//
//  MCPConnectionNamingDoorTests.swift
//  VariorumTests
//
//  VX-605 — THE APP'S HALF (the VX-620 run, batch 2; the record
//  `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`, BATCH 2 RECORD).
//  Settings ▸ MCP ▸ Clients reads "connected now" for a name in the door's
//  connected set (`MCPClientRow` — `door.connected.contains(name)`), else "last
//  seen …"; the door re-reads that set only when its host signals. The headless
//  pin is `MCPConnectionNamingSignalServerTests` (red on the pre-fix tree and
//  under the behavioural revert); this one drives the REAL door, host and socket.
//
//  The choreography is the walker's, and it is what makes this pin honest: the
//  reconnect REGISTERS first — its socket opened with not a word sent — and the
//  door's main-actor hop for that signal lands while the connection has no name;
//  only then does it name itself. (A connect that blocks the main actor through
//  its whole handshake would let that one hop land after the naming and read the
//  name — green on the old code, a hollow pin.)
//

import Darwin
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
import VariorumMCP
import VariorumMCPSocket
@testable import Variorum

@MainActor
private func withDoorWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 605))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
    for _ in 0..<300 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// A socket on the door's server with NOT A WORD sent: the host accepts and
/// registers it (its first signal). Off the main actor. The caller closes it.
private nonisolated func openSilently(_ directory: URL) throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw CocoaError(.fileNoSuchFile)
    }
    var timeout = timeval(tv_sec: 5, tv_usec: 0)
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    return fd
}

/// The connection names itself: its setup key's preamble, then an
/// `initialize` as `name`; returns once the server has answered. Off the main
/// actor.
private nonisolated func nameItself(_ fd: Int32, as name: String, key: String) {
    var bytes = MCPPreamble.line(key: key)
    bytes.append(Data((#"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"# + "\n").utf8))
    bytes.withUnsafeBytes { raw in
        var offset = 0
        while offset < raw.count {
            let written = Darwin.write(fd, raw.baseAddress! + offset, raw.count - offset)
            guard written > 0 else { return }
            offset += written
        }
    }
    _ = MCPShim.readFirstLine(fd, limit: 1 << 20)
}

/// The door's own server, in a temp directory, its host kept for the pins.
@MainActor
private final class DoorServer {
    /// Every host the door made, in order (the last is the one serving).
    final class Hosts { var all: [MCPServerHost] = [] }

    let directory: URL
    let operations: Operations
    let made: Hosts
    let door: MCPDoor

    var hosts: [MCPServerHost] { made.all }

    init() {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("vname-\(UUID().uuidString.prefix(8))", isDirectory: true)
        let operations = Operations()
        let made = Hosts()
        self.directory = directory
        self.operations = operations
        self.made = made
        door = MCPDoor(serverAllowed: true) { database, executor in
            let host = MCPServerHost(
                database: database, operations: operations, directory: directory, version: "test",
                executor: executor)
            made.all.append(host)
            return host
        }
    }

    func cleanUp() { try? FileManager.default.removeItem(at: directory) }
}

@MainActor
@Suite("VX-605 — the Clients row reads connected now once a connection names itself (the app's half)", .serialized)
struct MCPConnectionNamingDoorTests {
    /// **RED ON OLD (the mechanism the headless pin proves red; this pin's run
    /// rides the stage):** her client reconnects under its bound key — the walk's
    /// road. The door heard it register (no name) and was never told it named
    /// itself, so its row read "last seen …" while the client was served.
    @Test func aReconnectUnderItsBoundKeyReadsConnectedNowOnceItNamesItself() async throws {
        try await withDoorWorld { (session: AppSession, db: AppDatabase) async throws in
            let server = DoorServer()
            defer { server.cleanUp() }
            let door = server.door
            door.attach(session: session)
            defer { door.detach() }
            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            let key = try server.operations.mintMCPSetupKey(copiedFor: "claude-code")
            let directory = server.directory

            // Her client's first connection: a request, then her approval —
            // heard through the grants observation (non-vacuity of the seam).
            let first = try await Task.detached { () throws -> Int32 in
                let fd = try openSilently(directory)
                nameItself(fd, as: "claude-code", key: key)
                return fd
            }.value
            let client = try #require(try await db.read { try Queries.mcpClient($0, name: "claude-code") })
            try server.operations.approveMCPClient(client.id, granting: nil)
            #expect(try await settle { door.connected == ["claude-code"] }, "an approved, named connection reads connected")
            close(first)
            #expect(try await settle { door.connected.isEmpty }, "its end is heard: last seen")
            try await Task.sleep(for: .milliseconds(300))

            // The reconnect (her /mcp after a lock): it registers, and the
            // door's hop for that signal lands while it has no name…
            let again = try await Task.detached { try openSilently(directory) }.value
            defer { close(again) }
            try await Task.sleep(for: .milliseconds(300))
            #expect(door.connected.isEmpty, "registered, not yet named: nobody is connected yet")
            // …then it names itself, under the same bound key.
            await Task.detached { nameItself(again, as: "claude-code", key: key) }.value
            #expect(server.hosts.last?.connectedClientNames == ["claude-code"], "non-vacuity: the host serves it named")
            #expect(try await settle { door.connected == ["claude-code"] },
                    "the Clients row reads “\(MCPPaneCopy.connectedNow)” once the connection names itself — never “last seen …” while served")
        }
    }

    /// GUARD (green on both sides — the discipline the fix relies on): a
    /// signal is only a signal. The door re-reads its CURRENT host on the main
    /// actor, and a stop drops the host there first, so a late signal from a
    /// host it stopped — a naming that raced the stop — never brings that host's
    /// names back.
    @Test func aStoppedHostsLateSignalNeverBringsItsNamesBack() async throws {
        try await withDoorWorld { (session: AppSession, db: AppDatabase) async throws in
            let server = DoorServer()
            defer { server.cleanUp() }
            let door = server.door
            door.attach(session: session)
            defer { door.detach() }
            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            let key = try server.operations.mintMCPSetupKey(copiedFor: "claude-code")
            let directory = server.directory
            let fd = try await Task.detached { () throws -> Int32 in
                let fd = try openSilently(directory)
                nameItself(fd, as: "claude-code", key: key)
                return fd
            }.value
            defer { close(fd) }
            let client = try #require(try await db.read { try Queries.mcpClient($0, name: "claude-code") })
            try server.operations.approveMCPClient(client.id, granting: nil)
            #expect(try await settle { door.connected == ["claude-code"] })
            let stopped = try #require(server.hosts.last)

            door.setEnabled(false)   // her switch: the host stops, the door lets it go
            #expect(try await settle { door.serverState == .off })
            #expect(door.connected.isEmpty, "a stop empties the set at once")
            stopped.onConnectionsChanged?()   // the stopped host's late signal
            try await Task.sleep(for: .milliseconds(200))
            #expect(door.connected.isEmpty, "a stopped host's signal reads nothing back")
        }
    }
}
