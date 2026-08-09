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
}

enum MobileTab {
    case shelf
    case library
}

struct MobileShellView: View {
    let session: AppSession
    let services: AppServices?
    let router: MobileShellRouter

    @State private var tab: MobileTab = .shelf
    @State private var shelfPath = NavigationPath()
    @State private var libraryPath = NavigationPath()
    @State private var shelfModel: MobileShelfViewModel
    @State private var libraryModel: MobileLibraryViewModel
    @State private var settingsPresented = false
    @Environment(\.colorScheme) private var scheme
    #if DEBUG
    // Stage 0 TK2 spike auto-run (KEPT — the executable §5 form).
    @State private var spikePresented = SpikeLaunch.autoRunRequested || SpikeLaunch.uiTestBenchRequested
    #endif

    init(session: AppSession, services: AppServices?, router: MobileShellRouter) {
        self.session = session
        self.services = services
        self.router = router
        _shelfModel = State(initialValue: MobileShelfViewModel(session: session))
        _libraryModel = State(initialValue: MobileLibraryViewModel(session: session))
    }

    private var tokens: VoiceTokens {
        .resolve(voice: router.voice, dark: scheme == .dark)
    }

    var body: some View {
        ZStack {
            stack(path: $shelfPath, owner: .shelf) {
                MobileShelfView(
                    model: shelfModel, tokens: tokens,
                    tabBar: { tabBar },
                    onOpenBook: { shelfPath.append(MobileRoute.book($0)) },
                    onOpenForWriting: { shelfPath.append(MobileRoute.note($0, focus: true)) },
                    onSettings: { settingsPresented = true })
            }
            .opacity(tab == .shelf ? 1 : 0)
            .allowsHitTesting(tab == .shelf)
            .accessibilityHidden(tab != .shelf)

            stack(path: $libraryPath, owner: .library) {
                MobileLibraryView(
                    model: libraryModel, tokens: tokens,
                    tabBar: { tabBar },
                    onOpen: { libraryPath.append($0) })
            }
            .opacity(tab == .library ? 1 : 0)
            .allowsHitTesting(tab == .library)
            .accessibilityHidden(tab != .library)
        }
        .sheet(isPresented: $settingsPresented) {
            settingsSheet
        }
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
            onOpenTutorialBook: { bookID in
                settingsPresented = false
                shelfPath.append(MobileRoute.book(bookID))
            })
        #else
        return MobileSettingsView(session: session, router: router, services: services)
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
                onRead: { push(.bookRead(readingID), in: owner) })
        case .bookRead(let readingID):
            MobileReadView(
                session: session, readingID: readingID, tokens: tokens,
                onOpen: { push(.note($0, focus: false), in: owner) })
        case .note(let postID, let focus):
            MobileWriteScreen(
                session: session, postID: postID, router: router,
                beginEditing: focus, tab: owner)
        }
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
            Task { await editors.tabDidBecomeVisible(target) }
        } label: {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(tab == target ? tokens.ink : tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(tab == target ? .isSelected : [])
    }
}
