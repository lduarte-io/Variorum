import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-259 — THE DOOR'S BOOK-NAME CHECK READS ONLY WHAT THE CLIENT CAN READ (VX-184's
// ladder, round 1; her ruling: "it's fine if an accidental book name duplicate is
// made - there's no schema protection against it and we already ruled that it's
// ok if that happens"; the run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — "VX-259").
// `rename_book` and `create_book` refused a name ANY live book wore — a Private
// book, another wing's — and the refusal echoed the stored name: an oracle on
// books the client cannot reach (F-7; the advice's "Anything you can't reach
// answers exactly as if it did not exist"). The door now compares against the
// books it can READ; a readable collider still refuses (her E13 guard, kept
// where it tells the client nothing it can't see).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

@Suite("VX-259 — the door's book-name check reads only the books the client can read", .serialized)
struct MCPBookNameReachServerTests {
    private func name(_ h: ServerHarness, _ id: String) throws -> String? {
        try h.database.read { try Reading.fetchOne($0, key: id)?.name }
    }

    @Test func renamingTowardAHiddenBooksNameLandsAndNamesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let drafts = try h.operations.createReading(name: "drafts", kind: .book)
            let secret = try h.operations.createReading(name: "secret", kind: .book)
            try h.operations.setBookPrivate(secret.id, true)
            let work = try h.operations.createWing(name: "work")
            let ledger = try h.operations.createReading(name: "ledger", kind: .book, wingId: work.id)
            let letters = try h.operations.createReading(name: "letters", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, drafts.id))
            _ = try h.approve("claude-code", spec(.read, .book, letters.id))

            // A Private book's name: the rename lands, and the answer names
            // only what the client asked for — never the hidden book's casing.
            let hidden = try await connection.client.callTool(name: "rename_book", arguments: [
                "book_id": .string(drafts.id), "name": .string("Secret"),
            ])
            #expect(hidden.isError != true, "a Private book's name is not the client's to see: \(text(hidden))")
            #expect(!text(hidden).contains("secret") && !text(hidden).contains("uplicate"), "\(text(hidden))")
            #expect(try json(hidden)["name"] as? String == "Secret")
            #expect(try name(h, drafts.id) == "Secret" && name(h, secret.id) == "secret", "a duplicate, as ruled")

            // Another wing's book: the same.
            let elsewhere = try await connection.client.callTool(name: "rename_book", arguments: [
                "book_id": .string(drafts.id), "name": .string("LEDGER"),
            ])
            #expect(elsewhere.isError != true, "another wing's book is not the client's to see: \(text(elsewhere))")
            #expect(!text(elsewhere).contains("ledger") && !text(elsewhere).contains("uplicate"), "\(text(elsewhere))")
            #expect(try name(h, drafts.id) == "LEDGER" && name(h, ledger.id) == "ledger")

            // The control: a book the client CAN read still refuses (her E13
            // guard — nothing told that the client can't already see).
            let readable = try await connection.client.callTool(name: "rename_book", arguments: [
                "book_id": .string(drafts.id), "name": .string("Letters"),
            ])
            #expect(readable.isError == true && text(readable).contains("letters"), "\(text(readable))")
            #expect(try name(h, drafts.id) == "LEDGER", "nothing written")
            await h.hangUp(connection)
        }
    }

    @Test func makingABookBesideAHiddenBooksNameLandsAndNamesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let secret = try h.operations.createReading(name: "secret", kind: .book)
            try h.operations.setBookPrivate(secret.id, true)
            let work = try h.operations.createWing(name: "work")
            _ = try h.operations.createReading(name: "ledger", kind: .book, wingId: work.id)
            _ = try h.operations.createReading(name: "letters", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            for (asked, hiddenName) in [("SECRET", "secret"), ("Ledger", "ledger")] {
                let made = try await connection.client.callTool(name: "create_book", arguments: [
                    "name": .string(asked), "wing_id": .string(""),
                ])
                #expect(made.isError != true, "\(hiddenName) is not the client's to see: \(text(made))")
                #expect(!text(made).contains(hiddenName) && !text(made).contains("uplicate"), "\(text(made))")
            }
            let names = try await h.database.read { db in
                try String.fetchAll(db, sql: "SELECT name FROM reading WHERE wing_id = '' AND deleted_at IS NULL ORDER BY name")
            }
            #expect(names == ["Ledger", "SECRET", "letters", "secret"], "duplicates, as ruled")

            // The control: a book of the wing it writes into — one it can read.
            let readable = try await connection.client.callTool(name: "create_book", arguments: [
                "name": .string("LETTERS"), "wing_id": .string(""),
            ])
            #expect(readable.isError == true && text(readable).contains("letters"), "\(text(readable))")
            await h.hangUp(connection)
        }
    }
}
