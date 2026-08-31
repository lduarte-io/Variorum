# Batch 9 — THE ⋯ VOCABULARY + TEXT SELECTION · the record (built 2026-08-31)

> **⚠️ AMENDED BY THE FIX WAVE, 2026-08-31** (the cold review is
> `mobile-batch-9-cold-review.md`; its **FIX WAVE RESULTS** section is that wave's own
> record and carries the reds, the files and the final suite line). Four sections of
> THIS file changed and are marked in place: **§4.3 item 1** (the rule-out re-measured
> on a LOADED fixture — MINOR 2), **§4.4** (her "up and down" geometry argues against
> S3 — NIT 4), **§4.6** (the stranding defect's owner COMMITTED and the fix's shape
> ruled — MAJOR 1's record half; the defect itself is NOT fixed in that wave), and
> **§5** (three provenance corrections to "what exists today, precisely" — MINOR 1).
> **§8's count is superseded**: the wave added one walk pin, so the suite is **667 / 99**.

**The brief is `notes/plans/mobile-batch-9-brief.md`** and it binds. Her list is
verbatim there and in `notes/author-reports/2026-08-23-device-walk-and-product-asks.md`
(the source both cite).

Read in full, in this session, before any code: `CLAUDE.md` · `notes/MobileSoul.md`
(§2–§6 + PL-10/PL-11/PL-14/PL-15) · `mobile-round-2.md` §16's binding batch map,
§67–§68, §69–§71 · `notes/plans/mobile-batch-6b-record.md` · her verbatim report ·
and the code: `MobileBlockMenu.swift`, `MobileNoteActions.swift`,
`MobileTakesBrowser.swift` + `MobileTakesBrowserView.swift`,
`MobileBlockHistory.swift` + `MobileBlockHistorySheetView.swift`,
`MobileKeyboardBar.swift`, `MobileEditMenuSeam.swift`, `MobileEditorTextView.swift`,
`MobileEditorViewModel.swift` (the projection/render seam), `MobileTakesChrome.swift`
(the pan router), `MobileWriteView.swift`.

---

## 1 · DELIVERABLE 1 — THE VERIFY-FIRST INVENTORY

**Her phone runs the 2026-08-21 build (R30); her list is dated 2026-08-23.** Batch 4
landed **2026-08-22**. That one-day gap explains her whole first ask, and it is the
reason this deliverable exists.

### The row sets as they stood at `0aa6479` (before this batch)

| menu | where it lives | rows, in order |
|---|---|---|
| **note ⋯** | `MobileNoteActionsSheet`, masthead note-tool corner (`MobileWriteView.noteActionsDoor`) — beside copy · find · seal, **always visible however far she has scrolled** | Save a Version · Versions… · ── · **Undo ‹label›** *(rendered only when the stack has an end)* · **Redo ‹label›** *(same)* · ── · Delete Note… · the report line |
| **block ⋯** | `MobileBlockMenuController.menuElements`, rendered by the keyboard bar's ⋯ (`includeTakes: true`) | **Takes…** · Comments… · Callout ▸ · Name Block… · Commit Take · **Block History…** · New Block Below · Divide Block · Merge with Previous · Archive Block · Delete Block |
| **block ⋯, edit-menu arm** | same builder, `includeTakes: false`, inside `MobileEditMenu.menu`'s `Block` submenu | the same list **minus Takes…** (the edit menu carries its own flat `Takes…` beside it) |
| **per-take ⋯** | `MobileTakesCardView.apply`, on every LIVE take card in the browser | Label Take… · Lock/Unlock Take · Archive Take · Delete Take |
| **archived-take ⋯** | `MobileArchivedTakeCardView.apply` | Unarchive Take · Label Take… · Delete Take |

### Her four asks, mapped

| # | her words | verdict |
|---|---|---|
| 1 | *"structural undo should be added to the ... menu (and structural redo needs to be an option as well). i want it easy to access."* | **ALREADY BUILT — NOT REBUILT.** See below. |
| 2 | *"take history should move into the three ... menu on each take rather than the main three dot menu"* | **NOT built — deliverable 3.** |
| 3 | *"i also don't think takes needs to be an option on the three dot menu, it's already the middle bar"* | **NOT done — deliverable 2.** |
| 4 | *"i also only see merge with previous rather than a multi merge option? … idk, let's think about that three dots menu a little more"* | **PROPOSE-ONLY — §5.** Nothing built. |

### Ask 1, verified rather than assumed — and *why she could not have seen it*

**The evidence for "already built":** `MobileUndoDoor` (M20, her own R10 proposal) +
`MobileNoteActionsSheet.undoRow`/`redoRow`, which render
`StructuralUndoCopy.undoDoorTitle(door.undoLabel)` / `.redoDoorTitle(door.redoLabel)`
— the stack's LIVE labels, so the rows read *"Undo Divide"*, *"Redo Delete Blocks"*
rather than naming a direction and hoping.

**The reason her ask reads as though nothing existed is stronger than "she has an old
build": ON HER BUILD THERE WAS NO NOTE ⋯ AT ALL.** `MobileNoteActions.swift` is batch
4's file (2026-08-22) — it created the masthead ⋯ *and* put undo/redo in it in the same
commit. So on 2026-08-21 the only ⋯ menus in the app were the **block** ⋯ and the
**per-take** ⋯, which is exactly the vocabulary her sentence uses (*"the ... menu"*,
*"the main three dot menu"*, *"the three ... menu on each take"*). She was not asking
for a row to be added to a menu that already had it; she was asking for a door that
did not exist anywhere, in the only menu she could see.

**"Easy to access", counted honestly, from the editor with the keyboard up:**

- **Undo/Redo — 2 taps.** ⋯ in the masthead (always on screen — it does not scroll
  away and it does not need the keyboard) → the row. *There is also a ONE-tap road she
  may not have met: every structural act's receipt carries its own Undo/Redo button
  (`report(_:action:)`), which is where she is looking at the moment she wants it.*
- The rows are **P-2-gated**: with an empty stack neither renders, which is why a
  fresh note shows Save a Version · Versions… · Delete Note… and nothing else
  (`MobileUndoDoorTests.theSheetRendersNoUndoRowWithAnEmptyStack`).

**"Render and act", DRIVEN not read:**

- **Undo** was already pinned end to end through the real masthead + the real sheet row
  — `MobileUndoDoorTests.theNoteActionsSheetUndoRowIsReachableAndActs` (pre-existing,
  untouched).
- **Redo had a RECEIPT pin and no SHEET pin.** That gap is closed here:
  `MobileMenuVocabularyTests.theNoteActionsSheetRedoRowIsReachableAndActs` opens the
  real ⋯, finds *"Redo Delete Block"*, activates it, and reads the store. Its red is
  **A5** below, so the verification has teeth rather than being a green over nothing.

**Recorded for her bundle:** nothing about ask 1 was rebuilt. If she still finds it
hard to reach once she is on a current build, that is a *placement* question, not a
missing capability — and the placement is the masthead corner she already uses for
copy/find/seal.

---

## 2 · DELIVERABLE 2 — `Takes…` LEAVES THE BLOCK ⋯

Her letter: *"it's already the middle bar."* **It literally is.** The keyboard bar
rests on three acts — `restingActLabels == ["Formatting", "Takes", "Block"]`, i.e.
**Aa · ⑂ · ⋯** — and ⑂ (`fireTakes` → `openTakesBrowserAtCaret`) opens the same
browser on the same caret block that the ⋯ row opened. Two doors onto one surface, an
inch apart.

**Shipped:**

- The `Takes…` `UIAction` and the `takesTitle` constant are gone from
  `MobileBlockMenuController`; `rowTitles` is nine rows, not ten.
- **The `includeTakes:` parameter went with it.** Both callers were read first: it
  existed for exactly one purpose — keeping this row out of the edit menu's `Block`
  submenu, which carries its own flat `Takes…`. With the row retired the split had
  nothing left to suppress, so `menuElements(blockID:)` now has no arm and the two
  doors render byte-identical lists.
- **`MobileEditMenu`'s own flat `Takes…` SURVIVES, deliberately**, and the reasoning is
  at the code: her sentence names *"the three ... menu"*, and her reason is proximity
  to the bar's ⑂. Neither reaches the SELECTION's menu, which is summoned on held text
  and whose `Takes…` is the only takes door inside that gesture. She did not name it;
  it was not touched.

**The capability is not orphaned, and the pin proves it rather than asserting it:**
`theBlockMenuDropsTakesAndTheBarsMiddleActStillOpensTheBrowser` checks the absence over
a menu that still holds nine rows (never a vacuous check against an empty list) **and**
in the same test fires the surviving door — `bar.fireTakes()` on a real
`MobileKeyboardBarController` over the real surface — and asserts the browser opened on
the caret's block.

---

## 3 · DELIVERABLE 3 — BLOCK HISTORY MOVES TO THE PER-TAKE ⋯

Her letter: *"take history should move into the three ... menu on each take rather than
the main three dot menu."* Honored as written — a **move**, so the block ⋯'s row is
removed, not duplicated.

**Shipped:**

- Every **live** take card's ⋯ gains **`Block History…`**, and it **leads** the menu
  (looking before acting; the identity/state/destructive rows follow in their existing
  order).
- **The word did not fork.** The row's title is
  `MobileTakesBrowserController.historyTitle`, *composed* as
  `"\(BlockHistoryPath.name)…"` — the SHARED face's own name from
  `App/Variorum/Shared/BlockHistoryFace.swift`. It still reads `Block History…`
  byte-for-byte, and a re-word lands once. Moving a row is exactly the moment a literal
  becomes two literals; it did not.
- **It opens FOCUSED on the take whose card was pressed.**
  `MobileBlockHistoryController.open(blockID:focused:)` takes an optional focus;
  `nil` keeps the original rule (the block's DISPLAYED take), so the thirteen existing
  `open(blockID:)` call sites ride unmodified. This is the move's actual *gain*: the
  block-⋯ road could only ever expand the displayed take's savepoint run, whichever
  card she was really asking about.
- **The browser closes first**, and the pin asserts it. Reasons, both at the code:
  *mechanical* — the takes browser and the history sheet are overlay views installed
  lazily as SIBLINGS on the page's host, so their z-order is whichever opened first in
  the session, and neither is `accessibilityViewIsModal`, so a stacked pair would put
  two surfaces' labels in one tree; *product* — the browser is where you choose a take
  and the history face is where you read what a block has been, and one subject at a
  time is the phone's calm default. The precedent is the phone's own: the note ⋯'s
  `Versions…` row dismisses its sheet and then asks the shell to push.
  `close()` also flushes (through `refreshTakesFromStore`), so a card edited a
  keystroke ago is in the store before the face reads it — the standing flush-first
  contract, and why `openHistory` is async.
- The block ⋯'s `Block History…` row and `historyTitle` constant are **removed**.

### Nothing is orphaned — the road per region, stated

| region | road after the move |
|---|---|
| **Savepoint runs** (all live takes) | ⑂ / edit-menu `Takes…` / the ⑂ badge → the browser → any live card's ⋯ → `Block History…`. **I10 guarantees a live block always has ≥ 1 live active take**, so the browser always renders at least one card carrying the door. |
| **Archived takes** | the same road — *and* they are listed with Unarchive/Delete in the browser's own archived section (parity C4a), which is a second, independent road. |
| **Deleted takes** | the same road — *and* `blocks ▸ leaving` (batch 6b's tray), which is the only place a take's clock can be ended early. |
| **Came from** (all originals + Bring back) | the same road. Batch 6a's lineage door is this face; there is no second one. |

### ⚠️ ONE ROAD DID CLOSE, and it is named rather than left to be discovered

**A GAP BLOCK'S history is no longer reachable.** `MobileTakesBrowserController.open`
refuses on a gap (`slot.isGap` — an un-synced placement with no variant: *"This block
hasn't fully synced; it is read-only for now"*), and the block ⋯'s row was the only
door that did not go through the browser. A gap block's history is thin by construction
(no live take ⇒ no savepoint runs; at most deleted takes and origins) and the state is
a sync race rather than a place she sits — but it is a real, if narrow, regression of
reach and it is **PROVISIONAL 3** below.

### The archived-take card deliberately did NOT get the row

Her letter says *"each take"*, and an archived take is one. It was **left off on
purpose, with the mechanism recorded at the code**: the door's whole gain is focusing
the take it was pressed on, and `BlockHistoryExpansion.initiallyExpanded` would accept
an archived id (it reads `history.takes`, which carries archived rows) and then find no
`takeHeader` for it, because `rows()` sections the **active** takes only — so the face
would open with *nothing* expanded, which is worse than the default. Every archived
take on that card is already one of the face's four regions. **PROVISIONAL 4.**

### Her G2 commit/history pairing ends, visibly

`Commit Take` stays on the block ⋯: it is a block-scale act on the caret's DISPLAYED
take, and she asked for the **listing** to move, not the act. The old pin asserted the
adjacency (`history == commit + 1`); it is rewritten to hold the new fact plus the
precondition that still constrains it, with the retirement stated in the pin rather
than silently deleted. The *"write a moment / see the moments"* pairing survives one
grain up, on the note ⋯ (`Save a Version` + `Versions…`, batch 6c's finding 2).
**PROVISIONAL 5.**

---

## 4 · DELIVERABLE 5 — THE TEXT-SELECTION DEFECT · **TRACED, NOT FIXED**

Her report: *"right now it is genuinely hard to copy and paste text because the copying
and dragging up and down doesn't work correctly, holding it down makes you scroll
upwards, the exact opposite. so that needs to be fixed."*

**HEADLINE: the mechanism is NOT found, and nothing was built for it.** The brief's own
rule is *"do not design before you have the mechanism"*, and CLAUDE.md's is *do not
invent product behaviour*. What follows is the trace: what was measured, what that
RULES OUT, what survives, and the one experiment that would settle it. **This is the
M1 shape** — that row sat at *"high confidence, NOT PROVEN"* until **E1 ran on her
device** and the signature fired (§67). This one is not even at high confidence yet.

### 4.1 · Reproduction — attempted, and it is NOT available in this harness

**It could not be reproduced.** Stated plainly because a silent "traced by reading" is
the thing a reviewer cannot check:

- The defect lives in a **touch-driven UIKit interaction** — the loupe
  (`UIVariableDelayLoupeGesture`), the handle drag
  (`UITextRangeAdjustmentGestureRecognizer`), and/or drag-and-drop's own auto-scroll
  (`_UIDragAutoScrollGestureRecognizer`) — all internal, all driven by real `UITouch`
  sequences that **cannot be synthesised in process** (touch synthesis is private API).
- The unit harness never presents a software keyboard at all (recorded independently in
  `MobileKeyboardBar.swift`: under `xcodebuild test` the accessory view's `window`
  stays nil), so the geometry a real drag happens in cannot be assembled either.
- `VariorumMobileUITests` exists and the Stage-0 TK2 spike proved **real synthesised
  touches work there** (`press(forDuration:thenDragTo:)`). It is the honest road to a
  reproduction — but it drives the app from LAUNCH, and reaching a long note on the
  real Write surface means driving shelf → book → note through accessibility, in a
  target the standard scheme does not run. That is its own piece of work, and it is
  named in §4.5 rather than half-started here.

### 4.2 · What WAS measured, on the real mounted surface

A throwaway probe (`ZZProbeSelectionScroll`, deleted before commit — its numbers are
here, which is the point) mounted the real `MobileWriteSurfaceView` in a real
`UIWindow` at 393 × 852 over a 120-block / 19,689-character post:

```
PROBE bounds=(393.0, 852.0)
PROBE textContainerInset=UIEdgeInsets(top: 8.0, left: 15.0, bottom: 835.0, right: 15.0)
PROBE contentInset=UIEdgeInsets(0,0,0,0) adjusted=UIEdgeInsets(0,0,0,0)
PROBE contentSize=(393.0, 11385.0)
PROBE keyboardDismissMode=2                      // .interactive
PROBE storageEqualAfterScroll=true
PROBE stringEqualAfterScroll=true
PROBE roomBefore=835.0 roomAfter=499.0
PROBE contentSizeBefore=11825.0 after=11489.0
PROBE offsetBefore=1600.0 after=1600.0
PROBE gestureRecognizers=[UITextMultiTapRecognizer, UITapAndAHalfRecognizer,
  UIVariableDelayLoupeGesture, _UIPanOrFlickGestureRecognizer, UITextTapRecognizer,
  UITextRangeAdjustmentGestureRecognizer, UITapGestureRecognizer,
  UIScrollViewDelayedTouchesBeganGestureRecognizer, UIScrollViewPanGestureRecognizer,
  … _UIDragAutoScrollGestureRecognizer, _UIDragLiftGestureRecognizer, …,
  UITapGestureRecognizer, UIPanGestureRecognizer]
```

### 4.3 · RULED OUT by measurement (do not re-open these)

1. **"The page rewrites itself under the drag."** The chrome refresh runs on EVERY
   scroll tick (`layoutSubviews` → `refreshChrome(.nearViewport)`) and it DOES write
   paragraph-style reservations — so a storage mutation mid-drag, which would cancel a
   selection interaction outright, was the leading candidate. **Measured: it does not
   happen.** A full `NSAttributedString` snapshot before and after two scroll jumps
   compares EQUAL, attributes included (`storageEqualAfterScroll=true`). The
   equality-gating in `MobileTakesChromeController.refresh` holds.

   > **⚠️ RE-MEASURED AT THE FIX WAVE, on a LOADED fixture — cold-review MINOR 2, and
   > the reviewer was right about the first measurement.** Every storage-WRITING branch
   > of that refresh is conditional — `MobileTakesChrome.swift:195`
   > (`where slot.hasFan` → `setTailReservation`), `MobileBlockDecor.swift:119`
   > (`guard let presentation` → `setLeadingFirstLineReservation`, and only with an
   > emoji), `MobileBlockDecor.swift:193` (`where slot.commentCount > 0`) — so on the
   > original plain-block fixture the write path was **structurally unreachable** and
   > the equality held by construction. The rule-out was a green over nothing.
   >
   > **The fix wave re-took it on a fixture that reaches all three writers** (120
   > blocks; block 10 FANNED *and* commented, block 20 a callout carrying an emoji,
   > block 30 plain-and-commented), and **proved they executed before reading the
   > equality** — a paragraph's `tailIndent`/`firstLineHeadIndent` is non-zero only if
   > the writer ran:
   >
   > ```
   > PROBE slots=120 fanned=1 commented=2 emojiCallouts=1
   > PROBE writersRan fannedTailIndent=-56.0 calloutFirstLineHeadIndent=27.0
   > PROBE contentSize=(393.0, 9558.0) inset=UIEdgeInsets(top: 8.0, left: 15.0, bottom: 835.0, right: 15.0) contentInset=UIEdgeInsets(0,0,0,0) adjusted=UIEdgeInsets(0,0,0,0)
   > PROBE storageEqualAfterFirstScroll=true
   > PROBE storageEqualAfterScroll=true
   > PROBE stringEqualAfterScroll=true
   > PROBE offsetEnd=4200.0 contentSizeEnd=10242.0
   > PROBE endFannedTailIndent=-56.0 endCalloutGap=27.0
   > ```
   >
   > **The rule-out SURVIVES, and now it means something:** with all three writers
   > populated and demonstrably fired, two scroll jumps (one carrying the loaded blocks
   > off the near-viewport band entirely) leave storage byte-identical, attributes
   > included. The equality gates — `setTailReservation`'s
   > `guard abs(style.tailIndent - target) > 0.01` and its leading twin — are what hold
   > it. **The "do not re-open" instruction therefore stands for the FANNED and CALLOUT
   > shapes too**, which is exactly what the earlier fixture could not say and what her
   > real notes actually carry.
   >
   > *The probe was again a throwaway (`ZZProbeLoadedChromeScroll`, deleted before
   > commit — the 6b NIT-3 precedent); its numbers are above, which is the point, and
   > its fixture is described precisely enough to rebuild in one sitting.*
2. **"The typewriter room's recompute yanks the offset."** `textContainerInset.bottom`
   really is enormous (**835 pt of an 852 pt viewport**) and really does recompute on
   every height change. **Measured: the offset does not move.** Shrinking the surface by
   336 pt (a keyboard's worth) took the room 835 → 499 and `contentSize` 11825 → 11489
   with `contentOffset.y` **1600 → 1600**.
3. **Scroll-inset arithmetic.** `contentInset` and `adjustedContentInset` are **zero**,
   so there is no inset for an auto-scroll calculation to have the sign of.
4. **The app inverting anything itself.** `MobileEditorTextView` overrides
   `insertText`, `performTabKey`, `keyCommands`, `supportsTextReplacement` and `paste`
   — and **nothing selection- or geometry-shaped**: no `caretRect(for:)`, no
   `selectionRects(for:)`, no `textViewDidChangeSelection` handler anywhere in
   `VariorumMobile/` or `Shared/`. Every `selectedRange =` write in the app is behind an
   edit or an explicit jump (`jumpToBlock`, the structural ops' caret landings,
   `MobileMarkdownActs`), never behind a scroll or a selection change.

### 4.4 · SURVIVING candidates, with what each predicts

| # | candidate | app-local? | what it predicts | how to kill it |
|---|---|---|---|---|
| **S1** | **The gesture is being taken by the SCROLL PAN, not by the selection interaction.** Then dragging DOWN scrolls the content down — which moves you UP the document, and *"holding it down makes you scroll upwards, the exact opposite"* is a literal description of that. | partly | her drag never selects at all; the loupe never appears | a device trace: does the loupe show? |
| **S2** | **`keyboardDismissMode = .interactive`** (set by the app, measured). It is precisely a *downward drag* handler on this scroll view, and it competes for the same gesture. | **YES** | the keyboard follows her finger down as it happens | flip it to `.none` on a device build and re-drag |
| **S3** | **The app's own `UIPanGestureRecognizer`** (M5's swipe-peek, `MobileTakesPanRouter`) — the only app-added recognizer that competes with a drag, and `cancelsTouchesInView` defaults **true**, so if it ever begins it kills the drag in flight. | **YES** | the failure happens only on **fanned** blocks (`panTargetBlockID` requires `hasFan`) and only on drags that start >≈56° off vertical (`abs(tx) > abs(ty) * 1.5 && abs(tx) > 4`) | ask her whether it happens on plain, un-fanned blocks |
| **S4** | **Text drag-and-drop, not selection at all.** `_UIDragLiftGestureRecognizer` and `_UIDragAutoScrollGestureRecognizer` are both installed. Long-pressing text that is ALREADY selected lifts a drag, and drag auto-scroll is what runs near an edge. **Her M16 report is the same interaction family** — *"it looked like i would be able to move it and had a cursor for placement but then just didn't move there"* — and that one is already known broken. | no (system) | the two reports have ONE cause, and fixing M16 fixes this | a device trace distinguishing lift from handle-drag |

**The angle arithmetic for S3 is read from the code, not measured.** The probe's sweep
was **confounded and is not evidence**: a synthetic `UIPanGestureRecognizer` has no
touch, so `pan.location(in:)` returns `.zero`, `panTargetBlockID` hit-tests above the
text and returns nil, and the gate answered `no` at every angle including pure
horizontal. Recorded as a confound rather than reported as a result.

**⚠️ AND HER OWN GEOMETRY ARGUES AGAINST S3 — said out loud at the fix wave
(cold-review NIT 4), because this table claims to rank by evidence.** The pan router's
gate is **horizontal dominance** (`MobileTakesChrome.swift:566-567` —
`abs(translation.x) > abs(translation.y) * 1.5, abs(translation.x) > 4`), and her
report is about dragging **"up and down"**. A near-vertical drag cannot open that gate,
so the direction she describes is evidence *against* this candidate, not for it. **S3
stays on the list anyway, and deliberately:** it is one of only two app-local
candidates, it is the cheapest of the four to fix if it IS the cause, and question 2 of
§4.5 kills or confirms it outright in one observation. What changes is only the
honesty of the ranking — S3 is the one candidate whose own predicate her wording
already strains.

### 4.5 · THE ONE EXPERIMENT THAT SETTLES IT — hers, and it is small

This is E1's shape: the question is about what iOS does under her finger, and only her
finger can answer it. **Three observations, in one minute on the phone**, would collapse
the table above to one row:

1. **Does the LOUPE/magnifier appear** when she long-presses in the note? *(No ⇒ S1/S2:
   the gesture is never a selection. Yes ⇒ S3/S4.)*
2. **Does it happen on a plain block with NO takes**, or only on fanned ones? *(Only
   fanned ⇒ **S3, the app's own pan**, which is a one-line fix with a real pin.)*
3. **Is the text already selected before the drag that misbehaves?** *(Yes ⇒ **S4**, and
   it is M16's twin rather than a second bug.)*

**Recorded consequence for the round:** if (2) says fanned-only, the fix is phone-local
and cheap. Everything else routes to **13u1's editor-seam work** (its item 1 is *"non
editing pane stability… essential to the app feeling good"*, the same felt family) or,
if (3) says drag-lift, to **13u item 12**, which already owns multi-block drag on both
platforms and already records that the gesture does not complete.

### 4.6 · 🟠 A REAL DEFECT THE TRACE FOUND ON THE WAY — measured, recorded, NOT her bug

**`isEditable` can be STRANDED FALSE, leaving her page permanently read-only with no
sheet on screen.** Three overlay sheets — the takes browser, the comments sheet and the
block-history sheet — each save the page's `isEditable`, force it false, and restore
what they saved. Interleave two and the inner one saves the OUTER one's `false`:

```
PROBE editable at rest=true
PROBE after browser open editable=false
PROBE reverse-order editable=false   <-- browser open, history open, browser close, history close
```

**Why it is recorded and not fixed here:** it is not traced to her report (a
non-editable text view still *selects*, so it is a plausible aggravator of S1, not a
proven cause), and the fix is a posture change across three sheet files — exactly the
"design before mechanism" trap. **What WAS done is the part that is batch 9's own:** the
new per-take history door is the FIRST road in the app that goes from one of these
sheets to another, so it closes the browser BEFORE opening the face (properly nested),
and `theHistoryDoorLeavesThePageEditableAfterwards` pins that ordering with a real red
(**A6**). Whether the pre-existing interleave is reachable by any OTHER road was NOT
established — both sheets are summoned from the keyboard bar, which a covering sheet
hides — so it may be latent. **On her sitting list.**

### 🟠 THE OWNER, COMMITTED — and the fix's SHAPE ruled with it (fix wave, cold-review MAJOR 1)

*This supersedes the sentence this section used to end on — **"the natural owner is
13u2's pane work or a 17-entry"** — which named two candidates and therefore no owner:
the exact state `notes/KnownIssuesAndTechDebt.md`'s header forbids, and the state the
"six mobile brains" row was RESTORED to that file to escape. The reviewer was right
that a defect living only as prose in a plan file that closes has no owner at all.*

- **OWNER: the leftover-review-backlog consolidated batch** — the seat road's item 7
  (`mobile-round-2-fable-seat-handoff.md`), now written on the authoritative schedule
  row in `mobile-round-2-handoff-2026-08-30.md` **§7.2**. It is **in-round,
  phone-local and days away**, which is why it beats both candidates the old sentence
  offered: 13u2 is a Mac phase behind a fence, and a 17-entry would move a
  phone-local defect out of the round that found it.
- **THE FIX'S SHAPE, ruled at adjudication so the owner inherits a decision rather
  than a design problem:** the three per-sheet `pageWasEditable` save/restore pairs
  (`MobileTakesBrowserView.swift:226-234`, `MobileCommentsSheetView.swift:127-136`,
  `MobileBlockHistorySheetView.swift:143-150`) are replaced by **ONE nesting-aware
  editability authority on the write surface** — a depth count (sheets push and pop;
  the page is editable only at depth 0), or an equivalent restore-to-rest rule. The
  builder picks the minimal shape and **pins the reviewer's own two-sheet interleave
  red-on-old** (browser open → history open → browser close → history close ⇒ the page
  must end editable). This is the same "one authority" move `PaneTextAuthority` already
  is for liveness; three independent save/restore pairs is the shape that produced the
  bug.
- **What must NOT silently regress:** batch 9's own door stays properly nested
  (`openHistory` closes the browser BEFORE opening the face), and
  `theHistoryDoorLeavesThePageEditableAfterwards` keeps pinning that ordering with its
  A6 red. The authority replaces the mechanism underneath; it does not retire the pin.
- **The un-established half stays un-established**, said rather than guessed: whether
  any PRE-batch-9 road reaches the interleave was not determined here, and the cold
  reviewer's own independent search found none (the other two sheets are summoned from
  the keyboard bar, which a covering sheet hides). That is *support* for "latent",
  never proof — and it is exactly why the defect needed a row that survives this file.

---

## 5 · DELIVERABLE 4 — THE MERGE-VOCABULARY PROPOSAL · **PROPOSE-ONLY, NOTHING BUILT**

Her words: *"i also only see merge with previous rather than a multi merge option? or do
we need to add multi merge on mobile still? or a select and then merge? idk, let's think
about that three dots menu a little more."*

### What exists today, precisely

*(**Three corrections landed at the fix wave** — cold-review MINOR 1. This section
carries the heading "what exists today, **precisely**" and goes to her sitting bundle,
so the provenance had to be right. Every correction makes shape (A) STRONGER, not
weaker: it stops being a phone invention to design and becomes a shipped Mac gesture to
mirror.)*

- **The phone has ONE merge door: `Merge with Previous`** in the block ⋯, acting on the
  caret's block (`MobileStructuralController.mergeWithPrevious`). Her reading of the
  menu is exactly right.
- **THE CORE OPS ARE BINARY** — *this line used to read "the op underneath is NOT
  binary", and that was wrong*:
  `Operations+Structural.swift:659` is `merge(_ firstBlockID:, _ secondBlockID:)` and
  `:836` is `mergeCeremony(leading:trailing:pairings:carries:)`. Both take exactly two
  blocks. **The 9d N-way merge is a DOOR-level composition**, not an op: the Mac chains
  binary links inside one compound (`EditorSurfaceController.swift:316`,
  `case .mergeChain` → `runMergeChain`, over `CarryAllMerge.chainComposes` in
  `Variorum/Features/Editor/FannedDefaults.swift:104`). **That brain is
  Mac-app-local** — `CarryAllMerge` appears in three Mac files and in **zero** phone or
  `Shared/` files — and **the phone's single door does no chaining at all**:
  `MobileStructural.mergeWithPrevious` (`:202-314`) resolves exactly one
  leading/trailing pair and calls `mergeCeremony` or `merge` once.
- **The phone already shipped the CARRY-ALL MERGE as its fanned default (parity C5)**,
  composed from the Mac's own `mergeCeremony` with zero core change: one pairing of the
  two displayed takes plus every other active take carried whole. **She then ruled the
  Mac should adopt it too** (13j item 4b, 2026-08-09) — *the phone's implementation is
  the reference.*
- **The pairing CEREMONY is a ruled mobile exclusion** (MobileSoul §4.5), and her own
  sharpening is why: *"i thought merge and divide were already overly fiddly on the mac
  app and I think mobile is good for exposing complexity that can't survive a
  simplified UI."*
- **THE MAC ALREADY HAS SHAPE (A), SHIPPED — the Write surface's block-run merge
  chain.** *This line used to name ⌘-click take selection (13e) as "the Mac's own
  multi-merge affordance" and stop there, which omitted the one precedent that matters
  most here.* Selecting a run of blocks on the Mac's Write surface and merging them is
  the `.mergeChain` road above, with its own copy
  (`FannedDefaultsCopy.mergedChain(blocks:carried:)`) and its own pairwise refusal
  (`mergeCeremonyIsPairwise(blocks:)`). 13e's ⌘-click TAKE selection is a different
  grain and does have no phone twin; the phone's **block multi-select is batch 7
  (PR20)**, unbuilt.

### The three shapes

**(A) SELECT-THEN-MERGE — ride batch 7's block multi-select.** PR20 gives the phone a
multi-select mode over blocks; a `Merge Selected` act joins the run **the way the Mac's
Write surface already does — a chain of binary links inside ONE compound**. Her own
third suggestion, verbatim (*"or a select and then merge?"*).
*For:* no new selection grammar — it composes a capability the round is already
building; **it is a MIRROR of a shipped Mac gesture rather than a phone invention**
(MobileSoul §3's own preferred shape); the run is visible and
adjacent-by-construction; one act, one undo entry; nothing new to learn.
*Against:* it is gated on batch 7 landing; multi-select is a mode, so it is two
gestures rather than one for the common two-block case; **and it needs the Mac's chain
brain, which is Mac-app-local today** — see the corrected cost below.

**(B) `Merge with Next` — the missing half of the door she already has.** One more row
in the block ⋯. *For:* smallest possible change, no new machinery, and it removes a real
daily annoyance (to join A and B while the caret is in A, she must move the caret).
*Against:* it does not answer "multi" at all; it answers a different complaint she did
not make. **Worth doing regardless of which shape wins**, and cheap.

**(C) A repeat-merge receipt — "merged. ⌄ merge the next one too".** The receipt after a
merge offers one tap to absorb the following block, again and again. *For:* multi-merge
with NO selection mode and NO new surface, and it is the phone's own fire-and-DO
grammar; each tap is its own undo entry, which is calmer than one compound. *Against:*
a novel idiom with no Mac twin — the drift risk MobileSoul §3 exists to prevent — and
it is invention, which is hers alone to authorise.

### Recommendation

**(A) as the answer to her question, with (B) shipped alongside it whenever the ⋯ is
next open.** (A) is her own suggestion and it is **a shipped Mac gesture mirrored into
the phone's grammar** — the Write surface's block-run merge chain — which is the
strongest thing that can be said for a mobile shape. (B) is a one-row fix to a real gap
that has nothing to do with "multi" and should not wait behind it. **(C) is recorded so
she has seen it and is NOT recommended** — a phone-only merge idiom is precisely the
fork §3 forbids, and her *"mobile is good for exposing complexity"* ruling points the
other way.

**(A)'S COST, STATED HONESTLY (fix-wave correction — this used to read "costs nothing
new because batch 7 is already building the selection it needs", which was not true).**
Beyond batch 7's selection, (A) needs **the chain composition, the pre-compound
validation, and the compound itself** — and MobileSoul §3's rule is that a Mac brain
the phone needs is **HOISTED, never re-derived**, so (A)'s real cost includes a
`Shared/` hoist of `CarryAllMerge`. That is fenced this round, so it is a future
batch's. **Still small, and still the right recommendation** — a hoist plus a door,
against a gesture the Mac has already proven.

**Riding with it, not a separate finding: the phone ALREADY re-derives
`CarryAllMerge.compose` by hand.** `MobileStructural.swift:284-288` (the pairing +
`MergeJoin.canon` + the `carries` filter) is logic-identical to
`FannedDefaults.swift:71-78`. It is a live instance of the forked-brain class and it is
**not** on `KnownIssuesAndTechDebt.md`'s eight-brain table. It is **pre-existing** — the
phone shipped this shape first at parity C5 and the Mac copied it at 13j, saying so —
so it is not batch 9's to fix; it belongs on that existing row, whose owner (*"the
mobile app project row… any Mac phase touching one of these brains hoists it THEN"*)
already covers it. Recorded here so the hoist (A) needs and the fork that already
exists are known to be **the same piece of work**.

**One thing her question implies that this batch will not decide:** whether *multi*
merge means multi-BLOCK (join three blocks into one) or multi-TAKE (the pairing
ceremony). Everything above reads it as multi-BLOCK, because the ceremony is a ruled
exclusion and because her sentence sits inside a paragraph about the block ⋯. **If she
meant takes, the answer is different and it is 13j's/13u's, not a mobile batch's.**

---

## 6 · DELIVERABLE 6 — THE `commitNow` RIDER · **did not fire**

The rider binds *"if any surface you touch gains its own Commit button"*. **No surface
gained one.** `MobileBlockHistoryController.commitNow` still has exactly ONE caller —
the `Commit Take` row in the block ⋯, a dismissing `UIMenu` row, byte-untouched by this
batch. The row this batch ADDED (`Block History…` on the take card) opens a face; it
writes nothing. Nothing owed. *(Batch 6b recorded the same non-firing for the same
reason, and the latch gap on `commitNow` itself is still that file's recorded debt, not
this batch's.)*

---

## 7 · PINS — what was driven, and the reds

Every door is proven by driving the REAL control: the block ⋯'s and the take card's rows
through `MenuActionHandler`, which reaches a `UIAction`'s installed handler — the exact
closure UIKit runs on a tap (§53 finding 4); the note ⋯'s SwiftUI rows through
`accessibilityActivate()` on a mounted `MobileWriteScreen`; the keyboard bar's ⑂ through
the real `MobileKeyboardBarController`.

**+5 tests, +1 suite** (661/98 → **666/99**), exactly accounted for:
`MobileMenuVocabularyTests` 5 (new suite). Three existing pins were FLIPPED in place
rather than added to (`theTwoDoorsShareOneVocabulary`,
`theCardGrammarRendersChosenPeekingAndTheMenuDoors`,
`theHistoryCopyIsPinnedAndPlatformFree`), each with the flip's reason written into the
pin.

### THE RED-ON-OLD PROOFS — six reverts, each named, each quoted

Every one is a **behavioural revert of PRODUCTION code**, never a test edit. **A
pre-revert copy of each file was taken first and the restore came from that copy, never
`git checkout --`** — batch 6b's own rule, and every file below was also edited by this
batch, which is exactly the condition that rule exists for.

**A1 — `Takes…` put back in the block ⋯** (the row, the constant, and its place on
`rowTitles`):

```
✘ Test theBlockMenuDropsTakesAndTheBarsMiddleActStillOpensTheBrowser() recorded an issue at
  MobileMenuVocabularyTests.swift:101:13: Expectation failed: !((titles → ["takes…",
  "comments…", "callout", "name block…", "commit take", "new block below", "divide block",
  "merge with previous", "archive block", "delete block"]).contains(
  MobileEditorStyle.chromeCase("Takes…") → "takes…") → true)
✘ Test theBlockMenuDropsTakesAndTheBarsMiddleActStillOpensTheBrowser() recorded an issue at
  MobileMenuVocabularyTests.swift:103:13: Expectation failed: !((
  MobileBlockMenuController.rowTitles → ["Takes…", "Comments…", "Callout", "Name Block…",
  "Commit Take", "New Block Below", "Divide Block", "Merge with Previous", "Archive Block",
  "Delete Block"]).contains("Takes…") → true)
✘ Test run with 4 tests in 2 suites failed after 3.410 seconds with 2 issues.
```

…and the standing one-vocabulary pin catches the same revert from the other side, which
is what that pin is for:

```
✘ Test theTwoDoorsShareOneVocabulary() recorded an issue at MobileBlockMenuTests.swift:100:13:
  Expectation failed: (barTitles.first → "takes…") == "comments…"
✘ Test run with 11 tests in 1 suite failed after 1.040 seconds with 1 issue.
```

**A2 — the `Block History…` row removed from the take card's ⋯** (the door is simply not
there to drive, and every downstream assertion follows):

```
✘ Test theTakeCardsMenuOpensBlockHistoryFocusedOnThatTake() recorded an issue at
  MobileMenuVocabularyTests.swift:146:13: Expectation failed: (titles.first → "label take…")
  == (MobileEditorStyle.chromeCase(
✘ …:151:13: Expectation failed: MenuActionHandler.activate(
✘ …:161:13: Expectation failed: !((model.takesBrowser → …).isOpen → true → true)
✘ …:162:13: Expectation failed: (model.blockHistory → …).isOpen → false
✘ …:163:13: Expectation failed: (model.blockHistory.openBlockID → nil) == (seed.blockA → …001")
✘ …:164:13: Expectation failed: (model.blockHistory.focusedVariantID → nil) == (seed.a2 → …007")
✘ …:166:13: Expectation failed: (model.blockHistory.expandedTakes → []) == ([seed.a2] → […007"])
✘ …:175:13: Expectation failed: (savepoints → []) == ([seed.a2] → […007"])
✘ Test theTakeCardsMenuOpensBlockHistoryFocusedOnThatTake() failed after 2.153 seconds with 8 issues.
```

…and the card-grammar pin sees the same absence:

```
✘ Test theCardGrammarRendersChosenPeekingAndTheMenuDoors() recorded an issue at
  MobileTakesBrowserTests.swift:761:13: Expectation failed: (menu.children.compactMap {
  ($0 as? UIAction)?.title } → ["label take…", "lock take", "archive take", "delete take"])
  == (["block history…", "label take…", "lock take",
✘ Test run with 9 tests in 1 suite failed after 0.480 seconds with 1 issue.
```

**A3 — the FOCUS ignored** (`open(blockID:focused:)` reverted to `focusedVariantID =
slot.variantID`). This is the isolating revert: the door still opens, on the right
block, and the face is simply focused on the WRONG take — which is precisely the gain
the move was made for:

```
✘ Test theTakeCardsMenuOpensBlockHistoryFocusedOnThatTake() recorded an issue at
  MobileMenuVocabularyTests.swift:164:13: Expectation failed:
  (model.blockHistory.focusedVariantID → "…0002") == (seed.a2 → "…0007")
✘ …:166:13: Expectation failed: (model.blockHistory.expandedTakes → ["…0002"]) == ([seed.a2] → ["…0007"])
✘ …:175:13: Expectation failed: (savepoints → ["…0002"]) == ([seed.a2] → ["…0007"])
✘ Test theTakeCardsMenuOpensBlockHistoryFocusedOnThatTake() failed after 0.528 seconds with 3 issues.
```

**A4 — `Block History…` put back in the block ⋯** (the "move" half — a copy left behind
is not a move):

```
✘ Test theBlockMenuNoLongerCarriesTheHistoryDoor() recorded an issue at
  MobileMenuVocabularyTests.swift:192:13: Expectation failed:
  !(titles.contains { $0.localizedCaseInsensitiveContains("history") } → <not evaluated>)
✘ Test theHistoryCopyIsPinnedAndPlatformFree() recorded an issue at
  MobileBlockHistoryTests.swift:786:9: Expectation failed:
  !(MobileBlockMenuController.rowTitles.contains { $0.contains("History") } → <not evaluated>)
✘ Test run with 22 tests in 2 suites failed after 3.933 seconds with 2 issues.
```

**A5 — `redoRow` deleted from `MobileNoteActionsSheet`** — the red that gives
deliverable 1's verification teeth. Note the labels it prints: after the undo the stack
has no undo end, so the sheet's ONLY structural row is the redo one, and removing it
leaves the sheet with nothing but the version rows and Delete:

```
✘ Test theNoteActionsSheetRedoRowIsReachableAndActs() recorded an issue at
  MobileMenuVocabularyTests.swift:227:17: Expectation failed: (surface.visibleLabels →
  ["note", "done", "Save a Version", "Versions…", "Delete Note…", "Undid: Delete Block"])
  .contains("Redo Delete Block")
✘ …:229:17: Expectation failed: (surface → …HostedSurface<…MobileWriteScreen>).activate("Redo Delete Block")
✘ …:232:13: Expectation failed: try await storedBlockTexts(db, postID: postID) == ["Keep me."]
✘ Test theNoteActionsSheetRedoRowIsReachableAndActs() failed after 4.941 seconds with 3 issues.
```

**A6 — `openHistory`'s two lines swapped** (the face opened BEFORE the browser closed),
which is §4.6's stranding produced deliberately by the door this batch built:

```
✘ Test theHistoryDoorLeavesThePageEditableAfterwards() recorded an issue at
  MobileMenuVocabularyTests.swift:238:13: Expectation failed: (surface.textView →
  <VariorumMobile.MobileEditorTextView: …>).isEditable → false
✘ Test run with 5 tests in 1 suite failed after 6.217 seconds with 1 issue.
```

**Every revert was undone from its pre-revert copy and the affected suites re-run green**
(74/6 across the six touched suites), then the whole suite (§8).

### A HARNESS TRAP WORTH THE NEXT SESSION'S TIME

`-only-testing:VariorumMobileTests/MobileTakesBrowserTests` runs **21 of the file's 30
tests**: `MobileTakesBrowserTests.swift` declares TWO suites, and the pixel/⑂/edit-menu
cases live in **`MobileTakesBrowserSurfaceTests`**. A revert of A2 first appeared to
leave the card-grammar pin green for exactly this reason. Name both, or run unfiltered.

---

## 8 · COUNTS AND ENVIRONMENT

**Baseline:** mobile **661 / 98 green with 2 known issues** — the ONE documented
diagnostic test (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`,
one `withKnownIssue` block recording two issues); the 6b unit's close.

**This batch's final line, quoted:**

```
✘ Test run with 666 tests in 99 suites passed after 304.709 seconds with 2 known issues.
** TEST SUCCEEDED **
```

**+5 / +1 suite, exactly accounted for** (§7's opening). The **2 known issues are the
same single documented diagnostic test** as the baseline's; no other test records an
issue. **`MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`** —
the known load-flaky pin (KnownIssues, owner 12) — **passed in this run**
(`✔ … passed after 1.058 seconds`), so no isolated re-run was needed.

**One runner death, reported rather than swallowed:** a mid-batch filtered run of
`MobileTakesBrowserTests` died with `IDELaunchReport … Mach error -308 - (ipc/mig)
server died` before executing anything. Re-run immediately, it passed 21/1. This is the
runner-restart class the brief names; nothing was skipped and nothing red was hidden by
it.

**Environment:** worktree `~/dev/variorum-mobile`, branch `mobile`, HEAD `0aa6479` at
start. Own private simulator **`Variorum-batch9`** (iPhone 17 Pro, iOS 26.2 — the only
iOS-26 runtime on this machine; every iPhone 16-series sim here is iOS 18.3 and is not a
valid destination for an iOS-26 deployment target), `ApplicationAccessibilityEnabled`
armed and **read back `1`**; private `-derivedDataPath` under this session's scratchpad;
the simulator **deleted at the end**. `Package.resolved` did **not** drift and nothing
was swept into the commit. No Release build, no install, no push; the real store
untouched; the live Mac app never quit.

**The probe was DELETED.** `ZZProbeSelectionScroll.swift` existed only to produce §4.2's
and §4.6's numbers and is not in the tree or the suite counts.

---

## 9 · PROVISIONALs and recorded calls (for her sitting bundle)

1. **Ask 1 was already built and was NOT rebuilt** — and she could not have seen it,
   because the note ⋯ *itself* is one day newer than her build (§1). If it still reads
   as hard to reach on a current build, that is a placement question, not a missing
   capability.
2. **The take card's row is worded `Block History…`, not `History…`.** The brief
   suggested the shorter word; the longer one is composed from the SHARED
   `BlockHistoryPath.name`, so the two platforms cannot drift, and it is honest about
   what opens — the face is the BLOCK's whole past reached FROM a take, not that take's
   history. A re-word is one shared string.
3. **A GAP BLOCK's history is no longer reachable** (§3). The one road that closed. Her
   call whether the block ⋯ should keep a history row for that case alone.
4. **The ARCHIVED take card's ⋯ did NOT get the row**, with the mechanism at the code
   (`BlockHistoryExpansion` would focus an id `rows()` renders no header for, so the
   face would open with nothing expanded). Her letter says *"each take"*; this reads it
   as the live fan's cards.
5. **Her G2 commit/history adjacency is over.** `Commit Take` stays on the block ⋯ (she
   moved the listing, not the act); the *write-a-moment / see-the-moments* pairing
   survives one grain up on the note ⋯.
6. **The edit menu's flat `Takes…` survived** the block ⋯'s removal, deliberately — her
   reason (proximity to the bar's ⑂) does not reach the SELECTION's own menu.
7. **`Merge with Next` is recommended regardless of the multi-merge shape** (§5) — a
   one-row fix to a real daily gap that has nothing to do with "multi".
8. **The `isEditable` stranding (§4.6) is recorded, not fixed**, and whether any
   pre-batch-9 road reaches it was not established. *(Fix-wave amendment: it now has a
   **committed owner** — the leftover-review-backlog batch, on
   `mobile-round-2-handoff-2026-08-30.md` §7.2 — and its fix's SHAPE is ruled (one
   nesting-aware editability authority, replacing three save/restore pairs). §4.6
   carries the whole ruling. The defect is still unfixed; what changed is that it can
   no longer be lost when this file closes.)*

---

## 10 · Fence, verified before commit

```
git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum \
  "*.xcodeproj" "*.pbxproj"                       →  (empty)
git status --porcelain -- Sources/ App/Variorum/Shared App/Variorum/Variorum \
  "*.xcodeproj" "*.pbxproj"                       →  (empty — nothing untracked there either)
git status --porcelain -- "*Package.resolved"     →  (empty)
```

Zero schema, zero migrations, zero build-config changes, zero `Sources/`, zero
`Shared/`, zero Mac-target lines.

**No `Shared/` residue was added by this batch.** The one thing that WANTED a shared
home — the history row's word — was solved by *composing* `BlockHistoryPath.name`
rather than by minting a literal, so nothing new joins batch 6b's residue list.

---

## 11 · Deliberately not done

- **Anything for deliverable 5 beyond the trace.** The mechanism is not found; §4.5 is
  the experiment that finds it. Building a fix would have been inventing one.
- **A fix for the `isEditable` stranding** (§4.6) — recorded with its measurement; the
  batch's own door is pinned safe.
- **Anything from the merge proposal** (§5) — propose-only by the brief.
- **`Merge with Next`**, even though §5 recommends it: it is a product addition she has
  not ruled, and the brief's scope is her four asks plus the selection defect.
- **The archived-take card's history row** (PROVISIONAL 4).
- **Block multi-select** — batch 7's (PR20), untouched, and §5's shape (A) depends on it.

---

## 12 · For the cold reviewer

**Where to push hardest, in order:**

1. **The gap-block road that closed (§3).** This batch honored *"move"* literally and a
   region of a face lost its only door for one block state. Judge whether the letter
   should have been read as *"move, and keep a fallback"*. The whole reasoning is in
   `MobileBlockHistory.swift`'s header.
2. **`openHistory`'s close-then-open, and the stranding behind it (§4.6).** The ordering
   is pinned (A6), but the pre-existing three-sheet interleave is recorded as latent
   WITHOUT establishing whether any road reaches it. If you can find a road, that is a
   real finding this batch did not close.
3. **Deliverable 5's honesty.** The claim is *"not traced"*. Check §4.3's four
   rule-outs against the quoted numbers — especially the storage-equality one, which is
   what killed the leading hypothesis — and check that §4.4's surviving candidates are
   ranked by evidence rather than by taste. **§4.4's angle arithmetic for S3 is READ
   FROM CODE and its probe sweep was CONFOUNDED**; that is said in the record, and it
   should stay said.
4. **The take card menu's row ORDER.** `Block History…` LEADS. That is a taste call
   made by an implementer; the alternative (last, beside the destructive rows, or
   beside `Label Take…`) is a one-line move.
5. **Whether `Commit Take` should have moved with it** (PROVISIONAL 5). Her letter did
   not say so; the pairing it breaks was her own G2 ruling.

**Reproducing the reds:** every revert in §7 is a two-to-six-line edit described in its
own paragraph. **Take a copy of the file first** — every one of them is a file this
batch also edited.

**Checkable claims:**
- The resting bar's three acts (⑂ is literally the middle):
  `MobileKeyboardBarController.restingActLabels`, `MobileKeyboardBar.swift`.
- The shared face name the row composes: `App/Variorum/Shared/BlockHistoryFace.swift`
  (`BlockHistoryPath.name`).
- The expansion rule the focus feeds: `BlockHistoryExpansion.initiallyExpanded` — note
  it reads `history.takes`, which INCLUDES archived rows, while
  `MobileBlockHistoryController.rows()` sections `activeTakes` only. That asymmetry is
  PROVISIONAL 4's whole mechanism.
- I10 (a live block always has ≥ 1 live active take) is what makes the per-take door a
  complete replacement: `OverallModel.md` §4, `AppSpec.md` §5.
- The takes browser's gap refusal: `MobileTakesBrowserController.open`, `slot.isGap`.
