# 13u2b — LADDER ROUND 1 (fable-reviewer, cold, 2026-09-18)

**Scope:** the combined diff `70227004..HEAD` (UNIT 1 the height manifest · UNIT 2 the landing
authority + signpost · UNIT 3 the viewport-fraction carry · the star-cap 5→15 ruling commit
`edb4ea94` · the trace memo and plan/notes changes). Read cold per `notes/REVIEW_PROMPT.md`;
anchor: `notes/plans/phase-13u2b-landing-seam.md` (all three UNIT RECORDs, AR-1…AR-3, the
orchestrator's walks) + `notes/plans/navigation-landing-architecture-trace.md`.

**Verification runs made this round** (zero instances confirmed before each; suite-level
`-only-testing` from `App/Variorum`): the pure suites `LandingAuthorityTests` +
`LandingSignpostTests` + `ViewportCarryTests` + `BookHeightManifestTests` — **35/4 green**;
`BookOutlineLandingTests` — **8/8 green, zero known issues** (the gate arm unwrapped and green
isolated on this tree); `ModeSwitchCarryTests` + `ReadingFlowLandingTests` — **11/2 green**
(PIN A/B of both units green, the seven pre-existing flow pins green unmodified).

---

## FINDINGS (severity-ranked)

### [MAJOR] · `App/Variorum/Variorum/Surface/LandingAuthority.swift:173-184` · the watchdog cannot end an at-top landing whose surface veto never clears — an unbounded wait the hoist introduced

**What's wrong.** `LandingSettle.decide`'s at-top branch (line 173) returns `.done` or `.wait(…)`
and never consults `timeBudget`; `.giveUp` (line 181) is reachable only when the target is OFF the
top. The flow's `mayFinish` is `FlowLanding.aboveTargetSettled()`, whose own doc states the veto
plainly: *"a near story that has not reported settled blocks the finish however long it has been
loaded."* So: target at the top + one near story above it that never reports `settled` ⇒ the
landing re-arms its check every 0.25 s **forever** — `isPending` never clears, and **no signpost
line is ever emitted**, which silences the phase's own deliverable ("her next field report carries
its own trace") in exactly the stuck case the signpost exists for.

**Evidence (traced, inputs → wrong outcome).**
- The pre-hoist flow (`ReadingFlowView.checkLanding`, removed in this diff — the old body ran
  `if elapsed > timeBudget { finish("gave up …") }` unconditionally after the settled check) ended
  an at-top-vetoed landing at 4 s. The hoist changed this.
- The shipped contract contradicts the code: `LandingPolicy.timeBudget`'s own doc (line 100-101)
  says *"a landing older than this stops wherever it is."* It does not, at the top.
- The unit's own truth-table pin papers the gap: `LandingAuthorityTests.swift:94-98` comments
  *"the watchdog still ends it, veto or no veto"* — but its giveUp case uses `top: 900` (off the
  top); the at-top-vetoed-past-budget cell is unpinned, and the code answers `.wait(0.25)` there.
- The record's residual 2 (plan lines ~1085-1090) declares the ONE behaviour delta as "look up to
  0.25 s sooner"; this second delta is undisclosed.
- Reachability, honestly: it needs a near story above the target whose `StableSurface.settled`
  never fires for 4+ s. Not staged in the field; the harness's load-flaky surface family (KnownIssues
  rows 19/20/58) is the standing evidence the class exists. The severity rides the violated stated
  contract + the silenced signpost, not a field repro.

**Red-on-old pin** (pure, no window): `LandingSettle.decide(top: 0, corrections: 0, elapsed: 4.5,
mayFinish: false, policy: .readingFlow) == .giveUp(top: 0)` — fails on the shipped code (returns
`.wait(0.25)`), passes after the fix.

**Fix.** Honor the budget inside the at-top branch:
`if elapsed >= hold, mayFinish → .done` · `else if elapsed > timeBudget → .giveUp(top:)` · else
wait — byte-identical for the Outline (no veto: at top past the 1-s hold it is `.done` long before
4 s), restores the flow's pre-hoist termination, and the landing that gives up at `top=0` leaves
the page exactly where it should be while still filing its signpost.

### [MAJOR] · `App/Variorum/Variorum/Features/ReadMode/ReadModeView.swift:244-261` (the seed) + `Registry/CommandRouter.swift:301-321` · the orchestrator's flagged UNIT 3 field defect — the FIRST Read mount after a note-open lands on the note-open's block, not the switch's carried block

**What's wrong (observed in the field, captures `u3-09/10/11-orch-*`; routed to this ladder by the
orchestrator's walk).** Repro: open a note via ⌘K (Write lands at the remembered block B₁) → click
a different block B₂ → ⌘3 immediately. Read's first mount put the wash on **B₁** at the standing
anchor (B₂ measured at ≈0.86 against Write's ≈0.44); every SUBSEQUENT switch honors the carry.

**What I traced.** The only carry-consuming road on Read is the once-per-mount seed
(`.onChange(of: model.rows)`), whose target is `session.commandRouter.focusedBlock` read at
rows-arrival time; a target≠carry mismatch silently drops the carry (and leaves the slot loaded —
next finding). The observed wash on B₁ therefore means the caret-context fact still held the
note-open's restored block (`CommandRouter.registerDetail`'s note-change restore) at the deciding
read. Both the CAPTURE (`EditorViewModel.carriedBlockPlace` reads `caretBlockID`) and the seed's
target come from the same `updateCaretContext → noteFocusedBlock` report
(`EditorViewModel.swift:3247-3316`, wired synchronously at
`EditorView.swift:631 textViewDidChangeSelection`) — so the defect requires that report not to have
run for the click before the switch. **SPECULATIVE as to which link fails** (the click's
selection-change report never firing/coalescing vs. arriving after the capture): the deciding
instrument is the rig below. What is NOT speculative: the wrong outcome is real (walked, captured,
"every time" on the first mount), and the shipped pins cannot catch it —
`ModeSwitchCarryTests` deliberately settle-waits on `router.focusedBlock?.blockID == target`
BEFORE switching (lines 204-206 / 300-302), which is exactly the wait her hands don't take.

**Red-on-old pin shape** (the existing rig, one change): PIN A's fixture, but `putCaret` at a
block ≠ the remembered one and `requestMode(.read)` in the SAME turn — no settle on
`focusedBlock` — then assert `ReadModeOracle.selectedBlockID == the caret's block` (and the
fraction). Expected red on the shipped tree: selected == the note-open's block.

**Fix direction** (to be confirmed by the rig's trace in the fix pass): make the seed prefer the
CARRIED place's block when the carry's postID matches and the block is in `rows` — the switch-time
capture is the newer fact than the router's observed identity (the same "newer fact" doctrine
QUESTIONS #116(b) states for Write's session anchor), and the capture already reads the editor's
own `caretBlockID`, so seeding on the carried blockID heals both candidate links at once. If the
trace instead shows the capture itself stale (the carry holding B₁), flush the caret context at
the capture door (`switchMode`/`applyMode`) before probing.

### [MINOR] · `App/Variorum/Variorum/Registry/CommandRouter.swift:315-321` + `Features/Takes/PostDetailView.swift:876-888` · a mismatched take leaves the one-shot slot loaded, and the `jump(to:)` road — which bypasses the re-decide — still consumes it

**Mechanism (traced).** `takeCarriedFraction` clears the slot only on a MATCHED take; a mismatch
returns nil and leaves the place standing. Every mode switch re-decides the slot
(`carryPlaceAcrossModeSwitch`, nil included) — but `PostDetailView.jump(to:)` sets `mode = .write`
DIRECTLY (line 887), deliberately outside `switchMode`, so it re-decides nothing; and Write's
arrival consumes unconditionally (`parkCarriedPlacement`, `EditorViewModel.swift:2350`). Chain:
Write→Read carries (B, f); the seed's target mismatches (the finding above, or the current block
moved in flight) and leaves the slot; in Read she selects B (Read reports `focusedBlock = B`) and
takes a jump door (`onJump` → `jump(to: B)` — the index column's jump / Blocks' open-in-write /
the canvas card); Write's arrival fact = B matches the STALE place → the jump lands B at a
minutes-old fraction instead of its standing landing — contradicting the UNIT 3 RECORD's own
promise that those roads "name their own block and keep their standing landings."

**Red-on-old pin** (router-level, pure): register a probe returning (B, f); `carryPlaceAcrossModeSwitch()`;
`takeCarriedFraction(postID, otherBlock)` → nil; then `takeCarriedFraction(postID, B)` must be nil
— fails on the shipped code (returns f), passes after.

**Fix.** Clear the slot on ANY take (the switch's one arrival is its one chance) — one line, and it
also shrinks the blast radius of the first-mount defect above.

### [MINOR] · `App/Variorum/Variorum/Features/BookView/BookView.swift:1461` · the VOICE-change road drops her place where the width-change road (one line above) keeps it

**Mechanism (traced).** `.onChange(of: tokens)` calls `model.restandOutlineHeights()` — every
learned height drops and every row re-renders at modelled heights — but unlike the width road at
line 1452 it does NOT re-land `landingBox.topRow`. A voice change moves every row's height MORE
than a small width change (Study's 16-pt Iowan vs Terminal's 14-pt mono), so the scroll offset now
points at different prose: the exact silent mid-story relocation the trace measured for width and
QUESTIONS #115 ruled worth fixing. The comment's "nothing else is needed here" covers the
re-measure, not her place. Degradation: she changes voice in Settings mid-book and comes back to a
page that has quietly moved.

**Fix.** The same one-line re-land the width road does. **Pin:** the width re-land's own shape
driven by a voice change (mount, land, flip the voice, assert a re-land DONE on the top row). If
the harness can't stage a voice flip cheaply, record under #115 as an unbuilt arm instead of fixing
blind — but the mechanism is traced either way.

### [NIT] · `App/Variorum/Variorum/Registry/CommandRouter.swift:301-313` · two windows on the SAME note: the LIFO probe pick can capture the other window's geometry

The postID filter only discriminates across notes; with one note open in two windows both surfaces
register probes and a switch in window 1 may carry window 2's fraction (the comment's "a surface in
another window … can never answer" holds only across notes). The recorded two-windows oracle-keying
family; cosmetic misplacement at worst. Record; a detail-token/window key is the eventual fix.

### [NIT] · `App/Variorum/Variorum/Features/BookView/BookViewModel.swift:677-699` · `outlineSurfaceAnswer` rebuilds the O(entries) cache key per call

`flowExtents.lookup(entries.map(\.postID))` builds the full id list on every ask; the callers are
per-expanded-row (placeholder bodies, the manifest build), so an expand-all book at the 300-note
window cap pays O(expanded × entries) array-building per body pass. The measured cost pins cover
the collapsed cap and the 60-post expanded fixture (fine at those shapes); this is a cost-shape
note, not a measured regression. Hoist the key once per pass if the cap fixture ever shows it.

---

## THE FOUR ITEMS THE PLAN ROUTED TO THIS LADDER — explicit dispositions

1. **AR-3's flag: the two walk-found fixes.** Examined both. (a) The card/expanded shape confusion:
   `BookOutlineHeights.measured` carries the Shape; `input()` filters by shape match; `learn` never
   writes `byShape` for `.expandedNote`; the pin (`BookOutlineHeightsTests`) was red-on-old at
   `103.0` where `20 000` was due. Sound. (b) The already-there seed (`LandingAuthority.tops`):
   examined for stale-seed hazards — `land()` always re-aims, any real movement re-reports and
   overwrites the seed, and `tops` is refreshed by every row report whether or not a landing is
   pending; the one theoretical soft spot (a seeded in-tolerance top + an aim that silently moved
   nothing at all would settle without a fresh report) is exactly the already-there case behaving
   correctly, and no silent-scrollTo-failure mode is in evidence — anchors exist on every row by
   construction now. Sound.
2. **UNIT 2 residual 1 (the flow's eager small rows) — weighed, accepted.** Fifteen `Text`s on
   Sherlock, ~102 at the cap, one observer each; the Outline's measured 400-row worst case
   (+143 ms mount, 0.562 ms steady-state layout) bounds it from above by shape, and the named
   fallback (`OutlineRunRow`'s manifest placeholder) stands built and adoptable. No action owed.
3. **The load-flaky gate arm under full-suite load** (UNIT 3 finals, run 2's `abs(top) → 3424`):
   re-verified this round — `BookOutlineLandingTests` 8/8 green ISOLATED on this tree. Green ·
   red · green over identical code is the recorded load-flaky geometry class (rows 19/20/58). No
   code finding; **the closeout's row-64 removal wording must keep the distinction the record
   already draws** — the residual is gone, the harness-load timing is not (a row-19/20-class note
   or a row-58 widening is the honest home).
4. **The orchestrator's UNIT 3 flagged finding** — the second MAJOR above.

## CLEAN BILL (load-bearing things checked and found solid)

- **The gate (row 64's arm):** unwrapped exactly as the row instructed, interim bound dropped,
  claim `abs(top) ≤ 4` green isolated this round (8/8, zero known issues); the AR-2 premise
  restatement is genuinely stronger (positively below-the-fold, measured against the named window
  height) and the claim untouched. The two test edits match their rulings (AR-2, AR-3), and AR-3's
  re-derived budget (`< 12`) carries its derivation at the line.
- **`BookHeightManifest` / `resolve` precedence:** one brain asked per-row and per-column through
  the same `input()`; measured-by-shape filtering correct; duplicate anchors single-valued;
  offsets cumulative (pinned); `isExactAbove` rows-above-only is right (rows below never move a
  target); non-finite/non-positive answers fall through (pinned).
- **`ViewportCarry`:** the anchor-reading fraction, both applies, and the round trip are
  internally consistent and pinned from both ends (11 pins re-run green); the f·δ degradation
  argument is arithmetically true; clamps each carry a reason and a pin; `topInset` negative for
  page-tall blocks is deliberate and pinned.
- **`ProseHeightModel` hoist:** byte-faithful to both consumers — the flow keeps calibration/empty/
  rounding, the Outline keeps its floor; `FlowHeightEstimate.height` reproduces the old arithmetic
  exactly (paragraphs/lines/lineSpacing/paragraphGap re-derived by hand against the old body);
  21 tests green with zero test edits, as claimed.
- **`NearBand` hoist:** distance and hysteresis byte-identical to `NearViewportObserver`'s old
  body (`farMargin = margin * 3` confirmed at the source); the observer's behavior unchanged.
- **The Outline's exact column (`OutlineRunRow`):** placeholder heights come from the same
  precedence brain the manifest uses, so a near→far flip re-renders at the row's own measured
  height — the no-shrink-above-a-landed-target argument holds; `near` flips are decided off the
  layout pass (the state-during-update class respected); one geometry report serves three readers;
  learning only from real content (`if near`), placeholders never taught.
- **P1/P-8:** the lengths read is lazy and once-per-book (the `ensureOutlineExtents` empty-expand
  guard — the pin that went red and was right — plus `BookOutlineCostTests`' three sentences);
  manifest build ∝ entries at landing/width cadence, never autosave; the rebuilt layer carries
  measured costs (mount +143 ms at cap, steady-state layout CHEAPER than the lazy column).
- **The signpost:** content-free by construction and by proof — `LandingFacts` has no string
  field, `isContentFree` demands integers outside two closed enums, pinned against prose-named
  rows; Release strings verified in the record both ways; the DEBUG story `#if DEBUG`-fenced; the
  `@autoclosure` reason-sentence never built in Release. `LandingSurface` closed. The `RE-LAND`
  string residue is reasoned and harmless.
- **The authority's Outline adoption:** byte-identical numbers (pinned alias-by-alias), the
  retired `hops >= budget` fence genuinely unreachable (40 × 0.25 s > 4 s, pinned), landing suites
  green with zero test edits; the seed (`tops`) is what makes already-there landings terminate on
  BOTH surfaces (both pins green, both were red-on-old per the records).
- **UNIT 3's discipline:** capture at the act (`switchMode`/`applyMode`), never inferred from
  timing; the excluded roads each carry the reason at the code; Write's apply parks for the N14
  settle hop and stands down the session anchor + reveal only when it fires, with the caret
  re-revealed when the placement hides it (#116(c)); the carry is in-memory only (row 44's class
  respected), cleared on note change and teardown; `JumpPrimitive.landingInset` defaults to 0 with
  every existing caller byte-unchanged (`LandingOffsetTests` untouched in the diff); Takes proved
  byte-identical twice (58 tests unmodified + the pixel-identical walk).
- **PIN B's probe discipline:** the neutered-fix probe was stated, run, reverted, never committed,
  with the pre-probe state committed first — the hallucination guard's letter followed; PIN A red
  2/2 on the pre-fix tree through the real rig; PIN C honestly NOT claimed as red-on-old.
- **The star cap (`edb4ea94`):** exactly her ruling — `Operations.starLimit` the one home, 5→15,
  four copy sites re-worded, the freed-slot pin made symbolic over the cap (fixture iterates
  `0..<starLimit`), the geometry pin cap-independent, no test pins the old copy string anywhere
  (grepped), mobile edits are comments/copy only.
- **Fences:** zero `Sources/VariorumCore` lines outside the star-cap commit; zero `Sync/`, zero
  `Persistence/`, zero schema, marker 8; no `Shared/` file moved; P-3's liveness fence respected
  (the editor seam untouched; the expanded rows and the one live editor keep identity and
  position); no new doors (P-1/P-2 did not fire); structural-undo/sync surfaces untouched.
- **Repo-first records:** the three UNIT RECORDs' load-bearing claims each traced to code or
  re-run this round; QUESTIONS #114/#115/#116 match what shipped; the master-plan pointer,
  archive roll, and #112(b) closure are consistent.

**Tally: 0 BLOCKER · 2 MAJOR · 2 MINOR · 2 NIT.**
