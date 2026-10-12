# Variorum — App Spec

**Status:** the single source of design truth for this project — the CONTRACT. Evolved from `notes/source/SPEC.md` (superseded; §14 lists the deltas). **The narrative behind every rule — the dated rulings, the author's verbatim words, ladder findings, supersession histories — lives in `notes/AppSpecRulingsArchive.md`** (canon, not context-loaded; the earlier, longer edition of this document, same section numbers) and, for rulings after 2026-09-26, in the phase plan files this document points at. A pointer here reads *(archive §N)* or names the plan file. Deltas since the source spec: `notes/AppSpecDeltaArchive.md`.
**Stack (settled):** SQLite (GRDB 7, encrypted at rest via SQLCipher) as canonical local store, rows-as-truth · Swift · TextKit 2 `NSTextView` editor core · SwiftUI chrome (Observation + swift-dependencies, no TCA) · SPM core package + thin Xcode app target · macOS-first → iOS (a complete companion app, its own project) → (eventually) web. Sync is a hand-rolled row-sync protocol over Supabase/Postgres, authoritative in `notes/SyncSpec.md`.
**How to read this:** the vision is `CoreDescription.md`; the mental model and invariants are `OverallModel.md`. §1–5 architecture; §6–12 schema, operations, queries, views, sync; §13 build order; §14 resolutions; §15 standing risks; §16 open items.

---

## 1. Development context

- One machine (dev = acceptance): the author's M3 Mac, current macOS (27.x) and Xcode 26. Editor milestones re-verify after each macOS point release — TextKit 2 behavior is version-gated (`notes/TEXTKIT2_NOTES.md`).
- Toolchain: Xcode 26, `swift-tools-version: 6.2`; the fast inner loop is `swift test` on the core package. Deployment targets macOS 26 / iOS 26 (no older-OS support; no availability gating). Swift Testing for all tests.

## 2. Code architecture

- **`VariorumCore` Swift package** — everything below the UI: `Models`, `Persistence` (database stack, migrations, reader/writer pool), `Domain` (pure rule functions), `Operations` (the transactional API, §9), `Queries` (read-side traversals + observations), `Sync`.
- **App target** — thin Xcode app wrapping the package: `App/Variorum/Variorum/` (Mac entry, root composition, `Features/` one folder per module, `Core/Views` shared Mac chrome), `App/Variorum/Shared/` (cross-platform brains and faces), `VariorumMobile/`.
- **Pattern:** SwiftUI + `@Observable` view models + swift-dependencies (`@Dependency(\.database)`, `\.date`, `\.uuid`). View models hold projections and send operations; domain rules are pure functions; persistence and side effects live in injected dependencies. The editor core is AppKit (`NSTextView` via `NSViewRepresentable`).
- One feature = one module; cross-feature interaction routes through parent composition (CLAUDE.md states the exact rule).

## 3. Architectural decisions (settled — the why-nots are OverallModel §8)

SQLite rows-as-truth via GRDB 7, code-first migrations · operations-as-API (never ad-hoc row edits) · history native to the domain (commits, fans, edges — append-only; an audit log would be derived, never truth) · row-based sync designed up front (§11) · web someday via WASM SQLite on the same schema.

## 4. Performance architecture (hard constraint)

> **P1: cost is proportional to what's on screen and what's being edited — never to the size of the document or the corpus.**

- **Storage:** tiny writes (an edit writes one `variant` row), indexed reads, never the blob. WAL + connection pool; all DB I/O off the main thread (P2).
- **Editing:** TextKit 2 viewport layout; block IDs ride block ranges as text attributes so edits stay scoped; keystroke cost bounded by the visible region.
- **Rendering:** long views virtualize; unfocused units render as lightweight read-only text and only the focused unit is a live `NSTextView` (P3 — the same architecture as "calm default, one block blooms").
- Escape hatch (door open, unbuilt): within-post virtualization at 100k+ words.
- Live TK2 geometry was ADOPTED after the Phase 6 spike (archive §15 risk 2); the stored-estimate scrubber and STTextView stand down to documented fallbacks. Measured TK2 deltas per release live in `notes/TEXTKIT2_NOTES.md` §3.

## 5. Invariants

**I1–I9** (data), **P1–P3** (performance), **S1–S5** (sync) — defined in `OverallModel.md` §4–6. One addition formalized here:

- **I10 — a live block has at least one live variant.** Deleting/archiving a block's last active variant is not a variant operation; it is deleting the block. The operations layer enforces it (`deleteVariant`, `archiveVariant`, the ceremonies' birth checks).

## 6. Conventions

- PKs are random UUIDv4 `TEXT`, minted via `@Dependency(\.uuid)`. Timestamps are ISO-8601 `TEXT`.
- Soft-delete via `deleted_at` tombstones (S2). Domain "archive" (`variant.status='archived'`, `container.archived_at`, `block.archived_at`) is a separate kept-but-out-of-view concept.
- **Uniqueness is scoped to live rows:** every uniqueness rule is a partial unique index `… WHERE deleted_at IS NULL`, never a bare `UNIQUE` (a bare constraint lets tombstones block legitimate re-creation). Every such index has a deterministic apply-time repair rule (SyncSpec §7).
- `owner_id TEXT` (nullable) on top-level entities for RLS (S4).
- **Ordering is fractional-index `TEXT`** (base-62 keys with per-call jitter; the pure `FractionalIndex.between`). O(1) inserts, unlimited depth, **no rebalance operation exists**. Sort key is always `(position, id)`. SyncSpec §8.
- Every synced table carries `sync_version INTEGER NOT NULL DEFAULT 0` (the server CAS token). Outbox population is by AFTER INSERT/UPDATE trigger on every synced table, suppressed during remote apply via `_sync_applying` (SyncSpec §3).
- Booleans are `INTEGER` 0/1. `PRAGMA foreign_keys = ON` + WAL.
- **FK cascades are triggers, not `ON DELETE CASCADE`** (row sync applies records out of order). Local-only RESTRICT guards (`chosen_variant_id`) stay as constraints. Triggers own exactly three things — tombstone propagation, outbox capture, and the 13o derived-search-index capture (mechanical only — OverallModel §9, R-13o-4).
- The table for the domain "commit" is `commit_point`.

## 7. Schema (DDL)

> Creation order: `container` and `block` first (circular FKs resolve at DML time), then `variant`, then the rest. Cascades shown as comments are triggers. The current migration set is `Sources/VariorumCore/Persistence/`; the design notes behind each column are archive §7.

### block — identity anchors
```sql
CREATE TABLE block (
  id                 TEXT PRIMARY KEY,
  owner_id           TEXT,
  default_variant_id TEXT,            -- representative variant absent pointer context (§9 lifecycle)
  last_container_id  TEXT,            -- powers the per-post "deleted blocks" tray
  name               TEXT,            -- optional handle (v1_6); CAS metadata
  presentation       TEXT,            -- callout frame (v1_9): canonical JSON kind/color/emoji; color is a
                                      -- THEME-TOKEN NAME, never a literal; takes share the frame;
                                      -- malformed JSON reads as plain; CAS metadata, no repair rule
  created_at         TEXT NOT NULL,
  updated_at         TEXT NOT NULL,
  archived_at        TEXT,            -- domain archive
  deleted_at         TEXT,            -- sync tombstone
  FOREIGN KEY (default_variant_id) REFERENCES variant(id) ON DELETE SET NULL,
  FOREIGN KEY (last_container_id)  REFERENCES container(id) ON DELETE SET NULL
);
CREATE INDEX idx_block_last_container ON block(last_container_id);
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
  fan_position      TEXT NOT NULL,
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
  message     TEXT,                   -- EDITABLE after the fact (renameCommitPoint, §9); the text never is
  created_at  TEXT NOT NULL,
  FOREIGN KEY (variant_id) REFERENCES variant(id)  -- cascade via trigger
);
CREATE INDEX idx_commit_variant ON commit_point(variant_id, created_at);
CREATE INDEX idx_commit_created ON commit_point(created_at);  -- the Library day search's savepoint arm (18h)
```
> Order by `(created_at, id)`, never a per-variant `seq` (a global seq collides across offline devices). Restoring loads `text` into `working_text`; committing again inserts. No `deleted_at`: commits are unreachable once their variant is tombstoned; physical cleanup is the purge design.

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
> `derived_from (source, target)` reads "source is derived from target". `version_of` is undirected and stored canonically as `(min(id), max(id))` so two devices converge to one row.

### container — posts and pools (unified so single ownership is enforced uniformly)
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
  floating_notes         TEXT,
  segmentation_default   TEXT CHECK (segmentation_default IN ('one_block','paragraph','sentence') OR segmentation_default IS NULL),
  last_touched_at        TEXT,        -- any keystroke (sort: noisy)
  last_major_revision_at TEXT,        -- crossed churn threshold (sort: meaningful) — §10
  word_target            INTEGER,     -- per-POST words TARGET (v1_12): display/progress only, NEVER a refusal
  churn_accumulator      REAL NOT NULL DEFAULT 0,
  baseline_length        INTEGER NOT NULL DEFAULT 0,
  wing_id                TEXT NOT NULL DEFAULT '',  -- 13i-a: '' = the virtual Home wing (R-13ia-2)
  created_at             TEXT NOT NULL,
  updated_at             TEXT NOT NULL,
  archived_at            TEXT,
  deleted_at             TEXT
);
CREATE INDEX idx_container_kind       ON container(kind);
-- the timeline's keyset sort key is (stamp, id) over live rows; the indexes match it exactly
CREATE INDEX idx_container_entry_date ON container(entry_date, id) WHERE deleted_at IS NULL;
CREATE INDEX idx_container_major_rev  ON container(last_major_revision_at, id) WHERE deleted_at IS NULL;
CREATE INDEX idx_container_touched    ON container(last_touched_at, id) WHERE deleted_at IS NULL;
```
> Pool rows leave post-specific columns NULL. The UI calls the scraps area **Snippets** (`kind='pool'` stays the model term) and the bookless-notes surface **Pool**.

### container_block — ordered pointers (ownership + chosen variant)
```sql
CREATE TABLE container_block (
  id                TEXT PRIMARY KEY,
  container_id      TEXT NOT NULL,
  block_id          TEXT NOT NULL,
  position          TEXT NOT NULL,
  chosen_variant_id TEXT,             -- which variant renders here (I3); NULL, tombstoned or archived ⇒
                                      -- fall back to block.default_variant_id at read time (SyncSpec §7 repairs it)
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
> Rendering a post = walk by `position`, resolve the chosen variant (falling back to the block's default), concatenate `working_text`.

### wing — in-store libraries (13i-a, v1_18; the sitting record §9: TOTAL isolation)
```sql
CREATE TABLE wing (
  id           TEXT PRIMARY KEY,
  owner_id     TEXT,
  name         TEXT NOT NULL,            -- duplicate names legal (no natural key — no repair class)
  position     TEXT NOT NULL,            -- switcher order
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  deleted_at   TEXT
);
```
> **THE HOME WING IS VIRTUAL (R-13ia-2, the 13i-a kickoff):** rows here are ADDITIONAL wings only; every `wing_id` pointer (`container`/`tag`/`reading`/`shelf`, each `TEXT NOT NULL DEFAULT ''`) means Home when `''` — undeletable and convergence-proof by construction, no seeded row to race. Gatherings assemble, and search/tag listings/Arrivals scope, within ONE wing; the only crossings are the explicit move/copy doors (13i-b/c). The ruling's record: the sitting record §9 + the 13i-a plan §1.

### shelf — the Bookcase's groupings (13i-a, v1_18; `reading_section` one level up — the sitting record §7)
```sql
CREATE TABLE shelf (
  id           TEXT PRIMARY KEY,
  owner_id     TEXT,
  wing_id      TEXT NOT NULL DEFAULT '',  -- '' = Home; shelves are per-wing
  name         TEXT NOT NULL,             -- duplicate names legal
  glyph        TEXT,                      -- ONE grapheme, monochrome (the callout frame's precedent)
  role         TEXT,                      -- NULL | 'welcome' — the seed marker (the §7-SyncSpec Welcome keeper's key)
  position     TEXT NOT NULL,             -- strip order = All's stacking order (§24's ruling)
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  deleted_at   TEXT
);
CREATE INDEX idx_shelf_wing ON shelf(wing_id, position);
```
> An ordered named metadata row a pointer names (`reading.shelf_id`) — never a container, never nested. A nil or DANGLING pointer means UNSHELVED (§19's ruling: unshelved shows at the top of All, in no shelf's solo). Deleting a shelf returns its books to unshelved and never touches a book.

### reading — books and gatherings (recast at 13i-a)
```sql
CREATE TABLE reading (
  id              TEXT PRIMARY KEY,
  owner_id        TEXT,
  name            TEXT NOT NULL,
  kind            TEXT NOT NULL CHECK (kind IN ('book','gathering')),  -- 13i-a (v1_18): the RECAST —
                                               -- a BOOK holds membership rows as truth; a GATHERING is a
                                               -- saved rule assembled at read (the sitting record §1; stored
                                               -- values migrated curated→book, smart→gathering)
  profile         TEXT,                        -- 'journal' (the TRAIT) | 'book' | 'collection' | 'daily' (THE
                                               -- daily Journal's marker — BUILT at 13i-a; the memo's design)
  sort_field      TEXT NOT NULL DEFAULT 'manual'
                    CHECK (sort_field IN ('manual','entry_date','created_at','last_touched','last_major_revision')),
  sort_dir        TEXT NOT NULL DEFAULT 'asc' CHECK (sort_dir IN ('asc','desc')),
  grouping_tag_id TEXT,                        -- section a SMART book by a tag root; a dangling id reads as ungrouped
  query_spec      TEXT,                        -- the v2 RULE (13i-a): gatherings' assembly + living books' intake
  max_posts       INTEGER,                     -- extent constraint (fixed-length journal)
  word_target     INTEGER,                     -- words TARGET (v1_11): display/progress only, NEVER a refusal
  locked          INTEGER NOT NULL DEFAULT 0,  -- FINISHED (13i §5: assembly frozen, intake paused, text editable)
  -- ——— the 13i-a bundle (v1_18; the sitting record §11 — the b–e column set landed whole) ———
  wing_id         TEXT NOT NULL DEFAULT '',    -- '' = Home; books never span wings
  shelf_id        TEXT REFERENCES shelf(id),   -- nil/dangling = UNSHELVED (§19's ruling)
  shelf_position  TEXT,                        -- "my order" (§24); nil = never placed, appends last
  starred         INTEGER NOT NULL DEFAULT 0,  -- the one star (absorbs the retired pin list, §7)
  owned           INTEGER NOT NULL DEFAULT 0,  -- 13i-c's flag; ops enforce; SyncSpec §7's exclusivity repair converges
  sealed_at       TEXT,                        -- SEALED = Finished + text immutability (§5); the exact-stamp unseal key
  hide_owned      INTEGER,                     -- a gathering's toggle; NULL = the global default (SHOW, badged)
  intake_seating  TEXT CHECK (intake_seating IN ('auto','arrivals') OR intake_seating IS NULL),  -- the join dial (§4)
  auto_tag_id     TEXT REFERENCES tag(id) ON DELETE SET NULL,  -- RETIRED-AS-READ since 13i-c (v1_20 carried it;
                                               -- stays a synced column — SQLite cannot drop an FK column)
  auto_tag_ids    TEXT,                        -- THE OUTFLOW (13i-c, v1_20, marker 10→11 — R-13ic-1): a CHOSEN,
                                               -- OPTIONAL SET of tag ids as a JSON array, independent of the
                                               -- intake rule; NULL = none; PLAIN under E2EE (ids only)
  archived_at     TEXT,                        -- BOOK ARCHIVE (13i-e, v1_21, marker 11→12 — R-13ie-1): domain
                                               -- archive, kept-but-out-of-view forever (never a step toward
                                               -- deletion); books AND gatherings; auto-ingestion pauses while
                                               -- set, explicit adds stay open (R-13ie-4); PLAIN (a timestamp)
  created_at      TEXT NOT NULL,
  updated_at      TEXT NOT NULL,
  deleted_at      TEXT,
  FOREIGN KEY (grouping_tag_id) REFERENCES tag(id) ON DELETE SET NULL
);
```
> **A GATHERING REQUIRES A RULE (13i-c, R-13ic-4):** the mint and the rule write refuse a NULL `query_spec` on a gathering (`gatheringRequiresRule`); a gathering with NO rule — reachable only as a Trash restoree — assembles EMPTY everywhere (the malformed rule's closed reading; the match-all tolerance letter is retired; v1_20 moved every live rule-less gathering to the Trash). A BOOK's NULL rule stays "collects nothing by itself".
> `query_spec` holds the **v2 rule grammar** since v1_18 (`Domain/RuleGrammar.swift` — a boolean tree of tag-by-ID and star terms, §19's rulings: subtree matching, renameTag-proof, dead terms match nothing; v1 specs migrated with legacy profile/date terms grandfathered; a NULL is no rule, malformed fails closed per consumer). `profile` gains `'daily'` — THE daily Journal's marker (the identity memo §3; the mint stamps it, `setDailyJournalBook` moves it, the §7-SyncSpec keeper keys on it) — beside `'journal'`, the TRAIT every deliberate notebook door mints.

### reading_post — curated membership (a post may live in MANY readings)
```sql
CREATE TABLE reading_post (
  id          TEXT PRIMARY KEY,
  reading_id  TEXT NOT NULL,
  post_id     TEXT NOT NULL,                   -- container.id where kind='post'
  position    TEXT NOT NULL,
  section_id  TEXT REFERENCES reading_section(id),  -- which CHAPTER (v1_10); a DANGLING pointer reads as UNSECTIONED
                                               -- (deleting a chapter never rewrites memberships; no sync repair)
  status      TEXT NOT NULL DEFAULT 'member'
                CHECK (status IN ('member','arrival')),  -- 13i-a: an ARRIVAL is intake's bell (sitting §4) —
                                               -- synced, visible, NEVER counted/listed/worded as membership
                                               -- (every member-reader filters status='member'). The
                                               -- DISMISSAL-RECORD class = tombstoned 'arrival' rows, written
                                               -- by a judged dismissal, finishing's sweep, and an un-bind's
                                               -- residue alike; sweeps honor ANY row, while a FRESH applying
                                               -- act re-poses a DISMISSED pair at the door (never seated) and
                                               -- a removed MEMBER stays decided (her ratification 2026-10-01
                                               -- — the 13i-b plan §2.1/U1 RECORD)
  created_at  TEXT NOT NULL,
  deleted_at  TEXT,
  FOREIGN KEY (reading_id) REFERENCES reading(id),
  FOREIGN KEY (post_id)    REFERENCES container(id)
);
CREATE UNIQUE INDEX uq_reading_post_live ON reading_post(reading_id, post_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_reading_post_order ON reading_post(reading_id, position);
CREATE INDEX idx_reading_post_post  ON reading_post(post_id);
```
> Deliberate asymmetry with `container_block`: blocks are singly owned; posts are non-exclusively pointed at — that is what makes on-demand books work. The opt-in per-book **Owned** relationship (13i) bends this for books that want it, enforced operations-side with an apply-time repair, never a schema containment (`notes/plans/phase-13i-smart-book-identity-brief.md`).

### reading_section — real chapters: ordered, reorderable groupings within a CURATED book (v1_10)
```sql
CREATE TABLE reading_section (
  id           TEXT PRIMARY KEY,
  reading_id   TEXT NOT NULL,
  name         TEXT NOT NULL,                  -- duplicate names legal (no natural key — no repair class)
  position     TEXT NOT NULL,
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  deleted_at   TEXT,
  FOREIGN KEY (reading_id) REFERENCES reading(id)  -- cascade via trigger (exact stamp)
);
CREATE INDEX idx_reading_section_order ON reading_section(reading_id, position);
```
> A chapter is an ordered metadata row a membership points at — never a container of posts, never nested. Smart readings refuse sections (their sectioning is `grouping_tag_id`).

### tag — hierarchical, path-style
```sql
CREATE TABLE tag (
  id         TEXT PRIMARY KEY,
  owner_id   TEXT,
  parent_id  TEXT,
  name       TEXT NOT NULL,
  path       TEXT NOT NULL,                    -- materialized 'life/goals/2024' — the ONE deliberate denormalization;
                                               -- renameTag rewrites the subtree's paths
  wing_id    TEXT NOT NULL DEFAULT '',         -- 13i-a (R-13ia-1): '' = Home; cross-wing move/copy ADOPTS the
                                               -- destination's same-path tag's id (her rider, the 13i-a plan §1)
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT,
  FOREIGN KEY (parent_id) REFERENCES tag(id)
);
CREATE UNIQUE INDEX uq_tag_path_live ON tag(wing_id, path) WHERE deleted_at IS NULL;  -- 13i-a (R-13ia-1):
                                               -- the vocabulary is PER-WING; same path in two wings = legal twins
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
> Post-level tags drive the main UI; block-level tags primarily serve the scraps area. "Everything tagged X" UNIONs the two.

### block_comment — working notes on a block (v1_8; per-BLOCK, never per-take)
```sql
CREATE TABLE block_comment (
  id           TEXT PRIMARY KEY,
  owner_id     TEXT,
  block_id     TEXT NOT NULL,
  text         TEXT NOT NULL,
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  deleted_at   TEXT,
  FOREIGN KEY (block_id) REFERENCES block(id)  -- cascade via trigger (exact stamp)
);
CREATE INDEX idx_block_comment_block ON block_comment(block_id);
```
> No uniqueness (no repair class). Comment `text` is metadata under sync (server-wins CAS), deliberately not S5. Deleted comments stay visible and resurrectable. Travel across structural ops is the operations layer's (§9), never a trigger's.

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
  position      TEXT NOT NULL,
  created_at    TEXT NOT NULL,
  updated_at    TEXT NOT NULL,
  deleted_at    TEXT,
  FOREIGN KEY (container_id) REFERENCES container(id)
);
CREATE INDEX idx_reference_container ON reference(container_id, position);
```
> Quick Look / PDFKit (page memory; a dragged selection lands as a pool-drag-style copy) / read-only `WKWebView`. Permanently out of scope: EPUB rendering, annotation sync, citation management.

### setting — global/document key-values
```sql
CREATE TABLE setting (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- seeds: ('default_segmentation','paragraph'), ('major_revision_threshold','0.8'), ('idle_commit_hours','2')
-- NOT seeded (defaults applied at READ time in Queries.ThemeSettings): theme_voice, fan_style, receipt_style
--   (toast · quiet · off, default QUIET), theme_palette, theme_tint, theme_accent_tint (validated hex or ''),
--   savepoint_cadence, daily_journal_book (RETIRED-AS-READ at 13i-e — the designation derives from the
--   'daily' marker; the writers keep the key fresh as a cache), arrival_flash ("1"/"0", default ON — the mode-switch arrival
--   flash, 18l-c U8; read in Queries.AppearanceQueries), hide_owned_default ("0" = SHOW badged — the
--   gatherings/listings/search hide-owned default, Library EXEMPT; 13i-c) and ownership_badges ("1" =
--   on — the badge family toggles as a set; 13i-c).
```
> Settings are synced document semantics (segmentation must match on iOS capture): `sync_version` per §6, upsert-only, never tombstoned. **E2EE constraint (14b): `setting.value` is classified PLAIN under the promise "enum semantics, no prose" — no future setting key may carry user-authored prose; a prose-valued setting must re-open the column's classification.** `container.segmentation_default` overrides per post; `profile='journal'` seeds `one_block`.
>
> **Segmentation / the Return key (the current contract):** fresh-text segmentation is type-time crystallization — while typing new text at the end of a post, each completed paragraph silently becomes a block; the trailing paragraph is an open tail. Bulk entry (paste, import, drop, mobile capture) segments on entry. Once a block exists, a NEWLINE inside it is content (I4). **On the Mac, with the segmentation chip ON, the Return KEY is a structural gesture routed through the one structural door** (`TypedReturn.act`, `Shared/EditorBrain`; the intercept at `EditorTextView.insertNewline(_:)` after the list door): an empty block below at a block's end, a divide at the caret inside its text (single-take in place; fanned → keep-on-top), an empty block above at its start, and in an EMPTY block another empty block below, chaining indefinitely (R-13u4-2); an abandoned empty block stays. ⇧⏎ is the newline that stays inside the block. The chip OFF returns the note to Return-as-content. Crystallization is untouched; the tail opens only from a newline arriving as text. The phone's Return model is its own. Rulings U-1, U-19, R-13u4-2 — archive §7; unruled edges QUESTIONS #92.

### local-only sync machinery (never synced; SyncSpec §3)
```sql
CREATE TABLE sync_outbox (table_name TEXT NOT NULL, row_id TEXT NOT NULL, queued_at TEXT NOT NULL,
  PRIMARY KEY (table_name, row_id));           -- dirty-row SET: coalesces keystroke-rate autosaves
CREATE TABLE sync_state (key TEXT PRIMARY KEY, value TEXT NOT NULL);
  -- keys: 'last_server_seq', 'rekey_in_progress' (device identity lives in the per-store custody record)
CREATE TABLE _sync_applying (applying INTEGER NOT NULL);   -- apply-mode flag; permanent table, normally empty
CREATE TABLE sync_row_seq (table_name TEXT NOT NULL, row_id TEXT NOT NULL, server_seq INTEGER NOT NULL,
  PRIMARY KEY (table_name, row_id));           -- per-row server_seq bookkeeping for seq-ranked repairs
```
Later synced additions: `canvas_layout`, `lens`/`lens_choice` (11a), `purge_intent` (13j), **and the 13n-b PRIVATE MARK (v1_25 — THE marker-12→13 lockstep event, `Server/supabase/16_phase13nb_private.sql`): `container.ai_private_at` + `reading.ai_private_at`**, nullable PLAIN timestamps (structure only on the wire — that something is marked, never which words), the AI-private fence's store truth (R-13nb-4, re-keyed at 13n-c by R-AIR-1: the PER-ASK fence — the daily Journal's entries, ⌘J entries and anything Private answer one ask at a time; privacy wins ties, Private ⊥ Owned, gatherings refuse the mark) — see the migrations and SyncSpec §12's lockstep record. **Local-only DERIVED (13o, v1_22 — never synced, no mirror, marker untouched): the search-index family** (`search_doc` + the `search_fts` external-content FTS5 table over the `search_text` view + shadows), maintained by the third trigger duty, rebuildable from truth (`Operations.rebuildSearchIndex`/`verifySearchIndex`), registered as `SyncSchema.derivedTables` — subtracted by the completeness walk, KEPT by the plaintext export so the no-lock-in file searches by itself (the 13o §FORK RULINGS). **v1_23 (VX-83, 2026-10-08): the NINTH kind — savepoints** (`commit_point.text`), listed only under the explicit commits facet (R-13o-6's posture built); `search_doc.variant_id` is the savepoint doc's OWN-ROW parent fact, and liveness resolves at QUERY time through variant → block → placement (the §U-C RULINGS' five conditions, `notes/plans/fixes/vx-83-search-followup.md`); still local-only, zero lockstep, marker untouched. **Local-only, never synced (13n-b, v1_24): the MCP GRANTS family** — per-client × per-scope grant rows (the four rungs), the open-book switch and the activity log, the door's LOCAL truth, decided per call by the pure `Domain/MCPGrantRule` (`notes/plans/phase-13n-b-mcp-door.md`).

## 8. Cardinality summary
```
reading ──< reading_post >── container(kind=post)      many-to-many, non-owning (on-demand books)
reading ──< reading_section                            chapters: ordered groupings within a curated book
reading_post ──> reading_section (section_id)          membership points at its chapter; dangling ⇒ unsectioned
container(post|pool) ──< container_block >── block     ONE live container per block (owning)
block ──< variant                                      one block, many variants (the fan)
block ──< block_comment                                working notes on a block, never per-take
variant ──< commit_point                               append-only savepoints
variant ──> variant (parent_variant_id)                history/branch tree
block ──< edge >── block                               derived_from (directed), version_of (undirected)
tag ──< post_tag >── container(kind=post)              many-to-many
tag ──< block_tag >── block                            many-to-many
tag ──> tag (parent_id)                                hierarchy
```

## 9. Operations as a transactional API (the hard core)

Every mutation is one of these, one transaction each, through the operations layer. Text-changing ops update `container.last_touched_at` and churn (§10). Structural ops (divide-W, merge, poolDragCopy, …) stamp `last_touched_at` but never churn. Exact row-level transitions are pinned by the operations test suites. **Standing conventions** (each op inherits them unless it says otherwise): a sealed post refuses every authoring write under it; a locked take guards its BUFFER (edits refuse; branch or unlock); identity-level metadata setters are no-op-guarded (no touch, churn or outbox row when nothing changes); comments and the callout frame TRAVEL to structural successors (below); a `expectedText` precondition that no longer matches refuses as `bufferChangedSinceGesture`. The narrative behind each op — her words, the ladder findings, the PROVISIONAL numbers — is archive §9 under the same name.

**Blocks, variants, savepoints**
- **newBlock(container, text, at)** — INSERT block + variant(working_text=text); set `default_variant_id`; INSERT container_block(chosen=variant, position). Registers structural undo (a tombstone flip; R-13u-3) **except type-time crystallization**, which passes `registeringUndo: false` (not a gesture).
- **autosave(variant, text, charDelta)** — UPDATE `working_text`, `updated_at`; accumulate churn; threshold-cross ⇒ stamp major revision, reset, rebaseline (§10).
- **commit(variant, kind=manual, message?)** — INSERT commit_point(text=working_text). Counts as a major revision. Refused on a locked take and under a seal.
- **Quiet auto-commit occasions** (`kind='auto'`, deduped against the take's last savepoint when the text is unchanged): sealing a post; locking a dirty take; the idle backstop (`idle_commit_hours`, default 2 — `idleAutoCommit(post)`, at most one per idle period); a structural undo about to overwrite a buffer edited since the operation; `closeAutoCommit` when a note with unsaved changes stops being shown (the everyday cadence, 13j); a cross-block compound about to overwrite the takes it edits (`insureTakes`, 13u1); `moveSpanToNewTake`'s pre-move insurance. `savepoint_cadence` governs the two CADENCE occasions (close, idle) only; the insurance occasions are always on. (The Fragments-bridge landing occasion retired 2026-09-04.)
- **restoreCommit(variant, commit)** — UPDATE `working_text = commit.text` (old commits remain, I5). A commit may predate a structural op — restoring resurrects the pre-split text into this block while the successor still stands; the editor warns.
- **renameCommitPoint(commit, message?)** — set/clear `message`; nil clears; a no-op writes nothing and earns no receipt; refuses under a seal (checked before the no-op short-circuit); ALLOWED on a locked take (PROVISIONAL, QUESTIONS #121). The snapshot text is immutable; `message` is plain metadata CAS under sync (R-13u3-1).
- **branchVariant(block, fromVariant)** — INSERT variant(parent=fromVariant, working_text COPIED, fan_position=next). *The default gesture.* **newBlankVariant(block)** — the same with `''`.
- **moveSpanToNewTake(variant, span, expectedText)** (R-13u4-4 — MOVE alone) — ONE transaction: (1) a quiet auto savepoint of the current take (LOAD-BEARING: her ruled cover for the stay case); (2) UPDATE the take's `working_text` = buffer minus the span, exactly as selected, no snapping, no trimming (a doubled space at the seam is hers — PROVISIONAL #128); (3) INSERT variant(same block, parent=that take, text=the span, fan END, label NULL) — never chosen, never born locked. ONE structural-undo entry with exact-row redo. Touch + churn as a buffer edit. Refuses: sealed post, locked take, archived/tombstoned take, dead block, stale `expectedText`. I10 untouched (the source keeps its remainder; empty is legal).
- **lockVariant / unlockVariant** — UPDATE `locked`. Locking a dirty buffer first appends one quiet auto commit. Refused under a seal.
- **archiveVariant / deleteVariant** — archive: `status='archived'`; delete: tombstone (must not be any slot's chosen variant — re-point first; the operations-layer check is the ONLY live enforcement, since tombstones are UPDATEs and RESTRICT never fires). Either: if it was the block's last live active variant → refuse (I10; delete the block instead). If it was `default_variant_id` → reassign to the most recently updated active variant.
- **`default_variant_id` lifecycle:** set at `newBlock`; reassigned on delete/archive of the variant it names; never NULL while the block is live (I10 + reassignment). It is the pointer-free representative; `container_block.chosen_variant_id` always wins where a pointer exists.

**The split taxonomy** (OverallModel §7; **one snapping rule everywhere** — plain divide, the ceremony's per-take cuts, `CutPropagation`'s seeding and extract's span edges all consult the Domain `BoundarySnapping`: a cut may fall between any two words and at newlines, word-edge floor, gentle settle onto sentence ends and newlines — S4-22)
- **extract(blockA, span)** — *source survives.* Span must be a boundary-adjacent prefix/suffix of A's active variant. INSERT block B + variant(span); UPDATE A's active variant = remainder (other variants untouched); INSERT container_block(B) adjacent; edge(B derived_from A, 'extract'). A middle span is a divide. Extracting from a FANNED block edits only the chosen take (the other takes keep their span — accepted; the editor may hint).
- **divide(blockA, cut)** — *source consumed.* **Single-variant (in place):** INSERT block C + variant(A[cut:]); UPDATE A's variant = A[:cut]; INSERT container_block(C) after A; edge(C derived_from A, 'divide'). Start/end cuts refuse (`invalidCut`). **Fanned block, the DEFAULT — keep-on-top (U-2, both platforms):** the displayed take is cut into B and C and every OTHER active take rides WHOLE onto B (`KeepOnTopDivide`, composed from divide-W's parking rule; zero new operation); the keep-below mirror is the second preset.
- **divideW(blockA, marked takes + cuts, displayedVariantID?)** — *the ceremony ("Divide choosing takes…").* A is PRESERVED WHOLE (placement released, unmarked takes stay on A as lineage); for each marked take Vi, a first-half variant on new block B and a second-half on new block C; placements B then C where A stood; edges (B derived_from A), (C derived_from A, 'divide'). **Parking:** a take whose cut sits at its very END rides whole into B, at its very START into C — so B's and C's fans are independently sized. Refusals: every take parked at the same end (`divideSideWouldBeEmpty`, I10 at birth); an empty take's cut (`invalidCut`). A parked take keeps its label; `displayedVariantID` anchors each side's chosen/default (nil keeps A's rendered take — PROVISIONAL #91). Reversible by re-pointing at A (`placeBlock`). The sheet's presets: Keep takes on the top block (default) · on the bottom block · Copy takes to both (`divideDuplicating`) · Choose per take… (18f; `notes/plans/use-report-round-2026-09-06.md`).
- **divideDuplicating(blockA, displayedVariant, cut)** — the displayed take's halves seed B and C (each side's chosen + default); every OTHER active take is duplicated WHOLE onto BOTH successors (fresh UUIDs, labels ride, parent trees remapped per copy set, never born locked, commits never copied); A released whole; edges as divide-W; comments copied to both; presentation inherited; archived takes stay on A; touch without churn; ONE undo entry. Start/end cuts refuse. Accepted consequence: a duplicated take chosen on both successors reads twice. Superseded as the default by keep-on-top; survives as the third preset.
- **merge(B, C)** — *mirrors W.* INSERT block A′ + variant(text = chosen(B) + `"\n"` + chosen(C) — **the RENDERING join: exactly one newline, byte-exact, no trimming, R-13u4-3**, on EVERY merge DOOR: the block ▾ menu / ⌘⇧M, the context menu, the palette, the N-way chain, the bulk bars, the ceremony's per-pairing default, the phone's Merge with Previous, Make Block across blocks). **The DELETE keystrokes keep the shipped join** (the seam ⌦/backspace carve and the cross-block compound's mid-paragraph edge-join — `Domain/MergeJoin.swift`'s `MergeJoinRule`). Replace both placements with A′; edges (A′ derived_from B), (A′ derived_from C, 'merge'); B, C released to lineage (stamping `last_container_id`); fans never cartesian-producted; comments from both sides carried; presentation kept only when both agree, else plain. Refuses under a seal; adjacency required.
- **mergeCeremony(B, C, pairings, carries)** — *"Merge choosing takes…"* (S4-23). Each hand-placed pairing mints one joined take (explicit join: newline by default · space · nothing); each carried take rides onto A′ whole; the rest stay with the released sources. A take participates in at most one pairing (1:1, PROVISIONAL). Zero pairings and zero carries refuse (`mergedBlockWouldHaveNoTake`). Everything else as `merge`. Presets: Bring every take (default) · Only the two shown · Pair by hand…; **over three or more blocks the door offers only the first two** (U-16). The no-fan merge stays byte-unchanged.
- **poolDragCopy(P → post, at, includeFan=false)** — INSERT block B + the rendered take (or the whole live fan with archived takes riding, statuses preserved; commits never copied; not born locked; parent tree remapped); INSERT placement at the drop; edge(B derived_from P, 'pool_copy'); comments and presentation copied, `name` never. P stays. Pool→draft is the only copy direction.
- **importDocument(file) / importBook(folder, shelfId?)** (13n-a, 2026-10-09 — the Variorum document format's in-doors; the record `notes/plans/phase-13n-a-document-format.md`, the sitting `phase-13n-sitting-record-2026-10-09.md` R-13n-8/11): the format IS the fan export plus the capture-token header, parsed as `joinRenderedTexts`'s EXACT INVERSE (rows round-trip in the stated domain; any export re-imports whole; refusals are fail-honest with line numbers). A file mints a bookless note in the Pool; a folder mints an unshelved book (subfolders = chapters, digit-aware order; `shelfId` = the drop's context mint). ONE transaction and ONE compound undo entry each — the inverse tombstones exactly what was minted on one stamp, the stamp-keyed redo revives those exact rows (an inverse that tombstones nothing never overwrites the stamp). The in-place text is each block's chosen take AND default; labeled takes join the fan's end unchosen; tags adopt-or-mint by path through the one application road (living books hear them); touch without churn; the E13 name guard preflights. The EXPORT pin stands untouched: no export path writes a row; a file is bulk entry, never reconciled truth.
- **moveBlock(block → container, at)** — UPDATE `container_block.container_id` + position (I2 by the live-unique index). **reorder(block, between A and B)** — `position = FractionalIndex.between(...)`. **placeBlock(block, container, at)** — INSERT a placement for a live block with NO live placement (a released-to-lineage block, a tray restoree); the primitive structural undo emits.

**Deletion, restoration, the tray**
- **deleteBlock(block, requiring: precondition = .none)** — tombstone block + placement; set `last_container_id`; trigger-cascade tombstones variants, comments, edges. `.none` is the ordinary door; **`.emptyWithNothingUnshown(variantID:)`** is the seam-backspace carve's authorization, RE-CHECKED INSIDE the tombstone's transaction (the named variant must be the block's ONE live variant, active, unlocked, empty, under an unsealed post, with no live comment; else `blockCarriesUnshownText` / `bufferChangedSinceGesture`) — a caller-side check would read the editor's deliberately-stale projection. The same precondition rides the structural redo.
- **restoreBlock(block)** — clear the block's tombstone and those of children carrying the SAME `deleted_at` stamp (cascade victims; independently-deleted rows stay dead); then `placeBlock` into `last_container_id`. A tag application revives only if its tag is live.
- **restoreContainer(container)** — the same exact-stamp rule over placements, their blocks and children, memberships, post tags, references. Rows whose story diverged stay as they are (a block independently revived keeps its current placement; a membership whose reading died stays dead).
- **restoreReading(reading)** (S4-28.2 — readings DO have a restore door) — exact-stamp revival of its chapters and memberships; a membership whose post has since died stays dead; assignments reattach for free; smart readings restore by the flip alone; refuses when live. No undo entry (the door is the recovery). Documented corner: a member post that died AFTER its reading is left out — add it back by hand.
- **Structural undo / redo** — session-scoped, in-memory, structural ops only: divide (all forms), merge (both forms), extract, newBlock, deleteBlock, deleteVariant, archiveVariant, moveBlock, reorder, poolDragCopy, moveSpanToNewTake, the conversions and composites below. Each registration carries its inverse AND an exact-row `redo` built from do-time pre-images (never a re-run — IDs must survive undo↔redo); `register`'s `redo:` is required (nil = deliberately not redoable, and undoing past it ends the redo future). Any new structural act clears the redo future, a rolled-back compound included. Undo and redo EMIT ORDINARY OPERATIONS, so sync never learns they exist. Excluded: text editing (⌘Z stays NSTextView's), commits, locks, tags. Doors ⌥⌘Z / ⇧⌥⌘Z (never ⌘⇧Z). A buffer edited since the operation is insured by a quiet auto commit before the inverse overwrites it. Two presses inside one flight refuse the second.

**Posts, seals, extents**
- **lockPost / unlockPost** — auto-commit dirty live buffers, then UPDATE `locked`/`locked_at`. The seal refuses every authoring write under the post (edits, commits, order, chosen variants, comments, presentation, take labels, savepoint names); the post itself may still be archived, deleted, retitled, tagged and added to readings. **`resolveSyncConflict` lands even under a seal** (S5 outranks it).
- **setPostWordTarget(post, words?)** — display/progress only, NEVER a refusal; refuses non-positive; nil clears; no-op guarded; refuses under a seal (PROVISIONAL).
- **saveNoteVersion / restoreNoteVersion / promoteNoteVersion** — whole-note Versions (`notes/plans/post-13l-polish-round.md`): `saveNoteVersion` is a full family copy born archived + sealed from ONE clock read (`archived_at == created_at` IS the version classifier), no title mutation, no `entry_date`; `restoreNoteVersion` is identity-preserving — save the moment of now first, the outgoing blocks take the Delete Now road (tombstone + purge intents, never a raw DELETE), the version's family copied into the SAME container, every version link re-anchored via the classifier; `promoteNoteVersion` unarchives + unseals. Versions ride the note's deletion on its exact stamp; a version's ONE home is Note ▸ Versions (excluded from Library, Archived and every global search by `Queries.versionHistoryPredicate`).
- **divergePostForReading(post, reading)** (13f, W23) — ONE transaction: a `duplicateAsVersion`-shaped copy; its membership at the original's exact slot (position AND `section_id`); the original's membership in THIS book tombstoned (it lives on elsewhere). Curated books only; refuses under a finished book; capacity un-gated (net zero). ONE undo entry; the redo revives the copy through `restoreContainer`'s exact-stamp path. Doors flush the pending buffer first.
- **duplicateAsVersion / promoteLens** — per-block copies carrying comments, presentation AND `block.name`; a `version_of` edge for the former.

**Readings, chapters, tags, comments, presentation, references**
- **addPostToReading / removePostFromReading / assertReadingAcceptsPosts(reading)** — the gate (missing / wrong kind / locked / at capacity) is a standalone core read run INSIDE the serialized closure so a door can refuse BEFORE minting.
- **Event-driven INTAKE + the judgment ops (13i-b — the sitting record §4/§19/§24; the plan `notes/plans/phase-13i-b-gatherings.md`):** a LIVING book (live · `kind='book'` · readable rule · not finished) hears the APPLYING act only — `applyTag`/`setStarred` through the ONE application road — and seats (`status='member'`, END, unsectioned) or bells (`status='arrival'`) per the pure `Domain/IntakeDecision` table (capacity waits at the door; the `intake_seating` dial, NULL = join quietly; un-tag/un-star are NON-events; insert-only, tombstone-means-decided). CREATION-time backfill seats; RESUME catch-up (restore, un-finish, rule edit) bells. `lockReading` dismisses pending arrivals in its transaction. Judgment: `seatArrival` / `dismissArrival`. AUTO-TAG: `auto_tag_id`'s tag applies on mint-inside AND hand-add; `tagAllMembers` is the bulk door; removing a rule never untags. `saveFilterAsGathering(reading, filter)` mints a gathering (association ∧ filter). *(The outflow's CHOSEN multi-tag redesign is RULED and 13i-c's — an authorized §12 event.)*
- **OWNED, FINISHED, SEALED — the 13i-c op family (the sitting record §2/§5/§6/§18/§20; the plan `notes/plans/phase-13i-c-owned-finished-sealed.md` §3/§5/§6 + its U2 RECORD):** ONE pure consult, `Domain/OwnershipDecision` (an OWNED target + a note membered in another BOOK → the copy-or-move choice; a PLAIN target + a note owned elsewhere → copy only; bookless → a plain add), read by `addPostToReading` and `seatArrival` AFTER the capacity gate (`noteMemberedElsewhere` / `noteOwnedElsewhere` — the refusals that OPEN the ceremony sheet); `shelveInDailyJournalBook` BELLS on a conflict (`.waitingAtDoor`, never a throw). **`setReadingOwned(reading, true)`** — the convert door: every member also membered elsewhere FORKS IN PLACE (a full family copy takes this book's exact slot, tags RIDE the copy, the original's row here tombstoned; LISTED in the confirm); sole members own in place; refuses a gathering and a finished/sealed book; no undo entry. **`false`** lifts exclusivity, members stay. **`copyPostIntoReading`** (COPY IN: the family copy's membership first, then the outflow; one undo entry) · **`movePostIntoReading`** (MOVE IN: every other live row of the note severed — listed; refuses while a severed member sits in a finished book) — each with an `answering:` form for an arrival (the row decided member-class). **The REVIVAL PASS** (`restoreContainer`, `restoreReading`, the bind's redo, `revertDiverge`/`reapplyDiverge`): R2's shape locally — the earliest-created membership stands, a later owned-side row demotes to an arrival, a later plain-side row beside a standing claim is tombstoned; a membership revives into a SEALED book only when its note is sealed. **`sealReading`** — SEALED = Finished + text immutability (EDITION ZERO): shared members forked in place first (fork-free on an owned book), the finish (pending arrivals dismissed — the confirm's N IS the act's set, one shared predicate), `sealed_at = now`, every member sealed on that EXACT stamp (dirty buffers insured); **`unsealReading`** unseals the stamp-matched members AND REOPENS the book with the catch-up (R-13ic-3); `unlockReading` on a sealed book refuses `readingSealed`; a note's own `unlockPost` refuses `noteInSealedBook` while a live sealed book holds it. **`deleteReadingWithNotes`** — the owned book's second delete choice: the book and its member notes on ONE stamp (versions ride); **`restoreReading` returns WHOLE** (stamp-matched member notes revive first, then memberships, then the revival pass, then the catch-up). **`duplicateReading(name, deep)`** — configuration not state (rule, outflow, dial, extents, trait, chapters; born unshelved, open, non-owned); shallow = the same notes, deep = family copies; an owned source duplicates DEEP only; a gathering never duplicates. **`removePostFromReading`** returns whether the note is now bookless ("Release" on an owned book). **`setReadingOutflow(reading, tagIDs)`** — the CHOSEN set (ordered, deduped, every tag live in the book's wing; `[]` = none); `applyAutoTag` applies EVERY outflow tag on mint-inside and hand-add; `tagAllMembers(nil)` = every outflow tag. **`setReadingHideOwned(gathering, Bool?)`** — nil follows `hide_owned_default`. The membership readers (`membershipElsewhere`, the Pool's exclusion, `readingsContaining`) count BOOK rows only, live books only.
- **shelveInDailyJournalBook(post)** — puts the day's entry into THE daily Journal (since 13i-e, DERIVED from the `'daily'` marker — never the setting, which survives only as a written cache) as ordinary membership; an ARCHIVED daily Journal comes back ON EVERY PRESS — before the filing on a fresh pair, and on the decided road too (her post-close ruling 2026-10-03, the 13i-e plan's addendum: "it's fine for it to unarchive when you command J"; open-today kept; §10's "it returns when a day arrives"). NEVER throws: returns `shelved` / `alreadyDecided` / `bookFinished` / `bookAtCapacity` / `wrongKind` / `refused`. Any `reading_post` row for the pair — live OR tombstoned — means the pair is already decided (a headless round never undoes a deliberate removal). **Creates and pins the Journal when none is designated** (or the designation dangles) — curated, `profile:'journal'`, `entry_date` ascending — and ⌘J delegates its whole ensure here; it never replaces a book she designated (a finished, full or smart daily book keeps its own status). A READ-THEN-ACT composite, not one transaction (the tombstoned-row race is recorded, unpinnable without an op-level precondition). Its convergence under sync: SyncSpec §7's daily-Journal keeper repair.
- **createSection / renameSection / deleteSection / reorderSection / assignPostToSection / restoreSection** — CURATED readings only (smart refuse). A locked reading freezes chapter STRUCTURE while rename stays free. `deleteSection` tombstones only the section (memberships keep the pointer; dangle = unsectioned); `restoreSection` is one flip — refuses when live, under a locked reading, or when the section died WITH its reading (restore the reading first). No undo entry.
- **setReadingWordTarget / setReadingMaxPosts** — refuse non-positive and under a locked reading; `word_target` display only; lowering `max_posts` below membership is legal (further adds refuse).
- **convertSmartReadingToCurated(reading, order: nil)** (13c, N38 shape A — PROVISIONAL #46) — ONE transaction: the current assembly materializes as `reading_post` rows in the GIVEN order (nil = stored sort); `kind` → curated; `sort_field` → manual; `query_spec`/`grouping_tag_id` stay on the row — and the rule stays LIVE: **the bound book KEEPS COLLECTING** (the sitting record §14.6; N38-A's stop and the "(collecting)" sibling offer are retired — 13i-b). Refuses non-smart and locked. Undo AND redo; the un-bind leaves NO live row on the reverted gathering (every taken row flips to the dismissal class as it tombstones; hand-removals keep their member-class tombstones) and the redo restores each row AS WHAT IT WAS — ids AND statuses (the 13i-b plan's ladder record).
- **renameTag(tag, newName)** — rewrite `name` + the subtree's materialized `path` in one transaction (under sync, plain CAS per row — worst case a lost rename). **applyTag / removeTag** (post or block) — INSERT/tombstone; `post_tag` targets must be posts.
- **addBlockComment / editBlockComment / deleteBlockComment / restoreBlockComment** — delete is a tombstone; deleted comments visible and resurrectable (`Queries.deletedBlockComments`). All writes refuse under a seal (PROVISIONAL #23). **Travel:** extract/divide keep A's and COPY to the minted half; divide-W and divideDuplicating copy to B AND C; merge carries both sides'; poolDragCopy / duplicateAsVersion / promoteLens carry per-block copies. Copies are fresh owner-stamped rows preserving the source's `created_at`; DELETED comments never travel; structural undo needs no extra machinery (reverting a mint cascades the copies).
- **setBlockPresentation / updateBlockPresentation** — identity-level (no-op guard, no touch/churn); the update is a read-modify-write in ONE transaction; refuses under a seal (PROVISIONAL #24). Successors INHERIT the frame; merge keeps it only when both sources agree; duplicateAsVersion/promoteLens copy it with `name`; poolDragCopy copies it (and comments) but never `name` (#24(e), pending). Export maps a callout to a blockquote (a presentation transform only).
- **setBlockName / setTakeLabel** — identity-level metadata; a seal refuses `setTakeLabel`.
- **addReference / removeReference / updateReferenceViewState** — INSERT/tombstone/UPDATE `reference` rows.
- **setJournalTrait(reading, on)** (13i-a — the sitting record §10's per-book settings row; the Collecting-pane face is 13i-e's) — on ⇒ `profile='journal'`, off ⇒ `'book'`; the `'daily'` book refuses (its marker is constitutive — PROVISIONAL, the 13i-a plan §9); a finished book refuses; no-op-guarded. **setDailyJournalBook** MOVES the `'daily'` marker with the designation in one transaction (13i-a ladder M-3 — every other live `'daily'` row demotes to the trait; the stale-bearer merge class closed). **setShelfPinned / Queries.shelfPins** read and write `reading.starred` since 13i-a (starred absorbs pins, the sitting record §7; the `shelf_pins` setting is retired-as-read).
- **The 13i-e op family — BOOK ARCHIVE + the daily Journal as ruled (2026-10-03, `notes/plans/phase-13i-e-daily-journal.md` — the rulings R-13ie-1…4 with her two riders; PROVISIONALs #179):** **`archiveReading`** (a book OR a gathering, the daily Journal included — its one road; ONE row write, a plain book archives alone) · **`archiveReadingWithNotes`** (the OWNED door's second choice: the book's not-yet-archived member notes' `container.archived_at` on ONE stamp; never tombstones, never versions; the op refuses only a gathering — the DOOR offers it on owned books) · **`unarchiveReading`** (the book's flag clears; EXACT-STAMP members return whole; a living book's resume CATCH-UP bells, never quiet seats). Archived semantics: out of the Bookcase/census/counts/catalog, listed under ARCHIVED; AUTO-INGESTION paused in the ONE intake table (`intakeRuns`), VISIBLY (the Collecting pane says so); EXPLICIT adds land (her amendment — no `readingArchived` refusal exists; the pickers mark "(archived)"); an archived gathering assembles EMPTY everywhere (the Pool tuck re-classes); membership stays a FACT (an archived book still homes — and still owns — its notes); the E13 name guard skips archived names; pending arrivals keep waiting; Finished/Sealed/locked orthogonal; duplicate born unarchived; restore-from-Trash returns archived; double archive/unarchive refuse; no undo entry (the door is the recovery). **THE DAILY JOURNAL (§10 built):** the designation DERIVES from the `'daily'` marker (`Queries.dailyJournalBookID` = the keeper's smallest-id pick; the `daily_journal_book` setting RETIRED-AS-READ, kept as a written cache); `deleteReading` AND `deleteReadingWithNotes` refuse it (`dailyJournalCannotBeDeleted`, on the marker, inside the write) — every door shows ARCHIVE in Delete's place on both platforms; `shelveInDailyJournalBook` UN-ARCHIVES an archived Journal on EVERY press (fresh pair: before the savepointed filing — a refused filing still brings it back; decided pair: the un-archive alone, nothing re-filed — her post-close ruling, the addendum), and the ⌘J road speaks a quiet receipt when it returned; `setDailyJournalBook` refuses a non-book and a dead/missing designee (the ladder's two-step guard). Lesson 9's second sentence teaches it (F-U7-2's pin flipped).
- **The 13i-d op family (2026-10-02, `notes/plans/phase-13i-d-bookcase.md` — the rulings R-13id-1…6 + her #169(a)/(b); PROVISIONALs #170–#178):** **shelf ops** (create/rename/glyph/delete/move; `setReadingShelf`; `placeReading`'s one my-order sequence; deleting a shelf returns books to UNSHELVED) · **`ensureWelcomeShelf`** (adopt-by-role, the R5 keeper's key; the seeder mints and shelves the seeded content — since 13s-b the R-13s-37 set: the field guide, sherlock OWNED, the empty starred notes, the disclaimer snippet; the classics gathering and the quicknote now arrive by their restore doors, not the seed) · **the UNION STAR** (one star, one transaction over both stores; `setShelfPinned` routes through it; the Mac's Pin door retired into Star/Unstar; the daily Journal and Quicknotes stay born-starred, R-13id-5) · **wing ops** (mint/rename; DELETE refuses unless empty, naming contents and the bulk road — R-13id-2) · **`moveReadingToWing` / `moveWingContents`** (R-13id-6: members move whole with tags adopting by path, stay-behind memberships severed and LISTED, finished/sealed ride whole, archived ride archived, pending arrivals dismissed-and-said, unshelved landing, source tags without applications tombstoned — the wing ends empty; the daily Journal refuses both doors; NO undo) · **cross-wing undo revivals are OBSOLETE** (`revivalWingScope` — a replay that would cross wings does nothing) · **`lockReading` and non-nil extents REFUSE a gathering** (`wrongReadingKind`; clearing stays legal) · **`seatArrival` seats an ARCHIVED note as an archived member** (her #169(a); intake's automatic seats still never seat one; finishing dismisses every waiter).
- **resolveSyncConflict(variant, losingText, label='conflict')** — INSERT variant(losingText, label) on the same block, same parent, fan's end (S5). Lands under a seal; refuses a dead block (the engine's in-apply rescue skips one silently). ~~applyBridgeLanding~~ retired 2026-09-04 (tag `archive/fragments-bridge-2026-09-04`).

## 10. The "80%-edited" sort (anti-typo-reshuffle)

Two stamps per post: `last_touched_at` (every keystroke) and `last_major_revision_at` (meaningful edits). The editor reports a char-delta per edit; `churn_accumulator` (inserts + deletes, equal weight) accrues against `baseline_length`; when `churn / max(baseline,1) ≥ threshold` (setting, default 0.8): stamp, reset, rebaseline. A manual commit also stamps. A reading's `sort_field` picks the stamp; journals sort by `entry_date`. Churn math is a pure Domain function. The Library's day filter answers "notes edited on this day" as the UNION of the last-edit stamp and any savepoint written that day (18h) — the honest reading under the one-stamp design.

## 11. Sync architecture

**Authoritative document: `notes/SyncSpec.md`** (read it in full before touching sync, custody or a schema). Summary: hand-rolled state-based row sync over Supabase/Postgres; dumb server (compare-and-set + per-tenant `server_seq` changefeed); all merge intelligence client-side — conflict-as-variant for `working_text` (S5), server-wins for metadata, deterministic apply-time repairs for every live-unique index, deferred-FK batch application, trigger-fed coalescing outbox with apply-mode echo suppression; the wire is E2EE ciphertext sealed at the payload serializer; multi-tenant with RLS; the migration-lockstep rule (§12 there) governs every schema change.

## 12. Views and the UI stance

**Many views over one store is the point** — each is a different traversal that stress-tests a different edge of the model; a view that is tortured to build reveals a weak spot in the model. The load-bearing UI-shaped constraint throughout is P3's read-cheap/edit-focused split. **The binding design records are the plan files** — Phase 13 (`notes/plans/phase-13-ui-design.md`, rulings R1–R94), the pre-13u round, the Act 10 correction round, the use-report rounds (`use-report-round-2026-09-06.md`, `-2026-09-12.md`), 13u3's `phase-13u3-memo-gutter.md`, and the 13u4 restyle. Archive §12 holds the full narrative of every ruling below.

**The current surface (contract):**
- **Two voices, exactly two** — Terminal (leads) and Study — each with tokens AND idioms; light designed first; **dark is a fully black room in both voices under every palette** (R51); all fonts macOS-shipped; **Study is the fresh-store default since 13s-b** (a voiceless store adopts Study; an existing store keeps its voice). A **colour palette** layers UNDER the voice (18g): sixteen presets plus custom hex, the synced `theme_palette` + `theme_tint` + `theme_accent_tint`, replacing only room/wash/accent/take tints/hairline via ONE pure rule (`PaletteDerivation`, WCAG-AA-stepped accent); `default` is each voice's shipped colours. **Appearance** (18j): follow system · light · dark, a LOCAL preference applied once as `NSApp.appearance`. No literal colour outside the token layer (pinned).
- **The sidebar:** Bookcase · Library · Pool · Snippets · Archived (the Bookcase name since 13i-d); the Trash door on the Library masthead. **BOOK ARCHIVE's faces (13i-e, the plan's U2 RECORD + the walk):** the ARCHIVED surface gains its BOOKS group above the notes ("kept, with no countdown" — keep-forever, never a countdown), rows Open · Unarchive · Delete Book… (NEVER Delete on the daily Journal); the archive doors render from ONE table beside Delete on every book/gathering surface — the daily Journal shows Archive IN Delete's place, its State caption §10's own sentence; the OWNED book's door asks with the delete confirm's twin (N = the not-yet-archived member set); the Collecting pane leads with the visible pause while archived; the pickers/chips/Book Panel mark "(archived)"; the receipts say what came back and what waits at Arrivals; ⌘J's comes-back speaks "The Journal is back on the Bookcase." Library = everything, with List and Notes cards carrying a muted time stamp (`TimeStampFace`), a `sort ▾` (edited · created · date · title, direction local) and the day filter (18h). Pool = bookless posts. Snippets = the scraps area (groups as the container noun). ⌘K palette; ⌘N = New Post; Settings (nine panes, searchable) is tag management's home.
- **THE BOOKCASE (13i-d, `notes/plans/phase-13i-d-bookcase.md`; the sitting record §7/§19–§24 is the ruling):** shelves as a mode-row STRIP (one line, edge fade, ⋯ type-to-filter overflow; the names on quiet near-square light-wash chips, the solo'd one filled — librarywalkpolish R-LWP-2, the committed reference `notes/plans/librarywalkpolish-ui-reference.html`; **the strip LEADS with the VIRTUAL "starred" shelf: books-only, the union star, shown always, drop-to-star — R-17y-9, item (s)**); solo on the default shelf · All stacks shelves in strip order; UNSHELVED at the TOP of All under its own collapsible header; Welcome holds the SEEDED content only; new books land unshelved, a context mint lands on the solo'd shelf; drop targets + drag reorder + Move to Start/End; Rename · Set Glyph (one grapheme, monochrome) · Make Default · Delete→unshelved; **the № census** (a quiet POPOVER under its mark — the order menu's twin on ONE masthead-popover idiom, the selected row washed, census solos COMPOSING within a solo'd shelf: 17y (r) + librarywalkpolish R-LWP-1; collapsed by default; each row a SOLO filter: books · gatherings · finished · owned · living · with arrivals); **order ▾** = a–z (default, digit-aware) · last edited (DERIVED locally, never synced) — **my order and hand placing (grips, row drops, Send to Top/Bottom) STEPPED BACK for 0.9.2 at her word (librarywalkpolish R-LWP-4; a stored my-order preference reads a–z, never rewritten; the proper return is VR-120)**; starred floats first under any order; **details** hides row meta AND arrival counts; honest counts ("N notes · M archived"); NO search box, NO time filter (the place/finder boundary). **THE BOOK PANEL:** the collapsible right-side book TOC on every membered note (the switcher atop for shared notes; "appears in N gatherings" with names; Remove/Release; drags over the existing ops with menu twins). **THE WING SWITCHER** (a masthead dropdown; "Wings — each a separate library"): mint · rename · delete-unless-empty · Move Everything to Another Wing (additional wings only); the whole surface re-scopes per wing; the per-item Move/Copy to Wing doors carry R-13ia-1's tag adoption; the lineage door under a cross-wing copy names the wing and at most offers go-to (ruled #166(e)). **ARCHIVED MEMBERS (her #169(a)):** the per-book archived line on the Arrivals idiom (invisible when empty; Unarchive + Remove/Release), archived waiters visible and seatable at the door, the Index never shows them. **The tutorial's books chapter** carries §25's eleven lessons + five rituals (lesson 9's delete-guard sentence withheld until 13i-e ships the guard — P-6).
- **The 17y + librarywalkpolish contract lines (2026-10-05/06 — `notes/plans/17y-sitting-rulings-2026-10-05.md`, the 17y RUN RECORD in `notes/plans/phase-17-standing-fixes.md`, `notes/plans/librarywalkpolish.md`):** a book's ARRIVALS live on the masthead ICON beside its settings gear — calm when nothing waits, present when something does; the ONE word is "Arrivals" everywhere it speaks (R-17y-1/2 — the content-top door line's idiom is retired); a waiting row OPENS the note read-normal, and opening never seats. The Library's card view is named **"Cards"** (item (d)) and **always shows notes**: picking Cards moves the scope to Notes, and a non-Notes scope picked inside Cards returns the view to List (R-LWP-6, generalized at her word). The chapterless group reads **"unfiled"** everywhere (R-17y-4). The app's ONE WING FOLLOWS the focused pane's note on open and on focus, with the quiet "Now in …" receipt (her (f) ruling); cross-wing Open rows wear the wing indicator. A book-row drag presents a TITLE CHIP riding under the cursor (R-LWP-3), and a drop outline lights only where the drop would act (§12's own false-offer rule applied across the headers, the strip names and the starred word).
- **The NOTE mode row: Write · Takes · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘7, derived from the one order; **in RELEASE the row is SIX modes ⌘1–⌘6 — Canvas is Debug-only: 17y (p), her "debug-only ratified"; the 17y B2 RECORD, P-17y-B2-7/#184(g)**). **A note FIRST OPENS in WRITE, with per-post MODE memory (local, persistent, per note — S4-20's contract, `notes/plans/phase-13b-make-it-work.md`)**; this line's old "Takes … the first-open default" wording was STALE and corrected 2026-10-06 (VR-122's J-17 — the shipped code and the guide both say Write; a doc-accuracy fix, never a behavior change). Takes = single-column fan work (its article REMEMBERS the row at the top per note for the session; an entry landing outranks the memory when the note's current block changed — 17q). **NOTE-OPEN (R-18l-1, 2026-09-26, 18l U0c — her ruling + #150's provisional refinements): the session's FIRST open of a note shows the START in every mode (superseding the open-at-remembered-caret rule for the note-OPEN act only); an in-session RE-open restores the page she left, never revealing an off-page caret; deep links keep their targets. The binding record is `notes/plans/phase-18l-navigation-feel.md`.** Read carries an in-place `edit · read` switch opening on `edit` (the editable index surface with the `▸ 01` outline column; P3's one live editor through `PaneTextAuthority`) and `read` (the calm page, continuous or paged; a sentence click flips to `edit` at that block through `LandingTarget`). Lenses = the editable multi-column editor, ALL lens machinery's one home. Compare holds Outline. Blocks = the power-user workbench (multi-select, bulk bar, context panel). Canvas = a VIEW on a post or the scraps area (spatial arrangement + the minimal one-take switcher; movement free; the switcher view-local) — **Debug-only since 17y (p): off in Release, the Snippets area's Canvas face and its other doors included.**
- **The BOOK's mode row: Outline · Index · Book · Read** — Index editable in place; Read read-only; the focused note's controls live in the SIDEBAR'S NOTE BOX (three states: none · selected · live), the details gutter retired (18d); the navigator, Index's chapter panel and Read's contents column are draggable leading columns (`SideColumn`) with remembered widths; note lengths remembered per note in a LOCAL-ONLY store.
- **The editor language:** boundaries invisible at rest, dotted seams on a global toggle; the editing indicator a setting (off · outline · background); **comments and callouts render in the whitespace GUTTER outside the text area on every surface, stacked vertically, and the prose column's measure and left edge NEVER move for a decoration** (R-13u3-3, pinned per surface); the inline-tinted comment strips are an opt-in; comment EDITING lives in the panel; a callout's leading glyph is one grapheme; sacred margins; everything visible in an editing surface is editable. Takes presentations: tinted cards, "✓ chosen", ONE live-editor ring, the changing-block wash (default on), the short-block strip, follow-the-scroll in all modes; an empty block in Takes is an empty line.
- **The two ceremony sheets** — Divide choosing takes · Merge choosing takes — open on a preset row (§9), real prose side by side, the ✂ overlaid on the inter-word gap (18f).
- **Messages carry a KIND on the one status seam — refusal · offer · receipt** — decided at the door; the synced `receipt_style` (toast · quiet · off, quiet by default) governs RECEIPTS ONLY, rendered as a muted line at the bottom bar's trailing end; refusals and offers always toast (18i). **An AI write's line is a RECEIPT that CARRIES a one-press door — "Open ›" — with the session-scoped keyboard road "Show the AI's Last Change" (⌥⌘O) alive past the fade and under receipt_style off (R-13nb-27, her ratification 2026-10-10 — the door does not reclassify the line into an offer).** A door that did nothing speaks a refusal.
- **No popup greets a first open; the app's own asks (updates, the backup folder) wait for days of use and calm moments, and are always answerable in Settings** (R-13r-11/12; the cadence and the rulings are the 13r plan's — `notes/plans/phase-13r-distribution.md`; ruled canon at the 2026-10-04 post-close sitting).
- **FIRST OPEN, THE OFFER AND THE TOUR (13s-b, 2026-10-08, `notes/plans/phase-13s-voice-onboarding.md` — the rulings R-13s-1…42; VX-7):** a fresh store opens with NO popup (the calm-asks line above untouched): the Bookcase, quick entry at its foot (R-13s-3), and the ONE quiet offer line in her approved words with its retire-forever local flag (R-13s-6/13) — press it or ignore it forever. **Study is the fresh-store voice default** (a voiceless store adopts Study; existing stores keep their voice). The faithful two-tone V is the app's face — AppIcon in every appearance (dark/tinted wear the white-on-black edition), About, the offer mark (R-13s-24/25). **THE TOUR:** a pure-rule engine with ring + cards and NO dimming ever; the 22 approved frames verbatim (three build-verified adaptations, recorded); an off-target act re-anchors with the road-back line; Help ▸ Take the Tour re-enters any time; the end card's readme aside asks the store whether the readme still exists before speaking. The tour is Mac-only.
- **THE COMMIT VOCABULARY (13s-b U4 — R-13s-31/32; VX-103):** the app says **commit** everywhere a savepoint was named (Block History “Commits”, Settings ▸ Writing, ⌘/, receipts, the phone — 46 strings, both platforms, the label-fence verified); the sentences that DEFINE commit say “saved moment” (P-U4-1 — her open taste call, QUESTIONS #206); two ruled survivals stand (the tour's and the guide's one exemplar “savepoint” each).
- **THE SEED SET (13s-b U1b — R-13s-36/37/38/39):** launch = the field guide + sherlock (OWNED) + the empty starred notes + the disclaimer snippet; “journal” and “quicknotes” mint ON DEMAND, lowercase — mint-time defaults only, existing stores never renamed; Encryption Explained is GONE and UNRESTORABLE (door removed); the classics gain a restore door; jekyll's door fully lowercase; the readme placeholder carries her Start Here text with REAL fans (the finished text = VX-105, hers).
- **The BOOK SETTINGS sheet (13i-c U3; the same pane for a book and a gathering)** carries the COLLECTING section as sentences ("Gathers from: …" · "New matches: …" · "Notes written here are tagged: …") with ONE Edit… door into the rule editor (whose auto-tag row is the OUTFLOW CHOOSER — several tags, any, none), a gathering's three-state hide-owned row, and the STATE doors — Finished (the confirm carries §24's "N waiting at the door will be dismissed" only when N > 0), Seal… (the confirm LISTS the notes that fork; "nothing needs copying" on an owned book; sealing finishes too) / Unseal (reopens), Own Its Notes… (the confirm LISTS the copies) / Stop Owning. The mint door requires a rule (the editor inline); a gathering's empty save refuses and offers Delete. **The MEMBERSHIP CHOICE sheet (13i-c U4)** opens from every add road an ownership refusal reaches (the chip, the drops, Manage Notes, the Arrivals arms — Copy in · Move in · Dismiss, with "owned by"/"also in" lines): Copy in / Move in (the severed books listed) or Copy in only, the edit law said at the door. **Delete** asks on every book; an OWNED book offers two choices (book only → the Pool · book and its N notes → the Trash, returning whole). **Duplicate Book…** shallow or with copies (owned: copies only). **Remove from this book** reads **Release** on an owned book; a gathering offers "remove #tag". **The BADGE family** (one switch, `ownership_badges`): the shared mark inside a book (hover names the books), "owned by “X”" outside it (click-through opens the book at the note); the navigator chip reads sealed. The Trash row says "and N notes"; Put back's receipt says it came back whole.
- **This Note's Tray:** Leaving · Archived views with a shared blocks/takes filter; released originals surface per note and behind their successors' lineage doors (the global unplaced-blocks listing is retired as a user surface; `Queries.unplacedBlocks` is the debug net).
- **IMPORT & COPY FULL TEXT (13n-a, 2026-10-09 — the MCP door's Level 0; the plan file is the record):** File ▸ Import… and the Bookcase drop read the Variorum document format (a file → a Pool note; a folder → a book; the drop is a CONTEXT MINT onto the solo'd shelf and lights its outline only where the drop would act); refusals name folder, file and line; receipts carry the counts and ⌥⌘Z, rendered at the main column's page foot on book surfaces (`BookNoteBox.quietReceiptHome` — PROVISIONAL placement rule, the walk's WA-1). **Copy full text** (note ▾ menus + ⌘K; renamed from "Copy for AI" at her review — "I'd rather not have 'for AI' on a button") puts the note on the clipboard in the same format, receipt "Copied full text."; the format's one home is `Domain/VariorumDocument` (the export is its client). Commits and book settings deliberately do not ride the text form — the full-fidelity tier stays 13m's edition (R-13n-8).
- **THE MCP DOOR (13n-b, 2026-10-10 — Level 2; the record `notes/plans/phase-13n-b-mcp-door.md`: the sitting records R-13nb-1…28 verbatim + the architect rulings AF-1…AF-11. GROWN at 13n-c — MCP LAUNCH READINESS, 2026-10-11/12; the record `notes/plans/phase-13n-c-mcp-launch-readiness.md`: the Air sitting R-AIR-1…15, her eight sitting rounds, U1–U6, the combined fable ladder + the UX-fix opus ladder, the Opus UX walk):** an AI client reaches the store ONLY through the in-app MCP server — a unix socket in the app's container behind the protocol-blind `variorum-mcp` stdio shim (SDK pinned exact), alive only while the app runs with the pane's switch ON; **setup is the per-client SETUP MENU (13n-c U5, R-AIR-13: Claude Code · Codex · any MCP client's JSON; "a standard MCP stdio server at one binary path" said in the pane).** **Grants are LOCAL-ONLY (v1_24), per CLIENT × SCOPE (note · book · wing) on FOUR CUMULATIVE RUNGS — read · suggest · write new · edit — and the rung is the ONLY read dial (R-13nb-17);** durations **once** (ONE write call, spent atomically inside the act's transaction) · **while connected** (NAME-scoped: later sessions under the name count, it ends at the last live session's close or the server's stop, nothing re-mints on reconnect — the advice states this exact meaning; faces say "until it disconnects", P-13nc-U4-1 ruled) · **always** (standing; VX-162 — never offered on the fence, the why said); the just-in-time ask queues quietly. **The fence (R-AIR-1's keys, 13n-c U1 — superseding AF-6's fenced clause, the plan's U1 adjudications):** the daily Journal's entries, ⌘J entries (D-1: per-ask wherever filed), and anything wearing the Private mark — its own or through a live Private book — answer only a per-ask note grant; everything unreachable answers ONE uniform not-shared shape — no fenced-vs-unshared oracle anywhere, for BOOKS too (F-7), down to the byte-identical beyond-grant lineage stub (P-13nb-U4-7); a LIVE per-ask grant holder asking past its rung hears `rungTooLow` + the asked sentence (R2-6). Every write is one of §9's operations with the grant guard INSIDE the op's own transaction and ONE client-named undo entry (⌥⌘Z speaks the client's name); edit_take brackets with the EIGHTH auto-commit occasion ("before/after <client>'s edit", deduped, +1 ms after-stamp); **an agent-written book rule BELLS, never backfill-seats** (the U4 ladder's MAJOR — a rule write must not expand the writer's own reach; P-13nb-U4-16, her Save untouched). `show_in_app` is read-rung, never spends a once grant, moves ONLY while Variorum is frontmost in a full window, refuses honestly, never queues or raises windows (R-13nb-23/26g — her etiquette as law) — **and since 13n-c it takes a WING target, delivered as her switcher's own act ("Now in “X” — ‹client› showed you this wing.")**. **13n-c's faces and wire (R-AIR-1…15 as built; the UX walk's dispositions + the two ladders' records):** the GRANT ROAD is every place sharing is read — ⌥⌘A, the note ▾ / row menus, the Library's bulk door ("Share N notes with AI…", ONE act on one stamp) — all opening THE one grant sheet (WHERE = **a note · a book · a wing** on the one sectioned `SearchPicker`; fenced picks offer only honest durations with the one-line why); **APPROVAL IS ALONE** (W-UX-2 ruled: approving admits the client with ZERO reach, nothing pre-picked, Always never a default); **every Shared-with-AI row carries Change… beside Revoke** (W-UX-19 ruled — the receipt's pre-filled REPLACE sheet, one grant or a whole act; a GONE target keeps Revoke only); the pane's section title is **"Shared with AI"** (her in-pane carve-out to R-AIR-8); the Bookcase shared icon + the in-note indicator (ContextBar trailing) read standing reach, their popovers naming the why with Change…/Revoke (a wider grant's Revoke names the grant it takes); **ASKS WAIT quietly** (the `questionmark.bubble` pending marks, the pane's Waiting section, Esc = Don't allow, an answered ask never re-presents, a gone place's ask says so where she pressed); **⌘L is the wing switcher** (a sheet, no counts; with ONE wing it SPEAKS the ruled note); **`move_note_to_wing` rides the wire** (EDIT on the note + WRITE NEW on the destination wing, both sides decided, once grants of both spent together; ONE client-named undo whose replay is OBSOLETE-quiet when EITHER of the entry's wings — stood-in or the note's current — has died, and REFUSES keeping the entry when the note gained books/tags since, the way through said; the §9 rider: the MCP road wraps her undo-less per-note wing move with this entry — her own door stays undo-less); **a wing grant (or the open book) reads its wing's GATHERINGS as facts** (listed, assembled, searched, shown — never a grant's scope or a write's target; R-AIR-12); **Activity speaks every act in words, never a tool id** (refusals name the side that refused); the docs are TWO-LAYERED — the field guide's MCP chapter (seven lessons, her ruled "how to use it" recipes sixth) for the human, `MCPSession.instructions` (≤2,000 characters, truth-pinned, provider-neutral) + the tool descriptions for the model. The pane: per-client grant rows (counts say "grants"), the activity log, Allow-AI-here (renders only with ≥1 approved client), the client row's Deny…-with-confirm; A-4's honest boundary (client identity is self-declared and the pane says so — the per-setup secret is VX-168, pre-launch). Level 0 is 13n-a's format; Level 3 (chat) stays deferred.
- **The reference panel** (§7 `reference`), the badge behavior (a corner badge only on fanned blocks), export (a callout → blockquote), the Shortcuts & Dictionary helper, the keyboard family (⌘[/⌘] indent, ⌥⌘[/⌥⌘] back-forward — PROVISIONAL #130; ⌥⌘Z / ⇧⌥⌘Z structural undo/redo; ⇧⏎ in-block newline; the merge chord said on every face from the capability registry).
- **SEARCH — the one finder (13o, 2026-10-07; the rulings R-13o-1…15 + §FORK RULINGS + §U3 RULINGS in `notes/plans/phase-13o-search.md`):** full body-text search over the LIVING corpus (all live active takes, titles + worn display dates by query-time date parse, scraps, comments, names/labels; versions fenced; archived behind one facet; savepoints IN behind the one explicit **`+ commits`** facet — VX-83/VX-72, R-VX83-5/9/10: the chip's word is "commits", lines read "commit · <day>", counts "N commits", and a savepoint NEVER lists without the facet; the Trash deliberately out, VX-93's someday as search INSIDE the Trash), on a local-only derived FTS5 index, accent- and case-folding (the deliberate third sameness rule — the Write/Takes bars keep their pinned pair). The Library field is THE finder wearing direction C's ANSWER SHEET (the band's honest counts + quiet chips, passages grouped under their notes, every "all N ›" a real road — no capped listing anywhere); ⌘K carries passages under its title hits; the **when ▾** door is ONE calendar popover (direction 1, R-VX83-2: the mode row on a day · between days, a voiced month grid, the armed SENTENCE at the foot as the confirmation; NOTHING arms until a day is pressed — P-13o-U2-9 superseded for this door; between days is two presses with the run washing in; `any day` clears); a book's masthead rests as a bare 🔍 expanding to the same engine scoped in place (gatherings searchable through the ONE membership function); `#tag` surfaces the books it flows into, top-ranked with the reason said — and a `#tag` ALONE narrows the Library to the tagged notes as its OWN listing rows (sort ▾ and scope live, the Blocks scope by block-level tags, the archived facet's rows marked; R-VX83-1 superseding P-13o-U2-6), while a plain word NAMING a tag offers it as a one-press chip (`tag: #name ›` — the explicit-tag doctrine, her words on the record); the mode facets (gathering · living · owned · finished · sealed) are facts, never tags; the Library incl. its search is hide-owned-EXEMPT, owned notes badged; wings isolate totally with scraps the one ratified shared room; clicking any passage lands in Write at the block with the match selected and the find bar armed (⌘G steps on) — the needle is the snippet's first CONTIGUOUS matched span (whitespace and ≤2-character non-newline gaps coalesce, kept as written — VX-86 + P-VX83-W2) and the landing rests in the comfort band below the shown bar (VX-85). Search scales ∝ matches, never corpus (P1 pinned). The follow-up run's record: `notes/plans/fixes/vx-83-search-followup.md` (her first-use report; rulings R-VX83-1…10).
- **LIBRARY PORTABILITY (13x, 2026-10-08; the sitting rulings + the restore-hold ruling + four ladder rounds in `notes/plans/phase-13x-library-portability.md`):** **File ▸ Send Library to Another Mac…** (and its Data Safety twin) writes a FOLDER PAIR — a sealed snapshot + its key file — to a chosen folder, to AirDrop whole; **File ▸ Open Library…** (and the welcome/absent-store/waiting faces) classifies what was picked (a pair · a backup pair · a plaintext export · a keyless file ⇒ the honest refusal), unlocks by the lobby's roads, CONFIRMS, then adopts: the current library and its key files step aside whole into `Previous Libraries/<stamp>/` beside it after an A1-shaped safety copy, the copy lands (its WAL tail included; the picked file is never written — every read runs on a private staged copy), and custody adopts the key that opens the landed file (the collision rule). Settings ▸ Data Safety's **Restore from Backup** lists the backup folder's pairs, each saying which credential opens it (decision 11). **THE RESTORE HOLD (her round-3 ruling):** an adopted library lands HELD — no sync round, flush or rotation ceremony runs until the ONE **Resume Sync** press in the standing banner, which then catches up to the account (the gates read the marker beside the store); a copy never carries the sync key or device identity, so a Mac new to a library enrolls. The live library is never placed in iCloud Drive (the picker's guard). A key file still Apple-wrapped under a Castle account surfaces the follow notice (`castleKeyFileAppleOpenable`). Zero schema; marker 12.
- **Capture microsyntax** (R-13u4-1): `{#tag/path}` applies the tag (smart-book rules do the rest), `{t:"…"}` titles; only braced forms parse; tokens disappear (`Shared/CaptureMicrosyntax`, both Mac doors; the phone's face is the mobile catch-up's).

The views the model must support beyond today's surface (side-by-side, swap-and-reread, diff with optional whitespace normalization, infinite scroll, timeline as a Library view mode, the collapsible block index) are capabilities, built functional first; the UI is iterated with the author.

## 13. Build order

`notes/DetailedPlanForPhases.md` governs (product advancement only; fixes live in `notes/plans/phase-17-standing-fixes.md`). Summary shape: substrate (schema → operations → queries) → editor core → structural gestures → readings + views → hardening → the UI design passes with the author → sync → accounts → the mobile app (its own project) → web.

## 14. Resolutions & deltas from the source SPEC

Resolved (source SPEC §14 open questions): 1. single-variant divide in place ✔ · 2. unified `container` ✔ · 3. tagging as two tables with real FKs (deliberate schema delta) ✔ · 4. cascades as triggers; no variant→commit_point cascade ✔ · 5. the sync engine decided up front — hand-rolled row sync; PowerSync-class engines rejected (SyncSpec §1) ✔ · 6. pool-copy scope: active variant by default, `includeFan` from day one ✔ · 7. churn metric: characters, inserts + deletes equal weight ✔ · 8. headings are Markdown text, no column ✔ · 9. `default_variant_id` lifecycle (§9) ✔ · 10. edge directionality: source = descendant ✔ · 11. fractional-index positions, no rebalance ✔. Additional deltas: live-row partial unique indexes everywhere; I10 added; `chosen_variant_id` fallback semantics; the concretized stack.

**The dated delta record (Phase 0 → 13u4) lives in `notes/AppSpecDeltaArchive.md` and, for the pre-split narrative, `notes/AppSpecRulingsArchive.md` §14.** The closeout rule since 2026-09-26: a phase's canon delta lands in this document as a CONTRACT line (what is now true) plus a pointer to the plan file that carries the ruling — never a paragraph of history. **Most recent phase with canon deltas — 13n-c (VX-165, 2026-10-12, `notes/plans/phase-13n-c-mcp-launch-readiness.md` — MCP LAUNCH READINESS; the Air sitting R-AIR-1…15 + her eight live sitting rounds recorded verbatim in the plan; units U1–U6 each real-client-verified; the combined fable ladder CLOSED CLEAN at R2 (R1: 0B/0M/1m/2n, F-1…F-25 all concur — the owed Fable span discharged; R2: 0B/0M/1m/2n); the Opus UX walk (18 findings, 1 bug) + its fix pass; the UX-fix opus ladder CLOSED at R1 (0B/0M/4m/2n, all six fixed red-first)):** §12's THE MCP DOOR line GROWN (the fence re-keyed to R-AIR-1's keys with AF-6's fenced clause superseded + `rungTooLow` for live per-ask holders; the THREE durations incl. always and while-connected's exact name-scoped meaning; the per-client setup menu replacing "Copy setup command"; the grant road + the one sectioned picker; approve-alone and Change…-beside-Revoke as ruled; asks-wait + ⌘L; `move_note_to_wing` on the wire with the obsolete-quiet/refuse-keep replay letters; `show_in_app`'s wing target; gatherings as facts under a wing grant; Activity in words; the two-layer docs); §7's v1_25 bullet re-keyed (the per-ask fence). Zero schema, marker 13 untouched, zero lockstep, zero `Sync/` lines, zero editor seam. Finals: core 2,636/301 · VariorumMCPTests 93/14 · workbook 40/6 headless; the fix-pass whole Mac run 1,768/273 (the one red VX-115's standing) + the fix-leg batch 977/146 green. The ratify bundle at QUESTIONS #212; born VX-175/VX-176; U8 fell out to VX-168 (pre-launch gate, riders VX-169/VX-172/VX-170 at her word) and U7 out of the launch (VX-159). Before it — 13n-b (VX-124, 2026-10-10, `notes/plans/phase-13n-b-mcp-door.md` — THE MCP DOOR, Level 2, architect shape; the sitting records R-13nb-1…28 verbatim + the architect rulings AF-1…AF-11; FOUR units, each with a real-client live round and a cross-model fable-reviewer ladder CLOSED CLEAN at round 2; closed overnight under R-13nb-28's mandate, the deploy authorized by her amendment):** §7's Private-mark synced columns (v1_25 — THE ONE LOCKSTEP EVENT, marker 12→13, mirror artifact 16; the SyncSpec §12 window record carries the deploy) + §7's local-only MCP grants family (v1_24, zero lockstep); §12's THE MCP DOOR contract line; §12's message-KIND line amended per R-13nb-27 (RATIFIED mid-phase — an AI write line is a receipt that carries a door). The U4 ladder's MAJOR closed structurally (agent rule writes bell — P-13nb-U4-16, her bundle). Finals: core 2,580/295 · VariorumMCPTests 65/8 · workbook 40/6 headless + the closeout whole-target Mac run (the plan's ledger); the ratify bundle at QUESTIONS #209; born VX-127…134 and the four read-reach follow-ons VX-145…148. Zero editor seam; `Sync/` lines architect-only (AF-4). Before it — 13n-a (VX-117, 2026-10-09, `notes/plans/phase-13n-a-document-format.md` — the overnight build under her provisional mandate; the sitting record `phase-13n-sitting-record-2026-10-09.md` R-13n-1…11 + the architect rulings R-ARCH-13na-1…3; the two-round ladder + the W1–W7 walk):** §9's importDocument/importBook line; §12's IMPORT & COPY FULL TEXT line; the 13n resequencing (pre-launch, before 13s-a — the master plan's 2026-10-09 amendment). Zero schema, marker 12, zero lockstep, zero `Sync/`. Core finals 2,478/284 + 40/6; the ratify bundle at QUESTIONS #208; tickets VX-118…123 born. Before it — 13s-b (VX-7, 2026-10-08, `notes/plans/phase-13s-voice-onboarding.md` — the rulings R-13s-1…42 accumulated through her overnight R-13s-35/40 mandate; five units U1a/U2/U1b/U4/the field-guide landing, each laddered; one extra whole-phase Opus pass at her grant, 0B/0M/3m/4n all closed):** §12's FIRST OPEN/TOUR + COMMIT VOCABULARY + SEED SET contract lines; the Two-voices bullet's Study fresh-store default; §9's `ensureWelcomeShelf` correction (the R-13s-37 set). Zero schema, marker 12 untouched, ZERO `Sync/` lines in the seed itself. The closeout whole-target run closed the Study-default harness class (`TerminalMetricsPin`) and found VX-115 red-on-main. Finals: the whole VariorumTests target 4,164/682 (the one red VX-115's, + 5 known-issue records); core on the merged tree 2,426/280 + 40/6. The ratify bundle at QUESTIONS #206. Before it — VX-83 (a RUN, 2026-10-08, `notes/plans/fixes/vx-83-search-followup.md` — her first-use report on 13o, the sitting rulings R-VX83-1…10 incl. the VX-72 split and the merge-order freeing, the two walk judgments, the two-round ladder `notes/plans/fixes/vx-83-ladder-r1.md`): §7's NINTH derived kind + `search_doc.variant_id` (v1_23_savepoint_search — local-only, zero lockstep, marker stays 12); §12's SEARCH line gains the `+ commits` facet (the never-lists-without-it fence), the tag-alone narrowed listing + the offer chip (the explicit-tag doctrine; P-13o-U2-6 superseded), the when-door calendar popover (no silent arm; P-13o-U2-9 superseded for this door), and the contiguous-span needle + banded landing. Members VX-84…89 + VX-72 + VX-94 closed inside it; VX-90/93/98 shaped beside it. The ladder: R1 0B/0M/1 MINOR/2 NIT (three AGREEs, zero disputes, the reviewer's own fix pass with red-on-old evidence each) + R2 CLEAN BILL. Core finals 2,383/277 + 40/6 on the merged tree; the closeout Mac batch 448/64 zero-skipped (e933879b's every-changed-source-file rule) + the order-sensitive suite alone 12/12. The ratify bundle at QUESTIONS #203.**  *(The 13x entry rolled to `notes/AppSpecDeltaArchive.md` at the 13n-c closeout, 2026-10-12; the 13o entry rolled there at the 13n-b closeout, 2026-10-10; the 13r entry rolled there at the 13n-a closeout, 2026-10-09; the 13i-e entry rolled there at the 13s-b closeout, 2026-10-08; the 13i-d entry rolled there at the VX-83 closeout, 2026-10-08; the 13i-c entry rolled there at the 13x closeout, 2026-10-08; the 18l-c and 18l-first-half entries rolled to `notes/AppSpecDeltaArchive.md` at the 13r post-close sitting, 2026-10-04.)*

## 15. Risk register (standing risks and why; deferred WORK is `KnownIssuesAndTechDebt.md`)

1. **Live block-identity maintenance over `NSTextStorage`** — the single riskiest thing in the project: identity is maintained DURING editing (block IDs as attributes, exact changed ranges), never recovered by diffing. Hence headless operations first, editor phases of their own, pure boundary snapping, and the per-keystroke identity oracle in DEBUG. If an editor bug corrupts identity, the store is still safe — operations validate against the DB.
2. **TextKit 2 viewport/height/scroll-to-location** is the least reliable subsystem of the chosen stack and shifts between point releases. Live geometry was adopted after the Phase 6 spike; what survives is re-verifying after every macOS update (`notes/TEXTKIT2_NOTES.md` §5 — its §3 records each release's measured deltas).
3. **Hand-rolled sync** — chosen with eyes open because the engines fail this schema harder; the protection is the two-client fake-server harness and the convergence suites (any sync change without a convergence test is unreviewed; `notes/sync-postmortem-fragments.md` before touching `Sync/`).
4. **Resolved interpretations:** structural undo (not global undo); the reference panel (not a knowledge base).
5. **Decisions that must not silently regress:** jittered fractional-index positions (never REAL midpoints); live-row partial unique indexes (never bare UNIQUE); trigger-fed outbox capture; `server_seq` as the only ordering authority.
6. **Toolchain skew:** any second machine or CI must match the primary's Xcode major before its results count.

## 16. Still genuinely open

Phase 13's typographic PDF export · an optional derived audit/operation log · the UI, iterated with the author.
