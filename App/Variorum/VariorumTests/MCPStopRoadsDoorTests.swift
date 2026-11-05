//
//  MCPStopRoadsDoorTests.swift
//  VariorumTests
//
//  VX-394 — THE STOP ROADS, swept (VX-548 batch 2b; the run record
//  `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 2b RECORD — the
//  sweep table). The app's half: every road that closes the open library says
//  each live connection's end ONCE, through the teardown production wires
//  (`macLockTeardown` — `VariorumApp`'s `bootstrap.onWillLock`); the quit says
//  nothing (P-VX394-5). The host's half is `MCPStopRoadsServerTests` (headless).
//
//  VX-818 (the VX-809 run, batch 4 — her R-818; A-809-20/-21; the record
//  `notes/plans/fixes/vx-809-mcp-door-ergonomics.md` BATCH 4): THE LOCK IS NO
//  LONGER A STOP ROAD. The lock (Lock Library Now, the idle dial, sleep / screen
//  lock) and a re-keying reopen of the same library (P-809-13) keep every
//  connection — each call answers the locked sentence while the store is shut, and
//  the next ready serves the SAME connection; nothing ends, nothing is said. The
//  library CLOSING (adopt, swap — `.closing`), an unnamed road, her switch and the
//  quit stay TRUE STOPS, byte-unchanged. The host's half of the new posture is
//  `MCPLockPostureServerTests` (headless).
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

/// One `tools/call` on a raw connection (`initialized` sent first, once per
/// caller): the answer's text and whether it is an error, skipping any
/// notification the server sends between (a resume's `tools/list_changed`).
private func call(_ fd: Int32, id: Int, _ tool: String, initialize: Bool = false) -> (text: String, isError: Bool)? {
    var frames = ""
    if initialize { frames += #"{"jsonrpc":"2.0","method":"notifications/initialized"}"# + "\n" }
    frames += #"{"jsonrpc":"2.0","id":\#(id),"method":"tools/call","params":{"name":"\#(tool)","arguments":{}}}"# + "\n"
    let bytes = Array(frames.utf8)
    var offset = 0
    while offset < bytes.count {
        let written = bytes.withUnsafeBufferPointer { Darwin.write(fd, $0.baseAddress! + offset, bytes.count - offset) }
        guard written > 0 else { return nil }
        offset += written
    }
    for _ in 0..<16 {
        let line = MCPShim.readFirstLine(fd, limit: 1 << 20)
        guard !line.isEmpty else { return nil }
        guard let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any],
              (object["id"] as? Int) == id else { continue }
        let result = object["result"] as? [String: Any]
        let content = (result?["content"] as? [[String: Any]])?.compactMap { $0["text"] as? String }.joined() ?? ""
        return (content, (result?["isError"] as? Bool) ?? (object["error"] != nil))
    }
    return nil
}

/// Every line the server writes until it hangs up; the 0x1E-led close line's words.
private func closeWordsUntilEOF(_ fd: Int32) -> String? {
    var last: String?
    while true {
        let line = MCPShim.readFirstLine(fd, limit: 1 << 20)
        if line.isEmpty { return last }
        if line.first == 0x1E { last = String(decoding: line.dropFirst(), as: UTF8.self) }
    }
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
    /// **THE LOCK AND A RE-KEY KEEP THE CONNECTION** (VX-818 — A JUSTIFIED EDIT
    /// of VX-548 batch 2b's every-road pin, the ritual: the lock is no longer a
    /// stop road) — a re-keying reopen (Use Castle…, the crossings' seam every
    /// re-keying act shares), Lock Library Now (⌃⌘L, the File menu and Settings ▸
    /// Protection all call `lock()`), the idle dial, and sleep / screen lock (one
    /// monitor road) — through the teardown PRODUCTION wires (`macLockTeardown`
    /// reading the bootstrap's `willLockRoad`, a real door and host, a real Castle
    /// library on the planted road): ONE connection lives through all four — while
    /// a lock stands its call answers the locked sentence, and each next ready
    /// serves it again (no reconnect); nothing ends, so nothing is said. **RED ON
    /// OLD** (the named revert — every road taking the stop, `mcpServerSurvives`
    /// answering false): the crossing hung the connection up and said "the library
    /// locked or closed".
    @Test func theLockAndAReKeyKeepTheConnectionThroughTheProductionTeardown() async throws {
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
            /// wired exactly as `VariorumApp` wires it.
            @MainActor func ready() async throws {
                guard case .ready(let session) = bootstrap.state else { throw CocoaError(.coderInvalidValue) }
                door.attach(session: session)
                bootstrap.onWillLock = macLockTeardown(session: session, door: door, bootstrap: bootstrap) {}
                #expect(try await settle { door.serverState == .running }, "the ready serves")
            }
            try await ready()
            let fd = try connect(directory, as: "claude-code", key: key)
            defer { close(fd) }
            let clientID = try #require(try await library.read { try Queries.mcpClient($0, name: "claude-code") }).id
            _ = try operations.approveMCPClient(clientID, granting: nil)
            var id = 2
            /// The connection serves: an approved client's `list_my_activity` answers its rows.
            @MainActor func serves(_ road: String, initialize: Bool = false) {
                id += 1
                let answer = call(fd, id: id, "list_my_activity", initialize: initialize)
                #expect(answer?.isError == false, "\(road): served on the same connection — \(answer?.text ?? "no answer")")
            }
            serves("before any lock", initialize: true)

            // 1. A RE-KEYING REOPEN — Use Castle… (the crossings' seam: the teardown, the pool closed, the act, the reopen).
            let crossings = try #require(bootstrap.roadCrossings)
            await crossings.refresh()
            crossings.open(.useCastle)
            let confirm = try #require(crossings.confirm)
            confirm.gate = .alwaysAsk
            await confirm.submit(
                passphrase: LockWorld.passphrase, again: LockWorld.passphrase, words: words.joined(separator: " "))
            #expect(crossings.confirm == nil, "the crossing landed: \(confirm.refusal ?? "-")")
            guard case .ready = bootstrap.state, bootstrap.roadSession?.library.record?.mode == .castle else {
                Issue.record("reopened in Castle: \(bootstrap.state)")
                return
            }
            try await ready()
            serves("after the crossing (P-809-13)")

            /// A lock road: while it stands the call hears the locked sentence; the unlock's ready serves it again.
            @MainActor func keepsThrough(_ road: String, _ lock: () async -> Void) async throws {
                await lock()
                _ = try LockWorld.lobby(bootstrap)
                id += 1
                let locked = call(fd, id: id, "list_my_activity")
                #expect(locked?.text == "The library is locked \u{2014} ask again once it's unlocked.",
                        "\(road): \(locked?.text ?? "no answer — the connection was hung up")")
                #expect(locked?.isError == true)
                try await LockWorld.unlock(bootstrap)
                try await ready()
                serves("after \(road)")
            }
            // 2. LOCK LIBRARY NOW.
            try await keepsThrough("Lock Library Now") { await bootstrap.lock() }
            // 3. THE IDLE DIAL (ten minutes away by default).
            try await keepsThrough("the idle dial") {
                let now = Date()
                bootstrap.protection.noteActivity(now: now.addingTimeInterval(-11 * 60))
                await bootstrap.protection.relockIfIdle(now: now)
            }
            // 4. SLEEP / SCREEN LOCK (one monitor road — Castle always locks on both).
            try await keepsThrough("sleep or screen lock") { await bootstrap.protection.relockIfPolicySays() }

            // Four roads, one connection, nothing ended — so nothing said.
            #expect(try await endLines(library).isEmpty, "nothing ended")
        }
    }

    /// **A RE-KEY WHOSE RESUME LANDS IN ANOTHER LIBRARY ABANDONS** (VX-818 — the
    /// identity belt proven from the door): the re-key road suspends the host, and
    /// the store the next ready opens is NOT the one it suspended over (the grants
    /// store's fingerprint differs) — so the door never resumes it: the connection
    /// hears the closing road's close line and ends, and NOTHING is written to the
    /// library now open (no end line, no client row).
    @Test func aReKeyWhoseResumeLandsInAnotherLibraryAbandons() async throws {
        let directory = tempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let stores = (0..<2).map { _ in
            URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent("vstop-\(UUID().uuidString.prefix(8)).sqlite")
        }
        defer {
            for url in stores { for suffix in ["", "-wal", "-shm"] { try? FileManager.default.removeItem(atPath: url.path + suffix) } }
        }
        let bound = try AppDatabase.onDisk(url: stores[0], key: nil).asRebindable()
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
            let key = try Operations().mintMCPSetupKey(copiedFor: "claude-code")
            let fd = try connect(directory, as: "claude-code", key: key)
            defer { close(fd) }

            let teardown = macLockTeardown(session: AppSession(database: db), door: door, road: { .reKey }) {}
            await teardown()
            bound.binding.lock()
            try bound.binding.adopt(try AppDatabase.onDisk(url: stores[1], key: nil))
            door.attach(session: AppSession(database: db))
            #expect(closeWordsUntilEOF(fd)
                    == "Variorum's library locked or closed, so it closed this connection \u{2014} reconnect with /mcp once it's open again.",
                    "abandoned with the closing road's close line")
            try await Task.sleep(for: .milliseconds(300))
            #expect(try await endLines(db).isEmpty, "nothing written to the library now open")
            #expect(try await db.read { try Queries.mcpClient($0, name: "claude-code") } == nil)
        }
    }

    /// **THE LIBRARY CLOSING STAYS A TRUE STOP** (VX-818 — A-809-21's fail-closed
    /// condition, pinned explicitly): adopt and swap name `.closing` (the
    /// bootstrap's assignment is `WillLockRoadRouteTests`'), and a teardown that
    /// names no road is today's — each ends the connection with the closing road's
    /// close line and says its end ONCE ("the library locked or closed"), exactly
    /// as before, while the store is still open.
    @Test(arguments: [AppBootstrap.WillLockRoad.closing, nil] as [AppBootstrap.WillLockRoad?])
    func theLibraryClosingStillEndsTheConnectionAndSaysSoOnce(_ road: AppBootstrap.WillLockRoad?) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 818))
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

            let teardown = macLockTeardown(session: session, door: door, road: { road }) {}
            await teardown()
            #expect(closeWordsUntilEOF(fd)
                    == "Variorum's library locked or closed, so it closed this connection \u{2014} reconnect with /mcp once it's open again.")
            #expect(door.serverState == .waitingForLibrary)
            try await Task.sleep(for: .milliseconds(300))
            #expect(try await endLines(db) == ["claude-code disconnect_library_closed"], "said once, before the store went")
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

    /// **THE QUIT WHILE LOCKED** (VX-818): the lock suspended the host and kept it
    /// held; the quit then stops it exactly as a quit does — the quit's close line,
    /// nothing said (P-VX394-5), the store shut beneath it untouched.
    @Test func theQuitWhileLockedStillStopsTheServerAndSaysNothing() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 818))
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

            let teardown = macLockTeardown(session: session, door: door, road: { .lock }) {}
            await teardown()
            door.quit()
            #expect(closeWordsUntilEOF(fd)
                    == "Variorum quit, so it closed this connection \u{2014} reconnect with /mcp once it's open again.")
            try await Task.sleep(for: .milliseconds(300))
            #expect(try await endLines(db).isEmpty, "a quit says nothing, locked or not")
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
