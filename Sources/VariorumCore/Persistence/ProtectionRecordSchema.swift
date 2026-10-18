import Foundation
import GRDB

// VX-306 U1a, piece 2 — THE PROTECTION RECORD'S TABLE (`notes/plans/vx-306-castle-open-road.md` §2 U1a;
// the record's value is `Protection/Model/ProtectionRecord.swift`, design §3.2's homes column: "a table
// inside the library file, `protection_record`, in the local-only family (no lockstep; the plaintext
// export leaves it behind)").
//
// LOCAL-ONLY, by registration: the table joins `SyncSchema.localOnlyTables` — no `sync_version`, no
// outbox trigger, never a payload, never a mirror (the completeness walk pins it); the plaintext export
// DROPS it with the rest of that set; `LocalMachineryRecreation` re-creates it EMPTY in a landed export.
// NOT a SyncSpec §12 lockstep event: nothing on the wire changes, the marker stays 13 (the MCP grants
// family's and the search index's class).
//
// ONE VALUE, TWO USERS: the migration `v1_30_protection_record` and the production library leaf
// (`SQLCipherLibraryLeaf.createLibrary(with:record:)` writes a fresh keyed file holding only this table,
// before the app's ordinary open runs every migration over it — hence `IF NOT EXISTS`).
//
// ONE ROW PER FILE: a library file holds its own library's record and nothing else. A write REPLACES
// every row (a copy staged for Make this my library carries the OUTGOING library's row until the new
// record lands), and a read of more than one row refuses — never a guess between two.

public enum ProtectionRecordSchema {
    public static let table = "protection_record"

    /// `protection_record(library_id TEXT PRIMARY KEY, record TEXT NOT NULL, updated_at TEXT NOT NULL)` —
    /// the record as `ProtectionCoding` JSON, its `updated_at` an ISO-8601 stamp (AppSpec §6).
    public static let ddl = """
        CREATE TABLE IF NOT EXISTS protection_record (
          library_id TEXT PRIMARY KEY,
          record     TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
        """

    public enum RecordError: Error, Equatable, Sendable {
        /// More than one row — a file this design never writes; refused, never guessed.
        case moreThanOneRecord(Int)
        /// The row's text is not a record this build reads.
        case unreadable
    }

    /// The record in the file, or nil when the table is absent or empty (a library from before this
    /// design — rule 26: not handled).
    public static func read(_ db: Database) throws -> ProtectionRecord? {
        guard try db.tableExists(table) else { return nil }
        let texts = try String.fetchAll(db, sql: "SELECT record FROM protection_record")
        guard let text = texts.first else { return nil }
        guard texts.count == 1 else { throw RecordError.moreThanOneRecord(texts.count) }
        do {
            return try ProtectionCoding.decoder().decode(ProtectionRecord.self, from: Data(text.utf8))
        } catch {
            throw RecordError.unreadable
        }
    }

    /// The file's ONE record, replacing whatever rows it held. The caller owns the transaction.
    public static func write(_ record: ProtectionRecord, at date: Date, _ db: Database) throws {
        try db.execute(sql: ddl)
        let data = try ProtectionCoding.canonical(record)
        guard let text = String(data: data, encoding: .utf8) else { throw RecordError.unreadable }
        try db.execute(sql: "DELETE FROM protection_record")
        try db.execute(
            sql: "INSERT INTO protection_record (library_id, record, updated_at) VALUES (?, ?, ?)",
            arguments: [record.libraryID, text, isoStamp(date)])
    }

    static func isoStamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
