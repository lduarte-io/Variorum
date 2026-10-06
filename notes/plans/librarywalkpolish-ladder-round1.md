# librarywalkpolish batch 1 — cold-review ladder ROUND 1 (fresh `opus-reviewer`, 2026-10-05; diff `128c4af1..923be8c6`, the thirteen record-only commits named at spawn excluded)

**Verdict: 1 MAJOR · 5 MINOR · 5 NIT.** The reviewer executed REVIEW_PROMPT.md verbatim in its
own scratch DerivedData (`17y-review7`); re-ran the batch's suites (49/14 — 47 green + the
labeled known issue + the pre-existing F-BW-2 red) and the existing Library suites on the new
engine (71/10 green, the appearance-flip pin among them); compared the face captures
first-hand (visually identical); VERIFIED rather than trusted the two inherited claims (the
F-BW-2 "pre-existing" claim CONFIRMED by replaying the scan across six commits — with one
name corrected: the offender landed at 15b081d2, f8977039 only moved it; the compose rider
CONFIRMED genuinely shipped). Seam check: fences empty; the one borderline (VR-118's
effectiveOrder reading a stored LOCAL preference) judged outside "a default's meaning" — the
opus cast stands, the reasoning recorded. SAME-MODEL round: the dispositions below are the
orchestrator's, adjudicated against the spec.

## Findings and dispositions

- **[MAJOR-1] VR-116's drag chip is CUT OFF on most grabs** (`ShelfView.swift:1185–1199`): the
  preview canvas is exactly the row's size while the chip centre is clamped only to the
  canvas, so any grab ≳3 pt off the row's vertical centre, or within half a chip of either
  end, clips the chip (empirically probed standalone: grabs at y 4/32 cut 11 pt, a
  trailing-end grab lost 82 of 186 pt — the end of the book's name); the batch's own pin even
  locks a centre at y 0. **DISPOSITION: CONFIRMED — FIX, the reviewer's PRIMARY shape** (grow
  the canvas symmetrically by a chip-sized margin per axis, chip at grab + margin — the
  canvas stays centred over the source so the chip stays exactly under the cursor; the clamp
  alternative is REJECTED, it re-introduces the offset R-LWP-3 forbids). The reviewer's
  red-on-old pin as specified.
- **[MINOR-1] The order popover OUTLIVES NAVIGATION** (a menu never does): `orderOpen` lives
  on the RootView-owned model; only a board-local catcher closes it; ⌘K/⌘N/⌘J or a sidebar
  click tears the board down with the popover "open", and it greets her return. #188(d)
  overclaimed. **DISPOSITION: CONFIRMED — FIX** (close on the board's `.onDisappear`, window
  resign-key, app deactivation; the reviewer's pin; #188(d) corrected at this seam).
- **[MINOR-2] Three B-WALK record sections were filed INSIDE the B3 RECORD** (between B3's
  REVERT STATE and its red-on-old paragraph) — the late-session degradation class the spawn
  flagged, caught working. **DISPOSITION: CONFIRMED — FIXED AT THIS SEAM by the orchestrator**
  (the four blocks moved whole under the B-WALK RECORD's REVERT STATE line; LIVE STATUS's
  "below" pointers true again).
- **[MINOR-3] HALF of the F-BW-1 tripwire claim is HOLLOW:** the `withKnownIssue` arm reads
  only the model (it trips when hand placing returns) and NEVER the seed text — so the
  claimed "turns red when the lesson is re-worded" is false, and the arm also burns a full
  3-second wait every run. **DISPOSITION: CONFIRMED — FIX in the fix round**, folded into
  F-BW-1's own reword (below): the lesson re-words, a SEED-TEXT pin replaces the hollow half,
  the wait short-circuits when hand placing is off, and the three claim sentences are
  corrected to what is true.
- **[MINOR-4] Nothing GATED 0.9.2 on the lesson-7 reword** (the owner cell's "or VR-120,
  whichever comes first" would have let the release ship a lesson teaching hidden doors).
  **DISPOSITION: CONFIRMED — FIXED AT THIS SEAM:** F-BW-1 is now A PRE-0.9.2 GATE (the
  KnownIssues owner cell + the pass's close line both say so); the reword itself is
  AUTHORIZED seed-content work in the fix round (the B-SEED/B-DEDUPE precedent; the standing
  re-seed consequence already scheduled at the arc's close).
- **[MINOR-5, product] The scope-honesty rule was built on the WEAKER side:** Cards over the
  Books/Blocks scopes shows "No notes match" over a full library — the same dishonest state
  both of her rulings removed, reachable two ways. **DISPOSITION: CONFIRMED — BUILD THE
  GENERALIZED RULE as PROVISIONAL** (Cards ⇒ Notes from ANY scope; a non-Notes scope picked
  inside Cards ⇒ List), hers to overturn; #188(a) carries the note; no pin owed beyond the
  rule table's.
- **[NIT-1] `PressReporter` ignores clipping** (`bounds.contains`): a shelf name scrolled out
  of the strip keeps a ghost hit zone that closes the № float from unrelated right-clicks.
  **DISPOSITION: CONFIRMED — FIX** (`visibleRect.contains`; the reviewer's pin, red today).
- **[NIT-2] A cross-WINDOW Bookcase drag meets a per-window drag record** (no hairline, or a
  stale one, on a header drop that acts — W-5's reverse; needs two Bookcase windows).
  **DISPOSITION: RECORDED as an accepted corner** — #188(l); the app-wide drag record is hers
  to order.
- **[NIT-3] #188(k) named only part of its class:** the strip's "starred" word outlines for
  an already-starred book, then releases into `starBook`'s silent guard — the same false
  offer W-5 removed from the headers. **DISPOSITION: CONFIRMED — the class COMPLETES in the
  fix round** (the outline gates on the drop acting; the sweep-table discipline), and (k)
  carries the fold.
- **[NIT-4] F-BW-2 named the wrong commit** (the offender landed at 15b081d2; f8977039 moved
  it to :393) — the "pre-existing" substance VERIFIED true. **DISPOSITION: CONFIRMED — the
  name corrected at this seam in all four places; the one-line `.lineLimit` FIX itself is
  AUTHORIZED in the fix round** (the 19g class; `ChromeLineLimitTests`' standing red is the
  red-on-old, flipping green is the proof; round 2's eye covers the read-tier touch).
- **[NIT-5] Dark mode was never captured** (every capture and parity pin ran `.aqua`; R51's
  black room leaves the new face's header material, the popovers and the chips unmeasured
  there). **DISPOSITION: CONFIRMED — the fix round runs ONE `.darkAqua` pass of the rig +
  Bookcase mounts** and reports; the NOT-DONE line and HER RE-WALK list gain it.

## The clean bill (held)

The engine parity (pins + first-hand capture comparison + 244-unedited-tests), the switch
rule's purity, the dismissal mechanism's pass-through, the compose rider's shipped proof, the
reorder hiding through one value with the preference never rewritten, the W-5 trace against
the code, token-only fills, every red-on-old committed ahead, and the mobile-parity line —
all verified solid by the reviewer first-hand.

## HER RE-WALK list (the reviewer's three live-only items + one):

1. Does the № float leave the screen while the wing switcher's native menu is tracking?
2. Does the drag chip land under the cursor on a REAL drag (the fix round's margin fix
   included)?
3. Does a header's hairline light when a book from ANOTHER shelf hovers it in All?
4. Dark mode, one pass of the Library face + Bookcase (NIT-5) — the fix round's captures are `17y-screens/bwalk/fix/dark/`; her one call there is #188(m), the List's grey heading bar in dark.

## THE FIX ROUND (a FRESH session — the batch implementer ended past the ~500k cliff; spawned at this commit)

Scope: MAJOR-1 (the canvas margin + pin) · MINOR-1 (popover lifecycle + pin) · MINOR-3+F-BW-1
(the lesson-7 reword, seed-content AUTHORIZED, + the seed-text pin + the wait short-circuit +
the claim corrections) · MINOR-5 (the generalized switches, PROVISIONAL) · NIT-1
(`visibleRect` + pin) · NIT-3 (the starred-word false offer, the class sweep) · NIT-4's fix
half (the `.lineLimit` one-liner, `ChromeLineLimitTests` green) · NIT-5 (the `.darkAqua`
pass). Round 2 (fresh reviewer) re-reviews the fix diff.

### THE FIX ROUND (fresh session) — `opus-implementer`, 2026-10-05 ~22:20; LIVE STATUS from the first commit

**NOT DONE (first line, per the contract):** (1) **NO GUI WALK of any row** — the author may be at the machine, so every capture is a MOUNTED test-host window and every act a model/door/notification call; her re-walk is the use-shaped close: the drag chip on a REAL drag (MAJOR-1 is verified by rendering the canvas + Apple's centred-over-the-source rule, never a live drag), the order popover's close on a real ⌘K / sidebar click / ⌘-tab (verified through the notifications AppKit posts and a real root swap, not a live deactivation), the strip outlines under a real drag; (2) **#188(m) — the List's pinned heading in DARK — found by the dark pass, posed to her, NOT built** (a system material, not a literal/token bug; three probes did not reproduce the native table's look); (3) no Escape key for the order popover (#188(d), unchanged); (4) #188(l)'s cross-window corner now spans the strip's targets too (the class completed on the same per-window record — accepted, hers); (5) VR-122's full guide currency pass NOT run (the orchestrator's, before the release) — one note left for it in row 3; (6) her real store's guide re-seed and the `/Applications` refresh are the arc close's; (7) no Release measurement; (8) no core `swift test` (zero `Sources/` change).

Preflight read in this session's own context (never delegated): CLAUDE.md + its auto-loaded canon;
this file whole; `notes/plans/librarywalkpolish.md` (the governing frame, R-LWP-1…6); the 17 file's
"17y B-WALK BRIEF" + "17y B-WALK RECORD" whole; QUESTIONS #188; KnownIssues' F-BW-1/F-BW-2 rows;
`notes/SessionResiliencyProtocol.md`; `notes/TEXTKIT2_NOTES.md` (NIT-4 touches a read-tier file —
one `.lineLimit`, nothing else). Worktree `~/dev/variorum-17y` ONLY; DerivedData
`App/Variorum/DerivedData/17y-wfix2`; no subagents; the author may be at the machine — headless
builds/tests only, no GUI driving, no store staged or restored, the running Debug instance (pid
from the 17y DerivedData) untouched. Captures: `notes/plans/17y-screens/bwalk/` (gitignored).
SEED CONTENT AUTHORIZED for this session for lesson 7 ONLY (the B-SEED/B-DEDUPE precedent).

| # | item | status |
|---|---|---|
| 0 | This LIVE STATUS | DONE (this commit) |
| 1 | MAJOR-1 — the drag canvas grows by a chip-sized margin per axis, chip at grab + margin (the reviewer's red pin first) | DONE (05de8ae0 red · this commit fix) — `BookDragSource.placement` (pure): the canvas = the source + ONE CHIP on every side (the margin is the chip's own measured size — `GrabCanvas`, a `Layout` that measures its one subview, so any book name fits), still centred over the row (Apple's placement rule), the chip's top-left at grab + margin − half a chip ON WHOLE POINTS (crisp edges; ≤ 0.5 pt from the exact grab). The clamp shape NOT taken (it moves the chip off the cursor — R-LWP-3). RED on the old canvas (`bwalk/fix/red.log`: grab (600,4) ink 188×21, grab (790,17) ink 104×34 — cut) → GREEN, both grabs the whole chip 188×34 (`green2.log`). **One pin correction of mine, said:** the reference render of a bare chip at its own frame CLIPS its hairline's outer half-point (186×32 framed vs 188×34 whole) — the reference now renders the bare chip with room around it; the old tree's two inks still fail it (21 ≠ 34 high; 104 ≠ 188 wide — the red log's own numbers). JUSTIFIED EDIT: `thePreviewIsTheTitleAtTheGrabPoint` asserted a source-sized canvas — now the canvas grows by a chip per side and the ink's offset from the canvas centre equals the grab's offset from the row centre (three grabs, ±1.5 pt). New pure pin `thePlacementIsTheGrabPlusAChipMargin`. **REVERT-VERIFIED:** `placement` set back to the shipped shape (canvas = the source, chip centred on the grab) → the reviewer's pin RED against the corrected reference — grab (600,4) ink 188×21, grab (790,17) ink 104×34 vs the whole chip's 188×34 — with the placement and preview pins ("9 tests … with 11 issues", `bwalk/fix/major1-revert.log`); restored, `git diff --quiet` |
| 2 | MINOR-1 — the order popover closes on the board's disappearance, window resign-key, app deactivation (the reviewer's pin first) | DONE (05de8ae0 red, 557fbb1e arms made independent · this commit fix) — `ShelfViewModel.orderMenuLifeEnded()` (closes the order popover only — the census is a remembered float, #188(b), never a menu; guarded, no write when closed), reached by the board's `.onDisappear` and by the new shared `Core/Views/MenuLifeReporter` (`.reportsMenuLifeEnds`: an inert AppKit view observing ITS OWN window's `didResignKey` and the app's `didResignActive` — the notifications AppKit posts; ⌘K's palette is a SHEET, so it reaches the board through resign-key). RED on the old board, all three arms independently (`red2.log`: lines 317 / 327 / 335 — remount, resign-key, deactivation) → GREEN (`green1.log`), the census arm green both sides (a guard). **One pin correction of mine, said:** the first red run's arms cascaded (an arm's toggle closed the previous arm's leftover popover) — each arm now starts closed (557fbb1e), re-run red before any fix |
| 3 | MINOR-3 + F-BW-1 — lesson 7 reworded to what 0.9.2 ships; the seed-text pin replaces the hollow half; the wait short-circuits; the three claim sentences corrected — A PRE-0.9.2 GATE | DONE (05de8ae0 red, 557fbb1e · this commit fix) — **THE REWORD (seed content, authorized for this round; words functional, 13s re-voices), `TutorialSeeder` lesson 7 "the bookcase", its three hidden-door sentences:** (1) "…alphabetical until you choose otherwise ~~— switch to your own order to place them by hand~~." (2) "The order ▾ beside them reads A–Z or last edited." (was "…, or my order.") (3) "Switch the order ▾ to last edited and the books you worked in most recently come first." (was "…to my order and place a book by hand — drag it, or right-click ▸ Send to Top."); the drag-a-book-onto-a-shelf's-name sentence, the star sentence and the place/finder sentence unchanged. **THE SEED-TEXT PIN** `TutorialBooksLessonTests.noLessonTeachesADoorThisReleaseHides`: every lesson of the WHOLE guide (all members, not one chapter) against the release's hidden doors — the order ▾'s rows NOT in `offeredOrderModes` by their own labels, and while `handPlacingOffered` is off, Send to Top/Bottom by their own verbs; when VR-120 returns hand placing the hidden set empties. RED on the shipped seed (`red2.log`: "the bookcase" teaches "my order", "Send to Top") → GREEN (`green1.log`). **One pin correction of mine, said:** the first red run also forbade "own order" and caught "gatherings & arrivals" — a BOOK's own note order, real and correctly taught — dropped before any fix (557fbb1e). **THE HOLLOW HALF DROPPED:** R5's `withKnownIssue` is gone; the my-order arm now runs only `if model.handPlacingOffered` (the 300 × 10 ms wait short-circuits while hand placing is off — the same arm returns unchanged with VR-120), and R5 walks what the lesson now teaches (the order ▾'s last edited, picked through `pickOrder`). JUSTIFIED EDIT `lessonSevenTheBookcase`: the new sentences pinned exactly, the order labels read from `offeredOrderModes`, the Send to Top door no longer expected, and the "try it"'s truth EXECUTED (the door picks last edited; the most recently worked-in book leads). **THE THREE CLAIM SENTENCES CORRECTED** (the wrapper read only the model — it would have turned red when hand placing returned, never on a reword): the B-WALK RECORD's F-BW-1 text, the KnownIssues row (now RESOLVED), the R5 test comment (rewritten to say what is true). **The re-seed consequence stands as scheduled** (her real store's guide re-seeds via Help ▸ Restore Tutorial… at the arc's close; a fresh store is born with the new words). VR-122's full currency pass (the orchestrator's, before the release) is NOT this row — I read only lesson 7's hidden-door sentences; one currency note for it: lesson 7's strip sentence says "All, then each shelf by name" while the strip now also carries the "starred" word (17y (s)) — left for VR-122 |
| 4 | MINOR-5 — the generalized scope-honesty rule: Cards ⇒ Notes from any scope; a non-Notes scope inside Cards ⇒ List — **HER RULING** (R-LWP-6's amendment, ~23:00: "yes, generalized change is fine to work with" — the coordinator's message mid-round; no longer provisional) | DONE (05de8ae0 red · this commit fix) — the pure pair in ONE home, `LibraryCatalogModel.scope(afterPicking:from:)` = Notes whenever Cards is picked; `mode(afterPicking:from:)` = List whenever a scope other than Notes is picked inside Cards; List and the Timeline untouched, leaving Cards never moves the scope back; the doors (`pickMode`/`pickScope`) unchanged. The rule table's pins FLIPPED, committed ahead (JUSTIFIED EDIT, her ruling named in each): `pickingCardsMovesAnyScopeToNotes`, `pickingANonNotesScopeInCardsMovesToList`, `theGeneralizedCombinationsThroughTheDoors` (Cards over Books owes a re-read; Notes in Cards stays; Blocks in Cards → List) — RED on the All-only rule (`red.log`: 7 issues) → GREEN (`green1.log`); `theDoorsSwitchAndTheListingFollows` green unedited. #188(a) already carries the closure (the orchestrator's 7855bbac) |
| 5 | NIT-1 — `PressReporter` tests `visibleRect` (the reviewer's pin first) | DONE (05de8ae0 red, 557fbb1e precondition corrected · this commit fix) — `PressReporterView.handle` hands the pure rule `bounds.intersection(visibleRect)`, never `bounds`. **MEASURED (macOS 27), the reason it is the intersection and not `visibleRect` alone:** a view that does not clip to its bounds (the macOS 14+ default) reports a `visibleRect` NOT intersected with its own bounds — the pin's reporter half inside a scrolled clip read `visibleRect` (-80, 0, 100, 40), the clip's whole window in its space; `visibleRect` alone would have made the clip's every other point a hit zone. RED on the old `bounds.contains` (`red2.log`: the off-screen press reported) → GREEN (`green1.log`) with a guard arm (a press on screen beside the reporter reports nothing — green both sides; it fails a `visibleRect`-only fix). **One pin correction of mine, said:** the first red run's precondition assumed `visibleRect` ⊆ bounds (false, above) — corrected and re-run red before any fix (557fbb1e) |
| 6 | NIT-3 — the strip's "starred" word outlines only when the drop acts; the class sweep table | DONE (05de8ae0 red — the source pin · this commit fix) — `ShelfViewModel.starredDropLights()` (a book not yet starred; never a starred book — `starBook`'s guard; never a shelf name) and `shelfNameDropLights(shelfID:)` (a book from ANOTHER shelf — `reshelve`'s guard; ANOTHER shelf's name — the drop's own guard), read in each target's `onHover` exactly as the headers read `headerDropLights` — the strip's chips, the ⋯ panel's rows, the starred word. RED (`red.log`: the source pin, 2 issues) → GREEN with the rule pin `aStripOutlineLightsOnlyWhereItsDropActs` (`green1.log`). § THE CLASS SWEEP below |
| 7 | NIT-4's fix half — `.lineLimit(1)` beside `.fixedSize()` at `NoteIndexColumn.swift:393`; `ChromeLineLimitTests` red → green | DONE (this commit) — ONE added line (`.lineLimit(1)` + its P-8 comment, now :393, the `.fixedSize()` at :394); NOTHING else in the read-tier file. The standing red WAS the red-on-old (`red.log`: `ChromeLineLimitTests` 1 issue, the offender `NoteIndexColumn.swift:393`) → GREEN (`green1.log`), and the index column's own pins — `NoteIndexColumnScrollCostTests` (the live controls measured inside the hint's footprint) — green beside it: the live set is three one-line glyph controls, so the policy changes no size. KnownIssues' F-BW-2 row RESOLVED |
| 8 | NIT-5 — ONE `.darkAqua` pass of the List-face rig + Bookcase mounts; captures + report | DONE (02e171e2 the rig's dark switch · this commit the report) — the rig's opt-in `TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE_APPEARANCE=dark` (`.aqua` stays the default); `theFace` / `theFaceUnderManyBooks` / `theCardsFaces` / `theBookcaseFaces` × both voices: "4 tests in 1 suite passed" (`bwalk/fix/dark/rig.log`), 18 on-screen captures by window id (`bwalk/fix/dark/dark-*-screen.png`; a title-watching capture helper kept in the session scratchpad, F-BW-5's road). **NO literal/token bug found — nothing fixed.** ONE PARITY FINDING, judgment-shaped, posed to her as #188(m) and NOT built (§ THE DARK PASS below): the List's pinned section header draws a room-blind warm grey band in dark |
| 9 | END suites (the batch's + Bookcase/Library families + tutorial books + ChromeLineLimitTests) + record close | DONE (this commit) — **Mac END: "Test run with 522 tests in 80 suites passed"** — zero failures, zero skipped, zero known issues (`bwalk/fix/end-mac.log`, the suite list `end-suites.txt`): batch 1's whole 55-suite union (every Library- and Bookcase-touching suite, the tutorial's books suites, the registry walk, `NoLiteralColourTests`, `ChromeLineLimitTests` — GREEN now) + the tutorial spine (11 `TutorialWalkTests` suites, the furniture fold, the build flavour) and every seed-reading suite (launch furniture, Welcome, calm asks, the encryption book/drill, new modes, the shell confirm, the snippets and take-card doors) for the lesson-7 reword + `NoteIndexColumnScrollCostTests` for the read-tier line. Built from the CLEAN tree after the probes' restores. The phone: no build owed — `git diff 3b98c225 --stat -- App/Variorum/Shared Sources Server App/Variorum/VariorumMobile` EMPTY; the phone's own guide (`MobileTutorialSeeder`) never taught my order |

**REVERT STATE: NO REVERT IN FLIGHT** (MAJOR-1's behavioural revert and the dark pass's three header-material probes each ran and were restored: `git checkout --` + `git diff --quiet` clean).

#### THE CLASS SWEEP — every Bookcase drop target's outline/hairline vs. whether its drop acts (W-5's false-offer class, completed at NIT-3)

| target | lights for (after this round) | released into nothing — no longer offered | state |
|---|---|---|---|
| All's section HEADERS (`ShelfView.sectionHeader`) | a BOOK from another shelf (Unshelved: a shelved book) | a book on its own shelf's header · any shelf name | FIXED at W-5 (batch 1, 6c04ab78…), unchanged here |
| the strip's shelf NAMES (`BookcaseStrip.shelfName`) | a book from another shelf · another shelf's name | a book over its own shelf's name · a name over itself | FIXED HERE (#188(k)'s alternative — the class completes; hers to overturn) |
| the ⋯ panel's ROWS (`ShelfOverflowPanel.row`) | the same rule as a strip name (one rule, `shelfNameDropLights`) | the same | FIXED HERE |
| the strip's "starred" WORD (`BookcaseStrip.starredWord`) | a book not yet starred | an already-starred book · any shelf name | FIXED HERE (NIT-3) |
| the book ROWS (my order's insertion hairline) | nothing this release (`placesByHand` false — VR-118) | — | unchanged (returns with VR-120) |

Residues, named (not fixed — neither is a silent nothing): (1) a shelf name dropped on the name RIGHT AFTER it writes a fresh position and the strip does not visibly move (`moveShelf` acts — a write, not a guard); (2) **#188(l) now spans the strip too:** every one of these reads the per-window `dragInFlight`, so a book dragged from ANOTHER window's Bookcase lights no strip outline (or a stale one) though its drop acts — the same accepted corner as the headers, its alternative (one app-wide drag record) hers to order.

#### THE DARK PASS (NIT-5) — what the captures show, measured off the on-screen pixels (`bwalk/fix/dark/`; light comparisons from batch 1's `bwalk/face/after-*`)

- **The room stays black where this pass drew it.** Terminal's room #0D0E0D, Study's #191612 (the voices' own dark rooms, unchanged here) under the List rows, the gaps, the entry bar, Cards, the Bookcase board — and under BOTH masthead popovers: their background IS the room (№ #0D0E0D, order #191612), the hairline carries the edge, no shadow in dark (the app's precedent, as built). The popovers' washed row (#232F28 Terminal · #2E3233 Study) and the strip's chips (resting #191F1B → solo'd #232F28, Terminal) step off the room by about what they do in light (light: #F6F6F3 → #E8EDE9 over #FBFBF8) — the "subtle tone indicator" holds its contrast in both appearances. Cards (VR-117) read clearly on black. The pick wash + border (F-BW-3's restored face) shows in dark.
- **THE ONE FINDING — the List's pinned section header in dark (posed as #188(m), nothing built).** The lazy face's pinned header (`LibraryListHeader` on `NSVisualEffectView(.headerView, .withinWindow)`) draws **#2F2D29 in BOTH voices** — a warm grey band across the top of the black room — while the NATIVE table's own floating header beside it (the capped books region still rides the native `List`, `theFaceUnderManyBooks`) draws **#191B19 over Terminal's #0D0E0D and #25221E over Study's #191612**: room-tinted, nearly the room. In LIGHT all three read #FFFEFF (the batch-1 parity, true there). So the W-1 face's parity was light-only by construction (every capture and pin ran `.aqua`) and breaks in dark. PROBED, never committed (each restored clean): `.state = .active` → #292723 / #2C2925 (the inactive-window fallback is a small part); the room's own token beneath the material → no change; both → as `.active`. The material in the SwiftUI pinned header does not blend with the room the way the table's floating row does; I did not find the native's blend. Neither a literal nor a token bug (a system material) — so, per the brief, recorded, not fixed. Options for her in #188(m).
- **Pre-existing, both appearances, not this round's (an observation for VR-122's eye or her walk):** at 1000 pt with the note panel open, the Library masthead squeezes its search field to a sliver (batch 1's `before-*-picked` captures show the same, so it predates the List engine).

#### FOR ROUND 2 (the fix diff, this session's)

The range is `3b98c225..<this commit>`; the ORCHESTRATOR'S commit inside it is 7855bbac (her R-LWP-6 ruling + VR-122 — not this round's). This round's commits: 89dc8356 (LIVE STATUS) · **05de8ae0 the red pins ahead** · 557fbb1e (three red pins corrected before any fix, re-run red) · **13ae453a the Bookcase three (MAJOR-1 · MINOR-1 · NIT-3)** · **4e793168 NIT-1** · **aca85619 MINOR-5** · **c63ba1dc NIT-4's line** · **0919c814 F-BW-1 + MINOR-3 (the seed reword)** · 8c60e66c / 87f8daac (MAJOR-1's revert check, announced and restored) · **02e171e2 the rig's dark switch** · 3 record-only commits (the probe's announcement, the dark-pass report, the END). Seams: zero `Sources/` (no `Sync/`, schema, custody), zero `Shared/`, zero mobile; ONE read-tier line (`NoteIndexColumn.swift`, `.lineLimit(1)` only — `notes/TEXTKIT2_NOTES.md` read first; no editor-seam code touched); seed CONTENT in lesson 7 only (authorized). New shared Mac chrome: `Core/Views/MenuLifeReporter.swift`. Expected cast: `opus-reviewer` (the read-tier line is a chrome line policy, not editor-seam logic — the orchestrator's call; the orchestrator RE-CAST to Fable at 896b8166 — the seam rule binds on content).

---

# librarywalkpolish batch 1 — cold-review ladder ROUND 2 (fresh `fable-reviewer`, 2026-10-05; the fix diff `3b98c225..c7d58bef`, 7855bbac excluded as the orchestrator's)

**Verdict: NO new BLOCKER · NO new MAJOR · 0 MINOR · 1 NIT (record-only, mechanism SPECULATIVE — no fix landed). Every round-1 fix is CONFIRMED sound; the ladder needs no round 3.** The reviewer executed
REVIEW_PROMPT.md verbatim in its own scratch DerivedData (`17y-review8`), read the whole diff and
the touched files' surrounding code itself, and re-ran the touched suites first-hand: **51 tests in
8 suites green** (BookcaseDragFace, BookcaseCensusMenu, BookcaseMastheadPopover,
LibraryViewScopeSwitch, TutorialBooksLesson, TutorialBooksRitual, ChromeLineLimit — green now —
and NoteIndexColumnScrollCost). The fix round's local logs corroborated rather than trusted: the
END "522 tests in 80 suites passed" read from `bwalk/fix/end-mac.log`; every red-on-old read from
`red.log`/`red2.log` (NIT-1's two issues, MINOR-1's three arms, F-BW-1's two seed hits, NIT-3's
source pin, MINOR-5's rule table) and MAJOR-1's revert run from `major1-revert.log`
(`theChipIsNeverCutAtTheRowsEdges` red under the shipped placement against the CORRECTED
reference). TEXTKIT2_NOTES §3–4 re-read for the read-tier touch: nothing there bears on a SwiftUI
line-policy chrome line.

## The three scrutiny items (the spawn's), each given this reviewer's own judgment

1. **The NIT-3 class-sweep extension (strip names + ⋯ panel rows beyond the starred word) —
   the orchestrator's sustainment is CONFIRMED.** Traced on the code: each new gate mirrors its
   drop's OWN pre-existing guard exactly — `shelfNameDropLights` vs `reshelve`'s same-shelf
   return (ShelfViewModel:386) and the handlers' `guard draggedID != shelf.id`
   (BookcaseStrip:293/604); `starredDropLights` vs `starBook`'s `!book.starred` guard (:407);
   a shelf payload over "starred" lights nothing and its handler does nothing. The drops
   themselves are byte-untouched, so no product behavior was invented — only the OFFER was made
   honest, which is §12's standing law ("a door that did nothing speaks a refusal" — the
   false-offer class W-5 applied at her own word to this surface's sibling targets). #188(k)
   carries exactly what changed and each rule is one small pure function to overturn. Sustained.
2. **The three self-corrections — each verified SOUND, none a patch over a misread.**
   (a) *The chip reference's half-point hairline:* the reference measures INK, and a frame-sized
   render clips the hairline's outer half-point (it strokes ON the edge); `.padding(4)` un-clips
   the measurement and adds no ink. The old tree's failures survive the correction by arithmetic
   (ink 188×21 and 104×34 vs the whole 188×34 — a chip centred at y 4 spans [−13, 21], at x 790
   spans [697, 883] on an 800-wide source), and the revert log shows the pin red against the
   corrected reference. (b) *`visibleRect` not self-clipped on 27:* the `bounds ∩ visibleRect`
   shape is correct under EITHER OS behavior (if `visibleRect ⊆ bounds` the intersection is a
   no-op), the pin asserts the half-shown precondition at runtime, and its guard arm (a press on
   screen beside the reporter) defeats a `visibleRect`-only fix — traced end to end on the pin's
   geometry (window x 120 → reporter-local 40, inside bounds, outside the 20-pt shown slice).
   (c) *The dropped "own order" ban:* "gatherings & arrivals" teaches "it can wear your own
   order: drag one note above the other" — a BOOK's internal NOTE order (manual `sort_field`,
   `reading_post` reorder), a live shipped door unrelated to VR-118's hidden Bookcase my-order;
   the ban would have flagged a true lesson. Dropping it was right, and the final pin still
   catches the actual hidden doors.
3. **`noLessonTeachesADoorThisReleaseHides` + the lesson-7 reword.** The pin reads the WHOLE
   guide (`TutorialSeeder.restore` seeds every chapter; the SQL walks every live member;
   `lessons.count > chapterTitles.count` trips if the world ever shrinks) against a hidden set
   DERIVED from the model — `offeredOrderModes` + `handPlacingOffered`, labels/verbs read from
   the app's own constants, so a 13s re-voicing tracks and VR-120's return empties the set.
   **It WOULD catch a future lesson teaching a hidden door by its label or verb** (the only
   stable mechanical signature); a PARAPHRASED teaching escapes it — a named limit the pin's own
   doc claims nothing beyond, and exactly VR-122's (and her walk's) territory. Red-on-old is
   mechanically certain (the shipped seed contained "my order" and "Send to Top";
   `localizedCaseInsensitiveContains` hits both — the 2 issues in `red2.log`). **Lesson 7's
   reworded sentences verified TRUE of the shipped surface, each against the code:** the default
   is `.alphabetical` (BookcasePrefs:43) and a stored my-order READS A–Z while hidden
   (`effectiveOrder`); the order ▾ offers exactly A–Z · last edited (`offeredOrderModes`,
   ShelfViewModel:197, drawn at BookcaseStrip:490); "the books you worked in most recently come
   first" is `BookcaseBoard.ordered`'s `a > b // newest first` (BookcaseBoard:212) — with
   starred floating first, which the lesson's own star sentence teaches; the drop-onto-a-name
   and Move to Shelf doors are live. The one stale sibling (the strip sentence not naming the
   "starred" word) is NAMED and owned by VR-122, rightly left.

## The read-tier line (the reason this round is Fable's) — judged on its own context

`NoteIndexColumn.swift:393` — `.lineLimit(1)` on `liveRowControls`' HStack, directly above the
pre-existing `.fixedSize()`. The content is three one-glyph controls (↑ · ↓ · the ⋯ `Menu`, which
already carried its own policy pair), so the stated policy changes no size — the
footprint-equality pin (`NoteIndexColumnScrollCostTests`) green in this reviewer's own run. It is
the P-8/b6dae25 class rule applied where the scan found it missing; NOTHING else in the file
changed; no TextKit object, no editor-seam type, no measurement road is touched — TK2's §3–4
concerns (identity stamps, viewport, fixing) have no purchase on a SwiftUI chrome line policy.
`ChromeLineLimitTests`' standing red WAS the red-on-old; it flips green. CLEAN.

## Findings

- **[NIT, SPECULATIVE — record-only, no fix] · `App/Variorum/Variorum/Core/Views/MenuLifeReporter.swift:66` ·
  `stopObserving()` uses the blanket `NotificationCenter.default.removeObserver(self)`**, which
  removes EVERY default-center observation registered with this view as observer — the
  long-cautioned hazard being system/superclass registrations stripped alongside your own.
  Evidence: the call site, and Apple's standing guidance to remove by name where the observer
  outlives the registration moment. Mechanism NOT traced: this reviewer could not identify any
  concrete default-center registration AppKit makes with a plain `NSView` as observer on
  macOS 27 that the blanket call would strip, so no failure can be demonstrated and no
  red-on-old pin could exist — by the hallucination guard this is below the fix bar, and the
  view is final, dedicated, and registers exactly two observations. Proposed shape if ever
  touched: two name-scoped removals. RECORDED for the orchestrator's seam; deliberately NOT
  landed (no pinnable mechanism; no churn on fresh shared chrome mid-ladder without one).

## The clean bill (what this reviewer checked first-hand and found solid)

- **MAJOR-1:** `BookDragSource.placement`'s math verified by hand — the canvas spans
  [−chip, source+chip] per axis centred over the source, the chip's top-left at
  `center + chip/2` in canvas space puts the chip's CENTRE exactly on the grab in source space
  (≤ 0.5 pt rounding), and the chip can never touch the canvas edge (margin = one whole chip);
  `GrabCanvas` measures its one subview so any book name sets its own margin. The clamp
  alternative stays rejected per R-LWP-3. Red → green → revert-red all corroborated from logs
  plus arithmetic. Her re-walk remains the live-drag check (NOT-DONE first line, honest).
- **MINOR-1:** `MenuLifeReporterView` observes its OWN window's `didResignKey` + the app's
  `didResignActive` (re-registered per window move, deregistered on nil-window and dismantle,
  `hitTest` nil — never a click target); `orderMenuLifeEnded()` is guarded (no write when
  closed) and touches ONLY `orderOpen` — the census float verified untouched (the pin's fourth
  arm, green both sides as a guard). The three red arms are independent (each starts closed —
  the 557fbb1e correction, verified in the pin's body). The board's `.onDisappear` carries the
  root-swap close; the remount arm drives a REAL root swap.
- **MINOR-5:** the generalized pair is two one-line pure functions; the doors (`pickMode`
  returning whether the question changed → the caller's `search()`; `pickScope` always
  re-reading, the mode move riding the view's `onChange`) are byte-untouched and their only
  call sites verified (LibraryCatalogView:476/494). List and the Timeline provably untouched
  (`mode(afterPicking:)` acts only from `.notes`); leaving Cards never moves the scope back.
  Mode/scope are in-memory only (no persisted restoration road bypasses the doors). Her ruling
  R-LWP-6-as-amended is verbatim-anchored in the plan file; #188(a) closed.
- **NIT-1:** the intersection shape, the measured non-clipping `visibleRect`, the pin's
  geometry and its anti-overshoot guard arm — all traced (above).
- **The records:** KnownIssues' two rows resolved in place with the corrected history
  (the F-BW-1 row now says what the old wrapper actually read); #188 (a)/(d)/(k)/(l)/(m)
  current and honest; the fix-round record's commit map matches `git log` exactly; 7855bbac
  verified record-only (QUESTIONS + the plan file, zero code); no commit in the range carries
  a trailer; zero `Sources/`, zero `Shared/`, zero mobile confirmed by the diff stat; the
  phone's seeder never taught my order (no mobile reword owed).
- **NIT-5 / the dark pass:** record-only as briefed; #188(m) poses the List's dark heading
  band with the three probes' results, nothing built — the right call under the
  no-literal/no-token finding (a system material is hers to judge). The untracked
  `notes/plans/17y-screens/walk-mockups.html` predates this review session and was left alone.
- **Residues named, not silent:** the same-position shelf-name drop (a write, not a guard) and
  #188(l)'s cross-window corner now spanning the strip — both recorded, hers to order.

**Ladder consequence: no new BLOCKER/MAJOR ⇒ no round 3. The one NIT is record-only at this
reviewer's final call (the cross-model contract's confirm-and-implement path requires a traceable
mechanism; this one has none). The fix diff stands as committed; the pass moves to VR-122 and her
re-walk.**
