//
//  AutosaveCoordinator.swift
//  Variorum
//
//  Debounced per-variant autosave through Operations.autosave (Phase 7
//  Step 4). The editor records each edit's latest block text + its full
//  insert+delete cost (AppSpec §10: replacements report both sides, UTF-16
//  units per the Phase 3 offset decision); a quiet gap flushes one autosave
//  per dirty variant. Writes run off the main thread through
//  OperationsRunner (P2). The schema's coalescing outbox absorbs whatever
//  rate this produces (S1) — the debounce exists for local write economy,
//  not for sync's sake.
//
//  While anything is pending or in flight the buffer is authoritative and
//  the view model suppresses observation-driven re-renders (the plan's
//  buffer-vs-observation loop rule).
//

import Foundation
import VariorumCore

@MainActor
final class AutosaveCoordinator {
    struct Pending: Equatable {
        var text: String
        var charDelta: Int
    }

    private let runner: OperationsRunner
    private let debounce: Duration
    /// Injectable for deterministic tests (the default is the real clock).
    private let sleep: @Sendable (Duration) async throws -> Void

    private(set) var pending: [String: Pending] = [:]
    private var flushTask: Task<Void, Never>?
    private var flushesInFlight = 0
    /// Non-empty flushes performed (observable coalescing, for tests).
    private(set) var flushCount = 0

    /// Surfaced refusals (a variant locked mid-flight, a sealed post, …) —
    /// the operations layer's error, rendered by the editor, never retried
    /// blindly. (Single-owner form — the mobile capture editor's; Mac
    /// surfaces share one coordinator per post and use `observe` instead.)
    var onError: (@MainActor (Error) -> Void)?
    /// Fires after every flush settles (clean or failed) — the view model's
    /// cue to apply a deferred projection. (Single-owner form; see above.)
    var onSettled: (@MainActor () -> Void)?

    /// 13f batch 5 (W22): fires ONCE per coordinator, at the first edit
    /// recorded for its post — whichever surface made it, because every
    /// editing surface on a post shares this one instance (the N3 boundary).
    /// The owner (`AppSession.autosave(forPost:)`) knows the post; this only
    /// knows that something was typed, which is all the trigger needs.
    var onFirstEdit: (@MainActor () -> Void)?
    private var firstEditFired = false

    // Phase 13b Stage 1a (N3): ONE coordinator per open post means SEVERAL
    // surfaces (Write editor, takes board, Write takes panel, block TOC)
    // listen at once — multicast observers beside the single-owner
    // closures (which the mobile target keeps using unchanged).
    private var errorObservers: [UUID: @MainActor (Error) -> Void] = [:]
    private var settledObservers: [UUID: @MainActor () -> Void] = [:]

    /// Registers a surface's callbacks; remove with `stopObserving` at the
    /// surface's teardown (a shared coordinator outlives any one surface).
    func observe(
        onError: (@MainActor (Error) -> Void)? = nil,
        onSettled: (@MainActor () -> Void)? = nil
    ) -> UUID {
        let token = UUID()
        if let onError { errorObservers[token] = onError }
        if let onSettled { settledObservers[token] = onSettled }
        return token
    }

    func stopObserving(_ token: UUID) {
        errorObservers[token] = nil
        settledObservers[token] = nil
    }

    private func notifyError(_ error: Error) {
        onError?(error)
        for observer in errorObservers.values { observer(error) }
    }

    private func notifySettled() {
        onSettled?()
        for observer in settledObservers.values { observer() }
    }

    /// True while any edit is unpersisted (pending or mid-write).
    var isDirty: Bool { !pending.isEmpty || flushesInFlight > 0 }

    init(
        runner: OperationsRunner,
        debounce: Duration = .milliseconds(500),
        sleep: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) {
        self.runner = runner
        self.debounce = debounce
        self.sleep = sleep
    }

    /// Records the latest text for a variant plus this edit's cost;
    /// keystroke bursts coalesce into the newest text and the summed cost.
    func record(variantID: String, text: String, charDelta: Int) {
        if !firstEditFired {
            firstEditFired = true
            onFirstEdit?()
        }
        var entry = pending[variantID] ?? Pending(text: "", charDelta: 0)
        entry.text = text
        entry.charDelta += charDelta
        pending[variantID] = entry
        schedule()
    }

    private func schedule() {
        flushTask?.cancel()
        flushTask = Task { [sleep, debounce] in
            guard (try? await sleep(debounce)) != nil else { return } // cancelled
            guard !Task.isCancelled else { return }
            await self.flushNow()
        }
    }

    /// Flushes everything pending immediately (commit and teardown call this
    /// before acting — the commit must snapshot exactly the buffer).
    ///
    /// Failure posture (review round 1, MAJOR 1): each variant saves
    /// INDEPENDENTLY — one refusal never drops a sibling's save — and a
    /// refused entry goes BACK into `pending`, so the typed text is never
    /// dropped and `isDirty` stays true, which keeps projections deferred:
    /// the surface remains authoritative and an older store state can never
    /// clobber it. There is no automatic retry loop — a refused entry
    /// retries on the next flush trigger (further typing, a commit,
    /// teardown); a permanent refusal (a seal or lock that landed remotely
    /// mid-typing) sits visibly behind `onError`'s message until the user
    /// acts. If newer typing superseded the failed entry meanwhile, the
    /// newer text wins (the text is always the whole buffer) and only the
    /// churn cost merges.
    func flushNow() async {
        flushTask?.cancel()
        flushTask = nil
        let batch = pending
        pending = [:]
        guard !batch.isEmpty else {
            notifySettled()
            return
        }
        flushesInFlight += 1
        flushCount += 1
        var firstError: Error?
        for (variantID, entry) in batch.sorted(by: { $0.key < $1.key }) {
            do {
                try await runner.run { ops in
                    try ops.autosave(variantID, text: entry.text, charDelta: entry.charDelta)
                }
            } catch {
                if var newer = pending[variantID] {
                    newer.charDelta += entry.charDelta
                    pending[variantID] = newer
                } else {
                    pending[variantID] = entry
                }
                if firstError == nil { firstError = error }
            }
        }
        if let firstError {
            notifyError(firstError)
        }
        flushesInFlight -= 1
        notifySettled()
    }
}
