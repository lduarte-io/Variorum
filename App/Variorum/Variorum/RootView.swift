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
            SidebarView(session: session, model: library, pool: pool, selection: $selection)
                .navigationSplitViewColumnWidth(min: 180, ideal: 210)
                .safeAreaInset(edge: .bottom) {
                    if let services {
                        VStack(alignment: .leading, spacing: 0) {
                            SyncStatusRow(services: services)
                            BridgeStatusRow(bridge: services.bridge)
                        }
                    }
                }
        } detail: {
            detail
        }
        .environment(theme)
        .sheet(isPresented: $paletteOpen) {
            CommandPaletteView(model: palette) { picked in
                selection = picked
            }
            .environment(theme)
        }
        .onChange(of: router.pendingSelection) { _, pending in
            guard let pending else { return }
            selection = pending
            router.pendingSelection = nil
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
        .onAppear { wirePaletteCommands() }
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
                onOpen: { selection = $0 })
        case .poolPosts:
            PoolPostsView(
                session: session, model: poolPosts, library: library,
                readings: readings, tags: tags,
                onOpen: { selection = $0 })
        case .post(let postID):
            // Phase 11 (A3): the mode switcher — Write / Takes / Compare
            // over one post, one store.
            PostDetailView(session: session, postID: postID)
                .id(postID) // a different post is a different editor
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
            PoolDetailView(session: session, poolID: poolID)
                .id(poolID)
        case .recovery:
            RecoveryView(session: session, library: library) { postID in
                selection = .post(postID)
            }
        case .tutorial:
            ModesTutorialView(session: session) { postID in
                selection = .post(postID)
            }
        }
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

    /// The ⌘K vocabulary (R15): the buried capabilities, typeable. Actions
    /// live in composition — the palette lists and picks only.
    private func wirePaletteCommands() {
        palette.commands = [
            ("New Post", { [self] in
                Task {
                    if let id = await library.createPost() { selection = .post(id) }
                }
            }),
            ("Today's Entry", { [self] in openToday() }),
            ("Go to Shelf", { [self] in selection = .shelf }),
            ("Go to Library", { [self] in selection = .library }),
            ("Go to Pool", { [self] in selection = .poolPosts }),
            ("Archived & Deleted", { [self] in selection = .recovery }),
            ("Modes Tutorial", { [self] in selection = .tutorial }),
            ("Settings — Appearance & Tags", { [self] in openSettings() }),
            ("Toggle Block Seams", { [self] in
                theme.setSeamsVisible(!theme.settings.seamsVisible)
            }),
            ("Use Terminal Voice", { [self] in theme.setVoice(.terminal) }),
            ("Use Study Voice", { [self] in theme.setVoice(.study) }),
        ]
    }
}
