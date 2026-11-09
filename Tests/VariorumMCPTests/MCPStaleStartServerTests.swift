import Darwin
import Dependencies
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-613 (the VX-913 run, B3 — the run record's B3 RECORD, "VX-613 — the probe";
// the vx-548 record's MB-13 (ii)): THE HOST'S HALF of the door's stale-start races.
// Her switch ON → OFF → ON while the first start still waits (its while-connected
// sweep is a write, queued behind anything of hers): the door lets the first host
// go and starts a second, while the first start runs on. `MCPServerHost.start`
// checked its state only at entry, so a start that was STOPPED part-way still bound
// the socket and published `.running` — a host the door had let go served, and the
// fresh host's bind probe met it ("another Variorum is already serving mcp.sock"):
// the server down, the pane's reason false. And a host started twice (the flag
// half's road) faulted ITSELF: its second start's probe met its own live listener.
//
// The start is held where a busy writer holds it, by a DEBUG start-step probe
// (`MCPServerHost.startStepProbe` — the stop's `stopWindowProbe` precedent):
// `.swept` (after the sweep, before the bind) and `.bound` (after the bind, before
// the publish). RED ON OLD (the behavioural revert — the fix commit's
// `MCPServerHost.swift` from its parent): the three marked pins.

/// A start held at one step: the FIRST call to reach `step` waits there until
/// `open()` (later calls pass) — on the start's own thread, never the pool.
private final class StepGate: @unchecked Sendable {
    let step: MCPServerHost.StartStep
    private let calls = LockIsolated(0)
    private let release = DispatchSemaphore(value: 0)

    init(_ step: MCPServerHost.StartStep) { self.step = step }

    var reachedCount: Int { calls.value }

    func probe(_ reached: MCPServerHost.StartStep) {
        guard reached == step else { return }
        let first = calls.withValue { count -> Bool in
            count += 1
            return count == 1
        }
        if first { release.wait() }
    }

    func open() { release.signal() }
}

/// A start on its own thread (the door runs it detached, off the main actor),
/// its outcome kept for the pin.
private final class ThreadedStart: @unchecked Sendable {
    private let outcome = LockIsolated<Result<Void, Error>?>(nil)

    init(_ host: MCPServerHost) {
        let outcome = self.outcome
        let thread = Thread { outcome.setValue(Result { try host.start() }) }
        thread.start()
    }

    /// The start's outcome, waited for (bounded).
    func finished() async throws -> Result<Void, Error> {
        for _ in 0..<500 {
            if let done = outcome.value { return done }
            try await Task.sleep(for: .milliseconds(10))
        }
        throw HarnessFailure("the start never returned")
    }
}

private func until(_ condition: () -> Bool) async throws -> Bool {
    for _ in 0..<500 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// Two hosts on ONE directory — the door's stale host and its fresh one.
private struct TwoHosts {
    let directory: URL
    let stale: MCPServerHost
    let fresh: MCPServerHost

    init() throws {
        let database = try AppDatabase.inMemory()
        let operations = withDependencies {
            $0.database = database
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { Operations() }
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("v613-\(UUID().uuidString.prefix(8))", isDirectory: true)
        self.directory = directory
        stale = MCPServerHost(database: database, operations: operations, directory: directory, version: "test")
        fresh = MCPServerHost(database: database, operations: operations, directory: directory, version: "test")
    }

    /// Something answers at the socket path right now.
    var served: Bool {
        guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else { return false }
        close(fd)
        return true
    }

    var socketFileExists: Bool {
        FileManager.default.fileExists(atPath: MCPSocketRoad.socketPath(directory: directory))
    }

    func tearDown() {
        stale.stop()
        fresh.stop()
        try? FileManager.default.removeItem(at: directory)
    }
}

@Suite("VX-613 — a stopped start never binds; a host started twice never faults itself", .serialized)
struct MCPStaleStartServerTests {
    /// **RED ON OLD.** Her OFF lands while the first start waits in its sweep: the
    /// stopped start must not bind — and the fresh host then starts. Old: the
    /// stopped host bound the path and published `.running` (a host the door had
    /// let go, serving), and the fresh start failed "another Variorum is already
    /// serving mcp.sock".
    @Test func aStartStoppedDuringItsSweepNeverBindsAndTheFreshHostStarts() async throws {
        let world = try TwoHosts()
        defer { world.tearDown() }
        let gate = StepGate(.swept)
        defer { gate.open() }
        world.stale.startStepProbe = { gate.probe($0) }
        let start = ThreadedStart(world.stale)
        #expect(try await until { gate.reachedCount == 1 }, "the start is held after its sweep")

        world.stale.stop()                 // her OFF: nothing is bound yet
        gate.open()
        _ = try await start.finished()
        #expect(world.stale.state == .stopped, "RED ON OLD: a stopped start publishes nothing")
        #expect(!world.served, "RED ON OLD: the host the door let go serves nothing")

        #expect(throws: Never.self, "RED ON OLD: the fresh host binds") { try world.fresh.start() }
        #expect(world.fresh.state == .running && world.served)
    }

    /// **RED ON OLD.** Her OFF lands between the stale start's bind and its
    /// publish: the stop saw no listener (none was published), so the start must
    /// let its own go — closed, its socket removed — and the fresh host starts.
    /// Old: the stopped host published `.running` over the stop with a live accept
    /// loop nothing would ever end but a later stop, and the fresh start failed.
    @Test func aStartStoppedBetweenItsBindAndItsPublishLetsItsListenerGo() async throws {
        let world = try TwoHosts()
        defer { world.tearDown() }
        let gate = StepGate(.bound)
        defer { gate.open() }
        world.stale.startStepProbe = { gate.probe($0) }
        let start = ThreadedStart(world.stale)
        #expect(try await until { gate.reachedCount == 1 }, "the start is held after its bind")
        #expect(world.served, "non-vacuity: its listener is bound (the window this pin is about)")

        world.stale.stop()
        gate.open()
        _ = try await start.finished()
        #expect(world.stale.state == .stopped, "RED ON OLD: a stopped start publishes nothing")
        #expect(!world.served && !world.socketFileExists, "RED ON OLD: its listener closed, its own socket removed")

        #expect(throws: Never.self, "RED ON OLD: the fresh host binds") { try world.fresh.start() }
        #expect(world.fresh.state == .running && world.served)
    }

    /// **RED ON OLD.** One host started TWICE (the door's flag half: a stale
    /// completion cleared `starting`, and a reconcile started the held host
    /// again): whichever start binds serves, and the other one never faults its
    /// own host. Old: the later start's bind probe met its own host's listener and
    /// set `.failed("another Variorum is already serving mcp.sock")` over the host
    /// that served — the pane's false "couldn't start".
    @Test func aHostStartedTwiceNeverFaultsItselfOverItsOwnListener() async throws {
        let world = try TwoHosts()
        defer { world.tearDown() }
        let gate = StepGate(.swept)
        defer { gate.open() }
        world.stale.startStepProbe = { gate.probe($0) }
        let first = ThreadedStart(world.stale)
        #expect(try await until { gate.reachedCount == 1 }, "the first start is held after its sweep")

        let second = ThreadedStart(world.stale)    // the double start: it passes, binds and serves
        if case .failure(let error) = try await second.finished() { Issue.record("the second start failed: \(error)") }
        #expect(world.stale.state == .running && world.served, "non-vacuity: the second start serves")

        gate.open()
        let late = try await first.finished()
        if case .failure(let error) = late { Issue.record("RED ON OLD: the late start threw \(error)") }
        #expect(world.stale.state == .running, "RED ON OLD: the serving host is never faulted by its own listener")
        #expect(world.served)
    }

    /// GUARD (green on both sides): a stop belongs to the start it interrupts,
    /// never to the host's whole life — a host stopped and started again starts.
    @Test func aStopEndsOnlyTheStartItInterrupts() throws {
        let world = try TwoHosts()
        defer { world.tearDown() }
        try world.stale.start()
        #expect(world.stale.state == .running && world.served)
        world.stale.stop()
        #expect(world.stale.state == .stopped && !world.served)
        try world.stale.start()
        #expect(world.stale.state == .running && world.served, "a later start is its own")
    }
}
