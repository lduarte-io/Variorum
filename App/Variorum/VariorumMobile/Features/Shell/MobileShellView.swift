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

/// A ROOT SURFACE — and, since batch 10, a position in the swipe band.
///
/// It is the stack's identity (`MobileLivenessAuthority` keys registration
/// on it), so a third root surface is a third case here and nothing else:
/// the authority's rules are written against the value, never against a
/// list of two. `MobileShellBand.pages` owns the ARRANGEMENT — this enum
/// stays a plain identity.
enum MobileTab {
    /// Batch 10 (her *"a list of starred notes on the home page"*): the
    /// shelf's left-hand neighbour.
    case starred
    case shelf
    case library
}

struct MobileShellView: View {
    /// **THE SETTLE — a page ARRIVES, it does not teleport** (the batch-10
    /// cold review, MAJOR 1).
    ///
    /// The band tracked the finger one point per point and then hard-cut on
    /// every release: `tab` and the drag were written in the same
    /// synchronous turn, and neither a `Button` action nor a `DragGesture`
    /// callback carries an animation, so a page 243 pt away simply *was*
    /// at zero on the next frame. A drag has a continuous phase, so a
    /// discontinuous end reads as a bug rather than as a page turn — and
    /// this is the one feature she said was *"killing me"*.
    ///
    /// **ONE settle, both roads.** It lives on `selectPage` (the single
    /// road to a page change) and on the drag's own reset transaction, so
    /// a tap and a swipe arrive the same way and neither can drift from
    /// the other. The live drag itself is deliberately NOT animated — an
    /// animated `updating` would lag the finger, which is the 13e
    /// drag-jitter lesson from the other direction.
    static let settle: Animation = .interactiveSpring(
        response: 0.32, dampingFraction: 0.86)

    let session: AppSession
    let services: AppServices?
    let router: MobileShellRouter
    /// 13p Batch 4: the launch/protection brain — the protection screen's
    /// controller, and `canLock` for the Lock Now door (P-2: a door that
    /// cannot act is not rendered). Optional so any future composition
    /// without one still builds; the app always passes it.
    var bootstrap: AppBootstrap?

    @State private var tab: MobileTab = MobileShellBand.home
    @State private var shelfPath = NavigationPath()
    @State private var libraryPath = NavigationPath()
    /// The starred page's own stack (batch 10) — a starred row opens a note
    /// or a book, and a root surface that pushes needs somewhere to push.
    @State private var starredPath = NavigationPath()
    /// The live band drag, in points, in the NAMED coordinate space
    /// (`MobileShellBand.coordinateSpace` — the 13e jitter rider). Zero
    /// whenever no page drag is in flight.
    ///
    /// **`@GestureState`, not `@State`** (the batch-10 cold review, MINOR 1).
    /// `onEnded` was the only road back to zero, and a DragGesture that is
    /// CANCELLED rather than ended — a system edge gesture taking over, a
    /// call sheet, an interruption mid-pan — does not reliably deliver it.
    /// A stranded value left the shell parked part-way between two pages
    /// with a sliver of each showing and the neighbour inert. SwiftUI resets
    /// gesture state however the gesture ends, cancellation included, so
    /// the failure cannot occur rather than being cleaned up after.
    ///
    /// **And the reset carries THE SETTLE** (`resetTransaction`): a
    /// snap-back is the commoner outcome of a release — the landing distance
    /// is 28 % of the screen — and it must glide back exactly as a landing
    /// glides forward, or the band's most frequent release is its ugliest.
    @GestureState(resetTransaction: Transaction(animation: MobileShellView.settle))
    private var bandDrag: CGFloat = 0
    /// **THE DIRECTION LATCH**, decided once per gesture and then not
    /// re-asked: `nil` while undecided, `true` for a page, `false` for a
    /// drag this band has declined (a vertical scroll). Without the latch a
    /// drag that starts vertical and curves could begin paging mid-scroll.
    @State private var bandEngaged: Bool?
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
        // **THE BAND** (batch 10 — her *"we need a swipe gesture for between
        // shelf and library it's killing me"*). The reader supplies the ONE
        // number the arithmetic needs: a page's width. Everything else is
        // `MobileShellBand`'s.
        //
        // **No paging container, deliberately** — the brief's in-batch fork.
        // Each stack below is constructed by the same code, in the same
        // order, with the same modifiers as before this batch; the band only
        // OFFSETS them. That is what makes "both stacks stay alive exactly as
        // today" a structural fact rather than a claim about a container's
        // undocumented offscreen-page lifetime.
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack {
                page(.starred, width: width) {
                    stack(path: $starredPath, owner: .starred) {
                        MobileStarredView(
                            stars: starsModel, tokens: tokens,
                            tabBar: { tabBar },
                            onOpen: { starredPath.append($0) })
                    }
                }
                page(.shelf, width: width) {
                    stack(path: $shelfPath, owner: .shelf) {
                        MobileShelfView(
                            model: shelfModel, stars: starsModel,
                            quickNote: router.quickNote, tokens: tokens,
                            tabBar: { tabBar },
                            onOpenBook: { id in
                                leavingShelf { shelfPath.append(MobileRoute.book(id)) }
                            },
                            onOpenForWriting: { id in
                                leavingShelf {
                                    shelfPath.append(MobileRoute.note(id, focus: true))
                                }
                            },
                            onSettings: { settingsPresented = true },
                            // Finding 1: a deleted BOOK rows in the Trash while
                            // books live here, so the Shelf renders the same door.
                            onOpenTrash: {
                                leavingShelf { shelfPath.append(MobileRoute.trash) }
                            })
                    }
                }
                page(.library, width: width) {
                    stack(path: $libraryPath, owner: .library) {
                        MobileLibraryView(
                            model: libraryModel, scraps: scrapsModel, stars: starsModel,
                            // The filter batch (#92(a)): the books filter lists her
                            // books as rows, through the SHELF's own model — one held
                            // observation and one set of row faces, never a second.
                            books: shelfModel,
                            tokens: tokens,
                            tabBar: { tabBar },
                            onOpen: { libraryPath.append($0) },
                            onOpenTrash: { libraryPath.append(MobileRoute.trash) },
                            onOpenArchive: { libraryPath.append(MobileRoute.archive) })
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            // Neighbours sit exactly one screen away, so nothing but the
            // current page can draw — and the clip says so rather than
            // relying on the window's own edge to hide them.
            .clipped()
            .contentShape(Rectangle())
            .coordinateSpace(name: MobileShellBand.coordinateSpace)
            // `.simultaneousGesture`, because the roots underneath are
            // vertical `ScrollView`s and a page swipe must not take the
            // scroll's place — the two recognize together and the LATCH
            // decides which one this drag was.
            //
            // `including:` is the ROOT-SURFACES-ONLY rule made structural
            // (the brief: *"the shell pages only when the ROOT surfaces are
            // showing, never inside a pushed note"*): inside a pushed note
            // the mask drops to `.subviews`, so the editor's own horizontal
            // gestures are the only ones on the screen and the band cannot
            // fight them.
            .simultaneousGesture(
                bandGesture(width: width),
                including: pagingAllowed ? .all : .subviews)
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
                    openProtection: { protectionPresented = true },
                    openSettings: { settingsPresented = true })
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

    // MARK: - The band (batch 10)

    /// One page of the band: offset by its distance from the current page
    /// plus the live drag, and inert + invisible to assistive technology
    /// unless it IS the current page.
    ///
    /// The three flags are the pre-batch ones, minus opacity: a neighbour
    /// used to be hidden by `opacity(0)` and is now hidden by being a
    /// screen away, which is what lets a drag reveal it.
    private func page<Content: View>(
        _ owner: MobileTab, width: CGFloat, @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .offset(
                x: MobileShellBand.offset(
                    for: owner, current: tab, drag: bandDrag, width: width))
            .allowsHitTesting(tab == owner)
            .accessibilityHidden(tab != owner)
    }

    /// **THE ROOT-SURFACES-ONLY RULE.** The band pages only while the
    /// visible stack is at its root; inside a pushed note or book the
    /// gesture is masked off entirely, so the editor's horizontal gestures
    /// and the system's back-swipe never share a screen with it.
    private var pagingAllowed: Bool {
        switch tab {
        case .starred: return starredPath.isEmpty
        case .shelf: return shelfPath.isEmpty
        case .library: return libraryPath.isEmpty
        }
    }

    /// The page drag. The latch is taken ONCE per gesture and honoured for
    /// its lifetime; a declined drag contributes nothing, so a vertical
    /// scroll cannot page even if it curves.
    private func bandGesture(width: CGFloat) -> some Gesture {
        DragGesture(
            minimumDistance: 1,
            coordinateSpace: .named(MobileShellBand.coordinateSpace)
        )
        // THE LATCH, and only the latch — it is ordinary view state,
        // because `onEnded` must be able to read the decision this drag
        // took, and gesture state is gone by then.
        .onChanged { value in
            guard bandEngaged == nil else { return }
            if MobileShellBand.engages(value.translation) {
                bandEngaged = true
            } else if abs(value.translation.height) > MobileShellBand.engageDistance {
                // It committed to the vertical first — this drag is the
                // scroll view's, and asking again later is what the latch
                // exists to prevent.
                bandEngaged = false
            }
        }
        // THE LIVE DRAG, as gesture state: SwiftUI owns its lifetime, so a
        // cancelled gesture cannot strand the band (MINOR 1).
        .updating($bandDrag) { value, drag, _ in
            guard bandEngaged == true else { return }
            drag = MobileShellBand.clampedDrag(
                value.translation.width, current: tab, width: width)
        }
        .onEnded { value in
            // The latch is this view's to clear; the drag is SwiftUI's.
            defer { bandEngaged = nil }
            guard bandEngaged == true else { return }
            let landed = MobileShellBand.landing(
                current: tab,
                drag: MobileShellBand.clampedDrag(
                    value.translation.width, current: tab, width: width),
                predictedEnd: value.predictedEndTranslation.width,
                width: width)
            selectPage(landed)
        }
    }

    /// **ONE ROAD TO A PAGE CHANGE — a tap and a swipe are the same act.**
    ///
    /// This is the tab door's body, lifted so the swipe cannot become a
    /// second, quieter version of it. Both halves matter and both used to
    /// live only in `tabDoor`:
    ///
    /// · **A5-8 — leaving mints and clears.** A page change is a leaving,
    ///   so the quick-note box files what is in it. A swipe that skipped
    ///   this would have been a new road off the shelf that loses what the
    ///   tab door preserves.
    /// · **The liveness handoff** (S3 ladder BLOCKER; the architectural
    ///   review's MAJOR 2): the token is minted SYNCHRONOUSLY here, in the
    ///   same turn as the `tab` assignment, so the ORDER of requests is
    ///   fixed before any task runs.
    /// · **The settle** (the cold review's MAJOR 1): the page change is the
    ///   thing being animated, so the animation belongs where the change
    ///   happens — which makes "a tap and a swipe are the same act" true of
    ///   how they LOOK as well as of what they do.
    private func selectPage(_ target: MobileTab) {
        guard tab != target else { return }
        withAnimation(Self.settle) { tab = target }
        let editors = router.editors
        let handoff = editors.beginHandoff()
        let quickNote = router.quickNote
        Task {
            await quickNote.fileOnLeaving()
            await editors.tabDidBecomeVisible(target, handoff: handoff)
        }
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
                // Batch 10: a note minted INSIDE the book opens for
                // writing (the `+ New Note` grammar on both other roots).
                onOpenForWriting: { push(.note($0, focus: true), in: owner) },
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
        switch owner {
        case .starred: starredPath.append(route)
        case .shelf: shelfPath.append(route)
        case .library: libraryPath.append(route)
        }
    }

    /// Its mirror (round 2 batch 4): a screen whose subject just went pops
    /// off the OWNING stack, by the same rule — never the visible tab's.
    /// Guarded, because a pop of an empty path traps.
    private func pop(in owner: MobileTab) {
        switch owner {
        case .starred: if !starredPath.isEmpty { starredPath.removeLast() }
        case .shelf: if !shelfPath.isEmpty { shelfPath.removeLast() }
        case .library: if !libraryPath.isEmpty { libraryPath.removeLast() }
        }
    }

    /// LK7's tab bar: text-only, voice-cased (terminal lowercase / study
    /// normal case), hairline top rule — the ratified shape A.
    ///
    /// **The third door arrives at batch 10, and it IS the band's index**:
    /// the doors are in `MobileShellBand.pages` order, so what the bar shows
    /// and what a swipe traverses are one arrangement. It is also the whole
    /// answer to discoverability — a page reachable only by a gesture is a
    /// page a VoiceOver user cannot reach at all, and a swipe nobody has
    /// been told about is not a door.
    ///
    /// *(PROVISIONAL — the alternative is two doors with `Shelf` lit while
    /// Starred shows, which would leave the bar naming a surface that is not
    /// on screen. Recorded in the batch record.)*
    private var tabBar: some View {
        HStack(spacing: 26) {
            tabDoor(MobileStarsModel.pageName, .starred)
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

    /// A tab door. The BODY moved to `selectPage` at batch 10 so the swipe
    /// and the tap are the same act — the liveness handoff (S3 ladder
    /// BLOCKER; the review's MAJOR 2 ordering) and A5-8's leaving-files-it
    /// rule both live there now, and neither road can drift from the other.
    private func tabDoor(_ label: String, _ target: MobileTab) -> some View {
        Button {
            selectPage(target)
        } label: {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(tab == target ? tokens.ink : tokens.faint)
        }
        .buttonStyle(.plain)
        // The door's NAME, not its rendered casing (`chromeLabel` lowercases
        // in the Terminal voice) — the `+ New Note` precedent, and the only
        // way an assistive reader hears the same word in both voices.
        .accessibilityLabel(label)
        .accessibilityAddTraits(tab == target ? .isSelected : [])
    }
}
