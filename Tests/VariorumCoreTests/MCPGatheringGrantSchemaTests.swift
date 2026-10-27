import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-549 (VX-548 batch 3) — `v1_33_mcp_gathering_grants`: the grants family's
// `mcp_grant.scope_kind` gains 'gathering' (her sitting 2026-10-27, RATIFIED —
// "Gathering joins the grant scopes"). LOCAL-ONLY on the family's road (no
// sync_version, no trigger, no outbox, the marker untouched). A REBUILD — a
// CHECK cannot be altered — so the pins here prove the store's existing rows
// arrive EXACTLY (every column and the rowid Shared with AI's within-a-stamp
// order reads), the two indexes come back with their text unchanged, and
// VX-393's standing-place index holds a gathering as one more place with no
// change of its own.

@Suite("VX-549 — v1_33: a gathering joins the grant scopes (local-only, rows untouched)")
struct MCPGatheringGrantSchemaTests {
    private let stamp = "2026-10-27T03:00:00.000Z"

    /// The two indexes on `mcp_grant`, by name, with their stored text.
    private func grantIndexes(_ db: Database) throws -> [String: String] {
        var indexes: [String: String] = [:]
        for row in try Row.fetchAll(
            db, sql: "SELECT name, sql FROM sqlite_master WHERE type = 'index' AND tbl_name = 'mcp_grant'") {
            indexes[row["name"]] = row["sql"]
        }
        return indexes
    }

    /// Every grant row, rowid included, in rowid order.
    private func grantRows(_ db: Database) throws -> [[String?]] {
        let columns = ["id", "client_id", "rung", "scope_kind", "scope_id", "duration", "created_at", "consumed_at",
                       "revoked_at"]
        let rows = try Row.fetchAll(db, sql: """
            SELECT rowid, id, client_id, rung, scope_kind, scope_id, duration, created_at, consumed_at, revoked_at
            FROM mcp_grant ORDER BY rowid
            """)
        return rows.map { row -> [String?] in
            let rowid: Int64 = row["rowid"]
            var values: [String?] = [String(rowid)]
            for column in columns {
                let value: String? = row[column]
                values.append(value)
            }
            return values
        }
    }

    @Test func aStoreBeforeTheGatheringPlaceKeepsEveryGrantRowExactly() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_32_sync_pull_stage")
        try queue.write { db in
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, version, state, first_seen_at, last_seen_at, decided_at)
                  VALUES ('cl1', 'claude-code', '2.1', 'approved', ?, ?, ?);
                INSERT INTO mcp_client (id, name, version, state, first_seen_at, last_seen_at, decided_at)
                  VALUES ('cl2', 'codex', '0.9', 'approved', ?, ?, ?);
                """, arguments: [stamp, stamp, stamp, stamp, stamp, stamp])
            // Inserted out of id order, one stamp shared by three (an act the
            // pane orders by rowid), a spent once, a revoked row, every kind.
            for (id, client, rung, kind, scope, duration, consumed, revoked) in [
                ("g9", "cl1", "read", "note", "n1", "always", nil, nil),
                ("g2", "cl1", "read", "note", "n2", "always", nil, nil),
                ("g5", "cl1", "read", "note", "n3", "always", nil, nil),
                ("g1", "cl2", "edit", "wing", "", "always", nil, nil),
                ("g7", "cl2", "write_new", "book", "r1", "connection", nil, "2026-10-27T03:05:00.000Z"),
                ("g3", "cl1", "suggest", "book", "r1", "once", "2026-10-27T03:06:00.000Z", nil),
            ] as [(String, String, String, String, String, String, String?, String?)] {
                try db.execute(
                    sql: """
                        INSERT INTO mcp_grant
                          (id, client_id, rung, scope_kind, scope_id, duration, created_at, consumed_at, revoked_at)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                    arguments: [id, client, rung, kind, scope, duration, stamp, consumed, revoked])
            }
            // A deleted row leaves a rowid gap the copy must keep, not close.
            try db.execute(sql: "DELETE FROM mcp_grant WHERE id = 'g2'")
            try db.execute(
                sql: """
                    INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                    VALUES ('g4', 'cl1', 'read', 'wing', 'w1', 'always', ?)
                    """,
                arguments: [stamp])
        }
        let (rowsBefore, indexesBefore) = try queue.read { db in (try grantRows(db), try grantIndexes(db)) }
        #expect(rowsBefore.count == 6)
        #expect(indexesBefore.keys.sorted() == ["idx_mcp_grant_client", "uq_mcp_grant_standing_place"])

        try AppDatabase.migrator.migrate(queue)

        try queue.read { (db: Database) throws in
            #expect(try grantRows(db) == rowsBefore, "every row, every column and its rowid, exactly as it was")
            #expect(try grantIndexes(db) == indexesBefore, "both indexes back, their text unchanged")
            #expect(try Row.fetchAll(db, sql: "PRAGMA foreign_key_check").isEmpty)
            let foreignKeys = try Row.fetchAll(db, sql: "PRAGMA foreign_key_list(mcp_grant)")
            #expect(foreignKeys.map { $0["table"] as String } == ["mcp_client"], "still a client's grant")
            #expect(try String.fetchOne(db, sql: "SELECT state FROM mcp_client WHERE id = 'cl1'") == "approved")
        }
    }

    @Test func theFamilyStaysLocalOnlyAndTheMarkerStays() throws {
        #expect(SyncSchema.lockstepVersion == 14, "a local-only migration never moves the marker")
        #expect(SyncSchema.table(named: "mcp_grant") == nil)
        #expect(MCPGrantSchema.tables.contains("mcp_grant"))
        let db = try AppDatabase.inMemory()
        try db.read { (db: Database) throws in
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(mcp_grant)").map { $0["name"] as String }
            #expect(columns == ["id", "client_id", "rung", "scope_kind", "scope_id", "duration", "created_at",
                                "consumed_at", "revoked_at"], "the same nine columns, in their order")
            #expect(try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type = 'trigger' AND tbl_name = 'mcp_grant'
                """).isEmpty, "no trigger reads the grants store")
        }
        try db.write { db in
            let before = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, state, first_seen_at, last_seen_at) VALUES ('cl1', 'claude-code', 'approved', ?, ?);
                INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                  VALUES ('g1', 'cl1', 'read', 'gathering', 'r-g', 'always', ?);
                """, arguments: [stamp, stamp, stamp])
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") == before,
                    "a gathering grant never reaches the outbox")
        }
    }

    @Test func theCheckAdmitsAGatheringAndStillRefusesAnythingElse() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, state, first_seen_at, last_seen_at) VALUES ('cl1', 'claude-code', 'approved', ?, ?);
                INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                  VALUES ('g1', 'cl1', 'suggest', 'gathering', 'r-g', 'always', ?);
                """, arguments: [stamp, stamp, stamp])
        }
        for kind in ["tag", "shelf", "Gathering", ""] {
            #expect(throws: (any Error).self, "\(kind) is no grant scope") {
                try db.write { db in
                    try db.execute(
                        sql: """
                            INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                            VALUES ('x', 'cl1', 'read', ?, 'r', 'always', ?)
                            """,
                        arguments: [kind, stamp])
                }
            }
        }
    }

    /// VX-393's `uq_mcp_grant_standing_place` needs no change: it keys a place
    /// as client × KIND × id, so one standing grant per client × gathering, a
    /// once grant beside it, another client's beside it, and the same id string
    /// under another kind are all as for any place.
    @Test func theStandingPlaceIndexHoldsAGatheringAsOnePlaceUnchanged() throws {
        let db = try AppDatabase.inMemory()
        func insert(_ id: String, _ client: String, _ kind: String, _ duration: String) throws {
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                        VALUES (?, ?, 'read', ?, 'r-g', ?, ?)
                        """,
                    arguments: [id, client, kind, duration, stamp])
            }
        }
        try db.write { db in
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, state, first_seen_at, last_seen_at) VALUES ('cl1', 'claude-code', 'approved', ?, ?);
                INSERT INTO mcp_client (id, name, state, first_seen_at, last_seen_at) VALUES ('cl2', 'codex', 'approved', ?, ?);
                """, arguments: [stamp, stamp, stamp, stamp])
        }
        try insert("a", "cl1", "gathering", "always")
        #expect(throws: (any Error).self, "one live standing grant per client × gathering") {
            try insert("b", "cl1", "gathering", "connection")
        }
        try insert("c", "cl1", "gathering", "once")
        try insert("d", "cl1", "gathering", "once")
        try insert("e", "cl2", "gathering", "always")
        try insert("f", "cl1", "book", "always")
        try db.write { db in try db.execute(sql: "UPDATE mcp_grant SET revoked_at = ? WHERE id = 'a'", arguments: [stamp]) }
        try insert("g", "cl1", "gathering", "connection")
        try db.read { (db: Database) throws in
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_grant") == 6)
        }
    }
}
