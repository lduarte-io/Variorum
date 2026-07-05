# Variorum — App Spec

**Status:** the single source of design truth for this project. Evolved from `notes/source/SPEC.md` (which it supersedes); deltas from that document are listed in §14 so nothing changed silently.
**Stack (settled):** SQLite (GRDB 7) as canonical local store, rows-as-truth · Swift · TextKit 2 `NSTextView` editor core · SwiftUI chrome (Observation + swift-dependencies, no TCA) · SPM core package + thin Xcode app target · macOS-first → iOS journal capture early → full iOS → (eventually) web. Sync is a **hand-rolled row-sync protocol over Supabase/Postgres, fully designed now** in `notes/SyncSpec.md` (authoritative for everything sync) and built at its phase — early, not commercial-phase, so the author can journal from her phone.
**How to read this:** the vision is `CoreDescription.md`; the mental model and invariants are `OverallModel.md` (this doc assumes you've internalized both). Sections 1–5 here are the concrete architecture; 6–12 are schema, operations, queries, views, sync; 13 is build order (detail lives in `DetailedPlanForPhases.md`); 14 records resolutions and deltas; 15 is the risk register (standing risks + their reasoning); 16 is what's still genuinely open.

---

## 1. Development context (machines, toolchain)

- **Dev machine:** Intel MacBook Air, macOS Sequoia 15.6 — cannot run Tahoe. Fast inner loop: logic, storage, operations, `swift test` from CLI.
- **Acceptance machine:** M3 Mac on Tahoe (26.x), connected to the same repo. Every editor milestone gets re-verified there (TextKit 2 behavior is version- and SDK-gated; see `notes/TEXTKIT2_NOTES.md`).
- **Toolchain:** Xcode 26 on both machines (universal binary; runs on Intel + Sequoia 15.6). Editor-phase builds **must** use the macOS 26 SDK — Tahoe behaviors like the `.layoutManager` TK2→TK1 downgrade are SDK-gated, so a 15.x-SDK build on Tahoe does not test what a shipping build does.
- **Deployment target: macOS 15 (Sequoia)** — the app must launch on the dev Air; Tahoe-only APIs are availability-gated.
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
  created_at         TEXT NOT NULL,
  updated_at         TEXT NOT NULL,
  archived_at        TEXT,            -- domain archive (kept, out of view)
  deleted_at         TEXT,            -- sync tombstone (S2)
  FOREIGN KEY (default_variant_id) REFERENCES variant(id) ON DELETE SET NULL,
  FOREIGN KEY (last_container_id)  REFERENCES container(id) ON DELETE SET NULL
);
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
> `derived_from (source, target)` reads "source is derived from target" (target = ancestor). `version_of` is undirected (store one row; treat symmetrically in queries). This one coarse table carries split/merge/extract/pool lineage **and** outline→draft mapping **and** "two versions of an article" links.

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
  churn_accumulator      REAL NOT NULL DEFAULT 0,
  baseline_length        INTEGER NOT NULL DEFAULT 0,
  created_at             TEXT NOT NULL,
  updated_at             TEXT NOT NULL,
  archived_at            TEXT,
  deleted_at             TEXT
);
CREATE INDEX idx_container_kind       ON container(kind);
CREATE INDEX idx_container_entry_date ON container(entry_date);
CREATE INDEX idx_container_major_rev  ON container(last_major_revision_at);
CREATE INDEX idx_container_touched    ON container(last_touched_at);
```
> Posts and pools share one table so one live-unique index on `container_block.block_id` enforces single ownership (I2) uniformly, and "scrap" and "finished prose" are one object type. Pool rows leave post-specific columns NULL.

### container_block — ordered pointers (ownership + chosen variant)
```sql
CREATE TABLE container_block (
  id                TEXT PRIMARY KEY,
  container_id      TEXT NOT NULL,
  block_id          TEXT NOT NULL,
  position          TEXT NOT NULL,             -- fractional-index key (§6)
  chosen_variant_id TEXT,             -- which variant renders here (I3); NULL ⇒ fall back to block.default_variant_id
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
  grouping_tag_id TEXT,                        -- section the book by a hierarchical tag root
  query_spec      TEXT,                        -- JSON predicate for smart readings
  max_posts       INTEGER,                     -- extent constraint (fixed-length journal)
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
  created_at  TEXT NOT NULL,
  deleted_at  TEXT,
  FOREIGN KEY (reading_id) REFERENCES reading(id),
  FOREIGN KEY (post_id)    REFERENCES container(id)
);
CREATE UNIQUE INDEX uq_reading_post_live ON reading_post(reading_id, post_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_reading_post_order ON reading_post(reading_id, position);
CREATE INDEX idx_reading_post_post  ON reading_post(post_id);
```
> Deliberate asymmetry with `container_block`: blocks are singly-owned; **posts are non-exclusively pointed at** by readings — this is what makes on-demand books work.

### tag — hierarchical, path-style
```sql
CREATE TABLE tag (
  id         TEXT PRIMARY KEY,
  owner_id   TEXT,
  parent_id  TEXT,
  name       TEXT NOT NULL,
  path       TEXT NOT NULL,                    -- materialized: 'life/goals/2024'
  created_at TEXT NOT NULL,
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

### setting — global/document key-values
```sql
CREATE TABLE setting (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- seeds: ('default_segmentation','paragraph'), ('major_revision_threshold','0.8')
```
> Default segmentation is a document/global setting decoupled from UI/mode; `container.segmentation_default` overrides per-post; `profile='journal'` seeds `one_block`.

### local-only sync machinery (never synced; SyncSpec §3)
```sql
CREATE TABLE sync_outbox (
  table_name TEXT NOT NULL,
  row_id     TEXT NOT NULL,
  queued_at  TEXT NOT NULL,
  PRIMARY KEY (table_name, row_id)              -- dirty-row SET: coalesces keystroke-rate autosaves
);
CREATE TABLE sync_state (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- keys: 'last_server_seq', 'device_id'
```

## 8. Cardinality summary
```
reading ──< reading_post >── container(kind=post)      many-to-many, non-owning (on-demand books)
container(post|pool) ──< container_block >── block     ONE live container per block (owning)
block ──< variant                                      one block, many variants (the fan)
variant ──< commit_point                               append-only savepoints
variant ──> variant (parent_variant_id)                history/branch tree
block ──< edge >── block                               derived_from (directed), version_of (undirected)
tag ──< post_tag >── container(kind=post)              many-to-many
tag ──< block_tag >── block                            many-to-many
tag ──> tag (parent_id)                                hierarchy
```

## 9. Operations as a transactional API (the hard core)

Every mutation is one of these; each is a single transaction through the operations layer — never ad-hoc row writes. Text-changing ops also update `container.last_touched_at` and churn (§10). Exact row-level state transitions (rows read/written, before/after) are specified per-operation in the schema/operations phase plans, with a test per transition.

- **newBlock(container, text, at)** — INSERT block; INSERT variant(working_text=text); set block.default_variant_id; INSERT container_block(chosen=variant, position at insertion point).
- **autosave(variant, text, charDelta)** — UPDATE working_text, updated_at; accumulate churn; threshold-cross ⇒ stamp major revision, reset, rebaseline (§10).
- **commit(variant, kind=manual, message?)** — INSERT commit_point(text=working_text). Counts as a major revision.
- **restoreCommit(variant, commit)** — UPDATE working_text = commit.text (old commits remain; I5).
- **branchVariant(block, fromVariant)** — INSERT variant(parent=fromVariant, working_text=**copied**, fan_position=next). *The default gesture.*
- **newBlankVariant(block)** — branch with working_text=''. *The "genuinely different take" gesture.*
- **extract(blockA, span)** — *source survives.* Span must be a boundary-adjacent prefix/suffix of A's active variant. INSERT block B + variant(text=span); UPDATE A's active variant = remainder (other variants untouched); INSERT container_block(B) adjacent; edge(B derived_from A, 'extract'). Zero ceremony. A middle span cannot extract — that's a divide.
- **divide(blockA, cut)** — *source consumed into ordered successors.*
  - **single-variant (everyday, in-place):** INSERT block C + variant(text=A[cut:]); UPDATE A's variant = A[:cut] (A keeps identity as first half — lossless, no fan to desync); INSERT container_block(C) after A; edge(C derived_from A, 'divide').
  - **multi-variant (rare; the only ceremony; W resolution):** A is **preserved whole** — its placement is released (container_block tombstoned), unmarked variants stay on A as lineage. For each marked variant Vi: INSERT first-half variant on new block B, second-half on new block C → B's fan = first-halves, C's fan = second-halves. INSERT placements B then C where A stood; edges (B derived_from A), (C derived_from A, 'divide'). Reversible by re-pointing at A.
- **merge(B, C)** — *mirrors W.* INSERT block A' + variant(text = chosen(B) + chosen(C)); replace both placements with A'; edges (A' derived_from B), (A' derived_from C, 'merge'). B, C released to lineage; fans are **not** cartesian-producted.
- **poolDragCopy(poolBlock P → post, at, includeFan=false)** — INSERT block B + variant(s): active text by default, the whole fan if `includeFan`; INSERT container_block(B) at drop; edge(B derived_from P, 'pool_copy'). P stays in its pool.
- **moveBlock(block → container, at)** — UPDATE container_block.container_id + position. Single ownership preserved by the live-unique index.
- **reorder(block, between A and B)** — UPDATE container_block.position = `FractionalIndex.between(A.position, B.position)` (jittered; §6). No rebalance operation exists — fractional-index strings have unlimited depth.
- **lockVariant / unlockVariant** — UPDATE variant.locked. Locked ⇒ to edit, branch or unlock.
- **lockPost / unlockPost** — auto-commit (kind='auto') dirty live buffers under the post, then UPDATE container.locked/locked_at. While locked: no edits, no new commits, pointer order + chosen variants frozen. Reversible.
- **archiveVariant / deleteVariant** — archive: status='archived' (out of fan, kept in history); delete: tombstone (must not be any slot's chosen variant — re-point first; RESTRICT backs this up). Either way, if it was the block's last live *active* variant → refuse (I10; caller should delete the block instead). If it was `default_variant_id` → reassign to the most recently updated active variant.
- **deleteBlock(block)** — tombstone block + its container_block row; set last_container_id (feeds the deleted-blocks tray). Trigger-cascade tombstones variants (and their commit_points) and edges. Soft by default; true purge is a rare, explicit GC.
- **applyTag / removeTag (post or block)** — INSERT into post_tag/block_tag or tombstone; operations layer enforces post_tag targets kind='post'.
- **resolveSyncConflict(variant, losingText)** *(sync phase, S5)* — INSERT variant(working_text=losingText, label='conflict') on the same block. The losing edit becomes a card in the fan; nothing clobbered.

**`default_variant_id` lifecycle (resolves source-SPEC open question #9):** set at `newBlock`; on delete/archive of the variant it names, reassign to the most recently updated active variant; never NULL while the block is live (guaranteed jointly by I10 + reassignment). It is the pointer-free representative (pool display, lineage views); `container_block.chosen_variant_id` always wins where a pointer exists.

## 10. The "80%-edited" sort (anti-typo-reshuffle)

Two stamps per post: `last_touched_at` (every keystroke) and `last_major_revision_at` (meaningful edits only). The editor reports a char-delta per edit; the app accumulates `churn_accumulator` (chars inserted + chars deleted, equal weight) against `baseline_length`. When `churn / max(baseline,1) ≥ threshold` (setting, default 0.8): stamp, reset accumulator, rebaseline. A manual commit also stamps. A reading's `sort_field` picks which stamp orders the book; journals sort by `entry_date`. Churn math is a pure Domain function with its own tests.

## 11. Sync architecture (designed NOW, built at its phase)

**Authoritative document: `notes/SyncSpec.md`.** Summary: hand-rolled state-based row sync over Supabase/Postgres — rich local SQLite kept intact (the PowerSync-class engines were rejected: their JSON-view client storage deletes the FKs/triggers/partial-unique indexes this schema's invariants ride on). Dumb server (compare-and-set + `server_seq` changefeed); all merge intelligence client-side: conflict-as-variant for `working_text` (S5), server-version-wins for metadata, deterministic apply-time repairs for every live-unique index, deferred-FK batch application, trigger-fed coalescing outbox with apply-mode echo suppression. Ordering authority is `server_seq`, never wall clocks. Sync arrives **early** (see DetailedPlanForPhases) so iOS journal capture works while the app is young; multi-tenant (owner_id + RLS) reuses the same protocol at the accounts phase.

## 12. Views and the UI stance

**The desire for many views is firm and central** — each view is a different traversal that stress-tests a different edge of the model (folder → tags/membership; book-scrub → ordering + post-as-page; timeline → timestamps; outline → derived_from). A view that's tortured to build reveals a weak spot in the model before everything is built on it.

The views (all over one store): continuous/book view (each note scrolls internally; not paginated), book-scrub (page = a post; 50 entries = 50 pages), infinite scroll, timeline, side-by-side (`text | v1 | v2 | text`; also two posts in columns), swap-and-reread, outline-left/draft-right (independent or tracked scroll; outline items map via `derived_from` to the blocks they became), diff (whitespace normalization optional), expand-all-fans (fans stay open once expanded; close-all-fans button), folder, canvas/sticky-notes, and the badge behavior (boundaries invisible at rest; on focus/hover a block reveals bounds; a corner badge appears **only** on blocks with a fan).

**The visual UI is deliberately an open concept.** In the technical phase: treat the view list as *capabilities the model must support*; build the simplest functional unstyled rendering of each; invest zero effort in polish/theming/layout systems. UI design happens later, iteratively, with the author. The one load-bearing UI-shaped thing now is the read-cheap/edit-focused split (P3) — it's a performance constraint, not an aesthetic.

## 13. Build order

The master plan with phases, status, and closeouts is **`DetailedPlanForPhases.md`** — that document governs. Summary shape: substrate (schema → operations → queries) → editor core (with the Tahoe viewport spike first) → structural ops in the editor → readings + first views → remaining views → hardening → UI design passes (with the author) → sync → accounts → iOS → web. Defer aggressively: outline connector polish, fancy scrubber visuals, whitespace-diff niceties, within-post virtualization, all visual design.

## 14. Resolutions & deltas from the source SPEC

Resolved (source SPEC §14 open questions), with the calls made:

1. **Single-variant divide: in-place** (A keeps identity as first half) — avoids orphan proliferation on the everyday split; the asymmetry with multi-variant W is deliberate and documented in §9. ✔ confirmed
2. **Unified `container`** (posts + pools): confirmed — one live-unique ownership index beats NULL-column aesthetics. ✔
3. **Tagging: two tables** (`post_tag`, `block_tag`) replacing polymorphic `tagging` — real FKs, no discriminator. **Deliberate schema delta.** ✔
4. **Cascades-as-triggers**: confirmed; the trigger set is enumerated and individually tested in the schema phase (block→variants/container_block/edges; variant→commit_points; container→container_blocks→blocks — a deleted post soft-deletes its singly-owned blocks).
5. **Sync engine decided now** (author's direction: sync is early, not commercial-phase): hand-rolled row sync over Supabase/Postgres, fully specified in `notes/SyncSpec.md`. PowerSync-class engines rejected after research — their JSON-view client storage forbids the FKs/triggers/partial-unique indexes the invariants ride on. This *reverses* the earlier "defer the engine choice" call, exactly as the source SPEC warned it should be decided pre-schema — and it did change the schema (see below).
6. **Pool-copy scope**: active variant by default; `includeFan` option on the operation from day one. ✔
7. **Churn metric**: characters; inserts + deletes equal weight; threshold tunable. ✔
8. **Headings**: a block whose text is a Markdown heading — no schema column. ✔
9. **`default_variant_id` lifecycle**: defined in §9. ✔
10. **Edge directionality**: `source = descendant, target = ancestor`; reads "source derived_from target". ✔
11. **Fractional positions**: resolved by the sync sweep — fractional-index `TEXT` keys with jitter; **no rebalance operation** (REAL midpoints + mass renumber were a sync bomb; SyncSpec §8). Supersedes the earlier REAL-with-rebalance answer. ✔

Additional deltas: live-row partial unique indexes everywhere (§6 — correctness fix); I10 added (§5); `chosen_variant_id` NULL-fallback semantics defined (§7); stack concretized (§1–2: Observation + swift-dependencies, SPM core + thin app, Xcode 26 both machines, deployment target macOS 15, Swift Testing).

**Sync-sweep deltas (2026-07-04, author-directed):** positions REAL→TEXT fractional keys, rebalance op removed; `sync_version` on every synced table; `sync_outbox` + `sync_state` local tables + outbox triggers in schema v1; UUIDv5 clause dropped (random v4 only); per-unique-index repair rules defined (SyncSpec §7); tombstone-vs-edit rescue rule (SyncSpec §6); pull cursors moved off `updated_at` onto `server_seq` (clock-skew-proof); sync phase moved early in the master plan.

## 15. Risk register (why these are risks, so future sessions don't rediscover them)

Ordered by severity. Deferred *work* lives in `KnownIssuesAndTechDebt.md`; this section is standing *risks and their reasoning*.

1. **Live block-identity maintenance over `NSTextStorage` — the single riskiest thing in the project, and it is independent of the storage model.** The whole design rests on identity being maintained *during* editing (block IDs riding ranges as text attributes, edits reported as exact changed ranges) rather than recovered by diffing (OverallModel §8). Getting split/merge/attribute-drift edge cases right in a live editor is real engineering, historically underestimated. This is why the operations layer is proven headless first (Phases 2–3), why the editor gets its own phases (7, 9), and why boundary-snapping is a pure Domain function testable without AppKit. If an editor bug ever corrupts identity, the store is still safe — operations validate against the DB, not the text view.
2. **TextKit 2 viewport/height/scroll-to-location is the least reliable subsystem of the chosen editor stack** — simultaneously the reason TK2 was chosen (viewport lazy layout is P1's mechanism) and its weakest part; behavior is OS-version- and SDK-gated and regresses between releases. Full detail + defensive practices: `notes/TEXTKIT2_NOTES.md`. Mitigations: the Phase 6 throwaway spike on Tahoe *before* the editor is built; scrubber fallback = stored per-block length estimates, not live geometry; last-resort fallback = STTextView. **Corollary: the Intel Air can never be the final word on editor correctness** — Sequoia-correct ≠ Tahoe-correct, and acceptance builds must use the 26 SDK (behaviors like the `.layoutManager` TK1 downgrade are SDK-gated).
3. **Hand-rolled sync is a risk we chose with eyes open.** The default industry advice is "never roll your own sync." We overrode it because the engines fail this schema harder (SyncSpec §1: PowerSync's JSON views delete the DB-enforced invariants) and because this domain minimizes the danger by construction: one mutable field, insert/tombstone everything else, narrow mobile surface, dumb CAS server, deterministic client merges. The protection is the Phase 5 test harness (two in-memory clients vs in-process fake server, race suites) — treat any sync change that isn't covered by a convergence test as unreviewed.
4. **Requirement interpretations to confirm with the author, not silently assume:**
   - **Global undo:** command-Z is per-buffer text undo; structural ops are reversible via W (re-point at A); there is **no cross-operation undo stack**. If the author expects app-wide undo, that's the audit-log item (KnownIssues, assessed at Phase 4 closeout).
   - **"Pull up sources and notes to the side" (blog use case):** served by pool + floating notes + side-by-side views; no dedicated "reference panel" is spec'd. Interpretation, flagged 2026-07-04.
5. **Deterministic-looking decisions that must not silently regress:** positions must remain jittered fractional-index strings (reverting to REAL midpoints reintroduces the offline-collision + mass-renumber sync bomb, SyncSpec §8); uniqueness must remain live-row partial indexes (bare UNIQUE + tombstones permanently pins re-creation, §6); outbox capture must remain trigger-fed (app-level capture silently misses cascade writes, SyncSpec §3); sync ordering authority must remain `server_seq`, never wall clocks (§SyncSpec 9).
6. **Toolchain skew:** dev Air on Xcode 16.4/Swift 6.1 until Xcode 26 is installed (universal binary, runs on Intel + Sequoia 15.6 — verified 2026-07-04); keep `swift-tools-version: 6.1` and 6.1-compatible code until both machines run Xcode 26, then revisit.

## 16. Still genuinely open (tracked, not blocking)

- **TK2 viewport viability on Tahoe** — the editor-phase spike decides live-geometry vs stored-estimate scrubber (vs STTextView).
- **Markdown export shape** — planned so the store is never a black box; design when the read layer exists.
- **Audit/operation log** — optional derived artifact; revisit after the operations layer is real.
- **Visual/interaction design** — deliberately open until the substrate is proven, then iterative with the author.
