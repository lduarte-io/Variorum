import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **17y item (c) — DUPLICATE AS VERSION CARRIES TAGS** (her ruling, QUESTIONS
/// #169's tail, two beats: "should probably carry the tags… doesn't have to be
/// built right now", then mid-walk "let's just build [it] now — I think it's a
/// bit sloppy to not have it"; **Diverge STAYS tag-less** — her lean: a
/// diverged copy is meant to differ from what's already there).
///
/// The change is the POST-level tag ride on `duplicateAsVersion` ALONE: the
/// copy wears every live tag application the source wears, as fresh rows
/// (the ceremony copy's `copyLiveTags` — application order kept, the
/// source's own wing's live tags only). `divergePostForReading` and
/// `promoteLens` are untouched — both compose the same `copyPost` body, so
/// the ride must live in `duplicateAsVersion`'s own transaction, never in
/// the shared copy machine.
///
/// **VX-372 (VX-383 U1 — D-C-1) SUPERSEDES P-17y-B3-c1 for this door** (her
/// ticket: *"a duplicate with tags counts as tagging"*): the riding tags are
/// now APPLIED through the one road, so a living book whose rule names a tag
/// hears the duplicate exactly as when she tags (the intake arms are pinned in
/// `DuplicateAppliesTagsTests`; the without-tags choice in
/// `DuplicateWithoutTagsTests`). The ceremony copy keeps its row copy. Undo
/// tombstones the copy and its applications with it (the container cascade);
/// redo revives them on the exact stamp (`restoreContainer`). JUSTIFIED EDITS
/// (VX-372): the control below flipped to the applying act it now pins, and
/// the undo label reads the door's new verb (P-C-1, "Duplicate with Tags").
///
/// Red-on-old, stated (MEASURED on the pre-fix tree a93fbf6d — 4 issues): the
/// copy wears NO tag — `theDuplicateWearsEveryLiveTagOfTheSource` fails its
/// copy-paths and row-count arms, `undoAndRedoCarryTheCopiesTags` its do and
/// redo arms (the disjointness arm passes vacuously over no rows). The Diverge, promote and
/// no-intake pins are CONTROLS (green on both trees by design: they guard
/// the change's reach, not its presence).
@Suite("17y (c) — Duplicate as Version carries the note's tags; Diverge stays tag-less")
struct DuplicateCarriesTagsTests {
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

    @Test func theDuplicateWearsEveryLiveTagOfTheSource() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: post.id, text: "Some prose.")
            let draft = try ops.createTag(name: "draft")
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let gone = try ops.createTag(name: "gone")
            try ops.applyTag(draft.id, toPost: post.id)
            try ops.applyTag(goals.id, toPost: post.id)
            try ops.applyTag(gone.id, toPost: post.id)
            // A REMOVED application and a DELETED tag never ride.
            try ops.removeTag(gone.id, fromPost: post.id)
            let dead = try ops.createTag(name: "dead")
            try ops.applyTag(dead.id, toPost: post.id)
            try ops.deleteTag(dead.id)

            let result = try ops.duplicateAsVersion(post.id)

            #expect(try liveTagPaths(db, post: result.post.id) == ["draft", "life/goals"],
                    "the copy wears the source's live tags, in application order")
            #expect(try liveTagPaths(db, post: post.id) == ["draft", "life/goals"],
                    "the source keeps its own applications, untouched")
            let copyRows = try db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [result.post.id])
            }
            let sourceRows = try db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [post.id])
            }
            #expect(copyRows.count == 2)
            #expect(Set(copyRows).isDisjoint(with: Set(sourceRows)),
                    "fresh rows — the copy's applications are its own")
        }
    }

    @Test func undoAndRedoCarryTheCopiesTags() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: post.id, text: "Some prose.")
            let draft = try ops.createTag(name: "draft")
            try ops.applyTag(draft.id, toPost: post.id)

            let result = try ops.duplicateAsVersion(post.id)
            #expect(try liveTagPaths(db, post: result.post.id) == ["draft"])

            #expect(try stack.undo(with: ops) == "Duplicate with Tags")
            #expect(try db.deletedAt("container", result.post.id) != nil)
            #expect(try liveTagPaths(db, post: result.post.id).isEmpty,
                    "undo takes the copy's applications with the copy")

            #expect(try stack.redo(with: ops) == "Duplicate with Tags")
            #expect(try db.deletedAt("container", result.post.id) == nil)
            #expect(try liveTagPaths(db, post: result.post.id) == ["draft"],
                    "redo brings the copy back wearing its tags")
            #expect(try liveTagPaths(db, post: post.id) == ["draft"], "the source untouched")
        }
    }

    /// VX-372 (D-C-1 — JUSTIFIED EDIT: this was P-17y-B3-c1's control, "no
    /// living book hears the duplicate"; her ticket supersedes it): the riding
    /// tags are APPLIED, so a LIVING book whose rule names the tag hears the
    /// duplicate and takes it in.
    @Test func theRidingTagsAreAppliedSoALivingBookHearsThem() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            let living = try ops.createReading(
                name: "drafts", kind: .book, querySpec: try RuleGrammar.encode(.tag(draft.id)))
            let post = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: post.id, text: "Some prose.")
            try ops.applyTag(draft.id, toPost: post.id)  // the ACT — the book hears it
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                [living.id]) == 1, "the original was taken in by the act")

            let result = try ops.duplicateAsVersion(post.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND reading_id = ? AND status = 'member' AND deleted_at IS NULL",
                [result.post.id, living.id]) == 1,
                "the copy was heard: the living book took it in")
        }
    }

    /// CONTROL — Diverge stays tag-less (her lean, ruled with the item).
    @Test func divergeStaysTagLess() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "orbit", kind: .book)
            let post = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: post.id, text: "Some prose.")
            try ops.addPostToReading(post.id, to: book.id)
            let draft = try ops.createTag(name: "draft")
            try ops.applyTag(draft.id, toPost: post.id)

            let diverged = try ops.divergePostForReading(post.id, in: book.id)
            #expect(try liveTagPaths(db, post: diverged.copy.post.id).isEmpty)
            #expect(try liveTagPaths(db, post: post.id) == ["draft"])
        }
    }

    /// CONTROL — the lens door is untouched (the brief: "the lens door
    /// untouched").
    @Test func promoteLensStaysTagLess() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: post.id, text: "Some prose.")
            let draft = try ops.createTag(name: "draft")
            try ops.applyTag(draft.id, toPost: post.id)
            let lens = try ops.createLens(post: post.id, name: "a lens")

            let promoted = try ops.promoteLens(lens.id)
            #expect(try liveTagPaths(db, post: promoted.post.id).isEmpty)
        }
    }
}
