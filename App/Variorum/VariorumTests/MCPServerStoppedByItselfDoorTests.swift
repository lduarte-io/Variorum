//
//  MCPServerStoppedByItselfDoorTests.swift
//  VariorumTests
//
//  VX-612 — the app's half (the VX-648 run, batch 2; the record
//  `notes/plans/fixes/vx-648-launch-week.md`, BATCH 2 RECORD). When the host's
//  listener dies while it runs (`MCPServerHost.State.stoppedByItself` — the
//  headless half is `MCPAcceptLoopServerTests`), the door ADOPTS it from the
//  host's own signal: Settings ▸ MCP stops saying "running" and says the server
//  stopped by itself; a snapshot change never restarts that host (its start
//  would sweep the while-connected grants of the connections it still serves);
//  her switch — off, then on — starts a fresh one. RED ON OLD by the mechanism:
//  the door never heard the host, and the old loop flipped nothing.
//

import Darwin
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMCP
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 612))
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

/// The hosts the door made, in order.
@MainActor
private final class MadeHosts {
    var all: [MCPServerHost] = []
}

@MainActor
@Suite("VX-612 — the door says the server stopped by itself (the app's half)", .serialized)
struct MCPServerStoppedByItselfDoorTests {
    @Test func theDoorAdoptsADeadListenerAndOnlyHerSwitchRestartsIt() async throws {
        try await withDoorWorld { (session: AppSession, db: AppDatabase) async throws in
            let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent("vdead-\(UUID().uuidString.prefix(8))", isDirectory: true)
            defer { try? FileManager.default.removeItem(at: directory) }
            let operations = Operations()
            let made = MadeHosts()
            let door = MCPDoor(serverAllowed: true) { database, executor in
                let host = MCPServerHost(
                    database: database, operations: operations, directory: directory, version: "test",
                    executor: executor)
                made.all.append(host)
                return host
            }
            defer { door.detach() }
            door.attach(session: session)
            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            let first = try #require(made.all.first)

            // The listener breaks: the next accept fails with a fatal errno.
            let broken = LockIsolated(false)
            first.acceptLoopFault = { step in
                guard step == .accept else { return nil }
                return broken.withValue { done in
                    defer { done = true }
                    return done ? nil : EBADF
                }
            }
            if case .success(let nudge) = MCPSocketRoad.connect(directory: directory) { close(nudge) }
            let reason = "accept: \(String(cString: strerror(EBADF)))"
            #expect(try await settle { door.serverState == .stoppedByItself(reason) }, "\(door.serverState)")
            #expect(MCPPaneCopy.status(door.serverState)
                    == "stopped by itself (\(reason)) \u{00B7} turn it off and on to restart")

            // A snapshot change (a new connection request) never restarts it.
            _ = try operations.recordMCPContact(name: "someone new", version: nil)
            try await Task.sleep(for: .milliseconds(300))
            #expect(door.serverState == .stoppedByItself(reason))
            #expect(made.all.count == 1 && first.state == .stoppedByItself(reason), "the same host, still down")
            guard case .failure = MCPSocketRoad.connect(directory: directory) else {
                Issue.record("a dead host was restarted by a snapshot change")
                return
            }

            // Her switch: off, then on — a fresh host serves.
            door.setEnabled(false)
            #expect(try await settle { door.serverState == .off })
            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            #expect(made.all.count == 2)
            guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
                Issue.record("the fresh host does not serve")
                return
            }
            close(fd)
            _ = db
        }
    }

    /// The words, as a fact of the copy table (the status line's other states
    /// unchanged).
    @Test func theStatusLineSaysItInWords() {
        #expect(MCPPaneCopy.status(.stoppedByItself("poll: Invalid argument"))
                == "stopped by itself (poll: Invalid argument) \u{00B7} turn it off and on to restart")
        #expect(MCPPaneCopy.status(.running)
                == "running \u{00B7} socket in the app container \u{00B7} serves while Variorum is open")
        #expect(MCPPaneCopy.status(.failed("x")) == "couldn't start: x")
    }
}
