# 18l U1 — ladder ROUND 1 (cold review, `opus-reviewer`, 2026-09-26)

**Diff under review:** `cf9a596b..2eff1b27` (18 commits; product code `5e7cbf34` plus `905ee936`'s
policy doc line; the probe `7d3a83f1`/`0bf54efe`; pins `3a5e471b`/`c280a686`; the harness commits
`09c39388`/`9bea5c6d`/`3e8a17aa`/`bbcd65ba`/`905ee936`; the rest are record-keeping). The files: `Surface/LandingAuthority.swift` (two surface cases, two policies),
`Features/ReadMode/ReadNoteLanding.swift` (new), `ReadEditPane.swift`, `ReadModeView.swift`,
`Core/Views/VisualWalkProbe.swift` (the DEBUG `rl` read), three test files, and `Tools/VisualWalk/`
(`read-landing`, the Notification-Center column rule, the `readedit-click` AX role). Review anchor:
`notes/plans/phase-18l-navigation-feel.md` (the U1 BRIEF, the U1 RECORD, the orchestrator's acceptance),
the charter's U1 bullet (`notes/plans/post-13u-health-rounds.md` KICKOFF 2), QUESTIONS #151 and the health
review §1. Prompt: `notes/REVIEW_PROMPT.md`, run verbatim. The review was read-only: this file is its
only repo write. Two experiments (MAJOR-1, MINOR-1) ran in a scratch `git archive` copy under the
session scratchpad, on an in-memory store, and nothing from them was committed.

**STATUS: COMPLETE** — 0 BLOCKER · 1 MAJOR · 3 MINOR · 2 NIT.

## SEAM CALL (the brief's standing check)

**No editor-seam body is touched, and no Fable pass is owed on seam grounds.** `git diff --name-only`
shows no change to `EditorTextView`, `EditorViewModel`, `PaneSurface`/`PaneTextView`,
`PaneTextAuthority`, `BlockRangeIndex`, `JumpPrimitive` or `runStructural`. There is no custody or
keychain code, no `Sync/`, no `Sources/`, no schema, and no change to what a default means (both resting
anchors stay byte-identical: `ReadPageColumn.restingAnchor` = `ReadModeView.pageRestingAnchor` = 0.08,
`ReadEditPane.restingAnchor` = `.center`). `ReadNoteLanding.swift` only READS two static constants off
the seam (`PaneTextView.proseLeadingInset`/`proseTopInset`, in `ReadNoteHeights.metrics`), and the edit
face mounts `PaneSurfaceView` with every argument unchanged.

**One thing for the orchestrator to weigh (not a finding).** 18l's CAST line lists "landing/reading-position
capture code" among the Fable triggers. The brief narrowed that to seam bodies, and the orchestrator's
acceptance records Opus deliberately. MAJOR-1 below is exactly the landing loop's interaction with the
live pane (the landing corrects while the one live editor sits inside its target). The fix I propose
stays off the seam: it goes in `ReadEditPane`'s closures. If the fix pass reaches into `PaneSurfaceView`'s
callbacks instead, that is the point at which a Fable round 2 becomes the right cast.

## FINDINGS (severity-ranked)

### MAJOR-1 · `ReadEditPane.swift:79–88` + `:151–165` + `ReadNoteLanding.swift:70–80` · A click into the landed block during the landing's one-second hold now MOVES THE PAGE under her caret. This is a regression U1 introduced, measured red on HEAD and green on the pre-U1 tree.

**What is wrong.** On Read ▸ edit every landing stays pending for at least `minimumHold` = 1.0 s
(`LandingPolicy.readNoteEdit`, `LandingAuthority.swift:221–225`; the trials' `ms=1005–1033`). The residual
the face reports is measured against its CENTRE anchor
(`ReadLandingResidual.residual` → `ViewportCarry.topInset(fraction: 0.5, blockHeight:, …)`, so
`rest = 0.5·(V − h)`). That makes the block's "home" depend on the block's own HEIGHT. When she clicks the
landed block, it swaps from the read tier to the live pane (`onTap` → `model.makeLive`, `:79–87`). The two
tiers' vertical metrics differ (KnownIssues row 89, S3, measured at 16–19 pt on 5-line blocks and 64 pt on
a 17-line block), so the block's height changes while its TOP stays where it was. The row's existing
observer reports the new frame (`rowMoved` → `landing.noteTop(target, residual)`, `:157–164`), and the
residual is now −Δh/2. At the next quiet look `LandingSettle.decide` finds |top| > 2 with the budget
unspent → `.correct` → `proxy.scrollTo(target, anchor: .center)`. The page scrolls about 0.25 s after her
click, under the caret she just placed. Before U1 the pane never moved after a click: its own contract
reads *"A pane click never sets it (clicking what you can see must not move it under you)"*
(`ReadEditPane.swift:37–39`). The authority's own header says *"the one thing a landing must never do is
fight her hand"*, but this adoption hands over only on a scroll (`onScrollPhaseChange == .interacting`,
`:121–123`) and never on a click or an edit.

**Evidence: measured, not only traced.** I ran a scratch copy of `2eff1b27` (in-memory store, a real
`NSApp.sendEvent` click through `ReadModeTests.World.click`). The fixture was 80 five-sentence paragraphs,
arriving on block 41 via the row-39 road, with a click on the landed block's middle at +290 ms and again
at +589 ms:

| Tree | After the swap (top · h) | 3 s later (top) | DEBUG story |
|---|---|---|---|
| **HEAD `2eff1b27`** | 273.5 · 239 → 229 | **278.5 (the page moved 5 pt)** | `target residual=-5 hops=0 \| HOP 1 at 606 ms (top was -5.0) \| … DONE: settled at top=0.0 after 1 hops` (the +589 ms click: `HOP 1 at 968 ms`) |
| **pre-U1 (`cf9a596b` product files)** | 273.5 · 239 → 229 | **273.5 (no move)** | — (no authority) |

So S3 alone changes the height and never the top, and the 5-pt move is the correction and nothing else.
The move is Δh/2 of the swap. Here that was 5 pt (a 239-pt paragraph that swapped to 229). S3's own
measurements of the tier mismatch (lines rising 16–19 pt on 5-line blocks, 64 pt on a 17-line block)
put it well above that on other blocks. The same mechanism fires for (a) a click on ANOTHER block above the target (its swap shifts
the target by Δh, and the correction scrolls the page away from the block she clicked), and (b) typing
inside the hold after the click-through (the block is live from mount, and each wrapped or added line
moves the centre by half a line). Both have the same cause and the same fix. The walk and the harness
never covered it: W2/W3 did not click inside the hold, and `readedit-click` clicks a block no landing is
aiming at.

**The pin, red on HEAD and green on the pre-U1 tree (verified both ways).** In a `ReadNoteLandingTests`-shaped
mount on the edit face (uniform multi-line paragraphs, arrival at a deep block), after the target's
frame first appears, wait 0.15 s (and a second case at 0.45 s). Then run `world.click(at:
world.windowCenter(of: frame))`, poll until exactly one editable pane, sample the target's
`ReadModeOracle.editBlockFrames` minY right after the swap and again 3 s later, and require
`abs(settled.minY − afterSwap.minY) ≤ 1`. On HEAD it fails with `5.0 > 1` in both cases.

**Proposed fix.** Hand the landing over on HER acts inside the pane, just as her scroll already does.
`ReadEditPane`'s `onTap` closure calls `landing.userTookOver()` before `onSelect`/`makeLive` (the
signpost then says `end=handedover`). The live pane's edit path (`ReadEditBlock`'s `onEdit`, via a closure
the pane passes down) does the same, which covers typing after the click-through. Do NOT end the landing
on `model.blur()` or on the live pane's programmatic caret placement at mount: the column click's own
blur reflow above the target, and the click-through's live-pane height convergence, are exactly what the
watch SHOULD correct. Nothing changes on the page face (its only in-page act, the click-through, flips
the face and already ends the landing).

### MINOR-1 · `ReadEditPane.swift:151–165,181–196` + `ReadModeView.swift:862–891` vs `LandingAuthority.swift:449,505` · On a LAZY column the authority's `tops` seed goes stale. A re-landing on a block the face has already landed, now de-realized and missed by the aim, therefore ends `settled top=0 hops=0` without ever arriving. That suppresses the blind correction the policy exists for and makes the signpost untrue.

**Mechanism (traced in code; the authority half measured, see the pin).** The authority seeds each landing from *"where every row last said
it was"* (`tops`, `:435–449`; `lastTop = tops[anchorID]`, `:505`). That premise holds on its other three
adopters, where every row exists and reports on every scroll (the Outline's and the Index's non-lazy rows,
the flow's direct children). Note Read feeds `tops` only from its PENDING TARGET: `rowMoved` guards
`landing.anchor == placementID`, the scroll observer reports only `landing.anchor`, and `land` re-seeds
only when `box.residual(placementID)` exists, which means only when the row is realized right now. After a
landing on X settles, `tops[X]` keeps its last residual (about 0) indefinitely. Nothing clears it when X
de-realizes: `onPlace(nil)` clears `box.rows[X]` but not the authority's seed. The next landing on X from
far away (a second column click on the same row, which is exactly the harness's `209:warm` / `245:warm`
steps) starts with `lastTop ≈ 0`. If that aim misses (the synthetic class this policy's
`correctsAnUnreportedTarget: true` was chosen for: the block never draws, so it never reports),
`LandingSettle.decide` sees |0| ≤ tolerance, waits out the hold, and returns `.done`. The page stays
11–14 blocks past the target, no correction is issued, and her Console reads `end=settled top=0 hops=0`.

**Reproduction is conditional.** It needs a second miss on the same block within one face mount. On her
real prose the aim has never missed (72/72), and on the synthetic shape I did not establish whether the
lazy estimate misses a second time. So the user-visible impact on today's notes is nil. The defect is in
the watch's truthfulness, which is the unit's claimed durable gain. A side effect: the `read-landing`
scenario's warm steps cannot, by construction, tell an arrival from a miss through the signpost (the
recorded warm `rl` values differ from the cold ones, 0.2 → −0.1 in `155949/`, so those particular
landings did report fresh).

**Pin (deterministic; RAN RED on HEAD in the scratch copy).** Create `LandingAuthority(policy:
.readNote, storyboard:)`, run `land("X")` with `noteTop("X", 0.1)`, and wait 1.4 s. Then run `land("X")`
again with an aim that moves nothing and no reports, wait 1.4 s, and require that the story shows
`HOP 1` and never `DONE: settled`. HEAD's answer on the second landing: `X LAND | X DONE: settled at
top=0.1 after 0 hops, 1012 ms`. It never looked for the block. **Fix, either
of:** (a) a `LandingAuthority.forget(_ id:)` that the faces call from `rowMoved(nil)` (the row went away,
so its seed is no longer a fact), or (b) a policy field (`seedsFromLastReport`, false for the two note
Read policies) that makes the pin authority-level as written.

### MINOR-2 · `ReadNoteLandingTests.swift:199–201,268–281` · The "watched" arm can pass on the PREVIOUS test's landing. `ReadLandingStory.trace` is a process-global log that no test resets, and `lastStory()` takes the last `DONE` line from anyone.

**Mechanism.** The suite is `.serialized`, and its four tests ran in declaration order in
`18l-u1-closing1.log` (synthetic edit, real edit, real read, synthetic read). Their targets carry
IDENTICAL placement ids pairwise, because `.incrementing` UUIDs restart per DB (`…025B` for both synthetic
tests, `…026B` for both real ones; see the four `the landing's story` lines in that log). If the 4th test's
page-face landing were never watched (say, a regression dropping the page face's adoption only),
`expectWatched(.readNote, maxHops: 0)` would read the 3rd test's
`[ReadNote] …026B DONE: settled … after 0 hops` and pass. The R-watch revert still reds, because it
unwatches BOTH faces and leaves the trace empty. The other landing suites reset their traces at mount
(`BookOutlineLandingTests`, e.g. `:347`; `ReadingFlowLandingTests`, e.g. `:200`), and MainActor suites that
mount Read hosts (`ReadLandingTests`, `ReadModeTests`, …) interleave at every `await` and now append to
this same log. **Fix:** `ReadLandingStory.trace = []` at each mount, and have `lastStory()` match the
target's placement id (the `LAND`/`DONE` lines carry it). **Pin:** none needed beyond the fix (it is test
hygiene). The check: temporarily unwatch the page face only, and the 4th test must red.

### MINOR-3 · `ReadNoteLanding.swift:137–279` + `ReadEditPane.swift:189–191` + `ReadModeView.swift:869–872` · With JC1 the block manifest's only consumer is the Release signpost. Its `offset`/`total`/`exact` there describe a model no row stands on, so they read differently from every other adopter's, and `leading: 0` puts the offsets outside the content space the manifest's contract promises.

**The traced degradation.** On the Outline, the flow and the Index the rows STAND on the manifest, so
`offset=`/`exact=` are the column's own asserted geometry, and a line pasted from her Console explains a
shift (the trace's §5(c) purpose, the `LandingFacts` doc). On note Read the rows are lazy (JC1), so the
column's real positions come from SwiftUI's own estimate, which is precisely what could misland. The
manifest instead computes a parallel `ProseHeightModel` estimate that nothing on screen uses. A reader of
`surface=ReadNote … offset=18759 exact=0` cannot use it the way the same fields are used one surface over.
Separately, `BookHeightManifest.leading` is documented as *"Everything above the first row … Carried so
offsets are absolute in the column's content space"* (`BookHeightManifest.swift:107–110`), but both faces
pass `leading: 0` (`ReadNoteHeights.manifest`, `:219–223`). The edit face's column sits under
`.padding(.vertical, 26)` (so every `offset=` is 26 pt low). The page face's first block sits under
`.padding(.vertical, 28)` + `.padding(.vertical, 46)` + the `ReadPageHeader` row + one 14×scale gap
(roughly 150 pt low), and `total=` omits the same chrome plus the `· · ·` footer. Cost: taking the
extents walks every block's text (`unicodeScalars.count` + a UTF-8 scan) at the first landing after any
change to the block-id list (in Read ▸ edit that is every ⏎ divide or merge). That is within the brief's
"∝ the note, once" sanction, but it buys only these three numbers. **Justification for raising it:**
JC7's claim that *"`offset=` is an honest estimate"* is half-true. It is an estimate of a model, not of the
column, and it is not in the documented space. **Options (the orchestrator's call; this is not
bug-class):** (a) keep the manifest as the ready half of #151's (b)/(c), pass the real `leading`
(edit 26; page: the header's measured height plus paddings), and add one sentence to `LandingFacts`'s doc
saying that on `ReadNote*` the offsets are a model estimate the lazy column does not stand on; or
(b) until #151 is ruled, print the Index-F1 honest unknowns (`offset=-1`, `derived = rows − measured`)
and drop the per-note extents scan and the calibration suite. A red-on-old pin exists only for the
`leading` part: compare the story's `manifest … offset=` for a landed block that is `exactAbove`
against its drawn content-space top.

### NIT-1 · `ReadNoteHeightsTests.swift:123–133` · `theExtentIsTheQueriesOwnNumbers` is tautological

It asserts `ReadNoteHeightModel.extent` against `unicodeScalars.count` and a hand count, which restates
the implementation. The claim the test is named for ("the extent = `Queries.blockExtents`' numbers") is
true on reading the SQL (`PageExtents.swift:83–89`: `LENGTH()` code points; newlines by `REPLACE`), but
nothing pins it. **Fix:** seed a post with a multi-paragraph block, a blank take, and a non-BMP character,
then compare `Queries.blockExtents(db, containerIDs: [post])` to `rows.map { extent(postID:row:) }`.

### NIT-2 · `Tools/VisualWalk/helpers/vis-foreign.swift:23–34` vs `Tools/VisualWalk/README.md:79–82` · The foreign-window safety rule changed, but its binding statement did not

The README's per-step safety section still states the rule absolutely (*"never click a point any system
dialog covers (`helpers/vis-foreign.swift`)"*). The helper now shrinks ANY full-screen
`Notification Center` window to its top-right 440×480 column. As the record states, that is the right
answer for the persistent banner, and no consent prompt is NC-owned, so the TRAPS' consent rule is
intact. But the same full-screen test also matches the overlay NC raises when its panel (the widget
sidebar) is open, and its lower-right part would no longer count as covered. **Fix:** one README
sentence naming the carve-out and its limit, and optionally require that no other NC window lies outside
the column before narrowing.

## CLEAN BILL (load-bearing things checked and found solid)

- **The review's §1.2 Console flip is real and located.** `LandingAuthority.finish` files the shipping
  signpost for both new surfaces, and the harness runs show it. I counted all six post-fix `read-landing`
  runs myself: `155949`, `160626`, `162649`, `161316`, `162000`, `163324` each carry **12 signposts, 12
  `hops=0 … end=settled`, 0 FAIL/ERROR**, which makes 72/72. The walk's `walk.txt` shows W5's
  `end=handedover` (546/569 ms) in both voices.
- **The red-on-old evidence exists as claimed.** `18l-u1-pin-prefix1/2.log`: edit face `first → nil`
  (block 201 never drew), page face green (−0.005 / −0.03 pt). `18l-u1-R-watch.log`: 4 tests / 10 issues,
  exactly the named plan: the synthetic edit arrival nil, and every `expectWatched` arm red with story
  `NONE`. `18l-u1-B1.log`: synthetic `path [0]` after the fix. The "green on both sides" real-story
  residual arms are honestly labelled as guards, not pins.
- **The JC1 departure is evidenced.** `18l-u1-experiment-A-rows-at-asserted-heights.log` (byte-identical to
  `18l-u1-A1.log`) shows paths `[100, 0]` (synthetic) and `[59, 0]` (the real story) with 65/79 rows
  realized, against (B)'s `[0]` with 14–19. The pre-fix app baseline (12/12 exact, zero landing lines)
  matches the record. Measured, the acceptance metric (`hops=0` cold) outranks the charter's letter, and
  #151 puts the call in front of her correctly. The departure is PROVISIONAL and not mine to rule.
- **The shipped resting anchors are kept** (page 0.08, edit `.center`). Where a landing puts a block is
  untouched: the aim is still the one unanimated `scrollTo(placementID, anchor:)`, and the residual is
  `ViewportCarry.topInset`'s own definition. The clamp arithmetic is right: `ReadNoteLandingArithmeticTests`
  covers home, both ends and the inset, and I re-derived `wanted = offset + blockTop − rest` against
  `ScrollGeometry`'s `contentOffset`/`containerSize`, with the face frame as the scroll container on both
  faces.
- **U0c composes; it is not fought.** The seed/select/`openingLanding` arm (`ReadModeView.swift:300–312`)
  is byte-unchanged. A first open sets no `paneTarget`/`pageTarget`, so nothing lands and nothing is
  watched (W1 Study: no signpost). A re-open's seed lands and is watched.
- **The teardown is safe.** `.onDisappear { landing.end() }` is on both faces, the authority's work item
  is `[weak self]` and cancelled, the aim closure captures only a `ScrollViewProxy` value, the box and the
  manifests are unobserved reference boxes (no state write per geometry report), and a de-realized row
  clears its `box.rows` entry.
- **P1/P3 hold.** Per scroll frame, only realized rows' EXISTING observers do new work (a dictionary write,
  a no-op-guarded learn, and one string compare). The face gains one scroll-geometry observer whose
  residual runs only while a landing is pending. The extents are taken once per id list, and an
  autosave-shaped re-delivery takes nothing (pinned). No autosave-rate work was added. P3 is unchanged:
  the columns realize what they realized before.
- **The signpost is content-free on both new surfaces.** `LandingSurface` stays a closed enum,
  `theReadSignpostCarriesNumbersOnly` is run against a real title and prose, and the surface-count pin
  moved 3 → 5 on its own "the next adds its case here" line. Every other landing pin is byte-unmodified.
- **The closing run is as claimed.** `18l-u1-closing1.log`: `✔ Test run with 210 tests in 37 suites
  passed`, `** TEST SUCCEEDED **`. The script's `-only-testing` list covers the Read surfaces, the landing
  family, the C4 oracle suites and the eleven Tutorial suites (`TutorialWalkTests.swift`).
- **Release compile paths were checked by reading.** Every U1 DEBUG-only symbol (`ReadLandingStory`, the
  story appends in both `rowMoved`s, `extentTakes`, the `rl` probe, the storyboard init) sits behind
  `#if DEBUG`, and `LandingAuthority.readNote(_:)` has both arms. I did not build Release; the closeout's
  install refresh is the first Release build of this diff.
- **Harness.** `read-landing`'s filter road, the AXRadioButton correction (`VIS_AX_MINX` is honoured by
  `vis-ax.swift:16–17`), and the signpost window (`t0`-relative, +3 s slack that cannot reach the
  previous step's line) are sound. The `readedit-click` AX-role fix is correct and was latent, as stated.
- **Scope honesty.** Zero `Sources/`/`Shared/`/`Sync/`/schema/mobile. KnownIssues owned no note-Read
  landing row, so none is left unresolved. The NOT DONE list (contents column, aim kind, §1.2
  non-reproduction) is accurate and each item is recorded (JC 2/5). MOBILE PARITY is drafted.

*(Reviewer's scratch, not committed: both pins as run, `ScratchReviewHoldClickTests` (MAJOR-1) and
`ScratchReviewStaleSeedTests` (MINOR-1), lived only in a `git archive` copy of `2eff1b27` in the session
scratchpad, on an in-memory store, with zero app instances before each run. Their shapes are stated in
full above, for the fix pass to write as real pins.)*
