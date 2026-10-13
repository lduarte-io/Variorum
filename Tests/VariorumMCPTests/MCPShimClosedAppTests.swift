import Darwin
import Foundation
import Testing

@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-181 — THE SHIM WITH THE APP CLOSED answers Claude Code's probe AND its
// initialize (the run record `notes/plans/fixes/vx-184-mcp-launch-polish.md`,
// U1 — "VX-181 — the trace"; seen live in VX-180's round). The shim, run from
// an app bundle whose container holds no socket, reads the client's stdin
// through the SAME pre-initialize window the app's handshake reads (VX-180), so
// its honest "Variorum must be open" lands on the `initialize`'s id — the
// request a client reports — never on a probe's. Each pin drives only
// `MCPShim.run`, so it COMPILES on the pre-fix tree, where it was watched RED
// (the record's piece 4).

/// A shim inside a throwaway `Variorum.app` whose container (under a throwaway
/// home) has no socket: every connect fails ENOENT — "Variorum must be open".
private struct ClosedApp {
    let root: URL
    let shim: URL
    let home: String

    init() throws {
        root = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("vx181-\(UUID().uuidString.prefix(8))", isDirectory: true)
        let contents = root.appendingPathComponent("Variorum.app/Contents", isDirectory: true)
        try FileManager.default.createDirectory(
            at: contents.appendingPathComponent("MacOS"), withIntermediateDirectories: true)
        let plist = try PropertyListSerialization.data(
            fromPropertyList: ["CFBundleIdentifier": "io.lduarte.Variorum.vx181"], format: .xml, options: 0)
        try plist.write(to: contents.appendingPathComponent("Info.plist"))
        shim = contents.appendingPathComponent("MacOS/variorum-mcp")
        // A SHORT home that does not exist (the socket path must fit the
        // 103 bytes `sockaddr_un` holds, or the shim says `pathTooLong`):
        // the connect fails ENOENT — exactly Variorum closed.
        home = "/tmp/vx181-\(UUID().uuidString.prefix(8))-absent"
    }

    func remove() { try? FileManager.default.removeItem(at: root) }
}

/// A stream pair standing in for the client's stdio (sockets, so every read
/// is bounded and no write can raise SIGPIPE): the test writes `stdin`'s
/// near end and reads `stdout`'s.
private struct ClientStdio {
    let stdinNear: Int32, stdinFar: Int32, stdoutNear: Int32, stdoutFar: Int32

    init() throws {
        var a: [Int32] = [-1, -1], b: [Int32] = [-1, -1]
        guard socketpair(AF_UNIX, SOCK_STREAM, 0, &a) == 0, socketpair(AF_UNIX, SOCK_STREAM, 0, &b) == 0 else {
            throw HarnessFailure("socketpair")
        }
        for fd in a + b { MCPSocketRoad.suppressSIGPIPE(fd) }
        (stdinNear, stdinFar, stdoutNear, stdoutFar) = (a[0], a[1], b[0], b[1])
        var timeout = timeval(tv_sec: 5, tv_usec: 0)
        _ = setsockopt(stdoutNear, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    }

    func write(_ lines: String...) {
        _ = MCPShim.writeAll(stdinNear, Data(lines.map { $0 + "\n" }.joined().utf8))
    }

    /// The shim's next line as JSON (nil at EOF or the bound).
    func next() -> [String: Any]? {
        let line = MCPShim.readFirstLine(stdoutNear, limit: 1 << 20)
        guard !line.isEmpty else { return nil }
        return try? JSONSerialization.jsonObject(with: line) as? [String: Any]
    }

    func closeAll() { for fd in [stdinNear, stdinFar, stdoutNear, stdoutFar] { close(fd) } }
}

private func code(_ answer: [String: Any]?) -> Int? { (answer?["error"] as? [String: Any])?["code"] as? Int }
private func message(_ answer: [String: Any]?) -> String? {
    (answer?["error"] as? [String: Any])?["message"] as? String
}

@Suite("VX-181 — with Variorum closed, the shim's sentence answers the initialize", .serialized)
struct MCPShimClosedAppTests {
    /// Run the shim on its own thread (it blocks on stdin like the real one)
    /// and hand back its outcome once it exits.
    private func runShim(_ app: ClosedApp, _ io: ClientStdio) -> () -> MCPShim.Outcome? {
        let outcome = LockIsolatedBox<MCPShim.Outcome?>(nil)
        let done = DispatchSemaphore(value: 0)
        let (shim, home, input, output) = (app.shim, app.home, io.stdinFar, io.stdoutFar)
        Thread {
            outcome.set(MCPShim.run(executable: shim, home: home, environment: [:], input: input, output: output))
            done.signal()
        }.start()
        return {
            _ = done.wait(timeout: .now() + 10)
            return outcome.get()
        }
    }

    /// THE PIN: Claude Code's captured pair, PIPELINED — the probe answered
    /// `-32601` on its string id, then "Variorum must be open" on the
    /// initialize's id 0. Pre-fix: the sentence answered the PROBE and the
    /// initialize was never answered.
    @Test func theClosedAppSentenceAnswersTheInitializePastClaudeCodesProbe() throws {
        let app = try ClosedApp()
        defer { app.remove() }
        let io = try ClientStdio()
        defer { io.closeAll() }
        io.write(CapturedClaudeCode.probe, CapturedClaudeCode.initialize)
        let finished = runShim(app, io)

        let probe = io.next()
        #expect(probe?["id"] as? String == CapturedClaudeCode.probeID, "\(String(describing: probe))")
        #expect(code(probe) == -32601, "the probe hears the window's answer, as the open app answers it")
        let initialize = io.next()
        #expect(initialize?["id"] as? Int == 0, "the sentence answers the initialize: \(String(describing: initialize))")
        #expect(code(initialize) == MCPShim.refusalCode)
        #expect(message(initialize)?.hasPrefix("Variorum must be open") == true)
        #expect(finished() == .refused(.notRunning(errno: ENOENT)))
        #expect(io.next() == nil, "then the shim exits")
    }

    /// A spec-correct client WAITS for the probe's answer before it sends
    /// `initialize`: the shim answers before its next read blocks.
    @Test func aClientThatWaitsForTheProbesAnswerStillHearsTheSentenceOnItsInitialize() throws {
        let app = try ClosedApp()
        defer { app.remove() }
        let io = try ClientStdio()
        defer { io.closeAll() }
        let finished = runShim(app, io)
        io.write(CapturedClaudeCode.probe)
        let probe = io.next()
        #expect(probe?["id"] as? String == CapturedClaudeCode.probeID && code(probe) == -32601,
                "answered while the shim waits for the next frame: \(String(describing: probe))")
        io.write(CapturedClaudeCode.initialize)
        let initialize = io.next()
        #expect(initialize?["id"] as? Int == 0 && message(initialize)?.hasPrefix("Variorum must be open") == true,
                "\(String(describing: initialize))")
        #expect(finished() == .refused(.notRunning(errno: ENOENT)))
    }

    /// A notification is skipped and a ping answered with its empty result
    /// (the open app's window, P-VX180-2); the sentence lands on initialize.
    @Test func aNotificationIsSkippedAndAPingAnsweredBeforeTheSentence() throws {
        let app = try ClosedApp()
        defer { app.remove() }
        let io = try ClientStdio()
        defer { io.closeAll() }
        io.write(#"{"jsonrpc":"2.0","method":"notifications/cancelled","params":{}}"#,
                 #"{"jsonrpc":"2.0","id":"p","method":"ping"}"#,
                 CapturedClaudeCode.initialize)
        let finished = runShim(app, io)
        let ping = io.next()
        #expect(ping?["id"] as? String == "p" && ping?["result"] is [String: Any] && ping?["error"] == nil,
                "\(String(describing: ping))")
        let initialize = io.next()
        #expect(initialize?["id"] as? Int == 0 && code(initialize) == MCPShim.refusalCode,
                "\(String(describing: initialize))")
        #expect(finished() == .refused(.notRunning(errno: ENOENT)))
    }

    /// The window is bounded exactly as the app's: past its limit of
    /// requests, the sentence answers the frame past it (no initialize ever
    /// came) — never an endless read.
    @Test func pastTheWindowsBoundTheSentenceAnswersTheFramePastIt() throws {
        let app = try ClosedApp()
        defer { app.remove() }
        let io = try ClientStdio()
        defer { io.closeAll() }
        let limit = MCPHandshake.preInitializeLimit
        let requests = (0...limit).map { #"{"jsonrpc":"2.0","id":\#(100 + $0),"method":"server/discover"}"# }
        _ = MCPShim.writeAll(io.stdinNear, Data(requests.map { $0 + "\n" }.joined().utf8))
        let finished = runShim(app, io)
        for index in 0..<limit {
            let answer = io.next()
            #expect(answer?["id"] as? Int == 100 + index && code(answer) == -32601, "\(String(describing: answer))")
        }
        let past = io.next()
        #expect(past?["id"] as? Int == 100 + limit && message(past)?.hasPrefix("Variorum must be open") == true,
                "\(String(describing: past))")
        #expect(finished() == .refused(.notRunning(errno: ENOENT)))
    }

    /// A first frame that is no request and no notification ends the window
    /// at once: the sentence answers it by its id (the pre-VX-181 road).
    @Test func aFrameThatIsNoRequestHearsTheSentenceAtOnce() throws {
        let app = try ClosedApp()
        defer { app.remove() }
        let io = try ClientStdio()
        defer { io.closeAll() }
        io.write(#"{"jsonrpc":"2.0","id":5,"result":{}}"#)
        let finished = runShim(app, io)
        let answer = io.next()
        #expect(answer?["id"] as? Int == 5 && message(answer)?.hasPrefix("Variorum must be open") == true)
        #expect(finished() == .refused(.notRunning(errno: ENOENT)))
    }
}

/// A value one thread sets and another reads.
private final class LockIsolatedBox<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: Value
    init(_ value: Value) { self.value = value }
    func set(_ newValue: Value) { lock.withLock { value = newValue } }
    func get() -> Value { lock.withLock { value } }
}
