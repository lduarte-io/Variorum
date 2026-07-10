import Dependencies
import Foundation
import GRDB

// S5's landing operation: a lost `working_text` race becomes a card in the
// fan, never a clobber (AppSpec §9, SyncSpec §6).
extension Operations {
    /// `resolveSyncConflict(variant, losingText)` — INSERT a new variant on
    /// the same block carrying the losing text: branched from the SAME
    /// parent as the conflicted variant, `label='conflict'`, at the fan's
    /// end. The conflicted variant itself is untouched (the server text won
    /// that row before this is called).
    ///
    /// Deliberately not guarded by the post seal or variant locks: S5's
    /// "nothing is ever clobbered" outranks the seal's refuse-everything —
    /// refusing here would throw the losing text away, which is the one
    /// outcome the sync design forbids. (PROVISIONAL — logged for the
    /// author; the alternative wedges sync on sealed posts.)
    ///
    /// `label` (Phase 9b): the Fragments bridge lands its rescued bodies
    /// through this same door labeled `'fragments'` — the S5 doctrine
    /// extended to the second writer (the 9b brief). Default unchanged.
    @discardableResult
    public func resolveSyncConflict(
        _ variantID: String, losingText: String, label: String = "conflict"
    ) throws -> Variant {
        try database.write { db in
            let conflicted = try liveVariant(db, variantID)
            // Align with the engine's rescue path (Merge.rescueLosingText):
            // a dead block's fan takes no new cards — a live variant under a
            // tombstoned block is a transitional sync state, and a live
            // conflict variant there would dangle (Phase 5 review). The
            // public operation refuses loudly where the engine skips
            // silently.
            _ = try liveBlock(db, conflicted.blockId)
            return try Operations.insertConflictVariant(
                db,
                blockID: conflicted.blockId,
                parentVariantID: conflicted.parentVariantId,
                losingText: losingText,
                label: label,
                id: newID(),
                now: date.now)
        }
    }

    /// The Fragments bridge's landing overwrite (Phase 9b review round 1,
    /// MAJOR 1) — ONE transaction composing the fifth-occasion insurance,
    /// the overwrite, and insurance OF THE LANDED BODY ITSELF:
    ///
    /// 1. auto-commit every dirty buffer under the entry (the pre-image —
    ///    including any edit that landed after the bridge's classification
    ///    read: composing in one transaction is what makes "insured before
    ///    the overwrite" structurally true; the `lockPost` precedent);
    /// 2. write `body` into the variant's buffer (churn per the
    ///    whole-buffer-replace convention);
    /// 3. append one `commit_point(kind:'auto')` of the landed body — the
    ///    landed text is Fragments-typed writing with no history surface of
    ///    its own, and WITHOUT this commit the open editor's keep-pending
    ///    flush (Phase 7) can overwrite it seconds later while the next
    ///    push LWW-replaces it on the Fragments side too: gone everywhere,
    ///    the forbidden outcome. An empty body (a landed deletion) takes no
    ///    commit — emptiness is not losable text, and step 1's pre-image
    ///    commit is the insurance that matters there.
    ///
    /// Refuses under a sealed post / locked variant exactly like `autosave`
    /// (the engine classifies those into the conflict-variant path first; a
    /// lock RACING the landing surfaces as a failed round and re-lands next
    /// round).
    @discardableResult
    public func applyBridgeLanding(
        _ variantID: String, in containerID: String, body: String
    ) throws -> Variant {
        try database.write { db in
            let container = try liveContainer(db, containerID)
            try ensureUnlocked(container)
            var variant = try liveVariant(db, variantID)
            guard variant.status != .archived else {
                throw OperationError.archivedVariant(id: variantID)
            }
            guard !variant.locked else {
                throw OperationError.lockedVariant(id: variantID)
            }
            let now = date.now
            _ = try autoCommitDirtyVariants(db, containerID: containerID, now: now)
            let oldText = variant.workingText
            guard oldText != body else { return variant }
            variant.workingText = body
            variant.updatedAt = now
            try variant.update(db)
            try registerTextChange(
                db, blockID: variant.blockId,
                charDelta: oldText.count + body.count,
                forceMajorRevision: false, now: now)
            if !body.isEmpty {
                _ = try insertCommit(db, variant: variant, kind: .auto, message: nil, now: now)
            }
            return variant
        }
    }

    /// The shared core: also called by the sync engine's merge path, which
    /// runs inside an apply transaction (outbox triggers muted) and
    /// therefore enqueues the new row explicitly, repair-style (SyncSpec §7).
    @discardableResult
    static func insertConflictVariant(
        _ db: Database,
        blockID: String,
        parentVariantID: String?,
        losingText: String,
        label: String = "conflict",
        id: String,
        now: Date
    ) throws -> Variant {
        let lastFanPosition = try String.fetchOne(
            db,
            sql: "SELECT MAX(fan_position) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
            arguments: [blockID])
        let variant = Variant(
            id: id,
            blockId: blockID,
            parentVariantId: parentVariantID,
            workingText: losingText,
            label: label,
            fanPosition: FractionalIndex.between(lastFanPosition, nil),
            createdAt: now,
            updatedAt: now)
        try variant.insert(db)
        return variant
    }
}
