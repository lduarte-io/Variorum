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
    /// blindly.
    var onError: (@MainActor (Error) -> Void)?
    /// Fires after every flush settles (clean or failed) — the view model's
    /// cue to apply a deferred projection.
    var onSettled: (@MainActor () -> Void)?

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
        var entry = pending[variantID] ?? Pending(text: "", charDelta: 0)
        entry.text = text
        entry.charDelta += charDelta
        pending[variantID] = entry
        schedule()
    }

    /// Drops a variant's pending edit without saving (used when a store
    /// re-render is about to overwrite the buffer anyway).
    func discard(variantID: String) {
        pending.removeValue(forKey: variantID)
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
    func flushNow() async {
        flushTask?.cancel()
        flushTask = nil
        let batch = pending
        pending = [:]
        guard !batch.isEmpty else {
            onSettled?()
            return
        }
        flushesInFlight += 1
        flushCount += 1
        do {
            try await runner.run { ops in
                for (variantID, entry) in batch.sorted(by: { $0.key < $1.key }) {
                    try ops.autosave(variantID, text: entry.text, charDelta: entry.charDelta)
                }
            }
        } catch {
            onError?(error)
        }
        flushesInFlight -= 1
        onSettled?()
    }
}
