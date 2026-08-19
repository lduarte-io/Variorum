import Dependencies
import Foundation

/// Phase 8, amendment A3 — the engine-lifecycle layer.
///
/// The app's triggers (foreground, post-write debounce, background
/// transition) can fire concurrently; engine rounds must serialize. This
/// actor makes the guarantee explicit rather than relying on accidental
/// timing:
///
///  - **one round at a time** — a round is pull → push, pinned in that
///    order (reconcile before draining: the order that materializes
///    conflicts before acks can hide them);
///  - **coalescing** — any number of triggers arriving mid-round collapse
///    into AT MOST ONE follow-up round;
///  - **offline is free** — any error (network down, an iOS
///    file-protection window after device lock) skips the round, keeps the
///    outbox intact, surfaces a status message, and waits for the next
///    trigger. An error is never corruption and never touches state.
///
/// Rounds run in a `Task` inheriting the trigger's task-local dependency
/// context — in the app that is the installed live `\.database`; tests bind
/// their own world around `trigger()`.
public actor SyncScheduler {
    /// The one-row functional sync status surface (SyncSpec §10's "sync
    /// status indicator" scope, nothing more).
    public struct Status: Equatable, Sendable {
        public var isSyncing = false
        /// Wall-clock stamp of the last round that completed without error
        /// (display data only — never sync ordering, SyncSpec §9).
        public var lastSuccessAt: Date?
        /// The last round's failure, verbatim; nil after a clean round.
        public var lastError: String?
        /// True when `lastError` is an offline/unreachable-network class
        /// (Phase 11, Step A0 — the KnownIssues row re-owned from 10):
        /// offline is FREE by design (this scheduler's own posture — outbox
        /// kept, next trigger retries), so the status surface presents it
        /// as waiting/pending, never as a failure. Presentation-only
        /// classification; round behavior is untouched.
        public var lastErrorIsOffline = false
        /// Outbox rows still owed to the server after the last round.
        public var pendingPushCount = 0
        /// Rounds finished (clean or failed) — test observability.
        public var roundsCompleted = 0
        public init() {}
    }

    /// The offline/unreachable classification (Phase 11, Step A0) — a pure
    /// function from a round's error to "is this the designed-for offline
    /// state?". True exactly for URLError's network-down/unreachable codes
    /// (directly or anywhere in the NSError underlying chain, so a wrapped
    /// transport/auth-refresh failure classifies too). Everything else —
    /// HTTP refusals, CAS/schema errors, signed-out — keeps the error face.
    public static func isOfflineError(_ error: any Error) -> Bool {
        // URLError bridges to NSURLErrorDomain, so the NSError walk covers
        // both the typed and the bridged form.
        let offlineCodes: Set<Int> = [
            URLError.notConnectedToInternet.rawValue,
            URLError.networkConnectionLost.rawValue,
            URLError.cannotConnectToHost.rawValue,
            URLError.cannotFindHost.rawValue,
            URLError.dnsLookupFailed.rawValue,
            URLError.timedOut.rawValue,
            URLError.dataNotAllowed.rawValue,
            URLError.internationalRoamingOff.rawValue,
        ]
        var current: NSError? = error as NSError
        var depth = 0
        while let nsError = current, depth < 8 {
            if nsError.domain == NSURLErrorDomain, offlineCodes.contains(nsError.code) {
                return true
            }
            current = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
            depth += 1
        }
        return false
    }

    @Dependency(\.database) private var database
    @Dependency(\.date) private var date

    private let engine: SyncEngine
    /// Phase 13j: the purge janitor "rides the existing sync scheduler"
    /// (the memo's §4b) — nil where the composition's transport has no
    /// purge surface (test wrappers; the session wires one exactly when
    /// its transport conforms). A sweep runs after each CLEAN round, and
    /// a sweep failure never fails the round: the round's data work
    /// already landed, and the janitor's designed no-op conditions
    /// (no horizon) return quietly rather than throwing. Genuine sweep
    /// faults surface on the status row without erasing the round's
    /// success stamp.
    private let janitor: PurgeJanitor?
    private var running = false
    private var followUpRequested = false
    /// Set once by `retire()`; a retired scheduler never starts a round.
    private var retired = false
    private var idleWaiters: [CheckedContinuation<Void, Never>] = []
    private var statusContinuations: [Int: AsyncStream<Status>.Continuation] = [:]
    private var nextContinuationKey = 0

    public private(set) var status = Status()

    public init(engine: SyncEngine, janitor: PurgeJanitor? = nil) {
        self.engine = engine
        self.janitor = janitor
    }

    // MARK: - Triggering

    /// Requests a sync round. Serialized and coalescing: if a round is
    /// already running, at most one follow-up round is scheduled no matter
    /// how many triggers arrive. A retired scheduler refuses.
    public func trigger() {
        guard !retired else { return }
        guard !running else {
            followUpRequested = true
            return
        }
        running = true
        Task { await self.runLoop() }
    }

    /// Retires this scheduler permanently: no NEW round can ever start
    /// (the current one, if any, finishes and `awaitIdle` observes it).
    /// The session layer retires a chain BEFORE draining and replacing it —
    /// a trigger Task that captured the old scheduler before the swap must
    /// not be able to revive the retired chain after the drain (Phase 8
    /// review round 2; the follow-up flag is cleared for the same reason).
    public func retire() {
        retired = true
        followUpRequested = false
    }

    /// Suspends until no round is running and no follow-up is pending —
    /// teardown flushes and deterministic tests.
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
        status.isSyncing = true
        publishStatus()
        // 13j ladder B (B2): the LEDGER RECONCILIATION runs BEFORE the
        // round's drain — a returner's outbox is screened against other
        // devices' purges before anything pushes, so a never-pushed CHILD
        // of a meanwhile-purged family (the one id no ledger can name) is
        // swept with its family instead of landing as a permanent mirror
        // orphan under a missing parent — the poison-row jam every peer's
        // pull would then stall on forever. The round's own pull→push
        // order (A3) is untouched: this is a purge-bookkeeping read+local
        // drop, never engine work. The SAY-SO floor gate (round 10) now
        // refuses the WHOLE round — outbox intact, cursor unmoved, the
        // §12 grammar — instead of speaking only after one drain already
        // ran; any other pre-pass fault (offline, keys) is left for the
        // round's own error posture, which sees the same transport.
        if let janitor {
            do {
                _ = try await janitor.reconcileLedger()
            } catch let error as SyncError {
                if case .deviceLeftBehindReloadRequired = error {
                    status.lastError = String(describing: error)
                    status.lastErrorIsOffline = false
                    status.pendingPushCount =
                        (try? await outboxCount()) ?? status.pendingPushCount
                    status.isSyncing = false
                    status.roundsCompleted += 1
                    publishStatus()
                    return
                }
                // Anything else: the round's own attempt decides.
            } catch {
                // Transport/keys faults: the round's own attempt decides.
            }
        }
        do {
            // Pinned: pull → push (A3).
            _ = try await engine.pull()
            _ = try await engine.push()
            status.lastError = nil
            status.lastErrorIsOffline = false
            status.lastSuccessAt = date.now
            // Phase 13j: the janitor sweeps AFTER a clean round — the
            // order her round-10 wording implies (unsynced writes pushed
            // first; the sweep's say-so, if it ever fires, comes after
            // the drain saved everything typed). A sweep fault surfaces
            // on the status row but never un-succeeds the round.
            if let janitor {
                do {
                    _ = try await janitor.sweep()
                } catch {
                    status.lastError = String(describing: error)
                    status.lastErrorIsOffline = Self.isOfflineError(error)
                }
            }
        } catch {
            // Offline / protected-data / server hiccup: the round is
            // skipped, the outbox keeps everything, the next trigger
            // retries. Never a reason to touch state.
            status.lastError = String(describing: error)
            status.lastErrorIsOffline = Self.isOfflineError(error)
        }
        status.pendingPushCount = (try? await outboxCount()) ?? status.pendingPushCount
        status.isSyncing = false
        status.roundsCompleted += 1
        publishStatus()
    }

    private func outboxCount() async throws -> Int {
        try await database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
        }
    }

    // MARK: - Status observation

    /// A live status feed for the status row; yields the current value
    /// immediately, then every change.
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
