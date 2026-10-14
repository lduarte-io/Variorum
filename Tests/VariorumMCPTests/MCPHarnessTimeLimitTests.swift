import Darwin
import Foundation
import MCP
import Testing

@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-132 — THE HARNESS NEVER HANGS (the run record
// `notes/plans/fixes/vx-184-mcp-launch-polish.md`, U1 — "VX-132 — the trace").
// The pinned SDK gives no request a time limit and never fails a pending
// request when its connection ends, so a test whose answer never came waited
// forever and stalled the whole run. These pins stand a FAKE PEER on the
// harness's own socket path (the real host stopped first) that misbehaves on
// purpose, and drive it through the harness's ordinary `connect(as:)` and
// `callTool` — so each COMPILES on the pre-fix harness, where each one HANGS
// (watched red under an outer watchdog — the record's piece 2).

/// A stand-in for the server on the harness's socket path.
private final class FakePeer: @unchecked Sendable {
    enum Behavior {
        /// Accepts nothing and answers nothing (the connection waits in the
        /// listener's backlog).
        case silent
        /// Answers `initialize`, then reads and ignores everything.
        case answersInitializeOnly
        /// Answers `initialize`, then hangs up on the first tool call.
        case hangsUpOnTheFirstCall
    }

    private let listener: Int32
    private let directory: URL

    init(_ h: ServerHarness, _ behavior: Behavior) throws {
        h.host.stop()
        directory = h.directory
        let listener = try MCPSocketRoad.listen(directory: h.directory)
        self.listener = listener
        guard behavior != .silent else { return }
        Thread {
            let fd = accept(listener, nil, nil)
            guard fd >= 0 else { return }
            MCPSocketRoad.suppressSIGPIPE(fd)
            defer { close(fd) }
            while true {
                let line = MCPShim.readFirstLine(fd, limit: 1 << 20)
                guard !line.isEmpty else { return }   // EOF: the client hung up
                guard let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any],
                      let method = object["method"] as? String
                else { continue }                     // the preamble line
                if method == "initialize", let id = object["id"] {
                    // The id echoed as it arrived (the SDK's are strings).
                    let version = (object["params"] as? [String: Any])?["protocolVersion"] as? String ?? "2025-06-18"
                    let answer: [String: Any] = [
                        "jsonrpc": "2.0", "id": id,
                        "result": [
                            "protocolVersion": version, "capabilities": ["tools": [String: Any]()],
                            "serverInfo": ["name": "fake-peer", "version": "0"],
                        ] as [String: Any],
                    ]
                    guard let bytes = try? JSONSerialization.data(withJSONObject: answer) else { return }
                    _ = MCPShim.writeAll(fd, bytes + Data("\n".utf8))
                } else if method == "tools/call", behavior == .hangsUpOnTheFirstCall {
                    return                            // the deferred close ends the connection mid-call
                }
            }
        }.start()
    }

    func stop() {
        close(listener)
        MCPSocketRoad.unlink(directory: directory)
    }
}

@Suite("VX-132 — the socket harness never hangs: every act bounded and named", .serialized)
struct MCPHarnessTimeLimitTests {
    /// A peer that never answers `initialize`: the harness's connect fails
    /// NAMED, inside its (shortened) limit — never a stalled run.
    @Test func aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let peer = try FakePeer(h, .silent)
        defer { peer.stop() }
        let started = ContinuousClock.now
        let failure = await HarnessDeadline.$seconds.withValue(1) {
            await #expect(throws: HarnessFailure.self) { _ = try await h.connect(as: "never-answered") }
        }
        #expect(failure?.description.contains("connect") == true, "\(String(describing: failure))")
        #expect(ContinuousClock.now - started < .seconds(15), "bounded by the limit, not by the run")
    }

    /// A peer that answers `initialize` and then nothing: the call fails
    /// NAMED, inside its limit.
    @Test func aPeerThatNeverAnswersACallFailsTheCallNamedAndBounded() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let peer = try FakePeer(h, .answersInitializeOnly)
        defer { peer.stop() }
        let connection = try await h.connect(as: "never-called-back")
        let started = ContinuousClock.now
        let failure = await HarnessDeadline.$seconds.withValue(1) {
            await #expect(throws: HarnessFailure.self) {
                _ = text(try await connection.client.callTool(name: "list_books"))
            }
        }
        #expect(failure?.description.contains("list_books") == true, "\(String(describing: failure))")
        #expect(ContinuousClock.now - started < .seconds(15), "bounded by the limit, not by the run")
    }

    /// The SDK's own gap: a server that HANGS UP while a call is pending
    /// left that call waiting forever (nothing fails a pending request at
    /// EOF). The harness ends the client when its stream ends, so the call
    /// fails AT ONCE — well inside the default limit, so it is the hang-up,
    /// not the deadline, that answers it.
    @Test func aServerThatHangsUpMidCallFailsTheCallAtOnce() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let peer = try FakePeer(h, .hangsUpOnTheFirstCall)
        defer { peer.stop() }
        let connection = try await h.connect(as: "hung-up-on")
        let started = ContinuousClock.now
        await #expect(throws: (any Error).self) {
            _ = text(try await connection.client.callTool(name: "list_books"))
        }
        #expect(ContinuousClock.now - started < .seconds(10), "the hang-up answers the call, never the deadline")
    }
}
