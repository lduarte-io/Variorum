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
//  navigation state; the bottom bar (`MobileTabBar`, VM-52) renders on the
//  tab ROOTS and on every pushed LIST, never inside a note (her LK-5 —
//  "Roots and lists, not notes"). Pushed screens keep the system navigation
//  back door in minimal inline form (functional; the nav chrome's exact
//  voice is look-track material, recorded PROVISIONAL — and VM-52's trace
//  of each screen's top edge is P-47-20).
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
    /// **Settings ▸ Protection** (VM-8 unit 1, PROVISIONAL P-VM8-2): the phone's Protection screen, pushed on the stack
    /// Settings was opened over (VM-53, P-47-23: every root and a note carry Settings' door now) — and on the shelf's
    /// again after an act's reopen (F-U1-3: the shell adopts `ProtectionController.settingsRequest`).
    case protection
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
    /// VM-56 — the wing the phone stands in: the held wings read (a wing
    /// that dies returns the phone to Home) and its name, the roots' title.
    /// VM-225 — the SHARED brain (VM-63's hoist; batch 1's interim holder
    /// folded into it), and the interim wing door over it.
    @State private var wings: WingsModel
    @State private var wingDoor: MobileWingDoor
    @State private var settingsPresented = false
    /// VM-8 unit 2 — F-U2-E (PROVISIONAL P-VM8-8): the open library's protection receipts on the phone — the faces'
    /// `speak` door, shown by the Protection screen (one shell per open: a re-keying act's receipt owed to its reopen is
    /// spoken into the shell that re-pushes the screen).
    @State private var protectionReceipts = MobileProtectionReceipts()
    /// VM-61 — the phone's ONE message line (the face of `session.status`),
    /// hosted once, here, above everything this shell presents.
    @State private var messageLine: MobileMessageLineModel
    /// VM-61 — the tab bar's drawn height, so the line sits above its doors on
    /// a root and (VM-52) a pushed list (measured on `MobileTabBar`, never
    /// assumed: umbrella VM-47 owns the bar's size).
    @State private var tabBarHeight: CGFloat = 0
    /// VM-47 (the VM-55 re-land, meeting 2) — the bars a pushed LIST is
    /// showing now, per stack (VM-52 gives each list its own bar; a note
    /// pushed over a list covers it, the Versions reader leaves its listing's).
    /// Counted by the list bars' own appear and disappear, so the one line
    /// clears a bar wherever one is on screen — `barOnScreen`.
    @State private var listBarsShowing: [MobileTab: Int] = [:]
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
        let wings = MobileWingDoor.phoneWings(session)
        _wings = State(initialValue: wings)
        _wingDoor = State(initialValue: MobileWingDoor(
            wings: wings,
            // P-55-18: a switch files the box's draft in its own wing first.
            fileCaptureFirst: { [quickNote = router.quickNote] in
                await quickNote.fileOnLeaving()
            }))
        _messageLine = State(initialValue: MobileMessageLineModel(
            status: session.status, voice: { [router] in router.voice }))
        // The quick-note box's session (round 2, M5). Bound HERE and not
        // in a `.task` deliberately: `bind` is idempotent and writes only
        // `@ObservationIgnored` storage, so it cannot re-enter the view
        // update — and doing it synchronously leaves no window in which a
        // keystroke could find a box with no store to mint into.
        router.quickNote.bind(session: session)
        // VM-51: the open library's theme (the hoisted store), bound here for
        // the quick note's reason — idempotent per session, `@ObservationIgnored`
        // storage only; started by this view's `.task`.
        router.bindTheme(session: session)
    }

    /// VM-51: the library's voice and palette (LK-1), in this device's
    /// appearance (LK-2) — the ONE settings → tokens road, via the router.
    private var tokens: VoiceTokens {
        router.tokens(dark: scheme == .dark)
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
                            wingName: MobileWingTitle.name(of: wings),
                            onWingDoor: { wingDoor.open() },
                            tabBar: { tabBar },
                            onOpen: { starredPath.append($0) })
                    }
                }
                page(.shelf, width: width) {
                    stack(path: $shelfPath, owner: .shelf) {
                        MobileShelfView(
                            model: shelfModel, stars: starsModel,
                            quickNote: router.quickNote, tokens: tokens,
                            wingName: MobileWingTitle.name(of: wings),
                            onWingDoor: { wingDoor.open() },
                            tabBar: { tabBar },
                            onOpenBook: { id in
                                leavingShelf { shelfPath.append(MobileRoute.book(id)) }
                            },
                            onOpenForWriting: { id in
                                leavingShelf {
                                    shelfPath.append(MobileRoute.note(id, focus: true))
                                }
                            },
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
                            wingName: MobileWingTitle.name(of: wings),
                            onWingDoor: { wingDoor.open() },
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
        // VM-61: the one message line — its own overlay window over this
        // scene, above every sheet and alert this shell presents; it lifts
        // over the tab bar wherever a bar is on screen — a root, and (VM-52)
        // a pushed list.
        .background(MobileMessageLineHost(
            model: messageLine, chromeInset: barOnScreen ? tabBarHeight : 0))
        // (13p Batch 4's notice bar — today's nudge and reminder — left with today's road at VX-329 U1.)
        // VM-53: Settings' door from every root's ⋯ menu and a note's ⋯ sheet (`MobileRootMenu.swift`).
        .environment(\.mobileSettingsDoor, MobileSettingsDoor { settingsPresented = true })
        .sheet(isPresented: $settingsPresented) {
            settingsSheet
        }
        // VM-225 — the interim wing door's plain list (the name on any root
        // opens it). A pick lands on the wing's Bookcase: the door counts the
        // landing, and the shell shows the Shelf page through its one page
        // road (P-55-14: no stack is touched, so nothing she has open is
        // closed. The Shelf's own stack is never left holding a screen while
        // hidden — a page is left only from its root, and the protection
        // ask selects the Shelf before it pushes — so the landing always
        // shows the Bookcase itself).
        .sheet(isPresented: $wingDoor.isOpen) {
            MobileWingListSheet(door: wingDoor, tokens: tokens)
                .presentationDetents([.medium, .large])
        }
        .onChange(of: wingDoor.landings) { _, _ in selectPage(.shelf) }
        // VM-8 unit 1 — F-U1-3: a reopen's ask for Protection, adopted once (a fresh shell on appear; a standing one on
        // change).
        .onAppear { adoptProtectionRequest() }
        .onChange(of: bootstrap?.protection.settingsRequest) { _, _ in adoptProtectionRequest() }
        // VM-8 unit 2 — F-U2-E: the open library's faces speak their receipts into this shell's holder (the owed ones at
        // once — `RoadStandingModel.speak`'s own rule).
        .onAppear { attachProtectionReceipts() }
        .onChange(of: bootstrap?.roadStanding.map { ObjectIdentifier($0) }) { _, _ in attachProtectionReceipts() }
        .task { await starsModel.start() }
        // VM-51: the library's theme — held for the shell's life, so a voice
        // or palette changed on either device lands here and in the editors.
        .task {
            #if DEBUG
            // The walk's palette seam (DEBUG only; nothing without its env).
            await MobileWalkLaunch.applyPalette(session)
            #endif
            await router.theme?.start()
        }
        .task { await wings.track() }
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
    /// push the book's contents onto the VISIBLE stack (VM-53: Settings
    /// opens from every root and a note now, so it is no longer always the
    /// shelf's; the tab itself is deliberately not written — the tab doors
    /// own the liveness handoff).
    private var settingsSheet: some View {
        #if DEBUG
        return MobileSettingsView(
            session: session, router: router, services: services,
            bootstrap: bootstrap,
            onOpenProtection: { openProtection() },
            onOpenTutorialBook: { bookID in
                settingsPresented = false
                push(.book(bookID), in: tab)
            })
        #else
        return MobileSettingsView(
            session: session, router: router, services: services,
            bootstrap: bootstrap,
            onOpenProtection: { openProtection() })
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

    /// **A bar is on screen** (the VM-55 re-land, meeting 2): a root (every
    /// root draws the bar at its foot — the visible stack at its root is
    /// `pagingAllowed`), or a pushed list on the visible stack wearing its own
    /// (VM-52's destination builder — `listBar`). Inside a note, on Read, the
    /// Versions reader and Protection there is none, and the line keeps to the
    /// safe area's foot.
    private var barOnScreen: Bool {
        pagingAllowed || (listBarsShowing[tab] ?? 0) > 0
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
                // VM-52: a LIST — the bar rides its foot.
                .safeAreaInset(edge: .bottom, spacing: 0) { listBar(owner) }
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
                .safeAreaInset(edge: .bottom, spacing: 0) { listBar(owner) }  // VM-52: a list
        case .archive:
            MobileArchiveView(
                model: archiveModel, tokens: tokens,
                onOpen: { push(.note($0, focus: false), in: owner) })
                .safeAreaInset(edge: .bottom, spacing: 0) { listBar(owner) }  // VM-52: a list
        case .versions(let postID):
            // Built per push: a note's moments are that note's, and this
            // screen's whole lifetime is one visit (the read is the note's
            // own version count — never corpus-shaped).
            // VM-52: the bar rides the LISTING (a list) and leaves while a
            // moment's words are read (the reader is her words, not a list).
            MobileVersionsScreen(
                session: session, postID: postID, tokens: tokens,
                listingBar: AnyView(listBar(owner)))
        case .protection:
            // VM-52: NO bar here (PROVISIONAL P-47-18) — not a root, not a
            // list, and while new words are held on screen it gives no way off
            // it but her close (the screen's `navigationBarBackButtonHidden`);
            // a tab would be one.
            // VM-8 unit 1: the bootstrap's standing faces (kept across every reopen with the presenter and the account
            // section's model); the services for the Account sheet.
            MobileProtectionScreen(standing: bootstrap?.roadStanding, services: services, tokens: tokens)
                // VM-8 unit 2 — F-U2-E: the receipts the open library's faces spoke (P-VM8-8).
                .environment(protectionReceipts)
        }
    }

    /// **VM-8 unit 2 — F-U2-E (PROVISIONAL P-VM8-8): THE PROTECTION RECEIPTS' PHONE HOME.** The open library's faces speak
    /// through `RoadStandingModel.speak` (the Mac's ready window hands it the status seam); the phone hands it this shell's
    /// holder, which the Protection screen shows. Setting it speaks the receipts the open owes at once (rule 1's restore
    /// receipt, the key-file offer's, a crossing's or a re-keying account act's owed to its reopen).
    private func attachProtectionReceipts() {
        guard let standing = bootstrap?.roadStanding else { return }
        let receipts = protectionReceipts
        standing.speak = { text in receipts.say(text) }
    }

    /// **VM-8 unit 1 — F-U1-3: SETTINGS ASKED BACK TO PROTECTION** (VX-206's road, the Mac's `AppSettingsView
    /// .adoptProtectionRequest` idiom). A re-keying act from the Protection screen — her join into her Castle account —
    /// reopens the library: the `.ready` tree goes down (this shell and the pushed screen with it) and comes back fresh,
    /// while the act's confirm (its words moment, its first round) lives on in the bootstrap's presenter. The reopen asks
    /// for Protection back (`requestProtectionPaneForRoadCrossing`); this shell adopts each ask ONCE (the controller's
    /// counter and its "adopted" mark both live on the controller, which outlives the shell) and pushes the screen again on
    /// the shelf's stack, where the standing sheet presents again.
    private func adoptProtectionRequest() {
        guard let protection = bootstrap?.protection, Self.adoptsProtectionRequest(protection) else { return }
        settingsPresented = false
        if tab != .shelf { selectPage(.shelf) }
        shelfPath = NavigationPath([MobileRoute.protection])
    }

    /// The adoption rule, pinnable: an ask newer than the last adopted one is adopted ONCE (and marked so); every other
    /// read adopts nothing.
    static func adoptsProtectionRequest(_ protection: ProtectionController) -> Bool {
        guard protection.settingsRequest > protection.settingsRequestAdopted else { return false }
        protection.settingsRequestAdopted = protection.settingsRequest
        return true
    }

    /// VM-8 unit 1 — Settings' *Protection…* door: Settings goes, the screen is pushed on the VISIBLE stack (VM-53 —
    /// Settings opens from every root and from a note now, so the screen lands where she is and Back returns her there;
    /// it was the shelf's, when Settings was the shelf's own door). Leaving the shelf files the quick-note box first
    /// (A5-8); on another root the box is already filed. PROVISIONAL P-47-23.
    private func openProtection() {
        settingsPresented = false
        let here = tab
        leavingShelf { push(.protection, in: here) }
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

    /// **The bottom bar** (VM-52, her LK-5 — "Words on a chip"): Starred ·
    /// Bookcase · Library, the current one on a chip, 56 pt targets — the
    /// face is `MobileTabBar`. Each root draws it at its foot and the
    /// destination builder gives it to every pushed LIST, so a note pushed
    /// over a list covers it ("Roots and lists, not notes").
    ///
    /// **It IS the band's index** (batch 10): its doors are in
    /// `MobileShellBand.pages` order, so what the bar shows and what a swipe
    /// traverses are one arrangement — and a page reachable only by a gesture
    /// would be a page a VoiceOver user cannot reach at all.
    private var tabBar: some View {
        MobileTabBar(current: tab, tokens: tokens, select: { tabSelected($0) })
            // VM-61: the message line sits above the bar's doors — measured on
            // the bar itself (re-attached here at the VM-55 re-land: VM-55's
            // measurement rode the old `tabBar` body, which `MobileTabBar`
            // replaced). Every copy of the bar is one height.
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { tabBarHeight = $0 }
    }

    /// **A pushed list's bar** — the bar, counted while it shows (it appears
    /// with its list and leaves when a note is pushed over the list, the list is
    /// popped, or the Versions reader replaces its listing), so `barOnScreen`
    /// knows the one line has a bar to clear on this stack.
    private func listBar(_ owner: MobileTab) -> some View {
        tabBar
            .onAppear { listBarsShowing[owner, default: 0] += 1 }
            .onDisappear { listBarsShowing[owner, default: 0] -= 1 }
    }

    /// **A TAB TAP RETURNS TO THAT ROOT** (VM-52 — the ticket's "changing
    /// room means backing out first", answered). The page change itself is
    /// `selectPage`, the ONE road a swipe also takes (the liveness handoff,
    /// A5-8's leaving-files-it rule and the settle all live there).
    ///
    /// · The CURRENT tab, from a pushed list: back to its root (the system's
    ///   own tab grammar).
    /// · Another tab: the stack being left returns to ITS root first, then
    ///   the page changes. So a hidden stack always stands at its root
    ///   (PROVISIONAL P-47-19) — the band never reveals a pushed screen, a page
    ///   change always lands on a root, and nothing she left open in another
    ///   room keeps a note mounted behind the one on screen. (The bar shows
    ///   on lists only, so the screen she taps from is never a note; a note
    ///   BELOW a list — Versions pushed over its note — closes exactly as
    ///   Back would close it, its leaving road and savepoint included.)
    private func tabSelected(_ target: MobileTab) {
        let leaving = tab
        guard target != leaving else {
            popToRoot(leaving, animated: true)
            return
        }
        popToRoot(leaving, animated: false)
        selectPage(target)
    }

    /// One stack back to its root — the OWNING stack's path, by the S3 rule.
    /// Unanimated when the page is leaving (the slide is the motion).
    private func popToRoot(_ owner: MobileTab, animated: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        withTransaction(transaction) {
            switch owner {
            case .starred: if !starredPath.isEmpty { starredPath = NavigationPath() }
            case .shelf: if !shelfPath.isEmpty { shelfPath = NavigationPath() }
            case .library: if !libraryPath.isEmpty { libraryPath = NavigationPath() }
            }
        }
    }
}
