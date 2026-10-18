import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// **VX-372 (VX-383 U1 — D-C-3): Save Version → Promote ends like Duplicate with Tags** (her
/// ticket: *"Save Version → Promote ends the same way"*, her "I suppose"). `promoteNoteVersion`
/// applies the ORIGINAL note's live tags — its tags NOW, in its wing (a saved version stores none,
/// so the save-time set is not on record; P-C-2, PROVISIONAL) — to the promoted note, each through
/// the one application road in promote's own transaction, so living books hear it exactly as they
/// hear a duplicate with tags. Still NO undo entry (her one-way ruling stands; the seats ride the act).
///
/// Every test calls the pre-existing `saveNoteVersion` / `promoteNoteVersion`, so the file compiles
/// on the pre-fix tree and runs RED there (a promoted version wore no tag at all — VX-336's D-311-1
/// measured it). The undo control is green on both trees by design.
@Suite("VX-372 — a promoted version wears the original's tags, applied")
struct PromoteAppliesTagsTests {
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

    /// The ORIGINAL's tags NOW (not at save time): a tag removed since the save does not
    /// come back, a tag added since does, a deleted tag never rides; order is the original's.
    @Test func aPromotedVersionWearsTheOriginalsCurrentTags() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: note.id, text: "Some prose.")
            let kept = try ops.createTag(name: "kept")
            let dropped = try ops.createTag(name: "dropped")
            let doomed = try ops.createTag(name: "doomed")
            try ops.applyTag(kept.id, toPost: note.id)
            try ops.applyTag(dropped.id, toPost: note.id)
            try ops.applyTag(doomed.id, toPost: note.id)
            let version = try ops.saveNoteVersion(note.id)
            #expect(try liveTagPaths(db, post: version.post.id).isEmpty, "a saved version stores no tag")

            try ops.removeTag(dropped.id, fromPost: note.id)
            let added = try ops.createTag(name: "added")
            try ops.applyTag(added.id, toPost: note.id)
            try ops.deleteTag(doomed.id)

            try ops.promoteNoteVersion(version.post.id, of: note.id)

            #expect(try liveTagPaths(db, post: version.post.id) == ["kept", "added"],
                    "the original's live tags now, in its application order")
            #expect(try liveTagPaths(db, post: note.id) == ["kept", "added"], "the original untouched")
        }
    }

    /// The tags are APPLIED: a living book whose rule names one hears the promoted note and
    /// seats it, in promote's own act — exactly as a duplicate with tags is heard.
    @Test func aPromotedVersionIsHeardByLivingBooks() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            let living = try ops.createReading(
                name: "drafts", kind: .book, querySpec: try RuleGrammar.encode(.tag(draft.id)))
            let note = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: note.id, text: "Some prose.")
            try ops.applyTag(draft.id, toPost: note.id)
            let version = try ops.saveNoteVersion(note.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ?", [version.post.id]) == 0,
                "a version is never heard (it wears no tag and is archived)")

            try ops.promoteNoteVersion(version.post.id, of: note.id)

            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ?
                  AND status = 'member' AND deleted_at IS NULL
                """, [living.id, version.post.id]) == 1,
                "the living book seated the promoted note")
        }
    }

    /// Save → Promote ends where Duplicate with Tags ends: the same tags, the same books.
    @Test func promoteEndsWhereADuplicateWithTagsEnds() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            let living = try ops.createReading(
                name: "drafts", kind: .book, querySpec: try RuleGrammar.encode(.tag(draft.id)))
            let life = try ops.createTag(name: "life")
            let note = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: note.id, text: "Some prose.")
            try ops.applyTag(life.id, toPost: note.id)
            try ops.applyTag(draft.id, toPost: note.id)

            let duplicate = try ops.duplicateAsVersion(note.id)
            let version = try ops.saveNoteVersion(note.id)
            try ops.promoteNoteVersion(version.post.id, of: note.id)

            #expect(try liveTagPaths(db, post: version.post.id)
                    == liveTagPaths(db, post: duplicate.post.id))
            let books = "SELECT reading_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL AND status = 'member'"
            #expect(try db.fetchString(books, [version.post.id]) == living.id)
            #expect(try db.fetchString(books, [duplicate.post.id]) == living.id)
        }
    }

    /// CONTROL — still no undo entry (her one-way ruling): the tags and their seats ride the act.
    @Test func promoteStillRegistersNoUndoEntry() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let note = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: note.id, text: "Some prose.")
            let draft = try ops.createTag(name: "draft")
            try ops.applyTag(draft.id, toPost: note.id)
            let version = try ops.saveNoteVersion(note.id)
            let depth = stack.depth

            try ops.promoteNoteVersion(version.post.id, of: note.id)

            #expect(stack.depth == depth, "promote registers nothing")
            #expect(try db.fetchString(
                "SELECT archived_at FROM container WHERE id = ?", [version.post.id]) == nil)
        }
    }
}
