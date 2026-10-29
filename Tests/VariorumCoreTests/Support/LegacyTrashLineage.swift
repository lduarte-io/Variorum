//
//  LegacyTrashLineage.swift
//  VariorumCoreTests
//
//  VX-670 (the VX-678 run, Unit 3 — ruling A-678-1): the PRE-REWRITE bodies of
//  `Queries.strandedOriginals` and `Queries.originFamilyClocks`, VERBATIM from
//  `Sources/VariorumCore/Queries/Trash.swift` at 4e4e3ab51 (the tree before
//  the rewrite) — only the function names, their `Queries.` qualifications
//  and these comments differ. They are the EQUIVALENCE ORACLE: the rewrite is
//  a performance change that must never move an answer, so the exact-rows
//  pins (`TrashLineageP1Tests`) and the gated probe (`VX653LineageProbeTests`)
//  assert the new bodies answer exactly what these answer, on every fixture.
//
//  Both carry the `fam(origin, id)` PAIR SET — every original paired with
//  every one of its descendants — which is O(L²) in a note's seam history
//  (24.0 s / 14.6 s at 600 rounds, Unit 2's finding). Never call them from
//  production code.
//

import Foundation
import GRDB
@testable import VariorumCore

enum LegacyTrashLineage {
    /// `Queries.strandedOriginals` before VX-670, verbatim.
    static func strandedOriginals(
        _ db: Database, now: Date, oldestFirst: Bool = false, limit: Int? = nil,
        wingID: String? = nil
    ) throws -> [Queries.TrashItem] {
        let cutoff = TrashWindow.cutoffStamp(now: now)
        let dir = oldestFirst ? "ASC" : "DESC"
        let limitClause = limit == nil ? "" : " LIMIT :limit"  // binds (item 3)
        var arguments: StatementArguments = ["cutoff": cutoff]
        if let limit { arguments += ["limit": limit] }
        // 13i-d U5: the original's NOTE's wing (the per-wing Trash).
        var wingFence = ""
        if let wingID {
            if wingID.isEmpty {
                wingFence = """
                     AND (c.wing_id = '' OR c.wing_id NOT IN \
                    (SELECT w.id FROM wing w WHERE w.deleted_at IS NULL))
                    """
            } else {
                wingFence = " AND c.wing_id = :wing"
                arguments += ["wing": wingID]
            }
        }
        return try Row.fetchAll(
            db,
            sql: """
                WITH RECURSIVE origins(id) AS (
                  SELECT b.id FROM block b
                  JOIN container c ON c.id = b.last_container_id AND c.deleted_at IS NULL
                  WHERE b.deleted_at IS NULL AND b.archived_at IS NULL\(wingFence)
                    AND NOT EXISTS (
                      SELECT 1 FROM container_block placed
                      WHERE placed.block_id = b.id AND placed.deleted_at IS NULL)
                ),
                fam(origin, id) AS (
                  -- The edges are read WITHOUT their tombstones on purpose:
                  -- deleting a block cascade-tombstones its edges, and a
                  -- family whose members are all deleted is precisely the
                  -- state this query exists to find. Lineage is a fact about
                  -- what happened; the tombstone rides the block, not the
                  -- history (`derived_from` has no user-facing delete door).
                  SELECT o.id, e.source_block_id FROM origins o
                  JOIN edge e ON e.target_block_id = o.id AND e.type = 'derived_from'
                  UNION
                  SELECT f.origin, e.source_block_id FROM fam f
                  JOIN edge e ON e.target_block_id = f.id AND e.type = 'derived_from'
                )
                SELECT f.origin AS block_id,
                       MAX(d.deleted_at) AS family_clock,
                       SUM(CASE WHEN d.deleted_at IS NULL THEN 1 ELSE 0 END) AS live_count,
                       -- Ledger row 22 (her tenth-sitting ruling): the family
                       -- member whose tombstone IS the family clock — the
                       -- block she just deleted, which the Trash nests this
                       -- original UNDER. Written as an explicit ordered
                       -- correlated read rather than leaning on SQLite's
                       -- bare-column-beside-MAX() convenience, so the answer
                       -- is deterministic by the statement's own words.
                       (SELECT d2.id FROM fam f2
                          JOIN block d2 ON d2.id = f2.id
                         WHERE f2.origin = f.origin AND d2.deleted_at IS NOT NULL
                         ORDER BY d2.deleted_at DESC, d2.id DESC
                         LIMIT 1) AS anchor_block_id,
                       dv.working_text AS text,
                       c.id AS note_id, c.title AS note_title,
                       c.entry_date AS note_entry_date, c.created_at AS note_created_at
                FROM fam f
                JOIN block d ON d.id = f.id
                JOIN block o ON o.id = f.origin
                LEFT JOIN variant dv ON dv.id = o.default_variant_id AND dv.deleted_at IS NULL
                LEFT JOIN container c ON c.id = o.last_container_id
                GROUP BY f.origin
                HAVING live_count = 0 AND family_clock >= :cutoff
                  -- 13j batch 6b: a family with a standing purge intent has
                  -- left every surface (the doors' promise); its origin
                  -- rides the purge and stops listing with it. Stamp-aware
                  -- (ladder B, B1): a VOIDED intent from before a re-delete
                  -- never fences the fresh tombstone's family.
                  AND SUM(CASE WHEN EXISTS (SELECT 1 FROM purge_intent pi
                    WHERE pi.table_name = 'block' AND pi.row_id = f.id
                      AND (pi.deleted_at IS NULL OR pi.deleted_at >= d.deleted_at))
                    THEN 1 ELSE 0 END) = 0
                ORDER BY family_clock \(dir), f.origin \(dir)\(limitClause)
                """,
            arguments: arguments
        ).map { row in
            Queries.TrashItem(
                kind: .preservedOriginal, id: row["block_id"],
                deletedAt: row["family_clock"], text: row["text"],
                noteID: row["note_id"],
                noteTitle: (row["note_id"] as String?).map { _ in
                    DisplayTitle.note(
                        title: row["note_title"], entryDate: row["note_entry_date"],
                        createdAt: row["note_created_at"])
                },
                anchorBlockID: row["anchor_block_id"])
        }
    }

    /// `Queries.originFamilyClocks` before VX-670, verbatim.
    static func originFamilyClocks(
        _ db: Database, postID: String, now: Date
    ) throws -> [String: Queries.OriginFamilyFate] {
        var fates: [String: Queries.OriginFamilyFate] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                WITH RECURSIVE origins(id) AS (
                  SELECT b.id FROM block b
                  WHERE b.last_container_id = :post AND b.deleted_at IS NULL
                    AND b.archived_at IS NULL
                    AND NOT EXISTS (
                      SELECT 1 FROM container_block placed
                      WHERE placed.block_id = b.id AND placed.deleted_at IS NULL)
                ),
                fam(origin, id) AS (
                  -- The edges are read WITHOUT their tombstones on purpose:
                  -- deleting a block cascade-tombstones its edges, and a
                  -- family whose members are all deleted is precisely the
                  -- state this query exists to find. Lineage is a fact about
                  -- what happened; the tombstone rides the block, not the
                  -- history (`derived_from` has no user-facing delete door).
                  SELECT o.id, e.source_block_id FROM origins o
                  JOIN edge e ON e.target_block_id = o.id AND e.type = 'derived_from'
                  UNION
                  SELECT f.origin, e.source_block_id FROM fam f
                  JOIN edge e ON e.target_block_id = f.id AND e.type = 'derived_from'
                )
                SELECT f.origin AS block_id,
                       MAX(d.deleted_at) AS family_clock,
                       SUM(CASE WHEN d.deleted_at IS NULL THEN 1 ELSE 0 END) AS live_count,
                       -- The intent fence, stamp-aware (B1/B5 — the exact
                       -- condition `strandedOriginals` applies).
                       SUM(CASE WHEN EXISTS (SELECT 1 FROM purge_intent pi
                         WHERE pi.table_name = 'block' AND pi.row_id = f.id
                           AND (pi.deleted_at IS NULL OR pi.deleted_at >= d.deleted_at))
                         THEN 1 ELSE 0 END) AS fenced_count
                FROM fam f JOIN block d ON d.id = f.id
                GROUP BY f.origin
                HAVING live_count = 0
                """,
            arguments: ["post": postID]) {
            guard let clock: String = row["family_clock"] else { continue }
            let fenced = (row["fenced_count"] as Int? ?? 0) > 0
            let blockID = row["block_id"] as String
            if fenced || !TrashWindow.isInWindow(clock, now: now) {
                fates[blockID] = .gone
            } else {
                fates[blockID] = .counting(clock)
            }
        }
        return fates
    }
}
