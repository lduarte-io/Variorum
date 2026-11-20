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

## The answers

*Two answers came back: the implementer's on every finding (a fresh `opus-implementer`, from the repo at HEAD
`3396c4611` and the pushed tips of VM-47 and VM-64; it edited and built nothing), and the orchestrator's on
R4-F1's process half. Both are kept as written. The final calls follow them.*

### The implementer's answers (verbatim, whole)

**R4-F1: AGREE IN PART.** The finding is right that the conflicts are certain, that the other side of each one is the face before this run's fix, that the pins cannot see which side a resolver took, and that pressure from VM-47's type scan runs toward the wrong side. All three guards are buildable and should land now. Five points are corrected or tightened below. I checked everything at HEAD `3396c4611`, against the pushed tips after `git fetch`: VM-47 `65f26dc54` and VM-64 `31630a151`. I built nothing; anything marked "by reading" is not built.

**(a) The evidence, link by link**
1. **The conflicts. TRUE at the pushed tips.**
   - VM-47's tip moved 9 commits past `84f16a5c2`, but under `App/` it changed only one comment in `Shared/OpsRefusalTable.swift` and one test file.
   - `git merge-tree --write-tree --name-only HEAD origin/vm-47-sizes-and-look` gives tree `07c8553ca` and the same four content conflicts: `MobileBookDetails.swift` (4 hunks), `MobileCreateBook.swift` (2), `MobileMembership.swift` (2), `MobileWriteView.swift` (1).
   - VM-64's tip moved 5 commits past `3dcafa735`: library paging's Put-back listener, one line in `MobileLine.swift`, and tests. The trial merge with it is still clean (tree `5bf2a003f`).
   - I read VM-64's semantics in that trial tree:
     - `header =` happens only inside `adoptHeader` (`MobileEditorViewModel.swift:912`), and every header delivery calls `adoptHeader`, so VM-84's mirror holds.
     - The chip keeps `dateChipDay` (trial `:460`, `:462`, `:479`). VM-64's own tip still carries main's chip lines (`:461-466`) but never edits them, so the merge keeps HEAD's.
     - `undoReporting` and `redoReporting` survive beside VM-64's `inFlight` didSet.
     - `memberRowName`, `kindMark` and `rowCarriesDiverge` survive beside VM-64's `refreshChip()`, which fills `books` through the same `Self.ordered`.
     - Nothing is lost there.
2. **The other side is the pre-fix face. TRUE for all four files, as quoted.** One addition: VM-47's `static func kindWord`, which returns "Smart Book", auto-merges in *outside* any hunk (trial `MobileCreateBook.swift:311-317`). Even a correct resolution of the hunk leaves that literal in the file unless the resolver deletes it.
3. **The pins hold seams, not faces. TRUE.**
   - `theDateChipFollowsTheDateWhenTheTitleDoesNot` (`MobileMembershipTests.swift:323`, type `MobileNoteEntryDateTests`) reads `MobileWriteScreen.dateChipDay`.
   - The gathering-word pins (`MobileBookFixesTests.swift:624`, `:707`, `:827`) call pure functions.
   - No file under `VariorumMobileTests/` names `MobileMembershipSheet` or `MobileCreateBookSheet` (grep: 0 files).
4. **"The wrong side is silent in three files". TRUE IN PART.**
   - **The chip.** VM-47's side compiles; the only cost is an unused-`day` warning. But `let day = Self.dateChipDay(model)` (HEAD `:444`) is still evaluated in the masthead's body: `dateChip` sits inside `MobileChipFlow`, which is a `Layout`, and an `@Observable` getter cannot be optimised away. So by reading, the face still re-renders on a date change. VM-84 is fully undone only when someone also deletes the now-unused `let day`, which the warning invites. G1 catches the first of those two steps, so the guard stands; the regression just takes two steps, not one.
   - **The create sheet.** VM-47's side of both hunks compiles and is silent ("Smart Book"; "…a smart book collects by them."). HEAD's side of the kind-row hunk does not compile: VM-47 deleted `kindDoor`, and the trial tree has no definition of it.
   - **The membership row.** VM-47's side of hunk 1 compiles and is silent (no "(archived)"; the mark reads "smart"). VM-47's side of hunk 2 puts `.buttonStyle(PhoneInlineActStyle(…))` after the closing brace of HEAD's `if rowCarriesDiverge(book) { … }` (trial `:365-368`). By reading, that is a compile error. So the Diverge regression is not "a side". It is the hand edit — unwrapping the `if` — that VM-47's type scan pushes toward, because the `.font(tokens.small)` inside the `if` (trial `:361`) merges with no conflict.
   - **Book Details. Loud, as stated.** `deleteBookDoorTitle` is gone (trial `MobileShelfFaces.swift` has only `deleteDoorTitle(for:)` at `:140`). VM-47's side of the Finish hunk also fails to compile on its own: the common lines after it read `act` (`.accessibilityLabel(act == .reopen …)`), which VM-47's side never binds.
5. **The push runs one way. TRUE.**
   - What the scan forbids: `MobilePhoneTypeSourceTests.noPhoneViewReadsTheMacsTypeSlots` matches the regex `tokens\.(small|body|title|heading|mono|navigation)\b`. It walks every `.swift` file under `VariorumMobile/` except `Spike/` and `Features/Perf/`, and skips lines that begin with `//`, `///` or `*`.
   - Run with those patterns over the trial tree, it flags exactly 10 lines:
     - Inside hunks (HEAD's side): `MobileWriteView.swift:459`, `MobileMembership.swift:338` and `:343`, `MobileCreateBook.swift:324`, `MobileBookDetails.swift:577`, `:644` and `:651`.
     - Outside any hunk (this run's lines): `MobileBookDetails.swift:549` and `:554` (the Unarchive row; HEAD `:558`/`:563`, as the finding says) and **`MobileMembership.swift:361`** (the Diverge button's `.font(tokens.small)`). The finding misses that last one.
   - VM-47's controls scan flags only its three allowed cards on the trial tree. VM-47's look pins hold for the files of this run it names (`MobileTrashView`, `MobileShelfView`, `MobileLibraryView`).

**(b) The guards** — all buildable; none needs a product line.

**G1 — the date chip's face.**
- **Shape: tighten it.** The bare substring `header?.entryDate` would also match a local optional named `header`, which is legitimate (e.g. a seeder or a future face holding a `Queries.ContainerHeader?`; `MobileStars.swift:178` already reads a local `header.entryDate`). Match only a member access on some object: `/\.header[?!]?\.entryDate\b/`.
- **Don't broaden it.** "No face reads `.header?.`" would misfire today on `MobileWriteView.swift:244`: `renameField = model.header?.title ?? ""` seeds the rename alert's field at tap time, which is legitimate.
- **Home:** a new `@Test func noPhoneFaceReadsTheEditorsUnobservedHeaderDate()` in `MobileNoteEntryDateTests` (`MobileMembershipTests.swift:277`), beside the date pin. The date pin's doc comment gains one sentence: the face is held by this scan, the pin holds the seam.
- **Predicate:**
  - Walk `VariorumMobile/` (the house `#filePath` root), product files only. Tests stay out: `MobileShelfTodayDoorTests.swift:72` on main and both tips reads a local `header?.entryDate`.
  - Skip `Features/Write/MobileEditorViewModel.swift`. It is harmless to skip; it has no code hit today, only the doc comment at `:112`.
  - Lines come from `MobileNoRawErrorPinTests.strippingComments(_:)` (`MobileRawErrorPinTests.swift:160`): comments go, strings stay, line numbers are kept. This handles trailing and block comments, which VM-47's prefix test does not.
  - Expect `walked > 60`; offenders print as `file:line`.
- **Today:** green at HEAD and on the VM-64 trial. Red on `e48ef2f30` (`:458`, `:461`, `:463`), on `2d66e9a30` (`:475`), on VM-47's tip (`:453`, `:456`, `:458`) and on the VM-47 trial's wrong side (`:462`, `:464`).
- **Collisions:** none. Neither VM-47 nor VM-64 touches `MobileRawErrorPinTests.swift` or `MobileMembershipTests.swift`.

**G2 — the "smart" faces.**
- **Shape: tighten it, two ways.**
  - A *file* allowlist is too loose: VM-212 is rewriting the seeder's prose, and a new "smart" literal in either file would pass. Use the house's exact-literal exemptions instead — (file, literal text, why), each required to match exactly once — as in `MobileNoRedirectSweepTests` (`MobileStructuralTests.swift:1127-1237`) and `MobileNoRawErrorPinTests`. A re-worded or retired site then trips its stale entry, which is VM-85's and VM-212's retirement signal.
  - "Contains smart, any case" would match "smartphone". Use the Mac's whole-word, case-insensitive rule (`DeadVocabularyTests.containsWord`, `VariorumTests/DeadVocabularyTests.swift:87-98`). It lives in the Mac target, so copy it as a ~10-line private helper, with a two-line oracle mirroring the Mac's (`"a Smart book"` hits; `isSmart` and `smartphone` do not).
- **Literal extraction:** reuse `MobileNoRedirectSweepTests.stringLiteralContents(of:)` (`MobileStructuralTests.swift:1249`). It reads each literal's own contents, so two literals on one line never join. Its stated limit is a literal nested inside an interpolation.
- **Roots:** `VariorumMobile/` plus `Shared/` (the no-redirect sweep's two roots, each asserted to exist). Neither tree, nor VM-47's or VM-64's tip, has any "smart" literal in `Shared/`.
- **Exempt exactly:**
  - (`MobileTodayDoor.swift`, `"Entry saved. Your daily journal is a smart book, which can't hold entries — choose a hand-picked book as your daily journal (a book's details has the door)."`, VM-85)
  - (`MobileTutorialSeeder.swift`, `"hand-picked, a dated journal, or a smart book collecting by "`, VM-212)
  - Both literals are byte-identical on VM-47's and VM-64's tips; VM-47 touched `MobileTodayDoor.swift` only to add a trailing comment.
- **Home:** a new `@Test func noPhoneStringLiteralSaysSmart()` in `MobileGatheringWordTests` (`MobileBookFixesTests.swift:564`). `noRenderedStringInTheseFacesSaysSmart`'s doc comment (`:701-706`) is re-worded: the scan exists now, and the hand-kept list stays as the check on the pure functions.
- **Today:** green at HEAD (exactly the two sites). Red on `e48ef2f30`, main and VM-47's tip (the same five: `MobileMembership` "smart", the create sheet's three, `MobileShelfFaces.swift:75` "smart"). Red on the VM-47 trial (three: `MobileMembership:351`, `MobileCreateBook:315` from `kindWord` outside any hunk, and `:327`).
- **Collisions:** none. VM-47's scans forbid styling, not words. `#if DEBUG` code is scanned, which is right because it renders in Debug; it holds no hit today.

**G3 — the membership sheet's face.** It can be hosted cheaply: `MobileMembershipSheet(model:tokens:onOpenNote:)` has the same memberwise init on HEAD, main, `e48ef2f30`, VM-47's tip and VM-64's tip. The membership section is a plain `VStack` in a `ScrollView` (no lazy rows).
- **Home:** a new suite `MobileMembershipSheetFaceTests` in `MobileBookFixesTests.swift`, after `MobileCollectReceiptTests`.
- **The fixture (`withEditorWorld`):** create the tag `quote`; a book "Old projects"; a gathering "Quotes" on `.tag(quote)`; a note.
  - `addPostToReading(note, to: book)`, then `archiveReading(book)`, then `applyTag(quote, toPost: note)`.
  - `Queries.readingsContaining` lists an archived book's membership but skips an archived gathering (`ShelfQueries.swift:664-700`), so `books` is [Old projects, Quotes].
- **Hosting:** `let model = MobileMembershipModel(session:postID:)`; `await model.refresh()`; `withHostedSurface(MobileMembershipSheet(model: model, tokens: .studyLight, onOpenNote: nil))`; `settle(30)`.
  - Study does not lowercase (`lowercasesChrome: false`). Terminal lowercases every `chromeLabel`, so a Terminal mount compares `tokens.chromeLabel(expected)`.
- **Expect on `surface.visibleLabels`:**
  - contains "Old projects (archived)", "Quotes" and "gathering";
  - `filter { $0 == "diverge" }.count == 1`;
  - no label contains "smart" as a whole word.
- **Collisions:** none. Neither run touches `MobileBookFixesTests.swift` or `MobileSurfaceDriver.swift`, and a button style does not change an accessibility label.

**The red legs.** VM-47's side cannot be applied *verbatim* on this branch: `.phoneType`, `tokens.phone`, `PhoneInlineActStyle` and `PhoneSegmentedChoice` do not exist here (git grep at HEAD: none). So "the wrong side, by hand" means VM-47's reads and words in this branch's styling — which is exactly `e48ef2f30`'s lines.

The plan: one claim, one RED build in the throwaway checkout at the tip after the guards land.
1. **G1:** replace `MobileWriteView.swift:449-451` with `e48ef2f30`'s `:461-463` (`Text(model.header?.entryDate ?? …)` and `.foregroundStyle(model.header?.entryDate != nil ? tokens.muted : tokens.faint)`). This compiles with the unused-`day` warning.
2. **G2:**
   - In `MobileCreateBook.swift`, add the trial's `kindWord` (returning "Smart Book") to `MobileCreateBookSheet` and route `:322` through `kindDoor(Self.kindWord(kind), kind)`.
   - Replace `:343`'s `MobileCreateBookModel.noTagsLine` with VM-47's literal.
3. **G3:**
   - `MobileMembership.swift:347`: `memberRowName(for: book)` → `MobileShelfFaces.name(for: book)`.
   - `:351-352`: `if let mark = MobileMembershipModel.kindMark(for: book) { Text(tokens.chromeLabel(mark))` → `if book.kind == .gathering { Text(tokens.chromeLabel("smart"))`.
   - `:357`/`:364`: remove the `rowCarriesDiverge` wrapper. That is the unconditional Diverge that main and VM-47's tip draw.
4. **R4-N1 rides along:** `MobileBookDetails.swift:306-307` → `RecoveryCopy.movedToTrashReceipt(.book),`.

Build, then run `MobileNoteEntryDateTests`, `MobileGatheringWordTests`, `MobileMembershipSheetFaceTests`, `MobileCollectReceiptTests` and `MobileBookStateRowTests`.
- **Expected red:**
  - G1, at `:449` and `:451`;
  - G2, on three literals;
  - G3, on all three faces;
  - `bookDetailsDeleteLineNamesAGathering`, at `:666` only.
- **Expected GREEN on the same tree:** `theDateChipFollowsTheDateWhenTheTitleDoesNot`, `theMembershipAndCreateSheetsSayGathering`, `noRenderedStringInTheseFacesSaysSmart`, `pickersMarkAnArchivedBook` and `divergeIsNotDrawnOnAGatheringRow`. That is link 3, shown rather than argued.
- **Then:** `git checkout HEAD --` the four files, confirm a clean `git status`, rebuild, and run the same types green.

Optionally, with no rebuild, G1 and G2 can also show the pre-fix tree's red. After the green build, put `e48ef2f30`'s (or VM-47's tip's) `MobileWriteView`, `MobileCreateBook`, `MobileMembership` and `MobileShelfFaces` on disk and run the two scans with `test-without-building`. The scans read the sources at run time, so the swapped files never need to compile; window (3) used `test-without-building` before.

**R4-N5's alternative for G1** (an `.accessibilityValue` on the chip, read by a hosted `MobileWriteScreen` — there is precedent in `MobileUndoDoorTests:102` and `MobileWingDoorTests:328`): **not in this pass.**
- It is a product line in the chip's view. VoiceOver copy is VM-218's call, and the line would owe its own red and a Fable read.
- It would not detect the literal wrong side. With the value reading `day`, the body observes `entryDate`, the Text re-reads `header` fresh, and the face is right — so the pin is green, correctly.
- What it would do is prevent the second step: `day` stays used, so there is no warning to clean up. That is a reason to give it to VM-218, not to treat it as a guard.
- Without a product line, the chip's drawn text cannot be read from the tree, because the explicit label (`:455`) replaces it. So G1 stays a source scan.

**(d) The process rule — two holes.**
1. **The cap.** Round 5 is the last read under her standing cap of five. If main moves after round 5 is spawned, no read of the second merge-in fits under the cap. So the merge order must be known before round 5 starts. If this run merges second, round 5 waits for the second merge-in and reads both, as the round offers. If the order can't be fixed, the extra read is her call — ask now.
2. **If VM-47 merges first,** its three scans (`MobilePhoneTypeSourceTests`, `MobilePhoneControlsSourceTests`, `MobileLookSourceTests`) arrive here and force the restyle of this run's lines: the hunks, plus the Unarchive row and the Diverge button. The second merge-in's record should name them, so that a scan red is fixed by restyling and never by reverting this run's call.
3. Not a hole, but worth saying: if this run merges first, VM-47's ladder is closed (its tip's round 2 found no MAJOR and earns no further round), so G1–G3 on main are the only reader of its merge-in. This run should therefore merge only after the guards' window.

**R4-N1: AGREE.** Main's Book Details composes `RecoveryCopy.movedToTrashReceipt(.book)` for every kind (`eb18888db` `MobileBookDetails.swift:164`); HEAD has `:305-307`. Main's `collect` builds its own string (`eb18888db` `MobileMembership.swift:152`).
- **Precision:** the line-class halves are main's own behaviour and are green on both sides — `line.leavesPage` (`MobileBookFixesTests.swift:610`) and `expectOnTheLine`'s `.refusal` (`:760`). Only the words are red against main, and those words were already proved red on the model's slot in window (1).
- **So:** one hand-reverted line adds new evidence only for the Book Details join. Revert `MobileBookDetails.swift:306-307` to `RecoveryCopy.movedToTrashReceipt(.book),` (it compiles, since main's one-argument form exists). The pin goes red at `:666` and the book half stays green at `:672`. It rides in G1–G3's RED build: same checkout, same claim, no extra build. Elsewhere, "by reading" stands as recorded.

**R4-N2: AGREE.** Every cited line is stale or false as stated. The exact sentence changes:
- `notes/handoffs/vm-78-handoff.md:3-7`: "Still ahead: a short test window for the fixes re-applied after the merge, the fourth review round, and the final gate (…)" → "Still ahead: the guards the fourth review round asked for and the fifth round that reads them, then the final gate (…)". Keep the rest. `:202-203`'s `PENDING(ladder round 4: its outcome)` is filled from the final calls.
- Record `:8-10`: "Its `PENDING(…)` slots — the re-land's window, ladder round 4, the gate, the QUESTIONS number —" → "Its `PENDING(…)` slots — ladder round 4 and the round it earns, the gate, the QUESTIONS number —".
- `:76`: "The re-land's window, round 4 and the gate;" → "Round 4's guards, round 5 and the gate;".
- `:2856-2857`: "on the merged tree the fixes are built for testing and read, and their windows are the slots below." → "on the merged tree the re-land's window ran red on its six pins against main's files and green over 41 types (the evidence table); the gate's legs are the slots below."
- `:3562-3563` ("After the re-land's window: …"): append "— moot: the window ran red, then green, as the recipe expected (15:07–15:12)."
- `:3726`: delete "the re-land's stage window, " and change "ladder round 4" to "ladder round 4's guards and round 5".
- `:3738-3739`: "…their own red/green on that tree is the re-land's window, not yet run." → "…the re-land's window proved VM-16, VM-20 and VM-33 (and the Trash's two names) red on main's files and green on the tip; VM-81's and VM-83's joins and VM-21's line words are red against main by reading (R4-N1), the Book Details join by hand-revert if it rides the guards' window."
- `:3703` (the false one): "Fable orchestrated (a second session took over at a clean seam)," → "Fable orchestrated (one session throughout, its context compacted once at a clean seam at her word),".

**R4-N3: AGREE.**
- **The three lines:**
  - `notes/SurfaceContracts.md:34` quotes "N waiting at the door will be dismissed". The shipped words are "N waiting at Arrivals will be dismissed." (`Shared/BookStateCopy.swift:57-58`, re-worded under R-17y-2).
  - `:44` carries "PROVISIONAL P-849-5, QUESTIONS #274; VX-849".
  - `:58` carries "PROVISIONAL P-849-4, QUESTIONS #274; VX-443".
  - `notes/QUESTIONS.md:3924` (#274 addendum 2) reads "P-849-4 RATIFIED as built" and "P-849-5 RATIFIED as built".
- **Both changes:**
  - A handoff line: a new sub-section after "Two canon lines I changed, for your eyes", titled "Three canon lines I did not change, for your call", giving each line old beside new (the quote → "at Arrivals"; the two PROVISIONAL marks dropped, as this run did for P-849-1).
  - A to-file item 7 in the record's "Tickets — … to file" and in the handoff's tickets list: "To mint on VX — 'SurfaceContracts quotes the Finish confirm as "at the door" and keeps two ratified PROVISIONAL marks.' Debt · Confirmed · Books · Low · Wording." Its one-liner names the three lines.
- I invent no id; the record and the board snapshot show no existing ticket for this.

**R4-N4: AGREE.** VM-61's line draws in its own passthrough window at the window's foot, above sheets (`MobileMessageLine.swift:19-24`, `:117`), and the sheet draws none (`MobileBookDetails.swift:454-455`). No pin can see the line's placement. The re-worded rows for "The walk's rows (gate 3)" (record `:3199-3209`):
- Round 1's N9 (`:1195-1199`): "the tallest Book Details — an archived, journal-trait book with a rule (Finish with its three-line caption, the daily row, Unarchive with its pause sentence, Delete) — with a refusal standing on the one line (raised from the sheet itself: Rename Book to a live book's name in the same wing — the per-wing name guard refuses), at the medium and at the large detent. At the medium detent: does the line cover the sheet's last row (Delete), and is the line readable? On the tree that merges — with VM-47's sizes if VM-47 merged first (N9's own re-take note)."
- "a sealed book's Reopen sentence" → "a sealed book's Reopen — its refusal on the one line, captured with Book Details still up: the line readable, and where it stands against the sheet's last row."
- The membership-sheet row's "a ★-rule collect's line" → "…a ★-rule collect's line, captured with the membership sheet still up, the line readable above it."
- A refused Finish has no walkable road: it needs a store error, or the book deleted elsewhere while the sheet is up (`requestFinish`, `MobileBookDetails.swift:205-219`). It speaks through the same line as the sealed Reopen, so the row should say so rather than promise a capture.

**R4-N5: AGREE.** `MobileWriteView.swift:455` `.accessibilityLabel("Entry Date")` dates from `5992caf18`, before this run, and replaces the chip's drawn day for VoiceOver (by reading, not run). VM-218 exists in the board snapshot ([Todo] "Every screen works with VoiceOver and at the largest text size").
- **Make it a line on VM-218, not a new ticket, and not a code change in this pass.**
- In the record's "Lines for other owners" → the VM-218 bullet (`:3404-3406`), add: "and the masthead's date chip carries `.accessibilityLabel("Entry Date")` (`MobileWriteView.swift`, from before this run), which replaces the day it shows — VoiceOver hears "Entry Date" and never the date; an `.accessibilityValue` of the day would carry it (and would let a hosted pin read what the chip draws)."
- Fold the chip into to-file item 3 ("Book Details' name row and the note's date chip hide what they show from VoiceOver"), and the same into the handoff's tickets line `:253`.

---

**The corrected map** (the styling is VM-47's in every file; names are exact at HEAD)

- **`Features/Write/MobileWriteView.swift` — `MobileWriteScreen.dateChip`, 1 hunk.**
  - Keep `let day = Self.dateChipDay(model)` and the action's seed `dateField = Self.dateChipDay(model) ?? ""` (the seed auto-merged on the trial).
  - The label becomes `Text(day ?? tokens.chromeLabel("no date"))`, then `.phoneType(.chip, tokens)`, then `.foregroundStyle(day != nil ? tokens.phone.muted : tokens.phone.faint)`.
  - `static func dateChipDay(_ model: MobileEditorViewModel) -> String?` stays and returns `model.entryDate`.
  - Never `.header?.entryDate` anywhere in the file. `.accessibilityLabel("Entry Date")` stays as it is (VM-218's).
- **`Features/Write/MobileEditorViewModel.swift` — no hunk (for VM-64).**
  - `header` is assigned only inside `adoptHeader(_:)`, which sets `entryDate = value?.entryDate` beside `isSealed` and `displayTitle`.
  - `private(set) var entryDate: String?` stays observed, never `@ObservationIgnored`.
  - Any new header road calls `adoptHeader`. VM-64's tip already does all of this.
- **`Features/Shell/MobileCreateBook.swift` — `MobileCreateBookSheet`, 2 hunks plus one function outside them.**
  - `kindRow` is `PhoneSegmentedChoice(MobileCreateBookModel.BookKind.allCases, selection: model.kind, tokens: tokens, word: MobileCreateBookModel.kindLabel, select: { model.kind = $0 })`. HEAD's `kindDoor` cannot survive: VM-47 deleted it, and a word-row rebuild in VM-47's roles trips its controls scan.
  - VM-47's `static func kindWord` (auto-merged, outside any hunk) is deleted, or made to return `MobileCreateBookModel.kindLabel(kind)`.
  - The no-tags line is `Text(tokens.chromeLabel(MobileCreateBookModel.noTagsLine))` with `.phoneType(.meta, tokens)` and `.foregroundStyle(tokens.phone.muted)`.
  - The kind caption stays `MobileCreateBookModel.caption(for: model.kind)` (auto-merged on the trial).
- **`Features/Write/MobileMembership.swift` — `MobileMembershipSheet.membershipSection`, 2 hunks plus one restyle outside them.**
  - The name is `Text(tokens.chromeLabel(MobileMembershipModel.memberRowName(for: book)))` with `.phoneType(.rowTitle, tokens)`.
  - The mark is `if let mark = MobileMembershipModel.kindMark(for: book) { Text(tokens.chromeLabel(mark)).phoneType(.meta, tokens).foregroundStyle(tokens.phone.faint) }`. `kindMark` returns an optional.
  - Diverge stays inside `if MobileMembershipModel.rowCarriesDiverge(book) { … }`. VM-47's `.buttonStyle(PhoneInlineActStyle(tokens: tokens, tone: .muted))` goes on the Button inside that `if`, replacing the auto-merged `.font(tokens.small)` / `.foregroundStyle(tokens.muted)` / `.buttonStyle(.plain)` (trial `:361-363`, which VM-47's type scan reds). It never goes after the `if`'s brace, and the `if` is never unwrapped.
  - Unchanged and to keep: `addRow(MobileMembershipModel.addRowLabel(for: book))` on both add lists; `collect(into:)`'s `say(AddToBookCopy.collected(result, gatheringName: book.name), as: .refusal)`; VM-64's `refreshChip()` beside `refresh()`.
- **`Features/Shell/MobileBookDetails.swift` — `MobileBookDetailsSheet`, 4 hunks plus one restyle outside them.**
  - **`deleteRow(_ kind: ReadingKind)`:** `Text(tokens.chromeLabel(MobileShelfFaces.deleteDoorTitle(for: kind)))` with `.phoneType(.control, tokens)`; `.buttonStyle(PhoneMenuRowStyle())`; `.accessibilityLabel(MobileShelfFaces.deleteDoorTitle(for: kind))`; `.accessibilityHint(RecoveryCopy.deleteBookKeepsItsNotes)` (VM-47's side has no hint).
  - **`finishRow(_:)`:** the whole row stays inside `if let act = MobileBookDetailsModel.finishRowAct(for: book.reading) { … }`, so there is no row on an open gathering.
    - The action is `case .finish: await model.requestFinish()` / `case .reopen: await model.setFinished(false)`.
    - The verb is `act == .reopen ? BookStateCopy.reopenVerb : BookStateCopy.finishVerb`, in `.phoneType(.control, tokens)`.
    - The caption is `MobileBookDetailsModel.finishCaption(for: book.reading)` in `.phoneType(.meta, tokens)` / `tokens.phone.faint`, with `.lineLimit(3)` (VM-47's side has 2).
    - `.buttonStyle(PhoneMenuRowStyle())` goes on the Button inside the `if let`, in place of `.buttonStyle(.plain)`, never after the `if`.
    - Keep `.accessibilityLabel(act == .reopen ? BookStateCopy.reopenVerb : BookStateCopy.finishVerb)` and `.accessibilityHint(MobileBookDetailsModel.finishCaption(for: book.reading))`.
  - **`unarchiveRow(_:)` (no conflict; restyle by hand):** `BookStateCopy.unarchiveVerb` in `.phoneType(.control, tokens)`; `BookArchiveCopy.pausedSentence(for:)` in `.phoneType(.meta, tokens)` / `tokens.phone.faint`; `.buttonStyle(PhoneMenuRowStyle())`. Keep `.accessibilityLabel(BookStateCopy.unarchiveVerb)` and `.accessibilityHint(ifAny: BookArchiveCopy.pausedSentence(for: reading))`.
  - **Auto-merged, keep:** `deleteBook()`'s `RecoveryCopy.movedToTrashReceipt(.book, isGathering: book?.reading.kind == .gathering)`; `nameLine`; the Finish confirm's `.alert` on `finishConfirmPresented` / `pendingFinish`.
- **Auto-merged on the VM-47 trial — keep as they are:** `MobileShelfView`'s `rowActs` (no Pin); `MobileTrashView`'s `trashListingLoaded` gate (trial `:80`) and its `rowTitle` reading `RecoveryCopy.rowKind`; `MobileShelfFaces.deleteDoorTitle(for:)`; `MobileUndoDoor`'s `undoReporting` / `redoReporting` (VM-64 trial `:224`, `:282`).

---

**My own observations (not the reviewer's)**
- Mine: the finding's map and link 5 miss `MobileMembership.swift:361`, the Diverge button's `.font(tokens.small)`. It merges with no conflict, reds VM-47's type scan, and is the line whose "fix" tempts the unwrapping of `rowCarriesDiverge`.
- Mine: VM-64's tip still carries main's pre-VM-84 chip (`MobileWriteView.swift:461-466`), but VM-64 never edits those lines, so its trial merge keeps HEAD's chip; G1 is green there.
- Mine: VM-47's tip `65f26dc54` records its ladder round 2 closed with no further round earned, which supports the finding's guess that it may merge first.
- Mine: the walk's "the date chip" row should say "on a titled note — set a date, the chip shows it at once", because that is VM-84's case and the face G1 guards; run it on the tree that merges.
- Mine: in zsh, `git show $ref:App/…` silently fails, because `:A` is a path modifier. Briefs and recipes should write `"${ref}:App/…"`.

*(end of the implementer's answers)*

### The orchestrator's answers on R4-F1's process half (as sent)

> 1. I asked the stage coordinator the merge order; its call, from trial merges of the four pushed tips: (1)
>    vx-981 merges first, right after its merge gate, which holds the stage now — main moves then; (2) vm-64 and
>    vm-78 next, whichever sends its gate READY first — the two merge clean against each other, and the second
>    merger re-reads the five shared files after its merge-in; (3) vm-47 LAST — it does both resolutions once,
>    with this run's guard pins already on main. From a gate's GO until that run's merge the coordinator holds
>    main still. At this run's merge I hand the coordinator the hunk-by-hunk map and it goes into its "main
>    moved" message to vm-47's and vm-64's orchestrators. Against vx-981 this branch has one textual conflict
>    (notes/SurfaceContracts.md — both runs' lines kept) and two Mac files both runs changed that merge without
>    a conflict (BookSettingsSheet.swift, ShelfViewModel.swift), to be read by eye in the merged result.
> 2. So the plan I propose, for your call: (i) now — the implementer builds the guards and the NIT changes as
>    your final calls shape them, headless; (ii) when vx-981 has merged — a second merge-in by the same
>    implementer, every hand resolution and both auto-merged Mac files listed in the record; (iii) one short
>    stage window on THAT tree: the guards' red legs (the wrong side by hand, R4-N1's one line riding) then
>    green; (iv) ROUND 5 opens only after (ii) and (iii), and reads the guards, their window and the second
>    merge-in — it is the last round under the cap of five; (v) I send the gate's READY as round 5 opens, so
>    main is held still from the gate's GO while round 5 reads; a code fix round 5 confirms re-runs the leg it
>    touches; (vi) the implementer's hole 1: if vm-64 sends its gate READY before this run, this run merges
>    vm-64's merge in first — if that lands after round 5 has opened, no round under the cap reads it; it would
>    be read line by line by the implementer and by me against the five shared files, and I would put it to the
>    author plainly as unread by a cold round, hers to allow an extra read or not.

## Final calls

*Made by the round-4 reviewer after the answers came back. Nobody disputed a finding. The implementer corrected
my evidence in five places and tightened two guards; I rechecked each before taking it, and each is taken. No
finding is FINDER-FIXES: none is a `Sync/` line and none needs more than what is written here. The implementer
applies everything, each guard with its red shown; round 5's fresh reviewer re-checks.*

**What I re-ran before calling, read-only** (HEAD `3396c4611`; the tips had moved again since the answers were
written — VM-47 `ce9b6cfb1`, VM-64 `e3412bee4`, VX-981 `d534915ba`, each containing main `eb18888db`, main
unmoved):
- **The trial merges at those tips.** VM-47: the same four content conflicts. VM-64: clean. VX-981: one
  conflict, `notes/SurfaceContracts.md`, and THREE files both runs changed that merge without one —
  `BookSettingsSheet.swift`, `ShelfViewModel.swift` and `notes/AppSpec.md`. The orchestrator's answer names the
  two Mac files; AppSpec is the third. In the trial tree this run's lines stand in all three (`CollectingCopy`'s
  two captions over `BookStateCopy`; `nonisolated extension BookcaseCopy`; both §9 restore sites) beside
  VX-981's, which sit elsewhere in each file.
- **VM-47's type-scan pattern over the VM-47 trial tree:** ten lines, three of them outside any hunk —
  `MobileBookDetails.swift` (HEAD `:558`, `:563`) and `MobileMembership.swift` (HEAD `:361`). The implementer is
  right that my link 5 named only the first two.
- **The tightened G1 pattern** (`\.header[?!]?\.entryDate`): no hit at HEAD or in the VM-64 trial tree; three
  at `e48ef2f30`, one at `2d66e9a30`, three on main, three on VM-47's tip. `MobileStars.swift:178`'s local
  `header.entryDate` is not matched.
- **"smart" in string literals:** no tip (VX-981, VM-64, VM-47) holds one under `Shared/`, and none adds a site
  beyond main's five and the two that stay exempt.
- **The helpers the guard shapes lean on** exist and are reachable from another test file:
  `MobileNoRawErrorPinTests.strippingComments(_:)`, `MobileNoRedirectSweepTests.stringLiteralContents(of:)` and
  its `(file, literal, why)` table with the one-match cap, `VoiceTokens.studyLight`, and `withHostedSurface`'s
  own dead-tree check. `Queries.readingsContaining` keeps an archived book's membership row and lists a live
  gathering whose rule matches, as G3's fixture needs. Both exempt literals are single literals in the source,
  as quoted.

### R4-F1 — CONFIRMED AS AMENDED. The rank stands.

**The evidence, corrected** (each correction is the implementer's and is right):
1. *Link 4, the chip — two steps, not one.* With VM-47's label lines taken, `let day = Self.dateChipDay(model)`
   (`MobileWriteView.swift:444`) still runs in the body and still registers the observed read, so the face
   keeps re-rendering (by reading; an `@Observable` getter's access call is a side effect no optimiser may
   drop). VM-84 is undone when the then-unused `let day` is deleted — which the compiler's warning asks for,
   and which a merge-in that prides itself on "no warning in a line this merge-in wrote" will do. G1 catches
   step one.
2. *Link 4, the membership row — the Diverge regression is a hand edit, not a side.* VM-47's side of the second
   hunk puts its button style after the closing brace of `if rowCarriesDiverge(book) { … }`, which does not
   compile; the wrong edit is unwrapping the `if`, and VM-47's type scan, red on `:361` inside it, is what
   invites that. G3's count holds it.
3. *Link 4, Book Details.* VM-47's side of the Finish hunk fails to compile on its own too (the common lines
   after it read `act`). Loud, as the finding said.
4. *Link 2.* VM-47's `kindWord` — "Smart Book" — merges in OUTSIDE any hunk, so even a right resolution of the
   kind-row hunk leaves that literal in the file. G2 is the guard that sees it.
5. *Link 5.* `MobileMembership.swift:361` joins the Unarchive row's two lines: three lines of this run that no
   hunk will show and VM-47's type scan will red.

**Why the rank stands.** The create sheet and the membership row's name and mark are silent in one step; the
chip in two, the second invited by a warning; the Diverge gate by a hand edit a red scan invites. With the
coordinator's order the resolver of the four hunks is VM-47's merge-in, made after its own ladder closed — so
the guards on main and the map are what stand between that merge and three of this run's fixes.

**G1 — the date chip's face. Final shape, to build as written.**
- `@Test func noPhoneFaceReadsTheEditorsUnobservedHeaderDate()` in `MobileNoteEntryDateTests`
  (`MobileMembershipTests.swift`), beside the date pin.
- Walk the product `.swift` files under `VariorumMobile/` from the `#filePath` root; skip
  `Features/Write/MobileEditorViewModel.swift`; expect more than 60 files walked.
- Lines come from `MobileNoRawErrorPinTests.strippingComments(_:)`.
- An offender is a line matching `\.header[?!]?\.entryDate\b` — a member access on some object. The tightening
  is taken: my bare substring would trip on a legitimate local named `header`. It is NOT broadened to every
  `.header?.` read (the rename seed at `MobileWriteView.swift:244` is legitimate).
- Offenders print as `file:line`, and the failure message says the remedy, not only the rule: read
  `MobileWriteScreen.dateChipDay(model)`; `header` is unobserved (VM-84).
- The date pin's doc comment gains one sentence: this scan holds the face, the pin holds the seam.

**G2 — the "smart" faces. Final shape, to build as written.**
- `@Test func noPhoneStringLiteralSaysSmart()` in `MobileGatheringWordTests` (`MobileBookFixesTests.swift`).
- Roots: `VariorumMobile/` and `Shared/`, each asserted to exist and to be walked.
- Each file's literals come from `MobileNoRedirectSweepTests.stringLiteralContents(of:)`, so two literals on
  one line never join. Its known limit — a literal nested inside an interpolation is not read — is said in the
  test's comment; none of the seven sites is nested.
- The rule is the Mac's whole-word, case-insensitive one (`DeadVocabularyTests.containsWord`), as a small
  private copy with an oracle: "smart", "Smart Book" and "a smart book" hit; `isSmart` and "smartphone" do
  not. Both tightenings are taken.
- Exemptions are exact `(file, literal, why)` entries, each required to match exactly once — two of them:
  `MobileTodayDoor.swift`'s `.wrongKind` sentence (VM-85) and `MobileTutorialSeeder.swift`'s "hand-picked, a
  dated journal, or a smart book collecting by " (VM-212), each the source's own literal byte for byte. A
  third entry is not this run's to add.
- `noRenderedStringInTheseFacesSaysSmart`'s doc comment is re-worded: the scan exists now; the hand-kept list
  stays as the check on the pure functions.

**G3 — the membership sheet's face. Final shape, to build as written.**
- A new suite `MobileMembershipSheetFaceTests` in `MobileBookFixesTests.swift`, after
  `MobileCollectReceiptTests`.
- Fixture, in `withEditorWorld`: the tag `quote`; a book "Old projects"; a gathering "Quotes" on
  `.tag(quote)`; a note; `addPostToReading(note, to: book)`, then `archiveReading(book)`, then
  `applyTag(quote, toPost: note)`.
- One premise check first, with its own message, so a red in the fixture is never read as the face's:
  after `await model.refresh()`, `model.books.map(\.name) == ["Old projects", "Quotes"]`.
- Host `MobileMembershipSheet(model: model, tokens: .studyLight, onOpenNote: nil)` with `withHostedSurface`;
  settle.
- On `surface.visibleLabels`: contains "Old projects (archived)", "Quotes" and "gathering"; exactly one
  "diverge"; no label holds "smart" as a whole word.

**The red legs — ACCEPTED as an honest red, on four conditions.**
1. The record says in one sentence what the leg is: VM-47's reads and words applied in THIS branch's styling,
   which at each site is the pre-fix line, because VM-47's types do not exist on this branch — and that no
   guard's predicate reads styling.
2. The five seam pins are listed as EXPECTED GREEN on the red tree, by name, and the result line reports them:
   `theDateChipFollowsTheDateWhenTheTitleDoesNot`, `theMembershipAndCreateSheetsSayGathering`,
   `noRenderedStringInTheseFacesSaysSmart`, `pickersMarkAnArchivedBook`, `divergeIsNotDrawnOnAGatheringRow`.
   That is the finding's link 3 shown, not argued. A seam pin red there is reported as it fell, never
   explained away.
3. Expected RED, by name, and no other: G1 at `MobileWriteView.swift:449` and `:451`; G2 on three literals
   ("Smart Book", the no-tags line, "smart"); G3 on the archived name, the mark, the whole-word check and the
   Diverge count, each its own expectation; `bookDetailsDeleteLineNamesAGathering` at
   `MobileBookFixesTests.swift:666` only, its book half green. Anything else red is a finding.
4. It runs from the orchestrator's throwaway checkout, on the tree AFTER the VX-981 merge-in (the plan's step
   iii); the four files restored with `git checkout HEAD --` and a clean `git status` shown before the green
   leg; bundles checked and logs kept by round 2's R2-F1 rule.

**G1's optional no-rebuild leg against the pre-fix sources — NOT WANTED.** The red build's lines at the chip
are `e48ef2f30`'s own, so the pre-fix red is already what the build shows; the pattern's hits on the pre-fix
trees are recorded above from `git grep`. A built binary run over swapped sources adds a log whose tree is
neither commit, and stage time, and proves nothing more.

**The `.accessibilityValue` alternative — stays OUT of this pass,** for the implementer's reasons, which I
checked: it is a product line in the chip's view; it would not go red on the literal wrong side (the body still
observes `entryDate` through the value); and what the chip says to VoiceOver is VM-218's to word. R4-N5 carries
it there.

### The map, final

*Handed to the coordinator at this run's merge, for VM-47's and VM-64's orchestrators. The implementer's
corrected map is confirmed line by line against the VM-47 trial tree and VM-47's own rows; my additions are
marked. The styling is VM-47's in every file; the names are exact at HEAD.*

- **`Features/Write/MobileWriteView.swift` — `MobileWriteScreen.dateChip`, one hunk.** CONFIRMED.
  - Keep `let day = Self.dateChipDay(model)` and the action's seed `dateField = Self.dateChipDay(model) ?? ""`.
  - The label is `Text(day ?? tokens.chromeLabel("no date"))`, then `.phoneType(.chip, tokens)`, then
    `.foregroundStyle(day != nil ? tokens.phone.muted : tokens.phone.faint)`.
  - `static func dateChipDay(_ model: MobileEditorViewModel) -> String?` stays and returns `model.entryDate`.
  - Never `.header?.entryDate` anywhere in the file. `.accessibilityLabel("Entry Date")` stays as it is.
  - *Added:* a resolution that leaves `day` unused is the wrong one — the compiler's warning is the tell. Do
    not answer it by deleting `day`.
- **`Features/Write/MobileEditorViewModel.swift` — no hunk (for VM-64).** CONFIRMED; in the VM-64 trial tree
  `header = value` is at one place, inside `adoptHeader(_:)`, with `entryDate = value?.entryDate` two lines
  under it.
  - `private(set) var entryDate: String?` stays observed, never `@ObservationIgnored`.
  - Any new header road calls `adoptHeader`.
- **`Features/Shell/MobileCreateBook.swift` — `MobileCreateBookSheet`, two hunks and one function outside
  them.** CONFIRMED.
  - `kindRow` is `PhoneSegmentedChoice(MobileCreateBookModel.BookKind.allCases, selection: model.kind,
    tokens: tokens, word: MobileCreateBookModel.kindLabel, select: { model.kind = $0 })`. HEAD's `kindDoor`
    cannot survive (VM-47 deleted it).
  - VM-47's `static func kindWord` is deleted, or returns `MobileCreateBookModel.kindLabel(kind)`.
  - The no-tags line is `Text(tokens.chromeLabel(MobileCreateBookModel.noTagsLine))` with
    `.phoneType(.meta, tokens)` and `.foregroundStyle(tokens.phone.muted)`.
  - The kind caption stays `MobileCreateBookModel.caption(for: model.kind)`.
- **`Features/Write/MobileMembership.swift` — `MobileMembershipSheet.membershipSection`, two hunks and one
  restyle outside them.** CONFIRMED.
  - The name is `Text(tokens.chromeLabel(MobileMembershipModel.memberRowName(for: book)))` with
    `.phoneType(.rowTitle, tokens)`.
  - The mark is `if let mark = MobileMembershipModel.kindMark(for: book) { Text(tokens.chromeLabel(mark))
    .phoneType(.meta, tokens).foregroundStyle(tokens.phone.faint) }`.
  - Diverge stays inside `if MobileMembershipModel.rowCarriesDiverge(book) { … }`. VM-47's
    `.buttonStyle(PhoneInlineActStyle(tokens: tokens, tone: .muted))` goes on the Button INSIDE that `if`, in
    place of `.font(tokens.small)` / `.foregroundStyle(tokens.muted)` / `.buttonStyle(.plain)`. It never goes
    after the `if`'s brace, and the `if` is never unwrapped.
  - Unchanged, to keep: `addRow(MobileMembershipModel.addRowLabel(for: book))` on both add lists;
    `collect(into:)`'s `say(AddToBookCopy.collected(result, gatheringName: book.name), as: .refusal)`; VM-64's
    `refreshChip()` beside `refresh()`.
- **`Features/Shell/MobileBookDetails.swift` — `MobileBookDetailsSheet`, four hunks and one restyle outside
  them.** CONFIRMED.
  - `deleteRow(_ kind: ReadingKind)`: `Text(tokens.chromeLabel(MobileShelfFaces.deleteDoorTitle(for: kind)))`
    with `.phoneType(.control, tokens)`; `.buttonStyle(PhoneMenuRowStyle())`;
    `.accessibilityLabel(MobileShelfFaces.deleteDoorTitle(for: kind))`;
    `.accessibilityHint(RecoveryCopy.deleteBookKeepsItsNotes)`.
  - `finishRow(_:)`: the whole row stays inside `if let act = MobileBookDetailsModel.finishRowAct(for:
    book.reading) { … }`. The action is `case .finish: await model.requestFinish()` / `case .reopen: await
    model.setFinished(false)`. The verb is `act == .reopen ? BookStateCopy.reopenVerb :
    BookStateCopy.finishVerb` in `.phoneType(.control, tokens)`. The caption is
    `MobileBookDetailsModel.finishCaption(for: book.reading)` in `.phoneType(.meta, tokens)` /
    `tokens.phone.faint` with `.lineLimit(3)`. `.buttonStyle(PhoneMenuRowStyle())` goes on the Button inside
    the `if let`. Keep the row's `.accessibilityLabel` (the verb) and `.accessibilityHint` (the caption).
  - `unarchiveRow(_:)` — no conflict will ask for it; restyle by hand: `BookStateCopy.unarchiveVerb` in
    `.phoneType(.control, tokens)`; `BookArchiveCopy.pausedSentence(for:)` in `.phoneType(.meta, tokens)` /
    `tokens.phone.faint`, *its `.lineLimit(3)` kept (added)*; `.buttonStyle(PhoneMenuRowStyle())`. Keep
    `.accessibilityLabel(BookStateCopy.unarchiveVerb)` and `.accessibilityHint(ifAny:
    BookArchiveCopy.pausedSentence(for: reading))`.
  - Auto-merged, keep: `deleteBook()`'s `RecoveryCopy.movedToTrashReceipt(.book, isGathering:
    book?.reading.kind == .gathering)`; `nameLine`; the Finish confirm's `.alert` on `finishConfirmPresented` /
    `pendingFinish`.
- **Auto-merged on the VM-47 trial — keep as they are.** CONFIRMED: `MobileShelfView`'s `rowActs` (no Pin);
  `MobileTrashView`'s `emptyStateLine` gate on `trashListingLoaded` and its `rowTitle` reading
  `RecoveryCopy.rowKind(item)`; `MobileShelfFaces.deleteDoorTitle(for:)`; `MobileUndoDoor`'s `undoReporting` /
  `redoReporting`.
- ***Added — the scans (the implementer's hole 2).*** After the join, VM-47's three source scans
  (`MobilePhoneTypeSourceTests`, `MobilePhoneControlsSourceTests`, `MobileLookSourceTests`) are red or green on
  this run's lines by STYLING alone. A red there is fixed by restyling the line as this map says — never by
  putting back the other side's read or word, and never by unwrapping an `if`. Three lines no hunk will show:
  the Unarchive row's two `.font(…)` in `MobileBookDetails.swift`, and the Diverge button's
  `.font(tokens.small)` in `MobileMembership.swift`.
- ***Added — the guards.*** `noPhoneFaceReadsTheEditorsUnobservedHeaderDate`,
  `noPhoneStringLiteralSaysSmart` and `MobileMembershipSheetFaceTests` are on main when the join is made. Each
  goes red on the wrong side. A red there is fixed by this map, never by editing the guard; the word scan's
  exemption table holds two entries and a third is the author's call.
- ***Added — for VM-64, whose merge is textually clean: the five shared files, and what to see in each.***
  `MobileEditorViewModel.swift` (above). `MobileWriteView.swift`: the chip reads `dateChipDay` — VM-64's own
  tip carries main's chip lines, which it never edits, so its merge takes this run's. `MobileUndoDoor.swift`:
  `runUndo` and `redo()` read `undoReporting` / `redoReporting`, three arms each, beside VM-64's `inFlight`
  observer. `MobileMembership.swift`: `rowCarriesDiverge`, `kindMark`, `memberRowName`, `addRowLabel` and the
  collect line's composer, beside `refreshChip()`. `MobileLibraryView.swift`: this run changed comments only.

### The NITs

- **R4-N1 — CONFIRMED AS AMENDED.** The implementer's precision is right: the line-CLASS assertions
  (`line.leavesPage`, `expectOnTheLine`'s `.refusal`) are main's own behaviour and green on both sides, and the
  shelf's and the collect's WORDS were seen red in window (1) on the models' slots. So one pin lacks a seen
  red, not three: the Book Details join. Its one hand-reverted line (`MobileBookDetails.swift:306-307` back to
  `RecoveryCopy.movedToTrashReceipt(.book),`) rides the guards' red build: red at `:666`, the book half green
  at `:672`. Elsewhere "by reading" stands as recorded.
- **R4-N2 — CONFIRMED as answered, with one rule.** Every cited sentence changes as the implementer writes it,
  the false one included (`:3703` → "one session throughout, its context compacted once at a clean seam at her
  word"). The rule: each sentence is written to what is true WHEN it is written. The replacements were drafted
  before the coordinator's order was known; where one lists what is still ahead, it now also names the merge-in
  that follows VX-981's merge and the short window on that tree.
- **R4-N3 — CONFIRMED as answered.** Both changes: the handoff sub-section "Three canon lines I did not
  change, for your call", each line old beside new; and the to-file item. None of the three lines is edited by
  this run. One note for the merging session: a ticket takes ONE Area, and the three lines sit on three
  surfaces (the book settings sheet's Finish quote; P-849-5 on the take's ring; P-849-4 on the key file) — it
  picks the Area or splits the item. No id is invented.
- **R4-N4 — CONFIRMED AS AMENDED.** The implementer's re-worded rows are taken as written (round 1's N9 with a
  refusal raised from the sheet itself by a taken name; the sealed Reopen and the collect line each captured
  with its sheet still up). My "a refused Finish" is withdrawn as a capture: it has no walkable road, and the
  row says it rides the same line as the sealed Reopen. The implementer's own row is added: the date chip "on
  a titled note — set a date, the chip shows it at once". Every row is walked on the tree that merges.
- **R4-N5 — CONFIRMED as answered.** A line on VM-218, in the words the implementer gives; folded into to-file
  item 3 and the handoff's ticket line; no code in this pass.

### The process plan — my call on (i) to (vi)

- **(i) The guards and the NIT changes now, headless — YES.** One commit per guard with its doc-comment edit;
  the record and handoff sentences in their own commit; the phone target built for testing afterwards.
- **(ii) A second merge-in when VX-981 has merged — YES, with one file more.** The record lists the
  `notes/SurfaceContracts.md` resolution (both runs' lines kept) and the by-eye read of THREE auto-merged
  files, not two: `BookSettingsSheet.swift`, `ShelfViewModel.swift` and `notes/AppSpec.md`. Both targets
  build for testing on that tree.
- **(iii) One short window on that tree — YES:** the red legs as accepted above, then green over the same
  types.
- **(iv) Round 5 opens only after (ii) and (iii) — YES.** It reads the three guards and their doc edits, the
  window's logs and bundles, the VX-981 merge-in, the NIT edits and the map as written here.
- **(v) The gate's READY as round 5 opens — YES, with the order made exact, which closes most of hole 1.**
  Send the READY first; spawn round 5 on the coordinator's word that this run's gate is NEXT, with no other
  run's GO ahead of it. If the coordinator answers that VM-64 is ahead: wait for its merge, take it in, list
  it in the record as (ii) does, run the short window's GREEN leg again on that tree (the red legs are not
  owed twice — the guards did not change), and only then open round 5, which reads that merge-in too. A code
  fix round 5 confirms re-runs the leg it touches, and, being a final round's fix, gets the orchestrator's
  line-by-line check against its finding (CLAUDE.md).
- **(vi) The rest of hole 1 — as the orchestrator proposes, with a line drawn.** If a merge-in still lands
  after round 5 has opened: when it is textually clean, and `git diff` shows this run's lines in
  `MobileEditorViewModel.swift` and `MobileWriteView.swift` exactly as the map states them, no line was typed;
  the implementer's and the orchestrator's read of the five shared files against the map, the three guards
  green and the gate's legs on that tree are the evidence, and it is put to the author plainly as unread by a
  cold round — hers to allow or to send to an extra read. When ANY line in those two files is resolved by
  hand, I do not call it covered: CLAUDE.md gives the editor-seam class a Fable read, and only she waives it.
  Ask before the merge, not after.
- **The implementer's hole 2** is now the map's "scans" line, for VM-47's own merge-in.
- **Its third point stands and the plan meets it:** this run merges only after the guards' window, because
  with VM-47's ladder closed the guards on main are that merge-in's only reader besides its own orchestrator.

### The implementer's own observations

1. *`MobileMembership.swift:361` missed* — TAKEN: link 5 and the map (above).
2. *VM-64's tip still carries main's chip* — changes nothing here; written into the map's VM-64 line, so its
   orchestrator knows why the merge takes this run's chip.
3. *VM-47's round 2 closed* — overtaken by the coordinator's order (VM-47 merges last); it is why the plan's
   last point matters.
4. *The walk's date-chip row* — TAKEN (R4-N4).
5. *zsh and `git show $ref:App/…`* — TAKEN as a recipe rule: a brief or recipe writes `"${ref}:path"`. I met
   the same trap in this round; in my shell it failed loudly, with a mangled path.

### The ladder after this round

**0 BLOCKER · 1 MAJOR · 0 MINOR · 5 NIT; every finding dispositioned; none disputed; none FINDER-FIXES.** One
MAJOR, so round 5 is earned under her standing rule and is the last under the cap of five. It opens as (iv) and
(v) say. If it finds a BLOCKER or a MAJOR, the cap is reached and what follows is hers to say.

| Finding | Final call | What changes |
|---|---|---|
| R4-F1 MAJOR — the next wave-1 merge conflicts on three unpinned faces | CONFIRMED AS AMENDED | G1, G2, G3 as shaped above, each shown red on the wrong side in one red build and green after; the map handed to the coordinator at this run's merge; the process plan (i)–(vi) as called |
| R4-N1 — pins red by reading only | CONFIRMED AS AMENDED | one pin, not three; its one line rides the guards' red build |
| R4-N2 — stale sentences, one false | CONFIRMED | the implementer's sentences, each made true at the time of writing |
| R4-N3 — three stale canon lines with no owner | CONFIRMED | a handoff sub-section for her call and a to-file item; no canon line edited here |
| R4-N4 — the walk's rows predate the merge | CONFIRMED AS AMENDED | the re-worded rows; "a refused Finish" withdrawn as a capture; the date-chip row added |
| R4-N5 — the date chip's label hides its day | CONFIRMED | a line on VM-218; no code |
