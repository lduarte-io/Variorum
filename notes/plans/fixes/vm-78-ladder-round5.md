# VM-78 — ladder round 5: the cold review's findings

**Reviewer:** `fable-reviewer`, a fresh session with no implementation context, running
`notes/REVIEW_PROMPT.md` verbatim. **Diff:** the run's whole diff against merged main, `git diff ad5053002 HEAD`
on `vm-78-fixes-to-whats-there` at `861c053f0` (55 files; 41 of them code, all under `App/Variorum/`, none
under `Sources/`); the commits since round 4's review are `3396c4611..HEAD`. **Anchor:**
`notes/plans/fixes/vm-78-ladder-round1.md` … `-round4.md` (each round's findings and final calls) and the run
record's ladder tables. **Date:** 2026-11-19.

**The count: 0 BLOCKER · 0 MAJOR · 0 MINOR · 9 NIT, all new in this round.** No finding is against a product
line, and none says a test is wrong, on this tree. Six are sentences or slots in the record, the handoff and
one ledger row; one is three stale code comments to add to a ticket already on the to-file list; one is a small
duplication inside the guards' test file; one is a line for another owner. No finding is a `Sync/` line and
none is FINDER-FIXES. Under her standing rule the ladder closes here: this is the fifth round, and it found
neither a BLOCKER nor a MAJOR.

## What this round read and ran

- Read myself: `notes/REVIEW_PROMPT.md`; CLAUDE.md and its loaded canon; the run record's FOR A LATER READER,
  the live state, the kickoff and kickoff facts, batches B and A as briefed with their LIVE STATUS, "THE SECOND
  MERGE-IN" entire, "The ladder" entire, the Closeout entire; round 4's file entire (findings, both answers,
  the final calls, "The map, final") and the earlier rounds' disposition tables; the author handoff
  (`notes/handoffs/vm-78-handoff.md`) entire; the canon this run edited (the AppSpec §9 and OverallModel §3
  word-diffs, `notes/SurfaceContracts.md`'s five clauses by word-diff against main, `notes/MobileSoul.md` PL-78
  entire, the new block in `notes/TEXTKIT2_NOTES.md` §3).
- The code: every line of `git diff ad5053002 HEAD` outside `notes/` — the seven `Shared/` files, the six Mac
  files, the fourteen phone product files, the fourteen test files — and at the tip `MobileBookDetails.swift`,
  `MobileUndoDoor.swift` and `MobileMembership.swift`'s model whole, with the code they stand on:
  `MobileLine.swift`, `MobileWingScope.follow`, `MobileEditorViewModel`'s `adoptHeader` / `report` /
  `setEntryDate` / `confirmNoteStillLive`, `MobileTrashModel.startTrash`, `MobileBlockHistoryController.restore`,
  core `UndoStack.undoReporting` / `redoReporting` / `notifyWalk`, `restoreCommit`, `lockReading` /
  `unlockReading`, `setDailyJournalBook`, `Queries.bookshelf` / `bookcaseReadings` / `readings` / `reading` /
  `liveMemberNoteCount` / `pendingArrivalCount` / `shelfBookTags` / `ruleTagPaths`, `BookcaseBoard.ordered`,
  `RecoveryCopy.rowKind`'s three overloads, and the two test helpers the new guards lean on
  (`MobileNoRedirectSweepTests.stringLiteralContents(of:)`, `MobileNoRawErrorPinTests.strippingComments(_:)`).
- Not triggered: SyncSpec, CastleRules, MCPSpec — `git diff --name-only ad5053002 HEAD` names nothing outside
  `App/Variorum/` and `notes/`. TEXTKIT2_NOTES: the diff holds no TextKit line (the four chrome files equal
  main's); the new §3 block was read by round 4 against its logs and has not changed since.
- Ran, read-only (no stage, no `xcodebuild`, no simulator, no app):
  - no `swift test`: this run changes no core file and the worktree holds no core build (a cold build is
    outside this round's window);
  - `git fetch origin` (remote-tracking refs only): `origin/main` is still `ad5053002`, an ancestor of HEAD;
  - nothing under `App/`, `Sources/` or `Tests/` differs between `d55d22db9` (the tree the guards' window ran)
    and HEAD;
  - the second merge re-done with `git merge-tree --write-tree d73f63067 ad5053002`: the merge commit
    `d55d22db9` differs from git's own result in exactly two files, `notes/MobileSoul.md` and
    `notes/SurfaceContracts.md`; VX-981's merge changed zero bytes under `VariorumMobile/`,
    `VariorumMobileTests/` and `Shared/`;
  - the guards' window in its logs AND its bundles: `vm78-window-g-red.log` — 26 tests in 5 suites failed with
    7 issues, the four expected tests and no other, each on the lines the record names (G1's offenders
    `MobileWriteView.swift:449` and `:451`; G2's three literals; G3's four expectations, its premise and its
    "Quotes" expectation passing; the Book Details join at `:666` only), the five seam pins green on that red
    tree; `vm78-window-g-green.log` — 42 tests in 7 suites passed; `g-red.xcresult` (26: 22 passed, 4 failed)
    and `g-green.xcresult` (42 passed) both read with `xcresulttool`;
  - the second merge-in's two build logs end `TEST BUILD SUCCEEDED` with no `error:` line, each stamped with
    the commit it built (`1f0b23e20`);
  - G1's predicate by grep over HEAD: no hit (88 phone files, the model's own skipped); G2's: exactly the two
    exempt literals (88 phone and 148 shared files);
  - trial merges, nothing touched: with `origin/vm-47-sizes-and-look` at `85ffff986` (the same four content
    conflicts round 4 mapped) and with `origin/vm-64-timing-and-lags` at `beefc79f7` (clean) — read below under
    "What is still owed";
  - the Mac's `DeadVocabularyTests` predicate, emulated over the worktree (its three roots, its allow-list, its
    whole-word and phrase rules): 842 files, no offender — that type is in neither Mac tier list (R5-N2);
  - this run's added string literals under `Shared/` and `VariorumMobile/` against the phone's no-redirect
    rule (`/\bMac\b/`): none names the Mac.
- Not re-checked: the pre-merge windows and the re-land's window (round 4 read each log and bundle against the
  evidence table; nothing under `App/` this run wrote has changed since except the two guard test files);
  Linear's ticket states; `notes/plans/vm-78-orchestrator-handoff.md` (the orchestrator's own map).
- **Review foci:** the run record has no "Review foci" section and no brief file beside it, so there are none
  to answer.

## Round 4's final calls, re-checked

| Final call | What is on the branch | This round's reading |
|---|---|---|
| R4-F1, G1 | `MobileNoteEntryDateTests.noPhoneFaceReadsTheEditorsUnobservedHeaderDate` (`MobileMembershipTests.swift:396`, `43fec9e9c`) | built as called: the `#filePath` walk of `VariorumMobile/` with the model's file skipped and more than 60 files required, comment-stripped lines, the member-access pattern `\.header[?!]?\.entryDate\b`, offenders as `file:line`, the remedy in the message, the seam/face sentence in the date pin's doc. Seen red on the wrong side and green on the tree, in the log and the bundle |
| R4-F1, G2 | `MobileGatheringWordTests.noPhoneStringLiteralSaysSmart` (`MobileBookFixesTests.swift:749`, `e9823efaf`) | built as called: both roots asserted and walked, literals from the shared extractor (so the exemptions compare each literal's own contents — both exempt sentences are single literals in their sources, with a literal dash), the Mac's whole-word rule as a private copy with its five-case oracle, two exact exemptions each held to one match. Red on exactly the three literals, green on the tree |
| R4-F1, G3 | `MobileMembershipSheetFaceTests` (`MobileBookFixesTests.swift:957`, `905a12eb0`) | built as called: the fixture, the premise as a `#require`, the real sheet hosted under Study, five expectations each its own. Red on the four, green on the tree; the red log's label list shows the wrong face exactly ("Old projects", "smart", two "diverge") |
| R4-F1, the red legs' four conditions | "The guards' window — RAN" | each met; the record's account matches the logs line for line |
| R4-F1, the process plan | (i)–(iv) as called; (v) departed from, by the stage coordinator's ruling, recorded with its reason in the live state | (ii): the second merge-in is git's own merge plus two notes resolutions, both of which keep each run's lines (word-diff against main shows this run's five SurfaceContracts clauses and nothing else; MobileSoul gains one row). (v): see "What is still owed" — the departure is the coordinator's to make, and what it costs is covered by (vi) and by this round's read of the VM-64 join |
| R4-F1, the map | "Lines for other owners", the last bullet but one; handed over at the merge | still true at VM-47's tip `85ffff986`: the same four conflicts; the wrong side of each still answers G1 and G2 red by grep; VM-47's type-scan pattern still flags the same ten lines, three of them outside any hunk |
| R4-N1 | the one hand-reverted line rode the red build | red at `:666` only, the book half green — in the log |
| R4-N2 | the sentences re-written (`3a09463cf`) | as called, the finals-ledger draft's false line included. The same class recurs in a few sentences those edits and the second merge-in left behind — R5-N1, R5-N2, R5-N3 |
| R4-N3 | the handoff's "Three canon lines I did not change, for your call"; to-file item 7 | as called; none of the three lines is edited |
| R4-N4 | the walk's rows re-worded, the date-chip row added | as called |
| R4-N5 | a line on VM-218; to-file item 3 folded | as called; no code |

## Findings, by severity

### NIT

- **R5-N1 · [NIT] · `notes/MobileSoul.md:359` (PL-78, the STILL OWED list); the record `:3807-3808` (the W-073
  reconcile), `:3934-3939` (the VM-212 and VM-85 owner lines) · three places still say the phone's source scan
  for "smart" is owed and arrives with VM-212. Round 4's G2 is that scan.** *Evidence:*
  `noPhoneStringLiteralSaysSmart` walks every string literal under `VariorumMobile/` and `Shared/` today, with
  two exact exemptions, each required to match once — the Today door's sentence (VM-85) and the pocket guide's
  (VM-212). So what those two runs owe changed with round 4's fix pass: when either rewords its literal the
  guard goes red on its own stale entry, by design, and the fix is deleting that entry — while the lines their
  kickoffs will read tell VM-212 to "adopt the Mac's source-scanning ban … in place of
  `noRenderedStringInTheseFacesSaysSmart`'s hand-kept list" and tell VM-85 nothing about an entry. PL-78 goes
  into a shared ledger on main saying something is owed that is built. *Fix:* PL-78 — "…the guide's other stale
  lines and its exempt "smart" literal in the phone's word scan (VM-212) · the Today door's "smart book" note
  and its exempt literal (VM-85)"; the reconcile bullet — "the source scan over every phone and shared literal
  is `noPhoneStringLiteralSaysSmart` (round 4, G2), the hand-kept list beside it checks the pure functions";
  the two owner lines — "when this literal is reworded, delete its entry from
  `noPhoneStringLiteralSaysSmart`'s exemption table (the guard goes red on a stale entry by design)". The
  history line at `:1230-1232` stays as written. While there: the Closeout's member rows name only the seam
  pins — add G1 to VM-84's "Pin", G2 to VM-83's, G3 to VM-21's and VM-81's.
- **R5-N2 · [NIT] · the record `:3704` (the evidence table's Gate 2 row), FOR A LATER READER's "gate 2, the Mac
  leg", the handoff `:6-8` and `:226` · gate 2 is described as "the Mac types over the changed `Shared/` files —
  tier 1's 17 and tier 2's", where the gate as the coordinator sized it is the WHOLE Mac target (the live
  state's 15:20 and 17:00 updates; "THE MERGE-IN" `:2761-2762`).** *Evidence:* the tier lists were built by
  grepping the Mac tests for the moved symbols, so they hold no Mac scan that walks `Shared/` without naming
  one: `DeadVocabularyTests` reads every code line under `App/Variorum/Shared` for "smart" as a whole word and
  eleven banned phrases ("shelf row", "pin to shelf top", "on the shelf" among them), this run added three
  files there and changed four, and that type is in neither tier and has not run on this run's tree (window
  (1)'s Mac leg ran its seventeen suites, this one not among them). Emulated in this
  round it answers nothing (842 files) — this run's new mentions all sit on comment lines — so nothing is wrong;
  the slot's wording is what could under-run the gate. *Fix:* the three places say "the whole Mac target (the
  coordinator's sizing; tier 1 and tier 2 are inside it)", and the gate's result line names
  `DeadVocabularyTests.noShippedWordSpeaksTheRetiredVocabulary` among what ran.
- **R5-N3 · [NIT] · `notes/handoffs/vm-78-handoff.md:231` and `:244-245` · two sentences in "The review, in
  plain words" are stale.** "A fresh reviewer read the run three times." is followed by an account of four
  rounds (and this one makes five); "three canon lines wait for your call (the section below)" points down at
  a section that stands above it. *Fix:* "A fresh reviewer read the run five times, a new reviewer each
  round."; "(the section above)"; and the paragraph's `PENDING(ladder round 5: its outcome)` filled from this
  file's count.
- **R5-N4 · [NIT] · `Sources/VariorumCore/Operations/Operations+Variant.swift:201`,
  `App/Variorum/Variorum/Features/History/CommitsFaceModel.swift:782`,
  `App/Variorum/Variorum/Features/Takes/TakesViewModel.swift:3228-3229` · three code comments still call the
  insured restore "PROVISIONAL P-849-1" after this run dropped the mark from AppSpec §9 and OverallModel §3.**
  Comment only; this run opens no `Sources/` line and neither Mac file is otherwise its surface, so no edit
  here. *Fix:* one more clause on to-file item 4 (the core doc line: `Queries.bookshelf`'s) — "and three code
  comments still mark P-849-1 PROVISIONAL (ratified, QUESTIONS #274 addendum 2)", with the three sites.
- **R5-N5 · [NIT] · the record's "To land on main at the merge" and "Not done" (`:4290-4291`) · the drafts for
  main are short by one, and one is incomplete.** "Not done" says no master-plan line was written and "their
  drafts are above", but the section drafts no closeout paragraph for `notes/DetailedPlanForPhases.md` — only
  the MOBILE PARITY line that goes inside it — and names neither the in-flight row's retirement nor the
  outgoing paragraph's roll to the archive, which CLAUDE.md's closeout ritual asks for. And the AppSpecRecord
  draft's "Cast" stops at the closeout drafters: round 4's fix-pass implementer and the second merge-in's
  implementer are not in it. *Fix:* draft the paragraph beside the others (or say plainly that the merging
  session writes it from FOR A LATER READER); add the two sessions to the Cast sentence.
- **R5-N6 · [NIT] · the record `:6-94` · FOR A LATER READER is 1,338 words; CLAUDE.md gives it at most a
  page.** Its "The evidence that matters" paragraph has grown by a window per round and now repeats, count by
  count, what the Closeout's evidence table holds. *Fix:* when the last slots are filled at the merge, cut that
  paragraph to the lines a later reader acts on — what was proved where, the five lost bundles, the ladder's
  counts, the three guards and the map — with a pointer to the table for the rest.
- **R5-N7 · [NIT] · `App/Variorum/VariorumMobileTests/MobileBookFixesTests.swift:814` and `:1011` · the
  whole-word rule is written twice in one file** (`MobileGatheringWordTests.containsWord`,
  `MobileMembershipSheetFaceTests.saysSmart`), a third and fourth copy of the Mac's
  `DeadVocabularyTests.containsWord`. One file-private function would serve both suites. Tidiness only: the
  two bodies are the same today, and G2's oracle would not see the other drift. No change is asked before the
  merge — the guards' compiled bytes are what the window ran; fold it into whichever run next opens the file
  (VM-85 or VM-212, when an exemption leaves).
- **R5-N8 · [NIT] · the record, Kickoff facts `:427-438` and batch A `:1032-1039` · two of her answers are
  quoted without the message they answer.** "book order - that's fine to leave it for wave 3. 2 - collect
  receipt your choice is fine." replies to a numbered message of the orchestrator's that the record does not
  carry, so what "it" and "your choice" stand for is the record's reading, not something a later reader can
  check. The reading is sound either way — the a–z rule is W-068 itself, in the plan she approved, and the
  handoff tells her in plain words what shipped ("Choosing a different order waits for the phone's Bookcase in
  wave 3, as you said.") — so nothing built is in doubt. *Fix:* one sentence beside the quote giving what was
  asked, marked as the orchestrator's words (as the VM-17 ruling's option text is).
- **R5-N9 · [NIT — a line for another owner; no code here] ·
  `App/Variorum/VariorumMobile/Features/Write/MobileMembership.swift:85-91` and `:147-159` · after VM-83 the
  phone orders the same books two ways.** The shelf and the Library's book rows sort a–z, case-blind and
  digit-aware (`BookcaseBoard.ordered`); a note's Books sheet still lists its member rows by Swift's tuple `<`
  (`MobileMembershipModel.ordered`) and its two add lists in `Queries.readings`' `ORDER BY name, id` — both
  binary, so with books "apple", "Book 2", "Book 10", "Zebra" the shelf reads apple · Book 2 · Book 10 · Zebra
  and the sheet reads Book 10 · Book 2 · Zebra · apple. Not this run's brief (W-068 names the shelf; the
  sheet's order is from before this run) and not a regression in the sheet itself. *Fix:* one line under
  "Lines for other owners" for VM-113's kickoff, beside N6's: decide whether the phone's pickers take the
  shelf's rule when the order becomes a choice.

## What is still owed (not findings)

- **The gate's three legs**, on the tree that merges: the whole phone target (one standing red by decision,
  VM-24's caret test), the whole Mac target (R5-N2), the simulator walk. None has run. A product line a gate leg
  forces is new work no round will read: an implementer writes it with its pin, the orchestrator checks it line
  by line against what forced it, and a line in `MobileEditorViewModel.swift` or the chip's view is asked of
  her before the merge (round 4's line; CLAUDE.md's seam rule).
- **The order of this round and the gate.** Round 4 called "the gate's READY first, round 5 on the
  coordinator's word that this run's gate is next"; the stage coordinator ruled the other order, and the live
  state records it with its reason (the tree the gate tests must be the tree that merges; a round-5 fix after
  the whole-target legs would cost them twice). Merge order and the stage are the coordinator's, so I take
  that as ruled and not as a finding. What it leaves open is the case round 4's (vi) covers: VM-64 merging
  first, and this run taking its merge in after this round.
- **That case, read now.** At VM-64's tip `beefc79f7` (which contains main `ad5053002`) the trial merge with
  this branch is clean in every file (tree `49e1c08a7`). In that tree:
  - the two editor-seam files differ from VM-64's own by exactly this run's VM-84 lines — the observed
    `entryDate` and its one set inside `adoptHeader`, `dateChipDay` and the chip's three reads of it;
  - `header` is assigned at one place, inside `adoptHeader`, and every header road (seven call sites) goes
    through it;
  - `MobileUndoDoor.swift` gains only VM-64's `inFlight` observer beside `undoReporting` / `redoReporting`, and
    no phone or shared line calls `undo(with:)` or `redo(with:)`;
  - `MobileMembership.swift` gains only VM-64's `refreshChip()`; the sheet's memberwise shape G3 hosts is
    unchanged;
  - G1's predicate finds no hit and G2's finds exactly the two exempt literals; one `restoreCommit` caller,
    insured; the Trash's answered gate intact; no reference to a symbol this run removed.
  The five shared files' blobs there are `1b4149904` (`MobileEditorViewModel.swift`), `d63f7af29`
  (`MobileWriteView.swift`), `645612238` (`MobileUndoDoor.swift`), `3e48ae264` (`MobileMembership.swift`),
  `00b5c086c` (`MobileLibraryView.swift`). If VM-64 merges first and this run's merge-in leaves those five
  files at exactly these blobs, that join has had a cold read to this extent — its text, this run's lines in
  it and the guards' predicates; not VM-64's own work, which is its ladder's. If any of the five differs, (vi)
  stands as round 4 called it, and a hand-resolved line in either editor-seam file is asked of her before the
  merge.
- **The merge moment's ledgers**, as the record lists them, with R5-N1's and R5-N5's sentences corrected first:
  PL-78 is pasted into main as it reads on the branch.

## The ladder after this round

**0 BLOCKER · 0 MAJOR · 0 MINOR · 9 NIT.** The cap of five is reached and nothing here would have earned a
sixth round. Every NIT is a sentence, a slot's wording or a line for another owner; R5-N7 asks for no change
before the merge; none touches a product line or a compiled test. They enter the cross-model flow like any
finding: the implementer's answers come back to this reviewer for the final calls. Each fix above is written
to be applied as it stands, so where an answer disputes nothing the finding's own "Fix" is the final call. As a
final round's fixes they are read by the orchestrator line by line against this file (CLAUDE.md).

## The clean bill — what I checked and found solid

- **Nothing outside `App/Variorum/` and `notes/`.** No `Sync/`, custody, schema or core line. Every write the
  changed doors make is an existing operation (`lockReading`, `unlockReading`, `unarchiveReading`,
  `deleteReading`, `restoreCommit(…, insuringBuffer: true)`, `collectPostIntoSmartReading`, the stack's
  `undoReporting` / `redoReporting`), so S1–S5 and I1–I10 are untouched. Nothing new scales with the corpus:
  the archived book's resolve reads one reading, its members' count and its chapters; the Finish confirm reads
  one indexed count. Nothing tracks word-level change or copies text across entities — the insured restore is
  the operation's own savepoint on the same take.
- **The three guards.** Each is the shape round 4 called, each was seen red on the wrong side for the reason it
  names and green on the tree, and each reads what it claims: G1 a member access on comment-stripped product
  lines; G2 each literal's own contents under both roots with its exemptions held to one match; G3 the real
  sheet's drawn labels after a premise that stops the test. None reads styling, so VM-47's restyle cannot turn
  one green or red by itself.
- **The second merge-in.** A true two-parent merge; identical to git's own result but for two notes files; no
  phone, phone-test or shared file changed; the two Mac files and AppSpec carry each run's hunk with the other's
  untouched (against main, each shows this run's hunk alone). VX-981's one change under the phone's undo door is
  additive: `notifyWalk` runs after the stack has moved and calls nothing when no observer is registered, and
  the only registration is the Mac's MCP door. The door's pins ran green on that tree.
- **VM-16.** `runUndo` and `redo()` read the reporting halves; a quiet outcome speaks the shared refusal as a
  refusal and records no way back; a landed one keeps main's class and its recorded way back; an empty stack
  keeps main's refusal. Traced through `MobileLine.say`: the note's standing Undo line is withdrawn before any
  of the three speaks. No other phone reader of `undo(with:)` / `redo(with:)`.
- **VM-84.** `header` is assigned at one place; `entryDate` is set beside it and is observed; the chip's words,
  ink and alert seed read the one function. The pin's third arm (an unchanged header wakes nothing) is P3's
  half and it is green.
- **VM-33.** The flag is lowered at the top of each wing's run — so on every filter, sort or wing restart —
  and raised only by a value; a failed listing leaves the line unsaid and speaks its refusal.
- **VM-43.** One `restoreCommit` caller under the phone and `Shared/`, after its flush, with the insurance
  inside the operation's transaction; both Mac doors pass the same flag, so the canon's "on both platforms" is
  true of the code.
- **VM-81.** The Finish confirm takes its subject as a parameter and survives the binding's write-back; its
  count is the dismissal's own predicate, read at the press; `unlockReading` stays legal on a gathering, so a
  legacy finished one's Reopen can act; a sealed book's Reopen and a raced Unarchive reach the shared table's
  sentences by main's road. The archived book's Details draws Finish, the daily door, Unarchive and Delete —
  each an operation that is legal on an archived book (AppSpec §9: archive is orthogonal to Finished; an
  archived Journal comes back on the next press) — and the daily Journal keeps no Delete on the phone, archived
  or not.
- **VM-83 and VM-21.** The shelf orders by the shared rule over the wing's listing, whose star is the union;
  the Pin door, its model state and its pins are gone with no dangling reference on this tree or in either
  trial tree; both reading-delete doors name a gathering; the collect line is the shared composer's in the
  class main gives it; member and add rows wear the shared mark.
- **The hoists.** The Mac files extend the shared enums and the moved lines are the lines removed;
  `CollectingCopy`'s two captions, the finish confirm's title, the undo warning's detail and
  `movedToTrashReceipt(_:)` compose to the bytes they had. No added literal under `Shared/` or the phone names
  the Mac; the Mac's dead-vocabulary predicate answers nothing over the worktree.
- **The canon deltas.** AppSpec §9 (two sites) and OverallModel §3: only "PROVISIONAL" dropped and "on both
  platforms" added. SurfaceContracts: this run's five clauses and nothing else against main, each true of the
  tree, each one clause in place with one pointer. Neither MobileSoul nor SurfaceContracts carries "PENDING".
- **The records since round 4.** Every count the record gives for the guards' window and the second
  merge-in's builds is in the kept logs; the handoff says in plain words what merged in and what remains; the
  commits are one piece each, with no trailer, no home path and no device id.
- **Her rulings, against what shipped.** Nothing in the diff is product behaviour that is neither ruled, in the
  approved plan, nor listed as PROVISIONAL for her (the archived gathering's mark; F8). VM-24 and VM-17 are out
  of the run by her picks, no fix of either is in the tree, and the caret test is red and unwrapped.
