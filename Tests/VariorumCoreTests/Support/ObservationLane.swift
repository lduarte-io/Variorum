import Dependencies
import Foundation
import GRDB

/// **THE HELD-OBSERVATION LANE** (VX-926 U3 — VX-625; the trace is the U3
/// record in `notes/plans/fixes/vx-926-test-flakes.md`).
///
/// A held `AsyncValueObservation` reaches a test through TWO cooperative-pool
/// hops: GRDB's default `.task` scheduler runs the notification on a Task of
/// its own, then the consumer's `next()` resumes. In a full-parallel
/// `swift test` both hops queue FIFO behind every test case not yet started —
/// Swift Testing's default parallelization width is unbounded, so the whole
/// target is a child task the moment the run begins, and a resumed job joins
/// the back of that queue. Measured on an idle machine: a first emission GRDB
/// had ready in 5 ms reached its test after 272.6 s (hop 1 191.5 s, hop 2
/// 81.0 s). So a wall-clock bound on such a wait — a `.timeLimit`, a deadline
/// poll — measures the RUNNER'S QUEUE, not the observation; that is how
/// `StarContextTests`' one-minute pin read 205 s three times.
///
/// The lane runs the observation's whole chain at `.high` priority. A `Task`
/// inherits its creator's priority, so everything made on the lane — GRDB's
/// scheduler Task (created where the observation is made), `HeldValues`'
/// consumer, a poll's sleep — is dequeued ahead of the default-priority
/// backlog, and a bound measured inside the lane measures the delivery.
/// (`ObservationLaneTests` pins it: a forced backlog the bound cannot cover
/// is jumped.)
///
/// The rules, all three needed:
/// - MAKE the observation, HOLD it and WAIT for it inside the lane (an
///   observation made outside it keeps a default-priority scheduler Task).
/// - Bound the wait with `HeldValues`' own bound, never a `.timeLimit`: the
///   test task's own resumption after the lane returns is outside it, and
///   Swift Testing's limit is measured across that hop too.
/// - The lane is for HELD OBSERVATIONS whose waits carry a bound; an
///   unbounded `next()` only waits longer under the backlog and never reds.
func onTheObservationLane<T: Sendable>(
    _ body: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await Task(priority: observationLanePriority) { try await body() }.value
}

/// The lane's priority: above the `.medium` every Swift Testing test task
/// runs at (measured: 21), so its jobs never queue behind the run's backlog.
let observationLanePriority: TaskPriority = .high

/// One held observation's deliveries, in order, consumed on a Task of its
/// own (the app's shape: a view model holds an observation the same way).
/// Construct it ON THE LANE (`onTheObservationLane`) — the consumer Task
/// inherits the lane's priority from its creator.
final class HeldValues<Value: Sendable>: Sendable {
    /// The harness's one bound for an observation's delivery (the MCP
    /// harness's `HarnessDeadline.seconds` precedent): generous, because it
    /// waits for an EVENT — on the lane a healthy delivery takes milliseconds.
    static var defaultBound: Duration { .seconds(30) }

    private let delivered = LockIsolated<[Value]>([])
    private let consumer: Task<Void, Never>

    init(_ observation: AsyncValueObservation<Value>) {
        precondition(
            Task.currentPriority >= observationLanePriority,
            "hold an observation ON THE LANE — onTheObservationLane { } (VX-625)")
        let delivered = delivered
        consumer = Task {
            do {
                for try await value in observation { delivered.withValue { $0.append(value) } }
            } catch {}
        }
    }

    deinit { consumer.cancel() }

    /// Stops holding (the observation is cancelled with its consumer).
    func cancel() { consumer.cancel() }

    /// Every value delivered so far, in order.
    var values: [Value] { delivered.value }

    /// The `n`th value delivered (1-based), or nil when it has not arrived
    /// within `bound`.
    func value(_ n: Int, within bound: Duration = defaultBound) async throws -> Value? {
        try await first(within: bound) { $0.count >= n ? $0[n - 1] : nil }
    }

    /// The LATEST value delivered, once it satisfies `predicate`, or nil when
    /// none has within `bound` — for an observation that may COALESCE (a
    /// pool's concurrent observer can skip an intermediate state).
    func latest(
        where predicate: @escaping (Value) -> Bool, within bound: Duration = defaultBound
    ) async throws -> Value? {
        try await first(within: bound) { values in
            guard let last = values.last, predicate(last) else { return nil }
            return last
        }
    }

    private func first(
        within bound: Duration, _ pick: ([Value]) -> Value?
    ) async throws -> Value? {
        precondition(
            Task.currentPriority >= observationLanePriority,
            "wait for a held observation ON THE LANE (VX-625)")
        let deadline = ContinuousClock.now + bound
        while true {
            if let value = pick(delivered.value) { return value }
            if ContinuousClock.now >= deadline { return nil }
            try await Task.sleep(for: .milliseconds(2))
        }
    }
}
