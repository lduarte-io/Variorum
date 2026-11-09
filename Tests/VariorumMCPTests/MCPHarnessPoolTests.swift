import Darwin
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-850 (the VX-926 run, U1 — the record `notes/plans/fixes/vx-926-test-flakes.md`,
// "## U1 record") — THE HARNESS NEVER WAITS ON THE POOL IT SERVES FROM.
//
// The server under test runs on THIS process's cooperative pool (`MCPServerHost.serve`
// starts each connection as a task; the admission and the SDK's loops are pool work),
// and the pool is exactly `activeProcessorCount` threads wide. A test that waits for
// that server by BLOCKING a pool thread — a `read()` under a receive timeout, a
// semaphore — holds a thread the server needs: once such waits cover the pool, no
// server can answer any of them until their timeouts expire (Phase 1's C2: the
// door's initialize answered in 7–9 ms with 11 of 12 threads held, 2,703 ms with all
// 12 — exactly until the holders' timeout). These pins make that circular wait
// DETERMINISTIC: more waits at once than the pool has threads, on the harness's own
// roads, with no load and no timing luck — each answer takes milliseconds when the
// waits hold no thread, and never comes inside the bound when they do.

/// A stand-in for the server on the harness's socket path (the real host stopped)
/// that answers each connection's `initialize` only after `delay` — a server the
/// test process's congested pool has slowed, made deterministic on a plain thread.
private final class LatePeer: @unchecked Sendable {
    private let listener: Int32
    private let directory: URL

    init(_ h: ServerHarness, answersAfter delay: Double) throws {
        h.host.stop()
        directory = h.directory
        let listener = try MCPSocketRoad.listen(directory: h.directory)
        self.listener = listener
        Thread {
            while true {
                let fd = accept(listener, nil, nil)
                guard fd >= 0 else { return }
                MCPSocketRoad.suppressSIGPIPE(fd)
                Thread {
                    defer { close(fd) }
                    while true {
                        let line = MCPShim.readFirstLine(fd, limit: 1 << 20)
                        guard !line.isEmpty else { return }
                        guard let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any],
                              object["method"] as? String == "initialize", let id = object["id"]
                        else { continue }   // the preamble
                        usleep(UInt32(delay * 1_000_000))
                        let answer: [String: Any] = ["jsonrpc": "2.0", "id": id, "result": [String: Any]()]
                        guard let bytes = try? JSONSerialization.data(withJSONObject: answer) else { return }
                        _ = MCPShim.writeAll(fd, bytes + Data("\n".utf8))
                    }
                }.start()
            }
        }.start()
    }

    func stop() {
        close(listener)
        MCPSocketRoad.unlink(directory: directory)
    }
}

@Suite("VX-850 — the harness's waits never hold the pool the server needs", .serialized)
struct MCPHarnessPoolTests {
    /// A server that answers LATER than a hand-picked bound but inside the
    /// harness's own is HEARD: every raw wait for the server under test is
    /// bounded by `HarnessDeadline.seconds` — O-7's rule (the VX-771 run), which
    /// gave four raw helpers the harness's bound and "took them out of the
    /// family", carried to every raw wait. RED ON THE PRE-FIX HARNESS:
    /// `RawSocket`'s 5 s default gave up first (a congested pool answers that
    /// late — Phase 1/P4: 8.9 s in a full-target run).
    @Test func anAnswerLaterThanAHandPickedBoundButInsideTheHarnesssIsHeard() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let peer = try LatePeer(h, answersAfter: 6)
        defer { peer.stop() }
        try await HarnessDeadline.$seconds.withValue(10) {
            // The one raw client every stop-road suite shares, at the same time.
            async let named: Int32? = try? await namedClient(h.directory, key: "vmk1_late", as: "late-named")
            let socket = try RawSocket(h)
            defer { socket.close() }
            socket.send(#"{"jsonrpc":"2.0","id":7,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"late","version":"1"}}}"#)
            let answer = await socket.next()
            #expect(answer?["id"] as? Int == 7, "a raw wait heard a 6 s answer inside the harness's 10 s bound: \(String(describing: answer))")
            let namedFD = await named
            #expect(namedFD != nil, "the shared raw client heard it too")
            if let namedFD { close(namedFD) }
        }
    }

    /// More concurrent raw openings than the pool has threads — every one is
    /// answered. RED ON THE PRE-FIX HARNESS: `rawOpen` read its answer on the
    /// calling pool thread, so the first `activeProcessorCount` openings held
    /// every thread while the sessions that would answer them waited for one —
    /// each read ran out its bound unanswered ("got no JSON answer").
    @Test func moreOpeningsAtOnceThanThePoolHasThreadsAreAllAnswered() async throws {
        let waiters = ProcessInfo.processInfo.activeProcessorCount + 4
        let perHost = 8   // well inside a host's session cap (16)
        let harnesses = try (0..<((waiters + perHost - 1) / perHost)).map { _ in try ServerHarness() }
        defer { for h in harnesses { h.tearDown() } }
        let openings = try (0..<waiters).map { index in
            (harness: harnesses[index / perHost], name: "waiter-\(index)",
             key: try harnesses[index / perHost].setupKey(for: "waiter-\(index)"))
        }
        let started = ContinuousClock.now
        let answered: Int = await HarnessDeadline.$seconds.withValue(10) {
            await withTaskGroup(of: Bool.self) { group in
                for opening in openings {
                    group.addTask {
                        guard let (fd, answer) = try? await opening.harness.rawOpen(
                            as: opening.name, presenting: opening.key)
                        else { return false }
                        close(fd)
                        return answer["result"] != nil
                    }
                }
                var count = 0
                for await served in group where served { count += 1 }
                return count
            }
        }
        #expect(answered == waiters,
                "\(waiters - answered) of \(waiters) openings unanswered inside the 10 s bound (\(ContinuousClock.now - started)) — a wait held the pool the server needed")
    }

    /// The deadline's bound is read on ITS OWN clock — at its limit even while
    /// the whole pool is held (the family's own pattern: blocking waits inside
    /// async bodies), when a clock read after the awaiting test resumes reads the
    /// hold instead (the 15 s belt's 16–73.8 s). RED under the behavioural revert
    /// that reads `firedAfter` on the awaiting task (the pre-fix belt's place).
    /// The hold is short (0.8 s) so this pin never starves the run it sits in.
    @Test func theDeadlinesBoundIsReadOnItsOwnClockWhileThePoolIsHeld() async throws {
        let width = ProcessInfo.processInfo.activeProcessorCount
        let started = ContinuousClock.now
        let failure = await HarnessDeadline.$seconds.withValue(0.1) {
            await #expect(throws: HarnessFailure.self) {
                _ = try await HarnessDeadline.run("an act the pool starves") {
                    // Every pool thread held for 0.8 s — past the 0.1 s limit, so
                    // the awaiting test cannot resume until they let go.
                    for _ in 0..<width { Task.detached { usleep(800_000) } }
                    try await Task.sleep(for: .seconds(60))
                    return 0
                }
            }
        }
        // The hold delays the test's own resumption (wall ≥ 0.8 s) whenever the
        // blockers take every thread first — always when this pin runs alone,
        // which is where its red-on-old is read; in a full run another suite may
        // hold a thread past them, and the deadline's own reading is pinned the same.
        let wall = ContinuousClock.now - started
        #expect(failure?.firedAfter.map { $0 < .milliseconds(500) } == true,
                "the bound read on the deadline's own clock, not the pool's: \(String(describing: failure?.firedAfter)) (the test's own wall clock read \(wall))")
    }
}
