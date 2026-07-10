//
//  BridgeSession.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9b, Step 5 — the app-side Fragments-bridge lifecycle over the
//  BridgeEngine/BridgeScheduler, mirroring SyncSession's shape (wiring, not
//  building). Mac-side only this phase (the brief's explicit scope:
//  Fragments-on-phone edits land when the Mac bridge runs); the mobile
//  target constructs it disabled.
//
//  THE A4 FENCE EXTENDS (the plan's Step 5): the bridge pairs with the REAL
//  store only — a dev-store session must never land dev writes into the
//  author's live Fragments journal, nor push dev-store text there.
//
//  CONFIGURATION IS DELIBERATELY ABSENT THIS PHASE: the bridge needs the
//  author's Fragments user session + the id-derivation facts (namespace,
//  canonical user — contract asks), and the credential story is Phase 9c's
//  real sign-in (the Phase 8 paste-in retires there; the bridge must not
//  couple to it). Until 9c wires `configure(engine:)`, the session stays
//  unconfigured and the status row says so. Headless suites exercise the
//  full engine against the fake server.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class BridgeSession {
    /// The one-row functional bridge status surface.
    private(set) var status = BridgeScheduler.Status()
    var isConfigured: Bool { scheduler != nil }
    /// False on mobile (Mac-side-first scope) and for dev-store sessions
    /// (the A4 fence's bridge seam).
    let allowsBridge: Bool

    private var scheduler: BridgeScheduler?
    private var observationTasks: [Task<Void, Never>] = []

    /// The cadence throttle (review round 1, MAJOR 2): the engine's push
    /// half hash-sweeps every live journal day, and cadence triggers arrive
    /// at edit-settle rate (after every sync round) — unthrottled, an
    /// ordinary editing session re-renders the whole journal corpus over
    /// and over, the P1 failure shape. Cadence triggers therefore forward
    /// at most once per interval, with ONE trailing round scheduled so the
    /// last trigger is never lost. Manual triggers (the status row's
    /// buttons) bypass — a click is a deliberate act, not a cadence. The
    /// interval is an engineering default (the `settleDebounce` class); the
    /// P1 relaxation itself is on the author's ratify list (QUESTIONS #15).
    private let minimumRoundInterval: Duration
    private let clock = ContinuousClock()
    private var lastForwardedAt: ContinuousClock.Instant?
    private var trailingTask: Task<Void, Never>?

    init(allowsBridge: Bool, minimumRoundInterval: Duration = .seconds(60)) {
        self.allowsBridge = allowsBridge
        self.minimumRoundInterval = minimumRoundInterval
    }

    /// Builds the scheduler over a configured engine — 9c's sign-in flow is
    /// the intended production caller. Replacing a chain retires-then-drains
    /// the old one first (the SyncSession discipline: one-round-at-a-time is
    /// per-scheduler).
    func configure(engine: BridgeEngine) async {
        guard allowsBridge else { return }
        // A pending trailing cadence round must not survive reconfiguration
        // and fire into the NEW scheduler (review round 2, NIT 8).
        trailingTask?.cancel()
        trailingTask = nil
        let old = scheduler
        stopObservations()
        scheduler = nil
        if let old {
            await old.retire()
            await old.awaitIdle()
        }
        let scheduler = BridgeScheduler(engine: engine)
        self.scheduler = scheduler
        observationTasks.append(Task { [weak self] in
            for await status in await scheduler.statusUpdates() {
                self?.status = status
            }
        })
    }

    /// One bridge round, serialized/coalesced by the scheduler. Cadence
    /// triggers (`manual: false` — the AppServices after-sync hook) pass
    /// through the interval throttle above; manual triggers bypass it.
    ///
    /// Ordering honesty (review round 1, MINOR 5): the wired guarantee is
    /// ONE-DIRECTIONAL — a cadence bridge round starts only after a
    /// completed sync round. The reverse overlap (a settle-triggered sync
    /// round starting while a bridge round is still landing — bridge
    /// landings themselves grow the outbox) is possible and benign: both
    /// engines' writes are per-transaction atomic, the sync engine treats
    /// bridge-written rows as ordinary dirty rows, and the consequence
    /// class is the documented check-then-act window. Manual triggers are
    /// deliberate off-cadence escape hatches, same as "Sync now".
    func trigger(manual: Bool = false) {
        guard scheduler != nil else { return }
        if !manual, let last = lastForwardedAt,
           clock.now - last < minimumRoundInterval {
            guard trailingTask == nil else { return }  // one trailing round coalesces the burst
            let resumeAt = last + minimumRoundInterval
            let clock = clock
            trailingTask = Task { [weak self] in
                try? await Task.sleep(until: resumeAt, clock: clock)
                guard !Task.isCancelled else { return }
                self?.trailingTask = nil
                self?.forwardTrigger()
            }
            return
        }
        forwardTrigger()
    }

    private func forwardTrigger() {
        guard let scheduler else { return }
        lastForwardedAt = clock.now
        Task { await scheduler.trigger() }
    }

    func stop() {
        stopObservations()
        trailingTask?.cancel()
        trailingTask = nil
        let old = scheduler
        scheduler = nil
        if let old {
            Task { await old.retire() }
        }
    }

    private func stopObservations() {
        for task in observationTasks { task.cancel() }
        observationTasks.removeAll()
    }
}
