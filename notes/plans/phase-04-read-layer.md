# Phase 4 — Read layer & perf harness

## Kickoff message (for a fresh session)

> You are starting **Phase 4 of Variorum** — the read side: every view's traversal as a fast, observed query, plus the harness that proves P1. Read, in order: `CLAUDE.md`, `notes/OverallModel.md` §1–5 (the graph, the invariants, P1–P3), `notes/AppSpec.md` §7 (schema; note the read-time rules: chosen-variant fallback, `reading.grouping_tag_id` dangling ⇒ ungrouped), §10 (the two sort stamps), §12 (the view list — each query here feeds one or more of those views), `notes/SyncSpec.md` §5 (the read side must tolerate referenced-but-not-yet-arrived rows: render gaps, never crash), the **Phase 3 closeout** at the bottom of `notes/plans/phase-03-operations-structural.md` (your baseline: the full operations API — lifecycle AND structural — exists; **`swift test` = 224 green — do not re-run at session start** (Phase 3 close on the Air; re-verified 2026-07-06 on the M3, 224 green in 21 suites, after the move to `~/dev/variorum` and the swift-tools-6.2 / macOS-26-target bump)), and this plan. Key context: all queries live in `Sources/VariorumCore/Queries/` as a new module area; they read rows only — never through operations — and must never mutate. The rendered-variant rule is already precise in code (`Operations.renderedVariant` + `renderedLength`'s COALESCE): chosen-if-live-and-active, else default-if-live; reuse the semantics (SQL COALESCE pattern), don't re-derive it differently. Tests use the in-memory `AppDatabase` + the `Fixture` helpers; the perf harness seeds a large corpus once per suite. Work step by step; each step lands with tests; when done, run the closeout ritual (results here, master plan table + pointer, Phase 5 — sync core — plan + kickoff written from `notes/SyncSpec.md`).

**Goal:** a `Queries` module covering every Phase 10–11 view's traversal (post render, reading assembly, lineage, tags, timeline, pool, diff inputs, tray, unplaced blocks), ValueObservation wiring for live projections, and a seeded 10k-block corpus with benchmarks that prove P1/P2. Zero UI, zero new operations, zero sync engine.

**References:** @notes/AppSpec.md §7 (read-time rules), §10 (sort stamps), §12 (views); @notes/OverallModel.md §5 (P1–P3); @notes/SyncSpec.md §5 (missing-row tolerance); Phase 3 closeout (baseline, rendered-variant semantics); `notes/KnownIssuesAndTechDebt.md` (tray semantics entry — owned by THIS phase).

---

## Ground rules

- Queries are read-only: plain `fetch` functions over `Database` plus `ValueObservation` publishers over `AppDatabase`. No business rules beyond the documented read-time fallbacks; anything smelling like a mutation belongs in Operations.
- **Missing-row tolerance is a correctness requirement, not defensive style** (SyncSpec §5): a placement whose block hasn't arrived renders as a gap; a `chosen_variant_id` pointing at nothing falls back; a `grouping_tag_id` pointing at a tombstone means ungrouped. Every query gets at least one missing-row test.
- **P1 is asserted, not hoped:** the benchmark harness measures each core query at two corpus sizes (e.g. 1k and 10k blocks) and asserts near-flat scaling for viewport-shaped reads (post render, timeline page). Absolute timings are machine-noise; *ratios* are the assertion.
- P2: all observation delivery off the main thread is GRDB's default; assert no query API takes a blocking connection on the caller's thread.

## Steps

### Step 1 — Post render (the one everything else stands on)
**Files:** `Sources/VariorumCore/Queries/PostRender.swift`, tests.
**Work:** `renderPost(db, containerID) -> [RenderedBlock]` — walk `container_block` by `(position, id)`, resolve each slot's variant by the read-time rule (chosen live+active → default live → gap), return block id, variant id, text, fan badge data (live active variant count > 1), lock flags. One indexed query (JOINs, no N+1). A `renderedText(db, containerID) -> String` join for export/diff callers (blocks joined by `"\n\n"` — the rendering join that re-creates stored-nothing separators; decided here, document for the author).
**Tests:** order; fallback matrix (NULL/tombstoned/archived chosen); missing block row (gap, no crash); fan badge counts; pool renders the same way.

### Step 2 — Reading assembly
**Files:** `Queries/ReadingAssembly.swift`, tests.
**Work:** `assembleReading(db, readingID) -> [ReadingEntry]` — curated: `reading_post` by `(position, id)`; smart: interpret `query_spec` JSON (define the v1 predicate vocabulary: tag paths, profile, date ranges — smallest useful set, documented); apply `sort_field`/`sort_dir` (manual only for curated); `max_posts` extent; grouping by `grouping_tag_id` subtree (dangling ⇒ ungrouped, the AppSpec §7 rule). Entries carry post id/title/entry_date + section key.
**Tests:** curated order + extent; each sort field; smart predicate basics; grouping incl. dangling tag; tombstoned posts excluded; a post in many readings.

### Step 3 — Lineage & diff inputs
**Files:** `Queries/Lineage.swift`, tests.
**Work:** recursive CTE over `edge` (`derived_from`): `ancestors(of block)`, `descendants(of block)`, depth-bounded; `versionPeers(of post-block?)` — no: `version_of` links blocks; expose `versionOf(blockID)` pairs. Diff inputs: `diffPair(variantA, variantB) -> (String, String)` (just the two buffers; whitespace normalization is a view toggle, Phase 11). Outline mapping: `derivedBlocks(fromOutlineBlock)` is the same descendants query filtered by container.
**Tests:** chains (extract→divide lineage from Phase 3 fixtures), cycles impossible but bounded anyway, dead endpoints filtered (edges may outlive an endpoint — read filters by live blocks, the documented sweep exception).

### Step 4 — Tags, timeline, pool, tray, unplaced
**Files:** `Queries/TagQueries.swift`, `Queries/Timeline.swift`, `Queries/PoolAndTray.swift`, tests.
**Work:** tag subtree by path prefix (live rows); "everything tagged X" = UNION of post_tag/block_tag (AppSpec §7 note); timeline: posts by `entry_date` / `last_major_revision_at` / `last_touched_at` with keyset pagination (viewport-shaped — never OFFSET over the corpus); pool listing (pool container render + block tags); **the tray (owns the KnownIssues entry):** per-post tray = tombstoned blocks with `last_container_id = post` (individually deleted there) — container-cascade victims are `restoreContainer`'s business and excluded by definition; resolve the entry. Unplaced-blocks utility query (live blocks, no live placement) — cheap, lands here even though its view is Phase 11.
**Tests:** subtree correctness after renameTag; UNION dedupe; pagination window math; tray lists exactly the individually-deleted; unplaced population after divideW/merge.

### Step 5 — ValueObservation wiring
**Files:** `Queries/Observations.swift`, tests.
**Work:** `AppDatabase.observePost(containerID)`, `observeReading(readingID)`, `observeLibrary(sort:)` etc. — ValueObservation over the Step 1–4 fetch functions, delivering on a background queue, distinct-until-changed on the projected values. Keep projections value-typed and small (IDs + text), per the store-IDs-not-copies rule… note: rendered text in a projection is a *projection*, allowed — never a second source of truth.
**Tests:** an op through Operations triggers exactly the affected observation; unrelated writes don't fire it (region-scoped observation).

### Step 6 — Corpus & benchmarks (P1/P2 proven)
**Files:** `Tests/VariorumCoreTests/Support/CorpusFactory.swift`, `PerfBenchmarkTests.swift`.
**Work:** seeded deterministic corpus builder (N posts × M blocks, journals + a book-shaped reading, some fans/lineage/tags — through Operations, so it doubles as a scale smoke test); benchmarks: post render, reading assembly first page, timeline page, tag subtree — each at 1k vs 10k blocks, asserting time ratio stays near-flat (define tolerance, e.g. < 3× for 10× corpus); autosave cost flat in post length. Mark the suite `.serialized`/`.tags(.perf)` so ordinary runs stay fast if needed.
**Tests:** the benchmarks are the tests.

### Step 7 — Closeout
Ritual per CLAUDE.md: results here, master plan table + pointer, resolve the tray KnownIssues entry, **write the Phase 5 (sync core) plan + kickoff** from `notes/SyncSpec.md` §10 (mirrored schema, push/pull engine, apply mode, merge matrix, repairs, two-client convergence suites, the empty-outbox-after-push assertion from SyncSpec §4).

## Explicitly out of scope
Any UI (views arrive Phases 10–11). Sync engine (5). Markdown export (11, needs this layer — note the door). Editor integration (7). New operations.

## Risks / things to watch
- **Two sources of rendered-variant truth.** `renderedLength` (Operations) and Step 1's render must agree; extract the COALESCE into one shared SQL fragment or test them against each other explicitly.
- **Smart-reading `query_spec` scope creep** — define the smallest predicate vocabulary the author's stated cases need (tag, profile, date range) and stop; it's JSON, extensible later.
- **Benchmark flakiness on CI-class hardware** — assert ratios with generous tolerance, never absolute ms; keep corpus seeding deterministic (seeded RNG, injected clock).
- **Observation over-firing** — GRDB region tracking is table-grained for raw SQL; use `ValueObservation.tracking` with precise requests where over-firing would wake the whole library on one keystroke (P1's observation-shaped corollary).
- **Missing-row tolerance tests must simulate sync order** (child before parent) with raw SQL fixtures, not ops — ops can't produce those states locally.
