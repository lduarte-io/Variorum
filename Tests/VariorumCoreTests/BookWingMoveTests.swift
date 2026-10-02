import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U5b — **THE PER-ITEM BOOK MOVE** (`moveReadingToWing`; R-13id-6
/// items 1–7, the U5 RECORD's proposal RULED whole). A new op — its pins are
/// exact state transitions, one per ruled item: the sever-and-list arithmetic
/// (the confirm's list IS the act's), a stay-behind finished/sealed book
/// refusing with nothing written, finished/sealed books riding whole with
/// every stamp untouched, archived members riding archived, pending arrivals
/// dismissed as decision rows, the rule/outflow/grouping adopting by path
/// (adopt vs mint; a dead term untouched), the unshelved + starred landing,
/// the daily Journal's refusal (designation and marker), the plain refusals,
/// and no undo registration.
@Suite("13i-d U5b — move a book to another wing")
struct BookWingMoveTests {
    private func wingOf(_ db: AppDatabase, post: String) throws -> String? {
        try db.read { try Queries.effectiveWing($0, ofPost: post) }
    }

    private func reading(_ db: AppDatabase, _ id: String) throws -> Reading {
        try #require(try db.read { try Reading.fetchOne($0, key: id) })
    }

    private func liveRows(_ db: AppDatabase, reading: String, status: String = "member") throws -> Int {
        try db.fetchInt(
            "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND status = ? AND deleted_at IS NULL",
            [reading, status]) ?? 0
    }

    private func liveTag(_ db: AppDatabase, wing: String, path: String) throws -> VariorumCore.Tag? {
        try db.read {
            try VariorumCore.Tag.fetchOne(
                $0, sql: "SELECT * FROM tag WHERE wing_id = ? AND path = ? AND deleted_at IS NULL",
                arguments: [wing, path])
        }
    }

    /// Items 1(a) + 4: the book moves WITH its member notes (an archived one
    /// rides archived); a member's membership in a book that STAYS behind is
    /// SEVERED — and the confirm listed exactly what the act severed. The
    /// destination's same-named book is named, never refused (8(a)'s letter).
    @Test func theBookMovesWithItsMembersAndSeversWhatStaysBehind() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            _ = try ops.createReading(name: "ALPHA", kind: .book, wingId: wing.id)
            let alpha = try ops.createReading(name: "Alpha", kind: .book)
            let beta = try ops.createReading(name: "Beta", kind: .book)
            let one = try ops.createPost(title: "one")
            let two = try ops.createPost(title: "two")
            let three = try ops.createPost(title: "three")
            for note in [one, two, three] { _ = try ops.addPostToReading(note.id, to: alpha.id) }
            _ = try ops.addPostToReading(three.id, to: beta.id)
            try ops.archiveContainer(two.id)

            let preview = try #require(try db.read {
                try Queries.bookWingMovePreview($0, readingID: alpha.id, to: wing.id)
            })
            #expect(preview.notes == 3 && preview.archived == 1)
            #expect(preview.alsoLeaves == [Queries.AlsoLeaves(note: "three", book: "Beta")])
            #expect(preview.frozen == nil && preview.waiting == 0 && !preview.isDailyJournal)
            #expect(preview.nameTakenBy == "ALPHA", "the destination's twin name is named")

            let result = try ops.moveReadingToWing(alpha.id, to: wing.id)
            #expect(result.notes == 3)
            #expect(result.alsoLeft == preview.alsoLeaves, "the confirm's list IS the act's")
            #expect(try reading(db, alpha.id).wingId == wing.id)
            for note in [one, two, three] { #expect(try wingOf(db, post: note.id) == wing.id) }
            #expect(try liveRows(db, reading: alpha.id) == 3, "the members ride with their book")
            #expect(try liveRows(db, reading: beta.id) == 0, "the stay-behind membership is severed")
            #expect(try db.read { try Container.fetchOne($0, key: two.id) }?.archivedAt != nil,
                    "an archived member rides archived (item 4)")
            #expect(try reading(db, beta.id).wingId == "", "the book that stays, stays")
        }
    }

    /// Item 3(a)'s own clause: a member's stay-behind MEMBER row in a
    /// FINISHED book refuses the whole move (the confirm names it first);
    /// in a SEALED one likewise; nothing is written either way.
    @Test func aStayBehindFinishedOrSealedBookRefusesAndWritesNothing() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let alpha = try ops.createReading(name: "Alpha", kind: .book)
            let beta = try ops.createReading(name: "Beta", kind: .book)
            let three = try ops.createPost(title: "three")
            _ = try ops.seedBlock(in: three.id, text: "words")
            _ = try ops.addPostToReading(three.id, to: alpha.id)
            _ = try ops.addPostToReading(three.id, to: beta.id)
            try ops.lockReading(beta.id)
            #expect(try db.read {
                try Queries.bookWingMovePreview($0, readingID: alpha.id, to: wing.id)
            }?.frozen == Queries.AlsoLeaves(note: "three", book: "Beta"))
            let before = try db.snapshotRow("reading", alpha.id, excluding: [])
            #expect(throws: OperationError.lockedReading(id: beta.id)) {
                try ops.moveReadingToWing(alpha.id, to: wing.id)
            }
            #expect(try db.snapshotRow("reading", alpha.id, excluding: []) == before)
            #expect(try wingOf(db, post: three.id) == "")
            #expect(try liveRows(db, reading: beta.id) == 1, "a refusal severs nothing")

            // SEALED: a sealed Gamma holds `four`; `four` then joins Alpha too.
            try ops.unlockReading(beta.id)
            let gamma = try ops.createReading(name: "Gamma", kind: .book)
            let four = try ops.createPost(title: "four")
            _ = try ops.seedBlock(in: four.id, text: "sealed words")
            _ = try ops.addPostToReading(four.id, to: gamma.id)
            _ = try ops.sealReading(gamma.id)
            _ = try ops.addPostToReading(four.id, to: alpha.id)
            #expect(throws: OperationError.readingSealed(id: gamma.id)) {
                try ops.moveReadingToWing(alpha.id, to: wing.id)
            }
            #expect(try reading(db, alpha.id).wingId == "")
        }
    }

    /// Item 3(a): a FINISHED book and a SEALED book each move WHOLE — the
    /// finish and the seal stay, and every member's exact-stamp seal is
    /// untouched (a wing move is metadata, never authoring).
    @Test func finishedAndSealedBooksMoveWholeWithTheirStampsUntouched() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let done = try ops.createReading(name: "Done", kind: .book)
            let kept = try ops.createPost(title: "kept")
            _ = try ops.addPostToReading(kept.id, to: done.id)
            try ops.lockReading(done.id)
            _ = try ops.moveReadingToWing(done.id, to: wing.id)
            #expect(try reading(db, done.id).locked, "finished stays finished")
            #expect(try wingOf(db, post: kept.id) == wing.id)

            let edition = try ops.createReading(name: "Edition", kind: .book)
            let page = try ops.createPost(title: "page")
            _ = try ops.seedBlock(in: page.id, text: "immutable words")
            _ = try ops.addPostToReading(page.id, to: edition.id)
            _ = try ops.sealReading(edition.id)
            let sealedAt = try reading(db, edition.id).sealedAt
            let pageBefore = try #require(try db.read { try Container.fetchOne($0, key: page.id) })
            #expect(pageBefore.locked && sealedAt != nil)
            _ = try ops.moveReadingToWing(edition.id, to: wing.id)
            let after = try reading(db, edition.id)
            #expect(after.sealedAt == sealedAt && after.locked, "sealed stays sealed, same stamp")
            let pageAfter = try #require(try db.read { try Container.fetchOne($0, key: page.id) })
            #expect(pageAfter.locked && pageAfter.lockedAt == pageBefore.lockedAt,
                    "the member's exact-stamp seal is untouched")
            #expect(pageAfter.wingId == wing.id)
        }
    }

    /// Item 5(a): the book's PENDING ARRIVALS are dismissed in the move — the
    /// rows tombstone as decision records (status 'arrival'); the waiting
    /// notes stay behind; the confirm's count is the act's.
    @Test func itsPendingArrivalsAreDismissedAsDecisionRows() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let tag = try ops.createTag(name: "classics")
            let living = try ops.createReading(
                name: "Living", kind: .book,
                querySpec: try #require(try RuleGrammar.encode(.tag(tag.id))),
                intakeSeating: .arrivals)
            let waiter = try ops.createPost(title: "waiter")
            try ops.applyTag(tag.id, toPost: waiter.id)
            #expect(try liveRows(db, reading: living.id, status: "arrival") == 1)
            #expect(try db.read {
                try Queries.bookWingMovePreview($0, readingID: living.id, to: wing.id)
            }?.waiting == 1)

            let result = try ops.moveReadingToWing(living.id, to: wing.id)
            #expect(result.dismissedArrivals == 1)
            #expect(try liveRows(db, reading: living.id, status: "arrival") == 0)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM reading_post
                WHERE reading_id = ? AND post_id = ? AND status = 'arrival' AND deleted_at IS NOT NULL
                """, [living.id, waiter.id]) == 1, "a decision record — tombstone-means-decided")
            #expect(try wingOf(db, post: waiter.id) == "", "the waiting note stays behind")
        }
    }

    /// Item 2(a): the rule's tag terms, the outflow and the grouping tag adopt
    /// BY PATH — `writing/draft` adopts the destination's own, `poems` and
    /// `classics` are MINTED there; a DEAD term stays exactly as it was. A
    /// GATHERING moves alone and shows the destination's matches at once.
    /// The source wing's vocabulary stays (only the bulk move retires it).
    @Test func theRuleOutflowAndGroupingAdoptByPathAndAGatheringShowsTheDestination() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let writing = try ops.createTag(name: "writing")
            let draft = try ops.createTag(parent: writing.id, name: "draft")
            let poems = try ops.createTag(name: "poems")
            let classics = try ops.createTag(name: "classics")
            let gone = try ops.createTag(name: "gone")
            try ops.deleteTag(gone.id)
            let destWriting = try ops.createTag(name: "writing", wingID: wing.id)
            let destDraft = try ops.createTag(parent: destWriting.id, name: "draft")

            let rule = RuleTerm.and([.or([.tag(draft.id), .tag(poems.id)]), .not(.tag(gone.id)), .star])
            let book = try ops.createReading(
                name: "Ruled", kind: .book, groupingTagId: writing.id,
                querySpec: try RuleGrammar.encode(rule), autoTagIDs: [classics.id])
            let result = try ops.moveReadingToWing(book.id, to: wing.id)
            let destPoems = try #require(try liveTag(db, wing: wing.id, path: "poems"))
            let destClassics = try #require(try liveTag(db, wing: wing.id, path: "classics"))
            let moved = try reading(db, book.id)
            #expect(RuleGrammar.decode(moved.querySpec)
                    == .and([.or([.tag(destDraft.id), .tag(destPoems.id)]), .not(.tag(gone.id)), .star]),
                    "same shape; live terms by path; the dead term untouched")
            #expect(moved.autoTagIDs == [destClassics.id])
            #expect(moved.groupingTagId == destWriting.id)
            #expect(result.mintedTags == 2, "poems and classics are made in the destination")
            #expect(try db.deletedAt("tag", poems.id) == nil, "the source's vocabulary stays")

            // A gathering: alone, and at once the destination's matches.
            let gathering = try ops.createReading(
                name: "Classics", kind: .gathering,
                querySpec: try #require(try RuleGrammar.encode(.tag(classics.id))))
            let homeNote = try ops.createPost(title: "home classic")
            try ops.applyTag(classics.id, toPost: homeNote.id)
            let awayNote = try ops.createPost(title: "away classic", wingId: wing.id)
            try ops.applyTag(destClassics.id, toPost: awayNote.id)
            _ = try ops.moveReadingToWing(gathering.id, to: wing.id)
            let shown = try db.read { try Queries.assembleReading($0, readingID: gathering.id) }
            #expect(shown.map(\.postID) == [awayNote.id], "the destination's matches, never Home's")
            #expect(try wingOf(db, post: homeNote.id) == "", "a gathering carries no notes")
        }
    }

    /// Item 6: it lands UNSHELVED (shelf and hand position cleared — shelves
    /// never cross wings) and its STAR stays (both stores of the union).
    @Test func itLandsUnshelvedAndKeepsItsStar() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let shelf = try ops.createShelf(name: "The Work")
            _ = try ops.createReading(name: "A sibling", kind: .book, shelfId: shelf.id)
            let book = try ops.createReading(name: "Placed", kind: .book, shelfId: shelf.id)
            try ops.placeReading(book.id, at: .top)
            try ops.setStarred(.reading(book.id), starred: true)
            #expect(try reading(db, book.id).shelfPosition != nil)
            _ = try ops.moveReadingToWing(book.id, to: wing.id)
            let moved = try reading(db, book.id)
            #expect(moved.shelfId == nil && moved.shelfPosition == nil, "unshelved")
            #expect(moved.starred)
            #expect(try db.read { try Queries.starredReadingIDs($0) }.contains(book.id),
                    "the star's union holds")
        }
    }

    /// Item 7: the daily Journal never moves — the designated book refuses,
    /// and so does a book wearing the 'daily' marker; nothing is written.
    @Test func theDailyJournalNeverMoves() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-10-02").container
            _ = ops.shelveInDailyJournalBook(entry.id)
            let journalID = try #require(try ops.dailyJournalBookID())
            #expect(try db.read {
                try Queries.bookWingMovePreview($0, readingID: journalID, to: wing.id)
            }?.isDailyJournal == true)
            #expect(throws: OperationError.dailyJournalIsHomeOnly(id: journalID)) {
                try ops.moveReadingToWing(journalID, to: wing.id)
            }
            #expect(try reading(db, journalID).wingId == "")
            #expect(try wingOf(db, post: entry.id) == "")
            // The marker alone answers too (a 'daily' book not designated).
            let marked = try ops.createReading(
                name: "Old Journal", kind: .book, profile: Queries.dailyJournalBookProfile)
            #expect(throws: OperationError.dailyJournalIsHomeOnly(id: marked.id)) {
                try ops.moveReadingToWing(marked.id, to: wing.id)
            }
        }
    }

    /// The plain refusals, and NO undo entry (item 8: the symmetric door is
    /// the net — moving back works and restores the book's wing).
    @Test func theRefusalsHoldAndNothingRegistersUndo() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let wing = try ops.createWing(name: "Imports")
            let book = try ops.createReading(name: "Here", kind: .book)
            let note = try ops.createPost(title: "n")
            _ = try ops.addPostToReading(note.id, to: book.id)
            #expect(throws: OperationError.readingAlreadyInWing(readingID: book.id, wingID: "")) {
                try ops.moveReadingToWing(book.id, to: "")
            }
            #expect(throws: OperationError.wingNotFound(id: "nowhere")) {
                try ops.moveReadingToWing(book.id, to: "nowhere")
            }
            let depth = stack.depth
            _ = try ops.moveReadingToWing(book.id, to: wing.id)
            #expect(stack.depth == depth, "no structural-undo entry")
            _ = try ops.moveReadingToWing(book.id, to: "")
            #expect(try reading(db, book.id).wingId == "", "the symmetric door moves it back")
            #expect(try wingOf(db, post: note.id) == "")
            #expect(try liveRows(db, reading: book.id) == 1)
        }
    }
}
