# RUN A — LADDER ROUND 2 (cold re-review, Fable; 2026-09-21)

**Reviewer:** `fable-reviewer`, fresh session, zero implementation context, `notes/REVIEW_PROMPT.md`
verbatim. **Anchor:** `notes/plans/run-a-ladder-round1.md` (round 1's findings, final calls, fix
records, dispositions). **Diff under review:** round 1's fix pass (`bfdd3bd6..HEAD`, five fix
commits) re-derived at the code, the surfaces those fixes sit in, and anything else in the run's
combined diff (`50e581fa..HEAD`) this pass surfaces.

**Written incrementally per `notes/SessionResiliencyProtocol.md`; the round's final list is the
FINDINGS section when the STATUS line below says COMPLETE.**

**STATUS: COMPLETE — round 2's findings are final.** The fix pass re-derived at the code and its
suites re-run by my own hands (core P5/P6 family **50 tests in 4 suites — ALL GREEN**;
`QuickNoteParkTests` **6 tests in 1 suite — ALL GREEN**); the fixes' surfaces reviewed whole
(the quick-note family, the delegate's quit door, the phone comments sheet + controller, the two
operations files + `UndoStack`); samples re-derived across the combined diff (P5's pick leg, P14,
P36, the floor sweep, the re-link door's no-mint + consented-id guard, row 8's injected mark
leaves). Findings: **1 MAJOR · 1 NIT** (the NIT honestly labeled a hazard note, unpinnable under
the ruling's letter). Round 1's four fixes: **all four verdicted CORRECT** (clean bill below).

---

## FINDINGS (severity-ranked)

### [MAJOR] · App/Variorum/VariorumMobile/Features/Write/MobileCommentsSheetView.swift:156 (`render()`'s close arm) + MobileComments.swift:59–64 / 68–75 · The refused comment P4 just preserved is destroyed by the sheet's CLOSE — the very gesture the refusal's own sentence invites — and the residue is recorded NOWHERE

**The mechanism, traced end to end.** Sealed note → ⋯ → Comments → type a paragraph → Add:
`submitDraft` returns false and the field keeps her text (the P4 fix, working as pinned); she
reads *"This note is locked — unlock it to change comments."* Unlocking lives OUTSIDE the sheet,
so the refusal's own remedy requires leaving it: she taps the dim (`dimTapped` →
`comments.close()`, MobileComments.swift:59) and `render()`'s open→closed transition runs
`draftField.text = ""` (MobileCommentsSheetView.swift:156) — the paragraph is gone,
unrecoverably. The same wipe fires from `projectionDidChange`'s auto-close (MobileComments.swift:68–75)
when the block leaves the surface mid-draft (a sync-applied structural change). The refused-EDIT
draft dies the same way (`close()` nils `editingID` too).

**Why this is the run's class and not background noise.** This is byte-for-byte the shape
KnownIssues row 65 named on the Mac pad — a refusal preserves the words, then the CLOSE road takes
them — which this very run treated as a defect, ruled as a design fork, and closed with the park.
The phone's comments sheet has the identical two-gesture loss one surface over, and unlike the pad
its field is NOT torn down (the sheet view persists hidden in the host; the wipe is one explicit
line, not a lifecycle inevitability). The run's own discipline records what its items leave
standing (#136(b)'s undo-side residue got a KnownIssues row + owner 17e; row 65 itself sat as a
row until fixed) — but this residue appears in NO record: #136(d) announces the class closed on
this surface without naming the close road, KnownIssues has no row, QUESTIONS none. P4's binding
item text (the 17 entry) names only the submit road, so the run did not OWE the fix — what it owes
is the record, and the ladder's own rule flags an owned entry's surface left silently lossy.

**Red-on-old pin.** The `MobileCommentDraftTests` harness verbatim (mounted sheet, key window, a
real seal): refused submit (field kept — the shipped pin's own premise), then
`model.comments.close()` + render, then `open(blockID:)` again + render — the draft must survive
for the same block; the shipped code reads `""`. Red on current. (No shipped pin asserts the
close-clear — grep: `close|dim|render` has zero hits in MobileCommentDraftTests — so the fix
flips nothing.)

**Proposed fix (narrowest family-consistent, mirroring the ruled row-65 shape).** Hold the
REFUSED draft only (binding 1's letter one surface over), keyed to its block, on the controller —
memory-only, session-scoped; restored into the field at the next `open` of the SAME block's
comments; cleared on a landed submit, a different block's open, or her explicit cancel. Landed
PROVISIONAL with a QUESTIONS row, since it extends the row-65 ruling's shape to a new surface. If
the final call is that the mechanism is a row-7-class design fork wanting the orchestrator/author
rather than a ladder fix, the acceptable minimum is the RECORD — a KnownIssues row with an owner +
the QUESTIONS note. The silent state is what must not survive the run.

### [NIT] · App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift:373–392 + VariorumAppDelegate.swift:79–84 · The close road's refusal lands ASYNCHRONOUSLY, so a ⌘Q inside that window is decided before the park is armed — quit proceeds undeclined; hazard-note class (unpinnable under the ruling's letter)

**The mechanism (traced; no defect under the recorded ruling).** `onDisappear` unregisters the
quit token synchronously, then spawns `Task { pad.close() }`; the refusal — and the `park()` it
performs — lands only when the mint returns. A ⌘Q pressed inside that window finds
`registry.isEmpty == true` AND `held == nil`, so the early arm replies `.terminateNow` with no
decline; the refusal parks after the decision or never (the process is exiting). Binding 4's
letter fires "while a refused capture STANDS," and none stands at decision time — so no
failing-on-old test can pin a behavior the ruling permits, and the ruled memory-only cost model
("a crash or a forced second quit still loses it") arguably absorbs the window. Round 1's NIT-1
class exactly: worth one sentence in `QuickNotePark`'s cost-model doc (beside "a crash or a
forced second quit still loses the capture": *and a ⌘Q racing the close road's in-flight refusal
quits undeclined*) so the recorded trade stays complete. No code change proposed.

---

## CLEAN BILL — including the verdict on each of round 1's four fixes

1. **Round 1's MAJOR fix (`bfdd3bd6`) — CORRECT.** Re-derived on all four roads: pad-open ⌘Q #1
   (park into empty → re-arm → declined once) and #2 (re-park over a STANDING capture keeps the
   spent flag, still assigns the newest text → quit proceeds — binding 4 true on the pad-open
   road); the pad-closed early arm (no re-park, the one-shot survives to the second press); the
   resolution re-arm (`clear()` at `.filed`/`.nothingToFile`/`restore()`, then a fresh park into
   the emptied park); and decline → close → ⌘Q (the close's re-park keeps the flag — round 1's
   "undiscoverable escape" closed by the same line, as the sanity pass claimed). Pin (iii-c) IS
   the integrated second press the shipped pins never made; `QuickNoteParkTests` re-run by my own
   hands, **6/6 green**. The one-shot is per-STANDING-REFUSAL, not per-press-pair — the ruling's
   recorded letter, with the memory-only cost stated.
2. **Round 1's MINOR final call — CORRECT, both halves.** The dismissal's premise verified at
   the sources myself: `QuickEntryBar`'s recorded rationale exists verbatim with the same
   `if text == submitted` all-or-nothing gate; `QuickNotePad.take()`:199 is the same gate;
   `MobileQuickNote.frozenPrefix` confirmed as the DIFFERENT mechanism the round-1 premise
   conflated. The rewritten doc comment (`2e3b0276`) now states exactly what the code does,
   consequence named. (The finding above is the close road — a different mechanism on the same
   surface, not a relitigation of the dismissed submit-road behaviour change.)
3. **NIT-1 fix (`385ed8c4`) — CORRECT.** Both hazard sentences TRUE at their lines:
   `clearRedoFuture()` sits after `database.write` returns at Operations+Container.swift:415 and
   Operations+NoteVersions.swift:293; a refusal inside either write never reaches the clear;
   `clearRedoFuture()` itself clears the FUTURE only (UndoStack.swift:340–347).
4. **NIT-2 fix (`662237d3`) — CORRECT.** Exactly one production `park(` caller (take()'s
   `.refused` arm, after `mints()` passed); the assert is debug-loud and the release failure
   direction parks rather than eats — binding 1's right side.
5. **Suites, my own hands:** core `ContentReplacementRedoTests` + `PromotePicksArchivedPickTests`
   + `RedoStackTests` + `SmartConversionTests` — **50 tests in 4 suites, ALL GREEN**;
   `QuickNoteParkTests` — **6 tests in 1 suite, ALL GREEN** (literal selector; the N-tests line
   read). Tree clean before and after.
6. **Samples re-derived beyond the fixes:** P5's pick leg (`livePick` requires `.active`; the
   `sourceChosenID`/`shownVariant`/`defaultCopyID` fallback chain cannot mint I10-at-birth through
   the pick on either `carryFans` arm); P14 (identity owned FIRST — `postID = containerID` before
   the read — so the double-mint guard holds on every road out; the catch arm holds with the
   `.saved` sentence); P36 (the marker restored exactly as its two siblings; restoring the stale
   marker is safe because every application path re-reads fresh — round 1's NOT-finding #2
   concurred with); the passphrase floor (six setting-door sites all through
   `ProtectionCopy.passphraseFloor`; the unlock primitive not floored, as ruled); the re-link door
   (read-never-mint — `readAppleKey`, no mint call in the road; the key re-read at the act and
   matched against the consented id; every refusal arm exits before the one proof-authorized
   write); row 8's mark leaves injected in `TutorialWalkTests`' world (no headless write into the
   dev store's defaults).
7. **Fences:** the fix pass holds ZERO `Sources/VariorumCore/Sync/` lines (its only `Sources/`
   lines are the two hazard-comment blocks); zero commit trailers on every post-round-1 commit
   (grep over `bfdd3bd6~1..HEAD`); marker untouched; no schema.
8. **Records:** #137(c)'s author-facing sentence is now TRUE on the pad-open road; #136/#137
   otherwise match the fixed code; the TutorialWalkTests-selector trap present in ENVIRONMENT
   TRAPS; the round-1 file's fix-pass table matches the commits on disk.

## Verification log (what has been re-derived so far)

- **The MAJOR's fix (`bfdd3bd6`) re-derived at the code:** `QuickNotePark.park`
  (AppSession.swift:717–739) re-arms `declineSpent` only when `held == nil`; traced the integrated
  pad-open road end-to-end (⌘Q #1: finalizeAll → take() refused → park into EMPTY park → re-arm →
  decline; ⌘Q #2: re-park over a STANDING capture keeps the spent flag → `declineQuitOnce()` false →
  quit proceeds), the pad-closed road (early `.terminateNow` arm, no re-park, one-shot survives),
  the resolution re-arm (`clear()` at `.filed`/`.nothingToFile`/`restore()` resets the flag, and a
  fresh park into the emptied park arms it), and the decline-then-close-then-⌘Q road (the re-park at
  close keeps the spent flag → the next ⌘Q proceeds — round 1's "undiscoverable escape" note is
  indeed closed by the same line). The new pin (iii-c) is the genuine integrated second press
  (finalize → decline → finalize again → decline must read false) plus the re-park-assigns,
  capture-stays-parked and resolution-re-arms arms.
- **The MINOR's comment fix (`2e3b0276`):** the doc comment now states the all-or-nothing gate the
  code implements (`self.draftField.text == text`); the dismissal's premise re-checked at both cited
  sites (QuickNoteView.swift:199 is the same `text == submitted` gate).
- **NIT-1 (`385ed8c4`):** both hazard sentences verified TRUE at their code — `clearRedoFuture()`
  sits after `database.write` returns at Operations+Container.swift:415 and
  Operations+NoteVersions.swift:293; a refusal inside either write never reaches the clear.
- **NIT-2 (`662237d3`):** the silent early-out replaced by a debug assertion + unconditional park;
  the one production call site (take()'s `.refused` arm, after `mints()` passed) verified as the
  only `park(` caller.

*(Findings and clean bill land below as they are traced.)*

---

## THE FINAL CALLS (cross-model flow; the implementer's responses at `d340c5af`) + THE FIX PASS

**1 · MAJOR (the comments sheet's close destroys the refused draft) — CONFIRMED; implementer
AGREES; the fix shape is the orchestrator's fork ruling (the six bindings).** The causal history,
recorded for round 3 per the flow: the sheet inherited the pad's PRE-row-7 shape — the A1 brief's
P4 note said "match the pad's shipped pattern" and at P4's build time the pad had no park yet —
so this is row 65's own shadow arriving one surface over, which is exactly why binding 5's sweep
exists.

**THE BINDING-5 SWEEP (mine to run; the implementer's pointer treated as a CLAIM TO CONFIRM):
the Mac comments panel is CONFIRMED as a real refused-draft loss road — BOTH arms — and is fixed
in this same pass under the same ruling.** The trace, at the code:
- **The ADD draft** (`CommentsPanel.swift`): `fileAddDraft`'s refusal keeps `addDraft` and speaks
  (correct), but the model is `@State`-minted per presentation at its ONE construction site
  (CommentsPanel.init:441; the three presenters — EditorView:213, TakesBottomBar:295,
  TakesShared:742 — construct the PANEL; TrayPanel only names the adopt seam in a comment) — so
  Close, a click outside the popover, or ⎋⎋ tears the model down and the refused prose dies with
  it. `onDisappear` commits only `dirtyCommentIDs`; the add draft is deliberately never filed on
  leaving (#118(a)), so nothing saves it. Grammar-IDENTICAL to the phone's add arm: one field,
  whole prose, no net.
- **The in-place EDIT drafts**: focus-loss and `onDisappear` both commit (`commitEdit`), and under
  a sealed note that commit REFUSES — the `onDisappear` retry's refusal lands on a dying model and
  the draft goes with it. The Mac grammar differs (N simultaneous drafts; `survivingDrafts`
  pruning; the loss is a delta over surviving stored prose) — honored inside the same ruling: ONE
  held draft, newest wins (the ruled bounded trade), the edit arm riding with its `commentID`
  exactly as the phone's `editingID` does; the one corner that stays is a parked edit draft whose
  comment is deleted ELSEWHERE while parked (the first snapshot's `survivingDrafts` prunes it) —
  recorded in the QUESTIONS row, not a third adjacency.

**THE FIX AS BUILT (one brain, three homes):** `Shared/CommentDraftPark.swift` — ONE park type +
ONE restored-line wording (two constants would be the drift class): refused-drafts-only from the
SUBMITTED text, one held draft keyed to its block (+ the edit target), newest wins, take-at-open
clears in the same breath, `clearIfHeld` on a landed same-block submit. The phone's instance lives
ON THE CONTROLLER (the ruling's letter; parks in `submitDraft`'s refused arm, restores in
`open(blockID:)` via a one-shot the sheet's render consumes, speaks through a new
`comments.restored` line in its own register). The Mac's lives ON `AppSession` (macOS fence,
beside `quickNotePark`, for the same reason — the model dies with its presentation): parks in
`fileAddDraft`/`commitEdit`'s refused arms (the `onDisappear` net's refusal is `commitEdit`, so
the close-time refusal parks with zero close-site changes — binding 2's letter), restores in
`CommentsPanelModel.init` (add → `addDraft`; edit → `drafts[id]`), speaks through the panel's
status slot in the RECEIPT register (nothing is being refused).

**Accepted edges, recorded for #140:** (a) a refused draft she then EMPTIES by hand and closes
still restores at the next open (the park holds what was REFUSED, never the field's later state —
binding 1's letter; the pad's close-road parallel clears via `take()`'s nothingToFile, a hook the
comment closes deliberately lack); (b) the Mac's ⎋-clear likewise clears the FIELD, not the park;
(c) the pruned dead-comment corner above. All over-preservation, never loss.

**2 · NIT (the pad close road's flight window) — CONFIRMED at the one-sentence size; implementer
AGREES with two additions adopted:** the sentence lands in `QuickNotePark`'s cost-model doc and
NAMES the close-road window as its own class (the quit road's filing is synchronous with the
decision by construction; the optimistic park is ruled out by binding 1 itself), and QUESTIONS
#137(b) is extended to stay true — flagged as a RECORD-TRUTH EDIT.

**The build order (commit per piece, pathspec-limited, pushed; reverts announced from committed
state):** (1) phone fix + 5 pins (`MobileCommentParkTests`); revert R2-A — remove the park call
from `submitDraft`'s refused arm: pins (i)/(ii)/(iv)/(v) red at their park/restore arms, the
guard (iii) green. (2) Mac fix + 5 pins (`CommentPanelParkTests`); revert R2-B — remove both
`park(` calls: (a)/(b) red at restore, (c)/(e) red at their premises, the guard (d) green.
(3) the NIT sentence + #137(b) + the #140 QUESTIONS row. (4) closing runs.
