import Foundation
import GRDB

/// The read layer (Phase 4): every view is a traversal of the one store, and
/// these are the traversals — plain read-only fetch functions over `Database`,
/// composed into live projections by `Observations.swift`. Queries never
/// mutate and carry no business rules beyond the documented read-time
/// fallbacks (AppSpec §7); anything that smells like a mutation belongs in
/// `Operations`.
///
/// Missing-row tolerance is a correctness requirement, not defensive style
/// (SyncSpec §5): a placement whose block hasn't arrived renders as a gap; a
/// dangling `chosen_variant_id` falls back; a dangling `grouping_tag_id`
/// means ungrouped. Render gaps, never crash.
public enum Queries {}

extension Queries {
    /// One slot of a rendered container (post or pool), in reading order.
    public struct RenderedBlock: Equatable, Sendable {
        public let blockID: String
        /// The `container_block` pointer row backing this slot.
        public let placementID: String
        public let position: String
        /// The variant this slot renders — the read-time rule (AppSpec §7):
        /// the pointer's chosen variant while it is live, active, and on this
        /// block; else the block's default variant while it is live. `nil` ⇒
        /// a **gap**: the block row is missing or tombstoned, or no variant
        /// is renderable (sync-race states; SyncSpec §5/§7).
        public let variantID: String?
        public let text: String?
        /// Live *active* variants on the block; the fan badge shows only
        /// when > 1 (AppSpec §12 badge behavior). Counted through the live
        /// block row, so a gap slot never badges — variants that arrived
        /// before their block (sync order) count 0 until the block lands.
        public let activeVariantCount: Int
        /// The rendered variant's lock (frozen buffer, edit by branch/unlock).
        public let variantLocked: Bool

        public var isGap: Bool { variantID == nil }
        public var hasFan: Bool { activeVariantCount > 1 }
    }

    /// Renders a container: walk the live pointer list by `(position, id)`,
    /// resolving each slot by the read-time rule. One indexed query (no
    /// N+1); cost ∝ the container's own size, never the corpus (P1). Pools
    /// render exactly like posts — same table, same traversal.
    ///
    /// The variant resolution deliberately mirrors `Operations.renderedVariant`
    /// (and `renderedLength`'s COALESCE): chosen-if-live-and-active-and-same-
    /// block, else default-if-live — the default may be archived and still
    /// render (archive hides a take from the fan, not from a slot that has
    /// nothing else to show). The equivalence is pinned by a test that runs
    /// both against the same fallback matrix.
    public static func renderPost(_ db: Database, containerID: String) throws -> [RenderedBlock] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT
                  cb.id                                            AS placement_id,
                  cb.block_id                                      AS block_id,
                  cb.position                                      AS position,
                  COALESCE(chosen.id, dflt.id)                     AS variant_id,
                  COALESCE(chosen.working_text, dflt.working_text) AS text,
                  COALESCE(chosen.locked, dflt.locked, 0)          AS variant_locked,
                  (SELECT COUNT(*) FROM variant v
                    WHERE v.block_id = b.id
                      AND v.deleted_at IS NULL
                      AND v.status = 'active')                     AS active_variant_count
                FROM container_block cb
                LEFT JOIN block b
                  ON b.id = cb.block_id AND b.deleted_at IS NULL
                LEFT JOIN variant chosen
                  ON chosen.id = cb.chosen_variant_id
                 AND chosen.block_id = b.id
                 AND chosen.deleted_at IS NULL
                 AND chosen.status = 'active'
                LEFT JOIN variant dflt
                  ON dflt.id = b.default_variant_id
                 AND dflt.deleted_at IS NULL
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                ORDER BY cb.position, cb.id
                """,
            arguments: [containerID])
        return rows.map { row in
            RenderedBlock(
                blockID: row["block_id"],
                placementID: row["placement_id"],
                position: row["position"],
                variantID: row["variant_id"],
                text: row["text"],
                activeVariantCount: row["active_variant_count"],
                variantLocked: row["variant_locked"])
        }
    }

    /// The blocks-joined-by-`"\n\n"` separator used by `renderedText` — the
    /// rendering join that re-creates stored-nothing separators (block text
    /// never stores its trailing separator; SegmentationRules doctrine).
    public static let blockJoinSeparator = "\n\n"

    /// The container's full rendered prose, for export and diff callers:
    /// each slot's rendered text joined by `blockJoinSeparator`. Gaps
    /// contribute nothing (render gaps, never crash — SyncSpec §5), and
    /// **blank takes skip like gaps** (author decision 2026-07-06: a
    /// chosen-but-empty variant contributes nothing — export reads
    /// `"a\n\nb"`, never `"a\n\n\n\nb"`; the blank take still renders as an
    /// empty slot in `renderPost` for the editor). Cost is inherently ∝ the
    /// container's own length — this is the whole-document projection, for
    /// read-side consumers that need exactly that.
    public static func renderedText(_ db: Database, containerID: String) throws -> String {
        try renderPost(db, containerID: containerID)
            .compactMap(\.text)
            .filter { !$0.isEmpty }
            .joined(separator: blockJoinSeparator)
    }
}
