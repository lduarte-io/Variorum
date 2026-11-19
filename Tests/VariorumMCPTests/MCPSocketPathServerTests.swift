import Darwin
import Dependencies
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-959 (the VX-981 run, batch 4) — THE SOCKET PATH ACROSS HOSTS: a server
// removes only its own socket, and a fresh host is never refused by a stale
// one, in the narrow timings too. Two hosts on ONE socket path in one process —
// the door's STALE host (its start had passed its pre-bind check when her OFF
// let it go) and its FRESH one (her ON) — each ran `MCPSocketRoad.listen`
// (probe → unlink → bind → chmod → listen) and then `start`'s publish re-check
// (VX-613) with nothing making the two sequences exclusive. Four roads, each
// held here by a DEBUG step probe (the listen's own — `MCPSocketRoad.ListenStep`
// — or the start's — `MCPServerHost.StartStep`), never by a sleep:
//   A — the fresh probe lands in the stale bind → listen gap (refused), steals
//       the path; the stale publish-fail cleanup then unlinks the FRESH socket
//       by name (the vx-913 ladder's F2);
//   B — the stale probe found nothing, the fresh host binds and publishes, the
//       stale "stale-file" unlink removes the FRESH socket (residual (f));
//   C — the fresh probe meets the stale host's undecided listener and the
//       fresh start FAILS "another Variorum is already serving" (residual (e));
//   D — one host started twice: the second start's probe meets the first's
//       undecided listener and faults the host (F3, the double-start flicker).
// RED ON THE SCAFFOLD (the seams present, the bind road as it was). The
// release: a held stale start is let go once the fresh start has ended OR has
// told it waits for the path (`.waitsForTheDirectory` — the serialized road's
// signal), whichever comes first.
//
// VX-773: DEBUG-only from birth — every pin drives a DEBUG seam.
#if DEBUG

/// The FIRST call to reach `step` waits there until `open()`; later calls
/// pass (two hosts on one path share the listen probe).
private final class Hold<Step: Equatable & Sendable>: @unchecked Sendable {
    let step: Step
    private let calls = LockIsolated(0)
    private let release = DispatchSemaphore(value: 0)

    init(_ step: Step) { self.step = step }

    var reached: Bool { calls.value > 0 }

    func probe(_ reached: Step) {
        guard reached == step else { return }
        let first = calls.withValue { count -> Bool in
            count += 1
            return count == 1
        }
        if first { release.wait() }
    }

    func open() { release.signal() }
}

/// A start on a thread of its own (the door runs it detached), its outcome
/// kept, and whether it told it waits for another host's bind road.
private final class StartOnAThread: @unchecked Sendable {
    private let outcome = LockIsolated<Result<Void, Error>?>(nil)
    let waited = LockIsolated(false)

    init(_ host: MCPServerHost, also probe: ((MCPServerHost.StartStep) -> Void)? = nil) {
        let waited = self.waited
        host.startStepProbe = { step in
            if step == .waitsForTheDirectory { waited.setValue(true) }
            probe?(step)
        }
        let outcome = self.outcome
        Thread {
            // The start runs OUTSIDE the outcome's lock (a `setValue` autoclosure
            // would run it inside, and a reader would then wait out the start).
            let ended = Result { try host.start() }
            outcome.setValue(ended)
        }.start()
    }

    var hasEnded: Bool { outcome.value != nil }

    /// Ended, or waiting for another host's road — the moment a held host may go.
    var endedOrWaits: Bool { hasEnded || waited.value }

    /// The start's outcome, waited for (bounded).
    func ended() async throws -> Result<Void, Error> {
        for _ in 0..<1_000 {
            if let done = outcome.value { return done }
            try await Task.sleep(for: .milliseconds(10))
        }
        throw HarnessFailure("the start never returned")
    }
}

private func until(_ condition: () -> Bool) async throws -> Bool {
    for _ in 0..<1_000 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// Two hosts on ONE directory — the door's stale host and its fresh one.
private struct OnePath {
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
            .appendingPathComponent("v959-\(UUID().uuidString.prefix(8))", isDirectory: true)
        self.directory = directory
        stale = MCPServerHost(database: database, operations: operations, directory: directory, version: "test")
        fresh = MCPServerHost(database: database, operations: operations, directory: directory, version: "test")
    }

    var path: String { MCPSocketRoad.socketPath(directory: directory) }

    /// A client connecting to the path right now reaches a listener.
    var served: Bool {
        guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else { return false }
        close(fd)
        return true
    }

    var socketFileExists: Bool { FileManager.default.fileExists(atPath: path) }

    func tearDown() {
        MCPSocketRoad.setListenProbeForTesting(path: path, nil)
        stale.stop()
        fresh.stop()
        try? FileManager.default.removeItem(at: directory)
    }
}

@Suite("VX-959 — a server removes only its own socket, and no stale host refuses a fresh one", .serialized)
struct MCPSocketPathServerTests {
    /// **A — RED ON THE SCAFFOLD (F2).** The stale start is bound and not yet
    /// listening when her OFF lets it go; the fresh start's probe is refused
    /// there, so it calls the path stale, unlinks it and binds its own; the
    /// stale publish re-check then fails and its cleanup unlinked the path BY
    /// NAME — the fresh host's socket: the fresh host "running", every new
    /// client told Variorum must be open.
    @Test func aStaleHostsCleanupNeverRemovesTheFreshHostsSocket() async throws {
        let world = try OnePath()
        defer { world.tearDown() }
        let hold = Hold(MCPSocketRoad.ListenStep.bound)
        defer { hold.open() }
        MCPSocketRoad.setListenProbeForTesting(path: world.path) { hold.probe($0) }
        let stale = StartOnAThread(world.stale)
        #expect(try await until { hold.reached }, "the stale start is held between its bind and its listen")

        world.stale.stop()                       // her OFF, after its pre-bind check
        let fresh = StartOnAThread(world.fresh)  // her ON
        #expect(try await until { fresh.endedOrWaits }, "the fresh start ended, or waits for the path")
        hold.open()
        _ = try await stale.ended()
        if case .failure(let error) = try await fresh.ended() { Issue.record("the fresh start failed: \(error)") }

        #expect(world.stale.state == .stopped, "the stale host publishes nothing")
        #expect(world.fresh.state == .running)
        #expect(world.socketFileExists && world.served,
                "RED ON THE SCAFFOLD: the stale cleanup removed the fresh host's socket — it serves no one")
    }

    /// **B — RED ON THE SCAFFOLD (residual (f)).** The stale probe found
    /// nothing; before its stale-file unlink the fresh host binds, listens and
    /// publishes; the stale unlink then removed the FRESH socket (and the stale
    /// host bound its own, which its failed re-check later removed): the fresh
    /// host "running" on a socket no client can reach.
    @Test func aStaleHostsStaleFileUnlinkNeverRemovesTheFreshHostsSocket() async throws {
        let world = try OnePath()
        defer { world.tearDown() }
        let hold = Hold(MCPSocketRoad.ListenStep.probed)
        defer { hold.open() }
        MCPSocketRoad.setListenProbeForTesting(path: world.path) { hold.probe($0) }
        let stale = StartOnAThread(world.stale)
        #expect(try await until { hold.reached }, "the stale start is held after its probe, before its unlink")

        world.stale.stop()
        let fresh = StartOnAThread(world.fresh)
        #expect(try await until { fresh.endedOrWaits }, "the fresh start ended, or waits for the path")
        hold.open()
        _ = try await stale.ended()
        if case .failure(let error) = try await fresh.ended() { Issue.record("the fresh start failed: \(error)") }

        #expect(world.stale.state == .stopped)
        #expect(world.fresh.state == .running)
        #expect(world.socketFileExists && world.served,
                "RED ON THE SCAFFOLD: the stale host's stale-file unlink removed the fresh host's live socket")
    }

    /// **C — RED ON THE SCAFFOLD (residual (e)).** The stale host is listening
    /// but not yet decided (between its bind and its publish re-check) when
    /// her OFF lets it go; the fresh probe met that listener and the fresh start
    /// FAILED — "another Variorum is already serving mcp.sock" — while the stale
    /// host then let its own go: nothing serves, and the pane's reason is false.
    @Test func aFreshStartIsNeverRefusedByAStaleHostsUndecidedListener() async throws {
        let world = try OnePath()
        defer { world.tearDown() }
        let hold = Hold(MCPServerHost.StartStep.bound)
        defer { hold.open() }
        let stale = StartOnAThread(world.stale, also: { hold.probe($0) })
        #expect(try await until { hold.reached }, "the stale start is held after its bind, before its publish")
        #expect(world.served, "non-vacuity: its listener answers (the window this pin is about)")

        world.stale.stop()
        let fresh = StartOnAThread(world.fresh)
        #expect(try await until { fresh.endedOrWaits }, "the fresh start ended, or waits for the path")
        hold.open()
        _ = try await stale.ended()
        if case .failure(let error) = try await fresh.ended() {
            Issue.record("RED ON THE SCAFFOLD: the fresh start was refused by the stale host's listener: \(error)")
        }

        #expect(world.stale.state == .stopped)
        #expect(world.fresh.state == .running, "RED ON THE SCAFFOLD: the fresh host failed (\(world.fresh.state))")
        #expect(world.socketFileExists && world.served, "RED ON THE SCAFFOLD: nothing serves")
    }

    /// **D — RED ON THE SCAFFOLD (F3, the double-start flicker).** One host
    /// started twice (the door's belt case): the first start is listening and
    /// not yet published when the second runs; its probe met the first start's
    /// listener, and the second start wrote `.failed("another Variorum is
    /// already serving mcp.sock")` and threw — the door's completion then says
    /// "couldn't start" — while the first start published `.running` over it.
    @Test func aHostStartedTwiceNeverFaultsItselfOverItsOwnUndecidedListener() async throws {
        let world = try OnePath()
        defer { world.tearDown() }
        let hold = Hold(MCPServerHost.StartStep.bound)
        defer { hold.open() }
        let waited = LockIsolated(false)
        world.stale.startStepProbe = { step in
            if step == .waitsForTheDirectory { waited.setValue(true) }
            hold.probe(step)
        }
        let first = LockIsolated<Result<Void, Error>?>(nil)
        let second = LockIsolated<Result<Void, Error>?>(nil)
        let host = world.stale
        Thread {
            let ended = Result { try host.start() }
            first.setValue(ended)
        }.start()
        #expect(try await until { hold.reached }, "the first start is held after its bind, before its publish")

        Thread {
            let ended = Result { try host.start() }
            second.setValue(ended)
        }.start()
        #expect(try await until { second.value != nil || waited.value }, "the second start ended, or waits for the path")
        let stateBeforeTheFirstPublished = host.state
        hold.open()
        #expect(try await until { first.value != nil && second.value != nil }, "both starts returned")

        if case .failure(let error)? = second.value {
            Issue.record("RED ON THE SCAFFOLD: the second start faulted its own host: \(error)")
        }
        if case .failure(let error)? = first.value { Issue.record("the first start failed: \(error)") }
        #expect(stateBeforeTheFirstPublished != .failed("another Variorum is already serving mcp.sock"),
                "RED ON THE SCAFFOLD: the host read failed beside its own listener (\(stateBeforeTheFirstPublished))")
        #expect(host.state == .running && world.served)
    }
}

#endif
