import Foundation
import GRDB

/// A working note on a BLOCK (Phase 13, v1_8 — author-decided 2026-07-17,
/// AppSpec §14 items 6/9): "take 1 is what I prefer, but I like the
/// conclusion in take 2 more." Deliberately block-level, never per-take
/// (her explicit boundary), and deliberately its own table — multiple
/// comments per block, no natural key, no uniqueness; display order is
/// `(created_at, id)`.
///
/// Comments are metadata under sync (server-version-wins CAS — `text` here
/// is NOT `variant.working_text`; S5's conflict-as-variant is scoped to the
/// one mutable prose buffer by design). Deleted comments stay visible and
/// resurrectable (`restoreBlockComment` + the recovery queries) — accidental
/// deletion is recoverable, never skimpy. Structural travel (duplication
/// onto successors) is the operations layer's, Phase 13 Step A2.
public struct BlockComment: VariorumRecord {
    public static let databaseTableName = "block_comment"

    public var id: String
    public var ownerId: String?
    public var blockId: String
    public var text: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        blockId: String,
        text: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.blockId = blockId
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
