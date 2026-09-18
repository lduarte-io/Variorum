# Phase 13u2b — THE LANDING SEAM (EXECUTION PLAN)

**Status: OPEN 2026-09-18, at her word** (*"go ahead and write the phase plan and orchestrate it"*,
after the architectural trace answered her mandate — *"I want to know how we've been solving it, if
there's different architecture that we need, or if this really is just a bug fix"* — with: a missing
architectural piece plus a four-times-copied compensator, explicitly NOT a local bug). **The BINDING
DESIGN RECORD is `notes/plans/navigation-landing-architecture-trace.md`** (2026-09-18, commit
`a0606641`) — §2 the dated history, §3 the four compensators, §4 the hands-on reconciliation, §5 the
recommendation this phase builds, §6 the mode-switch answer, §7 the notes for whoever runs it. This
plan does not restate the trace; it schedules it.

**Why "13u2b":** this phase completes 13u2's items 1 and 18, whose field acceptance FAILED in her
hands (her report, verbatim: *"I clicked a far away chapter, that was fine, then I clicked one that
was much higher and I watched it stutter ~10 times, every time I did it. I managed this by clicking
on the last chapter and then The Man with the Twisted... in sherlock."*). It runs BEFORE 13u3 at her
word this morning.

**GOVERNANCE (2026-09-18, after the kickoff commit `93cb4d02`): the author invoked `/architect-phase`
for this phase — her cast, verbatim: *"this phase that we've discussed, Opus builders, Fable
orchestrator + reviewer."*** So: the orchestrating session holds the ARCHITECT MANDATE (the R117
shape; `.claude/skills/architect-phase/SKILL.md` governs beside CLAUDE.md — CLAUDE.md wins on
conflict); implementers are **`opus-implementer`**, one FRESH session per unit; the ladder's cold
reviewer is **`fable-reviewer`**; the 13b constitution below is BINDING; the skill's application
notes (P-1's routed-vocabulary scope, P-3's two deliberate surface kinds, the layer-placement and
overlay/sink laws) bind by reference. This matches the kickoff's cast exactly — nothing about the
units, the gate, or UNIT 1's running brief changes.

## BINDING PRINCIPLES (the 13b constitution, P-1…P-9 — copied verbatim per the skill's rule)

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

**How the constitution bites HERE (application, not modification):** P-8 is the phase's spine (the
manifest and the authority are the rebuilt layer; invalidation ∝ realized rows; the manifest read is
lengths-only ∝ entries). P-7's red-on-old is the gate itself (row 64's arm). P-3 is a FENCE: this
phase is scroll geometry — it composes beside the pane/editor split and extends NO liveness
mechanism. P-9 binds the UNIT 2 hoist (the authority is one concern: aim/settle; it does not absorb
board layout or text authority). P-6 rides every full-suite run (`TutorialWalkTests` green is part
of every unit's end verification). P-1/P-2 should not fire (no new doors); if a door appears, it is
declared in the registry, never inline.

**OVERNIGHT AUTHORIZATION (2026-09-18, her words verbatim):** *"I'll be stepping away overnight -
use the standard method of recording judgement calls and not stopping for questions unless
absolutely necessary. my app is now closed & when you finish, you can refresh it. write a handoff
for me in the case that you're done before i wake, so I don't have to wake a large cold cache for
handoff issues + walk."* So: **PROVISIONAL-and-continue** binds the whole run (judgment calls
recorded here + QUESTIONS, never stop-and-ask except the standing author-only hard stops); the
**`/Applications` refresh is PRE-AUTHORIZED at the phase's finish** (her app is closed — the
zero-instance window is open; the standing rails still bind: A1 backup first, zero instances
verified at every step, Release from a clean worktree, codesign + hashes recorded); the **author
handoff** (`notes/handoffs/phase-13u2b-handoff.md`) is written LAST, self-contained, her checklist
at the top — including the field walk she owes and every overnight judgment call, so nothing needs
this session's cache.

**Her remote check-in (2026-09-18, overnight):** *"only do U3 if your context is <600k … unless you
don't mean 13u3 faces? … if it isn't a separate 13u3 plan, then do it even if you're above that
context window."* Resolved: U3 here is UNIT 3 of THIS phase (the fraction carry), not 13u3 FACES —
it runs in a fresh implementer session like every unit, the orchestrator is far under her line, so
by her own condition **U3 PROCEEDS**. 13u3 FACES stays a separate phase at her word. **RATIFIED by
her follow-up, verbatim: *"oh - include U3 tonight, ratified. 13u3 remains a separate stage."*** —
no longer the orchestrator's reading of a condition; her direct ruling.

## THE LEDGER (every row owned; statuses flip in the same commit as the work)

| # | item | status → owner |
|---|---|---|
| 1 | UNIT 1 — the height manifest + the Outline lands once (gate: row 64's arm ≤4, UNWRAPPED) | **DONE 2026-09-18 — gate MET (0 hops, arm unwrapped), record closed at `f66d1dc5`, THE ORCHESTRATOR'S WALK PASSED (below)** |
| 2 | UNIT 2 — one landing authority + the flow + the Release signpost | **DONE 2026-09-18 — record closed at `77f0f09c`, THE ORCHESTRATOR'S WALK PASSED (below)** |
| 3 | UNIT 3 — the mode-switch viewport-fraction carry (#114's defaults) | **DONE 2026-09-18 — record closed at `67f437c4`, THE ORCHESTRATOR'S WALK PASSED with ONE FLAGGED FINDING → the ladder (below)** |
| 4 | QUESTIONS #114 (a)/(b) — U3's scope edges | LOGGED — hers |
| 5 | The ladder — `fable-reviewer` over the combined diff, standing rounds | **ROUND 1 DONE 2026-09-18** (`notes/plans/13u2b-ladder-round1.md`, `b9567148`): **0 BLOCKER · 2 MAJOR · 2 MINOR · 2 NIT** — M1 the authority's at-top branch never consults `timeBudget` (a veto that never clears waits forever); M2 the orchestrator's flagged first-Read-mount defect CONFIRMED with trace; m1 a mismatched carry leaves the one-shot slot loaded + `jump(to:)` bypasses the re-decide; m2 the VOICE-change road misses the width road's re-land (#115's class); n1 two windows on one note can cross-carry; n2 a cost-shape note. The four routed items dispositioned in the file (AR-3's walk fixes SOUND; eager-rows ACCEPTED; the gate arm 8/8 green isolated — row 64's removal wording must keep the harness-timing caveat; the U3 flag = M2). **CROSS-MODEL FLOW RUNNING:** findings to each unit's implementer verbatim → responses to the reviewer for the final call → the reviewer implements confirmed fixes in its own session → suite green → implementer sanity pass |
| 6 | The orchestrator's per-unit walks + HER field walk (the phase's acceptance) | pending |
| 7 | Closeout ritual + the `/Applications` refresh (delivers the star cap `edb4ae94` too) | pending |

## KICKOFF (self-contained for a fresh session)

Read, in order: this file · the trace memo (in full — it is the design) · the 13u2 plan's UNIT A and
A2 RECORDs + RULING A-1/A-2 (`notes/plans/phase-13u2-feel.md` — the ground already tried, including
the honest revert) · `KnownIssuesAndTechDebt.md` rows **64** (the wrapped arm + its unlock
instruction — this phase's acceptance gate), **49** (the Takes landing residues — context, NOT this
phase's to fix), **44** (the per-note defaults leak — context for `SurfaceSizeMemory`), **58** (the
read-click flake — an environment red you will meet), **48** (the double realization) ·
`TEXTKIT2_NOTES.md` §2 (TK2 is exonerated for this class — the trace's finding — but its
prohibitions still bind).

**BASELINES AT OPEN (never run the full suite at a session's start):** core `swift test`
**1567/171** green (the 2026-09-18 star-cap commit `edb4ae94` edited one pin symbolically; counts
unchanged) · the FULL Mac suite **2744/459** — green with **1 KNOWN ISSUE** (the wrapped far-below
arm, `abs(below) → 73.0` — the thing UNIT 1 exists to make right) and **1 recorded environment red**
(`theReadClickLandsInIndexAtThatBlock`, row 58 — 3/3 red isolated on zero-code trees; treat a red
there as that condition unless your diff touches the book Index) · iOS build **green** · the FULL
mobile suite **626/106 with 4 known issues** · lockstep marker **8** · `/Applications/Variorum.app`
= the 13u2 Release (the star-cap change and this phase both land at this phase's closing refresh).

## THE PHASE IN ONE SENTENCE

Heights become KNOWN before a landing aims — a per-book height manifest lets a far chapter click
compute its offset and scroll ONCE — the four hand-tuned settle loops collapse into ONE landing
authority kept as the net, a content-free Release signpost makes her next field report carry its own
trace, and mode switches place the carried block at the same viewport fraction it had before.

## UNITS (three, strictly sequential, one fresh `opus-implementer` session each)

### UNIT 1 — the book HEIGHT MANIFEST, and the Outline lands once

**Goal.** A per-book, per-content-width answer: for every navigator entry, `collapsed height |
expanded height | estimate`, from (in precedence order) the CONSTANTS (chapter heading; the primed
collapsed card — byte-stable since 13u2 A2), `SurfaceSizeMemory`'s remembered size at this width,
and an ESTIMATE derived from stored block counts/lengths — AppSpec §4's own designed fallback
("stored per-block length estimates, not live geometry") promoted from the scrubber to the landings;
no new canon. A landing then computes the target's offset arithmetically and scrolls ONCE
(offset-addressed, never estimate-resolved); the existing aim/hold/quiet/hop compensator survives
only as the NET under the estimate arm.

**Steps (file-level).**
1. The manifest brain as a PURE type (suggested `App/Variorum/Variorum/Surface/BookHeightManifest.swift`
   or beside the landing code — implementer's call, stated in the record): entries × height-source →
   cumulative offsets. Unit-tested pure: precedence (constant > remembered > estimate), width
   sensitivity, expanded/collapsed, the offset arithmetic.
2. The estimate arm's inputs: consume `BookViewModel.flowExtents` / `Queries.blockExtents` (the
   already-cached, lengths-only read — KnownIssues row 36's class; P1: ∝ entries, never ∝ prose).
   If a new core read is needed it is bounded and lengths-only; **zero schema, zero `Sync/`,
   zero `Persistence/`**.
3. `BookView.swift`'s Outline landing (`landOutline`/`checkLanding` family) consumes the manifest:
   compute offset → ONE scroll → the compensator only corrects residual error from ESTIMATE rows,
   and where every row is constant-or-remembered (the common case after a book's first day at a
   width) it has nothing to do.
4. A WIDTH CHANGE recomputes the offset from the manifest at the new width (the trace's directly
   observed silent mid-story relocation), instead of letting the ScrollView keep a meaningless
   offset. **Do NOT relax `SurfaceSizeMemory`'s per-width refusal** — the estimate arm is what
   covers the refused-width case; the refusal rule is 18d's deliberate design.

**Evidence (the built-in acceptance gate — row 64's own unlock instruction).**
- **RED-ON-OLD IS ALREADY WRITTEN:** `BookOutlineLandingTests.openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded`'s
  far-below arm sits at a stable −73 pt inside `withKnownIssue` (hard ≤90 bound, ≤4 aspiration).
  UNIT 1 closes only when the ≤4 aspiration PASSES, the arm is **UNWRAPPED**, and the interim bound
  is dropped — exactly as row 64 instructs. The three-expanded gate arm stays ≤2 hops.
- The dev-store walk (WalkKit + cliclick, `io.lduarte.Variorum.debug` ONLY): her exact gesture both
  directions (last chapter → The Man with the Twisted Lip, and downward), collapsed and
  three-expanded, at two widths including a width the memory has never seen — captures; land-once
  (zero visible hops) in the manifest-complete case, ≤2 in the cold-estimate case.
- P1: the manifest build measured ∝ entries on the Sherlock corpus (reuse the flowExtents cache; no
  per-keystroke work — the manifest rebuilds on adopt/width change, never on autosave).

### UNIT 2 — ONE landing authority + the flow adopts + the Release SIGNPOST

**Goal.** The Outline's settle discipline exists in four hand-tuned copies (trace §3: Outline ·
ReadingFlowView · TakesArticleScroll · BookIndexView). Hoist the aim/hold/quiet/hop brain to ONE
home, parameterized per surface, with the DEBUG landing story built in — placement per the
hoist-at-next-touch rule (`Core/Views/` for Mac-only chrome; a pure decision core may sit lower —
implementer's call, recorded). **This phase converts the Outline and the FLOW only**; Takes and
Index adopt at their next touch (their ~15 timing pins and row 49's residues stay untouched — owner
12 keeps them; adopting them here would put four surfaces in one phase, the exact over-scope the
sizing guidance names).

**Steps.**
1. Extract the authority from `BookView.swift`'s discipline (hold/quiet/ceiling/hop-budget/watchdog
   constants become per-surface parameters); Outline consumes it with byte-identical behaviour
   (its landing suites green UNMODIFIED — the 3C zero-test-edit proof).
2. `ReadingFlowView.swift` adopts the authority AND the manifest (the 306k-pt column is the largest
   absolute win; its hand-copied constants retire; the row-100 pins ride unmodified).
3. **The SIGNPOST:** a content-free landing story that ships in RELEASE — numbers only (surface,
   target index, aims, hops, offsets, content sizes; NEVER text or titles), via `Logger`/os_log
   under the app's subsystem, so her next field report is answerable from Console output instead of
   an unreproducible regime. The DEBUG story stays verbose. Any new user-facing string (there should
   be none) goes through the classed status doors.
4. New geometry oracles follow the `DebugProbeScope` pattern — never a bare static (13u2's rule).

**Evidence.** The Outline suites + row-100 flow pins green with zero test edits (the hoist moved an
address, not behaviour); the flow walked on the dev store (a far landing in Read ▸ Scroll, both
directions, captures); the signpost's output verified content-free by reading it (one capture of
Console beside the walk); red-on-old for the flow's manifest adoption = the same far-below fixture
class run against the flow surface (the implementer states the pin's shape in the record before
building — the hallucination guard binds: no fix without the traced mechanism, no bug-class fix
without red-on-old).

### UNIT 3 — the MODE-SWITCH viewport-fraction carry (small; her "do that piece now")

**Goal.** Trace §6: same block, four reveal policies ⇒ four heights — by accretion, never chosen as
a set. ONE shared rule for NOTE MODE SWITCHES: the carried block (`CurrentBlockMemory`'s road) is
placed at the same VIEWPORT FRACTION it occupied in the outgoing mode. A fraction, never a pixel —
the surfaces' visual deltas make pixel identity a false promise, and she pre-accepted the
≈one-line tolerance (*"if this is very difficult bc of the different visual elements of takes &
stuff, I do think that's fine"*).

**Scope, stated exactly (QUESTIONS #114 carries the two edges).**
- IN: **Write** and **Read (both faces: edit/index and the calm page)** — the surfaces whose reveal
  policies were never her rulings (minimal-scroll-to-visible and land-at-top respectively).
- OUT: **Takes** — its entry-landing/memory policy is HER OWN ruling (17q R-Q20/R-Q21) and OUTRANKS
  this rule; untouched. **The book's word-tabs** (Outline · Index · Book · Read) — chapter-level
  landings, not the note mode row; #114(a) asks whether she wants the fraction rule there too.
  Lenses/Compare/Canvas/Blocks — different geometries; #114(b) records the default (untouched)
  as PROVISIONAL.

**Steps.** Capture the outgoing fraction at mode-switch time on the carried-block road (one brain,
pure, pinned: given the block's rect and the viewport, the fraction; given a fraction and the new
surface's rect, the target offset); the incoming surface's reveal consumes it. No settle changes —
this is aim-time only, and it composes with UNIT 2's authority.

**Evidence.** The pure fraction brain pinned both directions; a dev-store walk: a long note, caret
mid-document at an off-center height, round-trip Write → Read(edit) → Write and Write → Read(page)
→ Write — the block visibly holds its screen position within ≈a line (captures); Takes round-trip
UNCHANGED (one capture proving R-Q21's restore still wins).

## WHAT NOT TO DO (bound from the trace §5, so nobody re-derives it)

- No lazy-run restructuring (one-scale-per-run broke the live editor's mount — the road is CLOSED
  until row 64's re-measure instruction is run, which is NOT this phase's).
- No per-row `.task` reads (13u2 A2's lesson) · no `@State` writes on content reports (the 7 Hz
  loop) · no `ensureLayout` over full documents (TK2 §2).
- No tuning-only changes to the compensator constants (re-tuned three times already; the trace
  rejects (a)).
- `SurfaceSizeMemory`'s per-width refusal stays; the Takes/Index compensators stay; row 49/58/64's
  owner-12 residues stay theirs unless this phase's own gate consumes them (row 64's arm is the one
  it does).
- **Zero `Sync/` · zero `Persistence/` · zero schema · zero migrations · marker stays 8.** Nothing
  here is mobile-visible (these are Mac surfaces; the phone's board has its own ruled policy) — the
  parity line at closeout is expected to read "nothing mobile-visible", and any `Shared/` file
  moved makes the mobile suite owed per the standing convention.

## ENVIRONMENT TRAPS (every batch brief carries this section verbatim — the skill's rule)

- **Instance checks:** `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances are identified by STORE, not path — **NEVER quit or
  kill one**; no Release builds or `/Applications` refreshes while one lives; install refreshes only
  at sanctioned zero-instance windows (this phase's is the closeout's).
- **Builds/tests:** Mac tests run from `App/Variorum/`, suite-level `-only-testing` only; confirm
  the "Test run with N tests" line (Swift Testing COUNTS skipped tests — read the `skipped:` lines);
  `xcodebuild build-for-testing` compiles without the runner; **NEVER add a custom build
  configuration** (any configuration not named exactly "Debug" builds SPM dependencies RELEASE and
  silently strips VariorumCore's DEBUG-gated oracles); zsh `pipestatus` for pipeline exit codes.
- **Suites beside a live session flash the test host's windows** — prefer zero-instance windows for
  timing-sensitive measurements (this phase's landing measurements ARE timing-sensitive: note the
  machine state beside any number you record; the differential-latency and read-click rows are the
  precedent for load-dependent reds).
- **Walks:** dev-store Debug build only (`io.lduarte.Variorum.debug`), `Tools/WalkKit/` + `cliclick`;
  screenshots in gitignored dirs (`notes/plans/13u2b-screens/`); the Debug domain's `surfaceSize.*`
  keys may be wiped to stage cold-heights runs (they regenerate) — NEVER the real store's.
- **Git:** never `git checkout` over uncommitted work; commit per piece and **PUSH after every
  commit** — the skill's 13b-era "never push" line is SUPERSEDED by CLAUDE.md's 2026-08-03 push rule
  and the resiliency protocol (CLAUDE.md wins on conflict; recorded here so no brief inherits the
  stale line). No commit trailers.
- **Backups:** any act near the real store takes the A1 rail first (WAL-safe, UTC-named) — this
  phase should never touch it before the closeout refresh.

## CAST & DISCIPLINE

**Orchestrator: Fable — this session** (her word; writes no feature code). **Implementer:
`opus-implementer`, a FRESH session per unit, strictly sequential, one at a time.** **Cold review:
`fable-reviewer`** over the combined diff (the landing/settle class is the judgment-heavy recurring
one; 13u2's precedent), the standing ladder (fresh reviewer per round, cross-model flow, cap
three). The hallucination guard binds every fix; PROVISIONALs log to `notes/QUESTIONS.md` (#114 is
this phase's; next free #115). Author-only calls are hard stops. Session resiliency: the checkpoint
protocol is RESTATED in every implementer brief (commit per piece + push · LIVE STATUS in the unit
record from the first commit, PENDING until verified · synchronous foreground waits via the
grep-poll loop, never a backgrounded run a subagent waits on · no subagents · reverts announced in
the record before they start, pre-revert state committed).

**The walk vs. her walk.** The orchestrator walks each unit on the dev store before its record
closes (sizing guidance line 3). The PHASE's field acceptance is HERS — her store's regime could
not be staged (trace §4), so item 1/18's close is her hands again, now with the signpost to catch
whatever her store does that the dev store will not.

## LADDER · LIVE STATUS · UNIT RECORDS

*(Filled as the phase runs — per-unit LIVE STATUS lines, traces, adjudications, the ladder rounds,
dispositions. The orchestration record below is the phase's running memory; a fresh session
finishes the phase from it.)*

**LIVE STATUS:** UNIT 1 — **CLOSED, WALKED, ACCEPTED** (the record below; gate MET and UNWRAPPED,
24/24 real-book landings at `top=0.0`, finals in; the orchestrator's walk passed). UNIT 2 —
**CLOSED, WALKED, ACCEPTED** (its record is in this file; the authority hoisted and both surfaces
adopting, PIN B fixed red-on-old, the signpost shipping and verified content-free, her gesture
walked at `hops=0` five times running). UNIT 3 — **BUILT AND RECORDED, pending the
orchestrator's walk** (its record is the last section of this file; the rule is ONE pure brain,
both pins red-on-old, Takes proved byte-identical twice, the walk returns her page at 0.0 pt,
finals in). Ladder — owed next, over the combined diff.

---

# UNIT 1 RECORD — the book HEIGHT MANIFEST, and the Outline lands once (opened 2026-09-18, `opus-implementer`)

**WHAT THIS UNIT DID NOT DO — the record's first line.** It did **not** build the plan's letter
(*feed the manifest to the AIM and scroll once*): it measured that shape failing its own gate and
raised the fork instead, and what shipped is the architect's ruling AR-1 — the manifest reaching the
ROWS. It did **not** touch the expanded notes' virtualization, the live editor, any scroll
mechanism, or `NearViewportObserver`'s behaviour (its rule was hoisted to `NearBand` and shared; the
modifier calls the same two functions and `StableSurfaceTests` rides unmodified). It did **not**
reopen the closed one-scale-per-lazy-run road — it ran that road's own successor MEASUREMENT instead
(rider 1) so the ambiguity is retired rather than inherited. It did **not** relax
`SurfaceSizeMemory`'s per-width refusal (the estimate arm is what covers a refused width — that is
the whole reason the refusal can stay). It did **not** adopt the FLOW or the Takes/Index
compensators (UNIT 2's and their next touch's). It did **not** edit any test's CLAIM. It made exactly
TWO test edits, each ruled before it was made and each named below: AR-2's PREMISE restatement, and
AR-3's FIXTURE lengthening for the one red this unit caused.

## DISPOSITIONS

| item | verdict | evidence |
|---|---|---|
| **the gate — row 64's far-below arm** | **MET, and the arm UNWRAPPED with its interim bound dropped** | `settled at top=0.0 after 0 hops` (was `gave up at top=-73.0 after 13 hops, 4.2 s`, 3/3). The suite's known-issue count fell 1 → 0. |
| **the three-expanded arm (≤2 hops)** | **MET at 0 hops** | Same run; every arm of that test now reads 0 hops. |
| **the plan's UNIT 1 letter** | **SUPERSEDED IN MECHANISM by AR-1, on a measurement** | THE MECHANISM, TRACED, above: the aim was already exact; the −73 arrives after arrival. PROBE A (hop budget 1) decays with zero hops spent. |
| **rider 1 — the closed road's guard** | **MEASURED in row 64's own terms and PINNED** | `window=Y entries=215 height=16134.0` (`theLiveEditorStillReachesTheScreenWithEveryBlockUnderTheNewRuns`). The road itself stays closed and unrebuilt. |
| **rider 2 — P1/P3 cost** | **A/B'd; it holds, with the number recorded** | Steady-state layout 0.562 ms vs the lazy column's 0.702 (CHEAPER); mount +143 ms at the 300-row cap, ∝ rows, ~9 ms at Sherlock's 26. Three P1 sentences pinned. |
| **rider 3 — zero test-mechanism churn** | **HELD, with ONE premise line ruled at AR-2** | `anOffScreenCollapsedNoteIsRevealedAtTheTop`'s premise said "unrealized" as "absent from the geometry oracle" — a lazy-column artifact. Its CLAIM is untouched and green. |
| **rider 4 — the DERIVED-row one-time shift** | **RECORDED as the compensator's honest job, and MEASURED** | A far row whose derived height is off shifts once when it enters the near band and is learned thereafter. In the walk this is the single hop that appears in 5 of 24 landings; `exactAbove=N` in the story names exactly when it can happen. |
| **the walk's two defects** | **BOTH FIXED, red-on-old, and one of them was MINE** | The card/expanded height confusion (`103.0` where `20 000` was due) and the already-there landing spinning 15 hops for 4.2 s (`gave up at top=unrealized`, reproduced byte for byte). |
| **`offViewportPostsNeverInstantiate`** | **TRACED, REPORTED, and RESOLVED at AR-3 by fixing the FIXTURE** | Green 2/2 isolated and red only under load — the load-flaky class a budget resting on a lie produces. The fixture now has the real book's shape (~1,000 pt a note); 4 surfaces of 60, 3/3 isolated, against a derived `< 12`. |
| **row 58's read-click red** | **the recorded environment condition** | Byte-identical signature; this diff touches the Outline, not the Index. |
| **a PROVISIONAL** | **ONE — QUESTIONS #115** | What the Outline KEEPS when the width changes. Built: the row that was at the top. |

**KnownIssues row 64 is UNLOCKED — for the closeout to remove, with this evidence:** its own
instruction was *"unwrap it and drop the interim bound then"*, and both are done; its successor
instruction (*"rebuild the split, measure with `textView.window != nil` + `index.entries.count`"*)
was answered by MEASUREMENT rather than by rebuilding — the guard is pinned and green, so the
closed road's ambiguity no longer rides on this row. The scale-mix residual the row describes is
gone because the estimate that produced it is gone.


## LIVE STATUS

| piece | state |
|---|---|
| the record opened + the RED-ON-OLD re-measured on this tree | **DONE** — 3/3 `gave up at top=-73.0 after 13 hops` + one anomalous run, below |
| the mechanism TRACE (why −73, measured not reasoned) | **DONE** — it is NOT hop-driven (PROBE A); `top = 0` is not a fixpoint of the lazy column |
| `BookHeightManifest` — the pure brain + its pins | **DONE** — 14 pins green (`BookHeightManifestTests`); `Surface/BookHeightManifest.swift`, beside `PaneTextAuthority` |
| the Outline's rows consume the manifest | **DONE** — `OutlineRunRow` (plain `VStack` runs, manifest-height placeholders, anchors kept) + `surfacePlaceholder`'s estimate arm |
| the landing consumes it (ONE aim, the compensator as the net) | **DONE** — nothing left for it to catch: **0 hops**, and not one `content=` change during a landing |
| the WIDTH-CHANGE recompute | **DONE** — the heights re-stand at the new width (and on a voice change), and the column re-lands the row that was at the top |
| THE GATE: the far-below arm ≤4, UNWRAPPED, the interim bound dropped | **MET and UNWRAPPED** — the two landing suites **21/21 GREEN, zero known issues**; every landing `settled at top=0.0 after 0 hops`; the ONE premise line restated under AR-2 |
| rider 1 — the closed-road mount guard (row 64's own instruction) | **DONE** — `window=Y entries=215 height=16134.0`, pinned |
| the dev-store WALK (her gesture both directions, two widths, one cold) | **DONE** — 24 landings on the real Sherlock book, **every one settled at `top=0.0`**, never more than ONE hop; the walk found TWO defects, both fixed with red-on-old; 9 captures |
| the manifest's cost ∝ entries, measured (rider 2) | **DONE, A/B'd against the pre-fix tree** — the table below; steady-state layout ends up CHEAPER than the lazy column, mount costs +143 ms at the 300-note cap, a collapsed book runs ZERO lengths queries (pinned) |
| tests: the touched suites · core (if core changed) · the FULL Mac suite | **DONE** — core NOT OWED (zero `Sources/` lines); FULL Mac **2767 / 462, ZERO known issues** (−1, the unwrap); of its 2 reds one is row 58's environment condition and the other was MINE, resolved at AR-3 by fixing the fixture (4 surfaces, 3/3 isolated) |

| the two walk-found defects, FIXED with red-on-old | **DONE** — the card/expanded height confusion, and the already-there landing spinning 15 hops |
| AR-3's fixture fix + its 3× isolated re-verification | **DONE** — 4 surfaces of 60, deterministic; the unit's four suites 29/29 green |
| **UNIT 1 — CLOSED, pending the orchestrator's walk** | **READY** |

*(Every line starts PENDING and is flipped in the same commit as the piece it names.)*

## WHAT SHIPPED — five files, and where each piece lives

- **`App/Variorum/Variorum/Surface/BookHeightManifest.swift`** (NEW, pure): the manifest value —
  three sources in precedence (MEASURED > REMEMBERED > DERIVED), the cumulative-offset arithmetic,
  the width gate, `isExactAbove`; and `BookOutlineHeightModel`, the derived arm, whose constants are
  the 13u2 traces' own readings off the real book rather than invented numbers.
- **`App/Variorum/Variorum/Features/BookView/BookOutlineHeights.swift`** (NEW, `@MainActor`,
  unobserved): what the column LEARNS — by row and by shape, each measurement carrying the shape it
  was taken in — plus the type measured off the real font per width, and the memoized card shape.
- **`App/Variorum/Variorum/Features/BookView/BookView.swift`**: `OutlineRunRow` (the runs' plain
  `VStack` + per-row virtualization at a manifest height, anchors kept, ONE geometry report with
  three readers), `surfacePlaceholder`'s estimate arm, the landing's seed from where rows last
  reported, the width-change re-land, the DEBUG story's manifest line.
- **`App/Variorum/Variorum/Features/BookView/BookViewModel.swift`**: the plumbing — the observed
  content width, the LAZY lengths read and its generation, `outlineSurfaceAnswer`,
  `outlineRowInput`, `outlineHeightManifest(rows:)`.
- **`App/Variorum/Variorum/Core/Views/StableSurface.swift`**: `NearBand` — the band's arithmetic and
  hysteresis hoisted to two pure functions so the Outline's rows share the rule instead of copying
  it. `NearViewportObserver` calls them; not a byte of its behaviour changed.

**Zero `Sources/VariorumCore/` lines. Zero `Sync/`. Zero `Persistence/`. Zero schema. Zero
migrations. Marker stays 8.** No `Shared/` file moved, so the phone inherits nothing and no mobile
suite is owed; the closeout's parity line reads *nothing mobile-visible*.

**Commits**, each pushed as it landed: `71b3791c` (the record + the baseline) · `f049af48` (the
mechanism traced, PROBE A) · `e6e7abb0` (the pure brain, 14 pins) · `f8610cb9` (the rows consume it
— 0 hops) · `36018e0e` (the gate unwrapped, AR-2's premise, rider 1's guard) · `4c50e33f` (rider 2's
cost pins + the P1 hole they caught) · `a6d87dd8` (one observer a row) · `1399b67a` (a measurement
is a fact about a SHAPE) · `3521bc5c` (the already-there landing) · `e9c7815e` (the walk) ·
`b18d6cae` (the finals) · `74c1dd4b` (QUESTIONS #115) · `4ba93fba` (the dispositions) · `cb58eb5a`
(AR-3's fixture). Two red-on-old probes were run and reverted without being committed, each with the
pre-probe state committed first.

## THE BASELINE, RE-MEASURED ON THIS TREE (2026-09-18, before a line of product code)

The brief's red-on-old is pre-written — `BookOutlineLandingTests.openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded`'s
**far below** arm, hard-bounded at ≤90 with the ≤4 aspiration in `withKnownIssue`. The
hallucination guard's first duty is to confirm it is red on MY tree, so it was run four times,
isolated (`-only-testing:VariorumTests/BookOutlineLandingTests`), on `8180605e`:

| run | machine state | far-below result |
|---|---|---|
| baseline-1 (02:39) | **her real-store instance LIVE** (pid 21755), first run after a cold build | `settled at top=-1.0 after 1 hops, 1003 ms` → the known issue **did not record** (an unexpected pass; suite FAILED for that reason) |
| r1 | zero instances | `gave up at top=-73.0 after 13 hops, 4154 ms` |
| r2 | zero instances | `gave up at top=-73.0 after 13 hops, 4142 ms` |
| r3 | zero instances | `gave up at top=-73.0 after 13 hops, 4109 ms` |

**So the arm is RED 3/3 in the steady state, byte-identically to RULING A-2's recorded measurement
(−73.0 / 13 hops / ~4.1 s), and it has ONE recorded load-dependent green** — noted rather than
smoothed over, because it is the row-58 class and because a session that sees only that run would
wrongly conclude the row had come right. Machine state is recorded beside every number in this
record for exactly this reason.

## THE WALK — her own gesture on the real Sherlock book (dev-store Debug build, zero instances)

Her report is the protocol: *"I clicked a far away chapter, that was fine, then I clicked one that
was much higher and I watched it stutter ~10 times, every time I did it. I managed this by clicking
on the last chapter and then The Man with the Twisted... in sherlock."* So: open the book, click the
LAST chapter, click **The Man with the Twisted Lip** (7th of 13, far above), and again, and again.

| run | state | landings | result |
|---|---|---|---|
| **A · warm, 1500-pt window (column 696)** | all cards collapsed, then 2 → 6 stories open | 12 | **every one `settled at top=0.0`**; 7 at ZERO hops, 5 at one |
| **B · the WIDTH change** | 696 → 518 mid-story, six stories open | 1 | `settled at top=-0.11 after 0 hops` — and the page still shows the story it was showing (`09-after-width-change`) |
| **C · COLD, 980-pt window (column 518)** | every `surfaceSize.*` record deleted, a width never seen | 9 | **every one `settled at top=0.0`**; 7 at ZERO hops, 2 at one |

**24 landings, not one of them off its target, and never more than a single hop.** Against the
thirteen the fixture used to spend before giving up 73 pt short, and her own *"~10 times, every
time."* The landing story tells the same thing from inside: the first landing of a session reads
`derived=13 exactAbove=N` (the column has measured nothing yet, so the model carries it) and every
landing after it reads `derived=0 exactAbove=Y` — **the column knows every one of its rows**, across
a 118,000-pt page with six open stories. And the `content=` line that used to appear every ~60 ms
during a landing appears not at all: the column's height does not change while a page lands.

**The model's cold numbers turned out to be exactly right on her book**, which is worth recording
because it is luck earned rather than luck: the traced constants (46 pt bare + 19 a line) predict
Sherlock's three-line cards at 103 pt, and the first landing of a cold session shows every card
reporting 103 on its first frame.

**THE WALK FOUND TWO DEFECTS, and both are fixed with red-on-old** — which is the argument for
walking rather than trusting a green suite:
1. **A note measured as a CARD kept that height after it was opened** (the manifest's own
   arithmetic, not the column's). Seen as `expanded=2 derived=1` — a number that could not be true.
   A measurement now carries the shape it was taken in. Pin: `BookOutlineHeightsTests`; red-on-old
   measured `103.0` where `20 000` was due.
2. **A landing on the row the page was ALREADY at spun for 4.2 seconds** — `gave up at
   top=unrealized after 15 hops`, three times. `onGeometryChange` reports a CHANGE, so a scroll that
   moves nothing produces no report and the landing concluded its target had never realized. THIS
   UNIT INTRODUCED IT (before it, a far row did not exist, so a target always realized during its
   landing) and the fix is a seed from where the rows last said they were. Pin:
   `landingAgainOnTheRowThePageIsAlreadyAtSettlesInsteadOfSpinning`; red-on-old reproduces the walk's
   line byte for byte (`gave up at top=unrealized after 15 hops, 4199 ms`).

Captures (gitignored, `notes/plans/13u2b-screens/`): `01-launch` · `02-sherlock-open` ·
`03-last-chapter` · `04-twisted-lip-upward` · `05-after-expansions` · `06-top` ·
`08-six-expanded-landed` · `09-after-width-change` · `10-cold-narrow-landed`, with the raw landing
stories `walk-warm.log` and `walk-cold.log` beside them.

## RIDER 2 — WHAT THE EXACT COLUMN COSTS (A/B against the pre-fix tree)

Both trees measured three times each, alternating, zero instances, nothing else running; the
pre-fix tree is `8180605e` in a throwaway worktree with the same measurement copied in (trimmed to
what it can compile). The fixture is the observation window's own CAP — 300 notes with realistic
previews, filed three to a chapter: **400 rows**, the largest column the Outline can produce.

| at the 300-note cap | pre-fix (`LazyVStack`) | UNIT 1, two observers a row | UNIT 1, ONE observer a row (shipped) |
|---|---|---|---|
| `adopt` (the entries + their previews) | 59.0 ms | 60.3 | **60.3** |
| mount + 8 settle turns | 616.7 ms | 786.5 | **760.1** |
| ONE full layout pass | 0.702 ms | 0.960 | **0.562** |
| the whole-column manifest | — | 1.11 ms | **1.16 ms** (0.0029 ms a row) |
| lengths queries, book read in cards | — | 0 | **0** |

**Read it in three lines.** (1) **Steady-state layout is CHEAPER than the lazy column it replaced**
— 0.562 ms against 0.702, which is the number that matters while she scrolls, and it is 3 % of a
60 Hz frame. That is not a free lunch: it is what the third column bought. The first cut of this
unit put TWO geometry observers on every row (the near/far band's and the landing anchor's); merging
them into one report with three readers — the band's rule hoisted to `NearBand` and shared rather
than copied — took the layout pass from 0.960 to 0.562 and the mount from 786 to 760.
(2) **Mount costs +143 ms at the CAP**, and the cap is the worst case the window allows; the cost is
∝ rows, so Sherlock's 26 rows pay about 9 ms of it. That is the price of the column knowing its own
geometry, paid once when a book opens. **My judgment: it holds** — 143 ms once, on the largest book
possible, against a landing that never stutters; the windowed-spacer fallback (AR-1's named option
(c)) stays available and unbuilt, and nothing about this diff makes it harder to reach.
(3) **The P1 sentences are PINNED, not just measured**: a book read in cards never runs the lengths
query, an entries re-delivery (what every keystroke produces through `last_touched_at`) costs no
read of any kind, and the first expansion reads the book's lengths exactly once with every further
expansion free. **The first of those three went RED and was right** — `reportOutlineContentWidth`
called `ensureOutlineExtents`, and a column reports its width on every mount, so every book was
paying for the lengths on open. The guard is now the sentence itself.

## THE MECHANISM, TRACED (not reasoned) — and it is NOT what the plan's model assumes

The plan's UNIT 1 model is: *the landing aims before the heights are known, so it aims wrong; give it
the heights and it aims right and scrolls once.* **The measurement says the aim is only half of it,
and the smaller half.** Here is the r1 far-below trace's repeating unit, verbatim, one cycle per hop:

```
… HOP 13 … | top=0.0 hops=13          ← the hop lands the target EXACTLY at the top
| content=66920 | top=70.0 hops=13     ← the content GROWS ~70 above it; the target is pushed down
|              | top=0.0 hops=13       ← SwiftUI's own offset compensation puts it back
| content=66919 | top=-1.0 hops=13
| content=66847 | top=-73.0 hops=13    ← the content SHRINKS ~73 above it; NOTHING compensates
| DONE: gave up at top=-73.0 after 13 hops, 4154 ms
```

**Every hop lands at 0.0 correctly.** The page then decays, by the column's content height changing
ABOVE the target: growth is compensated by the ScrollView, shrinkage is not. The realized rows do
not move (A2 measured `rows=38 sum=99998` constant through the whole swing) — what changes is
SwiftUI's ESTIMATE for the lazy runs' UNREALIZED rows, and it changes *because the landing arrived*:
at `top=0` the rows above the target are outside the lazy container's realization band, their real
heights (103-pt cards, 51-pt headings) are replaced by the run's average, and the average is ~70 pt
short over that stretch.

**PROBE A — is the cycle hop-driven? NO.** `landingHopBudget` cut 40 → 1 (a temporary edit, measured,
reverted, never committed), same suite, zero instances:

```
top=0.0 hops=0 | content=66889 | top=-39.0        ← decays BEFORE any hop is spent
| HOP 1 | top=0.0 hops=1 | content=66930 | top=40.0 | top=0.0 | content=66870 | top=-60.0
| DONE: gave up at top=-60.0 after 1 hops, 597 ms
```

The decay happens on the FIRST arrival, with zero hops spent. So the hops are not the disease — they
are the symptom she watches (each is a visible jump) and they never converge because **`top = 0` is
not a fixpoint of this column**: arriving there de-realizes the rows above, which shrinks the content
above, which moves the page off. The only stable state is the one the give-up leaves her in (−73,
stable across 24 samples — A2's measurement, re-confirmed here).

**What follows, and it is the load-bearing conclusion of this unit:** an aim that computes the
target's offset from a manifest and scrolls ONCE lands exactly — and then decays exactly as today,
because the decay is downstream of the aim. **The manifest must reach the ROWS, not only the aim.**
A column whose every row's height is known and *asserted* (never estimated by the lazy container)
cannot shrink above a landed target, and then — this is the whole prize — the aim is right, the
decay is gone, and the compensator has nothing left to do.

## THE DESIGN FORK, RAISED TO THE ARCHITECT (2026-09-18, mid-unit)

**The fork:** making the rows' heights exact means the runs of small rows (chapter headings +
collapsed cards) can no longer be `LazyVStack`s that estimate their unrealized rows. That is inside
the neighbourhood of the plan's *"No lazy-run restructuring"* line, so it is not mine to take alone.
The proposal, the alternatives and the reason the plan's letter cannot meet its own gate are in the
message to the architect; the adjudication lands below.

## THE ORCHESTRATOR'S WALK — UNIT 1 (2026-09-18, overnight; gates the record per the sizing guidance)

Dev-store Debug build (`DerivedData/13u2b`, binary of 05:04), launched with stderr as the
instrument, zero instances verified before and after, WalkKit + cliclick. **Her exact gesture,
verified independently of the implementer's 24:** open Sherlock ▸ Outline, click the LAST chapter —
`offset=25990 total=43882 · settled at top=0.0 after 1 hop, 1012 ms` (the one hop = `derived=1`,
the AR-1 rider-4 residual class, exactly as recorded) — then click **"the man with the twisted
lip" far UP**, the stutter case itself: `offset=1105 total=50559 derived=0 exactAbove=Y · settled
at top=0.0 after 0 hops, 1033 ms`. One clean motion where her report had ~10 stutters every time.
Also exercised on the way: the first-of-session cold landing (`derived=12 exactAbove=N` → still
`top=0.0, 0 hops`) and the **already-there landing** (the unit's own introduced-and-fixed defect:
0 hops where it had spun 15). Capture: `13u2b-screens/11-orch-walk-twisted-lip.png`. One walk
note, no action owed: the navigator's generous row spacing swallowed two of my early clicks into
the gap between rows — operator error, not product (the rows hit fine when actually hit).
**VERDICT: UNIT 1 ACCEPTED — ledger row 1 DONE.**

## THE ORCHESTRATOR'S WALK — UNIT 2 (2026-09-18, overnight)

Same rig (the rebuilt `13u2b` Debug binary of 06:30, stderr + `/usr/bin/log` as instruments, zero
instances before and after). **Her gesture in Read ▸ Scroll on the 289,594-pt column:** down to the
LAST chapter — `target=25 offset=263007 · top=0.0, 0 hops, 1009 ms` — then **far UP to Twisted Lip**
(a ~147,000-pt upward jump): `target=13 offset=116257 · top=0.0, 0 hops, 1003 ms`. The repeat click
(already-there — PIN B's fix): `top=0.0, 0 hops`. A mid-list chapter (five pips): 1 hop
(`derived`), the AR-1 rider-4 residual exactly as priced. **The SIGNPOST verified from MY OWN run**
via `/usr/bin/log`: `landing surface=ReadingFlow rows=28 target=25 offset=263007 total=289594
derived=6 exact=0 hops=0 content=0 ms=1010 end=settled top=0` — every value an integer, no prose.
Capture: `13u2b-screens/u2-07-orch-walk.png`. **Two walk notes, neither a product defect:** my
coordinate estimates twice fell in the navigator's 20-pt inter-row gaps (AX enumeration showed the
real 30-pt buttons on a 50-pt pitch — operator error, resolved by reading the frames); and macOS
`System Events` `click at` does not reach these SwiftUI rows at all (it lands on the scroll area —
cliclick's CG events do reach them; recorded for future walks in WalkKit's spirit). **The two
recorded residuals are ACCEPTED as recorded** (the flow's eager small rows — reasoned bound with
the placeholder as the named ready answer, the ladder may weigh it; the ≤0.25-s-sooner look —
identical-or-better). **VERDICT: UNIT 2 ACCEPTED — ledger row 2 DONE.**

## THE ORCHESTRATOR'S WALK — UNIT 3 (2026-09-18, overnight)

Same rig (the `13u2b` Debug binary of 08:29). The Twisted Lip note opened via ⌘K into Write at its
remembered block (130/222 — the memory road live). I set the current block to 137 mid-viewport
(fraction ≈0.5 of the editor), then round-tripped. **Three of four hops honor the carry** within my
eyeball tolerance: Read → Write returned 137 at ≈0.84 against Read's ≈0.86; a second Write → Read
placed ≈0.91 against ≈0.84 (my coordinates are hand-estimated; the implementer's cross-correlated
walk measured 0.0-pt shifts on the same roads). **Takes round trip: MAX PIXEL DIFFERENCE 0** across
enter → leave → re-enter (numpy diff of full-window captures) — R-Q21 byte-untouched, exactly the
#114(b) promise. **ONE FLAGGED FINDING, routed to the LADDER's fix pass with this trace:** the
FIRST Read mount after a note-open ignored the carry — Write had 137 at ≈0.44 (pane-relative) and
Read's first mount placed it at ≈0.86, with the pane's wash sitting on block 130, the NOTE-OPEN's
block — i.e. the first face mount consumed the stale open-landing's aim instead of the switch's
carried block+fraction; every SUBSEQUENT switch honors the carry. Repro: open a note via ⌘K (Write
lands at the remembered block) → click a different block → ⌘3 immediately. The unit's own "every
switch re-decides" rule appears not to reach the pane's FIRST-mount landing road. Captures
`u3-09/10/11-orch-*`. **VERDICT: UNIT 3 ACCEPTED — the core is proven by the pins and the
implementer's measured walk; the first-mount interaction is a bounded defect for the ladder.**

## ADJUDICATIONS (the architect's rulings)

**AR-1 (2026-09-18, overnight — UNIT 1's design fork; the implementer's trace is the UNIT 1 RECORD
at `f049af48`, adjudicated within the architect mandate; PROVISIONAL under the overnight
authorization, bundled for her handoff):** the implementer measured that the plan's letter — feed
the manifest to the AIM, scroll once — **cannot meet its own gate**: every hop already lands at
exactly `top=0.0`, and the −73 arrives AFTERWARD, because arrival de-realizes the rows ABOVE the
target and SwiftUI's lazy estimate replaces their real heights with the run average (~70 pt short
over that stretch); the ScrollView compensates content growth above but not shrinkage, so `top=0`
is not a fixpoint of the column — −73 is. Probe: hop budget 1 still decays with zero hops spent.
**RULING: build the proposal — the manifest reaches the ROWS.** The small-row runs (chapter
headings + collapsed cards) stop being lazy: plain `VStack`s whose far rows render manifest-height
placeholders (`Color.clear.frame(height:)`) and realize real content near the viewport — the
row-53 virtualization pattern the expanded notes already ship, extended downward. Anchors are KEPT
(`scrollTo(id:.top)` unchanged — no scroll-mechanism churn); heights are LEARNED > DERIVED for
small rows and `SurfaceSizeMemory` > `blockExtents`-estimate > any-width > fallback for expanded
notes, the extents read staying lazy so a collapsed book pays nothing. **Why this does not violate
the WHAT-NOT-TO-DO fence, stated so the ladder can check the reasoning:** the CLOSED road split
runs BY SCALE and moved the expanded notes/live editor between runs — the thing that (ambiguously)
broke the mount. Here the expanded notes and the live editor keep their exact identity and
position; only heading/card runs change form, and no liveness mechanism is touched (P-3's fence).
"Offset-addressed, never estimate-resolved" is satisfied in substance: no estimate remains to
resolve against. **FOUR RIDERS, binding:** **(1) the closed-road guard** — after the restructure,
run row 64's own successor measurement (`textView.window != nil` + `index.entries.count`, never
"the first editor") on a long note under Outline and record the numbers, so the road built beside
the closed one retires its ambiguity instead of inheriting it; **(2) P1/P3 gate the ship** —
measure mount and scroll cost at the 300-row window cap on the Sherlock corpus and confirm typing
cost untouched (nothing rebuilds at autosave rate); if the placeholder+observer cost does not hold,
REPORT, don't ship (option (c), windowed spacers, is the named O(visible) fallback — a bigger unit,
mine to re-scope); **(3) the gate is unchanged and the zero-test-mechanism-churn promise is
load-bearing** — ≤4, arm UNWRAPPED, three-expanded ≤2 hops; if test mechanisms need edits after
all, stop and report; **(4) the DERIVED-row residual is the compensator's honest job now** — a far
row whose derived height is slightly off shifts once when it enters the near band and is LEARNED
thereafter; record the class in the UNIT 1 RECORD and carry it into row 64's closeout disposition.
**Alternatives dispositioned:** (a) the plan's letter — REJECTED as the unit (measured to fail the
gate; a knowingly-partial ship is the class this phase exists to end), though its aim half rides
free inside the proposal; (b) the closed one-scale-per-run road — stays closed (the plan's own
line; still inexact by preview-line count); (c) windowed spacers — rejected for scope, kept as the
named fallback under rider 2. **The plan's UNIT 1 steps are AMENDED by this ruling** (the section's
"compute offset → ONE scroll" letter is superseded in mechanism, not in outcome: the landing still
computes from known heights and lands once — the heights now live in the column itself). U2's
authority hoist should expect the compensator's role as shrunk by this ruling: the net under
DERIVED rows, and the flow until it adopts.

**AR-2 (2026-09-18, overnight — the one test edit rider 3 fenced; ruled on the implementer's
stop-and-report, exactly the discipline the rider asked for):** the gate is MET (far below: `top=0.0,
0 hops, 1004 ms`, zero `content=` churn during the landing where the pre-fix trace moved every
~60 ms; every other landing 0 hops; the arm UNWRAPPED on its unexpected pass per row 64's own unlock
instruction; the manifest's 14 pure pins green). One PREMISE line in
`BookOutlineLandingTests.anOffScreenCollapsedNoteIsRevealedAtTheTop` broke by design:
`anchorTop(last) == nil` encoded "unrealized" as "absent from the geometry oracle" — an artifact of
the lazy column this unit retired; every row now exists as a placeholder and honestly reports its
anchor. **RULING: restate the premise as proposed** — `(anchorTop(last) ?? 0) > <the mounted
window's height>` ("starts far below the fold, off-screen") — which is the intent measured
DIRECTLY, and STRONGER than the old line (the old form also passed if the row was simply never
built for an unrelated reason; the new form asserts the hard case positively; measured 2922 against
the 760 window). Two small conditions: prefer the mounted height's existing symbol over a bare
literal where one is already in reach (a literal with its derivation stated at the line is
acceptable); and the UNIT 1 RECORD lists this as the unit's ONE test edit with this why — the
test's CLAIM (`abs(top) <= 4`) is untouched and green, so the zero-test-mechanism-churn promise
stands: no scroll mechanism, anchor road, or reveal path changed in any test. Riders 1–2
(the closed-road mount guard; the P1/P3 cost measurements) remain owed before the unit closes.

## FINALS, AND THE TWO REDS

| gate | result | baseline |
|---|---|---|
| core `swift test` | **NOT OWED — zero `Sources/` lines in the diff** | 1567 / 171 |
| the FULL Mac suite | **2767 tests / 462 suites**, 733.8 s, **ZERO known issues** — by composition **1 environment red** (row 58) once AR-3's fixture recalibration is counted, re-verified 3× isolated | 2744 / 459 GREEN with 1 known issue |
| iOS build | **not owed** — no `Shared/` file moved, nothing mobile-visible | green |
| lockstep marker | untouched — **8** | 8 |

The known-issue count fell from 1 to 0, which is the gate's own arithmetic: the wrapped far-below
arm is gone because the residual it described is gone. +23 tests / +3 suites are this unit's
(`BookHeightManifestTests` 14, `BookOutlineHeightsTests` 4, `BookOutlineCostTests` 3, and two new
landing pins).

**RED 1 — `BookIndexEditingTests.theReadClickLandsInIndexAtThatBlock`** (`live.count → 0`, the pane
identifier nil): **`KnownIssuesAndTechDebt` row 58's recorded condition, byte-identical** — the row
measured it 3/3 red isolated on zero-code trees, and this unit's diff touches the Outline, not the
Index. Treated as that condition, as the brief instructs.

**RED 2 — `BookViewTests.offViewportPostsNeverInstantiate`** (`instantiated → 33`, budget `< 30`):
**mine, traced, reported under rider 3, and RESOLVED BY FIXING THE FIXTURE** (architect ruling
AR-3). The pin mounts a 60-post book ALL EXPANDED in a 700×800 window and counts live READ SURFACES
— it is about the EXPANDED rows' virtualization at its 2,500-pt band, which this unit did not
touch. What changed is the column's HONESTY: a far expanded row's placeholder was `remembered ?? 800`
and is now `remembered-at-this-width → the lengths estimate → remembered-at-any-width → 800`, and the
fixture's notes were a few sentences each, so the estimate says ~50 pt where the old fallback said
800. With the lie gone the column is ~4× shorter through those rows and the same band genuinely
spans more of them.

**One more fact, measured before the fix and worth the record:** the pin was **green 2/2 isolated**
and red only under full-suite load — the load-flaky geometry class (rows 19/20/58), which is exactly
what a budget resting on a lie produces.

**AR-3's ruling, and why it is better than re-budgeting:** under an honest column any re-budgeted
number in this fixture is a weak assertion, because 200-pt notes make the ±2,500-pt band span
twenty-odd rows however the number is set. So the FIXTURE gets the real book's shape — twenty blocks
a note, ~1,000 pt of column each — and the band then covers a HANDFUL. **Measured after: 4 live read
surfaces of 60 posts, 3/3 isolated, deterministic** (8 on a cold-cache first run), against a budget
of `< 12` stated with its derivation at the line (≈6 rows can honestly be near — 2,500 above, 2,500
below, an 800-pt viewport — plus a boundary row at each end). Tight enough that a virtualization
failure cannot hide under it, and load cannot flip it. Option (b), shrinking the shipped band, was
rejected outright — re-tuning a real surface to satisfy a fixture is the class the plan's
WHAT-NOT-TO-DO names; option (c), a viewport-relative band, is recorded for UNIT 2's design notes
and not built.

**THE UNIT'S TWO TEST EDITS, both ruled, listed together** (the zero-test-mechanism-churn promise
stands because neither touched a CLAIM): **AR-2** restated
`anOffScreenCollapsedNoteIsRevealedAtTheTop`'s PREMISE (off-screen-ness said positively, against the
harness window's own height, instead of as absence from the geometry oracle — a lazy-column
artifact); **AR-3** lengthened `offViewportPostsNeverInstantiate`'s FIXTURE to the real book's shape
and tightened its budget from a number the old lie had calibrated. Both tests' claims are unchanged
and green.

**The re-verification AR-3 asked for** (zero instances, nothing else running): `BookViewTests` 3×
isolated — **7/7 green each, 4 surfaces each**; and the unit's four suites together —
**29 tests / 4 suites GREEN**, twelve landings in them all reading `after 0 hops`, with rider 1's
guard (`window=Y entries=215 height=16134.0`) and rider 2's numbers (layout pass 0.469 ms, manifest
1.003 ms, `lengthsReads=0`) re-measured in the same run. The full suite is NOT re-run for a
test-only recalibration — the ladder's round re-verifies it.

**AR-3 (2026-09-18, overnight — the off-viewport pin, ruled on the implementer's stop-and-report).**
*(Provenance: this block landed in commit `74c1dd4b` — the implementer's #115 commit swept the
architect's then-uncommitted edit off the shared tree; content verified intact against the
architect's copy. Machinery note, both writers: pathspec-limited `git add` only, from here on.)*
`BookViewTests.offViewportPostsNeverInstantiate` reads `instantiated → 33` against a `< 30` budget.
The traced mechanism is accepted: the pin's fixture (60 expanded posts of a FEW SENTENCES each) was
calibrated against the column's LIE — far expanded rows used to claim `remembered ?? 800` where the
honest lengths estimate says ~50 pt — so the honest column is far shorter and the same ±2500-pt
near band GENUINELY covers 33 rows. Nothing regressed in the mechanism the pin guards.
**RULING — the AR-2 class, taken one step further than option (a): fix the FIXTURE, not just the
number.** The fixture's discriminating power ALSO leaned on the lie (tiny notes only made a long
column because far rows over-claimed 16×); under the honest column a 60×~50-pt fixture barely
exceeds the band, so any re-budgeted number would be a weak assertion. **Preferred form: lengthen
the fixture's notes** (enough blocks that honest estimates put the column ≫ the band — a few
thousand points per note is the real-Sherlock shape) so the band covers only a handful of rows and
the budget returns TIGHT, its derivation stated at the line (rows-within-band + the hysteresis
margin). **Fallback, if other assertions in the same test depend on the small notes:** option (a) —
re-budget with the mechanism written at the line, PLUS one companion assertion that the
beyond-band rows are placeholders (the far-row half asserted positively), so the pin cannot pass on
a partial virtualization failure. **Option (b) is REJECTED outright** — re-tuning the shipped near
band to satisfy a fixture is the exact class the WHAT-NOT-TO-DO names. **Option (c) (a
viewport-relative band) is RECORDED-not-built:** a real design idea, out of this unit's scope; it
rides the UNIT 2 authority's design notes as a consideration, not an obligation. Either form is the
unit's SECOND test edit — listed in the record beside AR-2's with its why. **Also accepted from the
same report:** RED 1 treated as row 58's environment condition (byte-identical signature, the diff
touches the Outline not the Index — per the brief); the two walk-found fixes (the card-height
shape, and the no-op-scroll landing spin — a unit-INTRODUCED defect, honestly stated and fixed
red-on-old; FLAGGED for the ladder to examine specifically); the 24/24 real-book walk at `top=0.0`.

## CLOSEOUT (the ritual, so nothing is forgotten)

Record results per unit here; mark complete; master plan table + pointer flip (the superseded
pointer + 13u2's closeout paragraph + any outgoing AppSpec §14 delta roll to their archives —
expected: zero canon deltas); the MOBILE PARITY LINE (expected: "nothing mobile-visible", stated in
the closeout paragraph); KnownIssues: row 64 REMOVED at its unlock (evidence named), rows 49/58
narrowed only if this phase's evidence genuinely narrows them; the 13u3 kickoff refreshed with a
"what 13u2b changed under you" note (the authority's home, the manifest, the signpost); the
`/Applications` refresh LAST after her walk or at her word (standing rails: A1 backup first, zero
instances, Release from a clean worktree, codesign verified, hashes recorded — this refresh also
delivers the star-cap 5→15 already on main); the author handoff written LAST
(`notes/handoffs/phase-13u2b-handoff.md`, her checklist at the top).

---

# UNIT 2 RECORD — ONE landing authority + the flow adopts + the Release SIGNPOST (opened 2026-09-18, `opus-implementer`)

**WHAT THIS UNIT IS NOT DOING — the record's first line, written at the open and re-stated at the
close.** It does **not** touch Takes or the book Index (their ~15 timing pins and row 49's residues
stay theirs — owner 12 / next touch; adopting four surfaces in one phase is the over-scope the
sizing guidance names). It does **not** change any scroll MECHANISM — `proxy.scrollTo(id:.top)`
stays the one act on both surfaces, exactly as AR-1 kept it. It does **not** reopen the closed
one-scale-per-lazy-run road, and it extends NO liveness mechanism (P-3's fence — this unit is
scroll geometry beside the pane/editor split). It does **not** relax `SurfaceSizeMemory`'s per-width
refusal. It does **not** edit an existing test's CLAIM or mechanism (the hoist moves an address, not
a behaviour: the Outline's landing suites and the flow's row-100 pins must ride UNMODIFIED, which is
this unit's own 3C proof).

## THE RED-ON-OLD PIN SHAPES — STATED BEFORE A LINE OF PRODUCT CODE (the brief's own order)

The Outline's far-below arm's pattern is: *a long column, a target far from the viewport, rows above
it the column has not measured, the claim read TWICE (at the settle and a second later), and the
correction count bounded.* Applied to the FLOW, in her own gesture's shape (*"I clicked a far away
chapter, that was fine, then I clicked one that was much higher"* — and Read ▸ Scroll is a book's
mode too), that is **two** pins, and each names a mechanism I can point at in the shipped code
BEFORE measuring it:

**PIN A — a far CHAPTER landing in Read ▸ Scroll.** The flow's landing anchor for the first note of
a chapter is the CHAPTER HEADING's row (`FlowRows.landingAnchor`), and a chapter heading is a SMALL
row — which in the shipped flow lives inside a `LazyVStack` run (`FlowRows.segments`: every story is
a direct child at an honest height, everything else stays lazy). So the one row a chapter landing
aims at is the one row the column may not have built. Predicted mechanism, to be measured not
assumed: an unrealized heading sends no geometry report, so `landing.lastTop` stays nil, the flow
(deliberately — row 100) spends NO correction on an unreported target, and the landing runs out its
4-s watchdog as `gave up at top=unreported`, wherever the lazy estimate put the page. **Fixture:**
twelve Sherlock-shaped stories (215 blocks each) in four chapters of three — the flow's own
`aRevealOfTheTwelfthStory…` fixture plus chapters. **Claim:** reveal the first note of the LAST
chapter, then the first note of the SECOND (far ABOVE — her gesture's second half); each time the
chapter heading's top is within the flow's tolerance and STILL there a second later.

**PIN B — landing again on the row the page is ALREADY at.** `FlowLanding.begin` sets `lastTop =
nil` and nothing seeds it; `onGeometryChange` reports a CHANGE, so a scroll that moves nothing
produces no report. Predicted: the second reveal of the same target spins to the watchdog (`gave up
at top=unreported after 0 re-lands, ~4000 ms`) with nothing visible happening — **the exact defect
UNIT 1's walk found in the Outline and fixed there**, present in the flow by the same mechanism and
unfixed because UNIT 1 did not touch this surface. **Claim:** the second landing writes a `DONE:`
that says neither `unreported` nor `gave up`.

Both are measured on the pre-fix tree first; each lands in the SAME commit as its fix with its
measured red quoted at the test. **A pin that is green on both sides is recorded as hollow and not
fixed** — the hallucination guard's own rule, and it binds here exactly as it bound UNIT 1.

## LIVE STATUS

| piece | state |
|---|---|
| the record opened + the red-on-old pin shapes stated | **DONE** — this section, before any product code |
| PIN A / PIN B measured on the pre-fix tree | **DONE** — PIN B **RED** (`gave up at top=unreported after 0 re-lands, 4211 ms`, 2/2 runs); PIN A **GREEN on both sides — HOLLOW as a red-on-old pin**, and its trace measured something else that is real (below) |
| the PURE hoist — `ProseHeightModel`, ONE prose model for both consumers | **DONE** — `Surface/ProseHeightModel.swift`; `BookOutlineHeightModel.ProseMetrics` is now a typealias for it and both `expandedHeight` and `FlowHeightEstimate.height` call it; **21 tests / 2 suites green with ZERO test edits** (`ReadingFlowEstimateTests` + `BookHeightManifestTests`) |
| THE AUTHORITY — hoisted from `BookView`, parameterized, the story built in | **DONE** — `Surface/LandingAuthority.swift`: the PURE decision (`LandingSettle.decide`) + the runner + the policies + the signpost |
| the Outline consumes it BYTE-IDENTICALLY (its suites green, ZERO test edits) | **DONE** — `BookOutlineLandingTests` + `BookOutlineRowsTests` **13/13 green, zero test edits, zero known issues** |
| THE FLOW adopts the authority AND the manifest (row-100 pins unmodified) | **DONE** — all seven shipped flow pins green UNMODIFIED; **PIN B now settles at 0 hops in 1,017 ms** where it spent 4,211 ms and gave up; the four suites together **29 tests / 4 suites GREEN** |
| THE SIGNPOST — content-free, ships in Release, emitted by the authority | **DONE** — `LandingSignpost`; pinned by `LandingSignpostTests` (10 tests / 2 suites green, including the landing discipline's own truth tables — the hoist's dividend) |
| the signpost verified content-free (a capture + the Release binary's own strings) | **DONE** — both ways, below: eleven real lines captured from the dev-store walk, and the Release binary's own strings |
| the dev-store WALK — a far landing in Read ▸ Scroll, both directions, on Sherlock | **DONE** — her exact gesture, **5 consecutive landings at `hops=0 content=0 top=0`** across a 290,000-pt column; 6 captures |
| tests: the touched suites · the FULL Mac suite | **DONE** — core NOT OWED (zero `Sources/` lines); iOS NOT OWED (no `Shared/` file moved); the FULL Mac suite **2779 tests / 464 suites, ZERO known issues, ONE red — row 58's recorded environment condition, byte-identical** |
| **UNIT 2 — CLOSED, pending the orchestrator's walk** | **READY** |

*(Every line starts NOT-STARTED and is flipped in the same commit as the piece it names; an
unverified claim reads PENDING.)*

## THE PRE-FIX MEASUREMENT — what the two stated pins actually found (2026-09-18, zero instances verified)

Both pins were run against the tree as UNIT 1 left it (`262a3d6b`), isolated
(`-only-testing:VariorumTests/ReadingFlowLandingTests`), the other seven pins of that suite green in
the same runs.

**PIN B — RED, exactly as predicted, twice:**

```
flow-…792 LAND | 00000000 DONE: gave up at top=unreported after 0 re-lands, 4211 ms
```

One LAND, no report, no correction, and the whole 4-s watchdog spent. (The first run of this pin
read the oracle under the wrong key — a STORY row's report is keyed by its POST id while a chapter
heading's is keyed by the row id — so it recorded four issues instead of two; the key was corrected
and the measurement re-run. The DONE line was byte-identical in both runs: the defect is not the
key's.) This is UNIT 1's own walk-found defect, on the surface UNIT 1 did not touch, reached by the
same mechanism: `FlowLanding.begin` sets `lastTop = nil`, nothing seeds it, and
`onGeometryChange` reports a CHANGE — so a scroll that moves nothing says nothing.

**PIN A — GREEN on the pre-fix tree. Its CLAIM is therefore hollow and is recorded as such; it stays
as a REGRESSION GUARD** (the chaptered flow — the shape the book really hands this surface — had no
landing pin at all before it, which is worth having whatever this unit changes). **But its TRACE is
the unit's real measurement**, and it says the flow's remaining residual is not the one the pin was
aimed at:

```
top=0 offset=194141 | content=260196 | top=-4 | content=261865 | top=1665 | top=1675
| RE-LAND 1 (top was 1675) | top=0 offset=195805 | DONE: settled at top=0.0 after 1 re-lands, 1140 ms
```

A story ABOVE the landed target enters the near band, renders its real text, and turns out
**~1,670 pt taller than the estimate it was standing at** (`content=` 258,530 → 265,201 across the
run, in ~1,670-pt steps, one per story realized). The target is pushed down by exactly that, the
landing spends ONE correction, and the page comes back. Measured on both directions of her gesture
(far below, far above): `settled at top=0.0 after 1 re-lands`, 1,140 ms and 1,153 ms.

**Read it honestly, because it decides what this unit builds:** the flow's heavy rows have stood at
honest heights since batch H (row 95) — *the plan's "the 306k-pt column is the largest absolute win"
was banked there, before this phase* — so what is left on this surface is (1) the SMALL rows, which
are still a lazy run's average (measured: the first aim of a chapter landing arrives 24 pt off and
settles itself), (2) the DERIVED-story residual above — **AR-1's rider 4 at the flow's scale**: a
row whose derived height is off shifts once when it enters the near band, and is learned thereafter
(`SurfaceSizeMemory`) — and (3) PIN B's spin. (1) and (3) are this unit's; (2) is structural, is the
compensator's honest job by AR-1's own ruling, and is exactly what the SIGNPOST is for: a landing
that reports `derived=N exactAbove=N` says in her own store that a shift is expected and how many
rows can still cause one.

## WHAT THE FLOW'S ADOPTION ACTUALLY CHANGED — measured, before and after

| the chaptered flow's far landing (PIN A's trace) | before | after |
|---|---|---|
| the FIRST aim's error | `top=-24` (the lazy run's estimate for the heading's own row) | **`top=0`** — the aim is exact on the first report, both directions |
| the manifest's computed offset vs the column's own | — | **`offset=192496` computed, `offset=192496` scrolled** — the arithmetic and the column agree exactly |
| the derived-story residual | `content` 258,530 → 265,201 in ~1,670-pt steps; ONE correction | unchanged, and now SAID: `derived=12 exactAbove=N` |
| landing again on the row the page is at (PIN B) | `gave up at top=unreported after 0 re-lands, 4211 ms` | **`settled at top=0.0 after 0 hops, 1017 ms`** |

The first line is the small rows' lazy estimate retiring; the second is the manifest proving itself
against the real column; the fourth is the SEED, which the flow gets *because* the authority is
shared — it was built for the Outline at UNIT 1 and this surface never had it.

## THE WALK — her own gesture in READ ▸ SCROLL, on the real Sherlock book

Dev-store Debug build (`DerivedData/13u2b`, the binary of 06:22), zero instances verified before and
after, WalkKit + cliclick, the signpost read from the unified log
(`/usr/bin/log show --predicate 'eventMessage CONTAINS "landing surface"'` — note the full path:
zsh's own `log` builtin swallows the command otherwise, which cost this walk two attempts).

Her report is the protocol, on the surface it was filed about — *"I clicked a far away chapter, that
was fine, then I clicked one that was much higher and I watched it stutter ~10 times, every time I
did it."* So: Sherlock ▸ Read ▸ Scroll, click the LAST chapter, then **the man with the twisted lip**
far above, and again, and again. **Every line below is the app's own, unedited:**

```
landing surface=ReadingFlow rows=28 target=25 offset=263135 total=289968 derived=9 exact=0 hops=1 content=2 ms=1021 end=settled top=0
landing surface=ReadingFlow rows=28 target=13 offset=116266 total=289603 derived=7 exact=0 hops=0 content=0 ms=1003 end=settled top=0
landing surface=ReadingFlow rows=28 target=25 offset=263016 total=289603 derived=7 exact=0 hops=0 content=0 ms=1003 end=settled top=0
landing surface=ReadingFlow rows=28 target=13 offset=116266 total=289603 derived=7 exact=0 hops=0 content=0 ms=1005 end=settled top=0
landing surface=ReadingFlow rows=28 target=25 offset=263016 total=289603 derived=7 exact=0 hops=0 content=0 ms=1014 end=settled top=0
landing surface=ReadingFlow rows=28 target=13 offset=116266 total=289603 derived=7 exact=0 hops=0 content=0 ms=1013 end=settled top=0
landing surface=ReadingFlow rows=28 target=13 offset=116266 total=289603 derived=7 exact=0 hops=0 content=0 ms=1007 end=settled top=0   ← the ALREADY-THERE landing
landing surface=BookOutline rows=26 target=13 offset=1105  total=2252   derived=13 exact=0 hops=0 content=0 ms=1016 end=settled top=0
landing surface=BookOutline rows=26 target=11 offset=931   total=21261  derived=12 exact=0 hops=0 content=0 ms=1033 end=settled top=0
```

**Read the numbers.** A 290,000-pt column; the far chapter DOWN costs one hop the first time it is
visited (a story above it trades its estimate for its real height — AR-1's rider 4, and the line
SAYS so with `derived=9 content=2`); **every landing after that is `hops=0 content=0`, settled at
`top=0`, in ~1,005 ms** — including the stutter case itself and including the repeat clicks her
report describes as *"every time."* The last line of the flow's run is the ALREADY-THERE landing,
which before this unit spent its whole 4-s watchdog (`gave up at top=unreported after 0 re-lands,
4211 ms`, measured twice on the pre-fix tree). And `derived` FALLS as she reads — 26 → 11 → 9 → 7 —
which is the column learning its own geometry; the two BookOutline lines beneath prove the Outline
emits the same signpost with its behaviour unchanged.

Captures (gitignored, `notes/plans/13u2b-screens/`): `u2-01-launch` · `u2-02-read-scroll` ·
`u2-03-flow-last-chapter` · `u2-04-flow-twisted-lip-far-up` · `u2-05-flow-already-there` ·
`u2-06-outline-unchanged`, with the raw signpost capture beside them as `u2-signpost-capture.log`.

**One walk note, no action owed:** two of my early clicks fell in the gap between navigator rows and
landed nothing — the same operator error UNIT 1's walk recorded, not a product finding. (One of them
fell in the PAGE instead and took the scrolled-open door into Index, which worked exactly as R-cor-5
says it should.)

## THE SIGNPOST, VERIFIED CONTENT-FREE — BOTH WAYS

**1. By reading the real output** (the eleven lines above, and the twelve in
`u2-signpost-capture.log`): every value is an integer except `surface=` and `end=`, and nothing in
them names a book, a chapter, a note or an id. Sherlock's chapters are called *The Man with the
Twisted Lip*; the line that landed on one says `target=13`.

**2. By the Release binary's own strings** — the honest half, because the walk ran a Debug build.
`xcodebuild build -configuration Release` into a private `derivedDataPath` (built, never launched,
never copied — `/Applications` untouched, and the standard Release configuration, never a custom
one):

| in `strings Variorum.app/Contents/MacOS/Variorum` | present? | |
|---|---|---|
| `landing surface=`, ` rows=`, ` target=`, ` offset=`, ` total=`, ` derived=`, ` exact=`, ` hops=`, ` content=`, ` ms=`, ` end=`, ` top=` | **YES** | the signpost's whole format ships |
| `BookOutline`, `ReadingFlow` | **YES** | the two enum cases the line can name |
| `manifest rows=`, `DONE: `, ` h=`, `BookOutline landing` | **NO** | the verbose DEBUG story does not ship |
| `RE-LAND` | yes | **recorded rather than removed:** it is `LandingPolicy.readingFlow.correctionWord`, a plain field of a shipped struct whose only use sits inside `#if DEBUG`. Gating the FIELD would make the policy's shape differ between configurations, which is worse than a nine-byte constant nothing reads. |

The reason-strings (`settled at top=…`) are likewise reachable in the binary as literals but never
BUILT in Release: `finish(_:why:)` takes its sentence as an `@autoclosure` and only the DEBUG
storyboard calls it, so a landing that ends in her build costs exactly the one signpost line.

## FINALS, AND THE ONE RED

| gate | result | baseline (UNIT 1's finals) |
|---|---|---|
| core `swift test` | **NOT OWED — zero `Sources/` lines in the diff** | 1567 / 171 |
| the FULL Mac suite | **2779 tests / 464 suites**, 747.0 s, **ZERO known issues**, **1 red** (below) — zero instances, nothing else running | 2767 / 462, zero known issues, 1 environment red |
| iOS build | **not owed** — no `Shared/` file moved, nothing mobile-visible | green |
| lockstep marker | untouched — **8** | 8 |

+12 tests / +2 suites are this unit's: `LandingAuthorityTests` (7) and `LandingSignpostTests` (3)
are new; PIN A and PIN B joined the flow's existing landing suite.

**THE FULL SUITE WAS RUN THREE TIMES**, because the one-line `[weak router]` capture landed after
the first run and the second run then showed a SECOND red — recorded in full rather than re-run
until it agreed:

| run | tree | result |
|---|---|---|
| 1 | before the weak capture | 2792 / 466 · **1 red** (row 58) |
| 2 | the shipped tree | 2792 / 466 · **2 reds** — row 58, and `BookOutlineLandingTests.openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded`'s "story 3 opens at its top" arm at `abs(top) → 3424.0` |
| 3 | the shipped tree | 2792 / 466 · **1 red** (row 58) |

**The second red is UNIT 1's gate suite under full-suite LOAD, and it is not this unit's:** that
suite is **3/3 GREEN ISOLATED on the shipped tree** (8 tests, 13.6–13.8 s each), it contains no
reference to `requestMode`, `PostDetailView` or `applyMode` — it mounts the book view directly — and
nothing in this diff touches the book Outline (it registers no place probe, consumes no carry, and
does not use `JumpPrimitive`). Green · red · green across three runs of the same code is the
load-flaky geometry class this repo has measured before (KnownIssues rows 19/20/58; UNIT 1's own
record carries a load-dependent anomaly on this very suite). **Carried forward for row 64's closeout
disposition and for the ladder**: the arm UNIT 1 unwrapped can still miss under full-suite load —
its residual is gone, its harness timing is not.

**THE STANDING RED — `BookIndexEditingTests.theReadClickLandsInIndexAtThatBlock`** (`live.count → 0`, the pane
identifier nil): **`KnownIssuesAndTechDebt` row 58's recorded condition, byte-identical to UNIT 1's
own run and to the row's own measurement** (3/3 red isolated on zero-code trees). This unit's diff
touches the reading flow and the Outline's landing; it does not touch the book Index, which has not
adopted the authority and will not until its next touch.

## WHAT SHIPPED — four files, and where each piece lives

- **`App/Variorum/Variorum/Surface/LandingAuthority.swift`** (NEW): `LandingSurface` (a closed type,
  so the signpost's vocabulary cannot grow a name) · `LandingPolicy` + the two surfaces' shipped
  numbers · `LandingSettle.decide`, the PURE decision · `LandingFacts` (a manifest's numbers about
  one landing) · `LandingSignpost` (the content-free line AND the proof of it) ·
  `LandingAuthority`, the runner that owns the timer, the seed, the DEBUG story and the Release
  signpost.
- **`App/Variorum/Variorum/Surface/ProseHeightModel.swift`** (NEW): the prose arithmetic UNIT 1
  marked for this unit to hoist — one model, both consumers, each keeping its own empty answer,
  calibration, rounding and floor.
- **`App/Variorum/Variorum/Features/BookView/BookView.swift`**: the landing loop (`OutlineLanding`,
  `armLandingCheck`, `checkLanding`, `finishLanding`, the constants) retires into the authority; the
  Outline keeps its own act (the scroll), its own facts (the manifest) and the page bookkeeping that
  was never the landing's (which row is at the top, the per-landing height log).
- **`App/Variorum/Variorum/Features/BookView/ReadingFlowView.swift`**: the same retirement, plus the
  small-row runs becoming plain `VStack`s, every small row carrying its anchor and reporting its
  height, `FlowRowHeights` (what those rows reported), and the flow's own `heightManifest`.
  `FlowLanding` slims to what only this surface knows — which stories are near and which have
  settled — with its `begin`/`end`/`rowNear`/`rowSettled`/`aboveTargetSettled` shape untouched.

**Zero `Sources/VariorumCore/` lines. Zero `Sync/`. Zero `Persistence/`. Zero schema. Zero
migrations. Marker stays 8.** No `Shared/` file moved, so the phone inherits nothing and no mobile
suite is owed; the closeout's parity line still reads *nothing mobile-visible*.

**Commits**, each pushed as it landed: `81893e3c` (the record + the two pin shapes, before any
product code) · `c31898cd` (the PRE-FIX MEASUREMENT) · `8a271370` (the prose-model hoist) ·
`51052f86` (the authority + both adoptions + the two pins) · `ce8298e6` (the signpost, its pins, the
walk) · this commit (the finals).

## DISPOSITIONS

| item | verdict | evidence |
|---|---|---|
| **the authority** | **BUILT, and the Outline consumes it BYTE-IDENTICALLY** | its landing suites 13/13 green with ZERO test edits — the 3C proof the brief asked for |
| **the flow adopts it** | **BUILT** — all seven shipped flow pins green UNMODIFIED | `aRevealOfTheTwelfthStory…`'s re-land bound, `theFinisherWaitsOnTheSurfacesWord…`, R2-12's teardown pin, the virtualization pin: all untouched and green |
| **PIN B — the already-there landing** | **FIXED, red-on-old, and walked** | `gave up at top=unreported after 0 re-lands, 4211 ms` (2/2 pre-fix) → `settled at top=0.0 after 0 hops, 1017 ms`; in the field, 1,007 ms |
| **PIN A — the far chapter landing** | **HOLLOW as a red-on-old pin, and said so** | green on the pre-fix tree; KEPT as the chaptered flow's first landing guard (it had none), and its trace is what measured the real residual |
| **the derived-story residual** | **RECORDED, not fixed — AR-1's rider 4 at this surface's scale** | a story above a landed target realizes ~1,670 pt taller than its estimate, costs ONE correction, and is learned thereafter; the walk shows it once (`hops=1 derived=9`) and never again (`hops=0 derived=7`) |
| **the prose-model hoist** | **DONE, behaviour-free** | 21 tests / 2 suites green, zero test edits |
| **THE SIGNPOST** | **SHIPS, and is content-free by construction** | the walk's eleven real lines + the Release binary's strings + `LandingSignpost.isContentFree` pinned against a column whose every row id is prose |
| **the Outline's unreachable hop fence** | **RETIRED, with the arithmetic** | at a 0.25-s pause its 40 corrections need 10 s and its watchdog fires at 4, so `hops >= budget` could never fire; the unified rule (the budget stops CORRECTING, the watchdog stops the landing) changes nothing that can happen — pinned |
| **row 58's red** | **the recorded environment condition** | byte-identical; the diff touches the flow and the Outline, not the Index |
| **PROVISIONALs** | **NONE** | no product behaviour was invented: the signpost's existence and shape are the plan's own instruction, and every policy value is a surface's shipped number |

### TWO RESIDUALS, STATED RATHER THAN SMOOTHED OVER

1. **The flow's small rows are now EAGER, and that is a bound worth naming.** They are the title,
   the closing mark and one heading per chapter — fifteen on Sherlock, and at the observation
   window's 300-note cap a book filed three notes to a chapter would build ~102 of them. They are
   short `Text`s with one geometry observer each, against the Outline's measured +143 ms for 400
   rows carrying a placeholder AND an observer, so the order is tens of milliseconds once per book
   open — but it is reasoned, not measured, and it is stated here for that reason. **If a book with
   hundreds of chapters ever makes this matter, the answer is already built and needs no design:
   `OutlineRunRow`'s manifest-height placeholder, applied to these rows.**
2. **The at-top wait's one unified rule** (*look again when the hold is over; if the hold is
   already over and something else is blocking, after the quiet interval*) is byte-exact for the
   Outline and makes the flow look up to 0.25 s SOONER in one window (elapsed between 0.75 s and
   1.0 s, where its old floor was the quiet interval). Strictly more responsive, and stated because
   "byte-identical" was this unit's promise and this is the one place it is only "identical or
   better".

---

# UNIT 3 RECORD — the MODE-SWITCH viewport-fraction carry (opened 2026-09-18, `opus-implementer`)

**WHAT THIS UNIT IS NOT DOING — the record's first line, written at the open.** It does **not**
touch **Takes** (her own 17q ruling R-Q20/R-Q21 outranks this rule — QUESTIONS #114(b); its suites
must ride UNMODIFIED and its round trip must be byte-identical, which this unit proves rather than
assumes). It does **not** touch the **book's word-tabs** (Outline · Index · Book · Read — #114(a):
chapter-shaped landings, not the note's mode row), nor **Lenses · Compare · Canvas · Blocks**
(#114(b)'s recorded default: untouched). It does **not** change any SETTLE — UNIT 2's
`LandingAuthority` is not touched at all; this is aim-time only, and it composes beside it. It does
**not** persist anything: the carry is IN-MEMORY session state on the router beside
`CurrentBlockMemory`'s dictionary, never a new `UserDefaults` key (KnownIssues row 44's per-note
defaults hazard class). It does **not** change the meaning of a `LandingTarget` arriving from the
book's click-through roads, the fan-panel door, or `PostDetailView.jump(to:)` — those name their own
block and keep their standing landings; the fraction applies ONLY on a mode switch, decided at the
mode-switch call site and never inferred from timing. Zero `Sources/VariorumCore/`, zero `Sync/`,
zero `Persistence/`, zero schema, zero migrations, marker stays 8, no `Shared/` file moved.

## THE RED-ON-OLD PIN SHAPE — STATED BEFORE A LINE OF PRODUCT CODE

The behaviour this unit changes is *where a mode switch puts the carried block*, so the pin has to
perform a REAL mode switch and measure a REAL screen position — and it must COMPILE AND RUN on the
pre-fix tree, which rules out any pin that speaks through the new seam. The rig exists:
`CurrentBlockContinuityTests` already mounts the real `PostDetailView` in a real window and drives
`router.requestMode(…)` through the app's own road.

**PIN A — READ → WRITE (the one the brief names).** A long note; the caret put in a block in the
middle of it; `requestMode(.read)`, whose `edit` face lands the carried block at
`anchor: .center` (`ReadEditPane.land` — the shipped policy, so the block sits at viewport
fraction ≈ 0.5 BY CONSTRUCTION, no synthetic scrolling needed); then `requestMode(.write)` and
measure, in Write's own exact AppKit geometry, where that block's first line sits:
`f = (blockTop − visible.minY) / (visible.height − blockHeight)`.
**Predicted pre-fix:** `f ≈ 0` — Write's cold mount restores its own session scroll anchor and then
reveals the caret through `JumpPrimitive.jump`, which lands the line at the viewport TOP (the
trace's §6 finding: "same block, four reveal policies"). **Claim after:** `|f − 0.5| ≤ 0.08`, i.e.
the block holds the screen height it had in Read to within a line.

**PIN B — WRITE → READ (the other direction, so the carry is proven both ways).** The same note;
Write scrolled by `JumpPrimitive` so the carried block sits at a known off-centre height; then
`requestMode(.read)` and measure the block's frame against the pane's viewport through the DEBUG
Read oracle. **Predicted pre-fix:** the block lands CENTRED whatever height it had (`.center` is
the shipped anchor), so a block left near the top comes back at 0.5. **Claim after:** the pane's
fraction matches the one Write reported, within ≈ a line of the viewport.

**PIN C — the PURE brain, both directions and every clamp** (capture → fraction → apply →
the original place, and the degenerate cases named at the code). Not red-on-old and not claimed as
such: it is new pure arithmetic.

**PIN D — TAKES IS BYTE-IDENTICAL.** Its suites run UNMODIFIED, and a Takes round trip is walked.

Both A and B are measured on the pre-fix tree FIRST, each lands in the same commit as its fix with
its measured red quoted at the test, and **a pin green on both sides is recorded as hollow and not
fixed** — the hallucination guard's own rule.

## LIVE STATUS

| piece | state |
|---|---|
| the record opened + the red-on-old pin shapes stated | **DONE** — this section, before any product code |
| PIN A / PIN B measured on the pre-fix tree | **BOTH DONE** — PIN A **RED 2/2** on the pre-fix tree itself (`fraction 0.0`); PIN B **RED under the stated probe** (`fraction 0.5` — the pane's standing centre) |
| the PURE brain + its pins (PIN C) | **DONE** — `Surface/ViewportCarry.swift`; **11 pins green** (`ViewportCarryTests`), both applies and the round trip |
| the CAPTURE seam (the router's carry + the mode-switch funnel) | **DONE** — `CommandRouter`'s probe registry + one-shot slot; `PostDetailView.switchMode(to:)` and the `applyMode` closure are the two doors, with the roads that deliberately do NOT come through them named at the code |
| WRITE captures and consumes | **DONE** — the probe answers from live AppKit geometry; the apply is `JumpPrimitive`'s new `landingInset` (default 0, every existing caller byte-unchanged) parked for the N14 settle hop. **PIN A: `fraction 0.0` → `fraction 0.5`, red-on-old** |
| READ (both faces) captures and consumes | **DONE** — the carried row and the face report into an unobserved box; the arrival's landing passes the carried anchor to the `scrollTo` it already ran |
| PIN D — Takes byte-identical (suites unmodified + a walk capture) | **DONE** — its landing suites **58 tests green, ZERO edits**; and the walk's Takes round trip is **PIXEL-IDENTICAL** (max diff 0) |
| the dev-store WALK — her round trips, both faces | **DONE** — Write ⇄ Read(edit) returns at **0.0 pt**, Write → Read(page) lands the block at the same fraction (0.667 → 0.666), Takes and Blocks round trips unchanged; 8 captures |
| tests: the touched suites · the FULL Mac suite | **DONE** — core NOT OWED (zero `Sources/` lines); iOS NOT OWED (no `Shared/` file moved); the FULL Mac suite **2792 tests / 466 suites, ZERO known issues, ONE red — row 58's recorded environment condition, byte-identical and re-verified ISOLATED** |
| **UNIT 3 — CLOSED, pending the orchestrator's walk** | **READY** |

*(Every line starts NOT-STARTED and is flipped in the same commit as the piece it names; an
unverified claim reads PENDING.)*

## THE PRE-FIX MEASUREMENT — PIN A, on the tree as UNIT 2 left it (2026-09-18, zero instances verified before and after)

Run twice against `65da53b5`, isolated (`-only-testing:VariorumTests/ModeSwitchCarryTests`), through
the real mounted `PostDetailView` and the app's own `requestMode` road. **RED both times, byte for
byte:**

```
[13u2b U3] block top 2204.0 bottom 2238.0 · visible 2204.0…2853.0 · fraction 0.0
✘ Expectation failed: (abs(f - 0.5) → 0.5) <= 0.08
```

The block's first line sits **exactly at the viewport top** — `blockTop == visible.minY` to the
point — where the Read pane it just came from had it CENTRED. That is not a near miss or a settle
artifact: it is the second reveal policy doing precisely what it says, and it is the trace's §6
finding measured in one number. The mechanism, traced rather than reasoned (the code, not a guess):
Write's mode entry mints a COLD editor, so `EditorSurfaceController.renderFull` parks
`editorRouter.scrollAnchors[postID]` (the top of the note, where the page stood when she left Write
— she had moved the caret with `setSelectedRange`, which scrolls nothing) and `applyFocusSeeds`
parks the caret reveal; the settle hop restores the anchor first, the caret at block 60 is then far
below the viewport, and `consumePendingReveal`'s guard therefore fires `JumpPrimitive.jump`, whose
whole contract is *"lands the LINE containing `offset` at the viewport top"*. Nothing is broken —
the two surfaces simply never agreed on a rule, which is what this unit gives them.

## PIN B's RED — measured under a stated probe, and reverted (2026-09-18)

PIN B reads the FACE's own frame to state its claim as a fraction on both surfaces, and that
instrument arrived with this unit — so unlike PIN A it cannot be run on a tree that predates it.
The behaviour was therefore measured with the instrument in place and the FIX neutered: one line in
`ReadEditPane.land` put back to the shipped `anchor: Self.restingAnchor` (the `.center` it has
always used), the pin re-run, the line reverted. The pre-probe state was committed first
(`123b4f8d`), the probe was never committed, and `git status` is clean after it.

| | Write held it at | Read showed it at |
|---|---|---|
| **with the fix neutered (the shipped behaviour)** | `fraction 0.0` (row `2204.0…2238.0`, viewport `2204.0…2853.0`) | **`fraction 0.5`** — row `333.0…383.0` against a face at `36.0…680.0`: the pane's standing centre |
| **with the fix** | `fraction 0.0` | **`fraction 0.0`** — row `36.0…86.0`, flush with the face's top |

PIN A stayed GREEN throughout the probe, which is its own small proof that the probe neutered only
Read's landing: PIN A's direction is Read → Write, and Write's half was untouched by it.

## THE WALK — her own gesture, on the real Sherlock corpus (dev-store Debug build, zero instances verified before and after)

`DerivedData/13u2b`'s Debug build (`io.lduarte.Variorum.debug`), WalkKit + cliclick, a 980×1000
window. The note is **The Man with the Twisted Lip** — 222 blocks, 9,297 words. The gesture is the
one her report is about: stand somewhere in the middle of a long note and change mode.

Scrolled deep into the note, clicked into **block 130** (*"I have seen too much not to know…"*) so
it sat about two thirds down the viewport — deliberately NOT centred and NOT at the top, so neither
surface's standing policy could produce the right answer by accident.

| the round trip | what happened |
|---|---|
| **Write → Read(`edit`) → Write** | the page came back **pixel-aligned: best vertical shift 0.0 pt** (measured, not eyeballed: the two captures' row-darkness profiles cross-correlated over ±30 pt; the 4,253 differing pixels of 2.2 M are the caret and the ring). In Read the block stood at fraction **0.70** against Write's **0.667** — a third of a line apart on a 548-pt viewport, where its shipped landing would have centred it. |
| **Write → Read(the calm page)** | block 130 landed at fraction **0.666** against Write's **0.667**, where the page's own standing anchor is 0.08 — near the top. (Entered by a mode switch with the `read` face remembered, which is the in-scope road: a face FLIP is not a mode switch and keeps its standing behaviour.) |
| **Takes → away → Takes** | **PIXEL-IDENTICAL, max difference 0.** Her 17q memory (R-Q20/R-Q21) restores exactly as before: Takes registers no probe, consumes no carry, and its entry landing put the live pane where its own rule says — visibly NOT at the carried fraction. |
| **Write → Blocks → Write** | **0.0 pt**, by Write's own session anchor — the carry is nil there (Blocks answers no probe), so the standing behaviour is what ran, which is the point of clearing the slot at every switch. |

Captures (gitignored, `notes/plans/13u2b-screens/`): `u3-01-write-before` · `u3-02-read-edit` ·
`u3-03-write-back` · `u3-04-write-before-page` · `u3-05-read-page` · `u3-06-takes-left-here` ·
`u3-07-takes-restored` · `u3-08-write-after-blocks`.

**One walk note, no action owed:** flipping Read's own `edit`/`read` switch keeps whatever scroll
offset the host had rather than re-landing the current block — pre-existing behaviour this unit
does not touch (a face flip is not a mode switch; #114's scope is the note's mode row). It is
recorded because a reader of the captures will see the page hold its place across that flip and
might otherwise credit it to this unit.

## FINALS, AND THE ONE RED

| gate | result | baseline (UNIT 2's finals) |
|---|---|---|
| core `swift test` | **NOT OWED — zero `Sources/` lines in the diff** | 1567 / 171 |
| the FULL Mac suite | **2792 tests / 466 suites**, 742–748 s, **ZERO known issues**, **1 red** (below; run THREE times — the table below) — zero instances verified before and after, nothing else running | 2779 / 464, zero known issues, 1 environment red |
| iOS build | **not owed** — no `Shared/` file moved, nothing mobile-visible | green |
| lockstep marker | untouched — **8** | 8 |

+13 tests / +2 suites are this unit's: `ViewportCarryTests` (11) and `ModeSwitchCarryTests` (2).

**THE RED — `BookIndexEditingTests.theReadClickLandsInIndexAtThatBlock`** (`live.count → 0`, the
pane identifier nil): **`KnownIssuesAndTechDebt` row 58's recorded condition, byte-identical to
UNIT 1's and UNIT 2's own runs** — and re-verified **ISOLATED** on this tree (7 tests, the same two
issues, the same values), which is the row's own measurement ("3/3 red isolated on zero-code
trees"). This diff does not touch the book Index: it has no mode row, registers no place probe, and
consumes no carry.

## WHAT SHIPPED — seven files, and where each piece lives

- **`App/Variorum/Variorum/Surface/ViewportCarry.swift`** (NEW, pure): the rule — `Place` (the
  one-shot value a switch carries), `fraction` (CAPTURE, with every clamp and its reason),
  `anchor` (the SwiftUI APPLY — a `UnitPoint` for `scrollTo`) and `topInset` (the AppKit APPLY).
  No SwiftUI view, no AppKit, no store: every number is handed in.
- **`App/Variorum/Variorum/Registry/CommandRouter.swift`**: the SEAM — a LIFO registry of place
  probes (the `handlers` shape, filtered by `activePostID`), the ONE in-memory one-shot slot beside
  `CurrentBlockMemory`, `carryPlaceAcrossModeSwitch()` (called by the switch, and CLEARING when the
  outgoing surface does not participate) and `takeCarriedFraction(postID:blockID:)`. Cleared on a
  note change and on the detail's teardown. **Never persisted** (row 44's class).
- **`App/Variorum/Variorum/Features/Takes/PostDetailView.swift`**: the two doors every mode switch
  comes through — `switchMode(to:)` (the masthead's ▾) and the `applyMode` closure (⌘1–⌘7, the
  sidebar rail, ⌘K, the bars' "write" doors) — with the roads that deliberately do NOT come through
  them named at the code: `jump(to:)`, the remembered-mode mount, the blockless guard.
- **`App/Variorum/Variorum/Features/Editor/JumpPrimitive.swift`**: `landingInset` on `jump`,
  defaulted to 0 so every existing caller is byte-unchanged. The correction loop already converges
  `top` to whatever its closure reports, so reporting `minY − inset` lands the line that far below
  the viewport top — the whole AppKit apply, with no new scroll machinery.
- **`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift`**: Write's CAPTURE
  (`carriedBlockPlace`, two bounded single-fragment layouts — never a document-wide `ensureLayout`)
  and its APPLY (parked at the arrival, spent at the N14 settle hop where the frame is first
  honest, standing the session anchor and the ordinary reveal down, and revealing the caret
  afterwards if the placement left it off screen).
- **`App/Variorum/Variorum/Features/ReadMode/ReadModeView.swift`**: `ReadCarryGeometry` (the
  unobserved box — the carried row's frame and the face's own, written at geometry cadence and read
  once), `ReadLanding` (a landing is a block AND, when carried, an anchor), the probe registration,
  and the seeding that takes the carry. The DEBUG oracle gains the face's frame so a pin can state
  a landing as a fraction.
- **`App/Variorum/Variorum/Features/ReadMode/ReadEditPane.swift`**: the pane's resting anchor named
  (`.center`, its shipped one), the landing honouring a carried anchor, and the carried row's
  geometry report.

**Zero `Sources/VariorumCore/` lines. Zero `Sync/`. Zero `Persistence/`. Zero schema. Zero
migrations. Marker stays 8.** No `Shared/` file moved, so the phone inherits nothing and no mobile
suite is owed; the closeout's parity line still reads *nothing mobile-visible*.

**Commits**, each pushed as it landed: `65da53b5` (the record + the pin shapes) · `ff519c3c` (PIN
A's pre-fix measurement) · `448c4237` (the pure rule + 11 pins) · `90f94939` (the carry, both ends,
PIN A green) · `123b4f8d` (PIN B) · `6f4d5fae` (PIN B's red under a stated probe) · `de0c462f`
(the walk) · this commit (the finals, the dispositions, QUESTIONS #116).

## DISPOSITIONS

| item | verdict | evidence |
|---|---|---|
| **the rule** | **BUILT as ONE pure brain, both directions** | `ViewportCarry`; 11 pins including the round trip and every clamp |
| **PIN A — Read → Write** | **FIXED, red-on-old** | `fraction 0.0` on the pre-fix tree (2/2, byte-identical) → `fraction 0.5` |
| **PIN B — Write → Read** | **FIXED, red-on-old under a stated probe** | `Write 0.0 / Read 0.5` with the fix neutered → `0.0 / 0.0`; the probe never committed, the pre-probe state committed first |
| **PIN C — the pure clamps** | **PINNED, and not claimed as red-on-old** | new arithmetic; 11 pins |
| **PIN D — Takes byte-identical** | **PROVED TWICE** | its landing suites **58 tests green with ZERO edits**, and the walk's Takes round trip is **pixel-identical, max difference 0** |
| **Write's standing landings when nothing is carried** | **BYTE-UNCHANGED** | `LandingOffsetTests` (12 pins over the anchor restore, the reveal and its guard) green UNMODIFIED; `JumpPrimitive`'s new parameter defaults to 0 |
| **the walk** | **PASSED on the real 222-block note** | Write ⇄ Read(edit) at **0.0 pt**; the calm page at **0.666 against 0.667**; Blocks round trip 0.0 pt |
| **row 58's red** | **the recorded environment condition** | byte-identical, and red ISOLATED on this tree as the row itself measured |
| **PROVISIONALs** | **THREE, all on QUESTIONS #116** | (a) the fraction is the ANCHOR reading, not the distance-from-the-top one; (b) the carried height outranks Write's own session scroll anchor on a mode switch; (c) a block taller than the viewport keeps the CARET (the reveal runs after the placement) rather than the height |

### THREE RESIDUALS, STATED RATHER THAN SMOOTHED OVER

1. **The carry can only carry a block that is ON SCREEN.** If she scrolls the outgoing surface away
   from the current block and then switches, the capture returns nil (the clamp, pinned) and the
   arriving surface keeps its standing reveal. That is the honest answer — a fraction for something
   off screen would place it off screen — but it means the calm page, which never changes the
   current block as she reads, carries nothing once she has scrolled past the block she arrived on.
   Changing what the page REPORTS as the current block is product behaviour and not this unit's.
2. **Read's `edit`/`read` face flip is not a mode switch** and keeps whatever scroll the host had,
   which on the walk looked like continuity but is not this unit's doing. Recorded so the captures
   are not misread; #114's scope is the note's mode row.
3. **One report a scroll frame on Read's carried row.** Only the selected/live row measures itself
   (plus the face once), so this is not the per-row observer cost UNIT 1 measured at 400 rows — but
   it is a write per geometry frame while she scrolls, into an unobserved box. If it ever matters,
   the box is one object and the report is one modifier.
