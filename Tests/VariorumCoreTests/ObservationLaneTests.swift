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
/// work longer than the bound — every pool thread held in 50 ms slices —
/// before the observation exists, then holds the product's own observation
/// (`observeReading`) on the lane and asks for both values inside the bound.
/// Red on old (the lane's priority reverted to the tests' own `.medium`): the
/// observation's scheduler Task, its consumer and the wait all queue behind
/// the backlog and the bound expires. The premise is asserted too — a
/// default-priority job posted with the backlog waited longer than the bound,
/// so the bound could never have covered a delivery that queued.
@Suite("VX-926 U3 — the held-observation lane jumps the run's backlog (VX-625)", .serialized)
struct ObservationLaneTests {
    /// How long the forced backlog holds the pool, and the bound it beats.
    private static let backlogSeconds = 2.0
    private static let bound: Duration = .milliseconds(750)

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
                // THE BACKLOG first, so everything the observation makes
                // below is enqueued behind it unless it rides the lane.
                let backlog = Backlog(seconds: Self.backlogSeconds)
                let held = HeldValues(db.observeReading(gathering.id))
                let initial = try await held.value(1, within: Self.bound)
                #expect(initial?.map(\.postID) == [a.id, b.id],
                        "the held observation's first value inside \(Self.bound) despite the backlog")
                try ops.setStarred(.post(b.id), starred: false)
                let afterUnstar = try await held.value(2, within: Self.bound)
                #expect(afterUnstar?.map(\.postID) == [a.id],
                        "the un-star's value inside \(Self.bound) despite the backlog")
                held.cancel()
                // The premise: the backlog was real and longer than the bound.
                let queued = try await backlog.probeWait()
                #expect(queued > Self.bound,
                        "a default-priority job posted with the backlog waited \(queued) — longer than the bound")
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
