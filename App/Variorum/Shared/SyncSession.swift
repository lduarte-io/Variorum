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

    private let database: AppDatabase
    /// Post-write settle debounce: outbox growth quiets down for this long
    /// before a round runs (keystroke-rate autosaves coalesce; S1's outbox
    /// absorbs the rest).
    private let settleDebounce: Duration
    private var scheduler: SyncScheduler?
    private var observationTasks: [Task<Void, Never>] = []
    private var settleTask: Task<Void, Never>?

    init(database: AppDatabase, settleDebounce: Duration = .seconds(3)) {
        self.database = database
        self.settleDebounce = settleDebounce
    }

    /// Loads persisted credentials (Keychain) and configures if present.
    /// Returns whether sync is now configured.
    @discardableResult
    func loadPersistedCredentials() -> Bool {
        if let stored = SyncCredentialsStore.load() {
            configure(with: stored, persist: false)
        }
        return isConfigured
    }

    /// Builds the transport → engine → scheduler chain and starts the
    /// write-settle + status observations. Re-configuring (a key rotation
    /// re-paste) replaces the chain.
    func configure(with credentials: SyncCredentials, persist: Bool) {
        stop()
        self.credentials = credentials
        if persist {
            SyncCredentialsStore.save(credentials)
        }
        let transport = SupabaseTransport(configuration: credentials.transportConfiguration)
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

    func stop() {
        for task in observationTasks { task.cancel() }
        observationTasks.removeAll()
        settleTask?.cancel()
        settleTask = nil
        scheduler = nil
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
