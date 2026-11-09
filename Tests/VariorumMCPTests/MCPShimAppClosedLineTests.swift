import Darwin
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-762 (B2, PROVISIONAL P-771-3 — the VX-771 run, batch 4; the record
// `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`, BATCH 4 RECORD): when the
// APP ends a connection (a lock, her switch, a quit), the client sees only that
// its stdio server exited — "MCP server disconnected" — and nothing says
// Variorum did it or what to do. The shim now says so on stderr, once — and
// says nothing when the client ended first. These pins drive the pump directly
// (a plain SPM target), with pipes for stdin/stdout/stderr.

/// One shim pump over a socketpair: `app` is the app's end. Every descriptor is
/// closed only once nothing can touch it again — the pump's upstream thread
/// outlives the run when the app ends first (VX-132's straggler), so the socket
/// is closed after that thread's own end.
private final class PumpRig: @unchecked Sendable {
    let app: Int32
    private let shimSocket: Int32
    private let input: (read: Int32, write: Int32)
    private let output: (read: Int32, write: Int32)
    private let errors: (read: Int32, write: Int32)
    private let served = DispatchSemaphore(value: 0)
    private let upstreamEnded = DispatchSemaphore(value: 0)
    private var inputClosed = false
    private var appClosed = false

    init() throws {
        var pair: [Int32] = [-1, -1]
        guard socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0 else { throw HarnessFailure("socketpair") }
        MCPSocketRoad.suppressSIGPIPE(pair[0])
        MCPSocketRoad.suppressSIGPIPE(pair[1])
        var timeout = timeval(tv_sec: 10, tv_usec: 0)
        _ = setsockopt(pair[1], SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        var i: [Int32] = [-1, -1], o: [Int32] = [-1, -1], e: [Int32] = [-1, -1]
        guard pipe(&i) == 0, pipe(&o) == 0, pipe(&e) == 0 else { throw HarnessFailure("pipe") }
        (shimSocket, app) = (pair[0], pair[1])
        input = (i[0], i[1])
        output = (o[0], o[1])
        errors = (e[0], e[1])
        let (socket, inputRead, outputWrite, errorWrite) = (shimSocket, input.read, output.write, errors.write)
        let served = self.served
        let upstreamEnded = self.upstreamEnded
        let shim = Thread {
            MCPShim.pump(
                input: inputRead, output: outputWrite, socket: socket, errorOutput: errorWrite,
                onUpstreamEnd: { upstreamEnded.signal() })
            served.signal()
        }
        shim.start()
    }

    /// The app hangs up. A CLOSE, never `shutdown`: once the shim has
    /// half-closed, macOS answers `shutdown` on an AF_UNIX pair with ENOTCONN
    /// and wakes no reader (measured — `MCPShimTests`' VX-132 note).
    func appHangsUp() {
        guard !appClosed else { return }
        appClosed = true
        close(app)
    }

    /// The client writes a line on the shim's stdin.
    func clientSends(_ line: String) { _ = MCPShim.writeAll(input.write, Data((line + "\n").utf8)) }

    /// The client hangs up its stdin.
    func clientCloses() {
        guard !inputClosed else { return }
        inputClosed = true
        close(input.write)
    }

    /// The next line the client reads on the shim's stdout.
    func clientReads() -> Data { MCPShim.readFirstLine(output.read, limit: 1 << 20) }

    /// The shim's run ended (bounded).
    func shimEnded() -> Bool { served.wait(timeout: .now() + 10) == .success }

    /// Everything the shim wrote on stderr — read once its run has ended and its
    /// upstream is done, after which every descriptor closes.
    func finish() -> String {
        clientCloses()
        _ = upstreamEnded.wait(timeout: .now() + 10)
        close(shimSocket)
        close(errors.write)
        var said = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            let count = read(errors.read, &buffer, buffer.count)
            if count < 0, errno == EINTR { continue }
            guard count > 0 else { break }
            said.append(contentsOf: buffer[0..<count])
        }
        close(errors.read)
        close(input.read)
        close(output.read)
        close(output.write)
        appHangsUp()
        return String(decoding: said, as: UTF8.self)
    }
}

@Suite("VX-762 — B2: the shim says on stderr when the app ends the connection", .serialized)
struct MCPShimAppClosedLineTests {
    /// **RED ON OLD** (behavioural revert — the record names it): the app ends the
    /// socket while the client is still there; the shim ends, and its stderr
    /// carries exactly ONE line, the generic sentence. Its stdout carried the
    /// app's frame verbatim before it.
    @Test func whenTheAppEndsTheConnectionTheShimSaysSoOnceOnStderr() throws {
        let rig = try PumpRig()
        let frame = #"{"jsonrpc":"2.0","id":1,"result":{}}"#
        _ = MCPShim.writeAll(rig.app, Data((frame + "\n").utf8))
        let relayed = rig.clientReads()
        #expect(relayed == Data(frame.utf8), "the app's frame reaches the client verbatim")
        rig.appHangsUp()
        let ended = rig.shimEnded()
        #expect(ended, "the shim ends when the app hangs up")
        let said = rig.finish()
        #expect(said == MCPShim.appClosedMessage + "\n", "one line, the generic sentence: \(said.debugDescription)")
    }

    /// GUARD (green on both sides): the CLIENT ends first — its stdin's EOF, the
    /// half-close, the app's answering close — and the shim says nothing.
    @Test func whenTheClientEndsFirstTheShimSaysNothing() throws {
        let rig = try PumpRig()
        rig.clientSends(#"{"jsonrpc":"2.0","id":1,"method":"ping"}"#)
        let heard = MCPShim.readFirstLine(rig.app, limit: 4096)
        #expect(!heard.isEmpty, "the client's line reached the app")
        rig.clientCloses()
        var byte: UInt8 = 0
        let eof = read(rig.app, &byte, 1)
        #expect(eof == 0, "the client's end reaches the app as EOF")
        rig.appHangsUp()
        let ended = rig.shimEnded()
        #expect(ended)
        let said = rig.finish()
        #expect(said.isEmpty, "the client's own end says nothing: \(said.debugDescription)")
    }

    /// The words: one line, no newline inside, the reconnect road named
    /// provider-neutrally (O-4's net bans names, never the command — VX-640).
    @Test func theSentenceIsOneLineAndNamesTheReconnectRoad() {
        let words = MCPShim.appClosedMessage
        #expect(!words.contains("\n"))
        #expect(words.contains("/mcp"))
        #expect(words.hasPrefix("Variorum closed the connection"))
    }

    /// **RED ON OLD** (the same revert): end to end — a real server stops (her
    /// switch OFF) under a live session pumped by the shim; the client's stderr
    /// says the app ended it.
    @Test func aRealServerStopUnderALiveSessionIsSaidOnStderr() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        guard case .success(let socket) = MCPSocketRoad.connect(directory: h.directory) else {
            Issue.record("could not connect")
            return
        }
        var input: [Int32] = [-1, -1], output: [Int32] = [-1, -1], errors: [Int32] = [-1, -1]
        #expect(pipe(&input) == 0 && pipe(&output) == 0 && pipe(&errors) == 0)
        let environment = [MCPPreamble.environmentVariable: try h.setupKey(for: "stderr-test")]
        let (shimInput, shimOutput, shimErrors) = (input[0], output[1], errors[1])
        let served = DispatchSemaphore(value: 0)
        let upstreamEnded = DispatchSemaphore(value: 0)
        let pump = Thread {
            if let key = MCPPreamble.key(inEnvironment: environment) {
                _ = MCPShim.writeAll(socket, MCPPreamble.line(key: key))
            }
            MCPShim.pump(
                input: shimInput, output: shimOutput, socket: socket, errorOutput: shimErrors,
                onUpstreamEnd: { upstreamEnded.signal() })
            served.signal()
        }
        pump.start()
        let initialize = #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"stderr-test","version":"1"}}}"#
        _ = MCPShim.writeAll(input[1], Data((initialize + "\n").utf8))
        let clientReads = output[0]
        // VX-850: off the pool — the session answering through the pump needs a pool thread.
        let answer = await HarnessWait.offPool { MCPShim.readFirstLine(clientReads, limit: 1 << 20) }
        #expect(!answer.isEmpty, "the session answered through the shim")

        h.host.stop(ending: .serverOff)
        // Bounded waits on the pump's own thread — awaited off the pool (a
        // semaphore can't be waited on from an async context).
        let ended = await HarnessWait.offPool { served.wait(timeout: .now() + 10) == .success }
        #expect(ended, "the shim ends with the server")
        close(input[1])
        _ = await HarnessWait.offPool { upstreamEnded.wait(timeout: .now() + 10) == .success }
        close(socket)
        close(errors[1])
        var said = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            let count = read(errors[0], &buffer, buffer.count)
            if count < 0, errno == EINTR { continue }
            guard count > 0 else { break }
            said.append(contentsOf: buffer[0..<count])
        }
        close(errors[0])
        close(input[0])
        close(output[0])
        close(output[1])
        let line = String(decoding: said, as: UTF8.self)
        #expect(line.hasSuffix("\n") && line.dropLast().contains("reconnect with /mcp") && !line.dropLast().contains("\n"),
                "ONE stderr line saying the app closed it: \(line.debugDescription)")
    }
}
