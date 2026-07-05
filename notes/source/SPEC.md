# Holistic Spec — Native Writing App

**Status:** the single source of design truth for this project. Supersedes the earlier `SCHEMA_SPEC.md`.
**Stack (settled):** SQLite as canonical local store (rows-as-truth), Swift, TextKit 2 editor core, SwiftUI chrome, macOS-first → iOS → (eventually) web. A row-based sync engine (PowerSync-class) over Postgres/Supabase for the commercial/multi-device future, designed-for now, built later.
**How to read this:** Sections 1–5 are the *why* and the non-negotiables (vision, mental model, settled stack, performance, invariants). Sections 6–12 are the *what* (schema, operations, queries, views, sync). Section 13 is build order. Section 14 is what's still genuinely open. If anything here conflicts with a casual remark elsewhere, this document wins — except where it explicitly marks something open.

---

## 1. Product vision

A native, premium writing tool. The primary user is the author; it is built "for me and whoever else has a brain just like mine." It must serve three modes over **one** model:

- **Daily journaling** — simple; typically one entry = one block; ordering usually by the day written.
- **Blog posts** — many ideas; pull sources and notes to the side; try out alternate paragraphs.
- **Books** — chapter/scale ordering matters most; same paragraph/word/sentence-level editing as blog posts.

The core feeling: **free and dynamic to work with — ideas are never stifled.** Not forensic reconstruction; just keeping your choices open as long as you want. It is explicitly **not Pages**, **not** a knowledge base, and **not** Apple Notes (which lags badly past ~10k words — a failure this app must not repeat; see §4).

The author's real passion, and the project's design identity: **find the atomic unit, then build around it.** Same instinct as ClipFarm for video — take the underlying thing and play with it easily. It's about *pointers and flexibility*, not the tedious one-note-at-a-time apps on the market. If it's beautiful, bug-free, fast, and flexible, complexity is acceptable.

---

## 2. The mental model

**The store is a directed graph of text blocks with typed edges.** Blocks are nodes holding alternative texts (variants). Posts and pools are *ordered pointer collections* over blocks; readings are *ordered pointer collections* over posts. Every view is a traversal of this graph — never a bespoke subsystem.

Three framing principles carry the whole design:

- **Rich substrate, lean surface.** The data model is always fully capable; any UI exposes only a chosen subset and lets the rest stay latent. This resolves the tension between "crisp/usable" and "maximally flexible" — you don't choose; complexity lives in the store (cheap — rows and edges), restraint lives in the UI.
- **Pointer religion / non-destructive.** Nothing owns blocks; everything points at them. Mutation never reaches anything you've decided to keep. Same religion as ClipFarm, held all the way down — including structural operations (split/merge are reversible pointer moves, not destructive rewrites).
- **Coarse, not forensic.** The system preserves *choices and lineage*, never a word-by-word reconstruction of edits. Edges are `(fromBlock, toBlock, type)` — two IDs and a label. There is no word-level change tracking anywhere.

---

## 3. Architectural decisions (the settled stack)

These are decided. The "why not" notes exist so they aren't reopened.

- **SQLite is the canonical local store, rows-as-truth.** Full SQL (recursive lineage CTEs, the 80%-sort, tag-subtree queries, joins), real constraints (single ownership enforced by the DB), fast local-first reads, a plain file that's exportable and future-proof. Access via a GRDB-style code-first layer (transparent in diffs, clean for AI to author and the author to review).
- **Operations-as-API.** Every mutation flows through a defined, transactional operation (`divide()`, `branchVariant()`, `commit()`, `extract()`, …) — never ad-hoc row edits. This is the clean-operations discipline that keeps the model correct as features grow.
- **History is native to the domain, not bolted on.** Commits, the variant fan, and lineage edges are all append-only and non-destructive by design — event-sourcing's *benefits* without its infrastructure. An **optional secondary audit/operation log** may record operations for global undo/debugging, but it is a *derived artifact*, never the source of truth (so it carries zero projection-consistency or event-migration burden).
- **Row-based sync engine for the commercial future.** Designed-for now (see §11), built later. Target shape: client SQLite ⇄ Postgres/Supabase via a PowerSync-class engine, with `conflict-as-variant` for the one mutable field. Multi-tenant via `owner_id` + row-level security.
- **Web someday via SQLite-as-shared-substrate.** A future web client runs WASM SQLite with the same schema and SQL — cross-platform consistency **without** a shared non-Swift core.

**Why not op-log-as-source-of-truth (the "Option 4" event-sourcing path):** it would charge the full event-sourcing tax (projection-consistency bugs, permanent event-schema-evolution discipline, history-proportional rebuild work) to buy back history this domain already owns. It also fights the performance invariant (§4) and the row-sync engines. Rejected as *canonical* truth; kept only as an optional derived audit log.

**Why not CloudKit / CKSyncEngine:** it's for syncing one user's own devices under their iCloud account — wrong shape for a multi-tenant commercial app, and the tool is *not* rooted in iCloud+.

**Why not Core Data / SwiftData + CloudKit:** the CloudKit integration forbids exactly what this model needs — no unique constraints (breaks single ownership), no ordered relationships (the whole model is ordered pointers), no deny/restrict deletes, weak queries (no recursive CTEs), and add-only schema migrations forever. The "free sync" buys convenience by removing the guarantees the model is built on.

**Why not a Rust backend or core:** the snappiness target lives on the *client*, locally — a server's language is off the hot path and network-bound. SQLite is already optimal for this data size and shape. A shared Rust core's main payoff (cross-platform logic reuse) is already delivered by SQLite-as-shared-substrate, without an FFI seam that would slow AI-assisted development. Rust would only earn its place for real-time collaborative editing — which is **out of scope** (no collaboration).

---

## 4. Performance architecture (a hard constraint, not an afterthought)

**The invariant, treated as load-bearing as any data invariant:**

> **Cost is proportional to what's on screen and what's being edited — never to the total size of the document or the corpus.**

Apple Notes fails because a large note is one monolithic text object laid out in full: a keystroke in paragraph 400 costs in proportion to the *whole note*. This app must never have a cost that scales with document or corpus size. Three layers enforce the invariant:

**Storage layer — tiny writes, indexed reads, never the blob.** Because the document is decomposed into per-block rows, an edit writes one small `variant` row, not a giant document — autosave cost is fixed regardless of post length. Reading a post is one indexed query returning its blocks in order. Rendering a book never loads the book; it pages by post. SQLite runs in WAL mode with a connection pool so reads never block writes, and **all DB I/O is off the main thread.**

**Editing layer — TextKit 2, viewport layout, one focused unit live.** The editor core is an AppKit `NSTextView` on TextKit 2 (not SwiftUI `TextEditor`), chosen specifically for *viewport-based lazy layout*: a 50k-word post lays out only the screenful around the cursor. Block IDs ride block ranges as custom text attributes, so edits stay scoped to the edited range. Keystroke cost is bounded by the visible region, not the post.

**Rendering layer — virtualize long views; read cheap, edit only the focused unit.** Book/timeline/infinite-scroll render only the posts near the viewport (a 200-entry journal shows ~3 posts, recycling views as you scroll). And the sharp lever most apps miss: **content you're only reading is never a live editor.** Finished blocks render as lightweight read-only text; only the *focused* block/post upgrades to a real editable `NSTextView`. You never pay layout-and-edit cost for the 99% of the screen you aren't typing into.

**Convergence with the UX model:** "read cheap / edit only the focused unit" is the *same* principle as the product's "calm default, depth on demand — one block blooms at a time." The interaction design and the speed architecture are one architecture. Build "only the focused thing is heavy" once; get both snappiness and the calm UI from it.

**Escape hatch for pathological sizes (don't build now, but the door must stay open):** one `NSTextView` per post handles realistic sizes (tens of thousands of words) smoothly. At 100k+ words in a single post, virtualize *within* a post — render blocks as a recycled list, instantiate the live editor only around the cursor. The block decomposition is precisely what makes this possible later without re-architecting.

---

## 5. Invariants (never break these)

Data:
- **I1** A variant belongs to exactly one block; variants never span blocks. *(Enables "render = concatenate each slot's chosen variant in order.")*
- **I2** A block is referenced by at most one container (one post **or** one pool). Single ownership. *(DB-enforced: `UNIQUE(container_block.block_id)`.)*
- **I3** The chosen variant lives on the pointer, not the block. *(`container_block.chosen_variant_id`.)*
- **I4** Internal newlines are content, not structure; block boundaries change only via §7 operations.
- **I5** Commits are append-only per variant.
- **I6** Lock is orthogonal to commit — a reversible guard, zero commits.
- **I7** No nesting: a block's variants are whole-span alternatives for the entire block.
- **I8** Posts are edges-only across versions; no post-level variant resolution.
- **I9** Cross-block relationships are edges, never variants.

Performance:
- **P1** No operation's cost may scale with total document or corpus size — only with viewport + edit size.
- **P2** All DB I/O is off the main thread; reads never block writes (WAL).
- **P3** Long views are virtualized; only on-screen units render; only the focused unit is a live editor.

Sync/commercial (designed-for now, enforced when sync ships):
- **S1** All mutations are tiny, append-friendly writes through the operations API — never large-blob overwrites.
- **S2** Deletes are tombstones (`deleted_at`), not row removal, so deletions propagate.
- **S3** IDs are stable and convergent (UUID; deterministic UUIDv5 from natural keys where a natural key exists) so independent devices converge instead of duplicating.
- **S4** Every top-level entity carries a nullable `owner_id` for future multi-tenant row-level security (NULL = current single-user/local).
- **S5** The one mutable field (`variant.working_text`) resolves sync conflicts as a new variant (`conflict-as-variant`), never by clobbering.

---

## 6. Conventions

- **PKs are UUID `TEXT`**; deterministic UUIDv5 from natural keys where one exists (S3).
- **Timestamps are ISO-8601 `TEXT`** (`created_at`, `updated_at`); `updated_at` feeds sync pull cursors.
- **Soft-delete via `deleted_at` tombstones** is the default removal (S2). Domain "archive" (`variant.status='archived'`, `block.archived_at`) is a *separate* concept (kept-but-out-of-fan), distinct from a sync tombstone.
- **`owner_id TEXT` (nullable) on top-level entities** (block, container, reading, tag) for future RLS (S4).
- **Ordering via fractional `REAL` positions** (O(1) inserts; occasional rebalance).
- **Booleans are `INTEGER` 0/1.**
- **`PRAGMA foreign_keys = ON;` + WAL.**
- **FK *cascades* are expressed as triggers, not `ON DELETE CASCADE`,** because the row-sync layer applies records out of order and cannot honor cascade semantics; triggers keep behavior explicit and sync-safe. (Local-only RESTRICT guards like `chosen_variant_id` stay as constraints.)
- **The table named `commit_point`** is the domain "commit" (avoids the `COMMIT` keyword).
- **Per-row sync metadata** (e.g. a `sync_meta` column for the engine's record/change-tag) is added when the sync engine is chosen (§11) — its exact shape is engine-dependent, so it's a documented placeholder now, not a guessed column.

---

## 7. Schema (DDL)

> Order of creation: `container` and `block` first (their FKs are mutually circular and resolve at write time), then `variant`, then the rest. Cascades shown as comments are implemented via triggers per §6.

### block — identity anchors
```sql
CREATE TABLE block (
  id                 TEXT PRIMARY KEY,
  owner_id           TEXT,            -- future multi-tenant (S4)
  default_variant_id TEXT,            -- representative variant with no pointer context (pool/lineage)
  last_container_id  TEXT,            -- powers the per-post "deleted blocks" tray
  created_at         TEXT NOT NULL,
  updated_at         TEXT NOT NULL,
  archived_at        TEXT,            -- domain archive (kept, out of view)
  deleted_at         TEXT,            -- sync tombstone (S2)
  FOREIGN KEY (default_variant_id) REFERENCES variant(id) ON DELETE SET NULL,
  FOREIGN KEY (last_container_id)  REFERENCES container(id) ON DELETE SET NULL
);
```

### variant — the fan (alternative texts for a block)
```sql
CREATE TABLE variant (
  id                TEXT PRIMARY KEY,
  block_id          TEXT NOT NULL,
  parent_variant_id TEXT,            -- branch/history tree
  working_text      TEXT NOT NULL DEFAULT '',  -- THE mutable buffer; autosaved; conflict-as-variant target (S5)
  status            TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','archived')),
  locked            INTEGER NOT NULL DEFAULT 0,
  label             TEXT,
  fan_position      REAL NOT NULL DEFAULT 0,
  created_at        TEXT NOT NULL,
  updated_at        TEXT NOT NULL,
  deleted_at        TEXT,
  FOREIGN KEY (block_id)          REFERENCES block(id),     -- cascade via trigger
  FOREIGN KEY (parent_variant_id) REFERENCES variant(id) ON DELETE SET NULL
);
CREATE INDEX idx_variant_block  ON variant(block_id, status);
CREATE INDEX idx_variant_parent ON variant(parent_variant_id);
```
> `working_text` is the only mutable text in the system and the only field that can produce a sync conflict — resolved by S5.

### commit_point — append-only savepoints inside a variant
```sql
CREATE TABLE commit_point (
  id          TEXT PRIMARY KEY,
  variant_id  TEXT NOT NULL,
  text        TEXT NOT NULL,         -- immutable snapshot
  kind        TEXT NOT NULL DEFAULT 'manual' CHECK (kind IN ('manual','auto')),
  message     TEXT,
  created_at  TEXT NOT NULL,
  FOREIGN KEY (variant_id) REFERENCES variant(id)  -- cascade via trigger
);
CREATE INDEX idx_commit_variant ON commit_point(variant_id, created_at);
```
> Order commits by `created_at` (+ id), **not** a monotonic per-variant `seq` — a global seq collides when two devices commit offline. Restoring a commit loads its `text` into `working_text`; committing again inserts a new row. Text is never overwritten (I5).

### edge — typed block-to-block relationships
```sql
CREATE TABLE edge (
  id              TEXT PRIMARY KEY,
  source_block_id TEXT NOT NULL,     -- derived_from: descendant; version_of: side A
  target_block_id TEXT NOT NULL,     -- derived_from: ancestor;   version_of: side B
  type            TEXT NOT NULL CHECK (type IN ('derived_from','version_of')),
  origin_op       TEXT,              -- 'divide'|'merge'|'extract'|'pool_copy'|'manual'|NULL
  created_at      TEXT NOT NULL,
  deleted_at      TEXT,
  FOREIGN KEY (source_block_id) REFERENCES block(id),
  FOREIGN KEY (target_block_id) REFERENCES block(id),
  UNIQUE (source_block_id, target_block_id, type)
);
CREATE INDEX idx_edge_source ON edge(source_block_id, type);
CREATE INDEX idx_edge_target ON edge(target_block_id, type);
```
> `derived_from (source, target)` reads "source is derived from target" (target = ancestor). `version_of` is undirected. This one coarse table carries split/merge/extract lineage **and** outline→draft mapping **and** "two versions of an article" comparison links.

### container — posts and pools (unified for single-ownership enforcement)
```sql
CREATE TABLE container (
  id                     TEXT PRIMARY KEY,
  owner_id               TEXT,
  kind                   TEXT NOT NULL CHECK (kind IN ('post','pool')),
  title                  TEXT,
  profile                TEXT CHECK (profile IN ('journal','blog','book_chapter','generic','pool') OR profile IS NULL),
  entry_date             TEXT,       -- posts (esp. journals): ordering key
  locked                 INTEGER NOT NULL DEFAULT 0,   -- the post-level seal / "complete"
  locked_at              TEXT,
  floating_notes         TEXT,       -- free-floating per-post notes area
  segmentation_default   TEXT CHECK (segmentation_default IN ('one_block','paragraph','sentence') OR segmentation_default IS NULL),
  last_touched_at        TEXT,       -- any keystroke (sort: noisy)
  last_major_revision_at TEXT,       -- crossed churn threshold (sort: meaningful) — see §10
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
> Posts and pools share one table so a single `UNIQUE(container_block.block_id)` enforces single ownership (I2) uniformly, and "scrap" and "finished prose" are one object type. Pool rows leave post-specific columns NULL.

### container_block — ordered pointers (ownership + chosen variant)
```sql
CREATE TABLE container_block (
  id                TEXT PRIMARY KEY,
  container_id      TEXT NOT NULL,
  block_id          TEXT NOT NULL,
  position          REAL NOT NULL,
  chosen_variant_id TEXT,           -- which variant renders here (I3)
  created_at        TEXT NOT NULL,
  updated_at        TEXT NOT NULL,
  deleted_at        TEXT,
  FOREIGN KEY (container_id)      REFERENCES container(id),
  FOREIGN KEY (block_id)          REFERENCES block(id),
  FOREIGN KEY (chosen_variant_id) REFERENCES variant(id) ON DELETE RESTRICT,
  UNIQUE (block_id)                 -- SINGLE OWNERSHIP (I2)
);
CREATE INDEX idx_cblock_order ON container_block(container_id, position);
```
> Rendering a post = walk by `position`, join `chosen_variant_id → working_text`, concatenate. `RESTRICT` on chosen variant means a shown variant can't be deleted until the slot is re-pointed.

### reading — books / chapters / on-demand collections
```sql
CREATE TABLE reading (
  id              TEXT PRIMARY KEY,
  owner_id        TEXT,
  name            TEXT NOT NULL,
  kind            TEXT NOT NULL CHECK (kind IN ('curated','smart')),
  profile         TEXT,                       -- 'journal'|'book'|'collection'
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
  position    REAL NOT NULL,
  created_at  TEXT NOT NULL,
  deleted_at  TEXT,
  FOREIGN KEY (reading_id) REFERENCES reading(id),
  FOREIGN KEY (post_id)    REFERENCES container(id),
  UNIQUE (reading_id, post_id)                 -- once per reading; but unbounded across readings
);
CREATE INDEX idx_reading_post_order ON reading_post(reading_id, position);
CREATE INDEX idx_reading_post_post  ON reading_post(post_id);
```
> Deliberate asymmetry with `container_block`: blocks are singly-owned; **posts are non-exclusively pointed at** by readings — this is what makes on-demand books work (the same entry in your journal, your "motivation" book, and a year-in-review at once).

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
  FOREIGN KEY (parent_id) REFERENCES tag(id),
  UNIQUE (path)
);
CREATE INDEX idx_tag_path   ON tag(path);
CREATE INDEX idx_tag_parent ON tag(parent_id);
```

### tagging — polymorphic tag application (posts and blocks)
```sql
CREATE TABLE tagging (
  id          TEXT PRIMARY KEY,
  tag_id      TEXT NOT NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('post','block')),
  target_id   TEXT NOT NULL,
  created_at  TEXT NOT NULL,
  deleted_at  TEXT,
  FOREIGN KEY (tag_id) REFERENCES tag(id),
  UNIQUE (tag_id, target_type, target_id)
);
CREATE INDEX idx_tagging_tag    ON tagging(tag_id);
CREATE INDEX idx_tagging_target ON tagging(target_type, target_id);
```
> Post-level tags drive the main UI; block-level tags primarily serve the pool. Polymorphic `target` enforced in app code (split-into-two-tables alternative is in §14).

### setting — global/document key-values
```sql
CREATE TABLE setting (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- seeds: ('default_segmentation','paragraph'), ('major_revision_threshold','0.8')
```
> Default block segmentation is a document/global setting decoupled from UI/mode; `container.segmentation_default` overrides per-post; `profile='journal'` seeds `one_block`.

---

## 8. Cardinality summary
```
reading ──< reading_post >── container(kind=post)     many-to-many, non-owning (on-demand books)
container(post|pool) ──< container_block >── block     ONE container per block (owning; UNIQUE block_id)
block ──< variant                                      one block, many variants (the fan)
variant ──< commit_point                               append-only savepoints
variant ──> variant (parent_variant_id)                history/branch tree
block ──< edge >── block                               derived_from (directed), version_of (undirected)
tag ──< tagging >── (post | block)                     many-to-many, polymorphic
tag ──> tag (parent_id)                                hierarchy
```

---

## 9. Operations as a transactional API (the hard core)

Every mutation is one of these, each a single transaction, each through the operations layer (never ad-hoc row writes). Text-changing ops also update `container.last_touched_at` and churn (§10). The optional audit log (if built) records the operation here.

- **newBlock(post, text)** — INSERT block; INSERT variant(working_text=text); set block.default_variant; INSERT container_block(chosen=variant).
- **autosave(variant, text, charDelta)** — UPDATE working_text, updated_at; add charDelta to churn; cross threshold ⇒ stamp major-revision, reset, rebaseline (§10).
- **commit(variant, kind=manual)** — INSERT commit_point(text=working_text). Counts as a major revision.
- **restoreCommit(variant, commit)** — UPDATE working_text = commit.text. (Old commits remain.)
- **branchVariant(block, fromVariant)** — INSERT variant(parent=fromVariant, working_text=**copied**, fan_position=next). *Default gesture.*
- **newBlankVariant(block)** — branch with working_text=''. *The "different/blank" gesture.*
- **extract(block A, span)** — *source survives.* Span = boundary-adjacent prefix/suffix of A's active variant. INSERT block B + variant(text=span); UPDATE A's active variant = remainder (other variants untouched); INSERT container_block(B) adjacent; edge(B derived_from A, 'extract'). Zero ceremony. The way a sub-paragraph fan is born. *A middle span cannot extract — that's a divide.*
- **divide(block A, cut)** — *source consumed into ordered successors.*
  - **single-variant (everyday, in-place):** INSERT block C + variant(text=A[cut:]); UPDATE A's variant = A[:cut] (A keeps identity as first half — lossless, no fan to desync); INSERT container_block(C) after A; edge(C derived_from A, 'divide').
  - **multi-variant (rare; the only ceremony; W resolution):** A is **preserved whole** and untouched (becomes loose lineage, still referenceable); unmarked variants stay on A. For each marked variant Vi: INSERT first-half variant on new block B and second-half on new block C → B's fan = first-halves, C's fan = second-halves (enables first-half-of-1 with second-half-of-3). Replace A's placement with B then C; edges (B,C derived_from A, 'divide'). Reversible by re-pointing at A.
- **merge(B, C)** — *mirrors W.* INSERT block A' + variant(text = chosen(B)+chosen(C)); replace placements with A'; edges (A' derived_from B), (A' derived_from C, 'merge'). B,C remain as lineage; fans are **not** cartesian-producted.
- **poolDragCopy(poolBlock P → post)** — INSERT block B + variant(text = P's active text); INSERT container_block(B) at drop; edge(B derived_from P, 'pool_copy'). P stays in its pool. *(Copy active text by default; full-fan copy is an option, §14.)*
- **moveBlock(block → container)** — UPDATE container_block.container_id (+position). Single ownership preserved by the UNIQUE constraint.
- **reorder(block, newPosition)** — UPDATE container_block.position (fractional).
- **lockVariant / unlockVariant** — UPDATE variant.locked. (Locked ⇒ to edit, branch or unlock.)
- **lockPost / unlockPost** — auto-commit (kind='auto') live buffers under the post, then UPDATE container.locked. While locked: no new commits; pointer order + chosen variants frozen. Reversible.
- **archiveVariant / deleteVariant** — archive: status='archived' (out of fan, kept in history); delete: tombstone `deleted_at` (must not be chosen — re-point first).
- **deleteBlock** — tombstone `deleted_at`, remove container_block, set last_container_id (feeds deleted-blocks tray). (Soft by default; true purge is a rare GC.)
- **resolveSyncConflict(variant, losingText)** *(sync phase, S5)* — INSERT variant(working_text=losingText, label='conflict') on the same block. The losing edit becomes a card in the fan; no data is clobbered.

---

## 10. The "80%-edited" sort (anti-typo-reshuffle)

Two stamps per post: `last_touched_at` (every keystroke) and `last_major_revision_at` (meaningful edits only). The editor reports a char-delta per edit; the app maintains `churn_accumulator` (chars changed since last major stamp) and `baseline_length`. When `churn_accumulator / max(baseline_length,1) ≥ threshold` (default 0.8), stamp `last_major_revision_at`, reset, rebaseline. A commit also stamps it. A reading's `sort_field` chooses which stamp orders the book; journals sort by `entry_date`. Fixing a typo never reshuffles the library; a real rewrite does. `threshold` is a tunable setting.

---

## 11. Sync architecture (designed-for now, built later)

Not built in early phases — but the schema is shaped for it so it isn't a painful retrofit. Target: client SQLite ⇄ Postgres/Supabase via a **PowerSync-class row-sync engine** (production-tested, native client SDKs, sync-rules for multi-tenant partitioning, writes flow through your own logic so conflict handling is yours).

Design commitments already baked into the schema:
- **Rows-as-truth** → the sync engine's native mode is row replication. (This is a primary reason op-log-as-truth was rejected.)
- **Tiny append-friendly writes** (S1) — the operations API never does big-blob overwrites, so sync payloads stay small and merges stay clean.
- **Tombstones, not deletes** (S2) — `deleted_at` everywhere; server-side soft-delete with trigger-cascaded tombstones.
- **Convergent IDs** (S3) — UUID, deterministic UUIDv5 from natural keys where available, so devices converge instead of duplicating. *(Once sync ships, the deterministic-id scheme freezes — re-deriving would orphan server rows.)*
- **`owner_id` + row-level security** (S4) — present (nullable) now; populated when accounts arrive. RLS gives multi-tenant isolation for the commercial app.
- **Conflict-as-variant** (S5) — the one mutable field resolves conflicts by inserting a variant, not clobbering. For prose this is semantically better than CRDT character-merging (which can produce word-salad), so a row-LWW engine + this rule beats a generic CRDT here.
- **Pull cursors** — `updated_at` per row drives per-table incremental pull.
- A background-context / off-main-thread DB shape (P2) is also a prerequisite for non-janky sync, so it's required from day one anyway.

The exact per-row sync-metadata column shape is engine-specific and added when the engine is selected; treat it as a documented placeholder, not a guessed column, until then.

---

## 12. Views and the UI stance (read this carefully)

**The desire for many views is firm and central.** Multiple views is not a nice-to-have — it is the point, because each view is a different traversal that stress-tests a different edge of the model (folder → tags/membership; book-scrub → ordering + post-as-page; timeline → commit/variant timestamps; outline → derived_from edges). If a view is tortured to build, that reveals a weak spot in the model before everything is built on it.

The views the author wants (all over one store):
- **Continuous/book view** — scroll through notes stacked one on top of another; each note scrolls internally; *not* paginated into fixed page chunks.
- **Book-scrub** — drag a bottom scrubber to skim posts (ordered by time or otherwise); a "page" = a post (a block or grouped blocks); pause and read in full. *50 journal entries = 50 pages, even if one is 10k words — you just scroll through that one.*
- **Infinite-scroll** through the whole book of journals (Kindle-style).
- **Side-by-side** — rework a sentence and hold two **or more** versions open at once: `text | version one | version two | text`. Also two readings/posts in columns.
- **Swap-and-reread** — see the whole piece rendered with one paragraph option swapped in.
- **Outline-left / draft-right** — outline tracks the draft as an *option* and not (independent scroll, or matched); outline items map to the block(s) they became (`derived_from`), showing the spaced-out outline beside the wall of text it grew into.
- **Diff** — between two variants/commits, with whitespace normalization optional.
- **Expand-all-fans** — every fanned block shows its variants stacked/columned to read down and prune; **fans stay open once expanded** (no auto-close); a **close-all-fans** button exists.
- **Folder view**, **timeline view**, **sticky-note/canvas board** for posts (resize, arrange freely).
- **Badge** — at rest, block boundaries are invisible (seamless prose); on focus/hover a block reveals bounds, and a small corner badge appears **only on blocks that have a fan**.

**But the UI itself is an open concept, and that is deliberate.** We have *not* designed the visual UI, and we should not pretend to. The plan is explicit: **get it working technically first — the store, the operations, the traversals, the performance invariant — then do UI design, layout, and tweaks later, iteratively, with the author's direct engagement.** Claude Code should therefore:
- Treat the view list above as *capabilities the data model must support*, not as fixed screens to pixel-build.
- Build the simplest functional rendering of each view needed to prove the model and the performance invariant — plain, unstyled, correct.
- **Not** invest in visual polish, layout systems, theming, or interaction design in the technical phase. That work comes later, with the author, once the substrate is proven.
- Keep the editor/render split (read-cheap / edit-focused, §4) as the one UI-shaped thing that *is* load-bearing now, because it's a performance constraint, not an aesthetic one.

---

## 13. Build order

1. **Core substrate:** schema + migrations + the operations API (§9), with the performance invariant (§4/P1–P3) honored from the first commit (per-block storage, off-main-thread I/O).
2. **Editor core:** TextKit 2 `NSTextView` with block-ID attributes, viewport layout, autosave, commit, the fan, branch — single calm editor proving "cost ∝ viewport + edit."
3. **Readings + first views (functional, unstyled):** continuous book view + one or two others (e.g. timeline, folder) to stress-test traversals. Prove the model under divergent views.
4. **Split taxonomy:** extract / divide (single + multi-variant W) / merge — get the multi-variant divide state transition exactly right (it's the only ceremony).
5. **Remaining views (functional):** side-by-side, outline→draft, diff, book-scrub, canvas, expand-all-fans.
6. **Sync (its own phase):** select the engine, add sync-metadata, implement outbox/tombstone/cursor/LWW + conflict-as-variant; move to background context if not already.
7. **Accounts + multi-tenant:** populate `owner_id`, RLS.
8. **UI design pass(es):** with the author — visual design, layout, interaction polish, theming. Iterative.
9. **iOS surface; web (WASM SQLite) later.**

Defer aggressively: outline→draft connector polish, the fancy scrubber visuals, whitespace-diff niceties, the within-post virtualization escape hatch (only if a real >100k-word post appears), and *all* visual UI design until the substrate is proven.

---

## 14. Open questions for Claude Code to pressure-test

1. **Single-variant divide in-place (§9) vs canonical mint-both** — in-place avoids orphan-block proliferation on every ordinary split; confirm and apply consistently.
2. **Unified `container` (posts+pools) vs separate tables** — unification buys one-constraint single-ownership at the cost of NULL pool columns. Confirm comfortable.
3. **Polymorphic `tagging` vs two tables (`post_tag`, `block_tag`)** — two tables restore real FKs and drop the discriminator.
4. **Cascades-as-triggers** — validate the trigger set replicates intended cascade semantics while staying sync-safe.
5. **Sync engine choice** (PowerSync vs alternatives) — make it *before* finalizing schema, since it dictates the sync-metadata columns and FK handling.
6. **Pool-copy scope** — active variant only (default) vs whole fan.
7. **Churn metric** — char vs token; equal weight for inserts/deletes.
8. **Outline/heading identification** — heading as a block whose text/first-line is a Markdown heading (no schema column) vs an explicit `role`/`heading_level`. Spec assumes the former.
9. **`default_variant_id` lifecycle** — define when it's (re)assigned so a block always has a valid representative.
10. **Edge directionality** — confirm `source=descendant, target=ancestor` reads naturally in traversal code.
11. **Fractional position rebalancing** — threshold + routine when sibling positions converge.

---

## 15. GRDB appendix (sketch)

```swift
var migrator = DatabaseMigrator()
migrator.registerMigration("v1_core") { db in
    try db.execute(sql: "PRAGMA foreign_keys = ON;")
    // create container, block first (circular FKs resolve at write time), then variant,
    // commit_point, edge, container_block, reading, reading_post, tag, tagging, setting.
    // implement cascade behavior via triggers (not ON DELETE CASCADE) per §6.
}
try migrator.migrate(dbQueue)   // dbQueue opened in WAL mode
```
- Records: `Codable, FetchableRecord, MutablePersistableRecord`; associations (`belongsTo`/`hasMany`) for block→variants, variant→commit_points, container→container_blocks, reading→reading_posts.
- Every §9 operation wrapped in `try db.inTransaction { … }`, executed off the main thread; reads via a WAL reader pool.
- Lineage uses a `WITH RECURSIVE` CTE over `edge` (one of the concrete reasons SQL was chosen over an object store).
