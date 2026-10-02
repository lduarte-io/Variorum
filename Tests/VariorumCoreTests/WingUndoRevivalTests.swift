import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U6 ACT 0 — F-U5b-2, RULED (a) at the adjudication after U5b:
/// **an undo or redo replayed AFTER a wing move never revives a membership
/// across wings** (the sitting record §9 — a book never spans wings; lesson
/// 11: "Nothing crosses between wings except what you move or copy
/// yourself"). A replay whose revival would cross is OBSOLETE and does
/// NOTHING — each road's own "book deleted meanwhile" bucket, checked before
/// any write.
///
/// THE MECHANISM, traced from the code: the structural entries capture their
/// rows at do-time and replay them with liveness guards only, while the wing
/// moves (U5/U5b) register no undo entry and clear nothing — so an entry
/// recorded BEFORE a move replays AFTER it into a book that is no longer in
/// the note's wing:
/// - (i) `revertDiverge` revives the ORIGINAL's row in the book (live-post
///   guard only) — diverge → move the book → ⌥⌘Z;
/// - (ii) `reapplySmartConversion` revives every row the un-bind took
///   (live-post + no-live-pair guards) — bind → ⌥⌘Z → move a member note →
///   ⇧⌥⌘Z (and its twin: the GATHERING itself moved while unbound);
/// - (iii, the sibling the grep found) `reapplyDiverge` revives the COPY's
///   row after `restoreContainer` brings the copy back — diverge → ⌥⌘Z →
///   move the book → ⇧⌥⌘Z.
/// Each pin is the recipe exactly, RED on the pre-guard tree. The last test
/// is the CONTROL — `reapplyMintedContainer` revives only through
/// `restoreContainer`, which F-U5b-1 already guards at the row level (the
/// copy comes back bookless, as when its book was deleted meanwhile): green
/// on both sides of ACT 0, honest, not a fix.
@Suite("13i-d U6 ACT 0 — an undo/redo never revives a membership across wings")
struct WingUndoRevivalTests {
    private func liveRows(_ db: AppDatabase, post: String, reading: String) throws -> Int {
        try db.fetchInt(
            "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND reading_id = ? AND deleted_at IS NULL",
            [post, reading]) ?? 0
    }

    /// Every live membership row whose note and book read in DIFFERENT wings
    /// (a dangling pointer reads as Home on both sides — the surfaces' rule).
    /// The invariant the guard keeps: always zero.
    private func crossings(_ db: AppDatabase) throws -> Int {
        try db.fetchInt(
            """
            SELECT COUNT(*) FROM reading_post rp
            JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
            JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
            WHERE rp.deleted_at IS NULL
              AND (CASE WHEN c.wing_id IN (SELECT id FROM wing WHERE deleted_at IS NULL)
                        THEN c.wing_id ELSE '' END)
               <> (CASE WHEN r.wing_id IN (SELECT id FROM wing WHERE deleted_at IS NULL)
                        THEN r.wing_id ELSE '' END)
            """,
            []) ?? 0
    }

    private func isLive(_ db: AppDatabase, container id: String) throws -> Bool {
        (try db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ? AND deleted_at IS NULL", [id]) ?? 0) == 1
    }

    private func wing(_ db: AppDatabase, ofPost id: String) throws -> String? {
        try db.read { try Queries.effectiveWing($0, ofPost: id) }
    }

    /// A Home book holding one note with text (so the diverge copy carries
    /// something), and an additional wing to move things into.
    private func world(_ ops: Operations) throws -> (wing: Wing, book: Reading, post: Container) {
        let wing = try ops.createWing(name: "Annex")
        let book = try ops.createReading(name: "Orbit", kind: .book)
        let post = try ops.createPost(title: "shared")
        _ = try ops.newBlock(in: post.id, text: "Alpha beta.")
        try ops.addPostToReading(post.id, to: book.id)
        return (wing, book, post)
    }

    // MARK: - (i) revertDiverge — diverge → move the book → ⌥⌘Z

    @Test func anUndoneDivergeNeverRevivesTheOriginalIntoABookThatMovedAway() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            let result = try ops.divergePostForReading(w.post.id, in: w.book.id)
            let copyID = result.copy.post.id
            _ = try ops.moveReadingToWing(w.book.id, to: w.wing.id)
            // The move's own letter: the copy is the member, so it rode; the
            // original (no longer a member here) stayed in Home.
            #expect(try wing(db, ofPost: copyID) == w.wing.id)
            #expect(try wing(db, ofPost: w.post.id) == "")

            let label = try stack.undo(with: ops)
            #expect(label == "Diverge for This Book", "the entry is consumed quietly — obsolete")
            #expect(try crossings(db) == 0, "nothing crosses between wings")
            #expect(try liveRows(db, post: w.post.id, reading: w.book.id) == 0,
                    "the original never rejoins a book that moved to another wing")
            #expect(try liveRows(db, post: copyID, reading: w.book.id) == 1,
                    "OBSOLETE does nothing: the copy keeps its seat — no half-undo")
            #expect(try isLive(db, container: copyID), "…and the copy is not tombstoned")
        }
    }

    // MARK: - (ii) reapplySmartConversion — bind → ⌥⌘Z → move a note → ⇧⌥⌘Z

    private func boundGathering(_ ops: Operations) throws
        -> (wing: Wing, gathering: Reading, a: Container, b: Container)
    {
        let wing = try ops.createWing(name: "Annex")
        let tag = try ops.createTag(name: "work")
        let gathering = try ops.createReading(
            name: "collected", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
        let a = try ops.createPost(title: "a")
        _ = try ops.applyTag(tag.id, toPost: a.id)
        let b = try ops.createPost(title: "b")
        _ = try ops.applyTag(tag.id, toPost: b.id)
        return (wing, gathering, a, b)
    }

    @Test func aRedoneBindNeverRevivesARowForANoteThatMovedAway() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let w = try boundGathering(ops)
            _ = try ops.convertSmartReadingToCurated(w.gathering.id)
            _ = try stack.undo(with: ops)  // the un-bind: every row taken
            _ = try ops.moveNoteToWing(w.a.id, to: w.wing.id)

            let label = try stack.redo(with: ops)
            #expect(label == "Convert to Book", "the entry is consumed quietly — obsolete")
            #expect(try crossings(db) == 0, "nothing crosses between wings")
            #expect(try liveRows(db, post: w.a.id, reading: w.gathering.id) == 0,
                    "the note that moved away is never revived into the book")
            // The ruled letter (P-13id-U6-1): ONE crossing row voids the whole
            // re-bind — it stays a gathering, every taken row stays taken.
            let reading = try #require(try db.read { try Queries.reading($0, id: w.gathering.id) })
            #expect(reading.kind == .gathering, "OBSOLETE does nothing — still a gathering")
            #expect(try liveRows(db, post: w.b.id, reading: w.gathering.id) == 0)
        }
    }

    /// The twin: the GATHERING itself moved while unbound (a gathering moves
    /// alone — its notes stay), so every taken row would cross.
    @Test func aRedoneBindOfAGatheringThatMovedAwayDoesNothing() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let w = try boundGathering(ops)
            _ = try ops.convertSmartReadingToCurated(w.gathering.id)
            _ = try stack.undo(with: ops)
            _ = try ops.moveReadingToWing(w.gathering.id, to: w.wing.id)

            _ = try stack.redo(with: ops)
            #expect(try crossings(db) == 0, "nothing crosses between wings")
            let reading = try #require(try db.read { try Queries.reading($0, id: w.gathering.id) })
            #expect(reading.kind == .gathering, "never a book bound over another wing's notes")
            #expect(try liveRows(db, post: w.a.id, reading: w.gathering.id) == 0)
            #expect(try liveRows(db, post: w.b.id, reading: w.gathering.id) == 0)
        }
    }

    // MARK: - (iii) the sibling — reapplyDiverge: diverge → ⌥⌘Z → move the book → ⇧⌥⌘Z

    @Test func aRedoneDivergeNeverRevivesTheCopyIntoABookThatMovedAway() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            let result = try ops.divergePostForReading(w.post.id, in: w.book.id)
            let copyID = result.copy.post.id
            _ = try stack.undo(with: ops)  // the original back in its seat; the copy dead
            _ = try ops.moveReadingToWing(w.book.id, to: w.wing.id)
            #expect(try wing(db, ofPost: w.post.id) == w.wing.id, "the member rode with its book")

            let label = try stack.redo(with: ops)
            #expect(label == "Diverge for This Book", "the entry is consumed quietly — obsolete")
            #expect(try crossings(db) == 0, "nothing crosses between wings")
            #expect(try liveRows(db, post: copyID, reading: w.book.id) == 0,
                    "the copy (still in Home) never joins a book that moved away")
            #expect(try liveRows(db, post: w.post.id, reading: w.book.id) == 1,
                    "OBSOLETE does nothing: the original keeps its seat — no half-redo")
            #expect(try !isLive(db, container: copyID), "…and the copy stays where the undo put it")
        }
    }

    // MARK: - The CONTROL — reapplyMintedContainer (green on both sides of ACT 0)

    /// Copy In → ⌥⌘Z → move the book → ⇧⌥⌘Z: the redo revives rows only
    /// through `restoreContainer`, which F-U5b-1 already guards — the copy
    /// comes back BOOKLESS, exactly what the same road does when the book
    /// was deleted meanwhile. Nothing to fix; pinned so the sibling map's
    /// fourth road stays covered.
    @Test func aRedoneCopyInComesBackBooklessNeverAcross() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            let source = try ops.createPost(title: "source")
            _ = try ops.newBlock(in: source.id, text: "Gamma delta.")
            let result = try ops.copyPostIntoReading(source.id, into: w.book.id)
            let copyID = result.copy.id
            _ = try stack.undo(with: ops)
            _ = try ops.moveReadingToWing(w.book.id, to: w.wing.id)

            _ = try stack.redo(with: ops)
            #expect(try crossings(db) == 0, "nothing crosses between wings")
            #expect(try isLive(db, container: copyID), "the copy comes back…")
            #expect(try liveRows(db, post: copyID, reading: w.book.id) == 0,
                    "…bookless, in its own wing — never across")
        }
    }
}
