# VX-724 — The book's position line moves to a bottom bar (+ the 1.0 release)

**STATUS: OPEN — kickoff 2026-11-01.** Branch `vx-724-book-position-bottom-bar`, worktree `~/dev/variorum-vx-724`, the Pro. Architect shape (her word: "/architect-phase discipline"); Fable orchestrates, Opus implements, Opus cold-reviews (no editor seam, no `Sync/`, no custody, no default's-meaning content). The 1.0 release rides this ticket and runs AFTER the merge, at the standing release road.

## FOR A LATER READER

*(Written at closeout.)*

## HER ASK (2026-11-01, verbatim)

> "on a book, this part that says where you are in the book - I think it's ugly having it at the top of the book, looks crowded and not good. please just move it to the bottom bar of the book view, instead of the top. also, I would change it so that the information that isn't changing is to the right, separated. like 13 chapters, 13 notes, can probably be at the right. i know i asked for this feature but honestly i'm struggling with how I find it ugly. I don't really know where else it would go though. so yeah, I want that change made."

Same message, the release word: "I want to put the version 1.0 out into the world + on the website … I'll actually fix the wording notes myself for release once you're done with this page and then you'll put it straight on the stargazing.tech website (and this is version 1.0)."

**Ruling recorded:** R-724-1 — the book's nav/position info moves from above the page to a bottom bar; the static counts sit at the bar's RIGHT, separated; the changing position info is the other, leading half. This supersedes the AT-THE-TOP placement, which was her VX-562 beta ask's ("the navigation info … stays fixed at the top while scrolling" — the FIXED-while-scrolling half survives; the at-the-top half is hers to move and she moved it) and SurfaceContracts' "PINNED above the page" line. *(Corrected at ladder r1 NIT-1: the kickoff text attributed "at the top" to P-562-3 — wrongly; P-562-3 is the no-duplication + no-at-rest-suppression provisional and SURVIVES WHOLE.)* R-724-1 also AMENDS the reach of 13c's A6 ruling ("no bottom chrome" on Outline): A6 removed the jump slider and progress bar and its investigate-first clause targets that scrub/progress chrome, which stays banned; a sanctioned position bar now stands at the page's foot (ladder r1 BLOCKER's supersession record). The one-wording-brain and one-total laws (VX-562 r1 finding 3, `NoteBoxCopy.viewedLine`) are untouched.

## THE SURFACE TODAY (read these, in this order)

- `App/Variorum/Variorum/Features/BookView/BookOutlineViewed.swift` — the whole file (the viewed-pair brain, `positionLine`, `pinLine`, `NoteTotal`).
- `App/Variorum/Variorum/Features/BookView/BookView.swift` — the `.outline` arm of the mode switch (~line 321–345: the `VStack` of `BookArchivedLine` / `OutlinePinnedLine` / `outlineBody`, and the `pageFootReceipt` overlay on that stack); `OutlinePinnedLine` (~line 3344–3430, including the DEBUG oracle calls); `BookViewCopy.metaLine` + `outlinePinLine` (~line 4187–4230); the oracle stores `BookOutlineGeometry.outlinePinLines` / `outlinePinFrames` / `recordOutlinePin(Frame)` (~line 2904/2971).
- `App/Variorum/Variorum/Core/Views/NoteBox.swift` — `NoteBoxCopy.viewedLine` (~line 196; read-only context, the shared wording brain — do not change it).
- `App/Variorum/VariorumTests/BookOutlineViewedTests.swift` — the pure pins on `pinLine`/`positionLine`.
- `App/Variorum/VariorumTests/BookOutlineLandingTests.swift` — the mounted-window pins on `outlinePinLines`/`outlinePinFrames` (~lines 1395–1960).
- `notes/SurfaceContracts.md`, "The Outline follows the page (VX-562)" paragraph — the contract line that changes at closeout (the orchestrator lands the canon delta at merge; you do NOT touch SurfaceContracts).

## THE DESIGN (build exactly this)

1. **The line leaves the top.** `OutlinePinnedLine` stops rendering above the page. In the `.outline` arm the stack becomes: `BookArchivedLine` · `outlineBody` · the new **bottom bar**. The bar is a SIBLING BELOW the page's scroll, never inside it — the same geometry argument as the old top placement (landings measure anchor tops in the scroll's own space; chrome outside the scroll moves nothing).
2. **The bar's two halves.** One `HStack`: LEADING, the position words while a pair is viewed — `BookOutlineViewed.positionLine` ("note 5 of 13 · a scandal in bohemia"), empty at rest; a `Spacer`; TRAILING, the static counts — `BookViewCopy.metaLine` ("book · 13 chapters · 13 notes", plus the set-aside piece when present). Both halves from the ONE `NoteTotal` (the r1-finding-3 law: the two halves can never say two totals).
3. **Styling.** The same voice as today: `tokens.small`, `tokens.muted`, `lineLimit(1)`, tail truncation, `.padding(.horizontal, 20)`, `.padding(.vertical, 6)`. The hairline moves to the bar's TOP edge (the page's bottom edge, drawn — the same `tokens.line` 1-pt rectangle). The bar runs the pane's width (a bottom bar, not a prose-column-caged line) — PROVISIONAL P-724-1. Under width pressure the POSITION half wins (`layoutPriority(1)`) and the counts truncate — the position is the half she reads while scrolling — PROVISIONAL P-724-2. Neither half ever wraps (P-8).
4. **The receipt overlay.** Today `pageFootReceipt` overlays `bottomTrailing` on the whole outline stack; with a bar there it would sit on the counts. Move that overlay onto `outlineBody` alone, so the receipt floats at the page's foot, above the bar. No change to `BookNoteBox.quietReceiptHome` — PROVISIONAL P-724-3.
5. **Copy plumbing.** `BookViewCopy.outlinePinLine` (the joiner) loses its render consumer. Keep `pinLine`/`outlinePinLine` ONLY if the oracle still wants one joined sentence (your call, stated in LIVE STATUS); otherwise retire them and their pins deliberately. `positionLine` and `metaLine` stay as-is — they are the two halves.
6. **The DEBUG oracle.** Keep `recordOutlinePin` + `recordOutlinePinFrame` recording the BAR's content and frame. The recorded line should capture both halves unambiguously (e.g. record the two halves joined in the bar's reading order, position first — your call, stated). Update `BookOutlineLandingTests`' expected strings to the new shape; the "pin stands still while the page scrolls" frame assertion must survive (a bottom bar outside the scroll stands just as still). The at-rest assertion ("counts alone") survives with the counts in the trailing half.
7. **Nothing else moves.** The title block keeps title + expand/collapse doors exactly as-is (the counts do NOT return to it — P-562-3's no-duplication half stands). The masthead, navigator, Index/Read/spread arms, `NoteBoxCopy`, the follower/adoption machinery: untouched. Outline remains the only mode drawing this line, exactly as today.

## SCOPE FENCES

- No `Sources/VariorumCore/` changes. No editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier). No `Sync/`, no custody.
- No capability-registry change (the bar has no doors).
- No new settings, no new copy brains — reuse `positionLine`/`metaLine`.
- SurfaceContracts/AppSpec are the orchestrator's at closeout, never yours.

## TESTS & EVIDENCE (the acceptance unit)

ONE acceptance unit: the bar, verified by its kind — the updated mounted-window pins green plus the orchestrator's hands-on screenshot walk.

- `swift build` is not enough — this is app-target work: `xcodebuild -scheme Variorum -destination 'platform=macOS' test -only-testing:VariorumTests/BookOutlineViewedTests -only-testing:VariorumTests/BookOutlineLandingTests` **under a HELD `Tools/stage` claim** (the suites mount windows and share the dev-store defaults). Confirm the "Test run with N tests" line.
- The changed pins are the red-on-old evidence for the moved shape: the OLD expected strings/placement fail on the new code and vice versa — note in LIVE STATUS which pins changed and why each new expectation is the design above.
- A broader sanity pass is the orchestrator's at the ladder; you run the two suites above plus any suite your diff's types appear in (grep the tests for `OutlinePinnedLine`, `outlinePinLine`, `metaLine` consumers).

## ENVIRONMENT TRAPS (the standing core)

Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by path; treat real-store instances by STORE — never quit/kill one; no Release builds or `/Applications` refreshes. Mac tests from `App/Variorum/`, suite-level `-only-testing` only. NEVER add a custom build configuration. zsh `pipestatus`. Never `git checkout` over uncommitted work. Commit per piece, push after every commit, LIVE STATUS from the first commit (`notes/SessionResiliencyProtocol.md` binds). Work ONLY in `~/dev/variorum-vx-724`. The stage claim: `Tools/stage claim vx-724 "<reason>"` — check `Tools/stage status` first; release it when the suites finish.

## LIVE STATUS

**NOT done by the implementer: the hands-on screenshot walk** (the orchestrator's, per TESTS & EVIDENCE); no
SurfaceContracts/AppSpec edit (the orchestrator's at closeout).

Implementer: Opus (opus-implementer), 2026-11-01, worktree `~/dev/variorum-vx-724`.

| Piece | State |
|---|---|
| 0. Preflight read (CLAUDE.md + canon, this brief, SessionResiliencyProtocol, SurfaceContracts' VX-562 paragraph, the listed sources and both suites) | DONE |
| 1. The bar (BookView `.outline` arm, `OutlinePinnedLine` → `OutlineBottomBar`, receipt overlay onto `outlineBody`, oracle records the bar) | DONE (`ab9eb595f`) — compiles (`TEST BUILD SUCCEEDED`) |
| 2. The pins (`BookOutlineViewedTests`, `BookOutlineLandingTests`) | DONE (`ab9eb595f`, the placement pin's coordinate fix `fbe571fcc`) |
| 3. The two suites under a held stage claim | GREEN at `fbe571fcc`: `✔ Test run with 58 tests in 2 suites passed after 64.699 seconds with 4 warnings.` (0 skipped; the 4 warnings are the host app's swift-dependencies `Date.swift:37` unimplemented-date notices, «unknown» test, ambient). Run 1 (`ab9eb595f`): 58 tests, 1 issue — the placement pin's first coordinate conversion (fixed, see piece 2). |
| 3b. Placement pin's teeth — behavioral revert | DONE — **no revert in flight.** `OutlineBottomBar` moved back ABOVE `outlineBody` (the old placement), landing suite alone: `✘ Test run with 27 tests in 1 suite failed … with 6 issues (including 4 warnings)` — exactly the two VX-724 placement expectations red (`VX-724 BAR: bar=(191.0, 32.0, 1009.0, 26.0) page bottom=792.0 window height=792.0` — the bar just under the title bar, the page running to the window's foot), every other expectation green. Restored by `git checkout --` (tree clean). |
| 3c. Neighbouring consumers (the grep: `metaLine` in `VocabularySweepTests`; `BookOutlineViewed` in `BookNavigatorFollowTests`' two suites) | GREEN: `✔ Test run with 23 tests in 3 suites passed after 0.180 seconds.` (`VocabularySweepTests`, `BookNavigatorFollowTests`, `BookNavigatorViewedPairTests`). No other test or app file names `OutlinePinnedLine` / `outlinePinLine` / `pinLine` (grep clean; mobile's `MobileBookDetails.metaLine` is an unrelated symbol). |
| 3d. Final run, restored tree (`9a4349210`) | GREEN: `✔ Test run with 58 tests in 2 suites passed after 64.462 seconds with 4 warnings.` · `VX-724 BAR: bar=(191.0, 766.0, 1009.0, 26.0) page bottom=766.0 window height=792.0`. Stage released (`STAGE FREE`), no Variorum instance running. After it, ONE doc-comment-only edit (`OutlineBottomBar`'s header quotes her beta ask whole instead of with an ellipsis): `** TEST BUILD SUCCEEDED **`, no suite re-run (no code changed). |
| 4. Self-assessment | DONE (below) |

**The implementer's calls (brief points 5 and 6 left them to me):**

- **C-1 (point 5) — `pinLine` and `outlinePinLine` RETIRE.** The oracle no longer wants one joined sentence: a joined
  string cannot say where the position half ends and the counts half begins (both halves join their own pieces with
  " · "), so the bar's two halves become ONE pure value, `BookOutlineViewed.Bar { position, counts }`, from ONE pure
  composer `BookOutlineViewed.bar(…)` that takes `pinLine`'s exact inputs and feeds BOTH halves from the ONE
  `NoteTotal` (the r1-finding-3 law, unchanged and still pinned). It mints no words: `position` is
  `positionLine` (empty at rest), `counts` is `metaLine`, both as-is. The joiner `BookViewCopy.outlinePinLine` has no
  consumer left and is deleted; its pins move to the `Bar` shape deliberately (piece 2).
- **C-2 (point 6) — the oracle records the `Bar` value itself**, the very value the bar renders (leading ←
  `position`, trailing ← `counts`), so a pin compares both halves by name and can never confuse them. The store keeps
  its names (`recordOutlinePin` / `outlinePinLines`, `recordOutlinePinFrame` / `outlinePinFrames` — still the line
  that stays put while the page scrolls); its value type is `Bar`; the frame is the bar's.
- **C-3 — one placement assertion added** to the mounted pin that already reads the bar's frame
  (`theNavigatorFollowsWhatThePageShowsNeverTheCaret`): the bar stands BELOW the page's scroll view. This is the
  moved placement itself, so it is the red-on-old pin for "the line leaves the top" (on the old tree the pinned
  line's frame sat above the scroll). Plus its sibling: the bar is the pane's foot (its maxY is the window's). Both
  read the bar's `.global` frame against the page's AppKit rectangle flipped by the WINDOW frame's height — run 1
  measured that `.global` in this host is the window's top-left space with the title bar included (the bar's maxY
  792 = the window frame; the content view is 760), so the first conversion (by the content height) was 32 pt off.

**The changed pins, and why each new expectation is the design** (red-on-old: the new expectations are a `Bar`
value the old tree does not have — the old one-sentence, counts-first shape cannot satisfy them, and the old
strings cannot be compared with the new oracle; the placement pin was shown red by behavioral revert, 3b):

| Pin | Old expectation | New expectation | Why it is the design |
|---|---|---|---|
| `BookOutlineViewedTests.atTheBottomTheLastNoteIsViewedAndNinePointsUpTheTopEdgeAnswers` (2 `pin(...)` lines) | `"book · 4 chapters · 12 notes · note 12 of 12 · chapter four"` (and note 9) | `Bar(position: "note 12 of 12 · chapter four", counts: "book · 4 chapters · 12 notes")` (and note 9) | Design 2: position leading, counts trailing — two halves, not one counts-first sentence. The clamp logic it pins is untouched. |
| `BookOutlineViewedTests.thePinnedLineSaysOneTotalForBothHalves` (3 lines; red-on-old recipe re-pointed from `pinLine` to `bar`) | three joined sentences, counts first | the same three cases as `Bar`s; at rest `position: ""` | Design 2's last sentence: both halves from the ONE `NoteTotal` — the r1-finding-3 law kept ("300+" in both halves). |
| `BookOutlineLandingTests.theNavigatorFollowsWhatThePageShowsNeverTheCaret` — the at-rest line | `== counts` | `== Bar(position: "", counts: counts)` | Design 6: "counts alone" survives, the counts in the trailing half. |
| same test — `targetLine` | `counts + " · note 11 of 24 · chapter 3"` | `Bar(position: "note 11 of 24 · chapter 3", counts: counts)` | Design 2. |
| same test — NEW: the bar below the page, the pane's foot | — (the old line was above the page) | `bar.minY ≥ page bottom`, `bar.maxY = window height` | Design 1: the line leaves the top; the bar is a sibling BELOW the scroll. Red on the old placement (3b). |
| same test — "the pinned line stands still while the page scrolls" (frame) | unchanged | unchanged (passes) | Design 6: a bottom bar outside the scroll stands just as still. |
| `aLandingHoldsItsTargetFromTheClickUntilItEnds` · `aLandingOnTheLastScreenfulEndsOnItsTargetNeverTheTopRow` · `herScrollToTheVeryEndClampsToTheLastNoteAndNinePointsUpTheTopEdgeAnswers` (`expectedLine` + `aboveLine`, now `BookOutlineViewed.bar(...)`) · `aNavigatorClickOnAShortNoteInTheLastScreenfulEndsOnThatNote` | counts-first sentences | `Bar(position: "note N of 30 · chapter K", counts: "book · 10 chapters · 30 notes")` | Design 2 + 6: the follower/adoption/clamp assertions unchanged; only the recorded shape moves. |

**Self-assessment (the implementer's).** Built exactly THE DESIGN 1–7: the `.outline` stack is `BookArchivedLine` ·
`outlineBody` (carrying the receipt overlay — point 4) · `OutlineBottomBar`; the bar is one `HStack` of the
position (`layoutPriority(1)`, P-724-2) · `Spacer(minLength: 16)` · the counts, both `tokens.small` / `tokens.muted`
/ `lineLimit(1)` / tail truncation, `.padding(.horizontal, 20)` `.padding(.vertical, 6)`, the `tokens.line` 1-pt
hairline on its TOP edge, the pane's width (no `proseColumn` cap — P-724-1); the oracle records the bar's `Bar` value
and frame (C-1, C-2). Untouched: the title block (no counts return), masthead, navigator, Index/Read/spread arms,
`NoteBoxCopy`, `BookNoteBox.quietReceiptHome`, the follower/adoption machinery, `Sources/`, the editor seam, the
capability registry. **Deviations: none.** The only number I chose is the 16-pt minimum gap between the halves
("separated" — her word; the brief names no figure): the halves never touch however narrow the pane. **PENDING:**
the hands-on screenshot walk (the orchestrator's); the canon delta (the orchestrator's at closeout — SurfaceContracts'
"PINNED above the page" sentence and its joined-sentence description now read wrong against the build). No
QUESTIONS entry: nothing the brief left open was product behavior.

## LADDER

### Round 1 — cold reviewer: Opus (opus-reviewer), 2026-11-01. Findings with the orchestrator's dispositions (same-model ladder: the orchestrator arbitrates against the spec).

**F-1 [BLOCKER] — `OutlineWritingSurfaceTests.outlineCarriesNoBottomChrome` (BookViewTests.swift:644) fails on the branch; the A6 collision was never recorded.** Reviewer's evidence: the suite run red — "the page runs to the window's bottom edge" off by 26.0 (the bar's height); 15 other Outline-mounting suites green (59 tests), this the only red. The pin guards 13c's A6 ruling ("no bottom chrome"), whose target was the jump slider / progress bar — her R-724-1 explicitly orders a bottom bar, so the PIN is stale, not the code; but the supersession must be recorded and the pin deliberately rescoped, and the stale "no bottom chrome (A6)" comment at BookView.swift:~2190 fixed. **Disposition: CONFIRMED — fix in round 1's fix pass** (a deliberate shape change, the changed-pins class, no red-on-old owed for the rescope itself): rescope the test to keep A6's teeth (no scrub/progress chrome; the page's scroll insets clean) and pin the NEW truth — the page runs to the BAR's top edge and the bar's bottom is the pane's foot, the bar the only chrome below the page; MOVE the placement assertion out of `theNavigatorFollowsWhatThePageShowsNeverTheCaret` into this rescoped pin (F-4 folded in — one placement truth beside the ruling it amends); fix the :2190 comment; the supersession line is recorded above (R-724-1's A6 amendment).

**F-2 [MINOR] — the Outline is now the only book bottom bar not hosting the quiet receipt** (SpreadBookView and PagedReadView both host `QuietReceiptLine` at their bars' trailing end; SurfaceContracts' receipt rule says "at the bottom bar's trailing end"; P-724-3 keeps the receipt floating on the page and `quietReceiptHome == .pageFoot`). **Disposition: RULED — R-724-2 (her answer at the 2026-11-01 sitting, the two options presented): "Floating above the bar (as built)."** The receipt keeps floating at the page's foot above the bar; the bar stays a two-piece line and `quietReceiptHome` stays `.pageFoot` for Outline; P-724-3 is no longer provisional. The Outline bar is a RECORDED exception to the receipts-at-the-bar's-trailing-end idiom — the canon delta at closeout says so in the receipt rule's line. No QUESTIONS entry owed.

**F-3 [MINOR] — the three PROVISIONALs carried one option each, no alternatives recorded.** **Disposition: CONFIRMED — fixed here** (the options now stand under each):
- **P-724-1 (the bar's width):** (a) the pane's width, a true bottom bar — BUILT (her words "bottom bar of the book view"); (b) the prose column's measure and left edge, as the old top line (quieter, but reads as a caption not a bar).
- **P-724-2 (width pressure):** (a) the position wins, the counts truncate — BUILT (the position is the half she reads while scrolling; the counts are static and recoverable); (b) the counts win, the position truncates (the counts are the half she asked to the right).
- **P-724-3 (the receipt):** (a) the receipt floats at the page's foot above the bar, `quietReceiptHome` untouched — BUILT (keeps the bar two-piece and calm); (b) the bar hosts `QuietReceiptLine` at its trailing end before the counts, `.outline` routed to `.modeBottomBar` (the Spread/Pages precedent and the receipt rule's letter). F-2 carries this to her.

**F-4 [MINOR] — the placement assertion lives inside a follower-named test.** **Disposition: CONFIRMED — folded into F-1's rescope** (one placement truth in the A6-successor pin).

**F-5 [NIT] — the record's R-724-1 line misattributed "at the top" to P-562-3.** **Disposition: CONFIRMED — corrected in place above** (P-562-3 survives whole).

**F-6 [NIT] — four names for one thing ("pinned line" / "pin" / "bar" / `outlinePinLines: [String: Bar]`).** **Disposition: RECORDED, deferred to next touch** — a Low Debt ticket at closeout triage (rename `outlineBars`/`recordOutlineBar` or re-word the doc comments); not worth a fix round; C-2's name-keeping was deliberate.

**F-7 [NIT] — two bottom-bar looks across the book's modes** (Outline: surface + hairline, 26 pt; Book/Read pages: `.bar` material, ~30 pt). **Disposition: ON THE WALK** — the orchestrator's screenshot pass looks at the mode-switch seam; surfaced to her with the screenshot; her call whether to harmonize (the brief dictated the Outline styling deliberately).

### Round 1 fix pass — brief

ONE fix, F-1 (+F-4 folded): in `App/Variorum/VariorumTests/BookViewTests.swift`, rescope `OutlineWritingSurfaceTests.outlineCarriesNoBottomChrome` as the disposition above states (keep every arm that still holds — read the test first; only the window-edge arm changes meaning); in `BookOutlineLandingTests.swift`, remove the placement assertion from `theNavigatorFollowsWhatThePageShowsNeverTheCaret` and let the rescoped pin carry it (same `.global`/window-frame conversion, already proven); fix the stale "no bottom chrome (A6)" comment at `BookView.swift:~2190` to name the sanctioned bar (R-724-1) with A6's scrub/progress ban intact. Evidence: the rescoped suite green on the branch (`-only-testing:VariorumTests/OutlineWritingSurfaceTests` + the landing suite, under a held stage claim); the rescoped pin is inherently red-on-old (the old tree has no bar below the page — and F-1's red run on the unfixed branch is the pin's bite shown live). No other finding needs code.

### Round 1 fix pass — LIVE STATUS

Implementer: Opus (opus-implementer), 2026-11-01, worktree `~/dev/variorum-vx-724`. (`b5b5e6b21`'s message says the
record's LIVE STATUS opened with it — it did not: the record edit collided with the orchestrator's `910a51298` and
landed here, with the next commit.)

| Piece | State |
|---|---|
| 0. Read the brief, the F-1/F-4 dispositions, the A6 pin whole, the follower pin, the two BookView A6 comments | DONE |
| 1. `BookViewTests` — `outlineCarriesNoBottomChrome` rescoped, renamed `outlinesOnlyBottomChromeIsThePositionBar` | DONE (`b5b5e6b21`), green |
| 2. `BookOutlineLandingTests` — the C-3 placement assertion removed from `theNavigatorFollowsWhatThePageShowsNeverTheCaret` | DONE (`e5876892f`), green |
| 3. `BookView.swift` — the stale A6 comments, comment-only | DONE (`f045ca22f`) |
| 4. The three suites under a held stage claim | GREEN at `a51abe1c0` (code = `f045ca22f`): `✔ Test run with 65 tests in 3 suites passed after 67.742 seconds with 4 warnings.` (0 skipped; the 4 warnings the ambient `Date.swift:37` unimplemented-date notices, «unknown» test) · `VX-724 BAR (A6 successor): bar=(191.0, 806.0, 909.0, 26.0) page bottom=806.0 window height=832.0 below page=26.0` |
| 4b. The rescoped pin's teeth — behavioral revert | DONE — **no revert in flight.** `OutlineBottomBar` moved back ABOVE `outlineBody` (the old placement), `OutlineWritingSurfaceTests` alone: `✘ Test run with 7 tests in 1 suite failed … with 7 issues (including 4 warnings)` — exactly the three new arms red (`below page=0.0` vs the bar's 26 pt; `bar=(191.0, 32.0, 909.0, 26.0) page bottom=832.0 window height=832.0`), the inset and progress arms and the suite's other six tests green. Restored by `git checkout --` (tree clean). |
| 4c. Final run, restored tree | GREEN: `✔ Test run with 65 tests in 3 suites passed after 67.535 seconds with 4 warnings.` Stage released (`STAGE FREE`), no Variorum instance running. |

**What changed, per piece:**

- **Piece 1 — the rescoped pin, arm by arm.** KEPT UNCHANGED (A6's teeth, judged on what each asserts): the
  `contentInsets.bottom == 0` arm over every scroll view (the restored `safeAreaInset` showed as a 54-pt bottom
  content inset — the bar is a sibling below the scroll, never an inset, so this arm still bites a restored scrub
  bar; its message re-worded "no bottom bar … nothing" → "no scrub chrome … no bottom inset", since a bar now
  stands) and the `NSProgressIndicator == 0` arm (verbatim). CHANGED MEANING (the only one): the window-edge arm
  becomes three — (a) in the hosting view's own space (the old arm's), the run below the page equals the bar's
  height (the bar is the only chrome below the page; flip-agnostic, the bar's height only, so it needs no
  coordinate conversion); (b) in `.global` (the conversion the landing suite proved), the page's bottom IS the bar's
  top edge, two-sided (the moved C-3 arm was one-sided, `≥`); (c) the bar's maxY is the window frame's height (the
  pane's foot, as moved). The pin now resets the oracle (`forgetOutlinePins`) and settles until the bar has
  reported. Renamed — "no bottom chrome" lies beside a sanctioned bar; the doc comment keeps A6's provenance whole
  and records R-724-1's amendment, the old name, and the bite; the suite's header bullet re-worded to match. No arm
  was ambiguous, so none is kept conservatively.
- **Piece 2.** The C-3 block (the `.global` conversion, the `VX-724 BAR` print, the two placement `#expect`s) left
  the follower pin; a three-line comment points at the rescoped pin. `pinAtRest` stays (the stands-still check reads
  it); the `Bar` strings and the stands-still frame check are untouched.
- **Piece 3 — comment-only, one beyond the brief's letter.** The ~2190 sentence names the sanctioned bar with A6's
  scrub/progress ban intact. Also the A6 block at ~2546 ("Outline ends as a clean vertical scroll + the navigator"),
  the same stale claim in the same file: it now adds the position bar, a sibling below the scroll, the ban
  standing. Comment-only, so no behavior change; say so if the next round would rather it reverted.

**Orchestrator's round-1 fix-pass acceptance (2026-11-01):** pieces 1–3 verified against the F-1 disposition line by line (the kept arms, the three-way rescope, the rename, the removed C-3 block, both A6 comments); the ~2546 comment edit beyond the brief's letter is SANCTIONED (comment-only, the same stale claim, the same class as the brief's step 3 — it stays). One orchestrator adjudication fix typed after the round (the loosened rule: mechanical, fully specified by R-724-2, comment-only, no design choice, not `Sync/`/custody/editor seam, read by the next round): the two "PROVISIONAL P-724-3" code comments (`BookView.swift` ~343, ~1073) now say "P-724-3, ruled R-724-2".

### Round 2 — fresh cold reviewer re-reviews the fixes

Cold reviewer: Opus (opus-reviewer), 2026-11-01. **No BLOCKER, no MAJOR ⇒ no round 3; the ladder ends here.** Every round-1 disposition verified HONORED (its clean bill names each); the green run reproduced under its own stage claim (41 tests in 3 suites; the bar's numbers byte-equal to the record's). Findings with dispositions:

**R2-F-1 [MINOR, SPECULATIVE on frequency] — the rescoped A6 pin reads a shared DEBUG-oracle key (`withBookWorld`'s `.incrementing` UUIDs repeat the reading id across ~15 Outline-mounting suites) and opens with an unconditional `forgetOutlinePins()` (a three-store `forgetAll`, `outlineScrollStore` included) — both against the `OutlineRoomTests` precedent (live UUIDs; key-scoped forgets).** Under today's serial scheme (`parallelizable = "NO"` since July) the suites cannot interleave and the reviewer could not make it red — no failing-on-old pin can exist, so by the hallucination guard this is HYGIENE, not a bug. **Disposition: DEFERRED to a Debt ticket at closeout** (key-scoped forget + a `uuid:` parameter on this pin's world), per the reviewer's own fold-into-next-touch offer. Recorded, not fixed blind.

**R2-F-2 [MINOR] — P-724-1 (the bar's width) and P-724-2 (which half wins under squeeze) are still PROVISIONAL with no QUESTIONS entry planned** (R-724-2 settled P-724-3; the implementer's "no QUESTIONS entry" line predates F-3). **Disposition: CONFIRMED — closeout obligation added:** both are put to her AT THE WALK (the screenshot shows exactly these two choices); any she blesses becomes a ruling here; any left unruled is logged in `notes/QUESTIONS.md` at the merge moment by the merging session.

**R2-F-3 [NIT] — the rescoped pin's doc comment cites the wrong red-on-old evidence** (the first batch's revert and F-1's red run — both the other direction; the pin's own bite is the fix pass's 4b revert). **Disposition: CONFIRMED — orchestrator adjudication fix** (comment-only, fully specified: cite 4b), with one implementer sanity pass over the diff (the final-round rule: never the orchestrator's eyes alone).

**Round-2 closeout obligations, gathered:** the walk (the acceptance unit's use-shaped evidence; F-7 and the P-724-1/-2 blessings ride it) · the Debt tickets at closeout triage: R2-F-1 (oracle hygiene, Tests & tooling) and F-6 (the four-names rename, Books) · QUESTIONS entries for any P-724 provisional she leaves unruled at the merge.

## THE RELEASE (the orchestrator's half, after the merge)

Version **1.0** (`release.sh --version 1.0` — the script stamps MARKETING_VERSION; X.Y is a legal shape). Her word is explicit and standing (this message); the notes are HERS to word ("I'll actually fix the wording notes myself") — the orchestrator drafts `ReleaseNotes-1.0.md` as clean public copy (one line per bullet, no draft/meta/process lines — VX-708's rule), presents it in chat, lands her fixes on the branch before the merge so main is release-ready. Then: PR merge (merge commit) → `Tools/Release/release.sh --version 1.0` at a zero-instance window, no repo commits while it runs → the site road per `~/dev/stargazing.tech/stargazing-tech/notes/variorum-releases.md` (DMG-first: R2 put → verify dmg → appcast copy → `variorum.json` bump → build+deploy → verify appcast) → A1 safety copy + `/Applications` refresh at a zero-instance window.
