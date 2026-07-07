# Phase 9 — Structural ops in the editor

> ## ⚠️ PRE-WRITTEN PLAN (2026-07-06, author forward-planning session, Fable)
> This plan was written **before Phase 8 ran**, as part of the author's forward-planning
> session (token-budget decision: front-load Fable judgment; see CLAUDE.md's model-policy
> amendment). It replaces the plan that Phase 8's closeout would normally author. **Phase 8's
> closeout duty for this file is RECONCILIATION, not authorship:** verify the assumptions in
> the "Reconciliation checklist" below against Phase 8's actual outcomes, update the baseline
> counts in the kickoff, and record any deltas in a dated note under this banner. The
> gesture contract in the ground rules is **author-ratified 2026-07-06** — it is not up for
> reinterpretation by any session, only for faithful implementation.

## Kickoff message (for a fresh session)

> You are starting **Phase 9 of Variorum** — structural operations as editing gestures:
> extract, divide (single- and multi-variant W), merge, and the composed make-block gesture,
> over the Phase 7 editor, with live block identity preserved through every rewrite. **First,
> verify Phase 8 is closed** (the master plan pointer says Phase 9; the reconciliation note
> under this plan's banner is written) — if it is not, stop and report. Read, in order:
> `CLAUDE.md`, `notes/TEXTKIT2_NOTES.md` in full (§3's selection-at-boundary quirks are this
> phase's ambient hazard; §4 is law), `notes/OverallModel.md` §7 (the split taxonomy — the
> conceptual contract), `notes/AppSpec.md` §9 (extract/divide/divideW/merge/poolDragCopy —
> the operations this phase wires; they are DONE and headless-proven since Phase 3, this
> phase writes zero new row-writing logic), AppSpec §14's **2026-07-06 forward-planning
> delta** (the author-ratified gesture contract this plan embeds) and §15 risk 1 (live
> identity — this phase is that risk's second half), the **Phase 7 plan's closeout** (the
> editor architecture you inherit: `BlockRangeIndex`, `EditorDocument`, `EditorViewModel`'s
> differential/full render + echo detection, `OperationsRunner`, `AutosaveCoordinator`,
> `JumpPrimitive`, `ScrollAnchorController`, the text-undo hygiene rules), the Phase 3 plan's
> closeout (seam trimming, extract placement, W mix-and-match, the undo inverses), the two
> KnownIssues rows owned by 9 (cross-block re-bracketing — line ratified, see ground rules;
> undo menu labels + text-undo across identity rewrites), and this plan in full. **Baselines:
> take the core/app test counts from the master plan's Phase 8 closeout paragraph — do not
> re-run suites at session start.** There is no author-assist gate in this phase (no GUI
> steps expected); her calls are all pre-made in the ground rules. Views stay functional and
> unstyled — the W sheet especially: zero polish until Phase 13.

**Goal:** every structural operation reachable as a calm editor gesture — snap-and-proceed
divide/extract, the composed middle-span make-block, explicit two-block merge, the W ceremony
as one sheet — with identity provably intact after arbitrary gesture/typing interleavings
(the store, the range index, and the surface agree; `desyncRecovery` never fires), per-op
undo labels, and sync convergence under the new write pattern.

**References:** OverallModel §7; AppSpec §9, §14 (2026-07-06 forward-planning delta), §15
risk 1; TEXTKIT2_NOTES §3–§5; Phase 3 + Phase 7 plan closeouts; KnownIssues rows owned by 9.

---

## Reconciliation checklist (Phase 8's closeout fills this in)

> **RECONCILED 2026-07-07 (Phase 8 closeout).** Phase 8's outcomes against this plan's
> assumptions — deltas below; nothing invalidates a step of this plan.

- [x] Shared shell code this plan names — **two files MOVED, none behaviorally changed for
      the editor's purposes**: `OperationsRunner` and `AutosaveCoordinator` now live in
      `App/Variorum/Shared/` (compiled into BOTH app targets; same module for the Mac app,
      so no import/code changes — the editor pipeline is untouched). `EditorViewModel` and
      `BlockRangeIndex` are byte-unchanged (`Features/Editor/` was fenced all phase).
      `AppSession` gained `#if os(macOS)` around `editorRouter` (Mac behavior identical) —
      and `EditorRouter` moved to its own file `App/Variorum/Variorum/EditorRouter.swift`.
      New shell residents this plan may see but does not touch: `AppServices` (sync
      lifecycle + idle sweeps + backups), `SyncSession`/`SyncScheduler`, `StoreLocation`
      (**A4: debug builds open the DEV store** — a Phase 9 implementer's manual smoke
      launches land in `Variorum-dev/`, by design; the dev store never syncs).
- [x] Baseline test counts — **core `swift test` 423 green / 50 suites · Mac app 101 green
      / 17 suites · iOS (VariorumMobile) 11 green / 4 suites** (the kickoff says to take
      baselines from the master plan's Phase 8 closeout paragraph, which now records these
      same numbers).
- [x] macOS point release **unchanged** since the Phase 6 spike run: 26.4.1 (25E253)
      verified 2026-07-07 — no spike re-run needed.
- [x] No new KnownIssues rows owned by 9. (Phase 8 resolved three rows and re-owned the
      backup restore drill to 12; its one new row is owned by 9b — bridge-side
      `setEntryDate` day-key validation. The two rows this plan already owns stand
      unchanged. CONFIRMED at the Phase 8 checkpoint (2026-07-07): the author picked
      option (a) — `newBlock` stamps `last_touched_at` AND feeds churn. Phase 9 OWNS the
      change: fold it into Step 1's op-wiring work with its red-on-old pin
      (`aMintIntoAPreviouslyTouchedAndSweptPostIsMissed_documentedGap` flips into the pin);
      the decision is recorded in AppSpec §14's Phase 8 checkpoint delta.)

**Phase 8 deltas under this banner (2026-07-07):** the notebook rule now exists as
`Operations.createOrOpenJournalEntry` (live-first, earliest-deterministic; day keys
validated) — irrelevant to this phase's gestures but present in the ops surface; the sync
engine gained `SyncScheduler` (+ `retire()`) in `Sources/VariorumCore/Sync/` — remember the
standing rider: from Phase 10 onward that directory is Fable-only surgery, and THIS phase's
implementer is already Fable per the model policy; sync now runs in the Mac app at real
schedules (launch/became-active/post-write-settle), so editor-rate writes sync in the
background during manual testing — convergence noise in a dev session is expected behavior,
and the dev store's sync is fenced OFF entirely.

> **AUTHOR DECISION, MID-PHASE (2026-07-07, QUESTIONS walk with the coordinator) — the
> ground rules' pre-decided full-re-render reading is SUPERSEDED.** The "One rewrite path"
> ground rule below shipped as written through Step 8's first pass (PROVISIONAL logged as
> QUESTIONS #8; full-path latency measured ~16.6 ms at 10k words). At the walk the author
> directed: **build the differential structural rewrite THIS phase** — it is the gold
> standard for the everyday gestures (untouched text never moves; no restore step at all
> beats a correct restore step; full re-render is O(document) per gesture where the
> differential conforms to P1 as written), and this phase uniquely holds the verification
> net (the Step 8 soak) and the models. Her accepted scope: **differential apply for
> divide, extract, makeBlock, merge** — minimal text edits + attribute re-bracketing +
> incremental index update, derived from the OPERATION RESULT's known seams (never from
> diffing — categorically distinct from the rejected diff-recovered-blob model,
> OverallModel §8); **behind the SAME one door** (an internal strategy of
> `applyStructuralResult`, never a second path); **W-ceremony confirm and structural undo
> stay full re-render permanently** (rare ceremonial acts; rebuild-from-store is the sane
> answer); **text-undo clearing stays on every structural rewrite, differential
> included**; a **DEBUG oracle** asserts surface == the store's fresh projection after
> every differential apply, exercised by the soak; **Step 8 re-runs against the final
> path** and measures both strategies at 10k AND 50k words. QUESTIONS #8: ANSWERED
> (history preserved there). The closeout's Step 8 section records the re-run.

## Ground rules

- **The author-ratified gesture contract (2026-07-06 — implement, don't reinterpret):**
  1. **Two named commands, three doors.** "Divide Block at Cursor" and "Extract Selection"
     are distinct commands (mirroring the two-op taxonomy), each reachable via menu bar,
     right-click context menu, and keyboard shortcut, enabled only when the planner says the
     gesture is legal. No smart unified "Split".
  2. **Snap-and-proceed, visibly.** One invoke: the selection/cut visibly snaps to the legal
     sentence/paragraph boundary as part of the action, the op runs, the eye lands on the
     new seam. Never silent, never a two-step confirm.
  3. **The W ceremony is one sheet.** Fan checklist (mark/unmark; the active variant
     pre-marked), each marked variant's full text with a click-to-place cut marker,
     pre-seeded by string-context matching from the active variant's cut (a proposal, freely
     adjusted; unseeded when no unique match). Confirm mints B and C; cancel does nothing.
     The live editor is untouched for the ceremony's whole duration.
  4. **Merge is explicit and binary.** Caret at a block seam, or a selection spanning exactly
     two adjacent blocks, enables "Merge Blocks". A selection spanning more refuses with a
     clear message. Backspace at a boundary stays refused (Phase 7 ratification).
  5. **Composed middle-span gesture, single-variant only.** "Make Block from Selection" on a
     middle span of a single-variant block runs two divides as ONE undoable action. On a
     fanned block it refuses and points at the W ceremony.
  6. **Cross-boundary spans refuse in v1.** A selection crossing a block boundary →
     "make this a block" refuses, naming the workaround (divide the neighbors, then merge).
     KnownIssues' re-bracketing line, ratified; re-own the messy case at closeout only if
     her daily use demands it.
  7. **Drag-drop into the open tail is bulk entry** — segments on entry per the effective
     mode and closes the tail, exactly like paste (resolves the deferred QUESTIONS item).
     A drop into an existing block is a content edit at the drop point (I4; the Phase 7
     paste-into-block reading extends to drops).
  8. **Fanned extract gets a passive hint** — "this block has N other takes; they keep this
     span" — shown as part of the same single invoke, never a blocking confirm (AppSpec §9's
     "may hint", resolved).
- **Zero new row-writing paths.** Every gesture reaches the store exclusively through the
  Phase 3 operations via `OperationsRunner`. If a gesture seems to need a new operation or a
  schema change, stop — that is a spec conflict to report, not code to write (the one known
  core addition is the compound-undo entry, Step 4, which composes existing inverses).
- **The store leads; the surface follows.** Structural gestures never pre-write the text
  surface optimistically (typing's buffer-leads posture does NOT extend to structural ops).
  The gesture awaits the operation's result via the runner, applies the rewrite from the
  known outcome, and treats the observation's arrival as its own echo (Phase 7's echo
  machinery). Identity is validated against the DB, never inferred from the view (§15 risk 1).
- **One rewrite path.** All structural surface rewrites funnel through a single tested
  apply-structural-result path in the view model. **Pre-decided reading (PROVISIONAL, log
  it):** v1 uses Phase 7's existing full re-render with content-anchored scroll restore and
  caret-by-identity for sequence-changing rewrites (structural ops always change the slot
  sequence, so Phase 7's differential path doesn't apply); a gesture is a deliberate act,
  not keystroke-rate, so a full re-render is within budget — Step 8 measures it, and
  extending the differential path is the recorded fallback if the feel pass finds jank.
- **Boundary snapping is the editor's contract** (Phase 3 ratification): `BoundarySnapping`
  decides the legal cut/span; operations check well-formedness only. Snapping normalizes
  through `BlockRangeIndex` verdicts first — never trust raw AppKit selection at fragment
  boundaries (TEXTKIT2_NOTES §3's selection quirks are why the planner exists).
- **TK1 ban + grep audit before every commit**, canary stays armed, unchanged from Phase 7.
- **Undo discipline:** structural gestures register their existing Phase 3 inverses; NSTextView
  text-undo is cleared on every structural rewrite (Phase 7's hygiene rule — a stale-offset
  replay landing in a different block is the corruption class this phase must not create);
  ⌘Z and ⌥⌘Z stacks never interleave (OverallModel §3).

## Steps

### Step 1 — The gesture planner (pure core)
**Files:** `App/…/Features/Editor/StructuralGesturePlanner.swift` (+ exhaustive tests).
**Work:** a pure function family: `(selection/caret in UTF-16, BlockRangeIndex snapshot,
per-block context: fan arity / lock / seal / gap-slot, effective segmentation mode) →
GesturePlan` — one of `.divide(block, snappedCut)`, `.extract(block, snappedSpan,
edge: prefix|suffix, fanned: Int)`, `.makeBlock(block, cutA, cutB)` (middle span → two cuts),
`.merge(leading, trailing)`, `.divideW(block, activeCut)` (fanned block + divide invoke),
or `.refusal(Reason)` — where `Reason` is a closed enum (crossBlockSpan, tooManyBlocksForMerge,
fannedMiddleSpan, openTailTarget, gapSlot, sealed, lockedVariant, wholeBlockSpan,
nothingToDo…). Menu/context/shortcut **enablement is the same planner call** — one brain, three
doors. Snapping via `BoundarySnapping`; span-touching-a-boundary degrades `.makeBlock` to
`.extract` (one op beats two); whole-block spans refuse ("already a block"); the open tail is
not a block — structural gestures targeting it refuse (idle-mint will make it a block within
seconds); gap slots (SyncSpec §5) refuse.
**Tests:** the phase's largest pure suite — every selection topology × block topology
(single/fanned × locked/sealed × first/middle/last block × tail present/absent), every
refusal reason reachable, snap correctness on the Phase 3 grapheme corpus (emoji, combining
marks), degradation and precedence rules. This suite is to Phase 9 what `BlockRangeIndex`'s
was to Phase 7.

### Step 2 — The structural rewrite path (one door)
**Files:** `EditorViewModel` additions; small `EditorTextView` plumbing.
**Work:** `applyStructural(_ plan: GesturePlan)` — runs the mapped operation through
`OperationsRunner`, awaits the outcome, re-renders per the ground-rule reading (full
re-render + content-anchored restore + caret-by-identity: caret is re-placed by (blockID,
intra-block UTF-16 offset) mapped through the op's known seam positions — after divide, at
the start of the successor; after extract, at the extracted block's start; after merge, at
the join), clears text-undo, marks the incoming observation as echo. Every gesture in Steps
3–7 calls this and only this.
**Tests:** integration (real pipeline, in-memory store): for each op shape (divide, extract
prefix/suffix, merge, W, makeBlock) — surface equals the store's projection afterward,
caret lands per the rule above, text-undo stack is empty, the observation echo is skipped
without a second rewrite. Reuse Phase 7's integration harness.

### Step 3 — Divide + extract gestures (the everyday pair)
**Files:** menu/context/shortcut wiring in the app target; `EditorViewModel` glue.
**Work:** the two commands per contract items 1–2: enablement via planner; invoke = snap
visibly (selection updates to the snapped span / caret to the snapped cut as part of the
action) → `applyStructural`. Fanned-extract passive hint per item 8 (transient, non-blocking,
functional-unstyled — a small inline banner is fine; placement is the implementer's call,
the *requirements* are: visible, self-dismissing, never modal). Divide on a fanned block
routes to `.divideW` → Step 6's sheet. **Per-op undo labels land here** (KnownIssues part 1):
`UndoStack.topLabel` becomes observable and the Edit menu shows "Undo Divide" / "Undo
Extract" / etc. via menu validation.
**Tests:** VM-level: enablement mirrors planner verdicts; invoke-on-sloppy-selection snaps
then applies (the snapped range is what reaches the op); hint appears only when fan arity >1;
menu label matches the top inverse after each op and after undo; a locked/sealed target's
command is disabled AND its direct invocation (shortcut path) surfaces the op's refusal.

### Step 4 — Make Block from Selection (composed middle-span)
**Files:** `Sources/VariorumCore` (UndoStack compound entry — core addition, own commit
consideration: it's undo machinery, not schema; a normal code commit is fine), gesture wiring.
**Work:** contract item 5. The gesture runs divide(cutA) then divide(cutB) on the successor,
through the runner, registering ONE compound undo entry that runs the two inverses in reverse
order (`UndoStack` gains a minimal compound-entry capability — an array of inverses run
LIFO; no new inverse logic, composition only). Fanned block → refusal pointing at W
(planner already decided). Label: "Undo Make Block".
**Tests:** core: compound entry round-trips (do two, undo once, rows byte-equal to before —
the Phase 2/3 inverse-test pattern); VM: the three-block result (prefix / span / suffix) with
correct positions + lineage edges (two divide edges), single undo restores surface and store,
refusal on fanned.

### Step 5 — Merge gesture
**Files:** gesture wiring; `EditorViewModel` glue.
**Work:** contract item 4: enablement (caret at seam / exactly-two-block selection);
`applyStructural(.merge)`; the op's single-space join rule and released-to-lineage behavior
are Phase 3's — surface just reflects them; caret at the join point; label "Undo Merge";
>2-block selection refuses with copy naming the binary rule.
**Tests:** VM: seam-caret and two-block-selection both enable; three-block selection refuses;
post-merge surface equals projection (join space present per the op); undo restores B and C
placements and the surface.

### Step 6 — The W ceremony sheet
**Files:** `App/…/Features/Editor/DivideWSheet.swift` (SwiftUI), `CutPropagation.swift`
(pure), VM glue.
**Work:** contract item 3. `CutPropagation` (pure): given the active variant's snapped cut
and another variant's text, propose a cut by string-context match (a window of N UTF-16 units
each side of the cut, located in the target variant; unique match → proposed cut, snapped to
the nearest legal boundary; zero or multiple matches → no proposal). The sheet: fan checklist
(unmarked variants stay on A as lineage — the op's semantics, shown plainly), per-marked-
variant text with click-to-place cut marker (proposals pre-placed), confirm enabled only when
every marked variant has a legal cut; confirm → `applyStructural(.divideW…)` with the
per-variant cuts; cancel → nothing (no rows touched). Undo label "Undo Divide into Variants".
**Tests:** `CutPropagation` pure suite (unique/none/multiple matches, boundary snapping of
proposals, grapheme corpus); sheet VM: parameter fidelity (marked set + per-variant cuts
reach `divideW` exactly as placed — the op's W mix-and-match correctness is already proven
headless, so the VM test proves the *plumbing*, not the op); confirm-gating; cancel inertness.

### Step 7 — Drops, refusal copy, and the sweep
**Files:** `EditorTextView` drop handling; a small `RefusalCopy` table (reason → message).
**Work:** contract item 7: text drops into the open tail route through the bulk-entry path
(segments + closes the tail — reuse the paste plumbing; **resolves the deferred QUESTIONS
item — remove it, recording the resolution**); drops into a block are content edits at the
drop point. Refusal sweep: every `Reason` case gets one human-readable message (cross-block
names the divide-then-merge workaround; fanned-middle-span points at the W; merge >2 names
the binary rule); refusals are visible (same banner mechanism as the hint), never silent
no-ops, and never beep-only.
**Tests:** drop-routing (tail vs block vs boundary-adjacent); a compile-time-exhaustive
switch over `Reason` (a new case without copy fails the build or a test); VM: refusal surfaces
carry the right message.

### Step 8 — Phase verification
**Work:** (i) full suites (core + Mac app; iOS untouched but must still build/pass). (ii) The
TEXTKIT2_NOTES §5 milestone checks on the current point release — (a) canary silent through a
gesture-heavy session, (b) scroll/height stable on 10k + 50k posts *including after
structural rewrites*, (c) decorations update (badges appear/disappear as fans are born by W
and die by merge), (d) selections at boundaries resolve through the planner correctly.
(iii) **The randomized gesture soak** (this phase's centerpiece test): seeded posts, scripted
interleavings of typing / crystallization / gestures / undo (seeded RNG, several hundred
actions per seed, a few seeds) — after every action, DEBUG reconciliation asserts store ==
`BlockRangeIndex` == surface, and the run asserts **zero `desyncRecovery` firings**.
(iv) **Sync convergence under the structural write pattern:** the Phase 5 two-client harness
driven by a scripted gesture session (divide, W, merge, makeBlock, undos interleaved with
engine rounds) — byte-identical tables, empty outboxes. (v) Full-re-render latency measured
on a 10k-word post (the ground rule's PROVISIONAL reading: acceptable unless the author's
feel pass disagrees). (vi) The author's manual feel pass: the gestures, the snap feel, the
W sheet, refusal copy — her notes recorded here.

## Explicitly out of scope
Cross-boundary re-bracketing beyond the refusal (ratified line); pool UI (Phase 10 —
structural ops in pools are legal per Phase 3 but have no surface until then); any styling
(13); `version_of` minting (11); N-block merge chaining; within-post virtualization (12).

## Risks / things to watch
- **This phase is AppSpec §15 risk 1's second half.** The planner (pure, exhaustive) and the
  single rewrite path are the containment strategy — if either is bypassed "just for this one
  gesture", the phase has failed architecturally even if tests pass.
- **Sequence-changing rewrites are new territory for the view model.** Phase 7's differential
  path assumed same-sequence changes; the full-re-render reading keeps v1 simple, but watch
  scroll/caret feel — the recorded fallback (differential for structural results) is designed,
  not improvised, if needed.
- **TK2 §3 selection quirks at boundaries** — the exact place AppKit misreports selections is
  the exact place this phase's gestures operate. Normalize everything through the planner;
  never pass a raw NSRange from the view to an operation.
- **Compound undo is the one core addition.** Keep it composition-only; if it wants new
  inverse logic, something is mis-shaped — stop and reassess against AppSpec §9's inverse
  specifications.
- **W sheet scope creep:** it is a checklist, N text panes, and cut markers. Anything more
  (previews of resulting posts, diff decorations, animation) is Phase 13.
- **The idle-mint interplay:** a gesture arriving while a tail mint is in flight must be
  serialized through the runner like everything else (Phase 7's one-batch-in-flight rule) —
  the planner's refusal on tail targets plus runner serialization should make this a non-event;
  the soak's interleavings must include it to prove that.

## Review foci (for the cold reviewer — written at plan time, no implementation context)
1. Row writes: zero paths to the store outside Phase 3 operations via the runner.
2. Planner exhaustiveness: every selection/block topology yields a verdict; refusals never
   silent; enablement and invocation share one brain.
3. Reconciliation: the soak's store == index == surface assertion and the zero-desyncRecovery
   claim — verify the assertions are real (not vacuously passing) and the soak actually
   interleaves gestures with typing and idle-mints.
4. Undo: compound round-trips byte-equal; labels correct after do/undo; text-undo cleared on
   every structural rewrite; the two stacks never interleave.
5. The ratified gesture contract (ground rules 1–8) implemented as specified — flag ANY
   reinterpretation at full severity, even an arguably-better one.
6. Convergence: the structural-session suite exists and ends byte-identical with empty
   outboxes.
7. TK1 grep audit clean; canary armed; no new `ensureLayout` beyond the jump primitive's
   single fragment.

## Closeout (2026-07-07) — implementation complete; awaiting the review ladder

**Environment:** macOS 26.4.1 (25E253) · Xcode 26.3 / SDK 26.2 · the M3 — unchanged from
the Phase 6 definitive spike run (verified at phase start via the reconciliation checklist
and re-verified at Step 8), so no spike re-run was owed and the memo's numbers remain the
performance contract.

**Test results (the Phase 9b/10 baselines once the review ladder closes):**
core `swift test` = **430 green in 51 suites** (baseline 423/50; the 51st suite is the
structural-session sync convergence); Mac app `xcodebuild test` = **199 green in 33
suites** (baseline 101/17 — the additions are the 48-test planner suite, the gesture/door
suites, CutPropagation, the W ceremony suite, drops + refusal sweep, the windowed
structural smoke, the 3-seed soak, and the differential-apply pins + dual-path latency
measurements); iOS `VariorumMobile` = **11 green in 4 suites** on the iOS 26.2 simulator
(unchanged; the shared-shell addition `UndoMenuState` compiles into both targets).
Release-configuration build green. TK1 grep audit clean before every commit (hits remain
the known `textLayoutManager` locals and comments).

**Process notes:** (1) the coordinator installed a mid-phase gate after Steps 1–3
(implement → report → gate review → release). The gate PASSED with two non-blocking
observations, both taken: QUESTIONS.md re-ordered chronologically, and merge's
selection-touch semantics refined + pinned (see the merge reading below). (2) A
mid-phase author QUESTIONS walk (2026-07-07, with the coordinator) ANSWERED #8 by
directive — the full-re-render PROVISIONAL was superseded and the **differential
structural rewrite** was built this phase (scope in the banner note above); the walk also
ratified Phase 8's #3 (Keychain paste-in) and closed #6 (the A5 SQL, deployed by the
author), ratified the 9b graduated-entry policy in its brief, and bundled the pending
Phase 7 §5 feel pass with this phase's gesture feel pass into ONE sitting at the
checkpoint (the eventual handoff carries the combined checklist).

**Commits (in order):** `55ea067` (Step 1 op wiring: newBlock stamps + churns — QUESTIONS
#5(a)), `53c48f4` (Step 1: StructuralGesturePlanner + 48-test suite), `8d383e7` (core:
UndoStack change observer + "Divide into Variants" label), `42568d2` (Steps 2–3: the
rewrite door + divide/extract gestures + labels), `2e6d1cb` (QUESTIONS #8 logged),
`22b0edf` (Step 4 core: compound undo entries), `57473b9` (Steps 4–5 app: Make Block +
Merge + the pinned merge semantics), the Step 6 commit (W ceremony: CutPropagation +
DivideWSheet + ceremony flow), `b4971f8` (Step 7: drops + refusal sweep), the Step 8
commit (soak + sync convergence + windowed checks), the self-review hardening commit
(soak non-vacuity), the mid-phase recordings commit (QUESTIONS #3/#6/#8, the 9b brief
stamp, the handoff ticks, the banner note), and the differential-rewrite commit (below).
Nothing pushed.

**What shipped, per step:**

- **Step 1a — `newBlock` stamps `last_touched_at` + feeds churn (QUESTIONS #5, ratified
  option (a); the reconciliation checklist's owned hand-back).** `Operations.newBlock`
  calls `registerTextChange` with the minted text's length (grapheme `count` — the same
  unit convention as extract/divide/restoreCommit's in-core deltas; churn is approximate
  by design). **Red-on-old proven procedurally:** the flipped pin
  `aMintIntoAPreviouslyTouchedAndSweptPostIsNowInsured` (Phase 8's documented-gap test,
  now asserting the swept-past post IS a candidate and that `idleAutoCommit` lands one
  auto commit on the minted block) was run against the pre-change op FIRST — 7 issues red
  — then the fix landed and all suites went green. Both Phase 8 residual sweep gaps close;
  `IdleCommit.swift`'s coverage doc rewritten; the `created_at` branch **kept** with a new
  legacy-row test (stamp-less rows genuinely exist: containers minted by pre-Phase-9
  builds on the author's devices). Six ripple tests reworked with intent preserved —
  notably extract/divide churn tests now assert **visible accumulation** against the
  mint's baseline (stronger than the old trivially-crossed-at-first-autosave shape).
- **Step 1b — `StructuralGesturePlanner`** (pure, no AppKit/store): `plan(command,
  selection, World)` where `World` = BlockRangeIndex snapshot + per-entry fan arities +
  seal + **lazy** per-entry text (enablement costs the caret block's boundary scan, never
  the document — P1). Verdicts per the ratified contract: divide snaps to the nearest
  **interior** sentence-or-paragraph boundary (0/end are boundaries but not cuts —
  contract item 2's "legal sentence/paragraph boundary" read as the union set, constant
  across segmentation modes); fanned divide → `.divideW` seeded with the active take's
  snapped cut (locked takes don't refuse W — it copies); extract snaps both span ends,
  classifies prefix/suffix whitespace-tolerantly (mirroring the op's own classification),
  carries `otherTakes` for the hint; makeBlock = single-variant middle spans,
  **degrading to extract** when the snapped span touches a boundary (one op beats two;
  degradation precedes the fan check, so a fanned edge-span is a legal hinted extract);
  merge = seam caret (either side of the separator) or a characters-decide selection (the
  pinned reading below). Closed 12-case `Refusal` enum, **every case pinned reachable**;
  precedence pinned sealed > tail > shape; raw AppKit selections normalized through the
  tiling (separator-overhang shrink — TEXTKIT2_NOTES §3's discipline made mechanical);
  only grapheme-aligned pre-snapped offsets leave the planner (ops check well-formedness
  only — the Phase 3 ratification); the pure layer never asserts (out-of-tiling →
  `invalidSelection`, recover-not-crash — Phase 7 MINOR-7's lesson).
- **Step 2 — the one rewrite door.** `applyStructural(plan)` is the only path a
  structural result reaches the surface: refusal → `RefusalCopy` + beep (visible, never
  silent, never beep-only); actionable → **visible snap** (the selection moves to the
  snapped cut/span as part of the one invoke) → `runStructural`: **flush first** (store
  text == the text the planner snapped against), **abort if the flush left anything
  pending** (Phase 7's keep-pending refusals must not let an op run against a
  disagreeing store), the view non-editable for the few-ms flight (closes the
  flush→op keystroke window whose stale whole-buffer autosave would resurrect a
  divided-away half — the forbidden duplication class), wait out any in-flight
  crystallization mint, run **exactly one Phase 3 op** through `OperationsRunner`, fetch
  a fresh `renderPost`, apply the single rewrite: `renderFull` (Phase 7's
  content-anchored scroll restore + text-undo clearing ride along) + **caret by
  identity** (divide → successor's start; extract → extracted block's start; merge → the
  join = the trailing half's start; W → B's start; makeBlock → the middle block's
  start). The observation's later arrival is our own echo (`surfaceMatches` skips it —
  pinned). One gesture lands at a time (`structuralInFlight`; a second invoke refuses
  visibly).
- **Step 3 — divide/extract gestures, three doors, per-op labels.** A **Block** menu
  (Divide Block at Cursor ⌘⇧D, Extract Selection ⌘⇧E, later + Make Block ⌘⇧K and Merge
  ⌘⇧M — implementer's shortcut picks), NSTextView context-menu items via an
  `NSMenuItemValidation` trampoline (standard items' auto-validation untouched), and the
  menu shortcuts. Enablement everywhere = `gestureAvailability`, recomputed per
  caret/selection change from planner calls; **invocation re-plans**, so stale enablement
  (a remote seal/lock) surfaces the op-consistent refusal — pinned. Fanned-extract
  passive hint (contract 8): transient status line in the CommitBar, self-dismissing
  (~6 s), never modal, only when `otherTakes > 0`. Per-op undo labels (the KnownIssues
  row's part 1): core `UndoStack.setChangeObserver` (fires on register/completed-undo/
  removeAll; a failed undo fires nothing — pinned) → shared `UndoMenuState` mirror →
  Edit menu shows "Undo Divide"/"Undo Extract"/"Undo Make Block"/"Undo Divide into
  Variants", disabled when empty, generic-title derivation tested pure.
- **Step 4 — Make Block from Selection.** Core: `UndoStack.withCompound(label:operations:)`
  — composition only: registrations during the body collect and fold into ONE entry whose
  inverse runs them newest-first; **atomic on partial failure** (a body throw un-applies
  the collected work via its own inverses and rethrows; if an un-apply itself fails — a
  seal landing mid-gesture via sync apply — the not-yet-run inverses push as ordinary
  entries so nothing is stranded); compound retry after a failed undo is safe (revert ops
  are idempotent — documented on the API). Sub-registrations don't fire the change
  observer; the fold notifies once (pinned). App: the gesture runs two divides inside one
  serialized runner body under the compound; the second cut maps into the successor from
  the op's **actual output** (`span.count` minus the seam-trimmed leading whitespace,
  derived — never re-guessed). Round-trip pinned to row equality; atomic rollback pinned.
- **Step 5 — Merge.** Menu + context items; the door case landed in Step 2. **The
  merge-selection reading (gate observation 2, decided + pinned):** selected CHARACTERS
  decide the pair — zero-width endpoint grazes and swallowed edge separators don't count
  (a selection ending exactly at a third block's start merges the two blocks whose text
  is selected — pinned at planner AND end-to-end); a separator selected ALONE is the
  pure-seam gesture and names its pair; last-char+separator is notASeam (the consistent
  line: separators name a pair only when selected alone; otherwise characters decide);
  an empty block between two selected blocks refuses on the binary rule
  (`tooManyBlocksForMerge` — three blocks are involved). Undo restores both placements
  and the surface through the projection (pinned).
- **Step 6 — the W ceremony.** `CutPropagation` (pure): a grapheme-clamped 2N-unit
  context window around the active take's cut, located in the target take — a UNIQUE
  match proposes the corresponding position snapped through the planner's own
  `snapToInteriorBoundary` (one implementation of "legal cut"); zero or multiple matches,
  blank windows, misaligned cuts, or targets without an interior boundary propose
  NOTHING (a proposal is a seed, never a guess). The ceremony: divide-on-fanned opens
  `DivideWCeremonyState` after a flush (sheet text == surface == what the op will cut) —
  the live ACTIVE fan as a checklist, the rendered take pre-marked with the gesture's
  snapped cut, per-take proposals pre-seeded, per-take legal cut positions as
  click-to-place targets (`placeWCut` refuses illegal positions); Confirm gates until
  every marked take has a cut, then funnels `{variantID: cut}` through the SAME
  structural door; Cancel and any other dismissal touch no rows (pinned). `DivideWSheet`
  is functional-unstyled: checklist + full text with a visible ✂ marker at the cut +
  one button per legal boundary (the click-to-place reading of the contract — the
  placeable positions ARE the legal cuts); it renders the LIVE observable state
  (`.sheet(item:)` presentation snapshots pinned around). Undo label "Divide into
  Variants" (the core label change, own commit with the observer).
- **Step 7 — drops + the refusal sweep.** `performDragOperation` wraps super in the same
  bulk-entry flag as paste (3 lines of AppKit plumbing; the ROUTING is the flag + the
  verdict — Phase 7 MAJOR-3's arm-only-on-tail-verdict — tested through the seam paste
  shares): a drop into the open tail — at ANY tail position, drops aren't caret-bound —
  segments on entry and closes the tail; a drop into a block is a content edit at the
  drop point with newlines as content (I4); a boundary-adjacent drop at the exact seam
  extends the leading block (pinned). This implements the author's 2026-07-06 resolution
  of Phase 7's deferred drag-drop item (already recorded in QUESTIONS; nothing left to
  remove there). Refusal sweep: `RefusalCopy`'s switch is compile-time exhaustive (a new
  `Refusal` case fails the build) and the sweep test pins every case non-empty plus the
  ratified specifics (cross-block names divide-then-merge; fanned-middle points at the
  W's door; extract's middle-span refusal points at Make Block; merge names the binary
  rule).
- **The differential structural rewrite (author directive, mid-phase — supersedes the
  full-re-render PROVISIONAL; see the banner note).** `applyStructuralResult` now holds
  TWO strategies behind the same one door: every everyday gesture (divide, extract,
  makeBlock, merge) applies **differentially** — the op's `StructuralOutcome` carries a
  `StructuralSeam` (which entry changed and which fresh block IDs must appear there,
  taken from the op's returned rows — never from diffing, OverallModel §8), and the
  applier derives ONE minimal storage edit from the seam + the fresh store texts,
  leaning on the ops' proven seam semantics (a divide's first half is a strict PREFIX of
  the old text, an extract's remainder a strict prefix/suffix, a merge's halves
  verbatim): divide/extract/makeBlock replace only the seam region (separator + the
  minted text), merge's text edit is the ONE separator character (the join), plus
  attribute re-bracketing where identity changed (merge re-brackets the merged range to
  A'; makeBlock re-brackets the untouched suffix text to the fresh suffix block). The
  index/slots adopt the fresh store projection (a value rebuild, no surface cost — the
  store leads); untouched text never moves and NO scroll-restore step exists on this
  path. **W-ceremony confirm keeps `seam: nil` → full re-render — the permanent shape
  for ceremonial acts** (structural undo reaches the surface via the observation →
  `renderFull`, full by construction). Text-undo clears on BOTH strategies (the
  directive: stale-offset replays don't care which strategy rewrote). A **shape guard**
  precedes every differential apply (the fresh projection must match the seam's expected
  block IDs and arithmetic — a concurrent sync apply between op and fetch falls back to
  the full path, which is truth). The **DEBUG oracle** (`verifyDifferentialOracle`)
  compares the surface against the fresh projection after every differential apply —
  counts misses (test-visible `differentialOracleMisses`), asserts in debug, heals via
  `renderFull`; the soak asserts ZERO misses across every seed/action. Pins: the
  spy-on-storage-edits test proves everyday gestures edit ONLY the seam region (< ¼ of
  the document on a 30-block post) while the SAME spy sees the W confirm's full rewrite
  at document scale — so a regression to full re-render on the everyday gestures cannot
  hide (the discriminator makes the minimality assertion non-hollow).
- **Step 8 — verification (re-run in full against the final rewrite path, per the
  directive).** (i) Full suites, three targets, counts above; Release build
  green. (ii) The automatable §5 slices on the 10k-word windowed post: canary silent
  through gesture-heavy sessions; scroll anchor resolves through structural rewrites;
  fans born by the W feed the badge predicate and a merged block starts fanless; seam
  selections resolve through the planner. (iii) **The randomized gesture soak** (the
  centerpiece): 3 seeds × 250 scripted actions interleaving typing at random positions,
  deletions, tail opening, typing-past mints, idle-mints, bulk pastes, all four gestures
  (including W ceremony confirm/cancel), fan branching, and structural undo — after
  every settled action **store == BlockRangeIndex == surface per block**, the tiling
  invariant holds, **`desyncRecovery` fired ZERO times AND the differential oracle
  fired ZERO times** (real counters on the VM, asserted per action — the author-directed
  proof the differential lands safely), the canary stayed silent, and the final store proves
  **non-vacuity** (lineage edges > 0 — a hollow soak of pure refusals fails loudly).
  Unsettled stretches between assertions are deliberate: gestures land while mints and
  autosaves are in flight (the plan's demanded interleaving; the door waits them out).
  External writes (branch, undo) get a reload as the observation's stand-in; editor-path
  actions must reconcile incrementally with no re-render crutch. Runs in ~2.3 s
  (assertions flush rather than wait out the real 500 ms debounce). (iv) **Sync
  convergence under the structural write pattern:** a scripted gesture session (divide;
  branch → divideW with both takes marked — the ceremony's exact op call; merge; the
  compound make-block; two undos) with engine rounds MID-session and a phone editing a
  Mac-authored take concurrently → byte-identical synced dumps, empty outboxes,
  identical `renderedText`, and the racing edit alive somewhere (S5) — plus `newBlock`'s
  new touch/churn stamps riding every mint through CAS. (v) **Both rewrite strategies
  measured on real windows (debug builds): DIFFERENTIAL divide ≈ 8.6 ms at 10k words /
  ≈ 28.4 ms at 50k; FULL W-confirm ≈ 11.9 ms at 10k / ≈ 29.5 ms at 50k** (each = op +
  rewrite + caret; the pre-directive full-path figure of ~16.6 ms at 10k stands as
  history). Honest reading of the 50k differential number: the seam EDIT itself is
  block-scale (the spy pin proves it), but the measured window includes two O(post)
  costs — the fresh `renderPost` fetch (a DB read, the same class the Phase 7
  observation already performs at debounce rate) and the DEBUG-only oracle's full-text
  compare, which does not ship. Narrowing the fetch to affected slots is a recorded
  direction if real corpora ever care; the surface work — the part the directive
  targeted — no longer scales with the document. (vi) The author's manual feel pass —
  **pending at the checkpoint**, now ONE combined sitting with Phase 7's §5 pass
  (author, 2026-07-07): canary check, scroll/height on a long post, typing feel, snap
  feel, the W sheet, refusal copy, differential rewrite feel.

**PROVISIONAL calls:** none remain open. #8 (full re-render) was logged per the plan's
ground rule, then **ANSWERED mid-phase by the author (2026-07-07): the differential path
was built this phase** — history and scope preserved in QUESTIONS #8 and the banner note.

**Interpretations & readings for the record (planner-internal calls within the ratified
contract — not PROVISIONALs; flag any the review finds product-shaped):**
1. **Divide with a non-empty selection divides at the selection's start** (the
  caret-position reading of "at Cursor"; the visible snap collapses the selection).
2. **The planner takes no segmentation-mode parameter** — a deviation from the plan's
  Step 1 signature: the verdicts proved mode-independent (the legal-cut set is
  sentence ∪ paragraph per contract item 2 in every mode; segmentation stays a
  crystallization concern). A parameter the brain ignores would be noise.
3. **Merge's "caret at the join" = the trailing half's start** (after the space when one
  was added).
4. **The merge-selection characters-decide rule** (Step 5 above) — chosen over
  closed-range endpoint contact at the gate's prompting; both directions pinned.
5. **`invalidSelection` refuses with copy but does NOT trigger `desyncRecovery`'s
  debug-assert** — the planner is pure and the next projection heals; the recovery path
  (with its assert) remains the storage-edit path's.
6. **Divide on a fanned block with no legal interior cut refuses `nothingToDo` without
  opening the ceremony** — the ceremony needs an active-cut seed; an uncuttable rendered
  take means the gesture has nothing to propose (surfaced by the windowed smoke, which
  had to mint a sentence boundary first).
7. **The sheet's click-to-place = one button per legal boundary** (the functional-
  unstyled reading of "click-to-place cut marker": the placeable positions are exactly
  the legal cuts; free-form clicking would only ever snap to them anyway).
8. **`newBlock`'s churn delta is grapheme `count`** — consistent with extract/divide/
  restoreCommit's in-core convention (the editor's autosave deltas remain UTF-16;
  churn is approximate by design, AppSpec §10).

**Deltas / residual notes (for the cold review's eyes):**
- Text-undo clearing on structural rewrites rides `renderFull` (Phase 7's tested path);
  headless tests cannot observe `NSTextView.undoManager` (nil without a window), so the
  clearing is not directly asserted in the gesture tests — it is the same line
  `renderFull` has always executed.
- `openDivideWCeremony` has a ms-scale window between its flush and the fan fetch;
  the sheet is window-modal once up, so no typing can land mid-ceremony — the window is
  before presentation and closes with the fetch. Accepted.
- Availability recompute costs 4 planner calls per caret/selection change (each a
  boundary scan of the caret block — block-bounded, P1-compatible); the windowed smoke's
  keystroke budget (< 16.7 ms per keystroke at 10k words) passes WITH this recompute in
  the pipeline, so the cost is measured, not assumed.
- `interiorBoundaries(of:)` in the VM duplicates the planner's one-line interior filter
  (the snap function itself is shared); noted as cosmetic.
- The soak runs the paragraph segmentation mode only (one-block journal posts never
  crystallize and their single block takes gestures like any other; the capture surface
  has no gesture doors by design — CoreDescription pillar 8).

**KnownIssues reconciliation (both rows owned by 9):**
- **"Cross-block re-bracketing" — resolved, removed.** The ratified v1 line shipped
  exactly: in-one-block spans (composed middle-span gesture, single-variant; extract for
  edge spans) and cross-boundary spans refuse with the workaround named in the copy.
  The messy cross-fan case was to be re-owned "only if daily use demands it" — her daily
  use hasn't started on gestures yet; the checkpoint can re-own it if wanted.
- **"Undo menu labels + text-undo across identity rewrites" — resolved, removed.**
  Part 1 (labels) shipped: observable `UndoStack` → `UndoMenuState` → per-op Edit-menu
  titles, disabled-when-empty. Part 2 (text-undo cleared on programmatic rewrites; a ⌘Z
  crossing a boundary refuses): the clearing is this plan's own mandated hygiene rule
  ("text-undo is cleared on every structural rewrite") and stands as the designed
  posture — recorded here as the disposition rather than parked again.
- (The 9b-owned `setEntryDate` row stands untouched.)

**Still open for the author at the checkpoint:** the combined manual feel pass (vi —
Phase 7's §5 items + this phase's gesture items, one sitting per her 2026-07-07 call);
whether the messy cross-fan re-bracketing case gets re-owned; and the Phase 8 device
rounds (the handoff's items #3 and #6 closed at the mid-phase walk — Keychain ratified,
A5 deployed).

*(Master-plan pointer/table update, the Phase 9b plan authoring from its brief, and the
author handoff are deliberately NOT done yet — the coordinator holds them until the
review ladder closes.)*

---

## Review round 1 (2026-07-07) — 1 MAJOR / 4 MINOR / 2 NIT; all AGREED; every fix below

Fresh counts after the round: **core 430/51 · Mac app 211/36 · mobile 11/4** — all green;
TK1 audit clean. Same-model flow: no disputes went to arbitration.

**MAJOR (idle-mint born mid-structural-flight) — AGREED, fixed, red-on-old pin.**
Mechanism re-traced independently and confirmed: `idleMintTail` never consulted
`structuralInFlight`, and `runStructural` neither cancelled nor held `tailIdleTask`, so
the 2 s clock could birth a mint during the door's op/fetch suspensions; in the broken
ordering (the mint's committed row reaching the gesture's fresh fetch) the +1 shape guard
fails → `renderFull` materializes the minted block AND the still-unconsumed `tailText`
(the author's words visibly duplicated) → the late `finishMint` crystallizes a duplicate
index entry (index ≠ store; nothing heals it headless). Fix, both doors: `runStructural`
cancels `tailIdleTask` at entry and re-arms in its defer; `idleMintTail` re-arms-and-
returns while `structuralInFlight`. **Pin honesty note:** the first pin attempt targeted
the traced CONSEQUENCE (duplication) and passed on both sides — not because the finding
was hollow (a mint verifiably WAS born mid-flight; `mintInFlight` flipped true) but
because the corrupting ordering is a fetch-vs-commit race the harness consistently
loses (the reader snapshot beats the mint's write transaction). The shipped pin targets
the MECHANISM deterministically: with the gesture provably suspended mid-flight, the
clock fires and `mintInFlight` must stay false (`anIdleMintIsNeverBornMidStructuralFlight`
— verified red on the pre-fix code: `mintInFlight → true`); the post-settle consistency
checks and the held-tail-still-mints-afterwards check ride along as the belt.

**MINOR 2 (mid-flight header delivery reopens the keystroke fence) — AGREED, fixed,
red-on-old pin.** Mechanism confirmed: `adoptHeader` set `isEditable` unconditionally,
and the structural op's own `last_touched_at` stamp fires the very header observation
that could deliver mid-flight — reopening the flush→op window whose stale whole-buffer
autosave is the forbidden duplication class. Fix: `adoptHeader` skips the `isEditable`
write while `structuralInFlight` (the flight's defer re-derives editability from the
freshest header, so a mid-flight seal still lands at flight end). Pin:
`aMidFlightHeaderDeliveryCannotReopenTheKeystrokeFence` — deterministic staging (the
gesture task suspended mid-flight while the test holds the main actor), verified red on
the pre-fix code (`isEditable → true`), and asserts editability returns after the flight.
`structuralInFlight` became `private(set)` for both pins' staging.

**MINOR 3 (oracle comment claims a release heal that is compiled out) — AGREED, doc-only
fix; the optional release tripwire CONSIDERED AND DECLINED, then SUPERSEDED by an
author-directed source-level fix (2026-07-07, folded into round 2).** The comment now
states the truth: nothing in `verifyDifferentialOracle` ships in release. The tripwire
was declined as unpinnable (its release-only branch is untestable by the debug-only rig
— the deep oracle strictly subsumes the O(1) length check in debug, and staging any
oracle firing crashes the test host via the debug `assertionFailure`) and WEAK (length
checks miss same-length byte divergence — the very release scenario the reviewer
traced). The author reviewed the disposition and directed the replacement that CAN carry
its pin, enabled by MINOR 5's extraction: **retained-byte verification inside
`StructuralSeamEdit.derive`** — guard-level prevention in EVERY build, not detection.
Disposition and pins recorded under Review round 2 below.

**MINOR 4 (convergence test's "compound … exactly as the editor runs it" ran ONE divide)
— AGREED, test-scope fix.** The compound now runs TWO divides (cut 15, then the
successor at 12 — the editor's successor-cut shape); the byte-identical-dump assertion
after the compound's ONE undo is the pin (an inverse missing the second mint would
diverge the stores). No product-code change, so no red-on-old owed; the claim and the
code now match.

**MINOR 5 (seam→edit derivation embedded in the VM; fallback branches untested) —
AGREED, extraction done + the payoff pins landed.** Traced degradation (recorded per the
hallucination guard): the shape-guard `return false` branches protect text integrity on
the one path that rewrites the author's surface, yet were reachable only through
unstageable pipeline states — an untested safety net — and the growing VM mixed a pure
computation with AppKit application (CLAUDE.md hygiene). The derivation moved
behavior-neutrally to `StructuralSeamEdit.derive(seam:oldIndex:fresh:) -> Edit?` (new
file, with `StructuralSeam` beside it); the VM's `applyDifferentialStructural` now only
applies the derived edit. The payoff: `StructuralSeamEditTests` — exact-edit equality on
every happy path (including document-coordinate placement for later entries and both
merge join kinds) and a DIRECT pin on **every** fallback branch (divide: count/source-ID/
successor-ID/overlong-prefix/out-of-range; extract: swapped order both edges, wrong
source, overlong remainder, count; makeBlock: count, middle-ID, suffix-ID, overlong
halves; merge: count, wrong ID, impossible join, missing trailing neighbor). No
red-on-old pin owed (behavior-neutral by design; the whole gesture suite + soak + spy
pins re-ran green unchanged as the neutrality evidence).

**NIT 6 (text-undo clearing asserted nowhere) — AGREED, fixed.** The windowed structural
smoke — the one place with a real `undoManager` — now pins it: typing registers entries
(`canUndo == true`, guarding vacuity), the gesture clears them (`canUndo == false`).
Closes the assertion gap recorded against the resolved KnownIssues row.

**NIT 7 (a suffix selection swallowing only the tail separator refuses as
`openTailTarget`) — AGREED, fixed, red-on-old pin.** The tail test now excludes a
non-empty selection whose only overshoot is the tail SEPARATOR itself (`upperBound >
separator + 1`): the same overhang tolerance interior seams already get — only selected
tail TEXT makes a selection tail-side. Pin:
`aSuffixSelectionSwallowingOnlyTheTailSeparatorStaysBlockSide` (separator-only overshoot
→ suffix extract; one unit further → still `openTailTarget`, preserving the pinned
crossing-into-tail behavior) — verified red on the old threshold by behavioral revert
(the reverted line answered `openTailTarget`).

---

## Review round 2 (2026-07-07) — 1 NEW MAJOR / 1 MINOR / 1 NIT (all AGREED, all fixed)
## + the author-directed retained-byte fix, folded into the same batch

Fresh counts after the round: **core 430/51 · Mac app 220/39 · mobile 11/4** — all green;
TK1 audit clean; Release build green. The round-2 reviewer also re-verified all six
round-1 fixes in code with their pins (its clean bill).

**MAJOR (differential guard validates the seam but not the rest of the projection) —
AGREED, fixed, red-on-old pins for every seam kind.** Mechanism re-traced and confirmed:
`derive`'s guards never referenced a fresh slot outside the seam, so a concurrent write
(a sync pull apply can commit between the op's transaction and the fetch — GRDB
serializes writes) changing a NON-seam slot's length passed every guard; the rebuilt
index then adopts the remote slot's new length while the surface shows its old text —
index geometry ≠ surface geometry. In RELEASE (the author's ratified daily-drive
configuration) nothing checks: the next keystroke's `recordAutosave` reads `viewText` at
wrong offsets and writes scrambled text into `working_text` (the forbidden store-level
class), and the assumed healing delivery instead hits `applyDifferential` at misaligned
ranges — `programmaticReplace` had no bounds guard, so past-end ranges raise an
uncatchable NSRangeException. Fix: `derive` now requires every non-seam fresh slot to
correspond to its old entry under the seam's index mapping (same blockID, same UTF-16
length; O(#entries) value comparisons — the same class as the index rebuild the caller
already performs). Pins (`SeamEditNonSeamGeometryTests`): length drift on either side of
the seam, identity drift, and every seam kind (divide/extract/makeBlock/merge) — plus an
aligned-neighbors control proving the guard is correspondence, not paranoia. **Verified
red by behavioral revert** (guard short-circuited to `true` → all six refusal
assertions failed across all four seam kinds), restored, green.

**Author-directed fix (round-1 MINOR 3 follow-up): retained-byte verification —
IMPLEMENTED, red-on-old pins for every seam kind's retained region.** Mechanism traced
per the directive and confirmed for all four seams: the old guards used LENGTH
arithmetic for the regions the differential edit deliberately does not rewrite, so a
same-length remote rewrite of a seam entry's text (a sync apply between op and fetch)
passed the guard and left the surface's retained bytes silently disagreeing with the
store until the delivery healed — with typing in that window autosaving stale bytes over
the merged text. Fix: `derive` gained an `oldTextAt` input (the pre-edit surface text,
consulted for SEAM entries only — O(seam), never O(document)) and now byte-verifies
every retained region: divide's kept first half IS the old prefix; extract's kept
remainder IS the old suffix/prefix; makeBlock's kept prefix AND suffix ARE the old
edges; merge's two halves appear VERBATIM around the join (byte equality now decides the
join kind, subsuming the old length arithmetic). Any mismatch → nil → full render from
fresh, in EVERY build; the DEBUG deep oracle stays as-is (this is prevention, not
detection). A surface/index length-disagreement guard on `oldTextAt` rides along,
pinned. Pins (`SeamEditRetainedByteTests`): same-length different-byte doctored
projections for divide (kept half), extract (both edges' retained remainders), makeBlock
(both kept edges), merge (both halves) — **verified red by behavioral revert** (byte
checks bypassed, merge reverted to length arithmetic → all seven refusal assertions
failed), restored, green.

**The honestly-documented residual after BOTH guards (per the coordinator/author):** a
same-length BYTE change to a NON-seam slot still passes — deliberately: geometry stays
aligned (the index is safe; autosave offsets are correct), the stale surface text heals
through the ordinary projection delivery already in flight (the concurrent apply that
caused it fired the observation), and checking it would be O(document) per gesture
(P1: the differential's economy stands). This is the same delivery-window semantics
every Phase 7 projection lives under. Recorded here and in the code doc
(`StructuralSeamEdit.swift` header).

**MINOR (W ceremony cut fidelity unguarded against remote edits during the sheet's open
lifetime) — AGREED, fixed, red-on-old pin.** Mechanism confirmed: the ceremony state
snapshots the fan at open and was never re-verified; a sync round editing a marked
take's `working_text` while the sheet sat open meant confirm sent `{variantID:
staleCut}` and `divideW` cut the CURRENT store text at that offset — a well-formed but
wrong-position cut, silently. Fix: `confirmDivideWCeremony` re-reads the fan and
compares every MARKED take's current text against its snapshot (a vanished marked take
counts as drift); on any drift it refreshes the ceremony instead of cutting — marks
survive by identity, unchanged takes keep their placed cuts, the active take's cut
re-snaps into its new text via the planner's own `snapToInteriorBoundary`, other changed
takes re-seed via `CutPropagation`, and a status line says the takes changed; if the fan
itself dissolved the ceremony closes with a message. Pin
(`aStaleCeremonyRefreshesInsteadOfCutting`): drift a marked take mid-ceremony → confirm
→ no divide ran, ceremony refreshed with the current text and a re-snapped legal cut,
marks kept → confirming the REFRESHED ceremony cuts for real. **Verified red on the
pre-fix code** (the stale confirm divided: 2 blocks where 1 was asserted).

**NIT (`programmaticReplace` has no bounds guard) — AGREED, taken as defense-in-depth
(no pin, per the reviewer's own honest framing).** Traced mechanism: the one storage-
MUTATING path lacked the clamp its read-side siblings (`viewText`,
`setBlockAttribute`) have; an out-of-tiling range raises an NSRangeException Swift
cannot catch — a crash, against the file's recover-not-crash doctrine (Phase 7 MINOR 7).
Its only live route was the round-2 MAJOR's geometry breach, now closed — hence no
independent red-on-old pin is possible (hardening, not a bug fix; justification recorded
here per the guard). The fix: bounds guard → `desyncRecovery()` (assert-in-debug,
re-render-from-store), consistent with the posture everywhere else.

**Process note (recorded for honesty):** the round-2 clean bill observed the
`VariorumMobile` scheme's LaunchAction Debug→Release in Phase 9's diff. That change is
the AUTHOR's Xcode GUI edit implementing her ratified #4 (Release-install on the
phone); it was sitting in the working tree and was swept into the `3afd9dc` recordings
commit by `git add -A`. It stands (it implements a ratified decision); noted so the
attribution is accurate. TestAction remains Debug, so the oracle-bearing tests run
in Debug.
