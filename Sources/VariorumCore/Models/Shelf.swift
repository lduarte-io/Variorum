import Foundation
import GRDB

/// A shelf — the Bookcase's grouping (13i sitting record §7): mechanically
/// `reading_section` one level up — an ordered, named metadata row a pointer
/// names (`reading.shelf_id`), never a container, never nested. Books live
/// on exactly one shelf; a nil or DANGLING pointer means UNSHELVED (§19's
/// ruling — unshelved books show at the top of All under their own header,
/// in no shelf's solo view). Deleting a shelf returns its books to
/// unshelved and never touches a book. Duplicate names are legal (no
/// natural key); the one convergence class is the SEEDED Welcome shelf,
/// whose `role='welcome'` marker keys the §7 keeper repair (two devices'
/// seeders racing offline converge to one).
public struct Shelf: VariorumRecord {
    public static let databaseTableName = "shelf"

    public var id: String
    public var ownerId: String?
    /// '' = the virtual Home wing (R-13ia-2). Shelves are per-wing — the
    /// Bookcase is a wing's surface.
    public var wingId: String
    public var name: String
    /// Optional ONE-GRAPHEME monochrome glyph (record §7 — the callout
    /// frame's precedent; no emoji, no color). nil = none.
    public var glyph: String?
    /// nil | 'welcome' — the seed marker (the Welcome keeper repair's key).
    public var role: String?
    /// Strip order, left to right — which is also All's stacking order,
    /// top to bottom (§24's ruling). Fractional index.
    public var position: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        wingId: String = "",
        name: String,
        glyph: String? = nil,
        role: String? = nil,
        position: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.wingId = wingId
        self.name = name
        self.glyph = glyph
        self.role = role
        self.position = position
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
