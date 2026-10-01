import Foundation
import GRDB

// THE STARRED-NOTES GATHERING (13i-b U4 — the sitting record §3: the master
// plan's "smart book of starred notes" becomes "a gathering of starred notes",
// same build-at-13i instruction, new noun; the 13i-b plan §4).
//
// It is an ORDINARY gathering — the Quicknotes shape §20 ratified: rule
// `{"star":true}`, no special identity, no delete guard, UNSHELVED (§19.3's
// working-objects rule — like the Journal and Quicknotes, it is hers to use,
// not a sample), re-makeable by hand in one gesture (a gathering on ★ is the
// whole of it). Being derived, it shows a note the moment she stars it and
// lets it go the moment she un-stars it — the ★ term's context (`StarContext`)
// is what the assembly reads, so nothing here maintains any state.
//
// The only thing this file adds is the SEED: one silent ensure, the seeded
// books' discipline (`SampleLibrarySeeder` — discovery, the reader's deletion
// honoured, never a throw), minus everything a one-row seed does not need.
// WHEN it runs — and the per-device mark that makes "seeded once" survive a
// purge — is the app's (`Shared/StarredGatheringSeeder`), exactly as the
// sample library's occasion is.
extension Operations {
    /// The seeded gathering's name (PROVISIONAL P-13ib-4 — one constant;
    /// lowercase, the quiet vocabulary of her working surfaces).
    public static let starredNotesGatheringName = "starred notes"

    /// What the ensure did. Every case is a real outcome and none throws:
    /// furniture must never be able to break a launch.
    public enum StarredGatheringEnsure: Equatable, Sendable {
        /// Minted now — a fresh store, or an existing one meeting it for the
        /// first time.
        case minted(readingID: String)
        /// Already here: a live Home reading whose rule is exactly `★` (hers
        /// made by hand counts — it IS the thing; a BOUND one counts — the
        /// bind keeps the row), or one wearing the reserved name (never a
        /// second same-named row — E13's sense).
        case alreadyPresent(readingID: String)
        /// She deleted it: a TOMBSTONED Home reading of that rule or that
        /// name is on record (the `readingTombstoneExists` class — any age,
        /// made here or arrived by sync). Nothing minted, ever.
        case deletedByTheReader
        /// The store said no. A short phrase, never surfaced.
        case refused(String)
    }

    /// **THE SILENT ENSURE.** ONE write transaction, so discovery and mint
    /// cannot interleave with another writer on this device (GRDB serializes
    /// writers — two launches' tasks cannot mint two). Two DEVICES seeding
    /// before either syncs is the app occasion's sync gate's job, and its
    /// residue (two ordinary gatherings, harmless — a gathering holds
    /// nothing) is recorded in the 13i-b U4 record, not repaired (zero
    /// `Sync/`).
    ///
    /// Scoped to the HOME wing (`wing_id = ''`): Home holds her working
    /// objects; another wing is a separate library she makes.
    @discardableResult
    public func ensureStarredNotesGathering() -> StarredGatheringEnsure {
        do {
            return try database.write { db -> StarredGatheringEnsure in
                if let present = try Self.starredGatheringRow(db, live: true) {
                    return .alreadyPresent(readingID: present)
                }
                if try Self.starredGatheringRow(db, live: false) != nil {
                    return .deletedByTheReader
                }
                let now = date.now
                let gathering = Reading(
                    id: newID(), ownerId: currentOwnerID(),
                    name: Self.starredNotesGatheringName, kind: .gathering,
                    // Quicknotes' own shape (its sibling seeded gathering):
                    // the plain-collection profile, newest first.
                    profile: "collection", sortField: .createdAt, sortDir: .desc,
                    querySpec: try RuleGrammar.encode(.star),
                    wingId: "",
                    createdAt: now, updatedAt: now)
                try gathering.insert(db)
                return .minted(readingID: gathering.id)
            }
        } catch {
            return .refused(String(describing: error))
        }
    }

    /// The seeded gathering's SIGNATURE, live or tombstoned: a Home reading
    /// whose rule is exactly `★`, or whose name is the reserved one under
    /// E13's rule (`BookNaming` — ends-trimmed, case-folded). Smallest id
    /// first (deterministic). Cost ∝ the Home wing's readings — a shelf,
    /// never a corpus.
    static func starredGatheringRow(_ db: Database, live: Bool) throws -> String? {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT id, name, query_spec FROM reading
                WHERE wing_id = '' AND deleted_at IS \(live ? "NULL" : "NOT NULL")
                ORDER BY id
                """)
        return rows.first { row in
            let name: String = row["name"]
            let spec: String? = row["query_spec"]
            return RuleGrammar.read(spec) == .rule(.star)
                || BookNaming.sameName(name, starredNotesGatheringName)
        }.map { $0["id"] as String }
    }
}
