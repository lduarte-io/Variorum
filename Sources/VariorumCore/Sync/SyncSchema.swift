import Foundation
import GRDB

/// The sync layer's view of the schema (SyncSpec §3): which tables sync, in
/// what order a pulled batch applies, and each table's quirks. This registry
/// is the single source the push/pull engine, the fake test server, and the
/// Postgres mirror DDL are all derived from — if a table is added to the
/// schema, it is added HERE or it silently never syncs (the introspection
/// test in `SyncSchemaTests` fails the build instead).
public struct SyncTable: Equatable, Sendable {
    /// SQLite table name (identical on the Postgres mirror).
    public let name: String
    /// The PK column: `id` everywhere except `setting.key`.
    public let primaryKey: String
    /// Local-only columns excluded from sync payloads. Today exactly one:
    /// `reference.file_bookmark` (security-scoped bookmarks are per-machine;
    /// AppSpec §7). Apply preserves an excluded column's local value.
    public let excludedColumns: Set<String>
    /// Whether the table carries `deleted_at`. `setting` is upsert-only and
    /// never tombstones; `commit_point` has no tombstone column by design
    /// (unreachable once its variant dies; AppSpec §14.4).
    public let hasTombstone: Bool

    init(_ name: String, primaryKey: String = "id",
         excludedColumns: Set<String> = [], hasTombstone: Bool = true) {
        self.name = name
        self.primaryKey = primaryKey
        self.excludedColumns = excludedColumns
        self.hasTombstone = hasTombstone
    }
}

public enum SyncSchema {
    /// The 13 synced tables in FK-dependency-friendly apply order: parents
    /// before children wherever the graph is acyclic. (`container`⇄`block`⇄
    /// `variant` are mutually circular by design — the apply transaction runs
    /// with deferred FKs, so within one batch the order is a determinism
    /// nicety, not a correctness requirement; across batches the read side
    /// tolerates stragglers, SyncSpec §5.)
    public static let tables: [SyncTable] = [
        SyncTable("container"),
        SyncTable("block"),
        SyncTable("variant"),
        SyncTable("commit_point", hasTombstone: false),
        SyncTable("tag"),
        SyncTable("edge"),
        SyncTable("container_block"),
        SyncTable("reading"),
        SyncTable("reading_post"),
        SyncTable("post_tag"),
        SyncTable("block_tag"),
        SyncTable("reference", excludedColumns: ["file_bookmark"]),
        SyncTable("setting", primaryKey: "key", hasTombstone: false),
    ]

    /// Local-only machinery that must never appear in a payload or a mirror.
    public static let localOnlyTables: Set<String> = [
        "sync_outbox", "sync_state", "sync_row_seq", "_sync_applying",
    ]

    private static let byName: [String: SyncTable] = Dictionary(
        uniqueKeysWithValues: tables.map { ($0.name, $0) })

    public static func table(named name: String) -> SyncTable? {
        byName[name]
    }

    /// Batch order for a mixed set of dirty rows: registry order, then PK —
    /// deterministic, FK-friendly.
    public static func applyOrderIndex(of tableName: String) -> Int {
        tables.firstIndex { $0.name == tableName } ?? tables.count
    }
}

// MARK: - Values

/// One column value in a sync payload. SQLite's TEXT/INTEGER/REAL/NULL only —
/// the single BLOB column in the schema (`reference.file_bookmark`) is
/// local-only and excluded from payloads, so a blob reaching this type is a
/// programmer error and encoding throws.
///
/// Wire format is the bare JSON scalar (string / number / null), matching
/// what a Postgres `jsonb` payload naturally carries. An integral REAL may
/// come back as `.integer` after a JSON round trip; column affinity
/// normalizes it on write, so DB state — the thing convergence compares —
/// is unaffected.
public enum SyncValue: Equatable, Sendable, Codable {
    case null
    case integer(Int64)
    case real(Double)
    case text(String)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let integer = try? container.decode(Int64.self) {
            self = .integer(integer)
        } else if let real = try? container.decode(Double.self) {
            self = .real(real)
        } else {
            self = .text(try container.decode(String.self))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .integer(let value): try container.encode(value)
        case .real(let value): try container.encode(value)
        case .text(let value): try container.encode(value)
        }
    }

    init(databaseValue: DatabaseValue) throws {
        switch databaseValue.storage {
        case .null: self = .null
        case .int64(let value): self = .integer(value)
        case .double(let value): self = .real(value)
        case .string(let value): self = .text(value)
        case .blob:
            throw SyncError.blobInPayload
        }
    }

    var databaseValue: DatabaseValue {
        switch self {
        case .null: return .null
        case .integer(let value): return value.databaseValue
        case .real(let value): return value.databaseValue
        case .text(let value): return value.databaseValue
        }
    }
}

public enum SyncError: Error, Equatable, Sendable {
    /// A BLOB column reached a payload — only `reference.file_bookmark` is
    /// BLOB and it is excluded, so this is a schema/registry drift signal.
    case blobInPayload
    /// A payload named a table the registry doesn't know.
    case unknownTable(String)
    /// A payload's columns are missing its own primary key.
    case missingPrimaryKey(table: String)
}

// MARK: - Rows

/// One row as it travels: table + PK value + every synced column (including
/// the PK column, excluding `sync_version` which rides separately — on push
/// it is the CAS base, on pull the server-current version). JSON-encodable
/// for the wire.
public struct SyncRow: Equatable, Sendable, Codable {
    public let table: String
    public let rowID: String
    public var columns: [String: SyncValue]
    /// Push: the CAS base (the row's last server-accepted version).
    /// Pull: the server's current version for the row.
    public var syncVersion: Int

    public init(table: String, rowID: String, columns: [String: SyncValue], syncVersion: Int) {
        self.table = table
        self.rowID = rowID
        self.columns = columns
        self.syncVersion = syncVersion
    }

    /// deleted_at, when the table has one and the row carries it.
    public var isTombstoned: Bool {
        if case .text = columns["deleted_at"] { return true }
        return false
    }

    public var workingText: String? {
        if case .text(let value) = columns["working_text"] { return value }
        return nil
    }

    // MARK: Fetch (row → payload)

    /// The row's current payload, or nil if the row doesn't exist. Excluded
    /// (local-only) columns and `sync_version` never enter `columns`.
    public static func fetch(_ db: Database, table: SyncTable, rowID: String) throws -> SyncRow? {
        guard let row = try Row.fetchOne(
            db,
            sql: "SELECT * FROM \(table.name) WHERE \(table.primaryKey) = ?",
            arguments: [rowID])
        else { return nil }
        return try SyncRow(row: row, table: table)
    }

    /// All rows of a table as payloads (test dumps, initial mirror seeding).
    public static func fetchAll(_ db: Database, table: SyncTable) throws -> [SyncRow] {
        try Row.fetchAll(
            db,
            sql: "SELECT * FROM \(table.name) ORDER BY \(table.primaryKey)"
        ).map { try SyncRow(row: $0, table: table) }
    }

    init(row: Row, table: SyncTable) throws {
        var columns: [String: SyncValue] = [:]
        var syncVersion = 0
        for (name, value) in row {
            if name == "sync_version" {
                syncVersion = Int.fromDatabaseValue(value) ?? 0
                continue
            }
            guard !table.excludedColumns.contains(name) else { continue }
            columns[name] = try SyncValue(databaseValue: value)
        }
        guard case .text(let id) = columns[table.primaryKey] else {
            throw SyncError.missingPrimaryKey(table: table.name)
        }
        self.table = table.name
        self.rowID = id
        self.columns = columns
        self.syncVersion = syncVersion
    }

    // MARK: Apply (payload → row)

    /// Upserts the payload: UPDATE if the row exists, INSERT otherwise —
    /// deliberately not `INSERT OR REPLACE`, which would clobber local-only
    /// columns (`reference.file_bookmark`) and fire delete-side machinery.
    /// Writes `sync_version` from the payload. Callers decide the
    /// transaction/apply-mode context; this function only writes the row.
    public func apply(_ db: Database) throws {
        guard let table = SyncSchema.table(named: table) else {
            throw SyncError.unknownTable(table)
        }
        guard columns[table.primaryKey] != nil else {
            throw SyncError.missingPrimaryKey(table: table.name)
        }
        let names = columns.keys.sorted()
        let updateAssignments = names
            .filter { $0 != table.primaryKey }
            .map { "\($0) = ?" }
            .joined(separator: ", ")
        let updateArguments = names.filter { $0 != table.primaryKey }.map { columns[$0]!.databaseValue }
        try db.execute(
            sql: """
                UPDATE \(table.name) SET \(updateAssignments), sync_version = ?
                WHERE \(table.primaryKey) = ?
                """,
            arguments: StatementArguments(updateArguments + [syncVersion.databaseValue, rowID.databaseValue]))
        if db.changesCount == 0 {
            let placeholders = (names + ["sync_version"]).map { _ in "?" }.joined(separator: ", ")
            try db.execute(
                sql: """
                    INSERT INTO \(table.name) (\(names.joined(separator: ", ")), sync_version)
                    VALUES (\(placeholders))
                    """,
                arguments: StatementArguments(names.map { columns[$0]!.databaseValue } + [syncVersion.databaseValue]))
        }
    }
}
