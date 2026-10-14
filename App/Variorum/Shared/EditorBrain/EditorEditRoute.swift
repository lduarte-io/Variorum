//
//  EditorEditRoute.swift
//  Variorum / VariorumMobile (Shared/EditorBrain)
//
//  **18m U1 — THE CROSS-BLOCK ROUTE, AS ONE PURE DECISION.** The code that
//  decides whether a keystroke deletes blocks used to live twice, as two
//  prose-argued `if/else` ladders inside the two editors' `shouldChangeText`
//  gates (`EditorViewModel` and `MobileEditorViewModel`), with different arms
//  in a different order and the order itself — a ruled business rule —
//  testable only through a mounted editor (the post-13u health review §2.1,
//  leak 1; §3). The planners were already one brain; the ORDER and the ARM
//  SET were not. They are now DATA:
//
//  · `Arm` — every arm either platform's ladder can hold, each carrying the
//    ruling that placed it (the prose that used to argue the ladders' order
//    lives HERE now, at the arm, never lost);
//  · `macArms` / `phoneArms` — each platform's DECLARED list, in its ruled
//    order (a platform's missing arm is a missing list entry — KnownIssues
//    row 51's phone carves become two list entries plus two phone executors,
//    "buildable, never built" by this unit);
//  · `precedence` — the ruled pairwise order constraints, pinned against both
//    lists, so a future list edit that breaks a ruling fails by NAME;
//  · `route(...)` — walks a declared list LAZILY (the first arm that claims
//    stops the walk — today's evaluation order and cost, exactly) and ends in
//    the one terminal every ladder has always ended in: the diagnosis (P-2 as
//    structure — a refused keystroke always speaks its one real cause).
//
//  What is NOT here, by design (the boundary the 18m U1 ruling records):
//  every pre-arm above the ladder (the seal, the ⇧⏎ tail arm, the phone's
//  liveness belt and `MobileEditTrace`), the verdict switch's other arms, the
//  `pendingEdit`/`bulkPending` clears, every EXECUTOR (the roads, flights,
//  flush contracts and store-time authorizations) and every SENTENCE (the
//  find refusal naming ⌘⇧M, the phone's read-only line, both platforms'
//  `fanRoads`). Those are faces; each view model maps a `Route` onto the
//  roads and words it always had, and re-derives nothing.
//
//  Charter (EditorDocumentCore's): NOTHING here may depend on a platform UI
//  framework — Foundation + VariorumCore only.
//

import Foundation
import VariorumCore

nonisolated enum EditorEditRoute {

    // MARK: - The arms

    /// One arm of the cross-block ladder — the gate's answer to a keystroke
    /// whose verdict is `.refuse(.crossesBlockBoundary)` (the storage must
    /// never half-apply it, so something here either claims its intent or
    /// the terminal diagnosis speaks). Each case's doc is the ruling that
    /// placed it; `precedence` below is the ruled ORDER between them.
    enum Arm: Equatable, Hashable, Sendable, CaseIterable {
        /// **The find-replace fence** (QoL batch 3, L6 — THE SAFETY CORE):
        /// a FIND-DRIVEN replacement never restructures the post. Every arm
        /// below can DELETE or MERGE blocks — ratified for a deliberate
        /// hand-made selection, never for a machine-driven sweep — so this
        /// runs before every planner. `EditorFind` pre-checks every range,
        /// so reaching here under the flag means the text moved underneath a
        /// checked range (the belt for the one shape the substring valve
        /// cannot see: byte-identical text whose BLOCK membership moved); it
        /// refuses and says so, in the Mac's own words (they name ⌘⇧M, so
        /// they stay Mac-local). **Mac-only:** the phone's editor has no
        /// find-and-replace, so it neither declares this arm nor has the
        /// fact (it passes `findReplacing: false`).
        case findReplaceFence
        /// **A7's empty-block carve** (13c 1B — her A7: *"I cant use
        /// backspace to delete empty blocks with no takes right now which is
        /// too annoying"*). Deleting an EMPTY block is the one case where the
        /// cross-block refusal buys nothing: there is no text to lose. Its
        /// range is exactly one separator, which touches no entry at all, so
        /// the two compound-shaped plans can never see it (pinned). Plan:
        /// `SeamCarvePlan.emptyBlockDeletion` (below — ENABLEMENT only; the
        /// operation re-checks the whole authorization in its own
        /// transaction). **Mac-only today** — KnownIssues row 51.
        case emptyBlockCarve
        /// **#34's texted-seam merge** (13d batch 2 — her ruling (ii)): the
        /// same one-separator range with TEXT on both sides — backspace joins
        /// the paragraphs when neither block has takes, and says why when
        /// either does (the fan is the executor's STORE read, never this
        /// plan's). MUTUALLY EXCLUSIVE with A7's carve by construction (one
        /// needs an empty neighbour, this needs neither — pinned at every
        /// separator), and invisible to the compound-shaped plans (a lone
        /// separator intersects nothing — pinned). Plan:
        /// `SeamCarvePlan.textedSeamMerge` (below). **Mac-only today** —
        /// KnownIssues row 51.
        case textedSeamMerge
        /// **J9's whole-block delete** (13j J9 — her ruling; the phone's
        /// R18 ≡ M11): a selection covering exactly N WHOLE blocks + Delete
        /// IS the delete gesture — ONE undo entry, redo carried, the
        /// Trash/tray road. **Below the two seam carves**: their geometry is
        /// a single separator, which `wholeBlockRun` excludes by
        /// construction, so A7's no-fan/nothing-unshown authorization and
        /// #34's fan refusal keep every case they ruled and this road can
        /// never route around them. **ABOVE the clamp and ABOVE the compound,
        /// and there the order is LOAD-BEARING** (both overlap it — pinned by
        /// permutation): a run of whole paragraphs plus Delete means "these
        /// paragraphs go", and this road keeps its OWN ruling — #33(a)'s
        /// unrestricted delete, which takes a locked take's block, where the
        /// compound refuses whole for one (R-13u-1). *"Two gestures, two
        /// rulings, in her stated order."* Plan:
        /// `BlockRangeIndex.wholeBlockDeletion` (delete-never-type-over; the
        /// gap fence inside it).
        case wholeBlockDelete
        /// **#109's SHAPE (i) — clamp and EDIT** (her ruling of 2026-09-15:
        /// *"if it's on the boundary, why not treat it as just part of that
        /// one block?"*). A span touching only ONE block's characters plus
        /// the separator at one end CLAMPS to that block's text and becomes
        /// an ORDINARY in-block edit (never structural — ⌘Z stays text
        /// undo); the break she selected stands (R-13u-2 speaking, not a
        /// compromise of it). **BELOW J9 deliberately:** a whole paragraph
        /// plus its newline plus Delete is her J9 gesture and the paragraph
        /// GOES (tray, Put back real) — clamping first would have left an
        /// empty block; J9 declines a TYPE-OVER, which is why the same span
        /// typed over lands here and replaces the block's text in place.
        /// **BELOW the seam carves**, which own the one-character separator
        /// keystroke whole: this plan's "nothing to do" guard declines a
        /// lone-separator DELETE so it can never route around them. Plan:
        /// `CrossBlockCompound.clampedInBlockEdit`. (Shape (ii) — the TRIM —
        /// needs no arm: it lives inside the compound's plan.)
        case clampedInBlockEdit
        /// **The gap fence's FACE — a COPY arm** (mobile round 2, batch 1b
        /// ladder, MINOR 3(a); 18m U1's O-2, adopted). A whole-block run
        /// containing a block whose variant has not ARRIVED: the geometry is
        /// fine, and the cross-block line would send her looking for a
        /// boundary problem that isn't there — so it says the sentence the
        /// editor already says when she types into such a block. **It never
        /// changes WHETHER the gesture lands**: J9 declines a gap run on its
        /// own fence and the compound declines on its own (13u1 U-3), so the
        /// gesture refuses with or without this arm; the arm decides only
        /// the WORDS she reads. **Above the compound deliberately** (M22): a
        /// gap slot renders with zero length, and before 13u1's U-3 a run
        /// containing one could pass the compound's guards and refuse at
        /// `ops.merge`'s adjacency check with a compound-level error; the gap
        /// fence's own doctrine settles which sentence speaks. **Phone-only:**
        /// on the Mac the same condition is answered by the terminal
        /// diagnosis's `.unsyncedBlock` (a declared difference in WORDS —
        /// 18m U1's O-1, routed to U3, never converged here).
        case gapFence
        /// **THE CROSS-BLOCK COMPOUND** (13u1 UNIT 2 — her item 5; the
        /// ratified 2026-07-09 merge-then-edit, rebuilt): one gesture, one
        /// structural compound, one undo entry. Blocks the selection covers
        /// WHOLE ride `deleteBlock` (the tray road), the surviving ends take
        /// their chosen takes' edits, and the ends join only where both cuts
        /// sit mid-paragraph and no fan hangs on either (R-13u-2 + #11a, the
        /// fan read from the STORE at run time). Refuses only a locked take
        /// anywhere in the run (R-13u-1) plus its gap and tail fences. The
        /// last claimant. Plan: `CrossBlockCompound.plan` (with #109's trim).
        case crossBlockCompound
    }

    /// **The Mac's declared ladder.** Every arm but the gap fence, in the
    /// ruled order: the safety core first, the two seam carves (mutually
    /// exclusive) ahead of the whole-block delete, the clamp below J9, the
    /// compound last.
    static let macArms: [Arm] = [
        .findReplaceFence,
        .emptyBlockCarve,
        .textedSeamMerge,
        .wholeBlockDelete,
        .clampedInBlockEdit,
        .crossBlockCompound,
    ]

    /// **The phone's declared ladder.** No find fence (no find-and-replace
    /// in its editor); NO SEAM CARVES (KnownIssues row 51 — deliberately
    /// unbuilt; the day the mobile catch-up builds them they become two
    /// entries here, placed by `precedence`, plus two phone executors); the
    /// gap fence's copy arm above the compound.
    static let phoneArms: [Arm] = [
        .wholeBlockDelete,
        .clampedInBlockEdit,
        .gapFence,
        .crossBlockCompound,
    ]

    // MARK: - The ruled order, as data

    /// One ruled ordering constraint: where BOTH arms are declared, `before`
    /// must come earlier in the list. **An ABSENT arm is a VACUOUS PASS** —
    /// "the carves ≺ J9" holds on today's phone list (no carves) and bites
    /// the day row 51 adds them in the wrong place.
    struct Precedence: Equatable, Sendable {
        let before: Arm
        let after: Arm
        let ruling: String
    }

    static let precedence: [Precedence] = {
        // The generated fence-first rows cover the PLANNER arms only: the
        // gap fence is a COPY arm — it can only refuse (O-2) — so L6's "the
        // safety core runs before every planner" has nothing to guard
        // there, and no ruling has ever placed the two relative to each
        // other (no platform declares both; their relative order could
        // change only a refusal's wording, never whether a gesture lands).
        // (Ladder round 1's NIT, 2026-09-29 — pinned beside the
        // every-row-names-its-ruling check.)
        var rules: [Precedence] = Arm.allCases
            .filter { $0 != .findReplaceFence && $0 != .gapFence }
            .map {
                Precedence(
                    before: .findReplaceFence, after: $0,
                    ruling: "QoL batch 3 L6 — the safety core runs before every planner")
            }
        rules += [
            Precedence(
                before: .emptyBlockCarve, after: .textedSeamMerge,
                ruling: "13d #34's own precedence list — A7's carve first, unchanged"),
            Precedence(
                before: .emptyBlockCarve, after: .wholeBlockDelete,
                ruling: "13j J9 — below the seam carves, which keep every case they ruled"),
            Precedence(
                before: .textedSeamMerge, after: .wholeBlockDelete,
                ruling: "13j J9 — below the seam carves, which keep every case they ruled"),
            Precedence(
                before: .emptyBlockCarve, after: .clampedInBlockEdit,
                ruling: "#109 — the carves own the lone-separator keystroke whole"),
            Precedence(
                before: .textedSeamMerge, after: .clampedInBlockEdit,
                ruling: "#109 — the carves own the lone-separator keystroke whole"),
            Precedence(
                before: .wholeBlockDelete, after: .clampedInBlockEdit,
                ruling: "#109 / J9 — a whole paragraph + newline + Delete GOES; a type-over clamps"),
            Precedence(
                before: .wholeBlockDelete, after: .crossBlockCompound,
                ruling: "J9 — #33(a)'s unrestricted delete above R-13u-1's refuse-whole compound"),
            Precedence(
                before: .clampedInBlockEdit, after: .crossBlockCompound,
                ruling: "13u2 UNIT C — shape (i) is an ordinary in-block edit, never a compound"),
            Precedence(
                before: .gapFence, after: .crossBlockCompound,
                ruling: "mobile round 2 MINOR 3(a) — the read-only sentence, not a compound refusal"),
        ]
        return rules
    }()

    /// The constraints a list breaks (empty = the list honours every ruling).
    /// Absent arms pass vacuously — see `Precedence`.
    static func violations(of arms: [Arm]) -> [Precedence] {
        precedence.filter { rule in
            guard let before = arms.firstIndex(of: rule.before),
                  let after = arms.firstIndex(of: rule.after)
            else { return false }
            return before > after
        }
    }

    // MARK: - The answer

    /// What the ladder decided. Each case names the arm that claimed (or the
    /// terminal diagnosis) and carries that arm's plan, so the platform's
    /// face can run its EXISTING executor and speak its EXISTING words.
    enum Route: Equatable, Sendable {
        /// `.findReplaceFence` claimed: refuse, in the platform's own words.
        case refuseFindReplace
        /// `.emptyBlockCarve` claimed.
        case carveEmptyBlock(SeamCarvePlan.EmptyBlockDeletion)
        /// `.textedSeamMerge` claimed (the fan is the executor's store read).
        case mergeTextedSeam(SeamCarvePlan.SeamMerge)
        /// `.wholeBlockDelete` claimed: the blocks covered whole, in order.
        case deleteWholeBlocks([String])
        /// `.clampedInBlockEdit` claimed.
        case editInBlock(CrossBlockCompound.InBlockEdit)
        /// `.gapFence` claimed — a COPY arm: refuse with the read-only line.
        case refuseAwaitingSync
        /// `.crossBlockCompound` claimed.
        case editAcrossBlocks(CrossBlockCompound.Plan)
        /// Every declared arm declined: the terminal diagnosis — the ONE
        /// cause, which the platform speaks with its own `fanRoads`.
        case refuse(CrossBlockRefusal.Cause)
    }

    // MARK: - The decision

    /// **The one call both gates make.** Walks `arms` in order and returns
    /// the first claim — LAZILY, so each planner runs only when every arm
    /// above it has declined (a seam backspace on the Mac pays A7's
    /// O(position) walk and stops, exactly as the ladder always did). If
    /// every declared arm declines, the diagnosis answers.
    ///
    /// **The facts are what the gate already holds at the keystroke:**
    /// `index` (the tiling), `slots` (the projection beside it — A7's
    /// enablement guards and the diagnosis read it; it may run shorter than
    /// the entries and every read of it is bounds-guarded), `findReplacing`
    /// (a Mac fact — passed EXPLICITLY at both call sites, the phone's
    /// `false`), and `surfaceText`.
    ///
    /// **`surfaceText` is a bounded, read-only fact source** (the ruling's
    /// condition 1): the route never stores it, and it is consulted only by
    /// the two compound-shaped planners — the clamp reads ONE range and only
    /// when it claims (the walk then stops); the compound reads AT MOST TWO
    /// (its surviving ends) and only when reached. So one route reads the
    /// live surface at most twice — the ladder's own reads, unchanged.
    static func route(
        range: NSRange,
        replacement: String,
        index: BlockRangeIndex,
        slots: [Queries.RenderedBlock],
        findReplacing: Bool,
        arms: [Arm],
        surfaceText: (NSRange) -> String
    ) -> Route {
        for arm in arms {
            switch arm {
            case .findReplaceFence:
                if findReplacing { return .refuseFindReplace }
            case .emptyBlockCarve:
                if let plan = SeamCarvePlan.emptyBlockDeletion(
                    replacing: range, with: replacement, index: index, slots: slots) {
                    return .carveEmptyBlock(plan)
                }
            case .textedSeamMerge:
                if let plan = SeamCarvePlan.textedSeamMerge(
                    replacing: range, with: replacement, index: index) {
                    return .mergeTextedSeam(plan)
                }
            case .wholeBlockDelete:
                if let blockIDs = index.wholeBlockDeletion(
                    covering: range, replacement: replacement) {
                    return .deleteWholeBlocks(blockIDs)
                }
            case .clampedInBlockEdit:
                if let edit = CrossBlockCompound.clampedInBlockEdit(
                    replacing: range, with: replacement, index: index,
                    surfaceText: surfaceText) {
                    return .editInBlock(edit)
                }
            case .gapFence:
                if index.wholeBlockRunAwaitsSync(covering: range) {
                    return .refuseAwaitingSync
                }
            case .crossBlockCompound:
                if let plan = CrossBlockCompound.plan(
                    replacing: range, with: replacement, index: index,
                    surfaceText: surfaceText) {
                    return .editAcrossBlocks(plan)
                }
            }
        }
        // 13j J8(b): the refusal DIAGNOSES. Every arm declined for a reason
        // this terminal can still see — the range, the index's tiling and
        // the projection beside it — so the line names that one reason.
        return .refuse(CrossBlockRefusal.diagnose(range: range, index: index, slots: slots))
    }
}

// MARK: - The two seam carves' PLANS (hoisted from `EditorSurfaceController`, 18m U1)

/// **The ENABLEMENT half of the two seam keystrokes** — A7's empty-block
/// carve and #34's texted-seam merge — hoisted from the Mac's
/// `EditorSurfaceController` at 18m U1 (ruled (c1)) so the route above is
/// pure over its facts and the table suite pins these REAL guards. Their
/// GEOMETRY was already shared (`BlockRangeIndex.emptyBlockDeletion`,
/// `textedSeamPair`); what moved is the few guards around it, with the WHY
/// of each. The EXECUTORS — the roads, their store-time authorizations,
/// their receipts — stay the Mac's (`runEmptyBlockDeletion`,
/// `runSeamMerge`); the Mac keeps `EmptyBlockDeletion` / `SeamMerge` and both
/// `plan…` names as forwards, so every caller and pin reads unchanged (3C).
///
/// The phone declares neither arm (KnownIssues row 51): with these plans
/// shared, its carves are two `phoneArms` entries plus two phone executors
/// — never built by this unit.
nonisolated enum SeamCarvePlan {

    /// A7 (13c 1B): the narrow carve out of the cross-block refusal — a
    /// backspace/forward-delete of the ONE separator beside an EMPTY block
    /// deletes that block instead of refusing.
    ///
    /// **Where the authorization actually lives, since round 3 moved it**
    /// (13c Stage 1 ladder, R3-1). The four guards below are the
    /// ENABLEMENT layer: they read `slots`, decide fast, and let an ordinary
    /// seam keystroke fall through to the ratified refusal without a noisy
    /// message. They are NOT the authorization, because `slots` is
    /// deliberately held stale whenever the editor is busy
    /// (`EditorProjectionPolicy.decide` returns `.deferUntilClean` while the
    /// buffer is dirty or a mint/structural flight is up, and autosave's
    /// debounce re-arms on every keystroke — so for a whole typing burst
    /// this array is frozen). A comment arriving in that window — from sync,
    /// or from her own comments sheet — was invisible to guard 3, and the
    /// block went with its note.
    ///
    /// The authorization is now `Operations.BlockDeletionPrecondition
    /// .emptyWithNothingUnshown`, re-read INSIDE the tombstone's own
    /// transaction (the Mac's `runEmptyBlockDeletion`). Read the two
    /// together: what follows says WHY each condition matters; the operation
    /// is what makes it true at the moment the row is written.
    ///
    /// The four guards, and together they are what keeps the carve from
    /// widening:
    ///
    /// 1. the block's SURFACE text is empty (the index's rule) — a block
    ///    with any text keeps the ratified refusal;
    /// 2. the block has NO FAN (`activeVariantCount == 1`) — takes are
    ///    text, and a seam-key must never take one away unseen;
    /// 3. the block carries NO UNSHOWN TEXT — `carriesUnshownText`, the ONE
    ///    read that answers the carve's only authorization ("there is no
    ///    text to lose"). Two kinds live behind it, found one ladder round
    ///    apart and deliberately wired through one name rather than two
    ///    parallel guards: an **archived take** (R1-1 — archive is
    ///    out-of-the-fan, not gone; reachable in three ordinary gestures:
    ///    branch · archive the one with the prose · blank the survivor) and
    ///    a **block COMMENT** (R2-1 — `addBlockComment` has no empty-block
    ///    rule, and a note on an empty block is ordinary: *"I'll rewrite
    ///    this — see the note"*). Both die in `deleteBlock`'s cascade, and
    ///    the comment half additionally defeats AppSpec §7's ratified
    ///    "deleted comments are visible and resurrectable — never skimpy",
    ///    since `deletedBlockComments` is keyed by block and a tombstoned
    ///    block is only in the tray;
    /// 4. the slot is editable (a live variant, unlocked, not a gap).
    ///
    /// PROVISIONAL (13c R2-1, QUESTIONS #40): a NAMED or CALLOUT empty
    /// block still carves. `block.name` and `block.presentation` are
    /// columns on the block row — the tombstone keeps them, undo and
    /// `restoreBlock` bring them back with the block, and the tray lists
    /// the block by its name — so nothing of them becomes unrecoverable,
    /// which is the line the two counted kinds cross. Guarding on every
    /// datum attached to a block (tags cascade too) would narrow the carve
    /// back out of existence and undo A7.
    ///
    /// Every one of the four is re-checked in the operation's own
    /// transaction, so a sync apply — or her comments sheet, or another
    /// surface — changing any of them between the keystroke and the write
    /// refuses the whole gesture rather than deleting text nobody saw.
    struct EmptyBlockDeletion: Sendable, Equatable {
        let blockID: String
        let variantID: String
        let entryIndex: Int
        /// Where the caret lands once the block is gone (VX-290).
        let landing: Landing

        /// **VX-290 — her report is the ruling** (2026-10-13): *"when you're
        /// on an empty block in the write editor and there's a bunch of empty
        /// takes below it, clicking delete repeatedly eats the takes from
        /// underneath you, rather than moving you up into the previous line
        /// like writing editors typically do."* **The caret lands where the
        /// deleted line break was.** Named by the SURVIVING block's identity,
        /// never an offset: the surface re-renders from the store between
        /// this plan and the landing, and the survivor's id is still true
        /// afterwards. The Delete Block and archive doors keep their own rule
        /// (`EditorSurfaceController.caretLandingAfterRemoving`).
        enum Landing: Sendable, Equatable {
            /// The carved block sat AFTER the separator — ⌫ from inside it,
            /// or ⌦ at the end of the block before it: the caret lands at the
            /// END of the block before (it moves up into the previous line,
            /// and a second ⌫ deletes a letter there).
            case endOf(blockID: String)
            /// The carved block sat BEFORE the separator — ⌫ at the start of
            /// the block after it, or ⌦ from inside it: the START of the
            /// block after (the shipped landing, unchanged).
            case startOf(blockID: String)
        }
    }

    static func emptyBlockDeletion(
        replacing range: NSRange,
        with replacement: String,
        index: BlockRangeIndex,
        slots: [Queries.RenderedBlock]
    ) -> EmptyBlockDeletion? {
        guard replacement.isEmpty,
              let carve = index.emptyBlockCarve(replacing: range, isDeletion: true)
        else { return nil }
        let i = carve.carved
        let entry = index.entries[i]
        guard entry.editable, let variantID = entry.variantID else { return nil }
        // No fan: a block with several takes carries text in the ones you
        // are not looking at, so the "nothing to lose" argument fails.
        guard i < slots.count, slots[i].activeVariantCount == 1 else { return nil }
        // …and nothing the slot does not SHOW (R1-1's archived take, R2-1's
        // block comments). This is the guard that actually says "there is
        // no text to lose"; a third kind of unshown prose extends
        // `carriesUnshownText`, never this line.
        guard !slots[i].carriesUnshownText else { return nil }
        let survivor = index.entries[carve.survivor].blockID
        return EmptyBlockDeletion(
            blockID: entry.blockID, variantID: variantID, entryIndex: i,
            landing: carve.survivor < i ? .endOf(blockID: survivor) : .startOf(blockID: survivor))
    }

    /// The pair a seam keystroke would join. Geometry + liveness only — the
    /// fan question is the executor's, on the store (the Mac's
    /// `runSeamMerge`).
    struct SeamMerge: Sendable, Equatable {
        let leadingIndex: Int
        let trailingIndex: Int
        let leadingBlockID: String
        let trailingBlockID: String
    }

    /// Her QUESTIONS #34 ruling (13c ratify walk, 2026-07-27), option (ii):
    /// **backspace at a seam between two TEXTED blocks MERGES when NEITHER
    /// block has takes, and refuses-and-speaks when either does.** The second
    /// named exception to the ratified cross-block destructive-edit refusal —
    /// A7's empty-block carve (13c 1B) is the first, and this one is granted
    /// on a different argument: not *"there is no text to lose"* but *"basic
    /// text should behave like basic text"*, her own words at #34.
    ///
    /// The precedence at a deleted inter-block separator, in order:
    /// 1. **A7's carve** — an empty neighbour with nothing unshown: the block
    ///    goes (exactly as shipped; its guards and #40/#42's rulings are
    ///    untouched by this batch);
    /// 2. **this** — both neighbours texted, neither fanned: the ordinary
    ///    binary MERGE of the two, through the standing gesture path;
    /// 3. **this, refusing** — both texted, either side fanned: the fan is
    ///    named and the explicit door pointed at. A keystroke must never fold
    ///    a fan away, and must never open a sheet.
    ///
    /// What this plan deliberately does NOT decide is the fan. There is
    /// exactly ONE fan rule in the app — the merge ceremony's own threshold
    /// (S4-23 ruling 4: any live active fan on either side opens the
    /// ceremony) — and it is read from the STORE, never from `slots`,
    /// which the projection engine deliberately freezes for the length of a
    /// typing burst. That freeze is what the 13c ladder's R3-1 finding was
    /// about, one door over: a plan-time guard reading it is an enablement
    /// hint, never an authorization. Here the authorization is the run's
    /// truth read, and a fan arriving mid-burst therefore stops the merge
    /// (pinned).
    ///
    /// Locked takes deliberately do NOT refuse: merge COPIES the rendered
    /// texts and never edits a buffer, so the explicit gesture allows them
    /// (Phase 3 op semantics, `StructuralGesturePlanner.merge`) and parity is
    /// the rule for this door too. A sealed post never reaches here — the
    /// gate refuses at the seal before any plan runs.
    static func textedSeamMerge(
        replacing range: NSRange,
        with replacement: String,
        index: BlockRangeIndex
    ) -> SeamMerge? {
        guard replacement.isEmpty,
              let (leading, trailing) = index.textedSeamPair(
                deleting: range, isDeletion: true)
        else { return nil }
        let entries = index.entries
        // A gap slot has nothing to merge (the planner's `.gapSlot` refusal);
        // by geometry a gap is length 0 and so is never a texted seam, but
        // the pair the merge gesture requires is stated here rather than
        // inferred.
        guard entries[leading].variantID != nil, entries[trailing].variantID != nil
        else { return nil }
        return SeamMerge(
            leadingIndex: leading, trailingIndex: trailing,
            leadingBlockID: entries[leading].blockID,
            trailingBlockID: entries[trailing].blockID)
    }
}
