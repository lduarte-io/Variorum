import Darwin
import Dependencies
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-933 — A CLIENT THAT STOPS READING NEVER PINS THE COOPERATIVE POOL (the
// VX-940 run, W4; born at the VX-926 run's U1 as F-U1-2; the run record
// `notes/plans/fixes/vx-940-pre-oss-followups.md`, "## W4 record").
//
// THE MECHANISM: every write the door makes to a connection's socket is a
// BLOCKING `write` — it returns only once the kernel has taken every byte, and
// the kernel takes them only as fast as the client reads. The session runs on
// the process's cooperative pool (`MCPServerHost.serve` starts it as a `Task`;
// the transport is an actor on the default executor), so a client that stops
// reading while an answer bigger than the socket's buffer is pending held ONE
// POOL THREAD per such write, for as long as it did not read: the SDK's frames
// (`MCPSocketTransport.send`), the over-cap answer, and the opening's refusals
// (`MCPSession.run` — a refusal echoes the `initialize`'s id, which may be up to
// the opening's 1 MiB line). The pool is exactly `activeProcessorCount` wide and
// the host serves up to 16 connections, so enough stalled clients (more than the
// Mac has cores) stopped every task in the APP — nothing async ran until one of
// them read or the server stopped.
//
// THE PINS, made deterministic: MORE stalled writes at once than the pool has
// threads (a socket pair whose client end never reads; each write far larger
// than the buffer), then a task the pool must run. Every pin uses only API the
// pre-fix tree has, and bounds every wait OFF the pool (a thread of its own and
// a semaphore), so on the pre-fix tree it does not hang: it watches the pool
// pinned until its bound, then stops the writes the way the server's stop does
// (`shutdown` — the write fails, the thread is let go) and reports. No harness
// helper is used (no `ServerHarness`, `rawOpen`, `HarnessDeadline`, `HarnessWait`
// or `RawSocket`): the transport and the session are driven over socket pairs.

/// The wait bound — the MCP harness's own one bound (30 s, O-7's rule), so a
/// loaded machine's pool starvation by OTHER suites cannot read as this red;
/// the fixed tree answers in milliseconds.
private let bound: TimeInterval = 30

/// More stalled writes than the pool has threads.
private var stalledCount: Int { ProcessInfo.processInfo.activeProcessorCount + 4 }

private func noSigPipe(_ fd: Int32) {
    var one: Int32 = 1
    _ = setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &one, socklen_t(MemoryLayout<Int32>.size))
}

/// Whether bytes wait unread at `fd` (the stalled client's end) — i.e. the
/// write toward it has begun. Never blocks (a zero-timeout poll).
private func holdsUnreadBytes(_ fd: Int32) -> Bool {
    var ready = pollfd(fd: fd, events: Int16(POLLIN), revents: 0)
    return poll(&ready, 1, 0) == 1 && ready.revents & Int16(POLLIN) != 0
}

/// What the watcher saw while every write was stalled.
private struct Watch: Sendable {
    /// How many of the stalled writes had begun (their client holds bytes).
    let begun: Int
    /// Whether a task the cooperative pool must run ran while they stalled.
    let poolRan: Bool
}

/// The watcher, on a thread of its own (never the pool): waits (bounded) for
/// every write to have begun, then posts a task the pool must run and waits
/// (bounded) for it; then `stop` ends the writes the way a server stop does.
/// The awaiting test resumes only after the stop — on the pre-fix tree, the
/// first moment the pool has a thread again.
private func watchThePool(clients: [Int32], stop: @escaping @Sendable () -> Void) async -> Watch {
    await withCheckedContinuation { continuation in
        let watcher = Thread {
            let deadline = Date().addingTimeInterval(bound)
            var begun = clients.filter(holdsUnreadBytes).count
            while begun < clients.count, Date() < deadline {
                usleep(5_000)
                begun = clients.filter(holdsUnreadBytes).count
            }
            let ran = DispatchSemaphore(value: 0)
            Task.detached { ran.signal() }
            let poolRan = ran.wait(timeout: .now() + bound) == .success
            stop()
            continuation.resume(returning: Watch(begun: begun, poolRan: poolRan))
        }
        watcher.name = "vx933.watcher"
        watcher.start()
    }
}

@Suite("VX-933 — a client that stops reading never pins the cooperative pool", .serialized)
struct MCPStalledReaderPoolTests {
    /// The SDK's frames: `MCPSocketTransport.send` to clients that stopped
    /// reading, more at once than the pool has threads.
    @Test func framesToClientsThatStoppedReadingHoldNoPoolThread() async throws {
        let count = stalledCount
        let answer = Data(repeating: UInt8(ascii: "a"), count: 1 << 20)  // far past any socket buffer
        var transports: [MCPSocketTransport] = []
        var servers: [Int32] = []
        var clients: [Int32] = []
        for _ in 0..<count {
            var pair: [Int32] = [-1, -1]
            try #require(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
            noSigPipe(pair[0])
            let transport = MCPSocketTransport(fd: pair[0])
            try await transport.connect()
            transports.append(transport)
            servers.append(pair[0])
            clients.append(pair[1])
        }
        let sends = transports.map { transport in
            Task.detached { () -> Bool in
                do { try await transport.send(answer); return true } catch { return false }
            }
        }
        let stopping = servers
        let watch = await watchThePool(clients: clients) {
            for fd in stopping { _ = shutdown(fd, SHUT_RDWR) }  // the server's stop (`hangUp`)
        }
        var ended = 0
        for send in sends {
            if await send.value == false { ended += 1 }
        }
        for transport in transports {
            // The stop's `shutdown` ended each reader's `read`: its stream
            // finishes BY ITSELF once its last read has returned, so no read
            // can outlive the close below (VX-318's order).
            for try await _ in await transport.receive() {}
            await transport.disconnect()
        }
        for fd in servers + clients { close(fd) }

        #expect(watch.begun == count,
                "every one of the \(count) frames was being written at once (\(watch.begun) were) — none waited for a thread")
        #expect(watch.poolRan,
                "a task the pool must run ran while \(count) frames were stuck on clients that stopped reading")
        #expect(ended == count, "every stuck frame failed once the connection was stopped (\(ended) of \(count))")
    }

    enum Refusal: String, CaseIterable, Sendable {
        /// VX-396's naming refusal (a `clientInfo.name` holding U+0000) — no store.
        case nullName
        /// A bare connection (no setup key) — the admission's refusal.
        case bareKey
    }

    /// The opening's refusals: `MCPSession.run`'s one-off write before the
    /// transport exists — a refusal echoes the `initialize`'s id, so a client
    /// can make it as large as the opening's line allows, then stop reading.
    @Test(arguments: Refusal.allCases)
    func aRefusalToAClientThatStoppedReadingHoldsNoPoolThread(_ refusal: Refusal) async throws {
        let count = stalledCount
        let database = try AppDatabase.inMemory()
        let operations = withDependencies {
            $0.database = database
            $0.date = DateGenerator { Date() }
            $0.uuid = UUIDGenerator { UUID() }
        } operation: { Operations() }
        // Four times the socket pair's two 8 KiB buffers, so every refusal stalls
        // (the opening reads a byte at a time — a longer id only slows the test).
        let id = String(repeating: "i", count: 64 * 1024)
        var sessions: [MCPSession] = []
        var runs: [Task<Void, Never>] = []
        var clients: [Int32] = []
        for index in 0..<count {
            var pair: [Int32] = [-1, -1]
            try #require(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
            noSigPipe(pair[0])
            noSigPipe(pair[1])
            let session = MCPSession(
                fd: pair[0], database: database, operations: operations, version: "test",
                executor: MCPSerialExecutor(operations: operations), hooks: MCPHostHooks())
            let name = refusal == .nullName ? #"vx933\u0000x"# : "vx933-bare-\(index)"
            let opening = Data(
                (#"{"jsonrpc":"2.0","id":"\#(id)","method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"#
                    + "\n").utf8)
            let client = pair[1]
            Thread { _ = MCPShim.writeAll(client, opening) }.start()  // then it never reads
            sessions.append(session)
            runs.append(Task.detached { await session.run() })
            clients.append(client)
        }
        let stopping = sessions
        let watch = await watchThePool(clients: clients) {
            for session in stopping { session.hangUp() }  // the server's stop
        }
        for run in runs { await run.value }
        for session in sessions { session.closeConnection() }
        for fd in clients { close(fd) }

        #expect(watch.begun == count,
                "\(refusal): every one of the \(count) refusals was being written at once (\(watch.begun) were)")
        #expect(watch.poolRan,
                "\(refusal): a task the pool must run ran while \(count) refusals were stuck on clients that stopped reading")
    }

    /// The guards (green on both sides): moving the writes off the pool changes
    /// no byte and no order. One task's frames to a client that stalls, then
    /// reads, arrive exactly as sent, in sequence; frames sent at once to a
    /// stalled client each arrive whole, once, never interleaved.
    @Test func framesToAClientThatStallsThenReadsArriveWholeAndInOrder() async throws {
        var pair: [Int32] = [-1, -1]
        try #require(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
        noSigPipe(pair[0])
        let transport = MCPSocketTransport(fd: pair[0])
        try await transport.connect()
        let frames = (0..<6).map(Self.frame)

        // One task, in sequence, while the client stalls 300 ms before reading.
        let sequenced = frames.reduce(Data()) { $0 + $1 + Data("\n".utf8) }
        let reading = Self.read(pair[1], count: sequenced.count, after: 0.3)
        var sent = 0
        for frame in frames {
            try await transport.send(frame)
            sent += 1
        }
        #expect(sent == frames.count)
        #expect(await reading.value == sequenced, "every frame whole, in the order it was sent")

        // At once, to a client that has stopped reading; then it reads.
        let together = (6..<12).map(Self.frame)
        let sends = together.map { frame in
            Task.detached { () -> Bool in
                do { try await transport.send(frame); return true } catch { return false }
            }
        }
        let total = together.reduce(0) { $0 + $1.count + 1 }
        let received = await Self.read(pair[1], count: total, after: 0.3).value
        var landed = 0
        for send in sends {
            if await send.value { landed += 1 }
        }
        let lines = received.split(separator: UInt8(ascii: "\n"), omittingEmptySubsequences: false).dropLast()
        #expect(landed == together.count)
        #expect(lines.count == together.count && Set(lines.map { Data($0) }) == Set(together),
                "each frame arrived whole and once, none interleaved (\(lines.count) lines, \(received.count) of \(total) bytes)")

        close(pair[1])  // the client leaves: the reader's read ends and its stream finishes by itself
        for try await _ in await transport.receive() {}
        await transport.disconnect()
        close(pair[0])
    }

    /// The lifetime guard (green on both sides): a session's end never cuts a
    /// frame it had already sent. A `disconnect` (the SDK's, at `server.stop()`)
    /// that arrives while a frame is stuck on a client that stopped reading
    /// waits for that frame — as it did when the write held the transport's
    /// actor — so the client, reading again, gets the frame WHOLE, then the end.
    /// A disconnect that did not wait would shut the socket mid-frame (a torn
    /// line, then EOF).
    @Test func aDisconnectWaitsForAFrameAlreadySent() async throws {
        var pair: [Int32] = [-1, -1]
        try #require(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
        noSigPipe(pair[0])
        let transport = MCPSocketTransport(fd: pair[0])
        try await transport.connect()
        let frame = Self.frame(1_000)
        let sending = Task.detached { () -> Bool in
            do { try await transport.send(frame); return true } catch { return false }
        }
        // The frame is being written (the client holds its first bytes) …
        let client = pair[1]
        for _ in 0..<2_000 where !holdsUnreadBytes(client) { try await Task.sleep(for: .milliseconds(1)) }
        #expect(holdsUnreadBytes(client), "premise: the frame's write has begun")
        // … when the session's end arrives; the client reads again only later.
        let ending = Task.detached { await transport.disconnect() }
        let everything = Self.read(client, count: Int.max, after: 0.3)
        let received = await everything.value
        await ending.value
        #expect(await sending.value, "the frame already sent landed")
        #expect(received == frame + Data("\n".utf8),
                "the client read the whole frame, then the end (\(received.count) of \(frame.count + 1) bytes)")
        close(pair[0])
        close(pair[1])
    }

    /// The close line never lands INSIDE a frame (VX-762's invariant, kept by
    /// the fast road): a frame to a client that stopped reading goes out in
    /// part at once, and its rest waits on the writer — the write lock is free
    /// in between, but the stream is mid-frame. A stop's close line tried
    /// exactly there (the DEBUG probe; the client having read a little, so the
    /// line WOULD fit) is skipped, and the client reads the frame whole with no
    /// line inside it. A line written there would tear the frame.
    @Test func aCloseLineNeverLandsInsideAFrameWhoseRestWaitsOnTheWriter() async throws {
        var pair: [Int32] = [-1, -1]
        try #require(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
        noSigPipe(pair[0])
        let client = pair[1]
        let transport = MCPSocketTransport(fd: pair[0])
        try await transport.connect()
        let closeLine = try #require(MCPCloseLine.line("Variorum closed this connection."))
        let early = LockIsolated(Data())
        let said = LockIsolated<Bool?>(nil)
        await transport.setMidFrameProbeForTesting {
            // The client reads a little (room for the line), then the stop
            // tries its close line — in the gap.
            var buffer = [UInt8](repeating: 0, count: 4_096)
            let n = recv(client, &buffer, buffer.count, MSG_DONTWAIT)
            let read = n > 0 ? Data(buffer[0..<n]) : Data()
            early.withValue { $0.append(read) }
            said.setValue(transport.sayClosing(closeLine))
        }
        let frame = Self.frame(2_000)
        let sending = Task.detached { () -> Bool in
            do { try await transport.send(frame); return true } catch { return false }
        }
        let rest = await Self.read(client, count: frame.count + 1 - 4_096, after: 0.3).value
        #expect(await sending.value, "the frame landed")
        #expect(said.value == false, "the close line was skipped in the mid-frame gap (\(String(describing: said.value)))")
        #expect(early.value.count == 4_096, "premise: the client read 4,096 bytes before the line was tried")
        #expect(early.value + rest == frame + Data("\n".utf8),
                "the client read the frame whole, nothing inside it (\(early.value.count + rest.count) of \(frame.count + 1) bytes)")
        await transport.setMidFrameProbeForTesting(nil)
        close(client)
        for try await _ in await transport.receive() {}
        await transport.disconnect()
        close(pair[0])
    }

    /// The close line NEVER WAITS (VX-762's contract; VX-933's face of it): a
    /// stop says it from the stopping thread — the main thread at her switch —
    /// so to a client that stopped reading after whole frames (its buffer
    /// nearly full, no frame mid-write, the lock free) the line is dropped at
    /// once, never sent into a buffer that cannot take it. `MSG_DONTWAIT` does
    /// not stop such a send from waiting on a Unix-domain socket here, so the
    /// old line blocked its caller until the client read.
    @Test func aCloseLineToAClientThatStoppedReadingNeverWaits() async throws {
        var pair: [Int32] = [-1, -1]
        try #require(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
        noSigPipe(pair[0])
        let client = pair[1]
        let transport = MCPSocketTransport(fd: pair[0])
        try await transport.connect()
        // Whole frames the client never reads: the buffer left with less room
        // than the line needs to go without waiting.
        let filler = Data(repeating: UInt8(ascii: "f"), count: 7_000)
        try await transport.send(filler)
        let closeLine = try #require(MCPCloseLine.line("Variorum closed this connection."))
        let outcome: Bool? = await withCheckedContinuation { continuation in
            let said = LockIsolated<Bool?>(nil)
            let returned = DispatchSemaphore(value: 0)
            Thread {
                said.setValue(transport.sayClosing(closeLine))
                returned.signal()
            }.start()
            Thread {
                let inTime = returned.wait(timeout: .now() + 5) == .success
                if !inTime {
                    // The line is stuck in a send: let the client read, so the
                    // stuck caller is let go (and this pin reports, not hangs).
                    var sink = [UInt8](repeating: 0, count: 64 * 1024)
                    _ = Darwin.read(client, &sink, sink.count)
                    _ = returned.wait(timeout: .now() + 5)
                }
                continuation.resume(returning: inTime ? said.value : nil)
            }.start()
        }
        #expect(outcome != nil, "the close line returned at once — it never waited on a client that stopped reading")
        #expect(outcome == false, "a buffer that cannot take the line whole drops it (\(String(describing: outcome)))")
        close(client)
        for try await _ in await transport.receive() {}
        await transport.disconnect()
        close(pair[0])
    }

    /// A frame the size of a big answer, distinct per index.
    private static func frame(_ index: Int) -> Data {
        Data((#"{"n":\#(index),"pad":""# + String(repeating: "\(index % 10)", count: 100_000 + index) + #""}"#).utf8)
    }

    /// Read `count` bytes from `fd` on a thread of its own, starting `after`
    /// seconds (the client's stall); bounded by the receive timeout.
    private static func read(_ fd: Int32, count: Int, after delay: TimeInterval) -> Task<Data, Never> {
        Task {
            await withCheckedContinuation { continuation in
                Thread {
                    Thread.sleep(forTimeInterval: delay)
                    var timeout = timeval(tv_sec: Int(bound), tv_usec: 0)
                    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
                    var got = Data()
                    var buffer = [UInt8](repeating: 0, count: 64 * 1024)
                    while got.count < count {
                        let n = buffer.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, min($0.count, count - got.count)) }
                        guard n > 0 else { break }
                        got.append(contentsOf: buffer[0..<n])
                    }
                    continuation.resume(returning: got)
                }.start()
            }
        }
    }
}
