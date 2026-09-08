//
//  SidebarNoteBox.swift
//  Variorum (Mac)
//
//  18d batch 1 — THE FACE of the sidebar's note box (her U-10; mockup figure
//  C). It stands exactly where the "this note" rail stands for a note, at the
//  rail's exact height, while a book is open in an editing mode.
//
//  ── WHAT THIS VIEW OWNS, AND WHAT IT IS HANDED ───────────────────────────
//  It owns the box: the frame, the header, the identity, the facts, the empty
//  state, the door, the editing mark, the footer's place. It is HANDED the
//  bar — the live editor's own `CommitBar`, built by `RootView` from the
//  registered live editor and passed down as a view to render. The sidebar
//  never constructs or holds an `EditorViewModel`; rendering a sibling's view
//  is legal composition (CLAUDE.md's P39 refinement), and this is the seam
//  that keeps it so.
//
//  ── WHY THE HEIGHT IS A PARAMETER ────────────────────────────────────────
//  Her ruling measures the box against the rail — *"measured to take up the
//  same amount of room"* — and the whole point is that the Open strip below
//  never moves: not between a note and a book, and not between the box's
//  three states. So the box NEVER sizes to its content: the COLUMN frames it
//  at `SidebarLayout.railGroupHeight` (the column is what knows the rail's
//  arithmetic), and where a state wants more room than that — a two-line
//  title in a 180-pt column — its content scrolls INSIDE the box rather than
//  growing it.
//

import SwiftUI

struct SidebarNoteBox: View {
    let tokens: VoiceTokens
    let state: NoteBoxState
    /// What the BOOK knows about the note (nil while the facts have not
    /// arrived, or in the empty state).
    let identity: NoteBoxIdentity?
    /// What the STORE knows — fetched once per selection, never observed at
    /// keystroke rate (P1; the retired gutter's own cadence).
    let facts: NoteBoxFacts?
    /// The caret's block, as the bar labels it (`BlockLineLabel`) — nil in a
    /// mode with no full editor, where the box shows the facts instead.
    let caretLabel: String?
    /// "now", for the day rule (injected so a pin holds the rule and not the
    /// machine's clock).
    var now: Date = Date()
    /// The one door out of the read-cheap state.
    var onEditHere: (() -> Void)?
    /// The live editor's bar, built by the shell. nil ⇒ no full editor is
    /// live here (the Index's own liveness is a single block's pane, not an
    /// editor — see `BookNoteBox.livePost`).
    var bar: AnyView?

    /// The mockup's `.box{padding:8px}`, minus the border, so the box's
    /// contents land on exactly the left edge the column's ROW text does
    /// (`groupPadding` + 1 pt of border + this = `rowPadding`'s inset). Her
    /// punchlist 3's *"the items in that pane should all be aligned"*,
    /// applied to a bordered box.
    static let inset: CGFloat = SidebarView.rowPadding - 1
    private static let corner: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    switch state {
                    case .empty:
                        emptyBody
                    case .selected:
                        identityBlock
                        factsBlock
                        Spacer(minLength: 6)
                        editDoor
                    case .live:
                        identityBlock
                        if let bar {
                            bar
                        } else {
                            // A mode whose liveness is a single block's pane
                            // rather than a full editor (the Index): the
                            // facts stay, and the editing mark above says
                            // where the caret is. Recorded, not invented —
                            // the Index has never had a block menu.
                            factsBlock
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding(Self.inset)
        // The COLUMN owns the height (`SidebarLayout.railGroupHeight`, framed
        // by `SidebarView`), because the column is what knows the rail's
        // arithmetic. The box fills it and never asks for more: a state that
        // wants more room scrolls inside, so the Open strip below cannot move.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: Self.corner))
        .overlay(
            RoundedRectangle(cornerRadius: Self.corner)
                .stroke(tokens.line, lineWidth: 1))
        .overlay(alignment: .topTrailing) { editingMark }
#if DEBUG
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
            SidebarGeometry.noteBoxFrame = $0
        }
#endif
    }

    // MARK: - The header (the rail's own, by the row-13 rule)

    /// The rail's header rule, at the box's own edge: the words sit on the
    /// content's text edge, in the accent register, with `headerAir` between
    /// them and what is under them, inside the column's `groupHeaderHeight`
    /// row. Reading the SAME two constants the column budgets is what stops
    /// the box's header and the column's fit math from drifting apart.
    private var header: some View {
        Text(tokens.chromeLabel(NoteBoxCopy.header))
            .font(tokens.small)
            .foregroundStyle(tokens.accent)
            .lineLimit(1)
#if DEBUG
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                SidebarGeometry.noteBoxHeaderFrame = $0
            }
#endif
            .padding(.bottom, SidebarView.headerAir)
            .frame(height: SidebarLayout.groupHeaderHeight, alignment: .bottomLeading)
    }

    // MARK: - State 1

    private var emptyBody: some View {
        VStack(spacing: 4) {
            Text(tokens.chromeLabel(NoteBoxCopy.nothingSelected))
                .font(tokens.navigation)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            Text(tokens.chromeLabel(NoteBoxCopy.nothingSelectedHint))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.horizontal, 2)
        .help(NoteBoxCopy.emptyHelp)
    }

    // MARK: - States 2 and 3 — the identity

    @ViewBuilder private var identityBlock: some View {
        if let identity {
            VStack(alignment: .leading, spacing: 2) {
                Text(identity.title)
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                let line = NoteBoxCopy.whereLine(
                    chapter: identity.chapter, index: identity.index,
                    total: identity.total, block: caretLabel)
                if !line.isEmpty {
                    Text(tokens.chromeLabel(line))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 6)
        }
    }

    // MARK: - State 2 — the facts and the door

    @ViewBuilder private var factsBlock: some View {
        if let facts {
            VStack(alignment: .leading, spacing: 2) {
                factLine(NoteBoxCopy.countsLine(words: facts.words, blocks: facts.blocks))
                if let takes = NoteBoxCopy.takesLine(fannedBlocks: facts.fannedBlocks) {
                    factLine(takes)
                }
                if let stamps = NoteBoxCopy.stampsLine(
                    edited: facts.editedAt, saved: facts.savedAt, now: now) {
                    factLine(stamps)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func factLine(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(2)
            .truncationMode(.tail)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder private var editDoor: some View {
        if let onEditHere {
            Button(action: onEditHere) {
                Text(tokens.chromeLabel(NoteBoxCopy.editDoor))
                    .font(tokens.small)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(tokens.accent, in: RoundedRectangle(cornerRadius: 6))
                    .foregroundStyle(tokens.card)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(NoteBoxCopy.editDoorHelp)
        }
    }

    // MARK: - State 3 — the mark

    @ViewBuilder private var editingMark: some View {
        if state.isLive {
            Text(tokens.chromeLabel(NoteBoxCopy.editingMark))
                .font(tokens.small)
                .foregroundStyle(tokens.ring)
                .lineLimit(1)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(tokens.room, in: RoundedRectangle(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(tokens.ring.opacity(0.4)))
                .padding(4)
                .allowsHitTesting(false)
        }
    }
}
