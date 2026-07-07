//
//  SyncSession.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8, Step 6 — the app-side sync lifecycle over the Phase 5 engine:
//  wiring, not building (SyncSpec §10). One SyncScheduler (A3: serialized,
//  coalescing, pull→push) over SupabaseTransport with a foreground-simple
//  schedule; offline is free — the outbox queues, capture never blocks on
//  the network.
//
//  THE A4 FENCE, SYNC SEAM (review round 1, BLOCKER): there is exactly ONE
//  production mirror, and it pairs with the REAL store only. Debug and
//  release builds share a bundle identity and therefore a Keychain, so
//  once the author pastes credentials, an ungated dev-store session would
//  auto-configure sync, pull her whole corpus into the dev store, and push
//  every dev-session write — a dev bug's destructive writes included —
//  into the mirror that replicates to her real devices. `allowsSync` is
//  therefore derived from the store variant (AppServices): a dev-store
//  session NEVER configures sync — not from persisted credentials, not
//  from the setup form.
//
//  Triggers wired HERE (both platforms): after local writes settle (the
//  outbox observation, debounced). Platform files add their own: foreground/
//  became-active, launch, and the iOS background transition.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@MainActor
@Observable
final class SyncSession {
    /// The one-row functional status surface (SyncSpec §10 scope).
    private(set) var status = SyncScheduler.Status()
    private(set) var credentials: SyncCredentials?
    var isConfigured: Bool { scheduler != nil }
    /// False for dev-store sessions (the A4 fence's sync seam, above).
    let allowsSync: Bool

    private let database: AppDatabase
    /// Post-write settle debounce: outbox growth quiets down for this long
    /// before a round runs (keystroke-rate autosaves coalesce; S1's outbox
    /// absorbs the rest).
    private let settleDebounce: Duration
    /// Injectable credentials source (tests never touch the real Keychain).
    private let loadCredentials: () -> SyncCredentials?
    private var scheduler: SyncScheduler?
    private var observationTasks: [Task<Void, Never>] = []
    private var settleTask: Task<Void, Never>?

    init(
        database: AppDatabase,
        allowsSync: Bool = true,
        settleDebounce: Duration = .seconds(3),
        loadCredentials: @escaping () -> SyncCredentials? = { SyncCredentialsStore.load() }
    ) {
        self.database = database
        self.allowsSync = allowsSync
        self.settleDebounce = settleDebounce
        self.loadCredentials = loadCredentials
    }

    /// Loads persisted credentials (Keychain) and configures if present —
    /// refused wholesale for dev-store sessions (the fence). Returns whether
    /// sync is now configured.
    @discardableResult
    func loadPersistedCredentials() async -> Bool {
        guard allowsSync else { return false }
        if let stored = loadCredentials() {
            await configure(with: stored, persist: false)
        }
        return isConfigured
    }

    /// Builds the transport → engine → scheduler chain and starts the
    /// write-settle + status observations. Re-configuring (a key rotation
    /// re-paste) replaces the chain — after DRAINING the old one: the old
    /// scheduler may be mid-round, and A3's one-round-at-a-time guarantee
    /// is per-scheduler, so the session must never let a new chain run
    /// while the old round is in flight (review round 1, MINOR).
    func configure(with credentials: SyncCredentials, persist: Bool) async {
        guard allowsSync else { return }
        self.credentials = credentials
        if persist {
            SyncCredentialsStore.save(credentials)
        }
        let transport = SupabaseTransport(configuration: credentials.transportConfiguration)
        await configure(transport: transport)
    }

    /// The transport-level tail (internal seam — tests inject fakes here;
    /// production funnels through `configure(with:persist:)`).
    func configure(transport: any SyncTransport) async {
        guard allowsSync else { return }
        let old = scheduler
        stopObservations()
        scheduler = nil
        if let old {
            // Retire FIRST, then drain: a `triggerSync` Task that captured
            // the old scheduler before this swap must not revive the
            // retired chain after the drain (review round 2) — a retired
            // scheduler refuses all new rounds; awaitIdle covers the one
            // already in flight.
            await old.retire()
            await old.awaitIdle()
        }

        let scheduler = SyncScheduler(engine: SyncEngine(transport: transport))
        self.scheduler = scheduler

        // Status → the observable surface.
        observationTasks.append(Task { [weak self] in
            for await status in await scheduler.statusUpdates() {
                self?.status = status
            }
        })
        // Local writes settle → one round. The outbox observation fires at
        // write rate; the debounce coalesces a burst into one trigger.
        observationTasks.append(Task { [weak self, database] in
            do {
                for try await pending in database.observe({ db in
                    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
                }) {
                    guard let self, pending > 0 else { continue }
                    self.scheduleSettleTrigger()
                }
            } catch {
                // Observation ended (cancellation/teardown) — triggers from
                // foreground events still run rounds.
            }
        })
    }

    /// One sync round, serialized/coalesced by the scheduler (A3).
    func triggerSync() {
        guard let scheduler else { return }
        Task { await scheduler.trigger() }
    }

    /// Waits for in-flight rounds — the iOS background transition uses this
    /// to push before suspension.
    func flush() async {
        guard let scheduler else { return }
        await scheduler.trigger()
        await scheduler.awaitIdle()
    }

    /// Teardown only (no new chain follows; an in-flight round finishes on
    /// its own). Chain REPLACEMENT goes through `configure`, which drains.
    /// Retiring closes the stale-trigger door here too.
    func stop() {
        stopObservations()
        let old = scheduler
        scheduler = nil
        if let old {
            Task { await old.retire() }
        }
    }

    private func stopObservations() {
        for task in observationTasks { task.cancel() }
        observationTasks.removeAll()
        settleTask?.cancel()
        settleTask = nil
    }

    private func scheduleSettleTrigger() {
        settleTask?.cancel()
        settleTask = Task { [weak self, settleDebounce] in
            guard (try? await Task.sleep(for: settleDebounce)) != nil else { return }
            guard !Task.isCancelled else { return }
            self?.triggerSync()
        }
    }
}
