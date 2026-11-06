import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-808 — THE ARRIVALS & PINS SCHEMA EVENT (v1_37, SyncSpec §12 lockstep
// marker 14 → 15; the run record `notes/plans/fixes/vx-808-arrivals-books.md`
// §5). Two additive nullable columns on `reading_post`: `arrival_provenance`
// (ENCRYPTED — the arrival's why, an AI-authored reason being prose) and
// `pinned_at` (PLAIN — a bare timestamp). No new §7 repair: both are CAS
// metadata, and the status-aware pair dedupe keeps the smaller id with ITS
// values riding (recorded, accepted — pinned below). Red on the pre-event tree
// by construction: neither column existed.

// MARK: - The migration, exact

@Suite("VX-808 — v1_37: the arrivals & pins columns arrive born NULL")
struct ArrivalsPinsMigrationTests {
    private static let stamp = "2026-11-05T00:00:00.000Z"

    /// Every column of `reading_post` as (name, type, notnull, default).
    private static func shape(_ db: Database) throws -> [String] {
        try Row.fetchAll(db, sql: "PRAGMA table_info(reading_post)").map { row in
            let name: String = row["name"]
            let type: String = row["type"]
            let notNull: Int = row["notnull"]
            let dflt: String? = row["dflt_value"]
            return "\(name):\(type):\(notNull):\(dflt ?? "nil")"
        }
    }

    /// The table's indexes and triggers, by name and SQL.
    private static func machinery(_ db: Database) throws -> [String] {
        try Row.fetchAll(
            db, sql: """
                SELECT type, name, COALESCE(sql, '') AS sql FROM sqlite_master
                WHERE tbl_name = 'reading_post' AND type IN ('index', 'trigger')
                ORDER BY type, name
                """
        ).map { "\($0["type"] as String)|\($0["name"] as String)|\($0["sql"] as String)" }
    }

    /// Every row of `reading_post`, every column, canonical.
    private static func rows(_ db: Database, columns: [String]) throws -> [String] {
        try Row.fetchAll(
            db, sql: "SELECT \(columns.joined(separator: ", ")) FROM reading_post ORDER BY id"
        ).map { row in columns.map { "\($0)=\(String(describing: row[$0] as DatabaseValue))" }.joined(separator: "|") }
    }

    @Test func aFreshStoreCarriesBothColumnsNullableWithNoDefault() throws {
        let db = try AppDatabase.inMemory()
        try db.read { (db: Database) throws in
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(reading_post)")
            for name in ["arrival_provenance", "pinned_at"] {
                let column = try #require(columns.first { $0["name"] == name }, "\(name) exists")
                #expect(column["type"] == "TEXT")
                #expect(column["notnull"] == 0, "\(name) is nullable")
                #expect((column["dflt_value"] as String?) == nil, "\(name) has no default — NULL means absent")
            }
        }
        // A membership minted through the ordinary door is born with both NULL.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "a note", profile: .generic)
            let book = try ops.createReading(name: "a book", kind: .book)
            _ = try ops.addPostToReading(post.id, to: book.id)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM reading_post
                WHERE reading_id = ? AND post_id = ? AND arrival_provenance IS NULL AND pinned_at IS NULL
                """, [book.id, post.id]) == 1)
        }
    }

    /// The exact state transition: a store at v1_36 holding a member, an
    /// arrival and a tombstoned dismissal record migrates to v1_37 — every
    /// pre-existing column of every row byte-identical, both new columns
    /// NULL, `sync_version` untouched, the outbox untouched (a bare ADD
    /// COLUMN writes no row), and the table's indexes and triggers the same.
    @Test func aMigratedStoreGainsBothColumnsNullAndNothingElseMoves() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_36_fk_child_indexes")
        let s = Self.stamp
        try queue.write { db in
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at) VALUES
                  ('n1', 'post', 'one', '\(s)', '\(s)'),
                  ('n2', 'post', 'two', '\(s)', '\(s)'),
                  ('n3', 'post', 'three', '\(s)', '\(s)');
                INSERT INTO reading (id, name, kind, created_at, updated_at)
                  VALUES ('r1', 'a book', 'book', '\(s)', '\(s)');
                INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at, sync_version)
                  VALUES ('m1', 'r1', 'n1', 'a0', 'member', '\(s)', 3);
                INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                  VALUES ('w1', 'r1', 'n2', 'a1', 'arrival', '\(s)');
                INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at, deleted_at)
                  VALUES ('d1', 'r1', 'n3', 'a2', 'arrival', '\(s)', '\(s)');
                """)
        }
        let oldColumns = try queue.read { db in
            try Row.fetchAll(db, sql: "PRAGMA table_info(reading_post)").map { $0["name"] as String }
        }
        #expect(!oldColumns.contains("arrival_provenance") && !oldColumns.contains("pinned_at"),
                "red on the pre-event tree: neither column existed")
        let (before, outboxBefore, machineryBefore) = try queue.read { db in
            (try Self.rows(db, columns: oldColumns),
             try String.fetchAll(db, sql: "SELECT table_name || '/' || row_id FROM sync_outbox ORDER BY 1"),
             try Self.machinery(db))
        }

        try AppDatabase.migrator.migrate(queue)

        try queue.read { (db: Database) throws in
            #expect(try Self.rows(db, columns: oldColumns) == before, "every pre-existing value byte-identical")
            #expect(try Int.fetchOne(
                db, sql: "SELECT COUNT(*) FROM reading_post WHERE arrival_provenance IS NULL AND pinned_at IS NULL")
                == 3, "both columns arrive NULL on every row, live and dead")
            #expect(try String.fetchAll(db, sql: "SELECT table_name || '/' || row_id FROM sync_outbox ORDER BY 1")
                    == outboxBefore, "the migration writes no row — nothing new to push")
            #expect(try Self.machinery(db) == machineryBefore, "no index or trigger on the table moved")
        }
    }

    /// A fresh store and a migrated store agree on the table's whole shape —
    /// columns, types, nullability, defaults, indexes and triggers.
    @Test func aFreshStoreAndAMigratedStoreAgree() throws {
        let migrated = try DatabaseQueue()
        try AppDatabase.migrator.migrate(migrated, upTo: "v1_36_fk_child_indexes")
        try migrated.write { db in
            try db.execute(sql: """
                INSERT INTO container (id, kind, created_at, updated_at)
                  VALUES ('n1', 'post', '\(Self.stamp)', '\(Self.stamp)');
                INSERT INTO reading (id, name, kind, created_at, updated_at)
                  VALUES ('r1', 'a book', 'book', '\(Self.stamp)', '\(Self.stamp)');
                INSERT INTO reading_post (id, reading_id, post_id, position, created_at)
                  VALUES ('m1', 'r1', 'n1', 'a0', '\(Self.stamp)');
                """)
        }
        try AppDatabase.migrator.migrate(migrated)
        let fresh = try AppDatabase.inMemory()
        let freshShape = try fresh.read { try (Self.shape($0), Self.machinery($0)) }
        let migratedShape = try migrated.read { try (Self.shape($0), Self.machinery($0)) }
        #expect(freshShape.0 == migratedShape.0)
        #expect(freshShape.1 == migratedShape.1)
        #expect(freshShape.0.contains("arrival_provenance:TEXT:0:nil"))
        #expect(freshShape.0.contains("pinned_at:TEXT:0:nil"))
        // The event moves the marker, and only to the next value.
        #expect(SyncSchema.lockstepVersion == 15)
    }
}

// MARK: - Under sync: the columns travel, the provenance seals

@Suite("VX-808 — v1_37 under sync: the provenance travels sealed, the pin plain")
struct ArrivalsPinsSyncTests {
    private static let provenance =
        #"{"kind":"proposed","client":"Claude","reason":"it belongs with the harbour notes"}"#

    /// A book with one member and one waiting note, synced to both devices.
    private func sharedBook(
        _ a: SyncClient, _ b: SyncClient, server: FakeSyncServer
    ) async throws -> (book: String, member: String, waiting: String) {
        let ids = try a.with { ops, _ in
            let member = try ops.createPost(title: "a member", profile: .generic)
            let waiting = try ops.createPost(title: "a waiting note", profile: .generic)
            let book = try ops.createReading(name: "the book", kind: .book)
            _ = try ops.addPostToReading(member.id, to: book.id)
            return (book.id, member.id, waiting.id)
        }
        try await syncToQuiescence(a, b, server: server)
        return (ids.0, ids.1, ids.2)
    }

    /// One device writes an arrival's provenance and pins a membership (raw
    /// row writes — the doors arrive at B2/B4); the mirror stores the
    /// provenance ONLY as `e1:` ciphertext and the pin as its bare stamp; the
    /// other device reads both back byte-exact.
    @Test func theProvenanceSealsOnTheWireAndBothRoundTripByteExact() async throws {
        let (a, b, server) = try furniturePair()
        let world = try await sharedBook(a, b, server: server)
        let pin = "2026-11-05T12:00:00.000Z"
        try a.with { _, db in
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status,
                                                  created_at, arrival_provenance)
                        VALUES ('0AA00000-0000-4000-8000-000000000001', ?, ?, 'z0', 'arrival',
                                '2026-11-05T00:00:00.000Z', ?)
                        """,
                    arguments: [world.book, world.waiting, Self.provenance])
                try db.execute(
                    sql: "UPDATE reading_post SET pinned_at = ? WHERE reading_id = ? AND post_id = ?",
                    arguments: [pin, world.book, world.member])
            }
        }
        try await a.push()
        let stored = try #require(await server.currentRow(
            table: "reading_post", rowID: "0AA00000-0000-4000-8000-000000000001"))
        guard case .text(let sealed) = stored.columns["arrival_provenance"] else {
            Issue.record("the mirror must store the provenance")
            return
        }
        #expect(PayloadCipher.isEncrypted(sealed), "ENCRYPTED: the mirror holds ciphertext only")
        #expect(!sealed.contains("harbour") && !sealed.contains("Claude"), "never the words, nor the client")
        let memberRowID = try #require(try a.db.fetchString(
            "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ?", [world.book, world.member]))
        let storedMember = try #require(await server.currentRow(table: "reading_post", rowID: memberRowID))
        #expect(storedMember.columns["pinned_at"] == .text(pin), "PLAIN: the pin travels as its bare stamp")
        #expect(storedMember.columns["arrival_provenance"] == .null, "a member row carries no provenance")

        try await b.pull()
        #expect(try b.db.fetchString(
            "SELECT arrival_provenance FROM reading_post WHERE id = '0AA00000-0000-4000-8000-000000000001'")
                == Self.provenance, "opened back to exactly her words")
        #expect(try b.db.fetchString("SELECT pinned_at FROM reading_post WHERE id = ?", [memberRowID]) == pin)
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
    }

    /// RECORDED, ACCEPTED (the run record §5): two devices propose the SAME
    /// pair offline with different provenances — the standing status-aware
    /// pair dedupe keeps the SMALLER id and its OWN provenance rides; the
    /// retired row dies carrying its own. No new repair class; the repair's
    /// tombstone is enqueued explicitly on each device that meets the pair.
    @Test func aProposeProposeCollisionKeepsTheSmallerIdsProvenance() async throws {
        let (a, b, server) = try furniturePair()
        let world = try await sharedBook(a, b, server: server)
        let kept = "0A000000-0000-4000-8000-0000000000A1"
        let retired = "0B000000-0000-4000-8000-0000000000B1"
        for (client, id, words) in [(a, kept, "A's reason"), (b, retired, "B's reason")] {
            try client.with { _, db in
                try db.write { db in
                    try db.execute(
                        sql: """
                            INSERT INTO reading_post (id, reading_id, post_id, position, status,
                                                      created_at, arrival_provenance)
                            VALUES (?, ?, ?, 'z0', 'arrival', '2026-11-05T00:00:00.000Z', ?)
                            """,
                        arguments: [id, world.book, world.waiting,
                                    #"{"kind":"proposed","client":"Claude","reason":"\#(words)"}"#])
                }
            }
        }
        try await a.push()
        try await b.push()   // a different PK: accepted as its own row
        let pulledA = try await a.pull()   // A meets B's row: the incoming larger id retires
        #expect(pulledA.applied > 0)
        #expect(try a.db.deletedAt("reading_post", retired) != nil)
        #expect(try a.outboxContains("reading_post", retired), "the repair's tombstone pushes")
        try await b.pull()                  // B meets A's row: its own larger-id row retires
        #expect(try b.db.deletedAt("reading_post", retired) != nil)
        #expect(try b.outboxContains("reading_post", retired), "the repair's tombstone pushes")

        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        for client in [a, b] {
            #expect(try client.db.fetchString(
                """
                SELECT id FROM reading_post
                WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL
                """, [world.book, world.waiting]) == kept)
            #expect(try client.db.fetchString(
                "SELECT arrival_provenance FROM reading_post WHERE id = ?", [kept])?
                .contains("A's reason") == true, "the kept row's own provenance rides")
            #expect(try client.db.fetchString(
                "SELECT arrival_provenance FROM reading_post WHERE id = ?", [retired])?
                .contains("B's reason") == true, "the retired row dies carrying its own")
        }
    }

    /// The pin is plain CAS metadata: two devices pinning one membership
    /// offline with different stamps converge by the standing metadata class
    /// (no repair — no unique index guards it).
    @Test func twoDevicesPinningOneMembershipConverge() async throws {
        let (a, b, server) = try furniturePair()
        let world = try await sharedBook(a, b, server: server)
        let stamps = ["2026-11-05T10:00:00.000Z", "2026-11-05T11:00:00.000Z"]
        for (client, stamp) in zip([a, b], stamps) {
            try client.with { _, db in
                try db.write { db in
                    try db.execute(
                        sql: "UPDATE reading_post SET pinned_at = ? WHERE reading_id = ? AND post_id = ?",
                        arguments: [stamp, world.book, world.member])
                }
            }
        }
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        let converged = try a.db.fetchString(
            "SELECT pinned_at FROM reading_post WHERE reading_id = ? AND post_id = ?", [world.book, world.member])
        #expect(converged.map(stamps.contains) == true, "one device's stamp stands everywhere")
    }
}
