# The Library filter batch — KIND FILTERS + THE ARCHIVE'S INHERITED SET · the record

*(built 2026-08-31; the brief is `notes/plans/mobile-batch-filters-brief.md`;
her rulings are QUESTIONS **#85** and **#92**)*

**Read in full before a line was written:** `CLAUDE.md` · `notes/MobileSoul.md`
§2–§4 (+ the ledger rows this touches) · `notes/QUESTIONS.md` #84/#85/#92 ·
`notes/plans/mobile-batch-6c-record.md` + `-cold-review.md` (the rooms this
lands on, and the FIX WAVE RESULTS baseline) · the code:
`MobileLibraryView.swift`, `MobileLibraryViewModel.swift`,
`MobileArchiveView/Model.swift`, `MobileShelfView/ViewModel/Faces.swift`,
`MobileShellView.swift`, `MobileTrashView.swift` (the app's own kind-filter
grammar), `MobileRecoveryDoors.swift`, `MobileScraps.swift`,
`MobileSurfaceDriver.swift`, `MobileKeyboardBarGeometryTests.swift` (the 4.5d
width-measurement discipline), and the core reads —
`Sources/VariorumCore/Queries/ShelfQueries.swift`, `Timeline.swift`,
`Observations.swift`, `Trash.swift` — plus
`Sources/VariorumCore/Persistence/Migrations.swift` for deliverable 5's model
fact (READ only; the fence forbids writing there).

*(Sections below are written as the work lands.)*

---

## 0. THE MODEL FACT deliverable 5 demanded be verified FIRST

**`reading` carries NO `archived_at`. Verified at the schema, not assumed.**

`Sources/VariorumCore/Persistence/Migrations.swift:597-615` — the `v1_core`
`CREATE TABLE reading` — carries `locked`, `created_at`, `updated_at`,
`deleted_at`, `sync_version` and nothing else lifecycle-shaped; the only later
`ALTER TABLE reading` in the whole file is `:374`, `word_target` (v1_11).
AppSpec §7's `reading` DDL agrees exactly. So **a book can be FINISHED or
DELETED; a book cannot be ARCHIVED.**

Consequence, and it is why this batch did not simply mirror the Library's row
into the Archive room: **an Archive "books" door could never have content** —
the P-2 class (*a door that cannot act is not rendered*), and the strongest
form of it, since no future row could arrive without a schema change.

Two more doors fail the same test in that room, for a different reason —
**no core query exists to feed them**, and inventing one is a fenced change
this batch must not make (deliverable 6):

- **`bookless` in the Archive.** `Queries.poolPosts` is the bookless read and
  its own WHERE clause excludes archived posts
  (`ShelfQueries.swift:205` — `c.archived_at IS NULL`). There is no
  archived-and-bookless read. *(And it could not be composed row-by-row in the
  face: membership per post is `readingsContaining`, one query per row.)*
- **`scraps` in the Archive.** The only archived-block read in core is
  `Queries.archivedBlocks(_:postID:limit:)`
  (`Trash.swift:530`) — **per-NOTE by signature**, the tray's feed. There is
  no global archived-blocks listing.

And the room's own listing is notes by construction:
`Queries.archivedPosts` (`Timeline.swift:224-250`) reads
`WHERE kind = 'post' … AND archived_at IS NOT NULL`. **That matches the Mac's
post-13l ruling — Archived is NOTES only** — so the phone matches it rather
than inventing an archived-books surface.

**Logged for her as a QUESTIONS candidate (nobody's to improvise):** if she
ever wants book-archiving, `reading.archived_at` is a schema event — an
additive migration AND a SyncSpec §12 lockstep event — never a face.

## 1. What landed, per deliverable

### D1 · THE ONE FILTER BRAIN ✅

**`MobileListingFilters.swift`** (new) — declaration + renderer, serving BOTH
rooms, which is her §10.2 note's letter (*"one filter brain, not two"*):

| | the declaration | the renderer |
|---|---|---|
| what | `MobileListingFilter` (`all · books · notes · bookless · scraps`), its per-room door sets, ~~`isNoteListing`~~ *(deleted at the fix wave — m3)*, the books listing's empty line | `MobileFilterRow` — plain `Button` doors, one visible row, a `@ViewBuilder` trailing slot |
| also | `MobileSortDoor` (the glyph + the spoken verb, a DECLARATION not a view — the `MobileRecoveryDoors` precedent) | an `EmptyView` convenience init for the Archive's trailing-less shape |

`MobileLibraryViewModel.Filter` became a `typealias` of it, so no call site had
to learn a second word for the same thing and the three shipped doors kept
their names.

**PHONE-LOCAL IS CORRECT HERE — stated as a judgment, not a default.**
MobileSoul §3 says brains live in `VariorumCore`/`Shared/` and platforms own
faces, but that rule's test is whether a Mac twin exists to drift from. **There
is none:** the Mac reaches these listings through its SIDEBAR (Shelf · Library ·
Pool · Blocks · Archived — R44 + the post-13l Archived ruling), a different
mechanism entirely, not a filter row. Hoisting would move a phone face into a
shared home and buy no parity. *(If the Mac ever grows a kind-filter row, THAT
phase hoists — the standing §3 direction, written at the file's head.)*

### D2 · THE LIBRARY'S VOCABULARY ✅

The row is now **all · books · notes · bookless · scraps**, with the sort glyph
trailing. Every door was driven on the real surface and every door changes the
listing (`theLibrarysFilterRowCarriesHerFiveDoorsAndEachSwitchesTheListing`).

**No STOP AND REPORT was needed: the row FITS.** See §2's measurements — at
320 pt (Display Zoom, the narrowest the app is ever shown at) the rightmost
door edge lands at **298 pt inside a 300 pt content width**, with every door at
its full size in both voices. No door was dropped and none had to be.

One structural call beside the doors: **the Archived trailing row now renders
under NOTE listings only** (`all · notes · bookless`). It opens archived NOTES,
and §0's model fact says a book can never be archived — so trailing the books
listing with it would be a door pointing where its own listing cannot go.
Pinned (`theArchivedDoorTrailsNoteListingsOnly`).

### D3 · BOOKS AS ROWS (#92(a)) ✅

Filtering to **books** lists her books as openable rows, through the EXISTING
`MobileShelfFaces` brain — never a second row-rendering rule:

- **name** = `MobileShelfFaces.name` (the stored name plus the finished " ✓"
  state), **meta** = `MobileShelfFaces.meta` (LK5's order: count · tags ·
  daily), **order** = `MobileShelfFaces.ordered` (pins, then journals, then
  names) — so a book sits in the Library exactly where the Shelf puts it.
- **The model is the SHELF's own instance**, threaded by the shell. One held
  observation (`bookshelf` + `shelfPins` + the daily designation) serves both
  surfaces; both tab stacks stay alive by design, so a second model would be a
  second observation over rows the app is already watching. The consequence is
  written at `MobileLibraryView.books`: the held loop belongs to the SHELF
  root's `.task`, so a harness mounting the Library alone must start it (the
  pins do), and a second `start()` in this view would double
  `observationTicks`, which `MobileShelfPerfTests` reads.
- **A row opens the book's CONTENTS** (`onOpen(.book(id))` — P35's ruled
  inversion, the same landing the Shelf's rows have), and the pin asserts the
  ID it carries rather than that something fired (the 6c n10 lesson).
- **Windowed + marker** (P1) — see §3's PROVISIONAL 4 for the fetch/render
  split, which follows `MobileScrapsModel`'s shape.
- **Sort availability unchanged**: the control renders on `.all` only, per the
  brief. PROVISIONAL, logged.

### D4 · THE SORT GLYPH (#92(b)) ✅

The door became `Image(systemName: "arrow.up.arrow.down")` with
`Sort: <current stamp>` as its accessibility label — so an assistive reader now
hears MORE than the old text door said (the verb AND the stamp), while the row
gets ~70–100 pt back. **The menu behind it is byte-unchanged**, and so is its
`.all`-only availability rule.

Driven: the label carries the whole verb, the menu really presents, a sort
really applies (the listing re-orders and the door re-speaks its stamp), and
the door is absent under every other filter. Measured: §2.

### D5 · THE ARCHIVE INHERITS THE SET ✅ — with §0's model fact first

The Archive room renders **the same component** in the gap 6c left for it, with
the door set narrowed to `[.all, .notes]` — the doors whose kind CAN exist
there. The three absent doors are absent by the traced facts in §0
(`reading` has no `archived_at`; no core read exists for archived-and-bookless
or for archived scraps globally), and the pin asserts their absence **against a
populated world** — a live book and a live scrap exist while their doors do not
render, so the assertion can never pass vacuously.

`MobileArchiveModel` gained `filter` + `visible`. The filter is deliberately
**not pushed into SQL** (unlike the Trash room's): `Queries.archivedPosts` is
`kind = 'post'` by construction, so a predicate would invent a narrowing the
schema cannot have and would be a second copy of the room's own definition.

### D6 · NOT THIS BATCH — honoured ✅

The per-note tray (6b) untouched. **Zero lines** under `Sources/`,
`App/Variorum/Shared/`, `App/Variorum/Variorum/`, `EditorBrain/`, schema or
build configs — verified before the commit (§6). No core query was added: every
listing here reads one that already existed (`bookshelf`, `shelfPins`,
`dailyJournalBookID`, `shelfBookTags`, `library`, `poolPosts`, `poolListing`,
`archivedPosts`).

---

## 2. THE MEASUREMENTS (the flagged risk, answered)

Read off the accessibility frames of the Library's row hosted in a real
`UIWindow` at each width — the 4.5d technique
(`MobileKeyboardBarGeometryTests`), adapted to a SwiftUI surface. The dump is
re-runnable: `MobileFilterRowGeometryTests.theRowsMeasurementsAreOnTheRecord`
prints it under `FILTER-ROW-GEOMETRY`.

**Terminal voice (the worst case — monospaced chrome), doors as `minX…maxX`:**

```
320 pt · large: All=20…41 Books=52…88 Notes=99…134 Bookless=145…202 Scraps=213…256 sort=285…298 rightmost=298
375 pt · large: All=20…41 Books=52…88 Notes=99…134 Bookless=145…202 Scraps=213…256 sort=340…353 rightmost=353
402 pt · large: All=20…41 Books=52…88 Notes=99…134 Bookless=145…202 Scraps=213…256 sort=367…380 rightmost=380
```

- **Everything fits at every width, in BOTH voices**, with the doors in order
  and on one baseline band. At 320 the rightmost edge is **298 against a 300 pt
  content width** (320 − 20 pt padding a side).
- **Nothing is shrunk to fit.** Every door renders at its full ideal width at
  320 — identical to its width at 402 — so `minimumScaleFactor(0.7)` is present
  as the degradation road and is NOT being spent.

**AX sizes — identical at every size, and that is a FONT fact, not a dead
harness:**

```
320 pt · accessibility5: All=20…41 Books=52…88 Notes=99…134 Bookless=145…202 Scraps=213…256 sort=285…298
control · large: width=69      control · accessibility1: width=109
control · xxxLarge: width=90   control · accessibility3: width=155
                               control · accessibility5: width=204
```

The control is a `Text` under the SAME `.dynamicTypeSize`, through the SAME
harness — *(precision, fix wave n9: it is a second hosted window built by the
same helper, not literally the same tree as the row; the experiment is real
and the cold reviewer reproduced it, and the earlier "the SAME hosted tree"
overstated the setup)* — in a font that DOES scale: it grows 69 → 204 pt, so
the setting is reaching the host. The row does not move because `VoiceTokens.small`
is `Font.system(size: 11.5)`, which is **fixed** in SwiftUI (only text styles
and `.custom(…, relativeTo:)` scale).

> **RECORDED FOR HER, not changed here: the app's chrome does not honour
> Dynamic Type at all.** That is a standing tension with MobileSoul §5.6
> (*"Dynamic Type and VoiceOver are phone-native expectations"*), it is
> **PRE-EXISTING for every chrome string on the phone** — nothing in this batch
> caused or worsened it — and making the chrome scale is a look decision across
> every surface, not a filter row's to take. Pinned as it stands
> (`theChromeFontDoesNotScaleAndTheHarnessProvesItIsAsking`), so the day someone
> changes it, that pin says so.

**The spacing this measurement chose: 11 pt.** At 13 (the first value tried) the
320 pt row overflows and SwiftUI shrinks `Bookless` to 46 pt against its 57 pt
ideal — quoted in §4.

---

## 3. PROVISIONALs (for her bundle)

1. **The door says "Notes", not "Posts".** Her #85/#92 said *"posts"* while
   describing KINDS; 13f's K5 sweep renamed post→note in ALL UI strings (the
   model keeps `post`). Shipping the app's own UI noun is the K5-consistent
   reading. **One string** if she re-words it
   (`MobileListingFilter.notes.word`).
2. **`bookless` stays a door.** She called the provenance filters *"less
   useful"*, not wrong, and removing a shipped door is a bigger act than adding
   the kind doors (the R22/R25 precedent: door-count changes are hers). The row
   was measured rather than trimmed, and it fits with the door in it.
3. ~~**`All` and `Notes` show the SAME rows in BOTH rooms — and the
   alternative is hers to rule.**~~ **OVERTURNED by her #93(b), 2026-08-31,
   and BUILT at the fix wave** (verbatim: *"All should be a book + notes
   union - otherwise it just doesn't make sense"*). The shipped answer was
   `.all` = the note listing, chosen to change nothing at rest; the ruling
   takes the alternative this PROVISIONAL itself named — the Trash room's
   own All-is-the-union grammar — and the Library's `.all` now interleaves
   books with notes under the active sort. **The LIBRARY only:** in the
   Archive room the coincidence is FORCED rather than chosen (everything
   archivable there is a note — §0), so that room is untouched by the
   ruling. The interleave's stamp mapping lands PROVISIONAL in its place —
   see the FIX WAVE RESULTS in `mobile-batch-filters-cold-review.md`.
   *(The cold review's m5 folds in here: the batch deleted three Archive
   doors on P-2 grounds while `Notes` sat beside `All` as a visible no-op.
   The ruling ends that in the Library — `Notes` now names one kind where
   `All` names two. **What SURVIVES for her bundle is the ARCHIVE's two
   same-set doors**, which #93(a) has already parked: book archiving is
   13i's, so until that phase rules, that room's `All` and `Notes` name one
   set by a model fact nothing here can change.)*
3b. **The BOOKS listing's truncation sentence — amended at the fix wave
   (m4).** It shipped speaking the filterless rooms' one-number sentence
   (*"Showing the first N."*) though this listing's delivery is WHOLE and its
   exact total is in hand; it now speaks the two-number form
   (`MobileRoomListing.truncationMarker(shown:of:)` — *"Showing the first 2
   of 3."*), which is what its same-surface neighbour, the scraps area,
   already did. **And a PRE-EXISTING silence is recorded rather than fixed:
   the resting NOTE listing (`listingRows`) has no truncation marker at
   all** — `observeLibrary`'s `limit:` cuts silently at 200 — which is not
   this batch's doing and is not this batch's to fix: its home is the
   standing **"Bounded view windows show markers, not more"** row in
   `KnownIssuesAndTechDebt.md`, owner 12.

3c. **A LOOK divergence, chosen rather than missed (n8).** A book's name
   renders `tokens.body` in the Library and `tokens.body.weight(.semibold)`
   on the Shelf. The FACES are one brain (`MobileShelfFaces`) and stay one;
   what differs is weight, and the reason is that the Shelf is a shelf of
   books where a book's name is the row, while the Library is a listing of
   many kinds where a book's name sits beside note titles at the same
   weight. Recorded so a look round has the choice in front of it rather
   than reading it as an oversight.

4. **The books listing's window is a RENDER window, not a fetch window.**
   `Queries.bookshelf` takes no limit and the Shelf holds it unbounded, because
   core's own header calls it author-scale (*"reading rows + counted joins"*).
   So the Library bounds what the SURFACE BUILDS at its `listingLimit` (200)
   and shows the standing truncation marker — the `MobileScrapsModel` shape,
   where `count > window` is exact truth rather than a probe approximation.
   If she ever wants the fetch bounded too, that is a core seam, not a face.
5. **The sort stays a `.all`-only affordance**, per the brief — so `.notes`,
   which shows the note HALF of `.all`'s union *(amended at the fix wave: the
   two doors no longer name one SET, but they still share one ORDER)*, has no
   sort door. One line if she wants it under `.notes` as well; it stays absent under books/bookless/scraps for the
   standing P-2 reason (their orders are the Shelf's and the core queries'
   own).
6. **The Archive room's reduced door set** (`all · notes`) — the narrowing is
   §0's model fact, but *whether a two-door row is worth rendering at all* in a
   room where neither door narrows anything is a taste call. It is rendered
   because #85 asks for the Library's filters there in as many words.
7. **A Library book row carries no acts** — no pin/star/delete long-press,
   unlike the Shelf's row. This is a LISTING, not a second shelf: duplicating
   three acts means duplicating three confirms and two message slots, and the
   Shelf is one tab away. One `.contextMenu` if she wants them.
8. **`MobileShelfFaces.spokenRow`** — the composed accessibility label for a
   book row (`"Aster, 1 note"`, plain-cased). It exists because an explicit
   `accessibilityLabel` REPLACES the composed one, which silently dropped the
   count and tags out of the tree (measured — see §5). The Shelf's own rows
   still use SwiftUI's composed label and therefore speak VOICE-CASED text
   (`"aster, 0 notes"`); aligning them is a one-line change in another
   surface's file and was left alone.

---

## 4. THE PINS, and the reds

**+16 tests, +2 suites** (613/94 → **629/96**), exactly accounted for:
`MobileFilterTests` **10** (new suite) · `MobileFilterRowGeometryTests` **6**
(new suite). *(The fix wave added **3** more into the same two suites — 629 →
**632/96**; its own accounting is in `mobile-batch-filters-cold-review.md`'s
FIX WAVE RESULTS.)*

Four of them are proven by BEHAVIOURAL REVERT, with the failure quoted; the
rest are honestly labelled NEW COVERAGE, because this batch adds capability and
there is no pre-fix tree to revert to.

### RED ON OLD (1) — the spacing that the measurement chose

`doorSpacing` 11 → 13, which is the value the row was first built with:

```
✘ Test noFilterDoorIsShrunkToFitEvenAtDisplayZoom() recorded an issue at
  MobileFilterRowGeometryTests.swift:277:17: Expectation failed:
  (abs(atZoom - wide) → 11.0) <= 0.5
↳ Bookless renders 46.0 pt at 320 against its 57.0 pt ideal — the row is
  spending its scale factor, so re-measure the spacing
✘ Test everyFilterDoorLandsWhollyInsideTheSurfaceAtEveryWidth() recorded an
  issue at MobileFilterRowGeometryTests.swift:248:21: Expectation failed:
  ((ys.max() ?? 0) - (ys.min() ?? 0) → 1.3333333333333357) <= (1 → 1.0)
↳ the row wrapped at 320 pt: [54.0, 54.0, 54.0, 55.333333333333336, 54.0]
```

*(The second red is the same fact from the other side — a scaled label sits a
little lower, so it leaves the row's one baseline band. The pin's message was
re-worded to name both causes.)*

### RED ON OLD (2) — the sort glyph IS the width ruling

> **⚠️ CORRECTED 2026-08-31 at the fix wave (the cold review's M1), and the
> correction is the point.** The reds quoted below are real, but the revert
> that produced them edited **the TEST FIXTURE, not production**: at the time
> this section was written, *every* geometry case measured a hand-built
> `Image` inside `MobileFilterRowGeometryTests.libraryRow`, and the shipped
> door — `MobileLibraryView.sortMenu`, a SwiftUI `Menu` — was measured by
> nothing. So the sentence *"the shipped text door put back as the `Menu`'s
> label"* describes a production edit these pins could not have seen.
> **Proven at the fix wave, both directions:** reverting PRODUCTION's
> `sortMenu` to the text door leaves all three component cases GREEN, and
> reds only the new real-surface case
> (`theRealLibrarysRowFitsWithoutShrinkingAtDisplayZoom`, 5 issues — quoted
> in this file's FIX WAVE RESULTS). **The standing rule this cost:
> a red-on-old claim NAMES what was reverted, production or fixture, every
> time.** *(The reviewer's speculative tail — that a real `Menu` might report
> a ≥44 pt hit region and spend the row's scale factor — was FALSIFIED by
> measuring it: the shipped door reports **16.0 pt**, ending flush at x=300
> inside a 320 pt surface, and no layout fix was owed.)*

The shipped text door (`Text(chromeLabel("sort: last touched"))`) put back as
the FIXTURE `Menu`'s label. **Its accessibility label is unchanged by that
revert** — the modifier overrides the composed one either way — which is
exactly why a LABEL pin could not have seen this and a WIDTH pin can:

```
✘ Test theSortDoorMeasuresAsAGlyphRatherThanASentence() recorded an issue at
  MobileFilterRowGeometryTests.swift:318:17: Expectation failed:
  (sort.width → 42.666666666666686) <= (30 → 30.0)
↳ the sort door measures 42.666666666666686 pt at 320 pt — #92(b) shrank it to
  a glyph, and the longest stamp word it used to draw is "last meaningful edit"
✘ … (sort.width → 71.33333333333331) <= (30 → 30.0)   [375 pt]
✘ … (sort.width → 99.66666666666663) <= (30 → 30.0)   [402 pt]
✘ Test theSortDoorMeasuresAsAGlyphRatherThanASentence() failed after 1.310
  seconds with 3 issues.
```

and the knock-on, which is the ruling's own reason:

```
✘ Test noFilterDoorIsShrunkToFitEvenAtDisplayZoom() … (abs(atZoom - wide) →
  22.333333333333343) <= 0.5      [Bookless, at 320]
✘ …                               (abs(atZoom - wide) → 3.666666666666657)
```

### RED ON OLD (3) — the Archive's door set is narrowed for a reason

`archiveDoors` pointed at `libraryDoors` (the naive reading of *"the same
filters"*):

```
✘ Test theArchiveRoomInheritsTheRowNarrowedToWhatCanExistThere() recorded an
  issue at MobileFilterTests.swift:434:17: Expectation failed:
  !((labels → ["~/archived", "kept — no clock", "All", "Books", "Notes",
  "Bookless", "Scraps", "Set aside", "Unarchive", "Open note"])
  .contains(MobileListingFilter.books.word → "Books") → true)
↳ an Archive books door renders, and a book can never be archived
✘ … .contains(MobileListingFilter.bookless.word → "Bookless") → true)
✘ … .contains(MobileListingFilter.scraps.word → "Scraps") → true)
✘ Test theArchiveRoomInheritsTheRowNarrowedToWhatCanExistThere() failed after
  2.258 seconds with 3 issues.
```

### RED ON OLD (4) — the shell really hands over the SHELF's model

`books: shelfModel` → `books: MobileShelfViewModel(session: session)`, the
plausible mistake (a fresh model reads right and observes nothing, because the
held loop belongs to the shelf root's `.task`):

```
✘ Test theShellGivesTheLibraryTheShelfsOwnBooks() recorded an issue at
  MobileFilterTests.swift:541:17: Expectation failed:
  surface.visibleLabels.contains { $0.hasPrefix("Aster") }
↳ the shelf's books never reached the Library — labels were ["~/library",
  "Trash", "New Note", "search notes, books…", "All", "Books", "Notes",
  "Bookless", "Scraps", "No books yet.", "shelf", "library",
  "~/shelf  ·  1 book", …, "aster, 0 notes", …]
✘ Test theShellGivesTheLibraryTheShelfsOwnBooks() failed after 4.040 seconds
  with 1 issue.
```

*(The dump is the whole finding in one line: the shelf holds the book and the
Library says "No books yet.")*

### The new-capability pins (behaviour on real mounted surfaces)

Every door below is MOUNTED and ACTIVATED through `accessibilityActivate()`
(§15's trap (b)).

- `theLibrarysFilterRowCarriesHerFiveDoorsAndEachSwitchesTheListing` — all five
  doors present by their plain words, each driven, each listing asserted
  present AND the others asserted absent (a filter that showed everything would
  pass a contains-only pin).
- `aBookRowOpensThatBookAndWearsTheShelfsOwnFaces` — the finished book's " ✓"
  rides its name, the meta line is spoken, and the row opens **that** book (the
  id is asserted).
- `theBooksListingIsWindowedAndSaysSo` — window 2 over 3 books: two rows, the
  third absent, the standing marker rendered.
- `anEmptyBooksListingSpeaks` — an empty shelf says so rather than showing a
  blank page.
- `theArchivedDoorTrailsNoteListingsOnly` — present under notes, absent under
  books, back under notes.
- `theSortGlyphSpeaksItsVerbOpensItsMenuAndReallySorts` — the label carries the
  verb and the stamp; activating the door really PRESENTS a controller; a
  sort re-orders the listing (two notes whose stamps disagree) and the door
  re-speaks. *(A SwiftUI `Menu`'s ROWS stay undrivable in process — the
  harness's own measured finding — so the sort is applied through the model's
  named method and what is pinned is the listing and the door. Stated, not
  blurred.)*
- `theSortDoorRendersOnTheAllFilterOnly` — driven across all five doors.
- `theArchiveRoomInheritsTheRowNarrowedToWhatCanExistThere` — the reduced set,
  the absences against a populated world, and the door acting.
- `bothRoomsSpeakTheSameFilterWordsFromOneDeclaration` — the drift guard: the
  words each room RENDERS are asserted equal to its declared door set, and the
  Archive's are a subset of the Library's.
- `theShellGivesTheLibraryTheShelfsOwnBooks` — the composed road.
- `everyFilterDoorLandsWhollyInsideTheSurfaceAtEveryWidth` ·
  `noFilterDoorIsShrunkToFitEvenAtDisplayZoom` ·
  `theSortDoorMeasuresAsAGlyphRatherThanASentence` ·
  `theArchiveRoomsRowFitsAtEveryWidth` ·
  `theChromeFontDoesNotScaleAndTheHarnessProvesItIsAsking` ·
  `theRowsMeasurementsAreOnTheRecord` — §2.

---

## 5. Two things measured that were not expected

1. **An explicit `accessibilityLabel` on a row REPLACES the label SwiftUI would
   have composed from its children.** Labelling the Library's book rows with
   the name alone (the plain-label rule, applied naively) dropped the count and
   tags out of the accessibility tree entirely — while the Shelf's own rows,
   which set no label at all, still spoke both (`"aster, 0 notes"`). Caught by
   a pin that asserted the meta line was spoken. The fix is
   `MobileShelfFaces.spokenRow`, so the two listings cannot come to say
   different things about the same book. *(It also means the plain-label rule
   and the compose-everything default are in tension on any row that sets a
   label; worth knowing before the next surface does it.)*
2. **The chrome font does not scale with Dynamic Type at all** — §2's control
   measurement. Pre-existing, app-wide, recorded rather than changed.

---

## 6. Fence, verified before the commit

```
git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum \
  "*.xcodeproj" "*.pbxproj" EditorBrain   →  (empty)
```

Files touched: `MobileListingFilters.swift` (new) · `MobileLibraryView.swift` ·
`MobileLibraryViewModel.swift` · `MobileArchiveView.swift` ·
`MobileArchiveModel.swift` · `MobileShelfFaces.swift` (one added face
function) · `MobileShellView.swift` (one wiring line) · tests:
`MobileFilterTests.swift` (new) · `MobileFilterRowGeometryTests.swift` (new) ·
`MobileDeletionTests.swift` + `MobileTrashTests.swift` (the four
`MobileLibraryView(…)` call sites gained `books:`).

## 7. Counts and environment

**Baseline:** the FIX WAVE RESULTS final line in
`notes/plans/mobile-batch-6c-cold-review.md` — *"Test run with 613 tests in 94
suites passed after 180.841 seconds with 2 known issues."*

**This batch's own final line, quoted:**

```
✘ Test run with 629 tests in 96 suites passed after 244.000 seconds with 2 known issues.
** TEST SUCCEEDED **
```

Arithmetic exact: 613 + 16 = 629; 94 + 2 = 96. The **2 known issues are the
same single documented diagnostic test** as the baseline's —
`anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, which records
two issues from one `withKnownIssue` block. ~~No other test records an issue.~~

> **⚠️ AMENDED 2026-08-31 at the fix wave (the cold review's M2 — the line
> above is not a baseline a next session can rely on).** The cold reviewer ran
> the full suite TWICE on this same tree and both runs ended
> `** TEST FAILED **` at
> `MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`
> (**13.169 ms** and **12.936 ms** against a 12.0 ms budget, one with a runner
> restart) — and **2/2 GREEN in isolation** (9.4–10.8 ms, 12–22% headroom).
> **It is the load-flaky class, not this batch's doing:** the fence is
> git-clean and the diff carries zero editor-path lines. It is also the pin's
> **second recorded load-red** — `notes/plans/mobile-round-2.md` §70 already
> logged it as a load artifact of batch 6a, re-run isolated and green.
> **It now has a KnownIssues row** (owner 12, beside `CanvasDragTrackingTests`
> and the Mac `rewriteStrategyLatencies` pin), which is what it was missing:
> its two class-siblings had rows and it did not, so each session that met it
> re-derived the verdict from scratch. **The standing instruction is on that
> row: a red here on a full-suite run is re-run ISOLATED and BOTH results
> reported.**

**Environment:** worktree `~/dev/variorum-mobile`, branch `mobile`. Private
simulator `Variorum-filters` (iPhone 17 Pro, iOS 26.2,
`ApplicationAccessibilityEnabled` armed and read back `1`), private
`-derivedDataPath` under this session's scratchpad; the simulator was **deleted
at the end**. `Package.resolved` did not drift and was never swept. No Release
build, no install, no push; the real store untouched, the live Mac app never
quit.

## 8. For the cold reviewer

- The four reverts in §4 are reproducible from their descriptions; each is a
  one-line edit named there.
- **Push hardest on PROVISIONAL 3** (`All` and `Notes` naming one set). It is
  the batch's one genuinely open product question, it is hers, and the built
  answer was chosen to change nothing she looks at today rather than because it
  is obviously right.
- The Archive's narrowing rests entirely on §0's schema reading. If that
  reading is wrong, the fix is one array
  (`MobileListingFilter.archiveDoors`) and one pin.
- `MobileShelfFaces.spokenRow` is the only face brain this batch added; the
  Shelf's own rows deliberately still use SwiftUI's composed label (§3.8).

## 9. Logged for her — the QUESTIONS candidate deliverable 5 asked for

**Book archiving does not exist and cannot be added by a face.** `reading` has
no `archived_at` (§0), so the Archive room's books door is absent rather than
empty. If she ever wants to set a book aside without deleting it, that is an
additive migration **and** a SyncSpec §12 lockstep event — a phase's work, and
nobody's to improvise. *(Today's near-neighbours: FINISH the book — `locked`,
which the shelf already renders as " ✓" — or delete it, which the Trash holds
for 30 days.)*

---

## HER TWO RULINGS ON THIS RECORD (2026-08-31, verbatim — QUESTIONS #93)

> *"i think the question of book archiving is going to be handled in 13i,
> for the record. All should be a book + notes union - otherwise it just
> doesn't make sense."*

- **§5's book-archiving candidate is OWNED: 13i.** The Archive room's
  two-door set stands until that phase's design sitting rules; nothing
  further is mobile's here.
- **PROVISIONAL 3 is OVERTURNED: the Library's `All` IS the books + notes
  union** (the Trash room's own kind-filter grammar, which the PROVISIONAL
  itself named as the alternative). Builds in this batch's FIX WAVE. The
  one unspecified detail — how a book's stamp interleaves against notes
  under the active sort — lands PROVISIONAL with the build (a book carries
  `created_at`/`updated_at`; map each sort to the book's nearest stamp,
  record the mapping, pin it). The Archive room is untouched by the ruling
  (its union is forced: everything archivable there is a note).
