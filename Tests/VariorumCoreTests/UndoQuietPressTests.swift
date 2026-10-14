import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-246 U2 — THE UNDO CLASS (VX-276 · VX-277 · VX-119): one rule for every entry,
// the MCP door's and her own doors' alike — AN UNDO WRITES ONLY OVER THE ACT'S OWN
// RESULT, AND A REDO AFTER A QUIET UNDO STAYS QUIET.
//
// The mechanism these pins catch (the run record's U2 UNIT RECORD, "The mechanism,
// traced"): `UndoStack.undo` moved ANY inverse that did not throw onto the redo
// stack — a QUIET one included (an inverse that found the world already moved past
// its entry and wrote nothing) — and the redo then ran against whatever the rows
// read, checking only for the pre-act state that her own undo-less doors (Put back,
// restore, unlock, reopen, rename back, her ✓ back, unarchive, delete) produce. So
// act → her reversal → ⌥⌘Z (quiet) → ⇧⌥⌘Z wrote the act over hers. The same in the
// MIRROR order (⌥⌘Z wrote → she changed it → ⇧⌥⌘Z quiet → ⌥⌘Z un-did her change),
// for the PARTS of an entry with several (her ✓ back on ONE adopted slot), and on
// the revive road when the row died since on another stamp.
//
// Every pin is written against the PRE-FIX API (`undo(with:)` / `redo(with:)`,
// rows read back), each checking its premise — her door registered nothing — and
// each red on the pre-fix tree (the record's piece 1), red again by revert.

@Suite("VX-246 U2 — an undo writes only over the act's own result; a redo after a quiet undo stays quiet")
struct UndoQuietPressTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    private func chosen(_ db: AppDatabase, _ blockID: String) throws -> String? {
        try db.fetchString(
            "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL", [blockID])
    }

    // MARK: - VX-276: the round-2 reviewer's five probes (one per direction)

    /// TOGGLE: the client locks; she unlocks (no entry); ⌥⌘Z finds it unlocked —
    /// quiet; ⇧⌥⌘Z must not lock the take she unlocked.
    @Test func lockRedoAfterQuietUndo() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let take = try ops.seedBlock(in: note.id, text: "Her opening.").variant.id
            stack.removeAll()

            _ = try ops.lockTakeForClient(take, locked: true, undoLabel: label(.takeLock))
            try ops.unlockVariant(take)
            #expect(stack.depth == 1, "her unlock registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.fetchInt("SELECT locked FROM variant WHERE id = ?", [take]) == 0,
                    "her unlock stands: a redo after a quiet undo stays quiet")
        }
    }

    /// TOGGLE (a book): the client finishes; she reopens (no entry); ⌥⌘Z quiet;
    /// ⇧⌥⌘Z must not finish her open book again.
    @Test func finishRedoAfterQuietUndo() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            stack.removeAll()

            _ = try ops.setBookFinishedForClient(book.id, finished: true, undoLabel: label(.bookFinish))
            try ops.unlockReading(book.id)
            #expect(stack.depth == 1, "her reopen registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.fetchInt("SELECT locked FROM reading WHERE id = ?", [book.id]) == 0,
                    "her reopen stands")
        }
    }

    /// VALUE: the client renames; she renames it BACK (no entry); ⌥⌘Z quiet;
    /// ⇧⌥⌘Z must not write the client's name over hers.
    @Test func renameBackToOriginalThenQuietUndoThenRedo() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            stack.removeAll()

            _ = try ops.renameBookForClient(book.id, name: "drafts, revised", undoLabel: label(.bookName))
            try ops.renameReading(book.id, name: "drafts")
            #expect(stack.depth == 1, "her rename registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.fetchString("SELECT name FROM reading WHERE id = ?", [book.id]) == "drafts",
                    "her name stands")
        }
    }

    /// DELETE: the client deletes a note; she Puts it back from the Trash (no
    /// entry); ⌥⌘Z quiet; ⇧⌥⌘Z must not send it back to the Trash.
    @Test func deleteNoteRedoAfterHerPutBackAndAQuietUndo() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            _ = try ops.seedBlock(in: note.id, text: "Her opening.")
            stack.removeAll()

            _ = try ops.deleteNoteForClient(note.id, undoLabel: label(.noteDelete))
            try ops.restoreContainer(note.id)
            #expect(stack.depth == 1, "her Put back registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("container", note.id) == nil, "the note she put back stays")
        }
    }

    /// DELETE (a chapter): the client deletes; she restores it (no entry); ⌥⌘Z
    /// quiet; ⇧⌥⌘Z must not delete it again.
    @Test func deleteChapterRedoAfterHerRestoreAndAQuietUndo() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "one")
            stack.removeAll()

            _ = try ops.deleteChapterForClient(chapter.id, undoLabel: label(.chapterDelete))
            try ops.restoreSection(chapter.id)
            #expect(stack.depth == 1, "her restore registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("reading_section", chapter.id) == nil, "the chapter she restored stays")
        }
    }

    // MARK: - VX-276: the REVIVE family (the round-1 sweep's adjacent class)

    /// add_comment: she deletes the client's comment (no entry); ⌥⌘Z quiet;
    /// ⇧⌥⌘Z must not bring back the comment she deleted.
    @Test func aCommentSheDeletedStaysDeleted() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let block = try ops.seedBlock(in: note.id, text: "Her opening.").block.id
            stack.removeAll()

            let comment = try ops.addComment(
                toBlock: block, text: "consider a shorter close", author: client, undoLabel: label(.comment))
            try ops.deleteBlockComment(comment.id)
            #expect(stack.depth == 1, "her delete registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("block_comment", comment.id) != nil, "her delete stands")
        }
    }

    /// apply_tag: she takes the tag off (no entry); ⌥⌘Z quiet; ⇧⌥⌘Z must not
    /// put the very application back.
    @Test func aTagSheTookOffStaysOff() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            stack.removeAll()

            let application = try ops.applyTagPath("travel", toPost: note.id, undoLabel: label(.tag))
            try ops.removeTag(application.tagId, fromPost: note.id)
            #expect(stack.depth == 1, "her un-tag registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND deleted_at IS NULL", [note.id]) == 0,
                "her un-tag stands")
        }
    }

    /// create_section: she deletes the client's chapter (no entry); ⌥⌘Z quiet;
    /// ⇧⌥⌘Z must not revive it.
    @Test func aChapterSheDeletedStaysDeleted() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            stack.removeAll()

            let chapter = try ops.createSection(in: book.id, name: "one", undoLabel: label(.chapter))
            try ops.deleteSection(chapter.id)
            #expect(stack.depth == 1, "her chapter delete registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("reading_section", chapter.id) != nil, "her delete stands")
        }
    }

    /// create_note: she deletes the client's note (her Delete clears the redo
    /// future, never the undo stack); ⌥⌘Z quiet; ⇧⌥⌘Z must not revive it.
    @Test func aClientsNoteSheDeletedStaysDeleted() throws {
        try withUndo { ops, stack, db in
            stack.removeAll()
            let minted = try ops.createNote(
                title: "notes on chapter 1", text: "A first thought.", in: .wing(""), undoLabel: label(.note))
            try ops.deleteContainer(minted.post.id)
            #expect(stack.depth == 1, "her delete registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("container", minted.post.id) != nil, "her delete stands")
        }
    }

    /// add_note_to_book's SEAT (the other order): ⌥⌘Z demotes the seated arrival
    /// back to the door (it WROTE); she dismisses it there (no entry); ⇧⌥⌘Z must
    /// not re-seat the pair she decided.
    @Test func aSeatSheDismissedAfterTheUndoStaysDismissed() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "lessons", kind: .book)
            let waiting = try ops.createPost(title: "waiting")
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                    VALUES ('arrival-w', ?, ?, 'a5', 'arrival', '2026-07-01T00:00:00.000Z')
                    """, arguments: [book.id, waiting.id])
            }
            stack.removeAll()

            _ = try ops.addNoteToBook(waiting.id, book: book.id, undoLabel: label(.bookAdd))
            _ = try stack.undo(with: ops)
            #expect(try db.fetchString("SELECT status FROM reading_post WHERE id = 'arrival-w'") == "arrival")
            try ops.dismissArrival("arrival-w")
            #expect(stack.redoDepth == 1, "her dismissal clears no future")
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("reading_post", "arrival-w") != nil, "her dismissal stands")
        }
    }

    // MARK: - VX-276: the MIRROR order (an undo after a quiet redo stays quiet)

    /// The client renames A→B; ⌥⌘Z writes A; she renames it to B herself (no
    /// entry); ⇧⌥⌘Z is quiet (the name no longer reads A); ⌥⌘Z must not write A
    /// over the name she chose.
    @Test func anUndoAfterAQuietRedoLeavesHerValueAlone() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            stack.removeAll()

            _ = try ops.renameBookForClient(book.id, name: "letters", undoLabel: label(.bookName))
            _ = try stack.undo(with: ops)
            #expect(try db.fetchString("SELECT name FROM reading WHERE id = ?", [book.id]) == "drafts")
            try ops.renameReading(book.id, name: "letters")
            _ = try stack.redo(with: ops)
            _ = try stack.undo(with: ops)
            #expect(try db.fetchString("SELECT name FROM reading WHERE id = ?", [book.id]) == "letters",
                    "the name she gave it stands")
        }
    }

    // MARK: - VX-276: an entry with PARTS (the client's adopt over two slots)

    /// adopt_lens over two blocks; her ✓ puts block 1 BACK on its pre-adopt take;
    /// ⌥⌘Z walks block 2 back (block 1 is already there — quiet for that slot);
    /// ⇧⌥⌘Z must re-adopt block 2 only, never re-choose over her ✓ on block 1.
    @Test func aClientsAdoptRedoLeavesTheSlotSheSetBackAlone() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "Her opening.")
            let o1 = try ops.branchVariant(one.block.id, from: one.variant.id).id
            let two = try ops.seedBlock(in: note.id, text: "Her close.")
            let o2 = try ops.branchVariant(two.block.id, from: two.variant.id).id
            let lens = try ops.createLens(post: note.id, name: "the other cut")
            _ = try ops.setLensChoice(lens: lens.id, block: one.block.id, variant: o1)
            _ = try ops.setLensChoice(lens: lens.id, block: two.block.id, variant: o2)
            stack.removeAll()

            _ = try ops.adoptLensAsNote(lens.id, undoLabel: label(.lensAdoption))
            try ops.chooseVariant(one.block.id, variantID: one.variant.id)
            #expect(stack.depth == 1, "her ✓ registers nothing")
            _ = try stack.undo(with: ops)
            #expect(try chosen(db, two.block.id) == two.variant.id)
            _ = try stack.redo(with: ops)
            #expect(try chosen(db, one.block.id) == one.variant.id, "her ✓ back on block 1 stands")
            #expect(try chosen(db, two.block.id) == o2, "the slot the undo walked back is adopted again")
        }
    }

    // MARK: - VX-277: her own adopt doors (the value class, then the parts)

    /// Her own "✓ Make this the note" (the preserving adopt): her later ✓ on an
    /// adopted block survives the adopt's undo.
    @Test func herAdoptsUndoLeavesHerLaterCheckmarkAlone() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "Her opening.")
            let o1 = try ops.branchVariant(one.block.id, from: one.variant.id).id
            let t1 = try ops.branchVariant(one.block.id, from: one.variant.id).id
            let two = try ops.seedBlock(in: note.id, text: "Her close.")
            let o2 = try ops.branchVariant(two.block.id, from: two.variant.id).id
            let lens = try ops.createLens(post: note.id, name: "the other cut")
            _ = try ops.setLensChoice(lens: lens.id, block: one.block.id, variant: o1)
            _ = try ops.setLensChoice(lens: lens.id, block: two.block.id, variant: o2)
            stack.removeAll()

            _ = try ops.adoptLensPreservingChosen(lens.id)
            #expect(try chosen(db, one.block.id) == o1 && chosen(db, two.block.id) == o2)
            try ops.chooseVariant(one.block.id, variantID: t1)
            #expect(stack.depth == 1, "her ✓ registers nothing")
            _ = try stack.undo(with: ops)
            #expect(try chosen(db, one.block.id) == t1, "her later ✓ survives her adopt's undo")
            #expect(try chosen(db, two.block.id) == two.variant.id, "the slot she left alone walks back")
        }
    }

    /// Her own adopt, the parts: her ✓ BACK on block 1; ⌥⌘Z walks block 2 back;
    /// ⇧⌥⌘Z must re-adopt block 2 only.
    @Test func herAdoptsRedoLeavesTheSlotSheSetBackAlone() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "Her opening.")
            let o1 = try ops.branchVariant(one.block.id, from: one.variant.id).id
            let two = try ops.seedBlock(in: note.id, text: "Her close.")
            let o2 = try ops.branchVariant(two.block.id, from: two.variant.id).id
            let lens = try ops.createLens(post: note.id, name: "the other cut")
            _ = try ops.setLensChoice(lens: lens.id, block: one.block.id, variant: o1)
            _ = try ops.setLensChoice(lens: lens.id, block: two.block.id, variant: o2)
            stack.removeAll()

            _ = try ops.adoptLensPreservingChosen(lens.id)
            try ops.chooseVariant(one.block.id, variantID: one.variant.id)
            _ = try stack.undo(with: ops)
            #expect(try chosen(db, two.block.id) == two.variant.id)
            _ = try stack.redo(with: ops)
            #expect(try chosen(db, one.block.id) == one.variant.id, "her ✓ back on block 1 stands")
            #expect(try chosen(db, two.block.id) == o2, "block 2 is adopted again")
        }
    }

    // MARK: - VX-277: her own Delete Block after a tray Put back

    @Test func deleteBlockRedoAfterHerPutBackAndAQuietUndo() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            _ = try ops.seedBlock(in: note.id, text: "Her opening.")
            let block = try ops.seedBlock(in: note.id, text: "Her close.").block.id
            stack.removeAll()

            try ops.deleteBlock(block)
            _ = try ops.restoreBlock(block)
            #expect(stack.depth == 1, "her Put back registers nothing")
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("block", block) == nil, "the block she put back stays")
        }
    }

    // MARK: - VX-119: the single-container pair (the single-file import, the copies)

    private func document(_ title: String) -> VariorumDocument.NamedDocument {
        VariorumDocument.NamedDocument(fallbackTitle: title, document: .init(blocks: [.init(text: "\(title) text")]))
    }

    /// The ticket's own sequence: import one file → she deletes the note → ⌥⌘Z
    /// (already dead — quiet) → ⇧⌥⌘Z must not bring back the note she deleted.
    @Test func anImportedNoteSheDeletedStaysDeleted() throws {
        try withUndo { ops, stack, db in
            stack.removeAll()
            let imported = try ops.importDocument(document("letters"))
            try ops.deleteContainer(imported.post.id)
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("container", imported.post.id) != nil, "her delete stands")
        }
    }

    /// The copy ops ride the same pair: Duplicate as Version → she deletes the
    /// copy → ⌥⌘Z quiet → ⇧⌥⌘Z must not revive it.
    @Test func aCopySheDeletedStaysDeleted() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            _ = try ops.seedBlock(in: note.id, text: "Her opening.")
            stack.removeAll()

            let copy = try ops.duplicateAsVersion(note.id)
            try ops.deleteContainer(copy.post.id)
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("container", copy.post.id) != nil, "her delete stands")
        }
    }

    /// The F1 shape (the stamp the inverse wrote): ⌥⌘Z tombstones the imported
    /// note on its own stamp; the note then dies on ANOTHER stamp by a road that
    /// clears no redo future (a sync apply from another device writes the row);
    /// ⇧⌥⌘Z must revive only what its own undo tombstoned — nothing here.
    @Test func aRedoRevivesOnlyWhatItsOwnUndoTombstoned() throws {
        try withUndo { ops, stack, db in
            stack.removeAll()
            let imported = try ops.importDocument(document("letters"))
            _ = try stack.undo(with: ops)
            let undoStamp = try #require(try db.deletedAt("container", imported.post.id))
            // Another device's tombstone, converged server-wins: the same row,
            // another stamp (and its cascade) — no door of this session's.
            let elsewhere = "2026-07-02T09:00:00.000Z"
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container SET deleted_at = ? WHERE id = ?", arguments: [elsewhere, imported.post.id])
            }
            #expect(try db.deletedAt("container", imported.post.id) != undoStamp)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("container", imported.post.id) == elsewhere,
                    "the redo revives only rows dead on its own undo's stamp")
        }
    }

    // MARK: - Entries with parts, the mirror order (her own and the client's)

    /// Her merge: the merged block carries her later words, so ⌥⌘Z sends it to
    /// the tray; she Puts it back (no entry); ⇧⌥⌘Z re-releases the two sources
    /// (the merged block is already back — that part is quiet); ⌥⌘Z must return
    /// the sources only, never tombstone the block she put back.
    @Test func herMergeLeavesTheBlockSheRestoredBetweenRedoAndUndo() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let b = try ops.seedBlock(in: note.id, text: "First.").block.id
            let c = try ops.seedBlock(in: note.id, text: "Second.").block.id
            stack.removeAll()

            let merged = try ops.merge(b, c)
            try ops.autosave(merged.variant.id, text: "First.\nSecond, revised.", charDelta: 9)
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("block", merged.block.id) != nil)
            _ = try ops.restoreBlock(merged.block.id)
            #expect(stack.redoDepth == 1, "her Put back clears no future")
            _ = try stack.redo(with: ops)
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("block", merged.block.id) == nil, "the block she put back stays")
        }
    }

    /// The client's batch of two takes: ⌥⌘Z tombstones both; she Puts ONE back
    /// from the tray (no entry); ⇧⌥⌘Z revives the other; ⌥⌘Z must take back only
    /// what the redo brought back.
    @Test func aBatchLeavesTheTakeSheRestoredBetweenRedoAndUndo() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let block = try ops.seedBlock(in: note.id, text: "Her opening.").block.id
            stack.removeAll()

            let takes = try ops.addTakes(
                [.init(blockID: block, text: "A.", label: nil), .init(blockID: block, text: "B.", label: nil)],
                inNote: note.id, undoLabel: label(.takes))
            _ = try stack.undo(with: ops)
            _ = try ops.restoreVariant(takes[0].id)
            #expect(stack.redoDepth == 1, "her Put back clears no future")
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("variant", takes[1].id) == nil)
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("variant", takes[0].id) == nil, "the take she put back stays")
            #expect(try db.deletedAt("variant", takes[1].id) != nil, "the redo's own take goes again")
        }
    }

    /// The client's rule over TWO columns (the rule and the dial); she sets the
    /// dial BACK (her Save — no entry); ⌥⌘Z walks the rule back (the dial is
    /// already back — quiet for that column); ⇧⌥⌘Z must re-apply the rule only.
    @Test func aBookRulesRedoLeavesTheColumnSheSetBackAlone() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let seating = { try db.fetchString("SELECT intake_seating FROM reading WHERE id = ?", [book.id]) }
            let spec = { try db.fetchString("SELECT query_spec FROM reading WHERE id = ?", [book.id]) }
            stack.removeAll()

            _ = try ops.setBookRule(
                book.id, Operations.MCPBookRuleWrite(rule: .some(.tag("percy")), seating: .arrivals),
                undoLabel: label(.bookRule))
            #expect(try seating() == "arrivals" && spec() != nil)
            try ops.setReadingIntakeSeating(book.id, nil)
            #expect(stack.depth == 1, "her Save registers nothing")
            _ = try stack.undo(with: ops)
            #expect(try spec() == nil)
            _ = try stack.redo(with: ops)
            #expect(try spec() != nil, "the rule the undo walked back is applied again")
            #expect(try seating() == nil, "the dial she set back stands")
        }
    }

    /// Imported paste blocks: ⌥⌘Z sends both to the tray; she Puts ONE back;
    /// ⇧⌥⌘Z brings the other; ⌥⌘Z must take back only that one.
    @Test func importedBlocksLeaveTheBlockSheRestoredBetweenRedoAndUndo() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            _ = try ops.seedBlock(in: note.id, text: "Her opening.")
            stack.removeAll()

            let imported = try ops.importBlocks(into: note.id, text: "First pasted.\n\nSecond pasted.")
            #expect(imported.blockIDs.count == 2)
            _ = try stack.undo(with: ops)
            _ = try ops.restoreBlock(imported.blockIDs[0])
            #expect(stack.redoDepth == 1, "her Put back clears no future")
            _ = try stack.redo(with: ops)
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("block", imported.blockIDs[0]) == nil, "the block she put back stays")
            #expect(try db.deletedAt("block", imported.blockIDs[1]) != nil, "the redo's own block goes again")
        }
    }
}
