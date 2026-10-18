import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-357 — U+0000 NEVER REACHES THE STORE: one state-transition pin per
/// text-writing op family** (her ruling 2026-10-15; the run record
/// `notes/plans/fixes/vx-348-prelaunch-sweep.md`, U1 UNIT RECORD).
///
/// The bug these pin: GRDB binds TEXT with length -1, so SQLite reads a bound
/// value only up to its first NUL — "before\0after" landed as "before", the
/// rest of the take LOST, on every road. Each pin writes text holding U+0000
/// through ONE op family's real door and reads the row back two ways: the
/// text (what every read returns) AND its byte length (`length(CAST(… AS
/// BLOB))` — the store's own count, so a truncated row can never pass by
/// reading as a shorter string that happens to compare). Each expects the
/// text with every null character REMOVED and nothing else changed.
///
/// **RED ON OLD by construction**, with no new API named: on the tree before
/// the fix every row here holds only the text up to its first NUL (the
/// prefix), so each `#expect` on the stripped text fails. Verified on the
/// pre-fix tree itself (the run record's red-on-old leg).
@Suite("VX-357 — every text-writing op family stores the text without U+0000")
struct StoredTextNullStripTests {
    /// The text a column holds, and its byte count.
    private func stored(
        _ db: AppDatabase, _ table: String, _ column: String, _ id: String
    ) throws -> (text: String?, bytes: Int?) {
        (try db.fetchString("SELECT \(column) FROM \(table) WHERE id = ?", [id]),
         try db.fetchInt("SELECT length(CAST(\(column) AS BLOB)) FROM \(table) WHERE id = ?", [id]))
    }

    private func expectStripped(
        _ db: AppDatabase, _ table: String, _ column: String, _ id: String, _ expected: String,
        _ what: String, sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let row = try stored(db, table, column, id)
        #expect(row.text == expected, "\(what): the text without its null characters", sourceLocation: sourceLocation)
        #expect(row.bytes == expected.utf8.count, "\(what): every byte after the NUL kept", sourceLocation: sourceLocation)
    }

    // MARK: - Takes (the working buffer)

    /// Autosave (her typing and every paste into a block), a fresh block (the
    /// crystallizer's and ⌘⇧⏎'s mint), and bulk entry (a paste into the open
    /// tail, a drop — `importBlocks`).
    @Test func takesKeepEveryWordAroundANullCharacter() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let minted = try ops.newBlock(in: post.id, text: "born\u{0}whole", registeringUndo: false)
            try expectStripped(db, "variant", "working_text", minted.variant.id, "bornwhole", "newBlock")

            try ops.autosave(minted.variant.id, text: "before\u{0}after", charDelta: 3)
            try expectStripped(db, "variant", "working_text", minted.variant.id, "beforeafter", "autosave")

            let imported = try ops.importBlocks(into: post.id, text: "pasted\u{0} in\u{0}\u{0} bulk")
            let pastedTake = try #require(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [imported.blockIDs[0]]))
            try expectStripped(db, "variant", "working_text", pastedTake, "pasted in bulk", "importBlocks")
        }
    }

    /// The cross-block compound (her visible-take edit across blocks and
    /// Delete in Every Take): the replacement text lands without the null.
    @Test func theCrossBlockCompoundStoresItsTextWithoutTheNull() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let minted = try ops.seedBlock(in: post.id, text: "one two")
            _ = try ops.editTakesAtomically(
                [.init(variantID: minted.variant.id, newText: "one\u{0} two three", charDelta: 7)],
                undoLabel: "Edit")
            try expectStripped(db, "variant", "working_text", minted.variant.id, "one two three", "editTakesAtomically")
        }
    }

    // MARK: - Titles, floating notes, references

    @Test func titlesNotesAndReferencesStoreWithoutTheNull() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Chapter\u{0} one")
            try expectStripped(db, "container", "title", post.id, "Chapter one", "createPost")
            try ops.renameContainer(post.id, title: "Chapter\u{0} two")
            try expectStripped(db, "container", "title", post.id, "Chapter two", "renameContainer")
            try ops.updateFloatingNotes(post.id, notes: "remember\u{0} this")
            try expectStripped(db, "container", "floating_notes", post.id, "remember this", "updateFloatingNotes")
            let reference = try ops.addReference(
                to: post.id, kind: .url, name: "a\u{0}source", url: "https://example.com/\u{0}page")
            try expectStripped(db, "reference", "name", reference.id, "asource", "addReference name")
            try expectStripped(db, "reference", "url", reference.id, "https://example.com/page", "addReference url")
        }
    }

    // MARK: - Labels, names, commit messages

    @Test func labelsNamesAndCommitMessagesStoreWithoutTheNull() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let minted = try ops.seedBlock(in: post.id, text: "Some prose.")
            try ops.setTakeLabel(minted.variant.id, label: "eng\u{0}lish")
            try expectStripped(db, "variant", "label", minted.variant.id, "english", "setTakeLabel")
            try ops.setBlockName(minted.block.id, name: "The\u{0} opening")
            try expectStripped(db, "block", "name", minted.block.id, "The opening", "setBlockName")

            let saved = try ops.commit(minted.variant.id, message: "first\u{0} draft")
            try expectStripped(db, "commit_point", "message", saved.id, "first draft", "commit message")
            try ops.renameCommitPoint(saved.id, message: "second\u{0} draft")
            try expectStripped(db, "commit_point", "message", saved.id, "second draft", "renameCommitPoint")

            let lens = try ops.createLens(post: post.id, name: "my\u{0} lens")
            try expectStripped(db, "lens", "name", lens.id, "my lens", "createLens")
            try ops.renameLens(lens.id, newName: "our\u{0} lens")
            try expectStripped(db, "lens", "name", lens.id, "our lens", "renameLens")
        }
    }

    @Test func libraryNamesStoreWithoutTheNull() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Field\u{0} notes", kind: .book)
            try expectStripped(db, "reading", "name", book.id, "Field notes", "createReading")
            try ops.renameReading(book.id, name: "Field\u{0} guide")
            try expectStripped(db, "reading", "name", book.id, "Field guide", "renameReading")

            let chapter = try ops.createSection(in: book.id, name: "Part\u{0} one")
            try expectStripped(db, "reading_section", "name", chapter.id, "Part one", "createSection")
            try ops.renameSection(chapter.id, name: "Part\u{0} two")
            try expectStripped(db, "reading_section", "name", chapter.id, "Part two", "renameSection")

            let shelf = try ops.createShelf(name: "Top\u{0} shelf")
            try expectStripped(db, "shelf", "name", shelf.id, "Top shelf", "createShelf")
            let wing = try ops.createWing(name: "East\u{0} wing")
            try expectStripped(db, "wing", "name", wing.id, "East wing", "createWing")

            let tag = try ops.createTag(name: "ide\u{0}as")
            try expectStripped(db, "tag", "name", tag.id, "ideas", "createTag name")
            try expectStripped(db, "tag", "path", tag.id, "ideas", "createTag path")
            try ops.renameTag(tag.id, newName: "the\u{0}mes")
            try expectStripped(db, "tag", "name", tag.id, "themes", "renameTag name")
            try expectStripped(db, "tag", "path", tag.id, "themes", "renameTag path")
        }
    }

    // MARK: - Comments

    @Test func commentsStoreWithoutTheNull() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let minted = try ops.seedBlock(in: post.id, text: "Some prose.")
            let comment = try ops.addBlockComment(to: minted.block.id, text: "check\u{0} this")
            try expectStripped(db, "block_comment", "text", comment.id, "check this", "addBlockComment")
            try ops.editBlockComment(comment.id, text: "checked\u{0} it")
            try expectStripped(db, "block_comment", "text", comment.id, "checked it", "editBlockComment")
        }
    }

    // MARK: - The import (her File ▸ Import… and the Bookcase drop)

    @Test func theDocumentAndBookImportsStoreEveryTextWithoutTheNull() throws {
        try withOperations { ops, db in
            let document = VariorumDocument.Document(
                title: "Ti\u{0}tle", tagPaths: ["topic/sub\u{0}topic"],
                blocks: [.init(text: "In\u{0} place.", alternates: [.init(label: "alt\u{0}", text: "Other\u{0} way.")])])
            let imported = try ops.importDocument(.init(fallbackTitle: "file", document: document))
            try expectStripped(db, "container", "title", imported.post.id, "Title", "importDocument title")
            let shown = try #require(imported.blocks.first)
            try expectStripped(db, "variant", "working_text", shown.takes[0].id, "In place.", "importDocument text")
            try expectStripped(db, "variant", "working_text", shown.takes[1].id, "Other way.", "importDocument alternate")
            try expectStripped(db, "variant", "label", shown.takes[1].id, "alt", "importDocument label")
            let tagPath = try db.fetchString(
                """
                SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                """, [imported.post.id])
            #expect(tagPath == "topic/subtopic", "the header's tag path, as stored")

            let book = try ops.importBook(.init(
                name: "Bo\u{0}ok",
                chapters: [.init(name: "Chap\u{0}ter", notes: [.init(fallbackTitle: "n", document: .init(blocks: [.init(text: "x")]))])],
                unfiled: []))
            try expectStripped(db, "reading", "name", book.reading.id, "Book", "importBook name")
            try expectStripped(db, "reading_section", "name", book.sectionIDs[0], "Chapter", "importBook chapter")
        }
    }

    // MARK: - The wire's acts (the ops under `VariorumMCP` — their rows AND their undo entries)

    /// The MCP door's own acts store the text without the null, and each act's
    /// ONE client-named entry holds the STORED form: its compare-and-set halves
    /// check the row against what was written, so ⌥⌘Z walks the act back and
    /// ⇧⌥⌘Z re-applies it. (Holding the SENT form, a half would find the row
    /// "changed since" and retire quietly — her undo would do nothing.)
    @Test func theWiresActsStoreWithoutTheNullAndTheirUndoRoundTrips() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note")
            let minted = try ops.seedBlock(in: post.id, text: "Her words.")
            let take = try ops.addTake(
                toBlock: minted.block.id, text: "A\u{0} suggestion.", label: "claude\u{0}", undoLabel: "x")
            try expectStripped(db, "variant", "working_text", take.id, "A suggestion.", "addTake text")
            try expectStripped(db, "variant", "label", take.id, "claude", "addTake label")
            #expect(take.workingText == "A suggestion.", "the returned row — what the wire digests — is the stored one")

            let edit = try ops.editTakeUnderInsurance(
                minted.variant.id, text: "Her\u{0} words, revised.", expectedText: "Her words.",
                client: "claude-code", undoLabel: "edit")
            #expect(edit.changed && edit.take.workingText == "Her words, revised.")
            try expectStripped(db, "variant", "working_text", minted.variant.id, "Her words, revised.", "edit_take")
            #expect(try stack.undo(with: ops) == "edit")
            try expectStripped(db, "variant", "working_text", minted.variant.id, "Her words.", "edit_take's undo")
            #expect(try stack.redo(with: ops) == "edit")
            try expectStripped(db, "variant", "working_text", minted.variant.id, "Her words, revised.", "edit_take's redo")

            let comment = try ops.addComment(
                toBlock: minted.block.id, text: "Tighten\u{0} this.", author: "claude-code", undoLabel: "comment")
            try expectStripped(db, "block_comment", "text", comment.id, "Tighten this.", "add_comment")
            _ = try ops.editCommentForClient(
                comment.id, text: "Tighten\u{0} this, please.", expectedText: "Tighten this.", undoLabel: "comment edit")
            try expectStripped(db, "block_comment", "text", comment.id, "Tighten this, please.", "edit_comment")
            #expect(try stack.undo(with: ops) == "comment edit")
            try expectStripped(db, "block_comment", "text", comment.id, "Tighten this.", "edit_comment's undo")
            #expect(try stack.redo(with: ops) == "comment edit")
            try expectStripped(db, "block_comment", "text", comment.id, "Tighten this, please.", "edit_comment's redo")

            let renamed = try ops.renameNoteForClient(post.id, title: "Re\u{0}named", undoLabel: "rename")
            #expect(renamed.changed && renamed.title == "Renamed")
            try expectStripped(db, "container", "title", post.id, "Renamed", "rename_note")
            #expect(try stack.undo(with: ops) == "rename")
            try expectStripped(db, "container", "title", post.id, "note", "rename_note's undo")
        }
    }

    /// The bulk-entry import door (her capture and the sidebar's import):
    /// the title and the segmented text.
    @Test func theBulkImportDoorStoresItsTitleAndTextWithoutTheNull() throws {
        try withOperations { ops, db in
            let result = try ops.importPost(title: "Cap\u{0}ture", text: "A\u{0} thought.")
            try expectStripped(db, "container", "title", result.container.id, "Capture", "importPost title")
            let take = try #require(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [result.blockIDs[0]]))
            try expectStripped(db, "variant", "working_text", take, "A thought.", "importPost text")
        }
    }
}
