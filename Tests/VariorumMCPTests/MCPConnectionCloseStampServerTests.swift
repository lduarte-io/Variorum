import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-626 — "LAST SEEN" STAMPS THE CLOSE (the VX-648 run, batch 2; the VX-620 mid
// window's finding W-1: seconds after a ~13-minute session closed, Settings ▸ MCP's
// Clients row read "last seen 13 minutes ago"). The mechanism: `mcp_client.last_seen_at`
// was written at the connection's ADMISSION (`recordMCPContact`) and never again, so a
// closed session's row read its START. The fix stamps the END on the ONE road that
// already runs at every ending — the end line (VX-394's family: the client's close,
// a stop, the lock road's early write) — with the same clock read as the line, so the
// Clients row and Activity agree. RED ON OLD: the row reads the admission stamp.

private func spec(_ rung: MCPGrantRule.Rung = .read) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: .wing, scopeID: "", duration: .always)
}

@Suite("VX-626 — a closed connection's last seen is its end, not its start", .serialized)
struct MCPConnectionCloseStampServerTests {
    private func lastSeen(_ h: ServerHarness, _ name: String) throws -> String {
        try h.client(name).lastSeenAt
    }

    /// The newest connection-end line for `name` (nil: none yet).
    private func endLine(_ h: ServerHarness, _ name: String) throws -> MCPActivityRow? {
        let acts = Set(MCPConnectionEnd.allCases.map(\.act))
        return try h.database.read { db in try Queries.mcpActivity(db) }
            .first { $0.clientName == name && acts.contains($0.act) }
    }

    /// The walker's road: a session that lives a while (calls tick the
    /// world's clock), then the CLIENT closes — the row reads the end line's
    /// own moment, never the admission's.
    @Test func aClientsCloseIsItsLastSeenNotItsStart() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec())
            let admitted = try lastSeen(h, "claude-code")
            for _ in 0..<5 {
                #expect(try await connection.client.callTool(name: "list_books", arguments: [:]).isError != true)
            }
            await h.hangUp(connection)
            #expect(try await h.eventually { try endLine(h, "claude-code") != nil })
            let line = try #require(try endLine(h, "claude-code"))
            #expect(line.act == MCPConnectionEnd.clientClosed.act)
            let seen = try lastSeen(h, "claude-code")
            #expect(seen == line.at, "last seen is the close's own moment — the line's")
            #expect(seen > admitted, "never the session's start (\(admitted))")
        }
    }

    /// A stop (the switch off) stamps every connection it ends, each once —
    /// and a second client's row is its own.
    @Test func aStopStampsEveryConnectionItEnds() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let first = try await h.connect(as: "claude-code")
            let second = try await h.connect(as: "codex")
            _ = try h.approve("claude-code", spec())
            _ = try h.approve("codex", spec())
            let admitted = (try lastSeen(h, "claude-code"), try lastSeen(h, "codex"))
            #expect(try await first.client.callTool(name: "list_books", arguments: [:]).isError != true)
            h.host.stop(ending: .serverOff)
            #expect(try await h.eventually {
                try endLine(h, "claude-code") != nil && endLine(h, "codex") != nil
            })
            for (name, start) in [("claude-code", admitted.0), ("codex", admitted.1)] {
                let line = try #require(try endLine(h, name))
                #expect(line.act == MCPConnectionEnd.serverOff.act)
                #expect(try lastSeen(h, name) == line.at && line.at > start, "\(name)")
            }
            _ = second
        }
    }

    /// The lock road's early write (`recordConnectionEnds` — the store still
    /// open) stamps as it says; the hang-up after it writes nothing more.
    @Test func theLockRoadsLineStampsTooAndTheHangUpAddsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec())
            #expect(try await connection.client.callTool(name: "list_books", arguments: [:]).isError != true)
            let admitted = try lastSeen(h, "claude-code")
            try h.host.recordConnectionEnds(.libraryClosed)
            let line = try #require(try endLine(h, "claude-code"))
            #expect(line.act == MCPConnectionEnd.libraryClosed.act)
            let stamped = try lastSeen(h, "claude-code")
            #expect(stamped == line.at && stamped > admitted)
            h.host.stop(ending: .libraryClosed)
            try await Task.sleep(for: .milliseconds(200))
            #expect(try lastSeen(h, "claude-code") == stamped, "said once, stamped once")
        }
    }

    /// GUARD (P-VX394-5 — "a QUIT logs nothing"): the quit forgoes the line,
    /// and the stamp rides the line, so a quit writes nothing — the row keeps
    /// what it read (recorded in the batch record as the one ending left
    /// unstamped). Green on both sides.
    @Test func aQuitWritesNoLineAndNoStamp() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec())
            #expect(try await connection.client.callTool(name: "list_books", arguments: [:]).isError != true)
            let before = try lastSeen(h, "claude-code")
            h.host.stopWithTheProcess()
            try await Task.sleep(for: .milliseconds(200))
            #expect(try endLine(h, "claude-code") == nil)
            #expect(try lastSeen(h, "claude-code") == before)
        }
    }
}
