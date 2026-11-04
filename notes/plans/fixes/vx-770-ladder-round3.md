# VX-770 — Ladder round 3 (SCOPED: the W2 cycle's fix; fable-reviewer, 2026-11-04)

**Reviewer:** Fable (fresh session, zero W2-cycle implementation context; `notes/REVIEW_PROMPT.md`
run verbatim over the scoped diff).
**Diff under review:** `cfae861d1..HEAD` (HEAD = 4b564b7c0), branch `vx-770-takes-compare-window` —
the W2 cycle: the walk-world pin (c7710ca6e), the pure mechanism pin (b44ab4916), the fix
(a5fbc6151, `TakesArticleScroll.swift` only), the record commits.
**Anchors read whole:** ladder rounds 1 and 2 (`vx-770-ladder-round1.md`, `-round2.md`), the run
record's THE WALK RECORD, THE WALK ADJUDICATION, THE W2 CYCLE through the self-assessment. Every
source and test line of the diff read in this session; the fix's mechanism re-traced by my own read
through `TakesArticleScroll.swift` (`articleLandingReport`, `reaimWhereTheColumnReEstimated`,
`noteArticleRowFrame`, `landArticle`, `consumeArticleGeometry`), `TakesBoardView.swift`'s report
roads, `TakesViewModel.swift`'s forwarding, and `TakesBoardLayout.marginCardHeight`. Mounted
evidence read with my own eyes: `App/Variorum/DerivedData/logs/vx770-w2-red.log` and
`vx770-w2-green.log`, including the per-case `W2-TRACE`/`W2-SUMMARY` lines.

**STATUS: COMPLETE — NO new BLOCKER or MAJOR. The W2 fix ships; the ladder closes FINALLY.**

---

## The fix, re-traced (the hallucination guard)

The mechanism holds end to end from my own read:

- **The blind spot is real and exactly as traced.** Pre-fix, `reaimWhereTheColumnReEstimated`
  required BOTH `content != landingJudgedContent` (the event) and
  `landingTargetFrameContent == content` (freshness) — both keyed on the column's content height
  reaching the brain BEFORE her row's frame. A growth SwiftUI lays out itself (margin grid's cards,
  sized on `PaneSurface.deliverMeasuredHeight`'s deferred main-queue turn →
  `TakesBoardLayout.measuredTextHeights` → the next render) delivers her row's moved frame while
  `lastArticleGeometry` still holds the old height: the event gate fails at her row's report, the
  freshness gate fails at the column's report that follows (her frame stamped at the old height) —
  or that report coalesces away entirely. No aim; the watch corrects from quiet ≥ 0.25 s later: the
  walk's one hop, 3/3.
- **`landingTargetJustMoved` is honest.** It is set ONLY inside `noteArticleRowFrame`'s
  equality-gated write (`TakesArticleScroll.swift:1156–1171` — a < 0.5-pt re-report writes nothing
  and sets nothing), only for `placementID == articleLanding`. So "just moved" means the target's
  frame genuinely changed on this pass.
- **The flag cannot leak past its paired report.** The only setter's only reach is the view's one
  geometry-hook closure (`TakesBoardView.swift:814–818`): `model.noteArticleRowFrame(...)` then
  `spendArticleLanding(column, asReport: true)` → `articleLandingReport`, synchronously in the same
  MainActor closure, and the report consumes the flag at its very top (`:845–846`) on EVERY path —
  before the watch guard, before the banded second aim. No other `noteArticleRowFrame` caller
  exists (swept: the layout forwarder `TakesBoardLayout:536` ← `TakesViewModel:1033` ← the view).
  `landArticle` resets it per landing (`:352`).
- **The one-aim-per-event bound holds.** Each real frame move = one flag set = one judging at the
  paired report; an aim's own `scrollTo` moves the frame once more, whose judging finds the row
  home (`landingDecision == .none` → nil) and the chain terminates; a row that will not settle
  spends `landingStormAimsLeft` (the pocket's 24) and falls to the watch — the backstop intact.
  The 64-aim fence and `articleLandingAimsLeft` decrement inside the ONE step, unchanged.
- **Entry-kind-only and the exclusions hold.** `landingIsBanded` =
  `articleLanding != nil && articleLandingKind == .entry` (`:138`); `!articleEntryRidesThrough`
  unchanged in the guard — R-756-2's ride-through road stays excluded (R-W2-4 accurate); bloom,
  find and restore never reach the re-aim.
- **Her hand still wins.** A user scroll ends the landing at the geometry hook
  (`consumeArticleGeometry:1519 — if positionedByUser { articleLanding = nil }`), and R1-1's
  measured order for a scroll step is geometry-before-rows, so the hand-over lands before the
  target's scroll-moved frame could set the flag. (See R3-O3 below for the one speculative corner.)
- **P1/P-8:** one Bool read and write per report, O(1); the `order` autoclosure is still lazy
  through the new parameter (the inner `order()` is re-wrapped, evaluated only past the guards);
  the slot order builds only when a re-aim is decided. The green log's aims (7→9/11 per case) are
  in-storm aims replacing quiet hops, well inside the pocket.
- **R-770-1 (the stay-open contract):** the fix touches no line of the open-fan set, and the
  walk-world pin re-asserts `expandedBlocks == fannedBlockIDs` after the landing on both sides.

## The pins, verified

- **The pure pin (`TakesLateRemeasureReaimTests`) is the deterministic sentinel.** Red-on-old
  re-derived from the code (both arms: `.wait` at her row's report — the event gate's
  `content == judged` — then `.wait` at the column's — the freshness stamp at the old height), and
  EXECUTED red in the mounted window (`vx770-w2-red.log`: both arguments failed at `:1105` in
  0.018 s — no timing involved). Green on the fix tree. The guard
  (`aLateGrowthTheColumnReportsFirstIsStillReaimedOnce`) is green on BOTH trees by my own trace of
  both code shapes — batch 1's column-first order still re-aims exactly once, so the fix changed
  nothing it was not meant to.
- **The walk-world pin (`theWalksNoteLandsOnceAndStays` ×4) staged the live seam and expressed it.**
  The staging's non-vacuity is ASSERTED, not assumed (`measuredHeightWrites > 0`; her tallest
  margin card past the 110-pt sticky — verified `railCardHeight = 110`,
  `marginCardHeight(measuredText: nil) == sticky`), and the red log shows it real: cards 225–330 on
  every margin-grid case. The red case's trace is the walk's story in miniature — P23→P33 on rev:
  rest at her=124.5 (≈19.5 pt off home, the walk's Terminal 19.6), card already 293, then
  `hops 0→1` at ~580 ms with her=105 after (the walk's `HOP 1 at 611 ms`). On the fix tree the
  same case reaches her=105 at ~313 ms with two more in-storm aims and ZERO hops, still at
  1113 ms. The control (stack) is green on both trees — the staging does not over-reach.
- **The shared-world params are byte-safe.** `withExpansionWorld`'s `prose:`/`alternate:` default
  nil → `expansionProse(i + 1)` / the batch-1 alternate string, byte for byte; every existing
  caller passes nothing; batch 1's pin is untouched in the diff.
- **The revert tree is honest.** Commit order pins-before-fix (b44ab4916 → a5fbc6151), so the rev
  tree's behaviour file IS the pin commit's; the record's `nm` lines (`landingTargetJustMoved` ×6
  in w2, ×0 in w2-rev) and both TEST BUILD SUCCEEDED logs are on disk as named.

## Weighings the round was asked for

- **W1 — are the pins robust sentinels or timing-lucky? LAYERED, AND ADEQUATE.** The red-on-old
  burden is carried by the PURE pin, which is red by construction, timing-free, and was executed
  red for real. The mounted walk pin's RED expression is timing-dependent — 1 of 3 margin-grid
  cases red in this window, and batch 1's own marginGrid arm red here (`:814`, hops) after being
  green at b5gate on the same production bytes — but that is the nature of staging a deferred-turn
  race in a harness, the reading rule pre-committed to exactly this mix ("the cases that red are
  the gate-1 evidence"), and the traces let the greens be classified honestly: P25→P35's `card=`
  grew 110→330 BETWEEN aims 6 and 7, i.e. inside the storm, where batch 1's content road answers
  it — the harness turn cadence, not a staging failure. On the FIX tree the green is structural,
  not lucky: both report orders now aim, so there is no timing in which the blind spot expresses
  (the four order combinations traced: row-first → the flag road; column-first → batch 1's stamp
  road; column coalesced away → the flag road with the stamp equal; row unmoved → the row is where
  it was, nothing owed). Future flakiness on these pins would therefore be NEW information, not
  this mechanism.
- **W2 — the batch-1 arm's "honest anomaly" is CORROBORATING evidence, not a pin defect.** Its red
  on rev in this window means the blind spot was reachable even in the short-take world (the
  column's geometry report coalescing under load — the app's own
  `tried to update multiple times per frame` lines name the coalescer), so its b5gate green was
  itself timing-lucky. The fix closes that arm's flakiness at the root rather than masking it.
- **W3 — the reporting-order inference (R-W2-2) is immaterial to correctness.** The fix is correct
  under either order and under a dropped column report (traced above); the inference only names
  which order the app took on the walk's nights. Honestly marked as inference in the record;
  nothing to chase.
- **W4 — the two walk stories that did not reproduce (P25→P35, P35→P23) are correctly kept as
  guards.** Green-both-sides members of a parameterized pin whose red member and whose pure twin
  carry the evidence; their green-side assertions (0 hops, no later move, home, non-vacuity) are
  outcome-complete regression lines. Within the pre-committed reading rule, recorded with traces.
- **W5 — the F3 interaction (R-W2-3) is accurately scoped.** F3's revisited-height collision is
  closed for a REALIZED row whose re-basing moved it (her row's own report now carries the event
  past the `content != judged` refusal); the unrealized-target arm — content returning to exactly
  the judged height with no row report possible — still keys on the height alone and remains
  F3's record-only corner. The claim "partly closes" is exactly right.

## Findings

### R3-O1 · NIT (test-only observation) · `TakesExpansionMemoryTests.swift:597` (`movesAfterARest`) · the later-moves oracle sits at its own sampling boundary — the hops counter is the load-bearing finding line

On the red run, the P23→P33 case fired ONE issue (the `:1009` hops line), not the predicted two:
`W2-SUMMARY … hops=1 … laterMoves=[]` — a real 19.5-pt hop at ~580 ms that `movesAfterARest`
(quiet 250 ms) did not count, because `rested` flips true only when a SAMPLE lands ≥ 250 ms into a
still run, and this window's observed sample cadence after the storm (~270 ms: trace stamps 311 →
580 → 851) leaves no confirming sample inside the quiet window before the hop. The walk's hops come
0.25–0.33 s after rest — exactly at this boundary — so the motion oracle can only ever
half-witness them; `articleLandingCorrections == 0` is the assertion that actually catches the
mechanism, and it did. No action owed tonight: the pin is red where it must be on both of its
worlds' evidence lines together. Worth one line in the pin's doc (or the record) so a future
reader does not read `laterMoves=[]` beside `hops=1` as a contradiction. No pin demanded
(test-sensitivity observation, no product behaviour).

### R3-O2 · NIT · prediction-table bookkeeping · the mounted results are not yet written back into THE PREDICTION TABLE

The record's table (rows 1–8) still reads "PENDING the window" / "R predicted", while the window
has run (logs 09:35/09:37). The actual outcome is a MIX the reading rule anticipated: rows 1–2 red
(executed), row 3 green, rows 4–5 GREEN-on-rev (traces say in-storm growth — the turn cadence),
row 6 RED-on-rev (hops=1), row 7 green, row 8 RED-on-rev (the batch-1 arm — the anomaly). The
orchestrator should fill the table with these befores closing, including the row-8 anomaly and its
reading (W2 above), so the record's evidence column matches what ran. Bookkeeping only; the
evidence itself is sound and on disk.

### R3-O3 · NIT · `TakesArticleScroll.swift:954` · SPECULATIVE — a her-scroll row report that beat the geometry hook could spend one aim against her hand

If, during a pending entry landing, her own scroll's row-frame report ever reached the brain
BEFORE the geometry hook's `positionedByUser` hand-over, the flag road would judge the scrolled-off
row and aim once back. I cannot trace a mechanism that produces that order: R1-1 MEASURED
geometry-before-rows for a scroll step, the hand-over kills the landing at the geometry hook
(`:1519`), and the pre-fix code had the same class open through a content change during her scroll.
No pin could go red on old for this (the old tree simply never aims there), so per the prompt's own
standard this is labelled SPECULATIVE and recorded, not raised. If a walk ever shows a landing
fighting a wheel, this is the line to look at.

## Clean bill (checked and found solid this round)

1. **The fix diff is exactly its claim:** one file, one Bool, the two gate widenings, the reset in
   `landArticle`, the stamp beside `landingTargetFrameContent` — nothing else behavioural in
   `cfae861d1..HEAD` (3 files: fix, tests, record).
2. **Consumption discipline:** flag read-and-cleared at the top of `articleLandingReport` on every
   path, set only under `placementID == articleLanding` inside the equality-gated write, reset per
   landing — no stale read reachable, traced through all report roads including the banded second
   aim and the pre-watch fall-through.
3. **Nothing else moved:** seed, prune, restore, resolver, band, flash, watch/policy, step, pocket
   (24), fence (64), `PaneSurface`, the margin-grid card arithmetic, every view — byte-untouched by
   the behaviour commit.
4. **Scope fences:** no `Sync/`, no schema, no custody, no editor-seam line (`EditorTextView`,
   `BlockRangeIndex`, `PaneTextAuthority`, `PaneSurface` untouched), no `Shared/` file, no
   capability registry, no TK1 API, no literal colour, nothing corpus-proportional, nothing
   mobile-visible. No canon delta owed by this cycle (the fix makes no product-behaviour choice —
   it restores the landing contract batch 1 already shipped); nothing for `notes/QUESTIONS.md`.
5. **Evidence hygiene:** the red and green runs are real and on disk, read in this session; the
   rev tree's construction (shared clone, one behaviour file at the pin commit, `nm` ×6/×0,
   sha256-checked worktree) matches round 2's verified pattern; pins committed before the fix; the
   suite-level green (9/9, plus batch 1's ×4 green in the same green run) covers the touched
   surface, and the record correctly routes the WHOLE-target run to the merge gate.
6. **Commit hygiene:** one commit per piece, each pushed; no `Co-Authored-By`/`Claude-Session`
   trailers anywhere in `cfae861d1..HEAD`; the worktree carries only the pre-existing
   `Package.resolved` artifact (unchanged since rounds 1–2; dispose at closeout as already
   planned).
7. **The doc comments tell the truth:** the W2 blocks in `TakesArticleScroll.swift` state the
   mechanism, the order caveat and the bound exactly as the code has them; the pins' doc comments
   quote the walk's real stories.

## Verdict

**No new finding above NIT. The cycle's fix SHIPS; the ladder closes finally at this scoped round.**
What remains is execution and bookkeeping, not review: R3-O2's table fill-in; the gate tree rebuilt
on final bytes and the merge-gate whole-target run; the W2 walk re-run on the gate tree per
READY-FOR-SUITES item 4 (the acceptance is the story's `0 hops` and a burst with no second
movement); the W2-cycle residues (R-W2-1..4) and the walk look-lines to tickets at closeout as the
adjudication already plans.
