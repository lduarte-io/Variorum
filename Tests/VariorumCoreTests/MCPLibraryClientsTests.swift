import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-641 — THE ONE FACT, "has this library ever had an MCP client?" (VX-590's,
// shared now with the Private row — her ruling 2026-10-28, QUESTIONS #245 RB-10 +
// her third pass: the row hides until the library has EVER had a client; a note or
// book already marked Private always shows it). The store's answer over every
// client row, any state — monotone through Deny — and the row's gate. Red on old by
// construction: neither existed (the row rendered in every library).

@Suite("VX-641 — the library has had a client: one fact, and the Private row's gate")
struct MCPLibraryClientsTests {
    @Test func theFactIsAnyClientRowAndStaysThroughADeny() throws {
        try withOperations { ops, db in
            #expect(try db.read { try Queries.mcpLibraryHasHadClient($0) } == false, "a fresh library: none")
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            #expect(client.state == .pending)
            #expect(try db.read { try Queries.mcpLibraryHasHadClient($0) }, "a waiting request counts")
            _ = try ops.approveMCPClient(client.id, granting: nil)
            #expect(try db.read { try Queries.mcpLibraryHasHadClient($0) }, "approved")
            try ops.denyMCPClient(client.id)
            #expect(try db.read { try Queries.mcpLibraryHasHadClient($0) }, "a Deny keeps the row — ever")
        }
    }

    @Test func thePrivateRowsGateIsTheFactOrTheMark() {
        #expect(MCPLibraryClients.everHadClient(clientRows: 0) == false)
        #expect(MCPLibraryClients.everHadClient(clientRows: 1))
        #expect(MCPLibraryClients.showsPrivateRow(everHadClient: false, marked: false) == false,
                "no AI to share with, nothing marked: hidden")
        #expect(MCPLibraryClients.showsPrivateRow(everHadClient: true, marked: false))
        #expect(MCPLibraryClients.showsPrivateRow(everHadClient: false, marked: true),
                "a mark synced from another Mac is never invisible")
        #expect(MCPLibraryClients.showsPrivateRow(everHadClient: true, marked: true))
    }
}
