//
//  TakesBoardLayout.swift
//  Variorum
//
//  13b Stage 3, N10 — the TakesViewModel P-9 decomposition, seam 1 of 2
//  (the plan's "board layout/paging" candidate, proposed from the code):
//  the board's SESSION-ONLY view-geometry state — fan expansion, discrete
//  paging, follow-the-scroll row visibility, and the density inputs —
//  moved out of the conductor into one named, self-contained component.
//  Nothing here touches the store, the projection, or the authority: it
//  is exactly the state a board renders its geometry from, and it dies
//  with the session (the plan's letter: fans stay open once expanded,
//  close-all resets, nothing persists).
//
//  The view model forwards every existing property/method name, so every
//  view and pin call site reads unchanged (behavior parity is the batch
//  contract). Observation granularity is preserved: each piece of state
//  stays its OWN stored property on this @Observable class, so a view
//  reading only `pageOffsets` still doesn't re-render on an expansion
//  change (merging them into one struct property would have coarsened
//  invalidation).
//

import CoreGraphics
import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class TakesBoardLayout {
    // MARK: - Card geometry (QoL round 2026-07-29, batch 2 — L3 · L4)

    /// The take card's ruled height (13b 3F/4D — N40/S4-31b: ONE fixed
    /// strip height, the content scrolling in place). It lives HERE now
    /// because the reserve arithmetic and the drag clamps below all need
    /// it; `TakesBoardView.railCardHeight` forwards, so every existing
    /// call site and pin reads unchanged.
    nonisolated static let railCardHeight: CGFloat = 110
    /// The gap between stacked cards in a rail column.
    nonisolated static let cardGap: CGFloat = 6

    /// L4's RULED cap: a margin-grid card grows with its content to
    /// **three card-heights** and scrolls inside beyond that. Her report:
    /// *"even when there is a long block, the margin grid note is sticky
    /// note sized which isn't that helpful for long blocks."*
    ///
    /// Why 330 and not more (the ruling's derivation, kept where the
    /// constant lives): the unit is the one R74's density option already
    /// speaks — "n high" is literally n card-heights — and at `gridRows`
    /// 3 the tallest column lands near one viewport (~1,000 pt), so every
    /// density setting stays usable; a 4× cap would make "3 high" taller
    /// than most screens and quietly kill a shipped option. It takes the
    /// prose visible in a margin card from ~4 lines to ~18.
    nonisolated static let marginCardCapHeight: CGFloat = 330

    /// A card's non-text furniture: `TakeCardFrame`'s 5 + 5 vertical
    /// padding plus the choose header's line (~16 pt). Used only to turn a
    /// pane's MEASURED text height into the card height around it.
    nonisolated static let cardChromeHeight: CGFloat = 26

    /// L4: a margin card's height — its content, bounded by the cap, never
    /// below the sticky-note height. `nil` (no measurement yet) is the
    /// first-bloom state and resolves to exactly today's fixed height, so
    /// the card never starts wrong, only settles taller.
    nonisolated static func marginCardHeight(measuredText: CGFloat?) -> CGFloat {
        guard let measuredText else { return railCardHeight }
        return min(max(measuredText + cardChromeHeight, railCardHeight), marginCardCapHeight)
    }

    /// **VX-136 (the VX-143 run) — THE GRID'S ROWS.** Her report: *"the margin
    /// grid items are a little bit weirdly misaligned when you have several"*.
    /// Each column used to stack its cards at their OWN heights (L4), so the
    /// second card of one column started wherever the first one ended — with
    /// two columns on screen (the ruled default past two takes) the rows
    /// staggered, and nothing lined up across the grid.
    ///
    /// A row's slot is the tallest card IN THAT ROW across ALL the block's
    /// columns — every page, not the visible one, so a row never moves as
    /// ◀ ▶ turn (13b 3F's steadiness, kept). The cards themselves keep their
    /// own heights inside their slots (L4's ruled sticky note stays a sticky
    /// note — `aShortTakesMarginCardStaysASticky`); the slot only says where
    /// the next row starts. Unmeasured cards read as one card-height, so the
    /// first bloom degrades to the uniform grid.
    nonisolated static func railRowHeights(
        cardTextHeights: [CGFloat?], rowsPerColumn: Int
    ) -> [CGFloat] {
        let rows = min(max(rowsPerColumn, 1), max(cardTextHeights.count, 1))
        guard !cardTextHeights.isEmpty else { return [railCardHeight] }
        return (0..<rows).map { row in
            stride(from: row, to: cardTextHeights.count, by: rows).reduce(CGFloat(0)) {
                max($0, marginCardHeight(measuredText: cardTextHeights[$1]))
            }
        }
    }

    /// L4's reserve, reworked from uniform rows × 110 to ACTUAL card
    /// heights bounded by the cap (the ruling's item 6).
    ///
    /// The max is taken over ALL columns, never the visible page — that is
    /// what keeps the reserve **page-independent**, so the article does not
    /// jump as ◀ ▶ turn (13b 3F's steadiness property, preserved through
    /// the change to variable heights). With no measurements yet it
    /// degrades to `min(cards, rows) × 110 + gaps`, which is byte-identical
    /// to the arithmetic it replaces.
    ///
    /// **VX-136: the reserve is the ROWS' sum** — the height the aligned
    /// grid actually stands at (`railRowHeights`). Wherever a column's
    /// tallest card sits in the same row as every other column's, that is
    /// the old tallest-column number to the point; it is larger only where
    /// two columns' tall cards sit in DIFFERENT rows, which is exactly the
    /// staggered shape the rows now line up.
    nonisolated static func reservedRailHeight(
        cardTextHeights: [CGFloat?], rowsPerColumn: Int
    ) -> CGFloat {
        guard !cardTextHeights.isEmpty else { return railCardHeight }
        let rows = railRowHeights(cardTextHeights: cardTextHeights, rowsPerColumn: rowsPerColumn)
        return rows.reduce(0, +) + CGFloat(max(rows.count - 1, 0)) * cardGap
    }

    /// **VX-136 — THE RULED DEFAULT** (her sitting, 2026-10-10, the question
    /// tool's recommended option: *"the margin grid defaults to TWO columns
    /// when the block has more than 2 takes"*). R74 keeps the choice hers:
    /// `choice` is what she picked in the `n wide` menu, and it always wins;
    /// nil — never picked, or "auto" — is the default, decided per BLOCK by
    /// the size of its fan. The default never shows a column the fan cannot
    /// fill (three takes in a three-high grid are one column, so one wide).
    nonisolated static func effectiveGridCols(
        choice: Int?, takeCount: Int, rowsPerColumn: Int
    ) -> Int {
        if let choice { return min(max(choice, 1), 2) }
        guard takeCount > 2 else { return 1 }
        let rows = max(rowsPerColumn, 1)
        let filledColumns = (takeCount + rows - 1) / rows
        return min(2, max(filledColumns, 1))
    }

    /// L3's drag clamp (the `CanvasBoardGeometry.clampedSize` precedent —
    /// a pure function, pinned without hosting).
    ///
    /// Floor: one card-height — below a sticky note the in-card scroll is
    /// useless. Ceiling: the slot's NATURAL height, and a drag that
    /// reaches it returns `nil` — full length — so pulling the handle back
    /// down is how she undoes a shorten, not a menu item she has to find.
    nonisolated static func clampedSlotHeight(
        _ proposed: CGFloat, naturalHeight: CGFloat?
    ) -> CGFloat? {
        if let naturalHeight, proposed >= naturalHeight - 1 { return nil }
        return max(proposed, railCardHeight)
    }

    // MARK: - Measured card heights (QoL batch 2 — the RULED seam)

    /// variantID → the pane's measured TEXT height, delivered by
    /// `PaneSurfaceView.onMeasuredHeight` on a deferred turn. Only the two
    /// compositions that size a wrapper subscribe (margin grid, slot
    /// split); every other pane leaves this untouched.
    private var measuredTextHeights: [String: CGFloat] = [:]

    /// Observation seam (the 1G `occasionsFired` precedent — a plain
    /// counter, not DEBUG-gated): how many deliveries actually CHANGED
    /// state, i.e. how many board invalidations this seam has caused. The
    /// settle pin asserts it stops growing; the carousel parity pin
    /// asserts it never moves at all there.
    @ObservationIgnored private(set) var measuredHeightWrites = 0

    func measuredTextHeight(_ variantID: String) -> CGFloat? {
        measuredTextHeights[variantID]
    }

    /// Equality-gated: a re-published identical measurement must not
    /// re-render the board. (The pane's own sink gates too; this is the
    /// second half of the same discipline, on the observable side.)
    func noteMeasuredTextHeight(_ variantID: String, _ height: CGFloat) {
        if let existing = measuredTextHeights[variantID], abs(existing - height) <= 0.5 {
            return
        }
        measuredHeightWrites += 1
        measuredTextHeights[variantID] = height
    }

    /// A slot's NATURAL height: the tallest card its fan would render at
    /// full length. `nil` until some pane has measured — the drag's
    /// ceiling is simply absent until then.
    func naturalSlotHeight(variantIDs: [String]) -> CGFloat? {
        let heights = variantIDs.compactMap { measuredTextHeights[$0] }
        guard let tallest = heights.max() else { return nil }
        return tallest + Self.cardChromeHeight
    }

    // MARK: - Slot heights (L3: "maybe the height of the block should
    // even be draggable?") — LOCAL view memory, the Canvas precedent

    /// blockID → the height she pulled this block's takes down to. Absent
    /// ⇒ FULL LENGTH (L3's ruled default for slot split). Persisted per
    /// post under its OWN defaults key, never synced.
    ///
    /// Why its own key and not a field on `TakesViewMemory`: that struct is
    /// decoded with `try?`, and Swift's synthesized `init(from:)` requires
    /// every key regardless of a property's default — so a new field would
    /// make every already-stored memory fail to decode and silently reset
    /// her column arrangements and alignment lock. (Adopted as a standing
    /// note for any future `TakesViewMemory` change.)
    private(set) var slotHeights: [String: CGFloat] = [:]
    /// The live drag, before it commits (the Canvas `resizeOffsets` shape).
    private var slotDragBaselines: [String: CGFloat] = [:]
    private var slotDragOffsets: [String: CGFloat] = [:]

    @ObservationIgnored private var postID: String?
    @ObservationIgnored private var defaults: UserDefaults = .standard

    /// **THE ARTICLE COLUMN'S SCROLL BRAIN** (13u2 UNIT E — KnownIssues row
    /// 51, the split owed three times): the landing, the reveals, the scroll
    /// memory and its restore, and the row-frame bookkeeping the three share
    /// — 876 lines that had no code dependency on anything else in this file.
    ///
    /// A plain `let` on an `@Observable` class, so Observation flows through
    /// the forwards below exactly as it flowed through the stored properties
    /// they replace: reading `layout.articleLanding` registers
    /// `article.articleLanding`.
    @ObservationIgnored let article: TakesArticleScroll

    init(
        postID: String? = nil, defaults: UserDefaults = .standard,
        lastCurrentRow: String? = nil
    ) {
        self.postID = postID
        self.defaults = defaults
        self.article = TakesArticleScroll(lastCurrentRow: lastCurrentRow)
        loadSlotHeights()
    }


    static let slotHeightsKeyPrefix = "takesSlotHeights."

    private var slotHeightsKey: String? {
        postID.map { Self.slotHeightsKeyPrefix + $0 }
    }

    private func loadSlotHeights() {
        guard let slotHeightsKey,
              let raw = defaults.dictionary(forKey: slotHeightsKey) as? [String: Double]
        else { return }
        slotHeights = raw.mapValues { CGFloat($0) }
    }

    private func saveSlotHeights() {
        guard let slotHeightsKey else { return }
        defaults.set(slotHeights.mapValues { Double($0) }, forKey: slotHeightsKey)
    }

    /// The height this block's take cards render at: `nil` = full length.
    /// A drag in flight shows live, clamped exactly as it will commit.
    func slotHeight(_ blockID: String, naturalHeight: CGFloat? = nil) -> CGFloat? {
        guard let offset = slotDragOffsets[blockID] else { return slotHeights[blockID] }
        let baseline = slotDragBaselines[blockID]
            ?? slotHeights[blockID] ?? naturalHeight ?? Self.railCardHeight
        return Self.clampedSlotHeight(baseline + offset, naturalHeight: naturalHeight)
    }

    func beginSlotDrag(_ blockID: String, naturalHeight: CGFloat?) {
        guard slotDragBaselines[blockID] == nil else { return }
        slotDragBaselines[blockID] =
            slotHeights[blockID] ?? naturalHeight ?? Self.railCardHeight
    }

    func slotDragChanged(_ blockID: String, translation: CGFloat) {
        slotDragOffsets[blockID] = translation
    }

    func slotDragEnded(_ blockID: String, translation: CGFloat, naturalHeight: CGFloat?) {
        let baseline = slotDragBaselines[blockID]
            ?? slotHeights[blockID] ?? naturalHeight ?? Self.railCardHeight
        if let clamped = Self.clampedSlotHeight(baseline + translation, naturalHeight: naturalHeight) {
            slotHeights[blockID] = clamped
        } else {
            slotHeights.removeValue(forKey: blockID)
        }
        slotDragOffsets.removeValue(forKey: blockID)
        slotDragBaselines.removeValue(forKey: blockID)
        saveSlotHeights()
    }

    /// "Full length" — the Canvas `resetSize` door.
    func resetSlotHeight(_ blockID: String) {
        slotHeights.removeValue(forKey: blockID)
        slotDragOffsets.removeValue(forKey: blockID)
        slotDragBaselines.removeValue(forKey: blockID)
        saveSlotHeights()
    }

    // MARK: - Follow-the-scroll (Phase 13 C2, R25)

    /// R25 — follow-the-scroll as a takes-viewing OPTION in all modes.
    /// Pushed by the View from the theme settings (models never read
    /// environments — the EditorView appearance pattern).
    var followTheScroll = false

    /// Near-viewport row bookkeeping: per-block REF COUNTS, because the
    /// multi-column compositions repeat a block's row — a disappear in one
    /// column must not blind the others. Observed (not ignored) so blooms
    /// re-render as rows come and go; when `followTheScroll` is off,
    /// `isBloomed` short-circuits before reading it, so Observation never
    /// tracks the churn (the calm default costs nothing).
    private var rowVisibility: [String: Int] = [:]

    func rowAppeared(_ blockID: String) {
        rowVisibility[blockID, default: 0] += 1
    }

    func rowDisappeared(_ blockID: String) {
        let next = (rowVisibility[blockID] ?? 0) - 1
        if next <= 0 {
            rowVisibility.removeValue(forKey: blockID)
        } else {
            rowVisibility[blockID] = next
        }
    }

    /// Whether a block's row is currently near the viewport (the
    /// conductor's `visibleFannedBlocks` derives from this against the
    /// projection, so a fan born mid-visibility is picked up without a
    /// re-appear).
    func isRowVisible(_ blockID: String) -> Bool {
        (rowVisibility[blockID] ?? 0) > 0
    }

    /// THE bloom rule (R25): explicitly expanded, OR — with follow-the-
    /// scroll on — any fanned row near the viewport.
    func isBloomed(_ slot: Queries.RenderedBlock) -> Bool {
        expandedBlocks.contains(slot.blockID)
            || (followTheScroll && slot.hasFan
                && (rowVisibility[slot.blockID] ?? 0) > 0)
    }

    /// R24's short/long rule for the margin grid: a SHORT fanned block gets
    /// the one-card-high horizontally-scrolling strip; longer blocks keep
    /// the vertical card column. The threshold is a character count (~200
    /// chars ≈ under three lines at the 68ch measure) — a BUILD-TIME CALL,
    /// recorded in the Stage C closeout + QUESTIONS #28.
    nonisolated static func usesHorizontalStrip(text: String?) -> Bool {
        (text ?? "").count < 200
    }

    // MARK: - Expansion (session-only)

    /// Fanned blocks currently bloomed — SESSION-ONLY by the plan's letter
    /// (fans stay open once expanded; close-all resets; nothing persists).
    private(set) var expandedBlocks: Set<String> = []

    /// The one insert door (reveals, landings, and the toggle share it).
    func bloom(_ blockID: String) {
        expandedBlocks.insert(blockID)
    }


    // MARK: - The article column's scroll brain — FORWARDS (13u2 UNIT E)
    //
    // **Every pre-move name, at its old address.** The 3C parity pattern: a
    // split that keeps its names is a MOVE, and a zero-test-edit suite is the
    // proof. Each forward is one line and does nothing but delegate — and
    // reading one registers the inner property with Observation, so views and
    // pins behave identically.
    //
    // Nested types come across as typealiases for the same reason: 35 call
    // sites say `TakesBoardLayout.ArticlePlace`, and a split that renamed
    // them would be a rewrite wearing a refactor's clothes.

    typealias ArticleLandingKind = TakesArticleScroll.ArticleLandingKind
    typealias ArticleReveal = TakesArticleScroll.ArticleReveal
    typealias ArticleLandingStep = TakesArticleScroll.ArticleLandingStep
    typealias ArticleRevealAim = TakesArticleScroll.ArticleRevealAim
    typealias ArticleGeometry = TakesArticleScroll.ArticleGeometry
    typealias ArticlePlace = TakesArticleScroll.ArticlePlace
    typealias ArticleRestore = TakesArticleScroll.ArticleRestore
    typealias ArticleRestoreStep = TakesArticleScroll.ArticleRestoreStep

    nonisolated static var articleLandingAttempts: Int {
        TakesArticleScroll.articleLandingAttempts
    }
    nonisolated static var articleRestoreAttempts: Int {
        TakesArticleScroll.articleRestoreAttempts
    }

    nonisolated static func landingOutranks(
        _ landing: String?, lastCurrentRow: String?
    ) -> Bool {
        TakesArticleScroll.landingOutranks(landing, lastCurrentRow: lastCurrentRow)
    }

    nonisolated static func revealDecision(
        rowFrame: CGRect?, viewportHeight: CGFloat
    ) -> ArticleReveal {
        TakesArticleScroll.revealDecision(rowFrame: rowFrame, viewportHeight: viewportHeight)
    }

    nonisolated static func revealAnchor(
        for placementID: String, rowFrame: CGRect?, order: [String], realizedRows: Set<String>
    ) -> ArticleRevealAim {
        TakesArticleScroll.revealAnchor(
            for: placementID, rowFrame: rowFrame, order: order, realizedRows: realizedRows)
    }

    var articleLastCurrentRow: String? { article.articleLastCurrentRow }
    var articleLanding: String? { article.articleLanding }
    var articleLandingKind: ArticleLandingKind { article.articleLandingKind }
    var articleLandingAims: Int { article.articleLandingAims }
    var articleViewportHeight: CGFloat { article.articleViewportHeight }
    var articleRowDepartures: Int { article.articleRowDepartures }
    var articleRestore: ArticleRestore { article.articleRestore }
    var articleRestoreAims: Int { article.articleRestoreAims }
    var articleGeometrySeen: Bool { article.articleGeometrySeen }
    var articleReadyForLanding: Bool { article.articleReadyForLanding }
    var articlePlaceNow: ArticlePlace? { article.articlePlaceNow }

    func landArticle(on placementID: String, kind: ArticleLandingKind = .entry) {
        article.landArticle(on: placementID, kind: kind)
    }

    func clearArticleLanding() {
        article.clearArticleLanding()
    }

    func articleLandingStep(order: @autoclosure () -> [String]) -> ArticleLandingStep {
        article.articleLandingStep(order: order())
    }

    /// 18l-b U2 — the view's report roads (a row frame, the geometry): the
    /// step until the watch has the landing, a report to the watch after.
    func articleLandingReport(order: @autoclosure () -> [String]) -> ArticleLandingStep {
        article.articleLandingReport(order: order())
    }

    /// 18l-b U2 — the watch's corrections (the view spends the step once each).
    var articleLandingCorrections: Int { article.articleLandingCorrections }

    /// The view model's two LIFECYCLE calls into the article brain, forwarded
    /// so the model talks to the layout everywhere (the round-1 ladder's
    /// NIT-1; `adopt`'s reach-through was pre-existing since 13u2 UNIT E —
    /// the rule is now one rule): the structural arm at adoption, and the
    /// watch's silent end at teardown.
    func noteProjectionArrived(_ projection: Queries.TakesProjection) {
        article.noteProjectionArrived(projection)
    }

    func endArticleLandingWatch() {
        article.endArticleLandingWatch()
    }

    @discardableResult
    func noteArticleRowFrame(_ placementID: String, _ frame: CGRect) -> Bool {
        article.noteArticleRowFrame(placementID, frame)
    }

    func articleRowFramesMoved() -> ArticleRestoreStep {
        article.articleRowFramesMoved()
    }

    func forgetArticleRowFrame(_ placementID: String) {
        article.forgetArticleRowFrame(placementID)
    }

    /// 18l-b U2: through the watch's her-scroll door
    /// (`TakesArticleScroll.articleGeometryArrived`), which hands a watched
    /// landing over and then runs the restore's decision byte-unchanged.
    func consumeArticleGeometry(
        _ geometry: ArticleGeometry, remembered: ArticlePlace?, positionedByUser: Bool,
        order: @autoclosure () -> [String]? = nil
    ) -> ArticleRestoreStep {
        article.articleGeometryArrived(
            geometry, remembered: remembered, positionedByUser: positionedByUser,
            order: order())
    }

    func toggleExpanded(_ blockID: String) {
        if expandedBlocks.contains(blockID) {
            expandedBlocks.remove(blockID)
        } else {
            expandedBlocks.insert(blockID)
        }
    }

    /// Expand-all-fans (AppSpec §12): every FANNED block blooms, in the set
    /// style; fans stay open once expanded; close-all resets. The conductor
    /// passes the projection's fanned set (this component never reads the
    /// projection).
    func expandAll(fannedBlockIDs: Set<String>) {
        expandedBlocks = fannedBlockIDs
    }

    func closeAllFans() {
        expandedBlocks = []
    }

    // MARK: - The block selection (13e E3 — her A18: "⌘-click in Takes to
    // select blocks to merge"; 13e E2 — her A17's multi-DELETE joins it)

    /// Blocks ⌘-clicked into the board's selection — SESSION-ONLY view state,
    /// exactly like expansion: it names what the author is pointing at, never
    /// anything the store keeps. It dies with the board.
    ///
    /// 13e batch 4 (E2): the STORAGE is now the shared `BlockSelection`
    /// brain, because Write's editor needed the same set and the same rules
    /// and a second copy is the drift class. The batch-2 member names below
    /// are kept as thin forwards (the 3C parity pattern — every batch-2 pin
    /// reads unmodified), and the selection now serves TWO acts: merge (E3)
    /// and delete (E2). It was never merge's private property; it is what
    /// the pointer is pointing at.
    private(set) var selection = BlockSelection()

    var mergeSelection: Set<String> { selection.picked }

    func toggleMergeSelection(_ blockID: String) {
        selection.toggle(blockID)
    }

    /// ⌘⇧-click: extend the run from the anchor (E2's addition — a run of
    /// blocks is exactly what a multi-delete addresses, and picking twelve
    /// of them one ⌘-click at a time is the friction her ask names).
    func extendMergeSelection(to blockID: String, in order: [String]) {
        selection.extend(to: blockID, in: order)
    }

    func clearMergeSelection() {
        guard !selection.isEmpty || selection.anchor != nil else { return }
        selection.clear()
    }

    func isSelectedForMerge(_ blockID: String) -> Bool {
        selection.contains(blockID)
    }

    /// Drops selected blocks the post no longer holds (a merge's own
    /// successors, a delete, a sync arrival) — the conductor passes the fresh
    /// slot set at adoption, exactly as it passes the fanned set to
    /// `expandAll`; this component never reads the projection.
    func pruneMergeSelection(to blockIDs: Set<String>) {
        selection.prune(to: blockIDs)
    }

    /// Batch 2's name for the shared rule (`BlockSelection.isContiguousRun`),
    /// kept so its pins read unmodified.
    nonisolated static func isContiguousRun(
        _ picked: Set<String>, in order: [String]
    ) -> Bool {
        BlockSelection.isContiguousRun(picked, in: order)
    }

    // MARK: - Discrete paging (session-only; model-owned)

    /// Per-key page offsets for the card rows (carousel, slot split, and —
    /// AD-2's fix — the margin rail): whole cards/columns, never halfway,
    /// an EXPLICIT ◀ ▶ door instead of an invisible horizontal scroll.
    /// Model-owned (13b 1a) so the AD-2 pin and the board soak can drive
    /// page coverage; session-only like expansion.
    private(set) var pageOffsets: [String: Int] = [:]

    /// The clamped current offset for a key (limit = last legal offset).
    func pageOffset(_ key: String, limit: Int) -> Int {
        min(max(pageOffsets[key] ?? 0, 0), max(limit, 0))
    }

    func stepPage(_ key: String, by delta: Int, limit: Int) {
        pageOffsets[key] = min(max(pageOffset(key, limit: limit) + delta, 0), max(limit, 0))
    }

    /// The reveal's direct page set (13b 3F — auto-page to the mint): the
    /// same clamped write the ◀ ▶ door makes, addressed absolutely.
    func setPage(_ key: String, to offset: Int, limit: Int) {
        pageOffsets[key] = min(max(offset, 0), max(limit, 0))
    }

    // MARK: - Density inputs + the rail's chunking (13b 1b — AD-2's
    // keyboard companion shares one brain with the board's rendering)

    /// Density inputs, pushed by the board (models never read @AppStorage).
    var beneathCount = 2
    var gridRows = 2
    /// R74's column CHOICE — nil while she has not picked one (or picked
    /// "auto"), which is VX-136's ruled default (`effectiveGridCols`).
    var gridColsChoice: Int?

    /// The pre-VX-136 name, kept as a forward so every pin that sets a
    /// density reads unchanged (the 3C parity pattern): a SET is her choice.
    /// The getter answers the choice, or 1 while none is made — a block's
    /// actual column count is `gridCols(takeCount:slotText:)`, which every
    /// renderer and pager asks.
    var gridCols: Int {
        get { gridColsChoice ?? 1 }
        set { gridColsChoice = newValue }
    }

    /// The columns ONE block's rail shows — her choice, else the ruled
    /// default for its fan (VX-136). One brain for the board's rendering and
    /// both pagers.
    func gridCols(takeCount: Int, slotText: String?) -> Int {
        Self.effectiveGridCols(
            choice: gridColsChoice, takeCount: takeCount,
            rowsPerColumn: railRowsPerColumn(slotText: slotText))
    }

    /// R24's strip exception, one brain with the board's chunking.
    func railRowsPerColumn(slotText: String?) -> Int {
        (Self.usesHorizontalStrip(text: slotText) && gridRows == 1) ? 1 : gridRows
    }

    nonisolated static func railPageKey(_ blockID: String) -> String { "rail-\(blockID)" }
}
