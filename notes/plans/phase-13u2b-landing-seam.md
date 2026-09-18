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

**LIVE STATUS:** UNIT 1 — NOT-STARTED (design settled: this plan + the trace memo §5). UNIT 2 —
NOT-STARTED. UNIT 3 — NOT-STARTED. Ladder — not yet owed.

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
