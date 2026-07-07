import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 8, amendment A6 — the serializer/registry completeness walk.
///
/// The drift class (Fragments post-mortem, 2026-07-07): a future migration
/// adds a column or table, the payload wiring misses it, and sync silently
/// drops that data — corruption spreading via pull. These tests run forever
/// and fail the build instead:
///  - every synced table's payload carries EVERY live column, minus the
///    declared local-only exclusions and `sync_version` (which rides
///    separately as the CAS base);
///  - the JSON wire round-trip preserves the exact column set (NULLs are not
///    dropped by encoding);
///  - the Postgres mirror DDL in `Server/supabase/` carries a home for every
///    synced column (a client column the mirror lacks is SILENTLY dropped by
///    `jsonb_populate_record` — the migration-lockstep hazard, SyncSpec §12);
///  - registry ⇄ schema identity in both directions is pinned by the Phase 5
///    test `SyncSchemaTests.registryMatchesLiveSchemaExactly` (A6 walk 2 —
///    already standing; not duplicated here).
@Suite("Serializer/registry completeness walk (Phase 8, A6)")
struct SerializerCompletenessTests {
    // MARK: - The walk itself (a pure checkable, so the red-on-old proof
    // below can exercise it against a doctored double)

    /// Columns the live schema says must cross the wire but the payload does
    /// not carry. Empty = the serializer is complete for this table.
    static func serializerGaps(
        payloadColumns: Set<String>,
        schemaColumns: Set<String>,
        declaredExclusions: Set<String>
    ) -> Set<String> {
        schemaColumns
            .subtracting(declaredExclusions)
            .subtracting(["sync_version"])
            .subtracting(payloadColumns)
    }

    /// A world built through real Operations so every synced table has at
    /// least one row (same recipe as the Phase 5 payload round-trip suite).
    private func populatedWorld() throws -> AppDatabase {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: .journal)
            let b1 = try ops.newBlock(in: post.id, text: "First para. Second sentence.", at: .end).block
            let b2 = try ops.newBlock(in: post.id, text: "Second block text.", at: .end).block
            let v1 = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [b1.id])!
            try ops.autosave(v1, text: "First para, edited.", charDelta: 8)
            _ = try ops.commit(v1, message: "checkpoint")
            _ = try ops.branchVariant(b1.id, from: v1)
            _ = try ops.merge(b1.id, b2.id)
            let pool = try ops.createPool(title: "scraps")
            _ = try ops.newBlock(in: pool.id, text: "loose idea", at: .end)
            let reading = try ops.createReading(name: "book", kind: .curated, maxPosts: nil)
            _ = try ops.addPostToReading(post.id, to: reading.id)
            let tag = try ops.createTag(parent: nil, name: "life")
            let child = try ops.createTag(parent: tag.id, name: "goals")
            _ = try ops.applyTag(child.id, toPost: post.id)
            let blockID = try db.fetchString(
                "SELECT block_id FROM container_block WHERE deleted_at IS NULL LIMIT 1")!
            _ = try ops.applyTag(tag.id, toBlock: blockID)
            _ = try ops.addReference(
                to: post.id, kind: .file, name: "notes.pdf",
                fileBookmark: Data([0xDE, 0xAD, 0xBE, 0xEF]))
            return db
        }
    }

    // MARK: - Walk 1: payload column completeness, introspected

    @Test func everySyncedTablePayloadCarriesEveryLiveColumn() throws {
        let db = try populatedWorld()
        try db.read { database in
            for table in SyncSchema.tables {
                let schemaColumns = Set(
                    try Row.fetchAll(database, sql: "PRAGMA table_info(\(table.name))")
                        .map { $0["name"] as String })
                let rows = try SyncRow.fetchAll(database, table: table)
                #expect(!rows.isEmpty, "\(table.name) has no fixture row — the walk cannot see it")
                for row in rows {
                    let gaps = Self.serializerGaps(
                        payloadColumns: Set(row.columns.keys),
                        schemaColumns: schemaColumns,
                        declaredExclusions: table.excludedColumns)
                    #expect(gaps.isEmpty,
                            "\(table.name) payload silently drops column(s): \(gaps.sorted())")
                    // And nothing EXTRA crosses: exclusions stay excluded,
                    // sync_version rides separately.
                    let extras = Set(row.columns.keys)
                        .subtracting(schemaColumns)
                        .union(Set(row.columns.keys).intersection(table.excludedColumns))
                        .union(Set(row.columns.keys).intersection(["sync_version"]))
                    #expect(extras.isEmpty,
                            "\(table.name) payload carries column(s) it must not: \(extras.sorted())")
                }
            }
        }
    }

    /// The JSON wire hop must not shrink the column set — a NULL column
    /// encodes as JSON null and comes back as a present `.null`, never as an
    /// absent key (an absent key would UPDATE around that column on apply,
    /// silently preserving stale data).
    @Test func jsonRoundTripPreservesTheExactColumnSet() throws {
        let db = try populatedWorld()
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        try db.read { database in
            for table in SyncSchema.tables {
                for row in try SyncRow.fetchAll(database, table: table) {
                    let decoded = try decoder.decode(
                        SyncRow.self, from: encoder.encode(row))
                    #expect(Set(decoded.columns.keys) == Set(row.columns.keys),
                            "\(table.name) JSON hop changed the column set")
                }
            }
        }
    }

    // MARK: - Walk 3: the mirror DDL has a home for every synced column
    // (SyncSpec §12 — a client must never push a column the mirror lacks;
    // jsonb_populate_record drops unknown keys with no error)

    /// Columns that exist ONLY on the mirror (server machinery, never in a
    /// payload): `server_seq` (the ordering authority) and, once A5's
    /// visibility-horizon migration lands, `server_written_at`.
    private static let serverOnlyColumns: Set<String> = ["server_seq", "server_written_at"]

    @Test func mirrorDDLCoversEverySyncedColumn() throws {
        let mirror = try Self.mirrorColumnsFromDDL()
        let db = try AppDatabase.inMemory()
        try db.read { database in
            for table in SyncSchema.tables {
                let clientColumns = Set(
                    try Row.fetchAll(database, sql: "PRAGMA table_info(\(table.name))")
                        .map { $0["name"] as String })
                let expected = clientColumns.subtracting(table.excludedColumns)
                guard let mirrorColumns = mirror[table.name] else {
                    Issue.record("mirror DDL has no table \(table.name)")
                    continue
                }
                let missing = expected.subtracting(mirrorColumns)
                #expect(missing.isEmpty,
                        "mirror \(table.name) lacks synced column(s) \(missing.sorted()) — pushes would silently drop them (SyncSpec §12)")
                let unexpected = mirrorColumns
                    .subtracting(expected)
                    .subtracting(Self.serverOnlyColumns)
                #expect(unexpected.isEmpty,
                        "mirror \(table.name) carries column(s) the client cannot receive: \(unexpected.sorted())")
            }
            #expect(Set(mirror.keys) == Set(SyncSchema.tables.map(\.name)),
                    "mirror DDL table set drifted from the registry")
        }
    }

    /// Parses `Server/supabase/*.sql` (in filename order, mirroring deploy
    /// order): `create table` bodies plus `alter table … add column`
    /// migrations. Deliberately simple — the DDL files are ours and follow
    /// one formatting convention.
    private static func mirrorColumnsFromDDL() throws -> [String: Set<String>] {
        let serverDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumCoreTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // repo root
            .appendingPathComponent("Server/supabase", isDirectory: true)
        let files = try FileManager.default
            .contentsOfDirectory(at: serverDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "sql" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        #expect(!files.isEmpty, "no mirror DDL found at \(serverDir.path)")

        var tables: [String: Set<String>] = [:]
        for file in files {
            let sql = try String(contentsOf: file, encoding: .utf8)
            var currentTable: String?
            for rawLine in sql.split(separator: "\n", omittingEmptySubsequences: false) {
                let line = rawLine.trimmingCharacters(in: .whitespaces).lowercased()
                if line.hasPrefix("--") || line.isEmpty { continue }
                if let range = line.range(of: "create table ") {
                    let rest = line[range.upperBound...]
                    currentTable = rest.split(separator: " ").first.map(String.init)?
                        .replacingOccurrences(of: "(", with: "")
                    if let table = currentTable { tables[table, default: []] = tables[table] ?? [] }
                    continue
                }
                if let table = currentTable {
                    if line.hasPrefix(");") || line == ")" {
                        currentTable = nil
                        continue
                    }
                    if let first = line.split(separator: " ").first,
                       !["primary", "foreign", "unique", "check", "constraint"].contains(String(first)) {
                        tables[table, default: []].insert(String(first))
                    }
                    continue
                }
                if let range = line.range(of: "alter table ") {
                    let tokens = line[range.upperBound...].split(separator: " ").map(String.init)
                    // alter table <t> add column [if not exists] <col> …
                    guard tokens.count >= 4, tokens[1] == "add", tokens[2] == "column" else { continue }
                    let column = tokens[3] == "if" && tokens.count >= 7 ? tokens[6] : tokens[3]
                    tables[tokens[0], default: []].insert(column)
                }
            }
        }
        return tables
    }

    // MARK: - The red-on-old proof (plan requirement): a deliberately hidden
    // column in a test double FAILS the walk

    @Test func aHiddenColumnFailsTheWalk() throws {
        let db = try populatedWorld()
        // The double: a serializer that (wrongly) treats `url` as local-only,
        // silently dropping it from reference payloads — exactly the drift
        // class A6 exists to catch.
        let doctored = SyncTable(
            "reference", excludedColumns: ["file_bookmark", "url"])
        try db.read { database in
            let schemaColumns = Set(
                try Row.fetchAll(database, sql: "PRAGMA table_info(reference)")
                    .map { $0["name"] as String })
            let rows = try SyncRow.fetchAll(database, table: doctored)
            #expect(!rows.isEmpty)
            for row in rows {
                let gaps = Self.serializerGaps(
                    payloadColumns: Set(row.columns.keys),
                    schemaColumns: schemaColumns,
                    // The walk judges against the DECLARED exclusions — the
                    // registry's truth, not the doctored serializer's.
                    declaredExclusions: SyncSchema.table(named: "reference")!.excludedColumns)
                #expect(gaps == ["url"],
                        "the walk failed to flag the hidden column (got \(gaps.sorted()))")
            }
        }
    }
}
