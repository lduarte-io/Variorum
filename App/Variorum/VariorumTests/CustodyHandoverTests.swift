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

    private func record() -> SyncCustodyRecord {
        SyncCustodyRecord(deviceID: "handover-device", material: material())
    }

    private func material() -> DeviceKeyMaterial {
        DeviceKeyMaterial(
            masterKey: Data(repeating: 0, count: 32),
            corpusKey: Data(repeating: 1, count: 32), corpusKeyID: "corpus",
            journalBridgeKey: Data(repeating: 2, count: 32), journalBridgeKeyID: "bridge")
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
        loadedBack: SyncCustodyRecord? = nil,
        deletesSucceed: Bool = true,
        savePlainSucceeds: Bool = true
    ) -> E2EECustodyLeaves {
        E2EECustodyLeaves(
            saveGated: { _ in log.note("saveGated"); return true },
            savePlain: { _ in log.note("savePlain"); return savePlainSucceeds },
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
    /// pre-13x 1a: the gate-ON direction's OUTGOING act is no longer a
    /// delete — the bound item stays as the IDENTITY-ONLY item (the library
    /// keeps its identity; the material leaves it) — so the composition's
    /// third leaf is `savePlain`, and the rollback target stays the gated
    /// item.
    @Test func gateOnLeavesTheIdentityOnlyBoundItemAndOnlyThat() {
        let log = OrderedCalls()
        let storage = E2EECustodyStorage.wired(leaves: recordingLeaves(log))
        #expect(storage.setGated(record()) == .done)
        #expect(log.names == ["saveGated", "gatedExists", "savePlain"])
    }

    @Test func gateOnRollsBackTheGatedItemWhenTheWriteIsUnreadable() {
        let log = OrderedCalls()
        let storage = E2EECustodyStorage.wired(
            leaves: recordingLeaves(log, gatedExists: false))
        #expect(storage.setGated(record()) == .wroteButUnreadable)
        #expect(log.names == ["saveGated", "gatedExists", "deleteGated"],
                "the rollback tidies the INCOMING gated write — never the plain custody")
    }

    @Test func gateOffReleasesTheGatedItemAndOnlyTheGatedItem() {
        let log = OrderedCalls()
        let m = record()
        let storage = E2EECustodyStorage.wired(
            leaves: recordingLeaves(log, loadedBack: m))
        #expect(storage.setPlain(m) == .done)
        #expect(log.names == ["savePlain", "loadPlain", "deleteGated"])
    }

    @Test func gateOffRollsBackThePlainItemWhenTheWriteIsUnreadable() {
        let log = OrderedCalls()
        let storage = E2EECustodyStorage.wired(
            leaves: recordingLeaves(log, loadedBack: nil))
        #expect(storage.setPlain(record()) == .wroteButUnreadable)
        #expect(log.names == ["savePlain", "loadPlain", "deletePlain"])
    }

    /// 17h R3-5 through the composition: a refused outgoing act backs out,
    /// and the best-effort rollback targets the INCOMING item (pre-13x 1a:
    /// the outgoing act of gate-ON is the identity-only rewrite).
    @Test func aRefusedIdentityRewriteBacksTheGateOnTransitionOut() {
        let log = OrderedCalls()
        let storage = E2EECustodyStorage.wired(
            leaves: recordingLeaves(log, savePlainSucceeds: false))
        #expect(storage.setGated(record()) == .outgoingNotReleased)
        #expect(log.names == ["saveGated", "gatedExists", "savePlain", "deleteGated"],
                "the refused rewrite, then the best-effort rollback of the incoming item")
    }

    /// The migration hook (§11 — batch 2 runs it), pinned over recording
    /// leaves: the legacy material lands per shape, VERIFIED, then the legacy
    /// items are released and the CF-12 opt-in retired; a refused write
    /// leaves the legacy items in place.
    @Test func theSyncCustodyMigrationLandsPerShapeThenReleasesTheLegacyItems() {
        let retired = OrderedCalls()
        func legacy(_ log: OrderedCalls) -> SyncCustodyMigration.Legacy {
            SyncCustodyMigration.Legacy(
                material: material(), deviceID: "from-sync-state",
                deleteLegacyItems: { log.note("legacyDelete"); return true },
                retireOptIn: { retired.note("retired") })
        }
        let log = OrderedCalls()
        let session = SyncCustodySession()
        let expected = SyncCustodyRecord(deviceID: "from-sync-state", material: material())
        let silent = SyncCustodyMigration.migrateSyncCustodyToStoreScope(
            legacy: legacy(log), shape: .silent,
            leaves: recordingLeaves(log, loadedBack: expected), session: session)
        #expect(silent == .done)
        #expect(log.names == ["savePlain", "loadPlain", "legacyDelete"])
        #expect(retired.names.first == "retired", "the CF-12 opt-in default retires with the migration")
        #expect(session.record == nil, "the silent shape holds nothing in session memory")

        let log2 = OrderedCalls()
        let identityOnly = SyncCustodyRecord(deviceID: "from-sync-state", material: nil)
        let gated = SyncCustodyMigration.migrateSyncCustodyToStoreScope(
            legacy: legacy(log2), shape: .biometric,
            leaves: recordingLeaves(log2, loadedBack: identityOnly), session: session)
        #expect(gated == .done)
        #expect(log2.names == ["saveGated", "savePlain", "gatedExists", "loadPlain", "legacyDelete"])
        #expect(session.record == expected, "the biometric shape unlocks the session that migrated")

        let log3 = OrderedCalls()
        let refused = SyncCustodyMigration.migrateSyncCustodyToStoreScope(
            legacy: legacy(log3), shape: .silent,
            leaves: recordingLeaves(log3, loadedBack: nil), session: SyncCustodySession())
        #expect(refused == .wroteButUnreadable)
        #expect(!log3.names.contains("legacyDelete"), "a refused write leaves the legacy items in place")
    }

}
