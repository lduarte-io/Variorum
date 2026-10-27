import Darwin
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-605 — A LIVE NAMED CONNECTION READ "last seen …" (the VX-548 mid window's
// finding MID-2; the run record `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`,
// BATCH 2 RECORD). Settings ▸ MCP ▸ Clients reads "connected now" only for a
// name in the door's connected set, and the door re-reads that set ONLY when the
// host signals (`MCPServerHost.onConnectionsChanged` → `MCPDoor.refreshConnected`
// — a signal, never a decision, P-4). The host signalled when a connection
// REGISTERED — before it had read its `initialize`, so the read found no name —
// and the session set its name at `initialize` signalling nothing. A client
// reconnecting under its already-bound key (her /mcp after a lock) is admitted
// with no write the grants observation hears (`last_seen_at` is not in the
// fingerprint, and the observation removes duplicates), so nothing else came:
// the connection served calls while its row read "last seen 11 seconds ago",
// until some later event happened to re-read.
//
// The pins model the door exactly: at every signal, re-read
// `connectedClientNames`; the LAST read is what the Clients row shows.

/// The app's door reduced to its one reaction to the signal (`MCPDoor
/// .refreshConnected`): re-read the host's connected names. Every read is kept,
/// so a pin can ask what the row shows now (the last) and how it got there.
private final class DoorReads: @unchecked Sendable {
    private let reads = LockIsolated<[Set<String>]>([])

    func listen(to host: MCPServerHost) {
        host.onConnectionsChanged = { [weak host, reads] in
            guard let host else { return }
            let names = host.connectedClientNames
            reads.withValue { $0.append(names) }
        }
    }

    var all: [Set<String>] { reads.value }
    var last: Set<String>? { reads.value.last }
    func clear() { reads.setValue([]) }
}

@Suite("VX-605 — a connection is heard connected the moment it names itself", .serialized)
struct MCPConnectionNamingSignalServerTests {
    /// **RED ON OLD (the walker's repro):** her client reconnects under the key
    /// it is already bound to. The registration's signal reads it nameless; the
    /// naming signalled nothing, so the door's last read stayed empty and the
    /// row read "last seen …" while the client was served.
    @Test func aReconnectUnderItsBoundKeyIsHeardConnectedOnceItNamesItself() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let door = DoorReads()
        door.listen(to: h.host)
        try await h.within {
            // Her client, set up from its own tab and approved: its first
            // connection binds its key; the door hears it (non-vacuity of the model).
            let first = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            #expect(try await h.eventually { door.last == ["claude-code"] }, "a named, approved connection is heard")
            // The library locked, or the client restarted: the connection ends,
            // and its end is heard (the end's own signal — `ended`).
            await h.hangUp(first)
            #expect(try await h.eventually { door.last == [] }, "the end is heard: not connected")
            // Let any straggling signal of the first connection's life land
            // before the reconnect is watched alone.
            try await Task.sleep(for: .milliseconds(300))
            door.clear()

            // The reconnect: the same name, the same bound key (`.admit` — only
            // `last_seen_at` is written, which no grants signal hears).
            let again = try await h.connect(as: "claude-code")
            #expect(h.host.connectedClientNames == ["claude-code"], "non-vacuity: the connection named itself")
            #expect(door.all.first == [], "the registration's signal reads it nameless — the mechanism")
            #expect(try await h.eventually { door.last == ["claude-code"] },
                    "the door hears it connected once it names itself — never “last seen” while served: \(door.all)")
            // …and it is served, by the same connection.
            let served = try await again.client.callTool(name: "list_books", arguments: [:])
            #expect(served.isError != true, "\(text(served))")
            await h.hangUp(again)
            #expect(try await h.eventually { door.last == [] }, "its end is still heard")
        }
    }

    /// GUARD (green on both sides — VX-258): a connection whose setup WAITS for
    /// her OK names itself but is not the name's (`clientName` is nil while it
    /// waits), so no signal may read it connected — the fix signals the
    /// connected set, never the declared name. Her Allow is heard through the
    /// grants observation, as before.
    @Test func aConnectionWaitingForHerOKIsNeverHeardAsTheNamesUntilSheAllowsIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let door = DoorReads()
        door.listen(to: h.host)
        try await h.within {
            let real = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            await h.hangUp(real)
            #expect(try await h.eventually { door.last == [] })
            try await Task.sleep(for: .milliseconds(300))
            door.clear()

            // An "Any MCP client" copy under her approved name: it waits.
            let waiting = try await h.connect(as: "claude-code", presenting: try h.operations.mintMCPSetupKey())
            #expect(try await waiting.client.listTools().tools.isEmpty, "non-vacuity: it waits for her OK")
            try await Task.sleep(for: .milliseconds(200))
            #expect(door.all.allSatisfy { !$0.contains("claude-code") },
                    "a waiting connection is never heard as the name's: \(door.all)")

            let request = try #require(try await h.database.read { try Queries.mcpRebindRequests($0) }.first)
            _ = try h.operations.allowMCPRebind(request.id)
            #expect(try await h.eventually { door.last == ["claude-code"] }, "her Allow is heard: connected now")
            await h.hangUp(waiting)
        }
    }

    /// GUARD (green on both sides): a connection that never names itself (a
    /// bare shim, refused at its key) is never heard as anyone — only its
    /// registration and its end signal, each reading nobody.
    @Test func aConnectionRefusedAtItsKeyIsNeverHeardAsAnyone() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let door = DoorReads()
        door.listen(to: h.host)
        let (fd, _) = try h.rawOpen(as: "claude-code", presenting: nil)
        close(fd)
        #expect(try await h.eventually { door.all.count >= 2 }, "registered, then ended: \(door.all)")
        let reads = door.all
        #expect(reads.allSatisfy { $0.isEmpty }, "never heard as anyone: \(reads)")
    }
}
