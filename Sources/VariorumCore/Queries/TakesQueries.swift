import Foundation
import GRDB

// The takes/lens view family's read side (Phase 11, Step A3 — the kickoff
// spike record). One combined traversal so the board's standing observation
// is a single fetch, cost ∝ the post's own size (P1): slots + active fans +
// lenses with their effective picks + the fan-style setting + the seal.
extension Queries {
    /// One post's takes-board projection.
    public struct TakesProjection: Equatable, Sendable {
        /// The post's slots in reading order (the ordinary traversal —
        /// chosen resolution; lenses overlay app-side, never here).
        public var slots: [RenderedBlock]
        /// blockID → the block's live ACTIVE fan, in fan order (the fan
        /// definition — archived takes are FanPanel/history material).
        public var fans: [String: [Variant]]
        /// The post's live lenses, stable order.
        public var lenses: [Lens]
        /// lensID → blockID → variantID (EFFECTIVE picks — dangling
        /// dropped, the fall-through class).
        public var lensSelections: [String: [String: String]]
        public var fanStyle: FanStyle
        public var sealed: Bool

        public init(
            slots: [RenderedBlock] = [], fans: [String: [Variant]] = [:],
            lenses: [Lens] = [], lensSelections: [String: [String: String]] = [:],
            fanStyle: FanStyle = .stack, sealed: Bool = false
        ) {
            self.slots = slots
            self.fans = fans
            self.lenses = lenses
            self.lensSelections = lensSelections
            self.fanStyle = fanStyle
            self.sealed = sealed
        }
    }

    public static func takesProjection(
        _ db: Database, post containerID: String
    ) throws -> TakesProjection {
        let slots = try renderPost(db, containerID: containerID)
        var fans: [String: [Variant]] = [:]
        for slot in slots where !slot.isGap {
            fans[slot.blockID] = try Variant
                .filter(Column("block_id") == slot.blockID
                        && Column("deleted_at") == nil
                        && Column("status") == VariantStatus.active.rawValue)
                .order(Column("fan_position"), Column("id"))
                .fetchAll(db)
        }
        let lenses = try Queries.lenses(db, post: containerID)
        var selections: [String: [String: String]] = [:]
        for lens in lenses {
            selections[lens.id] = try effectiveLensSelection(db, lens: lens.id)
        }
        let sealed = try Bool.fetchOne(
            db, sql: "SELECT locked FROM container WHERE id = ?",
            arguments: [containerID]) ?? false
        return TakesProjection(
            slots: slots, fans: fans, lenses: lenses, lensSelections: selections,
            fanStyle: try fanStyle(db), sealed: sealed)
    }

    /// The fan-style setting ('fan_style'; default .stack — the recorded
    /// build-time call).
    public static func fanStyle(_ db: Database) throws -> FanStyle {
        let raw = try String.fetchOne(
            db, sql: "SELECT value FROM setting WHERE key = 'fan_style'")
        return raw.flatMap(FanStyle.init(rawValue:)) ?? .stack
    }

    /// BLOCK-LEVEL KINSHIP between two posts (spike record item 6 — the
    /// aligned versions/outline↔draft rows are keyed by `derived_from`
    /// lineage, NEVER by order): each of `other`'s placed blocks maps to
    /// its nearest lineage kin among `anchor`'s placed blocks (ancestors
    /// and descendants both count — a version copy's blocks DESCEND from
    /// the original's; an outline's draft blocks descend from outline
    /// blocks; direction is presentation). The block itself counts at
    /// depth 0 (two posts can point at... no — I2 forbids sharing; kept
    /// for self-comparison degenerates). Unmatched blocks are absent —
    /// the view renders them as orphan rows with blanks.
    public static func blockKinship(
        _ db: Database, anchor anchorID: String, other otherID: String,
        maxDepth: Int = 32
    ) throws -> [String: String] {
        let anchorBlocks = try String.fetchAll(
            db,
            sql: """
                SELECT block_id FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL
                """,
            arguments: [anchorID])
        let anchorSet = Set(anchorBlocks)
        guard !anchorSet.isEmpty else { return [:] }
        let otherBlocks = try String.fetchAll(
            db,
            sql: """
                SELECT block_id FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL
                ORDER BY position, id
                """,
            arguments: [otherID])

        var kinship: [String: String] = [:]
        for blockID in otherBlocks {
            if anchorSet.contains(blockID) {
                kinship[blockID] = blockID
                continue
            }
            // Nearest kin by lineage distance; ancestors win ties (a
            // divided block's pieces point AT their source).
            let up = try ancestors(db, of: blockID, maxDepth: maxDepth)
                .first { anchorSet.contains($0.blockID) }
            let down = try descendants(db, of: blockID, maxDepth: maxDepth)
                .first { anchorSet.contains($0.blockID) }
            switch (up, down) {
            case (let up?, let down?):
                kinship[blockID] = up.depth <= down.depth ? up.blockID : down.blockID
            case (let up?, nil):
                kinship[blockID] = up.blockID
            case (nil, let down?):
                kinship[blockID] = down.blockID
            case (nil, nil):
                break
            }
        }
        return kinship
    }
}

extension AppDatabase {
    /// The takes board's standing observation (Phase 11, A3). One post's
    /// combined projection — bounded by construction (cost ∝ this post).
    public func observeTakes(
        _ containerID: String
    ) -> AsyncValueObservation<Queries.TakesProjection> {
        observe { try Queries.takesProjection($0, post: containerID) }
    }
}
