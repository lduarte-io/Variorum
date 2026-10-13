import Darwin
import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// THE SIZE CAPS AT THEIR BOUNDARIES (VX-184 U1 — her 2026-10-12 ask; the run
// record `notes/plans/fixes/vx-184-mcp-launch-polish.md`, "Over-cap answers").
// Two caps guard the socket: every OPENING line (the preamble, a pre-initialize
// frame, the `initialize`) is read up to `MCPHandshake.lineLimit` (1 MiB), and
// every message after admission up to `MCPSocketTransport.lineCap` (16 MiB). A
// message exactly AT a cap is admitted and served; one byte OVER is answered
// with one JSON-RPC error on `id: null` (the overrun line's id cannot be read)
// and the connection closes. The over-cap pins and the exactness pin use only
// pre-fix API, so they COMPILE on the pre-fix tree, where they were watched RED
// (closed with no answer; the 16 MiB cap not exact) — the record's piece 6.

/// A line of EXACTLY `length` bytes: the template's own bytes plus ASCII
/// padding (no JSON escaping needed).
private func line(exactly length: Int, _ template: (String) -> String) -> String {
    let base = template("").utf8.count
    precondition(length >= base, "the template alone is \(base) bytes")
    let filled = template(String(repeating: "a", count: length - base))
    precondition(filled.utf8.count == length)
    return filled
}

private func initialize(_ name: String, id: Int = 1, pad: String = "") -> String {
    #"{"jsonrpc":"2.0","id":\#(id),"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"},"pad":"\#(pad)"}}"#
}

private func listBooks(id: Int, pad: String) -> String {
    #"{"jsonrpc":"2.0","id":\#(id),"method":"tools/call","params":{"name":"list_books","arguments":{"pad":"\#(pad)"}}}"#
}

/// Write `bytes` on a helper thread (a reader on the other end may stop
/// reading mid-message — the over-cap arms — so the test's own thread must
/// stay free to read the answer).
private func sendInBackground(_ fd: Int32, _ bytes: Data) {
    Thread { _ = MCPShim.writeAll(fd, bytes) }.start()
}

private func errorOf(_ answer: [String: Any]?) -> (code: Int?, message: String?) {
    let error = answer?["error"] as? [String: Any]
    return (error?["code"] as? Int, error?["message"] as? String)
}

@Suite("VX-184 U1 — the size caps at their boundaries", .serialized)
struct MCPSizeCapTests {
    // MARK: - The opening's cap (1 MiB)

    @Test func anInitializeExactlyAtTheOpeningCapIsAdmittedAndServed() throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let socket = try RawSocket(h, timeout: 30)
        defer { socket.close() }
        let frame = line(exactly: MCPHandshake.lineLimit) { initialize("at-the-cap", pad: $0) }
        sendInBackground(socket.fd, MCPPreamble.line(key: try h.setupKey(for: "at-the-cap")) + Data((frame + "\n").utf8))
        let answer = try #require(socket.next(), "the initialize at exactly 1 MiB is answered")
        #expect(answer["id"] as? Int == 1 && answer["result"] != nil, "\(answer)")
        #expect(try h.client("at-the-cap").state == .pending, "admitted: a connection request, as any first contact")
    }

    @Test func anInitializeOneByteOverTheOpeningCapIsAnsweredThenClosed() throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let key = try h.setupKey(for: "over-the-cap")
        let socket = try RawSocket(h, timeout: 30)
        defer { socket.close() }
        let frame = line(exactly: MCPHandshake.lineLimit + 1) { initialize("over-the-cap", pad: $0) }
        sendInBackground(socket.fd, MCPPreamble.line(key: key) + Data((frame + "\n").utf8))
        let answer = socket.next()
        #expect(answer?["id"] is NSNull, "the overrun line's id cannot be read: \(String(describing: answer))")
        #expect(errorOf(answer).code == MCPShim.refusalCode)
        #expect(errorOf(answer).message?.contains("1 MiB") == true, "\(String(describing: errorOf(answer).message))")
        #expect(socket.isHungUp(), "then the connection closes")
        // Nothing was decided: no client, no key claimed, nothing logged.
        #expect(try h.database.read { try Queries.mcpClient($0, name: "over-the-cap") } == nil)
        #expect(try h.database.read { try Queries.mcpSetupKeyStanding($0, hash: MCPSetupKeyRule.hash(key)) }
                == .unclaimed)
        #expect(try h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM mcp_activity") } == 0)
    }

    @Test func aPreambleOverTheOpeningCapIsAnsweredThenClosed() throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let socket = try RawSocket(h, timeout: 30)
        defer { socket.close() }
        let preamble = line(exactly: MCPHandshake.lineLimit + 1) { "variorum-mcp-key vmk1_\($0)" }
        sendInBackground(socket.fd, Data((preamble + "\n" + initialize("long-key") + "\n").utf8))
        let answer = socket.next()
        #expect(answer?["id"] is NSNull && errorOf(answer).code == MCPShim.refusalCode, "\(String(describing: answer))")
        #expect(socket.isHungUp())
    }

    /// A pre-initialize request exactly at the cap is still the window's
    /// (answered -32601), and the initialize after it opens.
    @Test func aProbeExactlyAtTheOpeningCapIsAnsweredAndTheInitializeOpens() throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let socket = try RawSocket(h, timeout: 30)
        defer { socket.close() }
        let probe = line(exactly: MCPHandshake.lineLimit) {
            #"{"jsonrpc":"2.0","id":"probe","method":"server/discover","params":{"pad":"\#($0)"}}"#
        }
        sendInBackground(socket.fd, MCPPreamble.line(key: try h.setupKey(for: "after-a-big-probe"))
                         + Data((probe + "\n" + initialize("after-a-big-probe") + "\n").utf8))
        let answered = socket.next()
        #expect(answered?["id"] as? String == "probe" && errorOf(answered).code == -32601, "\(String(describing: answered))")
        let opened = socket.next()
        #expect(opened?["id"] as? Int == 1 && opened?["result"] != nil, "\(String(describing: opened))")
    }

    // MARK: - The session's cap (16 MiB)

    /// A raw, admitted, approved session with a read grant on Home.
    private func admittedSession(_ h: ServerHarness, _ name: String) throws -> RawSocket {
        let socket = try RawSocket(h, timeout: 30)
        socket.send(preamble: try h.setupKey(for: name), initialize(name))
        _ = try #require(socket.nextResponse(), "initialized")
        socket.send(#"{"jsonrpc":"2.0","method":"notifications/initialized"}"#)
        _ = try h.approve(name, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
        return socket
    }

    @Test func aMessageExactlyAtTheSessionCapIsServed() throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let socket = try admittedSession(h, "at-the-session-cap")
        defer { socket.close() }
        let call = line(exactly: MCPSocketTransport.lineCap) { listBooks(id: 7, pad: $0) }
        sendInBackground(socket.fd, Data((call + "\n").utf8))
        let answer = try #require(socket.nextResponse(), "the 16 MiB call is answered")
        #expect(answer["id"] as? Int == 7, "\(answer)")
        let result = try #require(answer["result"] as? [String: Any], "\(answer)")
        #expect(result["isError"] as? Bool != true, "served: \(result)")
    }

    @Test func aMessageOneByteOverTheSessionCapIsAnsweredThenClosed() throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let socket = try admittedSession(h, "over-the-session-cap")
        defer { socket.close() }
        let call = line(exactly: MCPSocketTransport.lineCap + 1) { listBooks(id: 8, pad: $0) }
        sendInBackground(socket.fd, Data((call + "\n").utf8))
        let answer = socket.nextResponse()
        #expect(answer?["id"] is NSNull, "the overrun message's id cannot be read: \(String(describing: answer))")
        #expect(errorOf(answer).code == MCPShim.refusalCode)
        #expect(errorOf(answer).message?.contains("16 MiB") == true, "\(String(describing: errorOf(answer).message))")
        #expect(socket.isHungUp(), "then the connection closes")
    }

    /// The cap is EXACT whatever the chunking: a line one byte over is over
    /// even when its newline arrives in the same read (pre-fix it was yielded
    /// whole — anything up to the cap plus one read could pass).
    @Test func theSessionCapIsExactWhateverTheChunking() {
        var fds: [Int32] = [-1, -1]
        #expect(pipe(&fds) == 0)
        defer { close(fds[0]) }
        _ = MCPShim.writeAll(fds[1], Data("0123456789\nabcdefghijk\n{}\n".utf8))
        close(fds[1])
        var lines: [String] = []
        MCPSocketTransport.readLines(fd: fds[0], cap: 10) { lines.append(String(decoding: $0, as: UTF8.self)) }
        #expect(lines == ["0123456789"], "a line AT the cap passes; one byte over ends the read, in one chunk or many")
    }
}
