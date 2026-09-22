import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// RUN B batch B1 — THE HUNT (17i's opening act): the reconciliation probes
/// from `notes/plans/pre-13u-memo-sync-disagreements.md` ⚠️ UNSETTLED, run
/// in PRODUCTION'S round shape (`productionRound` — pull → push per device,
/// push chunks as separate server transactions), never the harness's
/// convenience order. Each probe ASSERTS AND RECORDS what happens; the
/// answers are written into the memo's ⚠️ UNSETTLED section and the run
/// record (`notes/plans/run-b-sync-correctness.md`, BATCH B1 RECORD).
///
/// A probe that confirms canon is a GREEN pin documenting settled behavior.
/// A probe that reproduces a defect is `withKnownIssue`-wrapped citing its
/// ledger row — never a bare red.
@Suite("Sync reconciliation probes (RUN B batch B1 — 17i's hunt)")
struct SyncReconciliationProbeTests {
    private func pair() throws -> (laptop: SyncClient, phone: SyncClient, server: FakeSyncServer) {
        let server = FakeSyncServer()
        let laptop = try SyncClient(name: "laptop", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)
        return (laptop, phone, server)
    }

    // MARK: - P1: her scenario — delete-vs-edit-plus-new-take

    /// THE MEMO'S P1, verbatim: both devices hold note N (one block, one
    /// take T1); sync stops; phone `deleteContainer(N)`; laptop
    /// `autosave(T1, newText)` + `branchVariant` (a new take T2); sync
    /// resumes laptop first (pull → push), then phone.
    ///
    /// ASSERTED AND RECORDED:
    ///  - N is in the Trash on BOTH devices, `deleted_at` matching (the
    ///    tombstone wins — rule 1);
    ///  - T2 exists on both, tombstoned with N's EXACT stamp (the §7 orphan
    ///    repair direction 2: a live child arriving under a locally-dead
    ///    parent joins the cascade — it rides Put back);
    ///  - **T1's `working_text` after the merge is the laptop's NEW text**
    ///    — the server-wins baseline carries the laptop-pushed edit into
    ///    the merged row while the phone's tombstone overlays it, so the
    ///    edit survives INTO the Trash on the row itself; NO conflict card
    ///    is minted (the whole BLOCK died with the note, so
    ///    `rescueLosingText`'s block-live guard skips — the phone's pre-edit
    ///    text was the same take's ancestor state, not a separate intent,
    ///    so nothing of anyone's intent is lost);
    ///  - `restoreContainer(N)` on the laptop revives the whole family —
    ///    N, the block, T1 (still the NEW text), T2 — and converges to the
    ///    phone byte-identically.
    @Test(arguments: [200, 1])
    func p1DeleteVsEditPlusNewTake(batchSize: Int) async throws {
        let (laptop, phone, server) = try pair()
        let (noteID, blockID, t1): (String, String, String) = try laptop.with { ops, _ in
            let note = try ops.createPost(title: "her note", profile: .journal)
            let made = try ops.newBlock(in: note.id, text: "the shared base", at: .end)
            return (note.id, made.block.id, made.variant.id)
        }
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)

        // Sync stops. The phone deletes; the laptop keeps working.
        try phone.with { ops, _ in try ops.deleteContainer(noteID) }
        let t2: String = try laptop.with { ops, _ in
            try ops.autosave(t1, text: "rewritten on the laptop", charDelta: 9)
            let t2 = try ops.branchVariant(blockID, from: t1)
            try ops.autosave(t2.id, text: "a brand-new take", charDelta: 5)
            return t2.id
        }

        // Sync resumes: laptop first (pull → push), then phone, then settle.
        _ = try await productionRound(laptop, batchSize: batchSize)
        let phoneRound = try await productionRound(phone, batchSize: batchSize)
        // Positive activity (the postmortem's vacuous-pass discipline): the
        // phone's resume round MERGED its dirty tombstoned rows against the
        // laptop's pushed edits, applied the new take, and ran the inline
        // orphan repair that stamps it into the cascade.
        #expect(phoneRound.pull.merged >= 2, "N and T1 were dirty-merged, not clean-applied")
        #expect(phoneRound.pull.applied >= 1, "T2 arrived")
        #expect(phoneRound.pull.repairs >= 1, "the direction-2 orphan repair stamped T2")
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)
        #expect(try laptop.syncedDump() == phone.syncedDump())

        // 1. N is in the Trash on both, stamps matching.
        let stamp = try phone.db.deletedAt("container", noteID)
        #expect(stamp != nil, "the deletion wins — N is in the Trash")
        #expect(try laptop.db.deletedAt("container", noteID) == stamp)

        // 2. T2 exists on both, tombstoned with N's EXACT stamp.
        for client in [laptop, phone] {
            #expect(try client.db.deletedAt("variant", t2) == stamp,
                    "\(client.name): T2 joins the note's cascade — same stamp, rides Put back")
        }

        // 3. THE RECORDED ANSWER: T1 carries the laptop's NEW text into the
        // Trash, on both devices; no conflict card (the block died whole).
        for client in [laptop, phone] {
            #expect(try client.db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [t1])
                == "rewritten on the laptop",
                "\(client.name): the edit survives into the Trash on the row itself")
            #expect(try client.db.deletedAt("variant", t1) == stamp)
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE label = 'conflict'") == 0,
                "\(client.name): no conflict card — the whole block died, the rescue skips")
        }

        // 4. Put back on the laptop revives the family and converges.
        try laptop.with { ops, _ in try ops.restoreContainer(noteID) }
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)
        #expect(try laptop.syncedDump() == phone.syncedDump())
        for client in [laptop, phone] {
            #expect(try client.db.deletedAt("container", noteID) == nil, "\(client.name): N is back")
            #expect(try client.db.deletedAt("block", blockID) == nil)
            #expect(try client.db.deletedAt("variant", t1) == nil)
            #expect(try client.db.deletedAt("variant", t2) == nil,
                    "\(client.name): the new take rode Put back home")
            let texts = try await client.db.read { db in
                Set(try String.fetchAll(
                    db, sql: "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]))
            }
            #expect(texts == ["rewritten on the laptop", "a brand-new take"],
                    "\(client.name): both texts came back whole")
        }
    }

    // MARK: - P3: edit-vs-edit on one take (S5), production shape

    /// THE MEMO'S P3: both devices edit T1 offline; sync in production's
    /// order → the loser is a `'conflict'` card on the same block; nothing
    /// lost on either side. (The Phase 5 pin re-proven under the round
    /// shape production actually runs.)
    @Test(arguments: [200, 1])
    func p3EditVsEditOnOneTake(batchSize: Int) async throws {
        let (laptop, phone, server) = try pair()
        let (blockID, t1): (String, String) = try laptop.with { ops, _ in
            let note = try ops.createPost(title: "p3", profile: .journal)
            let made = try ops.newBlock(in: note.id, text: "the shared base", at: .end)
            return (made.block.id, made.variant.id)
        }
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)

        try laptop.with { ops, _ in try ops.autosave(t1, text: "rewritten on the laptop", charDelta: 9) }
        try phone.with { ops, _ in try ops.autosave(t1, text: "rewritten on the phone", charDelta: 9) }

        _ = try await productionRound(laptop, batchSize: batchSize)
        _ = try await productionRound(phone, batchSize: batchSize)
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)
        #expect(try laptop.syncedDump() == phone.syncedDump())

        for client in [laptop, phone] {
            let texts = try await client.db.read { db in
                Set(try String.fetchAll(
                    db, sql: "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]))
            }
            #expect(texts == ["rewritten on the laptop", "rewritten on the phone"],
                    "\(client.name): nothing lost on either side")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL") == 1,
                "\(client.name): the loser is exactly one conflict card")
        }
    }
}
