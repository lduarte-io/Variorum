//
//  AppearanceChoiceRow.swift
//  Variorum (Mac)
//
//  18j (her R-Q12) — the light/dark choice's ONE door: the "Light & dark"
//  section under Voice in Settings ▸ Appearance, bound to the app's one
//  appearance owner (`AppearanceController`, `AppearanceChoice.swift`). Its
//  own file for the reason `PaletteSettingsRow` gives four lines above its
//  call site: a feature that arrives as lines inside a pane is how a pane
//  becomes a god file (P-9; the 18j ladder's R1-8) — the pane composes it
//  in one line.
//
//  The row holds NO rule: it reads the controller's choice and calls
//  `set(_:)`; the controller remembers the choice (LOCAL `UserDefaults`,
//  never synced) and writes `NSApp.appearance`, which every window, sheet,
//  menu and the Settings scene inherit.
//

import SwiftUI

struct AppearanceChoiceRow: View {
    let appearance: AppearanceController

    var body: some View {
        Section("Light & dark") {
            Picker("Appearance", selection: Binding(
                get: { appearance.choice },
                set: { appearance.set($0) })) {
                Text("Follow system").tag(AppearanceChoice.system)
                Text("Light").tag(AppearanceChoice.light)
                Text("Dark").tag(AppearanceChoice.dark)
            }
            .pickerStyle(.segmented)
            // Her 2026-10-13 General ruling: no explanation beneath.
        }
    }
}
