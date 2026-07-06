//
//  AutosaveCoordinatorTests.swift
//  VariorumTests
//
//  Phase 7 Step 4: debounce coalescing (deterministic — the sleep is
//  injected, no wall clock), churn integration against the real core, and
//  the P2 off-main assertion for the runner every write flows through.
//

import Foundation
import GRDB
import Testing
import Dependencies
import VariorumCore
@testable import Variorum

/// A controllable sleep: suspended callers wake only on `advance()` (or
/// task cancellation — which is exactly what a re-scheduled debounce does).
final class ManualSleep: @unchecked Sendable {
    private let lock = NSLock()
    private var waiters: [(id: Int, continuation: CheckedContinuation<Void, Error>)] = []
    private var nextID = 0

    func sleep(_ duration: Duration) async throws {
        let id: Int = lock.withLock {
            nextID += 1
            return nextID
        }
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let cancelled = lock.withLock { () -> Bool in
                    if Task.isCancelled { return true }
                    waiters.append((id, continuation))
                    return false
                }
                if cancelled { continuation.resume(throwing: CancellationError()) }
            }
        } onCancel: {
            let cancelledWaiter = lock.withLock { () -> CheckedContinuation<Void, Error>? in
                guard let index = waiters.firstIndex(where: { $0.id == id }) else { return nil }
                return waiters.remove(at: index).continuation
            }
            cancelledWaiter?.resume(throwing: CancellationError())
        }
    }

    /// Wakes every currently suspended sleeper (the quiet gap elapsing).
    func advance() {
        let woken = lock.withLock {
            let all = waiters
            waiters.removeAll()
            return all
        }
        for waiter in woken { waiter.continuation.resume() }
    }

    var sleeperCount: Int { lock.withLock { waiters.count } }
}

@MainActor
@Suite("AutosaveCoordinator (Step 4)")
struct AutosaveCoordinatorTests {
    private func makeWorld() throws -> (AppDatabase, Operations, OperationsRunner) {
        let db = try AppDatabase.inMemory()
        let ops = Operations()
        return (db, ops, OperationsRunner(operations: ops))
    }

    @Test func aBurstCoalescesIntoOneAutosavePerQuietGap() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let ops = Operations()
            let runner = OperationsRunner(operations: ops)
            let post = try ops.createPost()
            let minted = try ops.newBlock(in: post.id, text: "")
            let sleeper = ManualSleep()
            let coordinator = AutosaveCoordinator(
                runner: runner, sleep: { try await sleeper.sleep($0) })

            // A typing burst: three edits, each re-arming the debounce.
            coordinator.record(variantID: minted.variant.id, text: "a", charDelta: 1)
            coordinator.record(variantID: minted.variant.id, text: "ab", charDelta: 1)
            coordinator.record(variantID: minted.variant.id, text: "abc", charDelta: 1)
            #expect(coordinator.isDirty)
            // Let the re-arm cancellations propagate, then end the quiet gap.
            for _ in 0..<200 {
                if sleeper.sleeperCount == 1 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(sleeper.sleeperCount == 1)   // exactly one armed debounce
            sleeper.advance()
            for _ in 0..<2000 {
                if !coordinator.isDirty { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(coordinator.flushCount == 1)  // ONE flush for the burst
            let text = try await db.read {
                try String.fetchOne(
                    $0, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.variant.id])
            }
            #expect(text == "abc")
            // The summed insert+delete cost reached churn intact.
            let churn = try await db.read {
                try Double.fetchOne(
                    $0, sql: "SELECT churn_accumulator FROM container WHERE id = ?",
                    arguments: [post.id])
            }
            // newBlock text was empty (baseline 0 → the first flush crosses
            // the threshold and resets) — so assert via the major-revision
            // stamp instead: 3 chars / max(0,1) ≥ 0.8 ⇒ stamped and reset.
            #expect(churn == 0)
            let stamp = try await db.read {
                try String.fetchOne(
                    $0, sql: "SELECT last_major_revision_at FROM container WHERE id = ?",
                    arguments: [post.id])
            }
            #expect(stamp != nil)
        }
    }

    @Test func churnAccumulatesBelowTheThresholdWithoutStamping() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let ops = Operations()
            let runner = OperationsRunner(operations: ops)
            let post = try ops.createPost()
            // A 100-char baseline, committed once so the baseline is real.
            let text = String(repeating: "x", count: 100)
            let minted = try ops.newBlock(in: post.id, text: text)
            _ = try ops.commit(minted.variant.id)   // stamps + rebaselines to 100
            let coordinator = AutosaveCoordinator(
                runner: runner, sleep: { _ in })    // immediate flushes
            coordinator.record(variantID: minted.variant.id, text: text + "y", charDelta: 1)
            await coordinator.flushNow()
            let churn = try await db.read {
                try Double.fetchOne(
                    $0, sql: "SELECT churn_accumulator FROM container WHERE id = ?",
                    arguments: [post.id])
            }
            #expect(churn == 1)   // 1/100 < 0.8: accumulated, not stamped
        }
    }

    @Test func operationErrorsSurfaceViaOnError() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let ops = Operations()
            let runner = OperationsRunner(operations: ops)
            let post = try ops.createPost()
            let minted = try ops.newBlock(in: post.id, text: "guarded")
            try ops.lockVariant(minted.variant.id)
            let coordinator = AutosaveCoordinator(runner: runner, sleep: { _ in })
            let seen = LockIsolated<Error?>(nil)
            coordinator.onError = { error in seen.setValue(error) }
            coordinator.record(variantID: minted.variant.id, text: "clobbered", charDelta: 9)
            await coordinator.flushNow()
            #expect(seen.value as? OperationError == .lockedVariant(id: minted.variant.id))

            // Review round 1, MAJOR 1: the refused entry is NOT dropped — it
            // stays pending, so the buffer remains authoritative (isDirty)
            // and the text survives to a later retry.
            #expect(coordinator.isDirty)
            #expect(coordinator.pending[minted.variant.id]?.text == "clobbered")

            // The user resolves (unlock) and the next flush lands the text.
            try ops.unlockVariant(minted.variant.id)
            await coordinator.flushNow()
            #expect(!coordinator.isDirty)
            let saved = try await db.read {
                try String.fetchOne(
                    $0, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.variant.id])
            }
            #expect(saved == "clobbered")
        }
    }

    @Test func oneRefusalNeverDropsASiblingsSave() async throws {
        // Review round 1, MAJOR 1 (secondary): variants save independently.
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let ops = Operations()
            let runner = OperationsRunner(operations: ops)
            let post = try ops.createPost()
            let locked = try ops.newBlock(in: post.id, text: "frozen")
            let free = try ops.newBlock(in: post.id, text: "free")
            try ops.lockVariant(locked.variant.id)

            let coordinator = AutosaveCoordinator(runner: runner, sleep: { _ in })
            coordinator.record(variantID: locked.variant.id, text: "frozen edit", charDelta: 5)
            coordinator.record(variantID: free.variant.id, text: "free edit", charDelta: 5)
            await coordinator.flushNow()

            let freeText = try await db.read {
                try String.fetchOne(
                    $0, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [free.variant.id])
            }
            #expect(freeText == "free edit")                       // sibling saved
            #expect(coordinator.pending[free.variant.id] == nil)   // and cleared
            #expect(coordinator.pending[locked.variant.id]?.text == "frozen edit")
        }
    }

    @Test func newerTypingSupersedesAFailedEntry() async throws {
        // Review round 1, MAJOR 1: if the user typed again while the failed
        // flush was in flight, the newer whole-buffer text wins and only the
        // churn cost merges.
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let ops = Operations()
            let runner = OperationsRunner(operations: ops)
            let post = try ops.createPost()
            let minted = try ops.newBlock(in: post.id, text: "guarded")
            try ops.lockVariant(minted.variant.id)
            let coordinator = AutosaveCoordinator(runner: runner, sleep: { _ in })
            coordinator.record(variantID: minted.variant.id, text: "old", charDelta: 3)
            // Simulate mid-flight typing by re-recording between flushes:
            // flush 1 fails and re-inserts; the fresher record must win.
            await coordinator.flushNow()
            coordinator.record(variantID: minted.variant.id, text: "old plus new", charDelta: 9)
            #expect(coordinator.pending[minted.variant.id]?.text == "old plus new")
            #expect(coordinator.pending[minted.variant.id]?.charDelta == 3 + 9)
        }
    }

    @Test func runnerWritesNeverRunOnTheMainThread() async throws {
        // P2: every operations-layer write the editor performs flows through
        // the runner, and the runner is off-main by construction.
        let (_, _, runner) = try makeWorld()
        let onMain = try await runner.run { _ in Thread.isMainThread }
        #expect(onMain == false)
    }
}
