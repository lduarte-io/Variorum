import Foundation
import GRDB

/// External source material attached to a post — a viewing aid, NOT a
/// knowledge object (no transclusion, no annotations, no citations). The row
/// syncs; `fileBookmark` is a security-scoped bookmark, local-only under sync
/// (excluded from payloads by the Phase 5 engine — files are per-machine).
public struct Reference: VariorumRecord {
    public static let databaseTableName = "reference"

    public var id: String
    public var ownerId: String?
    public var containerId: String
    public var kind: ReferenceKind
    public var name: String?
    /// kind='url'.
    public var url: String?
    /// kind='file': security-scoped bookmark. LOCAL-ONLY under sync.
    public var fileBookmark: Data?
    /// Remembered page/scroll position (JSON).
    public var viewState: String?
    /// Fractional-index key (AppSpec §6).
    public var position: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        containerId: String,
        kind: ReferenceKind,
        name: String? = nil,
        url: String? = nil,
        fileBookmark: Data? = nil,
        viewState: String? = nil,
        position: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.containerId = containerId
        self.kind = kind
        self.name = name
        self.url = url
        self.fileBookmark = fileBookmark
        self.viewState = viewState
        self.position = position
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
