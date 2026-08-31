//
//  MobileShellView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the app's real shape (M7): shelf-first home,
//  tabs Shelf · Library (LK7: text-only, voice-cased), navigation to book
//  lists and THE editor (the S1/S2 Write surface). This replaces Phase
//  8's `MobileRootView` + capture stack.
//
//  Both tab stacks stay ALIVE (opacity-switched) so each keeps its
//  navigation state; the voiced tab bar renders on tab ROOTS only (a
//  pushed book list or note shows no tab bar — the ratified mockup's own
//  geometry). Pushed screens keep the system navigation back door in
//  minimal inline form (functional; the nav chrome's exact voice is
//  look-track material, recorded PROVISIONAL).
//
//  The Stage 0 spike's DEBUG auto-run cover survives at the root (the
//  gate record's KEPT deviation — `TK2SpikeUITests` drives it); the
//  manual spike door moved to Settings. The S1 "Write S1" DEBUG door
//  RETIRED with the capture surface (the app shape is its replacement).
//

import SwiftUI
import VariorumCore

/// Where the shell can navigate. `focus` on a note ⇒ raise the keyboard
/// on arrival (the Today door's straight-into-typing invitation).
enum MobileRoute: Hashable {
    /// A book's front: the CONTENTS list (the S3 screen). P35's ruled
    /// inversion (parity A3) — "book-tap INVERTS — contents list first;
    /// Read is the door": this supersedes S4's Read-first reading of M8.
    case book(String)
    /// The Read flow (the calm continuous column) — reached through the
    /// contents screen's "Read" door, never by the book tap itself.
    case bookRead(String)
    case note(String, focus: Bool)
    /// **THE TWO ROOMS** (batch 6c — her QUESTIONS #84 ruling: *"Two rooms
    /// … two doors, two destinations, nothing shared."*). Batch 4's single
    /// `.recovery` route opened one screen holding both states and RETIRES
    /// here. Both are pushed, never held: the Trash's stranded-originals arm
    /// walks lineage families, so it is a deliberately-opened room (the
    /// Mac's own posture), and Archive follows its sibling.
    case trash
    case archive
    /// **Note ▸ Versions** (batch 6c — PL-14(f)): the moments of one note,
    /// pushed over it. The phone covers and stands its editor down, which is
    /// the honest answer to a Mac side panel it cannot have.
    case versions(String)
}

enum MobileTab {
    case shelf
    case library
}

struct MobileShellView: View {
    let session: AppSession
    let services: AppServices?
    let router: MobileShellRouter
    /// 13p Batch 4: the launch/protection brain — the protection screen's
    /// controller, and `canLock` for the Lock Now door (P-2: a door that
    /// cannot act is not rendered). Optional so any future composition
    /// without one still builds; the app always passes it.
    var bootstrap: AppBootstrap?

    @State private var tab: MobileTab = .shelf
    @State private var shelfPath = NavigationPath()
    @State private var libraryPath = NavigationPath()
    @State private var shelfModel: MobileShelfViewModel
    @State private var libraryModel: MobileLibraryViewModel
    /// The scraps area's model (parity C3 — the Library's third filter).
    @State private var scrapsModel: MobileScrapsModel
    /// The Trash room's model (PR2) — one per shell, so the filter and sort
    /// survive a push/pop the way the Library's do.
    @State private var trashModel: MobileTrashModel
    /// The Archive room's own model (batch 6c). Two rooms, two models —
    /// *"nothing shared"* is the ruling's own clause, and a shared model
    /// would have kept one error slot and one receipt slot between two rooms
    /// that exist to be read apart.
    @State private var archiveModel: MobileArchiveModel
    /// The starred set (parity C3 — ONE model threaded to every surface
    /// carrying the star door, the Mac StarDoor discipline).
    @State private var starsModel: MobileStarsModel
    @State private var settingsPresented = false
    /// 13p Batch 4: the protection screen, openable from the nudge/
    /// reminder bar as well as from Settings (each presenter owns its own
    /// state — the tag-manager precedent).
    @State private var protectionPresented = false
    @Environment(\.colorScheme) private var scheme
    #if DEBUG
    // Stage 0 TK2 spike auto-run (KEPT — the executable §5 form).
    @State private var spikePresented = SpikeLaunch.autoRunRequested || SpikeLaunch.uiTestBenchRequested
    #endif

    init(
        session: AppSession, services: AppServices?, router: MobileShellRouter,
        bootstrap: AppBootstrap? = nil
    ) {
        self.session = session
        self.services = services
        self.router = router
        self.bootstrap = bootstrap
        _shelfModel = State(initialValue: MobileShelfViewModel(session: session))
        _libraryModel = State(initialValue: MobileLibraryViewModel(session: session))
        _scrapsModel = State(initialValue: MobileScrapsModel(session: session))
        _trashModel = State(initialValue: MobileTrashModel(session: session))
        _archiveModel = State(initialValue: MobileArchiveModel(session: session))
        _starsModel = State(initialValue: MobileStarsModel(session: session))
        // The quick-note box's session (round 2, M5). Bound HERE and not
        // in a `.task` deliberately: `bind` is idempotent and writes only
        // `@ObservationIgnored` storage, so it cannot re-enter the view
        // update — and doing it synchronously leaves no window in which a
        // keystroke could find a box with no store to mint into.
        router.quickNote.bind(session: session)
    }

    private var tokens: VoiceTokens {
        .resolve(voice: router.voice, dark: scheme == .dark)
    }

    var body: some View {
        ZStack {
            stack(path: $shelfPath, owner: .shelf) {
                MobileShelfView(
                    model: shelfModel, stars: starsModel,
                    quickNote: router.quickNote, tokens: tokens,
                    tabBar: { tabBar },
                    onOpenBook: { id in
                        leavingShelf { shelfPath.append(MobileRoute.book(id)) }
                    },
                    onOpenForWriting: { id in
                        leavingShelf { shelfPath.append(MobileRoute.note(id, focus: true)) }
                    },
                    onOpenNote: { id in
                        leavingShelf { shelfPath.append(MobileRoute.note(id, focus: false)) }
                    },
                    onSettings: { settingsPresented = true },
                    // Finding 1: a deleted BOOK rows in the Trash while
                    // books live here, so the Shelf renders the same door.
                    onOpenTrash: {
                        leavingShelf { shelfPath.append(MobileRoute.trash) }
                    })
            }
            .opacity(tab == .shelf ? 1 : 0)
            .allowsHitTesting(tab == .shelf)
            .accessibilityHidden(tab != .shelf)

            stack(path: $libraryPath, owner: .library) {
                MobileLibraryView(
                    model: libraryModel, scraps: scrapsModel, stars: starsModel,
                    tokens: tokens,
                    tabBar: { tabBar },
                    onOpen: { libraryPath.append($0) },
                    onOpenTrash: { libraryPath.append(MobileRoute.trash) },
                    onOpenArchive: { libraryPath.append(MobileRoute.archive) })
            }
            .opacity(tab == .library ? 1 : 0)
            .allowsHitTesting(tab == .library)
            .accessibilityHidden(tab != .library)
        }
        // 13p Batch 4 (item e): the Standard nudge / reminder, as a calm
        // banner at the top — dismissible, NEVER modal (an offer that
        // blocks the app is a demand). It sits above both tab stacks
        // rather than inside either, so it survives a tab switch and never
        // fights the tab bar for the bottom edge.
        .safeAreaInset(edge: .top, spacing: 0) {
            if let protection = bootstrap?.protection {
                MobileProtectionNoticeBar(
                    controller: protection, services: services, tokens: tokens,
                    openProtection: { protectionPresented = true })
            }
        }
        .sheet(isPresented: $settingsPresented) {
            settingsSheet
        }
        .sheet(isPresented: $protectionPresented) {
            if let protection = bootstrap?.protection {
                MobileProtectionSheet(
                    controller: protection, services: services,
                    bootstrap: bootstrap, tokens: tokens)
            }
        }
        .task { await starsModel.start() }
        // R27b's starter Journal used to be seeded from HERE, concurrently
        // with the task that composes AppServices — which is what the
        // batch-5 cold review's MAJOR was about: the seed always won that
        // race, so its virgin-store guard was asked before sync could
        // possibly have answered. It now runs in `VariorumMobileApp`'s own
        // task, AFTER `services.start()`, where sign-in is settled and the
        // sync gate has something true to read.
        #if DEBUG
        .fullScreenCover(isPresented: $spikePresented) { SpikeScreen() }
        #endif
    }

    /// The Settings sheet. FIX-B4 (fire-and-DO): the DEBUG "Open the
    /// pocket guide" door really OPENS the book — dismiss the sheet and
    /// push the book's contents onto the SHELF stack (Settings is the
    /// shelf's own door, so the shelf tab is the visible one whenever
    /// this fires; the tab itself is deliberately not written — the tab
    /// doors own the liveness handoff).
    private var settingsSheet: some View {
        #if DEBUG
        return MobileSettingsView(
            session: session, router: router, services: services,
            bootstrap: bootstrap,
            onOpenTutorialBook: { bookID in
                settingsPresented = false
                shelfPath.append(MobileRoute.book(bookID))
            })
        #else
        return MobileSettingsView(
            session: session, router: router, services: services,
            bootstrap: bootstrap)
        #endif
    }

    /// One tab's navigation stack: a voiced root + the shared route
    /// destinations. `owner` is the STACK's identity, not the visible tab
    /// (S3 ladder BLOCKER wiring: a hidden stack's screens re-render while
    /// the other tab shows, so liveness registration must carry the
    /// owning stack, never `tab`'s current value).
    private func stack<Root: View>(
        path: Binding<NavigationPath>, owner: MobileTab, @ViewBuilder root: () -> Root
    ) -> some View {
        NavigationStack(path: path) {
            root()
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: MobileRoute.self) { route in
                    destination(route, in: owner)
                }
        }
    }

    @ViewBuilder
    private func destination(_ route: MobileRoute, in owner: MobileTab) -> some View {
        switch route {
        case .book(let readingID):
            // P35 (parity A3, her ruled flip): a book opens into its
            // CONTENTS list; Read is the door from there. Tapping into a
            // note edits it in Write — both roads unchanged.
            MobileBookView(
                session: session, readingID: readingID, tokens: tokens,
                onOpen: { push(.note($0, focus: false), in: owner) },
                onRead: { push(.bookRead(readingID), in: owner) },
                // PR4: the book went — never leave a contents list standing
                // on a tombstone.
                onDeleted: { pop(in: owner) })
        case .bookRead(let readingID):
            MobileReadView(
                session: session, readingID: readingID, tokens: tokens,
                onOpen: { push(.note($0, focus: false), in: owner) })
        case .note(let postID, let focus):
            MobileWriteScreen(
                session: session, postID: postID, router: router,
                beginEditing: focus, tab: owner,
                onOpenNote: { push(.note($0, focus: false), in: owner) },
                // PR1: the note went — pop, because a Write surface standing
                // on a tombstoned note is exactly what the delete door must
                // not leave behind.
                onDeleted: { pop(in: owner) },
                // Batch 6c: the ⋯ sheet's Versions… row, pushed onto the
                // OWNING stack (never the visible tab's — the S3 rule).
                onOpenVersions: { push(.versions(postID), in: owner) })
        case .trash:
            MobileTrashView(
                model: trashModel, tokens: tokens,
                onOpen: { push(.note($0, focus: false), in: owner) })
        case .archive:
            MobileArchiveView(
                model: archiveModel, tokens: tokens,
                onOpen: { push(.note($0, focus: false), in: owner) })
        case .versions(let postID):
            // Built per push: a note's moments are that note's, and this
            // screen's whole lifetime is one visit (the read is the note's
            // own version count — never corpus-shaped).
            MobileVersionsScreen(session: session, postID: postID, tokens: tokens)
        }
    }

    /// A5-8 — LEAVING MINTS AND CLEARS. Every road OFF the shelf root
    /// files what is in the quick-note box first: the push happens
    /// immediately (navigation must never wait on a write), and the filing
    /// runs to completion on its own because the box's text lives on the
    /// router's model, not on a view that is about to be covered. The box
    /// comes back empty, which is the Mac pad's closing-files-it grammar.
    private func leavingShelf(_ push: () -> Void) {
        let quickNote = router.quickNote
        Task { await quickNote.fileOnLeaving() }
        push()
    }

    /// One push door for the route builders — the OWNING stack's path,
    /// never the visible tab's (the S3 BLOCKER wiring rule).
    private func push(_ route: MobileRoute, in owner: MobileTab) {
        if owner == .shelf {
            shelfPath.append(route)
        } else {
            libraryPath.append(route)
        }
    }

    /// Its mirror (round 2 batch 4): a screen whose subject just went pops
    /// off the OWNING stack, by the same rule — never the visible tab's.
    /// Guarded, because a pop of an empty path traps.
    private func pop(in owner: MobileTab) {
        if owner == .shelf {
            if !shelfPath.isEmpty { shelfPath.removeLast() }
        } else {
            if !libraryPath.isEmpty { libraryPath.removeLast() }
        }
    }

    /// LK7's tab bar: text-only, voice-cased (terminal lowercase / study
    /// normal case), hairline top rule — the ratified shape A.
    private var tabBar: some View {
        HStack(spacing: 34) {
            tabDoor("Shelf", .shelf)
            tabDoor("Library", .library)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(tokens.room)
        .overlay(alignment: .top) {
            Rectangle().fill(tokens.line).frame(height: 1)
        }
    }

    private func tabDoor(_ label: String, _ target: MobileTab) -> some View {
        Button {
            guard tab != target else { return }
            tab = target
            // The liveness handoff (S3 ladder BLOCKER): the entering
            // tab's editor takes the pen — the leaving tab's stands down;
            // pending text lands and the taker re-reads fresh BEFORE its
            // next keystroke can build on a stale photograph.
            let editors = router.editors
            // THE ORDER IS FIXED HERE, SYNCHRONOUSLY (the architectural
            // review's MAJOR 2), in the same turn as the `tab` assignment
            // above. The task below suspends twice on database work, so two
            // quick taps used to leave two unordered tasks racing to
            // install liveness — and the loser installing last won. The
            // token says which request this task belongs to; a task that
            // resumes to find a newer one abandons its grant.
            let handoff = editors.beginHandoff()
            // A5-8: a tab switch is a leaving, so the quick-note box files
            // whatever is in it (a no-op when it is empty).
            let quickNote = router.quickNote
            Task {
                await quickNote.fileOnLeaving()
                await editors.tabDidBecomeVisible(target, handoff: handoff)
            }
        } label: {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(tab == target ? tokens.ink : tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(tab == target ? .isSelected : [])
    }
}
