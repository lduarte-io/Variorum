# Cold review — batch 6c, the Two-rooms IA (`bfd0df5..51101ba`)

*Cold Opus reviewer, zero implementation context, 2026-08-31. It ran the
full mobile suite on its own armed simulator — `Test run with 607 tests in
94 suites passed … with 2 known issues`, exactly the record's claim, test
arithmetic exact (+15 = 11+2+1+1) — verified all three red-on-old reverts
line-consistent, and traced the record's flagged D5 deviation at FOUR links
before endorsing it. **Counts: 0 BLOCKER · 0 MAJOR · 4 MINOR · 6 NIT.***

## Findings (landed in full — the compressed-summary rule)

**m1 [MINOR] · `MobileVersions.swift:216-227` · READ-ONLY.**
`MobileVersionsModel.rowMeta` composes as shared `VersionsPath.rowMeta(item)`
MINUS ELEMENT 0, assuming element 0 is always the date — positional
coupling to an array whose contract promises no order, whose own doc names
a live future that will edit it (13w's automated rotation renders there),
and which no pin covers (`rowTitle` is pinned; `rowMeta` is not). A reorder
or new leading piece silently drops the wrong element with zero signal —
the drift class arriving through composition instead of copying. *Fix:*
pin the composed string, and/or compose from named pieces rather than
counting to one.

**m2 [MINOR] · `MobileNoteActions.swift:180,195` + the record §3 item 5 +
the pin name · READ-ONLY.** The batch invented THREE Versions sentences,
not one: beside the recorded ⌘⇧S-empty-line re-voice, the note ⋯ rows
carry invented detail prose — and one ("saves this whole note as it is
right now") is a near-verbatim rewrite of a clause inside
`VersionsPath.empty`, the same sentence living twice, which
`VersionsCopy.swift`'s own header forbids. The pin's name and the record
both say "the ONE gap". *Fix:* de-duplicate the near-verbatim detail
(genuinely phone-voice it; a shared `saveDetail` home is FENCED and goes
to the next Shared-touching batch's list), extend the pin to cover all
phone-voiced Versions strings, and correct the record's count.

**m3 [MINOR] · `MobileVersions.swift:97-105` · READ-ONLY.** The Versions
listing is the one new phone listing with NO window and NO truncation
marker — every sibling takes `window + 1` + a visible marker, and
`Queries.noteVersions` already carries `limit: Int? = nil`. True-today
("versions are hand-saved") is exactly what 13w un-makes. *Fix:* pass
`limit: window + 1`, reuse `TrashListing.windowed`, add the marker string
beside the Archive room's.

**m4 [MINOR] · `MobileNoteActions.swift:188-191` + record §1 D4 ·
READ-ONLY (risk half SPECULATIVE).** The `dismiss()`-then-push road's
comment claims a "proven road on this app" — the cited precedent is
DEBUG-only (`onOpenTutorialBook`), unpinned even there, and a different
shape (state-flag flip + append in one scope, not environment-dismiss then
a call up the tree). No actual failure traced; the provenness CLAIM is
falsifiable and false. *Fix:* correct the comment and record; and either
drive the composed road once on a mounted `MobileShellView` or invert the
order to match the precedent's shape.

**n5 [NIT]** · `MobileArchiveModel.swift:98-100` vs
`MobileTrashModel.swift:243-245` — a second byte-identical `refusal(_:)`
forward (the RULE stays shared in `RecoveryActs`; two call sites must now
change together, and `DeletionRefusal.Act` has no `.unarchive` arm, so the
Archive's unarchive refusals speak the put-back sentence — inherited).
**n6 [NIT]** · `MobileVersions.swift:109-125` — a failed moment read
leaves the reader open, empty, with all three live verbs; `closeReader()`
in the catch. **n7 [NIT]** · `theCombinedSurfacesNameIsGoneFromThePhone`
claims corpus-wide, asserts one surface (the wide claim IS true —
grep-verified zero phone call sites); narrow the doc or widen the pin.
**n8 [NIT]** · the new Archive room is the one surface where a born-
archived VERSION could newly leak into a phone listing, and no phone pin
holds the fence (the reviewer verified it holds — core's
`excludingVersionHistory: true` default + nine core pins); one line in
`theTwoRoomsCarryOnlyTheirOwnPromises`. **n9 [NIT]** · both rooms'
truncation-marker strings are unpinned (inherited gap, now on a new
surface). **n10 [NIT]** · the rooms' "Open note" doors are routed but
never driven — the one door on the new surfaces no pin activates, in the
round that shipped four dead-door classes.

## Clean bill (headlines; the full text is in the session record)

D5's declined flip CORRECT at four links (the region is take-only;
`TrashScope.listedKinds` cannot widen past its literal; the Mac's own arm
names the TRAY; the precondition pin is real and falsifiable) · the split
lost NO guard (the Trash diff is pure deletion of the archived half;
`MobileArchiveModel` has no purge road AT ALL — in-trash-only is
structural; the nowhere-else pin covers the new room over a populated
screen) · `TrashScope` untouched, pinned at four surfaces · P1 rides both
rooms (window+1 through the core wrapper, `TrashListing.windowed`) · one
door declaration, two renderers, driven end-to-end with different
destinations proven · the retired route leaves nothing orphaned
(compile-proven) · `RecoveryCopy.surfaceName` zero phone call sites,
`Shared/` byte-untouched · the fence held everywhere · the Versions verbs
match her ratified shapes, DRIVEN not asserted (real alert with
`presenting:`; asking-is-not-doing proven; Promote no-confirm proven
against a surface that can present; Delete lands a version row in the
Trash with `purge_intent == 0`) · the 13u2 item-15 fence honoured · restore
flush-first through the ONE per-post coordinator · the two-model split is
a face split, not a forked brain (rules stay shared; the archived listing
MOVED, not copied) · ledger updates honest, D5's exception in the cell.

---

# ADJUDICATION + FIX-WAVE BRIEF (the Fable orchestrator, 2026-08-31)

**ALL TEN ACCEPTED, ZERO DISPUTES.** No BLOCKER/MAJOR at round 1 ⇒ the
unit closes after ONE fix wave (the batch-1 economics: NITs and MINORs are
fixed without a further round); the orchestrator verifies the wave's diff.

**ONE Opus fix session, the ten items, adjudicated shapes:**

1. **m1**: compose `rowMeta` from NAMED pieces if the shared file exposes
   them individually (READ it — it is fenced for edits); if it does not,
   keep the composition but PIN the composed string and leave a comment
   naming the coupling and the 13w future. Either way the drift now has a
   signal.
2. **m2**: genuinely phone-voice the save row's detail (no near-verbatim
   rewrite of a shared clause), extend the pin to enumerate ALL
   phone-voiced Versions strings (rename it honestly), correct the record
   §3's "one gap" count, and add `VersionsPath.saveDetail` to the
   next-Shared-touching-batch list in the record.
3. **m3**: `limit: window + 1` + `TrashListing.windowed` + a visible
   truncation marker, the Archive room's shape exactly; pin the marker
   (folds n9's Versions-adjacent half in).
4. **m4**: correct the comment and the record sentence (mandatory), and
   drive the composed dismiss-then-push once on a mounted
   `MobileShellView` if the harness reaches it; if it cannot, invert the
   order to the precedent's shape and say so.
5. **n5**: inline both rooms' one-liner forwards to direct
   `DeletionRefusal.words(_:act:)` calls at their use sites, with a
   comment at the Act enum's phone callers noting the missing `.unarchive`
   arm is a FENCED (`Shared/`) addition for the next Shared-touching
   batch.
6. **n6**: `closeReader()` in the catch; pin it (a refusal lands on the
   listing, never an empty reader with live verbs).
7. **n7**: narrow the pin's doc comment to the surface it drives; keep the
   grep truth in the comment.
8. **n8**: the one-line version-fence assertion in
   `theTwoRoomsCarryOnlyTheirOwnPromises` (save a moment, assert it does
   not row in the Archive room).
9. **n9**: pin BOTH rooms' truncation markers (drive past the window on a
   seeded set, assert the marker renders).
10. **n10**: drive each room's "Open note" door once on the real mounted
    surface, asserting the shell receives the push.

Environment and rules: exactly the standing fix-brief block (own armed
simulator, private DerivedData, full mobile suite at the end — baseline
607/94 + 2 known issues — quoted line, `Package.resolved` never swept,
fence verified empty before the pathspec-limited commit, no pushes).
Append a FIX WAVE RESULTS section to THIS file before the final message.

---

# FIX WAVE RESULTS (one Opus fix session, 2026-08-31)

**ALL TEN LANDED. Nothing declined, nothing deferred.** Five items carry a
red-on-old proof by behavioural revert with the failure quoted; the rest are
honestly labelled NEW COVERAGE or doc-only, because a revert that could prove
them does not exist inside this batch's fence.

**Suite: 607/94 → 613/94** (+6 tests, +0 suites — `MobileVersionsTests` 11 →
15, `MobileTrashTests` +2), same 2 known issues from the one documented
diagnostic test.

| # | Item | What landed | Pin, and what kind of proof it is |
|---|---|---|---|
| 1 | **m1** — `rowMeta`'s positional coupling | The shared file exposes no named pieces (READ, fenced), so the composition now drops **the piece that IS the title, by name** (`filter { $0 != rowTitle(item) }`) instead of counting to one — a reorder or a new leading piece can no longer silently drop the block count. The coupling underneath is named in the doc and the 13w future with it. | `theRowsMetaSaysEverythingButTheTitle` — **NEW COVERAGE, stated as such.** `rowMeta` had no pin at all (that absence IS the finding), and staging the drift means editing `Shared/VersionsCopy.swift`, which is fenced. Its last expectation (`rowMeta(item).first == rowTitle(item)`) is the drift signal: a 13w reorder reds there and names the coupling. |
| 2 | **m2** — three invented sentences, one a near-verbatim rewrite | Save row's detail re-voiced to *"keeps a moment of the note, to come back to"*; Versions row's detail **composed from the shared verbs** (`read, restore or promote a saved moment`); the file header and the record corrected from "the ONE gap" to **four, enumerated**; `VersionsPath.saveDetail` added to the record's next-Shared-batch list (§5, now three items). | `theVersionsVocabularyIsSharedAndEveryPhoneVoicedLineIsListed` (renamed) — **RED ON OLD.** It enumerates all four phone-voiced strings and holds the invented ones ≥6 words clear of every shared sentence. |
| 3 | **m3** — the unwindowed listing | `MobileVersionsModel(window: 200)`, `Queries.noteVersions(limit: window + 1)`, `TrashListing.windowed`, `truncated`, and a visible marker — the Archive room's shape exactly. Folds **n9's Versions half**. | `theVersionsListingIsWindowedAndSaysSo` — **RED ON OLD** (3 issues). |
| 4 | **m4** — the false "proven road" claim | Comment rewritten to say what was actually traced (the cited precedent is DEBUG-only, unpinned, a different shape) and a dated correction added to the record's D4. The order was NOT inverted — the harness reached the composed road, so it is **driven** instead. | `theVersionsRowOpensTheRoomThroughTheWholeShell` — **RED ON OLD.** A mounted `MobileShellView` → the shelf's Today door → the real ⋯ sheet → the real row → the room arrives. |
| 5 | **n5** — the second byte-identical `refusal(_:)` forward | Both forwards **deleted**; both call sites now call `DeletionRefusal.words(_:act: .putBack)` directly. The missing `.unarchive` arm is noted at `MobileArchiveModel`'s call site as a FENCED `Shared/` addition and added to the record's next-Shared-batch list. | Compile-proven (two symbols gone, no callers left); `theDeletionRefusalsHaveOneHome` updated to read the shared home directly and still holds the two surfaces' equality. |
| 6 | **n6** — the empty reader with three live verbs | `closeReader()` in `read`'s catch, with the mechanism at the code. | `aFailedMomentReadLandsOnTheListingNotInAnEmptyReader` — **RED ON OLD.** The read failure is injected at the storage layer (an in-memory world has no other way to make a read throw); the pin holds the surface's contract, never the injection. |
| 7 | **n7** — the pin's over-wide doc | Doc narrowed to the surface it drives (the Library), with the corpus-wide grep truth kept in the comment and labelled as grep-verified rather than driven. | Doc-only; the pin's assertions are unchanged. |
| 8 | **n8** — no phone pin on the version fence | `theTwoRoomsCarryOnlyTheirOwnPromises` now saves a moment and asserts it does **not** row in the Archive room, beside a real archived note so the absence is never vacuous. | **NEW COVERAGE.** The fence is core's (`excludingVersionHistory: true` + nine core pins) and staging its failure means changing core, which is fenced. |
| 9 | **n9** — both rooms' markers unpinned | Both rooms driven past a window of 1 and the marker asserted where she reads it. The filterless sentence gained **one home** — `MobileRoomListing.truncationMarker` (the Archive room's private copy retired rather than copied a third time for Versions) — and both rooms' prose lines gained the plain-sentence accessibility label the standing rule asks for. | `bothRoomsSayWhenTheWindowIsHidingSomething` — **RED ON OLD for the label half**, which is the honest description: the marker rendered before, but VoiceOver read it as chrome (`"showing the first 1."` against `"Showing the first 1."`). |
| 10 | **n10** — the "Open note" doors never driven | Both driven on their real mounted surfaces, and the **id carried is asserted**, not merely that something fired — the Archive room opens the archived note itself, a Trash row opens the still-live note the deleted block came from. | `bothRoomsOpenNoteDoorsReallyOpenTheRightNote` — **RED ON OLD** (`"some-other-note" == archivedID` fails). |

## The reds, quoted

**m3** — the windowed read and the marker reverted:

```
✘ Test theVersionsListingIsWindowedAndSaysSo() recorded an issue at
  MobileVersionsTests.swift:533:17: Expectation failed:
  (model.versions.count → 3) == 2
✘ … :534:17: Expectation failed:
  (model → VariorumMobile.MobileVersionsModel).truncated → false
✘ … :536:17: Expectation failed: (labels → ["~/versions", "whole moments of
  this note, saved by hand. …", "Read Jun 30, 2026 at 6:00 PM", ×3])
  .contains(MobileRoomListing.truncationMarker(shown: 2) → "Showing the first 2.")
✘ Test theVersionsListingIsWindowedAndSaysSo() failed after 2.038 seconds
  with 3 issues.
```

**n6** — `closeReader()` removed from the catch:

```
✘ Test aFailedMomentReadLandsOnTheListingNotInAnEmptyReader() recorded an
  issue at MobileVersionsTests.swift:569:13: Expectation failed:
  (model.reading → NoteVersionItem(postID: "00000000-…-000000000004",
  savedAt: 2026-07-01 00:00:02 +0000, blockCount: 1,
  preview: Optional("Readable."), cadence: …manual)) == nil
✘ Test aFailedMomentReadLandsOnTheListingNotInAnEmptyReader() failed after
  0.058 seconds with 1 issue.
```

**m2** — the shipped save-row detail (*"saves this whole note as it is right
now"*) put back:

```
✘ Test theVersionsVocabularyIsSharedAndEveryPhoneVoicedLineIsListed()
  recorded an issue at MobileVersionsTests.swift:421:17:
  Expectation failed: (run → 7) < 6
✘ Test theVersionsVocabularyIsSharedAndEveryPhoneVoicedLineIsListed()
  failed after 0.016 seconds with 1 issue.
```

**m4** — the shell's `onOpenVersions:` wiring dropped (the row still renders
— the door is optional by design, which is exactly why a row-level pin could
not see this):

```
✘ Test theVersionsRowOpensTheRoomThroughTheWholeShell() recorded an issue at
  MobileVersionsTests.swift:614:17: Expectation failed: (labels → ["Rename
  Note", "Copy Note", "Find in Note", "Lock Note", "Note Actions", …,
  "~/library", "Trash", "New Note", …, "Archived", "shelf", "library"])
  .contains(MobileVersionsModel.noVersions → "No saved moments yet — Save a
  Version in ⋯ keeps the whole note as it is right now.")
✘ Test theVersionsRowOpensTheRoomThroughTheWholeShell() failed after 5.494
  seconds with 1 issue.
```

**n9 + n10** — the Archive room's prose-line accessibility label removed and
its `onOpen` pointed elsewhere, in one revert:

```
✘ Test bothRoomsSayWhenTheWindowIsHidingSomething() recorded an issue at
  MobileTrashTests.swift:547:17: Expectation failed: (labels → ["~/archived",
  "kept — no clock", "md", "Unarchive", "Open note", "showing the first 1."])
  .contains(MobileRoomListing.truncationMarker(shown: 1) → "Showing the first 1.")
✘ Test bothRoomsOpenNoteDoorsReallyOpenTheRightNote() recorded an issue at
  MobileTrashTests.swift:586:13: Expectation failed:
  (openedFromArchive.value → "some-other-note")
  == (archivedID → "00000000-0000-0000-0000-000000000000")
```

Every revert was undone and the suite re-run green (below).

## Files

**Product (7):** `MobileVersions.swift` (m1, m2's header, m3, n6) ·
`MobileNoteActions.swift` (m2, m4's comment) · `MobileRecoveryDoors.swift`
(the filterless marker's one home) · `MobileArchiveView.swift` (n9 marker
call + label) · `MobileArchiveModel.swift` (n5) · `MobileTrashModel.swift`
(n5) · `MobileTrashView.swift` (n9 label).
**Tests (2):** `MobileVersionsTests.swift` (+4, one renamed and widened, one
helper) · `MobileTrashTests.swift` (+2, n7's doc, n8's assertions, the n5
call-site update).
**Records (2):** `mobile-batch-6c-record.md` (§1 D4's two dated corrections,
§2's renamed pin + the wave's count line, §3's items 5 and 6, §5's residue
list) · this file.

## Counts and environment

**Final line, quoted:**

```
✘ Test run with 613 tests in 94 suites passed after 180.841 seconds with 2 known issues.
```

The **2 known issues are the same single documented diagnostic test** as the
baseline's — `anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`,
which records two issues from one `withKnownIssue` block. No other test
records an issue. Arithmetic exact: 607 + 6 = 613, suites unchanged.

**Environment:** worktree `~/dev/variorum-mobile`, branch `mobile`. Private
simulator `Variorum-6c-fix` (iPhone 17 Pro, iOS 26.2,
`ApplicationAccessibilityEnabled` armed and read back `1`), private
`-derivedDataPath` under this session's scratchpad; the simulator was
**deleted at the end**. `Package.resolved` never swept. No Release build, no
install, no push; the real store untouched, the live Mac app never quit.

**Fence, verified before the commit:**

```
git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum \
  "*.xcodeproj" "*.pbxproj"   →  (empty)
```
