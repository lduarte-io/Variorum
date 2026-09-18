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
| 1 | UNIT 1 — the height manifest + the Outline lands once (gate: row 64's arm ≤4, UNWRAPPED) | **IN FLIGHT** — implementer spawned 2026-09-18 |
| 2 | UNIT 2 — one landing authority + the flow + the Release signpost | NOT-STARTED (follows U1) |
| 3 | UNIT 3 — the mode-switch viewport-fraction carry (#114's defaults) | NOT-STARTED (follows U2) |
| 4 | QUESTIONS #114 (a)/(b) — U3's scope edges | LOGGED — hers |
| 5 | The ladder — `fable-reviewer` over the combined diff, standing rounds | not yet owed |
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

**LIVE STATUS:** UNIT 1 — IN PROGRESS (record below). UNIT 2 —
NOT-STARTED. UNIT 3 — NOT-STARTED. Ladder — not yet owed.

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
compensators (UNIT 2's and their next touch's). It did **not** edit any test's CLAIM: one PREMISE
line was restated under architect ruling AR-2 and is named below. And it leaves **one red it caused**
undecided — `offViewportPostsNeverInstantiate`, traced and reported under rider 3, not touched.

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
| **`offViewportPostsNeverInstantiate`** | **RED, TRACED, REPORTED — not touched** | THE TWO REDS, above. |
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
| tests: the touched suites · core (if core changed) · the FULL Mac suite | **RUN** — core NOT OWED (zero `Sources/` lines); FULL Mac **2767 / 462, ZERO known issues** (−1, the unwrap) with **2 reds**: row 58's recorded environment condition, and ONE of mine reported to the architect under rider 3 (below) |

*(Every line starts PENDING and is flipped in the same commit as the piece it names.)*

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
| the FULL Mac suite | **2767 tests / 462 suites**, 733.8 s, **ZERO known issues**, 2 reds (below) | 2744 / 459 GREEN with 1 known issue |
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
**mine, traced, and reported to the architect rather than touched** (rider 3). The pin mounts a
60-post book ALL EXPANDED in a 700×800 window and counts live READ SURFACES — it is about the
EXPANDED rows' virtualization at its 2,500-pt band, which this unit did not touch. What changed is
the column's HONESTY: a far expanded row's placeholder was `remembered ?? 800` and is now
`remembered-at-this-width → the lengths estimate → remembered-at-any-width → 800`, and the fixture's
notes are a few sentences each, so the estimate says ~50 pt where the old fallback said 800. With
the lie gone the column is 16× shorter through those rows, so the same ±2,500-pt band genuinely
spans more of them. The pin's INTENT holds (33 of 60 — the extent is not instantiated); its NUMBER
was calibrated against a column that lied. The architect's call; the options put to it were
re-budgeting the pin with the mechanism at the line, shrinking the shipped band (re-tuning a real
surface to satisfy a fixture — the class the plan's WHAT-NOT-TO-DO names), or making the band
viewport-relative (right, and beyond this unit).

**AR-3 (2026-09-18, overnight — the off-viewport pin, ruled on the implementer's stop-and-report):**
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
