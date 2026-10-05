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
//  THE CONSENT (the calm default): the Info.plist leaves
//  `SUEnableAutomaticChecks` unset, so no automatic check runs before she
//  answers. `SUEnableSystemProfiling` is unset too, so the anonymous system
//  profile option never appears and nothing beyond the feed request leaves
//  the machine. The Check for Updates… door checks when she asks, from the
//  first launch on.
//
//  ── 13r U3-A — R-13r-11: NO POPUP AT FIRST OPEN ─────────────────────────
//  Her words at the U2 walk: *"I don't want the user experience to start
//  with a popup. please change things so that this popup shows up after
//  they've been using the app."* Read from the 2.10.0 source
//  (`SPUUpdater startUpdateCycle`): with `SUEnableAutomaticChecks` absent
//  from the defaults and the Info.plist, Sparkle consults the delegate's
//  `updaterShouldPromptForPermissionToCheckForUpdates:` — and only when it
//  is not implemented does it prompt on the SECOND launch. The delegate
//  below answers NO, always; the cycle then schedules nothing, because
//  `automaticallyChecksForUpdates` reads NO until answered (the
//  `scheduleNextUpdateCheckFiringImmediately:` early return). The question
//  is asked LATER, by THE CALM-ASKS CADENCE (`CalmAsks.swift` — from the
//  3rd day of use, at a calm moment, never at launch): `askPermission()`
//  shows Sparkle's OWN permission window through its standard user driver
//  (`showUpdatePermissionRequest:reply:`, the public `SPUUserDriver` road)
//  and applies the answer exactly as Sparkle's own
//  `updatePermissionRequestFinishedWithResponse:` does. Answering writes
//  `SUEnableAutomaticChecks` into the defaults — Sparkle's own record that
//  the question is settled, read here as `permissionAnswered` — and so does
//  Settings ▸ General's "Check for updates automatically", which maps onto
//  Sparkle's own setting; either one retires the ask for good.
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

    /// R-13r-11: true while OUR deferred permission window is on screen.
    /// Sparkle does not know it is showing (we drive its user driver
    /// directly), so the door greys here instead of opening a check beside it.
    private(set) var isAskingPermission = false

    /// Mirrors `SPUUpdater.automaticallyChecksForUpdates` — Settings ▸
    /// General's checkbox. False until she says yes.
    private(set) var automaticallyChecks = false

    /// The menu door's enablement: Sparkle can check, and our permission
    /// window is not already up.
    var canCheckNow: Bool { canCheckForUpdates && !isAskingPermission }

    /// Sparkle's own record of the answer lives in these defaults (the main
    /// bundle's `SUHost` reads `standardUserDefaults`, read from its source).
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let controller: SPUStandardUpdaterController?
    /// Held strongly: Sparkle references its updater delegate WEAKLY.
    @ObservationIgnored private let deferral = PermissionDeferral()
    @ObservationIgnored private var observation: NSKeyValueObservation?
    @ObservationIgnored private var autoCheckObservation: NSKeyValueObservation?

    /// The defaults key Sparkle writes when the question is answered — in
    /// the prompt or through `automaticallyChecksForUpdates`
    /// (`SPUUpdaterSettings`, read from the 2.10.0 source).
    nonisolated static let answerKey = "SUEnableAutomaticChecks"

    /// **R-13r-11's delegate: Sparkle's early permission prompt is declined,
    /// always.** Sparkle calls it (only while the question is unanswered) by
    /// its Objective-C selector — named exactly here — and prompts on the
    /// second launch only when it is NOT implemented.
    final class PermissionDeferral: NSObject, SPUUpdaterDelegate {
        @objc(updaterShouldPromptForPermissionToCheckForUpdates:)
        func updaterShouldPromptForPermissionToCheck(forUpdates updater: SPUUpdater) -> Bool {
            Self.promptsEarly
        }

        /// The answer, named so a pin can read it without a live updater.
        static let promptsEarly = false
    }

    /// The channel THIS build gets. It is the one place the fence applies.
    static func forThisBuild() -> UpdateChannel {
        UpdateChannel(live: liveInThisBuild)
    }

    /// `live: false` builds the inert channel (Debug builds, and every test).
    /// A live channel builds Sparkle's standard controller UNSTARTED, with
    /// R-13r-11's deferral as its updater delegate, and `start()` begins the
    /// cycle once the app has finished launching.
    init(live: Bool, defaults: UserDefaults = .standard) {
        isLive = live
        self.defaults = defaults
        controller = live
            ? SPUStandardUpdaterController(
                startingUpdater: false, updaterDelegate: deferral, userDriverDelegate: nil)
            : nil
    }

    /// Whether she has answered "Check for updates automatically?" — in the
    /// permission window or in Settings. Sparkle's own record (`answerKey`).
    var permissionAnswered: Bool { defaults.object(forKey: Self.answerKey) != nil }

    /// THE UPDATE ASK's `wantsAsking` (the calm-asks scheduler): a live
    /// channel, the question unanswered, our window not already up.
    var wantsPermissionAsked: Bool { isLive && !permissionAnswered && !isAskingPermission }

    /// R-13r-11 — THE DEFERRED ASK: Sparkle's own permission window ("Check
    /// for updates automatically?" — Check Automatically / Don't Check), shown
    /// through its standard user driver when the cadence says so; the answer
    /// applied exactly as Sparkle's own `updatePermissionRequestFinished`
    /// applies it. A no-op on the inert channel, once answered, or while up.
    func askPermission() {
        guard let controller, wantsPermissionAsked else { return }
        let request = SPUUpdatePermissionRequest(systemProfile: controller.updater.systemProfileArray)
        isAskingPermission = true
        controller.userDriver.show(request) { [weak self] response in
            // Sparkle's own flow hops to main before applying (its source);
            // the same here, then the main-actor contract is asserted.
            let checks = response.automaticUpdateChecks
            let profile = response.sendSystemProfile
            let downloading = response.automaticUpdateDownloading?.boolValue
            DispatchQueue.main.async {
                MainActor.assumeIsolated {
                    self?.applyPermission(checks: checks, sendProfile: profile, downloading: downloading)
                }
            }
        }
    }

    /// The answer, applied as Sparkle's `updatePermissionRequestFinished`
    /// applies it. Setting `automaticallyChecksForUpdates` writes the answer
    /// into the defaults and, on yes, Sparkle re-arms its cycle after a short
    /// delay (its documented behaviour).
    private func applyPermission(checks: Bool, sendProfile: Bool, downloading: Bool?) {
        defer { isAskingPermission = false }
        guard let updater = controller?.updater else { return }
        updater.sendsSystemProfile = sendProfile
        updater.automaticallyChecksForUpdates = checks
        if let downloading { updater.automaticallyDownloadsUpdates = downloading }
        automaticallyChecks = updater.automaticallyChecksForUpdates
    }

    /// Settings ▸ General's "Check for updates automatically" — Sparkle's own
    /// setting. Setting it ANSWERS the question (the ask retires).
    func setAutomaticallyChecks(_ on: Bool) {
        guard let controller else { return }
        controller.updater.automaticallyChecksForUpdates = on
        automaticallyChecks = controller.updater.automaticallyChecksForUpdates
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
        // The checkbox's mirror (same main-thread contract as above).
        autoCheckObservation = controller.updater.observe(
            \.automaticallyChecksForUpdates, options: [.initial, .new]
        ) { [weak self] updater, _ in
            MainActor.assumeIsolated {
                self?.automaticallyChecks = updater.automaticallyChecksForUpdates
            }
        }
    }

    /// The door's act: a user-initiated check. From here on the UI is
    /// Sparkle's own standard alerts (found / up to date / install / relaunch).
    ///
    /// F4 (ladder round 1): guarded on `isAskingPermission` AT THE CHANNEL, so
    /// EVERY door — the menu's (which also greys), the sync row's, any future
    /// one — refuses to open a check beside the deferred permission window.
    /// Sparkle cannot refuse it for us: we drive its user driver directly, so
    /// its own `_showingPermissionRequest` stays NO (its source). Deliberately
    /// NOT guarded on `canCheckForUpdates`: mid-session, Sparkle's own
    /// `checkForUpdates` brings the running session into focus — behaviour
    /// worth keeping for a door that is not greyed.
    func checkForUpdates() {
        guard !isAskingPermission else { return }
        controller?.checkForUpdates(nil)
    }

    /// 13r U3-A — R-13r-13: the SYNC ROW's Check for Updates… door (the calm
    /// out-of-date face, `SyncRowFace.appOutOfDate`). Handed out ONLY by a
    /// live channel, so the door renders only where it can act (P-2): a
    /// Debug build's row says the plain sentence alone. The act is this
    /// channel's own — the same one the menu door runs.
    var syncRowDoor: CheckForUpdatesDoor? {
        guard isLive else { return nil }
        return CheckForUpdatesDoor { [weak self] in self?.checkForUpdates() }
    }
}
