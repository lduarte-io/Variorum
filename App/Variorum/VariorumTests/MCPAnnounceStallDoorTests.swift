//
//  MCPAnnounceStallDoorTests.swift
//  VariorumTests
//
//  VX-944 (the VX-981 run, batch 3 — the record
//  `notes/plans/fixes/vx-981-mcp-door-followups.md`, BATCH 3 — RECORD; the VX-940
//  ladder's F-R1-2) — THE UNLOCK NEVER WAITS ON A CLIENT THAT STOPPED READING: the
//  door's half. `MCPDoor.resumeSuspended` awaits the host's `resume(executor:)`, and
//  only on its return does the pane's state run (`serverState`, `refreshConnected`,
//  `reconcileServer`). The old resume announced to each session IN SERIES, and an
//  announce to a connection whose writer still holds a big frame waits until that
//  client reads — so one stalled client froze the pane's face at its locked-time
//  `.waitingForLibrary`. The host's half is `MCPAnnounceStallServerTests` (headless).
//
//  RED ON OLD (the named revert — `Sources/VariorumMCP/MCPSession.swift` and
//  `Sources/VariorumMCP/MCPServerHost.swift` at the scaffold): the server state
//  never reads running while A stalls.
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
private func settle(_ seconds: Double = 10, _ condition: @MainActor () -> Bool) async throws -> Bool {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// A raw client on the door's socket that names itself (its setup key's preamble,
/// then an `initialize` as `name`); returns once the server answered. Blocking —
/// called off the main actor. The caller closes the descriptor.
private func connectBlocking(_ directory: URL, as name: String, key: String) throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw CocoaError(.fileNoSuchFile)
    }
    var timeout = timeval(tv_sec: 10, tv_usec: 0)
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    var bytes = MCPPreamble.line(key: key)
    bytes.append(Data((#"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"# + "\n").utf8))
    writeAll(fd, bytes)
    guard !MCPShim.readFirstLine(fd, limit: 1 << 20).isEmpty else {
        close(fd)
        throw CocoaError(.fileReadUnknown)
    }
    return fd
}

/// Write every byte (blocking — called off the main actor).
@discardableResult
private func writeAll(_ fd: Int32, _ data: Data) -> Bool {
    data.withUnsafeBytes { raw in
        var offset = 0
        while offset < raw.count {
            let written = Darwin.write(fd, raw.baseAddress! + offset, raw.count - offset)
            if written < 0, errno == EINTR { continue }
            guard written > 0 else { return false }
            offset += written
        }
        return true
    }
}

/// Bytes waiting unread at `fd` (`SO_NREAD`).
private func unreadBytes(_ fd: Int32) -> Int {
    var value: Int32 = 0
    var size = socklen_t(MemoryLayout<Int32>.size)
    return getsockopt(fd, SOL_SOCKET, SO_NREAD, &value, &size) == 0 ? Int(value) : 0
}

/// Read whatever `fd` holds until a read times out (its `SO_RCVTIMEO`) — the
/// stalled client let go at the end, so nothing waits on it past the pin.
private func drain(_ fd: Int32) {
    var timeout = timeval(tv_sec: 1, tv_usec: 0)
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    var sink = [UInt8](repeating: 0, count: 64 * 1024)
    while read(fd, &sink, sink.count) > 0 {}
}

@MainActor
private func makeDoor(serving directory: URL) -> MCPDoor {
    MCPDoor(serverAllowed: true) { database, executor in
        let operations = withDependencies { $0.database = database } operation: { Operations() }
        return MCPServerHost(
            database: database, operations: operations, directory: directory, version: "test", executor: executor)
    }
}

@MainActor
@Suite("VX-944 — the unlock never waits on a client that stopped reading: the door's half", .serialized)
struct MCPAnnounceStallDoorTests {
    /// **The lock, then the same library back, while client A has stopped
    /// reading** with a 200 KB answer pending (its `ping` echoed a 200 KB id):
    /// the door's resume returns and the pane reads running again — the same
    /// connections, both still the clients'.
    @Test func theUnlockRunsThePanesRefreshWhileAClientHasStoppedReading() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("vstall-\(UUID().uuidString.prefix(8))", isDirectory: true)
        let store = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("vstall-\(UUID().uuidString.prefix(8)).sqlite")
        defer {
            try? FileManager.default.removeItem(at: directory)
            for suffix in ["", "-wal", "-shm"] { try? FileManager.default.removeItem(atPath: store.path + suffix) }
        }
        let bound = try AppDatabase.onDisk(url: store, key: nil).asRebindable()
        let db = bound.view
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let door = makeDoor(serving: directory)
            defer { door.detach() }
            door.attach(session: AppSession(database: db))
            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            let operations = Operations()
            let stalledKey = try operations.mintMCPSetupKey(copiedFor: "claude-code")
            let readerKey = try operations.mintMCPSetupKey(copiedFor: "codex")
            let stalled = try await Task.detached { try connectBlocking(directory, as: "claude-code", key: stalledKey) }.value
            defer { close(stalled) }
            let reader = try await Task.detached { try connectBlocking(directory, as: "codex", key: readerKey) }.value
            defer { close(reader) }
            for name in ["claude-code", "codex"] {
                let client = try #require(try await db.read { try Queries.mcpClient($0, name: name) })
                _ = try operations.approveMCPClient(client.id, granting: nil)
            }
            #expect(try await settle { door.connected == ["claude-code", "codex"] })

            // A says it is ready, then pings with a 200 KB id and never reads.
            let initialized = #"{"jsonrpc":"2.0","method":"notifications/initialized"}"# + "\n"
            let ping = #"{"jsonrpc":"2.0","id":""# + String(repeating: "s", count: 200_000) + #"","method":"ping"}"# + "\n"
            _ = await Task.detached { writeAll(reader, Data(initialized.utf8)) }.value
            _ = await Task.detached { writeAll(stalled, Data((initialized + ping).utf8)) }.value
            #expect(try await settle { unreadBytes(stalled) >= 4_096 },
                    "premise: A's 200 KB answer has begun, so its writer waits on A")

            // The lock: the host suspended, the session's faces let go.
            let teardown = macLockTeardown(session: AppSession(database: db), door: door, road: { .lock }) {}
            await teardown()
            #expect(door.serverState == .waitingForLibrary, "premise: the locked-time face")
            bound.binding.lock()
            try bound.binding.adopt(try AppDatabase.onDisk(url: store, key: nil))  // the SAME library back
            door.attach(session: AppSession(database: db))

            let running = try await settle { door.serverState == .running }
            #expect(running, "the unlock's resume returned and the pane's state ran while A has stopped reading")
            #expect(door.connected == ["claude-code", "codex"], "the same connections, still the clients'")

            // Let A go, so nothing waits on it past the pin (and an old tree's stuck resume ends).
            await Task.detached { drain(stalled) }.value
            if !running { _ = try await settle { door.serverState == .running } }
        }
    }
}
