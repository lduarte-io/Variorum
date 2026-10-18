import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-371 (VX-383 U2 — the run record `notes/plans/fixes/vx-383-duplicate-note.md`, D-C-4):
// the core half of `duplicate_note`'s BOOK ROAD, as exact state transitions. The one body
// (`duplicateAsVersionBody`) takes a `DuplicateFiling`: the book's gates and the chapter BEFORE
// anything is minted, then the family copy, then the membership through the hand-add's choke
// point (capacity, the wing, ownership, the outflow), the chapter on that row, and only THEN the
// `with_tags` applications — so a destination that collects one of the copy's tags takes it ONCE,
// filed, and the other books hear the applications (an owned destination's copy BELLS at a plain
// collecting book). ONE undo entry over the copy, its membership and its seats. The answered facts
// (`MCPDuplicate`) are read inside the act's transaction: every tag the copy wears (the applied
// tags, then the outflow, each once) and every book it is a member of (the filing first).
// New API (the `filing:` spelling), so red BY COMPILATION on the pre-fix tree and green by
// construction — the house's rule for a pure addition; the ORDER's behavioural red is the U2
// record's revert check, and the wire pins (`MCPDuplicateNoteFilingServerTests`) ran red first.

@Suite("VX-371 — duplicate_note's book road (core)")
struct MCPDuplicateFilingActsTests {
    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    /// Every row of the pair, tombstones included, in insertion order: (id, status, section, dead).
    private func pairRows(_ db: AppDatabase, book: String, post: String) throws -> [ReadingPost] {
        try db.read {
            try ReadingPost.fetchAll(
                $0, sql: "SELECT * FROM reading_post WHERE reading_id = ? AND post_id = ? ORDER BY rowid",
                arguments: [book, post])
        }
    }

    /// The pair's rows' `deleted_at`, as stored (the exact stamp).
    private func stamps(_ db: AppDatabase, book: String, post: String) throws -> [String?] {
        try db.read {
            try Optional<String>.fetchAll(
                $0, sql: "SELECT deleted_at FROM reading_post WHERE reading_id = ? AND post_id = ? ORDER BY rowid",
                arguments: [book, post])
        }
    }

    /// A book's live MEMBERS in its stored order (`position, id` — "the end" is the last place,
    /// whichever chapter a row is filed under).
    private func members(_ db: AppDatabase, _ book: String) throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0,
                sql: """
                    SELECT post_id FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member' ORDER BY position, id
                    """,
                arguments: [book])
        }
    }

    private func taggedNote(_ ops: Operations, _ title: String, tags: [VariorumCore.Tag]) throws -> Container {
        let note = try ops.createPost(title: title)
        _ = try ops.seedBlock(in: note.id, text: "Some prose.")
        for tag in tags { try ops.applyTag(tag.id, toPost: note.id) }
        return note
    }

    private var notes: String { "SELECT COUNT(*) FROM container WHERE kind = 'post'" }

    // MARK: - Filed: the book's end, its chapter, one entry

    /// The copy joins the book at its END under the chapter, in the act; ONE entry labelled as
    /// given; its undo leaves the book (and a book that took the copy in by its tag) without it,
    /// on the copy's one stamp; its redo returns the SAME rows.
    @Test func aFiledCopyJoinsTheBooksEndInItsChapterUnderOneEntryAndTheRedoReturnsTheSameRows() throws {
        try withUndo { ops, stack, db in
            let essay = try ops.createTag(name: "essay")
            let book = try ops.createReading(name: "drafts", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "second drafts")
            let earlier = try taggedNote(ops, "an earlier draft", tags: [])
            _ = try ops.addPostToReading(earlier.id, to: book.id)
            let living = try ops.createReading(name: "living", kind: .book, querySpec: try rule(.tag(essay.id)))
            let source = try taggedNote(ops, "the essay", tags: [essay])

            let made = try ops.duplicateNoteForClient(
                source.id, filing: .init(bookID: book.id, sectionID: chapter.id), undoLabel: "claude-code's duplicate")
            let copyID = made.copy.post.id
            #expect(try members(db, book.id) == [earlier.id, copyID], "at the book's END")
            let filed = try pairRows(db, book: book.id, post: copyID)
            try #require(filed.count == 1)
            #expect(filed[0].status == .member && filed[0].sectionId == chapter.id)
            let seated = try pairRows(db, book: living.id, post: copyID)
            #expect(seated.map(\.status) == [.member], "the applied tag was heard by the collecting book")
            #expect(made.memberBookIDs == [book.id, living.id], "the filing first, then the seat")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's duplicate", "ONE entry")

            #expect(try stack.undoReporting(with: ops) == .init(label: "claude-code's duplicate", changed: true))
            let stamp = try #require(try db.deletedAt("container", copyID))
            #expect(try stamps(db, book: book.id, post: copyID) == [stamp])
            #expect(try stamps(db, book: living.id, post: copyID) == [stamp], "the seat went on the copy's one stamp")
            #expect(try members(db, book.id) == [earlier.id])
            #expect(try stack.redoReporting(with: ops) == .init(label: "claude-code's duplicate", changed: true))
            let back = try pairRows(db, book: book.id, post: copyID)
            #expect(back.map(\.id) == [filed[0].id] && back[0].deletedAt == nil && back[0].sectionId == chapter.id,
                    "the same row, filed")
            #expect(try pairRows(db, book: living.id, post: copyID).map(\.deletedAt) == [nil], "the seat back")
        }
    }

    // MARK: - THE ORDER

    /// The destination COLLECTS the copy's tag: the membership comes first, so the copy is ONE
    /// member, in its chapter — never an arrival, never `alreadyInReading`.
    @Test func theMembershipComesFirstSoACollectingDestinationTakesTheCopyOnceFiled() throws {
        try withUndo { ops, _, db in
            let essay = try ops.createTag(name: "essay")
            let destination = try ops.createReading(name: "drafts", kind: .book, querySpec: try rule(.tag(essay.id)))
            let chapter = try ops.createSection(in: destination.id, name: "one")
            let ringing = try ops.createReading(
                name: "drafts too", kind: .book, querySpec: try rule(.tag(essay.id)), intakeSeating: .arrivals)
            let source = try taggedNote(ops, "the essay", tags: [essay])

            let made = try ops.duplicateNoteForClient(
                source.id, filing: .init(bookID: destination.id, sectionID: chapter.id), undoLabel: "u")
            let copyID = made.copy.post.id
            let rows = try pairRows(db, book: destination.id, post: copyID)
            #expect(rows.count == 1 && rows.first?.status == .member && rows.first?.sectionId == chapter.id,
                    "ONE row, a member, filed: \(rows)")
            #expect(try pairRows(db, book: ringing.id, post: copyID).map(\.status) == [.arrival],
                    "the other book heard the application")
            #expect(made.memberBookIDs == [destination.id], "an arrival is no membership")
            #expect(made.tagIDs == [essay.id])
        }
    }

    /// An OWNED destination is a plain add (the copy is membered nowhere yet); a plain book that
    /// collects the copy's tag then BELLS it — the copy is owned elsewhere (the ownership table).
    @Test func anOwnedDestinationIsAPlainAddAndAPlainCollectingBookBellsTheCopy() throws {
        try withUndo { ops, _, db in
            let essay = try ops.createTag(name: "essay")
            let owned = try ops.createReading(name: "owned", kind: .book)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            let plain = try ops.createReading(name: "plain", kind: .book, querySpec: try rule(.tag(essay.id)))
            let source = try taggedNote(ops, "the essay", tags: [essay])

            let made = try ops.duplicateNoteForClient(source.id, filing: .init(bookID: owned.id), undoLabel: "u")
            #expect(try members(db, owned.id) == [made.copy.post.id])
            #expect(try pairRows(db, book: plain.id, post: made.copy.post.id).map(\.status) == [.arrival])
            #expect(made.memberBookIDs == [owned.id])
        }
    }

    // MARK: - The answered tags

    /// Every tag the copy wears: the APPLIED tags in the source's application order, then the
    /// destination's OUTFLOW, each once (a tag both carry at its applied place); without tags,
    /// the outflow alone — and the list IS the store.
    @Test func theTagsAreListedAppliedThenOutflowEachOnceAndWithoutTagsTheOutflowAlone() throws {
        try withUndo { ops, _, db in
            let first = try ops.createTag(name: "first")
            let second = try ops.createTag(name: "second")
            let third = try ops.createTag(name: "third")
            let book = try ops.createReading(name: "drafts", kind: .book)
            try ops.setReadingOutflow(book.id, tagIDs: [third.id, first.id])
            let source = try taggedNote(ops, "the essay", tags: [first, second])

            let applied = try ops.duplicateNoteForClient(source.id, filing: .init(bookID: book.id), undoLabel: "u")
            #expect(applied.tagIDs == [first.id, second.id, third.id])
            #expect(applied.tagPaths == ["first", "second", "third"])
            let worn = try db.read { db in
                Set(try String.fetchAll(
                    db, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [applied.copy.post.id]))
            }
            #expect(worn == Set(applied.tagIDs), "the list is the store")

            let bare = try ops.duplicateNoteForClient(
                source.id, tags: .none, filing: .init(bookID: book.id), undoLabel: "u")
            #expect(bare.tagIDs == [third.id, first.id] && bare.tagPaths == ["third", "first"])

            let unfiled = try ops.duplicateNoteForClient(source.id, filing: nil, undoLabel: "u")
            #expect(unfiled.tagIDs == [first.id, second.id] && unfiled.memberBookIDs.isEmpty)
        }
    }

    // MARK: - The destination's refusals: nothing minted, no entry

    /// A finished book, a gathering, a full book, a book of another wing, a chapter of another
    /// book and a deleted chapter each refuse with the op's own error, minting NOTHING (the gates
    /// run before the copy; capacity and the wing at the choke point, rolling the copy back) and
    /// registering no entry. An ARCHIVED book takes the add (explicit adds land — AppSpec §9).
    @Test func theDestinationsRefusalsMintNothingAndAnArchivedBookTakesTheAdd() throws {
        try withUndo { ops, stack, db in
            let essay = try ops.createTag(name: "essay")
            let finished = try ops.createReading(name: "finished", kind: .book)
            try ops.lockReading(finished.id)
            let gathering = try ops.createReading(name: "gathering", kind: .gathering, querySpec: try rule(.tag(essay.id)))
            let full = try ops.createReading(name: "full", kind: .book, maxPosts: 1)
            let occupant = try taggedNote(ops, "the occupant", tags: [])
            _ = try ops.addPostToReading(occupant.id, to: full.id)
            let elsewhere = try ops.createWing(name: "elsewhere")
            let theirs = try ops.createReading(name: "theirs", kind: .book, wingId: elsewhere.id)
            let book = try ops.createReading(name: "drafts", kind: .book)
            let other = try ops.createReading(name: "another", kind: .book)
            let othersChapter = try ops.createSection(in: other.id, name: "theirs")
            let gone = try ops.createSection(in: book.id, name: "gone")
            try ops.deleteSection(gone.id)
            let source = try taggedNote(ops, "the essay", tags: [essay])
            let before = try db.fetchInt(notes)

            let refusals: [(DuplicateFiling, OperationError)] = [
                (.init(bookID: finished.id), .lockedReading(id: finished.id)),
                (.init(bookID: gathering.id), .wrongReadingKind(id: gathering.id, expected: .book)),
                (.init(bookID: full.id), .readingAtCapacity(id: full.id)),
                (.init(bookID: book.id, sectionID: othersChapter.id),
                 .sectionNotInReading(sectionID: othersChapter.id, readingID: book.id)),
                (.init(bookID: book.id, sectionID: gone.id), .sectionNotFound(id: gone.id)),
            ]
            for (filing, error) in refusals {
                #expect(throws: error) { try ops.duplicateNoteForClient(source.id, filing: filing, undoLabel: "u") }
            }
            do {
                _ = try ops.duplicateNoteForClient(source.id, filing: .init(bookID: theirs.id), undoLabel: "u")
                Issue.record("another wing's book took the copy")
            } catch let error as OperationError {
                guard case .crossWingMembership = error else {
                    Issue.record("expected crossWingMembership, got \(error)")
                    return
                }
            }
            #expect(try db.fetchInt(notes) == before && stack.depth == 0, "nothing minted, no entry")

            let archived = try ops.createReading(name: "archived", kind: .book)
            try ops.archiveReading(archived.id)
            let landed = try ops.duplicateNoteForClient(source.id, filing: .init(bookID: archived.id), undoLabel: "u")
            #expect(try db.read { try Queries.assembleReading($0, readingID: archived.id).map(\.postID) }
                    == [landed.copy.post.id], "an explicit add lands in an archived book")
        }
    }

    /// Her doors file nothing: the body's filing-less road is her Duplicate's exact rows (the
    /// D-311-1 shape, unchanged by the filing's arrival) — the copy bookless unless intake seats it.
    @Test func herDoorsFileNothing() throws {
        try withUndo { ops, _, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let source = try taggedNote(ops, "the essay", tags: [])
            _ = try ops.addPostToReading(source.id, to: book.id)
            let theirs = try ops.duplicateAsVersion(source.id)
            let count = try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL", [theirs.post.id])
            #expect(count == 0, "her door's copy lands in no book")
        }
    }
}

private typealias DuplicateFiling = Operations.DuplicateFiling
