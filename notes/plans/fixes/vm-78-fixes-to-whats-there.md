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

*(the implementer fills this from its first commit)*

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

*(the implementer fills this from its first commit)*

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

## Closeout

*(written at closeout: results, the PROVISIONAL ratify list, canon deltas, the mobile parity line, born tickets)*
