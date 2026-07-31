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
    @State private var selection: SidebarSelection? = .shelf
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
                workspace: router.workspace, selection: $selection,
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
            VStack(spacing: 0) {
                // 13f batch 3 (W16): the road back, above whatever the pane
                // is showing — one chip for every destination kind, because
                // "where did I come from" is the PANE's fact, not the
                // post's. Absent when the pane arrived from nowhere.
                if let origin = router.workspace.history().origin {
                    BackChip(
                        tokens: theme.tokens(for: scheme),
                        originLabel: router.workspace.label(for: origin),
                        collapsed: router.workspace.backChipCollapsed,
                        onBack: { router.goBack() },
                        onToggleCollapse: {
                            router.workspace.backChipCollapsed.toggle()
                        })
                    Divider().overlay(theme.tokens(for: scheme).line)
                }
                detail
            }
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
            selection = pending
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
        workspace.visit(selection ?? .shelf)
    }

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case .shelf, nil:
            ShelfView(
                session: session, model: shelf, readings: readings,
                onOpen: { selection = $0 },
                onTodaysEntry: { openToday() })
        case .library:
            LibraryCatalogView(
                session: session, model: catalog, library: library, tags: tags,
                onOpen: { selection = $0 },
                onOpenBlock: { picked, blockID in open(picked, blockID: blockID) },
                // MINOR-D6: the one fire-and-DO tutorial door (failures speak).
                onOpenTutorial: { ShellActions(session: session, shell: router).openTutorial() })
        case .poolPosts:
            PoolPostsView(
                session: session, model: poolPosts, library: library,
                readings: readings, tags: tags,
                onOpen: { selection = $0 })
        case .blocks:
            // Batch 12: the Blocks AREA — standalone blocks live and are
            // born here (the sidebar rows retired).
            BlocksAreaView(session: session, model: pool) { poolID in
                selection = .pool(poolID)
            }
        case .post(let postID):
            // Phase 11 (A3): the mode switcher — Write / Takes / Compare
            // over one post, one store.
            PostDetailView(
                session: session, postID: postID,
                initialBlockID: target(for: postID))
                // a different post (or block landing) is a different editor
                .id("\(postID)#\(target(for: postID) ?? "")")
        case .tag(let tagID):
            FolderView(session: session, tagID: tagID) { postID in
                selection = .post(postID)
            }
            .id(tagID)
        case .reading(let readingID):
            BookView(session: session, readingID: readingID)
                .id(readingID)
        case .pool(let poolID):
            // A scraps container ("Blocks") opens in the ordinary detail
            // editor (the ratified Phase 10 shape); the canvas is its
            // second face (Phase 11, A7).
            PoolDetailView(
                session: session, poolID: poolID,
                initialBlockID: target(for: poolID))
                .id("\(poolID)#\(target(for: poolID) ?? "")")
        case .recovery:
            RecoveryView(
                session: session, library: library,
                openPost: { postID in selection = .post(postID) },
                revealBlockID: revealUnplacedBlockID,
                onRevealConsumed: { revealUnplacedBlockID = nil })
        }
    }

    /// Navigation with an optional caret-precise block landing (Stage C).
    private func open(_ picked: SidebarSelection, blockID: String?) {
        switch (picked, blockID) {
        case (.post(let id), .some(let block)), (.pool(let id), .some(let block)):
            blockTarget = BlockTarget(containerID: id, blockID: block)
        default:
            blockTarget = nil
        }
        selection = picked
    }

    private func target(for containerID: String) -> String? {
        blockTarget?.containerID == containerID ? blockTarget?.blockID : nil
    }

    /// The dated home's door (R38: the journal lives on the shelf;
    /// `JournalBooks.openToday` carries the ensure-membership half).
    private func openToday() {
        Task {
            if let id = await library.openJournalEntry() {
                selection = .post(id)
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
            ("Go to Shelf", { [self] in selection = .shelf }),
            ("Go to Library", { [self] in selection = .library }),
            ("Go to Pool", { [self] in selection = .poolPosts }),
            (RecoveryPath.menuLabel, { [self] in selection = .recovery }),
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
