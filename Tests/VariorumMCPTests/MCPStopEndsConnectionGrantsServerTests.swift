import Darwin
import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-400 (the VX-771 run, batch 4 — `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`,
// BATCH 4 RECORD): "until it disconnects" ends at the client's last connection's
// close OR THE SERVER'S STOP (MCPSpec; R-13n-4). The app's door stops its host and
// lets it go in the same breath (`MCPDoor.stopServer`), so every session a door
// stop ends finishes on the serve task's host-gone arm — which wrote the session's
// end line (VX-348 U5's fix leg) but never ended its client's while-connected
// grants: they stayed live until the NEXT start's sweep, listed in Settings ▸ MCP
// ▸ Shared with AI while the server was off. The harness holds its host strongly,
// so every older stop pin took the live-host arm and stayed green.

private func tempDirectory(_ prefix: String) -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("\(prefix)-\(UUID().uuidString.prefix(8))", isDirectory: true)
}

/// A raw client on `directory`'s socket that NAMES ITSELF (its setup key's
/// preamble, then an `initialize` as `name`, the answer read under a receive
/// bound — `HarnessDeadline.seconds`, the harness's own, O-7). The caller closes the descriptor.
/// VX-850: the read runs off the pool (`HarnessWait`); the task-local bound is
/// read here, before the hop (a plain thread sees none).
private func namedClient(_ directory: URL, key: String, as name: String) async throws -> Int32 {
    let seconds = Int(HarnessDeadline.seconds.rounded(.up))
    return try await HarnessWait.offPoolThrowing {
        try namedClientBlocking(directory, key: key, as: name, receiveSeconds: seconds)
    }
}

private func namedClientBlocking(_ directory: URL, key: String, as name: String, receiveSeconds: Int) throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw HarnessFailure("could not connect as \(name)")
    }
    var timeout = timeval(tv_sec: receiveSeconds, tv_usec: 0)
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    var opening = MCPPreamble.line(key: key)
    let initialize = #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"#
    opening.append(Data((initialize + "\n").utf8))
    _ = MCPShim.writeAll(fd, opening)
    guard !MCPShim.readFirstLine(fd, limit: 1 << 20).isEmpty else {
        close(fd)
        throw HarnessFailure("\(name) got no answer to its initialize")
    }
    return fd
}

/// The server hung this connection up: reading reaches EOF within the receive bound.
private func reachesEOF(_ fd: Int32) async -> Bool {
    await HarnessWait.offPool {   // VX-850: off the pool
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            let count = read(fd, &buffer, buffer.count)
            if count == 0 { return true }
            if count < 0 { return false }
        }
    }
}

/// The grant's revocation stamp, read fresh (nil = still live).
private func revokedAt(_ h: ServerHarness, _ grantID: String) throws -> String? {
    try h.database.read { try Queries.mcpGrant($0, id: grantID) }?.revokedAt
}

/// Polls up to 3 s — long past any session's own end, short of any restart.
private func becomesRevoked(_ h: ServerHarness, _ grantID: String) async throws -> Bool {
    for _ in 0..<300 {
        if try revokedAt(h, grantID) != nil { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return try revokedAt(h, grantID) != nil
}

/// The door's three stop roads, each exactly as `MCPDoor` runs it: the host
/// stopped, then let go at once.
enum DoorStopRoad: String, CaseIterable, Sendable, CustomTestStringConvertible {
    /// Her switch OFF — `reconcileServer` → `stopServer(ending: .serverOff)`.
    case switchOff
    /// The library locking — the lock road says each end first, while the store
    /// is open (`recordLibraryClosing`), then `detach()` → `stop(.libraryClosed)`.
    case libraryLocks
    /// The app quitting — `quit()` → `stopWithTheProcess()` (no end line, P-VX394-5).
    case appQuits

    var testDescription: String { rawValue }

    func stop(_ host: MCPServerHost) throws {
        switch self {
        case .switchOff: host.stop(ending: .serverOff)
        case .libraryLocks:
            try host.recordConnectionEnds(.libraryClosed)
            host.stop(ending: .libraryClosed)
        case .appQuits: host.stopWithTheProcess()
        }
    }
}

@Suite("VX-400 — a server stop ends its clients' until-disconnect grants", .serialized)
struct MCPStopEndsConnectionGrantsServerTests {
    /// **RED ON OLD:** the door's stop let its host go, its session ended on the
    /// host-gone arm, and the client's while-connected grant stayed live with the
    /// server stopped — nothing restarted, nothing swept. Now it is revoked by
    /// the stop's own end of the connection, before any restart. The client's
    /// standing ("always") grant and its unspent once grant stay as they were.
    @Test(arguments: DoorStopRoad.allCases)
    func aDoorStopThatLetsGoOfItsHostEndsTheClientsUntilDisconnectGrants(_ road: DoorStopRoad) async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let directory = tempDirectory("vx400")
        defer { try? FileManager.default.removeItem(at: directory) }
        var host: MCPServerHost? = MCPServerHost(
            database: h.database, operations: h.operations, directory: directory, version: "test",
            executor: SeededExecutor(operations: h.writeOperations))
        weak var released = host
        try host?.start()
        let fd = try await namedClient(directory, key: try h.setupKey(for: "claude-code"), as: "claude-code")
        defer { close(fd) }
        let clientID = try h.client("claude-code").id
        let (first, second) = try await h.within {
            (try h.operations.createPost(title: "a note"), try h.operations.createPost(title: "another note"))
        }
        let whileConnected = try #require(try h.approve(
            "claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .connection)))
        let always = try h.operations.grantMCPAccess(
            clientID, .init(rung: .read, scopeKind: .note, scopeID: first.id, duration: .always))
        let once = try h.operations.grantMCPAccess(
            clientID, .init(rung: .read, scopeKind: .note, scopeID: second.id, duration: .once))
        let namedBefore = host?.connectedClientNames ?? []
        #expect(namedBefore == ["claude-code"], "the connection named itself")
        let liveBefore = try revokedAt(h, whileConnected) == nil
        #expect(liveBefore, "the until-disconnect grant is live while the client is connected")

        // The door's road: stop, then let go — and nothing starts again.
        if let host { try road.stop(host) }
        host = nil
        let hostGone = released == nil
        #expect(hostGone, "the host is gone before its session finishes ending — the door's road")
        let ended = await reachesEOF(fd)
        #expect(ended, "the connection ends with the server")

        let dead = try await becomesRevoked(h, whileConnected)
        #expect(dead, "\(road): the stop ended the connection, so its until-disconnect grant ends with it — before any restart")
        let alwaysStands = try revokedAt(h, always) == nil
        #expect(alwaysStands, "\(road): an always grant outlives every stop")
        let onceStands = try revokedAt(h, once) == nil
        #expect(onceStands, "\(road): an unspent once grant is one act's permission, never a connection's")
        let socketGone = !FileManager.default.fileExists(atPath: MCPSocketRoad.socketPath(directory: directory))
        #expect(socketGone, "\(road): the server stayed stopped — no restart swept anything")
    }

    /// GUARD (green on both sides): a stop whose host is still held (the
    /// harness's posture — the live-host arm, `ended`) ended the grants before
    /// and still does.
    @Test func aStopWhoseHostIsStillHeldEndsThemToo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let fd = try await namedClient(h.directory, key: try h.setupKey(for: "claude-code"), as: "claude-code")
        defer { close(fd) }
        let whileConnected = try #require(try h.approve(
            "claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .connection)))
        h.host.stop(ending: .serverOff)
        let ended = await reachesEOF(fd)
        #expect(ended)
        let dead = try await becomesRevoked(h, whileConnected)
        #expect(dead, "the live-host arm ends the client's until-disconnect grants at its last connection")
    }

    /// GUARD (green on both sides): a connection that never named itself — a
    /// BARE shim declaring the client's name, refused at the key — ends none of
    /// that client's grants when the server it reached stops and is let go; the
    /// client's own connection (on another server) keeps its grant.
    @Test func aConnectionThatNeverNamedItselfEndsNoGrants() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let named = try await namedClient(h.directory, key: try h.setupKey(for: "claude-code"), as: "claude-code")
        defer { close(named) }
        _ = try h.approve("claude-code", nil)
        let directory = tempDirectory("vx400")
        defer { try? FileManager.default.removeItem(at: directory) }
        var host: MCPServerHost? = MCPServerHost(
            database: h.database, operations: h.operations, directory: directory, version: "test",
            executor: SeededExecutor(operations: h.writeOperations))
        try host?.start()  // its start sweeps — so the grant is minted after it
        let whileConnected = try h.operations.grantMCPAccess(
            try h.client("claude-code").id,
            .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .connection))
        let bare = try await bareClient(directory, declaring: "claude-code")
        defer { close(bare) }
        host?.stop(ending: .serverOff)
        host = nil
        let bareEnded = await reachesEOF(bare)
        #expect(bareEnded)
        try await Task.sleep(for: .milliseconds(400))
        let stands = try revokedAt(h, whileConnected) == nil
        #expect(stands, "a bare shim's end under the client's declared name is no connection of the client's")
    }
}

/// A BARE shim's connection (no setup key) declaring `name`: refused at the key,
/// its refusal read. The caller closes the descriptor.
private func bareClient(_ directory: URL, declaring name: String) async throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw HarnessFailure("could not connect")
    }
    var timeout = timeval(tv_sec: Int(HarnessDeadline.seconds.rounded(.up)), tv_usec: 0)
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    let initialize = #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"#
    _ = MCPShim.writeAll(fd, Data((initialize + "\n").utf8))
    _ = await HarnessWait.offPool { MCPShim.readFirstLine(fd, limit: 1 << 20) }   // VX-850: off the pool
    return fd
}
