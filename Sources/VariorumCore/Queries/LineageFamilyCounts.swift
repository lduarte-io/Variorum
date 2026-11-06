import Foundation
import GRDB

// VX-801 (VX-827 U3b) — the Lineage face's per-member counts (THE DESIGN
// MEMO's row: "origin verb · first words · where it lives · counts").
extension Queries {
    /// **Each lineage member's takes and commits** — the live ACTIVE takes
    /// (the face's "N takes") and the commits of its live takes (active and
    /// archived, the rail's own reach), for the given blocks only. One
    /// statement, every count an index seek (`idx_variant_block`,
    /// `idx_commit_variant`) over the named blocks' own rows: cost ∝ the
    /// family's takes and commits, never the corpus (P1). A block with no row
    /// counts zero.
    public static func lineageFamilyCounts(
        _ db: Database, blockIDs: [String]
    ) throws -> [String: LineageFamily.Counts] {
        guard !blockIDs.isEmpty else { return [:] }
        let json = String(decoding: try JSONEncoder().encode(blockIDs), as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT j.value AS id,
                  (SELECT COUNT(*) FROM variant v
                    WHERE v.block_id = j.value AND v.status = 'active' AND v.deleted_at IS NULL) AS takes,
                  (SELECT COUNT(*) FROM variant v
                    JOIN commit_point c ON c.variant_id = v.id
                    WHERE v.block_id = j.value AND v.deleted_at IS NULL) AS commits
                FROM json_each(?) j
                """,
            arguments: [json])
        var out: [String: LineageFamily.Counts] = [:]
        for row in rows {
            out[row["id"]] = LineageFamily.Counts(takes: row["takes"], commits: row["commits"])
        }
        return out
    }
}
