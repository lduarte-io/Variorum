import Foundation
import Testing

@testable import Variorum
import VariorumCore

private final class Calls: @unchecked Sendable {
    private let lock = NSLock()
    private var counts: [String: Int] = [:]
    func record(_ name: String) { lock.lock(); counts[name, default: 0] += 1; lock.unlock() }
    func count(_ name: String) -> Int { lock.lock(); defer { lock.unlock() }; return counts[name] ?? 0 }
}

/// 13p-fix ladder R2-1/R2-3. The custody handover rule, pinned directly —
/// and then pinned again at the E2EE transition, which round 2 found had
/// NO coverage of any kind even though its guard was the one protecting
/// the item that actually went missing on 2026-08-30.
@Suite("Custody handover (13p-fix)")
struct CustodyHandoverTests {
    @Test func aRefusedWriteChangesNothingAtAll() {
        let calls = Calls()
        let outcome = CustodyHandover.perform(
            write: { false },
            verify: { Issue.record("verify must not run after a refused write"); return true },
            deleteOutgoing: { calls.record("delete") },
            rollBackIncoming: { calls.record("rollback") })
        #expect(outcome == .writeRefused)
        #expect(calls.count("delete") == 0, "the outgoing custody is untouched")
        #expect(calls.count("rollback") == 0, "there is nothing to roll back")
    }

    /// THE RULE'S WHOLE POINT: a write can succeed into a place the read
    /// path cannot reach. The outgoing custody must survive that.
    @Test func aWriteThatCannotBeReadBackKeepsTheOutgoingCustody() {
        let calls = Calls()
        let outcome = CustodyHandover.perform(
            write: { true },
            verify: { false },
            deleteOutgoing: { calls.record("delete") },
            rollBackIncoming: { calls.record("rollback") })
        #expect(outcome == .wroteButUnreadable)
        #expect(calls.count("delete") == 0,
                "the ONLY reachable copy must not be deleted on a write's word alone")
        #expect(calls.count("rollback") == 1, "the unreachable write is tidied, best-effort")
    }

    @Test func aVerifiedWriteReleasesTheOutgoingCustody() {
        let calls = Calls()
        let outcome = CustodyHandover.perform(
            write: { true },
            verify: { true },
            deleteOutgoing: { calls.record("delete") },
            rollBackIncoming: { calls.record("rollback") })
        #expect(outcome == .done)
        #expect(calls.count("delete") == 1)
        #expect(calls.count("rollback") == 0)
    }

    // MARK: - The E2EE transition (round 2's MAJOR)

    private func material() -> DeviceKeyMaterial {
        DeviceKeyMaterial(
            masterKey: Data(repeating: 0, count: 32),
            corpusKey: Data(repeating: 1, count: 32), corpusKeyID: "corpus",
            journalBridgeKey: Data(repeating: 2, count: 32), journalBridgeKeyID: "bridge")
    }

    /// RED ON OLD for the half round 1 left unpinned: revert
    /// `setBiometricGate` to the pre-fix two-liner and this fails, because
    /// the transition would stop consulting the handover outcome at all.
    /// Drives a FAKE custody seam — no Keychain is touched.
    @Test func theE2EEGateRefusesWhenTheGatedWriteCannotBeReadBack() {
        let store = DeviceKeyStore.keychain(
            custody: E2EECustodyStorage(
                setGated: { _ in .wroteButUnreadable },
                setPlain: { _ in .done }))
        #expect(store.setBiometricGate(true, material()) == .wroteButUnreadable,
                "a gated item nothing can find is not a landed gate — and the plain item it would have replaced must not have been deleted")
    }

    /// 13p-fix R3-2, red-on-old: the E2EE surface must NOT say "nothing
    /// was altered" when something landed somewhere unreadable. Before the
    /// fix the seam returned a Bool, so this arm and a genuine refusal
    /// were the same sentence — on the family whose custody went missing.
    @MainActor @Test func theE2EESurfaceNamesTheSymptomWhenAWriteLandsUnreadable() async {
        let session = EncryptionSession(
            store: .keychain(custody: E2EECustodyStorage(
                setGated: { _ in .wroteButUnreadable },
                setPlain: { _ in .done })),
            client: nil, signedIn: { true })
        await session.setBiometricRequirement(true)
        #expect(session.lastError == ProtectionCopy.wroteButUnreadable,
                "the honest arm names the keychain-identity symptom, not 'nothing was altered'")
    }

    @Test func theE2EEGateTurnsOffOnlyWhenThePlainItemReadsBack() {
        let refusing = DeviceKeyStore.keychain(
            custody: E2EECustodyStorage(
                setGated: { _ in .done },
                setPlain: { _ in .wroteButUnreadable }))
        #expect(refusing.setBiometricGate(false, material()) == .wroteButUnreadable)

        let working = DeviceKeyStore.keychain(
            custody: E2EECustodyStorage(
                setGated: { _ in .done },
                setPlain: { _ in .done }))
        #expect(working.setBiometricGate(false, material()) == .done)
    }
}
