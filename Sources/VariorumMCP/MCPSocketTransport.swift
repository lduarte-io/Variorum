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
actor MCPSocketTransport: Transport {
    /// The longest line accepted (a message bigger than this ends the
    /// connection). Generous for any document the read tools return in
    /// reverse; a request this size is not one an honest client sends.
    static let lineCap = 16 * 1024 * 1024

    nonisolated let logger: Logger
    private let fd: Int32
    private var isConnected = false
    private let stream: AsyncThrowingStream<Data, Swift.Error>
    private let continuation: AsyncThrowingStream<Data, Swift.Error>.Continuation

    init(fd: Int32) {
        self.fd = fd
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
        let reader = Thread {
            MCPSocketTransport.readLines(fd: fd, cap: MCPSocketTransport.lineCap) { line in
                continuation.yield(line)
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

    // MARK: - The blocking halves (pure over a descriptor — pinned headless)

    /// Read until EOF or error, yielding each complete non-empty line; a line
    /// longer than `cap` ends the read.
    static func readLines(fd: Int32, cap: Int, yield: (Data) -> Void) {
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        var pending = Data()
        while true {
            let count = buffer.withUnsafeMutableBytes { read(fd, $0.baseAddress, $0.count) }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else { return }
            pending.append(contentsOf: buffer[0..<count])
            while let newline = pending.firstIndex(of: UInt8(ascii: "\n")) {
                let line = pending[pending.startIndex..<newline]
                if !line.isEmpty { yield(Data(line)) }
                pending = Data(pending[(newline + 1)...])
            }
            if pending.count > cap { return }
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
