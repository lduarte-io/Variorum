import Darwin
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-180 — THE PRE-INITIALIZE PROBE on the socket road (the kickoff
// `notes/plans/vx-180-kickoff-prompt.md`; the record
// `notes/plans/fixes/vx-180-discover-probe.md`). Claude Code 2.1.296 opens
// every MCP stdio connection by PIPELINING a `server/discover` request ahead
// of its `initialize` (captured on the Air, 2026-10-12 20:19 MDT). The
// pre-fix opening read took the FIRST frame as the initialize: no name, so
// the one refusal answered the probe's id and the host closed — the real
// `initialize`, already in the buffer, was never read (her Activity: "an
// unnamed client was refused connecting without a name"; Claude Code:
// CONNECTION_CLOSED after ~25 ms, on every connection).
//
// These pins drive a real `MCPServerHost` over a real socket with RAW
// JSON-RPC lines (the SDK's own client never probes), through the keyed
// harness (`ServerHarness.setupKey(for:)` — a setup's own key, as the shim's
// preamble speaks it). They use only the pre-fix tree's API, so each one
// COMPILES on the pre-fix tree and was watched RED there (the record's piece
// 1, and again by revert — piece 3).

/// The two frames Claude Code pipelined, as captured (the kickoff file). The
/// capture's elisions (`...` inside `clientInfo`, `{...}` for the capability
/// objects) are dropped to the fields it showed; nothing else is changed —
/// the key order (`method` FIRST in the initialize) and the STRING probe id
/// are the capture's own.
enum CapturedClaudeCode {
    static let probe = #"{"jsonrpc":"2.0","id":"server-discover-probe-1","method":"server/discover","params":{"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientInfo":{"name":"claude-code","title":"Claude Code","version":"2.1.296"},"io.modelcontextprotocol/clientCapabilities":{}}}}"#
    static let initialize = #"{"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"claude-code","version":"2.1.296"}},"jsonrpc":"2.0","id":0}"#
    static let probeID = "server-discover-probe-1"
}

/// A raw line-level client on the server's socket.
struct RawSocket {
    let fd: Int32

    /// Connect, with a bounded receive (a deferred answer must fail a pin,
    /// never hang the suite — the VX-132 class).
    init(_ h: ServerHarness, timeout seconds: Int = 5) throws {
        guard case .success(let fd) = MCPSocketRoad.connect(directory: h.directory) else {
            throw HarnessFailure("could not connect")
        }
        var timeout = timeval(tv_sec: seconds, tv_usec: 0)
        _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        self.fd = fd
    }

    /// Write the lines in ONE write, each newline-framed (pipelined, as
    /// Claude Code sends them); `preamble` first when given.
    func send(preamble key: String? = nil, _ lines: String...) {
        var bytes = key.map(MCPPreamble.line(key:)) ?? Data()
        for line in lines { bytes.append(Data((line + "\n").utf8)) }
        _ = MCPShim.writeAll(fd, bytes)
    }

    /// The next line the server wrote, as JSON; nil at EOF, timeout, or a
    /// line that is not a JSON object.
    func next() -> [String: Any]? {
        let line = MCPShim.readFirstLine(fd, limit: 1 << 20)
        guard !line.isEmpty else { return nil }
        return try? JSONSerialization.jsonObject(with: line) as? [String: Any]
    }

    /// The next RESPONSE (a line carrying an id) — the server's own
    /// notifications (`tools/list_changed` after a grant moves) are skipped.
    func nextResponse() -> [String: Any]? {
        for _ in 0..<16 {
            guard let object = next() else { return nil }
            if object["id"] != nil { return object }
        }
        return nil
    }

    /// After the server's answers: EOF within the receive timeout.
    func isHungUp() -> Bool {
        var byte: UInt8 = 0
        return read(fd, &byte, 1) == 0
    }

    func close() { Darwin.close(fd) }
}

/// The JSON-RPC error object of an answer, flattened for pins.
private func errorOf(_ answer: [String: Any]?) -> (code: Int?, message: String?) {
    let error = answer?["error"] as? [String: Any]
    return (error?["code"] as? Int, error?["message"] as? String)
}

/// Her Activity list's CONNECTION lines.
private func connectionActivity(_ h: ServerHarness) throws -> [String] {
    try h.database.read { db in
        try Row.fetchAll(db, sql: "SELECT client_name, act, outcome FROM mcp_activity WHERE act LIKE 'connect_%' ORDER BY id")
            .map { "\($0["client_name"] as String) \($0["act"] as String) \($0["outcome"] as String)" }
    }
}

@Suite("VX-180 — the pre-initialize probe on the socket road", .serialized)
struct MCPDiscoverProbeServerTests {
    // MARK: - THE PIN: the captured pipelined pair

    /// Claude Code's own opening, replayed byte for byte behind its setup's
    /// key: the probe is answered `-32601` on its STRING id, the pipelined
    /// `initialize` is read, admitted and answered, and the session serves —
    /// `tools/list` lists her grant's tools and a call reads the note. RED ON
    /// THE PRE-FIX TREE: the probe's id heard the setup-key refusal (`-32000`)
    /// and the connection closed with the initialize unanswered.
    @Test func claudeCodesPipelinedProbeIsAnsweredAndItsInitializeServes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            // Her library's state: claude-code set up (its key bound by a
            // first connection) and approved with a grant.
            let note = try h.operations.createPost(title: "a page")
            let first = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            await h.hangUp(first)

            let socket = try RawSocket(h)
            defer { socket.close() }
            socket.send(preamble: try h.setupKey(for: "claude-code"),
                        CapturedClaudeCode.probe, CapturedClaudeCode.initialize)

            let probeAnswer = socket.next()
            #expect(probeAnswer?["id"] as? String == CapturedClaudeCode.probeID,
                    "the probe answered on its own id, a string echoed as a string: \(String(describing: probeAnswer))")
            #expect(errorOf(probeAnswer).code == -32601, "Method not found — never the setup-key refusal")
            #expect(probeAnswer?["result"] == nil)

            let initialized = try #require(socket.nextResponse(), "the pipelined initialize is read and answered")
            #expect(initialized["id"] as? Int == 0)
            let result = try #require(initialized["result"] as? [String: Any], "admitted: \(initialized)")
            #expect((result["serverInfo"] as? [String: Any])?["name"] as? String == VariorumMCP.serverName)
            #expect(result["instructions"] as? String == MCPSession.instructions, "the advice, as ever")

            socket.send(#"{"jsonrpc":"2.0","method":"notifications/initialized"}"#,
                        #"{"jsonrpc":"2.0","id":1,"method":"tools/list"}"#)
            let listed = try #require(socket.nextResponse())
            #expect(listed["id"] as? Int == 1)
            let tools = ((listed["result"] as? [String: Any])?["tools"] as? [[String: Any]])?
                .compactMap { $0["name"] as? String } ?? []
            #expect(tools.contains("read_note"), "tools/list works: \(tools)")

            socket.send(#"{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"read_note","arguments":{"note_id":"\#(note.id)"}}}"#)
            let read = try #require(socket.nextResponse())
            #expect(read["id"] as? Int == 2)
            #expect((read["result"] as? [String: Any])?["isError"] as? Bool != true, "the note is read: \(read)")

            #expect(try await h.eventually { h.host.connectedClientNames == ["claude-code"] })
            #expect(try connectionActivity(h).isEmpty, "no refusal in her Activity — the probe is no client")
        }
    }

    // MARK: - The wire order: a client that WAITS for the probe's answer

    /// A spec-correct client may hold its `initialize` until the probe is
    /// answered. The answer must therefore be written BEFORE the opening read
    /// blocks on the next frame — never batched after the opening completes
    /// (that would deadlock this client until its timeout). The probe, then
    /// a read, then — only then — the initialize. RED ON THE PRE-FIX TREE
    /// (the refusal answered the probe and the socket closed).
    @Test func aClientThatWaitsForTheProbesAnswerHearsItBeforeSendingInitialize() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let key = try h.operations.mintMCPSetupKey()   // a fresh setup: a new connection request
        let socket = try RawSocket(h)
        defer { socket.close() }
        socket.send(preamble: key, CapturedClaudeCode.probe)

        let probeAnswer = socket.next()   // bounded: 5 s
        #expect(probeAnswer?["id"] as? String == CapturedClaudeCode.probeID,
                "answered while the client waits: \(String(describing: probeAnswer))")
        #expect(errorOf(probeAnswer).code == -32601)

        socket.send(CapturedClaudeCode.initialize)
        let initialized = socket.nextResponse()
        #expect(initialized?["id"] as? Int == 0)
        #expect(initialized?["result"] != nil, "admitted as a connection request: \(String(describing: initialized))")
        let client = try await h.database.read { try Queries.mcpClient($0, name: "claude-code") }
        #expect(client?.state == .pending && client?.isSetupBound == true, "K2: the fresh key bound to the request")
    }

    // MARK: - A notification first: skipped, never answered

    /// A notification (no id) before `initialize` gets no answer (JSON-RPC
    /// never answers one) and does not end the window: the first line the
    /// client reads is its initialize's result. RED ON THE PRE-FIX TREE (the
    /// notification was taken as the initialize and refused, id null).
    @Test func aNotificationBeforeInitializeIsSkippedSilently() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let key = try h.operations.mintMCPSetupKey()
        let socket = try RawSocket(h)
        defer { socket.close() }
        socket.send(preamble: key,
                    #"{"jsonrpc":"2.0","method":"notifications/cancelled","params":{"requestId":"server-discover-probe-1","reason":"timeout"}}"#,
                    CapturedClaudeCode.initialize)
        let first = socket.next()
        #expect(first?["id"] as? Int == 0, "the first answer is the initialize's: \(String(describing: first))")
        #expect(first?["result"] != nil)
    }

    // MARK: - A ping first: MCP's one sanctioned pre-initialize request

    /// MCP's lifecycle lets a client ping before `initialize` is answered,
    /// and the ping utility says the receiver MUST answer with an EMPTY
    /// result — what this server's SDK does for a ping before initialize
    /// (P-VX180-2, PROVISIONAL). Answered on its id; the window continues.
    /// RED ON THE PRE-FIX TREE (refused, closed).
    @Test func aPingBeforeInitializeIsAnsweredEmpty() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let key = try h.operations.mintMCPSetupKey()
        let socket = try RawSocket(h)
        defer { socket.close() }
        socket.send(preamble: key, #"{"jsonrpc":"2.0","id":41,"method":"ping"}"#, CapturedClaudeCode.initialize)
        let pong = socket.next()
        #expect(pong?["id"] as? Int == 41, "\(String(describing: pong))")
        #expect((pong?["result"] as? [String: Any])?.isEmpty == true && pong?["error"] == nil)
        let initialized = socket.nextResponse()
        #expect(initialized?["id"] as? Int == 0 && initialized?["result"] != nil)
    }

    // MARK: - Past the session cap: the cap's sentence lands on the initialize

    /// `MCPServerHost.refuseOverCap` reads the connection's opening through
    /// the SAME read, so past the session cap a probe-first client hears the
    /// probe answered and the cap's sentence on ITS INITIALIZE — the request
    /// it reports — never on the probe. RED ON THE PRE-FIX TREE (the cap's
    /// sentence answered the probe's id).
    @Test func pastTheSessionCapTheCapsSentenceAnswersTheInitializeNotTheProbe() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        var held: [Int32] = []
        defer { for fd in held { close(fd) } }
        for index in 0..<MCPServerHost.sessionCap {
            let (fd, answer) = try h.rawOpen(as: "held-\(index)", presenting: try h.setupKey(for: "held-\(index)"))
            held.append(fd)
            #expect(answer["result"] != nil, "connection \(index) serves")
        }
        #expect(try await h.eventually { h.host.connectedClientNames.count == MCPServerHost.sessionCap })

        let socket = try RawSocket(h)
        defer { socket.close() }
        socket.send(preamble: try h.setupKey(for: "claude-code"), CapturedClaudeCode.probe, CapturedClaudeCode.initialize)
        let probeAnswer = socket.next()
        #expect(probeAnswer?["id"] as? String == CapturedClaudeCode.probeID)
        #expect(errorOf(probeAnswer).code == -32601, "\(String(describing: probeAnswer))")
        let capped = socket.next()
        #expect(capped?["id"] as? Int == 0, "the cap answers the initialize: \(String(describing: capped))")
        #expect(errorOf(capped).code == MCPShim.refusalCode)
        #expect(errorOf(capped).message == MCPServerHost.overCapMessage)
        #expect(socket.isHungUp())
    }
}
