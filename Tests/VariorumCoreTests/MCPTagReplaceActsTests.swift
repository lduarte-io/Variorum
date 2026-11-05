import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-812 — `replace_tag`'s ITEM (`Operations.replaceTagForClient` — the VX-809
// run, batch 3; her R-812): one note's tag A → tag B in ONE transaction, A off
// (her un-tag's row — a non-event for intake) and B on through the ONE
// application road (B adopted-else-minted by path in the note's wing), ONE
// client-named entry whose halves compare-and-set PER PART. Who may act and
// which notes the sweep takes is the wire's (`MCPReplaceTagServerTests`).
// Features: no red-on-old owed (the act did not exist).

private struct GuardRefused: Error, Equatable {}

@Suite("VX-812 — replace_tag's item: A off, B on, one entry")
struct MCPTagReplaceActsTests {
    private let label = Operations.MCPWriteAct.tagReplace.undoLabel(client: "claude-code")

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack).heardAsWireClient(), stack, db)
        }
    }

    private func worn(_ db: AppDatabase, _ postID: String) throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0,
                sql: """
                    SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL ORDER BY t.path
                    """,
                arguments: [postID])
        }
    }

    private func status(_ db: AppDatabase, _ readingID: String, _ postID: String) throws -> String? {
        try db.read {
            try String.fetchOne(
                $0,
                sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                arguments: [readingID, postID])
        }
    }

    @Test func aOffBOnInOneActWithOneEntryAndExactHalves() throws {
        try withUndo { ops, stack, db in
            let a = try ops.createTag(name: "old")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(a.id, toPost: note.id)
            let done = try ops.replaceTagForClient(a.id, with: "new/leaf", onNote: note.id, undoLabel: label)
            #expect(done.toPath == "new/leaf" && done.appliedApplicationID != nil)
            #expect(try worn(db, note.id) == ["new/leaf"])
            #expect(stack.depth == 1 && stack.topLabel == label)
            #expect(try stack.undo(with: ops) == label)
            #expect(try worn(db, note.id) == ["old"], "A back on its own row, B off")
            #expect(try stack.redo(with: ops) == label)
            #expect(try worn(db, note.id) == ["new/leaf"])
            let ids = try db.read {
                try String.fetchAll($0, sql: "SELECT id FROM post_tag WHERE post_id = ? ORDER BY id", arguments: [note.id])
            }
            #expect(ids.count == 2, "exact rows both ways — no row minted by a replay")
        }
    }

    /// A note already wearing B: the item lands (A off), B's own application
    /// untouched; the undo puts A back and leaves B as it was.
    @Test func aNoteAlreadyWearingBKeepsItsApplication() throws {
        try withUndo { ops, stack, db in
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(a.id, toPost: note.id)
            let bRow = try ops.applyTag(b.id, toPost: note.id).id
            let done = try ops.replaceTagForClient(a.id, with: "b", onNote: note.id, undoLabel: label)
            #expect(done.appliedApplicationID == nil && done.toTagID == b.id)
            #expect(try worn(db, note.id) == ["b"])
            _ = try stack.undo(with: ops)
            #expect(try worn(db, note.id) == ["a", "b"])
            #expect(try db.read {
                try String.fetchOne($0, sql: "SELECT deleted_at FROM post_tag WHERE id = ?", arguments: [bRow])
            } == nil, "B's own row never touched")
        }
    }

    /// Intake hears B as any application (seat; a Private book's would-be seat
    /// bells — the wire's hand, A-809-11); taking A off is a non-event — a book
    /// A brought the note into keeps it.
    @Test func intakeHearsBAndTakingAOffIsANonEvent() throws {
        try withUndo { ops, _, db in
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let byA = try ops.createReading(name: "by a", kind: .book, querySpec: try RuleGrammar.encode(.tag(a.id)))
            let byB = try ops.createReading(name: "by b", kind: .book, querySpec: try RuleGrammar.encode(.tag(b.id)))
            let diary = try ops.createReading(name: "diary", kind: .book, querySpec: try RuleGrammar.encode(.tag(b.id)))
            _ = try ops.setBookPrivate(diary.id, true)
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(a.id, toPost: note.id)
            #expect(try status(db, byA.id, note.id) == "member")
            _ = try ops.replaceTagForClient(a.id, with: "b", onNote: note.id, undoLabel: label)
            #expect(try status(db, byA.id, note.id) == "member", "un-tagging never evicts (§19)")
            #expect(try status(db, byB.id, note.id) == "member")
            #expect(try status(db, diary.id, note.id) == "arrival")
        }
    }

    @Test func theItemsRefusalsWriteNothing() throws {
        try withUndo { ops, stack, db in
            let a = try ops.createTag(name: "a")
            let note = try ops.createPost(title: "n")
            #expect(throws: OperationError.tagNotApplied(tagID: a.id, targetID: note.id)) {
                try ops.replaceTagForClient(a.id, with: "b", onNote: note.id, undoLabel: label)
            }
            _ = try ops.applyTag(a.id, toPost: note.id)
            #expect(throws: OperationError.invalidTagName(name: "//")) {
                try ops.replaceTagForClient(a.id, with: "//", onNote: note.id, undoLabel: label)
            }
            #expect(throws: OperationError.invalidTagName(name: "a")) {
                try ops.replaceTagForClient(a.id, with: "a", onNote: note.id, undoLabel: label)
            }
            #expect(throws: GuardRefused()) {
                try ops.replaceTagForClient(a.id, with: "b", onNote: note.id, undoLabel: label) { _ in throw GuardRefused() }
            }
            #expect(try worn(db, note.id) == ["a"])
            #expect(try db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM tag WHERE path = 'b'") } == 0,
                    "a refused item mints nothing")
            #expect(stack.depth == 0)
        }
    }

    /// The halves compare-and-set PER PART: her hand re-applying A since keeps
    /// A's part quiet (a live twin stands) while B's part still comes off; once
    /// BOTH parts have moved on, the undo writes nothing and retires the entry.
    @Test func eachHalfWritesOnlyThePartsThatStillReadTheAct() throws {
        try withUndo { ops, stack, db in
            let a = try ops.createTag(name: "a")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(a.id, toPost: note.id)
            _ = try ops.replaceTagForClient(a.id, with: "b", onNote: note.id, undoLabel: label)
            _ = try ops.applyTag(a.id, toPost: note.id)  // her hand: A again
            #expect(try stack.undoReporting(with: ops)?.changed == true)
            #expect(try worn(db, note.id) == ["a"], "B came off; A stands on her row")
            // A second act, both parts aged: her un-tag of B and her A.
            let other = try ops.createPost(title: "m")
            _ = try ops.applyTag(a.id, toPost: other.id)
            let done = try ops.replaceTagForClient(a.id, with: "b", onNote: other.id, undoLabel: label)
            try ops.removeTag(done.toTagID, fromPost: other.id)
            _ = try ops.applyTag(a.id, toPost: other.id)
            let quiet = try stack.undoReporting(with: ops)
            #expect(quiet?.changed == false, "nothing of the act's left to take back — the entry retires")
            #expect(try worn(db, other.id) == ["a"])
        }
    }
}
