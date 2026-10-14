//
//  JumpAndUndoTests.swift
//  VariorumTests
//
//  Phase 7 Step 7: the bounded hybrid jump's correction loop against a fake
//  geometry source, and the structural-undo serialization guard (two
//  concurrent undo() calls execute one at a time — the KnownIssues race
//  note, resolved by the runner).
//

import CoreGraphics
import Foundation
import Testing
import Dependencies
@testable import VariorumCore
@testable import Variorum

@MainActor
@Suite("Bounded hybrid jump loop (Step 7)")
struct JumpCorrectionLoopTests {
    @Test func stableGeometryConvergesInOneCorrection() {
        // The target fragment really sits at y=1000; the estimate said 400.
        let result = JumpCorrectionLoop.run(initialTop: 400, maxScroll: 5000) { _ in 1000 }
        #expect(result.converged)
        #expect(result.finalTop == 1000)
        #expect(result.iterations == 1)   // ≤1 correction, as the spike measured
    }

    @Test func exactEstimateNeedsNoCorrection() {
        let result = JumpCorrectionLoop.run(initialTop: 1000, maxScroll: 5000) { _ in 1000.4 }
        #expect(result.converged)
        #expect(result.iterations == 0)
    }

    @Test func shiftingEstimatesConvergeWithinTheCap() {
        // Height estimates revise as layout becomes real: the fragment's
        // reported minY moves a little each time we scroll.
        let calls = LockIsolated(0)
        let result = JumpCorrectionLoop.run(initialTop: 0, maxScroll: 10_000) { top in
            calls.withValue { $0 += 1 }
            return 2000 + max(0, 200 - abs(top - 2000)) * 0.1  // settles near 2000
        }
        #expect(result.converged)
        #expect(result.iterations <= 6)
    }

    @Test func aNonConvergingGeometryHitsTheCapInsteadOfSpinning() {
        let result = JumpCorrectionLoop.run(initialTop: 0, maxScroll: 10_000) { top in top + 50 }
        #expect(!result.converged)
        #expect(result.iterations == 6)   // the bounded in "bounded hybrid"
    }

    @Test func targetsBeyondMaxScrollClampAndStop() {
        // The fragment near the document end can't reach the viewport top.
        let result = JumpCorrectionLoop.run(initialTop: 0, maxScroll: 500) { _ in 1000 }
        #expect(result.converged)         // as close as geometry allows
        #expect(result.finalTop == 500)
    }

    @Test func missingGeometryBailsWhereItIs() {
        let result = JumpCorrectionLoop.run(initialTop: 300, maxScroll: 500) { _ in nil }
        #expect(!result.converged)
        #expect(result.finalTop == 300)
    }
}

/// Line resolution inside one layout fragment (13c 1A — A4). A Variorum
/// block is always its own paragraph, a paragraph is one TK2 layout
/// fragment, so a block taller than the viewport makes fragment-granularity
/// scroll anchoring collapse every position inside it to the block's first
/// line. These pin the two pure lookups both halves of the anchor use.
@Suite("Fragment line resolution (13c 1A — A4)")
struct FragmentLinesTests {
    /// Three 17 pt lines, fragment-local.
    private let bounds = [
        CGRect(x: 0, y: 0, width: 300, height: 17),
        CGRect(x: 0, y: 17, width: 300, height: 17),
        CGRect(x: 0, y: 34, width: 300, height: 17),
    ]

    @Test func aPointPicksTheLineItLandsIn() {
        #expect(FragmentLines.lineIndex(atLocalY: 0, lineBounds: bounds) == 0)
        #expect(FragmentLines.lineIndex(atLocalY: 16.9, lineBounds: bounds) == 0)
        #expect(FragmentLines.lineIndex(atLocalY: 17, lineBounds: bounds) == 1)
        #expect(FragmentLines.lineIndex(atLocalY: 40, lineBounds: bounds) == 2)
    }

    /// Above the first line ⇒ the first; below the last (the paragraph's
    /// own trailing gap is inside the fragment) ⇒ the last. Never nil for
    /// a laid-out fragment, so the anchor never silently falls back.
    @Test func pointsOutsideTheLinesClampToTheEnds() {
        #expect(FragmentLines.lineIndex(atLocalY: -40, lineBounds: bounds) == 0)
        #expect(FragmentLines.lineIndex(atLocalY: 900, lineBounds: bounds) == 2)
    }

    @Test func anUnlaidFragmentResolvesToNoLine() {
        #expect(FragmentLines.lineIndex(atLocalY: 10, lineBounds: []) == nil)
        #expect(FragmentLines.lineIndex(atLocalOffset: 10, lineRanges: []) == nil)
    }

    @Test func anOffsetPicksTheLineThatContainsIt() {
        let ranges = [NSRange(location: 0, length: 74),
                      NSRange(location: 74, length: 77),
                      NSRange(location: 151, length: 60)]
        #expect(FragmentLines.lineIndex(atLocalOffset: 0, lineRanges: ranges) == 0)
        #expect(FragmentLines.lineIndex(atLocalOffset: 73, lineRanges: ranges) == 0)
        #expect(FragmentLines.lineIndex(atLocalOffset: 74, lineRanges: ranges) == 1)
        #expect(FragmentLines.lineIndex(atLocalOffset: 200, lineRanges: ranges) == 2)
        #expect(FragmentLines.lineIndex(atLocalOffset: 9_999, lineRanges: ranges) == 2)
    }

    /// 18k C6b (W-4, QUESTIONS #147 PROVISIONAL): the line she is READING is
    /// the first whose baseline is at or below the edge — Terminal's
    /// measured baselines, 14 pt into each 17-pt line. A line cut above its
    /// baseline is still hers; cut below it (descenders only), the next line
    /// is; below every baseline (the paragraph's trailing spacing), none here.
    @Test func theReadingLineIsTheFirstWhoseBaselineIsStillOnScreen() {
        let baselines: [CGFloat] = [14, 31, 48]
        #expect(FragmentLines.readingLineIndex(atLocalY: 0, baselines: baselines) == 0)
        #expect(FragmentLines.readingLineIndex(atLocalY: 14, baselines: baselines) == 0)
        #expect(FragmentLines.readingLineIndex(atLocalY: 15, baselines: baselines) == 1)
        #expect(FragmentLines.readingLineIndex(atLocalY: 47.5, baselines: baselines) == 2)
        #expect(FragmentLines.readingLineIndex(atLocalY: 49, baselines: baselines) == nil)
        #expect(FragmentLines.readingLineIndex(atLocalY: 5, baselines: []) == nil)
    }
}

@MainActor
@Suite("Structural undo wiring (Step 7)")
struct StructuralUndoTests {
    @Test func concurrentUndosExecuteOneAtATime() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: {
            let undoStack = UndoStack()
            let ops = Operations(undoStack: undoStack)
            let runner = OperationsRunner(operations: ops)

            let active = LockIsolated(0)
            let maxActive = LockIsolated(0)
            for label in ["one", "two"] {
                undoStack.register(
                    label: label,
                    inverse: { _ in
                        active.withValue { $0 += 1 }
                        maxActive.withValue { $0 = max($0, active.value) }
                        Thread.sleep(forTimeInterval: 0.03)   // widen any overlap window
                        active.withValue { $0 -= 1 }
                        // JUSTIFIED EDIT (VX-246 U2): a half now answers
                        // whether it changed anything — this toy stands for an
                        // inverse that did; the serialization it pins is
                        // untouched.
                        return true
                    },
                    // 13c 1B: the serialization test cares only about the
                    // inverse; a synthetic entry with no re-apply is exactly
                    // the `redo: nil` case the signature makes explicit.
                    redo: nil)
            }

            async let first = runner.run { operations in try undoStack.undo(with: operations) }
            async let second = runner.run { operations in try undoStack.undo(with: operations) }
            let labels = try await [first, second]
            #expect(maxActive.value == 1)                    // strictly serial
            #expect(Set(labels.compactMap { $0 }) == ["one", "two"]) // each ran once
            #expect(undoStack.depth == 0)
        }
    }

    @Test func undoEmitsOrdinaryOperationsThroughTheRunner() async throws {
        // A real structural inverse: reorder registers its pre-image; undo
        // through the runner restores the exact prior position.
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: {
            let undoStack = UndoStack()
            let ops = Operations(undoStack: undoStack)
            let runner = OperationsRunner(operations: ops)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "a")
            _ = try ops.newBlock(in: post.id, text: "b")

            try ops.reorder(a.block.id, to: .end)
            let reordered = try await db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(reordered.map(\.text) == ["b", "a"])

            let label = try await runner.run { operations in
                try undoStack.undo(with: operations)
            }
            #expect(label == "Reorder")
            let restored = try await db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(restored.map(\.text) == ["a", "b"])
        }
    }
}
