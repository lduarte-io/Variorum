import Foundation
import GRDB

/// **THE MCP DOOR's GRANTS STORE** (13n-b, A-5/A-6 — the plan
/// `notes/plans/phase-13n-b-mcp-door.md`; R-13n-4's "a LOCAL-ONLY table").
///
/// Four local-only tables, born in ONE migration (`v1_24_mcp_grants`):
///
/// - `mcp_client` — a client as it named itself in `initialize`
///   (`clientInfo.name` IS the identity — A-4's ruled honest boundary: a
///   grant gates the DOOR, never a specific process); first contact is a
///   PENDING connection request with no access.
/// - `mcp_grant` — what an approved client may do (rung), where (a note, a
///   book, a wing), and for how long (once · while connected · always), with
///   its consumption and revocation stamps.
/// - `mcp_activity` — the coarse log (who, which act, which target's title,
///   allowed or refused, when) — coarse-not-forensic, pruned to a cap.
/// - `mcp_switch` — the server toggle and the ONE open-book switch (A-6:
///   boundary state lives beside the grants the rule reads, in the same
///   transaction — never the synced `setting` table, never UserDefaults).
///
/// **LOCAL-ONLY, and not derived.** Nothing here carries `sync_version`,
/// nothing is pushed, no mirror changes — zero SyncSpec §12 lockstep, the
/// marker stays 12. The family is its own registration (`tables`) beside the
/// sync registry's local-only and derived sets, and the completeness walk
/// (`SyncSchemaTests`) subtracts it by name: grants are neither sync
/// machinery (whose tables the plaintext export DROPS and the adoption road
/// recreates) nor a rebuildable index (which the export KEEPS whole). The
/// plaintext export keeps these tables EMPTY — the file's schema stays
/// whole while no grant, client or activity row travels in it
/// (`StorePlaintextExport` — A-5's exclusion: a grants list in an export
/// serves nobody).
///
/// **VX-168 — THE PER-SETUP KEY** (`v1_26_mcp_setup_keys`; the VX-156 brief
/// §12's K2, her R-VX168-1): the family's FIFTH table and one column, born
/// LOCAL-ONLY on the same road — zero lockstep, the marker untouched (13).
/// - `mcp_setup_key` — a key minted by a Copy setup command and not yet
///   presented: its HASH and when it was minted. A key lives here until the
///   first client name that presents it claims it (the row then leaves —
///   the key moves to the client), or until newer copies push it past the
///   cap.
/// - `mcp_client.setup_key_hash` — the HASH of the key bound to the name;
///   NULL = unbound (a client approved before VX-168, or released by Deny).
/// Only hashes are stored: the key itself exists on the clipboard and in the
/// client's own settings, never in the library.
///
/// **VX-188 — WHO WROTE A COMMENT** (`v1_27_mcp_comment_authors`; VX-184 U3,
/// her ruling R-VX188-1: *"local only record is fine for clarity / for
/// now"*): the family's SIXTH table, born LOCAL-ONLY on the same road — zero
/// lockstep, the marker untouched (13).
/// - `mcp_comment_author` — one row per comment a client added THROUGH THE
///   DOOR (`add_comment`, `add_comments`), written in the comment's own
///   transaction: the comment's id and the client's NAME (A-4's identity, the
///   activity log's own key). The suggest rung's `delete_comment` deletes only
///   a comment this record names as the caller's; an ABSENT row (a comment of
///   hers, one synced from another Mac, one written before this table, one
///   that travelled to a structural successor — and, since VX-260, one she has
///   EDITED: her edit removes its row) is never the caller's. No
///   foreign key to `block_comment`: that row is synced and the purge may one
///   day remove it physically, while this one is local — a record naming a
///   gone comment is harmless (nothing can delete a gone comment), a foreign
///   key would block the purge.
///
/// **VX-258 — A SETUP WAITING FOR HER OK** (`v1_28_mcp_rebind_requests`; the
/// run record `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — her
/// ruling: an "Any MCP client" key presented under a name that carries her
/// approval "re-binds only after my ok"): the family's SEVENTH table, born
/// LOCAL-ONLY on the same road — zero lockstep, the marker untouched (13).
/// - `mcp_rebind_request` — a copied key a connection presented under an
///   APPROVED name it was not copied for: the key's HASH (claimed by that
///   presentation — it has left `mcp_setup_key`), the client it would bind,
///   the version the connection declared, and when. ONE per client (a newer
///   wait replaces the older) and one per key. Her Allow binds the key to the
///   name and removes the row; her Don't allow removes it and the key is
///   forgotten. A foreign key to `mcp_client` (both rows are this family's
///   and local; a waiting row only ever names an approved client, which no
///   cap ever deletes).
///
/// **P-VX260-1, OPTION (b) — THE WORDS A CLIENT WROTE** (`v1_29_mcp_comment_words`;
/// VX-246 U1b, THE ORCHESTRATOR ON U1's HAND-BACK — her VX-260 rule: "Once she
/// has edited an AI's comment, deleting it needs EDIT", wherever she edits): ONE
/// column on `mcp_comment_author`, born LOCAL-ONLY on the family's road — zero
/// lockstep, the marker untouched (13).
/// - `mcp_comment_author.text_digest` — a digest of the comment's words as the
///   client wrote them (`MCPCommentWords.digest`), written in the comment's own
///   transaction beside the record. The comment is the client's OWN only while
///   its words still hash to it: any change to the words — her edit on any
///   device (arriving by sync, which runs no door here), another client's — and
///   deleting it needs EDIT. NULL = UNPROVEN (a record written before this
///   column): never the client's own (the strict reading — the record may name
///   a comment she has rewritten since, on any device, and nothing can tell).
///
/// **VX-393 — ONE GRANT ROW PER CLIENT × PLACE** (`v1_30_mcp_one_grant_per_place`;
/// VX-348 U5, her ruling R-VX348-6 "Upgrade in place" — the run record
/// `notes/plans/fixes/vx-348-prelaunch-sweep.md` §U5): no new table — a
/// partial unique index on `mcp_grant` and a one-time merge, born LOCAL-ONLY
/// on the family's road (zero lockstep, the marker untouched, 13).
/// - `uq_mcp_grant_standing_place` — at most ONE live STANDING grant (while
///   connected · always) per client × scope kind × scope id. A once grant is
///   one act's permission, not a standing row, so any number may stand beside
///   it; a revoked row never counts. Every grant road replaces the place's row
///   (`insertMCPGrant` revokes it on the act's stamp first), so the store
///   refusing a second is what guarantees no future road can mint a duplicate
///   silently.
///
/// **VX-549 — A GATHERING AS A GRANT PLACE** (`v1_33_mcp_gathering_grants`;
/// VX-548 batch 3, her sitting 2026-10-27 RATIFIED — the supersession of
/// VX-273's facts-only rule): `mcp_grant.scope_kind` gains `'gathering'`, born
/// LOCAL-ONLY on the family's road (zero lockstep, the marker untouched, 14).
/// A rebuild (a CHECK cannot be altered): rows and rowids copied verbatim,
/// `idx_mcp_grant_client` and `uq_mcp_grant_standing_place` re-made with their
/// text unchanged — the latter already keys a place as kind × id, so a
/// gathering is one more place under VX-393's one standing row.
/// - The merge (`v1_30MergeSQL`): a store holding duplicates from before keeps
///   each place's STRONGEST standing row and revokes the rest on one stamp
///   (never a delete) — an "always" row over a while-connected one (none of
///   those can be serving anything when a migration runs: every server start
///   revokes them all), then the higher rung, then the newer.
public enum MCPGrantSchema {
    /// The family's tables — the registration the completeness walk and the
    /// plaintext export consult.
    public static let tables: Set<String> = [
        "mcp_client", "mcp_grant", "mcp_activity", "mcp_switch", "mcp_setup_key", "mcp_comment_author",
        "mcp_rebind_request",
    ]

    /// The family in CHILD-FIRST order (`mcp_grant` references
    /// `mcp_client`) — the order a whole-family row strip must take with
    /// foreign keys on. Pinned to cover `tables` exactly.
    public static let childFirstOrder: [String] = [
        "mcp_grant", "mcp_activity", "mcp_switch", "mcp_setup_key", "mcp_comment_author", "mcp_rebind_request",
        "mcp_client",
    ]

    /// `v1_24_mcp_grants`' DDL — FROZEN with the migration that runs it (a
    /// later shape change is a NEW migration, never an edit here).
    ///
    /// `mcp_client.name` carries a BARE unique index, deliberately: the
    /// live-row partial-index convention (AppSpec §6) exists because sync
    /// tombstones would block re-creation, and these rows are never synced
    /// and never tombstoned. `mcp_grant.scope_id` is `''` for the virtual
    /// Home wing (R-13ia-2), like every other wing pointer.
    static let v1_24DDL = """
        CREATE TABLE mcp_client (
          id            TEXT PRIMARY KEY,
          name          TEXT NOT NULL,
          version       TEXT,
          state         TEXT NOT NULL DEFAULT 'pending'
                          CHECK (state IN ('pending','approved','denied')),
          first_seen_at TEXT NOT NULL,
          last_seen_at  TEXT NOT NULL,
          decided_at    TEXT
        );
        CREATE UNIQUE INDEX uq_mcp_client_name ON mcp_client(name);
        CREATE TABLE mcp_grant (
          id          TEXT PRIMARY KEY,
          client_id   TEXT NOT NULL REFERENCES mcp_client(id),
          rung        TEXT NOT NULL CHECK (rung IN ('read','suggest','write_new','edit')),
          scope_kind  TEXT NOT NULL CHECK (scope_kind IN ('note','book','wing')),
          scope_id    TEXT NOT NULL,
          duration    TEXT NOT NULL CHECK (duration IN ('once','connection','always')),
          created_at  TEXT NOT NULL,
          consumed_at TEXT,
          revoked_at  TEXT
        );
        CREATE INDEX idx_mcp_grant_client ON mcp_grant(client_id, revoked_at);
        CREATE TABLE mcp_activity (
          id           INTEGER PRIMARY KEY,
          client_name  TEXT NOT NULL,
          act          TEXT NOT NULL,
          target_kind  TEXT,
          target_id    TEXT,
          target_title TEXT,
          outcome      TEXT NOT NULL CHECK (outcome IN ('allowed','refused')),
          at           TEXT NOT NULL
        );
        CREATE TABLE mcp_switch (
          key        TEXT PRIMARY KEY,
          value      TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
        """

    /// `v1_26_mcp_setup_keys`' DDL (VX-168) — FROZEN with the migration that
    /// runs it.
    ///
    /// Both hashes are hex SHA-256 digests of a 256-bit random key (the
    /// derivation is `MCPSetupKeyRule.hash`). The unique index on the bound
    /// hash is PARTIAL only because NULL (unbound) is the common case — a
    /// key ties to ONE name, ever; like `uq_mcp_client_name` it needs no
    /// live-row clause (these rows are never synced, never tombstoned).
    static let v1_26DDL = """
        ALTER TABLE mcp_client ADD COLUMN setup_key_hash TEXT;
        CREATE UNIQUE INDEX uq_mcp_client_setup_key ON mcp_client(setup_key_hash)
          WHERE setup_key_hash IS NOT NULL;
        CREATE TABLE mcp_setup_key (
          key_hash  TEXT PRIMARY KEY,
          minted_at TEXT NOT NULL
        );
        CREATE INDEX idx_mcp_setup_key_minted ON mcp_setup_key(minted_at);
        """

    /// `v1_27_mcp_comment_authors`' DDL (VX-188, VX-184 U3) — FROZEN with the
    /// migration that runs it. The comment id is the key (ONE author per
    /// comment); the client is named as it names itself (the identity every
    /// grant and activity row already reads). Like the family's other keys it
    /// needs no live-row clause: these rows are never synced, never
    /// tombstoned.
    static let v1_27DDL = """
        CREATE TABLE mcp_comment_author (
          comment_id  TEXT PRIMARY KEY,
          client_name TEXT NOT NULL,
          recorded_at TEXT NOT NULL
        );
        """

    /// `v1_28_mcp_rebind_requests`' DDL (VX-258, VX-246 U1) — FROZEN with the
    /// migration that runs it. `key_hash` is `MCPSetupKeyRule.hash` of the
    /// waiting key (never the key); `version` is what the waiting connection
    /// declared in `initialize` (what tells her a stranger from the client she
    /// knows). Both uniques are bare, like the family's others: these rows are
    /// never synced, never tombstoned.
    static let v1_28DDL = """
        CREATE TABLE mcp_rebind_request (
          id         TEXT PRIMARY KEY,
          client_id  TEXT NOT NULL REFERENCES mcp_client(id),
          key_hash   TEXT NOT NULL,
          version    TEXT,
          asked_at   TEXT NOT NULL
        );
        CREATE UNIQUE INDEX uq_mcp_rebind_request_client ON mcp_rebind_request(client_id);
        CREATE UNIQUE INDEX uq_mcp_rebind_request_key ON mcp_rebind_request(key_hash);
        """

    /// `v1_29_mcp_comment_words`' DDL (P-VX260-1 option (b), VX-246 U1b) —
    /// FROZEN with the migration that runs it. Hex SHA-256 over a
    /// domain-separated encoding of the words (`MCPCommentWords.digest`);
    /// nullable, NO backfill — a record that predates the column stays NULL,
    /// which reads as UNPROVEN (never the client's own).
    static let v1_29DDL = """
        ALTER TABLE mcp_comment_author ADD COLUMN text_digest TEXT;
        """

    /// `v1_30_mcp_one_grant_per_place`'s MERGE (VX-393) — FROZEN with the
    /// migration that runs it. One argument: the merge's stamp (every revoked
    /// duplicate carries it). Per client × scope kind × scope id, among the
    /// live standing rows (while connected · always), the row ranked first
    /// stays live: an "always" row before a while-connected one, then the
    /// higher rung, then the newer `created_at`, then the larger id (pure
    /// determinism). Once rows and revoked rows are never touched.
    static let v1_30MergeSQL = """
        UPDATE mcp_grant SET revoked_at = ?
        WHERE revoked_at IS NULL AND duration IN ('connection', 'always')
          AND id NOT IN (
            SELECT id FROM (
              SELECT id, ROW_NUMBER() OVER (
                PARTITION BY client_id, scope_kind, scope_id
                ORDER BY (duration = 'always') DESC,
                         CASE rung WHEN 'edit' THEN 3 WHEN 'write_new' THEN 2 WHEN 'suggest' THEN 1 ELSE 0 END DESC,
                         created_at DESC, id DESC) AS place_rank
              FROM mcp_grant
              WHERE revoked_at IS NULL AND duration IN ('connection', 'always'))
            WHERE place_rank = 1)
        """

    /// `v1_30_mcp_one_grant_per_place`'s DDL (VX-393) — FROZEN with the
    /// migration that runs it, AFTER the merge (the index could not be built
    /// over the duplicates). Partial on the live standing rows; like the
    /// family's other uniques it needs no live-row clause of the sync kind
    /// (these rows are never synced, never tombstoned).
    static let v1_30DDL = """
        CREATE UNIQUE INDEX uq_mcp_grant_standing_place ON mcp_grant(client_id, scope_kind, scope_id)
          WHERE revoked_at IS NULL AND duration IN ('connection', 'always');
        """

    /// `v1_33_mcp_gathering_grants`' DDL (VX-549 — her sitting 2026-10-27,
    /// RATIFIED: "Gathering joins the grant scopes") — FROZEN with the
    /// migration that runs it. `mcp_grant.scope_kind` gains `'gathering'` (a
    /// gathering's `reading.id` in `scope_id`). SQLite cannot alter a CHECK, so
    /// the table is REBUILT (v1_18's road for `reading.kind`): every row copied
    /// verbatim — its `rowid` too, so Shared with AI's within-one-stamp order
    /// (`g.rowid`) and ⌥⌘A's newest-grant tiebreak read exactly as before — then
    /// both of the table's indexes re-made with their v1_24 / v1_30 text
    /// UNCHANGED. `uq_mcp_grant_standing_place` already keys on client × scope
    /// kind × scope id, so a gathering is one more place under VX-393's one
    /// standing row, with no change (pinned). Nothing references `mcp_grant`
    /// (no foreign key names it; no trigger reads it), so the drop is free.
    static let v1_33DDL = """
        CREATE TABLE mcp_grant_v1_33 (
          id          TEXT PRIMARY KEY,
          client_id   TEXT NOT NULL REFERENCES mcp_client(id),
          rung        TEXT NOT NULL CHECK (rung IN ('read','suggest','write_new','edit')),
          scope_kind  TEXT NOT NULL CHECK (scope_kind IN ('note','book','wing','gathering')),
          scope_id    TEXT NOT NULL,
          duration    TEXT NOT NULL CHECK (duration IN ('once','connection','always')),
          created_at  TEXT NOT NULL,
          consumed_at TEXT,
          revoked_at  TEXT
        );
        INSERT INTO mcp_grant_v1_33
          (rowid, id, client_id, rung, scope_kind, scope_id, duration, created_at, consumed_at, revoked_at)
          SELECT rowid, id, client_id, rung, scope_kind, scope_id, duration, created_at, consumed_at, revoked_at
          FROM mcp_grant;
        DROP TABLE mcp_grant;
        ALTER TABLE mcp_grant_v1_33 RENAME TO mcp_grant;
        CREATE INDEX idx_mcp_grant_client ON mcp_grant(client_id, revoked_at);
        CREATE UNIQUE INDEX uq_mcp_grant_standing_place ON mcp_grant(client_id, scope_kind, scope_id)
          WHERE revoked_at IS NULL AND duration IN ('connection', 'always');
        """
}
