# Batch 6c — THE TWO-ROOMS IA · the record (built 2026-08-30/31)

**The brief is `notes/plans/mobile-batch-6c-brief.md`.** Her ruling, verbatim
(QUESTIONS #84, 2026-08-30): *"i read the proposal and I want this option:
**Two rooms** — The Mac's own asymmetry, translated literally. Archive becomes
a room you browse; the Trash becomes a utility you visit. Two doors, two
destinations, nothing shared."* The design record is
`notes/plans/mobile-archive-trash-design/` (option 2 is the ruled one); the
five-places map (`mobile-round-2.md` §69.1) was the tie-breaker for every face
call, and MobileSoul **PL-14(b)/(f)** and **PL-11(b)/(c)** are the ledger rows
this burns down.

Read in full before a line was written: `CLAUDE.md` · `notes/MobileSoul.md`
§2–§5 + PL-11/PL-13/PL-14/PL-15 · the design record's README **and**
`proposal.html`'s option-2 and note-scale frames · `mobile-round-2.md` §69–§71
· `QUESTIONS.md` #84–#87 and #80(a)–(f) · and every named code file
(`MobileTrashView`, `MobileTrashModel`, `MobileLibraryView`, `MobileShelfView`,
`MobileNoteActions`, `MobileWriteView`, `Shared/RecoveryCopy.swift`,
`Shared/VersionsCopy.swift`, `Shared/VersionActs.swift`,
`Shared/BlockHistoryFace.swift`, `Sources/…/Queries/NoteVersions.swift`,
`MobileSurfaceDriver.swift`).

---

## 1. What landed, per deliverable

### D1 · THE SPLIT — the combined surface retires; two rooms replace it ✅

The one `MobileTrashView` (one `ScrollView`: trash half → `Divider` → archived
half) is now **two pushed screens**, and the split reaches the MODEL layer, not
just the view:

| | the Trash room | the Archive room |
|---|---|---|
| view | `MobileTrashView` (narrowed) | `MobileArchiveView` **(new)** |
| model | `MobileTrashModel` (trash only) | `MobileArchiveModel` **(new)** |
| door | the **Library path line's 🗑** — option 2's letter, the analogue of her Mac B1 masthead trash icon | the Library listing's **trailing row, narrowed** to `Archived` |
| route | `MobileRoute.trash` | `MobileRoute.archive` |
| carries | kind filter (TrashScope order) · clocks · Put back · **Empty Trash + Delete Now, confirm-every-time** · truncation marker · report line — all moved WHOLE | kept-forever, no clock, Unarchive + Open note — moved WHOLE |

- `MobileRoute.recovery` is **gone**; `.trash` and `.archive` replace it, and
  the shelf's starred-route switch answers all three new cases explicitly
  rather than defaulting (its own standing rule).
- **Two models, not one with two `.task`s.** *"Nothing shared"* is the ruling's
  last clause: a shared model keeps ONE error slot and ONE receipt slot between
  two rooms that exist to be read apart, and its two windows would be one
  object's business when they are two rooms' P1 discipline. The archived
  listing moved with its act, its receipt and its window bound; every read
  still goes through the core's own `observeArchivedPosts` wrapper (§49's
  MINOR), never a rolled `observe { … }`.
- **`RecoveryCopy.surfaceName` ("Archived & Deleted") is no longer called from
  any phone surface.** The file was NOT edited (fenced — see §5's residue).

### D2 · NAMES — PROVISIONAL ✅

The Archive room and its door say **"Archived"**
(`RecoveryCopy.archivedSection`); the Trash says **"Trash"**
(`RecoveryCopy.trashSection`). Both are read through one declaration
(`MobileRecoveryDoors`), so a re-word is one string each. Logged as
PROVISIONAL — design-record **Q7**, and **Q3** rides with it (the trash door
renders as the mockup's 🗑 glyph with the WORD as its accessibility label).

### D3 · THE SHELF'S TRASH DOOR — PROVISIONAL ✅

`MobileRecoveryDoors` + `MobileTrashDoor` are **one declaration with two
renderers**: the Library's path line and the Shelf's render the same glyph, the
same accessibility word, to the same destination. The reason is the design
record's finding 1 — **books live on the Shelf and a deleted book rows in the
Trash**, so a door reachable only from the Library would put a tab switch
between deleting a book and getting it back. Logged as PROVISIONAL (Q6).
The Shelf's door files the quick-note box first (`leavingShelf`), like every
other road off that root.

### D4 · THE VERSIONS FACE — PROVISIONAL, built to the proposal's drawn shape ✅

**`MobileVersions.swift`** — `MobileVersionsModel` + `MobileVersionsScreen` +
`MobileVersionsView`. The phone had **no Versions face at all** while all three
operations were already core, so her saved moments existed on the phone and
were unreachable from it. Now:

- **The door (Q5, PROVISIONAL):** the note ⋯ sheet gains **`Save a Version`**
  and **`Versions…`** ABOVE Undo · Redo · Delete Note…, so the phone's two ⋯
  menus teach the two grains — block ⋯ = Commit Take + Block History…, note ⋯ =
  Save a Version + Versions… (finding 2; the Mac teaches it with ⌘S vs ⌘⇧S and
  the phone has no chord culture). A sixth masthead chip was refused: that row
  already wraps five and its crowding is flagged for her.
- **The listing:** `Queries.noteVersions` — date-led rows (V6: no title
  mutation, the display is derived), block count, cadence, first words.
- **Q9, PROVISIONAL — the tap is READ**, and the phone **covers**: the moment
  reader replaces the listing on the same pushed screen with a `‹ Versions`
  door back (the proposal's own drawn path line). The Mac reads a moment
  BESIDE the note in a side panel, which is exactly the thing the phone cannot
  have (design record §5.1). The three verbs sit **on the moment**, never on a
  row — four verbs do not fit a phone row.
- **Her ratified shapes, pinned as such:** Restore **CONFIRMS** (#80(d)),
  Promote is **fast with NO confirm** (#80(c)), Delete **confirms** and takes
  the ordinary move-to-Trash road. Both confirms use
  `.alert(isPresented:presenting:)` over a real `@Bindable` projection — the
  batch-4.5b BLOCKER rule, so no act reads its subject back after SwiftUI's
  write-back.
- **The acts are the SHARED decision layer** (`Shared/VersionActs.swift`):
  flush-first, the receipts, and the refusal voice are not this face's to
  invent. `MobileEditorViewModel.saveVersion()` is the phone's four-line voice
  over `VersionActs.save`.
- **NO purge door**: a moment's Delete is a tombstone with 30 days, and the
  pin asserts `purge_intent` stays at 0.

### D5 · THE EXPLAINER'S SECOND HALF — **NOT FLIPPED. The brief's premise does not hold, and here is the trace.** ⚠️

The brief says: *"the phone now HAS a purge road, so the Block History
deleted-region caller passes the Trash's door name."* **It does have a purge
road — for notes, books and blocks. The region in question lists deleted
TAKES, and takes are not in the global Trash.**

Traced, not assumed:

- `BlockHistoryCopy.deletedRegionExplainer(purgeRoad:)` produces
  *"On the 30-day clock. Put one back here; to end **a take's** remaining days
  early, ⟨road⟩."* — its clause is about a TAKE.
- Its only phone caller is `MobileBlockHistoryController.deletedExplainer`,
  rendered over `history.deletedTakes` (`MobileBlockHistory.swift:375-379`).
- `TrashScope.listedKinds` = `[.note, .book, .block, .preservedOriginal]` —
  takes excluded by her **D1** ruling, and `TrashScope.kinds(filter:)` cannot
  widen past it (`Shared/RecoveryActs.swift:462-481`). The Trash room's
  observation calls exactly that function.

So naming the Trash room here would point her at a room where the take she is
reading about **does not appear** — a door that cannot act (P-2) wearing a true
sentence's clothes, on a surface whose whole job is to stop a take being
invisible. §70's own hand-forward says the second half lands *"when batch 6b
gives the phone its note-level trash section"*, and that is the road that makes
it true (§69.3: the tray's Leaving section carries per-take Put back +
Delete Now, confirm-every-time).

**What landed instead:** `purgeRoad: nil` stands; the mechanism is recorded at
the call site so nobody re-derives it; and a new pin
(`theDeletedRegionPromisesNoPurgeRoadTheAppDoesNotHave`) holds the
**precondition** — if a later batch makes takes reachable from a purge road,
the pin's first two expectations change with it and the flip is one argument.
**Recorded here for the cold reviewer and for her bundle; nothing was
escalated mid-run** (the away-run protocol).

### D6 · NOT THIS BATCH — honoured ✅

- Kind filters on the Library/Archive (her **#85**, which she ruled OUTRANKS
  this work) are the NEXT batch's. **The Archive room is structured for it:**
  its listing is a plain `ScrollView`/`LazyVStack` under a two-line masthead
  with nothing between them, so the Library's filter-row component drops into
  that gap on BOTH surfaces as one brain. Its truncation marker deliberately
  omits the "narrow the filter" half until there is a filter to narrow.
- The per-note tray's three-section rework (6b): untouched.
- `TrashScope` untouched, and **pinned still true after the split**
  (`theTrashRoomStillListsNoTakes`).
- **Zero lines** under `Sources/`, `App/Variorum/Shared/`,
  `App/Variorum/Variorum/`, `EditorBrain/`, schema or build configs —
  verified by `git diff --name-only` before commit (§5).

---

## 2. Pins — what was driven, and the reds

Every door is proven by MOUNTING the real surface and ACTIVATING the real
control through `accessibilityActivate()` (§15's trap (b)); every confirm by
asserting a live `UIAlertController` and then driving its own installed action
with SwiftUI's write-back landed in the same turn.

**+15 tests, +1 suite** (592/93 → **607/94**), exactly accounted for:
`MobileVersionsTests` 11 (new suite) · `MobileTrashTests` +2 ·
`MobileDeletionTests` +1 · `MobileBlockHistoryTests` +1.

### The three RED-ON-OLD proofs (the split's guards)

The brief names three places the split could lose a guard. Each was proven by
behavioural revert, with the failure quoted.

**(a) A purge door leaking into the Archive room** — added a `Delete Now`
button to `MobileArchiveView`'s row:

```
✘ Test thePurgeDoorsExistNowhereButInTheTrashRoom() recorded an issue at
  MobileTrashTests.swift:493:17: Expectation failed:
  !((labels → ["~/archived", "kept — no clock", "md", "Unarchive",
  "Delete Now", "Open note"]).contains(RecoveryCopy.deleteNowVerb →
  "Delete Now") → true)
✘ … recorded an issue at MobileTrashTests.swift:495:17
✘ Test thePurgeDoorsExistNowhereButInTheTrashRoom() failed after 6.116 seconds
  with 2 issues.
```

**(b) The narrowed Library door still reaching the Trash** — pointed the
trailing row's action at `onOpenTrash`:

```
✘ Test theLibraryCarriesBothRoomsDoors() recorded an issue at
  MobileDeletionTests.swift:297:17: Expectation failed:
  (archive → VariorumMobileTests.LockIsolatedBox<Swift.Bool>).value → false
✘ Test theLibraryCarriesBothRoomsDoors() failed after 1.834 seconds with 1 issue.
```

**(c) The two rooms blurring each other's promise** — rendered
`archivedForever` in the Trash room's header:

```
✘ Test theTwoRoomsCarryOnlyTheirOwnPromises() recorded an issue at
  MobileTrashTests.swift:72:17: Expectation failed:
  !(labels.contains { $0.contains(RecoveryCopy.archivedForever) }
  → <not evaluated>)
✘ Test theTwoRoomsCarryOnlyTheirOwnPromises() failed after 2.786 seconds
  with 1 issue.
```

All three reverts were undone and the suite re-run green (§4).

### The new-capability pins (behaviour on real mounted surfaces)

- `theTwoRoomsCarryOnlyTheirOwnPromises` — the Trash room shows the 30-day
  clock and **never** kept-forever; the Archive room shows kept-forever and
  **never** a countdown. (Batch 4's pin asserted both promises on one screen;
  after a split the inverted form is the one a screen can actually break.)
- `theCombinedSurfacesNameIsGoneFromThePhone` — `"Archived & Deleted"` appears
  on no phone surface, and the two doors that replaced it do.
- `thePurgeDoorsExistNowhereButInTheTrashRoom` — extended from batch 4's
  version to name all three places a leak could now appear: the **Archive
  room** (asserted over a POPULATED screen, never vacuously), the **Library**
  (which grew a door this batch), and a note's own surfaces.
- `theTrashRoomStillListsNoTakes` — `TrashScope` pinned still true after the
  split, at `listedKinds`, `filterKinds`, `kinds(filter:)` and the view's own
  filter row.
- `theLibraryCarriesBothRoomsDoors` — both doors driven, and asserted to be
  DIFFERENT destinations (a split whose doors both opened one screen would
  pass a "the door exists" pin and fail the ruling).
- `theShelfCarriesTheSameTrashDoor` — the Shelf's door driven on the real
  shelf, and its label asserted to BE the Library's (one declaration).
- Versions: `theNoteMenuCarriesBothTimeControls` (and the block grain has not
  wandered into the note ⋯) · `theVersionsRowReallyAsksTheShellToPush` ·
  `theSaveVersionRowReallySavesAMoment` (driven through the real sheet row,
  asserted in the STORE) · `theRoomListsEveryMoment` ·
  `aRowsTapReadsTheMomentAndTheVerbsSitOnIt` (verbs absent from the listing,
  present on the moment, **no purge verb anywhere**, and the way back works) ·
  `restoreConfirmsAndThenMakesTheNoteSayItAgain` (asking is not doing; the
  note says the old words; **the save-first promise is kept — 2 moments
  after**) · `promoteIsFastAndHasNoConfirm` (no alert on a surface just proven
  able to present one; the container ends unarchived and unsealed) ·
  `deleteConfirmsAndSendsTheMomentToTheTrash` (it rows in the Trash as a
  version and `purge_intent` stays 0) ·
  `theVersionsVocabularyIsSharedAndTheOneGapIsPhoneVoiced` ·
  `anEmptyRoomInvitesTheFirstMoment` ·
  `aSealedNoteRefusesARestoreInTheFamilysVoice`.
- `theDeletedRegionPromisesNoPurgeRoadTheAppDoesNotHave` — D5's traced fact,
  held as a falsifiable precondition.

---

## 3. PROVISIONALs (for her sitting bundle)

1. **Q7 / Q3 — the words and the glyph.** The Archive room and door say
   **"Archived"**; the Trash says **"Trash"** and its door is the mockup's 🗑
   with the word as its accessibility label. One string each if she re-words;
   a labelled row instead of (or beside) the glyph is a two-line change.
2. **Q6 — the Shelf's trash door.** Built (finding 1). It costs one glyph in
   the Shelf's path line, which now carries 🗑 · + new note · Settings.
3. **Q5 — `Save a Version` and `Versions…` in the note ⋯**, growing a
   three-row sheet to five, with the two time controls placed FIRST.
4. **Q9 — the row's tap is Read**, verbs on the moment, reader replacing the
   listing on the same screen with a `‹ Versions` door back.
5. **The Versions empty line is phone-voiced.** `VersionsPath.empty` names
   ⌘⇧S; the phone says *"No saved moments yet — Save a Version in ⋯ keeps the
   whole note as it is right now."* Same class as batch 6a's `noSavepoints`,
   and pinned as a deliberate gap (the shared line is asserted to name a chord,
   so nobody "fixes" the phone's by adopting it).
6. **The Archive room's truncation marker** is `"Showing the first N."` — the
   Trash's version ends *"narrow the filter to see more"* and this room has no
   filter until her #85 batch.
7. **The Library path line's spacing** moved to `16` (the Shelf's own value)
   now that it carries two trailing doors.

## 4. Counts and environment

**Baseline:** the WAVE 2 RESULTS line in `notes/plans/mobile-fable-sweep-review.md`
— *"Test run with 592 tests in 93 suites passed … with 2 known issues"*.

**This batch's own final line, quoted:**

```
✘ Test run with 607 tests in 94 suites passed after 159.989 seconds with 2 known issues.
** TEST SUCCEEDED **
```

The **2 known issues are the same single documented diagnostic test** as the
baseline's — `anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`,
which records two issues from one `withKnownIssue` block. No other test records
an issue.

**Environment:** worktree `~/dev/variorum-mobile`, branch `mobile` at `bfd0df5`.
Private simulator `Variorum-batch6c` (iPhone 17 Pro, iOS 26.2,
`ApplicationAccessibilityEnabled` armed and read back `1`), private
`-derivedDataPath` under this session's scratchpad; the simulator was **deleted
at the end**. `Package.resolved` drifted during test runs and was reverted —
never swept into a commit. No Release build, no install, no push, the real
store untouched, the live Mac app never quit.

## 5. Fence, verified before commit

```
git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum \
  "*.xcodeproj" "*.pbxproj"   →  (empty)
```

**The one Shared residue, recorded rather than edited (D1's letter):**
`RecoveryCopy.surfaceName` = `"Archived & Deleted"` in
`App/Variorum/Shared/RecoveryCopy.swift` now has **no caller on either
platform** — the Mac stopped reading it at the post-13l polish round, and the
phone stopped this batch. Its doc comment still says *"It stays for the PHONE,
whose recovery surface still holds both lists — a face, and mobile's own round
to move"*, which is now history. **One line for the post-13u cleanup: delete
the constant and its paragraph.** (`VariorumTests/NoteDeletionDoorsTests` and
`MobileDeletionTests` still reference it in ABSENCE assertions — *the confirm
must not name it* — which is a legitimate use and should outlive the constant
as a literal or be dropped with it.)

## 6. Deliberately not done

- **D5's flip** — §1's trace; the road is batch 6b's tray.
- **Kind filters** on the Library or the Archive (her #85 — the next batch).
- **A second search field for the Archive room** (design-record Q4, open):
  neither room has a search field; the Library's is unchanged and unscoped
  toward them. 13o inherits the answer either way, and the room is structured
  so a filter/search strip drops in above its listing.
- The per-note tray (6b), the guide's deletion chapter (§69.8), anything in
  `Shared/`/`Sources/`/`Variorum/`/`EditorBrain/`.
- **13u2 item 15's faces were NOT pre-built** (the fence): the restore
  confirm does not name set-aside ancestors and the tutorial gained no
  versions lesson. The confirm says exactly `VersionsPath.restoreConfirmDetail`.

## 7. For the cold reviewer

- The three red-on-old proofs are reproducible from §2's descriptions; each
  revert is a two-to-nine-line edit named there.
- Every claim about `TrashScope` is checkable at
  `App/Variorum/Shared/RecoveryActs.swift:462-481`, and the pin that holds it
  is `MobileTrashTests.theTrashRoomStillListsNoTakes`.
- The Versions verbs' ratified shapes are `QUESTIONS.md` #80(c) and #80(d);
  the pins name them in their doc comments.
- The one place a reviewer should push hardest is **D5**: the brief asked for a
  flip and this batch declined it on a traced fact. If the trace is wrong, the
  fix is one argument at `MobileBlockHistory.swift`'s `deletedExplainer` and
  one pin.
