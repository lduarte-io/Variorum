import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-803 — `setMembershipPinned`, exact state transitions** (the B4 fork's
/// ruling, A-808-12 in `notes/plans/fixes/vx-808-arrivals-books.md`): the pin
/// is identity-level membership metadata — `pinned_at` := now / NULL and
/// nothing else; no touch, no churn, no `reading.updated_at`, no undo entry;
/// a no-op writes nothing; a gathering refuses `wrongReadingKind` first; a
/// finished or sealed book refuses `lockedReading` (P-808-B4-1); an arrival is
/// no member; and the exact-slot copies carry the pin (A-808-12 (f)).
///
/// New capability: no pre-fix code wrote `pinned_at`, so there is no
/// red-on-old — these pin the ruled posture row by row.
@Suite("VX-803 — setMembershipPinned's state transitions")
struct MembershipPinOperationTests {
    private struct Fixture {
        let book: Reading
        let a: Container
        let b: Container
    }

    private func fixture(_ ops: Operations) throws -> Fixture {
        let book = try ops.createReading(name: "pins", kind: .book)
        let a = try ops.createPost(title: "a")
        let b = try ops.createPost(title: "b")
        try ops.addPostToReading(a.id, to: book.id)
        try ops.addPostToReading(b.id, to: book.id)
        return Fixture(book: book, a: a, b: b)
    }

    private func membership(_ db: AppDatabase, _ postID: String, _ readingID: String) throws -> ReadingPost {
        try #require(try db.read {
            try ReadingPost
                .filter(Column("reading_id") == readingID && Column("post_id") == postID
                    && Column("deleted_at") == nil)
                .fetchOne($0)
        })
    }

    private func clearOutbox(_ db: AppDatabase) throws {
        try db.write { try $0.execute(sql: "DELETE FROM sync_outbox") }
    }

    private func outbox(_ db: AppDatabase) throws -> [String] {
        try db.read {
            try String.fetchAll($0, sql: "SELECT table_name || ':' || row_id FROM sync_outbox ORDER BY 1")
        }
    }

    /// The raw stored text of a column, so "untouched" is byte-exact.
    private func raw(_ db: AppDatabase, _ table: String, _ column: String, _ id: String) throws -> String? {
        try db.read {
            try String.fetchOne($0, sql: "SELECT \(column) FROM \(table) WHERE id = ?", arguments: [id])
        }
    }

    // MARK: - The writes

    /// A pin stamps `pinned_at` with the injected clock's now and changes
    /// NOTHING else: the row's position, chapter, status and life; the note's
    /// touch, churn and updated stamps; the book's `updated_at`. One outbox
    /// row: the membership's.
    @Test func aPinStampsPinnedAtAndNothingElse() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            let before = try membership(db, f.a.id, f.book.id)
            let note = try db.read { try Container.fetchOne($0, key: f.a.id) }
            let bookStamp = try raw(db, "reading", "updated_at", f.book.id)
            try clearOutbox(db)

            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)

            let after = try membership(db, f.a.id, f.book.id)
            let stamp = try #require(after.pinnedAt)
            #expect(stamp > before.createdAt, "the stamp is the op's own now")
            var expected = before
            expected.pinnedAt = stamp
            #expect(after == expected, "only pinned_at moved")
            #expect(try db.read { try Container.fetchOne($0, key: f.a.id) } == note,
                    "no touch, no churn, no updated_at on the note")
            #expect(try raw(db, "reading", "updated_at", f.book.id) == bookStamp,
                    "the book's updated_at is untouched (the membership siblings' posture)")
            #expect(try outbox(db) == ["reading_post:\(after.id)"])
            #expect(try membership(db, f.b.id, f.book.id).pinnedAt == nil, "the other member is untouched")
        }
    }

    /// An unpin clears the stamp to NULL — one outbox row, nothing else.
    @Test func anUnpinClearsTheStamp() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            var expected = try membership(db, f.a.id, f.book.id)
            try clearOutbox(db)

            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: false)

            expected.pinnedAt = nil
            #expect(try membership(db, f.a.id, f.book.id) == expected)
            #expect(try raw(db, "reading_post", "pinned_at", expected.id) == nil)
            #expect(try outbox(db) == ["reading_post:\(expected.id)"])
        }
    }

    /// No-op guarded both ways: pinning a pinned row keeps its ORIGINAL
    /// since-when and writes nothing; unpinning an unpinned row writes nothing.
    @Test func aNoOpWritesNothingEitherWay() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            let pinned = try membership(db, f.a.id, f.book.id)
            try clearOutbox(db)

            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            try ops.setMembershipPinned(f.b.id, in: f.book.id, pinned: false)

            #expect(try membership(db, f.a.id, f.book.id) == pinned, "the first pin's stamp stands")
            #expect(try membership(db, f.b.id, f.book.id).pinnedAt == nil)
            #expect(try outbox(db).isEmpty, "a write that changes nothing writes nothing")
        }
    }

    /// Several pins are allowed (her ruling) — each its own stamp.
    @Test func severalPinsStandTogether() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            try ops.setMembershipPinned(f.b.id, in: f.book.id, pinned: true)
            #expect(try membership(db, f.a.id, f.book.id).pinnedAt != nil)
            #expect(try membership(db, f.b.id, f.book.id).pinnedAt != nil)
        }
    }

    /// No undo entry (the `assignPostToSection` / `setStarred` class — Unpin is
    /// the way back), and the redo future is left alone.
    @Test func aPinRegistersNoUndoAndKeepsTheRedoFuture() throws {
        let stack = UndoStack()
        try withOperations { _, _ in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "p")
            _ = try ops.newBlock(in: post.id, text: "one", at: .end)
            _ = try stack.undo(with: ops)
            #expect(stack.depth == 0 && stack.redoDepth == 1)
            let f = try fixture(ops)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: false)
            #expect(stack.depth == 0)
            #expect(stack.redoDepth == 1)
        }
    }

    /// A SEALED NOTE in an OPEN book pins freely — the seal's reach is the
    /// note's authoring writes; a pin is book-side (A-808-12 (b)).
    @Test func aSealedNoteInAnOpenBookPins() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            try ops.lockPost(f.a.id)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            #expect(try membership(db, f.a.id, f.book.id).pinnedAt != nil)
        }
    }

    /// An ARCHIVED book is not frozen (archive is orthogonal to Finished): its
    /// pins move.
    @Test func anArchivedBookPins() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            try ops.archiveReading(f.book.id)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            #expect(try membership(db, f.a.id, f.book.id).pinnedAt != nil)
        }
    }

    // MARK: - The refusals (each leaves the row as it was)

    /// A FINISHED book refuses `lockedReading` — a pin is order, and Finished
    /// freezes the assembly (the sort dial's posture; P-808-B4-1). Both ways.
    @Test func aFinishedBookRefusesBothWays() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            try ops.setMembershipPinned(f.b.id, in: f.book.id, pinned: true)
            try ops.lockReading(f.book.id)
            let a = try membership(db, f.a.id, f.book.id)
            let b = try membership(db, f.b.id, f.book.id)
            #expect(throws: OperationError.lockedReading(id: f.book.id)) {
                try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            }
            #expect(throws: OperationError.lockedReading(id: f.book.id)) {
                try ops.setMembershipPinned(f.b.id, in: f.book.id, pinned: false)
            }
            #expect(try membership(db, f.a.id, f.book.id) == a)
            #expect(try membership(db, f.b.id, f.book.id) == b)
        }
    }

    /// A SEALED book refuses by construction (sealing finishes too).
    @Test func aSealedBookRefuses() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            _ = try ops.sealReading(f.book.id)
            #expect(throws: OperationError.lockedReading(id: f.book.id)) {
                try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            }
            #expect(try membership(db, f.a.id, f.book.id).pinnedAt == nil)
        }
    }

    /// A GATHERING refuses `wrongReadingKind`, answered FIRST — a legacy
    /// finished one included (the kind, not the state, is the answer).
    @Test func aGatheringRefusesWrongKindFirst() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "g")
            let note = try ops.createPost(title: "n")
            try ops.applyTag(tag.id, toPost: note.id)
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let gathering = try ops.createReading(name: "g", kind: .gathering, querySpec: rule)
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.setMembershipPinned(note.id, in: gathering.id, pinned: true)
            }
            try db.write {
                try $0.execute(sql: "UPDATE reading SET locked = 1 WHERE id = ?", arguments: [gathering.id])
            }
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.setMembershipPinned(note.id, in: gathering.id, pinned: true)
            }
        }
    }

    /// A missing or deleted book: `readingNotFound`.
    @Test func aMissingOrDeletedBookRefuses() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            #expect(throws: OperationError.readingNotFound(id: "nope")) {
                try ops.setMembershipPinned(f.a.id, in: "nope", pinned: true)
            }
            try ops.deleteReading(f.book.id)
            #expect(throws: OperationError.readingNotFound(id: f.book.id)) {
                try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            }
        }
    }

    /// A note that is not a member — never added, removed, or WAITING at the
    /// door (an arrival is no member) — refuses `postNotInReading`, and the
    /// arrival row is untouched.
    @Test func aNonMemberAndAnArrivalRefuse() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            let stranger = try ops.createPost(title: "stranger")
            #expect(throws: OperationError.postNotInReading(postID: stranger.id, readingID: f.book.id)) {
                try ops.setMembershipPinned(stranger.id, in: f.book.id, pinned: true)
            }
            try ops.removePostFromReading(f.b.id, from: f.book.id)
            #expect(throws: OperationError.postNotInReading(postID: f.b.id, readingID: f.book.id)) {
                try ops.setMembershipPinned(f.b.id, in: f.book.id, pinned: true)
            }
            let waiting = try ops.createPost(title: "waiting")
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('arrival-x', ?, ?, 'z', 'arrival', '2026-07-01T00:00:00.000Z')
                        """,
                    arguments: [f.book.id, waiting.id])
            }
            let arrival = try #require(try db.read { try ReadingPost.fetchOne($0, key: "arrival-x") })
            #expect(throws: OperationError.postNotInReading(postID: waiting.id, readingID: f.book.id)) {
                try ops.setMembershipPinned(waiting.id, in: f.book.id, pinned: true)
            }
            #expect(try db.read { try ReadingPost.fetchOne($0, key: "arrival-x") } == arrival)
        }
    }

    // MARK: - The exact-slot copies carry the pin (A-808-12 (f))

    /// `divergePostForReading`: the copy takes the original's slot — its pin too.
    @Test func aDivergedCopyKeepsThePin() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            _ = try ops.newBlock(in: f.a.id, text: "words", at: .end)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            let stamp = try membership(db, f.a.id, f.book.id).pinnedAt
            let result = try ops.divergePostForReading(f.a.id, in: f.book.id)
            #expect(try membership(db, result.copy.post.id, f.book.id).pinnedAt == stamp)
        }
    }

    /// Own Its Notes… (`setReadingOwned` → `forkInPlace`): a shared pinned
    /// member's fork keeps the pin.
    @Test func anOwnershipForkKeepsThePin() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            let other = try ops.createReading(name: "other", kind: .book)
            try ops.addPostToReading(f.a.id, to: other.id)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            let stamp = try membership(db, f.a.id, f.book.id).pinnedAt
            let result = try ops.setReadingOwned(f.book.id, owned: true)
            let fork = try #require(result.copied.first)
            #expect(fork.originalID == f.a.id)
            #expect(try membership(db, fork.copyID, f.book.id).pinnedAt == stamp)
        }
    }

    /// Seal… (its forks ride `forkInPlace` too): the sealed edition keeps her pins.
    @Test func aSealForkKeepsThePin() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            let other = try ops.createReading(name: "other", kind: .book)
            try ops.addPostToReading(f.a.id, to: other.id)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            let stamp = try membership(db, f.a.id, f.book.id).pinnedAt
            let result = try ops.sealReading(f.book.id)
            let fork = try #require(result.forked.first)
            #expect(try membership(db, fork.copyID, f.book.id).pinnedAt == stamp)
        }
    }

    /// Duplicate Book… (shallow and deep): the arrangement rides — pins too.
    @Test(arguments: [false, true])
    func aDuplicateKeepsThePins(deep: Bool) throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            try ops.setMembershipPinned(f.b.id, in: f.book.id, pinned: true)
            let stamp = try membership(db, f.b.id, f.book.id).pinnedAt
            let result = try ops.duplicateReading(f.book.id, name: "copy", deep: deep)
            let entries = try db.read { try Queries.assembleReading($0, readingID: result.reading.id) }
            #expect(entries.map(\.pinned) == [true, false], "the duplicate reads in the same floated order")
            let copiedB = deep ? try #require(result.copied.first { $0.originalID == f.b.id }).copyID : f.b.id
            #expect(try membership(db, copiedB, result.reading.id).pinnedAt == stamp)
        }
    }

    // MARK: - The recorded corners (A-808-12 (j))

    /// Put back (exact-stamp revival) returns the pin with its row; a fresh
    /// re-add after a remove is a NEW membership — unpinned.
    @Test func putBackReturnsThePinAndAFreshReAddIsUnpinned() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            try ops.setMembershipPinned(f.a.id, in: f.book.id, pinned: true)
            let stamp = try membership(db, f.a.id, f.book.id).pinnedAt
            try ops.deleteReading(f.book.id)
            try ops.restoreReading(f.book.id)
            #expect(try membership(db, f.a.id, f.book.id).pinnedAt == stamp)

            try ops.setMembershipPinned(f.b.id, in: f.book.id, pinned: true)
            try ops.removePostFromReading(f.b.id, from: f.book.id)
            try ops.addPostToReading(f.b.id, to: f.book.id)
            #expect(try membership(db, f.b.id, f.book.id).pinnedAt == nil)
        }
    }
}
