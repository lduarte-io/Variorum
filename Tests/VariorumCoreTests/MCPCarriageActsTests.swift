import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-b U4 S1 — THE MCP DOOR's CARRIAGE ACTS (R-13nb-14/18/26; AF-11): exact
// state transitions, ONE client-named undo entry per act whose inverse and
// redo round-trip the same rows, and the in-transaction WRITE GUARD carried
// to every new act. Who may act is the server's per-call rule
// (`MCPCarriageServerTests`).

private struct GuardRefused: Error, Equatable {}

@Suite("13n-b U4 — the MCP carriage acts, their guards and their undo")
struct MCPCarriageActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    private let refuse: Operations.WriteGuard = { _ in throw GuardRefused() }

    // MARK: - put_back: a deleted block

    @Test func aPutBackBlockReturnsToItsOwnPlaceAndUndoesInOne() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let first = try ops.seedBlock(in: note.id, text: "first")
            let second = try ops.seedBlock(in: note.id, text: "second")
            _ = try ops.seedBlock(in: note.id, text: "third")
            try Operations().deleteBlock(second.block.id)  // her delete, no stack
            #expect(try db.read { try Queries.trayBlocks($0, postID: note.id, now: harnessNow) }.map(\.blockID)
                    == [second.block.id])

            let landing = try ops.putBackBlock(second.block.id, undoLabel: label(.putBack))
            #expect(landing == .itsOldPlace(home: .post))
            #expect(try db.deletedAt("block", second.block.id) == nil)
            let order = try db.read { try Queries.renderPost($0, containerID: note.id).map(\.text) }
            #expect(order == ["first", "second", "third"], "its OWN place, not the end")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's put back")
            let placement = try db.fetchString(
                "SELECT id FROM container_block WHERE block_id = ? AND deleted_at IS NULL", [second.block.id])

            #expect(try stack.undo(with: ops) == "claude-code's put back")
            #expect(try db.deletedAt("block", second.block.id) != nil, "undone: deleted again")
            #expect(try db.read { try Queries.trayBlocks($0, postID: note.id, now: harnessNow.addingTimeInterval(60)) }
                    .map(\.blockID) == [second.block.id], "the tray catches it again")
            #expect(try stack.redo(with: ops) == "claude-code's put back")
            #expect(try db.fetchString(
                "SELECT id FROM container_block WHERE block_id = ? AND deleted_at IS NULL", [second.block.id])
                    == placement, "the redo flips the SAME placement row back")
            _ = first
        }
    }

    @Test func aPutBackBlockGuardRefusalLeavesItInTheTrayAndRegistersNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let block = try ops.seedBlock(in: note.id, text: "gone")
            _ = try ops.seedBlock(in: note.id, text: "stays")
            try Operations().deleteBlock(block.block.id)
            #expect(throws: GuardRefused.self) {
                try ops.putBackBlock(block.block.id, undoLabel: label(.putBack), guardedBy: refuse)
            }
            #expect(try db.deletedAt("block", block.block.id) != nil)
            #expect(stack.depth == 0)
        }
    }

    // MARK: - put_back: a deleted take

    @Test func aPutBackTakeReturnsToTheFanAndItsUndoRespectsHerChoice() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let block = try ops.seedBlock(in: note.id, text: "hers")
            let take = try Operations().branchVariant(block.block.id, from: block.variant.id)
            try Operations().deleteVariant(take.id)

            #expect(try ops.putBackTake(take.id, undoLabel: label(.putBack)) == .active)
            #expect(try db.deletedAt("variant", take.id) == nil)
            #expect(stack.topLabel == "claude-code's put back")
            #expect(try stack.undo(with: ops) == "claude-code's put back")
            #expect(try db.deletedAt("variant", take.id) != nil)
            #expect(try stack.redo(with: ops) == "claude-code's put back")
            #expect(try db.deletedAt("variant", take.id) == nil)

            // She chooses the put-back take; the client's undo now refuses
            // (choose another first) and KEEPS its entry.
            try Operations().chooseVariant(block.block.id, variantID: take.id)
            #expect(throws: OperationError.variantIsChosen(id: take.id)) { _ = try stack.undo(with: ops) }
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's put back")
            #expect(try db.deletedAt("variant", take.id) == nil)
        }
    }

    @Test func aPutBackTakeGuardRefusalChangesNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let block = try ops.seedBlock(in: note.id, text: "hers")
            let take = try Operations().branchVariant(block.block.id, from: block.variant.id)
            try Operations().deleteVariant(take.id)
            #expect(throws: GuardRefused.self) {
                try ops.putBackTake(take.id, undoLabel: label(.putBack), guardedBy: refuse)
            }
            #expect(try db.deletedAt("variant", take.id) != nil)
            #expect(stack.depth == 0)
        }
    }

    // MARK: - save_version

    @Test func aSavedVersionIsTheClassifierShapeAndUndoesInOne() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "design doc")
            _ = try ops.seedBlock(in: note.id, text: "edition one")
            let result = try ops.saveVersion(of: note.id, undoLabel: label(.version))
            let row = try #require(try db.read { reader in try Row.fetchOne(
                reader, sql: "SELECT archived_at, created_at, locked, entry_date FROM container WHERE id = ?",
                arguments: [result.post.id]) })
            #expect((row["archived_at"] as String?) == (row["created_at"] as String?), "born archived — the classifier")
            #expect((row["locked"] as Bool) == true, "born sealed")
            #expect(try db.read { try Queries.noteVersions($0, of: note.id).map(\.postID) } == [result.post.id])
            #expect(stack.topLabel == "claude-code's version")
            _ = try stack.undo(with: ops)
            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }.isEmpty)
            _ = try stack.redo(with: ops)
            #expect(try db.read { try Queries.noteVersions($0, of: note.id).map(\.postID) } == [result.post.id])
        }
    }

    @Test func aRefusedVersionMintsNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "design doc")
            _ = try ops.seedBlock(in: note.id, text: "edition one")
            let before = try db.fetchInt("SELECT COUNT(*) FROM container")
            #expect(throws: GuardRefused.self) {
                try ops.saveVersion(of: note.id, undoLabel: label(.version), guardedBy: refuse)
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == before)
            #expect(stack.depth == 0)
        }
    }

    // MARK: - set_entry_date

    @Test func anEntryDateIsSetValidatedNoOpGuardedAndUndoesExactly() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "an old entry", entryDate: "2026-07-01")
            #expect(try ops.setNoteEntryDate(note.id, entryDate: "2019-03-04", undoLabel: label(.entryDate)))
            #expect(try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [note.id]) == "2019-03-04")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's date")
            #expect(try !ops.setNoteEntryDate(note.id, entryDate: "2019-03-04", undoLabel: label(.entryDate)),
                    "the same date writes nothing")
            #expect(stack.depth == 1, "and registers nothing")
            #expect(throws: OperationError.invalidEntryDate("2019-02-30")) {
                try ops.setNoteEntryDate(note.id, entryDate: "2019-02-30", undoLabel: label(.entryDate))
            }
            _ = try stack.undo(with: ops)
            #expect(try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [note.id]) == "2026-07-01")
            _ = try stack.redo(with: ops)
            #expect(try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [note.id]) == "2019-03-04")
            // nil un-dates (her op's own allowance).
            #expect(try ops.setNoteEntryDate(note.id, entryDate: nil, undoLabel: label(.entryDate)))
            #expect(try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [note.id]) == nil)
        }
    }

    @Test func anEntryDateLandsUnderASealAsHerOwnDateDoes() throws {
        try withUndo { ops, _, db in
            let note = try ops.createPost(title: "sealed")
            _ = try ops.seedBlock(in: note.id, text: "done")
            try Operations().lockPost(note.id)
            #expect(try ops.setNoteEntryDate(note.id, entryDate: "2020-01-01", undoLabel: label(.entryDate)))
            #expect(try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [note.id]) == "2020-01-01")
        }
    }

    @Test func aRefusedEntryDateChangesNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "x")
            #expect(throws: GuardRefused.self) {
                try ops.setNoteEntryDate(note.id, entryDate: "2019-03-04", undoLabel: label(.entryDate), guardedBy: refuse)
            }
            #expect(try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [note.id]) == nil)
            #expect(stack.depth == 0)
        }
    }

    // MARK: - file_note_in_chapter

    @Test func filingAMemberIntoAChapterUndoesExactlyAndAFinishedBookRefuses() throws {
        try withUndo { ops, stack, db in
            let plain = Operations()
            let book = try plain.createReading(name: "lessons", kind: .book)
            let chapter = try plain.createSection(in: book.id, name: "1 basics")
            let note = try plain.createPost(title: "lesson 1")
            _ = try plain.addPostToReading(note.id, to: book.id)

            #expect(try ops.fileNoteInChapter(note.id, book: book.id, section: chapter.id, undoLabel: label(.filing)))
            let section = { try db.fetchString(
                "SELECT section_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL", [note.id]) }
            #expect(try section() == chapter.id)
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's chapter filing")
            #expect(try !ops.fileNoteInChapter(note.id, book: book.id, section: chapter.id, undoLabel: label(.filing)))
            #expect(stack.depth == 1)
            _ = try stack.undo(with: ops)
            #expect(try section() == nil)
            _ = try stack.redo(with: ops)
            #expect(try section() == chapter.id)

            try plain.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.fileNoteInChapter(note.id, book: book.id, section: nil, undoLabel: label(.filing))
            }
            #expect(try section() == chapter.id)
        }
    }

    // MARK: - set_book_rule (AF-11 F-1: her Save, mirrored)

    private func spec(_ db: AppDatabase, _ readingID: String) throws -> String? {
        try db.fetchString("SELECT query_spec FROM reading WHERE id = ?", [readingID])
    }

    @Test func aBookRuleWriteResolvesPathsMintsTheMissingAndUndoesTheThreeColumns() throws {
        try withUndo { ops, stack, db in
            let plain = Operations()
            let percy = try plain.createTag(name: "percy")
            let book = try plain.createReading(name: "percy lessons", kind: .book)
            let write = Operations.MCPBookRuleWrite(
                rule: .some(.or([.tag("percy"), .tag("percy/pt-en")])),
                outflowPaths: ["lessons"], seating: .arrivals)
            let result = try ops.setBookRule(book.id, write, undoLabel: label(.bookRule))
            #expect(result.changed && result.mintedTags == 2, "percy/pt-en and lessons minted in the book's wing")
            let ptEn = try #require(try db.fetchString("SELECT id FROM tag WHERE path = 'percy/pt-en'"))
            let lessons = try #require(try db.fetchString("SELECT id FROM tag WHERE path = 'lessons'"))
            #expect(RuleGrammar.decode(try spec(db, book.id)) == .or([.tag(percy.id), .tag(ptEn)]),
                    "the store holds IDS — the wire named paths")
            #expect(try db.fetchString("SELECT auto_tag_ids FROM reading WHERE id = ?", [book.id])
                    == Reading.encodeOutflow([lessons]))
            #expect(try db.fetchString("SELECT intake_seating FROM reading WHERE id = ?", [book.id]) == "arrivals")
            #expect(result.intakeRuns)
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's book rule")

            _ = try stack.undo(with: ops)
            #expect(try spec(db, book.id) == nil)
            #expect(try db.fetchString("SELECT auto_tag_ids FROM reading WHERE id = ?", [book.id]) == nil)
            #expect(try db.fetchString("SELECT intake_seating FROM reading WHERE id = ?", [book.id]) == nil)
            #expect(try db.fetchString("SELECT id FROM tag WHERE path = 'lessons'") == lessons,
                    "a minted tag stays as vocabulary")
            _ = try stack.redo(with: ops)
            #expect(RuleGrammar.decode(try spec(db, book.id)) == .or([.tag(percy.id), .tag(ptEn)]))
        }
    }

    @Test func anUnchangedBookRuleWriteRegistersNothing() throws {
        try withUndo { ops, stack, _ in
            let plain = Operations()
            _ = try plain.createTag(name: "percy")
            let book = try plain.createReading(name: "b", kind: .book)
            _ = try ops.setBookRule(book.id, .init(rule: .some(.tag("percy"))), undoLabel: label(.bookRule))
            let again = try ops.setBookRule(
                book.id, .init(rule: .some(.tag("percy")), seating: .auto), undoLabel: label(.bookRule))
            #expect(!again.changed, "the same rule and the default dial: her Save writes nothing")
            #expect(stack.depth == 1)
        }
    }

    @Test func aBookRuleWriteKeepsTheSeatsItsIntakeMade() throws {
        try withUndo { ops, stack, db in
            let plain = Operations()
            let percy = try plain.createTag(name: "percy")
            let note = try plain.createPost(title: "tagged")
            _ = try plain.applyTag(percy.id, toPost: note.id)
            let book = try plain.createReading(name: "b", kind: .book)
            _ = try ops.setBookRule(book.id, .init(rule: .some(.tag("percy"))), undoLabel: label(.bookRule))
            let members = { try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'",
                [book.id]) }
            #expect(try members() == 1, "a rule set on a rule-less book backfills (her choke point's intake)")
            _ = try stack.undo(with: ops)
            #expect(try spec(db, book.id) == nil)
            #expect(try members() == 1, "seats stay — removing a rule never evicts (§19)")
        }
    }

    @Test func aFinishedOrSealedBookLandsAsHerSaveDoesWithIntakePaused() throws {
        try withUndo { ops, _, db in
            let plain = Operations()
            _ = try plain.createTag(name: "percy")
            let finished = try plain.createReading(name: "finished", kind: .book)
            try plain.lockReading(finished.id)
            let result = try ops.setBookRule(finished.id, .init(rule: .some(.tag("percy"))), undoLabel: label(.bookRule))
            #expect(result.changed && !result.intakeRuns, "lands; intake paused until the reopen")
            #expect(try spec(db, finished.id) != nil)

            let sealed = try plain.createReading(name: "sealed", kind: .book)
            let member = try plain.createPost(title: "m")
            _ = try plain.seedBlock(in: member.id, text: "x")
            _ = try plain.addPostToReading(member.id, to: sealed.id)
            _ = try plain.sealReading(sealed.id)
            let onSealed = try ops.setBookRule(
                sealed.id, .init(rule: .some(.tag("percy")), outflowPaths: ["percy"]), undoLabel: label(.bookRule))
            #expect(onSealed.changed && !onSealed.intakeRuns, "her ops and her Edit… door land on a sealed book too")
        }
    }

    @Test func aMalformedStoredRuleRefusesARuleWriteAsHerEditorDoesButNotTheOtherFields() throws {
        try withUndo { ops, stack, db in
            let plain = Operations()
            let book = try plain.createReading(name: "b", kind: .book)
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET query_spec = '{not json' WHERE id = ?", arguments: [book.id])
            }
            #expect(throws: Operations.MCPBookRuleRefusal.storedRuleUnreadable) {
                try ops.setBookRule(book.id, .init(rule: .some(nil), seating: .arrivals), undoLabel: label(.bookRule))
            }
            #expect(try db.fetchString("SELECT intake_seating FROM reading WHERE id = ?", [book.id]) == nil,
                    "nothing half-lands")
            let dial = try ops.setBookRule(book.id, .init(seating: .arrivals), undoLabel: label(.bookRule))
            #expect(dial.changed, "her Save still writes the dial over an unreadable rule")
            #expect(try spec(db, book.id) == "{not json", "the unreadable rule is untouched")
            #expect(stack.depth == 1)
        }
    }

    @Test func aBlankPathAndAGuardRefusalChangeNothing() throws {
        try withUndo { ops, stack, db in
            let book = try Operations().createReading(name: "b", kind: .book)
            #expect(throws: OperationError.invalidTagName(name: " / ")) {
                try ops.setBookRule(book.id, .init(rule: .some(.tag(" / "))), undoLabel: label(.bookRule))
            }
            #expect(throws: GuardRefused.self) {
                try ops.setBookRule(book.id, .init(seating: .arrivals), undoLabel: label(.bookRule), guardedBy: refuse)
            }
            #expect(try db.fetchString("SELECT intake_seating FROM reading WHERE id = ?", [book.id]) == nil)
            #expect(stack.depth == 0)
        }
    }
}
