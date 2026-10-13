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

    // MARK: - RUN B B2 row 10 (17d P9): a LIVE container root's family

    /// **The mechanism pin (red on old):** `expandContainer`'s member-block
    /// arm was liveness-conditional — `b.deleted_at = c.deleted_at` can
    /// never be true for a LIVE container, so a live root expanded to its
    /// placements, lenses, tags and memberships with ZERO blocks, and the
    /// purge-wins roads that can hand the expansion a live root (the
    /// engine's `.purged` refusal handler; the janitor's in-transaction
    /// re-expand after `executePurge` racing a Put back; a ledger entry
    /// naming a since-revived row) removed the note while stranding its
    /// blocks live, unplaced and invisible — the partial state the file's
    /// own header contract ("purge is never partial") forbids.
    ///
    /// The live arm's discriminator: LIVE blocks under LIVE placements —
    /// what `deleteContainer`'s cascade would take. A block deleted
    /// EARLIER (its own stamp, its own Trash clock) does not ride, exactly
    /// as on the dead-root arm; an ARCHIVED block (kept forever) does not
    /// ride either, excluded by the same discriminator since archiving
    /// releases its placement.
    @Test func aLiveContainerRootExpandsItsLiveMemberBlocksFamilyComplete() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "revived note", profile: .generic)
            let kept = try ops.newBlock(in: post.id, text: "kept prose", at: .end)
            let second = try ops.newBlock(in: post.id, text: "second block", at: .end)
            let earlier = try ops.newBlock(in: post.id, text: "deleted earlier", at: .end)
            try ops.deleteBlock(earlier.block.id)
            let archived = try ops.newBlock(in: post.id, text: "kept forever", at: .end)
            try ops.archiveBlock(archived.block.id)

            let family: PurgeFamily.Expansion = try db.read { db in
                try PurgeFamily.expand(
                    db, roots: [SyncPurgeTarget(table: "container", rowID: post.id)])
            }
            let familyBlocks = family.ids(in: "block")
            #expect(familyBlocks.contains(kept.block.id),
                    "a live root's live member blocks ride — purge is never partial")
            #expect(familyBlocks.contains(second.block.id))
            #expect(family.ids(in: "variant").contains(kept.variant.id),
                    "the member blocks' takes ride with them")
            #expect(!familyBlocks.contains(earlier.block.id),
                    "a block deleted earlier keeps its own clock — it never rides")
            #expect(!familyBlocks.contains(archived.block.id),
                    "an archived block is kept forever — its released placement excludes it")
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
            let book = try ops.createReading(name: "doomed book", kind: .book, maxPosts: nil)
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
            let book = try ops.createReading(name: "book", kind: .book, maxPosts: nil)
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

    // MARK: - 13j ladder B (B1): the restore-side belt + the stamp-aware fence

    @Test func everyRestoreRoadVoidsALiveIntentNamingItsRow() throws {
        try withOperations { ops, db in
            // Block: delete → intent → restoreBlock voids it.
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            _ = try ops.newBlock(in: post.id, text: "the rest", at: .end)
            try ops.deleteBlock(made.block.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: made.block.id)])
            _ = try ops.restoreBlock(made.block.id)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM purge_intent
                WHERE table_name = 'block' AND row_id = ? AND deleted_at IS NULL
                """, [made.block.id]) == 0,
                    "a restored block voids the live intent naming it")

            // Take: delete → intent → restoreVariant voids it.
            let extra = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(extra.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "variant", rowID: extra.id)])
            _ = try ops.restoreVariant(extra.id)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM purge_intent
                WHERE table_name = 'variant' AND row_id = ? AND deleted_at IS NULL
                """, [extra.id]) == 0)

            // Note: delete → intent → restoreContainer voids it.
            try ops.deleteContainer(post.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: post.id)])
            try ops.restoreContainer(post.id)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM purge_intent
                WHERE table_name = 'container' AND row_id = ? AND deleted_at IS NULL
                """, [post.id]) == 0)

            // Book: delete → intent → restoreReading voids it.
            let book = try ops.createReading(name: "book", kind: .book)
            try ops.deleteReading(book.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "reading", rowID: book.id)])
            try ops.restoreReading(book.id)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM purge_intent
                WHERE table_name = 'reading' AND row_id = ? AND deleted_at IS NULL
                """, [book.id]) == 0)
        }
    }

    @Test func theUndoRoadVoidsALiveIntentToo() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            _ = try ops.newBlock(in: post.id, text: "the rest", at: .end)
            try ops.deleteBlock(made.block.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: made.block.id)])
            // The ⌥⌘Z inverse — the single-device door of the B1 hole.
            try ops.revertDeleteBlock(made.block.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE id = ? AND deleted_at IS NULL",
                [made.block.id]) == 1, "the undo brought the block back")
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM purge_intent
                WHERE table_name = 'block' AND row_id = ? AND deleted_at IS NULL
                """, [made.block.id]) == 0,
                    "…and the leftover intent can never claim it")
        }
    }

    /// **RUN B B2 row 11 (17d P28):** `reapplyStructural`'s untombstoning
    /// loop performs exactly `revertDeleteBlock`'s transition (its own
    /// comment says so) — but it was the ONE revive road that did not call
    /// `voidPurgeIntents`. The entry's trace, through the real doors:
    /// divide → type in the minted successor → ⌥⌘Z (the undo TRAYS the
    /// diverged mint) → Delete Now on it in the tray (a LIVE intent) →
    /// ⇧⌥⌘Z. Red on old: the intent stays live; an ordinary re-delete
    /// before the next sweep then names a genuinely-tombstoned row — the
    /// stamp-aware fences hide it from the Trash and the tray
    /// (`pi.deleted_at IS NULL`), `familyVerdict` no longer reads
    /// `.stale`, and the janitor takes it at the horizon with NO 30-day
    /// window at all.
    @Test func theRedoRoadVoidsALiveIntentLikeEverySiblingRevive() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "First half. Second half.")
            let divided = try ops.divide(a.block.id, cut: 13)
            // She works in the minted successor, so the undo TRAYS it
            // (the divergence bucket) and the tray's Delete Now can name it.
            try ops.autosave(divided.variant.id, text: "Second half, reworked.", charDelta: 10)
            #expect(try stack.undo(with: ops) == "Divide")
            #expect(try db.deletedAt("block", divided.block.id) != nil,
                    "the diverged mint trays rather than vanishing")
            _ = try ops.requestPurge(
                [SyncPurgeTarget(table: "block", rowID: divided.block.id)])

            #expect(try stack.redo(with: ops) == "Divide")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE id = ? AND deleted_at IS NULL",
                [divided.block.id]) == 1, "the redo brought the block back")
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM purge_intent
                WHERE table_name = 'block' AND row_id = ? AND deleted_at IS NULL
                """, [divided.block.id]) == 0,
                    "…and the leftover intent can never claim it — the B1 rule, redo road")

            // The consequence the entry traced: an ordinary re-delete
            // starts a FRESH 30-day clock and the row LISTS.
            try ops.deleteBlock(divided.block.id)
            let rows = try db.read {
                try Queries.trash($0, now: harnessNow, kinds: [.block])
            }
            #expect(rows.map(\.id).contains(divided.block.id),
                    "the re-deleted row lists on its fresh clock, never intent-limbo")
        }
    }

    @Test func aReDeletedRowListsInTheTrashDespiteItsVoidedIntent() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            _ = try ops.newBlock(in: post.id, text: "the rest", at: .end)
            try ops.deleteBlock(made.block.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: made.block.id)])
            _ = try ops.restoreBlock(made.block.id)  // voids the intent
            try ops.deleteBlock(made.block.id)       // a FRESH, ordinary delete

            // The stamp-aware fence (B1): the voided intent predates the
            // fresh tombstone, so the row lists — an any-state fence would
            // hide it forever, an unrecoverable-but-alive-intent limbo.
            let rows = try db.read {
                try Queries.trash($0, now: harnessNow, kinds: [.block])
            }
            #expect(rows.map(\.id) == [made.block.id],
                    "a re-deleted row lists on its fresh 30-day clock")
            let tray = try db.read {
                try Queries.trayBlocks($0, postID: post.id, now: harnessNow)
            }
            #expect(tray.map(\.blockID) == [made.block.id])
        }
    }

    @Test func aCompletedIntentStillFencesTheRowItActuallyCovered() throws {
        try withOperations { ops, db in
            // The purged-elsewhere ledger lag: the intent COMPLETED at or
            // after the row's tombstone — the fence must hold until the
            // ledger scan drops the local copy (never a re-listing window).
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            _ = try ops.newBlock(in: post.id, text: "the rest", at: .end)
            try ops.deleteBlock(made.block.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: made.block.id)])
            // Complete it the way a peer's janitor would (deleted_at AFTER
            // the row's own tombstone — completion follows deletion).
            try db.write { db in
                try db.execute(
                    sql: """
                        UPDATE purge_intent SET deleted_at = '2027-01-01T00:00:00.000Z'
                        WHERE table_name = 'block' AND row_id = ?
                        """,
                    arguments: [made.block.id])
            }
            let rows = try db.read {
                try Queries.trash($0, now: harnessNow, kinds: [.block])
            }
            #expect(rows.isEmpty, "purged stays purged — the completed intent still fences")
        }
    }

    // MARK: - VX-179: the comment kind ("Delete forever…", R-VX179-3)

    /// The live-intent count naming one comment — the belt pins' one read.
    private func liveCommentIntents(_ db: AppDatabase, _ commentID: String) throws -> Int? {
        try db.fetchInt(
            """
            SELECT COUNT(*) FROM purge_intent
            WHERE table_name = 'block_comment' AND row_id = ? AND deleted_at IS NULL
            """, [commentID])
    }

    /// A note with one live block and one comment on it, the comment then
    /// deleted — the deleted fold's ordinary row.
    private func deletedComment(
        _ ops: Operations, text: String = "a note to self"
    ) throws -> (post: Container, blockID: String, comment: BlockComment) {
        let post = try ops.createPost(title: "note", profile: .generic)
        let made = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
        let comment = try ops.addBlockComment(to: made.block.id, text: text)
        try ops.deleteBlockComment(comment.id)
        return (post, made.block.id, comment)
    }

    @Test func aLiveCommentRefusesOnlyDeletedCommentsPurge() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
            let live = try ops.addBlockComment(to: made.block.id, text: "still here")
            #expect {
                try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: live.id)])
            } throws: { error in
                error as? OperationError
                    == .purgeTargetNotDeleted(table: "block_comment", id: live.id)
            }
            #expect(try liveCommentIntents(db, live.id) == 0, "a refusal mints nothing")
        }
    }

    @Test func aDeletedCommentMintsOneTravellingIntentAndAskingTwiceIsOne() throws {
        try withOperations { ops, db in
            let (_, _, comment) = try deletedComment(ops)
            let target = SyncPurgeTarget(table: "block_comment", rowID: comment.id)

            #expect(try ops.requestPurge([target]) == 1)
            let intentID = try #require(try db.fetchString(
                "SELECT id FROM purge_intent WHERE table_name = 'block_comment' AND row_id = ?",
                [comment.id]))
            #expect(try db.outboxContains("purge_intent", intentID),
                    "the intent TRAVELS — every device's fold drops the row")
            // The act is idempotent by nature: the second ask mints nothing.
            #expect(try ops.requestPurge([target]) == 0)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM purge_intent WHERE row_id = ?", [comment.id]) == 1)
            // No undo entry, no content touch: the comment row itself is
            // untouched until the janitor takes it.
            #expect(try db.deletedAt("block_comment", comment.id) != nil)
        }
    }

    @Test func aMissingCommentRefusesByNameUnlessAlreadyPurged() throws {
        try withOperations { ops, db in
            #expect {
                try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: "ghost")])
            } throws: { error in
                error as? OperationError == .commentNotFound(id: "ghost")
            }
            // Gone WITH an intent standing (the janitor took it): skip.
            let (_, _, comment) = try deletedComment(ops)
            let target = SyncPurgeTarget(table: "block_comment", rowID: comment.id)
            _ = try ops.requestPurge([target])
            try db.write { db in
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                let family = try PurgeFamily.expand(db, roots: [target])
                #expect(family.rows == [target], "a comment's family is the row itself")
                try PurgeFamily.deleteLocal(
                    db, family: family, stamp: "2026-08-19T00:00:00.000Z")
            }
            #expect(try ops.requestPurge([target]) == 0,
                    "a purged comment is never re-minted — nothing would ever complete it")
        }
    }

    /// **RED-ON-OLD (the fence):** without the `NOT EXISTS` arm on
    /// `deletedBlockComments` the purged comment keeps listing in the fold
    /// until the janitor's horizon — a "deleted forever" row still offering
    /// Restore.
    @Test func anIntentNamedCommentLeavesTheDeletedFoldAtOnce() throws {
        try withOperations { ops, db in
            let (_, blockID, doomed) = try deletedComment(ops, text: "going for good")
            let kept = try ops.addBlockComment(to: blockID, text: "deleted, still restorable")
            try ops.deleteBlockComment(kept.id)
            #expect(try db.read {
                try Queries.deletedBlockComments($0, blockID: blockID)
            }.map(\.id) == [kept.id, doomed.id])

            _ = try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: doomed.id)])

            #expect(try db.read {
                try Queries.deletedBlockComments($0, blockID: blockID)
            }.map(\.id) == [kept.id], "the purged comment leaves the fold the moment it is asked")
            // A COMPLETED intent (the janitor's, or a peer's) still fences —
            // purged stays purged through the ledger lag.
            try db.write { db in
                try db.execute(
                    sql: """
                        UPDATE purge_intent SET deleted_at = '2027-01-01T00:00:00.000Z'
                        WHERE table_name = 'block_comment' AND row_id = ?
                        """,
                    arguments: [doomed.id])
            }
            #expect(try db.read {
                try Queries.deletedBlockComments($0, blockID: blockID)
            }.map(\.id) == [kept.id])
        }
    }

    /// **RED-ON-OLD (the restore belt):** without `voidPurgeIntents` in
    /// `restoreBlockComment` the intent stays LIVE on a live comment.
    @Test func restoringACommentVoidsItsLiveIntent() throws {
        try withOperations { ops, db in
            let (_, _, comment) = try deletedComment(ops)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: comment.id)])
            #expect(try liveCommentIntents(db, comment.id) == 1)

            try ops.restoreBlockComment(comment.id)
            #expect(try db.deletedAt("block_comment", comment.id) == nil)
            #expect(try liveCommentIntents(db, comment.id) == 0,
                    "a restored comment voids the live intent naming it (13j B1)")
        }
    }

    /// The belt's consequence, end to end, and the reason the fence is the
    /// STAMP-AWARE arm and not "any intent at all": restore → delete again
    /// must list on the fold like any ordinary delete. **Red on old** two
    /// ways — without the belt (the leftover LIVE intent fences the fresh
    /// tombstone and the janitor would take it unconfirmed) and under an
    /// any-state fence (the voided intent would hide it forever).
    @Test func aReDeletedCommentListsInTheFoldDespiteItsVoidedIntent() throws {
        try withOperations { ops, db in
            let (_, blockID, comment) = try deletedComment(ops)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: comment.id)])
            try ops.restoreBlockComment(comment.id)  // voids the intent
            try ops.deleteBlockComment(comment.id)   // a FRESH, ordinary delete

            #expect(try db.read {
                try Queries.deletedBlockComments($0, blockID: blockID)
            }.map(\.id) == [comment.id],
                    "a re-deleted comment is restorable again — never intent-limbo")
            #expect(try liveCommentIntents(db, comment.id) == 0)
        }
    }

    /// **RED-ON-OLD (the redo road's belt):** an AI client's comment
    /// (`addComment` — its own undo entry), undone by ⌥⌘Z, deleted forever
    /// from the fold, then brought back by ⇧⌥⌘Z: `reapplyAddedComment` is a
    /// REVIVE road, and without the belt the intent stays live on a live
    /// comment (the 17d P28 class — the redo road that forgot).
    @Test func theCommentRedoRoadVoidsALiveIntentLikeItsSiblings() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
            let comment = try ops.addComment(
                toBlock: made.block.id, text: "the AI's note", undoLabel: "Claude's comment")
            #expect(try stack.undo(with: ops) == "Claude's comment")
            #expect(try db.deletedAt("block_comment", comment.id) != nil,
                    "the undo tombstones it onto the deleted fold")
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: comment.id)])

            #expect(try stack.redo(with: ops) == "Claude's comment")
            #expect(try db.deletedAt("block_comment", comment.id) == nil,
                    "the redo brought the comment back")
            #expect(try liveCommentIntents(db, comment.id) == 0,
                    "…and the leftover intent can never claim it — the B1 rule, redo road")
        }
    }

    /// **RED-ON-OLD (the seal — PROVISIONAL, QUESTIONS #23(a)'s posture
    /// extended):** every comment write refuses under a sealed post, and a
    /// permanent delete is a write. Without `ensurePlacementUnlocked` in the
    /// arm the intent mints under the seal.
    @Test func aSealedPostRefusesACommentsDeleteForever() throws {
        try withOperations { ops, db in
            let (post, blockID, comment) = try deletedComment(ops)
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: comment.id)])
            }
            #expect(try liveCommentIntents(db, comment.id) == 0)
            #expect(try db.read {
                try Queries.deletedBlockComments($0, blockID: blockID)
            }.map(\.id) == [comment.id], "reading is free under the seal; the row stays listed")

            // Unsealed, the same ask lands.
            try ops.unlockPost(post.id)
            #expect(try ops.requestPurge(
                [SyncPurgeTarget(table: "block_comment", rowID: comment.id)]) == 1)
        }
    }

    /// **RED-ON-OLD (the dead-block guard — the hazard it closes, traced in
    /// the arm's comment):** a CASCADE victim purged alone would revive LIVE
    /// on its block's restore with its intent still standing. Without
    /// `liveBlock` in the arm, `ensurePlacementUnlocked` passes a dead block
    /// silently (no live placement ⇒ no post to ask) and the intent mints.
    @Test func aCommentUnderADeadBlockRefusesItsOwnPurge() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
            _ = try ops.newBlock(in: post.id, text: "Sibling.", at: .end)
            let victim = try ops.addBlockComment(to: made.block.id, text: "dies with the block")
            let earlier = try ops.addBlockComment(to: made.block.id, text: "deleted on its own")
            try ops.deleteBlockComment(earlier.id)
            try ops.deleteBlock(made.block.id)

            for comment in [victim, earlier] {
                #expect(throws: OperationError.blockNotFound(id: made.block.id)) {
                    try ops.requestPurge(
                        [SyncPurgeTarget(table: "block_comment", rowID: comment.id)])
                }
                #expect(try liveCommentIntents(db, comment.id) == 0)
            }
            // The block's own road is untouched: Put back revives the
            // victim on the stamp, with no intent anywhere to claim it.
            _ = try ops.restoreBlock(made.block.id)
            #expect(try db.deletedAt("block_comment", victim.id) == nil)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM purge_intent WHERE table_name = 'block_comment'") == 0)
        }
    }

    /// The decided edge's other half: a LIVE block with no live placement
    /// (released to lineage by divide-W) has no post to seal it, so a
    /// comment deleted on it purges like any other.
    @Test func aCommentOnALiveUnplacedBlockPurges() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .generic)
            let made = try ops.newBlock(
                in: post.id, text: "First sentence. Second sentence.", at: .end)
            let comment = try ops.addBlockComment(to: made.block.id, text: "on the original")
            _ = try ops.divideW(made.block.id, cuts: [made.variant.id: 16])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [made.block.id]) == 0, "the original is released — live, unplaced")
            try ops.deleteBlockComment(comment.id)

            #expect(try ops.requestPurge(
                [SyncPurgeTarget(table: "block_comment", rowID: comment.id)]) == 1)
        }
    }

    /// The Delete Now road, driven for the kind on a local install (the
    /// panel's confirm runs this sweep, `AppSession.sweepLocalPurge`): the
    /// row is physically removed, the intent completes, and the fold stays
    /// empty — purged stays purged.
    @Test func theLocalRoadTakesAPurgedCommentWhole() async throws {
        try await withOperationsAsync { ops, db in
            let (_, blockID, comment) = try deletedComment(ops)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: comment.id)])

            let report = try await LocalPurge(database: db).sweep()
            #expect(report.familiesPurged == 1)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block_comment WHERE id = ?", [comment.id]) == 0,
                    "the bytes are gone on a local install")
            #expect(try liveCommentIntents(db, comment.id) == 0, "the intent completed")
            let fold = try await db.read {
                try Queries.deletedBlockComments($0, blockID: blockID)
            }
            #expect(fold.isEmpty)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE id = ? AND deleted_at IS NULL",
                [blockID]) == 1, "the block it hung on is untouched")
        }
    }
}
