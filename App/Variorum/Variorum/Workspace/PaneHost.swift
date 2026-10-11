//
//  PaneHost.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 4 (W1/A25 — the SPLIT): one pane's CHROME, around
//  whatever the shell renders inside it.
//
//  The chrome split is the gate's ruling (d):
//
//  - **Per pane:** the CONTEXT BAR (batch 3 put the back chip in the shell
//    rather than in `PostDetailView` precisely because "where did I come
//    from" is the PANE's fact; batch 5 gave it its second half — "in
//    <book>" — for the same reason, and 13k K11 made both, plus the tag
//    door and a real forward door, one constant icon row), and —
//    when the pane is NOT focused — a quiet name line, because a focused
//    pane brings its own masthead and an unfocused one would otherwise be
//    anonymous. **The difference between a full masthead and a thin name
//    line IS the focus signal**, which is a better thing to have than a
//    border.
//  - **Per window** (and therefore not here): the sidebar, the status
//    toast, the ⌘K palette.
//
//  Nothing in this file decides anything: the mount fork is `PaneMount`'s
//  and the shell's, the chip's arithmetic is `NavigationHistory`'s, and the
//  books' order is `BookChooserOrder`'s.
//

import GRDB // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

struct PaneHost<Content: View>: View {
    let tokens: VoiceTokens
    /// 13f batch 5 (W20 b): the bar's "in <book>" half needs one read, and
    /// this is the only chrome that knows which note the pane holds.
    let session: AppSession
    let workspace: WorkspaceModel
    let pane: PaneID
    /// True for exactly one pane (`PaneMount.liveCount`), and the reason
    /// this one shows a masthead-bearing detail and the others do not.
    let focused: Bool
    /// Whether a split exists at all — with one pane there is nothing to
    /// signal, so the name line stays away and the chrome reads as it did
    /// before the split existed.
    let split: Bool
    let onBack: () -> Void
    /// 13k K11: the → is a real forward door now — ⌥⌘]'s face (R4-1
    /// replaced the chevron: it read as the ＃'s expander).
    let onForward: () -> Void
    let onFocus: () -> Void
    /// The ascent (W20 a): open this book, revealed at this note.
    let onOpenBook: (String, String) -> Void
    @ViewBuilder let content: () -> Content

    /// The pane note's books, ordered. A ONE-SHOT read keyed on what is
    /// shown (the shipped `PostTitleLabel` / `MembershipChip` precedent) and
    /// deliberately NOT a held observation: `readingsContaining` walks every
    /// smart book's filter, and a held one would re-run that sweep at
    /// autosave rate on a table autosave writes (P1). The recorded corner:
    /// adding or removing a book elsewhere does not re-title this line until
    /// the pane's note next changes.
    @State private var books: [Reading] = []

    // (The tag half LEFT this host at Act 10 item 5 — the cards, their
    // loaders and their doors live in `MastheadTagCluster` on the masthead's
    // right edge now, her ruling.)

    /// 13j J2 — the tray badge's counts. Unlike `books`/`tags` above this
    /// IS a held observation, and deliberately so: the badge's whole job is
    /// to appear the moment she deletes a block, which is the one event a
    /// one-shot read keyed on the pane's note would never see.
    ///
    /// It is affordable because `Queries.trayCounts` reads `block`,
    /// `container_block` and `container` and never `variant` — so the
    /// observation does not re-run at autosave rate on the table autosave
    /// writes (its own doc comment carries the reasoning).
    @State private var trayCounts = Queries.TrayCounts(deleted: 0, preservedOriginals: 0)

    /// The note this pane holds, if it holds one (a scraps container counts
    /// — it is a container with memberships like any other).
    private var noteID: String? { workspace.selections[pane]?.noteID }

    /// Only a NOTE wears tags. A pane at the shelf, the library, a book or
    /// the recovery surface gets no tag half at all (P-2: a door that cannot
    /// act in its context isn't rendered).
    private var notePostID: String? {
        guard case .post(let id) = workspace.selections[pane] else { return nil }
        return id
    }

    var body: some View {
        VStack(spacing: 0) {
            let history = workspace.history(pane)
            let bar = ContextBar(
                tokens: tokens,
                originLabel: history.origin.map { workspace.label(for: $0) },
                forwardLabel: history.next.map { workspace.label(for: $0) },
                books: books,
                isNote: notePostID != nil,
                trayFace: notePostID.map { postID in
                    ContextBar.TrayFace(
                        deletedCount: trayCounts.deleted,
                        onOpen: { openTray(postID) })
                },
                // 13n-c U3 — VX-164 (R-AIR-7): the in-note MCP indicator at the
                // bar's trailing end, a NOTE's only (it gates itself on the
                // window's road: the server ON and an approved client).
                trailing: notePostID.map { postID in
                    AnyView(MCPNoteIndicator(session: session, postID: postID, tokens: tokens))
                },
                onBack: onBack,
                onForward: onForward,
                onOpenBook: { bookID in
                    guard let noteID else { return }
                    onOpenBook(bookID, noteID)
                })
            if bar.hasContent {
                // The badge's popover is GONE (the post-13l polish round,
                // ledger row 9 — the kickoff's C1 small call): the badge stays
                // as the glance signal and opens THE SAME side panel the
                // masthead's tray icon opens. Two doors, one panel, zero
                // choreography drift.
                bar
                Divider().overlay(tokens.line)
            }
            if split, !focused, let selection = workspace.selections[pane] {
                nameLine(selection)
                Divider().overlay(tokens.line)
            }
            content()
        }
        // 13g L6 (WT-6): clicking ANYWHERE in an unfocused pane makes it the
        // live one — the name line's promise, made true for every content
        // surface at once rather than for the two that happened to carry
        // their own door. A background, so it draws nothing and eats
        // nothing; see `PaneFocusCatcher` for the trace and the reasoning.
        .background {
            PaneFocusCatcher(active: split && !focused, onFocus: onFocus)
        }
        .task(id: noteID) { await loadBooks() }
        .task(id: notePostID) { await watchTray() }
    }

    /// **The badge's act** (the post-13l polish round, ledger row 9): open
    /// this pane's note's tray — in the SIDE PANEL, which is the detail's,
    /// not this bar's.
    ///
    /// The pane is focused FIRST, and that is the whole subtlety: an
    /// unfocused pane renders read-cheap, so there is no `PostDetailView`
    /// mounted to hold an inspector. The request is parked on the router
    /// (stamped with its post) and the arriving detail consumes it on
    /// registration — the `pendingWriteIntent` choreography, one act over.
    /// Focusing an already-focused pane is a no-op, so the ordinary case
    /// costs nothing.
    private func openTray(_ postID: String) {
        let request = TrayRequest(postID: postID)
        if session.commandRouter.requestNoteTray(request) { return }
        // Not mounted: focus this pane and let the arriving detail consume it.
        onFocus()
        session.commandRouter.pendingTrayRequest = request
    }

    /// 13j J2 — the badge's live counts (see `trayCounts`' own note for why
    /// this one is held where its siblings are one-shot).
    private func watchTray() async {
        guard let postID = notePostID else {
            trayCounts = Queries.TrayCounts(deleted: 0, preservedOriginals: 0)
            return
        }
        do {
            for try await value in session.database.observeTrayCounts(postID, now: session.now) {
                trayCounts = value
            }
        } catch {
            // A failed observation leaves the badge away rather than
            // showing a number it cannot stand behind.
            trayCounts = Queries.TrayCounts(deleted: 0, preservedOriginals: 0)
        }
    }

    private func loadBooks() async {
        guard let noteID else {
            books = []
            return
        }
        let found = (try? await session.database.read { db in
            try Queries.readingsContaining(db, postID: noteID)
        }) ?? []
        books = BookChooserOrder.ordered(found, recentlyVisited: workspace.recentBookIDs)
    }

    /// The quiet name line an unfocused pane wears in place of a masthead.
    /// `lineLimit(1)` on the name is P-8's chrome rule (the b6dae25 class:
    /// an unlimited `fixedSize` text in chrome inflates the window's
    /// min-height probe).
    private func nameLine(_ selection: SidebarSelection) -> some View {
        HStack(spacing: 6) {
            Text(tokens.chromeLabel(WorkspaceNaming.paneLine(
                workspace.label(for: selection), mode: heldMode(selection))))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
            Text(tokens.chromeLabel("click to edit"))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(tokens.surface)
        .contentShape(Rectangle())
        .onTapGesture(perform: onFocus)
        .help(heldMode(workspace.selections[pane] ?? .shelf).map {
            "This pane is holding \(WorkspaceNaming.paneLine("this note", mode: $0)) — "
                + "click anywhere in it to write here, and it opens back into "
                + "\($0.rawValue)"
        } ?? "This pane is showing — click anywhere in it to write here")
    }

    /// 13g L5 (WT-5/F-4): the mode this pane is HOLDING, read from the very
    /// source the pane restores from when it goes live again
    /// (`PostDetailView.rememberedMode`, the per-note memory since S4-20).
    ///
    /// Deliberately NOT a second piece of state. A `modes[PaneID]` field
    /// beside this one could disagree with what the detail actually restores
    /// — and a mode row that lies is worse than no mode row. Reading the one
    /// source makes "sticky" true by construction rather than by upkeep.
    /// It is re-read whenever this line renders, which is whenever the pane
    /// changes what it holds or which pane is live.
    private func heldMode(_ selection: SidebarSelection) -> PostMode? {
        guard case .post(let postID) = selection else { return nil }
        return PostDetailView.rememberedMode(postID: postID)
    }
}
