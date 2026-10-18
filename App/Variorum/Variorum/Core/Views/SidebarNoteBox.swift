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
import VariorumCore

struct SidebarNoteBox: View {
    /// 13i-c U4: the box's context menu renders the remove/release door
    /// (§20 — "the sidebar note box's book context").
    static let contextMenuCapabilities: [CapabilityID] = [.removeFromBook]

    let tokens: VoiceTokens
    /// **Whose box this is** — the book it belongs to. Its one job is the
    /// DEBUG oracles' key (the 18d ladder's MINOR-3: suites run in parallel,
    /// so a pin must read ITS box's rectangles, never the last box drawn
    /// anywhere). Production passes the report's `readingID`.
    let subjectKey: String
    let state: NoteBoxState
    /// What the BOOK knows about the note (nil while the facts have not
    /// arrived, or in the empty state).
    let identity: NoteBoxIdentity?
    /// What the STORE knows — fetched once per selection, never observed at
    /// keystroke rate (P1; the retired gutter's own cadence).
    let facts: NoteBoxFacts?
    /// The caret's block, as the bar labels it (`BlockLineLabel`) — nil in a
    /// mode with no full editor, where the box shows the facts instead.
    ///
    /// **A CLOSURE, deliberately, and evaluated inside THIS view's body**
    /// (the round-end Fable pass, MAJOR-1). The label reads the live
    /// editor's `caretOrdinal`/`blockCount`, which `updateCaretContext`
    /// rewrites on EVERY keystroke — and Observation registers an access
    /// against whichever body is evaluating when it happens. As a VALUE the
    /// shell computed it inside `ShellSplit`'s sidebar closure, so every
    /// keystroke in a book note re-ran the whole shell: the sidebar column
    /// re-made with a fresh `AnyView`, the pane row re-made (a `BookView`
    /// whose `init` mints and discards two view models per pass), the
    /// navigator's rows re-diffed. Read HERE, the only view that re-runs per
    /// caret move is this box, which already carries the bar. The shell
    /// still holds no model: it hands down a closure over the local model it
    /// composed the bar from (CLAUDE.md: features receive values and
    /// closures), never `self`.
    let caretLabel: (() -> String?)?
    /// "now", for the day rule (injected so a pin holds the rule and not the
    /// machine's clock).
    var now: Date = Date()
    /// The one door out of the read-cheap state.
    var onEditHere: (() -> Void)?
    /// 13i-c U4 (the sitting record §20) — the box's BOOK CONTEXT: the
    /// remove/release door for the box's note (the book's word, and its act),
    /// rendered as the box's context menu while a note is in it. nil where
    /// the book holds no membership (a gathering).
    var removeDoor: (verb: String, act: () -> Void)?
    /// **VX-304 — "open ↗": out of the book, into the note's own editor**, in
    /// Write at her caret's block (the book's one open door, VX-303's road).
    /// nil ⇒ no door.
    var onOpenInWrite: (() -> Void)?
    /// **VX-304 — the Index's "Takes"**: the live block's takes in place, over
    /// the book. Handed only where the live note has no bar (the Index); a
    /// bar carries its own Takes door. nil ⇒ no door.
    var onOpenTakes: (() -> Void)?
    /// The live editor's bar, built by the shell. nil ⇒ no full editor is
    /// live here (the Index's own liveness is a single block's pane, not an
    /// editor — see `BookNoteBox.livePost`).
    var bar: AnyView?

    #if DEBUG
    /// **This box's own name in the DEBUG oracle** (18k UNIT C4 — the
    /// `MastheadStamp.oracleOwner` shape): it owns the box's frame, header
    /// and where-line, and takes exactly those with it when it leaves.
    @State private var oracleOwner = UUID()
    #endif

    /// The mockup's `.box{padding:8px}`, minus the border, so the box's
    /// contents land on exactly the left edge the column's ROW text does
    /// (`groupPadding` + 1 pt of border + this = `rowPadding`'s inset). Her
    /// punchlist 3's *"the items in that pane should all be aligned"*,
    /// applied to a bordered box.
    ///
    /// The numbers come from `SidebarLayout` — the column's layout BRAIN,
    /// not the column's view (the 18d ladder's MINOR-7), and that brain
    /// lives HERE in `Core/Views/` since round 2's MINOR-4 finished the
    /// move: the shared-chrome home reads no `Features/` type at all.
    static let inset: CGFloat = SidebarLayout.rowPadding - 1
    private static let corner: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if case .empty = state {
                // The empty state cannot overflow, so it does not scroll —
                // and it CENTRES in the box's room (mockup figure C's
                // `margin: auto 0`), which is what makes "nothing is
                // selected" read as a state rather than as a stub at the top.
                emptyBody
            } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    switch state {
                    case .empty:
                        EmptyView()
                    case .selected:
                        identityBlock
                        factsBlock
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
            // The door sits at the box's BOTTOM (figure C's `margin-top:
            // auto`), OUTSIDE the scroll: it is the state's one act and it
            // must never scroll out of reach under a long title.
            if case .selected = state { editDoor }
            // VX-304 (P-U1b-5): a live note with NO bar (the Index — its
            // liveness is one block's pane, not an editor) gets the block's
            // "Takes" in the same place, so it never scrolls out of reach
            // either. A bar carries its own Takes door; none is handed then.
            if state.isLive, bar == nil, let onOpenTakes { takesDoor(onOpenTakes) }
            }
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
        // 13i-c U4 (§20): the box's BOOK CONTEXT — right-click the box to take
        // its note out of the book. Only while a note is in it.
        .contextMenu {
            if let removeDoor, state.postID != nil {
                Button(removeDoor.verb) { removeDoor.act() }
            }
        }
#if DEBUG
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
            SidebarGeometry.recordBoxFrame(subjectKey, $0, owner: oracleOwner)
        }
        // 18k C4: this box's rows, and no other window's box's.
        .onDisappear { SidebarGeometry.release(owner: oracleOwner) }
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
                SidebarGeometry.recordBoxHeader(subjectKey, $0, owner: oracleOwner)
            }
#endif
            .padding(.bottom, SidebarLayout.headerAir)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 2)
        .help(NoteBoxCopy.emptyHelp)
#if DEBUG
        .onAppear { SidebarGeometry.noteBoxFaces[subjectKey, default: [:]]["empty", default: 0] += 1 }
        .onDisappear { SidebarGeometry.noteBoxFaces[subjectKey, default: [:]]["empty", default: 0] -= 1 }
#endif
    }

    // MARK: - States 2 and 3 — the identity

    @ViewBuilder private var identityBlock: some View {
        if let identity {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(identity.title)
                        .font(tokens.heading)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)
                    // VX-304 (P-U1b-2): while LIVE the door stands by the
                    // TITLE, where the book's own "open ↗" stands by its
                    // title — at no height cost, because the live box's bar
                    // fills the rail's height (the 18d floor). Selected, it
                    // stands beside "edit here" instead (`editDoor`).
                    if state.isLive, let onOpenInWrite {
                        Spacer(minLength: 0)
                        titleOpenDoor(onOpenInWrite)
                    }
                }
                let line = NoteBoxCopy.whereLine(
                    chapter: identity.chapter, index: identity.index,
                    total: identity.total, totalIsAtLeast: identity.totalIsAtLeast,
                    block: caretLabel?())
#if DEBUG
                // MAJOR-1's second arm: what the where-line SAYS, so the pin
                // that counts the shell's bodies can also prove the label
                // still follows the caret (a body count alone is satisfied by
                // deleting the label).
                let _ = SidebarGeometry.recordWhereLine(line, for: subjectKey, owner: oracleOwner)
#endif
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
            .padding(.bottom, 4)
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

    /// The selected state's door row: "edit here" (into the note, INSIDE the
    /// book) and, beside it, VX-304's "open ↗" (out of the book, into the
    /// note's own editor — P-U1b-2: the state's two ways in, side by side).
    @ViewBuilder private var editDoor: some View {
        if onEditHere != nil || onOpenInWrite != nil {
            HStack(spacing: 6) {
                if let onEditHere { editHereButton(onEditHere) }
                if let onOpenInWrite { rowOpenDoor(onOpenInWrite) }
            }
        }
    }

    private func editHereButton(_ act: @escaping () -> Void) -> some View {
        Button(action: act) {
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
        // 13s-b U2: step 10's first beat points here ("edit here drops
        // you back into it").
        .tourAnchor(.noteBoxEditHere, cornerRadius: 6)
#if DEBUG
        .onAppear { SidebarGeometry.noteBoxFaces[subjectKey, default: [:]]["door", default: 0] += 1 }
        .onDisappear { SidebarGeometry.noteBoxFaces[subjectKey, default: [:]]["door", default: 0] -= 1 }
#endif
    }

    /// **VX-304 — the Index-live box's "Takes"** (P-U1b-5): the live block's
    /// takes, in place over the book — one cell in the bar's own grammar
    /// (`CommitBar`'s bordered box cell, its "Takes" word), at the bar's cell
    /// height, so the Index's box reads like the Outline's where the two
    /// overlap.
    ///
    /// The cell's height is the bar's (`CommitBar.boxCellHeight`, 24) restated
    /// rather than read: this shared-chrome home reads no `Features/` type
    /// (the 18d round 2 MINOR-4 move — the box is HANDED the bar, never
    /// names it).
    static let takesCellHeight: CGFloat = 24

    private func takesDoor(_ act: @escaping () -> Void) -> some View {
        // The VX-382 ladder's R1-7 (walk finding W-1's lesson — a macOS button
        // counts a press only inside its OWN bounds): the CELL is laid out
        // bare and the BUTTON rides an overlay of it, its label filling the
        // cell, so the button's own frame IS the bordered cell. Before, the
        // Button was the word's size inside a full-width frame and a press
        // anywhere else in the cell was dropped (measured: the probe's edge
        // press, 4 pt inside the left border, opened nothing). The word, its
        // ink and its place are unchanged; the hover wash covers the target.
        let door = Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: Self.takesCellHeight)
            .background(tokens.surface, in: RoundedRectangle(cornerRadius: 6))
            .overlay {
                Button(action: act) {
                    Text(tokens.chromeLabel(NoteBoxCopy.takesDoor))
                        .lineLimit(1)
                        .fixedSize()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(NoteBoxCopy.takesDoorHelp)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(tokens.line, lineWidth: 1)
                    .allowsHitTesting(false))
#if DEBUG
        return door
            .onAppear { SidebarGeometry.noteBoxFaces[subjectKey, default: [:]]["takes", default: 0] += 1 }
            .onDisappear { SidebarGeometry.noteBoxFaces[subjectKey, default: [:]]["takes", default: 0] -= 1 }
#else
        return door
#endif
    }

    /// **VX-304 — "open ↗" in the selected row** (P-U1b-1: the book's own
    /// words for the act): the bar's bordered-cell grammar beside the filled
    /// "edit here", at the same height, so the row reads as two doors. With
    /// no caret in the note, it opens the note in Write with the plain open's
    /// place (R-U1a-2) — and its hover says so.
    private func rowOpenDoor(_ act: @escaping () -> Void) -> some View {
        let door = Button(action: act) {
            Text(tokens.chromeLabel(NoteBoxCopy.openDoor))
                .font(tokens.small)
                .fontWeight(.semibold)
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .foregroundStyle(tokens.accent)
                .background(tokens.surface, in: RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(tokens.line, lineWidth: 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(NoteBoxCopy.openDoorHelpSelected)
#if DEBUG
        return door.modifier(OpenDoorOracle(subjectKey: subjectKey, owner: oracleOwner))
#else
        return door
#endif
    }

    /// **VX-304 — "open ↗" by the title, while LIVE**: the book's title door,
    /// word for word and in its voiced grammar, in the accent (her report is
    /// that she could not SEE it). It carries her caret's block (VX-303's
    /// road) — and its hover says so.
    private func titleOpenDoor(_ act: @escaping () -> Void) -> some View {
        let door = Button(tokens.chromeLabel(NoteBoxCopy.openDoor), action: act)
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .lineLimit(1)  // P-8: a fixedSize chrome label states its line policy
            .fixedSize()
            .help(NoteBoxCopy.openDoorHelpLive)
#if DEBUG
        return door.modifier(OpenDoorOracle(subjectKey: subjectKey, owner: oracleOwner))
#else
        return door
#endif
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

#if DEBUG
/// **VX-304 — the box's "open ↗" in the DEBUG oracle**: its FACE (a +1/−1
/// refcount, the "door" face's shape) and its FRAME (owned by the box that
/// drew it, released with that box) — so "the door is drawn, whole, inside
/// the box" is read off what was drawn.
private struct OpenDoorOracle: ViewModifier {
    let subjectKey: String
    let owner: UUID

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                SidebarGeometry.recordBoxOpenDoor(subjectKey, $0, owner: owner)
            }
            .onAppear { SidebarGeometry.noteBoxFaces[subjectKey, default: [:]]["open", default: 0] += 1 }
            .onDisappear { SidebarGeometry.noteBoxFaces[subjectKey, default: [:]]["open", default: 0] -= 1 }
    }
}
#endif
