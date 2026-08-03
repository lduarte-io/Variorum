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
    case book(String)
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
            stack(path: $shelfPath) {
                MobileShelfView(
                    model: shelfModel, tokens: tokens,
                    tabBar: { tabBar },
                    onOpenBook: { shelfPath.append(MobileRoute.book($0)) },
                    onOpenToday: { shelfPath.append(MobileRoute.note($0, focus: true)) },
                    onSettings: { settingsPresented = true })
            }
            .opacity(tab == .shelf ? 1 : 0)
            .allowsHitTesting(tab == .shelf)
            .accessibilityHidden(tab != .shelf)

            stack(path: $libraryPath) {
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
            MobileSettingsView(router: router, services: services)
        }
        #if DEBUG
        .fullScreenCover(isPresented: $spikePresented) { SpikeScreen() }
        #endif
    }

    /// One tab's navigation stack: a voiced root + the shared route
    /// destinations.
    private func stack<Root: View>(
        path: Binding<NavigationPath>, @ViewBuilder root: () -> Root
    ) -> some View {
        NavigationStack(path: path) {
            root()
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: MobileRoute.self) { route in
                    destination(route)
                }
        }
    }

    @ViewBuilder
    private func destination(_ route: MobileRoute) -> some View {
        switch route {
        case .book(let readingID):
            MobileBookView(
                session: session, readingID: readingID, tokens: tokens,
                onOpen: { postID in
                    if tab == .shelf {
                        shelfPath.append(MobileRoute.note(postID, focus: false))
                    } else {
                        libraryPath.append(MobileRoute.note(postID, focus: false))
                    }
                })
        case .note(let postID, let focus):
            MobileWriteScreen(
                session: session, postID: postID, router: router, beginEditing: focus)
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
            tab = target
        } label: {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(tab == target ? tokens.ink : tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(tab == target ? .isSelected : [])
    }
}
