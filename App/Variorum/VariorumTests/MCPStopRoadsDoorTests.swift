//
//  MCPStopRoadsDoorTests.swift
//  VariorumTests
//
//  VX-394 — THE STOP ROADS, swept (VX-548 batch 2b; the run record
//  `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 2b RECORD — the
//  sweep table). The app's half: every road that closes the open library says
//  each live connection's end ONCE, through the teardown production wires
//  (`macLockTeardown` — `VariorumApp`'s `bootstrap.onWillLock`), and the pane
//  reads "on · starts when the library is open" — never "running" — while the
//  library is locked; the quit says nothing (P-VX394-5). The host's half is
//  `MCPStopRoadsServerTests` (headless).
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
private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
    for _ in 0..<500 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// A raw client on the door's socket that names itself (its setup key's preamble,
/// then an `initialize` as `name`); returns once the server answered. The caller
/// closes the descriptor.
private func connect(_ directory: URL, as name: String, key: String) throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw CocoaError(.fileNoSuchFile)
    }
    var timeout = timeval(tv_sec: 5, tv_usec: 0)
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
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
    guard !MCPShim.readFirstLine(fd, limit: 1 << 20).isEmpty else {
        close(fd)
        throw CocoaError(.fileReadUnknown)
    }
    return fd
}

/// The server hung this connection up: reading reaches EOF within the 5 s bound.
private func reachesEOF(_ fd: Int32) -> Bool {
    var buffer = [UInt8](repeating: 0, count: 4096)
    while true {
        let count = read(fd, &buffer, buffer.count)
        if count == 0 { return true }
        if count < 0 { return false }
    }
}

/// The connection-end acts in the log, oldest first, as "client act".
private func endLines(_ db: AppDatabase) async throws -> [String] {
    let acts = Set(MCPConnectionEnd.allCases.map(\.act))
    return try await db.read { try Queries.mcpActivity($0) }
        .reversed()
        .filter { acts.contains($0.act) }
        .map { "\($0.clientName) \($0.act)" }
}

private func tempDirectory() -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("vstop-\(UUID().uuidString.prefix(8))", isDirectory: true)
}

/// A door whose hosts serve on `directory` — each host's operations bound to the
/// store it is handed (the app's makes `Operations()` in the ambient store; a
/// test bootstrap installs no ambient store).
@MainActor
private func makeDoor(serving directory: URL) -> MCPDoor {
    MCPDoor(serverAllowed: true) { database, executor in
        let operations = withDependencies { $0.database = database } operation: { Operations() }
        return MCPServerHost(
            database: database, operations: operations, directory: directory, version: "test", executor: executor)
    }
}

@MainActor
@Suite("VX-394 — the stop roads, swept: the app's half (VX-548 batch 2b)", .serialized)
struct MCPStopRoadsDoorTests {
    /// **EVERY ROAD THAT CLOSES THE LIBRARY** — a re-keying reopen (Use Castle…, the
    /// crossings' seam every re-keying act shares), Lock Library Now (⌃⌘L, the File
    /// menu and Settings ▸ Protection all call `lock()`), the idle dial, and sleep /
    /// screen lock (one monitor road) — through the teardown PRODUCTION wires
    /// (`macLockTeardown`, a real door and host, a real Castle library on the planted
    /// road): each says its connection's end exactly ONCE ("the library locked or
    /// closed"), hangs the connection up, and while the library is locked the pane's
    /// status reads "on · starts when the library is open" — never "running"; the
    /// unlock's ready starts the server again. PINNED GREEN (the sweep's lock cells:
    /// the road was right; this pins the composition no test reached).
    @Test func everyRoadThatClosesTheLibrarySaysEachConnectionsEndOnceThroughTheProductionTeardown() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (bootstrap, words) = try await LockWorld.readyInStandard(road)
            let directory = tempDirectory()
            defer { try? FileManager.default.removeItem(at: directory) }
            let door = makeDoor(serving: directory)
            defer { door.detach() }
            guard case .ready(let first) = bootstrap.state else {
                Issue.record("not ready: \(bootstrap.state)")
                return
            }
            // The library's one ambient view — the SAME across every reopen (the binding adopts each fresh pool).
            let library = first.database
            // The switch ON and one setup key, through the library's own operations (never the session's runner — a
            // test bootstrap installs no ambient store).
            let operations = withDependencies { $0.database = library } operation: { Operations() }
            try operations.setMCPSwitch(.server, on: true)
            let key = try operations.mintMCPSetupKey(copiedFor: "claude-code")

            /// What the window's `.task` does at every ready: the door attached to the session, the lock teardown
            /// wired exactly as `VariorumApp` wires it; then a client connected that names itself.
            @MainActor func readyWithAClient() async throws -> Int32 {
                guard case .ready(let session) = bootstrap.state else { throw CocoaError(.coderInvalidValue) }
                door.attach(session: session)
                bootstrap.onWillLock = macLockTeardown(session: session, door: door) {}
                #expect(try await settle { door.serverState == .running }, "the ready starts the server")
                return try connect(directory, as: "claude-code", key: key)
            }
            /// The library is closed: the connection was hung up and the pane says so honestly.
            @MainActor func closedHonestly(_ fd: Int32, _ road: String) {
                #expect(reachesEOF(fd), "\(road): the connection is hung up")
                close(fd)
                #expect(door.serverState == .waitingForLibrary, "\(road): \(door.serverState)")
                #expect(MCPPaneCopy.status(door.serverState) == "on \u{00B7} starts when the library is open",
                        "\(road): never \"running\" while the library is closed")
            }

            // 1. A RE-KEYING REOPEN — Use Castle… (the crossings' seam: the teardown, the pool closed, the act, the reopen).
            var fd = try await readyWithAClient()
            let crossings = try #require(bootstrap.roadCrossings)
            await crossings.refresh()
            crossings.open(.useCastle)
            let confirm = try #require(crossings.confirm)
            confirm.gate = .alwaysAsk
            await confirm.submit(
                passphrase: LockWorld.passphrase, again: LockWorld.passphrase, words: words.joined(separator: " "))
            #expect(crossings.confirm == nil, "the crossing landed: \(confirm.refusal ?? "-")")
            closedHonestly(fd, "the crossing")
            guard case .ready = bootstrap.state, bootstrap.roadSession?.library.record?.mode == .castle else {
                Issue.record("reopened in Castle: \(bootstrap.state)")
                return
            }
            #expect(try await endLines(library) == ["claude-code disconnect_library_closed"])

            // 2. LOCK LIBRARY NOW.
            fd = try await readyWithAClient()
            await bootstrap.lock()
            _ = try LockWorld.lobby(bootstrap)
            closedHonestly(fd, "Lock Library Now")
            try await LockWorld.unlock(bootstrap)

            // 3. THE IDLE DIAL (ten minutes away by default).
            fd = try await readyWithAClient()
            let now = Date()
            bootstrap.protection.noteActivity(now: now.addingTimeInterval(-11 * 60))
            await bootstrap.protection.relockIfIdle(now: now)
            _ = try LockWorld.lobby(bootstrap)
            closedHonestly(fd, "the idle dial")
            try await LockWorld.unlock(bootstrap)

            // 4. SLEEP / SCREEN LOCK (one monitor road — Castle always locks on both).
            fd = try await readyWithAClient()
            await bootstrap.protection.relockIfPolicySays()
            _ = try LockWorld.lobby(bootstrap)
            closedHonestly(fd, "sleep or screen lock")
            try await LockWorld.unlock(bootstrap)

            // Four roads, four connections, four lines — each said once, before its store closed.
            #expect(try await endLines(library) == Array(repeating: "claude-code disconnect_library_closed", count: 4))
            guard case .ready(let last) = bootstrap.state else {
                Issue.record("unlocked: \(bootstrap.state)")
                return
            }
            door.attach(session: last)
            #expect(try await settle { door.serverState == .running }, "unlocked: the server runs again")
        }
    }

    /// **THE QUIT** (P-VX394-5 — "a QUIT logs nothing"): the door's quit road
    /// (`applicationWillTerminate` → `quit()`) stops the server and hangs every
    /// connection up with NO end line. RED ON OLD: the quit's road was `detach()`,
    /// whose stop says "the library locked or closed" through each connection's own
    /// end — whenever that end beat the process's exit (the headless red leg,
    /// `MCPStopRoadsServerTests.aQuitSaysNothingForAConnectionItEnds`, logged exactly
    /// that through the old road).
    @Test func theQuitRoadStopsTheServerAndSaysNothing() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 548))
        } operation: { @MainActor in
            let directory = tempDirectory()
            defer { try? FileManager.default.removeItem(at: directory) }
            let session = AppSession(database: db)
            let door = makeDoor(serving: directory)
            door.attach(session: session)
            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            let key = try Operations().mintMCPSetupKey(copiedFor: "claude-code")
            let fd = try connect(directory, as: "claude-code", key: key)
            defer { close(fd) }

            door.quit()
            #expect(reachesEOF(fd), "the connection ends with the server")
            #expect(door.serverState != .running)
            try await Task.sleep(for: .milliseconds(400))
            #expect(try await endLines(db).isEmpty, "a quit says nothing (P-VX394-5)")
        }
    }

    /// GUARD (green on both sides): a plain `detach()` with no lock road before it
    /// (a re-attach to another session) still says "the library locked or closed",
    /// once — only the quit forgoes the line.
    @Test func aDetachWithNoLockRoadBeforeItStillSaysTheLibraryClosedOnce() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 548))
        } operation: { @MainActor in
            let directory = tempDirectory()
            defer { try? FileManager.default.removeItem(at: directory) }
            let session = AppSession(database: db)
            let door = makeDoor(serving: directory)
            door.attach(session: session)
            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            let key = try Operations().mintMCPSetupKey(copiedFor: "claude-code")
            let fd = try connect(directory, as: "claude-code", key: key)
            defer { close(fd) }

            door.detach()
            #expect(reachesEOF(fd))
            var lines: [String] = []
            for _ in 0..<300 {
                lines = try await endLines(db)
                if !lines.isEmpty { break }
                try await Task.sleep(for: .milliseconds(10))
            }
            try await Task.sleep(for: .milliseconds(200))
            #expect(try await endLines(db) == ["claude-code disconnect_library_closed"])
        }
    }
}
