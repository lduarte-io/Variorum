import Dependencies
import Foundation
import GRDB

// WINGS — the operations (13i-d U5; the sitting record §9, §21; her kickoff
// rulings R-13id-2 and R-13id-4; F-U5-1: 13i-a shipped the table, the four
// `wing_id` columns and the `Wing` record — no operation existed).
//
// A wing is a separate library in the same store ("a different room in the
// same house"). HOME IS VIRTUAL (R-13ia-2): `''` everywhere, no row — so every
// op here refuses Home (`wingNotFound`): it cannot be renamed or deleted.
//
// The standing conventions, applied:
// - **Identity-level metadata** (the shelf ops' convention): no touch stamp,
//   no churn; a write that changes nothing writes nothing.
// - **Duplicate names are legal at the op** (the schema's no-natural-key
//   letter — two devices may mint the same name offline, and there is no
//   repair class); the DOORS refuse a taken name through
//   `assertWingNameIsFree` (E13's door-guard precedent, PROVISIONAL
//   P-13id-U5-1).
// - **No undo entries, no Trash for wings** (the shelf precedent): a wing can
//   only be deleted EMPTY (R-13id-2), so there is nothing to recover.
extension Operations {
    // MARK: - Mint · rename · delete

    /// A new wing at the END of the switcher's order. Blank refuses.
    @discardableResult
    public func createWing(name: String) throws -> Wing {
        try database.write { db in
            // VX-357: U+0000 removed first (`StoredText`), then the trim.
            let trimmed = StoredText.stripped(name).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { throw OperationError.invalidWingName(name: name) }
            let last = try String.fetchOne(
                db, sql: "SELECT MAX(position) FROM wing WHERE deleted_at IS NULL")
            let now = date.now
            let wing = Wing(
                id: newID(), ownerId: currentOwnerID(), name: trimmed,
                position: FractionalIndex.between(last, nil),
                createdAt: now, updatedAt: now)
            try wing.insert(db)
            return wing
        }
    }

    /// Retitle an additional wing. Home refuses (`wingNotFound` — it has no
    /// row to rename; renaming Home was never ruled, the 13i-a §1 note).
    public func renameWing(_ id: String, to name: String) throws {
        try database.write { db in
            var wing = try liveWingRow(db, id)
            let trimmed = StoredText.stripped(name).trimmingCharacters(in: .whitespacesAndNewlines)  // VX-357
            guard !trimmed.isEmpty else { throw OperationError.invalidWingName(name: name) }
            guard wing.name != trimmed else { return }
            wing.name = trimmed
            wing.updatedAt = date.now
            try wing.update(db)
        }
    }

    /// **DELETE WING — refuses unless empty** (her R-13id-2, verbatim-faithful:
    /// "Delete Wing refuses while the wing holds any live note, book or tag,
    /// NAMING what remains … Nothing destroyed, no new recovery machinery;
    /// emptying the wing is the deliberate act"). The refusal carries
    /// `Queries.wingContents` — the SAME read the confirm shows.
    ///
    /// On an empty wing: the wing row AND its live shelves tombstone on ONE
    /// stamp (shelves are metadata a pointer names — never Trash objects,
    /// §18.3 — and a wing's shelves can hold nothing once its books are gone).
    /// The wing's TRASH rows (notes/books deleted inside it, still within the
    /// window) are left as they are: they read as HOME's from now on (the
    /// dangling-wing rule, `Queries.wingScope`) and a Put back re-homes them.
    public func deleteWing(_ id: String) throws {
        try database.write { db in
            var wing = try liveWingRow(db, id)
            let contents = try Queries.wingContents(db, wingID: id)
            guard contents.isEmpty else {
                throw OperationError.wingNotEmpty(id: id, contents: contents)
            }
            let now = date.now
            let stamp = DateFormatter.variorumISO8601.string(from: now)
            try db.execute(
                sql: """
                    UPDATE shelf SET deleted_at = ?, updated_at = ?
                    WHERE wing_id = ? AND deleted_at IS NULL
                    """,
                arguments: [stamp, stamp, id])
            wing.deletedAt = now
            wing.updatedAt = now
            try wing.update(db)
        }
    }

    /// **THE WING-NAME DOOR GUARD** (E13's shape, `assertBookNameIsFree`'s
    /// sibling — PROVISIONAL P-13id-U5-1): throws `duplicateWingName` when a
    /// LIVE wing — or Home, the built-in's name — already wears this name
    /// (ends-trimmed, case-folded — `BookNaming`'s key, the one rule).
    /// `excluding` is the RENAME door's own row. A read a door calls BEFORE
    /// it mints; the ops stay permissive (the offline race is legal).
    public func assertWingNameIsFree(
        _ name: String, excluding wingID: String? = nil, homeName: String = "Home"
    ) throws {
        let key = BookNaming.key(name)
        if key == BookNaming.key(homeName) {
            throw OperationError.duplicateWingName(name: homeName)
        }
        try database.read { db in
            for wing in try Queries.wings(db) where wing.id != wingID {
                if BookNaming.key(wing.name) == key {
                    throw OperationError.duplicateWingName(name: wing.name)
                }
            }
        }
    }

    // MARK: - Internals

    /// A live ADDITIONAL wing's row. Home (`''`) has none, so every op that
    /// needs one refuses it — Home is undeletable and unrenamable by
    /// construction (R-13ia-2).
    func liveWingRow(_ db: Database, _ id: String) throws -> Wing {
        guard !id.isEmpty, let wing = try Queries.liveWing(db, id: id) else {
            throw OperationError.wingNotFound(id: id)
        }
        return wing
    }
}
