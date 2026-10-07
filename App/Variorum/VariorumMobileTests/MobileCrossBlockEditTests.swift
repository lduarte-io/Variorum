//
//  MobileCrossBlockEditTests.swift
//  VariorumMobileTests
//
//  Mobile round 2, batch 3 — M22: MERGE-THEN-EDIT on the phone. A selection
//  that opens mid-paragraph and closes in another one, plus Delete (or
//  typing over it), MERGES the touched run and applies the edit — instead of
//  refusing.
//
//  The lineage: batch 1 turned her crash into an honest refusal; batch 1b
//  turned the WHOLE-paragraph half of that refusal into the delete she was
//  reaching for; this batch turns the MID-paragraph half into the merge the
//  Mac has done since the ratified 2026-07-09 rule. Her correction is what
//  found it (§30: *"i thought we added cross block edits on the mac app when
//  there are no takes, where it just auto merges? is that being used
//  here?"*) — it was Mac-only, which made it a parity gap, not a shared
//  limitation.
//
//  WHICH PINS ARE RED ON WHICH TREE — stated per test, the batch-1b
//  convention (its ladder MINOR 6 is why this header exists at all):
//
//  1. RED ON THE PRE-BATCH TREE (the batch's own gesture): every pin that
//     watches a partial cross-block span MERGE and apply its edit. Pre-batch
//     the gate's `.crossesBlockBoundary` arm had no merge-then-edit road, so
//     the store kept all its blocks and `statusMessage` carried the "spans
//     more than one block" line. `MobileWholeBlockDeleteTests`'
//     `aPartialSpanStillRefusesExactlyAsBefore` was that behaviour's
//     characterization and is RETIRED by this batch — it said so itself.
//  2. BOUNDARY CHARACTERIZATIONS, green on BOTH trees by design: the cases
//     this road deliberately does NOT take — a FANNED span (the fence), a
//     gap, a lock, a seam keystroke, a whole-block run (which stays the
//     delete road), a sealed note. Regression guards on the new road, never
//     evidence that it works.
//
//  **THE FENCE IS GONE — 13u1 UNIT 2, her item 5.** This header used to
//  say that a span touching a block with TAKES was not this road's, that
//  the Mac routed it to its own visible-take edit (#11a, 2026-07-13), and
//  that the author was handling the fanned case herself. She handled it,
//  and the brain was rebuilt to her rulings: a block the selection covers
//  WHOLE rides `deleteBlock` — the Trash/tray road, a fanned one included,
//  family intact — while a block covered in PART keeps its identity and its
//  CHOSEN take takes an ordinary buffer edit. The ends JOIN only when both
//  cuts sit mid-paragraph (R-13u-2) and no fan hangs on either (#11a's rule,
//  carried forward and asked of the STORE at run time, never of the
//  editor's projection). A LOCKED take anywhere in the run refuses the
//  WHOLE gesture (R-13u-1). The pins below say which of them changed with
//  the ruling and which are boundary characterizations that did not.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Seeds & probes

@MainActor
private func seedThreeParagraphs(
    _ session: AppSession,
    _ texts: [String] = ["Alpha one.", "Beta two.", "Gamma three."]
) async throws -> (postID: String, blockIDs: [String]) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "merge-then-edit", profile: .blog)
        // A fixture mint is not a gesture (13u1 UNIT 2 — `makePost`'s own
        // rule, stated there).
        let ids = try texts.map {
            try ops.newBlock(in: post.id, text: $0, at: .end, registeringUndo: false).block.id
        }
        return (post.id, ids)
    }
}

/// Drives the real gesture: the delegate gate sees the span, refuses the
/// keystroke (the storage must not half-apply a cross-block edit), and the
/// scheduled compound reproduces the intent. Awaited through the VM's own
/// handle, so nothing spins on a guess about when the act landed.
@MainActor
private func editSpan(
    _ model: MobileEditorViewModel, _ storage: NSTextStorage,
    _ range: NSRange, _ replacement: String = ""
) async {
    typeEdit(model, storage, range: range, replacement: replacement)
    await model.pendingGestureTask?.value
}

// MARK: - The shared brain (the hoist's own pins)

@Suite("The shared cross-block compound brain (M22's hoist, rebuilt at 13u1 UNIT 2)")
@MainActor
struct MobileCrossBlockEditBrainTests {

    /// "Alpha one.\nBeta two.\nGamma three." — entries at (0,10), (11,9),
    /// (21,12); the same document the face tests drive.
    private static let document = "Alpha one.\nBeta two.\nGamma three."

    private static func index(
        _ lengths: [Int] = [10, 9, 12], tail: Int? = nil,
        gap: Int? = nil, locked: Int? = nil
    ) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: lengths.enumerated().map {
                BlockRangeIndex.Entry(
                    blockID: "b\($0.offset)",
                    variantID: $0.offset == gap ? nil : "v\($0.offset)",
                    length: $0.element,
                    editable: $0.offset != gap && $0.offset != locked)
            },
            tailLength: tail)
    }

    private static func text(_ range: NSRange) -> String {
        (document as NSString).substring(with: range)
    }

    /// Filler of the RIGHT LENGTH: the plan compares the surface text it is
    /// handed against the index's own tiling and refuses a mismatch as a
    /// desync (13u1 UNIT 2), so a probe that returns `""` is not a probe,
    /// it is a desync.
    private static func filler(_ range: NSRange) -> String {
        String(repeating: "x", count: range.length)
    }

    private static func plan(
        _ range: NSRange, _ replacement: String = "",
        index: BlockRangeIndex = index()
    ) -> CrossBlockCompound.Plan? {
        CrossBlockCompound.plan(
            replacing: range, with: replacement, index: index, surfaceText: text)
    }

    /// **THE FATES, and the geometry that decides them** (13u1 UNIT 2, her
    /// item 5). A block covered in PART keeps its identity and its chosen
    /// take takes an ordinary buffer edit; the two surviving ends JOIN when
    /// both cuts sit mid-paragraph.
    ///
    /// *(This pin's ancestor read `blockIDs` / `intraStart` /
    /// `intraEndInLast` / `lastPieceLength` off the retired merge-then-edit
    /// plan, which merged the WHOLE run into one block. Same road, same
    /// question, the answers her ruling changed.)*
    @Test func thePlanNamesTheEndsItKeepsAndTheFatesOfTheRest() {
        // 6..16: "one." + the separator + "Beta " — mid-block 0 to mid-block 1.
        let edit = Self.plan(NSRange(location: 6, length: 10))
        #expect(edit != nil)
        #expect(edit?.deletedBlockIDs.isEmpty == true, "no block is covered whole")
        #expect(edit?.leading?.blockID == "b0")
        #expect(edit?.leading?.variantID == "v0")
        #expect(edit?.leading?.oldText == "Alpha one.",
                "the PLAN-TIME surface text — the compound's compare-and-set input")
        #expect(edit?.leading?.newText == "Alpha ")
        #expect(edit?.trailing?.blockID == "b1")
        #expect(edit?.trailing?.oldText == "Beta two.")
        #expect(edit?.trailing?.newText == "two.")
        #expect(edit?.joinsEnds == true, "both cuts sit mid-paragraph — R-13u-2")
        #expect(edit?.caretBlockID == "b0")
        #expect(edit?.caretOffset == 6)
    }

    /// A run of THREE: the MIDDLE is covered whole, so it rides
    /// `deleteBlock` — the Trash/tray road, her ruling's first clause — and
    /// the two ends keep their identities. A replacement rides the first end.
    @Test func aWhollyCoveredMiddleRidesTheTrayAndTheEndsSurvive() {
        let edit = Self.plan(NSRange(location: 6, length: 20), "X")
        #expect(edit != nil)
        #expect(edit?.deletedBlockIDs == ["b1"], "the middle goes whole")
        #expect(edit?.leading?.blockID == "b0")
        #expect(edit?.leading?.newText == "Alpha X", "the typed text lands where the span opened")
        #expect(edit?.trailing?.blockID == "b2")
        #expect(edit?.trailing?.newText == " three.", "6 + 20 = 26, which is 5 into block 2")
        #expect(edit?.caretOffset == 7, "6 + the replacement's length")
    }

    /// **R-13u-2, in the brain.** A cut at a paragraph break of EITHER kind
    /// — the block's own edge, or an internal newline — suppresses the join.
    @Test func aCutAtAParagraphBreakSuppressesTheJoin() {
        // The span OPENS at block 0's start: a block seam.
        #expect(Self.plan(NSRange(location: 0, length: 16))?.joinsEnds == false)
        // …and the mirror: a span CLOSING at the last block's end covers it
        // whole, so there is no second remainder to join to.
        #expect(Self.plan(NSRange(location: 6, length: 14))?.joinsEnds == false)
        // The internal-newline half, on a two-paragraph first block.
        let internalNewline = "Alpha\nmore.\nBeta two."
        let index = BlockRangeIndex(
            entries: [
                .init(blockID: "b0", variantID: "v0", length: 11, editable: true),
                .init(blockID: "b1", variantID: "v1", length: 9, editable: true),
            ],
            tailLength: nil)
        let surface: (NSRange) -> String = { (internalNewline as NSString).substring(with: $0) }
        // Opening at offset 6 — immediately AFTER the internal newline.
        #expect(CrossBlockCompound.plan(
            replacing: NSRange(location: 6, length: 11), with: "",
            index: index, surfaceText: surface)?.joinsEnds == false)
        // …while opening one character later is mid-paragraph and joins.
        #expect(CrossBlockCompound.plan(
            replacing: NSRange(location: 7, length: 10), with: "",
            index: index, surfaceText: surface)?.joinsEnds == true)
    }

    /// **THE FENCE IS GONE, and that is her ruling** (item 5, built at 13u1
    /// UNIT 2). Merge-then-edit declined any span touching a FANNED block
    /// (the Mac routed it to its own visible-take edit, which the phone
    /// never had). The compound takes fanned spans on both platforms now:
    /// a fanned block covered WHOLE goes to the tray with its family, a
    /// fanned END takes its chosen take's edit only, and the FAN decides
    /// the JOIN — asked of the STORE at run time, never of the plan, which
    /// is why this function no longer takes an arity at all (U-1's
    /// correctness half: never authorize from stale state).
    @Test func aFannedSpanIsThisRoadNowAndTheFanDecidesTheJoinElsewhere() {
        let span = NSRange(location: 6, length: 10)
        let edit = Self.plan(span)
        #expect(edit != nil)
        #expect(edit?.leading?.blockID == "b0")
        #expect(edit?.joinsEnds == true,
                "the GEOMETRY says join; whether it really does is the store's answer")
    }

    /// **A gap slot fences the span — and the run is an index RANGE, so it
    /// fences an INTERIOR gap too** (13u1 UNIT 2, item 8's U-3). A gap
    /// renders with zero length, so the retired planner ran straight past
    /// one and planned a merge ACROSS it; the operations layer then refused
    /// with a raw `blocksNotAdjacent`. Tombstoning a block whose text has
    /// never arrived would delete a peer's paragraph under tombstone-wins.
    @Test func aGapInTheRunHasNoPlan() {
        #expect(Self.plan(NSRange(location: 6, length: 10), index: Self.index(gap: 1)) == nil)
        #expect(Self.plan(NSRange(location: 6, length: 10), index: Self.index(gap: 0)) == nil)
        #expect(Self.plan(NSRange(location: 6, length: 10), index: Self.index(gap: 2)) != nil,
                "a gap OUTSIDE the run does not fence the span")
        // The INTERIOR zero-length gap the old walk could not see.
        let interior = Self.index([10, 0, 12], gap: 1)
        #expect(CrossBlockCompound.plan(
            replacing: NSRange(location: 6, length: 10), with: "",
            index: interior, surfaceText: Self.filler) == nil,
                "the gap sits inside the span and renders nothing — it is IN the run")
    }

    /// **R-13u-1: a LOCKED take anywhere in the run refuses the WHOLE
    /// gesture.** One gesture, one answer.
    @Test func aLockedTakeInTheRunHasNoPlan() {
        #expect(Self.plan(NSRange(location: 6, length: 10), index: Self.index(locked: 1)) == nil)
        #expect(Self.plan(NSRange(location: 6, length: 10), index: Self.index(locked: 0)) == nil)
    }

    /// A span reaching the OPEN TAIL is refused by the contiguity guard —
    /// the tail is not a block yet (idle-mint makes it one within seconds).
    @Test func aSpanReachingTheOpenTailHasNoPlan() {
        let withTail = Self.index([10, 9], tail: 4)
        // Entries (0,10) and (11,9); the tail's text starts at 21.
        #expect(CrossBlockCompound.plan(
            replacing: NSRange(location: 6, length: 17), with: "",
            index: withTail, surfaceText: Self.text) == nil,
                "the span runs past the last entry's end, into the tail")
        #expect(CrossBlockCompound.plan(
            replacing: NSRange(location: 6, length: 10), with: "",
            index: withTail, surfaceText: Self.text) != nil,
                "…while a span that stops inside the blocks is fine")
    }

    /// One block is not a cross-block edit; the ordinary verdict owns it.
    @Test func aSingleBlockSpanHasNoPlan() {
        #expect(Self.plan(NSRange(location: 1, length: 4)) == nil)
    }

    /// **A SEAM KEYSTROKE can never reach this road**, and that is what
    /// keeps A7's empty-block carve and #34's texted-seam merge owning the
    /// geometry they were ruled on. *(13u1 UNIT 2 re-derived it: the run now
    /// admits zero-length entries INSIDE the span, so "a separator
    /// intersects nothing" stopped being the whole argument — but a
    /// one-character separator range can reach at most the entry BEFORE it,
    /// and only when that entry is empty, so the count never reaches two.)*
    @Test func aSeamKeystrokeIsNotACrossBlockEdit() {
        #expect(Self.plan(NSRange(location: 10, length: 1)) == nil, "the separator after block 0")
        #expect(Self.plan(NSRange(location: 20, length: 1)) == nil, "…and the one after block 1")
        // The empty-heavy tiling, walked at every separator.
        let empties = Self.index([0, 5, 0, 0, 4])
        for offset in 0..<empties.documentLength {
            #expect(CrossBlockCompound.plan(
                replacing: NSRange(location: offset, length: 1), with: "",
                index: empties, surfaceText: Self.filler) == nil,
                    "a one-character range reached the compound at \(offset)")
        }
    }

    /// **A CARET NEVER PLANS A COMPOUND.** A zero-length range overlaps
    /// nothing and encloses no entry, so the run is empty on every legal
    /// tiling — an empty neighbour included.
    @Test func aCaretAtASeamNeverPlansACompound() {
        #expect(Self.plan(NSRange(location: 10, length: 0)) == nil, "the seam's left side")
        #expect(Self.plan(NSRange(location: 11, length: 0)) == nil, "…and its right side")
        #expect(CrossBlockCompound.plan(
            replacing: NSRange(location: 11, length: 0), with: "",
            index: Self.index([10, 0, 9]), surfaceText: Self.filler) == nil,
                "…and beside an EMPTY block, which is the one shape worth checking")
    }

    /// **THE ONE-PASS WALK ANSWERS EXACTLY WHAT THE INDEX'S OWN ACCESSOR
    /// DOES** — the equivalence the perf fix rests on. `range(ofEntryAt:)`
    /// walks from zero each call; the plan reads the tiling once. Checked on
    /// an IRREGULAR tiling with empty entries at both edges and in the
    /// middle, which is where an off-by-one would hide.
    @Test func theWalkAgreesWithTheIndexsOwnAccessor() {
        let lengths = [0, 7, 0, 0, 13, 1, 0]
        let index = Self.index(lengths)
        var location = 0
        for i in lengths.indices {
            let accessor = index.range(ofEntryAt: i)
            #expect(accessor == NSRange(location: location, length: lengths[i]))
            location += lengths[i] + 1
        }
        // …and the plan built on it still answers the geometry the same way:
        // a span from inside entry 1 to inside entry 4.
        let edit = CrossBlockCompound.plan(
            replacing: NSRange(location: 4, length: 15), with: "",
            index: index, surfaceText: Self.filler)
        #expect(edit != nil)
        #expect(edit?.leading?.blockID == "b1")
        #expect(edit?.trailing?.blockID == "b4")
        #expect(edit?.deletedBlockIDs == ["b2", "b3"],
                "the zero-length entries between them are IN the run and covered whole")
        #expect(edit?.caretOffset == 3, "4 - entry 1's start (1)")
        #expect(edit?.trailing?.newText.count == 5, "13 - 8, the trailing keep")
    }

    /// **THE COST, measured rather than argued (P1/P-8) — and RED ON THE
    /// PRE-FIX WALK.** The original loop asked `index.range(ofEntryAt: i)`
    /// per entry, and that accessor walks from zero every call: O(N²) in the
    /// note's BLOCK COUNT, on a main-actor keystroke road. This pin measured
    /// **23.8 s for one plan at 20,000 entries** on the pre-fix walk, which
    /// is ~100 ms of freeze at her own 100k-word bar (~1,400 paragraphs) —
    /// cost proportional to the DOCUMENT, the one thing P1 forbids.
    ///
    /// *(13u1 UNIT 2 makes the claim STRONGER: the plan reads the tiling
    /// once and calls `surfaceText` at most TWICE — once per surviving end —
    /// so its cost is the EDIT's, not the note's, at both scales.)*
    @Test func thePlanStaysCheapAtTwentyThousandBlocks() {
        let index = Self.index(Array(repeating: 40, count: 20_000))
        let clock = ContinuousClock()
        let text: (NSRange) -> String = { String(repeating: "x", count: $0.length) }

        // A real gesture: mid-block 100 to mid-block 102.
        let span = NSRange(location: 100 * 41 + 20, length: 2 * 41)
        var planned: CrossBlockCompound.Plan?
        let gestureCost = clock.measure {
            planned = CrossBlockCompound.plan(
                replacing: span, with: "", index: index, surfaceText: text)
        }
        #expect(planned?.leading?.blockID == "b100")
        #expect(planned?.trailing?.blockID == "b102")
        #expect(planned?.deletedBlockIDs == ["b101"])
        #expect(gestureCost < .milliseconds(50),
                "a re-quadratic walk measured 23.8 SECONDS here")

        // The seam keystroke that reaches this arm and finds nothing.
        let seam = NSRange(location: 40, length: 1)
        var seamCost = Duration.zero
        seamCost = clock.measure {
            #expect(CrossBlockCompound.plan(
                replacing: seam, with: "", index: index, surfaceText: text) == nil)
        }
        #expect(seamCost < .milliseconds(50),
                "…and 23.3 s for the keystroke that plans nothing at all")

        print("PERF[plan] crossBlockCompound @20k blocks — gesture \(gestureCost) · seam \(seamCost)")
    }
}

// MARK: - The phone's face

@Suite("Merge-then-edit on the phone (M22)")
@MainActor
struct MobileCrossBlockEditTests {

    /// **HER CASE.** Select from the middle of one paragraph through the
    /// middle of the next and hit delete. The paragraphs JOIN and the
    /// selection vanishes — one act, exactly as on her Mac.
    ///
    /// RED ON OLD: pre-batch this leaves all three blocks untouched and
    /// `statusMessage` reads "This edit spans more than one block…".
    @Test func aPartialCrossBlockSpanMergesAndTakesTheSelectionWithIt() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // "Alpha one.\nBeta two.\nGamma three." — 6..16 is
            // "one." + the seam + "Beta ".
            await editSpan(model, storage, NSRange(location: 6, length: 10))

            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha two.", "Gamma three."],
                    "the two paragraphs joined and the selected span is gone")
            #expect(model.index.entries.count == 2, "the surface healed to the store's shape")
            #expect(model.statusMessage == nil, "no refusal, and no chatter either")
        }
    }

    /// Typing OVER the same span: the typed characters land where the
    /// selection started, in the merged buffer.
    ///
    /// RED ON OLD: pre-batch the keystroke refused and nothing was typed.
    @Test func typingOverACrossBlockSpanMergesAndKeepsTheTypedText() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            await editSpan(model, storage, NSRange(location: 6, length: 10), "X")

            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha Xtwo.", "Gamma three."],
                    "the typed character is never dropped on the floor")
        }
    }

    // MARK: - #109's boundary-clamp law reaching the phone (13u2 UNIT C)

    /// **SHAPE (ii) — the TRIM — reaches the phone through the SHARED
    /// compound**, with no phone-side arm at all: the clamp lives inside
    /// `CrossBlockCompound.plan`, so the road this suite already drives
    /// inherits it. Her ruling of 2026-09-15, both platforms, one brain.
    ///
    /// **RED ON OLD:** the compound's contiguity guard refused this span,
    /// nothing was trayed, and `statusMessage` carried the boundary line.
    @Test func aSpanOpeningOnTheSeparatorTrimsAndTraysTheWholeBlock() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // From the END of "Alpha one." (offset 10 — ON the separator)
            // through "Gamma ": "Beta two." covered whole, "Gamma three." in
            // part, the first block's characters untouched.
            await editSpan(model, storage, NSRange(location: 10, length: 17))

            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha one.", "three."],
                    "the whole block went; the ends kept their own blocks (R-13u-2)")
            #expect(model.statusMessage == nil, "no refusal: \(model.statusMessage ?? "")")
        }
    }

    /// **SHAPE (i) — clamp and EDIT — is PLANNED on the phone from the same
    /// brain**, and the phone's arm routes to it.
    ///
    /// **What this pin deliberately does NOT assert, and why:** the LANDING.
    /// Shape (i) lands through the phone's one ordinary input door
    /// (`MobileMarkdownActs.inputReplace`), which needs a real `UITextView`
    /// — and this harness attaches STORAGE only, never a view. Making the
    /// road work without one would mean a SECOND input path on the phone,
    /// which is the exact thing that door exists to prevent. So the plan is
    /// pinned here, the landing is pinned on the Mac (`BoundaryClampTests`,
    /// same shared brain), and the phone's own walk is the mobile catch-up's
    /// (PL-23). The gate's routing is visible in the two assertions below:
    /// the keystroke is refused and NOTHING is spoken, where before the
    /// refusal line was.
    @Test func shapeOneIsPlannedFromTheSharedBrainAndTheGateRoutesToIt() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // "one." plus the separator at 10 — released exactly where
            // "Beta" begins.
            let span = NSRange(location: 6, length: 5)
            let planned = try #require(
                model.planClampedInBlockEdit(range: span, replacement: ""))
            #expect(planned.range == NSRange(location: 6, length: 4),
                    "clamped to the block's own text — the break stands")
            #expect(planned.blockID == seed.blockIDs[0])

            await editSpan(model, storage, span)
            #expect(model.statusMessage == nil,
                    "the boundary refusal is gone: \(model.statusMessage ?? "")")
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."],
                    "…and nothing was half-applied by the refused keystroke")
        }
    }

    /// A span across THREE paragraphs merges the whole run — the chain, not
    /// just the pair.
    ///
    /// RED ON OLD: pre-batch, three blocks and a refusal.
    @Test func aSpanAcrossThreeParagraphsMergesTheWholeRun() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // 6..27: "one." + seam + "Beta two." + seam + "Gamma ".
            await editSpan(model, storage, NSRange(location: 6, length: 21))

            #expect(try await storedBlockTexts(db, postID: seed.postID) == ["Alpha three."])
            #expect(model.index.entries.count == 1)
        }
    }

    /// **ONE undo entry, and the sources come back whole.** A merge RELEASES
    /// its sources to lineage (AppSpec §9's W resolution), so the pre-edit
    /// text was never destroyed — and one undo puts the paragraphs back
    /// where they were. The Mac's own compound label rides the shared brain,
    /// so this phone's undo door reads the same words (M20, batch 4 — the
    /// door was still "future" when this was written; 4.5c-phone item 5).
    ///
    /// RED ON OLD: pre-batch nothing landed, so there was no entry at all.
    @Test func theWholeActIsOneUndoEntryAndTheParagraphsComeBack() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            await editSpan(model, storage, NSRange(location: 6, length: 10))
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha two.", "Gamma three."])

            let stack = session.undoStack
            #expect(stack.topLabel == CrossBlockCompound.undoLabel)
            try await session.runner.run { ops in _ = try stack.undo(with: ops) }
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."],
                    "ONE undo restores both paragraphs, with their original text")
        }
    }

    /// **THE FENCE IS GONE, AT THE GESTURE — and that is her ruling** (item
    /// 5, built at 13u1 UNIT 2). This pin used to hold the opposite: a span
    /// touching a FANNED block refused on the phone, because the Mac routed
    /// it to the visible-take edit (#11a) and the author was handling the
    /// fanned case herself. She handled it: a fanned block covered WHOLE
    /// goes to the tray with its family, and a fanned END takes its chosen
    /// take's edit and nothing else.
    ///
    /// Here the fan is on the MIDDLE block, covered whole — so it leaves the
    /// page with both its takes, and the two ends join because neither of
    /// them carries a fan.
    ///
    /// RED ON OLD: the plan answered nil and the store kept three blocks.
    @Test func aFannedMiddleRidesTheTrayAndTheEndsJoinOnThePhone() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            try await session.runner.run { [blockID = seed.blockIDs[1]] ops in
                _ = try ops.newBlankVariant(blockID)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            #expect(model.slots[1].activeVariantCount == 2, "block 1 carries a fan")

            // Mid-block 0 through mid-block 2: block 1 is covered WHOLE.
            let span = NSRange(location: 6, length: 21)
            #expect(model.planCrossBlockEdit(range: span, replacement: "") != nil,
                    "a fanned span is THIS road now")
            await editSpan(model, storage, span)

            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha three."],
                    "the ends joined; the fanned middle left the page whole")
            // Its takes rode with it — the block is tombstoned, not emptied.
            let takes = try await db.read { [blockID = seed.blockIDs[1]] db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM variant WHERE block_id = ?",
                    arguments: [blockID]) ?? -1
            }
            #expect(takes == 2, "both takes are preserved on the tombstoned block")
        }
    }

    /// **A SPAN RUNNING PAST A NOT-YET-ARRIVED BLOCK: nothing merges, and
    /// the refusal says why.**
    ///
    /// **13u1 UNIT 2 CLOSED THE FINDING THIS PIN RECORDED.** It used to read:
    /// a gap slot renders with ZERO length, so the selection never
    /// intersects its characters, and the plan named the two blocks she
    /// could read and skipped it — a plan doomed by construction, since the
    /// gap's placement still sat between them and `ops.merge` refused on
    /// adjacency inside the one transaction. The round left it because
    /// narrowing the plan's conditions was a change to a ratified Mac road
    /// rather than a hoist. Item 8's U-3 made that change: the run is an
    /// index RANGE now, so the gap is IN it and the plan FENCES rather than
    /// planning something the ops layer must refuse. The outcome she meets
    /// is the same and better sourced — the refusal names the block that
    /// has not arrived, and no operation is attempted at all.
    ///
    /// RED ON OLD for the sentence (the ladder MINOR 2 class); the
    /// nothing-merged half is green on both trees.
    @Test func aSpanRunningPastAGapRefusesInWordsAndMergesNothing() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            // The SyncSpec §5 gap state, manufactured (the batch-1b seed's
            // shape): the block row is here, its variant is not.
            try await db.write { [blockID = seed.blockIDs[1]] db in
                try db.execute(
                    sql: "UPDATE variant SET deleted_at = ? WHERE block_id = ?",
                    arguments: ["2026-08-21T00:00:00Z", blockID])
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            #expect(model.index.entries[1].variantID == nil, "the middle slot is a gap")

            // Opens mid-block 0 and runs past the gap's (zero-length) slot
            // into the block below it.
            let span = NSRange(location: 6, length: 10)
            let planned = model.planCrossBlockEdit(range: span, replacement: "")
            #expect(
                planned == nil,
                """
                the gap is IN the run, so the plan FENCES it (U-3) instead of \
                planning a merge the ops layer must refuse
                """)
            await editSpan(model, storage, span)

            let status = try #require(model.statusMessage)
            #expect(!status.contains("blocksNotAdjacent"), "never the raw enum")
            #expect(status.contains("hasn't arrived yet"))
            #expect(status.lowercased().contains("nothing was changed"))
            let live = try await db.read { [postID = seed.postID] db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [postID]) ?? -1
            }
            #expect(live == 3, "nothing merged — not the gap, and not its neighbours")
        }
    }

    /// **The whole-block DELETE road keeps its cases.** A selection covering
    /// paragraphs WHOLE means "these paragraphs go", not "join them and
    /// leave the join empty" — so it must still route to batch 1b's delete
    /// compound, above this batch's road in the same ladder.
    ///
    /// BOUNDARY CHARACTERIZATION: green on both trees, and the regression
    /// guard that matters most in this batch — a merge-then-edit that stole
    /// this geometry would silently change what her ⌫ does to a selected
    /// paragraph.
    @Test func aWholeParagraphSelectionStillDeletesRatherThanMerging() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let beta = model.index.range(ofEntryAt: 1)
            await editSpan(
                model, storage, NSRange(location: beta.location, length: beta.length + 1))

            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha one.", "Gamma three."],
                    "the paragraph is GONE — not merged into its neighbour")
            #expect(model.statusMessage == MobileStructuralController.blockDeletedStatus)
        }
    }

    /// A SEALED note refuses with nothing changed — the gate's own lock
    /// answer fires before the gesture is armed, and the compound's legs
    /// would refuse through the operations layer besides.
    ///
    /// BOUNDARY CHARACTERIZATION: green on both trees.
    @Test func aSealedNoteRefusesAndMergesNothing() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            #expect(model.isSealed)

            await editSpan(model, storage, NSRange(location: 6, length: 10))

            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."])
            #expect(model.statusMessage == "This note is locked — unlock it to edit.")
        }
    }

    /// **DRIVEN ON THE REAL SURFACE, through the exact call UIKit makes for
    /// ⌫** (§34's M25 lesson: `deleteBackward()` and `replace(_:withText:)`
    /// mutate storage WITHOUT consulting the delegate, so a pin that drives
    /// them exercises the system-path fallback and never the gesture it
    /// believes it is testing). The delegate answer is asserted too, so the
    /// path this pin drove is provably the path it meant.
    ///
    /// The CARET is what only this arm can see: it lands where the deleted
    /// span began, inside the merged block.
    ///
    /// RED ON OLD: pre-batch the store keeps three blocks.
    @Test func theKeystrokeMergesOnTheRealSurfaceAndLandsTheCaret() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)

            let span = NSRange(location: 6, length: 10)
            surface.textView.selectedRange = span
            let allowed = surface.textView.delegate?.textView?(
                surface.textView, shouldChangeTextIn: span, replacementText: "")
            await model.pendingGestureTask?.value

            #expect(allowed == false, "the storage never half-applies a cross-block edit")
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha two.", "Gamma three."])
            let merged = try #require(model.index.entries.first)
            let range = try #require(model.rangeOfBlock(merged.blockID))
            #expect(surface.textView.selectedRange
                == NSRange(location: range.location + 6, length: 0),
                    "the caret sits where the selection began")
        }
    }

    /// The no-redirect principle on this batch's new copy: nothing it can
    /// say names the other platform, or a door this phone lacks.
    @Test func theNewRefusalNamesNothingThePhoneDoesNotHave() {
        let lines = [
            MobileStructuralController.refusalMessage(
                OperationError.bufferChangedSinceGesture(variantID: "v1"),
                act: "join these blocks"),
            MobileStructuralController.refusalMessage(
                OperationError.lockedPost(id: "p1"), act: "join these blocks"),
            MobileStructuralController.refusalMessage(
                OperationError.blocksNotAdjacent(first: "b0", second: "b2"),
                act: "join these blocks"),
        ]
        for line in lines {
            #expect(!line.contains("Mac"))
            #expect(!line.contains("bufferChanged"), "never the raw enum")
            // The phone HAS an undo door (M20, batch 4 — `MobileUndoDoor`,
            // rendered with its label in the masthead and the ⋯ sheet). What
            // it has no culture of is CHORDS, so copy naming ⌥⌘Z would point
            // her at a Mac keystroke this surface cannot receive — the
            // no-redirect principle, which is what this assertion is for.
            // *(4.5c-phone item 5: the old reason — "there is no undo door on
            // this phone yet" — has been false since batch 4. The assertion
            // was right and its reason had gone stale under it.)*
            #expect(!line.contains("\u{2325}\u{2318}Z"), "the phone has no chord to name")
        }
        #expect(lines[0].contains("nothing was changed"),
                "a rolled-back gesture must not read as a half-done one")
    }
}
