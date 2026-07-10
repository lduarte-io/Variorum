import Dependencies
import Foundation

/// Phase 9b — the bridge's lifecycle actor, patterned exactly on
/// `SyncScheduler` (A3): one round at a time (pull → push inside
/// `BridgeEngine.run()`), triggers arriving mid-round coalesce into at most
/// one follow-up, any error skips the round with ALL state intact (cursor,
/// day hashes — offline is free; an error is never corruption), and a
/// retired scheduler never starts another round.
///
/// The bridge deliberately has no cadence of its own: the app layer triggers
/// it AFTER sync rounds complete (never interleaved with one), so a
/// Fragments landing always sees the store the mirror sync just settled.
public actor BridgeScheduler {
    /// The one-row functional bridge status surface (the phase's only UI).
    public struct Status: Equatable, Sendable {
        public var isBridging = false
        /// Wall-clock stamp of the last clean round (display data only).
        public var lastSuccessAt: Date?
        /// The last round's failure, verbatim; nil after a clean round.
        public var lastError: String?
        /// Days currently holding the duplicate-day push pause — shown
        /// until the author hand-merges (never newest-wins).
        public var pausedDays: [String] = []
        /// The landing cursor stalled this round (a row it could not land
        /// yet — retried next round). Persistent truth means a jammed feed;
        /// it must be VISIBLE (review round 1, MINOR 4: "record, don't
        /// guess" — a silent stall is a silently frozen bridge).
        public var stalled = false
        /// The last round's attention notes: rejected pushes (a per-day
        /// rejection recurs every round and would otherwise freeze that
        /// day's projection invisibly), deferred/stalled landings, and
        /// consumed-with-note rows. Empty after a fully clean round.
        public var issueNotes: [String] = []
        /// Rounds finished (clean or failed) — test observability.
        public var roundsCompleted = 0
        public init() {}
    }

    @Dependency(\.date) private var date

    private let engine: BridgeEngine
    private var running = false
    private var followUpRequested = false
    private var retired = false
    private var idleWaiters: [CheckedContinuation<Void, Never>] = []
    private var statusContinuations: [Int: AsyncStream<Status>.Continuation] = [:]
    private var nextContinuationKey = 0

    public private(set) var status = Status()

    public init(engine: BridgeEngine) {
        self.engine = engine
    }

    // MARK: - Triggering

    /// Requests a bridge round; serialized and coalescing, exactly the
    /// SyncScheduler contract. A retired scheduler refuses.
    public func trigger() {
        guard !retired else { return }
        guard !running else {
            followUpRequested = true
            return
        }
        running = true
        Task { await self.runLoop() }
    }

    /// Permanently retires this scheduler: no NEW round can start; a round
    /// already in flight finishes and `awaitIdle` observes it.
    public func retire() {
        retired = true
        followUpRequested = false
    }

    /// Suspends until no round is running and no follow-up is pending.
    public func awaitIdle() async {
        guard running else { return }
        await withCheckedContinuation { idleWaiters.append($0) }
    }

    // MARK: - The serialized loop

    private func runLoop() async {
        repeat {
            followUpRequested = false
            await runOneRound()
        } while followUpRequested
        running = false
        let waiters = idleWaiters
        idleWaiters.removeAll()
        for waiter in waiters { waiter.resume() }
    }

    private func runOneRound() async {
        status.isBridging = true
        publishStatus()
        do {
            let report = try await engine.run()
            status.lastError = nil
            status.lastSuccessAt = date.now
            status.pausedDays = report.push.pausedDays
            status.stalled = report.landing.stalled
            status.issueNotes = report.landing.notes + report.push.notes
        } catch {
            // Offline / signed-out / server hiccup: the round is skipped,
            // the cursor and day hashes keep everything, the next trigger
            // retries. Never a reason to touch state.
            status.lastError = String(describing: error)
        }
        status.isBridging = false
        status.roundsCompleted += 1
        publishStatus()
    }

    // MARK: - Status observation

    /// A live status feed; yields the current value immediately, then every
    /// change.
    public func statusUpdates() -> AsyncStream<Status> {
        let key = nextContinuationKey
        nextContinuationKey += 1
        return AsyncStream { continuation in
            statusContinuations[key] = continuation
            continuation.yield(status)
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeStatusContinuation(key) }
            }
        }
    }

    private func removeStatusContinuation(_ key: Int) {
        statusContinuations[key] = nil
    }

    private func publishStatus() {
        for continuation in statusContinuations.values {
            continuation.yield(status)
        }
    }
}
