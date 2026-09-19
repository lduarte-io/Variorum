# 13u3 LADDER ROUND 1 — THE IMPLEMENTER-SIDE RESPONSES (opus, 2026-09-19)

**What this is:** the cross-model flow's implementer half. The cold reviewer's findings R1-1…R1-6
(`notes/plans/13u3-ladder-round1.md`) were delivered verbatim; each one below carries an
INDEPENDENT trace made in the code, then AGREE or DISPUTE. **Nothing was fixed in this pass** —
under the standing cross-model rule the reviewer makes the final call on each finding and
implements the confirmed fixes in its own session. The only file this pass writes is this one.

**The hallucination guard binds in both directions**, so no finding below is agreed on the
reviewer's say-so: every mechanism was re-walked from its entry point, and where my trace
DIFFERS from the finding's supporting text I say so even when the finding itself stands
(R1-3 is the one case — the defect is wider than the finding scopes it).

**Verdicts at a glance**

| # | Sev | Verdict |
|---|-----|---------|
| R1-1 | MAJOR | **AGREE** — chain confirmed line by line; the codebase states the broken rule at a sibling call site; pre-existing confirmed by the diff. Two cautions for the fix. |
| R1-2 | MINOR | **AGREE** — guard order confirmed against `setTakeLabel`; both consequences reachable; the existing seal pin provably cannot catch it. One adjacent observation the fix does NOT close. |
| R1-3 | MINOR | **AGREE on the finding, DISPUTE its scoping.** Write is not "the one missed cell" — Takes/Lenses share it by an ordinary click, and Canvas/Compare warrant the same check. Evidence below. |
| R1-4 | NIT | **AGREE** — neither case exists; the route is exactly as described; race-only reachability confirmed. |
| R1-5 | NIT | **AGREE** — `displayed` is provably unread on the plain road; the drift check is what makes the promise true. Doc-only. |
| R1-6 | NIT·SPEC | **AGREE with the SPECULATIVE label** — the structural gap is real and the hardening is right; the *cause* remains unproven and I could not prove it either. One caution on the one line. |

---

## R1-1 · [MAJOR] · the decoration refresh forced TK2 layout estimation synchronously inside `processEditing`

**AGREE.** Confirmed, and the codebase already states the rule this arm breaks — at a sibling
call site, in its own words.

### My independent trace (entry → wrong behaviour)

1. `EditorSurfaceDelegate.textStorage(_:didProcessEditing:range:changeInLength:)` —
   `App/Variorum/Variorum/Features/Editor/EditorView.swift:667–676`. It is
   `nonisolated`, guards `.editedCharacters`, and calls `model.storageDidEdit` inside
   `MainActor.assumeIsolated` (`:673–674`). This runs **inside** `NSTextStorage.processEditing`.
2. `EditorViewModel.storageDidEdit` — `EditorViewModel.swift:1170`. It bumps
   `overlayGeometryGeneration` at `:1176` (before the `suppressEditProcessing` guard), applies the
   verdict, restyles markdown, runs the identity oracle, and ends at `updateCaretContext()`
   (`:1279`).
3. `updateCaretContext` — `:3281`. The block-walk sets `caretBlockID`/`caretVariantID`, then at
   **`:3336–3337`**: `if appearance.indicator != .off, caretBlockID != previousCaretBlock {
   refreshDecorations() }`. This is the **only** `refreshDecorations()` call site reachable from
   inside `storageDidEdit` (I enumerated all ten: `:216`, `:225`, `:542`, `:547`, `:3009`, `:3016`,
   `:3025`, `:3337`, `:3420`, `:3497` — appearance/pointer `didSet`s, block-selection acts, the
   settle hop's `defer`, and `pushDecorationsToSink`; none of the others rides a storage edit).
4. `refreshDecorations` — `:3509`. `needsFrames` is true by the arm's own condition
   (`appearance.indicator != .off` is its second clause), so the walk is NOT skipped, and it
   immediately calls `offsetAt(y: visible.minY + 1)` (`:3560`).
5. `offsetAt(y:)` — `:3553–3556` — calls `layoutManager.textLayoutFragment(for:)`. That is a
   layout-**forcing** geometry query, and the sample's frames name exactly its interior:
   `ensureLayoutForBounds:` → `_estimatedTextLocationForVerticalOffset:`.

**The sample corroborates the arm, not merely the function.** The UNIT B record's stack goes
`updateCaretContext` → `refreshDecorations`, and `:3336` is the only edge between those two
frames — so the condition was true in that instance, i.e. the editing indicator was ON and the
caret had changed blocks. That is independent confirmation of *which* arm fired, which I would not
have from the function names alone.

### The codebase states the broken rule itself

`EditorView.swift:584–592`, the inline editor's re-measure observer on the same notification:

> `// didProcessEditing fires INSIDE the edit transaction;`
> `// geometry reads must wait for it to close.`
> `DispatchQueue.main.async { self?.remeasure() }`

One sibling road on the same notification already hops to the next turn *for exactly this reason*.
The indicator arm does not. That is a stronger justification than TEXTKIT2 §2 alone, because it is
this project's own ruling on this project's own seam.

### The redundancy claim is true

`EditorTextView.viewWillDraw` (`EditorTextView.swift:388–391`) calls `onLayoutSettle?()`, wired at
`EditorViewModel.swift:387` to `overlayLayoutDidSettle()` (`:3380`). Its gate is
`overlayGenerationDelivered != overlayGeometryGeneration` — which `storageDidEdit` guaranteed to
differ at `:1176` — and its async body runs `refreshBadges()` (`:3419`), whose first line is
`defer { refreshDecorations() }` (`:3420`). **So every storage edit already schedules a
post-layout decoration refresh for the same generation.** The synchronous call buys one runloop
turn of indicator latency — a latency every other edit-driven decoration on this surface already
has — at the price of a documented estimation hazard inside the edit transaction.

### Pre-existing: confirmed against the diff, not the record

`git diff 98696c81..HEAD -- EditorViewModel.swift` is four hunks: the `savepointAsk` property
(`:142`), UNIT D's ask/file doors (`:3057–3095`), and A1's **retirement** of
`proseColumnDidChange` (`:3485`). `updateCaretContext`, the indicator arm, `refreshDecorations`,
`needsFrames` and `offsetAt` are **byte-untouched by this phase**. A1 removed a *settle-hop*
trigger, never the synchronous road. MAJOR-not-BLOCKER is the right call on the prompt's own
rubric.

### Two cautions for the fix pass (the reviewer's, since it owns the fix)

1. **`updateCaretContext` is called from eight sites** (`:1279`, `:1706`, `:2097`, `:2198`,
   `:2202`, `:2468`, `:2540`, plus `textViewDidChangeSelection` at `EditorView.swift:660`). Only
   `:1279` is inside the edit transaction, so a flag/parameter on that one call is the minimal
   correct scope — but note the **interaction**: after a typing edit, `storageDidEdit` already
   updated `caretBlockID`, so the selection-change call that follows sees
   `caretBlockID == previousCaretBlock` and will *not* re-fire the arm. The indicator refresh for
   that edit therefore comes from the settle hop or from nowhere; the fix must not also gate the
   settle hop (it does not today — `refreshBadges`' `defer` is unconditional).
2. **Caret staleness at `:1279` is real and should not be "fixed" as part of this.** During
   `didProcessEditing` the text view's own selection adjustment has not necessarily run, so the
   caret read there can lag the edit. That is why the arm can fire on edits that look like they
   stay in one block — and it is also why the *later* selection-change call can fire the arm
   outside `processEditing` (safe from `NSTextStorage` re-entrancy, still pre-layout). Rerouting
   `:1279` is a strict improvement either way; changing the caret read is a separate question and
   not this finding's.

**Severity calibration, recorded honestly:** `EditingIndicatorStyle`'s default is **`off`**
(`Sources/VariorumCore/Models/Enums.swift:164–171`, "OFF is the default"), so the arm is gated on
a non-default setting she has turned on. This does not weaken the mechanism — it was met in a real
walk on a real store — but it is the fact that keeps this MAJOR rather than BLOCKER, and it
belongs in the disposition.

---

## R1-2 · [MINOR] · `renameCommitPoint`'s no-op guard runs above the seal/liveness guards

**AGREE.** The order is exactly as stated, the convention it claims to follow does the opposite,
and the existing pin provably cannot catch it.

### My independent trace

`Sources/VariorumCore/Operations/Operations+Variant.swift:101–113`:

```swift
public func renameCommitPoint(_ commitID: String, message: String?) throws {
    try database.write { db in
        guard var commitPoint = try CommitPoint.fetchOne(db, key: commitID) else {
            throw OperationError.commitNotFound(id: commitID)
        }
        let normalized = SavepointName.normalized(message)
        guard commitPoint.message != normalized else { return }   // ← the no-op guard
        let variant = try liveVariant(db, commitPoint.variantId)  // ← liveness
        try ensurePlacementUnlocked(db, blockID: variant.blockId) // ← the seal
        …
```

`setTakeLabel` (`:418–428`), the precedent the doc names, is the mirror image:

```swift
var variant = try liveVariant(db, variantID)
try ensurePlacementUnlocked(db, blockID: variant.blockId)
…
guard variant.label != normalized else { return }
```

So the op's own doc comment — *"Identity-level metadata on the `setTakeLabel` / `setBlockName`
conventions, which this follows **to the letter** so the three cannot drift"* (`:75–77`) — is
false for the one thing that distinguishes them.

### Both consequences are reachable from the shipped face

- **The seal.** `BlockHistoryPane.swift` contains **no** occurrence of `locked` or `seal`
  (grepped: zero hits) — the rename door is not gated on the seal, so on a sealed note the door
  opens. `BlockHistoryModel.rename` (`:297–309`) runs the op and, on a non-throw, sets
  `status = .receipt(BlockHistoryCopy.renamed(…))` — i.e. *"Saved moment named “…”."*
  (`App/Variorum/Shared/BlockHistoryFace.swift:188–197`). Pressing ⏎ with the seed **unedited**
  therefore speaks a receipt under a seal; changing one character throws `lockedPost` and speaks
  the seal sentence. One door, two answers under one seal, decided by whether she touched the
  text.
- **The tombstoned take.** `liveVariant` is what raises `variantNotFound`; skipping it makes the
  documented refusal at `:98–100` untrue for the same-name case.

### The existing pin cannot catch it — verified, not assumed

`Tests/VariorumCoreTests/SavepointNameTests.swift:155–166` (`aSealedPostRefusesRenaming`) renames
to `"too late"` on a fixture savepoint whose `message` is `nil` (the cell's own post-condition
asserts `message == nil`). A changed name never reaches the short-circuit, so the guard order is
invisible to it. Same for `aMissingSavepointAndADeadTakeBothRefuse` (`:210–228`), which renames to
`"gone"`. The reviewer's proposed red-on-old — sealed post + **unchanged** name, expecting
`lockedPost` — is a genuine red on the current tree and green after the three-line move.

### One adjacent observation the fix does NOT close (offered, not asked for)

Moving the guard does not touch the **unsealed** no-op's face: opening the door on an unnamed
savepoint and pressing ⏎ with an empty field yields `normalized == nil == current`, a silent
return, and the receipt *"Name cleared — the saved moment itself is untouched."* — a receipt that
names an act that did not happen, on a savepoint that had no name to clear. That is a face-level
copy question one grain away from 18i's grammar, not the op's; I record it here rather than
raising it as a finding, because it is the reviewer's call whether it rides this fix or a row.

---

## R1-3 · [MINOR] · ⌘S on a SEALED note opens a name field over a gesture that cannot file

**AGREE on the finding. DISPUTE its scoping** — the sentence *"the Write editor's seal state is
the one missed cell"* is not what the code says. Three of the other four doors share the same
shape under a seal, and one of them reaches it by an ordinary click. The fix is owed wider than
one guard.

### My independent trace of the finding itself

`EditorViewModel.swift:3067–3078`:

```swift
func commitCaretVariant() { askSavepointName() }

func askSavepointName() {
    guard let variantID = caretVariantID else {
        refuse("Place the caret in a block to commit.")
        return
    }
    savepointAsk = .naming(variantID: variantID)
}
```

- **The chord is ungated.** `EditorTextView.performKeyEquivalent` (`:827–835`) fires
  `onCommitShortcut` on ⌘S with no editable/locked test; it is wired at
  `EditorViewModel.swift:403`. The menu/registry road is `EditorView.swift:334–336` (`case
  .commit`). Neither consults the seal.
- **The caret still resolves under a seal.** The seal sets `textView?.isEditable = false`
  (`:770`), which does not clear the selection or the index, so `updateCaretContext` populates
  `caretVariantID` from `index.entries` exactly as on an unsealed note. The guard passes.
- **The bar is the only door that knows.** `CommitBar.swift:517–519` and `:546–547`:
  `.disabled(model.caretVariantID == nil || model.header?.locked == true)`. So the fact is
  available on the model — one guard, as the finding says.
- **The regression is real against the shipped tree.** The diff's own `-` line is
  `func commitCaretVariant() { Task { await commitCaret() } }` → `ops.commit` → `lockedPost` →
  `showOperationError`, i.e. the seal sentence at the keypress. Nothing lands wrongly now (the
  refusal still arrives after ⏎), so MINOR is right — this is P-2 grammar, not a data defect.
- **The unit's own pin does not cover it.** `SavepointNamingTests.swift:219–230`
  (`theDoorRefusesBeforeItOpensAFieldItCannotFile`) drives the **open-tail** state
  (`caretVariantID == nil`) only.

### Where my trace departs from the finding's supporting text

The finding argues the siblings are clean: *"Takes `askSavepointName` guards `focusedPane`;
Canvas/Compare guard `authority.livePane` … each refuse before opening the field in their
unfileable state."* Under a **seal** they do not, and here is the evidence:

1. `TakesViewModel.focusedPane` is **the raw stored pointer**, not the sealed-aware answer:
   `App/Variorum/Variorum/Features/Takes/TakesViewModel.swift:101` —
   `var focusedPane: PaneKey? { authority.livePane }`. The sealed-aware answer is a *different*
   member: `isPaneLive` (`:333–335`), `let frozen = projection.sealed || structuralInFlight;
   return authority.isLive(key, sealed: frozen)`.
2. **Nothing blurs on a seal.** `PaneTextAuthority.blur()` (`Surface/PaneTextAuthority.swift:95`)
   is called from teardown/mode-exit sites only (grepped: `BlockTOCView:235,245`,
   `CompareBoardView:386,538,578`, `TakesViewModel:599`, `CanvasViewModel:161,684`,
   `BookIndexEditModel:84`). `TakesViewModel.toggleSeal()` (`:1650–1658`) does not blur.
3. **A click under a seal still sets `livePane`.** `TakesBoardView.focusPane`
   (`TakesBoardView.swift:1494–1497`) calls `model.focus(PaneKey(...))` unconditionally; the card
   wires it as `onFocus:` (`:978`, `:1425`) with no seal test, and `TakesViewModel.focus`
   (`:568–585`) has none either — the seal is consulted only by `isPaneLive`, which decides
   whether the pane *renders* live.

So on a sealed note: click a take card (it renders read-cheap, correctly), press ⌘S →
`focusedPane` is non-nil → `savepointAsk = .naming(...)` → the field opens over a gesture that
`commitFocusedTake` will refuse. That is R1-3's exact shape on **Takes and Lenses** (one model,
one bar), reached by an ordinary click rather than a race. `CanvasViewModel.askSavepointName`
(`:718–724`) and `CompareBoardView`'s (`:775–781`) read `authority.livePane` the same raw way and
warrant the same check; I traced the Takes road end to end and did not stage the other two.

**Stated plainly:** this is a code trace, not a use verification — I did not run the app (this
pass fixes nothing and walks nothing). The finding stands as written; its *scope* is what I
dispute, and the practical consequence for the fix pass is that `projection.sealed` (already read
at `TakesViewModel.swift:1651`) is the same one-line fact there that `header?.locked` is in Write.
Whether the siblings ride this fix or a row is the reviewer's final call.

---

## R1-4 · [NIT] · `commitNotFound` / `variantNotFound` still fall to the `default:` enum dump

**AGREE.** Both facts check out exactly.

- `App/Variorum/Variorum/Registry/OpsRefusalCopy.swift` contains **no** `commitNotFound` and no
  `variantNotFound` case (grepped: zero hits in the file), and the switch ends
  `default: return "Refused: \(error)"` (`:520–521`). No face anywhere in `App/` references
  `commitNotFound` either.
- The route is as described: `BlockHistoryModel.rename` (`BlockHistoryPane.swift:305`) →
  `TrayRefusalCopy.message(for:)` (`TrayPanel.swift:734–739`, which special-cases only
  `lockedPost`) → `OpsRefusalCopy.message(for:)` → the dump. It is precisely the class UNIT H
  closed for `variantIsChosen` (`OpsRefusalCopy.swift:363–377`, whose comment records the same
  `default:` dump).
- **Reachability is race-only, as classed.** The savepoints region lists LIVE takes' runs (the
  pane's own header, `BlockHistoryPane.swift:16–21`), so `variantNotFound` needs the take to die
  under the open ask; `commit_point` has no `deleted_at` at all (AppSpec §14 item 4), so a
  savepoint can only *vanish* through 13j's physical purge. NIT is the right severity, and the
  two worded cases + copy-table cells are the right fix.

---

## R1-5 · [NIT] · the `displayed:` comment overstates what it binds on the plain road

**AGREE.** Doc-truth, exactly as characterised; nothing wrong lands.

### My independent trace

- The comment: `EditorSurfaceController.swift:743–747` — *"the SHEET passes the ids its list marks
  … so what she was shown is what joins."*
- The plain road ignores `displayed` entirely: `MergeArrangement.swift:196–204` — the `else` arm
  of `MergeChainRun.run` calls `try ops.merge(mergedID, next)` and reads none of `displayed`
  (`displayed[next]` appears only in the `bringEveryTake` arm's `CarryAllMerge.compose` call at
  `:182–184`).
- `Operations.merge` resolves from the store at op time:
  `Sources/VariorumCore/Operations/Operations+Structural.swift:931–932` —
  `let head = first.rendered.workingText` / `let tail = second.rendered.workingText`, where
  `first`/`second` come from `placedContext(db, blockID:)` (`:888–889`). So the joined text is the
  store's rendered take, full stop.
- The promise is in fact made true for that road by the **drift check**:
  `refreshMergeRunIfDrifted` (`EditorSurfaceController.swift:1772–1797`) re-reads through
  `runFansAndRendered` and compares `read.blocks != state.runBlocks` — the whole rows, shown ids
  included — rebuilding the list or refusing before the confirm proceeds. Modulo the recorded
  sub-ms confirm-to-transaction window, which is the standing honestly-unpinnable class
  (`shelveInDailyJournalBook`'s own residual, AppSpec §9).

A future reader could weaken that check believing `displayed` fences the plain road; one sentence
at the parameter naming the plain road's actual protection is the right, pin-free fix.

---

## R1-6 · [NIT · SPECULATIVE] · the chip's adopt does not return key focus

**AGREE, including the SPECULATIVE label.** The structural gap is real; the cause is unproven and
I could not prove it either.

### My independent trace

- Both call sites toggle a flag and nothing else: `QuickEntryBar.swift:239–243`
  (`box.titleFromFirstWords.toggle()`) and `QuickNoteView.swift:234–238`
  (`pad.titleFromFirstWords.toggle()`). Neither touches `focusRequest`.
- `CaptureTextView.focusRequest` (`Core/Views/CaptureTextView.swift:150`) is the counted one-shot;
  a change drives `Coordinator.takeFocus()` (`:222–224`), which is
  `window.makeFirstResponder(view)` (`:281–284`). Its doc explicitly anticipates **multiple
  askers** ("a counter rather than a Bool because the two askers are different in kind"), so a
  third asker is the design's own shape, not a strain on it.
- ⏎ files only through the text view: `CaptureNSTextView.onFile` is wired in `makeNSView`
  (`:164–166`) and raised from the view's one key override. If keys are elsewhere, `CaptureKeys`
  never sees the ⏎ — which is the candidate mechanism.
- **Why it stays speculative:** the chip is a SwiftUI `Button` with `.buttonStyle(.plain)`
  (`VoicedChip`, `Theme/VoiceControls.swift:105–119`). On macOS a plain SwiftUI button is not
  normally in the key view loop and does not ordinarily take first responder on click (it does
  under Full Keyboard Access). I could not confirm the steal, and the walk note itself
  (`phase-13u3-faces.md`, the acceptance walk's note (a)) records it as unreproduced and
  "ambiguous focus-vs-app". So: right hardening, unproven cause, no honest red — a decision cell,
  not a pin. That matches the finding's own framing.

### One caution on the one line

`takeFocus()` is an unconditional `makeFirstResponder`. Worth confirming during the fix that
re-asserting it when the box **already** holds keys is a no-op in practice (AppKit's
`makeFirstResponder` short-circuits on the current first responder, but NSTextView's
`becomeFirstResponder` is the family where select-all-on-focus surprises live). Toggling the chip
**off** would also pull the caret back under the same line — which reads as correct UX to me
(she is returning to the words she just decided not to name), but it is a behaviour choice worth
stating in the disposition rather than discovering.

---

## WHAT I DID NOT DO

- **No fixes, no pins, no production edits** — this pass is the traced response only; the
  reviewer implements its confirmed findings.
- **No app run, no walk.** Every claim above is a code trace (plus the recorded sample frames and
  the recorded walk note); R1-3's widening in particular is traced, not staged, and I say so at
  the claim.
- **No suite run.** Nothing in this pass changes behaviour, so there is nothing to keep green; the
  phase's finals stand as each unit recorded them.

---

# THE IMPLEMENTER'S SANITY PASS OVER THE FIX DIFF (opus, 2026-09-19)

**Scope:** the six dispositions and the five fix commits — `262ef925` (R1-2) · `ede79958` (R1-3) ·
`5cceee24` (R1-4) · `d42a3440` (R1-5 + R1-6) · `43f420b4` (R1-1) — read against the code they
landed in. Same rules as the responses above: **I fixed nothing**; anything raised here returns to
the reviewer for the final word.

**Verdict: the fix pass is sound. Four items raised, none BLOCKER-class — two are pin-strength
(the pins can go hollow or already do not discriminate the fix's own judgment), two are one-line
statements of a premise the code now depends on.** Everything the coordinator named as a sanity
question checked out; the list of what I verified is at the end so round 2 knows what is already
walked.

---

## S-1 · [pin strength] · R1-1's cell 1 has no WITNESS that the deferral path was taken — it can go hollow at the next point release, silently

`theIndicatorRefreshNeverForcesLayoutInsideTheEditTransaction` asserts an **absence**
(`decorLayoutQueriesInEditTransaction == 0`). That absence is equally true in two different
worlds: the fix working, and **the arm never being reached at all**.

Reaching it depends on an AppKit ordering fact the cell relies on but never checks — that during
`didProcessEditing` the text view's selection is still the PRE-edit one while `index` has already
shrunk, so the in-transaction caret read maps to block 2. The cell's own comment says this is the
mechanism; nothing asserts it happened. By the time the cell can look, AppKit's post-edit fixup
has put `caretBlockID` back in block 1 (the comment records that too), so there is no post-hoc
witness available.

**Why it matters more than usual here:** that ordering is exactly the class TEXTKIT2 §5's matrix
says to re-verify after every macOS point release. If Tahoe changes it, this pin goes green-and-
hollow on the one axis it exists to guard, and the next reader has no way to tell.

**The cheap close (the reviewer's call):** a second DEBUG counter incremented at the deferral
branch itself — `if appearance.indicator != .off, caretBlockID != previousCaretBlock { if
inStorageEditTransaction { deferredIndicatorRefreshes += 1 } else { refreshDecorations() } }` —
asserted `== 1` in cell 1. That turns the pin from "nothing bad happened" into "the arm fired and
was deferred", which is the fix's actual contract, and it fails loudly rather than quietly if the
ordering ever moves. It also gives the red-on-old measurement a permanent home instead of a
once-by-hand log line.

## S-2 · [pin strength] · the Compare seal cell does not discriminate the fact the fix deliberately chose

`compareDoorRefusesASealedPanesOwnPost` seals the **anchor** and focuses an **anchor** pane. A
guard written the wrong way — `projection.anchor.sealed`, the board-level fact the disposition
explicitly rejected because "Compare crosses posts" — passes that cell **identically**. So the one
place in the R1-3 widen that needed judgment is the one place no pin holds.

Two cells would hold it, and they are the two directions:

- **unsealed anchor + SEALED PEER, the peer's pane live → must refuse** (the anchor-fact
  implementation would wrongly allow);
- **SEALED anchor + unsealed peer, the peer's pane live → must NOT refuse** (the anchor-fact
  implementation would wrongly refuse — and this is the worse direction: it blocks a commit she is
  entitled to make, on a note that is not sealed).

`face(for:)` already answers peers (`projection.peers[postID]`), and both pane-key construction
sites set `context: postID` (`CompareBoardView.swift:1636–1638` and `:1718–1720`), so both cells
are ordinary to write. The second one is the one I would not ship without.

## S-3 · [premise, one line] · `inStorageEditTransaction` is a Bool, and it is correct only because `storageDidEdit` cannot re-enter — nothing says so

I verified the premise holds **today**: one production caller (`EditorView.swift:674`, guarded by
`editedMask.contains(.editedCharacters)`); the function is non-`async`, so the flag cannot leak
across a suspension; `MarkdownStyling.restyle` inside it produces attribute-only edits the
delegate's guard filters out; and `desyncRecovery` defers its re-render into a `Task` rather than
writing storage synchronously. So there is no re-entrant path.

But the failure mode if that ever changes is silent and is exactly the bug we just fixed: a
synchronous re-render inside `storageDidEdit` would run an inner `defer { inStorageEditTransaction
= false }` while the OUTER frame is still inside `processEditing`, and the arm would go back to
forcing layout in the transaction — with the oracle reading zero for the outer frame's own work.
A depth **counter** (`+= 1` / `-= 1`, same two lines) cannot be got wrong; failing that, one
sentence at the property naming the single-entry premise and what breaks it. I would take the
sentence at minimum, since the whole point of the flag is that a future reader must not reopen the
hole by accident.

## S-4 · [stated choice, one line] · Compare's guard fails OPEN on a missing face

`guard face(for: pane.context)?.sealed != true` — a `nil` face (a peer dropped from the board
while its `livePane` pointer lingers, or a pane read during a projection swap) passes the guard and
opens the field. On an unknown post that is arguably the right direction (never refuse on
ignorance, and the filer still refuses if the post really is sealed), but the three sibling doors
have no equivalent unknown state, so this one door's fail-open should be a **stated** choice rather
than a spelling. One clause in the existing comment. Lowest severity of the four; record-or-fix.

---

## WHAT I CHECKED AND FOUND SOLID (so round 2 does not re-walk it)

**The coordinator's four named questions, answered:**

1. **The R1-1 flag's scope covers the transaction exactly, with no road that leaves it stuck up.**
   `inStorageEditTransaction = true` + `defer { … = false }` open the method, and `defer` fires on
   every exit: the `suppressEditProcessing` early return, all four `desyncRecovery()` returns
   (`.block` · `.tail` · `.openTail` · `.closeTail`) and the `.refuse` return. Non-throwing and
   non-`async`, so neither a throw nor a suspension can strand it. (The one premise worth writing
   down is S-3's.)
2. **The deferred refresh is structurally delivered.** Four independent legs, each verified:
   (a) `storageDidEdit` bumps `overlayGeometryGeneration` at `:1176` **before** every early
   return, so the settle hop's gate (`overlayGenerationDelivered != overlayGeometryGeneration`) is
   open for the exact edit that deferred; (b) a storage character edit always dirties the view, so
   `viewWillDraw` → `onLayoutSettle` fires — and the contrast is written in the code itself at
   `onWidthReflow`, which calls the hop DIRECTLY precisely because a width reflow has no guaranteed
   display pass, while a storage edit does; (c) `refreshBadges`' `defer { refreshDecorations() }`
   sits above its own early return, so the hop delivers the decor pass even when the badge walk
   bails; (d) `caretBlockID` is a member of `BlockDecor.State`, so the `lastDecorState` equality
   gate passes the block change through rather than swallowing it. **Belt beside the braces:** on
   most real edits `textViewDidChangeSelection` re-runs `updateCaretContext` immediately after the
   transaction closes, where the arm is ungated — so the settle-hop-only case is narrowly the one
   where the in-transaction read was already correct. No uncovered shape found; the residual is a
   surface with no draw pass at all (hidden/occluded), which delivers on its next draw.
3. **The four seal guards read the right fact on each surface.** Write → `header?.locked`, the
   same fact `CommitBar`'s own `.disabled` reads. Takes/Lenses → `projection.sealed`, which is
   exactly the `frozen` term `isPaneLive` uses (it omits `structuralInFlight`, correctly — the
   filer does not refuse for that, and a door must not refuse where the filer would not). Canvas →
   `sealed`, set from `Queries.containerHeader(db, containerID:)?.locked` for its OWN container
   (`CanvasViewModel.swift:144`). **Compare → `face(for: pane.context)?.sealed`, and `context` is
   really populated:** both pane keys are built with `context: postID` (`:1636–1638`, `:1718–1720`),
   so the pane's own post's face is what answers. That is the right fact; S-2 is only that no pin
   holds it.
4. **The did-write answer is consumed at every caller that speaks.** `renameCommitPoint` has
   exactly one production caller — `BlockHistoryModel.rename` (`BlockHistoryPane.swift:300–308`) —
   and it consumes the Bool before speaking. There is no mobile caller (`renameCommitPoint` does
   not appear anywhere under `VariorumMobile`; the shared `BlockHistoryFace` only names it in a doc
   comment), which is why the phone needed no half. The `@discardableResult` is needed by the core
   cells that call it as a statement; the residual — a future face dropping the answer and speaking
   a wrong receipt — is held only by the Mac cell, which is proportionate.

**The hollow-pin sweep (the coordinator's fifth question) — nothing found beyond S-1/S-2:**

- **No shipped decoration pin drives its state through a storage edit.** All seven suites that
  touch decorations (`Phase13SurfaceTests` · `BlockManagementTests` · `ProseGutterTests` ·
  `TintRegistrationTests` · `CommentsAndTagsTests` · `TutorialWalkTests` · the new one) reach the
  decor pass through explicit calls — `refreshDecorations()`, `pushDecorationsToSink()`,
  `pickBlock`, `noteHover` — so the deferral hollows none of them. (It could not have gone the
  other way either: in a harness there is no draw pass, so a pin that had relied on the
  synchronous refresh would have gone RED, not hollow, and the full suite is green.)
- **No shipped pin asserted the old enum dumps** — `TakeCardDoorTests:280` names the class in a
  comment only. R1-4's two cases therefore strengthen every face that can raise them, not just the
  rename door; the generic `variantNotFound` wording is correct for the ops that actually throw it.
- **`TutorialWalkTests:3136`'s ⌘S cell** drives `commitCaretVariant()` on an unsealed practice note,
  so the new seal guard does not change why it passes.
- **`renamingASavepointSetsAndClearsItsNameAndSaysSo`** renames to two DIFFERENT values, so `wrote`
  is true on both legs and the receipt change does not hollow it — and the reviewer's note is
  right that it is the cell that would have caught a row-value implementation (its second leg
  compares against a deliberately stale `CommitPoint`).
- **R1-6's counter bookkeeping is safe:** `updateNSView` assigns `lastFocusRequest = focusRequest`
  **before** calling `takeFocus()`, so the new already-first-responder early return cannot
  desynchronise the counter or re-fire; and `QuickNoteView`'s new `@State focusRequest = 1`
  reproduces the open-time behaviour byte-for-byte (`wantsInitialFocus = focusRequest > 0`).

**Two things I checked that nobody asked about, both clean:**

- **The oracle sits on the right road and needs no extension.** `refreshDecorations`' `offsetAt` →
  `textLayoutFragment(for:)` is the ONLY layout-FORCING call in the overlay family; `refreshBadges`
  and `refreshDecorations`' own `fragmentFrame` both enumerate with `options: []`, which does not
  ensure layout (and the badge pass's doc says so). The counter's placement — after the
  `needsFrames` guard, before the first geometry read — is exactly the forcing boundary.
- **There is no mobile twin of R1-1.** `MobileEditorViewModel` contains no
  `textLayoutFragment(for:)` and no `ensureLayout` anywhere, so the phone's `storageDidEdit` has no
  forcing road to defer. No parity row is owed by this fix.

**What I did not do here:** no fixes, no pins, no app run, no suite run — the same contract as the
responses above. S-1 and S-2 are pin work the reviewer owns; S-3 and S-4 are one-liners it may
take or record.
