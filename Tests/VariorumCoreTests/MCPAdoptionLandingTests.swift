import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-b U2 Q4 — ledger row 10, R-13nb-6 (hers): a handed-off or restored
// library arrives with the MCP server OFF, grants kept, resuming on her
// deliberate re-enable. The door's write is `landMCPAfterAdoption`, keyed on
// the restore hold's stamp (every 13x adoption writes one).

@Suite("13n-b U2 — adoption lands the MCP server OFF (R-13nb-6)")
struct MCPAdoptionLandingTests {
    @Test func anAdoptionsHoldTurnsTheServerOffOnceKeepingGrantsAndHerReEnableStands() throws {
        try withOperations { ops, db in
            let client = try ops.recordMCPContact(name: "claude-code", version: nil)
            let book = try ops.createReading(name: "shared", kind: .book)
            try ops.approveMCPClient(
                client.id, granting: .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            try ops.setMCPSwitch(.server, on: true)
            try ops.setMCPSwitch(.openBook, on: true)
            func serverOn() throws -> Bool { try db.read { try Queries.mcpSwitch($0, .server) } }

            #expect(try ops.landMCPAfterAdoption(holdStamp: "2026-10-09T12:00:00.000Z"))
            #expect(try serverOn() == false, "the adopted library lands OFF whatever it was")
            #expect(try db.read { try Queries.mcpGrants($0, clientID: client.id) }.count == 1, "grants kept as data")
            #expect(try db.read { try Queries.mcpClient($0, id: client.id) }?.state == .approved)
            #expect(try db.read { try Queries.mcpSwitch($0, .openBook) }, "only the server switch moves")

            try ops.setMCPSwitch(.server, on: true)  // her deliberate re-enable
            #expect(try ops.landMCPAfterAdoption(holdStamp: "2026-10-09T12:00:00.000Z") == false,
                    "the SAME hold, read again at the next ready, changes nothing")
            #expect(try serverOn(), "her re-enable stands for the rest of the hold's life")

            #expect(try ops.landMCPAfterAdoption(holdStamp: "2026-10-10T08:00:00.000Z"),
                    "a NEW adoption's hold lands OFF again")
            #expect(try serverOn() == false)
        }
    }

    @Test func aFreshStoreLandsOffAndRecordsTheHoldWithoutAnyPriorSwitchRow() throws {
        try withOperations { ops, db throws in
            #expect(try ops.landMCPAfterAdoption(holdStamp: "0001-01-01T00:00:00.000Z"))
            #expect(try db.read { try Queries.mcpSwitch($0, .server) } == false)
            #expect(try db.fetchString("SELECT value FROM mcp_switch WHERE key = ?", [Queries.mcpAdoptionAckKey])
                    == "0001-01-01T00:00:00.000Z")
        }
    }
}
