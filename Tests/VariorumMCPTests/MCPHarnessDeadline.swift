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

    /// Run `body` under the deadline. The timer is GCD's, never a task on the
    /// cooperative pool, so it fires whatever `body` is doing — `body` need
    /// not honor cancellation (the SDK's awaits do not). On expiry
    /// `onTimeout` runs (the harness ends the act's connection there, which
    /// lets `body` finish failing in the background) and `body`'s task is
    /// cancelled; its eventual result is dropped.
    static func run<T: Sendable>(
        _ act: String, onTimeout: @escaping @Sendable () -> Void = {},
        _ body: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        let limit = seconds
        let gate = HarnessGate<T>()
        return try await withCheckedThrowingContinuation { continuation in
            gate.arm(continuation)
            let work = Task {
                do { gate.resume(.success(try await body())) } catch { gate.resume(.failure(error)) }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + limit) {
                let expired = HarnessFailure(
                    "\(act) did not finish within \(limit) s — the harness's time limit (VX-132)")
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
