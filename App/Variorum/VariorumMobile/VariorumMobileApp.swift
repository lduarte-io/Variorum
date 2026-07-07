//
//  VariorumMobileApp.swift
//  VariorumMobile
//
//  Phase 8: iOS journal capture — a second client of the SAME VariorumCore
//  + sync engine (CoreDescription pillar 8: a smaller surface, never a
//  separate data model). Root composition mirrors the Mac shell: the
//  recoverable open (AppBootstrap, A4 variant-aware) before any view, then
//  AppServices (sync lifecycle + idle-commit sweep; no local backups — the
//  phone's store is re-derivable from the mirror).
//
//  Sync triggers (Step 6, foreground-simple): scene → active runs a round;
//  scene → background flushes one round before suspension; post-write
//  settles are SyncSession's own observation. Offline is free — the outbox
//  queues; capture never blocks on the network.
//

import SwiftUI
import VariorumCore

@main
struct VariorumMobileApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var bootstrap = AppBootstrap()
    @State private var services: AppServices?

    var body: some Scene {
        WindowGroup {
            switch bootstrap.state {
            case .ready(let session):
                MobileRootView(session: session, services: services)
                    .task {
                        guard services == nil else { return }
                        let fresh = AppServices(
                            session: session,
                            storeVariant: bootstrap.storeVariant,
                            backupEnabled: false)
                        services = fresh
                        await fresh.start()
                    }
            case .failed(let error):
                MobileStoreFailureView(error: error) { bootstrap.retry() }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                services?.sync.triggerSync()
            case .background:
                // One flush before suspension. If the device locks mid-round,
                // file protection may cut the store off — the scheduler
                // treats that exactly like being offline (round skipped,
                // outbox intact, retry on next foreground).
                let sync = services?.sync
                Task { await sync?.flush() }
            default:
                break
            }
        }
    }

    // (The protection-class pick moved into AppBootstrap.open() — review
    // round 1: iOS data protection is inherited AT CREATION, so setting it
    // after the store was opened protected nothing; it must precede the
    // first open.)
}
