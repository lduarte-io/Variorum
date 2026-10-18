import Dependencies
import Foundation
import GRDB

// THE BOOKCASE'S SHELVES (13i-d U1 — the sitting record §7, §19, §20, §24;
// the 13i-d plan's U1 brief). A shelf is `reading_section` one level up: an
// ordered, named metadata row a pointer names (`reading.shelf_id`) — never a
// container, never nested, per-wing. 13i-a landed the table, the four
// `reading` columns and the R5 Welcome keeper; these are the operations the
// board drives (F-U1-1: none existed).
//
// The standing conventions, applied:
// - **Identity-level metadata** (the `setShelfPinned` / `setBlockName`
//   convention): no touch stamp, no churn, and a write that changes nothing
//   writes nothing (no outbox row).
// - **A shelf never touches a book.** Deleting one tombstones the shelf row
//   alone; its books keep their now-DANGLING pointer, which reads as
//   UNSHELVED (§19's ruling). Shelves are not Trash objects (§18.3) — cheap
//   metadata, no restore door, no undo entry (the chapter-delete precedent).
// - **Shelving is presentation, not assembly** — a finished or sealed book
//   may be re-shelved and re-ordered like any other (the freeze binds the
//   table of contents, §5; where a book sits on the bookcase is not that).
// - **Wings are separate libraries** (§9): a shelf belongs to one wing and
//   holds only that wing's books.
extension Operations {
    // MARK: - Shelves

    /// A new shelf at the END of the wing's strip (the strip's left-to-right
    /// IS All's top-to-bottom, §24). Duplicate names are legal.
    @discardableResult
    public func createShelf(name: String, wingID: String = "") throws -> Shelf {
        try database.write { db in
            // VX-357: U+0000 removed first (`StoredText`), then the trim.
            let trimmed = StoredText.stripped(name).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { throw OperationError.invalidShelfName(name: name) }
            try requireLiveWing(db, wingID)
            let now = date.now
            let shelf = Shelf(
                id: newID(), ownerId: currentOwnerID(), wingId: wingID, name: trimmed,
                position: try shelfPosition(db, wingID: wingID, at: .end),
                createdAt: now, updatedAt: now)
            try shelf.insert(db)
            return shelf
        }
    }

    /// Retitle a shelf (Welcome included — it is ordinary and renamable,
    /// §17(a); the keeper keys on its `role`, never its name).
    public func renameShelf(_ id: String, to name: String) throws {
        try database.write { db in
            var shelf = try liveShelf(db, id)
            let trimmed = StoredText.stripped(name).trimmingCharacters(in: .whitespacesAndNewlines)  // VX-357
            guard !trimmed.isEmpty else { throw OperationError.invalidShelfName(name: name) }
            guard shelf.name != trimmed else { return }
            shelf.name = trimmed
            shelf.updatedAt = date.now
            try shelf.update(db)
        }
    }

    /// Set (or, with nil/blank, clear) the shelf's glyph — ONE grapheme, no
    /// emoji (`ShelfGlyph.normalize`, the sheet's own live check).
    public func setShelfGlyph(_ id: String, glyph: String?) throws {
        try database.write { db in
            var shelf = try liveShelf(db, id)
            let normalized = ShelfGlyph.normalize(StoredText.stripped(glyph))  // VX-357
            guard normalized.valid else {
                throw OperationError.invalidShelfGlyph(value: glyph ?? "")
            }
            guard shelf.glyph != normalized.glyph else { return }
            shelf.glyph = normalized.glyph
            shelf.updatedAt = date.now
            try shelf.update(db)
        }
    }

    /// Tombstone the shelf. Its books are NOT rewritten: their pointers
    /// dangle and read as unshelved (§19 — "deleting a shelf returns its
    /// books to UNSHELVED"). Their `shelf_position`s stay too; they join the
    /// unshelved run's one sequence by their keys, which is deterministic.
    public func deleteShelf(_ id: String) throws {
        try database.write { db in
            var shelf = try liveShelf(db, id)
            let now = date.now
            shelf.deletedAt = now
            shelf.updatedAt = now
            try shelf.update(db)
        }
    }

    /// Move a shelf in its wing's strip (drag a name, or the right-click's
    /// Move to Start / Move to End — §24). An anchor must be a live shelf of
    /// the SAME wing.
    public func moveShelf(_ id: String, to insert: InsertPosition) throws {
        try database.write { db in
            var shelf = try liveShelf(db, id)
            switch insert {
            case .before(let anchor), .after(let anchor):
                guard anchor != id else { return }
                let other = try liveShelf(db, anchor)
                guard other.wingId == shelf.wingId else {
                    throw OperationError.shelfNotFound(id: anchor)
                }
            case .start, .end:
                break
            }
            let position = try shelfPosition(db, wingID: shelf.wingId, at: insert)
            shelf.position = position
            shelf.updatedAt = date.now
            try shelf.update(db)
        }
    }

    // MARK: - The Welcome shelf (13i-d U7 — F-U1-3; the sitting record §7/§17(a)/§19)

    /// The seeded shelf's name — "it's literally a welcome to the app,
    /// designed to make you feel comfortable" (her §7 ruling). Ordinary and
    /// renamable: identity is the ROLE below, never this name.
    public static let welcomeShelfName = "Welcome"

    /// The seed marker the R5 Welcome keeper (`Sync/Repairs.swift`,
    /// `convergeWelcomeShelves`) converges on — the ONE key a seeder writes.
    public static let welcomeShelfRole = "welcome"

    /// What `ensureWelcomeShelf` found or made.
    public struct WelcomeShelfEnsure: Equatable, Sendable {
        public let shelf: Shelf
        /// True when this call minted it; false when it ADOPTED a live one.
        public let minted: Bool
    }

    /// **THE WELCOME SHELF, adopted or minted** (13i-d U7). ONE transaction:
    /// the wing's live `role='welcome'` shelf with the SMALLEST id is adopted
    /// — exactly the shelf the R5 keeper keeps when two devices' seeders
    /// raced (it keys on the role, never the name, and keeps the smallest
    /// id), so a restore door and a convergence always agree on which shelf
    /// is Welcome. Else one is minted: named "Welcome", `role='welcome'`, at
    /// the END of the wing's strip (on a fresh store the end IS the start).
    ///
    /// A shelf she named "Welcome" by hand carries no role and is never
    /// adopted — a name is hers, the role is the seed's. A tombstoned Welcome
    /// is not revived: shelves are not Trash objects (§18.3), so an explicit
    /// restore mints a fresh one. Identity-level metadata, like every shelf
    /// op: no undo entry, no touch. Zero `Sync/` — the keeper already exists
    /// and this only CONSUMES its key.
    @discardableResult
    public func ensureWelcomeShelf(wingID: String = "") throws -> WelcomeShelfEnsure {
        try database.write { db in
            try requireLiveWing(db, wingID)
            if let present = try Shelf.fetchOne(
                db,
                sql: """
                    SELECT * FROM shelf
                    WHERE wing_id = ? AND role = ? AND deleted_at IS NULL
                    ORDER BY id LIMIT 1
                    """,
                arguments: [wingID, Self.welcomeShelfRole])
            {
                return WelcomeShelfEnsure(shelf: present, minted: false)
            }
            let now = date.now
            let shelf = Shelf(
                id: newID(), ownerId: currentOwnerID(), wingId: wingID,
                name: Self.welcomeShelfName, role: Self.welcomeShelfRole,
                position: try shelfPosition(db, wingID: wingID, at: .end),
                createdAt: now, updatedAt: now)
            try shelf.insert(db)
            return WelcomeShelfEnsure(shelf: shelf, minted: true)
        }
    }

    // MARK: - Books on shelves

    /// Put a book (or a gathering — every shelf citizen) on a shelf, or take
    /// it off (`nil` = unshelved). The shelf must be live and in the book's
    /// own wing. The book arrives NEVER-PLACED in its new shelf's "my order"
    /// (its old key belonged to the old shelf's sequence) — so it appends at
    /// the end there (§24). A no-op writes nothing.
    public func setReadingShelf(_ readingID: String, shelf shelfID: String?) throws {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            if let shelfID {
                let shelf = try liveShelf(db, shelfID)
                guard shelf.wingId == reading.wingId else {
                    throw OperationError.shelfNotFound(id: shelfID)
                }
            }
            guard reading.shelfId != shelfID else { return }
            try db.execute(
                sql: "UPDATE reading SET shelf_id = ?, shelf_position = NULL WHERE id = ?",
                arguments: [shelfID, readingID])
        }
    }

    /// **"My order" — place a book by hand** (§20, §24): Send to Top, Send
    /// to Bottom, or immediately before another book of the SAME shelf (the
    /// drag). ONE position sequence per shelf; the star is never encoded
    /// (`BookcaseOrdering.placementWrites` carries the whole arithmetic,
    /// including the never-placed run's materialization). A placement that
    /// changes nothing writes nothing.
    public func placeReading(_ readingID: String, at placement: BookcaseOrdering.Placement) throws {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            let sequence = BookcaseOrdering.placementSequence(
                try shelfMates(db, of: reading))
            guard let writes = BookcaseOrdering.placementWrites(
                moving: readingID, in: sequence, to: placement)
            else {
                if case .before(let anchor) = placement {
                    throw OperationError.placementAnchorNotOnShelf(
                        readingID: readingID, anchorID: anchor)
                }
                return
            }
            for write in writes {
                try db.execute(
                    sql: "UPDATE reading SET shelf_position = ? WHERE id = ?",
                    arguments: [write.position, write.readingID])
            }
        }
    }

    // MARK: - Internals

    func liveShelf(_ db: Database, _ id: String) throws -> Shelf {
        guard let shelf = try Shelf.fetchOne(db, key: id), shelf.deletedAt == nil else {
            throw OperationError.shelfNotFound(id: id)
        }
        return shelf
    }

    /// '' (Home) is virtual and always live (R-13ia-2); any other id must
    /// name a live `wing` row.
    func requireLiveWing(_ db: Database, _ wingID: String) throws {
        guard !wingID.isEmpty else { return }
        let live = try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM wing WHERE id = ? AND deleted_at IS NULL)",
            arguments: [wingID]) ?? false
        guard live else { throw OperationError.wingNotFound(id: wingID) }
    }

    /// The live books that RESOLVE to the same shelf as `reading` in its
    /// wing — the one scope a hand placement orders within (the unshelved
    /// run is a scope too: every book whose pointer is nil or dangling).
    private func shelfMates(_ db: Database, of reading: Reading) throws -> [Reading] {
        let liveShelves = Set(try String.fetchAll(
            db,
            sql: "SELECT id FROM shelf WHERE wing_id = ? AND deleted_at IS NULL",
            arguments: [reading.wingId]))
        let home = BookcaseOrdering.resolvedShelf(of: reading, liveShelfIDs: liveShelves)
        return try Reading.fetchAll(
            db,
            sql: "SELECT * FROM reading WHERE wing_id = ? AND deleted_at IS NULL",
            arguments: [reading.wingId]
        ).filter {
            BookcaseOrdering.resolvedShelf(of: $0, liveShelfIDs: liveShelves) == home
        }
    }

    /// A `shelf.position` in a wing's live strip (the shared resolver —
    /// jittered fractional keys, sort `(position, id)`, no rebalance).
    private func shelfPosition(
        _ db: Database, wingID: String, at insert: InsertPosition
    ) throws -> String {
        try listPosition(
            db,
            in: OrderedList(
                table: "shelf", scopeColumn: "wing_id", anchorColumn: "id",
                missingAnchor: { OperationError.shelfNotFound(id: $0) }),
            scopeID: wingID, at: insert)
    }
}
