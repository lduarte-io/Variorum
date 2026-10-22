import Foundation
import GRDB

/// pre-13x batch 3b — THE PLAINTEXT `.sqlite` EXPORT (the postures design
/// decision 15; §3.3; corners 14.1 / 14.13; copy §4's *Export a decrypted
/// copy*): the ONE deliberate unencrypted escape besides the `.md` export.
///
/// From the OPEN keyed connection: a plaintext file is ATTACHed (`KEY ''`),
/// `sqlcipher_export` copies the whole schema and every row into it, and
/// the LOCAL bookkeeping tables are then DROPPED inside the export — the
/// exact local-only set the sync registry declares (`SyncSchema
/// .localOnlyTables`: the outbox, the cursor/marker keyspace, the per-row
/// seq bookkeeping, the apply flag — pinned by `SyncSchemaTests` as exactly
/// the schema minus the synced registry), never a hand list that drifts.
/// There is no key in the file to strip (§3.3: the sync keys and the device
/// identity live in per-store custody, never in the library file). Every
/// synced table keeps `sync_version` and `owner_id`, so 13x's open door can
/// reconcile a re-opened export (§14.13).
///
/// Recorded consequence for that door: the copied outbox triggers still
/// name the dropped tables, so a re-opened export cannot take a WRITE until
/// its local tables are recreated — the open door's reconciliation step.
///
/// The DERIVED set (`SyncSchema.derivedTables` — the 13o search-index
/// family) is deliberately NOT dropped (the §FORK RULINGS derived-set
/// ruling, 2026-10-06): the no-lock-in file opens with working full-text
/// search, and its capture triggers stay satisfied — the broken-trigger
/// consequence above never grows a second instance.
///
/// Never scheduled, never into the backups folder (the caller's picker
/// refuses that), a user-chosen destination only; an existing file is never
/// overwritten.
public enum StorePlaintextExport {
    public struct ExportError: Error, CustomStringConvertible, Equatable {
        public let reason: String
        public var description: String { "StorePlaintextExport: \(reason)" }
    }

    /// The tables that stay behind — the registry's local-only set.
    public static var localOnlyTables: Set<String> { SyncSchema.localOnlyTables }

    /// The tables that travel EMPTY — the MCP door's grants store (13n-b,
    /// A-5).
    public static var strippedTables: Set<String> { MCPGrantSchema.tables }

    /// Write the decrypted copy at `destination`. Runs on the caller's
    /// thread (a file-sized copy — callers hop off the main actor).
    public static func export(from database: AppDatabase, to destination: URL) throws {
        guard !FileManager.default.fileExists(atPath: destination.path) else {
            throw ExportError(reason:
                "a file named \(destination.lastPathComponent) is already there — choose another name")
        }
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try write(from: database, into: destination)
    }

    /// The copy itself, into `destination` — made by the ATTACH when absent (the save panel's grant lets exactly that
    /// one path be created and written; `export` refuses a file already there before calling this).
    static func write(from database: AppDatabase, into destination: URL) throws {
        try database.writeWithoutTransaction { db in
            do {
                try db.execute(
                    sql: "ATTACH DATABASE ? AS plain KEY ''", arguments: [destination.path])
            } catch {
                throw ExportError(reason: "the destination could not be opened for writing (\(error))")
            }
            defer { try? db.execute(sql: "DETACH DATABASE plain") }
            // VX-461 (W-VX309-4): the copy's rollback journal lives in MEMORY, never as a file beside it. A sandboxed
            // save panel grants the picked path alone, so `<picked>-journal` cannot be created there — the copy's first
            // write failed "unable to open database file" and left the picked file at 0 bytes. The copy is a fresh file
            // nothing else reads until it is whole, so an on-disk journal protected nothing here.
            try db.execute(sql: "PRAGMA plain.journal_mode = MEMORY")
            try db.execute(sql: "SELECT sqlcipher_export('plain')")
            for table in localOnlyTables.sorted() {
                let quoted = table.replacingOccurrences(of: "\"", with: "\"\"")
                try db.execute(sql: "DROP TABLE IF EXISTS plain.\"\(quoted)\"")
            }
            // 13n-b (A-5): the MCP door's grants store travels EMPTY — no
            // client, grant, switch or activity row leaves in the file (a
            // grants list in an export serves nobody), while the tables stay
            // so the file's schema is whole and a re-opened export needs no
            // second recreation road (`MCPGrantSchema`).
            for table in MCPGrantSchema.childFirstOrder {
                let quoted = table.replacingOccurrences(of: "\"", with: "\"\"")
                try db.execute(sql: "DELETE FROM plain.\"\(quoted)\"")
            }
        }
        // The export's own journal sidecars (the attached file's) — swept.
        for suffix in ["-wal", "-shm", "-journal"] {
            try? FileManager.default.removeItem(atPath: destination.path + suffix)
        }
    }
}
