import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// **VX-372 (VX-383 U1 — D-C-1): the tag CHOICE — "Duplicate without Tags"**, and the two
/// verbs as the act's own words. The copy is otherwise exactly the with-tags copy (her door's
/// one body: whole fans, one `derived_from` per block, one `version_of`, bookless in the
/// source's wing); it simply wears no tag, so no book hears it. Each choice registers ONE
/// entry under its own verb (P-C-1, PROVISIONAL), and the MCP door's body takes the same
/// choice (D-311-1's no-drift extraction).
///
/// NEW API (`duplicateAsVersion(_:tags:)`, `DuplicateTags`), so these are state pins, green by
/// construction — red-on-old by compilation (the pre-fix tree has no tag choice: its duplicate
/// always wore the source's tags). The behavioural revert check (the U1 record, piece 6) turns
/// `.none` back into a tag ride and watches `aDuplicateWithoutTagsWearsNoneAndNoBookHearsIt` fail.
@Suite("VX-372 — Duplicate without Tags; the two verbs")
struct DuplicateWithoutTagsTests {
    private func liveTagCount(_ db: AppDatabase, post: String) throws -> Int {
        try db.fetchInt(
            "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND deleted_at IS NULL", [post]) ?? -1
    }

    private func pairRowCount(_ db: AppDatabase, post: String) throws -> Int {
        try db.fetchInt("SELECT COUNT(*) FROM reading_post WHERE post_id = ?", [post]) ?? -1
    }

    @Test func theTwoVerbsAreTheDoorsWords() {
        #expect(Operations.DuplicateTags.applied.verb == "Duplicate with Tags")
        #expect(Operations.DuplicateTags.none.verb == "Duplicate without Tags")
        #expect(Operations.DuplicateTags.allCases == [.applied, .none])
    }

    /// Without tags: the copy wears none, and a living book whose rule names the source's tag
    /// never hears it — no member, no arrival, no dismissal row. Everything else is her door's
    /// copy: the blocks, one `derived_from` each, the one `version_of`, the source untouched.
    @Test func aDuplicateWithoutTagsWearsNoneAndNoBookHearsIt() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            let living = try ops.createReading(
                name: "drafts", kind: .book, querySpec: try RuleGrammar.encode(.tag(draft.id)))
            let source = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: source.id, text: "One.")
            _ = try ops.seedBlock(in: source.id, text: "Two.")
            try ops.applyTag(draft.id, toPost: source.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                [living.id]) == 1, "the source was taken in by her act")

            let copy = try ops.duplicateAsVersion(source.id, tags: .none)

            #expect(try liveTagCount(db, post: copy.post.id) == 0, "the copy wears no tag")
            #expect(try pairRowCount(db, post: copy.post.id) == 0, "no book heard it")
            #expect(try liveTagCount(db, post: source.id) == 1, "the source keeps its own")
            #expect(copy.blockCopies.count == 2)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM edge WHERE type = 'derived_from' AND deleted_at IS NULL
                  AND source_block_id IN (SELECT block_id FROM container_block
                                          WHERE container_id = ? AND deleted_at IS NULL)
                """, [copy.post.id]) == 2, "one derived_from per copied block")
            #expect(copy.versionEdge.type == .versionOf)
            #expect(try db.fetchString("SELECT wing_id FROM container WHERE id = ?", [copy.post.id]) == "")
        }
    }

    /// Each choice is ONE entry under its own verb; its undo tombstones the copy, its redo
    /// revives it.
    @Test func eachChoiceUndoesAndRedoesUnderItsOwnVerb() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let source = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: source.id, text: "One.")
            for choice in Operations.DuplicateTags.allCases {
                let copy = try ops.duplicateAsVersion(source.id, tags: choice)
                #expect(stack.topLabel == choice.verb)
                #expect(try stack.undo(with: ops) == choice.verb)
                #expect(try db.deletedAt("container", copy.post.id) != nil)
                #expect(try stack.redo(with: ops) == choice.verb)
                #expect(try db.deletedAt("container", copy.post.id) == nil)
            }
        }
    }

    /// The MCP door's body takes the same choice (one body, D-311-1): without tags, the wire's
    /// copy wears none and no book hears it; the default is her door's with-tags.
    @Test func theWiresBodyTakesTheSameChoice() throws {
        try withOperations { ops, db in
            let draft = try ops.createTag(name: "draft")
            _ = try ops.createReading(
                name: "drafts", kind: .book, querySpec: try RuleGrammar.encode(.tag(draft.id)))
            let source = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: source.id, text: "One.")
            try ops.applyTag(draft.id, toPost: source.id)

            let bare = try ops.duplicateNoteForClient(
                source.id, tags: .none, undoLabel: "claude-code's duplicate")
            #expect(try liveTagCount(db, post: bare.post.id) == 0)
            #expect(try pairRowCount(db, post: bare.post.id) == 0)

            let tagged = try ops.duplicateNoteForClient(source.id, undoLabel: "claude-code's duplicate")
            #expect(try liveTagCount(db, post: tagged.post.id) == 1)
            #expect(try pairRowCount(db, post: tagged.post.id) == 1, "the default: with tags, heard")
        }
    }
}
