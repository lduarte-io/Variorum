# VM-78 — ladder round 1: the cold review's findings

**Reviewer:** `fable-reviewer`, a fresh session with no implementation context, running
`notes/REVIEW_PROMPT.md` verbatim. **Diff:** `git diff e48ef2f30..988e9434f` on `vm-78-fixes-to-whats-there`
(27 commits, 43 files). **Anchor:** `notes/plans/fixes/vm-78-fixes-to-whats-there.md`. **Date:** 2026-11-19.

## What this round read and ran

- Read myself, whole: the run record; `notes/REVIEW_PROMPT.md`; CLAUDE.md and its loaded canon;
  `notes/TEXTKIT2_NOTES.md` §2–4 (the diff touches the phone's editor view model and a TK2 probe);
  `notes/MobileSoul.md` §2–5; `notes/SurfaceContracts.md`, The Bookcase and books; the master work list's
  rows for the ten members; the whole diff; the changed product files at the tip (`MobileBookDetails`,
  `MobileUndoDoor`, `MobileShelfFaces` and the three new test files whole, the rest in the regions the diff
  touches and their callers); the core operations and queries the changed doors call (`UndoStack`, `restoreCommit`, `lockReading` /
  `unlockReading`, the archive family, `bookshelf`, `pendingArrivalCount`, `liveMemberNoteCount`,
  `starredReadingRows`); the Mac doors the phone now mirrors (`ShellActions.structuralUndo/Redo`,
  `BookStateDoors.open`, `RecoveryViewModel`'s listing gate, `MembershipChip`).
- Not triggered: SyncSpec, CastleRules, MCPSpec — the diff has no line under `Sources/`, no schema, no
  custody, no protection sentence (verified: `git diff --stat` names nothing outside `App/Variorum/` and
  the record).
- Ran: nothing on the stage (other sessions hold it). No `swift test` either — the diff changes no core
  file, so the core suite has nothing of this run's to say. No `build-for-testing` of my own: the two
  DerivedData folders in this worktree belong to live work, and a second full build would only re-prove
  a compile the record's logs already show (below).
- Evidence I located for the record's load-bearing claims: the batch B GREEN run's result bundle in the
  orchestrator's throwaway checkout (68 tests, 67 passed, 1 expected failure, 0 failed — it matches the
  record's line); the last batch C `build-for-testing` log ending `TEST BUILD SUCCEEDED`, written at the
  minute of `fec0e478b`; `git diff --stat 0abaf3938..HEAD` empty over `Shared/`, the Mac app and its
  tests (so the Mac build at `0abaf3938` is the tip's); every `-only-testing` TYPE name in the record's
  three invocations and the Mac leg resolves to a real suite (28 phone, 17 Mac — a misspelt type would
  run nothing and read green). **Not located:** the batch B RED run's result bundle (only the green one
  is on disk). I read each of the seven pins against the pre-fix code instead and each is red there by
  assertion; see the clean bill.
- **Review foci:** the run record has no "Review foci" section and no brief file beside it, so there are
  none to answer.

## Findings, by severity

### MAJOR

**F1 · [MAJOR — coverage, not code] · the run record, BATCH C — LIVE STATUS and "The run's state when
ladder round 1 opened" · this round cannot give the run its clean bill, and the ladder must not close on
it.**
- *What.* The cold review covers the whole run's diff (CLAUDE.md, "A RUN bundles small tickets"). At the
  tip under review that diff does not exist yet: batch C has run no window — VM-24's cause is untraced,
  VM-17 is undecided, VM-19's pin has never been seen red — and its record pre-decides arms that end in
  product lines this round cannot read (arm B: `MobileEditorTextView` / the gate delegate /
  `Shared/EditorBrain`, the editor seam; VM-17 red: `MobileTakesChrome`). Batch A's twenty-one reds, its
  green, the Mac leg over the hoisted words and the walk are all still PENDING.
- *Evidence.* The record's own table: batch A "PENDING — stage window (1) is queued"; batch C "half 1
  only … VM-24's cause is not yet traced and VM-17 is not yet decided real or hollow".
- *Why it is ranked.* Tonight's rule closes the ladder on a round with no BLOCKER or MAJOR. Were this
  round's code findings all MINOR, the ladder would close with batch C's outcome never cold-read — and an
  editor-seam change with no Fable review is exactly what CLAUDE.md forbids.
- *Fix.* A fresh round after windows (1) and (3), anchored on this file, reading: whatever window (3)
  lands (as NEW work, not as a fix re-check), batch A's red/green lines, and this round's fixes. If
  window (3) lands only test files and record text, that round is short; it is still owed. No pin — a
  process finding.

**F2 · [MAJOR for VM-17 — the probe is the member's whole evidence] ·
`App/Variorum/VariorumMobileTests/MobileFanBadgePlacementProbeTests.swift:205-221` (reading 3), with
`:197-203` (reading 2) and the record's pre-decided arms · reading 3 cannot see the form this defect would
take on the phone, and can go green or red for reasons that are not about a visible badge.**
- *The product mechanism the probe has to catch (traced).* At load the `.document` pass resolves EVERY
  fanned block's badge by `firstLineGeometry` (`MobileTakesChrome.swift:211`), which forces
  `.ensuresLayout` from the block's own mid-document offset (`MobileEditorTextView.swift:611`), and
  writes the frame in content coordinates (`MobileTakesChrome.swift:218`). On every later scroll tick
  (`layoutSubviews` → `.nearViewport`, `MobileEditorTextView.swift:347`) a fanned block OUTSIDE the band
  is skipped and "the badge's last resolved frame stands" (`MobileTakesChrome.swift:206-209`). TEXTKIT2
  §3 (VX-246, measured on macOS 27; not yet measured on iOS) says a mid-document forced layout places
  fragments at ESTIMATED offsets and a later viewport pass re-positions them. If that holds on iOS 26.2,
  the user-visible defect is not "a badge at block 1": it is a STRAY badge — an off-band block's stale
  frame standing inside the viewport, beside text that is not its block.
- *What reading 3 does instead.* It scrolls to `truthY − 120` (`:209-210`), where `truthY` is the
  IDEALIZED whole-walk layout's y (`:160`, `:177`), not the live surface's; it then compares the targeted
  block's badge with that same block's live fragment (`:212-217`). It never asserts the block is inside
  the viewport, never asserts the fragment is laid out (`laidOut` is computed at `:141` and only printed
  at `:219`), and never looks at any OTHER badge in the viewport.
- *Wrong outcomes this allows.* (a) FALSE GREEN: if the live layout puts block k a few hundred points
  from `truthY`, block k is not on screen; when it is inside the band the tick has just re-resolved its
  badge from the same fragment the test then reads, so the comparison is true by construction — and a
  stray badge of another block in the viewport is never inspected. The record's arm then reads "all three
  readings green ⇒ HOLLOW" and closes the ticket. (b) FALSE RED: when block k is outside the band its
  badge keeps its load-time frame while the fragment may have moved; the test reports "a visible badge
  stands off its block" for a badge that is not visible, and the arm sends the member to a product
  change in `MobileTakesChrome`. Whether (a) or (b) occurs depends on the size of TextKit's estimate
  error on this note, which nobody has measured on iOS — **SPECULATIVE as to occurrence; the missing
  assertions are concrete.**
- *Reading 2 and its arm.* Reading 2 compares off-screen badges with the idealized layout, so by TEXTKIT2
  §3's own finding it is expected red on any long note. The record's arm treats "(2) red alone" as red by
  the brief's wording with the fix shape already named. Read alone it cannot tell a harmless estimate
  (re-resolved before it is ever seen) from a harmful one (a stray). Reading 3, made valid, is what
  decides.
- *Fix (the implementer's, before window (3) runs — it is cheap now and expensive after).* Replace
  reading 3 with the invariant she would actually see, checked at several scroll positions reached by
  the LIVE surface's own geometry (the product's scroll-to-block road or `scrollRangeToVisible`, never
  `truthY`): after the settle, (i) every badge view whose frame intersects the visible rect belongs to a
  block whose live first-line fragment is `.layoutAvailable`, inside the visible rect, and within
  tolerance of the badge; (ii) every fanned block whose live first line is inside the visible rect has
  its badge on it; (iii) non-vacuity — at each stop at least one fanned block is asserted on screen.
  Then decide: (1) red ⇒ the pile, as recorded; (3′) red ⇒ real, fix with it as the pin; (2) red with
  (1) and (3′) green ⇒ TextKit's estimate, recorded as such, NO product line changed, the probe kept as
  the guard. The pin for any fix is (3′) itself, red on the unfixed chrome.

### MINOR

**F3 · [MINOR — bug class, pinnable] ·
`App/Variorum/VariorumMobile/Features/Shell/MobileBookDetails.swift:250-253` (`unarchive`) through
`:348-362` (`refusal`) · the new Unarchive door dumps raw error text on its one foreseeable refusal.**
- *Mechanism.* `unarchive()` → `run` → `Self.refusal(error)`. `refusal` has two arms
  (`.duplicateBookName`, `.readingSealed`) and then `DeletionRefusal.words`, whose `default` is
  `fallback`: "That couldn't be done — readingNotArchived(id: "…")." (`Shared/RecoveryActs.swift:239-247`).
  `unarchiveReading` throws `readingNotArchived` when the book is no longer archived
  (`Operations+ReadingArchive.swift`, `unarchiveReading(_:id:now:)`'s guard). Two roads reach it: the
  book unarchived on the Mac while this sheet is open (the sheet reads once and after its own acts, it
  holds no observation), and a second press landing before the first one's re-read removes the row — the
  same double-press race `DeletionRefusal`'s "already BACK" family was written for.
- *Why it is this run's.* The door is new here (VM-81 · W-120); the kickoff's rule is "a refusal always
  speaks a sentence, never raw error text"; the shared table already has the sentence ("That book isn't
  archived any more — nothing changed.", `Shared/OpsRefusalTable.swift:373-374`); and
  `archiveDailyJournal()` twenty lines below routes through that table already (`:314`).
- *Fix.* Add `.readingNotArchived` to the arm that already forwards `.readingSealed` to
  `OpsRefusalCopy.words(for:roads: .phone)`. One line; it sits at the site VM-62 will sweep, so name it
  in the handoff to that run.
- *Pin (red on the tip).* Archive a book, `await model.refresh()`, unarchive it through `ops` directly,
  then `await model.unarchive()`: `model.lastError == "That book isn't archived any more — nothing
  changed."`. Today it is the raw fallback.

**F4 · [MINOR — bug class, pinnable] ·
`App/Variorum/VariorumMobile/Features/Tutorial/MobileTutorialSeeder.swift:280-282` · VM-83 made a
pocket-guide sentence false, in the same run that fixes VM-3 for exactly that reason.**
- *Mechanism.* The "getting around" lesson still seeds: "…with this one pinned first — pinned books
  always sit first, and a long press on a book row pins or unpins it." VM-83 (W-071) removed the Pin
  door (`MobileShelfRowAct` has `star`, `archiveDailyJournal`, `delete`), so a long press now offers
  Star / Unstar and Delete. The same paragraph already says, truthfully, that a long press stars.
- *Evidence that this class counts here.* VM-3 is this run's own member for a lesson that outlived its
  behaviour; `MobileTutorialLibraryWalkTests.theShelfLessonDescribesTheShelfThatExists` exists because an
  earlier review found "the pocket guide now describes a shelf that does not exist". The record's
  "Seen, NOT changed" list for VM-83 names the guide's "smart book" phrase (VM-212) but not this
  sentence, which was true until this run.
- *Fix.* The smallest true wording, as a DRAFT for her wording pass and listed with the others — for
  example "…with this one starred first — starred books always sit first." and the pin/unpin clause
  dropped (the paragraph's later sentence about starring already teaches the door). If the orchestrator
  would rather leave every guide word to VM-212, then the record must say so by name and her handoff must
  carry it; silence is the one wrong answer.
- *Pin (red on the tip).* In `theShelfLessonDescribesTheShelfThatExists`: the prose does not contain
  "pins or unpins".

**F5 · [MINOR — evidence gap] · `MobileBookDetails.swift:456-471` (the Finish confirm's alert host) ·
no pin drives the confirm's FACE, which is where this app's confirms have failed before.**
- *What.* `MobileFinishConfirmTests` drives `requestFinish()`, `confirmFinish(_:)` and `cancelFinish()`
  on the model. Nothing hosts `MobileBookDetailsSheet`, activates Finish, reads the presented alert, and
  presses its button. The binding setter (`finishConfirmPresented`), the `presenting:` capture and the
  action's `Task` are therefore proved only by reading — the exact seam of batch 4.5b's BLOCKER ("the
  projection alone presented perfectly and then confirmed NOTHING", this file's own comment at the
  shelf's host).
- *I read it and it is right:* the confirm rides `presenting:`, the act takes its subject as a
  parameter, the setter only clears. The walk row will prove it by use. A hosted pin makes that
  permanent.
- *Fix.* One hosted test on `MobileDeletionTests.theBookDetailsDeleteRowPresentsTheRealConfirm`'s
  template: a book with two waiting arrivals → activate the Finish row → `presentedAlert` title and
  message exact → press Finish → the book is locked and nothing waits. (The Finish row has no
  `accessibilityLabel` of its own, unlike the archive, unarchive and delete rows; give it the verb so the
  driver, and VoiceOver, can name it.) A guard, green on the tip by design — say so; it is not a
  red-on-old pin.
- *With it:* `cancelFinish()` has no production caller — the alert's Cancel is an empty closure and the
  binding setter does the clearing — so `cancellingTheConfirmLeavesTheBookAsItWas` proves a road the face
  never takes. Either call `model.cancelFinish()` from the Cancel button or delete the method and let the
  hosted pin press Cancel.

**F6 · [MINOR — advance guidance on a pre-decided arm] · the run record, BATCH C, "What each outcome
means" · arm A's classification rule and its proof of teeth are both a step short of the brief.**
- *The classification.* Arm A reads "TEST POSTURE" when `realPosture` is green and the suite's posture
  shows `key=false` / `fr=false` / "a keyboard mid-presentation". The first two are postures no person
  can type in. The third is one a person can be in (she taps into a note and an input-system replace
  lands while the keyboard is still rising). If the trace shows key and first responder TRUE in both
  postures and only the keyboard's presentation differing, that is a product mechanism in a narrow
  window, not a test posture: take arm B's protocol — stop, report, no seam line touched — and let the
  ruling decide whether the window is reachable enough to fix.
- *The teeth.* The brief asks to "show the same assertion still goes red when the product rule it guards
  is broken by hand". The teeth instrument is a different test, asserts nothing, runs in the suite's
  posture, and breaks the rule test-side; it shows that a face write joining the transaction desyncs,
  from which red is inferred. The record already names the direct proof: the one-line product hand-break
  at `Shared/EditorBrain/EditorEditRouting.swift:148`, uncommitted, restored by `git checkout HEAD --`,
  run against the FIXED `MobileMarkdownCaretTests` test in the real posture. Use that as the proof and
  keep the teeth run as supporting evidence.
- No pin — guidance for window (3); SPECULATIVE by nature until the trace is read.

**F7 · [MINOR — gate precondition] · `App/Variorum/VariorumMobileTests/MobileCaretReplaceTraceTests.swift`
(three suites) and `MobileFanBadgePlacementProbeTests.vm17CostNote_theDocumentPassOnALongFannedNote` ·
the instruments must leave before any whole-target run, not merely before the merge.**
- *Mechanism.* The file's own header says each suite is "run ALONE by type name so no instrument's
  posture reaches another". That isolation exists only under `-only-testing`. In the whole phone target
  (the merge gate) they run in one process with every other `@MainActor` suite, interleaved at
  suspension points: `MobileStaleResponderTraceTests` builds a stale first responder in a hidden frame
  window on purpose (`:580-595`) — VM-19's own polluter — and the trace suites flip the global
  `MobileEditorStyle.voice` (`:461-462`, `:605-606`). They assert nothing, so they cannot go red; they
  can only redden somebody else.
- *Fix.* The named removal commit lands BEFORE the gate's whole-target run, and the gate's result line
  is taken on the tree without them. Record the cost note's numbers first, as planned.

**F8 · [MINOR — a question for `notes/QUESTIONS.md`, not a ruling] ·
`App/Variorum/VariorumMobile/Features/Write/MobileMembership.swift:89-96` against
`App/Variorum/Variorum/Features/BookView/MembershipChip.swift:136-145` · the two platforms now answer
"Diverge on a gathering's row" in opposite ways, and each cites her.**
- The phone no longer draws the door (W-110, the approved catch-up plan: "a door drawn where it can't
  act"). The Mac's chip draws it and refuses with a road, and its comment calls that "her ruled shape —
  silence where the row looks actionable is the confusion"; the parity round's record said the phone
  mirrored that on purpose. I could not find her words for either reading in canon (the 13f record
  endorses the refusal's SENTENCE, not the door's presence). MobileSoul §3: a behaviour difference is a
  ruled compromise, recorded, or a bug.
- The record carries this as "one platform difference to know". It should be filed as a question at the
  merge — which is the rule, and does the Mac follow (a VX ticket) or the phone revert? Until she
  answers, the phone's choice stands as PROVISIONAL, since it is the newer written plan.

### NIT

- **N1 · coverage lost with `MobileBookPinTests`.** The retired test was the only one that toggled the
  star AFTER the shelf's observation had started and watched the order follow. `MobileShelfOrderTests`
  and `MobileShellTests` both star before `start()`. The mechanism is sound by reading (`bookshelf` reads
  `starredReadingIDs` inside the observed closure, so both star stores are in the held region). One
  added step in `MobileShelfOrderTests` — toggle through `MobileStarsModel.toggle(.reading(id), from:
  .shelf)` after `start()`, settle on `orderedBooks.first` — puts the guard back.
- **N2 · `MobileTrashView.swift:313`.** `rowTitle` has the row in hand and calls
  `RecoveryCopy.rowKind(item.kind, isGathering:)`; the shared file says "prefer the item overload …
  wherever the row itself is in hand". `RecoveryCopy.rowKind(item)` gives the same answer for a
  gathering and also names an untitled saved version by its own word instead of "(empty note)".
- **N3 · `MobileBookDetails.swift:228-235`, `:111-117`.** `confirmFinish(_ confirm:)` never reads its
  parameter; `FinishConfirm.pendingArrivals` is read by tests only. Harmless, and the parameter is the
  house rule's shape — say so in the doc comment or drop the unused field.
- **N4 · stale words left behind by this run's own changes.** `Shared/BookcaseBoard.swift:15-17` still
  says `ShelfOrder` "keeps the phone's shipped pin-then-journal order until the phone's catch-up adopts
  this"; `Sources/VariorumCore/Queries/ShelfQueries.swift`'s `bookshelf` doc still says the pin/journal
  ordering is the view model's call over `shelfPins`; `MobileShellTests`'
  `theShelfObservationDeliversBooksPinsAndTheDailyMark` keeps "Pins" in its name and "the pinned book
  leads; the journal follows" in its message. Comment and name edits only (the core one can ride any
  later core touch — this run is right not to open `Sources/` for a comment).
- **N5 · `MobileLivenessTests.swift:1063` and `:1086`.** `Self.leave(window)` runs on the success path
  only and the old `defer { window.isHidden = true }` still stands beside it. Nothing between them
  throws today, so it holds. Make the `defer` call `Self.leave(window)` (it is idempotent) and keep the
  explicit call and its expectation where they are: the teardown is then certain on every exit and the
  second hide is gone.
- **N6 · `MobileShelfViewModel.swift:100-102`.** `orderedBooks` is a computed sort with
  `localizedStandardCompare`, read three times per shelf body (`MobileShelfView.swift:96` for a `.count`,
  `:197`, `:203`) and three per Library body. ∝ the number of books, so P1 holds; it is simply sorted
  more often than it changes. Sort once where the observation delivers, or read `books.count` for the
  counts.
- **N7 · `MobileGatheringWordTests.noRenderedStringInTheseFacesSaysSmart`.** The brief asked for a sweep;
  this is a hand-kept list of fifteen strings, so a new "smart" literal in these faces would pass. The
  Mac bans dead spellings by scanning source (`DeadVocabularyTests`); when VM-85 and VM-212 retire the
  last two phone sites, that mechanism is the one to adopt for the phone.
- **N8 · `MobileBookDetails.swift:146-152`.** The comment says `liveMemberNoteCount` is "the set the
  shelf's count counts". The shelf counts live member ROWS without joining the note
  (`bookcaseMemberCountsSQL`, a deliberate P1 choice for a held read); this one-shot read joins the live
  note. Equal in a settled store; say "the same members, read with the note's liveness" so nobody later
  "fixes" one to match the other.
- **N9 · for the walk, SPECULATIVE.** `MobileBookDetailsSheet` is a fixed `VStack` in a medium detent,
  not a scroll view. This run adds a row (Unarchive, with a pause sentence of up to three lines) and
  lengthens the Finish caption to a three-line cap. The tallest case — an archived journal-trait book
  with a rule, a refusal line showing — may not fit the medium detent at the larger text sizes. Capture
  that case in the walk before calling the face done.
- **N10 · the class VM-33 fixes stands in sibling rooms — for the closeout's reconcile step.** By reading,
  the same shape is in the Archive room (`MobileArchiveView.swift:74`, "Nothing archived." on
  `model.visible.isEmpty`; `MobileArchiveModel.archived` starts `[]` with no answered flag) and in a
  book's contents (`MobileBookView.swift:100`, "No notes in this book yet."; `MobileBookViewModel.entries`
  starts `[]`), each filled by a `.task` that starts after the first render. Not run, so SPECULATIVE as
  to whether a frame is seen; the Trash's own pin went red on exactly this mechanism. The work list
  carries only the Trash (W-057). Not this member's to fix — name them in the closeout so a ticket, or
  wave 2's room work, owns them.
- **N11 · evidence kept.** The RED run's result bundle for batch B was not kept; only the GREEN one is on
  disk. For batches A and C, keep both bundles (or their summary JSON) until the run closes, so the next
  round can read the names rather than the record's sentence about them.

## The clean bill — what I checked and found solid

- **No `Sync/`, no custody, no schema, no core line.** The diff is `App/Variorum/` and the record. Every
  write the changed doors make is an existing operation (`restoreCommit`, `lockReading`,
  `unlockReading`, `unarchiveReading`, `deleteReading`, `collectPostIntoSmartReading`, `setStarred`), so
  S1–S5 and I1–I10 are untouched; nothing new scales with the corpus (the one new read,
  `archivedBook`, is three indexed probes for one reading; the shelf's held observation reads one
  statement FEWER than before).
- **Batch B's seven pins are red on the pre-fix code, by reading** (the RED bundle is not on disk, N11):
  the two undo pins because `undo(with:)` / `redo(with:)` hand back the label of a quiet press; the words
  pin because the old detail said "saved"; the restore pin because the commit run stayed `["manual"]`;
  the lesson pin because the seeded prose was the duplicate lesson; the date pin because the seam's
  `dateChipDay` read the unobserved `header`, so `withObservationTracking` registered nothing; the Trash
  pin because the body drew the line on `trash.isEmpty` before the `.task` could run. The GREEN bundle
  holds all sixty-eight.
- **VM-16 (the undo door).** `runUndo` and `redo` are the Mac door's three arms exactly
  (`ShellActions.swift:185-200`, `:228-239`): changed → the receipt and the other direction; quiet → the
  shared refusal and no action; nil → nothing to undo. I traced `UndoStack.undoReporting` /
  `redoReporting` (`UndoStack.swift:356-402`): a quiet half retires its entry and leaves the other stack
  as it was, which is the premise of the fix. The receipt's button also renders only while the stack
  holds that end (`MobileWriteView.swift:622-644`), so a landed undo of an entry with no redo offers
  nothing either. Both pins are red on the old `undo(with:)` shape by reading.
- **VM-20 (the warning's detail).** The hoisted sentence is byte-identical on the Mac (the removed and
  added lines compared; `UndoWarningWordsTests` pins the bytes) and the phone now says "committed". No
  shouted capital was carried.
- **VM-43 (restores).** One `restoreCommit` call exists under `VariorumMobile/` and `Shared/` and it
  passes `insuringBuffer: true` after the flush and the dirty check. I read the core body
  (`Operations+Variant.swift:218-233`): the insurance is inside the one transaction and deduped by
  `isDirty`. The pin holds the pending-typing case and the dedupe control.
- **VM-84 (the date chip — the editor seam member).** `entryDate` is set in `adoptHeader` beside
  `isSealed` and `displayTitle`, the file's own mirror pattern; `header` stays unobserved, so the
  keystroke road's reads did not gain an observer; the chip's three uses read one function. The pin's
  third arm (an unchanged header wakes nothing) is in the green bundle, which is the evidence that the
  macro's equal-value skip holds on this SDK. No `MobileEditorTextView`, `BlockRangeIndex`, gate or
  routing line is touched.
- **VM-33 (the Trash's first paint).** The gate is the Mac's rule line for line, including WHERE the
  flag is lowered (at `startTrash`, as `RecoveryView.swift:305`). A failed listing never raises it.
  Consequence shared with the Mac and not worth a finding: on a filter change away from an empty listing
  the old "empty" answer stands for the turn between the tap and the task's start.
- **VM-3 (the lesson).** The new two blocks say what `KeepOnTopDivide` does and what AppSpec §9 says; the
  walk pin now asserts top = two takes, bottom = one, original released whole, with no `withKnownIssue`.
- **The hoists.** `BookStateCopy`, `ArrivalsCopy.word`, the collect receipt family and
  `StructuralUndoCopy.discardingUndoDetail` moved verbatim. Checked mechanically: every code line removed
  from the four Mac files appears unchanged in the Shared files, bar one — the finish confirm's title
  literal, now `finishTitle(name)`, which composes the same bytes; the undo detail and the composed
  `CollectingCopy.finishedCaption` I compared by hand. The Mac files extend the shared enums, so no Mac
  call site changed. Words only — no door table, no confirm item, nothing reaching the capability
  registry moved. (The Mac leg that pins these bytes has not run yet; F1.)
- **VM-81.** The Finish confirm reads N by the dismissal's own predicate
  (`Queries.pendingArrivalRowsWhere`), the same read the Mac's `open(.finishBook)` makes, and acts at
  once when nothing waits. `finishRowAct` matches the Mac's table for books and gatherings; its one
  difference (Reopen stays on a sealed book and explains) is the work list's W-106 and is recorded as a
  fork to retire at W-070/W-112. `unlockReading` really is legal on a legacy finished gathering
  (`Operations+Reading.swift`, the 13i-d U4 note), so that Reopen can act. The sealed sentence is the
  shared table's, with the phone's roads (`bookSeal.verb` is nil there). The archived book resolves
  through `Queries.reading`, which is tombstone-tolerant, so a DELETED book still shows nothing.
- **VM-83.** `BookcaseBoard.ordered(.alphabetical)` is the Mac Bookcase's rule; the star it floats is the
  union (`ShelfBook.starred` ← `starredReadingRows`), the same set the retired `shelfPins` read, so no
  book loses its place by the switch. The row's Star state (`MobileStarsModel.isStarred` over
  `Queries.starred`) reads the union too. `ShelfOrder.ordered`, its forwarder and both pins of the old
  rule went in one commit. Every "smart" literal the brief names is gone from those faces; the two that
  remain (`MobileTodayDoor.swift:70`, the guide) are the ones the record assigns elsewhere.
- **VM-21.** The phone speaks the Mac chip's composer; the op's own `starred` and `gatheringArchived`
  decide. The membership sheet is the phone's only picker fed by `Queries.readings`, and it marks
  archived books; the archived-gathering mark is flagged PROVISIONAL in the record, as it should be.
- **The seam commit (`7c9fc0151`) as batch A's "old".** I diffed it against the shipped files: it
  expresses the shipped behaviour through testable surfaces and changes none of it, so a pin red there
  is red on the product as shipped. By reading, each of the twenty-one named pins fails there by
  assertion and each named control passes.
- **VM-19's fix.** `window.endEditing(true)` before the hide is the right call on a `UIWindow`. Outside
  the spike scenarios three product sites call `becomeFirstResponder()` — the arrival, the emoji field
  and the takes card — and the window-hosted tests I found reaching them (`MobileTakesBrowserTests`,
  `MobileTakeStructureTests`) end their editing or resign before the window hides. That is a reading of
  the tests that mention a first responder or call those roads, not an exhaustive proof; the one-site
  fix matches the ticket. Its red on the hide-only teardown is still PENDING (M9), and a pin green on
  both sides there makes the fix hollow, as the record already says.
- **Commits.** Twenty-seven, one piece each, pin commits ahead of their fixes where a seam was needed, no
  trailer, no home path, public wording.
