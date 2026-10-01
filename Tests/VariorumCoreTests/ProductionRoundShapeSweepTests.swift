import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// RUN B batch B1 — **probe P4, the round-shape sweep** (ledger row 4): the
/// scenario table's ✔ rows (`notes/plans/pre-13u-memo-sync-disagreements.md`)
/// re-run under PRODUCTION'S round shape — pull → push per device, push
/// chunks as separate server transactions — plus a CHUNK SPLIT at a registry
/// boundary the scenario crosses, with the OTHER device's full round running
/// between the halves (the cross-chunk window the furniture ladder's F1/F2
/// findings came from). Any pin that holds only in the harness's convenience
/// order is a FINDING.
///
/// COVERAGE MAP (scenario × shape × boundary):
///  - edit-vs-edit (S5)            → production [200, 1] (probe P3) + the
///                                   `variant`-boundary split here (S1);
///  - delete-take-vs-edit          → production + `variant` split (S2);
///  - I10 double-tombstone         → production + `variant` split (S3);
///  - placement race (I2)          → production + `container_block` split (S4);
///  - rename/rename CAS            → production [200, 1] (S5; single-table
///                                   scenario — no cross-table boundary exists);
///  - concurrent divide            → production + `edge` split stranding the
///                                   edge AND placement chunks (S6);
///  - daily-Journal keeper         → production rounds at chunk-per-row (S7;
///                                   the tombstone/re-point CROSS-CHUNK orders
///                                   are already the furniture suite's F1 pins
///                                   — `theLosersTombstoneArrivingBeforeIts
///                                   RepointsMovesTheMembershipsToTheKeeper`,
///                                   `aFreshStoreMeetingTheLoserDead…` — not
///                                   duplicated);
///  - sample-library dedupe        → covered by the B1 probes P5(b)/P5(c)
///                                   (production shape) + the R2-1 reserved-tag
///                                   completeness pins for the post_tag chunk
///                                   split (SampleLibraryDedupeRepairTests) —
///                                   not duplicated.
///
/// OUT OF SWEEP REACH, with reasons (recorded in the batch record too):
///  - "a device restored from an OLD backup re-keys → the T1 recency warning"
///    — a custody/backup-matrix behavior (wave 2a's own pins), not a
///    two-client convergence scenario;
///  - "an account-owned device never synced cleanly → the seed gate declines"
///    — app-target seeder logic, outside the core harness.
@Suite("Production round-shape sweep (RUN B batch B1 — probe P4)")
struct ProductionRoundShapeSweepTests {
    /// A pair whose transports can be mid-drain-faulted independently.
    private func faultPair() throws -> (
        a: SyncClient, b: SyncClient, server: FakeSyncServer,
        aFault: FaultInjectingTransport, bFault: FaultInjectingTransport
    ) {
        let server = FakeSyncServer()
        let aFault = FaultInjectingTransport(server: server)
        let bFault = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: aFault)
        let b = try SyncClient(name: "B", prefix: "BB", transport: bFault, clockOffset: 977, seed: 2)
        return (a, b, server, aFault, bFault)
    }

    // MARK: - S1: edit-vs-edit, the variant chunk stranded

    @Test func s1EditVsEditWithTheVariantChunkStranded() async throws {
        let (a, b, server, aFault, _) = try faultPair()
        let (blockID, t1): (String, String) = try a.with { ops, _ in
            let note = try ops.createPost(title: "s1", profile: .journal)
            let made = try ops.newBlock(in: note.id, text: "the shared base", at: .end)
            return (made.block.id, made.variant.id)
        }
        try await productionQuiescence(a, b, server: server)

        try a.with { ops, _ in try ops.autosave(t1, text: "rewritten on A", charDelta: 5) }
        try b.with { ops, _ in try ops.autosave(t1, text: "rewritten on B", charDelta: 5) }

        // A's round: pull, then the push dies AT the variant boundary — the
        // container touch landed, the edit did not. B's full round runs in
        // the gap; A then resumes.
        _ = try await a.pull()
        try await pushSplitAtBoundary(a, table: "variant", transport: aFault)
        _ = try await productionRound(b)
        try await productionQuiescence(a, b, server: server)

        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            let texts = try await client.db.read { db in
                Set(try String.fetchAll(
                    db, sql: "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]))
            }
            #expect(texts == ["rewritten on A", "rewritten on B"],
                    "\(client.name): nothing lost under the split order")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL") == 1,
                "\(client.name): exactly one conflict card")
        }
    }

    // MARK: - S2: delete-take-vs-edit (block lives), the tombstone stranded

    @Test func s2DeleteTakeVsEditRescuesTheEditThenHonorsTheTombstone() async throws {
        let (a, b, server, aFault, _) = try faultPair()
        let (blockID, t1): (String, String) = try a.with { ops, db in
            let note = try ops.createPost(title: "s2", profile: .journal)
            let made = try ops.newBlock(in: note.id, text: "the shared base", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            // The slot renders the default so either variant is individually
            // deletable (the SyncRepairTests idiom — deleteVariant refuses a
            // chosen variant by design).
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET chosen_variant_id = NULL")
            }
            return (made.block.id, made.variant.id)
        }
        try await productionQuiescence(a, b, server: server)

        try a.with { ops, _ in try ops.deleteVariant(t1) }
        try b.with { ops, _ in try ops.autosave(t1, text: "edited on the phone", charDelta: 6) }

        // A's push dies at the variant boundary: the block's default
        // reassignment lands, T1's tombstone is stranded; B's round runs in
        // the gap (its edit reaches the server first).
        _ = try await a.pull()
        try await pushSplitAtBoundary(a, table: "variant", transport: aFault)
        _ = try await productionRound(b)
        try await productionQuiescence(a, b, server: server)

        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            #expect(try client.db.deletedAt("variant", t1) != nil,
                    "\(client.name): the tombstone is honored")
            let liveTexts = try await client.db.read { db in
                Set(try String.fetchAll(
                    db, sql: "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]))
            }
            #expect(liveTexts.contains("edited on the phone"),
                    "\(client.name): the edit was rescued before the tombstone applied")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL") == 1,
                "\(client.name): the rescue is exactly one conflict card")
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                """, [blockID])! >= 1, "\(client.name): I10 holds")
        }
    }

    // MARK: - S3: I10 double-tombstone, the tombstone chunk stranded

    @Test func s3DoubleTombstoneResurrectsTheSameRescueOnBothDevices() async throws {
        let (a, b, server, aFault, _) = try faultPair()
        let (blockID, t1, t2): (String, String, String) = try a.with { ops, db in
            let note = try ops.createPost(title: "s3", profile: .journal)
            let made = try ops.newBlock(in: note.id, text: "first take", at: .end)
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(second.id, text: "second take", charDelta: 4)
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET chosen_variant_id = NULL")
            }
            return (made.block.id, made.variant.id, second.id)
        }
        try await productionQuiescence(a, b, server: server)

        try a.with { ops, _ in try ops.deleteVariant(t1) }
        try b.with { ops, _ in try ops.deleteVariant(t2) }

        _ = try await a.pull()
        try await pushSplitAtBoundary(a, table: "variant", transport: aFault)
        _ = try await productionRound(b)
        try await productionQuiescence(a, b, server: server)

        #expect(try a.syncedDump() == b.syncedDump())
        let rescuedOnA = try a.db.fetchString(
            """
            SELECT id FROM variant
            WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
            """, [blockID])
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                """, [blockID]) == 1,
                "\(client.name): exactly one take survives the I10 race")
            #expect(try client.db.fetchString(
                """
                SELECT label FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                """, [blockID]) == "rescued", "\(client.name): the survivor is the rescue")
            #expect(try client.db.fetchString(
                """
                SELECT id FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                """, [blockID]) == rescuedOnA,
                "\(client.name): the SAME variant everywhere — deterministic on seq")
        }
    }

    // MARK: - S4: the I2 placement race, the placement chunk stranded

    @Test func s4PlacementRaceConvergesToTheHigherSeqUnderTheSplit() async throws {
        let (a, b, server, aFault, _) = try faultPair()
        try a.with { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            let b1 = try ops.newBlock(in: post.id, text: "one.", at: .end).block
            let b2 = try ops.newBlock(in: post.id, text: "two.", at: .end).block
            _ = try ops.merge(b1.id, b2.id)  // releases b1, b2: live, unplaced
        }
        try await productionQuiescence(a, b, server: server)
        let released = try a.db.fetchString(
            """
            SELECT b.id FROM block b WHERE b.deleted_at IS NULL AND NOT EXISTS
              (SELECT 1 FROM container_block cb WHERE cb.block_id = b.id AND cb.deleted_at IS NULL)
            ORDER BY b.id LIMIT 1
            """)!

        let placementA: String = try a.with { ops, _ in
            let home = try ops.createPost(title: "A's home", profile: nil)
            return try ops.placeBlock(released, in: home.id, at: .end).id
        }
        let placementB: String = try b.with { ops, _ in
            let home = try ops.createPost(title: "B's home", profile: nil)
            return try ops.placeBlock(released, in: home.id, at: .end).id
        }

        // A's push dies at the container_block boundary (its home post
        // lands, its placement is STRANDED — never server-accepted); B's
        // full round lands its placement. When B's row then arrives on A,
        // the I2 repair ranks A's never-accepted local row at seq 0
        // (SyncSpec §3 — "a never-accepted row carries no later-intent
        // authority"), so B'S placement wins everywhere and A's is
        // tombstoned BEFORE it ever lands. Observed under the sweep and
        // exactly the spec's sentence — the split changes which row wins
        // versus the both-pushed order, deterministically, not divergently.
        _ = try await a.pull()
        try await pushSplitAtBoundary(a, table: "container_block", transport: aFault)
        _ = try await productionRound(b)
        try await productionQuiescence(a, b, server: server)

        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            #expect(try client.db.deletedAt("container_block", placementA) != nil,
                    "\(client.name): the never-accepted placement ranks 0 and loses")
            #expect(try client.db.deletedAt("container_block", placementB) == nil,
                    "\(client.name): the server-accepted placement wins")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [released]) == 1, "\(client.name): I2 holds")
        }
    }

    // MARK: - S5: rename/rename CAS, production shape

    @Test(arguments: [200, 1])
    func s5RenameRenameIsServerVersionWins(batchSize: Int) async throws {
        let (a, b, server, _, _) = try faultPair()
        let postID: String = try a.with { ops, _ in
            try ops.createPost(title: "original", profile: nil).id
        }
        try await productionQuiescence(a, b, server: server, batchSize: batchSize)

        try a.with { ops, _ in try ops.renameContainer(postID, title: "A's title") }
        try b.with { ops, _ in try ops.renameContainer(postID, title: "B's title") }
        _ = try await productionRound(a, batchSize: batchSize)
        _ = try await productionRound(b, batchSize: batchSize)
        try await productionQuiescence(a, b, server: server, batchSize: batchSize)

        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try a.db.fetchString(
            "SELECT title FROM container WHERE id = ?", [postID]) == "A's title",
            "the first-landed rename wins CAS; one rename lost, never corruption")
    }

    // MARK: - S6: concurrent divide, the edge + placement chunks stranded

    @Test func s6ConcurrentDivideStillConvergesToTheDocumentedDuplication() async throws {
        let (a, b, server, aFault, _) = try faultPair()
        let (postID, blockID): (String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "essay", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "One. Two. Three.", at: .end)
            return (post.id, made.block.id)
        }
        try await productionQuiescence(a, b, server: server)

        try a.with { ops, _ in _ = try ops.divide(blockID, cut: 5) }   // "One." | "Two. Three."
        try b.with { ops, _ in _ = try ops.divide(blockID, cut: 10) }  // "One. Two." | "Three."

        // A's push dies at the edge boundary: its successor block + the
        // variants land; the lineage edge AND the placement are stranded.
        // B's full round runs against that partial picture (its own divide
        // dirty locally), then A resumes.
        _ = try await a.pull()
        try await pushSplitAtBoundary(a, table: "edge", transport: aFault)
        _ = try await productionRound(b)
        try await productionQuiescence(a, b, server: server)

        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL
                """, [postID]) == 3, "\(client.name): the documented duplication — 3 placements")
            let slotTexts = try await client.db.read { db in
                Set(try Queries.renderPost(db, containerID: postID).compactMap(\.text))
            }
            #expect(slotTexts == ["One.", "Two. Three.", "Three."],
                    "\(client.name): both second halves present — duplicated, never lost")
            let firstHalves = try await client.db.read { db in
                Set(try String.fetchAll(
                    db,
                    sql: "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]))
            }
            #expect(firstHalves == ["One.", "One. Two."],
                    "\(client.name): the first-half race resolved as S5 — both halves preserved")
        }
    }

    // MARK: - S7: the daily-Journal keeper at chunk-per-row

    @Test func s7JournalKeeperConvergesUnderProductionRoundsAtChunkPerRow() async throws {
        let (a, b, server, _, _) = try faultPair()
        let journalA: (bookID: String, entryID: String) = try a.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-08-30")
            guard case .shelved(let readingID) = ops.shelveInDailyJournalBook(entry.container.id)
            else { throw SweepError.journalDidNotShelve }
            return (readingID, entry.container.id)
        }
        let journalB: (bookID: String, entryID: String) = try b.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-08-31")
            guard case .shelved(let readingID) = ops.shelveInDailyJournalBook(entry.container.id)
            else { throw SweepError.journalDidNotShelve }
            return (readingID, entry.container.id)
        }

        // Production rounds with EVERY row its own chunk and pull windows
        // of one — the strongest uniform registry split.
        try await productionQuiescence(a, b, server: server, batchSize: 1, maxRounds: 16)

        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            let liveJournals = try await client.db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT id FROM reading
                        WHERE kind = 'book' AND profile = 'daily' AND deleted_at IS NULL
                        """)
            }
            #expect(liveJournals == [journalA.bookID],
                    "\(client.name): ONE Journal — the smaller-id keeper")
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL
                """, [journalA.bookID]) == 2,
                "\(client.name): both devices' entries live in the keeper")
            #expect(try client.db.fetchString(
                "SELECT value FROM setting WHERE key = 'daily_journal_book'") == journalA.bookID,
                "\(client.name): the designation converged to the keeper")
        }
        _ = journalB
    }

    private enum SweepError: Error {
        case journalDidNotShelve
    }
}
