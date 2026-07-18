//
//  TakesBoardView.swift
//  Variorum
//
//  Phase 11, Step A3 — the takes/lens board (the kickoff spike record,
//  BINDING): the two side-by-side compositions — (A) 1–4 separate
//  FULL-TEXT columns with the block-start alignment LOCK toggle; (B) one
//  article column whose fanned slot blooms in place — and the four fan-out
//  styles as a user SETTING (stack / carousel / margin grid / slot split;
//  whichever is set is what expand-all-fans opens document-wide). EVERY
//  pane is an editing surface; the ONE live editor migrates on click;
//  choosing stays the explicit ✓.
//
//  Phase 13, Stage C2 — the v2-canon restyle (R12: mockups-v2 is CANON for
//  the active view; anchor beside it: Phase13Mockups/round-2 §3): take
//  cards on VoiceTokens (card paper, takeLine border, the 3pt chosen bar +
//  "✓ chosen" mark, the live ring); the changing-block WASH behind its
//  default-on toggle (R13/R22); the R24 short-block one-card-high
//  HORIZONTAL strip in the margin grid; follow-the-scroll as a
//  takes-viewing option in all modes (R25); expand-all only where
//  meaningful; the ＋new-take doors (v2's dashed footer). R9: the article
//  holds the 68ch-class measure, never the window edge.
//

import SwiftUI
import VariorumCore

struct TakesBoardView: View {
    let session: AppSession
    let postID: String
    @State private var model: TakesViewModel
    /// The carousel's EXPLICIT beneath-count control (1–4, user-chosen for
    /// their screen width — never auto-only; the spike's round-2 call).
    @AppStorage("takesBeneathCount") private var beneathCount = 2
    /// R13/R22 — the changing-block WASH marks the block whose takes are
    /// open, default ON, toggleable ("Mark the changing block" — v2's
    /// letter). Folds the old marginGrid-only "Seamless" toggle: the wash
    /// is now the ONE changing-block marker across every in-flow style
    /// (recorded as a Stage C build-time call).
    @AppStorage("markChangingBlock") private var markChangingBlock = true
    /// Discrete paging offsets per block (whole cards, never halfway).
    @State private var pageOffsets: [String: Int] = [:]
    @State private var lensNamePrompt: LensNamePrompt?
    @State private var diffPresentation: DiffPresentation?
    /// Phase 13 (C2): the voice reaches the board — optional environment,
    /// terminal fallback (test hosts lack it — the established pattern).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private var themeSettings: Queries.ThemeSettings {
        themeStore?.settings ?? Queries.ThemeSettings()
    }

    /// The margin grid's reserved rail width — fixed so the article column
    /// stays a straight measure whether or not a row blooms (R9's calm).
    private let marginRailWidth: CGFloat = 340

    struct DiffPresentation: Identifiable {
        let leftTitle: String
        let rightTitle: String
        let left: String
        let right: String
        let id = UUID()
    }

    struct LensNamePrompt: Identifiable {
        enum Purpose { case saveScratch(columnID: String), branchAll }
        let purpose: Purpose
        var id: String {
            switch purpose {
            case .saveScratch(let id): return "save-\(id)"
            case .branchAll: return "branch-all"
            }
        }
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
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(.horizontal, 12)
            }
            if model.projection.sealed {
                Text("Sealed post — takes are viewable; choosing and new takes are frozen.")
                    .font(.caption)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(.quaternary)
            }
            content
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
        .sheet(item: $lensNamePrompt) { prompt in
            LensNameSheet { name in
                switch prompt.purpose {
                case .saveScratch(let columnID):
                    Task { await model.saveScratchAsLens(columnID: columnID, name: name) }
                case .branchAll:
                    Task { await model.branchAllFans(lensName: name) }
                }
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
            if model.columns.count <= 1 && model.projection.fanStyle != .slotSplit {
                Toggle("Mark changing block", isOn: $markChangingBlock)
                    .toggleStyle(.checkbox)
                    .help("Wash the block whose takes are open (R13 — the transient marker)")
            }

            if model.offersExpandAll {
                // R25's agreed half: expand-all only where it means
                // something — columns/slot-split ARE whole-post fan
                // presentations already.
                Button("Expand All Fans") { model.expandAllFans() }
                Button("Close All") { model.closeAllFans() }
                    .disabled(model.expandedBlocks.isEmpty)
            }

            Spacer()

            if model.columns.count > 1 {
                Toggle("Align blocks", isOn: Binding(
                    get: { model.alignmentLocked },
                    set: { model.alignmentLocked = $0 }))
                    .toggleStyle(.checkbox)
                    .help("Locked: registered comparison rows (honest whitespace). "
                        + "Unlocked: each column flows as its own read.")
            }
            Menu("+ Column") {
                Button("Scratch column (transparent)") { model.addScratchColumn() }
                if !model.projection.lenses.isEmpty {
                    Menu("Lens column") {
                        ForEach(model.projection.lenses, id: \.id) { lens in
                            Button(lens.name) { model.addLensColumn(lens.id) }
                        }
                    }
                }
                Button("Branch all fans into a new thread…") {
                    lensNamePrompt = LensNamePrompt(purpose: .branchAll)
                }
            }
            .fixedSize()
            .disabled(model.columns.count >= 4)
            Button("Duplicate as Version") { Task { await model.duplicateAsVersion() } }
        }
        .controlSize(.small)
        .padding(8)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if model.columns.count <= 1 {
            singleColumnArticle
        } else if model.alignmentLocked {
            lockedColumns
        } else {
            unlockedColumns
        }
    }

    /// Composition B: ONE article column; a bloomed slot fans out in place,
    /// in the set style; the rest of the article stays normal. The column
    /// holds the 68ch-class measure, centered, with real gutters (R9).
    private var singleColumnArticle: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 6) {
                ForEach(model.projection.slots, id: \.placementID) { slot in
                    articleRow(slot: slot, column: model.columns[0])
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
    /// reserved rail beside it (v2's rail-row — the article column stays
    /// straight whether or not a row blooms).
    private var articleMeasure: CGFloat {
        model.projection.fanStyle == .marginGrid
            ? 680 + 16 + marginRailWidth
            : 680
    }

    @ViewBuilder
    private func articleRow(slot: Queries.RenderedBlock, column: TakesColumn) -> some View {
        let bloomed = model.isBloomed(slot)
        if model.projection.fanStyle == .marginGrid {
            // v2's rail-row: article left at the fixed measure, the takes
            // rail right (empty until the block blooms — R24 shapes it).
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    fanToggleRow(slot: slot, bloomed: bloomed)
                    washedCell(slot: slot, column: column, washed: bloomed)
                }
                .frame(maxWidth: 680, alignment: .topLeading)
                Group {
                    if bloomed {
                        marginRail(slot: slot, column: column)
                    } else {
                        Color.clear.frame(height: 1)
                    }
                }
                .frame(width: marginRailWidth, alignment: .topLeading)
            }
        } else {
            VStack(alignment: .leading, spacing: 4) {
                fanToggleRow(slot: slot, bloomed: bloomed)
                if bloomed && model.projection.fanStyle == .slotSplit {
                    // The slot itself splits — the in-flow text is one of
                    // the split's panes, not a separate copy (no wash: the
                    // split replaces the flow cell).
                    slotSplitBloom(slot: slot, column: column)
                } else {
                    washedCell(slot: slot, column: column, washed: bloomed)
                    if bloomed && model.projection.fanStyle == .stack {
                        stackBloom(slot: slot, column: column)
                    }
                    if bloomed && model.projection.fanStyle == .carousel {
                        carouselBloom(slot: slot, column: column)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func fanToggleRow(slot: Queries.RenderedBlock, bloomed: Bool) -> some View {
        if slot.hasFan {
            HStack {
                Button("⑂\(slot.activeVariantCount)") { model.toggleExpanded(slot.blockID) }
                    .controlSize(.mini)
                    .tint(tokens.accent)
                    .help(bloomed ? "Close this fan" : "Open this fan (\(styleName))")
                Spacer()
            }
        }
    }

    /// The in-flow article cell, wearing the changing-block WASH while its
    /// takes are open (R13 — behind the default-on toggle).
    private func washedCell(
        slot: Queries.RenderedBlock, column: TakesColumn, washed: Bool
    ) -> some View {
        cell(slot: slot, column: column, tinted: false)
            .padding(2)
            .background(washed && markChangingBlock ? tokens.wash : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    /// Composition A, LOCKED: registered comparison rows — block starts
    /// aligned, honest whitespace.
    private var lockedColumns: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                columnHeaders
                ForEach(model.projection.slots, id: \.placementID) { slot in
                    let tints = Sameness.tints(model.rowTexts(slot: slot))
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 8) {
                            lineageStripe(slot.blockID)
                            ForEach(Array(model.columns.enumerated()), id: \.element.id) { i, column in
                                VStack(alignment: .leading, spacing: 4) {
                                    cell(slot: slot, column: column,
                                         tinted: i < tints.count ? tints[i] : false)
                                    if model.isBloomed(slot) {
                                        inCellBloom(slot: slot, column: column)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                        }
                    }
                    .onAppear { model.rowAppeared(slot.blockID) }
                    .onDisappear { model.rowDisappeared(slot.blockID) }
                }
            }
            .padding(12)
        }
    }

    /// Composition A, UNLOCKED: each column flows as its own complete read.
    private var unlockedColumns: some View {
        VStack(spacing: 0) {
            columnHeaders.padding(.horizontal, 12)
            HStack(alignment: .top, spacing: 8) {
                ForEach(model.columns) { column in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 6) {
                            ForEach(model.projection.slots, id: \.placementID) { slot in
                                cell(slot: slot, column: column, tinted: false)
                                    .onAppear { model.rowAppeared(slot.blockID) }
                                    .onDisappear { model.rowDisappeared(slot.blockID) }
                            }
                        }
                        .padding(6)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var columnHeaders: some View {
        HStack(alignment: .center, spacing: 8) {
            Color.clear.frame(width: 4, height: 1)
            ForEach(model.columns) { column in
                HStack(spacing: 6) {
                    Text(columnTitle(column)).font(.caption.weight(.semibold))
                    columnMenu(column)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func columnTitle(_ column: TakesColumn) -> String {
        switch column.kind {
        case .main: return "Chosen (the post)"
        case .scratch: return "Scratch"
        case .lens(let id):
            return model.projection.lenses.first { $0.id == id }?.name ?? "Lens"
        }
    }

    @ViewBuilder
    private func columnMenu(_ column: TakesColumn) -> some View {
        Menu("⋯") {
            switch column.kind {
            case .main:
                Button("⧉ Duplicate as Version") { Task { await model.promoteColumn(column.id) } }
            case .scratch:
                Button("💾 Save as lens…") {
                    lensNamePrompt = LensNamePrompt(purpose: .saveScratch(columnID: column.id))
                }
                Button("⧉ Promote…") { Task { await model.promoteColumn(column.id) } }
            case .lens(let lensID):
                Button("✓✓ Adopt this lens (every pick → chosen)") { Task { await model.adoptLens(lensID) } }
                Button("⧉ Promote (fans ride)") { Task { await model.promoteColumn(column.id, carryFans: true) } }
                Button("⧉ Promote (chosen only)") { Task { await model.promoteColumn(column.id, carryFans: false) } }
                Button("Duplicate lens") { Task { await model.duplicateLens(lensID) } }
                Button("Delete lens", role: .destructive) { Task { await model.deleteLens(lensID) } }
            }
            if model.columns.count > 1 {
                Divider()
                Button("Remove column") { model.removeColumn(column.id) }
            }
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .controlSize(.mini)
    }

    // MARK: - Cells & blooms

    /// One cell: the column's resolved take, read-cheap until clicked; the
    /// clicked cell is the ONE live editor.
    @ViewBuilder
    private func cell(slot: Queries.RenderedBlock, column: TakesColumn, tinted: Bool) -> some View {
        if let resolved = model.resolvedTake(column: column, slot: slot) {
            let key = TakesViewModel.PaneKey(
                columnID: column.id, blockID: slot.blockID, variantID: resolved.variantID)
            TakePaneView(
                text: resolved.text,
                isLive: model.focusedPane == key && !model.projection.sealed,
                tokens: tokens,
                onFocusRequest: { model.focus(key) },
                onEdit: { model.paneEdited(variantID: resolved.variantID, newText: $0) })
                // Sameness divergence tints in the voice's accent (was the
                // unstyled yellow — the Stage C2 token swap).
                .background(tinted ? tokens.accent.opacity(0.12) : Color.clear)
                .contextMenu {
                    cellMenu(slot: slot, column: column, resolved: resolved)
                }
        } else {
            Text("· · ·")  // a gap slot renders a gap, never crashes
                .foregroundStyle(tokens.muted)
        }
    }

    @ViewBuilder
    private func cellMenu(
        slot: Queries.RenderedBlock, column: TakesColumn,
        resolved: (variantID: String, text: String)
    ) -> some View {
        Button("✓ Choose this take (the post shows it)") {
            Task { await model.choose(blockID: slot.blockID, variantID: resolved.variantID) }
        }
        .disabled(slot.variantID == resolved.variantID)
        Button("Diverge here (new take, this thread)") {
            Task {
                await model.divergeHere(
                    columnID: column.id, blockID: slot.blockID,
                    fromVariantID: resolved.variantID)
            }
        }
        if slot.variantID != resolved.variantID, let chosenText = slot.text {
            Button("Diff against chosen") {
                diffPresentation = DiffPresentation(
                    leftTitle: "chosen", rightTitle: "this take",
                    left: chosenText, right: resolved.text)
            }
        }
        if let fan = model.projection.fans[slot.blockID], fan.count > 1 {
            Menu("Show take") {
                ForEach(fan, id: \.id) { take in
                    Button(takeLabel(take, chosen: slot.variantID)) {
                        Task {
                            await model.pick(
                                columnID: column.id, blockID: slot.blockID, variantID: take.id)
                        }
                    }
                }
            }
        }
    }

    private func takeLabel(_ take: Variant, chosen: String?) -> String {
        var label = take.label ?? String(take.workingText.prefix(40))
        if label.isEmpty { label = "(empty take)" }
        if take.id == chosen { label = "✓ " + label }
        return label
    }

    /// STACK: takes stacked under the block, each with a quick
    /// expand/collapse (round 2's addition); v2's dashed growth doors
    /// close the stack.
    private func stackBloom(slot: Queries.RenderedBlock, column: TakesColumn) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(model.projection.fans[slot.blockID] ?? [], id: \.id) { take in
                CollapsibleTakeCard(
                    take: take, isChosen: take.id == slot.variantID,
                    isLive: paneKeyIsLive(column: column, slot: slot, take: take),
                    tokens: tokens,
                    onFocus: { focusPane(column: column, slot: slot, take: take) },
                    onEdit: { model.paneEdited(variantID: take.id, newText: $0) },
                    onChoose: { Task { await model.choose(blockID: slot.blockID, variantID: take.id) } })
            }
            newTakeDoors(slot: slot)
        }
        .padding(.leading, 24)
    }

    /// CAROUSEL: the chosen take stays the in-flow main option; beneath it
    /// a 1–4-wide row of further takes, paging whole cards.
    private func carouselBloom(slot: Queries.RenderedBlock, column: TakesColumn) -> some View {
        let takes = (model.projection.fans[slot.blockID] ?? [])
            .filter { $0.id != slot.variantID }
        return pagedTakesRow(
            takes: takes, slot: slot, column: column, pageKey: slot.blockID)
            .padding(.leading, 24)
    }

    /// SLOT SPLIT: the fanned slot divides into an equal mathematical
    /// split inside the article column — the takes ARE the row.
    private func slotSplitBloom(slot: Queries.RenderedBlock, column: TakesColumn) -> some View {
        let takes = model.projection.fans[slot.blockID] ?? []
        return pagedTakesRow(takes: takes, slot: slot, column: column, pageKey: slot.blockID)
    }

    /// MARGIN GRID's rail (R24, her design): a SHORT fanned block's cards
    /// render as a ONE-CARD-HIGH strip scrolling HORIZONTALLY — the row
    /// grows vertically to the card even when the block is a sentence;
    /// LONGER blocks keep the ~3-tall grid growing rightward. Both end in
    /// the growth doors.
    private func marginRail(slot: Queries.RenderedBlock, column: TakesColumn) -> some View {
        let takes = model.projection.fans[slot.blockID] ?? []
        return VStack(alignment: .leading, spacing: 4) {
            Text("takes · \(takes.count)")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            if TakesViewModel.usesHorizontalStrip(text: slot.text) {
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 6) {
                        ForEach(takes, id: \.id) { take in
                            takeMiniPane(take: take, slot: slot, column: column)
                                .frame(width: 220, height: 110, alignment: .topLeading)
                                .clipped()
                        }
                        newTakeDoors(slot: slot)
                    }
                }
            } else {
                ScrollView(.horizontal) {
                    let columnsOfThree = stride(from: 0, to: takes.count, by: 3).map {
                        Array(takes[$0..<min($0 + 3, takes.count)])
                    }
                    HStack(alignment: .top, spacing: 6) {
                        ForEach(Array(columnsOfThree.enumerated()), id: \.offset) { _, group in
                            VStack(spacing: 6) {
                                ForEach(group, id: \.id) { take in
                                    takeMiniPane(take: take, slot: slot, column: column)
                                }
                            }
                            .frame(width: 220)
                        }
                        newTakeDoors(slot: slot)
                    }
                }
            }
        }
    }

    /// The shared discrete-paging row (carousel + slot split): whole cards,
    /// never halfway; ◀ ▶ move one card at a time.
    private func pagedTakesRow(
        takes: [Variant], slot: Queries.RenderedBlock, column: TakesColumn, pageKey: String
    ) -> some View {
        let offset = min(max(pageOffsets[pageKey] ?? 0, 0), max(takes.count - beneathCount, 0))
        let visible = Array(takes.dropFirst(offset).prefix(beneathCount))
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 6) {
                ForEach(visible, id: \.id) { take in
                    takeMiniPane(take: take, slot: slot, column: column)
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
    /// where takes are seen). Under a seal the ops refuse and the refusal
    /// speaks (the 9d fire-and-speak posture).
    private func newTakeDoors(slot: Queries.RenderedBlock) -> some View {
        HStack(spacing: 8) {
            Button("＋ new take (branch)") {
                guard let from = slot.variantID else { return }
                Task { await model.branchTake(blockID: slot.blockID, from: from) }
            }
            .disabled(slot.variantID == nil)
            Text("·").foregroundStyle(tokens.faint)
            Button("＋ blank take") {
                Task { await model.newBlankTake(blockID: slot.blockID) }
            }
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


    /// A take's pane inside a bloom: editable on click like every pane,
    /// with the explicit ✓ beside it — on the v2-canon card (card paper,
    /// takeLine border, the 3pt chosen bar + "✓ chosen").
    private func takeMiniPane(
        take: Variant, slot: Queries.RenderedBlock, column: TakesColumn
    ) -> some View {
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
                        .help("Choose this take — the post shows it (everywhere)")
                }
                TakePaneView(
                    text: liveText(take),
                    isLive: paneKeyIsLive(column: column, slot: slot, take: take),
                    tokens: tokens,
                    onFocusRequest: { focusPane(column: column, slot: slot, take: take) },
                    onEdit: { model.paneEdited(variantID: take.id, newText: $0) })
            }
        }
    }

    /// In-cell blooms (the two-post/columns compositions): follow the set
    /// style where the cell's geometry allows; narrow cells degrade to the
    /// stack (recorded presentation call — Phase 13 revisits).
    @ViewBuilder
    private func inCellBloom(slot: Queries.RenderedBlock, column: TakesColumn) -> some View {
        if model.projection.fanStyle == .carousel || model.projection.fanStyle == .slotSplit {
            pagedTakesRow(
                takes: model.projection.fans[slot.blockID] ?? [],
                slot: slot, column: column, pageKey: "\(column.id)-\(slot.blockID)")
        } else {
            stackBloom(slot: slot, column: column)
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

    private func lineageStripe(_ blockID: String) -> some View {
        // The 9d stable-color family: same block, same color, forever —
        // the same-ORIGIN signal (sameness's other channel).
        let hue = Double(BlockTint.stableHash(blockID) % 360) / 360.0
        return Color(hue: hue, saturation: 0.5, brightness: 0.85)
            .frame(width: 4)
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }

    private func paneKeyIsLive(
        column: TakesColumn, slot: Queries.RenderedBlock, take: Variant
    ) -> Bool {
        model.focusedPane == TakesViewModel.PaneKey(
            columnID: column.id, blockID: slot.blockID, variantID: take.id)
            && !model.projection.sealed
    }

    private func focusPane(column: TakesColumn, slot: Queries.RenderedBlock, take: Variant) {
        model.focus(TakesViewModel.PaneKey(
            columnID: column.id, blockID: slot.blockID, variantID: take.id))
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

// MARK: - Lens naming

private struct LensNameSheet: View {
    let onName: (String) -> Void
    @State private var name = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Name this lens").font(.headline)
            TextField("e.g. bolder thread", text: $name)
                .frame(width: 260)
                .onSubmit(submit)
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") { submit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(16)
    }

    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        onName(trimmed)
        dismiss()
    }
}
