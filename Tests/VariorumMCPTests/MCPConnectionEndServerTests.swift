import Darwin
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-394 (VX-348 U5 — the run record `notes/plans/fixes/vx-348-prelaunch-sweep.md`
// §U5, VX-394's section): "partway through a long Claude Code session (around
// 3–4 AM, Mac likely idle), all Variorum tools vanished with 'MCP server
// disconnected'. The app still showed 'running'." The traced kill path is the
// library LOCKING (Castle's re-lock on sleep, screen lock or time away — counted
// from HER use of Variorum, never a client's calls): the lock detaches the door,
// the server stops and hangs up every connection, and the next unlock starts it
// again, "running". Nothing said a connection had ended, or why. Each
// connection that ends now leaves ONE line in the activity log saying how —
// the client closed it, the library closed, the switch went off, or a message
// was over the cap — so the log tells "the client ended it" from "Variorum did".

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value] = [:]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// The connection-end rows, oldest first, as (client, act).
private func ends(_ h: ServerHarness) throws -> [(String, String)] {
    let acts = MCPConnectionEnd.allCases.map(\.act)
    return try h.database.read { db in try Queries.mcpActivity(db) }
        .reversed()
        .filter { acts.contains($0.act) }
        .map { ($0.clientName, $0.act) }
}

/// The log's newest row (a sync read — the async overload would win in a test body).
private func newestRow(_ h: ServerHarness) throws -> MCPActivityRow? {
    try h.database.read { try Queries.mcpActivity($0, limit: 1) }.first
}

private func initialize(_ name: String) -> String {
    #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"#
}

@Suite("VX-394 — a dropped connection says why, in the activity log", .serialized)
struct MCPConnectionEndServerTests {
    // MARK: - RED ON OLD: no connection's end was ever logged

    /// The client's own close (it quit, restarted its server, or its process
    /// ended) — the server still running — is said as the client's.
    @Test func aClientThatClosesItsConnectionLeavesOneLineSayingSo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            #expect(try await call(connection, "list_books").isError != true)
            await h.hangUp(connection)
            #expect(try await h.eventually { try ends(h).count == 1 }, "the drop is logged")
            let logged = try ends(h)
            #expect(logged.map(\.0) == ["claude-code"] && logged.map(\.1) == [MCPConnectionEnd.clientClosed.act])
            let row = try #require(try newestRow(h))
            #expect(row.allowed && row.targetKind == nil && row.targetID == nil, "an event, target-less")
        }
    }

    /// The switch OFF ends every connection — each one says the server was
    /// turned off, never that the client left.
    @Test func theServerSwitchedOffEndsEveryConnectionAndSaysSo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            _ = try await h.connect(as: "claude-code")
            _ = try await h.connect(as: "codex")
            #expect(try await h.eventually { h.host.connectedClientNames == ["claude-code", "codex"] })
            h.host.stop(ending: .serverOff)
            #expect(try await h.eventually { try ends(h).count == 2 })
            let logged = try ends(h)
            #expect(Set(logged.map(\.0)) == ["claude-code", "codex"])
            #expect(logged.allSatisfy { $0.1 == MCPConnectionEnd.serverOff.act }, "\(logged)")
        }
    }

    /// The library's closing road (a lock — her report's 3–4 AM case — or
    /// opening another library): the line is written BEFORE the store closes,
    /// by the app's lock road, and the hang-up that follows never says it
    /// again.
    @Test func theLibraryClosingIsSaidBeforeTheStoreGoesAndNeverTwice() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            _ = try await h.connect(as: "claude-code")
            #expect(try await h.eventually { h.host.connectedClientNames == ["claude-code"] })
            try h.host.recordConnectionEnds(.libraryClosed)
            #expect(try ends(h).map(\.1) == [MCPConnectionEnd.libraryClosed.act], "said at once, while the store is open")
            h.host.stop(ending: .libraryClosed)
            #expect(try await h.eventually { h.host.connectedClientNames.isEmpty })
            try await Task.sleep(for: .milliseconds(200))
            let after = try ends(h)
            #expect(after.count == 1, "the hang-up never says it twice: \(after)")
        }
    }

    /// A message past the session's cap is answered and closed (VX-184 U1) —
    /// and its end says so.
    @Test func aMessageOverTheCapEndsTheConnectionAndSaysSo() throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let socket = try RawSocket(h, timeout: 30)
        defer { socket.close() }
        socket.send(preamble: try h.setupKey(for: "big-sender"), initialize("big-sender"))
        _ = try #require(socket.nextResponse(), "initialized")
        socket.send(#"{"jsonrpc":"2.0","method":"notifications/initialized"}"#)
        let pad = String(repeating: "a", count: MCPSocketTransport.lineCap + 1)
        let bytes = Data((#"{"jsonrpc":"2.0","id":8,"method":"tools/call","params":{"name":"list_books","arguments":{"pad":""#
            + pad + #""}}}"# + "\n").utf8)
        Thread { _ = MCPShim.writeAll(socket.fd, bytes) }.start()
        _ = socket.nextResponse()
        #expect(socket.isHungUp())
        var logged: [(String, String)] = []
        for _ in 0..<200 {
            logged = try ends(h)
            if !logged.isEmpty { break }
            Thread.sleep(forTimeInterval: 0.01)
        }
        #expect(logged.map(\.0) == ["big-sender"] && logged.map(\.1) == [MCPConnectionEnd.overLimit.act], "\(logged)")
    }

    // MARK: - Guards: only a connection that named itself has an end to say

    /// A bare shim (no setup key — refused at the door) and a connection that
    /// hangs up before its `initialize` leave no end line: the first is the
    /// setup-key row's to say, the second is nobody.
    @Test func aConnectionThatNeverNamedItselfLeavesNoEndLine() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let (bare, _) = try h.rawOpen(as: "no-key", presenting: nil)
        close(bare)
        let silent = try RawSocket(h)
        silent.close()
        try await Task.sleep(for: .milliseconds(300))
        let logged = try ends(h)
        #expect(logged.isEmpty, "\(logged)")
    }

    /// The acts are their own family: a client's `list_my_activity` never lists
    /// them (they are not its tools — `MCPOwnActivity`'s rule for every
    /// connection row), and none is a catalog tool's name.
    @Test func theEndActsAreNoClientsActs() {
        let tools = Set(MCPToolCatalog.all.map(\.name))
        for end in MCPConnectionEnd.allCases {
            #expect(!tools.contains(end.act))
            #expect(!MCPOwnActivity.listedActs(includeReads: true).contains(end.act))
            #expect(MCPConnectionEnd(act: end.act) == end)
        }
    }
}
