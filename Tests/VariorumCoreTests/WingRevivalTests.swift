import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U5b — F-U5b-1: **a Put back never revives a membership across
/// wings** (the sitting record §9 — a book never spans wings; PROVISIONAL
/// P-13id-U5b-5, AppSpec §9's restore letter: "rows whose story diverged stay
/// as they are").
///
/// THE MECHANISM, traced: both revival sites flip a membership on the EXACT
/// stamp with a liveness guard only — `restoreReading` (the book's rows whose
/// note is live) and `restoreContainerRows` (the note's rows whose book is
/// live). A note or book that lay in the Trash while its partner moved to
/// another wing therefore came back INTO a cross-wing membership. U5's note
/// move already exposed it (pin 1, RED on the pre-fix restore with the real
/// move); the book and bulk moves widen it (pin 2 stages the moved book's wing
/// RAW, so it compiles and runs on the pre-fix tree, the `insertWingTag`
/// precedent). Pin 3 is the control: a pair that lay in a wing's Trash and
/// came home TOGETHER (both re-homed when the wing died) revives as before.
@Suite("13i-d U5b — a Put back never revives a membership across wings")
struct WingRevivalTests {
    private func liveMembership(_ db: AppDatabase, _ postID: String, _ readingID: String) throws
        -> Int
    {
        try db.fetchInt(
            "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND reading_id = ? AND deleted_at IS NULL",
            [postID, readingID]) ?? 0
    }

    /// A book deleted, then its member note moved to another wing, then the
    /// book put back: the note stays where it went, and the book comes back
    /// WITHOUT it (its row stays a tombstone — nothing crosses).
    @Test func puttingBackABookNeverPullsInANoteThatMovedAway() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let note = try ops.createPost(title: "member")
            let book = try ops.createReading(name: "Alpha", kind: .book)
            _ = try ops.addPostToReading(note.id, to: book.id)
            try ops.deleteReading(book.id)
            _ = try ops.moveNoteToWing(note.id, to: wing.id)

            try ops.restoreReading(book.id)
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.wingId == "",
                    "the book comes back to its own (live) wing")
            #expect(try db.read { try Queries.effectiveWing($0, ofPost: note.id) } == wing.id)
            #expect(try liveMembership(db, note.id, book.id) == 0,
                    "a book never spans wings — the row stays decided-dead")
        }
    }

    /// A note deleted, then its book moved to another wing (staged raw — the
    /// book move's exact effect on the row), then the note put back: it comes
    /// back to its own wing, OUTSIDE the book that moved away.
    @Test func puttingBackANoteNeverRejoinsABookThatMovedAway() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let note = try ops.createPost(title: "member")
            let book = try ops.createReading(name: "Alpha", kind: .book)
            _ = try ops.addPostToReading(note.id, to: book.id)
            try ops.deleteContainer(note.id)
            try db.write { db in
                try db.execute(
                    sql: "UPDATE reading SET wing_id = ? WHERE id = ?",
                    arguments: [wing.id, book.id])
            }

            try ops.restoreContainer(note.id)
            #expect(try db.read { try Queries.effectiveWing($0, ofPost: note.id) } == "")
            #expect(try liveMembership(db, note.id, book.id) == 0,
                    "the note comes back bookless rather than across a wing")
        }
    }

    /// The control (green on both sides): a book and its note that lay in a
    /// wing's Trash TOGETHER come home together when the wing dies — both
    /// re-home to Home, so the membership revives as it always did.
    @Test func aPairThatComesHomeTogetherStillRevives() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let note = try ops.createPost(title: "member", wingId: wing.id)
            let book = try ops.createReading(name: "Alpha", kind: .book, wingId: wing.id)
            _ = try ops.addPostToReading(note.id, to: book.id)
            try ops.deleteContainer(note.id)
            try ops.deleteReading(book.id)
            try ops.deleteWing(wing.id)

            try ops.restoreReading(book.id)
            try ops.restoreContainer(note.id)
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.wingId == "")
            #expect(try db.read { try Queries.effectiveWing($0, ofPost: note.id) } == "")
            #expect(try liveMembership(db, note.id, book.id) == 1,
                    "re-homed together — the membership comes back")
        }
    }
}
