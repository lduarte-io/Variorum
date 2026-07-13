import Foundation
import GRDB

/// One block-card's persisted position on a container's canvas (AppSpec §12
/// canvas view; author-ratified 2026-07-06, Phase 11 brief item 1). At most
/// one live row per (container, block) — the live-unique index; positions
/// are plain metadata under sync (CAS — a two-device drag race converges to
/// either position, never corruption). The row tombstones with its
/// container AND with its block (cascade triggers, migration v1_5).
///
/// Deliberately NOT rendering state: the canvas is a traversal of the
/// container's blocks (the read tier renders the cards); this table stores
/// only where the cards sit.
public struct CanvasLayout: VariorumRecord {
    public static let databaseTableName = "canvas_layout"

    public var id: String
    public var ownerId: String?
    public var containerId: String
    public var blockId: String
    public var x: Double
    public var y: Double
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        containerId: String,
        blockId: String,
        x: Double,
        y: Double,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.containerId = containerId
        self.blockId = blockId
        self.x = x
        self.y = y
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
