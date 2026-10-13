import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U4 — VX-195, THE COMMITS FAMILY at EDIT (R-VX184-1): `restore_commit`
// — her `restoreCommit`, INSURED first (a quiet commit of the text it replaces,
// "before ‹client›'s restore", and one of the restored text, "after …" — the
// eighth occasion's bracket; both stay when her ⌥⌘Z walks the restore back) —
// and `rename_commit` — her `renameCommitPoint` exactly (nil clears, the
// same name writes nothing, the seal checked first, a locked take allowed —
// QUESTIONS #121), the message as given. ONE client-named undo entry each.
// Written BEFORE the fix: on the pre-fix tree both tools answer "Unknown tool".

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("VX-195 — the commits family at edit: restore (insured) and rename", .serialized)
struct MCPCommitEditServerTests {
    /// A note in a book: one take that was committed ("first") at "First
    /// draft." and has since been rewritten to "Second draft." (unsaved).
    private struct World {
        let book: Reading
        let note: Container
        let block: String
        let take: String
        let first: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let one = try h.operations.newBlock(in: note.id, text: "First draft.", registeringUndo: false)
        let first = try h.operations.commit(one.variant.id, message: "first")
        try h.operations.autosave(one.variant.id, text: "Second draft.", charDelta: 6)
        return World(book: book, note: note, block: one.block.id, take: one.variant.id, first: first.id)
    }

    private func buffer(_ h: ServerHarness, _ take: String) async throws -> String {
        try await h.database.read { db in
            try #require(try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [take]))
        }
    }

    /// Newest first: (message, text).
    private func history(_ h: ServerHarness, _ take: String) async throws -> [[String?]] {
        try await h.database.read { db in
            try Row.fetchAll(
                db, sql: "SELECT message, text FROM commit_point WHERE variant_id = ? ORDER BY created_at DESC, id DESC",
                arguments: [take]).map { [$0["message"], $0["text"]] }
        }
    }

    // MARK: - restore_commit

    @Test func restoreCommitIsInsuredBothSidesAndOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let restored = try await call(connection, "restore_commit", ["commit_id": .string(w.first)])
            #expect(restored.isError != true, "\(text(restored))")
            let answer = try json(restored)
            #expect(answer["changed"] as? Bool == true && answer["take_id"] as? String == w.take)
            #expect(answer["before_commit_id"] is String && answer["after_commit_id"] is String)
            #expect(try await buffer(h, w.take) == "First draft.")
            #expect(try await history(h, w.take) == [
                ["after claude-code's restore", "First draft."],
                ["before claude-code's restore", "Second draft."],
                ["first", "First draft."],
            ], "the replaced words insured first; the restore named after the client")
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's commit restore")
            #expect(h.receipts.value.last?.act.rawValue == "commit restore")

            // Already reading the commit's words: nothing to do.
            let again = try json(try await call(connection, "restore_commit", ["commit_id": .string(w.first)]))
            #expect(again["changed"] as? Bool == false)
            let count = try await history(h, w.take).count
            #expect(h.undoStack.depth == 1 && count == 3)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's commit restore")
            #expect(try await buffer(h, w.take) == "Second draft.", "her ⌥⌘Z: the words it replaced")
            #expect(try await history(h, w.take).count == 3, "commits stay")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's commit restore")
            #expect(try await buffer(h, w.take) == "First draft.")
            await h.hangUp(connection)
        }
    }

    /// Where her restore refuses, this one does — a locked take, an archived
    /// take, a sealed note — and nothing is written.
    @Test func restoreCommitRefusesWhereHersDoes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let other = try h.operations.branchVariant(w.block, from: w.take)
            let otherCommit = try h.operations.commit(other.id, message: "kept")
            try h.operations.archiveVariant(other.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let archived = try await call(connection, "restore_commit", ["commit_id": .string(otherCommit.id)])
            #expect(archived.isError == true && text(archived).contains("archivedVariant"), "\(text(archived))")
            try h.operations.lockVariant(w.take)
            let locked = try await call(connection, "restore_commit", ["commit_id": .string(w.first)])
            #expect(locked.isError == true && text(locked).contains("lockedVariant"), "\(text(locked))")
            try h.operations.unlockVariant(w.take)
            try h.operations.lockPost(w.note.id)
            let sealed = try await call(connection, "restore_commit", ["commit_id": .string(w.first)])
            #expect(sealed.isError == true && text(sealed).contains("lockedPost"), "\(text(sealed))")
            #expect(try await buffer(h, w.take) == "Second draft.")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }

    // MARK: - rename_commit

    @Test func renameCommitIsHerRenameAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            func message() async throws -> String? {
                try await h.database.read { db in
                    try String.fetchOne(db, sql: "SELECT message FROM commit_point WHERE id = ?", arguments: [w.first])
                }
            }

            let renamed = try await call(connection, "rename_commit", [
                "commit_id": .string(w.first), "message": .string("the first draft"),
            ])
            #expect(renamed.isError != true, "\(text(renamed))")
            #expect(try json(renamed)["message"] as? String == "the first draft")
            #expect(try await message() == "the first draft", "as given — her rename, no prefix")
            #expect(h.undoStack.topLabel == "claude-code's commit name")
            #expect(h.receipts.value.last?.act.rawValue == "commit name")
            let same = try json(try await call(connection, "rename_commit", [
                "commit_id": .string(w.first), "message": .string("the first draft"),
            ]))
            #expect(same["changed"] as? Bool == false && h.undoStack.depth == 1, "the same name writes nothing")

            // A locked take's commit may be renamed (QUESTIONS #121).
            try h.operations.lockVariant(w.take)
            let cleared = try json(try await call(connection, "rename_commit", [
                "commit_id": .string(w.first), "message": .null,
            ]))
            #expect(cleared["changed"] as? Bool == true && cleared["message"] is NSNull)
            #expect(try await message() == nil)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's commit name")
            #expect(try await message() == "the first draft")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's commit name")
            #expect(try await message() == "first", "her name, back")

            try h.operations.lockPost(w.note.id)
            let sealed = try await call(connection, "rename_commit", [
                "commit_id": .string(w.first), "message": .string("first"),
            ])
            #expect(sealed.isError == true && text(sealed).contains("lockedPost"),
                    "the seal is checked before the no-op: \(text(sealed))")
            await h.hangUp(connection)
        }
    }

    // MARK: - The rung and the one answer

    @Test func belowEditTheRungRefusesAndOutsideTheGrantIsTheOneAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let outside = try h.operations.createPost(title: "not shared")
            let theirs = try h.operations.newBlock(in: outside.id, text: "Elsewhere.", registeringUndo: false)
            let theirCommit = try h.operations.commit(theirs.variant.id, message: "theirs")
            let gone = try h.operations.branchVariant(w.block, from: w.take)
            let goneCommit = try h.operations.commit(gone.id, message: "gone")
            try h.operations.deleteVariant(gone.id)
            func arguments(_ tool: String, _ id: String) -> [String: Value] {
                tool == "rename_commit" ? ["commit_id": .string(id), "message": .string("x")] : ["commit_id": .string(id)]
            }

            let maker = try await h.connect(as: "maker")
            _ = try h.approve("maker", spec(.writeNew, .book, w.book.id))
            for tool in ["restore_commit", "rename_commit"] {
                let refused = try await call(maker, tool, arguments(tool, w.first))
                #expect(refused.isError == true
                        && text(refused).hasPrefix("This client may only read, suggest and write new here."),
                        "\(tool): \(text(refused))")
            }
            #expect(h.asks.value.last?.clientName == "maker" && h.asks.value.last?.rung == .edit)
            await h.hangUp(maker)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            let unshared = MCPRefusalCopy.words(.notShared, .note)
            for tool in ["restore_commit", "rename_commit"] {
                for id in [theirCommit.id, goneCommit.id, "no-such-commit"] {
                    let refused = try await call(connection, tool, arguments(tool, id))
                    #expect(refused.isError == true && text(refused) == unshared, "\(tool) \(id): \(text(refused))")
                }
            }
            #expect(try await buffer(h, w.take) == "Second draft.")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }
}
