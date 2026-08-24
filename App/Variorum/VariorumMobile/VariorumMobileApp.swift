//
//  VariorumMobileApp.swift
//  VariorumMobile
//
//  Variorum for iPhone — a second client of the SAME VariorumCore + sync
//  engine (CoreDescription pillar 8: a smaller surface, never a separate
//  data model). Root composition mirrors the Mac shell: the recoverable
//  open (AppBootstrap, A4 variant-aware) before any view, then
//  AppServices (sync lifecycle + idle-commit sweep; no local backups —
//  the phone's store is re-derivable from the mirror).
//
//  Since Mobile Stage 3 the root is the app's REAL shape (M7):
//  `MobileShellView` — shelf-first home, Today a button, tabs Shelf ·
//  Library — over the S1/S2 Write surface. The Phase 8 capture views
//  are RETIRED; the bootstrap/session/sync shells carry over unchanged.
//
//  Sync triggers (Phase 8 Step 6, foreground-simple): scene → active runs
//  a round; scene → background flushes one round before suspension;
//  post-write settles are SyncSession's own observation. Offline is free —
//  the outbox queues; writing never blocks on the network.
//

import SwiftUI
import VariorumCore

@main
struct VariorumMobileApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var bootstrap = AppBootstrap()
    @State private var services: AppServices?
    /// The shell's shared routing state: the active editor (for the
    /// background flush) + the one voice authority (LK2).
    @State private var shellRouter = MobileShellRouter()

    var body: some Scene {
        WindowGroup {
            switch bootstrap.state {
            case .ready(let session):
                MobileShellView(
                    session: session, services: services, router: shellRouter)
                    // The app-switcher snapshot cover (SnapshotPrivacy —
                    // PROVISIONAL, pre-Stage-A): redacts exactly the
                    // privacySensitive spans (the 12 words, phrase entries)
                    // while the scene is not active. Environment reaches
                    // presented sheets, so the words are covered wherever
                    // they render.
                    .redacted(reason: SnapshotPrivacy.redactionReasons(for: scenePhase))
                    .task {
                        guard services == nil else { return }
                        let fresh = AppServices(
                            session: session,
                            storeVariant: bootstrap.storeVariant,
                            backupEnabled: false)
                        services = fresh
                        await fresh.start()
                    }
            case .opening:
                // 13l L-c: the store opens off the main thread now, so there
                // is a first frame with no session. Quiet by design — a
                // spinner announcing 50 ms of work is worse than the calm
                // ground the app opens onto anyway.
                MobileStoreOpeningView()
            case .failed(let error):
                MobileStoreFailureView(error: error) { bootstrap.retry() }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // The routing lives in `mobileScenePhaseChanged` (round 2, M5)
            // so it is pinnable, not merely readable. On `.background`:
            // the HOME-SCREEN QUICK NOTE mints and files first (its text
            // lives nowhere but the box until it does — her R5
            // requirement), then EVERY registered editor's pending
            // autosave lands in the STORE (`onDisappear` never fires on
            // whole-app backgrounding — the Phase 8 review-round-2
            // finding, carried; the flush targets are the liveness
            // authority's own bookkeeping since the S3 ladder's MAJOR 1,
            // so a second open editor is covered too), then one sync round
            // pushes it — all of it inside a `beginBackgroundTask` grant
            // (A5-4: there had never been one).
            //
            // **The grant is taken SYNCHRONOUSLY inside
            // `mobileScenePhaseChanged` itself, and it carries an
            // expiration handler** (4.5a, Q4). It used to be taken one hop
            // later, inside the Task — the anti-pattern Apple's own
            // documentation names — and with no handler at all, which makes
            // an overrun fatal rather than recoverable.
            //
            // If the device locks mid-round, file protection may cut the
            // store off — the scheduler treats that exactly like being
            // offline (round skipped, outbox intact, retry on next
            // foreground). **The quick note now survives that too**: a
            // leaving whose mint the store refuses KEEPS her text and its
            // reason rather than clearing the box (4.5a, Q2).
            // PR7 (round 2 batch 4): backgrounding is the phone's ⌘Q, so
            // it is a LEAVING — every open note gets its quiet savepoint
            // through the ONE shared entry (`AppSession.savepointOnLeaving`,
            // 13j J11's sixth auto-commit occasion). The session is read
            // here rather than held, because the scene handler is outside
            // the bootstrap's switch.
            var savepoint: (@MainActor (String) async -> Void)?
            if case .ready(let session) = bootstrap.state {
                savepoint = { postID in await session.savepointOnLeaving(postID) }
            }
            mobileScenePhaseChanged(
                phase, editors: shellRouter.editors, sync: services?.sync,
                quickNote: shellRouter.quickNote, savepoint: savepoint)
        }
    }

    // (The protection-class pick lives in AppBootstrap.open() — Phase 8
    // review round 1: iOS data protection is inherited AT CREATION, so it
    // must precede the first open.)
}
