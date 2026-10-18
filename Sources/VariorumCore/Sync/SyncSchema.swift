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
    /// the Mac + phone refreshes); version 8 = the pre-13x POSTURES event
    /// (the design's §3.10, decisions 12 / 31 / 32: the KEY PROOF on every
    /// mutating RPC and the two read RPCs — `sync_push` / `sync_pull` /
    /// `sync_horizon` / `sync_purge_ledger` / `sync_purge_execute` /
    /// `account_data_truncate` gain `key_proof` beside `active_key_id`,
    /// the OLD signatures dropped first; the NEW `sync_reencrypt`
    /// (version-neutral re-encryption) and `key_vault_update` (the ONE
    /// vault write road, the PostgREST PATCH road CLOSED); the vault's
    /// six nullable columns incl. `rotation_started_seq`; mirror DDL
    /// 11_pre13x_postures.sql — deploy is the orchestrator's window under
    /// her standing pre-authorization, immediately before batch 2's
    /// migration + both installs); version 9 = the Phase 13y PER-TENANT
    /// `server_seq` event (the 14c I-1 disclosure closed: `server_seq`
    /// becomes per-owner — the `sync_tenant_seq` counter table + the
    /// row-locked `next_tenant_seq`, every mint site swapped (the stamp
    /// trigger, `sync_purge_execute`'s ledger seq, `key_vault_update`'s
    /// rotation seq), each owner's counter floored at the GREATEST of
    /// their data-row seqs / device cursors / ledger seqs / a standing
    /// rotation seq so NO cursor resets; `sync_pull` reordered so
    /// `key_proof` is defaultless (NIT-4 — zero wire change, PostgREST
    /// resolves by name); the rotation completion guard folded into the
    /// canonical `key_vault_update`; the global `sync_server_seq`
    /// DROPPED fail-loud; CLIENT SEMANTICS UNCHANGED — the Step 0 survey
    /// verdicted every seq comparison within-account, so per-tenant
    /// numbering preserves every order any client observes; PLUS, in the
    /// SAME marker-9 event, UNIT B's three halves per the ruled memo and
    /// QUESTIONS #144: the KEY-PROOF CHALLENGE — the static bearer proof
    /// retires for a per-request `HMAC(kp2, nonce ‖ ':' ‖ rpc_name)` over
    /// server-issued single-use nonces (`sync_challenge`), kp2 in
    /// Supabase Vault, enrollment once via `key_proof_enroll`, every
    /// gated RPC's signature gaining the defaultless `challenge`; the
    /// MINIMAL ABUSE GUARD (`sync_write_budget` — 2,000/call · 500,000
    /// lifetime pool · 50,000/24h, typed VARIORUM_WRITE_QUOTA); and the
    /// destructive RPCs' 10-minute amr RE-AUTH window; mirror DDL
    /// 12_phase13y_tenant_seq.sql — deploy is the orchestrator's ONE
    /// end-of-phase window under her standing pre-authorization,
    /// R-13y-2); version 10 = the Phase 13i-a WINGS/SHELVES/BOOKS event
    /// (the ONE 13i bundle — the sitting record §11, the 13i-a plan:
    /// the `wing` + `shelf` tables born multi-tenant; the additive
    /// mirror columns — reading's nine, container.wing_id, tag.wing_id,
    /// reading_post.status; the six registry-carrying RPC bodies
    /// redefined with the two tables, key_vault_update's ciphertext
    /// registry gaining wing.name + shelf.name/glyph; AND the marker
    /// fences the CLIENT-side recasts that ride v1_18 — the
    /// gathering/book kind values, the v2 query_spec format and the
    /// per-wing tag uniqueness are meaning changes a marker-9 client
    /// must never meet; mirror DDL 13_phase13i_wings.sql — deploy is
    /// HER window, the 13i-a plan §8's checklist, never pre-authorized);
    /// version 12 = the Phase 13i-e BOOK ARCHIVE event (her kickoff
    /// ruling R-13ie-1, the 13i-e plan: ONE additive column —
    /// `reading.archived_at`, the `container.archived_at` class, PLAIN —
    /// no table, no RPC change; the marker moves because a marker-11
    /// client's CAS whole-row push would silently null the column out
    /// from under a marker-12 writer; mirror DDL 15_phase13ie_archive.sql
    /// — deploy is HER window, the 13i-e deploy checklist, never
    /// pre-authorized);
    /// version 13 = the Phase 13n-b PRIVATE MARK event (her ruling
    /// R-13nb-4, the 13n-b plan's sitting record: TWO additive columns —
    /// `container.ai_private_at` + `reading.ai_private_at`, the
    /// `archived_at` class, PLAIN — the AI fence's third leg; no table,
    /// no RPC change; the marker moves because a marker-12 client's CAS
    /// whole-row push would silently null the columns out from under a
    /// marker-13 writer; mirror DDL 16_phase13nb_private.sql — deploy is
    /// HER closeout window, never pre-authorized).
    /// **Bump this
    /// constant together with the mirror file's marker in every future
    /// lockstep event** — the DDL pin (`AuthRLSDDLTests`) fails the build
    /// if they drift.
    public static let lockstepVersion = 13
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
                "baseline_length", "word_target", "wing_id", "created_at",
                "updated_at", "archived_at",
                // 13n-b (v1_25, marker 12→13 — R-13nb-4): the per-NOTE
                // PRIVATE mark, the AI fence's own-row leg. PLAIN — a bare
                // timestamp, the archived_at class (disclosed structure:
                // that a note is marked, never which or what it says).
                "ai_private_at",
                "deleted_at",
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
                "id", "owner_id", "parent_id", "wing_id", "created_at",
                "updated_at", "deleted_at",
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
        // 13i-a (v1_18, the marker-10 bundle — the sitting record §11):
        // wings and shelves precede reading (reading.shelf_id and
        // reading.wing_id point at them; FK-friendly order). The virtual
        // Home wing ('') never syncs because it never exists as a row.
        // Wing/shelf NAMES are hers (encrypted); the shelf GLYPH is her
        // chosen grapheme (encrypted — content-adjacent, and a one-char
        // plain column would leak a distinctive marker per shelf); role /
        // positions / ids are structure (plain). An apply that meets an
        // ABSENT new column (a mirror row from before the window) reads it
        // as its default ('' wing, 'member' status) — pinned.
        SyncTable(
            "wing",
            plain: [
                "id", "owner_id", "position", "created_at", "updated_at",
                "deleted_at",
            ],
            encrypted: ["name"]),
        SyncTable(
            "shelf",
            plain: [
                "id", "owner_id", "wing_id", "role", "position", "created_at",
                "updated_at", "deleted_at",
            ],
            encrypted: ["name", "glyph"]),
        SyncTable(
            "reading",
            plain: [
                "id", "owner_id", "kind", "profile", "sort_field", "sort_dir",
                "grouping_tag_id", "max_posts", "word_target", "locked",
                // 13i-a: the bundle's reading columns — ids, flags, stamps,
                // positions; disclosed structure, never prose (the
                // query_spec RULE stays encrypted as before — its v2 format
                // is ids and operators, sealed all the same).
                "wing_id", "shelf_id", "shelf_position", "starred", "owned",
                "sealed_at", "hide_owned", "intake_seating", "auto_tag_id",
                // 13i-c (v1_20, marker 10→11 — R-13ic-1): the CHOSEN
                // multi-tag outflow, a JSON array of tag ids. PLAIN like
                // the single-tag column it retires (ids, content-free —
                // PROVISIONAL P-13ic-8); `auto_tag_id` stays classified
                // because it stays a column, retired-as-read.
                "auto_tag_ids",
                // 13i-e (v1_21, marker 11→12 — R-13ie-1): BOOK ARCHIVE on
                // the row. PLAIN — a bare timestamp, the container.archived_at
                // class (disclosed structure: that a book is put away, never
                // which one or what it holds).
                "archived_at",
                // 13n-b (v1_25, marker 12→13 — R-13nb-4): the per-BOOK
                // PRIVATE mark — a live private book fences every live
                // member (privacy wins ties). PLAIN — a bare timestamp,
                // the same disclosure class as archived_at.
                "ai_private_at",
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
                "status", "created_at", "deleted_at",
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
        "protection_record",  // VX-306 U1a: v1_31 (v1_30 at U1a; renumbered at the fold of VX-348 — its v1_30 was on main first), the library's protection facts (P-VX306-K6)
    ]

    /// DERIVED machinery — equally local-only under SYNC (never in a payload
    /// or a mirror; the completeness walk subtracts this set beside the one
    /// above and pins the two disjoint) but KEPT by the plaintext export:
    /// the search index is derivable from the rows the export carries, and
    /// the no-lock-in file should open with WORKING full-text search and
    /// satisfied capture triggers rather than growing the outbox's recorded
    /// broken-trigger consequence a second instance (13o §FORK RULINGS,
    /// 2026-10-06 — the derived-set ruling; the architect's seam-2 commit).
    /// `StorePlaintextExport` drops `localOnlyTables` ALONE.
    public static let derivedTables: Set<String> = SearchIndex.tables

    private static let byName: [String: SyncTable] = Dictionary(
        uniqueKeysWithValues: tables.map { ($0.name, $0) })

    public static func table(named name: String) -> SyncTable? {
        byName[name]
    }

    /// pre-13x ladder round 1, F1 (BLOCKER-1): the tables that CARRY
    /// CIPHERTEXT — at least one encrypted-classified column. The rotation's
    /// completion guard (`key_vault_update`'s clearing arm, the fake's
    /// twin, the Mac emulation) counts rows of THESE tables only below the
    /// rotation seq: an all-plain row under the "previous key" is under no
    /// key at all (the seam returns a plain-table row untouched), so its
    /// visibility inside the A5 window must never hold a completion
    /// hostage; a ciphertext row left below the seq is the wedged
    /// changefeed. The maintenance SQL's list is pinned equal to this one
    /// (`AuthRLSDDLTests`).
    public static var tablesCarryingCiphertext: [SyncTable] {
        tables.filter { !$0.encryptedColumns.isEmpty }
    }

    /// F1 (the coordinator's refinement — "is there a guarantee the horizon
    /// always clears?"): whether ONE ROW carries ciphertext — at least one
    /// of its table's encrypted columns is NOT NULL (an `e1:` value). A row
    /// of an encrypted table whose encrypted columns are all NULL (a block
    /// with no name and no presentation) is under no key: the seam opens it
    /// untouched under either key, so the completion guard never counts it
    /// — the guard counts exactly the rows the walk must re-seal, which are
    /// a subset of the rows the walk re-stamps (it re-stamps every row
    /// below the seq, this one included). The maintenance SQL's per-table
    /// predicate (`t.<col> is not null or …`) is this function's letter.
    public static func rowCarriesCiphertext(_ row: SyncRow) -> Bool {
        guard let table = table(named: row.table) else { return false }
        return table.encryptedColumns.contains { column in
            if case .text? = row.columns[column] { return true }
            return false
        }
    }

    // MARK: Column catalog (the payload-to-SQL injection guard)

    private static let catalogLock = NSLock()
    /// Table → its live column names, introspected once per process. The
    /// schema is fixed after migration and identical across every
    /// `AppDatabase` in a process, so a process-wide cache is sound.
    nonisolated(unsafe) private static var columnCatalog: [String: Set<String>] = [:]
    nonisolated(unsafe) private static var notNullDefaultedCatalog: [String: Set<String>] = [:]

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

    /// The columns the LOCAL schema declares NOT NULL **with a default** —
    /// the set an arriving EXPLICIT NULL must normalize against (13i-a
    /// ladder R1 B-2). A mirror row pushed BEFORE a lockstep event that
    /// added such a column holds NULL there, and `to_jsonb` serves it as a
    /// PRESENT null — the client's additive-column tolerance must therefore
    /// cover null-as-absent, not absence alone, or the first old row aborts
    /// the apply transaction (`SQLITE_CONSTRAINT_NOTNULL`) and the pull
    /// refuses forever. Schema-introspected so every FUTURE additive
    /// NOT-NULL-defaulted column inherits the tolerance for free.
    static func notNullDefaultedColumns(of tableName: String, _ db: Database) throws -> Set<String> {
        catalogLock.lock()
        if let cached = notNullDefaultedCatalog[tableName] {
            catalogLock.unlock()
            return cached
        }
        catalogLock.unlock()
        let names = Set(
            try Row.fetchAll(db, sql: "PRAGMA table_info(\(tableName))")
                .filter { ($0["notnull"] as Int64) == 1 && ($0["dflt_value"] as String?) != nil }
                .map { $0["name"] as String })
        catalogLock.lock()
        notNullDefaultedCatalog[tableName] = names
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
    /// pre-13x (decision 12 — THE KEY PROOF): the presented `key_proof`
    /// does not hash to the account's `key_vault.key_proof_hash` (or is
    /// absent / malformed) — a session without the master key gets
    /// nothing from the mirror. Surfaces as `SyncError.keyProofRefused`.
    public static let keyProofRequired = "VARIORUM_KEY_PROOF_REQUIRED"
    /// pre-13x (decision 32 — one rotation at a time): `key_vault_update`
    /// was asked to set a DIFFERENT previous corpus key while one stands.
    public static let rotationInProgress = "VARIORUM_ROTATION_IN_PROGRESS"
    /// pre-13x: `key_vault_update` found no vault row for the caller.
    public static let vaultAbsent = "VARIORUM_VAULT_ABSENT"
    /// pre-13x: `key_vault_update`'s revision CAS matched zero rows — the
    /// vault moved under the caller (ladder R1-2, now inside the RPC).
    public static let vaultRevisionConflict = "VARIORUM_VAULT_REVISION_CONFLICT"
    /// pre-13x ladder round 1, F1 (BLOCKER-1): `key_vault_update` was asked
    /// to CLEAR the previous corpus key while a row of the caller's
    /// partition in a table that carries ciphertext still sits BELOW the
    /// rotation seq — a straggler the A5 visibility window hid from the
    /// walk. Completion is "no row of mine below it" (decision 31): the
    /// server refuses, the client re-walks. Deployed by the maintenance
    /// artifact `maintenance/pre13x-ladder-rotation-clearing-guard.sql`.
    public static let rotationRowsRemain = "VARIORUM_ROTATION_ROWS_REMAIN"
    /// 13y UNIT B (the ruled memo §3): the account holds no Vault-held
    /// per-request proof secret yet — raised BEFORE any nonce is consumed,
    /// so the signer's enroll road retries under a live challenge.
    public static let keyProofEnroll = "VARIORUM_KEY_PROOF_ENROLL"
    /// 13y UNIT B: `key_proof_enroll` found the account's secret already
    /// landed — the racing loser's outcome, treated as success (its kp2
    /// is the same value; memo §7 edge 1).
    public static let keyProofAlreadyEnrolled = "VARIORUM_KEY_PROOF_ALREADY_ENROLLED"
    /// 13y UNIT B: the presented challenge is unknown, already consumed,
    /// or expired (the 5-minute server-clock TTL) — the signer fetches
    /// fresh and retries ONCE, then surfaces the §12 grammar.
    public static let keyProofStaleChallenge = "VARIORUM_KEY_PROOF_STALE_CHALLENGE"
    /// 13y UNIT B (the memo §4; QUESTIONS #144(b)): the minimal abuse
    /// guard refused the push — the per-call cap or the daily window.
    /// Carries `retry_after_seconds=<n>` in the message.
    public static let writeQuota = "VARIORUM_WRITE_QUOTA"
    /// 13y UNIT B (the memo §5; QUESTIONS #144(c)): a destructive RPC
    /// (`account_data_truncate` / `sync_purge_execute`) demands a session
    /// re-authenticated by password within 10 minutes.
    public static let reauthRequired = "VARIORUM_REAUTH_REQUIRED"
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
    /// device and never completed — the persisted per-step `RotationMarker`
    /// (pre-13x 2b; the 14c `AccountRekeyMarker`'s successor) survives a
    /// crash/relaunch mid-road. The round refuses — outbox
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
    /// pre-13x (decision 12 — THE KEY PROOF): the server refused this
    /// device's proof of the master key — the account's keys were
    /// replaced elsewhere (a rotation this device has not followed), or
    /// the device holds no master at all. The whole round refuses —
    /// outbox intact, cursor unmoved (the §12 refusal grammar); the road
    /// back is the FOLLOW: enter the passphrase once to pick up the new
    /// keys (the design's §7; the surface's banner is the copy file's).
    case keyProofRefused
    /// pre-13x 2b (§4 step 1 — the named `pullToHead` primitive): the
    /// changefeed could not be read to head because a pull kept STALLING
    /// at a straggler (a row whose referents another device still owes).
    /// A rotation must not begin over an incomplete picture; the outbox
    /// and the cursor are untouched, and the next round self-heals when
    /// the owing device drains.
    case pullStalled(cursor: Int64)
    /// pre-13x 2b (§4 step 1): the outbox still holds rows — a rotation
    /// (or a posture switch) refuses until this device's own writing has
    /// reached the server, so nothing typed here is ever re-encrypted from
    /// a stale copy or pushed under a key the fence then refuses.
    case outboxNotEmpty(pending: Int)
    /// 13y UNIT B (memo §3): the account has not enrolled its per-request
    /// proof secret. The `SyncChallengeSigner` handles it TRANSPARENTLY
    /// (the one enroll road, then a retry); surfacing means enrollment
    /// itself keeps refusing — the round fails visibly, outbox intact.
    case keyProofEnrollRequired
    /// 13y UNIT B: the enroll road found the secret already landed — a
    /// racing device won; the signer treats it as success (memo §7 edge 1)
    /// and it never reaches a round's status.
    case keyProofAlreadyEnrolled
    /// 13y UNIT B: the challenge was unknown, consumed, or expired TWICE
    /// (the signer already fetched fresh and retried once) — the round
    /// refuses in the §12 grammar and the next trigger retries clean.
    case keyProofChallengeStale
    /// 13y UNIT B (memo §4; QUESTIONS #144(b)): the server's minimal
    /// abuse guard refused the push. Outbox intact, cursor unmoved —
    /// nothing is lost; sync resumes when the window passes.
    case writeQuotaExceeded(retryAfterSeconds: Int?)
    /// 13y UNIT B (memo §5; QUESTIONS #144(c)): a destructive act needs a
    /// session re-authenticated by password within the 10-minute window.
    case reauthRequired
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
            // pre-13x 2b: the per-step rotation marker (`RotationMarker`) —
            // entering Castle or Replace All Keys started here and has not
            // finished; the acting device resumes it at the failed step.
            return "Sync paused: replacing this account's encryption keys didn't finish on "
                + "this device. It resumes from Settings ▸ Protection (or Replace All Keys); "
                + "nothing is lost while paused."
        case .pullStalled(let cursor):
            return "Sync couldn't read everything from the server just now — another "
                + "device still owes some of it (paused at \(cursor)). Nothing is lost; "
                + "try again in a moment."
        case .outboxNotEmpty(let pending):
            return "This device still has \(pending) change\(pending == 1 ? "" : "s") to "
                + "send — wait for sync to finish, then try again."
        case .deviceLeftBehindReloadRequired:
            // Her round-10 wording class, verbatim-faithful: "this phone
            // has been away a while — it will reload from your account;
            // anything written here first gets saved up".
            return "This device has been away a while — it needs to reload from your "
                + "account. Anything written here first gets saved up; nothing typed is "
                + "lost. Nothing syncs until the reload runs."
        case .keyProofRefused:
            // The design's §7 un-followed state; the surface's banner
            // wording is `pre-13x-copy.md`'s (batch 4 renders it) — this
            // is the engine's own status sentence.
            return "Sync is paused until you enter your passphrase once — your keys were "
                + "replaced on another device. Nothing is lost while paused."
        case .keyProofEnrollRequired:
            return "Sync couldn't finish setting up this account's security check — it "
                + "retries on the next sync. Nothing is lost while it waits."
        case .keyProofAlreadyEnrolled:
            // Never a round's status (the signer swallows it); the honest
            // sentence exists so a stray surface never prints a raw case.
            return "This account's security check is already set up."
        case .keyProofChallengeStale:
            return "Sync couldn't complete a security check just now — it retries on the "
                + "next sync. Nothing is lost while it waits."
        case .writeQuotaExceeded(let retryAfterSeconds):
            // The memo §4's wording (13s re-words); the retry-after rides
            // when the server named one.
            let wait = retryAfterSeconds.map { seconds -> String in
                let minutes = max(1, seconds / 60)
                return " It resumes automatically (about \(minutes) minute\(minutes == 1 ? "" : "s"))."
            } ?? " It resumes automatically."
            return "Sync is paused — this account hit today's write limit; nothing is "
                + "lost.\(wait)"
        case .reauthRequired:
            return "This needs a fresh sign-in — confirm your account password and try "
                + "again."
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
        // 13i-a (ladder R1 B-2): an arriving EXPLICIT NULL in a column the
        // local schema declares NOT NULL WITH a default is a pre-event
        // mirror row's "never set" — it lands as the default (dropped from
        // the write set: an INSERT takes the DDL default; an UPDATE keeps
        // the local value, which for such a row IS the default). Without
        // this, the first pre-window `container` row aborts a fresh
        // device's whole first pull.
        var columns = self.columns
        let defaulted = try SyncSchema.notNullDefaultedColumns(of: table.name, db)
        for (name, value) in columns where value == .null && defaulted.contains(name) {
            columns.removeValue(forKey: name)
        }
        let names = columns.keys.sorted()
        // sync_version joins the assignment list directly so the statement
        // stays well-formed even if the normalize above left only the PK.
        let updateAssignments = (names
            .filter { $0 != table.primaryKey }
            .map { "\($0) = ?" } + ["sync_version = ?"])
            .joined(separator: ", ")
        let updateArguments = names.filter { $0 != table.primaryKey }.map { columns[$0]!.databaseValue }
        try db.execute(
            sql: """
                UPDATE \(table.name) SET \(updateAssignments)
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
