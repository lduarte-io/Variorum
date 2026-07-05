import Foundation
import GRDB

/// Ordered pointer from a container to a block — ownership (I2, the live-unique
/// index) plus the chosen variant (I3: the choice lives on the pointer, never
/// the block). Rendering a post = walk by `(position, id)`, resolve
/// `chosenVariantId` falling back to the block's default when NULL *or* when
/// the chosen variant is tombstoned/archived (read-time rule, AppSpec §7).
public struct ContainerBlock: VariorumRecord {
    public static let databaseTableName = "container_block"

    public var id: String
    public var containerId: String
    public var blockId: String
    /// Fractional-index key (AppSpec §6).
    public var position: String
    public var chosenVariantId: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        containerId: String,
        blockId: String,
        position: String,
        chosenVariantId: String? = nil,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.containerId = containerId
        self.blockId = blockId
        self.position = position
        self.chosenVariantId = chosenVariantId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
