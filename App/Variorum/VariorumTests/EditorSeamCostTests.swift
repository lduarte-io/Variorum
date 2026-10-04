//
//  EditorSeamCostTests.swift
//  VariorumTests
//
//  **Phase 13u1, UNIT 1 — the O(N²) class, swept to completion and pinned.**
//
//  `BlockRangeIndex.range(ofEntryAt:)` walks the entries from ZERO on every
//  call (it is O(i) by construction — the tiling invariant is a running sum).
//  A caller that asks it once per entry inside a loop therefore pays
//  Σi ≈ N²/2 **on the main actor**, which is cost proportional to the
//  DOCUMENT — P1's one prohibition ("no operation's cost may scale with
//  total document or corpus size — only with viewport + edit size").
//
//  The class was opened by `KnownIssuesAndTechDebt.md`'s `planVisibleTakeEdit`
//  row (owner 13u1), whose own remedy text demanded it be *"swept to
//  completion — every caller of that accessor inside a loop, on both
//  platforms, each verdicted FIXED-with-a-named-pin or provably SAFE"*, and
//  widened by the 2026-08-30 proactive sweep (P16 the merge-enablement road,
//  P17 the differential projection apply, P22 Replace-All-in-Every-Take).
//  The fixed twin — `CrossBlockEditPlanner.plan`, mobile round 2 — measured
//  **23.8 s for ONE plan at 20,000 entries** before it accumulated instead,
//  which is the constant every budget below is chosen against.
//
//  **The remedy is arithmetic, never policy:** entry `i` starts at
//  `Σ_{j<i}(length_j + 1)`, which is precisely what the accessor computes one
//  call at a time, so ONE accumulating pass answers identically. The
//  equivalence pin below is the proof; the cost pins are the measurements.
//
//  ── On the budgets ───────────────────────────────────────────────────────
//  Every budget here carries a ≥100× margin over the measured post-fix
//  number and is blown by ORDERS of magnitude on the pre-fix code, so none of
//  these is a load-flaky latency pin (the standing `KnownIssuesAndTechDebt`
//  row about `rewriteStrategyLatencies` is the counter-example to avoid:
//  a pin whose verdict flips with machine load cannot do its job). Measured
//  numbers are recorded in `notes/plans/phase-13u1-editor-seam.md`'s UNIT 1
//  RECORD, base and current, from the same box.
//

import AppKit
import Foundation
import Testing
import VariorumCore

@testable import Variorum

@Suite("The editor seam's cost floor (13u1 UNIT 1)")
struct EditorSeamCostTests {
    // MARK: - The equivalence the whole sweep rests on

    private static func index(_ lengths: [Int]) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: lengths.enumerated().map { i, length in
                BlockRangeIndex.Entry(
                    blockID: "b\(i)", variantID: "v\(i)", length: length, editable: true)
            },
            tailLength: nil)
    }

    /// **THE ONE-PASS WALK ANSWERS EXACTLY WHAT THE INDEX'S OWN ACCESSOR
    /// DOES.** Checked on an IRREGULAR tiling with empty entries at BOTH
    /// edges and in the middle — the shape the KnownIssues row names, and
    /// the one where an off-by-one hides (a zero-length entry contributes
    /// only its separator, so a walk that forgets the `+ 1` agrees
    /// everywhere else).
    @Test func theEntryRangesWalkAgreesWithTheIndexsOwnAccessor() {
        for lengths in [[0, 7, 0, 0, 13, 1, 0], [5], [0], [], [3, 0], [0, 4]] {
            let index = Self.index(lengths)
            let walked = index.entryRanges()
            #expect(walked.count == lengths.count)
            for i in lengths.indices {
                #expect(walked[i] == index.range(ofEntryAt: i),
                        "entry \(i) of \(lengths)")
            }
        }
    }

    /// …and the walk agrees with the DOCUMENT the tiling describes: the last
    /// entry ends exactly where a tail-free document does.
    @Test func theWalkLandsTheLastEntryAtTheDocumentEnd() {
        let index = Self.index([0, 7, 0, 0, 13, 1, 0])
        let last = try? #require(index.entryRanges().last)
        #expect(last?.upperBound == index.documentLength)
    }

    // MARK: - P16: the merge-enablement road (the sweep's MAJOR)

    private static func world(_ lengths: [Int]) -> StructuralGesturePlanner.World {
        StructuralGesturePlanner.World(
            index: index(lengths),
            fanArities: Array(repeating: 1, count: lengths.count),
            sealed: false,
            textAt: { _ in "" })
    }

    /// **THE HOTTEST ROAD IN THE APP, MEASURED** (P16). Gesture enablement
    /// rides EVERY caret change and EVERY keystroke:
    /// `textViewDidChangeSelection` → `updateCaretContext` →
    /// `refreshGestureAvailability` → `enabled(.mergeBlocks)` →
    /// `StructuralGesturePlanner.plan(.mergeBlocks, …)` → `seamPair`, and
    /// `storageDidEdit` ends in `updateCaretContext` too. A caret anywhere
    /// but a block seam — which is essentially always — used to run the
    /// whole Σi walk to completion.
    ///
    /// Both shapes are under the clock: the ordinary in-block caret (which
    /// finds no seam) and a caret at the LAST seam of the document (the
    /// worst case for a walk that cannot exit early).
    @Test func theMergeEnablementRoadStaysCheapAtTwentyThousandBlocks() {
        let world = Self.world(Array(repeating: 40, count: 20_000))
        let clock = ContinuousClock()

        // An ordinary caret, mid-block, three quarters down the note.
        let midBlock = NSRange(location: 15_000 * 41 + 20, length: 0)
        var plan: StructuralGesturePlanner.Plan?
        let inBlock = clock.measure {
            plan = StructuralGesturePlanner.plan(.mergeBlocks, selection: midBlock, world: world)
        }
        #expect(plan == .refusal(.notASeam), "a mid-block caret is not a seam")
        #expect(inBlock < .milliseconds(50),
                "the Σi walk measured seconds here on its twin")

        // The document's LAST seam — the furthest an accumulating walk can
        // be pushed before it answers.
        let lastSeam = NSRange(location: 19_999 * 41 - 1, length: 0)
        var seamPlan: StructuralGesturePlanner.Plan?
        let atSeam = clock.measure {
            seamPlan = StructuralGesturePlanner.plan(.mergeBlocks, selection: lastSeam, world: world)
        }
        if case .merge(let leading, let trailing, _, _) = seamPlan {
            #expect(leading == 19_998 && trailing == 19_999)
        } else {
            Issue.record("the last seam did not plan a merge: \(String(describing: seamPlan))")
        }
        #expect(atSeam < .milliseconds(50))

        print("PERF[13u1] mergeEnablement @20k blocks — inBlock \(inBlock) · atSeam \(atSeam)")
    }

    /// The pure-seam gesture's sibling walk (`separatorPair`), reached ONLY
    /// by a selection of exactly one SEPARATOR character (a one-character
    /// selection inside a block shrinks to nothing and answers `.notASeam`
    /// three guards earlier — the first draft of this pin selected one of
    /// those and never reached the walk at all, which is the reason it read
    /// green on both trees and the reason it is written this way now).
    ///
    /// Not a keystroke road — but it had the identical Σi shape when it IS
    /// reached, and the sweep's rule is every caller or none. The LAST
    /// separator in the document is the worst case.
    @Test func theSeparatorSelectionRoadStaysCheapAtTwentyThousandBlocks() {
        let world = Self.world(Array(repeating: 40, count: 20_000))
        // The separator after entry 19,998 — the document's last.
        let lastSeparator = NSRange(location: 19_998 * 41 + 40, length: 1)
        let clock = ContinuousClock()
        var plan: StructuralGesturePlanner.Plan?
        let cost = clock.measure {
            plan = StructuralGesturePlanner.plan(
                .mergeBlocks, selection: lastSeparator, world: world)
        }
        if case .merge(let leading, let trailing, _, _) = plan {
            #expect(leading == 19_998 && trailing == 19_999,
                    "the pure-seam gesture names the separator's own pair")
        } else {
            Issue.record("the separator selection did not plan a merge: \(String(describing: plan))")
        }
        #expect(cost < .milliseconds(50))
        print("PERF[13u1] separatorPair @20k blocks — \(cost)")
    }

    // MARK: - The cross-block refusal's diagnosis (the same class, unnamed)

    /// `CrossBlockRefusal.cause` walks every entry asking the accessor — the
    /// same Σi shape, on the road a REFUSED cross-block keystroke takes (so
    /// it runs exactly when the author is already being told no, and a
    /// document-proportional stall there is the worst possible moment).
    @MainActor
    @Test func theCrossBlockRefusalDiagnosisStaysCheapAtTwentyThousandBlocks() {
        let index = Self.index(Array(repeating: 40, count: 20_000))
        let slots = (0..<20_000).map { slot("b\($0)", text: String(repeating: "x", count: 40)) }
        // A span from inside the last block into the open nothing past it —
        // reaches the walk with no early answer.
        let span = NSRange(location: 19_998 * 41 + 20, length: 45)
        let clock = ContinuousClock()
        var message = ""
        let cost = clock.measure {
            message = CrossBlockRefusal.message(range: span, index: index, slots: slots)
        }
        #expect(!message.isEmpty)
        #expect(cost < .milliseconds(50))
        print("PERF[13u1] crossBlockRefusal @20k blocks — \(cost)")
    }
}

// MARK: - The MOUNTED roads (the real editor, at scale)

@Suite("The editor seam's cost floor — mounted (13u1 UNIT 1)")
@MainActor
struct EditorSeamMountedCostTests {
    /// Eight thousand blocks: an order of magnitude past the author's own
    /// stated 100k-word bar (~1,400 paragraphs) and small enough that the
    /// harness's own TK2 mount is not the thing being measured. Pre-fix, a
    /// single pass of the class costs ~32M main-actor accessor steps here.
    private static let blockCount = 8_000

    private static func bigSlots(marking changed: Int? = nil) -> [Queries.RenderedBlock] {
        (0..<blockCount).map { i in
            slot("b\(i)", text: i == changed ? "changed paragraph body" : "paragraph body \(i % 10)")
        }
    }

    /// The tiling's own arithmetic, computed HERE rather than asked of the
    /// index — so this suite's fixtures stay independent of the very walk
    /// the fix introduces (and so the whole file compiles against the
    /// pre-fix tree for the red-on-old runs).
    private static func ranges(_ index: BlockRangeIndex) -> [NSRange] {
        var result: [NSRange] = []
        var location = 0
        for entry in index.entries {
            result.append(NSRange(location: location, length: entry.length))
            location += entry.length + 1
        }
        return result
    }

    /// **P17 — the differential projection apply.** It replaces only the
    /// changed slots, last-to-first, and asked the accessor once per slot
    /// with no accumulation: Σi ≈ N²/2 on a main-actor road a take switch, a
    /// `restoreCommit` and every sync landing take.
    ///
    /// (Its doc comment claimed *"Cost ∝ changed blocks, never the post"*.
    /// The accessor half is fixed here; the other half of that claim — the
    /// per-slot `viewText` comparison — is inherently O(the note's text) and
    /// the comment now says so instead of promising otherwise.)
    @Test func theDifferentialProjectionApplyStaysCheapAtEightThousandBlocks() async throws {
        try await withEditor { h in
            h.model.applyProjection(Self.bigSlots())
            #expect(h.model.index.entries.count == Self.blockCount)

            let clock = ContinuousClock()
            var cost = Duration.zero
            cost = clock.measure {
                h.model.applyProjection(Self.bigSlots(marking: Self.blockCount - 1))
            }
            #expect(h.model.index.entries.count == Self.blockCount)
            let lastRange = try #require(Self.ranges(h.model.index).last)
            #expect((h.textView.string as NSString).substring(with: lastRange)
                    == "changed paragraph body",
                    "the differential road actually ran")
            #expect(cost < .milliseconds(400),
                    "the Σi accessor walk is the document-proportional term")
            print("PERF[13u1] applyDifferential @\(Self.blockCount) blocks — \(cost)")
        }
    }

    /// **The KnownIssues row's own named site — carried to the road that
    /// replaced it.** The cross-block KEYSTROKE plan (`shouldChangeText`'s
    /// cross-block arm, after `verdict` answers `.crossesBlockBoundary`) used
    /// to ask the accessor once per entry over the WHOLE note plus four more
    /// times for the edges; its already-fixed sibling in the same family
    /// measured 23.8 s at 20,000 entries.
    ///
    /// *(13u1 UNIT 2 retired `planVisibleTakeEdit` into the ONE cross-block
    /// compound — same road, same keystroke, same question — so the pin
    /// moved with it rather than being deleted with the method. The
    /// compound's plan reads the tiling ONCE and its `surfaceText` closure
    /// at most TWICE, which is the stronger statement: cost ∝ the EDIT, not
    /// the note.)*
    @Test func theCrossBlockPlanStaysCheapAtEightThousandBlocks() async throws {
        try await withEditor { h in
            h.model.applyProjection(Self.bigSlots())
            let ranges = Self.ranges(h.model.index)
            // A real gesture, far down the note: mid-block 7,000 through
            // mid-block 7,001.
            let from = ranges[7_000].location + 5
            let to = ranges[7_001].location + 5
            let span = NSRange(location: from, length: to - from)

            let clock = ContinuousClock()
            var plan: EditorViewModel.CrossBlockEdit?
            let cost = clock.measure {
                plan = h.model.planCrossBlockEdit(range: span, replacement: "")
            }
            #expect(plan?.leading?.blockID == "b7000")
            #expect(plan?.trailing?.blockID == "b7001")
            #expect(plan?.deletedBlockIDs.isEmpty == true, "no whole block is covered")
            #expect(plan?.caretBlockID == "b7000")
            #expect(cost < .milliseconds(100))
            print("PERF[13u1] planCrossBlockEdit @\(Self.blockCount) blocks — \(cost)")
        }
    }

    /// The plan's GEOMETRY on a small, hand-checkable tiling, so a
    /// regression reads as an arithmetic error rather than a timing one.
    ///
    /// **And it is item 8's U-4 pin** (13u1 UNIT 2): the EMPTY block sitting
    /// between the two ends is INSIDE the span and is covered whole, so it
    /// rides `deleteBlock` with the rest. The retired planner collected by
    /// intersection, so a zero-length entry was invisible to it — the plan
    /// it built then tried to merge ACROSS the empty block and the
    /// operations layer refused (`blocksNotAdjacent`), which is exactly the
    /// backlog row *"an EMPTY block inside a span yields a plan that can
    /// never execute"*.
    @Test func theCrossBlockPlanTakesAnEmptyBlockInsideTheSpan() async throws {
        try await withEditor { h in
            h.model.applyProjection([
                slot("b0", text: "Alpha one."),     //  0..10, separator at 10
                slot("b1", text: ""),               // 11..11, separator at 11
                slot("b2", text: "Beta two."),      // 12..21, separator at 21
                slot("b3", text: "Gamma three."),   // 22..34
            ])
            let ranges = Self.ranges(h.model.index)
            #expect(ranges.map(\.location) == [0, 11, 12, 22])
            #expect(ranges.map(\.length) == [10, 0, 9, 12])

            // From "one." in b0 through "Beta " in b2.
            let plan = try #require(h.model.planCrossBlockEdit(
                range: NSRange(location: 6, length: 11), replacement: ""))
            #expect(plan.deletedBlockIDs == ["b1"], "the empty block is in the run, covered whole")
            #expect(plan.leading?.variantID == "v-b0")
            #expect(plan.leading?.newText == "Alpha ")
            #expect(plan.trailing?.variantID == "v-b2")
            #expect(plan.trailing?.newText == "two.")
            #expect(plan.caretBlockID == "b0")
            #expect(plan.caretOffset == 6)
            #expect(plan.joinsEnds, "both cuts sit mid-paragraph")
        }
    }
}
