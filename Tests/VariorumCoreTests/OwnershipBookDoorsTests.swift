import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-c U2 — the BOOK-level ownership doors, exact state transitions (the
/// 13i-c plan §3's revival pass and bind limb, §6's delete · duplicate · the
/// Trash; the sitting record §3, §6, §18.3). Every test names the rows.
@Suite("13i-c U2 — the revival pass · the bind's owned limb · delete · duplicate · the Trash")
struct OwnershipBookDoorsTests {
    // MARK: - Fixtures

    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        try ops.seedBlock(in: post.id, text: "the text of \(title)")
        return post
    }

    private func ownedBook(_ ops: Operations, _ name: String) throws -> Reading {
        let book = try ops.createReading(name: name, kind: .book)
        try ops.setReadingOwned(book.id, owned: true)
        return book
    }

    private func members(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    /// The pair's one row (live or not), newest first.
    private func pair(_ db: AppDatabase, _ readingID: String, _ postID: String) throws -> ReadingPost? {
        try db.read {
            try ReadingPost.fetchOne(
                $0, sql: """
                    SELECT * FROM reading_post WHERE reading_id = ? AND post_id = ?
                    ORDER BY rowid DESC LIMIT 1
                    """,
                arguments: [readingID, postID])
        }
    }

    private func liveTagIDs(_ db: AppDatabase, _ postID: String) throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                arguments: [postID])
        }
    }

    // MARK: - The revival pass, per door (the plan §4 rows 7–9)

    @Test func restoringAnOwnedBookKeepsItsEarlierClaimAndTombstonesTheLaterPlainAdd() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: owned.id)
            try ops.deleteReading(owned.id)           // book only: n → the Pool
            let plain = try ops.createReading(name: "plain", kind: .book)
            try ops.addPostToReading(n.id, to: plain.id)

            try ops.restoreReading(owned.id)

            #expect(try members(db, owned.id) == [n.id])        // the earlier claim stands
            let later = try #require(try pair(db, plain.id, n.id))
            #expect(later.deletedAt != nil && later.status == .member)   // recoverable
        }
    }

    @Test func restoringAPlainBookBellsTheLaterOwnedClaim() throws {
        try withOperations { ops, db in
            let plain = try ops.createReading(name: "plain", kind: .book)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: plain.id)
            try ops.deleteReading(plain.id)
            let owned = try ownedBook(ops, "owned")
            try ops.addPostToReading(n.id, to: owned.id)

            try ops.restoreReading(plain.id)

            #expect(try members(db, plain.id) == [n.id])        // the earlier membership stands
            let claim = try #require(try pair(db, owned.id, n.id))
            #expect(claim.deletedAt == nil && claim.status == .arrival)   // the bell
            #expect(try members(db, owned.id).isEmpty)
        }
    }

    @Test func restoringANoteRevivesItsMembershipsUnderTheOwnershipRule() throws {
        try withOperations { ops, db in
            let first = try ops.createReading(name: "first", kind: .book)
            let second = try ops.createReading(name: "second", kind: .book)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: first.id)
            try ops.addPostToReading(n.id, to: second.id)
            try ops.deleteContainer(n.id)
            try ops.setReadingOwned(first.id, owned: true)   // n is dead: nothing forks

            try ops.restoreContainer(n.id)

            #expect(try members(db, first.id) == [n.id])        // the earliest, owned, stands
            #expect(try pair(db, second.id, n.id)?.deletedAt != nil)
        }
    }

    @Test func theBindsRedoBellsAClaimMadeSinceTheUndo() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let n = try note(ops, "n")
            _ = try ops.applyTag(t.id, toPost: n.id)
            try ops.convertSmartReadingToCurated(gathering.id)
            _ = try stack.undo(with: ops)                  // the row is taken; n is bookless
            let owned = try ownedBook(ops, "owned")
            try ops.addPostToReading(n.id, to: owned.id)

            _ = try stack.redo(with: ops)

            #expect(try members(db, gathering.id) == [n.id])    // the earlier (bind) row stands
            #expect(try pair(db, owned.id, n.id)?.status == .arrival)
        }
    }

    @Test func theDivergeUndoBellsAClaimMadeSinceTheDiverge() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let plain = try ops.createReading(name: "plain", kind: .book)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: plain.id)
            let diverge = try ops.divergePostForReading(n.id, in: plain.id)
            let owned = try ownedBook(ops, "owned")
            try ops.addPostToReading(n.id, to: owned.id)   // n left `plain` with the diverge

            _ = try stack.undo(with: ops)

            #expect(try members(db, plain.id) == [n.id])
            #expect(try pair(db, owned.id, n.id)?.status == .arrival)
            #expect(try db.deletedAt("container", diverge.copy.post.id) != nil)
            // …and the redo re-diverges exact-row, the claim still belled.
            _ = try stack.redo(with: ops)
            #expect(try members(db, plain.id) == [diverge.copy.post.id])
            #expect(try pair(db, owned.id, n.id)?.status == .arrival)
        }
    }

    @Test func theRevivalPassIsIdempotentAndTouchesNothingLegal() throws {
        try withOperations { ops, db in
            let a = try ops.createReading(name: "a", kind: .book)
            let b = try ops.createReading(name: "b", kind: .book)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: a.id)
            try ops.addPostToReading(n.id, to: b.id)
            try db.clearOutbox()
            try db.write { database in
                try ops.enforceOwnershipAfterRevival(database, postIDs: [n.id, n.id], now: Date())
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)   // plain + plain: legal
            #expect(try members(db, a.id) == [n.id] && members(db, b.id) == [n.id])
        }
    }

    // MARK: - The bind's owned-notes limb (the plan §4 row 6)

    @Test func theBindLeavesOwnedNotesOutByDefaultAndListsThemFirst() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let owned = try ownedBook(ops, "owned")
            let free = try note(ops, "free")
            let claimed = try note(ops, "claimed")
            try ops.addPostToReading(claimed.id, to: owned.id)
            for n in [free, claimed] { _ = try ops.applyTag(t.id, toPost: n.id) }

            let preview = try db.read { try Queries.bindOwnedNotesPreview($0, readingID: gathering.id) }
            #expect(preview.map(\.postID) == [claimed.id])
            #expect(preview.first?.owner == Queries.BookRef(id: owned.id, name: "owned"))

            let result = try ops.convertSmartReadingToCurated(gathering.id)

            #expect(result.leftOut == [claimed.id] && result.copied.isEmpty)
            #expect(try members(db, gathering.id) == [free.id])
            #expect(try members(db, owned.id) == [claimed.id])
            #expect(try pair(db, gathering.id, claimed.id) == nil)   // nothing written for it
        }
    }

    @Test func theBindsCopyInLimbSeatsATaggedCopyInTheNotesSlot() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let owned = try ownedBook(ops, "owned")
            let claimed = try note(ops, "claimed")
            try ops.addPostToReading(claimed.id, to: owned.id)
            let free = try note(ops, "free")
            for n in [claimed, free] { _ = try ops.applyTag(t.id, toPost: n.id) }

            let result = try ops.convertSmartReadingToCurated(gathering.id, ownedNotes: .copyIn)

            let fork = try #require(result.copied.first)
            #expect(fork.originalID == claimed.id && fork.elsewhereNames == ["owned"])
            #expect(try members(db, gathering.id) == [fork.copyID, free.id])   // the slot kept
            #expect(try liveTagIDs(db, fork.copyID) == [t.id])
            #expect(try members(db, owned.id) == [claimed.id])
        }
    }

    // MARK: - Delete · the Trash · restore WHOLE (the plan §6)

    @Test func deletingAnOwnedBookWithItsNotesIsOneStampAndPutBackReturnsItWhole() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            let chapter = try ops.createSection(in: owned.id, name: "one")
            let a = try note(ops, "a")
            let b = try note(ops, "b")
            try ops.addPostToReading(a.id, to: owned.id)
            try ops.addPostToReading(b.id, to: owned.id)
            try ops.assignPostToSection(b.id, in: owned.id, section: chapter.id)
            let version = try ops.saveNoteVersion(a.id).post

            let deleted = try ops.deleteReadingWithNotes(owned.id)

            #expect(deleted == [a.id, b.id])
            let stamp = try #require(try db.deletedAt("reading", owned.id))
            for id in [a.id, b.id, version.id] {
                #expect(try db.deletedAt("container", id) == stamp)   // ONE stamp
            }
            #expect(try db.read { try Queries.trashBookNoteCount($0, readingID: owned.id) } == 2)
            let trash = try db.read { try Queries.trash($0, now: harnessNow) }
            #expect(Set(trash.filter { $0.kind == .note }.map(\.id)).isSuperset(of: [a.id, b.id]))
            #expect(trash.contains { $0.kind == .book && $0.id == owned.id })

            try ops.restoreReading(owned.id)

            #expect(try members(db, owned.id) == [b.id, a.id])   // the chapter first, as before
            #expect(try db.deletedAt("container", version.id) == nil)   // versions ride home
            #expect(try db.deletedAt("reading_section", chapter.id) == nil)
            #expect(try db.read { try Queries.trashBookNoteCount($0, readingID: owned.id) } == 0)
        }
    }

    @Test func aNotePutBackAloneComesBackBooklessUntilTheBookReturns() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            let a = try note(ops, "a")
            try ops.addPostToReading(a.id, to: owned.id)
            try ops.deleteReadingWithNotes(owned.id)

            try ops.restoreContainer(a.id)
            #expect(try db.read { try Queries.poolListing($0, window: 10) }.loose
                .map(\.postID) == [a.id])

            try ops.restoreReading(owned.id)
            #expect(try members(db, owned.id) == [a.id])
        }
    }

    @Test func deletingBookOnlyReleasesAnOwnedBooksNotesToThePoolAndRefusalsHold() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            let a = try note(ops, "a")
            try ops.addPostToReading(a.id, to: owned.id)
            try ops.deleteReading(owned.id)
            #expect(try db.deletedAt("container", a.id) == nil)
            #expect(try db.read { try Queries.poolListing($0, window: 10) }.loose
                .map(\.postID) == [a.id])
            #expect(try db.read { try Queries.trashBookNoteCount($0, readingID: owned.id) } == 0)

            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.deleteReadingWithNotes(gathering.id)
            }
        }
    }

    // MARK: - Duplicate (the plan §6, §4 row 12)

    @Test func aShallowDuplicateCopiesTheConfigurationAndPointsAtTheSameNotes() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let out = try ops.createTag(name: "out")
            let source = try ops.createReading(
                name: "source", kind: .book, querySpec: try rule(.tag(t.id)),
                maxPosts: 9, wordTarget: 5000, intakeSeating: .arrivals, autoTagIDs: [out.id])
            try ops.setStarred(.reading(source.id), starred: true)
            let chapter = try ops.createSection(in: source.id, name: "one")
            let a = try note(ops, "a")
            let b = try note(ops, "b")
            try ops.addPostToReading(a.id, to: source.id)
            try ops.addPostToReading(b.id, to: source.id)
            try ops.assignPostToSection(b.id, in: source.id, section: chapter.id)
            let waiting = try note(ops, "waiting")
            _ = try ops.applyTag(t.id, toPost: waiting.id)   // an arrival (the dial)
            try ops.lockReading(source.id)

            let result = try ops.duplicateReading(source.id, name: "copy", deep: false)
            let dup = result.reading

            #expect(dup.kind == .book && dup.name == "copy" && dup.wingId == source.wingId)
            #expect(dup.querySpec == source.querySpec && dup.maxPosts == 9 && dup.wordTarget == 5000)
            #expect(dup.intakeSeating == .arrivals && dup.autoTagIDs == [out.id])
            #expect(!dup.locked && dup.sealedAt == nil && !dup.owned && !dup.starred)
            #expect(dup.shelfId == nil && dup.shelfPosition == nil)
            #expect(result.copied.isEmpty)
            #expect(try members(db, dup.id) == [b.id, a.id])   // same notes, same shape
            let dupChapter = try #require(try db.read {
                try ReadingSection.fetchOne(
                    $0, sql: "SELECT * FROM reading_section WHERE reading_id = ?",
                    arguments: [dup.id])
            })
            #expect(dupChapter.name == "one" && dupChapter.position == chapter.position)
            #expect(try pair(db, dup.id, b.id)?.sectionId == dupChapter.id)
            #expect(try pair(db, dup.id, waiting.id) == nil)   // arrivals never
            #expect(try members(db, source.id) == [b.id, a.id])
        }
    }

    @Test func anOwnedBookDuplicatesOnlyWithCopiesAndTheDuplicateIsBornPlain() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            let t = try ops.createTag(name: "t")
            let a = try note(ops, "a")
            try ops.addPostToReading(a.id, to: owned.id)
            _ = try ops.applyTag(t.id, toPost: a.id)
            #expect(throws: OperationError.ownedBookDuplicatesDeep(id: owned.id)) {
                try ops.duplicateReading(owned.id, name: "shallow", deep: false)
            }

            let result = try ops.duplicateReading(owned.id, name: "deep", deep: true)

            let fork = try #require(result.copied.first)
            #expect(fork.originalID == a.id)
            #expect(try members(db, result.reading.id) == [fork.copyID])
            #expect(try members(db, owned.id) == [a.id])
            #expect(!result.reading.owned)
            #expect(try liveTagIDs(db, fork.copyID) == [t.id])
        }
    }

    @Test func theDailyJournalsDuplicateWearsTheTraitNotTheMarkerAndAGatheringRefuses() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let journalID) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("expected the entry shelved"); return
            }
            let dup = try ops.duplicateReading(journalID, name: "Journal 2", deep: false).reading
            #expect(dup.profile == Queries.journalTraitProfile)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == journalID)

            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.duplicateReading(gathering.id, name: "x", deep: true)
            }
        }
    }
}
