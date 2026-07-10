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

    var body: some Scene {
        WindowGroup {
            switch bootstrap.state {
            case .ready(let session):
                RootView(session: session, services: services)
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
                        services?.sync.triggerSync()
                    }
            case .failed(let error):
                StoreFailureView(error: error) { bootstrap.retry() }
            }
        }
        .commands {
            EditorCommands(bootstrap: bootstrap)
        }
    }
}
