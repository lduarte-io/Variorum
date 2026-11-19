import Darwin
import Dependencies
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-952 (the VX-981 run, batch 4 — born at the VX-940 run as F-W4-3) — THE
// OPENING READ, BUFFERED. The pre-initialize window read every opening line a
// byte at a time (`MCPOpeningWindow.readLine`): a 1 MiB opening line cost about
// a million `read` calls on the handshake's own thread — bounded and off the
// pool, a performance cost only. The opening now reads in chunks
// (`MCPOpeningWindow.Reader`), with the one care the ticket names: whatever it
// read past its own lines reaches the transport untouched (`leftover`), the
// replayed `initialize` and anything pipelined behind it included. An
// Improvement — these pin the NEW contract: the read count; the byte reader's
// verdicts at every boundary (an oracle: the old reader, kept here verbatim);
// the handoff, byte for byte, through the handshake and the transport and
// through a real session; and the shim's closed-app road answering the same
// when frames follow in one segment. Every existing handshake arm runs
// unchanged beside them (the window's answers, the skipped notification, the
// 1 MiB cap's answer, the setup-key preamble, the closed-app shim).

/// An in-memory source for a `Reader`: serves at most what each call asks,
/// counts the calls, and answers 0 (EOF) once spent.
private final class CountingSource: @unchecked Sendable {
    private let bytes: [UInt8]
    private var offset = 0
    private(set) var calls = 0

    init(_ data: Data) { bytes = Array(data) }

    func read(_ buffer: UnsafeMutableRawPointer, _ count: Int) -> Int {
        calls += 1
        let n = min(count, bytes.count - offset)
        guard n > 0 else { return 0 }
        bytes.withUnsafeBytes { raw in buffer.copyMemory(from: raw.baseAddress! + offset, byteCount: n) }
        offset += n
        return n
    }

    /// What it never served.
    var unread: Data { Data(bytes[offset...]) }
}

/// THE ORACLE — the pre-VX-952 byte-at-a-time reads, verbatim but for their
/// source (an in-memory `CountingSource` in place of the descriptor).
private enum ByteReader {
    static func readLine(_ source: CountingSource, limit: Int) -> MCPOpeningWindow.LineRead {
        var line = Data()
        var byte: UInt8 = 0
        while true {
            let count = withUnsafeMutableBytes(of: &byte) { source.read($0.baseAddress!, 1) }
            guard count == 1 else { return .ended }
            if byte == UInt8(ascii: "\n") { return .line(line) }
            line.append(byte)
            if line.count > limit { return .overLimit }
        }
    }

    static func nextLine(_ source: CountingSource, limit: Int) -> MCPOpeningWindow.LineRead {
        for _ in 0...MCPOpeningWindow.blankLimit {
            let result = readLine(source, limit: limit)
            if case .line(let line) = result, line.isEmpty { continue }
            return result
        }
        return .ended
    }
}

private func reader(_ source: CountingSource, chunk: Int) -> MCPOpeningWindow.Reader {
    MCPOpeningWindow.Reader(-1, chunk: chunk) { _, buffer, count in source.read(buffer, count) }
}

private func lines(_ texts: String...) -> Data { Data(texts.map { $0 + "\n" }.joined().utf8) }

private func socketPair() throws -> (server: Int32, client: Int32) {
    var fds: [Int32] = [-1, -1]
    guard socketpair(AF_UNIX, SOCK_STREAM, 0, &fds) == 0 else { throw HarnessFailure("socketpair") }
    MCPSocketRoad.suppressSIGPIPE(fds[0])
    MCPSocketRoad.suppressSIGPIPE(fds[1])
    return (fds[0], fds[1])
}

@Suite("VX-952 — the opening reads in chunks and hands on every byte it did not consume", .serialized)
struct MCPOpeningReaderTests {
    // MARK: - The cost

    /// **The read count.** A line of the full 1 MiB (`lineLimit` bytes, then
    /// its newline) costs `ceil((lineLimit + 1) / chunk)` reads — seventeen
    /// with the 64 KiB chunk, where the byte reader made 1,048,577 — and the
    /// line is whole; one byte more is over the limit after the same seventeen
    /// (the byte reader's verdict, at its byte).
    @Test func aFullLengthLineCostsSeventeenReadsNotAMillion() {
        let limit = MCPOpeningWindow.lineLimit
        let chunk = MCPOpeningWindow.Reader.chunk
        let body = Data(repeating: UInt8(ascii: "a"), count: limit)

        let full = CountingSource(body + Data("\n".utf8))
        var atTheLimit = reader(full, chunk: chunk)
        #expect(atTheLimit.readLine() == .line(body), "a line of exactly lineLimit bytes is a line")
        #expect(full.calls == (limit + 1 + chunk - 1) / chunk, "\(full.calls) reads")
        #expect(full.calls == 17)
        #expect(atTheLimit.leftover.isEmpty)

        let over = CountingSource(body + Data("a\n".utf8))
        var pastTheLimit = reader(over, chunk: chunk)
        #expect(pastTheLimit.readLine() == .overLimit, "one byte more is over")
        #expect(over.calls == 17, "\(over.calls) reads")

        // A full-length line with frames behind it in the same reads: the line
        // whole, then every later byte handed on (the reader keeps only what
        // follows a long line it handed out).
        let behind = CountingSource(body + Data("\n{\"id\":2}\n{\"par".utf8))
        var longThenMore = reader(behind, chunk: chunk)
        #expect(longThenMore.readLine() == .line(body))
        #expect(longThenMore.readLine() == .line(Data("{\"id\":2}".utf8)))
        #expect(longThenMore.leftover + behind.unread == Data("{\"par".utf8))

        let byByte = CountingSource(body + Data("\n".utf8))
        #expect(ByteReader.readLine(byByte, limit: limit) == .line(body))
        #expect(byByte.calls == limit + 1, "the oracle: one read per byte (\(byByte.calls))")
    }

    // MARK: - The verdicts, at every boundary

    /// **The byte reader's verdicts, exactly** — for every input below and
    /// every chunk size (one byte, small primes, the real 64 KiB), the
    /// buffered reader's sequence of `nextLine` verdicts equals the old byte
    /// reader's, and NOTHING IS LOST: what the buffered reader handed on
    /// (`leftover`) plus what its source never served equals what the byte
    /// reader left unread. The limit is shrunk to 8 so the boundary is cheap.
    @Test func theVerdictsAreTheByteReadersAtEveryBoundary() {
        let limit = 8
        let inputs: [String] = [
            "", "\n", "abc", "abc\n", "12345678\n", "123456789\n", "12345678",  // the limit, both sides
            "a\nb\nc\n", "a\n\n\nb\n", "\n\n\n\n\n\n\n\n\n\n\nz\n",            // blank lines, past blankLimit
            "first\nsecond\npartial", "1234567890123\nshort\n",                // over, then more
            "variorum-mcp-key k\n{\"id\":1}\n{\"id\":2}\n{\"par",             // an opening and its leftover
        ]
        for input in inputs {
            for chunk in [1, 2, 3, 5, 7, 13, 64, MCPOpeningWindow.Reader.chunk] {
                let old = CountingSource(Data(input.utf8))
                let new = CountingSource(Data(input.utf8))
                var buffered = reader(new, chunk: chunk)
                var oldVerdicts: [MCPOpeningWindow.LineRead] = []
                var newVerdicts: [MCPOpeningWindow.LineRead] = []
                for _ in 0..<6 {
                    oldVerdicts.append(ByteReader.nextLine(old, limit: limit))
                    newVerdicts.append({
                        for _ in 0...MCPOpeningWindow.blankLimit {
                            let result = buffered.readLine(limit: limit)
                            if case .line(let line) = result, line.isEmpty { continue }
                            return result
                        }
                        return .ended
                    }())
                    guard case .line = oldVerdicts.last!, case .line = newVerdicts.last! else { break }
                    // After every line both handed out: nothing lost past it.
                    #expect(buffered.leftover + new.unread == old.unread,
                            "\(input.debugDescription) by \(chunk): nothing lost past the lines handed out")
                }
                #expect(newVerdicts == oldVerdicts, "\(input.debugDescription) by \(chunk): \(newVerdicts) vs \(oldVerdicts)")
            }
        }
    }

    /// `nextLine` is the window's own (blank lines skipped up to `blankLimit`,
    /// then `.ended`), at the real limit.
    @Test func nextLineSkipsBlankLinesUpToTheBound() {
        let skipped = CountingSource(Data((String(repeating: "\n", count: MCPOpeningWindow.blankLimit) + "{}\n").utf8))
        var withinTheBound = reader(skipped, chunk: 3)
        #expect(withinTheBound.nextLine() == .line(Data("{}".utf8)))
        let tooMany = CountingSource(Data((String(repeating: "\n", count: MCPOpeningWindow.blankLimit + 1) + "{}\n").utf8))
        var pastTheBound = reader(tooMany, chunk: 3)
        #expect(pastTheBound.nextLine() == .ended)
        #expect(ByteReader.nextLine(CountingSource(Data((String(repeating: "\n", count: MCPOpeningWindow.blankLimit + 1) + "{}\n").utf8)),
                                    limit: MCPOpeningWindow.lineLimit) == .ended, "the oracle agrees")
    }

    // MARK: - The handoff

    /// **Frames pipelined in ONE segment reach the transport untouched.** A
    /// client writes, in one write: its preamble, a pre-initialize probe, its
    /// `initialize`, `notifications/initialized`, a `tools/list` request and
    /// the START of one more frame; the window answers the probe; the opening
    /// is the `initialize` with every later byte its leftover; the transport
    /// built with that leftover yields the replayed `initialize`, the two
    /// whole frames and — once the client finishes it — the straddling one,
    /// then the next, byte for byte, in order.
    @Test func framesPipelinedInOneSegmentReachTheTransportUntouched() async throws {
        let (server, client) = try socketPair()
        defer { close(server) }
        let initialized = #"{"jsonrpc":"2.0","method":"notifications/initialized"}"#
        let list = #"{"jsonrpc":"2.0","id":1,"method":"tools/list"}"#
        let straddling = #"{"jsonrpc":"2.0","id":2,"method":"ping"}"#
        let split = straddling.index(straddling.startIndex, offsetBy: 17)
        let after = #"{"jsonrpc":"2.0","id":3,"method":"ping"}"#
        var segment = MCPPreamble.line(key: "vmk1_a")
        segment.append(lines(CapturedClaudeCode.probe, CapturedClaudeCode.initialize, initialized, list))
        segment.append(Data(straddling[..<split].utf8))
        _ = MCPShim.writeAll(client, segment)

        let opened = try #require(MCPHandshake.readOpening(fd: server))
        #expect(opened.presentedKey == "vmk1_a")
        #expect(opened.firstFrame == Data(CapturedClaudeCode.initialize.utf8))
        #expect(opened.leftover == lines(initialized, list) + Data(straddling[..<split].utf8),
                "every byte past the initialize is handed on, the partial frame included")
        var timeout = timeval(tv_sec: 5, tv_usec: 0)
        _ = setsockopt(client, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        #expect(MCPShim.readFirstLine(client, limit: 1 << 16)
                == MCPHandshake.windowAnswer(toRequest: Data(CapturedClaudeCode.probe.utf8)).dropLast(),
                "the window's answer, byte-unchanged")

        let transport = MCPSocketTransport(fd: server, replay: [opened.firstFrame], leftover: opened.leftover)
        try await transport.connect()
        _ = MCPShim.writeAll(client, Data((straddling[split...] + "\n").utf8) + lines(after))
        close(client)   // the client leaves: the reader's read ends and its stream finishes by itself
        var received: [Data] = []
        for try await line in await transport.receive() { received.append(line) }
        await transport.disconnect()
        #expect(received == [CapturedClaudeCode.initialize, initialized, list, straddling, after].map { Data($0.utf8) },
                "the replayed initialize, then every pipelined frame whole and in order: \(received.map { String(decoding: $0, as: UTF8.self) })")
    }

    /// **The leftover is the stream's first bytes** — the same split and the
    /// same exact cap as a read's: a line begun in the leftover and finished on
    /// the descriptor is measured whole; one byte past the cap is over.
    @Test func theLeftoverIsReadAsTheStreamsFirstBytes() throws {
        func run(_ leftover: String, then rest: String, cap: Int) throws -> (lines: [String], end: MCPSocketTransport.ReadEnd) {
            var fds: [Int32] = [-1, -1]
            try #require(pipe(&fds) == 0)
            _ = MCPShim.writeAll(fds[1], Data(rest.utf8))
            close(fds[1])
            defer { close(fds[0]) }
            var yielded: [String] = []
            let end = MCPSocketTransport.readLines(fd: fds[0], cap: cap, initial: Data(leftover.utf8)) {
                yielded.append(String(decoding: $0, as: UTF8.self))
            }
            return (yielded, end)
        }
        let whole = try run("one\ntwo\nthr", then: "ee\nfour\n", cap: 16)
        #expect(whole.lines == ["one", "two", "three", "four"] && whole.end == .closed)
        let atTheCap = try run("abc", then: "defg\n", cap: 7)
        #expect(atTheCap.lines == ["abcdefg"], "seven bytes across the seam, cap seven: a line")
        let overTheCap = try run("abc", then: "defg\n", cap: 6)
        #expect(overTheCap.lines.isEmpty && overTheCap.end == .overLimit, "one byte past the cap across the seam: over")
        let overInTheLeftover = try run("abcdefgh", then: "\n", cap: 6)
        #expect(overInTheLeftover.end == .overLimit, "a leftover already past the cap is over at once")
        let blanks = try run("\n\nx\n", then: "\ny\n", cap: 6)
        #expect(blanks.lines == ["x", "y"], "empty lines are skipped, as from a read")
    }

    /// **Through a real session:** a keyed client that pipelines its probe, its
    /// `initialize`, `notifications/initialized` and a `ping` in ONE write
    /// hears the probe answered, its `initialize` answered and its ping
    /// answered — the ping reached the SDK through the opening's leftover.
    @Test func aPipelinedOpeningIsServedWholeThroughARealSession() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "a page")
            let first = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            await h.hangUp(first)

            let socket = try RawSocket(h)
            defer { socket.close() }
            socket.send(preamble: try h.setupKey(for: "claude-code"),
                        CapturedClaudeCode.probe, CapturedClaudeCode.initialize,
                        #"{"jsonrpc":"2.0","method":"notifications/initialized"}"#,
                        #"{"jsonrpc":"2.0","id":"pipelined-ping","method":"ping"}"#)

            let probeAnswer = await socket.next()
            #expect(probeAnswer?["id"] as? String == CapturedClaudeCode.probeID)
            var answered: [String: [String: Any]] = [:]
            for _ in 0..<2 {
                guard let response = await socket.nextResponse() else { break }
                answered["\(response["id"] ?? "nil")"] = response
            }
            #expect((answered["0"]?["result"] as? [String: Any])?["serverInfo"] != nil, "the initialize answered: \(answered.keys)")
            #expect(answered["pipelined-ping"]?["result"] as? [String: Any] != nil,
                    "the ping pipelined behind it answered — it reached the SDK whole: \(answered.keys)")
        }
    }

    /// **The shim's closed-app road, one segment:** frames written AFTER the
    /// `initialize` in the same write change nothing the client hears — the
    /// probe's `-32601`, then the refusal on the `initialize`'s id, byte for
    /// byte the answers to the same two frames sent alone (the reader drops
    /// what it read past the frame; the shim exits).
    @Test func theShimsClosedAppRoadAnswersTheSameWhenFramesFollowInOneSegment() throws {
        func answers(to input: Data) throws -> Data {
            var stdin: [Int32] = [-1, -1]
            var stdout: [Int32] = [-1, -1]
            try #require(pipe(&stdin) == 0 && pipe(&stdout) == 0)
            _ = MCPShim.writeAll(stdin[1], input)
            close(stdin[1])
            MCPShim.respondToFirstRequest(input: stdin[0], output: stdout[1], message: "Variorum must be open.")
            close(stdin[0])
            close(stdout[1])
            var heard = Data()
            var buffer = [UInt8](repeating: 0, count: 4096)
            while true {
                let n = read(stdout[0], &buffer, buffer.count)
                guard n > 0 else { break }
                heard.append(contentsOf: buffer[0..<n])
            }
            close(stdout[0])
            return heard
        }
        let alone = try answers(to: lines(CapturedClaudeCode.probe, CapturedClaudeCode.initialize))
        let followed = try answers(to: lines(
            CapturedClaudeCode.probe, CapturedClaudeCode.initialize,
            #"{"jsonrpc":"2.0","method":"notifications/initialized"}"#, #"{"jsonrpc":"2.0","id":1,"method":"tools/list"}"#)
            + Data(#"{"jsonrpc":"2.0","id":2,"me"#.utf8))
        #expect(followed == alone, "byte-identical answers")
        let heard = alone.split(separator: UInt8(ascii: "\n")).map { Data($0) }
        #expect(heard.count == 2)
        #expect(heard.first == MCPHandshake.windowAnswer(toRequest: Data(CapturedClaudeCode.probe.utf8)).dropLast())
        #expect(heard.last == MCPShim.refusalResponse(toFirstLine: Data(CapturedClaudeCode.initialize.utf8),
                                                       message: "Variorum must be open.").dropLast())
    }
}
