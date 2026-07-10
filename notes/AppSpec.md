# Variorum — App Spec

**Status:** the single source of design truth for this project. Evolved from `notes/source/SPEC.md` (which it supersedes); deltas from that document are listed in §14 so nothing changed silently.
**Stack (settled):** SQLite (GRDB 7) as canonical local store, rows-as-truth · Swift · TextKit 2 `NSTextView` editor core · SwiftUI chrome (Observation + swift-dependencies, no TCA) · SPM core package + thin Xcode app target · macOS-first → iOS journal capture early → full iOS → (eventually) web. Sync is a **hand-rolled row-sync protocol over Supabase/Postgres, fully designed now** in `notes/SyncSpec.md` (authoritative for everything sync) and built at its phase — early, not commercial-phase, so the author can journal from her phone.
**How to read this:** the vision is `CoreDescription.md`; the mental model and invariants are `OverallModel.md` (this doc assumes you've internalized both). Sections 1–5 here are the concrete architecture; 6–12 are schema, operations, queries, views, sync; 13 is build order (detail lives in `DetailedPlanForPhases.md`); 14 records resolutions and deltas; 15 is the risk register (standing risks + their reasoning); 16 is what's still genuinely open.

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
-- seeds: ('default_segmentation','paragraph'), ('major_revision_threshold','0.8'), ('idle_commit_hours','24')
```
> Default segmentation is a document/global setting decoupled from UI/mode; `container.segmentation_default` overrides per-post; `profile='journal'` seeds `one_block`. Settings are **synced** (they're document semantics — segmentation must match on iOS capture): they carry `sync_version` per §6, are upsert-only, and never tombstone.
>
> **Segmentation trigger (author decision 2026-07-04, review item #11):** fresh-text segmentation is **type-time crystallization** — while typing brand-new text at the end of a post, each completed paragraph silently becomes a block as you type past it; the trailing paragraph still being typed is an *open tail*, not yet a block. Bulk entry (paste, import, pool-drop, mobile capture) segments on entry. Once a block exists, Enter inside it is pure content forever — I4 is never violated because crystallization only ever applies to text that has not yet become a block. The boundary-detection logic is a pure Domain function (Phase 2).

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

Every mutation is one of these; each is a single transaction through the operations layer — never ad-hoc row writes. Text-changing ops also update `container.last_touched_at` and churn (§10). **All structural ops touch:** divide-W, merge, and poolDragCopy stamp `last_touched_at` too (restructuring is working on the post — author decision 2026-07-06) but never churn — restructuring must not reshuffle the meaningful sort. Exact row-level state transitions (rows read/written, before/after) are specified per-operation in the schema/operations phase plans, with a test per transition.

- **newBlock(container, text, at)** — INSERT block; INSERT variant(working_text=text); set block.default_variant_id; INSERT container_block(chosen=variant, position at insertion point).
- **autosave(variant, text, charDelta)** — UPDATE working_text, updated_at; accumulate churn; threshold-cross ⇒ stamp major revision, reset, rebaseline (§10).
- **commit(variant, kind=manual, message?)** — INSERT commit_point(text=working_text). Counts as a major revision.
- **idleAutoCommit(post)** *(author-approved 2026-07-04)* — when a post with uncommitted buffer changes goes untouched for `idle_commit_hours` (setting, default 24): one commit_point per dirty variant, kind='auto', at most one per idle period, only if the text changed since that variant's last commit. Visually quiet, prunable. Insurance for "I rewrote it over weeks and never committed."
- **restoreCommit(variant, commit)** — UPDATE working_text = commit.text (old commits remain; I5). **Known behavior (review #9):** a commit may predate a structural op — after a single-variant divide or extract, A's old commits still hold the full pre-split text, so restoring one resurrects both halves into A's buffer while the successor block still sits next door. Coherent under "coarse, not forensic"; the editor should warn ("this commit predates a split of this block") — documented Phase 3 test, UI warning at the editor phase.
- **branchVariant(block, fromVariant)** — INSERT variant(parent=fromVariant, working_text=**copied**, fan_position=next). *The default gesture.*
- **newBlankVariant(block)** — branch with working_text=''. *The "genuinely different take" gesture.*
- **extract(blockA, span)** — *source survives.* Span must be a boundary-adjacent prefix/suffix of A's active variant. INSERT block B + variant(text=span); UPDATE A's active variant = remainder (other variants untouched); INSERT container_block(B) adjacent; edge(B derived_from A, 'extract'). Zero ceremony. A middle span cannot extract — that's a divide. **Known behavior (review #10):** extracting from a *fanned* block edits only the chosen variant — the other variants keep their own versions of that span, so switching the slot's chosen variant later shows the extracted content twice. Accepted (the model-level "fix" would be per-variant marking, i.e. turning extract into divide); the editor may hint when extracting from a fanned block.
- **divide(blockA, cut)** — *source consumed into ordered successors.*
  - **single-variant (everyday, in-place):** INSERT block C + variant(text=A[cut:]); UPDATE A's variant = A[:cut] (A keeps identity as first half — lossless, no fan to desync); INSERT container_block(C) after A; edge(C derived_from A, 'divide').
  - **multi-variant (rare; the only ceremony; W resolution):** A is **preserved whole** — its placement is released (container_block tombstoned), unmarked variants stay on A as lineage. For each marked variant Vi: INSERT first-half variant on new block B, second-half on new block C → B's fan = first-halves, C's fan = second-halves. INSERT placements B then C where A stood; edges (B derived_from A), (C derived_from A, 'divide'). Reversible by re-pointing at A.
- **merge(B, C)** — *mirrors W.* INSERT block A' + variant(text = chosen(B) + `" "` + chosen(C) — **a single space at the join** unless either side's edge already carries whitespace; author decision 2026-07-06, a raw no-space join was more annoying than helpful. Consequence: divide-then-merge restores a sentence cut exactly, while a paragraph cut comes back as a space — the author adjusts in the editor); replace both placements with A'; edges (A' derived_from B), (A' derived_from C, 'merge'). B, C released to lineage (stamping `last_container_id`, so a released block deleted later still trays); fans are **not** cartesian-producted.
- **poolDragCopy(poolBlock P → post, at, includeFan=false)** — INSERT block B + variant(s): the rendered variant's text by default, the whole *live* fan if `includeFan` (**archived takes ride along with statuses preserved** — author-ratified 2026-07-06; commits are never copied, copies are not born locked, the parent tree is remapped inside the copy); INSERT container_block(B) at drop; edge(B derived_from P, 'pool_copy'). P stays in its pool. Pool→draft is the only copy direction.
- **moveBlock(block → container, at)** — UPDATE container_block.container_id + position. Single ownership preserved by the live-unique index.
- **placeBlock(block, container, at)** *(review #7 — the op W-reversibility depends on)* — INSERT container_block for a live block with **no live placement** (a released-to-lineage block after divide-W/merge, or a tray restoree). This is the primitive that makes "reversible by re-pointing at A" a real operation instead of a promise, and it's what structural undo emits.
- **restoreBlock(block)** — undo a deleteBlock from the tray: clear the block's tombstone and those of children whose `deleted_at` equals the block's (cascade-stamped with the same value, so cascade-victims are identifiable and independently-deleted rows stay dead); then placeBlock into `last_container_id`. A stamp-matched tag application only revives if its tag is still live.
- **restoreContainer(container)** *(author decision 2026-07-05: deleted posts must be recoverable)* — undo a deleteContainer: clear the container's tombstone and every cascade victim carrying its exact stamp — placements, their singly-owned blocks and those blocks' children, reading memberships, post tags, references. Rows whose story diverged in the meantime are left alone: independently-deleted rows keep their different stamps; memberships/applications whose reading or tag has since died stay dead; a block independently revived keeps its current placement (I2) and one re-deleted under a newer stamp stays dead.
- **renameTag(tag, newName)** *(review D1)* — rewrite `name` + the materialized `path` of the tag and its entire subtree in one transaction. Bounded by subtree size (fine locally); under sync it's plain metadata CAS per row — converges, worst case a lost rename, never corruption.
- **reorder(block, between A and B)** — UPDATE container_block.position = `FractionalIndex.between(A.position, B.position)` (jittered; §6). No rebalance operation exists — fractional-index strings have unlimited depth.
- **lockVariant / unlockVariant** — UPDATE variant.locked. Locked ⇒ to edit, branch or unlock. Locking a dirty buffer first appends one quiet auto commit (kind='auto') — the guard insures exactly what it protects, so unlock-then-edit can never destroy it (author decision 2026-07-05; mirrors lockPost's consequence-not-equivalence). Commit of a locked variant stays refused; lock toggles under a sealed post are refused like everything else under the seal.
- **lockPost / unlockPost** — auto-commit (kind='auto') dirty live buffers under the post, then UPDATE container.locked/locked_at. While locked: no edits, no new commits, pointer order + chosen variants frozen (the seal refuses *everything under* the post — author-ratified 2026-07-05). The seal is content-level: the post itself may still be archived, deleted (recoverable via restoreContainer), retitled, tagged, and added to readings without unsealing. Reversible.
- **archiveVariant / deleteVariant** — archive: status='archived' (out of fan, kept in history); delete: tombstone (must not be any slot's chosen variant — re-point first). **Precision (review #3): the operations-layer check is the *only* live enforcement** — under soft-delete-everywhere, tombstones are UPDATEs, so the FK RESTRICT never fires; RESTRICT guards only the physical-purge/GC path. Tests target the ops layer. Either way, if it was the block's last live *active* variant → refuse (I10; caller should delete the block instead — and note the sync-race variant of this, repaired per SyncSpec §7). If it was `default_variant_id` → reassign to the most recently updated active variant.
- **deleteBlock(block)** — tombstone block + its container_block row; set last_container_id (feeds the deleted-blocks tray). Trigger-cascade tombstones variants (and their commit_points) and edges. Soft by default; true purge is a rare, explicit GC.
- **applyTag / removeTag (post or block)** — INSERT into post_tag/block_tag or tombstone; operations layer enforces post_tag targets kind='post'.
- **addReference / removeReference / updateReferenceViewState (post)** — INSERT/tombstone/UPDATE `reference` rows (§7).
- **resolveSyncConflict(variant, losingText)** *(sync phase, S5)* — INSERT variant(working_text=losingText, label='conflict') on the same block (same parent, fan's end). The losing edit becomes a card in the fan; nothing clobbered. **Lands even under a sealed post** (author-ratified 2026-07-06: S5 outranks the seal — the seal freezes *authoring*, and a sync conflict is not authoring). Refuses a dead block; the engine's in-apply rescue path skips one silently instead.

**Structural undo (author-approved 2026-07-04; resolves the global-undo question):** a **session-scoped, in-memory undo stack for structural operations only** — divide, merge, extract, deleteBlock, deleteVariant, archiveVariant, moveBlock, reorder, poolDragCopy. Each of these registers its inverse when it runs (mostly tombstone-flips + placeBlock — cheap precisely because the model destroys nothing). **Undo emits ordinary operations**, so sync never knows undo exists and the merge rules already cover it. Explicitly excluded: text editing (command-Z remains NSTextView's ordinary per-buffer undo, never interleaved with structural undo), commits (append-only; restore *is* the feature), locks and tags (trivially re-toggled). No persistence across sessions — the deliberate cheap/nightmare line. Inverses are specified per-op in Phases 2–3 (they double as the reversibility tests); UI wiring at the editor phases.

**`default_variant_id` lifecycle (resolves source-SPEC open question #9):** set at `newBlock`; on delete/archive of the variant it names, reassign to the most recently updated active variant; never NULL while the block is live (guaranteed jointly by I10 + reassignment). It is the pointer-free representative (pool display, lineage views); `container_block.chosen_variant_id` always wins where a pointer exists.

## 10. The "80%-edited" sort (anti-typo-reshuffle)

Two stamps per post: `last_touched_at` (every keystroke) and `last_major_revision_at` (meaningful edits only). The editor reports a char-delta per edit; the app accumulates `churn_accumulator` (chars inserted + chars deleted, equal weight) against `baseline_length`. When `churn / max(baseline,1) ≥ threshold` (setting, default 0.8): stamp, reset accumulator, rebaseline. A manual commit also stamps. A reading's `sort_field` picks which stamp orders the book; journals sort by `entry_date`. Churn math is a pure Domain function with its own tests.

## 11. Sync architecture (designed NOW, built at its phase)

**Authoritative document: `notes/SyncSpec.md`.** Summary: hand-rolled state-based row sync over Supabase/Postgres — rich local SQLite kept intact (the PowerSync-class engines were rejected: their JSON-view client storage deletes the FKs/triggers/partial-unique indexes this schema's invariants ride on). Dumb server (compare-and-set + `server_seq` changefeed); all merge intelligence client-side: conflict-as-variant for `working_text` (S5), server-version-wins for metadata, deterministic apply-time repairs for every live-unique index, deferred-FK batch application, trigger-fed coalescing outbox with apply-mode echo suppression. Ordering authority is `server_seq`, never wall clocks. Sync arrives **early** (see DetailedPlanForPhases) so iOS journal capture works while the app is young; multi-tenant (owner_id + RLS) reuses the same protocol at the accounts phase.

## 12. Views and the UI stance

**The desire for many views is firm and central** — each view is a different traversal that stress-tests a different edge of the model (folder → tags/membership; book-scrub → ordering + post-as-page; timeline → timestamps; outline → derived_from). A view that's tortured to build reveals a weak spot in the model before everything is built on it.

The views (all over one store): continuous/book view (each note scrolls internally; not paginated), book-scrub (page = a post; 50 entries = 50 pages), infinite scroll, timeline, side-by-side (`text | v1 | v2 | text`; also two posts in columns), swap-and-reread, outline-left/draft-right (independent or tracked scroll; outline items map via `derived_from` to the blocks they became), diff (whitespace normalization optional), expand-all-fans (fans stay open once expanded; close-all-fans button), folder, canvas/sticky-notes, the **reference panel** (per-post sources beside the draft: Quick Look / PDFKit with drag-selection-into-draft, read-only WKWebView for URLs — §7 `reference`), and the badge behavior (boundaries invisible at rest; on focus/hover a block reveals bounds; a corner badge appears **only** on blocks with a fan). A low-priority **unplaced-blocks utility view** (live blocks with no placement — divide-W/merge lineage leftovers) is a cheap query worth having as a safety net; owned by the remaining-views phase. The **collapsible block-TOC view** (author-adopted 2026-07-07): one row per block — the block's explicit name where set, else its first sentence **derived at read time** (never stored); a row expands into the ordinary read-cheap tier, and exactly one expanded block upgrades to the live editor (P3's split, reused); collapse state is session UI state, and collapsing lives in the view — **never as in-place text folding inside the live TK2 editor** (TEXTKIT2_NOTES §3). Owned by the remaining-views phase; §14's 2026-07-07 delta records the decision and the `block.name` column that rides with it.

**The visual UI is deliberately an open concept.** In the technical phase: treat the view list as *capabilities the model must support*; build the simplest functional unstyled rendering of each; invest zero effort in polish/theming/layout systems. UI design happens later, iteratively, with the author. The one load-bearing UI-shaped thing now is the read-cheap/edit-focused split (P3) — it's a performance constraint, not an aesthetic.

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

**Sync-sweep deltas (2026-07-04, author-directed):** positions REAL→TEXT fractional keys, rebalance op removed; `sync_version` on every synced table; `sync_outbox` + `sync_state` local tables + outbox triggers in schema v1; UUIDv5 clause dropped (random v4 only); per-unique-index repair rules defined (SyncSpec §7); tombstone-vs-edit rescue rule (SyncSpec §6); pull cursors moved off `updated_at` onto `server_seq` (clock-skew-proof); sync phase moved early in the master plan.

**Review-session deltas (2026-07-04 — independent Phase 0 review; all findings accepted):** I10 double-tombstone repair = deterministic resurrection (SyncSpec §7); dangling `chosen_variant_id` handled read-time (fallback) + apply-time (NULL repair); repairs enqueue outbox rows explicitly past echo suppression; server mirror carries no unique constraints/FKs (stated, load-bearing); concurrent same-block structural ops documented as converging-with-duplication; `placeBlock` + `restoreBlock` ops added (W-reversibility now has its operation); `version_of` stored canonically (min,max); RESTRICT precisely scoped to the GC path (ops-layer check is the live enforcement); restoreCommit-predates-split and fanned-extract behaviors documented with owned tests; **segmentation trigger defined: type-time crystallization (author decision)**; `renameTag` op + `tag.updated_at` added, `path` marked as the one deliberate denormalization; settings are synced, upsert-only; **idle auto-commit approved (author decision)** with `idle_commit_hours` setting.

**Author-decision deltas (2026-07-04):** structural undo — session-scoped, in-memory, structural-ops-only, inverses specified per-op in Phases 2–3 (§9); `reference` table + reference panel (Quick Look/PDFKit/WKWebView; drag-selection-into-draft; EPUB and annotation/citation permanently out of scope; `file_bookmark` local-only under sync).

**Author-decision deltas (2026-07-06, Phase 3 closeout review):** all structural ops stamp `last_touched_at` (never churn — no reshuffle); merge joins with a single space (unless an edge already carries whitespace) — supersedes the phase's raw-concatenation reading of "chosen(B) + chosen(C)"; structural-undo divergence insurance ratified — undoing extract/divide auto-commits a buffer edited since the op before restoring the pre-image (**the fourth quiet auto-commit occasion**), and undoing a mint the author worked on since stamps `last_container_id` so it lands in the tray instead of vanishing; `includeFan` pool copies carry archived takes with statuses preserved; structural ops are legal in pools; UTF-16 confirmed as the structural API's offset unit (grapheme-validated); boundary snapping confirmed as the *editor's* contract — operations check well-formedness only; divide/divide-W seam trimming and extract's prefix-before/suffix-after placement presented and explained (recorded in the Phase 3 plan's closeout).

**Author-decision deltas (2026-07-05, Phase 2 closeout review):** the post seal refuses *everything* under the post (including fan growth and variant-lock toggles); `lockVariant` auto-commits a dirty buffer before freezing (the third quiet auto-commit occasion, joining post-seal and long-idle) while commit of a locked variant stays refused; `restoreBlock` into a since-locked container throws rather than silently leaving the block unplaced; archiving a chosen variant confirmed allowed (read-time fallback + default reassignment cover it).

**Author-decision deltas (2026-07-06, Phase 4 closeout review — the read layer's ratifications):** the whole-document projection (`Queries.renderedText`, feeding export/diff) joins blocks with **`"\n\n"`** (the rendering join re-creates stored-nothing separators), and **blank takes skip like gaps** — a chosen-but-empty variant contributes nothing to the projection while still rendering as an empty slot in the editor; **schema:** `idx_block_last_container` ratified into §7's block DDL (the tray's access path), and the three container stamp indexes upgraded to **composite live-row form** `(column, id) WHERE deleted_at IS NULL` (migration `v1_2` — the keyset sort key matched exactly; author: "why would we not do this now? we don't have sync yet"), §7 DDL updated; **smart readings:** the v1 `query_spec` vocabulary ratified as shipped — `{tags, profile, entryDateFrom, entryDateTo}`, AND across fields, ANY-of tags with subtree semantics, NULL spec = all posts, malformed = assembles empty, unknown keys ignored — and `sort_field='manual'` on a smart reading falls back to `created_at ASC`; **grouping** ratified: a post's section is the *immediate child* of the grouping tag root whose subtree contains a tag applied to the post (lexically-smallest tiebreak; root-only tags ungrouped; clustering is the view's presentation call); **timelines** ratified strict-stamp (a timeline keyed on a stamp lists only rows carrying it) with the `library` listing as the total surface, COALESCE-ing missing stamps to `created_at`; **archived containers** ratified out of *ambient* view (reading assembly, timelines, library) while direct address still renders and tag lookups still find them, with `Queries.archivedPosts` as the recovery surface behind `unarchiveContainer`.

**Author-decision deltas (2026-07-06, Phase 5 closeout review — the sync engine's ratifications):** conflict/rescue variants **land under sealed posts** (S5's "nothing is ever clobbered" outranks the seal — the seal freezes authoring, and a sync conflict is not authoring; §9 `resolveSyncConflict` updated); the **archive/archive race** repairs by un-archiving the highest-`server_seq` archived variant, status active, label `'rescued'` (the I10 resurrection doctrine extended to archives — SyncSpec §7); the local-only **`sync_row_seq`** table joins the client machinery (migration `v1_3`, own commit — SyncSpec §3, §7 DDL above; **rows the server never accepted rank as seq 0**); the **orphan repair** joins SyncSpec §7 (cascades cannot cross devices: parent-tombstone application explicitly enqueues its stamp-matched cascade victims, and a live child arriving under a locally-dead parent joins the cascade with the parent's exact stamp so `restoreContainer`/`restoreBlock` still revive it); the **tombstone rescue is symmetric** (either side's `working_text` edit racing a tombstone on a still-live block is rescued as a conflict variant — SyncSpec §6); and a **merged row equal to the server row clears its outbox entry** (SyncSpec §5 amended — no no-op pushes, no gratuitous echoes).

**Author-decision deltas (2026-07-06, Phase 6 closeout review — the TK2 gate):** the Phase 6 decision memo **accepted as written** (§15 risk 2 records the resolution; the spike's numbers live in `notes/plans/phase-06-tk2-spike.md`): live TK2 geometry for the continuous editor and long-post scrolling; the **bounded hybrid jump** (proportional estimate → single-fragment `ensuresLayout` → scroll correction) as the one scroll-to-location primitive — `relocateViewport(to:)` is banned (measured broken: moves the viewport, never the scroll view), `scrollRangeToVisible` reserved for caret reveal; **book-scrub is model-driven** (the post list is the scrubber's domain; stored per-block length estimates remain §4's documented, unbuilt fallback door); **no STTextView** (kept bookmarked as last resort — MIT-licensed, so commercially usable if a point release ever forces it); canary posture **assert-in-debug / os_log-fault-plus-visible-alert-in-release**; the spike re-runs after every macOS point update (TEXTKIT2_NOTES §5's executable form). At the same walk she confirmed the editor-v1 interpretations Phase 7 had flagged: **one live NSTextView per focused post** (the per-block read-only tier becomes load-bearing at Phase 10's multi-post views), **a single `"\n"` as the editor-surface block separator** (a render-time artifact — distinct from Phase 4's `"\n\n"` ratification, which covers the `renderedText` projection only), and **cross-block destructive edits refuse/clamp in editor v1** (structural gestures arrive Phase 9).

**Author-decision deltas (2026-07-06, Phase 7 review round — mid-phase rulings):** the open tail gains an **idle-mint** (refines §7's segmentation note — the "trailing paragraph still being typed is an open tail, not yet a block" wording gains an early-persistence-for-durability clause): a short quiet gap in typing (autosave-scale, 2 s) crystallizes the open tail *including the trailing partial paragraph*, bounding crash loss to seconds like every other edit; editor teardown (post switch, window close, quit) remains the backstop. Resumed typing extends the idle-minted block, so the final block structure is identical to typing past. At the same ruling: **live-typing crystallization granularity is paragraph in every segmentation mode** (closing the sentence-mode question open since Phase 2) — sentence granularity comes from bulk entry (`bulkSegments(.sentence)` on paste) and from extract; revisit only if Phase 9's gestures change the friction cost. At the same day's checkpoint she ratified two more Phase 7 readings: **Enter at the exact document end is the gesture that opens the tail** (typed single newline only; the accepted consequence: multi-paragraph blocks aren't *typed* at the post end in paragraph mode — paste-into-block, one-block posts, and merge still produce them), and **surface-only for a sealed post's open tail at quit** (the seal refuses the mint, the refusal is shown, no rescue path is invented — seconds-wide-rare by construction under idle-mint). Drag-drop-into-tail stays PROVISIONAL-typing, deferred to Phase 9 (`notes/QUESTIONS.md`).

**Author-decision deltas (2026-07-06, forward-planning session — Phases 9–12 pre-decided with the coordinator under the Fable token constraint; the process side lives in CLAUDE.md's model-policy + front-loaded-planning amendments; the pre-written Phase 9 plan and the 10–12 briefs in `notes/plans/` embed these):** **Editor gestures (Phase 9):** extract and divide are **two named commands with three doors** (menu bar, context menu, shortcut; enablement = the gesture planner's verdict — no smart unified "Split"); snapping is **snap-and-proceed, visibly** (one invoke, never silent, never a confirm step); the **W ceremony is one modal sheet** (fan checklist, per-marked-variant click-to-place cuts pre-seeded by string-context matching, live editor untouched throughout); **merge is explicit and binary** (caret at seam or exactly-two-block selection; more refuses); a **composed "Make Block from Selection"** runs two divides as one undoable action on single-variant blocks only (fanned → refusal pointing at the W); **cross-boundary re-bracketing refuses in v1** (ratifying the KnownIssues line; workaround named in the refusal copy); **drag-drop into the open tail is bulk entry** — segments on entry and closes the tail, like paste (supersedes the PROVISIONAL-typing reading; resolves the deferred QUESTIONS item), while a drop into a block is a content edit (I4); **fanned extract gets a passive non-blocking hint** (§9's "may hint", resolved). **Views (Phases 10–11):** the read-cheap tier allows **select + copy** (per post) with click-to-focus upgrading exactly one post to the live editor; a **minimal pool moves into Phase 10** (listing + drag-into-draft; fuller pool stays at 11); **`version_of` gets two doors** (select-two-posts → "Mark as Versions" in the library; the side-by-side view offers the link on unlinked posts); the **canvas view persists layout in a small synced `canvas_layout` table** designed at Phase 11 with its own schema commit (live-unique per (container, block); metadata-CAS positions; the first exercise of SyncSpec §12). **Export (resolves §16's "export shape"):** posts, readings, **and single blocks** export as `.md`; **fan export = one file with labeled "Alternates" sections** (chosen take in place); **two-tier sharing ratified** — `.md`/basic PDF at Phase 11 for humans without the app, the full-fidelity "variorum edition" bundle stays at Phase 14, the SQLite file remains the lossless archive, sync remains the author's own device transfer; exports are one-way projections on `renderedText` semantics (`"\n\n"` joins, blank takes skip). **Operational:** plaintext rows in the author's own Supabase re-confirmed acceptable until Phase 14's E2EE decision; **store backup = app-level rotating cold copies** landing Phase 8 (Supabase is a mirror, not a backup); **transport fault-injection and engine re-entrancy tests** join Phase 8; the **migration-lockstep rule** joins SyncSpec as §12 (mirror first, then every client, before any new-schema writes; disagreement = refusal to sync).

**Author-decision deltas (2026-07-07, forward-planning round 2 — journal identity, the Fragments bridge, export freedom):** the journal's **`entry_date` is user-set** — it defaults to the local calendar date at creation and the author may point it at any date, **past** (backfilling a journal is legitimate) **or future** (allowed; she's conflicted but found no precise reason to refuse) — while `created_at` always preserves when the entry was actually written and is never user-editable. **The dedicated journal is one entry per calendar day** (the notebook rule — flip through days like pages), enforced as **create-or-open** at the operations/UI level ("new entry" on a date that already has a live entry opens it), deliberately NOT as a DB unique index — no new sync-repair class; the offline same-day double-create converges to two *visible* entries on that day's page, hand-merged, with the Fragments bridge pausing that day's push until resolved. **The Fragments journal bridge is decided: two-way, now** (supersedes the QUESTIONS deferral — the author wants to journal in Fragments as well as in Variorum's own iOS capture): the doctrine is **Variorum is the journal's home and truth**; Fragments' `journal_entries` satellite is a co-writer *projection surface* — the bridge pushes `renderedText` per `entry_date` and lands Fragments-side writing through ordinary operations, so S5's conflict-as-variant guards the Variorum side and nothing typed in either app can be lost where truth lives; the user-set calendar date is exactly what makes the join trivial (both apps agree the user's stated day IS the key); and a bridge landing about to overwrite journal text edited since its last commit **auto-commits first** — **the fifth quiet auto-commit occasion** (author, 2026-07-07: Fragments has no history surface, so an edit or deletion made there must stay one restore away in Variorum's commit view; the idleAutoCommit change-guard bounds it — OverallModel §3 updated). Master plan row **9b** (slotted after Phase 9 the same day — she won't heavily use the app until 9–11 land, and the Fable budget goes to 9 first); brief `notes/plans/phase-09b-fragments-bridge-brief.md`; Fragments-side asks in `notes/fragments-bridge-contract.md` — **this repo's coordinator and agents never work in the Fragments repo** (author process rule, 2026-07-07). **Export freedom ratified as a product principle:** users are never locked in — *their work is always theirs to download*; concretely, Phase 11 adds **bulk export** (the whole library as a folder of plain `.md` in one gesture) beside the per-post/reading/block exports, with the SQLite file and the Phase 14 variorum-edition bundle as the lossless tiers. Also noted: the **week-one dump-compare ritual** (a manual comparison of both stores after the first week of real two-device journaling; Phase 12's soak formalizes it), and the **sync round-3 hardening** from the Fragments post-mortem (SyncSpec §5 visibility-skew note; Phase 8 amendments A5/A6 and the sharpened A2).

**Author-decision deltas (2026-07-07, Phase 8 checkpoint — the capture surface's ratifications):** the **capture editing control is SwiftUI `TextEditor`** (one live editor for the focused block, read-cheap tap-to-focus siblings; §4's TK2 mandate confirmed as targeting the *Mac editor core*, not the phone's capture field — Phase 15 revisits the control when block identity must live on the phone); **daily-drive is Release builds on both devices** — the A4 dev-store fence stands as shipped (debug builds open `Variorum-dev/` and **never sync**; the real store from a debug build only via the explicit Xcode-launch opt-in; the "iOS defaults to the real store" alternative declined); **`newBlock` stamps `last_touched_at` and feeds churn** (minting text is working on the post — §10's text-changing-op rule applies a fortiori after the 2026-07-06 structural-stamp ruling; implementation owned by Phase 9, where crystallization mints live; the two documented idle-sweep residual gaps close with it); and **re-dating an entry onto an occupied day stays silently allowed** (the day's page shows both entries, hand-merged — the same doctrine as the offline double-create; a UI hint is Phase 13's if wanted).

**Author-decision delta (2026-07-07, mid-Phase-9 planning walk with the coordinator — block names + the collapsible block-TOC):** posts gain a **block-level table of contents**: a **collapsible block-TOC view** (one row per block; expand-to-read, one live editor on demand — §12's view list updated) and an **optional per-block name** — a new nullable **`block.name`** column (additive; plain metadata under sync — CAS, no uniqueness, no repair rule; a small `setBlockName` operation). An unnamed block's TOC row shows its **first sentence derived at read time** via the existing `BoundarySnapping` sentence rules — never stored, never copied (the no-denormalization rule holds); names are **block-identity-level** (I2's single owner makes that unambiguous) and are a *handle on a prose block*, deliberately distinct from §14.8's headings-live-in-text rule. Collapse state is session-only in v1 (nothing persisted); in-place text folding inside the live editor is **ruled out** (TK2's least reliable subsystem — the TOC is a pane/view). **Owned by Phase 11**: the view joins 11's set, and `block.name` lands as its own schema commit deployed in the **same migration-lockstep event** as `canvas_layout` (SyncSpec §12 — one choreography, two additive changes). Design detail is the Phase 11 plan's, per the brief. Rationale worth keeping: the collapse-all TOC is the natural UX face of §4's within-post virtualization escape hatch — a 100k-word post viewed as a TOC costs ∝ block count, and editing one expanded block costs ∝ that block.

**Author-decision delta (2026-07-07, mid-Phase-9 — the auth re-sequencing):** Phase 14's **auth core is pulled forward as Phase 9c** (immediately after the Fragments bridge): Supabase Auth on the Variorum project, `owner_id` population + stamping through Operations, RLS + RPC rework on the mirror (SyncSpec §12 lockstep), transport token refresh, and the **retirement of Phase 8's Keychain paste-in into a real sign-in** (the same-day QUESTIONS #3 ratification is superseded — the paste-in is now interim scaffolding; the iCloud-Keychain-sync tweak declined: no in-between mechanisms). The underlying fact driving it: Variorum's deliberately auth-less mirror makes *any* key a full bearer token to the corpus, so the two apps can only converge by Variorum gaining auth — a mechanism swap cannot do it. **Identity goal ratified: ONE account — the author's Fragments account IS her Variorum account** (two accounts explicitly rejected; the trust mechanism — issuer trust vs shared JWT secret vs merged project — is the 9c plan's to resolve against verified current Supabase capabilities; candidates + tradeoffs in `notes/plans/phase-09c-auth-brief.md`). After 9c the API key demotes to a genuinely publishable key. **What does not move:** multi-tenant/commercial hardening, non-author account provisioning, the E2EE/privacy decision (plaintext stays ratified meanwhile), and the variorum-edition export all stay at Phase 14.

**Author-decision deltas (2026-07-09 — the author's first hands-on session; recorded with her uncertainty preserved, per her explicit instruction: "don't add more certainty than I have"):** Her first real session with the Phase 7–9 editor (before the formal feel pass) found two shipped-capability gaps — **a block's first branch had no door** (the FanPanel's only entrance is the ⑂ badge, which renders only on already-fanned blocks — fanning was unreachable in the UI), and **refusals were silent in practice** (all three gesture doors *disable* on a planner refusal, so the tested refusal copy only surfaced on stale-enablement races; a refused shortcut read as a dead key). **Phase 9d created out-of-band (runs before 9b; implemented directly by Fable in this author-attended session — her staffing call):** the fan door ("Show Takes" in the Block menu, context menu, and bottom bar, any arity); the refusal posture change — **doors fire and speak** (refines the ratified "enablement = the planner's verdict": the verdict still drives visual state, but invocation is never blocked into silence — a refused gesture states its refusal); a **gesture button bar** (the contract's fourth door — she needs visible affordances to tell what's possible); a **block ordinal display** ("block 6 · 741AC27E" — user-facing numbers derived from current order at read time, never stored; stable IDs stay the identity); **word counts** (caret block + selection); a **"Show Blocks" tint mode** — soft pastel background per block, rule: **the same color is never adjacent, and colors are stable so inserting a block never re-ripples the document** (her call: deliberately NOT an alternating zebra; the polished version and fan color-coding stay Phase 13); and **sidebar post rename** (`renameContainer`'s first face — the op shipped Phase 2, no phase ever owned its UI). **Merge is N-ary now (supersedes the 2026-07-06 "explicit and binary" ratification):** a selection touching two or more contiguous blocks merges them all — a left-to-right chain of the existing binary merges under ONE undo compound; empty blocks the selection spans join the chain; caret-at-seam stays the binary gesture; merge still never partially applies. **Phase 10 scope additions:** tag management + application UI (folder view is already 10's; an empty taxonomy tests nothing), post archive/delete/restore UI, the seal toggle, and Mac-side entry-date editing — recorded in the Phase 10 brief. **Phase 11 additions — the "boundary fluidity" package (a design DIRECTION, deliberately not fully ratified):** the Phase 9 handoff's cross-fan question is answered **re-owned at 11, not dead** (her first re-bracketing attempt was immediately annoying — the "daily use demands it" condition met on day one): a **guided cross-boundary Make Block** (refusal becomes confirm → adjust the neighbor edges → compound divide/divide/merge under one undo), with **auto-proceed when the span matches uniquely in every take** as a design input (CutPropagation's unique-match condition — the identical middle mints single-variant, the differing outer pieces keep per-take fans, W-style — principled but a genuine change to "the W is the one deliberate ceremony", so it needs 11's design round); **cross-block EDITS ratified as a direction for single-variant×single-variant: merge-then-edit as a compound** (a cross-seam delete just works); for **fanned** blocks the semantics are **OPEN** — she floated per-variant deletion *without* merging ("arguably even for blocks that have variants it should still delete what you chose to delete on each block") and is explicitly not sure; **whether the W must always be a full ceremony is OPEN** (she's conflicted; her argument: if structural changes undo easily, why refuse an easy W that could be undone? — difficulty-dependent, and she suggested open items like these may need **both-ways testing via distinct commands** during 11 rather than a paper decision). Her product principle, recorded for 11's design round: *"the complex machinery is so that power users have powerful options... it shouldn't show up as daily friction. There is no other writing editor where you can select a bunch of text, hit delete, and it doesn't delete... if your text looks like basic text with no variants, it should behave like basic text."* **Block-management affordances named at 11** (delete block, drag-reorder, move to pool — joining the block-TOC work, where TOC rows gain the ordinal + name and may support naming/reordering directly). **Process notes:** she will not enter daily use until the immediate phases (9d, 9b, 9c) are done; effort estimates recalibrated (this class of UI work is hours, not days, with current models).

**Author-decision deltas (2026-07-09, evening — the author's on-device pass, recorded by the 9b coordinator at kickoff; every fix deliberately deferred so 9b proceeds — her call: "go ahead and just work on 9b"):** **(1) The multi-variant editing view is core to the app's identity.** Her pass found there is still no way to fan a block's variants open **side by side** (the FanPanel is a list, not a spread); recorded as her decision, in her terms: *"a view where multiple variants are editable is very important to the overall app and approach"* — suggested shape: side-by-side takes, "maybe with a horizontal scroll when there's many of them." Things are working fine for now, so it waits for its owning phase: **Phase 11's view set is its home** (side-by-side `text | v1 | v2 | text` + expand-all-fans, §12 — brief item 8: a first-class deliverable, not a tail item); how simultaneous *editability* reconciles with P3's one-live-editor rule was left open for the design round — and **ratified by the author the same evening: the live editor migrates between panes as you click** (P3's one-live-editor rule holds unchanged). **(2) "Show Blocks" tint mis-registration is a defect:** the 9d tint stripes do not line up with the text they should cover (colors change where no block boundary is — observed on a long many-block post; screenshot on file with the 9b coordinator session). Fix owned by **Phase 10** (KnownIssues row — trace the fragment-geometry→block-range mapping in the `BlockTint` overlay path before fixing; the never-adjacent/stable-color rules stand). **(3) Paste preserves inter-item spacing (decision at direction level):** bulk entry currently segments pasted text into blocks and the blank lines between the pasted pieces vanish from the editor surface; the author wants the spacing and newlines between pasted items preserved. The *mechanism* is deliberately open — whitespace as block content under I4, versus a render-time rule; either must reconcile with the single-`"\n"` editor-separator and `"\n\n"` renderedText ratifications — and is the owning phase's design question, **asked to her live** rather than assumed (QUESTIONS #12). Owned by **Phase 10** (KnownIssues row). Her same-evening follow-up confirms ask-live and **broadens the conversation**: it should cover the various spacing use cases *including how newline entry is handled*, not just paste — her words: "the editor is so ugly as is, and we'll have to fix it" (the functional spacing/newline treatment is Phase 10's conversation; pure visual polish stays Phase 13). **(4) Cross-fan bracketing is COMMITTED scope, not just a direction:** the Phase 11 boundary-fluidity package (the same-day delta above) upgrades from "design round + build" to committed build scope; its deliberately-open parts (QUESTIONS #10/#11) are settled by **asking her at the time of implementation** — she expects live questions during that phase; both-ways-testing-via-distinct-commands stays her suggested method where a live answer doesn't settle it.

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
