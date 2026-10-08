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
    /// 13e E14 (W26): the app's SYSTEM hot keys — ⌃⌥⌘N summons the quick-note
    /// pad while any app is frontmost. App-level like the window register and
    /// for the same reason: there is one of it, however many windows exist.
    /// `RootView` installs it (it holds the `openWindow` the summon needs);
    /// installing is idempotent, so a second window costs nothing.
    @State private var hotKeys = GlobalHotKeyCenter()
    /// 13x U2 row 6 — the adoption doors' presenters: the MAIN scene's
    /// (File ▸ Open Library… + the lobby faces' doors) and SETTINGS' own
    /// (the Restore surface) — two instances so the two scenes' sheets
    /// can never both fire over one model.
    @State private var libraryOpen = LibraryOpenPresenter()
    @State private var settingsLibraryOpen = LibraryOpenPresenter()
    /// 13x F1 (ladder R1-MAJOR): the hand-off door's presenters — the
    /// File menu's and Data Safety's twin, one per scene like the
    /// adoption pair above.
    @State private var handOff = LibraryHandOffPresenter()
    @State private var settingsHandOff = LibraryHandOffPresenter()
    /// 13x U2 row 7 — the restore-hold's observable state (the marker
    /// beside the store, projected): the banner renders it, the sync
    /// session's gate reads it. Built at the first task (it needs the
    /// bootstrap's store home).
    @State private var restoreHold: RestoreHoldModel?

    var body: some Scene {
        // Batch 7: a sane fresh-window size (the oversized-window report —
        // an inherited frame taller than the screen made the shelf's
        // bottom bars and the navigator's doors invisible).
        //
        // 13f batch 5b: the group gains an id so File ▸ New Window can open
        // another one by name.
        WindowGroup(id: EditorCommands.mainWindowGroupID) {
            mainWindowContent
                // 13x U2 row 6: the one adoption sheet of the MAIN scene
                // (the File door and the lobby faces all drive this
                // presenter).
                .sheet(isPresented: Binding(
                    get: { libraryOpen.model != nil },
                    set: { if !$0 { libraryOpen.dismiss() } })
                ) {
                    if let model = libraryOpen.model {
                        LibraryOpenSheet(model: model) { libraryOpen.dismiss() }
                    }
                }
                // 13x F1 (R1-MAJOR): the hand-off sheet — the File door's
                // progress/done/refusal face, beside the adoption sheet.
                .sheet(isPresented: Binding(
                    get: { handOff.model != nil },
                    set: { if !$0 { handOff.dismiss() } })
                ) {
                    if let model = handOff.model {
                        LibraryHandOffSheet(model: model) { handOff.dismiss() }
                    }
                }
        }
        .defaultSize(width: 1240, height: 840)
        // 13g L3 + L4 (her WT-3 and WT-4, which the screenshot proved are
        // ONE thing). Her words: *"i don't even konw if we need that empty
        // whitespace that says Variorum at the top - let's try getting rid
        // of it"* and *"the back bar should be flush with the top to match
        // the bar at the bottom, which sits underneath the floating left
        // pane."*
        //
        // MEASURED, not assumed (the Debug build, captured and zoomed): the
        // sidebar's `Section` header — which the plan named as the source —
        // renders NOTHING on macOS 26. The word she sees is the WINDOW
        // TITLE, drawn in a band across the top of the DETAIL pane with a
        // divider under it, and that band is exactly what stands between the
        // window's top edge and the pane's first row. `.toolbar(removing:
        // .title)` in `RootView` takes the word and the divider together, so
        // the pane's own chrome — the context bar, when there is one — is
        // the topmost thing in the detail. That is the flush edge her WT-3
        // asks for, mirroring the status bar along the bottom.
        //
        // The strip that REMAINS above it is the window's toolbar row, and
        // it is not empty: it carries the traffic lights, New Note and the
        // sidebar toggle. `.unifiedCompact` is the shortest honest form of
        // it — everything stays reachable and the band stops being taller
        // than the things in it.
        //
        // TWO ATTEMPTS MEASURED AND REJECTED on the way here (screenshots in
        // the batch record):
        //   · `.ignoresSafeArea(.container, edges: .top)` on the detail — the
        //     toolbar band is OPAQUE, so the pane's first row slid under it
        //     and became unreadable. A worse bug than the whitespace.
        //   · `.windowStyle(.hiddenTitleBar)` — captured before and after and
        //     compared at the same key state: NO visible difference once the
        //     title itself is removed. A modifier that changes window
        //     behaviour and nothing on screen is not worth carrying.
        //     (It also LOOKED like it un-floated the sidebar; the
        //     discriminating capture — the ORIGINAL binary, not key — proved
        //     the floating card is simply the KEY-WINDOW appearance. Recorded
        //     because the wrong conclusion was one screenshot away.)
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            // 13r U2: the update channel rides in for the app menu's
            // Check for Updates… door (rendered only where it can act).
            EditorCommands(
                bootstrap: bootstrap, windows: windows, updates: appDelegate.updates,
                openDoor: libraryOpen, handOffDoor: handOff)
        }
        noteWindows
    }

    /// The launch seed's REAL gate (17y B-SEED's composition, byte-moved —
    /// 13s-b U1b's diagnosis only NAMED it so the DEBUG walk override above
    /// has one production body to fall through to): captured strongly,
    /// deliberately — the closures outlive nothing, and a nil'd weak
    /// reference would read as "no account", which is the unsafe direction.
    private func productionSeedGate(_ fresh: AppServices) -> SampleLibrarySeeder.SyncGate {
        SampleLibrarySeeder.SyncGate(
            belongsToAnAccount: {
                fresh.sync.isConfigured || fresh.account.variorum != nil
            },
            hasSyncedCleanly: { fresh.sync.status.lastSuccessAt != nil })
    }

    @ViewBuilder
    private var mainWindowContent: some View {
            switch bootstrap.state {
            case .ready(let session):
                RootView(
                    session: session, services: services,
                    protection: bootstrap.protection, windows: windows,
                    hotKeys: hotKeys, whatsNew: appDelegate.whatsNew,
                    calmAsks: appDelegate.calmAsks,
                    // 13s-b U1a: the first-open tour offer's one model.
                    tourOffer: appDelegate.tourOffer)
                    .onAppear {
                        appDelegate.session = session
                        #if DEBUG
                        // 17y B1: the large fixture — a no-op unless the walk
                        // launched this process with `VARIORUM_SCALE_FIXTURE`.
                        ScaleFixture.seedIfRequested(session: session)
                        #endif
                    }
                    // 13r U3-A — R-13r-13: the sync row's Check for Updates…
                    // door, from the ONE update channel; nil unless it is
                    // live (never in a Debug build), and then no door shows.
                    .environment(\.checkForUpdatesDoor, appDelegate.updates.syncRowDoor)
                    .task {
                        // 13x U2 row 7: the hold's projection — fresh per
                        // ready (this task re-runs after every adoption's
                        // reopen), BEFORE the services guard so a re-ready
                        // always re-reads the marker.
                        if restoreHold == nil {
                            restoreHold = RestoreHoldModel(storeURL: bootstrap.liveStoreURL)
                        } else {
                            restoreHold?.refresh()
                        }
                        guard services == nil else { return }
                        let fresh = AppServices(
                            session: session,
                            storeVariant: bootstrap.storeVariant,
                            backupEnabled: true,
                            // 13l Act 4 (row 13): the Mac's own restore
                            // recipe, dropped into every backup folder.
                            backupRunbookText: DataSafetyCopy.runbook,
                            // 17y B-DEDUPE: the Mac's furniture-fold facts =
                            // the shared half + the GUIDE's (the engine's
                            // pairwise fold; the phone wires the shared half
                            // alone — its pocket guide is the parity row).
                            // 13s-b U1b: composed in ONE named, pinnable
                            // place — and it now carries the readme and the
                            // example snippet (the birth furniture's folds).
                            furnitureFacts: MacFurnitureFacts.compose(),
                            // The retired-credential sweep — REQUIRED at the
                            // seam (pre-13x 1a); production names the real one.
                            legacyCleanup: { LegacyPasteInCleanup.clear() })
                        services = fresh
                        // 13x U2 row 7: the restore-hold's gate — wired
                        // BEFORE start() so no first round outruns it; the
                        // one Resume press clears the hold and catches up
                        // (QD: the kept outbox pushes in that round).
                        if let hold = restoreHold {
                            // 13x F3 (ladder R3-2): BOTH gates — the round
                            // trigger and the rotation ceremonies' door
                            // (F1 R1-M1: Replace All Keys / Use Castle
                            // refuse while held) — read the MARKER, never
                            // the projection this `.task` refreshes.
                            hold.wireGates(sync: fresh.sync, protection: bootstrap.protection)
                            hold.onResume = { [weak fresh] in
                                await fresh?.resumeSync()
                            }
                        }
                        // Phase 13p (the re-lock teardown, THE DESIGN's
                        // ruled order): a lock FLUSHES and SAVEPOINTS every
                        // open note (⌘Q's leaving doctrine — the same
                        // registry), STOPS the services, and lets them go —
                        // the next unlock composes fresh ones over the
                        // fresh session, which is exactly the "deferred
                        // starts begin only after the stack exists" rule.
                        // Pre-13u Act 9 (17a P3): via the factory, which
                        // ALSO runs the active editor's full finalize —
                        // the open tail and a pending cross-block compound
                        // were dropped by the registry-only shape (see
                        // MacWillLock.swift).
                        bootstrap.onWillLock = macWillLock(session: session) {
                            services?.stop()
                            services = nil
                        }
                        // pre-13x 2a (decision 18, row 7): the KEYLESS
                        // byte-copy of the closed library at lock time when
                        // a backup is due — the app's own folder only; the
                        // values are captured (the services are gone by the
                        // time it runs), never the objects.
                        if let storeURL = try? AppDatabase.defaultStoreURL(
                            variant: bootstrap.storeVariant) {
                            let directory = storeURL.deletingLastPathComponent()
                                .appendingPathComponent("Backups", isDirectory: true)
                            bootstrap.lockTimeCopy = {
                                StoreBackup.performLockTimeCopyIfDue(
                                    storeURL: storeURL, directory: directory,
                                    interval: StoreBackup.Configuration().interval,
                                    defaults: .standard, now: Date())
                            }
                        }
                        // 13p one-secret wiring (R13p-4): the vault's
                        // passphrase FOLLOWS into the store wrap; the vault's
                        // twelve words follow too (R1-m3's twin); the store
                        // wrap GUARDS vault setup; and the reset door's
                        // vault half re-wraps from held material (R13p-9 —
                        // an enrolled account that cannot follow refuses
                        // the whole reset rather than diverging). Extracted
                        // to the SHARED factory at ladder R2-M1 so the phone
                        // wires the SAME composition — see
                        // `wireOneSecretHooks` (ProtectionController.swift).
                        wireOneSecretHooks(
                            protection: bootstrap.protection,
                            encryption: fresh.encryption,
                            keyVault: fresh.keyVault, auth: fresh.auth)
                        // pre-13x 2b: THE POSTURE-SWITCH RUNNER — entering
                        // and leaving Castle, and the in-place Replace All
                        // Keys the Encryption tab's door now runs. Built
                        // here because it composes the bootstrap's re-key
                        // road with the controller's custody and the
                        // services' vault; the services are read LIVE
                        // (the reopen rebuilds them).
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
                            // pre-13x 2c (§7): the silent follow into Standard
                            // and the Encryption tab's follow door ride the
                            // same runner.
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
                        // THE LAUNCH'S FURNITURE — the sample books, the
                        // starred-notes gathering and, at a fresh store's
                        // birth, the Welcome arrangement. HERE, inside the
                        // window's own `.task` and after `start()`: first
                        // paint is done and the sign-in question is settled
                        // (the gate reads facts). 17y B-SEED moved the body
                        // verbatim into `LaunchFurniture.seed` so the pins
                        // drive this exact composition — its header carries
                        // every seed's reasons.
                        let seedGate: SampleLibrarySeeder.SyncGate
                        #if DEBUG
                        // 13s-b U1b DIAGNOSIS (the coordinator's fresh-walk
                        // block, 2026-10-08 — the U1b record's section): the
                        // DEV scope carries a persisted device-bound session
                        // that a store reset never clears, so EVERY fresh
                        // dev store takes the arrive-by-sync road and — dev
                        // sync being off by the A4 fence — waits forever,
                        // seeding nothing and marking nothing (F-BSEED-4's
                        // recorded corner, QUESTIONS #183). A WALK of the
                        // fresh seed therefore needs this launch treated as
                        // unowned: the env key below does exactly that,
                        // DEBUG-only (the ScaleFixture idiom — walk
                        // machinery, zero Release bytes, zero store state).
                        // A REAL fresh install is signed out (the session
                        // is device-bound), takes Road 1 and seeds — the
                        // production pin `aFreshLaunchSeedsTheFinalSet`
                        // drives that composition headlessly.
                        if ProcessInfo.processInfo
                            .environment["VARIORUM_SEED_GATE_UNOWNED"] == "1" {
                            seedGate = .unowned
                        } else {
                            seedGate = productionSeedGate(fresh)
                        }
                        #else
                        seedGate = productionSeedGate(fresh)
                        #endif
                        await LaunchFurniture.seed(
                            session: session,
                            storeVariant: bootstrap.storeVariant,
                            gate: seedGate)
                    }
                    // 13p: the calm, dismissible protection notices (the
                    // Standard nudge's two-offer shape + the reminder).
                    // 13x U2 row 7: the restore-hold banner stacks above
                    // them — a standing bar until the one Resume press.
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        VStack(spacing: 0) {
                            if let restoreHold {
                                // Read at RENDER from the observable account
                                // state (W-4): the hold is wired before
                                // `start()` restores the sign-in, so a value
                                // captured there reads "no account" on a
                                // signed-in Mac. Unknown (no services yet)
                                // keeps the shipped account wording.
                                RestoreHoldBar(
                                    model: restoreHold,
                                    hasAccount: services.map {
                                        $0.account.variorum != nil || $0.sync.isConfigured
                                    } ?? true)
                            }
                            ProtectionNoticeBar(
                                controller: bootstrap.protection, services: services)
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(
                        for: NSApplication.didBecomeActiveNotification)) { _ in
                        // The became-active hook: one sync round (13c A2's
                        // shape; it also asked for a bridge round until the
                        // bridge's 2026-09-04 retirement — the wrapper that
                        // held both halves left with it, round-1 MINOR-4).
                        services?.sync.triggerSync()
                    }
            case .opening:
                // 13l L-c: the store opens off the main thread now, so there
                // is a first frame with no session. Quiet by design — see
                // StoreOpeningView.
                StoreOpeningView()
            case .locked(let lobby):
                // Phase 13p: the demanded at-open modes' lobby — no store,
                // no session, no services until it unlocks (R13p-5).
                StoreLockView(lobby: lobby)
            case .waitingForICloudKeychain(let lobby):
                // pre-13x 2a (§3.8): Standard's waiting state — the same
                // face, copy §2d's words, the doors that act. 13x U2
                // row 6: §3.8's second door — "open an existing library".
                StoreLockView(lobby: lobby, openDoor: {
                    libraryOpen.openPanel(bootstrap: bootstrap)
                })
            case .libraryMissing(let lobby):
                // pre-13x 1a (§3.7): the three-door face — the lock stays.
                // 13x U2 row 6: the third door lands (copy §3's "Open an
                // Existing Library…", shipped unrendered since 1a).
                LibraryMissingView(lobby: lobby, openDoor: {
                    libraryOpen.openPanel(bootstrap: bootstrap)
                })
            case .failed(let error, let recovery):
                // 13p ladder R1-M3: `recovery` is the sidecar-present
                // unlock road — non-nil when the key custody is empty but
                // `variorum-keys.json` with wraps sits beside the store.
                StoreFailureView(error: error, recovery: recovery) { bootstrap.retry() }
            }
    }

    /// The scenes beside the main window (13f's two window kinds, the
    /// quick-note pad, the helper, Settings) — unchanged but for hosting;
    /// split out when 13x U2 gave the main WindowGroup its adoption sheet.
    @SceneBuilder
    private var noteWindows: some Scene {
        // 13f batch 5b (W2/A26 — her round-2 ruling: BOTH window kinds).
        // The lightweight NOTE-ONLY window: one note, its detail and its
        // context bar, and deliberately no sidebar, no Open strip and no
        // split. Every app-scope act is honestly grey there through the
        // gates that already exist (see `WorkspaceModel.showOnly`).
        WindowGroup(id: EditorCommands.noteWindowGroupID, for: String.self) { $postID in
            switch (bootstrap.state, postID) {
            case (.ready(let session), .some(let postID)):
                NoteWindowView(session: session, windows: windows, postID: postID)
            case (.failed(let error, _), _):
                // The note window shows the failure plainly; the MAIN
                // window carries the recovery roads (one unlock surface,
                // not two competing ones).
                StoreFailureView(error: error) { bootstrap.retry() }
            case (.opening, _):
                StoreOpeningView()
            case (.locked, _), (.waitingForICloudKeychain, _):
                // 13p: note windows never outlive a lock (the whole
                // `.ready` tree tears down); a restored one says so.
                Text("Variorum is locked — unlock it in the main window.")
                    .padding(24)
            case (.libraryMissing, _):
                Text("\(ProtectionCopy.libraryMissingTitle) See the main window.")
                    .padding(24)
            default:
                // No note handed over (a restored window whose value did not
                // come back): honest, not a blank pane.
                Text("Open a note from the main window.")
                    .padding(24)
            }
        }
        .defaultSize(width: 760, height: 720)
        // 13f batch 6 (W5 — her round-3 ruling: a FLOATING MINI-WINDOW).
        // A SINGLETON `Window`, because there is one pad; floating, so it
        // stays above the writing it is a note about. Measured before it
        // was written: `.windowLevel(.floating)` type-checks clean at
        // macOS 26 against both SDKs, so this needs no `NSPanel` bridge and
        // therefore no second window mechanism beside the two groups above.
        //
        // It is a CAPTURE surface — no text surface of its own, so P-3 is
        // not extended here, it is simply not engaged (see QuickNoteView).
        Window(QuickNoteCopy.verb, id: EditorCommands.quickNoteWindowGroupID) {
            if case .ready(let session) = bootstrap.state {
                QuickNoteView(session: session, windows: windows)
            } else {
                Text("Open the main window first.")
                    .padding(24)
            }
        }
        .defaultSize(width: 340, height: 260)
        .windowLevel(.floating)
        .windowResizability(.contentSize)
        // Her round-14.1 ruling: YES to the menu-bar icon — the
        // summon-from-anywhere door, and the permission-free one (the true
        // system-wide hotkey is out of v1 by her round-14.4 ruling; ledger
        // row W26). It opens the same one pad the other two doors do.
        MenuBarExtra(QuickNoteCopy.verb, systemImage: "square.and.pencil") {
            QuickNoteMenuBarContent()
        }
        // Sitting 9 (R73/R91): the shortcut helper + dictionary window
        // (⌘/, Help menu, the status bars' "?").
        Window("Shortcuts & Dictionary", id: "variorum-helper") {
            HelperView()
        }
        .defaultSize(width: 680, height: 560)
        // 13s-b U1a, piece 4 (R-13s-24/25): the About window — the mark, the
        // lowercase serif wordmark, the version (`AboutView`). A singleton,
        // sized to its content, like the system panel it replaces.
        Window(AboutCopy.menuTitle, id: AboutCopy.windowID) {
            AboutView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        // Phase 13 (B2/R52): the Settings window — Appearance (the voice +
        // the B1 global settings) and the TAG MANAGER's real home.
        Settings {
            if case .ready(let session) = bootstrap.state {
                AppSettingsView(
                    session: session, services: services,
                    protection: bootstrap.protection,
                    // 18j: the app's ONE appearance owner, handed to its
                    // door. Never re-read from `UserDefaults` by the pane
                    // (F-0: a setting is read once at its owner and pushed
                    // down) — the pane binds to this object.
                    appearance: appDelegate.appearance,
                    // 13r U3-A: General's "Check for updates automatically"
                    // — rendered only where the channel is live (P-2).
                    updates: appDelegate.updates,
                    // 13r U3-B: Settings ▸ Diagnostics — the ONE crash-
                    // reporting owner (opt-in, default OFF).
                    crashReports: appDelegate.crashReports,
                    // 13x U2 row 6: the Restore surface's per-row door —
                    // Settings' OWN presenter (the main scene's sheet and
                    // this one can never both fire).
                    restoreDoor: { picked in
                        settingsLibraryOpen.begin(bootstrap: bootstrap, picked: picked)
                    },
                    // 13x F1 (R1-MAJOR): Data Safety's hand-off twin —
                    // Settings' OWN presenter, the restore door's pattern.
                    handOffDoor: {
                        settingsHandOff.openPanel(session: session, bootstrap: bootstrap)
                    })
                    .sheet(isPresented: Binding(
                        get: { settingsLibraryOpen.model != nil },
                        set: { if !$0 { settingsLibraryOpen.dismiss() } })
                    ) {
                        if let model = settingsLibraryOpen.model {
                            LibraryOpenSheet(model: model) { settingsLibraryOpen.dismiss() }
                        }
                    }
                    .sheet(isPresented: Binding(
                        get: { settingsHandOff.model != nil },
                        set: { if !$0 { settingsHandOff.dismiss() } })
                    ) {
                        if let model = settingsHandOff.model {
                            LibraryHandOffSheet(model: model) { settingsHandOff.dismiss() }
                        }
                    }
            } else {
                Text("Open the main window first.")
                    .padding(24)
            }
        }
    }
}
