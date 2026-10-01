import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// 13i-a ladder R1 M-1: the v1_18 UPGRADE-PATH pins the plan owed — an old
// store (migrated upTo v1_17, seeded with pre-recast rows) runs the chain
// whole and every data migration's outcome is asserted. The pattern is the
// bridge-retirement test's (`theRetirementMigrationDropsTheBridgeTables…`).
// These are red-by-construction on the pre-13i tree (no v1_18 existed);
// their value is guarding the AUTHOR'S one-way door at the deploy window
// and every future refactor of the migration.
@Suite("v1_18 upgrade path (13i-a — the one-way door's pins)")
struct WingsMigrationTests {
    private static let now = "2026-09-30T00:00:00.000Z"

    /// An old-shape store at v1_17, seeded raw (the triggers are live, so
    /// outbox rows accrue; each test clears them pre-chain when it asserts
    /// enqueues).
    private func oldStore(_ seed: (Database) throws -> Void) throws -> DatabaseQueue {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_17_commit_created_index")
        try queue.write(seed)
        return queue
    }

    private func reading(
        _ db: Database, id: String, name: String, kind: String,
        profile: String? = nil, spec: String? = nil,
        syncVersion: Int = 0, deletedAt: String? = nil
    ) throws {
        try db.execute(
            sql: """
                INSERT INTO reading (id, name, kind, profile, query_spec,
                                     sync_version, deleted_at, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
            arguments: [id, name, kind, profile, spec, syncVersion, deletedAt,
                        Self.now, Self.now])
    }

    @Test func theKindRecastPreservesCASTombstonesAndStamps() throws {
        let queue = try oldStore { db in
            try reading(db, id: "A1", name: "hand-made", kind: "curated", syncVersion: 7)
            try reading(db, id: "A2", name: "collected", kind: "smart", syncVersion: 3)
            try reading(db, id: "A3", name: "gone", kind: "curated",
                        syncVersion: 5, deletedAt: "2026-09-01T00:00:00.000Z")
        }
        try AppDatabase.migrator.migrate(queue)
        let rows = try queue.read { db in
            try Row.fetchAll(
                db, sql: "SELECT id, kind, sync_version, deleted_at, updated_at FROM reading ORDER BY id")
        }
        #expect(rows.map { $0["kind"] as String } == ["book", "gathering", "book"])
        #expect(rows.map { $0["sync_version"] as Int } == [7, 3, 5],
                "the rebuild preserves the CAS tokens")
        #expect((rows[2]["deleted_at"] as String?) == "2026-09-01T00:00:00.000Z",
                "tombstones survive the rebuild")
        #expect(rows.allSatisfy { ($0["updated_at"] as String) == Self.now },
                "the recast is housekeeping — updated_at never moves (the Library must not resort)")
    }

    @Test func everyReadingRowIsExplicitlyEnqueuedTombstonedIncluded() throws {
        let queue = try oldStore { db in
            try reading(db, id: "B1", name: "live", kind: "curated")
            try reading(db, id: "B2", name: "dead", kind: "smart",
                        deletedAt: "2026-09-01T00:00:00.000Z")
            // The seed's own trigger rows would mask the migration's
            // explicit enqueue — clear before the chain runs.
            try db.execute(sql: "DELETE FROM sync_outbox")
        }
        try AppDatabase.migrator.migrate(queue)
        let enqueued = try queue.read { db in
            Set(try String.fetchAll(
                db, sql: "SELECT row_id FROM sync_outbox WHERE table_name = 'reading'"))
        }
        #expect(enqueued.isSuperset(of: ["B1", "B2"]),
                "the rebuild's copy fires no triggers — without the explicit enqueue the mirror never learns the recast")
    }

    @Test func pinnedLiveBooksBecomeStarredAndDeadPinsDoNot() throws {
        let queue = try oldStore { db in
            try reading(db, id: "C1", name: "pinned", kind: "curated")
            try reading(db, id: "C2", name: "pinned but dead", kind: "curated",
                        deletedAt: "2026-09-01T00:00:00.000Z")
            try reading(db, id: "C3", name: "unpinned", kind: "curated")
            try db.execute(
                sql: "INSERT INTO setting (key, value) VALUES ('shelf_pins', ?)",
                arguments: [#"["C1","C2"]"#])
        }
        try AppDatabase.migrator.migrate(queue)
        let starred = try queue.read { db in
            try Row.fetchAll(db, sql: "SELECT id, starred FROM reading ORDER BY id")
                .map { ($0["id"] as String, $0["starred"] as Int) }
        }
        #expect(starred.map(\.1) == [1, 0, 0],
                "live pins become stars; a dead pin and an unpinned book do not")
    }

    @Test func theDesignatedBookGainsTheDailyMarkerAndADeliberateNotebookDoesNot() throws {
        let queue = try oldStore { db in
            try reading(db, id: "D1", name: "Journal", kind: "curated", profile: "journal")
            try reading(db, id: "D2", name: "Dream Journal", kind: "curated", profile: "journal")
            try db.execute(
                sql: "INSERT INTO setting (key, value) VALUES ('daily_journal_book', 'D1')")
        }
        try AppDatabase.migrator.migrate(queue)
        let profiles = try queue.read { db in
            try Row.fetchAll(db, sql: "SELECT id, profile FROM reading ORDER BY id")
                .map { $0["profile"] as String }
        }
        #expect(profiles == ["daily", "journal"],
                "only the DESIGNATED book is the daily Journal; a deliberate notebook keeps the trait")
    }

    @Test func v1SpecsConvertToV2AndUndecodableBytesStayRaw() throws {
        let queue = try oldStore { db in
            try db.execute(
                sql: """
                    INSERT INTO tag (id, name, path, created_at, updated_at)
                    VALUES ('T-LIFE', 'life', 'life', ?, ?)
                    """,
                arguments: [Self.now, Self.now])
            try reading(db, id: "E1", name: "period", kind: "smart",
                        spec: #"{"profile":"journal","tags":["life"]}"#)
            try reading(db, id: "E2", name: "corrupt", kind: "smart", spec: "not json")
            try reading(db, id: "E3", name: "ghostly", kind: "smart",
                        spec: #"{"tags":["never-existed"]}"#)
        }
        try AppDatabase.migrator.migrate(queue)
        let specs = try queue.read { db in
            try Row.fetchAll(db, sql: "SELECT id, query_spec FROM reading ORDER BY id")
                .map { $0["query_spec"] as String? }
        }
        #expect(specs[0] == #"{"and":[{"profile":"journal"},{"tag":"T-LIFE"}]}"#,
                "the v1 shape converts exactly — the legacy profile term + the tag by ID")
        #expect(specs[1] == "not json",
                "undecodable bytes stay RAW (MIN-1 — the read side fails closed; never laundered to match-all)")
        #expect(specs[2] == #"{"tag":""}"#,
                "a path no row ever carried becomes the deliberate dead term")
    }

    /// Her 2026-10-01 ruling: journals read NEWEST FIRST — v1_19 flips
    /// existing mint-shaped daily/journal books and NEVER a hand-set order.
    @Test func mintShapedJournalsFlipToNewestFirstAndHandSetOrdersSurvive() throws {
        let queue = try oldStore { db in
            try db.execute(sql: """
                INSERT INTO reading (id, name, kind, profile, sort_field, sort_dir,
                                     created_at, updated_at)
                VALUES ('J1', 'Journal', 'curated', 'journal', 'entry_date', 'asc', ?, ?),
                       ('J2', 'By title on purpose', 'curated', 'journal', 'manual', 'asc', ?, ?),
                       ('J3', 'Already newest', 'curated', 'journal', 'entry_date', 'desc', ?, ?),
                       ('B1', 'plain book', 'curated', NULL, 'entry_date', 'asc', ?, ?)
                """, arguments: [Self.now, Self.now, Self.now, Self.now,
                                   Self.now, Self.now, Self.now, Self.now])
        }
        try AppDatabase.migrator.migrate(queue)
        let dirs = try queue.read { db in
            try Row.fetchAll(db, sql: "SELECT id, sort_dir FROM reading ORDER BY id")
                .map { $0["sort_dir"] as String }
        }
        #expect(dirs == ["asc", "desc", "asc", "desc"],
                "B1 (no trait) and J2 (hand-set field) untouched; J1 flips; J3 already there")
    }

    /// Ladder R1 B-2's pin, client half (red-on-old): a PRE-WINDOW mirror
    /// row arrives with EXPLICIT NULL in columns the local schema declares
    /// NOT NULL with a default (`to_jsonb` serves present nulls — Postgres
    /// never produces column ABSENCE) — it must land as the defaults, not
    /// abort the apply transaction.
    @Test func preWindowExplicitNullsLandAsTheDefaults() throws {
        let db = try AppDatabase.inMemory()
        try db.write { database in
            // The membership's book exists (her pre-window corpus has it);
            // the pin's subject is the NULLED new columns, not stragglers.
            try database.execute(
                sql: """
                    INSERT INTO reading (id, name, kind, created_at, updated_at)
                    VALUES ('SOME-BOOK', 'the book', 'book', ?, ?)
                    """,
                arguments: [Self.now, Self.now])
            let container = SyncRow(
                table: "container", rowID: "OLD-POST",
                columns: [
                    "id": .text("OLD-POST"), "owner_id": .null,
                    "kind": .text("post"), "title": .text("pre-window note"),
                    "profile": .null, "entry_date": .null, "locked": .integer(0),
                    "locked_at": .null, "floating_notes": .null,
                    "segmentation_default": .null, "last_touched_at": .null,
                    "last_major_revision_at": .null, "churn_accumulator": .real(0),
                    "baseline_length": .integer(0), "word_target": .null,
                    "wing_id": .null,  // the pre-window mirror's explicit null
                    "created_at": .text(Self.now), "updated_at": .text(Self.now),
                    "archived_at": .null, "deleted_at": .null,
                ], syncVersion: 4)
            try container.apply(database)
            let membership = SyncRow(
                table: "reading_post", rowID: "OLD-MEMBER",
                columns: [
                    "id": .text("OLD-MEMBER"), "reading_id": .text("SOME-BOOK"),
                    "post_id": .text("OLD-POST"), "position": .text("a1"),
                    "section_id": .null,
                    "status": .null,  // the pre-window mirror's explicit null
                    "created_at": .text(Self.now), "deleted_at": .null,
                ], syncVersion: 2)
            try membership.apply(database)
        }
        let landed = try db.read { database in
            (try String.fetchOne(
                database, sql: "SELECT wing_id FROM container WHERE id = 'OLD-POST'"),
             try String.fetchOne(
                database, sql: "SELECT status FROM reading_post WHERE id = 'OLD-MEMBER'"))
        }
        #expect(landed.0 == "", "the null lands as the virtual Home wing")
        #expect(landed.1 == "member",
                "the null lands as a member — a pre-status row was always a seated membership")
    }

    /// Ladder R1 M-3's pin (red-on-current before the fix): re-designation
    /// MOVES the 'daily' marker — the old bearer demotes to the trait, the
    /// designee gains the marker, and the keeper repair's candidate set
    /// names exactly the new designee.
    @Test func reDesignationMovesTheDailyMarker() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-09-30")
            guard case .shelved(let oldDaily) = ops.shelveInDailyJournalBook(entry.container.id)
            else { Issue.record("the mint did not shelve"); return }
            let next = try ops.createReading(
                name: "Journal Vol. II", kind: .book,
                profile: Queries.journalTraitProfile,
                sortField: .entryDate, sortDir: .asc)
            try ops.setDailyJournalBook(next.id)
            let profiles = try db.read { database in
                (try Queries.reading(database, id: oldDaily)?.profile,
                 try Queries.reading(database, id: next.id)?.profile)
            }
            #expect(profiles.0 == Queries.journalTraitProfile,
                    "the old daily demotes to the trait it was wearing")
            #expect(profiles.1 == Queries.dailyJournalBookProfile)
            #expect(try db.read { try Queries.dailyJournalBookCandidates($0) } == [next.id],
                    "the keeper repair's candidate set follows the designation — no stale bearer")
        }
    }
}
