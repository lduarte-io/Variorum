//
//  AppearanceChoiceRule.swift
//  Variorum (shared: Mac + Mobile)
//
//  VM-53 (the VM-47 run, batch 5) — **the light/dark choice's RULE, shared.**
//  18j (her R-Q12) built it on the Mac: Follow the system · Light · Dark, a
//  LOCAL preference (this device's `UserDefaults`, never the synced `setting`
//  table — AppSpec §12: "appearance (follow system, light, dark) is a local
//  preference"; her LK-1/LK-2 for the phone: "if the phone has dark mode on,
//  that shouldn't change what your mac is like"). The phone takes the SAME
//  rule and the SAME stored shape (one key, three raw values, a strange value
//  reads as follow-system) rather than a second copy of it (MobileSoul §3: the
//  phone never forks a brain), so the pure enum moved here from the Mac's
//  `Theme/AppearanceChoice.swift` — its cases, its key and its remembered
//  rule byte for byte; `isDark(system:)` and the UIKit twin are the phone's
//  additions.
//
//  What stays per platform is only how a choice is APPLIED, each at its one
//  root: the Mac's `AppearanceController` writes `NSApp.appearance` (its
//  AppKit name, `appearanceName`, stays in the Mac's file beside that owner);
//  the phone's `MobileAppearanceController` writes each window's
//  `overrideUserInterfaceStyle` (`userInterfaceStyle`, below). Neither ever
//  reaches the store: each device answers for itself.
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// Follow the system · Light · Dark. The pure half — a rule with no state,
/// so the mapping and the stored form are unit-pinnable without an
/// application (`AppearanceChoiceTests` on the Mac, `MobileAppearanceTests`
/// on the phone).
nonisolated enum AppearanceChoice: String, CaseIterable, Sendable {
    /// Whatever the system says — the shipped behaviour, and the default,
    /// so an app that has never been told anything behaves exactly as it
    /// did before 18j.
    case system
    case light
    case dark

    /// This device's `UserDefaults` key (the Mac's since 18j; the phone's
    /// own domain holds its own answer under the same name — never synced).
    static let settingKey = "appearanceChoice"

    /// A stored value that is not one of the three reads as `.system` —
    /// the same posture `ReadModeView.rememberedFace` and
    /// `LibraryCatalogModel`'s sort take with their local keys.
    static func remembered(_ defaults: UserDefaults = .standard) -> AppearanceChoice {
        defaults.string(forKey: settingKey)
            .flatMap(AppearanceChoice.init(rawValue:)) ?? .system
    }

    /// Whether a face resolved OUTSIDE a window's own traits reads dark under
    /// this choice, given what the system says (VM-53: the phone's lobby
    /// resolves its tokens at the app's root, where no window override is
    /// seen). Every face inside a window reads its traits and needs none of
    /// this — the choice is applied there.
    func isDark(system systemIsDark: Bool) -> Bool {
        switch self {
        case .system: systemIsDark
        case .light: false
        case .dark: true
        }
    }

    #if os(iOS)
    /// The UIKit style this choice names — the phone's twin of the Mac's
    /// `appearanceName`. **`.unspecified` is meaningful**: it is what "follow
    /// the system" means for a window's override, not an error case.
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }
    #endif
}
