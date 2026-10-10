import Foundation
import GRDB

// THE MCP DOOR's EDIT-RUNG READS (13n-b U3). The few facts the edit tools
// address by: which note a block or a take lives in right now (a released,
// pooled or dead one lives in none — the one-answer refusal), and which take
// a block SHOWS (the rule the structural ops cut and join by).
extension Queries {
    /// The note (or pool) a block is live-placed in now, else nil.
    public static func mcpContainerOf(block blockID: String, _ db: Database) throws -> String? {
        try String.fetchOne(
            db,
            sql: """
                SELECT cb.container_id FROM container_block cb
                JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                WHERE cb.block_id = ? AND cb.deleted_at IS NULL
                """,
            arguments: [blockID])
    }

    /// The note (or pool) a take's block is live-placed in now, else nil.
    public static func mcpContainerOf(take variantID: String, _ db: Database) throws -> String? {
        try String.fetchOne(
            db,
            sql: """
                SELECT cb.container_id FROM variant v
                JOIN block b ON b.id = v.block_id AND b.deleted_at IS NULL
                JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                WHERE v.id = ? AND v.deleted_at IS NULL
                """,
            arguments: [variantID])
    }

    /// **The take a placed block SHOWS** — exactly the structural ops' own
    /// rendered-take rule (`Operations.renderedVariant`): the placement's
    /// chosen take while it is live, ACTIVE and on this block, else the
    /// block's default while it is live. Nil for an unplaced or dead block.
    public static func mcpShownTake(_ db: Database, blockID: String) throws -> Variant? {
        guard let row = try Row.fetchOne(
            db,
            sql: """
                SELECT cb.chosen_variant_id, b.default_variant_id FROM container_block cb
                JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                WHERE cb.block_id = ? AND cb.deleted_at IS NULL
                """,
            arguments: [blockID])
        else { return nil }
        if let chosenID: String = row["chosen_variant_id"],
           let chosen = try Variant.fetchOne(db, key: chosenID),
           chosen.blockId == blockID, chosen.deletedAt == nil, chosen.status == .active {
            return chosen
        }
        if let defaultID: String = row["default_variant_id"],
           let fallback = try Variant.fetchOne(db, key: defaultID), fallback.deletedAt == nil {
            return fallback
        }
        return nil
    }

    /// **Where a TRAY item belongs** (13n-b U4 — `put_back`'s address): a
    /// deleted block's `last_container_id` (the note it was deleted from — the
    /// tray's own key); nil for a live block or one that remembers no home.
    public static func mcpTrayHome(block blockID: String, _ db: Database) throws -> String? {
        try String.fetchOne(
            db, sql: "SELECT last_container_id FROM block WHERE id = ? AND deleted_at IS NOT NULL",
            arguments: [blockID])
    }

    /// A deleted TAKE's home — `trayTakes`' own rule: its live block's live
    /// placement, else (a released original) the block's `last_container_id`;
    /// nil for a live take, or one whose block died (it rides its block's
    /// row — restore the block).
    public static func mcpTrayHome(take variantID: String, _ db: Database) throws -> String? {
        try String.fetchOne(
            db,
            sql: """
                SELECT COALESCE(cb.container_id, b.last_container_id) FROM variant v
                JOIN block b ON b.id = v.block_id AND b.deleted_at IS NULL
                LEFT JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
                WHERE v.id = ? AND v.deleted_at IS NOT NULL
                """,
            arguments: [variantID])
    }
}
