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
//  THE FENCE, stated where a later session will read it: a span touching a
//  block that HAS TAKES is not this road's. The Mac routes it to its own
//  visible-take edit (the #11a sitting ruling of 2026-07-13 — the halves
//  JOIN only where no fan hangs on the seam), which is Mac-app code and
//  stays there; the author is handling the fanned case herself.
//  `aFannedSpanIsNotThisRoad` and `aFannedSpanStillRefusesOnThePhone` are
//  that fence in both layers.
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
        let ids = try texts.map { try ops.newBlock(in: post.id, text: $0, at: .end).block.id }
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

@Suite("The shared merge-then-edit brain (M22's hoist)")
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

    private static func plan(
        _ range: NSRange, _ replacement: String = "",
        index: BlockRangeIndex = index(), arities: [Int] = [1, 1, 1]
    ) -> CrossBlockEditPlanner.Edit? {
        CrossBlockEditPlanner.plan(
            replacing: range, with: replacement,
            index: index, fanArities: arities, surfaceText: text)
    }

    /// The plan names the touched run and the two intra offsets that anchor
    /// the edit inside the MERGED text — the arithmetic `apply` reads.
    @Test func thePlanNamesTheRunAndTheIntraOffsets() {
        // 6..16: "one." + the separator + "Beta " — mid-block 0 to mid-block 1.
        let edit = try? #require(Self.plan(NSRange(location: 6, length: 10)))
        #expect(edit?.blockIDs == ["b0", "b1"])
        #expect(edit?.pieces.map(\.variantID) == ["v0", "v1"])
        #expect(edit?.pieces.map(\.text) == ["Alpha one.", "Beta two."],
                "the PLAN-TIME surface texts — the compound's compare-and-set inputs")
        #expect(edit?.intraStart == 6, "intra the FIRST block")
        #expect(edit?.intraEndInLast == 5, "intra the LAST block")
        #expect(edit?.lastPieceLength == 9)
        #expect(edit?.replacement == "")
    }

    /// A run of THREE, and a replacement riding along.
    @Test func aRunOfThreeBlocksPlansWithItsReplacement() {
        let edit = try? #require(Self.plan(NSRange(location: 6, length: 20), "X"))
        #expect(edit?.blockIDs == ["b0", "b1", "b2"])
        #expect(edit?.intraStart == 6)
        #expect(edit?.intraEndInLast == 5, "6 + 20 = 26, which is 5 into block 2")
        #expect(edit?.lastPieceLength == 12)
        #expect(edit?.replacement == "X")
    }

    /// **THE FENCE, in the brain.** A touched block with TAKES declines —
    /// merge-then-edit stays the single×single behaviour (the #11a sitting
    /// ruling, 2026-07-13). The Mac routes that span to its visible-take
    /// edit; the phone has no such road and refuses. Neither is this
    /// function's business, and this pin is here so it never becomes it.
    ///
    /// BOUNDARY CHARACTERIZATION: green on both trees.
    @Test func aFannedSpanIsNotThisRoad() {
        let span = NSRange(location: 6, length: 10)
        #expect(Self.plan(span, arities: [1, 1, 1]) != nil, "the control")
        #expect(Self.plan(span, arities: [2, 1, 1]) == nil, "a fan on the FIRST touched block")
        #expect(Self.plan(span, arities: [1, 2, 1]) == nil, "…or on the second")
        #expect(Self.plan(span, arities: [1, 1, 5]) != nil,
                "a fan OUTSIDE the touched run is nobody's business here")
    }

    /// A missing arity DECLINES — deliberately stricter than
    /// `StructuralGesturePlanner.World.fanArity`, which reads a missing
    /// entry as 1. `slots` lags `entries` during a crystallization window,
    /// and this road MERGES blocks: an unknown fan is not a fan it may
    /// assume away. The shipped Mac rule, preserved by the hoist.
    @Test func aMissingArityDeclinesRatherThanAssumingNoFan() {
        let span = NSRange(location: 6, length: 10)
        #expect(Self.plan(span, arities: [1]) == nil, "block 1's arity is unknown")
        #expect(Self.plan(span, arities: []) == nil)
    }

    /// A gap slot (its variant has not arrived) has nothing to merge.
    /// BOUNDARY CHARACTERIZATION: green on both trees.
    @Test func aGapInTheSpanHasNoPlan() {
        #expect(Self.plan(NSRange(location: 6, length: 10), index: Self.index(gap: 1)) == nil)
        #expect(Self.plan(NSRange(location: 6, length: 10), index: Self.index(gap: 0)) == nil)
        #expect(Self.plan(NSRange(location: 6, length: 10), index: Self.index(gap: 2)) != nil,
                "a gap OUTSIDE the touched run does not fence the span")
    }

    /// A LOCKED take's buffer is frozen: no road edits it.
    /// BOUNDARY CHARACTERIZATION: green on both trees.
    @Test func aLockedTakeInTheSpanHasNoPlan() {
        #expect(Self.plan(NSRange(location: 6, length: 10), index: Self.index(locked: 1)) == nil)
    }

    /// A span reaching the OPEN TAIL is refused by the contiguity guard —
    /// the tail is not a block yet (idle-mint makes it one within seconds).
    /// BOUNDARY CHARACTERIZATION: green on both trees.
    @Test func aSpanReachingTheOpenTailHasNoPlan() {
        let withTail = Self.index([10, 9], tail: 4)
        // Entries (0,10) and (11,9); the tail's text starts at 21.
        #expect(CrossBlockEditPlanner.plan(
            replacing: NSRange(location: 6, length: 17), with: "",
            index: withTail, fanArities: [1, 1], surfaceText: Self.text) == nil,
                "the span runs past the last entry's end, into the tail")
        #expect(CrossBlockEditPlanner.plan(
            replacing: NSRange(location: 6, length: 10), with: "",
            index: withTail, fanArities: [1, 1], surfaceText: Self.text) != nil,
                "…while a span that stops inside the blocks is fine")
    }

    /// One block is not a cross-block edit; the ordinary verdict owns it.
    @Test func aSingleBlockSpanHasNoPlan() {
        #expect(Self.plan(NSRange(location: 1, length: 4)) == nil)
    }

    /// **A SEAM KEYSTROKE can never reach this road**, and that is what
    /// keeps A7's empty-block carve and #34's texted-seam merge owning the
    /// geometry they were ruled on: a lone separator intersects NO entry, so
    /// the touched run is empty. Pinned on both platforms' behalf — the
    /// Mac's routing arm relies on exactly this.
    ///
    /// BOUNDARY CHARACTERIZATION: green on both trees.
    @Test func aSeamKeystrokeIsNotACrossBlockEdit() {
        #expect(Self.plan(NSRange(location: 10, length: 1)) == nil, "the separator after block 0")
        #expect(Self.plan(NSRange(location: 20, length: 1)) == nil, "…and the one after block 1")
    }

    /// **A CARET NEVER PLANS A MERGE — traced, not assumed.** The collection
    /// loop has a zero-length arm (a caret counts as touching an entry whose
    /// CLOSED range contains it), and reading the code it looks as though a
    /// caret at a seam might touch both neighbours. It cannot: entries are
    /// separated by exactly one character, so the seam's left side is inside
    /// entry i's closed range only and its right side inside entry i+1's
    /// only — the touched count is always 1, and the run guard declines.
    /// (A zero-length entry does not change this; it still starts one past
    /// the previous separator.)
    ///
    /// Recorded as behaviour because it is what makes the arm harmless: the
    /// zero-length clause is unreachable-as-a-plan on any legal tiling, and
    /// it is preserved verbatim by the hoist rather than "cleaned up" on a
    /// reading. If a future tiling ever put two entries at one offset, this
    /// pin is where the surprise would land.
    @Test func aCaretAtASeamNeverPlansAMerge() {
        #expect(Self.plan(NSRange(location: 10, length: 0)) == nil, "the seam's left side")
        #expect(Self.plan(NSRange(location: 11, length: 0)) == nil, "…and its right side")
        #expect(CrossBlockEditPlanner.plan(
            replacing: NSRange(location: 11, length: 0), with: "",
            index: Self.index([10, 0, 9]), fanArities: [1, 1, 1],
            surfaceText: Self.text) == nil,
                "…and beside an EMPTY block, which is the one shape worth checking")
    }

    /// **THE ONE-PASS WALK ANSWERS EXACTLY WHAT THE INDEX'S OWN ACCESSOR
    /// DOES** — the equivalence the perf fix below rests on. `range(ofEntryAt:)`
    /// walks from zero each call; the plan accumulates the same sum once.
    /// Checked on an IRREGULAR tiling with empty entries at both edges and in
    /// the middle, which is where an off-by-one would hide.
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
        let edit = try? #require(CrossBlockEditPlanner.plan(
            replacing: NSRange(location: 4, length: 15), with: "",
            index: index, fanArities: Array(repeating: 1, count: lengths.count),
            surfaceText: { _ in "" }))
        #expect(edit?.blockIDs == ["b1", "b4"],
                "the zero-length entries between them are touched by nothing")
        #expect(edit?.intraStart == 3, "4 - entry 1's start (1)")
        #expect(edit?.intraEndInLast == 8, "19 - entry 4's start (11)")
        #expect(edit?.lastPieceLength == 13)
    }

    /// **THE COST, measured rather than argued (P1/P-8) — and RED ON THE
    /// PRE-FIX WALK.** The hoisted loop asked `index.range(ofEntryAt: i)`
    /// per entry, and that accessor walks from zero every call: O(N²) in the
    /// note's BLOCK COUNT, on a main-actor keystroke road. This pin measured
    /// **23.8 s for one plan at 20,000 entries** on the pre-fix walk, which
    /// is ~100 ms of freeze at her own 100k-word bar (~1,400 paragraphs) —
    /// cost proportional to the DOCUMENT, the one thing P1 forbids. One pass
    /// over the tiling answers identically (`theWalkAgreesWithTheIndexsOwnAccessor`)
    /// and the same measurement lands in single-digit milliseconds.
    ///
    /// The fix rides the SHARED brain, so the Mac inherits it: this walk has
    /// been quadratic there since 2026-07-09.
    ///
    /// What is measured: the plan walks the entry TILING — block count,
    /// never character count — at GESTURE cadence (it is reached only after
    /// `verdict` has answered `.crossesBlockBoundary`), and BOTH shapes that
    /// get there are under the clock: a real three-block gesture, and the
    /// seam keystroke that finds no touched entry. 20,000 entries is the
    /// ceiling batch 1b's sibling pin adopted — an order of magnitude past
    /// her own bar, so a re-quadratic walk cannot hide inside the headroom.
    @Test func thePlanStaysCheapAtTwentyThousandBlocks() {
        let index = Self.index(Array(repeating: 40, count: 20_000))
        let arities = Array(repeating: 1, count: 20_000)
        let clock = ContinuousClock()
        let text: (NSRange) -> String = { String(repeating: "x", count: $0.length) }

        // A real gesture: mid-block 100 to mid-block 102.
        let span = NSRange(location: 100 * 41 + 20, length: 2 * 41)
        var planned: CrossBlockEditPlanner.Edit?
        let gestureCost = clock.measure {
            planned = CrossBlockEditPlanner.plan(
                replacing: span, with: "", index: index,
                fanArities: arities, surfaceText: text)
        }
        #expect(planned?.blockIDs.count == 3)
        #expect(gestureCost < .milliseconds(50),
                "a re-quadratic walk measured 23.8 SECONDS here")

        // The seam keystroke that reaches this arm and finds nothing.
        let seam = NSRange(location: 40, length: 1)
        var seamCost = Duration.zero
        seamCost = clock.measure {
            #expect(CrossBlockEditPlanner.plan(
                replacing: seam, with: "", index: index,
                fanArities: arities, surfaceText: text) == nil)
        }
        #expect(seamCost < .milliseconds(50),
                "…and 23.3 s for the keystroke that plans nothing at all")

        print("PERF[plan] crossBlockEdit @20k blocks — gesture \(gestureCost) · seam \(seamCost)")
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
            #expect(stack.topLabel == "Merge & Edit")
            try await session.runner.run { ops in _ = try stack.undo(with: ops) }
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."],
                    "ONE undo restores both paragraphs, with their original text")
        }
    }

    /// **THE FENCE, at the gesture.** A span touching a block that HAS TAKES
    /// still refuses on the phone: the Mac routes it to the visible-take
    /// edit (#11a), which is Mac-app code and stays there — the author is
    /// handling the fanned case herself. Nothing is merged, nothing is
    /// deleted, and the refusal speaks.
    ///
    /// BOUNDARY CHARACTERIZATION: green on both trees. It exists so this
    /// road can never quietly grow onto fanned blocks.
    @Test func aFannedSpanStillRefusesOnThePhone() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeParagraphs(session)
            try await session.runner.run { [blockID = seed.blockIDs[1]] ops in
                _ = try ops.newBlankVariant(blockID)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            #expect(model.slots[1].activeVariantCount == 2, "block 1 carries a fan")

            let span = NSRange(location: 6, length: 10)
            #expect(model.planCrossBlockEdit(range: span, replacement: "") == nil)
            await editSpan(model, storage, span)

            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."],
                    "a fanned span is untouched by this road")
            #expect(model.statusMessage
                == model.message(for: BlockRangeIndex.Refusal.crossesBlockBoundary))
        }
    }

    /// **A SPAN RUNNING PAST A NOT-YET-ARRIVED BLOCK: nothing merges, and
    /// the refusal says why — traced, and its shape is a finding, not a
    /// design.** A gap slot renders with ZERO length (its text is nil), so
    /// the selection never intersects its characters and the plan names the
    /// two blocks she CAN read, skipping it. That plan is doomed by
    /// construction: the gap's placement still sits between them, so
    /// `ops.merge` refuses on adjacency inside the one transaction and
    /// nothing changes.
    ///
    /// **This is the Mac's behaviour, preserved verbatim by M22's hoist**
    /// (the same span plans and fails there today), which is why this batch
    /// did not fence it: the plan's conditions are a ratified rule, and
    /// narrowing them is a change to a Mac road, not a hoist. What the batch
    /// DID fix is the words — the door used to answer a raw
    /// `blocksNotAdjacent(first:second:)` enum dump.
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
            #expect(planned?.blockIDs == [seed.blockIDs[0], seed.blockIDs[2]],
                    "the plan skips the gap — it has no characters to touch")
            await editSpan(model, storage, span)

            let status = try #require(model.statusMessage)
            #expect(!status.contains("blocksNotAdjacent"), "never the raw enum")
            #expect(status.contains("hasn't arrived yet"))
            #expect(status.contains("Nothing was changed"))
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
