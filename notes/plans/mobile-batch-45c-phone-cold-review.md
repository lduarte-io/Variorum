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

---

# FIX WAVE RESULTS (2026-08-31)

**Scope:** the eight adjudicated items above, and nothing else.
**Files touched:** three phone-local production files, one test file, two
notes files.

| file | items |
|---|---|
| `VariorumMobile/Features/Shell/MobileLivenessAuthority.swift` | 1, 2, 3 |
| `VariorumMobile/Features/Write/MobileEditorViewModel.swift` | 2, 3, 5, 7 (+ item 1's `observeHeader` context line) |
| `VariorumMobile/Features/Takes/MobileLenses.swift` | 8 |
| `VariorumMobileTests/MobileLivenessTests.swift` | 1, 2, 5, 6 (**+3 pins**) |
| `notes/plans/mobile-round-2-handoff-2026-08-30.md` | 4 |
| `notes/plans/mobile-batch-45c-phone-record.md` | 4, 5, 7 |
| `notes/plans/mobile-round-2.md` | 5 (§49 + ledger row 11 carry the same false sentence) |

## Environment

| what | value |
|---|---|
| simulator | `V45cFixWave-17-26` — iPhone 17, **iOS 26.2 (23C54)**, created fresh for this wave (the 16-series sims are iOS 18.3 and invalid) |
*[removed for publication]*
| accessibility | `ApplicationAccessibilityEnabled` written and **read back `1`** |
| derived data | private `-derivedDataPath` at `<scratchpad>/dd-wave` |
| pre-revert copies | `<scratchpad>/45c-wave-prerevert/` — a UNIQUELY named directory. The scratchpad already held FOUR stale copy dirs from other batches (`prerevert/`, `45c-prerevert/`, `45c-coldreview/`, `fixwave-prerevert/`); none was read or written. Every restore was verified by `diff` **and** by sha256 against the copy this wave made. |
| hygiene | `Package.resolved` untouched · no fenced file touched · no `.bak-*` · no Release build, no install, no push · the real store never touched · the live Mac app never quit |

## Per-item dispositions

### 1 · MAJOR 1 — the entry arm RE-CONFIRMS instead of refusing · **FIXED, pinned**

`takeLiveness`'s `guard !editor.noteIsGone else { standDownEveryone(); return }`
became an arm that, on a `noteIsGone` reading, calls `confirmNoteStillLive()`
FIRST — one indexed header read, strictly cheaper than the flush + takes-refresh
it skips — and refuses only if the store agrees. The `guard isCurrent(token)`
after the added await is the A2 discipline, identical to every other suspension
in the method. **Everything the arm was kept for survives:** a store-confirmed
tombstone still skips the flush and the refresh entirely.

**Item 1's `observeHeader` clause, honoured as CONTEXT and not rebuilt:** one
comment at the stream's `catch` names that it exits and is never restarted, and
says why that makes the re-confirm load-bearing — after one dropped stream,
`confirmNoteStillLive` is the only door left, so the old short-circuit would
have made a stale `noteIsGone` terminal. **No retry machinery was built.**

**New pin:** `aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap` — the
reviewer's own probe script (delete → `loadOnce` → `restoreContainer` → **no
delivery** → `tabDidBecomeVisible(.shelf)`), with the gap left undriven on
purpose because the gap IS the precondition.

**RED ON OLD — revert R-W1** (production; the short-circuiting guard restored,
everything else post-fix):

```
✘ aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap() … Expectation failed: (editors.live → nil) === (shelf → VariorumMobile.MobileEditorViewModel)
✘ … Expectation failed: (shelf → …).isLive → false
✘ … Expectation failed: !((shelf → …).noteIsGone → true → true)
✘ … Expectation failed: (shelfStorage.string → "").contains("Base.")
✘ … Expectation failed: typeEdit((shelf → …), (shelfStorage → ), range: ({1, 0}), replacement: "X")
✘ … Expectation failed: try await storedText(db, variantID: minted.variant.id) == "BXase."
✘ Test aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap() failed after 5.410 seconds with 6 issues.
✘ Test run with 17 tests in 1 suite failed after 6.289 seconds with 6 issues.
```

**Isolated: the other 16 stayed green** — so nothing else in the suite rides
the short-circuit. Restored from `45c-wave-prerevert/`, `diff` clean,
sha256 `bd62c6da…` identical.

### 2 · MAJOR 2 — the existence answer comes BEFORE the wipe, and the refusal SPEAKS · **FIXED, pinned (both halves separately)**

Two changes, and one belt the first of them makes necessary:

- **the ORDER.** `confirmNoteStillLive()` moved above `refreshTakesFromStore()`,
  so a tombstoned note's empty projection never reaches `renderFull([])` and her
  words stay on screen.
- **the SENTENCE.** ~~Both refusal sites~~ *[CORRECTED 2026-08-31, round-2 NIT
  R2-4: **THREE** — the entry arm (`MobileLivenessAuthority.swift:188`), the
  authoritative read (`:210`) and the belt this same fix added (`:222` on the
  wave-1 tree this section describes; `:236` after wave 2 grew that belt's
  comment); the count was written before the wave grew the third site]* now
  route through one
  private `refuseOverTombstone(_:)` = `standDownEveryone()` +
  `editor.report(Self.deletedNoteRefusal)`.
  `MobileWriteView`'s existing `statusMessage` row renders it — **no new face**.
- **the BELT the reorder earns.** With the read above the refresh, the refresh
  becomes the one suspension between the store's answer and the grant — the
  round-1 clean bill (§4) had rested on there being none. A cheap
  `guard !editor.noteIsGone` after the refresh closes it, and it is ~~**provably
  not stale**: the read a moment earlier adopted the store's own answer through
  the same door, so a true value can only have come from a later delivery.~~
  *[SUPERSEDED 2026-08-31, round-2 MINOR R2-2 — the claim was wrong and the
  belt was changed rather than re-worded: **landed after is not taken after.** A
  nil delivery observed BEFORE the read can land after it, so the bare belt
  could stand a LIVE note down and speak a refusal about a note the store never
  lost (the reviewer measured it). **Wave 2's belt re-confirms through
  `confirmNoteStillLive()` — token-checked like every other await — so every
  refusal on this road is now store-confirmed.** See WAVE 2 RESULTS item 2.]*

**New pins:** `aRefusedGrantLeavesHerWordsOnScreenAndSaysWhy` (the reviewer's
PROBE4 script — surface intact AND status spoken) and
`aDeliveryLandingInsideTheRefreshStillStopsTheGrant` (the belt).

**RED ON OLD — revert R-W2** (the ORDER alone: `confirmNoteStillLive()` moved
back below the refresh, taking the belt with it):

```
✘ aRefusedGrantLeavesHerWordsOnScreenAndSaysWhy() … Expectation failed: (shelfStorage.string → "").contains("Base.")
✘ Test aRefusedGrantLeavesHerWordsOnScreenAndSaysWhy() failed after 0.062 seconds with 1 issue.
✘ aDeliveryLandingInsideTheRefreshStillStopsTheGrant() … Expectation failed: (editors.live → VariorumMobile.MobileEditorViewModel) == nil
✘ … Expectation failed: !((model → …).isLive → true → true)
✘ … Expectation failed: (model.statusMessage → nil) == (MobileEditorViewModel.deletedNoteRefusal → "This note was deleted — if it's still in the Trash (30 days), put it back there to keep writing.")
✘ Test run with 17 tests in 1 suite failed after 5.598 seconds with 4 issues.
```

`shelfStorage.string → ""` **is the reviewer's measured wipe, reproduced.**

**RED ON OLD — revert R-W3** (the SENTENCE alone: `refuseOverTombstone`'s
`editor.report(…)` removed, order kept):

```
✘ aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork() … Expectation failed: (model.statusMessage → nil) == (MobileEditorViewModel.deletedNoteRefusal → "…")
✘ aRefusedGrantLeavesHerWordsOnScreenAndSaysWhy() … Expectation failed: (shelf.statusMessage → nil) == (MobileEditorViewModel.deletedNoteRefusal → "…")
✘ aDeliveryLandingInsideTheRefreshStillStopsTheGrant() … Expectation failed: (model.statusMessage → nil) == (MobileEditorViewModel.deletedNoteRefusal → "…")
✘ Test run with 17 tests in 1 suite failed after 0.977 seconds with 3 issues.
```

**RED ON OLD — revert R-W4** (the BELT alone: the post-refresh guard removed):

```
✘ aDeliveryLandingInsideTheRefreshStillStopsTheGrant() … Expectation failed: (editors.live → VariorumMobile.MobileEditorViewModel) == nil
✘ … Expectation failed: !((model → …).isLive → true → true)
✘ … Expectation failed: (model.statusMessage → nil) == (…)
✘ Test run with 17 tests in 1 suite failed after 4.001 seconds with 3 issues.
```

**Each revert is isolated to what it removes** — R-W2 reddens 2 of 17, R-W3
reddens 3 of 17 (the three status assertions and nothing else), R-W4 reddens 1
of 17; every other pin in the suite stayed green through all three. All three
restores `diff`-clean against `45c-wave-prerevert/` and sha256-identical.

**A WIDENING CONSIDERED AND DECLINED, recorded because the adjudication offered
it ("and/or in `adoptHeader`'s relinquish branch").** It was built, then
**traced and removed**: speaking at that transition clobbers the receipt on her
commonest deletion road — `deleteNote` reports *"Moved to the Trash…"*, the
observation delivers nil a beat later, and the note's own ⋯ door would answer
its own act with a refusal about a door she just used
(`MobileDeletionTests.deletingANoteMovesItToTheTrashAndSaysSo` pins that
receipt). Speaking only where the refusal is DECIDED covers every road that
hands this surface the pen, with no clobber. **What that leaves, named at the
code and here rather than left to be discovered:** the SYNC road — deleted on
the Mac while she is looking at it here — still drops the keyboard with nothing
on screen until the next grant or keystroke speaks. Closing it wants a way to
tell *this surface deleted it* from *someone else did*, which is a design act,
not a fix-wave line.

### 3 · MINOR 5 — the sentence covers BOTH gone shapes · **FIXED (copy), no pin, and the no-pin is measured**

The **one honest sentence** road, not the branch: a second store read to tell
tombstoned from missing buys one word. Now
*"This note was deleted — if it's still in the Trash (30 days), put it back
there to keep writing."* — true for a tombstoned row AND for one that has left
the Trash through the phone's own Delete Now door. `TrashWindow.days` still
carries the number; no literal.

**No pin, and this was checked rather than asserted (revert R-W5 — the pre-fix
sentence restored):** `✔ Test run with 17 tests in 1 suite passed after 0.612
seconds.` **Nothing red** — because every consumer compares the symbol, by
design so the sentence cannot fork between the gate and the authority. A pin
here could only echo the literal back, which is the green-over-nothing shape
this round has caught six times. Filed under the hallucination guard's
copy/clarity clause: traced mechanism (nil header covers missing; the Delete
Now door at `MobileTrashModel.swift:182–210` makes it reachable), written
justification, no test.

### 4 · MINOR 4 — the sheets' `isEditable` PHOTOGRAPH · **ROUTED, not fixed**

One clause added to the owned leftover-backlog row in
`mobile-round-2-handoff-2026-08-30.md` §7.2, naming this tombstone direction
beside the stranded-false direction batch 9 found in the same three lines, and
adding the load-bearing constraint the routing exists for: **the ruled authority
must DERIVE editability at rest (`isLive && !noteIsGone && !sealed`), not
depth-count a photograph** — a depth count alone leaves this direction leaking.
A pin for the new direction is named there too. One line in the batch record
(§11). **Nothing built here** — half-fixing a class whose ruled fix replaces the
mechanism is how machinery gets built twice.

### 5 · MINOR 3 + NIT 7 + NIT 9 — record corrections · **DONE**

- **MINOR 3 (the false mechanism)** corrected in all three homes: the production
  docstring on `noteIsGone`, the pin docstring on
  `aNoteDeletedOnTheOtherTabNeverGetsThePenBack`, and record §3 (struck in
  place, marked `[CORRECTED 2026-08-31]`). The true statement replaces it: no
  byte was ever written into a tombstone; the surface accepted keystrokes it
  could never save, and every flush dumped the raw `variantNotFound(id: "…")`.
  The pin's docstring now also says which of its assertions is a
  characterization green on both trees, so nobody reads it as the red.
  **Two homes the review did not enumerate carried the same false sentence and
  are corrected with it** (same correction, not new scope): `mobile-round-2.md`
  **§49's MAJOR** and its **ledger row 11** — the round's master record, and the
  file most likely to be read by a future session. Both struck in place with the
  measured statement beside them.
- **NIT 7 (two counts)** — record §9's *"all GREEN on the final tree"* keeps the
  runs but loses the false final-tree claim for the `32 tests in 2 suites` line
  (33 on the final tree; 32 predates the fourth liveness pin); §4's
  `MobileLensesTests` *"11 tests"* corrected to **10**.
- **NIT 9 (the vacuous ordering claim)** struck at the gate's comment and in
  record §3 point 4: a gone note has a nil `header`, so `header?.locked == true`
  is false whatever the order — there was no constraint against the seal to
  satisfy. The `!isLive` constraint is real and is untouched.

### 6 · MINOR 6 — the entry arm's red-on-old, RUN in its new shape · **DONE**

Revert **R-W1b**: the arm replaced by a fall-through (the isolating revert for
the WORK assertion, in the shape the arm now has).

```
✘ aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork() … Expectation failed: (settles → 1) == 0
✘ Test run with 17 tests in 1 suite failed after 1.444 seconds with 1 issue.
```

**Note the number changed and it is not noise: `settles → 1`, where the
reviewer measured 2.** That is item 2's reorder, visible: the grant now meets
the authoritative read one suspension earlier, so a note it did not know was
gone costs ONE flush instead of a flush plus the refresh's. The pin's docstring
was rewritten to describe the arm it now guards and to name **both** reverts
that red it (the fall-through for the work, `refuseOverTombstone`'s `report` for
the sentence). Restored `diff`-clean.

### 7 · NIT 8 — the swallow's silence · **ENDORSED, comment + record only**

One comment at `confirmNoteStillLive`'s `catch` distinguishing it from its two
speaking siblings — they are the roads that were going to PAINT something; this
is a belt inside a handoff, and MINOR 3's measurement is why keeping the pen
there cannot cost a byte. Record §11 carries the disposition. **No behaviour
change, no pin owed.**

### 8 · NIT 10 — the dead `RowPrompt.currentName` · **DELETED**

Written at `MobileLenses.swift:708`, read nowhere (grep-verified across the
whole app: the only other `currentName` is the Mac's own `LensesBoardView`
type, which reads its own and is fenced). The struct's doc now says why it
carries the id and nothing else. Compile-verified; no behaviour to pin.

## Suite

**Baseline: 675/99 green with 2 known issues** (the batch's own close).

**Liveness suite on the final tree:**

```
✔ Test run with 17 tests in 1 suite passed after 0.878 seconds.
```

**FULL SUITE — the exact final line, on the FINAL tree:**

```
✘ Test run with 678 tests in 99 suites passed after 313.010 seconds with 2 known issues.
** TEST SUCCEEDED **
```

*(Swift Testing marks a run carrying known issues with `✘` while reporting it
`passed`; `** TEST SUCCEEDED **` is the verdict.)*

| | baseline | now | delta |
|---|---|---|---|
| tests | 675 | **678** | **+3 — exactly this wave's pins** (all three in `MobileLivenessTests`, 14 → 17) |
| suites | 99 | 99 | 0 — every pin joined an existing suite |
| known issues | 2 | 2 | 0 — the same documented diagnostic, `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, which records issues BY DESIGN |

**IT WAS RUN TWICE, and both are reported.** The first full run (`678 tests in
99 suites passed after 313.621 seconds with 2 known issues` · `** TEST
SUCCEEDED **`) was started before two `///` lines were added to
`refuseOverTombstone`/`standDownEveryone`'s doc comments, so it is one build
behind the committed tree; the run quoted above is the final tree. Reporting
both rather than the convenient one.

**Neither watched-for condition occurred, in either run:** the load-flaky perf
pin `MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`
**passed** both times (1.172 s / 1.198 s — no isolated re-run needed), and there
was **no runner restart** (`grep -c "Restarting after unexpected exit"` = 0 in
both logs). The one revert that took the runner down in the original batch
(item 1's trap) has no analogue here — every revert in this wave failed
assertions rather than trapping.

**Simulator teardown: DONE** — `V45cFixWave-17-26`
*[removed for publication]*
simulators from older batches were left alone.

## Fences

```
$ git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"
(empty)
$ git diff -- '*.swift' | grep -c planVisibleTakeEdit
0
```

ZERO changes under `Sources/`, `App/Variorum/Shared/`,
`App/Variorum/Variorum/` (the Mac target), `EditorBrain/`, schema/migrations,
build configs; `Package.resolved` untouched. No item's trace ran through
`planVisibleTakeEdit` — 13u1 owns that neighbourhood.

---

# ROUND 2 — the FOCUSED re-review of the fix wave

**Reviewer:** a fresh cold reviewer with zero implementation context.
**Date:** 2026-08-31.
**Target:** the wave's diff `ad88752..06d6163` (one commit), on branch
`mobile` in the `~/dev/variorum-mobile` worktree. Round 1's full-batch
clean bills stand; this pass is the FIXES and what they touched.

## What I ran

| act | result |
|---|---|
*[removed for publication]*
| `ApplicationAccessibilityEnabled` | written and **read back `1`** |
| derived data | private `-derivedDataPath` at `<scratchpad>/dd-round2` |
| **FULL MOBILE SUITE** (from `App/Variorum/`), on the pristine final tree BEFORE any revert | `✘ Test run with 678 tests in 99 suites passed after 321.406 seconds with 2 known issues.` / `** TEST SUCCEEDED **` |
| runner restarts | **ZERO** (`grep -c "Restarting after unexpected exit"` = 0) |
| the load-flaky perf pin | `✔ typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k() passed after 1.219 seconds` — **did not red; no isolated re-run needed** |
| the 2 known issues | the same documented diagnostic, `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, which records issues BY DESIGN |
| THREE production reverts (mine — R-R2-1 = the wave's R-W1, R-R2-2 = its R-W1b, R-R2-3 = its R-W2) | run, quoted below |
| TWO temporary PROBE tests (mine, `ZZRound2Probes.swift`) | run, quoted below, **file deleted** |

**Hygiene.** My copies live in a UNIQUELY named
`<scratchpad>/45c-round2-prerevert/`; the FIVE stale copy dirs from other
batches (`prerevert/`, `45c-prerevert/`, `45c-coldreview/`,
`45c-wave-prerevert/`, `fixwave-prerevert/`) were neither read nor
written. Every restore verified by `diff` **and** sha256:
`MobileLivenessAuthority.swift` = `a4bef847…`,
`MobileEditorViewModel.swift` = `156d904d…`, both matching the copies I
took before touching anything; `git status --porcelain` empty afterwards,
and `MobileLivenessTests` re-run green on the restored tree
(`✔ Test run with 17 tests in 1 suite passed after 0.569 seconds`).
`Package.resolved` untouched. No Release build, no install, no commit, no
push. The real store was never touched; the live Mac app was never quit.
Tree left byte-identical apart from this file.

## Severity counts

**BLOCKER 0 · MAJOR 0 · MINOR 3 · NIT 2**

**No round 3 is triggered.** Both MAJORs are genuinely closed — I
reproduced their reds myself, and the fixes are the right shape. What I
found is one behaviour the wave's new sentence introduced, one
justification that claims more than it proves, and one deferral left
without an owner.

---

# FINDINGS

## MINOR R2-1 — the authority's NEW sentence outlives the note it was about: after a Put back and a successful re-grant, the masthead still says *"This note was deleted…"* while she is typing in the note

**Files:** `MobileLivenessAuthority.swift:244–247` (`refuseOverTombstone`'s
`editor.report(…)`, added by this wave) with
`MobileEditorViewModel.swift:299–304` (`noteLivenessGranted`, which clears
nothing) and the sticky `statusMessage` convention at `:87–89`.
**Label: MEASURED** (probe below).

### Mechanism, traced then measured

`statusMessage` is sticky by design: it is cleared only by an explicit
`report(nil)`, and there are exactly three such sites — rename (`:1036`),
seal (`:1151`) and entry date (`:1187`). **Nothing on the grant road
clears it.** `noteLivenessGranted()` sets `isLive` and hands the keyboard
back; `adoptHeader`'s restore branch sets `isEditable`; `ingest` /
`applyProjection` repaint the surface. None of them touches the status
line, and typing does not either.

So the sequence **MAJOR 1's own fix now makes possible** ends in a false
sentence:

1. she deletes the note from a Library row;
2. she taps to Shelf — the authority refuses and **now speaks**
   (`aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork` and
   `aRefusedGrantLeavesHerWordsOnScreenAndSaysWhy` both pin that);
3. she taps back to Library and Puts the note back from the Trash;
4. she taps to Shelf — the re-confirming arm heals everything: the pen
   returns, `noteIsGone` is false, the refresh brings her words back, the
   gate accepts her keystroke…
5. …and the masthead still reads **"This note was deleted — if it's still
   in the Trash (30 days), put it back there to keep writing."**

### The probe (mine, on the shipped tree — everything else in it passed)

```
PROBE-A refusal spoken: This note was deleted — if it's still in the Trash (30 days), put it back there to keep writing.
PROBE-A status AFTER the heal: This note was deleted — if it's still in the Trash (30 days), put it back there to keep writing.
✘ probeTheRefusalSentenceSurvivesThePutBackAndTheReGrant() … Expectation failed: (shelf.statusMessage → "This note was deleted — if it's still in the Trash (30 days), put it back there to keep writing.") == nil
✘ Test probeTheRefusalSentenceSurvivesThePutBackAndTheReGrant() failed after 0.129 seconds with 1 issue.
```

The probe's other five expectations — `editors.live === shelf`,
`isLive`, `!noteIsGone`, the words back on screen, and a `typeEdit` that
is ACCEPTED — all passed. So this is isolated to the sentence: a working,
live, editable note wearing a refusal about itself.

### Apportioning honestly

**The CLASS is one batch older than this wave.** The gate's own refusal
(`MobileEditorViewModel.swift:1409–1412` → `refuse(…)` at `:2148–2149`)
is equally sticky and equally survives a Put back — that site is
4.5c-phone's, not the wave's. **What the wave added is a second producer,
on the road it simultaneously taught to heal**, which is what makes the
contradiction reachable without a keystroke into a tombstone first.

**Severity by this round's own calibration:** round 1 rated *"the refusal
promises the Trash for a note that has left it"* (MINOR 5) a MINOR — the
same class, a sentence that is not true of the note in front of her. This
is that class again, so MINOR it is. Nothing is lost and she can write.

**Fix shape (one line, and it composes with the wave's own shape):** clear
the refusal where the grant succeeds — in the authority, immediately
before `editor.noteLivenessGranted()`:
`if editor.statusMessage == MobileEditorViewModel.deletedNoteRefusal { editor.report(nil) }`
— narrow on purpose, so a grant never eats an unrelated receipt. **Pin:**
extend `aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap` with a
refusing tap before the Put back and a `statusMessage == nil` assertion
after the heal (red on today's tree, per the probe above). Whoever fixes
it should decide at the same time whether the GATE's producer wants the
same treatment; one clearing rule covers both.

---

## MINOR R2-2 — the post-refresh belt's *"cannot be stale"* proof claims more than it proves, and the pin defending it drives exactly the stale case: a nil DELIVERY refuses a note that is LIVE in the store

**Files:** `MobileLivenessAuthority.swift:216–224` (the comment and the
belt) with the pin `aDeliveryLandingInsideTheRefreshStillStopsTheGrant`
(`MobileLivenessTests.swift:807`). **Label: MEASURED** (probe below).

### Mechanism

The belt's written justification is:

> *"A `noteIsGone` reading taken HERE cannot be stale — the read above just
> adopted the store's own answer through the same door, so a true value can
> only have come from a delivery that landed after it."*

"Landed after" is not "observed after", and **the gap between the two is
this file's own load-bearing premise**: `confirmNoteStillLive`'s docstring
says it (`MobileEditorViewModel.swift:368–371` — *"a delivery whose latency
is real, and a tab tap landing inside that latency would take the pen on a
stale answer"*), and MAJOR 1 was argued from exactly that asymmetry. A nil
header delivery **observed before** the confirm can **land after** it,
inside the refresh; the belt then refuses a live note, stands the surface
down, and speaks a refusal that is false.

**The wave's own pin drives that world.** Its docstring is explicit that
*"the store row itself is left alone"* — nothing is ever deleted in it —
and the delivery is injected by hand at settle 2. It then reports the
outcome as *"the grant stopped on the fresher reading"*. It was not
fresher; there was nothing to be fresher than. The pin is a good pin of the
BELT's mechanism and a poor witness for the belt's JUSTIFICATION, and the
docstring should not be the thing a future session reads as proof of
freshness.

### The probe (mine — the same world, read back from the store's side)

```
PROBE-B store header is nil? false
PROBE-B live? false status: This note was deleted — if it's still in the Trash (30 days), put it back there to keep writing.
✘ probeTheBeltRefusesALiveNoteOnAStaleNilDelivery() … Expectation failed: (editors.live → nil) != nil
```

`Queries.containerHeader` returns a live row for the whole test, and the
grant is refused anyway.

### Why MINOR and not MAJOR

Two things bound it, and both are the wave's own work:

- **Reachability is sub-millisecond.** `noteIsGone` can only become true
  from a header answer, and the only writer that can carry a value older
  than our read is the observation. So the false refusal needs a delete
  and a Put back straddling one delivery's flight, with a tab tap inside
  it. A human cannot produce that.
- **It is no longer terminal.** MAJOR 1's fix is precisely what heals it:
  the next grant's entry arm re-confirms rather than refusing, so the
  surface recovers on the following tap. The wave replaced a terminal
  staleness with a transient one — which is a real improvement, just not
  the absence the comment asserts.

**Fix shape (either is fine, and the second is prettier):**
(a) **record-only** — soften the claim to what holds (*"a nil reading here
is either genuinely fresh or a delivery observed before the read; the
latter is a sub-ms window and self-heals on the next grant, which
re-confirms"*) and re-word the pin's narrative so it stops describing a
fabricated delivery as fresher; or (b) **apply the wave's own medicine** —
have the belt `confirmNoteStillLive()` instead of refusing on a delivery,
exactly as MAJOR 1 taught the entry arm to. It is one indexed read on a
road that has already done two, and it would make the belt's guarantee
match its comment.

---

## MINOR R2-3 — the disclosed decline's own residual has NO OWNER: it lives in a production comment and a plan file that closes, while the SAME wave routed its sibling deferral to a durable owned row

**Files:** `MobileEditorViewModel.swift:634–648` (the comment) and this
file's FIX WAVE RESULTS (line ~729). **Label: READ-ONLY traced + verified.**

### The decline's trace: SOUND, with two qualifications the record does not carry

I verified it rather than taking it:

- `deleteNote()` really does report on the **editor's own**
  `statusMessage` — `report(RecoveryCopy.movedToTrashReceipt(.note))` at
  `MobileEditorViewModel.swift:1082` — and
  `MobileDeletionTests.deletingANoteMovesItToTheTrashAndSaysSo:62` pins
  that receipt. So an `adoptHeader`-sited report WOULD overwrite it when
  the observation's nil lands. **The property is real.**
- **Qualification (i):** on that road the screen is dismissing —
  `MobileNoteActions.swift:145–148` calls `dismiss()` and `onDeleted()`
  the moment `deleteNote()` returns true — so the clobber is a flash under
  an animation on a surface that is leaving, not a state she is left
  standing in. The Library-row road cannot clobber at all
  (`MobileLibraryViewModel.swift:385` reports on the LIBRARY model).
- **Qualification (ii):** the pin could not have caught it either way.
  `start()` is production-only (`MobileEditorViewModel.swift:502`), and no
  headless world calls it, so no observation runs in tests. "Traced and
  removed" is the honest description; nothing was measured.

**I do not dispute the decline.** Speaking only where the refusal is
decided is the cleaner rule, and the wave was right to record what it
leaves rather than to widen quietly.

### The finding is the ASYMMETRY

The residual — *the SYNC road (deleted on the Mac while she is looking at
it here) still drops the keyboard with nothing on screen* — is recorded in
exactly two places: a comment inside `adoptHeader`, and the fix-wave
section of **this file**, which closes with the batch. It is **not** in
`mobile-round-2.md`'s ledger, **not** on the handoff's owned
leftover-backlog row, and **not** in `KnownIssuesAndTechDebt.md`
(grep-verified). Meanwhile the same wave, for MINOR 4, wrote a full clause
onto the owned row in `mobile-round-2-handoff-2026-08-30.md` §7.2 — the
right instinct, applied to one deferral and not its sibling.

CLAUDE.md's rule is that deliberately-deferred work names an owner, and a
17-entry or a project row satisfies it exactly as a phase number does. A
code comment is durable but only reaches someone already editing
`adoptHeader`; it is not a work item anybody will schedule.

**My judgment, for the orchestrator to adjudicate:** the record + comment
is **not enough**. One clause is owed, and the natural home is the one the
wave already used — the owned row in
`mobile-round-2-handoff-2026-08-30.md` §7.2 (or a numbered row in
`mobile-round-2.md`'s ledger) — naming the residual and the design
question it needs answered: *how does a relinquish tell "this surface
deleted it" from "someone else did"?* That question is genuinely a design
act, which is an argument for giving it an owner, not for leaving it
unowned.

---

## NIT R2-4 — "Both refusal sites" is stale by one: there are THREE, and all three do route through `refuseOverTombstone`

The fix-wave section says *"Both refusal sites now route through one
private `refuseOverTombstone(_:)`"*. The sites are
`MobileLivenessAuthority.swift:188` (the entry arm), `:210` (the
authoritative read) and `:222` (the belt the same fix added). **All three
verified routed**, and `standDownEveryone` now has exactly one caller
(`refuseOverTombstone`), so the reporting road really is single. Only the
count is wrong, and it is wrong because the wave grew a third site after
writing the sentence.

*(Noted and not raised: `tabDidBecomeVisible`'s else-branch at `:144–145`
open-codes `standDownEveryone`'s two lines instead of calling it. That is
pre-existing and arguably right — that road is not a tombstone refusal and
must not speak.)*

## NIT R2-5 — the shipped count correction repeats a false reason

Record §4's correction reads *"the file holds 10 `@Test`s and **no
`arguments:`**"*. There ARE three `arguments:` lines in
`MobileLensesTests.swift` (`:52`, `:373`, `:456`) — all three are **GRDB
SQL arguments**, none on a `@Test` macro, so the **10 is correct** and the
correction's conclusion stands. The reason as written is not, and a future
count check that re-runs `grep -c 'arguments:'` will trip on it. Same
check re-derived for the other three suites: liveness 17, takes 19,
deletion 13, lenses 10 — every `arguments:` occurrence is SQL.

---

# CLEAN BILL — the seven areas I was told to push hardest on

### 1. MAJOR 1's fix — **CLOSED, correctly, and the arm order opens nothing**

- **A2 token discipline on the added await: correct, and better than
  merely correct.** `guard isCurrent(token)` sits between the await and
  the refusal (`:186` before `:187`), so a superseded grant **cannot even
  speak** — it returns having installed nothing. Same shape at both other
  sites. The one thing that DOES install state across the await is
  `confirmNoteStillLive`'s own `adoptHeader`, which round 1 already
  adjudicated benign; it stays benign post-fix, and I re-derived why in
  both directions: `adoptHeader`'s restore branch requires `isLive`, so a
  superseded surface either has `isLive == false` already (the superseding
  grant's stand-down ran first) or gets `isEditable = false` from that
  stand-down a moment later. No leak either way.
- **The Put-back pin really drives the shipped road** — I reproduced its
  red myself (below), and the pin deliberately drives NO delivery after
  the restore, which is the defect's precondition rather than an omission.
- **ARM ORDER — no window re-opened.** Round 1's probe closed a
  *terminal* staleness; re-confirming first cannot re-open it. A delete
  landing between the entry confirm and the grant is still caught by the
  authoritative read after the flush (`:207`) and then by the belt
  (`:221`). The window that DID widen is a delete committing between the
  authoritative read and the grant — it now spans `refreshTakesFromStore`
  — and its outcome is unchanged from pre-fix: the observation's relinquish
  drops the keyboard just after the grant. No byte can move (round 1's
  MINOR 3 measurement), and the belt catches it whenever the delivery
  arrives in time. **The narrow leftover** is a delete committing between
  the read and the refresh's own store read, which would render an empty
  projection and then grant — strictly narrower than the pre-fix behaviour
  the fix replaced, so a reduction, not a regression. Recorded here rather
  than raised.

**RED ON OLD — my revert R-R2-1** (production; the wave's R-W1 exactly —
the short-circuiting `guard !editor.noteIsGone else { refuseOverTombstone(editor); return }`
restored, everything else post-fix):

```
✘ aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap() … Expectation failed: (editors.live → nil) === (shelf → VariorumMobile.MobileEditorViewModel)
✘ … Expectation failed: (shelf → …).isLive → false
✘ … Expectation failed: !((shelf → …).noteIsGone → true → true)
✘ … Expectation failed: (shelfStorage.string → "").contains("Base.")
✘ … Expectation failed: typeEdit((shelf → …), (shelfStorage → ), range: ({1, 0}), replacement: "X")
✘ … Expectation failed: try await storedText(db, variantID: minted.variant.id) == "BXase."
✘ Test aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap() failed after 5.735 seconds with 6 issues.
✘ Test run with 17 tests in 1 suite failed after 6.380 seconds with 6 issues.
```

**Identical to the wave's quoted R-W1, assertion for assertion**, and the
other 16 stayed green.

### 2. MAJOR 2's fix, three halves — **all three hold**

- **The authoritative read above the refresh: `renderFull([])` cannot run
  for a gone note on ANY road into the grant.** `takeLiveness` has exactly
  two callers — `register` (`refresh: false`, so no refresh at all) and
  `tabDidBecomeVisible` (`refresh: true`, and the refresh is now below the
  read). Verified against the wipe's actual mechanism:
  `applyProjection`'s `.fullRender` arm with an empty non-delivery
  projection → `renderFull(new, preserveTail: true)` → `tail = new.isEmpty ? "" : nil`
  (`MobileEditorViewModel.swift:751–760`). The 25-odd OTHER callers of
  `refreshTakesFromStore` (takes browser, structural, comments, lenses,
  block history, undo) are not grant roads and are untouched by this fix —
  correctly, since round 1 apportioned the blanking as pre-existing.
  **A delivery-shaped empty projection is separately safe**: deliveries
  never take a render arm (`.refetchFresh`), which is why the sync road
  does not blank her surface.
- **The ONE `refuseOverTombstone`: yes — and it is THREE sites, not two**
  (NIT R2-4), all routed, with `standDownEveryone` reduced to a single
  caller. `MobileWriteView.swift:295–302` renders `statusMessage`, so the
  sentence reaches the screen with no new face, exactly as claimed.
- **The non-stale belt: the mechanism is right, the PROOF is overstated**
  — MINOR R2-2. It is a real belt closing a real window; what it cannot
  claim is the absence of the other one.

**RED ON OLD — my revert R-R2-3** (the wave's R-W2: the authoritative read
moved back below the refresh, taking the belt with it):

```
✘ aRefusedGrantLeavesHerWordsOnScreenAndSaysWhy() … Expectation failed: (shelfStorage.string → "").contains("Base.")
✘ Test aRefusedGrantLeavesHerWordsOnScreenAndSaysWhy() failed after 0.029 seconds with 1 issue.
✘ aDeliveryLandingInsideTheRefreshStillStopsTheGrant() … Expectation failed: (editors.live → VariorumMobile.MobileEditorViewModel) == nil
✘ … Expectation failed: !((model → …).isLive → true → true)
✘ … Expectation failed: (model.statusMessage → nil) == (MobileEditorViewModel.deletedNoteRefusal → "This note was deleted — if it's still in the Trash (30 days), put it back there to keep writing.")
✘ Test aDeliveryLandingInsideTheRefreshStillStopsTheGrant() failed after 2.663 seconds with 3 issues.
✘ Test run with 17 tests in 1 suite failed after 3.356 seconds with 4 issues.
```

**`shelfStorage.string → ""` — round 1's measured wipe, reproduced a
third time**, and matching the wave's quote exactly. The other 15 stayed
green.

### 3. THE DISCLOSED DECLINE — **trace sound, removal clean, residual UNOWNED**

The trace verified (with two qualifications the record should carry) and
the removal is complete: `adoptHeader` gained a comment and nothing else,
there is no orphaned helper, and the app's only `refuseOverTombstone`
caller set is the authority's three sites. The judgment on the residual is
**MINOR R2-3** above; the short version for the orchestrator is that **the
code comment plus a closing plan file is not an owner**, and the wave
itself demonstrated the right remedy one item earlier.

### 4. MINOR 6's number — **attribution VERIFIED by trace AND by running it**

The wave says `settles` moved 2 → 1 because MAJOR 2's reorder means a
tombstone is discovered before `refreshTakesFromStore` opens its own
flush. Traced first: pre-wave the fall-through ran `flushNow` (settle 1) →
`refreshTakesFromStore`'s own `flushNow` (settle 2) → confirm → refuse;
post-wave it runs `flushNow` (settle 1) → confirm → refuse, and the
refresh never happens. Then measured, with my revert **R-R2-2** (the
wave's R-W1b — the entry arm replaced by a fall-through):

```
✘ aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork() … Expectation failed: (settles → 1) == 0
✘ Test aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork() failed after 0.039 seconds with 1 issue.
✘ Test run with 17 tests in 1 suite failed after 0.967 seconds with 1 issue.
```

**`settles → 1`, exactly as recorded, with the story that produces it.**
The pin is honest coverage in its new shape, and the docstring now names
both reverts that red it.

### 5. Pin quality — **no green-over-nothing in the three new pins**

- `aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap` guards its own
  precondition (`#expect(shelf.noteIsGone, "the surface knows, and that is
  the stale value")`) so it cannot silently drift onto the other road, and
  six of its assertions red on the old shape. **Strongest pin in the wave.**
- `aRefusedGrantLeavesHerWordsOnScreenAndSaysWhy` guards the opposite
  precondition (`#expect(!shelf.noteIsGone, "the surface has not been
  told")`). Two of its four assertions (`live == nil`, `!isLive`) are green
  on both trees — characterization, and the docstring says so rather than
  claiming the red. The two that matter both red.
- `aDeliveryLandingInsideTheRefreshStillStopsTheGrant` cannot pass
  vacuously: if `settles` never reached 2 the delivery would not fire and
  the grant would land, reddening `live == nil`. Its MECHANISM coverage is
  sound; its NARRATIVE is MINOR R2-2.
- The status assertion added to
  `aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork` reds under the
  wave's R-W3, and I confirmed by grep that **every** consumer of the
  sentence compares the SYMBOL `MobileEditorViewModel.deletedNoteRefusal`
  (5 test sites, 2 production sites), never a literal — which is also the
  independent proof that MINOR 5's "no pin is possible" is true by
  construction, not by assertion.

### 6. The record corrections — **spot-verified, all landed**

- **MINOR 3's homes: FIVE, all corrected.** The production docstring on
  `noteIsGone` (`:315–324`), the pin docstring on
  `aNoteDeletedOnTheOtherTabNeverGetsThePenBack`, batch record §3, and the
  two the review had not enumerated — `mobile-round-2.md` **§49** and
  **ledger row 11**, both struck in place with the measured statement
  beside them. A repo-wide grep for the false sentence returns only the
  three sites that QUOTE it inside their own correction. The correction's
  factual claim re-verified at the source: `Operations.autosave` →
  `editableVariant` → `liveVariant` (`Operations.swift:78`).
- **NIT 7:** §9's *"all GREEN on the final tree"* is now *"all GREEN"*
  with the stale line explained; §4's `11 tests` is now `10`. Both counts
  independently re-derived (see NIT R2-5 for the one wrong reason).
- **NIT 9:** struck at the gate's comment (`:1400–1403`) and in record §3
  point 4; the surviving claim (the `!isLive` ordering) is the true one.
- **MINOR 5's measured no-pin:** verified by construction — see area 5.
  The new sentence is honest for both gone shapes, and `TrashWindow.days`
  still carries the number.
- **NIT 10:** `RowPrompt.currentName` is gone and the alert reads only
  `prompt.lensID` (`MobileLenses.swift:651–667`); the only surviving
  `currentName` in the repo is the Mac's own `LensesBoardView` type, which
  reads its own and is fenced.
- **MINOR 4's routing:** the clause on
  `mobile-round-2-handoff-2026-08-30.md` §7.2 is real, names the tombstone
  direction beside batch 9's stranded-false direction, carries the
  load-bearing constraint (**derive**, do not depth-count a photograph),
  and names a pin for the new direction. Correctly routed.

### 7. The fence — **re-derived by me, empty; tripwire zero**

```
$ git diff --name-only ad88752..06d6163 -- Sources/ App/Variorum/Shared App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"
(empty)
$ git diff ad88752..06d6163 -- '*.swift' | grep -c planVisibleTakeEdit
0
```

Eight changed files and no more: three phone-local production files
(`MobileLivenessAuthority.swift`, `MobileEditorViewModel.swift`,
`MobileLenses.swift`), one test file, four `notes/plans/` files.
`Package.resolved` untouched; nothing under `Sources/`, `Shared/`,
`EditorBrain/`, the Mac target, schema/migrations or build configs. **And
the behavioural surface is genuinely tight**: outside the authority, the
only non-comment production changes in the whole wave are the refusal
STRING and the deletion of one dead struct field — every other line in
`MobileEditorViewModel.swift` is documentation.


---

# ROUND-2 ADJUDICATION + WAVE-2 BRIEF (the Fable orchestrator, 2026-08-31)

**ALL FIVE ACCEPTED, ZERO DISPUTES. No round 3 (no new BLOCKER/MAJOR).**
One small final wave:

1. **R2-1** — one narrow clear of the tombstone sentence on the grant
   road before `noteLivenessGranted()` (clear ONLY the refusal-family
   status, never an unrelated receipt — the deletion receipt's pin must
   ride green). Pin red-on-old with the reviewer's own probe: refuse →
   Put back → re-grant leaves NO stale "deleted" sentence while she
   types in the live note.
2. **R2-2 — the belt takes the wave's own medicine:** on a late
   `noteIsGone` flip, the belt RE-CONFIRMS via `confirmNoteStillLive()`
   (token-checked like every other await) instead of trusting delivery
   ordering; the false-refusal window closes instead of being
   documented. Re-word the pin so the live-in-store world drives to a
   GRANT (red-on-old: the shipped belt refuses it falsely), and the
   "cannot be stale" claim comes out of the comment — say what is now
   true (every refusal on this road is store-confirmed).
3. **R2-3** — one clause on the owned leftover-backlog row in
   `mobile-round-2-handoff-2026-08-30.md` §7.2, beside MINOR 4's:
   the SYNC-ROAD SILENT KEYBOARD DROP residual, with its design
   question (how does a relinquish tell "this surface deleted it" from
   "someone else did"?) — the MECHANISM investigation owned there; the
   VOICE half (what the phone should say when sync deletes the note
   under her — MobileSoul §5.3's discoverability family) flagged for
   her bundle in the record.
4. **R2-4** — "both" → "three", verified sites named. **R2-5** — restore
   the true count reason (three GRDB SQL args exist; the `10` stands for
   the reason the reviewer states).

Then this unit CLOSES on the orchestrator's verification. Environment
and rules exactly as wave 1 (own armed simulator, private DerivedData,
deleted after; full suite — baseline 678/99 + 2 known issues — final
line quoted; unique pre-revert dir, diff-verified restores; fence grep +
planVisibleTakeEdit zero; pathspec-limited commit; no pushes). Append a
WAVE 2 RESULTS section to THIS file before the final message.

---

# WAVE 2 RESULTS (2026-08-31)

**Session:** the wave-2 fix session, on branch `mobile` in the
`~/dev/variorum-mobile` worktree, from `526f6a0`. Scope was exactly the
four numbered items of the ROUND-2 ADJUDICATION + WAVE-2 BRIEF above;
nothing beyond them was touched.

## Environment

| act | result |
|---|---|
*[removed for publication]*
| `ApplicationAccessibilityEnabled` | written and **read back `1`** |
| derived data | private `-derivedDataPath` at `<scratchpad>/dd-wave2` |
| **FULL MOBILE SUITE** (from `App/Variorum/`), on the final tree | `✘ Test run with 678 tests in 99 suites passed after 309.041 seconds with 2 known issues.` / `** TEST SUCCEEDED **` |
| runner restarts | **ZERO** (`grep -c "Restarting after unexpected exit"` = 0) |
| the load-flaky perf pin | `✔ typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k() passed after 1.187 seconds` — **did not red; no isolated re-run needed** |
| the 2 known issues | the same documented diagnostic, `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, which records issues BY DESIGN |
| THREE production reverts (mine — R-W2-1, R-W2-2a, R-W2-2b) | run, quoted below |

**Counts unchanged, deliberately.** No test was added: item 1 EXTENDS an
existing pin and item 2 REWORKS one, so `MobileLivenessTests` holds 17
`@Test`s exactly as it did at round 2, and the suite total is the
baseline `678 tests in 99 suites` on the nose.

**Hygiene.** Pre-revert copies live in a UNIQUELY named
`<scratchpad>/45c-wave2-prerevert/`; the six stale copy dirs from other
batches (`prerevert/`, `45c-prerevert/`, `45c-coldreview/`,
`45c-wave-prerevert/`, `45c-round2-prerevert/`, `fixwave-prerevert/`)
were neither read nor written. Both restores verified by `diff` **and**
sha256 — `MobileLivenessAuthority.swift` = `1c07a1f4…`, identical to the
copy taken before the first revert. `Package.resolved` untouched (no
drift to revert). No Release build, no install, no push; the real store
was never touched and the live Mac app was never quit.

## Per-item dispositions

### 1 · MINOR R2-1 — the refusal is withdrawn where it stops being true · **FIXED, pinned**

**Production** (`MobileLivenessAuthority.swift`, in `takeLiveness`,
immediately before `editor.noteLivenessGranted()`):

```swift
if editor.statusMessage == MobileEditorViewModel.deletedNoteRefusal {
    editor.report(nil)
}
```

**NARROW exactly as the brief required — the refusal-family sentence and
nothing else.** The comparison is against the one sentence this road can
have produced, so an unrelated receipt on the editor's own status line is
untouched: her commonest deletion road leaves *"Moved to the Trash…"*
standing there, and
**`MobileDeletionTests.deletingANoteMovesItToTheTrashAndSaysSo` rides
green** — verified in the full run above, and structurally
safe besides (that pin never constructs a `MobileLivenessAuthority`, so no
grant runs in it, and the two strings differ regardless).

**One rule, both producers.** Matching on the sentence rather than on the
site means the GATE's producer (`MobileEditorViewModel:1409-1412` →
`refuse(Self.deletedNoteRefusal)`) is covered by the same line — the
reviewer's *"whoever fixes it should decide at the same time"* answered
in the affirmative, with no second mechanism.

**Pin:** `aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap` extended
with a refusing tap BEFORE the Put back (which is what puts the sentence
on the masthead) and a `statusMessage == nil` assertion after the heal.
The refusing tap asserts the sentence IS spoken first, so the pin cannot
pass by never having produced one.

**RED ON OLD — revert R-W2-1** (the clear removed, nothing else):

```
✘ Test aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap() recorded an issue at MobileLivenessTests.swift:737:13: Expectation failed: (shelf.statusMessage → "This note was deleted — if it's still in the Trash (30 days), put it back there to keep writing.") == nil
✘ Test aNotePutBackFromTheTrashGetsThePenBackOnTheNextTabTap() failed after 0.043 seconds with 1 issue.
✘ Test run with 17 tests in 1 suite failed after 0.602 seconds with 1 issue.
```

**Isolated: the other 16 stayed green**, so nothing else in the suite
rides the clear. Restored, `diff` clean, sha256 identical.

### 2 · MINOR R2-2 — the belt takes the wave's own medicine · **FIXED, pinned in two directions**

**Production** — the post-refresh belt now re-confirms instead of trusting
delivery ordering, in the entry arm's exact shape (the cheap reading gates
the read; the read earns the refusal; **the token is re-checked after the
added await, exactly as the A2 discipline requires and as the entry arm
does**, so a superseded grant cannot even speak):

```swift
if editor.noteIsGone {
    let confirmedLive = await editor.confirmNoteStillLive()
    guard isCurrent(token) else { return }
    guard confirmedLive else {
        refuseOverTombstone(editor)
        return
    }
}
```

**The claim came out of the comment** and what is now true went in its
place: *landed after is not taken after* — a nil observed BEFORE the
authoritative read can land after it — so the comment no longer asserts
freshness it cannot have, and states instead that **every refusal on this
road is store-confirmed**. The wave-1 record's *"provably not stale"*
paragraph is struck in place above with a pointer here (round-2 NIT R2-4's
count correction sits beside it).

**Cost:** one indexed header read, paid ONLY when the delivery says gone —
so the ordinary grant is byte-for-byte the same work it was.

**Pin re-worded and RENAMED** to what it now witnesses:
`aDeliveryLandingInsideTheRefreshIsReConfirmedAgainstTheStore` (was
`…StillStopsTheGrant`). Its world is unchanged and is the honest one —
the settle seam is synchronous so the observer drives `adoptHeader(nil)`,
the DELIVERY, and **the store row is deliberately left ALIVE** — but the
outcome it now demands is a GRANT.

**RED ON OLD, direction 1 — revert R-W2-2a** (the shipped bare belt
restored):

```
✘ Test aDeliveryLandingInsideTheRefreshIsReConfirmedAgainstTheStore() recorded an issue at MobileLivenessTests.swift:871:13: Expectation failed: (editors.live → nil) === (model → VariorumMobile.MobileEditorViewModel)
✘ Test aDeliveryLandingInsideTheRefreshIsReConfirmedAgainstTheStore() recorded an issue at MobileLivenessTests.swift:873:13: Expectation failed: (model → VariorumMobile.MobileEditorViewModel).isLive → false
✘ Test aDeliveryLandingInsideTheRefreshIsReConfirmedAgainstTheStore() recorded an issue at MobileLivenessTests.swift:874:13: Expectation failed: !((model → VariorumMobile.MobileEditorViewModel).noteIsGone → true → true)
✘ Test aDeliveryLandingInsideTheRefreshIsReConfirmedAgainstTheStore() recorded an issue at MobileLivenessTests.swift:876:13: Expectation failed: (model.statusMessage → "This note was deleted — if it's still in the Trash (30 days), put it back there to keep writing.") == nil
✘ Test run with 17 tests in 1 suite failed after 4.782 seconds with 4 issues.
```

**That output IS the defect, quoted:** a note the store never lost, stood
down and told it had been deleted.

**RED ON OLD, direction 2 — revert R-W2-2b** (the belt removed outright),
which is what keeps the pin from being green-over-nothing about the
belt's PRESENCE:

```
✘ Test aDeliveryLandingInsideTheRefreshIsReConfirmedAgainstTheStore() recorded an issue at MobileLivenessTests.swift:874:13: Expectation failed: !((model → VariorumMobile.MobileEditorViewModel).noteIsGone → true → true)
✘ Test run with 17 tests in 1 suite failed after 2.263 seconds with 1 issue.
```

Nothing re-asks the store, so the injected delivery's `noteIsGone` stands
— and `noteLivenessGranted` would hand back the pen without making the
surface editable. Restored, `diff` clean, sha256 `1c07a1f4…` identical.

**WHAT THE PIN DOES NOT WITNESS, recorded rather than implied** (and
written into its docstring so no future session reads more into it): the
belt refusing a note the store AGREES is gone. Producing that world needs
the row deleted BETWEEN the pre-refresh read and the refresh — i.e. an
`await` inside a synchronous settle observer, which cannot be written, and
the alternative (a raw synchronous row write from the observer) would be
an ad-hoc row edit outside the operations API. The refusal itself is
pinned at the road's two other sites
(`aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork`,
`aRefusedGrantLeavesHerWordsOnScreenAndSaysWhy`), and all three sites route
through the one `refuseOverTombstone`.

### 3 · MINOR R2-3 — the sync-road residual gets a durable owner · **DONE**

One clause added to the owned leftover-backlog row in
`notes/plans/mobile-round-2-handoff-2026-08-30.md` §7.2, beside MINOR 4's
— explicitly *"the same batch's second deferral, given the same owner so
neither sits in a plan file that closes"*. It carries: the residual (the
sync road drops the keyboard with nothing on screen), the DECLINE's trace
with the round-2 reviewer's two qualifications (the screen is dismissing;
the Library-row road cannot clobber at all), the receipt pin the decline
protects, and **the design question named as the work**: *how does a
relinquish tell "this surface deleted it" from "someone else did"?*

**The split the brief asked for is written into the clause:** the
MECHANISM investigation is owned there; the **VOICE half — what the phone
should SAY when sync deletes the note under her hands — is FLAGGED FOR
THE AUTHOR'S BUNDLE** as MobileSoul §5.3's discoverability family (it is a
copy decision about a surface she is standing on, not an implementation
choice). **Nothing was built for it here.**

The production comment in `adoptHeader` gains a four-line pointer to that
owned row — so the comment, which the reviewer rightly said reaches only
someone already editing this function, now hands them the work item.

### 4 · NIT R2-4 + NIT R2-5 — record corrections · **DONE**

- **R2-4** — *"Both refusal sites"* corrected in place to **THREE**, each
  site named and re-verified by me: `MobileLivenessAuthority.swift:188`
  (the entry arm), `:210` (the authoritative read), and the belt the same
  fix added (`:222` on the wave-1 tree that section describes, **`:236` on
  this one** — wave 2's rewrite grew that belt's comment, and the
  correction says so rather than quoting a number that has moved). The
  reason is recorded too: the wave grew a third site after the sentence
  was written. All three still route through the one
  `refuseOverTombstone`, and `standDownEveryone` still has exactly that
  one caller (`:279`).
- **R2-5** — the shipped count correction in
  `notes/plans/mobile-batch-45c-phone-record.md` keeps its conclusion (10
  is right) and **loses the false reason**: `MobileLensesTests.swift`
  carries three `arguments:` lines at `:52`, `:373` and `:456`, **all
  three GRDB SQL arguments and none on a `@Test` macro** — re-derived by
  me, not taken. The other three suites re-checked the same way and every
  `arguments:` occurrence is SQL: **liveness 17 · takes 19 · deletion 13 ·
  lenses 10**, each figure a fresh `grep -c '@Test'` at this tree.

## Fences

`git status --porcelain` after the work touches SIX files and no others:

```
 M App/Variorum/VariorumMobile/Features/Shell/MobileLivenessAuthority.swift
 M App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift
 M App/Variorum/VariorumMobileTests/MobileLivenessTests.swift
 M notes/plans/mobile-batch-45c-phone-cold-review.md
 M notes/plans/mobile-batch-45c-phone-record.md
 M notes/plans/mobile-round-2-handoff-2026-08-30.md
```

**FENCE GREP EMPTY** — zero changes under `Sources/`,
`App/Variorum/Shared/`, `App/Variorum/Variorum/`, `EditorBrain/`, and
none to schema, build configs or `Package.resolved`. **`planVisibleTakeEdit`
tripwire: ZERO** Swift hits in the diff (the surviving Mac P1 violation is
13u1's, and this wave went nowhere near it).

**No PENDING marks are left in this section.**

---

# UNIT CLOSED (the Fable orchestrator, 2026-08-31)

**Batch 4.5c-phone's R28 unit is COMPLETE, and it took the FULL ladder:**
build `4788a95` (through two session deaths — an auth outage and the
account limit — survived on the survival-record posture, `df97677`) →
round-1 cold review `ad88752` (0B · 2M · 4m · 4n, both MAJORs measured
in the liveness seam) → fix wave `06d6163` → round-2 focused re-review
`526f6a0` (0B · 0M · 3m · 2n — one of them the wave's own sticky
sentence) → wave 2 `6eec90e`. **Final: mobile 678/99 green, 2 known
issues.** Fence clean at every commit, verified by the orchestrator.
The liveness seam now refuses NOTHING without store confirmation, heals
on Put back in the same visit, and speaks when it refuses.

**Held/owned out of this unit:** the seam carves deferred to post-13u
(by ruling, recorded); the sync-road silent keyboard drop owned on the
leftover-backlog row (mechanism) + her bundle (the voice half); MINOR
4's isEditable-photograph variant folded into the same owned row; the
`observeHeader` terminal-catch recorded as context. The scratchpad
prerevert-collision hazard is now standing machinery (unique dirs +
diff-verified restores) — carried in every subsequent brief.
