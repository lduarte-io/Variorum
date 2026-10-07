# Batch 9 — THE ⋯ VOCABULARY + TEXT SELECTION · COLD REVIEW

**Reviewer:** cold reviewer (Opus 5), zero implementation context.
**Date:** 2026-08-31.
**Target:** `0aa6479..1260da4` (one commit — *"Her ⋯ letter lands: takes leaves the
block menu, history moves onto each take, and the selection defect gets a trace
instead of a guess."*).
**Read in full, myself:** `notes/plans/mobile-batch-9-brief.md` ·
`notes/plans/mobile-batch-9-record.md` · the ENTIRE diff (code + record) ·
`CLAUDE.md` · `notes/MobileSoul.md` §2–§5 · her verbatim list
(`notes/author-reports/2026-08-23-device-walk-and-product-asks.md`, as quoted in
the brief) · `notes/KnownIssuesAndTechDebt.md` · and the code:
`MobileBlockMenu.swift`, `MobileNoteActions.swift`, `MobileUndoDoor.swift`,
`MobileTakesBrowser.swift`, `MobileTakesBrowserView.swift`,
`MobileTakesController.swift`, `MobileTakesChrome.swift`,
`MobileBlockHistory.swift`, `MobileEditMenuSeam.swift`, `MobileKeyboardBar.swift`,
`MobileWriteView.swift`, `MobileEditorTextView.swift`, `MobileCommentsSheetView.swift`,
`MobileBlockDecor.swift`, `MobileStructural.swift`, `MobileNoteTray.swift`,
`MobileTutorialSeeder.swift`, `Variorum/Features/Editor/FannedDefaults.swift`,
`Sources/VariorumCore/Queries/TakesQueries.swift`,
`Sources/VariorumCore/Operations/Operations+Structural.swift`, and the four
touched test files + `MobileTutorialWalkTests.swift`.

## What I ran

- **Own fresh simulator** `Variorum-b9-coldreview`, iPhone 17 Pro, **iOS 26.2**
  (the only iOS-26 runtime on this machine; every 16-series sim here is iOS 18.3
  and is not a valid destination). `ApplicationAccessibilityEnabled` armed and
  **read back `1`**. Private `-derivedDataPath` under this session's scratchpad.
  Simulator **deleted at the end**.
- **Full mobile suite at HEAD**, unfiltered, from `App/Variorum/`:
  ```
  ✘ Test run with 666 tests in 99 suites passed after 296.937 seconds with 2 known issues.
  ** TEST SUCCEEDED **
  ```
  The 2 known issues are the ONE documented diagnostic test
  (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`,
  recording two issues), identical to the recorded baseline's. **The load-flaky
  perf pin PASSED** (`typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`,
  ✔ 0.881 s) — no isolated re-run needed. **No runner death observed.**
- **SIX red-on-old reproductions, all six of the record's, all reproduced
  EXACTLY** (§ "Pin quality" below). Every revert was a PRODUCTION revert, taken
  from a pre-revert copy and restored from that copy; `git status` verified clean
  between each.
- **The harness trap reproduced** (`-only-testing:…/MobileTakesBrowserTests` runs
  21 of the file's 30 and stays GREEN under the A2 revert).
- **The fence, re-derived myself** (below).
- `Package.resolved` untouched; the tree is byte-identical to `1260da4` apart from
  this file, which is left UNCOMMITTED.

## Fence — re-derived, both commands

```
$ git diff --name-only 0aa6479..1260da4 -- Sources/ App/Variorum/Shared \
      App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"
(empty)

$ git diff 0aa6479..1260da4 -- '*.swift' | grep -c planVisibleTakeEdit
0
```
No `EditorBrain/` file appears in `git diff --name-only 0aa6479..1260da4`. The
whole diff is six `VariorumMobile/Features/…` files, four
`VariorumMobileTests/…` files, and one `notes/plans/` record. **The selection
trace produced no code at all** — the diff contains not one line of scroll,
selection, gesture or inset handling. Deliverable 5's "nothing was built" is
literally true.

---

## Severity counts

| | |
|---|---|
| BLOCKER | **0** |
| MAJOR | **2** |
| MINOR | **2** |
| NIT | **4** |

---

# FINDINGS

## MAJOR 1 — The `isEditable` stranding defect has NO OWNER outside a plan file that closes

**Where:** `notes/plans/mobile-batch-9-record.md` §4.6; the mechanism lives at
`VariorumMobile/Features/Takes/MobileTakesBrowserView.swift:226-234`,
`VariorumMobile/Features/Write/MobileCommentsSheetView.swift:127-136`,
`VariorumMobile/Features/Takes/MobileBlockHistorySheetView.swift:143-150`.

**Label: MEASURED (the mechanism) + READ-ONLY traced (the absence).**

**Mechanism, which I proved myself rather than taking from the record.** All three
overlay sheets independently do `pageWasEditable = page.isEditable; page.isEditable
= false` on open and `page.isEditable = pageWasEditable` on close. Nest two and the
inner one saves the outer one's `false`, so the last restore leaves the page
**non-editable with no sheet on screen** — her note becomes read-only and nothing
on the surface explains why. I reproduced this exactly by swapping the two lines in
`MobileTakesBrowserController.openHistory` (revert A6):

```
✘ Test theHistoryDoorLeavesThePageEditableAfterwards() recorded an issue at
  MobileMenuVocabularyTests.swift:238:13: Expectation failed:
  (surface.textView → <VariorumMobile.MobileEditorTextView: …>).isEditable → false
```

So the defect is real, is a *text-loss-adjacent* class (she cannot type in her
note), and batch 9's own door is the first road in the app that could produce it.

**What the batch did right, and I confirm it:** `openHistory` closes the browser
BEFORE opening the face, the pairs are properly nested, and
`theHistoryDoorLeavesThePageEditableAfterwards` pins that ordering with a real red.
I also confirmed the *production* ordering is safe and not merely the test's
hand-ordered renders: `onChanged` is a **synchronous** callback
(`MobileEditorTextView.swift:198-214` → `browserView?.render()`), and
`MobileTakesBrowserController.close()` fires `onChanged?()` *before* its
`await refreshTakesFromStore()`, so the restore lands before
`blockHistory.open(…)` runs. The door is safe.

**The finding is what happened to the underlying defect.** It exists ONLY as prose
in §4.6, and its owner line reads *"the natural owner is 13u2's pane work **or** a
17-entry."* That is two candidates, not an owner. I checked every place an owner
could have been filed and found nothing:

- `notes/KnownIssuesAndTechDebt.md` — no row (`grep -n "isEditable\|stranded"`
  returns only the unrelated tray-windowing and version-anchor rows).
- `notes/plans/mobile-round-2.md` — no mention (`grep -n "isEditable"` → nothing).
- `notes/plans/mobile-round-2-orchestrator-handoff.md` §2b handback checklist — no item.
- `git diff --name-only 0aa6479..1260da4 -- notes/` → **only** the batch record.

This is precisely the state `KnownIssuesAndTechDebt.md`'s own header forbids
(*"no entry without naming the phase that resolves it… A blank owner is still
forbidden"*), and the file already contains the precedent that names the harm: the
"six mobile brains" row was **restored** to that file specifically *"because
without it the forked-brain debt had **no owner outside a plan file that
closes**."* The same batch's sibling — batch 6b's cold-review MINOR 1 — *did* get
a KnownIssues row. This one did not.

**Aggravating, and it is the reason this is MAJOR and not MINOR:** §4.6 explicitly
records that *"whether the pre-existing interleave is reachable by any OTHER road
was NOT established"*, so the batch is parking an **unbounded** defect. My own
search for a reachable pre-batch-9 road found none (the two other sheets are
summoned from the keyboard bar at `MobileBlockMenu.swift:182` /
`MobileBlockDecor.swift:259` / `MobileTakesChrome.swift:328`, all of which a
covering sheet hides), which supports the record's guess — but a guess left in a
closing plan file is exactly what a KnownIssues row exists to survive.

**Fix shape.** One row in `notes/KnownIssuesAndTechDebt.md` naming a single owner
(**17b, "text-loss doors"**, is the closest existing entry — the page going
read-only under her fingers is that family; **13u2** is defensible via its item (1)
pane work, but the file's rule wants ONE named owner, not a choice), carrying: the
three file:line save/restore sites, the mechanism in one sentence, the proof that
batch 9's own door is nested correctly, and the un-established half stated as
un-established. The durable remedy sketch belongs in the row too: one shared
stand-down authority (a depth counter or a single `PageStandDown` owner) rather
than three independent save/restore pairs — the same "one authority" shape
`PaneTextAuthority` already is for liveness.

---

## MAJOR 2 — The TUTORIAL still teaches the retired door, in two shipped lessons, and its own pin cannot see it

**Where:** `App/Variorum/VariorumMobile/Features/Tutorial/MobileTutorialSeeder.swift:369-371`
and `:701-704`. The blind pin is
`App/Variorum/VariorumMobileTests/MobileTutorialWalkTests.swift:1373`.

**Label: READ-ONLY traced** (the removal itself I proved by reverts A2 and A4).

**Mechanism.** The batch removed `Block History…` from the block ⋯ — verified by
revert A4, which reds `theBlockMenuNoLongerCarriesTheHistoryDoor` and
`theHistoryCopyIsPinnedAndPlatformFree`. Two seeded lessons still name that
retired row as the road, and both ship: `MobileTutorialSeeder.findOrSeed` /
`.restore` are wired to `MobileSettingsView.swift:430,466`, so these sentences are
written into her pocket guide as note text.

1. **The savepoints lesson**, `:369-371`:
   > *"Commit Take, in ⋯, keeps the exact text of the take you're in, forever —
   > **and Block History… beside it** opens everything this block has been…"*

   `Commit Take` is still in the block ⋯ (correct); `Block History…` is not beside
   it, and is not in that menu at all.

2. **The five-places lesson, item 5**, `:701-704` — and this is the damaging one,
   because it is the ONLY place the guide teaches how to REACH the face:
   > *"5 — THIS BLOCK'S HISTORY: one block's whole time. **⋯ on the bottom bar,
   > then Block History…** — every take's saved moments, the takes this block
   > archived or deleted, and the block it came out of."*

   Following that instruction now opens a nine-row menu with no history row. This
   is P-2's own class, in the direction the phone's doctrine cares about most: not
   a dead door, but a *taught* road that cannot act. It matters more than usual
   here because the Block History face is now the **sole** door to the *came from*
   and *deleted takes* regions — the record's own §3 table says so ("*there is no
   second one*"), and I confirmed it: `grep -rn "blockHistory\.open" VariorumMobile/`
   returns **exactly one** production caller, the new per-take row.

**Why the suite did not catch it, which is the second half of the finding.**
`theFivePlacesLessonNamesEveryPlaceAndItsPhoneRoad` asserts, under the comment
*"The roads, in the phone's own words"*:

```swift
#expect(prose.contains(BlockHistoryPath.name))
```

That is the FACE's name (`"Block History"`), not the ROAD. The lesson's navigation
sentence can be arbitrarily wrong and the pin stays green — a green over nothing
for exactly the claim this batch invalidated. The full suite ran 666/99 green with
these two false sentences in the store.

**Scope check, done rather than assumed:** the `Takes…` removal left the tutorial
**correct** — the bottom-bar lesson (`:363-366`) already attributes takes to ⑂ and
never lists `Takes…` under ⋯, and the seeder's only other ⋯ references (`:554`
Divide Block, `:688` Archive Block) both still exist in that menu. So this finding
is exactly two sentences, both about Block History.

**Fix shape.** Re-word both to the new road, composing rather than re-typing:
the takes act from `MobileKeyboardBarController.restingActLabels[1]`, the row from
`MobileTakesBrowserController.historyTitle` (which is already composed from
`BlockHistoryPath.name`) — e.g. *"⑂ on the bottom bar, then a take's ⋯, then Block
History…"*. Then give the pin teeth: assert the lesson names the takes road AND
does not attribute the face to the block ⋯ (`#expect(!prose.contains("⋯ on the
bottom bar, then \(BlockHistoryPath.name)"))` or the positive equivalent).
**Red-on-old is available and cheap:** restore either sentence and the strengthened
pin reds.

---

## MINOR 1 — The merge proposal (§5) misstates "what exists today, precisely" in two ways that change its own recommendation

**Where:** `notes/plans/mobile-batch-9-record.md` §5. Nothing is built from it —
I confirmed the diff carries zero merge/structural lines — so this is a
*document* finding, but the document goes to her sitting bundle under the heading
*"What exists today, **precisely**"*.

**Label: READ-ONLY traced.**

**(a) "The op underneath is NOT binary."** It is. Both core ops are binary:

```
Sources/VariorumCore/Operations/Operations+Structural.swift:659:
    public func merge(_ firstBlockID: String, _ secondBlockID: String) throws -> MergeResult
Sources/VariorumCore/Operations/Operations+Structural.swift:836:
    public func mergeCeremony(   // (leading, trailing, pairings:, carries:)
```

The 9d N-way merge is a **Mac door-level chain of binary links inside a compound**
— `EditorSurfaceController.swift:316` (`case .mergeChain(let indices, let
blockIDs)` → `runMergeChain`) over `CarryAllMerge.chainComposes`
(`Variorum/Features/Editor/FannedDefaults.swift:104`). That brain is
**Mac-app-local**: `grep -rn "CarryAllMerge" Variorum/ VariorumMobile/ Shared/`
returns three Mac files and **zero** phone or `Shared/` files. And the phone's
single merge door does **no chaining at all** — `MobileStructural.mergeWithPrevious`
(`:202-314`) resolves exactly one leading/trailing pair and calls `mergeCeremony`
or `merge` once.

**(b) "The Mac's own multi-merge affordance is ⌘-click take selection (13e), which
has no phone twin"** omits the Mac's **Write-surface block-run merge chain**, which
is shape (A) itself, already shipped, with its own copy
(`FannedDefaultsCopy.mergedChain(blocks:carried:)`) and its own pairwise refusal
(`mergeCeremonyIsPairwise(blocks:)`).

**Consequence for her sitting, which is why this is worth a finding.** §5's
recommendation says (A) *"costs nothing new because batch 7 is already building the
selection it needs"* and *"joins the run through the same N-way chain the single
door uses."* Neither holds. Beyond batch 7's selection, (A) needs the chain
composition, the pre-compound validation, and the compound itself — and MobileSoul
§3's rule says a Mac brain the phone needs is **hoisted**, not re-derived, so (A)'s
real cost includes a `Shared/` hoist of `CarryAllMerge` (fenced this round, hence
a future batch's). Read correctly, (A) also gets *stronger*, not weaker: it stops
being a phone invention to be designed and becomes a shipped Mac gesture to mirror.

**Observation riding with it, not a separate finding.** The phone already
re-derives `CarryAllMerge.compose` by hand — `MobileStructural.swift:284-288`
(pairing + `MergeJoin.canon` + `carries` filter) is logic-identical to
`FannedDefaults.swift:71-78`. This is a live instance of the forked-brain class and
is **not** on `KnownIssuesAndTechDebt.md`'s eight-brain table. It is pre-existing
(the phone shipped first at parity C5; the Mac copied it at 13j and says so), so
it is not this batch's to fix — but it belongs on that existing row, whose owner
(*"the mobile app project row… any Mac phase touching one of these brains hoists it
THEN"*) already covers it, so adding it leaves nothing blank-owner.

**Fix shape.** Three sentence-level corrections in §5 before the bundle goes to
her: the core ops are binary; the N-way chain is a Mac door-level composition whose
brain is Mac-app-local; the Mac's Write surface already has the block-run merge
that (A) proposes. Then restate (A)'s cost honestly (batch 7's selection **plus** a
`CarryAllMerge` hoist) — which is still small, and still the right recommendation.

---

## MINOR 2 — §4.3's rule-out #1 may be a green over nothing, and §4.3 says "do not re-open these"

**Where:** `notes/plans/mobile-batch-9-record.md` §4.2/§4.3 item 1
(`PROBE storageEqualAfterScroll=true`). The gating code is
`MobileTakesChrome.swift:195`, `MobileBlockDecor.swift:119`,
`MobileBlockDecor.swift:193`.

**Label: READ-ONLY traced** (the probe is deleted, so the measurement itself
cannot be re-run — which is half the finding).

**Mechanism.** The rule-out kills the *leading* hypothesis — *"the chrome refresh
writes paragraph styles mid-drag and cancels the selection interaction"* — with a
before/after `NSAttributedString` equality over a **120-block / 19,689-character**
post. But every storage-**writing** branch of that refresh is conditional:

```
MobileTakesChrome.swift:195   for slot in model.slots where slot.hasFan {   → setTailReservation
MobileBlockDecor.swift:119    guard let presentation = model.presentations[slot.blockID] else { continue }
MobileBlockDecor.swift:193    for slot in model.slots where slot.commentCount > 0 {
```

and `setTailReservation` itself writes only on real change
(`MobileEditorTextView.swift:424`: `guard abs(style.tailIndent - target) > 0.01
else { return false }`). So on a fixture with **no fanned block, no callout and no
commented block**, the write path is *structurally unreachable* and
`storageEqualAfterScroll=true` holds by construction — proving nothing about the
hypothesis it was taken to kill. The record never says what its fixture carried,
and the probe (`ZZProbeSelectionScroll`) was deleted before commit
(`grep -rn "ZZProbe"` → nothing), so no reader can check.

**Why it matters rather than being pedantry:** §4.3 is headed **"RULED OUT by
measurement (do not re-open these)"**, so a future session — including whoever runs
her device experiment — is instructed not to re-examine the most likely candidate.
And her real notes carry fans: fanned blocks are exactly the shape that reaches the
write path, and exactly the shape her ⑂ and swipe-peek work lives on.

**What survives untouched:** rule-outs 3 and 4 I verified independently and they are
sound — `contentInset` is never written by the app
(`grep -rn "contentInset" VariorumMobile/ Shared/` outside `Spike/` → nothing), and
there is no `caretRect(for:)`/`selectionRects(for:)`/`textViewDidChangeSelection`
override anywhere in the app. Rule-out 2's stimulus (a bounds change) is fairly
measured for the hypothesis it names. Candidates S1/S2/S4 and the device
experiment (§4.5) are well shaped, and the record's own honesty about S3's
**confounded** probe sweep is exactly right and should stay said.

**Fix shape.** Either (i) re-take the measurement on a fixture carrying at least one
FANNED block plus one callout and one commented block — the only three shapes that
reach the writers — or (ii) downgrade item 1 from *ruled out* to **"not exercised
— the write path was unreachable on the fixture"** and leave the hypothesis live
for her device pass. Whichever, keep the probe as a `#if DEBUG` diagnostic so the
numbers are re-derivable; a rule-out whose evidence was destroyed cannot carry a
"do not re-open" instruction.

---

## NIT 1 — `theTwoDoorsShareOneVocabulary`'s second half is now a literal duplicate of its first

`App/Variorum/VariorumMobileTests/MobileBlockMenuTests.swift:96-105`. With
`includeTakes:` retired, both halves call `model.blockMenu.menuElements(blockID:
seed.blockA)` and compare to the same oracle (`rowTitles.map(cased)`), so deleting
the "submenu" half changes no coverage. Nothing anywhere drives
`MobileEditMenu.menu`'s **Block submenu children** —
`MobileStructuralTests.swift:1016-1027`, `MobileBlockMenuTests.swift:153-161` and
`MobileTakesBrowserTests.swift:872` all check the menu's TOP-level titles only — so
the production claim at `MobileBlockMenu.swift:256` (*"the two doors… ONE builder
decides the words and the order"*) and at `MobileEditMenuSeam.swift:83` is unpinned
at the seam. **No coverage was lost** (the pre-batch arms also both tested the
builder, never the seam), which is why this is a NIT. Fix shape: replace the
duplicated half with one that composes through `MobileEditMenu.menu(model:range:
suggested:)` and reads the `Block` submenu's children — that would pin the claim
the comment makes, for the same number of lines.

## NIT 2 — One assertion in the new suite is a constant compared to its own literal

`MobileMenuVocabularyTests.swift:109`: `#expect(MobileKeyboardBarController
.restingActLabels == ["Formatting", "Takes", "Block"], "⑂ is literally the middle
of the resting three")`. In isolation this cannot fail. **Mitigated, and I checked:**
`MobileMarkdownTests.swift:662` anchors that same constant to the real bar's rendered
items (`#expect(labels() == MobileKeyboardBarController.restingActLabels)`), and
`MobileKeyboardBar.swift:596` is the real `#selector(fireTakes)` act — so the
suite-wide claim is sound and the DRIVE half of that pin (`bar.fireTakes()` →
`model.takesBrowser.isOpen` on the caret's block) is genuine and non-vacuous. Only
the one line is decorative.

## NIT 3 — Three production comments still assert the pairing the batch deliberately ended

`MobileBlockMenu.swift:283-287` now says her G2 commit/history pairing *"ends here,
deliberately and visibly"*, but two other headers still draw it as current:
`MobileNoteActions.swift:26` (`block ⋯ → Commit Take + Block History…`) and
`MobileVersions.swift:28` (`block ⋯ = Commit Take + Block History…`). Both are the
*teaching* comment for the two-grains design, so a next reader learns a menu shape
that no longer exists. Also `MobileUndoDoor.swift:258,267` tells her the set-aside
writing *"is saved first, so you can bring it back from the block's Block History at
any time"* — still TRUE (the face exists), but the road behind that sentence went
from one tap to three and the sentence names no road. Fix shape: one sweep, and
where a road is named, compose it rather than re-type it.

## NIT 4 — §4.4 does not say that her own words argue against S3

The S3 candidate is the app's `MobileTakesPanRouter`, whose gate is **horizontal
dominance** — verified at `MobileTakesChrome.swift:566-567`
(`abs(translation.x) > abs(translation.y) * 1.5, abs(translation.x) > 4`) plus
`panTargetBlockID`'s `hasFan == true` at `:551`, exactly as the record states. Her
verbatim report is about dragging **"up and down"**. A near-vertical drag cannot
open that gate, so her own geometry is evidence *against* S3, and §4.4 claims its
candidates are ranked by evidence. Keeping S3 on the list is still right — it is
app-local and one of her three questions kills it outright — but the table should
say the geometry runs the other way. (Its "how to kill it" row already asks the
right question.)

---

# CLEAN BILL — what I attacked and could not break

**The verify-first inventory (deliverable 1) is honest, and its headline claim is
stronger than the record needed it to be.** I confirmed independently that
`MobileNoteActions.swift` — the note ⋯ **itself** — was born at `e7e2472`, dated
**2026-08-22**, one day after the 2026-08-21 build her phone runs
(`git log --diff-filter=A`, and `git log -S"noteActionsDoor"` puts the masthead door
in the same commit). So *"on her build there was no note ⋯ at all"* is true, and
"already built, not rebuilt" is a dismissal with evidence rather than an excuse.
The rows render and act: both are P-2-gated on a live stack end
(`MobileNoteActions.swift:246-272`), the labels are the stack's own
(`MobileUndoDoor.undoLabel`/`redoLabel` → `session.undoMenuState`), and `redoRow`
calls the real `door.redo()`. **The tap count is honest**: the masthead is a
`.safeAreaInset(edge: .top)` (`MobileWriteView.swift:168`), so the ⋯ genuinely does
not scroll away and needs no keyboard — ⋯ then the row is two taps, and the
receipt's one-tap road is real (`report(_:action:)`).

**The redo pin has real teeth, and I proved the gap it closes was real.** Under
revert A5 (`redoRow` deleted from the sheet body) the new pin reds with three
issues **while the entire pre-existing `MobileUndoDoorTests` suite (11 tests) stays
green** — so the record's *"redo had a RECEIPT pin and no SHEET pin"* is exactly
right, and the new pin is not duplicating existing coverage.

**The `Takes…` removal is complete and the surviving door is genuinely driven.**
The absence pin runs over a **nine-row** menu (never vacuous), and the same test
fires the real `#selector` target of the bar's ⑂ act
(`MobileKeyboardBar.swift:596` → `fireTakes()` → `openTakesBrowserAtCaret()`) and
asserts `takesBrowser.isOpen` on the caret's block. The `includeTakes:` parameter's
death left **no caller half-migrated** — `grep -rn "includeTakes"` returns nothing
anywhere in the tree, both call sites (`MobileKeyboardBar.swift:770`,
`MobileEditMenuSeam.swift:87`) take the new signature, and the edit menu's own flat
`Takes…` survives with its reasoning intact: I verified the Block submenu now
carries the same nine rows it carried before (`rowTitles.dropFirst()` was nine;
`rowTitles` is now nine), so the edit menu shows **no duplicate takes door**. The
"she named the ⋯, not the selection's menu" argument holds at the code.

**The Block History move is correct, and its completeness claim survives the check
the record only asserted.** The per-take row opens the face **focused on the pressed
take** — driven through the real `UIAction` handler, with the id asserted
(`focusedVariantID == seed.a2`), the expansion asserted (`expandedTakes == [seed.a2]`)
and the rendered savepoints asserted (`savepoints == [seed.a2]`), on the take that
is deliberately NOT the block's displayed one. The block-⋯ removal has its own
absence pin over a populated menu. And the load-bearing completeness claim — *"I10
means the browser always renders at least one live card carrying the door"* — is
**true for FANLESS blocks too**, which is the case that could have silently orphaned
the face: `Queries.activeFans` (`TakesQueries.swift:119-136`) populates an entry for
**every** requested block, so `MobileTakesBrowserController.cards()` renders one card
for a one-take block and that card carries the ⋯. I checked the regions:

- **savepoints** — the browser road, on every live block ✔
- **archived takes** — the browser's own archived section is a real second road
  (`archivedCards()` + `reloadArchived()`, per-card Unarchive/Delete) ✔
- **deleted takes** — `blocks ▸ leaving` is real (`MobileNoteTray.swift`, the
  `leaving` segment) ✔
- **came from** — the record says "no second road", which is *conservative*: the
  per-note tray's `stranded` listing and `MobileTrashView`'s `.preservedOriginal`
  rows reach the same data at other grains. Understating reach is the safe error.

I also checked two states that could have closed silently and did **not**: a
**sealed** note still reaches the face (the browser's `open` guards only `slot.isGap`;
the card ⋯ has no seal gate; and `MobileEditMenu`'s flat `Takes…` rides
`UITextViewDelegate.textView(_:editMenuForTextIn:…)`, which a selectable-but-not-
editable text view still gets), and rapid double-taps on the new row cannot
double-open (`openHistory`'s `guard let blockID = openBlockID` fails for the second
task, because `close()` nils it synchronously).

**The one closed road is disclosed accurately.** A **gap** block's history really is
unreachable now: `MobileTakesBrowserController.open` refuses on `slot.isGap` with a
worded refusal (*"This block hasn't fully synced; it is read-only for now."*), and
`grep -rn "blockHistory\.open"` confirms the retired block-⋯ row was the only other
production door. The refusal speaks, the closure is named at the code AND as
PROVISIONAL 3, and its "thin by construction" caveat is honest (it says *"at most
deleted takes and origins"*, so it does not oversell the thinness). **Nothing else
closed silently** — the archived-take card's deliberate omission is real and its
mechanism checks out: `rows()` sections `history.activeTakes` only
(`MobileBlockHistory.swift:359,386`) while `BlockHistoryExpansion` reads
`history.takes`, so an archived focus would expand nothing.

**The `commitNow` rider genuinely did not fire.** The new row opens a face and
writes nothing; `commitNow` still has exactly one caller.

**Deliverable 5 stayed inside its fence and built nothing.** No `EditorBrain/`,
no `Shared/`, no `Sources/`, no scroll/selection/gesture code of any kind; the
throwaway probe was really deleted. The reproduction attempt's honesty is exactly
right — touch synthesis is private API and the unit harness never presents a
keyboard, so "not reproducible here, and here is the road that could" is the
correct answer, not a shortfall.

**Pin quality: SIX reverts, six exact reproductions, every one PRODUCTION.**

| revert | what I changed (production) | result |
|---|---|---|
| **A1** | re-added the `Takes…` `UIAction`, the `takesTitle` constant and its `rowTitles` entry in `MobileBlockMenu.swift` | RED, both sides, verbatim: `theBlockMenuDropsTakes…` 2 issues + `theTwoDoorsShareOneVocabulary` (`barTitles.first → "takes…"`) |
| **A2** | dropped the history `UIAction` from `MobileTakesCardView.apply`'s menu | RED: `theTakeCardsMenu…` **8 issues** at the recorded lines + `theCardGrammarRenders…` |
| **A3** | `open(blockID:focused:)` → `focusedVariantID = slot.variantID` | RED: 3 issues, lines 164/166/175, focus/expansion/savepoints only — the door still opened, which is the isolating property claimed |
| **A4** | re-added `historyTitle` + its element to the block ⋯ | RED: `theBlockMenuNoLongerCarries…` + `theHistoryCopyIsPinnedAndPlatformFree` |
| **A5** | deleted `redoRow` from `MobileNoteActionsSheet`'s body | RED: 3 issues; `MobileUndoDoorTests` (11) stayed GREEN — the gap was real |
| **A6** | swapped `openHistory`'s two lines | RED: page left `isEditable → false` |

Every quoted line in the record's §7 matched what I got, including the printed
label lists and variant ids. **The harness trap is real and I reproduced it**:
under the A2 revert, `-only-testing:VariorumMobileTests/MobileTakesBrowserTests`
reported `✔ Test run with 21 tests in 1 suite passed`, hiding the card-grammar red
that appears the moment `MobileTakesBrowserSurfaceTests` is named too. That warning
is worth keeping in front of the next session.

**Counts reconcile.** `MobileMenuVocabularyTests` declares exactly 5 `@Test` in 1
new `@Suite`; 661/98 + 5/1 = **666/99**, which is what the unfiltered run reported.

---

## Environment teardown

Simulator `Variorum-b9-coldreview` deleted. `Package.resolved` untouched. The real
store was never opened, no Release build, no install, no commit, no push. The
working tree is byte-identical to `1260da4` except for this file, left
**UNCOMMITTED**.

---

# ADJUDICATION + FIX-WAVE BRIEF (the Fable orchestrator, 2026-08-31)

**ALL EIGHT ACCEPTED, ZERO DISPUTES.** Two MAJORs at round 1 ⇒ one fix
wave now, and the orchestrator's verification of the wave's diff closes
the unit (the filter unit's precedent: both MAJORs' fixes are
record/copy/pin-mechanical, verifiable without a fourth session).
Adjudicated shapes:

1. **MAJOR 1 — the stranded-`isEditable` defect gets a COMMITTED owner,
   and the architect rules the fix's shape now** so the owner inherits a
   decision: the per-sheet boolean save/restore is replaced by ONE
   nesting-aware editability authority on the write surface (a depth
   count — sheets push/pop; the page is editable only at depth 0 — or an
   equivalent restore-to-rest rule; the builder picks the minimal shape
   and pins the reviewer's own two-sheet interleave red-on-old).
   **Owner: the leftover-review-backlog consolidated batch** (the seat
   road's item 7 — in-round, phone-local, days away). The wave does the
   RECORD half: add the defect to that batch's row in
   `mobile-round-2-handoff-2026-08-30.md` §7.2 (the authoritative
   schedule), and amend the batch-9 record §4.6's "candidates" sentence
   to name the committed owner. The defect itself is NOT fixed in this
   wave (the record's design-before-mechanism hedge was right; the
   design is now made).
2. **MAJOR 2 — the tutorial stops teaching the retired door, in-wave.**
   Re-word both lessons (`MobileTutorialSeeder.swift`, the two sites the
   review names) to the REAL road — Takes (the middle bar) → the take
   card's ⋯ → `Block History…` — re-teaching, not door-name
   substitution, since the second lesson is the guide's only road to the
   came-from and deleted-takes regions. Strengthen the walk pin to
   assert the ROAD (the lesson text names the door that exists; a
   revert to the old wording reds). P-6 is the reason this is MAJOR:
   the tutorial is the executable spec, and a green suite over a false
   instruction is the exact failure P-6 exists to catch.
3. **MINOR 1 — correct §5's "what exists, precisely" in place**: the
   core ops are binary; the N-way chain is a Mac DOOR-level composition
   (brain Mac-app-local); the phone's single door does no chaining; and
   the Mac's shipped Write-surface block-run merge exists and is shape
   (A)'s true precedent. Re-frame (A)'s "costs nothing new" honestly.
   The recommendation itself STANDS — corrected provenance makes it
   stronger, as the reviewer says.
4. **MINOR 2 — re-run the rule-out-#1 probe with a LOADED fixture** (a
   fanned block + a presentation + a comment, so the gated
   storage-writing branches actually execute) and replace §4.3's #1 with
   the honest result either way; if the probe cannot be resurrected
   cheaply, narrow #1's claim to the plain-block scope it actually
   measured and strike the "do not re-open" for the gated branches.
5. **NITs 1–4**: de-duplicate the vocabulary pin's cloned half (or point
   it at the unpinned edit-menu seam, which is the better spend); fix
   the constant-vs-own-literal assertion; correct the three production
   comments still asserting the retired commit/history pairing; add the
   reviewer's geometry note to §4.4 (her "up and down" wording argues
   against S3 — worth her seeing beside the candidate table).

**ONE Opus fix session, the items above, then the orchestrator verifies
and closes.** Fence and environment exactly as the batch brief (own
armed simulator, private DerivedData, deleted after; full suite at the
end — baseline 666/99 + 2 known issues — final line quoted; the
load-flaky pin isolated-re-run if red; `Package.resolved` never swept;
fence grep empty before the pathspec-limited commit; no pushes; reverts
restored from pre-revert copies). Every behavioural change proven red by
behavioural revert with output quoted, production or fixture named.
Append a FIX WAVE RESULTS section to THIS file before the final message.

---

# FIX WAVE RESULTS (Opus fix session, 2026-08-31)

**All five adjudicated items executed; nothing beyond them.** Two production
behaviour changes (MAJOR 2's two lessons), two production isolation changes that
serve them, three production comment corrections, three test changes, four
document amendments. **The reds below are all PRODUCTION reverts**, each taken from
a pre-revert copy under
`…/scratchpad/fixwave-prerevert/` and restored from that copy (md5-verified on
restore — never `git checkout --`, since every reverted file is one this wave also
edits or shares a build with).

## Environment

*[removed for publication]*
  **iPhone 17 Pro, iOS 26.2** — the only iOS-26 runtime on this machine; every
  16-series sim here is iOS 18.3 and is not a valid destination.
  `ApplicationAccessibilityEnabled` armed and **read back `1`**. Private
  `-derivedDataPath` under this session's scratchpad. Simulator **deleted at the end**.
- **`Package.resolved` never drifted** (`git status --porcelain -- "*Package.resolved"`
  empty at commit). No Release build, no install, no push. The real store was never
  opened; the live Mac app was never quit.
- **No runner death observed** in this wave; the load-flaky perf pin
  (`MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`,
  KnownIssues, owner 12) **PASSED** in a re-run beside `MobileTrashTests`
  (`✔ … passed after 1.064 seconds`), so no isolated re-run was owed.
- **The harness trap was respected**: every filtered run named suites by STRUCT name
  (`MobileMenuVocabularyTests`, `MobileBlockMenuTests`,
  `MobileTutorialWritingWalkTests`, `MobilePocketGuideDeletionTests`), never by file,
  and the closing run was unfiltered.

## Final suite line, quoted

```
✘ Test run with 667 tests in 99 suites passed after 301.008 seconds with 2 known issues.
** TEST SUCCEEDED **
```

**Baseline 666 / 99 + 2 known issues → 667 / 99 + 2 known issues.** The **+1** is
exactly one new walk pin (`theSavepointLessonTeachesRoadsThatStillExist`, joining the
existing `MobileTutorialWritingWalkTests` suite — hence +0 suites). The **2 known
issues are the SAME single documented diagnostic test** as the baseline's, verified by
name in a targeted re-run:

```
✘ Test anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor() recorded a known issue at MobileTrashTests.swift:781:17: Issue recorded
✘ Test anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor() recorded a known issue at MobileTrashTests.swift:780:36: Issue recorded
✘ Test anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor() passed after 0.434 seconds with 2 known issues.
```

No other test records an issue.

---

## Item 1 — MAJOR 1 · the stranded `isEditable` gets a COMMITTED OWNER · **RECORD HALF DONE, defect deliberately NOT fixed**

**Executed exactly as adjudicated: the record half only.** The ruled fix (one
nesting-aware editability authority replacing the three per-sheet save/restore pairs,
pinned red-on-old against the reviewer's own two-sheet interleave) is written down for
the owner to build; **this wave changed no sheet code**, and the diff proves it —
`MobileTakesBrowserView.swift`, `MobileCommentsSheetView.swift` and
`MobileBlockHistorySheetView.swift` are all untouched.

**Where the owner now lives:**

1. **`notes/plans/mobile-round-2-handoff-2026-08-30.md` §7.2** — the authoritative
   schedule. The leftover-review-backlog row is retitled **"THE LEFTOVER REVIEW
   BACKLOG (the seat road's item 7)"** and now carries the defect in full: the three
   file:line save/restore sites, the mechanism in one sentence, its
   text-loss-adjacent severity, the ruled fix shape with its red-on-old, the note that
   batch 9's own door is already correctly nested and keeps its A6 pin, and the
   un-established half **stated as un-established**.
2. **`notes/plans/mobile-batch-9-record.md` §4.6** — the two-candidate sentence
   (*"the natural owner is 13u2's pane work or a 17-entry"*) is **superseded in place**
   by a new subsection naming the single owner, quoting the superseded wording so the
   change is legible, and carrying the same four facts.
3. **`notes/plans/mobile-round-2-fable-seat-handoff.md` item 7** — a pointer, so the
   seat road and the schedule cannot drift apart.
4. **`mobile-batch-9-record.md` §9's PROVISIONAL 8** amended to match.

**Deviation from the reviewer's suggested location, and why.** The finding's fix shape
proposed a row in `notes/KnownIssuesAndTechDebt.md` (owner 17b or 13u2).
**Adjudication routed it to the round's own schedule instead**, and that is what was
built: the committed owner is an **in-round, phone-local batch days away**, not a
phase — 13u2 is a Mac phase behind this round's fence, and a 17-entry would move a
phone-local defect out of the round that found it. The reviewer's underlying
requirement — *an owner that survives a closing plan file* — is met by §7.2, which is
the round's durable schedule and outlives every batch record. **No blank owner
remains.**

**No red owed** (no behavioural change).

---

## Item 2 — MAJOR 2 · the tutorial stops teaching the retired door · **FIXED, two lessons, two new reds**

Both shipped sentences re-taught to the road that **exists**, composing rather than
re-typing.

- **`MobileTutorialSeeder.swift`, the savepoints lesson** (writing ▸ blocks & typing):
  *"Commit Take, in ⋯ … and Block History… beside it"* becomes
  *"…\(commitTitle), in ⋯, keeps the exact text of the take you're in, forever — and
  the moments themselves are read back one door along: **⑂ on the bottom bar opens
  this block's takes, and each take's own ⋯ carries \(historyTitle)**, which opens
  everything this block has been…"*
- **`MobileTutorialSeeder.swift`, the five-places lesson item 5** — the guide's ONLY
  road to the *came from* and *deleted takes* regions:
  *"⋯ on the bottom bar, then Block History…"* becomes
  *"**⑂ on the bottom bar opens this block's takes; each take's own ⋯ carries
  \(historyTitle)**"*.

**The words are COMPOSED**, per the finding's fix shape:
`MobileBlockMenuController.commitTitle` for the act that stayed, and
`MobileTakesBrowserController.historyTitle` — itself composed from the SHARED
`BlockHistoryPath.name` — for the row that moved. **This required two production
isolation changes, disclosed rather than buried:** both statics live on `@MainActor`
controllers and `MobileTutorialSeeder` runs off the main actor, so
`commitTitle` and `historyTitle` are now `nonisolated` (a `let` of a `String` and a
pure computed `String` over a `nonisolated enum` — no state crosses, no behaviour
changes, and both are documented at the declaration with the reason).

**The pins now assert the ROAD, not the face's name.**

- `theFivePlacesLessonNamesEveryPlaceAndItsPhoneRoad` — the line
  `#expect(prose.contains(BlockHistoryPath.name))` is replaced by three: the row's own
  composed title, a positive on the takes road, and a **negative refusing the retired
  road**.
- **NEW:** `theSavepointLessonTeachesRoadsThatStillExist` (in
  `MobileTutorialWritingWalkTests`) — asserts both doors against the menus that carry
  them: `Commit Take` must still be a `rowTitles` entry, and **no `rowTitles` entry may
  contain "history"**, so a future move reds here rather than shipping a false
  instruction.

### RED B1 — the five-places lesson (production revert: the pre-batch-9 sentence restored)

```
✘ Test theFivePlacesLessonNamesEveryPlaceAndItsPhoneRoad() recorded an issue at MobileTutorialWalkTests.swift:1422:13: Expectation failed: (prose → "Everything you have ever written here is in exactly ONE of five places. …
✘ Test theFivePlacesLessonNamesEveryPlaceAndItsPhoneRoad() recorded an issue at MobileTutorialWalkTests.swift:1424:13: Expectation failed: !((prose → "Everything you have ever written here is in exactly ONE of five places. …
✘ Test theFivePlacesLessonNamesEveryPlaceAndItsPhoneRoad() failed after 0.299 seconds with 2 issues.
✘ Test run with 4 tests in 1 suite failed after 0.806 seconds with 2 issues.
** TEST FAILED **
```

**Note which lines reddened, because it IS the finding**: 1422 (the `⑂ on the bottom
bar` positive) and 1424 (the negative). **Line 1420 — the composed row title — stayed
GREEN**, because the retired sentence also contains the string `Block History…`. That
is the reviewer's point reproduced exactly: the old face-name assertion could not see
this defect, and the two new assertions are what catch it.

### RED B2 — the savepoints lesson (production revert: the pre-batch-9 sentence restored)

```
✘ Test theSavepointLessonTeachesRoadsThatStillExist() recorded an issue at MobileTutorialWalkTests.swift:640:13: Expectation failed: !((prose → "Everything you write is made of BLOCKS — paragraph-sized pieces …
✘ Test theSavepointLessonTeachesRoadsThatStillExist() recorded an issue at MobileTutorialWalkTests.swift:642:13: Expectation failed: (prose → "Everything you write is made of BLOCKS — paragraph-sized pieces …
✘ Test theSavepointLessonTeachesRoadsThatStillExist() failed after 0.217 seconds with 2 issues.
✘ Test run with 3 tests in 1 suite failed after 1.000 seconds with 2 issues.
** TEST FAILED **
```

Line 640 is the *"…beside"* negative; 642 is the takes-road positive.

**Store safety, recorded because these lessons are note TEXT.** `MobileTutorialSeeder`
is reached only from the DEBUG-only Settings door, and Debug builds resolve the **dev
store** by construction (the A4 fence at the file's own header); every run in this wave
was an in-memory test world. **The real store was not opened at any point.** The
standing consequence stands and is stated so nobody re-derives it: **an already-seeded
pocket guide keeps the old sentences until it is re-seeded** — `findOrSeed` returns an
existing book untouched — so **the corrected lessons reach her phone on its next
install + Restore**, and reach her Mac not at all (this is the phone's own seeder; the
Mac's field guide was never wrong here). That re-seed is an install-time concern, not
this wave's.

---

## Item 3 — MINOR 1 · §5's "what exists today, precisely" · **THREE CORRECTIONS LANDED**

`mobile-batch-9-record.md` §5, in place, with a leading note saying why (it goes to her
sitting bundle under a heading that promises precision):

1. **"The op underneath is NOT binary" was WRONG and is reversed.** Both core ops are
   binary (`Operations+Structural.swift:659` `merge(_:_:)`, `:836` `mergeCeremony`).
   The 9d N-way merge is a **DOOR-level composition** — `EditorSurfaceController.swift:316`'s
   `.mergeChain` over `CarryAllMerge.chainComposes` — whose brain is **Mac-app-local**
   (three Mac files, zero phone or `Shared/` files), **and the phone's single door does
   no chaining at all** (`MobileStructural.mergeWithPrevious:202-314` resolves one pair
   and calls once).
2. **The Mac's Write-surface block-run merge chain is named** — shape (A) itself,
   already shipped, with its own copy (`FannedDefaultsCopy.mergedChain`) and its own
   pairwise refusal. 13e's ⌘-click TAKE selection survives in the sentence as the
   different grain it is.
3. **(A)'s cost restated honestly.** *"Costs nothing new because batch 7 is already
   building the selection it needs"* is replaced by the real bill: batch 7's selection
   **plus** the chain composition, the pre-compound validation, the compound, and —
   under MobileSoul §3 — a `Shared/` **hoist of `CarryAllMerge`** rather than a
   re-derivation. Fenced this round, so a future batch's.

**The recommendation STANDS and reads stronger**, as the reviewer predicted: (A) stops
being a phone invention to design and becomes a shipped Mac gesture to mirror.

**The riding observation is recorded, not fixed** (it is pre-existing and already
owned): the phone re-derives `CarryAllMerge.compose` by hand at
`MobileStructural.swift:284-288`, logic-identical to `FannedDefaults.swift:71-78`. It
belongs on `KnownIssuesAndTechDebt.md`'s eight-brain row, whose owner (*"any Mac phase
touching one of these brains hoists it THEN"*) already covers it — so nothing is
blank-owner. §5 now says so, and says that this fork and the hoist (A) needs are **the
same piece of work**.

**No red owed** (document only — the diff carries zero merge/structural lines).

---

## Item 4 — MINOR 2 · the rule-out re-taken on a LOADED fixture · **RE-MEASURED; the rule-out SURVIVES, now honestly**

The reviewer was right that the original measurement proved nothing: every
storage-writing branch of the chrome refresh is conditional
(`MobileTakesChrome.swift:195` `where slot.hasFan`; `MobileBlockDecor.swift:119`
`guard let presentation` — and only with an emoji; `MobileBlockDecor.swift:193`
`where slot.commentCount > 0`), so on a plain-block fixture the write path is
**structurally unreachable**.

**A throwaway probe was rebuilt on a fixture that reaches all three writers** — 120
blocks; block 10 FANNED *and* commented (so the takes chrome's `commentMarkRoom` rides
its tail reservation), block 20 a callout carrying an emoji, block 30
plain-and-commented — mounted in a real `UIWindow` at 393 × 852, **and it proves the
writers executed before it reads the equality**:

```
PROBE slots=120 fanned=1 commented=2 emojiCallouts=1
PROBE writersRan fannedTailIndent=-56.0 calloutFirstLineHeadIndent=27.0
PROBE contentSize=(393.0, 9558.0) inset=UIEdgeInsets(top: 8.0, left: 15.0, bottom: 835.0, right: 15.0) contentInset=UIEdgeInsets(0,0,0,0) adjusted=UIEdgeInsets(0,0,0,0)
PROBE storageEqualAfterFirstScroll=true
PROBE storageEqualAfterScroll=true
PROBE stringEqualAfterScroll=true
PROBE offsetEnd=4200.0 contentSizeEnd=10242.0
PROBE endFannedTailIndent=-56.0 endCalloutGap=27.0
```

A non-zero `tailIndent` / `firstLineHeadIndent` is written by **nothing but** those two
reservation writers, so `writersRan` is the falsifiable evidence the first measurement
lacked. With both populated and fired, two scroll jumps — the second carrying the
loaded blocks well off the near-viewport band — leave storage **byte-identical,
attributes included**. The equality gates
(`guard abs(style.tailIndent - target) > 0.01` and its leading twin) are what hold it.

**Disposition: option (i) of the fix shape — re-measured, so the rule-out and its "do
not re-open" both stand, and now cover the FANNED and CALLOUT shapes her real notes
actually carry.** `mobile-batch-9-record.md` §4.3 item 1 carries the whole re-measurement
in a marked block, including the admission that the first one was a green over nothing.

**The probe does NOT ship** (`ZZProbeLoadedChromeScroll.swift`, deleted before commit —
the reviewer's own NIT-3 precedent from 6b; `grep -rn "ZZProbe"` returns nothing). Its
numbers and its fixture are in the record, described precisely enough to rebuild in one
sitting.

---

## Item 5 — the four NITs · **ALL FOUR DONE, two with new reds**

### NIT 1 — the cloned half is pointed at the unpinned edit-menu seam ✔ (the better spend, per the finding)

`MobileBlockMenuTests.theTwoDoorsShareOneVocabulary`'s second half no longer calls
`menuElements` twice against the same oracle. It now composes the **real edit menu**
(`MobileEditMenu.menu(model:range:suggested:)`) and reads the **`Block` submenu's
children** — the claim `MobileEditMenuSeam.swift:87` and `MobileBlockMenu.swift`'s
header both make and which nothing pinned.

**RED B3 — production revert: `.dropLast()` on the seam's `menuElements` result.**

```
✘ Test theTwoDoorsShareOneVocabulary() recorded an issue at MobileBlockMenuTests.swift:126:13: Expectation failed: (blockSubmenu.children.map(\.title) → ["comments…", "callout", "name block…", "commit take", "new block below", "divide block", "merge with previous", "archive block"]) == (MobileBlockMenuController.rowTitles.map(cased) → ["comments…", "callout", "name block…", "commit take", "new block below", "divide block", "merge with previous", "archive block", "delete block"])
✘ Test theTwoDoorsShareOneVocabulary() failed after 0.070 seconds with 1 issue.
✘ Test run with 11 tests in 1 suite failed after 1.036 seconds with 1 issue.
** TEST FAILED **
```

**The finding proved from the other side:** the deleted half read the builder directly,
so it would have stayed GREEN under this exact revert. The replacement is real
coverage, not a re-shuffle.

### NIT 2 — the constant compared to its own literal ✔

`MobileMenuVocabularyTests.swift:109` (`restingActLabels == ["Formatting", "Takes",
"Block"]`) is replaced by an assertion against the **real bar**: `bar.makeBar()`'s
toolbar items, their labels (item or custom view — the markdown suite's own walk
shape) compared to `restingActLabels`, and — the link this pin actually owed — **the
middle door's `action` is `#selector(fireTakes)`**, i.e. the act the test then fires.

**RED B4 — production revert: the middle act's selector changed to
`#selector(toggleFormattingDoor)`.**

```
✘ Test theBlockMenuDropsTakesAndTheBarsMiddleActStillOpensTheBrowser() recorded an issue at MobileMenuVocabularyTests.swift:126:13: Expectation failed: (acts[1].action → toggleFormattingDoor) == (#selector(MobileKeyboardBarController.fireTakes) → fireTakes)
✘ Test theBlockMenuDropsTakesAndTheBarsMiddleActStillOpensTheBrowser() failed after 0.110 seconds with 1 issue.
✘ Test run with 5 tests in 1 suite failed after 3.095 seconds with 1 issue.
** TEST FAILED **
```

**Exactly one issue — isolated to the new assertion**, and deliberately so: this revert
leaves the labels untouched, so the retired line would have stayed green while the door
it names had stopped being the door.

### NIT 3 — the production comments still drawing the retired pairing ✔

Three, swept, and where a road is named it is **composed**:

- **`MobileNoteActions.swift:26`** — the `block ⋯ → Commit Take + Block History…` /
  `note ⋯ → Save a Version + Versions…` diagram is now labelled **"as it stood at 6c,
  kept because it was TRUE WHEN WRITTEN"** (`MobileBlockMenu`'s own convention for a
  superseded note) and followed by what batch 9 changed and what survives: the pair now
  exists at exactly ONE grain, the note's.
- **`MobileVersions.swift:28`** — the Q5 paragraph gains the same correction, pointing
  at `MobileBlockMenu`'s header for the reasoning rather than re-arguing it.
- **`MobileUndoDoor.swift:255-259`** — the doc comment that asserted *"The road it names
  is the phone's own"* now says the sentence names a **FACE, deliberately, and not a
  road**, with the reason (a spelled road would be three taps long and would go stale
  at the next move) and the instruction for a future author: **if it ever grows a road,
  compose it from `historyTitle`.**

**One thing deliberately NOT changed, and disclosed:** the user-facing string in
`discardingUndoDetail` (*"…bring it back from the block's Block History at any time"*)
is **untouched**. The reviewer called it *"still TRUE"*, and the adjudication scoped
this clause to the production **comments**; editing shipped copy is a product-copy
change, not a NIT's, and it would have needed its own red for a sentence that is not
wrong. **`MobileBlockMenu.swift:283-287` needed nothing** — it already states the
pairing ends there; its `commitTitle` doc comment (which still called the two a "pair")
was corrected while that constant was being made `nonisolated`.

### NIT 4 — §4.4 says that her own geometry argues against S3 ✔

`mobile-batch-9-record.md` §4.4 gains the note beside the existing confound paragraph:
the pan router gates on **horizontal dominance**
(`MobileTakesChrome.swift:566-567`) and her report is about dragging **"up and down"**,
so a near-vertical drag cannot open that gate — her wording is evidence *against* this
candidate. **S3 stays on the list, and the record says why it stays** (one of only two
app-local candidates, the cheapest to fix if it is the cause, and §4.5's question 2
settles it in one observation). Only the honesty of the ranking changed, which is what
the finding asked for.

---

## Files touched

**Production (6):** `MobileTutorialSeeder.swift` (MAJOR 2 — two lessons) ·
`MobileBlockMenu.swift` (`commitTitle` → `nonisolated`, its doc comment corrected) ·
`MobileTakesBrowser.swift` (`historyTitle` → `nonisolated`, documented) ·
`MobileNoteActions.swift`, `MobileVersions.swift`, `MobileUndoDoor.swift` (NIT 3 —
comments only).

**Tests (3):** `MobileTutorialWalkTests.swift` (the strengthened five-places road
assertions + the new savepoints-road pin) · `MobileBlockMenuTests.swift` (NIT 1) ·
`MobileMenuVocabularyTests.swift` (NIT 2).

**Documents (4):** `mobile-batch-9-record.md` (banner + §4.3 · §4.4 · §4.6 · §5 · §9) ·
`mobile-round-2-handoff-2026-08-30.md` (§7.2's leftover-backlog row) ·
`mobile-round-2-fable-seat-handoff.md` (item 7's pointer) · **this file**.

## Fence, re-derived at commit

```
$ git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum \
      "*.xcodeproj" "*.pbxproj"
(empty)

$ git status --porcelain -- Sources/ App/Variorum/Shared App/Variorum/Variorum \
      "*.xcodeproj" "*.pbxproj"
(empty — nothing untracked there either)

$ git diff -- '*.swift' | grep -c planVisibleTakeEdit
0

$ git status --porcelain | grep -i editorbrain
(empty)

$ git status --porcelain -- "*Package.resolved"
(empty)
```

Zero `Sources/`, zero `Shared/`, zero Mac-target, zero `EditorBrain/`, zero schema,
zero build-config, zero `Package.resolved`. The new test file the probe needed was a
throwaway in the synchronized test group and is deleted; **no `.pbxproj` edit was ever
required**.

## One thing left for the orchestrator

**Batch 9's own row in `mobile-round-2-handoff-2026-08-30.md` §7.2 is deliberately left
un-struck.** Marking it DONE wants the fix wave's commit hash and is the closing act,
which the adjudication assigns to the orchestrator ("*then the orchestrator verifies and
closes*"). The row's neighbours (6c · the filter unit · 6b) show the house format.

---

# UNIT CLOSED (the Fable orchestrator, 2026-08-31)

**Batch 9's R28 unit is COMPLETE:** build `1260da4` → cold review
`78f2532` (0B · 2M · 2m · 4n) → fix wave `f0cb1f1`, all items, two
declines both endorsed (the `discardingUndoDetail` product-copy scope
call; the row flip held for this close). **Final: mobile 667/99 green,
2 known issues.** Fence clean at every commit, verified by the
orchestrator; the two disclosed production isolation changes
(`commitTitle`/`historyTitle` → `nonisolated` so the guide COMPOSES the
row's word) verified at the diff — the composition is what makes the
walk's pin red on the next door move rather than merely stale, which is
MAJOR 2's lesson made structural.

**What leaves this unit for HER (tracked in the bundle):**
- **The device experiment** (record §4.5 — three observations, one
  minute) that collapses the selection-defect candidate table; joins the
  device queue beside E1's precedent. Until it runs, the defect is open
  with four candidates and honest rule-outs.
- **The merge-vocabulary proposal** (record §5, corrected at the wave):
  (A) select-then-merge riding batch 7's multi-select + (B) `Merge with
  Next` alongside; (C) recorded, not recommended; the multi-BLOCK vs
  multi-TAKE reading flagged as hers.
- **PROVISIONAL 3** (a gap block's history is unreachable after the door
  move) and the batch's other recorded calls (record §9).
- The stranded-`isEditable` defect: informational for her; its FIX is
  owned in-round (the leftover-backlog batch, shape ruled).
