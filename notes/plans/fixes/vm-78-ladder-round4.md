# VM-78 — ladder round 4: the cold review's findings

**Reviewer:** `fable-reviewer`, a fresh session with no implementation context, running
`notes/REVIEW_PROMPT.md` verbatim. **Diff:** the run's whole diff against merged main, `git diff eb18888db HEAD`
on `vm-78-fixes-to-whats-there` at `acb441110` (54 files; 41 of them code, none under `Sources/`); the commits
since round 3's review are `117e8c047..HEAD`. **Anchor:** `notes/plans/fixes/vm-78-ladder-round1.md`,
`-round2.md` and `-round3.md` (each round's findings and final calls) and the run record's ladder tables.
**Date:** 2026-11-19.

**The count: 0 BLOCKER · 1 MAJOR · 0 MINOR · 5 NIT, all new in this round.** No finding is against a product
line as it stands on this tree: I found no defect in the back-out, in the merge resolutions or in VM-16 as
re-landed. The MAJOR is about what happens to three of this run's fixes at the NEXT wave-1 merge, where this
run's pins cannot protect them.

## What this round read and ran

- Read myself, whole: `notes/REVIEW_PROMPT.md`; the run record's FOR A LATER READER, live state, kickoff and
  kickoff facts, batches B and A as briefed, BATCH D's "THE WINDOW AND HER RULING", "THE MERGE-IN" entire, the
  ladder and the Closeout entire; rounds 1, 2 and 3; CLAUDE.md and its loaded canon; the handoff
  (`notes/handoffs/vm-78-handoff.md`); both kickoffs (`notes/plans/vm-17-chrome-geometry.md`,
  `notes/plans/vm-24-unwarned-edit-routing.md`) and `notes/plans/vm-78-orchestrator-handoff.md`; the canon the
  run edited (the AppSpec §9 and OverallModel §3 word-diffs, `notes/SurfaceContracts.md`'s five clauses,
  `notes/MobileSoul.md` PL-77, the new block in `notes/TEXTKIT2_NOTES.md` §3); QUESTIONS #274 and its
  addendum 2.
- The code: every line of the diff outside `notes/` (the seven `Shared/` files, the six Mac files, the fourteen
  phone product files, the fourteen test files), and at the tip `MobileUndoDoor.swift`, `MobileBookDetails.swift`
  and `MobileBookFixesTests.swift` whole; main's own code the re-land stands on (`MobileLine.swift`,
  `MobileMessageLine.swift`'s hosting, `MobileWing.swift`'s `MobileWingScope.follow`,
  `MobileEditorViewModel.report`, `DeletionRefusal.sentence` / `knownWords`, `UndoStack.undoReporting` /
  `redoReporting`, `Queries.bookshelf` / `bookcaseReadings` / `starred(_:wingID:)` / `reading` /
  `liveMemberNoteCount` / `pendingArrivalCount`, `BookcaseBoard.ordered`, core `restoreCommit`); the Mac's two
  restore doors and its undo door; VM-55's three Mac source-scan pins.
- Not triggered: SyncSpec, CastleRules, MCPSpec — `git diff --name-only eb18888db HEAD` names nothing outside
  `App/Variorum/` and `notes/`. TEXTKIT2_NOTES: with batch D backed out, the diff holds no TextKit line; I read
  the new §3 block against the kept logs (below) and nothing else of it bears on this round.
- Ran: nothing on the stage; no `xcodebuild`, no simulator. No `swift test` — the diff changes no core file and
  the worktree has no core build (a cold build is outside this round's window). Read-only checks:
  - the back-out: `git diff eb18888db HEAD` over `MobileTakesChrome.swift`, `MobileEditorTextView.swift`,
    `MobileBlockDecor.swift`, `MobileTakesChromeTests.swift` and `MobileMarkdownCaretTests.swift` prints
    nothing; `git ls-files` and `git grep` find none of the four instrument types in the tree; the probe, the
    decor reading and the settle measurement each resolve at the commit the VM-17 kickoff names;
  - the 57 commit hashes I took from the record's FOR A LATER READER and Closeout each resolve and are
    ancestors of HEAD;
  - nothing under `App/` changed after `9ee926cb1`, the code the re-land's window ran;
  - the re-land's window, in its logs AND its bundles: `vm78-window-r-red.log` — 44 tests in 4 suites failed,
    17 issues including 2 known, the six expected tests and no other, each failing on the assertion the record
    names; `vm78-window-r-green.log` — 283 tests in 41 suites passed, 41 suites for the recipe's 41 types (a
    misspelt type would run nothing); `r-red.xcresult` (44: 37 passed, 6 failed, 1 expected failure) and
    `r-green.xcresult` (283: 282 passed, 1 expected failure) both read with `xcresulttool`;
  - the verdict line of each of the 28 kept window logs against the Closeout's evidence table — all agree;
  - the merge-in's three build logs end `TEST BUILD SUCCEEDED`, 0 errors; the only warnings in files this run
    touched are the test files' standing `try`-without-throw pattern;
  - the new TEXTKIT2_NOTES block's numbers against `vm78-c-M2.log`, `-M3.log`, `-M5.log`, `vm78-d-measure.log`,
    `vm78-window-d-green.log` and `-d-decor.log` (24 acts, `consults=0` in each; five of six suite-posture
    replaces widened, six of six real-posture exact; 9,276 / 4,716 pt; 61 of 61; 118 of 118; 17 bare, 4 jumps
    missed) — each as written;
  - a mechanical comparison of the run's delta before the merge (`e48ef2f30..b83463516`) with its delta after
    it (`eb18888db..HEAD`), file by file: identical everywhere except the four conflicted product files and
    the two re-shaped test files, whose differences I then read line by line;
  - two trial merges with `git merge-tree --write-tree` (nothing touched) — R4-F1.
- Not re-checked: the pre-merge windows' RED bundles that the record already says are lost or unreadable (their
  logs agree with the table); `notes/MobileSoul.md` PL-77's cross-references to earlier PL rows beyond a spot
  check of twelve rows (each names what PL-77 says it names); Linear's ticket states.
- **Review foci:** the run record has no "Review foci" section and no brief file beside it, so there are none
  to answer.

## Round 3's final calls, re-checked

| Final call | What is on the branch | This round's reading |
|---|---|---|
| R3-F1 | the decor reading ran alone in batch D's window, red as a measurement; VM-239 minted; the reading removed in `7d84e4b22`; her ruling folds it into VM-17's run | as called, then overtaken by her ruling. `MobileBlockDecor.swift` equals main's, so the one comment line the call asked for is gone with the fix it described — right, since the two controllers share one law again |
| R3-F2, and the called shape S1–S11 | built (`15add793d`, `f869f8667`), failed its window, reverted (`b69d5d12e`, `feabe164c`) | the window's log says what the record says (the scroll road clean, 17 bare lines on the jump road, four jumps missed, eight tests red). The shape I would have had to read is not in the tree; the VM-17 kickoff tells its run not to assume it |
| R3-F3 | one sentence in the Closeout: `linkFired=51/61` is the stale fallback | as called |
| R3-F4 | withdrawn | nothing to check |
| R3-F5 | the reach table's typing row and the live-state sentence reworded (`76bfc56b6`); the handoff's VM-24 section leads with it | as called; the handoff says it in plain words ("sometimes even an ordinary typed letter") |
| R3-F6 | the rule for the red probe was written, then USED: the probe left in a named commit (`1981d4041`) that the kickoff cites | as called |
| R3-N1, R3-N3 | moot — the probe is out of the tree | — |
| R3-N2 | the closeout drafts re-fitted; `grep -n PENDING notes/MobileSoul.md notes/SurfaceContracts.md` answers nothing | as called; the re-fit left a few stale sentences in the record and the handoff — R4-N2 |

## Findings, by severity

### MAJOR

**R4-F1 · [MAJOR — evidence and process; nothing is wrong on the tree under review; SPECULATIVE where marked] ·
the face lines of three shipped members — `App/Variorum/VariorumMobile/Features/Write/MobileWriteView.swift:443-463`
(VM-84's date chip), `Features/Shell/MobileCreateBook.swift:320-324` and `:343` (VM-83's kind row and no-tags
line), `Features/Write/MobileMembership.swift:347-364` (VM-21's and VM-83's member row) — with
`Features/Shell/MobileBookDetails.swift:551-577` (the new Unarchive row) · the next wave-1 merge conflicts on
exactly these lines, the other side of each conflict is the face as it was BEFORE this run's fix, and this
run's pins cannot tell which side was taken.**

- *The mechanism, link by link.*
  1. **The conflict is certain.** `git merge-tree --write-tree --name-only HEAD origin/vm-47-sizes-and-look`
     (HEAD `acb441110`; VM-47's tip as this checkout holds it, `84f16a5c2`, which already contains main
     `eb18888db`; its remote tip has moved since) reports four content conflicts: `MobileBookDetails.swift`,
     `MobileCreateBook.swift`, `MobileMembership.swift`, `MobileWriteView.swift`. Both runs go to main, so
     whichever merges second resolves them by hand. (The same trial with `origin/vm-64-timing-and-lags` at
     `3dcafa735` merges clean textually; it changes `MobileEditorViewModel.swift`, `MobileUndoDoor.swift`,
     `MobileMembership.swift`, `MobileWriteView.swift` and `MobileLibraryView.swift` too, so a semantic read is
     owed there as well.)
  2. **The other side is the pre-fix face.** From the trial's conflicted tree:
     - the date chip — VM-47's side: `Text(model.header?.entryDate ?? tokens.chromeLabel("no date"))` and
       `.foregroundStyle(model.header?.entryDate != nil ? …)`. That is VM-84's defect itself: the unobserved
       `header`.
     - the create sheet — VM-47's side: `PhoneSegmentedChoice(…, word: Self.kindWord, …)`, where `kindWord` is a
       NEW function on its branch returning `"Smart Book"` for the gathering kind; and the literal
       `"No tags yet — notes get tags first; a smart book collects by them."`
     - the membership row — VM-47's side: `MobileShelfFaces.name(for: book)` (no "(archived)") and
       `Text(tokens.chromeLabel("smart"))`.
     - Book Details — VM-47's side: `MobileShelfFaces.deleteBookDoorTitle`, and the old Finish row whole
       (`setFinished(!finished)`, "a finished book reads ✓ and freezes its notes").
  3. **The pins hold seams, not faces.** `theDateChipFollowsTheDateWhenTheTitleDoesNot`
     (`MobileMembershipTests.swift:323`) reads `MobileWriteScreen.dateChipDay(model)`; nothing asserts that the
     chip's body calls it. `theMembershipAndCreateSheetsSayGathering`, `noRenderedStringInTheseFacesSaysSmart`
     and `pickersMarkAnArchivedBook` call `kindLabel`, `noTagsLine`, `kindMark` and `memberRowName` — pure
     functions. No test constructs `MobileMembershipSheet` or `MobileCreateBookSheet` (grep over
     `VariorumMobileTests/`).
  4. **So the wrong side is silent in three files.** A resolution that takes VM-47's side of the chip, the
     create sheet and the membership row compiles (at most an unused-`day` warning), every pin of this run
     passes, and main ships a date chip that again waits for the title to change (VM-84 undone — the one
     shipped member in the editor-seam class), "Smart Book" and "a smart book collects by them" on the create
     sheet, and "smart" with no "(archived)" on a note's books list. Book Details is the one file where the
     wrong side is loud: `deleteBookDoorTitle` no longer exists (a compile error), and a Finish row that acts
     at once reds round 1's hosted guard and round 2's hints pin.
  5. **The push is one-directional.** VM-47 carries a source scan,
     `MobilePhoneTypeSourceTests.noPhoneViewReadsTheMacsTypeSlots`, forbidding
     `tokens.(small|body|title|heading|mono|navigation)` on every phone code line. HEAD's side of each hunk
     reads those slots, so that scan stays red until the resolver moves to VM-47's side of the styling — and
     nothing goes red if this run's calls leave with it. In the create sheet the compiler joins the push: VM-47
     deleted the `kindDoor` helper that HEAD's side of the hunk still calls, so HEAD's side no longer compiles
     and the resolver lands on `word: Self.kindWord` — "Smart Book" — unless it rewires the control to
     `kindLabel` by a deliberate edit. The same type scan reds on this run's new Unarchive row
     (`MobileBookDetails.swift:558`, `:563`), which merges with no conflict at all.
- *Why it is ranked.* Round 1's F1 and F2 are this run's own precedents: the tree the ladder closes on must be
  the tree that merges, and a pin that stays green while the defect stands is not evidence. Here the event is
  certain, the failure is silent in three places, and the pressure runs toward the wrong side. VM-47 closed its
  second round with no MAJOR at `84f16a5c2`, so it may well merge first — in which case the hand resolution is
  THIS run's second merge-in, made after this round, read by nobody.
- *SPECULATIVE:* which run merges second, and that its resolver would take the wrong side. The four conflicts,
  both sides of each, the scan's direction and the pins' blindness are concrete.
- *Fix.* Three parts.
  1. **The rule, written into the live state now.** Before the gate's three legs are spent, ask the
     coordinator which of VM-47, VM-64 and this run merges first. If main moves before this run merges:
     `origin/main` is merged in again by a merge commit; every hand resolution and semantic join is listed file
     by file, as "THE MERGE-IN" did; the guards below are shown red against the wrong side; the gate's legs
     (the walk's rows for these faces included) run on THAT tree; and a fresh reviewer reads the second
     merge-in as new work before the merge — owed whatever this round's count is, as round 3 was owed after
     round 2 found no MAJOR, and Fable's, because the chip's line is VM-84's. If this run merges first, the map
     below goes to VM-47's and VM-64's orchestrators through the coordinator and under "Lines for other owners":
     their resolver meets these hunks instead.
  2. **The map — what of this run must survive each hunk; the styling is VM-47's.**
     - `MobileWriteView.swift`, the chip's label: it reads `day` (`Self.dateChipDay(model)`), never
       `model.header?.entryDate`, in VM-47's type and colour roles.
     - `MobileCreateBook.swift`: the kind control's `word:` is `MobileCreateBookModel.kindLabel` (VM-47's
       `kindWord` goes, or forwards to it); the no-tags line is `MobileCreateBookModel.noTagsLine`.
     - `MobileMembership.swift`: the row's name is `memberRowName(for:)`, its mark `kindMark(for:)`; the
       Diverge button stays inside `rowCarriesDiverge(book)`.
     - `MobileBookDetails.swift`: the delete row keeps `deleteDoorTitle(for: kind)` and its hint; the Finish row
       keeps `finishRowAct` / `requestFinish` / `finishCaption(for:)`, its label and its hint; the Unarchive row
       is restyled to VM-47's roles by hand (no conflict will ask for it).
  3. **Guards for the three silent faces** — green on the tip, each red on the wrong side of its hunk and on the
     pre-fix tree. They land now, so they stand in whichever run's gate comes second.
- *Pins.*
  - **G1 — VM-84's face.** A source pin: no code line under `VariorumMobile/` outside
    `Features/Write/MobileEditorViewModel.swift` contains `header?.entryDate`. On the tip: none. Red on the
    pre-fix tree — `e48ef2f30`'s `MobileWriteView.swift:458`, `:461`, `:463`, and the seam commit `2d66e9a30`'s
    `:475` — and on VM-47's side (`MobileWriteView.swift:453-458` on its branch). The date pin's comment then
    says G1 holds the face.
  - **G2 — W-073's faces.** Round 1's N7 scan, now, with its two owned sites as an allowlist: no string literal
    on a phone code line contains "smart" in any case, outside `Features/Shell/MobileTodayDoor.swift` (VM-85)
    and `Features/Tutorial/MobileTutorialSeeder.swift` (VM-212). On the tip: exactly those two. Red at
    `e48ef2f30` (five more sites: three in the create sheet, the shelf row's meta, the membership row) and on
    VM-47's tip (the same five). The scan must read the literal's own contents; a bare `"[^"]*smart[^"]*"` can
    match across two literals on one line.
  - **G3 — the membership sheet's face.** One hosted pin on the house driver (the `MobileBookDetailsSheet`
    pins are the template): a note that is in an archived book and matches a gathering — the visible labels
    carry the book's name with "(archived)" and the "gathering" mark, and "diverge" is offered once (the book's
    row). Red on VM-47's side of the row hunk. If the sheet cannot be hosted cheaply the implementer says so
    and proposes a source-shape pin instead; a face left unguarded is named in the record.
  - The red legs: the wrong side of each hunk applied by hand in the throwaway checkout (the three hunks are in
    the trial tree), restored by `git checkout HEAD --`, in one short window; G1 and G2 may show their pre-fix
    red by file swap instead.

### NIT

- **R4-N1 · three pins are red on the merged tree by reading only.** The join's pin
  `bookDetailsDeleteLineNamesAGathering` (`8d2b9f8bf`), the removal-line assertion added to
  `theDeleteDoorConfirmAndReceiptNameAGathering` (`MobileBookFixesTests.swift:609-611`), and the line-class
  assertions added to the three collect pins (`expectOnTheLine`, `:758`). The record says so, and I read each
  red against main's files: main's Book Details composes `movedToTrashReceipt(.book)` for every kind
  (`MobileBookDetails.swift:164` at `eb18888db`), which fails `:666`; main's `collect` composes "Added by
  tagging …" for a star-only collect. If R4-F1's guards get a window, one hand-reverted line
  (`MobileBookDetails.swift:306-307` back to `movedToTrashReceipt(.book)`) shows the join's pin red in the same
  checkout at no extra claim; otherwise "by reading" stands as recorded.
- **R4-N2 · sentences the re-fit and the window's result left stale.** `notes/handoffs/vm-78-handoff.md:3-7`
  ("Still ahead: a short test window for the fixes re-applied after the merge") while its own evidence section
  reports that window; the record's `:8-10` and `:76` (FOR A LATER READER still lists the re-land's window
  among the slots and the open items), `:2856-2857` ("their windows are the slots below"), `:3726` and
  `:3738-3739` ("the re-land's window, not yet run"). And one that is false rather than stale: the
  finals-ledger draft at `:3703` says "a second session took over at a clean seam", where the live state
  (`:88`) and the AppSpecRecord draft (`:3643`) say one session ran throughout — that draft line is pasted into
  a shared ledger on main at the merge. The first bullet of "Sentences to revisit" is moot.
- **R4-N3 · two stale canon lines beside this run's clauses have no owner outside the working record.** This
  run's clause 2 was added inside a SurfaceContracts sentence that still quotes the Finish confirm as "N waiting
  at the door will be dismissed" (`notes/SurfaceContracts.md:34`); the shipped words on both platforms are "N
  waiting at Arrivals will be dismissed." (`Shared/BookStateCopy.swift:57`), so the sentence now says the phone
  asks "the same" as words neither platform says. The Closeout lists this, and P-849-4's and P-849-5's
  PROVISIONAL marks (ratified at #274 addendum 2), under "Lines believed false or stale — NOT edited, for the
  orchestrator" — and nowhere else: not in her handoff, not among the tickets to file. Canon is hers to change;
  give the three lines one line in the handoff's canon section, or a wording ticket.
- **R4-N4 · the walk's rows were written before the merge moved this run's sentences out of the sheets.**
  Round 1's N9 row asks for the tallest Book Details "with a refusal line showing"; the sheet no longer draws
  one (`MobileBookDetails.swift:454-455` — VM-61's line floats in its own window above the sheet), so the row's
  question changes: at the medium detent, does the standing line cover the sheet's last row (Delete). And three
  of this run's sentences now reach her only on that line while a sheet is still up — the sealed book's Reopen
  sentence, the collect line, a refused Finish. No pin can see "above the sheet" (they read
  `session.status.current`). Their rows should say: captured with the sheet up, the line readable.
- **R4-N5 · the date chip's label hides its day from VoiceOver** (`MobileWriteView.swift:455`,
  `.accessibilityLabel("Entry Date")` — from before this run; by reading, not run). The label replaces the
  chip's text, so VoiceOver hears "Entry Date" and never the date: round 2's R2-N1 class. A line for VM-218
  beside the "Rename Book" one. An `.accessibilityValue` of the day would also let a hosted pin read what the
  chip draws — an alternative shape for G1, if the implementer prefers a face read to a source scan (it is then
  a product line and owes its own red).

## What is still owed (not findings)

- **The gate's three legs** — the whole phone target, the whole Mac target, the simulator walk — and, by R4-F1,
  on the tree that actually merges. The Mac target has not run on the merged tree at all (window (1)'s 110
  tests in 17 suites ran before the merge); it builds.
- **A gate-driven product change is new work.** If a gate leg or the walk forces a product line, an implementer
  writes it with its pin; a line in `MobileEditorViewModel.swift` or the chip's view gets a Fable read before
  the merge (CLAUDE.md's seam rule), anything else the orchestrator's line-by-line check.
- **The merge moment's ledgers**, as the record lists them: the QUESTIONS bundle and F8's question, the dated
  AppSpecRecord entry, the finals-ledger line (R4-N2), the tickets to mint, `Tools/canon-size`, PL-77's
  "Verified so far" brought to what ran.

## The ladder after this round

One MAJOR, so by her standing rule a round 5 is earned — the last under the cap. A fresh `fable-reviewer`
reads, as new work: R4-F1's guards with their reds, the rule and the map as written, and — if main has moved by
then — this run's second merge-in. One round for both if the coordinator's order allows it.

## The clean bill — what I checked and found solid

- **Nothing outside `App/Variorum/` and `notes/`.** No `Sync/`, custody, schema or core line. Every write the
  changed doors make is an existing operation, so S1–S5 and I1–I10 are untouched; nothing new scales with the
  corpus; nothing tracks word-level change or copies text across entities.
- **The back-out.** The four chrome files and the caret test are byte-for-byte main's; no instrument type is in
  the tree; main gets no new red test from this run. The reverts are revert commits and the removals are named
  commits the VM-17 kickoff cites, each of which resolves. VM-19's teardown fix and pin are kept.
- **The merge.** A true merge commit over `eb18888db` (two parents; main is an ancestor). The merged tree equals
  main plus this run's intended delta: outside the four conflicted product files and the two re-shaped test
  files, the run's delta is line-for-line what it was before the merge. `notes/MobileSoul.md` gains one row and
  `notes/SurfaceContracts.md` five clauses; neither lost a line of main's.
- **VM-16, re-landed.** `runUndo` and `redo()` read `undoReporting` / `redoReporting`; a quiet outcome reports
  the shared refusal as a `.refusal` with no action, a landed one keeps main's ordinary class and its recorded
  way back, an empty stack keeps main's refusal. Through `MobileLine.say` the quiet press also takes back the
  note's standing Undo line before it speaks, so no way back is left on the line either. I traced
  `UndoStack.undoReporting` again: a quiet half retires its entry and leaves the other stack alone. No other
  reader of `undo(with:)` / `redo(with:)` is left on the phone. One precision the record already carries: on
  the merged tree nothing draws `statusAction` any more, so what main's door got wrong for her was the silence
  of a press that did nothing; the recorded stale way back is the model's record only. Both pins were seen red
  against main's door and green on the tip, in the log and in the bundle.
- **VM-20.** The phone forwards to the shared sentence with its own read-back place; the Mac forwards with its
  own; the bytes of both are pinned.
- **VM-33, inside the per-wing follow.** The flag is lowered at the top of each wing's run and raised only by a
  value; a failed listing never raises it. The first-paint pin was seen red against main's pair and green on
  the tip.
- **VM-81, at the merge.** Deleting this run's forwarding arm was right: `DeletionRefusal.knownWords` has no
  arm for `readingSealed` or `readingNotArchived`, so main's road falls to the shared table, and both pins —
  which now also read the one line — pass on the tip. `requestFinish`'s two refusals ride main's road. The
  Finish confirm, the finish row's act table and caption, the archived book's resolve, Unarchive, and the four
  rows' labels and hints are all in the merged file. The archived-starred road is still reachable on the merged
  tree: `Queries.starred(_:wingID:)` filters by wing, not by archive.
- **The one semantic join.** Book Details' delete line composes `movedToTrashReceipt(.book, isGathering:)` from
  the model's own book, which resolves an archived gathering too; a book's line is byte-identical to main's.
- **VM-83 and VM-21, at the merge.** The shelf orders main's wing-scoped listing by `BookcaseBoard.ordered`,
  whose star is the union the listing carries; no second book listing on the phone orders by another rule. The
  collect line speaks the shared composer's words in the class main gives both collect arms, and for a live
  tags-only collect and an already-matched one those words are byte-identical to main's own (compared with
  main's `collect` at `eb18888db`).
- **VM-43, VM-84, VM-3, F4.** One `restoreCommit` call under `VariorumMobile/` and `Shared/`, after its flush,
  with the insurance inside the op's transaction; `entryDate` set at the one place `header` is assigned, the
  chip's three uses reading the one function; the two lessons as drafted. The pocket guide's seeding door is
  Debug-only, as round 2 said.
- **The hoists.** The Mac files extend the shared enums; the moved lines are the lines removed. VM-55's Mac
  source scans (`VM61MacStatusSeamPinTests`, `VM62MacRefusalWordsPinTests`, read for their file lists and
  forbidden words) walk the Mac tree and six named hoisted brains; none of this run's Mac lines holds a word
  they forbid.
- **The canon deltas.** AppSpec §9 (two sites) and OverallModel §3: only "PROVISIONAL" dropped and "on both
  platforms" added; the ruling is in QUESTIONS (#274 addendum 2); and the claim is true of the code — both Mac
  restore doors (`TakesViewModel`, `CommitsFaceModel`) and the phone's one pass `insuringBuffer: true`.
  SurfaceContracts' five clauses are each true of the merged tree, one clause in place with one pointer, no
  date, no words of hers, no tally. TEXTKIT2_NOTES §3: every number I checked is in the logs, and the block
  says twice that it is a measurement and not a recipe.
- **The two kickoffs.** Each states what was measured and what was not, names the commits that hold its pins
  and instruments (all resolve), and tells its run what not to assume. The VM-24 kickoff's first acceptance
  unit is the measurement on her phone, as her ruling says.
- **Her rulings, against what shipped.** The quotes the Closeout attributes to her are in the sources it
  names. VM-24 and VM-17 are each out of this run by her dialog picks; no fix of either is in the tree; the
  caret test is red and unwrapped. The order choice waits for VM-113; the collect line is kept and true; no
  ordinary act gained a line. I found no product behavior in the diff that is neither ruled nor listed as
  PROVISIONAL.
- **Commits since round 3.** One piece each, reverts as revert commits, the merge as a merge commit, no
  trailer, no home path, no device id, no test wrapped as a known issue, public wording.

*Final calls are appended here after the answers come back.*
