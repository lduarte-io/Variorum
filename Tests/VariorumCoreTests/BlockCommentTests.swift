import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Step A1 — migration v1_8 `block_comment`: working notes on a
/// block (author-decided 2026-07-17; AppSpec §14 items 6/9). Multiple per
/// block, NO uniqueness, tombstoned, resurrectable — never skimpy.
@Suite("Block comments (Phase 13, A1 — v1_8)")
struct BlockCommentTests {
    // MARK: - Schema shape

    @Test func tableShapeMatchesTheEventsLetter() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(block_comment)")
                .map { $0["name"] as String }
            #expect(Set(columns) == [
                "id", "owner_id", "block_id", "text",
                "created_at", "updated_at", "deleted_at", "sync_version",
            ])
            // Deliberately NO unique index — comments have no natural key
            // (the plan's letter), so no SyncSpec §7 repair class exists.
            let uniques = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master
                WHERE type = 'index' AND tbl_name = 'block_comment'
                  AND sql LIKE 'CREATE UNIQUE INDEX%'
                """)
            #expect(uniques.isEmpty)
            let indexes = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master
                WHERE type = 'index' AND tbl_name = 'block_comment' AND name NOT LIKE 'sqlite_%'
                """)
            #expect(indexes == ["idx_block_comment_block"])
        }
    }

    // MARK: - CRUD transitions

    @Test func addEditListOrderAndOwnerStamp() throws {
        try withDependencies {
            $0.ownerIdentity = OwnerIdentity { "owner-13" }
        } operation: {
            try withOperations { ops, db in
                let post = try ops.createPost(title: "p", profile: .generic)
                let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block

                let first = try ops.addBlockComment(to: block.id, text: "take 1 preferred")
                let second = try ops.addBlockComment(to: block.id, text: "but take 2's ending")
                #expect(first.ownerId == "owner-13")

                var listed = try db.read { try Queries.blockComments($0, blockID: block.id) }
                #expect(listed.map(\.text) == ["take 1 preferred", "but take 2's ending"])

                try ops.editBlockComment(second.id, text: "but take 2's CONCLUSION")
                listed = try db.read { try Queries.blockComments($0, blockID: block.id) }
                #expect(listed.map(\.text) == ["take 1 preferred", "but take 2's CONCLUSION"])
                #expect(listed[1].updatedAt > second.updatedAt)

                // Metadata, not authoring: neither add nor edit stamps the
                // container's touch clock or feeds churn.
                let touched = try db.fetchString(
                    "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
                let afterMint = try db.fetchString(
                    "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
                #expect(touched == afterMint)
            }
        }
    }

    @Test func whitespaceOnlyTextRefuses() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            #expect(throws: OperationError.invalidCommentText) {
                try ops.addBlockComment(to: block.id, text: "  \n ")
            }
            let comment = try ops.addBlockComment(to: block.id, text: "real note")
            #expect(throws: OperationError.invalidCommentText) {
                try ops.editBlockComment(comment.id, text: "\t")
            }
        }
    }

    @Test func deleteIsATombstoneAndTheRecoverySurfaceSeesIt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            let keep = try ops.addBlockComment(to: block.id, text: "keep me")
            let drop = try ops.addBlockComment(to: block.id, text: "drop me")

            try ops.deleteBlockComment(drop.id)
            #expect(try db.deletedAt("block_comment", drop.id) != nil)

            let live = try db.read { try Queries.blockComments($0, blockID: block.id) }
            #expect(live.map(\.id) == [keep.id])
            let deleted = try db.read { try Queries.deletedBlockComments($0, blockID: block.id) }
            #expect(deleted.map(\.id) == [drop.id], "the deleted note stays visible — never skimpy")
        }
    }

    @Test func restoreResurrectsAnIndividuallyDeletedComment() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            let comment = try ops.addBlockComment(to: block.id, text: "oops")
            try ops.deleteBlockComment(comment.id)

            try ops.restoreBlockComment(comment.id)
            #expect(try db.deletedAt("block_comment", comment.id) == nil)
            let live = try db.read { try Queries.blockComments($0, blockID: block.id) }
            #expect(live.map(\.id) == [comment.id])

            // Restoring a live comment refuses (typed, never silent).
            #expect(throws: OperationError.commentNotDeleted(id: comment.id)) {
                try ops.restoreBlockComment(comment.id)
            }
        }
    }

    // MARK: - Seal posture (PROVISIONAL — the everything-under-the-post letter)

    @Test func aSealedPostRefusesEveryCommentWrite() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            let comment = try ops.addBlockComment(to: block.id, text: "pre-seal note")
            let doomed = try ops.addBlockComment(to: block.id, text: "to delete, then seal")
            try ops.deleteBlockComment(doomed.id)
            try ops.lockPost(post.id)

            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.addBlockComment(to: block.id, text: "new note")
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.editBlockComment(comment.id, text: "rewrite")
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.deleteBlockComment(comment.id)
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.restoreBlockComment(doomed.id)
            }
            // Reading is not authoring: both surfaces still list.
            let live = try db.read { try Queries.blockComments($0, blockID: block.id) }
            #expect(live.count == 1)
            let deleted = try db.read { try Queries.deletedBlockComments($0, blockID: block.id) }
            #expect(deleted.count == 1)
        }
    }

    // MARK: - Cascade + restore (the exact-stamp contract)

    @Test func blockTombstoneCascadesWithTheExactStampAndRestoreBlockRevives() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            _ = try ops.newBlock(in: post.id, text: "Sibling.", at: .end)
            let cascade = try ops.addBlockComment(to: block.id, text: "dies with the block")
            let independent = try ops.addBlockComment(to: block.id, text: "died earlier, stays dead")
            try ops.deleteBlockComment(independent.id)
            let independentStamp = try db.deletedAt("block_comment", independent.id)

            try ops.deleteBlock(block.id)
            let blockStamp = try db.deletedAt("block", block.id)
            #expect(try db.deletedAt("block_comment", cascade.id) == blockStamp,
                    "the cascade stamps the comment with the block's exact deleted_at")
            #expect(try db.deletedAt("block_comment", independent.id) == independentStamp,
                    "an independently-deleted comment keeps its own stamp")

            try ops.restoreBlock(block.id)
            #expect(try db.deletedAt("block_comment", cascade.id) == nil,
                    "the cascade victim revives with its block")
            #expect(try db.deletedAt("block_comment", independent.id) != nil,
                    "the independently-deleted comment stays dead (its door is restoreBlockComment)")
        }
    }

    @Test func containerDeleteChainsToCommentsAndRestoreContainerRevives() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            let comment = try ops.addBlockComment(to: block.id, text: "note")

            try ops.deleteContainer(post.id)
            let stamp = try db.deletedAt("container", post.id)
            #expect(try db.deletedAt("block_comment", comment.id) == stamp,
                    "container → block → comment chain carries ONE stamp")

            try ops.restoreContainer(post.id)
            #expect(try db.deletedAt("block_comment", comment.id) == nil)
            let live = try db.read { try Queries.blockComments($0, blockID: block.id) }
            #expect(live.map(\.id) == [comment.id])
        }
    }

    @Test func restoreOfACommentUnderADeadBlockRefuses() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            _ = try ops.newBlock(in: post.id, text: "Sibling.", at: .end)
            let comment = try ops.addBlockComment(to: block.id, text: "note")
            try ops.deleteBlockComment(comment.id)
            try ops.deleteBlock(block.id)

            #expect(throws: OperationError.blockNotFound(id: block.id)) {
                try ops.restoreBlockComment(comment.id)
            }
            _ = db  // silence unused warning
        }
    }

    // MARK: - Outbox capture (SyncSpec §3)

    @Test func commentWritesReachTheOutboxAndApplyModeSuppresses() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            try db.clearOutbox()

            let comment = try ops.addBlockComment(to: block.id, text: "note")
            #expect(try db.outboxContains("block_comment", comment.id))
            try db.clearOutbox()

            try ops.deleteBlockComment(comment.id)
            #expect(try db.outboxContains("block_comment", comment.id))
            try db.clearOutbox()

            // Apply mode: a remote write must NOT re-enqueue (echo
            // suppression) — the standing trigger contract.
            try db.applyingRemote { db in
                try db.execute(
                    sql: "UPDATE block_comment SET text = 'remote edit' WHERE id = ?",
                    arguments: [comment.id])
            }
            #expect(try !db.outboxContains("block_comment", comment.id))
        }
    }

    // MARK: - Backfill (Phase 9c's introspected adoption)

    @Test func adoptOwnerIDClaimsUnownedComments() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            let comment = try ops.addBlockComment(to: block.id, text: "unowned note")
            #expect(comment.ownerId == nil)

            try withDependencies {
                $0.ownerIdentity = OwnerIdentity { "owner-13" }
            } operation: {
                let report = try Operations().adoptOwnerID()
                #expect(report.adoptedByTable["block_comment"] == 1,
                        "the introspected backfill sees the new owner-carrying table")
            }
            #expect(try db.fetchString(
                "SELECT owner_id FROM block_comment WHERE id = ?", [comment.id]) == "owner-13")
        }
    }
}
