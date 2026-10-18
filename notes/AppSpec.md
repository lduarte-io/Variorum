# Variorum — App Spec

**Status:** the single source of design truth for this project — the CONTRACT. Evolved from `notes/source/SPEC.md` (superseded; §14 lists the deltas). **A line here says what is true now, plus one pointer.** The narrative behind every rule — the dated rulings, the author's verbatim words, ladder findings, supersession histories — lives in `notes/AppSpecRulingsArchive.md` (canon, not context-loaded; two editions of this document, same section numbers: the pre-2026-09-26 file and the 2026-10-18 pre-pass edition of §7/§9/§12/§14) and in the phase plan and fix files this document points at. A pointer here reads *(archive §N)*, names a ruling (R-…, P-…, U-…, S4-…), a QUESTIONS number, or a plan file. Deltas since the source spec: `notes/AppSpecDeltaArchive.md`.
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
CREATE INDEX idx_commit_created ON commit_point(created_at);  -- the Library day search's savepoint arm
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
  wing_id                TEXT NOT NULL DEFAULT '',  -- '' = the virtual Home wing (R-13ia-2)
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

### wing — in-store libraries (v1_18)
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
> **The Home wing is VIRTUAL (R-13ia-2):** rows here are ADDITIONAL wings only; every `wing_id` pointer (`container`/`tag`/`reading`/`shelf`, each `TEXT NOT NULL DEFAULT ''`) means Home when `''` — undeletable and convergence-proof by construction, no seeded row to race. Wings isolate totally: gatherings assemble, and search/tag listings/Arrivals scope, within ONE wing; the only crossings are the explicit move/copy doors. (archive §7)

### shelf — the Bookcase's groupings (v1_18; `reading_section` one level up)
```sql
CREATE TABLE shelf (
  id           TEXT PRIMARY KEY,
  owner_id     TEXT,
  wing_id      TEXT NOT NULL DEFAULT '',  -- '' = Home; shelves are per-wing
  name         TEXT NOT NULL,             -- duplicate names legal
  glyph        TEXT,                      -- ONE grapheme, monochrome (the callout frame's precedent)
  role         TEXT,                      -- NULL | 'welcome' — the seed marker (SyncSpec §7's Welcome keeper's key)
  position     TEXT NOT NULL,             -- strip order = All's stacking order
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  deleted_at   TEXT
);
CREATE INDEX idx_shelf_wing ON shelf(wing_id, position);
```
> An ordered named metadata row a pointer names (`reading.shelf_id`) — never a container, never nested. A nil or DANGLING pointer means UNSHELVED (unshelved shows at the top of All, in no shelf's solo). Deleting a shelf returns its books to unshelved and never touches a book.

### reading — books and gatherings
```sql
CREATE TABLE reading (
  id              TEXT PRIMARY KEY,
  owner_id        TEXT,
  name            TEXT NOT NULL,
  kind            TEXT NOT NULL CHECK (kind IN ('book','gathering')),  -- a BOOK holds membership rows as
                                               -- truth; a GATHERING is a saved rule assembled at read
                                               -- (v1_18 migrated curated→book, smart→gathering — the code's
                                               -- older spelling)
  profile         TEXT,                        -- 'journal' (the TRAIT) | 'book' | 'collection' | 'daily' (THE
                                               -- daily Journal's marker)
  sort_field      TEXT NOT NULL DEFAULT 'manual'
                    CHECK (sort_field IN ('manual','entry_date','created_at','last_touched','last_major_revision')),
  sort_dir        TEXT NOT NULL DEFAULT 'asc' CHECK (sort_dir IN ('asc','desc')),
  grouping_tag_id TEXT,                        -- section a SMART book by a tag root; a dangling id reads as ungrouped
  query_spec      TEXT,                        -- the v2 RULE: gatherings' assembly + living books' intake
  max_posts       INTEGER,                     -- extent constraint (fixed-length journal)
  word_target     INTEGER,                     -- words TARGET (v1_11): display/progress only, NEVER a refusal
  locked          INTEGER NOT NULL DEFAULT 0,  -- FINISHED: assembly frozen, intake paused, text editable
  wing_id         TEXT NOT NULL DEFAULT '',    -- '' = Home; books never span wings
  shelf_id        TEXT REFERENCES shelf(id),   -- nil/dangling = UNSHELVED
  shelf_position  TEXT,                        -- "my order"; nil = never placed, appends last
  starred         INTEGER NOT NULL DEFAULT 0,  -- the one star (absorbs the retired pin list)
  owned           INTEGER NOT NULL DEFAULT 0,  -- ops enforce; SyncSpec §7's exclusivity repair converges
  sealed_at       TEXT,                        -- SEALED = Finished + text immutability; the exact-stamp unseal key
  hide_owned      INTEGER,                     -- a gathering's toggle; NULL = the global default (SHOW, badged)
  intake_seating  TEXT CHECK (intake_seating IN ('auto','arrivals') OR intake_seating IS NULL),  -- the join dial
  auto_tag_id     TEXT REFERENCES tag(id) ON DELETE SET NULL,  -- RETIRED-AS-READ since v1_20 (stays a synced
                                               -- column — SQLite cannot drop an FK column)
  auto_tag_ids    TEXT,                        -- THE OUTFLOW (v1_20): a CHOSEN, OPTIONAL SET of tag ids as a JSON
                                               -- array, independent of the intake rule; NULL = none; PLAIN under
                                               -- E2EE (ids only)
  archived_at     TEXT,                        -- BOOK ARCHIVE (v1_21): domain archive, kept-but-out-of-view forever
                                               -- (never a step toward deletion); books AND gatherings; auto-ingestion
                                               -- pauses while set, explicit adds stay open; PLAIN (a timestamp)
  created_at      TEXT NOT NULL,
  updated_at      TEXT NOT NULL,
  deleted_at      TEXT,
  FOREIGN KEY (grouping_tag_id) REFERENCES tag(id) ON DELETE SET NULL
);
```
> **A GATHERING REQUIRES A RULE (R-13ic-4):** the mint and the rule write refuse a NULL `query_spec` on a gathering (`gatheringRequiresRule`); a gathering with NO rule — reachable only as a Trash restoree — assembles EMPTY everywhere (the malformed rule's closed reading). A BOOK's NULL rule stays "collects nothing by itself".
> `query_spec` holds the **v2 rule grammar** (`Domain/RuleGrammar.swift` — a boolean tree of tag-by-ID and star terms: subtree matching, renameTag-proof, dead terms match nothing; v1 specs migrated with legacy profile/date terms GRANDFATHERED — still parsed and evaluated, never malformed; a NULL is no rule, malformed fails closed per consumer). `profile='daily'` is THE daily Journal's marker (the mint stamps it, `setDailyJournalBook` moves it, SyncSpec §7's keeper keys on it); `'journal'` is the TRAIT every deliberate notebook door mints. (archive §7)

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
                CHECK (status IN ('member','arrival')),  -- an ARRIVAL is intake's bell — synced, visible, NEVER
                                               -- counted/listed/worded as membership (every member-reader
                                               -- filters status='member'). Tombstoned 'arrival' rows are the
                                               -- DISMISSAL-RECORD class (a judged dismissal, finishing's sweep,
                                               -- an un-bind's residue); sweeps honor ANY row, while a FRESH
                                               -- applying act re-poses a DISMISSED pair at the door (never
                                               -- seated) and a removed MEMBER stays decided
  created_at  TEXT NOT NULL,
  deleted_at  TEXT,
  FOREIGN KEY (reading_id) REFERENCES reading(id),
  FOREIGN KEY (post_id)    REFERENCES container(id)
);
CREATE UNIQUE INDEX uq_reading_post_live ON reading_post(reading_id, post_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_reading_post_order ON reading_post(reading_id, position);
CREATE INDEX idx_reading_post_post  ON reading_post(post_id);
```
> Deliberate asymmetry with `container_block`: blocks are singly owned; posts are non-exclusively pointed at — that is what makes on-demand books work. The opt-in per-book **Owned** relationship bends this for books that want it, enforced operations-side with an apply-time repair, never a schema containment (`notes/plans/phase-13i-smart-book-identity-brief.md`).

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
  wing_id    TEXT NOT NULL DEFAULT '',         -- '' = Home; a cross-wing move/copy ADOPTS the destination's
                                               -- same-path tag's id (R-13ia-1)
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT,
  FOREIGN KEY (parent_id) REFERENCES tag(id)
);
CREATE UNIQUE INDEX uq_tag_path_live ON tag(wing_id, path) WHERE deleted_at IS NULL;  -- the vocabulary is
                                               -- PER-WING; the same path in two wings = legal twins
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
> No uniqueness (no repair class). Comment `text` is metadata under sync (server-wins CAS), deliberately not S5. Deleted comments stay visible and resurrectable — until deleted forever: `block_comment` is the SIXTH purgeable kind on the purge road (tombstoned rows only; a dead block's comment refuses as a cascade victim; a sealed post refuses). Travel across structural ops is the operations layer's (§9), never a trigger's.

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
-- NOT seeded (defaults applied at READ time in Queries.ThemeSettings / Queries.AppearanceQueries): theme_voice,
--   fan_style, receipt_style (toast · quiet · off, default QUIET), theme_palette, theme_tint, theme_accent_tint
--   (validated hex or ''), savepoint_cadence, daily_journal_book (RETIRED-AS-READ — the designation derives
--   from the 'daily' marker; the writers keep the key fresh as a cache), arrival_flash ("1"/"0", default ON — the mode-switch arrival flash),
--   hide_owned_default ("0" = SHOW badged — gatherings/listings/search, Library EXEMPT) and ownership_badges
--   ("1" = on — the badge family toggles as a set).
```
> Settings are synced document semantics (segmentation must match on iOS capture): `sync_version` per §6, upsert-only, never tombstoned. **E2EE constraint: `setting.value` is classified PLAIN under the promise "enum semantics, no prose" — no future setting key may carry user-authored prose; a prose-valued setting must re-open the column's classification.** `container.segmentation_default` overrides per post; `profile='journal'` seeds `one_block`.
>
> **Segmentation / the Return key:** fresh-text segmentation is type-time crystallization — while typing new text at the end of a post, each completed paragraph silently becomes a block; the trailing paragraph is an open tail. Bulk entry (paste, import, drop, mobile capture) segments on entry. Once a block exists, a NEWLINE inside it is content (I4). **On the Mac, with the segmentation chip ON, the Return KEY is a structural gesture routed through the one structural door** (`TypedReturn.act`, `Shared/EditorBrain`; the intercept at `EditorTextView.insertNewline(_:)` after the list door): an empty block below at a block's end, a divide at the caret inside its text (single-take in place; fanned → keep-on-top), an empty block above at its start, and in an EMPTY block another empty block below, chaining indefinitely; an abandoned empty block stays. ⇧⏎ is the newline that stays inside the block. The chip OFF returns the note to Return-as-content. Crystallization is untouched; the tail opens only from a newline arriving as text. The phone's Return model is its own. (Rulings U-1, U-19, R-13u4-2 — archive §7; unruled edges QUESTIONS #92.)

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
**Later SYNCED additions** (each a SyncSpec §12 lockstep event; the migrations are the DDL): `canvas_layout`, `lens`/`lens_choice`, `purge_intent`, and the PRIVATE MARK (v1_25, marker 13 — `Server/supabase/16_phase13nb_private.sql`): `container.ai_private_at` + `reading.ai_private_at`, nullable PLAIN timestamps (structure only on the wire — that something is marked, never which words), the AI-private fence's store truth (privacy wins ties, Private ⊥ Owned, gatherings refuse the mark).
**LOCAL-ONLY DERIVED, never synced** (no mirror, marker untouched; rebuildable from truth): **the search-index family** (v1_22–v1_23: `search_doc` + the `search_fts` external-content FTS5 table over the `search_text` view + shadows), maintained by the third trigger duty, rebuildable from truth (`Operations.rebuildSearchIndex`/`verifySearchIndex`), registered as `SyncSchema.derivedTables` — subtracted by the completeness walk, KEPT by the plaintext export so the no-lock-in file searches by itself; savepoints (`commit_point.text`) are the NINTH kind, listed only under the explicit commits facet, `search_doc.variant_id` the savepoint doc's own-row parent fact and its liveness resolving at QUERY time through variant → block → placement. **LOCAL-ONLY, never synced and NOT derived — the MCP GRANTS family, the door's only local truth** (v1_24 → v1_30): per-client × per-scope grant rows (the four rungs), the open-book switch, the activity log, the per-setup key pair (`mcp_setup_key` — a copied setup's key BY HASH until a name presents it — + `mcp_client.setup_key_hash`, the key bound to the name), `mcp_comment_author` (a comment's writing client by comment id, written in the comment's own transaction; no FK, purge-safe, the export STRIPS it; + `text_digest` — a comment stays the client's own only while its words are unchanged; NULL reads as unproven), `mcp_rebind_request` (a setup key waiting for her OK under an approved name, one row per client, the newer replacing the older; the key's HASH never the key, plus the declared version), and ONE standing grant row per client × place (a partial unique index; a new grant replaces the pair's row) — the door's LOCAL truth, decided per call by the pure `Domain/MCPGrantRule` (`notes/MCPSpec.md`; the records are the vx-168 · vx-184 · vx-246 · vx-348 fix files under `notes/plans/fixes/`). **The `protection_record` table** (v1_31) is local-only too (the plaintext export drops it). (archive §7)

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

Every mutation is one of these, one transaction each, through the operations layer. Text-changing ops update `container.last_touched_at` and churn (§10). Structural ops (divide-W, merge, poolDragCopy, …) stamp `last_touched_at` but never churn. Exact row-level transitions are pinned by the operations test suites. **Standing conventions** (each op inherits them unless it says otherwise): a sealed post refuses every authoring write under it; a locked take guards its BUFFER (edits refuse; branch or unlock); identity-level metadata setters are no-op-guarded (no touch, churn or outbox row when nothing changes); comments and the callout frame TRAVEL to structural successors (below); an `expectedText` precondition that no longer matches refuses as `bufferChangedSinceGesture`. The narrative behind each op — her words, the ladder findings, the PROVISIONAL numbers — is archive §9 under the same name; rulings after 2026-09-26 are in the plan file each line points at.

**Blocks, variants, savepoints**
- **newBlock(container, text, at)** — INSERT block + variant(working_text=text); set `default_variant_id`; INSERT container_block(chosen=variant, position). Registers structural undo (a tombstone flip) **except type-time crystallization**, which passes `registeringUndo: false` (not a gesture).
- **autosave(variant, text, charDelta)** — UPDATE `working_text`, `updated_at`; accumulate churn; threshold-cross ⇒ stamp major revision, reset, rebaseline (§10).
- **commit(variant, kind=manual, message?)** — INSERT commit_point(text=working_text). Counts as a major revision. Refused on a locked take and under a seal.
- **Quiet auto-commit occasions** (`kind='auto'`, deduped against the take's last savepoint when the text is unchanged): sealing a post; locking a dirty take; the idle backstop (`idle_commit_hours`, default 2 — `idleAutoCommit(post)`, at most one per idle period); a structural undo about to overwrite a buffer edited since the operation; `closeAutoCommit` when a note with unsaved changes stops being shown (the everyday cadence); a cross-block compound about to overwrite the takes it edits (`insureTakes`); `moveSpanToNewTake`'s pre-move insurance; and the MCP door's `edit_take` bracket ("before/after ‹client›'s edit", deduped, +1 ms after-stamp; `notes/MCPSpec.md`). `savepoint_cadence` governs the two CADENCE occasions (close, idle) only; the insurance occasions are always on.
- **restoreCommit(variant, commit)** — UPDATE `working_text = commit.text` (old commits remain, I5). A commit may predate a structural op — restoring resurrects the pre-split text into this block while the successor still stands; the editor warns.
- **renameCommitPoint(commit, message?)** — set/clear `message`; nil clears; a no-op writes nothing and earns no receipt; refuses under a seal (checked before the no-op short-circuit); ALLOWED on a locked take (PROVISIONAL #121). The snapshot text is immutable; `message` is plain metadata CAS under sync.
- **branchVariant(block, fromVariant)** — INSERT variant(parent=fromVariant, working_text COPIED, fan_position=next). *The default gesture.* **newBlankVariant(block)** — the same with `''`.
- **moveSpanToNewTake(variant, span, expectedText)** — MOVE alone, ONE transaction: (1) a quiet auto savepoint of the current take (LOAD-BEARING: the ruled cover for the stay case); (2) UPDATE the take's `working_text` = buffer minus the span, exactly as selected, no snapping, no trimming (a doubled space at the seam is hers — PROVISIONAL #128); (3) INSERT variant(same block, parent=that take, text=the span, fan END, label NULL) — never chosen, never born locked. ONE structural-undo entry with exact-row redo. Touch + churn as a buffer edit. Refuses: sealed post, locked take, archived/tombstoned take, dead block, stale `expectedText`. I10 untouched (the source keeps its remainder; empty is legal). (R-13u4-4)
- **lockVariant / unlockVariant** — UPDATE `locked`. Locking a dirty buffer first appends one quiet auto commit. Refused under a seal.
- **archiveVariant / deleteVariant** — archive: `status='archived'`; delete: tombstone (must not be any slot's chosen variant — re-point first; the operations-layer check is the ONLY live enforcement, since tombstones are UPDATEs and RESTRICT never fires). Either: if it was the block's last live active variant → refuse (I10; delete the block instead). If it was `default_variant_id` → reassign to the most recently updated active variant.
- **`default_variant_id` lifecycle:** set at `newBlock`; reassigned on delete/archive of the variant it names; never NULL while the block is live (I10 + reassignment). It is the pointer-free representative; `container_block.chosen_variant_id` always wins where a pointer exists.

**The split taxonomy** (OverallModel §7; **one snapping rule everywhere** — plain divide, the ceremony's per-take cuts, `CutPropagation`'s seeding and extract's span edges all consult the Domain `BoundarySnapping`: a cut may fall between any two words and at newlines, word-edge floor, gentle settle onto sentence ends and newlines — S4-22)
- **extract(blockA, span)** — *source survives.* Span must be a boundary-adjacent prefix/suffix of A's active variant. INSERT block B + variant(span); UPDATE A's active variant = remainder (other variants untouched); INSERT container_block(B) adjacent; edge(B derived_from A, 'extract'). A middle span is a divide. Extracting from a FANNED block edits only the chosen take (the other takes keep their span — accepted; the editor may hint).
- **divide(blockA, cut)** — *source consumed.* **Single-variant (in place):** INSERT block C + variant(A[cut:]); UPDATE A's variant = A[:cut]; INSERT container_block(C) after A; edge(C derived_from A, 'divide'). Start/end cuts refuse (`invalidCut`). **Fanned block, the DEFAULT — keep-on-top (U-2, both platforms):** the displayed take is cut into B and C and every OTHER active take rides WHOLE onto B (`KeepOnTopDivide`, composed from divide-W's parking rule; zero new operation); the keep-below mirror is the second preset.
- **divideW(blockA, marked takes + cuts, displayedVariantID?)** — *the ceremony ("Divide choosing takes…").* A is PRESERVED WHOLE (placement released, unmarked takes stay on A as lineage); for each marked take Vi, a first-half variant on new block B and a second-half on new block C; placements B then C where A stood; edges (B derived_from A), (C derived_from A, 'divide'). **Parking:** a take whose cut sits at its very END rides whole into B, at its very START into C — so B's and C's fans are independently sized. Refusals: every take parked at the same end (`divideSideWouldBeEmpty`, I10 at birth); an empty take's cut (`invalidCut`). A parked take keeps its label; `displayedVariantID` anchors each side's chosen/default (nil keeps A's rendered take — PROVISIONAL #91). Reversible by re-pointing at A (`placeBlock`). The sheet's presets: Keep takes on the top block (default) · on the bottom block · Copy takes to both (`divideDuplicating`) · Choose per take….
- **divideDuplicating(blockA, displayedVariant, cut)** — the displayed take's halves seed B and C (each side's chosen + default); every OTHER active take is duplicated WHOLE onto BOTH successors (fresh UUIDs, labels ride, parent trees remapped per copy set, never born locked, commits never copied); A released whole; edges as divide-W; comments copied to both; presentation inherited; archived takes stay on A; touch without churn; ONE undo entry. Start/end cuts refuse. Accepted consequence: a duplicated take chosen on both successors reads twice. The third preset.
- **merge(B, C)** — *mirrors W.* INSERT block A′ + variant(text = chosen(B) + `"\n"` + chosen(C) — **the RENDERING join: exactly one newline, byte-exact, no trimming (R-13u4-3), on EVERY merge DOOR**: the block ▾ menu / ⌘⇧M, the context menu, the palette, the N-way chain, the bulk bars, the ceremony's per-pairing default, the phone's Merge with Previous, Make Block across blocks). **The DELETE keystrokes keep their own join** (the seam ⌦/backspace carve and the cross-block compound's mid-paragraph edge-join — `Domain/MergeJoin.swift`'s `MergeJoinRule`). Replace both placements with A′; edges (A′ derived_from B), (A′ derived_from C, 'merge'); B, C released to lineage (stamping `last_container_id`); fans never cartesian-producted; comments from both sides carried; presentation kept only when both agree, else plain. Refuses under a seal; adjacency required.
- **mergeCeremony(B, C, pairings, carries)** — *"Merge choosing takes…"* (S4-23). Each hand-placed pairing mints one joined take (explicit join: newline by default · space · nothing); each carried take rides onto A′ whole; the rest stay with the released sources. A take participates in at most one pairing (1:1, PROVISIONAL). Zero pairings and zero carries refuse (`mergedBlockWouldHaveNoTake`). Everything else as `merge`. Presets: Bring every take (default) · Only the two shown · Pair by hand…; **over three or more blocks the door offers only the first two** (U-16). The no-fan merge stays byte-unchanged.
- **poolDragCopy(P → post, at, includeFan=false)** — INSERT block B + the rendered take (or the whole live fan with archived takes riding, statuses preserved; commits never copied; not born locked; parent tree remapped); INSERT placement at the drop; edge(B derived_from P, 'pool_copy'); comments and presentation copied, `name` never. P stays. Pool→draft is the only copy direction.
- **importDocument(file) / importBook(folder, shelfId?)** — the Variorum document format's in-doors (`notes/plans/phase-13n-a-document-format.md`): the format IS the fan export plus the capture-token header, parsed as `joinRenderedTexts`'s EXACT INVERSE (rows round-trip in the stated domain; any export re-imports whole; refusals are fail-honest with line numbers). A file mints a bookless note in the Pool; a folder mints an unshelved book (subfolders = chapters, digit-aware order; `shelfId` = the drop's context mint). ONE transaction and ONE compound undo entry each — the inverse tombstones exactly what was minted on one stamp, the stamp-keyed redo revives those exact rows (an inverse that tombstones nothing never overwrites the stamp). The in-place text is each block's chosen take AND default; labeled takes join the fan's end unchosen; tags adopt-or-mint by path through the one application road (living books hear them); touch without churn; the E13 name guard preflights. The EXPORT pin stands untouched: no export path writes a row; a file is bulk entry, never reconciled truth.
- **moveBlock(block → container, at)** — UPDATE `container_block.container_id` + position (I2 by the live-unique index). **reorder(block, between A and B)** — `position = FractionalIndex.between(...)`. **placeBlock(block, container, at)** — INSERT a placement for a live block with NO live placement (a released-to-lineage block, a tray restoree); the primitive structural undo emits.

**Deletion, restoration, the tray**
- **deleteBlock(block, requiring: precondition = .none)** — tombstone block + placement; set `last_container_id`; trigger-cascade tombstones variants, comments, edges. `.none` is the ordinary door; **`.emptyWithNothingUnshown(variantID:)`** is the seam-backspace carve's authorization, RE-CHECKED INSIDE the tombstone's transaction (the named variant must be the block's ONE live variant, active, unlocked, empty, under an unsealed post, with no live comment; else `blockCarriesUnshownText` / `bufferChangedSinceGesture`) — a caller-side check would read the editor's deliberately-stale projection. The same precondition rides the structural redo. **The carve's caret lands where the deleted line break was** — at the end of the block before it when the carved block sat after the separator, else at the start of the block after it (QUESTIONS #33(d) still decides WHICH block goes); Delete Block and archive keep their own landing (the start of the block below, else the end of the block above).
- **restoreBlock(block)** — clear the block's tombstone and those of children carrying the SAME `deleted_at` stamp (cascade victims; independently-deleted rows stay dead); then `placeBlock` into `last_container_id`. A tag application revives only if its tag is live.
- **restoreContainer(container)** — the same exact-stamp rule over placements, their blocks and children, memberships, post tags, references. Rows whose story diverged stay as they are (a block independently revived keeps its current placement; a membership whose reading died stays dead).
- **restoreReading(reading)** — exact-stamp revival of its chapters and memberships; a membership whose post has since died stays dead; assignments reattach for free; smart readings restore by the flip alone; refuses when live. No undo entry (the door is the recovery). Documented corner: a member post that died AFTER its reading is left out — add it back by hand.
- **Structural undo / redo** — session-scoped, in-memory, structural ops only: divide (all forms), merge (both forms), extract, newBlock, deleteBlock, deleteVariant, archiveVariant, moveBlock, reorder, poolDragCopy, moveSpanToNewTake, **deleteTag** (ONE "Delete Tag" entry — the inverse revives the subtree's tag rows with paths REBUILT from the live parent, plus their applications dead on the delete's exact stamp; a live same-path twin refuses `duplicateTagPath` and KEEPS the entry; the redo re-deletes by the delete's own subtree rule on a fresh stamp), the conversions and composites below. Each registration carries its inverse AND an exact-row `redo` built from do-time pre-images (never a re-run — IDs must survive undo↔redo); `register`'s `redo:` is required (nil = deliberately not redoable, and undoing past it ends the redo future). Any new structural act clears the redo future, a rolled-back compound included. Undo and redo EMIT ORDINARY OPERATIONS, so sync never learns they exist. Excluded: text editing (⌘Z stays NSTextView's), commits, locks, tag APPLICATIONS (apply/remove). Doors ⌥⌘Z / ⇧⌥⌘Z (never ⌘⇧Z). A buffer edited since the operation is insured by a quiet auto commit before the inverse overwrites it. Two presses inside one flight refuse the second. **A half runs only after its partner changed something:** an undo that finds its act's result already gone (an undo-less door — Put back, a restore, a rename, her ✓, a lock, the rule editor's Save — or a sync apply) changes nothing and RETIRES it, leaving the other stack as it was (the Mac's door says so as a refusal naming the entry, §12's status seam); a redo re-applies exactly what its undo un-did, parts and stamps included (an entry with several parts moves only the parts its partner moved; a revive revives only rows dead on its own undo's stamp), so it never writes over a change of hers (PROVISIONAL #226; the record `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, whose SWEEP TABLE dispositions every registration).

**Posts, seals, extents**
- **lockPost / unlockPost** — auto-commit dirty live buffers, then UPDATE `locked`/`locked_at`. The seal refuses every authoring write under the post (edits, commits, order, chosen variants, comments, presentation, take labels, savepoint names); the post itself may still be archived, deleted, retitled, tagged and added to readings. **`resolveSyncConflict` lands even under a seal** (S5 outranks it).
- **setPostWordTarget(post, words?)** — display/progress only, NEVER a refusal; refuses non-positive; nil clears; no-op guarded; refuses under a seal (PROVISIONAL).
- **saveNoteVersion / restoreNoteVersion / promoteNoteVersion** — whole-note Versions (`notes/plans/post-13l-polish-round.md`): `saveNoteVersion` is a full family copy born archived + sealed from ONE clock read (`archived_at == created_at` IS the version classifier), no title mutation, no `entry_date`; `restoreNoteVersion` is identity-preserving — save the moment of now first, the outgoing blocks take the Delete Now road (tombstone + purge intents, never a raw DELETE), the version's family copied into the SAME container, every version link re-anchored via the classifier; `promoteNoteVersion` unarchives + unseals **and applies the original note's CURRENT live tags through the one application road — Save Version → Promote ends as Duplicate with Tags does**; no undo entry; mobile-visible through the shared op (PROVISIONAL #229). Versions ride the note's deletion on its exact stamp; a version's ONE home is Note ▸ Versions (excluded from Library, Archived and every global search by `Queries.versionHistoryPredicate`).
- **divergePostForReading(post, reading)** — ONE transaction: a `duplicateAsVersion`-shaped copy; its membership at the original's exact slot (position AND `section_id`); the original's membership in THIS book tombstoned (it lives on elsewhere). Curated books only; refuses under a finished book; capacity un-gated (net zero). ONE undo entry; the redo revives the copy through `restoreContainer`'s exact-stamp path. Doors flush the pending buffer first.
- **duplicateAsVersion(_:tags:) / promoteLens** — per-block copies carrying comments, presentation AND `block.name`; a `version_of` edge for the former. **Her duplicate is TWO doors** (`notes/plans/fixes/vx-383-duplicate-note.md`): Duplicate with Tags APPLIES every live tag the source wears through the one application road (`insertPostTag`), so living books hear the copy exactly as when she tags (seat · bell · capacity · ownership); Duplicate without Tags applies none; ONE undo entry covers the copy and its seats (the container tombstone takes memberships and applications on one stamp, the redo revives them); both declared ONCE in the capability registry (⌘K, File, both `note ▾` menus, the note rows; the shipped inline doors route to with-tags) and every door speaks ONE receipt naming where the copy landed, with "Open ›"; the label "Duplicate as Version" is retired. The wire's `duplicate_note` shares the body (`notes/MCPSpec.md`).

**Readings, chapters, tags, comments, presentation, references**
- **addPostToReading / removePostFromReading / assertReadingAcceptsPosts(reading)** — the gate (missing / wrong kind / locked / at capacity) is a standalone core read run INSIDE the serialized closure so a door can refuse BEFORE minting.
- **Event-driven INTAKE + the judgment ops** (`notes/plans/phase-13i-b-gatherings.md`): a LIVING book (live · `kind='book'` · readable rule · not finished · not archived) hears the APPLYING act only — `applyTag`/`setStarred` through the ONE application road — and seats (`status='member'`, END, unsectioned) or bells (`status='arrival'`) per the pure `Domain/IntakeDecision` table (capacity waits at the door; the `intake_seating` dial, NULL = join quietly; un-tag/un-star are NON-events; insert-only, tombstone-means-decided). CREATION-time backfill seats; RESUME catch-up (restore, un-finish, un-archive, rule edit) bells. `lockReading` dismisses pending arrivals in its transaction. Judgment: `seatArrival` / `dismissArrival`. `saveFilterAsGathering(reading, filter)` mints a gathering (association ∧ filter). Removing a rule never untags.
- **OWNED, FINISHED, SEALED** (`notes/plans/phase-13i-c-owned-finished-sealed.md`): ONE pure consult, `Domain/OwnershipDecision` (an OWNED target + a note membered in another BOOK → the copy-or-move choice; a PLAIN target + a note owned elsewhere → copy only; bookless → a plain add), read by `addPostToReading` and `seatArrival` AFTER the capacity gate (`noteMemberedElsewhere` / `noteOwnedElsewhere` — the refusals that OPEN the ceremony sheet); `shelveInDailyJournalBook` BELLS on a conflict (`.waitingAtDoor`, never a throw). **`setReadingOwned(reading, true)`** — the convert door: every member also membered elsewhere FORKS IN PLACE (a full family copy takes this book's exact slot, tags RIDE the copy, the original's row here tombstoned; LISTED in the confirm); sole members own in place; refuses a gathering and a finished/sealed book; no undo entry. **`false`** lifts exclusivity, members stay. **`copyPostIntoReading`** (COPY IN: the family copy's membership first, then the outflow; one undo entry) · **`movePostIntoReading`** (MOVE IN: every other live row of the note severed — listed; refuses while a severed member sits in a finished book) — each with an `answering:` form for an arrival (the row decided member-class). **The REVIVAL PASS** (`restoreContainer`, `restoreReading`, the bind's redo, `revertDiverge`/`reapplyDiverge`): the earliest-created membership stands, a later owned-side row demotes to an arrival, a later plain-side row beside a standing claim is tombstoned; a membership revives into a SEALED book only when its note is sealed. **`sealReading`** — SEALED = Finished + text immutability (EDITION ZERO): shared members forked in place first (fork-free on an owned book), the finish (pending arrivals dismissed — the confirm's N IS the act's set, one shared predicate), `sealed_at = now`, every member sealed on that EXACT stamp (dirty buffers insured); **`unsealReading`** unseals the stamp-matched members AND REOPENS the book with the catch-up; `unlockReading` on a sealed book refuses `readingSealed`; a note's own `unlockPost` refuses `noteInSealedBook` while a live sealed book holds it. **`deleteReadingWithNotes`** — the owned book's second delete choice: the book and its member notes on ONE stamp (versions ride); **`restoreReading` returns WHOLE** (stamp-matched member notes revive first, then memberships, then the revival pass, then the catch-up). **`duplicateReading(name, deep)`** — configuration not state (rule, outflow, dial, extents, trait, chapters; born unshelved, open, non-owned, unarchived); shallow = the same notes, deep = family copies; an owned source duplicates DEEP only; a gathering never duplicates. **`removePostFromReading`** returns whether the note is now bookless ("Release" on an owned book). **`setReadingOutflow(reading, tagIDs)`** — the CHOSEN set (ordered, deduped, every tag live in the book's wing; `[]` = none); `applyAutoTag` applies EVERY outflow tag on mint-inside and hand-add; `tagAllMembers(nil)` = every outflow tag. **`setReadingHideOwned(gathering, Bool?)`** — nil follows `hide_owned_default`. The membership readers (`membershipElsewhere`, the Pool's exclusion, `readingsContaining`) count BOOK rows only, live books only.
- **shelveInDailyJournalBook(post)** — puts the day's entry into THE daily Journal (DERIVED from the `'daily'` marker — never the setting, which survives only as a written cache) as ordinary membership; an ARCHIVED daily Journal comes back ON EVERY PRESS (fresh pair: before the savepointed filing — a refused filing still brings it back; decided pair: the un-archive alone, nothing re-filed; open-today kept — ⌘J opens today's existing entry rather than minting a second; the ⌘J road speaks a quiet receipt when it returned). NEVER throws: returns `shelved` / `alreadyDecided` / `bookFinished` / `bookAtCapacity` / `wrongKind` / `refused`. Any `reading_post` row for the pair — live OR tombstoned — means the pair is already decided (a headless round never undoes a deliberate removal). **Creates and pins the Journal when none is designated** (or the designation dangles) — curated, `profile:'journal'`, `entry_date` ascending — and ⌘J delegates its whole ensure here; it never replaces a book she designated (a finished, full or smart daily book keeps its own status). A READ-THEN-ACT composite, not one transaction (the tombstoned-row race is recorded, unpinnable without an op-level precondition). Its convergence under sync: SyncSpec §7's daily-Journal keeper repair. (`notes/plans/phase-13i-e-daily-journal.md`)
- **createSection / renameSection / deleteSection / reorderSection / assignPostToSection / restoreSection** — CURATED readings only (smart refuse). A locked reading freezes chapter STRUCTURE while rename stays free. `deleteSection` tombstones only the section (memberships keep the pointer; dangle = unsectioned); `restoreSection` is one flip — refuses when live, under a locked reading, or when the section died WITH its reading (restore the reading first). No undo entry.
- **setReadingWordTarget / setReadingMaxPosts** — refuse non-positive and under a locked reading; `word_target` display only; lowering `max_posts` below membership is legal (further adds refuse). **`lockReading` and non-nil extents REFUSE a gathering** (`wrongReadingKind`; clearing stays legal).
- **convertSmartReadingToCurated(reading, order: nil)** (PROVISIONAL #46) — ONE transaction: the current assembly materializes as `reading_post` rows in the GIVEN order (nil = stored sort); `kind` → book; `sort_field` → manual; `query_spec`/`grouping_tag_id` stay on the row — and the rule stays LIVE: **the bound book KEEPS COLLECTING**. Refuses non-smart and locked. Undo AND redo; the un-bind leaves NO live row on the reverted gathering (every taken row flips to the dismissal class as it tombstones; hand-removals keep their member-class tombstones) and the redo restores each row AS WHAT IT WAS — ids AND statuses.
- **renameTag(tag, newName)** — rewrite `name` + the subtree's materialized `path` in one transaction (under sync, plain CAS per row — worst case a lost rename). **applyTag / removeTag** (post or block) — INSERT/tombstone; `post_tag` targets must be posts. **deleteTag** registers structural undo (above).
- **addBlockComment / editBlockComment / deleteBlockComment / restoreBlockComment** — delete is a tombstone; deleted comments visible and resurrectable (`Queries.deletedBlockComments`) — and **purgeBlockComment** is the true-delete road: the Delete Now shape (purge intent, the purge horizon), offered as "Delete forever…" beside Restore in the deleted fold, confirm-each-time; tombstoned comments only; `restoreBlockComment` and the MCP add_comment redo road void pending intents; the purge fence and `restoreCost`'s deleted-comment count are stamp-aware. All writes refuse under a seal (PROVISIONAL #23). **Travel:** extract/divide keep A's and COPY to the minted half; divide-W and divideDuplicating copy to B AND C; merge carries both sides'; poolDragCopy / duplicateAsVersion / promoteLens carry per-block copies. Copies are fresh owner-stamped rows preserving the source's `created_at`; DELETED comments never travel; structural undo needs no extra machinery (reverting a mint cascades the copies).
- **setBlockPresentation / updateBlockPresentation** — identity-level (no-op guard, no touch/churn); the update is a read-modify-write in ONE transaction; refuses under a seal (PROVISIONAL #24). Successors INHERIT the frame; merge keeps it only when both sources agree; duplicateAsVersion/promoteLens copy it with `name`; poolDragCopy copies it (and comments) but never `name` (#24(e), pending). Export maps a callout to a blockquote (a presentation transform only).
- **setBlockName / setTakeLabel** — identity-level metadata; a seal refuses `setTakeLabel`.
- **addReference / removeReference / updateReferenceViewState** — INSERT/tombstone/UPDATE `reference` rows.
- **setJournalTrait(reading, on)** — on ⇒ `profile='journal'`, off ⇒ `'book'`; the `'daily'` book refuses (its marker is constitutive — PROVISIONAL); a finished book refuses; no-op-guarded. **setDailyJournalBook** MOVES the `'daily'` marker with the designation in one transaction (every other live `'daily'` row demotes to the trait); refuses a non-book and a dead/missing designee. **setShelfPinned / Queries.shelfPins** read and write `reading.starred` (starred absorbs pins; the `shelf_pins` setting is retired-as-read).
- **BOOK ARCHIVE** (`notes/plans/phase-13i-e-daily-journal.md`, PROVISIONALs #179): **`archiveReading`** (a book OR a gathering, the daily Journal included — its one road; ONE row write, a plain book archives alone) · **`archiveReadingWithNotes`** (the OWNED door's second choice: the book's not-yet-archived member notes' `container.archived_at` on ONE stamp; never tombstones, never versions; the op refuses only a gathering — the DOOR offers it on owned books) · **`unarchiveReading`** (the book's flag clears; EXACT-STAMP members return whole; a living book's resume CATCH-UP bells, never quiet seats). Archived semantics: out of the Bookcase/census/counts/catalog, listed under ARCHIVED; AUTO-INGESTION paused in the ONE intake table (`intakeRuns`), VISIBLY (the Collecting pane says so); EXPLICIT adds land (no `readingArchived` refusal exists; the pickers mark "(archived)"); an archived gathering assembles EMPTY everywhere; membership stays a FACT (an archived book still homes — and still owns — its notes); the E13 name guard skips archived names; pending arrivals keep waiting; Finished/Sealed/locked orthogonal; duplicate born unarchived; restore-from-Trash returns archived; double archive/unarchive refuse; no undo entry (the door is the recovery). **THE DAILY JOURNAL:** the designation DERIVES from the `'daily'` marker (`Queries.dailyJournalBookID` = the keeper's smallest-id pick); `deleteReading` AND `deleteReadingWithNotes` refuse it (`dailyJournalCannotBeDeleted`, on the marker, inside the write) — every door shows ARCHIVE in Delete's place on both platforms.
- **The Bookcase op family** (`notes/plans/phase-13i-d-bookcase.md`, PROVISIONALs #170–#178): **shelf ops** (create/rename/glyph/delete/move; `setReadingShelf`; `placeReading`'s one my-order sequence; deleting a shelf returns books to UNSHELVED) · **`ensureWelcomeShelf`** (adopt-by-role, the keeper's key; the seeder mints and shelves the seeded content — the §12 SEED SET) · **the UNION STAR** (one star, one transaction over both stores; `setShelfPinned` routes through it; the Mac's Pin door is retired into Star/Unstar; the daily Journal and Quicknotes are born starred) · **wing ops** (mint/rename; DELETE refuses unless empty, naming contents and the bulk road) · **`moveReadingToWing` / `moveWingContents`** (members move whole with tags adopting by path, stay-behind memberships severed and LISTED, finished/sealed ride whole, archived ride archived, pending arrivals dismissed-and-said, unshelved landing, source tags without applications tombstoned — the wing ends empty; the daily Journal refuses both doors; NO undo) · **cross-wing undo revivals are OBSOLETE** (`revivalWingScope` — a replay that would cross wings does nothing) · **`seatArrival` seats an ARCHIVED note as an archived member** (intake's automatic seats still never seat one; finishing dismisses every waiter).
- **resolveSyncConflict(variant, losingText, label='conflict')** — INSERT variant(losingText, label) on the same block, same parent, fan's end (S5). Lands under a seal; refuses a dead block (the engine's in-apply rescue skips one silently). ~~applyBridgeLanding~~ retired (tag `archive/fragments-bridge-2026-09-04`).

## 10. The "80%-edited" sort (anti-typo-reshuffle)

Two stamps per post: `last_touched_at` (every keystroke) and `last_major_revision_at` (meaningful edits). The editor reports a char-delta per edit; `churn_accumulator` (inserts + deletes, equal weight) accrues against `baseline_length`; when `churn / max(baseline,1) ≥ threshold` (setting, default 0.8): stamp, reset, rebaseline. A manual commit also stamps. A reading's `sort_field` picks the stamp; journals sort by `entry_date`. Churn math is a pure Domain function. The Library's day filter answers "notes edited on this day" as the UNION of the last-edit stamp and any savepoint written that day (18h) — the honest reading under the one-stamp design.

## 11. Sync architecture

**Authoritative document: `notes/SyncSpec.md`** (read it in full before touching sync, custody or a schema). Summary: hand-rolled state-based row sync over Supabase/Postgres; dumb server (compare-and-set + per-tenant `server_seq` changefeed); all merge intelligence client-side — conflict-as-variant for `working_text` (S5), server-wins for metadata, deterministic apply-time repairs for every live-unique index, deferred-FK batch application, trigger-fed coalescing outbox with apply-mode echo suppression; the wire is E2EE ciphertext sealed at the payload serializer; multi-tenant with RLS; the migration-lockstep rule (§12 there) governs every schema change.

## 12. Views and the UI stance

**Many views over one store is the point** — each is a different traversal that stress-tests a different edge of the model; a view that is tortured to build reveals a weak spot in the model. The load-bearing UI-shaped constraint throughout is P3's read-cheap/edit-focused split. **The binding design records are the plan files** — Phase 13 (`notes/plans/phase-13-ui-design.md`, rulings R1–R94), the pre-13u round, the Act 10 correction round, the use-report rounds (`use-report-round-2026-09-06.md`, `-2026-09-12.md`), 13u3's `phase-13u3-memo-gutter.md`, the 13u4 restyle, and the phase and fix files each line below names. Archive §12 (both editions) holds the full narrative of every ruling below.

**The current surface (contract):**
- **Two voices, exactly two** — Terminal (leads) and Study — each with tokens AND idioms; light designed first; **dark is a fully black room in both voices under every palette**; all fonts macOS-shipped; **Study is the fresh-store default** (a voiceless store adopts Study; an existing store keeps its voice). A **colour palette** layers UNDER the voice: sixteen presets plus custom hex, the synced `theme_palette` + `theme_tint` + `theme_accent_tint`, replacing only room/wash/accent/take tints/hairline via ONE pure rule (`PaletteDerivation`, WCAG-AA-stepped accent); `default` is each voice's shipped colours. **Appearance:** follow system · light · dark, a LOCAL preference applied once as `NSApp.appearance`. No literal colour outside the token layer (pinned).
- **The sidebar:** Bookcase · Library · Pool · Snippets · Archived; the Trash door on the Library masthead. The ARCHIVED surface has a BOOKS group above the notes ("kept, with no countdown" — keep-forever, never a countdown), rows Open · Unarchive · Delete Book… (NEVER Delete on the daily Journal); the archive doors render from ONE table beside Delete on every book/gathering surface — the daily Journal shows Archive IN Delete's place, its State caption §10's own sentence; the OWNED book's door asks with the delete confirm's twin (N = the not-yet-archived member set); the Collecting pane leads with the visible pause while archived; the pickers/chips/Book Panel mark "(archived)"; the receipts say what came back and what waits at Arrivals; ⌘J's comes-back speaks "The Journal is back on the Bookcase." Library = everything, with List and Cards carrying a muted time stamp (`TimeStampFace`), a `sort ▾` (edited · created · date · title, direction local) and the day filter. **EVERY stamp speaker hovers the WHOLE fact** — one wording brain (`TimeStampFace`) and one hover (`.stampHelp`) across the Library, the info panel and note box (the panel's fact is the LAST TOUCH), the Timeline, the search sheet, Arrivals/Archived, the pickers and the MCP pane; the raw-day-key drift copy is dead; the stamp-form setting is VX-389, deferred. Pool = bookless posts. Snippets = the scraps area (groups as the container noun). ⌘K palette; ⌘N = New Post; Settings (nine panes, searchable) is tag management's home.
- **THE OPEN LIST AND STARRED** (`notes/plans/fixes/vx-283-sidebar-library-polish.md`): **Room** — the Open list grows down the sidebar to just above the sync footer, floored at 3½ rows (the sidebar's outer scroll carries the rest on a short window); Starred keeps its ~7½ rows; both scroll bars sit in the list's own margin, clear of every ✕ and ★. **Closing** — View ▸ Close Note ⇧⌘W closes the shown note's row and lands the pane on the NEXT note in the list, else the previous, else the Library; ⌘W still closes the window; in a window merged into macOS tabs ⇧⌘W is macOS's Close Window (accepted); View ▸ Close All Notes (and the list's right-click) empties the list and lands on the Library; a row's ✕ or right-click ▸ Close on the note being shown behaves like ⇧⌘W, on any other row it removes only that row; closing is view-only. **Following** — each list follows its current row ONLY on her next act (an open, ⇧⌘W, a ✕, Close All, back/forward); a hand scroll stops it until the next act; a resize never pulls it back; re-selecting the shown note is not an act; each section follows on its own. **Edges** — an edge with more content beyond it fades; the fade is always half a row deep, easing in over the row's own text padding, capped at 0.8 and never fully solid. **Reordering** — an Open row drags with its title chip at the cursor; each row is its own drop (a 2-pt ring line at the targeted row's top; the drop lands before that row with a short settle; an end zone under the last row reaches the last slot; the dragged row's own place offers nothing); the chip lives only on the Open list's rows.
- **THE LIBRARY'S CONTROLS ROW** (`notes/plans/fixes/vx-348-prelaunch-sweep.md`): search · scope / mode · sort · when compose as ONE Layout (never `ViewThatFits`), the field first. It wraps onto a second line only by STABLE widths: the field at its prompt (never its typed text), the sort slot at its widest form, each segmented picker at its natural width — so typing, a sort pick or a search never changes the line count. At the 1240-pt default the row is one line with the panel closed and two with it open, and the info panel is never pushed off. **NARROW WIDTHS:** below the two-line widths the field COLLAPSES to a 🔍 button — a width-class decision INSIDE the one Layout, decided at WHOLE points in both passes so placement re-decides nothing — and the open field lives on its own line (open is HER state, never the text); hidden controls sit off-row; the info panel's floor drops to 200 pt and the LIST gives way, never the panel; no window floor.
- **Toasts clear the quick-entry band:** a toast over the Bookcase or the Library sits above the band the shared `QuickEntryBar` marks, never on it. **The Pool hosts the shared `QuietReceiptLine` at its foot:** a receipt-only act from its rows (a duplicate, ⌥⌘Z, ⇧⌥⌘Z, an AI's receipt with its Open ›) speaks there under receipt_style quiet; composed only while a receipt shows.
- **The List's pinned headings in dark** are drawn on the List's surface with a hairline, never a warm grey band across the black room.
- **THE BOOKCASE** (`notes/plans/phase-13i-d-bookcase.md`, `notes/plans/librarywalkpolish.md`): shelves as a mode-row STRIP (one line, edge fade, ⋯ type-to-filter overflow; the names on quiet near-square light-wash chips, the solo'd one filled — the committed reference `notes/plans/librarywalkpolish-ui-reference.html`); **the strip LEADS with the VIRTUAL "starred" shelf: books-only, the union star, shown always, drop-to-star**; solo on the default shelf · All stacks shelves in strip order; UNSHELVED at the TOP of All under its own collapsible header; Welcome holds the SEEDED content only; new books land unshelved, a context mint lands on the solo'd shelf; drop targets + drag reorder + Move to Start/End; Rename · Set Glyph (one grapheme, monochrome) · Make Default · Delete→unshelved; **the № census** (a quiet POPOVER under its mark — the order menu's twin on ONE masthead-popover idiom, the selected row washed, census solos COMPOSING within a solo'd shelf; collapsed by default; each row a SOLO filter: books · gatherings · finished · owned · living · with arrivals); **order ▾** = a–z (default, digit-aware) · last edited (DERIVED locally, never synced) — **my order and hand placing (grips, row drops, Send to Top/Bottom) are STEPPED BACK** (a stored my-order preference reads a–z, never rewritten; the proper return is VR-120); starred floats first under any order; **details** hides row meta AND arrival counts; honest counts ("N notes · M archived"); NO search box, NO time filter (the place/finder boundary). **THE BOOK PANEL:** the collapsible right-side book TOC on every membered note (the switcher atop for shared notes; "appears in N gatherings" with names; Remove/Release; drags over the existing ops with menu twins). **THE WING SWITCHER** (a masthead dropdown; "Wings — each a separate library"): mint · rename · delete-unless-empty · Move Everything to Another Wing (additional wings only); the whole surface re-scopes per wing; the per-item Move/Copy to Wing doors carry R-13ia-1's tag adoption; the lineage door under a cross-wing copy names the wing and at most offers go-to. **ARCHIVED MEMBERS:** the per-book archived line on the Arrivals idiom (invisible when empty; Unarchive + Remove/Release), archived waiters visible and seatable at the door, the Index never shows them. **The tutorial's books chapter** carries the eleven lessons + five rituals; lesson 9's second sentence teaches the daily Journal's delete guard.
- **Arrivals, Cards, "unfiled", the one wing** (`notes/plans/17y-sitting-rulings-2026-10-05.md`, `notes/plans/librarywalkpolish.md`): a book's ARRIVALS live on the masthead ICON beside its settings gear — calm when nothing waits, present when something does; the ONE word is "Arrivals" everywhere it speaks (the content-top door line's idiom is retired); a waiting row OPENS the note read-normal, and opening never seats. The Library's card view is named **"Cards"** and **always shows notes**: picking Cards moves the scope to Notes, and a non-Notes scope picked inside Cards returns the view to List. The chapterless group reads **"unfiled"** everywhere. The app's ONE WING FOLLOWS the focused pane's note on open and on focus, with the quiet "Now in …" receipt; cross-wing Open rows wear the wing indicator. A book-row drag presents a TITLE CHIP riding under the cursor, and a drop outline lights only where the drop would act (the false-offer rule, applied across the headers, the strip names and the starred word).
- **The NOTE mode row: Write · Takes · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘7, derived from the one order; **in RELEASE the row is SIX modes ⌘1–⌘6 — Canvas is Debug-only**). **A note FIRST OPENS in WRITE, with per-post MODE memory (local, persistent, per note — S4-20, `notes/plans/phase-13b-make-it-work.md`).** Takes = single-column fan work (its article REMEMBERS the row at the top per note for the session; an entry landing outranks the memory when the note's current block changed). **Takes is LENS-AWARE:** the masthead `show ▾` popover filters the board by four lens forms — in X · in A, not in B · X disagrees with Y · X disagrees with the chosen takes — non-matches collapse to one-line rows, a match expands the filter-named + chosen takes, a quiet chip names the active filter, and the pick is SESSION-ONLY per note (a blank take is an ordinary take in every form; `notes/plans/fixes/vx-168-mcp-client-secret.md`). **NOTE-OPEN** (`notes/plans/phase-18l-navigation-feel.md`): the session's FIRST open of a note shows the START in every mode (superseding the open-at-remembered-caret rule for the note-OPEN act only); an in-session RE-open restores the page she left, never revealing an off-page caret; deep links keep their targets. Read carries an in-place `edit · read` switch opening on `edit` (the editable index surface with the `▸ 01` outline column; P3's one live editor through `PaneTextAuthority`) and `read` (the calm page, continuous or paged; a sentence click flips to `edit` at that block through `LandingTarget`). Lenses = the editable multi-column editor, ALL lens machinery's one home. Compare holds Outline. Blocks = the power-user workbench (multi-select, bulk bar, context panel). Canvas = a VIEW on a post or the scraps area (spatial arrangement + the minimal one-take switcher; movement free; the switcher view-local) — off in Release, the Snippets area's Canvas face and its other doors included.
- **The BOOK's mode row: Outline · Index · Book · Read** — Index editable in place; Read read-only. **THE BOOK'S DOORS AND PLACE** (`notes/plans/fixes/vx-382-book-view-doors.md`): every book open door (the headers' and cards' open ↗, Index's "Open in the full editor", the spread's) lands in WRITE at her block with her caret's offset through the ONE landing road (`BookOpenDoor.Landing` → `ShellRouter.adopt(landing:offset:)` + `ModeLanding` → `jump`), forcing Write even with nothing live — never the note's remembered mode; the left note box offers "open ↗" in every book mode and "Takes" on Index's live block; Index blocks with takes wear the ⑂N badge opening the in-place Takes sheet over the book (her pending typing written first, the live pane released); Outline → Index carries the live block at her caret (the departing surface never eats the arriving one's reveal); a book surface's caret — and a CLICK into a book note — feeds the note's ONE place memory, so "edit here" and an in-session re-open return to her book place (PROVISIONAL #232); the focused note's controls live in the SIDEBAR'S NOTE BOX (three states: none · selected · live), the details gutter retired; the navigator, Index's chapter panel and Read's contents column are draggable leading columns (`SideColumn`) with remembered widths; note lengths remembered per note in a LOCAL-ONLY store.
- **The editor language:** boundaries invisible at rest, dotted seams on a global toggle; the editing indicator a setting (off · outline · background); **comments and callouts render in the whitespace GUTTER outside the text area on every surface, stacked vertically, and the prose column's measure and left edge NEVER move for a decoration** (pinned per surface); the inline-tinted comment strips are an opt-in; comment EDITING lives in the panel; a callout's leading glyph is one grapheme; sacred margins; everything visible in an editing surface is editable. Takes presentations: tinted cards, "✓ chosen", ONE live-editor ring, the changing-block wash (default on), the short-block strip, follow-the-scroll in all modes; an empty block in Takes is an empty line. **The live editor's markdown face honours a closer at the caret:** while the caret sits right after the whitespace that would disqualify a closing marker, the span still reads styled, and leaving a trailing space behind un-styles it honestly; only an editor she can type in honours a caret; every non-live reader (the read pages, export, search, ⌘I/⌘B's acts) keeps the flanking rule byte-for-byte (the open edges are QUESTIONS #220). **Write's take panel answers every routed command about a block or a take on ITS block** — or greys it (the nine verbs that cut, join or add blocks) — never Write's caret block beneath the sheet; ⌘⇧T closes it (QUESTIONS #221). **A comment left unsubmitted in the comments panel by any close but ⎋ is kept for its block and comes back on reopen; keeping never files** (QUESTIONS #223 — the Mac; the phone's sheet is VM-18).
- **The two ceremony sheets** — Divide choosing takes · Merge choosing takes — open on a preset row (§9), real prose side by side, the ✂ overlaid on the inter-word gap.
- **Messages carry a KIND on the one status seam — refusal · offer · receipt** — decided at the door; the synced `receipt_style` (toast · quiet · off, quiet by default) governs RECEIPTS ONLY, rendered as a muted line at the bottom bar's trailing end; refusals and offers always toast. **An AI write's line is a RECEIPT that CARRIES a one-press door — "Open ›"** — with the session-scoped keyboard road "Show the AI's Last Change" (⌥⌘O) alive past the fade and under receipt_style off (the door does not reclassify the line into an offer). A door that did nothing speaks a refusal.
- **No popup greets a first open; the app's own asks (updates, the backup folder) wait for days of use and calm moments, and are always answerable in Settings** (`notes/plans/phase-13r-distribution.md`).
- **FIRST OPEN, THE OFFER AND THE TOUR** (`notes/plans/phase-13s-voice-onboarding.md`): a fresh store opens with NO popup: the Bookcase, quick entry at its foot, and the ONE quiet offer line in her approved words with its retire-forever local flag — press it or ignore it forever. The sea-glass cards fan (#C2DDD3) is the app's face — ONE icon in every appearance, About, the offer mark; no user-switchable colourways. **THE TOUR:** a pure-rule engine with ring + cards and NO dimming ever; the 22 approved frames verbatim; an off-target act re-anchors with the road-back line; Help ▸ Take the Tour re-enters any time; the end card's readme aside asks the store whether the readme still exists before speaking. The tour is Mac-only. **A window that OPENS on the Bookcase (launch, unlock, a new window) puts the caret in its quick entry when nothing else in that window holds the keyboard** — decided once, never stealing from a field, a sheet or the tour; arriving back at the Bookcase later is unchanged (QUESTIONS #224). The capture box keeps its own undo, and a filing ends it (QUESTIONS #222).
- **THE COMMIT VOCABULARY:** the app says **commit** everywhere a savepoint was named (Block History "Commits", Settings ▸ Writing, ⌘/, receipts, the phone — both platforms, the label-fence verified); the sentences that DEFINE commit say "saved moment" (her open taste call, QUESTIONS #206); two ruled survivals stand (the tour's and the guide's one exemplar "savepoint" each). **⌘S ALWAYS COMMITS:** the name field stays, and every way of leaving it but ⎋ FILES the commit (unnamed if nothing was typed) — ⏎, clicking away, typing on (the click that returns is the leave), closing the window, ⌘S again (which files and opens no second field); ⎋ alone is don't-save; the filing commits the take the ask NAMED, never the caret's at leave time; ONE filing per press (the presentation ledger); the rename door stays ⏎-only. One shared seam (`SavepointNameField` + the leave rule + the settle-once box), every host (`notes/plans/fixes/vx-348-prelaunch-sweep.md`).
- **THE SEED SET:** launch = the field guide + sherlock (OWNED) + the empty starred notes + the disclaimer snippet; "journal" and "quicknotes" mint ON DEMAND, lowercase — mint-time defaults only, existing stores never renamed; Encryption Explained is GONE and UNRESTORABLE (door removed); the classics gain a restore door; jekyll's door fully lowercase; the readme placeholder carries her Start Here text with REAL fans.
- **The BOOK SETTINGS sheet (the same pane for a book and a gathering)** carries the COLLECTING section as sentences ("Gathers from: …" · "New matches: …" · "Notes written here are tagged: …") with ONE Edit… door into the rule editor (whose auto-tag row is the OUTFLOW CHOOSER — several tags, any, none), a gathering's three-state hide-owned row, and the STATE doors — Finished (the confirm carries "N waiting at the door will be dismissed" only when N > 0), Seal… (the confirm LISTS the notes that fork; "nothing needs copying" on an owned book; sealing finishes too) / Unseal (reopens), Own Its Notes… (the confirm LISTS the copies) / Stop Owning. The mint door requires a rule (the editor inline); a gathering's empty save refuses and offers Delete. **The MEMBERSHIP CHOICE sheet** opens from every add road an ownership refusal reaches (the chip, the drops, Manage Notes, the Arrivals arms — Copy in · Move in · Dismiss, with "owned by"/"also in" lines): Copy in / Move in (the severed books listed) or Copy in only, the edit law said at the door. **Delete** asks on every book; an OWNED book offers two choices (book only → the Pool · book and its N notes → the Trash, returning whole). **Duplicate Book…** shallow or with copies (owned: copies only). **Remove from this book** reads **Release** on an owned book; a gathering offers "remove #tag". **The BADGE family** (one switch, `ownership_badges`): the shared mark inside a book (hover names the books), "owned by "X"" outside it (click-through opens the book at the note); the navigator chip reads sealed. The Trash row says "and N notes"; Put back's receipt says it came back whole. (`notes/plans/phase-13i-c-owned-finished-sealed.md`)
- **This Note's Tray:** Leaving · Archived views with a shared blocks/takes filter; released originals surface per note and behind their successors' lineage doors (the global unplaced-blocks listing is retired as a user surface; `Queries.unplacedBlocks` is the debug net).
- **IMPORT & COPY FULL TEXT** (`notes/plans/phase-13n-a-document-format.md` — the MCP door's Level 0): File ▸ Import… and the Bookcase drop read the Variorum document format (a file → a Pool note; a folder → a book; the drop is a CONTEXT MINT onto the solo'd shelf and lights its outline only where the drop would act); refusals name folder, file and line; receipts carry the counts and ⌥⌘Z, rendered at the main column's page foot on book surfaces (`BookNoteBox.quietReceiptHome` — PROVISIONAL). **Copy full text** (note ▾ menus + ⌘K) puts the note on the clipboard in the same format, receipt "Copied full text."; the format's one home is `Domain/VariorumDocument` (the export is its client). Commits and book settings deliberately do not ride the text form — the full-fidelity tier stays the 13m edition.
- **THE MCP DOOR (Level 2) — authoritative: `notes/MCPSpec.md`, read before touching anything it names (the door, its tools, grants, Settings ▸ MCP, the shared icon, the AI docs — and any operation the wire calls, or Private, Seal, Own).** An AI client reaches the store ONLY through the in-app MCP server, alive only while the app runs with the pane's switch ON; at the EDIT rung the door is broadly AS CAPABLE AS HER AT THE KEYBOARD. The rules any session can break WITHOUT knowingly touching MCP stay loaded here: **every AI write is one of §9's operations** with the grant check inside the op's own transaction and ONE ⌥⌘Z entry naming the client (an MCP undo writes back only while the row still reads the act's value, else it quiet-retires its entry — §9); **her pending typing lands first** — before a wire act that meets a take she may be typing in, the door flushes every open note's pending typing ahead of the act, and a wire note delete rides her Delete door's ONE road (`.variorumNotesDeleted`), every pane leaving a dead note for the Library IN PLACE, focus kept; **Private, Seal and Own are hers alone** — no MCP road writes `ai_private_at`, `sealed_at` or `owned`; **the fence** — the daily Journal's entries, ⌘J entries and anything Private answer only a PER-ASK note grant, and everything unreachable answers ONE byte-identical not-shared shape, so a client can never tell hidden from missing; **grants are LOCAL-ONLY, never synced** (§7's family); **a book rule an AI writes BELLS, never backfill-seats** (a rule write must not expand the writer's own reach); **the shared icon reads reach only for the rows DRAWN, never the corpus — and reads NOTHING while no client is approved** (P1); **`show_in_app` moves things only while Variorum is frontmost and never queues or raises windows**; `list_wings` lists the wings the client holds a standing wing grant on (a granted EMPTY wing is discoverable); one standing grant row per client × place; every connection's END says why in Activity (the stop roads included); a write carrying U+0000 is stored stripped with the answer naming how many were removed (the digest stays the stored text's). Level 0 is the IMPORT & COPY line above; Level 3 (chat) stays deferred.
- **The reference panel** (§7 `reference`), the badge behavior (a corner badge only on fanned blocks), export (a callout → blockquote), the Shortcuts & Dictionary helper, the keyboard family (⌘[/⌘] indent, ⌥⌘[/⌥⌘] back-forward — PROVISIONAL #130; ⌥⌘Z / ⇧⌥⌘Z structural undo/redo; ⇧⏎ in-block newline; the merge chord said on every face from the capability registry).
- **SEARCH — the one finder** (`notes/plans/phase-13o-search.md`, `notes/plans/fixes/vx-83-search-followup.md`): full body-text search over the LIVING corpus (all live active takes, titles + worn display dates by query-time date parse, scraps, comments, names/labels; versions fenced; archived behind one facet; savepoints IN behind the one explicit **`+ commits`** facet — the chip's word is "commits", lines read "commit · <day>", counts "N commits", and a savepoint NEVER lists without the facet; the Trash deliberately out), on a local-only derived FTS5 index, accent- and case-folding (the deliberate third sameness rule — the Write/Takes bars keep their pinned pair). The Library field is THE finder wearing the ANSWER SHEET (the band's honest counts + quiet chips, passages grouped under their notes, every "all N ›" a real road — no capped listing anywhere); ⌘K carries passages under its title hits; the **when ▾** door is ONE calendar popover (the mode row on a day · between days, a voiced month grid, the armed SENTENCE at the foot as the confirmation; NOTHING arms until a day is pressed; between days is two presses with the run washing in; `any day` clears); a book's masthead rests as a bare 🔍 expanding to the same engine scoped in place (gatherings searchable through the ONE membership function); `#tag` surfaces the books it flows into, top-ranked with the reason said — and a `#tag` ALONE narrows the Library to the tagged notes as its OWN listing rows (sort ▾ and scope live, the Blocks scope by block-level tags, the archived facet's rows marked), while a plain word NAMING a tag offers it as a one-press chip (`tag: #name ›` — the explicit-tag doctrine); the mode facets (gathering · living · owned · finished · sealed) are facts, never tags; the Library incl. its search is hide-owned-EXEMPT, owned notes badged; wings isolate totally with scraps the one ratified shared room; clicking any passage lands in Write at the block with the match selected and the find bar armed (⌘G steps on) — the needle is the snippet's first CONTIGUOUS matched span (whitespace and ≤2-character non-newline gaps coalesce, kept as written) and the landing rests in the comfort band below the shown bar. Search scales ∝ matches, never corpus (P1 pinned).
- **LIBRARY PORTABILITY** (`notes/plans/phase-13x-library-portability.md` — the RELEASE road until VX-329): **File ▸ Send Library to Another Mac…** (and its Data Safety twin) writes a FOLDER PAIR — a sealed snapshot + its key file — to a chosen folder, to AirDrop whole; **File ▸ Open Library…** (and the welcome/absent-store/waiting faces) classifies what was picked (a pair · a backup pair · a plaintext export · a keyless file ⇒ the honest refusal), unlocks by the lobby's roads, CONFIRMS, then adopts: the current library and its key files step aside whole into `Previous Libraries/<stamp>/` beside it after an A1-shaped safety copy, the copy lands (its WAL tail included; the picked file is never written — every read runs on a private staged copy), and custody adopts the key that opens the landed file (the collision rule). Settings ▸ Data Safety's **Restore from Backup** lists the backup folder's pairs, each saying which credential opens it. **THE RESTORE HOLD:** an adopted library lands HELD — no sync round, flush or rotation ceremony runs until the ONE **Resume Sync** press in the standing banner, which then catches up to the account (the gates read the marker beside the store); a copy never carries the sync key or device identity, so a Mac new to a library enrolls. The live library is never placed in iCloud Drive (the picker's guard). A key file still Apple-wrapped under a Castle account surfaces the follow notice (`castleKeyFileAppleOpenable`).
- **THE PROTECTION REBUILD** (the contract `notes/CastleRules.md`, the walk `notes/plans/vx-266/castle-lifecycle.html`; the records `notes/plans/vx-378-castle-simplified.md`, `notes/plans/vx-306-castle-open-road.md`): the headless core under `Sources/VariorumCore/Protection/` is built and gated to the rules — every library encrypted under its own random key with a key file kept redundant (beside it, in every backup, a sealed copy in the Mac's keychain), twelve words from birth and a passphrase asked, Standard a convenience posture with quiet roads and Castle one promise (no Apple road, ever), one posture at a time (entering takes everything in, leaving hands everything out), the floor "a backup always opens with the passphrase and words you had when you made it", a copy is a copy (Look inside / Make this my library — the latter IS Restore from Backup, a new library with no previous keys), detect-and-say (the notice, never a repair), no migration of pre-design stores (rule 26). **THE OPEN ROAD:** the core is LIVE in DEBUG BUILDS ONLY, behind ONE compile-time switch (`ProtectionRoad.newRoadIsLive` — a Debug build on the Mac and the phone, reaching the dev store; Release runs 13x's road byte-unchanged until VX-329): the thirteen production leaves (`App/Variorum/Shared/Protection/` — the data-protection keychain for custody, sync keys and the memory item, iCloud Keychain for the Apple keys, SQLCipher for the library and its copies, the files beside the slot, the catalogue over the folders this design writes), the LOCAL-ONLY `protection_record` table (`v1_31_protection_record` — never synced, the plaintext export drops it, marker 13 untouched), the library-ID stamp on every custody item and Apple key (Castle entry sweeps this library's silent items and Apple keys by the stamp; the catalogue sweep stays the belt), and the faces: the lobby on `assess`'s roads (the quiet roads at once, the typed roads with rule 1's mirror and the catalogued key files, the Touch ID button and line), the once-shown words card at creation, rule 3's reminder and the Set a passphrase sheet, rule 21's notice and key-file offer, rule 27's lobby and banner, rule 1's restore receipt, the rule-8 re-makes at every open, and the two copy doors — **Look inside** (a read-only facts sheet over a private byte copy; nothing written, closing forgets) and **Make this my library** (one confirmed door: a new library in the posture of now under the current pair, the previous one whole in Previous Libraries, the restore HOLD kept as the sync gate it is — Settings ▸ Data Safety's Restore list and File ▸ Open Library… (a picked pair is FILED first) are these doors; 13x's adoption flow retires behind them on the new road). The phone opens on the same road (its words card, lobby and rule-27 faces; no Look inside on the phone yet). The words are the VX-306 plan's §7c, hers at QUESTIONS #234. The server's `key_vault` shape stays VX-307's SyncSpec §12 lockstep (`notes/plans/vx-307-castle-crossings.md`).
- **Capture microsyntax:** `{#tag/path}` applies the tag (smart-book rules do the rest), `{t:"…"}` titles; only braced forms parse; tokens disappear (`Shared/CaptureMicrosyntax`, both Mac doors; the phone's face is the mobile catch-up's).

The views the model must support beyond today's surface (side-by-side, swap-and-reread, diff with optional whitespace normalization, infinite scroll, timeline as a Library view mode, the collapsible block index) are capabilities, built functional first; the UI is iterated with the author.

## 13. Build order

`notes/DetailedPlanForPhases.md` governs (product advancement only; fixes live in `notes/plans/phase-17-standing-fixes.md`). Summary shape: substrate (schema → operations → queries) → editor core → structural gestures → readings + views → hardening → the UI design passes with the author → sync → accounts → the mobile app (its own project) → web.

## 14. Resolutions & deltas from the source SPEC

Resolved (source SPEC §14 open questions): 1. single-variant divide in place ✔ · 2. unified `container` ✔ · 3. tagging as two tables with real FKs (deliberate schema delta) ✔ · 4. cascades as triggers; no variant→commit_point cascade ✔ · 5. the sync engine decided up front — hand-rolled row sync; PowerSync-class engines rejected (SyncSpec §1) ✔ · 6. pool-copy scope: active variant by default, `includeFan` from day one ✔ · 7. churn metric: characters, inserts + deletes equal weight ✔ · 8. headings are Markdown text, no column ✔ · 9. `default_variant_id` lifecycle (§9) ✔ · 10. edge directionality: source = descendant ✔ · 11. fractional-index positions, no rebalance ✔. Additional deltas: live-row partial unique indexes everywhere; I10 added; `chosen_variant_id` fallback semantics; the concretized stack.

**The delta record.** A phase's canon delta lands in this document as a CONTRACT line (what is now true) plus a pointer to the plan file that carries the ruling — never a paragraph of history. This section keeps ONE LINE per recent effort (the most recent ~five, always including the most recent MCP effort's): the effort, its record file, and which sections it changed. Everything else about an effort — its cast, rounds, tallies, merge order, born tickets, the ratify bundle — lives in `notes/plans/run-finals-ledger.md` and the plan or fix file; the dated entries roll verbatim to `notes/AppSpecDeltaArchive.md` at each closeout (the pre-2026-10-18 entries are there now, under the VX-419 heading).

| Effort | Record | Sections changed |
|---|---|---|
| VX-306 — the Castle open road (a phase, 2026-10-18) | `notes/plans/vx-306-castle-open-road.md`; bundle QUESTIONS #234 | §12 THE OPEN ROAD paragraph. One `Sync/` line (the `protection_record` local-only registration); zero `Server/` lines; marker 13 untouched. |
| VX-348 — the pre-launch bug sweep (a run, 2026-10-18; the most recent MCP effort) | `notes/plans/fixes/vx-348-prelaunch-sweep.md`; bundle QUESTIONS #233 | §7 grants family v1_30; §12 THE DOOR'S GROWTH, ⌘S ALWAYS COMMITS, NARROW WIDTHS, the every-speaker hover, the Pool's receipt line. Local-only; marker 13 untouched. |
| VX-382 — book view doors & reds (a run, 2026-10-18) | `notes/plans/fixes/vx-382-book-view-doors.md`; bundle QUESTIONS #232 | §12 THE BOOK'S DOORS AND PLACE. No schema, `Sync/` or custody lines. |
| VX-378 — Castle simplified (a phase, 2026-10-16/18) | `notes/plans/vx-378-castle-simplified.md`; bundle QUESTIONS #231 | CLAUDE.md's read-explicitly list gains `notes/CastleRules.md`; §12 THE PROTECTION REBUILD. No `Sync/`, `App/`, `Server/` or schema lines. |
| VX-381 — gatherings & tags (a run, 2026-10-18) | `notes/plans/fixes/vx-381-gatherings-tags.md`; bundle QUESTIONS #230 | §9 structural undo gains `deleteTag`; the refusal table gains `duplicateTagPath`'s sentence (both platforms); the gathering mint allows NOT terms; the collect door sets the star through the union-star road (cap-exempt, ONE planner authority with the mint) and speaks the mint family's receipts with the honest archived tail; the shared-note notice counts BOOKS only; `CalmButtonStyle` wears a token-derived disabled face app-wide; the Settings `.opening` arm says "Opening your library…". No schema or `Sync/` lines. |

## 15. Risk register (standing risks and why; deferred WORK is `KnownIssuesAndTechDebt.md`)

1. **Live block-identity maintenance over `NSTextStorage`** — the single riskiest thing in the project: identity is maintained DURING editing (block IDs as attributes, exact changed ranges), never recovered by diffing. Hence headless operations first, editor phases of their own, pure boundary snapping, and the per-keystroke identity oracle in DEBUG. If an editor bug corrupts identity, the store is still safe — operations validate against the DB.
2. **TextKit 2 viewport/height/scroll-to-location** is the least reliable subsystem of the chosen stack and shifts between point releases. Live geometry was adopted after the Phase 6 spike; what survives is re-verifying after every macOS update (`notes/TEXTKIT2_NOTES.md` §5 — its §3 records each release's measured deltas).
3. **Hand-rolled sync** — chosen with eyes open because the engines fail this schema harder; the protection is the two-client fake-server harness and the convergence suites (any sync change without a convergence test is unreviewed; `notes/sync-postmortem-fragments.md` before touching `Sync/`).
4. **Resolved interpretations:** structural undo (not global undo); the reference panel (not a knowledge base).
5. **Decisions that must not silently regress:** jittered fractional-index positions (never REAL midpoints); live-row partial unique indexes (never bare UNIQUE); trigger-fed outbox capture; `server_seq` as the only ordering authority.
6. **Toolchain skew:** any second machine or CI must match the primary's Xcode major before its results count.

## 16. Still genuinely open

Phase 13's typographic PDF export · an optional derived audit/operation log · the UI, iterated with the author.
