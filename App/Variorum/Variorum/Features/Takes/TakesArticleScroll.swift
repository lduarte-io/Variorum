//
//  TakesArticleScroll.swift
//  Variorum
//
//  13u2 UNIT E — **the `TakesArticleScroll` split**
//  (`KnownIssuesAndTechDebt` row 51, owed THREE times: named at the 17p
//  batch-a ladder's R1-6, declined at the 17q ladder's R1-3, and handed to
//  this phase by 13u1).
//
//  WHAT THIS IS: the Takes ARTICLE COLUMN's scroll brain — the landing (which
//  row the column is asked to reveal, and which door asked), the reveal
//  arithmetic, the per-mount scroll MEMORY and its one-shot restore, the
//  hold that keeps a restore aimed at one absolute place through SwiftUI's
//  later re-resolution passes, and the row-frame bookkeeping all three read.
//  It grew to 876 of `TakesBoardLayout`'s 1,302 lines across three rounds
//  (17p batch a, 17q, and 17q's own ladder), which is what made the row's
//  own completeness argument hard to hold: the ONE thing in that file that
//  is not "session-only view geometry a board renders from" was two thirds
//  of it.
//
//  **THE SPLIT IS A MOVE, NOT A CHANGE** (the 3C parity pattern, which this
//  codebase uses for every hoist): every pre-move name stays reachable at its
//  old address — `TakesBoardLayout` holds one of these and forwards every
//  property, method, static and nested type — so **not one test was edited**,
//  and a zero-test-edit suite is the proof that an address moved and a
//  behaviour did not. The region moved with NO edits to its bodies: it had no
//  code dependency on the rest of `TakesBoardLayout` at all (verified symbol
//  by symbol before the move), which is itself the argument that it was
//  always a separate thing.
//
//  **Observation is preserved by construction.** This is its own `@Observable`
//  class held as a plain `let`, and the forwards are computed properties — so
//  a view reading `layout.articleLanding` registers `article.articleLanding`
//  exactly as it registered the stored property before. The
//  `@ObservationIgnored` markers rode across unchanged, which matters: several
//  of these are deliberately untracked (the aim counters, the geometry
//  snapshots) because a view must not re-render on a settling pass.
//
//  **The per-mount constant rode too.** `articleLastCurrentRow` is a fact
//  about the PREVIOUS showing, snapshotted at construction and never moved
//  (17q piece 6, her ruling R-Q21) — it is read only by this brain, so it
//  lives here now and `TakesBoardLayout` forwards it.
//

import CoreGraphics
import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class TakesArticleScroll {
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

    init(lastCurrentRow: String? = nil) {
        self.articleLastCurrentRow = lastCurrentRow
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
        // no-op. **The condition is "a page to come back to", never "a
        // restore pending"** (the 17q ladder's round 2, R2-1): a TOP memory
        // settles at the first geometry without ever reaching `.wanted`, and
        // the entry landing that then arrives on the block she was in must
        // stand down there exactly as it does over a row — measured in USE:
        // a page left at rest came back with her block revealed at the foot
        // (captures `39` → `40`). So the resolver is consulted whenever the
        // first geometry READ a memory (`articleMemoryAtMount`), the restore
        // still aiming or already settled. The other order (a landing
        // already pending at the first geometry — every pin's, since
        // `landingModel` adopts before mounting) is answered in
        // `consumeArticleGeometry`'s `.undecided` branch by the same
        // resolver; there the restore is still `.undecided` and this line
        // does nothing.
        if articleRestore != .undecided, articleMemoryAtMount != nil {
            resolveEntryLandingAgainstTheMemory()
        }
    }

    /// **Which of the two wins, decided in ONE place** (17q piece 6, her
    /// rulings R-Q20 + R-Q21; the 17q ladder's R1-2/R1-3 made it the ONE
    /// site) — called at the two moments an ENTRY landing and a remembered
    /// page first meet: the landing arriving after the first geometry has
    /// read a memory (`landArticle`, the app's order — the restore aiming
    /// at a row, or already settled at the TOP; the ladder's round 2, R2-1),
    /// and the first geometry finding a landing already pending
    /// (`consumeArticleGeometry`'s `.undecided` branch, the pins' order). A
    /// BLOOM landing is never weighed here: it
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
    // MARK: - THE ONE STRUCTURAL ARM (13u2 UNIT E — row 51's recommended design)

    /// The projection a PENDING landing was judged against — the last one
    /// this brain was told about when the landing was made.
    ///
    /// `@ObservationIgnored` because nothing renders from it: it is the arm's
    /// own bookkeeping, and tracking it would invalidate every view on every
    /// autosave-cadence adoption.
    @ObservationIgnored private var landingProjection: Queries.TakesProjection?

    /// **A PROJECTION ARRIVED.** If a landing is pending and this projection
    /// differs from the one it was judged against, the landing ends.
    ///
    /// **Why this exists** (`clearArticleLanding`'s road table, and the
    /// residue row 51 carries): a landing is a REVEAL kept alive against the
    /// lazy column's own settling passes, and what can defeat it afterwards
    /// is a change to the article's CONTENT height, its VIEWPORT height, or
    /// the LIVE PANE. Until now every content-height road was covered BY
    /// ENUMERATION — a table of a dozen gesture doors, each with its own
    /// `clearArticleLanding()` arm, whose completeness was argued three times
    /// and falsified twice (round 1 claimed "by construction" for the
    /// structure controller; round 2 measured the split and the callout;
    /// round 3 measured the ⌘-pick's banner). An enumeration of gesture doors
    /// also cannot, in principle, cover the roads that are NOT gestures: a
    /// SYNC arrival, a structural undo performed in another window, an engine
    /// repair. Those change the content height with nobody's hand on the
    /// board.
    ///
    /// This closes the class by construction for every content change,
    /// whatever produced it, because a content change is exactly a projection
    /// that differs. The enumerated arms STAY — see the record — so nothing
    /// about when her own gestures end a landing moves.
    ///
    /// **THE CHOSEN BEHAVIOUR, written down rather than discovered** (the
    /// exact caveat row 51 asks to be recorded here): `!=` on
    /// `Queries.TakesProjection` fires on ANY field, so a projection that
    /// differs only in METADATA — a title edit, a word target, a lens
    /// rename, a seal — ends a pending landing too. That is deliberate and it
    /// is the safe direction: a landing is a one-shot reveal with a 64-aim
    /// budget measured in milliseconds, and the states in which a metadata-only
    /// arrival can race one are rare and self-correcting (the page simply
    /// stays where it is, which is where she left it). The alternative — a
    /// field-by-field "does this change heights" predicate — is a second
    /// completeness argument of exactly the kind this arm exists to retire.
    ///
    /// **The first arrival never ends anything:** with no judged projection in
    /// hand there is nothing to differ FROM, and a mount whose landing is set
    /// before its first adoption (every pin's order, and the app's when a
    /// door lands before the observation delivers) must keep it.
    func noteProjectionArrived(_ projection: Queries.TakesProjection) {
        defer { landingProjection = projection }
        guard articleLanding != nil, let judged = landingProjection else { return }
        if judged != projection { clearArticleLanding() }
    }

    func clearArticleLanding() {
        // The 17q ladder's round 3 (R3-1): her hand ends the restore's HOLD
        // exactly as it ends the landing — here, in the ONE funnel every arm
        // above already reaches, so the road table is the hold's completeness
        // proof too. A gesture that reflows the page with no scroll (a
        // note-wide split, a keystroke that grows a row) must not be fought
        // by a re-aim; and on a board that never held this is a no-op.
        endArticleHold()
        articleLanding = nil
    }

    // MARK: - The landing REVEALS (17p batch a, ledger row 1 — her ruling R-Q1)
    //
    // **18l-b U2: the reveal's pure arithmetic lives on the AUTHORITY's side
    // now** — `LandingAim.MinimalReveal` (`Surface/LandingAim.swift`), the
    // `.minimalReveal` aim kind's brain, its bodies moved there unchanged
    // with their measured reasons. These names stay at their old addresses
    // (the 3C parity pattern): a typealias per type, a one-line forward per
    // function, so every pin reads them unmodified.

    /// What a landing may ask the article for — `LandingAim.MinimalReveal
    /// .Decision` (`.none` · `.reveal`; never a top anchor, her R-Q1).
    typealias ArticleReveal = LandingAim.MinimalReveal.Decision

    /// **THE RULE, pure** — `LandingAim.MinimalReveal.decision`.
    nonisolated static func revealDecision(
        rowFrame: CGRect?, viewportHeight: CGFloat
    ) -> ArticleReveal {
        LandingAim.MinimalReveal.decision(rowFrame: rowFrame, viewportHeight: viewportHeight)
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

    /// Which edge of the page a reveal puts the row at — `LandingAim
    /// .MinimalReveal.Edge` (`.head` · `.foot`; the minimal scroll stated as
    /// an edge, never the far one), mapped to a SwiftUI anchor through
    /// `LandingAim.MinimalReveal.anchor(_:)` by the view.
    typealias ArticleRevealAim = LandingAim.MinimalReveal.Edge

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
        // The 17q ladder's round 3 (R3-1): a landing's own scroll ends the
        // restore's hold — the bloom door rides through the restore and
        // reveals afterwards (R1-2), and a hold that re-aimed after the
        // reveal would haul the page back. Decided here, the one place a
        // reveal is decided (F-1), never beside the view's scroll.
        endArticleHold()
        return .reveal(
            landing,
            Self.revealAnchor(
                for: landing, rowFrame: frame, order: order,
                realizedRows: Set(articleRowFrames.keys)))
    }

    /// Pure: which edge reaches the row — `LandingAim.MinimalReveal.edge`.
    nonisolated static func revealAnchor(
        for placementID: String, rowFrame: CGRect?, order: [String], realizedRows: Set<String>
    ) -> ArticleRevealAim {
        LandingAim.MinimalReveal.edge(
            for: placementID, rowFrame: rowFrame, order: order, realizedRows: realizedRows)
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
    /// Returns whether anything moved (the 17q ladder's R1-1 walk — the
    /// caller re-derives the memory only when it did).
    @discardableResult
    func noteArticleRowFrame(_ placementID: String, _ frame: CGRect) -> Bool {
        if let existing = articleRowFrames[placementID],
           abs(existing.minY - frame.minY) < 0.5,
           abs(existing.height - frame.height) < 0.5 {
            return false
        }
        articleRowFrames[placementID] = frame
        return true
    }

    /// **The memory follows the ROWS, not only the scroll hook** (the 17q
    /// ladder's R1-1, measured on her 262-block note at the re-walk): for
    /// one scroll step the scroll geometry hook runs BEFORE the rows report
    /// their new frames, so a memory written from that hook alone is always
    /// ONE STEP STALE — the row that sat at `into` before the step, not the
    /// one there now (30 pt on a wheel tick; a fling's last step is pages).
    /// So a row frame's arrival re-derives the place while the restore is
    /// settled — the restore, while pending, owns the page and nothing is
    /// remembered under it (17p's one-shot rule, unchanged).
    ///
    /// **…and a row's DEPARTURE re-derives it too** (the 17q ladder's round
    /// 2, R2-2 — measured: a fling from the entry frame to the top of her
    /// 262-block note came back at the entry frame). `articlePlaceNow` takes
    /// the lowest fitting row, so a de-realized row's last frame — still
    /// held until `forgetArticleRowFrame` — masks every other row's arrival
    /// while it is present, and SwiftUI de-realizes a row without a final
    /// frame report. The view model calls this after a departure as well,
    /// DEFERRED and coalesced to the end of the current turn, because a
    /// board's unmount runs every row's departure in one transaction and a
    /// write per departure would let the last row to leave decide what she
    /// comes back to (`TakesViewModel.forgetArticleRowFrame`).
    func articleRowFramesMoved() -> ArticleRestoreStep {
        // `.settled` only: a pending restore AND a hold (R3-1) own the page,
        // and nothing is remembered under either — which is also what keeps
        // the deferred departure silent while the restore holds.
        guard articleRestore == .settled, let geometry = lastArticleGeometry else { return .wait }
        return rememberStep(geometry)
    }

    /// The last geometry the scroll hook reported — what a row frame's
    /// re-derivation reads (`articleRowFramesMoved`).
    @ObservationIgnored private var lastArticleGeometry: ArticleGeometry?

    func forgetArticleRowFrame(_ placementID: String) {
        // Remove always; count what was removed (the 17q ladder's round 3,
        // R3-2): a row realized and de-realized in one pass never reported a
        // frame, and never joined the set the counter speaks of.
        if articleRowFrames.removeValue(forKey: placementID) != nil {
            articleRowDepartures += 1
        }
    }

    /// Observation seam (the `articleRestoreAims` precedent — a plain
    /// counter, not DEBUG-gated): how many rows that had REPORTED a frame
    /// have left the realized set on this mount. The pins' non-vacuity: a
    /// departure really happened before the memory was read, and a teardown
    /// really ran every row's.
    @ObservationIgnored private(set) var articleRowDepartures = 0

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

    /// **Where the article was left: the BLOCK at the top of the page — and,
    /// since the 17q ladder (R1-1), WHERE THAT BLOCK'S TOP SAT.**
    ///
    /// The row identity is the memory's spine. Two measurements decided that
    /// at 17p, and both still bind:
    ///
    /// 1. A raw content OFFSET is not the same number for the same view twice
    ///    in a lazy column — the rows above the fold are estimated until they
    ///    are realized, so the same y means a different block on the way back
    ///    (96 pt and nine blocks apart on a sixty-block note; ~390 pt on her
    ///    262-block one).
    /// 2. A row identity PLUS the pixels she was into it, applied as a
    ///    RELATIVE nudge, doubles its own correction — the row frames and the
    ///    scroll geometry arrive in different passes, and a nudge computed
    ///    from a frame one pass stale landed 896 where 800 was owed.
    ///
    /// **What the row-only promise cost (the 17q ladder, R1-1):** the row
    /// remembered was the one STRADDLING the fold and it was restored with
    /// its top AT the fold, so every page came back shifted by the straddle —
    /// one row on the 46-pt fixture, a paragraph on her 262-block note — and
    /// the block she was in moved that far toward the page's edge (piece 6's
    /// walk, `17` → `18`). Her R-Q21 says *exactly* as she left it.
    ///
    /// So the memory carries the sub-row place too — never as a nudge, but as
    /// the ANCHOR of the same absolute, idempotent, row-settled restore: the
    /// row remembered is the first row whose top sits at or below the fold
    /// and that fits in the room under it; `into` is where its top sat
    /// (0…viewport) and `rowHeight` what it measured. The restore aims
    /// `scrollTo(row, anchor: UnitPoint(y: into / (viewport − rowHeight)))`
    /// — a unit point in [0, 1] for any row that fit — re-aimed with the REAL
    /// height as the column measures the row, and settled when the row's
    /// top reports `into` (±2). Measurement 1 holds (the row is the identity,
    /// never the offset); measurement 2 holds (an anchor is absolute, so a
    /// stale frame re-aims instead of compounding). **When no row below the
    /// fold fits** (the 17q ladder's round 2, R2-3 — the last block of a
    /// short note scrolled up through the room, or a bloomed fan under the
    /// fold): the SHORT straddling row is remembered with where its top sat
    /// — a negative `into`, aimed by a unit point below 0, which `scrollTo`
    /// honours linearly (measured: aimed at −30, landed at −30.0, settled);
    /// a TALL straddler and the `below` fallback stay at the fold, 17p's
    /// rule, because a row taller than the viewport is not placed by the
    /// anchor's arithmetic at all (measured: aimed to sit at −400 it landed
    /// at −838.5 and never settled).
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
        /// The `placementID` of the remembered row — or nil for the TOP of
        /// the page itself.
        let rowID: String?
        /// Where the row's top sat below the fold (0 = at the fold — 17p's
        /// one place, and the fold-straddling fallback's). Zero for the TOP.
        let into: CGFloat
        /// The row's measured height when it was remembered — the first
        /// aim's denominator, before the column has realized the row again.
        let rowHeight: CGFloat

        init(rowID: String?, into: CGFloat = 0, rowHeight: CGFloat = 0) {
            self.rowID = rowID
            self.into = into
            self.rowHeight = rowHeight
        }

        /// The page at rest: nothing above the first row.
        static let top = ArticlePlace(rowID: nil)

        /// The aim's unit y: the row's point at this fraction of its height
        /// meets the viewport's point at the same fraction, so the row's top
        /// lands `into` below the fold — `into / (viewport − rowHeight)`.
        ///
        /// **Measured at the 17q ladder's round 2 (R2-3), on the mounted
        /// harness:** a unit point BELOW 0 is honoured linearly by
        /// `ScrollViewProxy.scrollTo` — a short straddler aimed at −30 landed
        /// at −30.0 and the restore settled on the row's report — so a
        /// negative `into` (a row whose top sits ABOVE the fold) aims where
        /// it sat. A row TALLER than the viewport is NOT placed by that
        /// arithmetic (aimed to sit at −400 it landed at −838.5: SwiftUI
        /// aligns such a row's anchor point with the viewport's TOP, not with
        /// the viewport's own fraction) and never settles, so a tall row
        /// aims at the fold (17p's `.top`) and its place is remembered as
        /// the fold. The upper clamp is belt-and-braces: no place
        /// `articlePlaceNow` produces has `into > room`.
        ///
        /// **What the proxy honours, SwiftUI's later re-resolution does not**
        /// (the ladder's round 3, R3-1, measured): after the row has reported
        /// `into`, the lazy column's next measurement pass re-resolves the
        /// scroll target to `into · (1 − rowHeight/viewport)` — the sign is
        /// irrelevant, the row's height is everything (a 2-pt shortfall on a
        /// 46-pt row, the fold on a page-tall one). The restore therefore
        /// HOLDS and re-aims this same anchor until her hand or a landing
        /// (`ArticleRestore.holding`); the anchor itself is right.
        nonisolated static func anchorY(
            into: CGFloat, rowHeight: CGFloat, viewport: CGFloat
        ) -> CGFloat {
            let room = viewport - rowHeight
            guard room > 1 else { return 0 }
            return min(into / room, 1)
        }
    }

    /// The one-shot restore's state. `.undecided` until the FIRST honest
    /// geometry — **never resolved in `onAppear`**, whose ordering against
    /// that first geometry event is not ours to assume (measured at this
    /// batch: the geometry hook fires first, and a mount that records its own
    /// 0 before reading the memory erases the very thing it came back for).
    /// `.wanted` then holds while the article finds the row again — the 17o
    /// batch-b ladder's RAISE-M1 lesson (never restore against a frame that
    /// has not been filled) in this surface's vocabulary.
    ///
    /// **`.holding` — settled when the ROW says so, and it STAYS so** (the
    /// 17q ladder's round 3, R3-1; measured on the mounted harness): the
    /// row's report at `into` is not the page's final word. SwiftUI
    /// re-resolves the scroll target on the lazy column's later measurement
    /// passes (J1(c)'s bound `ScrollPosition`), and that re-resolution does
    /// NOT reproduce the proxy's placement — it lands the row's top at
    /// `into · (1 − rowHeight/viewport)`: a 2-pt shortfall on a 46-pt row,
    /// 20 → 15 / 11 / 8.5 / 6 on rows of 173 / 296 / 378 / 460 pt under a
    /// 638-pt viewport, the FOLD for a row nearly a page tall (+4 → 0, −15 →
    /// 0 on a 542-pt row at every room from 6 to 96 pt). A restore that
    /// went to rest at the first report then REMEMBERED the drift, so the
    /// next trip was byte-identical and the miss hid. So the restore holds:
    /// it keeps re-aiming the same absolute anchor while the row is off its
    /// place, reads the slot order only then (P1), and ends into `.settled`
    /// at her hand (`positionedByUser`, checked first; the her-hand funnel
    /// `clearArticleLanding`), at a landing's own scroll (`articleLandingStep`
    /// — the bloom door's reveal is spendable during a hold and spending it
    /// ends the hold, so the two never fight), or at the aim budget — which
    /// the hold refills once on entry, so it is bounded exactly as the
    /// restore is. Under a hold nothing is remembered (`rememberStep` never
    /// runs; `articleRowFramesMoved` returns `.wait`, which keeps the
    /// deferred departure of R2-2 silent by construction); the non-geometry
    /// ends write nothing — a geometry report or a frame arrival follows
    /// every one of them and writes through the one road. At the BUDGET end
    /// the page is remembered as it shows, so a drift that outlasts the
    /// budget DECAYS across trips (each trip's drift is a proportion of the
    /// remembered `into`) rather than holding at one wrong value.
    enum ArticleRestore: Equatable {
        case undecided
        case wanted(ArticlePlace)
        case holding(ArticlePlace)
        case settled
    }

    /// What the view should do with a geometry report.
    enum ArticleRestoreStep: Equatable {
        /// Scroll this row to the remembered place (the coarse aim, for a row
        /// a lazy column has not realized yet — the only scroll that can
        /// reach one). `anchorY` is the unit point's y — 0 for the fold
        /// (17p's `.top`), else where the row's top sat (the 17q ladder,
        /// R1-1; `ArticlePlace.anchorY`).
        case scrollToRow(String, anchorY: CGFloat = 0)
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
    /// batch-a ladder, R1-4). The HOLD (R3-1) refills the pocket once on
    /// entry: the restore's own aims (11 on a page-tall row, 15 on a
    /// 60-block note) must not starve the hold's, and the hold stays bounded
    /// by the same number.
    nonisolated static let articleRestoreAttempts = 24

    @ObservationIgnored private(set) var articleRestore: ArticleRestore = .undecided
    /// What the FIRST geometry read from the session — a per-mount fact
    /// (the 17q ladder's round 2, R2-1): whether there is a page to come back
    /// to at all, which is the condition under which an ENTRY landing that
    /// arrives later is weighed against it (`landArticle`). A TOP memory
    /// settles the restore at once and never reaches `.wanted`, so the
    /// restore's STATE cannot carry this fact; nil until the first report.
    @ObservationIgnored private var articleMemoryAtMount: ArticlePlace?
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
    /// A HOLD counts (R3-1): the page IS where the memory says; a bloom's
    /// reveal must still spend (17o row 8), and spending it ends the hold.
    var articleReadyForLanding: Bool {
        guard articleGeometrySeen else { return false }
        switch articleRestore {
        case .settled, .holding: return true
        case .undecided, .wanted: return false
        }
    }

    /// The place worth remembering, right now (the 17q ladder, R1-1): the
    /// first row whose top sits at or below the fold AND that fits in the
    /// room under it — with where its top sat, sub-row exact. Failing that,
    /// the row straddling the fold (the one she is reading through) — with
    /// where ITS top sat when it is shorter than the viewport (a negative
    /// `into`, aimed by a unit point below 0 — the ladder's round 2, R2-3,
    /// measured), at the fold when it is taller (a tall row is not placed by
    /// the anchor's arithmetic — measured too). Failing that, the first row
    /// below, at the fold: nothing straddles and that row does not fit, so
    /// it is either a tall row whose top the anchor cannot put below the
    /// fold at all, or a fling's transient (the rows above it not yet
    /// realized) that the arrivals re-derive.
    var articlePlaceNow: ArticlePlace? {
        var fits: (id: String, frame: CGRect)?
        var straddling: (id: String, frame: CGRect)?
        var below: (id: String, frame: CGRect)?
        for (id, frame) in articleRowFrames {
            if frame.minY >= -0.5 {
                if frame.maxY <= articleViewportHeight + 0.5,
                   fits == nil || frame.minY < fits!.frame.minY {
                    fits = (id, frame)
                }
                if below == nil || frame.minY < below!.frame.minY { below = (id, frame) }
            } else if straddling == nil || frame.minY > straddling!.frame.minY {
                straddling = (id, frame)
            }
        }
        if let fits {
            return ArticlePlace(
                rowID: fits.id, into: max(fits.frame.minY, 0), rowHeight: fits.frame.height)
        }
        if let straddling {
            let short = straddling.frame.height < articleViewportHeight - 1
            return ArticlePlace(
                rowID: straddling.id, into: short ? straddling.frame.minY : 0,
                rowHeight: straddling.frame.height)
        }
        return below.map { ArticlePlace(rowID: $0.id, into: 0, rowHeight: $0.frame.height) }
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
        lastArticleGeometry = geometry
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
            // The fact is kept for the mount: a landing arriving AFTER this
            // report (the app's order) is weighed by `landArticle` iff a
            // memory was read here — the TOP included, which settles below
            // without ever reaching `.wanted` (the ladder's round 2, R2-1).
            articleMemoryAtMount = remembered
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
        case .wanted(let place), .holding(let place):
            return restoreStep(
                to: place, geometry, positionedByUser: positionedByUser, order: order())
        case .settled:
            return rememberStep(geometry)
        }
    }

    /// The hold's non-geometry ends (R3-1): her hand's funnel and a landing's
    /// spend. `.settled` and nothing else — the session write lives on the
    /// one geometry road, and a report follows every one of these.
    private func endArticleHold() {
        if case .holding = articleRestore { articleRestore = .settled }
    }

    /// A page at rest remembers the TOP itself (R1-1); a scrolled page
    /// remembers the row at the top of the viewport.
    private func rememberStep(_ geometry: ArticleGeometry) -> ArticleRestoreStep {
        if geometry.offset <= 0.5 {
            return .remember(.top)
        }
        return articlePlaceNow.map { .remember($0) } ?? .wait
    }

    private func restoreStep(
        to place: ArticlePlace, _ geometry: ArticleGeometry, positionedByUser: Bool,
        order: @autoclosure () -> [String]?
    ) -> ArticleRestoreStep {
        let holding: Bool = { if case .holding = articleRestore { return true } else { return false } }()
        // Her hand outranks a pending restore — and a hold, FIRST (R3-1: her
        // scroll is what moves the row off its place, so a hold that tested
        // the row first would fire one aim against a page she just moved):
        // if she has already scrolled this page herself, the restore is over
        // and we remember her place.
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
        let atItsPlace = articleRowFrames[rowID].map { abs($0.minY - place.into) <= 2 } ?? false
        // A hold in its steady state — the row where it sat — costs nothing
        // in the note's size (P1): decided before the slot order is read.
        if holding, atItsPlace { return .wait }
        // A row the note no longer holds settles at once (R1-4): there is
        // nothing to scroll to, and waiting would starve the landing. Only
        // once the slots are KNOWN — nil means the projection has not
        // arrived, and the aim below is kept until it does.
        if let order = order(), !order.contains(rowID) {
            articleRestore = .settled
            return rememberStep(geometry)
        }
        // **Settled when the ROW says so**, never when an offset we computed
        // says so: a lazy column re-lays out under a scroll, and the row
        // frames and the scroll geometry arrive in different passes. "So"
        // means its top is back where it SAT (the 17q ladder, R1-1) — at
        // the fold for a 17p-shaped place, `into` below it otherwise. **And
        // it stays so** (R3-1): settled INTO A HOLD, not to rest — the row's
        // report is not the page's final word (`ArticleRestore.holding`).
        if atItsPlace {
            articleRestore = .holding(place)
            articleRestoreAimsLeft = Self.articleRestoreAttempts
            return .wait
        }
        // Otherwise aim again. The aim is ABSOLUTE (scroll this row to its
        // anchor) and therefore idempotent: re-aiming as the real heights
        // arrive converges, where a relative nudge computed from a stale
        // frame doubles its own correction. The anchor's denominator is the
        // row's REAL height once the column has realized it, the remembered
        // one before (the coarse aim).
        guard articleRestoreAimsLeft > 0 else {
            articleRestore = .settled   // the row is gone, or will not settle.
            // A hold that outlasts its budget remembers the page as it shows
            // — the drift DECAYS across trips (R3-1's documented end).
            return holding ? rememberStep(geometry) : .wait
        }
        articleRestoreAimsLeft -= 1
        articleRestoreAims += 1
        let height = articleRowFrames[rowID]?.height ?? place.rowHeight
        return .scrollToRow(
            rowID,
            anchorY: ArticlePlace.anchorY(
                into: place.into, rowHeight: height, viewport: geometry.viewport))
    }
}
