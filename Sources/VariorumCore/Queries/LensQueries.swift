import Foundation
import GRDB

// Lens read side (Phase 11, Step A1 — v1_7). A lens is a VIEW-side
// projection: these traversals overlay sparse overrides onto the ordinary
// slot resolution and never touch rendering truth. Exports, the bridge,
// and the book view keep reading `renderPost`/`renderedText` — a lens
// changes what a lens-bound COLUMN shows, nothing else.
extension Queries {
    /// The post's live lenses, stable order (creation, id tiebreak).
    public static func lenses(_ db: Database, post containerID: String) throws -> [Lens] {
        try Lens
            .filter(Column("container_id") == containerID && Column("deleted_at") == nil)
            .order(Column("created_at"), Column("id"))
            .fetchAll(db)
    }

    /// A lens by key, live-only (tolerant: nil when missing/tombstoned).
    public static func lens(_ db: Database, id: String) throws -> Lens? {
        guard let lens = try Lens.fetchOne(db, key: id), lens.deletedAt == nil else {
            return nil
        }
        return lens
    }

    /// The lens's live overrides, RAW (block → variant), no validity
    /// filtering — the editing surface needs to know what the lens says
    /// even when a pick dangles.
    public static func lensChoices(_ db: Database, lens lensID: String) throws -> [String: String] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT block_id, variant_id FROM lens_choice
                WHERE lens_id = ? AND deleted_at IS NULL
                """,
            arguments: [lensID])
        return Dictionary(
            uniqueKeysWithValues: rows.map { ($0["block_id"], $0["variant_id"]) })
    }

    /// The lens's EFFECTIVE overrides: picks whose variant is live, active,
    /// and on the picked block. A dangling pick (variant tombstoned or
    /// archived since, or a foreign block's variant arriving through a sync
    /// race) is DROPPED — the slot falls through to the post's ordinary
    /// chosen/default resolution (the AppSpec §7 fallback class; the spike
    /// record's letter).
    public static func effectiveLensSelection(
        _ db: Database, lens lensID: String
    ) throws -> [String: String] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT lc.block_id AS block_id, lc.variant_id AS variant_id
                FROM lens_choice lc
                JOIN variant v
                  ON v.id = lc.variant_id
                 AND v.block_id = lc.block_id
                 AND v.deleted_at IS NULL
                 AND v.status = 'active'
                WHERE lc.lens_id = ? AND lc.deleted_at IS NULL
                """,
            arguments: [lensID])
        return Dictionary(
            uniqueKeysWithValues: rows.map { ($0["block_id"], $0["variant_id"]) })
    }

    /// `renderPost` seen THROUGH a lens: slots with an effective override
    /// render that take's text; un-overridden slots (and every slot when
    /// `lensID` is nil) render exactly as `renderPost` does — the sparse-
    /// override composition. Cost ∝ the post's own size (P1).
    public static func renderPost(
        _ db: Database, containerID: String, throughLens lensID: String?
    ) throws -> [RenderedBlock] {
        let base = try renderPost(db, containerID: containerID)
        guard let lensID else { return base }
        let picks = try effectiveLensSelection(db, lens: lensID)
        guard !picks.isEmpty else { return base }
        return try base.map { slot in
            guard !slot.isGap, let pick = picks[slot.blockID], pick != slot.variantID else {
                return slot
            }
            guard let variant = try Variant.fetchOne(db, key: pick) else { return slot }
            return RenderedBlock(
                blockID: slot.blockID,
                placementID: slot.placementID,
                position: slot.position,
                variantID: variant.id,
                text: variant.workingText,
                activeVariantCount: slot.activeVariantCount,
                liveVariantCount: slot.liveVariantCount,
                variantLocked: variant.locked)
        }
    }
}
