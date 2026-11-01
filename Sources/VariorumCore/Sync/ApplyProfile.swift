import Foundation

/// VX-497 (VX-500 U1b, D-497 (1)) — THE APPLY PROFILE SEAM: where a measurement reads a pull round's phases from
/// inside the engine (`notes/plans/fixes/vx-500-sync-followups.md`, the U1b record). The `keyProvider` /
/// `SampleLibraryDedupeFacts` pattern — an injected, nil-by-default value on `SyncEngine.init`. **Nil — production,
/// every unwired engine — is INERT:** no clock is read, no closure is called (`ApplyProfileMarks` guards on it before
/// touching `ContinuousClock`). Only the gated bench (`ApplyProfileMeasurementTests`, `VARIORUM_APPLY_PROFILE=1`) ever
/// wires one. The engine REPORTS durations through it and never decides anything from them; the round's semantics
/// are byte-identical with or without a hook.
public struct ApplyProfileHook: Sendable {
    /// The phases of one pull round, in the order the engine runs them.
    public enum Phase: String, CaseIterable, Sendable {
        /// The window loop to head: each window fetched, opened (decrypted), encoded and staged.
        case download
        /// `PullStage.rows`: the staged JSON read back and decoded into the batch.
        case stageDecode
        /// Inside the apply: the one-writer belt (the cursor check + the stage's continuity).
        case belt
        /// Inside the apply: the straggler FIXPOINT — `foreignKeysSatisfiable` over the batch until the stop index
        /// settles (one `PRAGMA foreign_key_list` per row per pass; the `foreignKeyList` callback counts them).
        case fixpoint
        /// Inside the apply: the row loop — `isEnqueued`, then merge or `writeResolvedRow` (inline repairs included)
        /// and `recordSeq`, per row.
        case rowLoop
        /// Inside the apply: `runPostApplyRepairs`.
        case repairs
        /// Inside the apply: the save's last progress publish, the cursor write, the stage clear, a stall's naming.
        case commitPrep
        /// The whole apply as awaited — the hop onto the writer, BEGIN and the deferred-FK pragma, the five inner
        /// phases, the COMMIT (the WAL write, the deferred FK check) and the hop back. Minus the five inner phases it
        /// is the transaction's own overhead.
        case applyTransaction
    }

    /// One phase's measured duration, reported as the phase ends. Called on whatever thread ran the phase — the
    /// inner five on GRDB's writer queue — so a recorder must be thread-safe and quick.
    public var phase: @Sendable (Phase, Duration) -> Void
    /// One `PRAGMA foreign_key_list` read by the engine's FK introspection and how long it took — D-497's suspect:
    /// the introspection runs once per ROW of the fixpoint. The sum over a pull is exactly what a per-table memo
    /// would remove.
    public var foreignKeyList: @Sendable (Duration) -> Void

    public init(
        phase: @escaping @Sendable (Phase, Duration) -> Void,
        foreignKeyList: @escaping @Sendable (Duration) -> Void
    ) {
        self.phase = phase
        self.foreignKeyList = foreignKeyList
    }
}

/// The lap timer the engine threads through a round: `lap(_:)` reports the time since the previous lap (or the
/// marks' creation) under the phase that just ended. With no hook it is a no-op that reads no clock — the inert
/// default's whole cost is one optional check per lap.
struct ApplyProfileMarks {
    private let hook: ApplyProfileHook?
    private var last: ContinuousClock.Instant?

    init(_ hook: ApplyProfileHook?) {
        self.hook = hook
        self.last = hook == nil ? nil : ContinuousClock.now
    }

    mutating func lap(_ phase: ApplyProfileHook.Phase) {
        guard let hook, let last else { return }
        let now = ContinuousClock.now
        hook.phase(phase, now - last)
        self.last = now
    }
}
