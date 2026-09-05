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
                RootView(
                    session: session, services: services,
                    protection: bootstrap.protection, windows: windows,
                    hotKeys: hotKeys)
                    .onAppear { appDelegate.session = session }
                    .task {
                        guard services == nil else { return }
                        let fresh = AppServices(
                            session: session,
                            storeVariant: bootstrap.storeVariant,
                            backupEnabled: true,
                            // 13l Act 4 (row 13): the Mac's own restore
                            // recipe, dropped into every backup folder.
                            backupRunbookText: DataSafetyCopy.runbook,
                            // The retired-credential sweep — REQUIRED at the
                            // seam (pre-13x 1a); production names the real one.
                            legacyCleanup: { LegacyPasteInCleanup.clear() })
                        services = fresh
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
                        await fresh.start()
                        // Pre-13u Act 3: THE SAMPLE LIBRARY — the Sherlock
                        // adventures as a real book, seeded once per store.
                        // Her ruling is default-on in every reader's store,
                        // which puts this on every launch's path, so where
                        // it sits matters: HERE, inside the window's own
                        // `.task` and after `start()`, so (1) first paint is
                        // already done — nothing in the launch awaits it —
                        // and (2) the sign-in question is settled, so the
                        // gate below reads facts instead of a coin flip (the
                        // starter journal's batch-5 MAJOR, whose duplicate
                        // book propagated to every device). Idempotent by
                        // construction and resumable, so a re-run after an
                        // unlock — or after a cancelled seed — is safe.
                        await SampleLibrarySeeder.seedIfNeeded(
                            session: session,
                            storeVariant: bootstrap.storeVariant,
                            gate: SampleLibrarySeeder.SyncGate(
                                // Captured strongly, deliberately: the
                                // closures outlive nothing, and a nil'd weak
                                // reference would read as "no account",
                                // which is the unsafe direction.
                                belongsToAnAccount: {
                                    fresh.sync.isConfigured
                                        || fresh.account.variorum != nil
                                },
                                hasSyncedCleanly: {
                                    fresh.sync.status.lastSuccessAt != nil
                                }))
                    }
                    // 13p: the calm, dismissible protection notices (the
                    // Standard nudge's two-offer shape + the reminder).
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        ProtectionNoticeBar(
                            controller: bootstrap.protection, services: services)
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
            case .libraryMissing(let lobby):
                // pre-13x 1a (§3.7): the three-door face — the lock stays.
                LibraryMissingView(lobby: lobby)
            case .failed(let error, let recovery):
                // 13p ladder R1-M3: `recovery` is the sidecar-present
                // unlock road — non-nil when the key custody is empty but
                // `variorum-keys.json` with wraps sits beside the store.
                StoreFailureView(error: error, recovery: recovery) { bootstrap.retry() }
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
            case (.failed(let error, _), _):
                // The note window shows the failure plainly; the MAIN
                // window carries the recovery roads (one unlock surface,
                // not two competing ones).
                StoreFailureView(error: error) { bootstrap.retry() }
            case (.opening, _):
                StoreOpeningView()
            case (.locked, _):
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
        // Phase 13 (B2/R52): the Settings window — Appearance (the voice +
        // the B1 global settings) and the TAG MANAGER's real home.
        Settings {
            if case .ready(let session) = bootstrap.state {
                AppSettingsView(
                    session: session, services: services,
                    protection: bootstrap.protection)
            } else {
                Text("Open the main window first.")
                    .padding(24)
            }
        }
    }
}
