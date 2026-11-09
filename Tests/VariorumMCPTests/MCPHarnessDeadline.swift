import Dispatch
import Foundation

// VX-132 — THE HARNESS's TIME LIMITS (the run record
// `notes/plans/fixes/vx-184-mcp-launch-polish.md`, U1 — "VX-132 — the trace").
// The pinned MCP SDK gives no request a time limit (`Client.sendAndAwait` parks
// a continuation only an answer, a disconnect or a cancellation notification
// resumes, and it ignores the caller's cancellation), so a test whose answer
// never comes waited forever and stalled the whole `VariorumMCPTests` run.
// Every act the harness drives — a connect, a tool call, a tool listing — now
// runs under a deadline and fails NAMED instead.

/// A bounded act: `run` returns `body`'s outcome, or throws a `HarnessFailure`
/// naming the act once `seconds` pass first.
enum HarnessDeadline {
    /// How long one act may take. Generous (an act normally answers in
    /// milliseconds; a loaded machine in a few seconds) and TASK-LOCAL, so a
    /// pin shortens it for its own body without touching any other test.
    @TaskLocal static var seconds: Double = 30

    /// **The deadline's own queue** (VX-850 — the VX-926 run, U1): a queue of
    /// its own targets GCD's OVERCOMMIT root queue, so its timer gets a thread
    /// even while every cooperative-pool thread is held. `DispatchQueue.global()`
    /// — what the timer used before — is a CONSTRAINED root queue that shares
    /// its width with the cooperative pool: with the pool full, a 0.1 s limit
    /// fired at 0.81 s (`MCPHarnessPoolTests`'s own-clock pin, before this).
    private static let timer = DispatchQueue(label: "variorum.mcp.harness-deadline")

    /// Run `body` under the deadline. The timer is GCD's, never a task on the
    /// cooperative pool, so it fires whatever `body` is doing — `body` need
    /// not honor cancellation (the SDK's awaits do not). On expiry
    /// `onTimeout` runs (the harness ends the act's connection there, which
    /// lets `body` finish failing in the background) and `body`'s task is
    /// cancelled; its eventual result is dropped.
    ///
    /// VX-850 (the VX-926 run, U1): the expiry carries `firedAfter` — how long
    /// after arming the timer fired, read ON THE TIMER'S OWN THREAD. A belt on
    /// the harness's bound reads that, never a wall clock taken after the
    /// awaiting test resumes: resuming needs a cooperative-pool thread, so a
    /// test-side clock measures how long the pool stayed full (73.8 s against
    /// a 1 s limit under Phase 1's C3), not the harness.
    static func run<T: Sendable>(
        _ act: String, onTimeout: @escaping @Sendable () -> Void = {},
        _ body: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        let limit = seconds
        let gate = HarnessGate<T>()
        let armed = ContinuousClock.now
        return try await withCheckedThrowingContinuation { continuation in
            gate.arm(continuation)
            let work = Task {
                do { gate.resume(.success(try await body())) } catch { gate.resume(.failure(error)) }
            }
            timer.asyncAfter(deadline: .now() + limit) {
                let expired = HarnessFailure(
                    "\(act) did not finish within \(limit) s — the harness's time limit (VX-132)",
                    firedAfter: ContinuousClock.now - armed)
                if gate.resume(.failure(expired)) {
                    onTimeout()
                    work.cancel()
                }
            }
        }
    }
}

/// A continuation resumed exactly once — by whichever of the act and its
/// deadline comes first.
private final class HarnessGate<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<T, Error>?

    func arm(_ continuation: CheckedContinuation<T, Error>) {
        lock.withLock { self.continuation = continuation }
    }

    /// Resume with `result` if nothing has yet; returns whether this call did.
    @discardableResult
    func resume(_ result: Result<T, Error>) -> Bool {
        let continuation: CheckedContinuation<T, Error>? = lock.withLock {
            defer { self.continuation = nil }
            return self.continuation
        }
        guard let continuation else { return false }
        continuation.resume(with: result)
        return true
    }
}
