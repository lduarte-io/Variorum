//
//  ProtectionController.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-329 U1 — THE CONTROLLER'S ROAD ARMS, and only those. Through 13p and pre-13x this was today's protection brain
//  (custody transitions, the posture and its effective gate, the launch reconcile, the follow, the migration's confirm,
//  the notices, the one-secret hooks); all of that was today's deciding and writing road and was deleted at the release
//  switch (CastleRules rule 26 — the protection core under `Sources/VariorumCore/Protection/` and its app road under
//  `Shared/Protection/` decide and write everything now). What stands is what the road still needs the bootstrap to own:
//
//    - THE RELOCK MONITORS (Mac — sleep · screen lock · idle; VX-308 U4 — VX-445): each trigger asks the OPEN library's
//      policy at fire time (`roadRelock` — the bootstrap's `roadRelockPolicy`: Castle, with this Mac's sealed idle
//      minutes; nil where nothing locks) and ends at the bootstrap's one lock (`performLock`).
//    - THE IDLE CLOCK's stamp (decision 18 — time since Variorum was last used): the Mac's event monitor and both
//      platforms' became-active hooks stamp it.
//    - THE SETTINGS PANE REQUEST (VX-206's road, VX-307 U2a's use): a crossing's reopen rebuilds the Settings scene at
//      its default pane; the crossing asks for Protection back, and the scene adopts the request. VX-486: the locked
//      sync row's door asks the same way (`requestProtectionPane`).
//

import Foundation
import Observation

@MainActor
@Observable
final class ProtectionController {
    init() {}

    /// Wired by AppBootstrap: the lock act (Castle only; the callee re-checks).
    @ObservationIgnored var performLock: (@MainActor () async -> Void)?
    /// VX-308 U4 — VX-445: the OPEN library's relock policy, wired by AppBootstrap (`roadRelockPolicy` — Castle, with
    /// this Mac's sealed idle minutes; nil when nothing open locks).
    @ObservationIgnored var roadRelock: (@MainActor () -> RoadRelockPolicy?)?
    /// pre-13x 2a: the idle clock's stamp — when Variorum was last USED (decision 18). The Mac's event monitor and the
    /// became-active hook stamp it; `relockIfIdle` reads it.
    @ObservationIgnored private(set) var lastUsedAt: Date?

    /// The idle clock's stamp (decision 18): called from the Mac's event monitor and both platforms' became-active
    /// hooks.
    func noteActivity(now: Date = Date()) {
        lastUsedAt = now
    }

    // MARK: - VX-206 — Settings asked back to Protection

    /// **A REQUEST that Settings adopts (its pane → Protection)** — the twin of `MCPDoor.settingsRequest`, the one
    /// programmatic open-at-pane road (the VX-214 machinery ruling). A crossing's reopen rebuilds the `.ready` tree, and
    /// the Settings window's content with it, at its default pane (General); the crossing asks for Protection back. A
    /// counter, so every ask is fresh; the window's "seen" mark rides beside it HERE, because this controller outlives
    /// the reopen (the bootstrap's own) and the Settings view does not.
    private(set) var settingsRequest = 0
    @ObservationIgnored var settingsRequestAdopted = 0

    /// VX-486 — THE ASK ITSELF, under a neutral name (the `MCPDoor.requestSettings()` twin): Settings ▸ Protection,
    /// adopted by the Settings window on appear (a fresh window) or on change (one already up). The ask re-points a
    /// window; it opens none — a caller that must also bring Settings up opens it beside the ask (the locked sync row's
    /// door: `ProtectionPaneDoor`, then `openSettings()` — ⌥⌘,'s own press shape).
    func requestProtectionPane() {
        settingsRequest += 1
    }

    /// VX-307 U2a — a crossing ends on Protection (`AppBootstrap.crossOnNewRoad`: its reopen rebuilt Settings at
    /// General). Unconditional: the crossings' doors live only in Settings ▸ Protection.
    func requestProtectionPaneForRoadCrossing() {
        requestProtectionPane()
    }

    // MARK: - Re-lock monitors (Mac — sleep · screen lock · idle)

    #if os(macOS)
    @ObservationIgnored private var workspaceTokens: [NSObjectProtocol] = []
    @ObservationIgnored private var distributedTokens: [NSObjectProtocol] = []
    @ObservationIgnored private var idleTask: Task<Void, Never>?
    @ObservationIgnored private var activityMonitor: Any?

    /// Started by the production bootstrap only (never test instances): each trigger re-checks the open library's
    /// policy at FIRE time. Re-lock on sleep / screen lock is ALWAYS ON in Castle (decision 18), and the idle clock is
    /// Variorum's own activity — the local event monitor stamps it (never the system's idle clock, which any app resets:
    /// "switching to another app doesn't lock it; time away does").
    func startRelockMonitors() {
        stopRelockMonitors()
        let workspace = NSWorkspace.shared.notificationCenter
        workspaceTokens.append(workspace.addObserver(
            forName: NSWorkspace.willSleepNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in await self?.relockIfPolicySays() }
        })
        distributedTokens.append(DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.apple.screenIsLocked"),
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in await self?.relockIfPolicySays() }
        })
        activityMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown,
                       .scrollWheel, .magnify, .swipe]
        ) { [weak self] event in
            Task { @MainActor [weak self] in self?.noteActivity() }
            return event
        }
        noteActivity()
        idleTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                await self?.relockIfIdle()
            }
        }
    }

    func stopRelockMonitors() {
        let workspace = NSWorkspace.shared.notificationCenter
        for token in workspaceTokens { workspace.removeObserver(token) }
        for token in distributedTokens {
            DistributedNotificationCenter.default().removeObserver(token)
        }
        workspaceTokens = []
        distributedTokens = []
        if let activityMonitor { NSEvent.removeMonitor(activityMonitor) }
        activityMonitor = nil
        idleTask?.cancel()
        idleTask = nil
    }

    /// Sleep and screen lock (internal for VX-308 U4's route pins): the OPEN library's policy decides (Castle locks —
    /// always on, decision 18).
    func relockIfPolicySays() async {
        guard roadRelock?() != nil else { return }
        await performLock?()
    }

    /// The idle tick (internal, `now` injectable, for VX-308 U4's route pins) — VX-308 U4 — VX-445 (R-U4-3): the same
    /// clock over THIS MAC'S SEALED idle minutes.
    func relockIfIdle(now: Date = Date()) async {
        guard let policy = roadRelock?(),
              IdleLockClock.isDue(now: now, lastUsedAt: lastUsedAt, minutes: policy.idleMinutes)
        else { return }
        await performLock?()
    }
    #endif
}

#if os(macOS)
import AppKit
#endif
