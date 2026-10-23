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
    /// The copy doors' presenters (VX-306 U3; 13x U2 row 6's shape): the MAIN scene's (File ▸ Open Library… + the
    /// lobby faces' doors) and SETTINGS' own (the Restore surface) — two instances so the two scenes' sheets can never
    /// both fire over one model.
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
                // VX-306 U3: a picked copy's doors, Make this my library (the File door and the lobby faces all drive
                // this presenter).
                .sheet(isPresented: Binding(
                    get: { libraryOpen.roadDoors != nil },
                    set: { if !$0 { libraryOpen.dismissRoad() } })
                ) {
                    if let doors = libraryOpen.roadDoors {
                        CopyDoorsSheet(model: doors) { libraryOpen.dismissRoad() }
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
                // (13n-b U2's self-presenting ASK SHEET lived here — the door's
                // first waiting ask, presented on every main window the
                // moment it arrived. RETIRED at 13n-c U4 — ARRIVAL X, the
                // VX-156 brief §5: an ask WAITS at its pending glyph on the
                // thing it names and in Settings ▸ MCP ▸ Waiting, and its
                // sheet opens only on HER press, in the window she pressed
                // in (`RootView`'s / `NoteWindowView`'s `mcpAskSheet`). No
                // host in this file may present one again — pinned by
                // `MCPAsksWaitTests.noSceneHostsTheAskSheet`.)
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
                openDoor: libraryOpen, handOffDoor: handOff, mcp: appDelegate.mcp)
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
                    windows: windows,
                    hotKeys: hotKeys, whatsNew: appDelegate.whatsNew,
                    // VX-468: a copy door landed a library in this process — What's New waits for the next launch.
                    whatsNewWaits: bootstrap.adoptedALibraryThisProcess,
                    calmAsks: appDelegate.calmAsks,
                    // 13s-b U1a: the first-open tour offer's one model.
                    tourOffer: appDelegate.tourOffer,
                    // 13n-c U3: the share faces' road is built from the door.
                    mcp: appDelegate.mcp,
                    // VX-307 U2b: the new road's card above the quick entry and the tour's last card (nil today).
                    protectionFaces: bootstrap.roadStanding)
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
                    // VX-486: the locked sync row's door to Settings ▸
                    // Protection — the bootstrap's one pane ask (the
                    // crossings' own road), adopted by the Settings window.
                    .environment(\.protectionPaneDoor, ProtectionPaneDoor.settings(bootstrap.protection))
                    .task {
                        // 13x U2 row 7: the hold's projection — fresh per
                        // ready (this task re-runs after every adoption's
                        // reopen), BEFORE the services guard so a re-ready
                        // always re-reads the marker.
                        // 13n-b U1 (A-8): the MCP door follows the open
                        // store — EVERY ready, before the services guard
                        // (an adoption's reopen re-readies with the services
                        // standing, and the door must not keep watching the
                        // old writer); idempotent per session, so a window
                        // re-appearing never drops a live connection. It
                        // serves iff its toggle is ON and stops at lock and
                        // quit. 13n-b U2 (R-13nb-6): the store's path rides
                        // in so an adopted library's restore hold lands the
                        // server OFF before it could start (ledger row 10).
                        appDelegate.mcp.attach(
                            session: session, storeURL: bootstrap.liveStoreURL, windows: windows)
                        // VX-306 U2: the new road's receipts (rule 1's restore, the offer's *Use it*, the
                        // passphrase set) are spoken on this window's status seam — `receipt_style` governs them as
                        // every receipt; the receipts the open owes are spoken once, here.
                        bootstrap.roadStanding?.speak = { text in session.status.receipt(text) }
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
                            // VX-423: the process's one refresh authority —
                            // the vault leaf rides the same one.
                            auth: bootstrap.auth,
                            // VX-307 U1: the engine's keys come from the
                            // protection core's custody (rule 15).
                            makeSyncKeyProvider: { [newRoadSyncKeys = bootstrap.newRoadSyncKeys] in newRoadSyncKeys },
                            // VX-314: the engine's account-binding gate — the
                            // bound account from the SAME truth the key
                            // provider reads (the protection record's).
                            boundAccountRead: { @Sendable [newRoadSyncKeys = bootstrap.newRoadSyncKeys] in
                                newRoadSyncKeys.boundAccount
                            },
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
                        // VX-308 U1 (P-VX308-U1-F1): the Account sheet's Delete Account also runs the protection
                        // half (the open library stops naming the deleted account — rule 16's local leave); and the
                        // account section's *Sign out…* signs out through this one session.
                        fresh.afterAccountDeleted = { account in
                            await bootstrap.accountDeletedOnNewRoad(account)
                        }
                        bootstrap.roadAccount?.signOutRoad = { [weak fresh] in await fresh?.signOutVariorum() }
                        // VX-306 U1b → VX-329 U1: the backup clock's writer is the open library's pair road (rule
                        // 5's pair — the library + its key file), per services instance (every reopen rebuilds them).
                        ProtectionBackupHook.attach(to: fresh.backup, session: bootstrap.roadSession)
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
                            hold.wireGates(sync: fresh.sync)
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
                        bootstrap.onWillLock = macWillLock(
                            session: session,
                            // VX-394 (VX-348 U5): each live MCP connection's
                            // end is said while the store is still open.
                            endingConnections: { await appDelegate.mcp.recordLibraryClosing() }
                        ) {
                            services?.stop()
                            services = nil
                            // 13n-b U1 (A-8): a locked library serves no one.
                            appDelegate.mcp.detach()
                        }
                        await fresh.start()
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
                    // 13x U2 row 7: the restore-hold banner — a standing bar
                    // until the one Resume press — above rule 27's banner
                    // (VX-306 U2; today's 13p notice bar left with today's
                    // road at VX-329).
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        VStack(spacing: 0) {
                            if let restoreHold {
                                // VX-473 (F-U2-2): the account clause reads
                                // whether the OPEN LIBRARY syncs with an
                                // account — its standing faces' record fact,
                                // observable, re-read when an account act
                                // lands — never whether this Mac is signed in
                                // (Make this my library while signed in lands
                                // a library that names no account). Unknown
                                // (no faces) keeps the shipped wording.
                                RestoreHoldBar(
                                    model: restoreHold,
                                    hasAccount: bootstrap.roadStanding?.syncsWithAnAccount ?? true)
                            }
                            // VX-306 U2: rule 27's banner. (VX-307 U2c dropped the split pair's line; U2b moved rule
                            // 3's reminder into the card above the quick entry.)
                            ProtectionRoadBar(model: bootstrap.roadStanding)
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
            case .libraryMissing(let lobby):
                // pre-13x 1a (§3.7): the three-door face — the lock stays.
                // 13x U2 row 6: the third door lands (copy §3's "Open an
                // Existing Library…", shipped unrendered since 1a).
                // VX-306 U3: on the new road the door leads to the picked flow — filed, then Look inside (Make this my
                // library needs a library open; the empty-slot landing, T-5, is VX-309's) — P-VX306-U3-7 narrowed.
                LibraryMissingView(
                    lobby: lobby, openDoor: { libraryOpen.openPanel(bootstrap: bootstrap) },
                    // VX-309 U1b: Restore from a Backup… is the doors over this Mac's copies (rule 17).
                    restoreDoor: { libraryOpen.openRestoreList(bootstrap: bootstrap) })
            case .failed(let error):
                StoreFailureView(error: error) { bootstrap.retry() }
            case .roadLobby(let lobby):
                // VX-306 U1b: the road's lobby — roads only, before unlock. U2: rule 27's face carries the missing
                // face's doors.
                RoadLockView(
                    lobby: lobby,
                    // VX-306 U3: the door leads to the picked flow — filed, then Look inside (P-VX306-U3-7 narrowed).
                    openDoor: { libraryOpen.openPanel(bootstrap: bootstrap) },
                    // VX-309 U1b: Restore from Backup… is the doors over this Mac's copies (rule 17).
                    restoreDoor: { libraryOpen.openRestoreList(bootstrap: bootstrap) },
                    copiesHome: bootstrap.liveStoreURL.map(RoadLockView.copiesHome(besideStore:)) ?? false)
            case .newLibraryWords(let card):
                // VX-307 U2b (VX-412): the creation-time words card RETIRED on the Mac — the first open has nothing in
                // front of it (`ProtectionRoad.showsWordsAtCreation` is false here, so the bootstrap never lands on this
                // state on the Mac; the phone keeps its card, P-VX307-U2b-0). Should it ever arrive, the open goes
                // straight on: the words forgotten unseen (nothing stores them) — the card above the quick entry offers
                // fresh ones when she asks.
                StoreOpeningView()
                    .onAppear { card.iveWrittenThemDown() }
            case .roadInterlude(let interlude):
                // VX-306 U2: rule 21's notice, then the key-file offer — once, before the library shows.
                RoadInterludeCard(model: interlude)
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
                NoteWindowView(session: session, windows: windows, postID: postID, mcp: appDelegate.mcp)
            case (.failed(let error), _):
                // The note window shows the failure plainly; the MAIN
                // window carries the recovery roads (one unlock surface,
                // not two competing ones).
                StoreFailureView(error: error) { bootstrap.retry() }
            case (.opening, _):
                StoreOpeningView()
            case (.roadLobby, _), (.newLibraryWords, _), (.roadInterlude, _):
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
            // The scene's content lives in `SettingsSceneContent` (VX-224:
            // moved verbatim so a pin mounts exactly what this window shows).
            SettingsSceneContent(
                bootstrap: bootstrap, services: services,
                appearance: appDelegate.appearance,
                updates: appDelegate.updates,
                crashReports: appDelegate.crashReports,
                mcp: appDelegate.mcp,
                libraryOpen: settingsLibraryOpen,
                handOff: settingsHandOff)
        }
    }
}
