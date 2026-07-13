import Foundation
import GRDB

/// A saved way of looking at one post (Phase 11, v1_7 — the kickoff spike's
/// author-confirmed SAVED LENSES): a durable, named, SYNCED selection
/// profile. The governing frame, in her ratified words: *"a lens is the
/// same structure with different choices; a version is a different
/// structure; promote is the bridge."*
///
/// A lens is NEVER rendering truth — exports, the bridge, book views, and
/// every other surface read `container_block.chosen_variant_id` (I3);
/// ✓/adopt gestures are the only doors from lens to chosen. Choices are
/// sparse (`LensChoice` rows exist only where the lens diverges from
/// chosen); the EMPTY lens is legal — the transparent new-thread default.
public struct Lens: VariorumRecord {
    public static let databaseTableName = "lens"

    public var id: String
    public var ownerId: String?
    /// The post this lens views (kind 'post' — enforced in operations).
    public var containerId: String
    public var name: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        containerId: String,
        name: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.containerId = containerId
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}

/// One sparse override: "through this lens, this block shows THAT take."
/// At most one live row per (lens, block); `variantId` is CAS metadata —
/// a dangling pick (variant since tombstoned/archived) falls through to
/// the slot's ordinary resolution at read time (the chosen-variant
/// fallback class, AppSpec §7).
public struct LensChoice: VariorumRecord {
    public static let databaseTableName = "lens_choice"

    public var id: String
    public var lensId: String
    public var blockId: String
    public var variantId: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        lensId: String,
        blockId: String,
        variantId: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.lensId = lensId
        self.blockId = blockId
        self.variantId = variantId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
