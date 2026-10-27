import Darwin
import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-394 — THE STOP ROADS, swept (VX-548 batch 2b; the run record
// `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 2b RECORD). Every
// road that ends an MCP connection × what Activity says about it. The shipped
// lines' own pins are `MCPConnectionEndServerTests` (headless) and
// `MCPConnectionEndDoorTests` (the app's door); these pin what the sweep found
// at the host:
//
//   - THE QUIT (P-VX394-5 — "a QUIT logs nothing"): since VX-348's fix leg a
//     connection writes its own end through its own store, host or no host, so
//     the quit's stop (the door's `detach()` — "the library locked or closed")
//     raced the process's exit: a line on some quits, none on others.
//   - A STOP THAT NEVER SERVED (the pane's "running" while nothing answers): a
//     host whose start lost to another's — the door's stale start, after a
//     quick OFF → ON — unlinked the socket path on its stop, the LIVE host's
//     file, so the pane said "running" while every client heard "Variorum must
//     be open".
//   - A CONNECTION ACCEPTED WHILE THE SERVER STOPS: the stop took its list of
//     connections before the accept loop had stopped, so one accepted in that
//     window was never hung up — it outlived the stop (still served with the
//     switch OFF) and never said its end.

/// The connection-end rows, oldest first, as (client, act).
private func ends(_ database: AppDatabase) throws -> [(client: String, act: String)] {
    let acts = Set(MCPConnectionEnd.allCases.map(\.act))
    return try database.read { db in try Queries.mcpActivity(db) }
        .reversed()
        .filter { acts.contains($0.act) }
        .map { ($0.clientName, $0.act) }
}

private func tempDirectory(_ prefix: String) -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("\(prefix)-\(UUID().uuidString.prefix(8))", isDirectory: true)
}

/// A raw client on `directory`'s socket that NAMES ITSELF: its setup key's
/// preamble, then an `initialize` as `name`, the server's answer read (a bounded
/// receive — 5 s). The caller closes the descriptor.
private func namedClient(_ directory: URL, key: String, as name: String) throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw HarnessFailure("could not connect as \(name)")
    }
    var timeout = timeval(tv_sec: 5, tv_usec: 0)
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

/// The server hung this connection up: reading reaches EOF (anything the server
/// still had to say is read past) within the 5 s receive bound — false on a
/// timeout, i.e. a connection still open.
private func reachesEOF(_ fd: Int32) -> Bool {
    var buffer = [UInt8](repeating: 0, count: 4096)
    while true {
        let count = read(fd, &buffer, buffer.count)
        if count == 0 { return true }
        if count < 0 { return false }
    }
}

private func eventually(_ condition: () throws -> Bool) async throws -> Bool {
    for _ in 0..<300 {
        if try condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return try condition()
}

@Suite("VX-394 — the stop roads, swept (VX-548 batch 2b)", .serialized)
struct MCPStopRoadsServerTests {
    // MARK: - THE QUIT (P-VX394-5): nothing, every time

    /// **RED ON OLD:** the quit's stop said "the library locked or closed" through
    /// the connection's own end — whenever that end won the race with the
    /// process's exit. A quit says nothing (P-VX394-5), whoever wins.
    @Test func aQuitSaysNothingForAConnectionItEnds() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let directory = tempDirectory("vquit")
        defer { try? FileManager.default.removeItem(at: directory) }
        var host: MCPServerHost? = MCPServerHost(
            database: h.database, operations: h.operations, directory: directory, version: "test",
            executor: SeededExecutor(operations: h.writeOperations))
        weak var released = host
        try host?.start()
        let fd = try namedClient(directory, key: try h.setupKey(for: "claude-code"), as: "claude-code")
        defer { close(fd) }
        #expect(host?.connectedClientNames == ["claude-code"], "the connection named itself")

        // The door's quit road: the stop with the process, then the host let go.
        host?.stopWithTheProcess()
        host = nil
        #expect(released == nil, "the host is gone before its session finishes ending — the door's road")
        #expect(reachesEOF(fd), "the connection ends with the server")
        try await Task.sleep(for: .milliseconds(400))
        let logged = try ends(h.database)
        #expect(logged.isEmpty, "a quit says nothing (P-VX394-5): \(logged)")
    }

    /// GUARD (green on both sides): a client that left BEFORE the quit keeps its
    /// own line — the quit forgoes only the ends it makes.
    @Test func aClientThatLeftBeforeTheQuitKeepsItsOwnLine() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let directory = tempDirectory("vquit")
        defer { try? FileManager.default.removeItem(at: directory) }
        let host = MCPServerHost(
            database: h.database, operations: h.operations, directory: directory, version: "test",
            executor: SeededExecutor(operations: h.writeOperations))
        try host.start()
        let fd = try namedClient(directory, key: try h.setupKey(for: "claude-code"), as: "claude-code")
        close(fd)
        #expect(try await eventually { try ends(h.database).count == 1 }, "the client's close is said")
        host.stopWithTheProcess()
        try await Task.sleep(for: .milliseconds(300))
        let logged = try ends(h.database)
        #expect(logged.map(\.act) == [MCPConnectionEnd.clientClosed.act], "\(logged)")
    }

    // MARK: - A STOP THAT NEVER SERVED leaves the serving host's socket alone

    /// **RED ON OLD:** a host whose start lost the race (the path already served
    /// — `alreadyServed`), or that never started at all, unlinked the socket path
    /// on its stop: the LIVE host's file. The live host kept saying "running"
    /// while nothing could reach it.
    @Test func aStopThatNeverServedLeavesTheServingHostsSocketInPlace() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        // The door's stale start (a quick OFF → ON): its start finds the path served.
        let stale = MCPServerHost(
            database: h.database, operations: h.operations, directory: h.directory, version: "test",
            executor: SeededExecutor(operations: h.writeOperations))
        #expect(throws: MCPSocketRoad.ListenError(kind: .alreadyServed)) { try stale.start() }
        stale.stop()
        // …and one stopped before its start ever ran.
        MCPServerHost(
            database: h.database, operations: h.operations, directory: h.directory, version: "test",
            executor: SeededExecutor(operations: h.writeOperations)
        ).stop()

        #expect(h.host.state == .running)
        guard case .success(let probe) = MCPSocketRoad.connect(directory: h.directory) else {
            Issue.record("the serving host's socket is gone — it says running while nothing reaches it")
            return
        }
        close(probe)
        // …and a client still connects end to end (the connect throws if it can't).
        let connection = try await h.connect(as: "claude-code")
        await h.hangUp(connection)
    }

    /// GUARD (green on both sides): a host's own stop still removes ITS socket —
    /// the socket dies with the server.
    @Test func aHostsOwnStopStillRemovesItsSocket() throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let directory = tempDirectory("vstop")
        defer { try? FileManager.default.removeItem(at: directory) }
        let host = MCPServerHost(
            database: h.database, operations: h.operations, directory: directory, version: "test",
            executor: SeededExecutor(operations: h.writeOperations))
        try host.start()
        host.stop()
        #expect(host.state == .stopped)
        #expect(!FileManager.default.fileExists(atPath: MCPSocketRoad.socketPath(directory: directory)))
        guard case .failure(let failure) = MCPSocketRoad.connect(directory: directory) else {
            Issue.record("a stopped host still answers")
            return
        }
        #expect(failure == .notRunning(errno: ENOENT))
    }

    // MARK: - A CONNECTION ACCEPTED WHILE THE SERVER STOPS is hung up and says why

    /// **RED ON OLD:** the stop's list of connections was taken before its accept
    /// loop stopped, so a client accepted in between was never hung up — it
    /// outlived the stop, served on with the switch OFF, and never said its end.
    @Test func aConnectionAcceptedWhileTheServerStopsIsHungUpAndSaysWhy() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let key = try h.setupKey(for: "latecomer")
        let late = LockIsolated<Int32>(-1)
        let probed = LockIsolated(false)
        h.host.stopWindowProbe = { [directory = h.directory] in
            guard !probed.value else { return }
            probed.setValue(true)
            late.setValue((try? namedClient(directory, key: key, as: "latecomer")) ?? -1)
        }
        h.host.stop(ending: .serverOff)
        let fd = late.value
        #expect(fd >= 0, "the latecomer was accepted and named itself while the server stopped")
        guard fd >= 0 else { return }
        defer { close(fd) }
        #expect(reachesEOF(fd), "the stop hangs up every connection it served — the latecomer included")
        #expect(try await eventually { try ends(h.database).count == 1 }, "its end is said")
        let logged = try ends(h.database)
        #expect(logged.map(\.client) == ["latecomer"] && logged.map(\.act) == [MCPConnectionEnd.serverOff.act],
                "\(logged)")
    }

    // MARK: - GUARD: past the session cap, the refused connection says nothing

    /// GUARD (green on both sides — P-VX394-6's clarification): the connection the
    /// session cap turns away is never admitted, never names itself, and leaves no
    /// end line; the sixteen it serves say theirs when the server stops.
    @Test func pastTheSessionCapTheRefusedConnectionSaysNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        var held: [Int32] = []
        defer { held.forEach { close($0) } }
        for index in 0..<MCPServerHost.sessionCap {
            held.append(try namedClient(h.directory, key: try h.setupKey(for: "c\(index)"), as: "c\(index)"))
        }
        #expect(try await eventually { h.host.connectedClientNames.count == MCPServerHost.sessionCap })
        let capped = try namedClient(h.directory, key: try h.setupKey(for: "capped"), as: "capped")
        #expect(reachesEOF(capped), "answered with the cap's sentence, then closed")
        close(capped)
        try await Task.sleep(for: .milliseconds(300))
        #expect(try ends(h.database).isEmpty, "nothing said for a connection the cap refused")
        h.host.stop(ending: .serverOff)
        #expect(try await eventually { try ends(h.database).count == MCPServerHost.sessionCap })
        let logged = try ends(h.database)
        #expect(!logged.map(\.client).contains("capped"))
        #expect(logged.allSatisfy { $0.act == MCPConnectionEnd.serverOff.act })
    }
}
