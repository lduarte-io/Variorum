import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **Phase 13j batch 6 — the Trash's clock, its listing, and block archive.**
///
/// Her rulings under test, by number: the 30-day window is FIXED and applies
/// to EVERY surface (round 3); everything deleted rides ONE listing, filtered
/// by kind (round 3); a note deleted whole is ONE row and its cascade victims
/// are never double-listed (round 5); a preserved original is permanent while
/// any descendant lives and MOVES onto the family's clock when the last one
/// is deleted (round 8b); block archive is kept-forever with no clock, and
/// Put back returns the block where it stood (round 7).
@Suite("13j — the Trash window, the listing & block archive")
struct TrashAndArchiveTests {
    // MARK: - The window (the pure rule)

    @Test func theWindowIsThirtyDaysAndTheBoundaryBelongsToTheThingBeingRecovered() {
        let now = harnessNow
        let day29 = DateFormatter.variorumISO8601.string(
            from: now.addingTimeInterval(-29 * 86_400))
        let day31 = DateFormatter.variorumISO8601.string(
            from: now.addingTimeInterval(-31 * 86_400))
        #expect(TrashWindow.days == 30)
        #expect(TrashWindow.isInWindow(day29, now: now))
        #expect(!TrashWindow.isInWindow(day31, now: now))
        // "N days left" counts whole days down, and the LAST day is a whole
        // day rather than a rounded-away one.
        #expect(TrashWindow.daysLeft(
            DateFormatter.variorumISO8601.string(from: now), now: now) == 30)
        #expect(TrashWindow.daysLeft(day29, now: now) == 1)
        #expect(TrashWindow.daysLeft(day31, now: now) == 0)
        // An unparseable stamp reads as IN (never hide a thing on a
        // technicality) and wears no clock rather than a made-up one.
        #expect(TrashWindow.isInWindow("not a stamp", now: now))
        #expect(TrashWindow.daysLeft("not a stamp", now: now) == nil)
    }

    // MARK: - The age fence, on every surface

    @Test func aDeletedThingLeavesEVERYSurfaceAtThirtyDays() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the note")
            let kept = try ops.newBlock(in: post.id, text: "stays")
            let gone = try ops.newBlock(in: post.id, text: "deleted block")
            let take = try ops.branchVariant(kept.block.id, from: kept.variant.id)
            try ops.deleteVariant(take.id)
            try ops.deleteBlock(gone.block.id)
            let deadPost = try ops.createPost(title: "deleted note")
            try ops.deleteContainer(deadPost.id)
            let book = try ops.createReading(name: "b", kind: .curated)
            try ops.deleteReading(book.id)

            let inWindow = harnessNow
            let past = harnessNow.addingTimeInterval(31 * 86_400)

            let day0 = try db.read { db in
                (tray: try Queries.trayBlocks(db, postID: post.id, now: inWindow).count,
                 counts: try Queries.trayCounts(db, postID: post.id, now: inWindow).deleted,
                 takes: try Queries.deletedTakes(db, blockID: kept.block.id, now: inWindow).count,
                 past: try Queries.blockPast(
                    db, blockID: kept.block.id, now: inWindow).deletedTakes.count,
                 posts: try Queries.deletedPosts(db, now: inWindow).count,
                 books: try Queries.deletedReadings(db, now: inWindow).count,
                 trash: try Queries.trash(db, now: inWindow).count)
            }
            // Day 0: every listing sees it.
            #expect(day0.tray == 1)
            #expect(day0.counts == 1)
            #expect(day0.takes == 1)
            #expect(day0.past == 1)
            #expect(day0.posts == 1)
            #expect(day0.books == 1)
            #expect(day0.trash == 4, "block · take · note · book")

            let day31 = try db.read { db in
                (tray: try Queries.trayBlocks(db, postID: post.id, now: past).count,
                 counts: try Queries.trayCounts(db, postID: post.id, now: past).deleted,
                 takes: try Queries.deletedTakes(db, blockID: kept.block.id, now: past).count,
                 past: try Queries.blockPast(
                    db, blockID: kept.block.id, now: past).deletedTakes.count,
                 posts: try Queries.deletedPosts(db, now: past).count,
                 books: try Queries.deletedReadings(db, now: past).count,
                 trash: try Queries.trash(db, now: past).count)
            }
            // Day 31: it has left EVERY one of them.
            #expect(day31.tray == 0)
            #expect(day31.counts == 0)
            #expect(day31.takes == 0)
            #expect(day31.past == 0)
            #expect(day31.posts == 0)
            #expect(day31.books == 0)
            #expect(day31.trash == 0)
        }
    }

    // MARK: - The listing

    @Test func aNoteDeletedWholeIsONERowAndItsBlocksAreNeverDoubleListed() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "whole note")
            let first = try ops.newBlock(in: post.id, text: "one")
            _ = try ops.newBlock(in: post.id, text: "two")
            // A take deleted on its own BEFORE the note goes keeps its own
            // stamp — but its BLOCK dies with the note, so it is a cascade
            // victim's child and must not list either.
            let take = try ops.branchVariant(first.block.id, from: first.variant.id)
            try ops.deleteVariant(take.id)
            try ops.deleteContainer(post.id)

            let rows = try db.read { try Queries.trash($0, now: harnessNow) }
            #expect(rows.count == 1, "one note deleted whole is ONE row")
            #expect(rows[0].kind == .note)
            #expect(rows[0].id == post.id)
        }
    }

    @Test func theListingFiltersByKindAndSortsBothWays() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let block = try ops.newBlock(in: post.id, text: "block text")
            let keeper = try ops.newBlock(in: post.id, text: "keeps the note alive")
            let take = try ops.branchVariant(keeper.block.id, from: keeper.variant.id)
            let book = try ops.createReading(name: "book", kind: .curated)
            try ops.deleteBlock(block.block.id)
            try ops.deleteVariant(take.id)
            try ops.deleteReading(book.id)

            try db.read { db in
                let all = try Queries.trash(db, now: harnessNow)
                #expect(Set(all.map(\.kind)) == [.block, .take, .book])
                // Newest first by default; oldest first on request.
                #expect(all.map(\.id) == all.sorted { $0.deletedAt > $1.deletedAt }.map(\.id))
                let oldest = try Queries.trash(db, now: harnessNow, oldestFirst: true)
                #expect(oldest.map(\.id) == all.reversed().map(\.id))
                // The filter.
                let blocksOnly = try Queries.trash(db, now: harnessNow, kinds: [.block])
                #expect(blocksOnly.map(\.id) == [block.block.id])
                let takesOnly = try Queries.trash(db, now: harnessNow, kinds: [.take])
                #expect(takesOnly.map(\.id) == [take.id])
                // Context: a block/take row says which note it came from.
                #expect(blocksOnly[0].noteID == post.id)
                #expect(blocksOnly[0].noteTitle == "note")
                #expect(blocksOnly[0].noteIsDeleted == false)
                #expect(takesOnly[0].blockID == keeper.block.id)
            }
        }
    }

    @Test func aBlockWhoseNoteDiedLaterSaysSo() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let block = try ops.newBlock(in: post.id, text: "deleted first")
            _ = try ops.newBlock(in: post.id, text: "the rest")
            try ops.deleteBlock(block.block.id)
            try ops.deleteContainer(post.id)

            let rows = try db.read { try Queries.trash($0, now: harnessNow, kinds: [.block]) }
            #expect(rows.count == 1, "deleted first, on its own stamp — still its own row")
            #expect(rows[0].noteIsDeleted, "…and it says its note is in the Trash too")
        }
    }

    // MARK: - The preserved original's two states (her round-8b ruling)

    @Test func anOriginalIsPermanentWhileADescendantLivesAndMovesWhenTheLastOneGoes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "divided")
            let block = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.branchVariant(block.block.id, from: block.variant.id)
            let w = try ops.divideW(block.block.id, cuts: [block.variant.id: 12])

            // While the successors live: the original is a PERMANENT row —
            // in the note's tray, with no family clock.
            let before = try db.read { db in
                (clocks: try Queries.originFamilyClocks(db, postID: post.id),
                 stranded: try Queries.strandedOriginals(db, now: harnessNow).count,
                 originals: try Queries.preservedOriginals(db, postID: post.id).map(\.blockID))
            }
            #expect(before.clocks.isEmpty, "nothing is at risk while the family lives")
            #expect(before.stranded == 0)
            #expect(before.originals == [block.block.id])

            try ops.deleteBlock(w.first.block.id)
            let midway = try db.read { try Queries.originFamilyClocks($0, postID: post.id) }
            #expect(midway.isEmpty, "one descendant still lives — still permanent")

            try ops.deleteBlock(w.second.block.id)
            let clocks = try db.read { try Queries.originFamilyClocks($0, postID: post.id) }
            #expect(clocks[block.block.id] != nil,
                    "the LAST live descendant went — the original moves onto the clock")
            let stranded = try db.read { try Queries.strandedOriginals($0, now: harnessNow) }
            #expect(stranded.map(\.id) == [block.block.id])
            #expect(stranded[0].kind == .preservedOriginal)
            #expect(stranded[0].noteID == post.id)

            // …and Put back of ANY descendant returns it to the forever
            // section. Pure derivation — nothing is written to the original.
            _ = try ops.restoreBlock(w.second.block.id)
            let after = try db.read { db in
                (clocks: try Queries.originFamilyClocks(db, postID: post.id),
                 stranded: try Queries.strandedOriginals(db, now: harnessNow).count)
            }
            #expect(after.clocks.isEmpty, "put one back and the original is permanent again")
            #expect(after.stranded == 0)
        }
    }

    @Test func aStrandedOriginalRidesTheNotesOneRowWhenTheWholeNoteGoes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "divided")
            let block = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.branchVariant(block.block.id, from: block.variant.id)
            _ = try ops.divideW(block.block.id, cuts: [block.variant.id: 12])
            try ops.deleteContainer(post.id)

            let rows = try db.read { try Queries.trash($0, now: harnessNow) }
            #expect(rows.map(\.kind) == [.note], "ONE row — the note; nothing double-listed")
        }
    }

    @Test func theReceiptKnowsWhenADeleteStrandedAnOriginal() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "divided")
            let block = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.branchVariant(block.block.id, from: block.variant.id)
            let w = try ops.divideW(block.block.id, cuts: [block.variant.id: 12])

            try ops.deleteBlock(w.first.block.id)
            let afterFirst = try db.read {
                try Queries.originalsStrandedBy($0, blockIDs: [w.first.block.id])
            }
            #expect(afterFirst.isEmpty, "one descendant still lives — the receipt says nothing")

            try ops.deleteBlock(w.second.block.id)
            let afterSecond = try db.read {
                try Queries.originalsStrandedBy($0, blockIDs: [w.second.block.id])
            }
            #expect(afterSecond == [block.block.id],
                    "this delete took the last one — the receipt names it")
        }
    }

    // MARK: - Block archive (her round-7 ruling)

    @Test func archiveReleasesThePlacementAndStampsTheBlock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let first = try ops.newBlock(in: post.id, text: "one")
            let second = try ops.newBlock(in: post.id, text: "two")

            try ops.archiveBlock(first.block.id)

            let block = try db.read { try Block.fetchOne($0, key: first.block.id) }
            #expect(block?.archivedAt != nil, "the stamp")
            #expect(block?.deletedAt == nil, "archive is NOT a delete")
            #expect(block?.lastContainerId == post.id, "it remembers its note")
            // The note renders on, with no view-level filtering: rendering
            // walks live placements, and the archived block has none.
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.map(\.blockID) == [second.block.id])
            // It lists in the tray's first section, and NOT among the
            // preserved originals (a deliberate set-aside is not a leftover).
            let listings = try db.read { db in
                (archived: try Queries.archivedBlocks(db, postID: post.id).map(\.blockID),
                 originals: try Queries.preservedOriginals(db, postID: post.id).count,
                 counts: try Queries.trayCounts(db, postID: post.id, now: harnessNow),
                 trash: try Queries.trash(db, now: harnessNow).count)
            }
            #expect(listings.archived == [first.block.id])
            #expect(listings.originals == 0, "a set-aside is not a leftover")
            #expect(listings.counts.archived == 1)
            #expect(listings.counts.deleted == 0, "the badge counts deleted only (#67(a))")
            #expect(listings.counts.preservedOriginals == 0)
            // An archived block is not in the Trash: no clock, ever.
            #expect(listings.trash == 0)
        }
    }

    @Test func unarchivePutsTheBlockBackWhereItStood() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let first = try ops.newBlock(in: post.id, text: "one")
            let second = try ops.newBlock(in: post.id, text: "two")
            let third = try ops.newBlock(in: post.id, text: "three")

            try ops.archiveBlock(second.block.id)
            let landing = try ops.unarchiveBlock(second.block.id)

            #expect(landing == .itsOldPlace, "the exact placement row revived (the F2 road)")
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.map(\.blockID)
                    == [first.block.id, second.block.id, third.block.id],
                    "…so it comes back in its own position, not at the end")
            let block = try db.read { try Block.fetchOne($0, key: second.block.id) }
            #expect(block?.archivedAt == nil)
        }
    }

    @Test func theArchiveDoorsRefuseWhatTheyMust() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let first = try ops.newBlock(in: post.id, text: "one")
            _ = try ops.newBlock(in: post.id, text: "two")

            #expect(throws: OperationError.self) { try ops.unarchiveBlock(first.block.id) }
            try ops.archiveBlock(first.block.id)
            #expect(throws: OperationError.self) { try ops.archiveBlock(first.block.id) }

            // The seal: a placement release is a pointer change, and the seal
            // freezes pointer order (AppSpec §9's letter).
            let sealed = try ops.createPost(title: "sealed")
            let block = try ops.newBlock(in: sealed.id, text: "under the seal")
            _ = try ops.newBlock(in: sealed.id, text: "second")
            try ops.lockPost(sealed.id)
            #expect(throws: OperationError.self) { try ops.archiveBlock(block.block.id) }
            // …and unarchiving back INTO a sealed note refuses too.
            try ops.unlockPost(sealed.id)
            try ops.archiveBlock(block.block.id)
            try ops.lockPost(sealed.id)
            #expect(throws: OperationError.self) { try ops.unarchiveBlock(block.block.id) }
            _ = db
        }
    }

    @Test func archiveIsOneStructuralEntryThatUndoesAndRedoes() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note")
            let first = try ops.newBlock(in: post.id, text: "one")
            _ = try ops.newBlock(in: post.id, text: "two")

            try ops.archiveBlock(first.block.id)
            #expect(stack.topLabel == "Archive Block")

            _ = try stack.undo(with: ops)
            var block = try db.read { try Block.fetchOne($0, key: first.block.id) }
            #expect(block?.archivedAt == nil, "undo puts it back in the note")
            #expect(try db.read { try Queries.renderPost($0, containerID: post.id) }
                .first?.blockID == first.block.id)

            _ = try stack.redo(with: ops)
            block = try db.read { try Block.fetchOne($0, key: first.block.id) }
            #expect(block?.archivedAt != nil, "redo sets it aside again")
            #expect(try db.read { try Queries.archivedBlocks($0, postID: post.id) }
                .map(\.blockID) == [first.block.id])
        }
    }
}
