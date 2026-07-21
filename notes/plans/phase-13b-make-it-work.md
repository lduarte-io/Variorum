# Phase 13b — Make It Work (usability & interaction hardening)

**Status:** ACTIVE — **Stage 3 OPEN (execution brief at the end of this
file, authored just-in-time 2026-07-20 by the successor architect session
at the handoff cutover per `phase-13b-orchestrator-handoff.md`; batches
running under R121)**. Stage 2 CLOSED (ladder closed at round 2; both
fix passes complete; stage-level closeout below):
"the field guide" (6 chapters · 21 act-ready lessons) + the hardened
Restore/Open doors (one discovery, confirm-gates-what-dies, the session
latch, the quiet undo-free seeder) + the starved-overlay class ended on
ALL sinks (sweep table b: 5/5 push-on-wire) + the
ring-on-an-unhosted-pane class swept (table a: 30 cells, 15 fixed / 15
provably safe) + the REAL-store seed behind the A1 rail. Counts: **Mac
542/106 · core 747/90 untouched**. Stage 1 CLOSED (ladder closed at
round 2; 1a/1b closeouts + dispositions below; Mac 499/100 at its
close). Stage 0 complete + ratified batch 17; started 2026-07-20.
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

### Stage 2 — the tutorial spine (R113) — full brief in "## Stage 2 execution brief" below (finalized 2026-07-20 at Stage 1 close; where this section's original wording predates R120 — "her ruling before its fix" — the brief supersedes: memos are self-executing)

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
| D3 | Takes structural-gesture gap: Make Block silent, Divide redirects, no add-block-at-end door in Takes | **RESOLVED 1b** (fire-and-DO move-and-execute on all four + the lecture DELETED; native ＋new-block door in Takes/Lenses; red-on-old end-to-end pin) |
| D4 | Capability-confusion theme (buttons/crowdedness/what's-possible) | registry + router LANDED 1b (T1 done — silent/lecture/dead-key classes structurally closed; the walk keeps them closed); crowdedness half stays → T7 |
| M1 | MERGE whole-feature design memo (R116) | **WRITTEN 1b** (`phase-13b-memo-merge.md`, self-executing per R120); doors/reachability built; deeper builds → Stage 3 |
| M2 | W CEREMONY memo + reachability (R116) | **WRITTEN 1b** (`phase-13b-memo-w-ceremony.md`); the ceremony is REACHABLE from Takes (divide fire-and-DOes; Helper dictionary names it) |
| N1 | Take-archive vanish trap: ⌘⇧A in Takes hides the take with no UI recovery (fans query active-only) | new, Stage 0(b) → T5 |
| N2 | Dead take-pane canary (fallback invisible in take panes) | **RESOLVED 1a** (rendered banner on the unified surface; red-on-old pin) |
| N3 | Triple AutosaveCoordinator; two can run over one post | **RESOLVED 1a** (one per-post coordinator at session scope; identity + clobber pins red-on-old) |
| N4 | ⌥⌘Z executes-then-reports-into-nil outside Write (silent state change) | **RESOLVED 1b** (reports through the StatusCenter on every surface; red-on-old pin) |
| N5 | ⌘S advertised in Takes bar, silently no-ops outside Write | **RESOLVED 1b** (routed — the mounted board commits the focused take, pinned over the real board; truly-uncommittable contexts disable the item; red-on-old) |
| N6 | Take-label setter missing in core; lens-rename face missing | **CORE HALF DONE 3B** (`setTakeLabel` shipped on the setBlockName precedent, commit 82c9411 — locked-take allowed PROVISIONAL, archived allowed; `renameLens` confirmed existing since 11a, `Operations+Lens.swift:44` — no core change needed); the FACES (card/bar label doors, Lenses column-header rename, registry rows) stay → T5/3D |
| N7 | AD-2 fan truncation: "takes · 4" renders 2 cards, no more-door — half the fan unreachable | **RESOLVED 1a** (the rail pages discretely with the ◀ x–y of n ▶ door; red-on-old pin + soak capacity invariant) |
| N8 | AD-8 margin comments clip under the sidebar (invisible at default width); AD-7 margin-grid wash slabs | new, Stage 0(c) → T7 |
| N9 | AD-17 quick-entry lands in Takes where typing does nothing | **RESOLVED 1b** (the landing focuses the first slot's article pane; live transitions claim the keyboard; red-on-old) |
| N10 | The deferred T3 slice: EditorViewModel's gesture-execution band + the projection executors move TOGETHER (one seam), plus the TakesViewModel decomposition (890→1,113, P-9 pressure) | **DONE 3C** (`8bebdbd`+`d892056` — EditorSurfaceController 1,295 ln + TakesBoardLayout + TakesChoreographer; zero test edits, Mac 542/106 parity-green; record + architect's annotation below; the ladder reviews the seam) |
| N11 | ⌘K palette has NO keyboard row-stepping: ⏎ always runs the FIRST row (the › marker never moves; ↓/↑ unhandled — `CommandPaletteView` has no selection state); other rows are mouse-only, and act rows shadow same-named posts ("divide"/"merge" lessons unreachable first by ⏎) | **CONFIRMED live-unlocked 3A** (shots 05/06; the shadow bit the drive itself — ⌘K "extract" ⏎ ran the act, shot 41) → 3E (small: selectedIndex + onKeyPress arrows + ⏎ runs selected) |
| N12 | A bare mode switch into Write never focuses the editor — ⌘1-then-type lands nowhere (no caret claim; the N9 landing solved exactly this for Takes; the choreography/clicks focus it, a plain switch doesn't) | **VERIFIED REAL 3A** (unlocked repro, shots 08/09; click-first control types fine) → 3E fix |
| N13 | `reading_section` chapters never reach `exportReading` — `assembleReading.sectionPath` rides the smart-book grouping tag only, so a chaptered book exports with no chapter headings (core-frozen this stage; the export lesson deliberately doesn't promise them) | **CORE DONE 3B** (commit 309adc7 — assembleReading resolves chapters for curated books in the BOOK VIEW's grouped order, `sectionID` additive; exportReading emits chapter headings incl. empty chapters + the `## unfiled` trail; smart-book byte-parity pinned; consumer deltas + citations in the 3B record). Existing export doors show chapters with NO face work; the export-lesson prose upgrade + the stale walk-test comment (`TutorialWalkTests.swift:1366–1370`) → 3D; the Mac-suite re-run over this seam owed at 82c9411 (first unblocked+permitted session) |
| N14 | Doubled fan badge (author, 2026-07-21 03:36, on the 3B build): choose a take in Write's takes panel → "the take button goes up to the top and lays on top of the other take button" (the ⑂ badge); heals on mode-switch remount; "happens in other places too" (screenshot on record). Suspects to TRACE, not assume: overlay add-path idempotence vs the R2-B push-at-wire double-delivery; a collapsed/stale anchor frame rendering at origin | **REPRODUCED + SHARPENED 3A**: precondition = a COLD model (post's first open since launch) — first Write mount collapses ALL badges onto one top anchor (the layered capture, shots 28/29); choose is unrelated; any remount heals; warm models correct; **the class is the whole overlay family** — cold mounts also starve callout frames/💡/seams/handles until any decor-input change (shots 49–51, store JSON verified). Double-delivery suspect looks WRONG; stale-geometry-at-compute + input-equality-gate starving matches all evidence (inferred, not traced) → 3F (trace-before-fix, evidence in the 3A log) |
| N15 | The block bar in book-inline form is cramped — buttons wrap mid-word ("com mit ⌘S", "Divi de"); her suggestion: "it needs 2 rows or something" (screenshot on record) | **EVIDENCE CAPTURED 3A** (shot 66 — every item wraps mid-word at default width) → Stage 3F (T7 crowdedness; adaptive/2-row bar layout) |
| N16 | W ceremony cut-placement (author, same session; (a) RECLASSIFIED by her follow-up): (a) sentence-boundary snapping is ratified, so the "can't move the cut" experience is likely DESIGNED — the trace now VERIFIES the sheet offers EVERY legal interior sentence boundary (a multi-boundary take must be placeable at any of them; only-the-proposed-spot-accepted would still be a bug); (b) design ask — edit multiple takes' cuts without clicking into each; (c) design ask re-affirmed — "i think the scissors should still be movable" (visual drag). Root-cause treatment demanded ("not whack a mole… it can be its own phase if it needs to be") | **(a) VERIFIED GOOD 3A** — a 3-sentence take offered BOTH interior boundaries as cut-at buttons and the ✂ moved on click (shots 33/34); her experience = the one-boundary case + affordance plainness. (b)/(c) → Batch 3H (memo-first per R116/R120) |
| N17 | Merge-after-divide "loses" takes (author, same session): 2-take block → ceremony divide → merge back ⇒ 1 block, 1 take. The stored behavior IS canon (merge joins the visible takes; other takes stay on the released sources in lineage; undo restores — AppSpec §9, OverallModel §7, the merge memo's own section) — but (a) VERIFY the merge toast actually SPOKE in her path, (b) the symmetric round-trip product question (DECISION HERS at the checkpoint), (c) what UI road leads from a merged block to its pre-merge takes | **(a) CLOSED 3A — the toast SPEAKS on both paths** (Takes choreography shot 55; book-inline seam shot 68; mid-block book-inline caret gets the real refusal spoken, 67; likeliest silent-read: the 6 s auto-dismiss). **(c) ANSWERED 3A**: two roads — ⌥⌘Z right away, or Library → ⋯ → Archived & Deleted → "Unplaced blocks" (Place-in-pool door, takes intact; shot 58) — road exists, nothing points at it; the 3H memo addendum weighs naming it in the toast and/or a lineage door on the merged block. (b) → end checkpoint |
| N18 | Extract/make-block boundary snapping rounds the selection START edge to the NEAREST boundary: a suffix selection starting late in the block's final sentence rounds FORWARD to the block end → empty span → "No legal boundary for that here." — while the extract lesson promises "select from anywhere in this paragraph to its end" (3A shots 45/46; the exact-boundary form works, 48). Loud refusal, never silent; but snap and prose disagree. Mechanism inferred, not traced | new, 3A → 3H (snap semantics are the cut-placement memo's territory; either the snap widens suffix spans to the containing sentence's start, or the lesson prose narrows) |
| N19 | Tutorial scraps unreachable + scrap→draft drag has NO geometry: `PoolViewModel.activePool = pools.first` (PoolSection.swift:37) shows only the OLDEST pool in the Blocks area, so "tutorial scraps" renders nowhere on any store with an older pool (dev store live: the corpus "scraps" 30 shadow it) and the pool lesson's drag instruction is unfollowable; and even where listed, NO layout shows a scrap list beside a draft — the `.onDrag` payload and the editor's ⌥-aware `performDragOperation` both exist, orphaned (no second window; canvas-on-a-post renders the scrap tag filter but zero scraps — shots 74–79) | new, 3A → 3D (T5/IA design: multi-pool surfacing + a real drag geometry; the lesson-prose half rides the fix) |
| N20 | Chapter drag-reorder in the book navigator never commits under synthetic drags (drop indicator renders — froze once — store unchanged over two attempts incl. slow spring-load profile); the context-menu Move Up/Down road WORKS (store-verified both directions, 3A shots 69–72) | new, 3A → 3E (needs a human-hand drag before defect status; if real it joins D1's book-view batch) |
| N21 | Chapter dragging in the BOOK VIEW body (author, 2026-07-21 afternoon): "you should be able to drag chapters within the book view, not just in that sidebar, but there are two places where the dots that indicate dragging make me feel like it should be draggable and it isn't" — locate both false-affordance ⠿ spots; dots that don't drag either drag or lose the dots (the R112 honesty rule applied to affordances) | new, author → 3E (joins N20/D1's book batch) |
| N22 | Clicking a collapsed post CARD in the book view should open the post — "clicking on the post should bring you to it, not just the smaller open button (I mean the separated box, not the text that you can actively edit)" | new, author → 3E |
| N23 | Margin-grid CANNOT SCROLL — "a substantial part of the take is inaccessible" | new, author → 3F (T7; joins AD-7/D2) |
| N24 | Tags on a book: free-typed entry — "I want to be able to freely type tags in to a book, not just have to select from already created tags" (type-to-create; taxonomy CRUD exists, the entry face is select-only) | new, author → 3D |
| N25 | Extra/duplicate checkmark on the chosen take in marginalia (margin grid) | new, author → 3F |
| N26 | Block drag-reorder in Write & Takes (author sketch, uncertainty preserved: "for take, you could click and hold on the take button, where for write you could maybe just drag the only block you're typing in? idk") — FIRST verify whether Write's shipped Stage-C drag handles actually reorder (if a shipped face is broken, that's a 3F-class fix); the Takes-side design → Stage 4 stub | new, author → verify next drive / design Stage 4 |
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

## Stage 1b closeout (2026-07-20, fresh implementer session — COMPLETE)

**Counts:** Mac app **485 tests / 96 suites** green (was 455/89 — +30
tests, +7 suites) · core **747/90** green and byte-untouched ·
`VariorumMobile` builds clean. `/Applications/Variorum.app` refreshed
from Release. Commits `184c1b4` → the closeout commit, in three logical
chunks.

### What shipped

**The registry (P-1)** — `App/Variorum/Variorum/Registry/` (a shared
layer beside `Surface/`, ~1,080 lines): `Capability.swift` (the model:
verb in the app's vocabulary, scope, doors, shortcut label, ops-honest
`unavailableNote`, availability as a PURE function of
`CapabilityContext(mode, writeEditorAttached, undoAvailable)`, and the
**R118 parity table in the declaration** — `takesAccess: .native /
.moveAndExecute`, non-nil for every editing capability);
`CapabilityRegistry.swift` (the 33-capability table + door/lookup
helpers + the router's unhandled-note source); `PostMode.swift` (the
seven modes, moved out of PostDetailView — typealias keeps every call
site); `CommandRouter.swift`; `StatusCenter.swift` + `StatusToast.swift`;
`OpsRefusalCopy.swift`; `ShellActions.swift`.

**The router (P-4)** — ALL THREE Stage 0 routing regimes are gone:
- `.variorumTakesCommand`, `.variorumSwitchMode`, and
  `.variorumModeDidChange` are DELETED (`TakesCommands.swift` removed;
  the `TakesCommand` enum lives registry-side, notification-free).
  `.variorumOpenPost` survives deliberately (an announcement with one
  shell observer — no decision rides it; recorded).
- Surfaces register `RoutedCommand` handlers with
  `session.commandRouter` by composition (LIFO stack, token-guarded
  against SwiftUI's appear/disappear ordering); EditorView /
  TakesBoardView / LensesBoardView / CanvasView each register the
  switch they used to hang on `onReceive`. An unhandled dispatch SPEAKS
  the registry's note — the broadcast-into-the-void class is
  structurally impossible.
- Mode truth stays PostDetailView's `@State`; the detail REGISTERS
  (postID + apply-closure) and reports changes with `noteMode`; the
  sidebar rail reads the router's observable mirror (RootView's
  broadcast-derived `postMode` shadow deleted); ⌘1–⌘7 and every
  "switch mode" door call `requestMode` — with no detail mounted it
  speaks instead of vanishing.
- Menu enablement derives from the registry over the router's live
  context (`EditorCommands` 415 → 308 lines; titles come from the
  declared verbs; every action routes through `ShellActions`). The
  enabled-item-posting-into-the-void class is dead both ways: acts
  route where they can act (incl. via choreography), and truly
  inapplicable contexts disable the item (honest grey — recorded
  judgment call #3 below).

**Fire-and-DO (P-2) — the named cells, each red-on-old:**
- **D3 (the lecture DIES):** `speakStructuralGesturesLiveInWrite` is
  DELETED, not reworded. The Takes/Lenses structural doors (bar
  buttons, ⌘⇧D/E/K/M, palette rows) perform the ONE mode-switch
  choreography — `TakesViewModel.moveToWriteAndRun`: flush first (the
  1a per-post coordinator serializes the arriving editor's reads), park
  a `WriteIntent` (target block + the live pane's carried
  caret/selection where the pane shows the CHOSEN take), `requestMode
  (.write)` visibly; the arriving editor consumes the intent at first
  render (`applyFocusSeeds`), lands the selection, runs the gesture —
  which plans against the REAL landed selection, so any refusal is the
  operation's own, spoken. **On a fanned block, divide opens the take
  ceremony — the W is now reachable from her real path (M2's
  reachability half, built).** Merge from Takes lands at the block's
  START (joins upward — the merge memo's call). End-to-end pin: a
  parked divide intent LANDS and the store shows two blocks
  (revert-verified red: one block, silence).
- **D3's third leg:** "＋ new block" — NATIVE in Takes/Lenses
  (`ops.newBlock(text:"", at:.end)`; the minted block's pane takes the
  ring the moment its slot arrives — typing continues instantly);
  doors: the board's end-of-article dashed door, the bar's block menu,
  Block ▸ New Block at End of Post, the palette. In Write: caret-to-end
  (typing there births blocks). Red-on-old: ring handover pin.
- **N4:** `ShellActions.structuralUndo` reports through the
  StatusCenter — visible on EVERY surface (red-on-old: the old
  report-into-nil-editor shape left the center empty).
- **N5:** ⌘S routes `.commit` — the mounted board commits the FOCUSED
  take (pinned over the REAL mounted TakesBoardView: menu action body →
  dispatch → handler → commit_point row; revert-verified red at zero
  rows); where truly nothing commits the item is grey.
- **N9/AD-17:** the Takes board landing focuses the first slot's
  article pane (`landingEnabled`, board-only — the Write panel's
  embedded model never steals it, pinned), and `PaneSurface` CLAIMS the
  keyboard on every read→live transition (window-attach deferred claim
  for panes born live) — "just start typing" is literal, and
  ring-stepping (⌃⌘←/→) types into the right pane too. Cross-mode
  landings ride `TakesLanding.bloom`: Lenses' ⌘⇧T (its lecture died)
  and the Write panel's "Open Takes mode" land bloomed and ringed.
- **AD-14:** `StatusCenter` + `StatusToast` = ONE presentation — the
  root detail overlay, one auto-dismiss policy (6 s, injectable),
  R93-readable (wrapping, selectable, load-bearing lineLimit).
  EditorViewModel/TakesViewModel/CanvasViewModel `statusMessage`s
  forward on set (properties stay — every pin reads unchanged); the
  board-top ChromeNotices, CommitBar's trailing status, and Canvas's
  status line (the live unguarded b6dae25 fixedSize instance) are
  retired. Sheets keep their in-sheet notices (a sheet covers the
  toast; recorded judgment call #6).
- **AD-4:** right-clicking a take card now shows the Variorum
  vocabulary — `PaneTextView.menu(for:)` renders registry-declared
  items ABOVE the standard edit menu (the SwiftUI `.contextMenu` never
  fired inside the NSTextView — that was the mechanism); branch /
  blank / choose / diverge / archive / diff / show-take, with archive
  newly on the cell menu (its ⌘⇧A twin was already Takes-reachable).
- **Write's ⌘⏎ / ⌃⌘←→ lectures died:** both now OPEN the caret
  block's takes panel (the surface where choosing/stepping lives).
- **⌥⌘←/→ keyboard fan paging** (deliverable 8, taken): one paging
  brain — the model owns key/limit (`pageTarget`), the board renders
  from the same answers (`railRowsPerColumn` shared), the menu items
  route `.pageFan`. NOTE the deviation: the brief sketched ⌘←/→; those
  are line-start/end text-editing keys in every live pane — overriding
  them app-wide would break basic typing, so the chord is ⌥⌘←/→
  (recorded judgment call #7).
- **⌘K palette (R15 made true):** 18 registry act rows (the structural
  four, the take family, commit, undo, seal, add-block, import/export,
  seams) beside the shell's navigation rows — same routed bodies as the
  menu; an act that can't work here speaks its honest note.
- **OpsRefusalCopy** moved to the shared layer; Canvas/TOC/Tutorial
  stop reaching into the Takes feature for refusal copy
  (`TakesViewModel.message(for:)` forwards, so every pin reads
  unchanged). Canvas's silent `default: break` handler is gone: step/
  choose speak when no switcher is open; everything else is honestly
  unavailable there (R40 — canvas arranges).
- **Helper dictionary** gains "divide / the take ceremony", "merge",
  "extract / make block" (the memos' discovery half). The Helper's
  taught keys are now TRUE on the default surface — ⌘⇧D/⌘S act in
  Takes.

**The T4 memos (R120, plain language, self-executing):**
`notes/plans/phase-13b-memo-w-ceremony.md` and
`notes/plans/phase-13b-memo-merge.md` — what each act is in the app's
words, the doors (Takes-first per R118), every edge case as a plain
sentence, discovery, and the decided-here-built-later list (Stage 3).
Their reachability/door halves are BUILT this stage.

### The registry walk (P-1's test) + the new pins

`CapabilityRegistryTests` (13): declaration totality; no act unavailable
in every sampled context; **R118 parity** (native ⇒ acts in Takes;
moveAndExecute ⇒ actElsewhere(.write); nothing Write-available is
Takes-unavailable); declared ⇔ rendered on all four door surfaces
(rendered sets pinned as statics on EditorCommands / TakesBottomBar /
CommitBar / EditorViewModel / TakesCellView); every shortcut label has
exactly one key wiring; every routed command has honest fallback copy;
the named D3/N5 cells as availability facts. `CommandRoutingTests` (11):
router mechanics (LIFO, token-guarded stale unregister, fall-through,
speak-on-unhandled), the N4/N5/N9/AD-14/D3/mode-drop/add-block/merge-
upward pins. `PostDetailRoutingTests` mounts the REAL detail shell
(registration + R79 takes-first + a routed request that MOUNTS the
actual Write editor); `SidebarSmokeTests` mounts the rail (zero-test-
view obligation; RootView remains untested — recorded below).

### Red-on-old verifications (every one by behavioral revert, run RED)

Batch A: N4 (undo → old nil-editor reporting: center empty, RED); N5
(⌘S → old `editorRouter.active?` call with the board mounted: zero
commit rows, RED); the mode-drop class (requestMode's speak removed:
RED); AD-14 (the statusMessage didSet forward removed: RED). Batch B:
the landing consumption inert (N9 + cross-mode bloom + add-block ring:
all RED); the choreography replaced with the old lecture (intent never
parked, mode never switched: RED); the intent consumption removed (the
parked divide never lands — the store stays ONE block: RED, the exact
silent-nothing D3 shipped with). All restored; final suites green.
(One artifact: the end-to-end pin originally indexed `after[1]` and
CRASHED the runner during the deliberate red run — hardened to
optional indexing so the pin fails gracefully; the .ips in
DiagnosticReports at 05:08 is that revert run, not a product crash.)

### Judgment calls / PROVISIONALs (R119/R120 — for the author's en-masse walk)

1. **The T3 slice boundary (THE deviation to review).** The brief's
   letter: "command routing + gesture dispatch (~1,200 lines) moves out
   of EditorViewModel into the registry layer." What MOVED: the routing
   TERMINUS — EditorCommands' dispatch/enablement decisions into
   ShellActions + the registry (415→308; every remaining line is menu
   rendering), the four notification switches into router-registered
   handlers, mode routing into CommandRouter. What did NOT move: EVM's
   gesture EXECUTION band (`applyStructural`, the compounds, the W
   state machine) — it writes `index`/`slots`/`textView`/undo through
   `runStructural`, which is fused to the projection executors the 1a
   closeout deliberately left in place; moving execution "into the
   registry layer" would put storage-coupled code in a pure shared
   layer, and moving it to a sibling controller mid-stage, pre-ladder,
   on the app's riskiest tested file (~243 tests) against a
   behavior-parity mandate is the same wrong risk 1a recorded for the
   executors. EVM is 3,037 lines (grew ~86: intent consumption,
   jumpToDocumentEnd, walk statics). The honest next slice (post-
   ladder, one seam, one review): gesture band + projection executors
   TOGETHER into an editor-feature controller. R119 empowerment
   invoked; the ladder should judge whether this satisfies T3's intent.
2. **TakesViewModel grew** (890 → 1,113) — the choreography, landings,
   add-block, paging, and comments-request landed on the takes
   conductor (they are board semantics). P-9 pressure noted; its
   decomposition is Stage 3 material if the ladder agrees.
3. **"Isn't rendered" = disabled, for menus.** P-2's letter says a door
   that can never act isn't rendered; macOS menus keep stable item
   lists, so truly-inapplicable contexts DISABLE (standard grey — ⌘C
   with no selection). The crime was enabled-but-void, which is now
   impossible. Rendered-but-grey ≠ a bad cell where the act is
   genuinely impossible there.
4. **The registry's scope is the ROUTED vocabulary** (menu bar, bars,
   take-card context menu, palette — 33 capabilities). Surface-local
   doors that already work (Library/Pool context menus, book navigator,
   history/tags/date buttons) are deliberately NOT declared this stage;
   the registry grows to cover them as Stage 3 touches them.
5. **Landing focus vs the 1a article pin:** the N9 landing makes the
   first slot's article pane LIVE at board open, which collided with
   the batch-14 pin's premise (an article READ pane mirroring the
   buffer). The pin was adapted — ring moved aside before the
   assertion — preserving its exact intent (read-pane mirroring).
   Recorded because a live-at-open article pane is a real behavior
   change (it is N9's point).
6. **Sheets keep in-sheet status displays** (WriteTakesPanel); the
   window-level toast would render under a sheet. AD-14's "one
   presentation" reads as one WINDOW-LEVEL presentation.
7. **Keyboard paging chord is ⌥⌘←/→, not the brief's ⌘←/→** (line
   start/end in every text surface — a global menu shortcut would
   swallow basic caret movement).
8. **Merge from Takes joins UPWARD** (the focused block into the one
   above) — the merge memo's contestable call, revisited only if it
   trips her (R116).
9. **Canvas's take family beyond step/choose is unavailable** (grey)
   rather than move-and-execute — R40: canvas is an arranging view;
   switching modes to deliver a refusal helps nobody. Contestable.
10. **`.variorumOpenPost` survives** as a pure announcement (one shell
    observer, no decision rides it) — P-4-compliant; retiring it means
    threading ShellRouter into MembershipChip/BookView for no
    behavioral gain.
11. **The visual smoke was blocked by the locked login session** (the
    dev app launched and ran clean — no crash report for the app
    process — but the screen showed the screensaver; AX saw no window).
    The screenshot-verify pass folds into the Stage 2/3 drives per the
    Stage 0(c) precedent (caffeinate -d + unlocked session).

### Memo pointers + contestable memo calls

`notes/plans/phase-13b-memo-w-ceremony.md` — contestable: NO separate
"Divide into takes…" named command (divide IS the door; the ceremony
appears exactly when the block is fanned). `notes/plans/
phase-13b-memo-merge.md` — contestable: merge-joins-upward from Takes;
"merge with block above/below" pair deliberately not built (Stage 3
revisit condition stated in the memo).

### Inputs for the Stage 1 review ladder (the cold reviewer's foci)

- The combined 1a+1b diff is the review unit. Focus 1: the
  **choreography's failure modes** — intent parked but the mode switch
  refused/raced; the flush-then-switch ordering; a block deleted
  between surfaces (lands at 0, speaks); intent consumed exactly once.
- Focus 2: **handler/detail registration lifecycles** — SwiftUI
  appear/disappear ordering (token guards pinned, but review the sheet/
  inline-editor cases: WriteTakesPanel over Write registers EditorView's
  handler UNDER the sheet, parity with the old observer behavior).
- Focus 3: **the enablement context** — `writeEditorAttached` covers
  book-inline and pool editors (mode == nil there); check every
  registry availability rule against the matrix's surfaces column.
- Focus 4: **AD-14's removals** — the board/CommitBar/Canvas local
  status displays are gone; confirm no surface now lacks feedback a
  test doesn't cover (sheets kept theirs).
- Focus 5: the T3 deviation (judgment call #1) — agree or direct the
  next slice.
- Ladder mechanics: fresh reviewer, `notes/REVIEW_PROMPT.md` verbatim;
  these closeouts are the anchor.

### Inputs for the Stage 2 tutorial brief-writer

- The tutorial can now RELY on: every structural act reachable from
  Takes (the default surface) with real execution; the take ceremony
  reachable via divide-on-a-fanned-block from either surface; ＋ new
  block in Takes; ⌘S/⌥⌘Z acting everywhere they're advertised; the
  ⌘K palette carrying the act vocabulary; ONE status toast every
  outcome lands in (the tutorial can point at it); the Helper
  dictionary naming divide/ceremony/merge/extract.
- The tutorial should EXERCISE: the move-and-execute choreography
  (divide from Takes end to end), the W sheet (fan a block, divide),
  merge-upward from Takes, the add-block door, the landing focus
  ("just start typing"), and the toast (make a refusal happen on
  purpose — sealed post — and show the spoken answer).
- Tutorial content must stay non-journal (R57/batch-17 note — the
  bridge sweeps journal days only).
- The seeded tutorial post lives in the REAL store at the end
  checkpoint (batch 17: "nothing real is in there right now").

### Architect acceptance of Stage 1b (2026-07-20, pre-ladder)

- **Both T4 memos READ IN FULL and APPROVED** (R120 satisfied — they are
  now the design of record): plain language throughout; every ratified
  semantic checked against canon (the single-space merge join, W's
  preserve-the-original + unchecked-takes-stay rule, locked-takes-copied,
  merge speaking about the fan it folds away, undo insurance). Both
  flagged contestable calls SUSTAINED: (1) divide IS the door — no
  separate ceremony command (consistent with the ratified
  two-commands/three-doors contract; a second name for one act is R112
  clutter); (2) merge-from-Takes joins UPWARD, with the memo's own R116
  revisit trigger standing (if the upward reading trips her in practice,
  the feature gets reconsidered, not patched). Both stay on the author's
  end-checkpoint reading list.
- **The T3 deviation (1b judgment call #1) — accepted as the plan of
  record, subject to the ladder:** the gesture-execution band stays in
  EditorViewModel, fused to the projection executors 1a held back; the
  proposed next slice moves band + executors TOGETHER as one seam,
  post-ladder. The architect agrees a pre-ladder mechanical move of the
  riskiest tested file served no one; the LADDER should adjudicate the
  call on the merits (it is listed in the closeout's review foci).
- **TakesViewModel growth (890→1,113)** noted as recorded P-9 pressure —
  a Stage 3 decomposition candidate once the ladder settles Stage 1's
  shape.

## Stage 1 ladder — round 1 findings (VERBATIM record; fix pass COMPLETE — dispositions follow the clean bill)

*Process note (2026-07-20): the original 1b implementer session was lost
to the author's API session limit immediately after acknowledging these
findings — zero fixes had been applied, working tree clean at `49e8c48`.
The fix pass runs as a FRESH session anchored on THIS section (which is
why it exists: the verbatim findings previously lived only in a session
message — the delivery-verification lesson applied). The fresh session is
also the better cast: the old session had passed the ~500k-token
degradation line.*

**[MAJOR]** · `Features/Takes/TakesViewModel.swift:833-837` +
`Registry/CommandRouter.swift:70-80` +
`Features/Editor/EditorViewModel.swift:1933-1935` · A stale parked
`WriteIntent` survives a failed mode switch and later executes a
structural gesture unprompted. Mechanism: `moveToWriteAndRun` parks
`pendingWriteIntent` then calls `requestMode(.write, postID:)`
DISCARDING the result. `requestMode` fails two ways: (a) `postID !=
activePostID` (user clicked another post during the preceding `await
autosave.flushNow()`) — returns false SILENTLY (the mismatch branch at
CommandRouter.swift:71-73 doesn't speak — itself a silent-door residue);
(b) no detail mounted (speaks, but the intent stays). The intent carries
no postID and no freshness token, and `applyFocusSeeds` consumes it at
the FIRST render of ANY subsequently-mounted full-document editor (detail
Write of a different post, book-inline, pool — all run `applyFocusSeeds`
on `.initialRender`). Worst case: divide invoked from Takes on post P,
switch races, nothing visible; minutes later the user opens P in Write
and the app divides a block by itself at the stale offset (different
post: lands at 0, a refusal speaks out of nowhere). Red-on-old pin: park
an intent, make `requestMode` fail, mount an editor later, assert store
unchanged / no gesture ran — fails on current code · Fix: clear
`pendingWriteIntent` (and speak) when `requestMode` returns false; and/or
stamp `WriteIntent` with postID + one-round validity so
`applyFocusSeeds` discards mismatches.

**[MINOR-1]** · `Registry/ShellActions.swift:53-74` +
`Registry/CommandRouter.swift:101-107` · `toggleSeal` in handler-less
modes (Compare/Outline/Blocks; Canvas falls through) speaks the
factually wrong `sealPost.unavailableNote` ("open a post first" — a post
IS open), THEN the ShellActions fallback seals and speaks "Sealed" — a
wrong refusal flash replaced by success, undermining AD-14's one
presentation. Related: `sealPost` availability ignores
`writeEditorAttached`, so `isEnabled(.sealPost)` is false in
book-inline/pool contexts where the act works · Fix: a non-speaking
dispatch variant for commands with shell fallbacks (or register the
missing handlers); add the `writeEditorAttached` arm.

**[MINOR-2]** · `Features/TOC/BlockTOCView.swift:38,221-222,190-193` ·
AD-14 gap: `BlockTOCViewModel.statusMessage` is the only surface VM not
forwarding to `StatusCenter`; the TOC renders its own never-dismissing
red caption. Blocks is a full mode surface — the sheet exemption doesn't
cover it · Fix: the same one-line `didSet` forward; drop the caption.

**[MINOR-3]** · `EditorCommands.swift:226,231,244-258` +
`Registry/ShellActions.swift:149-150` · The enabled-into-nil class
survives in non-routed menu items: `previousBlock`/`nextBlock` take
registry enablement (`mode == .write` OR attached) but optional-chain
into a possibly-nil editor (enabled-but-silent in Write pre-attachment);
the Callout menu + `exportCaretBlock` use a third idiom
(`editorRouter.active == nil` checks; a silent `guard else return`).
Three enablement idioms coexist in the file P-1 unified · Fix: route as
handled commands, or derive availability from attachment only.

**[MINOR-4]** · plan-file ledger · T3's deferred slice had no owner row ·
**RESOLVED BY THE ARCHITECT pre-pass** (row N10; the reviewer
independently CONCURRED with the deferral on the merits).

**[MINOR-5]** · `Features/Takes/TakesBottomBar.swift:241` ·
O(post-length) word count per keystroke: `wordCountLabel` runs
`TextMetrics.wordCount` over EVERY slot's full text each bar render, and
the bar re-renders per keystroke (reads `focusedPane`/`resolvedTake`;
every `paneEdited` mutates the observed authority). The Write editor
caches per-variant for exactly this reason (P-8 binds the rebuilt layer
to P1) · Fix: per-variant count cache on the model (recompute only the
edited variant / on projection adoption).

**[NIT-1]** · `Registry/ShellActions.swift:231` · `paletteAction`'s
`default: return {}` — a future `paletteActs` entry without a case
compiles into a silent no-op palette row; no walk covers the switch ·
Make the default speak, or pin paletteActs ⊆ handled cases.

**[NIT-2]** · `Features/Editor/EditorView.swift:189-190` +
`Features/Takes/LensesBoardView.swift:136-137` · `.takes(.closeAll)`
consumed with `break` in Write and Lenses — enabled menu item, silent
no-op in two of three enabled modes · Scope `closeAllTakes` availability
to `.takes`, or speak.

**[NIT-3]** · `Registry/CapabilityRegistry.swift:97-103,210-216,251-257`
· `addBlockAtEnd`/`commitTake`/`blockComments` inline byte-identical
copies of the `takeFamily` availability closure · Name it once.

**Clean bill (round 1, abridged):** suites verified by the reviewer's own
runs (Mac 485/96; core diff empty); PaneTextAuthority invariants; the
board soak's realness (fresh-hosting-view remount honored); N2/N3/D3/N4/
N5/N9 pins end-to-end; the registry walk's declared⇔rendered enforcement
+ R118 parity as code; P-4's three regimes deleted (grep-verified);
memos canon-checked; P1/P3 on the new surfaces (visible-page rendering,
clamped offsets, ≤1 live editor).

### Stage 1 ladder — round 1 dispositions (fix pass, 2026-07-20; fresh implementer session)

*Every finding traced to its concrete mechanism before disposal; every
bug-class fix carries a red-on-old pin verified by BEHAVIORAL REVERT
(the fix's wiring reverted, the pin run RED, the fix restored — the
types/fields stayed so the pins compile on both sides). New pins live in
`VariorumTests/CommandRoutingTests.swift` (suites "Stale WriteIntent",
"Seal door in handler-less modes", "Block TOC status forward", "Takes
word-count cache") and `VariorumTests/CapabilityRegistryTests.swift`
(the three ladder registry-fact tests appended to the walk suite).
Counts after the pass: **Mac 497/100** green (was 485/96) · **core
747/90**, `Sources/VariorumCore` byte-untouched (git-status-verified).
Fix commit: `b1f6250`.*

**[MAJOR] — AGREED-FIXED, both halves + the landing twin.** Trace
confirmed exactly as written: `moveToWriteAndRun` discarded
`requestMode`'s result; the postID-mismatch branch (user clicks another
post during the pre-switch `await flushNow()`) returned false with no
speech; the un-stamped intent survived and `applyFocusSeeds` consumed it
at the FIRST render of ANY full-document editor. Fixes: **(a)** the
parker clears `pendingWriteIntent` when `requestMode` returns false, and
the mismatch branch speaks `CommandRouter.staleModeRequestNote` ("The
open post changed — that request no longer applies."); **(b)**
`WriteIntent` gains `postID` + detail-lifecycle freshness —
`applyFocusSeeds` consumes only its OWN post's intent (a mismatched
intent is deliberately LEFT PARKED: a book-inline/pool editor rendering
mid-choreography must not destroy the detail editor's landing);
`registerDetail` clears parcels stamped for a different post
(register-ordering-proof — on a P→Q switch Q's onAppear can precede P's
onDisappear, making the token-guarded unregister a no-op); a genuine
`unregisterDetail` clears both parcels (the round is over).
**Extension, same class, recorded:** `TakesLanding` got the identical
discipline (post-stamp; clear-on-refused-switch at its two parking
sites, WriteTakesPanel + LensesBoardView; consumption guard in
`consumeLandings`) — traced mechanism: a stale landing consumed by an
unrelated board bloomed a foreign block ID AND set `landingFocusDone`,
eating that board's own N9 "just start typing" focus. Pins (5, suite
"Stale WriteIntent"): `aRefusedModeSwitchClearsTheParkedIntentAndNothing
EverRuns` (the finding's own end-to-end pin — REVERT-1 of half (a) ran
RED with the smoking gun: the reverted code DIVIDED THE BLOCK UNPROMPTED
at the later editor mount, store 1→2 blocks, plus zero speech);
`aStaleTargetedModeRequestSpeaks` (RED under REVERT-1);
`aStaleIntentForAnotherPostIsNeverConsumedByAMountedEditor`,
`theDetailLifecycleClearsStaleParkedIntents`, and
`aStaleLandingForAnotherPostNeverEatsTheBoardsLandingFocus` (all RED
under REVERT-2 of half (b) — the landing pin's red showed the foreign
bloom AND `livePane → nil`, the eaten focus, live). Both reverts
restored; the suite is green on shipped code.

**[MINOR-1] — AGREED-FIXED.** Trace: `toggleSeal`'s
`router.dispatch(.toggleSeal)` speaks the unhandled note synchronously
in handler-less modes (Compare/Outline/Blocks register no handler;
Canvas's handler falls through) — "open a post first" with a post open —
then the ShellActions fallback seals and speaks "Sealed.". Fixes:
`dispatch` gains `speakingWhenUnhandled:` (default true — every other
call site unchanged); `toggleSeal` dispatches QUIET and its
no-post guard now speaks the honest `sealPost.unavailableNote` itself
(the quiet dispatch must not create a new silent door — pinned as a
parity guard, `sealWithNoPostOpenStillSpeaksTheHonestNote`, not claimed
red); `sealPost` availability gains the `writeEditorAttached` arm
(book-inline/pool editors seal through their own routed EditorView
handler — the rule now says so). Pins:
`sealFromAHandlerLessModeActsWithoutAWrongRefusalFlash` (asserts
`status.current == nil` immediately after the call — the wrong note
landed synchronously pre-fix — then the real seal + "Sealed."; REVERT-3
ran RED capturing the wrong note verbatim) and
`sealPostIsAvailableWhereverItActuallyWorks` (RED on the reverted arm).

**[MINOR-2] — AGREED-FIXED.** Trace: `BlockTOCViewModel.statusMessage`
was the one surface VM without the AD-14 `didSet` forward; the view
rendered it as a never-dismissing red caption — Blocks is a full mode
surface, outside the sheet exemption. Fix: the same one-line forward
(`session.status.speak`) + the caption removed from `BlockTOCView`.
Pin: `tocRefusalsLandInTheOneStatusCenter` (a sealed-post deleteBlock
refusal reaches the StatusCenter; the property stays the tested truth;
REVERT-3 ran RED — center empty).

**[MINOR-3] — AGREED-FIXED.** Trace: `previousBlock`/`nextBlock` were
registry-enabled under `writeEditorAttached || mode == .write` but their
menu actions optional-chain into `editorRouter.active` — in Write with
the editor still mounting they were enabled-but-silent (the
enabled-into-nil class); Callout and `exportCaretBlock` used a third
idiom (raw `editorRouter.active == nil` disables; a silent
`guard else return`). Fix — the reviewer's "derive availability from
attachment only" option: the `writeEditor` availability rule is now
ATTACHMENT-ONLY (enabled ⇔ the editor the action chains into exists),
and all four items read the one registry idiom (`enabled(id)`);
`exportCaretBlock`'s guard SPEAKS its declared note for the
caret-outside-any-block case its coarser enablement now admits (the
open tail — fire → real refusal, P-2). Not taken: routing them as
handled commands (heavier — four handler switches grow for acts whose
one true home is the attached editor; attachment IS the actability
truth). Pin: `writeEditorScopedActsAreEnabledOnlyWithARealEditor`
(never enabled unattached; enabled when attached, incl. the
book-inline/pool context; REVERT-3 ran RED on all four ids).

**[MINOR-4] — RESOLVED-BY-ARCHITECT** (pre-pass): ledger row N10 owns
the deferred T3 slice (gesture band + projection executors move
TOGETHER, post-ladder). No action this pass.

**[MINOR-5] — AGREED-FIXED.** Trace: `TakesBottomBar.wordCountLabel`
reduced `TextMetrics.wordCount` over EVERY slot's full projection text
per render, and the bar re-renders per keystroke (it reads
`focusedPane`/`resolvedTake`, and every `paneEdited` mutates the one
observed `authority` property) — O(post length) per keystroke, the
class P-8 binds the rebuilt layer against. Fix: the post total is now
`TakesViewModel.postWordCount`, recomputed per PROJECTION adoption with
the `EditorSurfaceLedger.adopt` discipline mirrored (per-slot text+count
cache; only changed texts re-enumerate; `slotRecountCount` is the test
seam); the bar reads the cached total. The focused-take half stays a
per-render count of ONE take (O(the edit unit) — the Write editor's
live-caret-count precedent). Displayed values are byte-identical to the
old label (the old reduce also only changed at projection cadence).
Pin: `slotWordCountsRecomputeOnlyWhereTextChanged` (first adoption
counts N; unchanged re-adoption counts ZERO more; a one-slot edit
counts exactly one more; totals asserted; REVERT-3 — recount-all — ran
RED at 6 then 9 recounts).

**[NIT-1] — AGREED-FIXED** (no pin owed; traced mechanism: a future
`paletteActs` entry without a `paletteAction` case compiles into
`default: return {}` — a rendered palette row that does nothing, and no
walk can introspect closures to catch it). The default is now loud in
DEBUG (`assertionFailure`) and speaks an honest sentence in release —
the row can never be silent. Justification: the invocation-walk
alternative can't run (several palette bodies open modal panels).

**[NIT-2] — AGREED-FIXED** (bonus pin, cheap): traced — Write's and
Lenses' handlers consume `.takes(.closeAll)` with `break` while the
menu item rendered enabled (`takeFamily`); blooms exist only on the
Takes board. `closeAllTakes` availability is now scoped to `.takes`
(the reviewer's first option); its unavailable-note names the board.
The handlers' `break` arms stay (unreachable from the now-disabled
door; behavior parity). Pin: `closeAllTakesIsScopedToTheTakesBoard`
(RED under REVERT-3).

**[NIT-3] — AGREED-FIXED** (no pin owed; traced: the
`addBlockAtEnd`/`commitTake`/`blockComments` availability closures were
byte-identical copies of `takeFamily` — three places for one rule to
drift). All three now name `takeFamily`; the registry walk's existing
facts pin the unchanged semantics. `blockComments`' inline comment
("the bars' block menus carry the door") moved to the declaration.

**For round 2's reviewer:** the fix surface is 11 app files + 2 test
files (commit `b1f6250` — Registry/{Capability, CommandRouter,
CapabilityRegistry, ShellActions}, TakesViewModel, EditorViewModel,
WriteTakesPanel, LensesBoardView, BlockTOCView, TakesBottomBar,
EditorCommands). Judgment calls WORTH A LOOK: (1) the mismatched-intent
leave-it-parked reading in `applyFocusSeeds` (protects the book-inline
race; staleness is the router's lifecycle clearing — is the pairing
airtight?); (2) the TakesLanding extension (same class, small, but it
widens the diff beyond the finding's letter); (3) MINOR-3's
attachment-only reading briefly greys the four caret acts while Write's
editor mounts (honest-grey vs the old enabled-but-silent — P-2 says
grey); (4) `exportCaretBlock` is now enabled with the caret in the open
tail and speaks instead of greying (context can't see caretBlockID —
acceptable under fire-and-DO?).

## Stage 1 ladder — round 2 (VERDICT: zero new BLOCKER/MAJOR — the ladder CLOSES at round 2; residual fixes land post-close per the standing pattern)

The round-2 fresh cold reviewer verified EVERY round-1 disposition HOLDS
(all pins located, read, and re-run; the full Mac suite re-run
independently: 497/100 green, count arithmetic exact; `Sources/
VariorumCore` byte-untouched across the whole 13b range, git-verified)
and SUSTAINED all four flagged judgment calls (leave-it-parked: sound
for its class, refined by the MINOR below; the TakesLanding extension:
the right call; attachment-only grey: P-2's own text; exportCaretBlock
speaks: the P-2 contract, copy nit noted). Round-2 findings, verbatim:

**[MINOR-R2] · `Features/Takes/TakesViewModel.swift:881–887` +
`Registry/CommandRouter.swift:67–77,96–108` +
`Features/Editor/EditorViewModel.swift:1940–1944` · A SAME-POST parked
`WriteIntent` survives an ABORTED round and executes on a later Write
mount — the MAJOR's class through a window the fix doesn't cover.**
Mechanism (traced): the park + `requestMode(.write, P)` SUCCEEDS →
`applyMode(.write)` flips the detail's `@State` → the arriving editor
consumes only at `.initialRender` (one render pass + the first async
projection delivery). In that tens-of-ms gap a competing mode switch
(⌘2–⌘7, user-reachable) flips the detail off Write; EditorView unmounts
before any `.initialRender`; the intent stays parked — the post MATCHES,
so neither `registerDetail` (same detail, no re-registration) nor
`unregisterDetail` (never torn down) clears it. The NEXT Write mount of
that post — minutes later — consumes it and runs the structural gesture
unprompted. The fix's own stated invariant ("valid for exactly the round
that parked it") is not fully delivered: clearing keys on detail
IDENTITY, not on the ROUND. The `TakesLanding` twin has the same window
(benign consequence: stale bloom/focus). Red-on-old pinnable (park →
successful request → report a competing mode → later mount → assert no
gesture ran). Proposed fix: clear `pendingWriteIntent` in `noteMode`
when the reported mode differs from the intent's landing mode (and the
landing twin when mode leaves `.takes`); ordering safe — the park
precedes `applyMode(.write)`, whose own `onChange` reports `.write` and
keeps the parcel.

**[NIT-R2-1] · `Registry/CommandRouter.swift:48–57`** · the 5-line
"Staleness (round-1 MAJOR, half b)" comment pasted twice verbatim inside
`registerDetail` — fix-pass edit artifact; delete one copy.

**[NIT-R2-2] · `Features/Takes/TakesViewModel.swift:95,101–124`** ·
`slotCountTexts` holds a full second copy of every slot's rendered text
for change detection. Bounded and settle-cadence (P1-clean), but the
"never copies of persisted text in state" rule is now leaned on twice,
and a cheaper shape is in-hand: `adopt` still holds the OLD projection
before the overwrite — diff old-vs-new slots (or per-slot hashes), no
text copy. Cleanliness only; honestly labeled unpinnable.

**[NIT-R2-3] · `EditorCommands.swift:297–310`** · `promptCalloutEmoji`'s
`guard … else { return }` is the file's last silent-return idiom (frame
race reachable only if the editor detaches between menu-open and click);
speak the callout note. Related copy nit: `exportCaretBlock`'s spoken
note reads oddly when heard IN Write with the caret in the open tail — a
caret-specific sentence would read better. Cosmetic.

**Clean bill (round 2, abridged):** fix-diff scope matches the
disposition record exactly (11 app + 2 test files, nothing stray);
`speakingWhenUnhandled:` has exactly one quiet call site whose fallback
guard speaks (pinned); the TOC forward cannot double-present; the seal
check-then-act race degrades to a spoken ops refusal, never wrong state;
the registry walk still enforces declared⇔rendered on all four door
surfaces + R118 parity; AD-14's one presentation now total across
surface VMs; P1/P-8 on the fix surface (settle-cadence counting, nothing
O(corpus)); the choreography's flush-first ordering rides the one
per-post coordinator with no interleaving hazard at the park site.

### Stage 1 ladder — round 2 dispositions (residual fix pass, 2026-07-20; same fix-pass session)

*The ladder CLOSED at round 2 (zero new BLOCKER/MAJOR); these residuals
landed post-close per the standing pattern. Every mechanism re-traced
before fixing; the one bug-class fix revert-verified RED. New pins in
`CommandRoutingTests` suite "Stale WriteIntent". Counts after the pass:
**Mac 499/100** green (was 497/100) · **core 747/90**,
`Sources/VariorumCore` still byte-untouched. Fix commit: `cd1650c`.*

**[MINOR-R2] — AGREED-FIXED.** Trace confirmed independently: the park +
successful `requestMode(.write, P)` begins a round whose consumption
door (`applyFocusSeeds` at `.initialRender`) is one render pass + one
async projection delivery away; a competing ⌘2–⌘7 switch in that gap
unmounts EditorView pre-render, and the SAME-post parcel defeats both
round-1 clearing doors (registerDetail — same detail, never re-fires;
unregisterDetail — never torn down). The round-1 invariant ("valid for
exactly the round that parked it") was keyed on detail IDENTITY, not the
ROUND. Fix — the reviewer's proposed shape, verified sound by own trace:
`noteMode` clears a parked parcel the moment the detail reports any mode
other than the parcel's LANDING mode (`WriteIntent` ⇒ `.write`,
`TakesLanding` ⇒ `.takes`). Ordering safety verified and PINNED: the
park precedes `applyMode(.write)`, whose own `onChange` reports the
landing mode first — the pin asserts `noteMode(.write)` keeps the
in-flight intent before `noteMode(.lenses)` clears it. Pins (2):
`aCompetingModeSwitchAbortsTheRoundAndClearsTheParkedIntent` (the full
window end-to-end — park via the real choreography, successful request,
landing-mode report kept, competing report cleared, later same-post
Write mount runs NOTHING; behavioral revert of the noteMode clearing ran
RED with the same smoking gun as round 1: the orphaned intent DIVIDED
THE BLOCK UNPROMPTED, store 1→2) and
`aCompetingModeSwitchClearsTheParkedLandingToo` (the twin's round
boundary; RED under the same revert). Restored; suite green.

**[NIT-R2-1] — AGREED-FIXED** (no pin owed; the mechanism was a fix-pass
edit artifact — the restore-after-REVERT-2 edit re-added the staleness
comment above the surviving copy). One copy deleted.

**[NIT-R2-2] — AGREED-FIXED, the cheaper shape taken.** Traced: the
change-detection texts in `slotCountTexts` were exactly the OLD
projection's slot texts (adopt is the only projection door and always
refreshed both), so diffing against `self.projection` BEFORE the
overwrite is equivalent by construction — `refreshWordCounts(old:new:)`
now runs first in `adopt` and builds a transient old-text index; the
stored text copy is GONE (the "never copies of persisted text in state"
rule is leaned on zero extra times; `slotCounts` remains — counts are
derived values, sanctioned state). The MINOR-5 pin
(`slotWordCountsRecomputeOnlyWhereTextChanged`) held byte-unchanged
through the reshape — the recount discipline is pinned independent of
the detection mechanism, exactly as intended.

**[NIT-R2-3] — AGREED-FIXED** (no pin owed; traced: the
editor-detaching-between-menu-open-and-click race reached a bare
`return`). `promptCalloutEmoji`'s guard speaks the callout note (a nil
SESSION still returns silently — no status surface exists to speak to);
`exportCaretBlock`'s note is now caret-specific — "Put the caret in a
block to export it." — because its ONE speaking site is precisely the
attached-editor caret-outside-any-block case (the menu grey covers
everything else; nothing pinned the old copy, grep-verified).

## Stage 1 closeout (stage-level, 2026-07-20 — written at ladder close for the Stage 2 brief-writer and the end-checkpoint walk)

Stage 1 rebuilt the interaction layer's two load-bearing floors and
closed its review ladder at round 2 with zero open findings. **1a** put
pane text/liveness under ONE pure tested authority (`PaneTextAuthority`
— exactly one live ring, buffer-authoritative live pane, catch-up read
panes) rendered by ONE pane surface (`PaneSurface` — one measurement
brain, a RENDERED canary, the full-document editor deliberately kept as
its own kind), consolidated autosave to one per-post coordinator
(`AppSession.autosave(forPost:)`), and landed the randomized board soak;
**1b** made every routed act data (the 33-capability
`Registry/` — availability, doors, refusal copy, the R118 parity table
declared and walk-enforced), replaced all three Stage 0 routing regimes
with the `CommandRouter`, and made fire-and-DO real (the mode-switch
choreography; the W ceremony reachable from Takes; ⌘S/⌥⌘Z/landing/
palette/context-menu cells fixed; AD-14's one StatusCenter
presentation); **the ladder** (round 1: 1 MAJOR/5 MINOR/3 NIT; round 2:
zero new HIGH, 1 MINOR/3 NIT residuals) then hardened the choreography's
one genuinely new hazard — a parked `WriteIntent` is now post-stamped
and round-scoped (cleared on refused switch, detail change, teardown,
AND any off-landing-mode report), so the app's first
gesture-without-a-user-gesture machinery cannot fire stale — and retired
the last silent/wrong-speech residues (seal double-speak, TOC caption,
enabled-into-nil menu items, the O(post)-per-keystroke word count).
**Counts trajectory: Mac 431/81 (pre-13b) → 455/89 (1a) → 485/96 (1b) →
497/100 (round-1 fixes) → 499/100 (round-2 residuals)**; core 747/90
byte-untouched throughout; every bug-class fix in the stage carries a
behavioral-revert-verified red-on-old pin. **Classes retired
structurally:** frozen/clipped pane text (the authority), the dead
canary, dual autosave, silent doors / dead keys / lecture-and-redirect /
broadcast-into-the-void (registry + router + fire-and-DO), the
enabled-but-void menu class both ways, fragmented refusal presentation,
and stale choreography parcels. **Deferred to Stage 3, each owned:** the
T3 second slice — EditorViewModel's gesture band + projection executors
move TOGETHER as one seam (ledger **N10**; both implementers + both
reviewers concurred) — and the TakesViewModel P-9 decomposition (890 →
~1,240 with the choreography/landings/paging, recorded 1b judgment call
#2); the takes-lifecycle completeness set (**N1, N6** — T5), geometry/
spacing/crowdedness (**D2, N8, AD-7/AD-8** — T7), book view (**D1** —
T6), and the memos' deeper behavior builds (**M1/M2** tails). The
tutorial spine (Stage 2) can rely on everything in the 1b closeout's
"Inputs for the Stage 2 tutorial brief-writer" plus: the round-scoped
choreography is safe to script against mode switches, and the
StatusCenter is the ONE place every outcome (including refusals made on
purpose) lands.

## Stage 2 execution brief (self-contained — finalized 2026-07-20 after Stage 1 closed; read this + the constitution + the Stage 1 stage-level closeout + the 1b "Inputs for the Stage 2 tutorial brief-writer")

**Goal (R113, her words):** a tutorial that "could walk you through all
the functionality, and has been walked through all the functionality…
if it touched every functionality and actually worked perfectly, [it]
would be the thorough UI edit and pass needed." Stage 2 builds it, WALKS
it, and fixes everything the walk trips over. Output: the tutorial as
the app's permanent acceptance layer (P-6) and its discoverability face.

**Architect decisions (binding):**

1. **The tutorial is a curated BOOK, built of the app's own objects** —
   a book with real chapters (`reading_section` rows), lessons as posts,
   instructions IN the prose. The app teaches itself WITH itself: by the
   time she's read the book she has USED books, chapters, posts, and
   blocks. Name it in the app's voice (implementer's call; plain, warm,
   terminal-flavored — the memos' bar). All content NON-JOURNAL
   (`.generic`; never `profile='journal'` — R57; the bridge sweeps
   journal days only).
2. **Lesson content is act-ready:** each lesson's prose tells the reader
   what to do AND its blocks are pre-shaped for the act (a paragraph
   begging for a second take; two blocks that read as one thought,
   ready to merge; a pre-fanned block whose divide opens the ceremony; a
   sealed mini-post whose refusal demonstrates the status toast — the
   deliberate-refusal show-and-tell from the 1b inputs).
3. **Coverage (every lesson names its acts; this list is the contract):**
   getting around (shelf, library, ⌘K, the Helper) · writing + blocks
   (typing/crystallization, seams toggle, make block, add-block-at-end,
   block names, callouts) · takes (first take, ＋take, blank take,
   choose, the styles incl. the paged rail, expand/collapse, ⌘S commit,
   history/restore, archive — teach where an archived take GOES only as
   far as today's truth allows; N1/T5 is Stage 3's, route the lesson
   honestly around it) · divide + THE CEREMONY (single-variant divide;
   fan-then-divide → the W sheet end to end) · extract · merge (seam,
   selection chain, from-Takes upward) · comments · tags · lenses
   (column, save, adopt-swaps-never-destroys) · compare · outline ·
   the Blocks area/TOC · canvas · books (the tutorial book itself:
   chapters, reorder, collapsed cards, finish/extent) · pool/scraps ·
   export (block/post/book) · seal + unseal · both undo stacks (⌘Z text
   vs ⌥⌘Z structural) · the choreography itself (divide-from-Takes:
   watch the app switch, act, and speak).
4. **The walk is mandatory and comes AFTER the build:** drive EVERY
   lesson in the dev store through the visual loop (AX/keystrokes +
   window-scoped screencapture; run your own `caffeinate -d`;
   pid-verify the dev instance; never touch a /Applications instance).
   Triage every stumble: (a) a happy-path breaker → FIX in-stage,
   red-on-old pin; (b) a known Stage 3 ledger item → verify the row,
   design the lesson around it honestly; (c) a new out-of-scope defect →
   new ledger row, Stage 3. The stage is done when a full walk produces
   zero stumbles.
5. **The executable half:** `TutorialWalkTests` — for each lesson,
   execute its acts HEADLESSLY through the same registry/operations
   doors against freshly-seeded tutorial content and assert the outcome
   the prose promises (store state, not pixels). Green forever after; a
   change that breaks a tutorial step is a regression by definition
   (P-6). The screenshot walk is the visual half and re-runs per Stage 3
   batch.
6. **Seeding is a product door, not a spike:** an idempotent seeder
   through Operations (extend the A10/DesignCorpusSeeder patterns),
   invoked from a Help-menu door ("Restore Tutorial…" — registry-
   declared, fire-and-DO like everything). Re-seed restores pristine
   lessons (existing tutorial book replaced wholesale after a spoken
   confirm); everything deletable like any post/book.
7. **The A10 modes tutorial is ABSORBED, not duplicated:** its
   polish/thread/fork content becomes a chapter of the one tutorial
   book; the old entrance points at the new book; record the
   supersession (A10 was a ratified deliverable — this is its
   growth, and the author reviews it at the checkpoint).
8. **REAL-store seeding at stage close** (batch-17 allowance): run an A1
   rotating backup FIRST; require ZERO running Variorum instances;
   pid/path/store-fence verified (the sanctioned real-store opt-in door
   from a Debug-build tool, or the refreshed /Applications build's own
   Restore-Tutorial door driven via the visual loop); the tutorial book
   appears on her real shelf for the end checkpoint. Log exactly what
   was written.
9. **Choreography caution (from the Stage 1 close):** any NEW landing
   kind must declare its landing mode in `noteMode` or it is cleared on
   arrival — the round-scoping is deliberate.

**Tests:** `TutorialWalkTests` (every lesson); pins for every in-stage
fix (red-on-old, revert-verified); the registry walk extended to the new
Help door; full Mac + core suites green at close. Baselines: **Mac
499/100 · core 747/90** (core stays untouched — the seeder writes
through existing Operations only).

**Constraints:** behavior parity outside the tutorial + its door;
`Sources/VariorumCore` untouched; P1–P3 (the seeded book is ordinary
data — no special rendering path); VoiceControls vocabulary; the R120/
R119 posture (choose, record, continue; judgment calls to the closeout).

**Process:** fresh implementer session; commits in logical chunks with
the standing trailer; "## Stage 2 closeout" in this file (lesson
inventory, walk log summary + screenshot dir, fixes with pins, judgment
calls, what the Stage 3 brief-writer needs); `/Applications` refreshed;
the environment traps from the Stage 1a/1b briefs apply verbatim (incl.
PIPESTATUS, suite-level test filters, the NSHostingView remount trap).
**Review:** the standard ladder follows the closeout.

## Stage 2 closeout (2026-07-20, fresh implementer session — COMPLETE)

**Counts:** Mac app **530 tests / 106 suites** green (was 499/100 —
+32 `TutorialWalkTests` incl. 2 walk-fix pins, −3 retired
`ModesTutorialTests`, +1 elsewhere in the diff arithmetic) · core
**747/90** green and **byte-untouched** (git-verified; the seeder writes
through existing Operations ONLY). `/Applications/Variorum.app`
refreshed from Release and carrying the tutorial build. Commits:
`7c08111` (the spine) → `63bb594` (walk fixes) → the closeout commit.

*(Ladder round-1 correction, NIT-1 — a correction note, not a rewrite:
`TutorialWalkTests` shipped as **34** tests, not 32, and there was no
"+1 elsewhere" — the true decomposition is 499 + 34 − 3 = 530. The 530
total and the suite count were right; only the decomposition above was
invented. Recorded here so the history stays as written.)*

### The book (the coverage contract, executed)

**"the field guide"** — a curated book, 6 real chapters
(`reading_section` rows) · 21 `.generic` lesson posts, every one tagged
`tutorial` (the restore identity — disclosed IN the tags lesson),
`word_target` 4000 (the extent face teaches itself on the shelf),
plus the staged satellites: the **"compare & versions — the twin"**
version copy (tagged; retitled at seed — walk finding: two identical
palette rows), the **"tutorial scraps"** pool (2 scraps, the second
fanned for ⌥-drag), and the **sealed** "the seal" lesson.
`TutorialSeeder.plan` is the machine-readable contract; the walk test
asserts seeded book ⇔ plan exactly. Zero journal-shaped rows (profile
OR entry_date — the R57 bridge guard, pinned).

Chapters → lessons → headline acts:
- **welcome** — *start here* (the book's own objects; the toast; ⌘/;
  Restore Tutorial), *getting around* (shelf/quick entry, Library,
  Pool, Blocks, ⌘K, ⌘N/⌘J, the seven modes).
- **writing** — *blocks & typing* (crystallization, I4, ⌘⇧B seams,
  word counts), *shaping blocks* (⌘⇧K's staged lonely sentence,
  ＋new-block doors, the NAMED block, the CALLOUT with 💡).
- **takes** — *your first take* (⌘T/⌥⌘T on the staged lighthouse
  block; ONE ring), *choosing & the board* (⌘⏎; the staged 4-take rain
  fan; styles; the ◀ x–y of n ▶ paged rail + ⌥⌘←→), *keeping takes
  safe* (⌘S/history/restore; archive with the honest
  road-back-through-Write note — N1/T5 routed around, not lied about).
- **structure** — *divide* (snap-and-proceed; the choreography NAMED as
  a feature), *the take ceremony* (staged 3-take ferry block; check
  two, leave one; undo restores whole), *extract & make block*, *merge*
  (the staged waiting pair; the fanned pair whose spare take stays in
  lineage; joins-upward from Takes), *the two undos* (⌘Z vs ⌥⌘Z; the
  insurance savepoint).
- **ways of looking** — *lenses* (2×2 takes + the saved "the other
  reading" lens; adopt-swaps-never-destroys), *compare & versions* (the
  seeded twin; mark vs duplicate; unmark), *outline · blocks · canvas*.
- **the library of things** — *comments & tags* (staged margin comment;
  the tag disclosure), *books & the shelf* (this book itself: chapters,
  reorder, cards, Book·Read, finish/extent), *pool & scraps*, *export —
  it's all yours* (Markdown with Takes… = the Alternates shape), *the
  seal* (the deliberate-refusal toast show-and-tell), *three ways of
  working* (**the A10 absorption**).

### The doors

Help ▸ **Restore Tutorial…** — registry-declared (`.restoreTutorial`,
menuBar + palette, availability `always`), fire-and-DO: spoken confirm
naming the EXACT scope (only when a tutorial exists), wholesale replace
by the app's own identities (the `tutorial` tag + the reserved
book/pool names), then opens the fresh book and speaks ("The tutorial
is fresh — 'the field guide' is on your shelf."). Help ▸ **Open the
Tutorial** + the ⌘K row + the Library ⋯ menu are find-or-seed OPEN
entrances (navigation-class, deliberately not registry-declared — the
1b judgment-call-#4 scope rule). The registry walk covers the new
capability via the existing statics equality (menuRendered +
paletteActs grew with the declaration).

**A10 SUPERSESSION RECORDED:** the Phase 11 A10 modes tutorial
(`ModesTutorialView` + model + tests + the `.tutorial` sidebar case) is
DELETED; its polish-in-place / thread-one-piece / fork-the-piece
teaching lives on as the "three ways of working" lesson (act-ready:
the staged thread take; the ratified vocabulary sentence verbatim);
every old entrance now opens the book. A10 was a ratified deliverable —
this is its growth into the R113 spine; the author reviews the
absorption at the end checkpoint.

### TutorialWalkTests (P-6's executable half — 32 tests, 7 suites)

Book shape (plan ⇔ seed exactly; R57 zero-journal pin; tag identity +
faces; act-ready staging: the 4-take fan, the 3-take ferry, the seal,
the named block + callout JSON, the lens, the comment, the scrap fan,
the twin link) · the doors (restore replaces wholesale AND leaves a
user's rows byte-identical — pinned against a seeded user post/book;
confirm-declined keeps the book; the door seeds+opens+speaks; open
never duplicates) · per-chapter acts through the registry/operations
doors with STORE outcomes asserted — highlights: the ⌘⇧K compound
frees the exact sentence; the routed ⌘T over the REAL mounted board
reveals (walk-fix pin); commit/history/restore round-trip; archive +
unarchive; the choreography end-to-end ON tutorial content (park →
visible switch → landed cut); `divideW` with an unchecked take +
structural undo restoring the whole; merge's single-space join; the
fanned merge's lineage promise; the undo-insurance savepoint pin;
adopt-preserving-chosen mints "chosen until"; twin independence;
outline mint; canvas memory; comment edit/delete/restore; chapters
reorder + finish reversibility; poolDragCopy ± fan; exports (post with
Alternates, book as one document, block alone); the sealed ⌘S refusal
landing verbatim in the StatusCenter.

### The walk (the visual loop — dev store, Debug build, pid-scoped)

Screenshots: `notes/plans/phase-13b-stage2-screens/` (~40 captures,
gitignored). Driven with a rebuilt AX/CGEvent tool (scratchpad;
`CGEventPostToPid` + menu-path AXPress + window-scoped
`screencapture -l`), own `caffeinate -d`.
**Environment: the login session was SCREEN-LOCKED throughout** (the
Stage 0(c) condition): menu key-equivalents, SwiftUI-field typing
(palette, quick entry), menu AXPress, and captures all work; real
clicks/drags/scroll never deliver, window-content AX is degraded, and
the NSTextView editor receives no caret/typing events (menu
equivalents only). Consequence: Takes-surface acts and every menu door
were LIVE-driven; Write-caret-precise acts were not drivable live.

**Live-verified (highlights):** the seed via the product door; the
spoken confirm sheet (exact scope copy); Cancel keeps the book
(⎋/⌘. dismiss the modal); the book view (chapters, collapsed cards,
21 posts); every lesson's Takes face + the Write faces; the N9 landing
("LANDED:" typed straight into the ring); ⌘T-reveal post-fix (fan
blooms, ✓ card, pager, growth doors); ⌥⌘→ paging (3–3 of 3); the
COMMIT toast; the UNDO toast ("Undid: Divide") + both cuts restored;
the divide REFUSAL toast ("No legal boundary for that here."); the
choreography live (Takes → visible Write switch → snapped cut — fired
once from the ⌘K palette act row, an accidental proof of the palette's
fire-and-DO); the SEALED lesson's banner + greyed commit + unseal door
+ the sealed-refusal toast verbatim; Compare's aligned pair with
lineage bars; Blocks/TOC self-referential rows; the callout + seams +
handles rendering on mount POST-FIX (w41); the shelf faces ("the field
guide · #tutorial · 21 posts · 6 ch · 79% of 4000w" — the row's 0%
right after seeding is a settle-cadence artifact, correct on next
refresh); the REAL-store door end-to-end (below).

**Stumbles → triage:**
1. **⌘T minted an INVISIBLE take** (closed fan: no bloom, no ring —
   the article kept showing chosen; the bar's ＋take didn't even
   focus). Happy-path breaker → **FIXED in-stage**:
   `TakesViewModel.revealTake` + `branchTakeRevealed`/
   `newBlankTakeRevealed` (blankChoose reveals too); every mint door
   (⌘T/⌥⌘T/⇧⌥⌘T, bar, block ▾, growth doors, card context menu)
   routes through the one brain; Lenses' pick-into-column and the
   Write panel's always-listed takes keep their own
   visible-by-construction semantics. Pin
   `branchOnAClosedFanRevealsTheNewTake` (the REAL routed door over
   the mounted board) — behavioral revert ran RED (expandedBlocks
   empty). Re-driven live: w08.
2. **The callout lesson rendered NO frame** (and that mount had no
   seams/handles either). Traced to a mount-order race: `attach`
   precedes the coordinator's `install`, so a loaded model computes
   decorations into a NIL `decorSink` and the `lastDecorState`
   equality gate then STARVES the freshly-wired host until the next
   real change. Happy-path breaker (and a pre-existing timing-
   dependent class) → **FIXED in-stage**: wiring now delivers
   (`pushDecorationsToSink` re-arms the gate;
   `BlockDecorOverlayController.init` calls it). Pin
   `aFreshlyMountedEditorRendersTheCalloutFrame` reproduces the
   starved order over the real mounted editor — behavioral revert RED.
   Re-driven live: w41 (frame + 💡 + seams + handles on mount).
3. **Palette keyboard row-stepping missing** (⏎ = first row only; the
   › never moves; act rows shadow same-named posts). Real gap, not a
   lesson-promise breaker (the lesson promises "⏎ opens the hit" —
   true) → **ledger N11**, Stage 3.
4. **⌘1-then-type lands nowhere** (Write never claims the caret on a
   bare mode switch; the lesson's own instruction says "click", so no
   prose lie). Observed under the lock where first-responder semantics
   are abnormal → **ledger N12, VERIFY-THEN-FIX** at an unlocked
   drive.
5. **Chapters don't reach `exportReading`** (headless walk finding:
   `assembleReading.sectionPath` is grouping-tag-only; core frozen) →
   **ledger N13**; the export lesson + test assert the honest shape.
6. **N8/AD-8 CONFIRMED live** on the comments lesson (the margin
   comment clips under the sidebar at default width) — the existing
   T7 row, now with tutorial-content evidence (w25).
7. Seeder polish from the walk: the version twin retitled
   ("compare & versions — the twin") — two identical ⌘K rows invited
   opening the wrong post.

**Environment-gated live remainder** (each headlessly pinned through
the same code paths; folds into the Stage 3 unlocked drives per the
Stage 0(c) precedent): the ceremony SHEET's on-screen walk (its store
half — divideW + undo — is pinned; the sheet is untouched Phase 9
machinery), precise selections (extract/make-block at the staged
spans), typing/crystallization's surface half, archive-recovery
through Write's panel, all drags (scrap → draft, canvas cards, chapter
reorder), save-panel exports, the Restore confirm's Replace press
(modal keys dead under lock; Cancel + the no-book path both proven),
palette ↓-stepping (N11 anyway). One anomaly on the record: the FIRST
dev-instance restore seeded but did not visibly auto-open/speak —
never reproduced (the real-store run did both; the headless pin covers
the mechanism); noted alongside two blank utility windows the app
creates at every launch (a 500×500 layer-0 white window + a layer-101
panel — identity unestablished, no app code creates NSWindows; worth a
look at an unlocked drive).

**Exit-bar reading (honest):** every lesson surface reachable under
the locked session was driven; both happy-path breakers found were
fixed in-stage, revert-verified, and re-driven clean; the un-drivable
remainder is enumerated above and headlessly covered. Zero OPEN
stumbles on the walked surface; the locked-session residue is the
Stage 3 drives' first item.

### REAL-store seeding (the brief's rail, executed in order)

1. **A1 backup FIRST**: `variorum-backup-2026-07-20-175038.sqlite`
   into the store's own `Backups/` (WAL-safe `.backup`;
   `integrity_check` ok; 15 live containers / 2 readings — matching
   the live store pre-seed).
2. **Zero instances**: pgrep-verified (the dev instance quit first).
3. **Fence/path**: the real store had NO field guide (count 0);
   `/Applications` refreshed from Release (this build) BEFORE launch;
   the launched instance verified visually as the REAL store (Study
   voice, her Journal + "my book :)", Signed out + Bridged footer — no
   dev-fence line) and by pid/path.
4. **The product door itself seeded it**: Help ▸ Restore Tutorial… on
   the /Applications instance (no confirm — nothing to replace); the
   door seeded, AUTO-OPENED the book, and spoke the toast (r02).
5. **Written** (verified read-only post-quit): 1 reading "the field
   guide" + 6 sections + 21 memberships; 22 posts tagged `tutorial`
   (21 lessons + the twin); 1 pool "tutorial scraps" (2 scraps, one
   fanned); "the seal" sealed; assorted blocks/takes/lens/comment per
   the seed; **zero journal-shaped rows** (her Journal book
   untouched). Her pre-existing 15 containers and 2 readings:
   untouched. The app was quit gracefully (⌘Q, quit-door flush) after
   verification — it was the instance this session launched.

**Dev-store state left behind** (re-seed awareness): the field guide
plus walk artifacts (extra takes on the first-take/keeping lessons, a
chosen-take change on the choosing lesson, "a quick post minted by the
stage 2 walk", the pre-retitle twin). One Help ▸ Restore Tutorial…
makes it pristine — deliberately left as a live exercise of the door.

### Judgment calls (R119 — for the end-checkpoint walk)

1. **The tutorial's name and voice are the implementer's call as
   briefed**: "the field guide", lowercase lesson titles, warm
   terminal-flavored prose in the memos' register — she reads the book
   itself at the checkpoint.
2. **The restore identity is the `tutorial` TAG + reserved names**
   (book "the field guide", pool "tutorial scraps") — the app's own
   machinery as the marker, disclosed in the tags lesson; a lesson she
   un-tags becomes HERS and survives restores (asserted). No schema,
   no defaults-key bookkeeping (a defaults key would leak across the
   dev/real store fence).
3. **"Open the Tutorial" entrances are navigation-class** (not
   registry capabilities) per the 1b registry-scope call; the ACT
   (restore) is declared.
4. **The book carries a word target (4000)** so the extent face is
   real on her shelf — the books lesson owns the explanation.
5. **The A10 demo's UserDefaults keys are gone** with the view;
   leftover A10 demo posts in any store remain ordinary deletable
   posts (none exist in the real store).
6. **The ceremony/merge lessons teach the memos' calls verbatim**
   (divide IS the door; merge joins upward from Takes) — the
   contestable memo calls stay on her checkpoint list unchanged.
7. **The seeder tolerates partial cleanup** (`try?` per delete): a
   half-deleted tutorial can't wedge a restore; the fresh seed is the
   goal.
8. **Walk fix 1 changes mint-door behavior everywhere** (fan opens +
   ring moves on every mint) — the R112-class fix the lesson demanded;
   if she prefers quieter minting anywhere, that's an R116
   reconsideration, not a revert.

### For the Stage 2 review ladder

- The diff unit: `7c08111` + `63bb594` + this closeout commit.
- Focus 1: the seeder's cleanup scope (the tag-identity contract — can
  a wholesale replace ever touch hers? The pin says no; check the
  discovery queries' edges: archived tutorial posts ARE tagged and die
  with the replace — intended: archive is kept-out-of-view, and the
  confirm says "every post tagged tutorial").
- Focus 2: the two walk fixes' blast radius (revealTake on the LENSES
  model host; pushDecorationsToSink on read-tier/inline editors — the
  controller init is shared).
- Focus 3: TutorialWalkTests' store-outcome assertions vs the prose's
  promises (P-6: is any lesson promising something untested?).
- Focus 4: the N11–N13 routings (were any actually in-scope?).
- Ladder mechanics: fresh reviewer, `notes/REVIEW_PROMPT.md` verbatim;
  this closeout is the anchor.

### For the Stage 3 brief-writer

- New ledger rows N11 (palette stepping), N12 (Write focus on bare
  mode switch — verify unlocked first), N13 (chapters → exportReading;
  a core Queries seam). Confirmed live: N8/AD-8 (T7).
- *(Ladder round 1, NIT-4 — recorded, no headless fix owed):* several
  `TutorialWalkTests` acts execute at the raw ops layer
  (makeBlock/choose/ceremony/extract/merge) rather than through
  registry doors — the unlocked drives own driving those acts through
  the REAL doors (they are the same acts the deferred live list above
  names); the headless store-outcome assertions stay as they are.
- The Stage 3 verification drives should START with the deferred live
  list above (ceremony sheet, drags, selections, typing surface,
  archive recovery, save panels, palette stepping) — an UNLOCKED
  session is the one requirement; the axdrive tool pattern is in this
  session's scratchpad and trivially rebuilt.
- The tutorial is now the acceptance spine: every Stage 3 batch re-runs
  `TutorialWalkTests` for free (suite-level) and should screenshot-walk
  any lesson its theme touches (P-6: a broken tutorial step is a
  regression by definition).
- The dev store's walk residue is one Restore away from pristine.

## Stage 2 ladder — round 1 findings (VERBATIM record; fix pass COMPLETE — dispositions follow the clean bill)

**[MAJOR-A] · `Registry/ShellActions.swift:194` vs
`Features/Tutorial/TutorialSeeder.swift:135–145` · The spoken-confirm
gate keys on a NARROWER predicate than the destruction it gates —
Restore can delete user content with NO confirm.** `restoreTutorial`
consults the confirm only when `existingBookID != nil` (a live reading
named "the field guide"), but `restore()` → `cleanup()` deletes EVERY
post tagged `tutorial` (subtree-wide), every pool named "tutorial
scraps", and every same-named reading — regardless. Concrete path: she
deletes the tutorial book (everything is deletable; lessons survive as
tagged bookless posts) or tags one of HER OWN posts `tutorial` (the
tags lesson teaches the gesture), presses Help ▸ Restore Tutorial… →
`existingBookID == nil` → NO confirm → her content silently tombstoned.
`TutorialSeeder.Existing.isEmpty` (75–77) — the correct gate predicate
— is DEAD CODE, never referenced. Fix: run `discover` ONCE in
`restoreTutorial`, gate the confirm on `!existing.isEmpty`, pass that
same `Existing` into the replace (closes the read-twice TOCTOU too).
Red-on-old pin: seed → delete the book → tag a user post `tutorial` →
`restoreTutorial(confirm: spy)` → assert confirm consulted / user post
survives an unconfirmed call.

**[MAJOR-C] · `Features/ReadTier/ReadPostView.swift:145–168` +
`ReadPostViewModel.swift:71–72,108–121,298–304` · The
starved-decoration-host class (walk fix 2) is fixed only in
`EditorViewModel`; the READ TIER carries the identical mechanism
un-fixed.** Same `lastDecorState` equality gate; `Coordinator.install`
wires `decorSink` with NO push-on-wire; only the EditorViewModel-typed
CONVENIENCE init got `pushDecorationsToSink()` — the read tier uses the
designated init, which pushes nothing. The trigger is documented real
in this very file (`detach()`'s comment: dismantle→remake on the SAME
model happens; the Stage-1 round-1 MINOR reset `loaded`/`slots` for
exactly that cycle but NOT `lastDecorState`) → after a remount with
unchanged content/width the fresh controller renders no
callouts/comments/seams until the next real decor change. The
closeout's Focus-2 premise ("on all controller inits — the init is
shared") is falsified by the code. Fix: same push (or reset
`lastDecorState` in `detach()`); pin over a mounted read surface driven
dismantle→remake; fails on current code.

**[MINOR-D1] · `TutorialSeeder.swift:527` + core `duplicateAsVersion` +
`Shared/AppSession.swift:95–99` · Every seed leaves a stray "Duplicate
as Version" entry on the session structural-undo stack** — her next
unmatched ⌥⌘Z pops an inverse for an act she never performed (toast +
the twin lesson vanishes): the R112 class via the tutorial's own door.
Fix: seed through an Operations facade with `undoStack: nil` (or
snapshot/restore the stack around the seed). Pin: after restore, stack
unchanged; fails on current code.

**[MINOR-D2] · `TakesViewModel.swift:1049–1061` + `LensesBoardView.swift:
164–169` + `WriteTakesPanel.swift:222–223` · `newBlankTakeAsChosen` now
reveals UNCONDITIONALLY on every host** — on a lens column (pick
unchanged → pane never rendered) or the Write panel with no focused
pane (falls to `"takes-main"`, a column the panel doesn't render) the
authority can move onto a pane NO surface hosts → the live ring
silently disappears. The closeout's blast-radius claim is falsified for
this one door. Fix: gate the reveal on host/preferredColumnID. Pin: on
a `.lenses` host, blankChoose from a lens column → `authority.livePane`
names a renderable pane; fails on current code.

**[MINOR-D3] · `TutorialSeeder.swift:88` vs `:44–47` · Cleanup destroys
a WIDER set than the confirm discloses:** `everythingTagged(
includeSubtree: true)` kills a post tagged `tutorial/anything` while
the confirm says "every post tagged 'tutorial'"; the seeder itself only
ever applies the exact tag. Fix: `includeSubtree: false` (matches the
identity), or disclose sub-tags in the copy. Pinnable.

**[MINOR-D4] · `TutorialSeeder.swift:82–84,142–144` · A USER reading
named "the field guide" dies in a restore with NO recovery door**
(readings have no restore — the standing pre-13 boundary; member posts
survive, structure gone permanently); the confirm says "the book
itself" singular while cleanup deletes ALL same-named readings; the
wholesale pin seeds a non-colliding name and never exercises the edge.
Fix (architect's R120 call, recorded): the one-discovery reshape +
confirm-whenever-anything-exists (MAJOR-A) + accurate plural/sub-tag
copy + a collision-case pin; keying stays name-based,
accept-and-document. Pinnable.

**[MINOR-D5] · `TutorialSeeder.swift:110–116` · `findOrSeed` seeds
WITHOUT cleanup** — a book-deleted-but-pool-alive store grows a second
"tutorial scraps" pool (titles aren't unique) and keeps orphaned old
lessons beside fresh ones; only a later Restore heals. Fix: route
find-or-seed through the one-discovery shape — non-empty-but-bookless ⇒
the restore path (with its confirm, per MAJOR-A). Pinnable.

**[MINOR-D6] · `Features/Library/LibraryCatalogView.swift:203–210` ·
the Library "Open the Tutorial" door swallows failure silently
(`try? … findOrSeed`)** while its ShellActions sibling speaks. Fix:
route through `actions.openTutorial()`. Honestly labeled
pin-light (error-path copy): hygiene + consistency.

**NITs:** (1) closeout arithmetic — `TutorialWalkTests` is 34, not 32
(the 530 total is right; the decomposition invented "+1 elsewhere") —
correct the record; (2) `pushDecorationsToSink` inserted mid-doc-comment
in EditorViewModel (2719–2740), splitting `refreshDecorations`' comment
— reunite; (3) the declined-confirm negative poll is vacuous (passes on
first turn) — keep the `stillThere` assert, drop the implied coverage
or make it real; (4) several walk-test "acts" execute at the raw ops
layer (makeBlock/choose/ceremony/extract/merge) not through doors —
recorded for Stage 3's unlocked drive, no fix owed now; (5) the
"user rows byte-identical" pin compares ONE container row — extend to
its blocks/variants (cheap); (6) double-press Restore can race two
discoveries into two live field guides — the one-discovery reshape + an
in-flight guard closes it.

**Verdicts recorded:** judgment calls 1/3/4/5/6/7 SOUND (7 with residue
folding into the one-discovery reshape); call 2 SOUND-in-principle but
under-implemented (MAJOR-A) and over-implemented (D3); call 8 SOUND for
the Takes board, leaky on blankChoose's other hosts (D2). Focus 1 NOT
fully sound (A/D3/D4/D5 are its named edges, live); Focus 2 NOT sound
as stated (MAJOR-C falsifies the shared-init premise); Foci 3/4 SOUND
(N13 verified independently: `reading_section` never reaches export —
core frozen, routing forced).

**Clean bill (abridged):** core byte-untouched (git-verified); Mac
530/0 by the reviewer's own run; the seeder writes through Operations
only (sync-shaped by construction, P2 honored); R57 zero-journal pinned
+ verified read-only against her REAL store (0 journal-shaped rows; her
15+2 untouched; the backup on disk, arithmetic exact); no
denormalization; P1/P3 honored; the registry discipline held incl. the
new act; the A10 absorption residue-free; the choreography + seal
show-and-tell end-to-end on tutorial content; the N9 noteMode caution
needed no extension.

### Stage 2 ladder — round 1 dispositions (fix pass, 2026-07-20; fresh implementer session)

*Every finding traced to its concrete mechanism before disposal; every
bug-class fix carries a red-on-old pin verified by BEHAVIORAL REVERT
(the fix's logic reverted with signatures kept so the pins compile on
both sides, the pin run RED, the fix restored, the full suite re-run
green on shipped code). Three revert batches: REVERT-A = the door
reshape reverted (book-only confirm gate, no latch, blind findOrSeed);
REVERT-B = subtree cleanup + session-ops seeding restored; REVERT-C =
no push-on-wire + the unconditional reveal. New pins live in
`VariorumTests/TutorialWalkTests.swift` (six added to the "Tutorial
doors" suite), `VariorumTests/ReadTierTests.swift` (one), and
`VariorumTests/TakesBoardTests.swift` (one). Counts after the pass:
**Mac 538/106** green (was 530/106) · **core 747/90**,
`Sources/VariorumCore` byte-untouched (git-status-verified — the D1 fix
uses core's EXISTING `Operations(undoStack: nil)` init). Fix commits:
`080d06f` (the door reshape) → `b6f585f` (the read tier's delivery) →
`53c110e` (the reveal gate).*

**[MAJOR-A] — AGREED-FIXED, the one-discovery reshape.** Trace
confirmed exactly as written: `restoreTutorial` consulted the confirm
only when a live reading named "the field guide" existed, while
`restore()` → `cleanup()` destroyed by the full identity (every
`tutorial`-tagged post, every same-named pool and reading);
`Existing.isEmpty` — the correct predicate — was dead code with zero
references. Fix: ONE `discover` per entrance in `ShellActions.
restoreTutorial`; the confirm gates on `!existing.isEmpty`; the SAME
`Existing` is passed into `TutorialSeeder.restore(session:existing:)`
(the read-twice TOCTOU closed — what was confirmed is exactly what
dies); a one-discovery convenience overload serves direct callers.
Pin: `theConfirmGatesOnEverythingTheReplaceDestroys` (seed → delete the
book → tag a USER post `tutorial` → restore with a declining spy) —
REVERT-A (book-only gate, no latch, blind findOrSeed) ran RED with the
smoking gun: `consulted == false` AND her tagged post tombstoned.

**[MAJOR-C] — AGREED-FIXED, the read tier's push-on-wire (badges
included).** Trace confirmed AND found the mechanism reaches one more
field: `ReadPostSurfaceCoordinator.install` wires `decorSink` into the
controller's designated init with no push; `detach()` resets
`loaded`/`slots`/`index` but not `lastDecorState`, so the documented
dismantle→remake cycle recomputes an EQUAL state (same content, same
width) and the equality gate starves the fresh controller — and the
`refreshBadges` `result != badges` gate is the IDENTICAL mechanism one
field over, so the remade surface lost its ⑂ badges too. The
closeout's Focus-2 premise ("the controller init is shared") is
CONFIRMED FALSIFIED — the push lived only in the EditorViewModel
convenience init. Fix: `ReadPostViewModel.pushOverlaysToSinks()`
(badges delivered from stored state; the decor gate re-armed and
recomputed) as `install`'s last act, after both sinks exist — chosen
over a `detach()`-side reset because the push ALSO covers the
attach-before-install nil-sink window (the editor's original trigger),
making wiring itself the delivery in every order; the coordinator
hoisted to file scope (`ReadPostSurfaceCoordinator`, internal) so the
pin drives the REAL install/uninstall path. Pin:
`aRemadeReadSurfaceStillRendersDecorAndBadges` (mount over a real
callout + fan → uninstall → remake same model/width) — REVERT-C (the
push commented out) ran RED on BOTH halves (no `DecorRectView`, no ⑂
on the remade surface).

**[MINOR-D1] — AGREED-FIXED.** Trace: the seed's `duplicateAsVersion`
(the compare lesson's twin) registers a "Duplicate as Version" inverse
on the session stack via `session.runner.run`'s undo-carrying
Operations — one stray entry per seed; her next unmatched ⌥⌘Z would
revert an act she never performed. Fix: `restore(session:existing:)`
runs cleanup + seed through a QUIET facade — `Operations(undoStack:
nil)`, core's existing public init (same ambient database dependency,
same serialized runner turn, no stack; core stays byte-untouched).
Snapshot-restore was NOT chosen: `UndoStack` exposes no snapshot API
and adding one would break the core freeze. Pin:
`theSeederNeverTouchesTheStructuralUndoStack` — REVERT-B (session ops
restored) ran RED: depth 1 after the world's seed, 2 after the second
restore.

**[MINOR-D2] — AGREED-FIXED.** Trace confirmed for both leaky hosts:
on Lenses, `revealTake` lands the ring on (lensColumn, block, NEW
take) while that column renders its unchanged PICK — an unhosted pane,
ring gone; on Write's panel with no focused pane the fallback is
`"takes-main"`, which the panel never renders. Fix: the reveal gated
on host in `revealChosenTake` — Takes keeps the ordinary reveal (the
article pane renders the new chosen; an opened fan renders every
take); Lenses focuses the `.main` column (the one that renders chosen)
and, when none is open, LEAVES the ring where it is (a rendered pane)
rather than moving it onto nothing; the Write panel passes its own
column as the new `preferredColumnID`. Pin:
`blankChooseOnALensesHostKeepsTheRingOnAHostedPane` (asserts
`authority.livePane` ∈ the rendered-pane set computed exactly as the
cells key) — REVERT-C ran RED with the smoking gun visible in the
failure output: livePane named the lens column with the minted take
while that column renders the pick.

**[MINOR-D3] — AGREED-FIXED.** Trace: `discover` collected
`includeSubtree: true` while the confirm said "every post tagged
'tutorial'" and the seeder only ever applies the exact tag. Fix:
`includeSubtree: false` (the identity IS the exact tag) + the copy
states "tagged exactly". Pin: `aSubTaggedUserPostSurvivesTheRestore`
(a `tutorial/keepsake` post rides through a full restore) — REVERT-B
(subtree back on) ran RED: the sub-tagged post tombstoned.

**[MINOR-D4] — ARCHITECT-CALL BUILT (accept-and-document, as
recorded).** The one-discovery reshape + confirm-whenever-anything-
exists landed via MAJOR-A; the copy now discloses the PLURAL
name-based scope ("every pool named …", "every book named 'the field
guide'"); keying stays name-based. Coverage pin (deliberately NOT
claimed red-on-old — the book-exists collision path was already
confirm-gated; the finding's bug halves red under MAJOR-A/D3's
reverts): `aSameNamedUserBookDiesWithTheConfirmedReplaceButItsPosts
Survive` exercises the edge the wholesale pin never did — her
same-named book dies WITH consultation, exactly one live field guide
remains, and her member posts survive (cleanup deletes tagged posts
only; deleting a reading never touches containers).

**[MINOR-D5] — AGREED-FIXED** (folded into the one-discovery reshape
per the findings' own convergence): `findOrSeed` routes a
non-empty-but-bookless discovery through the restore path — cleanup +
confirm — instead of seeding blind beside residue; the truly-empty
store stays a pure fresh seed through the same one shape (cleanup over
an empty discovery is a no-op). `ShellActions.openTutorial` gains the
injectable confirm seam and shares the NIT-6 latch (the two doors
can't race each other either). Pin:
`openOnABooklessStoreWithResidueRestoresInsteadOfDuplicating` —
REVERT-A ran RED with both predicted symptoms live: `pools → 2` (the
second "tutorial scraps") and `tagged → 44` (orphaned old lessons
beside fresh ones), plus no confirm.

**[MINOR-D6] — AGREED-FIXED.** The Library "Open the Tutorial" door
routes through `actions.openTutorial()` (the shell's fire-and-DO body:
failures speak through the StatusCenter, and the door now inherits the
latch + D5's confirm) — `LibraryCatalogView` gains a required
`onOpenTutorial` closure supplied by RootView; the silent
`try? … findOrSeed` is gone. Honestly labeled pin-light as the finding
itself did (error-path copy; the routed body's own behavior is pinned
by the door suite).

**[NIT-1] — AGREED-FIXED ON THE RECORD:** the closeout's arithmetic
corrected by a bracketed correction note under its counts paragraph
(34, not 32; no "+1 elsewhere"; the 530 total stood) — history
annotated, not rewritten.

**[NIT-2] — AGREED-FIXED:** `pushDecorationsToSink` moved out of the
middle of `refreshDecorations`' doc comment in EditorViewModel; each
function now sits under its own whole comment (the split halves
reunited verbatim).

**[NIT-3] — AGREED-FIXED:** the declined-confirm negative poll
(`poll { shell.pendingSelection == nil }` — true on its first turn)
replaced with REAL coverage: a consulted-spy poll proves the gate was
reached, a latch-idle poll proves the door FINISHED declined, then the
`stillThere` + nothing-opened asserts run against a completed door.

**[NIT-4] — RECORD-ONLY, CONFIRMED ROUTED:** the raw-ops walk-test
acts are now named explicitly on the closeout's "For the Stage 3
brief-writer" list (a marked ladder addition) — the unlocked drives
own driving those acts through the real doors; no headless change.

**[NIT-5] — AGREED-FIXED:** the wholesale pin's user-world comparison
extended from ONE container row to the post's full subtree
(placements + blocks + variants, ordered `SELECT *` rows) — still
byte-identical across a restore.

**[NIT-6] — AGREED-FIXED** (folded into the reshape as the findings
converged): the session-scoped in-flight latch
(`AppSession.beginTutorialDoor`/`endTutorialDoor`, checked
SYNCHRONOUSLY at press time so the second press bails before any await
can interleave; session-scoped so parallel test worlds stay
independent — a process-global latch would couple them). Pin:
`aDoublePressedRestoreConvergesToOneFieldGuide` — REVERT-A ran RED
deterministically on `confirmCount → 2` (the old door consulted per
press).

**REAL-store note (the fix-pass rail honored):** the real store was
NOT touched. The already-seeded field guide is data and remains valid —
the seed logic itself is unchanged (identical rows under old and new
seeders), and the one runtime residue the old path left there (the
stray "Duplicate as Version" undo entry) was SESSION-scoped, in-memory,
and died with the graceful ⌘Q recorded in the closeout. Nothing about
the seeded content needs the architect's attention; the fixed doors
simply govern future presses.

**For round 2's fresh reviewer:** the diff unit is `080d06f` +
`b6f585f` + `53c110e` + the dispositions commit, over the round-1
anchor `d80f9e3`. Focus-worthy edges of the fixes themselves: (a) the
latch is per-SESSION — two ShellActions instances over one session
share it by construction (both construction sites hold the session),
and `TutorialSeeder.restore` direct calls (tests, the walk) bypass it
deliberately; (b) `findOrSeed` returns nil on a declined residue
confirm and `openTutorial` then opens nothing — chosen over opening a
lesson-post remnant (there is no book to open; the user said no to
making one); (c) the D2 Lenses no-`.main`-column case keeps the ring in
place and reveals nothing — the mint+choose still happened and speaks
through the projection; (d) `pushOverlaysToSinks` pushes STALE badge
frames at install (correct while geometry is unchanged; a later
`refreshBadges` re-delivers if it differs).

## Stage 2 ladder — round 2 (VERDICT: zero new BLOCKER/MAJOR — the Stage 2 ladder CLOSED at round 2; residual fix pass COMPLETE — dispositions + the sweep tables follow the findings)

The round-2 fresh cold reviewer verified EVERY round-1 disposition HOLDS
(all pins read; the full Mac suite re-run independently: 538/538 green;
`Sources/VariorumCore` byte-untouched git-verified; the fix-diff scope
exactly the four declared commits; the door reshape reviewed WHOLE as a
destructive seam and found honest — one discovery, confirm-gates-what-
dies, tombstones through Operations only, the latch synchronous and
defer-cleared) and SUSTAINED all four flagged notes (a: the latch covers
every app construction site by construction; b: a declined confirm
opening nothing is the user's own Cancel — cosmetic copy note recorded;
c: sustained WITH the silent-corner residue below; d: stale badge frames
at install are geometry-correct, re-delivery traced). Round-2 findings,
verbatim-faithful:

**[MINOR-R2-A] · `TakesBottomBar.swift:76,80,128` +
`TakesShared.swift:91–99` (mounted on Lenses via
`LensesBoardView.swift:67,270,295`) · The D2 class survives ONE DOOR
OVER: the un-chosen mint doors reveal to an unhosted pane on the Lenses
host.** The bar is mounted by BOTH boards; its ＋New/＋Blank/"+ take"
doors and the cell context-menu twins call
`branchTakeRevealed`/`newBlankTakeRevealed` unconditionally; on Lenses
the mint changes neither the column's pick nor chosen, so no column
renders the revealed pane — ring vanishes, take appears nowhere;
inconsistent with the same board's own keyboard doors (which route
pick-into-column and are visible by construction). Fix: host-gate the
Revealed brains as `revealChosenTake` was gated — on `.lenses`, route
through the board's pick-into-column semantics. Pin: the D2 pin's exact
shape over the bar door; reds on current code.

**[MINOR-R2-B] · `EditorView.swift:480–484` +
`EditorViewModel.swift:2713–2716` · The starved-host class survives on
the editor's BADGE sink — the LAST un-fixed field of the mechanism
MAJOR-C closed.** The read tier got both fields (decor + badges); the
editor got only decor. `BadgeOverlayController.init` wires
`model.badgeSink` with no push; `attach` neither resets `badges` nor
forces delivery; `refreshBadges` carries the same equality gate; both
editor representables build fresh coordinators over possibly-loaded
models → a freshly-wired overlay shows no ⑂ until a real badge/viewport
change (a fully-visible short post never gets one). Fix: deliver stored
badges at wire time, symmetric with the read tier. Pin: the read-tier
pin's badge half over the editor's real install path; reds on current
code.

**[NIT-R2-C] · `TakesViewModel.swift:1075–1084` · blankChoose on a
Lenses host with NO `.main` column is a visually silent success** when
every open column holds an explicit pick for the block — nothing visible
changes and nothing speaks, against fire-and-speak. One spoken line in
the no-main branch; fold into the R2-A fix.

**[NIT-R2-D · SPECULATIVE, RECORD-ONLY] · the discovery→confirm→restore
window is open to SYNC, not to the user** (an apply landing a
tutorial-tagged row mid-modal survives cleanup and the seed mints beside
it — two field guides until the next Restore heals). Single-device
today; pin-impossible without a contrived apply-mid-modal harness;
recorded, no fix owed.

**Architect's routing:** R2-A + R2-B + R2-C → the residual fix pass NOW,
with a CLASS-COMPLETENESS SWEEP obligation: enumerate every door that
calls a reveal brain (× hosts) and every equality-gated overlay sink
(× hosts), verify each is either fixed or provably safe, and record the
enumeration in the dispositions — the ladder has now caught two
adjacent-door survivals of fixed classes; the sweep ends the pattern.
R2-D stays record-only. The cosmetic notes (b's confirm copy;
exportCaretBlock's tail phrasing from Stage 1) ride Stage 3's polish
themes.

### Stage 2 ladder — round 2 dispositions (residual fix pass, 2026-07-20; same fix-pass session)

*Every finding traced before disposal; every bug-class fix red-on-old by
behavioral revert (signatures kept; pins run RED; fixes restored; full
suite green on shipped code). Counts after the pass: **Mac 542/106**
green (was 538/106; +4 pins, one existing pin strengthened) · **core
747/90**, `Sources/VariorumCore` byte-untouched (git-verified). Fix
commit: `f4f3ae5`. Revert batches: REVERT-R2a = the host gates + the
fan-namespace mapping + the no-op-guarded divergeHere + the silent
no-main branch restored to pre-fix logic; REVERT-R2b = the badge push
commented out.*

**[MINOR-R2-A] — AGREED-FIXED, and the sweep widened it.** Trace
confirmed: the bar's ＋New/＋Blank/"+ take" doors and the cell-menu
twins call the Revealed brains unconditionally; on `.lenses` the mint
changes neither pick nor chosen, so `revealTake` focused a pane no
column renders. Fix: `branchTakeRevealed`/`newBlankTakeRevealed` are
HOST-GATED like `revealChosenTake` — `.lenses` resolves a real column
(the cell menus now pass theirs; the bar falls back to the focused
pane's; none ⇒ the spoken `lensesMintNeedsColumnNote`, matching the
keyboard doors' own guards) and routes through the board's
pick-into-column cores (`branchIntoColumn`/`blankIntoColumn` — the
`divergeHere` body extracted and shared; named lenses live-edit in the
same serialized breath; a mint into the Chosen column starts a scratch
thread, chosen never moves without ✓) with the ring FOLLOWING onto the
pane that now renders the mint. The Lenses keyboard ⌥⌘T consolidates
onto the same brain — its old mint-then-`pick` pair REFUSED the pick on
the Chosen column AFTER minting (an invisible take plus a lecture, the
R112 class, fixed by the consolidation). **The sweep's own finds, fixed
with the class:** (1) on the TAKES host an article-keyed reveal
stranded the ring's AUTHORITY on `("takes-main", block, mint)` — a pane
NO style renders (the article renders chosen only; an un-chosen mint
blooms as a FAN card) — `takesUnchosenRevealColumnID` maps
article/landing keys onto the fan namespace (`takesFanColumnID` hoisted
to the model; the view aliases it); (2) `divergeHere` from the takes
board's cell menu was a SILENT NO-OP (board-local column IDs never live
in `columns`; the index guard returned before minting anything) — now
host-gated: the takes arm routes through the takes reveal. Pins:
`barMintDoorOnALensesHostLandsInTheFocusedColumn` (REVERT-R2a RED
twice — the lens pick unmoved AND the ring on an unhosted pane),
`divergeHereFromTheArticleCellMintsOnTheTakesBoard` (RED: `minted →
nil`, the silent no-op live), and the round-1
`branchOnAClosedFanRevealsTheNewTake` STRENGTHENED with a full-key
assert (RED: livePane on `takes-main`).

**[MINOR-R2-B] — AGREED-FIXED.** Trace confirmed: the read tier got
both fields, the editor only decor — `BadgeOverlayController.init`
wired with no push; nothing resets `badges` at attach; the
`result != badges` gate starves a fresh host over a loaded model, and a
fully-visible short post never produces the un-starving change. Fix:
`EditorViewModel.pushBadgesToSink()` called from
`BadgeOverlayController.init` after wiring — symmetric with the decor
twin and the read tier; stored badges are geometry-correct until the
next real change re-delivers (the round-2 reviewer's sustained note d).
Pin: `aFreshlyWiredBadgeOverlayShowsTheFans` (the choosing lesson's
rain fan; stored badges asserted non-empty BEFORE the wire) —
REVERT-R2b ran RED (no ⑂ on the wired host; the sibling decor pin
stayed green — the fields are independent, which is exactly why this
one survived round 1).

**[NIT-R2-C] — AGREED-FIXED** (folded into R2-A as routed): the
no-`.main` branch of `revealChosenTake` speaks — "Chosen — the post now
shows the new blank take; add a \u{201C}Chosen (the post)\u{201D} column to see it
here." Pin: `blankChooseWithNoChosenColumnSpeaks` — REVERT-R2a ran RED
(`statusMessage` nil, the silent success live).

**[NIT-R2-D] — RECORD-ONLY, as routed.** No action; the
apply-mid-modal window stays on the record (single-device today;
pin-impossible without a contrived harness).

**THE CLASS-COMPLETENESS SWEEP (the architect's addition, executed):**

*Table (a) — every reveal-brain door × every host that can mount it.
Verdicts: FIXED-R1/FIXED-R2 (pin named) or SAFE (why, one line).*

| Door → brain | Takes host | Lenses host | Write panel |
|---|---|---|---|
| Bar block-menu ＋New + "+ take" → `branchTakeRevealed` (no preferred) | FIXED-R2 — article/landing keys map to the fan namespace (strengthened `branchOnAClosedFanRevealsTheNewTake`) | FIXED-R2 (`barMintDoorOnALensesHostLandsInTheFocusedColumn`) | — (bar not mounted) |
| Bar block-menu ＋Blank → `newBlankTakeRevealed` (no preferred) | FIXED-R2 — same host-gated brain as ＋New (one body, the pins cover the gate) | FIXED-R2 — same brain | — |
| Bar ＋Blank-as-chosen → `newBlankTakeAsChosen` | SAFE — the mint IS chosen; the article renders it (`revealChosenTake` .takes arm; round-1 D2 disposition) | FIXED-R1 (`blankChooseOnALensesHostKeepsTheRingOnAHostedPane`) + FIXED-R2 speak (`blankChooseWithNoChosenColumnSpeaks`) | — |
| Takes keyboard ⌘T/⌥⌘T (preferred = pane.columnID) | FIXED-R2 — `takes-main` maps to the fan namespace; `takes-fan` renders the mint directly | — (routes to the Lenses handler there) | — |
| Takes keyboard ⇧⌥⌘T | SAFE — chosen mint, article renders it | — | — |
| Growth doors (`newTakeDoors`, takes board only) → both Revealed brains (no preferred) | FIXED-R2 — same host-gated brains | — (not rendered) | — |
| Cell menu ＋New/＋Blank (both boards; now preferred = column.id) | FIXED-R2 — `takes-main` cell maps to fan | FIXED-R2 — the cell's own column adopts the pick | — (panel renders its own cards, not `TakesCellView`) |
| Cell menu "Diverge here" → `divergeHere` | FIXED-R2 (`divergeHereFromTheArticleCellMintsOnTheTakesBoard` — was a silent no-op) | SAFE — `branchIntoColumn` + ring-follow (the R2-A core; the bar pin exercises it) | — |
| Lenses keyboard ⌘T → `divergeHere(pane.columnID)` | — | FIXED-R2 — ring-follow added in the shared core (previously stranded on the replaced key) | — |
| Lenses keyboard ⌥⌘T | — | FIXED-R2 — consolidated onto `newBlankTakeRevealed` (old pair minted then REFUSED the Chosen-column pick) | — |
| Lenses keyboard ⇧⌥⌘T | — | FIXED-R1 + R2-C | — |
| Panel growth doors (branch/blank → direct mint + `focus(column.id)`; blank&choose → preferred = column.id) | — | — | SAFE — the panel renders EVERY fan take keyed `column.id`, so any of its focuses is hosted (round-1 D2 gave blank&choose the preferred column) |
| `addBlockAtEnd` → `consumeLandings` pendingFocus | SAFE — focuses the new block's CHOSEN variant; the article renders it (pin `addBlockAtEndMintsAndHandsTheRingOver`) | SAFE — sparse picks can never cover a brand-new block, so every column resolves it to chosen (hosted) | — |
| `consumeLandings` bloom/N9 landing focus | SAFE — keys (takes-main, block, chosen) = the article | SAFE — `landingEnabled` is set ONLY by `TakesBoardView`; the landing half never runs on the Lenses host (grep-verified) | — |
| Canvas ‹ › switcher | SAFE — view-local viewing state; calls NO reveal brain (grep-verified) | — | — |

30 door×host cells enumerated: **15 FIXED** (11 across rounds 1–2 with
8 named pins + the strengthened round-1 pin), **15 SAFE** with the
mechanism stated. **One recorded residual (cosmetic, Stage 3 polish):**
on a LONG open fan the revealed fan card may sit on a later PAGE of the
carousel/rail — the fan is open, the counter ticks, and the ◀ x–y of
n ▶ pager advertises it, so this is not the silent-vanish class; an
auto-page-to-the-mint is a polish call for Stage 3's takes theme.

*Table (b) — every equality-gated overlay sink × every wiring path
(grep-verified complete: the app has exactly these four sink fields and
these six construction/wiring sites; no other gated delivery exists).*

| Sink · gate | Wiring path | Verdict |
|---|---|---|
| `EditorViewModel.decorSink` · `lastDecorState` equality | `BlockDecorOverlayController` convenience init (BlockDecor.swift:224) ← EditorView FULL coordinator install | FIXED-R1 walk fix 2 — `pushDecorationsToSink` in the one shared init (pin `aFreshlyMountedEditorRendersTheCalloutFrame`) |
| same | ← INLINE coordinator install (same convenience init) | FIXED-R1 — same single wiring point |
| `EditorViewModel.badgeSink` · `result != badges` | `BadgeOverlayController.init` (EditorView:483) ← BOTH editor coordinators | FIXED-R2 — `pushBadgesToSink` (pin `aFreshlyWiredBadgeOverlayShowsTheFans`) |
| `ReadPostViewModel.decorSink` · `lastDecorState` equality | `ReadPostSurfaceCoordinator.install` | FIXED-R1 fix pass (MAJOR-C) — `pushOverlaysToSinks` (pin `aRemadeReadSurfaceStillRendersDecorAndBadges`) |
| `ReadPostViewModel.badgeSink` · `result != badges` | same install | FIXED-R1 fix pass (MAJOR-C) — same push, the pin's badge half |

5 sink×path cells: **5 FIXED**, 0 remaining. Every sink in the app now
delivers at wire time — the starved-host class has no un-pushed field
left, and table (b)'s grep is the completeness proof.

## Stage 2 closeout (stage-level, 2026-07-20 — written at ladder close for the Stage 3 brief-writer and the end-checkpoint walk)

**STAGE 2 CLOSED.** The tutorial spine (R113/P-6) is built, walked,
twice-cold-reviewed, and hardened: the ladder closed at round 2 with
zero new BLOCKER/MAJOR; the round-1 fix pass (2 MAJOR + 6 MINOR + 6
NIT) and the round-2 residual pass (R2-A/B/C + the class-completeness
sweep) are fully dispositioned above, every bug-class fix red-on-old by
behavioral revert.

**Counts trajectory:** Mac 499/100 (Stage 1 close) → 530/106 (the spine
+ walk fixes) → 538/106 (round-1 fix pass, +8 pins) → **542/106 final**
(round-2 residuals, +4 pins + one strengthened). Core **747/90
byte-untouched across the entire stage** (git-verified at every pass —
the seeder writes through existing Operations only, including the
quiet `Operations(undoStack: nil)` facade). `/Applications/Variorum.app`
refreshed from Release at each pass.

**The tutorial's final shape:** "the field guide" — a curated book of
the app's own objects (6 real chapters · 21 act-ready `.generic`
lessons, every one tagged `tutorial`, `word_target` 4000), plus the
version twin, the "tutorial scraps" pool (one fanned scrap), and the
sealed lesson. Seeding is a product door hardened by the ladder: Help ▸
Restore Tutorial… runs ONE discovery, confirms whenever ANYTHING the
replace destroys exists (exact-tag, plural name-based scope in the
copy), replaces exactly what was confirmed, never touches the
structural-undo stack, and converges under a double press (the session
latch); the open entrances route bookless residue through the same
confirmed restore. The tutorial is seeded in her REAL store (data
unchanged by the fix rounds — the fixed doors govern future presses)
and `TutorialWalkTests` (now 41 across its suites — counted, not
derived) is the permanent acceptance layer: every Stage 3 batch re-runs
it for free.

**Classes ended this stage (the ladder's arc):** the
confirm-gate-narrower-than-destruction seam (MAJOR-A's reshape); the
starved-overlay-host class — ALL five sink×path cells now deliver at
wire time (sweep table b: 5/5 FIXED, grep-complete); the
ring-on-an-unhosted-pane class — 30 door×host cells enumerated, 15
fixed / 15 provably safe (sweep table a), including the sweep's own
finds (the article-keyed reveal strand; `divergeHere`'s silent no-op on
the takes board; the Lenses ⌥⌘T mint-then-refused-pick).

**What Stage 3 inherits:**
- **The unlocked-drive list FIRST** (the locked-session remainder from
  the walk): the ceremony SHEET on-screen, precise selections
  (extract/make-block at the staged spans), typing/crystallization's
  surface half, archive recovery through Write's panel, all drags
  (scrap → draft, canvas cards, chapter reorder), save-panel exports,
  the Restore confirm's Replace press, palette ↓-stepping — plus the
  two blank utility windows at launch (identity unestablished) and the
  N12 verify-unlocked item.
- **Ledger rows:** N11 (palette keyboard row-stepping), N12 (Write
  focus on a bare mode switch — verify unlocked first), N13 (chapters
  never reach `exportReading` — a core Queries seam, routing forced).
  Confirmed live: N8/AD-8 (T7).
- **The raw-ops walk-test acts** (round-1 NIT-4): drive
  makeBlock/choose/ceremony/extract/merge through the REAL doors at the
  unlocked drives; the headless store-outcome assertions stay.
- **Cosmetic/copy notes riding Stage 3 polish themes:** the
  declined-confirm copy note (round-2 sustained note b);
  `exportCaretBlock`'s open-tail phrasing (Stage 1); the
  auto-page-to-the-mint call (sweep table a's recorded residual — a
  revealed fan card can sit on a later page of a long fan's pager).
- The dev store's walk residue remains one Restore away from pristine;
  the R2-D speculative record (sync landing mid-confirm-modal) stays on
  file for the eventual multi-device era.

## Stage 3 execution brief (self-contained — authored just-in-time 2026-07-20 by the successor architect session at the Stage 2/3 handoff cutover; per batch, read: this brief + the constitution + the Stage 1/2 stage-level closeouts + the running ledger + the named batch inputs; nothing else assumed)

**Goal:** burn down the ratified backlog's Stage 3 themes and complete
the coverage the locked-session walks couldn't reach. At close: no
unowned open ledger rows, the tutorial green (P-6), every batch
screenshot-verified against the app itself, the ladder closed — then the
ONE R121 end checkpoint assembles.

### Environment state at authoring (verified 2026-07-20 18:16; binding until observed otherwise)

A LIVE REAL-STORE instance is running: **pid 20720, path
`~/Library/Developer/Xcode/DerivedData/Variorum-*/Build/Products/Release/
Variorum.app`, launched 16:40:47 — AFTER the founding session's 15:33
handoff commit.** Nothing in the record launched it, so it is treated as
THE AUTHOR'S OWN session (Launch Services can resolve "Variorum" to the
DerivedData Release copy; it holds the real store open —
`Application Support/Variorum/variorum.sqlite`, lsof-verified — and its
bytes are the same final Stage 2 build `/Applications` carries; the
15:32 refresh copied FROM this product). Also resolved on the record:
the Stage 2 backup name `175038` is UTC (≈11:50 MDT — pre-ladder,
consistent with the closeout's ordering; no anomaly).

**Rules while ANY real-store instance lives (whether `/Applications` or
DerivedData Release):**
- NEVER quit or kill it — it is the author's live session; the standing
  "/Applications instance" prohibition covers it by store, not by path.
- NO Mac `xcodebuild test` runs (a live instance fails the runner —
  Runningboard error 5; the standing trap).
- **NO Release builds** (NEW trap, this brief): `xcodebuild
  -configuration Release build` writes into the very bundle the live
  instance is executing from — mutating a running app's signed bundle on
  disk is a crash/kill class. No `/Applications` refresh either (it
  builds Release first). Skip and RECORD; the next unblocked batch
  refreshes.
- `swift test` (core) and Debug builds are unaffected.
- Check `pgrep -fl Variorum` before EVERY build/test step, every batch.
  A Debug dev-store instance from our own drives stays quittable per the
  standing rule (path- and pid-verified first).

**Batch order rule:** 3A (the drive) is Stage 3's first item BY
PRIORITY, but it requires an unlocked, author-free session with zero
real-store instances. Until the environment allows it, 3B (blocked by
nothing — core-side by construction) runs first. The orchestrator
sequences 3C → 3D → 3E → 3F/3G around the drive, inserting it at the
first opening; drive findings route per the Stage 2 triage rule
(happy-path breaker → fix in-batch with a pin; known ledger row →
verify + design around honestly; new defect → new ledger row).

### Batch 3A — the unlocked verification drive (a drive session; fixes only for happy-path breakers, each red-on-old)

**Preconditions:** zero Variorum instances (pgrep); an unlocked session
verified EMPIRICALLY (deliver a synthetic event and confirm its effect —
the locked-session signature is events swallowed / clicks undelivered);
own `caffeinate -d`; Debug dev-store build, pid/path/store verified; the
axdrive pattern from the Stage 0(c)/Stage 2 walks (CGEventPostToPid +
menu-path AXPress + window-scoped `screencapture -l`), rebuilt from the
recorded pattern.

**Contents (the Stage 2 closeout's inherit list, verbatim-faithful):**
1. The ceremony SHEET on-screen end to end: fan a block, divide from
   Takes (the choreography), the sheet's checklist / per-take cut
   placement / uncheck / Confirm / Cancel — the store half is pinned;
   this is the surface half (and the author's R116 parenthetical made
   the sheet's real-world visibility a first-class question).
2. Precise selections: extract + make-block at the staged spans in the
   field guide's lessons.
3. Typing/crystallization's surface half: type past a paragraph → the
   mint; the idle-mint; the N9 landing typed live (re-verify unlocked).
4. Archive recovery through Write's takes panel (the current honest
   road — pre-3D truth).
5. All drags: scrap → draft (plain and ⌥ fan-carry), canvas cards,
   chapter reorder in the book navigator.
6. Save-panel exports (post/book/block through the real NSSavePanel;
   TCC prompts get RECORDED, never worked around).
7. The Restore confirm's Replace press — on the DEV store, whose walk
   residue makes the confirm + wholesale replace a real exercise.
8. Palette ↓-stepping (expected missing — N11's live evidence).
9. **N12 VERIFY:** bare ⌘1 into Write, then type — is the caret claimed
   in a normal session? Verdict updates the ledger row (fix lands in
   3E, or falls out if the lock was the whole story).
10. **The two blank utility windows at launch:** establish identity
    (AX + `CGWindowListCopyWindowInfo` — owner, class, layer) or record
    precisely what resists identification.
11. The NIT-4 raw-ops acts driven through the REAL doors:
    makeBlock/choose/ceremony/extract/merge as the user would reach
    them.
12. **The author's night-of items (2026-07-21, rows N14–N17):**
    reproduce N14 (choose a take in Write's panel; watch the ⑂ badge
    for the doubled/layered button; capture it); N15 evidence capture
    (the book-inline bar at default width); N16(a) verify (in the
    ceremony, a take with 2+ interior sentence boundaries must accept
    the cut at ANY of them, not just the proposed one); N17(a) verify
    (does the merge-folds-a-fan toast SPEAK on her path — book-inline
    included?); N17(c) the lineage-road hunt (after a fanned merge,
    what UI path — if any — reaches the pre-merge takes: unplaced
    blocks? compare/outline lineage? undo only? Record the honest
    answer step by step).

**Output:** a "Batch 3A drive log" section in this file (per-item
verdict + screenshot refs; screenshots to a gitignored
`phase-13b-stage3-screens/` dir), ledger updates, pins for anything
fixed. No build work beyond breaker fixes.

### Batch 3B — the core seam (fresh implementer; the stage's ONE sanctioned core-touch batch)

`Sources/VariorumCore` changes are allowed in THIS batch only —
sanctioned by the ratified Stage 0 verdict ("Core Operations: ADD two
small ops/faces") and the N13 routing. Own commits per the schema/model
convention (no schema changes exist here — additive query/op work only,
so NO §12 lockstep event); `Sync/` untouched a fortiori; the mobile
target must still build.

1. **N13 — chapters reach export.** `assembleReading` gains
   `reading_section` resolution for CURATED books: each membership's
   `section_id` resolves to its live section; dangling/tombstoned ⇒
   unsectioned (the ratified read-time rule, AppSpec §7); smart books
   keep grouping-tag sectioning UNCHANGED (byte-identical assembly,
   pinned). **Mirror the shipped book-view presentation semantics —
   ordering by section `position`, where unsectioned posts land, empty
   sections — so the export matches what the book view shows; read the
   BookView/navigator's rules from code first and cite them in the
   closeout; do not invent a second sectioning truth.** `exportReading`
   renders the resolved chapters through its EXISTING sectioned-output
   shape (the smart-book sectionPath path) — a chaptered curated book
   exports with chapter headings. Tests: curated assembly (ordering,
   dangling ⇒ unsectioned, empty sections, smart-book byte-parity) +
   export (headings present; every existing export pin green). The
   tutorial's export lesson honesty note updates ONLY if its promise
   text changes — the walk test owns the assertion either way.
2. **T5's core op — `setTakeLabel(variant, label)`.** The Stage 0
   verdict's missing setter (column + renderers exist). Follow the
   `setBlockName` precedent: identity-level metadata — no-op guard, no
   touch/churn, `updated_at` stamped, nil/empty clears to NULL, refuses
   under a sealed post (the seal refuses everything under the post —
   Phase 2's ratified scope), allowed on a LOCKED take (lock freezes
   the BUFFER, not metadata — record as a PROVISIONAL judgment call for
   the walk). Metadata-CAS under sync, no uniqueness, no repair class.
   Exact state-transition tests per the operations conventions.
3. **Confirm-and-record:** `renameLens` exists in core (11a) — the 3D
   face needs no core change; state where it lives.

**Verification:** full `swift test` green; core count grows from
747/90. The Mac suite CANNOT run while the live real-store instance
holds — RECORD the exact commit at which the Mac re-run is owed; the
first unblocked moment runs the full Mac suite BEFORE any further
Mac-side work builds on this seam.

### Batch 3C — N10, the one-seam move (fresh implementer; the stage's riskiest batch — behavior parity absolute)

1. EditorViewModel's gesture-execution band (`applyStructural`, the
   compounds, the W state machine, `runStructural`) and the projection
   executors (`renderFull`/`applyDifferential`) move TOGETHER into an
   editor-feature controller — a sibling under `Features/Editor/`,
   NEVER the shared Registry layer (storage-coupled code stays
   feature-side; both 1a/1b closeouts recorded this seam). EVM keeps:
   composition, crystallization (verbatim), decoration/badge geometry,
   and the `viewText`/`programmaticReplace`/`setBlockAttribute` surface
   plumbing (the storage owner keeps its plumbing — the 1a call).
2. The TakesViewModel P-9 decomposition (~1,240 lines): split by
   concern (board layout/paging · choreography/landings · the rest);
   the implementer proposes the seams FROM the code and records them.
3. **Parity is the contract:** every existing pin stays green
   UNMODIFIED (they are the parity proof; a pin edit is a red flag the
   closeout must justify line by line); the board soak re-runs; zero
   user-visible changes; no features smuggled inside the refactor.

Blocked while the live instance holds (needs the Mac runner) —
scheduled at the first unblocked window.

### Batch 3D — T5 takes lifecycle faces (may share a session with 3E)

1. **Archived takes become visible + recoverable in-mode** (N1's
   vanish trap dies): a door on the Takes surface reveals archived
   takes (design within the v2 card grammar; the fans query stays
   active-only — the archived listing is its own read), with unarchive
   as the act; ⌘⇧A speaks where the take went. R118: the road back
   lives in Takes, not just Write's panel. AD-4's archived-road-back
   half closes with it.
2. **Take-label face** (3B's op gets its door): card context menu +
   bar block-menu; labels already render on cards.
3. **Lens-rename face** (op exists): the Lenses column-header menu.
4. Registry: the new acts declared (unarchive/label/lens-rename) with
   doors, availability, honest notes; the walk grows; every new door
   fire-and-DOes.
5. **The tutorial keeps pace (P-6):** the "keeping takes safe" lesson's
   honest routing note dies — the lesson teaches the real road back;
   seeder + walk tests updated. (The REAL store's seeded book goes
   stale with every lesson edit — the end checkpoint re-seeds behind
   the A1 rail; recorded there.)

### Batch 3E — T6 book view + N11 (+ N12 if verified)

1. **D1:** collapsing the focused post releases/moves focus (the traced
   `BookView.swift:545` force-expand disjunct; red-on-old pin);
   collapse-all correctness; `BookFocusState` folds into the one focus
   model (the Stage 0 verdict).
2. **N11:** palette keyboard row-stepping — `selectedIndex` + ↓/↑ +
   ⏎ runs the SELECTED row; the › marker moves; red-on-old pin
   (⏎-always-first is the old truth).
3. **N12** (if 3A verified it real): the bare mode switch into Write
   claims the caret — the N9 landing pattern applied to Write's
   arrival; pinned. If 3A found the lock was the whole story, the row
   closes as environment-artifact with the drive log as evidence.

### Batch 3F — T7 geometry/spacing + copy notes (may share a session with 3G)

1. **D2 — TRACE FIRST** (the hallucination guard; two recorded
   candidates: `TakesBoardView.swift:315–319` +
   `PostDetailView.swift:70–75` reading one UserDefaults key two ways;
   `fanToggleRow` rendering above every block incl. unfanned). Fix the
   traced mechanism; pin where pinnable; screenshot-verify the margin
   grid no longer shifts the article.
2. **N8/AD-8:** margin comments clip UNDER the sidebar at default
   width — geometry fix within R7's margin-default language (clamp,
   flip, or reflow; the implementer designs and records).
3. **AD-7:** margin-grid wash slabs (~2/3-empty cells) — the ballooning
   mechanism traced and fixed.
4. **The crowdedness pass** (R112's named half; bounded): the worst
   instances from the Stage 0(c) inventory + the 3A drive, addressed
   with restraint; before/after screenshots.
5. **Memo polish halves:** the Write seam-hover affordance (merge
   memo — build if it earns its place in this pass, else record
   against its memo); the ceremony cut-placement polish (only if
   cheap). NOT owed: the merge above/below pair and the divide hint —
   their memo revisit-conditions stand untripped.
6. **Copy notes:** the declined-residue-confirm copy (round-2 note b);
   `exportCaretBlock`'s tail phrasing (check the shipped copy;
   improve or record no-change-needed); **auto-page-to-the-mint** on
   long fans (sweep table (a)'s recorded residual).

### Batch 3H — RESTRUCTURED 2026-07-21 (the author's direction: "we should have the plan sorted out now for what you said would be in 3H, while it can be part of stage 4")

**The restructure:** the memo addenda are AUTHORED NOW by the architect
— `phase-13b-memo-w-ceremony.md` "Addendum: the cut, redesigned" and
`phase-13b-memo-merge.md` "Addendum: the merge ceremony" — and the
BUILDS move to **Stage 4**, which opens author-attended: she starts a
fresh implementer session and discusses goals/tradeoffs at its kickoff
(the addenda are that conversation's basis; R120's self-execution is
SUPERSEDED for these two designs by her stated attendance — the
tradeoff lists in each addendum are the agenda). What old-3H leaves IN
Stage 3: the canon-preserving lineage-road TOAST COPY (name the
Library → Archived & Deleted → Unplaced blocks road in merge's speech)
and N18's lesson-prose honesty → both ride 3F's copy notes; the snap
semantics change itself is Stage 4's. Stage 3's remaining batches are
therefore 3F → 3G → the ladder.

*(The original 3H scoping, kept for the record below — its items now
route per the restructure.)*

### Batch 3H (original scoping, superseded — see the restructure above)

The author's findings N16/N17 get root-cause treatment, her explicit
process demand: "really consider the root cause of these issues and
give thorough solutions… it can be its own phase if it needs to be."
1. **The W-memo interaction addendum FIRST** (plain language, R120
   self-executing): the sheet's cut-placement interaction designed
   whole — why the current click-to-place clamps or appears to
   (N16a's trace decides bug vs design), an all-takes-at-once
   placement surface, the draggable scissors affordance, keyboard
   placement, and what "no legal spot" looks like. Then the build,
   pinned; the ceremony's store semantics (divideW) are UNTOUCHED.
2. **The merge-memo round-trip addendum:** the divide-then-merge
   symmetric case laid out with options and consequences (status quo +
   unmissable speech · lineage-aligned fan zip · other). NO build
   beyond a traced fire-and-speak fix if N17a shows the toast silent —
   merge semantics are canon and the ruling is the author's at the end
   checkpoint.
3. **Also recorded here, no build:** her cut-granularity question
   (cuts snap to sentence boundaries — canon: the block floor is a
   sentence; she noted "i guess it does actually work so that's good")
   goes on the checkpoint conversation list, not the backlog.

Sequenced after 3F (its fixes ride the same overlay/geometry
verification drives) and before 3G (looks-polish stays LAST per R111).

### Author additions (2026-07-21 afternoon — verbatim-faithful, routed; her sequencing directive: "finish these batches first… only handle these fixes / stage 4 plans / etc. in ways that are architecturally consistent")

**3F scope grows (margin grid):** N23 (the scroll bug — inaccessible
take content) and N25 (the extra ✓ on the chosen take) join D2/N8/AD-7;
her DESIGN INPUTS for the grid recorded: non-chosen takes "use the full
size of the box… a little bit wider and show the option better", and
chosen-marking becomes "a header where you would click on it to mark it
chosen… without making the box of text less wide."

**3H scope grows (her structural-design inputs — the memo addenda now
carry her direction, not just options):**
1. **A MERGE CEREMONY** (her sketch): "if you're merging two blocks
   with takes, there should be something like the W ceremony but for
   keeping the takes of your two blocks. Maybe instead of having
   scissors, there is a + that you move around?" — the W's mirror,
   designed whole in the merge-memo addendum (with the N17 round-trip
   and the lineage-road naming); semantics changes remain HER
   checkpoint ruling, but the design now aims at her sketch.
2. **The join without sentence punctuation:** merge "should account for
   merging two blocks that don't have periods or other sentence
   markers" — the join-character rule (space vs newline vs nothing)
   designed for outline-ish content; memo edge.
3. **DIVIDE GRANULARITY RELAXED (her ruling, uncertainty preserved):**
   "we should allow divide even if it's not on a sentence… or do we
   allow cuts on newlines too? I think if we allow cuts on new lines
   that would be fine, but tbh I don't see why we wouldn't allow a
   divide with only a word left there, given that a block is at minimum
   one character." Newlines are her floor; her lean is word-level
   freedom. The memo settles the exact snap rule (word-edge snapping vs
   none; refusal cases); this supersedes the sentence-only reading of
   the ratified snap-and-proceed contract BY HER DIRECTION — the
   boundary-snapping change is core Domain work, SANCTIONED as 3H's
   core allowance (own commits, exact tests, no schema; the Stage 3
   brief's "core only in 3B" line is amended by this paragraph).
4. **End-of-block cut = no second half for that take:** "if you put the
   cut marker at the very end of the block, it's clear that the W
   ceremony won't mint a 2nd block for that take" (her 2-paragraph vs
   1-paragraph example) — a divideW semantics addition (a take whose
   cut sits at its end contributes a first half only), memo-designed,
   core-sanctioned under the same allowance.

**### Stage 4 stub (recorded at her request — "I think I'm going to
want a stage 4"; scoped AFTER this stage's batches + ladder. PROCESS,
her 2026-07-21 direction: Stage 4 opens AUTHOR-ATTENDED — she starts a
fresh implementer session and discusses goals/tradeoffs at kickoff; the
two memo addenda authored 2026-07-21 are the opening material):**
- **The memo builds (moved here from 3H):** the cut redesign
  (draggable ✂, word-edge cuts + newlines, end/start-of-take
  semantics, all-takes-at-once placement — the W memo's addendum;
  includes the `BoundarySnapping` core change, own commits) and the
  MERGE CEREMONY (pairing ＋, carry/leave, join preview — the merge
  memo's addendum; its semantics extension is HER ruling at the
  kickoff).
- The OUTLINE post's utility — "go into the utility of outline post…
  and make some changes there."
- The CANVAS view mode — same directive.
- **EDITING IN COMPARE:** "you should be able to actually edit the
  posts in compare, otherwise the compare view is not actually
  particularly useful except for seeing what the difference is." Her
  own caution recorded verbatim: "i know we recently unified our text
  editing surface and I do not want to go back to that class of bugs,
  so defer it to stage 4 if that's a change that needs more time" —
  the architect concurs: cross-POST live editing extends the
  PaneTextAuthority's one-live-ring contract across post contexts;
  Stage 4 designs it on the authority, never beside it.
- Takes-side block drag-reorder (N26's design half, pending the
  verify).
- D1 status note: her "collapsing a post you extended is [still not]
  working" report arrived while 3E was in flight and unlanded —
  expected; D1 remains 3E's.

### 3F trimmed / 3G retired (author-raised 2026-07-21, architect's recorded call): 3F proceeds NOW but trimmed — it is defect-shaped (the overlay cold-mount substrate bug N14 gates everything Stage 4 builds on; the grid scroll bug N23 hides content — functionality by R111's own standard) and its surfaces barely intersect Stage 4's rework list (ceremony/merge sheets, outline, canvas, compare). The broad crowdedness pass SHRINKS to the named instances (N15 + the drive's worst cells) — sweeping subjective judgments wait for her presence at the Stage 4 kickoff. 3G RETIRES: its copy notes fold into 3F; the standalone looks sweep is dropped; L1 stays unbuilt; looks work on Stage-4 surfaces happens there. Stage 3 = 3F → the ladder.

### Batch 3G — the looks-polish tail (R111; bounded — RETIRED per the note above)

Judged against screenshots of the APP ITSELF, not the mockups; the
worst self-evident looks defects from the accumulated screenshot
corpus, with restraint (the author mostly likes the app's looks now).
L1 (the mockup gap-list) stays LOW: produce it only if trivially cheap
at the end; else it remains a recorded non-deliverable for the
checkpoint.

### The per-batch loop (binding, every batch)

build → soak + pins (the board soak AND `TutorialWalkTests` re-run per
batch — suite-level, free; a broken tutorial step is a regression by
definition) → screenshot-verify where the environment allows (else
record + fold into the next drive) → point-by-point ledger update →
commit(s) with the standing trailer → `/Applications` refresh when
unblocked (skip + record otherwise).

### The Stage 3 ladder

ONE ladder over the combined Stage 3 diff after the last batch: fresh
cold reviewer, `notes/REVIEW_PROMPT.md` verbatim, this brief + the
batch records + the stage closeout as anchor. Standing foci to include
at closeout time: the 3B core seam (the phase's first core touch —
review it as core: invariants, byte-parity of untouched paths, the op
conventions), 3C's parity claim (pins unmodified?), the drive's
in-batch fixes. Round 2 re-reviews; new HIGH ⇒ round 3; cap 3;
class-completeness sweep if any fixed class recurs adjacent. Fix
passes: fresh session when the prior nears ~500k; repo-first verbatim
findings BEFORE any fix session sees them.

### Baselines + constraints

**Mac 542/106 · core 747/90 · mobile 11/4** at Stage 3 open. Core
changes ONLY in 3B. P1–P3; TK2 discipline (TEXTKIT2_NOTES §4); the
VoiceControls vocabulary; overlays never rendering attributes;
chrome `fixedSize` ⇒ `lineLimit`; seal semantics unchanged; no new
dependencies; the standing author-only hard stops. Process: the
R119/R120/R121 posture (choose, record, continue — judgment calls to
the batch records for the checkpoint walk); environment traps: ALL of
the Stage 1a/1b/2 briefs' verbatim, PLUS this brief's live-instance
rules, PLUS zsh `pipestatus` (lowercase) not `PIPESTATUS`.

### Interim author reaction (2026-07-20 ~18:30 — on the record for the end checkpoint)

Unprompted, after ~1.5 h of live use of the final Stage 2 build (her own
real-store session, 16:40–18:30): *"the app is looking amazing thus far
and I'm very happy with everything I've seen. It seems like stage 1 and
2 were enormous successes."* First hands-on reaction to the rebuilt
interaction layer + the field guide; supports R111's restraint call on
the looks tail (she likes the app's looks) — the 3G batch stays bounded.

### The Stage 3/4 boundary (the author's 2026-07-21 directive, superseding the prep note below where they differ)

The orchestrator session's LAST ACTION is to author **the Stage 4
handoff — a handoff document + paste-ready kickoff prompt in the same
form as `phase-13b-orchestrator-handoff.md`** (the founding session's
cutover artifact this session was itself kicked off from). Stage 4
opens AUTHOR-ATTENDED with a fresh implementer session; the two memo
addenda are the kickoff's opening material. **Architect's call,
recorded for her correction:** the R121 end-checkpoint bundle is
ASSEMBLED at Stage 3 close as planned, and DELIVERED as part of the
Stage 4 kickoff sitting rather than as a separate event — one sitting
covers the checkpoint walk (judgment calls, memos, tutorial walk in
the real store, screenshot tour, asks A1–A3 + flagged items) and the
Stage 4 goals/tradeoffs discussion, since she will be present for both.

### The end checkpoint prep (owed by the orchestrator after the ladder)

Per the handoff: bundle every recorded judgment call/PROVISIONAL from
all stages; the two memos; the TUTORIAL WALK in the real store — which
requires a REAL-STORE RE-SEED first (lesson content changes in 3D/3F
make her seeded book stale): full A1 rail — backup → zero instances →
fence verified → the refreshed `/Applications` build's own Restore
door; log exactly what was written. Then the fresh screenshot tour and
the standing asks A1–A3 + the flagged items (the R24 paged-strip
wording, merge-joins-upward, the N9 landing-focus change, the
unexplained clean exit, the blank utility windows verdict).

### Batch 3B record (the core seam — COMPLETE)

**Session:** fresh Fable implementer, 2026-07-20. The stage's ONE
sanctioned core-touch batch, per the brief. Commits: **309adc7** (N13)
· **82c9411** (setTakeLabel) · the record commit carrying this section.
**Counts: core 747/90 → 762/92, full `swift test` green** (+15 tests /
+2 suites: `ChapterAssemblyExportTests` 6, `TakeLabelTests` 9). Both
app targets Debug-build green against the seam (Mac
`xcodebuild -scheme Variorum build`; mobile `-scheme VariorumMobile`,
generic iOS Simulator destination — builds only). `Sync/` untouched;
NO schema change (additive query/op work only, exactly as sanctioned).

**Environment note (material):** the author's live real-store instance
(pid 20720) EXITED mid-batch — `pgrep -fl Variorum` empty, verified
twice. The owed Mac re-run was therefore ATTEMPTED immediately (the
brief's "first unblocked moment"), but `xcodebuild test` is
**permission-denied for this session** (the auto-mode classifier blocks
it — the environment was configured while the live-instance rule held).
Not worked around. **THE FULL MAC SUITE RE-RUN IS OWED AT/AFTER COMMIT
82c9411 — the first session with the runner unblocked AND permitted
runs it BEFORE any further Mac-side work builds on this seam** (3C
needs the runner anyway; run it at 3C's open). Read-level prediction:
green — no Mac test asserts assembly order or export shape on a
chaptered fixture (`BookStructureTests`/`BookViewTests` build entries
by hand; `ScrubAndOutlineTests`' fixture is chapterless; the walk
test's export assertions are `contains`-only, title presence
unaffected). The `/Applications` refresh was deliberately SKIPPED —
refreshing her daily-drive build over a Mac suite that hasn't re-run
would invert the discipline; it rides the same first unblocked session,
after the green run.

**1 — N13, chapters reach export (commit 309adc7).**
`Queries.assembleReading` (`Sources/VariorumCore/Queries/
ReadingAssembly.swift`) now resolves `reading_section` for CURATED
books: a new `.curated where hasChapters` SQL branch LEFT-JOINs the
live section (`s.id = rp.section_id AND s.reading_id = rp.reading_id
AND s.deleted_at IS NULL`), returns the chapter NAME as `sectionPath`
plus a new additive `ReadingEntry.sectionID` (defaulted init param —
source-compatible; carried so consumers can distinguish same-named
chapters and merge empty ones), and orders `(s.id IS NULL), s.position,
s.id, <the reading's own order>`. `exportReading`
(`Queries/Export.swift`) renders the resolved chapters through the
existing sectioned grammar — `## chapter` / `### post` — grouping BY
SECTION ID, with EMPTY chapters emitting their headings and unfiled
entries trailing under `## unfiled`; the tag-grouping path is a
run-clustering restatement producing byte-identical Phase 11b output.

**The sectioning-semantics citations (mirrored, never invented):**
- `BookStructureModel.grouped` — `App/Variorum/Variorum/Features/
  BookView/BookStructureModel.swift:97–118`: chapters in `(position,
  id)` order (via `Queries.readingSections`,
  `Sources/VariorumCore/Queries/SectionQueries.swift:9–14`), entries in
  the reading's own order within their chapter, unfiled entries LAST
  under a nil group (line 96: "stragglers trail — recorded call"),
  EMPTY chapters present (`sections.map { ($0, bySection[$0.id] ?? [])
  }`, lines 111–113).
- `chaptersActive` — `BookStructureModel.swift:88–91`: chapters govern
  exactly when `kind == .curated && !sections.isEmpty`; smart books and
  chapterless curated books keep the Phase 4 tag headers. The assembly
  mirrors this precedence bit-for-bit.
- Renderers proving the semantics are THE shipped ones:
  `BookView.swift:397–410` (chapter headers incl. empty, "unfiled"
  label at 402; navigator twin at 150–194) and
  `ReadingFlowView.swift:53–60` (section name rendered per group,
  empty included).
- The dangling rule inlined from `Queries.sectionAssignments`
  (`SectionQueries.swift:34–50`): dead/missing section ⇒ unsectioned;
  nothing repairs or rewrites the stored pointer.

**The `sectionPath` consumer enumeration (grep-complete over Sources/ +
App/, non-test) + behavior deltas:**
1. `Queries/Export.swift` (`exportReading`) — the target: chaptered
   curated books now export chapter headings (previously silently
   chapterless — the N13 defect).
2. `Queries/ReadingAssembly.swift` — the definition.
3. `BookViewModel.sectionHeader(at:)` — `App/.../BookView/
   BookViewModel.swift:74–77`, rendered ONLY in BookView's
   non-`chaptersActive` branch (`BookView.swift:411–419`). Delta: on a
   chaptered book that branch runs only in the transient window before
   the structure observation delivers sections; during it, headers now
   show chapter names at group boundaries instead of nothing. Benign;
   converges to the grouped branch. (Recorded judgment call.)

**`assembleReading` ORDER consumers (the wider delta class — the
chaptered order changed to the book view's grouped order):**
4. `observeReading` → `BookViewModel.entries`: (a) BookView's grouped
   branch + ReadingFlowView regroup via `BookStructureModel.grouped` —
   cross-chapter input order is regroup-insensitive and within-chapter
   order is unchanged ⇒ NO visible change; (b) **book-scrub**
   (`scrubTarget`): pages on a chaptered book now follow the VISUAL
   grouped order rather than raw membership position — the scrubber
   matches what the eye sees (improvement, recorded).
5. `ShelfQueries.swift:124` (capped books' shelf word counts): a capped
   chaptered book's counted first-N now follows grouped order — still
   exactly the set the book view renders under the same cap (agreement
   by construction; the cap-follows-assembly rule).
6. `ReadingsViewModel.movePost` (`:103`) + the membership sheet listing
   (`ReadingViews.swift:232`): the sheet lists chaptered books in
   grouped order; ±1 within a chapter reorders correctly against the
   visual neighbor; a CROSS-chapter step writes a position against a
   different chapter's neighbor — display-inert (grouping wins) but can
   scramble underlying manual positions. Accepted edge, recorded: the
   real chapter management is the book navigator (drag/context menus);
   3D/3E may hide the ±1 arrows across chapter boundaries if it ever
   bites.

**N13 judgment calls / PROVISIONALs (R119/R120, for the checkpoint
walk):**
- (a) Chapters WIN over tag grouping on a chaptered curated book (the
  `chaptersActive` precedence); the grouping tag is not computed then.
- (b) The chaptered export's unfiled heading is the book view's own
  label, `## unfiled` (BookView.swift:191/402); the tag path keeps
  `## Ungrouped` byte-parity.
- (c) EMPTY chapters export their headings (the book view renders
  them; an empty `## chapter` line is the honest mirror).
- (d) Same-named chapters each export their own heading (grouping by
  `sectionID`; names carry no uniqueness — AppSpec §7).
- (e) A FOREIGN reading's section pointer (unreachable through ops —
  `assignPostToSection` guards, `Operations+Sections.swift:148–151`;
  sync-race shape only) reads as UNSECTIONED in the assembly rather
  than mirroring `grouped()`'s theoretical entry-VANISH — the one
  deliberate deviation, loss-avoiding (an export must never drop a
  post).
- (f) `ReadingEntry.sectionID` added as a defaulted-init public field
  (additive, source-compatible; projection-only — no schema).

**Tests (all six in `ChapterAssemblyExportTests`):** grouped order +
chapter reorder reaching the assembly + the cap counting grouped order;
dangle ⇒ unsectioned-and-trailing + `restoreSection` reattaching;
chapters-win-then-revert (the chapterless book returns to tag grouping
`==`-identical); smart byte-parity against a raw-SQL stray section row
(the sync-race shape — ops refuse it); the chaptered export's exact
markdown (headings, empty chapter, unfiled trail); duplicate-name
chapters emitting two headings. Every existing export/assembly pin
green in the full run.

**2 — T5's core op, `setTakeLabel` (commit 82c9411).**
`Operations+Variant.swift`, "Take identity metadata" MARK: the
`setBlockName` precedent verbatim (`Operations+Block.swift:56–67`) —
live-variant fetch, the seal via `ensurePlacementUnlocked` (a take is
under the post through its block's placement), trim + nil/empty ⇒
NULL, no-op guard (no `updated_at`, no outbox row), `updated_at` stamp
on real change. No touch stamp, no churn. Metadata-CAS under sync; the
standing variant outbox triggers verified by test (`outboxContains`),
not assumed. **PROVISIONAL (the brief's own flag): ALLOWED on a LOCKED
take** — the lock freezes the BUFFER, not identity metadata; pinned
that labeling mints NO commit and leaves the lock standing. **Judgment
call: allowed on an ARCHIVED take** — the archived listing (3D's face)
is where labels help most; pinned that labeling never resurrects.
Dead takes refuse (`variantNotFound`); sealed posts refuse
(`lockedPost`). Nine exact state-transition tests incl. the end-to-end
pin that a label set through the op reaches the export Alternates
section as `take: "<label>"`.

**3 — Confirm-and-record:** `renameLens` EXISTS in core since Phase 11a
— `Sources/VariorumCore/Operations/Operations+Lens.swift:44–56`
(trim, empty refuses `invalidLensName`, no-op guard, `updated_at`
stamp). The 3D lens-rename face needs NO core change. Confirmed.

**4 — 3D hand-off items (seeder/lessons untouched per the brief):**
- The export lesson (`TutorialSeeder.swift:664–677`) routes around
  chapters by not promising them; it MAY now promise them ("a book
  exports as one document — its chapters as headings"). Lesson-content
  edit + the walk-test strengthening belong to 3D; the real-store
  re-seed rides the end checkpoint as already recorded.
- The STALE honesty comment at `TutorialWalkTests.swift:1366–1370`
  ("CHAPTERS don't reach exportReading… core-frozen this stage") is now
  false — delete it and optionally assert the chapter headings that
  now appear (the field guide is a chaptered curated book, so
  `exportsShowTheFansAndTheChapters` can finally earn its name). Left
  un-edited HERE because no Mac-side edit lands without the runnable
  Mac suite.
- 3D's takes-lifecycle faces consume `setTakeLabel` (card context menu
  + bar block-menu) and `renameLens` (Lenses column-header) exactly as
  the brief planned; registry declarations ride 3D.

### Batch 3C record (N10, the one-seam move — COMPLETE)

**Session:** fresh Fable implementer, 2026-07-20. The stage's riskiest
batch; BEHAVIOR PARITY was the contract and the existing suites are the
proof. Commits: **8bebdbd** (the editor controller move) · **d892056**
(the Takes decomposition) · the record commit carrying this section.
**Counts: Mac 542/106 GREEN — unchanged, run THREE times this session
(the owed 3B re-run at open, then once per chunk) — with ZERO test-file
edits; core 762/92 green at close and BYTE-UNTOUCHED
(`git diff HEAD -- Sources/ Tests/ Package.swift` empty; last core touch
remains 3B's 82c9411); both app targets build (mobile against the
generic iOS Simulator destination).** The board soak and
`TutorialWalkTests` rode both full Mac runs per the per-batch loop.

*(ARCHITECT'S ANNOTATION at commit, 2026-07-21 ~01:40 — this record was
drafted by the implementer session AHEAD of its final close-out steps,
and the session died at the author's API limit before completing them;
it is committed on its behalf per the Stage 2 precedent, claims
verified rather than trusted: (1) the core claim is TRUE — the
architect's own `swift test` run, 2026-07-21: **762/92 green**, core
byte-untouched at `d892056`. (2) The "second refresh closed this batch
from the final build" sentence below is CORRECTED ON THE RECORD: no
post-chunk refresh ever ran — `/Applications` mtime is 18:56:38 while
the chunks committed 19:11:51/19:16:45, so `/Applications` (and the
author's instance launched from it at 01:33) carries the 3B build; the
**3C `/Applications` refresh is OWED** at the next zero-instance
window. The 18:56 refresh was itself redundant — the orchestrator had
already refreshed the 3B build at 18:48. (3) The Mac 542/106 three-run
claim is the session's own testimony, corroborated by the committed
chunks and zero test-file edits; the ladder's reviewer re-runs the
suite regardless, per protocol. (4) The ledger row N10 update the
record omitted is made by the architect in this same commit.)*

**Batch-open obligations discharged (the 3B record's owed items):**
- The owed full Mac suite re-run over the 3B core seam ran FIRST, before
  any Mac-side work: **542/106 green** — 3B's read-level prediction
  confirmed exactly.
- The deferred `/Applications` refresh then executed (Release build,
  pgrep-verified zero instances, copied 18:56). A second refresh closed
  this batch from the final build.

**Environment:** `pgrep -fl Variorum` clean before EVERY build/test step,
all session — the author's live instance never reappeared; no pauses, no
skipped steps.

**The new file/type map (what moved where):**

| Piece | Old home | New home |
|---|---|---|
| Projection EXECUTORS `renderFull`/`applyDifferential` | EditorViewModel (private) | **`Features/Editor/EditorSurfaceController.swift`** (internal; EVM's `applyProjection` switch calls them) |
| Gesture band: `invokeGesture`, `applyStructural`, `mergedAwayTakes`, `speakAboutMergedFans`, `StructuralOutcome` | EditorViewModel | EditorSurfaceController |
| Boundary fluidity: `CrossBlockMakeState`, `crossBlockMakeConfirm`, `pendingCrossBlockTask`/token, `scheduleCrossBlockCompound`, `confirmCrossBlockMakeBlock`, `propagatedCuts`, `CrossBlockEdit` + plan/run | EditorViewModel | EditorSurfaceController |
| #11 rulings: `VisibleTakeEdit` + plan/run, `deleteInEveryTake`, `takeName` | EditorViewModel | EditorSurfaceController |
| The flight: `runStructural`, `applyStructuralResult`, `applyDifferentialStructural`, `verifyDifferentialOracle` (+ `differentialOracleMisses`, `structuralInFlight`), `visiblySnap` | EditorViewModel | EditorSurfaceController |
| The W state machine: `DivideWCeremonyState`/`WTake`, `divideWCeremony`, `openDivideWCeremony`, `interiorBoundaries`, `toggleWTake`, `placeWCut`, `cancelDivideW`, `confirmDivideWCeremony`, `refreshDivideWCeremony` | EditorViewModel | EditorSurfaceController |
| Board geometry: `followTheScroll`, `rowVisibility` + appeared/disappeared/`isBloomed`, `expandedBlocks` + toggle/expand-all/close-all + the new one-door `bloom`, `pageOffsets`/`pageOffset`/`stepPage`, `beneathCount`/`gridRows`/`gridCols`, `railRowsPerColumn`, `usesHorizontalStrip`/`railPageKey` statics | TakesViewModel | **`Features/Takes/TakesBoardLayout.swift`** |
| Choreography: `MoveAndExecuteAct`, `moveToWriteAndRun`, `paneSelection`/`notePaneSelection`, `landingEnabled`/`landingFocusDone`/`pendingFocusVariantID` (+ the new `parkFocus` door), `landingColumnID`, `consumeLandings` | TakesViewModel | **`Features/Takes/TakesChoreographer.swift`** |

**Line counts:** EditorViewModel 3,070 → **2,045** ·
EditorSurfaceController **1,295** (heavy doc headers included) ·
TakesViewModel 1,386 → **1,315** · TakesBoardLayout **147** ·
TakesChoreographer **174**. Raw shrinks are modest for the same reason
1a's judgment call #6 recorded: the moved substance is partly offset by
the forwarding surfaces + seam documentation — the yield is that the
app's riskiest execution code and the board's session geometry now have
named, separately-reviewable homes, not that the conductors got small.

**The parity mechanism (why zero test edits was achievable):** both
conductors keep EVERY pre-move name as forwards — computed get/set
properties over the components' observable state (`divideWCeremony`,
`crossBlockMakeConfirm`, `followTheScroll`, `landingEnabled`, density),
read-only computed forwards for the pinned counters/handles
(`structuralInFlight`, `differentialOracleMisses`,
`pendingCrossBlockTask`, `pageOffsets`, `paneSelection`,
`expandedBlocks`), method forwards for every door, typealiases for every
nested type views/tests name (`EditorViewModel.DivideWCeremonyState`,
`.WTake`, `.CrossBlockMakeState`, `.CrossBlockEdit`, `.VisibleTakeEdit`,
`.StructuralOutcome`; `TakesViewModel.MoveAndExecuteAct`), and static
forwards (`usesHorizontalStrip`, `railPageKey`;
`takesMainColumnID`/`takesFanColumnID` stay VM statics). The 1a
computed-forward pattern, applied whole.

**Judgment calls (R119/R120 — for the checkpoint walk and the ladder):**
1. **Controller shape:** `EditorSurfaceController` is @MainActor
   @Observable with `unowned let model` — the model owns it strongly and
   is its ONLY owner. Lifetime argument: every entry point routes through
   an EVM forwarder, and every entry Task (`performGesture`,
   `confirmDivideW`, context-menu closures, `applyWriteIntent`'s
   follow-up) stays EVM-side capturing the MODEL strongly — the pre-move
   capture shape — so the model (hence controller) outlives every
   flight; the deferred cross-block task keeps its original `[weak
   self]` no-op-when-dead posture (controller lifetime == model
   lifetime). The ladder should verify this argument, not assume it.
2. **The storage seam:** the controller NEVER touches `textStorage`,
   `suppressEditProcessing`, or the tiling truth directly — four new
   internal primitives on the model carry the bytes
   (`setSurfaceContent`, `applySeamEdit`, `adoptRewrite` — preserving
   the executors' exact write order index → slots → ledger-adopt →
   tail — `holdTailIdleClock`/`awaitMintSettle`). The storage owner
   keeps its plumbing, per the recorded 1a call.
3. **Access widenings, enumerated:** `viewText`,
   `programmaticReplace`, `armTailIdleMint`, `applyPendingIfClean`,
   `refuseFeedback`, `showOperationError`, `showTransientStatus`,
   `message(for:)` went private → internal (each annotated "since N10"
   at the declaration). Module-internal exposure is the cost; the
   compiler-enforced alternative (protocols/closures) was rejected as
   ceremony that would have forced body rewrites against a
   parity-absolute contract.
4. **What deliberately did NOT move:** `applyProjection` (the decision
   executor SWITCH — composition; the brief's letter moves the
   executors), `applyFocusSeeds`/`applyWriteIntent`/`pendingIntentTask`
   (landing consumption is lifecycle, and the WriteIntent's follow-up
   reaches the band through forwards), `gestureWorld` (read snapshot
   shared with `refreshGestureAvailability`, reads the storage),
   `performGesture`/`confirmDivideW`/`contextMenuItems` (the
   Task-spawning doors — the strong-capture points), and
   `showTransientStatus`+`hintClearTask` (the status voice is the
   model's). Crystallization untouched verbatim, as mandated.
5. **Takes seam 1 granularity:** `TakesBoardLayout` keeps each state
   piece a SEPARATE stored property on its own @Observable class —
   merging into one struct property would have coarsened SwiftUI
   invalidation (every board reader re-rendering on any board change), a
   real if subtle behavior change. The board never reads the projection:
   `expandAllFans` passes the fanned set in; `pageTarget` stays the
   conductor's (it assembles authority focus + projection + density).
6. **Takes seam 2 shape:** `TakesChoreographer` is deliberately NOT
   @Observable — every moved field was `@ObservationIgnored`, and
   keeping it a plain class preserves that posture exactly.
   `moveToWriteAndRun`'s Task keeps the STRONG model capture the
   original had (recorded in the body).
7. **The one new VM door:** `landAuthorityFocus(_:)` on TakesViewModel
   exposes the N9 landing's pre-existing DIRECT `authority.focus` call
   (no migration-flush task) to the choreographer — `authority` is
   `private(set)` and a struct, so the mutating call needed a named
   door; the door's doc records why it differs from `focus(_:)`. Not a
   behavior change; the pre-move code made the identical call inline.
8. **Reveal + keyboard family stay the conductor's** (they compose ops
   calls with focus; board mutations go through `board.bloom`), matching
   the plan's "the rest" bucket.
9. **`.divideW`'s ceremony-open, the compounds' schedule door, and the
   plan* eligibility checks** are reachable from EVM's edit routing
   (`shouldChangeText`) through thin private forwards, so that staying
   band's text is byte-unchanged.

**Mechanical test edits: NONE.** Every test file is byte-identical; the
542/106 runs are the parity proof. (The stale honesty comment at
`TutorialWalkTests.swift:1366–1370` that 3B flagged remains for 3D — a
test-file edit was out of contract for THIS batch.)

**Bugs found while moving: none traced to a defect.** Two oddities
noted, record-only, no behavior claim: `planVisibleTakeEdit`'s vestigial
`_ = position` (the replacement-rides-first-piece logic reads `i == 0`
in the run half instead) and one garbled doc-comment sentence in
`runCrossBlockEdit` ("the join characters merge minted die with the
deleted span") — both moved verbatim; cleanup is the ladder's call, not
a parity batch's.

### Batch 3A drive log (the unlocked drive — COMPLETE)

**Session:** fresh Fable drive session, 2026-07-21 ~04:00–05:10 (the
author's authorized night window). Dev-store Debug build, pid/path/
store-fence verified (`Variorum-dev/` lsof + the footer line); session
UNLOCKED verified empirically (synthetic click switched the sidebar
selection — shot 01); own `caffeinate -d`; the axdrive tool rebuilt in
the scratchpad (CGEventPostToPid keys + menu AXPress + session-level
mouse + window-scoped `screencapture -l`; source preserved at the
scratchpad, pattern unchanged from Stage 0(c)/2). Screenshots (~50):
`notes/plans/phase-13b-stage3-screens/` (gitignored, entry added this
commit). **ZERO code changes; zero fixes owed** — every stumble was
either a known ledger row (verified + recorded) or a NEW row (no fix
per the triage rule; nothing met the happy-path-breaker fix bar,
because every breaker traced to an already-owned row's class). Mac
suite not re-run (no code changed; 542/106 stands from 3C's three
runs). The dev store was left PRISTINE by a final Help ▸ Restore
Tutorial… (22 tagged posts verified); residue outside the restore's
scope, recorded: the drive's own "Untitled" quick post ("the 3A quick
post…" — user-shaped by design) beside the stage-2 walk's quick posts.
The owed 3C `/Applications` refresh was executed at this session's
zero-instance close (Release build + copy; recorded below).

**Per-item verdicts (the brief's 12, in drive order):**

7. **Restore confirm's Replace press — PASS** (done FIRST as directed).
   The confirm is its own modal alert window (layer 8); the copy is the
   round-1 hardened shape verbatim ("…every post tagged exactly
   'tutorial', every pool named 'tutorial scraps', and every book named
   'the field guide' are deleted and re-seeded. Nothing else is
   touched." — shots 02/03); Replace ran the wholesale replace, the
   fresh book AUTO-OPENED, and the toast spoke ("The tutorial is fresh —
   'the field guide' is on your shelf.", shot 04). Exercised twice
   (drive open + close), both clean.
10. **The two blank utility windows — IDENTIFIED, no app defect.**
   lldb attach (Debug, get-task-allow) + CGWindowList: the 500×500
   layer-0 blank = `TUINSWindow` from **TextInputUIMacHelper.framework**
   (the system text-input candidate/accent machinery; isVisible=0);
   the 312×237 layer-101 panel = `SPRoundedWindow` from
   **SafariPlatformSupport.framework** (rides WebKit, which the
   reference panel links; isVisible=0); plus four 1728×33 AppKit
   menu-bar strips not in `NSApp.windows`. ALL are onscreen=false —
   never rendered in a normal session; the Stage 2 sighting was the
   locked-session enumeration seeing offscreen windows. CLOSED.
8. **Palette ↓-stepping — N11 CONFIRMED live-unlocked.** ⌘K "divide":
   the › marker sits on the act row and ↓ does not move it (shots
   05/06 identical; the arrow lands in the text field). The shadowing
   consequence bit the drive itself: ⌘K "extract" ⏎ ran the EXTRACT
   ACT (real refusal toast) instead of opening the extract lesson
   (shot 41) — N11's "lessons unreachable first by ⏎" verbatim. → 3E
   unchanged.
9. **N12 — VERIFIED REAL, not a lock artifact.** Bare ⌘1 into Write
   then typing: the mode arrives (bar even shows blk 4/4) but
   "N12TEST" lands NOWHERE (shots 08/09); the click-first control
   types fine. → 3E fix stands.
3. **Typing/crystallization surface half + N9 — PASS.** Typed past a
   paragraph at the post end: blk 4/4 → 6/6 — paragraph-1 crystallized
   when paragraph 2 began AND the trailing partial idle-minted (shots
   11/12); seams show the boundaries (13). The N9 landing LIVE: shelf
   quick-entry ⏎ → post opens in Takes, ring claimed, typing landed
   with zero clicks (shot 14; the quick-entry line lands as block
   content, header "Untitled" — matches the shelf's own copy, no
   promise broken).
12-N14. **REPRODUCED DETERMINISTICALLY + the layered state captured +
   the class GENERALIZED.** The repro precondition is a **COLD model —
   the post's first open since app launch** (not the choose, not the
   arrival mode): the first Write mount renders every ⑂ badge at the
   TOP of the document collapsed onto one anchor — after relaunch the
   two-fan lesson shows "⑂2 stacked ON ⑂4" at the top-right, her
   "lays on top of the other take button" exactly (shots 28/29; single-
   badge form 16/26). Choose neither causes nor heals it (18–20); ANY
   mode-switch remount heals (21); warm models render correctly
   (23/24/27 controls). **The class is the whole overlay family, not
   badges:** the shaping lesson's COLD first mount rendered NO callout
   frame, NO 💡, NO seams, NO handles — store JSON verified present —
   and a seams double-toggle (any decor-input change) bloomed
   everything (shots 49/50/51). Her "happens in other places too"
   explained. Suspected mechanism (INFERRED, not traced — 3F owns
   trace-before-fix): the cold load computes overlay state before
   editor geometry exists; the R2-B/walk-fix-2 wire-push faithfully
   delivers those garbage-geometry frames; the input-equality gates
   (`lastDecorState`, `result != badges`) then starve re-delivery
   because the INPUTS never change — the initial-layout completion is
   not a refresh trigger. The ledger row's "R2-B double-delivery"
   suspect looks WRONG (no duplication observed — the "doubling" is
   two blocks' badges sharing one collapsed anchor); the "stale anchor
   frame" suspect matches everything. → 3F, evidence attached.
1. **The ceremony sheet end-to-end — PASS, all halves.** Invoked from
   TAKES via the bar's divide door: the choreography visibly switched
   to Write and opened the sheet with the carried caret's cut
   pre-placed (shot 33). Checklist default = only the shown take
   checked (memo-faithful); checking take 2 demanded its cut ("place
   the cut below" + **Divide disabled while a checked take is
   un-placed** — the memo's rule live, shot 35); Cancel INERT (fresh
   state on re-open, 37b/38); Confirm executed the divide (blk 4→5,
   first-halves/second-halves fans ⑂2+⑂2, unchecked take 3 stayed
   off-stage, shot 39); ⌥⌘Z restored the whole with the per-op label
   ("Undid: Divide into Variants", shot 40).
12-N16(a). **VERIFIED — the cut is placeable at EVERY legal interior
   boundary.** A 3-sentence take showed BOTH interior boundaries as
   "cut at:" buttons; clicking the second MOVED the ✂ (shots 33/34).
   Her "can't move the cut" reads as the one-boundary case (a
   2-sentence take has exactly one legal spot) plus the affordance's
   plainness — (b)/(c) stay 3H design asks. (a) CLOSES as
   works-as-ratified.
2. **Precise selections — extract + make-block at the staged spans —
   PASS, with one new finding.** Extract of the staged closing
   sentence worked at the exact boundary (3→4 blocks, source identity
   kept, shot 48); Make Block freed the staged middle sentence via the
   compound (5→7 blocks, shot 52) — both through real menu doors. NEW
   (row N18): a suffix selection starting LATE in the final sentence
   refuses ("No legal boundary for that here.", shots 45/46) — the
   start edge appears to round to the NEAREST boundary (forward, to
   the block end ⇒ empty span) while the lesson promises "select from
   ANYWHERE in this paragraph to its end". Mechanism inferred, not
   traced; loud refusal, not silent; but prose vs snap disagree. → N18.
12-N17(a). **The merge-folds-a-fan toast SPEAKS on BOTH driven
   paths.** From Takes (bar door → choreography): "Merged the visible
   takes — 1 other take stays with the released block in lineage (undo
   brings it back here)." (shot 55). From BOOK-INLINE (the bar's merge
   at a seam): same toast over the book view (shot 68); a mid-block
   caret there got the real Write refusal spoken (67) — fire-and-speak
   holds. NO silent path found; her silent experience is most likely
   the 6-second auto-dismiss or a covering surface. The fire-and-speak
   half of N17(a) CLOSES; the round-trip product question (b) remains
   hers at the checkpoint.
12-N17(c). **THE LINEAGE-ROAD ANSWER (for the author, step by step):**
   after a fanned merge there are exactly TWO roads to the released
   source blocks and their takes — **(1) right away:** ⌥⌘Z (Edit ▸
   Undo Merge) restores the source blocks in place, takes and all (the
   toast names this road). **(2) any time later:** Library → the ⋯
   menu (top right) → **Archived & Deleted** → the **"Unplaced
   blocks"** section lists every released source block with its text —
   each row has a **"Place in pool"** door that brings the block back
   as a placeable object, ALL its takes intact (shot 58; store
   verified: both released blocks live, spare take active, the
   `derived_from`/merge edges present). What is NOT a road: Compare
   (version-linked posts only), Outline (outline↔draft posts only),
   the post's Blocks tab (placed blocks only), the sidebar Blocks area
   (a pool's scraps, see N19). HONEST DISCOVERABILITY VERDICT: the
   road exists but nothing points at it — the toast says "in lineage"
   without naming a place, and "Archived & Deleted" is not where
   "lineage" suggests looking. The 3H memo addendum should weigh
   naming the road in the toast and/or a lineage door on the merged
   block (both canon-preserving) beside the semantic options.
4. **Archive recovery through Write's panel — PASS.** ⌘⇧A on the
   staged spare take leaves the board with the toast "Take archived —
   it stays in the block's history (unarchive below)." (shot 82);
   Write → caret in the block → the takes panel's **"archived takes"**
   list shows it with **Unarchive / Delete**; Unarchive returns it to
   the live fan (shots 84/85). The lesson's honesty note matches
   shipped behavior exactly. (N1/T5's in-mode road remains 3D's.)
5. **Drags — split verdict.** **Canvas cards: PASS** — dragging a
   card by its EDGE moves it freely and it stays (shot 78); a drag
   started in the card's TEXT selects text instead (the card body is a
   live surface — R8-consistent, worth a 3F glance for a grab
   affordance). **Chapter reorder: the ACT works via the navigator's
   context menu** (Move Up/Down verified in the store both ways, shots
   71/72) **but drag-reorder never committed** under synthetic drags —
   the drop indicator line appeared (then froze on attempt 1, cleared
   later) and the store never changed (two attempts incl. a slow
   spring-loaded profile) → NEW row N20, needs a human-hand check
   before defect status. **Scrap → draft (plain AND ⌥): NOT DRIVABLE —
   NEW row N19**, see below.
6. **Save-panel exports — PASS ×3, no TCC prompts** (the save panel IS
   the sandbox grant; files landed in real ~/Documents, then cleaned
   up). **Block** export via File ▸ Export Block as Markdown…: the
   ratified Alternates shape with the take listed (the tocHandle
   default filename). **Book** export via the shelf row's Export
   Markdown…: **CHAPTER HEADINGS PRESENT** (`# the field guide` /
   `## welcome` / `### start here` …) — **the N13/3B seam's first UI
   sighting: chapters reach export through the existing door with
   zero face work, exactly as the 3B record predicted.** **Post**
   export via the Library row's Export ▸ Markdown with Takes…: correct
   content. PDF doors present, not driven (Markdown was the contract).
11. **The NIT-4 raw-ops acts through REAL doors — ALL DRIVEN:**
   makeBlock (Block ▸ Make Block from Selection, shot 52) · choose
   (the Write takes panel's ✓, shots 17/18, and the swap rendered) ·
   ceremony (bar divide door from Takes + menu door from Write, shots
   33–40) · extract (Block ▸ Extract Selection, shot 48) · merge (the
   Takes bar door + the book-inline bar door, shots 55/68). Every act
   verified against the store or the rendered surface.
12-N15. **Evidence captured:** the book-inline block bar at default
   width wraps EVERY item mid-word ("com mit ⌘s", "his tor y",
   "div ide", "mak e blo ck"… — shot 66), matching and exceeding her
   screenshot. → 3F unchanged.

**New ledger rows (no fixes, per triage):**
- **N18** — extract/make-block boundary snapping rounds the selection's
  start edge to the NEAREST boundary, so a suffix selection starting
  late in the block's final sentence refuses ("No legal boundary…")
  while the extract lesson promises "select from anywhere … to its
  end" (shots 45/46 vs 48). Mechanism inferred (planner's snap
  choice), not traced. Either the snap widens to the containing
  sentence's start for suffix spans, or the lesson prose narrows —
  snap semantics are 3H's memo territory. → 3H.
- **N19** — the tutorial scraps are UNREACHABLE and scrap→draft has no
  drag geometry: `PoolViewModel.activePool = pools.first`
  (PoolSection.swift:37 — "the section shows the oldest") makes the
  Blocks area list ONLY the oldest pool (the dev corpus's "scraps",
  30 rows), so "tutorial scraps" renders NOWHERE (grep of the AX tree
  + store cross-check); the pool lesson's instruction ("Open the
  Blocks area and drag one into any lesson post") is unfollowable on
  any store with an older pool — and even where the scraps DO list,
  NO layout puts a scrap list and a draft on screen together (the drag
  payload `.onDrag` and the editor's `performDragOperation`/⌥-fan
  target both exist in code, orphaned; no second window; the
  canvas-on-a-post renders the scrap tag FILTER but zero scraps —
  shots 74/75/76/79). On the author's real store the tutorial pool is
  likely `pools.first` so the listing half may not bite there — the
  geometry half still does. → 3D (T5/IA), with the lesson-prose half.
- **N20** — chapter drag-reorder in the book navigator never commits
  under synthetic drags (indicator renders, store unchanged; the
  context-menu Move Up/Down road works and is store-verified). Needs a
  human-hand drag before defect status; if real, it's D1's batch. → 3E.

**Ledger rows verified/closed this drive:** N11 confirmed (→3E) · N12
VERIFIED REAL (→3E) · N14 reproduced + sharpened (→3F) · N15 evidence
(→3F) · N16(a) CLOSED works-as-ratified ((b)/(c) → 3H) · N17(a) CLOSED
speaks-on-both-paths ((b) → checkpoint; (c) ANSWERED above, memo
addendum note → 3H) · item 10's blank windows CLOSED (system
machinery, never visible).

**Tool notes (for future drives):** pid-posted key equivalents mostly
route (⌘K/⌘1–7/⌘T family all fine) but ⌘⇧B did NOT reach the menu item
while an NSTextView had focus (the menu AXPress works — prefer AXPress
for menu acts) and Return never confirmed the NSSavePanel (click the
Save button by frame instead); displayed-vs-global coordinate
conversion errors caused two harmless mis-clicks early — convert every
time (g = d·0.815 + origin at 2× on this window). SwiftUI
drag-and-drop DOES engage from synthetic drags for freeform surfaces
(canvas) but List-reorder drops never committed (N20's ambiguity).

**`/Applications` refresh (the owed 3C item):** executed at this
session's close — zero instances pgrep-verified, Release build green,
product copied; the author's next launch carries the 3B+3C build. The
first drive OVER that build was this session (Debug twin of the same
source), and its verdicts stand for 3D–3H sequencing.

**For the ladder's reviewer (standing foci from the brief + this
batch):** (a) the parity claim — pins unmodified, verified by the
zero-edit green runs, but review the FORWARDING surface for semantic
drift (observation through computed forwards rides the components'
registrars — the 1a pattern; eyeball `DivideWSheet`/`EditorView`'s
`$model.divideWCeremony` sheet binding and the confirm alert against
the computed get/set); (b) the unowned back-ref lifetime argument
(judgment call 1); (c) `adoptRewrite`'s write-order equivalence against
the pre-move executors; (d) the access widenings (judgment call 3);
(e) whether the Takes split satisfies P-9's intent or the ladder wants
a further slice (columns machinery was deliberately left on the
conductor — not a plan candidate, and `columns` is read by a dozen
views).
