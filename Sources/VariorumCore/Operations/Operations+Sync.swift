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
    @discardableResult
    public func resolveSyncConflict(_ variantID: String, losingText: String) throws -> Variant {
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
                id: newID(),
                now: date.now)
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
