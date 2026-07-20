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

    /// Batch 14 (her image-#9 report — TWO live rings): the fan CARDS pane
    /// in their own namespace. When the chosen take's card was focused,
    /// its key EQUALED the article cell's (same column/block/variant) —
    /// both went live, and a live pane never adopts text, so the article
    /// froze stale. Distinct namespaces keep exactly ONE pane live (R22).
    static let fanColumnID = "takes-fan"

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
                // ChromeNotice: the line limit is LOAD-BEARING here
                // (window-min probe class — batch 12's Lenses recurrence).
                ChromeNotice(tokens: tokens, text: status, ink: tokens.accent)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 4)
            }
            if model.projection.sealed {
                Text(tokens.chromeLabel(
                    "sealed post — takes are viewable; choosing and new takes are frozen"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(tokens.wash)
            }
            if model.isJournalShaped {
                // R84 — the Fragments projection note on journal entries.
                ChromeNotice(
                    tokens: tokens,
                    text: "Takes live here in Variorum. Only the CHOSEN text is what Fragments sees "
                        + "(when a Fragments account is linked) — sync conflicts can add takes here "
                        + "too; nothing is lost, choose what the entry shows.")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 4)
            }
            singleColumnArticle
            TakesBottomBar(model: model)
        }
        .background(tokens.surface)
        .task { await model.start() }
        .onAppear {
            model.followTheScroll = themeSettings.followTheScroll
            model.host = .takes
        }
        .onChange(of: themeSettings.followTheScroll) { _, new in
            model.followTheScroll = new
        }
        .onDisappear { model.teardown() }
        .onExitCommand { model.closeAllFans() }  // ⎋ — the plain page (R87)
        .onReceive(NotificationCenter.default.publisher(for: .variorumTakesCommand)) { note in
            guard let command = TakesCommand.from(note) else { return }
            handleTakesCommand(command)
        }
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

    /// The board's half of the R73 keyboard family — the focused pane is
    /// the target; without one, the command SAYS what to do.
    private func handleTakesCommand(_ command: TakesCommand) {
        switch command {
        case .toggleFan:
            model.toggleFocusedFan()
        case .closeAll:
            model.closeAllFans()
        case .branch:
            guard let pane = model.focusedPane else {
                model.speak("Click into a take first — ⌘T branches the take you're in.")
                return
            }
            Task {
                if let take = await model.branchTake(blockID: pane.blockID, from: pane.variantID) {
                    model.focus(.init(
                        columnID: pane.columnID, blockID: pane.blockID, variantID: take.id))
                }
            }
        case .blank:
            guard let pane = model.focusedPane else {
                model.speak("Click into a block first — ⌥⌘T adds a blank take there.")
                return
            }
            Task {
                if let take = await model.newBlankTake(blockID: pane.blockID) {
                    model.focus(.init(
                        columnID: pane.columnID, blockID: pane.blockID, variantID: take.id))
                }
            }
        case .blankChoose:
            guard let pane = model.focusedPane else {
                model.speak("Click into a block first — ⇧⌥⌘T opens a blank take as chosen there.")
                return
            }
            Task { await model.newBlankTakeAsChosen(blockID: pane.blockID) }
        case .choose:
            Task { await model.chooseFocusedTake() }
        case .stepPrev:
            Task { await model.stepTakes(by: -1) }
        case .stepNext:
            Task { await model.stepTakes(by: 1) }
        case .archive:
            Task { await model.archiveFocusedTake() }
        case .saveLens:
            lensNamePrompt = true
        }
    }

    // MARK: - Header

    /// Batch 9 (R101): ONE quiet voiced line — style/density as compact
    /// word-menus, the wash as a chip, expand/close as words, and the
    /// three rare post-level acts folded into a single "post actions"
    /// menu. Every door the old toolbar had is still one click away; the
    /// row just stops shouting over the page.
    private var header: some View {
        HStack(spacing: 8) {
            VoicedMenu(tokens: tokens, label: "style: \(styleName)") {
                styleOption("Stack", .stack)
                styleOption("Carousel", .carousel)
                styleOption("Margin grid", .marginGrid)
                styleOption("Slot split", .slotSplit)
            }
            .help("How a block's takes fan open")

            if model.projection.fanStyle == .carousel || model.projection.fanStyle == .slotSplit {
                VoicedMenu(tokens: tokens, label: "× \(beneathCount) beside") {
                    ForEach(1...4, id: \.self) { n in
                        Button("× \(n)") { beneathCount = n }
                    }
                }
                .help("How many takes show side by side (your screen width, your call)")
            }
            if model.projection.fanStyle == .marginGrid {
                // R74 — the grid density option: "you should be able to
                // choose what grid you want, up to like 3 high and 2 wide".
                VoicedMenu(tokens: tokens, label: "\(gridRows) high") {
                    ForEach(1...3, id: \.self) { n in
                        Button("\(n) high") { gridRows = n }
                    }
                }
                .help("How many take cards stack vertically in the margin")
                VoicedMenu(tokens: tokens, label: "\(gridCols) wide") {
                    ForEach(1...2, id: \.self) { n in
                        Button("\(n) wide") { gridCols = n }
                    }
                }
                .help("How many card columns the margin shows before scrolling")
            }
            if model.projection.fanStyle != .slotSplit {
                VoicedChip(
                    tokens: tokens,
                    text: markChangingBlock ? "wash: on" : "wash: off",
                    on: markChangingBlock
                ) { markChangingBlock.toggle() }
                    .help("Wash the block whose takes are open (R13 — the transient marker)")
            }

            if model.offersExpandAll {
                Button(tokens.chromeLabel("expand all")) { model.expandAllFans() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help("Open every block's fan (they stay open once expanded)")
                Button(tokens.chromeLabel("close all")) { model.closeAllFans() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .disabled(model.expandedBlocks.isEmpty)
                    .help("Back to the plain page (⎋)")
            }

            Spacer()

            VoicedMenu(tokens: tokens, label: "post actions", role: .primary) {
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
            .help("The rare whole-post acts: a rewrite pass, saving choices as a lens, "
                + "duplicating as a version")
        }
        // Batch 14 (her alignment ask): the control line shares the
        // article's measure and left edge — one column, like the mockup.
        .frame(maxWidth: articleMeasure, alignment: .leading)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 6)
    }

    private func styleOption(_ name: String, _ style: FanStyle) -> some View {
        Button(name) { Task { await model.setFanStyle(style) } }
    }

    // MARK: - The article (ONE column; blooms in the set style)

    private var singleColumnArticle: some View {
        ScrollView {
            if model.projection.slots.isEmpty {
                // Batch 6: an empty post must never be a dead end — blocks
                // are born by TYPING, and Write is where typing lives.
                VStack(spacing: 8) {
                    Text(tokens.chromeLabel("Nothing here yet — blocks are born by typing."))
                        .font(tokens.body)
                        .foregroundStyle(tokens.muted)
                    Button(tokens.chromeLabel("Start writing (Write mode)")) {
                        NotificationCenter.default.post(
                            name: .variorumSwitchMode, object: nil,
                            userInfo: ["mode": "Write", "postID": postID])
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary, font: tokens.mono))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            }
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
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                    .help(bloomed ? "Close this fan (⌘⇧T)" : "Open this fan (\(styleName)) — ⌘⇧T")
            } else {
                // R72's "we need an easier take": every block offers its
                // FIRST take — no fan required to grow one.
                Button("⑂ +") { model.toggleExpanded(slot.blockID) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help("Give this block its first alternative take (⌘⇧T)")
            }
            Spacer()
        }
    }

    private func washedCell(slot: Queries.RenderedBlock, washed: Bool) -> some View {
        TakesCellView(
            model: model, tokens: tokens, slot: slot, column: mainColumn,
            tinted: false, role: "article", onDiff: { diffPresentation = $0 })
            .padding(2)
            .background(washed && markChangingBlock ? tokens.wash : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            // Batch 14 (her "even when there is a comment, i can't really
            // see the comment anywhere (I suppose it oculd go on the left
            // in the blank area)"): the block's comments in the LEFT
            // margin — the round-2 margin-comment idiom, takes-side.
            .overlay(alignment: .topLeading) {
                CommentMarginNote(session: session, blockID: slot.blockID, tokens: tokens)
                    .frame(width: 150, alignment: .topLeading)
                    .offset(x: -166)
            }
    }

    /// STACK: takes stacked under the block. The card's text routes
    /// through the AUTHORITY (13b 1a — the stack style fed panes raw
    /// `take.workingText`, bypassing the live buffers: the frozen-article
    /// class, still live in exactly this style; pinned in
    /// TakesArticleRenderTests's stack extension).
    private func stackBloom(slot: Queries.RenderedBlock) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(model.projection.fans[slot.blockID] ?? [], id: \.id) { take in
                CollapsibleTakeCard(
                    take: take, text: model.liveText(take),
                    isChosen: take.id == slot.variantID,
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

    /// CAROUSEL: the WHOLE fan as cards, chosen included and marked
    /// (Sitting 9 batch 7: filtering chosen out made "⑂3" show two cards
    /// with no way to reach the third — the count must match what blooms).
    private func carouselBloom(slot: Queries.RenderedBlock) -> some View {
        let takes = model.projection.fans[slot.blockID] ?? []
        return pagedTakesRow(takes: takes, slot: slot, pageKey: slot.blockID)
            .padding(.leading, 24)
    }

    /// SLOT SPLIT: the fanned slot divides into an equal split in-flow.
    private func slotSplitBloom(slot: Queries.RenderedBlock) -> some View {
        let takes = model.projection.fans[slot.blockID] ?? []
        return pagedTakesRow(takes: takes, slot: slot, pageKey: slot.blockID)
    }

    /// MARGIN GRID's rail (R24 + R74): a SHORT fanned block's cards render
    /// one-card-high; longer blocks keep the grid — `gridRows` tall (her
    /// density call) with `gridCols` columns visible, and the row RESERVES
    /// that vertical room so cards get regular space (the post grows —
    /// Sitting 9's push-down ask).
    ///
    /// AD-2 (13b 1a): the rail PAGES DISCRETELY — whole columns, an
    /// explicit ◀ x–y of n ▶ door — instead of the old horizontal
    /// ScrollView, which realized every card but CLIPPED all past the
    /// rail's width with no pager, no scrollbar, no affordance ("takes ·
    /// 4", two cards, half the fan unreachable). The carousel's discrete-
    /// paging grammar (whole cards, never halfway) is now the rail's too.
    private func marginRail(slot: Queries.RenderedBlock) -> some View {
        let takes = model.projection.fans[slot.blockID] ?? []
        // R24's one-card-high strip for short blocks when density is
        // 1-high; an explicit 2/3-high setting outranks it (batch 14).
        let rowsPerColumn =
            (TakesViewModel.usesHorizontalStrip(text: slot.text) && gridRows == 1)
            ? 1 : gridRows
        return VStack(alignment: .leading, spacing: 4) {
            Text("takes · \(takes.count)")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            if takes.isEmpty {
                newTakeDoors(slot: slot)
            } else {
                railCards(takes: takes, slot: slot, rowsPerColumn: rowsPerColumn)
                    .frame(
                        minHeight: rowsPerColumn > 1 ? gridReservedHeight : 0,
                        alignment: .top)
                // Batch 12 (her "i can't make a new take"): the growth
                // doors live BELOW the cards, always on screen (R72's
                // promise; never behind pagination either).
                newTakeDoors(slot: slot)
            }
        }
    }

    /// The rail's paged card window: takes chunk into columns of
    /// `rowsPerColumn`; `gridCols` columns are visible; ◀ ▶ move one
    /// column at a time. Every take is a card on SOME page — none is ever
    /// silently clipped away (the AD-2 pin + the soak invariant).
    private func railCards(
        takes: [Variant], slot: Queries.RenderedBlock, rowsPerColumn: Int
    ) -> some View {
        let columns = stride(from: 0, to: takes.count, by: rowsPerColumn).map {
            Array(takes[$0..<min($0 + rowsPerColumn, takes.count)])
        }
        let pageKey = "rail-\(slot.blockID)"
        let limit = max(columns.count - gridCols, 0)
        let offset = model.pageOffset(pageKey, limit: limit)
        let visible = Array(columns.dropFirst(offset).prefix(gridCols))
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 6) {
                ForEach(Array(visible.enumerated()), id: \.offset) { _, column in
                    VStack(spacing: 6) {
                        ForEach(column, id: \.id) { take in
                            // Batch 7: UNIFORM card height — "2 high" is
                            // literally two card-heights, never a clipped
                            // column of tall cards.
                            takeMiniPane(take: take, slot: slot)
                                .frame(width: 220, height: 110, alignment: .topLeading)
                                .clipped()
                        }
                    }
                    .frame(width: 220)
                }
            }
            if columns.count > gridCols {
                let firstShown = offset * rowsPerColumn + 1
                let lastShown = min((offset + gridCols) * rowsPerColumn, takes.count)
                HStack(spacing: 4) {
                    Button("◀") { model.stepPage(pageKey, by: -1, limit: limit) }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .disabled(offset == 0)
                    Text("\(firstShown)–\(lastShown) of \(takes.count)")
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                    Button("▶") { model.stepPage(pageKey, by: 1, limit: limit) }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .disabled(offset >= limit)
                }
            }
        }
    }

    /// The shared discrete-paging row (carousel + slot split): whole cards,
    /// never halfway; ◀ ▶ move one card at a time.
    private func pagedTakesRow(
        takes: [Variant], slot: Queries.RenderedBlock, pageKey: String
    ) -> some View {
        // Offsets live on the MODEL now (13b 1a, AD-2's companion move):
        // one paging brain for carousel, slot split, and the rail — and
        // the soak can drive page coverage.
        let limit = max(takes.count - beneathCount, 0)
        let offset = model.pageOffset(pageKey, limit: limit)
        let visible = Array(takes.dropFirst(offset).prefix(beneathCount))
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 6) {
                ForEach(visible, id: \.id) { take in
                    takeMiniPane(take: take, slot: slot)
                        .frame(maxWidth: .infinity)
                }
            }
            if takes.count > beneathCount {
                HStack(spacing: 4) {
                    Button("◀") { model.stepPage(pageKey, by: -1, limit: limit) }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .disabled(offset == 0)
                    Text("\(offset + 1)–\(min(offset + beneathCount, takes.count)) of \(takes.count)")
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                    Button("▶") { model.stepPage(pageKey, by: 1, limit: limit) }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .disabled(offset >= limit)
                }
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
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                        .disabled(isChosen)
                        .help("Choose this take — the post shows it (everywhere); ⌘⏎ from the keyboard")
                }
                PaneSurfaceView(
                    text: model.liveText(take),
                    isLive: paneKeyIsLive(slot: slot, take: take),
                    tokens: tokens,
                    role: "mini", variantID: take.id,
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
        model.authority.isLive(
            TakesViewModel.PaneKey(
                columnID: Self.fanColumnID, blockID: slot.blockID, variantID: take.id),
            sealed: model.projection.sealed)
    }

    private func focusPane(slot: Queries.RenderedBlock, take: Variant) {
        model.focus(TakesViewModel.PaneKey(
            columnID: Self.fanColumnID, blockID: slot.blockID, variantID: take.id))
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
    /// The AUTHORITY-resolved display text (13b 1a): the card never reads
    /// `take.workingText` directly — that was the stack style's liveness
    /// bypass (a dirty edit showed stale store text in read cards).
    let text: String
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
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                        .disabled(isChosen)
                        .help("Choose this take — the post shows it (everywhere); ⌘⏎ from the keyboard")
                }
                if collapsed {
                    Text(text.split(separator: "\n").first.map(String.init) ?? "(empty)")
                        .font(.callout)
                        .lineLimit(1)
                        .foregroundStyle(tokens.muted)
                        .onTapGesture { collapsed = false }
                } else {
                    PaneSurfaceView(
                        text: text, isLive: isLive, tokens: tokens,
                        role: "card", variantID: take.id,
                        onFocusRequest: onFocus, onEdit: onEdit)
                }
            }
        }
    }
}
