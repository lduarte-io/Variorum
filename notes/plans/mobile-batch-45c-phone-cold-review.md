# Batch 4.5c-PHONE — the COLD REVIEW

**Reviewer:** a cold reviewer with zero implementation context (R28 dispatch).
**Date:** 2026-08-31.
**Target:** `61a6e8d..4788a95` on branch `mobile`, in the `~/dev/variorum-mobile`
worktree.

> **Note on the range:** the prompt named it as two commits; it is **three**.
> `1efbf0e` ("Batch 7's brief lands ahead of need") sits between the base and
> `df97677` and is the ORCHESTRATOR's unrelated work — `notes/plans/mobile-batch-7-brief.md`,
> 125 lines, nothing else. Everything below concerns `df97677` (the survival
> record) and `4788a95` (the work + the record's completion).

## What I ran

| act | result |
|---|---|
*[removed for publication]*
| `ApplicationAccessibilityEnabled` | written and **read back `1`** |
| derived data | private `-derivedDataPath` at `<scratchpad>/dd-coldreview` |
| **FULL MOBILE SUITE** (from `App/Variorum/`) | `✘ Test run with 675 tests in 99 suites passed after 322.032 seconds with 2 known issues.` / `** TEST SUCCEEDED **` |
| runner restarts | **ZERO** (`grep -c "Restarting after unexpected exit"` = 0) |
| the load-flaky perf pin | `✔ typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k() passed after 1.190 seconds` — **did not red; no isolated re-run needed** |
| the 2 known issues | the same documented diagnostic, `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, which records issues BY DESIGN |
| four temporary PROBE tests (mine, in `ZZColdReviewProbes.swift`) | run, quoted below, **file deleted**; `git status --porcelain` empty afterwards |
| ONE production revert (mine, **R-CR1** — the entry guard alone) | run, quoted below, **restored from my own `45c-coldreview/` copy and verified: `diff` clean, sha256 `e203a5ae…` identical** |

**Hygiene.** The stale `prerevert/` directory from another batch was left
untouched; my copies live in `45c-coldreview/`. `Package.resolved` untouched.
No Release build, no install, no commit, no push. The real store was never
touched; the live Mac app was never quit. Tree left byte-identical apart from
this file.

## Severity counts

**BLOCKER 0 · MAJOR 2 · MINOR 4 · NIT 4**

---

# FINDINGS

## MAJOR 1 — the entry guard refuses the pen from a STALE `noteIsGone`, so a note Put back from the Trash can leave its own surface silently dead

**File:** `App/Variorum/VariorumMobile/Features/Shell/MobileLivenessAuthority.swift:163–174`
(the `guard !editor.noteIsGone else { standDownEveryone(); return }` arm).
**Label: MEASURED** (red/green pair below).

### Mechanism, traced then measured

`noteIsGone` has exactly **two** writers: `adoptHeader` (fed by
`observeContainerHeader`, by `loadOnce`, and by `confirmNoteStillLive`), and
nothing else. The batch's own justification for adding the post-suspension
authoritative read is that the observation's delivery latency is real and *"a
tab tap can land inside it"* (`MobileEditorViewModel.swift:346–349`;
`MobileLivenessAuthority.swift:184–190`). **That argument is symmetric — it
holds in the resurrection direction exactly as in the deletion direction — but
the entry guard acts on the stale value in one direction only, and it acts by
short-circuiting the very read that would have corrected it.**

So on the road item 2 exists for:

1. she opens N on the shelf tab, taps to Library, deletes N there;
2. the shelf surface's header door hears it → `noteIsGone = true`; the next tab
   tap is refused and `standDownEveryone()` runs (`isLive = false`,
   `isEditable = false`);
3. she Puts N back from the Trash — **which is on the Library tab, so the very
   next thing she does is tap back to Shelf**;
4. if the header delivery has not landed in that gap, `takeLiveness`'s entry
   guard reads the stale `true`, **returns before `confirmNoteStillLive()`**,
   and stands the surface down again.

**And it does not heal inside that visit.** `adoptHeader`'s restore branch
(`MobileEditorViewModel.swift:595`) requires `isLive` — which the refusal has
just made false — so when the delivery finally arrives, `noteIsGone` flips to
false and **editability is not restored**. She is looking at her restored note
with no keyboard and no sentence; the only way out is a second tab round-trip
or a pop/push.

**A widening worth stating, because it turns a race into a permanent state:**
`observeHeader`'s `catch` (`MobileEditorViewModel.swift:548–551`) exits the
`for try await` loop and **never restarts it**. After one transient observation
error, `adoptHeader` can only be driven by `loadOnce` or by
`confirmNoteStillLive` — and the entry guard is precisely what prevents
`confirmNoteStillLive` from ever running again. The stale `true` is then
terminal for that surface.

### The red/green pair (mine)

With the shipped tree, my probe drives the sequence above (delete →
`loadOnce` → `restoreContainer` → **no delivery** → `tabDidBecomeVisible(.shelf)`):

```
✘ probeAResurrectedNoteGetsThePenBackOnTheNextTabTap() … Expectation failed: (editors.live → nil) === (shelf → VariorumMobile.MobileEditorViewModel)
✘ … Expectation failed: (shelf → …).isLive → false
✘ … Expectation failed: !((shelf → …).noteIsGone → true → true)
✘ … Expectation failed: typeEdit((shelf → …), (shelfStorage → ), range: ({1, 0}), replacement: "X")
✘ Test probeAResurrectedNoteGetsThePenBackOnTheNextTabTap() failed after 4.216 seconds with 4 issues.
```

With **revert R-CR1 — the entry guard alone removed** (production,
`MobileLivenessAuthority.swift`):

```
✔ Test probeAResurrectedNoteGetsThePenBackOnTheNextTabTap() passed after 0.031 seconds.
```

The mechanism is therefore isolated to the entry guard and nothing else. (The
same revert reddened only `aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork`
of the 14 shipped liveness pins — see MINOR 6 — so nothing else in the suite
depends on it.)

### Why "just delete the guard" is NOT the fix I recommend

The implementer offered deletion as the honest alternative (§10 point 3), and it
does close this. But the guard is also **the only thing keeping her words on
screen** on the road where the surface already knows — see MAJOR 2: without it,
`refreshTakesFromStore()` runs first and blanks the surface. Deleting the guard
would widen that blanking to this road too.

**Fix shape:** keep the cheap arm but make it *re-confirm* instead of *refuse*.
When `editor.noteIsGone`, call `confirmNoteStillLive()` **first** — one indexed
row read, strictly cheaper than the flush + takes-refresh it currently skips —
and refuse only if the store agrees, still skipping the flush and the refresh.
That preserves every saving the guard was kept for and removes the staleness
entirely. The existing pin (`aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork`,
which watches for zero autosave settles) survives that change unmodified, since
a header read is not a flush.

---

## MAJOR 2 — on item 2's headline road her words leave the screen and NOTHING tells her why; the sentence the batch built is unreachable there

**Files:** `MobileLivenessAuthority.swift:176–196` (the order: flush → refresh →
confirm) with `MobileEditorViewModel.swift:1346–1349` (the gate belt).
**Label: MEASURED.**

### Mechanism

`takeLiveness` does its store work **before** it asks whether the note exists:

```
live = editor
await editor.autosave.flushNow()
if refresh { await editor.refreshTakesFromStore() }   ← this renders the tombstone
let stillLive = await editor.confirmNoteStillLive()   ← only now does it ask
```

`refreshTakesFromStore` reads `Queries.takesProjection` for a tombstoned post —
an **empty** projection — and hands it to `ingest` → `applyProjection([])`.
`EditorProjectionPolicy.decide` returns `.fullRender` (not busy, no match, not a
delivery, not the same sequence), and `renderFull([], preserveTail: true)`
computes `tail = new.isEmpty ? "" : nil` → `""`, so
`storage.setAttributedString(empty)` **wipes the surface**. Then
`confirmNoteStillLive()` returns false, `standDownEveryone()` runs, and
`standDown()` sets `isEditable = false`.

**Consequence, measured on the shipped tree:**

```
PROBE4 SURFACE: <>
PROBE4 STATUS: nil
PROBE4 SLOTS: 0 ENTRIES: 0
✘ probeWhatSheIsLeftLookingAtAfterTheRefusal() … Expectation failed: (shelfStorage.string → "") == "Base."
✘ … Expectation failed: (shelf.statusMessage → nil) != nil
```

A blank note, and `statusMessage` **nil**.

**And `deletedNoteRefusal` cannot rescue it.** The sentence lives only in
`shouldChangeText`, which UIKit calls only for an *editable* text view — and the
refusal has just set `isEditable = false`, so no keyboard appears and the gate is
never consulted. The sentence is a genuine third belt (a marked-text commit in
flight, a hardware keyboard), but it is **not** the road she is on.

The pin `aNoteDeletedOnTheOtherTabNeverGetsThePenBack` asserts
`statusMessage == deletedNoteRefusal` by calling `typeEdit`, which invokes
`model.shouldChangeText` directly — bypassing the `isEditable` gate production
imposes. That is legitimate for pinning the belt, but the pin's name ("and it
SAYS so — naming the Trash, not a seal") describes the belt, not the experience.

**Apportioning honestly:** the *blanking* is pre-existing (`refreshTakesFromStore`
did this before the batch). What is this batch's is the *silence*: it built the
right sentence for exactly this situation and left it on a road the fix's own
`standDown()` forecloses.

**Fix shape, two lines and both already available:**
- report the sentence where the refusal is *decided* — `editor.report(MobileEditorViewModel.deletedNoteRefusal)`
  at the authority's refusal (and/or in `adoptHeader`'s relinquish branch).
  `MobileWriteView.swift:295–297` already renders `statusMessage`, so it reaches
  the screen with no new face;
- consider asking `confirmNoteStillLive()` **before** the refresh (it is the
  cheapest of the three store acts), so her words are still on screen when the
  sentence arrives. That reordering also makes the entry guard's saving
  redundant, which composes with MAJOR 1's fix shape.

---

## MINOR 3 — the recorded defect mechanism is FALSE: no byte was ever written into a tombstone, pre-fix or post-fix

**Files:** `MobileEditorViewModel.swift:313–314` (production comment: *"Typing
then autosaved into a tombstoned note's variants — bytes written where no
listing will ever show them"*), repeated in `MobileLivenessTests.swift`'s
docstring for `aNoteDeletedOnTheOtherTabNeverGetsThePenBack` and in record §3.
**Label: MEASURED.**

`Operations.autosave` → `editableVariant` → `liveVariant`
(`Sources/VariorumCore/Operations/Operations.swift:78`) throws
`variantNotFound` for any tombstoned variant, and `deleteContainer`'s cascade
tombstones the note's blocks and variants. Measured directly:

```
PROBE2 REFUSAL: variantNotFound(id: "00000000-0000-0000-0000-000000000002")
✔ probeAutosaveIntoATombstonedNotesVariantRefuses() passed
```

and through the editor's own road (type, then delete, then `flushNow`):

```
PROBE3 STATUS: Optional("variantNotFound(id: \"00000000-0000-0000-0000-000000000002\")")
PROBE3 STORED: Optional("Base.")
✔ probeTheEditorsOwnFlushIntoATombstoneLandsNothing() passed
```

The pre-fix defect is therefore **not** silent byte loss. It is: *the surface
accepted keystrokes it could never save, and every flush refused with a raw
`variantNotFound(id: "…")` dumped into the status line.* (That raw dump is
`MobileEditorViewModel.swift:207–208`'s `String(describing: error)` — pre-existing,
this batch's item 4 is about the sibling family, and it is now confirmed
reachable on this exact road.)

**Why it matters rather than being pedantry:** the claim is what a future
session will weigh when it revisits the `confirmNoteStillLive` swallow (§10
point 4) or asks whether the gate belt is load-bearing. A belt believed to stop
corruption gets treated differently from a belt that stops a confusing surface.
The fix is a factual correction to three sentences; no code changes.

---

## MINOR 4 — the three sheets' editability PHOTOGRAPH hands the keyboard back over a tombstone (and over a stood-down surface)

**Files:** `MobileTakesBrowserView.swift:228–232`,
`MobileCommentsSheetView.swift:129–133`,
`MobileBlockHistorySheetView.swift:145–149`. **Label: READ-ONLY traced.**

Each captures `pageWasEditable = page.isEditable` at open and restores it
unconditionally at close. If the note dies while a sheet is up, `adoptHeader`'s
relinquish sets `isEditable = false` (a no-op — the sheet already did), and the
sheet's close then restores the captured `true`. The keyboard returns over a
tombstone; the gate belt refuses each keystroke, so no bytes move, but the fix's
stated intent — *"the keyboard drops the moment the note does"* — is defeated.

**This is the implementer's own §10 point 2 asked from the other side, and the
answer is the direction they did not ask about.** The resurrection direction is
fine (the restore branch requires `!takesBrowser.isOpen`, and the photograph
then restores `true` correctly); the *deletion* direction is the leak.

Note the class is **pre-existing for liveness** — a `standDown()` during an open
sheet is undone the same way — so the honest framing is a class this batch
joined rather than created.

**Fix shape:** at close, derive editability from one predicate
(`isLive && !noteIsGone && !sealed`) rather than restoring a photograph. The
phone now has six writers of `textView.isEditable` across four files; one
derivation would retire the whole class.

---

## MINOR 5 — `deletedNoteRefusal` promises the Trash for a note that has left it

**File:** `MobileEditorViewModel.swift:336–339`. **Label: READ-ONLY traced.**

`noteIsGone` is set from `Queries.containerHeader == nil`, which is true when the
row is **missing** as well as when it is tombstoned
(`Sources/VariorumCore/Queries/EditorSupport.swift:41–44` — verified). The phone
has a real Delete Now door (`MobileTrashModel.swift:182–210` →
`Operations.requestPurge`), so a stale surface can outlive its note's departure
from the Trash: between the intent and the janitor the row is tombstoned but no
longer listed, and after the sweep it is gone outright. In both states the
sentence *"it's in the Trash for 30 days. Put it back there to keep writing."*
names a door with nothing behind it.

Narrow, but it is exactly the corner item 2 exists for, and this round words
refusals from what the store says.

**Fix shape:** either soften to what is certainly true (*"This note was
deleted."* plus the Trash hint) or distinguish tombstoned-from-missing at the
one header door, which already has the row in hand.

---

## MINOR 6 — the entry guard's red-on-old was CLAIMED and never run; I ran it, and it is real

**File:** `MobileLivenessTests.swift`, the docstring of
`aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork`: *"RED ON OLD: remove the
entry `guard !editor.noteIsGone` alone and `settles` is non-zero."*
**Label: MEASURED.**

Record §3 quotes three reverts — R2 (the whole item), R2a (both authority
guards), R2a′ (the post-suspension read alone). **None of them removes the entry
guard alone**, which is the only revert that isolates this pin; and R2/R2a
predate the pin's existence (the record's own narrative says it was added
*after* those measurements — corroborated arithmetically: R2's "13 tests in 1
suite" is the pre-pin liveness count, and the file now holds 14). So the brief's
standing rule — *"red-on-old by behavioural revert, output QUOTED… every time"* —
was not met for this pin.

**I ran it (revert R-CR1, production, entry guard only):**

```
✘ aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork() … Expectation failed: (settles → 2) == 0
✘ Test aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork() failed after 0.027 seconds with 1 issue.
```

**So the pin is honest coverage, not green-over-nothing** — and the mechanism is
sound: `AutosaveCoordinator.flushNow()` calls `notifySettled()` even for an
empty batch (`AutosaveCoordinator.swift:147–150`), so "zero settles" genuinely
distinguishes *refused before any store work* from *flushed and re-read*. Two
settles, not one, because the refresh flushes again.

The finding is the discipline gap only: a docstring asserting a red that the
record never demonstrated. Recording my run closes it.

---

## NIT 7 — record accuracy: §9's per-suite lines are not all from the final tree, and one count is wrong

- §9 presents *"Per-suite runs, all GREEN on the final tree"* and lists
  `✔ Test run with 32 tests in 2 suites` for `MobileLivenessTests` +
  `MobileTakesTests`. On the final tree those files hold **14 + 19 = 33**
  (`grep -c '@Test'`, verified). 32 = 13 + 19, i.e. the run predates the fourth
  liveness pin. Harmless, but it is presented as final-tree evidence.
- §4 says the `MobileLensesTests` suite *"passes unmodified (11 tests)"*; it
  holds **10** (`@Test` count, no `arguments:` anywhere), and §9's own
  `23 tests in 2 suites` for deletion + lenses (13 + 10) proves it.

Everything load-bearing checked out: **+4 liveness / +1 deletion / +3 takes =
+8**, derived per file against `61a6e8d`; 99 suites unchanged (the new
`mintATailBlock` helper is a file-scope function, not a suite); and §9's final
line is reproduced **exactly** by my own independent run.

## NIT 8 — `confirmNoteStillLive`'s catch is silent about everything, including a store that genuinely failed

**File:** `MobileEditorViewModel.swift:352–361`.

The two sibling readers of the same door distinguish cancellation from failure
(`loadOnce` at :484–491 and `observeHeader` at :548–551 both surface a
non-cancellation error into `statusMessage`). This one swallows both. Also, on a
surface that has never had a store answer, the initialiser default `false` is
returned as though it were *"the last store answer"*.

**On the judgment itself (§10 point 4) — I assess it RIGHT, and on firmer ground
than the record knew.** MINOR 3 measures that no write can reach a tombstoned
note through any road, so "keeps the pen" cannot cost bytes; and refusing the pen
because a read failed would strand her on a note that is probably fine, with her
keystrokes having nowhere to go. The swallow's other direction is the safe one
(a failed read while the last answer was *gone* returns false and refuses).
Recommend only the sibling treatment: let a non-`CancellationError` speak.

## NIT 9 — the gate belt's "it sits above the seal" justification is vacuous

**File:** `MobileEditorViewModel.swift:1339–1340`. When `noteIsGone` is true,
`header` is nil, so `header?.locked == true` is false regardless of ordering —
the seal belt could never fire for a gone note. The stated ordering constraint
against the seal is not one (the ordering against `!isLive` **is**, and that half
is correct and was found by a pin, exactly as §10 says).

## NIT 10 — `RowPrompt.currentName` is now dead

**File:** `MobileLenses.swift:564`. The field is written at :708 and, since the
action closure takes `prompt` and reads only `lensID`, never read anywhere. The
TextField is seeded from `row.currentNameForPrompt` at :707, so nothing is
broken — the field is simply residue the conversion could have taken with it.

---

# CLEAN BILL — the eight areas I was told to push hardest on

### 1. The `confirmNoteStillLive()` swallow — **judged RIGHT** (NIT 8 rides)

Assessed adversarially against all three readings of a failed read
(cancellation at teardown; a store that cannot be opened; a transient failure
while the note really is tombstoned). The decisive fact is MINOR 3's
measurement: `Operations.autosave` refuses on a tombstoned variant, so the
"keeps the pen" branch cannot write a byte anywhere it should not. Refusing
instead would strand a probably-fine note. **The Mac's own seam** answers the
same question one line at a time — `EditorViewModel.adoptHeader:602–612` sets
`textView?.isEditable = value.map { !$0.locked } ?? false`, so a nil header
(missing or tombstoned) makes the Mac editor read-only by derivation, with no
flag, no belt, and no sentence. The phone is ahead of the Mac here; its extra
machinery is what MINOR 4 and MAJOR 1 are about, not the swallow.

### 2. The entry guard's WORK-shaped pin — **honest coverage** (MINOR 6), but the guard itself is MAJOR 1

The pin is genuinely red-on-old (I ran the isolating revert) and the work it
watches is real (`flushNow` notifies settled even when empty). **Does the guard
buy anything?** Yes, and more than the record claims: it is the only thing that
keeps her rendered words on screen on the road where the surface already knows
(MAJOR 2's blanking), and it avoids a flush whose refusal would dump a raw
`variantNotFound(…)` into the status line (MINOR 3's measurement). So the
implementer's instinct to keep it was right — but its *refuse-on-stale-state*
arm is the MAJOR, and the fix shape I propose keeps the saving while deleting the
staleness.

### 3. B45-2 — **fix correct, alternative rightly declined, lookup cannot go stale**

- Both cited readers verified verbatim: `StructuralGesturePlanner.fanArity`
  (`:491–493`) reads a missing arity as **1**; `CrossBlockEditPlanner`
  (`:192`) **declines** on a missing arity, and its own docstring already states
  *"It may run SHORTER than the entries during a crystallization window"* and
  names the asymmetry as deliberate. Ending the lag would let a cross-block
  merge run across a freshly minted block that today declines — a real semantic
  change, well outside the item. **Decline upheld.**
- **The divergence is one-directional and provable.** All three `slots`
  assignments were checked: `renderFull` and `applyDifferential` set `index` and
  `slots` together; `.adoptEcho` is reachable only via `matchesSurface()`, which
  itself requires `new.count == entries.count`
  (`EditorProjectionEngine`'s `matches`), and `.differential` requires
  `sameSequence()`. `BlockRangeIndex.crystallize` only **appends**. So `slots` is
  always a prefix of `entries`, never longer, never reordered.
- **The identity lookup cannot go stale mid-crystallization**: it searches the
  very array it writes, so it cannot be out of range by construction, and a
  blockID appears at most once in a post's rendering, so it cannot mis-match.
  Where the two arrays *are* aligned it is byte-equivalent to the old
  `slots[i]`; where they are not, the old code wrote the wrong row.
- The caller accident is real as described (`MobileTakesController.swift:148`
  `flip` and `:191` `peek` both `guard let current = model.slot(for: blockID)`;
  `:221` `endAllPeeksRestoringDisplay` reaches only previously-captured blocks).
  The survey quote at `mobile-round-2-stability-survey.md:428–439` is verbatim.
- **I did not re-run the trap revert.** The record's quoted
  `Fatal error: Index out of range` plus the traced mechanism above are
  sufficient, and re-running it would have taken my runner down for no new
  information.
- No P1 concern: the added `slots.firstIndex` is O(slots) on a per-gesture door
  that already performs two O(entries) walks.

### 4. Item 2's ordering — **correct, for the reason given**; interleavings hunted

The tombstone belt above `!isLive` is right: the authority's refusal stands the
surface down, so below the liveness belt the door would answer *"This note is
live in your other tab"* about a note in the Trash. (Above the *seal* is a
non-constraint — NIT 9.) `noteIsGone` kept apart from `isLive` is right, and the
`private(set)`/single-writer discipline holds — only the authority writes
`isLive`, only `adoptHeader` writes `noteIsGone`.

Interleavings I hunted:
- **a delete landing DURING the authoritative read's suspension** — covered.
  There is no suspension between `confirmNoteStillLive()` returning and
  `noteLivenessGranted()`, so the delete lands either before the read (refused)
  or after the grant, where the observation drives `adoptHeader`'s relinquish.
- **a superseded grant that still adopts a header** — `confirmNoteStillLive`
  calls `adoptHeader` before the caller's `guard isCurrent(token)`, so a
  superseded grant does install state. It is benign: the header read is of that
  editor's own note and is fresher than what it replaces, and the restore branch
  cannot fire on a superseded surface because it requires `isLive`.
- **a Put back racing a stand-down** — **this is MAJOR 1**, and it is the one the
  tokens cannot help with, because the staleness is in the surface's own
  projection, not in the handoff order.
- **the transient `live = editor` before the suspensions** — grepped: nothing
  outside this class and its tests reads `MobileLivenessAuthority.live`, so the
  window is unobservable.

### 5. Item 3's `presenting:` conversion — **the 4.5b shape, done right; the no-pin declaration verified**

The conversion matches the established sites verbatim (`MobileNoteTray.swift:503`,
`MobileVersions.swift:331/346`, `MobileLibraryView.swift:149`,
`MobileTrashView.swift:114`, `MobileTagManager.swift:356/373`); the subject
arrives as a parameter and no read-back survives. The alert has no `message:`
closure, so no second closure needed the parameter. The sibling alert in the same
file ("Save as Lens") is not in the class — it reads `saveField` forwards over
`$savePresented`, with no subject to clear — so no sibling was left behind.

**"Unpinnable by construction" is TRUE as declared, and both halves check out
against the harness's own measured header:** the opener really is a
`.contextMenu` row (`MobileLenses.swift:705`), and `MobileSurfaceDriver.swift:34–45`
states *"A SwiftUI `Menu`'s rows are NOT reachable… the accessibility tree comes
back EMPTY"* and *"A `.contextMenu` (long-press) row is likewise undrivable in
process"*; the subject is view `@State` (`:559`), which
`tapAlertAction(_:writeBack:)` (`:426–434`) cannot write because its write-back
must go *"through the very binding SwiftUI writes"*. **I found no in-process road
the header denies.** `MobileLensesTests` (10 tests) passed unmodified in my full
run.

### 6. Item 4's scope claim — **verified at both tables**

`Operations.deleteContainer` (`Operations+Container.swift`) has exactly one
throwing guard, `liveContainer`, which throws `containerNotFound`
(`Operations.swift:56`); its only other work is the version-tombstone loop and
two `update`s. `DeletionRefusal.words` maps `containerNotFound` to *"That note is
already gone."* (`RecoveryActs.swift`) — **byte-identical** to the retired private
table. So nothing she can currently reach moved, and the 12 other tests in
`MobileDeletionTests` passing on the record's reverted tree is the positive
proof. The non-`OperationError` road (a raw `DatabaseError`) also improves: the
old `String(describing:)` becomes `DeletionRefusal.fallback`'s
*"That couldn't be done — …"*.

### 7. The survival-mode record — **every PENDING resolved, and the claims check out**

Diffed `df97677`'s record against the final one. All five PENDING marks are
resolved rather than dropped: the teardown (**verified — `V45cPhone-17-26` /
*[removed for publication]*
indeed left alone**), item 4's red-on-old (run and quoted), the full suite (run
and quoted), and the two narrative ones. Counts re-derived per file against the
base: liveness 10→14, deletion 12→13, takes 16→19 = **+8**, matching the record's
attribution exactly; suites 99→99 confirmed by my own run. **§9's final line
matches mine byte for byte** (675/99, 2 known issues, `** TEST SUCCEEDED **`),
and the two known issues are the one documented diagnostic it names. The
scratchpad-hazard record is accurate — the stale `prerevert/` directory is real
and holds another batch's copies of the two files this batch edited; I used my
own `45c-coldreview/` for the same reason. Residue: NIT 7.

### 8. The fence — **re-derived, empty; tripwire zero**

```
$ git diff --name-only 61a6e8d..4788a95 -- Sources/ App/Variorum/Shared App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"
(empty)
$ git diff 61a6e8d..4788a95 -- '*.swift' | grep -c planVisibleTakeEdit
0
```

`Package.resolved` untouched; nothing under `EditorBrain/`; the nine changed
files are the seven the record names plus its own two `notes/plans/` files (one
of which, `mobile-batch-7-brief.md`, belongs to `1efbf0e`, not this batch).
`Shared/RecoveryCopy.swift` and `Shared/RecoveryActs.swift` were called and never
edited. The deferral (item 6, §7) is coherent and correctly reasons from the 13u
item-5 ruling; nothing was built for it.

---

# ADJUDICATION + FIX-WAVE BRIEF (the Fable orchestrator, 2026-08-31)

**ALL TEN ACCEPTED, ZERO DISPUTES** — and because both MAJORs' fixes land
in the LIVENESS SEAM (the app's riskiest neighbourhood), this unit takes
a **focused ROUND-2 re-review of the wave's diff** after the fixes, per
the ladder's letter — not the mechanical-fix close 6b/9 used. Shapes:

1. **MAJOR 1 — re-confirm instead of refuse.** At the entry guard, a
   `noteIsGone` reading triggers `confirmNoteStillLive()` FIRST (cheaper
   than the flush+refresh it currently skips); only a store-confirmed
   gone note refuses. The A2 token discipline rides the added await
   exactly as the existing arms. Pin: the reviewer's own probe — a Put
   back followed by a grant heals the surface in the same visit
   (red-on-old against the shipped short-circuit). The `observeHeader`
   terminal-catch is CONTEXT, not this wave's to rebuild — one comment
   line naming it where the stream exits, and it rides the record.
2. **MAJOR 2 — the refusal SPEAKS, and the existence answer comes before
   the wipe.** Order the authoritative existence check ahead of the
   store refresh on the grant road where the trace allows (so
   `renderFull([])` never runs for a gone note), and land
   `deletedNoteRefusal` through the existing `statusMessage` road at the
   point the refusal is decided. Pin: the reviewer's PROBE4 script —
   after a tombstoned note's grant, the surface is not silently blank:
   the status speaks (red-on-old on the shipped silence).
3. **MINOR 5 rides MAJOR 2's fix:** the sentence covers BOTH gone
   shapes — tombstoned (the Trash road is true) and missing/purged (it
   is not) — either one honest sentence or a branch on which fact
   `confirmNoteStillLive` learned.
4. **MINOR 4 — routed, not fixed here:** the sheets' `isEditable`
   photograph is the SAME CLASS as the leftover-backlog batch's owned
   stranded-`isEditable` item (the ruled nesting-aware editability
   authority replaces photographs entirely). One clause on that owned
   row in `mobile-round-2-handoff-2026-08-30.md` §7.2 naming this
   tombstone variant so the fix covers both; one line in this record.
5. **MINOR 3 + NIT 7 + NIT 9 — record corrections** (the false
   no-byte-was-written mechanism becomes the true one: a surface
   accepting keystrokes it could never save, dumping the raw enum; the
   two count fixes; the vacuous ordering claim corrected to what the
   nil-header fact makes true).
6. **MINOR 6 — run-and-record:** the entry-guard revert the docstring
   claimed is now REAL (the reviewer ran it) — the wave re-runs it
   post-fix in its new shape, quotes it, and the docstring says what
   reds it.
7. **NIT 8 — record-only:** the swallow's judgment is ENDORSED as
   assessed (and better-founded than the record knew); add the one
   comment line distinguishing it from its two speaking siblings, and
   the record notes the deliberate silence. NO behaviour change.
8. **NIT 10 — delete the dead `RowPrompt.currentName`.**

**ONE Opus fix session, the items above, then a FRESH focused round-2
reviewer over the wave's diff** (dispatched by the orchestrator from the
wave's report; no round 3 unless it finds a NEW BLOCKER/MAJOR — the
ladder's cap). Fence and environment as the batch brief (own armed
simulator, private DerivedData, deleted after; full suite at the end —
baseline 675/99 + 2 known issues — final line quoted; pre-revert copies
in a UNIQUELY NAMED scratchpad dir with diff-verified restores — stale
`prerevert/` dirs from other batches exist; `Package.resolved` never
swept; fence grep + planVisibleTakeEdit zero verified before the
pathspec-limited commit; no pushes). Every behavioural change proven red
by behavioural revert with output quoted, production or fixture named.
Append a FIX WAVE RESULTS section to THIS file before the final message.
