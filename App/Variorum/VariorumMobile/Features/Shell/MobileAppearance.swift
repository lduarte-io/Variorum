//
//  MobileAppearance.swift
//  VariorumMobile
//
//  VM-53 (the VM-47 run, batch 5) — **this phone's light · dark · follow-the-
//  system choice**, and the ONE root it is applied at. Her ruling (LK-1, LK-2):
//  "follow the library but if the phone has dark mode on, that shouldn't change
//  what your mac is like (the device dark mode)" — the voice and the palette
//  are the LIBRARY's (synced, `ThemeStore`); light or dark is each device's own.
//  AppSpec §12: "appearance (follow system, light, dark) is a local preference".
//
//  THE RULE is the Mac's (`AppearanceChoice`, `Shared/Theme/AppearanceChoice
//  Rule.swift` — three choices, one `UserDefaults` key, a strange value reads as
//  follow-system). THE OWNER is this phone's twin of the Mac's
//  `AppearanceController`: it holds the choice, remembers it in THIS device's
//  defaults (never the `setting` table — nothing here can reach a store), and is
//  the only thing in the app that writes a window's `overrideUserInterfaceStyle`.
//
//  **Why the window and not `preferredColorScheme(_:)`** — the Mac's F-9 reason,
//  on the phone's terms: a window's override is the app-level fact every view in
//  that window inherits through its traits — the SwiftUI chrome
//  (`@Environment(\.colorScheme)`), the UIKit editor and its overlays (their
//  dynamic colours, and `MobileTraitBorder`'s trait registration — VM-54), every
//  sheet, alert and menu presented in it, the keyboard, the lobby — so ONE write
//  moves the whole app and not one surface had to learn about it. A
//  `preferredColorScheme` would be a per-presentation modifier: a copy for every
//  sheet, and the UIKit chrome a SwiftUI tree does not own would keep the
//  system's. It is applied (1) to every window of the app's connected scenes
//  when the choice changes and (2) to each window AS IT BECOMES VISIBLE
//  (`UIWindow.didBecomeVisibleNotification`, delivered synchronously on the
//  posting main thread), so the first frame of a launch is drawn in the choice
//  rather than flashing the system's and correcting (the Mac's own worry).
//
//  **Inert in a test runner's host** (VX-604's posture — `AppBootstrap.Launch`):
//  the production owner there reads a scratch suite, never the Debug app's own
//  domain, and touches no window — the suites share the dev-store app's
//  `.standard` and their own hosted windows must never wear a walk's choice.
//  The pins inject their own defaults and their own windows.
//

import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
final class MobileAppearanceController {
    /// The choice in force on this phone.
    private(set) var choice: AppearanceChoice
    /// Injected (the Mac's `AppearanceController` rule): the suites and the
    /// walks share the dev-store app's `.standard`.
    @ObservationIgnored private let defaults: UserDefaults
    /// The windows a change reaches — the app's connected scenes' windows in
    /// production; a pin hands its own.
    @ObservationIgnored private let windows: @MainActor () -> [UIWindow]
    /// The first-frame road: each window, as it becomes visible.
    @ObservationIgnored private var watcher: MobileWindowVisibilityWatcher?

    /// The scratch domain the inert host reads (never `.standard`).
    nonisolated static let testSuiteName = "vm53.appearance.host"

    /// The app's owner: this phone's own defaults and windows — inert under a
    /// test runner's host (see the header).
    convenience init(launch: AppBootstrap.Launch = .thisProcess) {
        if launch == .hostingTests {
            self.init(
                defaults: UserDefaults(suiteName: Self.testSuiteName) ?? .standard,
                windows: { [] }, watchesNewWindows: false)
        } else {
            self.init(defaults: .standard, windows: Self.connectedWindows, watchesNewWindows: true)
        }
    }

    init(
        defaults: UserDefaults,
        windows: @escaping @MainActor () -> [UIWindow],
        watchesNewWindows: Bool = false
    ) {
        self.defaults = defaults
        self.windows = windows
        choice = AppearanceChoice.remembered(defaults)
        if watchesNewWindows {
            watcher = MobileWindowVisibilityWatcher { [weak self] window in
                self?.apply(to: window)
            }
        }
        apply()
    }

    /// Choose. Remembered in THIS device's defaults and applied at once.
    func set(_ choice: AppearanceChoice) {
        guard choice != self.choice else { return }
        self.choice = choice
        defaults.set(choice.rawValue, forKey: AppearanceChoice.settingKey)
        apply()
    }

    /// THE ONE WRITE, to every window a change reaches. Idempotent.
    func apply() {
        for window in windows() { apply(to: window) }
    }

    private func apply(to window: UIWindow) {
        let style = choice.userInterfaceStyle
        guard window.overrideUserInterfaceStyle != style else { return }
        window.overrideUserInterfaceStyle = style
    }

    /// Every window of the app's connected scenes.
    static func connectedWindows() -> [UIWindow] {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
    }
}

/// `UIWindow.didBecomeVisibleNotification`, observed for as long as its owner
/// lives (the `CopiesChangedObserver` shape: the token is removed when this
/// goes). Delivered SYNCHRONOUSLY on the posting thread (`queue: nil`) — UIKit
/// shows windows on the main thread, so the window is styled before its first
/// frame is drawn.
nonisolated final class MobileWindowVisibilityWatcher: @unchecked Sendable {
    private let token: any NSObjectProtocol

    init(_ seen: @escaping @MainActor @Sendable (UIWindow) -> Void) {
        token = NotificationCenter.default.addObserver(
            forName: UIWindow.didBecomeVisibleNotification, object: nil, queue: nil
        ) { note in
            guard let window = note.object as? UIWindow else { return }
            MainActor.assumeIsolated { seen(window) }
        }
    }

    deinit { NotificationCenter.default.removeObserver(token) }
}
