# Batch 7 — TAKES & BLOCK DOORS, the phone-local half · the implementer's record

**Brief:** `notes/plans/mobile-batch-7-brief.md` (binding).
**Branch:** `mobile` · **base HEAD at dispatch:** `4b58399`.
**Baseline (given by the orchestrator, superseding the brief's read-the-latest
instruction):** mobile **678/99 green with 2 known issues** — 4.5c-phone's unit
close (`mobile-batch-45c-phone-cold-review.md`'s UNIT CLOSED section).

> **WRITTEN AS THE WORK LANDS.** This round has had two session deaths; the
> survival posture is standing practice. Anything marked **PENDING** below is
> resolved before the final message.

---

## 0. PRECONDITION — B45-2's structural fix · **VERIFIED IN THE TREE**

The brief's stop condition. `mobile-batch-45c-phone-record.md` §2 records the
fix landing at `4788a95`; it was confirmed **at the code**, not from the
record:

`App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift:1349`

```swift
if let s = slots.firstIndex(where: { $0.blockID == blockID }) {
    slots[s] = slot
}
```

— the slot write is **BY IDENTITY**, and the comment above it (`:1329-1348`)
names batch 7's reorder door as the caller that walks into that room. The
`i` derived from `index.entries` is no longer used to subscript `slots`.
Three pins ride it in `MobileTakesTests` (the window characterization, the
red-on-old, and the control).

**Verdict: PRESENT. Proceeding.** Deliverable 1's own door is built on the
same discipline one layer up — it never authorizes from the frozen
projection (§1).

---

## 1. Deliverable 1 — REORDER TAKES (PL-10(a))

**STATUS: BUILT + PINNED.** 6 pins; red-on-old RUN and QUOTED (§7, R1/R2).

### The doors

Two rows on each live take card's ⋯ — **Move Take Up** / **Move Take Down**
(`MobileTakesBrowserController.moveUpTitle` / `.moveDownTitle`), driving
`moveTake(variantID:by:)` over the core `reorderTake` op.

**"Up"/"Down" and not the Mac's "earlier"/"later":** #57(e)'s own rule is
that the direction word follows the strip — ◀▶ in the carousel, **▲▼ in the
stack** — and the phone's browser is a vertical scroll of cards in fan order.
The stack is exactly the case the Mac draws ▲▼ for.

### NO DRAG — the call, recorded

The brief's instruction, and the reason is worth keeping: the 13e canvas
jitter rider named a coordinate-space rule any new drag owes, and the phone's
card list is manual-frame views inside an overlay sheet (not a `UICollection
View` with a reorder mode). **A first iOS drag-reorder is its own project**,
not a row in a takes batch. Two menu rows are also the phone-native shape —
#57(d)'s arrows are KEYLESS `.surface` doors on the Mac, and the phone's
equivalent of "the door is on the card you point at" is that card's ⋯.

### The ruled semantics, composed arm for arm (#57)

| ruling | the phone's answer |
|---|---|
| **(a)** a LOCKED take may be moved | the rows render on a locked card; the op's own rule carries it (the lock freezes the BUFFER, not identity metadata) |
| **(b)** stepping is within the ACTIVE fan | `moveTake` filters `Queries.blockFan` to `.active` before stepping — an archived take is neither stepped onto nor over |
| **(c)** no touch, no churn | the op's; nothing here adds any |
| **(d)** keyless | menu rows, no chord (the phone has no chord culture) |
| **(e)** the end **greys rather than vanishing**; a one-take fan draws NO arrows | the row is rendered with `.disabled` at the end it cannot reach, and the PAIR is absent entirely when `cards().count < 2` |
| **(f)** a move relative to itself writes nothing | the op's no-op convention, untouched |

### The Mac's road, matched (`TakesStructureController.moveTake`)

**Flush first, then read the fan FROM THE STORE.** The takes projection is
deliberately frozen while a buffer is dirty, so a projection-read neighbour
is an **enablement hint and never an authorization** — a take that arrived
mid-burst would make the move land beside the wrong card. `canMoveTake(_:by:)`
is explicitly named as the hint half (it reads `cards()`), and `moveTake`
re-decides from the store and **speaks** when it disagrees
(`fanChangedRefusal` / `alreadyFirstRefusal` / `alreadyLastRefusal`).

### No latch, and why (the rider's own criterion)

Every caller is a `UIMenu` row, which **dismisses on the first tap** — the
door cannot fire twice. That is the same test the `commitNow` rider applies,
applied forward. Recorded at the code so a future non-dismissing host knows
it owes the latch. *(The two STRUCTURAL doors below do get one — §2.)*

### Files

`Features/Takes/MobileTakesBrowser.swift` (the door, the vocabulary, the
words) · `Features/Takes/MobileTakesBrowserView.swift` (the rows).

---

## 2. Deliverable 2 — TAKE → BLOCK and TAKES → BLOCKS (PL-10(d))

**STATUS: BUILT + PINNED.** 8 pins; red-on-old RUN and QUOTED (§7, R3/R4).

### The doors

- **`Take to New Block Below`** — a row on each live take card's ⋯, driving
  `takeToBlockBelow(variantID:)` over the core op. **NOT `.destructive`**:
  nothing is destroyed — the take becomes a block and the original is
  ARCHIVED (AR-1) — which is exactly what separates it from `Delete Take`
  two rows below.
- **`All Takes to Blocks`** — the sheet's **actions row**, a chrome button
  directly above the mint footer, driving `takesToBlocks()`.

### Door placement — **PROVISIONAL**, and the reasoning

**The card ⋯'s new order** is the menu's existing grammar continued:
read (`Block History…`) → the card's own identity facts (`Label Take…`, then
its PLACE in the fan, beside the ordinal the meta row already shows) → state
(`Lock`/`Unlock Take`) → **the three ways a take leaves this fan, gentlest
first** (`Take to New Block Below` · `Archive Take` · `Delete Take`).
`Take to New Block Below` sits with the leaving family because it archives
the original.

**`All Takes to Blocks` is block-scoped among take-scoped rows**, which is
why it is chrome and not a card row (the brief: "its footer/actions region —
pick the honest spot"). It gets its **own line above the mint footer** rather
than a fourth word crowding `+ new take · branch this one ⧉ · blank ○`, and
it renders **only when a fan exists** (`canTurnTakesIntoBlocks`, P-2). So the
calm one-take sheet is byte-identical to the one that shipped **and gives up
no card height** — verified in the layout arithmetic: with the row hidden,
`listBottom = footerY - 8` reproduces the shipped `height: max(footerY - 52, 0)`
at `y: 44` exactly.

### The ruled semantics (#58) — COMPOSED, never re-decided

Every one of #58's calls lives in the core ops, which the phone calls
unchanged: the original **ARCHIVED not deleted** (a), a **LOCKED take may be
moved out** (b), the conversion **keeps the take the block is SHOWING** (c),
**blank takes skipped and counted** (d), **archived takes ride nowhere** (f),
callout frame inherited + comments copied (g), label rides / commits do not
(h), the `manual` edge (i), the one-take refusal (j).

**No pre-checks at the door, deliberately** — the Mac's own posture, and the
only honest one over a frozen projection: fan arity/I10, the blank take, the
seal and a locked take are all decided INSIDE the write, and the door speaks
the op's real answer. (`canTurnTakesIntoBlocks` is an enablement hint only;
`noConvertibleTakes` still speaks when every alternate is blank.)

### Structural undo — **VERIFIED, not re-registered**

`Operations+TakeStructure.registerTakeConversions` registers **ONE** entry
per act carrying **inverse AND redo** from do-time pre-images
(`revertStructural` / `reapplyStructural`), for both `takeToBlockBelow` and
`takesToBlocks`. Nothing is registered at the phone's doors — a second
registration would be two entries for one act. Both receipts carry
`action: .undo`, the phone's undo BUTTON (M20).

### The latch — **the `commitNow` rider, applied forward**

`structureLatch` (a `MobileWriteLatch`, separate from `mintLatch` so one
gesture cannot wedge the other) guards both doors. The card ⋯ row dismisses
and could not double-fire, but **`All Takes to Blocks` is a persistent chrome
BUTTON** — the exact non-dismissing host the rider names — and both doors
await a flush before writing, which is a wide window. A door and its twin
with different concurrency rules is the drift class, so the pair latches.

### Receipts — `MobileTakeStructureCopy` (new file), a RECORDED FORK

The Mac's twin (`TakeStructureCopy`) lives in
`App/Variorum/Variorum/Registry/OpsRefusalCopy.swift` — **the Mac target,
which this batch is fenced out of** (#94: the four hoists are deferred to the
post-13u merge). So this is the `MobileCallout` posture: mirror the
SEMANTICS, record the fork, never invent a different promise. **On the
residue list (§8).**

**One difference is not drift but the no-redirect principle:** the Mac's
lines end *"⌥⌘Z undoes it."* This phone has no chord to name — its undo road
is the receipt's own Undo button and the note ⋯ — so the sentences carry the
FACT and the caller carries the door, exactly as
`MobileStructuralController.blockDeletedStatus` does.

### Refusal copy

`emptyTakeCannotBecomeABlock` and `noConvertibleTakes` get the Mac's own
sentences in the phone's table (they had no arm and would have dumped the raw
enum). `lastActiveVariant` gains a **verb-scoped arm** for the take→block
door: I10 through that door means "there is no other take left behind", so
naming `Delete Block` (the delete door's answer) would be wrong — it names
`Divide Block`, **composed from
`MobileBlockMenuController.divideTitle`** so a rename reaches the sentence,
and it names the ⋯ menu rather than a Mac chord.

### Files

`Features/Takes/MobileTakesBrowser.swift` · `.../MobileTakesBrowserView.swift`
· **new** `Features/Takes/MobileTakeStructureCopy.swift`.

---

## 3. Deliverable 4 — CALLOUT SWATCHES + A REAL EMOJI ROAD (PR19)

**STATUS: BUILT + PINNED.** 3 pins + the EXTENDED drift pin; red-on-old RUN
and QUOTED (§7, R5/R6).

### The swatches

`MobileCallout.swatchImage(for:dark:size:)` — the Mac's 13e E1
`CalloutMenu.swatchImage`, phone-imaged, and it composes
`MobileCallout.color(_:)`: **the same resolution the block's own frame uses**,
so the chip is a PREVIEW and never a second source of truth, and the stored
value is still the **NAME** (AppSpec §7's R1). The FIVE colour rows in
`MobileBlockMenuController.calloutSubmenu` now carry it as their `UIAction`
image.

Two details carried across deliberately:
- **`.withRenderingMode(.alwaysOriginal)`** is the exact twin of the Mac's
  `isTemplate = false` — a template image is recoloured by UIKit to the
  menu's tint, which is the one thing a colour swatch must not be.
- **the word stays beside the chip** — the Mac's reason, which binds here
  twice over: a swatch alone would be the one control in the app that cannot
  be read aloud (R93; MobileSoul §5.6), and **the words are what the drift
  pin compares**.

**ONE VOCABULARY, UNDISTURBED:** no row was added — an image was hung on the
FIVE that existed — so `MobileBlockMenuController.calloutRowTitles` and its drift
pin against `CalloutMenu.rowTitles` are **unchanged by this batch**. The pin
is EXTENDED (never weakened) with a composition assertion that the colour
rows carry swatches and the non-colour rows do not — the Mac's own `swatch`
nil-ness rule.

### The emoji road — **PROVISIONAL**, with its fallback structural

The Mac's answer was `orderFrontCharacterPalette`; iOS has no character
palette, and the place every iPhone user already knows is the 🙂 key on their
own keyboard. So the phone's road **opens that keyboard**:
`MobileEmojiTextField` overrides `textInputMode` to the emoji input mode
(`UITextInputMode.activeInputModes` + `primaryLanguage` — public API).

**The fallback is structural, not promised:** where the user has no emoji
keyboard enabled, the override returns `super.textInputMode` — the ordinary
keyboard, i.e. exactly the prompt that shipped. There is no arm that can
fail, only one that upgrades. And `MobileBlockMenuController.promptForEmoji`
is a **separate seam that falls back to `promptForText` when nothing
installed one**, so every harness injecting only `promptForText` keeps
driving this door unchanged.

**The host is an owned sheet (`MobileEmojiPromptController`), not the alert
its siblings use — the divergence is the row's whole point and is recorded
as PROVISIONAL.** `UIAlertController` hands out its own `UITextField` and
there is no public way to replace it or name its input mode, and the emoji
keyboard needs a field we own. The two roads that keep the alert are both
worse: overlaying our field on the alert's private view hierarchy is brittle
across OS versions, and a hand-rolled emoji grid as an `inputView` would
invent a curated glyph list the system already has. The owned sheet is public
API only, matches the phone's sheet grammar, and — a real gain — **its
buttons ARE drivable in process**, which a `UIAlertController`'s measurably
are not (`MobileSurfaceDriver`'s own recorded finding).

Semantics travel with the chrome, byte-for-byte: **cancel → nil (nothing
happens); Set → the text, and EMPTY is a real answer meaning "no glyph"**
(the Mac `CalloutMenu.promptEmoji` rule, which `MobileCallout.apply` honours
by trimming). The completion fires **exactly once on every road out**,
swipe-to-dismiss included.

**The rule is a pure function on purpose:** `UITextInputMode` cannot be
constructed in a test, so the selection rule is lifted into
`MobileEmojiKeyboard.emojiMode(in:primaryLanguage:)`, generic over anything
that can name a language — that is the half where a typo would silently
disable the whole feature, and it is pinned against fakes. The override is
then two lines that cannot be wrong in an interesting way.

### Files

`Features/Write/MobileCallout.swift` · `Features/Write/MobileBlockMenu.swift`
· **new** `Features/Write/MobileEmojiField.swift` ·
`Features/Write/MobileEditorViewModel.swift` (the seam's plumbing).

---

## 4. Deliverable 5 — BLOCK MULTI-SELECT (PR20)

**STATUS: BUILT + PINNED.** 8 pins, two red-on-old runs quoted (§7).

### The shape

- **`MobileBlockSelection`** (new) — the pure rule: `picked: Set<String>`,
  `toggle`, `clear`, `prune(to:)`, `inOrder(_:)`. **P1's letter: ids, never
  text copies**; session-only, never persisted or projected.
- **Host: the blocks sheet's `in the note` segment** (`MobileBlockListSheet`
  / `MobileBlockListModel`), where the subject already IS this note's blocks.
- **Entry: a `Select` chrome button** beside the sheet's Done, which swaps to
  `Done` while picking. **PROVISIONAL.**
- **Tap-to-toggle** with a visible mark (`◉`/`○`) plus a soft accent wash and
  the `.isSelected` trait; the row's tap jumps at rest and toggles while
  picking.
- **`Delete N Blocks…`** in the banner → ONE confirm → the act.

### The entry door — PROVISIONAL, and the reasoning

The brief offered a block ⋯ row or a long-press. **A long-press is
undrivable in process** (`MobileSurfaceDriver`'s measured finding: a
`.contextMenu` row's accessibility tree comes back EMPTY), which alone
decides it against a destructive gesture's only entrance. And a ⋯ row would
be a **second door onto one surface, one inch from the first** — the shape
batch 9 retired when her letter removed `Takes…` from the block ⋯. So the
door is chrome on the surface that already holds the subject. ONE door.

### The act — COMPOSED, never a second delete road

`onDeleteBlocks` is injected by the HOST (`MobileWriteView`) rather than
called from the sheet: that screen composes the block list and the structural
controller and is the only place allowed to know they meet (CLAUDE.md's
composition rule — a call from the list into `model.structural` would be
feature-to-feature).

The road is **`MobileStructuralController.deleteWholeBlockRun`, which already
exists** and already carries every promise: `UndoStack.withCompound(label:
"Delete Blocks")` — **ONE compound undo entry over every picked block**
(#59(g)) — plus the flight latch, the flush-first contract, the caret
landing, the stranded-originals note, and the receipt with its Undo action.
A second road would be a second promise.

### The confirm — **IN-DOCTRINE, not a divergence from #59(i)**

The Mac ruled **NO** prompt for its multi-delete. **Her R13 ruling on THIS
phone drew the line that governs here, and drew it explicitly:** *the ⋯
menu's single-block door still asks, because that is a menu row and asking
there costs a tap she already spent; **this road is a keystroke**.* The Mac's
road IS a keystroke (⌘-click, then ⌫ in the editor). **This road is a
deliberate button press in a sheet** — the menu-row class, where this phone
already confirms (`MobileBlockMenuController.confirmDelete`). Same line,
other side. The `…` in the verb is the promise.

The confirm's detail **composes the single-block confirm's own road phrase**
(`MobileNoteTrayModel.putBackRoadPhrase` + `TrashWindow.days`), so the two
delete doors cannot promise different roads back, and it names **no chord**.

### The `BlockSelection` FORK, declared

The Mac's `BlockSelection` is in `App/Variorum/Variorum/Registry/`, which
this batch is fenced out of (#94). So this is a recorded fork — and
deliberately a **STRICT SUBSET**, because two of the Mac's members answer
questions the phone does not have:

- **no `extend(to:in:)`** — ⌘⇧-click's range has no phone twin (no chords).
- **no `isContiguousRun`** — that is MERGE's precondition, and **Merge
  Selected is deliberately NOT BUILT** (below). Shipping the rule with no act
  would be machinery guarding nothing.

A later hoist must bring the Mac's members back **with the acts that need
them**, never merely to match a shape. On the residue list (§8).

### MERGE SELECTED — **deliberately NOT BUILT**

Batch 9's proposal (A) recommends it, but it is **PROPOSE-ONLY and awaits her
ruling**. The absence is **pinned over a populated surface**
(`thereIsNoMergeSelectedDoorAndTheAbsenceIsRuled`: two ADJACENT blocks
picked — the exact shape a merge door would light up for — the delete door
present, no merge anywhere), so a later batch adds it by DECISION rather than
discovering the gap.

### Files

**new** `Features/Write/MobileBlockSelection.swift` ·
`Features/Write/MobileBlockList.swift` (model + copy + face) ·
`Features/Write/MobileWriteView.swift` (the host's injection).

---

## 5. Deliverable 3 — M23 ≡ R15, COPY FOLLOWS THE SCREEN

**STATUS: BUILT + PINNED, with ONE recorded corner that is a fence
collision.** 3 pins, red-on-old quoted (§7).

### The rule, in its ruled shape

`MobileEditorViewModel.displayedTextByBlock` **asks the surface what it is
displaying** — §31's exact wording — and there is no derivation in it to get
wrong: `slots` IS the display, because `MobileTakesController.overlay(_:)`
swaps a peeked slot's variant and text **before the VM ever sees the
projection**, and a lens activation drives that same primitive
(`peek(blockID:to:)`). Text resolves ledger-first, the overlay's own rule.

**`takes.peeks.isEmpty` is the surface's own cheap, exact answer to "is
anything on screen other than the store's chosen"** — so with nothing peeked
the map is EMPTY and `MobileNoteClipboard.markdown` takes
`Queries.exportPost` **verbatim**. "Byte-identical to today" is therefore
guaranteed by *which function runs*, not by two projections happening to
agree — and that is pinned directly.

### ⚠️ THE ONE CORNER — a fence collision, recorded with its one-word fix

**A note carrying a CALLOUT FRAME takes the stored road even while
something is peeked.** `exportPost` maps a callout block to a blockquote
through **`Queries.exportMapped`, which is `internal` to VariorumCore** — so
this app cannot ask for "this text, mapped for that frame", and
re-implementing the mapper here would **FORK A CORE BRAIN**, which MobileSoul
§3 forbids outright.

The alternative I rejected: substituting only the unframed blocks would emit
a document whose framed blocks **silently lose their `> `** — a regression
introduced to half-satisfy a ruling. The honest fallback is the shipped
behaviour.

> **⚠️ THIS GRADING WAS INCOMPLETE, AND THE FIX WAVE CORRECTED IT** (cold
> review MAJOR 1, accepted; the fix is in the review file's FIX WAVE
> RESULTS §1). The paragraph above weighs "framed blocks lose their `> `"
> against "the shipped behaviour" and **never states its own side's cost in
> her terms**, which is this: the copy carries **a different take's
> paragraphs than the screen shows, for the whole note, with nothing
> marking it.** The two costs are not symmetrical —
>
> | road | what she gets | detectable? |
> |---|---|---|
> | shipped (stored road) | a **different take's paragraphs** | **NO** — the prose reads fine |
> | rejected (displayed road) | the right paragraphs, minus `> ` and the emoji | **YES** — visible in the pasted text |
>
> — and this batch is what TAUGHT her the promise ("copy follows the
> screen") that the silence then breaks, on exactly the notes that carry
> callouts. **The fallback CHOICE stands** (MobileSoul §3 forbids forking
> the mapper, and `exportMapped` really is `internal`); what was wrong was
> the silence. The fix wave gives the fallback its own `Outcome` case and
> sentence, so the one outcome that cannot be seen in the pasted text is
> the one that is said out loud. The one-word cure now also has a durable
> owner — the seat handoff §4's #94 deferral list, not only this file.

**The fix is ONE WORD — `public` on `Queries.exportMapped`, zero behaviour
change — and it is a `Sources/` edit this batch is fenced out of.** The
corner needs a peek-or-lens AND a callout **in the same note** to be
reachable. It is **pinned as documented behaviour**
(`aCalloutNoteKeepsTheStoredRoadEvenWhilePeeking`, whose docstring names the
expectation that FLIPS when the word lands), so it announces itself instead
of passing quietly. **Owner on the residue list (§8).**

### Files

`Features/Write/MobileNoteClipboard.swift` ·
`Features/Write/MobileEditorViewModel.swift`.

---

## 6. Deliverable 6 — THE `commitNow` RIDER · **it did NOT fire, and the
criterion was applied FORWARD**

**`MobileBlockHistory.commitNow` is untouched and still has exactly ONE
caller** — the block ⋯'s `Commit Take` `UIAction`
(`MobileBlockMenu.swift:196`), a `UIMenu` row that dismisses on the first
tap. Nothing this batch built gives it a second caller or a non-dismissing
host. **So the rider's literal answer is: nothing did.** Its latch gap
remains that file's recorded debt.

**But the rider's CRITERION governed two of this batch's own doors**, and
recording only the literal answer would have been the thinner reading:

| new write door | host | latch? |
|---|---|---|
| `moveTake` (×2 rows) | `UIMenu` row — dismisses | **no**, and the reason is at the code |
| `takeToBlockBelow` | `UIMenu` row — dismisses | **YES** (`structureLatch`) |
| `takesToBlocks` | **persistent chrome `UIButton`** | **YES** (`structureLatch`) |
| bulk block delete | persistent banner `Button` | **YES** — inherited: `deleteWholeBlockRun`'s `structuralInFlight` |

`takesToBlocks` is the exact non-dismissing host the rider names, and both
structural doors await a flush before writing (a wide window), so **the pair
latches rather than only the one that needs it** — a door and its twin with
different concurrency rules is the drift class. `moveTake`'s no-latch is
recorded at the code so a future non-dismissing host knows it owes one.

---

## 7. RED-ON-OLD — every revert RUN, output QUOTED

Nine behavioural reverts, applied to **production** files (never tests),
restored from `b7-prerevert/` and **`diff`-verified byte-identical** (§8).
**Two of them exposed HOLLOW pins, which are recorded as findings rather
than quietly fixed** — the hallucination guard working in the direction it
was written for.

### R1 · R2 · R4 — the reorder door and the take→block refusal

Applied together (distinct pins, distinct assertions): the anchor direction
swapped; `attributes:` dropped from the two move rows; the verb-scoped
`lastActiveVariant` arm deleted.

```
✘ aTakeStepsOnePlaceInTheFanAndTheStoreFollows() … Expectation failed: (model.statusMessage → "This take is already last in the fan.") == (MobileTakesBrowserController.movedDownNote → "Take moved down.")
✘ … (model.takesBrowser.cards().map(\.variantID) → ["…002", "…007", "…008"]) == ([seed.a2, seed.a1, seed.a3] → ["…007", "…002", "…008"])
✘ theMoveRowsGreyAtTheEndsAndAreAbsentOnAOneTakeFan() … Expectation failed: try row(first, up).attributes.contains(.disabled)
✘ … Expectation failed: try row(last, down).attributes.contains(.disabled)
✘ aLockedTakeMovesAndAnArchivedOneIsSteppedNeitherOntoNorOver() … (model.statusMessage → "This take is already first in the fan.") == (…movedUpNote → "Take moved up.")
✘ movingTheOnlyTakeOutRefusesAndNamesDivideOnThisPhone() … Expectation failed: (spoken → "This is the block's only take — a block always keeps one. To remove it all, use Delete Block in the ⋯ menu.").contains(MobileBlockMenuController.divideTitle → "Divide Block")
```

**The last line is the finding in her own words:** without the verb-scoped
arm the door points a "there is no other take left behind" refusal at
**Delete Block**, which is the wrong act entirely.

### R3 — the structural latch · **THE FIRST PIN WAS HOLLOW**

The pin as first written asserted the STORE, on the guess that a second
flight would mint a second run of blocks. **It PASSED with the latch
removed.** Traced: the op is not idempotent by accident but by validation —
the second flight finds every alternate already archived and throws
`noConvertibleTakes`, so the rows are right either way.

The real difference is **what she reads**. Re-aimed at the receipt, the same
revert reds:

```
✘ aSecondPressWhileTheConversionIsInFlightIsNotReportedAsARefusal() … Expectation failed: (model.statusMessage → "This block has no other takes with text in them — nothing to turn into blocks.") == (MobileTakeStructureCopy.convertedNote(
✘ … Expectation failed: (model.statusMessage?.contains("no other takes") → true) != true
✘ … Expectation failed: (model.statusAction → nil) == .undo
```

The second flight's refusal **overwrites the receipt she earned** — about a
conversion that just succeeded. That is the latch's whole documented
contract: *"`nil` means this gesture was already in flight, which is not a
refusal and must never be reported as one."* The store assertion is kept as
the control that says so.

### R5 · R6 — the swatches and the emoji seam's fallback

```
✘ theTwoDoorsShareOneVocabulary() … Expectation failed: (row.image → nil) != nil        [×5, one per colour row]
✘ theEmojiRowFallsBackToTheTextPromptAndKeepsTheMacsSemantics() … Expectation failed: (asked → []) == ([MobileBlockMenuController.emojiPromptTitle] → ["Callout Emoji"])
✘ … Expectation failed: try await storedPresentation(db, blockID: seed.blockA)
```

Without the fallback arm the prompt is **never asked** and the glyph never
lands.

### R7 — the selection's prune · **THE SECOND HOLLOW PIN**

As first written it asserted `pickedInOrder`, which **passed with the prune
removed**: `inOrder` already filters to blocks the note's order holds, so the
ACT could never address a ghost either way. What the prune protects is what
she **reads** — `selection.count` feeds the banner AND the delete verb.
Re-aimed:

```
✘ aBlockDeletedElsewhereDropsOutOfThePicksAndOutOfTheCount() … Expectation failed: (model.selection.count → 2) == 1
✘ … Expectation failed: (MobileBlockSelectionCopy.deleteVerb(picked: model.selection.count) → "Delete 2 Blocks…") == "Delete Block…"
✘ … Expectation failed: (MobileBlockSelectionCopy.bannerLabel(picked: model.selection.count) → "2 blocks picked") == "1 block picked"
```

The door would say **"Delete 2 Blocks…"** over a gesture that can only reach
one — the Mac's own stated reason for the rule, verbatim: *"the count in the
banner would be a lie."* The `pickedInOrder` assertion is kept as the control.

> **THIS ACCOUNT WAS INCOMPLETE — corrected at the fix wave** (cold review
> NIT 2, accepted). The revert reds **two tests and four assertions**, not
> the three quoted above: the fourth is
> `pickingTwoBlocksAndConfirmingDeletesExactlyThoseTwo`'s
> `!list.isSelecting`, reproduced by the reviewer as
> `MobileBlockListTests.swift:349:17: Expectation failed: !((list → …).isSelecting → true → true)`
> — i.e. picking mode never turned off after a SUCCESSFUL delete, because
> `prune` was also the mode's exit mechanism. The round's discipline is
> that a revert's output is quoted AS RUN; this one was quoted partially,
> and the direction of the error was in the batch's favour (the pin was
> stronger than claimed).
>
> **And that coupling is now gone ON PURPOSE** (MINOR 3, §11-4 above): the
> exit follows the act's returned outcome rather than the re-read, so from
> the fix wave on this same revert reds **three assertions in one test** —
> exactly what the original paragraph said, for a different reason. Written
> down so a later session meets a recorded decision instead of what looks
> like a regression.

### R8 — the row's tap always jumps

```
✘ pickingTwoBlocksAndConfirmingDeletesExactlyThoseTwo() … Expectation failed: (list.selection.count → 0) == 2
✘ … Expectation failed: (surface).activate(verb → "Delete 2 Blocks…")
✘ … Expectation failed: (surface).presentedAlert → nil → nil
✘ thereIsNoMergeSelectedDoorAndTheAbsenceIsRuled() … (labels → ["blocks", "done picking", "done", "tap blocks to pick them.", "alpha here.", "beta here.", "gamma here.", "delta here."]).contains("delete 2 blocks…")
```

The last line quotes the REAL mounted tree: the sheet is in picking mode with
every row on screen and **no pick ever forms**, so the act never appears.

### R9 — M23: the copy door stops asking the surface

`displayedTextByBlock` forced to `[:]` (its pre-batch-7 behaviour):

```
✘ aPeekedTakeIsWhatTheCopyCarries() … Expectation failed: (board.pasteboard.string → "The chosen one.
✘ Test run with 10 tests in 1 suite failed after 0.630 seconds with 1 issue.
```

**EXACTLY ONE of the suite's ten pins red** — the other nine, including
`aFannedBlockCopiesTheChosenTake`, the no-divergence control and the callout
corner, stayed green. **That contrast IS the finding:** nothing about the
ordinary copy road moved.

---

## 8. Fences, hygiene, residue

Verified with the tree in its final shape:

```
$ git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"
(empty)
$ git diff -- '*.swift' | grep -c planVisibleTakeEdit
0
```

- **ZERO** changes under `Sources/`, `App/Variorum/Shared/`,
  `App/Variorum/Variorum/` (Mac target), `EditorBrain/`, schema, build
  configs. Shared and core types were READ and CALLED, never edited.
- **`planVisibleTakeEdit`: ZERO Swift hits**, and no trace ran through it.
- `Package.resolved` untouched; no `.bak-*` files; the real store never
  touched; no Release build, no install, no push.
- Pre-revert copies in a **uniquely named** `b7-prerevert/` (the shared
  scratchpad holds STALE `prerevert/`, `45c-prerevert/`, `fixwave-prerevert/`
  dirs from other batches — restoring from those would clobber this batch's
  work). Every restore `diff`-verified: **five files, five IDENTICAL**.

### Files touched (8 source + 4 test + this record)

| file | deliverable |
|---|---|
| `Features/Takes/MobileTakesBrowser.swift` | 1, 2, 6 |
| `Features/Takes/MobileTakesBrowserView.swift` | 1, 2 |
| **new** `Features/Takes/MobileTakeStructureCopy.swift` | 2 |
| `Features/Write/MobileCallout.swift` | 4 |
| `Features/Write/MobileBlockMenu.swift` | 2 (composed title), 4 |
| **new** `Features/Write/MobileEmojiField.swift` | 4 |
| **new** `Features/Write/MobileBlockSelection.swift` | 5 |
| `Features/Write/MobileBlockList.swift` | 5 |
| `Features/Write/MobileWriteView.swift` | 5 |
| `Features/Write/MobileEditorViewModel.swift` | 3, 4 (seam plumbing) |
| `Features/Write/MobileNoteClipboard.swift` | 3 |
| **new** `VariorumMobileTests/MobileTakeStructureTests.swift` | 1, 2 (14 pins) |
| `VariorumMobileTests/MobileBlockListTests.swift` | 5 (8 pins) |
| `VariorumMobileTests/MobileBlockMenuTests.swift` | 4 (3 pins + the extended drift pin) |
| `VariorumMobileTests/MobileNoteClipboardTests.swift` | 3 (3 pins) |
| `VariorumMobileTests/MobileTakesBrowserTests.swift` | the SANCTIONED drift-pin flip |

### The two SANCTIONED pin flips, declared

1. **`theCardGrammarRendersChosenPeekingAndTheMenuDoors`** — the card ⋯ gains
   three rows by design, so its literal list moved to the CONTROLLER
   (`cardRowTitles`), which the batch-7 suite pins **by value**. The pin is
   now COMPOSED from that vocabulary, so this door and the word list cannot
   drift apart again — the `historyTitle` lesson applied to the whole row set.
   **Extended, not weakened.**
2. **`theTwoDoorsShareOneVocabulary`** — the callout drift pin's WORDS are
   untouched (no row was added; an image was hung on the FIVE that existed); the
   pin GAINS a composition assertion that colour rows carry swatches and
   non-colour rows do not, plus the `.alwaysOriginal` claim.

### A REAL DEFECT THIS BATCH CAUGHT IN ITSELF, at the full suite

`theKeyboardNeverStrandsTheCardListFooterOrLiveCard` — the A1 gate defect's
own pin — **went red**: the new actions row spent 30 pt of card-list height,
and with the keyboard up the unoccluded band is barely taller than one live
card, so the live card's top was cut off. **That is the class of her original
report** (*"i could make a new take but i couldn't scroll down through the
list of takes to edit it better"*).

**Fixed at the mechanism, not at the pin:** the actions row now stands down
while a card is LIVE. The mint footer stays because minting is the ADJACENT
act; converting the whole fan is not something she is doing mid-keystroke —
so while a take is being written, the sheet's geometry is byte-identical to
the one that shipped. The pin rode unmodified.

### RESIDUE — carried forward with owners

| item | owner |
|---|---|
| **`Queries.exportMapped` is `internal`**, so the phone's copy cannot map a callout for a displayed take — M23's one corner (§5), pinned as documented behaviour. One-word fix, `Sources/`-fenced. | the post-13u merge session (the #94 hoist class — it is the same fence, and the same conversation) |
| **`MobileTakeStructureCopy`** forks the Mac's `TakeStructureCopy` | the KnownIssues forked-brains row — a Mac-app-local copy home, exactly like the five deletion-copy homes batch 4 hoisted |
| **`MobileBlockSelectionCopy`** forks the Mac's `BlockSelectionCopy` | same row |
| **`MobileBlockSelection`** forks the Mac's `BlockSelection` (already listed there) — this batch adds that a phone SUBSET now exists, and that a hoist must bring `extend`/`isContiguousRun` back **with the acts that need them** | same row (already present) |
| **`MobileCallout`** — the recorded byte-copy of the Mac's `CalloutPalette`, now also carrying `swatchImage` beside the Mac's `CalloutMenu.swatchImage` | same row (already present) |
| **Merge Selected** — propose-only, awaiting her ruling; absence pinned | her sitting; batch 9's proposal (A) |

---

## 9. THE #94 DEFERRALS — build nothing, inherit a DECISION

**This section IS the deliverable.** Her ruling, verbatim: *"i agree that
those four hoists should just be deferred to the post 13u merge - seems
cleaner that way."*

- **PR21 REPLACE is NOT BUILT, and must NEVER be built without the
  `FindReplaceGate` hoist.** Nothing in this batch touches find or replace.
- **COPY-ALL-TAKES is NOT BUILT** — it needs the `TakeClipboard` composition
  hoist. `Queries.blockTakes` (core) is ready; what is missing is the Mac's
  composition half, which lives in the fenced target. **Note the phone's
  pasteboard writer is already the ONE place prose leaves this app**
  (`MobileClipboard`), and its header already says PL-10(c) *"composes it
  rather than opening a second writer"* — so the hoist lands into a home that
  is waiting for it.

**So the post-merge session inherits a decision, not a discovery.** Neither
is missing because nobody looked: both are held because their brains sit
behind the same fence, and the merge is where that fence comes down. What
that session should do first is read this section beside PL-10(c) and the
KnownIssues forked-brains row, which now names every copy home this batch
had to fork for the same reason.

---

## 10. Suite

**Baseline: 678/99 green with 2 known issues** (4.5c-phone's unit close).

**FULL SUITE — RUN, GREEN. The exact final line:**

```
✘ Test run with 706 tests in 102 suites passed after 332.268 seconds with 2 known issues.
** TEST SUCCEEDED **
```

*(Swift Testing marks a run carrying known issues with `✘` while reporting it
`passed`; `** TEST SUCCEEDED **` is the verdict.)*

| | baseline | now | delta |
|---|---|---|---|
| tests | 678 | **706** | **+28 — exactly this batch's pins** (6 reorder · 8 take↔block · 8 selection · 3 callout/emoji · 3 copy) |
| suites | 99 | **102** | +3 — `MobileTakeReorderTests`, `MobileTakeToBlockTests`, `MobileBlockSelectionTests` |
| known issues | 2 | 2 | 0 — the same documented diagnostic (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, which records issues BY DESIGN) |

### Both watched-for conditions, reported

- **The load-flaky perf pin did NOT red.** `MobilePerfWalkTests
  .typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k` — `✔ … passed after
  1.210 seconds`. No isolated re-run needed.
- **A RUNNER DEATH OCCURRED and is reported rather than hidden.** The
  second full-suite run died mid-flight:

  ```
  Restarting after unexpected exit, crash, or test timeout; summary will include totals from previous launches.
  ```

  It died at `anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAn
  AbsentDoor` — **the known diagnostic test, which tears the
  accessibility server down by design**, i.e. the same region that carries
  the 2 known issues. The FIRST run reached that test and passed it with its
  2 known issues; the THIRD run (quoted above) passed it and completed with
  **zero `Restarting after` lines**. Recorded as an observation of the
  round's known runner flakiness under load, not as a finding about this
  batch's code.

### Environment

| what | value |
|---|---|
| simulator | `VB7-17-26` — iPhone 17, **iOS 26.2 (23C54)**, created fresh for this batch |
*[removed for publication]*
| accessibility | `ApplicationAccessibilityEnabled` written and **read back `1`** |
| derived data | private `-derivedDataPath` at `<scratchpad>/b7-dd` |
*[removed for publication]*

*(The 16-series simulators on this machine carry iOS 18.3 only and are
INVALID for this app.)*

---

## 11. For the cold reviewer

**Where to look hardest, in the order I would look:**

1. **M23's callout corner (§5).** I chose the stored road over a document
   whose framed blocks silently lose their `> `. If you think the other
   trade is right — or that the phone may legitimately re-derive a ten-line
   text transform rather than fork "a brain" — say so; the whole item turns
   on where that line sits, and I drew it at MobileSoul §3's letter.
2. **The two HOLLOW pins (§7, R3 and R7).** Both were re-aimed at what the
   mechanism actually changes. Check that the NEW assertions are the real
   consequence and not a second guess — particularly R3, where the store is
   correct either way and the whole claim now rides on the status line.
3. **The actions row's stand-down while a card is live** (§8's defect). I
   justified it as a rule (typing room first) rather than a geometry patch.
   If the honest fix is instead to shrink the live card or scroll
   differently, that is a real alternative I did not take.
4. **`deletePicked`'s success/refusal discrimination.** It re-reads the
   listing and treats an empty selection as "landed". The compound is
   all-or-nothing, which is what makes that sound — but it is inference from
   a state, not a returned outcome. A `Bool` from `onDeleteBlocks` would be
   stronger; I kept the composition thin instead.

   > **ANSWERED, and the `Bool` was taken** (cold review MINOR 3, accepted;
   > FIX WAVE RESULTS §5). The traced hole: the discrimination rode on
   > `refresh()` reaching `adopt` — the only place `prune` runs — and
   > `refresh()` **swallows a read failure** (`catch { status = … }`, rows
   > stay stale). So a read that threw immediately after a delete that
   > SUCCEEDED left the selection un-pruned, the app read its own success
   > as a refusal, picking mode stayed on and `Delete N Blocks…` stayed
   > armed over blocks that were already gone. `deleteWholeBlockRun` now
   > returns `Bool`, `onDeleteBlocks` is `([String]) async -> Bool`, and
   > the exit follows the ACT's answer; the listing is still re-read, that
   > discipline is unchanged. **Knock-on, recorded in §7 below:** this
   > deliberately severs the coupling that produced R7's fourth red.
5. **The reorder door's enablement/authorization split.** `canMoveTake` reads
   the frozen projection and `moveTake` re-decides from the store. Check the
   two cannot disagree in a way that leaves a row enabled over a fan that
   moved — I believe the refusal covers it, and it is pinned, but the
   projection-vs-store seam is this round's recurring room.
6. **`MobileEmojiPromptController`.** It is a new presented surface where
   every sibling prompt is a `UIAlertController`. The chrome divergence is
   deliberate and argued (§3), but it is the batch's largest new UI surface
   and it has no pin driving its buttons — only the seam beneath it does.
7. **The `Take to New Block Below` row is offered on a one-take fan** (the
   Mac's posture: let the op validate). Confirm that reads as honest rather
   than as a door that mostly refuses — the alternative is a P-2 hide, which
   would mean authorizing from the frozen projection.

**What I deliberately did NOT do:** PR21 replace, copy-all-takes, Merge
Selected (§9 and §4), and anything under `Sources/`, `App/Variorum/Shared/`,
`App/Variorum/Variorum/` or `EditorBrain/`.
