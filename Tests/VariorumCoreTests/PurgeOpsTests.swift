import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13j batch 6b — the purge-intent OPERATION (`requestPurge`, the
/// doors' one write), its refusal set, the read-side INTENT FENCE ("rows
/// leave every surface immediately" — the doors' promise), and the pruning
/// brain. The janitor's end-to-end behavior lives in
/// `PurgeConvergenceTests` (any sync change not covered by a convergence
/// test is unreviewed — AppSpec §15.3).
@Suite("Purge intents: the op, the fences, the pruning brain (13j 6b)")
struct PurgeOpsTests {
    // MARK: - requestPurge state transitions

    @Test func requestPurgeWritesOneIntentRowAndTheOutboxCapturesIt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            try ops.deleteBlock(made.block.id)

            let minted = try ops.requestPurge(
                [SyncPurgeTarget(table: "block", rowID: made.block.id)])
            #expect(minted == 1)

            let row = try db.read { db in
                try Row.fetchOne(
                    db, sql: "SELECT * FROM purge_intent WHERE table_name = 'block' AND row_id = ?",
                    arguments: [made.block.id])
            }
            #expect(row != nil)
            #expect((row?["deleted_at"] as String?) == nil)
            #expect((row?["requested_at"] as String?) != nil)
            // The outbox trigger captured the mint — the intent TRAVELS.
            let intentID: String = row!["id"]
            #expect(try db.outboxContains("purge_intent", intentID))
        }
    }

    @Test func askingTwiceIsOneIntent() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            try ops.deleteBlock(made.block.id)
            let target = SyncPurgeTarget(table: "block", rowID: made.block.id)

            #expect(try ops.requestPurge([target]) == 1)
            #expect(try ops.requestPurge([target]) == 0)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM purge_intent WHERE row_id = ?", [made.block.id]) == 1)
        }
    }

    @Test func aLiveRowRefusesOnlyTrashThingsPurge() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            #expect {
                try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: made.block.id)])
            } throws: { error in
                error as? OperationError
                    == .purgeTargetNotDeleted(table: "block", id: made.block.id)
            }
            #expect {
                try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: post.id)])
            } throws: { error in
                error as? OperationError
                    == .purgeTargetNotDeleted(table: "container", id: post.id)
            }
        }
    }

    @Test func aDeliberateSavepointNeverPrunesTheOpRefusesIt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            let manual = try ops.commit(made.variant.id, message: "hers")
            #expect {
                try ops.requestPurge([SyncPurgeTarget(table: "commit_point", rowID: manual.id)])
            } throws: { error in
                error as? OperationError == .deliberateSavepointNeverPruned(id: manual.id)
            }
            // A QUIET savepoint is a legal target.
            try db.write { db in
                try db.execute(
                    sql: "UPDATE commit_point SET kind = 'auto' WHERE id = ?",
                    arguments: [manual.id])
            }
            #expect(try ops.requestPurge(
                [SyncPurgeTarget(table: "commit_point", rowID: manual.id)]) == 1)
        }
    }

    @Test func unknownTablesAndMissingRowsRefuseByName() throws {
        try withOperations { ops, db in
            #expect {
                try ops.requestPurge([SyncPurgeTarget(table: "tag", rowID: "x")])
            } throws: { error in
                error as? OperationError == .unsupportedPurgeTarget(table: "tag")
            }
            #expect {
                try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: "ghost")])
            } throws: { error in
                error as? OperationError == .blockNotFound(id: "ghost")
            }
            // A missing row with a standing intent is ALREADY going —
            // idempotent skip, never a throw (the resumed-janitor shape).
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            try ops.deleteBlock(made.block.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: made.block.id)])
            try db.write { db in
                // Simulate the janitor having taken the row (and completed
                // the intent) — the second ask must not resurrect anything.
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                let family = try PurgeFamily.expand(
                    db, roots: [SyncPurgeTarget(table: "block", rowID: made.block.id)])
                try PurgeFamily.deleteLocal(
                    db, family: family, stamp: "2026-08-19T00:00:00.000Z")
            }
            #expect(try ops.requestPurge(
                [SyncPurgeTarget(table: "block", rowID: made.block.id)]) == 0)
        }
    }

    // MARK: - The intent FENCE: rows leave every surface immediately

    @Test func anIntentNamedRowLeavesEverySurfaceImmediately() throws {
        try withOperations { ops, db in
            // A note with a deleted block and a deleted take; a deleted
            // book; a deleted second note.
            let post = try ops.createPost(title: "kept note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "First block.", at: .end)
            let second = try ops.newBlock(in: post.id, text: "Second block.", at: .end)
            let spare = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(spare.id)
            try ops.deleteBlock(second.block.id)
            let doomedPost = try ops.createPost(title: "doomed note", profile: .generic)
            _ = try ops.newBlock(in: doomedPost.id, text: "going", at: .end)
            try ops.deleteContainer(doomedPost.id)
            let book = try ops.createReading(name: "doomed book", kind: .curated, maxPosts: nil)
            try ops.deleteReading(book.id)

            let now = harnessNow
            func counts() throws -> (trash: Int, posts: Int, books: Int, tray: Int,
                                     trayCount: Int, takes: Int) {
                try db.read { db in
                    (try Queries.trash(db, now: now).count,
                     try Queries.deletedPosts(db, now: now).count,
                     try Queries.deletedReadings(db, now: now).count,
                     try Queries.trayBlocks(db, postID: post.id, now: now).count,
                     try Queries.trayCounts(db, postID: post.id, now: now).deleted,
                     try Queries.deletedTakes(db, blockID: made.block.id, now: now).count)
                }
            }
            let before = try counts()
            // note + book + block + the take (deleted from a LIVE block,
            // so it is its own Trash row beside its History-face row).
            #expect(before.trash == 4)
            #expect(before.posts == 1)
            #expect(before.books == 1)
            #expect(before.tray == 1)
            #expect(before.trayCount == 1)
            #expect(before.takes == 1)

            _ = try ops.requestPurge([
                SyncPurgeTarget(table: "container", rowID: doomedPost.id),
                SyncPurgeTarget(table: "reading", rowID: book.id),
                SyncPurgeTarget(table: "block", rowID: second.block.id),
                SyncPurgeTarget(table: "variant", rowID: spare.id),
            ])

            let after = try counts()
            #expect(after.trash == 0, "every intent-named row must leave the Trash at once")
            #expect(after.posts == 0)
            #expect(after.books == 0)
            #expect(after.tray == 0)
            #expect(after.trayCount == 0)
            #expect(after.takes == 0)
        }
    }

    // MARK: - The pruning brain (her round-9 numbers)

    @Test func thePruningBrainKeepsTheNewestTenQuietAndEveryDeliberateOne() {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        func savepoint(_ index: Int, kind: String, ageDays: Double) -> SavepointPruning.Savepoint {
            SavepointPruning.Savepoint(
                id: String(format: "%03d", index), kind: kind,
                createdAt: now.addingTimeInterval(-ageDays * 86_400))
        }
        // 14 quiet old rows + 3 quiet young + 4 manual ancient.
        var rows: [SavepointPruning.Savepoint] = []
        for index in 0..<14 { rows.append(savepoint(index, kind: "auto", ageDays: 100 + Double(index))) }
        for index in 14..<17 { rows.append(savepoint(index, kind: "auto", ageDays: 5)) }
        for index in 17..<21 { rows.append(savepoint(index, kind: "manual", ageDays: 400)) }

        let prunable = Set(SavepointPruning.prunable(among: rows, now: now))
        // Newest 10 QUIET survive (the 3 young + the 7 youngest old);
        // manuals never appear; the 7 oldest quiet prune.
        #expect(prunable.count == 7)
        #expect(prunable.isDisjoint(with: ["014", "015", "016"]),
                "the young quiet savepoints survive")
        #expect(prunable.isDisjoint(with: ["017", "018", "019", "020"]),
                "deliberate savepoints NEVER prune")
        // The oldest quiet rows are exactly the pruned ones (007…013 are
        // the 100+7…100+13-day rows — older than the kept seven).
        #expect(prunable == Set(["007", "008", "009", "010", "011", "012", "013"]))

        // Under the age bar nothing prunes even beyond ten.
        var young: [SavepointPruning.Savepoint] = []
        for index in 0..<20 { young.append(savepoint(index, kind: "auto", ageDays: 30)) }
        #expect(SavepointPruning.prunable(among: young, now: now).isEmpty)
    }

    // MARK: - The family expansion's zero-orphan claim, DB-verified

    @Test func aFamilyRemovalLeavesZeroOrphansTheForeignKeysProveIt() throws {
        try withOperations { ops, db in
            // A rich note: two blocks (one fanned + committed + commented +
            // tagged), a book membership, a reference, a lens with a pick,
            // a canvas position — then the whole note deleted.
            let post = try ops.createPost(title: "rich", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "First.", at: .end)
            let second = try ops.newBlock(in: post.id, text: "Second.", at: .end)
            let alt = try ops.branchVariant(made.block.id, from: made.variant.id)
            _ = try ops.commit(made.variant.id, message: "kept")
            _ = try ops.addBlockComment(to: made.block.id, text: "margin note")
            let tag = try ops.createTag(parent: nil, name: "life")
            _ = try ops.applyTag(tag.id, toPost: post.id)
            _ = try ops.applyTag(tag.id, toBlock: made.block.id)
            let book = try ops.createReading(name: "book", kind: .curated, maxPosts: nil)
            _ = try ops.addPostToReading(post.id, to: book.id)
            _ = try ops.addReference(to: post.id, kind: .url, url: "https://example.org")
            let lens = try ops.createLens(post: post.id, name: "cut")
            _ = try ops.setLensChoice(lens: lens.id, block: made.block.id, variant: alt.id)
            _ = try ops.setCanvasPosition(container: post.id, block: second.block.id, x: 1, y: 2)
            try ops.deleteContainer(post.id)

            let familyRows: Int = try db.write { db in
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                let family = try PurgeFamily.expand(
                    db, roots: [SyncPurgeTarget(table: "container", rowID: post.id)])
                try PurgeFamily.deleteLocal(
                    db, family: family, stamp: "2026-08-19T00:00:00.000Z")
                return family.rows.count
            }
            #expect(familyRows > 10, "the family must take the whole household")

            // Zero orphans, checked two ways: the write above COMMITTED
            // under PRAGMA foreign_keys=ON (a missed child would have
            // failed the commit), and nothing referencing the note's ids
            // survives anywhere.
            try db.read { db in
                #expect(try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM container WHERE id = ?",
                    arguments: [post.id]) == 0)
                for table in ["container_block", "reference", "post_tag", "reading_post",
                              "canvas_layout", "lens"] {
                    let count = try Int.fetchOne(
                        db,
                        sql: "SELECT COUNT(*) FROM \(table) WHERE \(table == "reading_post" || table == "post_tag" ? "post_id" : "container_id") = ?",
                        arguments: [post.id]) ?? 0
                    #expect(count == 0, "\(table) still references the purged note")
                }
                for blockID in [made.block.id, second.block.id] {
                    for (table, column) in [("variant", "block_id"), ("block_tag", "block_id"),
                                            ("block_comment", "block_id"),
                                            ("container_block", "block_id"),
                                            ("canvas_layout", "block_id"),
                                            ("lens_choice", "block_id")] {
                        let count = try Int.fetchOne(
                            db, sql: "SELECT COUNT(*) FROM \(table) WHERE \(column) = ?",
                            arguments: [blockID]) ?? 0
                        #expect(count == 0, "\(table) still references purged block \(blockID)")
                    }
                    let edges = try Int.fetchOne(
                        db,
                        sql: "SELECT COUNT(*) FROM edge WHERE source_block_id = ? OR target_block_id = ?",
                        arguments: [blockID, blockID]) ?? 0
                    #expect(edges == 0)
                }
                // Bookkeeping went with the rows.
                #expect(try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM sync_row_seq WHERE row_id = ?",
                    arguments: [post.id]) == 0)
                // The BOOK and the TAG survive — the family is the note's
                // household, never its acquaintances.
                #expect(try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM reading WHERE id = ?",
                    arguments: [book.id]) == 1)
                #expect(try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM tag WHERE id = ?",
                    arguments: [tag.id]) == 1)
            }
        }
    }

    @Test func aStrandedOriginalJoinsItsFamilysPurge() throws {
        try withOperations { ops, db in
            // Divide-W shape: original A preserved whole, successors B/C.
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(
                in: post.id, text: "First sentence. Second sentence.", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            let outcome = try ops.divideW(made.block.id, cuts: [made.variant.id: 16])
            let firstBlockID = outcome.first.block.id
            let secondBlockID = outcome.second.block.id
            // A is released to lineage — live, unplaced.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [made.block.id]) == 0)

            // Delete BOTH successors, then purge them as a family.
            for successor in [firstBlockID, secondBlockID] {
                try ops.deleteBlock(successor)
            }
            let family: PurgeFamily.Expansion = try db.read { db in
                try PurgeFamily.expand(db, roots: [
                    SyncPurgeTarget(table: "block", rowID: firstBlockID),
                    SyncPurgeTarget(table: "block", rowID: secondBlockID),
                ])
            }
            #expect(family.strandedOriginals.contains(made.block.id),
                    "the preserved original must ride its whole family's purge (round 8b)")
            #expect(family.ids(in: "block").contains(made.block.id))

            try db.write { db in
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                let fresh = try PurgeFamily.expand(db, roots: [
                    SyncPurgeTarget(table: "block", rowID: firstBlockID),
                    SyncPurgeTarget(table: "block", rowID: secondBlockID),
                ])
                try PurgeFamily.deleteLocal(
                    db, family: fresh, stamp: "2026-08-19T00:00:00.000Z")
            }
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE id = ?", [made.block.id]) == 0,
                    "the original is gone with its family")
        }
    }
}
