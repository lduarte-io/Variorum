# Batch 4.5c-PHONE — the implementer's record

**Brief:** `notes/plans/mobile-batch-45c-phone-brief.md` (binding).
**Branch:** `mobile` · **base HEAD at dispatch:** `61a6e8d`.

> ## ⚠️ AMENDED 2026-08-31 BY THE FIX WAVE — read this first
>
> The batch was cold-reviewed (`mobile-batch-45c-phone-cold-review.md`:
> **BLOCKER 0 · MAJOR 2 · MINOR 4 · NIT 4**, all ten accepted, zero
> disputes) and a fix wave landed. **Two claims in this record were
> measured FALSE and are corrected in place below, marked
> `[CORRECTED 2026-08-31]`** — §3's defect mechanism (no byte was ever
> written into a tombstone), §3's seal-ordering justification (vacuous),
> and §9/§4's two test counts. **Two behaviours this record describes
> have CHANGED:** the authority's entry arm now RE-CONFIRMS instead of
> refusing on a stale `noteIsGone` (MAJOR 1), and the authoritative
> existence read now comes BEFORE the takes-refresh and SPEAKS its
> refusal (MAJOR 2). The fix wave's own record — dispositions, reverts,
> quoted reds — is the **FIX WAVE RESULTS** section at the end of the
> cold-review file, and it governs where the two disagree.

> ## ✅ BATCH COMPLETE — every deliverable done, every PENDING resolved
>
> This session died TWICE mid-batch (an authentication outage, then the
> account limit) and was written throughout **for a successor with ZERO
> context**. Both deaths were survived without losing work; the survival
> posture is kept below as the record of how, and because it is the honest
> account of how this batch was produced.
>
> **FINAL STATE:** all five build/verify deliverables **DONE**, item 6
> (record-only) **DONE**, every red-on-old **RUN AND QUOTED**, the full mobile
> suite **GREEN at 675/99 with the 2 known issues** (baseline 667/99 + this
> batch's 8 pins). No behavioural revert is in flight — every reverted file
> was restored byte-identical from `45c-prerevert/` and verified with `diff`.
> Fences clean, tripwire zero.
>
> *(The one thing a successor should NOT re-derive: the deaths cost this batch
> nothing except time. Nothing was half-applied, nothing was lost, and the
> two-stage record — write it as the work lands, resolve PENDINGs at the end —
> is what made that true.)*

---

## 0. Session interruptions — what they did and did not do

**Outage 1 (authentication, mid-turn).** It hit after items 1 and 2's
PRODUCTION code had landed in the working tree and before any pin, any other
item, or any build had run. On resume the tree was verified before anything
else was touched:

```
$ git log --oneline -1
61a6e8d 4.5c's phone-local brief lands: five items and one recorded deferral, …
$ git status --short
 M App/Variorum/VariorumMobile/Features/Shell/MobileLivenessAuthority.swift
 M App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift
$ git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"
(empty)
```

The full diff of both files was read back and matched what this session
intended to write: **no half-applied edit, no revert staged when the outage
hit**, no `Package.resolved` drift, no fence crossing. Work resumed from there.

**A scratchpad hazard, recorded because it could bite a successor:** this
session's scratchpad already contained a `prerevert/` directory holding TEN
files from an **earlier, unrelated batch** (`MobileBlockHistory.swift`,
`MobileBlockMenu.swift`, `MobileTakesBrowser.swift`, … and its own copies of
`MobileEditorViewModel.swift` and `MobileLivenessAuthority.swift`). Restoring
"the pre-revert copy" from that directory would have clobbered this batch's
work with another batch's bytes. **This batch's copies live in a uniquely
named directory, `45c-prerevert/`**, and every restore below was verified with
`diff` rather than trusted. The stale `prerevert/` was left untouched.

---

## 1. Environment

| what | value |
|---|---|
| simulator | `V45cPhone-17-26` — iPhone 17, **iOS 26.2 (23C54)**, created fresh for this batch |
*[removed for publication]*
| accessibility | `ApplicationAccessibilityEnabled` written and **read back `1`** |
| derived data | private `-derivedDataPath` at `<scratchpad>/dd` |
| teardown | DONE — deleted at the batch's close (§9) |

The 16-series simulators on this machine carry iOS 18.3 only and are invalid
for this app; iPhone 17 / iOS 26.2 is the newest pair available here. A stray
`Variorum-batch6a` simulator from an older batch was left alone.

---

## 2. Deliverable 1 — B45-2: the `displaySlot` / `slots[i]` coupling

**STATUS: DONE.** Fix + 3 pins in the tree; **red-on-old RUN and QUOTED**.

### The room, traced (finding-time `:1146`; re-located by symbol at `:1166`)

`MobileEditorViewModel.displaySlot(_:for:)` derives `i` from
`index.entries.firstIndex(where: { $0.blockID == blockID })` and then wrote
`slots[i] = slot`. Those are **two different arrays**, and they genuinely
diverge:

- `renderFull` (`index = newIndex; slots = new`) and `applyDifferential`
  (`index = BlockRangeIndex(slots: new, …); slots = new`) set both together;
- `.adoptEcho` sets `slots = new` only, but that arm is reached exactly when
  the block sequence matches, so no length divergence;
- **`finishMint` calls `index.crystallize(minted:remainingTailLength:)` and
  never assigns `slots`.** For the whole crystallization window
  `index.entries.count > slots.count`, with `slots` a prefix of `entries`
  (crystallize APPENDS).

So for a freshly minted block, `i` is a valid `entries` index and an
**out-of-range trap** in `slots`.

**Why nothing traps today — the caller accident, verified at the code:** both
takes-controller doors that reach `displaySlot` guard first on
`model.slot(for: blockID)` (`MobileTakesController.swift:148` `flip`, `:191`
`peek`), and `slot(for:)` searches `slots` — so a block absent from `slots`
bails before the call. The third caller, `endAllPeeksRestoringDisplay`
(`:221`), is not guarded that way but can only reach a block it previously
captured an `originals[blockID]` for, i.e. one that was in `slots` at capture
time; since crystallize only appends, its index is still in range. **None of
this is an invariant** — it is where the callers happen to stand, and the
stability survey said exactly that (`mobile-round-2-stability-survey.md:432–439`).

### The fix, and why this shape

The survey named two remedies — *"index the slot by blockID, or keep `slots`
in lockstep through `crystallize`"*. **Taken: index by blockID** (the brief's
"re-derive the slot from identity rather than index"):

```swift
if let s = slots.firstIndex(where: { $0.blockID == blockID }) {
    slots[s] = slot
}
```

**Why not the lockstep half:** `slots` is index-parallel with `entries` for
other readers — `planCrossBlockEdit`'s `fanArities: slots.map(\.activeVariantCount)`
and `MobileTakesBrowser`'s position count — and the LAG is deliberately guarded
for in two places that would silently change meaning if it ended:
`StructuralGesturePlanner.World.fanArity` (`:492`, reads a missing arity as 1)
and `CrossBlockEditPlanner` (a missing arity DECLINES — pinned by the existing
`aMissingArityDeclinesRatherThanAssumingNoFan`). Manufacturing a slot row at
this door would end that lag for one block on one road — a semantic change well
outside this item. The non-append is recorded at the code as deliberate.

**No new cost class:** the function already does an O(entries)
`firstIndex(where:)` and an O(entries) `index.range(ofEntryAt: i)` on the same
road. A per-gesture door, never a keystroke road.

### Pins (`MobileTakesTests.swift`, end of the main suite)

| pin | what it holds |
|---|---|
| `aCrystallizedBlockIsInTheIndexBeforeItIsInTheSlots` | the WINDOW is real (3 entries, 2 slots, append-shaped) — boundary characterization, green both trees |
| `displayingAFreshlyMintedBlocksSlotDoesNotTrap` | **THE RED-ON-OLD PIN** |
| `aBlockTheProjectionKnowsStillHasItsSlotUpdated` | the control: a known block still gets its slot written (an implementation that "fixed" this by writing nothing would fail here) |

A private helper `mintATailBlock(_:_:)` builds the window on the shipped
timing rule (a paragraph completes when the next one begins).

**The pin drives `displaySlot` DIRECTLY, and that is deliberate**: `flip`/`peek`
bail at the very guard that IS the accident under test, so a pin routed
through them would be green over nothing. This is the shape batch 7's PR8
reorder-takes door will produce.

### RED ON OLD — production (`MobileEditorViewModel.displaySlot`)

Revert: `if let s = slots.firstIndex(…) { slots[s] = slot }` → `slots[i] = slot`.
It does not fail — **it TRAPS**, taking the runner down:

```
◇ Test run started.
Swift/ContiguousArrayBuffer.swift:704: Fatal error: Index out of range
2026-08-31 10:14:39.294100-0600 VariorumMobile[44002:70551587] Swift/ContiguousArrayBuffer.swift:704: Fatal error: Index out of range
Restarting after unexpected exit, crash, or test timeout; summary will include totals from previous launches.
◇ Test run started.
✔ Test run with 1 test in 1 suite passed after 0.064 seconds.
** TEST FAILED **
```

Its two siblings passed on the reverted tree, exactly as their docstrings say
they would. **Restored** from `45c-prerevert/MobileEditorViewModel.swift` and
verified: `diff` reported no difference.

**Tripwire:** the trace did not run through `planVisibleTakeEdit`; untouched (§8).

---

## 3. Deliverable 2 — the live editor over a tombstone

**STATUS: DONE.** Fix + 4 pins in the tree; **red-on-old RUN and QUOTED**,
with both arms measured separately.

### The seam, traced

From §63: a note is open in the SHELF stack's `MobileWriteScreen`; she taps to
Library (the shelf editor stands down); she deletes that note from a Library
row; she taps back to Shelf. `MobileShellView.destination`'s note route passes
`onDeleted: { pop(in: owner) }`, but that fires only from the note's OWN ⋯ door
(`MobileNoteActions.swift:147` → `MobileWriteView.swift:374`) — the Library
row's delete never calls it, and popping the Library's stack would not reach the
shelf stack's screen anyway. **§49's filed fix reaches nothing**, as §63 says.

**[CORRECTED 2026-08-31 — the cold review's MINOR 3, measured]** This
section's original account of what that COST was is struck. It said the
pen let keystrokes *"autosave into a tombstoned note's variants — bytes
written where no listing will ever show them"*. **No byte was ever
written into a tombstone, pre-fix or post-fix.** `Operations.autosave`
resolves through `liveVariant`
(`Sources/VariorumCore/Operations/Operations.swift:78`), which throws
`variantNotFound` for a tombstoned variant, and `deleteContainer`'s
cascade tombstones the note's blocks and variants; the reviewer measured
both the op directly and the editor's own flush road. **The true defect:
the surface accepted keystrokes it could never save, and every flush
refused with a raw `variantNotFound(id: "…")` dumped into her status
line** (`String(describing: error)` at the autosave observer — pre-
existing, and now confirmed reachable on exactly this road). The
correction matters because a belt believed to stop CORRUPTION is weighed
differently from one that stops a confusing surface — which is what a
future session does when it revisits the `confirmNoteStillLive` swallow
(§10 point 4). Production comment and pin docstring corrected with the
code.

What DOES reach it: `tabDidBecomeVisible(.shelf)` → `takeLiveness(heir,
refresh: true)` → `noteLivenessGranted()`. That is the one act that hands a
surface the pen, so that is where the refusal belongs.

### What was built (one mechanism, four parts)

1. **The fact, from the ONE header door.** `MobileEditorViewModel.noteIsGone`,
   written in `adoptHeader` — the only place a store answer about this
   container arrives. `Queries.containerHeader` returns nil exactly when the
   row is missing or `deleted_at != nil` (verified at
   `Sources/VariorumCore/Queries/EditorSupport.swift:41–44`), and it is never
   called speculatively, so a nil answer is the store speaking, never "not
   loaded yet".
   **Deliberately NOT `isLive`:** `isLive` means *the authority granted the
   pen* and only the authority writes it; `noteIsGone` means *there is nothing
   here to write into*. Keeping them apart is what makes the resurrection road
   heal itself instead of stranding her on a restored note she cannot type in.
2. **The relinquish** (`adoptHeader`): first responder resigned and editability
   dropped the moment the note goes; editability restored if it comes back
   while this surface still holds the pen. Covers the road where the note dies
   UNDER a live editor (sync from the Mac; the ⋯ door a beat before its pop).
3. **The refusal at the seam** (`MobileLivenessAuthority.takeLiveness`): no pen
   for a gone note, **at entry** (cheap, on what the surface knows) **and after
   the suspensions** via `editor.confirmNoteStillLive()` — an authoritative
   store read immediately before the grant, in a road already doing store work,
   with `guard isCurrent(token)` after it (the A2 token discipline). A refused
   grant calls the new `standDownEveryone()` and leaves `live = nil` — legal,
   because the law is *at most* one live editor, never exactly one.
4. **The gate's belt** (`shouldChangeText`): refuses with
   `MobileEditorViewModel.deletedNoteRefusal`.
   **ORDER MATTERS AND WAS CORRECTED MID-BUILD:** the belt sits ABOVE the
   `!isLive` check. Placed below it, the pin caught the surface answering
   *"This note is live in your other tab"* about a note in the Trash — because
   the authority's refusal stands the surface down, making `!isLive` true too.
   The more specific truth wins, and it is the one with a road in it. ~~It sits
   above the seal for the same reason twice over: a note that no longer exists
   cannot be locked or unlocked.~~
   **[CORRECTED 2026-08-31 — the cold review's NIT 9]** That last clause was
   VACUOUS and is struck: when `noteIsGone` is true, `header` is nil, so
   `header?.locked == true` is false *whatever the order* — the seal belt
   could never have spoken for a gone note, and there was no ordering
   constraint against it to satisfy. The constraint against `!isLive` is
   real, and it is the one a pin caught.

**[AMENDED 2026-08-31 — the fix wave changed parts 3 and 4's behaviour.]**
Part 3's entry guard no longer refuses on `noteIsGone`: it **re-confirms**
with one indexed header read and refuses only if the store agrees (the
review's MAJOR 1 — refusing on the last delivery could strand her on a
note she had just Put back, and short-circuited the very read that would
have corrected it). The authoritative read moved **above**
`refreshTakesFromStore` (MAJOR 2 — that refresh renders a tombstoned
note's empty projection and wipes her words off the screen before
anything establishes there is nothing to show), a cheap non-stale belt
now guards the window the move opens, and the refusal **speaks**
`deletedNoteRefusal` through the status road from where it is decided —
part 4's gate belt could never reach that road, because the refusal drops
the keyboard and `shouldChangeText` runs only for an editable view. Three
pins were added; the full account is the cold-review file's **FIX WAVE
RESULTS**.

**Why the authoritative read and not the observation:** `observeContainerHeader`
is a delivery with real latency and a tab tap can land inside it. One indexed
row read per liveness grant — a tab tap or a push, never a keystroke.

**Copy, phone-local and recorded as such:** `deletedNoteRefusal` speaks about a
PHONE surface's own state (a Write screen left standing by the alive-stacks
shape), which the Mac has no twin of; `RecoveryCopy` is FENCED this batch
(read-only). It uses `TrashWindow.days`, never a literal. If the Mac ever grows
the same refusal it hoists this then (MobileSoul §3).

**No fenced file was needed** — the whole fix is in the two phone-local files
the brief named as candidates.

### Pins (`MobileLivenessTests.swift`)

| pin | what it holds |
|---|---|
| `aNoteDeletedOnTheOtherTabNeverGetsThePenBack` | **THE BRIEF'S OWN RED-ON-OLD SCRIPT** — delete from the Library tab, tab back, the gate refuses; keystroke driven through the REAL gate (`typeEdit`) |
| `aNoteDeletedUnderALiveEditorStopsAcceptingKeystrokes` | the relinquish half — the sync road, no tab tap mediating |
| `aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork` | isolates the ENTRY guard, via the coordinator's settle seam (see the measurement below) |
| `puttingTheNoteBackLetsItsSurfaceWriteAgain` | the healing control — **explicitly NOT a red-on-old pin** (see below) |

### RED ON OLD — production, and the arms MEASURED separately

**Revert R2 (whole item 2):** `noteIsGone = (value == nil)` → `noteIsGone = false`
in `adoptHeader`, which neuters every consumer at once.

```
✘ aNoteDeletedOnTheOtherTabNeverGetsThePenBack() … Expectation failed: (editors.live → VariorumMobile.MobileEditorViewModel) == nil
✘ … Expectation failed: !((shelf → …).isLive → true → true)
✘ … Expectation failed: (shelf → …).noteIsGone → false
✘ … Expectation failed: !(typeEdit((shelf → …), (shelfStorage → x{
✘ … Expectation failed: (shelf.statusMessage → nil) == (MobileEditorViewModel.deletedNoteRefusal → "This note was deleted — it's in the Trash for 30 days. Put it back there to keep writing.")
✘ Test aNoteDeletedOnTheOtherTabNeverGetsThePenBack() failed after 5.895 seconds with 5 issues.
✘ aNoteDeletedUnderALiveEditorStopsAcceptingKeystrokes() … noteIsGone → false
✘ … Expectation failed: !(typeEdit((model → …), (storage → x{
✘ Test aNoteDeletedUnderALiveEditorStopsAcceptingKeystrokes() failed after 2.082 seconds with 3 issues.
✘ Test run with 13 tests in 1 suite failed after 10.419 seconds with 9 issues.
```

**The line that IS the defect:** `Expectation failed: !(typeEdit(…))` — the
pre-fix gate **ACCEPTS** the keystroke into the tombstone.

**Revert R2a (the authority's two guards ONLY**, keeping the fact, the
relinquish and the gate belt): reds `aNoteDeletedOnTheOtherTabNeverGetsThePenBack`
with the same 5 issues, and **nothing else** — the other two pins stayed green.

**Revert R2a′ (ONLY the post-suspension `confirmNoteStillLive()`, keeping the
entry guard): reds the pin IDENTICALLY, same 5 issues.**

> **The measurement corrected an assumption, which is why it was run rather
> than traced.** On the tab-tap road the **post-suspension authoritative read
> carries the pin alone**; the entry guard fires there not at all, because in
> the harness nothing has told the surface yet (no observation loop runs).
> So `aNoteDeletedOnTheOtherTabNeverGetsThePenBack` proves the PAIR, not its
> arms — and the entry guard would have shipped **un-pinned**. That is what
> `aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork` was added for: it
> drives the road where the surface ALREADY knows, and watches the WORK (zero
> autosave settles) rather than the outcome, because the outcome is identical
> either way — the second guard catches it.

**`puttingTheNoteBackLetsItsSurfaceWriteAgain` is NOT a red-on-old pin and its
docstring was corrected to say so.** Under R2 it fails only at its own
`noteIsGone` precondition — machinery that did not exist pre-fix — which is not
evidence about a defect. It is a control against a WRONG FIX: an implementation
that latched `isLive` would fail it.

**Restored** from `45c-prerevert/` and verified byte-identical by `diff` for
both files after every revert.

### One test-authoring correction worth recording

`puttingTheNoteBackLetsItsSurfaceWriteAgain` first typed at the document's very
END and the stored text did not change. Traced, not guessed: an empty render
leaves a zero-length OPEN TAIL behind it, so the keystroke landed in the tail
and waited on a crystallization instead of reaching the variant. Shipped
behaviour, nothing to do with this fix; the pin now types INSIDE the block and
says why.

---

## 4. Deliverable 3 — `MobileLenses` "Rename Lens" (SETTLE OR RECORD)

**STATUS: DONE. ROAD TAKEN: (b) — convert the site to the `presenting:`
shape**, which moots the question rather than re-answering it.

### Why (b), and why NOT (a) "settle it with a real driven tap"

**A driven tap is provably unavailable in process**, and the harness's own
measured header says so on both counts:

- the door's OPENER is a `.contextMenu` row —
  `MobileSurfaceDriver.swift`: *"A `.contextMenu` (long-press) row is likewise
  undrivable in process"*, and *"**A SwiftUI `Menu`'s rows are NOT reachable**:
  … the accessibility tree comes back EMPTY"*;
- even if it opened, `tapAlertAction(_:writeBack:)` requires the caller to
  perform the write-back *"through the very binding SwiftUI writes"* — and
  here that binding is computed over the VIEW's own `@State renamePrompt`,
  which no test can write. The three doors 4.5b fixed were reachable precisely
  because their state lived on a MODEL (`model.xPresented`).

That is also the concrete reason §63's probe *"could not drive a genuine tap"*
— so re-attempting it would have re-derived the same wall.

### What changed

`.alert("Rename Lens", isPresented:)` gained `presenting: renamePrompt` and its
action closure now takes the subject as a PARAMETER, so the handler no longer
reads `renamePrompt` back after SwiftUI's dismissal machinery may have cleared
it. `renameField` is still read synchronously and is safe by the same rule read
forwards: nothing clears it at dismissal.

**Disposition of the §63 question:** the site was reported *"not in the affected
class — but NOT PROVEN IMMUNE"*. It is now immune **by shape**, so the proof is
no longer needed. That is the honest end state for a site whose only remaining
question was about SwiftUI's ordering.

### NO PIN — declared hollow, not manufactured

A behavioural pin would need to mount a door that cannot be mounted in process
(both halves above). Any pin that appeared to cover this would be green over
nothing — the failure mode this round has caught six times. **Recorded as
unpinnable-by-construction rather than papered over.** The conversion is
compile-verified and the whole `MobileLensesTests` suite passes unmodified
(**10** tests — *[CORRECTED 2026-08-31, the cold review's NIT 7: this read
"11"; the file holds 10 `@Test`s, which §9's own `23 tests in 2 suites` for
deletion + lenses confirms as 13 + 10. **REASON RE-STATED the same day,
round-2 NIT R2-5:** the first correction said "and no `arguments:`", which is
false — `MobileLensesTests.swift` carries three (`:52`, `:373`, `:456`), **all
three GRDB SQL arguments and none on a `@Test` macro**, so the count of 10 is
right for the reason the reviewer states and a future `grep -c 'arguments:'`
check must not trip on the old wording. Re-derived the same way for the other
three suites — liveness 17, takes 19, deletion 13 — every `arguments:`
occurrence is SQL]*), which is
the available evidence that nothing regressed. *(The fix wave then deleted
`RowPrompt.currentName`, written at the opener and read nowhere — the
review's NIT 10, residue of this very conversion.)*

---

## 5. Deliverable 4 — `deleteNoteRefusal` → the shared vocabulary

**STATUS: DONE.** Forwarder + 1 pin; **red-on-old RUN and QUOTED** below.

`MobileEditorViewModel.deleteNoteRefusal` now forwards to
`DeletionRefusal.words(error, act: .delete)` — the last `String(describing:)`
fallback in that door's family (A1-18's 4.5c share). `act:` is passed
explicitly because the same `OperationError` wants different words at a delete
door and a put-back door.

**SCOPE, STATED HONESTLY — this is a contract change, not a road change.**
`deleteContainer`'s only reachable refusal is `containerNotFound` (its body's
one guard is `liveContainer` — read at
`Sources/VariorumCore/Operations/Operations+Container.swift:383`), and BOTH
tables word that identically (*"That note is already gone."*). So **nothing she
can currently reach changes**, and the existing
`deletingAnAlreadyGoneNoteSpeaksPlainly` / `aRefusedDeleteIsSpokenOnTheSheet
ThatRaisedIt` pins pass unmodified — which is the proof. What closed is the
FALLBACK: the next refusal this op learns to throw arrives as a sentence
instead of `lockedPost(id: "…")`.

**Pin:** `MobileDeletionTests.theNoteDeleteDoorSpeaksTheSharedDeletionVocabulary`
— asserts the door's output equals the shared vocabulary's for four errors
(including two the old table dumped), that no output carries `OperationError`
or an associated value, and that the one always-mapped sentence did NOT change.

### RED ON OLD — production (`MobileEditorViewModel.deleteNoteRefusal`) — RUN

Revert R3: the pre-fix table restored (`guard let error = error as? OperationError
… case .containerNotFound … default: String(describing: error)`).

```
✘ theNoteDeleteDoorSpeaksTheSharedDeletionVocabulary() … Expectation failed: (spoken → "lockedPost(id: "p1")") == (DeletionRefusal.words(error, act: .delete) → "This note is marked complete — unseal it first.")
✘ … Expectation failed: !((spoken → "lockedPost(id: "p1")").contains("id: \"" → "id: "") → true)
✘ … Expectation failed: (spoken → "containerNotDeleted(id: "c1")") == (DeletionRefusal.words(error, act: .delete) → "That note is already back.")
✘ … Expectation failed: (spoken → "variantNotFound(id: "v1")") == (DeletionRefusal.words(error, act: .delete) → "That take is already gone.")
✘ Test theNoteDeleteDoorSpeaksTheSharedDeletionVocabulary() failed after 0.025 seconds with 6 issues.
✘ Test run with 13 tests in 1 suite failed after 17.016 seconds with 6 issues.
```

**The dumps are right there in the output** — `"lockedPost(id: "p1")"` is what
this door would have shown her. And the OTHER 12 tests in that suite passed on
the reverted tree, which is the positive proof of the scope claim above: the
`containerNotFound` sentence did not change, so no shipped road moved.

**Restored** from `45c-prerevert/` and verified byte-identical by `diff`.

---

## 6. Deliverable 5 — the stale test comment

**STATUS: DONE.** `MobileCrossBlockEditTests.swift`, two sites (the brief named
one; the second is the same staleness three hundred lines away in the same
file, and leaving a known-stale sibling beside a fix is the drift class):

- `:598`'s assertion message *"there is no undo door on this phone yet"* — false
  since **M20 (batch 4)**, which shipped `MobileUndoDoor` with a rendered label
  in the masthead and the ⋯ sheet. **The ASSERTION was right and its REASON had
  gone stale under it:** what the phone has no culture of is CHORDS, so copy
  naming ⌥⌘Z would point her at a Mac keystroke this surface cannot receive
  (the no-redirect principle). Message now reads *"the phone has no chord to
  name"*, with the history in a comment above it.
- `:391`'s docstring *"a future undo door on this phone"* → the door exists;
  corrected with the same citation.

Zero behaviour change; no pin owed.

---

## 7. Deliverable 6 — THE DEFERRAL, RECORDED (build nothing)

**STATUS: DONE — this section IS the deliverable.**

**The A7/#34 seam carves — backspace-to-join at a block seam — stay UNWIRED on
the phone, by this ruling, and the reason is a decision rather than an
oversight.** §45's batch-3 review filed the gap as a fifth refusal case that
§31's four-case table omits: on the phone, backspace at a block seam refuses
because the carve was never wired. Wiring it now would do one of two harmful
things. It would either **harden a refusal 13u is about to open** — her 13u
item 5 ruling (2026-08-21) settles that cross-block edits *stop refusing*, that
the edge-join **merges** mid-paragraph and **does not** at a paragraph break,
and that the fanned case is RULED OPEN — or it would **invent the join's
semantics on the phone first**, against her own fence that *"the phone does not
invent its own answer"* and against her sequencing principle that the Mac
phases run first so the shared brain is solid. A seam carve IS a cross-block
join by another name, so it is the same question, and 13u1 owns it for both
platforms (the master plan's 13u split assigns items 5/7/8/12 there precisely
because they rewrite one seam and belong together).

**So the post-13u-merge mobile session inherits a DECISION, not a discovery**
(the #94 pattern): the carve is not missing because nobody looked — it is held,
deliberately, until 13u1 rules what a join means, and then the phone composes
to that rule rather than to one of its own. What that session should do first
is read 13u1's ruling and check it against `mobile-round-2.md` §31's four-case
table, which will need a fifth row written by whatever 13u1 decided.

---

## 8. Fences, tripwire, hygiene

Verified with the tree in its committed shape:

```
$ git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"
(empty)
$ git diff -- '*.swift' | grep -c planVisibleTakeEdit
0
```

- **ZERO** changes under `Sources/`, `App/Variorum/Shared/`,
  `App/Variorum/Variorum/` (the Mac target), `EditorBrain/`, schema/migrations,
  build configs. `Shared/RecoveryCopy.swift` and `Shared/RecoveryActs.swift`
  were READ and CALLED, never edited.
- **`planVisibleTakeEdit`: ZERO Swift hits**, and no item's trace ran through
  it. 13u1 owns its neighbourhood (and the surviving O(N²) violation in it,
  which is that phase's, not this batch's).
- `Package.resolved` untouched; no `.bak-*` files; the real store never touched;
  no Release build, no install, no push.

**Files touched (7 source + this record):**

| file | items |
|---|---|
| `VariorumMobile/Features/Write/MobileEditorViewModel.swift` | 1, 2, 4 |
| `VariorumMobile/Features/Shell/MobileLivenessAuthority.swift` | 2 |
| `VariorumMobile/Features/Takes/MobileLenses.swift` | 3 |
| `VariorumMobileTests/MobileTakesTests.swift` | 1 (3 pins + helper) |
| `VariorumMobileTests/MobileLivenessTests.swift` | 2 (4 pins) |
| `VariorumMobileTests/MobileDeletionTests.swift` | 4 (1 pin) |
| `VariorumMobileTests/MobileCrossBlockEditTests.swift` | 5 (comments only) |

---

## 9. Suite

**Baseline: 667/99 green with 2 known issues** (batch 9's unit close).

**Per-suite runs, all GREEN:**

```
✔ Test run with 14 tests in 1 suite passed after 0.590 seconds.   (MobileLivenessTests)
✔ Test run with 32 tests in 2 suites passed after 0.726 seconds.  (MobileLivenessTests + MobileTakesTests)
✔ Test run with 23 tests in 2 suites passed after 20.843 seconds. (MobileDeletionTests + MobileLensesTests)
```

**[CORRECTED 2026-08-31 — the cold review's NIT 7]** This block was headed
*"all GREEN on the final tree"* and the middle line is not from the final
tree: `MobileLivenessTests` + `MobileTakesTests` hold **14 + 19 = 33** there,
so `32` (13 + 19) predates the fourth liveness pin. The run happened and was
green; the *final-tree* claim was the error. The other two lines and the full
suite below are final-tree and were independently reproduced by the reviewer.
*(The fix wave's three new pins move `MobileLivenessTests` to 17 and the full
suite to 678 — its own section carries those runs.)*

**FULL SUITE — RUN, GREEN. The exact final line:**

```
✘ Test run with 675 tests in 99 suites passed after 311.186 seconds with 2 known issues.
** TEST SUCCEEDED **
```

*(Swift Testing marks a run carrying known issues with `✘` while reporting it
`passed`; `** TEST SUCCEEDED **` is the verdict.)*

**Against the baseline — 667 tests / 99 suites, green with 2 known issues:**

| | baseline | now | delta |
|---|---|---|---|
| tests | 667 | **675** | **+8 — exactly this batch's pins** (3 takes · 4 liveness · 1 deletion) |
| suites | 99 | 99 | 0 — every pin joined an existing suite |
| known issues | 2 | 2 | 0 — the same documented diagnostic (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, which records issues BY DESIGN) |

**Neither of the two conditions the brief warned about occurred, and both were
watched for:** the load-flaky perf pin
`MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`
did **not** red (no isolated re-run needed), and there was **no runner restart**
— the log carries no `Restarting after unexpected exit, crash, or test timeout`
line, which the item-1 red-on-old run had shown this harness does print when it
happens.

**Simulator teardown: DONE** — `V45cPhone-17-26`
*[removed for publication]*
`Variorum-batch6a` simulator from an older batch was left alone.

---

## 10. For the cold reviewer

**Where to look hardest, in the order I would look:**

1. **The gate's guard ORDER** (`shouldChangeText`). The tombstone belt sits
   above `!isLive` and above the seal, and the reason is that the authority's
   own refusal stands the surface down — so below the liveness belt this door
   answers the wrong true sentence. This was caught by a pin, not by reading;
   check the reasoning holds for roads I did not drive.
2. **`adoptHeader`'s two-directional relinquish.** It touches first responder
   and editability but deliberately NOT `isLive`. Ask whether the restore
   branch's conditions (`isLive`, `!takesBrowser.isOpen`) are the right set,
   and whether a surface whose note is resurrected while the takes browser is
   open ends up correct.
3. **The authority's entry guard is pinned only by a WORK-shaped assertion**
   (zero autosave settles), because its outcome is indistinguishable from the
   post-suspension guard's. If you think that pin is weak, the honest
   alternative is deleting the entry guard and relying on the authoritative
   read — say so; I kept it because it avoids a flush and a projection re-read
   for a note already known gone.
4. **The `confirmNoteStillLive()` swallow.** A failed read is treated as "not
   an answer" and the last store answer stands. Consider the case where the
   store cannot be opened at all: the surface keeps the pen. I judged that
   right (refusing to write is not obviously safer than writing to a store you
   cannot read), but it is a judgment.
5. **Item 3's no-pin declaration.** If you can find an in-process road to that
   `contextMenu` + `@State` alert that the harness header says does not exist,
   the conversion should get a real pin.
6. **Item 4's scope claim** (§5) — I assert `containerNotFound` is
   `deleteContainer`'s only reachable refusal, from reading its body's one
   guard (`liveContainer`). If a road exists that makes it throw anything else,
   that item stops being a contract change and becomes a road change, and its
   pin should grow accordingly.

**What I deliberately did NOT do:** anything in `Shared/EditorBrain/`, the fan
fence's source, the O(N²) twin, the gap fence's Mac face, the empty-block plan,
`CrossBlockRefusal`'s hoist, the identity-audit hoist — all 13u's, per the
brief's supersession banner — and the A7/#34 seam carves, deferred by ruling
(§7).

---

## 11. Added by the fix wave (2026-08-31) — two dispositions this record owes

- **MINOR 4 — the three sheets' `isEditable` PHOTOGRAPH is ROUTED, not fixed
  here.** `MobileTakesBrowserView` / `MobileCommentsSheetView` /
  `MobileBlockHistorySheetView` each capture `page.isEditable` at open and
  restore it unconditionally at close, so a note that dies while a sheet is up
  gets its keyboard handed back over a tombstone — the inverse leak of the
  stranded-false defect batch 9 found in the same three lines. It is ONE class
  with ONE ruled fix (the nesting-aware editability authority), so fixing half
  of it here would have built machinery that fix then replaces. The clause
  naming this direction now rides that owned row in
  `mobile-round-2-handoff-2026-08-30.md` §7.2, with the note that the
  authority must DERIVE editability at rest rather than restore a
  photograph — a depth count alone would leave this direction leaking.
- **NIT 8 — `confirmNoteStillLive`'s swallow is ENDORSED and its silence is
  now a recorded decision.** §10 point 4 flagged it as a judgment; the review
  assessed it right and on firmer ground than this record knew, because MINOR 3
  measures that no write can reach a tombstoned note by any road — so "keeps
  the pen on a failed read" cannot cost a byte, while refusing would strand
  her on a note that is probably fine. Its two speaking siblings (`loadOnce`,
  `observeHeader`) are the roads that were going to PAINT something; this one
  is a belt inside a handoff. A comment at the catch says so. **No behaviour
  changed.**
