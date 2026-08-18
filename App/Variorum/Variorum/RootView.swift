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
    @State private var paletteOpen = false
    /// Sitting 9 (R94): the bridge row's auth-shaped failures open the
    /// account sheet from right there.
    @State private var accountSheetShown = false
    /// Stage C: a palette/Library block hit lands CARET-PRECISE — the
    /// target block rides beside the selection and seeds the opened
    /// editor's caret (cleared on ordinary navigation).
    @State private var blockTarget: BlockTarget?
    /// 13f W10b: the released original the lineage door asked to see; the
    /// recovery surface reveals it and consumes the request.
    /// 13f W20(a) — THE ASCENT: the post a book was asked to open AT. One
    /// shot, keyed by book so a stale request can never land in another
    /// book (the `blockTarget` guard's shape).
    @State private var bookAscent: BookAscent?

    struct BookAscent: Equatable {
        let bookID: String
        let postID: String
    }

    struct BlockTarget: Equatable {
        let containerID: String
        let blockID: String
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
        router: ShellRouter = ShellRouter(), windows: WindowRegistry = WindowRegistry(),
        // 13e E14: defaulted like `windows`, and defaulted to the INERT
        // system — a harness that mounts this view must never ask the real
        // system for her chord (it would fight the running app for it).
        hotKeys: GlobalHotKeyCenter = GlobalHotKeyCenter(system: .inert)
    ) {
        self.session = session
        self.services = services
        self.windows = windows
        self.hotKeys = hotKeys
        _router = State(initialValue: router)
        _library = State(initialValue: LibraryViewModel(session: session))
        _tags = State(initialValue: TagsViewModel(session: session))
        _readings = State(initialValue: ReadingsViewModel(session: session))
        _pool = State(initialValue: PoolViewModel(session: session))
        _shelf = State(initialValue: ShelfViewModel(session: session))
        _catalog = State(initialValue: LibraryCatalogModel(session: session))
        _poolPosts = State(initialValue: PoolPostsModel(session: session))
        _palette = State(initialValue: PaletteModel(session: session))
        _stars = State(initialValue: StarsModel(session: session))
        _theme = State(initialValue: ThemeStore(session: session))
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                session: session, model: library, pool: pool,
                workspace: router.workspace, stars: stars, starDoor: starDoor,
                selection: selectionBinding,
                onOpenBeside: { router.openBeside(.post($0)) },
                onOpenInNewWindow: openInNewWindow,
                // 13b 1b: the rail's marker reads the router's observable
                // mode truth (the broadcast-derived shadow is retired).
                postMode: (session.commandRouter.activeMode ?? .takes).rawValue)
                .navigationSplitViewColumnWidth(min: 180, ideal: 210)
                .safeAreaInset(edge: .bottom) {
                    if let services {
                        // Sitting 9 (her report): the scrap rows scroll UNDER
                        // this inset — an opaque voiced background + divider
                        // keep the status rows readable over any list content.
                        VStack(alignment: .leading, spacing: 0) {
                            Divider().overlay(theme.tokens(for: scheme).line)
                            SyncStatusRow(services: services)
                            BridgeStatusRow(bridge: services.bridge) {
                                accountSheetShown = true
                            }
                        }
                        .background(theme.tokens(for: scheme).room)
                    }
                }
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
        // 13g L4 (WT-4): *"i don't even konw if we need that empty whitespace
        // that says Variorum at the top - let's try getting rid of it."*
        // MEASURED (the Debug build, captured and zoomed): the word she sees
        // is the WINDOW TITLE, drawn in a band across the top of the detail
        // pane — NOT the sidebar `Section` header the plan named, which
        // renders nothing at all on macOS 26. Removing the title takes the
        // band's only content away; `.ignoresSafeArea` above takes the band
        // itself. A TRY, per her word — one modifier to put back.
        .toolbar(removing: .title)
        .environment(theme)
        // 13f batch 5b: AppKit's own key events, reported to the registry —
        // the ONE place key-ness is decided (and it is sticky there: a
        // resign never un-keys, so ⌘-tabbing to another app does not tear
        // this window's live surface down).
        .background {
            WindowKeyReporter(
                onWindow: { windows.attach($0, to: windowID) },
                onKey: { windows.noteKey(windowID) })
        }
        .sheet(isPresented: $accountSheetShown) {
            if let services {
                AccountView(services: services)
            }
        }
        .sheet(isPresented: $paletteOpen) {
            CommandPaletteView(model: palette) { picked, blockID in
                open(picked, blockID: blockID)
            }
            .environment(theme)
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
        // Phase 13 C1: the voice's text-surface half — keep the one global
        // typography current so surfaces created LATER materialize in the
        // right voice (open surfaces re-style through their own chrome
        // application; both writers set the same resolved value).
        .onChange(of: theme.settings) { _, settings in
            EditorTypography.current = EditorTypography.resolve(
                voice: settings.voice, inlineComments: settings.inlineComments)
            adoptMarkdownPalette()
        }
        // 13g batch 2 (L7): the markdown face's palette follows the voice AND
        // the appearance — the second is why it needs its own hook (the
        // settings value does not move when the Mac switches to dark).
        .onChange(of: scheme) { _, _ in adoptMarkdownPalette() }
        .task { await theme.start() }
        .task { await library.start() }
        .task { await library.startJournal() }
        .task { await tags.start() }
        .task { await readings.start() }
        .task { await pool.start() }
        .task { await stars.start() }
        .onAppear {
            windows.register(windowID, router: router, kind: .full)
            wirePaletteCommands()
            wireWorkspace()
            adoptMarkdownPalette()
            // 13e E14 (W26): ask the system for ⌃⌥⌘N. Here because this is
            // the one place holding BOTH the app-lifetime centre and the
            // `openWindow` a summon needs; idempotent, so the second window
            // asks for nothing new. The captured action outlives this window
            // deliberately — she can close every window and the pad still
            // answers her chord (the menu-bar extra's own promise).
            hotKeys.install { _ in summonQuickNote() }
        }
        .onDisappear { windows.unregister(windowID) }
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
        // 13f batch 5 (W22's button): the first-edit note names its target
        // book by the chooser's own order, and that order floats what she
        // has visited — which lives per window, so it reads the key one too.
        session.recentBookIDs = { windows.activeRouter?.workspace.recentBookIDs ?? [] }
        let status = session.status
        router.speak = { status.speak($0) }
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
    private func adopt(_ destination: SidebarSelection, in pane: PaneID) {
        switch router.workspace.select(destination, in: pane) {
        case .adopted:
            break
        case .focusedExistingPane:
            session.status.speak(
                WorkspaceNaming.sameNoteNote(router.workspace.label(for: destination)))
        }
    }

    /// A navigation door belonging to a particular pane: it focuses that
    /// pane and navigates it in one click, which is how a row click inside
    /// an UNFOCUSED list pane does the obvious thing.
    private func opener(_ pane: PaneID) -> (SidebarSelection) -> Void {
        { destination in adopt(destination, in: pane) }
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
                        paneDivider(index: index - 1, rowWidth: geo.size.width, tokens: tokens)
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

    /// The draggable seam. Its arithmetic is `PaneLayout`'s (clamped so a
    /// drag can never swallow a pane); the drag itself is AppKit's and is
    /// on the visual-verification list.
    private func paneDivider(index: Int, rowWidth: CGFloat, tokens: VoiceTokens) -> some View {
        Rectangle()
            .fill(tokens.line)
            .frame(width: Self.dividerWidth)
            .overlay {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 9)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(coordinateSpace: .named(Self.paneRowSpace))
                            .onChanged { value in
                                guard rowWidth > 0 else { return }
                                router.workspace.setSplitFraction(
                                    at: index, to: value.location.x / rowWidth)
                            })
                    .onHover { inside in
                        if inside { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() }
                    }
            }
            .help("Drag to resize the panes")
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
            // 13k K11: the → is ⌘]'s face, on the pane it sits above —
            // focus first, exactly as the ← does, so the key and the icon
            // can never act on different panes.
            onForward: {
                router.workspace.focus(pane)
                router.goForward(in: pane)
            },
            onToggleTags: { router.toggleTagChips() },
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
                starDoor: starDoor)
        case .library:
            LibraryCatalogView(
                session: session, model: catalog, library: library, tags: tags,
                onOpen: openHere,
                onOpenBlock: { picked, blockID in open(picked, blockID: blockID, in: pane) },
                onOpenBeside: { router.openBeside(.post($0)) },
                onOpenInNewWindow: openInNewWindow,
                starDoor: starDoor,
                // MINOR-D6: the one fire-and-DO tutorial door (failures speak).
                onOpenTutorial: { ShellActions(session: session, shell: router).openTutorial() })
        case .poolPosts:
            PoolPostsView(
                session: session, model: poolPosts, library: library,
                readings: readings, tags: tags,
                onOpen: openHere,
                onOpenBeside: { router.openBeside(.post($0)) },
                onOpenInNewWindow: openInNewWindow,
                starDoor: starDoor)
        case .blocks:
            // Batch 12: the Blocks AREA — standalone blocks live and are
            // born here (the sidebar rows retired).
            BlocksAreaView(session: session, model: pool) { poolID in
                openHere(.pool(poolID))
            }
        case .post(let postID):
            if live {
                // Phase 11 (A3): the mode switcher — Write / Takes / Compare
                // over one post, one store.
                PostDetailView(
                    session: session, postID: postID,
                    initialBlockID: target(for: postID),
                    recentBookIDs: router.workspace.recentBookIDs)
                    // a different post (or block landing) is a different editor
                    .id("\(postID)#\(target(for: postID) ?? "")")
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
                onRevealConsumed: { bookAscent = nil })
                .id(readingID)
        case .pool(let poolID):
            if live {
                // A scraps container ("Blocks") opens in the ordinary detail
                // editor (the ratified Phase 10 shape); the canvas is its
                // second face (Phase 11, A7).
                PoolDetailView(
                    session: session, poolID: poolID,
                    initialBlockID: target(for: poolID))
                    .id("\(poolID)#\(target(for: poolID) ?? "")")
            } else {
                readCheapNote(poolID, pane: pane)
            }
        case .recovery:
            RecoveryView(
                session: session, library: library,
                openPost: { postID in openHere(.post(postID)) })
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
    /// door, so the pane's history is pushed and ⌘[ returns to the note.
    private func openBook(_ bookID: String, at postID: String, in pane: PaneID) {
        bookAscent = BookAscent(bookID: bookID, postID: postID)
        adopt(.reading(bookID), in: pane)
    }

    /// Navigation with an optional caret-precise block landing (Stage C).
    private func open(
        _ picked: SidebarSelection, blockID: String?, in pane: PaneID? = nil
    ) {
        switch (picked, blockID) {
        case (.post(let id), .some(let block)), (.pool(let id), .some(let block)):
            blockTarget = BlockTarget(containerID: id, blockID: block)
        default:
            blockTarget = nil
        }
        adopt(picked, in: pane ?? router.workspace.focusedPane)
    }

    private func target(for containerID: String) -> String? {
        blockTarget?.containerID == containerID ? blockTarget?.blockID : nil
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
            ("Go to Shelf", { [self] in adopt(.shelf, in: router.workspace.focusedPane) }),
            ("Go to Library", { [self] in adopt(.library, in: router.workspace.focusedPane) }),
            ("Go to Pool", { [self] in adopt(.poolPosts, in: router.workspace.focusedPane) }),
            (RecoveryPath.menuLabel,
                { [self] in adopt(.recovery, in: router.workspace.focusedPane) }),
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
