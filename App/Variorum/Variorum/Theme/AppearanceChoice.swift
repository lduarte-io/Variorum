//
//  AppearanceChoice.swift
//  Variorum
//
//  18j (her R-Q12 — 13u4's item 6 pulled forward): **the in-app light/dark
//  choice**, and the ONE root it is applied at.
//
//  Until now the Mac simply followed the system appearance: every surface
//  reads `@Environment(\.colorScheme)` (48 sites) and the dark token sets
//  have existed since Phase 13 (R51 — a fully black room in both voices),
//  but there was no way to say "dark" while the system said light. This
//  file is that choice and nothing else; NOT ONE SURFACE CHANGES, because
//  the choice is applied where the whole app reads its appearance from.
//
//  **Why `NSApp.appearance` and not `preferredColorScheme(_:)`** (review
//  focus F-9: "applied at ONE root … no per-surface override"): the app has
//  FIVE scenes — the main `WindowGroup`, the note `WindowGroup`, the
//  floating quick-note `Window`, the helper `Window` and `Settings` — plus
//  a `MenuBarExtra`, and every sheet, alert, popover and menu those open.
//  `preferredColorScheme` is a per-scene modifier: it would be five copies
//  of one decision (the drift class), it does not reach a menu bar extra's
//  menu, and AppKit chrome a scene does not own (the title bar, the
//  toolbar, a Save panel) would keep the system's appearance. `NSApp`'s
//  appearance is the app-level one that every window whose own `appearance`
//  is nil inherits — which is all of them (nothing in this app sets a
//  window appearance; verified by grep) — so ONE write moves the whole
//  process, AppKit chrome included, and SwiftUI's `colorScheme` follows
//  each window's `effectiveAppearance` by construction.
//
//  **LOCAL, never synced.** The `readModeOutlineShown` / `libraryCatalogSort`
//  class: the VOICE and the PALETTE are document semantics and ride the
//  synced `setting` table (13's R1, 18g's R-Q6), but whether this screen
//  wears the light or the dark reading of them is this machine's taste —
//  a phone in a dark room and a Mac by a window are honestly different
//  answers, and iOS already has its own system-wide control. Zero schema,
//  zero `setting` key, the lockstep marker stays 8.
//

import AppKit
import Observation

/// Follow the system · Light · Dark. The pure half — a rule with no state,
/// so the mapping and the stored form are unit-pinnable without an
/// `NSApplication` (`AppearanceChoiceTests`).
nonisolated enum AppearanceChoice: String, CaseIterable, Sendable {
    /// Whatever the system says — the shipped behaviour, and the default,
    /// so an app that has never been told anything behaves exactly as it
    /// did before 18j.
    case system
    case light
    case dark

    /// The AppKit appearance this choice names. **Nil is meaningful**: it
    /// is what `NSApp.appearance = nil` means — "inherit the system's" —
    /// and not an error case.
    var appearanceName: NSAppearance.Name? {
        switch self {
        case .system: nil
        case .light: .aqua
        case .dark: .darkAqua
        }
    }

    /// This Mac's `UserDefaults` key.
    static let settingKey = "appearanceChoice"

    /// A stored value that is not one of the three reads as `.system` —
    /// the same posture `ReadModeView.rememberedFace` and
    /// `LibraryCatalogModel`'s sort take with their local keys.
    static func remembered(_ defaults: UserDefaults = .standard) -> AppearanceChoice {
        defaults.string(forKey: settingKey)
            .flatMap(AppearanceChoice.init(rawValue:)) ?? .system
    }
}

/// **The ONE owner** (F-9). It holds the choice, remembers it, and is the
/// only thing in the app that writes `NSApp.appearance`.
///
/// It lives on `VariorumAppDelegate` — the app-level object that already
/// exists before the first window and outlives every one of them, beside
/// the window register and the hot-key centre's reason for being App-level:
/// *there is one of it, however many windows exist*. A per-window owner
/// (the `ThemeStore` class — the app mints one per window kind, and a note
/// window mints its own) would be several owners of one process-wide fact,
/// which is exactly the shape F-9 forbids.
@MainActor
@Observable
final class AppearanceController {
    private(set) var choice: AppearanceChoice
    /// **Injected** (the `LibraryCatalogModel` rule, KnownIssues R1-7): the
    /// suites and her hand walks share the dev-store app's `.standard`, so
    /// a pin that wrote the real key would be writing what a walk reads.
    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        choice = AppearanceChoice.remembered(defaults)
        // Applied here as well as at `applicationDidFinishLaunching`
        // because the two orders are not guaranteed against each other and
        // the write is idempotent: whichever runs first, the first window
        // is composed under the chosen appearance rather than flashing the
        // system's and correcting.
        apply()
    }

    func set(_ choice: AppearanceChoice) {
        guard choice != self.choice else { return }
        self.choice = choice
        defaults.set(choice.rawValue, forKey: AppearanceChoice.settingKey)
        apply()
    }

    /// THE ONE WRITE. Safe before `NSApplication` exists (it does nothing),
    /// and idempotent.
    func apply() {
        guard let app = NSApp else { return }
        app.appearance = choice.appearanceName.flatMap(NSAppearance.init(named:))
    }
}
