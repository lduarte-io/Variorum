//
//  RootView.swift
//  Variorum
//
//  Root chrome (reworked Phase 13, B2): the FINAL sidebar (Shelf · Library
//  · Pool · Blocks — R44) + the selected traversal in the detail pane,
//  voiced through the token layer. The shelf is HOME. Cross-feature
//  routing lives HERE, in composition — plus the shell router's adoption
//  (⌘N/⌘J/⌘K arrive from the menu bar) and the ⌘K palette (R15).
//

import SwiftUI
import VariorumCore

struct RootView: View {
    let session: AppSession
    /// Session services (Phase 8) — nil for the first frames until the root
    /// `.task` starts them; the footer appears when ready.
    let services: AppServices?
    /// pre-13u Act 10 (memo §6): the unchosen-state indicator reads this.
    let protection: ProtectionController?
    /// 13f batch 5b (W2/A26): the app's register of open windows and the ONE
    /// authority on which is key. This window reads two things from it — is
    /// it the key window (the mount gate) and is it the navigation target
    /// (the app-wide broadcasts) — and writes one: its own registration.
    let windows: WindowRegistry
    /// 13e E14 (W26): the app's SYSTEM hot keys. This window INSTALLS them —
    /// it is the one place that holds both the app-lifetime centre and the
    /// `openWindow` a summon needs — and installing is idempotent, so a
    /// second window replaces the action with an identical one and asks the
    /// system for nothing more.
    let hotKeys: GlobalHotKeyCenter
    /// Menu-command routing (⌘N/⌘J/⌘K — Phase 13 B2), and since 13f batch 3
    /// this window's WORKSPACE. **Owned here since batch 5b**: it used to be
    /// App-level `@State`, which every `WindowGroup` window shared — one
    /// Open strip, one set of histories, one fold, for all of them.
    @State private var router: ShellRouter
    /// This window's identity in the registry. Minted once per window.
    @State private var windowID = UUID()
    @State private var library: LibraryViewModel
    @State private var tags: TagsViewModel
    @State private var readings: ReadingsViewModel
    @State private var pool: PoolViewModel
    @State private var shelf: ShelfViewModel
    @State private var catalog: LibraryCatalogModel
    @State private var poolPosts: PoolPostsModel
    @State private var palette: PaletteModel
    /// 13f batch 6 (W4): the starred notes and books. STORE state, not
    /// window state — it is synced, so every window shows the same five;
    /// each window observes it for itself, exactly as it does the library.
    @State private var stars: StarsModel
    /// 17y B3 item (l): the sidebar Starred section's BOOK rows' menu brain
    /// (`BookRowMenu` — the Bookcase's menu trimmed of position).
    @State private var starredBookDoors: BookRowDoors
    /// 13i-d U5 — the WINGS (the shared `Core/Views` brain): the Bookcase's
    /// switcher and the note rows' Move/Copy to Wing doors read this one.
    @State private var wings: WingsModel
    @State private var paletteOpen = false
    /// pre-13x 5b (ledger 64): the iCloud Drive offer's brain — made once the
    /// services exist; nil until then and in harness mounts without services.
    @State private var iCloudOffer: ICloudDriveOfferModel?
    /// 13r U3-A: What's New's ledger (the app delegate's one instance; nil
    /// in harness mounts, which then never auto-show) and this window's sheet.
    let whatsNew: WhatsNewLedger?
    @State private var whatsNewShown = false
    /// 13r U3-A: the calm-asks scheduler (the app delegate's one instance);
    /// this window registers the backup-folder ask once its services exist.
    let calmAsks: CalmAskScheduler?
    /// 13s-b U1a (R-13s-2/6/13): the first-open tour offer — the app
    /// delegate's ONE model (one per process, every window's Bookcase reads
    /// it); nil in harness mounts, which then draw no offer.
    let tourOffer: TourOfferModel?
    /// 13s-b U2 — THE TOUR, while one runs in THIS window (its `engine` is
    /// nil otherwise). Per window by construction (`RootView` is the window);
    /// born at `startTour()`, dropped when the tour finishes or ends. A SLOT
    /// object rather than a bare `@State` engine so the engine's doors can
    /// hold it weakly — a window closed mid-tour leaves no cycle behind.
    @State private var tourSlot = TourSlot()
    // (Stage C's parked block target LEFT this view at 17o c/d/e round 1,
    // MAJOR-2: it is `ShellRouter.blockLanding` now — same per-window scope,
    // but on the object every navigation door already speaks to, so the
    // "a navigation expires the park" rule has one home and one pin.)
    /// 13f W10b: the released original the lineage door asked to see; the
    /// recovery surface reveals it and consumes the request.
    /// 13f W20(a) — THE ASCENT: the post a book was asked to open AT. One
    /// shot, keyed by book so a stale request can never land in another
    /// book (the `blockLanding` guard's shape).
    @State private var bookAscent: BookAscent?
    /// **18d batch 1 (her U-10) — THE SIDEBAR'S NOTE BOX, composed here.**
    /// The focused pane's book publishes a VALUE and a DOOR; this view builds
    /// the box's content — the facts from the published id, the bar from the
    /// editor UNDER THE CARET (`EditorRouter.editing`, never `active`) — and
    /// hands the sidebar
    /// a view to RENDER. The sidebar never constructs or holds the book's or
    /// the editor's view model (CLAUDE.md's P39 refinement); this composition
    /// is what keeps that true.
    ///
    /// Per WINDOW by construction: `RootView` is the window (13f batch 5b),
    /// exactly as its `router` is.
    @State private var noteBoxReport: NoteBoxReport?
    @State private var noteBoxDoor: NoteBoxDoor?
    @State private var noteBoxFacts = NoteBoxFactsModel()

    struct BookAscent: Equatable {
        let bookID: String
        let postID: String
    }

    /// Phase 13 (B1): the live voice — tokens + idioms, environment-fed.
    @State private var theme: ThemeStore
    @Environment(\.openSettings) private var openSettings
    @Environment(\.colorScheme) private var scheme
    /// 13f batch 5b: "Open in New Window" on a note row.
    @Environment(\.openWindow) private var openWindow

    /// The note-row door's one body, handed to the three surfaces that
    /// render the note-row menu (the Open strip, the Library catalog, the
    /// Pool) — ONE declaration, three renderers, exactly as `.openBeside`.
    private func openInNewWindow(_ noteID: String) {
        openWindow(id: EditorCommands.noteWindowGroupID, value: noteID)
    }

    /// 13e E14: the quick note's ONE summon, from this window's environment —
    /// used by ⌘K's row (through the shell) and by the system hot key, which
    /// this window installs. `QuickNoteSummon` is the line all four doors
    /// share.
    private func summonQuickNote() {
        QuickNoteSummon.summon { openWindow(id: $0) }
    }

    /// 13f batch 6 (W4): ONE door value, handed to every surface that
    /// renders the star act (the Open strip, the Library catalog, the Pool,
    /// the shelf's book rows) — so the menu's word is derived in one place
    /// and the four cannot drift apart.
    private var starDoor: StarDoor {
        StarDoor(
            isStarred: { stars.isStarred($0) },
            toggle: { target in Task { await stars.toggle(target) } })
    }

    init(
        session: AppSession, services: AppServices? = nil,
        // pre-13u Act 10 (memo §6): the unchosen-state indicator's brain —
        // defaulted so harness mounts never need one.
        protection: ProtectionController? = nil,
        router: ShellRouter = ShellRouter(), windows: WindowRegistry = WindowRegistry(),
        // 13e E14: defaulted like `windows`, and defaulted to the INERT
        // system — a harness that mounts this view must never ask the real
        // system for her chord (it would fight the running app for it).
        hotKeys: GlobalHotKeyCenter = GlobalHotKeyCenter(system: .inert),
        whatsNew: WhatsNewLedger? = nil,
        calmAsks: CalmAskScheduler? = nil,
        tourOffer: TourOfferModel? = nil
    ) {
        self.session = session
        self.services = services
        self.protection = protection
        self.windows = windows
        self.hotKeys = hotKeys
        self.whatsNew = whatsNew
        self.calmAsks = calmAsks
        self.tourOffer = tourOffer
        _router = State(initialValue: router)
        _library = State(initialValue: LibraryViewModel(session: session))
        _tags = State(initialValue: TagsViewModel(session: session))
        _readings = State(initialValue: ReadingsViewModel(session: session))
        _pool = State(initialValue: PoolViewModel(session: session))
        // 13i-d U5: the Bookcase is ONE wing's surface — the current one.
        _shelf = State(initialValue: ShelfViewModel(
            session: session, wingID: session.wing.currentID))
        _catalog = State(initialValue: LibraryCatalogModel(session: session))
        _poolPosts = State(initialValue: PoolPostsModel(session: session))
        _palette = State(initialValue: PaletteModel(session: session))
        _stars = State(initialValue: StarsModel(session: session))
        _starredBookDoors = State(initialValue: BookRowDoors(session: session))
        _wings = State(initialValue: WingsModel(session: session))
        _theme = State(initialValue: ThemeStore(session: session))
    }

    /// The `.surface` acts this shell renders (P-1's declared ⇔ rendered
    /// walk): the sidebar toggle, a toolbar door since the correction round
    /// made the split ours (row 2).
    static let surfaceCapabilities: [CapabilityID] = [.toggleSidebar]

    var body: some View {
        // The Act 10 correction round, batch A (row 2): the flat shell —
        // `ShellSplit` (an HStack, one honest divider) in place of
        // `NavigationSplitView`, whose Tahoe sidebar is the floating glass
        // pane W8-3 ruled out. The container's reason is in its file header.
        ShellSplit(tokens: theme.tokens(for: scheme), sidebarShown: router.sidebarShown) {
            SidebarView(
                session: session, model: library, pool: pool,
                workspace: router.workspace, stars: stars, starDoor: starDoor,
                bookRowDoors: starredBookDoors,
                selection: selectionBinding,
                onOpenBeside: { router.openBeside(.post($0)) },
                onOpenInNewWindow: openInNewWindow,
                // 13b 1b: the rail's marker reads the router's observable
                // mode truth (the broadcast-derived shadow is retired).
                postMode: (session.commandRouter.activeMode ?? .takes).rawValue,
                noteBox: noteBoxView,
                bottom: statusRows)
        } detail: {
            paneRow
                // 13b 1b (AD-14): the ONE status/refusal presentation —
                // every transient outcome (refusals, undo reports, routed
                // speech) renders HERE, mode- and surface-independent,
                // with the one auto-dismiss policy.
                .overlay(alignment: .bottom) {
                    if let item = session.status.current {
                        StatusToast(
                            item: item,
                            tokens: theme.tokens(for: scheme),
                            onDismiss: { session.status.clear() })
                            .padding(.bottom, 46)
                    }
                }
        }
        .toolbar {
            // The sidebar's own door, leading — where the split view's
            // button stood; ⌃⌘S is its View-menu twin.
            ToolbarItem(placement: .navigation) {
                Button(WorkspaceNaming.toggleSidebarVerb, systemImage: "sidebar.leading") {
                    router.sidebarShown.toggle()
                }
                .help("\(WorkspaceNaming.toggleSidebarVerb) (\u{2303}\u{2318}S)")
            }
            ToolbarItem(placement: .navigation) {
                Button("New Note", systemImage: "square.and.pencil") {
                    Task {
                        if let id = await library.createPost() {
                            adopt(.post(id), in: router.workspace.focusedPane)
                        }
                    }
                }
            }
        }
        // 13g L4 (WT-4): *"i don't even konw if we need that empty whitespace
        // that says Variorum at the top - let's try getting rid of it."*
        // MEASURED (the Debug build, captured and zoomed): the word she sees
        // is the WINDOW TITLE, drawn in a band across the top of the detail
        // pane — NOT the sidebar `Section` header the plan named, which
        // renders nothing at all on macOS 26. Removing the title takes the
        // band's only content away; `.ignoresSafeArea` above takes the band
        // itself. A TRY, per her word — one modifier to put back.
        .toolbar(removing: .title)
        // 13s-b U2 — the tour's cards over the whole window (never a dim —
        // R-13s-12) and its spotlight in every door's environment (nil, and
        // so inert, whenever no tour runs).
        .tourLayer(tourSlot.engine, sources: tourSources)
        .environment(theme)
        // 13i-d U6 (k): the shared wings model reaches the note ▾ menus (both
        // bars render the cross-wing doors) without threading it through
        // every pane — the theme store's own road; consumers read it optional.
        .environment(wings)
        // 13f batch 5b: AppKit's own key events, reported to the registry —
        // the ONE place key-ness is decided (and it is sticky there: a
        // resign never un-keys, so ⌘-tabbing to another app does not tear
        // this window's live surface down).
        .background {
            WindowKeyReporter(
                onWindow: { windows.attach($0, to: windowID) },
                onKey: { windows.noteKey(windowID) })
        }
        .sheet(isPresented: $paletteOpen) {
            CommandPaletteView(
                model: palette,
                onOpen: { picked, blockID in open(picked, blockID: blockID) },
                // 13o U2 (D7): a passage lands at its match (D6) …
                onLand: { picked, blockID, find in open(picked, blockID: blockID, find: find) },
                // … and the road row opens the Library's answer sheet on the
                // same words (R-13o-9).
                onSearchLibrary: { words in searchLibrary(words) })
            .environment(theme)
        }
        // pre-13x 5b (ledger 64 — decision 24): THE iCLOUD DRIVE OFFER's
        // sheet. 13r U3-A — R-13r-12: it no longer opens at the first backup
        // run (which greeted the first open); the ask is the calm-asks
        // cadence's OFFER toast — from the 5th day of use, once the library
        // holds her own writing, never on the update ask's day — whose
        // Set Up… opens this sheet and whose Not Now is the existing mark.
        .task(id: services != nil) {
            guard let services, iCloudOffer == nil else { return }
            let offer = ICloudDriveOfferModel(
                leaves: .live(services: services, protection: protection))
            iCloudOffer = offer
            guard let calmAsks else { return }
            let ownWriting = OwnWritingProbe(session: session)
            let status = session.status
            calmAsks.register(.init(
                id: CalmAskScheduler.AskID.backupFolder, rank: 1,
                fromDay: calmAsks.numbers.backupAskFromDay,
                maxShows: 2, returnsAfterDays: calmAsks.numbers.backupReturnsAfterDays,
                host: windowID,
                wantsAsking: { [weak offer] in
                    guard let offer, offer.stillWantsAsking() else { return false }
                    return await ownWriting.holdsOwnWriting()
                },
                present: { [weak offer] in
                    guard let offer else { return }
                    status.offer(
                        CalmAskCopy.backupQuestion,
                        action: .init(label: CalmAskCopy.backupSetUpDoor) { offer.openSheet() },
                        secondary: .init(label: CalmAskCopy.backupNotNowDoor) { offer.notNow() })
                }))
        }
        .sheet(isPresented: Binding(
            get: { iCloudOffer?.isDue ?? false },
            set: { shown in if !shown { iCloudOffer?.notNow() } })
        ) {
            if let iCloudOffer { ICloudDriveOfferSheet(model: iCloudOffer) }
        }
        // 13r U3-A — WHAT'S NEW: once after a version CHANGE (the ledger's
        // launch decision; the first window to appear claims it), and on
        // demand from Help ▸ What's New. The sheet settles the version the
        // moment it is actually on screen, so a sheet that never appeared
        // (another sheet held the window) is not marked seen.
        .sheet(isPresented: $whatsNewShown) {
            WhatsNewSheet(
                version: WhatsNewLedger.thisAppsVersion,
                notes: ReleaseNotes.source(for: WhatsNewLedger.thisAppsVersion),
                onClose: { whatsNewShown = false })
                .environment(theme)
                .onAppear { whatsNew?.markShown() }
        }
        .onChange(of: router.whatsNewRequested) { _, requested in
            guard requested else { return }
            whatsNewShown = true
            router.whatsNewRequested = false
        }
        // 13s-b U1a, piece 5 — Help ▸ Take the Tour: the same one entry the
        // offer line's "yes" calls.
        .onChange(of: router.tourRequested) { _, requested in
            guard requested else { return }
            router.tourRequested = false
            startTour()
        }
        .onChange(of: router.pendingSelection) { _, pending in
            guard let pending else { return }
            adopt(pending, in: router.workspace.focusedPane)
            router.pendingSelection = nil
        }
        // 13f batch 3 (W3/A27 + W16): ONE place records that a navigation
        // happened — every door in the app already funnels through this
        // selection (shelf, library, pool, ⌘K, a book's open-post
        // broadcast, Compare's new click-through, the Open strip itself),
        // so the history and the Open list are complete by construction
        // rather than by instrumenting each door. P-4 exactly: the doors
        // name a destination, the shell decides what it means.
        .onChange(of: selection) { _, current in
            guard let current else { return }
            router.workspace.visit(current)
        }
        // Sitting 9 (R67): surfaces hand the shell a post to open (the
        // chip's "Open the Copy", and any future minted-post moment).
        .onReceive(NotificationCenter.default.publisher(for: .variorumOpenPost)) { note in
            guard let id = note.userInfo?["postID"] as? String, claimBroadcast() else { return }
            router.pendingSelection = .post(id)
        }
        // 13f W20(a) — THE ASCENT: the membership chip names a book and a
        // post; the SHELL decides that this means "navigate to the book,
        // and hand it the post to land on" (P-4, the W10b precedent).
        .onReceive(
            NotificationCenter.default.publisher(for: .variorumOpenBookAtPost)
        ) { note in
            guard let bookID = note.userInfo?["bookID"] as? String,
                  let postID = note.userInfo?["postID"] as? String,
                  claimBroadcast()
            else { return }
            openBook(bookID, at: postID, in: router.workspace.focusedPane)
        }
        // 13l Act 2 (item 3) — **THE NAVIGATE-AWAY, her ruling's letter:**
        // *"navigate-away covers EVERY pane/window showing the note."* So
        // this listener deliberately does NOT `claimBroadcast()`, which every
        // other app-wide notification here does: those are NAVIGATIONS and
        // exactly one window should perform them, while this is a FACT each
        // window must act on for its own panes. A second window left standing
        // on a tombstone is the failure this exists to prevent.
        .onReceive(NotificationCenter.default.publisher(for: .variorumNotesDeleted)) { note in
            guard let ids = note.userInfo?["postIDs"] as? [String] else { return }
            router.workspace.notesDeleted(ids)
        }
        .onChange(of: router.paletteRequested) { _, requested in
            guard requested else { return }
            paletteOpen = true
            router.paletteRequested = false
        }
        // 13f batch 6 (W5): ⌘K's quick-note row. The pad is a singleton
        // window, so this opens the same one the menu-bar extra, ⌘⇧N and
        // the File-menu item open.
        .onChange(of: router.quickNoteRequested) { _, requested in
            guard requested else { return }
            summonQuickNote()
            router.quickNoteRequested = false
        }
        // Phase 13 C1: the voice's text-surface half — the one global
        // typography keeps surfaces created LATER materializing in the right
        // voice. **18d ladder MINOR-2: the typography adoption MOVED to
        // `ThemeStore.start`, where the settings land** — a view noticing a
        // change is one turn late and never fires at all when the loaded
        // value equals the default, and `SurfaceSizeMemory`'s records carry
        // the type they were measured in. What stays here is the markdown
        // palette, which depends on the color SCHEME too (the hook below) and
        // so is genuinely this view's question.
        .onChange(of: theme.settings) { _, _ in
            adoptMarkdownPalette()
        }
        // 13g batch 2 (L7): the markdown face's palette follows the voice AND
        // the appearance — the second is why it needs its own hook (the
        // settings value does not move when the Mac switches to dark).
        .onChange(of: scheme) { _, _ in adoptMarkdownPalette() }
        // 18d batch 1: the note box's facts — one read per selection (and one
        // more when a note stops being live), never an observation.
        .task(id: noteBoxFactsKey) {
            await noteBoxFacts.load(session: session, postID: noteBoxReport?.state.postID)
        }
        .shellConfirmAlert(router)
        // 19f: Help ▸ Send Feedback…'s pre-draft choice, asked of this window.
        .supportChoiceAlert(router.supportChoice)
        .task { await theme.start() }
        // 13i-d U5: the wing is part of every scoped read's question, so a
        // switch restarts them (snippets — `pool` — are one shared room).
        .task(id: session.wing.currentID) { await library.start() }
        .task { await library.startJournal() }
        .task(id: session.wing.currentID) { await tags.start() }
        .task(id: session.wing.currentID) { await readings.start() }
        .task { await pool.start() }
        .task(id: session.wing.currentID) { await stars.start() }
        .task { await wings.track() }
        .onChange(of: session.wing.currentID) { _, wing in
            shelf = ShelfViewModel(session: session, wingID: wing)
        }
        .onAppear {
            windows.register(windowID, router: router, kind: .full)
            wirePaletteCommands()
            wireWorkspace()
            adoptMarkdownPalette()
#if DEBUG
            publishBlockNamingDoor()
#endif
            // 13e E14 (W26): ask the system for ⌃⌥⌘N. Here because this is
            // the one place holding BOTH the app-lifetime centre and the
            // `openWindow` a summon needs; idempotent, so the second window
            // asks for nothing new. The captured action outlives this window
            // deliberately — she can close every window and the pad still
            // answers her chord (the menu-bar extra's own promise).
            hotKeys.install { _ in summonQuickNote() }
            // 13r U3-A: the version-change show, claimed once per process.
            if whatsNew?.claimAutoShow() == true { whatsNewShown = true }
        }
        .onDisappear {
            windows.unregister(windowID)
#if DEBUG
            // Row 46: this shell's own registration goes with this shell.
            ShellRouter.releaseBlockNamingDoor(owner: windowID)
            // 18k C4: …and so do its pane seams, under the same name.
            SeamGeometry.release(owner: windowID)
#endif
            // 13j J11: closing the window is a leaving for every note its
            // panes were showing.
            SavepointOnLeave.windowClosing(workspace: router.workspace, session: session)
            // 13r U3-A: this window's backup-ask registration goes with it
            // (another window's is never touched).
            calmAsks?.unregister(id: CalmAskScheduler.AskID.backupFolder, host: windowID)
        }
    }

    /// The sidebar column's BOTTOM — the bottom-left family: the
    /// protection row (memo §6: renders only while the choice is genuinely
    /// unmade; NEVER "encryption off") and the sync row (the bridge row
    /// stood third until the bridge's 2026-09-04 retirement). They
    /// were the split view's `safeAreaInset`; the flat column carries them
    /// as its own last region (Sitting 9's opaque voiced background survives
    /// as the column's `room`). nil until the services exist.
    private var statusRows: AnyView? {
        guard let services else { return nil }
        let tokens = theme.tokens(for: scheme)
        return AnyView(
            VStack(alignment: .leading, spacing: 0) {
                if let protection {
                    ProtectionStatusRow(controller: protection, tokens: tokens)
                }
                SyncStatusRow(services: services)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tokens.room))
    }

    /// 13g batch 2 (L7): keep the markdown face's two colors on the current
    /// voice + appearance. The full-document editor's chrome application sets
    /// the same value; both writers resolve from the same tokens, so a surface
    /// created before either one still materializes in the right register.
    private func adoptMarkdownPalette() {
        MarkdownStyling.palette = MarkdownStyling.Palette(tokens: theme.tokens(for: scheme))
    }

    /// Whether THIS window mounts the live surface (13f batch 5b): the pane
    /// rule, gated on the window being key. Sticky key-ness, so an app
    /// switch changes nothing (`WindowRegistry`).
    private var windowIsKey: Bool { windows.isKey(windowID) }

    /// **Who acts on an app-wide navigation broadcast.** Those notifications
    /// (`.variorumOpenPost`, `.variorumOpenBookAtPost`) reach every window
    /// that listens, so with a
    /// second window on screen ONE click would navigate both — P-4's own
    /// class, arriving the moment windows do. The registry names a single
    /// target: the key window when it can navigate, otherwise the most
    /// recently key FULL window (a note-only window navigates nowhere, so
    /// making the rule "is key" would have turned a book link clicked there
    /// into a dead door — exactly what W20 exists to kill).
    ///
    /// A window that acts while it is NOT the one she is looking at raises
    /// itself, so the thing she asked for arrives in front of her.
    private func claimBroadcast() -> Bool {
        guard windows.isNavigationTarget(windowID) else { return false }
        if !windowIsKey { windows.bringForward(windowID) }
        return true
    }

    /// 13f batch 3: the navigation core's two wirings, both idempotent.
    ///
    /// (1) The registry context reads THIS window's workspace — the
    /// workspace is per-window state and the command router is the app's,
    /// so a closure is what keeps the two straight (the `undoAvailable`
    /// idiom); batch 4's focused-window refinement lands here and nowhere
    /// else. (2) The pane's history is SEEDED with what it is already
    /// showing, because `onChange` never fires for an initial value — and
    /// without the seed the first click out of the shelf would push
    /// nothing, so the very first back chip she could want would be the
    /// one that never appeared.
    private func wireWorkspace() {
        // 13f batch 5b: the closures read the KEY WINDOW's workspace through
        // the registry, not this window's. That is the whole per-window fix
        // at the menu's end: the `CommandRouter` is the APP's, so with two
        // windows open the last one to appear used to win every gate — Back,
        // Forward and ⌘⇧n would answer for a window she was not in. Reading
        // the registry makes this wiring IDEMPOTENT across windows: whoever
        // runs it last installs the same closures.
        let windows = self.windows
        session.commandRouter.openNoteCount = {
            windows.activeRouter?.workspace.openNotes.ids.count ?? 0
        }
        session.commandRouter.canNavigateBack = {
            windows.activeRouter?.workspace.history().canGoBack ?? false
        }
        session.commandRouter.canNavigateForward = {
            windows.activeRouter?.workspace.history().canGoForward ?? false
        }
        // 13f batch 4: the split's two facts, and the router's own voice.
        // `history()` now defaults to the FOCUSED pane, so the two
        // navigation closures above became focus-aware without changing —
        // the gate's refinement, landed at the model.
        session.commandRouter.paneCount = { windows.activeRouter?.workspace.panes.count ?? 1 }
        session.commandRouter.canOpenBeside = {
            windows.activeRouter?.workspace.openBesideCandidate != nil
        }
        // 13f batch 6 (W4): ⌘K's Toggle Star gate — is the key window's
        // focused pane showing a thing a star can point at?
        session.commandRouter.canStarCurrent = {
            StarTargeting.target(for: windows.activeRouter?.workspace.focusedSelection) != nil
        }
        // 18o U1 (17e (12)): the key window's kind — the sidebar toggle's
        // gate, now a registry fact the View-menu item reads back.
        session.commandRouter.windowKind = { windows.activeWindowKind }
        // 13f batch 5 (W22's button): the first-edit note names its target
        // book by the chooser's own order, and that order floats what she
        // has visited — which lives per window, so it reads the key one too.
        session.recentBookIDs = { windows.activeRouter?.workspace.recentBookIDs ?? [] }
        let status = session.status
        router.refuse = { status.refuse($0) }
        // 13j J11: THIS window's workspace raises its departures to the
        // session's one savepoint entry. Per-window (unlike the gates above,
        // which read the key window through the registry) because leaving is
        // a fact about the panes that just changed, not about focus.
        SavepointOnLeave.wire(workspace: router.workspace, session: session)
        // 17y B3 item (f): THIS window's focused subject — an open, or a focus
        // move between its panes — carries the app's one wing with it (her
        // ruled cross-wing follow; the receipt "Now in X").
        WingFollow.wire(workspace: router.workspace, session: session)
        router.workspace.visit(selection ?? .shelf)
    }

    // MARK: - Selection, per pane (13f batch 4 — the gate's (a))

    /// What the FOCUSED pane shows. The sidebar binds to this, so a sidebar
    /// click targets the focused pane by construction and batch 3's ONE
    /// recording point below stays complete without knowing panes exist.
    private var selection: SidebarSelection? { router.workspace.focusedSelection }

    private var selectionBinding: Binding<SidebarSelection?> {
        Binding(
            get: { router.workspace.selections[router.workspace.focusedPane] },
            set: { picked in
                guard let picked else { return }
                adopt(picked, in: router.workspace.focusedPane)
            })
    }

    /// The ONE door a destination enters a pane through — so her round-7.3
    /// rule (a split never shows one note twice) cannot be bypassed by
    /// adding a door, and is spoken in one voice wherever it fires.
    private func adopt(
        _ destination: SidebarSelection, in pane: PaneID, landing blockID: String? = nil,
        find: EditorFindSeed? = nil
    ) {
        // 17o c/d/e round 1 (MAJOR-2) + round 2 (MINOR-1): **a navigation
        // expires a parked block landing and installs the one it names — in
        // ONE statement.** Every ordinary door lands here — `openHere`, the
        // sidebar's own binding, ⌘K's rows, the back/forward chips, the
        // open-post broadcast — and none of them names a block, so the park
        // must not outlive them.
        //
        // 13u2 UNIT E (row 47's PARK half): those two statements now live on
        // the ROUTER as `ShellRouter.adopt`, so `park` is private to them and
        // no door can park without navigating. The shell keeps the outcome,
        // because saying the same-note refusal out loud is the shell's job,
        // not the router's (P-4).
        switch router.adopt(destination, in: pane, landing: blockID, find: find) {
        case .adopted:
            break
        case .focusedExistingPane:
            session.status.refuse(
                WorkspaceNaming.sameNoteNote(router.workspace.label(for: destination)))
        }
    }

    /// A navigation door belonging to a particular pane: it focuses that
    /// pane and navigates it in one click, which is how a row click inside
    /// an UNFOCUSED list pane does the obvious thing.
    private func opener(_ pane: PaneID) -> (SidebarSelection) -> Void {
        // MAJOR-2's ruled line: a list-row door names NO block, and says so
        // through the one road that knows how to write that (`open`'s nil).
        { destination in open(destination, blockID: nil, in: pane) }
    }

    // MARK: - The pane row (W1/A25)

    /// 13g batch 6 (R5-5 — THE CRASH): the row NEVER frames itself to the
    /// size the `GeometryReader` reports.
    ///
    /// The trace, in one sentence: `.inspector` is HOISTED to the enclosing
    /// `NavigationSplitView`, so opening the masthead's Scraps/References
    /// panel narrows the DETAIL COLUMN — the very size this reader reports —
    /// and a child hard-framed to `geo.size` is then a stale, oversized child
    /// fighting the animating split, which makes SwiftUI dirty its graph on
    /// every pass and ask AppKit for another Update-Constraints-in-Window
    /// pass until AppKit's own feedback guard throws
    /// (*"marked as needing another Update Constraints in Window pass, but it
    /// has already had more … passes than there are views in the window"*)
    /// and `_crashOnException` kills the app. Reading `geo` is fine; feeding
    /// it back as a hard frame is the loop. `.infinity` accepts whatever is
    /// proposed THIS pass, so the row settles in one.
    // MARK: - The sidebar's note box (18d batch 1 — her U-10)

    /// A book's publication, adopted for THIS window.
    ///
    /// A CLEAR is stamped with its publisher, and applies only when the box
    /// standing is that publisher's: SwiftUI mounts an arriving `.id` before
    /// it unmounts the departing one, so an unstamped clear would erase the
    /// box the next book just filled. A REPORT always wins — the focused
    /// pane's book is the only one that publishes a non-nil one (its own
    /// `paneFocused` gate), and `noteBoxView` re-checks against the focused
    /// pane's selection anyway, so nothing stale can reach the column.
    private func adoptNoteBox(
        _ bookID: String, _ report: NoteBoxReport?, _ door: NoteBoxDoor?
    ) {
        if report == nil, noteBoxReport != nil, noteBoxReport?.readingID != bookID {
            return
        }
        noteBoxReport = report
        noteBoxDoor = door
    }

    /// The box's content, or nil when no book in an editing mode is showing —
    /// in which case the sidebar's column is exactly what it was.
    private var noteBoxView: AnyView? {
        // THE GATE: the box belongs to the book the FOCUSED pane is showing,
        // and to no other. Derived rather than remembered, so a report left
        // behind by a book that is no longer on screen — a pane switched to
        // the Library, a second window taking key — can never leak into the
        // one column this window has.
        guard case .reading(let showing)? =
                router.workspace.selections[router.workspace.focusedPane],
              let report = noteBoxReport, report.readingID == showing
        else { return nil }
        let tokens = theme.tokens(for: scheme)
        // THE EDITOR UNDER THE CARET (`EditorRouter.editing` — its own
        // comment carries the measured reason it is not `active`). Gated on
        // the note the BOOK reported besides: an editor left standing on
        // another surface must never lend its doors to this box.
        let live = session.editorRouter.editing
        let barModel = report.state.isLive && live?.postID == report.state.postID
            ? live : nil
        return AnyView(SidebarNoteBox(
            tokens: tokens,
            subjectKey: report.readingID,
            state: report.state,
            identity: report.identity,
            facts: noteBoxFacts.facts(for: report.state.postID),
            // One label, from the bar's own brain (13g R5-4), so the box's
            // identity line and the bar can never disagree about where the
            // caret is.
            //
            // **A CLOSURE over the LOCAL model, never a value and never
            // `self`** (the round-end Fable pass, MAJOR-1). This body runs
            // inside `ShellSplit`'s sidebar closure, and `caretOrdinal` /
            // `blockCount` are rewritten on every keystroke — reading them
            // HERE registered the shell against the caret, so every
            // keystroke in a book note re-ran the sidebar column and the
            // whole pane row (`BookView.init` minting two view models per
            // pass). The box evaluates the closure inside its own body, so
            // the observation lands on the smallest view in the tree. The
            // capture is the local `model` and it is STRONG: a weak capture
            // would let the where-line silently lose its "block 3/41" in a
            // teardown race, and the closure lives one render of the box.
            caretLabel: barModel.map { model in
                { () -> String? in
                    BlockLineLabel.caret(ordinal: model.caretOrdinal, of: model.blockCount)
                }
            },
            onEditHere: noteBoxDoor?.editHere,
            // 13i-c U4 (§20): the box's book-context remove/release door.
            removeDoor: noteBoxDoor?.removeFromBook.map { (verb: $0.verb, act: $0.act) },
            bar: barModel.map { AnyView(CommitBar(model: $0, axis: .box)) }))
    }

    /// The facts read's key: the note, and whether it is live. Leaving the
    /// live state re-reads, which is what makes the counts honest again after
    /// a writing burst (the model's header says why they are not observed).
    private var noteBoxFactsKey: String {
        guard let state = noteBoxReport?.state, let postID = state.postID else { return "" }
        return "\(postID)|\(state.isLive)"
    }

    private var paneRow: some View {
        let panes = router.workspace.panes
        let tokens = theme.tokens(for: scheme)
        return GeometryReader { geo in
            HStack(spacing: 0) {
                let widths = PaneLayout.widths(
                    total: max(geo.size.width - Self.dividerWidth * CGFloat(panes.count - 1), 0),
                    fractions: router.workspace.splitFractions)
                ForEach(Array(panes.enumerated()), id: \.element) { index, pane in
                    if index > 0 {
                        // Row 9's part the HOST owns (18d ladder round 2,
                        // MINOR-1): `paneHost` is the divider's later HStack
                        // sibling and so hit-tests above it, which is why
                        // the grip's right half was dead over a live
                        // editor's I-beam — her sentence verbatim.
                        paneDivider(index: index - 1, rowWidth: geo.size.width, tokens: tokens)
                            .zIndex(1)
                    }
                    paneHost(pane, split: panes.count > 1, tokens: tokens)
                        .frame(width: panes.count > 1 ? widths[index] : nil)
                        .frame(maxWidth: panes.count > 1 ? nil : .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .coordinateSpace(name: Self.paneRowSpace)
    }

    private static let dividerWidth: CGFloat = 1
    private static let paneRowSpace = "variorum-pane-row"

    /// The draggable seam — **the shared one** (`SeamGrip`, `Core/Views`).
    /// Its arithmetic is `PaneLayout`'s (clamped so a drag can never swallow
    /// a pane); the seam's shape is row 9's, which the shell got at 17o
    /// batch d and `SideColumn`'s three boundaries at 18d's ladder.
    ///
    /// **The FOURTH seam, converted at round 2's MINOR-1.** It carried the
    /// old shape (a 9-pt `.overlay` with `NSCursor.push()` on `.onHover` and
    /// no `zIndex`) — as did a FIFTH, the Blocks workbench's `WorkbenchSeam`,
    /// which the round-end Fable pass converted after this comment had
    /// called this one "the last copy" (a completeness claim must be made by
    /// searching for the DEFECT's shape, never by inheriting a count). Here
    /// the defect sat in the row where `paneHost` is drawn
    /// after it and takes the grip's right half — over a live editor, so the
    /// pointer she got there was the I-beam. **Layout-neutral:**
    /// `SeamGrip`'s own frame is `SeamGrip.lineWidth`, the same 1 pt this
    /// row's width math already subtracts (`Self.dividerWidth`, above).
    /// Batch 3's record left this with two candidate owners and no row; the
    /// ladder's rule is that a known defect with no owner gets fixed now.
    private func paneDivider(index: Int, rowWidth: CGFloat, tokens: VoiceTokens) -> some View {
        SeamGrip(
            tokens: tokens,
            space: Self.paneRowSpace,
            onDrag: { location in
                guard rowWidth > 0 else { return }
                router.workspace.setSplitFraction(at: index, to: location.x / rowWidth)
            },
            help: "Drag to resize the panes",
            frameSpace: .named(Self.paneRowSpace),
            onLineFrame: { frame in
                #if DEBUG
                // 18k C4: registered under THIS window's id (the subject
                // already names this window's router; the owner makes the
                // teardown take only this shell's seams).
                SeamGeometry.recordLine(
                    SeamGeometry.key(
                        Self.paneSeamFamily,
                        subject: Self.paneSeamSubject(router: router, index: index)),
                    frame, owner: windowID)
                #endif
            },
            onGripFrame: { frame in
                #if DEBUG
                SeamGeometry.recordGrip(
                    SeamGeometry.key(
                        Self.paneSeamFamily,
                        subject: Self.paneSeamSubject(router: router, index: index)),
                    frame, owner: windowID)
                #endif
            })
    }

    // MARK: - The tour (13s-b U1a — R-13s-2/6/13; U2 builds the engine)

    /// The offer line for the Bookcase's slot: a row exactly when the model
    /// keeps one this process (`TourOfferModel.holdsRow` — an offer to make,
    /// or one that retired since launch and keeps its height so nothing moves).
    private var tourOfferLine: AnyView? {
        guard let tourOffer, tourOffer.holdsRow else { return nil }
        return AnyView(TourOfferLine(model: tourOffer, onTakeTour: startTour))
    }

    /// **THE TOUR'S ONE ENTRY** — the offer line's "yes" and Help ▸ Take the
    /// Tour (U1a piece 5, through `router.tourRequested`). 13s-b U2 fills it:
    /// a start is ALWAYS step 1 (Q12 — a tour already running starts over; no
    /// resume), on the Bookcase, and the tour's layer releases the window's
    /// first responder the moment it arrives in the window (`TourOverlay` —
    /// the U1a walk's W-U1a-1: "yes" left the caret in the quick entry, where
    /// a keystroke would mint a note). The line steps aside now; the engine
    /// retires it at the end
    /// (`TourOfferModel.tourEnded(completed:)` — completed at the end card,
    /// ended by End tour before it, nothing at all if the app quits mid-way).
    private func startTour() {
        tourOffer?.tourStarted()
        let session = session
        let place = TourPlaces.place(router.workspace.focusedSelection)
        let doors = tourDoors
        let slot = tourSlot
        Task {
            let landmarks = await TourEngine.landmarks(session: session)
            slot.engine = TourEngine(
                session: session, landmarks: landmarks, facts: Tour.Facts(place: place),
                doors: doors)
        }
    }

    /// What the tour's effects DO in this window — the shell's own roads.
    /// They hold the window's long-lived objects and the slot WEAKLY, never
    /// this view (a captured `RootView` would hold the slot that holds the
    /// engine that holds these closures).
    private var tourDoors: TourEngine.Doors {
        let router = router
        let session = session
        let offer = tourOffer
        let slot = tourSlot
        let pool = poolPosts
        return TourEngine.Doors(
            navigate: { place in
                guard let destination = TourPlaces.selection(place),
                      router.workspace.focusedSelection != destination
                else { return }
                // The ONE adoption door's own road (`adopt` above) — a tour
                // destination never names a block, and the same-note refusal
                // speaks exactly as it does for every other door.
                if case .focusedExistingPane = router.adopt(
                    destination, in: router.workspace.focusedPane) {
                    session.status.refuse(
                        WorkspaceNaming.sameNoteNote(router.workspace.label(for: destination)))
                }
            },
            openFieldGuide: {
                ShellActions(session: session, shell: router).openTutorial()
            },
            recordCompleted: { offer?.tourEnded(completed: true) },
            finished: { [weak slot] completed in
                offer?.tourEnded(completed: completed)
                slot?.engine = nil
            },
            // F-U2-W-2 (option A, ruled): leg 3 opens the Pool's "in
            // gatherings" run — the masthead's own "show", on this window's
            // Pool model — so her starred (and so tucked) note is on screen.
            showPoolTucked: { Task { await pool.showTucked() } })
    }

    /// The window's facts, as readers the tour's overlay evaluates in ITS
    /// body (so the caret's observation never lands on this shell's — the
    /// note box's MAJOR-1 lesson). The caret reading is composed HERE: the
    /// editor's model is a sibling feature's, and only the composition root
    /// reads it, handing the tour plain values.
    private var tourSources: TourFactSources {
        let router = router
        let session = session
        let stars = stars
        let bookNoteLive = tourBookNoteLive
        return TourFactSources(
            selection: { router.workspace.focusedSelection },
            noteDetail: {
                (session.commandRouter.activePostID, session.commandRouter.activeMode)
            },
            caret: {
                guard let editor = session.editorRouter.editing else { return nil }
                return TourCaretReading(
                    postID: editor.postID,
                    blockID: editor.caretBlockID,
                    ordinal: editor.caretOrdinal,
                    takeCounts: Dictionary(
                        editor.badges.map { ($0.blockID, $0.variantCount) },
                        uniquingKeysWith: { max($0, $1) }),
                    panelBlockID: editor.fanPanel?.blockID)
            },
            bookNoteLive: { bookNoteLive },
            isStarred: { stars.isStarred(.post($0)) })
    }

    /// Whether the focused pane's BOOK has its note box live — the "edit
    /// here" door took (the same gate `noteBoxView` draws the box by).
    private var tourBookNoteLive: Bool {
        guard case .reading(let showing)? =
                router.workspace.selections[router.workspace.focusedPane],
              let report = noteBoxReport, report.readingID == showing
        else { return false }
        return report.state.isLive
    }

    /// The pane seam's family in the shared oracle.
    static let paneSeamFamily = "paneDivider"

    /// The pane seam's SUBJECT — THIS window's router and the seam's index in
    /// its row (the round-end Fable pass, MINOR-2 (b)). The index alone was
    /// `paneDivider|0` for every split in every suite and every window, so a
    /// pin polling for its own seam could exit on another suite's mounted
    /// shell and then compare two windows' rectangles. The router is
    /// per-window `@State` (13f batch 5b), so its identity is the window's;
    /// the view and the pin both call this one rule.
    static func paneSeamSubject(router: ShellRouter, index: Int) -> String {
        "\(ObjectIdentifier(router))|\(index)"
    }

    private func paneHost(_ pane: PaneID, split: Bool, tokens: VoiceTokens) -> some View {
        // THE MOUNT RULE, consulted as the one fork (13f batch 4, gate (b);
        // 13f batch 5b's key-window gate on the same fork): exactly one
        // pane, in exactly one WINDOW, mounts a live surface — an authority
        // owner, a routed-command handler, a live editor. Everything else
        // renders read-cheap, which is why the app-scoped singletons that
        // assume one detail keep being correct with two windows open.
        let live = PaneMount.kind(
            of: pane, focused: router.workspace.focusedPane, windowIsKey: windowIsKey) == .live
        return PaneHost(
            tokens: tokens, session: session, workspace: router.workspace, pane: pane,
            focused: live, split: split,
            onBack: {
                router.workspace.focus(pane)
                router.goBack(in: pane)
            },
            // 13k K11: the → is ⌥⌘]'s face, on the pane it sits above —
            // focus first, exactly as the ← does, so the key and the icon
            // can never act on different panes.
            onForward: {
                router.workspace.focus(pane)
                router.goForward(in: pane)
            },
            onFocus: { router.workspace.focus(pane) },
            // 13f W20(a): the bar's in-line ascends exactly like the chip's
            // link does — one shell decision, two doors.
            onOpenBook: { bookID, postID in openBook(bookID, at: postID, in: pane) }
        ) {
            paneDetail(router.workspace.selections[pane], pane: pane, live: live)
        }
    }

    /// What ONE pane shows. `live` is `PaneMount`'s verdict: the focused
    /// pane mounts the full surface, the others render read-cheap — a NOTE
    /// as `ReadPostView` (whose standing click-to-focus door migrates the
    /// ring, exactly the Book spread's sibling page), a BOOK through its
    /// own focus authority, and every list surface unchanged, because a
    /// list owns no authority and registers no handler.
    @ViewBuilder
    private func paneDetail(
        _ selection: SidebarSelection?, pane: PaneID, live: Bool
    ) -> some View {
        let openHere = opener(pane)
        switch selection {
        case .shelf, nil:
            ShelfView(
                session: session, model: shelf, readings: readings,
                onOpen: openHere,
                onTodaysEntry: { openToday(in: pane) },
                starDoor: starDoor, wings: wings,
                // 13s-b U1a: the tour offer's row — built HERE (composition)
                // and rendered by the Bookcase alone ("Bookcase only").
                offerLine: tourOfferLine)
                // 13i-d U5: a new wing is a new board (its tasks restart).
                .id("bookcase-\(shelf.wingID)")
        case .library:
            LibraryCatalogView(
                session: session, model: catalog, library: library, tags: tags,
                onOpen: openHere,
                // 13o U2 (D6): a search passage lands at its block with its
                // find seed — the same caret-precise road, one more value.
                onOpenBlock: { picked, blockID, find in
                    open(picked, blockID: blockID, find: find, in: pane)
                },
                onOpenBeside: { router.openBeside(.post($0)) },
                onOpenInNewWindow: openInNewWindow,
                // The correction round, batch E (row 33): the panel's book
                // outline opens the book AT a note — the ascent's landing.
                onOpenBook: { bookID, postID in openBook(bookID, at: postID, in: pane) },
                starDoor: starDoor, wings: wings)
        case .poolPosts:
            PoolPostsView(
                session: session, model: poolPosts,
                // P39a: the PARENT owns the sibling and passes its acts down
                // (CLAUDE.md's cross-feature rule — "parents construct;
                // features receive view models, values, and closures").
                onDuplicateAsVersion: { await library.duplicateAsVersion(postID: $0) },
                onArchive: { await library.archive(postID: $0) },
                readings: readings, tags: tags,
                onOpen: openHere,
                onOpenBeside: { router.openBeside(.post($0)) },
                onOpenInNewWindow: openInNewWindow,
                starDoor: starDoor, wings: wings)
        case .blocks:
            // Batch 12: the Blocks AREA — standalone blocks live and are
            // born here (the sidebar rows retired).
            // 17o batch e (row 38): the door carries its own target — a
            // CARD names its group AND the snippet clicked, so the caret
            // lands in it (the Stage C landing road, which the
            // Library's block hits have always used); the header's scope
            // door names the group alone and CLEARS a stale landing, which
            // `openHere` never did.
            BlocksAreaView(session: session, model: pool) { target in
                open(.pool(target.poolID), blockID: target.blockID, in: pane)
            }
        case .post(let postID):
            if live {
                // Phase 11 (A3): the mode switcher — Write / Takes / Compare
                // over one post, one store.
                PostDetailView(
                    session: session, postID: postID,
                    initialBlockID: target(for: postID),
                    initialFind: router.landingFind(for: postID),
                    recentBookIDs: router.workspace.recentBookIDs)
                    // **The park is spent when it lands.** A re-mount is not
                    // a navigation — the shell re-creates this view whenever
                    // the pane stops being live (a split's other pane taking
                    // focus, a second window becoming key) — so an unspent
                    // park re-threw her to the named block instead of the
                    // caret she left (round 2's MAJOR).
                    //
                    // `.id` comes LAST in this chain (a few lines down), so it
                    // identifies the `.onAppear` written here and a new
                    // identity re-fires the spend. Moving `.onAppear` AFTER
                    // the `.id` in the source makes it outlive the identity
                    // and it never fires again — measured: the first cut sat
                    // there and the park was never spent (the 17o c/d/e
                    // ladder's round-3 NIT-1 reworded this in one vocabulary).
                    .onAppear { router.spendLanding(for: postID) }
                    // A different post — or a NEW landing for this one — is a
                    // different editor. The key is the landing GENERATION, not
                    // the parked block: the mount above SPENDS the park, and
                    // an identity keyed on the block would then change under a
                    // view that has already landed and throw the caret away.
                    .id("\(postID)#\(router.landingGeneration(for: postID))")
            } else {
                readCheapNote(postID, pane: pane)
            }
        case .tag(let tagID):
            FolderView(session: session, tagID: tagID) { postID in
                openHere(.post(postID))
            }
            .id(tagID)
        case .reading(let readingID):
            // The book blurs through its OWN single focus authority
            // (`BookViewModel.focusedPostID`, 13b 3E's fold) when its pane
            // is not focused — a second reason for one mechanism to answer
            // nil, never a second mechanism.
            BookView(
                session: session, readingID: readingID, paneFocused: live,
                onPaneFocusRequest: { router.workspace.focus(pane) },
                // 13f W20(a): the ascent's landing, handed to the book it
                // named and to no other.
                revealPostID: bookAscent?.bookID == readingID ? bookAscent?.postID : nil,
                onRevealConsumed: { bookAscent = nil },
                // 18d batch 1: the book publishes what its sidebar box shows.
                onNoteBox: { bookID, report, door in
                    adoptNoteBox(bookID, report, door)
                },
                // 13o U3 (the architect's F1): a book's search passage lands
                // exactly as the Library's — Write at its block, find seeded.
                onOpenSearchHit: { postID, blockID, find in
                    open(.post(postID), blockID: blockID, find: find, in: pane)
                })
                .id(readingID)
        case .pool(let poolID):
            if live {
                // A scraps container ("Blocks") opens in the ordinary detail
                // editor (the ratified Phase 10 shape); the canvas is its
                // second face (Phase 11, A7).
                PoolDetailView(
                    session: session, poolID: poolID,
                    initialBlockID: target(for: poolID),
                    initialFind: router.landingFind(for: poolID))
                    .onAppear { router.spendLanding(for: poolID) }
                    .id("\(poolID)#\(router.landingGeneration(for: poolID))")
            } else {
                readCheapNote(poolID, pane: pane)
            }
        case .recovery:
            RecoveryView(
                session: session, library: library,
                openPost: { postID in openHere(.post(postID)) },
                // 13l (§8b): a scrap's row opens the SCRAPS area, not a note
                // pane over a pool container.
                openPool: { poolID in openHere(.pool(poolID)) })
        // The post-13l polish round, ledger row 8 (B2): archived notes, in
        // their own room, apart from the Trash's clock.
        case .archived:
            ArchivedView(
                session: session, library: library,
                openPost: { postID in openHere(.post(postID)) },
                // 13i-e U2 (R-13ie-1): an archived book opens in the book view.
                openBook: { readingID in openHere(.reading(readingID)) },
                // 17y B3 item (l): the BOOKS group's row menu carries the star.
                starDoor: starDoor)
        }
    }

    /// An unfocused note pane: the read tier, in its own scroll (the read
    /// view is content-sized and never brings one — the `SpreadPage`
    /// precedent), with its click-to-focus door pointed at this pane.
    ///
    /// 13g batch 6 (R5-1 — her L5 word, TAKES-FIRST): a pane she left in
    /// TAKES keeps showing takes while it waits its turn, as a read-only
    /// projection that owns no authority and registers no handler
    /// (`ReadTakesView`). Lenses, Compare, Canvas and Blocks deliberately do
    /// NOT get one — her words: *"i honestly don't think that lenses or
    /// compare need to be a side by side mode option for now or potentially
    /// ever"* — so they keep the mode LABEL and plain read text, which is
    /// batch 1's (a). The mode read is `PostDetailView.rememberedMode`, the
    /// same one source the pane's name line reads and the detail restores
    /// from, so the three can never disagree.
    @ViewBuilder
    private func readCheapNote(_ containerID: String, pane: PaneID) -> some View {
        if ReadTakesView.holdsTakes(postID: containerID) {
            ReadTakesView(session: session, postID: containerID)
                .id("pane-takes-\(containerID)")
        } else {
            readCheapProse(containerID, pane: pane)
        }
    }

    private func readCheapProse(_ containerID: String, pane: PaneID) -> some View {
        ScrollView {
            ReadPostView(
                session: session, postID: containerID,
                // 13u3 UNIT A1: the pane's own 20 pt padding becomes the
                // surface's GUTTER — the prose lands on the same point and
                // keeps the same measure (this pane has never capped it),
                // and a comment's face finally has somewhere to stand that
                // is not on the words.
                gutter: .pane,
                onFocusRequest: { _ in router.workspace.focus(pane) },
                onBadgeTap: { _ in router.workspace.focus(pane) })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
        }
        .id("pane-read-\(containerID)")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.tokens(for: scheme).surface)
    }

    /// 13f W20(a) — the ascent, decided in ONE place. Both doors (the
    /// masthead chip's link and the context bar's in-line) name a book and a
    /// post; this parks the landing and navigates through the ONE adoption
    /// door, so the pane's history is pushed and ⌥⌘[ returns to the note.
    private func openBook(_ bookID: String, at postID: String, in pane: PaneID) {
        bookAscent = BookAscent(bookID: bookID, postID: postID)
        adopt(.reading(bookID), in: pane)
    }

    /// **⌘K's road to the rest** (13o U2, D7 — R-13o-9): the Library's field
    /// takes the palette's words and its answer sheet asks them; the focused
    /// pane goes to the Library.
    private func searchLibrary(_ words: String) {
        catalog.query = words
        Task { await catalog.search() }
        adopt(.library, in: router.workspace.focusedPane)
    }

    /// Navigation with an optional caret-precise block landing (Stage C) —
    /// and, for a search passage, its find seed (13o U2, D6).
    private func open(
        _ picked: SidebarSelection, blockID: String?, find: EditorFindSeed? = nil,
        in pane: PaneID? = nil
    ) {
        adopt(picked, in: pane ?? router.workspace.focusedPane, landing: blockID, find: find)
    }

#if DEBUG
    /// Publishes THIS shell's block-naming door for round 2's MINOR-1 pin —
    /// see `ShellRouter.blockNamingDoor`.
    ///
    /// **13u4 UNIT S3 (row 46): it publishes under THIS shell's own
    /// `windowID` and releases it when this shell leaves**, so a torn-down
    /// mount can neither leave its closure standing over a live one nor
    /// take a live one down on its way out. Before, every mount overwrote
    /// one bare static and one of eight test mount sites cleared it. The
    /// token is the window's own identity — the one the registry already
    /// keys on — rather than a second `@State` UUID beside it.
    private func publishBlockNamingDoor() {
        ShellRouter.publishBlockNamingDoor(owner: windowID) { destination, blockID in
            open(destination, blockID: blockID)
        }
    }
#endif

    private func target(for containerID: String) -> String? {
        router.landing(for: containerID)
    }

    /// The dated home's door (R38: the journal lives on the shelf;
    /// `JournalBooks.openToday` carries the ensure-membership half).
    private func openToday(in pane: PaneID? = nil) {
        Task {
            if let id = await library.openJournalEntry() {
                adopt(.post(id), in: pane ?? router.workspace.focusedPane)
            }
        }
    }

    /// The ⌘K vocabulary (R15, completed 13b 1b): navigation rows here in
    /// composition, ACT rows from the capability registry (the same routed
    /// bodies as the menu doors — the palette's claimed takes/structural/
    /// export commands are finally real; an act that can't work here
    /// speaks its honest note).
    private func wirePaletteCommands() {
        let actions = ShellActions(session: session, shell: router)
        var rows: [(title: String, action: @MainActor () -> Void)] = [
            // 13i-d U1: the section is the BOOKCASE (§7).
            ("Go to Bookcase", { [self] in adopt(.shelf, in: router.workspace.focusedPane) }),
            ("Go to Library", { [self] in adopt(.library, in: router.workspace.focusedPane) }),
            ("Go to Pool", { [self] in adopt(.poolPosts, in: router.workspace.focusedPane) }),
            // The post-13l polish round, ledger rows 7–8: the two halves of
            // the old "Archived & Deleted" surface, now two destinations
            // with two names. Both are NAVIGATION rows, which is why they
            // live in composition rather than the registry (this method's
            // own rule, one comment up).
            (RecoveryPath.menuLabel,
                { [self] in adopt(.recovery, in: router.workspace.focusedPane) }),
            (RecoveryPath.archivedSurface,
                { [self] in adopt(.archived, in: router.workspace.focusedPane) }),
            // 13b Stage 2: the old modes-tutorial entrance points at the
            // one tutorial BOOK (find-or-seed, then open — fire-and-DO).
            ("Open the Tutorial — \(TutorialSeeder.bookName)", { actions.openTutorial() }),
            ("Settings — Appearance & Tags", { [self] in openSettings() }),
            ("Use Terminal Voice", { [self] in theme.setVoice(.terminal) }),
            ("Use Study Voice", { [self] in theme.setVoice(.study) }),
        ]
        rows.append(contentsOf: actions.paletteEntries())
        palette.commands = rows
    }

}


// MARK: - The shell's confirm (13u4 UNIT S3 — KnownIssues row 67)

// **THE SHELL'S CONFIRM** (13u4 UNIT S3 — KnownIssues row 67): the
// tutorial's replace confirm retires its app-modal
// `NSAlert.runModal()` here. An act holds no view, so it ASKS
// (`ShellRouter.ask`) and the window presents — in the same `.alert`
// grammar every sibling confirm in the app already uses. Dismissal is
// an ANSWER (`false`), never a silence: nothing may be left awaiting a
// question that is no longer on screen.
//
// **What is NOT retired, named so this is not read as the class
// closed:** `ShellActions.confirmDiscardingUndo` (A12's
// destructive-undo warning) and `CalloutMenu.promptEmoji` are still
// `NSAlert`s. Row 67 names the tutorial's confirm; the other two are
// in this unit's conformance remainder list, and the UNDO one can now
// adopt this channel in about five lines.

private extension View {
    /// **13s-b U2 — the tour's layer**: its cards over the whole window and
    /// its spotlight in every door's environment. Its own function for the
    /// confirm's reason below (the body's expression is at the type
    /// checker's budget). With no tour, the spotlight is nil — every
    /// `.tourAnchor` in the app is inert — and there is no overlay at all.
    func tourLayer(_ tour: TourEngine?, sources: TourFactSources) -> some View {
        overlay {
            if let tour {
                TourOverlay(engine: tour, sources: sources)
                    // A restarted tour is a NEW overlay: its first facts are
                    // delivered on appear (`onChange(initial:)`), never left
                    // waiting for the window to change.
                    .id(ObjectIdentifier(tour))
            }
        }
        .environment(tour?.spotlight)
    }

    /// Hosts whatever the shell is asking. Its own function for a mundane
    /// reason worth recording: inlined in `RootView.body` the presenting
    /// `.alert` pushed that already-enormous expression past the type
    /// checker's budget (`unable to type-check this expression in reasonable
    /// time`) — the one thing a big SwiftUI body reliably punishes.
    func shellConfirmAlert(_ router: ShellRouter) -> some View {
        alert(
            router.pendingConfirm?.question ?? "",
            isPresented: Binding(
                get: { router.pendingConfirm != nil },
                set: { shown in if !shown { router.answerPendingConfirm(false) } }),
            presenting: router.pendingConfirm
        ) { pending in
            Button(pending.verb, role: pending.destructive ? .destructive : nil) {
                router.answerPendingConfirm(true)
            }
            Button("Cancel", role: .cancel) { router.answerPendingConfirm(false) }
        } message: { pending in
            Text(pending.detail)
        }
    }
}
