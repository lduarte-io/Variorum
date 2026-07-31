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
    /// Menu-command routing (⌘N/⌘J/⌘K — Phase 13 B2).
    let router: ShellRouter
    @State private var library: LibraryViewModel
    @State private var tags: TagsViewModel
    @State private var readings: ReadingsViewModel
    @State private var pool: PoolViewModel
    @State private var shelf: ShelfViewModel
    @State private var catalog: LibraryCatalogModel
    @State private var poolPosts: PoolPostsModel
    @State private var palette: PaletteModel
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
    @State private var revealUnplacedBlockID: String?
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

    init(session: AppSession, services: AppServices? = nil, router: ShellRouter = ShellRouter()) {
        self.session = session
        self.services = services
        self.router = router
        _library = State(initialValue: LibraryViewModel(session: session))
        _tags = State(initialValue: TagsViewModel(session: session))
        _readings = State(initialValue: ReadingsViewModel(session: session))
        _pool = State(initialValue: PoolViewModel(session: session))
        _shelf = State(initialValue: ShelfViewModel(session: session))
        _catalog = State(initialValue: LibraryCatalogModel(session: session))
        _poolPosts = State(initialValue: PoolPostsModel(session: session))
        _palette = State(initialValue: PaletteModel(session: session))
        _theme = State(initialValue: ThemeStore(session: session))
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                session: session, model: library, pool: pool,
                workspace: router.workspace, selection: selectionBinding,
                onOpenBeside: { router.openBeside(.post($0)) },
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
        .environment(theme)
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
            guard let id = note.userInfo?["postID"] as? String else { return }
            router.pendingSelection = .post(id)
        }
        // 13f W10b: "Show Original Block" — the surface names the block, the
        // SHELL decides the destination (P-4). One place, both editors.
        .onReceive(
            NotificationCenter.default.publisher(for: .variorumRevealUnplacedBlock)
        ) { note in
            guard let id = note.userInfo?["blockID"] as? String else { return }
            revealUnplacedBlockID = id
            router.pendingSelection = .recovery
        }
        // 13f W20(a) — THE ASCENT: the membership chip names a book and a
        // post; the SHELL decides that this means "navigate to the book,
        // and hand it the post to land on" (P-4, the W10b precedent).
        .onReceive(
            NotificationCenter.default.publisher(for: .variorumOpenBookAtPost)
        ) { note in
            guard let bookID = note.userInfo?["bookID"] as? String,
                  let postID = note.userInfo?["postID"] as? String
            else { return }
            openBook(bookID, at: postID, in: router.workspace.focusedPane)
        }
        .onChange(of: router.paletteRequested) { _, requested in
            guard requested else { return }
            paletteOpen = true
            router.paletteRequested = false
        }
        // Phase 13 C1: the voice's text-surface half — keep the one global
        // typography current so surfaces created LATER materialize in the
        // right voice (open surfaces re-style through their own chrome
        // application; both writers set the same resolved value).
        .onChange(of: theme.settings) { _, settings in
            EditorTypography.current = EditorTypography.resolve(
                voice: settings.voice, inlineComments: settings.inlineComments)
        }
        .task { await theme.start() }
        .task { await library.start() }
        .task { await library.startJournal() }
        .task { await tags.start() }
        .task { await readings.start() }
        .task { await pool.start() }
        .onAppear {
            wirePaletteCommands()
            wireWorkspace()
        }
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
        let workspace = router.workspace
        session.commandRouter.openNoteCount = { workspace.openNotes.ids.count }
        session.commandRouter.canNavigateBack = { workspace.history().canGoBack }
        session.commandRouter.canNavigateForward = { workspace.history().canGoForward }
        // 13f batch 4: the split's two facts, and the router's own voice.
        // `history()` now defaults to the FOCUSED pane, so the two
        // navigation closures above became focus-aware without changing —
        // the gate's refinement, landed at the model.
        session.commandRouter.paneCount = { workspace.panes.count }
        session.commandRouter.canOpenBeside = { workspace.openBesideCandidate != nil }
        let status = session.status
        router.speak = { status.speak($0) }
        workspace.visit(selection ?? .shelf)
    }

    // MARK: - Selection, per pane (13f batch 4 — the gate's (a))

    /// What the FOCUSED pane shows. The sidebar binds to this, so a sidebar
    /// click targets the focused pane by construction and batch 3's ONE
    /// recording point below stays complete without knowing panes exist.
    private var selection: SidebarSelection? {
        router.workspace.selections[router.workspace.focusedPane]
    }

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
            .frame(width: geo.size.width, height: geo.size.height)
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
        // THE MOUNT RULE, consulted as the one fork (13f batch 4, gate (b)):
        // exactly the focused pane mounts a live surface — an authority
        // owner, a routed-command handler, a live editor. Everything else
        // renders read-cheap, which is why the app-scoped singletons that
        // assume one detail keep being correct.
        let live = PaneMount.kind(of: pane, focused: router.workspace.focusedPane) == .live
        return PaneHost(
            tokens: tokens, session: session, workspace: router.workspace, pane: pane,
            focused: live, split: split,
            onBack: {
                router.workspace.focus(pane)
                router.goBack(in: pane)
            },
            onToggleCollapse: { router.workspace.contextBarCollapsed.toggle() },
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
                onTodaysEntry: { openToday(in: pane) })
        case .library:
            LibraryCatalogView(
                session: session, model: catalog, library: library, tags: tags,
                onOpen: openHere,
                onOpenBlock: { picked, blockID in open(picked, blockID: blockID, in: pane) },
                onOpenBeside: { router.openBeside(.post($0)) },
                // MINOR-D6: the one fire-and-DO tutorial door (failures speak).
                onOpenTutorial: { ShellActions(session: session, shell: router).openTutorial() })
        case .poolPosts:
            PoolPostsView(
                session: session, model: poolPosts, library: library,
                readings: readings, tags: tags,
                onOpen: openHere,
                onOpenBeside: { router.openBeside(.post($0)) })
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
                openPost: { postID in openHere(.post(postID)) },
                revealBlockID: revealUnplacedBlockID,
                onRevealConsumed: { revealUnplacedBlockID = nil })
        }
    }

    /// An unfocused note pane: the read tier, in its own scroll (the read
    /// view is content-sized and never brings one — the `SpreadPage`
    /// precedent), with its click-to-focus door pointed at this pane.
    private func readCheapNote(_ containerID: String, pane: PaneID) -> some View {
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
