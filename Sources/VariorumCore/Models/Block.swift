import Foundation
import GRDB

/// Identity anchor (OverallModel §2): holds identity and its variants, nothing
/// else. `defaultVariantId` is the pointer-free representative — never NULL
/// while the block is live (I10 + reassignment, AppSpec §9); a pointer's
/// `chosenVariantId` always wins where one exists.
public struct Block: VariorumRecord {
    public static let databaseTableName = "block"

    public var id: String
    public var ownerId: String?
    public var defaultVariantId: String?
    /// Powers the per-post "deleted blocks" tray; maintained by the operations
    /// layer, not by triggers.
    public var lastContainerId: String?
    /// The optional per-block name (Phase 11, v1_6 — the block-TOC's
    /// explicit handle; AppSpec §14's 2026-07-07 delta). Block-identity-
    /// level, plain metadata under sync; an unnamed block's display handle
    /// is DERIVED at read time (first sentence), never stored here.
    public var name: String?
    public var createdAt: Date
    public var updatedAt: Date
    /// Domain archive (kept, out of view) — distinct from the sync tombstone.
    public var archivedAt: Date?
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        defaultVariantId: String? = nil,
        lastContainerId: String? = nil,
        name: String? = nil,
        createdAt: Date,
        updatedAt: Date,
        archivedAt: Date? = nil,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.defaultVariantId = defaultVariantId
        self.lastContainerId = lastContainerId
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }

    public static let variants = hasMany(Variant.self)
}
