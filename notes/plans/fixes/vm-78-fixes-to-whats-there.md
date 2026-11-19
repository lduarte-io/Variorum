# VM-78 — Run: Fixes to what's there (mobile catch-up, wave 1, umbrella 4)

**STATUS: OPEN 2026-11-19. Orchestrator session `vm-78`; /run-phase, overnight; `nov18` coordinating the stage and
the merges. Branch `vm-78-fixes-to-whats-there`, worktree `~/dev/variorum-vm-78` (Pro).**

## FOR A LATER READER

*Written at closeout. Until then this file is the live working record: the kickoff, the batches and each batch's
LIVE STATUS below are current.*

---

## Kickoff message (handed to every implementer verbatim, with the batch named)

> You are the implementer for ONE batch of the run **VM-78 — Fixes to what's there**, the fourth umbrella of the
> mobile catch-up's first wave. The run makes what the phone app already has behave rightly: ten small, mostly
> independent fixes, pin before fix per member. Nothing here is a redesign; the redesigns are later waves.
>
> **Work only in the worktree `~/dev/variorum-vm-78`** (branch `vm-78-fixes-to-whats-there`).
> Never commit from, or switch, `~/dev/variorum`.
>
> **Read first, yourself, in this session:** `CLAUDE.md` and the canon it auto-loads; `notes/MobileSoul.md` §1–5;
> `notes/SessionResiliencyProtocol.md` (it binds you); `notes/plans/vm-44-mobile-catch-up-plan.md` ("The rules
> every umbrella inherits"); `notes/plans/vm-44/plans/sitting-1-rulings.md`; this file's **Kickoff facts**, **your
> batch's section** and nothing of the other batches beyond their titles; then, for each member of your batch,
> the audit rows and files its entry names. `notes/TEXTKIT2_NOTES.md` §3–4 if your batch says "editor seam".
>
> **The rules that bind every member:**
> - **Pin before fix.** For a bug-class member: write the pin first, show it RED on the pre-fix code and GREEN
>   after (verified by revert — commit the fix before you revert, restore with `git checkout -- <file>`, and say
>   in LIVE STATUS that a revert is in flight before you start one). A pin that is green on both sides exposes
>   the member as hollow: record that, do not "fix" it. A wording member pins the new words exactly.
> - **Brains live in Core or `App/Variorum/Shared/`; the phone owns faces.** Where a member needs words or a rule
>   that today sits in Mac-app code, HOIST it into `Shared/` (the Mac keeps compiling and its strings stay
>   byte-identical; move only what the member needs) rather than forking a phone copy.
> - **Her rulings govern; where they are silent, never invent.** A choice the batch entry does not settle and
>   that does not gate the member: write 2–3 options into your LIVE STATUS, build the most spec-defensible, mark
>   it **PROVISIONAL**. Do not edit `notes/QUESTIONS.md` (a shared ledger, touched only at the merge) — list the
>   question in LIVE STATUS and the orchestrator files it.
> - **Rendered words:** sentence case, short and plain, the Mac's own words wherever a Mac face exists; never a
>   word capitalised for emphasis; nothing that tells her to "do it on the Mac". No new line for an ordinary
>   act; a refusal always speaks a sentence, never raw error text.
> - **Commits:** one per coherent piece, pushed after each (`git push`), message `VM-NN: …` ending
>   `Part of VM-78`. NO `Co-Authored-By` or session trailer. Commit by pathspec; never `git add -A`. The repo is
>   public: commit messages and notes are public copy.
> - **The stage:** you may run `swift build` / `swift test` on the core package and `xcodebuild build` /
>   `build-for-testing` freely. You may NOT run `xcodebuild test`, boot a simulator, or launch the app until the
>   orchestrator sends you a GO carrying the claim line; then follow that message exactly and release when done.
>   So this batch has TWO halves: (1) code + pins + a green `build-for-testing`, then END YOUR TURN with the
>   report below; (2) on the orchestrator's GO message, run the pins (red-on-old, then green), fix what the run
>   shows, flip LIVE STATUS, release the stage, report.
> - **LIVE STATUS** for your batch is in this file under your batch's section. Fill it from your first commit:
>   one line per member — `DONE (hash)` · `IN-PROGRESS — what remains` · `NOT-STARTED`; every unverified claim
>   marked **PENDING**. A fresh session with only the repo must be able to finish the batch from it.

*(The orchestrator appends the skill's implementer addendum — autonomous mode, the never-list, the subagent rule,
the stage rule, the report shape — after this blockquote.)*

## Kickoff facts (2026-11-19)

- **Members — the sub-issue roster of VM-78, listed from Linear at kickoff (ten; it matches
  `notes/plans/vm-44/plans/minted/umbrella-04.md`):** VM-43 · VM-16 (carries VM-20) · VM-81 · VM-3 · VM-83 ·
  VM-21 · VM-33 · VM-17 · VM-24 (carries VM-19) · VM-84. All moved to In Progress at kickoff.
- **Cast:** `opus-implementer` per batch, a fresh one per batch; **`fable-reviewer`** on the ladder (VM-84 edits
  `MobileEditorViewModel` / `MobileWriteView` — the editor seam, dependency-notes §4; VM-24 and VM-17 work in
  the editor's test and badge code); the Fable orchestrator briefs, verifies, adjudicates and records, and types
  no batch code. Cross-model ladder: the reviewer makes the final call, the implementer applies the fixes.
- **No `Sync/`, no custody, no schema** — verified against every member's files. Not the wave's sync slot.
- **The ladder's cap, tonight only — her ruling in this session (2026-11-19), verbatim:** "sounds good, tonight,
  up to 5 review rounds as long as a major is found." So for this run tonight: a round that surfaces a new
  BLOCKER or MAJOR earns the next, up to round 5; a round with neither closes the ladder. Every round is a fresh
  `fable-reviewer`. The standing cap of three returns after tonight.
- **Her frame for the night (2026-11-19, verbatim, in this session):** "and just to be clear, the plan is
  sequential merges to main, overnight provisional running, but I won't get a new phone build until wave 2 is
  done according to what another session said." This run closes on a simulator walk, not her phone; its
  PROVISIONAL calls are bundled for her next sitting.
- **Her rulings later the same night (2026-11-19, in this session), verbatim:** "letting alll my sessions know
  this - which is good, since three of your fixes will solve active hazards. i resolved that issue with vx-64.
  book order - that's fine to leave it for wave 3. 2 - collect receipt your choice is fine.  resolved the
  previous install blocker with vm-55. now, i'll plan to have the wave 1 build installed on my phone after the
  last vm has merged in, prepared by the last one - a new session should be able to help me with the install if
  i don't want to wake a stale cache. sound good? the phone step is the single wave-1 install after all four
  runs have merged. I'll do the hands part hands on in the morning." What they answer here: **VM-83's order** is
  a–z, digit-aware, starred first, and the visible order choice waits for the Bookcase in wave 3 (VM-113);
  **VM-21's collect receipt** is kept and made true (whether the line exists at all still goes to her wording
  pass); **the phone step** is ONE wave-1 install after all four mobile runs have merged, prepared by the last
  merger (the device build from merged main and a paste-ready install kickoff a fresh session can run with her,
  per `notes/plans/vm-44/plans/vm-45-install-runbook.md`), her hands in the morning.
- **A known merge conflict, relayed by nov18 from vm-55 (2026-11-19):** vm-55's branch moves every phone screen's
  error and receipt slot onto one message seam (`Shared/StatusCenter.swift`, the phone's `Shell/MobileLine.swift`
  and `Shell/MobileMessageLine.swift`); its undo door no longer draws "Undid: ‹label›" with a Redo button, and
  `MobileUndoDoorTests`' pins were rewritten to that; it also touches `MobileEditorViewModel.report` and nine
  report calls in `MobileStructural`. vm-55 merges first. When this branch takes main in behind it, VM-16 is
  re-landed on that vocabulary by an implementer — the same rule (a quiet press refuses and offers no way back),
  its pins re-shaped and shown red and green again — and a later ladder round reads it as new work.
- **She is away overnight** (relayed by nov18, her words to it: "rule provisionally in my absence, i'll check in
  in the morning"): a fork that does not gate a member is ruled PROVISIONAL and bundled; nothing author-only is
  touched; no question dialogs.
- **`App/Variorum/Shared/` changes** (the `BookStateCopy` words hoist, batch A) ⇒ the merge gate adds the Mac
  suites beside the whole phone target (nov18's rule).
- **Riders:** none offered. Every open VM ticket already has its umbrella and wave in the approved plan
  (`vm-44-mobile-catch-up-plan.md`); pulling one forward would re-compose a wave, which is hers to say.
- **VM-81's blocker (VM-62, umbrella 2's refusals in words):** only the sealed book's Reopen sentence leans on
  it. The shared `OpsRefusalTable` already words `.readingSealed` (`App/Variorum/Shared/OpsRefusalTable.swift`),
  so batch A routes that ONE refusal through the shared table now; VM-62's sweep of every other raw-dump site
  stays vm-55's. Expect a small textual conflict at that site when the two branches meet; whoever merges second
  rebases.
- **File overlap inside the wave** (dependency-notes §5): the Shelf files with VM-47 (sizes and look), the
  listing call sites and receipt lines with VM-55 (wings underneath). Merges serialize through nov18.
- **The simulator:** the standing phone-suite device, iPhone 17 Pro / iOS 26.2, addressed by UDID
  (`<simulator-udid>` — the orchestrator hands the value in each GO message; it is never written into the repo),
  booted fresh inside a claim, settled before the launch, shut down before the release. DerivedData for this
  run: `App/Variorum/DerivedData/vm78-ios` (phone) and `App/Variorum/DerivedData/vm78-mac` (the Mac leg).
  `-only-testing` takes TYPE names and the list is a zsh array.
- **The standing phone red:** `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`
  — VM-24, this run's own member (batch C). Until batch C lands, name it in every result line; never chase it
  from another batch.
- **Stage protocol (nov18, in writing):** REQUEST (sent at kickoff: four windows) → READY (a separate ping, able
  to start now) → GO (only from nov18, with the claim line; a free stage is never an invitation) → RELEASE plus
  one result line: Executed counts, EVERY failing test by name, sim shut down, no Variorum instance left, any new
  `Variorum-*.ips` or Problem Reporter window. Ask before T−10 for more time. Never hold a claim across a wait
  on her.
- **Evidence the run closes on** (the plan's rule: use-shaped, never a pin alone): the per-member pins; the
  whole phone target; the Mac suites over the changed Shared files; and a simulator walk on the dev-store Debug
  phone build through the changed faces (the Finish confirm with waiting arrivals, a gathering's doors, the
  starred archived book's way out, the shelf's order, the undo door after a quiet press, a restore and its kept
  moment, the date chip, the Trash's first paint, the tutorial lesson).
- **Preflight read:** CLAUDE.md and its loaded canon · the master plan's in-flight table (row added, `a501c4d29`)
  · the board snapshot · the catch-up plan, `umbrella-04.md`, the dependency notes, her rulings by surface, the
  work list's seventeen rows and their audit rows · MobileSoul §1–5 and §7 · the resiliency protocol · the
  review prompt · the ten tickets in full. Not triggered: SyncSpec (no `Sync/` line), CastleRules (no protection
  sentence), MCPSpec (the door is Mac-only; `restoreCommit` is called with an argument it already takes, its
  meaning unchanged). TEXTKIT2_NOTES §3–4 is the implementer's and the reviewer's for the seam members.

## The batches (run order: B, then A, then C)

### BATCH B — the note: undo, restore, the date chip, the Trash, the tutorial (VM-16 · VM-43 · VM-84 · VM-33 · VM-3)

Five independent fixes; four are in the plan's "should not wait" set or Urgent. Stage window (2).

- **VM-16 (Urgent; carries VM-20) — the undo door.** Audit C·B18. `VariorumMobile/Features/Write/MobileUndoDoor.swift`
  (~:202, :246) calls `undo(with:)` / `redo(with:)`, which return the label even for a quiet press, so after a
  quiet undo of X the phone says "Undid: X" and offers a Redo that runs a different entry (and the mirror for a
  quiet redo). The fix is the Mac door's shape: `undoReporting` / `redoReporting`; on a quiet outcome speak the
  shared refusal from `Shared/StructuralUndoCopy` ("Nothing to undo — ‹label› was already undone or changed
  since." / "Nothing to redo — it changed again after ‹label› was undone.") and offer NO ping-pong action.
  Read the Mac's door for the exact shape; AppSpec §9 "Structural undo and redo" is the contract. **Pin (the
  ticket's):** register X then Y, undo Y, reverse X through an undo-less door, then undo — the report carries no
  `.redo` action and speaks the refusal; and the mirror for redo. **VM-20:** the undo-overwrite warning's detail
  says "It is saved first" (~:285) where the Mac says "committed" — use the Mac's sentence (find it; if it is
  Mac-local, hoist the one string to `Shared/StructuralUndoCopy`), pinned exactly. Note VX-342 (the Mac's detail
  says "BEFORE" in capitals) is a separate open Mac ticket: do not carry shouting capitals to the phone; if the
  Mac's sentence has them, use the sentence-case form on the phone, mark it PROVISIONAL and say so.
- **VM-43 — restores keep the replaced words.** Audit C·H4; her ruling QUESTIONS #274 addendum 2 ("Ratify + wire
  the phone."). `Takes/MobileBlockHistory.swift:483` calls `ops.restoreCommit(variantID, commitID:)` with no
  insurance. Wire `insuringBuffer: true` at EVERY phone restore call site (grep for `restoreCommit` across
  `VariorumMobile/`; the Mac's flush-first restore doors are the model — pending typing is flushed first, then
  the restore, the insurance inside the one transaction; AppSpec §9 `restoreCommit`). **Pin:** type into a take
  past its last savepoint, restore an older commit through the phone's door, and the take now has one more
  quiet `auto` savepoint holding the replaced words (and none when the buffer equals the last savepoint — the
  dedupe). Background: `notes/plans/fixes/vx-849-typed-over-rescue.md`, FOR A LATER READER, P-849-1.
- **VM-84 — the date chip (EDITOR SEAM).** Audit F §12.5. `header` is `@ObservationIgnored`
  (`Write/MobileEditorViewModel.swift:128`); the chip reads `model.header?.entryDate`
  (`Write/MobileWriteView.swift:456-468`), so it refreshes only because the title changes in the same pass.
  Make the chip's fact observed with the SMALLEST change: do not make the whole header observed if that would
  re-render the editor surface on every header refresh (P3, and audit F's lag findings — read F §12.5 and what
  it says about why `header` is ignored before choosing). Options to weigh in LIVE STATUS: a small observed
  `entryDate` mirror set where `header` is set · un-ignoring `header` with the render cost measured · the chip
  reading its own narrow observation. **Pin:** change a note's entry date with the title untouched (the
  `setEntryDate` / `shiftEntryDate` op, then the model's refresh road) and the value the chip renders changes;
  red on old.
- **VM-33 — the Trash's first paint (Suspected: check first).** Audit A·E11. `Shell/MobileTrashView.swift:84`
  draws its empty line on `model.trash.isEmpty`, the Mac's pre-VX-670 shape. First establish whether the phone
  really paints "empty" before the first value (read the model's observation start; a pin that holds the
  observation back is the proof). If real: the Mac's rule — the empty line is nil until the listing's first
  value answers (`RecoveryViewModel.trashEmptyStateLine`, commit `8d87d3f39`; record
  `notes/plans/fixes/vx-678-trash-purge-resurrection.md`, FOR A LATER READER); if that rule is a pure function
  in Mac-app code, hoist it to `Shared/` and use it from both. If hollow: record it and change nothing.
- **VM-3 — the tutorial's retired lesson (Wording).** Audit C §2.13, D·D-49. `Tutorial/MobileTutorialSeeder.swift`
  (~:593-608) still teaches the duplicate divide ("copied onto both halves") while the phone divides keep-on-top
  (`Write/MobileStructural.swift:165`; AppSpec §9 divide: the displayed take is cut and every other take rides
  whole onto the top block). Rewrite the lesson to teach what the phone does, in the tutorial's existing voice,
  as few words as the old lesson; the wording is a DRAFT for her wording pass — put the old and new text side by
  side in LIVE STATUS. Unwrap the lesson's pin from `withKnownIssue` so it asserts the truth plainly. Do not
  touch the Mac's guide. (The whole pocket guide is rewritten in wave 6, VM-212; this is only the false lesson.)

**Evidence:** each member's pin red-on-old and green; the batch's suites green by TYPE name in window (2).

#### BATCH B — LIVE STATUS

*Implementer: `opus-implementer`, session of 2026-11-19. Half 1 = code + pins + a green `build-for-testing` (no
`xcodebuild test`, no simulator); half 2 = the stage window's red-on-old + green runs. **No revert is in flight.***

**Half 2 — DONE (2026-11-19, stage window (2), claimed 04:03:11, released 04:07:08; run by the orchestrator as a
verification act from a throwaway detached checkout at `d17e61b2d` with its own DerivedData, so batch A's
implementer kept the worktree to itself; the recipe above, unchanged).**
- **RED run (the seven files at their pre-fix versions):** Swift Testing 68 tests in 6 suites FAILED, 20 issues
  including 2 known. Failed — exactly the seven expected and no other: `aQuietUndoSpeaksTheRefusalAndOffersNoRedo`
  · `aQuietRedoSpeaksTheRefusalAndOffersNoUndo` · `theWarningsDetailSaysCommittedInTheMacsSentence` ·
  `aRestoreKeepsTheReplacedWordsAsAQuietSavepoint` · `theFannedDivideLessonSaysKeepOnTop` ·
  `theDateChipFollowsTheDateWhenTheTitleDoesNot` · `theFirstPaintSaysNothingBeforeTheListingAnswers`.
- **GREEN run (the tip, restored; `git diff HEAD` empty in the checkout):** Swift Testing 68 tests in 6 suites
  PASSED with 2 known issues (the designed `MobileTrashTests` diagnostic,
  `anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`); 0 failed.
- **VM-33 is REAL, not hollow:** its first-paint pin went red on the pre-fix tree.
- Still owed outside this window: the Mac guard `UndoWarningWordsTests` (+ `DestructiveUndoWarningTests`) in the
  merge gate's Mac leg; the walk captures for these five rows in the gate's walk leg.

| Member | State | Pin (TYPE name for `-only-testing`) |
|---|---|---|
| VM-16 (+VM-20) | DONE (`48055fa9c`, `a11af21d0`) — red-on-old and green VERIFIED in window (2); the Mac guard waits for the gate's Mac leg | `MobileUndoDoorTests`, `MobileUndoWarningWordsTests` (+ the Mac guard `UndoWarningWordsTests`, Mac leg) |
| VM-43 | DONE (`0f8ca319d`) — `insuringBuffer: true` at the ONE phone call site; red-on-old and green VERIFIED in window (2) | `MobileBlockHistoryTests` |
| VM-3 | DONE (`c29095d35`, `a11af21d0`) — lesson rewritten (DRAFT for her wording pass), pin unwrapped + flipped, words pin added; red-on-old and green VERIFIED in window (2) | `MobileTutorialStructureWalkTests` |
| VM-84 | DONE (seam + pin `2d66e9a30`, fix `f933a4663`) — red-on-old and green VERIFIED in window (2) | `MobileNoteEntryDateTests` |
| VM-33 | DONE (`e1d709b1b`) — REAL: its first-paint pin went red on the pre-fix tree, green on the fix (window (2)) | `MobileTrashTests` |

**Half 1 — DONE (2026-11-19):** every member's code + pins committed and pushed; phone `build-for-testing`
(`-destination 'generic/platform=iOS Simulator'`, DerivedData `vm78-ios`, `CODE_SIGNING_ALLOWED=NO`) **TEST BUILD
SUCCEEDED**, then again signed for the pinned device by name (no boot) **TEST BUILD SUCCEEDED**; Mac `build-for-testing` (DerivedData `vm78-mac`) **TEST BUILD SUCCEEDED**. No `xcodebuild test` run, no
simulator booted, no walk. No PROVISIONAL call in this batch; the one draft is VM-3's lesson wording (her pass).

**Half 2 — the stage window's recipe (a fresh session can run it from here):**
1. Write "REVERT IN FLIGHT — product files at their pre-fix versions; restore = `git checkout -- <the seven
   files>`" into this LIVE STATUS, commit + push, THEN revert (every fix is committed, so the restore is safe):
   `git checkout 463411619 -- App/Variorum/VariorumMobile/Features/Write/MobileUndoDoor.swift
   App/Variorum/VariorumMobile/Features/Takes/MobileBlockHistory.swift
   App/Variorum/VariorumMobile/Features/Tutorial/MobileTutorialSeeder.swift
   App/Variorum/VariorumMobile/Features/Shell/MobileTrashModel.swift
   App/Variorum/VariorumMobile/Features/Shell/MobileTrashView.swift` and `git checkout 2d66e9a30 --
   App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift
   App/Variorum/VariorumMobile/Features/Write/MobileWriteView.swift` (VM-84's "old" is its seam commit, which reads
   `header` exactly as shipped). The pins compile against this tree (none references a new product symbol except
   VM-84's seam, present at `2d66e9a30`).
2. RED run (the `xcodebuild test` below). Expected RED, by name: `aQuietUndoSpeaksTheRefusalAndOffersNoRedo`,
   `aQuietRedoSpeaksTheRefusalAndOffersNoUndo` · `theWarningsDetailSaysCommittedInTheMacsSentence` ·
   `aRestoreKeepsTheReplacedWordsAsAQuietSavepoint` · `theFannedDivideLessonSaysKeepOnTop` ·
   `theDateChipFollowsTheDateWhenTheTitleDoesNot` · `theFirstPaintSaysNothingBeforeTheListingAnswers`. Expected GREEN
   on both sides (controls/guards): `aLandedRedoStillOffersItsUndo`,
   `aRestoreOverABufferEqualToItsLastSavepointAddsNoSavepoint`, `theFannedDivideLessonLandsKeepOnTop`,
   `anEmptyTrashSaysSoOnceTheListingAnswers`, and every pre-existing test in the six types.
   (`MobileTrashTests` carries a DESIGNED known issue — `anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`
   — whose recorded issues are the harness diagnostic, not VM-33.)
3. `git checkout -- <the seven files>`; `git status` clean; record "no revert is in flight".
4. GREEN run (same invocation). Every test in the six types green.
5. Release the stage (sim shut down, no Variorum instance left), flip this table, report.

```zsh
ONLY=(
  -only-testing:VariorumMobileTests/MobileUndoDoorTests
  -only-testing:VariorumMobileTests/MobileUndoWarningWordsTests
  -only-testing:VariorumMobileTests/MobileBlockHistoryTests
  -only-testing:VariorumMobileTests/MobileTutorialStructureWalkTests
  -only-testing:VariorumMobileTests/MobileNoteEntryDateTests
  -only-testing:VariorumMobileTests/MobileTrashTests
)
xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'platform=iOS Simulator,id=<simulator-udid>' \
  -derivedDataPath App/Variorum/DerivedData/vm78-ios "${ONLY[@]}"
```
(The project's own simulator signing, deliberately — the phone target carries keychain access-group entitlements,
so the test host is not run unsigned. A signed `build-for-testing` for `platform=iOS Simulator,name=iPhone 17
Pro,OS=26.2` into `vm78-ios` is already **TEST BUILD SUCCEEDED** (no boot, no install), so the GREEN run starts
up to date; the RED run recompiles only the seven reverted files and their dependents.)
The Mac leg (the merge gate's, not window 2's unless the orchestrator says so): `UndoWarningWordsTests` (the new
byte-exact guard) and `DestructiveUndoWarningTests` over DerivedData `vm78-mac`.

**Traced mechanisms (read in this session, before any code):**
- **VM-16.** `MobileUndoDoor.runUndo` / `redo` called `UndoStack.undo(with:)` / `redo(with:)`, which return the
  entry's LABEL for a quiet press too (`UndoStack.swift:346`, `:382` — `undoReporting(...)?.label`). A quiet undo
  RETIRES its entry and leaves the redo stack as it was, so the door said "Undid: X" and offered `.redo` — whose
  press re-applies the redo stack's top, a DIFFERENT entry (and the mirror for a quiet redo offering `.undo`). The
  Mac's door (`ShellActions.structuralUndo` / `structuralRedo`) reads `undoReporting` / `redoReporting` and speaks
  `StructuralUndoCopy.undoFoundNothing` / `redoFoundNothing` with no way back on a quiet outcome.
- **VM-20.** The phone's A12 detail (`MobileUndoDoor.discardingUndoDetail`) said "It is saved first"; the Mac's
  (`ShellActions.discardingUndoDetail`, Mac-local) says "It is committed first". VX-342 has already landed on the
  Mac (no shouted capitals in either detail), so nothing shouted is carried.
- **VM-43.** `MobileBlockHistoryController.restore` (flush-first already) called `ops.restoreCommit(variantID,
  commitID:)` with no `insuringBuffer`, so the words a restore replaced were kept nowhere. It is the only
  `restoreCommit` call under `VariorumMobile/` and `Shared/`.
- **VM-3.** The phone's fanned divide is keep-on-top (`MobileStructural.swift` → `KeepOnTopDivide.compose` →
  `divideW`: the displayed take is cut, every other take parks whole on the TOP block); the "divide with takes"
  lesson still taught the duplicate shape, and its walk pin asserted that shape inside `withKnownIssue`.

**What changed, file by file (half 1):**
- VM-16: `VariorumMobile/Features/Write/MobileUndoDoor.swift` `runUndo` and `redo()` — `undoReporting` /
  `redoReporting`; three arms each (changed → receipt + the other direction; quiet → the shared refusal, no action;
  nil → "No structural change to …").
- VM-20: `Shared/StructuralUndoCopy.swift` gains `discardingUndoDetail(_:readBackFrom:)` (the Mac's sentence, moved);
  `Variorum/Registry/ShellActions.swift` `discardingUndoDetail` forwards with "the take's history (⌘S's list)" (bytes
  unchanged, pinned exactly in the Mac's `UndoWarningWordsTests`); `MobileUndoDoor.discardingUndoDetail` forwards
  with "the block's Block History". No PROVISIONAL: the Mac's sentence had no shouted capitals to drop.
- VM-43: `VariorumMobile/Features/Takes/MobileBlockHistory.swift` `restore(_:of:confirmed:)` passes
  `insuringBuffer: true`.
- VM-3: `VariorumMobile/Features/Tutorial/MobileTutorialSeeder.swift`, the "divide with takes" lesson's blocks 1–2
  (blocks 3–4, the ferry and the try-it line, unchanged and still true). **The wording is a DRAFT for her wording
  pass:**

  | | Old (taught the retired duplicate divide) | New (draft — what the phone does) |
  |---|---|---|
  | block 1 | Dividing a block that has several takes follows one simple rule on the phone: the take you're READING is cut in two, and every other take rides along whole — copied onto both halves, so nothing needs a matching cut and nothing is lost. | Dividing a block that has several takes follows one simple rule on the phone: the take you're reading is cut in two, and every other take rides along whole onto the top block, so nothing needs a matching cut and nothing is lost. |
  | block 2 | The extra copies are quick to delete where you don't want them — quicker than hunting for a lost take ever was. The original block keeps everything, off-stage, in lineage. | The bottom block holds just the second half. The original block keeps everything, off-stage, in lineage. |

  ("READING" lost its capitals per her no-shouting rule; the new text is 59 words to the old 72.) The Mac's guide is
  untouched. The walk pin `theFannedDivideLessonLandsKeepOnTop` (was `…LandsTheDuplicateShape`, wrapped) now
  asserts plainly: top block = the cut's first half + the other take whole (2 takes); bottom block = the second half
  alone (1 take); the original released with both takes in lineage. It is green on both sides by design (the
  phone's divide did not change); `theFannedDivideLessonSaysKeepOnTop` (exact words, no "both halves"/"copies") is
  the red-on-old pin.
- VM-84 (EDITOR SEAM — the editor view model and the masthead; no `EditorTextView`, `BlockRangeIndex` or
  `runStructural` line is touched): **mechanism** — `header` is `@ObservationIgnored`
  (`MobileEditorViewModel.swift`, "Editor internals (never observed)", so since S1 batch 1); the chip read
  `header?.entryDate`, so its body re-ran only when an OBSERVED sibling changed in the same `adoptHeader` pass —
  `displayTitle`, which is the date only on an untitled note. The `@Observable` macro on this SDK skips equal-value
  sets (`shouldNotifyObservers`, in the iOS 27.1 SDK's `Observation.swiftinterface` macro declaration), so on a
  TITLED note nothing the masthead observed changed and the chip kept the old day. **Options weighed (the brief's
  three):** (a) a small observed `entryDate` mirror set in `adoptHeader` — CHOSEN: it is this file's own pattern
  (`isSealed` and `displayTitle` are exactly such mirrors of header fields), and a set notifies only when the day
  changes, so no header delivery that leaves the date alone re-renders anything (pinned: the pin's third arm);
  (b) un-ignore `header` — rejected as wider than the chip needs: `header` is the keystroke road's read
  (`segmentationMode`, the seal check), and every body that reads any header field would then re-render on any
  header field's change (cheap in steady state — `ContainerHeader` is Equatable and carries no touched stamp — but
  it widens what the editor's views observe, against the brief's "smallest change"); (c) the chip reading its own
  narrow observation — rejected: a second `observeContainerHeader`-class DB observation per open note for one
  field (P1's direction is fewer held observations, audit F §7). Not PROVISIONAL (an implementation choice; no
  product behaviour changes). **Files:** `MobileEditorViewModel.swift` (`entryDate`, set in `adoptHeader`);
  `MobileWriteView.swift` (`dateChipDay`, read by the chip's words, ink and alert seed). **Pin shape:** the pin
  holds the chip's one read under `withObservationTracking` (SwiftUI's re-render mechanism) because the chip's
  rendered day is not in the accessibility tree (its label is "Entry Date"); the seam commit `2d66e9a30` is the
  "old" for the revert (it reads `header`, byte-for-byte the shipped behaviour).
- VM-33: **check first, by reading** — `MobileTrashView` is pushed; its body draws on the first render, and the
  observation starts in `.task(id: model.restartToken)`, which SwiftUI runs only after that render; `trash` starts
  `[]` (`MobileTrashModel`), and the body drew "Nothing in the Trash." on `model.trash.isEmpty`. So every opening of a
  non-empty Trash painted "empty" until `observeTrash`'s first value landed — the Mac's VX-670 mechanism exactly.
  **The proof is the pin**, which holds the observation back by construction (the surface is built and laid out
  with no `await`, so the `.task` cannot run) and reads the first paint; it must go red on the pre-fix tree in the
  stage window, or the member is hollow and gets reverted. **Fix:** `MobileTrashModel.trashListingLoaded` (lowered
  when `startTrash` begins, raised by each value) and `MobileTrashView.emptyStateLine(_:)` (nil until answered, then
  the line when empty). **Not hoisted:** the Mac's rule (`RecoveryViewModel.trashEmptyStateLine`) is a computed
  property over the Mac model's own state (its filter, its unfiltered-total flag, `RecoveryCopy`'s filter-aware
  words), not a pure function, so per the brief the phone carries the same two-line answered gate on its own
  model rather than a hoist. **Noted, not touched (out of scope):** under a kind filter the phone's line still
  says "Nothing in the Trash." even when other kinds wait — the Mac's ledger-row-2 rule; the phone's Trash face is
  wave 2's (VM-96).

### BATCH A — books (VM-81 · VM-83 · VM-21)

One surface, one implementer: the Shelf, the book's Details, the membership sheet, the create sheet, Starred.
Mockup for all three: `notes/plans/vm-44/design/mockups/a-book.html` (a starting point, not a pixel contract;
read its build notes). Audit: `notes/plans/vm-44/audit/B-books-family.md` rows named below. Stage window (1).

- **The hoist (first, its own commit):** move the WORDS these members need out of the Mac's
  `App/Variorum/Variorum/Features/Readings/BookStateDoors.swift` (`BookStateCopy`) into `App/Variorum/Shared/` —
  `finishVerb`, `reopenVerb`, `deleteVerb`, `deleteVerb(_:)`, `deleteDoorLabel(_:)`, `quoted(_:)`,
  `waitingLine(_:)`, `finishNeedsConfirm(pendingArrivals:)`, the finish confirm's title and line, and
  `ArrivalsCopy.word` if `waitingLine` needs it. Words only: do NOT hoist `BookStateConfirm`, the door sets or
  anything that drags the capability registry (later waves hoist those — W-070, W-112; and the registry in two
  branches at once is a known merge trap). The Mac's strings stay byte-identical and its existing copy pins stay
  green; say in LIVE STATUS exactly what moved and where.
- **VM-81 — Finish asks; doors only where they work.** B·G8, I3, I4, H6, M3.
  - *Finish confirm (W-105, her ruling):* `Shell/MobileBookDetails.swift` (~:111-116, :386-407) finishes at once
    and `lockReading` dismisses every waiting arrival in its transaction (AppSpec §9). Before acting, when N > 0
    arrivals wait, ask: the hoisted title ("Finish "‹name›"?") and line ("N waiting at Arrivals will be
    dismissed."), confirm "Finish", and a cancel. When nothing waits it acts at once (the Mac's
    `finishNeedsConfirm`). N is the act's own set — read it with the same predicate the op dismisses by (find the
    Mac's count read; hoist it if Mac-local, never a second definition). **The "Open Arrivals first" button is
    NOT built here** (VM-175, wave 4 — the phone has no Arrivals review yet). **Pin:** a book with waiting
    arrivals → the Finish door yields the confirm carrying the count and does not lock; confirming locks and
    dismisses; with none waiting it locks at once.
  - *The caption (W-106):* "freezes its notes" is false (text stays editable; Finished = assembly frozen, intake
    paused). Use the Mac's words for the Finished state if a Mac sentence exists (SurfaceContracts, The Bookcase
    and books; the Mac's book settings state doors), else draft the shortest true line and mark it PROVISIONAL.
  - *Finish not on gatherings (W-106):* the row is drawn on gatherings and `lockReading` then throws
    `wrongReadingKind`. Do not draw it there (P-2: a door that can never act is not rendered).
  - *Reopen on a sealed book (W-106):* `unlockReading` refuses `readingSealed` and the phone dumps raw text
    (`MobileBookDetails.swift:211-216`). The phone has no Unseal door until wave 4 (VM-161), so Reopen stays
    drawn and its refusal speaks the shared sentence: route this ONE refusal through `Shared/OpsRefusalTable`
    (which already words `.readingSealed`). Read that sentence: if it sends her to a door the phone does not
    have, say so in LIVE STATUS as a question for her rather than rewording shared copy.
  - *Diverge on gathering rows (W-110):* `Write/MobileMembership.swift` (~:154-163, refusing at :286-292) draws
    Diverge on a gathering's row. Do not draw it there.
  - *The starred archived book (W-120):* `Queries.starred` keeps archived readings and archiving never unstars,
    so an archived book opens from `Shell/MobileStarredView.swift` to an EMPTY Details sheet (Details reads the
    bookshelf listing, which drops archived books — `MobileBookDetails.swift:79-97, 254-268`). Give it its way
    out: Details resolves an archived book too, says it is archived (the shared `BookArchiveCopy` words) and
    offers Unarchive (`unarchiveReading`). The Archived room itself is wave 2 (W-117) — build only the way out.
    **Pin:** an archived starred book's Details is non-empty and carries the unarchive door; unarchiving returns
    it to the shelf.
- **VM-83 — order, one star door, "gathering".** B·A5, A9, A16, B4, K2, M1.
  - *Order (W-068):* the phone sorts through the retired `Shared/ShelfOrder.swift` (:39-54, via
    `Shell/MobileShelfFaces.swift:117-121`): starred, then journal-trait books, then the rest, case-sensitive and
    not digit-aware. Use the shared `BookcaseBoard` rule the Mac uses (`Shared/BookcaseBoard.swift:31-43`: a–z,
    digit-aware, the default; or last edited; starred float first). The ticket title says "a–z or by last
    edited": the RULE is in scope; a visible order choice is in scope only if it can be the smallest honest
    door on the existing shelf chrome (the Bookcase's real chrome is wave 3, VM-113) — if it cannot be done
    without designing chrome, ship a–z digit-aware as the order, leave the choice to VM-113 and record that as
    PROVISIONAL with the options. If `ShelfOrder` is left with no caller, delete it and its tests in the same
    commit. **Pin:** "apple" before "Zebra", "Book 2" before "Book 10", starred first; red on old.
  - *One star door (W-071):* "Pin to Shelf Top" and Star write the same star (`setShelfPinned` is `setStarred`).
    Remove the Pin door (`Shell/MobileShelfView.swift:317-330`, `MobileShelfFaces.swift:108-110`,
    `MobileShelfViewModel.swift:122-131`); Star stays. Pin: the shelf row's menu carries Star / Unstar and no
    Pin entry.
  - *"gathering", never "smart" (W-073):* every rendered site — shelf rows (`MobileShelfFaces.swift:74-76`), the
    delete door, confirm and receipt (`:142-143`, `MobileShelfViewModel.swift:194`; use the hoisted
    `deleteVerb(_:)` / `deleteDoorLabel(_:)`), the membership sheet (`Write/MobileMembership.swift:277-283`), the
    create sheet (`Shell/MobileCreateBook.swift:263-281` — "Smart Book", "A smart book collects notes by these
    tags"), and the Trash's empty-name placeholder (`Shell/MobileTrashView.swift:301`, "(empty book)" for an
    untitled gathering). Use the Mac's words wherever the Mac has the same face. **Pin:** a sweep test — no
    rendered phone string in these faces contains "smart" (case-insensitive), plus the exact new strings.
    Identifiers and the model's older spelling in code are NOT in scope (AppSpec §7: the code still carries it).
- **VM-21 — the collect receipt and "(archived)" marks.** B·F4, F5. `Write/MobileMembership.swift` (:88-104,
  :119-138, :314-319). The receipt after collecting a note into a gathering names no star on a ★-only collect
  and claims the gathering shows the note while it is archived (it assembles empty everywhere).
  `SmartCollectResult` (Core) already carries what was applied and `gatheringArchived`. Speak the Mac's register
  (find the Mac's receipt composer; hoist it to `Shared/` if Mac-local and use it from both): "Starred — the
  gathering shows it now." / "Tagged #x and starred — …" / the archived tail "…the gathering shows it once it's
  unarchived." Her receipts ruling ("no line for ordinary acts") does not remove this line: it is the existing
  receipt made true, and whether the phone keeps a collect receipt at all is a wording-pass question — list it.
  Pickers mark archived books "(archived)" with the shared `BookArchiveCopy` words. **Pins:** the three receipt
  arms exactly; an archived book's picker row carries the mark.

**Evidence:** each piece's pin red-on-old and green; the Mac's `BookStateCopy` pins still green (the Mac leg of
the merge gate); the batch's suites green by TYPE name in window (1).

#### BATCH A — LIVE STATUS

*Implementer: `opus-implementer`, session of 2026-11-19. Half 1 = code + pins + a green `build-for-testing` on BOTH
targets (no `xcodebuild test`, no simulator); half 2 = the stage window's red-on-old + green runs. **No revert is in
flight.***

**Half 2 — DONE (2026-11-19, stage window (1), claimed 05:26:26, released 05:33:04; run by the orchestrator as a
verification act from the throwaway detached checkout at `437696f06` — the recipe above, unchanged; three legs).**
- **Phone RED (the eight files at the seam commit `7c9fc0151`):** Swift Testing 84 tests in 16 suites FAILED, 52
  issues. Failed — exactly the 21 expected and no other: the 18 new pins
  (`finishWithArrivalsWaitingAsksWithTheCountAndDoesNotLock`, `cancellingTheConfirmLeavesTheBookAsItWas`,
  `theFinishCaptionSaysWhatFinishedMeans`, `finishIsNotDrawnOnAGathering`,
  `reopenOnASealedBookSpeaksTheSharedSentence`, `divergeIsNotDrawnOnAGatheringRow`,
  `anArchivedStarredBooksDetailsCarriesTheUnarchiveDoor`, `theShelfSortsAToZDigitAwareWithStarredFirst`,
  `theRowMenuOffersStarAndNoPin`, `theShelfRowCallsAGatheringAGathering`,
  `theDeleteDoorConfirmAndReceiptNameAGathering`, `theMembershipAndCreateSheetsSayGathering`,
  `theTrashNamesAnUntitledGatheringAGathering`, `noRenderedStringInTheseFacesSaysSmart`,
  `aStarOnlyCollectNamesTheStar`, `aTagAndStarCollectNamesBoth`, `anArchivedGatheringsReceiptSaysWhenItWillShow`,
  `pickersMarkAnArchivedBook`) and the 3 edited existing tests (`theIdentityBlockDisplaysTagsForBothKinds`,
  `lk5FacesLeadWithCountAndTags`, `walk7_shelfTodayLibraryColdLaunch`).
- **Phone GREEN (the tip, restored; `git diff HEAD` empty in the checkout):** 84 tests in 16 suites PASSED, 0
  failed, no known issue.
- **Mac leg (the 17 types that read a hoisted word, the dev-store Debug test host):** 110 tests in 17 suites
  PASSED, 0 failed — the Mac's words are unchanged through the hoists (batch B's `UndoWarningWordsTests` guard
  included; `DestructiveUndoWarningTests.redoNeverAsks`, an open red on the board as VX-608, passed here).
- Still owed: the walk rows (the gate's walk leg), and the Mac leg again on the merged tree at the gate.

| Piece | State | Pin (TYPE name for `-only-testing`) |
|---|---|---|
| The hoist (words) | DONE (`68f7e7eab`) — Mac `build` GREEN | the Mac's existing copy pins (Mac leg) |
| VM-21's hoist (the collect receipt family) | DONE (`4118af9b3`) — Mac `build` GREEN | the Mac's `GatheringCollectReceiptTests`, `GatheringCollectStarReceiptTests` (Mac leg) |
| Seams + pins (all three members) | DONE (`7c9fc0151` — the revert recipe's OLD) — phone `build-for-testing` GREEN; every pin compiles against this tree; red-on-old VERIFIED in window (1) | see the members' rows |
| VM-81 | DONE bar the walk — code: the Finish confirm (`aa4a8670f`), the rest (`081af74b0`), face polish (`5681d8304`); phone + Mac `build-for-testing` GREEN; red-on-old + green VERIFIED in window (1); walk **PENDING** | `MobileFinishConfirmTests`, `MobileBookStateRowTests`, `MobileArchivedStarredBookTests` (+ `MobileBookDetailsTests`) |
| VM-83 | DONE bar the walk — code (`0abaf3938`), face polish (`5681d8304`); phone + Mac `build-for-testing` GREEN; red-on-old + green VERIFIED in window (1); walk **PENDING** | `MobileShelfOrderTests`, `MobileShelfRowActsTests`, `MobileGatheringWordTests` (+ `MobileShellTests`, `MobileBookDetailsTests`, `MobileWalkTests`, `MobileDeletionTests`) |
| VM-21 | DONE bar the walk — code (`ea3b965af`); phone `build-for-testing` GREEN; red-on-old + green VERIFIED in window (1); walk **PENDING** | `MobileCollectReceiptTests` |

**Half 1 — DONE (2026-11-19):** the hoists, the seams + pins, and all three members' fixes committed and pushed. Phone
`build-for-testing` **TEST BUILD SUCCEEDED** — unsigned for `generic/platform=iOS Simulator` and then SIGNED for
`platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2` (no boot, no install) at the last commit, both into
`DerivedData/vm78-ios`; Mac `build-for-testing` (`DerivedData/vm78-mac`) **TEST BUILD SUCCEEDED** at `0abaf3938` (no
Mac file changed after it). No `xcodebuild test` run, no simulator booted, no walk. **Questions for her (the
orchestrator files them):** (1) an archived GATHERING's add row — wear "(archived)" on both platforms? (VM-21, below;
PROVISIONAL as built); (2) the wording pass: the create sheet's three gathering lines (VM-83's table), the sealed
Reopen's "…so it can't be reopened here." (VM-81), whether the phone keeps a collect receipt at all (VM-21). **One
platform difference to know (not this batch's surface):** the Mac chip still draws Diverge on gathering rows and
refuses (VM-81 · W-110 below).

**Half 2 — the stage window's recipe (a fresh session can run it from here):**
1. Write "REVERT IN FLIGHT — product files at the seam commit `7c9fc0151`; restore = `git checkout -- <the eight
   files>`" into this LIVE STATUS, commit + push, THEN revert (every fix is committed, so the restore is safe):
   `git checkout 7c9fc0151 -- App/Variorum/VariorumMobile/Features/Shell/MobileBookDetails.swift
   App/Variorum/VariorumMobile/Features/Write/MobileMembership.swift
   App/Variorum/VariorumMobile/Features/Shell/MobileShelfFaces.swift
   App/Variorum/VariorumMobile/Features/Shell/MobileShelfView.swift
   App/Variorum/VariorumMobile/Features/Shell/MobileShelfViewModel.swift
   App/Variorum/VariorumMobile/Features/Shell/MobileCreateBook.swift
   App/Variorum/VariorumMobile/Features/Shell/MobileTrashView.swift App/Variorum/Shared/ShelfOrder.swift`. (At
   `7c9fc0151` `MobileTrashView.swift` already carries batch B's VM-33 fix — only this batch's placeholder line reverts.
   `ShelfOrder.swift` reverts because the seam's `MobileShelfFaces.ordered` calls `ShelfOrder.ordered`. The Shared
   word files stay at HEAD — the seam files don't call the post-seam additions, `RecoveryCopy`'s overload and
   `BookStateCopy.unarchiveVerb`. The tests stay at HEAD: every symbol they call exists at the seam.)
2. RED run (the invocation below). **Expected RED, by name:** `finishWithArrivalsWaitingAsksWithTheCountAndDoesNotLock`,
   `cancellingTheConfirmLeavesTheBookAsItWas` · `theFinishCaptionSaysWhatFinishedMeans`, `finishIsNotDrawnOnAGathering`,
   `reopenOnASealedBookSpeaksTheSharedSentence`, `divergeIsNotDrawnOnAGatheringRow` ·
   `anArchivedStarredBooksDetailsCarriesTheUnarchiveDoor` · `theShelfSortsAToZDigitAwareWithStarredFirst` ·
   `theRowMenuOffersStarAndNoPin` · `theShelfRowCallsAGatheringAGathering`,
   `theDeleteDoorConfirmAndReceiptNameAGathering`, `theMembershipAndCreateSheetsSayGathering`,
   `theTrashNamesAnUntitledGatheringAGathering`, `noRenderedStringInTheseFacesSaysSmart` ·
   `aStarOnlyCollectNamesTheStar`, `aTagAndStarCollectNamesBoth`, `anArchivedGatheringsReceiptSaysWhenItWillShow`,
   `pickersMarkAnArchivedBook` · and the edited existing pins `MobileBookDetailsTests/theIdentityBlockDisplaysTagsForBothKinds`,
   `MobileShellTests/lk5FacesLeadWithCountAndTags`, `MobileWalkTests/walk7_shelfTodayLibraryColdLaunch` (each on its
   "gathering · #…" line). **Expected GREEN on both sides (controls/guards):** `finishWithNothingWaitingActsAtOnce`,
   `aLiveTagsOnlyCollectKeepsTheChipsWords`, `MobileShellTests/theShelfObservationDeliversBooksPinsAndTheDailyMark`,
   every `MobileDeletionTests` test (a book's delete words are unchanged), and every other pre-existing test in the
   listed types. A member whose pins go green on the seam is HOLLOW — record it, revert its fix, keep the pin.
3. `git checkout -- <the eight files>`; `git status` clean; record "no revert is in flight".
4. GREEN run (same invocation). Every test in the listed types green. Name the standing phone red
   (`MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`, batch C's) if it shows —
   it is not in this list.
5. The WALK (the gate is use): the dev-store Debug phone build on the booted simulator, one capture per row into the
   screens folder the orchestrator names — Book Details' Finish with notes waiting (the confirm, its count; Cancel
   leaves the book; Finish dismisses), Finish absent on a gathering's Details, a sealed book's Reopen sentence, the
   membership sheet on a note in a gathering (no diverge; the "gathering" mark; an archived book "(archived)" in the
   add list; a ★-rule collect's receipt), the shelf in a–z with a starred book first and a long-press menu without
   Pin, the create sheet's Gathering kind, a starred archived book opened from Starred → its Details with Unarchive →
   back on the shelf. Both voices where the face has one. **Added by round 1 (N9):** the tallest Book Details — an
   archived, journal-trait book with a rule, a refusal line showing — at the medium detent and at large (the fix
   pass's LIVE STATUS, below); and the pocket guide's "getting around" lesson as F4 reworded it.
6. Release the stage (sim shut down, no Variorum instance left), flip this table, report.

```zsh
ONLY=(
  -only-testing:VariorumMobileTests/MobileFinishConfirmTests
  -only-testing:VariorumMobileTests/MobileBookStateRowTests
  -only-testing:VariorumMobileTests/MobileArchivedStarredBookTests
  -only-testing:VariorumMobileTests/MobileShelfOrderTests
  -only-testing:VariorumMobileTests/MobileShelfRowActsTests
  -only-testing:VariorumMobileTests/MobileGatheringWordTests
  -only-testing:VariorumMobileTests/MobileCollectReceiptTests
  -only-testing:VariorumMobileTests/MobileBookDetailsTests
  -only-testing:VariorumMobileTests/MobileBookCreateTests
  -only-testing:VariorumMobileTests/MobileBookNameGuardTests
  -only-testing:VariorumMobileTests/MobileShellTests
  -only-testing:VariorumMobileTests/MobileWalkTests
  -only-testing:VariorumMobileTests/MobileDeletionTests
  -only-testing:VariorumMobileTests/MobileMembershipTests
  -only-testing:VariorumMobileTests/MobileFilterTests
  -only-testing:VariorumMobileTests/MobileTutorialLibraryWalkTests
)
xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'platform=iOS Simulator,id=<simulator-udid>' \
  -derivedDataPath App/Variorum/DerivedData/vm78-ios "${ONLY[@]}"
```
**The Mac leg** (the merge gate's, over the changed Shared files and the Mac files that now extend them; DerivedData
`vm78-mac`, already TEST BUILD SUCCEEDED): `BookStateDoorsTests`, `BookSettingsSheetTests`, `GatheringKindWordTests`,
`ArrivalsDoorPlacementTests`, `BookArrivalsTests`, `GatheringCollectReceiptTests`, `GatheringCollectStarReceiptTests`,
`VocabularySweepTests`, `BookArchiveDoorActTests`, `BookSettingsArchiveRowTests`, `ArchivedBooksGroupTests`,
`ShelfModelTests`, `TutorialBooksLessonTests`, `TutorialMCPChapterTests`, `GatheringRuleGateTests` — every Mac pin that
reads a moved word (`BookStateCopy.*`, `ArrivalsCopy.word`, the collect receipt family, `CollectingCopy`'s two
captions, `unarchiveVerb`).

**The seam commit (the "old" of the revert recipe).** Each pin needs a testable surface the fix then changes, so the
seam commit adds those surfaces with the SHIPPED behaviour, byte for byte, and wires the faces through them:
`MobileBookDetailsModel` — `finishRowAct(for:)` (always drawn: finish/reopen by `locked`), `finishCaption(for:)` (the
shipped two captions), `FinishConfirm` + `pendingFinish` + `requestFinish()` (acts at once, as shipped) +
`confirmFinish(_:)` / `cancelFinish()` / `finishConfirmPresented`, `offersUnarchive` + `unarchive()` (never drawn: an
archived book never resolved); `MobileMembershipModel` — `rowCarriesDiverge` (always true), `kindMark(for:)`
("smart"), `memberRowName(for:)`, `addRowLabel(for:)` (bare names); `MobileShelfFaces` — `deleteDoorTitle(for:)` /
`deleteConfirmTitle(for:)` (always the book's words) and `MobileShelfRowAct` (pin · star · archive/delete), with
`MobileShelfViewModel.rowActs(for:starred:)` and the row's `.contextMenu` rendering it in the shipped order;
`MobileCreateBookModel` — `kindLabel(_:)`, `caption(for:)`, `noTagsLine` (the shipped words). Pins:
`VariorumMobileTests/MobileBookFixesTests.swift`; the existing tests whose words change (`MobileBookDetailsTests`,
`MobileShellTests`, `MobileWalkTests`, `MobileDeletionTests`) were edited in the same commit to the new words / the
kind-aware seam functions, so they are pins too.

**What moved, and where (the hoist — words only; every Mac string byte-identical):**
- `App/Variorum/Shared/BookStateCopy.swift` (new) declares `enum BookStateCopy` with `finishVerb`, `reopenVerb`,
  `deleteVerb`, `deleteVerb(_:)`, `deleteDoorLabel(_:)`, `quoted(_:)`, `waitingLine(_:)`,
  `finishNeedsConfirm(pendingArrivals:)` — moved verbatim from the Mac's `Features/Readings/BookStateDoors.swift` —
  plus `finishTitle(_:)` (the finish confirm's title, which the Mac's `BookStateCopy.finish(…)` now composes from —
  same bytes), `finishedMeans` (the first sentence of the Mac's `CollectingCopy.finishedCaption`) and `sealedMeans`
  (the Mac's `CollectingCopy.sealedCaption`, whole). The Mac's `BookStateDoors.swift` now EXTENDS the enum
  (`nonisolated extension BookStateCopy`); `BookSettingsSheet.swift`'s `CollectingCopy.finishedCaption` is
  `BookStateCopy.finishedMeans + " A finished book opens as pure text."` and `sealedCaption` is
  `BookStateCopy.sealedMeans` (bytes unchanged). Not hoisted (per the brief): `BookStateConfirm`, the door sets,
  anything reaching the capability registry.
- `App/Variorum/Shared/ArrivalsCopy.swift` (new) declares `enum ArrivalsCopy` with `word` only (`waitingLine` needs
  it); the Mac's `Features/BookView/BookArrivals.swift` now extends it.
- `App/Variorum/Shared/CollectReceiptCopy.swift` (new, VM-21) declares `enum BookcaseCopy` with the collect/mint
  receipt family moved verbatim from the Mac's `Features/Shelf/ShelfViewModel.swift` (`shownByTagging`,
  `taggedWhileArchived`, `alreadyMatchesWhileArchived`, `shownByMint`, and their private `shownNowTail`,
  `shownAfterUnarchiveTail`, `wore`), and `enum AddToBookCopy` with `byTagging` and `collected(_:gatheringName:)`
  moved verbatim from the Mac's `Core/Views/MembershipChoice.swift` — the chip's receipt composer, which the phone's
  membership sheet (the chip's twin) now speaks. Both Mac files now extend the shared enums; the board's own
  `collectReceipt` / `alreadyShowing`, the shelf verbs and the chip's other words stay Mac-side.

**Traced mechanisms and what changed (read in this session before any code; file:line at the fix commits):**
- **VM-81 · W-105 (the Finish confirm).** `MobileBookDetailsSheet.finishRow` called `setFinished(true)` →
  `lockReading`, whose `finishReadingRows` runs `dismissPendingArrivals` in the same transaction (AppSpec §9), so a
  Finish pressed while notes waited at Arrivals tombstoned them unseen. Fix (`MobileBookDetails.swift`
  `requestFinish()`): read the book and `Queries.pendingArrivalCount` (the dismissal's own predicate,
  `pendingArrivalRowsWhere` — never a second definition) fresh; `BookStateCopy.finishNeedsConfirm` → set
  `pendingFinish` (`FinishConfirm`: title `BookStateCopy.finishTitle(name)`, line `BookStateCopy.waitingLine(N)`)
  and act nothing; else act at once. The sheet hosts `.alert(…, presenting: model.pendingFinish)` with Finish
  (`BookStateCopy.finishVerb`) and Cancel; `confirmFinish(_:)` takes the confirm as a parameter (the shelf delete's
  rule). "Open Arrivals first" is NOT built (VM-175, wave 4).
- **VM-81 · W-106 (the caption).** "a finished book reads ✓ and freezes its notes" / "finished — its notes and order
  are frozen" — false: a finished book's text stays editable. `finishCaption(for:)` = `BookStateCopy.finishedMeans`
  (the Mac's settings caption, its first sentence — the second, "A finished book opens as pure text.", is the Mac's
  own and false on the phone, which opens a book to its contents) on an open or finished book;
  `BookStateCopy.sealedMeans` (the Mac's sealed caption) on a sealed one, where "the writing inside can still change"
  would be false. Not PROVISIONAL: both are the Mac's sentences.
- **VM-81 · W-106 (Finish on gatherings).** The row drew Finish on every reading; `lockReading` refuses a gathering
  `wrongReadingKind` (a raw dump on the phone). `finishRowAct(for:)` reads the Mac's `BookStateDoorSet` finish pair:
  a gathering draws nothing, unless ALREADY finished (legacy) — then Reopen alone, its way out. A sealed BOOK keeps
  Reopen (the brief). This is a phone-side reading of the Mac's table until W-070/W-112 hoist the door sets — the one
  small fork this batch carries, named so it is retired then.
- **VM-81 · W-106 (Reopen on a sealed book).** `unlockReading` → `reopenReadingRows` refuses `readingSealed`;
  `MobileBookDetailsModel.refusal` sent every non-name refusal to `DeletionRefusal.words`, which has no arm for it, so
  she read "That couldn't be done — readingSealed(id: …)." Fix: that ONE arm routes through
  `OpsRefusalCopy.words(for:roads: .phone)` → "This book is sealed, so it can't be reopened here." (the phone's roads
  name no Unseal door). **For her wording pass (not reworded — shared copy):** the sentence names no door the phone
  lacks, but "here" quietly implies somewhere else can; the phone's Unseal arrives with VM-161 (wave 4), when the
  roads' `bookSeal.verb` fills and the sentence becomes "…— unseal it to reopen it."
- **VM-81 · W-110 (Diverge on gathering rows).** `MobileMembershipSheet.membershipSection` drew "diverge" on every
  row; `divergePostForReading` refuses a gathering. `rowCarriesDiverge(_:)` = book rows only. **Noted:** the Mac's
  chip still draws it on gathering rows and refuses (its 13f W23 comment: "silence where the row looks actionable is
  the confusion"); the catch-up plan's W-110 rules the phone's, so the two platforms now differ here — a line for the
  orchestrator (the Mac side is not this batch's surface).
- **VM-81 · W-120 (the starred archived book).** `MobileBookDetailsModel.refresh` resolved the book from
  `Queries.bookshelf`, whose `bookcaseReadings` drops `archived_at IS NOT NULL`; `Queries.starred` keeps archived
  readings and archiving never unstars, so Starred → the book → Details showed an empty sheet with no way back. Fix:
  `archivedBook(_:id:absentFrom:)` resolves the live archived reading when the shelf does not hold it (counts for that
  one book: `liveMemberNoteCount`, `readingSections`); `nameLine` wears the shared mark (`BookArchiveCopy.name` —
  "Old projects (archived)"); `offersUnarchive` draws an Unarchive row (`BookStateCopy.unarchiveVerb`, hoisted from
  the Mac's extension in this commit; the visible pause beside it when `BookArchiveCopy.pausedSentence` has one) above
  Delete (the Mac's archived rows: Unarchive + Delete; the daily Journal keeps no Delete on the phone). `unarchive()`
  runs `unarchiveReading`; no receipt (no line for an ordinary act — the sheet itself changes).

- **VM-83 · W-068 (the order — her ruling, below).** `MobileShelfViewModel.orderedBooks` →
  `MobileShelfFaces.ordered` → the retired `Shared/ShelfOrder.ordered`: pins (the starred readings, by name), then
  journal-trait books, then the rest by case-sensitive `<` — so "Zebra" before "apple", "Book 10" before "Book 2", and
  journal books a group of their own. Fix: `orderedBooks` = `BookcaseBoard.ordered(books, mode: .alphabetical,
  lastEdited: [:])` — the Mac Bookcase's rule (starred float first, by `ShelfBook.starred`, the union star; then
  `BookcaseOrdering.nameAscending`, `localizedStandardCompare`). The Library's book rows read the same order. No order
  door (her ruling: wave 3, VM-113). `ShelfOrder.ordered` and `MobileShelfFaces.ordered` deleted with their one pin
  (`MobileShellTests.shelfOrderPutsPinsFirstThenJournalsThenName`); `ShelfOrder.swift` stays for
  `smartQueryTagPaths` (both platforms call it). The Mac test `ShelfModelTests`'s doc comment that named the phone's
  rule is corrected (comment only).
- **VM-83 · W-071 (one star door).** The row's menu offered "Pin to Shelf Top" (`setPinned` → `setShelfPinned`, which
  since 13i-d IS `setStarred`) beside Star — two doors, one truth, so Pin flipped Star's label. Fix: the menu is the
  act table `MobileShelfViewModel.rowActs(for:starred:)` → Star/Unstar, then Delete (Archive on the daily Journal);
  `MobileShelfRowAct.pin`, `MobileShelfFaces.pinDoorTitle`, `setPinned`, and the model's `pins` list (and its
  `shelfPins` read in the held observation — the listing's `ShelfBook.starred` already carries the union star) are
  gone. `MobileBookPinTests` (pinned the retired door) is deleted; `MobileShellTests`' observation test now reads the
  star from the listing. The tutorial seeder's own `setShelfPinned` CALL (the core op, = star) is untouched (wave 6).
- **VM-83 · W-073 ("gathering", never "smart").** Sites changed: the shelf meta (`MobileShelfFaces.meta` — "gathering",
  the Mac shelf row's word, via `MobileShelfFaces.gatheringWord`); the delete door, confirm and receipt
  (`deleteDoorTitle(for:)` / `deleteConfirmTitle(for:)` = the hoisted `BookStateCopy.deleteDoorLabel(_:)` /
  `deleteVerb(_:)`, on the shelf row AND Book Details; the receipt via a new Shared overload
  `RecoveryCopy.movedToTrashReceipt(_:isGathering:)`, which reads `rowKind(_:isGathering:)` — every other kind
  byte-identical); the membership sheet's row mark (`kindMark(for:)`); the create sheet (`kindLabel`, `caption`,
  `noTagsLine`); the Trash's empty-name placeholder (`MobileTrashView.rowTitle` → `rowKind(_:isGathering:)`, a line
  away from batch B's VM-33 change, untouched). **The create sheet's words — DRAFTS for her wording pass:**

  | | Old | New (draft) |
  |---|---|---|
  | kind door | Smart Book | Gathering *(the Mac's kind word — its "Create Gathering…")* |
  | caption | A smart book collects notes by these tags — the tags stay on the notes. | A gathering shows every note these tags match and holds none of them — the tags stay on the notes. *(from the Mac's `newBookMessage`: "a gathering shows every note its rule matches and holds none of them")* |
  | no tags | No tags yet — notes get tags first; a smart book collects by them. | No tags yet — notes get tags first; a gathering shows the notes that match them. |

  **Seen, NOT changed (other umbrellas own them):** the Today door's `.wrongKind` note ("…is a smart book…",
  `MobileTodayDoor.swift`) — VM-85 (W-107, umbrella 5); the pocket guide's "a smart book collecting by…"
  (`MobileTutorialSeeder.swift`) — VM-212 (wave 6); the create sheet's "Create Book" button on the gathering kind
  (not "smart"; the Mac's sheet has a separate "Create Gathering…" — the new-book sheet is VM-112's, wave 3); the
  Starred page's "book" kind word on a gathering row (wave 2's Starred page); the delete confirm's detail "Its notes
  stay in the library." on a gathering (true, if odd — the Mac's gathering confirm says "No note is touched: a
  gathering holds none."; a wording-pass line).

- **VM-21 · F4 (the collect receipt — her ruling, below).** `MobileMembershipModel.collect(into:)` composed its own
  receipt: "Added by tagging ‹paths› — “X” collects by filter." on every non-matched collect — so a ★-only collect
  read "Added by tagging  — …" (no star named, an empty tag list), a tag+★ collect never named the star, and on an
  ARCHIVED gathering (which assembles empty everywhere, 13i-e) it claimed the gathering shows the note. Fix: the
  status is `AddToBookCopy.collected(result, gatheringName:)` — the Mac chip's composer, hoisted (`4118af9b3`); the
  op's own `SmartCollectResult.starred` / `.gatheringArchived` decide. Arms: "Starred — the gathering shows it now." ·
  "Tagged #x and starred — the gathering shows it now." · "Tagged #x — the gathering shows it once it's unarchived."
  (and "It already matches — …once it's unarchived."); a live tags-only collect and an already-matching one keep the
  chip's shipped words (the controls). **On her wording-pass list:** whether the phone keeps a collect line at all.
- **VM-21 · F5 (the "(archived)" marks).** The add list is `Queries.readings` (archived books included — explicit adds
  stay open) and named them bare; the membership rows too. Fix: `addRowLabel(for:)` = `BookArchiveCopy.name(reading)`
  (+ " (by tagging)" — `AddToBookCopy.byTagging`, hoisted — on a gathering); `memberRowName(for:)` =
  `BookArchiveCopy.name(MobileShelfFaces.name(for:), archived:)` ("Old projects ✓ (archived)"). **PROVISIONAL —
  an archived GATHERING's add row:** (a) mark it too, "Quotes (archived) (by tagging)" — BUILT: SurfaceContracts says
  "The pickers, chips and Book Panel mark '(archived)'" without a kind exception, and the collect receipt's archived
  arm then has a mark to agree with; (b) the Mac chip's picker exactly — gatherings carry only "by tagging", unmarked;
  (c) list no archived gathering in the add list at all (not the contract: explicit adds stay open). Question for her
  (the orchestrator files it): does an archived gathering's add row wear "(archived)" on both platforms?

**Her rulings on this batch's two forks (2026-11-19, in the orchestrator's session; relayed by the orchestrator) —
RULED, not PROVISIONAL. Her words, verbatim:** "book order - that's fine to leave it for wave 3. 2 - collect receipt
your choice is fine."
1. **The shelf's order** becomes a–z, digit-aware, starred first (`BookcaseBoard.ordered(…, mode: .alphabetical)`);
   the visible "a–z or last edited" choice is left to the Bookcase's real chrome in wave 3 (VM-113). No order door
   is built here.
2. **The collect receipt** is kept and made true (it names the star; it is honest when the gathering is archived).
   "Should this line exist at all" still goes on the list for her wording pass.

#### Round 1 fix pass — LIVE STATUS (batches A and B's findings: F3, F4, F5, F8, N1–N4, N6–N11)

*Implementer: a fresh `opus-implementer` (2026-11-19), taking over batches A and B's round-1 findings; the final calls
are `vm-78-ladder-round1.md` "Final calls" (`90610aa92`). Headless only: code, pins, `build-for-testing` on both
targets, and a build of the RED tree; the fix-pin window is the orchestrator's, from its own checkout. **No revert is
in flight** (the red-tree build's revert, `8ea7f4e52`, was restored with `git checkout HEAD --`; `git status` clean).
The pre-fix-pass tip ("old" for this window) is `0180727de`.*

**The fix-pin window — RUN (2026-11-19, stage window (5), claimed 06:26:55, released 06:31:48; by the orchestrator
from the throwaway detached checkout at `140869902`, the four product files at `0180727de` for the red leg):**
- **RED:** Swift Testing 75 tests in 10 suites FAILED, 9 issues including 2 known. Failed — four, and no other:
  `aRacedUnarchiveSpeaksTheSharedSentence` (F3) · `theTrashNamesAnUntitledSavedVersionAsOne` (N2) ·
  `theFinishRowsConfirmPresentsAndItsFinishActs` and `theFinishRowsConfirmCancelChangesNothing` (F5's guards —
  red only because the reverted Finish row has no label for the driver to find).
- **GREEN (the tip, restored; `git diff HEAD` empty):** 75 tests in 10 suites PASSED with 2 known issues (the
  designed `MobileTrashTests` diagnostic, on both sides); 0 failed. The cancel pin, the write-back assertion and
  N1's guard were green on both sides, as designed.
- **F4's pin DID NOT RUN in this window.** The recipe named the wrong type for it:
  `theShelfLessonDescribesTheShelfThatExists` lives in `MobilePocketGuideDeletionTests`, not
  `MobileTutorialLibraryWalkTests`. (The wrong name came from round 1's own text, and this pass carried it without
  checking the struct; the two fix-pass commit messages keep it as history.) The follow-up below proved it.
- **Bundles (R2-F1's call):** the RED leg's bundle `App/Variorum/DerivedData/vm78-bundles/fixpass-red.xcresult` is
  **UNREADABLE** — its `xcodebuild` was stopped 40 s after the verdict line, before it had finalized the bundle (no
  `Info.plist`). Its evidence is the kept log `App/Variorum/DerivedData/logs/vm78-window-f-red.log` (75 tests in 10
  suites failed, 9 issues including 2 known, the four reds above and no other; the log also prints the old Finish
  row's joined label, R2-N1's premise). The GREEN bundle `fixpass-green.xcresult` **reads** (75 tests: 74 passed,
  1 expected failure, 0 failed). From here on (R2-F1): up to 90 s of grace for `xcodebuild` to exit after its
  verdict; `xcrun xcresulttool get test-results summary --path <bundle>` afterwards; "reads" or "unreadable — the
  log is the evidence" beside each run; the log kept whatever the bundle does.

**F4's follow-up window — RUN (2026-11-19, 06:52–06:54, by the orchestrator; one type):**
- **RED** (only `MobileTutorialSeeder.swift` at `0180727de`): 4 tests in 1 suite, FAILED —
  `theShelfLessonDescribesTheShelfThatExists` ran and failed with 3 issues (the three expectations F4 added), no
  other red. Bundle `f4-red.xcresult` reads; log `App/Variorum/DerivedData/logs/vm78-window-f4-red.log`.
- **GREEN** (the tip, restored): 4 tests in 1 suite PASSED. Bundle `f4-green.xcresult` reads; log
  `App/Variorum/DerivedData/logs/vm78-window-f4-green.log`.
- **F4 is VERIFIED: red on the pre-fix-pass seeder, green on the tip.**

**Headless — DONE (2026-11-19):** pins and guards `72fa54dc8`; VM-81's fixes `326d61da4`; VM-83's fixes `36ace0aa5`.
- Phone `build-for-testing` (signed, `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`, no boot, DerivedData
  `vm78-ios`) **TEST BUILD SUCCEEDED** at `36ace0aa5`'s code (and at `72fa54dc8` — the pins against the pre-fix
  product).
- Mac `build-for-testing` (DerivedData `vm78-mac`) **TEST BUILD SUCCEEDED** at `36ace0aa5` (the pass touches one
  `Shared/` comment and moves no string).
- **The RED tree builds:** the four product files below reverted to `0180727de`, the tests at `36ace0aa5`, phone
  `build-for-testing` into a separate DerivedData `vm78-ios-red` (so the tip's products stay warm): **TEST BUILD
  SUCCEEDED**; then restored.
- No `xcodebuild test`, no simulator, no walk.

| Finding | State | Pin (TYPE / test) |
|---|---|---|
| F3 (VM-81) | DONE — pin `72fa54dc8`, fix in the VM-81 fix commit after it; red on the pre-fix-pass tip and green VERIFIED in window (5) | `MobileArchivedStarredBookTests/aRacedUnarchiveSpeaksTheSharedSentence` |
| F4 (VM-83) | DONE — pin `72fa54dc8` (+ the neighbouring test's message reworded), fix in the VM-83 fix commit (the lesson's first sentence, the dangling "also"; a DRAFT for her wording pass, below); `build-for-testing` GREEN; red on the pre-fix-pass seeder and green VERIFIED in the follow-up window (06:52–06:54; it did not run in window (5) — the type was misnamed) | `MobilePocketGuideDeletionTests/theShelfLessonDescribesTheShelfThatExists` |
| F5 (VM-81) | DONE — tests `72fa54dc8` (the cancel pin re-pointed to the binding, the write-back assertion, two hosted guards), fix in the VM-81 fix commit (the row's label, `cancelFinish()` deleted); `build-for-testing` GREEN; the window's lines VERIFIED in window (5) (the two guards red for the missing label only, green on the tip; the cancel pin and the write-back assertion green on both sides) | `MobileFinishConfirmTests` |
| F8 (VM-81) | no code — the question below, for the orchestrator to file at the merge | — |
| N1 (VM-83) | DONE — guard `72fa54dc8` (green on both sides by design); green on both sides in window (5) | `MobileShelfOrderTests/aStarTakenWithTheShelfOpenReordersIt` |
| N2 (VM-83) | DONE — pin `72fa54dc8`, fix in the VM-83 fix commit (`rowTitle` reads `RecoveryCopy.rowKind(item)`); red on the pre-fix-pass tip and green VERIFIED in window (5) | `MobileGatheringWordTests/theTrashNamesAnUntitledSavedVersionAsOne` |
| N3 (VM-81) | DONE — the test's `pendingArrivals` assertion removed `72fa54dc8`; the field gone and `confirmFinish` acting on `confirm.readingID` in the VM-81 fix commit | (the existing `MobileFinishConfirmTests`) |
| N4 (VM-83) | DONE in part — test renamed `72fa54dc8`; the `Shared/BookcaseBoard.swift` comment in the VM-83 fix commit (Mac `build-for-testing` GREEN); the core doc line left (owner line below) | `MobileShellTests/theShelfObservationDeliversBooksStarsAndTheDailyMark` |
| N6 | WITHDRAWN — one line for VM-113's kickoff (below) | — |
| N7 (VM-83) | DONE in part — the sweep test's doc says what it is (`72fa54dc8`); the source scan comes with VM-212 (below) | — |
| N8 (VM-81) | DONE — comment only, in the VM-81 fix commit | — |
| N9 | a walk row (below) | — |
| N10 | a ticket line for the orchestrator (below) | — |
| N11 | the window's two bundles (the recipe below); batch B's lost RED bundle recorded as lost | — |

**The fix-pin window — the recipe (the orchestrator runs it from its own checkout at the fix pass's tip, as for
batches A and B).**
1. "Old" is the PRE-FIX-PASS TIP, literally: only the product files this pass changed, reverted to `0180727de`; the
   tests stay at the tip (the red tree's build is proven above):
   ```zsh
   git checkout 0180727de -- \
     App/Variorum/VariorumMobile/Features/Shell/MobileBookDetails.swift \
     App/Variorum/VariorumMobile/Features/Tutorial/MobileTutorialSeeder.swift \
     App/Variorum/VariorumMobile/Features/Shell/MobileTrashView.swift \
     App/Variorum/Shared/BookcaseBoard.swift
   ```
   Restore with `git checkout HEAD -- <the same four files>` (the old versions are staged by the checkout) and confirm
   `git status` clean before the GREEN run.
2. The types (the reviewer's ten) and the two runs, each keeping its result bundle (N11; the bundle path must not
   exist beforehand; `App/Variorum/DerivedData/` is gitignored). **This `ONLY` array is AS RUN IN WINDOW (5), left as
   it ran:** it lists `MobileTutorialLibraryWalkTests` (the reworded neighbouring message) but not
   `MobilePocketGuideDeletionTests`, where F4's pin lives, so F4's pin did not run there (R2-N2). The follow-up's
   one-type leg, which did run it, is beside it below. **A full re-run of this recipe carries BOTH
   `MobileTutorialLibraryWalkTests` and `MobilePocketGuideDeletionTests`** (eleven types).
   ```zsh
   ONLY=(
     -only-testing:VariorumMobileTests/MobileFinishConfirmTests
     -only-testing:VariorumMobileTests/MobileArchivedStarredBookTests
     -only-testing:VariorumMobileTests/MobileBookStateRowTests
     -only-testing:VariorumMobileTests/MobileShelfOrderTests
     -only-testing:VariorumMobileTests/MobileGatheringWordTests
     -only-testing:VariorumMobileTests/MobileTutorialLibraryWalkTests
     -only-testing:VariorumMobileTests/MobileShellTests
     -only-testing:VariorumMobileTests/MobileBookDetailsTests
     -only-testing:VariorumMobileTests/MobileDeletionTests
     -only-testing:VariorumMobileTests/MobileTrashTests
   )
   # RED — the four files at 0180727de
   xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile \
     -destination 'platform=iOS Simulator,id=<simulator-udid>' \
     -derivedDataPath App/Variorum/DerivedData/vm78-ios-red \
     -resultBundlePath App/Variorum/DerivedData/vm78-bundles/fixpass-red.xcresult "${ONLY[@]}"
   # GREEN — the tip, restored
   xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile \
     -destination 'platform=iOS Simulator,id=<simulator-udid>' \
     -derivedDataPath App/Variorum/DerivedData/vm78-ios \
     -resultBundlePath App/Variorum/DerivedData/vm78-bundles/fixpass-green.xcresult "${ONLY[@]}"
   ```
   (The DerivedData paths are this worktree's; a separate checkout uses its own, as window (1) did.)
   **The follow-up's one-type leg (as run 06:52–06:54; results above):**
   ```zsh
   # RED — only the seeder at 0180727de
   git checkout 0180727de -- App/Variorum/VariorumMobile/Features/Tutorial/MobileTutorialSeeder.swift
   xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile \
     -destination 'platform=iOS Simulator,id=<simulator-udid>' \
     -derivedDataPath App/Variorum/DerivedData/vm78-ios-red \
     -resultBundlePath App/Variorum/DerivedData/vm78-bundles/f4-red.xcresult \
     -only-testing:VariorumMobileTests/MobilePocketGuideDeletionTests
   # GREEN — git checkout HEAD -- <the seeder>; git status clean; the same type, f4-green.xcresult, DerivedData vm78-ios
   ```
3. **Expected RED on the reverted product, by name and reason — five, and no other:**
   - `MobileArchivedStarredBookTests/aRacedUnarchiveSpeaksTheSharedSentence` — F3: `lastError` is the raw fallback
     ("That couldn't be done — readingNotArchived(…).").
   - `MobilePocketGuideDeletionTests/theShelfLessonDescribesTheShelfThatExists` — F4: the old lesson (the new first
     sentence absent, "pins or unpins" present, "A long press also STARS").
   - `MobileGatheringWordTests/theTrashNamesAnUntitledSavedVersionAsOne` — N2: "(empty note)".
   - `MobileFinishConfirmTests/theFinishRowsConfirmPresentsAndItsFinishActs` and
     `MobileFinishConfirmTests/theFinishRowsConfirmCancelChangesNothing` — F5's two hosted GUARDS, red **because the
     reverted Finish row has no accessibility label for the driver to find** (`surface.activate("Finish")` returns
     false, so no alert is presented to read). This is NOT "the confirm was broken": both are guards, green on the
     tip by design.
4. **Expected GREEN on both sides:** `MobileFinishConfirmTests/cancellingTheConfirmLeavesTheBookAsItWas` (now drives
   the binding), `MobileFinishConfirmTests/aConfirmWhoseBindingWasWrittenBackFirstStillFinishes` (the write-back
   assertion), `MobileShelfOrderTests/aStarTakenWithTheShelfOpenReordersIt` (N1's guard),
   `MobileShellTests/theShelfObservationDeliversBooksStarsAndTheDailyMark` (renamed, N4), and every other test in the
   ten types. `MobileTrashTests` carries its DESIGNED known issue
   (`anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`) on both sides. Anything else red is a finding.
5. GREEN: every test in the ten types passes. Release the stage, record both verdict lines and the bundles' paths
   here.

**F4 — the lesson's words, a DRAFT for her wording pass** (the "getting around" lesson, block 1; only the changed
sentences):

| | Old (false since VM-83 retired the Pin door) | New (draft) |
|---|---|---|
| first sentence | The SHELF is home: your books at the top, with this one pinned first — pinned books always sit first, and a long press on a book row pins or unpins it. | The SHELF is home: your books at the top, starred books first — this one is starred. |
| the star door | A long press also STARS a note or a book — starred things sit above everything at the shelf's very top, and the same press takes the star back off. | A long press STARS a note or a book — starred things sit above everything at the shelf's very top, and the same press takes the star back off. |

("this one starred first" was not promised: starred books sort a–z among themselves, and a starred Journal can
lead.) **Named for VM-212 (wave 6), not changed here:** in the same paragraph, "starred things sit above everything
at the shelf's very top" — false for notes since the starred list moved to its own page (an earlier round's batch
10); the paragraph's "a smart book collecting by tags" (already on VM-212's list); the seeder's cleanup comment
about "the shelf-pins setting" (`MobileTutorialSeeder.cleanup`). The neighbouring test
(`theShelfShowsThePinnedGuideFirstWithItsFaces`) had its message and comments reworded to "starred"; its function
name is kept (the final call named the message).

**F8 — the question, for the orchestrator to file in `notes/QUESTIONS.md` at the merge (PROVISIONAL as built: the
phone draws none):** "Diverge on a gathering's row in a note's books list. The Mac's chip draws 'diverge' on every
row and a gathering refuses with the tag road (13f W23; `MembershipChip.swift:136-145`; its comment's 'her ruled
shape' is the 13f orchestrator's batch-5 adjudication — `notes/plans/phase-13f-workspace.md`, 'the orchestrator's
adjudication — batch 5 CLOSES' — which endorsed the refusal's sentence and, for the W22 offer, P-2's 'never offer an
act that could only refuse'; no words of hers were found for either reading). The phone since VM-81 (W-110, 'a
door drawn where it can't act') draws none. Options: (a) neither draws it — the Mac follows in a VX ticket (Books,
Low); (b) both draw it and refuse with the road — the phone reverts W-110; (c) keep the difference as a recorded
compromise (MobileSoul §3). PROVISIONAL as built: the phone's (a)."

**Lines for other owners (the orchestrator places them):**
- **F3, for vm-55's run (VM-62):** `MobileBookDetailsModel.refusal` now forwards `.readingSealed` and
  `.readingNotArchived` to `OpsRefusalCopy.words(for:roads: .phone)`; VM-62's sweep collapses the rest onto the
  table — expect a textual conflict at that function. **And (ladder round 2, R2-N4):** "Book Details' act rows
  (Unarchive here; Finish, Reopen and Archive share the shape) start one task per press with no in-flight latch. A
  double press on Unarchive that lands before the first press's re-read meets `readingNotArchived` and shows 'That
  book isn't archived any more — nothing changed.' under the book the first press did unarchive. Only Unarchive's
  second press is visible today — a second Finish or Reopen repeats an operation that is safe to repeat, and Archive
  dismisses its sheet. When the sweep moves `MobileBookDetailsModel.refusal` and its rows onto the message seam,
  give the rows an in-flight latch (the undo door's `inFlight`), so the sentence stays for the real race — the book
  unarchived elsewhere while the sheet is open."
- **R2-N1's neighbour, for the orchestrator to place (no id invented; nothing changed here):** "Book Details' name
  row carries `.accessibilityLabel(\"Rename Book\")` (`MobileBookDetails.swift`, `identityBlock`, from before this
  run), which replaces the book's name for VoiceOver — the sheet's one place the name is shown is not spoken." For
  the owner of the phone's VoiceOver pass.
- **N4, an owner for the core doc line** (this run opens no `Sources/` line): "core `Queries.bookshelf`'s doc
  (`Sources/VariorumCore/Queries/ShelfQueries.swift:43-44`) still says pin/journal ordering is the view model's call
  over `shelfPins`; the phone orders by `BookcaseBoard` since VM-83." — a line on the standing sweep ticket, or the
  next core touch.
- **N6 (withdrawn), for VM-113's kickoff:** `MobileShelfViewModel.orderedBooks` is a computed sort
  (`localizedStandardCompare`) read several times per shelf and Library body — ∝ the books, P1 holds; when the order
  becomes a live choice there, decide whether to sort once where the observation delivers.
- **N7, for VM-212 (the later of the last two phone "smart" sites; VM-85 holds the other):** once both sites are
  gone, adopt the Mac's source-scanning ban (`DeadVocabularyTests`) for the phone in place of
  `noRenderedStringInTheseFacesSaysSmart`'s hand-kept list.
- **N10, a ticket line (no id invented):** "Bug · Suspected · Low — the Archive room and a book's contents may paint
  their empty line before the first listing lands (VM-33's class). `MobileArchiveView.swift:74` draws 'Nothing
  archived.' on `model.visible.isEmpty` (`MobileArchiveModel.archived` starts `[]`, no answered flag);
  `MobileBookView.swift:100` draws 'No notes in this book yet.' on `model.entries.isEmpty`
  (`MobileBookViewModel.entries` starts `[]`); both are filled by a `.task` after the first render. Check first with
  VM-33's pin shape (`MobileTrashTests.theFirstPaintSaysNothingBeforeTheListingAnswers`); the fix is VM-33's
  answered gate." Owner: wave 2's room work (the Archived room, W-117).
- **N11:** batch B's RED result bundle was not kept — its reds are attested by the verdict line above and the round-1
  reviewer's per-pin reading. From this window on, both bundles are kept until the run closes.

**N9 — a walk row (added to batch A's walk, step 5):** the tallest Book Details — an ARCHIVED, journal-trait book
with a rule (so Finish with its three-line caption, the daily row, Unarchive with its pause sentence, and Delete),
with a refusal line showing — captured at the MEDIUM detent and at LARGE (the sheet offers both). A clipped medium
detent is reported with its capture, not fixed unasked. (The phone's fonts are fixed sizes today; if VM-47 raises
them, re-take this row on the merged tree.)

##### Round 2 — the fix pass's rows (ladder round 2's final calls, `vm-78-ladder-round2.md`, `874da32d8`)

*The same implementer, headless. **No revert is in flight.** "Old" for R2-N1's window is `046a886fc`, the commit
before the pin (`MobileBookDetails.swift` is byte-identical there and at the pin commit).*

| Finding | State | Pin (TYPE / test) |
|---|---|---|
| R2-N1 (VM-81) | DONE — pin `01205f799`, fix `97282e72f` (the four act rows on `MobileBookDetailsSheet` keep the verb as their label and carry the caption they draw as `.accessibilityHint`, unvoiced: Finish/Reopen `finishCaption(for:)` · Unarchive `pausedSentence(for:)` when it has one, else none · Archive `archiveDailyJournalDetail` · Delete `deleteBookKeepsItsNotes`; no new words); phone `build-for-testing` GREEN; red/green **PENDING** (it rides the next short window) | `MobileBookStateRowTests/theBookDetailsRowsSpeakTheirCaptionsAsHints` |
| R2-N2 | DONE — the recipe's `ONLY` array marked "as run in window (5)", the follow-up's leg and results beside it, the re-run line; F4's row flipped to VERIFIED; R2-F1's bundle lines landed here (the orchestrator's call) | — |
| R2-N4 | DONE — no code; the line for VM-62's run, with the reviewer's clause, under "Lines for other owners" | — |

**R2-N1's window (one short leg pair, riding the next window this run owes):**
- RED: revert ONE product file — `git checkout 046a886fc -- App/Variorum/VariorumMobile/Features/Shell/MobileBookDetails.swift`
  — tests at the tip; restore with `git checkout HEAD -- <that file>` and confirm `git status` clean before GREEN.
  The red tree compiles by construction: the pin calls only symbols that exist at `046a886fc` (the fix adds the
  modifiers and a file-private helper the test never names); the orchestrator builds it in its own checkout.
- Types: `MobileBookStateRowTests` (the pin), plus `MobileFinishConfirmTests` so the final call's "F5's two guards
  stay green" is SEEN with the hints on the same rows (the call named one type; the second costs two hosted mounts).
  ```zsh
  ONLY=(
    -only-testing:VariorumMobileTests/MobileBookStateRowTests
    -only-testing:VariorumMobileTests/MobileFinishConfirmTests
  )
  ```
  Bundles under `App/Variorum/DerivedData/vm78-bundles/` (`r2n1-red.xcresult`, `r2n1-green.xcresult`), logs under
  `App/Variorum/DerivedData/logs/`, R2-F1's grace and `xcresulttool` read beside each.
- **Expected RED, one and no other:** `MobileBookStateRowTests/theBookDetailsRowsSpeakTheirCaptionsAsHints` — every
  hint is nil on the old rows (the `#require`s by label pass; the four hint expectations fail).
- **Expected GREEN on both sides:** the rest of `MobileBookStateRowTests` (`theFinishCaptionSaysWhatFinishedMeans`,
  `finishIsNotDrawnOnAGathering`, `reopenOnASealedBookSpeaksTheSharedSentence`, `divergeIsNotDrawnOnAGatheringRow`)
  and every `MobileFinishConfirmTests` test, F5's two hosted guards included (the labels are unchanged; a hint does
  not move a label).
- **The final call's rule after the window:** if the fixed tip still reads nil for every row, the driver cannot see
  a SwiftUI hint and the fix is unproved — the modifiers and the pin then come out by a NEW commit, and the finding
  leaves as a line for the owner of the phone's VoiceOver pass, with the run's evidence (the old Finish row's joined
  label in `vm78-window-f-red.log`). That decision is made after the window, not before.

**Headless — DONE (2026-11-19):** phone `build-for-testing` (signed, `platform=iOS Simulator,name=iPhone 17
Pro,OS=26.2`, no boot, DerivedData `vm78-ios`) **TEST BUILD SUCCEEDED** at `97282e72f`'s code; log
`App/Variorum/DerivedData/logs/vm78-fixpass-r2n1-build.log`. No Mac build: the R2-N1 fix touches one phone file
and no `Shared/` or Mac file. No `xcodebuild test`, no simulator.

### BATCH C — the probe and the red test (VM-17 · VM-24, which carries VM-19) — EDITOR SEAM, test and badge code

Both are trace-first members; a hollow result closes its ticket honestly. This batch is stage-bound from its
first run, so its first half is reading and writing the probes headless; window (3) runs them.

- **VM-24 (+ VM-19) — the standing phone red.**
  `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` is red on the pinned
  simulator, red alone, red since before VM-8 (`fd56f2279`). Cause untraced: simulator keyboard state, or
  VM-19's class (a stale first responder left in a hidden window — `MobileLivenessTests` leaves one — desyncs
  the editor on `insertText`; the caret suite keys its own window since VX-282's C-1). **Trace before fixing:**
  read the test and the input road it drives; in window (3) run it alone, with the suite, after
  `MobileLivenessTests`, and with instrumentation that names where the surface and the model first disagree.
  Then one of: a PRODUCT mechanism (fix it, the test is its pin — editor seam, the Fable reviewer reads it) · a
  TEST-POSTURE mechanism (fix the posture so the test asserts what it means; show the same assertion still goes
  red when the product rule it guards is broken by hand) · untraceable in the window (record exactly what was
  ruled out; the ticket stays open, never wrapped as a known issue to make the run green). VM-19: trace the
  stale-first-responder desync on its own; fix each mechanism found, with its pin. Records:
  `notes/plans/vm-8-castle-catchup.md` (UNIT 1 — LIVE STATUS, Suites); `notes/plans/fixes/vx-282-*.md`'s C-1.
- **VM-17 — do fan badges pile at block 1? (probe first).** Audit C·T1 reads it as unlikely: the badge's
  geometry comes from `firstLineGeometry`, which forces `.ensuresLayout`
  (`Write/MobileEditorTextView.swift:603-619`; `Takes/MobileTakesChrome.swift:195-224`) — the opposite of
  VX-230's unlaid-frame read (TEXTKIT2_NOTES §3; `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U4).
  Write the probe: a long note with many fanned blocks below the fold, mounted in the phone editor, asserting
  that no two fanned blocks' badge frames coincide and that an off-screen block's badge sits at its own block
  (or is not drawn), never at block 1. **Red ⇒ fix with that probe as the pin (the Mac's rule: a badge waits
  until its block is laid out). Green ⇒ the finding is hollow: keep the probe as a guard pin, record it, change
  no product code.** Note for the record either way what forcing `.ensuresLayout` for every fanned block costs
  on a long note (VM-179, wave 4, owns that cost — do not fix it here).

**Evidence:** the trace written down; whichever arm each member took, its pin's red/green story.

#### BATCH C — LIVE STATUS

**NOT DONE YET (first, as the contract asks):** no `xcodebuild test` has run for this batch, no simulator booted, no
product line changed. Every red/green below is **PENDING** window (3). **No revert and no hand-break is in flight.**

*Implementer: `opus-implementer`, session of 2026-11-19. Half 1 = read, trace, instruments, a green `build-for-testing`
(no stage); half 2 = the orchestrator's GO window.*

| Member | State | Pin / instrument (TYPE name for `-only-testing`) |
|---|---|---|
| VM-24 | IN-PROGRESS — half 1 DONE (trace, hypotheses, instruments `a570d3960` + `fec0e478b`); half 2 = window (3), MATRIX ONLY, then the arm taken after release (a fix's own red/green in a second short window) | the red itself: `MobileMarkdownCaretTests` · instruments: `MobileCaretReplaceTraceTests`, `MobileCaretReplaceTeethTraceTests` (DIAGNOSTIC) |
| VM-19 | IN-PROGRESS — pin `615a12189` (RED on the hide-only teardown: PENDING), fix `5ec59922c` + round 1's N5 `839d86dd9` (the `defer` calls the same teardown; GREEN: PENDING); its reproduction is an instrument | pin: `MobileLivenessTests` (`arrivalRaisesFocusBeforeTheObservationLoops`'s VM-19 expectation) · instrument: `MobileStaleResponderTraceTests` (DIAGNOSTIC) |
| VM-17 | IN-PROGRESS — probe written `a570d3960`, re-shaped to round 1's F2 final call `e3f406086`, (i′) added by round 2's R2-F3 `78179b765`; outcome PENDING (the pile, (i), (i′) or (ii) red ⇒ real: stop and report; all green ⇒ hollow, kept as the guard) | `MobileFanBadgePlacementProbeTests` (`noFanBadgePilesAndNoneStandsAstrayInTheViewportOnALongNote`) |

**Half 1 — DONE (2026-11-19).** Phone `build-for-testing` signed for `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`
into `DerivedData/vm78-ios` (no boot): **TEST BUILD SUCCEEDED** at the code of `fec0e478b` (its one later edit is a
comment). No `xcodebuild test`, no simulator booted, no product file touched — this batch's commits
(`b1a19db56..`) change only this record and three files under `VariorumMobileTests/`
(`MobileCaretReplaceTraceTests.swift` and `MobileFanBadgePlacementProbeTests.swift` new; `MobileLivenessTests.swift`'s
arrival test). The only warnings in the batch's files are the deliberate
`UIWindow(init(frame:))` deprecations (the polluted postures are reproduced as they were).

**Ladder round 1's calls on this batch — APPLIED headless (2026-11-19):** F2 (the probe, `e3f406086`), N5 (`839d86dd9`),
F6 and F7 (this section's matrix and arms, below). **The F2 amendment, said here as the final call asks:** the brief's
pin wording for VM-17 ("an off-screen block's badge sits at its own block") is AMENDED — that reading is now a printed
measurement (an off-screen badge against an idealized layout the live surface never promised is not something she can
see, and a kept guard cannot carry a line red by TextKit's design), and the pin is what is visible (the viewport
invariant). Phone `build-for-testing`, signed for `name=iPhone 17 Pro,OS=26.2` into `DerivedData/vm78-ios`, no boot:
**TEST BUILD SUCCEEDED** at the code of `839d86dd9` — which carries the round-1 fix pass's product files, so the
products there are current for `test-without-building`. **The hand-break products are NOT pre-built, deliberately:** the
proof runs the FIXED caret test, and arm A's fix is written only after the trace names the posture; a hand-broken build
made now would run the unfixed test, red already, and prove nothing. They are built when arm A's fix exists (below).

**The orchestrator's answers to the window runner's readiness report — APPLIED headless (2026-11-19).** A fresh
`opus-implementer` runs window (3) (the instruments' author spent its context at a clean seam). Its readiness read
changed nothing and found: `DerivedData/vm78-ios` holds the tip's code (every batch C source file predates the
06:00:07 build, the test binary carries round 1's F2 probe text, the tree is clean); the stale 04:31
`…arm64-x86_64.xctestrun` beside the 06:00 `…arm64.xctestrun` points at the same `Debug-iphonesimulator` products;
`vm78-bundles/` is empty. The stage coordinator re-shaped the window to MATRIX ONLY in one 25-minute claim, and the
orchestrator ruled the report's eight points. Both are written into the matrix and the arms below: every fix step
moved out of the window; teeth-red filtered to one function; the hand-break's reach read from M2 first; the unmapped
posture case decided by the orchestrator after the window; the other unmapped combinations; arm A's own copy of the
wait; a jump-road reach miss named separately; M9-red's extra red; reading 2's yardstick.

**Ladder round 2's calls on this batch — APPLIED headless (2026-11-19; `vm-78-ladder-round2.md`, "Final calls"):**
R2-F3 in the probe (`78179b765`: (i′), its counts and its two expectations), then one phone `build-for-testing`,
signed for `name=iPhone 17 Pro,OS=26.2` into `DerivedData/vm78-ios`, no boot, log `DerivedData/logs/vm78-c-bft6.log`:
**TEST BUILD SUCCEEDED** at the code of `78179b765` — so window (3)'s M5 runs WITH (i′). R2-F1 (the bundle rule), R2-F2
(two lines under "Combinations no arm maps", H1's second half, arm A's posture expectation), R2-N3 (the filter quoted)
and R2-N5 (the voice-flip cite) are written into the matrix and the arms below.

**The instruments (what each run prints — `grep -E 'VM(24|19|17)\|'` over the log):**
- `MobileCaretReplaceTraceTests` (DIAGNOSTIC, asserts nothing): the red test's replace, three postures × the three
  replacements × two fresh worlds — `vm24_suitePosture` (the red test's own host and timing: no turn between host and
  act), `vm24_realPosture` (H2's decider: the same after a bounded wait until the window is key, the view first
  responder and any keyboard presentation finished), `vm24_settleHeld` (H1's decider: the selection/change callbacks
  are NOT forwarded to the model during the replace; one settle is replayed after it). Each case prints the posture
  (app, every scene and window — key, hidden, level, who holds first responder — the keyboard notifications,
  `GCKeyboard`, input modes, traits), every gate consult with the storage's edit mask, every `sel`/`chg` callback with
  the mask before/after the model's handler and whether any `processEditing` ran between (`WROTE-INSIDE-TRANSACTION`
  marks H1's signature), every `willProcess`/`didProcess` (mask, range, delta, the desync count, index vs storage
  length), the model's own E1 trace (`MobileEditTrace`, bound task-locally to the act), UIKit call stacks on every
  in-act event, and one `VERDICT` line. The model's gate is wrapped by a forwarding proxy for the act alone.
- `MobileCaretReplaceTeethTraceTests` (DIAGNOSTIC): the assertion's teeth — the settle made to write inside an explicit
  storage transaction that the replace then joins (the product rule "no face write joins an edit's transaction" broken
  by hand, test side). Red by construction in any posture; its own type because it opens a transaction around UIKit's
  replace (a host crash there costs only this run).
- `MobileStaleResponderTraceTests` (DIAGNOSTIC, VM-19's reproduction on its own): `MobileLivenessTests`' exact leftover
  (a text view raised in a frame window, then only hidden, its locals dropped) and then C-1's `leaving…` act
  (`insertText("hello ")` at `*|*`), victim in the pre-keyfix frame window and in the keyfix scene window, with and
  without the polluter — whether the polluter survives and still holds first responder, and the same trace.
- `MobileFanBadgePlacementProbeTests` (VM-17's PROBE — a pin or the guard by its outcome; round 1's F2 shape):
  `noFanBadgePilesAndNoneStandsAstrayInTheViewportOnALongNote` — 150 blocks of irregular length, every 7th fanned (22
  fans, block 0 included), hosted in a scene window (not key, no first responder). (1) THE PILE, an expectation: at
  load no two badges coincide, no later badge at block 1. (2) A MEASUREMENT, printed, never asserted
  (`VM17|load|`, `VM17|reading2|`): how many off-screen badges stand off an idealized layout (a bare TK2 stack over a
  copy of the text, laid out whole from the start), the largest and the mean distance — VM-179's numbers. (3) THE
  VIEWPORT INVARIANT, expectations, on two COLD mounts: a stepped walk (unanimated offsets of 0.8 of a viewport, the
  end re-read live, to the live end) and the product's jump road (`jumpToBlock`, far to near); visible rect =
  `view.bounds`, every fragment read unforced (`options: []`): (i) every drawn badge meeting the visible rect stands
  within 1 pt of its own block's `.layoutAvailable` first line (`VM17|astray|` on failure); (ii) every laid-out fanned
  first line whose top is on screen has its drawn badge within 1 pt (`VM17|bare|`); (i′) (round 2's R2-F3) every drawn
  badge meeting the visible rect, asked without its own block's frame: the point 1 pt under its top, at the container's
  mid-width, in container coordinates, must lie in a fragment (`textLayoutFragment(for:)` — the product's swipe
  hit-test call; nothing forces layout) that BEGINS at the badge's own block offset; a point outside the visible rect is
  skipped and counted; a different offset ("stands beside the fragment at @n") or no fragment ("no fragment at the
  badge's point") is a miss, printed `VM17|astray|(i′) …`; (iii) REACH — every jump target, and across the walk every
  fanned block, meets (ii)'s premise at least once, and (i′) asks at least one badge on each road ("the probe did not
  reach…": the probe's red, never VM-17's). Per-stop lines `VM17|walk|` / `VM17|jump|` (with `asked=`, `skipped=`,
  `misses=`), and `VM17|SUMMARY` (the totals). Plus
  `vm17CostNote_theDocumentPassOnALongFannedNote` (prints only — VM-179's; leaves with the instruments): load time
  fanned vs unfanned over the same text and the cold/warm `.document` chrome pass at 150 and 600 blocks.

**THE WINDOW (3) — MATRIX ONLY, one `Tools/stage` claim of 25 minutes (the stage coordinator's shape; round 1's F6/F7
applied).** From `~/dev/variorum-vm-78/App/Variorum`, on the orchestrator's GO (sim booted fresh by id, ~25 s settle,
`pgrep -lx Variorum` empty). The claim runs M1, M2, M3, M4, M5, M6a, M6b, M7, M9-red and M9-green and NOTHING else: no
fix is written, built or run inside it on any arm. After the matrix: the simulator shut down, `git status` clean,
release, the result line. Any fix's own red/green (arm A's fixed test and its teeth pair, a fixed probe's re-run) and
any re-run ALONE of a red seen under load belong to a SEPARATE short window that the orchestrator requests once the fix
is written and built headless; a red seen under load in this window is recorded as seen once, not yet counted. Every
run keeps its result bundle under `DerivedData/vm78-bundles/` (round 1's N11; a name is never reused — `xcodebuild`
refuses an existing bundle) and its log under `DerivedData/logs/vm78-c-<run>.log`; poll for the Swift Testing verdict
line (`Test run with [0-9]+ tests? in [0-9]+ suites? (passed|failed)` — singular for a one-test run; also break on
`xcodebuild: error` and `** TEST (EXECUTE )?FAILED **`, and count `Restarting after unexpected exit`, whose
relaunch's verdict covers only the relaunch), never the exit. **The bundle rule (round 2's R2-F1):** after the
verdict line the runner's own `xcodebuild` (found by its bundle name) gets up to 90 s to exit by itself before it is
stopped; after every run `xcrun xcresulttool get test-results summary --path <bundle>`, and beside the run in this
record either "bundle reads" or "bundle unreadable — the log is the evidence"; every run's log is kept under
`App/Variorum/DerivedData/logs/` whatever the bundle does, never deleted before the run closes. Every red is named,
and said with whether it was seen ALONE on a quiet machine. **The three trace suites run only ALONE** (in one process
their posture and the global voice reach other suites — F7).
```zsh
T=(xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile
   -destination 'platform=iOS Simulator,id=<simulator-udid>' -derivedDataPath DerivedData/vm78-ios
   -collect-test-diagnostics never)
B=DerivedData/vm78-bundles
"${T[@]}" -resultBundlePath $B/c-M1.xcresult  -only-testing:VariorumMobileTests/MobileMarkdownCaretTests
"${T[@]}" -resultBundlePath $B/c-M2.xcresult  -only-testing:VariorumMobileTests/MobileCaretReplaceTraceTests
"${T[@]}" -resultBundlePath $B/c-M3.xcresult  -only-testing:VariorumMobileTests/MobileCaretReplaceTeethTraceTests
"${T[@]}" -resultBundlePath $B/c-M4.xcresult  -only-testing:VariorumMobileTests/MobileStaleResponderTraceTests
"${T[@]}" -resultBundlePath $B/c-M5.xcresult  -only-testing:VariorumMobileTests/MobileFanBadgePlacementProbeTests
"${T[@]}" -resultBundlePath $B/c-M6a.xcresult -only-testing:VariorumMobileTests/MobileMarkdownCaretTests
"${T[@]}" -resultBundlePath $B/c-M6b.xcresult -only-testing:VariorumMobileTests/MobileMarkdownCaretTests
"${T[@]}" -resultBundlePath $B/c-M7.xcresult  -only-testing:VariorumMobileTests/MobileLivenessTests \
                                               -only-testing:VariorumMobileTests/MobileMarkdownCaretTests
```
| Run | What | Expected |
|---|---|---|
| M1 | the caret suite ALONE | **RED BY DESIGN** — the standing red: `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` for `"hi"` and `"hello there"` (`desyncRecoveryCount == 0`, 2 issues); every other caret test green. A green M1 is itself a finding (state-dependence — read its posture against the red runs') |
| M2 | `MobileCaretReplaceTraceTests` ALONE (suite posture · real posture · settle held) | **expected GREEN** (asserts nothing — the read is the `VM24|` trace and its `VERDICT` lines) |
| M3 | `MobileCaretReplaceTeethTraceTests` ALONE | **expected GREEN** (asserts nothing; its `VERDICT` lines are expected to show `desync=1` BY DESIGN — supporting evidence only, F6) |
| M4 | `MobileStaleResponderTraceTests` ALONE (VM-19's reproduction) | **expected GREEN** (asserts nothing — the read is the `VM19|` trace) |
| M5 | `MobileFanBadgePlacementProbeTests` ALONE (VM-17's decision run, with (i′)) | **expected GREEN** if VM-17 is hollow; a red in the pile, (i), (i′) or (ii) decides the member real (stop and report); a red in (iii) or in (i′)'s "asked at least one" is the probe's |
| M6a, M6b | the caret suite alone, twice more (the repetition; the old M8 `-test-iterations` row is retired) | **RED BY DESIGN**, as M1 — the same two cases, the same counts |
| M7 | `MobileLivenessTests` + `MobileMarkdownCaretTests`, NO trace suite (C-1's pair, with the VM-19 fix in) | **expected GREEN** for every liveness test (the VM-19 expectation included); the caret suite **RED BY DESIGN** as M1 — any caret red BEYOND M1's two (C-1's `leaving…` crash, an extra desync) is attributed to the pair only after an immediate re-run of M1 ALONE is green, never by M7's line alone (`MobileLivenessTests` flips the global voice too: `aVoiceFlipReachesEveryRegisteredEditor`, `:1104-1146`, its flips at `:1135` and `:1141`, the reset at `:1110` — a synchronous flip window by that test's own design, so no other suite can observe the other voice from it; the rule stands anyway, the pair sharing a process) — that re-run is not in the matrix-only window: such a red is recorded UNATTRIBUTED, and its M1-alone re-run goes to the second window |

**M9 — VM-19's pin, red-on-old then green (the revert protocol):** write "REVERT IN FLIGHT — MobileLivenessTests.swift
at `615a12189` (the pin on the hide-only teardown); restore = `git checkout HEAD -- App/Variorum/VariorumMobileTests/MobileLivenessTests.swift`"
into this LIVE STATUS, commit + push, THEN `git checkout 615a12189 -- App/Variorum/VariorumMobileTests/MobileLivenessTests.swift`
and run (it rebuilds the one test file):
```zsh
xcodebuild test -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'platform=iOS Simulator,id=<simulator-udid>' -derivedDataPath DerivedData/vm78-ios \
  -collect-test-diagnostics never -resultBundlePath DerivedData/vm78-bundles/c-M9-red.xcresult \
  -only-testing:VariorumMobileTests/MobileLivenessTests
```
— **RED BY DESIGN** exactly at `arrivalRaisesFocusBeforeTheObservationLoops`' VM-19 expectation ("the raised surface
lets go…"), every other liveness test green. Restore with `git checkout HEAD -- …` (NOT `git checkout -- …`: the old
version is staged by the revert), `git status` clean, record "no revert is in flight", re-run the same command with
`-resultBundlePath DerivedData/vm78-bundles/c-M9-green.xcresult` — **expected GREEN**. (Green on both sides ⇒ the
posture fix is hollow: record it, revert `5ec59922c` and `839d86dd9` by new commits.) An extra liveness red in M9-red
is VM-19's own class showing (the hide-only teardown leaves its polluter for the rest of the unserialized suite): name
it; it must be absent in M9-green.

**What each outcome means, decided in advance (the arms — round 1's F2 and F6 final calls, with the orchestrator's
answers to the readiness report):**
- **VM-24 — M2 `suitePosture` red for "hi"/"hello there" with `WROTE-INSIDE-TRANSACTION` on an in-act `sel`, the
  character report starting at 0 AND reaching the terminator (`{0,6}` for "hi" — round 2's R2-F2: the settle's own
  write is `{0,8}`, the face's applied ranges and spans only, so the widening past the terminator is attribute
  fixing's; an unwidened `{0,5}` gives `fallbackVerdict` the old range `(0,8)`, block 0 exactly, and no desync), E1
  "arming rejected"; `settleHeld` green** ⇒ H1 is the mechanism. **Before any arm's fix, the hand-break's reach is
  read from M2** (holding for a process in M2's state — the "seen red" rule below stays the proof): M2 `realPosture`'s in-act `didProcess … range=` line for each
  caret-moving replacement. The hand-break (below) reaches the assertion only through a report WIDENED past the
  paragraph's terminator (for "hi", `{1,5}` → the old range `(1,8)` crosses the separator at 8 → `.refuse`); an EXACT
  report (`{1,2}`) sends `fallbackVerdict` (`MobileEditorViewModel.swift:1962-1972`) back to `.block(0)`, and the fixed
  test would stay green under the hand-break. If exact, the window's report says so: per F6's final call arm A then
  does not close on the teeth suite alone, and the orchestrator takes it to the reviewer before any build is spent.
  Then:
  - **ARM A, TEST POSTURE — only when `realPosture` is GREEN and `suitePosture`'s posture at the act shows `key=false`
    or `fr=false`** (postures no person can type in). **Nothing of arm A runs inside window (3).** After release,
    headless, in this order: (1) the fix — `MobileMarkdownCaretTests.host(_:)` becomes `async` and waits for the real
    posture as `CaretTraceHost.waitForTheRealPosture` does (bounded: at least 20 and at most 300 turns of a yield and a
    5 ms sleep, until the window is key, the view first responder and the keyboard's willShow and didShow counts
    agree), carrying ITS OWN copy of that wait and ITS OWN keyboard willShow/didShow counter, observing from before
    `becomeFirstResponder` — the instruments leave in F7's removal commit, so the fix references neither
    `CaretTraceHost` nor `CaretInputTrace`; after its bounded wait `host` carries ONE expectation over everything it
    waited for — the window is key, the view is first responder, the keyboard's willShow and didShow counts agree —
    its message naming the three and printing their values, so a caret test can never run silently outside the posture
    it means (round 2's R2-F2); the four call sites `await` it; committed and pushed. (2)
    `build-for-testing` (same destination) into `DerivedData/vm78-ios`, so it holds the FIXED test. (3) **The teeth —
    the product hand-break, run against the FIXED test (F6):** write "HAND-BREAK IN FLIGHT —
    `App/Variorum/Shared/EditorBrain/EditorEditRouting.swift` `ArmedEdit.describes`' `editedRange.location >=
    range.location` made `>`; restore = `git checkout HEAD -- App/Variorum/Shared/EditorBrain/EditorEditRouting.swift`"
    into this LIVE STATUS, commit + push; make the one edit; `build-for-testing` (same destination) into
    `DerivedData/vm78-ios-handbreak` (a fresh DerivedData: a cold build of every package); restore the file straight
    after the build and record `git status` clean. (4) **The second short window**, requested by the orchestrator once
    both builds exist: teeth-red — `test-without-building` against `vm78-ios-handbreak`, filtered to the ONE function,
    the argument QUOTED WHOLE (round 2's R2-N3 — unquoted, zsh reads `(_:)` as a glob qualifier and stops before
    `xcodebuild` starts):
    `'-only-testing:VariorumMobileTests/MobileMarkdownCaretTests/aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)'`
    (`-resultBundlePath DerivedData/vm78-bundles/c-teeth-red.xcresult`; under the hand-break the unmuted siblings
    `herFlowTyping…` and `leavingATrailingSpace…` would desync too and trap the host through `EditorAssertionSeam`),
    its verdict required to read "1 test in 1 suite" (a misspelt id runs nothing and must not pass as a result) —
    **RED BY DESIGN** in the fixed test's rescue-point replace; teeth-green — the WHOLE type against `vm78-ios`
    (`c-teeth-green.xcresult`) — **expected GREEN**. The proof counts only if the fixed test is SEEN red under the
    hand-break and green without it; **if it stays green under the hand-break, report it — arm A does not close on the
    teeth suite (M3) alone.**
  - **ARM B, PRODUCT — when `realPosture` is RED as well, OR when key and first responder are true in BOTH postures and
    only the keyboard's presentation differs** (a window a person can be in: she taps into a note and an input-system
    replace lands while the keyboard is still rising) ⇒ the settle writes inside the input road's transaction in a
    posture a phone can be in — the autocorrect/spelling/dictation road desyncs and the recovery re-renders from the
    store (the replaced words may not survive the heal). **STOP and report** before touching `MobileEditorTextView` /
    the gate delegate / `Shared/` (the editor seam). Information for the ruling, in that report: every input-system
    replace (autocorrect after a typed space, dictation, the spelling Replace) needs her to have typed or dictated
    first, so a replace while the keyboard is still rising may be hard to reach by hand — reachability is the ruling's
    call. Candidate fixes for the ruling, none built: (i) the text view overrides `replace(_:withText:)`, holds the
    selection-driven settle across `super` and settles once after (a few lines in the seam; whether the keyboard's
    autocorrect reaches this override on device is unproven); (ii) the gate delegate defers a selection settle that
    arrives with the storage's mask empty but INSIDE UIKit's input transaction — needs a transaction signal UIKit does
    not publish; (iii) the binding learns the face's own attribute span (EditorBrain — the shared seam, both platforms).
  - **THE UNMAPPED POSTURE CASE — key and first responder TRUE in both postures, the keyboard rows identical,
    `realPosture` GREEN** (the only difference: run-loop turns after `becomeFirstResponder`). Neither arm's trigger is
    met, and **the arm is NOT decided in the window.** The runner records exactly what the two postures show,
    including whatever in the trace speaks to whether an input session exists at the act (`modes=`, `viewMode=`,
    `gcKeyboard=`, the keyboard rows — and if nothing does, it says so), and its PROPOSED READING with that evidence:
    an input-system replace (autocorrect, dictation, the spelling Replace) cannot arrive before its input session
    exists, so no person can be in that posture — test posture, arm A's shape. **The orchestrator decides the arm after
    the window, with the trace in hand**; the ladder's next cold reviewer reads the decision; no fix starts on this
    case until the orchestrator names the arm.
- **Combinations no arm maps (the orchestrator's word):** M2 `suitePosture` GREEN while M1/M6 are red (the instrument
  then perturbs the act — the delegate proxy swap, `MobileCaretReplaceTraceTests.swift:136-140`, and the posture
  snapshot's input-mode and `GCKeyboard` reads, `:234`, sit between host and act); `WROTE-INSIDE` present with
  `settleHeld` still red; `settleHeld` green with no `WROTE-INSIDE` ⇒ H1 not cleanly confirmed: no arm A or B from this
  window; record what each line showed and what is ruled out (the untraceable arm); a second window only if the
  stacks name a writer.
  - **`realPosture` never reached its posture (round 2's R2-F2, line one):** its `waited spins=300`, or its at-act
    snapshot or VERDICT showing `key=false` or `fr=false` ⇒ no arm from this window. The after-wait snapshot says which
    condition failed — the window not key, the view not first responder, or both true with the keyboard's willShow and
    didShow never agreeing; all three are one answer: the posture the run was meant to stand in was not reached. That
    is the finding, recorded with the snapshot; the orchestrator decides after the window.
  - **The report's range, not the posture (round 2's R2-F2, line two):** where a red case and a green case differ in
    `firstCharReport` / `didProcess … range=` (terminator-inclusive or not) while their postures agree — M1 against a
    green M1, suite against real posture, alone against the pair — the answer is attribute fixing's widening (TEXTKIT2
    §3, 18k C8: decided by paragraph-style object identity, process-wide; unmeasured on iOS), not posture: neither
    arm; record both ranges and stop for the orchestrator.
- **M2 shows no in-transaction write and `settleHeld` still red** ⇒ H1 killed; read H4 (E1's consults) and the stacks
  for the writer; a second window would run whatever that names.
- **M1 green alone on a quiet machine** (state-dependence, as VM-8 L1 saw once) ⇒ record the posture snapshot of the
  green run against the red ones (H3: the keyboard rows) — that difference IS the trace's answer.
- **VM-19 (M4):** desync in `frameWindow|polluted` but not `sceneWindow|*` ⇒ C-1's reading stands (a test-posture gap:
  the keyfix posture defends, the polluter is real) — the liveness fix (M9) closes the polluter the ticket names; the
  trace's E1/gate lines say what the insert road did in that posture (the ticket's second owed item). A desync in
  `frameWindow|clean` too ⇒ the frame window alone is the polluted posture (no leftover needed). A desync in
  `sceneWindow|*` ⇒ the keyfix posture does not defend on this toolchain — the same arm question as VM-24. No desync
  in any of the four cases ⇒ "not reproduced on this toolchain", recorded so; the M9 pin stands as test hygiene.
- **VM-17 (M5), round 1's F2 arms with round 2's R2-F3:** (1) red ⇒ the pile, VX-230's shape. **(i), (i′) or (ii) red
  ⇒ VM-17 is real — STOP and report before any product line** (an (i′) red reads exactly as (i)'s does; both lines go
  in the report). The fix shape the reviewer would confirm, written down, not built: the Mac's rule
  made literal — an off-band badge does not stand: the `.document` pass resolves badges for in-band blocks only and
  hides the rest; the `.nearViewport` pass hides a badge as its block leaves the band and resolves it as it enters
  (tail reservations untouched — storage truth). The peek markers share the standing-frame rule
  (`MobileTakesChrome.swift:256`); the fix covers them or a ticket names them. Pin: (i)/(ii), red on the unfixed
  chrome. **(1), (i), (i′), (ii) green ⇒ HOLLOW:** no product line, the probe kept as the guard, reading 2's numbers and
  the cost note's written into this record for VM-179. **The HOLLOW verdict states its reach:** reading 2's largest
  distance beside one viewport's height of text (about 700 pt less the insets) — APPROXIMATE, and said so, because the
  band's pad (`nearViewportBand`) is one viewport of CHARACTERS each side (`max(the viewport's characters, 512)`), not
  points. Under it: no load-time estimate on this note could stand on screen before its block came into the band, and
  "hollow" is shown for notes of this size. Over it with everything green: the verdict still stands on what the walk
  and the jump saw, and the number goes to VM-179 with the words "longer notes were not run". (iii) red, or (i′)'s
  "asked no badge" on a road ⇒ the probe did not reach — fix the probe, never the product; the fixed probe is written and built headless after release and re-run only in the second window, never in
  window (3). **A reach miss on the JUMP road is named separately:** `jumpToBlock`
  (`MobileEditorViewModel.swift:1134-1155`) forces layout at a mid-document target and scrolls there unclamped
  (TEXTKIT2 §3's VX-246 shape), so the product's jump can leave its target off screen after the next viewport pass —
  record each miss's distance (the target's live first line against the visible rect, from its `VM17|jump|` line) as
  a jump-road observation for the orchestrator to ticket (no ticket id invented), apart from "the probe did not
  reach". **Reading 2's yardstick** (`idealMinY`'s container of height 0 — TextKit reads a non-positive container
  dimension as unlimited) is left as written; if reading 2 comes back empty (`offscreenDrawn=0`), say so plainly, and
  VM-179's numbers are re-measured later.
- **After the window, BEFORE any whole-target run (F7):** the named removal commit — the three trace suites
  (`MobileCaretReplaceTraceTests.swift` whole) and the cost note — lands once their traces and numbers are in this
  record; the probe's main test stays (it flips no global and plants no responder). The gate's whole-target line is
  taken on the tree without them.

**Environment facts read in half 1 (no device id written):** Simulator app `ConnectHardwareKeyboard = 0` (global and
the one per-device entry; the prefs file last changed Aug 31). The device's `com.apple.keyboard.preferences`:
`HardwareKeyboardLastSeen = true`, keyboards `en_US@sw=QWERTY;hw=Automatic`; its `com.apple.keyboard.plist` last moved
2026-10-14 09:42 (C-1's K run), its `com.apple.Preferences.plist` 2026-10-25 06:16 (VM-8 unit 1's day), its keyboard
preferences and text-replacement plists tonight 04:24–04:25. Toolchain: Xcode 27.1 (27A9275).

**Questions for the orchestrator to file (none yet gating):** none. **PROVISIONAL:** none (the half-1 process choice —
the teeth instrument as arm A's proof — is WITHDRAWN by round 1's F6: the proof is the product hand-break against the
fixed test).

**Read in this session (myself):** CLAUDE.md + its loaded canon; MobileSoul §1–5; the resiliency protocol; the catch-up
plan's inherited rules; sitting-1 rulings; this file's kickoff facts and batch C; TEXTKIT2_NOTES §3–4; the VM-8 record's
caret-red passages (unit 1 LIVE STATUS, unit 2, L1 run D); VX-282's C-1 whole (merged-tip run → fix leg → decider →
ruling → final window); the tickets VM-24, VM-19, VM-17 and the duplicates VM-34/36/37/38; audit C·E1/E11/T1 and D-73;
the code on both roads (below).

**The trace (VM-24) — the road the red test drives, and what is settled about it:**
- The test (`MobileMarkdownCaretTests.swift:192-232`) hosts the surface (`host(_:)` — a window on the foreground scene,
  leftovers resigned, `makeKeyAndVisible`, `becomeFirstResponder`), sets the caret to 7 in `*hello *` (the rescue
  point, honoured), then calls UIKit's `replace(_:withText:)` over `hello` (1,5) and SYNCHRONOUSLY reads
  `desyncRecoveryCount` — no run-loop turn between `host()` and the replace.
- The road: UIKit's replace → the gate (`MobileEditorGateDelegate` → `shouldChangeText`, arms `ArmedEdit` for (1,5)) →
  the storage edit → `MobileStorageObserver` → `storageDidEdit` binds the arming through `ArmedEdit.describes`
  (`Shared/EditorBrain/EditorEditRouting.swift:140-155`: the report must START at or after the approved location) →
  else `fallbackVerdict` over the report's `(location, length − delta)` → a report widened over the paragraph's
  terminator (attribute fixing, TEXTKIT2 §3 iOS) crosses the separator → `.refuse` → `recoverFromUnroutableEdit` →
  `desyncRecovery` (+1). The caret settle (`settleMarkdownCaret` → `MarkdownFace.settleCaret`,
  `Shared/MarkdownFace/MarkdownFaceCore.swift:241-277`) runs from `textViewDidChangeSelection` and `textViewDidChange`;
  its one guard is `storage.editedMask.isEmpty` (empty between `beginEditing` and a transaction's first change).
- Settled by the record: deterministic for `"hi"` and `"hello there"` (the caret-MOVING replacements), never `"Hello"`
  (same length, the caret stays put); red ALONE on branch and main (VM-34/37/38); one green whole-target run on
  2026-10-25 (VM-8 L1); green on 2026-10-14 in C-1's K and final windows (the same host posture). **No product line on
  this road changed between the Oct 14 green and the first red** — `git log 2d36b2b06..` over the text view, the view
  model, `Shared/EditorBrain`, `Shared/MarkdownFace`, `MarkdownCaretRescue`: only VX-342's undo wording (Oct 14),
  VX-806 (Nov 5), VX-683 B (Nov 8) — the last two after the red was already standing. The inert test host (VX-912 B1,
  Nov 8) did not clear it (VX-915's gate, Nov 9, still red). So the change is environmental or posture, and the
  mechanism is C-1's: in the polluted posture the settle's write desynced a replace and disappeared with the settle off
  (C-1 decider D); a `pendingEdit` guard did NOT stop it (c1fix (a)) — so the in-transaction selection report can come
  BEFORE the gate's consult.
- Environment read (read-only, no boot): the Simulator app's `ConnectHardwareKeyboard` is 0 (its prefs file unchanged
  since Aug 31); the device's own `com.apple.keyboard.preferences` reads `HardwareKeyboardLastSeen = true`, and the
  device's keyboard plists last moved inside C-1's windows (Oct 14, 09:42) and tonight. C-1's logs named a "manual
  keyboard"; whether a software keyboard presents during these runs is unrecorded — the posture snapshot records it.

**Hypotheses, ranked — each with the one observation that confirms or kills it:**
1. **H1 — the settle writes INSIDE the replace's storage transaction (the mechanism).** For a caret-moving replace,
   UIKit reports the selection (`textViewDidChangeSelection`) from inside `coordinateEditing` before the character
   change; `editedMask` is empty, so the settle's attribute write joins the transaction; the one report starts at the
   line's first marker (0 < the approved 1), the arming is rejected, the widened fallback crosses the separator.
   *Confirms:* the trace shows a selection callback during the replace with the mask empty before and non-empty after
   with NO processEditing between (the write landed inside an open transaction), then one character report at location
   0 carrying chars+attrs, E1 "arming rejected", desync +1; and the decider (the in-replace settle HELD, replayed after)
   is green. *Kills:* no in-transaction write (the mask after the callback is empty, or a separate attribute-only
   report fired), or the character report starts at 1.
2. **H2 — the posture is not the one the test means (decides test-posture vs product).** When the replace runs, the
   test's window is not key, or the scene is not foreground-active, or the text view is not first responder of the key
   window (the keyfix posture not reached on this toolchain: `makeKeyAndVisible`'s promotion is deferred and the test
   never yields). *Confirms:* the posture snapshot right before the replace shows `key=false` or `fr=false` or an
   inactive scene; and the same replace after waiting (bounded) until the window is key, the view first responder and
   the keyboard settled is green. *Kills:* key + first responder + active scene at the replace, and the waited variant
   still red ⇒ H1 is a PRODUCT mechanism in a real posture (editor seam — stop and report before any fix).
3. **H3 — the keyboard's state (software vs hardware) changes UIKit's ordering.** *Confirms:* red runs show a software
   keyboard presenting (keyboard notifications after `becomeFirstResponder`, no `GCKeyboard`) while a green posture
   shows none, or the reverse. *Kills:* the same keyboard state in red and green variants.
4. **H4 — the gate is consulted more than once, or for another range, on this road** (the M1 class). *Confirms:* E1
   shows >1 consult before the report or a consult ≠ (1,5). *Kills:* exactly one consult (1,5) armed, then one report.

**VM-19 (carried):** the ticket owes (a) `MobileLivenessTests` resigning what it raises, and (b) the gate's unrouted
road traced in a non-key posture. Its own reproduction is an instrument below (a stale first responder left exactly as
`arrivalRaisesFocusBeforeTheObservationLoops` leaves one, then an `insertText` of a run — C-1's `leaving…` shape —
in two victim postures, with and without the polluter).

**VM-17 — the read:** the badge's y comes from `firstLineGeometry(atOffset:)`
(`MobileEditorTextView.swift:603-619`), which forces `.ensuresLayout` FROM the block's own offset; the `.document` pass
(load, flips, voice) does that for every fanned block (`MobileTakesChrome.swift:195-224`). So VX-230's mechanism — an
unlaid fragment's `.zero` frame — cannot arise (the frame is laid out), and a pile at block 1 is unlikely as the audit
says. But TEXTKIT2 §3's VX-246 finding (macOS 27) is exactly this shape: a mid-document `.ensuresLayout` places fragments
at ESTIMATED offsets until a viewport pass re-positions them. So the probe separates three readings: a pile (two badges
coincide, or any badge at block 1), an off-screen badge off its own block (against an independent clean TK2 stack laid
out whole from the start), and a visible badge off its block once scrolled to.

## The ladder

*(round files `vm-78-ladder-roundN.md` beside this one; findings and dispositions land here before the next round)*

**Cap for this run: five rounds, each earned by a new BLOCKER or MAJOR in the round before it (her ruling tonight,
Kickoff facts).**

### Round 1 — `vm-78-ladder-round1.md` (a fresh `fable-reviewer`; diff `e48ef2f30..988e9434f`)

**0 BLOCKER · 2 MAJOR · 6 MINOR · 11 NIT.** No product bug above MINOR in batches A and B. The findings, the
implementers' answers and the reviewer's final calls are in the round file (findings `708450404`, final calls
`90610aa92`); nobody disputed a finding and none is FINDER-FIXES. Dispositions:

| Finding | Final call | What changes |
|---|---|---|
| F1 MAJOR (process) — the ladder cannot close before batch C's window is cold-read | CONFIRMED (the orchestrator's answer: agreed) | Round 2 is a fresh reviewer, spawned only after windows (1) and (3) have run and batch C's outcome is on the branch; it reads as new work window (3)'s outcome, this fix pass, and VM-16 re-landed on main's message seam |
| F2 MAJOR — the VM-17 probe's reading 3 is vacuous | CONFIRMED, amended | Reading 2 becomes a printed measurement; reading 3 becomes the viewport invariant by a stepped walk and by `jumpToBlock`; the arms rewritten — applied by batch C's implementer BEFORE window (3). **This amends the brief's pin wording for VM-17** (the brief asked that an off-screen block's badge sit at its own block; the final call makes that a measurement and pins what is visible) |
| F3 MINOR — Unarchive dumps raw text on `readingNotArchived` | CONFIRMED | the one arm, pin `aRacedUnarchiveSpeaksTheSharedSentence` |
| F4 MINOR — the guide's "pins or unpins" sentence is now false | CONFIRMED, amended | the implementer's sentence (a DRAFT for her wording pass), the dangling "also" dropped, the rest named for VM-212 |
| F5 MINOR — no pin drives the Finish confirm's face | CONFIRMED + one assertion | the row's label, `cancelFinish()` deleted, two hosted guards, the write-back-then-confirm assertion |
| F6 MINOR — batch C's arm A lumps a keyboard-only difference with test posture | CONFIRMED | keyboard-only ⇒ stop and report; the teeth proof is the fixed caret test against the named product hand-break |
| F7 MINOR — the instruments must leave before any whole-target run | CONFIRMED, extended | the removal commit first; M6/M7 re-shaped; a caret red under the pair counts only after M1 alone |
| F8 MINOR — Diverge on a gathering row: the Mac draws and refuses, the phone no longer draws | CONFIRMED as a question | filed in `notes/QUESTIONS.md` at the merge; the phone's choice stays PROVISIONAL |
| N1–N5, N7–N11 | confirmed as answered (N4, N7 in part) | small fixes and guards; N9 is a walk row; N10 a ticket to file; N11 keeps result bundles from here on (batch B's RED bundle was not kept — attested by the verdict line and the reviewer's per-pin reading) |
| N6 | withdrawn | one line for VM-113's kickoff |

**The fix pass** is applied by a fresh `opus-implementer` (batches A and B; the two original sessions' context was
spent) and by batch C's implementer (its own files); each bug-class fix lands with its pin, shown red on the
pre-fix-pass tip and green after in its own short stage window.

### Round 2 — `vm-78-ladder-round2.md` (a fresh `fable-reviewer`; opened 2026-11-19 at tip `84fe72e50`)

Round 2 re-reviews round 1's fixes and what they touched (`0180727de..84fe72e50`: the fix pass for batches A and
B, batch C's rewritten probe and re-shaped arms) while the stage queue stands between this run and batch C's
window. **It cannot close the ladder** (F1's final call): batch C's window (3) has not run, so its outcome — and
later VM-16 re-landed on main's message seam — is new work that a further fresh round reads whatever round 2
finds. State as it opens: batches A and B verified in windows (1) and (2); the fix pass verified in window (5)
except F4's pin, which waits for a short follow-up window; batch C's matrix is queued.

## Closeout

*(written at closeout: results, the PROVISIONAL ratify list, canon deltas, the mobile parity line, born tickets)*

### The run's state when ladder round 1 opened (2026-11-19, tip `e2c4c0c6e`)

The closeout proper is written when the last batch closes. Until then each batch's LIVE STATUS above is the
record of what was built and why, and this is what is and is not yet proved:

| Batch | Members | Code and pins | Red-on-old and green |
|---|---|---|---|
| B | VM-16 (+VM-20), VM-43, VM-3, VM-84, VM-33 | on the branch (`48055fa9c` … `a11af21d0`) | **VERIFIED** in stage window (2): the seven pins red on the pre-fix tree, 68 tests in 6 suites green on the fix. The Mac guard for the hoisted undo sentence is **PENDING** (the Mac leg). |
| A | VM-81, VM-83, VM-21 | on the branch (`68f7e7eab` … `5681d8304`); phone and Mac `build-for-testing` green | **PENDING** — stage window (1) is queued: 21 reds expected on the seam commit `7c9fc0151`, then green, then the Mac types that read the hoisted words. No simulator run has happened for this batch yet. |
| C | VM-24 (+VM-19), VM-17 | half 1 only: the trace instruments, the fan-badge probe, VM-19's pin and fix (`a570d3960` … `fec0e478b`) | **PENDING** — stage window (3) is queued. The three diagnostic trace suites and the probe's cost note are instruments, not pins; they leave the tree in a named commit once the trace is read. VM-24's cause is not yet traced and VM-17 is not yet decided real or hollow. |

Not yet done, by design: the whole phone target, the Mac leg on the merged tree, the simulator walk, the canon
deltas, the mobile parity row. Her rulings and the PROVISIONAL calls so far are in Kickoff facts and in batch A's
LIVE STATUS (one PROVISIONAL: an archived gathering's add row wearing "(archived)"); the drafted words waiting for
her wording pass are VM-3's lesson, the create sheet's three gathering lines, and whether the collect receipt and
the sealed book's Reopen sentence read rightly on the phone.
