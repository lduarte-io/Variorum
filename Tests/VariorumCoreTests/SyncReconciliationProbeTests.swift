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

    /// **LADDER R1 F-R1 (RUN B's cold review): dirty ROW is not dirty
    /// TEXT.** The row-15 ride-the-row overlay keyed on the outbox's
    /// dirty-ROW fact alone — but `setTakeLabel` (and every metadata op)
    /// enqueues the variant row with `working_text` untouched, so a
    /// metadata-only-dirty row whose text is the un-edited ANCESTOR rode
    /// that stale text over the server's NEWER final edit: B labels a
    /// take; A autosaves new text into it and deletes the note; A pushes;
    /// B pulls — and on the old overlay B's stale ancestor text replaced
    /// the server baseline carrying A's only-ever edit, pushed, and
    /// converged everywhere with the new bytes GONE (a regression in §6's
    /// own forbidden class; the PRE-run server-wins handled this input
    /// correctly). The fix: the ride fires only when `working_text` is
    /// the ONLY divergence between the rows — a metadata-only-dirty row
    /// diverges in the metadata it dirtied and takes server-wins again;
    /// the genuinely-text-dirty rides exactly as ruled (#143(a)).
    @Test(arguments: [200, 1])
    func aMetadataOnlyDirtyRowNeverRidesStaleTextOverTheServersFinalEdit(batchSize: Int) async throws {
        let (laptop, phone, server) = try pair()
        let (noteID, _, t1): (String, String, String) = try laptop.with { ops, _ in
            let note = try ops.createPost(title: "her note", profile: .journal)
            let made = try ops.newBlock(in: note.id, text: "the shared base", at: .end)
            return (note.id, made.block.id, made.variant.id)
        }
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)

        // Sync stops. The PHONE only labels the take — its row is dirty,
        // its text is the ancestor. The LAPTOP writes the only new bytes
        // anyone ever typed, then deletes the note.
        try phone.with { ops, _ in try ops.setTakeLabel(t1, label: "keeper") }
        try laptop.with { ops, _ in
            try ops.autosave(t1, text: "her final words", charDelta: 6)
            try ops.deleteContainer(noteID)
        }

        // The laptop's tombstones + final text land first; the phone's
        // pull merges them over its metadata-dirty row.
        _ = try await productionRound(laptop, batchSize: batchSize)
        _ = try await productionRound(phone, batchSize: batchSize)
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)
        #expect(try laptop.syncedDump() == phone.syncedDump())

        let stamp = try laptop.db.deletedAt("container", noteID)
        for client in [laptop, phone] {
            #expect(try client.db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [t1])
                == "her final words",
                "\(client.name): the only new bytes survive into the Trash — the stale ancestor never rides")
            #expect(try client.db.deletedAt("variant", t1) == stamp,
                    "\(client.name): the deletion still wins (rule 1)")
            #expect(try client.db.fetchString(
                "SELECT label FROM variant WHERE id = ?", [t1]) == nil,
                "\(client.name): the label intent dropped by ordinary metadata CAS (§6) — the pre-fix outcome for metadata, unchanged")
        }

        // Put back returns A's final words, not the ancestor.
        try laptop.with { ops, _ in try ops.restoreContainer(noteID) }
        try await productionQuiescence(laptop, phone, server: server, batchSize: batchSize)
        for client in [laptop, phone] {
            #expect(try client.db.fetchString(
                "SELECT working_text FROM variant WHERE id = ? AND deleted_at IS NULL", [t1])
                == "her final words", "\(client.name)")
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

        // THE HEAL (RUN B ledger row 9 — B1's wrapped desired contract,
        // UNWRAPPED at B2 Phase 2 as the red-on-old pin): bounded
        // PRODUCTION rounds clear the jam. The scheduler's stalled report
        // hands the stall's identity to the janitor's ledger-verified
        // orphan heal — the missing referent is proven purged (its ledger
        // entry can never be satisfied by a future arrival), the stalled
        // TOMBSTONE completes its family's purge through the EXISTING
        // RPCs, and the cursor proceeds.
        let scheduler = SyncScheduler(
            engine: a.engine(),
            janitor: PurgeJanitor(transport: server, keyProvider: a.keyProvider))
        var healed = false
        for _ in 0..<4 {
            try await a.withAsync { _ in await scheduler.trigger() }
            await scheduler.awaitIdle()
            if await scheduler.status.pullStalled == false { healed = true; break }
        }
        #expect(healed, "the inbound jam clears within bounded rounds")
        #expect(await server.currentRow(table: "container_block", rowID: placementX) == nil,
                "the orphan left the mirror — §4f: really gone, the server included")
        #expect(await server.isPurged(table: "container_block", rowID: placementX),
                "…and the ledger fences any straggler")
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM block WHERE id = ?", [blockX]) == 0,
            "A's local residue (the block the purge never knew) completed the family")
        // The one-way jam is broken: B's fresh note reaches A.
        let after = try await a.pull()
        #expect(!after.stalled)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [freshNote]) == 1,
            "one-way no more — the account flows again")
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

        // THE HEAL (row 9 — the band variant's wrap, UNWRAPPED the same
        // way): the same scheduler road clears the same jam.
        let scheduler = SyncScheduler(
            engine: a.engine(),
            janitor: PurgeJanitor(transport: server, keyProvider: a.keyProvider))
        var healed = false
        for _ in 0..<4 {
            try await a.withAsync { _ in await scheduler.trigger() }
            await scheduler.awaitIdle()
            if await scheduler.status.pullStalled == false { healed = true; break }
        }
        #expect(healed, "the band-shaped jam clears within bounded rounds")
        #expect(await server.currentRow(table: "container_block", rowID: placementX) == nil)
        #expect(await server.isPurged(table: "container_block", rowID: placementX))
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM block WHERE id = ?", [blockX]) == 0)
    }

    /// **Row 9's ruled NARROWING, end to end: a LIVE stalled row is NEVER
    /// healed** — even when its missing referent is ledger-named. The
    /// construction: a note pushed live, its container then purged from
    /// the mirror (test-side `executePurge` — the ledger names it) while
    /// the PLACEMENT stays on the mirror LIVE. Every pull stalls at it;
    /// the ledger proves the referent gone; and the heal still refuses —
    /// an untraced class, left stalled and HONEST under row 12's flag
    /// (safe-by-refusal), never guessed at.
    @Test func aLiveStalledRowIsLeftStalledAndHonestNeverHealed() async throws {
        let (a, b, server) = try pair()
        let orphaned: String = try b.with { ops, _ in
            let note = try ops.createPost(title: "orphaned live", profile: .journal)
            _ = try ops.newBlock(in: note.id, text: "stranded words", at: .end)
            return note.id
        }
        _ = try await b.push()
        _ = try await server.executePurge(
            [SyncPurgeTarget(table: "container", rowID: orphaned)],
            activeKeyID: SyncTestKeys.corpusKeyID, keyProof: SyncTestKeys.keyProof)
        let placement = try b.db.fetchString(
            """
            SELECT id FROM container_block WHERE container_id = ?
            """, [orphaned])!
        let ledgerBefore = await server.purgedLedgerCount()

        let scheduler = SyncScheduler(
            engine: a.engine(),
            janitor: PurgeJanitor(transport: server, keyProvider: a.keyProvider))
        for _ in 0..<3 {
            try await a.withAsync { _ in await scheduler.trigger() }
            await scheduler.awaitIdle()
        }
        #expect(await scheduler.status.pullStalled,
                "the live orphan stays stalled — and the status says so (row 12)")
        #expect(await scheduler.status.lastError == nil, "no error is invented for it")
        #expect(await server.currentRow(table: "container_block", rowID: placement) != nil,
                "nothing was purged: a live row is never healed, whatever the ledger says")
        #expect(await server.purgedLedgerCount() == ledgerBefore,
                "no ledger entry was written — no executePurge fired")
    }

    /// **Row 9's transient guard: a missing referent the ledger does NOT
    /// name is a genuine §5 straggler — the heal touches NOTHING.** The
    /// owing device still holds the referent in its outbox; the class
    /// self-heals when it drains, and a heal here would purge rows whose
    /// parent is merely late. Driven directly (the discriminator's own
    /// refusal arm; the fire arms are the two unwrapped constructions).
    @Test func aStallWhoseReferentIsNotLedgerNamedHealsNothing() async throws {
        let (a, _, server) = try pair()
        _ = try await a.push()  // settings seeds; the janitor's preflight is real
        let headBefore = await server.headSeq
        let ledgerBefore = await server.purgedLedgerCount()
        let healed = try await a.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: a.keyProvider)
                .healPurgeOrphan(SyncEngine.PullStall(
                    table: "container_block", rowID: "some-arriving-placement",
                    tombstoneStamp: "2026-09-01T00:00:00.000Z",
                    missingReferents: [.init(table: "container", rowID: "a-late-parent")]))
        }
        #expect(!healed, "an unproven stall is a straggler, never an orphan")
        #expect(await server.headSeq == headBefore,
                "no executePurge fired — the mirror is untouched")
        #expect(await server.purgedLedgerCount() == ledgerBefore)
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

    /// **P5(b) — the double-retirement race, FIXED (RUN B ledger row 15;
    /// B1's `withKnownIssue` wrap UNWRAPPED at B2 Phase 2 as the
    /// red-on-old pin).** The race, as B1 reproduced it: the two passes
    /// classify on DIFFERENT evidence (the edit sits in the delayed
    /// pusher's outbox), the retirements CROSS, tombstones win both ways —
    /// both copies dead on both devices AND the edit's bytes lost outright
    /// (the pristine tombstoned baseline over the dirty row; rescue
    /// block-dead-skipped; outbox cleared).
    ///
    /// THE RULED MATRIX, now pinned green (the orchestrator's row-15
    /// ruling): **exactly-one-edited ⇒ the EDITED copy survives LIVE on
    /// both devices with its edit intact; the pristine copy stays
    /// retired.** Two repairs land it: Part 1 (the merge's ride-the-row
    /// rescue keeps the edit's bytes AND its outbox entry alive through
    /// the retirement batch) and Part 2 (the dedupe's defense leg: a
    /// same-name copy killed by an ARRIVING retirement, in the two-copy
    /// meeting context, whose family carries PRE-BATCH outbox dirt —
    /// unpushed local intent the retiring device could never have seen —
    /// revives exact-stamp and pushes).
    @Test func p5bTheDoubleRetirementRaceKeepsTheEditedCopyAliveWithItsEdit() async throws {
        let (a, b, server) = try dedupePair()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        try await a.push()
        try await b.push()

        // B edits — from here B's pushes are delayed.
        let editedPost = copyB.postIDs["A Scandal in Bohemia"]!
        let editedVariant = try firstVariantID(b, postID: editedPost)
        try b.with { ops, _ in
            try ops.autosave(editedVariant, text: "Rewritten in her own words.", charDelta: 20)
        }

        // B's pass: copyB edited (local evidence) → copyA retired on B.
        _ = try await b.pull()
        _ = try await b.pull()
        #expect(try liveCopyIDs(b) == [copyB.bookID],
                "B kept the edited copy and retired the pristine one — the ruled outcome, on B's evidence")

        // A's pass: both pristine (the edit is still only in B's outbox)
        // → copyB retired on A — correct on A's evidence; the defense is
        // what un-crosses it when the evidence lands.
        _ = try await a.pull()
        _ = try await a.pull()
        #expect(try liveCopyIDs(a) == [copyA.bookID],
                "A retired copyB as a redundant pristine copy — correct on A's evidence")

        // The delayed pushes land, production order per device.
        try await productionQuiescence(a, b, server: server, maxRounds: 16)
        #expect(try a.syncedDump() == b.syncedDump(), "the stores converge")

        // THE RULED MATRIX: the edited copy alive everywhere, edit intact,
        // the pristine copy retired. (Red on old: both copies dead and the
        // bytes gone — B1's reproduction, wrapped until this fix.)
        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "\(client.name): the EDITED copy survives — never silently retired (R-pre13u-8)")
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM variant
                WHERE working_text = 'Rewritten in her own words.' AND deleted_at IS NULL
                """) == 1,
                "\(client.name): the edit lives on the surviving copy (§6's forbidden outcome held off)")
            #expect(try client.db.deletedAt("reading", copyA.bookID) != nil,
                    "\(client.name): the pristine copy stays retired — one library, hers")
        }
    }

    /// **Row 15's BOTH-EDITED variant (the ruled matrix's second row):**
    /// each device edits ITS OWN copy before the crossing; each side's
    /// pass correctly keeps its own and retires the other on its local
    /// evidence; the retirements cross — and BOTH copies survive, each
    /// defended at its kill moment by the classifier's own EDITED verdict
    /// (reachable even though each device's edit has PUSHED by the time
    /// the peer's retirement arrives — the reason the defense reads the
    /// classifier at the kill, never the outbox). The settled state is
    /// then the pass's own both-edited row: two live copies, both edited,
    /// nothing retired.
    @Test func p5bBothEditedMeansBothCopiesSurvive() async throws {
        let (a, b, server) = try dedupePair()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        try await a.push()
        try await b.push()

        let variantA = try firstVariantID(a, postID: copyA.postIDs["A Scandal in Bohemia"]!)
        let variantB = try firstVariantID(b, postID: copyB.postIDs["A Scandal in Bohemia"]!)
        try a.with { ops, _ in
            try ops.autosave(variantA, text: "In A's own words.", charDelta: 10)
        }
        try b.with { ops, _ in
            try ops.autosave(variantB, text: "In B's own words.", charDelta: 10)
        }

        // Each side's pass, on its local evidence: keep own (edited),
        // retire the other (pristine as far as it can see).
        _ = try await a.pull()
        _ = try await a.pull()
        _ = try await b.pull()
        _ = try await b.pull()
        #expect(try liveCopyIDs(a) == [copyA.bookID])
        #expect(try liveCopyIDs(b) == [copyB.bookID])

        try await productionQuiescence(a, b, server: server, maxRounds: 20)
        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID, copyB.bookID].sorted(),
                    "\(client.name): both-edited ⇒ BOTH survive (the documented concurrent-divide class)")
            for text in ["In A's own words.", "In B's own words."] {
                #expect(try client.db.fetchInt(
                    "SELECT COUNT(*) FROM variant WHERE working_text = ? AND deleted_at IS NULL",
                    [text]) == 1,
                    "\(client.name): each side's edit lives on its own surviving copy")
            }
        }
    }

    /// **Row 15's NO-DEFENSE guard:** her deliberate delete of the sample
    /// library with NO second copy anywhere — the overwhelmingly normal
    /// state — is never defended: no meeting context, no kill recorded,
    /// the deletion stands (rule 1). The other device's unpushed edit
    /// still rides the row into the Trash (Part 1) — bytes never lost,
    /// copy never resurrected.
    @Test func aDeliberateDeleteWithNoSecondCopyIsNeverDefended() async throws {
        let (a, b, server) = try dedupePair()
        let copy = try seedCopy(a)
        try await productionQuiescence(a, b, server: server)

        let variant = try firstVariantID(b, postID: copy.postIDs["A Scandal in Bohemia"]!)
        try b.with { ops, _ in
            try ops.autosave(variant, text: "Kept in her drafts.", charDelta: 5)
        }
        try a.with { ops, _ in
            for postID in copy.postIDs.values.sorted() {
                try ops.deleteContainer(postID)
            }
            try ops.deleteReading(copy.bookID)
        }
        _ = try await productionRound(a)
        _ = try await productionRound(b)
        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            #expect(try liveCopyIDs(client).isEmpty,
                    "\(client.name): the deliberate delete stands — nothing revives")
        }
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [variant])
            == "Kept in her drafts.",
            "the unpushed edit rode the row into the Trash — Part 1's bytes, no resurrection")
    }

    /// **LADDER R1 F-R2: the meeting is BOUNDED — a deliberate delete
    /// AFTER the meeting settled is never defended.** The defense's
    /// meeting predicate counted DEAD readings, so the retired loser's
    /// tombstone kept the "meeting context" open for its whole tombstone
    /// lifetime (a month+): a deliberate cross-device `deleteReading` of
    /// the kept, ever-engaged copy arrived as the batch's only family
    /// death (the reading itself — the stamp check trivially matches),
    /// the kill-time classifier read any engagement ever as EDITED, and
    /// her deleted book reappeared on every device — resurrecting a
    /// deliberate delete, the class the row-17 ruling rejected Shape C
    /// over. The fixed meeting stands only while the other copy is LIVE,
    /// or its retirement is this device's own UNPUSHED act, or its
    /// tombstone sits within the settle window of the arriving kill —
    /// each arm strictly narrower than the old any-row-any-age predicate.
    @Test func aDeliberateDeleteAfterTheMeetingSettledIsNeverDefended() async throws {
        let (a, b, server) = try dedupePair()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        // The meeting resolves normally: both pristine, the smaller-id
        // keeper (copyA) survives, the loser retires, rounds settle.
        // (Quiescence alone goes quiet before any empty window fires the
        // armed markers — the p5c cadence — so the deciding rounds run
        // explicitly: A's empty pull decides, B applies.)
        try await productionQuiescence(a, b, server: server, maxRounds: 20)
        _ = try await productionRound(a)
        _ = try await productionRound(b)
        try await productionQuiescence(a, b, server: server, maxRounds: 16)
        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID],
                    "\(client.name): the meeting resolved to the keeper")
            #expect(try client.db.deletedAt("reading", copyB.bookID) != nil,
                    "\(client.name): the loser retired — its tombstone will outlive the meeting")
        }

        // She ENGAGES the kept copy (one manual savepoint — engagement the
        // classifier reads as EDITED forever after) and it settles.
        let saved = try firstVariantID(a, postID: copyA.postIDs["A Scandal in Bohemia"]!)
        try a.with { ops, _ in _ = try ops.commit(saved) }
        try await productionQuiescence(a, b, server: server)

        // A MONTH LATER she deliberately deletes the book — the shelf's
        // own door, the book alone (notes stand). The op runs under a
        // constant future clock so the kill stamp sits far outside any
        // honest settle window of the long-dead loser's retirement.
        let aMonthOn = Date(timeIntervalSince1970: 1_785_542_400)  // 2026-08-01T00:00:00Z
        try a.with { ops, _ in
            try withDependencies {
                $0.date = .constant(aMonthOn)
            } operation: {
                try ops.deleteReading(copyA.bookID)
            }
        }
        _ = try await productionRound(a)
        _ = try await productionRound(b)
        try await productionQuiescence(a, b, server: server, maxRounds: 16)
        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            #expect(try client.db.deletedAt("reading", copyA.bookID) != nil,
                    "\(client.name): her deliberate delete STANDS — the month-old loser tombstone is not a meeting")
            #expect(try liveCopyIDs(client).isEmpty, "\(client.name): nothing revives")
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
