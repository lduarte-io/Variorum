import Foundation
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
        // Author decision 2026-07-06 (Phase 4 ratification review): the
        // three container stamp indexes upgrade to composite live-row form.
        // The timeline's keyset seek is a row-value comparison on
        // `(stamp, id)`; the single-column originals made the id tiebreak
        // and the tombstone filter residual work that grew with
        // duplicate-stamp runs. Same index count, same write cost, precise
        // seeks. ("Why would we not do this now? we don't have sync yet.")
        migrator.registerMigration("v1_2_composite_stamp_indexes") { db in
            try db.execute(sql: """
                DROP INDEX idx_container_entry_date;
                DROP INDEX idx_container_major_rev;
                DROP INDEX idx_container_touched;
                CREATE INDEX idx_container_entry_date ON container(entry_date, id) WHERE deleted_at IS NULL;
                CREATE INDEX idx_container_major_rev  ON container(last_major_revision_at, id) WHERE deleted_at IS NULL;
                CREATE INDEX idx_container_touched    ON container(last_touched_at, id) WHERE deleted_at IS NULL;
                """)
        }
        // Phase 5 (sync core): per-row server_seq bookkeeping, local-only.
        // SyncSpec §7's deterministic repairs rank rows by server_seq
        // ("the placement with the higher server_seq wins", "resurrect the
        // tombstoned variant with the highest server_seq") — which requires
        // the client to KNOW each row's last server-accepted seq. Neither
        // §3's client-machinery list nor the v1 schema enumerated a home for
        // that knowledge (a Phase 5 finding, same class as Phase 1's
        // `_sync_applying` correction): the engine records it here on every
        // push-accept and pull-apply. Never synced; absent rows rank as seq
        // 0 (a row the server has never accepted carries no later-intent
        // authority).
        migrator.registerMigration("v1_3_sync_row_seq") { db in
            try db.execute(sql: """
                CREATE TABLE sync_row_seq (
                  table_name TEXT NOT NULL,
                  row_id     TEXT NOT NULL,
                  server_seq INTEGER NOT NULL,
                  PRIMARY KEY (table_name, row_id)
                );
                """)
        }
        // Phase 9b (Fragments bridge): the bridge's LOCAL-ONLY state —
        // RETIRED 2026-09-04 with the bridge (archived at tag
        // `archive/fragments-bridge-2026-09-04`; `v1_16_drop_bridge_tables`
        // below drops both tables — this migration STAYS because migrations
        // are append-only). The original rationale, kept as history:
        // never synced, no sync_version, no outbox triggers, exempt from
        // SyncSpec §12's lockstep (nothing on the mirror changes). Two
        // tables where the plan sketched one, because the two lifetimes
        // differ: `bridge_day` is per-calendar-day protocol state (the
        // hash of the last body BOTH surfaces agreed on — recorded on
        // push-accept AND on every pull-landing, which is what makes
        // echoes/replays skip and gives push its change detection), while
        // `bridge_state` is per-bridge bookkeeping (the Fragments keyset
        // pull cursor), which has no day to live on. Both join
        // SyncSchema.localOnlyTables so the registry/completeness walks
        // KNOW they are deliberately unsynced.
        // `last_remote_stamp` (amended in place before any on-disk store
        // ran v1_4 — safe because migrations only skip stores that already
        // ran them, and none had): the incoming row's client-LWW
        // `updated_at`, recorded at landing time AND on every accepted push
        // (the push's own sent stamp). A push of that day stamps
        // `last_remote_stamp + 1s` — minimally above the newest server-row
        // stamp the bridge has SEEN or WRITTEN, never the wall clock when a
        // stamp is known (review round 2 MAJOR; supersedes round 1's
        // `max(now, …)`): the push is a compare-and-set that outranks
        // exactly what the bridge knows and goes `.stale` against an unseen
        // Fragments save, which then lands as a conflict card instead of
        // being LWW-destroyed. `now` only on first contact or an
        // unparseable stamp.
        // `remote_created_at` (reconciliation amendment, same in-place
        // safety): the row's created_at as last pulled or pushed — their
        // upsert's SET list includes created_at, so a winning push
        // OVERWRITES it; the bridge echoes the pulled value to preserve the
        // original instant (own instant only for rows never seen).
        // `last_synced_hash` is NULLABLE (second in-place amendment, same
        // safety; review round 1, MINOR 3): a day can carry a remote LWW
        // stamp with NO agreed body — the first-contact tombstone-races-an-
        // edit case records the stamp only, and a NOT NULL hash forced that
        // record into a no-op UPDATE, silently re-opening the `.stale`
        // wedge the stamp exists to close.
        migrator.registerMigration("v1_4_bridge_state") { db in
            try db.execute(sql: """
                CREATE TABLE bridge_state (
                  key   TEXT PRIMARY KEY,
                  value TEXT NOT NULL
                );
                CREATE TABLE bridge_day (
                  day_key           TEXT PRIMARY KEY,
                  last_synced_hash  TEXT,
                  last_remote_stamp TEXT,
                  remote_created_at TEXT
                );
                """)
        }
        // Phase 11, Step A1 (author-ratified 2026-07-06, brief item 1): the
        // canvas view's persisted spatial positions — a small SYNCED table,
        // every §6 convention honored (UUID TEXT PK, owner_id, ISO
        // timestamps, tombstone, sync_version, live-row partial unique
        // index, cascades-as-triggers, outbox triggers). Position updates
        // are plain metadata CAS (SyncSpec §6 — races harmless); the
        // live-unique (container_id, block_id) gets the pure-duplicate
        // repair (keep smaller id, SyncSpec §7 pattern). Part of the ONE
        // SyncSpec §12 lockstep event with v1_6 + v1_7 (mirror DDL:
        // Server/supabase/05_phase11_lockstep.sql — mirror first, then every
        // client, before any new-schema write).
        migrator.registerMigration("v1_5_canvas_layout") { db in
            try db.execute(sql: """
                CREATE TABLE canvas_layout (
                  id           TEXT PRIMARY KEY,
                  owner_id     TEXT,
                  container_id TEXT NOT NULL,
                  block_id     TEXT NOT NULL,
                  x            REAL NOT NULL DEFAULT 0,
                  y            REAL NOT NULL DEFAULT 0,
                  created_at   TEXT NOT NULL,
                  updated_at   TEXT NOT NULL,
                  deleted_at   TEXT,
                  sync_version INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY (container_id) REFERENCES container(id),
                  FOREIGN KEY (block_id)     REFERENCES block(id)
                );
                CREATE UNIQUE INDEX uq_canvas_layout_live ON canvas_layout(container_id, block_id) WHERE deleted_at IS NULL;
                CREATE INDEX idx_canvas_layout_block ON canvas_layout(block_id);
                """)
            // Cascade-by-trigger from BOTH parents (the brief's letter).
            // Both may fire for one pool deletion (container→blocks→canvas
            // and container→canvas directly); the live-row guard makes them
            // idempotent and the stamp identical (Triggers.swift doctrine).
            try db.execute(sql: """
                CREATE TRIGGER cascade_container_tombstone_canvas
                AFTER UPDATE OF deleted_at ON container
                WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
                BEGIN
                  UPDATE canvas_layout SET deleted_at = NEW.deleted_at
                    WHERE container_id = NEW.id AND deleted_at IS NULL;
                END;
                """)
            try db.execute(sql: """
                CREATE TRIGGER cascade_block_tombstone_canvas
                AFTER UPDATE OF deleted_at ON block
                WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
                BEGIN
                  UPDATE canvas_layout SET deleted_at = NEW.deleted_at
                    WHERE block_id = NEW.id AND deleted_at IS NULL;
                END;
                """)
            try createOutboxCaptureTriggers(db, table: "canvas_layout", pk: "id")
        }
        // Phase 11, Step A1 (author-adopted 2026-07-07, AppSpec §14's
        // block-TOC delta): the optional per-block NAME — a handle on a
        // prose block, block-identity-level (I2 makes that unambiguous),
        // deliberately distinct from headings-in-text (§14.8). Additive
        // nullable column; plain metadata under sync (CAS, no uniqueness,
        // no repair rule); an unnamed block's TOC row derives its first
        // sentence AT READ TIME (never stored — the no-denormalization
        // rule). Rides the SAME §12 lockstep event as v1_5/v1_7.
        migrator.registerMigration("v1_6_block_name") { db in
            try db.execute(sql: "ALTER TABLE block ADD COLUMN name TEXT")
        }
        // Phase 11, Step A1 (the kickoff spike's ruling, author-confirmed
        // 2026-07-13 — SAVED LENSES, synced): a lens is a durable NAMED
        // selection profile over one post — "the same structure with
        // different choices" (her ratified boundary sentence). A lens is
        // NEVER rendering truth: exports and every view read
        // chosen pointers; ✓/adopt are the only lens→chosen doors (I3/I8
        // untouched). Choices are SPARSE overrides — only divergences
        // stored; un-overridden slots follow the post's chosen; the empty
        // lens is the legal transparent new-thread default. `variant_id`
        // is a CAS metadata pointer; a dangling pick (variant tombstoned/
        // archived) falls through to chosen at read time — the existing
        // fallback class, deliberately no cascade from variant. Live-unique
        // (lens_id, block_id) repairs as a pure duplicate (SyncSpec §7).
        // Rides the SAME §12 lockstep event as v1_5/v1_6.
        migrator.registerMigration("v1_7_lenses") { db in
            try db.execute(sql: """
                CREATE TABLE lens (
                  id           TEXT PRIMARY KEY,
                  owner_id     TEXT,
                  container_id TEXT NOT NULL,
                  name         TEXT NOT NULL,
                  created_at   TEXT NOT NULL,
                  updated_at   TEXT NOT NULL,
                  deleted_at   TEXT,
                  sync_version INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY (container_id) REFERENCES container(id)
                );
                CREATE INDEX idx_lens_container ON lens(container_id);
                CREATE TABLE lens_choice (
                  id           TEXT PRIMARY KEY,
                  lens_id      TEXT NOT NULL,
                  block_id     TEXT NOT NULL,
                  variant_id   TEXT NOT NULL,
                  created_at   TEXT NOT NULL,
                  updated_at   TEXT NOT NULL,
                  deleted_at   TEXT,
                  sync_version INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY (lens_id)    REFERENCES lens(id),
                  FOREIGN KEY (block_id)   REFERENCES block(id),
                  FOREIGN KEY (variant_id) REFERENCES variant(id)
                );
                CREATE UNIQUE INDEX uq_lens_choice_live ON lens_choice(lens_id, block_id) WHERE deleted_at IS NULL;
                CREATE INDEX idx_lens_choice_block ON lens_choice(block_id);
                """)
            // Cascades: container → its lenses (each lens's own trigger
            // then cascades its choices — the v1_core cross-table chain
            // pattern); block → the choices that override it. Deliberately
            // NO variant → lens_choice cascade (fall-through class).
            try db.execute(sql: """
                CREATE TRIGGER cascade_container_tombstone_lens
                AFTER UPDATE OF deleted_at ON container
                WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
                BEGIN
                  UPDATE lens SET deleted_at = NEW.deleted_at
                    WHERE container_id = NEW.id AND deleted_at IS NULL;
                END;
                """)
            try db.execute(sql: """
                CREATE TRIGGER cascade_lens_tombstone
                AFTER UPDATE OF deleted_at ON lens
                WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
                BEGIN
                  UPDATE lens_choice SET deleted_at = NEW.deleted_at
                    WHERE lens_id = NEW.id AND deleted_at IS NULL;
                END;
                """)
            try db.execute(sql: """
                CREATE TRIGGER cascade_block_tombstone_lens_choice
                AFTER UPDATE OF deleted_at ON block
                WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
                BEGIN
                  UPDATE lens_choice SET deleted_at = NEW.deleted_at
                    WHERE block_id = NEW.id AND deleted_at IS NULL;
                END;
                """)
            try createOutboxCaptureTriggers(db, table: "lens", pk: "id")
            try createOutboxCaptureTriggers(db, table: "lens_choice", pk: "id")
        }
        // Phase 13, Step A1 (author-decided 2026-07-17, AppSpec §14 items
        // 6/9; sitting rulings R7/R27 context): BLOCK COMMENTS — working
        // notes on a BLOCK, deliberately never per-take (her words: per-take
        // comments "would become absolutely insane"). Their own TABLE
        // (multiple per block), tombstoned like every synced row, with
        // deleted comments visible and RESURRECTABLE ("the feature shouldn't
        // be excessively skimpy"). NO uniqueness — comments have no natural
        // key; display order is (created_at, id). Cascade: block tombstone →
        // its live comments with the block's EXACT stamp, so restoreBlock/
        // restoreContainer revive cascade victims and independently-deleted
        // comments stay dead (the standing contract). Travel rules
        // (duplicate onto structural successors) are the operations layer's
        // (Phase 13 Step A2), never triggers. Part of the ONE SyncSpec §12
        // lockstep event with v1_9–v1_11 (mirror DDL:
        // Server/supabase/06_phase13_lockstep.sql; deploy pre-authorized,
        // R53 — mirror → Mac only, the phone app is removed).
        migrator.registerMigration("v1_8_block_comment") { db in
            try db.execute(sql: """
                CREATE TABLE block_comment (
                  id           TEXT PRIMARY KEY,
                  owner_id     TEXT,
                  block_id     TEXT NOT NULL,
                  text         TEXT NOT NULL,
                  created_at   TEXT NOT NULL,
                  updated_at   TEXT NOT NULL,
                  deleted_at   TEXT,
                  sync_version INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY (block_id) REFERENCES block(id)
                );
                CREATE INDEX idx_block_comment_block ON block_comment(block_id);
                """)
            try db.execute(sql: """
                CREATE TRIGGER cascade_block_tombstone_comment
                AFTER UPDATE OF deleted_at ON block
                WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
                BEGIN
                  UPDATE block_comment SET deleted_at = NEW.deleted_at
                    WHERE block_id = NEW.id AND deleted_at IS NULL;
                END;
                """)
            try createOutboxCaptureTriggers(db, table: "block_comment", pk: "id")
        }
        // Phase 13, Step A1 (sitting rulings R16/R27 — callout blocks
        // WANTED, "the callout frame makes sense at a block level"): the
        // optional block-level PRESENTATION — a separated, background-
        // colored text frame within the writing (the Notes/Notion class).
        // Identity-level like block.name (v1_6), additive nullable TEXT
        // holding canonical JSON (kind/color/emoji — BlockPresentation.swift
        // owns the shape); plain metadata under sync (CAS, no uniqueness,
        // no repair rule). Takes share the frame: presentation is the
        // BLOCK's, never the take's (R16's letter). The white-gap rule
        // (R17) and the export-as-blockquote mapping are the view/export
        // layers' — nothing here stores rendering. Rides the SAME §12
        // lockstep event as v1_8/v1_10/v1_11.
        migrator.registerMigration("v1_9_block_presentation") { db in
            try db.execute(sql: "ALTER TABLE block ADD COLUMN presentation TEXT")
        }
        // Phase 13, Step A1 (sitting rulings R28 + R50 — "a reading section
        // table is fine; we don't need nesting readings"; the BOOKS
        // REVERSAL, sitting 1): REAL CHAPTERS — first-class reorderable
        // groupings of posts within a book, superseding tag-derived
        // sections for curated books. `reading_section` is an ordered
        // metadata row list (fractional-index positions, §6; no natural
        // key, no uniqueness — duplicate chapter names are legal, like
        // lens names); `reading_post.section_id` is the membership's
        // chapter pointer (R50: reading_post = which book, section_id =
        // which chapter within it). A DANGLING section_id reads as
        // UNSECTIONED at read time — the chosen-variant fallback class
        // (AppSpec §7's grouping_tag_id precedent); deliberately NO
        // cascade from section to membership, and deleting a chapter
        // never touches the posts. Cascade: reading tombstone → its live
        // sections (exact stamp). Rides the SAME §12 lockstep event as
        // v1_8/v1_9/v1_11.
        migrator.registerMigration("v1_10_reading_sections") { db in
            try db.execute(sql: """
                CREATE TABLE reading_section (
                  id           TEXT PRIMARY KEY,
                  reading_id   TEXT NOT NULL,
                  name         TEXT NOT NULL,
                  position     TEXT NOT NULL,
                  created_at   TEXT NOT NULL,
                  updated_at   TEXT NOT NULL,
                  deleted_at   TEXT,
                  sync_version INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY (reading_id) REFERENCES reading(id)
                );
                CREATE INDEX idx_reading_section_order ON reading_section(reading_id, position);
                """)
            // SQLite allows ADD COLUMN with REFERENCES when the default is
            // NULL; out-of-order sync application is covered by the apply
            // transaction's deferred FKs (SyncSpec §5).
            try db.execute(sql: """
                ALTER TABLE reading_post ADD COLUMN section_id TEXT REFERENCES reading_section(id)
                """)
            try db.execute(sql: """
                CREATE TRIGGER cascade_reading_tombstone_section
                AFTER UPDATE OF deleted_at ON reading
                WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
                BEGIN
                  UPDATE reading_section SET deleted_at = NEW.deleted_at
                    WHERE reading_id = NEW.id AND deleted_at IS NULL;
                END;
                """)
            try createOutboxCaptureTriggers(db, table: "reading_section", pk: "id")
        }
        // Phase 13, Step A1 (AppSpec §14 item 10 — bounded-length notebooks;
        // R38's bounded thread: "declare a length at start; at its end,
        // extend or start a new notebook — she'd like WORDS as a unit"):
        // `reading.word_target`, the words-based sibling of `max_posts`.
        // A display TARGET, deliberately never an add-time refusal —
        // membership can't enforce a word count that every edit changes;
        // the shelf shows progress ("62% of 10,000w") and the boundary
        // offers extend-or-new. Additive nullable column; plain metadata
        // CAS. Rides the SAME §12 lockstep event as v1_8–v1_10.
        migrator.registerMigration("v1_11_reading_word_target") { db in
            try db.execute(sql: "ALTER TABLE reading ADD COLUMN word_target INTEGER")
        }
        // Phase 13b, Stage 4 Batch 4F (author ruling S4-28.1, ledger N36 —
        // "you should be able to set a word limit on a post if you want"):
        // `container.word_target`, the per-POST twin of v1_11's reading
        // column. Same semantics VERBATIM: a display/progress TARGET,
        // deliberately never an add/type-time refusal — word counts change
        // with every edit, so nothing gates on them; the editor bars show
        // progress ("62% of 5,000w"). Additive nullable column; plain
        // metadata CAS, no uniqueness, no repair rule. Its OWN SyncSpec §12
        // lockstep event (marker 3 → 4; mirror DDL
        // Server/supabase/07_phase13b_lockstep.sql — deploy PRE-AUTHORIZED
        // by the author, the 13b EOL addendum; the ORCHESTRATOR executes it
        // at the consolidated window, mirror first, then the client build
        // ships). Until the mirror is at marker 4, a v1_12 client visibly
        // refuses to sync — outbox intact, cursor unmoved, by design.
        migrator.registerMigration("v1_12_container_word_target") { db in
            try db.execute(sql: "ALTER TABLE container ADD COLUMN word_target INTEGER")
        }
        // Phase 13j, J11 (her sitting-round-1 cadence ruling): the idle
        // BACKSTOP drops 24 h → 2 h, now that leaving a note leaves a
        // savepoint of its own. **ZERO SCHEMA** — no table, no column, no
        // index: one seeded `setting` VALUE, so the mirror needs nothing and
        // `SyncSchema.lockstepVersion` does not move (marker 6 stands). It
        // rides as a migration because it must happen exactly ONCE per store.
        //
        // **The guard is the whole point: only a value still at the shipped
        // default moves.** No UI has ever exposed `idle_commit_hours`, so in
        // practice every store reads '24' — but a value she (or a future
        // door) set by hand is hers, and a migration that overwrote it would
        // be the app deciding it knows better. `seedV1Settings` seeds '2'
        // directly, so a fresh store finds nothing to change here.
        //
        // The write enqueues an ordinary outbox row and converges as plain
        // metadata CAS (SyncSpec §6) — two devices migrating offline both
        // land on '2', which is the same value.
        migrator.registerMigration("v1_13_savepoint_backstop") { db in
            try db.execute(sql: """
                UPDATE setting SET value = '2'
                WHERE key = 'idle_commit_hours' AND value = '24'
                """)
        }
        // Phase 13j, batch 6b (J1 — the PURGE BUILD; the binding design is
        // notes/plans/phase-13j-purge-memo.md §5a, her round-8
        // pre-authorization: "The small purge_intent table is fine and I'll
        // authorize the DDL and mirror deploy right now").
        //
        // **The purge INTENT: "this is going, everywhere."** One row per
        // thing being purged — Delete Now / Empty Trash mint them, the
        // savepoint-pruning pass mints them for prunable quiet savepoints
        // (memo §4d, so `table_name` carries 'commit_point' beside the four
        // Trash kinds — the §5a comment's enumeration plus the §4d road),
        // and the janitor tombstones them when the purge completes. Synced
        // like any other row so the act TRAVELS: a peer that pulls an
        // intent purges its own copy when its own horizon allows, instead
        // of discovering a silent hole later.
        //
        // Deliberately NO foreign key on (table_name, row_id): the row it
        // names is precisely the row the janitor will physically DELETE,
        // and an FK would make completing the purge a constraint violation.
        // Every column is PLAIN under E2EE — ids and enums only, no user
        // words by design, so the disclosure list gains nothing to
        // disclose (the classification in SyncSchema.swift is the record).
        //
        // ONE SyncSpec §12 lockstep event (marker 6 → 7; mirror DDL
        // Server/supabase/10_phase13j_purge.sql — finalized in this batch,
        // DEPLOYED only at the architect's one-window per her
        // pre-authorization). Until the mirror is at marker 7, a v1_14
        // client visibly refuses to sync — outbox intact, cursor unmoved,
        // by design; her installed builds are untouched until the window.
        migrator.registerMigration("v1_14_purge_intent") { db in
            try db.execute(sql: """
                CREATE TABLE purge_intent (
                  id            TEXT PRIMARY KEY,
                  owner_id      TEXT,
                  table_name    TEXT NOT NULL,
                  row_id        TEXT NOT NULL,
                  requested_at  TEXT NOT NULL,
                  created_at    TEXT NOT NULL,
                  updated_at    TEXT NOT NULL,
                  deleted_at    TEXT,
                  sync_version  INTEGER NOT NULL DEFAULT 0
                );
                CREATE UNIQUE INDEX uq_purge_intent_live
                  ON purge_intent(table_name, row_id) WHERE deleted_at IS NULL;
                CREATE INDEX idx_purge_intent_row ON purge_intent(table_name, row_id);
                """)
            // Repair rule for the live-unique index (SyncSpec §7, wired in
            // Repairs.swift): two devices asking to purge the same row is
            // not a conflict — pure duplicate, keep the smaller id,
            // tombstone the other. The act is idempotent by nature.
            try createOutboxCaptureTriggers(db, table: "purge_intent", pk: "id")
        }
        // Pre-13u round, Act 4 (17c item P20): AN INDEX FOR THE
        // VERSION-HISTORY CLASSIFIER.
        //
        // `Queries.versionHistoryPredicate` classifies a saved note version
        // by its BIRTH FACT — `archived_at IS NOT NULL AND archived_at =
        // created_at` — and neither column was indexed, so every caller
        // walked `idx_container_kind (kind='post')`, i.e. EVERY POST IN THE
        // CORPUS. `deleteContainer` runs `noteVersionIDs` INSIDE its write
        // transaction (Operations+Container.swift), so an ordinary note with
        // zero versions held the write lock for a corpus-proportional walk,
        // and a multi-select delete paid it once per note. Measured before:
        // 0.374 ms at 2,000 posts → 1.791 ms at 20,000 — exactly linear.
        //
        // The index is PARTIAL on the classifier itself, so it contains
        // saved versions and nothing else: a corpus of 20,000 notes with 15
        // moments carries 15 entries. `(kind, deleted_at, id)` is the column
        // order the four callers need — the live listings seek `kind='post'
        // AND deleted_at IS NULL`, and `versionHistoryDeletedWith` (the
        // `restoreContainer` road) seeks the same pair with a stamp — and it
        // is what makes SQLite prefer it: stats-free (this repo never runs
        // ANALYZE), the planner will not scan an index in place of an
        // equality SEARCH, so the new index has to serve `kind` too.
        //
        // **NOT a SyncSpec §12 lockstep event, deliberately.** The Postgres
        // mirrors carry no indexes beyond the PK by design (SyncSpec §2 —
        // the constraint-free mirror is what makes the §7 repairs possible),
        // so a local index changes no wire semantics, no column, and no
        // classification. The marker stays 7. It is still a schema change,
        // so it lands in its own commit ahead of anything that uses it
        // (CLAUDE.md), and there is nothing for a client to disagree about:
        // an un-migrated client simply keeps the old plan.
        migrator.registerMigration("v1_15_note_version_index") { db in
            try db.execute(sql: """
                CREATE INDEX idx_container_note_version
                  ON container(kind, deleted_at, id)
                  WHERE archived_at IS NOT NULL AND archived_at = created_at;
                """)
        }
        // The Fragments bridge's RETIREMENT (2026-09-04, pre-13x batch 0b —
        // the plan `notes/plans/pre-13x-bridge-retirement.md`, the archive
        // `notes/archive/fragments-bridge.md`): the bridge's two LOCAL-ONLY
        // state tables from v1_4 leave the schema. LOCAL only — they were
        // never synced (no sync_version, no outbox triggers, never in the
        // registry), so there is no SyncSpec §12 lockstep event and the
        // marker stays 7: an un-migrated client and a migrated one push and
        // pull identical rows. The `IF EXISTS` guard is for a store whose
        // v1_4 was somehow skipped — none exists, but a drop is the one
        // migration that must never fail on absence. Their contents were
        // per-device bookkeeping (a pull cursor, per-day agreed hashes)
        // that nothing reads any more; nothing of hers lived there.
        migrator.registerMigration("v1_16_drop_bridge_tables") { db in
            try db.execute(sql: """
                DROP TABLE IF EXISTS bridge_day;
                DROP TABLE IF EXISTS bridge_state;
                """)
        }
        // **The day search's index** (18h batch 2's ladder, R1-1 — the
        // 2026-09-12 use-report round; her row 11: *"search for any note
        // edited on a particular day"*).
        //
        // The Library's day filter asks "which notes were edited on day D"
        // as the union of the note's own last-edit stamp and any SAVEPOINT
        // written that day (`Queries.editedOnClause`). The savepoint half
        // needs to be driven BY THE DAY — "the savepoints written in this
        // window, whose notes are they" — and `idx_commit_variant
        // (variant_id, created_at)` cannot serve that: its leading column is
        // the take. Without this index the only path is per-note, and the
        // measured cost was Σ(blocks × takes) over the whole corpus on every
        // keystroke — 18,016 → 998,116 VM steps at 1 → 100 blocks per note
        // on a 300-note store, which is P1's forbidden shape. With it, and
        // with the query's uncorrelated form (the commit after this one),
        // the same measurement is FLAT at 6,636.
        //
        // Stats-free, like `v1_15`'s: this repo never runs ANALYZE, so the
        // index has to be the obvious path rather than the cheap one — a
        // bare range on `created_at` is exactly that for a `WHERE created_at
        // >= ? AND created_at < ?` driver, and it is what the planner picks
        // (pinned: `LibraryDaySearchTests.theSavepointArmIsDrivenByTheDaysOwnSavepoints`).
        //
        // **NOT a SyncSpec §12 lockstep event**, on `v1_15_note_version_index`'s
        // own reasoning: the Postgres mirrors carry no indexes beyond the PK
        // by design (SyncSpec §2 — the constraint-free mirror is what makes
        // the §7 repairs possible), so a local index changes no wire
        // semantics, no column and no classification. **The marker stays 8.**
        // It is still a schema change, so it lands in its own commit ahead of
        // the query that uses it (CLAUDE.md), and an un-migrated client
        // simply keeps the old plan. The phone gains it by construction —
        // the migration set is shared.
        migrator.registerMigration("v1_17_commit_created_index") { db in
            try db.execute(sql: """
                CREATE INDEX idx_commit_created ON commit_point(created_at);
                """)
        }
        // **Phase 13i-a — THE SCHEMA EVENT (the ONE 13i lockstep bundle;
        // SyncSpec §12 marker 9→10; the binding design is the 13i sitting
        // record §11 + the execution plan `notes/plans/phase-13i-a-schema-event.md`).**
        // Everything 13i b–e will consume lands in this one migration (the
        // author's 2026-08-25 bundling rule): WINGS (the virtual-Home shape,
        // R-13ia-2 — '' means Home everywhere; the table holds additional
        // wings only), SHELVES (+ reading.shelf_id/shelf_position), the
        // gathering/book RECAST of reading.kind (her migration freedom:
        // "there will never be a better time to do it than now"), PER-WING
        // tags (R-13ia-1 — uniqueness (wing_id, path)), starred-absorbs-pins,
        // the OWNED flag, SEALED's stamp, the hide-owned toggle, the intake
        // join dial + auto-tag, reading_post.status (member|arrival), the
        // query_spec v1→v2 recast (Domain/RuleGrammar.swift), and the daily
        // Journal's 'daily' marker on the designated book (the identity
        // memo's edge 1).
        migrator.registerMigration("v1_18_wings_shelves_books") { db in
            // 1 — the two new tables (shelf BEFORE the reading rebuild:
            // reading.shelf_id references it).
            try db.execute(sql: """
                CREATE TABLE wing (
                  id           TEXT PRIMARY KEY,
                  owner_id     TEXT,
                  name         TEXT NOT NULL,
                  position     TEXT NOT NULL,
                  created_at   TEXT NOT NULL,
                  updated_at   TEXT NOT NULL,
                  deleted_at   TEXT,
                  sync_version INTEGER NOT NULL DEFAULT 0
                );
                CREATE TABLE shelf (
                  id           TEXT PRIMARY KEY,
                  owner_id     TEXT,
                  wing_id      TEXT NOT NULL DEFAULT '',
                  name         TEXT NOT NULL,
                  glyph        TEXT,
                  role         TEXT,
                  position     TEXT NOT NULL,
                  created_at   TEXT NOT NULL,
                  updated_at   TEXT NOT NULL,
                  deleted_at   TEXT,
                  sync_version INTEGER NOT NULL DEFAULT 0
                );
                CREATE INDEX idx_shelf_wing ON shelf(wing_id, position);
                """)
            try createOutboxCaptureTriggers(db, table: "wing", pk: "id")
            try createOutboxCaptureTriggers(db, table: "shelf", pk: "id")

            // 2 — the additive columns. '' = the virtual Home wing, so no
            // existing row is rewritten and nothing repushes (R-13ia-2).
            try db.execute(sql: """
                ALTER TABLE container ADD COLUMN wing_id TEXT NOT NULL DEFAULT '';
                ALTER TABLE tag ADD COLUMN wing_id TEXT NOT NULL DEFAULT '';
                ALTER TABLE reading_post ADD COLUMN status TEXT NOT NULL DEFAULT 'member'
                  CHECK (status IN ('member','arrival'));
                """)

            // 3 — per-wing tag uniqueness (R-13ia-1). The NOT NULL ''
            // sentinel is load-bearing here: NULLs are distinct in SQLite
            // unique indexes, so a nullable wing column could never carry
            // this constraint for Home.
            try db.execute(sql: """
                DROP INDEX uq_tag_path_live;
                CREATE UNIQUE INDEX uq_tag_path_live ON tag(wing_id, path) WHERE deleted_at IS NULL;
                """)

            // 4 — the reading REBUILD: the kind CHECK can only change this
            // way. The copy preserves sync_version (CAS keeps working) and
            // deleted_at; updated_at is deliberately untouched everywhere in
            // this migration (a recast is housekeeping, not her edit — the
            // Library must not resort). GRDB runs migrations with foreign
            // keys off and checks at the end, which is what makes the
            // drop-and-rename legal under reading_post/reading_section FKs.
            try db.execute(sql: """
                CREATE TABLE reading_new (
                  id              TEXT PRIMARY KEY,
                  owner_id        TEXT,
                  name            TEXT NOT NULL,
                  kind            TEXT NOT NULL CHECK (kind IN ('book','gathering')),
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
                  word_target     INTEGER,
                  wing_id         TEXT NOT NULL DEFAULT '',
                  shelf_id        TEXT REFERENCES shelf(id),
                  shelf_position  TEXT,
                  starred         INTEGER NOT NULL DEFAULT 0,
                  owned           INTEGER NOT NULL DEFAULT 0,
                  sealed_at       TEXT,
                  hide_owned      INTEGER,
                  intake_seating  TEXT CHECK (intake_seating IN ('auto','arrivals') OR intake_seating IS NULL),
                  auto_tag_id     TEXT REFERENCES tag(id) ON DELETE SET NULL,
                  FOREIGN KEY (grouping_tag_id) REFERENCES tag(id) ON DELETE SET NULL
                );
                INSERT INTO reading_new (id, owner_id, name, kind, profile, sort_field, sort_dir,
                                         grouping_tag_id, query_spec, max_posts, locked,
                                         created_at, updated_at, deleted_at, sync_version, word_target)
                SELECT id, owner_id, name,
                       CASE kind WHEN 'smart' THEN 'gathering' ELSE 'book' END,
                       profile, sort_field, sort_dir, grouping_tag_id, query_spec, max_posts,
                       locked, created_at, updated_at, deleted_at, sync_version, word_target
                FROM reading;
                DROP TABLE reading;
                ALTER TABLE reading_new RENAME TO reading;
                """)
            // The rebuild dropped reading's four triggers with the old
            // table — recreate all of them (the trigger walk pins this).
            try db.execute(sql: """
                CREATE TRIGGER cascade_reading_tombstone
                AFTER UPDATE OF deleted_at ON reading
                WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
                BEGIN
                  UPDATE reading_post SET deleted_at = NEW.deleted_at
                    WHERE reading_id = NEW.id AND deleted_at IS NULL;
                END;
                CREATE TRIGGER cascade_reading_tombstone_section
                AFTER UPDATE OF deleted_at ON reading
                WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
                BEGIN
                  UPDATE reading_section SET deleted_at = NEW.deleted_at
                    WHERE reading_id = NEW.id AND deleted_at IS NULL;
                END;
                """)
            try createOutboxCaptureTriggers(db, table: "reading", pk: "id")

            // 5 — the copy fired NO outbox triggers, so the recast values
            // would never reach the mirror: enqueue EVERY reading row
            // explicitly (the §7 repairs' own pattern; tombstoned rows
            // included — the mirror converges whole; both devices run this
            // same migration and meet by ordinary server-wins CAS).
            try db.execute(sql: """
                INSERT OR REPLACE INTO sync_outbox (table_name, row_id, queued_at)
                SELECT 'reading', id, strftime('%Y-%m-%dT%H:%M:%fZ', 'now') FROM reading;
                """)

            // 6 — query_spec v1 → v2 (Domain/RuleGrammar.fromLegacy). Paths
            // resolve against LIVE tags first (all tags are Home's at this
            // moment), then tombstoned (deterministically the smallest id —
            // the dead term still displays "(deleted tag)"), else the
            // deliberate dead term ''. Shape preserved exactly; an empty v1
            // spec becomes NULL (both mean match-all).
            let specs = try Row.fetchAll(
                db, sql: "SELECT id, query_spec FROM reading WHERE query_spec IS NOT NULL")
            for row in specs {
                let id: String = row["id"]
                let json: String = row["query_spec"]
                guard let v1 = try? JSONDecoder().decode(
                    Queries.SmartQuerySpec.self, from: Data(json.utf8))
                else {
                    // Undecodable bytes stay RAW (ladder R1 MIN-1 — the
                    // write seam's own ruling): the read side fails CLOSED
                    // on malformed; laundering to NULL would flip a broken
                    // rule to match-all and empty the Pool.
                    continue
                }
                let v2 = RuleGrammar.fromLegacy(
                    tags: v1.tags, tagsAll: v1.tagsAll, profile: v1.profile,
                    entryDateFrom: v1.entryDateFrom, entryDateTo: v1.entryDateTo
                ) { path in
                    (try? String.fetchOne(db, sql: """
                        SELECT id FROM tag WHERE path = ? AND wing_id = ''
                        ORDER BY (deleted_at IS NOT NULL), id LIMIT 1
                        """, arguments: [path])) ?? nil
                }
                try db.execute(
                    sql: "UPDATE reading SET query_spec = ? WHERE id = ?",
                    arguments: [try RuleGrammar.encode(v2), id])
            }

            // 7 — pinned books become STARRED (sitting record §7; the
            // shelf_pins setting is retired-as-read — the key stays, since
            // settings never tombstone, and no reader remains after 13i-a).
            let pins = try String.fetchOne(
                db, sql: "SELECT value FROM setting WHERE key = 'shelf_pins'")
                .flatMap { (try? JSONDecoder().decode([String].self, from: Data($0.utf8))) } ?? []
            if !pins.isEmpty {
                try db.execute(
                    sql: """
                        UPDATE reading SET starred = 1
                        WHERE deleted_at IS NULL AND id IN (\(databaseQuestionMarks(count: pins.count)))
                        """,
                    arguments: StatementArguments(pins))
            }

            // 8 — THE DAILY MARKER (the identity memo §3, edge 1): the
            // currently designated daily book gains profile='daily' —
            // idempotent, same-value CAS-safe on every device; the
            // designation setting stays truth until 13i-e rewires its
            // readers. From here the daily MINT writes 'daily' and the §7
            // keeper repair keys on the marker, never the name.
            if let designated = try String.fetchOne(
                db, sql: "SELECT value FROM setting WHERE key = 'daily_journal_book'") {
                try db.execute(sql: """
                    UPDATE reading SET profile = 'daily'
                    WHERE id = ? AND deleted_at IS NULL AND profile = 'journal'
                    """, arguments: [designated])
            }
        }
        // **Her ruling (2026-10-01, at the 13i-a window's close, verbatim
        // intent: "journal should show most recent first … change the
        // default"):** journals read NEWEST FIRST. The three mint doors now
        // stamp `entry_date` DESC; this migration flips EXISTING daily and
        // journal-trait books that still wear the mint's exact ascending
        // shape — a hand-set order (any other field/direction) is hers and
        // never overridden. Ordinary synced metadata writes (CAS; both her
        // devices run the same flip and converge); zero schema, no §12
        // event.
        migrator.registerMigration("v1_19_journals_newest_first") { db in
            try db.execute(sql: """
                UPDATE reading SET sort_dir = 'desc'
                WHERE profile IN ('daily', 'journal')
                  AND sort_field = 'entry_date' AND sort_dir = 'asc'
                  AND deleted_at IS NULL
                """)
        }
        // **13i-c — THE OUTFLOW EVENT (SyncSpec §12 lockstep, marker 10→11;
        // the plan `notes/plans/phase-13i-c-owned-finished-sealed.md` §2).**
        // Her two rulings at the kickoff: R-13ic-1 — the outflow is a CHOSEN,
        // OPTIONAL SET of tags on a book, stored as ONE JSON column
        // (`auto_tag_ids`, the rule's own shape); R-13ic-4 — a gathering
        // REQUIRES a rule, so every live rule-less gathering goes to the
        // Trash here (a tombstone, Put back available, no note touched) and
        // "no rule" means SHOWS NOTHING from now on — nothing grandfathered.
        // Additive: no rebuild. The outbox captures every row this touches;
        // they push after her window (the engine refuses until the marker
        // reads 11 — the 13i-a pattern).
        migrator.registerMigration("v1_20_outflow_and_ruleless") { db in
            try db.execute(sql: "ALTER TABLE reading ADD COLUMN auto_tag_ids TEXT;")
            // 1 — carry every LIVE book's single outflow into a one-element
            // array. `auto_tag_id` is left as it is: retired-as-read (the
            // shelf_pins precedent; SQLite refuses to drop a column that
            // carries a foreign key). Dead rows are not rewritten — their
            // value is irrelevant and an UPDATE would repush a tombstone.
            try db.execute(sql: """
                UPDATE reading SET auto_tag_ids = json_array(auto_tag_id)
                WHERE deleted_at IS NULL AND auto_tag_id IS NOT NULL;
                """)
            // 2 — the rule-less sweep (R-13ic-4). A real clock: the Trash's
            // 30-day window reads the stamp. The reading cascade triggers
            // stamp any stray membership with the exact stamp (a gathering
            // holds nothing by design; a sync stray dies with it). A
            // MALFORMED rule is untouched — it already fails closed and the
            // editor shows it.
            let now = DateFormatter.variorumISO8601.string(from: Date())
            try db.execute(
                sql: """
                    UPDATE reading SET deleted_at = ?, updated_at = ?
                    WHERE deleted_at IS NULL AND kind = 'gathering' AND query_spec IS NULL
                    """,
                arguments: [now, now])
        }
        // **13i-e — THE BOOK ARCHIVE EVENT (SyncSpec §12 lockstep, marker
        // 11→12; the plan `notes/plans/phase-13i-e-daily-journal.md`).** Her
        // kickoff ruling R-13ie-1: general archive machinery for books ON THE
        // ROW ("a book is a set of rules + ordering now so it makes sense to
        // archive it … I'm fine with another sync schema event to do this
        // right") — the `container.archived_at` class, kept-but-out-of-view,
        // keep-forever. Additive, nullable, no data migration (nothing is
        // archived at birth), no index (reading listings are shelf-scale,
        // never corpus-scale). A bare ADD COLUMN writes no row, so the
        // outbox is untouched. The ops/doors land in this phase's U1/U2.
        migrator.registerMigration("v1_21_reading_archive") { db in
            try db.execute(sql: "ALTER TABLE reading ADD COLUMN archived_at TEXT;")
        }
        // **13o — THE SEARCH INDEX** (the plan `notes/plans/phase-13o-search.md`:
        // her sitting rulings R-13o-3/4/6/11 and the §FORK RULINGS F1–F4).
        //
        // A DERIVED, LOCAL-ONLY family (R-13o-3 — the `sync_outbox`
        // precedent): `search_doc` (one row per source text field — F2),
        // the `search_text` view (the text resolved from the SOURCE rows —
        // F1), the FTS5 `search_fts` over it (`unicode61 remove_diacritics
        // 2`, prefixes 2 and 3 — F4), and R-13o-4's third trigger family,
        // DERIVED-INDEX CAPTURE: mechanical mirroring of each source field's
        // existence and raw text, reading nothing but NEW/OLD and the doc
        // family (`Persistence/SearchIndex.swift` holds the shape and the
        // plan's §R-13o-4 RECORD its provenance).
        //
        // **NOT a SyncSpec §12 lockstep event**: nothing here carries
        // `sync_version`, nothing is pushed, no mirror changes — the marker
        // stays 12. The family joins the sync registry's DERIVED set (the
        // §FORK RULINGS' export ruling) so the completeness walk knows it is
        // deliberately unsynced and an exported store keeps a working index.
        //
        // **The backfill is the rebuild engine, run once** — every live
        // source row's fields derived into docs, then the index re-read from
        // the view. Measured at ~0.66 s for 55k takes (the U1 bench).
        //
        // One more LOCAL index rides here for the search's WORN-DAY arm
        // (R-13o-6 — a nameless, undated note wears the day it was created):
        // `idx_container_undated_created`, partial on exactly the undated
        // live containers, so "september 14" finds those notes by range
        // seeks on the day's own window instead of a walk of every note. Its
        // WHERE is a predicate no existing query states, so no shipped plan
        // can change under it (SQLite uses a partial index only when the
        // query implies its WHERE). Local index, no §12 event — the v1_15 /
        // v1_17 precedent.
        migrator.registerMigration("v1_22_search_index") { db in
            try SearchIndex.create(db)
            try db.execute(sql: """
                CREATE INDEX idx_container_undated_created ON container(created_at)
                  WHERE deleted_at IS NULL AND (entry_date IS NULL OR entry_date = '');
                """)
            // Frozen on v1_22's own eight kinds (VX-72 split the list so a
            // later kind never reaches a store mid-chain — `v1_23` below).
            try SearchIndex.rebuild(db, sources: SearchIndex.sourcesV1_22)
        }
        // **VX-72 — SAVEPOINTS JOIN THE SEARCH INDEX** (her R-VX83-5: *"do the
        // savepoints … it's the most important product story (anything
        // you've saved)"*; the run record `notes/plans/fixes/vx-83-search-
        // followup.md`, its §U-C RULINGS). The NINTH doc kind, `savepoint`
        // (`commit_point.text`), exactly as F2 reserved it ("VX-72's
        // savepoints join as one more kind") — nothing reshapes:
        // `search_doc` gains the savepoint's own-row parent fact
        // (`variant_id`, nullable), the `search_text` view is recreated with
        // the ninth arm, and the savepoint's three capture triggers join
        // R-13o-4's family (reading NEW/OLD and the doc family only). The
        // savepoint's take liveness and its home resolve at QUERY time, under
        // the facet only (FORK 1 ruled A — F3's road).
        //
        // **NOT a SyncSpec §12 lockstep event** (v1_22's class): the change is
        // to the DERIVED, local-only family — no synced column, no mirror, the
        // marker stays 12; `commit_point` itself is untouched. **The backfill
        // is the rebuild road, run once** over v1_23's frozen nine kinds.
        migrator.registerMigration("v1_23_savepoint_search") { db in
            try SearchIndex.addSavepoints(db)
            try SearchIndex.rebuild(db, sources: SearchIndex.sourcesV1_23)
        }
        // **13n-b — THE MCP DOOR's GRANTS STORE** (A-5/A-6; R-13n-4's "a
        // LOCAL-ONLY table"): `mcp_client` · `mcp_grant` · `mcp_activity` ·
        // `mcp_switch` (`Persistence/MCPGrantSchema.swift` carries the shape
        // and why each column is there).
        //
        // **NOT a SyncSpec §12 lockstep event**: nothing here carries
        // `sync_version` or an outbox trigger, nothing is pushed, no mirror
        // changes — the marker stays 12. Its own registration
        // (`MCPGrantSchema.tables`) beside the sync registry's local-only and
        // derived sets; the plaintext export keeps the tables EMPTY. No
        // backfill: a store meets the door with no clients, no grants, the
        // server OFF and the open book CLOSED (absent switch rows read off).
        migrator.registerMigration("v1_24_mcp_grants") { db in
            try db.execute(sql: MCPGrantSchema.v1_24DDL)
        }
        // **13n-b — THE PRIVATE MARK** (her ruling R-13nb-4, the 13n-b
        // plan's sitting record + design addendum, 2026-10-09): a per-NOTE
        // and per-BOOK privacy mark, both the `archived_at` class — an
        // additive nullable TEXT stamp, NULL = not private. The fence reads
        // them as its third leg (journal profile · journal/daily membership
        // · the private mark — a note in ANY live private book is fenced,
        // privacy wins ties); gatherings refuse the mark operations-side.
        //
        // **A SyncSpec §12 LOCKSTEP EVENT** (marker 12 → 13 — the
        // `SyncSchema.lockstepVersion` bump rides this commit): both
        // columns are SYNCED (a privacy mark is a fact about the book or
        // note, not about one Mac's AI setup — it must survive 13x
        // portability and read the same on every device), PLAIN under E2EE
        // (bare timestamps; disclosed structure only — that something is
        // marked, never which or what). The marker moves because a
        // marker-12 client's CAS whole-row push would silently null
        // `ai_private_at` out from under a marker-13 writer (13i-e's
        // reasoning, verbatim). Mirror DDL `16_phase13nb_private.sql` —
        // the deploy is HER closeout window, never pre-authorized. No
        // backfill: nothing is private at birth. No new §7 repair (plain
        // CAS metadata; NULL reads not-private).
        migrator.registerMigration("v1_25_private_mark") { db in
            try db.execute(sql: "ALTER TABLE container ADD COLUMN ai_private_at TEXT")
            try db.execute(sql: "ALTER TABLE reading ADD COLUMN ai_private_at TEXT")
        }
        // **VX-168 — THE PER-SETUP KEY** (the VX-156 brief §12's K2; her
        // kickoff ruling R-VX168-1, the run record
        // `notes/plans/fixes/vx-168-mcp-client-secret.md`): the grants
        // family's `mcp_setup_key` (a copied setup's key, by hash, until a
        // client name presents it) and `mcp_client.setup_key_hash` (the key
        // bound to the name). `Persistence/MCPGrantSchema.swift` carries the
        // shape.
        //
        // **NOT a SyncSpec §12 lockstep event** — v1_24's road exactly:
        // nothing here carries `sync_version` or an outbox trigger, nothing is
        // pushed, no mirror changes, the marker stays 13. The new table joins
        // `MCPGrantSchema.tables` (the completeness walk subtracts it; the
        // plaintext export keeps it EMPTY). No backfill: every client approved
        // before this migration arrives UNBOUND — her R-VX168-1: such a name
        // binds the first fresh setup presented under it, and a name arriving
        // without its key refuses (no grandfathering).
        migrator.registerMigration("v1_26_mcp_setup_keys") { db in
            try db.execute(sql: MCPGrantSchema.v1_26DDL)
        }
        // **VX-188 — WHO WROTE A COMMENT** (VX-184 U3; her ruling R-VX188-1,
        // the kickoff `notes/plans/mcp-launch-polish-kickoff.md`): the grants
        // family's `mcp_comment_author` — the comment a client added through
        // the door, by the client's name — so the suggest rung's
        // `delete_comment` can delete a client's OWN comment and nothing else.
        // `Persistence/MCPGrantSchema.swift` carries the shape.
        //
        // **NOT a SyncSpec §12 lockstep event** — v1_24's road exactly (the
        // run's ONE allowed schema change, its own commit): no `sync_version`,
        // no outbox trigger, nothing pushed, no mirror change, the marker stays
        // 13. It joins `MCPGrantSchema.tables` (the completeness walk subtracts
        // it; the plaintext export keeps it EMPTY). No backfill: every comment
        // that exists before this migration has no record — its author is
        // unknown, so no client can delete it at suggest (R-VX188-2's refusal).
        migrator.registerMigration("v1_27_mcp_comment_authors") { db in
            try db.execute(sql: MCPGrantSchema.v1_27DDL)
        }
        // **VX-258 — A SETUP WAITING FOR HER OK** (VX-246 U1; her ruling: an
        // "Any MCP client" key under a name that carries her approval
        // "re-binds only after my ok" — the run record
        // `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`): the grants
        // family's `mcp_rebind_request` — a claimed key waiting to bind an
        // approved name until she allows it. `Persistence/MCPGrantSchema.swift`
        // carries the shape.
        //
        // **NOT a SyncSpec §12 lockstep event** — v1_24's road exactly (its own
        // commit, ahead of the code that uses it): no `sync_version`, no outbox
        // trigger, nothing pushed, no mirror change, the marker stays 13. It
        // joins `MCPGrantSchema.tables` (the completeness walk subtracts it;
        // the plaintext export keeps it EMPTY). No backfill: nothing waits
        // before this migration.
        migrator.registerMigration("v1_28_mcp_rebind_requests") { db in
            try db.execute(sql: MCPGrantSchema.v1_28DDL)
        }
        // **P-VX260-1, OPTION (b) — THE WORDS A CLIENT WROTE** (VX-246 U1b; the
        // run record `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, THE
        // ORCHESTRATOR ON U1's HAND-BACK): `mcp_comment_author` gains
        // `text_digest`, so a comment is a client's own only while its words
        // are still the ones it wrote — her edit on ANY device makes deleting
        // it need EDIT. `Persistence/MCPGrantSchema.swift` carries the shape.
        //
        // **NOT a SyncSpec §12 lockstep event** — v1_24's road exactly (its own
        // commit, ahead of the code that uses it): no `sync_version`, no outbox
        // trigger, nothing pushed, no mirror change, the marker stays 13; the
        // plaintext export keeps the family EMPTY. **NO BACKFILL — NULL MEANS
        // UNPROVEN (argued in the record):** a record written before this
        // migration may name a comment she has since rewritten on another
        // device or in a build without VX-260's forget, and its current words
        // cannot say which; a backfill would bless exactly those as the
        // client's. So a NULL digest is never the client's own (deleting it
        // needs EDIT) — the strict reading, at the cost of a client's
        // pre-upgrade comments asking edit to delete.
        migrator.registerMigration("v1_29_mcp_comment_words") { db in
            try db.execute(sql: MCPGrantSchema.v1_29DDL)
        }
        // **VX-393 — ONE GRANT ROW PER CLIENT × PLACE** (VX-348 U5; her ruling
        // R-VX348-6 "Upgrade in place" — the run record
        // `notes/plans/fixes/vx-348-prelaunch-sweep.md` §U5): Shared with AI
        // listed one wing twice for one client, because every grant road but
        // Change… ADDED a row. Each place's duplicates merge to its strongest
        // standing row (the rest revoked on one stamp — never deleted), then a
        // partial unique index holds the family to one live standing grant per
        // client × place. `Persistence/MCPGrantSchema.swift` carries the shape
        // and the merge's order.
        //
        // **NOT a SyncSpec §12 lockstep event** — v1_24's road exactly (its own
        // commit, ahead of the code that relies on it): no `sync_version`, no
        // outbox trigger, nothing pushed, no mirror change, the marker stays 13;
        // the plaintext export keeps the family EMPTY. A real clock stamps the
        // merge (v1_20's precedent): the pane and the rule read a revoked row
        // as revoked whatever its stamp.
        migrator.registerMigration("v1_30_mcp_one_grant_per_place") { db in
            try db.execute(
                sql: MCPGrantSchema.v1_30MergeSQL,
                arguments: [DateFormatter.variorumISO8601.string(from: Date())])
            try db.execute(sql: MCPGrantSchema.v1_30DDL)
        }

        // **VX-306 U1a — THE PROTECTION RECORD'S HOME** (`notes/plans/vx-306-castle-open-road.md` §2 U1a,
        // design §3.2): `protection_record`, the library's own protection facts inside the library file
        // (`Persistence/ProtectionRecordSchema.swift` carries the ONE DDL value the production library leaf
        // shares). **NOT a SyncSpec §12 lockstep event** — LOCAL-ONLY by registration
        // (`SyncSchema.localOnlyTables`: no `sync_version`, no outbox trigger, never a payload or a mirror;
        // the plaintext export drops it; `LocalMachineryRecreation` re-creates it empty); the marker stays
        // 13. No backfill: a store from before this design has no record and is not handled (rule 26).
        migrator.registerMigration("v1_31_protection_record") { db in
            try db.execute(sql: ProtectionRecordSchema.ddl)
        }
        // VX-494 (D2): the pull stage — a first catch-up's downloaded windows, held so an interrupted round
        // resumes instead of restarting. LOCAL-ONLY by registration (`SyncSchema.localOnlyTables`): no
        // `sync_version`, no outbox trigger, never a payload or a mirror; the plaintext export drops it;
        // `LocalMachineryRecreation` re-creates it empty. NOT a SyncSpec §12 lockstep event; the marker stays 14.
        migrator.registerMigration("v1_32_sync_pull_stage") { db in
            try db.execute(sql: SyncPullStageSchema.ddl)
        }
        // **VX-549 — A GATHERING AS A GRANT PLACE** (VX-548 batch 3; her sitting
        // 2026-10-27, RATIFIED — the run record
        // `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 3): the
        // grants family's `mcp_grant.scope_kind` gains `'gathering'`.
        // `Persistence/MCPGrantSchema.swift` carries the shape (a rebuild — a
        // CHECK cannot be altered — rows and rowids copied verbatim, both indexes
        // re-made with their text unchanged).
        //
        // **NOT a SyncSpec §12 lockstep event** — v1_24's road exactly (its own
        // commit, ahead of the code that uses it): no `sync_version`, no outbox
        // trigger, nothing pushed, no mirror change, the marker stays 14; the
        // plaintext export keeps the family EMPTY. No backfill: no grant names a
        // gathering before this migration.
        migrator.registerMigration("v1_33_mcp_gathering_grants") { db in
            try db.execute(sql: MCPGrantSchema.v1_33DDL)
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
    // `idle_commit_hours` seeds at 2, not AppSpec §7's original 24 (Phase
    // 13j, J11 — her cadence ruling: *"the existing idle timer drops from
    // 24h to ~2h as the backstop for notes that stay open"*). Existing
    // stores are moved by `v1_13_savepoint_backstop`, which only touches a
    // value still at the old default; seeding the new value here means a
    // fresh store never writes the row twice.
    try db.execute(sql: """
        INSERT INTO setting (key, value) VALUES
          ('default_segmentation', 'paragraph'),
          ('major_revision_threshold', '0.8'),
          ('idle_commit_hours', '2');
        """)
}
