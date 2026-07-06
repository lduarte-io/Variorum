import Dependencies
import Foundation
import GRDB

// The variant lifecycle: the one mutable buffer, its append-only commits, and
// fan growth. Text-changing ops (autosave, commit, restoreCommit) also feed
// the owning container's touch/churn stamps (AppSpec §10) via
// `registerTextChange` — a pool block's edits update the pool's stamps the
// same way.
extension Operations {
    // MARK: - The mutable buffer

    /// Continuous autosave: updates the working buffer and accumulates churn
    /// on the owning container. `charDelta` is the editor-reported signed
    /// character delta for this edit.
    public func autosave(_ variantID: String, text: String, charDelta: Int) throws {
        try database.write { db in
            var variant = try editableVariant(db, variantID)
            let now = date.now
            variant.workingText = text
            variant.updatedAt = now
            try variant.update(db)
            try registerTextChange(
                db, blockID: variant.blockId, charDelta: charDelta,
                forceMajorRevision: false, now: now)
        }
    }

    // MARK: - Commits (append-only, I5)

    /// Appends an immutable savepoint of the variant's current buffer.
    /// A *manual* commit counts as a major revision (AppSpec §10); auto
    /// commits are quiet insurance and never reshuffle the library.
    /// Archived variants may commit (author-ratified 2026-07-05): commit
    /// reads the buffer without editing it, and restoring the take means
    /// unarchiving it first anyway — the snapshot is pure upside.
    @discardableResult
    public func commit(
        _ variantID: String, kind: CommitKind = .manual, message: String? = nil
    ) throws -> CommitPoint {
        try database.write { db in
            let variant = try liveVariant(db, variantID)
            // Post lock forbids new commits; a locked variant refuses too
            // (plan default — its buffer is frozen, nothing new to save).
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            guard !variant.locked else {
                throw OperationError.lockedVariant(id: variantID)
            }
            let now = date.now
            let commitPoint = try insertCommit(db, variant: variant, kind: kind, message: message, now: now)
            if kind == .manual {
                try registerTextChange(
                    db, blockID: variant.blockId, charDelta: 0,
                    forceMajorRevision: true, now: now)
            }
            return commitPoint
        }
    }

    /// Loads a commit's text back into the working buffer. Old commits
    /// remain — committing again appends, never truncates (I5). Note the
    /// documented restores-pre-split-text behavior (AppSpec §9): after Phase
    /// 3's divide/extract, a commit predating the split still holds the full
    /// pre-split text and restoring it resurrects both halves into this
    /// buffer — coherent under "coarse, not forensic"; the editor warns.
    public func restoreCommit(_ variantID: String, commitID: String) throws {
        try database.write { db in
            var variant = try editableVariant(db, variantID)
            guard let commitPoint = try CommitPoint.fetchOne(db, key: commitID),
                  commitPoint.variantId == variantID
            else { throw OperationError.commitNotFound(id: commitID) }

            let oldText = variant.workingText
            guard oldText != commitPoint.text else { return }
            let now = date.now
            variant.workingText = commitPoint.text
            variant.updatedAt = now
            try variant.update(db)
            // A restore replaces the whole buffer: churn = delete-all +
            // insert-all, equal weight. Approximate by design.
            try registerTextChange(
                db, blockID: variant.blockId, charDelta: oldText.count + commitPoint.text.count,
                forceMajorRevision: false, now: now)
        }
    }

    /// One `kind='auto'` commit per dirty live variant under the container —
    /// the long-idle insurance (author-approved). "Dirty" = the buffer
    /// differs from the variant's latest commit, or has never been committed
    /// and is non-empty. Idempotent: a second call finds nothing dirty. Idle
    /// *detection* (the 24h clock) is the caller's job at the app phase.
    /// Locked variants are skipped (lockVariant already insured them); a
    /// locked post refuses — lock forbids new commits. Pools are accepted
    /// deliberately (the spec names posts as the case that matters, but a
    /// pool scrap's buffer deserves the same insurance).
    @discardableResult
    public func idleAutoCommit(_ containerID: String) throws -> [CommitPoint] {
        try database.write { db in
            let container = try liveContainer(db, containerID)
            try ensureUnlocked(container)
            return try autoCommitDirtyVariants(db, containerID: containerID, now: date.now)
        }
    }

    /// Shared by `idleAutoCommit` and `lockPost` (which seals only after
    /// insuring its dirty buffers).
    func autoCommitDirtyVariants(
        _ db: Database, containerID: String, now: Date
    ) throws -> [CommitPoint] {
        let variants = try Variant.fetchAll(
            db,
            sql: """
                SELECT v.* FROM variant v
                JOIN container_block cb
                  ON cb.block_id = v.block_id
                 AND cb.container_id = ?
                 AND cb.deleted_at IS NULL
                WHERE v.deleted_at IS NULL AND v.locked = 0
                ORDER BY v.id
                """,
            arguments: [containerID])

        var committed: [CommitPoint] = []
        for variant in variants {
            guard try isDirty(db, variant) else { continue }
            committed.append(
                try insertCommit(db, variant: variant, kind: .auto, message: nil, now: now))
        }
        return committed
    }

    // MARK: - Fan growth

    /// The default gesture: a new variant inheriting the source's buffer,
    /// branched from it, placed immediately after it in the fan (the spec's
    /// "fan_position=next" — a branch appears beside its source, not at the
    /// fan's end; decided per plan risk note and tested).
    @discardableResult
    public func branchVariant(_ blockID: String, from sourceVariantID: String) throws -> Variant {
        try insertFanVariant(blockID: blockID) { db in
            let source = try liveVariant(db, sourceVariantID)
            guard source.blockId == blockID else {
                throw OperationError.variantNotFound(id: sourceVariantID)
            }
            let next = try String.fetchOne(
                db,
                sql: """
                    SELECT MIN(fan_position) FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL AND fan_position > ?
                    """,
                arguments: [blockID, source.fanPosition])
            return (
                text: source.workingText,
                parent: source.id,
                fanPosition: FractionalIndex.between(source.fanPosition, next)
            )
        }
    }

    /// The "genuinely different take" gesture: an empty, parentless variant
    /// at the fan's end.
    @discardableResult
    public func newBlankVariant(_ blockID: String) throws -> Variant {
        try insertFanVariant(blockID: blockID) { db in
            let last = try String.fetchOne(
                db,
                sql: "SELECT MAX(fan_position) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                arguments: [blockID])
            return (text: "", parent: nil, fanPosition: FractionalIndex.between(last, nil))
        }
    }

    // MARK: - Shared internals

    /// A variant whose buffer may be edited right now: live, active,
    /// unlocked, and not under a locked post. (Archived variants live in
    /// history — an edit reaching one signals a caller bug, so it refuses.)
    private func editableVariant(_ db: Database, _ id: String) throws -> Variant {
        let variant = try liveVariant(db, id)
        guard variant.status != .archived else {
            throw OperationError.archivedVariant(id: id)
        }
        guard !variant.locked else {
            throw OperationError.lockedVariant(id: id)
        }
        try ensurePlacementUnlocked(db, blockID: variant.blockId)
        return variant
    }

    func insertCommit(
        _ db: Database, variant: Variant, kind: CommitKind, message: String?, now: Date
    ) throws -> CommitPoint {
        let commitPoint = CommitPoint(
            id: newID(), variantId: variant.id, text: variant.workingText,
            kind: kind, message: message, createdAt: now)
        try commitPoint.insert(db)
        return commitPoint
    }

    func isDirty(_ db: Database, _ variant: Variant) throws -> Bool {
        let lastCommitText = try String.fetchOne(
            db,
            sql: """
                SELECT text FROM commit_point WHERE variant_id = ?
                ORDER BY created_at DESC, id DESC LIMIT 1
                """,
            arguments: [variant.id])
        guard let lastCommitText else { return !variant.workingText.isEmpty }
        return variant.workingText != lastCommitText
    }

    private func insertFanVariant(
        blockID: String,
        _ makeSpec: (Database) throws -> (text: String, parent: String?, fanPosition: String)
    ) throws -> Variant {
        try database.write { db in
            _ = try liveBlock(db, blockID)
            // The post-level seal freezes everything under the post,
            // including fan growth (interpretation flagged at closeout).
            try ensurePlacementUnlocked(db, blockID: blockID)
            let spec = try makeSpec(db)
            let now = date.now
            let variant = Variant(
                id: newID(), blockId: blockID, parentVariantId: spec.parent,
                workingText: spec.text, fanPosition: spec.fanPosition,
                createdAt: now, updatedAt: now)
            try variant.insert(db)
            return variant
        }
    }

    // MARK: - Touch & churn (AppSpec §10)

    /// The one door through which text changes reach the owning container's
    /// sort stamps. Unplaced blocks (lineage leftovers) have no container to
    /// stamp and skip quietly. `forceMajorRevision` is the manual-commit
    /// path; otherwise churn accumulates and the threshold decides.
    func registerTextChange(
        _ db: Database, blockID: String, charDelta: Int, forceMajorRevision: Bool, now: Date
    ) throws {
        guard let placement = try livePlacement(db, blockID: blockID) else { return }
        var container = try liveContainer(db, placement.containerId)
        container.lastTouchedAt = now
        var crossed = forceMajorRevision
        if !forceMajorRevision {
            let outcome = Churn.accumulate(
                accumulator: container.churnAccumulator,
                baselineLength: container.baselineLength,
                charDelta: charDelta,
                threshold: try majorRevisionThreshold(db))
            container.churnAccumulator = outcome.accumulator
            crossed = outcome.didCrossThreshold
        } else {
            container.churnAccumulator = 0
        }
        if crossed {
            container.lastMajorRevisionAt = now
            container.baselineLength = try renderedLength(db, containerID: container.id)
        }
        container.updatedAt = now
        try container.update(db)
    }

    /// Structural work counts as touching the post (author decision
    /// 2026-07-06): `last_touched_at` stamps, churn stays untouched —
    /// restructuring must never reshuffle the library's meaningful sort.
    /// Used by the structural ops that copy rather than edit text
    /// (divide-W, merge, poolDragCopy); extract and single divide stamp
    /// through `registerTextChange` since they also churn.
    func touchContainer(_ db: Database, _ containerID: String, now: Date) throws {
        let stamp = DateFormatter.variorumISO8601.string(from: now)
        try db.execute(
            sql: "UPDATE container SET last_touched_at = ?, updated_at = ? WHERE id = ?",
            arguments: [stamp, stamp, containerID])
    }

    /// The container's current rendered length: per live placement, the
    /// chosen variant's buffer (falling back to the block default when the
    /// choice is NULL, tombstoned, or archived — the read-time rule). Runs
    /// only on threshold crossings, never per keystroke.
    ///
    /// Approximate by design — this feeds the churn *counters* (SyncSpec §6
    /// class), so it deliberately diverges from `Queries.renderPost` in two
    /// documented, harmless ways (Phase 4 review): the subselects don't gate
    /// on block liveness, so the doubly-raced live-placement-over-dead-block
    /// state counts text the render gaps; and the `"\n\n"` separators
    /// `renderedText` re-creates aren't counted. Drift here only nudges the
    /// 80% threshold's baseline, never a rendered view.
    private func renderedLength(_ db: Database, containerID: String) throws -> Int {
        try Int.fetchOne(
            db,
            sql: """
                SELECT COALESCE(SUM(LENGTH(COALESCE(
                    (SELECT v.working_text FROM variant v
                     WHERE v.id = cb.chosen_variant_id AND v.block_id = cb.block_id
                       AND v.deleted_at IS NULL AND v.status = 'active'),
                    (SELECT v.working_text FROM variant v
                     JOIN block b ON b.default_variant_id = v.id
                     WHERE b.id = cb.block_id AND v.deleted_at IS NULL),
                    ''
                ))), 0)
                FROM container_block cb
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                """,
            arguments: [containerID]) ?? 0
    }
}
