import Darwin
import Foundation
import Testing

@testable import VariorumMCP
@testable import VariorumMCPSocket

// ROUND 1's F1 (the VX-981 ladder — `notes/plans/fixes/vx-981-ladder-round1.md`, FINAL
// CALLS): THE RAW CLIENT'S TWO HANG-UP READS, pinned on a socketpair with no server.
//
// THE MECHANISM (measured — instrument (b), 10 of 10): `MCPSizeCapTests`' over-cap pin
// approves its client, and an approval owes the connection 0 or 1
// `notifications/tools/list_changed` with nothing ordering it against the over-cap
// answer; batch 3 moved that notice behind the gate's catch-up, to within 265 ms of the
// answer. When it lands after the answer and before the close, the strict `isHungUp()`
// reads its first byte (`{`) and answers "not hung up" — the recorded red at
// `MCPSizeCapTests.swift:158`, line 158 alone. No contract is broken: the answer is the
// connection's last ANSWER, and the connection closes right after.
//
// THE FIX (test only): a second reader beside `isHungUp()` — `readToHangUp()`, whole lines
// to EOF under the socket's own receive bound, TRUE only for nothing but the door's own
// notices then EOF, and reporting what it read. Used at line 158 alone; the seven other
// `isHungUp()` calls keep the strict check (their connections are owed no notice, so it is
// their guard that nothing of the door's follows).
//
// Arm (i) is the red-on-old: on the scaffold (`readToHangUp` with TODAY's one-byte
// verdict) it is red, and it pins the strict helper's meaning on the same bytes.

/// The over-cap answer exactly as the door writes it (the transport's own builder).
private let overCapAnswer = MCPShim.refusalResponse(
    toFirstLine: Data(),
    message: MCPHandshake.overLimitRefusal(limit: MCPSocketTransport.lineCap, beforeInitialize: false))

private let notice = Data((#"{"jsonrpc":"2.0","method":"notifications/tools/list_changed"}"# + "\n").utf8)

/// A connected pair: the test's end (a `RawSocket`, reads bounded by `timeout`) and the far
/// end, which writes `bytes` and — unless `closing` is false — closes.
private func pair(_ bytes: Data, closing: Bool = true, timeout: Int = 5) throws -> (RawSocket, Int32) {
    var fds: [Int32] = [-1, -1]
    guard socketpair(AF_UNIX, SOCK_STREAM, 0, &fds) == 0 else { throw HarnessFailure("socketpair: errno \(errno)") }
    #expect(MCPShim.writeAll(fds[1], bytes), "the far end wrote its bytes")
    if closing { close(fds[1]) }
    return (RawSocket(adopting: fds[0], timeout: timeout), closing ? -1 : fds[1])
}

@Suite("Round 1's F1 (the VX-981 ladder) — the raw client's two hang-up reads", .serialized)
struct MCPRawSocketHangUpTests {
    /// **(i) RED ON OLD — the over-cap answer, a late notice, then the close:** the new
    /// reader answers TRUE and says what it read; on the SAME bytes the strict `isHungUp()`
    /// answers FALSE (the meaning the other seven calls rely on — and line 158's recorded red).
    @Test func aLateNoticeBeforeTheCloseIsTheDoorsOwnAndStillAHangUp() async throws {
        let (socket, _) = try pair(overCapAnswer + notice)
        defer { socket.close() }
        let answer = await socket.nextResponse()
        #expect(answer?["id"] is NSNull, "premise: the over-cap answer read first — \(String(describing: answer))")
        let read = await socket.readToHangUp()
        #expect(read.isOnlyNoticesThenEOF, "RED ON OLD: a notice, then EOF, is the hang-up — \(read)")
        #expect(read == HangUpRead(lines: [notice.dropLast()], ending: .eof), "it reports what it read — \(read)")

        let (strict, _) = try pair(overCapAnswer + notice)
        defer { strict.close() }
        _ = await strict.nextResponse()
        #expect(await strict.isHungUp() == false, "the strict check reads the notice's first byte: not hung up")
    }

    /// **(ii)** A frame carrying an `id` after the answer is no notice of the door's — FALSE;
    /// and so is a notification with any other method.
    @Test func aFrameCarryingAnIDOrAnotherMethodIsNoHangUp() async throws {
        let answered = Data((#"{"jsonrpc":"2.0","id":9,"result":{}}"# + "\n").utf8)
        let (socket, _) = try pair(overCapAnswer + notice + answered)
        defer { socket.close() }
        _ = await socket.nextResponse()
        let read = await socket.readToHangUp()
        #expect(!read.isOnlyNoticesThenEOF, "an answer after the answer: \(read)")
        #expect(read.lines.count == 2 && read.ending == .eof, "it reads both lines, then EOF — \(read)")

        let other = Data((#"{"jsonrpc":"2.0","method":"notifications/message","params":{}}"# + "\n").utf8)
        let (second, _) = try pair(overCapAnswer + other)
        defer { second.close() }
        _ = await second.nextResponse()
        let otherRead = await second.readToHangUp()
        #expect(!otherRead.isOnlyNoticesThenEOF, "another method: \(otherRead)")
    }

    /// **(iii)** Bytes with no newline, then the close — a torn line, FALSE.
    @Test func bytesWithNoNewlineBeforeTheCloseAreNoHangUp() async throws {
        let torn = Data(#"{"jsonrpc":"2.0","method":"notifications/tools/list_cha"#.utf8)
        let (socket, _) = try pair(overCapAnswer + torn)
        defer { socket.close() }
        _ = await socket.nextResponse()
        let read = await socket.readToHangUp()
        #expect(!read.isOnlyNoticesThenEOF, "\(read)")
        #expect(read.ending == .tornLine(torn), "it says the torn bytes — \(read)")
    }

    /// **(iv)** No EOF within a short bound — FALSE, said as the bound passing.
    @Test func noCloseWithinTheBoundIsNoHangUp() async throws {
        let (socket, farEnd) = try pair(overCapAnswer, closing: false, timeout: 1)
        defer {
            socket.close()
            close(farEnd)
        }
        _ = await socket.nextResponse()
        let read = await socket.readToHangUp()
        #expect(!read.isOnlyNoticesThenEOF, "\(read)")
        #expect(read.ending == .boundPassed, "\(read)")
    }

    /// **(v)** The close at once — TRUE, nothing read (what the strict check also says).
    @Test func aCloseAtOnceIsAHangUp() async throws {
        let (socket, _) = try pair(overCapAnswer)
        defer { socket.close() }
        _ = await socket.nextResponse()
        let read = await socket.readToHangUp()
        #expect(read.isOnlyNoticesThenEOF && read.lines.isEmpty, "\(read)")
    }
}
