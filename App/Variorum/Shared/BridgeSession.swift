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

    init(allowsBridge: Bool) {
        self.allowsBridge = allowsBridge
    }

    /// Builds the scheduler over a configured engine — 9c's sign-in flow is
    /// the intended production caller. Replacing a chain retires-then-drains
    /// the old one first (the SyncSession discipline: one-round-at-a-time is
    /// per-scheduler).
    func configure(engine: BridgeEngine) async {
        guard allowsBridge else { return }
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

    /// One bridge round, serialized/coalesced by the scheduler. Wired to
    /// fire AFTER sync rounds complete (AppServices), never interleaved
    /// with one.
    func trigger() {
        guard let scheduler else { return }
        Task { await scheduler.trigger() }
    }

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
    }
}
