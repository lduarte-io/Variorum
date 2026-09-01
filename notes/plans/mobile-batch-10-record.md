# Batch 10 — NAVIGATION · the implementer's record

*Written as the work lands. Brief: `notes/plans/mobile-batch-10-brief.md`
— binding. Her three asks are its opening quotes, from
`notes/author-reports/2026-08-23-device-walk-and-product-asks.md`.*

**Branch** `mobile` · **base** `8c5e8aa` · **baseline** mobile **712/102
green with 2 known issues** (batch 7's unit close,
`mobile-batch-7-cold-review.md`'s UNIT CLOSED section).

---

## LIVE STATUS

| piece | state |
|---|---|
| Reading (brief · CLAUDE.md · MobileSoul §2–§5 · her report · `mobile-round-2.md` §67 · the named code, all in full, myself) | **DONE** |
| **D1 — the swipe band** (`MobileShellBand.swift` + `MobileShellView.swift`) | **DONE** — in the commit this record lands with |
| **D2 — the starred page** (`MobileStarredView.swift`, `MobileStars.swift`, `MobileShelfView.swift`) | **DONE** — same commit |
| **D3 — new note + new chapter in a book** (`MobileBookView.swift`, `MobileBookViewModel.swift`) | **DONE** — same commit |
| **Pins** (`MobileNavigationTests.swift`, 13 tests) | **DONE (9a515b7)** — re-verified on the rebuilt simulator after the restart: `✔ Test run with 13 tests in 1 suite passed after 7.170 seconds.` |
| **Red-on-old** | **DONE — all 9 reverts quoted below** (R1–R8 in one wave, R9 re-run after the restart). Restores diff-verified byte-exact against the prerevert copies AND against the pushed commit (`git status` clean) |
| **Two pre-existing pins re-pointed** (`MobileStarsTests`, `MobileFilterTests`) | **DONE** — see "Two pins this batch had to move" below; both suites re-run green (`✔ Test run with 16 tests in 2 suites passed after 34.870 seconds.`) |
| **Full mobile suite vs 712/102** | **DONE** — `✘ Test run with 725 tests in 103 suites passed after 343.885 seconds with 2 known issues.` (the leading glyph is the runner's for a run carrying known issues; the word is **passed**, and `✘ Test .*failed` greps **0**) |
| **Fence verification** | **DONE** — quoted below: no fenced path touched, `planVisibleTakeEdit` count **0**, tree clean |
| Simulator deletion | **DONE** at the end of the run |
| **THE COLD REVIEW + ITS FIX WAVE** | **DONE (2026-09-01)** — 2 MAJOR · 4 MINOR · 2 NIT, all accepted, all executed; full suite **`✘ Test run with 727 tests in 103 suites passed after 348.273 seconds with 2 known issues.`** (725 + 3 new pins − 1 retired), fences clean. Per-item dispositions and every quoted red: the **FIX WAVE RESULTS** section of `mobile-batch-10-cold-review.md`; what changed in the shipped shape: the table directly below |

**Nothing below is PENDING any more — every count and every "green" is a
quoted run.**

---

## ⚙️ FIX WAVE (2026-09-01) — WHAT CHANGED IN THIS BATCH'S SHIPPED SHAPE

The cold review (`mobile-batch-10-cold-review.md`) landed 2 MAJOR, 4
MINOR, 2 NIT; **all eight were accepted with zero disputes** and one fix
wave executed them. **The per-item dispositions, the quoted reds and the
final suite line live in that file's FIX WAVE RESULTS section** — this
row exists so a reader of THIS record is never told the pre-wave shape as
though it were the shipped one. What moved:

| item | the shipped shape now |
|---|---|
| **MAJOR 1** | The band's release **SETTLES** — one `MobileShellView.settle` spring on `selectPage` (both roads) and on the drag's reset transaction. The animation itself is not observable in this harness and is DECLARED so rather than pinned. |
| **MAJOR 2** | A door's refusal renders **beside the doors**, not in the header: `MobileBookViewModel.doorRefusal` is its own slot, `lastError` keeps the store read. Pinned on a mounted twelve-note finished book, measured against the door's own frame. |
| **MINOR 1** | The live drag is `@GestureState`, so a CANCELLED pan can no longer strand the shell mid-page. The latch stays view state (it must be readable in `onEnded`); what a stale latch can still cost is stated in the results. |
| **MINOR 2** | The named chapter gap below now has a **home outside this file** — `mobile-round-2-status-2026-09-01.md` §C's YOUR RULINGS row. |
| **MINOR 3** | A5-8 is now **driven on the mounted shell**, and the reviewer's kept-text reading is explained (it is the activation's own turn — the filing is a `Task`, and navigation never waits on a write). |
| **MINOR 4** | A chapter whose notes fell past the window **folds** under the standing truncation marker; a genuinely empty chapter still renders (the section "EMPTY CHAPTERS NOW RENDER" below carries the amendment). |
| **NIT 1 / NIT 2** | The dead `starredRows` layout parameter is retired (guarantee pin re-derived: 602 states); `MobileShellBand.offset` gains the `width > 0` guard, pinned. |

**Pins after the wave:** `MobileNavigationTests` **16** (13 + 3 new);
`MobileShelfLayoutTests` **−1** (`starredRowsRideInsideTheBound`, whose
subject left the shelf).

---

## MACHINERY — the restart, and what survived (protocol §7)

The Claude Code process **exited and restarted mid-batch**, between the
red-on-old wave and its second wave. What survived: **the working tree**
(all three deliverables, all pins, the eight-revert restore already
diff-verified byte-exact). What did NOT: the **scratchpad** — `b10-dd`
(derived data) and `b10-prerevert/` were both wiped, and the simulator
`b10-nav` was left shut down but not deleted.

**What the continuation adopted, and the one correction it had to make:**
revert **R9** (the flick's direction-agreement clause) was still applied
to `MobileShellBand.swift` when the process came back — the scratchpad
copy that would have restored it was gone, so it was **restored by hand
from the known original** and re-verified by reading the file. Nothing
else in the tree was mid-revert: the R1–R8 restore had completed and
diff-verified before the death.

The **checkpoint protocol** (`notes/SessionResiliencyProtocol.md`, read
from the main checkout) binds from here: commit per coherent piece, push
`origin mobile` after every commit, this section current in the same
commit, foreground waits only.

**Environment (rebuilt after the restart):** simulator `b10-nav` —
**iPhone 17 Pro / iOS 26.2**, UDID
*[removed for publication]*
the 18.3 runtime is the INVALID 16-series one the brief fences),
`ApplicationAccessibilityEnabled` armed and **read back `1`**, private
`-derivedDataPath` at `<scratch>/b10-dd`. Pre-revert copies go in
`<scratch>/b10-prerevert/` — uniquely mine; no other batch's
`prerevert/` dir was read or written.

---

## THE IN-BATCH FORK, ANSWERED WITHOUT A STOP

The brief: *"Both stacks must STAY ALIVE exactly as today … if the
paging container would tear a stack down, STOP AND PROPOSE."*

**No paging container is used, so the fork does not arise.** The shell
keeps its `ZStack` of always-constructed `NavigationStack`s and the band
is ARITHMETIC — an X offset per page, from the pure brain
`MobileShellBand`. Every stack is built by the same code, in the same
order, with the same modifiers as before this batch; the only per-stack
modifier that changed is that `opacity(tab == x ? 1 : 0)` became an
`offset(...)` (a neighbour is hidden by being one screen away, which is
what lets a drag reveal it). `allowsHitTesting` and `accessibilityHidden`
are unchanged in kind.

`TabView(.page)` was NOT used deliberately: its offscreen-page lifetime
is not a documented guarantee, and "the A2 liveness world and the
quick-note box's lifecycle ride on it" is exactly the thing that must not
depend on an undocumented one.

---

## D1 · THE SWIPE — files, shape, and what is pinned where

**New:** `App/Variorum/VariorumMobile/Features/Shell/MobileShellBand.swift`
(pure brain) · **changed:** `MobileShellView.swift`.

- **The arrangement (PROVISIONAL — the architect's ruled shape):**
  `Starred ‹ Shelf › Library`, shelf at home. `MobileShellBand.pages`
  owns it; `MobileTab` gains a third case and stays a plain identity.
- **The tab bar gains a third door**, in band order, so the bar IS the
  band's index — authoritative (a tap selects) and in sync (a swipe moves
  the same state).
- **ONE ROAD:** `selectPage(_:)` is the tab door's old body, lifted, and
  the swipe calls it too. Both halves ride: **A5-8** (leaving files the
  quick-note box) and the **liveness handoff token minted
  synchronously** in the same turn as the `tab` assignment (the S3 ladder
  BLOCKER + the review's MAJOR 2 ordering). A swipe that skipped either
  would have been a quieter second version of the tab door.
- **Root surfaces only:** `pagingAllowed` is false whenever the visible
  stack has anything pushed, and the gesture's `including:` mask drops to
  `.subviews` — so inside a note the editor's horizontal gestures and the
  system back-swipe never share a screen with the band.
- **The 13e jitter rider:** ONE named coordinate space,
  `MobileShellBand.coordinateSpace`, read by both the
  `.coordinateSpace(name:)` modifier and `DragGesture(coordinateSpace:)`.
  No `.local`/`.global` mixing anywhere in the new math.
- **The direction latch** (`engages`) decides once per gesture and is not
  re-asked, so a vertical scroll can never become a page mid-drag; the
  ends of the band are **walls, not rubber** (`clampedDrag`).

### What the harness honestly reaches — stated, not blurred

**A real pan cannot be synthesized in process.** `accessibilityActivate()`
is UIKit's activation dispatch, not a touch stream, and there is no
in-process road to a `DragGesture`'s recognizer (the same limitation
`MobileSurfaceDriver`'s header already records for `Menu` rows and
`UIAlertController` buttons). So the swipe is pinned **at both ends and
not in the middle**:

- its **arithmetic** — the latch, the walls, the landing — as a pure
  brain, revert-verified;
- the **seam it calls** — `selectPage`, driven for real through the tab
  bar's own doors on the **real mounted `MobileShellView`**.

**The gesture RECOGNITION itself — that a finger on the shelf reaches
this brain, and that a vertical scroll does not — rides the device
queue.** That is the honest gap, and it is the one thing in D1 a
simulator cannot answer.

### 🔎 A HARNESS FINDING, worth the cold reviewer's attention

Writing the mounted pin measured something no previous batch had cause
to: **`MobileSurfaceDriver`'s walk descends raw `UIView.subviews` and
does not honour `accessibilityElementsHidden`, so ALL THREE roots stay
in the walked tree** even though the product marks the two offscreen
pages hidden and untouchable. Assistive technology sees one page; this
walker sees three (measured — the label list carried the Library's
filters, the Starred page's empty line and the Shelf's doors at once).

**Consequence, stated because it outlives this batch:** on a
SHELL-mounted surface, "which page is showing" is not answerable from the
label list, and an absence pin taken there would be measuring the walker
rather than the app. This batch's own absence pins mount INDIVIDUAL root
views (`MobileShelfView`, `MobileBookView`), where no other page exists,
so none of them is affected. **Not fixed here:** `MobileSurfaceDriver` is
shared test infrastructure and changing its walk could flip other
batches' pins in either direction — that is a decision with a blast
radius, not a drive-by. Recorded for the reviewer.

The mounted pin therefore asserts the **selection** (`.isSelected` moving
across the three doors), which is exactly the brief's *"the tab bar stays
authoritative and stays in sync"*, and is the single input to the offset
arithmetic pinned beside it.

---

## D2 · THE STARRED PAGE — a face over the existing star

**New:** `MobileStarredView.swift` · **changed:** `MobileStars.swift`,
`MobileShelfView.swift`.

- **NOTHING BOOK-SHAPED WAS BUILT** — her fence (*"add smart book of
  starred notes to the 13i phase and don't build it yourself"*). No new
  core query either: the page reads the SAME `Queries.starred` through the
  SAME `MobileStarsModel` the retired shelf section used.
- **The rows MOVED, they were not copied** (MobileSoul §3): the shelf's
  `starredRow` is gone from `MobileShelfView` and lives on the new page.
- **P1 without a window, deliberately:** the list is bounded by the DATA
  — `Operations.setStarred` refuses past `Operations.starLimit` (5) and
  `Queries.starred` returns live targets only, which is the argument
  `MobileStarsModel.start()` already makes for its own observation. A
  render window over a list that can never reach it, and a marker that
  can never render, would be the dead guard the 6c cold review named
  (m3: *"a dead guard reads as a rule and is not one"*). **Recorded as a
  deliberate call rather than drawn.**

### THE OLD PLACEMENT — RETIRED (the brief's required statement)

**Retired**, because the new face replaces its job whole. Her words are
about the placement (*"I don't like where it appears above the shelf, I
think it's awkward placing"*), and leaving it would have ignored her
while adding a second home for one list.

Three consequences, all deliberate:

1. **The shelf now passes `starredRows: 0`** to `MobileShelfLayout.split`.
   The BRAIN is untouched and **her writing-floor guarantee still spans
   every value of that parameter** — `theWritingFloorIsAGuaranteeInEvery
   ShelfState`, 2,408 states, unmodified and riding green. What changed
   is what this caller has to tell it, not the rule. *(PROVISIONAL: the
   parameter now has one live caller value. Removing it would change the
   pin's own `checked == 43 * 7 * 4 * 2` assertion, so it was left alone
   — the honest smaller change.)*
2. **`MobileShelfView.onOpenNote` went with the rows that were its only
   caller** (four test construction sites updated mechanically).
3. **The cap refusal was re-pointed — a bug-class fix, not a re-wording.**
   It said *"un-star one in the starred list at the top of the shelf"*
   and would have sent her to a place that no longer exists. It now names
   `MobileStarsModel.pageName`, the one symbol the tab door and the path
   line also read.

**What STAYS on the shelf:** the book row's own star DOOR (long-press)
and the star refusal's message slot — the door still fires there.

### PROVISIONALs on this page

- **It lists BOTH kinds** (notes and books), because that is what a star
  IS here (`StarTarget` covers `.post` and `.reading`, and shelf book
  rows have carried a Star door since parity C3). Her sentence says
  *"starred notes"*; showing only notes would strand every starred book
  with no surface at all — see-your-data inverted.
- **The tab bar's third door** (vs. two doors with `Shelf` lit while
  Starred shows). The bar would otherwise name a surface that is not on
  screen, and a swipe-only page is unreachable for a VoiceOver user.
- **`DoorHome.starred`** joins D2's rule: a refusal fired here speaks
  here, and only here.
- The path line carries **no doors** (nothing is minted on this page; the
  P38 crowding lesson).

---

## D3 · NEW NOTE + NEW CHAPTER INSIDE A BOOK

**Changed:** `MobileBookView.swift`, `MobileBookViewModel.swift`.

- **`+ New Note` rides `newPostInReading`** — the Mac's own door
  (`BookStructureModel.newPost`, R62/R75) through the Mac's own
  operation. **This is the refuse-before-mint doctrine in its strongest
  form:** the gate (missing · wrong kind · locked · at capacity) is
  checked INSIDE the same transaction, BEFORE `insertPost` runs, so a
  refusal cannot leave a stray note behind — it is not a pre-check that
  could race. *(The brief names `assertReadingAcceptsPosts`; that op is
  the same gate WITHOUT a post, for doors that must mint separately.
  Calling it here as well would be a second read of the same facts.)*
  The minted note **opens for writing** (`onOpenForWriting`).
- **`+ New Chapter` rides `createSection`** — curated-only and
  locked-refusing by the operation's own guards. The alert is the Mac's
  words: **"New Chapter" / "Name" / "Create" / "Cancel"**, with the blank
  name gated at the face (the rename door's rule, C2 ladder R1-3).
- **No undo entry is registered by either door**, because neither op
  registers one and neither should: `newPostInReading` is `createPost`'s
  class, and chapters are the tags/locks class where the recovery door
  (`restoreSection`) IS the inverse (AppSpec §9). **Verified at the ops,
  not assumed** — `Operations+Sections.swift` registers nothing.
- **Refusals speak the family's voice** by FORWARDING to
  `MobileMembershipModel.refusal` (*"“Poems” is finished — reopen it to
  change what's in it"* / *"is at its note cap."*), never a second copy
  of those sentences — the `MobileBookDetailsModel.refusal` forwarder is
  the precedent.

### THE TWO RENDER RULES, and the deliberate split between them

- **A SMART book: both doors ABSENT** (P-2). Derived membership has no
  row to mint and chapters are refused by model rule, so neither could
  ever mean what it says — the permanent case, the `showsDailyDoor`
  precedent.
- **A FINISHED book: the doors STAY and REFUSE.** Finished is a
  reversible state with its Reopen row one tap away in Details; a door
  that vanished when she finished a book would explain nothing.
  **This diverges from the Mac deliberately** (`BookView` hides both on
  `locked`) and follows the brief's own letter — *"refusing under a
  finished book in the family's voice"*. Recorded as a divergence so the
  reviewer sees it was chosen, not missed.
  > **AMENDED at the fix wave (cold review MAJOR 2):** as shipped in this
  > batch the refusal rendered in the HEADER, so on a book longer than a
  > screen it spoke where she was not looking — which is the entire
  > justification for keeping the doors. The refusal now renders
  > immediately beneath the doors (`doorRefusal`, its own slot), and the
  > divergence is honest as written.

### EMPTY CHAPTERS NOW RENDER — and why that was owed

The phone's contents list is the book's **only** chapter surface (there
is no navigator to put an empty chapter in), and the assembly emits no
row for a chapter with no notes. So a `+ New Chapter` press would have
created a real row **she could not see** — fire-and-DO (R115) dressed as
a success.

`MobileBookViewModel.grouped` therefore gained the chapter half the Mac's
`BookStructureModel.grouped` and `Queries.exportReading` already have,
**resolving by `sectionID` rather than by name** (chapter names have no
uniqueness — AppSpec §7 — so a name-keyed merge would fold two chapters
called "Openings" into one). The chapters ride the SAME held observation
as the entries (`Queries.readingSections`, author-scale, skipped entirely
on smart books), so the list and its chapters cannot disagree. The
pre-existing `theBookListGroupsByTheAssemblysOwnSections` pin rides
unmodified as the regression guard.

> **AMENDED at the fix wave (cold review MINOR 4):** teaching an empty
> header to MEAN "this chapter is empty" made the bounded window lie —
> `grouped` fills a chapter from the WINDOWED entries, so past the 300-note
> cut every chapter looked empty too. The model now also reads which
> chapters hold a member ANYWHERE (one `DISTINCT`, book-scoped, on the same
> held observation, and **only when the probe row says the window really
> cut something**); a chapter with no windowed entry and a member folds
> under the standing truncation marker, and the genuinely empty one still
> renders, which is what this section is about.

### 🚩 A NAMED GAP, for the reviewer and the parity ledger

**The phone has no assign-to-chapter door**, so a note minted by
`+ New Note` lands **unsectioned**, and a chapter created here can be
filled only from the Mac. The chapter is visible and real; it is not yet
fillable on the phone. **Not built here deliberately** — `assignPostToSection`
has no phone face at all, and `newPostInReading` already takes a
`section:` argument, so the mechanism is one argument away, but *where*
that door lives (a per-chapter trailing `+ new note`? the membership
sheet? a drag?) is a design call and inventing one is the thing the
guardrails forbid. **PROVISIONAL, and the obvious next step is named
rather than left to be rediscovered.**

> **✅ GIVEN A HOME at the cold review's MINOR 2 (fix wave, 2026-09-01).**
> The reviewer's point was that a gap recorded only in a batch record is
> recorded in a file that CLOSES — the KnownIssues owner rule's own
> failure shape, and this round's Fable-sweep finding 3 all over again.
> It is now a row in **`notes/plans/mobile-round-2-status-2026-09-01.md`
> §C's "YOUR RULINGS"**, which is the document the resume session reads:
> the placement is HERS (three candidates named), the mechanism note
> rides with it, and nothing about it is a build decision an implementer
> could take alone. **PROVISIONAL stands; it is now provisional somewhere
> a planning session looks.**

---

## PINS — `App/Variorum/VariorumMobileTests/MobileNavigationTests.swift`

**ONE suite in the file, deliberately** — the harness trap the round
records (`MobileTakesBrowserTests.swift` declares two, and filtering by
the first name silently runs a subset).

13 tests. **13/13 green before the restart; re-verification PENDING on
the rebuilt simulator.**

### Red-on-old — reverts R1–R8, applied together, each red attributed by its own test

Every revert is BEHAVIOURAL (production code, named below), never a test
edit. All eight were applied in one pass **because each affects exactly
one test**, and the runner attributes every failure by name. Verbatim
reds:

| revert (production) | test that went red | quoted red |
|---|---|---|
| **R1** `MobileShellBand.engages` — drop the ratio clause | `aVerticalScrollNeverEngagesTheBand` | `Expectation failed: !(MobileShellBand.engages(CGSize(width: 20, height: 200) → (20.0, 200.0)) → true)` (+2 more) |
| **R2** `MobileShellBand.clampedDrag` — `return raw` | `theBandsEndsAreWallsNotRubber` | `Expectation failed: (MobileShellBand.clampedDrag(120, current: .starred, width: width) → 120.0) == (0 → 0.0)` (+2) |
| **R3** `MobileShellView.tabBar` — the pre-batch two doors | `theTabBarCarriesThreeDoorsAndEachOneMovesTheBand` | `Expectation failed: (surface.element(labeled: door) → nil) != nil` · `…activate("Starred")` · `(selection(surface, "Starred") → (copies: 0, …)).allSelected → false` |
| **R4** `MobileStarsModel.capRefusal` — the old sentence | `theCapRefusalNamesTheListThatActuallyExists` | `Expectation failed: !((refusal → "You can star 5 things at a time — un-star one in the starred list at the top of the shelf, …").contains("shelf") → true)` (+1) |
| **R5** `MobileShelfView` — the starred rows restored above the books | `theStarredListLivesOnItsOwnPageAndNotAboveTheShelf` | `Expectation failed: !(labels.contains { $0.lowercased().contains("harbor") } → <not evaluated>)` |
| **R6** `MobileBookViewModel.grouped` — run-clustering only | `aNewChapterShowsInTheContentsEvenBeforeItHoldsAnything` | `Expectation failed: (groups.map(\.section) → [Optional("Openings")]) == ([…] → [Optional("Openings"), Optional("Openings"), Optional("Endings")])` (+1) |
| **R7** `MobileBookViewModel.showsBookDoors` → `true` | `aSmartBooksContentsCarriesNeitherDoor` | `Expectation failed: !((labels → ["everything essays", "Collected", "+ New Note", "+ New Chapter"]).contains("+ New Note") → true)` (+1) |
| **R8** `MobileBookViewModel.newNote` — mint FIRST, then add | `aRefusedBookDoorMintsNothingAndSpeaksTheFamilysVoice` | `Expectation failed: (after.containers → 1) == (before.containers → 0)` |

**R8 is the brief's own required assert, and it fired exactly as
predicted:** the mint-then-add shape leaves a **stray container** behind
a refused add on a finished book (1 vs 0), and `newPostInReading`'s
in-transaction gate is what makes the shipped door mint nothing.
`theBooksNewNoteDoorMintsInsideItAndOpensForWriting` stayed GREEN under
R8 — correctly: an unlocked curated book mints either way — so R8's red
is precisely the gate and nothing else.

The eight files were restored from `b10-prerevert/` and **diff-verified
byte-exact** (`diff -q` on all six production files, zero differences).
No `git checkout --` was used on any file this batch edits.

**R9 — re-run after the restart, its own wave, and it went red:**

| revert (production) | test | quoted red |
|---|---|---|
| **R9** `MobileShellBand.landing` — drop the flick's direction-agreement clause (`(predictedEnd < 0) == (drag < 0) && drag != 0`) | `aDragLandsOnlyWhenItCrossesOrIsFlicked` | `Expectation failed: (MobileShellBand.landing(current: .shelf, drag: -20, predictedEnd: 400, width: width) → .library) == .shelf` ↳ *"A flick whose projection contradicts the finger lands nothing."* |

Without the clause a finger that dragged 20 pt LEFT and was projected 400
pt RIGHT — a spring-back — landed the band on the page it had been pulled
away from. Restored and re-verified: the six production files are
byte-exact against both the prerevert copies and the pushed commit.

### Pins that pass on BOTH sides — DECLARED, not manufactured

- `theBandPutsTheShelfAtHomeBetweenStarredAndLibrary` — the arrangement
  and the offset arithmetic are **definitional**; a "revert" would only
  be a different definition.
- `theBookDoorsSpeakThePhonesOwnWords` — word pins.
- `aStarRefusalFromTheStarredPageSpeaksOnlyThere` and
  `theBooksNewNoteDoorMintsInsideItAndOpensForWriting` are
  **new-capability** pins: on the genuine pre-batch tree the page and the
  door do not exist at all, so their red-on-old is the feature's absence
  rather than a guard's removal. Stated as such.

### What is pinned at the model act rather than at the door

The starred page's **Unstar** rides a `.contextMenu`, which the driver's
header records as undrivable in process — the same shape the shelf's and
the Library's star doors have shipped with since parity C3. The ACT is
driven through `MobileStarsModel.toggle(_:from:)` for real, including
the cap refusal's home.

---

## TWO PRE-EXISTING PINS THIS BATCH HAD TO MOVE — and why each is honest

The first full-suite run came back **725 tests in 103 suites** (the
baseline 712/102 plus exactly this batch's new file) **with 4 issues,
2 of them the documented known ones** — so two real regressions, both
mine, both a direct consequence of a deliberate change rather than a
defect:

1. **`MobileStarsTests.theCapRefusalSpeaksPhoneWords`** asserted the
   refusal `.contains("top of the shelf")`. That is the road this batch
   RETIRED at her word. **The rule the pin was written to protect is
   untouched and is what it still asserts** — the refusal names a road
   that exists on the phone, never the Mac's sidebar — and it now names
   `MobileStarsModel.pageName`, with a new clause asserting the sentence
   no longer says "shelf" at all. *(A pin encoding the old road is
   exactly what a deliberate copy change is supposed to trip.)*
2. **`MobileFilterTests.theShellGivesTheLibraryTheShelfsOwnBooks`** drove
   `surface.activate("library")` — lowercase, because the tab door's
   label used to be its voice-cased chrome TEXT and `withEditorWorld`
   fixes the voice to terminal. This batch gave the tab doors an explicit
   `accessibilityLabel` (the `+ New Note` precedent), so an assistive
   reader hears the same proper noun in both voices. The pin follows the
   door: same act, same door, the name it is actually called.

Both were re-run and are green. **No other pin in the suite moved**, and
neither edit weakened an assertion — one changed which road it names, the
other which spelling of one door it drives.

## FENCES

**VERIFIED over the batch's three commits** (`9a515b7`, `f7c4937`,
`2a579cf` — the two orchestrator doc commits that interleaved on this
branch are deliberately excluded):

```
=== FENCE GREP (must be EMPTY) ===
EMPTY — no fenced path touched

=== planVisibleTakeEdit in the batch diff (must be 0) ===
0

=== working tree clean? ===
CLEAN
```

**Every file this batch touched, all fourteen:** seven under
`VariorumMobile/Features/Shell/` (two of them new — `MobileShellBand`,
`MobileStarredView`), six under `VariorumMobileTests/` (one new —
`MobileNavigationTests`), and this record. **ZERO** under `Sources/`,
`App/Variorum/Shared/`, `App/Variorum/Variorum/` (Mac), `EditorBrain/`,
schema, build configs or `Package.resolved`. The Mac's `BookView.swift`
and `BookStructureModel.swift` were read **READ-ONLY** for wording and
op parity, and nothing else outside the fence was opened for writing.

## THE SUITE

```
✘ Test run with 725 tests in 103 suites passed after 343.885 seconds with 2 known issues.
```

**725/103 against the 712/102 baseline = +13 tests, +1 suite: exactly
this batch's `MobileNavigationTests` and nothing else.** The 2 known
issues are the documented diagnostic
(`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAs
AnAbsentDoor`, which records issues deliberately), unchanged from the
baseline; `✘ Test .*failed` greps **0**. The load-flaky perf pin
(`MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`)
did **not** red on either full run, so no isolated re-run was owed.

*(The first full run came back with two failures — both this batch's,
both deliberate consequences, both fixed and re-run green; the section
above records them rather than hiding them behind this clean line.)*

---

## FOR THE COLD REVIEWER

1. **The harness finding above** (`accessibilityElementsHidden` is not
   honoured by the driver's walk) — it is not this batch's to fix, and it
   changes what a shell-mounted absence pin can claim.
2. **The finished-book divergence from the Mac** (doors stay and refuse
   vs. the Mac hiding them) — chosen per the brief's letter.
3. **The unsectioned-mint gap** — a chapter created on the phone cannot
   be filled from the phone yet.
4. **`starredRows: 0`** — a brain parameter with one live caller value,
   left in place so her 2,408-state guarantee pin rides unmodified.
5. **R9's re-run** — the one owed piece of red-on-old.
