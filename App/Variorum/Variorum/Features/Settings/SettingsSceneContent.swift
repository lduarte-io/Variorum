//
//  SettingsSceneContent.swift
//  Variorum
//
//  The Settings SCENE's content — what `VariorumApp`'s `Settings {}` hosts:
//  the panes over an open library, and the one non-ready arm. Moved here
//  verbatim from the scene closure (VX-224) so a pin can mount exactly what
//  the window shows, driven by a real `AppBootstrap`.
//
//  **VX-224 — the window closes when the library closes under it.** Her
//  report: locking with Settings open left "a weird variorum settings stub
//  window … you can't read the text in it, it's not possible to make it
//  bigger. i feel like we can probably just close this window." The stub
//  was the non-ready arm below: a lock flipped the scene into it and
//  nothing closed the window. Now the window closes itself — the AppKit
//  close its own ✕ performs — the moment the library SETTLES closed
//  (`libraryClosed`). Never on `.opening`: the reopen roads that run FROM
//  this window (Data Safety's Restore from Backup → `adoptLibrary`; the
//  Protection pane's posture switches → `rekeyLibrary`) pass through it
//  with their sheets on this window. No reopen-on-unlock (none was free);
//  ⌘, after the unlock opens it fresh.
//

import AppKit
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
    /// This content's own window (reported by AppKit, held weakly).
    @State private var host = HostWindow()

    /// **Whether the library has CLOSED under Settings** — a SETTLED state
    /// with no open library. `.opening` is not one: it is the in-flight
    /// middle of every reopen road, two of which run from this window.
    static func libraryClosed(_ state: AppBootstrap.State) -> Bool {
        switch state {
        case .ready, .opening: false
        case .locked, .waitingForICloudKeychain, .libraryMissing, .failed, .roadLobby, .newLibraryWords,
             .roadInterlude: true
        }
    }

    /// **VX-240 — what the window shows when there are no panes.** The
    /// reopen roads that run FROM this window (Restore from Backup, the
    /// posture switches) pass through `.opening` with the window kept open,
    /// and the stub's instruction — "Open the main window first." — was a
    /// wrong one mid-ceremony. `.opening` now shows her words, "Opening your
    /// library…", with a spinner (QUESTIONS #217); every settled closed
    /// state keeps the stub (the window closes on those — VX-224).
    enum NonReadyFace: Equatable {
        case opening
        case stub
    }

    static func nonReadyFace(_ state: AppBootstrap.State) -> NonReadyFace {
        if case .opening = state { return .opening }
        return .stub
    }

    /// The two faces' words — hers for the opening one, verbatim.
    enum Copy {
        static let opening = "Opening your library\u{2026}"
        static let stub = "Open the main window first."
    }

    var body: some View {
        arms
            .background(WindowKeyReporter(onWindow: { host.window = $0 }, onKey: {}))
            // A TRANSITION, never the initial value: a window opened while
            // the library is already closed keeps its arm (VX-224's ruled
            // scope is the lock engaging under an open window).
            .onChange(of: Self.libraryClosed(bootstrap.state)) { _, closed in
                if closed { host.window?.close() }
            }
    }

    @ViewBuilder private var arms: some View {
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
                },
                // VX-306 U2: the new road's *Set a passphrase…* row (nil on today's road).
                roadStanding: bootstrap.roadStanding,
                // VX-306 U3: the new road's Restore list — Make this my library on a catalogued copy, through
                // Settings' OWN presenter (nil on today's road).
                roadDoors: bootstrap.copyDoorsRoads().map { roads in
                    RoadDoorsHost(
                        roads: roads,
                        lookInside: { row in libraryOpen.beginLookInside(roads: roads, row: row) },
                        makeMine: { row in libraryOpen.beginMakeMine(roads: roads, row: row) })
                })
                .sheet(isPresented: Binding(
                    get: { libraryOpen.model != nil },
                    set: { if !$0 { libraryOpen.dismiss() } })
                ) {
                    if let model = libraryOpen.model {
                        LibraryOpenSheet(model: model) { libraryOpen.dismiss() }
                    }
                }
                // VX-306 U3: the two doors' sheet (the new road only).
                .sheet(isPresented: Binding(
                    get: { libraryOpen.roadDoors != nil },
                    set: { if !$0 { libraryOpen.dismissRoad() } })
                ) {
                    if let doors = libraryOpen.roadDoors {
                        CopyDoorsSheet(model: doors) { libraryOpen.dismissRoad() }
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
            switch Self.nonReadyFace(bootstrap.state) {
            case .opening:
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text(Copy.opening)
                }
                .padding(24)
            case .stub:
                Text(Copy.stub)
                    .padding(24)
            }
        }
    }
}

/// The Settings window, held WEAKLY — the scene owns it; this only names it
/// so the content can close its own window (VX-224).
@MainActor
private final class HostWindow {
    weak var window: NSWindow?
}
