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

    /// L4's reserve, reworked from uniform rows × 110 to ACTUAL card
    /// heights bounded by the cap (the ruling's item 6).
    ///
    /// The max is taken over ALL columns, never the visible page — that is
    /// what keeps the reserve **page-independent**, so the article does not
    /// jump as ◀ ▶ turn (13b 3F's steadiness property, preserved through
    /// the change to variable heights). With no measurements yet it
    /// degrades to `min(cards, rows) × 110 + gaps`, which is byte-identical
    /// to the arithmetic it replaces.
    nonisolated static func reservedRailHeight(
        cardTextHeights: [CGFloat?], rowsPerColumn: Int
    ) -> CGFloat {
        let rows = max(rowsPerColumn, 1)
        guard !cardTextHeights.isEmpty else { return railCardHeight }
        var tallest: CGFloat = 0
        for start in stride(from: 0, to: cardTextHeights.count, by: rows) {
            let column = cardTextHeights[start..<min(start + rows, cardTextHeights.count)]
            let height = column.reduce(CGFloat(0)) { $0 + marginCardHeight(measuredText: $1) }
                + CGFloat(max(column.count - 1, 0)) * cardGap
            tallest = max(tallest, height)
        }
        return tallest
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

    init(
        postID: String? = nil, defaults: UserDefaults = .standard,
        lastCurrentRow: String? = nil
    ) {
        self.postID = postID
        self.defaults = defaults
        self.articleLastCurrentRow = lastCurrentRow
        loadSlotHeights()
    }

    /// **The block that was CURRENT when this board was LAST SHOWN** — its
    /// row's `placementID`, snapshotted from the session at construction
    /// (`EditorRouter.takesArticleCurrentRows`) and never moved after (17q
    /// piece 6, her ruling R-Q21).
    ///
    /// **A per-mount CONSTANT on purpose.** The value is a fact about the
    /// PREVIOUS showing, and this mount overwrites the session's copy within
    /// milliseconds — `consumeLandings` sets the entry ring (which writes it)
    /// BEFORE it sets the landing — so a live read would compare the landing
    /// against itself and the memory would always win. The session's copy is
    /// the NEXT mount's snapshot; this one is this mount's question.
    @ObservationIgnored let articleLastCurrentRow: String?

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

    // MARK: - The article's landing (17o batch b, ledger row 8)

    /// **The slot the article column is asked to scroll to** — a
    /// `placementID`, which is the article `ForEach`'s own identity (the Act
    /// 10 ladder's R1-3 lesson: the identity IS the anchor; an explicit `.id`
    /// drifts under a lazy column's estimate). Her words on row 8: *"open
    /// takes mode in write from the takes menu is also not automatically
    /// navigating you to where the take is"* — the board bloomed the block and
    /// put the ring on its pane, and left the page where it was.
    ///
    /// Session-only view geometry, like everything else here. Set once per
    /// landing, cleared by the article the moment it has scrolled, so a page
    /// she scrolls afterwards is never hauled back.
    private(set) var articleLanding: String?

    /// **Which door asked for the landing** (the 17q ladder, R1-2). The two
    /// arms name a row the same way and are revealed the same way; they
    /// differ in ONE thing — what they may lose to the remembered place.
    enum ArticleLandingKind: Equatable {
        /// The N9 entry arm: the note's CURRENT block, on every entry. Her
        /// rulings R-Q20/R-Q21 are about THIS landing — it outranks the
        /// memory when she moved blocks while away, and STANDS DOWN on a
        /// plain round trip (`resolveEntryLandingAgainstTheMemory`).
        case entry
        /// The fan-panel bloom door (17o row 8 — *"open takes mode in write
        /// from the takes menu is also not automatically navigating you to
        /// where the take is"*): a CLICK that asks to go there. It is weighed
        /// against nothing: the restore runs as it always has and the
        /// landing then reveals the bloomed block if the restored page does
        /// not show it — 17p's shipped road (R-Q1's letter for a bloom).
        /// The 17q ladder's R1-2 measured the alternative: with the
        /// stand-down applied to a bloom on the block the ring was last in,
        /// the page came back without the bloomed block on it.
        case bloom
    }

    @ObservationIgnored private(set) var articleLandingKind: ArticleLandingKind = .entry

    func landArticle(on placementID: String, kind: ArticleLandingKind = .entry) {
        articleLanding = placementID
        articleLandingKind = kind
        articleLandingAimsLeft = Self.articleLandingAttempts
        articleLandingAims = 0
        // **R-Q20 — THE LANDING WINS** (her 2026-09-13 ruling on J3), keyed
        // by R-Q21. A restore still aiming ends here, before it can move the
        // page: on the real board the geometry hook runs before the
        // projection (the article's ScrollView exists from the first layout;
        // `adopt` arrives on a `.task`), so this is the order the app takes.
        // Nothing has moved yet when it does — before the projection the
        // column holds no rows and `scrollTo` at an id it does not hold is a
        // no-op. The other order (a landing already pending at the first
        // geometry — every pin's, since `landingModel` adopts before
        // mounting) is answered in `consumeArticleGeometry`'s `.undecided`
        // branch, by the same resolver.
        if case .wanted = articleRestore { resolveEntryLandingAgainstTheMemory() }
    }

    /// **Which of the two wins, decided in ONE place** (17q piece 6, her
    /// rulings R-Q20 + R-Q21; the 17q ladder's R1-2/R1-3 made it the ONE
    /// site) — called at the two moments an ENTRY landing and a remembered
    /// page first meet: the landing arriving while a restore is pending
    /// (`landArticle`, the app's order), and the first geometry finding a
    /// landing already pending (`consumeArticleGeometry`'s `.undecided`
    /// branch, the pins' order). A BLOOM landing is never weighed here: it
    /// rides through the restore and reveals afterwards (17o row 8's door,
    /// 17p's shipped road — `ArticleLandingKind`).
    ///
    /// The landing names a DIFFERENT block than the one that was current
    /// when the board was last shown ⇒ she MOVED, so the landing wins and
    /// the restore ends before it can aim. The landing names the SAME block
    /// ⇒ this is a plain round trip, so **the landing stands down** and the
    /// restore puts the page back exactly as she left it — the TOP included
    /// (a page left at rest with her block scrolled off it comes back at
    /// rest; the memory is the page, not the block).
    ///
    /// **Why the landing has to stand down and not merely lose the race**
    /// (the 17q walk measured it, on her 262-block note): the two are not
    /// exclusive — a kept-alive landing re-aims through the lazy column's
    /// settling passes, where rows report PLACEHOLDER frames first (J1's
    /// finding (b)), so it can judge a row that IS on screen to be off it and
    /// pull the page to the foot AFTER the restore has put it back. The pin's
    /// 60-block note came out restored and her 262-block one came out
    /// revealed — the same rule, two outcomes, decided by a race. Her R-Q21
    /// says *exactly* as she left it, and a race is not exactly.
    ///
    /// The accepted consequence, stated: if she left Takes having scrolled
    /// AWAY from her own block, a plain round trip brings back that page —
    /// without her block on screen. That is what "the page she left" means,
    /// and revealing it would be the second move her ruling removes.
    private func resolveEntryLandingAgainstTheMemory() {
        guard articleLanding != nil, articleLandingKind == .entry else { return }
        if Self.landingOutranks(articleLanding, lastCurrentRow: articleLastCurrentRow) {
            articleRestore = .settled
        } else {
            articleLanding = nil
        }
    }

    /// **R-Q20, as a rule** (her words on J3: *"the block I came from
    /// wins"*; her reasoning: *"switching between different modes is supposed
    /// to be seamless and keep the place you're writing in"*) — **keyed on
    /// what "the same block" MEANS by her ruling R-Q21 (2026-09-12):
    /// the note's CURRENT block did not CHANGE while she was away.**
    ///
    /// So a landing outranks the remembered place **iff it names a different
    /// block than the one that was current when the board was last shown**
    /// (`articleLastCurrentRow`). A plain mode round trip — leave Takes, ⌘1,
    /// ⌘2, nothing clicked — therefore restores the page EXACTLY as she left
    /// it, and only a deliberate move to another block makes the landing win,
    /// in which case the page opens where a mount starts (the top) and the
    /// landing reveals from there: ONE move where J3 measured two.
    ///
    /// **Why it is keyed on the current block and not on the remembered ROW
    /// (the 17q walk's measurement, and her ruling on it).** The first build
    /// read "the same block" as *the landing's row equals the row at the top
    /// of the page she left* — and the walk measured what that means: the two
    /// coincide only when her block happens to straddle the fold, so the
    /// restore practically never ran and a PLAIN round trip moved the page.
    /// Her own reason for R-Q20 argues against exactly that, and she ruled
    /// the other reading (R-Q21, J14).
    ///
    /// **The two nil cases, stated.** No landing at all ⇒ the memory rules,
    /// as it always has. A landing with NO recorded prior current block ⇒ the
    /// landing rules: we cannot claim "the same block" about a showing we
    /// have no record of, and the case is either a first entry (where there
    /// is no memory to restore either, so it costs nothing) or a previous
    /// mount that went away before its projection landed.
    ///
    /// **What this predicate does NOT decide (the 17q ladder, R1-2):** it is
    /// consulted for the ENTRY landing only. Piece 6 first kept a losing
    /// landing alive (so a page she had scrolled away from her own block got
    /// one reveal), then the walk forced the stand-down — and the stand-down
    /// written without distinguishing the arms also stood down the fan-panel
    /// bloom door's *"go there"* (row 8): measured at the ladder, a bloom on
    /// the block the ring was last in came back with the bloomed block off
    /// the page. So the arms ARE distinguished (`ArticleLandingKind`): an
    /// entry landing outranks or stands down by this rule; a bloom landing
    /// rides through the restore and reveals afterwards, as 17p shipped it.
    nonisolated static func landingOutranks(
        _ landing: String?, lastCurrentRow: String?
    ) -> Bool {
        guard let landing else { return false }
        guard let lastCurrentRow else { return true }
        return landing != lastCurrentRow
    }

    /// Her hand ends a landing. The request is otherwise kept through the
    /// column's settling passes (see `ArticleLandingStep`).
    ///
    /// **THE RULE (settled at the 17p batch-a ladder's final word, so the
    /// next arm is not guesswork):** a landing is a REVEAL kept alive only
    /// against the lazy column's own settling; what can defeat it after that
    /// is a change to the article's CONTENT HEIGHT, to its VIEWPORT HEIGHT
    /// (chrome appearing above it — the ladder's round 3, R3-1: the
    /// selection banner), or to the LIVE PANE — so her hand is every gesture
    /// that can do any of the three, and the arms sit at the view model's
    /// GESTURE DOORS for those, never at a model method a programmatic road
    /// shares. The arms: her scroll of the article
    /// (`consumeArticleGeometry`'s user branch); a click that migrates the
    /// live pane (`focus`'s `.migrated` arm only — the landed pane's own
    /// first-responder round trip is `.unchanged` and must not end it); a
    /// keystroke (`paneEdited`); the expansion doors (`toggleExpanded` /
    /// `expandAllFans` / `closeAllFans`); the slot-height drag and its
    /// double-click (`beginSlotDrag` / `resetSlotHeight`); every Operations
    /// call through `run` / `runCopying`; and the three bare-runner doors that
    /// change content height with neither a migration nor a gone row —
    /// `applyCallout` (a frame's pad), the split doors' one body
    /// (`TakesStructureController.runSplit`: rows multiply above) and
    /// `turnTakesIntoBlocks` (rows minted above when a card above is the
    /// target) — the ladder's round 2, R2-1, measured: the note-wide split
    /// hauled the page 406 → 1047 after her click, a callout above the landed
    /// row 65 → 75; and the two ⌘-PICK doors (`toggleMergeSelection` /
    /// `extendMergeSelection`) plus the banner's `deleteSelectedBlocks` — the
    /// ladder's round 3, R3-1, measured: ONE pick moved the page 65 → 93
    /// (the banner's 28 pt of viewport), the delete itself nothing.
    ///
    /// **COMPLETENESS IS BY ENUMERATION, NEVER "BY CONSTRUCTION"** (round 1
    /// claimed the latter for the structure controller and round 2 falsified
    /// it): every Operations road reachable from the Takes board, classified.
    /// The next arm is a row in this table, not a guess.
    ///
    /// | road | height / live pane? | covered by |
    /// |---|---|---|
    /// | every `run` / `runCopying` caller (choose · pick · the lens doors · set fan style · archive / unarchive / label / lock / delete take · commit · seal · entry date · the newlines chip · word target · restore commit · the drag-reorder) | various | the `run` arm — no programmatic caller of `run` exists |
    /// | `branchTake` · `newBlankTake` · `newBlankTakeAsChosen` | yes (the fan grows) | `revealTake` → `focus` → `.migrated` (a fresh variant is never the live pane) |
    /// | the ceremony (`runDivideW` · `runDivideDuplicating`) | yes | the target is the landed (focused) block → A released → the row gone → `.done` |
    /// | `addBlockAtEnd` · `insertBlockBelowFocused` · `deleteFocusedBlock` · `archiveFocusedBlock` · `runDivide` · `runKeepOnTopDivide` · `moveTakeIntoBlockBelow` · `mergeSelectedBlocks` | yes | `parkFocus` → `focus` → `.migrated`; a one-block delete → the row gone |
    /// | `moveTake` (reorder within the fan) | no (same cards, same height) | — |
    /// | `runSplit` (three doors) · `turnTakesIntoBlocks` · `applyCallout` | yes | THEIR OWN ARMS (R2-1) |
    /// | the ⌘-click PICK (`toggleMergeSelection` · `extendMergeSelection`) | VIEWPORT height (the selection banner appears above the article) | THEIR OWN ARMS (R3-1 — round 1 dismissed the pick as "a stroke overlay, no layout effect": true of the CELL, blind to the BANNER. Measured: one pick 65 → 93, the banner's 28 pt, nine more aims; the same pick with no landing pending moves nothing) |
    /// | `deleteSelectedBlocks` (the banner's Delete · the card row's delete-picked) | yes (rows removed; a ⌘-click never migrates the ring) | ITS OWN ARM (R3-1, the rule's letter — round 2 EXEMPTED this row by argument; measured at round 3 the delete itself moves nothing (no-landing control 65 → 65) and the pick before it has already ended the landing, so this arm is the letter, not the mover. No row in this table is argued any more — every door that can change content or viewport height is ARMED) |
    /// | the Lenses-host-only column roads (`addWriteColumn` · `branchIntoColumn` · `adoptColumn` · …) | n/a | host-gated; the Lenses board holds no article landing |
    /// | `saveNoteVersion` | no (the copy is born archived) | — |
    ///
    /// Deliberately NOT arms: a fan strip's page turn (a fixed strip height —
    /// and `setPage` is shared with the strip's settled-scroll write-back, a
    /// programmatic road after `pageToReveal`); `clearMergeSelection` (the
    /// banner's "clear" AND the structure controller's post-act clears — a
    /// shared road, and a banner LEAVING grows the viewport, which can clip
    /// nothing); the density menus (`beneathCount` cannot change height —
    /// N40's fixed strip; `gridRows` measured moving nothing in the reachable
    /// margin-grid shape at round 2) — none can move the article page, and an
    /// arm on a shared road would end a landing her hand did not. (Round 1
    /// listed "the merge pick" here as a stroke overlay with no layout
    /// effect; round 3 measured the pick's BANNER shrinking the viewport, so
    /// the two pick doors are arms above.) A future gesture that changes a
    /// row's height, the viewport's height or the live pane adds its door
    /// here, its row above, and its arm in the pin
    /// (`herBoardGesturesEndAPendingLanding`).
    ///
    /// The structural end state, recorded for the `TakesArticleScroll` split
    /// (owner 13u2), not built here: ONE arm in `adopt` — a projection that
    /// arrives while a landing is pending and differs from the one it was
    /// judged against ends it — makes every Operations road, hers or a sync
    /// arrival's, end a landing by construction. `!=` on the projection fires
    /// on any field, so a pure metadata arrival would end one too; chosen
    /// behaviour to write down there, not to discover.
    func clearArticleLanding() {
        articleLanding = nil
    }

    // MARK: - The landing REVEALS (17p batch a, ledger row 1 — her ruling R-Q1)

    /// What a landing may ask the article for. **Never a top anchor:** her
    /// words on the shipped behaviour were *"the page keeps trying to jump to
    /// the bottom and now show the text above"* — anchoring a slot's top at
    /// the viewport's top is exactly what pushed every earlier block off the
    /// screen, and the typewriter room made the LAST block a legal place to
    /// stop. A landing now either does nothing or reveals, minimally.
    enum ArticleReveal: Equatable {
        /// The slot is already fully on screen; the page does not move.
        case none
        /// The slot is not fully on screen: scroll the minimum that shows it
        /// (`anchor: nil`), never to the top.
        case reveal
    }

    /// **THE RULE, pure.** `rowFrame` is the row's frame in the article scroll
    /// view's own space (`.scrollView`), i.e. `minY == 0` is the viewport's
    /// top edge. A row we have no frame for is one a lazy column has not
    /// realized — which is proof it is NOT on screen, so it reveals; and a
    /// viewport we have not measured yet decides nothing, so it reveals too
    /// and the view's own minimal scroll settles the rest.
    nonisolated static func revealDecision(
        rowFrame: CGRect?, viewportHeight: CGFloat
    ) -> ArticleReveal {
        guard viewportHeight > 0, let rowFrame else { return .reveal }
        // A row TALLER than the viewport can never be fully on screen; it is
        // revealed when its top is (nothing above it could stay visible
        // anyway, so "minimal" and "top" coincide for that one shape).
        if rowFrame.height > viewportHeight {
            return rowFrame.minY >= -0.5 && rowFrame.minY < viewportHeight - 0.5
                ? .none : .reveal
        }
        // A generous pixel of slack: a row flush with an edge is on screen.
        return rowFrame.minY >= -0.5 && rowFrame.maxY <= viewportHeight + 0.5
            ? .none : .reveal
    }

    /// **THE LANDING, as a bounded step machine** (the 17p batch-a
    /// adjudication, J1). Measured at that adjudication, on the mounted board:
    /// (1) the landing was spent at the article's FIRST geometry report, with
    /// zero rows realized, and a scroll against a row a lazy column has not
    /// realized is a no-op; (2) a lazy column's rows report PLACEHOLDER
    /// frames first (every row 28 pt, then 50, then their measured heights,
    /// each pass on its own turn), so "the row is on screen" read from an
    /// early frame is the starved-host class — true for a page that does not
    /// exist yet; (3) the article's position is a bound `ScrollPosition`,
    /// which SwiftUI re-applies on every relayout until her hand moves the
    /// page, so a one-shot scroll is undone by the next content-size change
    /// (65 pt, then back to 0). No local signal says "measurement is
    /// complete", so the request does what the restore beside it does: it
    /// STAYS and re-aims as the column settles (bounded), and it ends at HER
    /// HAND — a scroll, a click into another pane, an edit — never at a
    /// frame that may be a placeholder.
    enum ArticleLandingStep: Equatable {
        /// Nothing pending (or the row is gone from the note).
        case done
        /// Keep the request; nothing to do this turn (no geometry yet, the
        /// restore still running, a column that has laid out nothing, or the
        /// row on screen right now).
        case wait
        /// Scroll this row to this edge of the page.
        case reveal(String, ArticleRevealAim)
    }

    /// Which edge of the page a reveal puts the row at — the MINIMAL scroll
    /// stated as an edge: a row below the fold comes up to the foot (the rows
    /// above it stay), a row above the fold comes down to the head. A row the
    /// column has not realized is placed by which side of the realized rows
    /// it lies on. A model-side word, mapped to a SwiftUI anchor by the view.
    /// Never the far edge: her words on the shipped behaviour were *"the page
    /// keeps trying to jump to the bottom and now show the text above"*.
    enum ArticleRevealAim: Equatable {
        case head
        case foot
    }

    /// Bounded, so a request can never loop: every aim is one idempotent
    /// scroll, and the column settles in a handful of passes.
    nonisolated static let articleLandingAttempts = 64
    @ObservationIgnored private var articleLandingAimsLeft = articleLandingAttempts
    /// Observation seam (the `measuredHeightWrites` precedent — a plain
    /// counter, not DEBUG-gated): how many aims the current landing issued.
    /// The pins' non-vacuity: a far block aimed at least once; a block already
    /// on screen never did.
    @ObservationIgnored private(set) var articleLandingAims = 0

    /// `order` is the article's slots in `ForEach` order (their placement ids)
    /// — an AUTOCLOSURE, evaluated only past the guards (the 17p batch-a
    /// ladder, R1-3): this step runs from every realized row's frame report
    /// at scroll rate, and with nothing pending it must cost nothing in the
    /// note's block count (P1's letter — cost ∝ the viewport, never the
    /// document).
    func articleLandingStep(order: @autoclosure () -> [String]) -> ArticleLandingStep {
        guard let landing = articleLanding else { return .done }
        guard articleReadyForLanding else { return .wait }
        let order = order()
        guard order.contains(landing) else {
            articleLanding = nil   // the row is gone from the note
            return .done
        }
        let frame = articleRowFrames[landing]
        if frame == nil, articleRowFrames.isEmpty { return .wait }
        if Self.revealDecision(rowFrame: frame, viewportHeight: articleViewportHeight) == .none {
            return .wait   // on screen now; the request stays until her hand
        }
        guard articleLandingAimsLeft > 0 else {
            articleLanding = nil
            return .done
        }
        articleLandingAimsLeft -= 1
        articleLandingAims += 1
        return .reveal(
            landing,
            Self.revealAnchor(
                for: landing, rowFrame: frame, order: order,
                realizedRows: Set(articleRowFrames.keys)))
    }

    /// Pure: which edge reaches the row. A realized row goes by its frame —
    /// above the fold → `.head`, else `.foot`. An unrealized row lies beyond
    /// the realized rows on one side — below them → `.foot` (it lands at the
    /// foot with the rows above it still showing), above them → `.head`. A
    /// shape that says neither takes `.foot` (a landing is a block she was
    /// working in, and the page opens at the top).
    nonisolated static func revealAnchor(
        for placementID: String, rowFrame: CGRect?, order: [String], realizedRows: Set<String>
    ) -> ArticleRevealAim {
        if let rowFrame { return rowFrame.minY < 0 ? .head : .foot }
        guard let target = order.firstIndex(of: placementID) else { return .foot }
        let indices = order.indices.filter { realizedRows.contains(order[$0]) }
        guard let low = indices.min(), let high = indices.max() else { return .foot }
        if target > high { return .foot }
        if target < low { return .head }
        return .foot
    }

    /// The realized article rows' frames in the scroll view's own space, and
    /// the viewport they are measured against. **`@ObservationIgnored` on
    /// purpose:** these are written on every scroll frame by the rows' own
    /// geometry hooks, and nothing renders FROM them — they answer one
    /// question, at the moment a landing arrives. Observing them would
    /// re-render the whole article at scroll rate (P1's letter: cost ∝ the
    /// viewport, and a re-render per frame is not that).
    @ObservationIgnored private var articleRowFrames: [String: CGRect] = [:]
    @ObservationIgnored private(set) var articleViewportHeight: CGFloat = 0

    /// Equality-gated, like every other geometry sink on this component: a
    /// row re-reporting the same place inside one layout pass writes nothing.
    func noteArticleRowFrame(_ placementID: String, _ frame: CGRect) {
        if let existing = articleRowFrames[placementID],
           abs(existing.minY - frame.minY) < 0.5,
           abs(existing.height - frame.height) < 0.5 {
            return
        }
        articleRowFrames[placementID] = frame
    }

    func forgetArticleRowFrame(_ placementID: String) {
        articleRowFrames.removeValue(forKey: placementID)
    }

    // MARK: - The scroll memory's one-shot restore (17p batch a, row 1)

    /// The article's scroll geometry, reduced to the three numbers the memory
    /// needs (Equatable, so the view's hook republishes only when one of them
    /// actually moves).
    struct ArticleGeometry: Equatable {
        let offset: CGFloat
        let content: CGFloat
        let viewport: CGFloat

        /// How far the article can scroll — the restore clamps to it, because
        /// a note edited elsewhere may be shorter than when she left it.
        var travel: CGFloat { max(content - viewport, 0) }
    }

    /// **Where the article was left: the BLOCK at the top of the page.**
    ///
    /// Deliberately a row identity and nothing else. Two measurements decided
    /// the shape, both taken at this batch:
    ///
    /// 1. A raw content OFFSET is not the same number for the same view twice
    ///    in a lazy column — the rows above the fold are estimated until they
    ///    are realized, so the same y means a different block on the way back
    ///    (96 pt and nine blocks apart on a sixty-block note; ~390 pt on her
    ///    262-block one).
    /// 2. A row identity PLUS the pixels she was into it looks more faithful
    ///    and is not: the pixel half has to be applied as a RELATIVE nudge,
    ///    and the row frames and the scroll geometry arrive in different
    ///    passes — a nudge computed from a frame one pass stale doubled its
    ///    own correction and landed 896 where 800 was owed.
    ///
    /// So the promise is exactly what a reader can state and a pin can check:
    /// **the block she was reading comes back to the top of the page.** A
    /// `scrollTo(id, anchor: .top)` is absolute and idempotent, so re-aiming
    /// as the column's real heights arrive converges instead of drifting.
    ///
    /// **The TOP is a place of its own** (the 17p batch-a ladder, R1-1 —
    /// measured: a page left at offset 0 came back at 18, on every return).
    /// The column's own top padding puts row 1 at `minY 18` when the page is
    /// at rest, so "row 1 at the top of the viewport" is NOT where a page at
    /// rest sits — aligning that row's top with the viewport's top scrolls
    /// past the padding. A page left at the top therefore remembers the top
    /// itself, and a mount that starts there (every mount does) issues no
    /// scroll at all.
    ///
    /// **The promise is CONDITIONAL since 17q** (her rulings R-Q20 *"the
    /// block I came from wins"* and R-Q21 on what *"the same block"* means):
    /// the block she was reading comes back to the top of the page when she
    /// returns with no entry landing, or on the SAME block she was in when
    /// she left — which is every plain mode round trip. A landing naming a
    /// block she moved to while away outranks the memory and the restore
    /// never runs — see `landingOutranks`.
    struct ArticlePlace: Equatable {
        /// The `placementID` of the row at the top of the viewport — or nil
        /// for the TOP of the page itself.
        let rowID: String?

        /// The page at rest: nothing above the first row.
        static let top = ArticlePlace(rowID: nil)
    }

    /// The one-shot restore's state. `.undecided` until the FIRST honest
    /// geometry — **never resolved in `onAppear`**, whose ordering against
    /// that first geometry event is not ours to assume (measured at this
    /// batch: the geometry hook fires first, and a mount that records its own
    /// 0 before reading the memory erases the very thing it came back for).
    /// `.wanted` then holds while the article finds the row again — the 17o
    /// batch-b ladder's RAISE-M1 lesson (never restore against a frame that
    /// has not been filled) in this surface's vocabulary.
    enum ArticleRestore: Equatable {
        case undecided
        case wanted(ArticlePlace)
        case settled
    }

    /// What the view should do with a geometry report.
    enum ArticleRestoreStep: Equatable {
        /// Scroll to this row (the coarse aim, for a row a lazy column has
        /// not realized yet — the only scroll that can reach one).
        case scrollToRow(String)
        /// Write this place into the session's memory.
        case remember(ArticlePlace)
        /// Wait — nothing to do this turn.
        case wait
    }

    /// How many coarse aims a restore may take before it gives up. Bounded so
    /// a row the column never brings to the fold settles instead of aiming
    /// forever — a restore that never settles would also never let a landing
    /// be spent. The bound counts GEOMETRY REPORTS (one aim per report), so
    /// it cannot cover a row the note no longer holds: `scrollTo` on a gone
    /// row is a no-op, the geometry stops changing, and the count stops with
    /// it — that case settles at once by the slot order instead (the 17p
    /// batch-a ladder, R1-4).
    nonisolated static let articleRestoreAttempts = 24

    @ObservationIgnored private(set) var articleRestore: ArticleRestore = .undecided
    @ObservationIgnored private var articleRestoreAimsLeft = articleRestoreAttempts
    /// Observation seam (the `articleLandingAims` precedent — a plain
    /// counter, not DEBUG-gated): how many coarse aims the restore has
    /// issued. **It is R-Q20's own red-on-old**: a landing that outranks the
    /// remembered place must leave the page alone, and "left alone" is
    /// measurable only as zero aims — the two roads end at the same rest
    /// (a reveal's `scrollTo(row, .bottom)` is absolute), so what her ruling
    /// removes is the MOVE, not the destination.
    @ObservationIgnored private(set) var articleRestoreAims = 0
    /// The article has reported real geometry at least once. Until it has,
    /// nothing knows where anything is, so no landing may be spent.
    @ObservationIgnored private(set) var articleGeometrySeen = false

    /// True once the page is where the memory says it should be — the moment
    /// a landing may be considered, and not before (a reveal judged against a
    /// position we are about to change would be judged against the wrong page).
    var articleReadyForLanding: Bool {
        articleGeometrySeen && articleRestore == .settled
    }

    /// The row at the top of the viewport right now — the place worth
    /// remembering. The lowest row whose top is at or above the fold (the one
    /// she is reading through); failing that, the first row below it.
    var articlePlaceNow: ArticlePlace? {
        var best: (id: String, minY: CGFloat)?
        for (id, frame) in articleRowFrames where frame.minY <= 0.5 {
            if best == nil || frame.minY > best!.minY { best = (id, frame.minY) }
        }
        if best == nil {
            for (id, frame) in articleRowFrames {
                if best == nil || frame.minY < best!.minY { best = (id, frame.minY) }
            }
        }
        return best.map { ArticlePlace(rowID: $0.id) }
    }

    /// **THE RESTORE, as a decision.** Pure but for its own state, so the
    /// whole rule can be pinned without a window: what the article should do,
    /// given where it is, what it remembers, and whether her hand has already
    /// moved it.
    ///
    /// `order` is the article's slots in `ForEach` order, or nil while the
    /// note's slots are not yet known (the projection may still be loading
    /// at the first geometry report). An autoclosure, read only while a
    /// restore is pending: a remembered row the note no longer holds — a
    /// block deleted, merged or divided away while she was in Write or on
    /// the phone — settles the restore AT ONCE, so the landing still lands
    /// and the memory is corrected (R1-4; measured: without it the restore
    /// starved the entry landing for the rest of the session's entries).
    func consumeArticleGeometry(
        _ geometry: ArticleGeometry, remembered: ArticlePlace?, positionedByUser: Bool,
        order: @autoclosure () -> [String]? = nil
    ) -> ArticleRestoreStep {
        guard geometry.viewport > 0 else { return .wait }
        articleGeometrySeen = true
        articleViewportHeight = geometry.viewport
        // Her hand outranks a pending LANDING too: a request that outlived
        // its moment must never haul a page she has since scrolled (the 17o
        // batch-b BLOCKER's class).
        if positionedByUser { articleLanding = nil }
        switch articleRestore {
        case .undecided:
            // Read the memory BEFORE this mount has written anything into it.
            // **A page she left meets a landing already pending — once, here,
            // through the ONE resolver** (17q, her R-Q20 keyed by R-Q21; the
            // ladder's R1-3 folded the inline copy): an ENTRY landing on a
            // block she moved to while away settles the restore before it
            // can aim (the block she came from wins — the page starts at the
            // top and the landing reveals from there); an entry landing on
            // the block she was in stands down, and the page comes back
            // exactly — the TOP included; a bloom landing is not weighed.
            // With NO memory there is nothing to weigh and nothing to lose.
            if remembered != nil { resolveEntryLandingAgainstTheMemory() }
            if articleRestore == .settled { return rememberStep(geometry) }
            // No memory, or the TOP remembered: a mount starts at the top, so
            // there is nothing to scroll to — settled at once, no scroll
            // issued (R1-1).
            guard let remembered, remembered.rowID != nil else {
                articleRestore = .settled
                return rememberStep(geometry)
            }
            articleRestore = .wanted(remembered)
            articleRestoreAimsLeft = Self.articleRestoreAttempts
            return restoreStep(
                to: remembered, geometry, positionedByUser: positionedByUser, order: order())
        case .wanted(let place):
            return restoreStep(
                to: place, geometry, positionedByUser: positionedByUser, order: order())
        case .settled:
            return rememberStep(geometry)
        }
    }

    /// A page at rest remembers the TOP itself (R1-1); a scrolled page
    /// remembers the row at the top of the viewport.
    private func rememberStep(_ geometry: ArticleGeometry) -> ArticleRestoreStep {
        if geometry.offset <= 0.5 { return .remember(.top) }
        return articlePlaceNow.map { .remember($0) } ?? .wait
    }

    private func restoreStep(
        to place: ArticlePlace, _ geometry: ArticleGeometry, positionedByUser: Bool,
        order: [String]?
    ) -> ArticleRestoreStep {
        // Her hand outranks a pending restore: if she has already scrolled
        // this page herself, the restore is over and we remember her place.
        if positionedByUser {
            articleRestore = .settled
            return rememberStep(geometry)
        }
        // The TOP never reaches `.wanted` (it settles at `.undecided`); total
        // for the type's sake.
        guard let rowID = place.rowID else {
            articleRestore = .settled
            return rememberStep(geometry)
        }
        // A row the note no longer holds settles at once (R1-4): there is
        // nothing to scroll to, and waiting would starve the landing. Only
        // once the slots are KNOWN — nil means the projection has not
        // arrived, and the aim below is kept until it does.
        if let order, !order.contains(rowID) {
            articleRestore = .settled
            return rememberStep(geometry)
        }
        // **Settled when the ROW says so**, never when an offset we computed
        // says so: a lazy column re-lays out under a scroll, and the row
        // frames and the scroll geometry arrive in different passes.
        if let frame = articleRowFrames[rowID], abs(frame.minY) <= 2 {
            articleRestore = .settled
            return .wait
        }
        // Otherwise aim again. The aim is ABSOLUTE (scroll this row to the
        // top) and therefore idempotent: re-aiming as the real heights arrive
        // converges, where a relative nudge computed from a stale frame
        // doubles its own correction.
        guard articleRestoreAimsLeft > 0 else {
            articleRestore = .settled   // the row is gone, or will not settle.
            return .wait
        }
        articleRestoreAimsLeft -= 1
        articleRestoreAims += 1
        return .scrollToRow(rowID)
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
    var gridCols = 1

    /// R24's strip exception, one brain with the board's chunking.
    func railRowsPerColumn(slotText: String?) -> Int {
        (Self.usesHorizontalStrip(text: slotText) && gridRows == 1) ? 1 : gridRows
    }

    nonisolated static func railPageKey(_ blockID: String) -> String { "rail-\(blockID)" }
}
