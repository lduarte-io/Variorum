# Batch 6b — THE PER-NOTE TRAY · the record (built 2026-08-31)

**The brief is `notes/plans/mobile-batch-6b-brief.md`.** The design was fully
ruled before a line was written — `mobile-round-2.md` **§69.3** (the post-13l
polish round's ruled tray, MobileSoul **PL-14(e)** / **PL-11(a)**) — so
nothing here invented product behaviour; what is a call is logged in §3.

Read in full, in this session, before any code: `CLAUDE.md` ·
`notes/MobileSoul.md` §2–§5 + PL-11/PL-14/PL-15 · `mobile-round-2.md` §69–§71
· `notes/plans/mobile-batch-6c-record.md` (incl. its **§1 D5** deviation,
which deliverable 4 flips) · `notes/plans/mobile-archive-trash-design/README.md`
(the whole record, §7 Q8 in particular) · `notes/plans/mobile-batch-5-record.md`
and its cold review's guide NIT · and the code:
`App/Variorum/Variorum/Features/Tray/TrayPanel.swift` (the Mac reference,
READ-only), `Shared/BlockHistoryFace.swift`, `Shared/RecoveryCopy.swift`,
`Shared/RecoveryActs.swift` (all READ-only — fenced), `MobileBlockHistory.swift`,
`MobileTrashView`/`Model`, `MobileArchiveView`/`Model`, `MobileRecoveryDoors.swift`,
`MobileBlockList.swift`, `MobileBlockMenu.swift`, `MobileStructural.swift`,
`MobileLenses.swift`, `MobileWriteView.swift`, `MobileTutorialSeeder.swift`,
`MobileSurfaceDriver.swift`, and the core reads in
`Sources/VariorumCore/Queries/PoolAndTray.swift` + `Trash.swift` +
`LensQueries.swift`.

---

## 1. What landed, per deliverable

### D1 · THE TRAY FACE — §69.3's exact shape ✅

**New file: `App/Variorum/VariorumMobile/Features/Write/MobileNoteTray.swift`**
— `MobileNoteTrayModel` + `MobileTrayRowFace` + `MobileNoteTraySection`.

| | what it holds | the acts |
|---|---|---|
| **Archived** | this note's archived blocks — **kept, forever, NO clock** | Put back (`unarchiveBlock`) |
| **Leaving** | every CLOCKED thing of THIS note: deleted blocks · originals that have MOVED onto a family's clock · its deleted TAKES under a **collapsed-by-default** disclosure | Put back (`restoreBlock` · `PreservedOriginPutBack` · `restoreVariant`) + **Delete Now on a take, confirm-EVERY-time** |
| ~~unclocked originals~~ | **deliberately absent** — her G5 ruling (*the tray audits what is LEAVING; lineage holds what is KEPT*); their home is Block History ▸ Came from, shipped at 6a | — |

- **Reads are core, unchanged:** `Queries.trayBlocks` · `archivedBlocks` ·
  `preservedOriginals` · `originFamilyClocks` · `trayTakes` — the same five
  the Mac's `TrayViewModel` composes, in one `Snapshot`.
- **Every sentence is the SHARED tray vocabulary** (`RecoveryCopy.tray*`,
  which the Mac's `TrayPath` forwards to), so the two trays cannot describe
  one 30-day clock two ways. The acts are the shared decision layer
  (`PreservedOriginPutBack`, `TrashPurge`, `DeletionRefusal`) and the shared
  message class (`RecoveryStatus` — a receipt reads muted, a refusal alarm,
  and the view never re-derives which from the words).
- **Receipts read the OP's own answer**, never an assumption:
  `RecoveryCopy.landingReceipt(landing)` for both block roads (so a block
  whose note is gone says it landed unplaced), and
  `takeRestoredReceipt(status)` for the take road (the exact flip, #68(b) —
  an archived-when-deleted take comes back ARCHIVED and the sentence says so).
- **P1:** all four listings bounded IN SQL at `window + 1` (200, the phone
  rooms' value) through the shared `TrashListing.windowed`, each with a
  visible truncation marker — the FILTERLESS rooms' shared sentence
  (`MobileRoomListing.truncationMarker(shown:)`), because the tray has no
  filter to narrow. **⚠️ This sentence was TRUE OF THREE at ship and became
  true of four at the cold review's fix wave** (2026-08-31, MINOR 1):
  `stranded` was bounded in SQL but handed over raw — no `prefix`, no flag,
  no marker — so a note with ≥ 201 counting originals rendered the probe row
  as content and said nothing. P1 itself was never breached (the `LIMIT`
  bounds the read either way); the visible-truncation half was. Fixed in
  `adopt` + `leavingSection`, and `everyTrayListingIsWindowedAndSaysSo` now
  asserts four of four *and* that the marker renders (its `Snapshot` had
  never populated `originals` at all, which is why the gap was invisible).
  The Mac carries the identical gap and is recorded, not fixed — the
  KnownIssues *"Bounded view windows show markers, not more"* row, owner 12.
- **The observation is HELD, and only while its segment is on screen.**
  `trayBlocks`/`trayTakes` read `variant`, so a held read re-runs at autosave
  rate — which costs nothing here because the sheet covers the page while it
  is up, and the `.task` dies with the segment. Same shape as its sibling in
  the same sheet (`MobileBlockListModel.start`); the opposite call from Block
  History's, and the reason is recorded at both (the Mac twin of THAT face
  stands open beside a live editor; this one cannot).
- **Why the purge door is legal here**, stated at the file head so nobody
  reads it as a breach of 13j's round-3 rider: her G5 ruling superseded that
  rider IN PART with the rule the polish round records — **purge doors live
  on TRASH SURFACES (the global Trash and this note-level trash section) and
  never in the writing flow.** The Leaving section qualifies by construction:
  every row in it is already deleted and already counting down.

### D2 · THE DOOR — the blocks chip's sheet gains segments · **PROVISIONAL** ✅

`MobileBlockListSheet` now carries `in the note | archived | leaving` —
**one subject in three states**, which is the design record's own Q8
candidate. Q8 flagged that *"batch 6b may place this door before she reads
the page; if it does, this question is already answered and that answer
stands"*, so this is that answer, logged in §3.

- The strip is **plain Buttons in a row** — the Library/Trash filter row's
  grammar — never a `Menu` or a `Picker`: §15's trap (b), and the measured
  reason (a `Menu`'s rows come back as an EMPTY accessibility tree).
- `MobileBlocksSegment` is ONE declaration: the segment's word, the pin's
  handle, and every sentence that POINTS at a segment all read it, so a
  re-word lands once. `MobileNoteTrayModel.roadPhrase(to:)` composes
  `blocks ▸ leaving` / `blocks ▸ archived` from the chip word and the segment
  word — never a third literal.
- `tray:` is OPTIONAL on the sheet, so every harness that mounts the plain
  list rides unmodified and the strip renders only where there is somewhere
  for it to go (P-2).
- **Why not a row in the note ⋯** (the brief's recorded fallback): the
  subject of all three segments is THIS NOTE'S BLOCKS, and the ⋯ is the
  note-ACTS menu (Save a Version · Versions… · Undo · Redo · Delete Note…) —
  a listing is not an act, and a tray behind the ⋯ would put one subject
  behind two unrelated doors.

### D3 · ARCHIVE / UNARCHIVE DOORS (PR6) — **verified first, then built BOTH** ✅

**What existed, checked rather than assumed:** neither direction. 6a's Block
History "Unarchive" is `unarchiveVariant` — a TAKE, not a block. A grep of
`VariorumMobile/` for `archiveBlock`/`unarchiveBlock` returned **zero hits**;
the Mac has had both doors since 13j (`BlockTOCView`, `TakesBottomBar`,
`CapabilityID.archiveBlock`). So the phone had a whole 13j capability with no
door at all.

- **Archive** — `Archive Block` in the block ⋯, one row ABOVE Delete Block
  (the gentler of the two ways a block leaves the page), NOT `.destructive`
  and with **no confirm**: nothing is destroyed, there is no clock, and the
  receipt names the road back. It rides `MobileStructuralController` (the
  Delete Block contract) rather than the menu controller's own latch, because
  `archiveBlock` RELEASES the placement — the block leaves the surface and
  the caret needs the shared brain's landing (`caretLandingAfterRemoving`,
  read BEFORE the write from the index that still holds the block).
- **Unarchive** — the tray's Archived section's Put back (`unarchiveBlock`),
  which is D1's.
- **The file header's recorded DELIBERATE ABSENCE is kept and corrected in
  place**: it said *"no such operation exists (blocks archive nowhere — only
  containers and takes do), the Mac offers no such door"*, which was true
  when written and is now exactly false. Left visible with its correction
  rather than deleted, so the reason the row arrived late is legible.

### D4 · 6c's §7 DEVIATION — **FLIPPED** ✅

`MobileBlockHistoryController.deletedExplainer` now passes
`MobileNoteTrayModel.purgeRoadPhrase` where it passed `nil`, so the deleted-
takes region reads *"On the 30-day clock. Put one back here; to end a take's
remaining days early, open blocks ▸ leaving."*

6c was **right to decline** and its trace holds: the region lists deleted
TAKES, `TrashScope.listedKinds` excludes takes by her D1 ruling, and naming
the Trash room would have been a door that cannot act (P-2) wearing a true
sentence's clothes. The tray's Leaving section is the road that makes it
true, and it exists now.

**6c's precondition pin was updated to the new truth, not deleted** —
`theDeletedRegionPromisesNoPurgeRoadTheAppDoesNotHave` became
`theDeletedRegionNamesTheTrayAsItsPurgeRoad`, and it holds BOTH halves: the
sentence names a road that really carries the take (asserted against the
door's own composed phrase), and it still never names the global Trash, which
still does not list takes (`TrashScope` re-asserted in the same pin).

### D5 · PR14 — THE LENS-DANGLES NOTICE ✅

Her 13j gate ruling (5), verbatim: *"say loudly if that take was archived and
this is a fallback WITH a button for quick restore."* Parity C5 shipped the
honest half (a quiet count in the row meta) and recorded that *"the LOUD
restore door stays 13j's"*. This is it.

Two places, because *where the lens renders* is two places on a phone:

1. **The masthead chip** — while the ACTIVE lens has a fallback the chip
   wears ⚠ in the alarm token, on the page the lens is driving, with a spoken
   label (`"Lenses — a pick fell back"`) because a glyph is not a sentence.
2. **The sheet, under the active lens's own row** — one line per dangling
   pick in the alarm token, naming the BLOCK through `Queries.tocHandle` (the
   one block-naming rule) and the STATE, with a real **Restore** button where
   a road exists.

- The four states are worded APART, never hedged into one sentence:
  `archived` / `deleted` / `gone` / `foreign`. The two roadless ones carry
  the plain "isn't here to restore" line instead of a button that could only
  fail (P-2).
- Restore rides existing core ops — `unarchiveVariant` / `restoreVariant` —
  and reads the op's own answer: a deleted take that comes back ARCHIVED
  still dangles, and the receipt says exactly that rather than claiming the
  lens is whole.
- After a restore the lens is **RE-APPLIED** through `activate(_:)`, the same
  road switching to it takes, so the block really does go back to showing its
  pick and there is no second way for the display to be assembled.
- The dangles are read in the SAME pass the counts already ride
  (`danglingLensPicks`, one join per lens), with the block handles read ONCE
  for the whole pass (`blockTOC` — cost ∝ the post, P1) rather than one read
  per pick.

### D6 · PR22 — THE POCKET GUIDE'S DELETION CHAPTER ✅

A new chapter, **"keeping & letting go"**, between *the library of things*
and *keeping it private* — a reader needs to know what a thing IS before
being told where it goes. Two lessons, re-taught in phone grammar (the Mac's
field-guide text names Mac doors and chords — MobileSoul §4.4):

- **"the five places"** — where you left it · Archived (notes' own room AND
  a block's `blocks ▸ archived`, with Archive Block named as the way in) ·
  the Trash (the 🗑 on both top lines, the clock, Delete Now asking every
  time) · this note's Versions · this block's History — plus the take's own
  paragraph: takes never row in the Trash, their two homes are Block History
  and `blocks ▸ leaving`, and that second one is the only place a take can be
  ended early.
- **"the two exits"** — deletion → the Trash (marked, not destroyed, days you
  can see); transformation → lineage (divide and merge keep the original
  WHOLE and set aside, so it is not in the Trash and wears no countdown, and
  it waits in Block History ▸ Came from with Bring back). It ends with a
  staged block the lesson asks her to delete, put back from `blocks ▸
  leaving`, and then divide — the guide's own tutorial-as-spec device, and a
  take is staged on it so the divide it teaches is the fanned kind whose
  original is exactly what *Came from* holds.

The seeder's declared `plan` gained the chapter and its two lessons, which is
what keeps the tutorial spine's own assertions honest (the walk compares the
book against `plan`).

**The batch-5 review's guide NIT, fixed while in the file:** the "getting
around" lesson described a shelf batch 5 had already replaced. It now
describes the ✎ today BADGE on the daily journal's row (reading
`MobileShelfFaces.todayDoorTitle`, the ONE declaration, so a re-word follows)
with its own-row fallback for a shelf with no journal, and it gained a
paragraph for the **quick-note box** — which had no mention anywhere in the
seeder despite being half the shelf.

### D7 · THE `commitNow` RIDER — **did not fire, and here is why** ✅

The rider binds *"if — and only if — you give any surface its own Commit
button while in here"*. **No surface gained one.** `MobileBlockHistory.commitNow`
still has exactly ONE caller — the `Commit Take` row in the block ⋯, a
dismissing `UIMenu` row — which is the condition that makes it safe today.
The row this batch ADDED to that same menu (`Archive Block`) carries the
structural controller's own `structuralInFlight` latch, so it is not a new
un-latched write road either. Nothing owed.

---

## 2. Pins — what was driven, and the reds

Every door is proven by MOUNTING the real surface and ACTIVATING the real
control through `accessibilityActivate()` (§15's trap (b)); the purge confirm
by asserting a live `UIAlertController` and then driving **its own installed
action** with SwiftUI's write-back landed in the same turn (`tapAlertAction`
— batch 4.5b's BLOCKER edge); the block ⋯'s rows through `MenuActionHandler`,
which reaches the `UIAction`'s real handler.

**+27 tests, +2 suites** (632/96 → **659/98**), exactly accounted for:
`MobileNoteTrayTests` 17 (new suite) · `MobilePocketGuideDeletionTests` 4
(new suite) · `MobileLensesTests` +4 · `MobileBlockMenuTests` +2 ·
`MobileBlockHistoryTests` +0 (its 6c precondition pin was RENAMED and
rewritten, not added).

### THE RED-ON-OLD PROOFS — nine reverts, each named, each quoted

Every one is a **behavioural revert** of PRODUCTION code (the seeder's prose
counts as production — it is what the app seeds), never a test edit.

**A1 — a purge door leaking out of the one trash-class surface.** Added a
`Delete Now` button to the ARCHIVED section's row (the brief's explicit ask:
*a Delete Now outside a trash-class surface must fail a pin*):

```
✘ Test thePurgeDoorIsOnLeavingAndNowhereElseInThisNote() recorded an issue at
  MobileNoteTrayTests.swift:318:17: Expectation failed: !(surface.visibleLabels.contains {
✘ Test thePurgeDoorIsOnLeavingAndNowhereElseInThisNote() failed after 2.720 seconds with 1 issue.
```

**A2 — the takes fold OPEN by default** (`takesShown = true`), against her G5
*"albeit maybe not shown by default"*:

> **⚠️ RE-CAPTURED 2026-08-31, SOLO** — the cold review's **NIT 2**. The quote
> this paragraph used to carry showed `"kept — no clock"` in the second slot,
> which the shipped `leavingSection` cannot render there: it fills that slot
> with `RecoveryCopy.trayLeavingExplainer`. That capture had been taken with a
> second revert also in the tree (**A4**, *"the Leaving header rendered
> `archivedForever`"* — the description that matches it), so a record
> presenting nine reverts as an individually-captured set was, in one place,
> presenting a stacked one. The red itself was never in doubt — the reviewer
> reproduced it at the same `:180:17` with the same assertion. Below is the
> true output, taken with **A2 alone** applied to the shipped tree
> (`MobileNoteTray.swift:457`, `takesShown = true`, nothing else) and the file
> then restored from a pre-revert copy, per §4's own rule.

```
✘ Test deletedTakesFoldClosedAndNameTheirBlockWhenOpened() recorded an issue at
  MobileNoteTrayTests.swift:180:17: Expectation failed: !((closed → ["Leaving — on
  the 30-day clock", "Everything this note has on the clock: blocks it deleted,
  takes deleted on their own, and originals riding a family's countdown. Put back
  keeps a row; Delete Now ends its days early.", "1 deleted take", "the spare take",
  "in a fanned block.  ·  deleted jun 30, 2026 at 6:00 pm  ·  30 days left",
  "Put back take", "Delete Now take"]).contains("\(RecoveryCopy.putBackVerb)
  \(RecoveryCopy.rowKind(.take))" → "Put back take") → true)
✘ Test deletedTakesFoldClosedAndNameTheirBlockWhenOpened() recorded an issue at
  MobileNoteTrayTests.swift:187:17: Expectation failed: (open → ["Leaving — on the
  30-day clock", "Everything this note has on the clock: blocks it deleted, takes
  deleted on their own, and originals riding a family's countdown. Put back keeps a
  row; Delete Now ends its days early.", "1 deleted take"]).contains(
  "\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(.take))" → "Put back take")
✘ Test run with 1 test in 1 suite failed after 2.363 seconds with 2 issues.
```

*(The second issue is this same pin's other half, from the other side:
activating a fold that starts OPEN closes it, so the doors that should appear
disappear instead. It also reds the two disclosure-driving pins as collateral,
which is recorded rather than trimmed for the same reason.)*

**A3 — the empty take calls itself a BLOCK again** (`MobileTrayRowFace.takeLabel`
dropped its `emptyTakeLabel` arm — the `BlockPastCopy.emptyTake` lesson):

```
✘ Test everyTraySentenceIsTheSharedOne() recorded an issue at
  MobileNoteTrayTests.swift:543:9: Expectation failed:
  (MobileTrayRowFace.takeLabel(take) → "(empty block)") ==
  (RecoveryCopy.emptyTakeLabel → "(empty take)")
```

**A4 — the two sections blur each other's promise** (the Leaving header
rendered `archivedForever`):

```
✘ Test theTwoSectionsCarryOnlyTheirOwnPromises() recorded an issue at
  MobileNoteTrayTests.swift:494:17: Expectation failed:
  !(labels.contains { $0.contains(RecoveryCopy.archivedForever) } → <not evaluated>)
✘ Test theLeavingSectionShowsDeletedBlocksWithTheirClock() recorded an issue at
  MobileNoteTrayTests.swift:149:17: Expectation failed:
  !(labels.contains { $0.contains(RecoveryCopy.archivedForever) } → <not evaluated>)
```

**A5 — the confirm READS ITS SUBJECT BACK** (`confirmPendingPurge` guarding on
`pendingConfirm` after the suspension instead of taking it as a parameter —
batch 4.5b's BLOCKER shape reproduced exactly). The confirm still PRESENTED
and purged **nothing**:

```
✘ Test aTakeCanBeEndedEarlyHereAndItAsksEveryTime() recorded an issue at
  MobileNoteTrayTests.swift:284:17: Expectation failed: try await purgeIntents(db) == 1
✘ Test aTakeCanBeEndedEarlyHereAndItAsksEveryTime() recorded an issue at
  MobileNoteTrayTests.swift:285:17: Expectation failed:
  (tray.status?.text.contains("gone from the app now") → nil) == true
```

**A6 — the Archive Block row removed from the one builder both doors render:**

```
✘ Test theArchiveRowSetsTheBlockAsideWithNoClock() recorded an issue at
  MobileBlockMenuTests.swift:452:13: Expectation failed:
  MenuActionHandler.activate((MobileEditorStyle.chromeCase(
  MobileBlockMenuController.archiveTitle) → "archive block"), in: (elements → […
  <UIAction: title = merge with previous>, <UIAction: title = delete block; …>]))
✘ Test theArchiveRowSetsTheBlockAsideWithNoClock() recorded an issue at
  MobileBlockMenuTests.swift:466:13: Expectation failed:
  (stamps?["archived_at"] as String? → nil) != nil
✘ Test theArchiveRowSetsTheBlockAsideWithNoClock() failed after 0.500 seconds with 6 issues.
```

…and the standing one-vocabulary pin catches it in BOTH doors at once, which
is what that pin is for:

```
✘ Test theTwoDoorsShareOneVocabulary() recorded an issue at
  MobileBlockMenuTests.swift:100:13: Expectation failed: (barTitles → [… "merge with
  previous", "delete block"]) == (MobileBlockMenuController.rowTitles.map(cased) →
  [… "merge with previous", "archive block", "delete block"])
```

**A7 — the lens sheet stops rendering the loud fallback region:**

```
✘ Test anArchivedPickSaysSoLoudlyAndRestoreBringsItBack() recorded an issue at
  MobileLensesTests.swift:359:17: Expectation failed: (surface.visibleLabels →
  ["lenses", "done", "The Note", "the other reading", "Save the Current View as a
  Lens", "Save into the Active Lens"]).contains(notice → "A second block. — this
  lens's take was archived; showing the note's take instead.")
✘ Test anArchivedPickSaysSoLoudlyAndRestoreBringsItBack() recorded an issue at
  MobileLensesTests.swift:375:13: Expectation failed: (status → "archived") ==
  (VariantStatus.active.rawValue → "active")
✘ Test anArchivedPickSaysSoLoudlyAndRestoreBringsItBack() failed after 5.319 seconds
  with 7 issues.
```

**A8 — the D4 flip put back to `purgeRoad: nil`:**

```
✘ Test theDeletedRegionNamesTheTrayAsItsPurgeRoad() recorded an issue at
  MobileBlockHistoryTests.swift:857:9: Expectation failed: (phone → "On the 30-day
  clock. Put one back here.").contains(MobileNoteTrayModel.purgeRoadPhrase →
  "open blocks ▸ leaving")
✘ Test theDeletedRegionCarriesNoPurgeDoorAndPromisesNoneEither() recorded an issue at
  MobileBlockHistoryTests.swift:451:13: Expectation failed:
  (MobileBlockHistoryController.deletedExplainer → "On the 30-day clock. Put one
  back here.") == ("On the \(TrashWindow.days)-day clock. Put one back here; "
```

**A9 — the guide's shelf lesson put back to the shelf batch 5 replaced:**

```
✘ Test theShelfLessonDescribesTheShelfThatExists() recorded an issue at
  MobileTutorialWalkTests.swift:1433:13: Expectation failed: (prose → "The SHELF is
  home: your books, with this one pinned to the top — pinned books always sit first.
  ✎ Today's Entry opens today's journal page, making it if the day hasn't started.
✘ Test theShelfLessonDescribesTheShelfThatExists() failed after 0.182 seconds with 7 issues.
```

**Every revert was undone and the affected suites re-run green** (60/5 across
the five touched suites), and then the whole suite (§4).

### NEW COVERAGE, labelled honestly

These pin behaviour that **did not exist before this batch**, so there is no
pre-fix tree to revert and no red-on-old to quote. They are new-capability
pins and are named as such rather than dressed up:

- `theArchivedSectionKeepsBlocksForeverAndPutsThemBack` · `theLeavingSectionShowsDeletedBlocksWithTheirClock`
  · `aDeletedTakeComesBackAndTheReceiptSaysWhere` (both roads — active AND
  the archived exact-flip) · `anOriginalJoinsLeavingOnlyWhenItsFamilyStartsCountingDown`
  · `anEmptyTraySaysSoInTheHomesOwnNoun` · `everyTrayListingIsWindowedAndSaysSo`
  · `theTruncationMarkerRendersAndIsTheFilterlessSentence`
  · `theBlocksSheetCarriesTheTrayInThreeSegments` · `theSheetWithoutATrayRendersNoSegmentStrip`
  · `theBlocksChipOnTheRealScreenOpensTheTray` (the whole road, through the
  real `MobileWriteScreen`) · `theRoadPhrasesAreComposedFromTheDoorNotWrittenAgain`
  · `archiveRefusesUnderTheSealInPhoneWords` · `aDeletedPickThatComesBackArchivedSaysSoRatherThanClaimingTheLens`
  · `aPickWithNoRoadBackOffersNoDoorAndSaysWhy` · `theChipMarksTheFallbackOnlyWhileThatLensIsActive`
  · the three guide pins.

### THE ONE GUARD PINNED OVER A FENCED CONSTANT, said plainly

`takesStillNeverRowInTheGlobalTrash` holds her D1 ruling — takes never row in
the global Trash — which this batch had to keep true while giving a take a
purge door for the first time on this phone. Its "revert" would be widening
`TrashScope` in `App/Variorum/Shared/RecoveryActs.swift`, which is FENCED
here, so it is a **precondition pin**, not a red-on-old: it asserts
`listedKinds`, `filterKinds`, `kinds(filter:)`, the phone's own filter row,
AND that a really-deleted take is absent from a real `Queries.trash` read. A
future widening reds it; this batch cannot demonstrate that without breaking
its own fence, and says so instead of implying otherwise.

### ONE PIN'S STATE COULD NOT BE MINTED LOCALLY, and it is named rather than faked

`aPickWithNoRoadBackOffersNoDoorAndSaysWhy` pins the **no-road ARM** of the
fallback face (no `Restore` button, the plain "isn't here to restore"
sentence) over `.foreign` — a `lens_choice` naming a take of a DIFFERENT
block, which is the sync race `effectiveLensSelection` guards against, and
which is written directly because `setLensChoice` correctly refuses it. Its
sibling `.gone` takes the **identical arm** and would need a hard-deleted
`variant` row that `lens_choice`'s foreign key forbids outside the purge —
so the arm is pinned once and the unmintable state is asserted only at
`isRestorable`, with the reason at the pin.

---

## 3. PROVISIONALs and recorded calls (for her sitting bundle)

1. **Q8 — WHERE THE TRAY'S DOOR SITS.** The blocks chip's sheet, in segments
   `in the note | archived | leaving`. The design record flagged that a
   6b placement answers the question and that answer stands; the reasoning
   against the ⋯ fallback is at D2 and at the code. One `MobileBlocksSegment`
   declaration if she re-words the segments; a move to the ⋯ would be a new
   door, not a re-word.
2. **The segment WORDS.** `in the note` · `archived` · `leaving` — short
   forms on purpose, because the tray's full section headers (the SHARED
   `Archived — kept, no clock` / `Leaving — on the 30-day clock`) render
   inside the segment they name. A segment strip is a place to stand, not a
   place to explain.
3. **The tray carries NO COUNTS on its segments.** The blocks chip's own
   recorded judgment, one level down: a census on a strip that does not
   refresh at the listing's cadence is worse than none, and the listing is
   the census. (The Mac's tray door DOES wear a count badge; it sits on
   chrome that lives beside the note, where the phone's sits inside a sheet
   that is not open.)
4. **Archive Block carries NO CONFIRM.** Delete Block confirms; archive does
   not, because nothing is destroyed, there is no clock, and the receipt
   names the road back. The Mac's archive doors carry no confirm either.
5. **PR14's chip marker is a ⚠ glyph in the alarm token**, with the full
   sentence as its spoken label. The alternative was a word on an already
   five-chip line (the recorded crowding flag) — the glyph was chosen for
   that reason and is one string if she wants the word.
6. **PR14's loud region renders for the ACTIVE lens only.** A lens she is not
   looking through is not falling back on anything she can see; its row keeps
   parity C5's quiet count.
7. **The DELETE-BLOCK CONFIRM and RECEIPT now name the tray.** Both carried
   an explicit recorded note that they promised no tray *because the phone
   had none* — the J8 copy doctrine read from its own other side. The tray
   landed, so both say so, with the durable road named before the session's
   undo. Not a new promise: the same promise, now true.
8. **The guide's new chapter is called "keeping & letting go"** and sits
   before "keeping it private". Both the name and the placement are copy
   calls; 13s's voice pass owns the final words.

---

## 4. Counts and environment

**Baseline (the brief's stale 607/94 corrected by the orchestrator):** mobile
**632 / 96 green with 2 known issues** — the ONE documented diagnostic test
(`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`,
one `withKnownIssue` block recording two issues). The record of that close is
the UNIT CLOSED banner atop `notes/plans/mobile-batch-filters-cold-review.md`.

**This batch's final line, quoted:**

```
✘ Test run with 659 tests in 98 suites passed after 282.224 seconds with 2 known issues.
** TEST SUCCEEDED **
```

**+27 / +2 suites, exactly accounted for** (§2's opening). The **2 known
issues are the same single documented diagnostic test** as the baseline's; no
other test records an issue. **`MobilePerfWalkTests.typingAtTheViewportHolds
ThePerKeystrokeBudgetAt100k`** — the known load-flaky pin (KnownIssues, owner
12) — **passed in this run**, so no isolated re-run was needed.

**Environment:** worktree `~/dev/variorum-mobile`, branch `mobile`, HEAD
`7d2b04f` at start. Own private simulator **`Variorum-batch6b`**
(iPhone 17 Pro, iOS 26.2 — the only iOS-26 runtime on this machine; every
iPhone 16-series sim here is iOS 18.3 and is not a valid destination for an
iOS-26 deployment target), `ApplicationAccessibilityEnabled` armed and **read
back `1`**; private `-derivedDataPath` under this session's scratchpad; the
simulator **deleted at the end**. `Package.resolved` did **not** drift this
run and nothing was swept into the commit. No Release build, no install, no
push; the real store untouched; the live Mac app never quit.

### ⚠️ AN INCIDENT, REPORTED BECAUSE A REVIEWER WOULD OTHERWISE HAVE TO GUESS

Mid-batch, restoring the four red-on-old reverts A6–A9 with
`git checkout -- <those four files>` **discarded this batch's own edits to
them along with the reverts** — `MobileBlockMenu.swift`,
`MobileLenses.swift`, `MobileBlockHistory.swift` and
`MobileTutorialSeeder.swift` went back to `HEAD`, i.e. to their PRE-BATCH
state. Nothing outside those four was touched; `MobileNoteTray.swift`
survived because it is untracked, and the other three production files and
every test file were not named in the command.

**All four were re-applied from this session's own edit record**, and the
restoration was VERIFIED rather than assumed: a marker grep for every symbol
each file was supposed to gain (`archiveTitle`, `PR14`, `purgeRoadPhrase`,
`keeping & letting go`, `QUICK NOTE box`, `blockArchivedStatus`,
`activeLensHasFallback`, `lensFallbackChipLabel`) found each in its file, and
the five touched suites re-ran **60/5 green** before the full run. **Nothing
was lost and nothing is half-applied** — but the account is here because a
reviewer reading `git reflog` or wondering why these four files were written
twice deserves the reason.

**The rule this batch would offer the round:** a behavioural revert on a file
the batch has ALSO edited must be undone from a **pre-revert copy of that
file**, never with `git checkout --`, whose baseline is the batch's own
starting point. That is what was done for `MobileNoteTray.swift` (a
scratchpad copy taken before its first revert), and it is exactly why that
file came through untouched.

## 5. Fence, verified before commit

```
git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum \
  "*.xcodeproj" "*.pbxproj"   →  (empty)
git status --porcelain -- Sources/ App/Variorum/Shared App/Variorum/Variorum
                              →  (empty — nothing untracked there either)
```

Zero schema, zero migrations, zero build-config changes, zero
`Package.resolved`.

### THE `Shared/` RESIDUE — the next shared-touching batch's list

*(6c left three; this batch adds two and does not clear any, because every
road to them is fenced here.)*

> **⚠️ ITEMS 4 AND 6 NOW LIVE ON THE TRACKED ROW TOO** (2026-08-31, the cold
> review's **MINOR 3**). `KnownIssuesAndTechDebt.md`'s *"Mac app-local brains
> are forked against mobile siblings"* row is the durable, owned home for this
> class, and it was left untouched by this batch — so the `TrayRowFace` /
> `TrayTakeFace` fork and `LensFallbackCopy`'s promotion from *"still
> Mac-only"* to **FORKED** existed only in this file, which closes. That is
> the precise state that row was restored (2026-08-22, round 2's finding 7) to
> prevent: *"the forked-brain debt had no owner outside a plan file that
> closes."* Both are clauses on its enumeration now; the list below stays as
> the batch's own account.

1. **`RecoveryCopy.surfaceName` still has no caller on either platform**
   (6c's item 1, unchanged — one line for the post-13u cleanup).
2. **`VersionsPath.saveDetail` does not exist** (6c's item 2, unchanged).
3. **`DeletionRefusal.Act` has no `.unarchive` arm** (6c's item 3) — and this
   batch made it BIGGER rather than clearing it: the tray's own
   `putBackArchived` road (`unarchiveBlock`) now joins the Archive room's in
   speaking the put-back sentence for an un-archive refusal. Still harmless
   (the sealed/not-found family reads the same either way) and noted at both
   call sites.
4. **NEW — `TrayRowFace` and `TrayTakeFace` are Mac-app-local pure rules that
   both platforms now need.** They are exactly the class batch 6a hoisted
   (`DeletedTakeFace`, `TrayRowPreview`, `SavepointRowFace` all moved for this
   reason), and they are the ONLY reason this batch has a
   `MobileTrayRowFace`. It composes the SAME shared primitives
   (`TrayRowPreview.line`/`.stampText`, `RecoveryCopy.trayTakeInBlock`,
   `.daysLeftLabel`, `.archivedForever`, `.emptyTakeLabel`,
   `Queries.tocHandle`) and a pin asserts the COMPOSITION rather than the
   literal, so a drift would have to change a shared sentence to happen — but
   the honest fix is a hoist into `Shared/BlockHistoryFace.swift` beside its
   siblings, with the Mac's two enums becoming forwarders (the 3C pattern).
5. **NEW — `BlockHistoryCopy.deletedRegionExplainer`'s doc comment is now
   stale.** It says *"on the phone, until its note-level trash section lands
   (batch 6b), the honest answer is that there isn't one yet"*. The section
   landed; the comment is one paragraph, and the code is unchanged (the
   parameter did its job exactly as designed).
6. **NEW (Mac-app-local, not `Shared/`) — `LensFallbackCopy` is still
   Mac-only**, so PR14's four notices, its restore verb and its three
   receipts are phone-voiced here. They are the same FACTS the Mac words
   (they had to be — the states are the core's), so the two will drift the
   moment either is touched. `KnownIssuesAndTechDebt.md`'s forked-brains row
   is the family; a hoist is one file move plus two forwarders.

## 6. Deliberately not done

- **Anything under `Sources/`, `App/Variorum/Shared/`,
  `App/Variorum/Variorum/`, `EditorBrain/`, schema or build configs** — the
  batch fence. Every one of the five residue items above is a fenced edit and
  is recorded rather than made.
- **A tray door anywhere but the blocks sheet** — Q8 names two candidates and
  this batch picks one; a second door onto one listing is the drift class the
  `MobileRecoveryDoors` declaration exists against.
- **A count badge on the blocks chip** (§3.3).
- **Block multi-select / bulk archive** — batch 7's, untouched.
- **The Mac's current-block jump** — still absent on the phone for 6a's
  recorded reason (the phone's sheet covers the page and stands its editor
  down, so the caret cannot wander).

## 7. For the cold reviewer

**Where to push hardest, in order:**

1. **The Q8 door (D2).** This batch ANSWERED a question the design record
   reserved for her, on that record's own standing permission. If the
   segments shape is wrong, the fallback (a row in the note ⋯) is a
   ten-line change and `MobileBlocksSegment` is the one declaration to move.
   Check the reasoning at `MobileBlockList.swift`'s header against §7 Q8.
2. **The three copy flips.** D4's explainer, the delete confirm, and the
   delete receipt all changed because a road they said did not exist now
   does. Each is the J8 doctrine read from its own other side, each is a
   sanctioned pin flip, and each pin was rewritten to hold the NEW fact plus
   the precondition that still constrains it. If any of the three names a
   road that does not really carry what the sentence is about, that is
   exactly 6c's D5 finding repeating and it should be caught.
3. **The evolved purge-door rule.** The Leaving section renders a Delete Now
   INSIDE a note. That is her G5 ruling superseding 13j's round-3 rider in
   part, not a breach — the reasoning is at `MobileNoteTray.swift`'s header
   and the polish round records it. `thePurgeDoorIsOnLeavingAndNowhereElseInThisNote`
   is the guard, and A1 is its red.
4. **`MobileTrayRowFace` is a fork by MobileSoul §3's letter**, and it is in
   §5's residue as such. Judge whether composing shared primitives + a
   composition pin is enough for one batch that cannot touch `Shared/`, or
   whether the hoist should have blocked the batch.
5. **PR14's shape.** Her ruling says *loudly*; this reads it as the chip
   marker AND the sheet region. If the notice belongs somewhere else — per
   block on the page, say — that is a design call worth naming.

**Reproducing the reds:** every revert in §2 is a two-to-twelve-line edit
described in its own paragraph. **Take a copy of the file first** — see the
incident in §4.

**Checkable claims:**
- `TrashScope`'s three members and their D1 reasoning:
  `App/Variorum/Shared/RecoveryActs.swift:462-491`.
- The five core reads the tray composes, each with its own `limit` doc:
  `Sources/VariorumCore/Queries/PoolAndTray.swift` (`trayBlocks`,
  `preservedOriginals`, `trayTakes`) and `Trash.swift` (`archivedBlocks`,
  `originFamilyClocks`).
- The Mac tray this face is built beside (READ-only, fenced):
  `App/Variorum/Variorum/Features/Tray/TrayPanel.swift`.
- The Mac's archive doors, which is what makes PR6 a parity gap rather than
  an invention: `Features/TOC/BlockTOCView.swift:238`, `:446`,
  `Features/Takes/TakesBottomBar.swift:145`, `CapabilityID.archiveBlock`.
- `Queries.DanglingPick.State`'s four cases and `isRestorable`:
  `Sources/VariorumCore/Queries/LensQueries.swift:77-103`.
