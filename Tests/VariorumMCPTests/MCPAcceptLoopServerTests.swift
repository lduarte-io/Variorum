import Darwin
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-612 — THE ACCEPT LOOP: RETRY THE TRANSIENT CLASS, FAIL LOUDLY OTHERWISE (the
// VX-648 run, batch 2; traced, unobserved, by VX-548 batch 2b — M1, MB-13 (i)).
// The loop returned on EMFILE / ENFILE / ENOMEM / ENOBUFS, poll's EAGAIN or a
// listener error and nothing told the host or the door: `state` stayed `.running`,
// the pane said "running", the listening descriptor stayed open (connects queued
// in its backlog, never answered) — and a restart's probe would even hear that
// zombie as "another Variorum is already serving". Now: the transient class is
// retried after a bounded pause, and a fatal exit closes the listener, removes
// its socket, flips the host to `.stoppedByItself` and signals the door. Faults
// are injected headlessly through the host's DEBUG seam (`acceptLoopFault`, the
// `stopWindowProbe` pattern). RED by behavioural revert (the loop's old
// `return` on every failure but EINTR/ECONNABORTED, no state flip).

/// Faults queued per step, consumed one per call; an empty queue runs the real call.
private final class FaultQueue: @unchecked Sendable {
    private let lock = NSLock()
    private var queued: [MCPServerHost.AcceptStep: [Int32]] = [:]
    private var persistent: [MCPServerHost.AcceptStep: Int32] = [:]
    private(set) var consumed: [MCPServerHost.AcceptStep: Int] = [:]

    func queue(_ step: MCPServerHost.AcceptStep, _ codes: [Int32]) { lock.withLock { queued[step, default: []] += codes } }
    func always(_ step: MCPServerHost.AcceptStep, _ code: Int32?) { lock.withLock { persistent[step] = code } }
    func count(_ step: MCPServerHost.AcceptStep) -> Int { lock.withLock { consumed[step, default: 0] } }
    func remaining(_ step: MCPServerHost.AcceptStep) -> Int { lock.withLock { queued[step, default: []].count } }

    func next(_ step: MCPServerHost.AcceptStep) -> Int32? {
        lock.withLock {
            if let code = persistent[step] {
                consumed[step, default: 0] += 1
                return code
            }
            guard var codes = queued[step], !codes.isEmpty else { return nil }
            let code = codes.removeFirst()
            queued[step] = codes
            consumed[step, default: 0] += 1
            return code
        }
    }
}

private func spec() -> Operations.MCPGrantSpec {
    .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always)
}

private func socketExists(_ directory: URL) -> Bool {
    FileManager.default.fileExists(atPath: MCPSocketRoad.socketPath(directory: directory))
}

@Suite("VX-612 — the accept loop retries what passes and says what doesn't", .serialized)
struct MCPAcceptLoopServerTests {
    private func faulted(_ h: ServerHarness) -> FaultQueue {
        let faults = FaultQueue()
        h.host.acceptLoopFault = { faults.next($0) }
        return faults
    }

    /// Counts the door's signal. `landingAfter` holds the signal on the
    /// thread that sends it before it is counted — VX-932's pin: the dying
    /// listener flips `state` under the host's lock and only AFTERWARDS removes
    /// its socket and signals (`MCPServerHost.listenerDied`), on the accept
    /// thread, which load can deschedule in between; a late signal is that
    /// descheduled thread made deterministic.
    private func signals(_ h: ServerHarness, landingAfter delay: Duration = .zero) -> LockIsolated<Int> {
        let count = LockIsolated(0)
        let micros = UInt32(delay.components.seconds * 1_000_000 + delay.components.attoseconds / 1_000_000_000_000)
        h.host.onStateChanged = {
            if micros > 0 { usleep(micros) }
            count.withValue { $0 += 1 }
        }
        return count
    }

    /// Descriptors, memory, buffers: each failure is retried after a pause and
    /// the client waiting in the backlog is served — the host never stops.
    @Test func transientAcceptFailuresAreRetriedAndTheClientIsServed() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let faults = faulted(h)
            let heard = signals(h)
            faults.queue(.accept, [EMFILE, ENFILE, ENOMEM, ENOBUFS, EAGAIN])
            let connection = try await HarnessDeadline.$seconds.withValue(10) {
                try await h.connect(as: "claude-code")
            }
            #expect(faults.count(.accept) == 5 && faults.remaining(.accept) == 0, "every fault met, then the real accept")
            _ = try h.approve("claude-code", spec())
            #expect(try await connection.client.callTool(name: "list_books", arguments: [:]).isError != true)
            #expect(h.host.state == .running && heard.value == 0)
            await h.hangUp(connection)
        }
    }

    /// poll's own transient class (and an interrupt) — retried the same way,
    /// and the loop serves the next client after it.
    @Test func transientPollFailuresAreRetried() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let faults = faulted(h)
            // The faults meet whichever polls come next (the loop's re-park after
            // the first connection, or the one after the second): each is retried.
            let first = try await h.connect(as: "claude-code")
            faults.queue(.poll, [EAGAIN, ENOMEM, EINTR])
            let second = try await HarnessDeadline.$seconds.withValue(10) { try await h.connect(as: "codex") }
            #expect(try await h.eventually { faults.count(.poll) == 3 }, "every fault met")
            let third = try await HarnessDeadline.$seconds.withValue(10) { try await h.connect(as: "a third") }
            #expect(h.host.state == .running)
            for connection in [first, second, third] { await h.hangUp(connection) }
        }
    }

    /// A broken listener: the loop ends and SAYS so — the host reads
    /// `.stoppedByItself` with the reason, the door's signal fires once, the
    /// socket is closed and removed (a new client is refused at once, never
    /// left in a dead backlog), and the connection already served is still
    /// served until a stop ends it.
    @Test func aFatalAcceptFailureStopsTheListenerAndSaysSo() async throws {
        try await fatalAcceptRoad(signalLandingAfter: .zero)
    }

    /// VX-932 — the same road with the door's signal landing 300 ms after the
    /// state flips (the descheduled accept thread, deterministic): the signal
    /// and the socket's removal are WAITED FOR, never read at the flip, and
    /// the signal is still heard exactly once. Red on old (the immediate reads).
    @Test func aSignalLandingLateAfterTheFlipIsStillHeardOnce() async throws {
        try await fatalAcceptRoad(signalLandingAfter: .milliseconds(300))
    }

    private func fatalAcceptRoad(signalLandingAfter delay: Duration) async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let faults = faulted(h)
            let heard = signals(h, landingAfter: delay)
            let served = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec())
            faults.queue(.accept, [EBADF])
            guard case .success(let doomed) = MCPSocketRoad.connect(directory: h.directory) else {
                Issue.record("the listener refused the triggering connect")
                return
            }
            defer { close(doomed) }
            #expect(try await h.eventually { h.host.state != .running })
            #expect(h.host.state == .stoppedByItself("accept: \(String(cString: strerror(EBADF)))"), "\(h.host.state)")
            // VX-932: the state flips under the lock FIRST; the socket's
            // removal and the signal follow on the accept thread.
            #expect(try await h.eventually { heard.value >= 1 }, "the door is signalled")
            #expect(try await h.eventually { !socketExists(h.directory) }, "the dead listener's socket is removed")
            guard case .failure = MCPSocketRoad.connect(directory: h.directory) else {
                Issue.record("a new client still reached a socket")
                return
            }
            #expect(try await served.client.callTool(name: "list_books", arguments: [:]).isError != true,
                    "the connection already served keeps being served")
            #expect(h.host.connectedClientNames == ["claude-code"])
            #expect(heard.value == 1, "the door is signalled ONCE")
            h.host.stop(ending: .serverOff)
            #expect(h.host.state == .stopped)
        }
    }

    /// The same for poll's fatal class.
    @Test func aFatalPollFailureDoesTheSame() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let faults = faulted(h)
            let heard = signals(h)
            let served = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec())
            faults.queue(.poll, [EINVAL])
            // Whichever poll comes next meets it: the re-park after the first
            // connection, or the one a second connect wakes.
            if case .success(let nudge) = MCPSocketRoad.connect(directory: h.directory) { close(nudge) }
            #expect(try await h.eventually { h.host.state != .running })
            #expect(h.host.state == .stoppedByItself("poll: \(String(cString: strerror(EINVAL)))"), "\(h.host.state)")
            // VX-932: the removal and the signal follow the flip — wait for them.
            #expect(try await h.eventually { heard.value >= 1 && !socketExists(h.directory) })
            #expect(try await served.client.callTool(name: "list_books", arguments: [:]).isError != true,
                    "the connection already served keeps being served")
            #expect(heard.value == 1, "the door is signalled once")
            await h.hangUp(served)
        }
    }

    /// A transient condition that lasts is RETRIED, never called a death (the
    /// state stays running while it retries, the pauses bounded), and a stop
    /// in the middle of a pause is a stop — `.stopped`, no signal.
    @Test func aLastingTransientConditionKeepsRetryingAndAStopIsAStop() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let faults = faulted(h)
            let heard = signals(h)
            faults.always(.accept, EMFILE)
            guard case .success(let waiting) = MCPSocketRoad.connect(directory: h.directory) else {
                Issue.record("no connect")
                return
            }
            defer { close(waiting) }
            #expect(try await h.eventually { faults.count(.accept) >= 5 }, "it keeps trying")
            try await Task.sleep(for: .milliseconds(300))
            #expect(h.host.state == .running, "a transient condition is never a death")
            h.host.stop(ending: .serverOff)
            #expect(h.host.state == .stopped && heard.value == 0)
            let tried = faults.count(.accept)
            try await Task.sleep(for: .milliseconds(1_200))
            #expect(faults.count(.accept) == tried, "the loop ended with the stop")
        }
    }

    /// A server removes only its own socket — across the new road too: once a
    /// host has stopped by itself, a fresh host binds the free path, and the
    /// dead host's later stop leaves the fresh one's socket in place.
    @Test func aDeadHostsLaterStopLeavesTheFreshHostsSocket() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let faults = faulted(h)
            let heard = signals(h)
            faults.queue(.accept, [EINVAL])
            guard case .success(let doomed) = MCPSocketRoad.connect(directory: h.directory) else {
                Issue.record("no connect")
                return
            }
            close(doomed)
            #expect(try await h.eventually { h.host.state != .running })
            // VX-932: the dead listener removes its socket AFTER the flip; a
            // fresh host binds only once the death is said (the door's road).
            #expect(try await h.eventually { heard.value == 1 })
            let fresh = MCPServerHost(
                database: h.database, operations: h.operations, directory: h.directory, version: "test",
                executor: SeededExecutor(operations: h.writeOperations))
            try fresh.start()
            defer { fresh.stop() }
            #expect(fresh.state == .running && socketExists(h.directory))
            h.host.stop(ending: .serverOff)
            #expect(socketExists(h.directory), "the dead host removed nothing of the fresh one's")
            guard case .success(let fd) = MCPSocketRoad.connect(directory: h.directory) else {
                Issue.record("the fresh host's socket is gone")
                return
            }
            close(fd)
        }
    }

    /// The classification, pure: interrupts and aborted connections again at
    /// once; the resource class after a pause; everything else fatal. The
    /// pause doubles from 10 ms to its one-second cap.
    @Test func theClassificationAndThePause() {
        typealias H = MCPServerHost
        for code in [EINTR] {
            #expect(H.classify(.poll, errno: code) == .again)
            #expect(H.classify(.accept, errno: code) == .again)
        }
        #expect(H.classify(.accept, errno: ECONNABORTED) == .again)
        for code in [EAGAIN, ENOMEM] { #expect(H.classify(.poll, errno: code) == .retry) }
        for code in [EMFILE, ENFILE, ENOMEM, ENOBUFS, EAGAIN] { #expect(H.classify(.accept, errno: code) == .retry) }
        for code in [EINVAL, EFAULT, EBADF] { #expect(H.classify(.poll, errno: code) == .fatal) }
        for code in [EBADF, EINVAL, ENOTSOCK, EOPNOTSUPP, EFAULT] { #expect(H.classify(.accept, errno: code) == .fatal) }
        #expect((0..<10).map { H.pause(afterRetries: $0) } == [10, 20, 40, 80, 160, 320, 640, 1_000, 1_000, 1_000])
        #expect(H.pause(afterRetries: 10_000) == H.pauseCap)
    }
}
