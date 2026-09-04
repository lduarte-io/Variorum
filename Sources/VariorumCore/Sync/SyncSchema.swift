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
    /// Columns that travel and are stored on the mirror IN THE CLEAR
    /// (Phase 14b E2EE classification): ids, FKs, enums/status/kinds,
    /// timestamps, positions, counters — disclosed structure, never prose.
    /// **Every column must be classified explicitly**: the completeness walk
    /// (`SyncSchemaTests`) introspects the live schema and fails the build
    /// on any column that is not exactly one of plain / encrypted /
    /// excluded — the postmortem-#4 serializer-drift lesson applied to
    /// encryption, so a future migration cannot silently leak a new text
    /// column. (`sync_version` rides separately as the CAS base and is
    /// machinery, not a classified payload column.)
    public let plainColumns: Set<String>
    /// User-authored text columns (Phase 14b, THE DESIGN's disclosure
    /// list): sealed by the payload seam on the way out, opened on the way
    /// in — the mirror stores only `e1:` AEAD ciphertext for these. The
    /// engine inland (merge, repairs, CAS) sees plaintext only.
    public let encryptedColumns: Set<String>
    /// Whether the table carries `deleted_at`. `setting` is upsert-only and
    /// never tombstones; `commit_point` has no tombstone column by design
    /// (unreachable once its variant dies; AppSpec §14.4).
    public let hasTombstone: Bool

    init(_ name: String, primaryKey: String = "id",
         plain: Set<String>, encrypted: Set<String> = [],
         excludedColumns: Set<String> = [], hasTombstone: Bool = true) {
        self.name = name
        self.primaryKey = primaryKey
        self.plainColumns = plain
        self.encryptedColumns = encrypted
        self.excludedColumns = excludedColumns
        self.hasTombstone = hasTombstone
    }
}

public enum SyncSchema {
    /// The client's schema-lockstep version (SyncSpec §12). Version 1 = the
    /// 9c-era 13-table deployment (defined retroactively: a mirror with no
    /// `sync_meta` marker reports 1); version 2 = the Phase 11 lockstep
    /// event (v1_5 canvas_layout + v1_6 block.name + v1_7 lens/lens_choice;
    /// mirror DDL 05_phase11_lockstep.sql); version 3 = the Phase 13 event
    /// (v1_8 block_comment + v1_9 block.presentation + v1_10
    /// reading_section/section_id + v1_11 reading.word_target; mirror DDL
    /// 06_phase13_lockstep.sql — deploy pre-authorized, R53); version 4 =
    /// the Phase 13b Stage 4 event (v1_12 container.word_target — the
    /// per-post extent target, S4-28.1/N36; mirror DDL
    /// 07_phase13b_lockstep.sql — deploy pre-authorized by the 13b EOL
    /// addendum, executed by the orchestrator at the consolidated
    /// post-ladder window); version 5 = the Phase 14b suite-E2EE event
    /// (the `key_vault` account table + the client's encrypted payload
    /// serializer — the eighteen encrypted-classified columns now travel
    /// as `e1:` ciphertext, so pre-14b clients and the post-wipe encrypted
    /// mirror corpus are mutually unreadable and MUST refuse each other;
    /// mirror DDL 08_phase14b_lockstep.sql — deploy is the architect's
    /// gate act, Rounds 4/5); version 6 = the Phase 14c multi-tenant
    /// event (the CLEAN REBUILD, sitting Round 4: the 18 data tables
    /// born multi-tenant with composite (owner_id, id) PKs + forced RLS;
    /// the RPCs rewritten tenant-scoped with the REQUIRED active-key-id
    /// fence parameter — new signatures, so a pre-14c client's calls
    /// have no function to land on even before the marker refusal; the
    /// `entitlement` table; mirror DDL 09_phase14c_multitenant.sql —
    /// deploy is the architect's gate act at the author's explicit go,
    /// behind the A1 rail); version 7 = the Phase 13j purge event (v1_14
    /// `purge_intent` — the ONE synced purge table, her round-8
    /// pre-authorization — plus the server-only `device_cursor` /
    /// `purged_row` tables, `sync_horizon()`, the purge-execution RPC,
    /// the pull-RPC cursor upsert and the push-RPC's typed 'purged'
    /// refusal; mirror DDL 10_phase13j_purge.sql — FINALIZED in batch
    /// 6b, deployed ONLY at the architect's one-window, which bundles
    /// the Mac + phone refreshes). **Bump this
    /// constant together with the mirror file's marker in every future
    /// lockstep event** — the DDL pin (`AuthRLSDDLTests`) fails the build
    /// if they drift.
    public static let lockstepVersion = 7
    /// The synced tables, in FK-dependency-friendly apply order: parents
    /// before children wherever the graph is acyclic. (`container`⇄`block`⇄
    /// `variant` are mutually circular by design — the apply transaction runs
    /// with deferred FKs, so within one batch the order is a determinism
    /// nicety, not a correctness requirement; across batches the read side
    /// tolerates stragglers, SyncSpec §5.)
    public static let tables: [SyncTable] = [
        SyncTable(
            "container",
            plain: [
                "id", "owner_id", "kind", "profile", "entry_date", "locked",
                "locked_at", "segmentation_default", "last_touched_at",
                "last_major_revision_at", "churn_accumulator",
                "baseline_length", "word_target", "created_at", "updated_at",
                "archived_at", "deleted_at",
            ],
            encrypted: ["title", "floating_notes"]),
        SyncTable(
            "block",
            plain: [
                "id", "owner_id", "default_variant_id", "last_container_id",
                "created_at", "updated_at", "archived_at", "deleted_at",
            ],
            encrypted: ["name", "presentation"]),
        SyncTable(
            "variant",
            plain: [
                "id", "block_id", "parent_variant_id", "status", "locked",
                "fan_position", "created_at", "updated_at", "deleted_at",
            ],
            encrypted: ["working_text", "label"]),
        SyncTable(
            "commit_point",
            plain: ["id", "variant_id", "kind", "created_at"],
            encrypted: ["text", "message"],
            hasTombstone: false),
        SyncTable(
            "tag",
            plain: [
                "id", "owner_id", "parent_id", "created_at", "updated_at",
                "deleted_at",
            ],
            encrypted: ["name", "path"]),
        SyncTable(
            "edge",
            plain: [
                "id", "source_block_id", "target_block_id", "type",
                "origin_op", "created_at", "deleted_at",
            ]),
        SyncTable(
            "container_block",
            plain: [
                "id", "container_id", "block_id", "position",
                "chosen_variant_id", "created_at", "updated_at", "deleted_at",
            ]),
        SyncTable(
            "reading",
            plain: [
                "id", "owner_id", "kind", "profile", "sort_field", "sort_dir",
                "grouping_tag_id", "max_posts", "word_target", "locked",
                "created_at", "updated_at", "deleted_at",
            ],
            encrypted: ["name", "query_spec"]),
        // Phase 13 (A1): sections precede reading_post — the membership's
        // section_id FK points here, and apply order is FK-friendly.
        SyncTable(
            "reading_section",
            plain: [
                "id", "reading_id", "position", "created_at", "updated_at",
                "deleted_at",
            ],
            encrypted: ["name"]),
        SyncTable(
            "reading_post",
            plain: [
                "id", "reading_id", "post_id", "position", "section_id",
                "created_at", "deleted_at",
            ]),
        SyncTable(
            "post_tag",
            plain: ["id", "tag_id", "post_id", "created_at", "deleted_at"]),
        SyncTable(
            "block_tag",
            plain: ["id", "tag_id", "block_id", "created_at", "deleted_at"]),
        SyncTable(
            "reference",
            plain: [
                "id", "owner_id", "container_id", "kind", "position",
                "created_at", "updated_at", "deleted_at",
            ],
            encrypted: ["name", "url", "view_state"],
            excludedColumns: ["file_bookmark"]),
        // Phase 11, Step A1 (the one lockstep event, SyncSpec §12):
        // canvas positions — metadata CAS, pure-duplicate repair on the
        // live-unique (container_id, block_id) — and saved lenses (sparse
        // selection profiles; lens_choice repairs as a pure duplicate on
        // the live-unique (lens_id, block_id); a lens itself has no
        // natural key — duplicate names are legal, no repair class).
        // Canvas x/y stay PLAIN (THE DESIGN: spatial metadata, no prose).
        SyncTable(
            "canvas_layout",
            plain: [
                "id", "owner_id", "container_id", "block_id", "x", "y",
                "created_at", "updated_at", "deleted_at",
            ]),
        SyncTable(
            "lens",
            plain: [
                "id", "owner_id", "container_id", "created_at", "updated_at",
                "deleted_at",
            ],
            encrypted: ["name"]),
        SyncTable(
            "lens_choice",
            plain: [
                "id", "lens_id", "block_id", "variant_id", "created_at",
                "updated_at", "deleted_at",
            ]),
        // Phase 13, Step A1 (the one lockstep event, SyncSpec §12): block
        // comments — working notes; metadata CAS, NO uniqueness, no repair
        // class (text races converge server-version-wins, deliberately not
        // S5 — that doctrine is scoped to variant.working_text). Its
        // sibling `reading_section` sits above, before reading_post (FK
        // order); same no-natural-key, no-repair posture, and the
        // membership's dangling section_id reads as unsectioned (the
        // chosen-variant fallback class) so no repair rides the pointer.
        SyncTable(
            "block_comment",
            plain: [
                "id", "owner_id", "block_id", "created_at", "updated_at",
                "deleted_at",
            ],
            encrypted: ["text"]),
        // `setting` values stay PLAIN (THE DESIGN's disclosure list: enum
        // semantics, no prose).
        SyncTable(
            "setting", primaryKey: "key", plain: ["key", "value"],
            hasTombstone: false),
        // Phase 13j batch 6b (the ONE lockstep event, marker 6→7): the
        // purge intent — "this is going, everywhere". EVERY column PLAIN
        // by design: ids, an enum table name, and timestamps — no user
        // words exist in the row, so the E2EE disclosure envelope gains
        // exactly one named line ("purge_intent: ids/enums only") and
        // nothing to seal. Live-unique (table_name, row_id) repairs as a
        // pure duplicate (smaller id wins — Repairs.swift; the act is
        // idempotent by nature). No FKs, so registry position is free;
        // last keeps the apply-order walk trivially satisfied.
        SyncTable(
            "purge_intent",
            plain: [
                "id", "owner_id", "table_name", "row_id", "requested_at",
                "created_at", "updated_at", "deleted_at",
            ]),
    ]

    /// Local-only machinery that must never appear in a payload or a mirror.
    /// The registry/completeness walks (`SyncSchemaTests`) pin that this set
    /// is exactly the schema minus the synced registry. (The retired Fragments
    /// bridge's `bridge_state`/`bridge_day` left this list when
    /// `v1_16_drop_bridge_tables` dropped them, 2026-09-04.)
    public static let localOnlyTables: Set<String> = [
        "sync_outbox", "sync_state", "sync_row_seq", "_sync_applying",
    ]

    private static let byName: [String: SyncTable] = Dictionary(
        uniqueKeysWithValues: tables.map { ($0.name, $0) })

    public static func table(named name: String) -> SyncTable? {
        byName[name]
    }

    // MARK: Column catalog (the payload-to-SQL injection guard)

    private static let catalogLock = NSLock()
    /// Table → its live column names, introspected once per process. The
    /// schema is fixed after migration and identical across every
    /// `AppDatabase` in a process, so a process-wide cache is sound.
    nonisolated(unsafe) private static var columnCatalog: [String: Set<String>] = [:]

    /// The actual columns of a registered table. Callers validate payload
    /// column names against this before interpolating them into SQL —
    /// payloads cross the network, and Phase 14's auth hardening has not
    /// closed that trust boundary yet.
    static func liveColumns(of tableName: String, _ db: Database) throws -> Set<String> {
        catalogLock.lock()
        if let cached = columnCatalog[tableName] {
            catalogLock.unlock()
            return cached
        }
        catalogLock.unlock()
        // `tableName` is registry-validated by every caller before this.
        let names = Set(
            try Row.fetchAll(db, sql: "PRAGMA table_info(\(tableName))")
                .map { $0["name"] as String })
        catalogLock.lock()
        columnCatalog[tableName] = names
        catalogLock.unlock()
        return names
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

/// Phase 14c — the server-refusal markers. The 09 RPCs RAISE with these
/// tokens leading the message; the transport classifies a refusal body by
/// marker into the matching typed `SyncError`, and the DDL pin
/// (`AuthRLSDDLTests`) holds the SQL and these constants together so
/// neither side can drift. Tokens, not sentences: the human wording may
/// evolve server-side, the marker may not.
public enum SyncServerRefusalMarker {
    /// The vault-key-id fence (THE DESIGN item 2): the caller's presented
    /// corpus key id does not match the account's current `key_vault`
    /// row (or no vault row exists). Surfaces as the CF-16 replaced
    /// state.
    public static let staleKeyFence = "VARIORUM_STALE_KEY_FENCE"
    /// The tier gate (THE DESIGN item 5): no active hosted_sync
    /// entitlement on the account.
    public static let notEntitled = "VARIORUM_NO_ENTITLEMENT"
}

public enum SyncError: Error, Equatable, Sendable {
    /// A BLOB column reached a payload — only `reference.file_bookmark` is
    /// BLOB and it is excluded, so this is a schema/registry drift signal.
    case blobInPayload
    /// A payload named a table the registry doesn't know.
    case unknownTable(String)
    /// A payload's columns are missing its own primary key.
    case missingPrimaryKey(table: String)
    /// A payload carried a column the local schema doesn't have. Column
    /// names are interpolated into SQL, so this is the injection guard for
    /// the server-to-client trust boundary (Phase 5 review; auth hardening
    /// is Phase 14) — and it gives cross-schema-version payloads a defined
    /// failure instead of silent SQL drift.
    case unknownColumn(table: String, column: String)
    /// SyncSpec §12: the mirror's deployed schema marker disagrees with
    /// this client's migration set. The round refuses — outbox intact,
    /// cursor unmoved — until the lockstep completes (mirror first, then
    /// every client). Stalling is safe by design; guessing is the one
    /// forbidden move.
    case schemaLockstepMismatch(client: Int, server: Int)
    /// Phase 14b: the device's encryption keys are absent or locked (not
    /// enrolled, or the Keychain item is unavailable). The round refuses
    /// BEFORE any network contact — outbox intact, cursor unmoved — in the
    /// §12 refusal grammar. Post-14b there is NO plaintext mode.
    case encryptionKeysUnavailable
    /// Phase 14b policy: a value arrived WITHOUT the `e1:` ciphertext
    /// format in an encrypted-classified column. Wipe-and-repush (R-2)
    /// guarantees this never fires in practice — firing signals a real
    /// fault (a pre-14b writer, or corruption), so the round refuses with
    /// the row named rather than passing unverified bytes through.
    case unencryptedValueInEncryptedColumn(table: String, rowID: String, column: String)
    /// Phase 14b: sealing or opening a payload value failed (wrong key,
    /// tampered/truncated ciphertext, a foreign format version, a non-text
    /// value in an encrypted-classified column). Nothing unauthenticated
    /// is ever applied; the round refuses with the row named.
    case payloadCryptoFailure(table: String, rowID: String, column: String, detail: String)
    /// Phase 14c (THE DESIGN item 2): the server's vault-key-id fence
    /// refused the round — this device's held corpus key id no longer
    /// matches the account's current `key_vault` row (the account was
    /// re-keyed elsewhere, or the vault is mid-replacement). The whole
    /// round refuses — outbox intact, cursor unmoved — and the app
    /// surfaces the CF-16 keys-were-replaced state; re-enrollment with
    /// the current passphrase is the road back.
    case encryptionKeysReplaced
    /// Phase 14c (THE DESIGN item 5): the server's entitlement gate
    /// refused the round — hosted sync is not active on this account.
    /// Outbox intact, cursor unmoved; local writing is untouched (the
    /// signed-out-reads-as-normal principle: sync is the tier, the app
    /// is not).
    case syncNotEntitled
    /// Phase 14c ladder R1-1: a key replacement (CF-8) started on THIS
    /// device and never completed — the persisted `AccountRekeyMarker`
    /// survives a crash/relaunch mid-road. The round refuses — outbox
    /// intact, cursor unmoved — because rounds against a mid-re-key
    /// account can silently strand the hosted copy (a truncated-but-not-
    /// reinitialized mirror reads idle while near-empty; an untruncated
    /// old-key corpus poisons every later enrollment). Running the
    /// re-key door again completes the road and clears the marker.
    case accountRekeyIncomplete
    /// Phase 13j (round 10 — the SAY-SO-FIRST returner): this device's
    /// purge-ledger scan point sits BELOW the ledger's coverage floor —
    /// it was away long enough that purge records it needs have been
    /// pruned, so it cannot be reconciled row-by-row. The janitor refuses
    /// (outbox intact, cursor unmoved — the §12 refusal grammar) and the
    /// road forward is `SyncEngine.reonboardFromAccount()`: unsynced
    /// writes pushed first, then the existing `resyncReinitialize`.
    /// Unreachable in production until ledger pruning exists (the floor
    /// stays 0); proven against the fake server's settable floor.
    case deviceLeftBehindReloadRequired(floor: Int64, scanPoint: Int64)
}

extension SyncError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .blobInPayload:
            return "a BLOB column reached a sync payload (schema/registry drift)"
        case .unknownTable(let table):
            return "sync payload names an unregistered table '\(table)'"
        case .missingPrimaryKey(let table):
            return "sync payload for '\(table)' is missing its primary key"
        case .unknownColumn(let table, let column):
            return "sync payload for '\(table)' carries unknown column '\(column)'"
        case .schemaLockstepMismatch(let client, let server):
            return "Sync paused: the app and the server are on different schema versions "
                + "(app \(client), server \(server)). Finish the schema update on the lagging "
                + "side; nothing is lost while paused (SyncSpec §12)."
        case .encryptionKeysUnavailable:
            return "Sync paused: this device's encryption keys are locked or not enrolled. "
                + "Enter your encryption passphrase to unlock sync; nothing is lost while paused."
        case .unencryptedValueInEncryptedColumn(let table, let rowID, let column):
            return "Sync refused: '\(table)' row '\(rowID)' arrived with an unencrypted value "
                + "in encrypted column '\(column)'. End-to-end encryption is mandatory — the "
                + "round is refused so nothing unverified lands; outbox and cursor are untouched."
        case .payloadCryptoFailure(let table, let rowID, let column, let detail):
            return "Sync refused: '\(table)' row '\(rowID)' column '\(column)' failed to "
                + "encrypt/decrypt (\(detail)). Nothing unverified lands; outbox and cursor "
                + "are untouched."
        case .encryptionKeysReplaced:
            return "Sync paused: this account's encryption keys were replaced — this device "
                + "still holds the previous keys. Re-enroll with the current encryption "
                + "passphrase; nothing is lost while paused."
        case .syncNotEntitled:
            return "Sync paused: hosted sync isn't active on this account. Your writing "
                + "stays safe on this device; sync resumes once the plan is active."
        case .accountRekeyIncomplete:
            return "Sync paused: replacing this account's encryption keys didn't finish on "
                + "this device. Run Replace Encryption Keys again (Account → Encryption) to "
                + "complete it; nothing is lost while paused."
        case .deviceLeftBehindReloadRequired:
            // Her round-10 wording class, verbatim-faithful: "this phone
            // has been away a while — it will reload from your account;
            // anything written here first gets saved up".
            return "This device has been away a while — it needs to reload from your "
                + "account. Anything written here first gets saved up; nothing typed is "
                + "lost. Nothing syncs until the reload runs."
        }
    }
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
        // Column names came off the wire and are interpolated below —
        // validate every one against the introspected schema (Phase 5
        // review MAJOR: the server-to-client injection surface).
        let allowed = try SyncSchema.liveColumns(of: table.name, db)
        for name in columns.keys where !allowed.contains(name) {
            throw SyncError.unknownColumn(table: table.name, column: name)
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
