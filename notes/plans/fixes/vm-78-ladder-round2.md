# VM-78 — ladder round 2: the cold review's findings

**Reviewer:** `fable-reviewer`, a fresh session with no implementation context, running
`notes/REVIEW_PROMPT.md` verbatim. **Diff:** the run's whole diff, `git diff e48ef2f30..db4f1ec6b` on
`vm-78-fixes-to-whats-there`; the commits since round 1's review are `0180727de..db4f1ec6b`. **Anchor:**
`notes/plans/fixes/vm-78-ladder-round1.md` (round 1's findings and final calls) and the run record's ladder
table. **Date:** 2026-11-19.

**The count: 0 BLOCKER · 0 MAJOR · 3 MINOR · 5 NIT, all new in this round.** Round 1's F1 stands as it was
ruled: this round cannot close the ladder (below, "What is still owed").

## What this round read and ran

- Read myself, whole: `notes/REVIEW_PROMPT.md`; the run record; round 1's file; CLAUDE.md and its loaded
  canon; `notes/TEXTKIT2_NOTES.md` whole (the diff holds a TK2 probe and one editor view-model line);
  `notes/SurfaceContracts.md`, The Bookcase and books; her sitting-1 rulings (the frame, receipts) and the
  work list's seventeen rows; the whole run diff — every product file's diff, and at the tip
  `MobileBookDetails.swift`, `MobileTakesChrome.swift`, `MobileFanBadgePlacementProbeTests.swift`,
  `MobileCaretReplaceTraceTests.swift` and `MobileBookFixesTests.swift` whole; the regions the probe and the
  batch C arms lean on (`MobileEditorTextView` `layoutSubviews` / `nearViewportBand` / `firstLineGeometry`,
  `MobileEditorViewModel.storageDidEdit` / `fallbackVerdict` / `jumpToBlock`, `EditorEditRouting`'s
  `ArmedEdit.describes`, `MobileMarkdownActs.inputReplace`, the caret suite's `host` and the red test, the
  hosted-surface driver's alert functions); the core operations the changed doors call (`lockReading`,
  `unlockReading`, `unarchiveReading`, `restoreCommit`, `setDailyJournalBook`, `pendingArrivalCount`,
  `Queries.reading`).
- Not triggered: SyncSpec, CastleRules, MCPSpec — the diff still names nothing outside `App/Variorum/` and
  the two record files (`git diff --stat`), no schema, no custody, no protection sentence.
- Ran: nothing on the stage (another session holds it), no `xcodebuild`, no simulator. No `swift test` — the
  diff changes no core file. Read-only checks: the two result bundles the record names for the fix-pin
  window (`xcrun xcresulttool` — the tool wrote its own index file, `database.sqlite3`, into the green
  bundle; nothing else under `DerivedData/` was touched); the last batch C build log; the built test
  binary's strings; one `zsh -c 'echo …'` to see how zsh reads a parenthesised test id.
- **Review foci:** the run record has no "Review foci" section and no brief file beside it, so there are
  none to answer.

## Round 1's fixes, re-checked against each final call

| Final call | What is on the branch | This round's reading |
|---|---|---|
| F1 | the ladder table says a fresh round reads window (3)'s outcome, the fix pass and VM-16 re-landed | stands; see "What is still owed" |
| F2 | `MobileFanBadgePlacementProbeTests` rewritten (`e3f406086`); the arms re-drawn; the brief's amendment said in batch C's entry and in the ladder table | matches the final call line for line (reading 1 an expectation, reading 2 printed only, (i)/(ii)/(iii) on two cold mounts, unforced reads, `view.bounds` as the visible rect, 1 pt). One remaining assumption: **R2-F3** |
| F3 | `refusal` forwards `.readingNotArchived` beside `.readingSealed` (`MobileBookDetails.swift:365-370`); pin `aRacedUnarchiveSpeaksTheSharedSentence` | right. `readingSealed` is thrown on no other Details road (`unlockReading` only), so the sealed sentence cannot be spoken for the wrong act. Red on the pre-fix tip by reading (the raw fallback); green in the kept bundle |
| F4 | the lesson's first sentence and the dropped "also" (`MobileTutorialSeeder.swift:287-296`); pin lines in `MobilePocketGuideDeletionTests.theShelfLessonDescribesTheShelfThatExists` | the words are as called and true (the seed stars the guide; "first" is no longer promised). Red on the pre-fix tip by reading — all three new expectations fail on the old sentence. **Not yet run either way** (the record says so) |
| F5 | the row's label, `cancelFinish()` gone, the cancel pin on the binding, two hosted guards, the write-back assertion | as called. The guards are not vacuous: only the alert's own Finish action can lock the book, and the driver refuses a missing action. One side effect of the label: **R2-N1** |
| F6 | arm B takes the keyboard-only difference; the teeth are the fixed test against the named hand-break, with the hand-break's reach read from M2 first | as called, and the reach analysis is right: I traced `{1,5}` → `fallbackVerdict`'s old range `(1,8)` → the separator at 8 → `.refuse`, and an exact `{1,2}` → `(1,5)` → `.block(0)` (`MobileEditorViewModel.swift:1962-1972`, `EditorEditRouting.swift:140-155`). One unread branch: **R2-F2** |
| F7 | the removal commit before any whole-target run; M6/M7 re-shaped; the trace suites alone | as called (nothing to read yet — the removal is after the window) |
| F8 | the question's text, for the merge | as called |
| N1 | `aStarTakenWithTheShelfOpenReordersIt` | a real guard: both orders are the rule's (starred a–z among themselves), through the row's own door; green in the kept bundle |
| N2 | `rowTitle` reads `RecoveryCopy.rowKind(item)`; pin | right; red on the pre-fix tip by reading ("(empty note)") |
| N3 | `FinishConfirm.pendingArrivals` gone; `confirmFinish` acts on `confirm.readingID` | right |
| N4 | the `BookcaseBoard.swift` header, the test's name and message; the core doc line given an owner line | right (comment only; no Mac string moved in the pass — `git diff 0180727de..HEAD -- App/Variorum/Shared` is that one comment) |
| N5 | `defer { Self.leave(window) }`, the explicit call and its expectation kept | right; M9's red tree (`615a12189`) still has the hide-only `leave`, so the revert recipe is sound |
| N7, N8 | comments | right |
| N6, N9, N10, N11 | withdrawn · a walk row · a ticket line · bundles kept | N11 is only half kept: **R2-F1** |

## Findings, by severity

### MINOR

**R2-F1 · [MINOR — evidence; a record claim that does not hold] · the run record, "Round 1 fix pass — LIVE
STATUS", "The fix-pin window — RUN" ("The result bundles are kept (N11)"), and BATCH C's matrix rule ("stop a
lingering `xcodebuild` once the verdict and counts are in") · the RED leg's bundle is not a result bundle, and
the matrix's stop rule will make more of them.**
- *Evidence.* `App/Variorum/DerivedData/vm78-bundles/fixpass-red.xcresult` holds `Data/` and `Staging/` and no
  `Info.plist`; `xcrun xcresulttool get test-results summary` answers "Info.plist … does not exist, the result
  bundle might be corrupted". The green bundle reads (75 tests: 74 passed, 1 expected failure, 0 failed — the
  record's line). The record's own sentence explains it: on the red leg `xcodebuild` was stopped 40 s after
  its verdict line — before it had finalized the bundle. No log of that leg is in the worktree's
  `DerivedData/logs/` either.
- *Why it matters.* N11 was confirmed so that "the next round can read the names rather than the record's
  sentence about them". This round is that next round and could not: the four reds of the fix-pin window are
  again attested only by the verdict line and by reading (I did read each — the clean bill). Batch C's
  matrix carries the same stop rule for ten runs whose outcomes decide two tickets.
- *Fix (process; no pin).* (1) The record says the red bundle is unreadable, as batch B's was recorded lost.
  (2) For every remaining window: after the verdict line give `xcodebuild` a bounded grace to exit by itself
  before stopping it; then run `xcrun xcresulttool get test-results summary --path <bundle>` and write "bundle
  reads" or "bundle unreadable — the log is the evidence" beside the run; keep each run's log whatever the
  bundle does (the matrix already names `DerivedData/logs/vm78-c-<run>.log`; the fix-pin recipe names none).

**R2-F2 · [MINOR — advance guidance on a pre-decided arm, no pin; SPECULATIVE as to occurrence, the missing
branch is concrete] · the run record, BATCH C, "What each outcome means" (arm A, arm B, "Combinations no arm
maps") with `MobileCaretReplaceTraceTests.swift:403-415` · no arm reads `realPosture`'s OWN posture.**
- *Mechanism.* `waitForTheRealPosture` gives up after 300 turns and the run goes on; nothing but the printed
  `waited spins=` line and the `posture[after-wait]` snapshot says whether the window ever became key and the
  view first responder. Arm A's trigger is "`realPosture` GREEN and `suitePosture` shows `key=false` or
  `fr=false`"; arm B's is "`realPosture` RED as well". Neither asks that `realPosture`'s own at-act line show
  `key=true` and `fr=true`. If the wait runs out (the H2 worry itself — a posture this host cannot reach on
  this toolchain): a GREEN run sends the member down arm A as "a posture no person can type in" while no run
  ever observed the posture a person types in, and arm A's fix (the same bounded wait in `host`) then passes
  for "turns elapsed"; a RED run sends it down arm B as "a product mechanism in a posture a phone can be in"
  when the posture was not one.
- *Fix.* Add one line to "Combinations no arm maps": `realPosture`'s `waited spins=300`, or its at-act
  snapshot or VERDICT showing `key=false` or `fr=false` ⇒ no arm from this window; the unreachable posture is
  itself the finding, recorded with the snapshot; the orchestrator decides after. And in arm A's fix shape:
  after its bounded wait, `host` states what it waited for (an expectation that the window is key and the
  view first responder, its message naming the posture), so the caret tests can never run silently outside
  the posture they mean — the brief's "fix the posture so the test asserts what it means".
- *A second column the arms do not read, same class.* The desync needs two things, not one: the settle's
  write inside the transaction AND a report widened past the paragraph's terminator. I traced the other
  half: with the in-transaction write the report starts at 0 and the arming is rejected either way, but an
  unwidened `{0,5}` gives `fallbackVerdict` the old range `(0,8)` — block 0 exactly — and routes as
  `.block(0)` with no desync; only the terminator-inclusive `{0,6}` → `(0,9)` crosses the separator
  (`MobileEditorViewModel.swift:1962-1972`). TEXTKIT2 §3 (18k C8, macOS) records that this widening is
  decided by paragraph-style OBJECT identity, uniqued process-wide, so "any surviving text stack in the same
  process can change its answer" — unmeasured on iOS. The VERDICT line already prints `firstCharReport=`.
  So: where a red and a green case (M1 against a green M1, suite against real posture, alone against the
  pair) differ in that range while their postures agree, the answer is fixing's widening, not posture —
  neither arm as written; record both ranges and stop for the orchestrator. It also means M2's pre-read of
  the hand-break's reach holds only for a process in M2's state; the record's "SEEN red" rule already
  covers a teeth run that disagrees.

**R2-F3 · [MINOR for VM-17 — the probe's one remaining assumption; SPECULATIVE as to occurrence] ·
`App/Variorum/VariorumMobileTests/MobileFanBadgePlacementProbeTests.swift:163-178, 203-211` (reading (i)) and
the record's HOLLOW arm · (i) judges a badge against its own block's fragment frame, and whether that frame is
the truth for an off-band block on iOS is the thing nobody has measured.**
- *Mechanism.* (i) passes when the badge's block reports a `.layoutAvailable` first line within 1 pt of the
  badge. A stray badge is an off-band block's badge still at the y its load-time forced layout gave it. That
  badge and that fragment were written from the same forced layout, so they agree until TextKit moves the
  fragment. TEXTKIT2 §3 (VX-246) measured, on macOS 27.0, that frames do stand inconsistent after a
  mid-document forced layout (a fragment 996–1,662 pt off its settled place, uncorrected even by a whole
  `.ensuresLayout` walk) and that "the next viewport pass re-positions every fragment". (i) is sound exactly
  when that second sentence holds on the phone's OS (iOS 26.2 — a different platform and an earlier release;
  the note says re-measure per release). If the pass re-positions only what it lays out, an off-band
  fragment keeps its estimated frame, the stale badge agrees with it, (i) is green, and the badge stands in
  the viewport beside another block's text — the form of the defect F2 was written to catch.
- *Why it is only MINOR.* Under the canon's measured behaviour (i) is right, and round 1's vacuity is gone:
  the walk and the jump both put off-band badges in front of it. This is the residue, not a second F2.
- *Fix (the implementer's; cheap before M5, a re-run in the second window after it).* Add (i′), independent
  of the block's own frame: for every drawn badge meeting the visible rect, ask TextKit what stands AT the
  badge — `textLayoutManager.textLayoutFragment(for:)` at the text's leading edge, 1 pt under the badge's
  top, in container coordinates (the call the product's own swipe hit-test resolves through,
  `MobileTakesChrome.swift:538`) — and expect that fragment to begin at the badge's own block offset; a miss
  prints `VM17|astray|` naming the block it stands beside. And one sentence in the HOLLOW arm: the verdict states its reach — reading 2's
  largest distance beside the band's pad (one viewport of characters each side, `nearViewportBand`); if no
  load-time estimate on this note was off by more than the band re-resolves before it is seen, "hollow"
  is shown for notes of this size, and VM-179 inherits the question for longer ones with those numbers.

### NIT

- **R2-N1 · `MobileBookDetails.swift:639` (round 1's F5 label), with `:557` · the row's label now hides its
  caption from VoiceOver.** `.accessibilityLabel(verb)` on the row's `Button` replaces the label SwiftUI
  built from the row's two texts, so VoiceOver now reads "Finish" where it read "Finish, Finished means the
  table of contents is done…" — the sentence VM-81 (W-106) just made true. The Unarchive row, new in this
  run, does the same to its pause sentence ("Collecting is paused while this book is archived."); Archive and
  Delete did before this run. The hosted guard's exact-label match is the evidence that the label is the
  verb alone; that the caption was read before is SwiftUI's default for a button with no label of its own,
  by reading, not by a run. Fix: keep the verb as the label and give the caption as `.accessibilityHint` (or value) on the
  rows that have one. Pinnable: `surface.element(labeled: "Finish")?.accessibilityHint ==
  BookStateCopy.finishedMeans`, red on the tip. Small, and the house pattern on four rows — say which rows
  are in scope if it is taken.
- **R2-N2 · the run record, the fix-pin window's recipe.** The `ONLY` array still lists
  `MobileTutorialLibraryWalkTests` and not `MobilePocketGuideDeletionTests`, while "Expected RED … five" names
  the latter's pin and the section says "corrected". Run as written, the recipe again skips F4's pin. Either
  add the type or mark the array "as run in window (5)" and put the follow-up's one-type invocation beside
  it. The wrong type came from round 1's own text (its F4 and its final call's ten types), and both fix-pass
  commit messages carry it; history stays as it is.
- **R2-N3 · the run record, arm A, teeth-red.** The one-function filter
  `…/aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)` must be quoted: zsh reads the
  unquoted parentheses as a glob qualifier and stops with "unknown file attribute" before `xcodebuild`
  starts (checked with `zsh -c 'echo …'`). Loud, not silent, and the "1 test in 1 suite" check covers a
  filter that runs nothing — but the line should be paste-ready.
- **R2-N4 · the Unarchive row, the double-press road of F3.** Each press starts its own task; a second press
  that lands before the first one's re-read removes the row ends with the alarm line "That book isn't
  archived any more — nothing changed." under a book her first press did unarchive. True, and rare (the op
  and the re-read are milliseconds). An in-flight latch on the row (the undo door's `inFlight`) would keep
  the sentence for the real race — the book unarchived elsewhere. Not worth a change before VM-62 sweeps
  this function; named so the sweep sees it.
- **R2-N5 · the run record, small drift.** M7's row and the F7 line cite `MobileLivenessTests` `:1102-1108`
  for the voice flip; after N5's edit it is `:1104-1111`.

## What is still owed (round 1's F1, as ruled — not a new finding)

A further fresh round reads, as new work: window (3)'s outcome for batch C (whichever arm VM-24 takes, the
VM-17 verdict, VM-19's red and green, the instruments' removal commit); F4's pin shown red and green; VM-16
re-landed on the message seam that arrives with main; and whatever R2-F2 and R2-F3 change. Still pending by
the record's own account: the walk, the whole phone target, the Mac leg on the merged tree, the closeout.

## The clean bill — what I checked and found solid

- **Nothing outside `App/Variorum/` and the record.** No `Sync/`, custody, schema or core line; every write
  the changed doors make is an existing operation. Nothing new scales with the corpus.
- **The fix pass, product side.** Four files: one arm in `refusal`, the confirm's subject taken from the
  confirm, one label, two comments; the lesson's two sentences; `rowTitle`'s overload; a `Shared/` comment.
  I read each against its final call and against the code it calls (`unarchiveReading`'s own guards are
  `readingNotFound` and `readingNotArchived`; `lockReading` is safe to call on a book finished meanwhile;
  `RecoveryCopy.rowKind(item)` names a version, a gathering and every other kind as the row's meta line
  does).
- **The fix-pin window's GREEN leg** is in a readable bundle: 75 tests in the ten types, 0 failed, the one
  expected failure the designed `MobileTrashTests` diagnostic; F3's pin, N2's pin, F5's two hosted guards,
  the write-back assertion, the cancel pin and N1's guard are in it by name and passed; F4's pin is not in
  it, as the record says.
- **The four reds of that window, by reading** (the red bundle does not read — R2-F1): F3's pin on the
  pre-fix tip gets `DeletionRefusal`'s raw fallback; N2's gets "(empty note)"; F5's two hosted guards cannot
  find a control labelled "Finish" (the old row had no label of its own, and the driver matches a label
  exactly), which is the reason the record gives.
- **The rewritten probe compiles and is the binary the window will run.** The last `build-for-testing` log
  ends `TEST BUILD SUCCEEDED` at the minute of `e3f406086`/`839d86dd9`; the test binary in
  `DerivedData/vm78-ios` is from that build and carries the new reach message; the fix-pin window did not
  rebuild into that folder (its products are untouched since 06:00).
- **The probe's shape.** Reading 1 an expectation; reading 2 printed only; (i), (ii), (iii) as called; the
  walk re-reads the live end at every step and overlaps its stops by a fifth of a viewport, so every y is
  on screen at some stop; the jump road is the product's `jumpToBlock`, far to near, on its own cold mount;
  every read in `checkViewport` is unforced; non-vacuity is asserted (22 fans, a note that dwarfs the
  viewport, reach on both roads). The main test plants no responder and flips no global, so it can stay in a
  whole-target run. Operator precedence in the two `?? false` lines is as intended.
- **The chrome the probe reads** (`MobileTakesChrome.refresh`): the band skip, the forced
  `firstLineGeometry`, the frame written in content coordinates — the probe's coordinates are the same
  (`textContainerInset.top + fragment minY` on both sides).
- **Batch C's arms.** F6's two halves and F7's are in the record as called. The hand-break reaches the
  fixed test only through a widened report, as the record now says, and the "read M2's `didProcess … range=`
  first" step is the right guard. The unmapped posture case is left undecided for the orchestrator with the
  trace in hand — right. I looked for a product road that could make "no person can be in that posture"
  false: the phone's own programmatic input road (`MobileMarkdownActs.inputReplace` — select, then
  `insertText`, no turn between) runs from the keyboard bar, hardware Tab and the clamped in-block edit,
  all with the view first responder in a key window; the hardware-keyboard case is the keyboard-only
  difference arm B already owns.
- **VM-19.** `leave` ends editing in the window before hiding it; the `defer` and the explicit call are the
  same idempotent teardown; the cancelled arrival task cannot re-raise focus after it.
- **The whole diff, re-read for what round 1 might have passed.** VM-16's three arms on both directions and
  no other reader of `undo(with:)` / `redo(with:)` on the phone; VM-43's one call site (grep: one
  `restoreCommit(` under `VariorumMobile/` and `Shared/`), flush first, insurance inside the op's
  transaction; VM-84's mirror set at the one place `header` is assigned; VM-33's flag lowered at restart and
  raised only by a value; the hoists byte-identical with the Mac files extending the shared enums; the
  shelf's order the Mac Bookcase's rule; the row menu a data table; the "smart" word gone from the faces
  the brief names, the two that remain (`MobileTodayDoor.swift:70`, the guide) assigned elsewhere; the
  collect receipt the Mac chip's composer. An archived book's Details now also draws Finish and, on a
  journal-trait book, Use as Daily Journal: both are legal operations on an archived book
  (`lockReading`, `setDailyJournalBook` carry no archive guard; AppSpec §9 holds Finished and archive
  orthogonal and lets the daily Journal be archived), so no door there is drawn that cannot act. The
  pocket guide's seeding door is Debug-only, so the two reworded lessons reach no real store and need no
  re-seed road.
- **Her rulings, against what is built.** Order a–z with the choice left to wave 3; the collect receipt
  kept and made true; no line for an ordinary act (Unarchive speaks none — the Mac's "what came back" receipt
  is the Mac's; her receipts ruling governs the phone); refusals in sentences on every road this run opened.
- **Commits since round 1.** One piece each, pins ahead of fixes, no trailer, no home path, no device id,
  public wording.
