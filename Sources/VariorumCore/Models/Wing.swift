import Foundation
import GRDB

/// A wing — an in-store library, a level above books: "a different room in
/// the same house" (the author's 2026-08-26 ruling; the 13i sitting record
/// §9: TOTAL isolation — gatherings, search, tag listings and Arrivals all
/// scope by wing; the only crossings are the explicit move/copy doors).
///
/// THE HOME WING IS VIRTUAL (R-13ia-1/2, the 13i-a kickoff): rows in this
/// table are the ADDITIONAL wings only. Every wing pointer ('' on
/// `container`/`tag`/`reading`/`shelf`) means Home when empty — undeletable
/// and convergence-proof by construction, with no seeded row to race.
/// Duplicate wing names are legal (no natural key — no repair class).
public struct Wing: VariorumRecord {
    public static let databaseTableName = "wing"

    public var id: String
    public var ownerId: String?
    public var name: String
    /// Switcher order — fractional index (§6's convention).
    public var position: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        name: String,
        position: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.position = position
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
