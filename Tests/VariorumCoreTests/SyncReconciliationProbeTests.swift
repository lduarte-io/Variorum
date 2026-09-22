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

    // MARK: - P2: the same scenario, but the deletion is purge-aged

    private func sweep(
        _ client: SyncClient, _ server: FakeSyncServer
    ) async throws -> PurgeJanitor.SweepReport {
        try await client.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: client.keyProvider).sweep()
        }
    }

    /// The scheduler's B2 pre-pass, exactly as production runs it BEFORE
    /// each round's drain (SyncScheduler.runOneRound).
    private func reconcile(
        _ client: SyncClient, _ server: FakeSyncServer
    ) async throws -> Int {
        try await client.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: client.keyProvider).reconcileLedger()
        }
    }

    /// Backdates one deletion event's EXACT stamp coherently (the
    /// PurgeConvergenceTests idiom) — run BEFORE pushing so the mirror
    /// holds the backdated stamps too.
    private func backdate(
        _ client: SyncClient, from original: String, to stamp: String
    ) throws {
        try client.db.write { db in
            for table in SyncSchema.tables where table.hasTombstone {
                try db.execute(
                    sql: "UPDATE \(table.name) SET deleted_at = ? WHERE deleted_at = ?",
                    arguments: [stamp, original])
            }
        }
    }

    /// Past the 30-day window for the harness clock (starts 2026-07-01).
    private let oldStamp = "2026-05-01T00:00:00.000Z"

    /// P1's offline divergence, purge-aged: converged note N; sync stops;
    /// the phone deletes N (stamp backdated past 30 days); the laptop
    /// edits T1 and branches T2, both unpushed. Both device cursors are
    /// committed + server-recorded at head before the stop.
    private func p2Setup() async throws -> (
        laptop: SyncClient, phone: SyncClient, server: FakeSyncServer,
        noteID: String, blockID: String, t1: String, t2: String
    ) {
        let (laptop, phone, server) = try pair()
        let (noteID, blockID, t1): (String, String, String) = try laptop.with { ops, _ in
            let note = try ops.createPost(title: "her note", profile: .journal)
            let made = try ops.newBlock(in: note.id, text: "the shared base", at: .end)
            return (note.id, made.block.id, made.variant.id)
        }
        try await productionQuiescence(laptop, phone, server: server)
        // Extra rounds so each device's SERVER-RECORDED cursor reaches head
        // (the device id rides only a pull's first window, where `since` is
        // the pre-round committed cursor — the purge-suite idiom, in
        // production's order).
        for _ in 0..<2 {
            _ = try await productionRound(laptop)
            _ = try await productionRound(phone)
        }

        try phone.with { ops, _ in try ops.deleteContainer(noteID) }
        let freshStamp = try phone.db.deletedAt("container", noteID)!
        try backdate(phone, from: freshStamp, to: oldStamp)
        let t2: String = try laptop.with { ops, _ in
            try ops.autosave(t1, text: "rewritten on the laptop", charDelta: 9)
            let t2 = try ops.branchVariant(blockID, from: t1)
            try ops.autosave(t2.id, text: "a brand-new take", charDelta: 5)
            return t2.id
        }
        return (laptop, phone, server, noteID, blockID, t1, t2)
    }

    /// THE MEMO'S P2, first half: **the horizon HOLDS the purge while the
    /// laptop is a live device.** The phone's janitor must NOT purge N
    /// until the laptop has pulled the tombstone; once the laptop has
    /// caught up (P1's merge dance included), the purge proceeds.
    ///
    /// Recorded consequence, deliberate per the 13j memo §2 (no defect):
    /// the 30-day window belongs to the DELETION's clock, not to each
    /// device's discovery clock — a laptop offline longer than the window
    /// meets a purge-eligible family the moment it reconnects; the horizon
    /// guarantees it SEES the deletion (the tombstone lands, the Trash
    /// lists it) before the bytes go, not that its own 30 days restart.
    @Test func p2aTheHorizonHoldsThePurgeWhileTheLaptopIsLive() async throws {
        let (laptop, phone, server, noteID, _, t1, t2) = try await p2Setup()

        // The phone rounds (tombstones pushed, cursor committed + recorded);
        // the laptop stays silent but IN the horizon window.
        for _ in 0..<3 { _ = try await productionRound(phone) }
        let held = try await sweep(phone, server)
        #expect(held.familiesPurged == 0,
                "the laptop has not seen the deletion — the horizon holds")
        #expect(held.familiesDeferred >= 1)
        #expect(await server.currentRow(table: "container", rowID: noteID) != nil,
                "nothing leaves the mirror while a live device is behind")

        // The laptop catches up: P1's merge dance (edit rides the row into
        // the Trash, T2 joins the cascade), then cursors re-record.
        for _ in 0..<3 { _ = try await productionRound(laptop) }
        for _ in 0..<3 { _ = try await productionRound(phone) }
        #expect(try laptop.db.deletedAt("container", noteID) != nil,
                "the laptop saw the deletion before any byte went")

        // NOW the purge proceeds — the whole family, the laptop's late
        // edits included (they rode the tombstoned rows).
        let after = try await sweep(phone, server)
        #expect(after.familiesPurged >= 1, "every live device has seen it — the purge runs")
        #expect(await server.currentRow(table: "container", rowID: noteID) == nil)
        #expect(await server.currentRow(table: "variant", rowID: t1) == nil)
        #expect(await server.purgedLedgerCount() > 0)

        // The laptop reconciles through the ledger and both stores converge
        // to zero family rows.
        _ = try await sweep(laptop, server)
        for client in [laptop, phone] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM container WHERE id = ?", [noteID]) == 0, "\(client.name)")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE id IN (?, ?)", [t1, t2]) == 0, "\(client.name)")
        }
        for _ in 0..<2 {
            _ = try await productionRound(laptop)
            _ = try await productionRound(phone)
        }
        #expect(try laptop.outboxCount() == 0)
        #expect(try phone.outboxCount() == 0)
        #expect(try laptop.syncedDump() == phone.syncedDump())
    }

    /// THE MEMO'S P2, second half — THE DROP-OUT CASE, and the memo's
    /// unsettled corner: the laptop goes silent past 60 days; the phone's
    /// janitor purges N's family; the laptop returns holding its dirty T1
    /// edit and the never-pushed take T2. **What does the returner do
    /// LOCALLY with T1/T2?**
    ///
    /// THE RECORDED ANSWER (shipped behavior, production path — the
    /// scheduler's B2 ledger-reconciliation pre-pass runs BEFORE the
    /// round's drain): **DROP, family-complete, silently.** The ledger
    /// names every row the purging device knew (N, the block, T1); the
    /// pre-pass expands those roots against the returner's own store, so
    /// the never-pushed T2 — the one id no ledger could ever name — dies
    /// WITH its family, outbox entries swept. The subsequent round is
    /// clean: nothing meets the `purged` refusal (the entries are already
    /// gone), nothing lands as a mirror orphan, no stall. No say-so fires:
    /// `deviceLeftBehindReloadRequired` gates on the ledger FLOOR, which
    /// stays 0 until ledger pruning exists — so the returner's unpushed
    /// writing under a purged family is discarded with NO surface at all.
    /// This is the purge-wins doctrine's letter, named out loud at
    /// `PurgeJanitor.reconcileLedger`'s own comment — canon-conforming
    /// CODE; whether the PRODUCT wants a rescue/say-so here is the memo's
    /// unsettled corner → QUESTIONS (the batch record carries the draft).
    @Test func p2bTheSixtyDayDropoutReturnerDropsItsEditsWithThePurgedFamily() async throws {
        let (laptop, phone, server, noteID, blockID, t1, t2) = try await p2Setup()

        // The phone rounds; the laptop still holds the horizon (sanity).
        for _ in 0..<3 { _ = try await productionRound(phone) }
        let held = try await sweep(phone, server)
        #expect(held.familiesPurged == 0 && held.familiesDeferred >= 1)

        // The laptop goes dark past the 60-day window; the phone's next
        // round re-stamps its own seen-at; the purge proceeds without the
        // laptop.
        await server.setHorizonDropoutTicks(10)
        await server.advanceClock(by: 100)
        for _ in 0..<2 { _ = try await productionRound(phone) }
        let after = try await sweep(phone, server)
        #expect(after.familiesPurged >= 1, "the drop-out no longer holds the horizon")
        #expect(await server.currentRow(table: "container", rowID: noteID) == nil)
        let ledgered = await server.purgedLedgerCount()
        #expect(ledgered > 0)
        #expect(await server.isPurged(table: "variant", rowID: t1))
        #expect(!(await server.isPurged(table: "variant", rowID: t2)),
                "the never-pushed take's id is the one no ledger can name")

        // THE RETURNER, production path: the B2 pre-pass BEFORE the round.
        let dropped = try await reconcile(laptop, server)
        #expect(dropped > 0, "the pre-pass dropped the purged family's local rows")
        #expect(try laptop.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [noteID]) == 0)
        #expect(try laptop.db.fetchInt(
            "SELECT COUNT(*) FROM block WHERE id = ?", [blockID]) == 0)
        #expect(try laptop.db.fetchInt(
            "SELECT COUNT(*) FROM variant WHERE id = ?", [t1]) == 0,
            "the dirty EDIT is discarded with the family — the purge-wins letter")
        #expect(try laptop.db.fetchInt(
            "SELECT COUNT(*) FROM variant WHERE id = ?", [t2]) == 0,
            "the never-pushed take dies WITH its family — family expansion, not the ledger, names it")
        #expect(try laptop.outboxContains("variant", t1) == false)
        #expect(try laptop.outboxContains("variant", t2) == false)

        // The returner's round is clean: nothing meets `purged`, nothing
        // lands as a mirror orphan, no stall.
        let round = try await productionRound(laptop)
        #expect(round.push.purged == 0, "the refusal never fires — the pre-pass already screened")
        #expect(round.pull.stalled == false)
        #expect(await server.currentRow(table: "variant", rowID: t2) == nil,
                "no mirror orphan: the unpushed child never landed")

        for _ in 0..<2 {
            _ = try await productionRound(laptop)
            _ = try await productionRound(phone)
        }
        #expect(try laptop.outboxCount() == 0)
        #expect(try phone.outboxCount() == 0)
        #expect(try laptop.syncedDump() == phone.syncedDump())
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
