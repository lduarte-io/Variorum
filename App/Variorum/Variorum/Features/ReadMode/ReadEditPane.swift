//
//  ReadEditPane.swift
//  Variorum
//
//  **READ's `edit` face — the editable index surface** (the Act 10
//  correction round, her ruling R-cor-7, verbatim: *"I incline towards there
//  is an editable index surface, then you click read and it isn't anymore."*
//  and row 30: *"the index tab is ALSO uneditable in the notes view… it's
//  literally a new writing mode"*). The note's text beside the `▸ 01`
//  column, rendered read-cheap per block — and **a clicked block goes LIVE
//  right where it is**: the read-cheap→live upgrade through the ONE
//  `PaneTextAuthority` the `BlockTOCViewModel` owns (P-3 — one live editor,
//  one ring; the Write editor's identity machinery is never duplicated
//  here, and the Index tab's small editing card in the column is gone).
//
//  P1: a LazyVStack of per-block rows, each rendering its own markdown
//  (`FlowParagraph`) — cost ∝ viewport, never note size; the scroll-sync is
//  SwiftUI anchors, zero TK2 geometry (TEXTKIT2 §2's family avoided). The
//  one live block is a `PaneSurfaceView`, exactly as the book Index's pane
//  and the Blocks workbench's panel upgrade theirs.
//

import SwiftUI
import VariorumCore

struct ReadEditPane: View {
    /// The pane's role inside the authority's keys and the NSView identity
    /// (`pane:read-edit|<variant>` — the soaks and pins read it).
    static let role = "read-edit"

    let model: BlockTOCViewModel
    let tokens: VoiceTokens
    /// 17o batch c (her U-7): the editing indicator, pushed in beside the
    /// tokens and carried to the block panes — this surface decides nothing.
    let indicator: EditingIndicatorStyle
    let selectedBlockID: String?
    /// The ONE-shot scroll request — the host sets it on a column click, a
    /// seed or a landing; the pane lands and clears it. A pane click never
    /// sets it (clicking what you can see must not move it under you).
    ///
    /// 13u2b UNIT 3: it carries an ANCHOR when a mode switch brought a height
    /// with it; `nil` is this pane's own standing landing, which every other
    /// road keeps.
    @Binding var paneTarget: ReadLanding?
    /// 13u2b UNIT 3: where the carried block sits, measured by that row alone
    /// and read at a mode switch (the host owns the box).
    let carryGeometry: ReadCarryGeometry
    /// A block was clicked: the host selects it (and reports the fact); the
    /// pane makes it live.
    let onSelect: (String) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(
                        Array(model.rows.enumerated()), id: \.element.placementID
                    ) { i, row in
                        // Ladder R1-3 (the Outline lesson, rows 47/53): the
                        // ForEach IDENTITY (the placement id) is the landing
                        // anchor — no explicit `.id` on the row.
                        ReadEditBlock(
                            model: model, tokens: tokens, indicator: indicator,
                            row: row, ordinal: i + 1,
                            selected: selectedBlockID == row.blockID,
                            carryGeometry: carryGeometry,
                            onTap: {
                                onSelect(row.blockID)
                                if let variantID = row.variantID, !row.variantLocked {
                                    model.makeLive(row.blockID, variantID: variantID)
                                }
                            })
                    }
                }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(.horizontal, 34)
                .padding(.vertical, 26)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .background(tokens.surface)
            .onChange(of: paneTarget) { _, target in
                guard let target else { return }
                // CENTER, deliberately: a landed block sits mid-viewport with
                // room above it, so its ring is never clipped at the pane's
                // top edge (batch B's nit on the book's flush landing).
                // Ladder R1-3: UNANIMATED, on the row's identity — the pin
                // measured the animated landing of block 200 of 215 drifting
                // by ~180 pt with the machine's speed (the rows it passed
                // grew after their first frame, see `ReadEditBlock`).
                land(target, proxy)
                paneTarget = nil
            }
            .task {
                // A request parked before this face mounted (the `read`
                // click flips the face and names its block in one breath).
                await Task.yield()
                guard let target = paneTarget else { return }
                land(target, proxy)
                paneTarget = nil
            }
        }
    }
}

extension ReadEditPane {
    /// This pane's own standing anchor. CENTER, deliberately: a landed block
    /// sits mid-viewport with room above it, so its ring is never clipped at
    /// the pane's top edge (batch B's nit on the book's flush landing).
    static let restingAnchor = UnitPoint.center

    /// The landing: the block's ROW IDENTITY (its placement id) is what the
    /// scroll reader lands on, unanimated (the Outline lesson) — at this
    /// pane's resting anchor, or at the viewport fraction a mode switch
    /// carried for this very block (13u2b UNIT 3). `scrollTo`'s anchor IS
    /// that fraction, so the landing's mechanism is untouched.
    private func land(_ target: ReadLanding, _ proxy: ScrollViewProxy) {
        guard let placementID = model.rows
            .first(where: { $0.blockID == target.blockID })?.placementID
        else { return }
        proxy.scrollTo(placementID, anchor: target.anchor ?? Self.restingAnchor)
    }
}

/// One block of the pane: THE live pane when it is the clicked one, else its
/// rendered paragraphs (a click on them is the upgrade). Washed when
/// selected, the ordinal in the margin, one generous click target.
private struct ReadEditBlock: View {
    /// This surface's resting padding — what the read tier used to pad on
    /// every side, and still the trailing/bottom measure.
    static let restingLeading = IndexProseColumn.readEditResting
    static let restingTop = IndexProseColumn.readEditRestingTop
    /// The two tiers' leading and top padding, derived from that one number
    /// and the pane's own inset so they cannot drift (13u2 UNIT B).
    @MainActor static var readTierLeading: CGFloat {
        IndexProseColumn.readTierLeading(
            resting: restingLeading, paneInset: PaneTextView.proseLeadingInset)
    }
    @MainActor static var livePaneLeading: CGFloat {
        IndexProseColumn.livePaneLeading(
            resting: restingLeading, paneInset: PaneTextView.proseLeadingInset)
    }
    @MainActor static var readTierTop: CGFloat {
        IndexProseColumn.readTierTop(
            resting: restingTop, paneInset: PaneTextView.proseTopInset)
    }
    @MainActor static var livePaneTop: CGFloat {
        IndexProseColumn.livePaneTop(
            resting: restingTop, paneInset: PaneTextView.proseTopInset)
    }

    let model: BlockTOCViewModel
    let tokens: VoiceTokens
    let indicator: EditingIndicatorStyle
    let row: Queries.TOCRow
    let ordinal: Int
    let selected: Bool
    /// 13u2b UNIT 3: the host's box — only the row the carry is about (the
    /// selected or live one) writes into it, so this is one report a scroll
    /// frame rather than one a realized row.
    let carryGeometry: ReadCarryGeometry
    let onTap: () -> Void

    /// The block's DISPLAY text — the authority's overlay over the store
    /// row, so a just-blurred block is never staler here than its buffer.
    private var text: String {
        model.displayText(variantID: row.variantID, storeText: row.text)
    }

    /// Ladder R1-3: the paragraphs render SYNCHRONOUSLY (a pure transform,
    /// cost ∝ the realized rows). Deferred through a `.task`, every row
    /// stood one line tall for its first frame and grew after — the lazy
    /// column's estimate drift that moved a far landing by ~180 pt.
    private var paragraphs: [FlowParagraph] {
        FlowParagraph.paragraphs(of: text, codeTint: tokens.codeTint)
    }

    private var isLive: Bool {
        model.liveBlockID == row.blockID && !row.variantLocked
    }

    var body: some View {
        Group {
            if isLive, let variantID = row.variantID {
                PaneSurfaceView(
                    text: text,
                    isLive: true,
                    tokens: tokens,
                    indicator: indicator,
                    role: ReadEditPane.role, variantID: variantID,
                    onFocusRequest: { model.makeLive(row.blockID, variantID: variantID) },
                    onEdit: { newText in
                        model.paneEdited(
                            variantID: variantID,
                            oldText: row.text ?? "", newText: newText)
                    },
                    onSelectionChange: { range in
                        // 17o batch b (U-20): this pane's caret is the note's
                        // current-block offset — Write lands there next.
                        model.notePaneCaret(
                            blockID: row.blockID, variantID: variantID,
                            offset: range.location)
                    },
                    caretOnGoingLive: model.caretLanding(forVariant: variantID))
                    // 13u2 UNIT B (her item 19): the live pane's PROSE lands
                    // exactly where the read tier's did — the host pays back
                    // only the remainder of the pane's own inset, so clicking
                    // into a block does not step the text sideways.
                    .padding(.leading, ReadEditBlock.livePaneLeading)
                    .padding(.trailing, ReadEditBlock.restingLeading)
                    .padding(.top, ReadEditBlock.livePaneTop)
                    .padding(.bottom, ReadEditBlock.restingTop)
                // (17o batch c's own host ring RETIRED at 13u2 UNIT B: the
                //  pane draws the indicator itself, in the same shape and the
                //  same token, so this overlay was a SECOND concentric ring —
                //  visible in the walk's captures. One editing mark, one
                //  drawer: `PaneDecoration.resolve`, inside the pane.)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                        Text(paragraph.text)
                            .font(font(paragraph))
                            .foregroundStyle(tokens.ink)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, paragraph.indent)
                    }
                    if paragraphs.isEmpty {
                        Text(" ").font(tokens.body)
                    }
                }
                // 13u2 UNIT B: the read tier's prose sits at the SAME column
                // as the live pane's (`IndexProseColumn` — one number, both
                // tiers derived).
                .padding(.leading, ReadEditBlock.readTierLeading)
                .padding(.trailing, ReadEditBlock.restingLeading)
                .padding(.top, ReadEditBlock.readTierTop)
                .padding(.bottom, ReadEditBlock.restingTop)
                .frame(maxWidth: .infinity, alignment: .leading)
                // **THE FIRST-CLICK HIGHLIGHT** (her item 19): a block chosen
                // from the index column washes, and that is NOT the editing
                // indicator's to govern — *"it shouldn't stop the item from
                // being highlighted on the left and highlighted when you first
                // click on it from the index column"*. A block she is EDITING
                // wears the R14/R22 setting's mark instead, drawn by the pane.
                .background(
                    selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
                    in: RoundedRectangle(cornerRadius: 8))
                .contentShape(Rectangle())
                .onTapGesture { onTap() }
                .help(row.variantLocked
                    ? "This take is locked — unlock it in Takes to write here"
                    : "Click to write in this block right here — one block is live at a time")
            }
        }
        .overlay(alignment: .topLeading) {
            if selected || isLive {
                Text(String(format: "%02d", ordinal))
                    .font(tokens.mono)
                    .foregroundStyle(tokens.faint)
                    .offset(x: -26, y: 6)
            }
        }
        .readModeGeometryProbe(.editBlock(row.blockID))
        .onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(ReadModeView.probeSpace))
        } action: { frame in
            if selected || isLive { carryGeometry.noteRow(row.blockID, frame) }
        }
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
    }

    /// The pane reads in the VOICE (the pane is the surface, not the paper —
    /// the `read` face owns the paper look). A view-local font map over the
    /// one transform's line styles, never a second markdown brain.
    private func font(_ paragraph: FlowParagraph) -> Font {
        switch paragraph.style {
        case .heading(let level):
            level == 1 ? tokens.title : tokens.heading
        case .body, .bullet, .checkbox:
            tokens.body
        }
    }
}
