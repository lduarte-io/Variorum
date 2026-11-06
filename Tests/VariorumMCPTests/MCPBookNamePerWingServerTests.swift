import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-816 (the VX-878 run, batch 3 — the record
// `notes/plans/fixes/vx-878-book-doors-faces.md`, BATCH 3 RECORD): THE WIRE'S
// BOOK-NAME CHECK SCOPES TO THE TARGET'S WING. The agent's own report, via her:
// "'posted' in writing was refused because PlanetLillian has 'Posted'." Every
// tool that names a reading — `create_book`, `rename_book`, `import_document`'s
// book form, `create_gathering` — keeps VX-259/VX-363's reach scoping (a book it
// cannot READ never counts) AND gains the wing scope: a collider counts only if
// the client can read it AND it lives in the wing the act names.
//
// RED ON OLD: in every arm below the client CAN read "Posted" (a read grant on
// its wing), so the old store-wide guard refused each call naming it; the same
// wing's readable "Letters" refuses on both trees (the control).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

@Suite("VX-816 — the wire's book-name check counts only the target wing's readable books", .serialized)
struct MCPBookNamePerWingServerTests {
    private func name(_ h: ServerHarness, _ id: String) throws -> String? {
        try h.database.read { try Reading.fetchOne($0, key: id)?.name }
    }

    /// PlanetLillian holds "Posted" and "Ledger" (readable to the client: a read
    /// grant on the wing); Home holds "Letters" (readable: the write-new grant on
    /// Home).
    private func world(_ h: ServerHarness) throws -> (planet: String, drafts: String, letters: String) {
        let planet = try h.operations.createWing(name: "PlanetLillian")
        _ = try h.operations.createReading(name: "Posted", kind: .book, wingId: planet.id)
        _ = try h.operations.createReading(name: "Ledger", kind: .book, wingId: planet.id)
        let letters = try h.operations.createReading(name: "Letters", kind: .book)
        let drafts = try h.operations.createReading(name: "drafts", kind: .book)
        return (planet.id, drafts.id, letters.id)
    }

    private func grants(_ h: ServerHarness, planet: String, drafts: String) throws {
        _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
        let client = try h.client("claude-code").id
        _ = try h.operations.grantMCPAccess(client, spec(.read, .wing, planet))
        _ = try h.operations.grantMCPAccess(client, spec(.edit, .book, drafts))
    }

    @Test func createBookAndCreateGatheringCheckOnlyTheirWing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            try grants(h, planet: w.planet, drafts: w.drafts)

            let book = try await connection.client.callTool(name: "create_book", arguments: [
                "name": .string("posted"), "wing_id": .string(""),
            ])
            #expect(book.isError != true, "RED ON OLD: another wing's book never blocks the name: \(text(book))")
            if book.isError != true {
                let id = try #require(try json(book)["book_id"] as? String)
                #expect(try name(h, id) == "posted")
            }
            let gathering = try await connection.client.callTool(name: "create_gathering", arguments: [
                "name": .string("LEDGER"), "wing_id": .string(""), "rule": .object(["star": .bool(true)]),
            ])
            #expect(gathering.isError != true, "RED ON OLD: nor a gathering's: \(text(gathering))")

            // The control: the same wing's readable book still refuses, naming it.
            for tool in ["create_book", "create_gathering"] {
                var arguments: [String: Value] = ["name": .string("letters"), "wing_id": .string("")]
                if tool == "create_gathering" { arguments["rule"] = .object(["star": .bool(true)]) }
                let same = try await connection.client.callTool(name: tool, arguments: arguments)
                #expect(same.isError == true && text(same).contains("Letters"), "\(tool): \(text(same))")
            }
            await h.hangUp(connection)
        }
    }

    @Test func renameBookChecksOnlyTheBooksOwnWing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            try grants(h, planet: w.planet, drafts: w.drafts)

            let other = try await connection.client.callTool(name: "rename_book", arguments: [
                "book_id": .string(w.drafts), "name": .string("POSTED"),
            ])
            #expect(other.isError != true, "RED ON OLD: another wing's book never blocks the name: \(text(other))")
            #expect(try name(h, w.drafts) == "POSTED")

            let same = try await connection.client.callTool(name: "rename_book", arguments: [
                "book_id": .string(w.drafts), "name": .string("letters"),
            ])
            #expect(same.isError == true && text(same).contains("Letters"), "\(text(same))")
            #expect(try name(h, w.drafts) == "POSTED", "nothing written")
            await h.hangUp(connection)
        }
    }

    @Test func aBookImportChecksOnlyItsWing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            try grants(h, planet: w.planet, drafts: w.drafts)
            func book(_ name: String) -> Value {
                .object(["name": .string(name), "documents": .array([.string("{t:\"one\"}\n\nOne.")])])
            }

            let other = try await connection.client.callTool(name: "import_document", arguments: [
                "wing_id": .string(""), "book": book("posted"),
            ])
            #expect(other.isError != true, "RED ON OLD: another wing's book never blocks the name: \(text(other))")
            if other.isError != true {
                let id = try #require(try json(other)["book_id"] as? String)
                #expect(try name(h, id) == "posted")
            }
            let same = try await connection.client.callTool(name: "import_document", arguments: [
                "wing_id": .string(""), "book": book("LETTERS"),
            ])
            #expect(same.isError == true && text(same).contains("Letters"), "\(text(same))")
            await h.hangUp(connection)
        }
    }
}
