import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-b U3 R2 — THE MCP DOOR's EDIT-RUNG ACTS (R-13n-4's edit rung; R-13n-7's
// insurance; R-13n-6's paper trail; AF-10): exact state transitions, the
// named bracketing commits, ONE client-named undo entry per act whose inverse
// and redo round-trip the same rows, and the in-transaction WRITE GUARD
// (the U2 ladder's F2, closed rung-wide). Who may act is the server's
// per-call rule (`MCPEditServerTests`).

private struct GuardRefused: Error, Equatable {}

@Suite("13n-b U3 — the MCP edit-rung acts, their insurance and their undo")
struct MCPEditActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    private func commits(_ db: AppDatabase, _ variantID: String) throws -> [Row] {
        try db.read { db in
            try Row.fetchAll(
                db, sql: "SELECT * FROM commit_point WHERE variant_id = ? ORDER BY created_at, id",
                arguments: [variantID])
        }
    }

    // MARK: - edit_take: the eighth occasion

    @Test func anEditLandsBracketedByTheNamedCommitsAndUndoesInOne() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "her paragraph, never committed")
            let touched = try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id])

            let edit = try ops.editTakeUnderInsurance(
                seeded.variant.id, text: "the client's rewrite", expectedText: "her paragraph, never committed",
                client: client, undoLabel: label(.edit))
            #expect(edit.changed)
            #expect(edit.take.workingText == "the client's rewrite")
            let history = try commits(db, seeded.variant.id)
            #expect(history.map { $0["message"] as String? } == ["before claude-code's edit", "after claude-code's edit"])
            #expect(history.map { $0["text"] as String } == ["her paragraph, never committed", "the client's rewrite"])
            #expect(history.allSatisfy { ($0["kind"] as String) == "auto" }, "insurance-class: quiet auto commits")
            // Block History's order (newest first) reads after over before.
            let newestFirst = try db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT message FROM commit_point WHERE variant_id = ? ORDER BY created_at DESC, id DESC",
                    arguments: [seeded.variant.id])
            }
            #expect(newestFirst == ["after claude-code's edit", "before claude-code's edit"])
            #expect(try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id]) != touched,
                    "an edit touches the note like any text edit")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's edit")

            #expect(try stack.undo(with: ops) == "claude-code's edit")
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [seeded.variant.id])
                    == "her paragraph, never committed")
            #expect(try commits(db, seeded.variant.id).count == 2, "commits are append-only (I5) — the history stays")
            #expect(try stack.redo(with: ops) == "claude-code's edit")
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [seeded.variant.id])
                    == "the client's rewrite")
        }
    }

    @Test func theBeforeCommitIsDedupedWhenTheTakesLastCommitAlreadyHoldsIt() throws {
        try withUndo { ops, _, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "saved text")
            try ops.commit(seeded.variant.id, message: "tightened")
            let edit = try ops.editTakeUnderInsurance(
                seeded.variant.id, text: "new text", expectedText: "saved text",
                client: client, undoLabel: label(.edit))
            #expect(edit.before == nil, "nothing to insure: her own commit already holds it")
            #expect(try commits(db, seeded.variant.id).map { $0["message"] as String? }
                    == ["tightened", "after claude-code's edit"])
        }
    }

    @Test func aStaleExpectedTextRefusesAndWritesNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "she typed since")
            #expect(throws: OperationError.bufferChangedSinceGesture(variantID: seeded.variant.id)) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, text: "overwrite", expectedText: "what the client read",
                    client: client, undoLabel: label(.edit))
            }
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [seeded.variant.id])
                    == "she typed since")
            #expect(try commits(db, seeded.variant.id).isEmpty)
            #expect(stack.depth == 0)
        }
    }

    @Test func anUnchangedTextWritesNothingAndRegistersNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "same")
            let edit = try ops.editTakeUnderInsurance(
                seeded.variant.id, text: "same", expectedText: "same", client: client, undoLabel: label(.edit))
            #expect(!edit.changed && edit.before == nil && edit.after == nil)
            #expect(try commits(db, seeded.variant.id).isEmpty && stack.depth == 0)
        }
    }

    @Test func aLockedTakeAnArchivedTakeAndASealRefuseTheEdit() throws {
        try withUndo { ops, _, _ in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "guarded")
            let other = try ops.branchVariant(seeded.block.id, from: seeded.variant.id)
            try ops.lockVariant(seeded.variant.id)
            #expect(throws: OperationError.lockedVariant(id: seeded.variant.id)) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, text: "x", expectedText: "guarded", client: client, undoLabel: label(.edit))
            }
            try ops.archiveVariant(other.id)
            #expect(throws: OperationError.archivedVariant(id: other.id)) {
                try ops.editTakeUnderInsurance(
                    other.id, text: "x", expectedText: "guarded", client: client, undoLabel: label(.edit))
            }
            try ops.unlockVariant(seeded.variant.id)
            try ops.lockPost(note.id)
            #expect(throws: OperationError.lockedPost(id: note.id)) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, text: "x", expectedText: "guarded", client: client, undoLabel: label(.edit))
            }
        }
    }

    // MARK: - THE GUARD: first, inside the act's own transaction

    @Test func theGuardRunsInsideTheActsTransactionAndItsThrowRollsTheWholeActBack() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "hers")
            let second = try ops.seedBlock(in: note.id, text: "second")
            // A guard that WRITES before it refuses: its write must roll back
            // with the act — the proof it runs inside the SAME transaction.
            let refusing: Operations.WriteGuard = { db in
                try db.execute(sql: "UPDATE container SET title = 'moved by the guard' WHERE id = ?", arguments: [note.id])
                throw GuardRefused()
            }
            #expect(throws: GuardRefused()) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, text: "x", expectedText: "hers", client: client,
                    undoLabel: label(.edit), guardedBy: refusing)
            }
            #expect(throws: GuardRefused()) { try ops.deleteBlock(second.block.id, guardedBy: refusing) }
            #expect(throws: GuardRefused()) {
                try ops.moveBlock(second.block.id, to: note.id, at: .start, guardedBy: refusing)
            }
            #expect(throws: GuardRefused()) { try ops.reorder(second.block.id, to: .start, guardedBy: refusing) }
            #expect(throws: GuardRefused()) { try ops.merge(seeded.block.id, second.block.id, guardedBy: refusing) }
            #expect(throws: GuardRefused()) { try ops.divide(second.block.id, cut: 3, guardedBy: refusing) }
            #expect(try db.fetchString("SELECT title FROM container WHERE id = ?", [note.id]) == "ch 1")
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [seeded.variant.id]) == "hers")
            #expect(try db.deletedAt("block", second.block.id) == nil)
            #expect(try commits(db, seeded.variant.id).isEmpty)
            #expect(stack.depth == 0, "a refused act registers nothing")

            // A passing guard lets the act land; it saw the rows the act saw.
            let seen = LockIsolated<String?>(nil)
            let passing: Operations.WriteGuard = { db in
                let text = try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [seeded.variant.id])
                seen.setValue(text)
            }
            try ops.editTakeUnderInsurance(
                seeded.variant.id, text: "x", expectedText: "hers", client: client,
                undoLabel: label(.edit), guardedBy: passing)
            #expect(seen.value == "hers")
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [seeded.variant.id]) == "x")
        }
    }

    // MARK: - set_block_name

    @Test func namingABlockIsOneEntryWithExactValuesAndANoOpRegistersNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "the opening")
            try ops.setBlockName(seeded.block.id, name: "old")
            #expect(try ops.setBlockName(seeded.block.id, name: "  the opening  ", undoLabel: label(.blockName)))
            #expect(try db.fetchString("SELECT name FROM block WHERE id = ?", [seeded.block.id]) == "the opening")
            #expect(stack.topLabel == "claude-code's block name")
            #expect(try !ops.setBlockName(seeded.block.id, name: "the opening", undoLabel: label(.blockName)))
            #expect(stack.depth == 1, "a no-op writes nothing and registers nothing")
            _ = try stack.undo(with: ops)
            #expect(try db.fetchString("SELECT name FROM block WHERE id = ?", [seeded.block.id]) == "old")
            _ = try stack.redo(with: ops)
            #expect(try db.fetchString("SELECT name FROM block WHERE id = ?", [seeded.block.id]) == "the opening")
            try ops.lockPost(note.id)
            #expect(throws: OperationError.lockedPost(id: note.id)) {
                try ops.setBlockName(seeded.block.id, name: "sealed", undoLabel: label(.blockName))
            }
        }
    }

    // MARK: - create_section + add_note_to_book's section

    @Test func aChapterIsOneEntryAndANoteFiledIntoItCarriesTheChapterThroughUndoAndRedo() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "lessons", kind: .book)
            let other = try ops.createReading(name: "elsewhere", kind: .book)
            let note = try ops.createPost(title: "lesson 1")
            let chapter = try ops.createSection(in: book.id, name: " week 1 ", undoLabel: label(.chapter))
            #expect(chapter.name == "week 1" && stack.topLabel == "claude-code's chapter")
            let foreign = try ops.createSection(in: other.id, name: "not here")
            #expect(throws: OperationError.sectionNotInReading(sectionID: foreign.id, readingID: book.id)) {
                try ops.addNoteToBook(note.id, book: book.id, section: foreign.id, undoLabel: label(.bookAdd))
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL", [note.id]) == 0,
                    "a refused chapter rolls the whole add back")

            let membership = try ops.addNoteToBook(note.id, book: book.id, section: chapter.id, undoLabel: label(.bookAdd))
            #expect(membership.sectionId == chapter.id)
            #expect(try db.fetchString("SELECT section_id FROM reading_post WHERE id = ?", [membership.id]) == chapter.id)
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("reading_post", membership.id) != nil)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("reading_post", membership.id) == nil)
            #expect(try db.fetchString("SELECT section_id FROM reading_post WHERE id = ?", [membership.id]) == chapter.id,
                    "the redo returns the chapter with the membership")

            _ = try stack.undo(with: ops)  // the membership
            _ = try stack.undo(with: ops)  // the chapter
            #expect(try db.deletedAt("reading_section", chapter.id) != nil)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("reading_section", chapter.id) == nil, "the SAME chapter row returns")

            let tag = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "smart", kind: .gathering, querySpec: try #require(try RuleGrammar.encode(.tag(tag.id))))
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.createSection(in: gathering.id, name: "x", undoLabel: label(.chapter))
            }
        }
    }

    // MARK: - divide_block / merge_blocks: her keyboard's compositions

    @Test func aSingleTakeDivideIsInPlaceAndAFannedOneKeepsTheOtherTakesOnTop() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let plain = try ops.seedBlock(in: note.id, text: "First half. Second half.")
            let cut = "First half. ".utf16.count
            let single = try ops.divideBlock(
                plain.block.id, cut: cut, shownTakeID: plain.variant.id, expectedText: "First half. Second half.",
                undoLabel: label(.divide))
            #expect(single.firstBlockID == plain.block.id && single.keptOnTop == 0)
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [plain.variant.id]) == "First half.")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's divide")
            _ = try stack.undo(with: ops)
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [plain.variant.id])
                    == "First half. Second half.")

            let fanned = try ops.seedBlock(in: note.id, text: "One. Two.")
            let alt = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(alt.id, text: "Another take entirely.", charDelta: 5)
            let kept = try ops.divideBlock(
                fanned.block.id, cut: "One. ".utf16.count, shownTakeID: fanned.variant.id, expectedText: "One. Two.",
                undoLabel: label(.divide))
            #expect(kept.keptOnTop == 1, "keep-on-top: the other take rides whole onto the first block")
            let firstFan = try db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position",
                    arguments: [kept.firstBlockID])
            }
            #expect(Set(firstFan) == ["One.", "Another take entirely."])
            #expect(stack.topLabel == "claude-code's divide")

            // Measured in a take that changed since: refused, nothing cut.
            let stale = try ops.seedBlock(in: note.id, text: "Changed since. The read.")
            #expect(throws: OperationError.bufferChangedSinceGesture(variantID: stale.variant.id)) {
                try ops.divideBlock(
                    stale.block.id, cut: 4, shownTakeID: stale.variant.id, expectedText: "What it said. Before.",
                    undoLabel: label(.divide))
            }
        }
    }

    @Test func aPlainMergeJoinsByTheRenderingJoinAndAFannedOneCarriesEveryTake() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let a = try ops.seedBlock(in: note.id, text: "Alpha.")
            let b = try ops.seedBlock(in: note.id, text: "Beta.")
            let plain = try ops.mergeBlocks(a.block.id, b.block.id, undoLabel: label(.merge))
            #expect(plain.carried == 0)
            #expect(try db.fetchString("""
                SELECT v.working_text FROM variant v JOIN block bl ON bl.default_variant_id = v.id WHERE bl.id = ?
                """, [plain.blockID]) == "Alpha.\nBeta.", "the rendering join (R-13u4-3)")
            #expect(stack.topLabel == "claude-code's merge")
            _ = try stack.undo(with: ops)

            let spare = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(spare.id, text: "Alpha, another way.", charDelta: 3)
            let carried = try ops.mergeBlocks(a.block.id, b.block.id, undoLabel: label(.merge))
            #expect(carried.carried == 1, "the carry-all merge: the other take rides whole")
            let fan = try db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [carried.blockID])
            }
            #expect(Set(fan) == ["Alpha.\nBeta.", "Alpha, another way."])
            #expect(stack.topLabel == "claude-code's merge")
        }
    }

    // MARK: - create_note's structured payload (R-13nb-11 G-2 + R-13nb-26 (b))

    @Test func aStructuredNoteKeepsAMultiParagraphBlockWholeWithNamesTakesAndItsDate() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "journals", kind: .book)
            let minted = try ops.createStructuredNote(
                title: "march 4", entryDate: "2019-03-04",
                blocks: [
                    .init(text: "First paragraph.\n\nSecond paragraph, same block.", name: "the morning"),
                    .init(text: "Plain.", takes: [.init(label: "english", text: "Plain, translated.")]),
                ],
                in: .book(book.id), undoLabel: label(.note))
            #expect(minted.blockIDs.count == 2, "a blank line inside a block is content, never a boundary")
            #expect(try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [minted.post.id]) == "2019-03-04")
            #expect(try db.fetchString("SELECT name FROM block WHERE id = ?", [minted.blockIDs[0]]) == "the morning")
            #expect(try db.fetchString("SELECT name FROM block WHERE id = ?", [minted.blockIDs[1]]) == nil)
            #expect(try db.read { try Queries.renderedText($0, containerID: minted.post.id) }
                    == "First paragraph.\n\nSecond paragraph, same block.\n\nPlain.")
            let fan = try db.read { db in
                try Row.fetchAll(
                    db, sql: "SELECT label, working_text FROM variant WHERE block_id = ? ORDER BY fan_position",
                    arguments: [minted.blockIDs[1]])
            }
            #expect(fan.map { $0["label"] as String? } == [nil, "english"], "takes join the fan, labeled, unchosen")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                                    [minted.post.id]) == 1, "it lands in the book")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's note")
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("container", minted.post.id) != nil, "one undo takes the whole note back")

            let plain = try ops.createNote(title: nil, text: "One.", entryDate: "2018-12-31", in: .wing(""),
                                           undoLabel: label(.note))
            #expect(try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [plain.post.id]) == "2018-12-31")
        }
    }

    @Test func aMalformedEntryDateRefusesAtTheOpAndMintsNothing() throws {
        // Phase 9b's day-key boundary (`setEntryDate`, `createOrOpenJournalEntry`):
        // no op is a permissive door to a malformed key — the notebook rule's
        // open-by-date would never find the entry. The wire validates too; the
        // op must not rely on it.
        try withUndo { ops, stack, db in
            let notes = { try db.fetchInt("SELECT COUNT(*) FROM container WHERE kind = 'post'") }
            let before = try notes()
            #expect(throws: OperationError.invalidEntryDate("2019-3-4")) {
                try ops.createNote(title: "x", text: "One.", entryDate: "2019-3-4", in: .wing(""),
                                   undoLabel: label(.note))
            }
            #expect(throws: OperationError.invalidEntryDate("2019-02-30")) {
                try ops.createStructuredNote(title: "x", entryDate: "2019-02-30", blocks: [.init(text: "One.")],
                                             in: .wing(""), undoLabel: label(.note))
            }
            #expect(try notes() == before, "the refusal rolls the whole mint back")
            #expect(stack.depth == 0, "and registers nothing")
        }
    }

    // MARK: - churn

    @Test func anEditsChurnIsWhatChangedBetweenTheCommonEnds() {
        #expect(Operations.churnCost(from: "abc", to: "abXc") == 1)
        #expect(Operations.churnCost(from: "abc", to: "") == 3)
        #expect(Operations.churnCost(from: "same", to: "same") == 0)
        #expect(Operations.churnCost(from: "a cat sat", to: "a dog sat") == 6)
    }
}
