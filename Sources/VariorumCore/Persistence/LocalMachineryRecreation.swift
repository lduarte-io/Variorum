import Foundation
import GRDB

// Phase 13x, U2 row 8 — THE FOUR LOCAL-ONLY TABLES, RECREATED (corner
// 14.13 + pre-13x ledger 22, the recorded consequence on
// `StorePlaintextExport`): the export copies the WHOLE schema — the
// outbox triggers included — and then drops the registry's four local
// tables, so a re-opened export cannot take a single write until they
// exist again (every synced-table INSERT/UPDATE fires a trigger that
// names `sync_outbox`, and SQLite refuses the statement whole). The
// adoption door's plaintext road runs this BEFORE any open, so no
// migration, housekeeping or seeding write can meet the broken triggers.
//
// Freshly recreated tables ARE §14.13's reconciliation state: an empty
// outbox, no cursor (`sync_state` empty ⇒ pull from 0), no per-row seqs
// (never-accepted ranks 0) — so a same-account re-open enrolls and pulls
// with ZERO pushes, exactly the ruled corner, with nothing built beside
// the shipped machinery.
//
// The DDL is RESTATED from the migration (v1 + v1_3) — Migrations.swift
// is append-only and this file must not depend on running it — and the
// `LocalMachineryRecreationTests` schema-equality pin compares the
// recreated tables' structure against a freshly MIGRATED store's, so the
// restatement cannot drift silently.

public enum LocalMachineryRecreation {
    /// The exact DDL per local-only table (the registry's set).
    static let ddl: [String: String] = [
        "sync_outbox": """
            CREATE TABLE sync_outbox (
              table_name TEXT NOT NULL,
              row_id     TEXT NOT NULL,
              queued_at  TEXT NOT NULL,
              PRIMARY KEY (table_name, row_id)
            );
            """,
        "sync_state": """
            CREATE TABLE sync_state (
              key   TEXT PRIMARY KEY,
              value TEXT NOT NULL
            );
            """,
        "sync_row_seq": """
            CREATE TABLE sync_row_seq (
              table_name TEXT NOT NULL,
              row_id     TEXT NOT NULL,
              server_seq INTEGER NOT NULL,
              PRIMARY KEY (table_name, row_id)
            );
            """,
        "_sync_applying": """
            CREATE TABLE _sync_applying (
              applying INTEGER NOT NULL
            );
            """,
        // VX-306 U1a (v1_30): the protection record's table — the ONE shared value, not a restatement,
        // so it cannot drift; re-created EMPTY (an export carries no record — rule 26: a library with no
        // record is not handled on the new road).
        ProtectionRecordSchema.table: ProtectionRecordSchema.ddl,
    ]

    public struct RecreationError: Error, CustomStringConvertible, Equatable {
        public let reason: String
        public var description: String { "LocalMachineryRecreation: \(reason)" }
    }

    /// Recreate whichever of the four tables are missing, inside the
    /// PLAINTEXT store at `url` (a landed export — the door runs this
    /// before the store is ever opened through `openStore`). Returns the
    /// names created, sorted; an already-whole store returns []. Never
    /// runs the migrator.
    @discardableResult
    public static func recreateIfMissing(inPlaintextStoreAt url: URL) throws -> [String] {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw RecreationError(reason: "no store at \(url.path)")
        }
        let queue = try DatabaseQueue(path: url.path, configuration: AppDatabase.configuration())
        defer { try? queue.close() }
        var created: [String] = []
        try queue.write { db in
            // The registry's set, never a hand list that drifts — the DDL
            // map above must cover it exactly, and says so loudly if a
            // future table joins the registry without a row here.
            for table in SyncSchema.localOnlyTables.sorted() {
                guard try !db.tableExists(table) else { continue }
                guard let statement = ddl[table] else {
                    throw RecreationError(reason:
                        "the registry names \(table) but no DDL is restated for it — "
                        + "add the migration's CREATE here (the schema-equality pin guards it)")
                }
                try db.execute(sql: statement)
                created.append(table)
            }
        }
        return created.sorted()
    }
}
