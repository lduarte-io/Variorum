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
            let book = try ops.createReading(name: "b", kind: .book)
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

    /// **THE BLOCK'S WHOLE TIME, IN ONE PROJECTION** (the post-13l polish
    /// round, ledger row 17 — the read behind her Block History pane).
    ///
    /// Two things it does that no shipped read did: it carries EVERY live
    /// take's savepoint run (the two faces it replaces each showed one take's
    /// at a time), and it carries the ORIGINALS with enough of their text to
    /// recognise — which is what let a pane absorb a peek whose whole panel
    /// existed to show that text. Its clock and its purge fence are
    /// `deletedTakes`' own, unchanged.
    @Test func theBlockHistoryProjectionCarriesEveryTakesRunAndItsOrigins() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "one block's time")
            let a = try ops.newBlock(in: post.id, text: "Alpha.")
            let b = try ops.newBlock(in: post.id, text: "Beta.")
            let second = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(second.id, text: "Alpha, again.", charDelta: 0)
            _ = try ops.commit(a.variant.id, kind: .manual)
            _ = try ops.commit(second.id, kind: .manual)
            _ = try ops.commit(second.id, kind: .auto)
            let archived = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.archiveVariant(archived.id)
            let doomed = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.deleteVariant(doomed.id)
            let merged = try ops.merge(a.block.id, b.block.id)

            let history = try db.read {
                try Queries.blockHistory($0, blockID: merged.block.id, now: harnessNow)
            }
            // The merge released BOTH sources, and both are here with their
            // text (the 13l walk's P-3 — the old door showed one).
            #expect(Set(history.origins.map(\.origin.blockID)) == Set([a.block.id, b.block.id]))
            #expect(history.origins.allSatisfy { $0.text?.isEmpty == false })

            let source = try db.read {
                try Queries.blockHistory($0, blockID: a.block.id, now: harnessNow)
            }
            #expect(source.activeTakes.map(\.id) == [a.variant.id, second.id])
            #expect(source.archivedTakes.map(\.id) == [archived.id])
            #expect(source.savepoints[a.variant.id]?.count == 1)
            #expect(source.savepoints[second.id]?.count == 2,
                    "every live take's run, not the caret take's alone")
            #expect(source.deletedTakes.map(\.id) == [doomed.id])
            #expect(!source.isEmpty)

            // A block with one take and nothing behind it is EMPTY — the pane
            // renders a region only where there is something in it.
            let plain = try ops.newBlock(in: post.id, text: "ordinary")
            #expect(try db.read {
                try Queries.blockHistory($0, blockID: plain.block.id, now: harnessNow)
            }.isEmpty)

            // The clock and the purge fence are `deletedTakes`' own: past the
            // window the deleted take leaves this projection too.
            #expect(try db.read {
                try Queries.blockHistory(
                    $0, blockID: a.block.id,
                    now: harnessNow.addingTimeInterval(31 * 86_400))
            }.deletedTakes.isEmpty)
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
            let book = try ops.createReading(name: "book", kind: .book)
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

    /// **13l Act 7 — the 8d walk's find: the Trash was the ONE surface that
    /// still said "Untitled".**
    ///
    /// A nameless note (every `⌘N` and every quick-entry note is one — the
    /// mint stores `nil`, 13g's other half) has no `entry_date` either, so
    /// `DisplayTitle.note`'s third link — the created DAY — is the only one
    /// that answers. Every arm of `Queries.trash` called that rule while
    /// omitting `createdAt:`, which is exactly the degraded path the rule's
    /// own doc names ("every such caller degrades to the behaviour it had
    /// before this existed"), so the row read `"Untitled"` — the placeholder
    /// her 13g R6-3 and 13k K1 rulings retired — while the note's masthead,
    /// its Library row and its shelf card all read its date.
    ///
    /// It matters HERE more than anywhere: this row is the one that has to
    /// answer *"which note am I putting back?"*, and 8d's mandate is that
    /// the recovery story hold from every door. All four arms carry the
    /// stamp now; the block/take/original arms name their HOME note through
    /// the same rule, so a block's context line cannot say "in Untitled"
    /// either.
    @Test func theTrashNamesANamelessNoteByItsDayAndNeverByThePlaceholder() throws {
        try withOperations { ops, db in
            // Nameless AND dateless — the quick-entry / ⌘N shape exactly.
            let post = try ops.createPost()
            let kept = try ops.newBlock(in: post.id, text: "keeps the note alive")
            let block = try ops.newBlock(in: post.id, text: "a deleted block")
            let take = try ops.branchVariant(kept.block.id, from: kept.variant.id)
            try ops.deleteBlock(block.block.id)
            try ops.deleteVariant(take.id)

            // The original's arm, so all four are covered by one fixture.
            let divided = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.branchVariant(divided.block.id, from: divided.variant.id)
            let w = try ops.divideW(divided.block.id, cuts: [divided.variant.id: 12])
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)

            let stamp = try db.read { db -> String? in
                try Row.fetchOne(
                    db, sql: "SELECT created_at FROM container WHERE id = ?",
                    arguments: [post.id])?["created_at"]
            }
            let day = try #require(DisplayTitle.day(fromStamp: #require(stamp)))
            #expect(day != DisplayTitle.placeholder)

            try db.read { db in
                // The block/take/original arms first — the note is still LIVE,
                // so its own arm has nothing to list yet.
                let rows = try Queries.trash(db, now: harnessNow)
                let byKind = Dictionary(grouping: rows, by: \.kind)
                for kind in [Queries.TrashItem.Kind.block, .preservedOriginal] {
                    let row = try #require(byKind[kind]?.first, "expected a \(kind) row")
                    #expect(row.noteTitle == day,
                            "a \(kind) row must name its home note by its day")
                    #expect(row.noteTitle != DisplayTitle.placeholder)
                }
                // JUSTIFIED EDIT (13i-d ladder B fix A): this arm used to
                // RECORD a gap instead of asserting — a take deleted from a
                // live block named no note, because the arm reached its note
                // through `block.last_container_id`, a stamp a LIVE block has
                // never carried. The ladder's fix joins through the block's
                // LIVE placement first (the query change the old comment
                // proposed), so the take row now names its home note like its
                // three siblings — the old `== nil` assertion flips to the
                // same day-name rule the block arm keeps.
                let take = try #require(byKind[.take]?.first, "expected a take row")
                #expect(take.noteTitle == day,
                        "a take row must name its home note by its day")
                #expect(take.noteTitle != DisplayTitle.placeholder)
            }

            // And the note's own arm, once it goes.
            try ops.deleteContainer(post.id)
            let noteRow = try db.read { db in
                try Queries.trash(db, now: harnessNow, kinds: [.note]).first
            }
            #expect(try #require(noteRow).title == day)
            #expect(try #require(noteRow).title != DisplayTitle.placeholder)
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

    // 13j ladder B (B5) — annotated pin edit, claims byte-unchanged:
    // `originFamilyClocks` gained `now:` (the tray twin's window/intent
    // fences) and returns FATES; the in-window assertions here read the
    // same truths through the new shape.
    @Test func anOriginalIsPermanentWhileADescendantLivesAndMovesWhenTheLastOneGoes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "divided")
            let block = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.branchVariant(block.block.id, from: block.variant.id)
            let w = try ops.divideW(block.block.id, cuts: [block.variant.id: 12])

            // While the successors live: the original is a PERMANENT row —
            // in the note's tray, with no family clock.
            let before = try db.read { db in
                (clocks: try Queries.originFamilyClocks(db, postID: post.id, now: harnessNow),
                 stranded: try Queries.strandedOriginals(db, now: harnessNow).count,
                 originals: try Queries.preservedOriginals(db, postID: post.id).map(\.blockID))
            }
            #expect(before.clocks.isEmpty, "nothing is at risk while the family lives")
            #expect(before.stranded == 0)
            #expect(before.originals == [block.block.id])

            try ops.deleteBlock(w.first.block.id)
            let midway = try db.read { try Queries.originFamilyClocks($0, postID: post.id, now: harnessNow) }
            #expect(midway.isEmpty, "one descendant still lives — still permanent")

            try ops.deleteBlock(w.second.block.id)
            let clocks = try db.read { try Queries.originFamilyClocks($0, postID: post.id, now: harnessNow) }
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
                (clocks: try Queries.originFamilyClocks(db, postID: post.id, now: harnessNow),
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

    /// **An archived block is not a leftover** (her round-7 ruling meeting
    /// her round-4 lineage door): the door offers ORIGINALS a divide or merge
    /// released, and offering an archived block there would let its Put back
    /// run `placeBlock` — which knows nothing about `archived_at` — leaving a
    /// block that is in the note AND listed as kept aside.
    @Test func theLineageDoorDoesNotOfferAnArchivedBlock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "divided")
            let block = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.branchVariant(block.block.id, from: block.variant.id)
            let w = try ops.divideW(block.block.id, cuts: [block.variant.id: 12])

            let before = try db.read {
                try Queries.unplacedOrigins($0, ofBlock: w.first.block.id).map(\.blockID)
            }
            #expect(before == [block.block.id], "the original is the door's whole point")

            try ops.archiveBlock(block.block.id)
            let after = try db.read { db in
                (ofBlock: try Queries.unplacedOrigins(db, ofBlock: w.first.block.id).count,
                 inPost: try Queries.unplacedOrigins(db, inContainer: post.id).count,
                 tray: try Queries.archivedBlocks(db, postID: post.id).map(\.blockID))
            }
            #expect(after.ofBlock == 0, "archived: the lineage door stops offering it")
            #expect(after.inPost == 0, "…on both reads of the same fact")
            #expect(after.tray == [block.block.id], "its road is the tray's Put back")
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

            #expect(landing == .itsOldPlace(home: .post),
                    "the exact placement row revived (the F2 road), in a note")
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

    // MARK: - 13j ladder B (B4): the per-arm SQL window is direction-true

    @Test func oldestFirstWithALimitReturnsTheTrueOldestRows() throws {
        try withOperations { ops, db in
            // Five deleted notes, deleted in order — the harness clock
            // ticks, so their tombstones are strictly increasing.
            var ids: [String] = []
            for index in 0..<5 {
                let post = try ops.createPost(title: "note \(index)", profile: .generic)
                try ops.deleteContainer(post.id)
                ids.append(post.id)
            }
            // The B4 trap this pins: a DESC arm under an oldest-first merge
            // hands over its NEWEST rows and presents the oldest of THOSE —
            // silently wrong. The arm must sort in the caller's direction
            // BEFORE it limits.
            let oldest = try db.read {
                try Queries.trash($0, now: harnessNow, kinds: [.note],
                                  oldestFirst: true, limit: 2)
            }
            #expect(oldest.map(\.id) == Array(ids.prefix(2)),
                    "oldest-first + limit = the true oldest, not the newest re-sorted")
            let newest = try db.read {
                try Queries.trash($0, now: harnessNow, kinds: [.note], limit: 2)
            }
            #expect(newest.map(\.id) == Array(ids.suffix(2).reversed()))
        }
    }

    // MARK: - 13j ladder B (B5): the two surfaces answer one state ONE way

    @Test func anExpiredFamilysOriginalLeavesBothTrayBucketsAndTheTrash() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "divided", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.branchVariant(block.block.id, from: block.variant.id)
            let w = try ops.divideW(block.block.id, cuts: [block.variant.id: 12])
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)

            // Day 29: counting — the tray's clock section and the Trash
            // agree the family is in its window.
            let day29 = harnessNow.addingTimeInterval(29 * 86_400)
            let counting = try db.read {
                try Queries.originFamilyClocks($0, postID: post.id, now: day29)
            }
            guard case .counting? = counting[block.block.id] else {
                Issue.record("day 29: the original rides the family's clock")
                return
            }
            #expect(try db.read { try Queries.strandedOriginals($0, now: day29) }
                .map(\.id) == [block.block.id])

            // Day 31: the family left every surface — the original leaves
            // BOTH tray buckets with it (round 8b + memo §4c: the janitor's
            // family expansion still takes it, so a "permanent" label here
            // would be the trust violation reborn in the post-window gap).
            let day31 = harnessNow.addingTimeInterval(31 * 86_400)
            let fates = try db.read {
                try Queries.originFamilyClocks($0, postID: post.id, now: day31)
            }
            #expect(fates[block.block.id] == .gone,
                    "expired family ⇒ the original leaves both buckets")
            #expect(try db.read { try Queries.strandedOriginals($0, now: day31) }.isEmpty,
                    "…and the Trash's twin arm answers the same state the same way")
        }
    }

    @Test func anIntentNamedFamilysOriginalLeavesTheTrayWithItsBlocks() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "divided", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.branchVariant(block.block.id, from: block.variant.id)
            let w = try ops.divideW(block.block.id, cuts: [block.variant.id: 12])
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)
            _ = try ops.requestPurge([
                SyncPurgeTarget(table: "block", rowID: w.first.block.id),
                SyncPurgeTarget(table: "block", rowID: w.second.block.id),
            ])

            // The deleted blocks left every surface at the confirm; the
            // origin leaves the tray's clock section (and the Trash) WITH
            // them — never a countdown pointing at rows no surface lists.
            let fates = try db.read {
                try Queries.originFamilyClocks($0, postID: post.id, now: harnessNow)
            }
            #expect(fates[block.block.id] == .gone,
                    "an intent-named family takes its original off every surface")
            #expect(try db.read { try Queries.strandedOriginals($0, now: harnessNow) }.isEmpty)
            #expect(try db.read { try Queries.trayBlocks($0, postID: post.id, now: harnessNow) }
                .isEmpty, "the fenced blocks are gone from the tray")
        }
    }

    // MARK: - The post-13l polish round (ledger rows 8 + 22)

    /// **VERSION HISTORY IS NOT AN ARCHIVED NOTE** (ledger row 8 — the V1
    /// classifier, built as the EXCLUSION before batch 5 mints the versions
    /// it excludes).
    ///
    /// Her B2 direction gave archive its own room, and her own worry about it
    /// was crowding: a note with fifteen saved moments would drown the notes
    /// she actually set aside. The answer needs no schema — a saved version
    /// is BORN ARCHIVED (`archived_at = created_at`, one clock call inside
    /// the save transaction) and carries a `version_of` edge to a note that
    /// is still live, and that conjunction IS the class.
    ///
    /// The born-archived half is hand-seeded here, deliberately: the save
    /// door arrives in batch 5, and the harness clock ticks once per read, so
    /// nothing in the shipped ops can produce the equal pair today. What is
    /// pinned is the CLASSIFIER, which batch 5 must then satisfy.
    ///
    /// **RED ON OLD** by behavioural revert (drop the `versionFence` from
    /// `Queries.archivedPosts`): the first expectation reds, listing the
    /// version copy among her archived notes.
    @Test func versionHistoryNeverListsAmongTheArchivedNotes() throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: source.id, text: "Prose.")
            let plain = try ops.createPost(title: "a work I set aside")
            _ = try ops.newBlock(in: plain.id, text: "More prose.")
            try ops.archiveContainer(plain.id)

            // The version copy: `duplicateAsVersion` mints the copy AND the
            // `version_of` edge; the born-archived stamp is the half batch 5
            // will write in the same transaction, seeded by hand.
            let copy = try ops.duplicateAsVersion(source.id)
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container SET archived_at = created_at WHERE id = ?",
                    arguments: [copy.post.id])
            }

            let listed = try db.read { try Queries.archivedPosts($0) }
            #expect(!listed.map(\.postID).contains(copy.post.id),
                    "a saved version's home is its note's Versions listing, never Archived")
            #expect(listed.map(\.postID).contains(plain.id),
                    "a note she set aside is exactly what this surface is for")

            // The RAW column is still readable, so the exclusion is a
            // product rule at a named door and never a lost row.
            let raw = try db.read {
                try Queries.archivedPosts($0, excludingVersionHistory: false)
            }
            #expect(raw.map(\.postID).contains(copy.post.id))
        }
    }

    /// **A NOTE THAT WAS EVER LIVE IS NEVER VERSION HISTORY** (ledger row 8,
    /// the classifier's other half — her sixth-sitting catch: a working draft
    /// archived later must never read as version history, especially once
    /// versions ride deletions).
    ///
    /// The same copy, version-linked exactly the same way, archived as a
    /// SECOND act: `archived_at` is a later tick than `created_at`, so it is
    /// a WORK she set aside and it lists.
    @Test func aCopySheWorkedWithAndArchivedLaterIsAnArchivedNote() throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: source.id, text: "Prose.")
            let copy = try ops.duplicateAsVersion(source.id)
            // Born LIVE (the fork road), archived later — two clock reads.
            try ops.archiveContainer(copy.post.id)

            let listed = try db.read { try Queries.archivedPosts($0) }
            #expect(listed.map(\.postID).contains(copy.post.id),
                    "archived-later is a WORK; only born-archived is version history")
        }
    }

    /// **THE STRANDED ORIGINAL NAMES THE BLOCK WHOSE CLOCK IT RIDES**
    /// (ledger row 22 — her tenth-sitting ruling: *"those ancestors [go]
    /// under the live block that was most recently deleted … going to trash
    /// shows you what you just deleted rather than suddenly being
    /// overwhelmed by 31 random items"*).
    ///
    /// The Trash nests the original under that block's row, and the anchor is
    /// the query's own answer rather than a stamp match at the face — which
    /// matters exactly when several blocks are deleted in one gesture and
    /// share a stamp.
    ///
    /// **RED ON OLD** by behavioural revert (drop `anchor_block_id` from
    /// `strandedOriginals` and the argument that carries it): `anchorBlockID`
    /// reads nil and both expectations red.
    @Test func aStrandedOriginalNamesTheDeletionThatStrandedIt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the note")
            let divided = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.branchVariant(divided.block.id, from: divided.variant.id)
            let w = try ops.divideW(divided.block.id, cuts: [divided.variant.id: 12])
            // The FIRST successor goes, then the second — so the family clock
            // is the second deletion, and that is the row she just acted on.
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)

            let originals = try db.read {
                try Queries.strandedOriginals($0, now: harnessNow)
            }
            let original = try #require(originals.first)
            #expect(original.id == divided.block.id)
            #expect(original.anchorBlockID == w.second.block.id,
                    "the anchor is the deletion whose stamp IS the family clock")
            #expect(original.deletedAt
                == (try db.fetchString(
                        "SELECT deleted_at FROM block WHERE id = ?", [w.second.block.id])),
                    "…which is the same row the clock came from")
        }
    }
}
