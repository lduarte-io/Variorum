import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-816 (the VX-878 run, batch 3 — the record
// `notes/plans/fixes/vx-878-book-doors-faces.md`, BATCH 3 RECORD): THE BOOK-NAME
// GUARD CHECKS THE TARGET'S WING. The agent's report (via her, 2026-11-04):
// "Book names are unique across all wings. 'posted' in writing was refused because
// PlanetLillian has 'Posted'." Wings isolate totally (the tag vocabulary is already
// per-wing — `uq_tag_path_live` keys on `(wing_id, path)`), so the one predicate
// (`requireBookNameFree`) counts only the readings in the wing the book is minted
// in, or the renamed book's own — as surfaces read wings (a reading whose wing died
// is Home's). Everything else holds: the case fold, the archived/deleted skips,
// `excluding`, VX-259's `counting`.
//
// RED ON OLD, per door: every pin here calls an API that stands on both sides of
// the fix (the rename form of the guard, `importBook`, the wire's `createBook`,
// `createGatheringForClient` and `renameBookForClient`), so the pre-fix tree runs
// them: each "another wing's name passes" arm refused `duplicateBookName` there.

@Suite("VX-816 — the book-name guard checks only the target's wing")
struct BookNameGuardPerWingTests {
    private func book(_ name: String) throws -> VariorumDocument.Book {
        let one = VariorumDocument.NamedDocument(
            fallbackTitle: "", document: try VariorumDocument.parse("{t:\"one\"}\n\nOne."))
        return VariorumDocument.Book(name: name, chapters: [], unfiled: [one])
    }

    /// Her rename doors (`excluding:` — the renamed book's own wing): a name
    /// another WING's book wears is free; one a book of the same wing wears is
    /// taken, named back in its stored casing.
    @Test func theRenameFormChecksOnlyTheBooksOwnWing() throws {
        try withOperations { ops, _ in
            let planet = try ops.createWing(name: "PlanetLillian")
            _ = try ops.createReading(name: "Posted", kind: .book, wingId: planet.id)
            let writing = try ops.createReading(name: "drafts", kind: .book)
            _ = try ops.createReading(name: "Letters", kind: .book)

            try ops.assertBookNameIsFree("posted", excluding: writing.id)  // RED ON OLD: refused "Posted"
            #expect(throws: OperationError.duplicateBookName(name: "Letters")) {
                try ops.assertBookNameIsFree("letters", excluding: writing.id)
            }
            // And from inside the other wing, its own book's name is taken.
            let neighbour = try ops.createReading(name: "notes", kind: .book, wingId: planet.id)
            #expect(throws: OperationError.duplicateBookName(name: "Posted")) {
                try ops.assertBookNameIsFree("POSTED", excluding: neighbour.id)
            }
        }
    }

    /// Her folder import's in-transaction guard (`importBook` — the wing it
    /// imports into): another wing's name lands; the same wing's refuses.
    @Test func theBookImportChecksOnlyItsWing() throws {
        try withOperations { ops, _ in
            let planet = try ops.createWing(name: "PlanetLillian")
            _ = try ops.createReading(name: "Posted", kind: .book, wingId: planet.id)
            _ = try ops.createReading(name: "Letters", kind: .book)

            let landed = try ops.importBook(try book("posted"), wingId: "")  // RED ON OLD: refused "Posted"
            #expect(landed.reading.name == "posted" && landed.reading.wingId == "")
            #expect(throws: OperationError.duplicateBookName(name: "Letters")) {
                try ops.importBook(try book("letters"), wingId: "")
            }
            #expect(throws: OperationError.duplicateBookName(name: "Posted")) {
                try ops.importBook(try book("POSTED"), wingId: planet.id)
            }
        }
    }

    /// The wire's three mints and its rename (the ops under `create_book`,
    /// `create_gathering`, `rename_book`): the same rule, with nil `counting`
    /// (every reading of the wing counts) — the wire's reach filter composes
    /// on top (`MCPBookNameReachTests` / the socket suites).
    @Test func theWiresMintsAndRenameCheckOnlyTheirWing() throws {
        try withOperations { ops, _ in
            let planet = try ops.createWing(name: "PlanetLillian")
            _ = try ops.createReading(name: "Posted", kind: .book, wingId: planet.id)
            _ = try ops.createReading(name: "Ledger", kind: .book, wingId: planet.id)
            _ = try ops.createReading(name: "Letters", kind: .book)

            let made = try ops.createBook(named: "posted", inWing: "", undoLabel: "x")  // RED ON OLD
            #expect(made.name == "posted")
            #expect(throws: OperationError.duplicateBookName(name: "Posted")) {
                try ops.createBook(named: "Posted", inWing: planet.id, undoLabel: "x")
            }
            let gathered = try ops.createGatheringForClient(
                named: "LEDGER ", inWing: "", rule: .star, undoLabel: "x")  // RED ON OLD
            #expect(gathered.gathering.name == "LEDGER")
            #expect(throws: OperationError.duplicateBookName(name: "Letters")) {
                try ops.createGatheringForClient(named: "letters", inWing: "", rule: .star, undoLabel: "x")
            }

            let drafts = try ops.createReading(name: "drafts", kind: .book, wingId: planet.id)
            #expect(throws: OperationError.duplicateBookName(name: "Posted")) {
                try ops.renameBookForClient(drafts.id, name: "posted", undoLabel: "x")
            }
            let renamed = try ops.renameBookForClient(drafts.id, name: "letters", undoLabel: "x")  // RED ON OLD
            #expect(renamed.changed && renamed.name == "letters")
        }
    }

    /// **As surfaces read wings:** a reading whose wing died reads as Home's
    /// (R-13ia-2's dangling rule — `Queries.wingScope`), so its name is taken
    /// in Home and free in every live wing. (The Home arm is green on both
    /// trees — the old guard counted every reading; the live-wing arm is RED
    /// ON OLD.)
    @Test func aBookWhoseWingDiedCountsAsHomes() throws {
        try withOperations { ops, db in
            let attic = try ops.createWing(name: "Attic")
            _ = try ops.createReading(name: "Orphan", kind: .book, wingId: attic.id)
            // A wing deletes only empty — the dangling pointer is a sync race's
            // (another device's book landed in a wing this one deleted).
            try db.write { db in
                try db.execute(sql: "UPDATE wing SET deleted_at = ? WHERE id = ?",
                               arguments: ["2026-07-01T00:00:00.000Z", attic.id])
            }
            let studio = try ops.createWing(name: "Studio")
            #expect(throws: OperationError.duplicateBookName(name: "Orphan")) {
                try ops.importBook(try book("orphan"), wingId: "")
            }
            let landed = try ops.importBook(try book("orphan"), wingId: studio.id)  // RED ON OLD
            #expect(landed.reading.name == "orphan")
        }
    }

    /// Unchanged, said here so the per-wing scope can't quietly widen them: an
    /// ARCHIVED book of the same wing never counts (her "archived/deleted books
    /// don't count"), and the wing-move preview's `nameTakenBy` was already the
    /// destination wing's alone (VX-807's `same_name_in_wing`).
    @Test func theArchivedSkipAndTheWingMovePreviewHold() throws {
        try withOperations { ops, db in
            let planet = try ops.createWing(name: "PlanetLillian")
            let archived = try ops.createReading(name: "Kept", kind: .book)
            try ops.archiveReading(archived.id)
            _ = try ops.createBook(named: "kept", inWing: "", undoLabel: "x")

            let traveler = try ops.createReading(name: "Traveler", kind: .book)
            _ = try ops.createReading(name: "traveler", kind: .book, wingId: planet.id)
            let preview = try db.read { try Queries.bookWingMovePreview($0, readingID: traveler.id, to: planet.id) }
            #expect(preview?.nameTakenBy == "traveler", "the destination wing's twin, named")
            let home = try db.read { try Queries.bookWingMovePreview($0, readingID: traveler.id, to: "") }
            #expect(home?.nameTakenBy == nil, "the book's own row never counts")
        }
    }
}
