import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// VX-926 U3 (VX-625) — **the held-observation lane jumps the run's backlog.**
///
/// The mechanism (the U3 record, `notes/plans/fixes/vx-926-test-flakes.md`):
/// a held observation's value reaches its test through two cooperative-pool
/// hops, and in a full-parallel run each hop queues FIFO behind every test
/// not yet started — Swift Testing's default width is unbounded — so a
/// wall-clock bound on the wait measures the runner's queue (StarContext's
/// one-minute pin read 205 s three times; a first emission GRDB had ready in
/// 5 ms waited 272.6 s on an idle machine).
///
/// The pin makes that deterministic: it queues a BACKLOG of default-priority
/// work — every pool thread held in 50 ms slices — and a default-priority
/// PROBE behind it, before the observation exists, then holds the product's
/// own observation (`observeReading`) on the lane and asserts ORDER: both
/// values arrive while the probe has not yet started. Red on old (the lane's
/// priority reverted to the tests' own `.medium`): the observation's
/// scheduler Task and its consumer are enqueued AFTER the probe, so the probe
/// starts first — deterministically, with no wall clock in the verdict.
/// (Ladder round 1, F-R1-6: the pin used to bound both values by 0.75 s of
/// wall, which a full run's long synchronous test segments could outlast — a
/// `.high` job still waits for a thread to finish what it is running; they
/// delay the probe, 480 slices behind, at least as much, so ORDER cannot red
/// on them.) `HeldValues`' own 30 s bound stays as the hang-ender. The
/// premise is asserted too — the probe waited longer than `premiseFloor`, so
/// the backlog was real and the order means the lane jumped it.
@Suite("VX-926 U3 — the held-observation lane jumps the run's backlog (VX-625)", .serialized)
struct ObservationLaneTests {
    /// How long the forced backlog holds the pool.
    private static let backlogSeconds = 2.0
    /// The premise's floor: the probe waited at least this long behind the
    /// backlog — so values that beat it beat a real queue, not a near-empty one.
    private static let premiseFloor: Duration = .milliseconds(750)

    @Test func aHeldObservationOnTheLaneIsHeardWhileThePoolsQueueHoldsABacklog() async throws {
        try await withOperationsAsync { ops, db in
            let tag = try ops.createTag(name: "drafts")
            let a = try ops.importPost(title: "a", text: "one").container
            let b = try ops.importPost(title: "b", text: "two").container
            _ = try ops.applyTag(tag.id, toPost: a.id)
            try ops.setStarred(.post(a.id), starred: true)
            try ops.setStarred(.post(b.id), starred: true)
            let gathering = try ops.createReading(
                name: "the gathering", kind: .gathering, querySpec: try RuleGrammar.encode(.star))

            try await onTheObservationLane {
                // THE BACKLOG and its probe first, so everything the
                // observation makes below is enqueued behind both unless it
                // rides the lane.
                let backlog = Backlog(seconds: Self.backlogSeconds)
                let held = HeldValues(db.observeReading(gathering.id))
                let initial = try await held.value(1)   // HeldValues' 30 s bound: the hang-ender
                let probeBeforeInitial = backlog.probeHasStarted   // read at the return, before anything else
                #expect(initial?.map(\.postID) == [a.id, b.id], "the held observation's first value")
                #expect(!probeBeforeInitial,
                        "the first value arrived BEFORE the default-priority probe posted behind the backlog started")
                try ops.setStarred(.post(b.id), starred: false)
                let afterUnstar = try await held.value(2)
                let probeBeforeUnstar = backlog.probeHasStarted
                #expect(afterUnstar?.map(\.postID) == [a.id], "the un-star's value")
                #expect(!probeBeforeUnstar,
                        "the un-star's value arrived BEFORE the default-priority probe posted behind the backlog started")
                held.cancel()
                // The premise: the backlog was real — the probe queued behind it.
                let queued = try await backlog.probeWait()
                #expect(queued > Self.premiseFloor,
                        "the default-priority probe posted behind the backlog waited \(queued) — longer than \(Self.premiseFloor)")
            }
        }
    }
}

/// A forced backlog on the cooperative pool's DEFAULT-priority queue: enough
/// 50 ms blocking slices that the pool's threads (one per active processor)
/// are held `seconds` in all, plus one probe job posted last that records how
/// long it waited to start. Blocking (`usleep`), not spinning: it holds
/// threads without loading the CPU.
private final class Backlog: Sendable {
    private let started = LockIsolated<Duration?>(nil)

    init(seconds: Double) {
        let slice: UInt32 = 50_000
        let slices = Int((seconds / 0.05).rounded(.up)) * ProcessInfo.processInfo.activeProcessorCount
        for _ in 0..<slices {
            Task.detached(priority: .medium) { usleep(slice) }
        }
        let posted = ContinuousClock.now
        let started = started
        Task.detached(priority: .medium) { started.setValue(ContinuousClock.now - posted) }
    }

    /// Whether the probe, posted behind every slice, has started yet (a read,
    /// never a wait).
    var probeHasStarted: Bool { started.value != nil }

    /// How long the probe, posted behind every slice, waited to start —
    /// POLLED, never awaited: awaiting its task from the lane would escalate
    /// it to the lane's priority and it would jump the very backlog it times.
    func probeWait() async throws -> Duration {
        while true {
            if let wait = started.value { return wait }
            try await Task.sleep(for: .milliseconds(10))
        }
    }
}
