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

    init(fd: Int32, replay: [Data] = []) {
        self.fd = fd
        self.replay = replay
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
        // Unblock the reader; the session closes the fd once the loop ends.
        shutdown(fd, SHUT_RDWR)
        continuation.finish()
    }

    func send(_ data: Data) async throws {
        guard isConnected else { throw MCPError.transportError(POSIXError(.ENOTCONN)) }
        var framed = data
        framed.append(UInt8(ascii: "\n"))
        guard MCPSocketTransport.writeAll(fd, framed) else {
            throw MCPError.transportError(POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO))
        }
    }

    func receive() -> AsyncThrowingStream<Data, Swift.Error> { stream }

    /// The over-cap answer (VX-184 U1 — the record's "Over-cap answers"): the
    /// overrun message's id cannot be read, so it rides `id: null`, in the
    /// door's refusal shape, naming the cap.
    private func answerOverLimit() {
        endedOverLimit = true
        guard isConnected else { return }
        let sentence = MCPHandshake.overLimitRefusal(limit: Self.lineCap, beforeInitialize: false)
        _ = Self.writeAll(fd, MCPShim.refusalResponse(toFirstLine: Data(), message: sentence))
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
