# Phase 13b — Make It Work (usability & interaction hardening)

**Status:** ACTIVE — Stage 0 underway (started 2026-07-20).
**Created:** 2026-07-20, at the taste checkpoint's Sitting 9, batches 15–16
(the governing rulings **R111–R117** are recorded verbatim-faithful in
`notes/plans/phase-13-ui-design.md`, batches 15–16; defects D1–D4 in batch 15).
**Cast (author, 2026-07-20 — R114/R117):** architect/orchestrator **Fable**
(the author-attended session) · implementer **Fable**, a FRESH session per
stage (the ~500k context-degradation rule) · cold reviewer **Fable** (the
standard fresh-reviewer ladder, up to 3 rounds, on every build stage; Stage 0
is read-only and its gate is the author's ratification instead).
**The architect mandate (R117):** the author granted Fable architectural
ownership for this phase — the principles below are BINDING for all 13b work;
deviations get recorded here with reasons, and product-flavored calls remain
hers (the standing author-only list in CLAUDE.md is untouched).

## Why this phase exists

The app's substrate (operations, sync, queries — 747 core tests) is sound and
was never the problem. The Mac frontend's **interaction layer** — which
actions are available where, how the seven post modes compose, how three TK2
text surfaces share buffer/liveness state — was never designed as a whole: it
accreted (Phase 9 wired structural gestures into Write when Write was the only
editing surface; Takes/Lenses arrived in 11a/13 and inherited nothing), and
Sitting 9 then laid fourteen batches of individually-pinned patches on top at
screenshot speed. The result is the author's named class (R112): buttons that
exist but silently do nothing, redirect-lectures instead of acts, missing
doors on basic acts, crowdedness, and "confusion of what is possible and what
is broken." Verdict recorded at batch 15: **selective rebuild of the
interaction layer on audit evidence — not a fresh frontend** (a restart would
discard tested, ratified behavior and re-earn its bugs).

## Architectural principles (the 13b constitution)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

## Stages

### Stage 0 — the audits (read-only; ACTIVE)

No building. Three parts, briefs below:
- **(a) Architecture / tech-debt survey** of the Mac frontend — evidence
  dossier per feature module + the live editor core; verdicts
  (keep / consolidate / rebuild) are the ARCHITECT'S, made from the dossier,
  not the surveyor's.
- **(b) The capability matrix** — every act × every surface: door exists?
  fires? speaks? gated to what? works? — with the W-ceremony reachability
  question answered explicitly (R116).
- **(c) The self-driven bug inventory** — Fable drives the dev-store app
  through the visual loop, walking the flows the author walks, worst matrix
  cells first; every bug logged with a screenshot. The author stops being
  the app's first tester.

**Output:** `phase-13b-stage0-architecture-survey.md`,
`phase-13b-stage0-capability-matrix.md`, the (c) inventory + the architect's
synthesis in this file: per-component verdicts and the ranked themed backlog.
**Gate:** the author ratifies verdicts + backlog before Stage 1 builds.

### Stage 1 — the interaction-layer consolidation

The selective rebuild, scoped by Stage 0's ratified verdicts. Expected core
(subject to Stage 0 evidence): the capability registry + fire-and-DO
rewiring of every door (P-1/P-2); ONE text surface + `PaneTextAuthority`
(P-3) with the existing pins migrated green; `TakesViewModel` decomposition
(P-9); notification discipline (P-4); defects D1–D3 fixed in-architecture
(not as patches), each red-on-old pinned. **Tests:** the registry walk; the
`PaneTextAuthority` unit + invariant suite; the RANDOMIZED BOARD SOAK
(seeded action sequences over the mounted board — type, choose, expand,
branch, adopt, mode-switch — invariants checked per action: one live ring,
article mirrors the chosen buffer, realized heights match text at real
width, empty takes show the kept line); full suites green. **Review:** the
standard ladder.

### Stage 2 — the tutorial spine (R113)

Build the guided tutorial flow touching EVERY functionality (first take,
choose, blank take, divide, extract, make block, merge — and the W where its
memo lands it — comments, tags, lenses, outline, books/chapters, pool,
canvas, export). Every step that doesn't work perfectly is in scope by
definition; a step that trips R116 gets its design memo + her ruling before
its fix. **Output:** the tutorial as the permanent acceptance script
(automated portion + the scripted screenshot walk) — also the
discoverability fix: the tutorial is where the app TELLS the user what's
possible. **Review:** the ladder.

### Stage 3+ — themed batches from the ratified backlog

Themes, not screenshots (candidates from batch 15: crowdedness/buttons;
spacing + the margin-grid shift D2; book view incl. D1; the merge + W
memos' builds; looks-polish LAST per R111). Each batch: build → soak +
pins → screenshot-verify against the app itself → point-by-point report →
ledger update → commit → `/Applications` refresh.

## Hygiene (R114 — binding)

Fresh implementer session per stage, briefed ONLY by this file + the named
docs (self-contained; no reliance on any prior session's context). Every
stage writes a closeout section here before its session ends. Every batch
updates the ledger below. Binding decisions and findings land in repo files
the same turn they happen. Memory updated at every significant state change.
Commits per batch/stage with the standing message convention.

## The running ledger

| # | Item | Status |
|---|------|--------|
| D1 | Book card collapse no-ops on the focused post (`BookView.swift:545` force-expand disjunct; traced batch 15) | open — Stage 1/3 |
| D2 | Margin grid shifts the post left; suspicious inter-block vertical gaps; spacing pass | open — trace first |
| D3 | Takes structural-gesture gap: Make Block silent, Divide redirects (`TakesViewModel.swift:742`), no add-block-at-end door in Takes | open — Stage 1 (P-1/P-2) |
| D4 | Capability-confusion theme (buttons/crowdedness/what's-possible) | Stage 0(b) matrix → backlog |
| M1 | MERGE whole-feature design memo (R116) | owed — Stage 1/2 seam |
| M2 | W CEREMONY whole-feature design memo + reachability finding (R116; she has never seen it) | owed — Stage 0(b) answers reachability first |
| L1 | Mockup gap-list ("anything that truly didn't make it over") | LOW, later per R111 |
| A1 | `//` comment-glyph ratification | hers, once comments used in anger |
| A2 | QUESTIONS #23–#27 + remainder of #28 | hers, standing |
| A3 | Typographic-PDF disposition | hers, standing |

## Stage 0 briefs (self-contained for fresh sessions/agents)

**Brief A — architecture survey (read-only + its own dossier file).**
Survey `App/Variorum/Variorum/` (Features/, app-level composition, Theme/) —
NOT `Sources/VariorumCore` (substrate out of scope; note frontend misuse of
it where seen). Per feature module: files + line counts; covering test files
and test counts; sediment signal (ruling-tagged comment density); which text
surface it uses (`EditorTextView` / `TakePaneView` / `ReadPostView`) and any
private measurement/liveness code; state shape (@Observable VMs, stored
projections) and EVERY NotificationCenter name it posts/observes;
cross-feature calls; hazard patterns (fixedSize-in-chrome, geometry mapping,
focus handling, timer/async races). Special dossier: the LIVE EDITOR CORE
(`EditorTextView`, `EditorDocument`, `BlockRangeIndex`, autosave/
crystallization/reconciler) — its seams with Takes/Lenses/ReadTier and the
four liveness moving parts (`liveBuffers`/`resolvedTake`/
`deferredProjection`/`projectionCaughtUp`). EVIDENCE ONLY with file:line for
every claim — verdicts are the architect's. Write the dossier to
`notes/plans/phase-13b-stage0-architecture-survey.md`.

**Brief B — capability matrix (read-only + its own dossier file).**
Enumerate acts × surfaces. Acts: structural (make block, divide, extract,
merge, the W); block lifecycle (new block at post end, delete, reorder,
move-to-pool, name, callout); takes (first/+take, blank take, choose,
expand, archive/delete take, label, lock, commit/history/restore); lenses
(new column, save, adopt, promote, diverge-here, branch-all); comments
(add/view/edit/delete/restore); tags (post + block); post (rename, seal,
archive/delete/restore, entry date, export, add-to-book,
duplicate-as-version, mark/unmark versions); books (new book, new post in
book, chapters, collapse/expand, finish/extent); pool/blocks-area (mint
scrap, drag-to-draft, ⌥-drag); canvas; quick entries. Surfaces: Write,
Takes, Lenses, Compare, Outline, Blocks (mode), Canvas, Book view, Shelf,
Library, Pool, Blocks area, ⌘K palette, menu bar. Depth priority: the
editing modes (Write/Takes/Lenses) × structural+takes acts get full
does-it-work-end-to-end readings; elsewhere door-exists/gated level
suffices. Per cell: door(s), fires?, speaks on refusal?, gated to what,
works per code reading — file:line evidence. MANDATORY special finding: the
exact user path that opens the W ceremony sheet today, and whether a user
who fans blocks in Takes can reach it without hidden knowledge (R116/M2).
Flag every silent door, every lecture-and-refuse door (R115 violations),
every missing basic door. Write the dossier to
`notes/plans/phase-13b-stage0-capability-matrix.md`.

**Brief C — the app-drive inventory (after B).** Launch the DEV-STORE app
(Debug build — the fenced store by design; NEVER the author's running
`/Applications` instance), walk the flows the author walks — quick entry →
write → make blocks → takes → choose → book → comments → tags — worst
matrix cells first, screencapture each step, log every defect with its
screenshot and a one-line repro. No fixes in Stage 0.

## Stage 0 findings

*(filled by the architect as results land)*

## Stage closeouts

*(one section per stage, written before that stage's session ends)*
