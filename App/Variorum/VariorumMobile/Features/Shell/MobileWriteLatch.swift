//
//  MobileWriteLatch.swift
//  VariorumMobile
//
//  **ONE FLIGHT AT A TIME — the door-level latch, in ONE place.**
//
//  From the phone's cold architectural review (2026-08-30), MAJOR 1: four
//  phone models had hand-rolled this latch (`MobileStructural`'s
//  `structuralInFlight`, `MobileUndoDoor`'s `inFlight`, and the two that
//  read them), and twenty other files wrote through `session.runner.run`
//  with none. Their doors are SwiftUI `Button { Task { … } }`, which spawns
//  an INDEPENDENT unstructured task per tap, and a door's `.disabled` state
//  is typically a pure function of fields that do not change during the
//  flight — so the button stays hittable for the whole write and a second
//  tap inside the first's suspension runs the whole operation again.
//
//  ── WHAT THIS IS AND IS NOT ──────────────────────────────────────────────
//  It is a UI-turn latch, not a lock. `SerializedRunner` already guarantees
//  that two writes never interleave in the store; what it cannot know is
//  that the second write was never *asked for* — it is one gesture arriving
//  twice. That is a door's question, so the door answers it.
//
//  It is deliberately NOT the whole answer either. The review's own caution
//  bears repeating: **not every unlatched door is a bug.** A door whose
//  operation is idempotent is safe by the OPERATION's property — the Today
//  door's `createOrOpenJournalEntry` is create-*or-open* inside one
//  serialized write, so a second flight opens rather than mints — and a door
//  whose operation carries its own refusal (a live-unique index, an
//  `alreadyInReading` guard, `assertBookNameIsFree`) converges on one row
//  whatever the door does. Latching those changes nothing except that the
//  second tap stops producing a refusal message for a gesture the user
//  made once. Where a double flight MINTS A SECOND ROW, though, there is no
//  layer beneath the door to catch it, and this is that layer.
//
//  ── WHY A HELD OBJECT AND NOT A VIEW MODIFIER ────────────────────────────
//  The declining half has to be readable by the model that owns the door
//  (a refusal may want to speak, and a button may want to dim), and models
//  here are `@Observable` classes. A held latch is one stored property and
//  reads naturally in a body; a modifier would have to own state the model
//  cannot see.
//

import Foundation

/// A door's one-flight-at-a-time guard. Hold one per DOOR-GROUP (a model
/// whose writes are alternatives to each other), never one per app: two
/// unrelated doors must not block each other.
@MainActor
@Observable
final class MobileWriteLatch {
    /// True while a flight is in the air. A door may read it to dim itself;
    /// nothing is required to.
    private(set) var isBusy = false

    init() {}

    /// Runs `body` unless a flight is already in the air, in which case it
    /// returns `nil` without touching the store. The `defer` clears the
    /// latch on every road out, thrown errors included — a door that could
    /// wedge shut on a refusal would be worse than the duplicate.
    ///
    /// The result is optional so a caller can TELL the two outcomes apart:
    /// `nil` means "this gesture was already in flight", which is not a
    /// refusal and must never be reported as one.
    func run<T>(_ body: () async -> T) async -> T? {
        guard !isBusy else { return nil }
        isBusy = true
        defer { isBusy = false }
        return await body()
    }

    /// A void body's flight, said as a boolean: `true` when it ran.
    /// (`run` above returns `Void?` for such a body, which is correct but
    /// reads badly at a call site that only wants to know whether it fired.)
    @discardableResult
    func runIfFree(_ body: () async -> Void) async -> Bool {
        await run(body) != nil
    }
}
