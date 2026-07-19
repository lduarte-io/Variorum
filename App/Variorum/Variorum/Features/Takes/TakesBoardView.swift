//
//  TakesBoardView.swift
//  Variorum
//
//  Phase 11, Step A3 — the takes board; Phase 13 Stage C2 — the v2-canon
//  restyle (R12: tinted cards, the 3pt "✓ chosen" bar, ONE live ring; the
//  R24 short-block strip; R25 follow-the-scroll; the ＋new-take doors).
//
//  Taste-checkpoint fix round (Sitting 9 — R86): the TAKES tab is now
//  SINGLE-COLUMN ONLY — the post, block by block, with each block's fan in
//  the set style. The multi-column compositions and every piece of lens
//  machinery moved to the LENSES tab (LensesBoardView); fan styles and
//  columns never co-occupy a surface again. New here: first-take doors on
//  EVERY block (the 9d chicken-and-egg closed again — R72), the margin
//  grid's density option + reserved vertical room (R74), "Save current
//  choices as a lens…" (the elevate door), and "Write new takes on every
//  block" (R82 — the renamed branch-all, jargon retired per R70/R81).
//

import SwiftUI
import VariorumCore

struct TakesBoardView: View {
    let session: AppSession
    let postID: String
    @State private var model: TakesViewModel
    /// The carousel/slot-split EXPLICIT beneath-count control (1–4,
    /// user-chosen for their screen width — never auto-only).
    @AppStorage("takesBeneathCount") private var beneathCount = 2
    /// R13/R22 — the changing-block WASH, default ON, toggleable.
    @AppStorage("markChangingBlock") private var markChangingBlock = true
    /// R74 — the margin grid's density, hers to choose: cards stacked per
    /// column (1–3 high) and visible columns (1–2 wide). The rail reserves
    /// this much room while a block's takes are open.
    @AppStorage("takesGridRows") private var gridRows = 2
    @AppStorage("takesGridCols") private var gridCols = 1
    /// Discrete paging offsets per block (whole cards, never halfway).
    @State private var pageOffsets: [String: Int] = [:]
    @State private var lensNamePrompt = false
    @State private var diffPresentation: TakesDiffPresentation?
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private var themeSettings: Queries.ThemeSettings {
        themeStore?.settings ?? Queries.ThemeSettings()
    }

    /// The Takes tab shows the POST — one fixed main column (columns live
    /// in Lenses now).
    private let mainColumn = TakesColumn(id: "takes-main", kind: .main)

    /// R74: the rail's reserved width follows the chosen column count.
    private var marginRailWidth: CGFloat {
        CGFloat(gridCols) * 220 + CGFloat(max(gridCols - 1, 0)) * 6
    }

    /// R74's "at least two cards of vertical room": while a block's takes
    /// are open in grid form, the row reserves this height — the post
    /// GROWS so the cards get regular room (the strip precedent).
    private var gridReservedHeight: CGFloat {
        CGFloat(gridRows) * 110 + CGFloat(max(gridRows - 1, 0)) * 6
    }

    init(session: AppSession, postID: String, model: TakesViewModel? = nil) {
        self.session = session
        self.postID = postID
        _model = State(initialValue: model ?? TakesViewModel(session: session, postID: postID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if let status = model.statusMessage {
                Text(status)
                    .font(.caption)
                    .foregroundStyle(tokens.accent)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            }
            if model.projection.sealed {
                Text("Sealed post — takes are viewable; choosing and new takes are frozen.")
                    .font(.caption)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(.quaternary)
            }
            if model.isJournalShaped {
                // R84 — the Fragments projection note on journal entries.
                Text("Takes live here in Variorum. Only the CHOSEN text is what Fragments sees "
                    + "(when a Fragments account is linked) — sync conflicts can add takes here "
                    + "too; nothing is lost, choose what the entry shows.")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            }
            singleColumnArticle
            TakesBottomBar(model: model)
        }
        .background(tokens.surface)
        .task { await model.start() }
        .onAppear { model.followTheScroll = themeSettings.followTheScroll }
        .onChange(of: themeSettings.followTheScroll) { _, new in
            model.followTheScroll = new
        }
        .onDisappear { model.teardown() }
        .sheet(item: $diffPresentation) { diff in
            DiffView(
                leftTitle: diff.leftTitle, rightTitle: diff.rightTitle,
                leftText: diff.left, rightText: diff.right)
        }
        .sheet(isPresented: $lensNamePrompt) {
            LensNameSheet(title: "Save current choices as a lens") { name in
                Task { await model.saveCurrentChoicesAsLens(name: name) }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Picker("Fan style", selection: Binding(
                get: { model.projection.fanStyle },
                set: { style in Task { await model.setFanStyle(style) } })) {
                Text("Stack").tag(FanStyle.stack)
                Text("Carousel").tag(FanStyle.carousel)
                Text("Margin grid").tag(FanStyle.marginGrid)
                Text("Slot split").tag(FanStyle.slotSplit)
            }
            .pickerStyle(.menu)
            .fixedSize()

            if model.projection.fanStyle == .carousel || model.projection.fanStyle == .slotSplit {
                Stepper("× \(beneathCount)", value: $beneathCount, in: 1...4)
                    .fixedSize()
                    .help("How many takes show side by side (your screen width, your call)")
            }
            if model.projection.fanStyle == .marginGrid {
                // R74 — the grid density option: "you should be able to
                // choose what grid you want, up to like 3 high and 2 wide".
                Stepper("\(gridRows) high", value: $gridRows, in: 1...3)
                    .fixedSize()
                    .help("How many take cards stack vertically in the margin")
                Stepper("\(gridCols) wide", value: $gridCols, in: 1...2)
                    .fixedSize()
                    .help("How many card columns the margin shows before scrolling")
            }
            if model.projection.fanStyle != .slotSplit {
                Toggle("Mark changing block", isOn: $markChangingBlock)
                    .toggleStyle(.checkbox)
                    .help("Wash the block whose takes are open (R13 — the transient marker)")
            }

            if model.offersExpandAll {
                Button("Expand All Fans") { model.expandAllFans() }
                Button("Close All") { model.closeAllFans() }
                    .disabled(model.expandedBlocks.isEmpty)
            }

            Spacer()

            Button("Write new takes on every block") {
                Task { await model.writeNewTakesEverywhere() }
            }
            .help("A fresh take on every block, branched from what the post shows — "
                + "a full rewrite pass. See them in each block's fan, or side by side in Lenses.")
            Button("Save choices as lens…") { lensNamePrompt = true }
                .help("Keep the post's current takes as a named way of looking (a lens) — "
                    + "you can bring it back or compare against it in Lenses")
            Button("Duplicate as Version") { Task { await model.duplicateAsVersion() } }
                .help("A full copy of this post — takes and all — as a new post, linked as a version")
        }
        .controlSize(.small)
        .padding(8)
    }

    // MARK: - The article (ONE column; blooms in the set style)

    private var singleColumnArticle: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 6) {
                ForEach(model.projection.slots, id: \.placementID) { slot in
                    articleRow(slot: slot)
                        .onAppear { model.rowAppeared(slot.blockID) }
                        .onDisappear { model.rowDisappeared(slot.blockID) }
                }
            }
            .frame(maxWidth: articleMeasure, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
        }
    }

    /// R9's measure: 680pt of prose; the margin-grid composition adds its
    /// reserved rail beside it.
    private var articleMeasure: CGFloat {
        model.projection.fanStyle == .marginGrid
            ? 680 + 16 + marginRailWidth
            : 680
    }

    @ViewBuilder
    private func articleRow(slot: Queries.RenderedBlock) -> some View {
        let bloomed = model.isBloomed(slot)
        if model.projection.fanStyle == .marginGrid {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    fanToggleRow(slot: slot, bloomed: bloomed)
                    washedCell(slot: slot, washed: bloomed)
                }
                .frame(maxWidth: 680, alignment: .topLeading)
                Group {
                    if bloomed {
                        marginRail(slot: slot)
                    } else {
                        Color.clear.frame(height: 1)
                    }
                }
                .frame(width: marginRailWidth, alignment: .topLeading)
            }
        } else {
            VStack(alignment: .leading, spacing: 4) {
                fanToggleRow(slot: slot, bloomed: bloomed)
                if bloomed && !slot.hasFan {
                    // The FIRST-take door (R72): an unfanned block blooms
                    // into just the growth doors, whatever the style.
                    washedCell(slot: slot, washed: true)
                    newTakeDoors(slot: slot).padding(.leading, 24)
                } else if bloomed && model.projection.fanStyle == .slotSplit {
                    slotSplitBloom(slot: slot)
                } else {
                    washedCell(slot: slot, washed: bloomed)
                    if bloomed && model.projection.fanStyle == .stack {
                        stackBloom(slot: slot)
                    }
                    if bloomed && model.projection.fanStyle == .carousel {
                        carouselBloom(slot: slot)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func fanToggleRow(slot: Queries.RenderedBlock, bloomed: Bool) -> some View {
        HStack {
            if slot.hasFan {
                Button("⑂\(slot.activeVariantCount)") { model.toggleExpanded(slot.blockID) }
                    .controlSize(.mini)
                    .tint(tokens.accent)
                    .help(bloomed ? "Close this fan (⌘⇧T)" : "Open this fan (\(styleName)) — ⌘⇧T")
            } else {
                // R72's "we need an easier take": every block offers its
                // FIRST take — no fan required to grow one.
                Button("⑂ +") { model.toggleExpanded(slot.blockID) }
                    .controlSize(.mini)
                    .tint(tokens.muted)
                    .help("Give this block its first alternative take (⌘⇧T)")
            }
            Spacer()
        }
    }

    private func washedCell(slot: Queries.RenderedBlock, washed: Bool) -> some View {
        TakesCellView(
            model: model, tokens: tokens, slot: slot, column: mainColumn,
            tinted: false, onDiff: { diffPresentation = $0 })
            .padding(2)
            .background(washed && markChangingBlock ? tokens.wash : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    /// STACK: takes stacked under the block.
    private func stackBloom(slot: Queries.RenderedBlock) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(model.projection.fans[slot.blockID] ?? [], id: \.id) { take in
                CollapsibleTakeCard(
                    take: take, isChosen: take.id == slot.variantID,
                    isLive: paneKeyIsLive(slot: slot, take: take),
                    tokens: tokens,
                    onFocus: { focusPane(slot: slot, take: take) },
                    onEdit: { model.paneEdited(variantID: take.id, newText: $0) },
                    onChoose: { Task { await model.choose(blockID: slot.blockID, variantID: take.id) } })
            }
            newTakeDoors(slot: slot)
        }
        .padding(.leading, 24)
    }

    /// CAROUSEL: chosen stays in flow; beneath it a 1–4-wide paged row.
    private func carouselBloom(slot: Queries.RenderedBlock) -> some View {
        let takes = (model.projection.fans[slot.blockID] ?? [])
            .filter { $0.id != slot.variantID }
        return pagedTakesRow(takes: takes, slot: slot, pageKey: slot.blockID)
            .padding(.leading, 24)
    }

    /// SLOT SPLIT: the fanned slot divides into an equal split in-flow.
    private func slotSplitBloom(slot: Queries.RenderedBlock) -> some View {
        let takes = model.projection.fans[slot.blockID] ?? []
        return pagedTakesRow(takes: takes, slot: slot, pageKey: slot.blockID)
    }

    /// MARGIN GRID's rail (R24 + R74): a SHORT fanned block's cards render
    /// as the ONE-CARD-HIGH horizontal strip; longer blocks keep the grid —
    /// now `gridRows` tall (her density call) with `gridCols` columns
    /// visible, and the row RESERVES that vertical room so cards get
    /// regular space (the post grows — Sitting 9's push-down ask).
    private func marginRail(slot: Queries.RenderedBlock) -> some View {
        let takes = model.projection.fans[slot.blockID] ?? []
        return VStack(alignment: .leading, spacing: 4) {
            Text("takes · \(takes.count)")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            if takes.isEmpty {
                newTakeDoors(slot: slot)
            } else if TakesViewModel.usesHorizontalStrip(text: slot.text) {
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 6) {
                        ForEach(takes, id: \.id) { take in
                            takeMiniPane(take: take, slot: slot)
                                .frame(width: 220, height: 110, alignment: .topLeading)
                                .clipped()
                        }
                        newTakeDoors(slot: slot)
                    }
                }
            } else {
                ScrollView(.horizontal) {
                    let groups = stride(from: 0, to: takes.count, by: gridRows).map {
                        Array(takes[$0..<min($0 + gridRows, takes.count)])
                    }
                    HStack(alignment: .top, spacing: 6) {
                        ForEach(Array(groups.enumerated()), id: \.offset) { _, group in
                            VStack(spacing: 6) {
                                ForEach(group, id: \.id) { take in
                                    takeMiniPane(take: take, slot: slot)
                                }
                            }
                            .frame(width: 220)
                        }
                        newTakeDoors(slot: slot)
                    }
                }
                .frame(minHeight: gridReservedHeight, alignment: .top)
            }
        }
    }

    /// The shared discrete-paging row (carousel + slot split): whole cards,
    /// never halfway; ◀ ▶ move one card at a time.
    private func pagedTakesRow(
        takes: [Variant], slot: Queries.RenderedBlock, pageKey: String
    ) -> some View {
        let offset = min(max(pageOffsets[pageKey] ?? 0, 0), max(takes.count - beneathCount, 0))
        let visible = Array(takes.dropFirst(offset).prefix(beneathCount))
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 6) {
                ForEach(visible, id: \.id) { take in
                    takeMiniPane(take: take, slot: slot)
                        .frame(maxWidth: .infinity)
                }
            }
            if takes.count > beneathCount {
                HStack {
                    Button("◀") { pageOffsets[pageKey] = max(offset - 1, 0) }
                        .disabled(offset == 0)
                    Text("\(offset + 1)–\(min(offset + beneathCount, takes.count)) of \(takes.count)")
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                    Button("▶") {
                        pageOffsets[pageKey] = min(offset + 1, takes.count - beneathCount)
                    }
                    .disabled(offset >= takes.count - beneathCount)
                }
                .controlSize(.mini)
            }
            newTakeDoors(slot: slot)
        }
    }

    /// v2's dashed footer — the fan-growth doors (R23: takes are minted
    /// where takes are seen). Minting NEVER chooses (R90); the power
    /// variant lives on the keyboard (⇧⌥⌘T). Under a seal the ops refuse
    /// and the refusal speaks.
    private func newTakeDoors(slot: Queries.RenderedBlock) -> some View {
        HStack(spacing: 8) {
            Button("＋ new take (branch)") {
                guard let from = slot.variantID else { return }
                Task { await model.branchTake(blockID: slot.blockID, from: from) }
            }
            .disabled(slot.variantID == nil)
            .help("A new take that starts as a copy of what's shown (⌘T)")
            Text("·").foregroundStyle(tokens.faint)
            Button("＋ blank take") {
                Task { await model.newBlankTake(blockID: slot.blockID) }
            }
            .help("A genuinely different take, from scratch (⌥⌘T; ⇧⌥⌘T opens it as chosen)")
        }
        .buttonStyle(.plain)
        .font(tokens.small)
        .foregroundStyle(tokens.muted)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
        .fixedSize()
    }

    /// A take's pane inside a bloom, on the v2-canon card.
    private func takeMiniPane(take: Variant, slot: Queries.RenderedBlock) -> some View {
        let isChosen = take.id == slot.variantID
        return TakeCardFrame(isChosen: isChosen, tokens: tokens) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if let label = take.label {
                        Text(label).font(tokens.small).foregroundStyle(tokens.muted)
                    }
                    if isChosen {
                        Text("✓ chosen").font(tokens.small).foregroundStyle(tokens.chosen)
                    }
                    Spacer()
                    Button("✓") { Task { await model.choose(blockID: slot.blockID, variantID: take.id) } }
                        .controlSize(.mini)
                        .disabled(isChosen)
                        .help("Choose this take — the post shows it (everywhere); ⌘⏎ from the keyboard")
                }
                TakePaneView(
                    text: liveText(take),
                    isLive: paneKeyIsLive(slot: slot, take: take),
                    tokens: tokens,
                    onFocusRequest: { focusPane(slot: slot, take: take) },
                    onEdit: { model.paneEdited(variantID: take.id, newText: $0) })
            }
        }
    }

    // MARK: - Small helpers

    private var styleName: String {
        switch model.projection.fanStyle {
        case .stack: return "stack"
        case .carousel: return "carousel"
        case .marginGrid: return "margin grid"
        case .slotSplit: return "slot split"
        }
    }

    private func paneKeyIsLive(slot: Queries.RenderedBlock, take: Variant) -> Bool {
        model.focusedPane == TakesViewModel.PaneKey(
            columnID: mainColumn.id, blockID: slot.blockID, variantID: take.id)
            && !model.projection.sealed
    }

    private func focusPane(slot: Queries.RenderedBlock, take: Variant) {
        model.focus(TakesViewModel.PaneKey(
            columnID: mainColumn.id, blockID: slot.blockID, variantID: take.id))
    }

    private func liveText(_ take: Variant) -> String {
        model.liveBuffers[take.id] ?? take.workingText
    }
}

// MARK: - The v2-canon card frame (Stage C2's grammar: card paper +
// takeLine border + the 3pt chosen leading bar)

struct TakeCardFrame<Content: View>: View {
    let isChosen: Bool
    let tokens: VoiceTokens
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            (isChosen ? tokens.chosen : Color.clear)
                .frame(width: 3)
            content()
                .padding(.vertical, 5)
                .padding(.horizontal, 7)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(tokens.card)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(tokens.takeLine, lineWidth: 1))
    }
}

// MARK: - The collapsible stack card (round 2: quick expand/collapse)

private struct CollapsibleTakeCard: View {
    let take: Variant
    let isChosen: Bool
    let isLive: Bool
    let tokens: VoiceTokens
    let onFocus: () -> Void
    let onEdit: (String) -> Void
    let onChoose: () -> Void
    @State private var collapsed = false

    var body: some View {
        TakeCardFrame(isChosen: isChosen, tokens: tokens) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Button(collapsed ? "▸" : "▾") { collapsed.toggle() }
                        .controlSize(.mini)
                        .buttonStyle(.plain)
                    if let label = take.label {
                        Text(label).font(tokens.small).foregroundStyle(tokens.muted)
                    }
                    if isChosen {
                        Text("✓ chosen").font(tokens.small).foregroundStyle(tokens.chosen)
                    }
                    Spacer()
                    Button("✓") { onChoose() }
                        .controlSize(.mini)
                        .disabled(isChosen)
                }
                if collapsed {
                    Text(take.workingText.split(separator: "\n").first.map(String.init) ?? "(empty)")
                        .font(.callout)
                        .lineLimit(1)
                        .foregroundStyle(tokens.muted)
                        .onTapGesture { collapsed = false }
                } else {
                    TakePaneView(
                        text: take.workingText, isLive: isLive, tokens: tokens,
                        onFocusRequest: onFocus, onEdit: onEdit)
                }
            }
        }
    }
}
