import Foundation
import GRDB

// The idle auto-commit sweep's read side (Phase 8, Step 5 — resolves the
// KnownIssues "Idle auto-commit scheduling" entry). AppSpec §9 assigns idle
// DETECTION (the `idle_commit_hours` clock) to the app; the app's scheduler
// asks these questions and `Operations.idleAutoCommit` answers per
// container (idempotent, at most one auto commit per dirty variant).
extension Queries {
    /// The `idle_commit_hours` setting.
    ///
    /// **Default 2, not 24** (Phase 13j, J11 — her cadence ruling). The
    /// fallback matches `seedV1Settings` deliberately: a store with no row at
    /// all must read the same backstop a seeded one does, or "unset" and
    /// "default" would mean two different things (the `defaultSegmentation`
    /// precedent, stated for the same reason).
    public static func idleCommitHours(_ db: Database) throws -> Double {
        try String.fetchOne(
            db, sql: "SELECT value FROM setting WHERE key = 'idle_commit_hours'")
            .flatMap(Double.init) ?? 2
    }

    /// **The savepoint cadence** (Phase 13j, J11): which of the two CADENCE
    /// occasions write — leaving a note, and the long-idle backstop. Absent
    /// or unrecognized reads as her default, `.everySession`, which is what
    /// makes the setting safe to add without seeding every existing store.
    ///
    /// Both `Operations.closeAutoCommit` and `Operations.idleAutoCommit` read
    /// this INSIDE their own write transaction, so the rule holds whichever
    /// caller asks — never per-call-site gating that a new door could miss.
    public static func savepointCadence(_ db: Database) throws -> SavepointCadence {
        try String
            .fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'savepoint_cadence'")
            .flatMap(SavepointCadence.init(rawValue:)) ?? .everySession
    }

    /// Containers plausibly owed a long-idle auto commit: live, unsealed,
    /// last touched inside the sweep window `(afterMark, cutoff]` (idle
    /// since `cutoff`; already insured up to `afterMark` by a previous
    /// sweep), carrying at least one live, unlocked variant whose buffer
    /// changed after its last commit.
    ///
    /// This is a cheap CANDIDATE filter, not the commit decision —
    /// `Operations.idleAutoCommit` re-checks true dirtiness (buffer vs last
    /// commit TEXT) per variant; a false positive costs one no-op
    /// transaction, never a wrong commit.
    ///
    /// **Cost shape (P1):** the window rides `idx_container_touched`
    /// (`(last_touched_at, id) WHERE deleted_at IS NULL`), so a sweep costs
    /// ∝ containers edited since the previous sweep — never the corpus.
    ///
    /// **Coverage (Phase 9 — QUESTIONS #5 resolved by the author, option
    /// (a)):** `newBlock` stamps `last_touched_at` since Phase 9, so every
    /// mint (one-burst entries, idle-/teardown-minted tails, mints into
    /// long-swept posts) re-enters the touch window like any other edit —
    /// Phase 8's two documented residual gaps are CLOSED, pinned by
    /// `aMintIntoAPreviouslyTouchedAndSweptPostIsNowInsured` (the flipped
    /// documented-gap test, red on the pre-Phase-9 op). The second branch
    /// (never-touched containers windowed by `created_at`) is retained as
    /// the net for stamp-less rows that genuinely exist: containers whose
    /// mints were written by pre-Phase-9 builds.
    public static func idleCommitCandidates(
        _ db: Database, afterMark: String, cutoff: String
    ) throws -> [String] {
        let dirtyVariantExists = """
            EXISTS (
                SELECT 1 FROM container_block cb
                JOIN variant v
                  ON v.block_id = cb.block_id
                 AND v.deleted_at IS NULL
                 AND v.locked = 0
                WHERE cb.container_id = c.id AND cb.deleted_at IS NULL
                  AND (v.working_text <> ''
                       OR EXISTS (SELECT 1 FROM commit_point cp2 WHERE cp2.variant_id = v.id))
                  AND COALESCE((SELECT MAX(cp.created_at) FROM commit_point cp
                                WHERE cp.variant_id = v.id), '') < v.updated_at
            )
            """
        return try String.fetchAll(
            db,
            sql: """
                SELECT c.id FROM container c
                WHERE c.deleted_at IS NULL AND c.locked = 0
                  AND c.last_touched_at > ? AND c.last_touched_at <= ?
                  AND \(dirtyVariantExists)
                UNION
                SELECT c.id FROM container c
                WHERE c.deleted_at IS NULL AND c.locked = 0
                  AND c.last_touched_at IS NULL
                  AND c.created_at > ? AND c.created_at <= ?
                  AND \(dirtyVariantExists)
                ORDER BY 1
                """,
            arguments: [afterMark, cutoff, afterMark, cutoff])
    }
}
