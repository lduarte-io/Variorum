# Phase 1 — Schema & Migrations (Execution Plan)

**Status:** ✅ complete (closed 2026-07-04) — see Closeout at the bottom

## Kickoff message (for a fresh session)

> You are starting **Phase 1 of Variorum** — the schema as GRDB migrations. Read, in order: `CLAUDE.md`, `notes/OverallModel.md` (all), `notes/AppSpec.md` §5–8 (invariants, conventions, DDL), `notes/SyncSpec.md` §3 + §8 (client sync machinery + fractional positions — they live in schema v1), and this plan. The Phase 0 closeout in `notes/DetailedPlanForPhases.md` is your baseline: `VariorumCore` package skeleton exists and `swift test` is green — do not re-verify it, start at Step 1. Work step by step; each step lands with its tests; migration + triggers get their own commit. Note: an author review session of Phase 0's decisions may be pending — if `git log` shows review changes to `notes/`, read those diffs first. When done, run the closeout ritual (record results here, update the master plan table + pointer, write the Phase 2 plan with its own kickoff message).

**Goal:** the full v1 schema exists as GRDB migrations with invariants DB-enforced and the client-side sync machinery in place (per SyncSpec — `sync_version`, outbox + triggers, fractional-index `TEXT` positions), record types defined, and a database stack honoring P2 — proven by tests, with zero UI and zero operations logic (operations are Phases 2/3; the sync *engine* is Phase 5).

**References:** @notes/OverallModel.md, @notes/AppSpec.md §5–8, @notes/SyncSpec.md §3/§7/§8, @notes/DetailedPlanForPhases.md, CLAUDE.md.

---

## Steps

### Step 1 — Database stack
**Files:** `Sources/VariorumCore/Persistence/AppDatabase.swift`, `AppDatabase+Dependency.swift`.
**Work:** `AppDatabase` wraps a `DatabasePool` (WAL, `foreign_keys = ON`, busy timeout); factories `.onDisk(url:)` / `.inMemory()`; registered as a swift-dependencies `DependencyKey`. All access via `pool.read`/`pool.write` — nothing exposes a raw connection (this is what keeps P2 enforceable). Include an `applyingRemote { }` write variant that creates/populates the `_sync_applying` temp-table flag for the transaction (SyncSpec §3) — the flag ships now because outbox triggers check it; the engine that uses it is Phase 5.
**Tests:** in-memory DB opens; `foreign_keys` ON inside read and write; WAL on the on-disk variant (temp dir); `applyingRemote` sets and clears the flag.

### Step 2 — Migration `v1_core`: tables + indexes
**Files:** `Sources/VariorumCore/Persistence/Migrations.swift`.
**Work:** one migration creating, in order: `container`, `block` (circular FKs resolve at DML time), `variant`, `commit_point`, `edge`, `container_block`, `reading`, `reading_post`, `tag`, `post_tag`, `block_tag`, `reference`, `setting`, plus local-only `sync_outbox` and `sync_state` — exactly as AppSpec §7, with:
- `sync_version INTEGER NOT NULL DEFAULT 0` on **every synced table** (all except the two local-only ones; `setting` IS synced — upsert-only, no tombstone),
- **all partial unique indexes (`WHERE deleted_at IS NULL`)** and plain indexes,
- positions as `TEXT` (`container_block.position`, `reading_post.position`, `variant.fan_position`, `reference.position`),
- `tag.updated_at` present (review fix); `reference.file_bookmark` is local-only under sync (a Sync-layer exclusion, not a schema difference),
- seeds: `('default_segmentation','paragraph')`, `('major_revision_threshold','0.8')`, `('idle_commit_hours','24')`.
**Tests:** migrator clean + idempotent across re-open; every table/index exists (`sqlite_master`); seeds present; circular block⇄container insert works in write order.

### Step 3 — Constraint behavior (the invariant backstops)
**Files:** `Tests/VariorumCoreTests/SchemaConstraintTests.swift`.
**Tests, one per rule:**
- **I2:** second live `container_block` for the same `block_id` fails; tombstone the first → insert succeeds.
- **I3/RESTRICT:** physically DELETE-ing a `variant` referenced by a live `chosen_variant_id` → FK error. **Wording matters (review #3):** under soft-delete, tombstones are UPDATEs and RESTRICT never fires — this test documents that RESTRICT guards only the future GC/purge path; the *live* guard is the ops-layer check (Phase 2's tests own it).
- Tombstone-then-recreate allowed for: `tag.path`, `edge` triple, `reading_post` pair, `post_tag`/`block_tag` pairs.
- CHECK constraints reject bad `kind`/`status`/`type`/`profile`/`sort_field`.
- FKs enforced on every child table (dangling id fails).
- Position columns accept/order fractional-index strings lexicographically (`ORDER BY position, id`).

### Step 4 — Triggers: tombstone cascades + outbox capture
**Files:** `Sources/VariorumCore/Persistence/Triggers.swift` (created inside `v1_core`).
**Ownership decision (document in code):** triggers own *downward tombstone propagation* and *outbox capture*; the operations layer owns semantic side-effects (`last_container_id`, default-variant reassignment, timestamps — no `updated_at` triggers; time comes from `@Dependency(\.date)`).
**Cascade set (transition-guarded: fire only on `deleted_at` NULL→value; idempotent):**
- `block` tombstoned → tombstone its live `variant`s, `container_block` row, `edge`s (either side), `block_tag`s.
- `container` tombstoned → tombstone its live `container_block` rows **and their blocks** (singly-owned; the block trigger cascades further), its `reading_post`, `post_tag`, and `reference` rows.
- `reading` tombstoned → its `reading_post` rows. `tag` tombstoned → its live `post_tag`/`block_tag` rows (tag *subtree* deletion is an operations-layer loop — keep `recursive_triggers` off; note for Phase 2).
- `commit_point` has no tombstone column: unreachable once its variant is tombstoned; physical cleanup is the Phase 12 GC.
**Outbox set (SyncSpec §3):** AFTER INSERT and AFTER UPDATE on every synced table → `INSERT OR REPLACE INTO sync_outbox(table_name, row_id, queued_at)` — **unless** `_sync_applying` exists (echo suppression). Note: outbox rows for cascade-produced writes are correct and wanted (the originating device ships everything).
**Tests:** one per cascade + one chain test (container → container_blocks → blocks → variants + edges + block_tags, one transaction); already-tombstoned rows keep their original `deleted_at`; outbox captures direct writes AND cascade writes; `INSERT OR REPLACE` coalesces repeated updates to one row; writes inside `applyingRemote { }` produce zero outbox rows while cascades still fire.

### Step 5 — Record types
**Files:** `Sources/VariorumCore/Models/` — one record per table + enums (`ContainerKind`, `Profile`, `VariantStatus`, `EdgeType`, `CommitKind`, `SortField`, `Segmentation`, `ReferenceKind`).
**Work:** `Codable, FetchableRecord, MutablePersistableRecord`; GRDB associations (block→variants, variant→commitPoints, container→containerBlocks, reading→readingPosts, tag→children). IDs random UUIDv4 via `@Dependency(\.uuid)` (SyncSpec §9 — no UUIDv5).
**Tests:** round-trip insert/fetch per record; enum columns map both directions; association fetches return expected rows.

### Step 6 — Verification & closeout
- `swift test` green on the Air (the phase baseline going forward).
- Commits: **migration + triggers as their own commit**, records as a second, tests alongside each.
- Closeout ritual per CLAUDE.md — including the Phase 2 execution plan with its kickoff message.

## Explicitly out of scope
Operations of any kind (even `newBlock`), churn logic, `FractionalIndex.between` (Phase 2 Domain work — this phase only stores/orders the strings), queries/observation, the sync engine, any UI, any Xcode project. If schema work reveals an operations- or sync-shaped problem, note it for Phase 2/5 rather than solving it here.

## Risks / things to watch
- GRDB 7 + Swift 6.1 strict-concurrency friction (Sendable records) — resolve per GRDB's Swift Concurrency guide, don't fight the library.
- Partial-index uniqueness is SQLite-enforced, not GRDB-conflict-handled — test against raw SQL behavior.
- Temp-table flag visibility (`_sync_applying`) is per-connection — verify the outbox-suppression test uses the same connection the flag was set on (pool!). *(Closeout note: overtaken by events — the flag ended up a permanent table; see below.)*
- Triggers must stay simple, single-transition, idempotent — they run during remote apply too (SyncSpec §5).

---

## Closeout (2026-07-04)

**Result: complete. `swift test` green on the Air — 37 tests, 0 failures** (5 stack, 7 migration, 8 constraint, 11 trigger, 6 record). This is the Phase 2 baseline.

**Commits:** `60e5752` (Step 1, stack), `95d2aef` (Steps 2–4, migration + triggers + spec correction), `b3871b7` (Step 5, records). Tests landed alongside each step per convention.

**What shipped, step by step:**
1. `AppDatabase` (WAL `DatabasePool` on disk / in-memory `DatabaseQueue` for tests; `foreign_keys` ON; busy timeout; sync + async `read`/`write`; no raw connection exposed) with `applyingRemote { }` echo-suppression writes; registered as `@Dependency(\.database)` (liveValue on disk, deliberately no testValue so unoverridden access fails tests).
2. `v1_core` migration: all 13 synced tables exactly per AppSpec §7 with `sync_version` on each, `sync_outbox`/`sync_state`/`_sync_applying` local-only, every live-unique index partial (`WHERE deleted_at IS NULL`), positions as `TEXT`, `tag.updated_at` present, the three setting seeds.
3. Constraint tests: I2 ownership + tombstone-recreate; RESTRICT documented as guarding only the physical-purge/GC path (the live guard is Phase 2's ops-layer check); recreate-after-tombstone for `tag.path` / `edge` / `reading_post` / `post_tag` / `block_tag`; CHECKs; FK probes on all 19 FK columns; lexicographic `(position, id)` ordering incl. tie stability.
4. Cascade triggers (block / container-chain / reading / tag), transition-guarded NULL→value, children stamped with the parent's exact `deleted_at` (restoreBlock's cascade-victim identification); outbox capture on INSERT+UPDATE of every synced table with `INSERT OR REPLACE` coalescing and `_sync_applying` suppression — cascades verified to still fire during apply.
5. 13 record types (pure values — IDs/timestamps minted by the Phase 2 ops layer via `@Dependency(\.uuid)`/`(\.date)`, never by records), shared `VariorumRecord` protocol (snake_case mapping; canonical ISO-8601 millisecond timestamps, byte-identical to the triggers' `strftime('%Y-%m-%dT%H:%M:%fZ')`), associations per plan.

**Finding (spec corrected, load-bearing):** `_sync_applying` cannot be a temp table — SQLite resolves unqualified names inside a main-schema trigger *in the trigger's own schema*, so the outbox triggers' `WHEN NOT EXISTS (SELECT 1 FROM _sync_applying)` can never see `temp._sync_applying`. It shipped as a **permanent local-only table, normally empty**, with the flag row written inside the apply transaction (rollback unwinds it). SyncSpec §3 and AppSpec §7 updated in commit `95d2aef`; author should skim that diff.

**Small deltas from the plan (all noted in code):**
- Enums additionally include `ReadingKind` and `SortDirection` (typed columns need them); `reading.profile` and `edge.origin_op` deliberately stay strings (un-CHECKed vocabularies).
- Records conform to `PersistableRecord` (which refines the plan's `MutablePersistableRecord`) — value types with string PKs need no post-insert mutation.
- `sync_outbox.queued_at` is written by trigger with SQLite's clock: the one timestamp not from `@Dependency(\.date)` — local-only bookkeeping, never domain or ordering data (documented in Triggers.swift).

**Deferred/notes for Phase 2 (nothing new for KnownIssues):** tag *subtree* deletion is an operations-layer loop (triggers only tombstone a tag's applications); the deleteVariant/chosen-variant live guard is ops-layer (RESTRICT never fires under soft-delete); GRDB 7 date strategies are per-column *functions* (`databaseDateEncodingStrategy(for:)`) — the static-var form silently no-ops.

**Review addendum (2026-07-05, author-directed fixes applied):** a post-phase self-review found: (1) the **Phase 5 push-loop trap** — a bare local `sync_version` bump after a successful push re-enqueues the row via the outbox trigger; SyncSpec §4 now mandates the bump run in apply mode, the Phase 5 verification row covers it, and `TriggerTests.syncVersionBumpMustRunSuppressedOrItReEnqueues` documents both halves; (2) an AppSpec §14 inconsistency (a claimed variant→commit_point cascade that cannot exist — no `deleted_at` on `commit_point`) — spec corrected; (3) two probe tests promoted into `TriggerTests` (many-block container cascade; value→value re-tombstone doesn't re-cascade) plus a `queued_at` format assertion; (4) `Container.entryDate` format documented, `AppDatabase.liveValue` failure UX parked in KnownIssues (owned by Phase 7); (5) the trigger-smell protocol written into OverallModel §9 + the Phase 2 plan's Risks. **Baseline is now 40 tests green.**
