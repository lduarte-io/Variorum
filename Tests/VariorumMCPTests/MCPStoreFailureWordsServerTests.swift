import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-369 (the VX-771 run, batch 2 — the run record's BATCH 2 RECORD, the SWEEP TABLE):
// the one class of non-`OperationError` throw a wire tool can reach past the wire's
// words — a STORE FAILURE (GRDB `DatabaseError` of the environment kind: a full disk, a
// read-only volume, an I/O error, a failing trigger; and a keyed store's sanitized
// connection error, `RedactedKeyedStatementError`). Before the fix it reached the client
// RAW at two kinds of site: through the one chain (`MCPWireRefusalCopy.spoken` — no wire
// words, so the app's hook printed `String(describing:)`, GRDB's text with the executed
// SQL), and through each tool family's catch-all (`"Variorum couldn't complete X: \(error)"`
// — write, read and show), which a failure escaping `land` (the refusal's own log write)
// or a read tool's write reaches.
//
// The failures are made real on the harness's one connection by TEMP triggers that
// abort a write the way a failing store does (GRDB raises the same `DatabaseError` for a
// full disk, a read-only volume or a trigger's abort): one on the act's UPDATE (the act
// fails, its refusal log lands), and one on the activity log too (every family's own
// write fails, so the error leaves the tool's body for its catch-all). RED ON OLD: each
// answer carries GRDB's description ("… - while executing `…`").

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// The store-failure sentence (PROVISIONAL P-771-11), spelled HERE so the pins
/// compile and run on the tree before the fix.
private func storeWords(_ detail: String?) -> String {
    "Variorum's library store refused the work" + (detail.map { " (\($0))" } ?? "")
        + ", so this call may not have landed — read what it touches before trying again."
}

/// GRDB's own description — the raw face the fix replaces.
private func isRaw(_ answer: String) -> Bool {
    answer.contains("while executing") || answer.contains("Refused:") || answer.contains("DatabaseError")
}

@Suite("VX-369 — a store failure on the wire is worded, never GRDB's description", .serialized)
struct MCPStoreFailureWordsServerTests {
    /// The act's own write fails (a trigger aborts the UPDATE); its refusal log
    /// lands. The answer leaves `land` through the one chain. RED ON OLD.
    @Test func aStoreFailureInsideTheActIsWordedThroughTheChain() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "ch 1")
            let seeded = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, note.id))
            try await h.database.write { db in
                try db.execute(sql: """
                    CREATE TEMP TRIGGER vx369_store_failure BEFORE UPDATE OF working_text ON variant
                    BEGIN SELECT RAISE(ABORT, 'simulated store failure'); END
                    """)
            }
            let answer = try await call(connection, "edit_take", [
                "take_id": .string(seeded.variant.id), "text": .string("New."), "expected_text": .string("Her line."),
            ])
            #expect(answer.isError == true)
            #expect(text(answer) == storeWords("SQLite error 19: simulated store failure"), "\(text(answer))")
            #expect(!isRaw(text(answer)), "never GRDB's text: \(text(answer))")
            try await h.database.write { db in try db.execute(sql: "DROP TRIGGER vx369_store_failure") }
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [seeded.variant.id])
            } == "Her line.", "the act rolled back")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    /// The store refuses the act AND the activity log: the write tool's refusal
    /// log fails too, so the error leaves `land` for the write family's
    /// catch-all; a read tool's activity write and a show's log meet their own
    /// families' catch-alls. Each is worded. RED ON OLD.
    @Test func aStoreRefusingEveryWriteIsWordedAtEveryFamilysCatchAll() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let seeded = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            try await h.database.write { db in
                try db.execute(sql: """
                    CREATE TEMP TRIGGER vx369_act_failure BEFORE UPDATE OF working_text ON variant
                    BEGIN SELECT RAISE(ABORT, 'the store refused'); END
                    """)
                try db.execute(sql: """
                    CREATE TEMP TRIGGER vx369_log_failure BEFORE INSERT ON mcp_activity
                    BEGIN SELECT RAISE(ABORT, 'the store refused'); END
                    """)
            }

            let answers = [
                ("edit_take", try await call(connection, "edit_take", [
                    "take_id": .string(seeded.variant.id), "text": .string("New."), "expected_text": .string("Her line."),
                ])),
                ("list_books", try await call(connection, "list_books", [:])),
                ("show_in_app", try await call(connection, "show_in_app", [
                    "target": .string("note"), "note_id": .string(note.id),
                ])),
            ]
            try await h.database.write { db in
                try db.execute(sql: "DROP TRIGGER vx369_act_failure")
                try db.execute(sql: "DROP TRIGGER vx369_log_failure")
            }
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [seeded.variant.id])
            } == "Her line.", "nothing landed")
            for (tool, answer) in answers {
                #expect(answer.isError == true, "\(tool)")
                #expect(text(answer) == storeWords("SQLite error 19: the store refused"),
                        "\(tool): \(text(answer))")
                #expect(!isRaw(text(answer)), "\(tool): never GRDB's text: \(text(answer))")
            }
            await h.hangUp(connection)
        }
    }

    /// The chain itself, for both store-failure types, under the app's hook
    /// (the Mac's `OpsRefusalCopy.message(for:)` answers `String(describing:)`
    /// for any type its table doesn't know) and under no hook at all: the wire's
    /// words FIRST — SQLite's code and its own message, never the executed SQL;
    /// a keyed store's sanitized connection error says no detail. RED ON OLD.
    @Test func theChainWordsBothStoreFailureTypesFirst() {
        let full = DatabaseError(
            resultCode: .SQLITE_FULL, message: "database or disk is full",
            sql: "UPDATE variant SET working_text = ? WHERE id = ?")
        let keyed = RedactedKeyedStatementError(
            description: "SQLite error 26: file is not a database - while executing `PRAGMA key = <store key redacted>`")
        for hook in [{ (error: Error) -> String? in String(describing: error) }, { (_: Error) -> String? in nil }] {
            #expect(MCPWireRefusalCopy.spoken(full, appWords: hook)
                    == storeWords("SQLite error 13: database or disk is full"))
            #expect(MCPWireRefusalCopy.spoken(keyed, appWords: hook) == storeWords(nil))
        }
        #expect(!MCPWireRefusalCopy.spoken(full) { _ in nil }.contains("UPDATE"), "never the executed SQL")
    }
}
