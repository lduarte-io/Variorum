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
public enum MCPGrantSchema {
    /// The family's tables — the registration the completeness walk and the
    /// plaintext export consult.
    public static let tables: Set<String> = [
        "mcp_client", "mcp_grant", "mcp_activity", "mcp_switch", "mcp_setup_key", "mcp_comment_author",
    ]

    /// The family in CHILD-FIRST order (`mcp_grant` references
    /// `mcp_client`) — the order a whole-family row strip must take with
    /// foreign keys on. Pinned to cover `tables` exactly.
    public static let childFirstOrder: [String] = [
        "mcp_grant", "mcp_activity", "mcp_switch", "mcp_setup_key", "mcp_comment_author", "mcp_client",
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
}
