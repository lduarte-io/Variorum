# Variorum — App Spec

**What this is.** The contract: what is true about the product, its schema, its operations and its surfaces, stated once and plainly. The vision is `CoreDescription.md`; the mental model and invariants are `OverallModel.md`. The reasoning behind every rule here — who ruled it, when, in what words, what it superseded — lives in `notes/AppSpecRecord.md` (the living record, same section numbers, appended at every closeout) and in the plan and fix files this document names. A pointer here reads *(record §N)*, a ruling id (R-…, P-…, U-…, S4-…), a QUESTIONS number, or a file. If code conflicts with this document, align the code or propose a deliberate change; where this document is silent, propose options and never invent behavior.

**Stack.** SQLite via GRDB 7, encrypted at rest with SQLCipher, rows as truth · Swift · a TextKit 2 `NSTextView` editor core · SwiftUI chrome with Observation and swift-dependencies, no TCA · an SPM core package and a thin Xcode app target · macOS first, iOS as a complete companion app (its own project), web someday. Sync is a hand-rolled row-sync protocol over Supabase/Postgres, authoritative in `notes/SyncSpec.md`.

**Sections.** §1–5 architecture · §6–12 conventions, schema, operations, sort, sync, views · §13 build order · §14 how changes land · §15 standing risks · §16 open items.

---

## 1. Development context

One machine is dev and acceptance: the author's M3 Mac on current macOS 27 and Xcode 27. Deployment targets are macOS 26 and iOS 26, with no older-OS support and no availability gating. `swift-tools-version: 6.2`; Swift Testing for all tests. The fast inner loop is `swift test` on the core package. Editor milestones re-verify after each macOS point release because TextKit 2 behavior is version-gated (`notes/TEXTKIT2_NOTES.md`).

## 2. Code architecture

- **`VariorumCore`** (the Swift package) holds everything below the UI: `Models`, `Persistence` (the database stack, migrations, the reader/writer pool), `Domain` (pure rule functions), `Operations` (the transactional API, §9), `Queries` (read-side traversals and observations), `Sync`, `Protection`.
- **The app target** is a thin wrapper: `App/Variorum/Variorum/` (the Mac entry, root composition, `Features/` with one folder per module, `Core/Views` for shared Mac chrome), `App/Variorum/Shared/` (cross-platform brains and faces), `VariorumMobile/`.
- **Pattern.** SwiftUI with `@Observable` view models and swift-dependencies (`@Dependency(\.database)`, `\.date`, `\.uuid`). View models hold projections and IDs, never copies of persisted text, and call operations; domain rules are pure functions; persistence and side effects live in injected dependencies. The editor core is AppKit (`NSTextView` via `NSViewRepresentable`). One feature is one module; cross-feature interaction routes through parent composition (CLAUDE.md states the exact rule).

## 3. Architectural decisions

Settled, with the why-nots in OverallModel §8: SQLite rows as truth via GRDB 7 with code-first migrations; operations as the only API (never ad-hoc row edits); history native to the domain (commits, fans and edges are append-only; an audit log would be derived, never truth); row-based sync designed up front (§11); web someday via WASM SQLite on the same schema.

## 4. Performance architecture

**P1: cost is proportional to what is on screen and what is being edited, never to the size of the document or the corpus.**

- Storage: tiny writes (an edit writes one `variant` row), indexed reads, never the blob. WAL and a connection pool; all database I/O off the main thread (P2).
- Editing: TextKit 2 viewport layout; block IDs ride block ranges as text attributes so edits stay scoped; keystroke cost is bounded by the visible region.
- Rendering: long views virtualize; unfocused units render as lightweight read-only text and only the focused unit is a live `NSTextView` (P3, the same architecture as "calm default, one block blooms").
- An escape hatch exists but is unbuilt: within-post virtualization at 100k+ words.
- Live TextKit 2 geometry is adopted; the stored-estimate scrubber and STTextView are documented fallbacks. Measured per-release deltas live in `notes/TEXTKIT2_NOTES.md` §3.

## 5. Invariants

I1–I9 (data), P1–P3 (performance) and S1–S5 (sync) are defined in OverallModel §4–6. One more is formalized here:

- **I10 — a live block has at least one live variant.** Deleting or archiving a block's last active variant is not a variant operation; it is deleting the block. The operations layer enforces it (`deleteVariant`, `archiveVariant`, the ceremonies' birth checks).

## 6. Conventions

- Primary keys are random UUIDv4 `TEXT`, minted via `@Dependency(\.uuid)`. Timestamps are ISO-8601 `TEXT`. Booleans are `INTEGER` 0/1. `PRAGMA foreign_keys = ON` and WAL.
- Soft delete is a `deleted_at` tombstone (S2). Domain "archive" (`variant.status='archived'`, `container.archived_at`, `block.archived_at`, `reading.archived_at`) is a separate kept-but-out-of-view concept.
- **Uniqueness is scoped to live rows.** Every uniqueness rule is a partial unique index `… WHERE deleted_at IS NULL`, never a bare `UNIQUE`, and every such index has a deterministic apply-time repair rule (SyncSpec §7).
- Top-level entities carry a nullable `owner_id TEXT` for row-level security (S4).
- **Ordering is a fractional-index `TEXT`** (base-62 keys with per-call jitter, the pure `FractionalIndex.between`). Inserts are O(1), depth is unlimited, and no rebalance operation exists. The sort key is always `(position, id)` (SyncSpec §8).
- Every synced table carries `sync_version INTEGER NOT NULL DEFAULT 0`, the server's compare-and-set token. Outbox population is an AFTER INSERT/UPDATE trigger on every synced table, suppressed during remote apply via `_sync_applying` (SyncSpec §3).
- **Cascades are triggers, not `ON DELETE CASCADE`**, because row sync applies records out of order. Local-only RESTRICT guards (`chosen_variant_id`) stay as constraints. Triggers own exactly three things: tombstone propagation, outbox capture, and the mechanical derived-search-index capture (OverallModel §9).
- The table for the domain "commit" is `commit_point`. There is no variant→commit_point cascade: commits become unreachable when their variant is tombstoned and are cleaned up only by the purge design.
- Headings are Markdown text inside a block; there is no heading column.

## 7. Schema (DDL)

> Creation order: `container` and `block` first (circular FKs resolve at DML time), then `variant`, then the rest. Cascades shown as comments are triggers. The current migration set is `Sources/VariorumCore/Persistence/`; the design notes behind each column are record §7.

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
  FOREIGN KEY (variant_id) REFERENCES variant(id)  -- no cascade: unreachable once the variant is tombstoned (§6)
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
> **The Home wing is VIRTUAL (R-13ia-2):** rows here are ADDITIONAL wings only; every `wing_id` pointer (`container`/`tag`/`reading`/`shelf`, each `TEXT NOT NULL DEFAULT ''`) means Home when `''` — undeletable and convergence-proof by construction, no seeded row to race. Wings isolate totally: gatherings assemble, and search/tag listings/Arrivals scope, within ONE wing; the only crossings are the explicit move/copy doors. (record §7)

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
> `query_spec` holds the **v2 rule grammar** (`Domain/RuleGrammar.swift` — a boolean tree of tag-by-ID and star terms: subtree matching, renameTag-proof, dead terms match nothing; v1 specs migrated with legacy profile/date terms GRANDFATHERED — still parsed and evaluated, never malformed; a NULL is no rule, malformed fails closed per consumer). `profile='daily'` is THE daily Journal's marker (the mint stamps it, `setDailyJournalBook` moves it, SyncSpec §7's keeper keys on it); `'journal'` is the TRAIT every deliberate notebook door mints. (record §7)

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
> **Segmentation / the Return key:** fresh-text segmentation is type-time crystallization — while typing new text at the end of a post, each completed paragraph silently becomes a block; the trailing paragraph is an open tail. Bulk entry (paste, import, drop, mobile capture) segments on entry. Once a block exists, a NEWLINE inside it is content (I4). **On the Mac, with the segmentation chip ON, the Return KEY is a structural gesture routed through the one structural door** (`TypedReturn.act`, `Shared/EditorBrain`; the intercept at `EditorTextView.insertNewline(_:)` after the list door): an empty block below at a block's end, a divide at the caret inside its text (single-take in place; fanned → keep-on-top), an empty block above at its start, and in an EMPTY block another empty block below, chaining indefinitely; an abandoned empty block stays. ⇧⏎ is the newline that stays inside the block. The chip OFF returns the note to Return-as-content. Crystallization is untouched; the tail opens only from a newline arriving as text. The phone's Return model is its own. (U-1, U-19, R-13u4-2; unruled edges QUESTIONS #92.)

### local-only sync machinery (never synced; SyncSpec §3)
```sql
CREATE TABLE sync_outbox (table_name TEXT NOT NULL, row_id TEXT NOT NULL, queued_at TEXT NOT NULL,
  PRIMARY KEY (table_name, row_id));           -- dirty-row SET: coalesces keystroke-rate autosaves
CREATE TABLE sync_state (key TEXT PRIMARY KEY, value TEXT NOT NULL);
  -- keys: 'last_server_seq', 'pull_stage' (the pull stage's header) (device identity lives in the per-store
  --   custody record; VX-329 retired 'rekey_in_progress' with the rotation era)
CREATE TABLE _sync_applying (applying INTEGER NOT NULL);   -- apply-mode flag; permanent table, normally empty
CREATE TABLE sync_row_seq (table_name TEXT NOT NULL, row_id TEXT NOT NULL, server_seq INTEGER NOT NULL,
  PRIMARY KEY (table_name, row_id));           -- per-row server_seq bookkeeping for seq-ranked repairs
CREATE TABLE sync_pull_stage (table_name TEXT NOT NULL, row_id TEXT NOT NULL, server_seq INTEGER NOT NULL,
  payload TEXT NOT NULL, PRIMARY KEY (table_name, row_id));  -- v1_32: a pull's downloaded, not-yet-applied rows; an
                                               -- interrupted round resumes from it, the apply that moves the cursor
                                               -- empties it; the export drops it
                                               -- (notes/plans/fixes/vx-494-catchup-hang.md)
```
**Later SYNCED additions** (each a SyncSpec §12 lockstep event; the migrations are the DDL): `canvas_layout`, `lens`/`lens_choice`, `purge_intent`, and the PRIVATE MARK (v1_25, marker 13 — `Server/supabase/16_phase13nb_private.sql`): `container.ai_private_at` + `reading.ai_private_at`, nullable PLAIN timestamps (structure only on the wire — that something is marked, never which words), the AI-private fence's store truth (privacy wins ties, Private ⊥ Owned, gatherings refuse the mark).
**LOCAL-ONLY DERIVED, never synced** (no mirror, marker untouched; rebuildable from truth): **the search-index family** (v1_22–v1_23: `search_doc` + the `search_fts` external-content FTS5 table over the `search_text` view + shadows), maintained by the third trigger duty, rebuildable from truth (`Operations.rebuildSearchIndex`/`verifySearchIndex`), registered as `SyncSchema.derivedTables` — subtracted by the completeness walk, KEPT by the plaintext export so the no-lock-in file searches by itself; savepoints (`commit_point.text`) are the NINTH kind, listed only under the explicit commits facet, `search_doc.variant_id` the savepoint doc's own-row parent fact and its liveness resolving at QUERY time through variant → block → placement. **LOCAL-ONLY, never synced and NOT derived — the MCP GRANTS family, the door's only local truth** (v1_24 → v1_30): per-client × per-scope grant rows (the four rungs), the open-book switch, the activity log, the per-setup key pair (`mcp_setup_key` — a copied setup's key BY HASH until a name presents it — + `mcp_client.setup_key_hash`, the key bound to the name), `mcp_comment_author` (a comment's writing client by comment id, written in the comment's own transaction; no FK, purge-safe, the export STRIPS it; + `text_digest` — a comment stays the client's own only while its words are unchanged; NULL reads as unproven), `mcp_rebind_request` (a setup key waiting for her OK under an approved name, one row per client, the newer replacing the older; the key's HASH never the key, plus the declared version), and ONE standing grant row per client × place (a partial unique index; a new grant replaces the pair's row) — the door's LOCAL truth, decided per call by the pure `Domain/MCPGrantRule` (`notes/MCPSpec.md`; the records are the vx-168 · vx-184 · vx-246 · vx-348 fix files under `notes/plans/fixes/`). **The `protection_record` table** (v1_31) is local-only too (the plaintext export drops it). (record §7)


## 8. Cardinality summary
```
reading ──< reading_post >── container(kind=post)      many-to-many, non-owning (on-demand books)
reading ──< reading_section                            chapters: ordered groupings within a book
reading_post ──> reading_section (section_id)          a membership points at its chapter; dangling ⇒ unsectioned
container(post|pool) ──< container_block >── block     ONE live container per block (owning)
block ──< variant                                      one block, many variants (the fan)
block ──< block_comment                                working notes on a block, never per take
variant ──< commit_point                               append-only savepoints
variant ──> variant (parent_variant_id)                history/branch tree
block ──< edge >── block                               derived_from (directed), version_of (undirected)
tag ──< post_tag >── container(kind=post)              many-to-many
tag ──< block_tag >── block                            many-to-many
tag ──> tag (parent_id)                                hierarchy
wing ──< container · tag · reading · shelf (wing_id)   '' = Home; total isolation between wings
shelf ──< reading (shelf_id)                           nil/dangling = unshelved
```

## 9. Operations as a transactional API

Every mutation is one of these operations, one transaction each, through the operations layer. Row-level transitions are pinned by the operations test suites; the reasoning behind each operation is record §9 under the same name.

**Conventions every operation inherits unless it says otherwise.**
- Text-changing operations update `container.last_touched_at` and churn (§10). Structural operations stamp `last_touched_at` but never churn. Identity-level metadata setters are no-op guarded: nothing changes, so no touch, no churn, no outbox row.
- A sealed post refuses every authoring write under it: edits, commits, order, chosen variants, comments, presentation, take labels, savepoint names. The post itself may still be archived, deleted, retitled, tagged and added to readings.
- A locked take guards its buffer: edits refuse; branch or unlock instead.
- An `expectedText` precondition that no longer matches refuses as `bufferChangedSinceGesture`.
- Comments and the callout frame travel to structural successors (see "Travel" below).
- Structural operations register structural undo with an exact-row redo (see "Structural undo and redo").

### Blocks, variants, savepoints
- **newBlock(container, text, at)** inserts a block and a variant with `working_text = text`, sets `default_variant_id`, and inserts a `container_block` pointing at the variant at the given position. It registers undo (the inverse is a tombstone flip) except for type-time crystallization, which passes `registeringUndo: false` because crystallization is not a gesture.
- **autosave(variant, text, charDelta)** updates `working_text` and `updated_at` and accrues churn; crossing the threshold stamps the major revision, resets and rebaselines (§10).
- **commit(variant, kind = manual, message?)** inserts a `commit_point` with the variant's current text. It counts as a major revision. Refused on a locked take and under a seal.
- **Quiet auto-commits** are commits with `kind = 'auto'`, deduped against the take's last savepoint when the text is unchanged. Two are cadence occasions governed by the `savepoint_cadence` setting: the idle backstop (`idleAutoCommit(post)`, at most one per idle period, `idle_commit_hours` default 2) and `closeAutoCommit` when a note with unsaved changes stops being shown anywhere. The rest are insurance and always on: sealing a post; locking a dirty take; a structural undo about to overwrite a buffer edited since the operation; a cross-block compound about to overwrite the takes it edits (`insureTakes`); `moveSpanToNewTake`'s pre-move savepoint; and the MCP door's `edit_take` bracket ("before/after ‹client›'s edit", deduped, the after-stamp +1 ms; `notes/MCPSpec.md`).
- **restoreCommit(variant, commit)** sets `working_text = commit.text`; old commits remain (I5). A commit may predate a structural operation, so restoring can resurrect pre-split text into this block while the successor still stands; the editor warns.
- **renameCommitPoint(commit, message?)** sets or clears `message` (nil clears). A no-op writes nothing and earns no receipt. It refuses under a seal, checked before the no-op short-circuit, and is allowed on a locked take (PROVISIONAL #121). The snapshot text is immutable; `message` is plain metadata under sync.
- **branchVariant(block, fromVariant)** inserts a variant with `parent = fromVariant`, the text copied, at the next fan position. This is the default gesture. **newBlankVariant(block)** is the same with empty text.
- **moveSpanToNewTake(variant, span, expectedText)** moves a span out of a take in one transaction: a quiet auto savepoint of the current take; the take's `working_text` becomes the buffer minus the span, exactly as selected with no snapping or trimming (a doubled space at the seam is the author's, PROVISIONAL #128); a new variant on the same block with `parent = that take`, the span as text, at the fan's end, label NULL, never chosen and never born locked. One undo entry with exact-row redo; touch and churn as a buffer edit. Refuses a sealed post, a locked take, an archived or tombstoned take, a dead block, and a stale `expectedText`. The source keeps its remainder, and empty is legal (I10 untouched).
- **lockVariant / unlockVariant** set `locked`. Locking a dirty buffer first appends one quiet auto commit. Refused under a seal.
- **archiveVariant** sets `status = 'archived'`; **deleteVariant** tombstones. A deleted variant must not be any slot's chosen variant (re-point first); the operations-layer check is the only live enforcement, since tombstones are updates and RESTRICT never fires. Either refuses when the variant is the block's last live active one (I10: delete the block instead). When the variant was `default_variant_id`, the default moves to the most recently updated active variant.
- **`default_variant_id`** is set at `newBlock`, reassigned on delete or archive of the variant it names, and never NULL while the block is live. It is the pointer-free representative; `container_block.chosen_variant_id` wins wherever a pointer exists.

### The split taxonomy
One snapping rule serves every cut: plain divide, the ceremony's per-take cuts, `CutPropagation`'s seeding and extract's span edges all consult the Domain `BoundarySnapping`. A cut may fall between any two words and at newlines, with a word-edge floor and a gentle settle onto sentence ends and newlines (S4-22).

- **extract(blockA, span)** — the source survives. The span must be a boundary-adjacent prefix or suffix of A's active variant. Inserts block B with a variant holding the span, sets A's active variant to the remainder (other variants untouched), places B adjacent, and adds the edge B derived_from A with origin `extract`. A middle span is a divide. Extracting from a fanned block edits only the chosen take; the other takes keep their span, and the editor may hint.
- **divide(blockA, cut)** — the source is consumed. Single-variant: inserts block C with A's text after the cut, sets A's variant to the text before it, places C after A, edge C derived_from A with origin `divide`. Start and end cuts refuse (`invalidCut`). Fanned block, the default on both platforms: keep-on-top — the displayed take is cut into B and C and every other active take rides whole onto B (`KeepOnTopDivide`, composed from divide-W's parking rule, no new operation); keep-below is the mirror and the second preset.
- **divideW(blockA, marked takes with cuts, displayedVariantID?)** — the ceremony, "Divide choosing takes…". A is preserved whole: its placement is released and unmarked takes stay on A as lineage. For each marked take, a first-half variant goes on new block B and a second-half on new block C; B then C are placed where A stood; edges B derived_from A and C derived_from A with origin `divide`. Parking: a take whose cut sits at its very end rides whole into B, at its very start into C, so B's and C's fans are independently sized. Refuses when every take parks at the same end (`divideSideWouldBeEmpty`, I10 at birth) and on an empty take's cut (`invalidCut`). A parked take keeps its label. `displayedVariantID` anchors each side's chosen and default variant; nil keeps A's rendered take (PROVISIONAL #91). Reversible by re-pointing at A through `placeBlock`. The sheet's presets: keep takes on the top block (default), on the bottom block, copy takes to both (`divideDuplicating`), choose per take.
- **divideDuplicating(blockA, displayedVariant, cut)** — the displayed take's halves seed B and C as each side's chosen and default; every other active take is duplicated whole onto both successors with fresh UUIDs, labels riding, parent trees remapped per copy set, never born locked, commits never copied. A is released whole; edges as divide-W; comments copied to both; presentation inherited; archived takes stay on A; touch without churn; one undo entry. Start and end cuts refuse. Accepted consequence: a duplicated take chosen on both successors reads twice.
- **merge(B, C)** — mirrors divide-W. Inserts block A′ with one variant whose text is chosen(B) + one newline + chosen(C): the rendering join, byte-exact, no trimming, used on every merge door (the block menu and ⌘⇧M, the context menu, the palette, the N-way chain, the bulk bars, the ceremony's per-pairing default, the phone's Merge with Previous, Make Block across blocks). The delete keystrokes keep their own join (the seam ⌦/backspace carve and the cross-block compound's mid-paragraph edge-join, `Domain/MergeJoin.swift`'s `MergeJoinRule`). Both placements are replaced by A′; edges A′ derived_from B and A′ derived_from C with origin `merge`; B and C are released to lineage with `last_container_id` stamped; fans are never cartesian-producted; comments from both sides are carried; presentation is kept only when both sources agree, else plain. Refuses under a seal; adjacency required.
- **mergeCeremony(B, C, pairings, carries)** — "Merge choosing takes…" (S4-23). Each hand-placed pairing mints one joined take with an explicit join (newline by default, space, or nothing); each carried take rides onto A′ whole; the rest stay with the released sources. A take participates in at most one pairing (PROVISIONAL). Zero pairings and zero carries refuse (`mergedBlockWouldHaveNoTake`). Everything else as `merge`. Presets: bring every take (default), only the two shown, pair by hand. Over three or more blocks the door offers only the first two. A merge with no fan is byte-identical to `merge`.
- **poolDragCopy(P → post, at, includeFan = false)** inserts block B with the rendered take, or with the whole live fan when `includeFan` (archived takes ride with statuses preserved; commits never copied; not born locked; parent tree remapped), places it at the drop, adds the edge B derived_from P with origin `pool_copy`, and copies comments and presentation but never `name`. P stays. Pool to draft is the only copy direction.
- **importDocument(file) / importBook(folder, shelfId?)** read the Variorum document format (`notes/plans/phase-13n-a-document-format.md`), which is the fan export plus the capture-token header, parsed as the exact inverse of `joinRenderedTexts`: rows round-trip, any export re-imports whole, refusals name the line. A file mints a bookless note in the Pool; a folder mints an unshelved book with subfolders as chapters in digit-aware order, or on the given shelf. One transaction and one compound undo entry each: the inverse tombstones exactly what was minted on one stamp, the redo revives those exact rows, and an inverse that tombstones nothing never overwrites the stamp. Each block's in-place text is its chosen take and default; labeled takes join the fan's end unchosen; tags adopt or mint by path through the one application road, so living books hear them; touch without churn; the name guard preflights. No export path ever writes a row: a file is bulk entry, never reconciled truth.
- **moveBlock(block → container, at)** updates `container_block.container_id` and position (I2 by the live-unique index). **reorder(block, between A and B)** sets `position = FractionalIndex.between(...)`. **placeBlock(block, container, at)** inserts a placement for a live block that has none (a released block, a tray restoree); the primitive undo emits.

### Deletion, restoration, the tray
- **deleteBlock(block, requiring: precondition = .none)** tombstones the block and its placement, sets `last_container_id`, and the trigger cascade tombstones variants, comments and edges. `.none` is the ordinary door. `.emptyWithNothingUnshown(variantID:)` is the seam-backspace carve's authorization, re-checked inside the transaction: the named variant must be the block's one live variant, active, unlocked and empty, under an unsealed post, with no live comment; otherwise `blockCarriesUnshownText` or `bufferChangedSinceGesture`. The check is inside the transaction because a caller-side check would read the editor's deliberately stale projection; the same precondition rides the redo. The carve's caret lands where the deleted line break was: at the end of the block before it when the carved block sat after the separator, else at the start of the block after it (QUESTIONS #33(d) decides which block goes). Delete Block and archive land at the start of the block below, else the end of the block above.
- **restoreBlock(block)** clears the block's tombstone and those of children carrying the same `deleted_at` stamp (cascade victims; independently deleted rows stay dead), then places the block into `last_container_id`. A tag application revives only if its tag is live.
- **restoreContainer(container)** applies the same exact-stamp rule over placements, their blocks and children, memberships, post tags and references. Rows whose story diverged stay as they are: a block independently revived keeps its current placement; a membership whose reading died stays dead.
- **restoreReading(reading)** revives its chapters and memberships on the exact stamp; a membership whose post has since died stays dead; assignments reattach; a gathering restores by the flip alone; refuses when live. No undo entry. A member post that died after its reading is left out and is added back by hand.
- **Structural undo and redo** are session-scoped and in-memory and cover structural operations only: divide in all forms, merge in both forms, extract, newBlock, deleteBlock, deleteVariant, archiveVariant, moveBlock, reorder, poolDragCopy, moveSpanToNewTake, deleteTag, the conversions and the composites below. Each registration carries its inverse and an exact-row `redo` built from do-time pre-images, never a re-run, so IDs survive undo and redo; `register`'s `redo:` is required (nil means deliberately not redoable, and undoing past it ends the redo future). Any new structural act clears the redo future, a rolled-back compound included. Undo and redo emit ordinary operations, so sync never learns they exist. Excluded: text editing (⌘Z stays NSTextView's), commits, locks, tag applications. Doors ⌥⌘Z and ⇧⌥⌘Z, never ⌘⇧Z. A buffer edited since the operation is insured by a quiet auto commit before the inverse overwrites it. Two presses inside one flight refuse the second. A half runs only after its partner changed something: an undo that finds its act's result already gone (an undo-less door such as Put back, a restore, a rename, the author's ✓, a lock, the rule editor's Save, or a sync apply) changes nothing and retires its entry, leaving the other stack as it was, and the Mac's door says so as a refusal naming the entry; a redo re-applies exactly what its undo un-did, parts and stamps included, so it never writes over a change of the author's (PROVISIONAL #226; the sweep table in `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md` dispositions every registration). **deleteTag** is one "Delete Tag" entry: the inverse revives the subtree's tag rows with paths rebuilt from the live parent plus their applications dead on the delete's exact stamp; a live same-path twin refuses `duplicateTagPath` (the same sentence on both platforms) and keeps the entry; the redo re-deletes by the delete's own subtree rule on a fresh stamp.

### Posts, seals, extents, versions
- **lockPost / unlockPost** auto-commit dirty live buffers, then set `locked` and `locked_at`. The seal's reach is the convention above. `resolveSyncConflict` lands even under a seal (S5 outranks it). `unlockPost` refuses `noteInSealedBook` while a live sealed book holds the note.
- **setPostWordTarget(post, words?)** is display and progress only, never a refusal elsewhere; refuses non-positive; nil clears; no-op guarded; refuses under a seal (PROVISIONAL).
- **saveNoteVersion / restoreNoteVersion / promoteNoteVersion** are whole-note versions (`notes/plans/post-13l-polish-round.md`). `saveNoteVersion` makes a full family copy born archived and sealed from one clock read; `archived_at == created_at` is the version classifier; no title mutation, no `entry_date`. `restoreNoteVersion` preserves identity: it saves the moment of now first, the outgoing blocks take the Delete Now road (tombstone plus purge intents, never a raw DELETE), the version's family is copied into the same container, and every version link is re-anchored through the classifier. `promoteNoteVersion` unarchives, unseals and applies the original note's current live tags through the one application road, so it ends as Duplicate with Tags does. No undo entry; mobile-visible through the shared operation (PROVISIONAL #229). Versions ride the note's deletion on its exact stamp. A version's one home is Note ▸ Versions; `Queries.versionHistoryPredicate` excludes them from the Library, Archived and every global search.
- **divergePostForReading(post, reading)** in one transaction makes a `duplicateAsVersion`-shaped copy, gives it the original's exact slot (position and `section_id`) in this book, and tombstones the original's membership here (it lives on elsewhere). Curated books only; refuses under a finished book; capacity un-gated (net zero). One undo entry; the redo revives the copy through `restoreContainer`'s exact-stamp path. Doors flush the pending buffer first.
- **duplicateAsVersion(_:tags:) / promoteLens** make per-block copies carrying comments, presentation and `block.name`, with a `version_of` edge for the former. The duplicate is two doors (`notes/plans/fixes/vx-383-duplicate-note.md`): Duplicate with Tags applies every live tag the source wears through the one application road (`insertPostTag`), so living books hear the copy exactly as when the author tags (seat, bell, capacity, ownership); Duplicate without Tags applies none; the label "Duplicate as Version" is retired. One undo entry covers the copy and its seats; both doors are declared once in the capability registry (⌘K, File, both note menus, the note rows; inline doors route to with-tags) and speak one receipt naming where the copy landed, with "Open ›". The wire's `duplicate_note` shares the body (`notes/MCPSpec.md`).

### Readings, intake, ownership
- **addPostToReading / removePostFromReading / assertReadingAcceptsPosts(reading)**: the gate (missing, wrong kind, locked, at capacity) is a standalone core read run inside the serialized closure so a door can refuse before minting. `removePostFromReading` returns whether the note is now bookless ("Release" on an owned book).
- **Intake is event-driven** (`notes/plans/phase-13i-b-gatherings.md`). A living book (live, `kind = 'book'`, a readable rule, not finished, not archived) hears the applying act only: `applyTag` and `setStarred` through the one application road. The pure `Domain/IntakeDecision` table decides whether it seats (`status = 'member'`, at the end, unsectioned) or bells (`status = 'arrival'`): capacity waits at the door; the `intake_seating` dial, NULL meaning join quietly; un-tag and un-star are non-events; insert-only; tombstone means decided. Creation-time backfill seats; resume catch-up (restore, un-finish, un-archive, rule edit) bells. `lockReading` dismisses pending arrivals in its transaction. Judgment: **seatArrival / dismissArrival**. **saveFilterAsGathering(reading, filter)** mints a gathering from association and filter. Removing a rule never untags.
- **Ownership** (`notes/plans/phase-13i-c-owned-finished-sealed.md`). One pure consult, `Domain/OwnershipDecision`, is read by `addPostToReading` and `seatArrival` after the capacity gate: an owned target and a note membered in another book gives the copy-or-move choice; a plain target and a note owned elsewhere gives copy only; a bookless note is a plain add. The refusals `noteMemberedElsewhere` and `noteOwnedElsewhere` open the membership choice sheet; `shelveInDailyJournalBook` bells on a conflict (`.waitingAtDoor`, never a throw). **setReadingOwned(reading, true)** converts: every member also membered elsewhere forks in place (a full family copy takes this book's exact slot, tags ride the copy, the original's row here is tombstoned, the list is shown in the confirm); sole members own in place; refuses a gathering and a finished or sealed book; no undo entry. **setReadingOwned(reading, false)** lifts exclusivity and members stay. **copyPostIntoReading** copies in (the family copy's membership first, then the outflow; one undo entry); **movePostIntoReading** moves in (every other live row of the note severed and listed; refuses while a severed member sits in a finished book). Each has an `answering:` form for an arrival, the row decided member-class. **The revival pass** (`restoreContainer`, `restoreReading`, the bind's redo, `revertDiverge` / `reapplyDiverge`): the earliest-created membership stands, a later owned-side row demotes to an arrival, a later plain-side row beside a standing claim is tombstoned; a membership revives into a sealed book only when its note is sealed. The membership readers (`membershipElsewhere`, the Pool's exclusion, `readingsContaining`) count book rows only, live books only.
- **sealReading** makes a sealed book: shared members are forked in place first (fork-free on an owned book), the finish runs (pending arrivals dismissed; the confirm's count is the act's set, one shared predicate), `sealed_at = now`, and every member is sealed on that exact stamp with dirty buffers insured. **unsealReading** unseals the stamp-matched members and reopens the book with the catch-up. `unlockReading` on a sealed book refuses `readingSealed`.
- **deleteReadingWithNotes** is the owned book's second delete choice: the book and its member notes on one stamp, versions riding. **restoreReading** then returns the whole: stamp-matched member notes first, then memberships, then the revival pass, then the catch-up.
- **duplicateReading(name, deep)** copies configuration, not state: rule, outflow, dial, extents, trait, chapters; born unshelved, open, non-owned, unarchived. Shallow shares the same notes; deep makes family copies; an owned source duplicates deep only; a gathering never duplicates.
- **setReadingOutflow(reading, tagIDs)** sets the chosen outflow set: ordered, deduped, every tag live in the book's wing; `[]` means none. `applyAutoTag` applies every outflow tag on mint-inside and hand-add; `tagAllMembers(nil)` applies every outflow tag to every member. **setReadingHideOwned(gathering, Bool?)**: nil follows `hide_owned_default`.
- **shelveInDailyJournalBook(post)** puts the day's entry into the daily Journal as ordinary membership. The Journal is derived from the `'daily'` marker, never from the setting, which survives only as a written cache. An archived Journal comes back on every press: on a fresh pair before the savepointed filing (a refused filing still brings it back), on a decided pair the un-archive alone, nothing re-filed; open-today is kept, so ⌘J opens today's existing entry rather than minting a second; the ⌘J road speaks a quiet receipt when the Journal returned. It never throws and returns `shelved`, `alreadyDecided`, `bookFinished`, `bookAtCapacity`, `wrongKind` or `refused`. Any `reading_post` row for the pair, live or tombstoned, means the pair is decided, so a headless round never undoes a deliberate removal. When no Journal is designated or the designation dangles it creates and stars one (curated, `profile: 'journal'`, `entry_date` ascending); ⌘J delegates its whole ensure here; it never replaces a book the author designated (a finished, full or gathering daily book keeps its own status). It is a read-then-act composite, not one transaction (the tombstoned-row race is recorded and unpinnable without an op-level precondition). Its convergence under sync is SyncSpec §7's daily-Journal keeper repair.
- **createSection / renameSection / deleteSection / reorderSection / assignPostToSection / restoreSection** apply to curated readings only; gatherings refuse. A locked reading freezes chapter structure while rename stays free. `deleteSection` tombstones only the section (memberships keep the pointer and dangle as unsectioned); `restoreSection` is one flip that refuses when live, under a locked reading, or when the section died with its reading (restore the reading first). No undo entry.
- **setReadingWordTarget / setReadingMaxPosts** refuse non-positive values and a locked reading; `word_target` is display only; lowering `max_posts` below membership is legal and further adds refuse. `lockReading` and a non-nil extent refuse a gathering (`wrongReadingKind`); clearing stays legal.
- **convertSmartReadingToCurated(reading, order: nil)** binds a gathering into a book in one transaction (PROVISIONAL #46): the current assembly materializes as `reading_post` rows in the given order (nil means the stored sort), `kind` becomes book, `sort_field` becomes manual, and `query_spec` and `grouping_tag_id` stay on the row, so the bound book keeps collecting. Refuses a non-gathering and a locked reading. Undo and redo: the un-bind leaves no live row on the reverted gathering (every taken row flips to the dismissal class as it tombstones; hand removals keep their member-class tombstones) and the redo restores each row as what it was, ids and statuses alike.
- **setJournalTrait(reading, on)** sets `profile` to `'journal'` or `'book'`; the `'daily'` book refuses because its marker is constitutive (PROVISIONAL); a finished book refuses; no-op guarded. **setDailyJournalBook** moves the `'daily'` marker with the designation in one transaction, demoting every other live `'daily'` row to the trait; refuses a non-book and a dead or missing designee. **setShelfPinned / Queries.shelfPins** read and write `reading.starred`; the `shelf_pins` setting is retired-as-read.
- **Book archive** (`notes/plans/phase-13i-e-daily-journal.md`, PROVISIONALs #179). **archiveReading** archives a book or a gathering, the daily Journal included, with one row write. **archiveReadingWithNotes** is the owned door's second choice: the book's not-yet-archived member notes get `container.archived_at` on one stamp; never tombstones, never versions; the operation refuses only a gathering. **unarchiveReading** clears the flag, returns exact-stamp members whole, and a living book's resume catch-up bells rather than seating. While archived: out of the Bookcase, census, counts and catalog and listed under Archived; auto-ingestion paused in the one intake table (`intakeRuns`) and visibly so; explicit adds land (no `readingArchived` refusal exists; the pickers mark "(archived)"); a gathering assembles empty everywhere; membership stays a fact and an archived book still homes and owns its notes; the name guard skips archived names; pending arrivals keep waiting; Finished, Sealed and locked are orthogonal; a duplicate is born unarchived; restore from Trash returns archived; double archive or unarchive refuse; no undo entry. **The daily Journal** derives from the `'daily'` marker (`Queries.dailyJournalBookID`, the keeper's smallest-id pick). `deleteReading` and `deleteReadingWithNotes` refuse it (`dailyJournalCannotBeDeleted`, on the marker, inside the write), and every door shows Archive in Delete's place on both platforms.
- **The Bookcase operations** (`notes/plans/phase-13i-d-bookcase.md`, PROVISIONALs #170–#178). Shelf operations: create, rename, glyph, delete, move; `setReadingShelf`; `placeReading`'s one my-order sequence; deleting a shelf returns its books to unshelved. **ensureWelcomeShelf** adopts by role and is the seeder's home (§12, the seed set). **The union star** is one star in one transaction over both stores; `setShelfPinned` routes through it; the Mac's Pin door is retired into Star and Unstar; the daily Journal and Quicknotes are born starred. Wing operations: mint and rename; delete refuses unless the wing is empty, naming its contents and the bulk road. **moveReadingToWing / moveWingContents** move members whole with tags adopting by path, sever and list stay-behind memberships, carry finished and sealed books whole and archived books archived, dismiss and say pending arrivals, land unshelved, and tombstone source tags left without applications, so the wing ends empty; the daily Journal refuses both; no undo. Cross-wing undo revivals are obsolete: `revivalWingScope` makes a replay that would cross wings do nothing. `seatArrival` seats an archived note as an archived member; intake's automatic seats never seat one; finishing dismisses every waiter.

### Tags, comments, presentation, references
- **renameTag(tag, newName)** rewrites `name` and the subtree's materialized `path` in one transaction; under sync each row is plain CAS, so the worst case is a lost rename. **applyTag / removeTag** on a post or block insert or tombstone an application; `post_tag` targets must be posts. **deleteTag** registers structural undo (above).
- **addBlockComment / editBlockComment / deleteBlockComment / restoreBlockComment**: delete is a tombstone; deleted comments stay visible and resurrectable (`Queries.deletedBlockComments`). **purgeBlockComment** is the true delete: the Delete Now shape with a purge intent and the purge horizon, offered as "Delete forever…" beside Restore in the deleted fold, confirmed each time; tombstoned comments only; `restoreBlockComment` and the MCP add_comment redo road void pending intents; the purge fence and `restoreCost`'s deleted-comment count are stamp-aware. All comment writes refuse under a seal (PROVISIONAL #23).
- **Travel.** Extract and divide keep A's comments and copy them to the minted half; divide-W and divideDuplicating copy to B and C; merge carries both sides'; poolDragCopy, duplicateAsVersion and promoteLens carry per-block copies. Copies are fresh owner-stamped rows preserving the source's `created_at`; deleted comments never travel; structural undo needs no extra machinery because reverting a mint cascades the copies.
- **setBlockPresentation / updateBlockPresentation** are identity-level: no-op guarded, no touch or churn; the update is a read-modify-write in one transaction; refuses under a seal (PROVISIONAL #24). Successors inherit the frame; merge keeps it only when both sources agree; duplicateAsVersion and promoteLens copy it with `name`; poolDragCopy copies it and the comments but never `name`. Export maps a callout to a blockquote.
- **setBlockName / setTakeLabel** are identity-level metadata; a seal refuses `setTakeLabel`.
- **addReference / removeReference / updateReferenceViewState** insert, tombstone and update `reference` rows.
- **resolveSyncConflict(variant, losingText, label = 'conflict')** inserts a variant with the losing text on the same block, same parent, at the fan's end (S5). It lands under a seal and refuses a dead block; the engine's in-apply rescue skips one silently.
- **applyBridgeLanding** is retired (tag `archive/fragments-bridge-2026-09-04`); the Fragments bridge no longer exists.

## 10. The "80%-edited" sort

Two stamps per post: `last_touched_at` (every keystroke) and `last_major_revision_at` (meaningful edits). The editor reports a character delta per edit; `churn_accumulator` (inserts and deletes, equal weight) accrues against `baseline_length`. When `churn / max(baseline, 1) ≥ threshold` (the `major_revision_threshold` setting, default 0.8), the operation stamps the major revision, resets the accumulator and rebaselines. A manual commit also stamps. A reading's `sort_field` picks the stamp; journals sort by `entry_date`. Churn math is a pure Domain function. The Library's day filter answers "notes edited on this day" as the union of the last-edit stamp and any savepoint written that day.

## 11. Sync architecture

**Authoritative: `notes/SyncSpec.md`.** Read it in full before touching sync, custody or any schema. In summary: a hand-rolled, state-based row sync over Supabase/Postgres; a dumb server (compare-and-set plus a per-tenant `server_seq` changefeed); all merge intelligence client-side — conflict-as-variant for `working_text` (S5), server-wins for metadata, deterministic apply-time repairs for every live-unique index, deferred-FK batch application, a trigger-fed coalescing outbox with apply-mode echo suppression; the wire is end-to-end-encrypted ciphertext sealed at the payload serializer; multi-tenant with row-level security; the migration-lockstep rule (SyncSpec §12) governs every schema change.

## 12. Views and the UI stance

Many views over one store is the point: each is a different traversal that stress-tests a different edge of the model, and a view that is tortured to build reveals a weak spot in the model. The load-bearing constraint throughout is P3's split between cheap reading and one focused editor. This section states the stance and the rules that cut across surfaces. **The full contract of each surface — every ruled behavior of the Library, the Bookcase, the note's modes, search, import, the MCP door, portability and protection — is `notes/SurfaceContracts.md`, read in full for every surface an effort touches, at preflight.** The design records are the plan files named there and `notes/plans/phase-13-ui-design.md` (rulings R1–R94); the narrative behind every line is record §12.

### The app
- **Two voices, exactly two: Terminal (leads) and Study**, each with tokens and idioms; light designed first; dark a fully black room in both voices under every palette; all fonts macOS-shipped; Study the fresh-store default while an existing store keeps its voice. A colour palette layers under the voice through one pure rule (`PaletteDerivation`); appearance (follow system, light, dark) is a local preference. No literal colour exists outside the token layer (pinned).
- **The sidebar:** Bookcase · Library · Pool · Snippets · Archived, with the Trash door on the Library masthead; an Open list and a Starred list (SurfaceContracts, The Open list). Library is everything; Pool is bookless notes; Snippets is the scraps area. ⌘K is the palette; ⌘N is New Post; Settings (nine searchable panes) is tag management's home.
- **Messages carry a kind on the one status seam: refusal, offer, receipt**, decided at the door. The synced `receipt_style` (toast, quiet, off; quiet by default) governs receipts only, as a muted line at the bottom bar's trailing end; refusals and offers always toast; a door that did nothing speaks a refusal. An AI write's line is a receipt carrying a one-press "Open ›" door (⌥⌘O, "Show the AI's Last Change", alive past the fade and under off). A toast never covers the quick-entry band; the Pool hosts the shared `QuietReceiptLine` at its foot.
- **The commit vocabulary:** the app says "commit" wherever a savepoint is named; the sentences that define it say "saved moment"; ⌘S always commits (every way of leaving the name field but ⎋ files; one filing per press; the take the ask named). Full rule: SurfaceContracts, The app.
- **First open:** no popup ever greets a first open; the app's own asks wait for days of use and calm moments and are always answerable in Settings. A fresh store opens on the Bookcase with quick entry at its foot and one quiet offer line; the tour (ring and cards, no dimming, Mac-only) is re-enterable from Help. The seed set and the capture microsyntax (`{#tag/path}`, `{t:"…"}`) are in SurfaceContracts, The app.
- **Keyboard family:** ⌘[ ⌘] indent; ⌥⌘[ ⌥⌘] back and forward; ⌥⌘Z ⇧⌥⌘Z structural undo and redo (never ⌘⇧Z); ⇧⏎ the in-block newline; the merge chord said on every face from the capability registry.

### The Library
Everything, as List or Cards (Cards always shows notes), with a muted time stamp whose hover is the whole fact, `sort ▾`, the day filter, and the controls row that never changes its line count as the author types, sorts or searches. **Search is the one finder:** full body-text over the living corpus on a local-only derived FTS5 index, accent and case folding, versions fenced, archived and commits behind explicit facets, the Trash out; it scales with matches, never the corpus (P1, pinned); a passage click lands in Write at the block with the match selected. The Library and its search are hide-owned-exempt. Full contract: SurfaceContracts, The Library.

### The Bookcase and books
Shelves as a mode-row strip led by the virtual starred shelf; solo and All; Unshelved at the top of All; Welcome for the seeded content; the № census; order a–z or last edited (my order stepped back); no search box and no time filter. A book's Arrivals live on its masthead icon and the one word is "Arrivals"; opening a waiting row never seats. The Book Panel, the wing switcher (the app's one wing follows the focused note), the book settings sheet with its Collecting sentences and state doors (Finished, Seal/Unseal, Own/Stop Owning), the membership choice sheet on every ownership refusal, Delete with the owned book's two choices and Archive in Delete's place on the daily Journal, the badge family, and the book's mode row Outline · Index · Book · Read whose every open door lands in Write at the author's block. Full contract: SurfaceContracts, The Bookcase and books.

### The note
- **The mode row: Write · Takes · Read · Lenses · Compare · Blocks · Canvas** (⌘1–⌘7 from the one order; Canvas is Debug-only, so Release has six). A note first opens in Write with per-note mode memory; the session's first open shows the start in every mode and an in-session re-open restores the page the author left. Takes is single-column fan work with the lens-aware `show ▾` filter; Read carries the in-place `edit · read` switch (P3's one live editor through `PaneTextAuthority`); Lenses is the one home of all lens machinery; Compare holds Outline; Blocks is the power-user workbench; Canvas is a view on a post or the scraps area.
- **The editor language.** Boundaries invisible at rest, dotted seams on a global toggle; the editing indicator a setting. Comments and callouts render in the whitespace gutter outside the text area on every surface, and the prose column's measure and left edge never move for a decoration (pinned per surface); comment editing lives in the panel; a callout's leading glyph is one grapheme; margins are sacred; everything visible in an editing surface is editable; a corner badge only on fanned blocks. The live editor's markdown face honours a closer at the caret while every non-live reader keeps the flanking rule byte for byte. Write's take panel acts on its block, never the caret block beneath it. An unsubmitted comment is kept for its block and never filed by keeping.
- **The two ceremony sheets**, Divide choosing takes and Merge choosing takes, open on a preset row (§9) with real prose side by side. **This Note's Tray** holds Leaving and Archived. **The reference panel** shows `reference` rows as a viewing aid. **Export** maps a callout to a blockquote. Full contract: SurfaceContracts, The note.

### Doors to the outside
- **Import and Copy full text** read and write the Variorum document format (`Domain/VariorumDocument`, the export's one home); a file imports as a Pool note, a folder as a book; no export path writes a row.
- **The MCP door** is authoritative in `notes/MCPSpec.md`. The rules any session can break without knowingly touching MCP: every AI write is one of §9's operations with the grant check inside its transaction and one ⌥⌘Z entry naming the client; the author's pending typing lands before any wire act; Private, Seal and Own are hers alone (no MCP road writes `ai_private_at`, `sealed_at` or `owned`); the fence answers hidden and missing with one byte-identical shape; grants are local-only and never synced; a rule an AI writes bells and never backfill-seats; the shared icon reads reach only for the rows drawn and nothing while no client is approved (P1); `show_in_app` never raises windows. Full list: SurfaceContracts, Doors.
- **Library portability** sends and opens a library as the road's folder pair (the store and this design's key file), adopts with the current library stepping aside whole into Previous Libraries, and lands held until Resume Sync; the live library is never placed in iCloud Drive. **Library protection** is authoritative in `notes/CastleRules.md`; the road is live in EVERY build since VX-329 (`ProtectionRoad.live` — today's road deleted whole; `notes/plans/vx-329-release-switch.md`), and a store from before the design gets the pre-design face (detect by name, say, set aside whole — never read). Full contract: SurfaceContracts, Doors.

The views the model must support beyond today's surface — side-by-side, swap-and-reread, diff with optional whitespace normalization, infinite scroll, timeline as a Library view mode, the collapsible block index — are capabilities, built functional first; the UI is iterated with the author.

## 13. Build order

`notes/DetailedPlanForPhases.md` governs product advancement; fixes and debt are VX tickets. The shape: substrate (schema → operations → queries) → editor core → structural gestures → readings and views → hardening → the UI design passes with the author → sync → accounts → the mobile app (its own project) → web.

## 14. How a change lands

A change to the product lands in this document as the changed contract line, in place, under the section it belongs to, plus one pointer: the plan or fix file, a ruling id, or a QUESTIONS number. The dated narrative — her rulings in her words, the ladder, the cast, the born tickets, the PR — is appended to `notes/AppSpecRecord.md` at the same closeout, under the same section and operation or surface name. Nothing in this document records who ruled what or when; nothing in the record is ever rolled out. The deltas from the original source spec (`notes/source/SPEC.md`) and the resolved questions of its §14 are recorded in `notes/AppSpecRecord.md` §14 and `notes/AppSpecDeltaArchive.md`. `Tools/canon-size` reports the loaded set's size at every closeout; a session never removes canon to make its own change fit (CLAUDE.md, canon hygiene).

## 15. Risk register

Standing risks and why; deferred work is tickets.

1. **Live block-identity maintenance over `NSTextStorage`** is the single riskiest thing in the project: identity is maintained during editing (block IDs as attributes, exact changed ranges), never recovered by diffing. Hence headless operations first, editor phases of their own, pure boundary snapping, and the per-keystroke identity oracle in DEBUG. If an editor bug corrupts identity the store is still safe, because operations validate against the database.
2. **TextKit 2 viewport, height and scroll-to-location** is the least reliable subsystem of the chosen stack and shifts between point releases. Live geometry is adopted; what survives is re-verifying after every macOS update (`notes/TEXTKIT2_NOTES.md` §5).
3. **Hand-rolled sync** was chosen with eyes open because the engines fail this schema harder. The protection is the two-client fake-server harness and the convergence suites: a sync change without a convergence test is unreviewed (`notes/sync-postmortem-fragments.md` before touching `Sync/`).
4. **Resolved interpretations:** structural undo, not global undo; the reference panel is not a knowledge base.
5. **Decisions that must not silently regress:** jittered fractional-index positions (never REAL midpoints); live-row partial unique indexes (never bare UNIQUE); trigger-fed outbox capture; `server_seq` as the only ordering authority.
6. **Toolchain skew:** any second machine or CI must match the primary's Xcode major before its results count.

## 16. Still genuinely open

A typographic PDF export · an optional derived audit/operation log · the UI, iterated with the author.
