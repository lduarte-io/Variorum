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

@Suite("VX-850 — the harness's waits never hold the pool the server needs", .serialized)
struct MCPHarnessPoolTests {
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
}
