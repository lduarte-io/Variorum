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

| Member | State | Pin (TYPE name for `-only-testing`) |
|---|---|---|
| VM-16 (+VM-20) | IN-PROGRESS — code + pins committed (`48055fa9c`, `a11af21d0`); builds GREEN; red-on-old + green **PENDING** (stage window) | `MobileUndoDoorTests`, `MobileUndoWarningWordsTests` (+ the Mac guard `UndoWarningWordsTests`, Mac leg) |
| VM-43 | IN-PROGRESS — `insuringBuffer: true` at the ONE phone call site (`0f8ca319d`); builds GREEN; red-on-old + green **PENDING** | `MobileBlockHistoryTests` |
| VM-3 | IN-PROGRESS — lesson rewritten (DRAFT for her wording pass), pin unwrapped + flipped, words pin added (`c29095d35`, `a11af21d0`); builds GREEN; red-on-old + green **PENDING** | `MobileTutorialStructureWalkTests` |
| VM-84 | IN-PROGRESS — seam + pin (`2d66e9a30`), fix (`f933a4663`); builds GREEN; red-on-old + green **PENDING** | `MobileNoteEntryDateTests` |
| VM-33 | IN-PROGRESS — REAL by reading; fix + pins (`e1d709b1b`); builds GREEN; red-on-old **PENDING — it is the proof**: a green-on-old makes the member HOLLOW (then revert the fix, keep the pin as a guard, record it) | `MobileTrashTests` |

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

| Piece | State | Pin (TYPE name for `-only-testing`) |
|---|---|---|
| The hoist (words) | DONE (`68f7e7eab`) — Mac `build` GREEN | the Mac's existing copy pins (Mac leg) |
| VM-21's hoist (the collect receipt family) | DONE (`4118af9b3`) — Mac `build` GREEN | the Mac's `GatheringCollectReceiptTests`, `GatheringCollectStarReceiptTests` (Mac leg) |
| Seams + pins (all three members) | DONE (this commit) — phone `build-for-testing` GREEN (unsigned, generic sim); every pin compiles against this tree; red-on-old **PENDING** (stage window) | see the members' rows |
| VM-81 | IN-PROGRESS — code DONE: the Finish confirm (`aa4a8670f`), the rest (this commit); phone `build-for-testing` + Mac `build` GREEN; red-on-old + green **PENDING** (stage window) | `MobileFinishConfirmTests`, `MobileBookStateRowTests`, `MobileArchivedStarredBookTests` (+ `MobileBookDetailsTests`) |
| VM-83 | IN-PROGRESS — code DONE (this commit); phone + Mac `build-for-testing` GREEN; red-on-old + green **PENDING** (stage window) | `MobileShelfOrderTests`, `MobileShelfRowActsTests`, `MobileGatheringWordTests` (+ `MobileShellTests`, `MobileBookDetailsTests`, `MobileWalkTests`, `MobileDeletionTests`) |
| VM-21 | IN-PROGRESS — code DONE (this commit); phone `build-for-testing` GREEN; red-on-old + green **PENDING** (stage window) | `MobileCollectReceiptTests` |

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

*(the implementer fills this from its first commit)*

## The ladder

*(round files `vm-78-ladder-roundN.md` beside this one; findings and dispositions land here before the next round)*

**Cap for this run: five rounds, each earned by a new BLOCKER or MAJOR in the round before it (her ruling tonight,
Kickoff facts).**

## Closeout

*(written at closeout: results, the PROVISIONAL ratify list, canon deltas, the mobile parity line, born tickets)*
