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

    /// **RUN B B2 row 15 Part 1 (F-1's bytes; PROVISIONAL §6 silent-cell
    /// reading, QUESTIONS #143(a)) — P1's OTHER resume order, closed.**
    /// The memo's P1 probe ran laptop-first, so the edit reached the
    /// server before any tombstone met it. PHONE-FIRST, the same offline
    /// divergence lost the edit's BYTES on the old code: the phone's
    /// tombstone family arrives over the laptop's dirty UNPUSHED edit,
    /// the block is dead in the same batch so `rescueLosingText`'s
    /// conflict-card rescue skips, the server-wins baseline (the OLD
    /// text) lands, the merged row equals the server wholesale and the
    /// outbox entry clears — zero rows anywhere carry the edit. Part 1's
    /// rule: when the losing local text cannot be rescued as a card, it
    /// RIDES THE ROW — the same end-state P1 blessed for the pushed
    /// direction — and the row stays enqueued, so the ridden text pushes
    /// and both devices converge with the edit in the Trash; Put back
    /// returns it whole.
    @Test(arguments: [200, 1])
    func p1PhoneFirstResumeRidesTheUnpushedEditIntoTheTrash(batchSize: Int) async throws {
        let (laptop, phone, server) = try pair()
        let (noteID, blockID, t1): (String, String, String) = try laptop.with { ops, _ in
            let note = try ops.createPost(title: "her note", profile: .journal)
            let made = try ops.newBlock(in: note.id, text: "the shared base", at: .end)
            return (note.id, made.block.id, made.variant.id)
        }
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)

        // Sync stops. The phone deletes; the laptop edits, UNPUSHED.
        try phone.with { ops, _ in try ops.deleteContainer(noteID) }
        try laptop.with { ops, _ in
            try ops.autosave(t1, text: "rewritten on the laptop", charDelta: 9)
        }

        // The PHONE resumes first — its tombstones land before the
        // laptop's edit ever reaches the server.
        _ = try await productionRound(phone, batchSize: batchSize)
        _ = try await productionRound(laptop, batchSize: batchSize)
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)
        #expect(try laptop.syncedDump() == phone.syncedDump())

        let stamp = try phone.db.deletedAt("container", noteID)
        for client in [laptop, phone] {
            #expect(try client.db.deletedAt("variant", t1) == stamp,
                    "\(client.name): the deletion still wins — into the Trash (rule 1)")
            #expect(try client.db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [t1])
                == "rewritten on the laptop",
                "\(client.name): the unpushed edit rides the row — bytes never lost (§6's forbidden outcome)")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE label = 'conflict'") == 0,
                "\(client.name): no conflict card — the block died whole, the card rescue stays skipped")
        }

        // Put back returns the edit whole, and the pair converges.
        try laptop.with { ops, _ in try ops.restoreContainer(noteID) }
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)
        #expect(try laptop.syncedDump() == phone.syncedDump())
        for client in [laptop, phone] {
            #expect(try client.db.fetchString(
                """
                SELECT working_text FROM variant
                WHERE block_id = ? AND deleted_at IS NULL
                """, [blockID]) == "rewritten on the laptop", "\(client.name)")
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

    // MARK: - 17d P8: the purge-window mirror orphan (ledger row 6 — THE RUN)

    /// **17d P8, RUN AND REPRODUCED** (the entry's own rule: reproducing it
    /// IS the red-on-old pin). The verifier's deterministic construction:
    ///
    ///  1. note N converged on Mac A and phone B, both cursors recorded;
    ///  2. B (offline) creates block X inside N — X's rows exist ONLY on B;
    ///  3. A Delete-Nows N (tombstone + purge intent) and rounds;
    ///  4. B's round: the pull applies N's tombstone (the cascade takes X
    ///     with N's exact stamp), then B's push of X's rows is HELD —
    ///     `FakeSyncServer.holdNextPush`, the A5 in-flight-transaction
    ///     window: seqs assigned, rows invisible;
    ///  5. A's sweep runs inside that window: the family expands from A's
    ///     store, WHICH NEVER SAW X — `executePurge` removes exactly what A
    ///     knows and ledgers exactly what it was handed;
    ///  6. the held transaction commits: X's rows surface at their original
    ///     seqs — a placement referencing a container that exists NOWHERE
    ///     (purged from the mirror and every store) and that NO ledger
    ///     entry names.
    ///
    /// REPRODUCTION FACTS (asserted green — the mechanism's record):
    /// A's next pull stalls (`foreignKeysSatisfiable` → stopIndex
    /// truncation), the cursor holds, and it NEVER heals — the ledger
    /// reconciliation cannot name X, B's reconcile drops X locally on B but
    /// never from the mirror, and every later write B makes lands ABOVE the
    /// orphan, so A integrates NOTHING from the account ever again: the
    /// permanent one-way inbound jam, silent under P31.
    ///
    /// THE DESIRED CONTRACT (`withKnownIssue`-wrapped, citing RUN B ledger
    /// row 9 — B2 unwraps this as its red-on-old pin): a bounded number of
    /// rounds + ledger reconciles after the release must clear the jam.
    @Test func p8AHeldPushAcrossThePurgeWindowJamsThePullForever() async throws {
        let (a, b, server) = try pair()
        let (noteID, _, _): (String, String, String) = try a.with { ops, _ in
            let note = try ops.createPost(title: "doomed", profile: .generic)
            let made = try ops.newBlock(in: note.id, text: "the original words", at: .end)
            return (note.id, made.block.id, made.variant.id)
        }
        try await productionQuiescence(a, b, server: server)
        for _ in 0..<2 {
            _ = try await productionRound(a)
            _ = try await productionRound(b)
        }

        // 2. B creates X inside N, offline.
        let (blockX, variantX, placementX): (String, String, String) = try b.with { ops, db in
            let made = try ops.newBlock(in: noteID, text: "the phone's late block", at: .end)
            let placement = try db.fetchString(
                "SELECT id FROM container_block WHERE block_id = ?", [made.block.id])!
            return (made.block.id, made.variant.id, placement)
        }

        // 3. A Delete-Nows N and rounds (tombstones + intent pushed,
        // cursor committed + recorded).
        try a.with { ops, _ in
            try ops.deleteContainer(noteID)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: noteID)])
        }
        for _ in 0..<3 { _ = try await productionRound(a) }

        // 4. B's round, its push held open: the pull lands N's tombstone
        // (X joins the cascade, N's exact stamp), then X's rows get seqs
        // but stay invisible.
        await server.holdNextPush()
        _ = try await productionRound(b)
        #expect(try b.db.deletedAt("block", blockX) != nil,
                "X joined N's cascade on B before the push")
        _ = try await b.pull()  // records B's advanced cursor (first-window rule)

        // 5. A's sweep inside the window: the purge expands from A's store,
        // which never saw X.
        let sweep = try await sweep(a, server)
        #expect(sweep.familiesPurged >= 1, "the family was horizon-eligible and purged")
        #expect(await server.currentRow(table: "container", rowID: noteID) == nil)
        #expect(!(await server.isPurged(table: "container_block", rowID: placementX)),
                "no ledger entry names X's placement — the purging device never knew it")

        // 6. The held transaction commits: the orphan surfaces.
        await server.commitHeldPushes()
        #expect(await server.currentRow(table: "container_block", rowID: placementX) != nil,
                "the mirror keeps X's placement, referencing a container that exists nowhere")

        // REPRODUCTION FACTS: A's pull stalls AT the orphaned placement.
        // Precisely observed: block X and variant VX apply (their FK
        // closures resolve within the batch — the cursor advances past
        // them), then PX truncates the batch and the cursor holds just
        // below it, forever.
        let jammed = try await a.pull()
        #expect(jammed.stalled, "the FK walk cannot satisfy the orphan — the batch truncates")
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM container_block WHERE id = ?", [placementX]) == 0,
            "the orphaned placement never applies")
        let held = jammed.newCursor

        // Nothing heals it: A's ledger reconcile names nothing A still
        // holds; B's reconcile drops X locally on B but never from the
        // mirror; and every later write B makes lands ABOVE the orphan.
        _ = try await reconcile(a, server)
        _ = try await reconcile(b, server)
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM block WHERE id = ?", [blockX]) == 0,
                "B's reconcile swept X locally — no device holds a tombstone for the mirror's copy")
        let freshNote: String = try b.with { ops, _ in
            try ops.createPost(title: "life goes on", profile: .journal).id
        }
        for _ in 0..<2 { _ = try await productionRound(b) }
        let still = try await a.pull()
        #expect(still.stalled && still.newCursor == held,
                "the jam is permanent: the cursor holds at the stall point across rounds")
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [freshNote]) == 0,
            "one-way: B's fresh note can never reach A")
        _ = variantX

        // THE DESIRED CONTRACT — known-broken today (RUN B ledger row 9;
        // B2's fix unwraps this block as its red-on-old pin): bounded
        // rounds + reconciles after the release must clear the jam.
        await withKnownIssue(
            "17d P8 (RUN B ledger row 9): the purge-window mirror orphan jams the pull forever"
        ) {
            var healed = false
            for _ in 0..<4 {
                _ = try await reconcile(a, server)
                let round = try await a.pull()
                if !round.stalled { healed = true; break }
            }
            #expect(healed, "the inbound jam must clear within bounded rounds")
        }
    }

    /// The VISIBILITY-BAND variant of the same construction (the A5 skew
    /// without a held transaction): B's push COMMITS normally but the
    /// server's changefeed refuses to serve rows younger than the band
    /// (`visibilityHorizon`) — A pulls and sweeps inside the band, the
    /// clock advances, the orphan surfaces. Same jam, the timing window
    /// production actually has (~2 s on the real mirror). Wrapped citing
    /// the same ledger row.
    @Test func p8TheVisibilityBandVariantJamsTheSameWay() async throws {
        let band: Int64 = 5
        let server = FakeSyncServer(visibilityHorizon: band)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 977, seed: 2)

        let noteID: String = try a.with { ops, _ in
            let note = try ops.createPost(title: "doomed", profile: .generic)
            _ = try ops.newBlock(in: note.id, text: "the original words", at: .end)
            return note.id
        }
        // Every settled stage advances the clock past the band first, so
        // earlier rows are visible and only the FINAL push sits inside it.
        try await a.push()
        await server.advanceClock(by: band)
        try await productionQuiescence(a, b, server: server)
        for _ in 0..<2 {
            _ = try await productionRound(a)
            _ = try await productionRound(b)
        }

        let (blockX, placementX): (String, String) = try b.with { ops, db in
            let made = try ops.newBlock(in: noteID, text: "the phone's late block", at: .end)
            let placement = try db.fetchString(
                "SELECT id FROM container_block WHERE block_id = ?", [made.block.id])!
            return (made.block.id, placement)
        }
        try a.with { ops, _ in
            try ops.deleteContainer(noteID)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: noteID)])
        }
        _ = try await productionRound(a)
        await server.advanceClock(by: band)
        for _ in 0..<2 { _ = try await productionRound(a) }

        // B's round: the pull lands the tombstone (X joins the cascade);
        // the push commits INSIDE the band — visible to no pull yet.
        _ = try await productionRound(b)
        #expect(try b.db.deletedAt("block", blockX) != nil)
        _ = try await b.pull()

        // A sweeps inside the band; the clock then leaves it.
        let sweep = try await sweep(a, server)
        #expect(sweep.familiesPurged >= 1)
        #expect(await server.currentRow(table: "container", rowID: noteID) == nil)
        await server.advanceClock(by: band)

        let jammed = try await a.pull()
        #expect(jammed.stalled, "the band-hidden rows surfaced as the same permanent orphan")
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM container_block WHERE id = ?", [placementX]) == 0,
            "the orphaned placement never applies")
        #expect(await server.currentRow(table: "container_block", rowID: placementX) != nil)
        let held = jammed.newCursor
        let still = try await a.pull()
        #expect(still.stalled && still.newCursor == held,
                "the cursor holds at the stall point across rounds")

        await withKnownIssue(
            "17d P8 (RUN B ledger row 9): the visibility-band variant of the purge-window jam"
        ) {
            var healed = false
            for _ in 0..<4 {
                _ = try await reconcile(a, server)
                let round = try await a.pull()
                if !round.stalled { healed = true; break }
            }
            #expect(healed, "the inbound jam must clear within bounded rounds")
        }
    }

    // MARK: - P5(b)/(c): the sample-library dedupe's traced observations

    private static let sampleBookName = "the adventures of sherlock holmes"
    private static let sampleTagPath = "sherlock holmes"
    private static let sampleNotes: [(title: String, text: String)] = [
        ("About this book", "Attribution text."),
        ("A Scandal in Bohemia", "To Sherlock Holmes she is always THE woman."),
    ]

    private static func sampleFacts() -> SampleLibraryDedupeFacts {
        let hashes = Dictionary(
            uniqueKeysWithValues: sampleNotes.map { ($0.title, BridgeHash.body($0.text)) })
        return SampleLibraryDedupeFacts(
            bookName: sampleBookName, tagPath: sampleTagPath,
            loadNoteHashes: { hashes }, hash: BridgeHash.body(_:))
    }

    private func dedupePair() throws -> (a: SyncClient, b: SyncClient, server: FakeSyncServer) {
        let (a, b, server) = try pair()
        a.sampleLibraryFacts = Self.sampleFacts()
        b.sampleLibraryFacts = Self.sampleFacts()
        return (a, b, server)
    }

    /// Seeds one copy in the seeder's exact shape (the dedupe suite's idiom).
    @discardableResult
    private func seedCopy(_ client: SyncClient) throws -> (bookID: String, postIDs: [String: String]) {
        try client.with { ops, _ in
            let book = try ops.createReading(
                name: Self.sampleBookName, kind: .curated, profile: "book")
            let tag = try ops.createTag(name: Self.sampleTagPath)
            var postIDs: [String: String] = [:]
            for note in Self.sampleNotes {
                let section = try ops.createSection(in: book.id, name: note.title)
                let minted = try ops.importPost(
                    title: note.title, text: note.text, undoLabel: "Sample Library")
                _ = try ops.addPostToReading(minted.container.id, to: book.id)
                try ops.assignPostToSection(minted.container.id, in: book.id, section: section.id)
                _ = try ops.applyTag(tag.id, toPost: minted.container.id)
                postIDs[note.title] = minted.container.id
            }
            return (book.id, postIDs)
        }
    }

    private func liveCopyIDs(_ client: SyncClient) throws -> [String] {
        try client.db.read { db in
            try String.fetchAll(
                db,
                sql: "SELECT id FROM reading WHERE name = ? AND deleted_at IS NULL ORDER BY id",
                arguments: [Self.sampleBookName])
        }
    }

    private func firstVariantID(_ client: SyncClient, postID: String) throws -> String {
        try client.db.read { db in
            try String.fetchOne(
                db,
                sql: """
                    SELECT v.id FROM variant v
                    JOIN container_block cb ON cb.block_id = v.block_id
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL AND v.deleted_at IS NULL
                    ORDER BY cb.position, v.id LIMIT 1
                    """,
                arguments: [postID])!
        }
    }

    /// **P5(b) — the double-retirement race, RUN AND REPRODUCED.** The
    /// memo's traced observation: the classifying device's push is delayed
    /// past the other device's pass, and the evidence changes between the
    /// two. Construction:
    ///
    ///  1. A seeds copyA, B seeds copyB; both push (copyB's PRISTINE bytes
    ///     are what the server holds);
    ///  2. B edits a copyB note — the edit sits in B's outbox, its pushes
    ///     DELAYED from here;
    ///  3. B pulls twice: its pass reads copyB EDITED (local evidence) →
    ///     retires copyA (the ruled "edited kept");
    ///  4. A pulls twice: its pass reads BOTH pristine (the edit never
    ///     arrived) → retires copyB (the ruled smaller-id keeper);
    ///  5. the delayed pushes land, production order (pull → push).
    ///
    /// REPRODUCTION FACTS (asserted green): the two retirements CROSS —
    /// tombstones win on both sides, **both copies end dead on both
    /// devices** (the shipped sample library vanishes into the Trash), and
    /// — sharper, production-order-specific — **the edit's bytes are LOST
    /// OUTRIGHT**: B's resume round pulls A's retirement BEFORE pushing
    /// (production's order), the merge lands the server's pristine
    /// tombstoned baseline over the dirty edited row, the rescue skips
    /// because the block died earlier in the same batch, and the cleared
    /// outbox entry means the edit never reaches the server at all. The
    /// converged stores agree — this is a ruled-outcome violation ("an
    /// edited copy is NEVER silently retired") plus the §6 forbidden
    /// outcome (an edit nobody chose to lose, deleted), not a divergence.
    ///
    /// THE DESIRED CONTRACT (`withKnownIssue`-wrapped — a B1 HUNT FINDING;
    /// its ledger row lands at adjudication; owner candidates recorded in
    /// the batch record, the 18a fence re-verified not absorbed): the
    /// edited copy survives live with its edit intact.
    @Test func p5bTheDoubleRetirementRaceRetiresBothCopiesAndLosesTheEdit() async throws {
        let (a, b, server) = try dedupePair()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        try await a.push()
        try await b.push()

        // 2. B edits — from here B's pushes are delayed.
        let editedPost = copyB.postIDs["A Scandal in Bohemia"]!
        let editedVariant = try firstVariantID(b, postID: editedPost)
        try b.with { ops, _ in
            try ops.autosave(editedVariant, text: "Rewritten in her own words.", charDelta: 20)
        }

        // 3. B's pass: copyB edited (local evidence) → copyA retired on B.
        _ = try await b.pull()
        _ = try await b.pull()
        #expect(try liveCopyIDs(b) == [copyB.bookID],
                "B kept the edited copy and retired the pristine one — the ruled outcome, on B's evidence")

        // 4. A's pass: both pristine (the edit is still only in B's outbox)
        // → copyB retired on A.
        _ = try await a.pull()
        _ = try await a.pull()
        #expect(try liveCopyIDs(a) == [copyA.bookID],
                "A retired copyB as a redundant pristine copy — correct on A's evidence")

        // 5. The delayed pushes land, production order per device.
        try await productionQuiescence(a, b, server: server, maxRounds: 16)
        #expect(try a.syncedDump() == b.syncedDump(), "the stores CONVERGE — the loss is agreed on")

        // REPRODUCTION FACTS: both copies dead everywhere; the edit's bytes
        // exist nowhere — live or tombstoned, local or mirror.
        for client in [a, b] {
            #expect(try liveCopyIDs(client).isEmpty,
                    "\(client.name): the whole sample library vanished — both copies retired")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE working_text = 'Rewritten in her own words.'") == 0,
                "\(client.name): the edit was clobbered by the pristine tombstoned baseline (rescue skipped — block dead)")
        }
        let mirrorTexts = await server.allStoredRows.filter { $0.table == "variant" }
        _ = mirrorTexts  // ciphertext on the wire; the local stores above are the honest surface

        let liveOnB = try liveCopyIDs(b)
        withKnownIssue(
            "B1 hunt finding (P5(b)): the double-retirement race retires the EDITED copy and loses the edit"
        ) {
            #expect(liveOnB == [copyB.bookID],
                    "the edited copy must survive on both devices")
        }
    }

    /// **P5(c) — the echo pull's extra round, RUN AND RECORDED (designed
    /// cost, green pin) — and the mechanism OBSERVED is sharper than the
    /// memo's phrase.** Under PRODUCTION rounds (pull → push per device),
    /// the deferring device takes THREE rounds from meeting to decision:
    ///
    ///  - round 1's pull brings the other copy → the arrived-this-batch
    ///    deferral + the one-shot marker (R2-3);
    ///  - round 2's pull is NOT empty — it serves back the device's OWN
    ///    push ECHO (its copy's rows, pushed in round 1's push half, sit
    ///    above its cursor). The echo applies that copy's `reading` row
    ///    again, so the arrived-this-batch rule RE-DEFERS and re-arms the
    ///    marker — THE ECHO PULL, costing the extra round the memo's
    ///    observation names;
    ///  - round 3's pull is the genuinely empty window: the marker fires
    ///    the pass, which decides.
    ///
    /// (The harness's convenience order hid a round: pushing both copies
    /// before any pull folds the meeting and the echo into ONE window, so
    /// the old suites saw a 1-round deferral. Production's shape shows 2.)
    /// Latency only — convergence intact, verdicts unchanged. Not a
    /// defect; pinned so the cost is a stated fact.
    @Test func p5cTheDeferralPlusTheEchoPullCostTwoRoundsPerMeeting() async throws {
        let (a, b, server) = try dedupePair()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)

        _ = try await productionRound(a)   // copyA lands on the server
        _ = try await productionRound(b)   // B meets copyA: defer + marker; copyB lands
        #expect(try liveCopyIDs(b) == [copyA.bookID, copyB.bookID].sorted(),
                "round 1 on B: the meeting round DEFERS — both copies stand")
        #expect(try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'sample_dedupe_pending'") == "1",
            "the one-shot marker is armed")

        // Round 2: THE ECHO PULL — B's own push comes back, re-defers.
        let echo = try await productionRound(b)
        #expect(echo.pull.applied > 0, "the echo window is NOT empty — B's own copy returns")
        #expect(try liveCopyIDs(b) == [copyA.bookID, copyB.bookID].sorted(),
                "the echo re-triggers the arrived-this-batch deferral — both copies still stand")
        #expect(try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'sample_dedupe_pending'") == "1",
            "the marker re-armed for the next window")

        // Round 3: the genuinely empty window decides.
        let deciding = try await productionRound(b)
        #expect(deciding.pull.applied == 0, "the deciding pull is the EMPTY window")
        #expect(deciding.pull.repairs > 0, "positive activity: the deferred pass ran and retired")
        #expect(try liveCopyIDs(b) == [copyA.bookID],
                "round 3 on B decides: the smaller-id keeper")

        try await productionQuiescence(a, b, server: server, maxRounds: 16)
        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID], "\(client.name)")
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
