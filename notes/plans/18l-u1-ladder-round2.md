# 18l U1 — ladder ROUND 2 (cold review, `opus-reviewer`, 2026-09-26)

**Diff under review:** the round-1 fix pass, `ef7859f4..7995ac9e` (10 commits; product code in
`ReadEditPane.swift`, `ReadModeView.swift`, `ReadNoteLanding.swift`, `Surface/LandingAuthority.swift`;
pins in `ReadNoteLandingTests.swift` / `ReadNoteHeightsTests.swift`; the harness in
`Tools/VisualWalk/helpers/vis-foreign.swift` + its README; the rest record-keeping). Anchor: round 1's
findings, the orchestrator's arbitration and the implementer's fix table in
`notes/plans/18l-u1-ladder-round1.md`. Prompt: `notes/REVIEW_PROMPT.md`, run verbatim. Read-only
review; this file is its only repo write.

**STATUS: COMPLETE.** All six round-1 findings are VERIFIED-FIXED. Round 1's NIT-2 was fixed as
worded, but the limit it states is unmeasured (NEW NIT-3). New findings: 0 BLOCKER · 0 MAJOR ·
0 MINOR · 5 NIT, so **no round 3 is earned**. The hard boundary held: no seam body was touched.

## SEAM CALL

**The hard boundary held, and round 2 is correctly Opus.** `git diff --name-only ef7859f4 7995ac9e` lists
no `EditorTextView`, `PaneSurface`/`PaneSurfaceView`/`PaneTextView`, `PaneTextAuthority`,
`EditorViewModel`, `BlockRangeIndex`, `JumpPrimitive`, `Sources/`, `Sync/` or schema file. The one
pane-adjacent change is the BODY of the `onEdit` closure `ReadEditPane` already passed to
`PaneSurfaceView` (`ReadEditPane.swift:296–301`, `onHerEdit()` prepended); the pane's signature, its
arguments and `PaneSurface.swift` are byte-unchanged. No default changed its meaning: both resting
anchors are untouched, `LandingPolicy.seedsFromLastReport` defaults `true` (the three book adopters
byte-identical in behaviour), `userTookOver()`'s no-argument call sites (`ReadModeView.swift:830`,
`ReadEditPane.swift:108`, `ReadingFlowView.swift:549`, `BookView.swift:1148`, `BookIndexView.swift:944`)
keep their old story sentence, and the signpost's vocabulary is unchanged (`handedover` now also
covers a click or an edit — a meaning the round-1 finding asked for, not a silent drift).

## ROUND-1 FINDINGS — VERIFICATION

Commit order checked for every bug-class pin: the red commit carries ONLY the test file
(`9813b8bd`, `1f9e7141`, `30499936` — `git show --stat`), the fix follows it.

**MAJOR-1 — VERIFIED-FIXED.** Mechanism re-traced: `ReadTierClickTarget`'s `onTapGesture`
(`ReadTierClickPlace.swift:214`) → `ReadEditPane.blockRow`'s `onTap` → `landing.userTookOver(…)`
(`ReadEditPane.swift:150`) BEFORE `onSelect` (→ `select(_, scrollFace: false)`, which sets no target —
`ReadModeView.swift:432,465`) and `makeLive`; every read-tier row gets the same closure, so round 1's
case (a) (a click on another block above the target) is covered by the same line. The edit hand-over:
`PaneSurface.swift:1621–1632` (`textDidChange` → `onEdit`) is reached only through NSTextView's
user-edit path; the pane's two programmatic writes are `view.string = text` (`:1193`, `:1293`), which
post no `NSText.didChangeNotification`, and the go-live caret is a selection, not an edit — so the
watch still covers the blur reflow and the click-through's height convergence, as round 1 specified
(the typing pin's own story shows the click-through landing still pending until her keystroke:
`residual=-105 … residual=0 … DONE: her edit in the live pane`). The pane's own Return is content
(`PaneSurface.swift:450–456`, `super.insertNewline` → `textDidChange`), so ⏎ hands over too.
Per-keystroke cost: one `isPending` guard (`LandingAuthority.swift:574`).
**Red-on-old reproduced by this review** (the table's cited red log no longer holds that run — NEW
NIT-1): a `git archive` of `9813b8bd` in the session scratchpad, `-only-testing:VariorumTests/ReadNoteLandingTests`,
zero app instances: `click at +0.15 s: after the swap top=273.5 h=229.0; 3 s later top=278.5` · story
`target residual=-5 hops=0 | HOP 1 at 620 ms (top was -5.0) | … DONE: settled at top=0.0 after 1 hops` —
and `+0.45 s`: the same 273.5 → 278.5, `HOP 1 at 944 ms (top was -5.0)`; `✘ … (abs(settled.minY -
afterSwap.minY) → 5.0) <= 1` for both cases, the four older tests green. Green on the fixed tree located
in `18l-u1-r1fix-closing.log` (both cases 273.5 → 273.5, `DONE: her click in the pane`). The typing pin
(case (b)) was added with the fix; its revert `18l-u1-R-M1b.log` is located and RED
(`278.5 → 261.5`, `HOP 1 at 418 ms (top was 17.0)`), which is the pre-fix behaviour for that road (the
click-through never passes through `onTap`).

**MINOR-1 — VERIFIED-FIXED; option (b) accepted.** `LandingAuthority.land` now reads
`lastTop = policy.seedsFromLastReport ? tops[anchorID] : nil` (`:523`), false only for `.readNote` /
`.readNoteEdit` (`:229,238`). The face still covers the case `tops` exists for (a landing on the block the
page is ALREADY at): both `land`s call `landing.noteTop(placementID, residual)` from `box.residual`
right after `landing.land` (`ReadEditPane.swift:214`, `ReadModeView.swift:889`), and `box.rows` is
fresh while a row is realized (every geometry change writes it) and cleared on `onDisappear`. Before the
fix `tops` was only ever written for the pending target on these faces (`rowMoved` and the scroll
observer both guard on `landing.anchor`), so nothing else is lost. Red/green located:
`18l-u1-M1-red.log` (really `m1` — the same file; see NIT-1) = `X DONE: settled at top=0.1 after 0
hops`, 4 issues; `18l-u1-M1-green.log` = `HOP 1 at 261 ms (unreported) | HOP 2 … | HOP 3 …`, green.
*On the implementer's reasoning:* the (b)-over-(a) case rests correctly on "the authority's memory is
the only stale source, and (a) would depend on SwiftUI delivering `onDisappear` for every
de-realization". Its second clause ("a row that stays realized off screen keeps its old `tops` entry
even with (a)") is true of the entry but harmless — a still-realized row is re-seeded by the face's
`noteTop` a line after `land`, which overwrites the stale `lastTop`. The choice stands on the first
clause alone; it is also the only option that makes round 1's pin authority-level as written.

**MINOR-2 — VERIFIED-FIXED.** `ReadLandingStory.trace = []` at both mounts
(`ReadNoteLandingTests.swift:92,174`); `lastStory(_:)` filters on the placement id (`:209–212`), and
`expectWatched` requires that id to exist (`:289–291`). The round-1 check is located:
`18l-u1-R-page.log` — the page face alone unwatched reds exactly the two page tests (3 issues each),
both edit tests and the typing pin green. Residual checked: the other Read suites land on different
placements (`ReadLandingTests.landingIndex = 199` ⇒ `…0258`, not `…025B`), and the closing log runs
the suites one after another.

**MINOR-3 — VERIFIED-FIXED as option (a); the choice is reasonable.** Leading traced against the view
trees: edit — `ScrollView { LazyVStack(spacing: 2)….padding(.vertical, 26) }`, nothing else above
row 0 (`ReadEditPane.swift:66–86`); page — `.padding(.vertical, 28)` room ⊃ `.padding(.vertical, 46)`
paper ⊃ `LazyVStack(spacing: 14×scale) { ReadPageHeader, rows… }` (`ReadModeView.swift:767–806`), so
row 0's content-space top is `28 + 46 + header + 14×scale`, exactly `land`'s sum (`:884`); the page's
`metrics.rowSpacing = 14×scale` (`ReadNoteLanding.swift:276`) agrees. The header observer measures
`size.height` only, so it fires on a height change, never per scroll frame (P1). Red/green located:
`18l-u1-m3-red.log` `offset=0` vs drawn `26.0` / `153.0`; `18l-u1-m3-green.log` `offset=26` / `153`
vs `26.0` / `153.0`. The named residue (a landing issued before the header's first report) is honest;
at mount the header is realized because the page starts at its top. Option (a) over (b) is defensible:
#151's alternatives (b)/(c) need the manifest, and `derived=` is useful now. Two small residues are
NEW NIT-2 and NIT-4 below.

**NIT-1 (round 1) — VERIFIED-FIXED.** The test now reads both sides (`Queries.blockExtents` over the
store vs `ReadNoteHeightModel.extent` over `Queries.blockTOC`) on a seeded note covering a
multi-paragraph block, a blank take, non-BMP letters, a ZWJ family and a take with no trailing
newline. Equality compares `containerID`/`blockID`/`characters`/`newlines`, so a mis-ordered or
mis-counted side reds; `String.count` would count the family as 1 against SQL's 5.

**NIT-2 (round 1) — FIXED as worded; its stated limit is unmeasured (NEW NIT-3).** The README carries
the carve-out and its limit (`Tools/VisualWalk/README.md:82–88`), and the helper narrows only while
every other layer ≥ 1 Notification Center window is full-screen or inside the column
(`vis-foreign.swift:37–45`).

## NEW FINDINGS (severity-ranked)

**0 BLOCKER · 0 MAJOR · 0 MINOR · 5 NIT.** No new BLOCKER or MAJOR, so by the ladder rule no round 3
is earned.

### NIT-1 · `notes/plans/18l-u1-ladder-round1.md:262–263` (the fix table's evidence column) · MAJOR-1's red log was overwritten by MINOR-1's, because the two names differ only in case

The table cites `18l-u1-M1-red.log` / `18l-u1-M1-green.log` for MAJOR-1 and `18l-u1-m1-red.log` /
`18l-u1-m1-green.log` for MINOR-1. On this machine's case-insensitive APFS those are ONE pair of files
(`App/Variorum/DerivedData/` lists only `18l-u1-M1-red.log` and `18l-u1-M1-green.log`, plus
`…-M1-green2.log`). Today `18l-u1-M1-red.log` (mtime 18:02) holds only MINOR-1's red run
(`aStaleSeedCannotFakeASettle` ✘ 4 issues, 7 tests in 1 suite, no `[18l U1 MAJOR-1]` line), and
`18l-u1-M1-green.log` (18:05) holds MINOR-1's green run. MAJOR-1's red run is gone from disk. Its green
survives in `18l-u1-M1-green2.log` (17:56), which the table does not cite. So the table's load-bearing
claim "RED `9813b8bd`: 273.5 → 278.5 (5.0 pt)" pointed at a file that no longer proves it. **The claim is
true.** This review reproduced it independently (MAJOR-1 above: 5.0 pt in both cases, `HOP 1 … (top was
-5.0)`), so nothing is owed on the code. **Fix:** correct the two citations. MAJOR-1's green is
`18l-u1-M1-green2.log`, and its red is this review's reproduction, recorded here. Never name two
evidence logs by case alone. (Record-keeping; no pin applies.)

### NIT-2 · `Surface/LandingAuthority.swift:325–328` · The new doc sentence claims more for `total` than is true

It says that on note Read, "`offset` and `total` are the manifest's MODEL of that column: its own
geometry where `exact=1`." That holds for `offset`. It does not hold for `total`, for two reasons.
First, `BookHeightManifest.totalHeight` is `last.offset + last.height`, "trailing gap excluded"
(`BookHeightManifest.swift:168–172`). With the new `leading` it therefore includes the top chrome but
still leaves out the edit column's bottom 26, the page's bottom 46 + 28, and the page's `· · ·` footer
row (`ReadModeView.swift:788–792`, `.padding(.vertical, 30)` around a serif line). Second, `exact=1`
speaks only of the rows ABOVE the target (`isExactAbove`, `:185–188`), so rows below can still be
arithmetic. **Fix:** in the sentence, say that `offset` is the column's geometry where `exact=1`, and
that `total` is the rows' extent (top chrome in, bottom chrome and footer out). Doc-only.

### NIT-3 · `Tools/VisualWalk/README.md:82–88` + `helpers/vis-foreign.swift:37–45` · The carve-out's stated LIMIT is an unmeasured premise (SPECULATIVE)

The README says the narrowing was "measured", and the banner case was: the fix table's `vis-foreign 0`
→ the column, `(300,332)` → not covered. The limit is a different claim: "an open NC panel … raises
windows outside the column, and then the whole screen stays covered". Nothing in the record shows a
run with the panel open. That limit holds only if the panel is its own non-full-screen window. If
macOS 27 draws the panel inside a full-screen Notification Center window, as it draws banners,
`othersInside` stays true (the `fullScreen ||` arm exempts every full-screen NC window) and the column
rule still applies with the panel open. The panel's full-height strip below 480 pt would then count as
uncovered.

What I measured, read-only, at rest: one full-screen NC window at layer 21 (`0 0 1728 1117`) and one NC
desktop-widget window at a negative layer, which the `layer >= 1` guard excludes. So the narrowing
applies right now, with no banner showing. I could not open the panel: that is a GUI act on her
machine. **Fix:** either one measurement with the panel open the next time she is at the machine (her
GUI step), or README wording that calls the limit unmeasured. A walk click that fails to reach the app
still ERRORs rather than passing, so the exposure is a click landing on a widget, not a false PASS.

### NIT-4 · `notes/QUESTIONS.md` #151 · MINOR-3 is marked PROVISIONAL "until #151 rules", but #151 does not mention it

The U1 record (`phase-18l-navigation-feel.md`, ROUND-1 FIX PASS) and the fix table both mark MINOR-3's
option (a) PROVISIONAL until #151 is ruled. #151's text, including its "Where it lives" line, says
nothing about the signpost's `offset=`/`total=` meaning on note Read. When she rules #151, nothing will
prompt anyone to revisit the choice between a model estimate and the honest unknowns. **Fix:** add one
clause to #151, e.g. "the `ReadNote*` signpost's `offset`/`total` print the manifest's model (option
(a)); a ruling of (a) may revisit printing `offset=-1` instead." Record-keeping.

### NIT-5 · `ReadNoteLandingTests.swift:437–470` (`aClickIntoTheLandedBlockDuringTheHoldDoesNotMoveThePage`, the 0.45 s case) · The case clicks only about 300 ms inside the hold, so a slow run can red the fixed tree spuriously

The delay is measured from the target's first FRAME, not from its `LAND`. On the pre-fix tree the
0.45 s case's correction ran at `HOP 1 at 944 ms`, one quiet interval (0.25 s) after the click's swap
report. That puts the click about 650–700 ms after `LAND`, against a one-second hold. If a loaded
machine pushes the click past the hold's done-look, the landing files `DONE: settled` first. On the
fixed tree, the story assertion ("…because her click ENDED the landing") then reds spuriously. On the
old tree the same slip would turn that case green, though the 0.15 s case keeps the pin red. No flake is
observed: all five fixed-tree runs on disk (`M1-green2`, `m2-green`, `m3-green`, `R-page`,
`r1fix-closing`) pass both cases with `DONE: her click in the pane`. **Fix (optional):** time the click from the target's `… LAND` line in
`ReadLandingStory.trace`, or derive the late case from `LandingPolicy.readNoteEdit.minimumHold` with a
stated margin. This is test hygiene, and it is not bug-class.

## CLEAN BILL (load-bearing things checked and found solid)

- **Pin-before-fix held for every bug-class finding.** `9813b8bd`, `1f9e7141` and `30499936` touch
  only test files, and each precedes its fix (`5a7e5ce5`, `901392d9`, `7678a362`). MAJOR-1's red was
  reproduced by this review. MINOR-1's and MINOR-3's red and green runs, and MINOR-2's check, are on
  disk and read. The closing run `18l-u1-r1fix-closing.log` (18:30, on `66dcf17d`; nothing but notes
  changed after it) reads `✔ Test run with 214 tests in 37 suites passed`, `** TEST SUCCEEDED **`, and
  includes all five new or rewritten functions (7 cases).
- **The hand-over does not over-reach.** It fires on her tap (`onTapGesture`, never a drag or a
  programmatic call) and on her `textDidChange`. It does not fire on `model.blur()`, on the column
  click (which starts a NEW landing through `select(_, scrollFace: true)` → `land`, and that resets
  the authority), on the go-live caret (a selection), on `view.string =` re-deliveries, or on the
  page-face click-through (that face's landing ends silently through `onDisappear → end()`, as before).
  `onSelect` from the pane sets no landing target, so nothing re-lands after the hand-over.
- **The book adopters are untouched.** The Outline, the flow and the Index take the new field's
  default (`true`) and the old `userTookOver()` sentence. `LandingAuthorityTests` and
  `LandingSignpostTests` are byte-unmodified and green in the closing run. The signpost stays
  content-free, since `act` reaches only the DEBUG `why:` autoclosure.
- **Release compile paths, by reading.** The new product code uses no DEBUG-only symbol outside
  `#if DEBUG`. `userTookOver(_:)`'s `act` is consumed only by the `@autoclosure` that the DEBUG branch
  evaluates. The storyboard-taking `LandingAuthority` init used by the new arithmetic pin sits inside
  that pin's `#if DEBUG`.
- **P1/P3.** The added per-frame work is none: the header observer keys on `size.height`, and
  `onHerEdit` is one `isPending` guard per keystroke. The manifest is still built at a landing only.
  The columns realize exactly what they realized before, since the `blockRow` factoring keeps the
  `ForEach` identity (the placement id) and every argument.
- **The MINOR-3 arithmetic is the view tree's own.** The edit face is 26. The page face is
  28 + 46 + the measured header + 14×scale, and `rowSpacing = 14×scale` agrees. The first-block pin
  compares against the AppKit scroll view's real `bounds.origin.y`, so it measures content space, not
  viewport space.
- **Scope and records.** No KnownIssues row was owned by this pass. The U1 record's ROUND-1 FIX PASS
  note, the fix table and the commit subjects agree, apart from the log citations in NIT-1. Round 1's
  scratch pins were re-expressed as real tests with the shapes round 1 stated.

*(Reviewer's scratch, not committed: the `git archive` of `9813b8bd` and its build products live only
in this session's scratchpad. The MAJOR-1 red reproduction ran there against an in-memory store, with
zero Variorum instances running before the run. A read-only listing of the on-screen Notification
Center windows (NIT-3) ran as a throwaway script in the same scratchpad.)*
