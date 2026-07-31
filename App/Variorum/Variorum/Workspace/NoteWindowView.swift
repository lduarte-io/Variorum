//
//  NoteWindowView.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 5b (W2/A26) — THE NOTE-ONLY WINDOW, her round-2 pick:
//  *File ▸ New Window = a full app window; "Open in New Window" on a note =
//  a lightweight note-only window.*
//
//  ── WHAT IT CARRIES, AND WHAT IT DELIBERATELY LACKS ──────────────────────
//  (the architect's ruling (d)) It carries the note's own detail — masthead,
//  mode row, inspector — and the CONTEXT BAR, whose "in <book>" half is
//  exactly as useful here as anywhere and whose back half is honestly empty
//  (`ContextBar` renders only what it has, so this needs no special case).
//  It lacks the sidebar, and therefore the Open strip, and the split. **One
//  note is what makes it lightweight.**
//
//  ── EVERY APP-SCOPE ACT IS HONESTLY GREY HERE, THROUGH THE GATES THAT
//     ALREADY EXIST ──────────────────────────────────────────────────────
//  Not one new availability rule was written for this window. Its workspace
//  is set with `showOnly`, which records NOTHING — so `openNoteCount` is 0
//  (⌘⇧1–9 grey), `canNavigateBack`/`Forward` are false (⌘[ / ⌘] grey),
//  `openBesideCandidate` is nil (Open Beside grey) and `panes.count` is 1
//  (Close Split grey). Everything editing-scoped — ⌘S, the structural and
//  take families, find — works exactly as in the main window, because it
//  routes through the app's `CommandRouter` and this window mounts the live
//  detail whenever it is key. That is the registry earning its existence.
//
//  Note-only HISTORY is deliberately not in v1 (the ruling): the workspace
//  is here and one line would give it one, at her word.
//

import SwiftUI
import VariorumCore

struct NoteWindowView: View {
    let session: AppSession
    let windows: WindowRegistry
    let postID: String

    /// Its own router — and therefore its own workspace, its own context-bar
    /// fold. The same per-window ownership `RootView` gained this batch.
    @State private var router = ShellRouter()
    @State private var windowID = UUID()
    @State private var theme: ThemeStore
    @Environment(\.colorScheme) private var scheme

    init(session: AppSession, windows: WindowRegistry, postID: String) {
        self.session = session
        self.windows = windows
        self.postID = postID
        _theme = State(initialValue: ThemeStore(session: session))
    }

    /// THE MOUNT RULE, the same one fork the shell consults — with the
    /// window's key-ness as its second input (batch 5b). A note-only window
    /// beside the one she is typing in mounts NOTHING live.
    private var live: Bool {
        PaneMount.kind(
            of: .primary, focused: router.workspace.focusedPane,
            windowIsKey: windows.isKey(windowID)) == .live
    }

    var body: some View {
        let tokens = theme.tokens(for: scheme)
        PaneHost(
            tokens: tokens, session: session, workspace: router.workspace, pane: .primary,
            focused: live, split: false,
            // No history here (the ruling), so the bar's back half never
            // renders and this can never be reached.
            onBack: {},
            onToggleCollapse: { router.workspace.contextBarCollapsed.toggle() },
            onFocus: {},
            // The ascent from a note-only window: it names the book, and the
            // app's navigation TARGET — a full window — opens it and raises
            // itself (`RootView.claimBroadcast`). A lightweight window shows
            // no books itself; it must not therefore hold a dead door.
            onOpenBook: { bookID, postID in
                MembershipChip.ascend(bookID: bookID, postID: postID)
            }
        ) {
            if live {
                PostDetailView(session: session, postID: postID)
                    .id(postID)
            } else {
                ScrollView {
                    ReadPostView(session: session, postID: postID)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(tokens.surface)
            }
        }
        .environment(theme)
        // AD-14's one status presentation, in this window too — a refusal
        // fired here has to be visible here.
        .overlay(alignment: .bottom) {
            if let item = session.status.current {
                StatusToast(
                    item: item, tokens: tokens,
                    onDismiss: { session.status.clear() })
                    .padding(.bottom, 24)
            }
        }
        .background {
            WindowKeyReporter(
                onWindow: { windows.attach($0, to: windowID) },
                onKey: { windows.noteKey(windowID) })
        }
        .task { await theme.start() }
        .onAppear {
            // `showOnly` and not `select`: this window shows one note and
            // records nothing, which is what makes the greys above honest.
            router.workspace.showOnly(.post(postID))
            windows.register(windowID, router: router, kind: .noteOnly)
            let status = session.status
            router.speak = { status.speak($0) }
        }
        .onDisappear { windows.unregister(windowID) }
    }
}
