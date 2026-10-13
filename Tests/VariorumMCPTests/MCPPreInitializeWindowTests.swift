import Darwin
import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-180 — THE PRE-INITIALIZE WINDOW itself (`MCPHandshake.readOpening` —
// the record `notes/plans/fixes/vx-180-discover-probe.md`). The captured
// probe's own pins are `MCPDiscoverProbeServerTests` (red on the pre-fix
// tree); these pin the window's letter: what each frame is to it, its fixed
// answers byte for byte, its order (each answer before the next read), its
// BOUND (a flood meets the one refusal, claiming nothing), and that a frame
// which is no request or notification still takes the pre-VX-180 road at
// once. They name the window's own symbols, so they are new-tree pins.

/// A connected socket pair (both ends without SIGPIPE): `[0]` is the
/// server's end `readOpening` reads and answers on, `[1]` the client's.
private func socketPair() throws -> (server: Int32, client: Int32) {
    var fds: [Int32] = [-1, -1]
    guard socketpair(AF_UNIX, SOCK_STREAM, 0, &fds) == 0 else { throw HarnessFailure("socketpair") }
    MCPSocketRoad.suppressSIGPIPE(fds[0])
    MCPSocketRoad.suppressSIGPIPE(fds[1])
    return (fds[0], fds[1])
}

private func setReceiveTimeout(_ fd: Int32, milliseconds: Int) {
    var timeout = timeval(tv_sec: milliseconds / 1000, tv_usec: Int32((milliseconds % 1000) * 1000))
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
}

private func frame(_ text: String) -> Data { Data(text.utf8) }
private func lines(_ texts: String...) -> Data { Data(texts.map { $0 + "\n" }.joined().utf8) }

/// Her Activity list's CONNECTION lines.
private func connectionActivity(_ h: ServerHarness) throws -> [String] {
    try h.database.read { db in
        try Row.fetchAll(db, sql: "SELECT client_name, act, outcome FROM mcp_activity WHERE act LIKE 'connect_%' ORDER BY id")
            .map { "\($0["client_name"] as String) \($0["act"] as String) \($0["outcome"] as String)" }
    }
}

@Suite("VX-180 — the pre-initialize window", .serialized)
struct MCPPreInitializeWindowTests {
    // MARK: - What each frame is to the window (pure)

    @Test func theWindowClassifiesEachFrame() {
        typealias W = MCPHandshake.WindowFrame
        let cases: [(String, W, Comment)] = [
            (CapturedClaudeCode.probe, .request, "the captured probe — a request, string id"),
            (CapturedClaudeCode.initialize, .initialize, "the captured initialize (method first)"),
            (#"{"jsonrpc":"2.0","id":3,"method":"ping"}"#, .request, "a ping is a request"),
            (#"{"jsonrpc":"2.0","id":4.5,"method":"tools/list"}"#, .request, "any number is an id the refusal echoes"),
            (#"{"jsonrpc":"2.0","method":"notifications/cancelled","params":{}}"#, .notification, "no id: a notification"),
            (#"{"jsonrpc":"2.0","method":"initialize","params":{}}"#, .initialize,
             "anything named initialize ends the window — the pre-VX-180 road decides it"),
            (#"{"jsonrpc":"2.0","id":5,"result":{}}"#, .other, "a response nobody asked for"),
            (#"{"jsonrpc":"2.0","id":null,"method":"tools/list"}"#, .other, "a null id (MCP forbids it)"),
            (#"{"jsonrpc":"2.0","id":{"a":1},"method":"tools/list"}"#, .other, "an id no answer could echo"),
            (#"{"jsonrpc":"2.0","id":1,"method":7}"#, .other, "a method that is no string"),
            (#"[{"jsonrpc":"2.0","id":1,"method":"initialize"}]"#, .other, "a batch"),
            (#"{"id":1}"#, .other, "the opening-read pins' own frame"),
            ("not json", .other, "malformed"),
        ]
        for (text, expected, comment) in cases {
            #expect(MCPHandshake.windowFrame(frame(text)) == expected, comment)
        }
    }

    // MARK: - The window's answers, byte for byte (pure)

    @Test func theWindowsAnswersAreFixedBytes() {
        #expect(String(decoding: MCPHandshake.windowAnswer(toRequest: frame(CapturedClaudeCode.probe)), as: UTF8.self)
                == #"{"error":{"code":-32601,"message":"Method not found"},"id":"server-discover-probe-1","jsonrpc":"2.0"}"# + "\n",
                "-32601 on the probe's STRING id")
        #expect(String(decoding: MCPHandshake.windowAnswer(toRequest: frame(#"{"jsonrpc":"2.0","id":0,"method":"tools/list"}"#)),
                       as: UTF8.self)
                == #"{"error":{"code":-32601,"message":"Method not found"},"id":0,"jsonrpc":"2.0"}"# + "\n",
                "a number id stays a number")
        #expect(String(decoding: MCPHandshake.windowAnswer(toRequest: frame(#"{"jsonrpc":"2.0","id":"p","method":"ping"}"#)),
                       as: UTF8.self)
                == #"{"id":"p","jsonrpc":"2.0","result":{}}"# + "\n",
                "a ping's empty result (P-VX180-2)")
        // The bytes depend on the method's class and the id ALONE: no
        // client-supplied text (method name, params, clientInfo) is echoed.
        let other = #"{"jsonrpc":"2.0","id":"server-discover-probe-1","method":"another/probe","params":{"x":"y"}}"#
        #expect(MCPHandshake.windowAnswer(toRequest: frame(other))
                == MCPHandshake.windowAnswer(toRequest: frame(CapturedClaudeCode.probe)))
        #expect(MCPHandshake.methodNotFoundCode == -32601 && MCPHandshake.methodNotFoundMessage == "Method not found",
                "JSON-RPC 2.0's own code and words")
    }

    // MARK: - The opening read over a socket pair

    /// Preamble, probe, notification, ping, initialize, and a frame after
    /// it: the read answers the two requests IN ORDER, says nothing to the
    /// notification or the initialize, returns the initialize as the
    /// opening's frame with the key, and leaves the next frame unread.
    @Test func theOpeningReadAnswersTheWindowAndStopsAtInitialize() throws {
        let (server, client) = try socketPair()
        defer { close(server); close(client) }
        _ = MCPShim.writeAll(client, Data("variorum-mcp-key vmk1_a\n".utf8) + lines(
            CapturedClaudeCode.probe,
            #"{"jsonrpc":"2.0","method":"notifications/cancelled","params":{}}"#,
            #"{"jsonrpc":"2.0","id":9,"method":"ping"}"#,
            CapturedClaudeCode.initialize,
            #"{"id":2}"#))
        #expect(MCPHandshake.readOpening(fd: server)
                == .init(presentedKey: "vmk1_a", firstFrame: frame(CapturedClaudeCode.initialize)))

        setReceiveTimeout(client, milliseconds: 300)
        #expect(MCPShim.readFirstLine(client, limit: 1 << 16)
                == MCPHandshake.windowAnswer(toRequest: frame(CapturedClaudeCode.probe)).dropLast(), "the probe first")
        #expect(String(decoding: MCPShim.readFirstLine(client, limit: 1 << 16), as: UTF8.self)
                == #"{"id":9,"jsonrpc":"2.0","result":{}}"#, "then the ping")
        #expect(MCPShim.readFirstLine(client, limit: 1 << 16).isEmpty,
                "nothing for the notification, nothing for the initialize (the admission's to answer)")
        #expect(MCPShim.readFirstLine(server, limit: 64) == frame(#"{"id":2}"#),
                "byte-exact: the frame after the opening is the transport's")
    }

    /// A bare connection (no preamble) gets the same window; a waiting
    /// client is answered before the read blocks — proven here by sending
    /// the initialize only AFTER reading the answer, while the production
    /// entry point (`opening(fd:)`, its own reader thread) waits.
    @Test func aBareOpeningIsAnsweredBeforeTheReadBlocks() async throws {
        let (server, client) = try socketPair()
        defer { close(server); close(client) }
        setReceiveTimeout(client, milliseconds: 3_000)
        _ = MCPShim.writeAll(client, lines(CapturedClaudeCode.probe))
        async let opened = MCPHandshake.opening(fd: server)
        let answer = MCPShim.readFirstLine(client, limit: 1 << 16)   // blocks until the window answers
        #expect(answer == MCPHandshake.windowAnswer(toRequest: frame(CapturedClaudeCode.probe)).dropLast(),
                "answered while the opening read waits for the next frame")
        _ = MCPShim.writeAll(client, lines(CapturedClaudeCode.initialize))
        #expect(await opened == .init(presentedKey: nil, firstFrame: frame(CapturedClaudeCode.initialize)))
    }

    /// The bound, on both sides of it: `preInitializeLimit` frames inside
    /// the window, then an `initialize` still opens; one frame more and that
    /// frame is the opening's (the admission refuses it) — with exactly
    /// `preInitializeLimit` answers written.
    @Test func theWindowHoldsExactlyItsLimit() throws {
        let limit = MCPHandshake.preInitializeLimit
        let request = { (id: Int) in #"{"jsonrpc":"2.0","id":\#(id),"method":"tools/list"}"# }

        let (server, client) = try socketPair()
        defer { close(server); close(client) }
        var inside = (0..<(limit - 1)).map(request)
        inside.append(#"{"jsonrpc":"2.0","method":"notifications/x"}"#)
        _ = MCPShim.writeAll(client, Data(((inside + [CapturedClaudeCode.initialize]).map { $0 + "\n" }.joined()).utf8))
        #expect(MCPHandshake.readOpening(fd: server)?.firstFrame == frame(CapturedClaudeCode.initialize),
                "\(limit) frames inside the window, then initialize: opened")

        let (server2, client2) = try socketPair()
        defer { close(server2); close(client2) }
        let flood = (0...limit).map(request)   // limit + 1 requests
        _ = MCPShim.writeAll(client2, Data((flood.map { $0 + "\n" }.joined()).utf8))
        #expect(MCPHandshake.readOpening(fd: server2)?.firstFrame == frame(request(limit)),
                "the frame past the window is the opening's, whatever it is")
        setReceiveTimeout(client2, milliseconds: 300)
        var answered = 0
        while !MCPShim.readFirstLine(client2, limit: 1 << 16).isEmpty { answered += 1 }
        #expect(answered == limit, "exactly the window's answers — none for the frame past it")
    }

    /// An answer that cannot be written ends the opening: the client is gone.
    @Test func anAnswerThatCannotBeWrittenEndsTheOpening() throws {
        let (server, client) = try socketPair()
        defer { close(server) }
        _ = MCPShim.writeAll(client, lines(CapturedClaudeCode.probe, CapturedClaudeCode.initialize))
        close(client)
        #expect(MCPHandshake.readOpening(fd: server) == nil)
    }

    // MARK: - On the socket road

    /// A peer that never initializes meets the ONE refusal sentence past the
    /// window, byte-identical to every other refusal arm but the id; it is
    /// logged as the unnamed connection it is; and it claims NOTHING — the
    /// key it presented stays unclaimed.
    @Test func aRequestFloodPastTheWindowIsRefusedWithTheOneSentence() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let key = try h.operations.mintMCPSetupKey()
        let socket = try RawSocket(h)
        defer { socket.close() }
        var bytes = MCPPreamble.line(key: key)
        for window in 0..<MCPHandshake.preInitializeLimit {
            bytes.append(Data((#"{"jsonrpc":"2.0","id":\#(100 + window),"method":"server/discover"}"# + "\n").utf8))
        }
        bytes.append(Data((#"{"jsonrpc":"2.0","id":99,"method":"server/discover"}"# + "\n").utf8))
        _ = MCPShim.writeAll(socket.fd, bytes)

        for window in 0..<MCPHandshake.preInitializeLimit {
            let answer = socket.next()
            #expect(answer?["id"] as? Int == 100 + window)
            #expect((answer?["error"] as? [String: Any])?["code"] as? Int == -32601)
        }
        let refused = try #require(socket.next(), "past the window, the refusal")
        #expect(refused["id"] as? Int == 99 && refused["result"] == nil)
        #expect((refused["error"] as? [String: Any])?["code"] as? Int == MCPShim.refusalCode)
        #expect((refused["error"] as? [String: Any])?["message"] as? String == MCPHandshake.refusal)
        #expect(socket.isHungUp(), "then the connection closes")

        let (bareFD, bare) = try h.rawOpen(as: "stray", presenting: nil, id: 99)
        close(bareFD)
        #expect(try JSONSerialization.data(withJSONObject: refused, options: [.sortedKeys])
                == JSONSerialization.data(withJSONObject: bare, options: [.sortedKeys]),
                "one sentence, byte for byte (no oracle)")
        #expect(try connectionActivity(h) == [
            "\(Operations.mcpUnnamedClient) \(MCPSetupKeyRule.activityAct(.unnamed)) refused",
            "stray \(MCPSetupKeyRule.activityAct(.bare)) refused",
        ])
        #expect(try await h.database.read { try Queries.mcpSetupKeyStanding($0, hash: MCPSetupKeyRule.hash(key)) }
                == .unclaimed, "a flood claims no key")
    }

    /// A first frame that is no request and no notification (here, a
    /// response nobody asked for) ends the window AT ONCE on the pre-VX-180
    /// road: the one sentence, byte-identical, on its id.
    @Test func aFrameThatIsNoRequestEndsTheWindowAtOnce() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let socket = try RawSocket(h)
        defer { socket.close() }
        socket.send(preamble: try h.operations.mintMCPSetupKey(), #"{"jsonrpc":"2.0","id":5,"result":{}}"#)
        let refused = try #require(socket.next())
        #expect(socket.isHungUp())
        let (bareFD, bare) = try h.rawOpen(as: "stray", presenting: nil, id: 5)
        close(bareFD)
        #expect(try JSONSerialization.data(withJSONObject: refused, options: [.sortedKeys])
                == JSONSerialization.data(withJSONObject: bare, options: [.sortedKeys]))
        #expect((refused["error"] as? [String: Any])?["message"] as? String == MCPHandshake.refusal)
    }
}
