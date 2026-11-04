import Darwin
import Foundation

/// **THE `variorum-mcp` SHIM's behaviour** (13n-b U1 — A-2: an MCP-blind
/// byte pump; VX-168 amended A-2's "protocol-blind" to "MCP-blind"). An MCP
/// client launches the shim over stdio; the shim finds its own app's socket,
/// connects, speaks its SETUP KEY as one preamble line when its environment
/// carries one (`MCPPreamble` — VX-168, K2), and then copies bytes both ways
/// VERBATIM until the app hangs up — newline-delimited JSON-RPC passes through
/// untouched, so the shim never learns MCP (A-3: the socket's framing IS
/// stdio's). A shim with no key sends no preamble; the app refuses it with
/// one honest JSON-RPC error answering the client's `initialize`.
///
/// When the socket cannot be reached it speaks ONE honest JSON-RPC error to
/// the client's `initialize` and exits: "Variorum must be open" when nothing
/// is listening (R-13n-3), its own line when macOS blocks the connection
/// (AF-1). VX-181: it reads the client's stdin through the SAME pre-initialize
/// window the app's handshake reads (`MCPOpeningWindow` — VX-180), so a probe
/// sent ahead of the `initialize` (Claude Code 2.1.296's `server/discover`) is
/// answered as the open app answers it and the sentence lands on the
/// `initialize`'s id — the request a client reports. It holds no store, no key
/// and no grant — the app is the one process that ever touches the library.
public enum MCPShim {
    /// What a run ended as.
    public enum Outcome: Equatable, Sendable {
        /// Connected; pumped until one side closed.
        case pumped
        /// Could not connect; the refusal was written.
        case refused(MCPSocketRoad.ConnectFailure)
        /// Not inside an app bundle; the refusal was written.
        case notInsideApp
    }

    /// The JSON-RPC error code the shim's refusals carry (the server-error
    /// range JSON-RPC reserves for implementations).
    public static let refusalCode = -32000

    /// **The whole shim.** Blocks until the session ends. `environment` is
    /// the process's own (VX-168: where a setup put its key).
    public static func run(
        executable: URL, home: String?,
        environment: [String: String] = ProcessInfo.processInfo.environment,
        input: Int32 = STDIN_FILENO, output: Int32 = STDOUT_FILENO, errorOutput: Int32 = STDERR_FILENO
    ) -> Outcome {
        guard let bundleID = MCPSocketRoad.bundleIdentifier(ofAppContaining: executable), let home else {
            respondToFirstRequest(input: input, output: output, message: notInsideAppMessage(executable))
            return .notInsideApp
        }
        let directory = MCPSocketRoad.containerDataDirectory(bundleIdentifier: bundleID, realHome: home)
        switch MCPSocketRoad.connect(directory: directory) {
        case .success(let socket):
            serve(socket: socket, environment: environment, input: input, output: output, errorOutput: errorOutput)
            close(socket)
            return .pumped
        case .failure(let failure):
            respondToFirstRequest(input: input, output: output, message: refusalMessage(failure))
            return .refused(failure)
        }
    }

    // MARK: - The words (the client reads them; technical register — P-13n-1)

    public static func refusalMessage(_ failure: MCPSocketRoad.ConnectFailure) -> String {
        switch failure {
        case .notRunning:
            return "Variorum must be open: its MCP server is not running. Open Variorum, turn on "
                + "Settings \u{25B8} MCP \u{25B8} Enable the MCP server, then reconnect."
        case .blocked(let code):
            return "macOS refused the connection to Variorum's MCP socket (\(describe(code))). "
                + "Variorum may be running; this process was not allowed to reach it."
        case .pathTooLong(let bytes):
            return "Variorum's MCP socket path is \(bytes) bytes long; macOS allows "
                + "\(MCPSocketRoad.maxPathBytes). This account's home path is too long for the door."
        case .other(let code):
            return "Couldn't reach Variorum's MCP socket (\(describe(code)))."
        }
    }

    public static func notInsideAppMessage(_ executable: URL) -> String {
        "variorum-mcp must run from inside Variorum.app (Contents/MacOS); it was started from "
            + "\(executable.path)."
    }

    /// **VX-762 (B2, PROVISIONAL P-771-3 — the VX-771 run's batch 4): the app
    /// ended the connection.** The ONE line the shim writes on stderr when the
    /// APP ends the socket while the client is still there (`pump`) — the
    /// client otherwise sees only that its server exited ("MCP server
    /// disconnected"), with nothing saying Variorum did it or what to do. A
    /// stdio client keeps a server's stderr as its log (Claude Code's MCP
    /// logs), never as protocol. Provider-neutral beyond the command (O-4's net
    /// bans names, not "/mcp" — VX-640). Her copy pass owns the words.
    public static let appClosedMessage = "Variorum closed the connection — reconnect with /mcp once it's back."

    private static func describe(_ code: Int32) -> String {
        "\(String(cString: strerror(code))), errno \(code)"
    }

    // MARK: - The refusal on the wire

    /// The JSON-RPC error answering the client's first message: its `id`
    /// echoed when it carried one (a request), `null` otherwise. VX-181 (the
    /// VX-180 ladder's NIT 1): "an id it may echo" is
    /// `MCPOpeningWindow.isEchoableID` — the window's own rule, one predicate.
    public static func refusalResponse(toFirstLine line: Data, message: String) -> Data {
        var id: Any = NSNull()
        if let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any],
           let requestID = object["id"], MCPOpeningWindow.isEchoableID(requestID) {
            id = requestID
        }
        let response: [String: Any] = [
            "jsonrpc": "2.0",
            "id": id,
            "error": ["code": refusalCode, "message": message],
        ]
        let data = (try? JSONSerialization.data(withJSONObject: response, options: [.sortedKeys]))
            ?? Data(#"{"jsonrpc":"2.0","id":null,"error":{"code":-32000,"message":"Variorum must be open."}}"#.utf8)
        return data + Data("\n".utf8)
    }

    /// Read the client's opening through the pre-initialize window
    /// (`MCPOpeningWindow` — VX-181: its requests answered on their own ids,
    /// its notifications skipped, bounded), then answer the frame that ends
    /// it — the `initialize` — with the refusal. A connection that ends or
    /// overruns the line limit first hears the refusal on `id: null` (the
    /// pre-VX-181 shim's answer to an unreadable first line).
    static func respondToFirstRequest(input: Int32, output: Int32, message: String) {
        let frame: Data
        switch MCPOpeningWindow.read(from: input, answeringOn: output) {
        case .frame(let opening): frame = opening
        case .ended, .overLimit: frame = Data()
        }
        writeAll(output, refusalResponse(toFirstLine: frame, message: message))
    }

    /// Public besides the shim's own use: the app's over-cap refusal (round 1
    /// F7) reads a refused connection's first request the same bounded way.
    public static func readFirstLine(_ fd: Int32, limit: Int) -> Data {
        var line = Data()
        var byte: UInt8 = 0
        while line.count < limit {
            let count = read(fd, &byte, 1)
            if count < 0, errno == EINTR { continue }
            guard count == 1 else { break }
            if byte == UInt8(ascii: "\n") { break }
            line.append(byte)
        }
        return line
    }

    // MARK: - The connected shim (VX-168)

    /// Connected: the preamble first (when the environment carries a key —
    /// one line, never parsed by anyone but the app), then the pump. A bare
    /// shim writes nothing of its own.
    public static func serve(
        socket: Int32, environment: [String: String], input: Int32, output: Int32,
        errorOutput: Int32 = STDERR_FILENO
    ) {
        if let key = MCPPreamble.key(inEnvironment: environment) {
            writeAll(socket, MCPPreamble.line(key: key))
        }
        pump(input: input, output: output, socket: socket, errorOutput: errorOutput)
    }

    // MARK: - The pump

    /// Copy `input` → `socket` on a helper thread and `socket` → `output` on
    /// this one, verbatim, until the socket closes. The client hanging up
    /// (EOF on `input`) half-closes the socket so the app sees the session
    /// end; the app hanging up ends the run.
    ///
    /// **VX-762 (B2): the app's end is said.** When the downstream ends on the
    /// SOCKET's side (EOF or a read error) and the client's input had not ended
    /// first, the app ended the connection: ONE line on `errorOutput`
    /// (`appClosedMessage`). The client's own end says nothing — its input's
    /// EOF is marked before the half-close, so the app's answering close always
    /// finds the mark — and neither does a failed write to `output` (the client
    /// is gone). Only the input's own end marks it: a write to the socket that
    /// fails is the app's close seen from the upstream side.
    ///
    /// **B2 part two (A-771-3): the app's own words, when it said why.** The
    /// downstream is a `relay`: every byte relayed verbatim and at once, except
    /// a line opening with `MCPCloseLine.marker`, which never reaches `output`;
    /// the stderr line is then the latest complete close line's words, else
    /// `appClosedMessage` (none came, it could not be said, or the stream ended
    /// inside one). Still ONE line per drop.
    public static func pump(input: Int32, output: Int32, socket: Int32, errorOutput: Int32 = STDERR_FILENO) {
        pump(input: input, output: output, socket: socket, errorOutput: errorOutput, onUpstreamEnd: nil)
    }

    /// The pump, with a TEST seam: `onUpstreamEnd` runs after the upstream
    /// thread's last act (its half-close), so a test can close the socket only
    /// once nothing can touch its number again (VX-132's straggler lesson — the
    /// upstream outlives the run whenever the app ends first).
    static func pump(
        input: Int32, output: Int32, socket: Int32, errorOutput: Int32,
        onUpstreamEnd: (@Sendable () -> Void)?
    ) {
        let clientEnded = ClientEnd()
        let upstream = Thread {
            if copy(from: input, to: socket) == .sourceEnded { clientEnded.mark() }
            shutdown(socket, SHUT_WR)
            onUpstreamEnd?()
        }
        upstream.start()
        let downstream = relay(from: socket, to: output)
        if downstream.end == .sourceEnded, !clientEnded.isMarked {
            writeAll(errorOutput, Data(((downstream.closingWords ?? appClosedMessage) + "\n").utf8))
        }
    }

    /// **The downstream** (VX-762, B2 part two): `copy`'s loop — the same reads,
    /// each relayed at once — with the close line kept off `destination`
    /// (`MCPCloseLine.Relay`). How it ended, and what the app said about it.
    static func relay(from source: Int32, to destination: Int32) -> (end: CopyEnd, closingWords: String?) {
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        var state = MCPCloseLine.Relay()
        while true {
            let count = buffer.withUnsafeMutableBytes { read(source, $0.baseAddress, $0.count) }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else { return (.sourceEnded, state.closingWords) }
            let spans = buffer.withUnsafeBufferPointer { state.take(UnsafeBufferPointer(rebasing: $0[0..<count])) }
            for span in spans where !span.isEmpty {
                guard writeAll(destination, Data(buffer[span])) else { return (.destinationFailed, nil) }
            }
        }
    }

    /// How a `copy` loop ended.
    enum CopyEnd: Equatable, Sendable {
        /// The source's read ended — EOF, or an error.
        case sourceEnded
        /// A write to the destination failed.
        case destinationFailed
    }

    /// "The client's input ended" — set by the upstream thread, read by the
    /// downstream one (VX-762).
    private final class ClientEnd: @unchecked Sendable {
        private let lock = NSLock()
        private var marked = false
        func mark() { lock.withLock { marked = true } }
        var isMarked: Bool { lock.withLock { marked } }
    }

    @discardableResult
    static func copy(from source: Int32, to destination: Int32) -> CopyEnd {
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        while true {
            let count = buffer.withUnsafeMutableBytes { read(source, $0.baseAddress, $0.count) }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else { return .sourceEnded }
            guard writeAll(destination, Data(buffer[0..<count])) else { return .destinationFailed }
        }
    }

    @discardableResult
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
