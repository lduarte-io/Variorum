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
    /// 13p Batch 4 (item g): the phone's re-lock coordinator — the dials'
    /// phone reading (lock on leaving · lock after time away), asked at
    /// both scene edges. It only ever ends at `bootstrap.lock()`, which
    /// refuses under Auto on its own, so nothing here can ship theater.
    @State private var relock: MobileRelockCoordinator?
    /// Pre-13u Act 0: the first-write occasion (R-pre13u-1 / R-pre13u-8).
    /// Held for the session's lifetime like `services`, so the once-per-
    /// launch flag it carries survives every view rebuild.
    @State private var firstWrite: MobileFirstWriteFurniture?
    @Environment(\.colorScheme) private var scheme

    /// The lobby's voice comes from the DEVICE preference, not the store —
    /// the store is exactly what is not open yet.
    private var lockedTokens: VoiceTokens {
        .resolve(voice: MobileVoicePreference.current(), dark: scheme == .dark)
    }

    var body: some Scene {
        WindowGroup {
            switch bootstrap.state {
            case .ready(let session):
                MobileShellView(
                    session: session, services: services,
                    router: shellRouter, bootstrap: bootstrap)
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
                            backupEnabled: false,
                            // The retired-credential sweep — REQUIRED at the
                            // seam (pre-13x 1a); production names the real one.
                            legacyCleanup: { LegacyPasteInCleanup.clear() })
                        services = fresh
                        // Phase 13p ladder R1-M2: the phone's lock road
                        // used to skip the ruled teardown entirely —
                        // `onWillLock` was wired ONLY on the Mac, so Lock
                        // Now closed the pool under pending keystrokes and
                        // left this stale `services` object alive through
                        // the locked window AND past the next `.ready`'s
                        // guard above. The factory mirrors the Mac's
                        // closure: flush + leaving savepoints, then stop
                        // AND nil the services (the next unlock composes
                        // fresh ones over the fresh session — the
                        // deferred-starts rule).
                        bootstrap.onWillLock = mobileWillLock(
                            session: session, editors: shellRouter.editors,
                            stopServices: {
                                services?.stop()
                                services = nil
                                // Act 0: the occasion belongs to the
                                // session it was primed against. A lock
                                // ends that session, so the next unlock
                                // primes a fresh one against the fresh
                                // store rather than spending a verdict
                                // taken before the store was closed.
                                firstWrite = nil
                            })
                        // Phase 13p ladder R2-M1: the phone wires the SAME
                        // four one-secret hooks the Mac wires (R13p-4 — one
                        // passphrase, one phrase, both platforms). Until
                        // this fix the phone presented the full shared
                        // vault flows AND its own reset door with NONE of
                        // them wired — a vault passphrase minted or changed
                        // here never reached the store's sidecar, and a
                        // phone reset skipped the vault half. Re-wired per
                        // session exactly like the teardown above.
                        wireOneSecretHooks(
                            protection: bootstrap.protection,
                            encryption: fresh.encryption,
                            keyVault: fresh.keyVault, auth: fresh.auth)
                        // pre-13x 2c (2b's runner at the PHONE'S root): the
                        // posture switch — entering and leaving Castle, the
                        // in-place Replace All Keys — the silent follow into
                        // Standard, and the Encryption tab's follow door,
                        // over the SAME shared runner the Mac wires (the
                        // phone is a first-class birthplace of Castle, §9).
                        // The services are read LIVE (the reopen rebuilds).
                        if let storeURL = try? AppDatabase.defaultStoreURL(
                            variant: bootstrap.storeVariant) {
                            let runner = PostureSwitchRunner(leaves: .live(
                                bootstrap: bootstrap,
                                protection: bootstrap.protection,
                                scope: bootstrap.storeVariant.rawValue,
                                storeURL: storeURL,
                                database: session.database,
                                services: { services }))
                            bootstrap.protection.switchRunner = runner
                            bootstrap.protection.followIntoStandardAct = {
                                try await runner.followIntoStandard()
                            }
                            fresh.encryption.followDoor = { bootstrap.protection.openFollow() }
                            // Row 10 (ledger 54): and whether that door will ask.
                            fresh.encryption.followDoorAsksNothing = {
                                bootstrap.protection.pendingFollowAsksNothing
                            }
                            // pre-13x 3a (decision 17): the Connect door and
                            // its act — the adopt road over the services.
                            bootstrap.protection.connectAct = { [weak fresh] passphrase, words in
                                guard let fresh else { throw ConnectLibraryError.signedOut }
                                try await fresh.connectLibrary(passphrase: passphrase, recoveryWords: words)
                            }
                            fresh.encryption.connectDoor = { bootstrap.protection.openConnect() }
                            // pre-13x 3a (copy §2d): enroll's two directed
                            // joins ride the same runner — (c) the follow
                            // with the typed secret; (d) the follow into Standard.
                            fresh.encryption.joinCastleAct = { passphrase, words in
                                _ = try await runner.follow(passphrase: passphrase, recoveryWords: words)
                            }
                            fresh.encryption.joinStandardAct = { try await runner.followIntoStandard() }
                            fresh.encryption.libraryOwnerIsForeign = { bootstrap.protection.differentOwner }
                            // pre-13x 3b (copy §4): REPLACE ALL KEYS — the
                            // ceremony held on the controller (a pending
                            // marker opens its resume instead); the change
                            // and regenerate doors hand their new secret in.
                            fresh.encryption.replaceKeysDoor = { [weak fresh] passphrase, words in
                                Task { @MainActor in
                                    let tie = VaultTie.make(services: fresh)
                                    if let pending = await runner.pendingMarker() {
                                        bootstrap.protection.openSwitch(.resume(pending), vaultTie: tie)
                                    } else {
                                        bootstrap.protection.openSwitch(
                                            .replaceKeys, vaultTie: tie,
                                            passphraseInHand: passphrase, wordsInHand: words)
                                    }
                                }
                            }
                        }
                        await fresh.start()
                        // pre-13x 2d (decision 35): THE NEXT READY — the
                        // vault hook is wired and the session restored
                        // now, so the migration-if-undone + the reconcile
                        // run again; the ready road's run had neither.
                        await bootstrap.runReadyHousekeeping()
                        // Pre-13u Act 0 — R-pre13u-1: **NOTHING IS SEEDED
                        // HERE ANY MORE.** The launch used to mint the
                        // starter Journal (R27b, batch 5) behind a sync
                        // gate and a 20-second bounded wait; her ruling
                        // moved the MINT to her first WRITE and deleted the
                        // wait, because the sign-in door lives inside the
                        // shell — so at launch on a fresh install the
                        // account question has no answer to read, and no
                        // amount of waiting gives it one. What launch does
                        // now is take ONE cheap local reading (`prime`) and
                        // hand the write doors a signal to announce to.
                        //
                        // Composed here rather than on a view for the
                        // batch-5 reason that still holds: the shell is
                        // hosted alone by several suites, and furniture
                        // must never appear in a pin's world.
                        let furniture = MobileFirstWriteFurniture(
                            session: session,
                            storeVariant: bootstrap.storeVariant,
                            // Two ACCOUNT facts, and only account facts. The
                            // A4 fence — a store that can never sync has no
                            // corpus on its way, so it must never wait for
                            // one — lives at `seedIfNeeded`, beside the
                            // store variant it is a fact about (R2-3).
                            // Composing it in here instead restated
                            // `storeVariant` through a fourth closure and
                            // let the unsafe pair be built.
                            //
                            // Captured STRONGLY, deliberately: the closures
                            // outlive nothing (the seed is awaited right
                            // here), and a nil'd weak reference would read as
                            // "no account", which is the unsafe direction.
                            gate: MobileStarterJournal.SyncGate(
                                belongsToAnAccount: {
                                    fresh.sync.isConfigured
                                        || fresh.account.variorum != nil
                                }))
                        firstWrite = furniture
                        session.onFirstWrite = { furniture.noteFirstWrite() }
                        await furniture.prime()
                    }
            case .opening:
                // 13l L-c: the store opens off the main thread now, so there
                // is a first frame with no session. Quiet by design — a
                // spinner announcing 50 ms of work is worse than the calm
                // ground the app opens onto anyway.
                MobileStoreOpeningView()
            case .locked(let lobby):
                // Phase 13p Batch 4 (item c): THE PHONE'S LOCKED LOBBY.
                // While this renders there is no session, no services, no
                // open store — and therefore no capture surface of any
                // kind: the quick-note box lives inside `MobileShellView`,
                // which exists only in `.ready`. That is item (i)'s
                // structural half (her ratification: capture demands
                // unlock first, never a plaintext side channel); the box's
                // own worded refusal covers the re-lock seam.
                MobileStoreLockView(lobby: lobby, tokens: lockedTokens)
            case .waitingForICloudKeychain(let lobby):
                // pre-13x 2a (§3.8): Standard's waiting state — the same
                // face, copy §2d's words, the doors that act.
                MobileStoreLockView(lobby: lobby, tokens: lockedTokens)
            case .libraryMissing(let lobby):
                // pre-13x 1a (§3.7): the three-door face — the lock stays.
                MobileLibraryMissingView(lobby: lobby, tokens: lockedTokens)
            case .failed(let error, let recovery):
                // 13p ladder R1-M3: `recovery` is the sidecar-present
                // unlock road — same brain and roads as the Mac's surface.
                MobileStoreFailureView(error: error, recovery: recovery) {
                    bootstrap.retry()
                }
            case .roadLobby, .newLibraryWords:
                // VX-306 U1b: the new road's faces are the Mac's this unit — the one switch is off on the phone
                // (P-VX306-U1b-1), so these never arrive here; the phone's faces are U3's.
                MobileStoreOpeningView()
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
                quickNote: shellRouter.quickNote, savepoint: savepoint,
                relock: relockCoordinator())
        }
    }

    // (The protection-class pick lives in AppBootstrap.open() — Phase 8
    // review round 1: iOS data protection is inherited AT CREATION, so it
    // must precede the first open.)

    /// The re-lock coordinator, minted once and kept: its ONE piece of
    /// state is the leaving stamp, which a per-call construction would
    /// throw away between the two scene edges that need to compare it.
    /// It reads the dials FRESH at every fire (the Mac monitors' rule),
    /// so a dial changed mid-session is honoured without re-wiring.
    @MainActor
    private func relockCoordinator() -> MobileRelockCoordinator {
        if let relock { return relock }
        let bootstrap = bootstrap
        let fresh = MobileRelockCoordinator(
            // pre-13x 2a: the EFFECTIVE gate (derived) + Castle's dials,
            // read fresh per store id at every fire.
            facts: { (bootstrap.currentEffectiveGate, bootstrap.currentDials) },
            lock: { await bootstrap.lock() })
        relock = fresh
        return fresh
    }
}
