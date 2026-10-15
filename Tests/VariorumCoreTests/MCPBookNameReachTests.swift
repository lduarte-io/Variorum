import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-259 — THE NAME GUARD'S `counting` (the run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — "VX-259"): the two
// MCP book ops take the readings their E13 guard COUNTS (the wire passes the ones
// the client can read); nil counts every reading — her own doors' guard, whole.
// The predicate is asked of colliders only, inside the act's transaction.

@Suite("VX-259 — the book-name guard counts only what it is told to")
struct MCPBookNameReachTests {
    @Test func aCollidingReadingThatDoesNotCountIsPassedBy() throws {
        try withOperations { ops, db in
            let hidden = try ops.createReading(name: "Secret", kind: .book)
            let book = try ops.createReading(name: "drafts", kind: .book)
            let asked = LockIsolated<[String]>([])
            let none: Operations.BookNameReach = { _, id in asked.withValue { $0.append(id) }; return false }

            let renamed = try ops.renameBookForClient(book.id, name: "secret", undoLabel: "x", namesCountedBy: none)
            #expect(renamed.changed && renamed.name == "secret", "a duplicate the client can't see is fine")
            #expect(asked.value == [hidden.id], "asked of the collider alone")
            let made = try ops.createBook(named: "SECRET", inWing: "", undoLabel: "x", namesCountedBy: none)
            #expect(made.name == "SECRET")

            // nil counts every reading (her doors' guard, whole) …
            #expect(throws: OperationError.duplicateBookName(name: "Secret")) {
                try ops.createBook(named: "secret", inWing: "", undoLabel: "x")
            }
            // … and a collider that counts refuses, naming it.
            let all: Operations.BookNameReach = { _, _ in true }
            #expect(throws: OperationError.duplicateBookName(name: "Secret")) {
                try ops.renameBookForClient(made.id, name: "secret ", undoLabel: "x", namesCountedBy: all)
            }
            #expect(try db.read { try Reading.fetchOne($0, key: made.id)?.name } == "SECRET", "nothing written")
        }
    }

    /// **VX-363 (the VX-336 run record's U9):** the folder import names a book
    /// too, so it takes the same `namesCountedBy` — the MCP book import passes
    /// it through; nil (her File ▸ Import… and the Bookcase drop) counts every
    /// reading. A new parameter: red by its absence on the old tree.
    @Test func theBookImportCountsOnlyWhatItIsToldTo() throws {
        try withOperations { ops, _ in
            let hidden = try ops.createReading(name: "Secret", kind: .book)
            let asked = LockIsolated<[String]>([])
            let none: Operations.BookNameReach = { _, id in asked.withValue { $0.append(id) }; return false }
            let one = VariorumDocument.NamedDocument(
                fallbackTitle: "", document: try VariorumDocument.parse("{t:\"one\"}\n\nOne."))
            func book(_ name: String) -> VariorumDocument.Book { .init(name: name, chapters: [], unfiled: [one]) }

            let landed = try ops.importBook(book("SECRET"), wingId: "", undoLabel: "x", namesCountedBy: none)
            #expect(landed.reading.name == "SECRET", "a duplicate the client can't see is fine")
            #expect(asked.value == [hidden.id], "asked of the collider alone")
            #expect(throws: OperationError.duplicateBookName(name: "Secret")) {
                try ops.importBook(book("secret"), wingId: "")
            }
        }
    }
}
