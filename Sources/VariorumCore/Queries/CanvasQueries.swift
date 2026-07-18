import Foundation
import GRDB

// The canvas view's read side (Phase 11, Step A7 — AppSpec §12; the
// canvas_layout table is A1's v1_5).
extension Queries {
    /// The container's live card positions: blockID → (x, y). Rows whose
    /// block no longer sits in the container simply never render (the
    /// canvas walks the container's blocks; a stale layout row is inert
    /// until the block returns — then its position is remembered).
    public static func canvasLayouts(
        _ db: Database, container containerID: String
    ) throws -> [String: CanvasPosition] {
        let rows = try CanvasLayout
            .filter(Column("container_id") == containerID && Column("deleted_at") == nil)
            .fetchAll(db)
        return Dictionary(uniqueKeysWithValues: rows.map {
            ($0.blockId, CanvasPosition(x: $0.x, y: $0.y))
        })
    }

    public struct CanvasPosition: Equatable, Sendable {
        public var x: Double
        public var y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    /// One canvas projection: the container's cards (its blocks, rendered)
    /// plus their positions — and, Phase 13 C3 (R40's minimal takes
    /// switcher), the FANNED blocks' live active fans in fan order, so the
    /// one-at-a-time selector needs no second fetch. Cost ∝ the container's
    /// own size (P1); single-take blocks are absent from `fans`.
    public struct CanvasProjection: Equatable, Sendable {
        public var cards: [PoolItem]
        public var positions: [String: CanvasPosition]
        /// blockID → the block's live ACTIVE takes, fan order — fanned
        /// blocks only (the switcher's feed; additive, default empty).
        public var fans: [String: [Variant]]

        public init(
            cards: [PoolItem] = [], positions: [String: CanvasPosition] = [:],
            fans: [String: [Variant]] = [:]
        ) {
            self.cards = cards
            self.positions = positions
            self.fans = fans
        }
    }

    public static func canvasProjection(
        _ db: Database, container containerID: String
    ) throws -> CanvasProjection {
        let cards = try poolListing(db, poolID: containerID)
        let fannedIDs = cards.filter { $0.block.hasFan }.map(\.block.blockID)
        return CanvasProjection(
            cards: cards,
            positions: try canvasLayouts(db, container: containerID),
            fans: try activeFans(db, blockIDs: fannedIDs))
    }
}

extension AppDatabase {
    /// The canvas's standing observation (Phase 11, A7).
    public func observeCanvas(
        _ containerID: String
    ) -> AsyncValueObservation<Queries.CanvasProjection> {
        observe { try Queries.canvasProjection($0, container: containerID) }
    }
}
