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
        /// **VX-683 B — the text this pending run was BUILT ON**: what the
        /// surface showed for the take right before the run's FIRST edit (its
        /// last-adopted snapshot, or its own text a write already landed),
        /// captured once and kept while later keystrokes coalesce. It rides the
        /// write as `Operations.autosave`'s `expectedText`, so a row changed
        /// under the run since (a sync pull in the debounce window, the MCP
        /// door, a second window) is RESCUED, never blind-written. nil = the
        /// caller gave none (the unguarded write).
        var expectedText: String? = nil
    }

    private let runner: OperationsRunner
    private let debounce: Duration
    /// Injectable for deterministic tests (the default is the real clock).
    private let sleep: @Sendable (Duration) async throws -> Void

    private(set) var pending: [String: Pending] = [:]
    private var flushTask: Task<Void, Never>?
    /// VX-402: true while ONE flush's batch is being written. Writes are
    /// serialized — at most one batch is in flight — and every other flush
    /// waits here for it (`flushNow`).
    private var writing = false
    private var writeWaiters: [CheckedContinuation<Void, Never>] = []
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
    var isDirty: Bool { !pending.isEmpty || writing }

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
    ///
    /// `basedOn` (VX-683 B): the text the surface held for this take right
    /// BEFORE this edit — what the edit was built on. Only the FIRST edit of a
    /// pending run sets the run's snapshot (`Pending.expectedText`); the
    /// coalesced keystrokes after it were built on her own pending text, not
    /// on the store. Every production surface passes it; nil = unguarded.
    func record(variantID: String, text: String, charDelta: Int, basedOn: String? = nil) {
        if !firstEditFired {
            firstEditFired = true
            onFirstEdit?()
        }
        var entry = pending[variantID] ?? Pending(text: "", charDelta: 0, expectedText: basedOn)
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
    ///
    /// **VX-402 — THE HONEST FLUSH: it returns only once every write already
    /// in flight has landed** (the vx-382 ladder's R1-3, ticketed then; the
    /// helper class under every flush-first door — `flushExistingAutosave`,
    /// the copy family, the leaving savepoint, the book's Takes sheet, Write's
    /// open-in-Write, Copy for AI, the note deletions, the block history, and
    /// the sync round's flush-before-apply, VX-683). A flush used to take the
    /// batch and clear `pending` BEFORE awaiting its writes, so a second flush
    /// arriving meanwhile found nothing pending and returned at once: the door
    /// then read the store before her last keystrokes landed, and
    /// `flushExistingAutosave` answered `false` — an answer its callers
    /// discard. Now the batch is written under ONE serial lock: a flush first
    /// waits for the write in flight, THEN takes everything pending at that
    /// moment (what she typed meanwhile included). The same lock closes the
    /// order hole beside it (found tracing this): a two-take batch writes one
    /// runner turn at a time, so a flush started between its turns used to
    /// write its NEWER text for the second take first, and the older batch's
    /// text then landed on top. Writes now land in the order they were
    /// recorded. Pinned: `AutosaveCoordinatorTests` (the VX-402 section).
    ///
    /// The wait is bounded by the one batch in flight (milliseconds of store
    /// writes); a refused entry it puts back is NOT retried by the waiter —
    /// the keep-pending posture above stands, and the door reads `isDirty`.
    func flushNow() async {
        flushTask?.cancel()
        flushTask = nil
        while writing {
            await withCheckedContinuation { writeWaiters.append($0) }
        }
        let batch = pending
        pending = [:]
        guard !batch.isEmpty else {
            notifySettled()
            return
        }
        writing = true
        flushCount += 1
        var firstError: Error?
        for (variantID, entry) in batch.sorted(by: { $0.key < $1.key }) {
            do {
                try await runner.run { ops in
                    try ops.autosave(
                        variantID, text: entry.text, charDelta: entry.charDelta,
                        expectedText: entry.expectedText)
                }
            } catch {
                if var newer = pending[variantID] {
                    newer.charDelta += entry.charDelta
                    // VX-683 B: the refused text never landed, so the newer
                    // run (built on it) still stands on the OLDER snapshot —
                    // carrying its own would read the untouched row as
                    // changed and mint a spurious card on the retry.
                    newer.expectedText = entry.expectedText
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
        writing = false
        // Every waiter re-checks the lock when it runs; the first to run takes
        // it before the others can (main-actor turns never interleave).
        let waiters = writeWaiters
        writeWaiters.removeAll()
        for waiter in waiters { waiter.resume() }
        notifySettled()
    }
}
