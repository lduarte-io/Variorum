import GRDB

/// Trigger ownership (the dividing line, decided in the Phase 1 plan):
///
/// **Triggers own** downward tombstone propagation and sync-outbox capture —
/// they must fire no matter which layer produced a write (the operations
/// layer, another cascade, or remote apply), which is exactly what app-level
/// code cannot guarantee (SyncSpec §3).
///
/// **The operations layer owns** semantic side-effects: `last_container_id`,
/// `default_variant_id` reassignment, and all timestamps — there are no
/// `updated_at` triggers, because time comes from `@Dependency(\.date)`.
/// (The one exception is `sync_outbox.queued_at`, written by trigger with
/// SQLite's clock: it is local-only bookkeeping, never domain or sync-ordering
/// data — ordering authority is `server_seq`, SyncSpec §9.)
///
/// All cascade triggers are transition-guarded (they fire only on
/// `deleted_at` NULL→value) and touch only live children, so they are
/// idempotent and safe during remote apply (SyncSpec §5): a parent tombstone
/// arriving before its children just pre-produces the same child rows the
/// batch then applies over. Children are stamped with the parent's exact
/// `deleted_at` value — `restoreBlock` identifies cascade victims by that
/// equality (AppSpec §9). No trigger updates its own table's ancestors, so
/// `recursive_triggers` stays off; tag *subtree* deletion is an
/// operations-layer loop (Phase 2), not a trigger.
func createV1Triggers(_ db: Database) throws {
    try createTombstoneCascades(db)
    try createOutboxCapture(db)
}

private func createTombstoneCascades(_ db: Database) throws {
    // block tombstoned → its live variants, its placement, its edges (either
    // side), its block tags. (commit_point has no tombstone column: it is
    // unreachable once its variant is dead; physical cleanup is Phase 12 GC.)
    try db.execute(sql: """
        CREATE TRIGGER cascade_block_tombstone
        AFTER UPDATE OF deleted_at ON block
        WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
        BEGIN
          UPDATE variant SET deleted_at = NEW.deleted_at
            WHERE block_id = NEW.id AND deleted_at IS NULL;
          UPDATE container_block SET deleted_at = NEW.deleted_at
            WHERE block_id = NEW.id AND deleted_at IS NULL;
          UPDATE edge SET deleted_at = NEW.deleted_at
            WHERE (source_block_id = NEW.id OR target_block_id = NEW.id) AND deleted_at IS NULL;
          UPDATE block_tag SET deleted_at = NEW.deleted_at
            WHERE block_id = NEW.id AND deleted_at IS NULL;
        END;
        """)

    // container tombstoned → its singly-owned blocks (whose trigger cascades
    // further), its placements, its reading memberships, its tags, its
    // references. Blocks first, so each block's own cascade sees a live
    // container_block row world consistent with what it expects.
    try db.execute(sql: """
        CREATE TRIGGER cascade_container_tombstone
        AFTER UPDATE OF deleted_at ON container
        WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
        BEGIN
          UPDATE block SET deleted_at = NEW.deleted_at
            WHERE deleted_at IS NULL AND id IN (
              SELECT block_id FROM container_block
              WHERE container_id = NEW.id AND deleted_at IS NULL);
          UPDATE container_block SET deleted_at = NEW.deleted_at
            WHERE container_id = NEW.id AND deleted_at IS NULL;
          UPDATE reading_post SET deleted_at = NEW.deleted_at
            WHERE post_id = NEW.id AND deleted_at IS NULL;
          UPDATE post_tag SET deleted_at = NEW.deleted_at
            WHERE post_id = NEW.id AND deleted_at IS NULL;
          UPDATE reference SET deleted_at = NEW.deleted_at
            WHERE container_id = NEW.id AND deleted_at IS NULL;
        END;
        """)

    // reading tombstoned → its memberships.
    try db.execute(sql: """
        CREATE TRIGGER cascade_reading_tombstone
        AFTER UPDATE OF deleted_at ON reading
        WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
        BEGIN
          UPDATE reading_post SET deleted_at = NEW.deleted_at
            WHERE reading_id = NEW.id AND deleted_at IS NULL;
        END;
        """)

    // tag tombstoned → its live applications. Subtree deletion is Phase 2's
    // operations-layer loop, deliberately not a recursive trigger.
    try db.execute(sql: """
        CREATE TRIGGER cascade_tag_tombstone
        AFTER UPDATE OF deleted_at ON tag
        WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
        BEGIN
          UPDATE post_tag SET deleted_at = NEW.deleted_at
            WHERE tag_id = NEW.id AND deleted_at IS NULL;
          UPDATE block_tag SET deleted_at = NEW.deleted_at
            WHERE tag_id = NEW.id AND deleted_at IS NULL;
        END;
        """)
}

/// Outbox capture (SyncSpec §3): AFTER INSERT and AFTER UPDATE on every synced
/// table enqueue `(table, id)` into the dirty-row set — unless `_sync_applying`
/// holds a row (echo suppression during remote apply; `AppDatabase.applyingRemote`).
/// Capture is by trigger, not by the operations layer, so cascade-produced
/// writes are never missed; outbox rows for cascade writes are correct and
/// wanted — the originating device ships everything its cascades produced.
private func createOutboxCapture(_ db: Database) throws {
    let syncedTables: [(table: String, pk: String)] = [
        ("container", "id"),
        ("block", "id"),
        ("variant", "id"),
        ("commit_point", "id"),
        ("edge", "id"),
        ("container_block", "id"),
        ("reading", "id"),
        ("reading_post", "id"),
        ("tag", "id"),
        ("post_tag", "id"),
        ("block_tag", "id"),
        ("reference", "id"),
        ("setting", "key"),
    ]
    for (table, pk) in syncedTables {
        for event in ["INSERT", "UPDATE"] {
            try db.execute(sql: """
                CREATE TRIGGER outbox_\(table)_\(event.lowercased())
                AFTER \(event) ON \(table)
                WHEN NOT EXISTS (SELECT 1 FROM _sync_applying)
                BEGIN
                  INSERT OR REPLACE INTO sync_outbox (table_name, row_id, queued_at)
                  VALUES ('\(table)', NEW.\(pk), strftime('%Y-%m-%dT%H:%M:%fZ', 'now'));
                END;
                """)
        }
    }
}
