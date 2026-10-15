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

    /// **VX-197 (VX-336 U8a): rename_book's description says VX-259.** Its
    /// VX-184 words said a name another live book wears is refused "as the
    /// author's rename is" — untrue since VX-259: the door counts only a live,
    /// unarchived reading (book or gathering — `requireBookNameFree`) that
    /// THIS client can read (`readableBooks`), while her own rename counts
    /// every one. The two pins above run the mechanics; this one holds the
    /// words to them (red on the old description).
    @Test func renameBooksDescriptionSaysOnlyBooksYouCanReadCount() {
        let words = MCPToolCatalog.renameBook.description
        #expect(!words.contains("as the author's rename is"), "the old claim is gone: \(words)")
        #expect(words.contains(
            "A name already worn (ignoring case) by another live, unarchived book or gathering that you can "
                + "read is refused; one you can't read never counts, so it can't block the name."), "\(words)")
    }

    /// **VX-363 (VX-336 U9 — the third road VX-259 missed; provisional ruling 2):**
    /// `import_document`'s BOOK form names a book too (the folder import's E13
    /// guard, `importBook` → `requireBookNameFree`), and it counted EVERY live
    /// book — a Private one, another wing's — refusing with the hidden book's
    /// stored name: the same oracle (F-7). The door now counts only the books
    /// the client can read; her own import doors keep the full guard.
    /// *Red on the old tree:* both imports refused, echoing "secret" / "ledger".
    @Test func importingABookBesideAHiddenBooksNameLandsAndNamesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let secret = try h.operations.createReading(name: "secret", kind: .book)
            try h.operations.setBookPrivate(secret.id, true)
            let work = try h.operations.createWing(name: "work")
            _ = try h.operations.createReading(name: "ledger", kind: .book, wingId: work.id)
            _ = try h.operations.createReading(name: "letters", kind: .book)
            func book(_ name: String) -> Value {
                .object(["name": .string(name), "documents": .array([.string("{t:\"one\"}\n\nOne.")])])
            }
            // Her own door counts every book (E13 whole) — a guard, both trees.
            let one = VariorumDocument.NamedDocument(
                fallbackTitle: "", document: try VariorumDocument.parse("{t:\"one\"}\n\nOne."))
            #expect(throws: OperationError.duplicateBookName(name: "secret")) {
                try h.operations.importBook(
                    VariorumDocument.Book(name: "Secret", chapters: [], unfiled: [one]), wingId: "")
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            for (asked, hiddenName) in [("SECRET", "secret"), ("Ledger", "ledger")] {
                let imported = try await connection.client.callTool(name: "import_document", arguments: [
                    "wing_id": .string(""), "book": book(asked),
                ])
                #expect(imported.isError != true, "\(hiddenName) is not the client's to see: \(text(imported))")
                #expect(!text(imported).contains(hiddenName) && !text(imported).contains("uplicate"),
                        "\(text(imported))")
                if imported.isError != true {
                    let bookID = try #require(try json(imported)["book_id"] as? String)
                    #expect(try name(h, bookID) == asked, "the client's own spelling, a duplicate as ruled")
                }
            }
            #expect(try name(h, secret.id) == "secret", "the hidden book untouched")

            // The control: a book of the wing it writes into — one it can read.
            let readable = try await connection.client.callTool(name: "import_document", arguments: [
                "wing_id": .string(""), "book": book("LETTERS"),
            ])
            #expect(readable.isError == true && text(readable).contains("letters"), "\(text(readable))")
            await h.hangUp(connection)
        }
    }
}
