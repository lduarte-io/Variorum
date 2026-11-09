//
//  VX613StaleStartDoorTests.swift
//  VariorumTests (Mac)
//
//  VX-613 — THE DOOR'S HALF (the VX-913 run, B3; the run record's B3 RECORD,
//  "VX-613 — the probe", (i) the flag half; the vx-548 record's MB-13 (ii)). Her
//  switch ON → OFF → ON while the first start still waits in its sweep: the door
//  lets the first host go and starts a second. The first start's completion ran
//  `starting = false` BEFORE its identity guard, so it cleared the SECOND start's
//  flag; any snapshot change while that start was still running then passed the
//  reconcile's gate (`host.state == .running || starting`) and started the held
//  host a second time — two starts of one host racing, the loser's bind probe
//  meeting its own host's listener ("couldn't start: another Variorum is already
//  serving mcp.sock" beside a listener that served).
//
//  The headless half (the host never faulting itself, a stopped start never
//  binding) is `MCPStaleStartServerTests`. This pin drives the REAL door with
//  every host's start held after its sweep by the host's DEBUG start-step probe.
//  RED ON OLD (the behavioural revert — the door fix commit's `MCPDoor.swift`
//  from its parent; the host's fix stays in): the fresh host's start runs TWICE.
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 613))
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

/// A host's start held after its sweep: the FIRST start to reach the step waits
/// until `open()` (on the start's own detached thread); later starts pass.
private final class StepGate: @unchecked Sendable {
    private let calls = LockIsolated(0)
    private let release = DispatchSemaphore(value: 0)

    /// How many starts of this host reached the step.
    var reachedCount: Int { calls.value }

    func probe(_ step: MCPServerHost.StartStep) {
        guard step == .swept else { return }
        let first = calls.withValue { count -> Bool in
            count += 1
            return count == 1
        }
        if first { release.wait() }
    }

    func open() { release.signal() }
}

/// The door's own server in a temp directory, every host it makes gated and
/// its stops counted (`stopWindowProbe` runs inside each stop).
@MainActor
private final class GatedDoorServer {
    final class Made {
        var hosts: [MCPServerHost] = []
        var gates: [StepGate] = []
        var stops: [LockIsolated<Int>] = []
    }

    let directory: URL
    let made: Made
    let door: MCPDoor

    init() {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("v613-\(UUID().uuidString.prefix(8))", isDirectory: true)
        let operations = Operations()
        let made = Made()
        self.directory = directory
        self.made = made
        door = MCPDoor(serverAllowed: true) { database, executor in
            let host = MCPServerHost(
                database: database, operations: operations, directory: directory, version: "test",
                executor: executor)
            let gate = StepGate()
            let stops = LockIsolated(0)
            host.startStepProbe = { gate.probe($0) }
            host.stopWindowProbe = { stops.withValue { $0 += 1 } }
            made.hosts.append(host)
            made.gates.append(gate)
            made.stops.append(stops)
            return host
        }
    }

    func cleanUp() {
        for gate in made.gates { gate.open() }
        try? FileManager.default.removeItem(at: directory)
    }
}

@MainActor
@Suite("VX-613 — a stale start's completion never clears the fresh start's flag", .serialized)
struct VX613StaleStartDoorTests {
    /// **RED ON OLD.** ON → OFF → ON with the first start held after its sweep;
    /// the stale start is let go and completes; a snapshot change lands while the
    /// fresh start is still held — and the fresh host's start has run ONCE, and
    /// it serves.
    @Test func aStaleStartsCompletionLeavesTheFreshStartsFlagAlone() async throws {
        try await withDoorWorld { (session: AppSession, _: AppDatabase) async throws in
            let server = GatedDoorServer()
            defer { server.cleanUp() }
            let door = server.door
            door.attach(session: session)
            defer { door.detach() }

            door.setEnabled(true)
            #expect(try await settle { server.made.gates.first?.reachedCount == 1 }, "the first start is held after its sweep")
            door.setEnabled(false)
            #expect(try await settle { door.serverState == .off }, "her OFF lets the starting host go")
            door.setEnabled(true)
            #expect(try await settle { server.made.gates.count == 2 && server.made.gates[1].reachedCount == 1 },
                    "the fresh host's start is held after its sweep")

            // The stale start runs on and completes (its host's second stop is its
            // completion's — the first was her OFF).
            server.made.gates[0].open()
            #expect(try await settle { server.made.stops[0].value == 2 }, "the stale completion landed")

            // A snapshot change while the fresh start is still held.
            door.setOpenBook(true)
            #expect(try await settle { door.snapshot.openBook }, "the reconcile ran")
            try await Task.sleep(for: .milliseconds(300))
            #expect(server.made.gates[1].reachedCount == 1,
                    "RED ON OLD: the fresh host is started ONCE — the stale completion left its flag alone")

            server.made.gates[1].open()
            #expect(try await settle { door.serverState == .running }, "the fresh host serves")
            #expect(server.made.hosts.count == 2 && server.made.hosts[1].state == .running
                    && server.made.hosts[0].state == .stopped)
        }
    }
}
