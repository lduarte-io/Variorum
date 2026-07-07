# Phase 11 — Remaining views, export/import — DESIGN BRIEF

> **This is a BRIEF, not the execution plan.** Written 2026-07-06 in the author's
> forward-planning session (Fable); the just-in-time plan is written at **Phase 10's
> closeout** and MUST incorporate it. Pre-answered decisions below are author-ratified.
> **Strong recommendation: subdivide this phase when the plan is written** — the master plan
> explicitly allows adding rows (e.g. 11a/11b). Suggested cut: **11a = views** (side-by-side,
> swap-and-reread, diff, expand-all-fans, book-scrub, outline↔draft, canvas, full pool,
> unplaced-blocks, `version_of`), **11b = export/import + reference panel** (+ the canvas
> schema commit can open whichever sub-phase builds the canvas). One phase of this breadth
> invites a rushed tail.

## Author-ratified decisions this phase implements (2026-07-06 — not reopenable)

1. **Canvas layout persists in a small synced table**, designed at this phase, **own schema
   commit**. Sketch (finalize in the plan, honoring every §6 convention):
   `canvas_layout(id PK, owner_id, container_id → container, block_id → block, x REAL,
   y REAL, created_at, updated_at, deleted_at, sync_version)`, live-unique
   `(container_id, block_id) WHERE deleted_at IS NULL`, cascade-by-trigger from container and
   block, outbox triggers, registry + Postgres mirror DDL additions, repair rule = pure
   duplicate (keep smaller id), position updates = plain metadata CAS (races harmless).
   **This is the first exercise of SyncSpec §12's migration-lockstep rule — follow it to the
   letter and record that it was followed.**
2. **`version_of` gets two doors:** select two posts in the library/folder → "Mark as
   Versions"; and the side-by-side view offers the link when opened on two unlinked posts.
   The minting operation itself (KnownIssues row) lands here: canonical `(min,max)` storage,
   `origin_op='manual'`, undirected semantics per AppSpec §7.
3. **Export shapes (resolves AppSpec §16's open "export shape" design):**
   - **Granularity: posts, readings, AND single blocks** all export as `.md`.
   - **Fan export = one file, labeled sections:** the chosen take renders in place; alternates
     follow under a marked "Alternates for this block" section, each labeled
     (`take: "<label>"`, unlabeled ones numbered). Applies to a fanned block's export and to
     post export with an "include variants" option.
   - **Two-tier sharing ratified:** `.md`/PDF here for humans without the app; the
     full-fidelity "variorum edition" bundle stays at Phase 14; the SQLite file remains the
     lossless whole-library archive; sync remains the author's own multi-device transfer.
   - Exports are **one-way projections** (never re-imported as truth), built on
     `Queries.renderedText` semantics: `"\n\n"` joins, blank takes skip.

## Standing definitions already settled elsewhere (the plan cites, never re-decides)

Book-scrub is **model-driven** (Phase 6 memo: post list is the scrubber's domain; hybrid
jump for landing). Expand-all-fans: fans stay open once expanded + close-all button (§12).
Diff: whitespace normalization optional (§12); inputs from Phase 4's `diffPair`. Outline↔draft
mapping traverses `derived_from` (Phase 4's `derivedBlocks`). Import: drop `.md`/text on
library or pool → `bulkSegments` (KnownIssues row); the file is a one-way source. Unplaced-
blocks utility view: the Phase 4 query, listed plainly.

## Open interpretations the execution plan must answer

1. **Reference-panel drag-out lineage:** AppSpec §7 says a selection dragged from a reference
   "lands as a pool-drag-style copy" — but a reference is not a block, so no `derived_from`
   edge is *possible*. Read it as: the *gesture* is pool-drag-style; the result is ordinary
   bulk text entry (new block(s), no edge). Flag PROVISIONAL; if the author wants provenance,
   that's a product call (a reference-to-block edge type would be a schema change — hers).
2. **Diff granularity** (line vs sentence chunks over the rendered texts) — display choice,
   not stored; pick the cheapest correct one.
3. **Swap-and-reread mechanics** (swap chosen variants temporarily in a view-local projection
   vs actually re-pointing `chosen_variant_id` with easy revert — leaning: view-local; UI
   state is a projection, I3 stays untouched until the author commits the choice).
4. **Canvas scope:** which containers get canvases (pools only, or any post too?) and whether
   canvas shows blocks only or posts-as-cards. (Leaning: pools first — sticky-notes is a pool
   idiom; extending is cheap later.)
5. **PDF path:** attributed-string print/PDF per the KnownIssues row; typographic polish
   explicitly Phase 13.

## Risks

- **Breadth is the phase's main risk** — hence the subdivision recommendation. The tail items
  (reference panel, import) must not be rushed footnotes; they carry sandbox/TCC work
  (security-scoped bookmarks; file-access prompts are author-assist moments).
- **Every view must be a traversal** (OverallModel §9): the moment side-by-side or the canvas
  wants its own data subsystem beyond `canvas_layout`, that's a model finding to surface.
- **The schema commit** (canvas_layout) must precede dependent code and follow the lockstep
  rule — this is the first live schema change under real two-device sync; treat it as the
  rehearsal for every future one.
- **Reference `file_bookmark` stays local-only under sync** (AppSpec §7) — the export code
  and the panel must never leak it into payloads (SyncSpec already excludes it; don't add a
  second path).

## Review foci (for the cold reviewer)

1. canvas_layout: sync-shaped end to end (triggers, registry, mirror, repair, lockstep
   followed) — audit against SyncSpec §3/§6/§7/§12, not against the implementer's summary.
2. Exports are pure projections: no export path writes rows; no second source of truth;
   `.md` shapes match the ratified forms (incl. blank-take skipping and the fan section).
3. `version_of`: canonical storage, both doors emit the same op, dedupe repair still holds.
4. Import: one-way, segments per the effective default, never touches the source file.
5. Each view reads through existing Queries (or new read-only queries with tests) — flag any
   bespoke view-side data machinery at full severity.
6. Swap-and-reread does not mutate `chosen_variant_id` unless the author's explicit
   commit-choice gesture runs (I3 discipline).
