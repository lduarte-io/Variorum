# Batch 7 — TAKES & BLOCK DOORS (phone-local half) · COLD REVIEW

**Target:** `4b58399..73945ed` (one commit) · **Branch:** `mobile` · worktree
`<home>/dev/variorum-mobile`
**Reviewer:** cold, zero implementation context. Brief, record and the ENTIRE
diff read first-hand; every claim below is traced at the code or run, never
taken on the record's word.
**Written INCREMENTALLY as findings firmed** (this session's standing posture —
a findings file on disk survives a session death where a final message does not).

---

## Environment (binding, and discharged)

| what | value |
|---|---|
| simulator | `cold-review-b7` — **iPhone 17, iOS 26.2 (23C54)**, created fresh for this review |
*[removed for publication]*
| accessibility | `ApplicationAccessibilityEnabled` written and **read back `1`** |
| derived data | private `-derivedDataPath` at `<scratchpad>/cr-b7-dd` |
| pre-revert dir | **`<scratchpad>/cr-b7-prerevert/`** — uniquely named, because the shared scratchpad holds STALE `45c-prerevert/`, `45c-wave-prerevert/`, `45c-wave2-prerevert/`, `45c-round2-prerevert/` and the implementer's own `b7-*` dirs |
| teardown | simulator deleted at the review's close |

**FULL SUITE — RUN BY THIS REVIEWER, on this simulator. The exact final line:**

```
✘ Test run with 706 tests in 102 suites passed after 321.832 seconds with 2 known issues.
** TEST SUCCEEDED **
```

`xcresulttool` summary on the same result bundle: `"failedTests" : 0`,
`"expectedFailures" : 1`, `"result" : "Passed"`, device `iPhone 17` / `26.2`.
**Matches the expected 706/102 with 2 known issues exactly.**

- **The load-flaky perf pin did NOT red.**
  `MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`
  ran and passed; `failedTests` is 0, so no isolated re-run was owed.
- **No runner death.** Zero `Restarting after unexpected exit` lines; the run
  completed in one launch (321.832 s).

---

## Severity counts

**BLOCKER 0 · MAJOR 2 · MINOR 4 · NIT 2**

| # | severity | one line |
|---|---|---|
| MAJOR 1 | MAJOR | M23's callout fallback silently copies the wrong take's prose, and the record's grading never names that cost — the batch's own new promise is what makes the silence wrong |
| MAJOR 2 | MAJOR | `All Takes to Blocks` disappears once she edits any take and there is **no door back** short of closing and reopening the sheet — no caller of `endEditing()` is user-reachable without `close()` |
| MINOR 1 | MINOR | Picking mode survives the sheet's dismissal, against the rule `exitSelection`'s own comment states |
| MINOR 2 | MINOR | PR20's real wiring is unpinned — pass `onDeleteBlocks: nil` in `MobileWriteView` and the whole feature vanishes with every pin green |
| MINOR 3 | MINOR | `deletePicked`'s success/refusal discrimination silently depends on `refresh()` not throwing (the record's own §11-4, answered) |
| MINOR 4 | MINOR | `MobileEmojiPromptController` hard-codes a 220 pt detent with no scroll, so Dynamic Type can push `Set` off the sheet; the keyboard-overlap half wants a device check |
| NIT 1 | NIT | The palette has FIVE colours; the record and two shipped comments say "four" |
| NIT 2 | NIT | The record's R7 revert account is incomplete — the revert reds two tests, not one (in the batch's favour) |

**Nothing here blocks the batch.** No invariant is violated, no data is at
risk, the fence is clean, and the full suite is green at the expected counts.
MAJOR 1 and MAJOR 2 are both about a *promise the batch makes and then quietly
does not keep*; both have fix shapes that stay inside the batch's own fence.

---

## FENCE — re-derived by this reviewer, not read from the record

```
$ git diff --name-only 4b58399..73945ed -- Sources/ App/Variorum/Shared \
      App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"
(empty)

$ git diff --name-only 4b58399..73945ed | grep -i editorbrain
(empty)

$ git diff 4b58399..73945ed -- '*.swift' | grep -c planVisibleTakeEdit
0
```

The whole diff is **11 mobile source files + 5 mobile test files + 2 notes
files**, nothing else. `Package.resolved` untouched. **CLEAN.**

---

## FINDINGS

### MAJOR 1 — M23's callout fallback is SILENT, and the batch's own new promise is what makes that wrong

**Label: READ-ONLY traced + reproduced at the pin.**
**Files:** `App/Variorum/VariorumMobile/Features/Write/MobileNoteClipboard.swift:154-166`
(`displayedProjection`'s guard) · pin at
`App/Variorum/VariorumMobileTests/MobileNoteClipboardTests.swift:281-318`.

**What I verified first, and it is all sound.** The three claims the brief
asked me to check are each TRUE:

1. **The pin really documents the corner.** It drives a genuinely framed +
   peeked world (block A branched and peeked to `"The peeked one."`, block B
   carrying a real `BlockPresentation(color: "blue")`) and asserts the stored
   outcome *explicitly*, including
   `#expect(board.pasteboard.string?.contains("The chosen one.") == true)`.
   That is not a euphemism — the pin states in its own assertions that the
   copy carries the take that is **not** on screen.
2. **The no-peek road really runs `Queries.exportPost` verbatim.** Traced:
   `MobileEditorViewModel.displayedTextByBlock` returns `[:]` whenever
   `takes.peeks.isEmpty`, and `markdown` then takes
   `displayed.isEmpty ? Queries.exportPost(...) : displayedProjection(...)`.
   The byte-identity is by *which function runs*, exactly as claimed, and
   `withNothingPeekedTheCopyIsTheStoredExportVerbatim` pins it directly.
3. **The peeked unframed road really follows the screen**, and the surface is
   genuinely the source: `MobileTakesController.overlay(_:)` swaps a peeked
   slot's variant *and text* before the VM sees the projection, and a lens
   activation drives the same primitive (`MobileLenses.swift:316` calls
   `editor.takes.peek(blockID:to:)`), so `takes.peeks` is the surface's own
   exact answer. A lens pick equal to chosen no-ops in `peek(...)`, so
   "transparent lens ⇒ stored road" falls out correctly rather than by luck.
   I also confirmed the two projections are otherwise equivalent:
   `renderedText` is `joinRenderedTexts(renderPost(...).compactMap(\.text)
   .filter { !$0.isEmpty })` and `displayedProjection` is the same walk with
   `.map { displayed[$0.blockID] ?? $0.text ?? "" }.filter { !$0.isEmpty }` —
   same join brain, same drop-the-empties, nil-text slots dropped identically.

**Now the graded question the brief asked — "trace which it is".** The
consequence of the shipped fallback is **the WRONG TAKE'S PROSE, silently**,
for the whole note. The rejected alternative's consequence is framed blocks
losing `> ` and their leading emoji. The record weighs these as *"a document
whose framed blocks silently lose their `> ` — a regression introduced to
half-satisfy a ruling"* versus *"the honest fallback is the shipped
behaviour"*, and **never states its own side's cost in her terms.** Traced
side by side:

| road | what she gets | detectable? |
|---|---|---|
| shipped (stored road) | a **different take's paragraphs** than the screen shows | **NO** — the prose reads fine; nothing marks it |
| rejected (displayed road) | the right paragraphs, minus `> ` and the emoji | **YES** — visible in the pasted text |

Losing the decoration is recoverable and obvious. Copying a paragraph she did
not choose is neither — and it is *precisely* the failure R15 was ruled to
end (her words: *"copy should follow what's on the screen"*).

**I am NOT objecting to the fallback choice.** MobileSoul §3 forbids forking a
core brain outright, `Queries.exportMapped` really is `internal`
(`Sources/VariorumCore/Queries/Export.swift:59`), and I confirmed there is no
third road that keeps `> ` without it — `renderPost` returns raw text, so ANY
document built from it loses the mapping whether or not the framed block is
the peeked one. Not-a-regression is a real argument and I credit it.

**What I am objecting to is the SILENCE.** Before this batch, copy never
followed the screen, so she had no expectation to violate. This batch *teaches
her a new promise* and then breaks it invisibly on exactly the notes that
carry callouts — a shipped feature she uses. That is the batch's own doing,
and the app's doctrine everywhere else is that a door speaks its real answer
(P-2; the whole `refusalMessage` family; this batch's own
`noConvertibleTakes` and blank-take arms).

**Fix shape — inside the fence, zero core change, no fork.**
`MobileNoteClipboard.copy` already returns an `Outcome` whose `.message` the
caller reports (`MobileNoteClipboard.swift:170-176`). Give `displayedProjection`
a way to say it took the fallback (a returned flag, or a third `Outcome` case)
and let the receipt read something like *"Copied — callout blocks copied their
chosen take."* One sentence converts a silent wrong answer into an honest one,
and it can ship today; the `public` keyword at the merge then deletes both the
sentence and the corner.

**Dismissal is available with evidence** if the implementer argues the
conjunction (callout + peek/lens + whole-note copy) is rare enough that a
sentence on *every* framed-note copy costs more than it buys — that is a taste
call about noise, and it is a legitimate one. What should not stand is the
current state, where the record's severity discussion omits the wrong-prose
half entirely.

---

### MAJOR 2 — `All Takes to Blocks` becomes unreachable once she edits any take, and there is no door back short of closing the sheet

**Label: READ-ONLY traced (exhaustive caller enumeration + layout arithmetic).**
**Files:** `App/Variorum/VariorumMobile/Features/Takes/MobileTakesBrowserView.swift:340-341`
(`showTakesToBlocks = browser.canTurnTakesIntoBlocks && browser.editingVariantID == nil`) ·
`App/Variorum/VariorumMobile/Features/Takes/MobileTakesBrowser.swift:499-505` (`endEditing`).

**The A1-gate defect and its fix both check out.** I verified the mechanism the
record describes, by arithmetic rather than by its word:

- before the batch: `cardsScroll.height = max(footerY - 52, 0)` at `y: 44`
  ⇒ list bottom `= footerY - 8`;
- with the row HIDDEN: `listBottom = footerY - 8`, `height = max(listBottom - 44, 0)`
  `= footerY - 52` — **byte-identical to the shipped sheet**;
- with the row SHOWN: `actionsY = footerY - 30`, `listBottom = actionsY - 8`
  ⇒ `height = footerY - 82` — **exactly the 30 pt the record names**.

And the pin it was caught by
(`MobileTakesBrowserTests.theKeyboardNeverStrandsTheCardListFooterOrLiveCard`,
`MobileTakesBrowserTests.swift:927`) is **not in this batch's diff** — it rode
unmodified, as claimed. Good: the fix was made at the mechanism.

**What the record does not say, and what I traced:** the row does not come
back when she stops typing, because **there is no "stop typing" that keeps the
sheet open.** I enumerated every caller of `endEditing()` in the app — there
are five, and none is a user-reachable "done with this card" door:

| site | what it is |
|---|---|
| `MobileTakesBrowser.swift:319` | `open(blockID:)` — opening a *different* block |
| `MobileTakesBrowser.swift:333` | `close()` — the sheet's **Done**, which closes the whole browser |
| `MobileTakesBrowser.swift:363` | `projectionDidChange()` — the live take vanished remotely |
| `:743`, `:766` | archive/delete of the take being edited |

Tapping another card's body calls `beginEditing(variantID:)`
(`MobileTakesBrowserView.swift:451`, via `bodyTapped()`), which *moves*
`editingVariantID` rather than clearing it. The sheet's only chrome button is
`takes.browser.done` → `close()`. **So the recovery road is: close the takes
sheet entirely and reopen it.**

**Why this is worth a finding rather than a nit:** the record justifies the
stand-down as a rule (*"converting the whole fan is not something she is doing
mid-keystroke"*), which is a fair product argument for hiding it *during* the
keystrokes — but it silently assumes a way back that the surface does not
have. A door that disappears on a common action and returns only via an
unrelated dismiss/re-open is the shape P-2 exists to prevent, and it is
invisible to every pin because
`theAllTakesToBlocksDoorRendersOnlyOnAFanAndActsWhenPressed` never puts a card
live.

**Fix shapes, cheapest first:** (a) keep the row visible but `.disabled` while
a card is live, spending 0 pt of typing room only when it can act — but that
re-spends the 30 pt, so it is likely wrong; (b) restore the row when the card
editor resigns first responder (`textViewDidEndEditing` → `endEditing()`),
which gives the sheet the missing "done with this card" state and costs
nothing while typing; (c) leave the behaviour and **pin it**, so the next
session inherits a decision. (b) is the one that matches the record's own
stated rule — *"while a take is being written"* — because today the condition
outlives the writing.

---

### MINOR 1 — picking mode survives the sheet's dismissal, against the rule the code's own comment states

**Label: READ-ONLY traced.**
**Files:** `App/Variorum/VariorumMobile/Features/Write/MobileBlockList.swift:113-117`
(`exitSelection`, and its comment) · `:310-325` (the Select/Done chrome) ·
`:311` (`Button(tokens.chromeLabel("Done")) { dismiss() }`) ·
`App/Variorum/VariorumMobile/Features/Write/MobileWriteView.swift:74,138`
(`@State private var blockList`).

`exitSelection`'s doc states the rule: *"A selection that outlived its surface
would offer acts on blocks she is no longer looking at."* But the **sheet's
own dismiss does not call it**, and neither does swipe-to-dismiss —
`exitSelection` is reached only from the Select/Done chrome toggle and from
`deletePicked`'s success road.

`blockList` is `@State` on `MobileWriteScreen` (`:74`, initialised once at
`:138`), so the model outlives the sheet. Traced consequence: enter picking,
pick three blocks, swipe the sheet away, reopen it — **it comes back in
picking mode with the three picks still armed and `Delete 3 Blocks…` on the
banner.**

**Severity is MINOR and honestly so:** the act is confirm-gated, the picks are
pruned to live blocks by `adopt`, and the mode is visible (banner + marks +
"Done"), so nothing is invisible or destructive-by-surprise. What makes it a
finding rather than nothing is that the code asserts a rule it does not
enforce on the primary exit road — the next reader will believe the comment.

**Fix shape:** call `model.exitSelection()` from the sheet's `Done`, and hang
it off the sheet's disappearance (`.onDisappear`) so swipe-to-dismiss is
covered too. Or amend the comment to say picking is deliberately sticky
across dismissal.

**Riding with it (same file, same class, NIT-weight):** the Select/Done chrome
renders only when `!model.rows.isEmpty` (`:310`). If every row leaves while
picking (a remote delete of the whole note's blocks), `isSelecting` stays true
with **no button to leave by** — the banner renders "Tap blocks to pick them."
over an empty list. Narrow, and the sheet's dismiss is still there, but it is
the same missing-exit class.

---

### MINOR 2 — PR20's real wiring is unpinned: the whole feature could be disconnected in `MobileWriteView` and the suite stays green

**Label: READ-ONLY traced.**
**Files:** `App/Variorum/VariorumMobile/Features/Write/MobileWriteView.swift:363-375`
(the `onDeleteBlocks:` injection) · pins at
`App/Variorum/VariorumMobileTests/MobileBlockListTests.swift:277-330`
(`pickingTwoBlocksAndConfirmingDeletesExactlyThoseTwo`) and `:332-360`
(`theBulkDeleteIsOneUndoEntryThatBringsThemAllBack`).

**The composition itself is right, and I verified it by trace rather than by
the record's word.** `MobileStructural.deleteWholeBlockRun` (`:676-720`)
genuinely carries every promise the record claims: the `structuralInFlight`
latch with its spoken refusal, the flush-first contract, the caret landing
read *after* the flush by block ID, `UndoStack.withCompound(label: "Delete
Blocks")` — **one** entry — the stranded-originals note, and the receipt with
`action: .undo`. Nothing is re-registered at the sheet. ✔

**The gap is the JOIN.** The two pins cover the two halves separately and
neither crosses the seam:

- `pickingTwoBlocksAndConfirmingDeletesExactlyThoseTwo` hosts
  `MobileBlockListSheet` with a **hand-written `onDeleteBlocks`** that does its
  own `withCompound` + `deleteBlock` loop — so it proves the sheet's gesture,
  not the app's road;
- `theBulkDeleteIsOneUndoEntryThatBringsThemAllBack` calls
  `model.structural.deleteWholeBlockRun(...)` **directly** — so it proves the
  road, not the sheet's use of it.

Consequence: pass `onDeleteBlocks: nil` in `MobileWriteView` and the Select
door simply stops rendering (`onDeleteBlocks != nil` is its P-2 arm) —
**every pin stays green and the feature is gone.** Transpose the ids and the
same holds.

**This is fixable with a pattern the suite already owns**, which is why it is
a finding rather than an accepted posture: `MobileWriteScreen` is hosted in at
least seven existing suites (`MobileNoteTrayTests.swift:764`,
`MobileVersionsTests.swift:50`, `MobileTrashTests.swift:685`,
`MobileDeletionTests.swift:86`, `MobileUndoDoorTests.swift:59`,
`MobileMenuVocabularyTests.swift:282`, …) — and `MobileNoteTrayTests` in
particular already drives the **blocks sheet** from the hosted screen, which
is the exact surface PR20 hangs off.

**Fix shape:** one pin that hosts `MobileWriteScreen`, opens the blocks sheet,
picks two rows, confirms, and asserts the store *and*
`session.undoStack.topLabel == "Delete Blocks"` — proving the screen's own
closure reaches the real road.

---

### MINOR 3 — `deletePicked`'s success/refusal discrimination silently depends on `refresh()` not throwing (the record's own §11-4, answered)

**Label: MEASURED — surfaced by MY revert B run, which reds a pin the record's
R7 account does not mention.**
**File:** `App/Variorum/VariorumMobile/Features/Write/MobileBlockList.swift:404-419`
(`deletePicked`) · `:134-144` (`refresh`) · `:128-132` (`adopt`).

The record asks (§11 item 4) whether inferring "landed" from an empty
selection is sound. **Traced answer: it is sound for the outcome it was
written for, and it has one traced hole the record does not name.**

```swift
await onDeleteBlocks(picked)
await model.refresh()
if model.selection.isEmpty { model.exitSelection() }
```

The discrimination rides entirely on `refresh()` reaching `adopt`, which is
the only place `prune` runs. And `refresh()` **swallows a read failure**:

```swift
} catch { status = String(describing: error) }   // rows stay STALE, adopt never runs
```

So a read that throws immediately after a **successful** delete leaves
`selection` un-pruned ⇒ non-empty ⇒ `exitSelection()` never fires ⇒ the app
reads its own success as a refusal, keeps picking mode on, and leaves
`Delete N Blocks…` armed over blocks that are already gone. Narrow (it needs a
read failure in the window right after a write that succeeded), but it is
exactly the fragility the record flagged and then kept.

**My revert-B run is the evidence that the coupling is real and load-bearing**
— and this is the part the record under-reports. Dropping `prune` from
`adopt` reds not only the three count/verb/banner assertions the record
quotes, but **a second, unmentioned test**:

```
✘ pickingTwoBlocksAndConfirmingDeletesExactlyThoseTwo() recorded an issue at
  MobileBlockListTests.swift:349:17: Expectation failed:
  !((list → VariorumMobile.MobileBlockListModel).isSelecting → true → true)
```

i.e. **picking mode never turns off after a successful delete.** So `prune`
protects more than "the count in the banner" — it is the mode's exit
mechanism. That makes the re-grounded pin *stronger* than the record claims,
and it makes the hidden coupling worth naming at the code.

**Fix shape (the record's own candidate, and I agree with it):** have
`onDeleteBlocks` return `Bool` and drive the exit off the returned outcome
rather than off a re-read state. Failing that, at minimum document at
`deletePicked` that the exit depends on `refresh()` succeeding, so the
coupling is visible to the next reader.

---

### MINOR 4 — `MobileEmojiPromptController` fixes its sheet at 220 pt with no scroll, so Dynamic Type can push `Set` off the surface

**Label: READ-ONLY traced (layout arithmetic); the keyboard-overlap half is
SPECULATIVE and wants a device check.**
**File:** `App/Variorum/VariorumMobile/Features/Write/MobileEmojiField.swift:96-99`
(the detent) · `:106-160` (`viewDidLoad`'s stack and constraints).

```swift
sheet.detents = [.custom { _ in 220 }]
```

A single hard-coded custom detent, and the content stack is pinned
**leading/trailing/top only** — there is no bottom constraint and no
`ScrollView`. The stack is `title (headline) → message (footnote,
numberOfLines = 0) → field (28 pt) → buttons`, with 14 pt spacing and a 20 pt
top inset. At the default content size that totals roughly 185 pt and fits.
At accessibility sizes it does not: `.headline` and `.footnote` both scale
(the labels correctly set `adjustsFontForContentSizeCategory = true`), and the
message wraps to more lines, so the `Cancel`/`Set` row is pushed past 220 pt
and off the sheet.

**Consequence:** the only road out is swipe-to-dismiss, which
`presentationControllerDidDismiss` correctly treats as **cancel** — so the
emoji can never be *set* at large text sizes. Nothing is lost or corrupted;
the feature is simply unreachable. MobileSoul §5.6 names Dynamic Type as a
phone-native expectation, which is why this is a finding rather than a nit.

**Second half, flagged honestly as SPECULATIVE:** `viewDidAppear` calls
`field.becomeFirstResponder()`, raising a ~300 pt emoji keyboard under a
220 pt sheet. I could not settle from reading whether
`UISheetPresentationController` performs keyboard avoidance for a custom
detent on iOS 26, and the record itself records that this controller **has no
pin driving its buttons** (§11 item 6) — so if the keyboard does cover the
button row, PR19's emoji road does not work on device at *any* text size and
nothing in the suite would say so. **This is the one item in the batch I would
ask for a device or booted-simulator check on before it ships**, and it is
cheap: present the sheet, confirm `Set` is hittable with the keyboard up.

**Fix shape:** wrap the stack in a `UIScrollView`, or use
`.custom { context in min(220, context.maximumDetentValue) }` together with a
bottom constraint and `.medium()` as a second detent so the sheet can grow.
Either makes the button row reachable regardless of text size.

---

### NIT 1 — the palette has FIVE colours; the record and a production comment both say "four"

**Label: READ-ONLY traced.**
**Files:** `App/Variorum/VariorumMobile/Features/Write/MobileCallout.swift:23`
(`static let names = ["blue", "green", "sand", "violet", "rose"]`) ·
`App/Variorum/VariorumMobile/Features/Write/MobileBlockMenu.swift:243-244`
(*"no row was added, only an image hung on four that existed"*) ·
`App/Variorum/VariorumMobileTests/MobileBlockMenuTests.swift:141-146` (the same
wording in the test's comment) · record §3 (*"The four colour rows"*) and §8.

There are five, and the record's own quoted revert output says so —
`(row.image → nil) != nil  [×5, one per colour row]`. Harmless to behaviour
(everything is derived from `MobileCallout.names`, never from the number), but
it is a stated fact that is wrong in three places including shipped comments,
and the Mac's `BlockDecor.swift:245` carries the same five.

---

### NIT 2 — the record's R7 revert account is incomplete in a way that understates its own pin

Covered in MINOR 3 above, recorded separately here because it is a *record*
accuracy point rather than a code one: R7's quoted output shows three failing
assertions in one test; the revert actually reds **two tests, four
assertions**, the extra one being `pickingTwoBlocksAndConfirmingDeletesExactly
ThoseTwo`'s `!list.isSelecting`. The round's discipline is that a revert's
output is quoted as run; this one was quoted partially. The direction of the
error is in the batch's favour, which is why it is a NIT.

---

## CLEAN BILL — the ten areas the brief named, each traced

### 1. M23's fence collision — **the three verifications PASS; the grading does not** → MAJOR 1

The pin genuinely drives a framed + peeked world and asserts the stored
outcome; the no-peek road genuinely runs `Queries.exportPost` verbatim, by
*which function runs*; the peeked unframed road genuinely follows the screen
through `overlay(_:)`, and the lens road reaches the same primitive
(`MobileLenses.swift:316`). **Independently corroborated by my revert C:**
with `displayedTextByBlock` forced to `[:]`, the callout-corner pin
`aCalloutNoteKeepsTheStoredRoadEvenWhilePeeking` **stayed green** — which is
the cleanest possible proof that the callout road never followed the screen at
all. Only the *severity grading* is a finding (MAJOR 1): the record weighs
"framed blocks lose `> `" against "the shipped behaviour" and never names its
own side's cost, which is silently copying the wrong take's prose.

### 2. The two self-caught hollow pins — **BOTH re-groundings are REAL, both reproduced by me**

**R3 (the latch), reproduced.** `structureLatch.run` → `MobileWriteLatch().run`
(a latch that never latches), `-only-testing:MobileTakeToBlockTests`:

```
✘ aSecondPressWhileTheConversionIsInFlightIsNotReportedAsARefusal() recorded an issue at
  MobileTakeStructureTests.swift:601:13: Expectation failed:
  (model.statusMessage → "This block has no other takes with text in them — nothing to turn into blocks.")
   == (MobileTakeStructureCopy.convertedNote(blocks: 2, skippedBlanks: 0) → "2 takes are now their own blocks below …")
✘ … :603:13: Expectation failed: (model.statusMessage?.contains("no other takes") → true) != true
✘ … :604:13: Expectation failed: (model.statusAction → nil) == .undo
✘ Test run with 8 tests in 1 suite failed after 0.835 seconds with 3 issues.
```

Three issues, **all on the receipt**; the store assertion at `:597` stayed
green and the other seven tests passed. That is precisely the claimed shape —
the op *is* idempotent by validation, and what the latch protects is the
receipt she earned. The re-grounding is the real consequence, not a second
guess. *(Revert applied to PRODUCTION `MobileTakesBrowser.swift`; restored
from `cr-b7-prerevert/` and `diff`-verified identical.)*

**R7 (the prune), reproduced — and it is STRONGER than recorded.** Dropped
`selection.prune(to:)` from `adopt`, `-only-testing:MobileBlockSelectionTests`:

```
✘ aBlockDeletedElsewhereDropsOutOfThePicksAndOutOfTheCount() … :276:13: (model.selection.count → 2) == 1
✘ … :277:13: (MobileBlockSelectionCopy.deleteVerb(picked: model.selection.count) → "Delete 2 Blocks…") == "Delete Block…"
✘ … :279:13: (MobileBlockSelectionCopy.bannerLabel(picked: model.selection.count) → "2 blocks picked") == "1 block picked"
✘ pickingTwoBlocksAndConfirmingDeletesExactlyThoseTwo() … :349:17: !((list …).isSelecting → true → true)
✘ Test run with 8 tests in 1 suite failed after 12.823 seconds with 4 issues.
```

The `pickedInOrder` control at `:274` stayed green exactly as the record says.
The fourth failure is the one the record does not mention — see MINOR 3 and
NIT 2. *(Revert applied to PRODUCTION `MobileBlockList.swift`; restored and
`diff`-verified identical.)*

### 3. The self-caught A1-gate defect — **mechanism verified; the fix has an unnamed consequence** → MAJOR 2

The 30 pt is real and I re-derived it from the layout arithmetic (hidden row
reproduces the shipped `footerY - 52` exactly; shown row costs exactly 30 pt).
The pin `theKeyboardNeverStrandsTheCardListFooterOrLiveCard` is **not in the
diff** — it rode unmodified, as claimed. The brief's own question — *"is the
act reachable after ending editing?"* — has a traced answer that is a finding:
**only by closing and reopening the takes sheet**, because no user-reachable
door clears `editingVariantID` without closing the browser (MAJOR 2, with the
full five-caller enumeration).

### 4. Reorder's #57 composition — **CLEAN, every arm traced**

- **Grey-not-vanish at the ends:** `attributes: canMoveUp ? [] : .disabled`
  on both rows (`MobileTakesBrowserView.swift:547-554`), pinned on the REAL
  mounted card's REAL `UIMenu` for first/middle/last.
- **A one-take fan draws NEITHER row:** the pair is inside `if fanned`, and
  `fanned` is `cards.count > 1` — pinned as an absence over a POPULATED menu
  (the other six rows asserted present).
- **Locked takes move:** no lock guard anywhere on the door; the op's rule
  carries it, pinned.
- **The fan is read FROM THE STORE after a flush.** Traced at
  `MobileTakesBrowser.swift:137-171`: `flushPendingText()` first, then
  `session.database.read { Queries.blockFan(...) }`, then `.filter { $0.status
  == .active }`, then index/target/anchor all derived from **that** array.
  `canMoveTake` reads `cards()` (the projection) and is used **only** for the
  `.disabled` attribute — it never gates the write. **There is no plan-time
  authorization from a stale projection**, which is the round's own law and
  the room B45-2 exists for. I checked both disagreement directions: a
  projection that over-reports enables a row whose act then refuses by name
  (`fanChangedRefusal` when the take itself is gone; `alreadyFirst/Last` when
  the neighbour is), and a projection that under-reports merely greys a row —
  neither can write to the wrong place.
- **No touch, no churn:** pinned directly against `last_touched_at` and
  `churn_accumulator` before/after.
- Also checked and fine: the silent `return` on a failed flush is correct —
  `flushPendingText` reports `unsavedChangesRefusal` itself before returning
  false (`MobileEditorViewModel.swift:930-937`), so the door is not silent.

**REVERT D — my own, to test the arm hardest to verify by reading.** I dropped
`.filter { $0.status == .active }` from `moveTake` (production
`MobileTakesBrowser.swift`), `-only-testing:MobileTakeReorderTests`:

```
✘ aLockedTakeMovesAndAnArchivedOneIsSteppedNeitherOntoNorOver() … :295:13:
  Expectation failed: try await fanOrder(db, blockID: seed.blockA) == [seed.a3, seed.a1]
✘ … :296:13: (model.takesBrowser.cards().map(\.variantID) → ["…002", "…008"]) == ([seed.a3, seed.a1] → ["…008", "…002"])
✘ … :304:13: (model.statusMessage → "This take is already first in the fan.") == (…movedUpNote → "Take moved up.")
✘ Test run with 6 tests in 1 suite failed after 0.470 seconds with 3 issues.
```

Exactly the traced mechanism: without the filter the step lands on the far side
of the archived take, so the fan does not move — and the *next* move then
refuses as "already first". **The other five reorder pins stayed green**, so
the red is narrow and at the right place. #57(b) is genuinely composed and
genuinely pinned. *(Restored from `cr-b7-prerevert/` and `diff`-verified
identical.)*

### 5. Take→block / takes→blocks — **CLEAN**

- **The single undo+redo entry is the OP's and is NOT re-registered.**
  Verified at the core, not from the record:
  `Sources/VariorumCore/Operations/Operations+TakeStructure.swift:109`
  (`registerTakeConversions([preImage], label: "Move Take into a Block")`) and
  `:198` (`registerTakeConversions(preImages, label: "Turn Takes into
  Blocks")`) — **both doors covered**. The phone's two methods contain no
  `register` call of any kind, and
  `theConversionRegistersExactlyOneUndoEntryAndItRoundTrips` pins
  `depth == before + 1` plus a full undo→redo round trip.
- **The latch actually gates the button's act.** `takesToBlocksButton`'s
  `.touchUpInside` → `takesToBlocks()` → `await structureLatch.run { … }`, and
  `MobileWriteLatch.run` returns `nil` without touching the store while busy
  (`MobileWriteLatch.swift:66-71`). The rider's criterion is applied correctly:
  the chrome button is the non-dismissing host, and latching its dismissing
  twin as well is the right call (a door and its twin with different
  concurrency rules would be the drift class). My revert A is the proof it
  gates.
- **AR-1 semantics untouched.** No pre-checks at either door; every #58 call
  (archive-not-delete, locked-take-may-move, keeps-what-it-showed, blank
  skipped-and-counted, archived-ride-nowhere) is decided inside the op and
  merely *spoken* by the phone. Pinned at the store: `variantStatus ==
  "archived"`, `fanOrder` shrinking, `blockTexts` gaining the run below.
- The `lastActiveVariant where verb == .takeToBlock` arm is a genuinely
  better sentence than the fall-through (it names `Divide Block`, composed
  from `MobileBlockMenuController.divideTitle` so a rename reaches it, and
  names no chord) — and its revert is quoted red in the record.

### 6. Multi-select — **CLEAN on the substance; two seam findings**

- **ids only (P1):** `MobileBlockSelection.picked` is `Set<String>` and
  nothing else; no text is copied anywhere. ✔
- **It composes `deleteWholeBlockRun`, verified by trace not by the record's
  word** (`MobileStructural.swift:676-720`): `structuralInFlight` latch with a
  spoken refusal · flush-first · caret landing read after the flush and named
  by block ID · `UndoStack.withCompound(label: "Delete Blocks")` — **ONE**
  entry · stranded-originals note · receipt with `action: .undo`. Nothing is
  re-registered at the sheet. ✔ (The *wiring* of that road into the real
  screen is MINOR 2; the road itself is right.)
- **The confirm's in-doctrine argument HOLDS, and I checked it against the
  phone rather than the record.** R13's line is gesture cost: a keystroke does
  not ask, a menu row does. The phone already proves both sides of that line
  *with the same op*: `runCrossBlockEdit` reaches `deleteWholeBlockRun`'s
  sibling road from a **keystroke** and deliberately does **not** confirm
  (`MobileStructural.swift`, "NO CONFIRM … this is a keystroke"), while
  `MobileBlockMenuController.confirmDelete` asks from a **menu row**. PR20's
  road is four deliberate taps ending in a button whose verb ends in `…`. That
  is the menu-row side of her own line, and the `…` makes the promise
  explicit. **Sound.**
- **Merge Selected is ABSENT and the absence is pinned over a POPULATED
  surface:** `thereIsNoMergeSelectedDoorAndTheAbsenceIsRuled` picks **two
  adjacent** blocks — the exact shape a merge door would light for — asserts
  the delete verb IS in the real mounted label tree, and asserts no label
  contains "merge". Correctly propose-only; `isContiguousRun` correctly
  omitted rather than shipped as machinery guarding nothing. ✔
- **The exit roads are the gap** → MINOR 1 (the sheet's own dismiss does not
  clear picking mode, against `exitSelection`'s stated rule).

### 7. The drift pin — **EXTENDED, never weakened. CLEAN.**

Verified at the source rather than from the claim:

- The **words** assertion (`MobileBlockMenuTests.swift:137-141`) is
  **untouched** by the diff — it still compares the rendered submenu against
  the literal `["Toggle Callout", "Blue", "Green", "Sand", "Violet", "Rose",
  "Emoji…", "Remove Callout"]`. The diff only *adds* below it.
- `MobileBlockMenuController.calloutRowTitles` is unchanged (`:171-175`), and
  no row was added — an `image:` was hung on the existing colour rows.
- The added assertion is genuinely **additive and composed**: colour rows
  carry a swatch, non-colour rows carry none (the Mac's own `swatch` nil-ness
  rule), plus `.alwaysOriginal` and the size. The `.alwaysOriginal` claim is
  load-bearing and correct — a template image would be recoloured to the
  menu's tint.
- **The one sanctioned flip elsewhere is backed.**
  `MobileTakesBrowserSurfaceTests`' card-⋯ literal was replaced by a
  composition from `cardRowTitles(fanned:locked:)`, which would be a weakening
  **unless that vocabulary is pinned by value** — and it is, in this batch's
  own suite: `theCardMenuCarriesTheStructureRowInOrderAndItIsNotDestructive`
  asserts `cardRowTitles(fanned: true, locked: false) == ["Block History…",
  "Label Take…", "Move Take Up", "Move Take Down", "Lock Take", "Take to New
  Block Below", "Archive Take", "Delete Take"]`. ✔ Extended, not weakened.

### 8. Pin quality overall — **HIGH. Four of the nine reverts reproduced; no green-over-nothing found in the sampled set.**

I reproduced **four** reverts on **production** files (never tests), each
restored from the uniquely-named `cr-b7-prerevert/` and `diff`-verified
identical afterwards: **R3** (latch), **R7** (prune), **R9** (M23), and a
**reorder** revert of my own choosing (§10 below). Every one produced a real
red at the claimed mechanism, and in three of four the *controls* the record
says stay green did stay green — which is the property that distinguishes a
grounded pin from a broad one.

The two self-caught hollow pins are the strongest signal in the batch: both
were found by the implementer's own reverts, both were **re-aimed at the
mechanism's real consequence rather than deleted or papered**, and both
re-groundings reproduce. That is the hallucination guard running in the
direction it was written for.

Hunting green-over-nothing, I found **one** real instance and it is MINOR 2
(PR20's join is unpinned — the feature could be disconnected in
`MobileWriteView` with every pin still green). The emoji sheet's buttons are
also undriven, which the record declares honestly (§11-6) and which MINOR 4
turns into a concrete ask.

### 9. The forked-brains row — **ACCURATE and COHERENT. CLEAN.**

The KnownIssues edit names three new forks and one widening, and I verified
each Mac twin exists where it is said to:
`TakeStructureCopy` at `App/Variorum/Variorum/Registry/OpsRefusalCopy.swift:137`;
`BlockSelectionCopy` at `:169`;
`BlockSelection` at `Registry/BlockSelection.swift:31`, carrying both members
the phone's subset omits — `extend(to:in:)` at `:77` and `isContiguousRun` at
`:120` — so the "strict subset" claim is exact, and the added instruction
(*a hoist must bring them back **with the acts that need them***) is the right
thing to have written down. The `MobileCallout`/`swatchImage` widening sits on
the already-listed `CalloutPalette` fork, correctly. Owner unchanged (the
mobile project row), the entry points at the batch record, and the "they name
no chord" characterisation is true of all four (I checked the receipts and the
confirm: no `⌘`, no `⌥`, pinned by
`theConfirmComposesTheOneRoadBackAndNamesNoChord`).

*Not a finding, noted for whoever next edits the row:* the phone's subset also
drops the Mac's `anchor` field and its independent pruning — entailed by
dropping `extend`, so nothing is missing, but a future hoist must restore the
anchor **and** its `prune` arm together, not just the method.

### 10. The fence — **RE-DERIVED BY ME, CLEAN** (commands and output at the top of this file)

Zero lines under `Sources/`, `App/Variorum/Shared/`, `App/Variorum/Variorum/`,
`EditorBrain/`, or any project file; `planVisibleTakeEdit` zero Swift hits.
The 18-file diff is entirely mobile target + tests + two notes files.
`Package.resolved` untouched (no drift to revert).

---

## Also checked, and clean (not in the brief's ten, worth recording)

- **Every whole-note copy road is covered by M23.** I enumerated them:
  `copyNote()` from `MobileWriteView.swift:570` is the **only** one — there is
  no share sheet, no `UIActivityViewController`, no library-side copy. The
  brief's "and any other whole-note copy road" has no second member. ✔
- **`displayedProjection` is byte-equivalent to `renderedText`'s walk** when
  `displayed` is empty for a block — `compactMap(\.text)` and
  `map { … ?? "" }.filter { !$0.isEmpty }` drop nil-text slots identically, and
  both go through `joinRenderedTexts`. Blank peeked takes correctly skip like
  blank chosen ones. ✔
- **The emoji seam's ordering is right and pinned** — `promptForEmoji` wins
  when installed (`theEmojiSeamIsPreferredOverTheTextPromptWhenBothExist`),
  which matters because the VM installs both; without that pin a reordering
  would silently disable the emoji keyboard in production while every other
  emoji pin stayed green.
- **`MobileEmojiPromptController`'s completion really does fire exactly once
  on every road out** — `finish` clears `completion` before dismissing, and
  `presentationControllerDidDismiss` guards on it, so a button press followed
  by the dismissal callback cannot answer twice. Programmatic `dismiss` does
  not fire the delegate, so the swipe path is the only second road and it is
  handled. ✔
- **`textInputContextIdentifier = ""`** is a genuinely good detail — without
  it UIKit's keyboard-choice memory leaks between fields.
- **Accessibility on every new surface:** the chrome button carries an
  explicit label; the Select/Done toggle carries a *distinct* VoiceOver name
  precisely because two "Done" doors would otherwise be indistinguishable in
  one tree (a nice catch); the pick mark rides `.isSelected` rather than
  relying on the `◉`/`○` glyph. ✔
- **The `commitNow` rider's literal answer is correct.** I confirmed
  `MobileBlockHistory.commitNow` still has exactly one caller
  (`MobileBlockMenu.swift:196`, a dismissing `UIMenu` row) and that nothing in
  this diff gives it a second or a non-dismissing host. The record's decision
  to also record the criterion applied *forward* is the right reading. ✔

---

# ADJUDICATION + FIX-WAVE BRIEF (the Fable orchestrator, 2026-08-31)

**ALL EIGHT ACCEPTED, ZERO DISPUTES.** One fix wave; the orchestrator's
verification closes the unit (these MAJORs are sheet-chrome and receipt
fixes, not seam surgery — the 4.5c round-2 escalation is not owed here).
Shapes:

1. **MAJOR 1 — the silence gets its sentence, in-fence.** When the
   callout fallback runs (a framed note copied while peeking), the copy's
   existing `Outcome`/receipt says honestly that the copy used the
   note's SAVED takes, not the screen. One sentence, shared-voice
   composed, pinned red-on-old (the framed+peeked world's receipt names
   the fallback; the unframed world's does not). The record's grading
   paragraph is corrected to name the real cost (wrong take's prose,
   silent). **And the one-word cure gets its durable owner:** one clause
   in the seat handoff §4's #94 deferral list — `Queries.exportMapped`
   → `public` (zero behaviour, one keyword) rides the post-13u merge
   session with the four hoists, so M23's corner closes there.
2. **MAJOR 2 — the act comes back.** Trace what ends a card's live state
   on that sheet by USER-reachable roads; the actions row re-shows the
   moment no card is live. If no user-reachable end-editing road exists
   at all, MAKE the standard one work (the sheet's background tap /
   another card's blur — whichever the surface already half-owns), never
   invent a new gesture. Pin: card live → row gone (the 30 pt pin rides
   unmodified); card ends by the user road → row BACK, act fires. If
   the trace shows this needs more than the sheet's own files, STOP AND
   REPORT.
3. **MINOR 1** — `exitSelection` on sheet dismissal (the rule its own
   comment states); pin.
4. **MINOR 2** — pin the JOIN on a hosted `MobileWriteScreen` (the
   pattern the 7 existing suites own): `onDeleteBlocks` wired, the bulk
   act reaching `deleteWholeBlockRun` — red when the wiring is nil'd.
5. **MINOR 3** — per your trace: either discriminate success/refusal
   independently of `refresh()`'s throw, or make the refusal road
   explicit; the record's §11-4 answer is corrected either way.
6. **MINOR 4** — the emoji sheet sizes to content or scrolls (no hard
   220 pt cliff under Dynamic Type); the keyboard-overlap half stays
   SPECULATIVE and joins the DEVICE QUEUE note in the record.
7. **NIT 1** — five, in all three homes. **NIT 2** — R7's account
   completed (two tests, in the batch's favour).

Environment and rules exactly as the batch brief (own armed simulator,
private DerivedData, deleted after; full suite — baseline 706/102 + 2
known issues — final line quoted; unique pre-revert dir, diff-verified
restores; fence grep + planVisibleTakeEdit zero; pathspec-limited
commit; no pushes). Reds quoted, production or fixture named. Append a
FIX WAVE RESULTS section to THIS file before the final message.
