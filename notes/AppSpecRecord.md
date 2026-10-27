# Variorum — App Spec RECORD (the living, appended record — NOT context-loaded)

**What this file is (her ruling 2026-10-18, VX-420).** This is the old `AppSpec.md` format continued: the dated record of every ruling with HER RULING and its date, her verbatim words, the ladder findings and tallies, the supersession histories, the cast and merge order of every effort. It is CANON — every ruling here binds — and it is where a session appends its entry at closeout, in the format below (§14's dated entries, the per-op and per-surface narrative under the same section numbers). **Nothing ever rolls out of this file**: ask it what happened in any phase and it answers in full. Sessions do not load it; they read it when they need the why behind a rule, and they write to it at every closeout. The LOADED spec is `notes/AppSpec.md` — a plain statement of what is true now, same section numbers, one pointer per rule cluster (into this file, a plan file, or a ruling id). The frozen earlier editions are `notes/AppSpecRulingsArchive.md` (pre-2026-09-26, and the 2026-10-18 pre-VX-419 edition of §7/§9/§12/§14 — identical to the text below) and `notes/AppSpecDeltaArchive.md` (the §14 entries rolled out between 2026-08-01 and 2026-10-18). Below: the file byte-verbatim as it stood before VX-419 (commit `78afd9d9c`), followed by the entries appended since.

---

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
> No uniqueness (no repair class). Comment `text` is metadata under sync (server-wins CAS), deliberately not S5. Deleted comments stay visible and resurrectable — until deleted forever: `block_comment` is the SIXTH purgeable kind on the 13j purge road (VX-179; tombstoned rows only, a dead block's comment refuses as a cascade victim, a sealed post refuses — P-VX179-U1-1). Travel across structural ops is the operations layer's (§9), never a trigger's.

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
Later synced additions: `canvas_layout`, `lens`/`lens_choice` (11a), `purge_intent` (13j), and the 13n-b PRIVATE MARK (v1_25 — THE marker-12→13 lockstep event, `Server/supabase/16_phase13nb_private.sql`): `container.ai_private_at` + `reading.ai_private_at`, nullable PLAIN timestamps (structure only on the wire — that something is marked, never which words), the AI-private fence's store truth (R-13nb-4, re-keyed PER-ASK at 13n-c by VX-163; privacy wins ties, Private ⊥ Owned, gatherings refuse the mark) — see the migrations and SyncSpec §12's lockstep record. **Local-only DERIVED (13o, v1_22–v1_23 — never synced, no mirror, marker untouched): the search-index family** (`search_doc` + the `search_fts` external-content FTS5 table over the `search_text` view + shadows), maintained by the third trigger duty, rebuildable from truth (`Operations.rebuildSearchIndex`/`verifySearchIndex`), registered as `SyncSchema.derivedTables` — subtracted by the completeness walk, KEPT by the plaintext export so the no-lock-in file searches by itself (the 13o §FORK RULINGS); since v1_23 (VX-83) savepoints (`commit_point.text`) are the NINTH kind, listed only under the explicit commits facet (R-13o-6), `search_doc.variant_id` the savepoint doc's own-row parent fact and liveness resolving at QUERY time through variant → block → placement (`notes/plans/fixes/vx-83-search-followup.md`). **Local-only, never synced (13n-b, v1_24 → v1_29 — marker 13 untouched, zero lockstep throughout): the MCP GRANTS family** — per-client × per-scope grant rows (the four rungs), the open-book switch and the activity log, the door's LOCAL truth, decided per call by the pure `Domain/MCPGrantRule` (`notes/plans/phase-13n-b-mcp-door.md`); grown by VX-168 (v1_26: the PER-SETUP KEY pair — `mcp_setup_key`, a copied setup's key by hash until a name presents it, + `mcp_client.setup_key_hash`, the key bound to the name), VX-184 (v1_27: `mcp_comment_author` — a comment's writing client, by comment id, written in the comment's own transaction, so a SUGGEST client may delete only its OWN comments, R-VX188-1; no FK, purge-safe, the export strips it) and VX-246 (v1_28: `mcp_rebind_request` — a setup key waiting for her OK under an approved name, one row per client, the newer replacing the older, the key's hash never the key plus the declared version, dropped by her Allow — which binds it — her Don't allow, a Deny or an adopted library; v1_29: `mcp_comment_author.text_digest` — a comment stays the client's own only while its words are unchanged; NULL, every pre-v1_29 record, reads as unproven); and VX-348 (v1_30: ONE STANDING GRANT ROW PER CLIENT × PLACE — R-VX348-6, upgrade-in-place: a new grant replaces the pair's row on every road, existing duplicates merged to the strongest rung by the local migration, a partial unique index making the store refuse a second standing row; once grants outside the rule); the records are the vx-168 · vx-184 · vx-246 · vx-348 fix files under `notes/plans/fixes/`.

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
- **Quiet auto-commit occasions** (`kind='auto'`, deduped against the take's last savepoint when the text is unchanged): sealing a post; locking a dirty take; the idle backstop (`idle_commit_hours`, default 2 — `idleAutoCommit(post)`, at most one per idle period); a structural undo about to overwrite a buffer edited since the operation; `closeAutoCommit` when a note with unsaved changes stops being shown (the everyday cadence, 13j); a cross-block compound about to overwrite the takes it edits (`insureTakes`, 13u1); `moveSpanToNewTake`'s pre-move insurance; and the MCP door's `edit_take` bracket — the EIGHTH occasion ("before/after ‹client›'s edit", deduped, +1 ms after-stamp; `notes/MCPSpec.md`). `savepoint_cadence` governs the two CADENCE occasions (close, idle) only; the insurance occasions are always on. (The Fragments-bridge landing occasion retired 2026-09-04.)
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
- **deleteBlock(block, requiring: precondition = .none)** — tombstone block + placement; set `last_container_id`; trigger-cascade tombstones variants, comments, edges. `.none` is the ordinary door; **`.emptyWithNothingUnshown(variantID:)`** is the seam-backspace carve's authorization, RE-CHECKED INSIDE the tombstone's transaction (the named variant must be the block's ONE live variant, active, unlocked, empty, under an unsealed post, with no live comment; else `blockCarriesUnshownText` / `bufferChangedSinceGesture`) — a caller-side check would read the editor's deliberately-stale projection. The same precondition rides the structural redo. **The carve's caret lands where the deleted line break was** — at the end of the block before it when the carved block sat after the separator, else at the start of the block after it (VX-290; her report is the ruling, QUESTIONS #33(d) still decides WHICH block goes); Delete Block and archive keep their own landing (the start of the block below, else the end of the block above).
- **restoreBlock(block)** — clear the block's tombstone and those of children carrying the SAME `deleted_at` stamp (cascade victims; independently-deleted rows stay dead); then `placeBlock` into `last_container_id`. A tag application revives only if its tag is live.
- **restoreContainer(container)** — the same exact-stamp rule over placements, their blocks and children, memberships, post tags, references. Rows whose story diverged stay as they are (a block independently revived keeps its current placement; a membership whose reading died stays dead).
- **restoreReading(reading)** (S4-28.2 — readings DO have a restore door) — exact-stamp revival of its chapters and memberships; a membership whose post has since died stays dead; assignments reattach for free; smart readings restore by the flip alone; refuses when live. No undo entry (the door is the recovery). Documented corner: a member post that died AFTER its reading is left out — add it back by hand.
- **Structural undo / redo** — session-scoped, in-memory, structural ops only: divide (all forms), merge (both forms), extract, newBlock, deleteBlock, deleteVariant, archiveVariant, moveBlock, reorder, poolDragCopy, moveSpanToNewTake, **deleteTag** (VX-381: ONE "Delete Tag" entry — the inverse revives the subtree's tag rows with paths REBUILT from the live parent, plus their applications dead on the delete's exact stamp; a live same-path twin refuses `duplicateTagPath` and KEEPS the entry; the redo re-deletes by the delete's own subtree rule on a fresh stamp), the conversions and composites below. Each registration carries its inverse AND an exact-row `redo` built from do-time pre-images (never a re-run — IDs must survive undo↔redo); `register`'s `redo:` is required (nil = deliberately not redoable, and undoing past it ends the redo future). Any new structural act clears the redo future, a rolled-back compound included. Undo and redo EMIT ORDINARY OPERATIONS, so sync never learns they exist. Excluded: text editing (⌘Z stays NSTextView's), commits, locks, tag APPLICATIONS (apply/remove; the tag DELETE registers since VX-381). Doors ⌥⌘Z / ⇧⌥⌘Z (never ⌘⇧Z). A buffer edited since the operation is insured by a quiet auto commit before the inverse overwrites it. Two presses inside one flight refuse the second. **A half runs only after its partner changed something** (VX-246 U2 — VX-276 · VX-277 · VX-119; her own doors and the MCP door's entries alike): an undo that finds its act's result already gone (her undo-less door — Put back, a restore, a rename, her ✓, a lock, the rule editor's Save — or a sync apply) changes nothing and RETIRES it, leaving the other stack as it was (the Mac's door says so as a refusal naming the entry, §12's status seam); a redo re-applies exactly what its undo un-did, parts and stamps included (an entry with several parts moves only the parts its partner moved; a revive revives only rows dead on its own undo's stamp), so it never writes over a change of hers (PROVISIONAL #226: P-VX276-1…4, P-VX277-1; the record `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, whose SWEEP TABLE dispositions every registration).

**Posts, seals, extents**
- **lockPost / unlockPost** — auto-commit dirty live buffers, then UPDATE `locked`/`locked_at`. The seal refuses every authoring write under the post (edits, commits, order, chosen variants, comments, presentation, take labels, savepoint names); the post itself may still be archived, deleted, retitled, tagged and added to readings. **`resolveSyncConflict` lands even under a seal** (S5 outranks it).
- **setPostWordTarget(post, words?)** — display/progress only, NEVER a refusal; refuses non-positive; nil clears; no-op guarded; refuses under a seal (PROVISIONAL).
- **saveNoteVersion / restoreNoteVersion / promoteNoteVersion** — whole-note Versions (`notes/plans/post-13l-polish-round.md`): `saveNoteVersion` is a full family copy born archived + sealed from ONE clock read (`archived_at == created_at` IS the version classifier), no title mutation, no `entry_date`; `restoreNoteVersion` is identity-preserving — save the moment of now first, the outgoing blocks take the Delete Now road (tombstone + purge intents, never a raw DELETE), the version's family copied into the SAME container, every version link re-anchored via the classifier; `promoteNoteVersion` unarchives + unseals **and, since VX-372 (VX-383), applies the original note's CURRENT live tags through the one application road — Save Version → Promote ends as Duplicate with Tags does; still no undo entry; mobile-visible through the shared op (P-C-2, QUESTIONS #229)**. Versions ride the note's deletion on its exact stamp; a version's ONE home is Note ▸ Versions (excluded from Library, Archived and every global search by `Queries.versionHistoryPredicate`).
- **divergePostForReading(post, reading)** (13f, W23) — ONE transaction: a `duplicateAsVersion`-shaped copy; its membership at the original's exact slot (position AND `section_id`); the original's membership in THIS book tombstoned (it lives on elsewhere). Curated books only; refuses under a finished book; capacity un-gated (net zero). ONE undo entry; the redo revives the copy through `restoreContainer`'s exact-stamp path. Doors flush the pending buffer first.
- **duplicateAsVersion / promoteLens** — per-block copies carrying comments, presentation AND `block.name`; a `version_of` edge for the former. **Her duplicate is TWO doors since VX-372 (VX-383, 2026-10-17 — `notes/plans/fixes/vx-383-duplicate-note.md`): `duplicateAsVersion(_:tags:)` — Duplicate with Tags APPLIES every live tag the source wears through the one application road (`insertPostTag`), so living books hear the copy exactly as when she tags (seat · bell · capacity · ownership; P-17y-B3-c1's row copy superseded for this door), Duplicate without Tags applies none; ONE undo entry covers the copy and its seats (the container tombstone takes memberships and applications on one stamp, the redo revives them); both declared ONCE in the capability registry (⌘K, File, both `note ▾` menus, the note rows; the shipped inline doors route to with-tags) and every door speaks ONE receipt naming where the copy landed, with "Open ›"; the label "Duplicate as Version" is retired (P-C-1; the bundle QUESTIONS #229). The wire's `duplicate_note` shares the body (`notes/MCPSpec.md`).**

**Readings, chapters, tags, comments, presentation, references**
- **addPostToReading / removePostFromReading / assertReadingAcceptsPosts(reading)** — the gate (missing / wrong kind / locked / at capacity) is a standalone core read run INSIDE the serialized closure so a door can refuse BEFORE minting.
- **Event-driven INTAKE + the judgment ops (13i-b — the sitting record §4/§19/§24; the plan `notes/plans/phase-13i-b-gatherings.md`):** a LIVING book (live · `kind='book'` · readable rule · not finished) hears the APPLYING act only — `applyTag`/`setStarred` through the ONE application road — and seats (`status='member'`, END, unsectioned) or bells (`status='arrival'`) per the pure `Domain/IntakeDecision` table (capacity waits at the door; the `intake_seating` dial, NULL = join quietly; un-tag/un-star are NON-events; insert-only, tombstone-means-decided). CREATION-time backfill seats; RESUME catch-up (restore, un-finish, rule edit) bells. `lockReading` dismisses pending arrivals in its transaction. Judgment: `seatArrival` / `dismissArrival`. AUTO-TAG: `auto_tag_id`'s tag applies on mint-inside AND hand-add; `tagAllMembers` is the bulk door; removing a rule never untags. `saveFilterAsGathering(reading, filter)` mints a gathering (association ∧ filter). *(The outflow's CHOSEN multi-tag redesign is RULED and 13i-c's — an authorized §12 event.)*
- **OWNED, FINISHED, SEALED — the 13i-c op family (the sitting record §2/§5/§6/§18/§20; the plan `notes/plans/phase-13i-c-owned-finished-sealed.md` §3/§5/§6 + its U2 RECORD):** ONE pure consult, `Domain/OwnershipDecision` (an OWNED target + a note membered in another BOOK → the copy-or-move choice; a PLAIN target + a note owned elsewhere → copy only; bookless → a plain add), read by `addPostToReading` and `seatArrival` AFTER the capacity gate (`noteMemberedElsewhere` / `noteOwnedElsewhere` — the refusals that OPEN the ceremony sheet); `shelveInDailyJournalBook` BELLS on a conflict (`.waitingAtDoor`, never a throw). **`setReadingOwned(reading, true)`** — the convert door: every member also membered elsewhere FORKS IN PLACE (a full family copy takes this book's exact slot, tags RIDE the copy, the original's row here tombstoned; LISTED in the confirm); sole members own in place; refuses a gathering and a finished/sealed book; no undo entry. **`false`** lifts exclusivity, members stay. **`copyPostIntoReading`** (COPY IN: the family copy's membership first, then the outflow; one undo entry) · **`movePostIntoReading`** (MOVE IN: every other live row of the note severed — listed; refuses while a severed member sits in a finished book) — each with an `answering:` form for an arrival (the row decided member-class). **The REVIVAL PASS** (`restoreContainer`, `restoreReading`, the bind's redo, `revertDiverge`/`reapplyDiverge`): R2's shape locally — the earliest-created membership stands, a later owned-side row demotes to an arrival, a later plain-side row beside a standing claim is tombstoned; a membership revives into a SEALED book only when its note is sealed. **`sealReading`** — SEALED = Finished + text immutability (EDITION ZERO): shared members forked in place first (fork-free on an owned book), the finish (pending arrivals dismissed — the confirm's N IS the act's set, one shared predicate), `sealed_at = now`, every member sealed on that EXACT stamp (dirty buffers insured); **`unsealReading`** unseals the stamp-matched members AND REOPENS the book with the catch-up (R-13ic-3); `unlockReading` on a sealed book refuses `readingSealed`; a note's own `unlockPost` refuses `noteInSealedBook` while a live sealed book holds it. **`deleteReadingWithNotes`** — the owned book's second delete choice: the book and its member notes on ONE stamp (versions ride); **`restoreReading` returns WHOLE** (stamp-matched member notes revive first, then memberships, then the revival pass, then the catch-up). **`duplicateReading(name, deep)`** — configuration not state (rule, outflow, dial, extents, trait, chapters; born unshelved, open, non-owned); shallow = the same notes, deep = family copies; an owned source duplicates DEEP only; a gathering never duplicates. **`removePostFromReading`** returns whether the note is now bookless ("Release" on an owned book). **`setReadingOutflow(reading, tagIDs)`** — the CHOSEN set (ordered, deduped, every tag live in the book's wing; `[]` = none); `applyAutoTag` applies EVERY outflow tag on mint-inside and hand-add; `tagAllMembers(nil)` = every outflow tag. **`setReadingHideOwned(gathering, Bool?)`** — nil follows `hide_owned_default`. The membership readers (`membershipElsewhere`, the Pool's exclusion, `readingsContaining`) count BOOK rows only, live books only.
- **shelveInDailyJournalBook(post)** — puts the day's entry into THE daily Journal (since 13i-e, DERIVED from the `'daily'` marker — never the setting, which survives only as a written cache) as ordinary membership; an ARCHIVED daily Journal comes back ON EVERY PRESS — before the filing on a fresh pair, and on the decided road too (her post-close ruling 2026-10-03, the 13i-e plan's addendum: "it's fine for it to unarchive when you command J"; open-today kept; §10's "it returns when a day arrives"). NEVER throws: returns `shelved` / `alreadyDecided` / `bookFinished` / `bookAtCapacity` / `wrongKind` / `refused`. Any `reading_post` row for the pair — live OR tombstoned — means the pair is already decided (a headless round never undoes a deliberate removal). **Creates and pins the Journal when none is designated** (or the designation dangles) — curated, `profile:'journal'`, `entry_date` ascending — and ⌘J delegates its whole ensure here; it never replaces a book she designated (a finished, full or smart daily book keeps its own status). A READ-THEN-ACT composite, not one transaction (the tombstoned-row race is recorded, unpinnable without an op-level precondition). Its convergence under sync: SyncSpec §7's daily-Journal keeper repair.
- **createSection / renameSection / deleteSection / reorderSection / assignPostToSection / restoreSection** — CURATED readings only (smart refuse). A locked reading freezes chapter STRUCTURE while rename stays free. `deleteSection` tombstones only the section (memberships keep the pointer; dangle = unsectioned); `restoreSection` is one flip — refuses when live, under a locked reading, or when the section died WITH its reading (restore the reading first). No undo entry.
- **setReadingWordTarget / setReadingMaxPosts** — refuse non-positive and under a locked reading; `word_target` display only; lowering `max_posts` below membership is legal (further adds refuse).
- **convertSmartReadingToCurated(reading, order: nil)** (13c, N38 shape A — PROVISIONAL #46) — ONE transaction: the current assembly materializes as `reading_post` rows in the GIVEN order (nil = stored sort); `kind` → curated; `sort_field` → manual; `query_spec`/`grouping_tag_id` stay on the row — and the rule stays LIVE: **the bound book KEEPS COLLECTING** (the sitting record §14.6; N38-A's stop and the "(collecting)" sibling offer are retired — 13i-b). Refuses non-smart and locked. Undo AND redo; the un-bind leaves NO live row on the reverted gathering (every taken row flips to the dismissal class as it tombstones; hand-removals keep their member-class tombstones) and the redo restores each row AS WHAT IT WAS — ids AND statuses (the 13i-b plan's ladder record).
- **renameTag(tag, newName)** — rewrite `name` + the subtree's materialized `path` in one transaction (under sync, plain CAS per row — worst case a lost rename). **applyTag / removeTag** (post or block) — INSERT/tombstone; `post_tag` targets must be posts.
- **addBlockComment / editBlockComment / deleteBlockComment / restoreBlockComment** — delete is a tombstone; deleted comments visible and resurrectable (`Queries.deletedBlockComments`) — and **purgeBlockComment** is the true-delete road (VX-179): the Delete Now shape (purge intent, the 13j horizon), offered as “Delete forever…” beside Restore in the deleted fold, confirm-each-time; tombstoned comments only; `restoreBlockComment` and the MCP add_comment redo road void pending intents; the purge fence and `restoreCost`'s deleted-comment count are stamp-aware. All writes refuse under a seal (PROVISIONAL #23). **Travel:** extract/divide keep A's and COPY to the minted half; divide-W and divideDuplicating copy to B AND C; merge carries both sides'; poolDragCopy / duplicateAsVersion / promoteLens carry per-block copies. Copies are fresh owner-stamped rows preserving the source's `created_at`; DELETED comments never travel; structural undo needs no extra machinery (reverting a mint cascades the copies).
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
- **The sidebar:** Bookcase · Library · Pool · Snippets · Archived (the Bookcase name since 13i-d); the Trash door on the Library masthead. **BOOK ARCHIVE's faces (13i-e, the plan's U2 RECORD + the walk):** the ARCHIVED surface gains its BOOKS group above the notes ("kept, with no countdown" — keep-forever, never a countdown), rows Open · Unarchive · Delete Book… (NEVER Delete on the daily Journal); the archive doors render from ONE table beside Delete on every book/gathering surface — the daily Journal shows Archive IN Delete's place, its State caption §10's own sentence; the OWNED book's door asks with the delete confirm's twin (N = the not-yet-archived member set); the Collecting pane leads with the visible pause while archived; the pickers/chips/Book Panel mark "(archived)"; the receipts say what came back and what waits at Arrivals; ⌘J's comes-back speaks "The Journal is back on the Bookcase." Library = everything, with List and Notes cards carrying a muted time stamp (`TimeStampFace`), a `sort ▾` (edited · created · date · title, direction local) and the day filter (18h). **EVERY stamp speaker hovers the WHOLE fact (VX-351, her R-VX348-1/3 — glances stay calm, the exact time on hover everywhere): one wording brain (`TimeStampFace`) and one hover (`.stampHelp`) across the Library, the info panel and note box (the two former gaps — the panel's fact is the LAST TOUCH now), the Timeline, the search sheet, Arrivals/Archived, the pickers and the MCP pane; the raw-day-key drift copy is dead; the stamp-form setting is VX-389, deferred at her word.** Pool = bookless posts. Snippets = the scraps area (groups as the container noun). ⌘K palette; ⌘N = New Post; Settings (nine panes, searchable) is tag management's home.
- **THE OPEN LIST AND STARRED (VX-283, 2026-10-14/16, `notes/plans/fixes/vx-283-sidebar-library-polish.md` — her VX-285/286/287/288/289 words and her rulings on the ✕, ⇧⌘W, the follow and the fade):**
  - **Room.** The Open list grows down the sidebar to just above the sync footer, floored at 3½ rows (the sidebar's outer scroll carries the rest on a short window). Starred keeps its ~7½ rows. Both scroll bars sit in the list's own margin, clear of every ✕ and ★.
  - **Closing.** View ▸ Close Note **⇧⌘W** closes the shown note's row and lands the pane on the NEXT note in the list, else the previous, else the Library; ⌘W still closes the window. In a window merged into macOS tabs, ⇧⌘W is macOS's Close Window (her "Keep ⇧⌘W, live with it"). View ▸ Close All Notes (and the list's right-click) empties the list and lands on the Library. A row's ✕ or right-click ▸ Close on the note being shown behaves like ⇧⌘W (her "Yes, same as ⇧⌘W"); on any other row it removes only that row. Closing is view-only.
  - **Following.** Each list follows its current row ONLY on her next act (an open, ⇧⌘W, a ✕, Close All, back/forward — her "Only on your next act"). A hand scroll stops it until the next act; a resize never pulls it back; re-selecting the shown note is not an act; each section follows on its own.
  - **Edges.** An edge with more content beyond it fades. The fade is always half a row deep, its strength easing in over the row's own text padding, capped at 0.8 and never fully solid (her "The fade, reshaped").
  - **Reordering (VX-288, the light version).** An Open row drags with its title chip at the cursor. Each row is its own drop (main's per-row road): a 2-pt ring line at the targeted row's top; the drop lands before that row with a short settle; an end zone under the last row reaches the last slot; the dragged row's own place offers nothing. The chip lives only on the Open list's rows. Verified by pins and parity with main's road (synthetic drags cannot reach sidebar drops); her hand check is VX-376.
- **THE LIBRARY'S CONTROLS ROW (VX-175 — her ruling (C), P-U3-5, P-U3c-1):** search · scope / mode · sort · when compose as ONE Layout (never `ViewThatFits`), the field first. It wraps onto a second line only by STABLE widths: the field at its prompt (never its typed text), the sort slot at its widest form, each segmented picker at its natural width. So typing, a sort pick or a search never changes the line count. At the 1240-pt default the row is one line with the panel closed and two with it open, and the info panel is never pushed off. **NARROW WIDTHS (VX-350, built on this row's invariant):** below the two-line widths the field COLLAPSES to a 🔍 button — a width-class decision INSIDE the one Layout, decided at WHOLE points in both passes so placement re-decides nothing — and the open field lives on its own line (open is HER state, never the text, so typing never changes the line count); hidden controls sit off-row; the info panel's floor drops to 200 pt and the LIST gives way, never the panel; no window floor (her call, #233); the record `notes/plans/fixes/vx-348-prelaunch-sweep.md`.
- **Toasts clear the quick-entry band (VX-121):** a toast over the Bookcase or the Library sits above the band the shared `QuickEntryBar` marks, never on it. **The Pool hosts the shared `QuietReceiptLine` at its foot (VX-385, closing VX-355): a receipt-only act from its rows — a duplicate, ⌥⌘Z, ⇧⌥⌘Z, an AI's receipt with its Open › — speaks there under receipt_style quiet; composed only while a receipt shows.**
- **The List's pinned headings in dark (VX-20, her #188(m) "the bands match"):** drawn on the List's surface with a hairline, never a warm grey band across the black room.
- **THE BOOKCASE (13i-d, `notes/plans/phase-13i-d-bookcase.md`; the sitting record §7/§19–§24 is the ruling):** shelves as a mode-row STRIP (one line, edge fade, ⋯ type-to-filter overflow; the names on quiet near-square light-wash chips, the solo'd one filled — librarywalkpolish R-LWP-2, the committed reference `notes/plans/librarywalkpolish-ui-reference.html`; **the strip LEADS with the VIRTUAL "starred" shelf: books-only, the union star, shown always, drop-to-star — R-17y-9, item (s)**); solo on the default shelf · All stacks shelves in strip order; UNSHELVED at the TOP of All under its own collapsible header; Welcome holds the SEEDED content only; new books land unshelved, a context mint lands on the solo'd shelf; drop targets + drag reorder + Move to Start/End; Rename · Set Glyph (one grapheme, monochrome) · Make Default · Delete→unshelved; **the № census** (a quiet POPOVER under its mark — the order menu's twin on ONE masthead-popover idiom, the selected row washed, census solos COMPOSING within a solo'd shelf: 17y (r) + librarywalkpolish R-LWP-1; collapsed by default; each row a SOLO filter: books · gatherings · finished · owned · living · with arrivals); **order ▾** = a–z (default, digit-aware) · last edited (DERIVED locally, never synced) — **my order and hand placing (grips, row drops, Send to Top/Bottom) STEPPED BACK for 0.9.2 at her word (librarywalkpolish R-LWP-4; a stored my-order preference reads a–z, never rewritten; the proper return is VR-120)**; starred floats first under any order; **details** hides row meta AND arrival counts; honest counts ("N notes · M archived"); NO search box, NO time filter (the place/finder boundary). **THE BOOK PANEL:** the collapsible right-side book TOC on every membered note (the switcher atop for shared notes; "appears in N gatherings" with names; Remove/Release; drags over the existing ops with menu twins). **THE WING SWITCHER** (a masthead dropdown; "Wings — each a separate library"): mint · rename · delete-unless-empty · Move Everything to Another Wing (additional wings only); the whole surface re-scopes per wing; the per-item Move/Copy to Wing doors carry R-13ia-1's tag adoption; the lineage door under a cross-wing copy names the wing and at most offers go-to (ruled #166(e)). **ARCHIVED MEMBERS (her #169(a)):** the per-book archived line on the Arrivals idiom (invisible when empty; Unarchive + Remove/Release), archived waiters visible and seatable at the door, the Index never shows them. **The tutorial's books chapter** carries §25's eleven lessons + five rituals (lesson 9's delete-guard sentence withheld until 13i-e ships the guard — P-6).
- **The 17y + librarywalkpolish contract lines (2026-10-05/06 — `notes/plans/17y-sitting-rulings-2026-10-05.md`, the 17y RUN RECORD in `notes/plans/phase-17-standing-fixes.md`, `notes/plans/librarywalkpolish.md`):** a book's ARRIVALS live on the masthead ICON beside its settings gear — calm when nothing waits, present when something does; the ONE word is "Arrivals" everywhere it speaks (R-17y-1/2 — the content-top door line's idiom is retired); a waiting row OPENS the note read-normal, and opening never seats. The Library's card view is named **"Cards"** (item (d)) and **always shows notes**: picking Cards moves the scope to Notes, and a non-Notes scope picked inside Cards returns the view to List (R-LWP-6, generalized at her word). The chapterless group reads **"unfiled"** everywhere (R-17y-4). The app's ONE WING FOLLOWS the focused pane's note on open and on focus, with the quiet "Now in …" receipt (her (f) ruling); cross-wing Open rows wear the wing indicator. A book-row drag presents a TITLE CHIP riding under the cursor (R-LWP-3), and a drop outline lights only where the drop would act (§12's own false-offer rule applied across the headers, the strip names and the starred word).
- **The NOTE mode row: Write · Takes · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘7, derived from the one order; **in RELEASE the row is SIX modes ⌘1–⌘6 — Canvas is Debug-only: 17y (p), her "debug-only ratified"; the 17y B2 RECORD, P-17y-B2-7/#184(g)**). **A note FIRST OPENS in WRITE, with per-post MODE memory (local, persistent, per note — S4-20's contract, `notes/plans/phase-13b-make-it-work.md`)** (the earlier Takes-first-open wording was a doc error — VR-122's J-17). Takes = single-column fan work (its article REMEMBERS the row at the top per note for the session; an entry landing outranks the memory when the note's current block changed — 17q). **LENS-AWARE since VX-168 (VX-170, 2026-10-12): the masthead `show ▾` popover filters the board by four lens forms — in X · in A, not in B · X disagrees with Y · X disagrees with the chosen takes (R-VX170-1) — non-matches collapse to one-line rows, a match expands the filter-named + chosen takes, a quiet chip names the active filter, and the pick is SESSION-ONLY per note (R-VX170-2…5; a blank take is an ordinary take in every form, P-VX170-1; the record `notes/plans/fixes/vx-168-mcp-client-secret.md`).** **NOTE-OPEN (R-18l-1, 2026-09-26, 18l U0c — her ruling + #150's provisional refinements): the session's FIRST open of a note shows the START in every mode (superseding the open-at-remembered-caret rule for the note-OPEN act only); an in-session RE-open restores the page she left, never revealing an off-page caret; deep links keep their targets. The binding record is `notes/plans/phase-18l-navigation-feel.md`.** Read carries an in-place `edit · read` switch opening on `edit` (the editable index surface with the `▸ 01` outline column; P3's one live editor through `PaneTextAuthority`) and `read` (the calm page, continuous or paged; a sentence click flips to `edit` at that block through `LandingTarget`). Lenses = the editable multi-column editor, ALL lens machinery's one home. Compare holds Outline. Blocks = the power-user workbench (multi-select, bulk bar, context panel). Canvas = a VIEW on a post or the scraps area (spatial arrangement + the minimal one-take switcher; movement free; the switcher view-local) — **Debug-only since 17y (p): off in Release, the Snippets area's Canvas face and its other doors included.**
- **The BOOK's mode row: Outline · Index · Book · Read** — Index editable in place; Read read-only; **THE BOOK'S DOORS AND PLACE (VX-382, 2026-10-18 — the record `notes/plans/fixes/vx-382-book-view-doors.md`):** every book open door (the headers' and cards' open ↗, Index's "Open in the full editor", the spread's) lands in WRITE at her block with her caret's offset through the ONE landing road (`BookOpenDoor.Landing` → `ShellRouter.adopt(landing:offset:)` + `ModeLanding` → `jump`), forcing Write even with nothing live — never the note's remembered mode (her ruling); the left note box offers "open ↗" in every book mode and "Takes" on Index's live block; Index blocks with takes wear the ⑂N badge opening the in-place Takes sheet over the book (her pending typing written first, the live pane released); Outline → Index carries the live block at her caret (the departing surface never eats the arriving one's reveal); a book surface's caret — and a CLICK into a book note — feeds the note's ONE place memory, so "edit here" and an in-session re-open return to her book place (PROVISIONAL, the bundle #232); the focused note's controls live in the SIDEBAR'S NOTE BOX (three states: none · selected · live), the details gutter retired (18d); the navigator, Index's chapter panel and Read's contents column are draggable leading columns (`SideColumn`) with remembered widths; note lengths remembered per note in a LOCAL-ONLY store.
- **The editor language:** boundaries invisible at rest, dotted seams on a global toggle; the editing indicator a setting (off · outline · background); **comments and callouts render in the whitespace GUTTER outside the text area on every surface, stacked vertically, and the prose column's measure and left edge NEVER move for a decoration** (R-13u3-3, pinned per surface); the inline-tinted comment strips are an opt-in; comment EDITING lives in the panel; a callout's leading glyph is one grapheme; sacred margins; everything visible in an editing surface is editable. Takes presentations: tinted cards, "✓ chosen", ONE live-editor ring, the changing-block wash (default on), the short-block strip, follow-the-scroll in all modes; an empty block in Takes is an empty line. **The live editor's markdown face honours a closer at the caret** (VX-296, her fix (a)): while the caret sits right after the whitespace that would disqualify a closing marker, the span still reads styled, and leaving a trailing space behind un-styles it honestly; only an editor she can type in honours a caret; every non-live reader (the read pages, export, search, ⌘I/⌘B's acts) keeps the flanking rule byte-for-byte — the open edges (the opener, which markers, the acts, a span re-shaped while the caret sits before an inner marker) are QUESTIONS #220. **Write's take panel answers every routed command about a block or a take on ITS block** — or greys it (the nine verbs that cut, join or add blocks) — never Write's caret block beneath the sheet; ⌘⇧T closes it (VX-154; #221). **A comment left unsubmitted in the comments panel by any close but ⎋ is kept for its block and comes back on reopen; keeping never files** (VX-257, her ruling on P-VX179-R2-1; #223 — the Mac; the phone's sheet is VM-18).
- **The two ceremony sheets** — Divide choosing takes · Merge choosing takes — open on a preset row (§9), real prose side by side, the ✂ overlaid on the inter-word gap (18f).
- **Messages carry a KIND on the one status seam — refusal · offer · receipt** — decided at the door; the synced `receipt_style` (toast · quiet · off, quiet by default) governs RECEIPTS ONLY, rendered as a muted line at the bottom bar's trailing end; refusals and offers always toast (18i). **An AI write's line is a RECEIPT that CARRIES a one-press door — "Open ›" — with the session-scoped keyboard road "Show the AI's Last Change" (⌥⌘O) alive past the fade and under receipt_style off (R-13nb-27, her ratification 2026-10-10 — the door does not reclassify the line into an offer).** A door that did nothing speaks a refusal.
- **No popup greets a first open; the app's own asks (updates, the backup folder) wait for days of use and calm moments, and are always answerable in Settings** (R-13r-11/12; the cadence and the rulings are the 13r plan's — `notes/plans/phase-13r-distribution.md`; ruled canon at the 2026-10-04 post-close sitting).
- **FIRST OPEN, THE OFFER AND THE TOUR (13s-b, 2026-10-08, `notes/plans/phase-13s-voice-onboarding.md` — the rulings R-13s-1…42; VX-7):** a fresh store opens with NO popup (the calm-asks line above untouched): the Bookcase, quick entry at its foot (R-13s-3), and the ONE quiet offer line in her approved words with its retire-forever local flag (R-13s-6/13) — press it or ignore it forever. **Study is the fresh-store voice default** (a voiceless store adopts Study; existing stores keep their voice). The sea-glass cards fan (#C2DDD3) is the app's face — ONE icon in every appearance (the dark appearance and the user-chosen tinted style fed the same art), About, the offer mark (VX-177 · VX-192 — the striped V and the jadeite face superseded; the ruled placements stand; no user-switchable colourways at her word). **THE TOUR:** a pure-rule engine with ring + cards and NO dimming ever; the 22 approved frames verbatim (three build-verified adaptations, recorded); an off-target act re-anchors with the road-back line; Help ▸ Take the Tour re-enters any time; the end card's readme aside asks the store whether the readme still exists before speaking. The tour is Mac-only. **A window that OPENS on the Bookcase (launch, unlock, a new window) puts the caret in its quick entry when nothing else in that window holds the keyboard** — decided once, never stealing from a field, a sheet or the tour; arriving back at the Bookcase later is unchanged (VX-326; #224; the back-navigation is VX-332). The capture box keeps its own undo, and a filing ends it (VX-193; #222).
- **THE COMMIT VOCABULARY (13s-b U4 — R-13s-31/32; VX-103):** the app says **commit** everywhere a savepoint was named (Block History “Commits”, Settings ▸ Writing, ⌘/, receipts, the phone — 46 strings, both platforms, the label-fence verified); the sentences that DEFINE commit say “saved moment” (P-U4-1 — her open taste call, QUESTIONS #206); two ruled survivals stand (the tour's and the guide's one exemplar “savepoint” each). **⌘S ALWAYS COMMITS (VX-347, her ruling superseding QUESTIONS #121(b)):** the name field stays, and every way of leaving it but ⎋ FILES the commit (unnamed if nothing was typed) — ⏎, clicking away, typing on (the click that returns is the leave), closing the window, ⌘S again (which files and opens no second field); ⎋ alone is don't-save; the filing commits the take the ask NAMED, never the caret's at leave time; ONE filing per press (the presentation ledger); the rename door stays ⏎-only. One shared seam (`SavepointNameField` + the leave rule + the settle-once box), every host — the record `notes/plans/fixes/vx-348-prelaunch-sweep.md` (P-VX347-1…5, #233).
- **THE SEED SET (13s-b U1b — R-13s-36/37/38/39):** launch = the field guide + sherlock (OWNED) + the empty starred notes + the disclaimer snippet; “journal” and “quicknotes” mint ON DEMAND, lowercase — mint-time defaults only, existing stores never renamed; Encryption Explained is GONE and UNRESTORABLE (door removed); the classics gain a restore door; jekyll's door fully lowercase; the readme placeholder carries her Start Here text with REAL fans (the finished text = VX-105, hers).
- **The BOOK SETTINGS sheet (13i-c U3; the same pane for a book and a gathering)** carries the COLLECTING section as sentences ("Gathers from: …" · "New matches: …" · "Notes written here are tagged: …") with ONE Edit… door into the rule editor (whose auto-tag row is the OUTFLOW CHOOSER — several tags, any, none), a gathering's three-state hide-owned row, and the STATE doors — Finished (the confirm carries §24's "N waiting at the door will be dismissed" only when N > 0), Seal… (the confirm LISTS the notes that fork; "nothing needs copying" on an owned book; sealing finishes too) / Unseal (reopens), Own Its Notes… (the confirm LISTS the copies) / Stop Owning. The mint door requires a rule (the editor inline); a gathering's empty save refuses and offers Delete. **The MEMBERSHIP CHOICE sheet (13i-c U4)** opens from every add road an ownership refusal reaches (the chip, the drops, Manage Notes, the Arrivals arms — Copy in · Move in · Dismiss, with "owned by"/"also in" lines): Copy in / Move in (the severed books listed) or Copy in only, the edit law said at the door. **Delete** asks on every book; an OWNED book offers two choices (book only → the Pool · book and its N notes → the Trash, returning whole). **Duplicate Book…** shallow or with copies (owned: copies only). **Remove from this book** reads **Release** on an owned book; a gathering offers "remove #tag". **The BADGE family** (one switch, `ownership_badges`): the shared mark inside a book (hover names the books), "owned by “X”" outside it (click-through opens the book at the note); the navigator chip reads sealed. The Trash row says "and N notes"; Put back's receipt says it came back whole.
- **This Note's Tray:** Leaving · Archived views with a shared blocks/takes filter; released originals surface per note and behind their successors' lineage doors (the global unplaced-blocks listing is retired as a user surface; `Queries.unplacedBlocks` is the debug net).
- **IMPORT & COPY FULL TEXT (13n-a, 2026-10-09 — the MCP door's Level 0; the plan file is the record):** File ▸ Import… and the Bookcase drop read the Variorum document format (a file → a Pool note; a folder → a book; the drop is a CONTEXT MINT onto the solo'd shelf and lights its outline only where the drop would act); refusals name folder, file and line; receipts carry the counts and ⌥⌘Z, rendered at the main column's page foot on book surfaces (`BookNoteBox.quietReceiptHome` — PROVISIONAL placement rule, the walk's WA-1). **Copy full text** (note ▾ menus + ⌘K; renamed from "Copy for AI" at her review — "I'd rather not have 'for AI' on a button") puts the note on the clipboard in the same format, receipt "Copied full text."; the format's one home is `Domain/VariorumDocument` (the export is its client). Commits and book settings deliberately do not ride the text form — the full-fidelity tier stays 13m's edition (R-13n-8).
- **THE MCP DOOR (Level 2) — authoritative: `notes/MCPSpec.md`, read before touching anything it names (the door, its tools, grants, Settings ▸ MCP, the shared icon, the AI docs — and any operation the wire calls, or Private, Seal, Own).** An AI client reaches the store ONLY through the in-app MCP server, alive only while the app runs with the pane's switch ON; her governing intent: at the EDIT rung the door is broadly AS CAPABLE AS HER AT THE KEYBOARD (R-VX184-1). The rules any session can break WITHOUT knowingly touching MCP stay loaded here: **every AI write is one of §9's operations** with the grant check inside the op's own transaction and ONE ⌥⌘Z entry naming the client (an MCP undo writes back only while the row still reads the act's value, else it quiet-retires its entry — §9); **her pending typing lands first** — before a wire act that meets a take she may be typing in, the door flushes every open note's pending typing ahead of the act, and a wire note delete rides her Delete door's ONE road (`.variorumNotesDeleted`), every pane leaving a dead note for the Library IN PLACE, focus kept (VX-275 · VX-246); **Private, Seal and Own are hers alone** — no MCP road writes `ai_private_at`, `sealed_at` or `owned` (R-VX184-2); **the fence** — the daily Journal's entries, ⌘J entries and anything Private answer only a PER-ASK note grant, and everything unreachable answers ONE byte-identical not-shared shape, so a client can never tell hidden from missing (VX-163); **grants are LOCAL-ONLY, never synced** (§7's family, v1_24→v1_30); **a book rule an AI writes BELLS, never backfill-seats** (a rule write must not expand the writer's own reach — P-13nb-U4-16); **the shared icon reads reach only for the rows DRAWN, never the corpus — and reads NOTHING while no client is approved** (P1; VX-271); **`show_in_app` moves things only while Variorum is frontmost and never queues or raises windows** (R-13nb-23/26g); the VX-258 key narrowing — the pre-public-release gate — shipped at VX-246 and the gate lifted. **THE DOOR'S 2026-10-18 GROWTH (VX-348's urgent trio — the contract lines live in MCPSpec):** `list_wings` lists the wings the client holds a standing wing grant on (a granted EMPTY wing is discoverable — her R-VX348-5), one standing grant row per client × place (R-VX348-6, v1_30), every connection's END says why in Activity (the stop roads included — VX-394's fix), and a write carrying U+0000 is stored stripped with the answer naming how many were removed (VX-357; the digest stays the stored text's). Level 0 is 13n-a's format (the IMPORT & COPY line above); Level 3 (chat) stays deferred.
- **The reference panel** (§7 `reference`), the badge behavior (a corner badge only on fanned blocks), export (a callout → blockquote), the Shortcuts & Dictionary helper, the keyboard family (⌘[/⌘] indent, ⌥⌘[/⌥⌘] back-forward — PROVISIONAL #130; ⌥⌘Z / ⇧⌥⌘Z structural undo/redo; ⇧⏎ in-block newline; the merge chord said on every face from the capability registry).
- **SEARCH — the one finder (13o, 2026-10-07; the rulings R-13o-1…15 + §FORK RULINGS + §U3 RULINGS in `notes/plans/phase-13o-search.md`):** full body-text search over the LIVING corpus (all live active takes, titles + worn display dates by query-time date parse, scraps, comments, names/labels; versions fenced; archived behind one facet; savepoints IN behind the one explicit **`+ commits`** facet — VX-83/VX-72, R-VX83-5/9/10: the chip's word is "commits", lines read "commit · <day>", counts "N commits", and a savepoint NEVER lists without the facet; the Trash deliberately out, VX-93's someday as search INSIDE the Trash), on a local-only derived FTS5 index, accent- and case-folding (the deliberate third sameness rule — the Write/Takes bars keep their pinned pair). The Library field is THE finder wearing direction C's ANSWER SHEET (the band's honest counts + quiet chips, passages grouped under their notes, every "all N ›" a real road — no capped listing anywhere); ⌘K carries passages under its title hits; the **when ▾** door is ONE calendar popover (direction 1, R-VX83-2: the mode row on a day · between days, a voiced month grid, the armed SENTENCE at the foot as the confirmation; NOTHING arms until a day is pressed — P-13o-U2-9 superseded for this door; between days is two presses with the run washing in; `any day` clears); a book's masthead rests as a bare 🔍 expanding to the same engine scoped in place (gatherings searchable through the ONE membership function); `#tag` surfaces the books it flows into, top-ranked with the reason said — and a `#tag` ALONE narrows the Library to the tagged notes as its OWN listing rows (sort ▾ and scope live, the Blocks scope by block-level tags, the archived facet's rows marked; R-VX83-1 superseding P-13o-U2-6), while a plain word NAMING a tag offers it as a one-press chip (`tag: #name ›` — the explicit-tag doctrine, her words on the record); the mode facets (gathering · living · owned · finished · sealed) are facts, never tags; the Library incl. its search is hide-owned-EXEMPT, owned notes badged; wings isolate totally with scraps the one ratified shared room; clicking any passage lands in Write at the block with the match selected and the find bar armed (⌘G steps on) — the needle is the snippet's first CONTIGUOUS matched span (whitespace and ≤2-character non-newline gaps coalesce, kept as written — VX-86 + P-VX83-W2) and the landing rests in the comfort band below the shown bar (VX-85). Search scales ∝ matches, never corpus (P1 pinned). The follow-up run's record: `notes/plans/fixes/vx-83-search-followup.md` (her first-use report; rulings R-VX83-1…10).
- **LIBRARY PORTABILITY (13x; the rulings in `notes/plans/phase-13x-library-portability.md`):** **File ▸ Send Library to Another Mac…** (and its Data Safety twin) writes a FOLDER PAIR — a sealed snapshot + its key file — to a chosen folder, to AirDrop whole; **File ▸ Open Library…** (and the welcome/absent-store/waiting faces) classifies what was picked (a pair · a backup pair · a plaintext export · a keyless file ⇒ the honest refusal), unlocks by the lobby's roads, CONFIRMS, then adopts: the current library and its key files step aside whole into `Previous Libraries/<stamp>/` beside it after an A1-shaped safety copy, the copy lands (its WAL tail included; the picked file is never written — every read runs on a private staged copy), and custody adopts the key that opens the landed file (the collision rule). Settings ▸ Data Safety's **Restore from Backup** lists the backup folder's pairs, each saying which credential opens it (decision 11). **THE RESTORE HOLD (her round-3 ruling):** an adopted library lands HELD — no sync round, flush or rotation ceremony runs until the ONE **Resume Sync** press in the standing banner, which then catches up to the account (the gates read the marker beside the store); a copy never carries the sync key or device identity, so a Mac new to a library enrolls. The live library is never placed in iCloud Drive (the picker's guard). A key file still Apple-wrapped under a Castle account surfaces the follow notice (`castleKeyFileAppleOpenable`). **THE PROTECTION REBUILD (VX-305 → VX-378, 2026-10-14/18; the contract `notes/CastleRules.md`, the walk `notes/plans/vx-266/castle-lifecycle.html`):** the headless core under `Sources/VariorumCore/Protection/` is built and gated to the rules — every library encrypted under its own random key with a key file kept redundant (beside it, in every backup, a sealed copy in the Mac's keychain), twelve words from birth and a passphrase asked, Standard a convenience posture with quiet roads and Castle one promise (no Apple road, ever), one posture at a time (entering takes everything in, leaving hands everything out), the floor "a backup always opens with the passphrase and words you had when you made it", a copy is a copy (Look inside / Make this my library — the latter IS Restore from Backup, a new library with no previous keys), detect-and-say (the notice, never a repair), no migration of pre-design stores (rule 26). **THE OPEN ROAD (VX-306, 2026-10-18 — `notes/plans/vx-306-castle-open-road.md`; a PHASE under the architect shape, her overnight mandate):** the core is LIVE in DEBUG BUILDS ONLY, behind ONE compile-time switch (`ProtectionRoad.newRoadIsLive` — a Debug build on the Mac and the phone, reaching the dev store; Release runs 13x's road byte-unchanged until VX-329): the thirteen production leaves (`App/Variorum/Shared/Protection/` — the data-protection keychain for custody, sync keys and the memory item, iCloud Keychain for the Apple keys, SQLCipher for the library and its copies, the files beside the slot, the catalogue over the folders this design writes), the LOCAL-ONLY `protection_record` table (`v1_31_protection_record` — never synced, the plaintext export drops it, marker 13 untouched), VX-390's library-ID stamp on every custody item and Apple key (Castle entry sweeps this library's silent items and Apple keys by the stamp; the catalogue sweep stays the belt), and the faces: the lobby on `assess`'s roads (the quiet roads at once, the typed roads with rule 1's mirror and the catalogued key files, VX-310's Touch ID button and line), the once-shown words card at creation, rule 3's reminder and the Set a passphrase sheet, rule 21's notice and key-file offer, rule 27's lobby and banner, rule 1's restore receipt, the rule-8 re-makes at every open, and the two copy doors — **Look inside** (a read-only facts sheet over a private byte copy; nothing written, closing forgets) and **Make this my library** (one confirmed door: a new library in the posture of now under the current pair, the previous one whole in Previous Libraries, the restore HOLD kept as the sync gate it is — Settings ▸ Data Safety's Restore list and File ▸ Open Library… (a picked pair is FILED first) are these doors; 13x's adoption flow retires behind them on the new road). The phone opens on the same road (its words card, lobby and rule-27 faces; no Look inside on the phone yet). The words are §7c of the plan, hers at QUESTIONS #234. The server's `key_vault` shape stays VX-307's SyncSpec §12 lockstep (`notes/plans/vx-307-castle-crossings.md`). The 13x landing wording above describes the RELEASE road until VX-329.
- **Capture microsyntax** (R-13u4-1): `{#tag/path}` applies the tag (smart-book rules do the rest), `{t:"…"}` titles; only braced forms parse; tokens disappear (`Shared/CaptureMicrosyntax`, both Mac doors; the phone's face is the mobile catch-up's).

The views the model must support beyond today's surface (side-by-side, swap-and-reread, diff with optional whitespace normalization, infinite scroll, timeline as a Library view mode, the collapsible block index) are capabilities, built functional first; the UI is iterated with the author.

## 13. Build order

`notes/DetailedPlanForPhases.md` governs (product advancement only; fixes live in `notes/plans/phase-17-standing-fixes.md`). Summary shape: substrate (schema → operations → queries) → editor core → structural gestures → readings + views → hardening → the UI design passes with the author → sync → accounts → the mobile app (its own project) → web.

## 14. Resolutions & deltas from the source SPEC

Resolved (source SPEC §14 open questions): 1. single-variant divide in place ✔ · 2. unified `container` ✔ · 3. tagging as two tables with real FKs (deliberate schema delta) ✔ · 4. cascades as triggers; no variant→commit_point cascade ✔ · 5. the sync engine decided up front — hand-rolled row sync; PowerSync-class engines rejected (SyncSpec §1) ✔ · 6. pool-copy scope: active variant by default, `includeFan` from day one ✔ · 7. churn metric: characters, inserts + deletes equal weight ✔ · 8. headings are Markdown text, no column ✔ · 9. `default_variant_id` lifecycle (§9) ✔ · 10. edge directionality: source = descendant ✔ · 11. fractional-index positions, no rebalance ✔. Additional deltas: live-row partial unique indexes everywhere; I10 added; `chosen_variant_id` fallback semantics; the concretized stack.

**The dated delta record (Phase 0 → 13u4) lives in `notes/AppSpecDeltaArchive.md` and, for the pre-split narrative, `notes/AppSpecRulingsArchive.md` §14.** The closeout rule since 2026-09-26: a phase's canon delta lands in this document as a CONTRACT line (what is now true) plus a pointer to the plan file that carries the ruling — never a paragraph of history. Her word 2026-10-14 (VX-341): this section keeps the most recent ~FIVE efforts' entries — always including the most recent MCP effort's — slimmed to contract and provenance; every entry's finals and ladder tallies live in `notes/plans/run-finals-ledger.md`; older entries roll verbatim to the delta archive at each closeout. **Most recent canon deltas — VX-306 (a PHASE under the architect shape, 2026-10-18 — `notes/plans/vx-306-castle-open-road.md`; her kickoff rulings §7 — the standing cast, a five-round ladder cap while MAJORs, the overnight mandate, the three-unit shape, the words drafted from the rules, VX-386 first and VX-390 in U1, the dev store's conversion approved, the Sync/-or-custody slot, her hands for the real store, no `/Applications` refresh; the orchestrator's provisional rulings K1–K7 §7b and the words §7c; units U1a (the production leaves — none existed) · U1b (the lobby on roads, the dev store recreated on rule 26's own road) · U2 (the honest faces) · U3 (the two doors + the phone), each proven by red-on-old pins, a Mac batch under the stage and the orchestrator's walk on the dev store; the ladder CLOSED at round 2 (0B/0M/4m/4N · 0B/0M/3m/3N — every finding fixed red-on-old or ticketed, the round-2 fixes line-by-line checked); the Release check green on every tree):** §12's THE PROTECTION REBUILD line gains THE OPEN ROAD paragraph; CLAUDE.md unchanged. ONE `Sync/` line (the `protection_record` local-only registration, P-VX306-K6); zero `Server/` lines; marker 13 untouched; zero lockstep. The bundle QUESTIONS #234; born VX-406 · VX-409 (Low) · VX-411 (Medium); PR #174. Before it — **VX-348 (a RUN, 2026-10-18 overnight-into-day, `notes/plans/fixes/vx-348-prelaunch-sweep.md` — the PRE-LAUNCH BUG SWEEP, her running list + the today's-road pair + riders + the urgent MCP trio she added mid-run; FOURTEEN members, all Done: VX-347 · VX-351 · VX-350 · VX-357 · VX-349 · VX-338 · VX-339 · VX-384 · VX-385 + riders VX-176 · VX-355 + the trio VX-392 · VX-393 · VX-394 (its code half; the Castle-lock product call hers, Needs Lillian); her kickoff sitting ruled VX-351 live (R-VX348-1…4: hover everywhere, the setting deferred to VX-389, all speakers, the phone's VM-22) and the trio's two shapes mid-run (R-VX348-5 `list_wings`, R-VX348-6 upgrade-in-place); her overnight mandate (rule provisionally; merge in finish order; the LAST merger of 381/382/348 mints the ONE 0.9.8 — THIS run merged LAST and mints) and her own force-push re-writing the kickoff commit's trailer; Fable orchestrated and cold-reviewed, `opus-implementer` at xhigh; FIVE units each red-on-old pinned, batch-verified under coordinator windows and walked (the combined walk rode a REVERSIBLE dev-store swap — the predesign store in, the fresh new-road library back byte-identical, cmp-verified both ways); the done-whens proven by a REAL client live (an empty granted wing found in ONE `list_wings` call, a book created unaided; the U+0000 strip answered `null_characters_removed: 1` with the stored text's digest); the verification verified itself twice (seven hollow mount cells caught by the premise check and re-shaped; the one fixed-leg red live-confirmed REAL — the stop roads wrote no end line — and fixed host-independently); the ladder CLOSED AT ROUND 1 (0B/0M/3m/3n, all dispositioned; VX-338's deletion-safety argument independently re-derived and found sound)):** §7's grants family gains v1_30 (one standing grant row per client × place); §12's MCP DOOR line gains THE DOOR'S 2026-10-18 GROWTH (the contract lines in MCPSpec); §12's commit vocabulary gains ⌘S ALWAYS COMMITS; §12's CONTROLS ROW gains NARROW WIDTHS; §12's Library line gains the EVERY-SPEAKER HOVER; §12's toast line gains the Pool's `QuietReceiptLine`. Zero `Sync/`, custody, `Protection/` or editor-seam lines; marker 13 untouched; zero lockstep (v1_30 is local-only). The ratify bundle QUESTIONS #233; born VX-389 · VM-22 · VX-395 · VX-396 · VX-397 · VX-400 · VX-401 · VX-407 · VX-408 · VX-410 (every one triaged at mint; VX-167 annotated with the night's discriminator evidence); PR #173 (merge commit 8611a7e17). Before it — **VX-382 (a RUN, 2026-10-18 overnight, `notes/plans/fixes/vx-382-book-view-doors.md` — Book view doors & reds, part B of VX-284's split at her 2026-10-17 sitting; members VX-303 · VX-304 · VX-291 · VX-21 · VX-69 · VX-77 · VX-115, all Done; her overnight mandate (rule provisionally; merge in finish order — this run merged SECOND, no release: the ONE 0.9.8 is the LAST merger's) and the night's merge protocol (the fold of main before the ladder; the coordinator's windows); Fable orchestrated at her launch (the plan's Opus-orchestrates line noted, not re-litigated), `opus-implementer`/`opus-reviewer` at xhigh; units U1a (the landing road; rulings R-U1a-1 — the book's caret feeds the note's ONE memory, option A with two guards — and R-U1a-2 — every book door forces Write, her sentence over the brief's sketch) · U1b (the box door + Index takes; finding D-2 — the departing Outline ate the mode-switch's block landing — traced, fixed, class-swept) · U2 (the small fixes; the walk's W-1 — the fold target's overhang took hover but dropped clicks — found and fixed by the button-frame overlay; VX-77 DISMISSED AS HOLLOW, the dark test host, the `.aqua`-pinned luminance scans ending the class; VX-21's premise corrected at R-U2-A's stop clause, the ticket's letter standing as R-U2-A2), each proven by red-on-old pins, Mac batches and both-voices walks; the fold batch green on the combined tree; the ladder CLOSED at round 1 (0B/0M/3m/5n — R1-1 hollow by measurement, R1-2 the click-is-her-place fix, R1-7 the Takes cell's dead zone fixed, both fixes orchestrator-line-checked)):** §12's book mode row gains THE BOOK'S DOORS AND PLACE sentence. Zero `Sync/`, custody or schema lines; the editor-adjacent hunks (the mount bracket, the other-note memory arm, the seed's hers bit) carry Fable line-checks and the stop trio is untouched; marker 13 untouched; zero lockstep. The ratify bundle QUESTIONS #232; born VX-402 · VX-403 · VX-404 · VX-405 (triaged; VX-353 and VX-300 annotated); PR #172. Before it — **VX-378 (a PHASE under the architect shape, 2026-10-16/18 — `notes/plans/vx-378-castle-simplified.md`; the corrector of VX-305 whose NO-GO and simplification sitting it answers; her kickoff cast word, her ladder cap (five while MAJORs), her overnight mandate; her rulings during the phase verbatim in §8 — both secrets at a crossing, the FACTS DIFF, the FLOOR, no key carry at Make this my library, the notice instead of the refusal, and her morning sitting of 2026-10-18 (rules 5, 11, 25 amended; O1-1, O2-1, O2-2, U4-7 ruled); units U1 (the cut) · U2 (the additions) · U3 (the lifecycle proof, fixture-first) · U4 (the world and the soak; stopped at a design find, ruled, resumed, finished by the orchestrator under the budget-death road); the ladder CLOSED at four rounds (0B/0M/2m/3N · 0B/0M/0m/2N · 0B/0M/0m/2N · 0B/0M/1m/1N); the gate GO on the final tree `66f7561e1` — discovery seeds 21–40 and gate seeds 1–20 green in Debug and release, three attempts, two real faults and one checker fault found and fixed red-first):** CLAUDE.md's read-explicitly list gains `notes/CastleRules.md`; §12 gains THE PROTECTION REBUILD line. Zero `Sync/`, `App/`, `Server/` or schema lines; marker 13 untouched; zero lockstep. The bundle QUESTIONS #231; born VX-380 (Low, Parked), VX-386 (Medium, VX-306's first commit), VX-390 (Medium, Pre-launch, VX-306 U1); PR #171 (merge commit aeabdd75b). Before it — **VX-381 (a RUN, 2026-10-18 overnight, `notes/plans/fixes/vx-381-gatherings-tags.md` — Gatherings & tags, part A of VX-284's split at her 2026-10-17 sitting; members VX-250 · VX-240 · VX-241 · VX-249 · VX-247 · VX-111 · VX-194; her #217 words landed byte-for-byte under her overnight mandate (rule provisionally; ONE 0.9.8 by the LAST merger of 381/382/348 — this run merged without a release); units U1 (the doors' words and faces) and U2 (the operations), each proven by red-on-old pins, Mac batches (135/18 · 132/17 · the fix leg's 143/18 + the phone's 23/3) and the orchestrator's both-voices walk; the ladder CLOSED at round 2 (r1 2B/1M/2m/6n — the revived-tag stale-path BLOCKER, the P1 revival-scan BLOCKER, the raw `duplicateTagPath` MAJOR, all fixed and re-verified; r2 0B/0M/1m/2n with the sweep's tag-path predicate + witness seed built by the orchestrator, both legs verified); the orchestrator's rulings P-VX381-1 + R-VX381-A1…A5):** §9's structural-undo list gains `deleteTag` (exact-stamp subtree revival with paths REBUILT from the live parent; "Excluded" now reads tag APPLICATIONS); the shared refusal table gains `duplicateTagPath`'s sentence (both platforms); the gathering mint planner ALLOWS NOT terms (P-VX217-d loosened as she ruled); R98's collect door sets the star through the union-star road (cap-exempt, ONE planner authority with the mint) and speaks the mint family's receipts with the honest archived tail; the shared-note notice counts BOOKS only; `CalmButtonStyle` wears a token-derived disabled face app-wide; the Settings `.opening` arm says "Opening your library…". Zero `Sync/`, custody, schema or editor-seam lines; marker 13 untouched; zero lockstep. The ratify bundle QUESTIONS #230; born VM-21 · VX-387 · VX-388 · VX-391 · VX-398 (pre-existing classes, triaged); PR #170. *(Entries before VX-381 live verbatim in `notes/AppSpecDeltaArchive.md`, each under the heading naming its roll.)*

## 15. Risk register (standing risks and why; deferred WORK is `KnownIssuesAndTechDebt.md`)

1. **Live block-identity maintenance over `NSTextStorage`** — the single riskiest thing in the project: identity is maintained DURING editing (block IDs as attributes, exact changed ranges), never recovered by diffing. Hence headless operations first, editor phases of their own, pure boundary snapping, and the per-keystroke identity oracle in DEBUG. If an editor bug corrupts identity, the store is still safe — operations validate against the DB.
2. **TextKit 2 viewport/height/scroll-to-location** is the least reliable subsystem of the chosen stack and shifts between point releases. Live geometry was adopted after the Phase 6 spike; what survives is re-verifying after every macOS update (`notes/TEXTKIT2_NOTES.md` §5 — its §3 records each release's measured deltas).
3. **Hand-rolled sync** — chosen with eyes open because the engines fail this schema harder; the protection is the two-client fake-server harness and the convergence suites (any sync change without a convergence test is unreviewed; `notes/sync-postmortem-fragments.md` before touching `Sync/`).
4. **Resolved interpretations:** structural undo (not global undo); the reference panel (not a knowledge base).
5. **Decisions that must not silently regress:** jittered fractional-index positions (never REAL midpoints); live-row partial unique indexes (never bare UNIQUE); trigger-fed outbox capture; `server_seq` as the only ordering authority.
6. **Toolchain skew:** any second machine or CI must match the primary's Xcode major before its results count.

## 16. Still genuinely open

Phase 13's typographic PDF export · an optional derived audit/operation log · the UI, iterated with the author.


---

# Entries appended since 2026-10-18

*(Each closeout appends its dated entry here — the §14-shaped paragraph with the cast, the ladder, her rulings verbatim, the born tickets and the PR — and, where a rule changed, the full narrative under the section and operation/surface name it belongs to. The loaded `AppSpec.md` takes only the changed contract line and a pointer here.)*

## VX-419 — the canon provenance pass (2026-10-18)

Her words: *"we were just working to make it barely fit under so I'm not sure if we need a more comprehensive reassessment of how to handle this, but I don't want to lose the focus that has made the app so great thus far."* The pass moved provenance out of the four auto-loaded files (164,409 → 148,572 chars), appended the pre-pass editions verbatim to the archives first, and added `Tools/canon-size` (reports, never deletes) with the canon-hygiene rule in CLAUDE.md. Her concern, which shaped the rule: *"a session under pressure to delete something is not the right session to be deleting"* — she does occasional triage herself. A cold Opus read found twelve drops, all restored. PR #176 (merge commit 68127a209).

## VX-420 — the new AppSpec and this record (2026-10-18)

Her ruling: *"if the previous app spec format is useful to have as a file that everyone keeps appending to so that I can always ask what happened in a particular phase and get a detailed answer, then let's keep it but rename it and stop making every session read it. I actually do think it's useful to be recording the HER RULING and date, I just don't think it belongs in the app spec."* So: this file, and a new `AppSpec.md` that is literally just a spec, written fresh from the product as it stands with the same section numbers. The record of the rewrite itself is PR #177.

---

## VX-307 — Castle rebuild, phase 3: the crossings and the `key_vault` wire (CLOSED 2026-10-19; PR https://github.com/lduarte-io/Variorum/pull/178, merge 253409a11)

**Her kickoff rulings (2026-10-18, the sitting):** the cast — "Fable fork builds U1" (a fork of the orchestrator implemented the Sync/-custody unit; Opus the U2 batches; fresh Fable reviewers); riders "Plan's two only" (VX-380/VX-406, neither taken — not one-line); the run "Overnight mandate". Standing from her 2026-10-18 rulings (the plan §1/§3a): the mirror deploy and marker-13→14 bump WAIT for the release carrying VX-329 — "I think it makes sense to wait to bump the mirror until we're ready to release this so that my client doesn't stop syncing"; the account faces to VX-308 — "yeah it's fine to keep them in phase 4"; VX-413 required — "can you still copy text out of it? … I think that should be done somewhere in this phase"; VX-412 to her band-card design (her words verbatim in the plan §3a; rules 2/3/7 amended ahead of the build at her word).

**The cast and the ladder:** orchestrator Fable; U1 a Fable fork (its identity incident — adopting the orchestrator's persona from inherited context and stopping itself — is the plan §6's machinery note; every commit survived); U2a/U2b/U2c fresh Opus implementers; round 1 (fresh Fable) 0B/1M/4m/3N — the MAJOR being the implementer's own held F-2 (the crash-window export divergence), fixed with a durable mark + ready reconcile, red-on-old; the orchestrator fixed U1's two client MINORs under same-model arbitration; round 2 (fresh Fable) 0B/0M/0m/2N with the three disputes ruled in writing (the mark-keyed reconcile REQUIRED; the re-arm trace upheld and the round-1 candidate withdrawn; NIT-3 hollow). No round 3.

**§12 (the protection surface):** the crossings' faces, the band card (the words' one home with rule 3's reminder folded in), Look inside's Copy full text, the re-arm question, and the held `key_vault` wire land as SurfaceContracts' protection-line deltas this same closeout; CastleRules' header note ("Until VX-412 lands…") closed. The walked evidence and every word's source are the plan §6's WALK RECORD and the words blocks.

**Born tickets (triaged at filing):** VX-442 (Bug·Suspected·Low) · VX-443 (Debt·Low) · VX-444 (Improvement·Low) · VX-445 (Debt·Medium; NIT-R2-1 rides) · VM-23 (Improvement·Medium). Closed at the merge: VX-307, VX-416, VX-417, VX-412, VX-413, VX-414, VX-310, VX-108, VX-109, VX-235, VX-313, VX-301. The bundle: QUESTIONS #235; #234 ACCEPTED at this phase's kickoff.


## 2026-10-19 — VX-308 (Castle rebuild, phase 4: accounts and the key doors; PR #179, merge 5dc67ff3a)

**The effort (one overnight-and-morning run under her mandate; the full record is
`notes/plans/vx-308-accounts-key-doors.md` — the kickoff record §4, her mid-run rulings in the U1 arbitration, the
unit records and arbitrations, the §5R rehearsal runbook and record, the ladder rounds, THE WALK RECORD).** Her words
at the kickoff sitting's tail, verbatim where quoted: the walk call resolved to option (b) on the throwaway project
she created by hand ("we can make a new project… we can do it"); VX-314 ruled IN after her design questions ("ok
include it. you can use a subagents to build it you want, up to you."); the 10-13 #216 block ruled stale ("10-13 is
probably old and superseded by now"); the throwaway's lifetime hers ("i'll delete the throwaway when this is all
merged to main & released.").

**§12 (SurfaceContracts, the protection line) — what changed and why:** the account faces (the sign-in/out doors, the
hand-up/join, the follow family, rule 16's three local leaves with the F-FORK-1-ruled pointer to the Account sheet's
real deletion and its protection hook), the one presenter (VX-239/VX-243's class ended structurally), the key doors
with VX-263's one line, VX-447's banner-as-the-door (her #235 ruling, the one core custody arm in `KeyDoors.swift`),
VX-448's concealed clipboard (her #235 ruling — the 60-second clear and restore-prior-contents retired), VX-445's
lock + NIT-R2-1's by-library mark, F-4's hold gate, VX-314's engine-mouth account gate. The rehearsal sentence was
added to the held-artifact line (17 has now run green on a real mirror; the grant sweep is marker-aware — R-2's fix).

**The cast:** Fable orchestrated and cold-reviewed (two fresh reviewers), Opus implemented (U1–U4 + the fix leg, one
fresh session each); the orchestrator's own hands: the rehearsal, VX-314, the Mac batches, the four U4 reverts, the
walk. The ladder: round 1 0B/1M/2m/2N, five-for-five agreed fixes, round 2 confirmed all five, zero new. Born tickets
and the bundle: the VX-308 handoff + QUESTIONS #236. Mobile parity: the phone builds throughout; its account faces
and relock are the catch-up's (F-U4-4; the VM comment).

## 2026-10-20 — VX-309 (Castle rebuild, phase 5: copies and words; PR #182)

**The effort (kicked off 2026-10-19, closed 2026-10-20; the full record is `notes/plans/vx-309-copies-and-words.md`
— the kickoff record §0, her sitting rulings, the cut §1b, the briefs §5a–§5d, the T-8 mapping ruling §5b-R, the
unit records and arbitrations §6, the ladder §6-L, THE WALK RECORD §8, the closeout §9).** Her kickoff rulings,
verbatim where quoted: riders the faces set (VX-451 + VX-453 + VX-454) with the rest delegated — "which of these do
you think are most important to release? VX-450 seems important enough to join along with the top 3, but I'm not
sure if anything else should be included" (the orchestrator added VX-450 and VX-444; VX-449/452/101/100 stayed out);
the standing cast; U1 copies → U2 words; VX-211 = "Floor + quiet hint" (the 12-character floor the only refusal, one
calm line, never a meter). Her kickoff accepted the rest of #236. Mid-walk her Fable credits ran out; her word on the
model: "I'm happy with Opus, let's just keep going" — Opus finished the walk and the closeout; on the dev words seen
during the walk: "it's fine to not rotate the dev words - it's not an issue."

**§12 (SurfaceContracts, the protection line) — what changed and why:** the copies' machinery (rule 5's pair in the
picked folder when due per library per Mac, one a day there; retention per library per Mac with future-dated copies
never claiming a slot — a Mac-batch red, MB-1, fixed in core and pinned; Data Safety's counts per library per Mac);
the doors' listings with rule 19's delete (by place; never the open library's; none over rule 27's library) and
VX-210's line; T-5 (Make this my library into the empty slot) and Previous Libraries reopening; T-8 (a plaintext
export in as a NEW library, the §5b-R mapping); VX-444's ledger carry; VX-450's interrupted key-door acts; VX-451's
dial and Lock Library Now in Castle's section; VX-211's floor + hint on every new-road setter; the join moment's
reword with VX-456's quiet arm (the set-up arm left speaking — VX-462) and VX-457's durable Done; the guide's
new-road chapter.

**The cast:** Fable orchestrated (the cut, the arbitrations, the Mac batches, the ladder, the walk's dev-library
half) and two fresh Fable reviewers ran the ladder; Opus implemented (U1a, U1b, U1c, U2 and the fix leg, one fresh
session each) and, from the walk's throwaway block, orchestrated. The ladder: round 1 0B/0M/2m/4N, six-for-six
agreed fixes, round 2 confirmed all six, zero new. The walk found what the suites could not: the pane's export door
writes an empty file (VX-461), VX-456's set-up arm (VX-462 — pinned headless as known issues), a dev device-ID drift
(VX-465), and five smaller findings; walk slips said in §8. Born tickets VX-461..VX-475 and the bundle QUESTIONS
#237; the handoff `notes/handoffs/vx-309-handoff.md`. Mobile parity: nothing mobile-visible; the phone's guide
chapter and passphrase faces are the VM-8 comment. Next: VX-329, its plan written at this closeout.

## 2026-10-22 — VX-329 (Castle rebuild, the release switch; kickoff to closeout in one day)

**The effort (the full record is `notes/plans/vx-329-release-switch.md` — the kickoff record §6, the cut, the
briefs §6a–§6d, the unit records §5, the L0/L1/pg_temp/VX-465 records, the stage batch + closing batch records,
THE REHEARSAL §8 + its addendum, THE RULING under the U4 record, the morning sitting record, the closeout §9; the
ladder `notes/plans/vx-329-ladder-round-1.md` / `-round-1-fixes.md` / `-round-2.md` / `-round-3.md`).** Her
mandate: the only session, no coordinator, overnight to a staged pause; Fable cold reviews; release 0.10; pg_temp
rehearsed on the throwaway with production riding the marker-14 deploy set at her go. She woke mid-run and ruled
live through the day.

**§12 (SurfaceContracts, the portability + protection bullets) — what changed and why:** the Castle rebuild's last
step. `ProtectionRoad.live` true for every build; today's whole deciding and writing road DELETED (~8,200 lines +
suites; "nothing is kept read-only" — the ticket's word, the U1 sweep table the proof); the 13x portability road
went with it (Send Library and the copy doors are the road's own); the lockstep marker 13→14 with artifact 17
registered in the drift pin; the Sync/ carve (CorpusRotation, the rekey guards, `accountRekeyIncomplete`,
`StaticSyncKeyProvider` — Fable's own hands); VX-423 as U3 (one `AuthSession` per process on the bootstrap — the
two-refreshers race that burned refresh tokens pinned red-on-old by behavioral revert); the seven riders (VX-461
the export door's rollback-journal mechanism fixed with an in-memory journal; VX-462 the quiet set-up arm; VX-463
every words field concealed behind the shared field; VX-464 the account-naming refusals; VX-468 the what's-new
wait; VX-469 (c)'s confirm line; VX-473 the banner's library-fact read); and U4 THE PRE-DESIGN FACE.

**Her rulings, verbatim where quoted:** rule 27 amended at her word — "the account's passphrase or twelve words
recover them from the account" (both wrap the vault's master; CastleRules edited in place at `8a369f4c5`, the two
quoting comments and the runbook following). The refusal face first DECLINED at the morning sitting ("it's fine,
this is just for my testers & myself"), then SUPERSEDED the same day by the §8 addendum's byte-copy finding — her
real store's copy met 0.10 as a dead-end lobby — and she ruled U4 IN with her approved words: lead "This library
is from an older version of Variorum."; body "This version can't open it. Open the previous version to copy
anything out — or if it synced, your writing comes back when you sign in. Starting fresh sets this library aside,
whole, in Previous Libraries."; doors Start fresh… / Open Library…; the confirm "Your old library will be set
aside whole in Previous Libraries — nothing is deleted." (byte-pinned). The testers' choreography corrected by her
("how can they open the app and let it sync once before updating if it can't sync after deploy?") — the sync-once
window closes at HER deploy; her robust instruction "Copy out anything you need, then update and start fresh" is
the script's line, and the round-3 reinstall-clause split got her word ("yeah that's fine"). RESTORE.md rewritten
to the rules at her approval with her full edit pass; the two round-2 word corrections ("One copy a day lands in
each place"; the pane, not each row, says what opens a copy) APPROVED BY HER and landed (`514f8e60c`) — the
approval recorded here at round 3's ask. VX-465 accepted as designed (the one-library memory; a Low wording row
minted). Her in-session latitude with round 3 in flight — "you can run a fourth round if you think it's
necessary" — went UNUSED (round 3 passed with nothing structural).

**U4's fork, ruled under the mandate (THE RULING in the plan):** Start fresh's set-aside could not reuse the
planned-act machinery (a plan is sealed under a key; a pre-design store has none this build can hold) — ruled (a),
the whole set-aside by link → one `RENAME_EXCL` commit → unlink, resumed from the files' identity (device + inode,
never a byte), AND (D): both Open Library… landings and the gates ride the same act and fact. Round 3 read the
mover line by line and confirmed rule 20's substance.

**The cast and the ladder:** Fable orchestrated (L0, L1, the rehearsals, the stage batches, the walks, the fork
ruling) with three fresh Fable reviewers; Opus implemented (U1, U3, R1, the fix legs, the r1/r2 fix legs, U4 — one
fresh session each). Round 1: 1 MAJOR (record-class — the §2 proof claimed ahead of its record; the lesson "the
record is the proof, never the plan") + 6 MINOR + 2 NIT; the export-pin dispute UPHELD for the implementer (the
`-shm` counter-pin the pin of record, the reviewer's own pin withdrawn as hollow). Round 2: all r1 fixes
confirmed; 1 MAJOR (five stale runbook pins — fixed test-side as justified edits) + 2 MINOR + 2 NIT. Round 3
(final): PASS — 1 MINOR + 2 NIT, all wording/record-class, the orchestrator's own line-by-line fixes. The closing
runs: Mac 5097/892 (one red — the rewritten runbook literal's missing final newline, a one-byte drift both earlier
byte proofs were insensitive to; the suite's own pin caught it; fixed `190bf985e`) and phone 808/126 exit 0. The
§8 rehearsal answered the phase's one question YES on real Postgres (rule 15 across the switch: the backfilled
vault joined, the words moment spoke her draft byte-faithful, a fresh store pulled the pre-switch notes back
verbatim by the typed passphrase alone); the walk window proved her face and the whole set-aside live on her real
store's byte copy and landed VX-461's three live arms, VX-463/469's captures in both voices, VX-464's and
VX-473's.

**Born tickets** (triaged at the merge; the handoff lists them by priority): the MCP load-flake family, the export
stranger-sidecar refusal (Low), F-FL-2, F-R1-4, F-U3-2, F-U3-3, walks-never-run-rounds, the VX-465 counts-wording
row, the lifecycle never-list clause. The bundle QUESTIONS #238; the handoff `notes/handoffs/vx-329-handoff.md`.
MOBILE PARITY: `notes/MobileSoul.md` PL-51. HERS AT THE WINDOW: the marker-14 deploy (the vx307 checklist + the
pg_temp belt), both Macs' installs, her rounds, the release 0.10, the delta brief to the site agent, the
throwaway's deletion. Next: VX-470 leads the next run; VX-212 phase 6 right after the merge at her call; VM-8 on
the phone.

## 2026-10-23 — VX-494 (the 0.10 window's blocker: the large-corpus first catch-up; PR #185, merge 44226636b)

**The effort (the full record is `notes/plans/fixes/vx-494-catchup-hang.md` — THE EVIDENCE, HER EXPERIMENT'S RESULT,
THE FIX DESIGN, the live proof, the three ladder rounds' FINAL CALLS and fix records; the ladder
`notes/plans/fixes/vx-494-ladder-round-1.md` / `-round-2.md` / `-round-3.md`).** Run under `/architect-phase` overnight,
kickoff to merge in one night; the session moved Fable → Opus 5.5 at her word ~03:40 ("fable kept hitting the
safeguards"), and her rulings set the cast — **R-494-1** "yeah go with opus - i think fable will almost certainly just
hit a bunch of safeguards" (Opus writes `Sync/`, a fresh `opus-reviewer` per round), **R-494-2** the scope ("we can fix
1-3 tonight and then i'll do the other two once the castle switch is fully done" — VX-495 the server query and VX-496
the progress line minted for after), **R-494-3** the night ("I want everything to continue forward because I am now
going to sleep"), and her "use normal /architect-phase discipline".

**What was true:** there was no hang. The morning's server reading ("one pull call, then nothing") was the 13j rule's
blind spot — the device cursor is stamped only by a round's first window. The app's own log showed every round paging
her whole feed (~108k rows, ~550 calls of 200 rows, ~12 minutes) and being cut off before its one save: the 10-minute
Castle idle lock at 02:55:16 (~50 s before the head), then two quits. **Left alone, her Pro's crossing landed at 04:12**
(11 min 36 s of download, ~4 min 20 s of save).

**What shipped (SyncSpec §3/§5, AppSpec §7 — the contract lines in place):** **D1** — the pull window its own size,
2,000 rows (the server's served query seq-scans and sorts every eligible row per call, so page size barely moves a
call's cost: 200 rows 2.9 s, 2,000 rows 1.5 s at `since = 0` on her data, under the 8 s statement timeout); **D2** —
the download staged in the local-only `sync_pull_stage` (v1_32) so an interrupted round resumes, the stage's identity
the committed cursor + corpus key + device + stage format + lockstep marker + purge-ledger scan point, kept contiguous,
an undecodable row discarding it; **D3** — retiring a chain cancels its download (never its save — ladder R3). **The
live proof** on the throwaway at her scale (~110k generated rows): the whole download in 56 windows / ~70 s; a
`kill -9` DURING THE SAVE, then a relaunch that re-downloaded nothing, saved from the stage and committed at the head.

**The ladder (three fresh `opus-reviewer` rounds, the cap):** r1 1 MAJOR (F1 — a stage wedge on a drifted or
undecodable row) + 5 MINOR + 4 NIT; r2 1 MAJOR (R2-1 — a staged row escaped the purge ledger and could resurrect a
purged note) + 3 MINOR + 2 NIT; r3 1 MAJOR (R3-1 — D3's cancel reached the save, so a lock would have discarded
minutes of work) + 1 MINOR + 3 NIT. Each round's fixes by a fresh `opus-implementer` with red-on-old pins and
behavioral reverts; the final round's checked line by line by the orchestrator. VX-493's stranded-flag claim REFUTED
in code (the row reads `isConfigured` first; a lock replaces the services) — its real defect was D3's.

**Born:** VX-495 (the server query, High) · VX-496 (the progress line, High) · VX-497 (the save's duration, Medium) ·
VX-498 (the Standard set-up's stale "Sync locked", Low). **Hers (QUESTIONS #239):** local-only migrations vs. plain-text
exports (F6); does a resuming device count as "seen" (R2-3); the stage's disk slack (O-2: 79 → 150 MB); the Standard
join's Touch ID prompt (O-1); VX-492/493's closures; Pre-launch on 495–497; the belt's words; whether a lock should wait
for a save in flight (R3-1); VX-498. MOBILE PARITY: the phone inherits all three through the shared engine — VM-8's
acceptance measures its first catch-up (its save is the number to watch). canon-size 125,087 / 150,000.

## 2026-10-23 — the 0.10 window's close (VX-488's narrative; the window sitting; the release)

**VX-488 (PR #184, merge e63602bac, 2026-10-23 — "Run: the 0.10 window hotfixes"; the record
`notes/plans/fixes/vx-488-window-hotfixes.md`).** The run that unblocked her crossing: VX-487 (Castle + Touch ID left
the engine unable to read the sync keys — the act's castle/touchID arm now also holds them in session, and the Touch ID
unlock loads the account's item riding the same press, never a second prompt), VX-486 (the locked sync row's door now
opens Settings ▸ Protection and the line was reworded off the old-road vocabulary — P-VX486-1/-2, PROVISIONAL, ruled
"fine on provisional wording" at the window sitting, R-494-4 — the SurfaceContracts sentence landed at this close), and
VX-483 (the walk-rounds opt-in behind the production-ref refusal). The typed-unlock residue M1 (c) was recorded, not
built — ruled at the window sitting into **VX-501** (a typed unlock holds sync keys in session until lock; High,
Pre-launch). The Fable ladder ran as the standing rule demands for custody code.

**The window sitting (2026-10-23, the morning-to-evening session; every ruling verbatim in
`notes/plans/fixes/vx-494-catchup-hang.md` R-494-4…R-494-13).** Her Pro acceptance (9162, Synced); the post-merge Fable
cold review at her word (0 BLOCKER · 0 MAJOR · 2 MINOR · 3 NIT; FB-1/FB-4 doc fixes at her word); the Air's install and
her ~8-minute crossing; RELEASE 0.10 (build 9172) published (the DMG byte-verified, the appcast live, the Pro refreshed
to the published build; the release toolchain's X.Y.Z-only checks swept to accept X.Y); the site's
`/variorum/privacy` + `/variorum/support` drafted and deployed at her word, every served HTML comment stripped at her
ruling ("if it's just on the internet… it's getting scraped and saved. so remove that"); her #239 answers (a)–(i)
*[removed for publication]*
*[removed for publication]*
road's enrollment act chartered for git-history archaeology); **VX-508** found (a pre-0.10 vault keeps a dormant
Apple-wrapped master as artifact 17's left-unread history — one account; cleared at her word after its 0.10 join);
**her re-ruling closing the window: "forget about mobile, figuring out this exact issue will be the next thing that we
do… this is obviously the biggest issue right now"** — VX-510 ("Run: the first-run sync failures", Urgent: VX-498,
VX-507, VX-509, VX-506) runs next under a fresh orchestrator with several live accounts as the acceptance and
read-only production verification; VM-8 deferred behind it, its kickoff standing in the handoff's Appendix B.
canon-size 125,087 / 150,000.

## 2026-10-24 — VX-510 (Run: the first-run sync failures; PR #186)

**The effort (the full record is `notes/plans/fixes/vx-510-first-run-sync.md` — her rulings R-510-1…29, THE TRACE and
THE ARCHAEOLOGY, the units' records A · B1–B5 · L1, unit C's live drill on production, THE MAP, the ladder, the
re-walks, THE CLOSEOUT; her handoff `notes/handoffs/vx-510-handoff.md`).** Run under `/architect-phase` from her
2026-10-23 kickoff to a 2026-10-24 morning merge, across three orchestrators: the session moved Fable → Opus at
R-510-5 ("I keep hitting safeguards on Fable - keep going"); a successor ran the sanity check she asked for ("consider
the work that has been done with an OPEN mind, as an evaluator… was that test the right test?"), the ladder, the closing
stage batch and the first re-walk leg; a third (Opus, R-510-29: "it should run everything through provisionally
including just releasing the change") walked the Castle leg, restored the dev store and closed. Implementers were fresh
`opus-implementer`s, one per unit; the ladder ran on fresh `fable-reviewer`s.

**What was true.** On 0.10 no account act started a sync round: VX-329 U1 (`f2306a535`) deleted the old road's
post-enrollment round hook and never rewired it, so a Standard set-up sat at "Sync locked" until the user typed,
switched apps, pressed Sync now or relaunched — joins and Castle set-ups only seemed fine because a system Touch ID
*[removed for publication]*
vault only after the twelve-word re-entry, so closing the sheet left a passphrase and no vault (his "I don't think I
*[removed for publication]*

**What shipped (SurfaceContracts' protection bullet and CLAUDE.md's Environment — the contract lines in place):**
the first round after every account act that changes sync's standing, the re-keying ones on the reopen's fresh
services (F-6 (A)), and the act's sheet staying to show it (VX-498/VX-507); the not-yet row and the join's door
(VX-506); `FirstRunDrillTests` + `Tools/WalkKit/first-run-walk.sh` + release.sh's step 0 (VX-509); the prod test road —
Debug-only, a handed allowlist of `vxtest` accounts, her R-510-1/-6; the typed Castle unlock loading the sync keys
(VX-501, her R-494-4 direction); the words card retiring at a landed set-up/join/Move (VX-511 — R-510-14, and CastleRules
rule 2's clause at R-510-28); vault-first key derivation so the Standard join never presses Touch ID (VX-503); the
read-only check door (VX-513, R-510-15); Standard-never-reads-Touch-ID + forgets by name (VX-517, R-510-16 — F-B4-1
accepted as residue); the lobby's words door as one press target (VX-527 — the words and their row open it; the 4 pt
reach past the label is not honoured live, VX-535). No `Sync/` line; core changes only in `Protection/`.

**The acceptance, live on PRODUCTION through the named road:** three fresh accounts (std, castle, del) — sign-up,
set-up, the first round with no relaunch, joins from a restored copy and from a fresh library (the testers' road), key
changes, older backups opened with old/current/new secrets in Castle, the account deletion leaving zero rows — every leg
read back server-side; on the final build, a re-minted fresh account's first run end to end, then the Castle leg (join,
Use Castle, the typed unlock, the check door, the Standard side with no auth window). **The ladder:** r1 0 BLOCKER ·
0 MAJOR · 3 MINOR · 2 NIT → unit L1 + O-L1-1 (a line-wise guard in the prod-confirm script — the same class as F-R1-5) →
r2 0 · 0 · 1 · 1, every fix SOUND, the final two checked 2/2. **The closing stage batch:** the core whole green (VX-532's
timing test isolated ×2), the whole Mac target 5221/915 with the real-keychain Touch ID arm RUN, the phone 62/7 + 47/15.

**Her closeout answers:** release 0.10.1 after the merge (R-510-22); keep all three test accounts (R-510-23); VX-521 and
VX-528 closed (R-510-24/-25); the wording bundle stays provisional (R-510-26 — QUESTIONS #240); Pre-launch = VX-529 only
(R-510-27); CastleRules rule 2's clause (R-510-28: "yes. I think that makes it logically consistent, right?"). **Born:**
VX-511…VX-537 (VX-514 canceled; VX-521/VX-528 closed at her word) — VX-529 (a pair changed on one device strands the
others; High, Pre-launch) is THE NEXT RUN at her R-510-19/-20 (no rule or storage change: "we are NOT changing the
castle rules at all"). MOBILE PARITY: PL-58. canon-size 125,663 / 150,000.

## 2026-10-25 — VX-529 (the catch-up for a pair changed elsewhere; PR at the merge)

**The effort (the full record is `notes/plans/fixes/vx-529-pair-catchup.md` — the design memo, her rulings R-529-1…8,
the units 1–3 and ladder fix sessions L1/L2, the ladder, the closing stage batch, the live proof on production, her
two-Mac test; her handoff `notes/handoffs/vx-529-handoff.md`).** Run under `/architect-phase` from her 2026-10-24 kickoff
(the boundary R-510-20: "we are NOT changing the castle rules at all… we aren't changing anything stored anywhere") to a
2026-10-25 merge and release. A Fable orchestrator ran the memo, the sittings, the units and the ladder; Fable's
safeguards stopped the live walk twice (`[cyber]`), and at her `/model` an Opus orchestrator took over the same session
for the walk, her test and the closeout. Implementers were fresh `opus-implementer`s, one per unit; the ladder ran on
fresh `fable-reviewer`s.

**What was true.** A passphrase or new words made on one device left every other device on the old pair: rule 7 says a
synced device holds the account's pair, but the follow covered only posture changes and key replacements, so a lagging
Castle device couldn't sync on its passphrase, a lagging Standard device synced with a silently stale one, and the key
doors refused the old passphrase with the false "doesn't open this library" (the VX-510 repro on production).

**What shipped (SurfaceContracts' protection bullet — the contract line in place):** quiet detection from the key
file's own locks against a fresh vault read (fact 1's invariant pinned across all 24 synced roads — no stored field);
the pair follow as the follow's third kind — a re-lock, never a re-key, no server write, an older-build-safe two-step
plan; either current secret catches up (R-529-5, the forgot road — typed words drop the stale passphrase lock); a
words-only change catches up with nothing typed (R-529-2); the key doors refuse naming the change and point at the
follow (R-529-3); the lobby's vault road — the account's current passphrase opens a lagging library through the vault
and lands the catch-up in the same press (R-529-1, her pick after her "how is it happening online?" questions); the E6
heal and VX-538's recurring band card (R-529-6 — the why and the road, her "until it's done"); the check door's
pointer; Make this my library's proof fields so a restored copy's join stays quiet (R-529-7, VX-523). Riders VX-526,
VX-522, VX-523, VX-530 (trace-first: exactly redundant Touch ID reads), VX-533, VX-538. Zero `Sync/`, `Server/` or
`notes/CastleRules.md` lines; no schema; no stored-shape change.

**The acceptance.** The ladder: r1 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT → L1 (the futile vault read gated) and L2
(VX-523 under R-529-7) → r2 every fix SOUND, 0 · 0 · 0 · 2 record NITs. The closing stage batch: the Mac target 5231 of
5265 (the 2 failures proven VX-539 on main), the phone 808/126. **Live on production** (the `castle` test account, D0–D7):
the quiet words catch-up, the everyday passphrase catch-up with the old passphrase retired, the vault road in Castle
(one typing, then a local open after ⌃⌘L), the words arm and E6's card and heal, the restored copy's quiet join, and a
clean restore of the dev store by its recorded inodes. **Her two-Mac test, her real Macs and account (Castle + Touch
ID):** the Pro changed the passphrase; the Air kept syncing, noticed while running, and its lock screen opened by the
NEW passphrase with the catch-up landing in the same unlock; the new passphrase then opened it offline and loaded the
sync keys online; Touch ID intact; new words made on the Air were caught up quietly on the Pro and verified there.

**Her calls:** R-529-1…7 at the sittings; R-529-8 — merge and release 0.10.2 ("let's get this merged & get a release
minted"; the notes approved verbatim); VX-544 and VX-542 later. **Born:** VX-538 (rode), VX-539, VX-540, VX-541, VX-542,
VX-543, VX-544. MOBILE PARITY: PL-59.

**The release:** 0.10.2 (build 9462) shipped 2026-10-25 at her word — published to stargazing.tech (the DMG first,
then the appcast and the page, every verify PASS) and installed on the Pro behind a fresh A1; the run record's THE
RELEASE section.

**Her answers to the bundle (2026-10-25, QUESTIONS #241 — her words there):** both drafted CastleRules clauses ratified —
rule 3's synced-library-with-no-typed-passphrase card (VX-538's) written now; rule 7's "…backups made with them" lands at
VX-545 with the app's sentence (a test pins the two together);
the sentences stand as built until her wording pass; the E6 heal (P-VX529-4) ratified; the second road's placement
stands (never the only road — no ticket); the wrong-passphrase wait bound and the restored copy's lobby line
accepted. Born: VX-545 (the app's rule-7 sentence and the lifecycle page follow the rule).

---

**2026-10-26 — VM-8, the phone's Castle catch-up (PR #191, merge `319aa684d`; the record
`notes/plans/vm-8-castle-catchup.md`; QUESTIONS #242; the parity row PL-60).** §12 Doors ▸ Library protection: the
phone's sentence in `notes/SurfaceContracts.md` changed in place — the phone now carries, over the same shared faces,
its pre-design face with Start fresh (no Open Library door exists there), the Settings ▸ Protection screen with the
account section (the join "Sync this library…", the words moment, the first-round sheet that stays), the entering
crossings with the Face ID gate choice, the key doors and the passphrase setter, the follow's in/into and pair arms
(the follow-owed refusal once per screen, follow-locked sections hidden whole — a ruled-at-ladder phone divergence
from the Mac's R-529-3 in-place refusals, hers to keep or align), the check door and a quiet receipts line; every
leave-direction arm is deliberately unrendered pending her rule-12 phone wording (F-PH-2 → VM-28, Pre-launch for
mobile's launch), and rule 11's export-off notice never fires on the phone (no scheduled export exists there). The
acceptance was her own device moment: her iPhone 17 Pro pulled her library whole under Castle + Face ID, the staged
catch-up resumed live across a suspend, and the save measured ≈ 4–5 minutes on her corpus (VX-497 stays open at her
word). The run's rulings, her sitting words verbatim, the ladder's three files and the born tickets (VM-24…VM-31,
VX-546, VX-547) are the record's; nothing in CastleRules changed (her frozen-design word held: zero `Sync/`,
`Server/`, `Persistence/`, `CastleRules` lines).

**→ VX-502 (2026-10-27, one overnight /architect-phase run — the record
`notes/plans/fixes/vx-502-export-across-migrations.md`; the ladder `vx-502-ladder-round-1.md` · `-round-2.md`; the
walk `vx-502-walk-script.md`; her handoff `notes/handoffs/vx-502-handoff.md`; PR #192, merge `32fb88ec6`, tip `683068fbb`).** §12
Doors ▸ Library portability: the plaintext-export clause in `notes/SurfaceContracts.md` changed in place — an
export from an earlier build imports (its applied migrations a subset of this build's known set), one written by
a newer Variorum refuses at the pick. HER RATIFIED RULE, on the ticket (2026-10-27): "accept any export whose
applied set is a subset of the importing build's known set; newer-than-me still refuses" — superseding
P-VX309-U1b-7's exact-match PROVISIONAL (VX-494's F6; #239(a); her R-494-6 word: "yeah, I agree that we should
fix this. Put it on pre-launch"). The subset rule is safe because no content-bearing export predates v1_31 —
VX-461's sandbox fix is the floor (a unit-A finding corrected the record's own first premise, which had credited
vx-309). The gate (`PlaintextExportReading.plan`) now throws only `schemaNewer`; the "earlier build" face is
deleted; the era-frozen guard pin (frozen at `v1_31_protection_record`, the 0.10 writer's drop list a literal)
mechanizes the standing feature-detect duty over BOTH gates — the classifier and the reader. Her overnight word,
in-session, verbatim: "make sure that the castle backup restore is solid & if it needs to be tested with a
passphrase change in between to verify that the old one still works AND the new one works, that's authorized. I
want it fully tested" — the Castle-restore walk ran ALL 13 LEGS GREEN on the dev store (the castle vxtest
account; the as-found held library preserved byte-whole and hand-returned, coordinator-confirmed): rule 5's floor
(the old pair opened the pair-change-era backup), rule 6 (the new passphrase opened it through the history),
rule 7 (the account re-wrapped with both changes), rule 17 (fresh key; the old passphrase REFUSED at the restored
lobby), rule 21 (the hand-return's notice), R-529-7 (the quiet words moment) — NO finding against CastleRules;
VX-510's R-510-2 restore gap is closed. The ladder: round 1 (fable-reviewer) 0·1·1·1, round 2 (opus-reviewer,
final) 0·0·2·4, every finding dispositioned, the final fixes orchestrator-checked line by line; the stage batch
594 tests executed in 109 suites, 0 failed. Cast: Fable orchestrated; one Opus implementer; one Opus walk
session; stage and merge order through the night's coordinator (first merger of the export-seam pair — VX-439
rebases). Born tickets: none. A provisional act for her: `type-dev-castle-secret` (the dev-pair typing road,
--check-guarded; her bundle item 2).
