//
//  JumpAndUndoTests.swift
//  VariorumTests
//
//  Phase 7 Step 7: the bounded hybrid jump's correction loop against a fake
//  geometry source, and the structural-undo serialization guard (two
//  concurrent undo() calls execute one at a time — the KnownIssues race
//  note, resolved by the runner).
//

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
                undoStack.register(label: label) { _ in
                    active.withValue { $0 += 1 }
                    maxActive.withValue { $0 = max($0, active.value) }
                    Thread.sleep(forTimeInterval: 0.03)   // widen any overlap window
                    active.withValue { $0 -= 1 }
                }
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
