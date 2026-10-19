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
            let scrap = try ops.newBlock(in: pool.id, text: "loose idea", at: .end).block
            // Phase 11 (A1): fixture rows for the lockstep event's tables.
            _ = try ops.setCanvasPosition(container: pool.id, block: scrap.id, x: 120, y: 64)
            let mergedBlock = try db.fetchString(
                "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL LIMIT 1",
                [post.id])!
            let mergedVariant = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [mergedBlock])!
            let lens = try ops.createLens(post: post.id, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: mergedBlock, variant: mergedVariant)
            // Phase 13 (A1): fixture row for the lockstep event's table.
            _ = try ops.addBlockComment(to: mergedBlock, text: "take 1 preferred")
            let reading = try ops.createReading(name: "book", kind: .book, maxPosts: nil)
            _ = try ops.addPostToReading(post.id, to: reading.id)
            // Phase 13 (A1): chapter fixture + a sectioned membership.
            let chapter = try ops.createSection(in: reading.id, name: "I / leaving")
            try ops.assignPostToSection(post.id, in: reading.id, section: chapter.id)
            let tag = try ops.createTag(parent: nil, name: "life")
            let child = try ops.createTag(parent: tag.id, name: "goals")
            _ = try ops.applyTag(child.id, toPost: post.id)
            let blockID = try db.fetchString(
                "SELECT block_id FROM container_block WHERE deleted_at IS NULL LIMIT 1")!
            _ = try ops.applyTag(tag.id, toBlock: blockID)
            _ = try ops.addReference(
                to: post.id, kind: .file, name: "notes.pdf",
                fileBookmark: Data([0xDE, 0xAD, 0xBE, 0xEF]))
            // Phase 13j (v1_14): a purge-intent fixture row so the walks
            // see the table. Direct SQL rather than the ops door — the
            // walk needs A row, not a whole deleted-family setup.
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO purge_intent
                          (id, owner_id, table_name, row_id, requested_at, created_at, updated_at)
                        VALUES (?, NULL, 'block', ?, ?, ?, ?)
                        """,
                    arguments: [
                        "0F000000-0000-4000-8000-00000000F14E", scrap.id,
                        "2026-08-19T00:00:00.000Z", "2026-08-19T00:00:00.000Z",
                        "2026-08-19T00:00:00.000Z",
                    ])
            }
            // 13i-a (v1_18): wing + shelf fixture rows so every walk and
            // round-trip sees the two new tables. Direct SQL — their ops
            // arrive at 13i-b/d; the walk needs A row each. The shelf
            // points at the minted wing (a non-Home pointer exercises the
            // column); the Welcome role exercises the seed marker.
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO wing (id, owner_id, name, position, created_at, updated_at)
                        VALUES ('0W000000-0000-4000-8000-000000000W01', NULL, 'the Work',
                                'a1', '2026-09-30T00:00:00.000Z', '2026-09-30T00:00:00.000Z')
                        """)
                try database.execute(
                    sql: """
                        INSERT INTO shelf (id, owner_id, wing_id, name, glyph, role, position,
                                           created_at, updated_at)
                        VALUES ('05000000-0000-4000-8000-0000000005E1', NULL,
                                '0W000000-0000-4000-8000-000000000W01', 'Welcome', '~',
                                'welcome', 'a1',
                                '2026-09-30T00:00:00.000Z', '2026-09-30T00:00:00.000Z')
                        """)
            }
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

    /// TABLES that exist only on the server (never a mirror of a client
    /// table, never in a payload): `sync_meta` carries the SyncSpec §12
    /// lockstep marker (05_phase11_lockstep.sql), read via its own RPC;
    /// `key_vault` (08_phase14b_lockstep.sql) is ACCOUNT data reached via
    /// plain authenticated PostgREST — the sync engine never touches it;
    /// `entitlement` (09_phase14c_multitenant.sql) is the tier's account
    /// data, read via PostgREST and enforced inside the RPCs, never in a
    /// payload.
    private static let serverOnlyTables: Set<String> = [
        "sync_meta", "key_vault", "entitlement",
        // Phase 13j (10_phase13j_purge.sql): the per-device pull cursor and
        // the content-free purged-ids ledger — purge machinery the RPCs
        // read/write server-side, never payload tables (the client learns
        // of them only through sync_horizon / sync_purge_ledger).
        "device_cursor", "purged_row",
        // Phase 13y (12_phase13y_tenant_seq.sql): the per-owner sequence
        // counter — pure server machinery (the trigger and the definer
        // bodies are its only writers); the client sees only the seqs it
        // grants, never the table.
        "sync_tenant_seq",
        // Phase 13y UNIT B (12, the challenge half): the single-use nonce
        // table (minted by sync_challenge, consumed by the proof check)
        // and the abuse guard's per-owner accounting row — both pure
        // server machinery, never payload tables (the client sees only
        // base64 nonces and the typed refusals).
        "key_proof_challenge", "sync_write_budget",
    ]

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
                // Phase 14c: `owner_id` on a table whose CLIENT schema has
                // no such column is server machinery like server_seq —
                // stamped into inserts and subtracted from payloads by the
                // tenant-scoped RPCs (09), so the client never receives it.
                var serverSide = Self.serverOnlyColumns
                if !clientColumns.contains("owner_id") { serverSide.insert("owner_id") }
                let unexpected = mirrorColumns
                    .subtracting(expected)
                    .subtracting(serverSide)
                #expect(unexpected.isEmpty,
                        "mirror \(table.name) carries column(s) the client cannot receive: \(unexpected.sorted())")
            }
            #expect(Set(mirror.keys).subtracting(Self.serverOnlyTables)
                        == Set(SyncSchema.tables.map(\.name)),
                    "mirror DDL table set drifted from the registry")
        }
    }

    // MARK: - Walk 4 (pre-13x 1b): the vault's columns are CLASSIFIED —
    // ids / hashes / wrapped keys / KDF parameters / bookkeeping — PLAIN
    // under E2EE by nature (key material travels WRAPPED; a hash is a
    // hash), never prose. `key_vault` is a server-only table (never a
    // payload), so the registry's per-column walk cannot see it; this pin
    // is its equivalent: every column the deployed DDL gives the vault
    // takes a declared side here, and a future column that forgets to
    // fails the build exactly as an unclassified synced column would.

    /// What each vault column IS. Adding a column to the mirror without
    /// adding it here fails `theVaultsColumnsAreClassifiedExactly`.
    enum VaultColumnClass: String { case id, kdfParameter, wrappedKey, hash, bookkeeping }
    static let keyVaultColumnClasses: [String: VaultColumnClass] = [
        "user_id": .id,
        "format_version": .bookkeeping,
        "kdf_algorithm": .kdfParameter,
        "kdf_argon2_version": .kdfParameter,
        "kdf_memory_kib": .kdfParameter,
        "kdf_iterations": .kdfParameter,
        "kdf_parallelism": .kdfParameter,
        "kdf_salt": .kdfParameter,
        "kdf_output_bytes": .kdfParameter,
        "master_wrapped_by_passphrase": .wrappedKey,
        "master_wrapped_by_recovery": .wrappedKey,
        "corpus_key_id": .id,
        "corpus_key_wrapped_by_master": .wrappedKey,
        "journal_bridge_key_id": .id,
        "journal_bridge_key_wrapped_by_master": .wrappedKey,
        "revision": .bookkeeping,
        "created_at": .bookkeeping,
        "updated_at": .bookkeeping,
        // pre-13x 11 — the six additive columns (design §3.10): the
        // previous corpus key is an id + a bare wrap, two columns, the
        // current key's own shape (the orchestrator's ruling on 1b's
        // question 1).
        "master_wrapped_by_apple_held": .wrappedKey,
        "apple_key_id": .id,
        "key_proof_hash": .hash,
        "corpus_previous_key_id": .id,
        "corpus_previous_wrapped_by_master": .wrappedKey,
        "rotation_started_seq": .bookkeeping,
        // pre-13x 2c — the SEVENTH column (decision 34): the writing device's
        // NAME. Plain by nature (never prose the user wrote; a device name);
        // the disclosure envelope gains one device name per account.
        "updated_by_device": .bookkeeping,
        // VX-307 (the HELD marker-14 shape, 17_phase_vx307_vault.sql): the
        // MODE flag — a posture enum, disclosed structure (which posture the
        // account is in), never a secret (`bookkeeping`); and the EARLIER
        // sync keys, each wrapped under the current master (rule 15) —
        // wrapped key material (`wrappedKey`). The disclosure envelope gains
        // the posture and the COUNT of kept keys (≈ Castle entries), no key.
        "mode": .bookkeeping,
        "earlier_row_keys": .wrappedKey,
    ]

    @Test func theVaultsColumnsAreClassifiedExactly() throws {
        let mirror = try Self.mirrorColumnsFromDDL()
        let vault = try #require(mirror["key_vault"], "the mirror DDL must carry key_vault")
        let declared = Set(Self.keyVaultColumnClasses.keys)
        #expect(vault.subtracting(declared).isEmpty,
                "key_vault carries unclassified column(s) \(vault.subtracting(declared).sorted()) — every vault column takes a side: id / KDF parameter / wrapped key / hash / bookkeeping")
        #expect(declared.subtracting(vault).isEmpty,
                "the classification names vault column(s) the DDL lacks: \(declared.subtracting(vault).sorted())")
        // The seven postures columns are all present — the additive event
        // reached the walk; VX-307's two join them (the held marker-14
        // shape). 27 vault columns in all.
        for column in ["master_wrapped_by_apple_held", "apple_key_id", "key_proof_hash",
                       "corpus_previous_key_id", "corpus_previous_wrapped_by_master",
                       "rotation_started_seq", "updated_by_device"] {
            #expect(vault.contains(column), "11 must add \(column)")
        }
        for column in ["mode", "earlier_row_keys"] {
            #expect(vault.contains(column), "17 must add \(column)")
        }
        #expect(vault.count == 27)
        // And no class is prose: the enum has no such case — stated so the
        // reader sees the disclosure list's promise where it is kept.
        #expect(Set(Self.keyVaultColumnClasses.values.map(\.rawValue))
                    .isSubset(of: ["id", "kdfParameter", "wrappedKey", "hash", "bookkeeping"]))
    }

    /// Parses `Server/supabase/*.sql` (in filename order, mirroring deploy
    /// order): `create table` bodies plus `alter table … add column`
    /// migrations plus — Phase 14c — `drop table`, which RESETS the
    /// table's accumulated set so the walk judges the deploy-order FINAL
    /// state. Without drop handling, 09's rebuild would UNION with 01's
    /// original definition and a column lost in the consolidation would
    /// be invisible to the walk (the exact drift class the rebuild
    /// risks). Deliberately simple — the DDL files are ours and follow
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
            try accumulateDDL(String(contentsOf: file, encoding: .utf8), into: &tables)
        }
        return tables
    }

    /// The pure accumulator (extracted so the drop-handling red-on-old
    /// proof below can feed it doctored SQL directly).
    static func accumulateDDL(_ sql: String, into tables: inout [String: Set<String>]) {
        var currentTable: String?
        for rawLine in sql.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = rawLine.trimmingCharacters(in: .whitespaces).lowercased()
            if line.hasPrefix("--") || line.isEmpty { continue }
            // drop table [if exists] <t>; — the rebuild pattern: the
            // table's accumulated columns reset; only what the NEW
            // definition carries counts from here on.
            if let range = line.range(of: "drop table ") {
                var rest = String(line[range.upperBound...])
                if rest.hasPrefix("if exists ") {
                    rest = String(rest.dropFirst("if exists ".count))
                }
                if let table = rest.split(separator: ";").first?
                    .trimmingCharacters(in: .whitespaces), !table.isEmpty {
                    tables[table] = nil
                }
                continue
            }
            if let range = line.range(of: "create table ") {
                var rest = String(line[range.upperBound...])
                if rest.hasPrefix("if not exists ") {
                    rest = String(rest.dropFirst("if not exists ".count))
                }
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
                // `references` opens a FK clause continued from the previous
                // column's line (08's `user_id uuid primary key` +
                // `references auth.users (id) …`) — never a column (pre-13x
                // 1b: the vault-column walk is the first to read key_vault).
                if let first = line.split(separator: " ").first,
                   !["primary", "foreign", "unique", "check", "constraint", "references"]
                       .contains(String(first)) {
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

    /// Drop-handling red-on-old (Phase 14c): a rebuild that DROPS a
    /// column must be visible to the walk. Before drop handling, the old
    /// definition's columns survived in the union and hid the loss —
    /// this proof fails on that parser and passes on the drop-aware one.
    @Test func aRebuildThatDropsAColumnIsVisibleToTheWalk() {
        var tables: [String: Set<String>] = [:]
        SerializerCompletenessTests.accumulateDDL("""
            create table demo (
              id   text primary key,
              kept text,
              lost text
            );
            """, into: &tables)
        #expect(tables["demo"] == ["id", "kept", "lost"])
        SerializerCompletenessTests.accumulateDDL("""
            drop table if exists demo;
            create table demo (
              owner_id uuid not null,
              id       text not null,
              kept     text,
              primary key (owner_id, id)
            );
            """, into: &tables)
        #expect(tables["demo"] == ["owner_id", "id", "kept"],
                "the rebuild's definition must REPLACE the accumulated set — a union would hide the lost column")
    }

    // MARK: - The red-on-old proof (plan requirement): a deliberately hidden
    // column in a test double FAILS the walk

    @Test func aHiddenColumnFailsTheWalk() throws {
        let db = try populatedWorld()
        // The double: a serializer that (wrongly) treats `url` as local-only,
        // silently dropping it from reference payloads — exactly the drift
        // class A6 exists to catch.
        let doctored = SyncTable(
            "reference",
            plain: SyncSchema.table(named: "reference")!.plainColumns,
            encrypted: SyncSchema.table(named: "reference")!.encryptedColumns,
            excludedColumns: ["file_bookmark", "url"])
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
