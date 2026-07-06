import GRDB

extension AppDatabase {
    /// The schema migrator. `v1_core` is the entire v1 schema — AppSpec §7 DDL
    /// verbatim, plus the conventions of AppSpec §6: `sync_version` on every
    /// synced table, live-row partial unique indexes, fractional-index `TEXT`
    /// positions, cascades-as-triggers, and the local-only sync machinery
    /// (SyncSpec §3).
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1_core") { db in
            try createV1Tables(db)
            try createV1Indexes(db)
            try createV1Triggers(db)
            try seedV1Settings(db)
        }
        // Migrations are append-only from here on (GRDB runs each once, by
        // name — editing a shipped migration silently skips any store that
        // already ran it; Phase 4 cold-review finding).
        migrator.registerMigration("v1_1_tray_index") { db in
            // The tray query's access path (Phase 4): the per-post tray
            // resolves tombstoned blocks by `last_container_id`; without
            // this index every tray render is a corpus-sized block scan,
            // which P1 forbids.
            try db.execute(
                sql: "CREATE INDEX idx_block_last_container ON block(last_container_id)")
        }
        return migrator
    }
}

/// Tables, in the write-order the plan prescribes: `container` and `block`
/// first (their circular FKs — block→container, block→variant while
/// variant→block — resolve at DML time, not DDL), then `variant`, then the
/// rest. Cascades noted in AppSpec §7 comments are triggers (Triggers.swift),
/// never `ON DELETE CASCADE` — row sync applies records out of order and
/// cannot honor cascade semantics. Local-only RESTRICT/SET NULL guards stay
/// as constraints.
private func createV1Tables(_ db: Database) throws {
    // container — posts and pools (unified so one live-unique index on
    // container_block.block_id enforces single ownership, I2, uniformly).
    try db.execute(sql: """
        CREATE TABLE container (
          id                     TEXT PRIMARY KEY,
          owner_id               TEXT,
          kind                   TEXT NOT NULL CHECK (kind IN ('post','pool')),
          title                  TEXT,
          profile                TEXT CHECK (profile IN ('journal','blog','book_chapter','generic','pool') OR profile IS NULL),
          entry_date             TEXT,
          locked                 INTEGER NOT NULL DEFAULT 0,
          locked_at              TEXT,
          floating_notes         TEXT,
          segmentation_default   TEXT CHECK (segmentation_default IN ('one_block','paragraph','sentence') OR segmentation_default IS NULL),
          last_touched_at        TEXT,
          last_major_revision_at TEXT,
          churn_accumulator      REAL NOT NULL DEFAULT 0,
          baseline_length        INTEGER NOT NULL DEFAULT 0,
          created_at             TEXT NOT NULL,
          updated_at             TEXT NOT NULL,
          archived_at            TEXT,
          deleted_at             TEXT,
          sync_version           INTEGER NOT NULL DEFAULT 0
        );
        """)

    // block — identity anchors.
    try db.execute(sql: """
        CREATE TABLE block (
          id                 TEXT PRIMARY KEY,
          owner_id           TEXT,
          default_variant_id TEXT,
          last_container_id  TEXT,
          created_at         TEXT NOT NULL,
          updated_at         TEXT NOT NULL,
          archived_at        TEXT,
          deleted_at         TEXT,
          sync_version       INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (default_variant_id) REFERENCES variant(id) ON DELETE SET NULL,
          FOREIGN KEY (last_container_id)  REFERENCES container(id) ON DELETE SET NULL
        );
        """)

    // variant — the fan. working_text is the only mutable text in the system.
    try db.execute(sql: """
        CREATE TABLE variant (
          id                TEXT PRIMARY KEY,
          block_id          TEXT NOT NULL,
          parent_variant_id TEXT,
          working_text      TEXT NOT NULL DEFAULT '',
          status            TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','archived')),
          locked            INTEGER NOT NULL DEFAULT 0,
          label             TEXT,
          fan_position      TEXT NOT NULL,
          created_at        TEXT NOT NULL,
          updated_at        TEXT NOT NULL,
          deleted_at        TEXT,
          sync_version      INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (block_id)          REFERENCES block(id),
          FOREIGN KEY (parent_variant_id) REFERENCES variant(id) ON DELETE SET NULL
        );
        """)

    // commit_point — append-only savepoints inside a variant. No deleted_at:
    // unreachable once its variant is tombstoned; physical cleanup is the
    // Phase 12 GC. Ordered by (created_at, id), never a per-variant seq.
    try db.execute(sql: """
        CREATE TABLE commit_point (
          id           TEXT PRIMARY KEY,
          variant_id   TEXT NOT NULL,
          text         TEXT NOT NULL,
          kind         TEXT NOT NULL DEFAULT 'manual' CHECK (kind IN ('manual','auto')),
          message      TEXT,
          created_at   TEXT NOT NULL,
          sync_version INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (variant_id) REFERENCES variant(id)
        );
        """)

    // edge — typed block-to-block relationships. version_of is stored
    // canonically as (min(id), max(id)) by the operations layer (SyncSpec §7).
    try db.execute(sql: """
        CREATE TABLE edge (
          id              TEXT PRIMARY KEY,
          source_block_id TEXT NOT NULL,
          target_block_id TEXT NOT NULL,
          type            TEXT NOT NULL CHECK (type IN ('derived_from','version_of')),
          origin_op       TEXT,
          created_at      TEXT NOT NULL,
          deleted_at      TEXT,
          sync_version    INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (source_block_id) REFERENCES block(id),
          FOREIGN KEY (target_block_id) REFERENCES block(id)
        );
        """)

    // container_block — ordered pointers (ownership + chosen variant). The
    // RESTRICT guards the physical-purge/GC path only; under soft-delete the
    // live guard is the operations layer (AppSpec §9, review #3).
    try db.execute(sql: """
        CREATE TABLE container_block (
          id                TEXT PRIMARY KEY,
          container_id      TEXT NOT NULL,
          block_id          TEXT NOT NULL,
          position          TEXT NOT NULL,
          chosen_variant_id TEXT,
          created_at        TEXT NOT NULL,
          updated_at        TEXT NOT NULL,
          deleted_at        TEXT,
          sync_version      INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (container_id)      REFERENCES container(id),
          FOREIGN KEY (block_id)          REFERENCES block(id),
          FOREIGN KEY (chosen_variant_id) REFERENCES variant(id) ON DELETE RESTRICT
        );
        """)

    // reading — books / chapters / on-demand collections.
    try db.execute(sql: """
        CREATE TABLE reading (
          id              TEXT PRIMARY KEY,
          owner_id        TEXT,
          name            TEXT NOT NULL,
          kind            TEXT NOT NULL CHECK (kind IN ('curated','smart')),
          profile         TEXT,
          sort_field      TEXT NOT NULL DEFAULT 'manual'
                            CHECK (sort_field IN ('manual','entry_date','created_at','last_touched','last_major_revision')),
          sort_dir        TEXT NOT NULL DEFAULT 'asc' CHECK (sort_dir IN ('asc','desc')),
          grouping_tag_id TEXT,
          query_spec      TEXT,
          max_posts       INTEGER,
          locked          INTEGER NOT NULL DEFAULT 0,
          created_at      TEXT NOT NULL,
          updated_at      TEXT NOT NULL,
          deleted_at      TEXT,
          sync_version    INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (grouping_tag_id) REFERENCES tag(id) ON DELETE SET NULL
        );
        """)

    // reading_post — curated membership; posts are non-exclusively pointed at
    // (deliberate asymmetry with container_block).
    try db.execute(sql: """
        CREATE TABLE reading_post (
          id           TEXT PRIMARY KEY,
          reading_id   TEXT NOT NULL,
          post_id      TEXT NOT NULL,
          position     TEXT NOT NULL,
          created_at   TEXT NOT NULL,
          deleted_at   TEXT,
          sync_version INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (reading_id) REFERENCES reading(id),
          FOREIGN KEY (post_id)    REFERENCES container(id)
        );
        """)

    // tag — hierarchical, path-style. `path` is the one deliberate
    // denormalization; renameTag (Phase 2) rewrites the subtree.
    try db.execute(sql: """
        CREATE TABLE tag (
          id           TEXT PRIMARY KEY,
          owner_id     TEXT,
          parent_id    TEXT,
          name         TEXT NOT NULL,
          path         TEXT NOT NULL,
          created_at   TEXT NOT NULL,
          updated_at   TEXT NOT NULL,
          deleted_at   TEXT,
          sync_version INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (parent_id) REFERENCES tag(id)
        );
        """)

    // post_tag / block_tag — two tables so FKs are real (AppSpec §7 delta).
    try db.execute(sql: """
        CREATE TABLE post_tag (
          id           TEXT PRIMARY KEY,
          tag_id       TEXT NOT NULL,
          post_id      TEXT NOT NULL,
          created_at   TEXT NOT NULL,
          deleted_at   TEXT,
          sync_version INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (tag_id)  REFERENCES tag(id),
          FOREIGN KEY (post_id) REFERENCES container(id)
        );
        """)
    try db.execute(sql: """
        CREATE TABLE block_tag (
          id           TEXT PRIMARY KEY,
          tag_id       TEXT NOT NULL,
          block_id     TEXT NOT NULL,
          created_at   TEXT NOT NULL,
          deleted_at   TEXT,
          sync_version INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (tag_id)   REFERENCES tag(id),
          FOREIGN KEY (block_id) REFERENCES block(id)
        );
        """)

    // reference — external source material beside a post. The row syncs;
    // file_bookmark is a Sync-layer payload exclusion (local-only), not a
    // schema difference.
    try db.execute(sql: """
        CREATE TABLE reference (
          id            TEXT PRIMARY KEY,
          owner_id      TEXT,
          container_id  TEXT NOT NULL,
          kind          TEXT NOT NULL CHECK (kind IN ('file','url')),
          name          TEXT,
          url           TEXT,
          file_bookmark BLOB,
          view_state    TEXT,
          position      TEXT NOT NULL,
          created_at    TEXT NOT NULL,
          updated_at    TEXT NOT NULL,
          deleted_at    TEXT,
          sync_version  INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (container_id) REFERENCES container(id)
        );
        """)

    // setting — global/document key-values. Synced (document semantics),
    // upsert-only, never tombstoned (AppSpec §7).
    try db.execute(sql: """
        CREATE TABLE setting (
          key          TEXT PRIMARY KEY,
          value        TEXT NOT NULL,
          sync_version INTEGER NOT NULL DEFAULT 0
        );
        """)

    // Local-only sync machinery (never synced; SyncSpec §3). The outbox is a
    // dirty-row SET, not an op log: the PK coalesces keystroke-rate autosaves.
    try db.execute(sql: """
        CREATE TABLE sync_outbox (
          table_name TEXT NOT NULL,
          row_id     TEXT NOT NULL,
          queued_at  TEXT NOT NULL,
          PRIMARY KEY (table_name, row_id)
        );
        """)
    try db.execute(sql: """
        CREATE TABLE sync_state (
          key   TEXT PRIMARY KEY,
          value TEXT NOT NULL
        );
        """)

    // The apply-mode flag (SyncSpec §3): outbox triggers skip enqueueing while
    // it holds a row. A permanent local-only table, not a temp table — SQLite
    // resolves unqualified names inside a main-schema trigger in the trigger's
    // own schema, so a temp table would be invisible to the outbox triggers.
    // Normally empty; populated only inside `AppDatabase.applyingRemote`'s
    // transaction, so a rollback unwinds the flag with everything else.
    try db.execute(sql: """
        CREATE TABLE _sync_applying (
          applying INTEGER NOT NULL
        );
        """)
}

/// Indexes. Every uniqueness rule is a live-row partial unique index
/// (`WHERE deleted_at IS NULL`) — a bare UNIQUE would let tombstones block
/// legitimate re-creation forever (AppSpec §6).
private func createV1Indexes(_ db: Database) throws {
    try db.execute(sql: """
        CREATE INDEX idx_variant_block  ON variant(block_id, status);
        CREATE INDEX idx_variant_parent ON variant(parent_variant_id);

        CREATE INDEX idx_commit_variant ON commit_point(variant_id, created_at);

        CREATE UNIQUE INDEX uq_edge_live ON edge(source_block_id, target_block_id, type) WHERE deleted_at IS NULL;
        CREATE INDEX idx_edge_source ON edge(source_block_id, type);
        CREATE INDEX idx_edge_target ON edge(target_block_id, type);

        CREATE INDEX idx_container_kind       ON container(kind);
        CREATE INDEX idx_container_entry_date ON container(entry_date);
        CREATE INDEX idx_container_major_rev  ON container(last_major_revision_at);
        CREATE INDEX idx_container_touched    ON container(last_touched_at);

        CREATE UNIQUE INDEX uq_cblock_ownership ON container_block(block_id) WHERE deleted_at IS NULL;
        CREATE INDEX idx_cblock_order ON container_block(container_id, position);

        CREATE UNIQUE INDEX uq_reading_post_live ON reading_post(reading_id, post_id) WHERE deleted_at IS NULL;
        CREATE INDEX idx_reading_post_order ON reading_post(reading_id, position);
        CREATE INDEX idx_reading_post_post  ON reading_post(post_id);

        CREATE UNIQUE INDEX uq_tag_path_live ON tag(path) WHERE deleted_at IS NULL;
        CREATE INDEX idx_tag_parent ON tag(parent_id);

        CREATE UNIQUE INDEX uq_post_tag_live ON post_tag(tag_id, post_id) WHERE deleted_at IS NULL;
        CREATE INDEX idx_post_tag_tag  ON post_tag(tag_id);
        CREATE INDEX idx_post_tag_post ON post_tag(post_id);

        CREATE UNIQUE INDEX uq_block_tag_live ON block_tag(tag_id, block_id) WHERE deleted_at IS NULL;
        CREATE INDEX idx_block_tag_tag   ON block_tag(tag_id);
        CREATE INDEX idx_block_tag_block ON block_tag(block_id);

        CREATE INDEX idx_reference_container ON reference(container_id, position);
        """)
}

private func seedV1Settings(_ db: Database) throws {
    try db.execute(sql: """
        INSERT INTO setting (key, value) VALUES
          ('default_segmentation', 'paragraph'),
          ('major_revision_threshold', '0.8'),
          ('idle_commit_hours', '24');
        """)
}
