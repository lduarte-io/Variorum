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
            deleteOutgoing: { calls.record("delete"); return true },
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
            deleteOutgoing: { calls.record("delete"); return true },
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
            deleteOutgoing: { calls.record("delete"); return true },
            rollBackIncoming: { calls.record("rollback") })
        #expect(outcome == .done)
        #expect(calls.count("delete") == 1)
        #expect(calls.count("rollback") == 0)
    }

    /// 17h R3-5, red-on-old: the delete leg's status decides the outcome.
    /// Pre-fix `deleteOutgoing` was `() -> Void` — a refused release still
    /// returned `.done`, so the custody law bound writes only and a
    /// transition could complete with the outgoing item silently in place.
    @Test func aRefusedOutgoingReleaseBacksTheTransitionOut() {
        let calls = Calls()
        let outcome = CustodyHandover.perform(
            write: { true },
            verify: { true },
            deleteOutgoing: { calls.record("delete"); return false },
            rollBackIncoming: { calls.record("rollback") })
        #expect(outcome == .outgoingNotReleased)
        #expect(calls.count("rollback") == 1,
                "the incoming write is tidied best-effort — the transition refuses whole")
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
    ///
    /// FULLY FAKED STORE (pre-13u Act 9, F1 — the state-dependent pin).
    /// The earlier form drove `.keychain(custody: fake)`, which fakes the
    /// TRANSITION only: its `load` is LIVE (`E2EELaunchKeyCache` → the
    /// real `E2EEKeychainStorage`), and `setBiometricRequirement` guards
    /// `store.load()` first — so on any machine without a readable plain
    /// `e2ee-keys` item the fake seam was never consulted and the pin
    /// went red on machine Keychain state. (Its green at 17g's close was
    /// borrowed from the R3-1 drill's litter; the author's owed cleanup
    /// turned it red.) A memberwise store consults nothing live — the pin
    /// is about the SESSION's outcome→sentence mapping, and the factory's
    /// transition mapping keeps its own pin above.
    @MainActor @Test func theE2EESurfaceNamesTheSymptomWhenAWriteLandsUnreadable() async {
        let material = material()
        let session = EncryptionSession(
            store: DeviceKeyStore(
                load: { material },
                save: { _ in true },
                clear: {},
                biometryAvailable: { true },
                isBiometricGateOn: { false },
                setBiometricGate: { _, _ in .wroteButUnreadable },
                unlockWithBiometrics: { nil }),
            client: nil, signedIn: { true })
        await session.setBiometricRequirement(true)
        // F6 (pre-13u Act 9): the E2EE arm speaks its OWN sentence now —
        // the store-key one promised "still open your library", which is
        // non-responsive here; this surface's road back is passphrase
        // re-enrollment of sync custody.
        #expect(session.lastError == ProtectionCopy.syncKeysWroteButUnreadable,
                "the honest arm names the keychain-identity symptom AND this surface's own road back")
    }

    // MARK: - The LIVE wiring's composition (17h R3-4)

    /// Ordered recorder — the wiring pins are about WHICH leaf plays
    /// WHICH role, so order and identity both matter.
    private final class OrderedCalls: @unchecked Sendable {
        private let lock = NSLock()
        private var recorded: [String] = []
        var names: [String] { lock.lock(); defer { lock.unlock() }; return recorded }
        func note(_ name: String) { lock.lock(); recorded.append(name); lock.unlock() }
    }

    private func recordingLeaves(
        _ log: OrderedCalls,
        gatedExists: Bool = true,
        loadedBack: DeviceKeyMaterial? = nil,
        deletesSucceed: Bool = true
    ) -> E2EECustodyLeaves {
        E2EECustodyLeaves(
            saveGated: { _ in log.note("saveGated"); return true },
            savePlain: { _ in log.note("savePlain"); return true },
            loadPlain: { log.note("loadPlain"); return loadedBack },
            gatedExists: { log.note("gatedExists"); return gatedExists },
            deletePlain: { log.note("deletePlain"); return deletesSucceed },
            deleteGated: { log.note("deleteGated"); return deletesSucceed })
    }

    /// 17h R3-4 — THE WIRING PIN. `.live` is `wired(leaves: .live)`, and
    /// these drive the SAME composition through recording leaves: for the
    /// gate-ON direction the OUTGOING item is the PLAIN one and the
    /// rollback target the GATED one. Transposing
    /// `deleteOutgoing`/`rollBackIncoming` in `wired` — the 2026-08-30
    /// incident's reinstatement, which round 3 found no test could see —
    /// changes these names: red.
    @Test func gateOnReleasesThePlainItemAndOnlyThePlainItem() {
        let log = OrderedCalls()
        let storage = E2EECustodyStorage.wired(leaves: recordingLeaves(log))
        #expect(storage.setGated(material()) == .done)
        #expect(log.names == ["saveGated", "gatedExists", "deletePlain"])
    }

    @Test func gateOnRollsBackTheGatedItemWhenTheWriteIsUnreadable() {
        let log = OrderedCalls()
        let storage = E2EECustodyStorage.wired(
            leaves: recordingLeaves(log, gatedExists: false))
        #expect(storage.setGated(material()) == .wroteButUnreadable)
        #expect(log.names == ["saveGated", "gatedExists", "deleteGated"],
                "the rollback tidies the INCOMING gated write — never the plain custody")
    }

    @Test func gateOffReleasesTheGatedItemAndOnlyTheGatedItem() {
        let log = OrderedCalls()
        let m = material()
        let storage = E2EECustodyStorage.wired(
            leaves: recordingLeaves(log, loadedBack: m))
        #expect(storage.setPlain(m) == .done)
        #expect(log.names == ["savePlain", "loadPlain", "deleteGated"])
    }

    @Test func gateOffRollsBackThePlainItemWhenTheWriteIsUnreadable() {
        let log = OrderedCalls()
        let storage = E2EECustodyStorage.wired(
            leaves: recordingLeaves(log, loadedBack: nil))
        #expect(storage.setPlain(material()) == .wroteButUnreadable)
        #expect(log.names == ["savePlain", "loadPlain", "deletePlain"])
    }

    /// 17h R3-5 through the composition: a refused release backs out, and
    /// the best-effort rollback targets the INCOMING item.
    @Test func aRefusedPlainReleaseBacksTheGateOnTransitionOut() {
        let log = OrderedCalls()
        let storage = E2EECustodyStorage.wired(
            leaves: recordingLeaves(log, deletesSucceed: false))
        #expect(storage.setGated(material()) == .outgoingNotReleased)
        #expect(log.names == ["saveGated", "gatedExists", "deletePlain", "deleteGated"],
                "the refused release, then the best-effort rollback of the incoming item")
    }

    @Test func theE2EEGateTurnsOffOnlyWhenThePlainItemReadsBack() {
        // R3-NIT rider (pre-13u Act 9): the `.done` arms of the real
        // factory write the process-global `E2EELaunchKeyCache` — save and
        // restore it so this test never leaks state into a neighbor.
        let cacheBefore = E2EELaunchKeyCache.shared.value
        defer { E2EELaunchKeyCache.shared.value = cacheBefore }

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
