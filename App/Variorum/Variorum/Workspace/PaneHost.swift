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
//    <book>" — for the same reason, and the two fold as ONE bar), and —
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
    let onToggleCollapse: () -> Void
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

    /// 13g batch 7 (R6-1): the note's tags and the live taxonomy behind the
    /// `＋`. Same one-shot discipline as `books` and for the same reason —
    /// a held observation on `post_tag` would re-read at write rate; this
    /// re-reads when the pane's note changes and after her own add/remove,
    /// which are the only two ways it moves from here.
    @State private var tags: [Tag] = []
    @State private var allTags: [Tag] = []

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
            let bar = ContextBar(
                tokens: tokens,
                originLabel: workspace.history(pane).origin.map { workspace.label(for: $0) },
                books: books,
                collapsed: workspace.contextBarCollapsed,
                tagFace: notePostID.map { postID in
                    ContextBar.TagFace(
                        tags: tags, allTags: allTags,
                        onApply: { path in apply(path, to: postID) },
                        onRemove: { tag in remove(tag, from: postID) })
                },
                onBack: onBack,
                onOpenTopBook: {
                    guard let noteID, let top = books.first else { return }
                    onOpenBook(top.id, noteID)
                },
                onToggleCollapse: onToggleCollapse)
            if bar.hasContent {
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
        .task(id: notePostID) { await loadTags() }
    }

    // MARK: - The tag half (13g batch 7, R6-1)

    private func loadTags() async {
        guard let postID = notePostID else {
            tags = []
            allTags = []
            return
        }
        let read = try? await session.database.read { db in
            (applied: try Queries.postTags(db, postID: postID),
             all: try Queries.allTags(db))
        }
        tags = read?.applied ?? []
        allTags = read?.all ?? []
    }

    /// Applying a typed path goes through the SHIPPED type-to-create door
    /// (`TagAssignmentViewModel.applyTypedPath`, 13b 3D's N24), so the
    /// hierarchy walk, the per-segment creation and the
    /// already-applied-is-a-no-op rule are the one implementation the sheet
    /// has always used — this face adds no tag semantics of its own.
    private func apply(_ path: String, to postID: String) {
        let model = TagAssignmentViewModel(session: session, postID: postID)
        Task {
            if await model.applyTypedPath(path) == nil, let error = model.lastError {
                session.status.speak(error)
            }
            await loadTags()
        }
    }

    private func remove(_ tag: Tag, from postID: String) {
        Task {
            do {
                try await session.runner.run { ops in
                    try ops.removeTag(tag.id, fromPost: postID)
                }
            } catch {
                session.status.speak(TagsViewModel.message(error))
            }
            await loadTags()
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
