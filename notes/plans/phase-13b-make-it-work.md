# Phase 13b — Make It Work (usability & interaction hardening)

**Status:** ACTIVE — Stage 1b underway (Stage 0 complete + ratified batch 17; Stage 1a COMPLETE — closeout below; started 2026-07-20).
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

### Stage 0 — the audits (read-only; COMPLETE — findings + (c) inventory below)

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

### Stage 1 — the interaction-layer consolidation (GATE PASSED 2026-07-20, batch 17; subdivided 1a/1b)

The author ratified all Stage 0 verdicts + the backlog verbatim, with two
riders now binding: **R118 TAKES PARITY** — Takes is the main editing view;
for every editing capability Takes offers it natively or via fire-and-DO
move-and-execute; Write is never the privileged surface — and **R119
REBUILD EMPOWERMENT** — if implementation fights test churn or debt, the
implementer may exceed a KEEP verdict (recorded, en-masse review later);
PROVISIONAL-and-continue governs every mid-stage ambiguity. Stage 1 runs
as TWO fresh implementer sessions (the context-degradation rule), one
review ladder over the combined diff after 1b.

**Stage 1a — the surface + authority consolidation (T2 + its T3 slice).**
Full brief below ("Stage 1a execution brief").

**Stage 1b — the capability registry (T1 + its T3 slice + the T4 memos).**
Full brief below ("Stage 1b execution brief") — finalized 2026-07-20 at
1a's closeout, per the just-in-time rule.

## Stage 1a execution brief (self-contained — read this + the constitution + the two Stage 0 dossiers; nothing else assumed)

**Goal:** retire the pane-text/liveness bug class and the text-surface
duplication at their source. No new features; behavior parity everywhere
except the named bug fixes.

**Architect precision on P-3 (binding):** the app deliberately keeps TWO
surface kinds. (i) The FULL-DOCUMENT editor — `EditorTextView` +
`BlockRangeIndex` + crystallization/reconciler, Write's multi-block
editor. KEEP; do NOT absorb it into the pane surface — its identity
machinery is the app's riskiest, best-tested code (AppSpec §15 risk 1).
(ii) The PANE surface — ONE new TK2 component (read + live modes)
replacing `TakePaneView`, `ReadPostView`'s view core, and the takes
article cell rendering: one width-gated measurement brain, one RENDERED
canary, shared focus plumbing. Both kinds consult the one authority and
the one autosave.

**Deliverables:**
1. **`PaneTextAuthority`** (new; pure Swift, unit-tested): THE answer to
   "what text does pane P show, and is it live" over (pane identity,
   focus state, live-buffer map, store projection, catch-up state) —
   absorbing the semantics of today's four moving parts (`liveBuffers`,
   `resolvedTake`, `deferredProjection`, `projectionCaughtUp`, spread 23
   refs / 5 files). Invariants as code: exactly one live pane per
   context; the live pane is buffer-authoritative; read panes are
   projection-authoritative once caught up; a read pane mirroring a
   variant with a live buffer never renders staler text than that
   buffer.
2. **The pane surface component** per the P-3 precision, adopted by every
   take pane (all four fan styles), the read tier, and the article cell.
   Fixes **N2** (the take-pane canary today writes `canaryMessage` that
   NOTHING renders — `TakePaneView.swift:131–145`; the unified surface
   renders fallback status everywhere, red-on-old pin) and the
   **stack-style liveness bypass** (`TakesBoardView.swift:672–674` feeds
   panes `take.workingText` directly — the frozen-article class still
   live in one style; route through the authority, pin per the batch-14
   `TakesArticleRenderTests` pattern extended to the stack style).
3. **Autosave consolidation (N3):** ONE `AutosaveCoordinator` per
   open-post context (today Editor/Takes/BlockTOC each mint their own —
   `EditorViewModel.swift:37`, `TakesViewModel.swift:36`,
   `BlockTOCView.swift:33` — and two can run concurrently over one
   post). Own it at the post-session scope, inject it everywhere;
   red-on-old pin (single-instance assertion that fails on the old
   shape). Do not break the mobile target's use of the shared class.
4. **The T3 slice:** extract the buffer/projection/text-authority
   concerns from `EditorViewModel` (2,994 lines) into the new
   components; it shrinks accordingly. Command routing stays put — that
   is 1b's slice.
5. **The randomized BOARD SOAK** (P-7): seeded action sequences over the
   real mounted board (type, choose, expand/collapse, branch, adopt,
   style-switch, mode-switch), invariants checked after EVERY action:
   one live ring; the article cell mirrors the chosen take's buffer;
   realized pane heights match their text at real width; empty takes
   render the kept line. Non-vacuity enforced per seed.

**Tests:** every existing pin migrates GREEN (`TakePaneMeasureTests`,
`TakesArticleRenderTests`, the board tests, ReadTier tests); every fixed
bug class red-on-old (behavioral-revert verified); zero-test views gain
focused coverage as they are touched (`PostDetailView`,
`WriteTakesPanel` at minimum); full Mac + core suites green at close.

**Constraints:** `Sources/VariorumCore` UNTOUCHED (no ops/schema changes
in 1a; `Sync/` untouched a fortiori). P1–P3 hold (invalidation ∝
realized rows; ONE live editor; virtualization intact). TK2 discipline
per TEXTKIT2_NOTES §4 (explicit TK2 opt-in, no TK1 APIs, canary armed —
and now rendered). No new dependencies. Seal/refusal semantics
unchanged. Chrome rules stand (VoiceControls vocabulary; fixedSize ⇒
lineLimit; overlays never rendering attributes).

**Process:** PROVISIONAL-and-continue per R119 — every judgment call
recorded in the closeout for the author's en-masse walk; commits in
logical chunks with the standing trailer convention; end by writing the
"Stage 1a closeout" section in this file (what moved where, counts,
deviations, judgment calls, the refined 1b brief inputs) and refreshing
`/Applications/Variorum.app` from Release per the standing convention.

**Environment traps (recorded across sittings; honor them):** piped
`xcodebuild … | tail` masks exit codes — check `PIPESTATUS` or avoid
piping; run `xcodebuild test` from `App/Variorum/` (repo root silently
finds no scheme; grep-empty ≠ green — confirm the "Test run with N
tests" line); `-only-testing:` with a wrong suite name = vacuous SUCCESS
on zero tests; a live app instance fails the Mac test runner — before
your FIRST build/test, check `pgrep -fl Variorum`: a leftover
DerivedData/Debug instance from the Stage 0 app-drive may be quit (by
pid, after verifying its path is DerivedData/…/Debug) ONCE
`notes/plans/phase-13b-stage0-app-drive.md` exists (before that file
exists the app-drive session may still be driving it — do pure-Swift
work first and re-check); NEVER quit or kill any `/Applications/
Variorum.app` instance (the author's real store); never `git checkout`
over uncommitted work; mobile sims are the 26.2-runtime devices.

## Stage 1b execution brief (self-contained — read this + the constitution + the Stage 0 dossiers + the Stage 1a closeout; nothing else assumed)

**Goal:** the capability registry + fire-and-DO everywhere. The confusion
class (R112) dies structurally; R118 Takes parity becomes enforced fact.

**Deliverables:**

1. **The registry** (pure model + data; a shared layer beside `Surface/`,
   not a feature module): every user-facing act declared ONCE — id + verb
   in the app's own vocabulary; scope (block / take / post / book / app);
   availability as a pure function of (mode, focus/caret/selection
   context, post state); doors (menu bar / context menu / bottom bar /
   shortcut / ⌘K palette); refusal copy sourced from the operations
   layer's real refusals, never invented. **The R118 parity table is part
   of the declaration:** every editing capability is available in Takes
   natively or via move-and-execute; Write is never privileged.
2. **The registry walk** (the P-1 test): every declared door renders
   where declared; every rendered door is declared (locate surfaces via
   1a's pane identity scheme `pane:role|variantID` — roles `article`,
   `card`, `mini`, `panel`, `toc`, `cell`, `tutorial`); no act is
   unavailable in EVERY mode; the parity assertions.
3. **Fire-and-DO rewiring (P-2):** EditorCommands, both bottom bars, the
   take-card context menu (AD-4's stock Cut/Copy/Fonts replaced with
   registry-driven Variorum vocabulary), and the ⌘K palette (its
   claimed-but-missing takes/structural/export commands) all render and
   route through the registry. Mode-switch choreography designed ONCE and
   reused: an act native to another mode switches visibly, executes, and
   leaves the user somewhere sensible. Cross-mode text safety rides the
   single per-post `AutosaveCoordinator` (1a's guarantee — leaving and
   arriving surfaces serialize on one instance; the soak's remount
   exercises it).
4. **The named cells fixed, each red-on-old:** **D3** (the structural
   four + add-block-at-end reachable from Takes;
   `speakStructuralGesturesLiveInWrite` DIES with the rewiring — it is
   not reworded); **N4** (⌥⌘Z reports through a mode-independent status
   surface, never into nil); **N5** (⌘S acts wherever advertised — in
   Takes/Lenses it commits the focused/chosen take through the
   authority; where genuinely no target, a real spoken refusal);
   **N9/AD-17** (the quick-entry landing: typing in Takes goes somewhere
   — `authority.focus` on the first slot's article pane, the 1a input's
   one-call path); **AD-14** (ONE refusal/status presentation:
   consistent copy, placement, and auto-dismiss policy); and the
   matrix's **enabled-menu-items-posting-into-the-void** class (menu
   enablement itself derives from the registry).
5. **P-4 discipline:** the four hand-kept `TakesCommand` switches
   (EditorView / TakesBoardView / LensesBoardView / CanvasView) are
   absorbed by registry routing; `variorumSwitchMode`'s
   6-poster/1-conditional-observer shape is replaced by composed routing
   (a notification may survive as an announcement only — no decision
   rides it, and nothing is silently dropped when no PostDetailView is
   mounted).
6. **The T3 slice:** command routing + gesture dispatch (the ~1,200-line
   band the 1a closeout mapped) moves out of `EditorViewModel` into the
   registry layer. The W-ceremony machinery moves only if routing
   extraction forces it; crystallization untouched; the projection
   executors stay (their slice is post-ladder, per the 1a call).
7. **The T4 memos (PLAIN LANGUAGE, R120)** as two standalone files the
   author will read at the end checkpoint —
   `notes/plans/phase-13b-memo-w-ceremony.md` and
   `notes/plans/phase-13b-memo-merge.md`. THE W CEREMONY: what it is in
   the app's own words; its real doors, Takes-first per R118; when the
   sheet appears; the edge cases enumerated (locked takes, sealed posts,
   unmarked takes, undo); how a fan-first writer DISCOVERS it (Helper +
   tutorial name it). MERGE: the everyday gesture in plain words; the
   N-ary chain recap; what happens to fans when blocks merge and how the
   app says it; cross-mode reachability; edge cases (sealed, locked,
   empty blocks, undo). The ARCHITECT approves the memos (self-executing
   per R120 — no author gate); build in THIS stage exactly the
   reachability/door halves the registry work carries naturally; deeper
   behavior changes are Stage 3's, referenced from the memos.
8. **Optional if trivial under the registry** (else record for Stage 3):
   keyboard paging for 1a's paged rail (⌘←/→ — one registry act per the
   1a input, no view surgery).

**Tests:** the registry walk + parity pins; every fixed cell red-on-old
(behavioral-revert verified); zero-test views gain coverage as touched
(`SidebarView`, `RootView` at minimum); full Mac + core suites green at
close. Baselines now: **Mac 455/89 · core 747/90**.

**Constraints:** `Sources/VariorumCore` untouched; P1–P3; TK2 discipline;
VoiceControls vocabulary; seal semantics unchanged. Parity nuance: 1b
deliberately CHANGES user-visible behavior where Stage 0 documented
broken cells — doors that act now, lectures that die; that is the
mandate. Everything else stays parity.

**Process:** the R119/R120/R121 posture (choose, record, continue);
commits in logical chunks with the standing trailer; the "Stage 1b
closeout" section in this file (judgment calls for the walk, memo
pointers, inputs for the ladder + the Stage 2 brief-writer);
`/Applications` refresh at close. **Environment traps:** ALL of the 1a
brief's, PLUS the two 1a discoveries: `NSHostingView.rootView`
replacement keeps the old `@State` — use a fresh hosting view / `.id`
for faithful remounts; `-only-testing:` with a Swift Testing FUNCTION
name = vacuous success at zero tests — filter at suite level and confirm
the "Test run with N tests" line.

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

## The end checkpoint (R121 — replaces per-stage author gates)

After the Stage 0 ratification (done, batch 17), the author gates NOTHING
until Stage 3 completes — her call ("it's sometimes hard for me to give an
opinion with existing bugs still present"). Stages run continuously:
1a → 1b → the Stage 1 ladder → Stage 2 (tutorial) + its ladder → Stage 3
themed batches. The cold-review ladders and the standing hard stops
(invariants, schema-meaning changes, new dependencies, credentials,
deleting her content, origin pushes) are unchanged. THE ONE CHECKPOINT at
the end bundles: the en-masse walk of every recorded judgment call /
PROVISIONAL from all stages; the T4 memos (self-executing per R120, now
reviewed); the TUTORIAL WALK — Stage 2's guided post seeded in the REAL
store (empty by her declaration, batch 17) so she experiences the finished
flows directly; a fresh screenshot tour of every surface; and the standing
asks A1–A3. Her reactions become new sitting entries; any resulting fix
round is the phase's tail.

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
| D1 | Book card collapse no-ops on the focused post (`BookView.swift:545` force-expand disjunct; traced batch 15, confirmed by both audits) | → T6 |
| D2 | Margin grid shifts the post left; suspicious inter-block vertical gaps; spacing pass | two candidate mechanisms traced by both audits → T7 (trace-before-fix stands) |
| D3 | Takes structural-gesture gap: Make Block silent, Divide redirects (`TakesViewModel.swift:742`, copy factually wrong), no add-block-at-end door in Takes | confirmed → T1 |
| D4 | Capability-confusion theme (buttons/crowdedness/what's-possible) | matrix DELIVERED (~310 cells; ≈40 silent, 4 lecturing, 12 missing) → T1/T7 |
| M1 | MERGE whole-feature design memo (R116) | owed — written during Stage 1, her rulings |
| M2 | W CEREMONY memo + reachability (R116) | reachability ANSWERED: built but unreachable on her real path — memo owed, build rides T4 |
| N1 | Take-archive vanish trap: ⌘⇧A in Takes hides the take with no UI recovery (fans query active-only) | new, Stage 0(b) → T5 |
| N2 | Dead take-pane canary (fallback invisible in take panes) | **RESOLVED 1a** (rendered banner on the unified surface; red-on-old pin) |
| N3 | Triple AutosaveCoordinator; two can run over one post | **RESOLVED 1a** (one per-post coordinator at session scope; identity + clobber pins red-on-old) |
| N4 | ⌥⌘Z executes-then-reports-into-nil outside Write (silent state change) | new, Stage 0(b), spot-verified → T1 |
| N5 | ⌘S advertised in Takes bar, silently no-ops outside Write | new, Stage 0(b), spot-verified → T1 |
| N6 | Take-label setter missing in core; lens-rename face missing | new, Stage 0(b) → T5 |
| N7 | AD-2 fan truncation: "takes · 4" renders 2 cards, no more-door — half the fan unreachable | **RESOLVED 1a** (the rail pages discretely with the ◀ x–y of n ▶ door; red-on-old pin + soak capacity invariant) |
| N8 | AD-8 margin comments clip under the sidebar (invisible at default width); AD-7 margin-grid wash slabs | new, Stage 0(c) → T7 |
| N9 | AD-17 quick-entry lands in Takes where typing does nothing ("just start typing" broken at the landing) | new, Stage 0(c) → 1b (R118 registry case) |
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

## Stage 0 findings — the architect's synthesis (2026-07-20)

**Inputs:** the two audit dossiers beside this file
(`phase-13b-stage0-architecture-survey.md`,
`phase-13b-stage0-capability-matrix.md`; the (c) app-drive inventory follows)
plus the architect's spot-verification pass — EVERY checked claim confirmed:
the take-pane canary writes a message no view ever renders
(`TakePaneView.swift:131–145` — a TK1 fallback in any take pane would be
invisible, while `ReadPostView.swift:57` renders its own); THREE
`AutosaveCoordinator` instantiations (Editor / Takes / BlockTOC — one more
than the survey claimed), so two debounced autosave pipelines can run over
one post with the Write takes panel open; ⌘S optional-chains into a nil
editor outside Write (`EditorCommands.swift:46–51`, never disabled) while
the Takes bar ADVERTISES "commit ⌘S"; ⌥⌘Z EXECUTES the structural undo and
reports into nil outside Write (`EditorCommands.swift:398–413`) — a silent
state change; no take-label setter exists anywhere in core Operations (the
schema column and renderers exist); the W door opens only via
divide-with-caret-in-a-fanned-block (`StructuralGesturePlanner`,
`.divideW` branch) — in Write.

**Headline numbers:** 80 files / ~21.4k lines in the Mac target; 31
@Observable view models; ~431 tests distributed INVERSELY to churn (Editor
~243; the Takes/Lenses layer ~25–40 over the app's highest-sediment ~3.6k
lines; PostDetailView / WriteTakesPanel / SidebarView / RootView: zero).
~310 capability cells audited: ≈40 silent key/surface combinations, 4
lecture-and-refuse doors (+2 borderline), 12 missing-door findings (2 of
them operation-level). Notification bus: 4 custom names, 12 post sites, 8
observers; `variorumSwitchMode` has 6 posters and ONE conditional observer
— mode switches are silently dropped when no PostDetailView is mounted.
Command routing runs through THREE regimes (editor-router calls /
notification broadcasts / direct actions); every bad cell is one of
ungated-call-into-nil, gated-to-grey dead key, or
broadcast-without-listener — precisely the classes P-1's registry retires.
A FOURTH text path exists: Compare/Outline/Canvas/ReadingFlow render prose
via SwiftUI `Text`, outside the typography brain entirely.

**M2 ANSWERED — the W ceremony:** fully built (`DivideWSheet`,
`EditorViewModel` ~1983–2109) and UNREACHABLE on the author's real path.
Its only trigger is divide-with-caret-in-a-fanned-block in Write; in Takes
(the default mode, R79) the Divide button lectures with FACTUALLY WRONG
copy (claims selection-based; divide is caret-based), ⌘⇧D is a dead key,
and nothing in the app — helper, tutorial, menus — names the ceremony's
existence. Her R116 instinct is verified verbatim: a feature patched into
half-existence. The memo (T4) designs its real doors; the registry carries
them.

### Verdicts (keep / consolidate / rebuild)

| Component | Verdict |
|---|---|
| Live editor pipeline (BlockRangeIndex, crystallization, reconciler, TK2 wrapper) | **KEEP the machinery; DECOMPOSE `EditorViewModel`** (2,994 lines, 10+ concerns — the app's real god object). "The core needs work" lands as decomposition + becoming the ONE live mode of the unified surface — NOT an identity-machinery rewrite. |
| Takes/Lenses interaction layer | **REBUILD IN PLACE** on the new architecture (PaneTextAuthority + registry + decomposed VMs). Highest sediment, worst coverage-to-churn, both recent bug classes lived here — and one frozen-article variant is STILL LIVE: the stack style feeds panes `take.workingText` directly, bypassing liveBuffers (`TakesBoardView.swift:672–674`). |
| Text surfaces (3 TK2 wrappers + the 4th SwiftUI-Text prose path) | **CONSOLIDATE to ONE surface family** (P-3): one measurement brain, one rendered canary, live/read as modes. Fixes the dead take-pane canary and the three divergent re-measure triggers as a class; the Text path gets absorbed or explicitly chartered for non-prose micro-text only. |
| Command routing (EditorCommands + notifications + bars + palette) | **REBUILD as the capability registry** (P-1/P-2). Three regimes become one; silent doors, dead keys, lectures, unheard broadcasts, and palette gaps retire structurally. |
| Autosave | **CONSOLIDATE to one coordinator per open post** (three per-VM instantiations today). |
| BookView | **KEEP + targeted fixes** (D1; fold `BookFocusState` — a third focus authority — into the one focus model). |
| Canvas | **KEEP + small fixes** (the one live unguarded b6dae25-class fixedSize, `CanvasView.swift:318–325`; stop calling `TakesViewModel.message(for:)` cross-feature). |
| Shelf / Library / Pool / Tags / Readings / Timeline / References / Export / Import / Settings / Help | **KEEP** (small, clean, read through Queries). |
| Core Operations | **ADD two small ops/faces:** a take-label setter (column + renderers exist, no setter); a lens-rename face (op exists, no door). |

### The ranked themed backlog (the ratification ask)

| # | Theme | Stage |
|---|-------|-------|
| T1 | **Capability registry + fire-and-DO rewiring** — kills the silent-⌘S class, dead keys, lecturing doors, unheard broadcasts, the ⌥⌘Z silent state change, the mode-switch drop, the palette gaps, and D3 (incl. the add-block-at-end door in Takes) | 1 |
| T2 | **One text surface + PaneTextAuthority + autosave consolidation** — kills the frozen/clipped classes (incl. the live stack-style instance), the dead canary, the triple measurement brains, the dual-autosave hazard; the randomized BOARD SOAK lands here | 1 |
| T3 | **EditorViewModel decomposition** (P-9; enabling work for T1/T2) | 1 |
| T4 | **The W + merge design memos** (paper, written during Stage 1 in PLAIN LANGUAGE; SELF-EXECUTING per R120 — builds proceed on the architect-approved memo, her review at the end checkpoint) → their builds ride the registry | memos: 1 · builds: 3 |
| T5 | **Takes lifecycle completeness** — delete/lock/unarchive faces; archived-takes visibility (today ⌘⇧A makes a take VANISH with no UI way back — the fans query is active-only); take-label op + face; lens-rename face | 3 |
| T6 | **Book view** — D1, focus unification, collapse-all correctness | 3 |
| T7 | **Geometry/spacing** — D2 (two traced candidates from both audits: the centered article+rail unit widening the measure and shifting prose left ~rail/2 — `TakesBoardView.swift:315–319` + `PostDetailView.swift:70–75` reading the same UserDefaults key two ways; `fanToggleRow` rendering above every block incl. unfanned); the crowdedness pass | 3 |
| T8 | **The tutorial spine** (R113) — after T1/T2 make every flow wire-able | 2 |
| — | Looks-polish LAST (R111) | tail |

**Stage 1 scope = T1 + T2 + T3 (+ the T4 memos on paper).**
**Gate:** the author ratifies these verdicts + this backlog before Stage 1
builds. The (c) app-drive inventory refines T5–T7's contents but is not
expected to move the verdicts.

### Stage 0(c) — the app-drive inventory (LANDED 2026-07-20)

Dossier: `phase-13b-stage0-app-drive.md`; 50 window-targeted captures in
`phase-13b-stage0-screens/` (~29 MB, deliberately UNTRACKED — local
evidence referenced by path; gitignored). The drive ran against the DEV
instance (pid- and store-verified) via direct accessibility actions +
pid-scoped keyboard events — notably while the login session was
SCREEN-LOCKED, which blocked real mouse clicks; the take-focus-dependent
checks (completing an archive, the D1 body-click variant, live-editor
mounting) remain for a later unlocked drive and fold into the ordinary
Stage 3 verification drives (no TCC change needed). **22 defects
(AD-1…AD-22) logged; 9 matrix worst-cells confirmed live; verdicts
UNMOVED, as predicted.** Routing of the genuinely new finds:

- **AD-2 — fan truncation (the worst new discovery):** "takes · 4"
  renders exactly 2 cards — no pager, no more-door; half the fan is
  unreachable. IN-TERRITORY for the running Stage 1a build → flagged to
  the implementer mid-flight with the soak invariant "every active take
  renders a card or an explicit more-door" (directive mirrored here per
  the delivery-verification rule).
- **AD-7** (margin-grid cells balloon into ~2/3-empty wash slabs — the
  likely mechanism behind her "suspicious vertical gaps") + **AD-8**
  (margin comments clip UNDER the sidebar — entirely invisible at the
  default window width) → **T7**.
- **AD-17** (quick-entry mints a post then lands in Takes where typing
  does nothing — "just start typing" broken at the landing; a concrete
  R118 registry case) + **AD-14** (refusal quality inconsistent; refusal
  lines never auto-dismiss) + **AD-4** (stock Cut/Copy/Fonts right-click
  on take cards, zero Variorum vocabulary; archived takes have no
  visible road back) → **1b / T5**.

**INCIDENT (architect-verified):** the author's real-store /Applications
instance exited during the audit window — a CLEAN exit (no crash report
in DiagnosticReports); the drive's events were pid-scoped to the dev
instance throughout; the store is WAL-safe; she relaunches whenever.
Dev-store mutations for re-seed awareness: one branched take on "the
glass city dream", one scratch post "stage0 audit scratch post".

## Stage closeouts

*(one section per stage, written before that stage's session ends)*

## Stage 1a closeout (2026-07-20, fresh implementer session — COMPLETE)

**Counts:** Mac app **455 tests / 89 suites** green (was 431/81 — +24
tests, +8 suites) · core **747/90** green and byte-untouched (the
constraint held: zero `Sources/VariorumCore` changes) · the mobile
target builds clean (its `AutosaveCoordinator` single-owner API kept;
its own suite untouched). `/Applications/Variorum.app` refreshed from
Release. Commits `00cc802` → this one, in five logical chunks.

### What moved where (old → new)

| Old | New |
|---|---|
| `TakesViewModel.liveBuffers` / `focusedPane` / `resolvedTake` fall-through / `projectionCaughtUp` (the four moving parts, 23 refs / 5 files) | **`Surface/PaneTextAuthority.swift`** — pure, `nonisolated`, unit-tested (9 tests); the VM stores ONE observed authority value and forwards (`liveBuffers`/`focusedPane` are computed forwards, so every pin and call site reads unchanged; `PaneKey` moved in, typealias kept) |
| `TakePaneView.swift` (deleted) + `ReadPostTextView` class + the take-pane/read-tier/inline measurement brains (3 private copies) | **`Surface/PaneSurface.swift`** — `PaneSurfaceView` (read+live modes, RENDERED canary, voice styling, the pane identity `pane:role\|variantID` on the NSView identifier) + `PaneTextView` (one text-view class; `ReadPostTextView` is now a typealias) + `PaneMeasurement` (the ONE height brain — the read tier and inline editor call it; each keeps its own re-measure TRIGGER by need, width-hook vs storage-edit, but the formula is one) |
| The read tier's `frameDidChangeNotification` width trigger | the shared width-gated `layout()` hook (the batch-12 proven mechanism, now every pane's) |
| Per-VM `AutosaveCoordinator` mints (Editor:37 / Takes:36 / TOC:33) + per-surface quitFinalize registrations | **`AppSession.autosave(forPost:)`** — one coordinator per open post, session-cached, registered with the quit door ONCE at creation; `AutosaveCoordinator` gains multicast `observe`/`stopObserving` beside the single-owner closures (mobile-compatible) |
| `EditorViewModel.surfaceTextByVariant` + `wordCountByVariant` + `surfaceMatches` + the applyProjection if-chain | **`Features/Editor/EditorProjectionEngine.swift`** — `EditorSurfaceLedger` (echo map + R11 word-count cache, pure, 4 tests) + `EditorProjectionPolicy` (the pinned precedence: not-loaded ▸ busy ▸ forced ▸ echo ▸ same-sequence ▸ full). EVM executes verdicts and delegates ledger touches |
| `TakesBoardView` `@State pageOffsets` (carousel/slot-split) + the rail's invisible horizontal ScrollViews | model-owned `pageOffsets`/`stepPage` + **the paged rail** (AD-2): whole columns, explicit ◀ x–y of n ▶, only the visible page renders |

### Bug classes closed (every one red-on-old, behavioral-revert verified)

- **Stack-style liveness bypass** (`TakesBoardView:672-674`): cards take
  authority-resolved `text:`; pin extends `TakesArticleRenderTests` to the
  stack style (revert showed the stale store text — RED confirmed).
- **N2 dead canary**: the surface publishes into a rendered banner;
  `PaneSurfaceTests` drives notification → canary → publish → banner
  (both halves RED on the reverted publish wiring). `FallbackCanary`
  gained a static `assertionHandler` test seam (debug stop-the-world made
  the path untestable otherwise — production never touches it).
- **N3 triple autosave**: identity pin (=== across Editor/Takes/TOC on
  one post) + the clobber pin (interleaved surface edits converge to the
  NEWEST text; the reverted shape stored the stale panel text) — both RED
  on the reverted wiring.
- **AD-2 fan truncation** (coordinator addendum, traced in-architecture):
  the rail realized every card and clipped all past `gridCols×220pt` —
  no pager, no affordance. Fixed with the board's own discrete-paging
  grammar; pin RED on the reverted view half (4 rendered where 2 fit);
  the soak carries the capacity invariant permanently.

### The board soak (P-7, `TakesBoardSoakTests`)

Two seeds × 24 actions over the REAL mounted board (focus/type/choose/
expand/expand-all/branch/blank/blank-and-choose/adopt-as-lens/style-
switch across all four styles/page-step + ONE remount), invariants after
EVERY action: ≤1 editable pane (one live ring); every read pane mirrors
the authority's text for its variant; article/stack panes hold measured
height at real width; every realized slot renders its article pane
(R103's kept line; slot-split blooms exempt by design); the AD-2 page
capacity. Non-vacuity by construction + asserted. ~9 s for both seeds.

### Judgment calls / PROVISIONALs (R119 — for the author's en-masse walk)

1. **AD-2's grammar change:** R24's "horizontally-scrolling strip"
   becomes a PAGED strip (the carousel's ratified whole-cards-never-
   halfway grammar). An invisible horizontal scroll in a 220pt rail was
   the defect's mechanism; discrete paging is the board's own idiom. Her
   call if she wants scroll-plus-pager instead.
2. **Authority layering:** the column-kind → pick mapping stays in
   `TakesViewModel` (3 lines); the authority takes the resolved pick.
   Keeps the Surface layer free of Takes feature types (`Surface/` sits
   beside `Theme/` as a shared layer, the sanctioned pattern — not a
   feature module).
3. **TOC exceeded the strict brief:** `BlockTOCViewModel` adopted the
   full authority (buffers + focus), retiring the round-2 NIT-5 accepted
   residual (blurred-pane stale flash). `makeLive` gained the take's ID.
4. **Empty-note condition simplified** (`TakesShared`): `resolved.text`
   already overlays the buffer, so the second clause was redundant —
   `resolved.text.isEmpty` alone now.
5. **Autosave registry lifetime:** session-cached per post, never
   evicted — bounded by posts opened per session; an idle coordinator
   holds a dictionary and no timers. The quitFinalize `isEmpty` pin
   migrated meaning: surfaces can no longer linger in the quit path BY
   CONSTRUCTION (they never register); the post's entry is session-owned
   and clean-flush idempotent.
6. **T3 slice scope (the honest line count):** EVM 2,994 → 2,951 — the
   raw shrink is modest because the extraction (~200 lines of concern)
   was partly offset by the policy switch + documentation. What actually
   moved: the text-authority state and the projection DECISION are now
   pure, named, tested code. The projection EXECUTORS
   (`renderFull`/`applyDifferential`) deliberately stayed: they write
   `index`/`slots`/`tailText` entangled with gestures, caret, badges,
   and scroll anchoring — moving them mid-phase, before the ladder, on
   the app's riskiest tested file, against a behavior-parity mandate,
   was the wrong risk. The natural NEXT slices: command routing (1b's,
   ~1,200 lines of gesture/W machinery) and then the projection
   executors once routing is out.
7. **The stack pin's timing:** asserts inside the 500 ms autosave
   debounce (a long settle would let pre-fix code converge late and
   hollow the pin); revert-verified RED.
8. **Soak interpretations:** "mode-switch" = one mid-script remount with
   a FRESH hosting view (PostDetailView's `.id` identity break,
   reproduced faithfully); "adopt" = save-current-choices-as-lens +
   `adoptLens` (the Takes tab's reachable adopt door).
9. **Coordinator addendum executed:** AD-2 traced to the board's rail
   (my rebuild territory) and fixed here; pid 58603 (dev-store Debug
   leftover) quit after the app-drive file landed, per the brief.

### Deviations from the brief

- The "article cell rendering" replacement kept `TakesCellView` as the
  cell WRAPPER (context menu, empty-note overlay, tint) — its text
  surface is the new component; the wrapper is composition, not a
  duplicate surface.
- The soak's "article mirrors the chosen take's buffer" invariant landed
  as the STRONGER general form (every read pane mirrors the authority).

### Findings worth keeping (harness class)

- `NSHostingView.rootView` replacement KEEPS the old `@State` (same
  structural identity) — a soak-shakedown catch: a "remount" that swaps
  rootView silently drives the old view model. Fresh hosting view (or
  `.id`) is the faithful teardown. Future view-layer harnesses beware.
- `-only-testing:VariorumTests/Suite/testName` with a Swift Testing
  function name matched ZERO tests and reported SUCCESS (the recorded
  vacuous-success trap, confirmed live) — filter at suite level and read
  the "Test run with N tests" line.

### Inputs for the Stage 1b brief-writer

- **The pane identity scheme** (`pane:role|variantID` on every surface's
  NSView identifier) is available to the registry-walk test for locating
  rendered surfaces/doors; roles in use: `article`, `card`, `mini`,
  `panel`, `toc`, `cell`, `tutorial`.
- **Cross-mode text safety now rides ONE coordinator:** fire-and-DO's
  mode-switch choreography can rely on `session.autosave(forPost:)` —
  the leaving surface's pending text and the arriving surface's flushes
  serialize on the same instance (the soak's remount exercises exactly
  this). No per-surface flush ordering to reason about.
- **Command routing observed while extracting:** the four hand-kept
  `TakesCommand` switches remain (EditorView / TakesBoardView /
  LensesBoardView / CanvasView) — untouched here, the registry's to
  absorb; `TakesViewModel.speakStructuralGesturesLiveInWrite` (D3's
  lecture, factually wrong copy) is still the Takes divide door —
  deliberately untouched (no product-behavior changes in 1a); it should
  DIE with 1b's fire-and-DO rewiring, not be reworded.
- **Registry-relevant discovery:** the board's paging is now a MODEL
  door (`stepPage`) — if 1b wants keyboard paging (⌘←/→ through a
  fan's pages), it's one registry act away, no view surgery.
- **N9's cheap half:** with the authority in place, "just start typing"
  in Takes could focus the first slot's article pane
  (`authority.focus`) — the landing affordance is one registry act; no
  new machinery needed.
- **EditorViewModel post-slice shape:** projection/text-authority
  concerns are out; what remains is (a) command routing + gesture
  machinery + the W ceremony (~1,900 lines — 1b's slice boundary
  decides how much moves), (b) crystallization (KEEP verbatim), (c)
  decoration/badge geometry (a later candidate). The `viewText` /
  `programmaticReplace` / `setBlockAttribute` surface plumbing stays
  with the storage owner by design.
