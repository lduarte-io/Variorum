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
                // 13g R5-12: this window has no sidebar, so the mode row
                // rides the masthead here (and only here).
                PostDetailView(session: session, postID: postID, showsModeSwitcher: true)
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

// MARK: - R5-11, the clipped top: REPRODUCED AND TRACED, DELIBERATELY NOT
// FIXED IN THIS BATCH (13g batch 6)
//
// Her report: *"opening in a new window seems to be working pretty well but
// there is this bug where the top of it i couldn't scroll to (where it says
// Untitled) and it was cut off."*
//
// REPRODUCED on HEAD, deterministically: open a note that is IN A BOOK (so
// the context bar renders) in a note-only window — the masthead's title is
// clipped along its top edge. Facts measured, so the next attempt starts
// where this one stopped:
//
//   · it clips at 720 tall AND at 900, so it is NOT an overflow;
//   · it clips at 760 wide and is clean at 800+ — but ONLY because the
//     resize itself repairs it: back at 760 after a resize it is clean, and
//     it stays clean forever. **Any resize is the repair**, which is exactly
//     why she could not scroll to it;
//   · the LAYOUT is correct and converges inside the first presentation —
//     instrumented with `onGeometryChange` on the masthead's own frames
//     (stderr): hstack 38 → 38 → **44**, title 23 → 23 → **29** — and the
//     repairing resize emits **no new geometry at all**. The numbers are
//     right; the picture is the first pass's;
//   · a temporary red border on the masthead frame showed its top edge
//     missing with the title above it — consistent with the whole subtree
//     being CLIPPED near the window's top, not with a short frame (an
//     earlier reading of that same capture said "short frame" and was
//     wrong — recorded so it is not re-derived).
//
// THREE FIXES BUILT AND MEASURED WRONG, each reverted rather than shipped
// (the hallucination guard: a fix that does not discriminate is not a fix):
//   1. `.toolbar(removing: .title)` + `.unifiedCompact` here (batch 1's
//      treatment for the main window) — the band went, the clip stayed;
//   2. the masthead's `.firstTextBaseline` → `.center` — identical clip;
//   3. a one-shot AppKit repaint after the window exists
//      (`layoutSubtreeIfNeeded` + `setNeedsDisplay` + `displayIfNeeded` on
//      the content view, next runloop turn) — identical clip at launch.
//
// What is still unexplained is what the resize invalidates that none of
// those three do. The main window never shows this, and the one structural
// difference is that its pane row is a `GeometryReader` that re-proposes.
// ROUTED, with this trace, to 13e's kickoff sweep beside the
// windowless-launch row — the same window/lifecycle first-layout family —
// rather than patched on suspicion.
