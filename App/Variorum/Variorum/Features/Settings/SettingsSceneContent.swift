//
//  SettingsSceneContent.swift
//  Variorum
//
//  The Settings SCENE's content — what `VariorumApp`'s `Settings {}` hosts:
//  the panes over an open library, and the one non-ready arm. Moved here
//  verbatim from the scene closure (VX-224) so a pin can mount exactly what
//  the window shows, driven by a real `AppBootstrap`.
//

import SwiftUI
import VariorumCore

struct SettingsSceneContent: View {
    let bootstrap: AppBootstrap
    let services: AppServices?
    let appearance: AppearanceController?
    let updates: UpdateChannel?
    let crashReports: CrashReporting?
    let mcp: MCPDoor?
    /// 13x U2 row 6 / F1: Settings' OWN adoption and hand-off presenters
    /// (the main scene's sheet and this one can never both fire).
    let libraryOpen: LibraryOpenPresenter
    let handOff: LibraryHandOffPresenter

    var body: some View {
        if case .ready(let session) = bootstrap.state {
            AppSettingsView(
                session: session, services: services,
                protection: bootstrap.protection,
                // 18j: the app's ONE appearance owner, handed to its
                // door. Never re-read from `UserDefaults` by the pane
                // (F-0: a setting is read once at its owner and pushed
                // down) — the pane binds to this object.
                appearance: appearance,
                // 13r U3-A: General's "Check for updates automatically"
                // — rendered only where the channel is live (P-2).
                updates: updates,
                // 13r U3-B: Settings ▸ Diagnostics — the ONE crash-
                // reporting owner (opt-in, default OFF).
                crashReports: crashReports,
                // 13n-b U1: Settings ▸ MCP — the ONE MCP door owner.
                mcp: mcp,
                // 13x U2 row 6: the Restore surface's per-row door —
                // Settings' OWN presenter (the main scene's sheet and
                // this one can never both fire).
                restoreDoor: { picked in
                    libraryOpen.begin(bootstrap: bootstrap, picked: picked)
                },
                // 13x F1 (R1-MAJOR): Data Safety's hand-off twin —
                // Settings' OWN presenter, the restore door's pattern.
                handOffDoor: {
                    handOff.openPanel(session: session, bootstrap: bootstrap)
                })
                .sheet(isPresented: Binding(
                    get: { libraryOpen.model != nil },
                    set: { if !$0 { libraryOpen.dismiss() } })
                ) {
                    if let model = libraryOpen.model {
                        LibraryOpenSheet(model: model) { libraryOpen.dismiss() }
                    }
                }
                .sheet(isPresented: Binding(
                    get: { handOff.model != nil },
                    set: { if !$0 { handOff.dismiss() } })
                ) {
                    if let model = handOff.model {
                        LibraryHandOffSheet(model: model) { handOff.dismiss() }
                    }
                }
        } else {
            Text("Open the main window first.")
                .padding(24)
        }
    }
}
