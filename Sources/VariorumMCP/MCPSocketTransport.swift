import Darwin
import Foundation
import Logging
import MCP
import VariorumMCPSocket

/// **THE TRANSPORT** (13n-b U1, A-3): one accepted socket connection as an
/// MCP `Transport`. The framing IS the stdio transport's — newline-delimited
/// JSON-RPC — because the shim forwards a client's stdio verbatim; this reads
/// the socket with BLOCKING reads on its own thread (no polling) and caps an
/// unterminated line (a local process cannot grow the app's memory without
/// bound by never sending a newline — the connection ends instead). The fd
/// carries `SO_NOSIGPIPE` (set at accept): a client that vanishes mid-write
/// costs this session an error, never the app its life.
///
/// VX-168: the session's handshake has already read the connection's opening
/// (the preamble and the first frame — `MCPHandshake`); that frame is REPLAYED
/// as the stream's first line, so the SDK reads the connection whole.
///
/// **VX-933 (the VX-940 run, W4): no write ever WAITS on the cooperative
/// pool.** A blocking write returns only once the client has read enough; on
/// this actor it held a pool thread for as long, so clients that stopped
/// reading (more of them than the Mac has cores — the host serves sixteen)
/// stopped every task in the app. Now a frame takes THE FAST ROAD while
/// nothing of this connection waits on the writer: written here at once, in
/// steps the socket is known to take without waiting (`writeWithoutWaiting`)
/// — the old timing, for a client that reads. Only what the socket will not
/// take NOW (a stalled client's frame) goes to the connection's own serial
/// writer (`writer`), handed over in this actor's order before it suspends,
/// the caller waiting suspended. So the bytes, their order, the errors, the
/// timing of a reading client's frames and the session's lifetime are as
/// before: a `disconnect` still runs only after every write handed over
/// before it has ended (`drained`), as it did when those writes held this
/// actor; and a frame whose rest waits on the writer counts as mid-write for
/// the close line (`frameGate`).
actor MCPSocketTransport: Transport {
    /// The longest line accepted (a message bigger than this ends the
    /// connection). Generous for any document the read tools return in
    /// reverse; a request this size is not one an honest client sends.
    /// VX-184 U1: EXACT — a line of `lineCap` bytes is served, one byte more
    /// is over, however the stream arrives — and an over-cap message is
    /// ANSWERED (one error on `id: null`) before the connection ends.
    static let lineCap = 16 * 1024 * 1024

    nonisolated let logger: Logger
    private let fd: Int32
    private var isConnected = false
    private let stream: AsyncThrowingStream<Data, Swift.Error>
    private let continuation: AsyncThrowingStream<Data, Swift.Error>.Continuation
    /// Lines read before the transport existed, yielded first (VX-168).
    private let replay: [Data]
    /// VX-394 (VX-348 U5): the read ended on a message past the cap (answered,
    /// then closed) — the session's end line says so.
    private(set) var endedOverLimit = false
    /// **VX-762 (B2 part two, A-771-3): every write to the socket holds this
    /// lock** — the SDK's frames (`send`), the over-cap answer, and the close
    /// line (`sayClosing`) — so no line is ever written into the middle of a
    /// frame. Uncontended except at a stop.
    nonisolated let writeLock = NSLock()
    /// **VX-933: the connection's writer** — a SERIAL queue of its own (it
    /// targets the overcommit root queue, never the cooperative pool's width),
    /// so a client that stops reading parks this queue's thread, never a pool
    /// thread, and the writes keep the order this actor handed them over in.
    /// One per connection: one stalled client never delays another
    /// connection's writes. (The host's announce loops, which await each
    /// session in turn, are their own seam — VX-944.)
    private nonisolated let writer = DispatchQueue(label: "variorum.mcp.writer")
    /// **VX-933: a frame is MID-WRITE while its rest waits on the writer** —
    /// its first bytes went on the fast road and the write lock was let go.
    /// Read and written only under `writeLock`: the close line skips such a
    /// frame exactly as it skips one holding the lock (VX-762's invariant — no
    /// line inside a frame).
    private nonisolated let frameGate = FrameGate()
    /// VX-933: the largest write the socket takes without waiting once it
    /// polls writable — its send low-water mark (`writeStep`).
    private nonisolated let step: Int
    final class FrameGate: @unchecked Sendable {
        /// Guarded by the transport's `writeLock`.
        var midFrame = false
    }
    /// VX-933: writes handed to the writer and not yet ended. While any is,
    /// every write goes behind it (never the fast road), so the order holds.
    private var handedOver = 0
    #if DEBUG
    /// TEST-ONLY (VX-933): run in the gap between a frame's first bytes (the
    /// fast road) and its rest's hand-over — the write lock free, the stream
    /// mid-frame — so a pin can try the close line exactly there.
    private var midFrameProbe: (@Sendable () -> Void)?
    func setMidFrameProbeForTesting(_ probe: (@Sendable () -> Void)?) { midFrameProbe = probe }
    #endif

    init(fd: Int32, replay: [Data] = []) {
        self.fd = fd
        self.replay = replay
        self.step = Self.writeStep(fd)
        self.logger = Logger(label: "variorum.mcp.socket", factory: { _ in SwiftLogNoOpLogHandler() })
        var made: AsyncThrowingStream<Data, Swift.Error>.Continuation!
        self.stream = AsyncThrowingStream { made = $0 }
        self.continuation = made
    }

    func connect() async throws {
        guard !isConnected else { return }
        isConnected = true
        let fd = self.fd
        let continuation = self.continuation
        for line in replay { continuation.yield(line) }
        let reader = Thread { [self] in
            let end = MCPSocketTransport.readLines(fd: fd, cap: MCPSocketTransport.lineCap) { line in
                continuation.yield(line)
            }
            if end == .overLimit {
                // VX-184 U1: the over-cap answer goes through THIS actor, so
                // it is serialized with the SDK's own writes (`send`) — never
                // interleaved mid-frame — and it lands before the stream ends
                // (the SDK then stops; the host closes). The wait is bounded:
                // a peer that reads nothing cannot hold this thread.
                let answered = DispatchSemaphore(value: 0)
                Task {
                    await self.answerOverLimit()
                    answered.signal()
                }
                _ = answered.wait(timeout: .now() + 2)
            }
            continuation.finish()
        }
        reader.name = "variorum.mcp.reader"
        reader.start()
    }

    func disconnect() async {
        guard isConnected else { return }
        isConnected = false
        // VX-933: every write handed over before this disconnect ends first —
        // exactly as when those writes ran on this actor and the disconnect
        // waited behind them (a session's end never cuts a frame it had sent).
        await drained()
        // Unblock the reader; the session closes the fd once the loop ends.
        shutdown(fd, SHUT_RDWR)
        continuation.finish()
    }

    func send(_ data: Data) async throws {
        guard isConnected else { throw MCPError.transportError(POSIXError(.ENOTCONN)) }
        var framed = data
        framed.append(UInt8(ascii: "\n"))
        if let failure = await deliver(framed) {
            throw MCPError.transportError(POSIXError(POSIXErrorCode(rawValue: failure) ?? .EIO))
        }
    }

    /// **VX-933 — every write's one road.** While nothing of this connection
    /// waits on the writer and the write lock is free, THE FAST ROAD: as much
    /// as the socket takes now, written here without waiting — for a client
    /// that reads, the whole frame, at the old timing. What the socket will not
    /// take now goes to the writer (`handOver`), the frame marked mid-write
    /// until its rest is written. nil when every byte was written, else the
    /// failing write's `errno`.
    private func deliver(_ bytes: Data) async -> Int32? {
        var rest = bytes
        if handedOver == 0, let road = fastRoad(bytes) {
            switch road {
            case .finished(let failure):
                return failure
            case .rest(let remainder):
                #if DEBUG
                midFrameProbe?()
                #endif
                rest = remainder
            }
        }
        return await handOver(rest)
    }

    /// How the fast road ended: the frame finished there (nil, or the failing
    /// send's `errno`), or its REST still has to be written.
    private enum FastRoad {
        case finished(Int32?)
        case rest(Data)
    }

    /// The fast road itself, synchronous (the lock is held only inside it):
    /// nil when the write lock is not free (a close line, or a pin holding it)
    /// — the writer's road then waits for it, off the pool. A frame that went
    /// out only in part is marked mid-write before the lock is let go.
    private nonisolated func fastRoad(_ bytes: Data) -> FastRoad? {
        guard writeLock.try() else { return nil }
        defer { writeLock.unlock() }
        let now = Self.writeWithoutWaiting(fd, bytes, step: step)
        if now.failure != nil || now.written == bytes.count { return .finished(now.failure) }
        frameGate.midFrame = now.written > 0
        return .rest(bytes.subdata(in: now.written..<bytes.count))
    }

    /// **VX-933 — the writer's road, off the pool.** `bytes` is handed to the
    /// writer BEFORE this actor suspends (the continuation's body runs at
    /// once), so writes go out in the order this actor took them; the caller
    /// then waits SUSPENDED, holding no thread. The writer writes under the
    /// lock and ends any mid-write mark (the writes are FIFO, so a frame's rest
    /// is the first thing behind its fast-road start). nil when every byte was
    /// written, else the write's `errno` (read on the writing thread, where it
    /// was set).
    private func handOver(_ bytes: Data) async -> Int32? {
        handedOver += 1
        defer { handedOver -= 1 }
        let fd = self.fd
        let lock = writeLock
        let gate = frameGate
        return await withCheckedContinuation { finished in
            writer.async {
                let failure: Int32? = lock.withLock {
                    let failure = Self.writeAll(fd, bytes) ? nil : errno
                    gate.midFrame = false
                    return failure
                }
                finished.resume(returning: failure)
            }
        }
    }

    /// Every write handed over so far has ended (the serial writer reached
    /// this point).
    private func drained() async {
        await withCheckedContinuation { reached in writer.async { reached.resume() } }
    }

    func receive() -> AsyncThrowingStream<Data, Swift.Error> { stream }

    /// The over-cap answer (VX-184 U1 — the record's "Over-cap answers"): the
    /// overrun message's id cannot be read, so it rides `id: null`, in the
    /// door's refusal shape, naming the cap.
    private func answerOverLimit() async {
        endedOverLimit = true
        guard isConnected else { return }
        let sentence = MCPHandshake.overLimitRefusal(limit: Self.lineCap, beforeInitialize: false)
        // VX-933: the one write road, behind any frame already handed over.
        _ = await deliver(MCPShim.refusalResponse(toFirstLine: Data(), message: sentence))
    }

    /// **The close line, as the connection ends** (VX-762 — B2 part two,
    /// A-771-3): written by the session's hang-up just before its shutdown,
    /// from whatever thread stops the server — so it NEVER WAITS: the write
    /// lock is only TRIED (a frame mid-write keeps it, and the line is skipped),
    /// and the line goes only when the socket takes it WHOLE without waiting
    /// (else it is dropped — a client that stopped reading left it no room).
    /// The shim honours only a COMPLETE close line, so a miss falls back to its
    /// own sentence. True when the whole line was written.
    ///
    /// VX-933: `MSG_DONTWAIT` does NOT keep a send on a Unix-domain stream
    /// socket from waiting on this macOS (probed: a send to a full buffer
    /// blocks with it set), so the line once BLOCKED its caller — the stop's
    /// thread, the main thread at her switch — until a stalled client read.
    /// So for its one write the socket's send low-water mark is set to the
    /// line's length (never above the mark it had: the line is no longer than
    /// `step`). XNU's send waits only while the free space is below both the
    /// write's length and the mark — here both the line's length — and the
    /// socket polls writable only while that space is at least the mark; so
    /// the line goes exactly when the socket can take it whole, however much
    /// less room that is than the 2,048 bytes a frame's step needs (the VX-940
    /// ladder's F-R1-1), and it never waits. The mark is restored on every
    /// path BEFORE the lock is let go, so no other write ever meets it, and
    /// `step` (the fast road's cached value) never changes; a restore fails
    /// only on a socket shut both ways, which fails every send at once
    /// (probed). A mark that cannot be read or set leaves the step-gated
    /// write: the line goes only while the socket polls writable at its own
    /// mark. A frame whose rest waits on the writer is mid-write too.
    nonisolated func sayClosing(_ line: Data) -> Bool {
        guard writeLock.try() else { return false }
        defer { writeLock.unlock() }
        guard !frameGate.midFrame, line.count <= step else { return false }
        guard let mark = Self.sendLowWater(fd), Self.setSendLowWater(fd, line.count) else {
            let now = Self.writeWithoutWaiting(fd, line, step: step)
            return now.failure == nil && now.written == line.count
        }
        defer { _ = Self.setSendLowWater(fd, mark) }  // declared after the unlock's, so it runs first
        let now = Self.writeWithoutWaiting(fd, line, step: line.count)
        return now.failure == nil && now.written == line.count
    }

    // MARK: - The blocking halves (pure over a descriptor — pinned headless)

    /// How a read loop ended.
    enum ReadEnd: Equatable, Sendable {
        /// EOF or an error.
        case closed
        /// A line ran past the cap.
        case overLimit
    }

    /// Read until EOF or error, yielding each complete non-empty line; a line
    /// longer than `cap` ends the read. VX-184 U1: the cap is EXACT — a
    /// complete line is measured too, so one whose newline arrives in the same
    /// read as its overflowing bytes is over (pre-fix it was yielded whole) —
    /// and only the NEW bytes of each read are scanned for a newline, so the
    /// cost is linear in the stream (pre-fix every read re-scanned the whole
    /// pending line: a 16 MiB message arriving ~8 KiB at a time was ~16 GB of
    /// comparisons — never served in practice).
    @discardableResult
    static func readLines(fd: Int32, cap: Int, yield: (Data) -> Void) -> ReadEnd {
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        var pending = Data()
        while true {
            let count = buffer.withUnsafeMutableBytes { read(fd, $0.baseAddress, $0.count) }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else { return .closed }
            var start = 0
            while let newline = buffer[start..<count].firstIndex(of: UInt8(ascii: "\n")) {
                guard pending.count + (newline - start) <= cap else { return .overLimit }
                pending.append(contentsOf: buffer[start..<newline])
                if !pending.isEmpty { yield(pending) }
                pending = Data()
                start = newline + 1
            }
            pending.append(contentsOf: buffer[start..<count])
            if pending.count > cap { return .overLimit }
        }
    }

    /// **VX-933 — a one-off write before the transport exists** (the opening's
    /// refusals, `MCPSession.run`): `writeAll` on a thread of its own — the
    /// handshake's idiom (`MCPHandshake.openingOutcome`) — the caller waiting
    /// suspended, so a client that stopped reading holds that thread, never a
    /// cooperative-pool one. A refusal echoes the `initialize`'s id, so it can
    /// be as long as the opening's line. Same bytes, same verdict.
    static func writeAllOffPool(_ fd: Int32, _ data: Data) async -> Bool {
        // The fast road first: a client that reads takes it all at once.
        let now = writeWithoutWaiting(fd, data, step: writeStep(fd))
        if now.failure != nil { return false }
        if now.written == data.count { return true }
        let rest = data.subdata(in: now.written..<data.count)
        return await withCheckedContinuation { finished in
            let writer = Thread { finished.resume(returning: writeAll(fd, rest)) }
            writer.name = "variorum.mcp.opening-writer"
            writer.start()
        }
    }

    /// **VX-933 — the fast road's write:** as much of `data` as the socket
    /// takes NOW, never waiting. A blocking send of `n` bytes waits only while
    /// the socket's free space is below BOTH `n` and its send low-water mark,
    /// and the socket polls writable only while that space is at least the
    /// mark — so each step polls (`poll`, timeout 0) and, writable, sends at
    /// most `step` (the mark) bytes; not writable, it stops. Only writes made
    /// under the write lock reach this socket meanwhile, and a client's reads
    /// only add space. (`MSG_DONTWAIT` is no such guarantee on a Unix-domain
    /// stream socket here — `sayClosing`'s doc.) Answers how many bytes went
    /// and, when a send FAILED, its `errno` — nil when it wrote everything or
    /// stopped only because the socket would wait.
    static func writeWithoutWaiting(_ fd: Int32, _ data: Data, step: Int) -> (written: Int, failure: Int32?) {
        data.withUnsafeBytes { raw in
            var offset = 0
            while offset < raw.count {
                var ready = pollfd(fd: fd, events: Int16(POLLOUT), revents: 0)
                let polled = poll(&ready, 1, 0)
                if polled < 0, errno == EINTR { continue }
                guard polled > 0, ready.revents & Int16(POLLOUT | POLLHUP | POLLERR) != 0 else { return (offset, nil) }
                let sent = Darwin.send(fd, raw.baseAddress! + offset, min(step, raw.count - offset), 0)
                if sent > 0 {
                    offset += sent
                    continue
                }
                if sent < 0, errno == EINTR { continue }
                return (offset, sent < 0 ? errno : EIO)
            }
            return (offset, nil)
        }
    }

    /// The step `writeWithoutWaiting` may send once the socket polls writable:
    /// its send low-water mark (2,048 bytes by default), at least one byte.
    static func writeStep(_ fd: Int32) -> Int {
        guard let mark = sendLowWater(fd), mark > 0 else { return 1 }
        return mark
    }

    /// The socket's send low-water mark now, nil when it cannot be read.
    static func sendLowWater(_ fd: Int32) -> Int? {
        var mark: Int32 = 0
        var size = socklen_t(MemoryLayout<Int32>.size)
        guard getsockopt(fd, SOL_SOCKET, SO_SNDLOWAT, &mark, &size) == 0 else { return nil }
        return Int(mark)
    }

    /// Sets the socket's send low-water mark (VX-933, `sayClosing`'s one
    /// write): true when it took. XNU refuses zero, a negative mark, and any
    /// option once the socket is shut both ways (`EINVAL`).
    static func setSendLowWater(_ fd: Int32, _ bytes: Int) -> Bool {
        var mark = Int32(clamping: bytes)
        return setsockopt(fd, SOL_SOCKET, SO_SNDLOWAT, &mark, socklen_t(MemoryLayout<Int32>.size)) == 0
    }

    static func writeAll(_ fd: Int32, _ data: Data) -> Bool {
        var offset = 0
        return data.withUnsafeBytes { raw -> Bool in
            while offset < raw.count {
                let written = write(fd, raw.baseAddress! + offset, raw.count - offset)
                if written < 0, errno == EINTR { continue }
                guard written > 0 else { return false }
                offset += written
            }
            return true
        }
    }
}
