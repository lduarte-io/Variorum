import Foundation
import GRDB

/// Append-only savepoint inside a variant (I5). Ordered by
/// `(createdAt, id)` — never a per-variant seq, which would collide when two
/// devices commit offline (AppSpec §7). No tombstone column: unreachable once
/// its variant is tombstoned; physical cleanup is the Phase 12 GC.
public struct CommitPoint: VariorumRecord {
    public static let databaseTableName = "commit_point"

    public var id: String
    public var variantId: String
    /// Immutable snapshot — never overwritten (I5).
    public var text: String
    public var kind: CommitKind
    public var message: String?
    public var createdAt: Date
    public var syncVersion: Int

    public init(
        id: String,
        variantId: String,
        text: String,
        kind: CommitKind = .manual,
        message: String? = nil,
        createdAt: Date,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.variantId = variantId
        self.text = text
        self.kind = kind
        self.message = message
        self.createdAt = createdAt
        self.syncVersion = syncVersion
    }
}
