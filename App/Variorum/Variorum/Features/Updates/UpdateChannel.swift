//
//  UpdateChannel.swift
//  Variorum
//
//  Phase 13r U2 — the app's ONE update channel: Sparkle 2.10.0 (her
//  dependency approval 2026-08-20, MIT, re-affirmed at the 13r sitting),
//  riding the XPC INSTALLER road because the app is sandboxed. The binding
//  record is `notes/plans/phase-13r-distribution.md` (R-13r-1/2/7, the U2
//  RECORD).
//
//  THE FENCE (R-13r-7): a DEBUG build NEVER instantiates the updater. The
//  dev fence extends to the update channel, so a Debug build can never reach
//  the public feed, ask for consent, or install anything. ONLY THE
//  INSTANTIATION is fenced (`liveInThisBuild`, consulted once in
//  `forThisBuild()`). The rest of this file compiles in both configurations,
//  so a Debug build and its tests type-check the Release road too.
//
//  THE CONSENT (the calm default): Sparkle's STANDARD flow. The Info.plist
//  leaves `SUEnableAutomaticChecks` unset, so Sparkle asks before any
//  automatic check. Read from the 2.10.0 source, it asks on the second launch;
//  the first launch only records that it happened. The Check for Updates…
//  door checks when she asks. `SUEnableSystemProfiling` is unset too, so the
//  anonymous system profile option never appears and nothing beyond the feed
//  request leaves the machine.
//
//  WHY THE APP DELEGATE OWNS IT: there is one of it, however many windows
//  exist, and it must exist before the first window. That is the
//  `AppearanceController` precedent (VariorumAppDelegate).
//

import Foundation
import Observation
import Sparkle

@Observable
final class UpdateChannel {
    /// The door's title: the platform's own words for this act.
    static let checkForUpdatesTitle = "Check for Updates…"

    /// THE FENCE as one constant: false in every DEBUG build (R-13r-7).
    static let liveInThisBuild: Bool = {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }()

    /// Whether this channel carries a real updater. When false, the door is
    /// not rendered at all (P-2: a door that can never act is not shown).
    let isLive: Bool

    /// Mirrors `SPUUpdater.canCheckForUpdates` (KVO-observable by Sparkle's
    /// contract). It is false while an update session already runs, so the
    /// door greys instead of stacking a second session on the first.
    private(set) var canCheckForUpdates = false

    @ObservationIgnored private let controller: SPUStandardUpdaterController?
    @ObservationIgnored private var observation: NSKeyValueObservation?

    /// The channel THIS build gets. It is the one place the fence applies.
    static func forThisBuild() -> UpdateChannel {
        UpdateChannel(live: liveInThisBuild)
    }

    /// `live: false` builds the inert channel (Debug builds, and every test).
    /// A live channel builds Sparkle's standard controller UNSTARTED, and
    /// `start()` begins the cycle once the app has finished launching.
    init(live: Bool) {
        isLive = live
        controller = live
            ? SPUStandardUpdaterController(
                startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
            : nil
    }

    /// Starts Sparkle's update cycle (called at launch from the app
    /// delegate). Idempotent; a no-op on the inert channel.
    func start() {
        guard let controller, observation == nil else { return }
        controller.startUpdater()
        observation = controller.updater.observe(
            \.canCheckForUpdates, options: [.initial, .new]
        ) { [weak self] updater, _ in
            // `SPUUpdater` is main-actor-isolated in Swift: Sparkle's contract
            // is main-thread-only. KVO fires on the mutating thread, which is
            // therefore main, and `.initial` fires synchronously inside this
            // `observe` call, also on main. So this ASSERTS the contract and
            // invents no hop. A violation would trap loudly instead of racing.
            MainActor.assumeIsolated {
                self?.canCheckForUpdates = updater.canCheckForUpdates
            }
        }
    }

    /// The door's act: a user-initiated check. From here on the UI is
    /// Sparkle's own standard alerts (found / up to date / install / relaunch).
    func checkForUpdates() {
        controller?.checkForUpdates(nil)
    }
}
