# Variorum — App Spec

**Status:** the single source of design truth for this project. Evolved from `notes/source/SPEC.md` (which it supersedes); deltas from that document are listed in §14 so nothing changed silently.
**Stack (settled):** SQLite (GRDB 7, encrypted at rest via SQLCipher since Phase 13p) as canonical local store, rows-as-truth · Swift · TextKit 2 `NSTextView` editor core · SwiftUI chrome (Observation + swift-dependencies, no TCA) · SPM core package + thin Xcode app target · macOS-first → iOS journal capture early → full iOS → (eventually) web. Sync is a **hand-rolled row-sync protocol over Supabase/Postgres, fully designed now** in `notes/SyncSpec.md` (authoritative for everything sync) and built at its phase — early, not commercial-phase, so the author can journal from her phone.
**How to read this:** the vision is `CoreDescription.md`; the mental model and invariants are `OverallModel.md` (this doc assumes you've internalized both). Sections 1–5 here are the concrete architecture; 6–12 are schema, operations, queries, views, sync; 13 is build order (detail lives in `DetailedPlanForPhases.md`); 14 records resolutions and deltas (the full dated delta record lives in `notes/AppSpecDeltaArchive.md` — canon, moved verbatim 2026-08-01; §14 keeps only the most recent phase's); 15 is the risk register (standing risks + their reasoning); 16 is what's still genuinely open.

---

## 1. Development context (machines, toolchain)

- **One machine (dev = acceptance): the author's M3 Mac on macOS Tahoe 26.x, Xcode 26.** The Intel Air era ended 2026-07-06 — the transition planned for "before Phase 6" was executed early, when the repo moved to the M3. The former dev/acceptance split is gone; the Air is not coming back.
- Editor milestones still re-verify against the **current Tahoe point release** after each macOS update — TextKit 2 behavior is version- and SDK-gated and regresses between point releases (see `notes/TEXTKIT2_NOTES.md`).
- **Toolchain:** Xcode 26 (macOS 26 SDK), `swift-tools-version: 6.2`. Fast inner loop: logic, storage, operations, `swift test` from CLI.
- **Deployment targets: macOS 26 (Tahoe) / iOS 26** — author decision 2026-07-06: no older-OS support. Build SDK and runtime match, so SDK-gated behaviors (e.g. the `.layoutManager` TK2→TK1 downgrade) are always what a shipping build sees, and Tahoe-only APIs need no availability gating.
- **Testing:** Swift Testing (`import Testing`) for all new tests.

## 2. Code architecture

- **`VariorumCore` Swift package** — everything below the UI: `Models` (value types + GRDB records), `Persistence` (database stack, migrations, reader/writer pool), `Domain` (pure rule functions — invariant enforcement, churn math, segmentation, boundary snapping), `Operations` (the transactional operations API, §9), `Queries` (read-side traversals + observations). Built and tested via `swift build` / `swift test`, no Xcode project needed.
- **App target (arrives in the editor phase)** — thin Xcode app wrapping the package: `App/` (entry, root composition), `Features/` (one folder per feature module: Editor, Library, BookView, Timeline, …), `Core/Views` (shared SwiftUI pieces).
- **Pattern:** SwiftUI + `@Observable` view models + [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) for injection (`@Dependency(\.database)`, `\.date`, `\.uuid`). View models hold projections and send operations; they contain no business rules. Domain rules are pure functions. All persistence and side effects live in injected dependencies. The editor core is AppKit (`NSTextView` via `NSViewRepresentable`), owned by the Editor feature.
- **One feature = one module.** Cross-feature interaction routes through parent composition, never feature-to-feature calls.

## 3. Architectural decisions (settled — the "why nots" live in OverallModel §8)

- SQLite rows-as-truth via GRDB 7; code-first migrations, transparent in diffs.
- Operations-as-API: every mutation flows through a defined transactional operation — never ad-hoc row edits.
- History native to the domain (commits, fans, edges — append-only); optional audit log later is derived, never truth.
- Row-based sync engine for the commercial future; designed-for now (§11), built later.
- Web someday via WASM SQLite, same schema/SQL.

## 4. Performance architecture (hard constraint)

> **P1: Cost is proportional to what's on screen and what's being edited — never to the total size of the document or the corpus.**

Three layers enforce it:

- **Storage — tiny writes, indexed reads, never the blob.** An edit writes one small `variant` row; autosave cost is fixed regardless of post length. Reading a post is one indexed query. Rendering a book pages by post. WAL + connection pool; all DB I/O off the main thread (P2).
- **Editing — TextKit 2, viewport layout, one focused unit live.** AppKit `NSTextView` on TextKit 2 (never SwiftUI `TextEditor`), chosen for viewport-based lazy layout. Block IDs ride block ranges as custom text attributes so edits stay scoped. Keystroke cost bounded by the visible region.
- **Rendering — virtualize long views; read cheap, edit only the focused unit (P3).** Long views render only near-viewport posts. Content you're only reading is never a live editor: unfocused blocks render as lightweight read-only text; only the focused block/post upgrades to a real `NSTextView`. This is the same architecture as the "calm default, one block blooms" UX.
- **Escape hatch (door stays open, don't build):** at 100k+ words in one post, virtualize *within* a post — recycled block list, live editor only around the cursor. The block decomposition makes this possible without re-architecting.

**Known risk:** TK2 viewport layout / height estimation / scroll-to-location is the least reliable part of the chosen stack. De-risk with a throwaway 50k-word scroll prototype run **on Tahoe** before committing book-scrub to live TK2 geometry (`notes/TEXTKIT2_NOTES.md` §2). Fallback: drive the scrubber off stored per-block length estimates, not live geometry; last resort is STTextView.

## 5. Invariants

Defined and explained in `OverallModel.md` §4–6: **I1–I9** (data), **P1–P3** (performance), **S1–S5** (sync). Every schema and operation decision below must be traceable to them. One addition formalized here:

- **I10 — A live block has at least one live variant.** Deleting/archiving a block's last active variant is not a variant operation — it is deleting the block. The operations layer enforces this (see `deleteVariant`, `archiveVariant`).

## 6. Conventions

- **PKs are UUID `TEXT`**, random (v4), minted via `@Dependency(\.uuid)`. (The original deterministic-UUIDv5 idea is dropped — it collides with tombstone-then-recreate; convergence is the sync layer's job. SyncSpec §9.)
- **Timestamps are ISO-8601 `TEXT`** (`created_at`, `updated_at`); `updated_at` feeds sync pull cursors.
- **Soft-delete via `deleted_at` tombstones** (S2). Domain "archive" (`variant.status='archived'`, `container.archived_at`, `block.archived_at`) is a separate concept (kept-but-out-of-view), distinct from a sync tombstone.
- **Uniqueness is scoped to live rows.** Every uniqueness rule is a **partial unique index `… WHERE deleted_at IS NULL`**, never a bare `UNIQUE` constraint. (A bare constraint makes tombstones block legitimate re-creation: e.g. a tombstoned `container_block` row would forever pin its block; a deleted tag path could never be re-created. Found while pressure-testing; applies to `container_block.block_id`, `reading_post`, `tag.path`, `edge`, `post_tag`, `block_tag`.)
- **`owner_id TEXT` (nullable) on top-level entities** (block, container, reading, tag) for future RLS (S4).
- **Ordering via fractional-index `TEXT` positions** (base-62 lexicographic keys with per-call jitter; pure Domain function `FractionalIndex.between`). O(1) inserts, unlimited depth, **no rebalance operation exists** — `REAL` midpoints were a sync bomb (identical offline midpoints; mass renumber conflicts). Sort key is always `(position, id)`. See SyncSpec §8.
- **Every synced table carries `sync_version INTEGER NOT NULL DEFAULT 0`** (the server CAS token; SyncSpec §3–4). Not repeated in each DDL block below.
- **Outbox-by-trigger:** AFTER INSERT/UPDATE triggers on every synced table enqueue into `sync_outbox` (dirty-row set, coalescing), suppressed during remote apply via the `_sync_applying` flag. Population by trigger, not by the operations layer, so cascade-produced rows are never missed. See SyncSpec §3.
- **Booleans are `INTEGER` 0/1.** **`PRAGMA foreign_keys = ON;` + WAL.**
- **FK cascades are expressed as triggers, not `ON DELETE CASCADE`** — the row-sync layer applies records out of order and can't honor cascade semantics. Local-only RESTRICT guards (e.g. `chosen_variant_id`) stay as constraints. The exact trigger set is enumerated + tested in the schema phase.
- **The table named `commit_point`** is the domain "commit" (avoids the SQL keyword).
- **Uniqueness violations across devices are repairable, not fatal:** every partial unique index has a deterministic apply-time repair rule (SyncSpec §7).

## 7. Schema (DDL)

> Creation order: `container` and `block` first (mutually circular FKs resolve at write time — SQLite checks FK targets at DML, not DDL), then `variant`, then the rest. Cascades shown as comments are triggers per §6.

### block — identity anchors
```sql
CREATE TABLE block (
  id                 TEXT PRIMARY KEY,
  owner_id           TEXT,
  default_variant_id TEXT,            -- representative variant absent pointer context; lifecycle in §9
  last_container_id  TEXT,            -- powers the per-post "deleted blocks" tray
  name               TEXT,            -- optional handle (v1_6, Phase 11a — §14's 2026-07-07 delta); CAS metadata
  presentation       TEXT,            -- callout frame (v1_9, Phase 13 — R16/R27): canonical JSON kind/color/emoji;
                                      -- color is a THEME-TOKEN NAME, never a literal (R1); takes share the frame;
                                      -- malformed JSON reads as a plain block; CAS metadata, no repair rule
  created_at         TEXT NOT NULL,
  updated_at         TEXT NOT NULL,
  archived_at        TEXT,            -- domain archive (kept, out of view)
  deleted_at         TEXT,            -- sync tombstone (S2)
  FOREIGN KEY (default_variant_id) REFERENCES variant(id) ON DELETE SET NULL,
  FOREIGN KEY (last_container_id)  REFERENCES container(id) ON DELETE SET NULL
);
CREATE INDEX idx_block_last_container ON block(last_container_id);  -- the tray's access path (ratified 2026-07-06)
```

### variant — the fan
```sql
CREATE TABLE variant (
  id                TEXT PRIMARY KEY,
  block_id          TEXT NOT NULL,
  parent_variant_id TEXT,             -- branch/history tree
  working_text      TEXT NOT NULL DEFAULT '',  -- THE mutable buffer; autosaved; conflict-as-variant target (S5)
  status            TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','archived')),
  locked            INTEGER NOT NULL DEFAULT 0,
  label             TEXT,
  fan_position      TEXT NOT NULL,             -- fractional-index key (§6)
  created_at        TEXT NOT NULL,
  updated_at        TEXT NOT NULL,
  deleted_at        TEXT,
  FOREIGN KEY (block_id)          REFERENCES block(id),     -- cascade via trigger
  FOREIGN KEY (parent_variant_id) REFERENCES variant(id) ON DELETE SET NULL
);
CREATE INDEX idx_variant_block  ON variant(block_id, status);
CREATE INDEX idx_variant_parent ON variant(parent_variant_id);
```
> `working_text` is the only mutable text in the system and the only field that can produce a sync conflict (S5).

### commit_point — append-only savepoints inside a variant
```sql
CREATE TABLE commit_point (
  id          TEXT PRIMARY KEY,
  variant_id  TEXT NOT NULL,
  text        TEXT NOT NULL,          -- immutable snapshot
  kind        TEXT NOT NULL DEFAULT 'manual' CHECK (kind IN ('manual','auto')),
  message     TEXT,
  created_at  TEXT NOT NULL,
  FOREIGN KEY (variant_id) REFERENCES variant(id)  -- cascade via trigger
);
CREATE INDEX idx_commit_variant ON commit_point(variant_id, created_at);
CREATE INDEX idx_commit_created ON commit_point(created_at);  -- 18h (2026-09-13): the day search's savepoint arm — the day's own savepoints are the driver (the ladder's BLOCKER); an index is not a §12 lockstep event, the marker stays 8
```
> Order by `created_at` (+ `id` as tiebreak), **not** a per-variant `seq` — a global seq collides when two devices commit offline. Restoring loads `text` into `working_text`; committing again inserts. Text is never overwritten (I5).

### edge — typed block-to-block relationships
```sql
CREATE TABLE edge (
  id              TEXT PRIMARY KEY,
  source_block_id TEXT NOT NULL,      -- derived_from: descendant; version_of: side A
  target_block_id TEXT NOT NULL,      -- derived_from: ancestor;   version_of: side B
  type            TEXT NOT NULL CHECK (type IN ('derived_from','version_of')),
  origin_op       TEXT,               -- 'divide'|'merge'|'extract'|'pool_copy'|'manual'|NULL
  created_at      TEXT NOT NULL,
  deleted_at      TEXT,
  FOREIGN KEY (source_block_id) REFERENCES block(id),
  FOREIGN KEY (target_block_id) REFERENCES block(id)
);
CREATE UNIQUE INDEX uq_edge_live ON edge(source_block_id, target_block_id, type) WHERE deleted_at IS NULL;
CREATE INDEX idx_edge_source ON edge(source_block_id, type);
CREATE INDEX idx_edge_target ON edge(target_block_id, type);
```
> `derived_from (source, target)` reads "source is derived from target" (target = ancestor). `version_of` is undirected — the operations layer stores it **canonically as `(min(id), max(id))`** so two devices creating the same relationship converge to one row (SyncSpec §7 treats a reversed pair as a duplicate). This one coarse table carries split/merge/extract/pool lineage **and** outline→draft mapping **and** "two versions of an article" links.

### container — posts and pools (unified for single-ownership enforcement)
```sql
CREATE TABLE container (
  id                     TEXT PRIMARY KEY,
  owner_id               TEXT,
  kind                   TEXT NOT NULL CHECK (kind IN ('post','pool')),
  title                  TEXT,
  profile                TEXT CHECK (profile IN ('journal','blog','book_chapter','generic','pool') OR profile IS NULL),
  entry_date             TEXT,        -- posts (esp. journals): ordering key
  locked                 INTEGER NOT NULL DEFAULT 0,   -- the post-level seal / "complete"
  locked_at              TEXT,
  floating_notes         TEXT,        -- free-floating per-post notes area
  segmentation_default   TEXT CHECK (segmentation_default IN ('one_block','paragraph','sentence') OR segmentation_default IS NULL),
  last_touched_at        TEXT,        -- any keystroke (sort: noisy)
  last_major_revision_at TEXT,        -- crossed churn threshold (sort: meaningful) — §10
  word_target            INTEGER,     -- per-POST words-based extent TARGET (v1_12, Phase 13b Stage 4 — author
                                      -- ruling S4-28.1; the twin of reading.word_target): display/progress only,
                                      -- NEVER an add- or type-time refusal. Plain metadata CAS, no uniqueness,
                                      -- no repair rule. Its own SyncSpec §12 lockstep event (marker 3 → 4).
  churn_accumulator      REAL NOT NULL DEFAULT 0,
  baseline_length        INTEGER NOT NULL DEFAULT 0,
  created_at             TEXT NOT NULL,
  updated_at             TEXT NOT NULL,
  archived_at            TEXT,
  deleted_at             TEXT
);
CREATE INDEX idx_container_kind       ON container(kind);
-- Stamp indexes are composite live-row (author decision 2026-07-06, Phase 4
-- ratification): the timeline's keyset sort key is (stamp, id) over live
-- rows, and the indexes match it exactly — precise row-value seeks, no
-- residual work on duplicate-stamp runs.
CREATE INDEX idx_container_entry_date ON container(entry_date, id) WHERE deleted_at IS NULL;
CREATE INDEX idx_container_major_rev  ON container(last_major_revision_at, id) WHERE deleted_at IS NULL;
CREATE INDEX idx_container_touched    ON container(last_touched_at, id) WHERE deleted_at IS NULL;
```
> Posts and pools share one table so one live-unique index on `container_block.block_id` enforces single ownership (I2) uniformly, and "scrap" and "finished prose" are one object type. Pool rows leave post-specific columns NULL.

### container_block — ordered pointers (ownership + chosen variant)
```sql
CREATE TABLE container_block (
  id                TEXT PRIMARY KEY,
  container_id      TEXT NOT NULL,
  block_id          TEXT NOT NULL,
  position          TEXT NOT NULL,             -- fractional-index key (§6)
  chosen_variant_id TEXT,             -- which variant renders here (I3); NULL **or tombstoned/archived** ⇒ fall back to block.default_variant_id (read-time rule; sync races can leave it dangling — SyncSpec §7 repairs it)
  created_at        TEXT NOT NULL,
  updated_at        TEXT NOT NULL,
  deleted_at        TEXT,
  FOREIGN KEY (container_id)      REFERENCES container(id),
  FOREIGN KEY (block_id)          REFERENCES block(id),
  FOREIGN KEY (chosen_variant_id) REFERENCES variant(id) ON DELETE RESTRICT
);
CREATE UNIQUE INDEX uq_cblock_ownership ON container_block(block_id) WHERE deleted_at IS NULL;  -- I2
CREATE INDEX idx_cblock_order ON container_block(container_id, position);
```
> Rendering a post = walk by `position`, resolve `chosen_variant_id` (falling back to the block's default), concatenate `working_text`. `RESTRICT` on chosen variant: a shown variant can't be deleted until the slot is re-pointed.

### reading — books / chapters / on-demand collections
```sql
CREATE TABLE reading (
  id              TEXT PRIMARY KEY,
  owner_id        TEXT,
  name            TEXT NOT NULL,
  kind            TEXT NOT NULL CHECK (kind IN ('curated','smart')),
  profile         TEXT,                        -- 'journal'|'book'|'collection'
  sort_field      TEXT NOT NULL DEFAULT 'manual'
                    CHECK (sort_field IN ('manual','entry_date','created_at','last_touched','last_major_revision')),
  sort_dir        TEXT NOT NULL DEFAULT 'asc' CHECK (sort_dir IN ('asc','desc')),
  grouping_tag_id TEXT,                        -- section the book by a hierarchical tag root;
                                               -- may dangle at a tombstoned tag under soft delete
                                               -- (SET NULL never fires) — read-time rule: treat as
                                               -- NULL/ungrouped (same class as the chosen-variant fallback)
  query_spec      TEXT,                        -- JSON predicate for smart readings
  max_posts       INTEGER,                     -- extent constraint (fixed-length journal)
  word_target     INTEGER,                     -- words-based extent TARGET (v1_11, Phase 13 — §14 item 10):
                                               -- display/progress only, NEVER an add-time refusal (word counts
                                               -- change with every edit; the boundary offers extend-or-start-new)
  locked          INTEGER NOT NULL DEFAULT 0,  -- declared "done"
  created_at      TEXT NOT NULL,
  updated_at      TEXT NOT NULL,
  deleted_at      TEXT,
  FOREIGN KEY (grouping_tag_id) REFERENCES tag(id) ON DELETE SET NULL
);
```

### reading_post — curated membership (a post may live in MANY readings)
```sql
CREATE TABLE reading_post (
  id          TEXT PRIMARY KEY,
  reading_id  TEXT NOT NULL,
  post_id     TEXT NOT NULL,                   -- container.id where kind='post'
  position    TEXT NOT NULL,                   -- fractional-index key (§6)
  section_id  TEXT REFERENCES reading_section(id),  -- which CHAPTER within the book (v1_10, Phase 13 — R28/R50);
                                               -- a DANGLING pointer reads as UNSECTIONED (the chosen-variant
                                               -- fallback class; deleting a chapter never rewrites memberships,
                                               -- and NO sync repair rides the pointer)
  created_at  TEXT NOT NULL,
  deleted_at  TEXT,
  FOREIGN KEY (reading_id) REFERENCES reading(id),
  FOREIGN KEY (post_id)    REFERENCES container(id)
);
CREATE UNIQUE INDEX uq_reading_post_live ON reading_post(reading_id, post_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_reading_post_order ON reading_post(reading_id, position);
CREATE INDEX idx_reading_post_post  ON reading_post(post_id);
```
> Deliberate asymmetry with `container_block`: blocks are singly-owned; **posts are non-exclusively pointed at** by readings — this is what makes on-demand books work. *(Ratified bend incoming — author, 2026-08-26 at the launch-strategy sitting, designed and built at Phase 13i: an OPT-IN per-book **Owned** relationship constrains membership for books that want it — her words, "notes will have to lose a little ground to let books be stronger." The non-exclusive DEFAULT and this asymmetry remain the norm; enforcement is operations-layer with an apply-time repair, never a schema containment. Design record: `notes/plans/phase-13i-smart-book-identity-brief.md`.)*

### reading_section — real chapters: ordered, reorderable groupings within a curated book (v1_10, Phase 13)
```sql
CREATE TABLE reading_section (
  id           TEXT PRIMARY KEY,
  reading_id   TEXT NOT NULL,
  name         TEXT NOT NULL,                  -- duplicate names legal (no natural key — no repair class)
  position     TEXT NOT NULL,                  -- fractional-index key (§6): chapters reorder like everything else
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  deleted_at   TEXT,
  FOREIGN KEY (reading_id) REFERENCES reading(id)  -- cascade via trigger (reading tombstone → its live sections, exact stamp)
);
CREATE INDEX idx_reading_section_order ON reading_section(reading_id, position);
```
> The Phase 13 books reversal made real (sittings 1/4 — R28/R50; the ratified supersession of "a chapter is effectively a tag section"): a chapter is an ordered metadata row a membership points at (`reading_post.section_id`), never a container of posts and never nested. **Curated readings only** — smart readings refuse sections (their sectioning story stays `grouping_tag_id`). `restoreSection` (§9) is the recovery door; assignments reattach for free because the dangle rule never rewrites pointers.

### tag — hierarchical, path-style
```sql
CREATE TABLE tag (
  id         TEXT PRIMARY KEY,
  owner_id   TEXT,
  parent_id  TEXT,
  name       TEXT NOT NULL,
  path       TEXT NOT NULL,                    -- materialized: 'life/goals/2024' — the ONE deliberate
                                               -- denormalization (parent names copied downward);
                                               -- renameTag rewrites the subtree's paths (§9)
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT,
  FOREIGN KEY (parent_id) REFERENCES tag(id)
);
CREATE UNIQUE INDEX uq_tag_path_live ON tag(path) WHERE deleted_at IS NULL;
CREATE INDEX idx_tag_parent ON tag(parent_id);
```

### post_tag / block_tag — tag application (two tables, real FKs)
```sql
CREATE TABLE post_tag (
  id          TEXT PRIMARY KEY,
  tag_id      TEXT NOT NULL,
  post_id     TEXT NOT NULL,                   -- container.id (kind='post' enforced in operations)
  created_at  TEXT NOT NULL,
  deleted_at  TEXT,
  FOREIGN KEY (tag_id)  REFERENCES tag(id),
  FOREIGN KEY (post_id) REFERENCES container(id)
);
CREATE UNIQUE INDEX uq_post_tag_live ON post_tag(tag_id, post_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_post_tag_tag  ON post_tag(tag_id);
CREATE INDEX idx_post_tag_post ON post_tag(post_id);

CREATE TABLE block_tag (
  id          TEXT PRIMARY KEY,
  tag_id      TEXT NOT NULL,
  block_id    TEXT NOT NULL,
  created_at  TEXT NOT NULL,
  deleted_at  TEXT,
  FOREIGN KEY (tag_id)   REFERENCES tag(id),
  FOREIGN KEY (block_id) REFERENCES block(id)
);
CREATE UNIQUE INDEX uq_block_tag_live ON block_tag(tag_id, block_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_block_tag_tag   ON block_tag(tag_id);
CREATE INDEX idx_block_tag_block ON block_tag(block_id);
```
> **Delta from source SPEC** (which had one polymorphic `tagging` table): two tables restore real DB-enforced foreign keys and drop the app-enforced discriminator — DB-enforced integrity was a stated reason for choosing SQLite, so the model should collect on it. Post-level tags drive the main UI; block-level tags primarily serve the pool. "Everything tagged X" queries UNION the two tables — acceptable, and rare outside the pool.

### block_comment — working notes on a block (v1_8, Phase 13; author 2026-07-17: per-BLOCK, deliberately never per-take)
```sql
CREATE TABLE block_comment (
  id           TEXT PRIMARY KEY,
  owner_id     TEXT,
  block_id     TEXT NOT NULL,
  text         TEXT NOT NULL,
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  deleted_at   TEXT,
  FOREIGN KEY (block_id) REFERENCES block(id)  -- cascade via trigger (block tombstone → its live comments, exact stamp)
);
CREATE INDEX idx_block_comment_block ON block_comment(block_id);
```
> Multiple comments per block; NO uniqueness (no natural key ⇒ no SyncSpec §7 repair class). Comment `text` is **metadata under sync (server-version-wins CAS), deliberately not S5** — conflict-as-variant stays scoped to `variant.working_text`. Deleted comments are visible and resurrectable (`Queries.deletedBlockComments` + `restoreBlockComment`, §9 — "never skimpy", author 2026-07-17), and cascade victims revive with `restoreBlock`/`restoreContainer` via the exact-stamp rule. Travel across structural ops is the operations layer's (§9), never a trigger's.

### reference — external source material attached to a post (a viewing aid, NOT a knowledge base)
```sql
CREATE TABLE reference (
  id            TEXT PRIMARY KEY,
  owner_id      TEXT,
  container_id  TEXT NOT NULL,
  kind          TEXT NOT NULL CHECK (kind IN ('file','url')),
  name          TEXT,
  url           TEXT,               -- kind='url'
  file_bookmark BLOB,               -- kind='file': security-scoped bookmark — LOCAL-ONLY, excluded from sync payloads
  view_state    TEXT,               -- remembered page/scroll position (JSON)
  position      TEXT NOT NULL,      -- fractional-index key (§6)
  created_at    TEXT NOT NULL,
  updated_at    TEXT NOT NULL,
  deleted_at    TEXT,
  FOREIGN KEY (container_id) REFERENCES container(id)
);
CREATE INDEX idx_reference_container ON reference(container_id, position);
```
> Author-approved 2026-07-04 (resolves the "sources to the side" interpretation): per-post references rendered in a side panel — Quick Look previews generally, PDFKit for PDFs/books (page memory + **text selection dragged into the draft lands as a pool-drag-style copy**), URLs shown via a read-only `WKWebView` pane or opened externally. **Out of scope permanently:** EPUB rendering, annotation/highlight sync, citation management — that way lies the knowledge base this app refuses to be. The row syncs; `file_bookmark` does not (files are per-machine; re-link on another device if wanted).

### setting — global/document key-values
```sql
CREATE TABLE setting (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- seeds: ('default_segmentation','paragraph'), ('major_revision_threshold','0.8'), ('idle_commit_hours','2')
--   (`idle_commit_hours` seeded 24 until Phase 13j's savepoint-cadence ruling
--    J11 dropped the idle timer to 2 h as the BACKSTOP behind `closeAutoCommit`;
--    `seedV1Settings` seeds '2' and migration `v1_13_savepoint_backstop` moves
--    existing stores still at the old default. This comment said 24 until
--    17f/P46 corrected it — the shipped seed had not been 24 since August.)
--   ('receipt_style' is NOT seeded — like `theme_voice`/`fan_style` its default is
--    applied at READ time (`Queries.ThemeSettings`), and the default is QUIET: her
--    ruling R-Q5, 18i (2026-09-13). Enum-valued (toast · quiet · off), so the
--    column's PLAIN classification and its "enum semantics, no prose" promise are
--    untouched; upsert-only, not a §12 lockstep event — the marker stays 8.)
--   ('theme_palette' / 'theme_tint' / 'theme_accent_tint' are NOT seeded: like theme_voice their
--    defaults are applied at READ time (Queries.ThemeSettings) — no palette, no seeds. The palette is
--    enum-valued; the two tint values are a VALIDATED six-hex-digit token or the empty string (cleared),
--    structured and never prose, so the column's PLAIN classification and its "enum semantics, no prose"
--    promise are untouched. 18g, her R-Q6/R-Q13, 2026-09-14.)
```
> Default segmentation is a document/global setting decoupled from UI/mode; `container.segmentation_default` overrides per-post; `profile='journal'` seeds `one_block`. Settings are **synced** (they're document semantics — segmentation must match on iOS capture): they carry `sync_version` per §6, are upsert-only, and never tombstone. **E2EE constraint (14b closeout, ladder R1-9): `setting.value` is classified PLAIN and the disclosure list promises "enum semantics, no prose" — that promise is COLUMN-fenced, so no future setting key may carry user-authored prose in its value; a prose-valued setting is a design change that must re-open the column's classification, never a quiet addition.**
>
> **Segmentation trigger (author decision 2026-07-04, review item #11):** fresh-text segmentation is **type-time crystallization** — while typing brand-new text at the end of a post, each completed paragraph silently becomes a block as you type past it; the trailing paragraph still being typed is an *open tail*, not yet a block. Bulk entry (paste, import, pool-drop, mobile capture) segments on entry. Once a block exists, Enter inside it is pure content forever — I4 is never violated because crystallization only ever applies to text that has not yet become a block. The boundary-detection logic is a pure Domain function (Phase 2). **SUPERSEDED IN WRITE ON THE MAC (author ruling U-1, 2026-09-06, the use-report round's 18c): with the chip ON (`effectiveSegmentation != one_block`), the Return KEY makes a block wherever the caret is** — an empty block below at a block's end, a divide at the caret inside its text (single-take in place; fanned → the keep-on-top default), an empty block above at its start, nothing in an empty block; the abandoned empty block STAYS as an empty paragraph, never auto-removed (U-19 (2)). The decision is the pure `TypedReturn.act` (`Shared/EditorBrain`), consulted at the key and re-derived at the act; the key intercept sits at `EditorTextView.insertNewline(_:)` after the list door. Type-time crystallization is untouched and is still how a fresh note's paragraphs are born (a note with no blocks is all tail; a tail with text still crystallizes); what the key no longer does is OPEN the tail — the tail opens only from a newline arriving as text (paste, drop). ⇧⏎ (13d A15) is the newline that stays inside the block, so a blank line inside a paragraph is ⇧⏎ (U-19 (3)); the chip OFF returns the whole note to Return-as-content. I4 is untouched: a typed Return is now a structural gesture routed through the one structural door, never a content newline that later becomes structure. The phone's Return model is unchanged (the mobile catch-up's). Three unruled edges are QUESTIONS #92, PROVISIONAL.**

### local-only sync machinery (never synced; SyncSpec §3)
```sql
CREATE TABLE sync_outbox (
  table_name TEXT NOT NULL,
  row_id     TEXT NOT NULL,
  queued_at  TEXT NOT NULL,
  PRIMARY KEY (table_name, row_id)              -- dirty-row SET: coalesces keystroke-rate autosaves
);
CREATE TABLE sync_state (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- keys: 'last_server_seq', 'rekey_in_progress'
--   ('device_id' LEFT this table at pre-13x, 2026-09-07 — the device
--   identity rides the per-store sync custody record in the device
--   Keychain beside the library key (the pre-13x design §3.3, decision
--   13): a copy of the library file is writing, never a device; the
--   migration's leg 1 carried an existing row into custody and deleted it)
--   ('rekey_in_progress' — Phase 14c ladder R1-1: a persisted
--   rekey-in-progress marker, written before the CF-8 re-key's vault
--   write and cleared only when the whole road completes, so a crash
--   mid-re-key re-speaks the rerun road on relaunch and both engine
--   round halves refuse until it clears; local-only, never synced,
--   survives resyncReinitialize by construction)
CREATE TABLE _sync_applying (applying INTEGER NOT NULL);
-- apply-mode flag; permanent and normally empty (a temp table is invisible to
-- main-schema triggers — Phase 1 finding, SyncSpec §3); row exists only inside
-- an apply transaction
CREATE TABLE sync_row_seq (
  table_name TEXT NOT NULL,
  row_id     TEXT NOT NULL,
  server_seq INTEGER NOT NULL,
  PRIMARY KEY (table_name, row_id)
);
-- per-row server_seq bookkeeping (migration v1_3, ratified 2026-07-06):
-- written on push-accept and pull-apply; read by SyncSpec §7's seq-ranked
-- repairs; a row the server never accepted ranks as seq 0
```

## 8. Cardinality summary
```
reading ──< reading_post >── container(kind=post)      many-to-many, non-owning (on-demand books)
reading ──< reading_section                            chapters: ordered groupings within a curated book (Phase 13)
reading_post ──> reading_section (section_id)          membership points at its chapter; dangling ⇒ unsectioned
container(post|pool) ──< container_block >── block     ONE live container per block (owning)
block ──< variant                                      one block, many variants (the fan)
block ──< block_comment                                working notes on a block, never per-take (Phase 13)
variant ──< commit_point                               append-only savepoints
variant ──> variant (parent_variant_id)                history/branch tree
block ──< edge >── block                               derived_from (directed), version_of (undirected)
tag ──< post_tag >── container(kind=post)              many-to-many
tag ──< block_tag >── block                            many-to-many
tag ──> tag (parent_id)                                hierarchy
```

## 9. Operations as a transactional API (the hard core)

Every mutation is one of these; each is a single transaction through the operations layer — never ad-hoc row writes. Text-changing ops also update `container.last_touched_at` and churn (§10). **All structural ops touch:** divide-W, merge, and poolDragCopy stamp `last_touched_at` too (restructuring is working on the post — author decision 2026-07-06) but never churn — restructuring must not reshuffle the meaningful sort. Exact row-level state transitions (rows read/written, before/after) are specified per-operation in the schema/operations phase plans, with a test per transition.

- **newBlock(container, text, at)** — INSERT block; INSERT variant(working_text=text); set block.default_variant_id; INSERT container_block(chosen=variant, position at insertion point).
- **autosave(variant, text, charDelta)** — UPDATE working_text, updated_at; accumulate churn; threshold-cross ⇒ stamp major revision, reset, rebaseline (§10).
- **commit(variant, kind=manual, message?)** — INSERT commit_point(text=working_text). Counts as a major revision.
- **idleAutoCommit(post)** *(author-approved 2026-07-04)* — when a post with uncommitted buffer changes goes untouched for `idle_commit_hours` (setting, **default 2** — dropped from 24 by Phase 13j's savepoint-cadence ruling J11, where the idle timer became the backstop behind `closeAutoCommit`'s leaving-a-note savepoint; corrected here at 17f/P46): one commit_point per dirty variant, kind='auto', at most one per idle period, only if the text changed since that variant's last commit. Visually quiet, prunable. Insurance for "I rewrote it over weeks and never committed."
- **restoreCommit(variant, commit)** — UPDATE working_text = commit.text (old commits remain; I5). **Known behavior (review #9):** a commit may predate a structural op — after a single-variant divide or extract, A's old commits still hold the full pre-split text, so restoring one resurrects both halves into A's buffer while the successor block still sits next door. Coherent under "coarse, not forensic"; the editor should warn ("this commit predates a split of this block") — documented Phase 3 test, UI warning at the editor phase.
- **renameCommitPoint(commit, message?)** *(13u3, author ruling R-13u3-1 — savepoint names are EDITABLE after the fact)* — set/clear `commit_point.message`; nil clears; a no-op writes nothing (no touch, no churn, no outbox row — the `setBlockName` identity-metadata class); returns whether it WROTE, and the Block History door speaks its receipt from that answer (a silent no-op never earns a receipt — the 13u3 ladder's R1-2). Refuses under a sealed post (the seal's letter; the guard order matches `setTakeLabel`'s — checked BEFORE the no-op short-circuit, so a same-name rename under a seal refuses rather than silently succeeding); ALLOWED on a locked take (the lock guards the buffer; a label is not the buffer — PROVISIONAL, QUESTIONS #121). The snapshot TEXT stays immutable — I5 is untouched by the whole name family; auto savepoints keep their occasion as the default label. Under sync, `message` is plain metadata CAS (SyncSpec §6's 13u3 annotation) — zero engine lines.
- **branchVariant(block, fromVariant)** — INSERT variant(parent=fromVariant, working_text=**copied**, fan_position=next). *The default gesture.*
- **newBlankVariant(block)** — branch with working_text=''. *The "genuinely different take" gesture.*
- **extract(blockA, span)** — *source survives.* Span must be a boundary-adjacent prefix/suffix of A's active variant. INSERT block B + variant(text=span); UPDATE A's active variant = remainder (other variants untouched); INSERT container_block(B) adjacent; edge(B derived_from A, 'extract'). Zero ceremony. A middle span cannot extract — that's a divide. **Known behavior (review #10):** extracting from a *fanned* block edits only the chosen variant — the other variants keep their own versions of that span, so switching the slot's chosen variant later shows the extracted content twice. Accepted (the model-level "fix" would be per-variant marking, i.e. turning extract into divide); the editor may hint when extracting from a fanned block.
- **divide(blockA, cut)** — *source consumed into ordered successors.*
  - **single-variant (everyday, in-place):** INSERT block C + variant(text=A[cut:]); UPDATE A's variant = A[:cut] (A keeps identity as first half — lossless, no fan to desync); INSERT container_block(C) after A; edge(C derived_from A, 'divide').
  - **multi-variant (rare; the only ceremony; W resolution):** A is **preserved whole** — its placement is released (container_block tombstoned), unmarked variants stay on A as lineage. For each marked variant Vi: INSERT first-half variant on new block B, second-half on new block C → B's fan = first-halves, C's fan = second-halves. INSERT placements B then C where A stood; edges (B derived_from A), (C derived_from A, 'divide'). Reversible by re-pointing at A. *(18c batch 1, 2026-09-07 — two additive arms, both default-preserving: a PARKED take — a whole-take ride under S4-22 ruling 2 — KEEPS ITS LABEL, the rule `divideDuplicating`'s duplicates and `mergeCeremony`'s carries already stated and divideW alone omitted since 13b Stage 4; and an optional `displayedVariantID` anchors each side's chosen/default on the take the author was working in when the caller can name it — nil keeps A's rendered take, the ceremony passes nil. QUESTIONS #91 carries the second as PROVISIONAL.)* *(18f, 2026-09-07/08 — THE FACE: the ceremony's UI name is **"Divide choosing takes…"** (U-4, her word: "clearer"; the model's term "the W ceremony" and the code's type names stay); its sheet opens on an ARRANGEMENT ROW of four — **Keep takes on the top block** (selected on open — the instant default, byte-identical on confirm), **Keep takes on the bottom block**, **Copy takes to both** (`divideDuplicating`), **Choose per take…** (the hand-placement vocabulary: every take CHECKED, the non-seed ✂ parked at the END — U-3/U-5); real prose side by side (up to three columns), the ✂ an overlay on the inter-word gap, placement by character hit-testing through the one snapping brain; rebuilt to her approved mockup, figure A. Doors: beside Divide in the block ▾ menu and the bulk bars; ⌥⌘⇧D. The bulk bars' merge door offers the two run options at every pick size — QUESTIONS #95, PROVISIONAL.)*
  - **WHERE A CUT MAY FALL (author ruling S4-22, Phase 13b Stage 4 — supersedes the sentence/paragraph-only reading of the ratified snap-and-proceed contract):** a cut may land **between any two words and at newlines**, with a **word-edge floor** (never mid-word; a one-word half is legal) and **gentle settle** magnetism — sentence ends and newlines pull a little, so the common landings stay easy without being the only ones. **ONE rule everywhere:** plain divide, the ceremony's per-take cuts, `CutPropagation`'s seeding, and **extract's span edges** all consult the one Domain function (`BoundarySnapping`) — two behaviors for one gesture is the confusion class 13b exists to kill. Extract's prefix/suffix boundary-adjacency requirement itself is untouched.
  - **PARKING — the ends mean something (same ruling):** in the ceremony, a checked take whose cut sits at its very **END** contributes its whole text to the **first** block and takes no part in the second; at its very **START**, the mirror. Consequence, deliberate: **B's and C's fans are independently sized** (they are no longer per-take mirror images), and the old "this take is a single sentence, so it has no legal placement" dead end is gone in both directions. **I10 at birth:** a confirm in which *every* checked take parks at the same end would leave the other successor takeless and is refused (`divideSideWouldBeEmpty`); an empty take's cut is refused as ambiguous (`invalidCut` — which block gets the blank would be a guess). Plain no-ceremony divide at the block's very start or end still refuses ("nothing to divide") — there is no second take to give the whole text to.
- **divideDuplicating(blockA, displayedVariant, cut)** *(author ruling Q-M2, 2026-08-03 at the mobile gate sitting — "both mobile and mac should change their default divide behavior"; BUILT at the mobile parity round Stage A, 2026-08-09: the shared core op + the phone's fanned-divide door; the MAC door change — default flip + the deliberate ceremony door + keybind — is Phase 13j's, so the op sits dormant Mac-side until then)* — **her duplicate-shape divide for a FANNED block**, ONE transaction: the DISPLAYED take's halves seed B (first half) and C (second half) — each successor's chosen + default, leading its fan; **every OTHER active take is duplicated WHOLE onto BOTH successors** behind them in source fan order (fresh UUIDs; labels ride; parent trees remapped inside each copy set; never born locked; commits never copied). A is released to lineage **PRESERVED WHOLE** — the W resolution unchanged, reversible via `placeBlock`; edges `(B derived_from A)`, `(C derived_from A, 'divide')`; divide-W comment travel (copies to B AND C); presentation inherited; archived takes stay on A; touch-without-churn; ONE structural undo entry with the exact-row redo. The cut consults the one `BoundarySnapping` rule (S4-22); start/end cuts refuse (`invalidCut` — no parking; the ends-mean-something rule stays the ceremony's). Accepted consequence, hers knowingly: a duplicated take chosen on both successors reads twice — the fanned-extract duplication class ("quick to delete"). Single-take divide is untouched; the W ceremony survives as the deliberately-summoned option. **SUPERSEDED AS THE DEFAULT (author ruling U-2, 2026-09-06, the use-report round's 18c — on BOTH platforms): a fanned block now divides KEEP-ON-TOP** — the displayed take is cut into B and C and every OTHER active take rides WHOLE onto B, composed from `divideW`'s parking rule (`KeepOnTopDivide`, `Sources/VariorumCore/Domain/`, zero new operation; the phone flipped in the same batch, her follow-up). `divideDuplicating` stays in core unchanged as 18f's third preset ("Copy takes to both"); U-5's second preset is the composition's `keepBelow` mirror. Her words: *"I know I said that should be the default, but I honestly believe now that if you divide, the takes should automatically stay on the top block that you divided."*
- **merge(B, C)** — *mirrors W.* INSERT block A' + variant(text = chosen(B) + `" "` + chosen(C) — **a single space at the join** unless either side's edge already carries whitespace; author decision 2026-07-06, a raw no-space join was more annoying than helpful. Consequence: divide-then-merge restores a sentence cut exactly, while a paragraph cut comes back as a space — the author adjusts in the editor); replace both placements with A'; edges (A' derived_from B), (A' derived_from C, 'merge'). B, C released to lineage (stamping `last_container_id`, so a released block deleted later still trays); fans are **not** cartesian-producted.
- **mergeCeremony(B, C, pairings, carries)** *(the PAIRING extension — **author canon ruling S4-23**, Phase 13b Stage 4: "a merge ceremony to match the divide ceremony… I think is an important option to have")* — **a merge may now mint SEVERAL takes on the merged block**, where plain `merge` mints exactly one. Each hand-placed **＋ pairing** mints one joined take (left half + right half under that pairing's explicit join); each **carried** take rides onto A′ **whole and unjoined**; unpaired, uncarried takes stay with their released source blocks in lineage exactly as before. **Nothing is cartesian-producted — pairing is choosing by hand** (OverallModel §7's rule survives intact, and a take participates in at most one pairing: 1:1 arity, PROVISIONAL — multi-pairing deliberately unbuilt). Everything else composes with `merge` byte-identically: adjacency, the seal refusal, releases stamping `last_container_id`, both `derived_from`/'merge' edges, comment and presentation travel, touch-without-churn, and ONE undo entry restoring the sources whole. **I10 at birth:** a confirm minting no take at all (zero pairings, zero carries) is refused (`mergedBlockWouldHaveNoTake`). The join is explicit per pairing (space · newline · nothing, defaulting to the canon rule above); the **instant no-fan merge is byte-unchanged**, and the ceremony opens only when a fan exists on either side, pre-paired with the chosen takes so confirming immediately reproduces the old outcome. *Why this is canon and not UI: it changes what "merge" MEANS — divide-then-merge now round-trips whole when you pair 1+1 and 2+2, which the one-take rule could never do.* *(18f, 2026-09-07/08: the UI name is **"Merge choosing takes…"** — a BUTTON beside Merge in the block ▾ menu and the bulk bars, not only ⌥⌘⇧M (U-4); its sheet opens on the arrangement row **Bring every take** (selected — the carry-all default) · **Only the two shown** · **Pair by hand…** (the S4-23 pairing surface, restyled to figure B). **Over a run of THREE OR MORE blocks the door offers exactly TWO choices — Bring every take · Only the shown ones — and never the pairing surface** (U-16, her amendment at the mockup approval: "i don't want a super complex ceremony for merging multiple blocks together"); the former pairwise refusal retired.)*
- **poolDragCopy(poolBlock P → post, at, includeFan=false)** — INSERT block B + variant(s): the rendered variant's text by default, the whole *live* fan if `includeFan` (**archived takes ride along with statuses preserved** — author-ratified 2026-07-06; commits are never copied, copies are not born locked, the parent tree is remapped inside the copy); INSERT container_block(B) at drop; edge(B derived_from P, 'pool_copy'). P stays in its pool. Pool→draft is the only copy direction.
- **moveBlock(block → container, at)** — UPDATE container_block.container_id + position. Single ownership preserved by the live-unique index.
- **placeBlock(block, container, at)** *(review #7 — the op W-reversibility depends on)* — INSERT container_block for a live block with **no live placement** (a released-to-lineage block after divide-W/merge, or a tray restoree). This is the primitive that makes "reversible by re-pointing at A" a real operation instead of a promise, and it's what structural undo emits.
- **restoreBlock(block)** — undo a deleteBlock from the tray: clear the block's tombstone and those of children whose `deleted_at` equals the block's (cascade-stamped with the same value, so cascade-victims are identifiable and independently-deleted rows stay dead); then placeBlock into `last_container_id`. A stamp-matched tag application only revives if its tag is still live.
- **restoreContainer(container)** *(author decision 2026-07-05: deleted posts must be recoverable)* — undo a deleteContainer: clear the container's tombstone and every cascade victim carrying its exact stamp — placements, their singly-owned blocks and those blocks' children, reading memberships, post tags, references. Rows whose story diverged in the meantime are left alone: independently-deleted rows keep their different stamps; memberships/applications whose reading or tag has since died stay dead; a block independently revived keeps its current placement (I2) and one re-deleted under a newer stamp stays dead.
- **restoreReading(reading)** *(author ruling S4-28.2, Phase 13b Stage 4 — **this DELIBERATELY REVERSES the standing pre-13 boundary** that readings alone had no restore door; her words: "I feel like readings should have a restore door? at least the curated ones if they're deleted")* — undo a `deleteReading` on the `restoreContainer` pattern: clear the reading's tombstone and every cascade victim carrying its **exact stamp** — its `reading_section` chapters and its `reading_post` memberships. Rows whose story diverged are left dead: an independently-deleted chapter or removed membership carries a different stamp, and a membership whose **post** has since died stays dead (the live-parent guard). Chapter **assignments reattach for free** — the dangle rule never rewrote `section_id`. Smart readings restore by the tombstone flip alone (membership is derived); a finished reading restores finished; refuses when the reading is live (`readingNotDeleted`). **No undo entry** (the recovery-door class — the door *is* the recovery, as with tags/locks and `restoreSection`). `restoreSection`'s "died WITH its reading" refusal now has a two-step road: restore the reading first, then any independently-cut chapter. `Queries.deletedReadings` is the recovery surface. *Documented corner (pinned as behavior): a reading that died and whose member post died AFTER it leaves that membership stamped by the reading, so restoring both leaves it out — the ordinary add-to-book door is the honest road back.*
- **setPostWordTarget(post, words?)** *(author ruling S4-28.1, Phase 13b Stage 4 — the per-POST twin of `reading.word_target`; her words: "I think you should be able to set a word limit on a post if you want - it's still helpful")* — set/clear `container.word_target` (migration v1_12; §7). **Display/progress ONLY, NEVER an add- or type-time refusal** — the ratified `word_target` semantics mirrored exactly: minting and autosave far beyond the target both succeed. Identity-level metadata on the extent-setter conventions: refuses non-positive, nil clears, a no-op writes nothing (no touch, no churn, no outbox row). **PROVISIONAL: refuses under a sealed post** (the reading extent setters' refuse-under-locked parallel — a sealed post is marked complete and its writing goal is part of what "complete" froze; the container-row-metadata-allowed reading argues the other way and is one guard line away — the author's call).
- **renameTag(tag, newName)** *(review D1)* — rewrite `name` + the materialized `path` of the tag and its entire subtree in one transaction. Bounded by subtree size (fine locally); under sync it's plain metadata CAS per row — converges, worst case a lost rename, never corruption.
- **reorder(block, between A and B)** — UPDATE container_block.position = `FractionalIndex.between(A.position, B.position)` (jittered; §6). No rebalance operation exists — fractional-index strings have unlimited depth.
- **lockVariant / unlockVariant** — UPDATE variant.locked. Locked ⇒ to edit, branch or unlock. Locking a dirty buffer first appends one quiet auto commit (kind='auto') — the guard insures exactly what it protects, so unlock-then-edit can never destroy it (author decision 2026-07-05; mirrors lockPost's consequence-not-equivalence). Commit of a locked variant stays refused; lock toggles under a sealed post are refused like everything else under the seal.
- **lockPost / unlockPost** — auto-commit (kind='auto') dirty live buffers under the post, then UPDATE container.locked/locked_at. While locked: no edits, no new commits, pointer order + chosen variants frozen (the seal refuses *everything under* the post — author-ratified 2026-07-05). The seal is content-level: the post itself may still be archived, deleted (recoverable via restoreContainer), retitled, tagged, and added to readings without unsealing. Reversible.
- **archiveVariant / deleteVariant** — archive: status='archived' (out of fan, kept in history); delete: tombstone (must not be any slot's chosen variant — re-point first). **Precision (review #3): the operations-layer check is the *only* live enforcement** — under soft-delete-everywhere, tombstones are UPDATEs, so the FK RESTRICT never fires; RESTRICT guards only the physical-purge/GC path. Tests target the ops layer. Either way, if it was the block's last live *active* variant → refuse (I10; caller should delete the block instead — and note the sync-race variant of this, repaired per SyncSpec §7). If it was `default_variant_id` → reassign to the most recently updated active variant.
- **deleteBlock(block, requiring: precondition = .none)** — tombstone block + its container_block row; set last_container_id (feeds the deleted-blocks tray). Trigger-cascade tombstones variants (and their commit_points) and edges. Soft by default; true purge is a rare, explicit GC. **The optional `precondition` is re-checked INSIDE the tombstone's own transaction** *(Phase 13c Stage 1 ladder, R3-1/R3-3)*: `.none` is the ordinary door (the block goes, whatever it holds — the author's unrestricted-delete call, QUESTIONS #33(a)), while `.emptyWithNothingUnshown(variantID:)` is the A7 seam-backspace carve's authorization — the named variant must still be the block's ONE live variant (no fan, no archived take), active, unlocked, under an unsealed post, with an empty buffer, and the block must carry no live comment; anything else refuses the whole gesture (`blockCarriesUnshownText`, or `bufferChangedSinceGesture` when only the text moved). **Why it is a parameter and not a caller-side check:** a caller whose authorization depends on what the block currently HOLDS was checking a projection — and the editor's projection is deliberately held stale while the buffer is dirty, so a comment or take arriving during a typing burst was invisible to it. A precondition evaluated in the tombstone's transaction cannot be read stale. The same precondition rides the structural-redo re-apply, since a redo lands a tombstone too.
- **applyTag / removeTag (post or block)** — INSERT into post_tag/block_tag or tombstone; operations layer enforces post_tag targets kind='post'.
- **addReference / removeReference / updateReferenceViewState (post)** — INSERT/tombstone/UPDATE `reference` rows (§7).
- **resolveSyncConflict(variant, losingText, label='conflict')** *(sync phase, S5; Phase 9b adds the `label` parameter)* — INSERT variant(working_text=losingText, label) on the same block (same parent, fan's end). The losing edit becomes a card in the fan; nothing clobbered. *(The Fragments bridge landed its rescued bodies through this same door labeled `'fragments'` — the S5 doctrine extended to a second writer — until its retirement, 2026-09-04, tag `archive/fragments-bridge-2026-09-04`; the `label` parameter stays, generic.)* **Lands even under a sealed post** (author-ratified 2026-07-06: S5 outranks the seal — the seal freezes *authoring*, and a sync conflict is not authoring). Refuses a dead block; the engine's in-apply rescue path skips one silently instead.
- ~~**applyBridgeLanding(variant, container, body)**~~ — **RETIRED 2026-09-04** with the Fragments bridge (pre-13x batch 0b; the code archived at tag `archive/fragments-bridge-2026-09-04`, the record `notes/archive/fragments-bridge.md`). It was the bridge's landing overwrite — ONE transaction composing the insurance auto-commits, the overwrite of the variant's `working_text` with the landed body, and the landed body's own `commit_point(kind:'auto')`; the row's full text lives at the tag. The sixth quiet auto-commit occasion (OverallModel §3) retired with it.
- **addBlockComment / editBlockComment / deleteBlockComment / restoreBlockComment** *(Phase 13, A1/A2 — §7 `block_comment`)* — comment CRUD; delete is a tombstone, and deleted comments stay visible and resurrectable (`Queries.deletedBlockComments` — "never skimpy", author 2026-07-17). All comment writes refuse under a sealed post (PROVISIONAL, QUESTIONS #23; reading stays free under seal). **Travel rules (the author's duplicate-where-needed instinct, built A2):** structural successors get COPIES — extract/divide keep A's comments and copy them to the minted half; divide-W copies to B AND C (A, preserved whole, keeps the originals); merge carries BOTH sides' onto A′; poolDragCopy / duplicateAsVersion / promoteLens carry per-block copies. Copies are fresh owner-stamped rows **preserving the source's `created_at`** (a note's date is part of the note — PROVISIONAL #23); DELETED comments never travel; structural undo needs zero new machinery (reverting a mint cascades the copies away; originals untouched).
- **setBlockPresentation / updateBlockPresentation** *(Phase 13, A1/A2 — §7 `block.presentation`, the callout frame R16/R27)* — identity-level like `setBlockName` (no-op guard, no touch/churn); `updateBlockPresentation` is the read-modify-write door in ONE transaction (partial edits — color, emoji — read stored state inside the transaction). Refuses under seal (PROVISIONAL #24). **Travel:** structural successors INHERIT the source's frame (the span was the callout's content); merge keeps the frame only when BOTH sources agree, else mints PLAIN (#24); duplicateAsVersion/promoteLens copy presentation AND `block.name` together; poolDragCopy copies presentation (and comments) but has never copied `name` — the recorded pre-13 asymmetry, #24(e), author call pending. Export maps a callout to a blockquote form (a presentation transform only — `renderedText` and the bridge's join brain never map; pinned).
- **createSection / renameSection / deleteSection / reorderSection / assignPostToSection / restoreSection** *(Phase 13, A1 + review round 1 — §7 `reading_section`, chapters R28/R50)* — CURATED readings only (smart readings refuse; #25). A locked reading freezes chapter STRUCTURE (create/delete/reorder/assign) while rename stays free — the `renameReading` parallel (#25). `deleteSection` tombstones only the section (memberships keep their pointer; the dangle reads as unsectioned); **`restoreSection`** is one tombstone flip — surviving assignments reattach for FREE precisely because the dangle rule never rewrote them; refuses when the section is live, under a locked reading, or when the section died WITH its reading (readings themselves have no restore door — a standing pre-13 boundary). No undo entry (the tags/locks class — the door is the recovery).
- **setReadingWordTarget / setReadingMaxPosts** *(Phase 13, A1 — §7 `reading.word_target`; `max_posts`' FIRST setter)* — both refuse non-positive values and refuse under a locked reading (extending a finished notebook = un-finish first, #25). `word_target` is display/progress only, never an add-time refusal; lowering `max_posts` below current membership is legal (further adds refuse at the standing capacity gate).
- **assertReadingAcceptsPosts(reading)** *(Phase 13, review round 3)* — the `addPostToReading` gate as a standalone core read (missing / wrong-kind / locked / at-capacity), run INSIDE the serialized closure so a UI door can refuse BEFORE minting anything (the locked non-daily book's "+ new entry" path — no stray posts, per-op transactions notwithstanding).
- **shelveInDailyJournalBook(post)** *(Phase 13c, batch 1D — ledger A1; the SECOND HALF of the daily door, made shared)* — put the day's entry into the **designated daily journal book** (`daily_journal_book`) as ordinary membership (R50's letter). `createOrOpenJournalEntry` mints or opens the day's entry and stops; only ⌘J/"Today's Entry" ever carried the membership half, so every other door — the phone's capture, and the Fragments bridge's landing until its 2026-09-04 retirement — minted days into NO book, and "posts in no book" is exactly what the Pool lists (R29). **It NEVER throws:** it returns what happened (`shelved` / `alreadyDecided` / `bookFinished` / `bookAtCapacity` / `wrongKind` / `refused`) and each surface words it, so shelving can never block a mint or a landing — "nothing typed in either app can be permanently lost" outranks tidiness. **Any `reading_post` row for the pair — live OR tombstoned — means the pair is already decided**, so a headless round can never undo a deliberate `removePostFromReading`; the same rule is what makes it a REPAIR for days that landed bookless before it existed. **It CREATES AND PINS the Journal book when none is designated** *(author ruling, the 13d sitting 2026-07-28 — QUESTIONS #37 OVERTURNED to option (iii); her words: "the fragments entries should arrive as part of Journal")*: with no designation — or one dangling at a deleted book, which reads the same way — this door mints the book exactly as ⌘J's first press always did (curated, `profile:'journal'`, `entry_date` ascending, designated, shelf-pinned), and **⌘J delegates its WHOLE ensure here**, so all four doors (three since the bridge's retirement) share one rule with no residue at any of them. *This supersedes the shipped PROVISIONAL "It never creates a book … ⌘J keeps create-and-pin, deliberately, because minting a book on the shelf is an act only a button press takes" (13c batch 1D; the ensure half alone had already been shared at the Stage 1 ladder's R1-4).* What creation does NOT do: it never replaces a book she designated — a FINISHED, FULL or SMART daily book keeps its own status and its own wording, because those are her deliberate states and answering them by minting a second Journal beside hers would be inventing product behavior. The `noDailyBook` case is retired from `DailyBookShelving` with the ruling: it can no longer occur, and a case that can never be returned is the drift class. No undo entry (the `addPostToReading` class). **It is a READ-THEN-ACT composite, not a single transaction** (13c Stage 1 ladder, R2-10 — stated so no reader infers atomicity from this section's header): it reads the designation and the pair's membership, then calls `addPostToReading`. The live-row race is caught by that op's own `alreadyInReading` guard; the tombstoned-row race — a `removePostFromReading` committing in the sub-millisecond window between the read and the insert — is not, and would re-shelve an entry just removed. Headless, sub-ms, and honestly unpinnable without an op-level precondition (the `confirmDivideWCeremony` residual's class); recorded rather than papered over.

- **convertSmartReadingToCurated(reading, order: nil)** *(Phase 13c, batch 2D + the K6 review's K2 fix — N38's shape A, PROVISIONAL in full, QUESTIONS #46)* — ONE transaction: the smart book's current assembly materializes as real `reading_post` rows **in the order given** (`order:` — the caller passes the view-local order the author is browsing, so "the order you're looking at" is literally true; nil = the stored sort), `kind` flips to `curated`, `sort_field` freezes to `manual` so nothing moves on screen; `query_spec` and `grouping_tag_id` stay on the row (tag-derived sections keep rendering until real chapters exist — the standing precedence). Refuses non-smart and locked readings. Structural undo AND redo, exact-row on do-time ids. The fresh-collector offer (a new smart book carrying filter/order/sectioning, never extents or finish state) is a face-level composition beside the op, not part of it.

- **divergePostForReading(post, reading)** *(Phase 13f, W23 — her round-10 ruling: the diverge button "nicely duplicates it as version and deletes the original for you all in one go"; the composite shape ruled at the batch-5 gate — an operations-layer composite of the standing paths, NO new semantics)* — ONE transaction: a `duplicateAsVersion`-shaped copy of the post; the copy's membership minted at the original's EXACT slot (position AND `section_id`); the original's membership tombstoned — **THIS book only**: the original lives on in its other books and the library (R31/R35's letter, which she re-affirmed at round 9). CURATED books only (a smart target refuses, naming the tag road — derived membership has no row to swap; 13i owns that design); refuses under a finished book (#25's letter). Capacity is deliberately un-gated (the swap is net-zero — the extent gate refuses ADDS). Registers ONE undo entry with inverse AND redo from do-time pre-images; **the redo revives the copy through `restoreContainer`'s exact-stamp path** (the 13f review's R1-1 fix — a container-only flip left a live but EMPTY note, its text stranded in cascade-tombstoned rows). Doors: the one-time multi-book first-edit note's button and the membership chip's book rows, both flushing the post's pending buffer first (R1-4 — the copy must carry the keystrokes that summoned the offer).

- **saveNoteVersion(post) / restoreNoteVersion(post, version) / promoteNoteVersion(version)** *(the post-13l polish round, 2026-08-24/25 — her whole-note Versions door, G1 + the ratified V1–V9; the BINDING record is `notes/plans/post-13l-polish-round.md`)* — the note's moments. `saveNoteVersion` (⌘⇧S "Save a Version"): ONE transaction — a `duplicateAsVersion`-shaped FULL family copy born **archived + SEALED from one clock read** (`archived_at == created_at` IS the version classifier — version-ness needs no column; the seal's insurance auto-commits ride per the lockPost doctrine, so a promoted version's takes always carry a savepoint of the moment), no title mutation (the listing shows dates via derived display), and **no `entry_date`** (a moment is not a day — the bridge's duplicate-day pause is pinned untrippable). `restoreNoteVersion`: **identity-preserving** — save the moment of NOW first (flushing the pending buffer), the outgoing blocks take the **Delete Now road** (tombstone + purge intents in the restore's own transaction — never a raw row DELETE), the version's family is copied into the SAME container (same identity, books, memberships), and **every version link is re-anchored via the classifier's own read** (the ladder's LR2-1); fully repeatable. `promoteNoteVersion`: unarchive + unseal — the past becomes a first-class note FOREVER, by derivation (a later archive stamps a fresh `archived_at ≠ created_at`). **Versions RIDE the note's deletion** on its exact `deleted_at` stamp (one honest confirm line — her V2 ratification: no dialog; Put back revives the note WITH its moments); a deleted single version rows in the Trash grouped under its note. A version's ONE home is Note ▸ Versions — never the Library, the Archived surface, or any global search (the scopes are exact complements on `Queries.versionHistoryPredicate`; the search-scope handoff is 13o's).

**Structural undo (author-approved 2026-07-04; resolves the global-undo question):** a **session-scoped, in-memory undo stack for structural operations only** — divide, merge, extract, **newBlock**, deleteBlock, deleteVariant, archiveVariant, moveBlock, reorder, poolDragCopy. *(**`newBlock` JOINED this list 2026-09-14 — author ruling R-13u-3 at the 13u1 kickoff sitting, a canon extension she made herself**, from `KnownIssuesAndTechDebt.md`'s 18c-ladder row (half 2) and QUESTIONS #108's neighbourhood: ⌥⌘Z must remove an empty block just minted by ⏎. It had registered nothing since Phase 2 by OMISSION, not by ruling — harmless while ⌘⇧⏎ was the only door onto it, and newly common the moment U-1 made the Return key mint blocks. Her words for the inverse: **a tombstone flip** — with the exact-row redo beside it, and `revertStructural`'s standing behaviours riding in unchanged (an untouched mint vanishes; one she has typed into TRAYS instead, the insurance doctrine). **The ONE named exception is type-time crystallization**, where a paragraph becomes a block because she typed past it (§7: it "silently becomes a block as you type"): that is not a gesture, and registering it would put an entry on the stack per paragraph and clear the redo future on every one — so the crystallizers alone pass `registeringUndo: false`, at their own call sites, with the reason at the line. Built at 13u1 UNIT 2.)* Each of these registers its inverse when it runs (mostly tombstone-flips + placeBlock — cheap precisely because the model destroys nothing). **Undo emits ordinary operations**, so sync never knows undo exists and the merge rules already cover it. Explicitly excluded: text editing (command-Z remains NSTextView's ordinary per-buffer undo, never interleaved with structural undo), commits (append-only; restore *is* the feature), locks and tags (trivially re-toggled). No persistence across sessions — the deliberate cheap/nightmare line. Inverses are specified per-op in Phases 2–3 (they double as the reversibility tests); UI wiring at the editor phases.

**Structural REDO (Phase 13c, batch 1B — author item A10, verbatim: "i desperately need a 'redo' command to be able to undo my structural undos for when that was an accident"; structural undo had been one-directional by omission, never by ruling).** A second stack beside the undo one, LIFO the same way. **Every registration carries BOTH halves** — its `inverse` and a `redo` re-apply built from the SAME do-time pre-images — so an entry MOVES between the two stacks and undo↔redo ping-pongs indefinitely without re-deriving anything. `register`'s `redo:` parameter is **required, never defaulted**: a new registration site must decide rather than silently ship a hole (passing `nil` is legal and deliberate — such an entry is not redoable, and undoing past it ends the redo future, because redo is strictly LIFO and never skips over an entry). The re-applies are **exact-row like the inverses** (tombstone flips, pre-image restores — never a re-run of the forward operation, which would mint fresh UUIDs and strand the inverse's captured ids), so do → undo → redo returns the store to the post-do rows with every ID intact. **Any new structural act clears the redo future** — including a compound whose body throws and rolls back (its legs cleared the future as they registered; recorded behavior, 13c Stage 1 ladder R1-10). A compound is redoable only when EVERY leg is. Session-scoped and in-memory like undo, never persisted; and **redo emits ordinary operations**, so sync never learns redo exists either. Doors: **⇧⌥⌘Z**, the ⌥⌘Z mirror — deliberately never ⌘⇧Z, which stays NSTextView's ordinary text redo, since the two stacks never interleave and so their doors never share a key.

**`default_variant_id` lifecycle (resolves source-SPEC open question #9):** set at `newBlock`; on delete/archive of the variant it names, reassign to the most recently updated active variant; never NULL while the block is live (guaranteed jointly by I10 + reassignment). It is the pointer-free representative (pool display, lineage views); `container_block.chosen_variant_id` always wins where a pointer exists.

## 10. The "80%-edited" sort (anti-typo-reshuffle)

Two stamps per post: `last_touched_at` (every keystroke) and `last_major_revision_at` (meaningful edits only). The editor reports a char-delta per edit; the app accumulates `churn_accumulator` (chars inserted + chars deleted, equal weight) against `baseline_length`. When `churn / max(baseline,1) ≥ threshold` (setting, default 0.8): stamp, reset accumulator, rebaseline. A manual commit also stamps. A reading's `sort_field` picks which stamp orders the book; journals sort by `entry_date`. Churn math is a pure Domain function with its own tests.

## 11. Sync architecture (designed NOW, built at its phase)

**Authoritative document: `notes/SyncSpec.md`.** Summary: hand-rolled state-based row sync over Supabase/Postgres — rich local SQLite kept intact (the PowerSync-class engines were rejected: their JSON-view client storage deletes the FKs/triggers/partial-unique indexes this schema's invariants ride on). Dumb server (compare-and-set + `server_seq` changefeed); all merge intelligence client-side: conflict-as-variant for `working_text` (S5), server-version-wins for metadata, deterministic apply-time repairs for every live-unique index, deferred-FK batch application, trigger-fed coalescing outbox with apply-mode echo suppression. Ordering authority is `server_seq`, never wall clocks. Sync arrives **early** (see DetailedPlanForPhases) so iOS journal capture works while the app is young; multi-tenant (owner_id + RLS) reuses the same protocol at the accounts phase.

## 12. Views and the UI stance

**The desire for many views is firm and central** — each view is a different traversal that stress-tests a different edge of the model (folder → tags/membership; book-scrub → ordering + post-as-page; timeline → timestamps; outline → derived_from). A view that's tortured to build reveals a weak spot in the model before everything is built on it.

The views (all over one store): continuous/book view (each note scrolls internally; not paginated), book-scrub (page = a post; 50 entries = 50 pages), infinite scroll, timeline, side-by-side (`text | v1 | v2 | text`; also two posts in columns), swap-and-reread, outline-left/draft-right (independent or tracked scroll; outline items map via `derived_from` to the blocks they became), diff (whitespace normalization optional), expand-all-fans (fans stay open once expanded; close-all-fans button), folder, canvas/sticky-notes, the **reference panel** (per-post sources beside the draft: Quick Look / PDFKit with drag-selection-into-draft, read-only WKWebView for URLs — §7 `reference`), and the badge behavior (boundaries invisible at rest; on focus/hover a block reveals bounds; a corner badge appears **only** on blocks with a fan). A low-priority **unplaced-blocks utility view** (live blocks with no placement — divide-W/merge lineage leftovers) is a cheap query worth having as a safety net; owned by the remaining-views phase. *(Ratified supersession — Phase 13j sitting round 2, 2026-08-19: the GLOBAL listing is REMOVED as a user surface ("that cursed table of lost hopes and dreams" — her J6 report); released originals surface per-note in This Note's Tray and behind their successors' lineage doors, and `Queries.unplacedBlocks` survives as the debug safety net only. The sitting's utility enumeration is the record, in the 13j plan.)* The **collapsible block-TOC view** (author-adopted 2026-07-07): one row per block — the block's explicit name where set, else its first sentence **derived at read time** (never stored); a row expands into the ordinary read-cheap tier, and exactly one expanded block upgrades to the live editor (P3's split, reused); collapse state is session UI state, and collapsing lives in the view — **never as in-place text folding inside the live TK2 editor** (TEXTKIT2_NOTES §3). Owned by the remaining-views phase; §14's 2026-07-07 delta records the decision and the `block.name` column that rides with it.

**Phase 13 surfaces (shipped 2026-07-18; the BINDING design record is `notes/plans/phase-13-ui-design.md`'s sittings 1–8, rulings R1–R59):** the **two-voice theme system** — Terminal (leads) and Study, each carrying tokens AND idioms (the `›` selection marker, `~/` path grammar, blinking cursor; the Study voice's sepia/paper/serif from the mockups canon), hold at exactly two (R1/R12); light designed first, **dark = a fully black background in both voices** (R51); all fonts macOS-shipped (R49). The **reading-flow view mode** (direction C — a calm continuous page column, voice-independent; a finished book opens into it; virtualized per P3 — the round-3 fix). **Canvas is a VIEW opened on a post or the scraps area** (R40 — supersedes this section's earlier sidebar-level canvas listing): spatial arrangement plus at most the MINIMAL takes switcher ("see takes" → one take at a time — deliberately the mobile-inheritable pattern, R58's seed). The **takes presentations as shipped**: the four fan-out styles restyled on the v2 canon (tinted take cards, "✓ chosen", ONE live-editor ring — R12/R22), the changing-block wash behind a default-on toggle (R13), *(17p batch a, 2026-09-12 — her R-Q2: an EMPTY block in Takes is an empty LINE, exactly as in Write — the caret and the ⑂+ badge, no placeholder words; this supersedes the FACE of Phase 13 batch 9's R103 — its faint "empty take — line kept" note — whose substance stands: the kept line, its pane and its badge)* *(17p batch a → 17q, 2026-09-12/13 — her R-Q1, R-Q20 and R-Q21: the Takes article REMEMBERS where she left it per note for the session (the row at the top of the page and where its top sat — sub-row, above the fold too when it straddled it; a row taller than the page stays at the fold), restored on entry by one absolute idempotent aim that HOLDS until her hand; an ENTRY LANDING — the block she came from — OUTRANKS that memory when the note's current block CHANGED while she was away (R-Q21: "the same block" is the current block unchanged, so a plain round trip restores exactly and a deliberate move elsewhere reveals the block minimally at the nearer page edge, never to the top, one move); the fan-panel bloom door is never weighed against the memory — it restores, then reveals; the memory follows the rows as they arrive AND as they leave; a page left at rest comes back at rest in every mount order; the typewriter room stays. The record is `notes/plans/use-report-round-2026-09-12.md` R-8 and its three-round ladder — which found the restore had never run in the app before 17q (a construction-time flag), so the family's acceptance evidence is USE.)*, the short-block one-card-high horizontal strip (R24), *(the two ceremony sheets — **Divide choosing takes** · **Merge choosing takes** — rebuilt at 18f, 2026-09-07/08, to her approved mockups: one row of presets first, real prose side by side, the ✂ overlaid, explainers folded — the record `notes/plans/use-report-round-2026-09-06.md` §5.2 + R-4/R-5)*, **follow-the-scroll as a takes-viewing option in all modes** (R25), expand-all offered only where meaningful. The IA: sidebar final **Shelf · Library · Pool · Blocks** (R44) *(+ **Archived** — the post-13l polish round, 2026-08-24/25, her ruling: "archived should be a different item on the left… separating archive and trash more makes sense"; archived NOTES only; the Trash door is the Library masthead's trash icon and the ⋯ menu dissolved)* — the shelf (terminal list + tags column, pinning, finish/extent faces, bottom quick-entry bar R3), Library = everything (R32; timeline a view mode) *(18h, 2026-09-12/13 — her rulings R-Q7 · R-Q8: the Library's rows — List and the Notes cards — carry a muted TIME STAMP, the sort's own, worded by the ONE pure brain `TimeStampFace` in core `Domain` (today with its time · yesterday · the day · the day with its year); the header carries a `sort ▾` door — edited · created · date · title — with a direction remembered LOCALLY, never a synced `setting`; the note's masthead wears the same stamp at the trailing end of its second row, flipping edited ↔ created on a click; and a **day filter** (`on day…`) answers "notes edited on this day" as the UNION of the note's own last-edit stamp and any savepoint written that day on a take it holds — the honest reading under §10's one-stamp-per-note design, the caveat worded on the surface where the answer is empty, the day→UTC conversion core's `DayBounds` on an explicit Gregorian calendar in her time zone, ONE query arm — the savepoint half an UNCORRELATED `IN` over `idx_commit_created` (the 18h ladder's BLOCKER: the correlated form cost Σ(blocks × takes) over the corpus on any past day, P1); the day's answer is uncapped and the capped listing under every sort says when it is truncated; a day names NOTES — books and blocks stand down while one is armed. The Notes cards carry BOTH the day she stated and the sort's own stamp where the row has room, collapsing to ONE click-flipping stamp where it does not (17q, her R-Q17 on QUESTIONS #103; under the `date` sort the second fact is the edit stamp, never one day twice), and the List row's beside-the-title day speaks the same brain and stands down under the `date` sort where the trailing stamp already says it. #103 RULED and BUILT (three PROVISIONAL calls on it: the pair beside the title; the edit stamp as the second under `date`; a no-day note showing its edit stamp) · #104 RATIFIED (a) · #105 RULED (a) — the title yields, both stamps always show on the Mac. Zero schema, zero `setting`, the marker stays 8.)*, Pool = bookless posts (R29), ⌘K palette (R15), ⌘N = New Post (R41), Settings = tag management's home (R52; hierarchy stays surfaced, R45). *(18i, 2026-09-13 — her R-Q5: every message the app speaks now carries a KIND on the one status seam — **refusal · offer · receipt** — decided at the DOOR that produced it (a receipt reports an act that LANDED; a door that did NOTHING speaks a refusal under every setting — the ladder's BLOCKER, the note-delete and import doors); a synced setting `receipt_style` (**toast · quiet · off**, **quiet by default**, applied at read, never seeded) governs RECEIPTS ONLY, rendering them as a muted line at the bottom bar's trailing end (`QuietReceiptLine`, composed by Write's bar, the takes/lenses bar and the book's sidebar note-box footer — always mounted so nothing moves for it); **refusals and offers always toast under every value** (P-2), and not one string changed. QUESTIONS #106 RULED (a) by her R-Q23 — "quiet means quiet": a receipt spoken on a surface with no bottom bar (Blocks · Canvas · Compare) is not shown under `quiet`; the five doors that cost is recorded in the record's J35 for her. The record is `notes/plans/use-report-round-2026-09-12.md` R-5 and its ladder.)* *(18g, 2026-09-13/14 — her R-Q6 · R-Q11 · R-Q13: a **COLOUR PALETTE** now layers UNDER the voice — sixteen choices plus her own hex (four pastels · six two-tone builds · five bold builds · custom), stored as the synced settings `theme_palette` + `theme_tint` + `theme_accent_tint`. **The voices still hold at exactly two (R1/R12):** a palette replaces only the room, the wash, the accent, the take tints and the hairline (and, in dark, the paper's whisper of hue) — derived from one or two seed hues by ONE pure rule (`PaletteDerivation`, two intensity tables fitted to her approved mockup) whose accent is stepped deep enough to clear WCAG AA on its own room and wash, so any hex she types reads (six of the mockup's accents therefore ship deeper — her call to reverse, one constant each). Type, idioms, "✓ chosen", the editing ring, the star, the alarm, the comment register, the code chip and the block seam stay the VOICE's; **`default` is each voice's shipped colours byte-identical**; ONE settings→tokens road serves the SwiftUI chrome AND the AppKit text surfaces (the caret, the selection wash, the indicator, the dark paper, the markdown link — the ladder's MAJOR); a palette click writes nothing to a note's storage; and dark keeps a fully black room under every palette (R51). The phone does NOT yet inherit it (a MOBILE PARITY row — its voice is local). PROVISIONAL: QUESTIONS #107 — the calm reading page's own voice-independent tokens (R2) are untouched by a palette. The record is `notes/plans/use-report-round-2026-09-12.md` R-6 and its two-round Fable ladder.)* *(18j, 2026-09-14 — her R-Q12, 13u4's item 6 pulled forward: the Mac gains an **APPEARANCE CHOICE** — follow system · light · dark — a LOCAL preference of this machine (the voice and the palette stay synced; how bright the screen should be is about where she is sitting), applied ONCE as the app's own appearance (`NSApp.appearance`, one owner on the app delegate) so every window, sheet, menu and the Settings scene follows and not one surface needed touching; the one exception, measured, is a status item's MENU, which follows the SYSTEM by AppKit's own rule. **Dark is a fully black room in both voices and under every preset (R51), pinned at the resolver**, and a palette's dark paper stays a whisper of that room. The prose ink is now ONE dynamic colour per voice carried by the editor's base attributes — so a light/dark change costs no storage write at all, and the full-document editor's prose is the voice's ink rather than AppKit's default, which in dark had been black on black (the walk's first find, pre-existing since the editor's birth); a faced run follows the CURRENT ink (the 18g ladder's R2-1, shared core, the phone's dynamic-colour pattern adopted). Every surface walked dark in BOTH voices across the batch and its ladder (the R-7 sweep + the fix pass's 20 rows; the ONE deferral is the Account sheet, hers on the real store — the dev store has no sync doors); a grep pin bans literal colours outside the token layer, by named form. The record is `notes/plans/use-report-round-2026-09-12.md` R-7 and its two-round Fable ladder.)* The editor language: boundaries invisible at rest with **dotted seams on a global toggle** (R6/R42 — the 9d tint look retired), the editing indicator a setting (off/outline/background — R14/R22), **margin-default comments with the inline-tinted setting** (R7), callout blocks with the white-gap rule (R16/R17/R27), sacred margins (R9), everything visible in an editing surface editable (R8/R23). *(13u3, 2026-09-18/19 — her R-13u-9 gutter reversal BUILT: comments and callouts render in the whitespace GUTTER outside the text area on EVERY surface, stacked vertically at every width (R-13u3-3), and the prose column's measure and left edge NEVER move for a decoration — the one law, pinned per surface; the 17p-b lane (`reservesDecorLane`) retired whole, and margin comment cards reach the book/read surfaces for the first time; a callout's leading glyph is ONE GRAPHEME (R-13u3-4); the inline-tinted comment strips survive as her explicit opt-in (R-13u3-5); the margin card stays a read face — comment EDITING lives in the panel, itself rebuilt as ONE writing surface (R-13u3-6). The design record is `notes/plans/phase-13u3-memo-gutter.md`.)* *Taste-checkpoint fix round (2026-07-18/19, Sitting 9 — R60–R94, binding record in the plan file): the mode row is now **Write · Takes · Lenses · Compare · Outline · Blocks · Canvas** — the **LENSES tab** (the editable multi-column editor; ALL lens machinery's one home; column slots with prominent auto-named unnamed lenses; adopt-SWAPS preserving the outgoing chosen as a lens) split out of Takes, which is single-column fan work only and the FIRST-OPEN DEFAULT with per-post mode memory; the Phase 7 FanPanel is retired for the one v2 card grammar everywhere; the canvas switcher is VIEW-LOCAL (#28e answered — chosen moves only through the explicit ✓) and canvas movement is free; version links are unmarkable; the membership chip adds-to-book; books mint posts inside themselves; the keyboard family + the Shortcuts & Dictionary helper carry the legibility mandate.* *Ratified supersession (the pre-13u round, 2026-08-31 — her eighth-wave rulings W8-1/W8-5 on the Blocks/Snippets mockups, the binding record `notes/plans/pre-13u-round.md`): the NOTE mode row is now **Write · Takes · Index · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘8, derived from the one order) — **Index** (the block-TOC grown up: headings become sections, blocks nest under, a scroll-synced read-cheap pane; names/first sentences derived at read time, never stored) and **Read** (a read-only projection-tier page with a MINIMAL companion outline; clicking a sentence lands in Index at that block — the ONE scrolled-open door 13u's read-view jump and 13i's Book Panel reuse) join; **Blocks stays, earned as the poweruser workbench** (per-row facts, multi-select with a bulk bar, a context panel). The BOOK's mode control is the word-tab row **Outline · Index · Book · Read** — an index-like book view sharing Outline's grouping brain; Outline's open right earns its keep as a DETAILS GUTTER (note metadata to the side, never below the opening paragraphs); the minimal navigator stays beside every mode but Index, where the index IS that pane grown up. The 13-era mockups the author ruled "an actual guide" are committed at `notes/plans/pre-13u-mockups/blocks-and-snippets.html` — the app restyles toward that grammar (Act 10 the surfaces it touched; 13u2 the continuation), and the sidebar's liquid-glass floating pane retires for solid geometric lines. The scrap-area vocabulary is **Snippets** in every UI string (`container.kind='pool'` stays the model term — the K5 precedent) with **groups** as the container noun; the bookless-notes Pool keeps its name.* *Ratified supersession (the Act 10 correction round, 2026-09-01 — her rulings R-cor-5/7, the binding record `notes/plans/act10-correction-round.md`): the NOTE mode row is **Write · Takes · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘7, derived from the one order). The Index mode RETIRES INTO Read: READ carries an in-place `edit · read` switch, opening on `edit` — the editable index surface (the `▸ 01` outline column, toggleable, beside a text pane in which a clicked block goes live; P3's one live editor through the one authority) — and `read` is the calm page, never editable (continuous or horizontal pages), a click on a sentence flipping to `edit` at that block through the ONE scrolled-open door (`LandingTarget`) the book's Read → Index click-through shares. The BOOK's Index word-tab is EDITABLE in place; the book's Read stays read-only. The 13k K12 masthead tag-fold is superseded: the masthead's `#` glyph is the ONE tag door (an inline field with the cursor active), the fold retired there.* *Ratified supersession (the 2026-09-06 use-report round's 18d, 2026-09-08 — her rulings U-9 · U-10 · U-12 · U-13 · U-17; the binding record `notes/plans/use-report-round-2026-09-06.md` §5.4 + R-10…R-13; the mockup figures C/D): **the book's DETAILS GUTTER RETIRES ENTIRELY** — in every book EDITING mode (Outline · Index · Book, never Read) the focused note's controls live in **the sidebar's note box**, standing exactly where a note's "this note" rail stands, at the rail's height, in three states (no note selected · selected-not-live with the note's identity and facts and one "edit here" door · live with the identity line, an "editing" mark, the bar as a two-column grid and the word footer); the unfocused rows' facts line and the paged mode's floating card go with the gutter. **This Note's Tray** is chosen by two top-level views — Leaving · Archived — with one shared blocks/takes filter under them; the "deleted takes" fold is retired. **The outline's room:** the book navigator, Index's chapter panel and the note Read contents column are draggable LEADING columns (one shared `SideColumn` brain) whose widths are remembered. **Remembered note lengths:** a note's settled surface size in the book Outline and the Read ▸ Scroll flow is remembered per note in a LOCAL-ONLY store (never synced; refused at another width), so the surface is right from the first frame. PROVISIONALs: QUESTIONS #99 · #100 · #101.)*

**The visual UI opened as a deliberately open concept and was designed at Phase 13** (the paragraph above; iteration continues with the author). The original stance stands as history: in the technical phases the view list was *capabilities the model must support*, built functional and unstyled; the one load-bearing UI-shaped thing throughout was the read-cheap/edit-focused split (P3) — a performance constraint, not an aesthetic.

## 13. Build order

The master plan with phases, status, and closeouts is **`DetailedPlanForPhases.md`** — that document governs. Summary shape: substrate (schema → operations → queries) → editor core (with the Tahoe viewport spike first) → structural ops in the editor → readings + first views → remaining views → hardening → UI design passes (with the author) → sync → accounts → iOS → web. Defer aggressively: outline connector polish, fancy scrubber visuals, whitespace-diff niceties, within-post virtualization, all visual design.

## 14. Resolutions & deltas from the source SPEC

Resolved (source SPEC §14 open questions), with the calls made:

1. **Single-variant divide: in-place** (A keeps identity as first half) — avoids orphan proliferation on the everyday split; the asymmetry with multi-variant W is deliberate and documented in §9. ✔ confirmed
2. **Unified `container`** (posts + pools): confirmed — one live-unique ownership index beats NULL-column aesthetics. ✔
3. **Tagging: two tables** (`post_tag`, `block_tag`) replacing polymorphic `tagging` — real FKs, no discriminator. **Deliberate schema delta.** ✔
4. **Cascades-as-triggers**: confirmed; the trigger set is enumerated and individually tested in the schema phase (block→variants/container_block/edges/block_tags; container→container_blocks→blocks — a deleted post soft-deletes its singly-owned blocks; reading→reading_posts; tag→its applications). There is deliberately **no variant→commit_point cascade**: `commit_point` has no `deleted_at` column — commits are unreachable once their variant is tombstoned, and physical cleanup is the Phase 12 GC.
5. **Sync engine decided now** (author's direction: sync is early, not commercial-phase): hand-rolled row sync over Supabase/Postgres, fully specified in `notes/SyncSpec.md`. PowerSync-class engines rejected after research — their JSON-view client storage forbids the FKs/triggers/partial-unique indexes the invariants ride on. This *reverses* the earlier "defer the engine choice" call, exactly as the source SPEC warned it should be decided pre-schema — and it did change the schema (see below).
6. **Pool-copy scope**: active variant by default; `includeFan` option on the operation from day one. ✔
7. **Churn metric**: characters; inserts + deletes equal weight; threshold tunable. ✔
8. **Headings**: a block whose text is a Markdown heading — no schema column. ✔
9. **`default_variant_id` lifecycle**: defined in §9. ✔
10. **Edge directionality**: `source = descendant, target = ancestor`; reads "source derived_from target". ✔
11. **Fractional positions**: resolved by the sync sweep — fractional-index `TEXT` keys with jitter; **no rebalance operation** (REAL midpoints + mass renumber were a sync bomb; SyncSpec §8). Supersedes the earlier REAL-with-rebalance answer. ✔

Additional deltas: live-row partial unique indexes everywhere (§6 — correctness fix); I10 added (§5); `chosen_variant_id` NULL-fallback semantics defined (§7); stack concretized (§1–2: Observation + swift-dependencies, SPM core + thin app, Xcode 26 both machines, deployment target macOS 15, Swift Testing).

**The dated delta record (2026-07-04 → 2026-08-24, Phase 0 through Phase 13l) lives in `notes/AppSpecDeltaArchive.md`** — moved verbatim 2026-08-01 (author housekeeping, the Fragments precedent; the file had outgrown the context-load limit). §14 keeps the source-SPEC resolutions above and ONLY the most recent phase's delta below; the closeout ritual moves the outgoing delta to the archive in the same commit that records the next one. The archive is canon — rulings recorded there bind exactly as they did here.

**Author-decision + shipped-semantics delta (2026-09-18 → 09-19, PHASE 13u3 — FACES; the BINDING record is `notes/plans/phase-13u3-faces.md`: the KICKOFF SITTING RECORD R-13u3-1…7, the gutter memo `notes/plans/phase-13u3-memo-gutter.md`, eight UNIT RECORDs, the two-round ladder and the PHASE CLOSEOUT; the handoff `notes/handoffs/phase-13u3-handoff.md`):** **(1) CANON DELTAS, hers.** **§9 gains `renameCommitPoint`** (her ruling **R-13u3-1** at the kickoff sitting — savepoint names EDITABLE after the fact; the bullet carries the guard order, the did-write receipt rule and the I5 fence) and **SyncSpec §6's matrix row gains the one-field bend** (`commit_point.message` = editable metadata CAS; zero engine lines — verified against `Merge.swift`'s server-wins baseline BEFORE the unit built). **§12's editor language gains the GUTTER LAW** (her R-13u-9 reversal built; the memo's §3 rulings R-13u3-3…6 made at the sitting, her words verbatim there: the stack at every width · one grapheme · the inline strips survive as her opt-in · panel-only editing). **(2) A RECORDED ANALYSIS CORRECTED BY MEASUREMENT:** #80(e)'s premise (a restore strands set-aside ancestors) is FALSE — the version-of-now's copies mint a `derived_from` edge to every outgoing block, so none is ever stranded; what the road takes for good is the replaced paragraphs' HISTORY (savepoints · waiting deleted takes · deleted comments). The restore confirm names THAT, in numbers, and keeps the set-aside count computed as a tripwire. **Her R-13u3-7 re-ruled #122(a) AS BUILT on the corrected ground, at the morning check-in.** **(3) SHIPPED FACES, one line each:** comments/callouts render in the whitespace GUTTER on every surface and the prose column's measure and left edge NEVER move for a decoration (the one law, pinned per surface; the 17p-b lane retired whole; margin cards reach the book/read surfaces for the first time); the comments panel is ONE writing surface (item 3's panel half — her 2026-08-21 ask); note lists lead with first words via ONE Domain brain (`NoteCardFace`), journal cards date-led, the title chip at capture (item 4); ⏎ files · ⇧⏎ paragraph on both Mac capture doors with the `importPost` bulk hand-off (item 9's face, R-13u-4 — the phone's lost-prose class impossible on the Mac by construction); ⌘S asks for a name with ⏎-to-skip instant, names lead the history rows, the rename door beside each savepoint (item 14); the restore confirm's two faces (item 15); the PDF export renders formatting through the app's own reading face, the `.md` export SHA-pinned byte-identical (item 16); the ceremony sheets' drift family closed to the 18f round-3 shapes (KnownIssues row 42 RESOLVED); the Takes board's live cards carry the take's acts and the tutorial teaches a door that exists (UNIT H, joined in-phase at a P-6 defect). **Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO lines. `Server/`: ZERO. The marker stays 8.** Finals: core **1604/174** · the FULL Mac suite **[FINAL-MAC]** · iOS build green · mobile **626/106 PASSED with 4 known issues**. A two-round `fable-reviewer` ladder with the full cross-model flow (R1: 0 BLOCKER · 1 MAJOR · 2 MINOR · 3 NIT — the MAJOR closed the pre-existing editor-spin PRECONDITION at its traced mechanism, a transaction-depth gate + deferral witness; the seal guard landed at all four doors on the implementer's own widen; four sanity items all taken; R2: 0/0/1/1, both fixed, no round 3 owed), nothing dismissed as hollow, every defect-shaped fix red-on-old. One process breach disclosed and systemically closed (a walk ⌘Q quit her running `/Applications` app; her store untouched, verified by mtime; quit-by-bundle-identity is now walker law). **(4) HANDED FORWARD:** 13u4 (the restyle continuation + her ELEVEN morning additions of 2026-09-19, two of them her own ruling changes — empty blocks must chain, superseding U-1's empty-block arm; merge keeps the newlines, superseding the 2026-07-06 join rule for merged runs — plus the accumulated owner rows); the mobile catch-up's parity rows (the panel face · the capture model, her lost-prose report its evidence · the chip · history names · the versions copy); her ratify bundle QUESTIONS **#117–#125** (#122(a) already ruled, R-13u3-7).

## 15. Risk register (why these are risks, so future sessions don't rediscover them)

Ordered by severity. Deferred *work* lives in `KnownIssuesAndTechDebt.md`; this section is standing *risks and their reasoning*.

1. **Live block-identity maintenance over `NSTextStorage` — the single riskiest thing in the project, and it is independent of the storage model.** The whole design rests on identity being maintained *during* editing (block IDs riding ranges as text attributes, edits reported as exact changed ranges) rather than recovered by diffing (OverallModel §8). Getting split/merge/attribute-drift edge cases right in a live editor is real engineering, historically underestimated. This is why the operations layer is proven headless first (Phases 2–3), why the editor gets its own phases (7, 9), and why boundary-snapping is a pure Domain function testable without AppKit. If an editor bug ever corrupts identity, the store is still safe — operations validate against the DB, not the text view.
2. **TextKit 2 viewport/height/scroll-to-location is the least reliable subsystem of the chosen editor stack** — simultaneously the reason TK2 was chosen (viewport lazy layout is P1's mechanism) and its weakest part; behavior is OS-version- and SDK-gated and regresses between releases. Full detail + defensive practices: `notes/TEXTKIT2_NOTES.md`. Mitigations: the Phase 6 throwaway spike on Tahoe *before* the editor is built; scrubber fallback = stored per-block length estimates, not live geometry; last-resort fallback = STTextView. **Corollary (re-baselined 2026-07-06 — dev is now the M3/Tahoe machine):** the version-gating risk didn't vanish with the Air, it moved to *point releases* — re-verify editor milestones after each macOS update, and never trust a pre-update result as the current baseline. **Resolution (2026-07-06, Phase 6 spike — memo accepted by the author):** on macOS 26.4.1 / Xcode 26.3 the spike measured zero silent fallbacks under the exercised inventory, flat typing to 200k words, convergent height estimates (content never regressed), and a pixel-exact ~7 ms hybrid jump flat in document size — **live TK2 geometry is adopted** per the accepted memo (`notes/plans/phase-06-tk2-spike.md`); the stored-estimate scrubber and STTextView stand down to documented, unbuilt fallbacks. What survives of this risk is exactly the corollary: point-release drift, guarded by re-running the spike (the §5 matrix's executable form) after every macOS update.
3. **Hand-rolled sync is a risk we chose with eyes open.** The default industry advice is "never roll your own sync." We overrode it because the engines fail this schema harder (SyncSpec §1: PowerSync's JSON views delete the DB-enforced invariants) and because this domain minimizes the danger by construction: one mutable field, insert/tombstone everything else, narrow mobile surface, dumb CAS server, deterministic client merges. The protection is the Phase 5 test harness (two in-memory clients vs in-process fake server, race suites) — treat any sync change that isn't covered by a convergence test as unreviewed. **Independent evidence (2026-07-07):** the author's Fragments app hand-rolled and long-hardened its own row sync; a one-time study of its scars both validated this design's core choices and transferred concrete fixes — the full comparison lives in `notes/sync-postmortem-fragments.md` (read it before changing anything in `Sources/VariorumCore/Sync/`).
4. **Formerly-open interpretations — both resolved by the author 2026-07-04:**
   - **Global undo → structural undo** (§9): session-scoped, in-memory, structural-ops-only; command-Z stays pure text undo. Chosen because the pointer religion makes structural inverses cheap (tombstone-flips + placeBlock) while full persistent/interleaved undo is the nightmare corner. The audit-log tech-debt item is superseded by this decision.
   - **"Sources to the side" → the reference panel** (§7 `reference`, §12): files + URLs beside the draft, native rendering only (Quick Look/PDFKit/WKWebView), EPUB and annotation/citation machinery permanently out of scope, file bookmarks local-only under sync.
5. **Deterministic-looking decisions that must not silently regress:** positions must remain jittered fractional-index strings (reverting to REAL midpoints reintroduces the offline-collision + mass-renumber sync bomb, SyncSpec §8); uniqueness must remain live-row partial indexes (bare UNIQUE + tombstones permanently pins re-creation, §6); outbox capture must remain trigger-fed (app-level capture silently misses cascade writes, SyncSpec §3); sync ordering authority must remain `server_seq`, never wall clocks (§SyncSpec 9).
6. **Toolchain skew — resolved 2026-07-06:** the M3 transition collapsed development onto one machine running Xcode 26 (Swift 6.2); `swift-tools-version` bumped to 6.2 and deployment targets to macOS 26 / iOS 26. Kept as a record: any future second machine (or CI) must match the primary's Xcode major version before its results count.

## 16. Still genuinely open (tracked, not blocking)

- ~~Export shape~~ — **resolved 2026-07-06 (forward-planning session):** granularity (posts/readings/blocks), the fan `.md` shape, and the two-tier sharing model are all designed — see §14's forward-planning delta and the Phase 11 brief. What remains open is Phase 13's typographic PDF only.
- **Audit/operation log** — optional derived artifact; revisit after the operations layer is real.
- **Visual/interaction design** — deliberately open until the substrate is proven, then iterative with the author.
