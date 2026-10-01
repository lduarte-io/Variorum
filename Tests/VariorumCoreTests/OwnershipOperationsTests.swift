import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-c U2 — OWNED BOOKS, exact state transitions per op (the 13i-c plan §3;
/// the sitting record §2, §6, §18.4, §20). Every test names the rows written —
/// status, liveness, slot, stamps, tags, edges — never only a count. The §4
/// enumeration (which ROAD consults what) is `OwnershipDoorTests`'.
@Suite("13i-c U2 — owned books: own · copy in · move in · the consult · the bell")
struct OwnershipOperationsTests {
    // MARK: - Fixtures

    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    /// A note with one block of text (a copyable note).
    private func note(_ ops: Operations, _ title: String, text: String? = nil) throws -> Container {
        let post = try ops.createPost(title: title)
        try ops.seedBlock(in: post.id, text: text ?? "the text of \(title)")
        return post
    }

    /// Every row of a book's membership table, tombstones included, oldest first.
    private func rows(_ db: AppDatabase, _ readingID: String) throws -> [ReadingPost] {
        try db.read {
            try ReadingPost.fetchAll(
                $0, sql: "SELECT * FROM reading_post WHERE reading_id = ? ORDER BY rowid",
                arguments: [readingID])
        }
    }

    private func members(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    private func liveTagIDs(_ db: AppDatabase, _ postID: String) throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0, sql: """
                    SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL
                    ORDER BY created_at, id
                    """,
                arguments: [postID])
        }
    }

    private func renderedText(_ db: AppDatabase, _ postID: String) throws -> String {
        try db.read { try Queries.renderedText($0, containerID: postID) }
    }

    // MARK: - The consult (addPostToReading)

    @Test func anOwnedBookRefusesANoteThatLivesElsewhereNamingTheChoiceAndWritesNothing() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let first = try ops.createReading(name: "first", kind: .book)
            let second = try ops.createReading(name: "second", kind: .book)
            let n = try note(ops, "shared")
            try ops.addPostToReading(n.id, to: first.id)
            try ops.addPostToReading(n.id, to: second.id)
            try db.clearOutbox()

            #expect(throws: OperationError.noteMemberedElsewhere(
                postID: n.id, readingID: owned.id, elsewhere: [first.id, second.id])) {
                try ops.addPostToReading(n.id, to: owned.id)
            }
            #expect(try rows(db, owned.id).isEmpty)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
        }
    }

    @Test func aPlainBookRefusesANoteAnOwnedBookHoldsNamingTheOwner() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let plain = try ops.createReading(name: "plain", kind: .book)
            let n = try note(ops, "claimed")
            try ops.addPostToReading(n.id, to: owned.id)

            #expect(throws: OperationError.noteOwnedElsewhere(
                postID: n.id, readingID: plain.id, owner: owned.id)) {
                try ops.addPostToReading(n.id, to: plain.id)
            }
            #expect(try rows(db, plain.id).isEmpty)
        }
    }

    @Test func aBooklessNoteMovesInCleanAndAnOrdinaryNoteJoinsAPlainBookBesideItsOthers() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let a = try ops.createReading(name: "a", kind: .book)
            let b = try ops.createReading(name: "b", kind: .book)
            let bookless = try note(ops, "bookless")
            let ordinary = try note(ops, "ordinary")

            try ops.addPostToReading(bookless.id, to: owned.id)
            try ops.addPostToReading(ordinary.id, to: a.id)
            try ops.addPostToReading(ordinary.id, to: b.id)
            #expect(try members(db, owned.id) == [bookless.id])
            #expect(try members(db, a.id) == [ordinary.id])
            #expect(try members(db, b.id) == [ordinary.id])
        }
    }

    @Test func aFullBookSpeaksItsCapacityBeforeAnyOwnershipChoice() throws {
        try withOperations { ops, _ in
            let owned = try ops.createReading(name: "owned", kind: .book, maxPosts: 1)
            try ops.setReadingOwned(owned.id, owned: true)
            let other = try ops.createReading(name: "other", kind: .book)
            try ops.addPostToReading(try note(ops, "filler").id, to: owned.id)
            let shared = try note(ops, "shared")
            try ops.addPostToReading(shared.id, to: other.id)
            #expect(throws: OperationError.readingAtCapacity(id: owned.id)) {
                try ops.addPostToReading(shared.id, to: owned.id)
            }
        }
    }

    @Test func removingFromAnOwnedBookReleasesTheNoteToThePoolAndSaysSo() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let plainA = try ops.createReading(name: "a", kind: .book)
            let plainB = try ops.createReading(name: "b", kind: .book)
            let solo = try note(ops, "solo")
            try ops.addPostToReading(solo.id, to: owned.id)
            let twice = try note(ops, "twice")
            try ops.addPostToReading(twice.id, to: plainA.id)
            try ops.addPostToReading(twice.id, to: plainB.id)

            #expect(try ops.removePostFromReading(solo.id, from: owned.id) == true)
            #expect(try ops.removePostFromReading(twice.id, from: plainA.id) == false)
            let pool = try db.read { try Queries.poolListing($0, window: 50) }
            #expect(pool.loose.map(\.postID).contains(solo.id))
            #expect(!pool.loose.map(\.postID).contains(twice.id))
            // The release is a member-class decision (tombstone-means-decided).
            let released = try #require(try rows(db, owned.id).first)
            #expect(released.status == .member && released.deletedAt != nil)
        }
    }

    // MARK: - OWN (the convert door)

    @Test func owningForksEverySharedMemberIntoItsExactSlotAndLeavesSoleMembersInPlace() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "one")
            let elsewhere = try ops.createReading(name: "elsewhere", kind: .book)
            let genre = try ops.createTag(name: "genre")
            let sole = try note(ops, "sole")
            let shared = try note(ops, "shared")
            let last = try note(ops, "last")
            for n in [sole, shared, last] { try ops.addPostToReading(n.id, to: book.id) }
            try ops.assignPostToSection(shared.id, in: book.id, section: chapter.id)
            try ops.addPostToReading(shared.id, to: elsewhere.id)
            _ = try ops.applyTag(genre.id, toPost: shared.id)
            let sharedRow = try #require(try rows(db, book.id).first { $0.postId == shared.id })

            #expect(try db.read { try Queries.ownConversionPreview($0, readingID: book.id) }
                .map(\.postID) == [shared.id])
            let result = try ops.setReadingOwned(book.id, owned: true)

            let fork = try #require(result.copied.first)
            #expect(result.copied.count == 1)
            #expect(fork.originalID == shared.id)
            #expect(fork.elsewhereNames == ["elsewhere"])
            // The copy took the original's EXACT slot — position AND chapter.
            let copyRow = try #require(
                try rows(db, book.id).first { $0.postId == fork.copyID })
            #expect(copyRow.position == sharedRow.position)
            #expect(copyRow.sectionId == chapter.id)
            #expect(copyRow.status == .member && copyRow.deletedAt == nil)
            // The original left THIS book as a member-class decision…
            let originalRow = try #require(try db.read { try ReadingPost.fetchOne($0, key: sharedRow.id) })
            #expect(originalRow.deletedAt != nil && originalRow.status == .member)
            // …and keeps its other life.
            #expect(try members(db, elsewhere.id) == [shared.id])
            // The book reads as before, the copy standing in the chapter's
            // slot (chapters first, the unfiled trailing — the assembly's rule).
            #expect(try members(db, book.id) == [fork.copyID, sole.id, last.id])
            // Tags RIDE the ceremony copy (P-13ic-5), as rows.
            #expect(try liveTagIDs(db, fork.copyID) == [genre.id])
            // Lineage: one version_of anchor + per-block derived_from.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM edge WHERE type = 'version_of' AND deleted_at IS NULL") == 1)
            #expect(try renderedText(db, fork.copyID) == renderedText(db, shared.id))
            #expect(try db.read { try Reading.fetchOne($0, key: book.id) }?.owned == true)
        }
    }

    @Test func owningRefusesAGatheringAndAFinishedBookAndIsANoOpWhenOwned() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(tag.id)))
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.setReadingOwned(gathering.id, owned: true)
            }
            let finished = try ops.createReading(name: "finished", kind: .book)
            try ops.lockReading(finished.id)
            #expect(throws: OperationError.lockedReading(id: finished.id)) {
                try ops.setReadingOwned(finished.id, owned: true)
            }
            let book = try ops.createReading(name: "book", kind: .book)
            try ops.setReadingOwned(book.id, owned: true)
            try db.clearOutbox()
            #expect(try ops.setReadingOwned(book.id, owned: true).copied.isEmpty)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
            // Stop owning: the flag lifts; nothing else moves; then a no-op.
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: book.id)
            try ops.setReadingOwned(book.id, owned: false)
            #expect(try db.read { try Reading.fetchOne($0, key: book.id) }?.owned == false)
            #expect(try members(db, book.id) == [n.id])
            try db.clearOutbox()
            try ops.setReadingOwned(book.id, owned: false)
            try ops.setReadingOwned(gathering.id, owned: false)  // never owned: a no-op
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
        }
    }

    @Test func anEmptySharedMemberForksAsABareNoteWithItsTags() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            let other = try ops.createReading(name: "other", kind: .book)
            let tag = try ops.createTag(name: "t")
            let empty = try ops.createPost(title: "empty")
            try ops.addPostToReading(empty.id, to: book.id)
            try ops.addPostToReading(empty.id, to: other.id)
            _ = try ops.applyTag(tag.id, toPost: empty.id)

            let fork = try #require(try ops.setReadingOwned(book.id, owned: true).copied.first)
            let copy = try #require(try db.read { try Container.fetchOne($0, key: fork.copyID) })
            #expect(copy.title == "empty" && copy.deletedAt == nil && copy.kind == .post)
            #expect(try liveTagIDs(db, copy.id) == [tag.id])
            #expect(try members(db, book.id) == [copy.id])
            #expect(try members(db, other.id) == [empty.id])
        }
    }

    @Test func aCeremonyCopyIsBornInItsSourcesWing() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            let other = try ops.createReading(name: "other", kind: .book)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: book.id)
            try ops.addPostToReading(n.id, to: other.id)
            // Only a later phase mints a second wing; the fixture moves the
            // note and its books there raw.
            try db.write {
                try $0.execute(sql: "UPDATE container SET wing_id = 'w2' WHERE id = ?",
                               arguments: [n.id])
                try $0.execute(sql: "UPDATE reading SET wing_id = 'w2'")
            }
            let fork = try #require(try ops.setReadingOwned(book.id, owned: true).copied.first)
            #expect(try db.fetchString(
                "SELECT wing_id FROM container WHERE id = ?", [fork.copyID]) == "w2")
        }
    }

    // MARK: - COPY IN

    @Test func copyInMintsATaggedCopyAtTheAskedSpotAndLeavesTheOriginalWhole() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let plain = try ops.createReading(name: "plain", kind: .book)
            let outflow = try ops.createTag(name: "outflow")
            try ops.setReadingOutflow(plain.id, tagIDs: [outflow.id])
            let genre = try ops.createTag(name: "genre")
            let first = try note(ops, "first")
            try ops.addPostToReading(first.id, to: plain.id)
            let n = try note(ops, "claimed")
            _ = try ops.applyTag(genre.id, toPost: n.id)
            try ops.addPostToReading(n.id, to: owned.id)

            let result = try ops.copyPostIntoReading(n.id, into: plain.id, at: .before(first.id))

            #expect(try members(db, plain.id) == [result.copy.id, first.id])
            #expect(result.membership.status == .member && result.answeredArrivalID == nil)
            // Tags ride (as rows), then the book's outflow rides (a hand-add).
            #expect(try liveTagIDs(db, result.copy.id) == [genre.id, outflow.id])
            #expect(try liveTagIDs(db, n.id) == [genre.id])
            // The original is untouched where it lives.
            #expect(try members(db, owned.id) == [n.id])
            #expect(try renderedText(db, result.copy.id) == renderedText(db, n.id))
        }
    }

    @Test func aCopysRidingTagsAreNotAnActButTheOutflowIs() throws {
        // P-13ic-U2-1: the riding tags are a row copy — a living book whose
        // rule matches them does NOT hear the copy; the target's OUTFLOW is
        // an applying act and IS heard.
        try withOperations { ops, db in
            let genre = try ops.createTag(name: "genre")
            let outflow = try ops.createTag(name: "outflow")
            let hearsGenre = try ops.createReading(
                name: "hears genre", kind: .book, querySpec: try rule(.tag(genre.id)))
            let hearsOutflow = try ops.createReading(
                name: "hears outflow", kind: .book, querySpec: try rule(.tag(outflow.id)))
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let target = try ops.createReading(name: "target", kind: .book)
            try ops.setReadingOutflow(target.id, tagIDs: [outflow.id])
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: owned.id)
            _ = try ops.applyTag(genre.id, toPost: n.id)   // hears-genre BELLS n (owned elsewhere)

            let copy = try ops.copyPostIntoReading(n.id, into: target.id).copy

            #expect(try rows(db, hearsGenre.id).map(\.postId) == [n.id])   // not the copy
            #expect(try members(db, hearsOutflow.id) == [copy.id])         // the outflow's act
        }
    }

    @Test func copyInAnsweringAnArrivalDecidesThePairForGood() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let plain = try ops.createReading(
                name: "plain", kind: .book, querySpec: try rule(.tag(work.id)))
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let filler = try note(ops, "filler")
            try ops.addPostToReading(filler.id, to: plain.id)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: owned.id)
            _ = try ops.applyTag(work.id, toPost: n.id)   // the plain book bells
            let arrival = try #require(try rows(db, plain.id).first { $0.postId == n.id })
            #expect(arrival.status == .arrival)

            let result = try ops.copyPostIntoReading(answering: arrival.id)

            #expect(result.answeredArrivalID == arrival.id)
            let answered = try #require(try db.read { try ReadingPost.fetchOne($0, key: arrival.id) })
            #expect(answered.status == .member && answered.deletedAt != nil)
            #expect(try members(db, plain.id) == [filler.id, result.copy.id])   // at the END
            // A FRESH act on the original never offers a second copy (P-13ic-3).
            let sub = try ops.createTag(parent: work.id, name: "sub")
            _ = try ops.applyTag(sub.id, toPost: n.id)
            #expect(try rows(db, plain.id).filter { $0.postId == n.id && $0.deletedAt == nil }
                .isEmpty)
            #expect(throws: OperationError.arrivalNotFound(id: arrival.id)) {
                try ops.copyPostIntoReading(answering: arrival.id)
            }
        }
    }

    @Test func copyInRefusesAFinishedOrFullBookAndAGathering() throws {
        try withOperations { ops, _ in
            let n = try note(ops, "n")
            let finished = try ops.createReading(name: "finished", kind: .book)
            try ops.lockReading(finished.id)
            #expect(throws: OperationError.lockedReading(id: finished.id)) {
                try ops.copyPostIntoReading(n.id, into: finished.id)
            }
            let full = try ops.createReading(name: "full", kind: .book, maxPosts: 1)
            try ops.addPostToReading(try note(ops, "f").id, to: full.id)
            #expect(throws: OperationError.readingAtCapacity(id: full.id)) {
                try ops.copyPostIntoReading(n.id, into: full.id)
            }
            let tag = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(tag.id)))
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.copyPostIntoReading(n.id, into: gathering.id)
            }
        }
    }

    @Test func copyInUndoesAndRedoesExactRow() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let plain = try ops.createReading(name: "plain", kind: .book)
            let n = try note(ops, "n")
            let result = try ops.copyPostIntoReading(n.id, into: plain.id)
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("container", result.copy.id) != nil)
            #expect(try members(db, plain.id).isEmpty)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("container", result.copy.id) == nil)
            #expect(try members(db, plain.id) == [result.copy.id])
            #expect(try db.deletedAt("reading_post", result.membership.id) == nil)
        }
    }

    // MARK: - MOVE IN

    @Test func moveInSeversEveryOtherRowAndJoinsHere() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let a = try ops.createReading(name: "a", kind: .book)
            let living = try ops.createReading(
                name: "living", kind: .book, querySpec: try rule(.tag(work.id)),
                intakeSeating: .arrivals)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: a.id)
            _ = try ops.applyTag(work.id, toPost: n.id)   // a waiting arrival on `living`
            let aRow = try #require(try rows(db, a.id).first)
            let livingRow = try #require(try rows(db, living.id).first)
            #expect(livingRow.status == .arrival)

            let preview = try db.read {
                try Queries.moveInPreview($0, postID: n.id, into: owned.id)
            }
            #expect(preview.map(\.rowID) == [aRow.id, livingRow.id])
            #expect(preview.map(\.isArrival) == [false, true])

            let result = try ops.movePostIntoReading(n.id, into: owned.id)

            #expect(result.severed.map(\.id) == [aRow.id, livingRow.id])
            let severedA = try #require(try db.read { try ReadingPost.fetchOne($0, key: aRow.id) })
            #expect(severedA.status == .member && severedA.deletedAt != nil)   // removed for good
            let severedBell = try #require(try db.read { try ReadingPost.fetchOne($0, key: livingRow.id) })
            #expect(severedBell.status == .arrival && severedBell.deletedAt != nil)  // dismissed
            #expect(try members(db, owned.id) == [n.id])
            #expect(try db.read { try Queries.noteMemberships($0, postID: n.id) }
                .map(\.book.id) == [owned.id])
        }
    }

    @Test func moveInSeatsAWaitingArrivalHereAndAnsweringIsTheSameRow() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let owned = try ops.createReading(
                name: "owned", kind: .book, querySpec: try rule(.tag(work.id)))
            try ops.setReadingOwned(owned.id, owned: true)
            let a = try ops.createReading(name: "a", kind: .book)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: a.id)
            _ = try ops.applyTag(work.id, toPost: n.id)   // owned book bells a membered note
            let bell = try #require(try rows(db, owned.id).first)
            #expect(bell.status == .arrival)
            #expect(throws: OperationError.noteMemberedElsewhere(
                postID: n.id, readingID: owned.id, elsewhere: [a.id])) {
                try ops.seatArrival(bell.id)
            }

            let result = try ops.movePostIntoReading(answering: bell.id)

            #expect(result.membership.id == bell.id)
            #expect(result.membership.status == .member)
            #expect(try members(db, owned.id) == [n.id])
            #expect(try members(db, a.id).isEmpty)
        }
    }

    @Test func moveInRefusesToSeverAFinishedBooksMembership() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let done = try ops.createReading(name: "done", kind: .book)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: done.id)
            try ops.lockReading(done.id)
            #expect(try db.read { try Queries.moveInPreview($0, postID: n.id, into: owned.id) }
                .map(\.finished) == [true])
            #expect(throws: OperationError.lockedReading(id: done.id)) {
                try ops.movePostIntoReading(n.id, into: owned.id)
            }
            #expect(try members(db, done.id) == [n.id])
            #expect(try rows(db, owned.id).isEmpty)
            // Copy in stays open.
            _ = try ops.copyPostIntoReading(n.id, into: owned.id)
        }
    }

    @Test func moveInClaimsANoteOutOfTheDailyJournal() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let journalID) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("expected the entry shelved"); return
            }
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let result = try ops.movePostIntoReading(entry.id, into: owned.id)
            #expect(result.severed.map(\.readingId) == [journalID])
            #expect(try members(db, journalID).isEmpty)
            // The Journal's pair is decided: the daily door never re-shelves it.
            #expect(ops.shelveInDailyJournalBook(entry.id) == .alreadyDecided)
        }
    }

    // MARK: - The daily Journal's bell (§6)

    @Test func theDailyDoorBellsAnEntryAnotherBookOwnsAndNeverThrows() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-02").container
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            try ops.addPostToReading(entry.id, to: owned.id)

            let outcome = ops.shelveInDailyJournalBook(entry.id)

            let journalID = try #require(try db.read { try Queries.dailyJournalBookID($0) })
            #expect(outcome == .waitingAtDoor(readingID: journalID))
            let bell = try #require(try rows(db, journalID).first)
            #expect(bell.postId == entry.id && bell.status == .arrival && bell.deletedAt == nil)
            #expect(try members(db, owned.id) == [entry.id])
            // Rung once: the pair is now decided.
            #expect(ops.shelveInDailyJournalBook(entry.id) == .alreadyDecided)
        }
    }

    @Test func anOwnedDailyJournalBellsAnEntryThatLivesElsewhere() throws {
        try withOperations { ops, db in
            let first = try ops.createOrOpenJournalEntry(entryDate: "2026-07-03").container
            guard case .shelved(let journalID) = ops.shelveInDailyJournalBook(first.id) else {
                Issue.record("expected the first entry shelved"); return
            }
            try ops.setReadingOwned(journalID, owned: true)   // "a perfectly acceptable choice"
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-04").container
            let other = try ops.createReading(name: "other", kind: .book)
            try ops.addPostToReading(entry.id, to: other.id)

            #expect(ops.shelveInDailyJournalBook(entry.id) == .waitingAtDoor(readingID: journalID))
            #expect(try rows(db, journalID).last?.status == .arrival)
        }
    }
}
