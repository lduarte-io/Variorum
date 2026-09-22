# RUN A — LADDER ROUND 3 (cold review, Fable; 2026-09-21 — the cap)

**Reviewer:** `fable-reviewer`, fresh session, zero implementation context, `notes/REVIEW_PROMPT.md`
verbatim. **Focus:** round 2's fixes (`b5e229b3..40939923` — the comment-draft park on both
platforms + the pad's cost-model sentence) and everything they touched, re-derived at the code;
anything else the pass surfaced in `50e581fa..HEAD`. **Anchors:** `run-a-ladder-round1.md`,
`run-a-ladder-round2.md`, `run-a-custody-text-loss.md`.

**Written incrementally per `notes/SessionResiliencyProtocol.md`; the round's final list is the
FINDINGS section when the STATUS line says COMPLETE.**

**STATUS: COMPLETE — round 3's findings are final.** The whole fix-pass diff read (the brain, both
platform halves, both pin files, the QUESTIONS edits, the cost-model sentence); the surfaces read
whole (`CommentsPanel.swift` 919 lines, `MobileComments.swift`, `MobileCommentsSheetView.swift`'s
render/layout/submit, `QuickNoteView.swift`'s take/onAppear/onDisappear, the delegate's quit door,
`CommentComposition`, `AppSession`'s park block + fences); all three Mac presenter sites read; the
suites run by my own hands (Mac `CommentPanelParkTests` + `QuickNoteParkTests` **11 tests in 2
suites ALL GREEN**; mobile `MobileCommentParkTests` + `MobileCommentDraftTests` **8 tests in 2
suites ALL GREEN**); the one Sonnet lookup spent on the two SwiftUI facts finding F1 rides on
(Apple's own `State` documentation quoted below). Findings: **2 MAJOR · 1 NIT**.

---

## FINDINGS (severity-ranked)

### [MAJOR] F1 · App/Variorum/Variorum/Features/Editor/CommentsPanel.swift:58 (`CommentsPanelModel.init`'s `take`) + :487–488 (`State(initialValue:)`) + the three presenter closures (EditorView.swift:213, TakesBottomBar.swift:295, TakesShared.swift:742) · The Mac restore is consumed inside a `@State` initial-value expression — PHANTOM panel constructions while the panel is presented EAT the park, silently reverting the Mac half to the pre-fix loss

**The mechanism, traced end to end.** `CommentsPanel.init` runs
`_model = State(initialValue: CommentsPanelModel(session:blockID:))` (CommentsPanel.swift:487–488),
and the model's init CONSUMES the park — `session.commentDraftPark.take(forBlock:)` clears `held`
in its `defer` (CommentDraftPark.swift:64). Two external facts make that a defect, both verified
(Sonnet lookup, Apple's `State` documentation, developer.apple.com/documentation/swiftui/state):
(1) *"A `State` property always instantiates its default value when SwiftUI instantiates the view.
For this reason, avoid side effects … when initializing the default value"* — the wrapped-value
expression runs on EVERY construction of the view struct, and SwiftUI discards every result after
the first while the side effect has already run; (2) `.sheet(item:)`/`.popover(isPresented:)`
content closures are re-invoked while presented whenever the presenting view's body re-evaluates
(modern SwiftUI; Fatbobman's demonstration — the closure re-captures updated parent state, which
requires re-invocation). All three presenters construct the panel inline in such closures with no
model passed (`model: nil` default at all three sites).

So: she opens the panel on block B (park empty — harmless take). She types a paragraph, Add →
refused → parks (CommentsPanel.swift:225–226) — the model keeps `addDraft`, the park holds the
insurance. Now ANY re-evaluation of the presenting view's body while the panel is still up —
`EditorViewModel`/`TakesViewModel` are `@Observable` and chatty: a projection arrival (including
the lockPost echo of the very seal that caused the refusal), autosave state, a sync apply behind
the sheet, a window resize — re-invokes the content closure → a fresh `CommentsPanel` value → a
fresh PHANTOM `CommentsPanelModel` whose init `take`s the park and is then discarded (installed
`@State` keeps the first model). The park is now EMPTY while she reads the refusal. She closes
(the add draft is deliberately never filed on leaving, #118(a)) → reopens → nothing restored. The
round-2 MAJOR's Mac fix degrades to the pre-fix loss, silently, under ordinary conditions.

**The family precedent avoids exactly this:** the quick-note pad consumes its park in `.onAppear`
(QuickNoteView.swift:362–365 — the installed-view lifecycle, once per summon), never in a
`State`-init. The Mac panel is the family's one deviation, and it is the one with the
side-effectful init.

**Why the shipped pins missed it.** `CommentPanelParkTests` construct models 1:1 with opens — the
exact grain the real presenters do NOT have. No pin constructs a model that is never installed
between the refusal and the reopen.

**Red-on-old pin.** Model-level, matching the mechanism: refusal parks (pin (a)'s staging) → a
CommentsPanelModel is constructed and DISCARDED (the phantom — never started, never installed) →
the reopen's model must still restore the draft. Red on current (the phantom's init consumed the
park; the reopen reads an empty add area). Green under the fix below, because a bare init no
longer consumes.

**Second arm, SPECULATIVE (recorded, not load-bearing):** at first presentation SwiftUI may
construct the content value more than once before the `@State` storage installs; if a later
value's initial value seeds the storage, the draft is eaten at the very restore (the installed
model is the one whose init took nil). Timing-dependent and version-dependent — I could not trace
a deterministic trigger; the same fix removes the whole class.

**Proposed fix (the pad's own shape, narrowest).** Move consumption out of the init into the
installed lifecycle: a `restoreParkedDraft()` on the model, called from the panel's `.task` before
`model.start()` (CommentsPanel.swift:524–529) — `.task` runs once per installed presentation, so
phantoms never touch the park. The three existing pins keep their arms and call the hook where
they now rely on init; the phantom pin above lands beside them. (If F2's final call makes the
restore NON-consuming, this init side effect becomes harmless as a by-product — but the init-time
`take` should still move or become a peek, because a side-effectful `State(initialValue:)` is the
documented anti-pattern either way and the receipt/draft placement on a phantom is wasted work.)

### [MAJOR] F2 · App/Variorum/Shared/CommentDraftPark.swift:62–66 (`take`'s consuming `defer`) + MobileComments.swift:88–96 / MobileCommentsSheetView.swift:163–166 + CommentsPanel.swift:58–67 with close()/onDisappear filing dirty ROWS only · Clear-at-restore was ported onto surfaces whose CLOSE never submits — a reopen she closes without filing spends the insurance, and the SECOND close loses the words for good, on the very unlock road the refusal names

**The mechanism, traced end to end (phone, both arms; Mac, the ADD arm).**
1. Submit refused → park holds (blockID, submitted text). Close #1 → covered (the fix, working).
2. Reopen the same block → the restore is AUTOMATIC and CONSUMING: `take` clears `held` in the
   same breath (CommentDraftPark.swift:64); the words now live only in the field
   (MobileCommentsSheetView.swift:178–180) / `addDraft` (CommentsPanel.swift:62).
3. Close #2 WITHOUT submitting — and the words are gone, unrecoverably: the phone's render
   close-arm wipes the field (MobileCommentsSheetView.swift:165, unchanged by design — "zero
   close-site changes"); the Mac's add draft dies with the model (close()/onDisappear commit
   `dirtyCommentIDs` only — CommentsPanel.swift:539–548, 825–831 — never the add draft, #118(a)).
   The park is empty. Nothing re-parks, because nothing was re-refused — these closes never
   submit anything.

**Why this is the run's own class and not a ruled edge.** The refusal's remedy lives OUTSIDE the
surface — *"This note is locked — unlock it to change comments"* — so reopen-to-look, then
close-to-go-unlock, is the ORDINARY path, not an exotic one; and the restored line (*"the comment
that couldn't be saved — here to try again"*) announces safekeeping the box no longer has. This is
round 2's MAJOR one generation later: a refusal preserved her words, and a close gesture the
surface itself invites destroys them. On the pad, the identical clear-at-restore ruling is
LOSSLESS because the pad's close FILES — `close()` → `take()` → a re-refusal RE-PARKS
(QuickNoteView.swift:158–223), so the insurance round-trips indefinitely. The round-2 ruling's
binding 3 imported that clause ("the sheet becomes the only home; a re-refusal re-parks") onto
surfaces where no close road ever produces the re-refusal — the ported shape's safety premise was
the pad's close-submits grammar, which these surfaces demonstrably lack. That is a falsifiable
premise, not a preference (the review contract's own carve-out on settled decisions).

**Precision:** the Mac EDIT arm mostly self-heals — the close-time dirty-row commit IS a
re-submission, refuses again under the seal, and re-parks (binding 2's design, verified at
commitEdit's refused arm) — EXCEPT the close-before-first-snapshot window (`comments == []` ⇒
`dirtyCommentIDs == []` ⇒ no commit ⇒ the restored draft dies un-re-parked; sub-second, narrow).
The Mac ADD arm and both phone arms carry the full second-close loss.

**Red-on-old pin.** Phone, at the real doors (pin (i)'s harness verbatim): refused → close →
reopen (restore observed — the field holds the text) → close with nothing submitted → reopen the
same block → the draft must come back; the shipped code reads `""` with `held == nil`. Red on
current. Mac: pin (a)'s staging + the second generation, same expectation on `addDraft`.

**Proposed fix (narrowest family-consistent; the shape is the flow's final call).** Make the
restore NON-consuMING — `take` becomes a peek; the park clears on a LANDED same-block submit
(already built: `clearIfHeld` at both Mac arms + the phone's `.landed`), is REPLACED by a newer
refusal (already built), and dies with its home (already ruled, #140(f)). Consequences, honest:
the restored line reappears at every open until she lands or replaces it (truthful — the box IS
holding an unfiled refusal), and her hand-emptied field still restores at the next open — which is
exactly #140(b)'s ALREADY-RECORDED over-preservation edge, extended one generation; #140(b)'s
sentence ("the next open brings back the SUBMITTED text") becomes true in every generation instead
of only the first. This change also collapses F1's phantom into harmlessness (a peek mutates
nothing). If the flow instead sustains clear-at-restore as ruled, the acceptable MINIMUM is the
record — a #140 line naming that a reopened draft closed without filing is spent — because the
silent state must not survive the round (round 2's own precedent, applied to round 2's own fix).

### [NIT] F3 · notes/QUESTIONS.md #140(d) · The phone's dead-block corner is unrecorded — pin (v)'s own staged state

`MobileCommentParkTests.theAutoCloseRoadParksTheSame` ends with the park holding a draft keyed to
a DELETED block. `open(blockID:)` guards `model.slot(for:) != nil` (MobileComments.swift:79), so
no door can ever restore it — it holds until a newer refusal replaces it, recoverable only if the
block itself is restored from the tray. Same class as the Mac's recorded (d) corner
(over-preservation with a pruned restore road); the symmetric sentence is missing. One line in
#140(d) or a (g). No pin (record-only).

---

## CLEAN BILL — including the verdict on each of round 2's fixes

1. **The PHONE park half (`9cf553e4`) — CORRECT AS BUILT for every pinned road; F2's
   second-generation road stands open against the shared brain, not this half's mechanics.**
   Re-derived: refused-only enforced through the `DraftOutcome` funnel — the latch's turn-away and
   the dead-model arm both map to `.turnedAway` and park NOTHING (binding 1's letter);
   `run`/`runDraft` byte-preserve `delete`/`restore`/`add` semantics (nil-latch and dead model →
   `false`, exactly as shipped); `blockID` captured before the await so a mid-flight close still
   parks keyed correctly; the one-shot is consumed synchronously (onChanged wired once at
   construction — MobileEditorTextView.swift:206–208 — and `render()` runs in the same call as
   `open()`), so no double-open window exists; `editingID` rides the park both directions; the
   restored label sits in its own accent register, no overlap with the editing Cancel (geometry
   checked), placeholder recomputed after the consume; the rows scroll yields the line's height.
   Suites **8/2 ALL GREEN by my own hands** (with `MobileCommentDraftTests` riding unmodified —
   the P4 pins' claim verified).
2. **The MAC park half (`62bfef0f`) — the binding-5 sweep's SUBSTANCE CONFIRMED**: both arms were
   real loss roads and the park at REFUSAL time is placed correctly at both (`fileAddDraft`'s
   refused arm fires only on a thrown refusal — `perform` returns false from its catch arms
   alone, no latch on the Mac; `commitEdit`'s refused arm is the onDisappear net's own call, so
   the close-time refusal parks with zero close-site changes); `clearIfHeld` on both landed arms;
   the `survivingDrafts` interaction verified at `CommentComposition.swift:141–148` (pin (b)'s
   premise true — a dirty draft against a live comment survives the first snapshot; the #140(d)
   dead-comment corner honestly recorded); the receipt register consistent with the panel's LOCAL
   status law (the sheet-geometry rationale at CommentsPanel.swift:80–86); the `#if os(macOS)`
   fence verified around `commentDraftPark` (AppSession.swift:469…605). **F1 and F2 stand against
   this half** — F1 at its restore's construction grain, F2 at the shared brain's consuming take.
3. **The NIT's cost-model sentence (`40939923`) — CORRECT, TRUE at the code.** `onDisappear`
   unregisters the quit token synchronously and spawns the filing task
   (QuickNoteView.swift:373–392); a ⌘Q inside that flight finds `registry.isEmpty` true and the
   park unarmed, and the early arm proceeds undeclined (VariorumAppDelegate.swift:79–84); the quit
   road's own filing precedes the decision by construction (lines 86–95); optimistic parking is
   correctly ruled out by binding 1. #137(b)'s extension matches the mechanism word for word and
   is flagged as the record-truth edit it is.
4. **The records:** QUESTIONS #140's six items on disk, matching the ruling's binding 6; the
   sanity pass's precision note applied to #140(a) as a record-truth line (verified at
   `ac444b02`); ONE wording constant on the brain (grep: no second copy of the restored line —
   the two `MobileQuickNote` strings are the pad family's own); next free number moved to #141.
5. **Fences:** ZERO `Sources/` lines in the fix pass (`git diff b5e229b3..40939923 --stat` — all
   App-side + notes); zero `Sources/VariorumCore/Sync/` lines; zero commit trailers across
   `b5e229b3..HEAD` (grep); tree clean at `ac444b02`; marker untouched, no schema.
6. **Round 1's fix area, re-checked in passing (not re-derived — round 2's verdict stands):**
   `QuickNotePark.park`'s emptiness-gated re-arm, `clear()`'s flag reset and `declineQuitOnce`
   read as recorded; `QuickNoteParkTests` + `CommentPanelParkTests` **11/2 ALL GREEN by my own
   hands**.
7. **Pin quality:** the mobile pins drive the REAL UIKit doors (mounted sheet, key window, a real
   seal; the auto-close staged through a real `deleteBlock` + the projection route) — the strong
   form. The Mac pins drive the model at its construction grain, which is exactly the grain F1
   shows the presenters do not share — recorded as the finding's locus, not a pin defect.

## Disposition state

Round 3 is the ladder's cap. F1 and F2 enter the cross-model flow (findings to the implementer
verbatim; responses return here for the final call; confirmed fixes implemented in this session,
each with its pin, per piece, suite green after). Anything unsettled when this round closes is
recorded for the author, never looped.

---

## THE FINAL CALLS (cross-model flow; the implementer's responses at `31b18914`, the ruling
amendment at `65c5c11b`) + THE FIX PASS

**F1 (the Mac restore consumed in `State(initialValue:)`) — CONFIRMED; implementer AGREES (the
primary arm confirmed not speculative).** Fix to the ruled shape: the restore moves to the
installed lifecycle — a `restoreParkedDraft()` on the model, called at the HEAD of the panel's
existing `.task` before `model.start()` (the implementer-confirmed home; the pad's own shape);
`CommentsPanelModel.init` becomes side-effect-free. Under F2's peek the phantom can no longer EAT
anything, so the move is hygiene exactly as the amendment says — and the documented
`State(initialValue:)` anti-pattern goes regardless.

**F2 (clear-at-restore on surfaces whose close never submits) — CONFIRMED; implementer AGREES;
the RAISE is ADOPTED (my final call, the mechanism re-derived myself).** The raise's trace holds
at the code: under a peek, the block-keyed `clearIfHeld(blockID:)` becomes a cross-kind hole —
the Mac's landed `commitEdit` (CommentsPanel.swift:248) clears a parked ADD draft on the same
block that never landed, and the phone's `.landed` arm (MobileComments.swift:190) does the same
when a landed edit follows a parked add (or vice versa). The hole is UNREACHABLE under the
shipped consuming take (the park is already empty after the restore) and REAL under the peek —
so the draft-keyed clear is the amendment's honest reading, exactly as the orchestrator's
ruling-side answer records, not a widening: the insurance clears when THE DRAFT IT INSURES lands,
identified as `(blockID, commentID)` (nil = the add draft). Built: `CommentDraftPark.peek` (non-
consuming) + `clearIfHeld(blockID:commentID:)`; the pad's `QuickNotePark` untouched (its
clear-at-restore premise holds — the pad's close files); the phone's one-shot render consume
stays (orthogonal — it protects her typing within an open, never the park's hold).

**F3 (the phone's dead-block corner unrecorded) — CONFIRMED; implementer AGREES.** One symmetric
sentence at #140(d), noting the peek makes it strictly a hold-for-the-session (harmless, and the
draft comes back if the block does — Put back).

**Ruled-change pin edits, named before the pass (the A1 redo-pins precedent — the ruled change
class, not defects):** Mac pin (a)'s `held == nil` clear-at-restore assertion and phone pin (i)'s
same assertion flip to the peek's `held != nil` (the insurance now outlives the restore); the Mac
pins' bare-init restores become explicit `restoreParkedDraft()` calls (init no longer restores —
F1's fix); each keeps its subject.

**THE REVERTS, ANNOUNCED (behavioural, from committed state, restored by `git checkout --`):**
- **R3-A (the peek revert):** re-add the consuming `defer { held = nil }` to
  `CommentDraftPark.peek`. Expected: the two-generation pins RED on BOTH platforms (the second
  reopen restores nothing), the phantom pin GREEN (with init no longer consuming, a consuming
  restore hook still serves the first installed reopen), the cross-kind and guard pins green.
- **R3-B (the shipped-combination revert, Mac):** call `restoreParkedDraft()` from
  `CommentsPanelModel.init` AND make the peek consuming — the shipped shape reproduced through
  the new API. Expected: the phantom pin RED (the discarded init consumes; the reopen restores
  nothing), the Mac two-generation pin RED, the guard (d) green.
- **R3-C (the cross-kind revert):** make `clearIfHeld` ignore `commentID` (block-keyed again).
  Expected: the cross-kind pins RED at their held-after-landed-other-draft arms on BOTH
  platforms, the same-draft clear arms and pins (ii)/(c) GREEN.

**The build order (commit per piece, pathspec-limited, pushed):** (1) this record; (2) the
production fix + all pins in ONE commit (the brain's signature change binds both platforms'
call sites and their pins into one coherent piece: `CommentDraftPark.swift`,
`MobileComments.swift`, `CommentsPanel.swift`, both pin files); (3) the reverts, run and
recorded; (4) #140's re-base + (d)'s sentence (record-truth edits, flagged); (5) closing runs
(both platforms' touched suites + the tutorial spine by its eleven struct names).

---

## THE FIX PASS — RECORDS (all commits pathspec-limited, pushed, no trailers)

**THE FIX PASS'S COMMITS:**
- `bb5d74ea` — the final calls + the raise's adoption + the three reverts announced (this file).
- `46aadc10` — the production fix + ALL pins, one coherent piece (the brain's signature change
  binds both platforms): `CommentDraftPark` peek + draft-keyed `clearIfHeld(blockID:commentID:)`;
  the phone controller's peek/clear call sites; the Mac's `restoreParkedDraft()` at the head of
  the panel's `.task` with a side-effect-free `CommentsPanelModel.init`; Mac pins (f)/(g)/(h) +
  phone pins (vi)/(vii); the round-2 clear-at-restore assertions flipped as the named
  ruled-change edits.
- `b1cac50e` — QUESTIONS #140 re-based to the peek (header + (b) + (f), each flagged as a
  record-truth edit in place) + (d)'s phone dead-block mirror (F3).

**REVERT R3-A RAN AND DISCRIMINATED EXACTLY** (from committed `46aadc10`; the consuming
`defer { held = nil }` put back on `peek`): Mac — **3 issues**: pin (a) red at its
held-survives arm, the two-generation pin (f) red at BOTH generation-2 arms; phone — **3
issues**: pin (i) red at its held-survives arm, pin (vi) red at both generation-2 arms (the
field `""` against her paragraph, the restored note nil). The phantom pin, the cross-kind pins
and every guard GREEN — the two-generation loss reproduced alone. Restored by `git checkout --`;
tree clean.

**REVERT R3-B RAN AND DISCRIMINATED EXACTLY** (the shipped combination reproduced through the
new API: `restoreParkedDraft()` called from `init` AND the peek consuming): Mac — **5 issues**:
the phantom pin (g) red at BOTH arms (the bare construction ate the park; the installed reopen
restored nothing — F1's exact loss), plus (f)/(a) as under R3-A. The guard (d) and the
cross-kind (h) GREEN. Restored; tree clean.

**REVERT R3-C RAN AND DISCRIMINATED EXACTLY** (`clearIfHeld` made block-keyed again): Mac —
**2 issues**, phone — **2 issues**: the cross-kind pins red at exactly their two
held-after-a-different-draft-landed arms on each platform (the landed edit spent the parked add
draft's insurance, then the landed add spent the parked edit's); the same-draft clear arms and
the round-2 ghost guards (ii)/(c) GREEN — the raise's direction exactly. Restored; tree clean.

**THE CLOSING RUNS (final tree, literal selectors, the N-tests lines read; one selector trap
walked on the way — the first spine attempt used guessed middle names, selected only 4 suites
(25 tests) and still printed green, so the eleven names were re-read from the file's structs
before the real run):**

| Gate | Result |
|---|---|
| Mac — `CommentPanelParkTests` (8) + `QuickNoteParkTests` (6) + THE TUTORIAL SPINE by its eleven struct names (79) | **93 tests in 13 suites — ALL GREEN** |
| Mobile — `MobileCommentParkTests` (7) + `MobileCommentDraftTests` (3) + `MobileQuickNoteReadFailureTests` (3) | **13 tests in 3 suites — ALL GREEN** |

**Fences:** ZERO `Sources/` lines in this fix pass (the whole pass is App-side: the Shared
brain, one controller, one panel, two pin files, the records); zero
`Sources/VariorumCore/Sync/` lines; zero trailers across the pass's commits (grep, count 0);
tree clean; marker untouched, no schema. The pad's `QuickNotePark` byte-untouched by this pass,
as the amendment requires.

**Fix pass CLOSED.** Per the flow: the implementer side's sanity pass over `bb5d74ea..HEAD` is
next; anything it raises returns here for the final word. This is the ladder's CAP — anything
that cannot settle there is recorded for the author, never looped.
