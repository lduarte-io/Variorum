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
//  (⌘⇧1–9 grey), `canNavigateBack`/`Forward` are false (⌥⌘[ / ⌥⌘] grey),
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
    /// 13n-c U3: the app's MCP door — this window composes its own
    /// `MCPShareRoad` (the in-note indicator and the note ▾ menus' share
    /// faces render here too — R118), and presents its own grant sheet.
    var mcp: MCPDoor? = nil

    /// Its own router — and therefore its own workspace, its own context-bar
    /// fold. The same per-window ownership `RootView` gained this batch.
    @State private var router = ShellRouter()
    @State private var windowID = UUID()
    @State private var theme: ThemeStore
    /// 13i-d U6 (k): this window's own wings model, so the note ▾ menu's
    /// cross-wing doors render here too (R118 — no surface is behind
    /// another); `RootView` hands its own to the main windows.
    @State private var wings: WingsModel
    /// 13l Act 2 (item 3): its own AppKit window, so a delete of the one note
    /// it shows can close it. Handed over by `WindowKeyReporter`, which
    /// already reports it to the registry.
    @State private var window: NSWindow?
    @Environment(\.colorScheme) private var scheme
    @State private var mcpGrantSheet: MCPGrantOpening?
    /// 13n-c U4 — the ask HER press opened in this window (RootView's twin).
    @State private var mcpAskSheetOpening: MCPAskOpening?

    init(session: AppSession, windows: WindowRegistry, postID: String, mcp: MCPDoor? = nil) {
        self.session = session
        self.windows = windows
        self.postID = postID
        self.mcp = mcp
        _theme = State(initialValue: ThemeStore(session: session))
        _wings = State(initialValue: WingsModel(session: session))
    }

    /// 13n-c U3 — this window's `MCPShareRoad` (`RootView.mcpRoad`'s twin).
    private var mcpRoad: MCPShareRoad? {
        guard let mcp else { return nil }
        let router = router
        let theme = theme
        return MCPShareRoad(
            canShare: mcp.hasApprovedClient,
            indicatorOn: mcp.hasApprovedClient && mcp.serverOn,
            open: { router.mcpGrantRequest = $0 },
            sheet: { opening, done in
                AnyView(MCPGrantSheet(door: mcp, opening: opening, done: done).environment(theme))
            },
            revoke: { await mcp.revokeFromReceipt($0) },
            // 13n-c U4 — ARRIVAL X: a pending glyph's press opens its ask here.
            answerAsk: { router.mcpAskRequest = $0 })
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
            // No history here (the ruling), so the ← and → are grey and
            // neither can be reached. 13k K11 makes them VISIBLE-and-grey
            // rather than absent, which is the same honesty the window's
            // four app-scope greys already carry.
            onBack: {},
            onForward: {},
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
                    // 13u3 UNIT A1: the workspace pane's twin — the 20 pt
                    // padding becomes the surface's gutter, the prose does
                    // not move.
                    ReadPostView(session: session, postID: postID, gutter: .pane)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(tokens.surface)
            }
        }
        .environment(theme)
        .environment(wings)
        // 13n-c U3: this window's road and its grant sheet (RootView's shape).
        .environment(\.mcpShareRoad, mcpRoad)
        .sheet(item: $mcpGrantSheet) { opening in
            if let mcp {
                MCPGrantSheet(door: mcp, opening: opening) { mcpGrantSheet = nil }
                    .environment(theme)
                    .environment(\.mcpShareRoad, mcpRoad)
            }
        }
        .onChange(of: router.mcpGrantRequest) { _, request in
            guard let request else { return }
            mcpGrantSheet = request
            router.mcpGrantRequest = nil
        }
        // 13n-c U4 — the waiting asks (the in-note indicator's pending leg and
        // the bar's note ▾ glyph read them) and the ask her press opened.
        .environment(\.mcpAskBoard, mcp?.askBoard ?? .empty)
        .mcpAskSheet(door: mcp, opening: $mcpAskSheetOpening, theme: theme)
        .onChange(of: router.mcpAskRequest) { _, request in
            guard let request else { return }
            // W-UX-1: THE raise waiting now — a later equal raise is never it.
            mcpAskSheetOpening = mcp?.opening(request)
            router.mcpAskRequest = nil
        }
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
                onWindow: {
                    window = $0
                    windows.attach($0, to: windowID)
                },
                onKey: { windows.noteKey(windowID) })
        }
        // 13l Act 2 (item 3) — the navigate-away, in the one shape this
        // window has. It shows exactly one note and navigates NOWHERE (the
        // ruling's (d)), so "get off the deleted note" can only mean CLOSING:
        // there is no other destination, and a lightweight window rendering a
        // tombstone is the standing-on-a-tombstone failure with no way out of
        // it. `onDisappear` still runs, so its teardown savepoint is
        // unaffected — and `closeAutoCommit` no-ops on a dead container by
        // its own guard, so the leaving writes nothing for a note that just
        // went.
        .onReceive(NotificationCenter.default.publisher(for: .variorumNotesDeleted)) { note in
            guard let ids = note.userInfo?["postIDs"] as? [String],
                  ids.contains(postID)
            else { return }
            window?.close()
        }
        .task { await theme.start() }
        .task { await wings.track() }
        .onAppear {
            // `showOnly` and not `select`: this window shows one note and
            // records nothing, which is what makes the greys above honest.
            router.workspace.showOnly(.post(postID))
            windows.register(windowID, router: router, kind: .noteOnly)
            let status = session.status
            router.refuse = { status.refuse($0) }
        }
        .onDisappear {
            windows.unregister(windowID)
            // 13j J11: this window shows exactly one note and never
            // navigates, so its whole leaving story is its teardown.
            SavepointOnLeave.leaving([postID], session: session)
        }
    }
}

// MARK: - R5-11, the clipped top: MECHANISM FOUND AND CLOSED (13e batch 8,
// rider 1 — the diagnosis pass over the 13g trace below)
//
// **It does not reproduce on HEAD, and 13k K11 is why.** The trace kept
// below stopped at "what does the resize invalidate that none of the three
// fixes do"; the answer was upstream of the repair. At the 13g tree
// `ContextBar.hasContent` read
//
//     var hasContent: Bool { originLabel != nil || !books.isEmpty }
//
// and this window has NO history, so `originLabel` is always nil (see
// `onBack: {}` above — the back half is honestly empty). That left
// `!books.isEmpty`, and `books` is filled by `PaneHost`'s
// `.task(id: noteID) { await loadBooks() }` — AFTER the first presentation.
// So for a note IN A BOOK the bar and its divider were inserted ABOVE the
// masthead one runloop late, the already-presented pixels were never
// re-composited for the insertion, and the masthead's top rode under the
// band that had appeared over it. Any resize redisplays the content and
// repairs it permanently — her "I couldn't scroll to it", exactly. It also
// explains the reproduction's odd precondition (*a note IN A BOOK, so the
// context bar renders*): a bookless note grew no bar and never clipped.
//
// PROVEN BY BEHAVIORAL REVERT ON THE LIVE APP (2026-08-18): HEAD draws the
// masthead whole; restoring the expression above and rebuilding reproduced
// the clip exactly (title, "Write ▾" and the inspector icons all sliced along
// their top edge), and one resize repaired it permanently. K11's rebuilt bar
// gained `isNote`, so the bar is there on the first pass and nothing arrives
// above the masthead afterwards. `NoteWindowFirstPassTests` pins that
// property — it is red on the 13g rule — because the fix was a side effect
// nobody knew they had made.
//
// The 13g trace stays below, unedited, as the record of what was ruled out.
//
// ── (13g batch 6's record) REPRODUCED AND TRACED, DELIBERATELY NOT
// FIXED IN THAT BATCH
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
