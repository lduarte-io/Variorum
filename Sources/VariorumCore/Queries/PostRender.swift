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
        /// **Live variants on the block regardless of `status`** — active
        /// AND archived (13c Stage 1 ladder, R1-1). `activeVariantCount` is
        /// the FAN: what the badge shows and what the author is looking at.
        /// This is what EXISTS. The two differ exactly when a block carries
        /// archived takes, and an archived take is still prose that a
        /// `deleteBlock` cascade takes with it — so any gesture whose
        /// authorization is "there is no text to lose here" must read THIS
        /// count, never the fan's. Counted through the live block row like
        /// its sibling, so a gap slot reads 0.
        public let liveVariantCount: Int
        /// **Live `block_comment` rows on the block** (13c Stage 1 ladder,
        /// R2-1). Comments are authored prose the SLOT never renders, and
        /// `deleteBlock` fires v1_8's cascade over them — so, like an
        /// archived take, a commented block that renders empty is not a
        /// textless block. Counted through the live block row like its two
        /// siblings, so a gap slot reads 0.
        public let commentCount: Int
        /// The rendered variant's lock (frozen buffer, edit by branch/unlock).
        public let variantLocked: Bool

        public var isGap: Bool { variantID == nil }
        public var hasFan: Bool { activeVariantCount > 1 }
        /// True when the block carries takes the fan does not show — the
        /// "renders empty but is not textless" state R1-1 found.
        public var hasArchivedTakes: Bool { liveVariantCount > activeVariantCount }
        /// True when the block carries working notes (13c R2-1).
        public var hasComments: Bool { commentCount > 0 }

        /// **THE read for any gesture authorized on "there is no text to
        /// lose here"** (13c Stage 1 ladder, R1-1 + R2-1 — the two halves
        /// of one class, wired through one name so a third kind of unshown
        /// prose extends this property rather than growing a parallel
        /// guard). `text` is what the slot SHOWS; this is what the block
        /// additionally HOLDS — archived takes, and block comments. Both
        /// die in `deleteBlock`'s cascade, and the comment half additionally
        /// breaks AppSpec §7's ratified "deleted comments are visible and
        /// resurrectable — never skimpy", because `deletedBlockComments` is
        /// keyed by block and a tombstoned block is only in the tray.
        ///
        /// Deliberately NOT included (13c R2-1, PROVISIONAL — QUESTIONS
        /// #40): `block.name` and `block.presentation`. Those are columns
        /// ON the block row: the tombstone keeps them, `restoreBlock` and
        /// structural undo bring them back with the block, and the tray
        /// lists the block BY its name. Nothing of them becomes
        /// unrecoverable or unreachable, which is what separates them from
        /// the two counted here.
        public var carriesUnshownText: Bool { hasArchivedTakes || hasComments }

        /// Public so view layers and tests can build projections directly
        /// (the editor's pure mapping functions take these as input).
        ///
        /// `liveVariantCount` and `commentCount` are REQUIRED, never
        /// defaulted: a projection builder that has not thought about
        /// archived takes or comments must say so, rather than silently
        /// reporting a block as textless (the `UndoStack.register(redo:)`
        /// precedent — green by construction, not by audit).
        public init(
            blockID: String, placementID: String, position: String,
            variantID: String?, text: String?,
            activeVariantCount: Int, liveVariantCount: Int, commentCount: Int,
            variantLocked: Bool
        ) {
            self.blockID = blockID
            self.placementID = placementID
            self.position = position
            self.variantID = variantID
            self.text = text
            self.activeVariantCount = activeVariantCount
            self.liveVariantCount = liveVariantCount
            self.commentCount = commentCount
            self.variantLocked = variantLocked
        }
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
                      AND v.status = 'active')                     AS active_variant_count,
                  -- Archived takes included: what EXISTS on the block, as
                  -- against what the fan shows (R1-1).
                  (SELECT COUNT(*) FROM variant v
                    WHERE v.block_id = b.id
                      AND v.deleted_at IS NULL)                    AS live_variant_count,
                  -- Working notes on the block (R2-1): prose the slot never
                  -- renders, taken by the same cascade. Indexed by
                  -- idx_block_comment_block; cost stays ∝ the container.
                  (SELECT COUNT(*) FROM block_comment bc
                    WHERE bc.block_id = b.id
                      AND bc.deleted_at IS NULL)                   AS comment_count
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
                liveVariantCount: row["live_variant_count"],
                commentCount: row["comment_count"],
                variantLocked: row["variant_locked"])
        }
    }

    /// The default blocks-join separator used by `renderedText` — the
    /// rendering join that re-creates stored-nothing separators (block text
    /// never stores its trailing separator; SegmentationRules doctrine).
    /// See `joinRenderedTexts` for the one conditional (author ruling
    /// 2026-07-12).
    public static let blockJoinSeparator = "\n\n"

    /// THE rendered-text join (author ruling 2026-07-12, QUESTIONS #12 —
    /// the export half of spacing preservation, shaped on the ratified
    /// merge-join precedent "a single space at the join unless either
    /// side's edge already carries whitespace"): blocks join with
    /// `"\n\n"` UNLESS the left side already ends in a newline (stored
    /// spacing — option (a)'s trailing-newline content), in which case the
    /// join completes it with a single `"\n"` — so a k-newline paste
    /// (k ≥ 2) exports as k newlines again, while a SINGLE-newline paste
    /// stores no trailing content and exports through the default
    /// `"\n\n"` join (the ratified rendering separator); unspaced posts
    /// join byte-identical to the pre-ruling `"\n\n"`. One join brain: `renderedText` AND the
    /// bridge's per-day projection both call this — the pushed body always
    /// equals the export.
    public static func joinRenderedTexts(_ texts: [String]) -> String {
        var result = ""
        for (i, text) in texts.enumerated() {
            if i > 0 {
                result += result.hasSuffix("\n") ? "\n" : blockJoinSeparator
            }
            result += text
        }
        return result
    }

    /// The container's full rendered prose, for export and diff callers:
    /// each slot's rendered text joined by `joinRenderedTexts`. Gaps
    /// contribute nothing (render gaps, never crash — SyncSpec §5), and
    /// **blank takes skip like gaps** (author decision 2026-07-06: a
    /// chosen-but-empty variant contributes nothing — export reads
    /// `"a\n\nb"`, never `"a\n\n\n\nb"`; the blank take still renders as an
    /// empty slot in `renderPost` for the editor). Cost is inherently ∝ the
    /// container's own length — this is the whole-document projection, for
    /// read-side consumers that need exactly that.
    public static func renderedText(_ db: Database, containerID: String) throws -> String {
        joinRenderedTexts(
            try renderPost(db, containerID: containerID)
                .compactMap(\.text)
                .filter { !$0.isEmpty })
    }
}
