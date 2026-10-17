import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// **VX-372 (VX-383 U1 — D-C-1): DUPLICATE WITH TAGS APPLIES THEM.** Her ticket's words:
/// *"a duplicate with tags counts as tagging."* The copy's tags are no longer a ROW copy
/// (P-17y-B3-c1, superseded for this door): each live tag the source wears in its wing is
/// APPLIED to the copy through the one application road (`insertPostTag`), in the source's
/// application order, inside the duplicate's own transaction — so every living book whose
/// rule hears a tag decides exactly as when she tags: a book that joins quietly SEATS the
/// copy, one whose dial says Arrivals BELLS it, a full book bells it at the door, and the
/// ownership table holds (an owned book claims the free copy; a plain book then bells a
/// note an owned book holds). Finished and archived books stay paused (the one table).
///
/// **The undo story** (D-C-1, pinned here): the ONE entry is `registerMintedContainerEntry`'s —
/// its inverse tombstones the copy, and the container trigger takes the copy's memberships and
/// arrivals with it on that one stamp; the redo's `restoreContainer` revives them on it. So an
/// undo after a seat leaves the book without the copy, a redo brings the seat back, and a row
/// she judged in between (a dismissal — a tombstone on ITS OWN stamp; a seat she pressed — the
/// same row flipped) stays as she judged it.
///
/// Every test here calls the door's pre-existing spelling (`duplicateAsVersion(_:)`, whose new
/// default is the with-tags choice, and `duplicateNoteForClient`), so the file compiles on the
/// pre-fix tree and runs RED there: the copy wore its tags as rows, so no book ever heard it.
/// The controls (finished, archived) are green on both trees by design — they guard the reach.
@Suite("VX-372 — Duplicate with Tags applies them: intake hears the copy")
struct DuplicateAppliesTagsTests {
    // MARK: - Fixtures

    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    private func livingBook(
        _ ops: Operations, _ term: RuleTerm, name: String = "living",
        maxPosts: Int? = nil, seating: IntakeSeating? = nil
    ) throws -> Reading {
        try ops.createReading(
            name: name, kind: .book, querySpec: try rule(term), maxPosts: maxPosts,
            intakeSeating: seating)
    }

    /// Every row of the pair (tombstones included), in insertion order.
    private func pairRows(_ db: AppDatabase, book: String, post: String) throws -> [ReadingPost] {
        try db.read {
            try ReadingPost.fetchAll(
                $0, sql: "SELECT * FROM reading_post WHERE reading_id = ? AND post_id = ? ORDER BY rowid",
                arguments: [book, post])
        }
    }

    private func members(_ db: AppDatabase, _ book: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: book).map(\.postID) }
    }

    private func liveTagPaths(_ db: AppDatabase, post: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                    ORDER BY pt.created_at, pt.id
                    """,
                arguments: [post])
        }
    }

    /// A one-block note wearing `tags`, applied in order (each application the ordinary act).
    private func taggedNote(_ ops: Operations, _ title: String, tags: [VariorumCore.Tag]) throws -> Container {
        let note = try ops.createPost(title: title)
        _ = try ops.seedBlock(in: note.id, text: "Some prose.")
        for tag in tags { try ops.applyTag(tag.id, toPost: note.id) }
        return note
    }

    // MARK: - The table, heard

    /// A book that joins quietly SEATS the copy: a live member row at the END, unsectioned,
    /// written by the duplicate's own act (the application's stamp).
    @Test func aBookThatJoinsQuietlySeatsTheDuplicate() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            let book = try livingBook(ops, .tag(draft.id))
            let source = try taggedNote(ops, "the essay", tags: [draft])
            #expect(try members(db, book.id) == [source.id], "the source was taken in by her act")

            let copy = try ops.duplicateAsVersion(source.id)

            let rows = try pairRows(db, book: book.id, post: copy.post.id)
            try #require(rows.count == 1, "the copy was heard: one row for the pair")
            #expect(rows[0].status == .member && rows[0].deletedAt == nil)
            #expect(rows[0].sectionId == nil, "unsectioned (§4)")
            #expect(try members(db, book.id) == [source.id, copy.post.id], "at the END")
            let application = try #require(try db.read { db in
                try PostTag.fetchOne(
                    db, sql: "SELECT * FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [copy.post.id])
            })
            #expect(rows[0].createdAt == application.createdAt,
                    "the seat is the application's own act — one clock read stamps both")
            #expect(try liveTagPaths(db, post: copy.post.id) == ["draft"])
        }
    }

    /// The join dial says Arrivals: the copy BELLS, never seats.
    @Test func aBookWhoseDialSaysArrivalsBellsTheDuplicate() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            let book = try livingBook(ops, .tag(draft.id), seating: .arrivals)
            let source = try taggedNote(ops, "the essay", tags: [draft])

            let copy = try ops.duplicateAsVersion(source.id)

            let rows = try pairRows(db, book: book.id, post: copy.post.id)
            try #require(rows.count == 1)
            #expect(rows[0].status == .arrival && rows[0].deletedAt == nil, "the bell, waiting")
            #expect(!(try members(db, book.id)).contains(copy.post.id), "an arrival is never a member")
        }
    }

    /// Capacity waits at the door: a full book bells the copy.
    @Test func aFullBookBellsTheDuplicateAtItsDoor() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            let book = try livingBook(ops, .tag(draft.id), maxPosts: 1)
            let source = try taggedNote(ops, "the essay", tags: [draft])
            #expect(try members(db, book.id) == [source.id], "the book is now full")

            let copy = try ops.duplicateAsVersion(source.id)

            let rows = try pairRows(db, book: book.id, post: copy.post.id)
            try #require(rows.count == 1)
            #expect(rows[0].status == .arrival, "at capacity: the bell, never a seat past the cap")
        }
    }

    /// The application ORDER is the source's, and the ownership table holds across it: the
    /// first tag's OWNED book claims the free copy, and the second tag's PLAIN book then bells a
    /// note an owned book holds — exactly what her own two taggings, in that order, would do.
    @Test func theApplicationOrderIsKeptAndTheOwnershipTableHolds() throws {
        try withOperations { ops, db in
            let first = try ops.createTag(name: "first")
            let second = try ops.createTag(name: "second")
            let owned = try livingBook(ops, .tag(first.id), name: "owned")
            _ = try ops.setReadingOwned(owned.id, owned: true)
            let plain = try livingBook(ops, .tag(second.id), name: "plain")
            let source = try taggedNote(ops, "the essay", tags: [first, second])

            let copy = try ops.duplicateAsVersion(source.id)

            #expect(try liveTagPaths(db, post: copy.post.id) == ["first", "second"],
                    "applied in the source's application order")
            let claimed = try pairRows(db, book: owned.id, post: copy.post.id)
            try #require(claimed.count == 1)
            #expect(claimed[0].status == .member, "the owned book claims the FREE copy")
            let belled = try pairRows(db, book: plain.id, post: copy.post.id)
            try #require(belled.count == 1)
            #expect(belled[0].status == .arrival, "the plain book bells a note an owned book holds")
        }
    }

    /// The MCP door's `duplicate_note` runs the SAME body (D-311-1's no-drift extraction), so
    /// the wire's copy is heard exactly as her door's is.
    @Test func theWiresDuplicateIsHeardTheSameWay() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            let book = try livingBook(ops, .tag(draft.id))
            let source = try taggedNote(ops, "the essay", tags: [draft])

            let copy = try ops.duplicateNoteForClient(source.id, undoLabel: "claude-code's duplicate")

            let rows = try pairRows(db, book: book.id, post: copy.post.id)
            try #require(rows.count == 1)
            #expect(rows[0].status == .member)
        }
    }

    // MARK: - The undo story

    /// ONE entry covers the seat: undo leaves the book without the copy (the membership row
    /// tombstoned on the copy's own stamp); redo brings the SAME row back as a member.
    @Test func undoAfterASeatLeavesTheBookWithoutTheCopyAndRedoBringsTheSeatBack() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let draft = try ops.createTag(name: "draft")
            let book = try livingBook(ops, .tag(draft.id))
            let source = try taggedNote(ops, "the essay", tags: [draft])
            let depth = stack.depth

            let copy = try ops.duplicateAsVersion(source.id)
            #expect(stack.depth == depth + 1, "ONE entry for the copy and its seat")
            let seat = try #require(try pairRows(db, book: book.id, post: copy.post.id).first)
            #expect(seat.status == .member)

            _ = try stack.undo(with: ops)
            let copyStamp = try #require(try db.deletedAt("container", copy.post.id))
            #expect(try db.deletedAt("reading_post", seat.id) == copyStamp,
                    "the seat went with the copy, on the copy's own stamp")
            #expect(try members(db, book.id) == [source.id], "the book is without the copy")

            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("container", copy.post.id) == nil)
            let back = try #require(try pairRows(db, book: book.id, post: copy.post.id).first)
            #expect(back.id == seat.id && back.deletedAt == nil && back.status == .member,
                    "the same seat, back")
            #expect(try members(db, book.id) == [source.id, copy.post.id])
            #expect(try liveTagPaths(db, post: copy.post.id) == ["draft"])
        }
    }

    /// A row she JUDGED between the act and its undo stays judged: a dismissal is a tombstone
    /// on her own stamp, so the redo — which revives only the undo's stamp — never brings the
    /// bell back.
    @Test func aDismissalSheMadeBetweenStaysDecidedAcrossUndoAndRedo() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let draft = try ops.createTag(name: "draft")
            let book = try livingBook(ops, .tag(draft.id), seating: .arrivals)
            let source = try taggedNote(ops, "the essay", tags: [draft])

            let copy = try ops.duplicateAsVersion(source.id)
            let bell = try #require(try pairRows(db, book: book.id, post: copy.post.id).first)
            try #require(bell.status == .arrival)
            try ops.dismissArrival(bell.id)
            let dismissedOn = try #require(try db.deletedAt("reading_post", bell.id))

            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)

            #expect(try db.deletedAt("container", copy.post.id) == nil, "the copy is back")
            let rows = try pairRows(db, book: book.id, post: copy.post.id)
            #expect(rows.count == 1, "no new row for the pair")
            #expect(try db.deletedAt("reading_post", bell.id) == dismissedOn,
                    "her dismissal stands, on her own stamp")
        }
    }

    /// …and a bell she SEATED between comes back seated (the same row, flipped by her Add).
    @Test func anArrivalSheSeatedBetweenComesBackSeated() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let draft = try ops.createTag(name: "draft")
            let book = try livingBook(ops, .tag(draft.id), seating: .arrivals)
            let source = try taggedNote(ops, "the essay", tags: [draft])

            let copy = try ops.duplicateAsVersion(source.id)
            let bell = try #require(try pairRows(db, book: book.id, post: copy.post.id).first)
            try #require(bell.status == .arrival)
            _ = try ops.seatArrival(bell.id)

            _ = try stack.undo(with: ops)
            #expect(!(try members(db, book.id)).contains(copy.post.id))
            _ = try stack.redo(with: ops)

            let back = try #require(try pairRows(db, book: book.id, post: copy.post.id).first)
            #expect(back.id == bell.id && back.status == .member && back.deletedAt == nil,
                    "her seat stands")
        }
    }

    // MARK: - Controls (green on both trees — the reach, not the presence)

    /// Finished and archived books stay paused, as for her own tagging.
    @Test func finishedAndArchivedBooksStayPaused() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            let finished = try livingBook(ops, .tag(draft.id), name: "finished")
            let archived = try livingBook(ops, .tag(draft.id), name: "archived")
            let source = try taggedNote(ops, "the essay", tags: [draft])
            try ops.lockReading(finished.id)
            try ops.archiveReading(archived.id)

            let copy = try ops.duplicateAsVersion(source.id)

            #expect(try pairRows(db, book: finished.id, post: copy.post.id).isEmpty)
            #expect(try pairRows(db, book: archived.id, post: copy.post.id).isEmpty)
            #expect(try liveTagPaths(db, post: copy.post.id) == ["draft"], "the copy still wears it")
        }
    }
}
