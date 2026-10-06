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
4. Dark mode, one pass of the Library face + Bookcase (NIT-5).

## THE FIX ROUND (a FRESH session — the batch implementer ended past the ~500k cliff; spawned at this commit)

Scope: MAJOR-1 (the canvas margin + pin) · MINOR-1 (popover lifecycle + pin) · MINOR-3+F-BW-1
(the lesson-7 reword, seed-content AUTHORIZED, + the seed-text pin + the wait short-circuit +
the claim corrections) · MINOR-5 (the generalized switches, PROVISIONAL) · NIT-1
(`visibleRect` + pin) · NIT-3 (the starred-word false offer, the class sweep) · NIT-4's fix
half (the `.lineLimit` one-liner, `ChromeLineLimitTests` green) · NIT-5 (the `.darkAqua`
pass). Round 2 (fresh reviewer) re-reviews the fix diff.

### THE FIX ROUND (fresh session) — `opus-implementer`, 2026-10-05 ~22:20; LIVE STATUS from the first commit

**NOT DONE (first line, per the contract): PENDING — the round is running; this line is rewritten at the close.**

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
| 9 | END suites (the batch's + Bookcase/Library families + tutorial books + ChromeLineLimitTests) + record close | NOT-STARTED |

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
