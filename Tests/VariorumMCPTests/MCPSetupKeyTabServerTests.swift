import Darwin
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-258 — KEYS TIED TO THEIR TAB, ON THE SOCKET ROAD (the run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — "VX-258"): a key
// copied from Claude Code's own tab re-binds `claude-code` with zero clicks and
// is served; an "Any MCP client" key under the same name waits — no tools, the
// request's sentence — until her Allow, when its tools arrive with no reconnect
// and the key it replaced hears its own sentence; her Don't allow leaves it
// reaching nothing and its next connection hears the one sentence; and a waiting
// connection never keeps the name's while-connected grants alive.

@Suite("VX-258 — keys tied to their tab, on the socket road", .serialized)
struct MCPSetupKeyTabServerTests {
    private func message(_ answer: [String: Any]) -> String? {
        (answer["error"] as? [String: Any])?["message"] as? String
    }

    private func note(_ h: ServerHarness) throws -> Container {
        let note = try h.operations.createPost(title: "her page")
        _ = try h.operations.newBlock(in: note.id, text: "the harbour at dawn", registeringUndo: false)
        return note
    }

    @Test func aTabCopyRebindsItsNameWithZeroClicks() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let page = try note(h)
            let real = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: page.id, duration: .always))
            let rerun = try h.operations.mintMCPSetupKey(copiedFor: "claude-code")
            let newer = try await h.connect(as: "claude-code", presenting: rerun)
            let read = try await newer.client.callTool(name: "read_note", arguments: ["note_id": .string(page.id)])
            #expect(read.isError != true && text(read).contains("the harbour at dawn"), "\(text(read))")
            #expect(try await h.database.read { try Queries.mcpRebindRequests($0) }.isEmpty, "nothing waits")
            await h.hangUp(real)
            await h.hangUp(newer)
        }
    }

    @Test func anAnyClientCopyWaitsThenHerAllowServesItWithNoReconnect() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let page = try note(h)
            let ownKey = try h.setupKey(for: "claude-code")
            let real = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: page.id, duration: .always))
            await h.hangUp(real)
            #expect(try await h.eventually { h.host.connectedClientNames.isEmpty })

            let anyKey = try h.operations.mintMCPSetupKey()
            let waiting = try await h.connect(as: "claude-code", presenting: anyKey)
            let heard = LockIsolated(0)
            _ = await waiting.client.onNotification(ToolListChangedNotification.self) { _ in heard.withValue { $0 += 1 } }
            #expect(try await waiting.client.listTools().tools.isEmpty)
            let refused = try await waiting.client.callTool(name: "read_note", arguments: ["note_id": .string(page.id)])
            #expect(refused.isError == true && text(refused) == MCPRefusalCopy.words(.clientPending, .note))
            let unknown = try await waiting.client.callTool(name: "no_such_tool", arguments: [:])
            #expect(text(unknown) == "Unknown tool: no_such_tool.", "as for anyone")
            #expect(h.host.connectedClientNames.isEmpty, "a waiting connection is not the name's")

            let request = try #require(try await h.database.read { try Queries.mcpRebindRequests($0) }.first)
            #expect(request.clientName == "claude-code" && request.version == "1.0", "what she reads: the declared version")
            _ = try h.operations.allowMCPRebind(request.id)
            #expect(try await h.eventually { heard.value > 0 }, "told its tools changed — no reconnect")
            #expect(try await waiting.client.listTools().tools.contains { $0.name == "read_note" })
            let served = try await waiting.client.callTool(name: "read_note", arguments: ["note_id": .string(page.id)])
            #expect(served.isError != true && text(served).contains("the harbour at dawn"), "\(text(served))")
            #expect(try await h.eventually { h.host.connectedClientNames == ["claude-code"] })

            let (fd, replaced) = try h.rawOpen(as: "claude-code", presenting: ownKey, id: 4)
            close(fd)
            #expect(message(replaced) == MCPHandshake.replacedRefusal, "the key she replaced: its own sentence")
            await h.hangUp(waiting)
        }
    }

    @Test func herDontAllowLeavesItReachingNothingAndTheRealKeyServed() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let page = try note(h)
            let real = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: page.id, duration: .always))
            let anyKey = try h.operations.mintMCPSetupKey()
            let waiting = try await h.connect(as: "claude-code", presenting: anyKey)
            let request = try #require(try await h.database.read { try Queries.mcpRebindRequests($0) }.first)
            _ = try h.operations.declineMCPRebind(request.id)
            #expect(try await waiting.client.listTools().tools.isEmpty, "still nothing")
            let (fd, again) = try h.rawOpen(as: "claude-code", presenting: anyKey, id: 5)
            close(fd)
            #expect(message(again) == MCPHandshake.refusal, "its next connection: the one sentence")
            let served = try await real.client.callTool(name: "read_note", arguments: ["note_id": .string(page.id)])
            #expect(served.isError != true, "the client she knows never noticed")
            await h.hangUp(waiting)
            await h.hangUp(real)
        }
    }

    /// While connected ends with the name's LAST real connection — a waiting
    /// one is not the name's, so it never holds the grant open.
    @Test func aWaitingConnectionNeverKeepsTheNamesWhileConnectedGrantsAlive() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "b", kind: .book)
            let real = try await h.connect(as: "claude-code")
            let grantID = try #require(try h.approve(
                "claude-code", .init(rung: .read, scopeKind: .book, scopeID: shared.id, duration: .connection)))
            let waiting = try await h.connect(as: "claude-code", presenting: try h.operations.mintMCPSetupKey())
            await h.hangUp(real)
            #expect(try await h.eventually {
                try h.database.read { try Queries.mcpGrant($0, id: grantID) }?.revokedAt != nil
            }, "the last REAL connection closed — while connected ends")
            await h.hangUp(waiting)
        }
    }
}
