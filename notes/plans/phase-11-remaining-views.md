# Phase 11 — Remaining views, export/import (execution plan)

> Authored 2026-07-12 at Phase 10's closeout per the front-loaded-planning rule,
> FROM `notes/plans/phase-11-brief.md` — the brief's author-ratified decisions
> (canvas_layout; version_of's two doors; the export shapes incl. bulk export;
> block names + the block-TOC) are **binding**; its 2026-07-09 additions are
> scope; its open interpretations are answered in §"Open interpretations,
> answered". **Staffing (CLAUDE.md model policy, author 2026-07-11): implementer
> FABLE · cold reviewer FABLE, same-model flow.** The standing Sync/ rider
> (+ Bridge/ prudence) is satisfied by the assignment; this phase's ONE
> engine-adjacent obligation is the migration-lockstep choreography (Step A1),
> which touches the registry/serializer/mirror-DDL exactly as SyncSpec §12
> prescribes.
>
> **Shape: the brief's subdivision recommendation is ADOPTED inside this plan**
> — Stage A (views) and Stage B (export/import + reference panel), strictly in
> order, each with its own verification gate. The coordinator may formalize
> 11a/11b master-plan rows at kickoff (the table "gains rows rather than
> rewriting history"); the plan works either way. One phase of this breadth
> invites a rushed tail — Stage B is never a footnote.

## Kickoff message (for a fresh session)

> You are starting **Phase 11 of Variorum** — the full traversal set
> (side-by-side multi-variant editing, expand-all-fans, swap-and-reread, diff,
> book-scrub, outline↔draft, canvas, block-TOC + block names, full pool,
> unplaced-blocks, `version_of`) plus export/import and the reference panel.
> **First, verify Phase 10 is closed** (the master plan pointer says Phase 11
> and the Phase 10 closeout paragraph exists). **Second, confirm with the
> coordinator that the KICKOFF ADDENDUM ran**: the author-attended HTML mockup
> spike (2026-07-11 author decision — throwaway mockups of the fan-out
> appearances and the side-by-side view for her to CHOOSE between before you
> build them; informs, never binds). If it hasn't run, Step A3 is blocked on
> it — say so in your first report rather than designing those views on paper.
> Read, in order: `CLAUDE.md`; `notes/plans/phase-11-brief.md` IN FULL
> (ratified decisions binding — including the kickoff addendum block);
> this plan IN FULL; `notes/OverallModel.md`; `notes/AppSpec.md` §7 (the
> reference table; block DDL — `block.name` lands beside it), §9, §12, §14's
> deltas of 2026-07-07 (block-TOC), 2026-07-09 (both — the boundary-fluidity
> package and the elevated side-by-side), and **2026-07-12 (the spacing
> ruling: renderedText's join is now CONDITIONAL — export code inherits it,
> never re-implements it)**; `notes/SyncSpec.md` §3/§6/§7 and **§12 IN FULL**
> (Step A1 is the first live schema change under real two-device production
> sync — the lockstep rehearsal); `notes/TEXTKIT2_NOTES.md` §2/§3 (book-scrub
> and the TOC ride the Phase 6 memo's decisions; NO in-place folding in the
> live editor); `notes/QUESTIONS.md` items **10, 11** (OPEN — settled ONLY by
> asking the author at implementation time; her uncertainty is recorded
> deliberately — never add certainty she doesn't have) and 17 (Phase 10's
> PROVISIONALs — confirm at kickoff whether the checkpoint ratified them;
> the full pool builds on 17(c)); the Phase 10 plan's closeout (the read
> tier/focus-handoff machinery you will reuse; the spacing ruling's
> mechanism); `Sources/VariorumCore/Queries/` and the Phase 10 features under
> `App/Variorum/Variorum/Features/` (Read tier, BookView, Pool — the reuse
> surface). **Baselines — do not re-run at session start: core 562/62 · Mac
> app 311/55 · mobile 11/4** (the Phase 10 closeout's final counts). Remember
> the environment traps: piped xcodebuild masks exit codes; a live app
> instance or stale unsigned DerivedData product blocks the Mac test runner
> (NEVER kill the author's `/Applications/Variorum.app` — report and run
> targeted suites instead); SwiftUI `.task` doesn't fire under the test host
> (drive models by hand; representable lifecycles DO fire); nested run loops
> don't drain the main queue (interleave real awaits when pumping). The
> author DAILY-DRIVES on real auth + the live mirror: the A4 fence stays
> absolute, and Step A1's mirror DDL deploys ONLY through the author-assist
> gate (her paste or her PAT — the 9c precedent), never headless.

**Hard author gates in this phase (stop-and-report, coordinator relays):**
1. **QUESTIONS #10** (must the W always be a full ceremony?) — ask at the
   moment cross-fan bracketing's auto-proceed case is reachable (Step A9).
2. **QUESTIONS #11** (fanned cross-block edit semantics) — ask when the
   fanned case is reachable (Step A9). Where a live answer doesn't settle
   either, her suggested method is BOTH-WAYS TESTING VIA DISTINCT COMMANDS —
   build both, let her use both, decide from use.
3. **Step A1's deploy** (mirror DDL + lockstep) — author-assist, both devices
   updated before any new-schema writes (§12's choreography, to the letter).
4. The reference panel's file-access/TCC prompts (Stage B) — author-assist.

## Open interpretations, answered (ride the checkpoint ratify list)

1. **Reference drag-out lineage: gesture-style copy, NO edge — PROVISIONAL.**
   A reference is not a block, so `derived_from` is impossible without a new
   edge/table class (a schema-level product call — hers, never invented).
   The drag is pool-drag-STYLE (AppSpec §7's wording); the result is ordinary
   bulk text entry. QUESTIONS entry at implementation.
2. **Diff granularity: LINE-based over the two rendered texts** (display
   choice, nothing stored; the cheapest correct form — sentence chunking can
   layer on later). Whitespace-normalization toggle per §12.
3. **Swap-and-reread: view-local projection** (the leaning adopted): the swap
   never touches `chosen_variant_id`; an explicit "keep this take" gesture
   emits `chooseVariant` (I3 discipline — review focus 6 enforces).
4. **Canvas scope: pools first, blocks-as-cards** (the leaning adopted;
   extending to posts later is cheap — the table's shape doesn't change).
   PROVISIONAL.
5. **PDF: the attributed-string print/PDF path** over `renderedText`
   semantics; typographic polish is explicitly Phase 13's.

## Ground rules

- **Every view is a traversal** (OverallModel §9): the moment side-by-side or
  the canvas wants data machinery beyond `canvas_layout`, surface it as a
  model finding — full-severity review item, never a quiet workaround.
- **Exports are one-way projections** on `renderedText` semantics — which,
  since 2026-07-12, means the CONDITIONAL join (`joinRenderedTexts`: `"\n\n"`
  unless the left block ends in a newline) and blank-take skipping. Export
  code CALLS the one join brain; it never re-implements it.
- Schema changes get their own commits BEFORE dependent code; the §12
  choreography order is recorded as it happens (mirror → every client → only
  then new-schema writes; disagreement = refusal to sync).
- Bounded observations everywhere (the Phase 10 probe-and-marker pattern for
  anything corpus-shaped); P3's one-live-editor rule holds in every new view
  (the side-by-side's ratified shape: the live editor MIGRATES between panes).
- The author's deliberately-open items stay open until SHE answers — record
  her words, not paraphrases that add certainty.

## Stage A — the views

### Step A0 — the offline-label fix (KnownIssues row re-owned from 10)
**Files:** `App/Variorum/Shared/SyncStatusViews.swift` + the status source in
`SyncSession`/scheduler surface (classification only — NO engine changes; if
classification demands engine surgery, stop and report per the rider).
**Work:** offline/unreachable (URLError network-down classes) presents as
"Waiting to sync (offline)" — pending/queued, never "SyncError"; real refusals
keep the error face. BOTH platforms (the row's letter).
**Tests:** classification pure-function tests (error → presented state);
the existing A3 offline-keeps-outbox behavior unchanged (no engine deltas).

### Step A1 — THE SCHEMA COMMITS + the lockstep rehearsal (`canvas_layout` + `block.name`)
**Work:** (i) migration `v1_5` — `canvas_layout` exactly per the brief's
sketch honoring every §6 convention (UUID TEXT PK, owner_id, ISO timestamps,
`deleted_at`, `sync_version`, live-unique `(container_id, block_id)`,
cascade-by-trigger from container AND block, outbox triggers) — own commit;
(ii) migration `v1_6` — nullable `block.name` (additive; plain metadata CAS;
no uniqueness, no repair rule) — own commit; (iii) registry + serializer +
`Server/supabase/` mirror DDL additions (+ the 04 RLS posture for the new
table: owner-gated like its peers — verify against the deployed 9c cutover,
don't assume); (iv) **the SyncSpec §12 version-check mechanism ships NOW**
(the spec's letter: it ships with the first post-sync migration that needs
it) — a server-readable schema marker checked at engine-session start,
mismatch ⇒ visible refusal, outbox intact; (v) repair rule: pure duplicate,
keep smaller id (SyncSpec §7 pattern); (vi) `setBlockName` +
`setCanvasPosition`/`removeCanvasPosition` operations; (vii) **the deploy is
an author-assist gate** — mirror first, then BOTH devices update, only then
any new-schema write; the choreography is recorded step-by-step in this
plan's closeout (review focus 1 audits it against §12, not the summary).
**Tests:** migration + trigger + serializer-completeness walks (the A6
pattern — the in-repo mirror-DDL coverage check must swallow the new table);
repair test with the outbox-row assertion; version-check refusal test
(behind ⇒ refuses, outbox intact, cursor unmoved); ops state-transition
tests; convergence scenario over canvas rows (move/move race = metadata CAS).

### Step A2 — `version_of` (the KnownIssues op) + two doors
**Work:** the minting operation (canonical `(min,max)` storage,
`origin_op='manual'`, undirected — AppSpec §7; refuse self-link and dupes at
the ops boundary) + undo inverse; door 1: select two posts in library/folder
→ "Mark as Versions"; door 2: the side-by-side view offers the link on
unlinked posts (lands with A3).
**Tests:** op state transitions (canonical order pinned both input orders);
both doors emit the SAME op; the Phase 5 dedupe repair still green.

### Step A3 — side-by-side multi-variant editing + expand-all-fans (FIRST-CLASS)
**Blocked on the kickoff addendum's mockup choice.**
**Work:** the core-identity view (author, 2026-07-09): a fanned block's takes
side by side (horizontal scroll when many), **every pane rendered read-cheap,
the ONE live editor migrating between panes on click** (ratified — P3
unchanged; the Phase 10 focus-handoff machinery is the reuse surface: seeds,
teardown contract, read-tier panes). Expand-all-fans: fans stay open once
expanded + close-all (§12); side-by-side also composes `text | v1 | v2 |
text` and two-posts-in-columns (the §12 shapes), with the version_of door on
unlinked posts.
**Tests:** exactly-one-live-editor across a randomized pane walk (the Phase
10 pattern); pane handoff mid-dirty-buffer; take edits land in the RIGHT
variant (row-level); fan expansion state is session-only.

### Step A4 — diff + swap-and-reread
**Work:** diff over `Queries.diffPair` inputs (line-granularity, whitespace
toggle); swap-and-reread as a view-local projection swap with an explicit
commit-choice gesture emitting `chooseVariant`.
**Tests:** diff pure-function tests; the I3 pin — swapping NEVER writes
`chosen_variant_id`; the commit gesture writes exactly it.

### Step A5 — book-scrub + outline↔draft
**Work:** book-scrub model-driven (the Phase 6 memo: the post list is the
scrubber's domain; landing via the hybrid jump; page = a post); outline-left/
draft-right over `derivedBlocks` (independent or tracked scroll; connector
polish stays deferred).
**Tests:** scrub landing accuracy (the memo's primitive, pinned at view
level); outline mapping matches the CTE exactly.

### Step A6 — block-TOC + `block.name` faces + block-management affordances
**Work:** the TOC view (one row per block: explicit name else first sentence
DERIVED AT READ TIME via BoundarySnapping — never stored; expand-to-read via
the read tier; one live editor on demand; collapse session-only; jump via the
hybrid primitive; NO in-place folding); naming (`setBlockName` face, in-TOC);
ordinals; block management: delete block (+ the tray's door — restore),
drag-to-reorder (in-TOC), move block to pool.
**Tests:** derived-first-sentence purity (nothing persisted — review focus 7
class); TOC ops emit exactly the Phase 2/3 ops; reorder emits fractional-
index moves; tray restore round-trip through the UI path.

### Step A7 — the canvas (pools first)
**Work:** sticky-notes board over `canvas_layout` (blocks-as-cards, drag =
`setCanvasPosition` metadata CAS; cards render via the read tier); layout
rows tombstone with their block/container (the A1 triggers).
**Tests:** view emits exactly the layout ops; a two-device position race
converges (CAS — either wins, never corruption); cards render gaps
tolerantly.

### Step A8 — the full pool
**Work:** block-tag filtering (the block-tagging faces DEFERRED FROM 10 land
here: apply/remove on blocks — `TagAssignmentSheet`'s block twin), pool-side
structural ops surface (legal since Phase 3), the canvas as the pool's
second face (A7), plus the Phase 10 minimal-pool PROVISIONALs as ratified at
the checkpoint (confirm #17 before building on the sidebar shape).
**Tests:** filter matches `everythingTagged` block semantics; block tag ops
row-level; structural ops in pools through the UI path.

### Step A9 — cross-fan bracketing (COMMITTED scope; the ask-her-live step)
**Work:** the boundary-fluidity package: the cross-block refusal becomes a
guided flow (confirm → adjust neighbor edges → compound divide/divide/merge
under ONE undo entry); single×single cross-block EDITS become merge-then-edit
compounds (a cross-seam delete just works — her ratified direction);
CutPropagation's unique-match auto-proceed prepared as a DEMO.
**THEN STOP at the two hard gates:** ask #10 (W-always-a-ceremony?) and #11
(fanned semantics) with the concrete demos in hand; implement her answers;
where she doesn't settle, build BOTH WAYS AS DISTINCT COMMANDS (her method)
and record that the decision moves to use-evidence.
**Tests:** per her answers — compounds atomic on partial failure (the
withCompound pattern); the soak extended over the new gestures; refusals
that remain still speak.

### Stage A verification gate
Full suites; the randomized gesture soak green over the new surface; sync
convergence spot suite incl. canvas rows + block names crossing the wire;
P1/P3 spot checks (side-by-side pane cost, TOC at 100+ blocks — the TOC is
the within-post-virtualization escape hatch's natural face, measure it);
TEXTKIT2 §5 ritual.

## Stage B — export/import + reference panel

### Step B1 — export (the ratified shapes)
**Work:** `.md` export for posts, readings, AND single blocks; fan export =
one file with the labeled "Alternates for this block" sections (chosen take
in place; `take: "<label>"`, unlabeled numbered); post export's
include-variants option; **bulk export — the whole library as a folder of
plain `.md` in ONE gesture** (one file per post, dated/titled filenames;
readings as optional folder views — layout details this step's, the gesture
and totality ratified); basic PDF via the attributed-string path. All through
`joinRenderedTexts` semantics; save panels are author-visible moments.
**Tests:** shape pins per ratified form (fan sections, blank-take skip, the
2026-07-12 conditional join — spaced posts export their spacing); NO export
path writes rows (review focus 2 — pure projections); bulk export totality
(every live post lands exactly once).

### Step B2 — import (drop-in)
**Work:** drop `.md`/plain text on the library or a pool → new post via
`bulkSegments` (the pipeline exists; spacing preserved per the ruling); the
file is a one-way source, never edited in place.
**Tests:** round-trip sanity (export→import→export byte-stable modulo the
recorded edge-run drops); segmentation per effective default; source file
untouched (mtime/bytes).

### Step B3 — the reference panel
**Work:** per-post references beside the draft (AppSpec §7): Quick Look
generally, PDFKit for PDFs (page memory via `view_state`; text selection
drag-out = interpretation 1's gesture-style copy, PROVISIONAL), read-only
WKWebView or open-externally for URLs; add/remove/reorder + view-state ops
(exist since Phase 2). Security-scoped bookmarks are LOCAL-ONLY under sync
(never in payloads — the serializer already excludes; verify, don't assume);
TCC prompts are author-assist moments.
**Tests:** ops through the UI path; `file_bookmark` never serialized (the
existing exclusion pinned from the panel's path too); view-state round-trip.

### Step B4 — Stage B verification + phase closeout
Full suites; import/export round-trip; the closeout ritual (results, memo,
dispositions; master plan row(s) + pointer → 12; KnownIssues reconciliation —
incl. whether the export/import rows and the offline-label row close; the
author handoff; the Phase 12 plan authored from `phase-12-brief.md`).

## Explicitly out of scope
Typographic PDF (13); the variorum-edition bundle + E2EE (14); EPUB/
annotation/citation (permanently); within-post virtualization BUILD (12
assesses; the TOC only measures); any bridge/sync-engine change beyond A0's
presentation and A1's prescribed choreography (anything more: stop, report).

## Risks
- **Breadth** — the two-stage gate structure exists so Stage B is never a
  rushed footnote; the coordinator may hard-split at kickoff.
- **A1 is the lockstep rehearsal under LIVE production** — a mis-ordered
  deploy desyncs her real devices; the choreography is recorded as executed,
  and the version-check mechanism is the permanent guard it leaves behind.
- **The ask-her-live items** — building past #10/#11 without her answers is
  the forbidden move; the gates are in A9 by construction.
- **Sandbox/TCC** (B3) — author-assist, planned not improvised.

## Review foci (for the cold reviewer — the brief's seven, carried verbatim in intent)
1. canvas_layout sync-shaped end to end (triggers, registry, mirror, repair,
   lockstep FOLLOWED) — audit against SyncSpec §3/§6/§7/§12 directly.
2. Exports are pure projections; shapes match the ratified forms incl. the
   2026-07-12 conditional join.
3. version_of: canonical storage; both doors emit the same op; dedupe holds.
4. Import: one-way; segments per the effective default; source untouched.
5. Every view reads through Queries (new queries tested) — bespoke view-side
   data machinery is full-severity.
6. Swap-and-reread never mutates `chosen_variant_id` without the explicit
   commit gesture (I3).
7. Block-TOC: derivation read-time-only (persisted derivation = full
   severity); collapse unpersisted; `block.name` sync-shaped and rode the
   SAME lockstep event as canvas_layout (verify the order held for BOTH).
8. *(added at plan time)* The ask-her-live gates actually stopped: #10/#11
   answers are recorded in her words before the dependent code exists.

## Closeout
*(Written at phase end.)*
