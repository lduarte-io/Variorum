import Foundation
import GRDB

// Lens read side (Phase 11, Step A1 — v1_7). A lens is a VIEW-side
// projection: these traversals overlay sparse overrides onto the ordinary
// slot resolution and never touch rendering truth. Exports and the book
// view keep reading `renderPost`/`renderedText` — a lens
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

    /// **`effectiveLensSelection` for NAMED blocks only** (VX-256, VX-336 U7 —
    /// D-256-4: a paged `read_note` reads a lens's picks for the page's blocks,
    /// never the lens whole). The same rule exactly — a pick whose variant is
    /// live, active and on the picked block — with each given block seeking its
    /// one live pick through `uq_lens_choice_live(lens_id, block_id)`, so the
    /// cost is ∝ the blocks named (P1), never the lens's picks.
    public static func effectiveLensSelection(
        _ db: Database, lens lensID: String, blocks blockIDs: [String]
    ) throws -> [String: String] {
        guard !blockIDs.isEmpty else { return [:] }
        let json = String(decoding: try JSONEncoder().encode(blockIDs), as: UTF8.self)
        let rows = try Row.fetchAll(db, sql: pageLensSelectionSQL, arguments: [json, lensID])
        return Dictionary(
            rows.map { ($0["block_id"], $0["variant_id"]) }, uniquingKeysWith: { first, _ in first })
    }

    /// The statement `effectiveLensSelection(_:lens:blocks:)` runs — internal so
    /// its plan is pinned (the given ids drive; `uq_lens_choice_live` serves).
    /// `CROSS JOIN` keeps that order (SQLite never reorders one): left to
    /// itself the planner put the lens's picks outermost — ∝ the lens, the
    /// whole note's picks — which the plan pin caught.
    static let pageLensSelectionSQL = """
        SELECT lc.block_id AS block_id, lc.variant_id AS variant_id
        FROM json_each(?) j
        CROSS JOIN lens_choice lc
          ON lc.lens_id = ? AND lc.block_id = j.value AND lc.deleted_at IS NULL
        CROSS JOIN variant v
          ON v.id = lc.variant_id
         AND v.block_id = lc.block_id
         AND v.deleted_at IS NULL
         AND v.status = 'active'
        """

    /// **A pick that no longer resolves** (13j J5 — her mobile-gate ruling:
    /// when a saved lens's pick dangles the Mac must *"say loudly if that take
    /// was archived and this is a fallback WITH a button for quick restore"*).
    ///
    /// `effectiveLensSelection` DROPS these silently and the column falls
    /// through to the note's own chosen take — correct, and completely
    /// invisible: the lens shows a take she never picked, with nothing saying
    /// so. This is the same set, seen from the other side, carrying WHY —
    /// because the notice has to word itself to the actual state and the
    /// Restore button has to know which door to open (unarchive vs restore).
    public struct DanglingPick: Equatable, Sendable {
        public enum State: String, Equatable, Sendable {
            /// The take is live but archived — `unarchiveVariant` brings it back.
            case archived
            /// The take is tombstoned — `restoreVariant` brings it back.
            case deleted
            /// No such row at all (a sync arrival naming a take this device
            /// never saw, or a purge). Nothing to restore; the notice says so.
            case gone
            /// The row exists but belongs to a DIFFERENT block (the sync race
            /// `effectiveLensSelection`'s join guards against). Nothing this
            /// surface can honestly restore INTO this slot.
            case foreign
        }

        public let variantID: String
        public let state: State

        public init(variantID: String, state: State) {
            self.variantID = variantID
            self.state = state
        }

        /// True where a Restore door can act — the notice renders either way,
        /// because "showing the default take" is the fact she needs first.
        public var isRestorable: Bool { state == .archived || state == .deleted }
    }

    /// blockID → the lens's dangling pick for that block. Cost ∝ the lens's
    /// own overrides (the `lensChoices` pass, one join), never the corpus.
    public static func danglingLensPicks(
        _ db: Database, lens lensID: String
    ) throws -> [String: DanglingPick] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT lc.block_id AS block_id, lc.variant_id AS variant_id,
                       v.id AS found_id, v.block_id AS variant_block,
                       v.deleted_at AS deleted_at, v.status AS status
                FROM lens_choice lc
                LEFT JOIN variant v ON v.id = lc.variant_id
                WHERE lc.lens_id = ? AND lc.deleted_at IS NULL
                """,
            arguments: [lensID])
        var dangling: [String: DanglingPick] = [:]
        for row in rows {
            let blockID: String = row["block_id"]
            let variantID: String = row["variant_id"]
            let state: DanglingPick.State
            if (row["found_id"] as String?) == nil {
                state = .gone
            } else if (row["deleted_at"] as String?) != nil {
                state = .deleted
            } else if (row["variant_block"] as String?) != blockID {
                state = .foreign
            } else if (row["status"] as String?) == VariantStatus.archived.rawValue {
                state = .archived
            } else {
                continue  // live, active, on this block — the effective pick
            }
            dangling[blockID] = DanglingPick(variantID: variantID, state: state)
        }
        return dangling
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
                commentCount: slot.commentCount,
                variantLocked: variant.locked)
        }
    }
}
