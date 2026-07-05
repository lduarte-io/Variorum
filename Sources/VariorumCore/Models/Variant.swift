import Foundation
import GRDB

/// One alternative text for a block's slot; the fan is a block's active
/// variants. `workingText` is THE mutable buffer — the only mutable text in
/// the entire system (OverallModel §3) and the only field that can produce a
/// sync conflict (S5).
public struct Variant: VariorumRecord {
    public static let databaseTableName = "variant"

    public var id: String
    public var blockId: String
    /// Branch/history tree.
    public var parentVariantId: String?
    public var workingText: String
    public var status: VariantStatus
    /// Reversible guard, orthogonal to commit (I6): to edit, branch or unlock.
    public var locked: Bool
    public var label: String?
    /// Fractional-index key (AppSpec §6).
    public var fanPosition: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        blockId: String,
        parentVariantId: String? = nil,
        workingText: String = "",
        status: VariantStatus = .active,
        locked: Bool = false,
        label: String? = nil,
        fanPosition: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.blockId = blockId
        self.parentVariantId = parentVariantId
        self.workingText = workingText
        self.status = status
        self.locked = locked
        self.label = label
        self.fanPosition = fanPosition
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }

    public static let commitPoints = hasMany(CommitPoint.self)
}
