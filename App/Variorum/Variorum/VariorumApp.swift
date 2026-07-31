//
//  VariorumApp.swift
//  Variorum
//
//  Phase 7: root composition. The store is opened through the recoverable
//  path (AppBootstrap) BEFORE any view exists; a failed open renders
//  StoreFailureView instead of ever reaching the package's headless
//  fatalError. SwiftUI does all chrome; the editor core is AppKit.
//
//  Phase 8: the session gains background services — sync lifecycle (Step 6),
//  the idle auto-commit sweep (Step 5), rotating store backups (A1) — and
//  the bootstrap opens the A4-resolved store variant (debug ⇒ dev store
//  unless explicitly opted into the real one).
//

import SwiftUI
import VariorumCore

@main
struct VariorumApp: App {
    @NSApplicationDelegateAdaptor(VariorumAppDelegate.self) private var appDelegate
    @State private var bootstrap = AppBootstrap()
    @State private var services: AppServices?
    /// 13f batch 5b (W2/A26): the router is per-WINDOW now — it lives inside
    /// `RootView`, so each window has its own workspace (its own Open strip,
    /// its own histories, its own context-bar fold). What the app keeps is
    /// the register of open windows and the one authority on which is key;
    /// the menu bar reads its active router from here. (Batch 4's recorded
    /// finding: an App-level `@State` router was shared by every
    /// `WindowGroup` window — nothing could ship a second window before
    /// this moved.)
    @State private var windows = WindowRegistry()

    var body: some Scene {
        // Batch 7: a sane fresh-window size (the oversized-window report —
        // an inherited frame taller than the screen made the shelf's
        // bottom bars and the navigator's doors invisible).
        //
        // 13f batch 5b: the group gains an id so File ▸ New Window can open
        // another one by name.
        WindowGroup(id: EditorCommands.mainWindowGroupID) {
            switch bootstrap.state {
            case .ready(let session):
                RootView(session: session, services: services, windows: windows)
                    .onAppear { appDelegate.session = session }
                    .task {
                        guard services == nil else { return }
                        let fresh = AppServices(
                            session: session,
                            storeVariant: bootstrap.storeVariant,
                            backupEnabled: true,
                            bridgeEnabled: true)  // Mac-side (Phase 9b scope)
                        services = fresh
                        await fresh.start()
                    }
                    .onReceive(NotificationCenter.default.publisher(
                        for: NSApplication.didBecomeActiveNotification)) { _ in
                        // The lifecycle cadence, not sync alone (13c A2): a
                        // sync round, plus a bridge round when sync cannot
                        // deliver one — otherwise the bridge silently loses
                        // every cadence trigger it has whenever the Variorum
                        // session is absent. See AppServices.
                        services?.triggerLifecycleRound()
                    }
            case .failed(let error):
                StoreFailureView(error: error) { bootstrap.retry() }
            }
        }
        .defaultSize(width: 1240, height: 840)
        .commands {
            EditorCommands(bootstrap: bootstrap, windows: windows)
        }
        // 13f batch 5b (W2/A26 — her round-2 ruling: BOTH window kinds).
        // The lightweight NOTE-ONLY window: one note, its detail and its
        // context bar, and deliberately no sidebar, no Open strip and no
        // split. Every app-scope act is honestly grey there through the
        // gates that already exist (see `WorkspaceModel.showOnly`).
        WindowGroup(id: EditorCommands.noteWindowGroupID, for: String.self) { $postID in
            switch (bootstrap.state, postID) {
            case (.ready(let session), .some(let postID)):
                NoteWindowView(session: session, windows: windows, postID: postID)
            case (.failed(let error), _):
                StoreFailureView(error: error) { bootstrap.retry() }
            default:
                // No note handed over (a restored window whose value did not
                // come back): honest, not a blank pane.
                Text("Open a note from the main window.")
                    .padding(24)
            }
        }
        .defaultSize(width: 760, height: 720)
        // Sitting 9 (R73/R91): the shortcut helper + dictionary window
        // (⌘/, Help menu, the status bars' "?").
        Window("Shortcuts & Dictionary", id: "variorum-helper") {
            HelperView()
        }
        .defaultSize(width: 680, height: 560)
        // Phase 13 (B2/R52): the Settings window — Appearance (the voice +
        // the B1 global settings) and the TAG MANAGER's real home.
        Settings {
            if case .ready(let session) = bootstrap.state {
                AppSettingsView(session: session)
            } else {
                Text("Open the main window first.")
                    .padding(24)
            }
        }
    }
}
