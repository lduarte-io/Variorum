# VX-143 — ladder round 2 (cold review of the round-1 fixes, fable-reviewer, 2026-10-10)

**Diff reviewed:** `380bc232..636142f7` on `vx-143-write-chrome-feedback`, minus the pure record
commits — i.e. the five fix commits: `276dfe7a` (pins) · `6cbd543c` (the gone-guard on the take
panel's four ring arms) · `6c7812ac` (the BookView publish-on-focus) · `65d7eb7c` (the gain-only
pin) · `59211b5f` (the gain-only refinement). Reviewed cold per `notes/REVIEW_PROMPT.md`; anchors:
round 1's findings, the cross-model exchange, the final calls and the sanity pass
(`notes/plans/fixes/vx-143-ladder-r1.md`), the run record, CLAUDE.md, AppSpec, OverallModel.
Question under review: do the fixes close what the final calls say they close, correctly and
completely, introducing nothing new.

Every changed file read in full; every load-bearing claim in the fix commits' comments re-traced
in source by this reviewer (not taken from round 1's record); the round-1 fix-pass logs read on
disk; the two fix-pin suites independently re-run on HEAD.

**Verdict: CLEAN BILL — 0 BLOCKER · 0 MAJOR · 0 MINOR · 1 NIT (record-only).**
No new round is earned; the ladder closes at round 2.

---

## Findings

### NIT-1 · `App/Variorum/VariorumTests/WriteTakesPanelKeysTests.swift:369–394` · the gone pin presses the four ring keys only; the mint arms' gone-guards remain unpinned

`theKeysOnAGoneBlockWriteNothing` dispatches exactly `[.archive, .choose, .stepNext, .stepPrev]`
— the ruled fix's scope, correctly. But the panel's three mint arms (`.branch`/`.blank`/
`.blankChoose`) carry the same gone-guard (batch 2, `2e5784ca`, predating this fix) and no test
anywhere presses a mint key on the gone face; the pin's own `rows.count == 3` assertion would
catch a mint regression for free if the loop grew to all seven keys. Green-on-old by design (the
mint guards predate every tree this ladder touched), so this is hardening, not a defect —
RECORD-ONLY, the same class as round 1's NIT-1 disposition. Optional fix: extend the loop to the
seven take keys.

---

## Examined and deliberately NOT raised

- **The guard-then-Task staleness window** (a key dispatched in the instant between a block
  leaving the note and the panel's projection refresh passes `guard slot != nil` and the Task
  still runs, so `archiveVariant` could land on a just-released block's take): traced, real, and
  NOT this diff's. The identical shape predates the run on the Takes board's own arms —
  `archiveFocusedTake` acts on the ring with no placement check, `authority.livePane` survives the
  block leaving (`PaneTextAuthority.swift:88–96`), `ensurePlacementUnlocked` no-ops with no live
  placement (`Operations.swift:118–122`) — and the op itself is legal by the operations layer's
  lights (archiving a released block's take violates no invariant; I10 and the chosen-variant
  check still enforce). Round 1's re-ranked MAJOR was the STANDING contradiction (a permanent face
  saying "gone" while keys wrote); this diff closes that and narrows the residue to the transient
  class every async gesture in the app shares. No behavior worsened; not a regression; not raised.
- **The sanity pass's pre-projection instant** (a ring key before the panel's first projection
  speaks the gone line): accepted in round 1 as written — the face shown in that frame is the same
  `if let slot` check, so the refusal agrees with the face. Re-checked; stands.
- **The gain-side publish's idempotent duplicate on editing books** (a focus gain fires both the
  report road and the new focus road): `adoptNoteBox` is a cheap state write, no store write, no
  churn; cost-only, by the implementer's own build precision, accepted in round 1. Stands.

---

## Clean bill — what was specifically checked and found solid

1. **The VX-150 fix closes the final call exactly as ruled.** `guard slot != nil else { return
   refuseBlockGone() }` on all four ring arms (`WriteTakesPanel.swift:239/242/245/248`) — the
   mints' rule made the panel's one rule, the keep-ops-road-for-⌘⏎ reading rejected per the final
   call; the three fall-through arms (`.toggleFan/.closeAll/.saveLens`) untouched; `slot` is the
   same derivation the gone face renders from (`:88–90` vs `:150/:164`), so the refusal and the
   face can never disagree; no key Write should get is eaten (all seven take keys were
   panel-claimed since `2e5784ca` — the guard changes what a consumed key DOES, not what is
   consumed).
2. **The escalated mechanism re-verified in source, not trusted from the record** (the
   hallucination guard, both directions): `livePane` is cleared only by `blur()` or migrated by a
   new `focus()` — nothing clears it on pane unmount (`PaneTextAuthority.swift:69/88–96`);
   `ensurePlacementUnlocked` passes when no live placement exists (`Operations.swift:118–122`);
   and the red log shows the write actually landing on the pre-fix tree (`vx143-r1-red`:
   `theKeysOnAGoneBlockWriteNothing` failed on `status == "active"` — the released block's take
   had flipped `archived`). The pin is store-asserted through the real router with Write's
   consuming stand-in beneath — the strongest shape for this class — and its fixture's merge road
   releases both sources whole exactly as `merge` specifies (AppSpec §9).
3. **The VX-141 fix closes MAJOR-1 exactly as ruled, with the sanity refinement.** The publish
   sits inside the EXISTING `.onChange(of: paneFocused)`, AFTER `model.paneFocused = focused`,
   `publishNoteBox()` only, gated `if focused` (`BookView.swift:357–380`). Mechanism re-traced
   end-to-end in this session: `BookNoteBox.shows(.read) == false` (`BookNoteBox.swift:95–103`) so
   a Read book's report is nil on both sides of a flip and the report road (`:402`) never fires;
   the gain-side nil lands in `adoptNoteBox` while `focusedReadingID == bookID`
   (`RootView.swift:678–679`), setting `noteBoxDeclinedBy` so the held slot's fallback returns nil
   (`RootView.swift:725`) — no phantom. The pane-focus input and `focusedReadingID` derive from
   the same `workspace.focusedPane` write, so the gain callback cannot observe a stale focus.
4. **The gain-only refinement is right, and loses nothing.** The loss-side wipe re-traced myself:
   `WorkspaceModel.paneShowing` guards `destination.noteID != nil` (`WorkspaceModel.swift:158–161`)
   — the one-destination-per-pane redirect is notes-only, so two panes may legally show the SAME
   book; `structure`/`mode` is per-view `@State` (`BookView.swift:126–128`); and in `adoptNoteBox`
   a same-id nil sets the declined word AND falls through the different-book early-return
   (`RootView.swift:686–688`), wiping the adopted report with no republish owed. The loss side
   adds nothing: editing modes publish on loss through the report road (the computed report gates
   on `paneFocused`, so it flips non-nil→nil and `.onChange(of: noteBoxReport)` fires), and a Read
   pane's loss was silent on the pre-run tree (no focus-road publish existed), so gain-only is a
   strict superset of pre-run behavior — nothing that worked before can have been removed. Cross-
   book focus flips, same-book both directions, book-swap-in-pane and the mid-departure transient
   all traced through `adoptNoteBox`'s three guards; every path ends with the derived gate
   (`noteBoxView` re-checking `report.readingID == showing`) hiding anything stale.
5. **The pins hold their mechanisms and the evidence discriminates both ways.** Logs read on disk,
   not trusted: `vx143-r1-red` fails on exactly the two recorded shapes (the archived flip; the
   slot settled `.box` at `NoteBoxSlotTests.swift:191`); `vx143-r1-gainonly-red` fails on the loss
   flip publishing (both arms, mechanically consistent — the un-cleared `["nil","nil"]`);
   `vx143-r1-revA` reds ONLY the gone-keys pin, `vx143-r1-revB` ONLY the phantom pin;
   `vx143-r1-gainonly-revA` (both-sides publish back) reds ONLY the gain-only pin,
   `vx143-r1-gainonly-revB` (no publish) reds the phantom pin AND the gain arm while the loss arm
   stays green — each arm reds exactly its mechanism, as the record says. The phantom pin's
   comment honestly records the removed hollow frames-oracle arm. The gain-only pin pins the RULE
   deterministically rather than the order-dependent two-pane repro, and says so — the honest
   choice under the fix protocol, since SwiftUI specifies no callback order between panes.
6. **Independent re-run on HEAD (this session, stage claimed and released):**
   `NoteBoxSlotTests` + `WriteTakesPanelKeysTests` = **9 tests / 2 suites passed, zero failures,
   zero skips** (`vx143-r2-verify.log`). The recorded covering run `vx143-r1-close3` read on disk:
   `Test run with 106 tests in 20 suites passed`, `** TEST SUCCEEDED **`, suite list matching the
   record, no test-level skips.
7. **Scope fences.** The fix diff touches exactly two production files (`BookView.swift`,
   `WriteTakesPanel.swift` — chrome, not the editor seam; `BlockRangeIndex`/`EditorTextView`/
   `PaneTextAuthority` untouched) and two test files; zero `Sources/` changes, zero `Sync/`, zero
   schema, zero `Shared/`; QUESTIONS.md untouched (the merge-moment rule); the record commits
   touch only the two `notes/plans/fixes/` files; no attribution trailers anywhere in
   `380bc232..636142f7` (checked `git log --format=%B`).
8. **The dispositions were honored completely.** The ruled fix shapes match the landed code line
   for line (all four ring arms; the existing onChange, after the model assignment,
   `publishNoteBox()` only, gain-gated); NIT-1/NIT-2's record-only dispositions left
   `CommitsPageLedgerTests` untouched, correctly; the fix commits' comments make no claim I could
   not verify in source (notes-only `paneShowing`, per-view `mode`, the same-id fall-through wipe,
   the ring's survival, the placement no-op — each located and read).

---

*Round 2 closes the ladder: no new BLOCKER or MAJOR; the one NIT is record-only hardening. The
round-1 fixes stand as landed.*
