import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// SyncSpec §6 rule by rule, plus AppSpec §9's `resolveSyncConflict`. The
/// merge is exercised directly (the unit under test); the same paths run
/// end-to-end in the push/pull and convergence suites.
@Suite("Merge matrix & resolveSyncConflict (Phase 5, Step 5)")
struct SyncMergeTests {
    // MARK: - Fixtures

    /// A post with one block and two variants (v1 default+chosen, v2
    /// branched from v1), outbox cleared so each test stages exactly the
    /// dirt it means to.
    private func world(
        _ body: (Operations, AppDatabase, _ blockID: String, _ v1: String, _ v2: String) throws -> Void
    ) throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "original text", at: .end)
            let v2 = try ops.branchVariant(made.block.id, from: made.variant.id)
            try db.clearOutbox()
            try body(ops, db, made.block.id, made.variant.id, v2.id)
        }
    }

    private func engine() -> SyncEngine {
        SyncEngine(transport: FakeSyncServer())
    }

    private func fetchRow(_ db: AppDatabase, _ tableName: String, _ id: String) throws -> SyncRow {
        try db.read { try SyncRow.fetch($0, table: SyncSchema.table(named: tableName)!, rowID: id)! }
    }

    private func merge(
        _ db: AppDatabase, local: SyncRow, server: SyncRow, serverSeq: Int64 = 7
    ) throws {
        let engine = engine()
        try engine.applyingRemoteWithDeferredFKs { txn in
            var touched = TouchedRows()
            try engine.merge(txn, local: local, server: server, serverSeq: serverSeq, touched: &touched)
        }
    }

    // MARK: - Metadata / positions / counters: server-version-wins

    @Test func metadataRaceServerVersionWins() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "local title", profile: nil)
            try db.clearOutbox()
            try ops.renameContainer(post.id, title: "local intent")

            var server = try fetchRow(db, "container", post.id)
            server.columns["title"] = .text("server intent")
            server.syncVersion = 3
            let local = try fetchRow(db, "container", post.id)
            try merge(db, local: local, server: server)

            #expect(try db.fetchString("SELECT title FROM container WHERE id = ?", [post.id])
                    == "server intent")
            #expect(try db.fetchInt("SELECT sync_version FROM container WHERE id = ?", [post.id]) == 3)
            // Accepted wholesale: nothing of local intent left to push.
            #expect(try db.outboxContains("container", post.id) == false)
            // The seq bookkeeping recorded the server's ordering stamp.
            #expect(try db.fetchInt(
                "SELECT server_seq FROM sync_row_seq WHERE table_name = 'container' AND row_id = ?",
                [post.id]) == 7)
        }
    }

    @Test func positionRaceIsServerWinsCAS() throws {
        try world { ops, db, blockID, _, _ in
            try ops.reorder(blockID, to: .start)
            let placementID = try db.fetchString(
                "SELECT id FROM container_block WHERE block_id = ?", [blockID])!
            var server = try fetchRow(db, "container_block", placementID)
            server.columns["position"] = .text("zzz")
            server.syncVersion = 2
            let local = try fetchRow(db, "container_block", placementID)
            try merge(db, local: local, server: server)

            #expect(try db.fetchString(
                "SELECT position FROM container_block WHERE id = ?", [placementID]) == "zzz")
            #expect(try db.outboxContains("container_block", placementID) == false)
        }
    }

    @Test func countersServerWin() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: nil)
            try db.clearOutbox()
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container SET churn_accumulator = 41, baseline_length = 10 WHERE id = ?",
                    arguments: [post.id])
            }
            var server = try fetchRow(db, "container", post.id)
            server.columns["churn_accumulator"] = .real(3.5)
            server.columns["baseline_length"] = .integer(99)
            server.syncVersion = 2
            let local = try fetchRow(db, "container", post.id)
            try merge(db, local: local, server: server)

            #expect(try db.fetchInt("SELECT baseline_length FROM container WHERE id = ?", [post.id]) == 99)
            #expect(try db.fetchString(
                "SELECT CAST(churn_accumulator AS TEXT) FROM container WHERE id = ?", [post.id]) == "3.5")
        }
    }

    @Test func settingRaceServerWins() throws {
        try withOperations { _, db in
            try db.clearOutbox()
            try db.write { db in
                try db.execute(
                    sql: "UPDATE setting SET value = 'sentence' WHERE key = 'default_segmentation'")
            }
            var server = try fetchRow(db, "setting", "default_segmentation")
            server.columns["value"] = .text("one_block")
            server.syncVersion = 4
            let local = try fetchRow(db, "setting", "default_segmentation")
            try merge(db, local: local, server: server)

            #expect(try db.fetchString(
                "SELECT value FROM setting WHERE key = 'default_segmentation'") == "one_block")
            #expect(try db.outboxContains("setting", "default_segmentation") == false)
        }
    }

    // MARK: - Tombstone wins over edits

    @Test func localTombstoneOverlaysServerEditAndStaysEnqueued() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: nil)
            try db.clearOutbox()
            try ops.deleteContainer(post.id)
            let localStamp = try db.fetchString(
                "SELECT deleted_at FROM container WHERE id = ?", [post.id])!

            var server = try fetchRow(db, "container", post.id)
            server.columns["title"] = .text("edited on the other device")
            server.columns["deleted_at"] = .null
            server.syncVersion = 2
            let local = try fetchRow(db, "container", post.id)
            try merge(db, local: local, server: server)

            // Server metadata adopted, local tombstone re-applied on top.
            #expect(try db.fetchString("SELECT title FROM container WHERE id = ?", [post.id])
                    == "edited on the other device")
            #expect(try db.fetchString("SELECT deleted_at FROM container WHERE id = ?", [post.id])
                    == localStamp)
            // Local intent survived: the row stays enqueued and pushes.
            #expect(try db.outboxContains("container", post.id))
        }
    }

    // MARK: - The one mutable text (S5)

    @Test func workingTextRaceBecomesConflictVariant() throws {
        try world { ops, db, blockID, v1, v2 in
            try ops.autosave(v2, text: "my local take", charDelta: 5)

            var server = try fetchRow(db, "variant", v2)
            server.columns["working_text"] = .text("the server's take")
            server.syncVersion = 2
            let local = try fetchRow(db, "variant", v2)
            try merge(db, local: local, server: server)

            // Server text won the row.
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [v2])
                    == "the server's take")
            #expect(try db.outboxContains("variant", v2) == false)

            // The losing local text became a card in the fan: same block,
            // branched from the SAME parent as the conflicted variant (v1),
            // label 'conflict', at the fan's end. Nothing clobbered.
            let conflict = try db.read { db in
                try Row.fetchOne(
                    db,
                    sql: "SELECT * FROM variant WHERE label = 'conflict'")
            }
            #expect(conflict != nil)
            #expect(conflict?["block_id"] == blockID)
            #expect(conflict?["parent_variant_id"] == v1)
            #expect(conflict?["working_text"] == "my local take")
            #expect(conflict?["status"] == "active")
            let fanEnd = try db.fetchString(
                "SELECT id FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position DESC LIMIT 1",
                [blockID])
            #expect(fanEnd == (conflict?["id"] as String?))
            // Born inside apply mode ⇒ enqueued explicitly, or it never syncs.
            #expect(try db.outboxContains("variant", conflict?["id"] as String? ?? ""))
        }
    }

    @Test func metadataOnlyVariantDirtSpawnsNoConflict() throws {
        try world { _, db, _, _, v2 in
            try db.write { db in
                try db.execute(
                    sql: "UPDATE variant SET label = 'local label' WHERE id = ?", arguments: [v2])
            }
            var server = try fetchRow(db, "variant", v2)
            server.columns["label"] = .text("server label")
            server.syncVersion = 2
            let local = try fetchRow(db, "variant", v2)
            try merge(db, local: local, server: server)

            #expect(try db.fetchString("SELECT label FROM variant WHERE id = ?", [v2]) == "server label")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM variant WHERE label = 'conflict'") == 0)
        }
    }

    @Test func serverTombstoneRescuesLocalEditThenHonorsTombstone() throws {
        try world { ops, db, blockID, _, v2 in
            try ops.autosave(v2, text: "edited after the other device deleted it", charDelta: 10)

            var server = try fetchRow(db, "variant", v2)
            // The other device tombstoned the variant BEFORE seeing this
            // edit: its row still carries the pre-edit text.
            server.columns["working_text"] = .text("original text")
            server.columns["deleted_at"] = .text("2026-07-06T09:00:00.000Z")
            server.syncVersion = 2
            let local = try fetchRow(db, "variant", v2)
            try merge(db, local: local, server: server)

            // Tombstone honored…
            #expect(try db.fetchString("SELECT deleted_at FROM variant WHERE id = ?", [v2])
                    == "2026-07-06T09:00:00.000Z")
            // …but the racing edit was rescued first (block still live).
            let rescued = try db.fetchString(
                "SELECT working_text FROM variant WHERE label = 'conflict' AND block_id = ?", [blockID])
            #expect(rescued == "edited after the other device deleted it")
        }
    }

    @Test func localTombstoneRescuesServerEditBeforeOverlay() throws {
        try world { ops, db, blockID, _, v2 in
            try ops.deleteVariant(v2)
            let localStamp = try db.fetchString(
                "SELECT deleted_at FROM variant WHERE id = ?", [v2])!

            var server = try fetchRow(db, "variant", v2)
            server.columns["deleted_at"] = .null
            server.columns["working_text"] = .text("the other device kept writing")
            server.syncVersion = 2
            let local = try fetchRow(db, "variant", v2)
            try merge(db, local: local, server: server)

            // The tombstone overlay wins the row…
            #expect(try db.fetchString("SELECT deleted_at FROM variant WHERE id = ?", [v2]) == localStamp)
            #expect(try db.outboxContains("variant", v2), "overlay must re-push")
            // …and the server-side edit is rescued, not clobbered.
            let rescued = try db.fetchString(
                "SELECT working_text FROM variant WHERE label = 'conflict' AND block_id = ?", [blockID])
            #expect(rescued == "the other device kept writing")
        }
    }

    @Test func rescueSkippedWhenTheWholeBlockDied() throws {
        try world { ops, db, blockID, _, v2 in
            try ops.autosave(v2, text: "doomed edit", charDelta: 3)
            try db.write { db in
                // Block dead, edited variant still live — a mid-apply
                // sync-order state (the cascade is undone by hand so the
                // rescue's own block-liveness guard is what's under test,
                // not the both-tombstoned early return).
                try db.execute(
                    sql: "UPDATE block SET deleted_at = '2026-07-06T09:00:00.000Z' WHERE id = ?",
                    arguments: [blockID])
                try db.execute(
                    sql: "UPDATE variant SET deleted_at = NULL WHERE id = ?", arguments: [v2])
            }
            var server = try fetchRow(db, "variant", v2)
            server.columns["working_text"] = .text("original text")
            server.columns["deleted_at"] = .text("2026-07-06T09:00:00.000Z")
            server.syncVersion = 2
            let local = try fetchRow(db, "variant", v2)
            try merge(db, local: local, server: server)

            #expect(try db.fetchInt("SELECT COUNT(*) FROM variant WHERE label = 'conflict'") == 0,
                    "a dead block's fan is unreachable — no rescue lands there")
        }
    }

    @Test func bothSidesTombstonedRescuesNothing() throws {
        try world { ops, db, _, _, v2 in
            try ops.autosave(v2, text: "edit then delete", charDelta: 3)
            try ops.deleteVariant(v2)
            var server = try fetchRow(db, "variant", v2)
            server.columns["working_text"] = .text("original text")
            server.columns["deleted_at"] = .text("2026-07-06T09:00:00.000Z")
            server.syncVersion = 2
            let local = try fetchRow(db, "variant", v2)
            try merge(db, local: local, server: server)

            #expect(try db.fetchInt("SELECT COUNT(*) FROM variant WHERE label = 'conflict'") == 0)
            #expect(try db.fetchString("SELECT deleted_at FROM variant WHERE id = ?", [v2])
                    == "2026-07-06T09:00:00.000Z", "server tombstone stands; no overlay needed")
        }
    }

    // MARK: - resolveSyncConflict (the public operation, AppSpec §9)

    @Test func resolveSyncConflictAppendsConflictCard() throws {
        try world { ops, db, blockID, v1, v2 in
            let conflict = try ops.resolveSyncConflict(v2, losingText: "the losing take")
            #expect(conflict.blockId == blockID)
            #expect(conflict.parentVariantId == v1, "branched from the SAME parent as the conflicted variant")
            #expect(conflict.label == "conflict")
            #expect(conflict.workingText == "the losing take")
            #expect(conflict.status == .active)
            // The conflicted variant itself is untouched.
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [v2])
                    == "original text")
            // Ordinary operation ⇒ ordinary trigger-captured outbox row.
            #expect(try db.outboxContains("variant", conflict.id))
        }
    }

    @Test func resolveSyncConflictLandsEvenUnderASealedPost() throws {
        // PROVISIONAL (logged in QUESTIONS): S5's nothing-clobbered outranks
        // the seal — refusing would throw the losing text away.
        try world { ops, db, _, _, v2 in
            let postID = try db.fetchString("SELECT id FROM container")!
            try ops.lockPost(postID)
            let conflict = try ops.resolveSyncConflict(v2, losingText: "conflict under seal")
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [conflict.id])
                    == "conflict under seal")
        }
    }

    @Test func resolveSyncConflictRefusesADeadBlock() throws {
        // Aligned with the engine's rescue guard (Phase 5 review): a dead
        // block's fan takes no new cards; the public op refuses loudly.
        try world { ops, db, blockID, _, v2 in
            try db.write { db in
                try db.execute(
                    sql: "UPDATE block SET deleted_at = '2026-07-06T09:00:00.000Z' WHERE id = ?",
                    arguments: [blockID])
                try db.execute(
                    sql: "UPDATE variant SET deleted_at = NULL WHERE id = ?", arguments: [v2])
            }
            #expect(throws: OperationError.blockNotFound(id: blockID)) {
                try ops.resolveSyncConflict(v2, losingText: "x")
            }
        }
    }

    @Test func resolveSyncConflictRefusesAMissingVariant() throws {
        try world { ops, _, _, _, _ in
            #expect(throws: OperationError.variantNotFound(id: "ghost")) {
                try ops.resolveSyncConflict("ghost", losingText: "x")
            }
        }
    }
}
