import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-184 LADDER ROUND 1 — THE UNDO-OVERWRITE CLASS (the opus-reviewer's MINOR,
// agreed): an MCP act's entry that restores a VALUE must never overwrite a value
// she wrote SINCE through one of her own doors that registers no undo entry (her
// renames, moves, label, commit name, title, block name, date, chapter filing,
// rule editor's Save, her ✓). The code's own stated rule — "divergence is QUIET
// (the world moved past the entry)" — read as compare-and-set: the inverse writes
// the old value only while the row still reads the act's value, and the redo
// writes the act's value only while the row still reads the old one; otherwise
// quiet (the entry still pops — `UndoStack.undo` pops on any non-throwing
// inverse). `rewriteCommentIfUnchanged` is the precedent.
//
// ONE pin per family, each in two independent halves on separate rows: the
// INVERSE half (the client's act, then her own door, then ⌥⌘Z — her value
// survives) and the REDO half (the act, ⌥⌘Z, then her own door, then ⇧⌥⌘Z — her
// value survives). Every half first checks the premise: her door registered
// nothing and cleared nothing. Written BEFORE the fix, against the pre-fix API —
// red on the pre-fix tree, red again by revert (the run record's ROUND 1 FIX PASS).
//
// The LOCK row is the one HOLLOW member (the last pin): a lock is two-valued and
// `setVariantLockRows` writes nothing when the take already reads the target, so
// her divergence can only ever be the value the inverse writes — green on both
// sides by construction; kept as the hollow verdict's evidence.

@Suite("VX-184 round 1 — an MCP undo or redo never overwrites a change she made since")
struct MCPUndoDivergenceTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    private func chapterIDs(_ db: AppDatabase, _ bookID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: "SELECT id FROM reading_section WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id",
                arguments: [bookID])
        }
    }

    private func memberIDs(_ db: AppDatabase, _ bookID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT post_id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL
                      AND status = 'member' ORDER BY position, id
                    """,
                arguments: [bookID])
        }
    }

    private func chosen(_ db: AppDatabase, _ blockID: String) throws -> String? {
        try db.fetchString(
            "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL", [blockID])
    }

    // MARK: - rename_book (U5) — her rename door

    @Test func aBookNamesUndoAndRedoLeaveHerLaterNameAlone() throws {
        try withUndo { ops, stack, db in
            let name = { (id: String) in try db.fetchString("SELECT name FROM reading WHERE id = ?", [id]) }
            let undone = try ops.createReading(name: "drafts", kind: .book)
            let redone = try ops.createReading(name: "letters", kind: .book)
            stack.removeAll()

            _ = try ops.renameBookForClient(undone.id, name: "drafts, revised", undoLabel: label(.bookName))
            try ops.renameReading(undone.id, name: "her drafts")
            #expect(stack.depth == 1, "her rename registers nothing")
            #expect(try stack.undo(with: ops) == label(.bookName))
            #expect(try name(undone.id) == "her drafts", "her later name survives the client's undo")

            _ = try ops.renameBookForClient(redone.id, name: "letters, revised", undoLabel: label(.bookName))
            _ = try stack.undo(with: ops)
            #expect(try name(redone.id) == "letters")
            try ops.renameReading(redone.id, name: "her letters")
            #expect(stack.redoDepth == 1, "her rename clears no future")
            #expect(try stack.redo(with: ops) == label(.bookName))
            #expect(try name(redone.id) == "her letters", "her later name survives the client's redo")
        }
    }

    // MARK: - rename_chapter / move_chapter (U5) — her section doors

    @Test func aChapterNamesUndoAndRedoLeaveHerLaterNameAlone() throws {
        try withUndo { ops, stack, db in
            let name = { (id: String) in try db.fetchString("SELECT name FROM reading_section WHERE id = ?", [id]) }
            let book = try ops.createReading(name: "drafts", kind: .book)
            let undone = try ops.createSection(in: book.id, name: "one")
            let redone = try ops.createSection(in: book.id, name: "two")
            stack.removeAll()

            _ = try ops.renameChapterForClient(undone.id, name: "uno", undoLabel: label(.chapterName))
            try ops.renameSection(undone.id, name: "her first")
            #expect(stack.depth == 1, "her chapter rename registers nothing")
            #expect(try stack.undo(with: ops) == label(.chapterName))
            #expect(try name(undone.id) == "her first", "her later name survives the client's undo")

            _ = try ops.renameChapterForClient(redone.id, name: "dos", undoLabel: label(.chapterName))
            _ = try stack.undo(with: ops)
            #expect(try name(redone.id) == "two")
            try ops.renameSection(redone.id, name: "her second")
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.chapterName))
            #expect(try name(redone.id) == "her second", "her later name survives the client's redo")
        }
    }

    @Test func aChapterMovesUndoAndRedoLeaveHerLaterPlaceAlone() throws {
        try withUndo { ops, stack, db in
            let undone = try ops.createReading(name: "drafts", kind: .book)
            let u = try (1...3).map { try ops.createSection(in: undone.id, name: "u\($0)").id }
            let redone = try ops.createReading(name: "letters", kind: .book)
            let r = try (1...3).map { try ops.createSection(in: redone.id, name: "r\($0)").id }
            stack.removeAll()

            _ = try ops.moveChapterForClient(u[2], to: .start, undoLabel: label(.chapterMove))
            #expect(try chapterIDs(db, undone.id) == [u[2], u[0], u[1]])
            try ops.reorderSection(u[2], to: .after(u[0]))
            #expect(stack.depth == 1, "her chapter move registers nothing")
            #expect(try stack.undo(with: ops) == label(.chapterMove))
            #expect(try chapterIDs(db, undone.id) == [u[0], u[2], u[1]], "her later place survives the client's undo")

            _ = try ops.moveChapterForClient(r[2], to: .start, undoLabel: label(.chapterMove))
            _ = try stack.undo(with: ops)
            #expect(try chapterIDs(db, redone.id) == r)
            try ops.reorderSection(r[2], to: .after(r[0]))
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.chapterMove))
            #expect(try chapterIDs(db, redone.id) == [r[0], r[2], r[1]], "her later place survives the client's redo")
        }
    }

    // MARK: - move_note_in_book (U5) — her book-order door

    @Test func aNoteMovesUndoAndRedoLeaveHerLaterPlaceAlone() throws {
        try withUndo { ops, stack, db in
            let undone = try ops.createReading(name: "drafts", kind: .book)
            let u = try (1...3).map { try ops.createPost(title: "u\($0)").id }
            for id in u { _ = try ops.addPostToReading(id, to: undone.id) }
            let redone = try ops.createReading(name: "letters", kind: .book)
            let r = try (1...3).map { try ops.createPost(title: "r\($0)").id }
            for id in r { _ = try ops.addPostToReading(id, to: redone.id) }
            stack.removeAll()

            try ops.moveNoteInBookForClient(u[2], book: undone.id, to: .before(u[0]), undoLabel: label(.bookOrder))
            #expect(try memberIDs(db, undone.id) == [u[2], u[0], u[1]])
            try ops.reorderReadingPost(u[2], in: undone.id, to: .after(u[0]))
            #expect(stack.depth == 1, "her move in the book registers nothing")
            #expect(try stack.undo(with: ops) == label(.bookOrder))
            #expect(try memberIDs(db, undone.id) == [u[0], u[2], u[1]], "her later place survives the client's undo")

            try ops.moveNoteInBookForClient(r[2], book: redone.id, to: .before(r[0]), undoLabel: label(.bookOrder))
            _ = try stack.undo(with: ops)
            #expect(try memberIDs(db, redone.id) == r)
            try ops.reorderReadingPost(r[2], in: redone.id, to: .after(r[0]))
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.bookOrder))
            #expect(try memberIDs(db, redone.id) == [r[0], r[2], r[1]], "her later place survives the client's redo")
        }
    }

    // MARK: - set_take_label (U4) — her label door

    @Test func aTakeLabelsUndoAndRedoLeaveHerLaterLabelAlone() throws {
        try withUndo { ops, stack, db in
            let take = { (id: String) in try db.fetchString("SELECT label FROM variant WHERE id = ?", [id]) }
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "Her opening.")
            let undone = try ops.branchVariant(seeded.block.id, from: seeded.variant.id).id
            let redone = seeded.variant.id
            stack.removeAll()

            _ = try ops.labelTakeForClient(undone, label: "bold", undoLabel: label(.takeLabel))
            try ops.setTakeLabel(undone, label: "her name for it")
            #expect(stack.depth == 1, "her label registers nothing")
            #expect(try stack.undo(with: ops) == label(.takeLabel))
            #expect(try take(undone) == "her name for it", "her later label survives the client's undo")

            _ = try ops.labelTakeForClient(redone, label: "plain", undoLabel: label(.takeLabel))
            _ = try stack.undo(with: ops)
            #expect(try take(redone) == nil)
            try ops.setTakeLabel(redone, label: "hers")
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.takeLabel))
            #expect(try take(redone) == "hers", "her later label survives the client's redo")
        }
    }

    // MARK: - rename_commit (U4) — her savepoint rename

    @Test func aCommitNamesUndoAndRedoLeaveHerLaterNameAlone() throws {
        try withUndo { ops, stack, db in
            let message = { (id: String) in try db.fetchString("SELECT message FROM commit_point WHERE id = ?", [id]) }
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "Her opening.")
            let undone = try ops.commit(seeded.variant.id, message: "first").id
            try ops.autosave(seeded.variant.id, text: "Her opening, revised.", charDelta: 9)
            let redone = try ops.commit(seeded.variant.id, message: "second").id
            stack.removeAll()

            _ = try ops.renameCommitForClient(undone, message: "the draft", undoLabel: label(.commitRename))
            try ops.renameCommitPoint(undone, message: "her name for it")
            #expect(stack.depth == 1, "her savepoint rename registers nothing")
            #expect(try stack.undo(with: ops) == label(.commitRename))
            #expect(try message(undone) == "her name for it", "her later name survives the client's undo")

            _ = try ops.renameCommitForClient(redone, message: "the revision", undoLabel: label(.commitRename))
            _ = try stack.undo(with: ops)
            #expect(try message(redone) == "second")
            try ops.renameCommitPoint(redone, message: "hers")
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.commitRename))
            #expect(try message(redone) == "hers", "her later name survives the client's redo")
        }
    }

    // MARK: - rename_note (U4) — her title doors

    @Test func aNoteTitlesUndoAndRedoLeaveHerLaterTitleAlone() throws {
        try withUndo { ops, stack, db in
            let title = { (id: String) in try db.fetchString("SELECT title FROM container WHERE id = ?", [id]) }
            let undone = try ops.createPost(title: "ch 1").id
            let redone = try ops.createPost(title: "ch 2").id
            stack.removeAll()

            _ = try ops.renameNoteForClient(undone, title: "Chapter one", undoLabel: label(.noteTitle))
            try ops.renameContainer(undone, title: "Her opening")
            #expect(stack.depth == 1, "her title registers nothing")
            #expect(try stack.undo(with: ops) == label(.noteTitle))
            #expect(try title(undone) == "Her opening", "her later title survives the client's undo")

            _ = try ops.renameNoteForClient(redone, title: "Chapter two", undoLabel: label(.noteTitle))
            _ = try stack.undo(with: ops)
            #expect(try title(redone) == "ch 2")
            try ops.renameContainer(redone, title: "Her middle")
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.noteTitle))
            #expect(try title(redone) == "Her middle", "her later title survives the client's redo")
        }
    }

    // MARK: - set_block_name (13n-b U3) — her block-name door

    @Test func aBlockNamesUndoAndRedoLeaveHerLaterNameAlone() throws {
        try withUndo { ops, stack, db in
            let name = { (id: String) in try db.fetchString("SELECT name FROM block WHERE id = ?", [id]) }
            let note = try ops.createPost(title: "ch 1")
            let undone = try ops.seedBlock(in: note.id, text: "Her opening.").block.id
            let redone = try ops.seedBlock(in: note.id, text: "Her close.").block.id
            stack.removeAll()

            _ = try ops.setBlockName(undone, name: "the opening", undoLabel: label(.blockName))
            try ops.setBlockName(undone, name: "her opening")
            #expect(stack.depth == 1, "her block name registers nothing")
            #expect(try stack.undo(with: ops) == label(.blockName))
            #expect(try name(undone) == "her opening", "her later name survives the client's undo")

            _ = try ops.setBlockName(redone, name: "the close", undoLabel: label(.blockName))
            _ = try stack.undo(with: ops)
            #expect(try name(redone) == nil)
            try ops.setBlockName(redone, name: "her close")
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.blockName))
            #expect(try name(redone) == "her close", "her later name survives the client's redo")
        }
    }

    // MARK: - set_entry_date (13n-b U4) — her date door

    @Test func anEntryDatesUndoAndRedoLeaveHerLaterDateAlone() throws {
        try withUndo { ops, stack, db in
            let date = { (id: String) in try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [id]) }
            let undone = try ops.createPost(title: "an entry", entryDate: "2026-07-01").id
            let redone = try ops.createPost(title: "another", entryDate: "2026-07-02").id
            stack.removeAll()

            _ = try ops.setNoteEntryDate(undone, entryDate: "2019-03-04", undoLabel: label(.entryDate))
            try ops.setEntryDate(undone, entryDate: "2020-01-01")
            #expect(stack.depth == 1, "her date registers nothing")
            #expect(try stack.undo(with: ops) == label(.entryDate))
            #expect(try date(undone) == "2020-01-01", "her later date survives the client's undo")

            _ = try ops.setNoteEntryDate(redone, entryDate: "2019-03-05", undoLabel: label(.entryDate))
            _ = try stack.undo(with: ops)
            #expect(try date(redone) == "2026-07-02")
            try ops.setEntryDate(redone, entryDate: "2021-02-02")
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.entryDate))
            #expect(try date(redone) == "2021-02-02", "her later date survives the client's redo")
        }
    }

    // MARK: - file_note_in_chapter (13n-b U4) — her chapter filing

    @Test func aChapterFilingsUndoAndRedoLeaveHerLaterFilingAlone() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "lessons", kind: .book)
            let x = try ops.createSection(in: book.id, name: "x").id
            let y = try ops.createSection(in: book.id, name: "y").id
            let z = try ops.createSection(in: book.id, name: "z").id
            let notes = try (1...3).map { try ops.createPost(title: "lesson \($0)").id }
            for id in notes { _ = try ops.addPostToReading(id, to: book.id) }
            let section = { (id: String) in
                try db.fetchString(
                    "SELECT section_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL", [id])
            }
            stack.removeAll()

            _ = try ops.fileNoteInChapter(notes[0], book: book.id, section: x, undoLabel: label(.filing))
            try ops.assignPostToSection(notes[0], in: book.id, section: y)
            #expect(stack.depth == 1, "her filing registers nothing")
            #expect(try stack.undo(with: ops) == label(.filing))
            #expect(try section(notes[0]) == y, "her later filing survives the client's undo")

            _ = try ops.fileNoteInChapter(notes[1], book: book.id, section: x, undoLabel: label(.filing))
            _ = try stack.undo(with: ops)
            #expect(try section(notes[1]) == nil)
            try ops.assignPostToSection(notes[1], in: book.id, section: z)
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.filing))
            #expect(try section(notes[1]) == z, "her later filing survives the client's redo")

            // EXACT-ROW (AppSpec §9's letter): she took the note out and put it
            // back — a NEW membership row, unfiled. The entry's row is gone, so
            // the undo is quiet; it never files her new row.
            try ops.assignPostToSection(notes[2], in: book.id, section: x)
            stack.removeAll()
            _ = try ops.fileNoteInChapter(notes[2], book: book.id, section: nil, undoLabel: label(.filing))
            _ = try ops.removePostFromReading(notes[2], from: book.id)
            _ = try ops.addPostToReading(notes[2], to: book.id)
            #expect(stack.depth == 1, "her remove and add register nothing")
            #expect(try stack.undo(with: ops) == label(.filing))
            #expect(try section(notes[2]) == nil, "her re-added membership stays as she made it")
        }
    }

    // MARK: - set_book_rule (13n-b U4) — her rule editor's Save

    @Test func aBookRulesUndoAndRedoLeaveHerLaterSaveAlone() throws {
        try withUndo { ops, stack, db in
            let travel = try ops.createTag(name: "travel")
            let spec = { (id: String) in try db.fetchString("SELECT query_spec FROM reading WHERE id = ?", [id]) }
            let seating = { (id: String) in try db.fetchString("SELECT intake_seating FROM reading WHERE id = ?", [id]) }
            let theirs = Operations.MCPBookRuleWrite(rule: .some(.tag("percy")))
            let undone = try ops.createReading(name: "first", kind: .book)
            let untouched = try ops.createReading(name: "second", kind: .book)
            let redone = try ops.createReading(name: "third", kind: .book)
            stack.removeAll()

            _ = try ops.setBookRule(undone.id, theirs, undoLabel: label(.bookRule))
            try ops.setReadingQuerySpec(undone.id, querySpec: try RuleGrammar.encode(.tag(travel.id)))
            #expect(stack.depth == 1, "her Save registers nothing")
            #expect(try stack.undo(with: ops) == label(.bookRule))
            #expect(RuleGrammar.decode(try spec(undone.id)) == .tag(travel.id), "her later rule survives the client's undo")

            // A column the act did NOT change is hers too: her dial, set after
            // the client wrote only the rule, survives the rule's undo.
            _ = try ops.setBookRule(untouched.id, theirs, undoLabel: label(.bookRule))
            try ops.setReadingIntakeSeating(untouched.id, .arrivals)
            #expect(try stack.undo(with: ops) == label(.bookRule))
            #expect(try spec(untouched.id) == nil, "the client's rule walks back")
            #expect(try seating(untouched.id) == "arrivals", "her dial, which the act never touched, stays")

            _ = try ops.setBookRule(redone.id, theirs, undoLabel: label(.bookRule))
            _ = try stack.undo(with: ops)
            #expect(try spec(redone.id) == nil)
            try ops.setReadingQuerySpec(redone.id, querySpec: try RuleGrammar.encode(.tag(travel.id)))
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.bookRule))
            #expect(RuleGrammar.decode(try spec(redone.id)) == .tag(travel.id), "her later rule survives the client's redo")
        }
    }

    // MARK: - choose_take (VX-168 U2) — her ✓

    @Test func aChosenTakesUndoAndRedoLeaveHerLaterCheckmarkAlone() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "Her opening.")
            let theirs1 = try ops.branchVariant(one.block.id, from: one.variant.id).id
            let hers1 = try ops.branchVariant(one.block.id, from: one.variant.id).id
            let two = try ops.seedBlock(in: note.id, text: "Her close.")
            let theirs2 = try ops.branchVariant(two.block.id, from: two.variant.id).id
            let hers2 = try ops.branchVariant(two.block.id, from: two.variant.id).id
            stack.removeAll()

            _ = try ops.chooseTake(theirs1, undoLabel: label(.choice))
            try ops.chooseVariant(one.block.id, variantID: hers1)
            #expect(stack.depth == 1, "her ✓ registers nothing")
            #expect(try stack.undo(with: ops) == label(.choice))
            #expect(try chosen(db, one.block.id) == hers1, "her later ✓ survives the client's undo")

            _ = try ops.chooseTake(theirs2, undoLabel: label(.choice))
            _ = try stack.undo(with: ops)
            #expect(try chosen(db, two.block.id) == two.variant.id)
            try ops.chooseVariant(two.block.id, variantID: hers2)
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.choice))
            #expect(try chosen(db, two.block.id) == hers2, "her later ✓ survives the client's redo")
        }
    }

    // MARK: - adopt_lens (VX-168 U2) — her ✓ on one of the adopted blocks

    @Test func aLensAdoptionsUndoAndRedoLeaveHerLaterCheckmarkAloneSlotBySlot() throws {
        try withUndo { ops, stack, db in
            // Two notes, each two fanned blocks and a lens picking the other takes.
            func world(_ title: String) throws -> (lens: String, b1: String, h1: String, o1: String, t1: String,
                                                   b2: String, h2: String, o2: String) {
                let note = try ops.createPost(title: title)
                let one = try ops.seedBlock(in: note.id, text: "Her opening.")
                let o1 = try ops.branchVariant(one.block.id, from: one.variant.id).id
                let t1 = try ops.branchVariant(one.block.id, from: one.variant.id).id
                let two = try ops.seedBlock(in: note.id, text: "Her close.")
                let o2 = try ops.branchVariant(two.block.id, from: two.variant.id).id
                let lens = try ops.createLens(post: note.id, name: "the other cut")
                _ = try ops.setLensChoice(lens: lens.id, block: one.block.id, variant: o1)
                _ = try ops.setLensChoice(lens: lens.id, block: two.block.id, variant: o2)
                return (lens.id, one.block.id, one.variant.id, o1, t1, two.block.id, two.variant.id, o2)
            }
            let u = try world("ch 1")
            let r = try world("ch 2")
            stack.removeAll()

            _ = try ops.adoptLensAsNote(u.lens, undoLabel: label(.lensAdoption))
            #expect(try chosen(db, u.b1) == u.o1 && chosen(db, u.b2) == u.o2)
            try ops.chooseVariant(u.b1, variantID: u.t1)
            #expect(stack.depth == 1, "her ✓ registers nothing")
            #expect(try stack.undo(with: ops) == label(.lensAdoption))
            #expect(try chosen(db, u.b1) == u.t1, "her later ✓ on block 1 survives the client's undo")
            #expect(try chosen(db, u.b2) == u.h2, "the slot she left alone walks back")

            _ = try ops.adoptLensAsNote(r.lens, undoLabel: label(.lensAdoption))
            _ = try stack.undo(with: ops)
            #expect(try chosen(db, r.b1) == r.h1 && chosen(db, r.b2) == r.h2)
            try ops.chooseVariant(r.b1, variantID: r.t1)
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.lensAdoption))
            #expect(try chosen(db, r.b1) == r.t1, "her later ✓ on block 1 survives the client's redo")
            #expect(try chosen(db, r.b2) == r.o2, "the slot she left alone is adopted again")
        }
    }

    // MARK: - lock_take / unlock_take (U4) — HOLLOW (green on both sides)

    /// The HOLLOW verdict's evidence, not a fix's pin: a lock is two-valued and
    /// `setVariantLockRows` writes nothing when the take already reads the
    /// target, so her later change can only ever be the very value the
    /// inverse (or redo) writes. Green on the pre-fix tree — recorded in the
    /// run record's ROUND 1 FIX PASS (dismissed as hollow, no fix).
    @Test func aTakeLockIsTwoValuedSoHerLaterChangeAlreadySurvivesHollow() throws {
        try withUndo { ops, stack, db in
            let locked = { (id: String) in try db.fetchInt("SELECT locked FROM variant WHERE id = ?", [id]) }
            let note = try ops.createPost(title: "ch 1")
            let undone = try ops.seedBlock(in: note.id, text: "Her opening.").variant.id
            let redone = try ops.seedBlock(in: note.id, text: "Her close.").variant.id
            stack.removeAll()

            _ = try ops.lockTakeForClient(undone, locked: true, undoLabel: label(.takeLock))
            try ops.unlockVariant(undone)
            #expect(stack.depth == 1, "her unlock registers nothing")
            #expect(try stack.undo(with: ops) == label(.takeLock))
            #expect(try locked(undone) == 0, "her unlock stands — the only other value there is")

            _ = try ops.lockTakeForClient(redone, locked: true, undoLabel: label(.takeLock))
            _ = try stack.undo(with: ops)
            #expect(try locked(redone) == 0)
            try ops.lockVariant(redone)
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label(.takeLock))
            #expect(try locked(redone) == 1, "her lock stands — the redo's own value")
        }
    }
}
