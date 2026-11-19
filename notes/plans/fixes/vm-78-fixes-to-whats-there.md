# VM-78 — Run: Fixes to what's there (mobile catch-up, wave 1, umbrella 4)

**STATUS: OPEN 2026-11-19. Orchestrator session `vm-78`; /run-phase, overnight; `nov18` coordinating the stage and
the merges. Branch `vm-78-fixes-to-whats-there`, worktree `~/dev/variorum-vm-78` (Pro).**

## FOR A LATER READER

*Written 2026-11-19 at the closeout re-fit (tip `3107de895`), from the settled facts. Its `PENDING(…)` slots — the
re-land's window, ladder round 4, the gate, the QUESTIONS number — are filled at the merge. Everything below this
section is the night's working record.*

**What the run was.** The mobile catch-up's wave 1, umbrella 4: ten small fixes to faces the phone already had, pin
before fix per member, with no `Sync/`, custody, schema or `Sources/` line — batches B, A and C, then D for VM-17's
fix, then the back-out and the merge-in ("### THE MERGE-IN"). **It ships EIGHT members** — VM-16 (with VM-20),
VM-43, VM-3, VM-84, VM-33, VM-81, VM-83, VM-21 — and VM-19's teardown pin. **VM-24 and VM-17 were traced here and
left for their own runs by her rulings; neither is fixed by this run.**

**The mechanisms, as settled** (one paragraph each in the Closeout): VM-16 — `undo(with:)` / `redo(with:)` return
a label for a quiet press too, so the door passed it for a landed undo and kept a way back acting on another
entry · VM-43 — the phone's one restore door passed no `insuringBuffer` · VM-84 — the chip read the unobserved
`header` · VM-33 — the empty line drew before the observing `.task` ran (found real) · VM-3 and F4 — two guide
lessons outlived what they taught · VM-81 — Finish's `lockReading` dismisses pending arrivals unseen; Details
resolved its book from a listing that drops archived books; doors drawn where they could only refuse · VM-83 — the
retired `ShelfOrder`, two doors over one star, "smart" in the faces · VM-21 — a home-made collect receipt blind to
`starred` and `gatheringArchived` · VM-19 — a test's stale first responder; its desync did not reproduce here.

**The fixes as built, one pointer per piece:** VM-16 `48055fa9c`, re-landed on VM-55's message line `ed1266e2f` ·
VM-20 `48055fa9c`, re-landed `ed1266e2f` · VM-43 `0f8ca319d` · VM-3 `c29095d35` · VM-84 `f933a4663` (seam
`2d66e9a30`) · VM-33 `e1d709b1b`, re-landed inside the per-wing follow `ed1266e2f` · the word hoists `68f7e7eab`,
`4118af9b3` · batch A's seams and pins `7c9fc0151` · VM-81 `aa4a8670f`, `081af74b0`, `326d61da4`, `97282e72f` (at
the merge its own refusal arm was deleted — main's road speaks the same sentences — and Book Details' delete line
names a gathering, `ed1266e2f`, pin `8d2b9f8bf`) · VM-83 `0abaf3938`, `36ace0aa5`, re-landed on the wing-scoped
listing `ed1266e2f` · VM-21 `ea3b965af`, its line in main's class `ed1266e2f` · face polish `5681d8304` · VM-19
`615a12189`, `5ec59922c`, `839d86dd9` · the pins re-shaped to the one line `c652d1669`.

**The two traced findings, handed on.**
- **VM-24 — the phone editor's edit routing.** An unarmed edit (autocorrect, dictation, marked text, sometimes a
  typed character) is routed from the storage's report; when TextKit's attribute fixing widens that report past
  the block's terminator, the edit is refused and re-rendered away — the word just entered snaps back; stored text
  is never at risk. Its pin, `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`,
  stays red on main by decision. Its run: `notes/plans/vm-24-unwarned-edit-routing.md` (`f4fce656b`),
  `/architect-phase vm-24`, launched by the stage coordinator once wave 1 has merged, starting with a measuring
  session on her phone. It reads BATCH C's "WINDOW (3) — RESULTS" and "VM-24 — the mechanism, its reach, and the
  options", round 3's R3-F5, and the trace instruments in history (`a570d3960`, `fec0e478b`).
- **VM-17 — stray fan badges on a long note's stepped scroll.** Two mechanisms: a frame kept from a forced
  mid-document read that TextKit later moved; an on-screen badge read before TextKit placed its line. A settle
  measurement found an unforced read already placed at the first subview after the text view's own layout (118 of
  118). A first fix built on that moment (`15add793d`, `f869f8667`) went clean on the scroll and FAILED its window
  on the jump road; it was backed out (`b69d5d12e`, `feabe164c`) and the probe and the decor reading removed
  (`1981d4041`, `7d84e4b22`) — the takes chrome is main's. The block decor shares the rule and measured astray:
  VM-239. Its run: `notes/plans/vm-17-chrome-geometry.md` (`de3bb0107`), `/architect-phase vm-17 vm-239 vm-179`,
  hers to launch after wave 1. It reads BATCH C's "WINDOW (3) — RESULTS", BATCH D whole, and round 3's R3-F1,
  R3-F2 and "VM-17's fix — the shape, as called" — never assuming that shape right and merely unfinished.

**Her rulings** are quoted verbatim in Kickoff facts (the cap of five rounds that night; the night's frame; the
shelf order left to wave 3; the collect receipt kept; one wave-1 install after all four mobile runs), in the live
state (VM-24: "Own run after wave 1 (Recommended)" and her words to the stage coordinator), in BATCH D's "THE
WINDOW AND HER RULING" (VM-17: "Take it out, own run (Recommended)") and in the Closeout's "Her rulings built
here". Two PROVISIONAL calls wait for her: an archived gathering's "(archived)" mark, and F8 (Diverge on a
gathering's row) — QUESTIONS PENDING(the QUESTIONS number, at the merge).

**The evidence that matters.** Before the merge: windows (2) 68/6, (1) 84/16 plus the Mac's 110/17, (5) 75/10, F4's
4/1 and R2-N1's 11/2, each green after exactly its expected reds; window (3): the caret pin red as traced, VM-17's
probe red (35 astray · 35 misses · 9 bare), VM-19's pin red on the old teardown and green on the fix; batch D's
window: the fix not proved (eight reds; 17 bare on the jump road), the decor reading red. The back-out's check
(`79fa4d36d`); both targets build for testing on the merged tree (`c652d1669`, `8d2b9f8bf`). Five bundles are lost
or unreadable; the kept logs under `App/Variorum/DerivedData/logs/` are the evidence. Ladder: round 1 0 BLOCKER / 2
MAJOR / 6 MINOR / 11 NIT; round 2 0 / 0 / 3 / 5; round 3 0 / 1 / 5 / 3. PENDING(the re-land's stage window; ladder
round 4; gate 1, the whole phone target; gate 2, the Mac leg; gate 3, the simulator walk).

**Canon.** SurfaceContracts › The Bookcase and books: five clauses naming the phone (`786f50af9`). MobileSoul §6:
PL-77 (`e24e0fb81`). AppSpec §9 and OverallModel §3: the insured restore no longer PROVISIONAL (`3471d0ad4`; #274
addendum 2). TEXTKIT2_NOTES §3: the two iOS 26.2 facts measured here (`02a3ac002`).

**Open items.** The re-land's window, round 4 and the gate; the shared ledgers, the PR and its merge; her ratify
list and wording pass; the tickets to mint (the Closeout's list — VM-239 is minted); VM-24's and VM-17's own runs.
The remainders are carried by VM-24, VM-17, VM-239, VM-179, VM-175, VM-161, VM-113, VM-212, VM-85, VM-117, VM-94,
VM-218, VM-99 and VM-96's Trash face.

---

## The orchestrator's live state (kept current; a resuming session reads this first)

### CURRENT STATE — 2026-11-19, late morning (she is back). Read this block; what follows it is the night's log, kept as written.

**UPDATE — 2026-11-19, 14:45 (the newest; it outranks everything below it).** Step 1 of the 14:10 list is DONE:
the back-out and the merge-in are committed ("### THE MERGE-IN", tip `9ee926cb1`; merge commit `ed1266e2f` over
main `eb18888db`), both targets build on the merged tree, and the four chrome files equal main's. The re-land's
stage window is queued with the coordinator and has NOT run until a result is written here. The orchestrator's
context had passed the cutover guideline: `notes/plans/vm-78-orchestrator-handoff.md` carries a paste-ready
kickoff and the remaining steps for a successor.

**UPDATE — 2026-11-19, 14:10. This paragraph outranks the bullets under it wherever they differ.**
- **Batch D's window ran (12:21–12:28) and VM-17's fix FAILED it** (BATCH D, "THE WINDOW AND HER RULING"): the
  scrolling road went clean, but the jump road left the target fan with no badge, four jumps missed, and eight
  tests were red on the fix. The decor reading, run alone, was red as a measurement: callout washes, glyphs and
  comment marks stray the same way.
- **HER RULING (a dialog pick, 2026-11-19): "Take it out, own run (Recommended)"** — the unproven fix is backed
  out of VM-78 with a plain revert commit; the probe and the measurement tests leave the branch in named commits
  the tickets cite, so main gets no new red test; VM-17, the callout and comment finding (VM-239, minted) and
  wave 4's VM-179 become one run after wave 1, kickoff `notes/plans/vm-17-chrome-geometry.md`. VM-17 is re-owned
  out of this umbrella. **So this run closes on EIGHT proved members (VM-16 with VM-20, VM-43, VM-3, VM-84,
  VM-33, VM-81, VM-83, VM-21) plus VM-19's pin; VM-24 and VM-17 each go to their own run with this record as
  their evidence.**
- **VM-55 has merged** (main `eb18888db`, after VX-980). The merge-in is unblocked.
- **What remains, in order (this replaces the list below):**
  1. ONE implementer session: (a) the back-out — batch D's product and pin commits reverted, the probe and the
     decor reading removed, each in a named commit, checked by `git diff 76bfc56b6 -- App/` showing nothing left
     of batch D but the settle instrument's absence; (b) `origin/main` merged in by a merge commit — the five
     conflicted phone files resolved, `notes/MobileSoul.md` and `notes/SurfaceContracts.md` keeping BOTH runs'
     lines, this run's parity row renumbered to the next free number (PL-77 when this was written); (c) VM-16
     re-landed on VM-55's message seam and VM-81's sealed-Reopen sentence riding VM-62's table, the affected
     pins re-shaped and listed for a red/green window; (d) both targets built.
  2. A short stage window for the re-landed pins (red on the merged tree with the re-land reverted, then green).
  3. Ladder round 4 — a fresh `fable-reviewer` over the back-out and the merged tree's re-land. With batch D
     gone it reads no new editor-seam fix.
  4. The gate: the whole phone target on the merged tree (one standing red, VM-24's caret test, by decision) ·
     the Mac leg over the changed `Shared/` files · the simulator walk.
  5. The closeout documents re-fitted to this outcome (they were refreshed BEFORE the window and still describe
     VM-17's fix as built and pending), the two canon deltas named below, the shared ledgers at the merge
     moment, the PR.

- **Proved red on the old code and green on the fix, in stage windows:** batch B (VM-16 with VM-20, VM-43, VM-3,
  VM-84, VM-33), batch A (VM-81, VM-83, VM-21, and the Mac's 17 types over the hoisted words), every fix of
  ladder rounds 1 and 2 (F3, F4, F5, N2, R2-N1), and VM-19's teardown pin.
- **VM-24 is RULED** (her dialog pick and her words to the coordinator, both verbatim in the night's log below):
  its own run after wave 1, `/architect-phase vm-24`, launched by the coordinator once all four mobile runs have
  merged; kickoff `notes/plans/vm-24-unwarned-edit-routing.md`; the ticket re-owned out of this umbrella. **This
  run builds no VM-24 fix, and the caret test stays red and unwrapped on main by decision.** Wherever this file
  still says "held for the author" about VM-24 (batch C's LIVE STATUS row, the intro of "VM-24 — the mechanism,
  its reach, and the options", batch D's brief), read: ruled 2026-11-19, its own run after wave 1.
- **VM-17's fix is BUILT, not yet proved** (batch D, "The build — LIVE STATUS": pins `15add793d`, fix
  `f869f8667`, the decor reading `211221f6b` and `75984c0e6`). It is built to the shape ROUND 3's reviewer called
  from the settle measurement — viewport-scoped geometry and a second geometry walk inside the same layout pass
  — not to round 1's pre-confirmed shape, which reached only one of the two mechanisms the trace found. Round 4
  reads it (the night's log below says "round 3"; that was before batch D stopped at its trace).
- **Queued on the stage, READY with the coordinator:** batch D's window, run by the orchestrator from the
  throwaway checkout — RED (`MobileTakesChromeTests` on the old chrome; exactly three reds expected:
  `perTickRefreshResolvesOnlyNearViewportGeometry`, `aKeystrokesChromePassIsEditScopedAndWriteFreeWhenNothingMoved`,
  `aFarFlipDrawsNoMarkerOrPillUntilItsBlockScrollsIn`), GREEN (the probe, which must turn green, plus the chrome
  types: `MobileTakesChromeTests`, `MobileWalkTests`, `MobileConflictDiscoveryTests`,
  `MobileTakesBrowserSurfaceTests`, `MobileTutorialTakesWalkTests`, `MobileTutorialLibraryWalkTests`,
  `MobileBlockListTests`, `MobileBlockDecorTests`, with `MobileBlockMenuTests` optional — batch D's build
  corrected round 3's "nine types" to this list), then `MobileDecorPlacementReadingTests` ALONE. Pre-decided arm
  if the probe still shows only the 74-pt class: the anchor moves to `insertSubview(_:at: 0)`, rebuilt, re-run;
  any other probe red, or a badge red inside the decor reading: stop and report.
- **The ladder:** rounds 1, 2 and 3 are closed with every finding dispositioned. Her ruling was "tonight, up to 5
  review rounds as long as a major is found"; round 3 found a MAJOR, so round 4 is earned under it and is owed by
  round 1's F1 in any case. Round 4 runs under that allowance and she is told; a round 5 would be hers to allow.
- **What remains, in order:**
  1. Batch D's window; then flip batch D's rows, remove the decor reading's file in a named commit, and write the
     decor ticket (to mint on VM at the closeout: Bug · Confirmed · Editor · High if the reading is red — the
     fan badge's own class and priority; no ticket and R3-F1 closes hollow if it is green).
  2. The merge-in, behind VM-55 (VX-980 is already on main, `359ae214d`): `origin/main` into this branch by a
     merge commit; `notes/MobileSoul.md` and `notes/SurfaceContracts.md` keep BOTH runs' lines; this run's parity
     row takes the next free number; an implementer re-lands VM-16 on VM-55's message seam and resolves the
     Book Details, Shelf, Trash and Membership conflicts, its pins shown red and green again. On the merged tree
     the orchestrator applies two canon deltas and names both in the handoff for her eyes: dropping
     "PROVISIONAL" from the insured restore in AppSpec §9 and OverallModel §3 (QUESTIONS #274 addendum 2), and
     the iOS 26.2 facts this run measured into `notes/TEXTKIT2_NOTES.md` §3 (a mid-document forced layout leaves
     estimates behind; inside the layout pass, after the text view's own layout, the unforced read is settled).
  3. Ladder round 4 — a fresh `fable-reviewer` reads batch D's fix against the called shape, its window, and
     VM-16 re-landed, in one round.
  4. The gate, three claims: the whole phone target (the probe green again on the merged tree; the caret test the
     one standing red, by decision) · the Mac suites over `Shared/ShelfOrder.swift`, `Shared/BookcaseBoard.swift`
     and the BookStateCopy hoist on the merged tree · the simulator walk.
  5. The closeout's slots, the shared ledgers on latest main at the merge moment, `Tools/canon-size`, the PR
     `VM-78: …` merged as a merge commit at the coordinator's GO, the in-flight row retired, the worktrees and
     the branch removed.
  6. If this run is the last mobile merger: the wave-1 phone install is prepared (the device build from merged
     main and a paste-ready kickoff). Then the coordinator launches VM-24's run.
- **For her sitting:** the two PROVISIONAL calls (an archived gathering's add row wearing "(archived)"; no
  Diverge on a gathering row on the phone — F8's question); the wording pass; the tickets to file, now including
  the decor's; the two canon deltas named in step 2; and, at VM-24's run, the session on her phone.

### The night's log of this section (2026-11-19, as written at the time)

*As of 2026-11-19 07:30, tip after the closeout drafts (`7cb529765` and this commit). The author is away until
morning; nothing is held for her hands yet. The closeout's writing is DRAFTED with PENDING slots (this file's
Closeout and FOR A LATER READER, five phone clauses in `notes/SurfaceContracts.md`, `notes/MobileSoul.md` row
PL-75, `notes/handoffs/vm-78-handoff.md`); what remains is filling the slots as the steps below land. One canon
delta is PROPOSED and not applied — dropping "PROVISIONAL" from the insured restore in AppSpec §9 and OverallModel
§3, per QUESTIONS #274 addendum 2 (Closeout, "Canon delta proposed"): the orchestrator applies it on the merged
tree at the closeout, and the handoff names it for her eyes.*

**WINDOW (3) RAN (08:39–08:50; BATCH C's LIVE STATUS, "WINDOW (3) — RESULTS", `6b214ad67`) AND THE ORCHESTRATOR'S
DECISIONS ON IT (2026-11-19 09:00):**
- **VM-17 is REAL** (the probe's reading 1 green — no pile at block 1; readings (i), (i′), (ii) red on the stepped
  walk, identically twice: stray badges in the viewport, one 1,260 pt from its own block, several 74 pt off their
  line; the jump road clean; reach complete). By the batch's arm no product line was touched in the window. **It
  is fixed in this run, as BATCH D** (below the batches): the reviewer's pre-confirmed fix shape (round 1, F2's
  final call — an off-band badge does not stand), the probe as its pin (already seen red on the unfixed chrome),
  green in a short window, then read by ladder round 3.
- **VM-24: no pre-decided arm mapped, and the decision is: NOT test posture.** Arm A's fix (a wait in the caret
  suite's `host`) is REFUSED — it would turn the test green by avoiding the condition, not by removing the hazard.
  The trace killed H1 (the caret settle writes nothing inside the transaction) and showed the mechanism: on this
  road the edit gate is never consulted, so the replace reaches `storageDidEdit` unarmed and is routed from the
  storage's own report; when TextKit's attribute fixing widens that report past the block's terminator,
  `fallbackVerdict` refuses a plain in-block replace and desync recovery re-renders from the store. That is a
  product mechanism in the editor's edit routing. **The red test stays red and unwrapped — it is the pin.**
  **HER RULING (2026-11-19, the morning; a dialog pick in this session, no prose): "Own run after wave 1
  (Recommended)"** — VM-24 becomes its own short run on merged main as soon as all four mobile runs have merged,
  before wave 2; it starts with one session on her phone counting how often unwarned edits and snap-backs occur,
  so the fix has before-and-after numbers; in VM-78 the ticket stays open, the test stays red and unwrapped as
  the pin, and this record's trace is its record. Her words to the stage coordinator the same morning, verbatim:
  "I chose the own run after wave 1 option that vm-78 proposed. i want you to message them about this to lock
  the plan down, but basically i want you to open a new session in tmux once wave 1 is done and merged, and tell
  it to architect-phase that issue, reporting to you for stage details. just kick that off when wave1 is done
  for me." So: **VM-78 builds no VM-24 fix.** The later run's kickoff is `notes/plans/vm-24-unwarned-edit-routing.md`
  (committed with this line); the VM-24 ticket is re-owned out of this umbrella (un-parented, Todo, Area Editor,
  retitled, related to VM-64 and VX-68, a comment carrying the mechanism and her decision), so this run's
  closeout cannot close it. What she was told before choosing (the coordinator's facts): no session is fixing
  VM-24; the other reds being repaired that night were each run's own new tests or code; VM-64's flight fence
  handles the same kind of unwarned edit in the same file. What follows below is the reasoning as it stood
  before she ruled.
  **The fix is NOT written in this run tonight**: it is an editor-seam change, not a small fix; another wave-1 run
  (VM-64) holds editor-seam work in the same file this wave; and the author is away. What happens instead: a
  read-only REACH read (which roads on her phone can arrive unarmed with a widened report) and the fix options
  are written into BATCH C; the decision — fix it here as its own batch with its own Fable round, or hand the
  mechanism to the seam's umbrella — is HELD for her sitting. VM-24 stays open; nothing is wrapped as a known
  issue.
  **Its reach, as written up after the window (BATCH C, "VM-24 — the mechanism, its reach, and the options",
  `65fe3a114`):** by the code's own account and an earlier device capture, autocorrect, predictive replacement,
  dictation and marked-text commits reach `storageDidEdit` without the gate. Return, Tab and the markdown acts arm
  at the call; a typed character is asked about but can land unarmed behind a keyboard transaction (E1 #50–#52 —
  round 3's R3-F5 corrected the first reading, which had typing as armed). So ORDINARY TYPING is on this road
  too in some keyboard transactions. What she would see when a widened report meets one of those roads: the
  character or word just put in snaps back, with a re-render flicker; stored text is never at risk. For the
  options this means: arming the visible roads cannot cover an arming spent before its edit lands, while routing
  from the pre-fixing range does not depend on the arming at all. How often fixing widens the report
  on a device is unmeasured. This looks like one mechanism with VX-68 (the gate-less insertion watch row). So
  the held decision is a real one, and it leads the handoff.
- **VM-19:** its pin is proved (red on the hide-only teardown at `615a12189`, green on the fix); the desync itself
  did not reproduce on this toolchain (M4, four cases); the pin stands as test hygiene.
- **The instruments leave now** (round 1's F7): the three trace suites and the cost note are removed in a named
  commit before any further window — their traces and numbers are in the record, and the commits that carried
  them stay in history for whoever fixes VM-24.

**Done and proved (red on the old code, green on the fix, in a stage window):** batch B — VM-16 (+VM-20), VM-43,
VM-3, VM-84, VM-33 (window 2); batch A — VM-81, VM-83, VM-21, with the Mac's 17 types over the hoisted words green
(window 1); ladder round 1's fixes — F3, F5, N2 (window 5) and F4 (its follow-up). Ladder rounds 1 and 2 are
closed with every finding dispositioned ("The ladder").

**Queued on the stage (nov18 schedules; READY sent for both):**
1. ~~Batch C's matrix, window (3)~~ — RAN 08:39–08:50 (above).
2. ~~R2-N1's pin~~ — RAN 07:19–07:24 and proved (red on the pre-fix file, green on the tip; the fix stands).

**Then, in order:**
3. Read window (3)'s trace with the runner's report and DECIDE THE ARM for VM-24 (the orchestrator's decision
   where the arms do not map — BATCH C, "Combinations no arm maps"); VM-17 is hollow only if (1), (i), (i′), (ii)
   are all green; VM-19's pin red-on-old and green.
4. Any fix the arm calls for is written and built headless, then proved in a second short window. A product
   mechanism in the editor is reported, never fixed in passing (editor seam).
5. The instruments' removal BEFORE any whole-target run (round 1's F7): the three trace suites and the cost note
   are out (`16c75a5bf`); `MobileFanBadgeSettleMeasureTests` and the decor reading leave in named commits too
   (round 3's R3-F6, R3-F1). **The rule for the red probe:** `MobileFanBadgePlacementProbeTests` is VM-17's pin
   and is red on the tip until batch D's fix lands. If that fix does NOT land in this run, the probe file leaves
   the branch in a named commit VM-17's ticket cites — never a second standing red on main without the author's
   word, never wrapped as a known issue.
6. **Ladder round 3** — a fresh `fable-reviewer`, owed by round 1's F1 whatever round 2 found: it reads window
   (3)'s outcome and the removal, reading (i′) and its run, R2-N1's fix and its red/green, R2-F2's lines, and
   VM-16 re-landed (step 7) if that has happened by then. Cap: five rounds tonight, each further one earned by a
   new BLOCKER or MAJOR.
7. **The merge behind vm-55** (nov18 serializes; ask it first): take `origin/main` into this branch with a merge
   commit once vm-55 has merged; an implementer re-lands VM-16 on vm-55's message seam (Kickoff facts, "A known
   merge conflict") and resolves the Shelf and refusal-site conflicts; its pins shown red and green again.
8. **The gate, three claims** (nov18's split): the whole phone target · the Mac suites over the changed `Shared/`
   files on the merged tree · the simulator walk through the changed faces (the walk rows are in batch A's and
   batch B's LIVE STATUS, plus N9's medium-detent row).
9. **Closeout** (CLAUDE.md's ritual): this file's FOR A LATER READER and Closeout; the canon deltas in the
   two-file shape; `notes/MobileSoul.md`'s parity row; `notes/QUESTIONS.md` (the PROVISIONAL bundle and F8's
   question) and the born tickets, on latest main at the merge moment; `Tools/canon-size`; the handoff
   `notes/handoffs/vm-78-handoff.md`; the PR `VM-78: …` merged as a merge commit at nov18's GO; the in-flight
   row retired; this worktree, the pins checkout and the branch removed.
10. **If this run is the last of the four mobile runs to merge:** prepare the single wave-1 phone install — the
    device build from merged main and a paste-ready install kickoff for a fresh session (her ruling, Kickoff
    facts). The install itself is her hands, in the morning.

**For her sitting (bundled; nothing here blocks the run):** the PROVISIONAL calls (an archived gathering's add
row wearing "(archived)"; the phone drawing no Diverge on a gathering row — F8's question); the drafted words
for her wording pass (VM-3's lesson, F4's shelf-lesson sentence, the create sheet's three gathering lines, the
sealed book's Reopen sentence on the phone, whether the collect receipt line stays); the lines for other
owners (VM-62's sweep, VM-113's kickoff, VM-212's guide rewrite, the phone's VoiceOver pass) and the tickets
to file (N10's first-paint shapes in the Archive room and a book's contents; the core `Queries.bookshelf` doc
line).

**Machinery a resuming session needs:** the stage protocol and the simulator are in Kickoff facts; every
window's log is under `App/Variorum/DerivedData/logs/` and its result bundle under
`App/Variorum/DerivedData/vm78-bundles/` (both local, gitignored); the orchestrator's window scripts are
throwaway instruments in its session scratchpad and are re-derivable from each batch's recipe.

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
| R2-N1 (VM-81) | DONE — pin `01205f799`, fix `97282e72f` (the four act rows on `MobileBookDetailsSheet` keep the verb as their label and carry the caption they draw as `.accessibilityHint`, unvoiced: Finish/Reopen `finishCaption(for:)` · Unarchive `pausedSentence(for:)` when it has one, else none · Archive `archiveDailyJournalDetail` · Delete `deleteBookKeepsItsNotes`; no new words); phone `build-for-testing` GREEN; red on the pre-fix file and green on the tip VERIFIED in its own window (claimed 07:19:38, released 07:23:59: RED 11 tests in 2 suites with this pin the only red, GREEN 11/2; the hosted driver reads a SwiftUI hint, so the fix stands; `r2n1-red.xcresult` unreadable, its log kept) | `MobileBookStateRowTests/theBookDetailsRowsSpeakTheirCaptionsAsHints` |
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

**WHAT IS NOT DONE (first, as the contract asks):** no fix of any kind in this batch — VM-24's seam fix is HELD for
the author (the orchestrator's decision, "The orchestrator's live state"), VM-17's fix is batch D's. The trace
instruments LEFT the tree in their named commit (round 1's F7; restorable from `a570d3960` + `fec0e478b`). **Window (3) RAN AND CLOSED:** claim `vm-78` 08:39:53 → released 08:50:46, the
whole matrix plus one M5 re-run, no run killed the host, no new `Variorum*.ips`, no Problem Reporter, the simulator
shut down, no instance left. M9's red leg ran on `MobileLivenessTests.swift` at `615a12189`; the file is restored by
`git checkout HEAD --` and `git status` is clean: **no revert is in flight.** No hand-break is in flight. No product
line changed.

*Implementer: `opus-implementer`, session of 2026-11-19. Half 1 = read, trace, instruments, a green `build-for-testing`
(no stage); half 2 = the orchestrator's GO window.*

| Member | State | Pin / instrument (TYPE name for `-only-testing`) |
|---|---|---|
| VM-24 | **OPEN — traced, HELD for the author.** Not test posture (arm A's wait refused); a product mechanism in the edit routing (the gate-less road meeting attribute fixing's widened report — the results below and "VM-24 — the mechanism, its reach, and the options"). The red test stays red and unwrapped as its pin. No fix | the pin: `MobileMarkdownCaretTests` (red) · the instruments `MobileCaretReplaceTraceTests` / `MobileCaretReplaceTeethTraceTests` left the tree (history: `a570d3960`, `fec0e478b`) |
| VM-19 | **DONE.** PIN VERIFIED — `615a12189` RED on the hide-only teardown (M9-red: exactly the VM-19 expectation, `:1087`), GREEN on the fix `5ec59922c` + N5 `839d86dd9` (M9-green, 18/18); the desync itself **not reproduced on this toolchain** (M4: no desync in any of the four cases) — the pin stands as test hygiene | pin: `MobileLivenessTests` (`arrivalRaisesFocusBeforeTheObservationLoops`'s VM-19 expectation) · the instrument `MobileStaleResponderTraceTests` left the tree (history: `fec0e478b`) |
| VM-17 | **REAL — its fix is batch D's** (a fresh implementer). Probe written `a570d3960`, re-shaped to round 1's F2 final call `e3f406086`, (i′) added by round 2's R2-F3 `78179b765`; **REAL by the record's arm — STOP AND REPORT, no product line**: (i), (i′) and (ii) red on the stepped walk (35 · 35 · 9), seen twice alone (M5, M5b); the pile and reach green; the jump road clean | the pin: `MobileFanBadgePlacementProbeTests` (`noFanBadgePilesAndNoneStandsAstrayInTheViewportOnALongNote`, red on the unfixed chrome — batch D turns it green) · its cost note left the tree (numbers above; history: `a570d3960`) |

**WINDOW (3) — RESULTS (2026-11-19, claim `vm-78` 08:39:53–08:50:46, the standing iPhone 17 Pro / iOS 26.2
simulator booted fresh by id; other sessions were building on this Mac throughout, so no machine was quiet).** Products:
M1–M7 by `test-without-building` against `DerivedData/vm78-ios`, built at the code of `97282e72f` (the tip's code:
every later commit is a record); M9's two `xcodebuild test` legs rebuilt the one liveness file. Every log is kept in
`App/Variorum/DerivedData/logs/vm78-c-<run>.log`, every bundle in `DerivedData/vm78-bundles/c-<run>.xcresult`, every
`xcodebuild` exited by itself within 5 s of its verdict, `Restarting after unexpected exit` = 0 in every log.

| Run | Swift Testing verdict | Reds, by name | Bundle |
|---|---|---|---|
| M1 caret suite alone | 4 tests in 1 suite **failed**, 2 issues (164 s, the fresh boot's first launch) | `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` "hi", "hello there" — `desyncRecoveryCount == 0` (`:215`) — **by design** | reads (4 · 3 passed · 1 failed) |
| M2 `MobileCaretReplaceTraceTests` | 3 tests in 1 suite passed | — | reads |
| M3 `MobileCaretReplaceTeethTraceTests` | 1 test in 1 suite passed | — | reads |
| M4 `MobileStaleResponderTraceTests` | 1 test in 1 suite passed | — | reads |
| M5 `MobileFanBadgePlacementProbeTests` | 2 tests in 1 suite **failed**, 3 issues | `noFanBadgePilesAndNoneStandsAstrayInTheViewportOnALongNote` — `astray.isEmpty` (`:394`), `misses.isEmpty` (`:396`), `bare.isEmpty` (`:398`) — VM-17's decision (below) | reads |
| M5b the same, re-run alone | 2 tests in 1 suite **failed**, 3 issues — identical, every count | the same three | reads |
| M6a, M6b caret suite alone | each 4 tests in 1 suite **failed**, 2 issues | the same two cases as M1 — **by design** | both read |
| M7 liveness + caret | 22 tests in 2 suites **failed**, 2 issues | the same two caret cases as M1 — **by design**; every liveness test green (the VM-19 expectation included); nothing beyond M1's two | reads |
| M9-red (`MobileLivenessTests.swift` at `615a12189`) | 18 tests in 1 suite **failed**, 1 issue | `arrivalRaisesFocusBeforeTheObservationLoops` — `!surface.textView.isFirstResponder` (`:1087`) — **by design**; no extra liveness red | reads |
| M9-green (restored) | 18 tests in 1 suite **passed** | — | reads |

**VM-24 — what the trace shows** (`grep -E 'VM24\|' vm78-c-M2.log`, `vm78-c-M3.log`; lines quoted without stacks):
- **No gate consult on this road, in any case.** Every act's E1 reads `consults=0 … gateless=1` — e.g.
  `suitePosture|hi|#1|E1 #1 EDIT at 1 len 5 Δ-3 after 0 gates ⚠ gate-less` then `E1 #2 ⟳ DESYNC RECOVERY`; the gate
  proxy printed no `gate` line in M2 or M4. The replace's stack: `-[UITextView replaceRange:withText:]` <
  `-[UITextInputController replaceRange:withText:]` < `-[UITextInputController _replaceRange:withAttributedTextFromKeyboard:…]`
  < `-[NSTextStorage coordinateEditing:]` < `endEditing` < `processEditing` — no `shouldChangeTextIn` on it. So every
  report reaches `storageDidEdit` unarmed and routes by `fallbackVerdict`. (M4's four `insertText` acts are gate-less
  too. The house helper `typeEdit`, `MobileEditorTestSupport.swift:82-103`, calls the gate itself for exactly this
  reason; whether her device's keyboard roads consult it is not shown by this window.)
- **The red follows the report's range.** In-act character reports, `willProcess` → `didProcess`:
  suitePosture "hi" `{1,2}` → `{1,5}` (both worlds, desync 1); "hello there" `{1,11}` → `{1,14}` (both, desync 1);
  "Hello" #1 `{1,5}` → `{1,5}` (desync 0) but #2 `{1,5}` → `{1,8}` (desync 1). realPosture: every case exact
  (`{1,2}`, `{1,11}`, `{1,5}`), desync 0 in all six. settleHeld: "hi" `{1,5}` and "hello there" `{1,14}` widened,
  desync 1; "Hello" exact, desync 0. The widening happens INSIDE `processEditing` (willProcess exact, didProcess past
  the terminator) — attribute fixing (TEXTKIT2 §3). Exact, `fallbackVerdict` gets the old range `(1,5)` → `.block(0)`;
  widened, `(1,8)` crosses the separator at 8 → `.refuse` → `desyncRecovery`.
- **The settle is not involved.** No `WROTE-INSIDE-TRANSACTION` in any M2 case; the in-act `sel`/`chg` come AFTER the
  edit's `processEditing` (`sel ACT sel={3,0} maskBefore=none maskAfter=none processedDuring=1` — its write is its own
  transaction, after the desync); `settleHeld` is red with the settle held. M3 shows the converse: the settle's write
  forced INSIDE the replace's transaction (`settleWroteInside=true`, report `{0,5}` / `{0,8}` / `{0,14}`) desyncs
  NOTHING (`desync=0` in all six) — round 2's R2-F2 second column, shown by a run: without the widening an
  in-transaction write routes as `.block(0)`.
- **Posture.** At the act both postures show the test window key and on the scene, the view first responder, `editable`,
  `viewMode=en-US`, `modes=["en-US","emoji"]`, `gcKeyboard=true` (a hardware keyboard connected), all text traits
  default. suitePosture: no keyboard notification (`willShow=0`). realPosture: `waited spins=300` in five of six cases
  (only "Hello" #1 settled, at 62) — `keyboardWillShow end=0,822 402x363`, then `keyboardWillShow end=0,822 402x52` (the
  hardware keyboard's bar), one `keyboardDidShow`: willShow 2, didShow 1, never agreeing.

**VM-24 — the arm, by the record's own rules: NO PRE-DECIDED ARM MAPS — the orchestrator decides.** (1) H1's
confirmation is not met (no in-transaction write; the report starts at 1; `settleHeld` red) — "M2 shows no
in-transaction write and `settleHeld` still red ⇒ H1 killed; read H4 and the stacks for the writer": H4's read is zero
consults, and the writer of the range that decides the red is `NSTextStorage`'s own attribute fixing. (2) R2-F2 line
one: `realPosture`'s `waited spins=300` ⇒ its posture was not reached ⇒ no arm. (3) R2-F2 line two: within ONE posture
"Hello" #1 (`{1,5}`, green) and #2 (`{1,8}`, red) differ only in the report's range ⇒ fixing's widening, neither arm.
**The runner's PROPOSED READING (for the orchestrator; not a ruling):** the standing red is a property of the product's
gate-less road, not of the caret settle and not of key or first responder: an edit that reaches `storageDidEdit`
without an arming is routed by `fallbackVerdict` from the storage's report, and attribute fixing can widen that report
past the paragraph's terminator, after which the fallback refuses a plain in-block replace and `desyncRecovery`
re-renders from the store — where the replace was never autosaved, so (by reading `desyncRecovery`, `:2016-2032`; the
trace reads the surface before the heal and does not show it) the replaced words go back to the old ones on the
surface. Which reports get widened is TextKit's (paragraph-style object identity, TEXTKIT2 §3 18k C8): here,
widened in five of six acts in the same turn as `becomeFirstResponder`, exact in all six after the waited turns and the
keyboard bar, and not stable across iterations in one posture. So it reads as arm B's protocol (a product mechanism;
stop, no seam line touched), with reach as the ruling's question: whether any road her phone takes arrives unarmed
(the gate's own comment expects autocorrect, dictation and marked text to) AND with a widened report. The fallback's
widening blind spot is in `MobileEditorViewModel.fallbackVerdict` (`:1962-1972`); the test's own posture is NOT shown
to be the cause, so arm A's fix (waiting in `host`) would make the test green by avoiding the widening, not by
removing the hazard.

**VM-19 — M4 and M9.** M4: no desync in any of the four cases (`frameWindow|polluted`, `frameWindow|clean`,
`sceneWindow|polluted`, `sceneWindow|clean`; every report `{1,6}`, gate-less). The polluter was gone by the act in the
frame-window case (`alive=false`) and alive and still first responder in the scene-window case (`alive=true fr=true`),
with no desync either way. By the record's rule: **"not reproduced on this toolchain"**; the pin stands as test
hygiene. M9: **RED on the hide-only teardown, GREEN on the fix** — the pin is real; no extra liveness red in M9-red.

**VM-17 — M5 (and M5b, identical).** (1) THE PILE: green — no two badges coincide, none at block 1. (2) THE
MEASUREMENT (never asserted): `offscreenDrawn=21 offIdeal=21 largest=9276.0 mean=4716.0` (points) — the load-time
estimates for off-screen badges stand thousands of points off the idealized layout; the walk's live content height
33,812 pt. (i) **35 astray**, (i′) **35 misses**, (ii) **9 bare** — ALL on the stepped walk (61 stops); the jump road
(22 jumps) 0 · 0 · 0. (iii) REACH green: `walkReached=22/22`, `jumpMissed=0`; (i′) asked 76 (walk 54, jump 22),
skipped 0. Samples: `walk#7@3920 @6890 badge=4581.75 line=4655.75` with (i′) `stands beside the fragment at @6537`;
`walk#8@4480 @9190 badge=4683.0 line=5943.0` with (i′) `stands beside the fragment at @6890` (a badge 1,260 pt from
its own block, beside another block's text); bare `walk#10@5600 @9190 line=6207.0 badge=6133.0 drawn=true` (a fan on
screen whose badge stands 74 pt above it — several bare and astray lines share that 74-pt offset). **The arm, by the
record's rules: (i), (i′) and (ii) red ⇒ VM-17 is REAL — STOP and report before any product line.** The fix shape the
reviewer would confirm is written in the arm (resolve in-band badges only; hide a badge as its block leaves the band);
nothing is built. The HOLLOW reach sentence does not apply. COST NOTE (VM-179's, prints only): 150 blocks — loadOnce
0.032 s unfanned vs 0.032 s with 22 fans; the `.document` chrome pass cold 0.11 ms vs 1.81 ms, warm 0.05 ms vs 0.30 ms.
600 blocks — loadOnce 0.116 s vs 0.122 s with 86 fans; the pass cold 0.31 ms vs 6.02 ms, warm 0.19 ms vs 1.24 ms.

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

#### VM-24 — the mechanism, its reach, and the options

*Written for the author's decision, read-only analysis (no product or test line changed). The orchestrator's decisions
stand: not test posture; arm A's wait refused; the red test stays red and unwrapped as the pin; the seam fix is HELD for
her. "SEEN" = shown by window (3)'s trace (`DerivedData/logs/vm78-c-M2.log`, `-M3.log`, kept locally); "BY READING" =
from the code, not observed.*

**The mechanism, link by link.**
1. A system edit arrives through UIKit's text-input door: `UITextView.replace(_:withText:)` →
   `UITextInputController replaceRange:withText:` → `_replaceRange:withAttributedTextFromKeyboard:…` →
   `NSTextStorage coordinateEditing:` (SEEN: the call stack of every replace in M2).
2. That door never asks the editor's gate. The gate is the text-view delegate's `shouldChangeTextIn`
   (`MobileEditorViewModel.swift:2362-2372` → `shouldChangeText`, `:1541`), and the trace recorded zero consults on
   every replace (SEEN: E1 `consults=0 … gate-less` in all 18 M2 acts and all 6 M3 acts). The repo had measured this
   before on the same door (mobile round 2's M25, `notes/plans/mobile-round-2.md:2396-2409`: `deleteBackward()` and
   `replace(_:withText:)` "mutate the storage WITHOUT consulting the delegate at all").
3. So the edit reaches `storageDidEdit` (`:1828`) with no arming, and its block is decided by `fallbackVerdict`
   (`:1882`, `:1962-1972`), which recomputes the verdict from the storage's own report of the edited range
   (BY READING).
4. That report can be WIDENED by TextKit's attribute fixing, which re-applies the paragraph's style across the whole
   paragraph, terminator included (TEXTKIT2 §3, the iOS 26 fixing finding). SEEN: for "hi" the storage's
   `willProcessEditing` range is `{1,2}` (exactly the change) and its `didProcessEditing` range `{1,5}` — the same edit,
   widened inside `processEditing` past the line's newline.
5. Exact, the fallback's old range is `(1,5)` — inside block 0 — and the edit routes normally (SEEN: every
   `realPosture` case, desync 0). Widened, the old range is `(1,8)`, which reaches the separator at offset 8, so
   `index.verdict` refuses it as crossing a block boundary (SEEN: desync 1 in every widened case; the refusal itself BY
   READING, `BlockRangeIndex.verdict` through `:1968-1971`).
6. A refused route takes `.refuse` → `recoverFromUnroutableEdit` → `desyncRecovery` (`:1927-1932`, `:2011-2032`),
   BEFORE `recordAutosave` runs (`:1901`), so the replacement is never queued for saving (BY READING).
7. `desyncRecovery` flushes the autosaves already pending (`:2025`), re-reads the note from the store (`:2026-2028`) and
   re-renders the surface from it (`ingest` with `forceFullRender`, `:2020`, `:2029`). The store never received the
   replacement, so the re-render puts back the words she had before it (BY READING; the trace reads the surface before
   the heal, `post-act string="*hi *"`, and does not observe the heal).
The caret settle plays no part (SEEN: no write inside the transaction in any M2 case; the red persists with the settle
held; M3 forces the settle's write inside the transaction and nothing desyncs without the widening).

**The reach — which roads on her phone can deliver an edit to `storageDidEdit` UNARMED.** By reading the phone's code:
| Road | Armed? | Evidence |
|---|---|---|
| Keyboard typing (a character key) | **Asked, but not thereby armed when it lands** (round 3, R3-F5) | UIKit consults the delegate for a typed character, and the arming is spent at the first storage report that follows, whether or not that report is the keystroke (`MobileEditorViewModel.swift:1855-1856`). When the keyboard lands a transaction of its own first, the typed character is routed unarmed by `fallbackVerdict`: her iPhone recorded exactly that in ordinary use (E1 #50–#52 — armed at 178, a different edit at 177 rejected the arming, the insert at 178 "after 0 gates"; `notes/plans/mobile-round-2-crash-trace.md:8-24`). The editor's `insertText` override (`MobileEditorTextView.swift:1014-1020`) adds no gate of its own |
| Return key | Armed by the product | `MobileMarkdownActs.handleReturnKey` arms before `super.insertText("\n")` (`MobileEditorTextView.swift:1016`; the arming named at `EditorEditRouting.swift:37-39`) |
| Tab / ⇧Tab and the bar's markdown acts | Armed by the product | `performTabKey` calls `gateAllows` before `super.insertText("\t")` (`MobileEditorTextView.swift:1032-1034`); every act goes through `MobileMarkdownActs.inputReplace`, which calls `gateAllows` first, then `insertText`/`deleteBackward` (`MobileMarkdownActs.swift:38-75`) |
| The product's programmatic slot/tail writes | Not routed at all | `programmaticReplace` sets `suppressEditProcessing` (`MobileEditorViewModel.swift:2107-2125`); `storageDidEdit` returns early for them (`:1837-1842`) |
| Autocorrect and predictive replacement | **UNARMED — by the code's own account** (the capture's `#52` line is the TYPED insert, row above — R3-F5) | the model's header: system paths "never consult the gate (autocorrect, dictation, marked text)" (`MobileEditorViewModel.swift:24-31`); the identity note names "autocorrect via `replace(_:withText:)`" (`:13-16`); the device walk's legend reads gate-less edits as "just autocorrect and dictation, and it is expected" (`mobile-round-2-device-walk.md:154-155`) |
| Dictation | **UNARMED**, same sources | as above; the spike's dictation case was a proxy only (`Spike/SpikeScenarios.swift:657-669` — "the real path is a device item") |
| Marked-text commits (the QWERTY candidate bar, CJK input) | **UNARMED**, same sources | as above (`:24-31`) |
| The spelling "Replace…" menu | Not established | the phone draws no spelling road of its own (`MobileEditorTextView.swift:936-947` leaves spell-checking alone); the system's menu replace is UIKit's |
| Paste | Expected armed — the code assumes it | the gate reads `isPasting` (`MobileEditorViewModel.swift:2371`, the paste override `MobileEditorTextView.swift:1097-1100`), which only means anything if UIKit consults the delegate for a paste; not measured here |
| Find's replace | Off | `supportsTextReplacement` is `false` (`MobileEditorTextView.swift:1074`) |

**What Apple's documentation says about the system-originated roads** (one read-only lookup, 2026-11-19; quotes from
developer.apple.com):
- `UITextViewDelegate.textView(_:shouldChangeTextIn:replacementText:)`: "The text view calls this method whenever the
  user types a new character or deletes an existing character." It never says whether programmatic or system edits
  call it. Its page metadata marks it deprecated at iOS 27.0, not in iOS 26.
  (…/uitextviewdelegate/textview(_:shouldchangetextin:replacementtext:))
- The iOS 26 ranges variant, `textView(_:shouldChangeTextInRanges:replacementText:)`: "If the delegate does not
  implement this method then the textView:shouldChangeTextInRange:replacementText: method will be called and passed the
  union range instead." So the phone's single-range gate is still the one UIKit calls, whenever UIKit asks at all.
- `textViewDidChange(_:)`, for contrast: "This method is not called in response to programmatically initiated changes."
- `UITextInput.replace(_:withText:)` ("Replaces the text in a document that is in the specified range") and
  `UIKeyInput.insertText(_:)` say nothing about the delegate.
- **Autocorrection, predictive text and inline predictions, dictation, the spelling menu, paste, Writing Tools:
  documentation is silent on whether any of them consults `shouldChangeTextIn` before the change.**
  - Dictation: the `UITextInput` page says only that "the system automatically inserts recognized phrases".
  - Writing Tools (WWDC24 session 10168): it "relies on the UITextInput protocol to read and write the text", and it
    alters the text storage.
  - Forum posts (not documentation, unconfirmed by Apple): one says autocorrect does not reach `shouldChangeTextIn`.
- `fixAttributes(in:)`: "assigns the first paragraph style attribute value in each paragraph to all characters of the
  paragraph. This method extends the range as needed to cover the last paragraph partially contained." Apple does not
  document that the range reported to `didProcessEditing` grows with it. That growth is this repo's measurement
  (TEXTKIT2 §3), seen again here (`{1,2}` → `{1,5}`).

Only a device run settles which system roads reach the storage unarmed. Her own device has already shown that some do
(the 26.6 capture above).

**How often the widening happens — what decides it.** TEXTKIT2 §3 records two facts. On iOS 26, fixing re-propagates
the paragraph's governing style across the whole paragraph, terminator included (probe-verified). On macOS 27 (18k C8),
whether fixing CHANGES anything is decided by object identity: when the edited characters already carry the very
paragraph-style object fixing would apply, nothing changes and the report stays exact (`{2,1}`, not `{2,5}`), and
content-equal attribute dictionaries are uniqued process-wide, so any other text stack in the process can change the
answer. Window (3) is consistent with that and adds a frequency picture for this host only: widened in five of six
replaces made in the same turn as `becomeFirstResponder`, exact in all six made after the
waited turns and the keyboard bar's presentation, four of six with the settle held, and not stable across two
iterations of one case ("Hello" #1 exact, #2 widened). The rate on her phone — which depends on where each replacement's attributes come from in a live editing
session — is not measured. The archived row for this class (KnownIssues row 30, mobile round 2's M12, now **VX-68**,
Backlog) records an iOS 1-character insert at offset 8 reporting `{8,9}`, and names this class as the "candidate cause
of 'the note flickered' on her phone".

**What she would see.** The word the keyboard just put in (an autocorrection she accepted, a dictated phrase, a
committed candidate) snaps back to what was there before, with the note's surface re-rendered around it (a flicker)
— BY READING (step 7). **Stored text is not put at risk:** a refused route returns before `recordAutosave`
(`:1927-1932` vs `:1901`), so nothing wrong is ever written; `desyncRecovery` first flushes the edits already pending
(`:2025`), so her earlier typing is kept; only the one unsaved replacement is lost from the screen. (In a DEBUG build
the same road fires the editor's assertion seam, `:2019` — her Xcode drops would stop there, which is how VX-68's watch
row says a flicker should be investigated.)

**Why green on Oct 14 and red from Oct 25, with no product change.** SHOWN: the red follows the widening (step 4), and
the widening varies with what happened earlier in the process and with the input posture; this window's host had a
hardware keyboard connected (`gcKeyboard=true` at every act; where a keyboard was posted at all, a 363-pt
software-keyboard announcement was followed by the 52-pt bar a hardware keyboard shows); the simulator's own keyboard
preferences read `HardwareKeyboardLastSeen = true` (half 1's environment read, above), and its
`com.apple.keyboard.plist` last moved on 2026-10-14 at 09:42 — inside C-1's K run, when the test was green. The record's
other history fits the same picture: a single green whole-target run on 2026-10-25 (VM-8 L1) among reds on that
toolchain. INFERENCE, not shown: the simulator's keyboard state changed on or after Oct 14 (a hardware keyboard seen),
which changes what UIKit sets up before a replace and therefore which attributes the replacement carries and whether
fixing widens its report. No posture snapshot exists from the Oct 14 green to compare, so this cannot be proved after
the fact; the two facts it rests on (the red follows the widening; the widening follows process state and posture)
are shown.

**The fix options** (none built; each lives in the editor seam and needs the Fable review; the standing red test is
each one's first pin):
1. **Route an unarmed report from the PRE-fixing range.** The storage observer also implements
   `textStorage(_:willProcessEditing:range:changeInLength:)` (today it has only `didProcessEditing`,
   `MobileEditorViewModel.swift:2402-2420`) and hands that range — the change itself, before fixing widens it — to
   `fallbackVerdict` (and to the re-stamp's clamp, TEXTKIT2 §3's rule). *Risk:* `willProcessEditing`'s range still
   includes any other write inside the same transaction (M3's `{0,5}`, which routes correctly); the delegate order must
   be re-checked so nothing else reads the range between the two calls; a new storage-delegate callback in the seam;
   and Apple's page for the delegate's `willProcessEditing` carries a sentence ("Programmatic changes don't cause the
   object to send this message") that conflicts with `processEditing()`'s own page. This window observed the
   NOTIFICATION (`willProcessEditingNotification`) firing with the exact range on the gate-less replace, so the fix's
   pin must drive the very callback it uses.
   *Pins:* the red test goes green; a new pin for a gate-less insert at a block's end (VX-68's own shape, driven through
   `replace(_:withText:)`, which is gate-less by construction in the test host); the existing routing suites
   unchanged. *Mac:* the Mac's `fallbackVerdict` is the same code (`Variorum/Features/Editor/EditorViewModel.swift:
   1465-1475`) and macOS 26 also widens (TEXTKIT2 §3, 13l); whether macOS ever reaches it unarmed is not shown here. The
   capture could live in `Shared/EditorBrain` and serve both, or stay phone-only.
2. **A fallback that tolerates the widening.** When the unarmed report's old range runs past a separator only by the
   paragraph's own terminator, and the net change (`delta`) fits inside the block the report starts in, route it as that
   block. *Where:* `fallbackVerdict` or a shared helper beside `BlockRangeIndex.verdict`. *Risk:* the report does not
   say where the characters really changed, so this is a judgment from a widened range — a real cross-block system edit
   could be attributed to the wrong block (the DEBUG identity audit would catch it; Release would autosave the wrong
   block's text). *Pins:* the red test; a cross-block gate-less replace must still refuse. *Mac:* same shape if shared.
3. **Arm the roads the phone can see.** `MobileEditorTextView` overrides `replace(_:withText:)` (and the other
   public input doors that skip the delegate) to ask the gate first, as `MobileMarkdownActs.gateAllows` does, so the
   report binds an arming — and a bound arming never polices the report's extent (`EditorEditRouting.swift:122-133`), so
   the widening stops mattering. *Risk:* it covers only roads that pass through those public methods; whether
   autocorrect, dictation and marked-text commits do on a device is not known (the keyboard may reach the input
   controller below them); a refusal now also blocks a system edit (right for a sealed note). *Pins:* the red test; E1 on
   a device to see which roads it actually covers. *Mac:* none (AppKit has its own gate road).
*The runner's view, one line:* option 1 first — it repairs the routing at the cause for every unarmed road at once,
without having to know which system roads skip the delegate; option 3 can follow as a belt.

**What the test host cannot tell us, and what a device run would add.** The host can only drive public UITextInput
calls, which are gate-less here by construction (M25), with a hardware keyboard connected; it cannot drive the real
keyboard's autocorrect, predictive tap, dictation or candidate commit, and it cannot say how often a live session's
replacements carry a paragraph-style object that makes fixing widen the report. A device run with E1 armed (Settings ▸
Diagnostics), typing with autocorrect on, accepting predictions, dictating, using the spelling menu and pasting into
block ends and block middles, would count the gate-less edits per road and the desync recoveries they cause — the
reach and the rate in one reading. VX-68's watch row has asked for exactly that evidence since round 2.

### BATCH D — VM-17's fix: an off-band fan badge does not stand (the takes chrome; read by ladder round 3)

Opened 2026-11-19 after window (3) proved VM-17 real. One member, one acceptance unit, a fresh implementer.

- **What is wrong (seen, twice identically — BATCH C, "WINDOW (3) — RESULTS"):** on a long note with many fanned
  blocks, stepping the page leaves stray fan badges in the viewport. The `.document` pass resolves EVERY fanned
  block's badge through a mid-document forced layout (`Takes/MobileTakesChrome.swift` ~:195-224, through
  `firstLineGeometry` in `Write/MobileEditorTextView.swift` ~:603-619, `.ensuresLayout`), and on later scroll
  ticks an off-band block's "last resolved frame stands" (~:206-209). TextKit then re-positions fragments
  (TEXTKIT2_NOTES §3), so a badge keeps a frame its block has left: one stood 1,260 pt from its own block, and
  several sat 74 pt off their own line. There is no pile at block 1 (reading 1 is green) and the jump road is
  clean; the defect is on steady scrolling.
- **The fix shape — the cold reviewer's, confirmed in advance (round 1, F2's final call; quote it, build it):**
  "the Mac's rule made literal — an off-band badge does not stand: the `.document` pass resolves badges for
  in-band blocks only and hides the rest, the `.nearViewport` pass hides a badge as its block leaves the band
  and resolves it as it enters (tail reservations untouched — they are storage truth). The peek markers share
  the standing-frame rule (`MobileTakesChrome.swift:256`); the fix covers them or a ticket names them."
  The Mac's own fix for the same class is VX-246's U4 (`notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U4
  UNIT RECORD; TEXTKIT2_NOTES §3) — read it for the rule, not to copy code.
- **The pin:** `MobileFanBadgePlacementProbeTests.noFanBadgePilesAndNoneStandsAstrayInTheViewportOnALongNote` —
  readings (i), (i′), (ii). It is ALREADY seen red on the unfixed chrome (M5 and M5b, bundles
  `c-M5.xcresult` / `c-M5b.xcresult`). The fix turns it green in a short stage window; reading (iii) (reach) must
  stay green, and reading 1 too. The probe is NOT edited to make it pass; if the fix changes what "drawn" means
  (a hidden badge), say exactly how the probe reads a hidden badge and prove by reading that (ii) still demands a
  badge on every on-screen fan.
- **What must not change:** which blocks wear a badge (fanned blocks only, count-free — SurfaceContracts, The
  note); the badge's look and its tap/swipe hit-testing for on-screen fans; the tail reservations; the takes
  browser; and P3 — nothing here may force layout for blocks outside the band (the fix should REDUCE forced
  layout, which is also VM-179's cost: record the `.document` pass's cost before and after by reading or a
  headless measure, for that ticket — do not chase further savings here).
- **The editor seam:** `firstLineGeometry` lives in `MobileEditorTextView.swift`. Prefer a fix that stays in
  `MobileTakesChrome.swift` (which blocks it asks about, when it hides). If a line in `MobileEditorTextView.swift`
  must change, keep it to the geometry helper, say so first in LIVE STATUS, and touch nothing in the text view's
  input, selection or storage roads. No line in `MobileEditorViewModel.swift`, `Shared/EditorBrain` or any edit
  routing — VM-24's mechanism is NOT this batch's and is held for the author.
- **Other tickets this meets, for the record (do not widen scope):** VM-179 (wave 4 — "the takes marks lay out
  only the fanned blocks on screen") is largely this fix's shape: say in LIVE STATUS what of VM-179 this leaves.
  VM-188 (wave 5 — the visible badge and the foot pill) redraws the badge's face later.
- **Evidence:** the probe green on the fix in a stage window (and, since red-on-old is already on file from
  window (3), no second red leg is needed unless the probe file changes — then red-on-old is shown again for the
  changed probe); the takes suites that exercise the chrome green by TYPE (name them: grep the tests for
  `MobileTakesChrome` / the badge layer); a walk row for the gate — a long fanned note scrolled top to bottom,
  badges on their own lines.

#### BATCH D — LIVE STATUS

*(The trace session's record, kept verbatim below. The BUILD of round 3's called shape has its own section, "The
build — LIVE STATUS", at the end of batch D: read that for where the batch stands now.)*

**WHAT IS NOT DONE (first, as the contract asks): NOTHING IS BUILT. The implementer STOPPED before any product line,
by the brief's own rule** ("if your trace says the confirmed shape would NOT remove a symptom — the 74-pt offset in
particular — STOP and report that before building anything"). The trace below says exactly that: the confirmed shape
removes the large strays (an off-band stale frame) and does NOT remove the 74-pt offsets (an IN-BAND badge resolved
against a fragment TextKit re-positions after the read). No product or probe line changed; no stage, no simulator.
Since then, at the orchestrator's word, ONE instrument test file is added (the settle measurement, below — test target
only, not a pin, it leaves the tree once its numbers are recorded) and built (`build-for-testing` green); its window is
the orchestrator's, PENDING. **No revert is in flight; `git status` is clean.** (2026-11-19, a fresh
`opus-implementer`.)

| Member | State |
|---|---|
| VM-17 | **IN-PROGRESS — STOPPED AT THE TRACE, before code; the settle MEASUREMENT is built (the instrument below), its window PENDING.** What remains: the orchestrator's window runs the instrument alone; the reviewer's final call on a shape that also removes symptom B (options below) reads its `VM17M|` lines; then the build, the probe green in a window, the chrome suites green by type, the walk row; the instrument leaves the tree in a named commit once its numbers are in this record. The pin stands as it is (red on the unfixed chrome, M5/M5b). |

**THE SETTLE MEASUREMENT — an instrument for the fix shape's call (2026-11-19, at the orchestrator's word; TEST TARGET
ONLY: no product line, no probe edit).** `App/Variorum/VariorumMobileTests/MobileFanBadgeSettleMeasureTests.swift`,
TYPE **`MobileFanBadgeSettleMeasureTests`**, one test (`whenDoesABandFansFragmentSettleOnTheSteppedWalk`). It asserts
nothing about the product (only `#require`s that its setup worked) and prints `VM17M|` lines. **Run it ALONE, by type:**
`-only-testing:VariorumMobileTests/MobileFanBadgeSettleMeasureTests`. It is not a pin: it leaves the tree in a named commit
once its numbers are written here.
- *The note and the walk:* the probe's fixture copied byte for byte (150 blocks, every 7th fanned; the probe's builder is
  private to its type, so it is copied, not called), the probe's host (a scene window, shown, never key — no first
  responder planted), the probe's settle, the probe's stepped walk (0.8 of a viewport, the end re-read live).
- *Mount 1 — the moments.* At EVERY stop (a superset of "a fan newly enters the band"; lines flagged `newBand`/`newVis`),
  for every fan in the chrome's band (the chrome's own `near` rule over `nearViewportBand()`, read at the pass), one
  `VM17M|walk#…` line with, at each moment, `b:` the drawn badge's top exactly as the probe reads it, `t:` the first-line
  fragment's top read UNFORCED (`options: []`), and `L`/`E` (`.layoutAvailable` or not); plus `ideal=` (the probe's
  idealized layout). The moments, in order, each cumulative on the one before:
  `pass` — inside the stop's layout pass, right after the text view's own `layoutSubviews` (so right after the chrome's
  tick): a zero-size TEST view at the text view's subview index 0 records from its own `layoutSubviews`, which UIKit runs
  after its superview's in the same recursion — the nearest point reachable without a product hook (`fired=0` on a line
  = not reached at that stop) · `afterPass` — when that pass (`window.layoutIfNeeded()`) returns · `hop` — after ONE
  main-queue hop: one `DispatchQueue.main.async` block resuming a `CheckedContinuation` (the test's own resumption is one
  main-actor job after it) · `relayout` — after `setNeedsLayout()` + `layoutIfNeeded()` on the text view (the chrome's
  tick runs again, with its forced reads) · `flush` — after `CATransaction.flush()` · `link` — after one `CADisplayLink`
  callback (public API; a 0.5 s fallback resumes it if none comes, counted in `linkFired`) · `settle` — after the
  probe's own settle: **the truth** (the unforced read there, as the probe compares).
- *Mount 2 — option (c).* A second cold mount; at each stop, BEFORE the stop's pass, ONE
  `NSTextLayoutManager.ensureLayout(for: NSTextRange)` from the TextKit viewport's start through the first character of
  the last fan inside the band (the band as `nearViewportBand()` gives it then, extended by one viewport length of
  characters to cover the step) — so no band fan is laid out ahead of its predecessors; then the pass, and
  `VM17M|c|…` lines with the chrome-resolved badge (`bandRun=`, read at the pass) against that mount's settled truth;
  `VM17M|c|END` carries the run count and their total time.
- *SUMMARY lines:* per mount and moment, for the unforced read and for the badge, over every band-fan read that has a
  laid-out truth and over the newly-visible subset (the 74-pt class): `agree` (within 1 pt of the truth) · `disagree` ·
  `missing` (the unforced read not `.layoutAvailable`, or no badge drawn) · `largest` disagreement; plus the probe's own
  reading after the settle, and `VM17M|walk|END` with `sentinelFired` and `linkFired` out of the stops.
- *Every moment asked was reached without a product hook* (the pass through the test-side subview, the display turn
  through `CATransaction.flush()` and a `CADisplayLink`). **Limits, said plainly:** both mounts carry TODAY's load-time
  full pass (every fan force-laid-out at load, ahead of its predecessors — the confirmed shape would remove it, a test
  cannot); every moment from `relayout` on carries the chrome's own forced reads of that pass; and whether the `pass`
  moment precedes a TextKit-internal subview's own layout is UIKit's recursion order, which the `pass`/`afterPass` pair
  reports rather than assumes. The shared editor harness resets the voice as it does for every editor suite; the
  instrument flips nothing else.
- **What each SUMMARY outcome would mean (for the newly-visible subset first, then all):**
  - `pass` unforced already agrees → TextKit placed the fragment before the sentinel; the 74 pt is then between the
    chrome's read and the end of the text view's own pass — re-read the trace, no option is supported yet.
  - `pass` disagrees, `afterPass` agrees → TextKit re-positions inside the same layout recursion, after the text view's
    own pass: a single deferred re-read after the pass suffices — **(a)** as a hop, or **(b)** with the hop.
  - `afterPass` disagrees, `hop` agrees → **(a)** works with exactly one main-queue hop; **(b)** with the hop (its
    `missing` count at `pass` is how many fans (b) would leave bare for that one hop).
  - `hop` disagrees, `relayout` agrees → the re-position needs another layout pass: (a) as a hop that runs
    `setNeedsLayout()` once per occasion (budgeted); (b) the same.
  - only `flush` or `link` agree → display-cycle bound: the re-read rides a one-shot display link.
  - nothing agrees before `settle` → no reachable moment carries the truth: neither (a) nor (b) as shaped; the
    reviewer shapes a later trigger.
  - mount 2's `bandRun` badge agrees for every read, the newly-visible above all → **(c)** removes symptom B at the
    source with no deferred re-read (its cost: `runTotalMs` over the runs); disagreements → (c) alone does not, by its
    `largest`.
- *Its build:* signed phone `build-for-testing` (`-scheme VariorumMobile -destination 'platform=iOS Simulator,name=iPhone 17
  Pro,OS=26.2' -derivedDataPath App/Variorum/DerivedData/vm78-ios`, no boot): **TEST BUILD SUCCEEDED** — log
  `App/Variorum/DerivedData/logs/vm78-d-bft1.log`; the file's one warning is the copied `UIWindow(frame:)` fallback (the
  probe's own deliberate deprecation).
- *Its run:* the probe's main test, the same walk on two mounts, took 4.29 s in window (3) (`vm78-c-M5.log`); this
  walks once with five extra moments per stop (each at most a display frame, or 0.5 s if the display link never fires)
  and once with a band run, so the test should take roughly ten seconds, and under a minute even if no display-link
  callback comes, on top of the invocation's build check and app launch.

**THE TRACE (by reading the chrome and window (3)'s kept logs — `DerivedData/logs/vm78-c-M5.log` and `-M5b.log`; their
`VM17|` geometry lines are IDENTICAL line for line, only the cost note's timings differ).**

*Where the badge comes from.* Every pass resolves a fanned block's badge through `firstLineGeometry`
(`Takes/MobileTakesChrome.swift:211` → `Write/MobileEditorTextView.swift:603-619`, `.ensuresLayout` from the block's own
offset at `:611`) and writes the frame in content coordinates (`MobileTakesChrome.swift:216-221`). A FULL pass resolves
every fan: the `.document` scope (`:155-157`; callers `MobileEditorTextView.swift:287` and the model's
`refreshChrome()` calls) and the first `.nearViewport` pass after mount, which escalates to full on the width change
(`:158-162`, `lastFullPassWidth` starts at −1). A scroll tick (`layoutSubviews` → `refreshChrome(.nearViewport)`,
`MobileEditorTextView.swift:340-349`, the chrome AFTER `super.layoutSubviews()`) resolves only fans inside the band
(`nearViewportBand`, `:587-598`: TextKit's `viewportRange` in characters ± `max(its length, 512)`); an off-band fan that
already has a badge is skipped and "its last resolved frame stands" (`MobileTakesChrome.swift:206-209`).

*Symptom A — the large strays (24 of the 35 (i) lines, their 24 (i′) misses; the 1,260-pt one among them): an
OFF-BAND STALE FRAME from the load's full pass.* At load the full pass forces layout at each fan's mid-document offset,
ahead of its unlaid predecessors, so TextKit places it at an estimate (TEXTKIT2 §3, VX-246 U4b fact 1): the load lines
step 1,095.25 pt per fan where the settled layout steps ~1,551 (`@9190` at 4683.0, settled 6207.0). TextKit then moves the
fragment as its viewport passes lay out the text above (`@9190`: 4683 → 5943 at walk#8 → 6207 at walk#10), while the
badge, off-band, keeps 4683. At walk#8 (visible 4480..5180) that frame stands in the viewport beside the fragment at
`@6890`, 1,260 pt from its own line — and `@9190` is still outside the band (its line is 763 pt below the visible
bottom). **Every one of the 24 large-offset lines carries its block's exact LOAD value** (`@11490` 5778.25, `@13790`
6873.5, `@16090` 7968.75, … `@48337` 23302.25 — each equal to its `VM17|load|` line). **The confirmed shape removes this
class**: the full pass would resolve in-band fans only and hide the rest, and a tick would hide a badge as its block
leaves the band.

*Symptom B — the 74-pt offsets (the other 11 (i) lines, their 11 (i′) misses, and ALL 9 (ii) bare lines): an IN-BAND
badge resolved against a fragment TextKit re-positions after the read.* The eleven cases, every one exactly 74.0 pt:

| stop (visible rect) | block | line | badge | line vs the visible bottom |
|---|---|---|---|---|
| walk#7 (3920..4620) | `@6890` | 4655.75 | 4581.75 | 36 pt below it |
| walk#10 (5600..6300) | `@9190` | 6207.0 | 6133.0 | 93 pt above it |
| walk#13 (7280..7980) | `@11490` | 7758.25 | 7684.25 | 222 above |
| walk#21 (11760..12460) | `@18390` | 12412.0 | 12338.0 | 48 above |
| walk#24 (13440..14140) | `@20690` | 13963.25 | 13889.25 | 177 above |
| walk#32 (17920..18620) | `@27590` | 18617.0 | 18543.0 | 3 above |
| walk#35 (19600..20300) | `@29890` | 20168.25 | 20094.25 | 132 above |
| walk#43 (24080..24780) | `@36802` | 24822.0 | 24748.0 | 42 below |
| walk#46 (25760..26460) | `@39109` | 26373.25 | 26299.25 | 87 above |
| walk#49 (27440..28140) | `@41416` | 27924.5 | 27850.5 | 216 above |
| walk#57 (31920..32620) | `@48337` | 32578.25 | 32504.25 | 42 above |

Three facts decide it. (1) **Each line equals the idealized layout** (its `VM17|load|` `ideal=`): TextKit has settled the
fragment by the probe's read. (2) **Each badge holds a value it was never loaded with**, so a pass re-resolved it after
load — e.g. `@6890` loaded at 3587.75, but at walk#6 (visible 3360..4060) no badge was in view, so it had already moved,
and at walk#7 it stands at 4581.75; `@9190` went 4683.0 (walk#8) → 6133.0 (walk#10). (3) **Each block came into the
visible rect AT THAT STOP** (every line was below the previous stop's visible rect; each lies within 222 pt above, or 42
pt below, the bottom edge), so it is inside the band at that stop whichever viewport the band was computed from — the
pad is a viewport of characters, the step 560 pt. So the chrome's in-band read in that cycle returned a frame 74 pt
short, and TextKit moved the fragment AFTER that read: the read is `.ensuresLayout` from the block's offset while the
text just above it (below the previous viewport) is not yet laid out, so the fragment is placed ahead of its unlaid
predecessors at an estimate (TEXTKIT2 §3, VX-246 U4b fact 1); TextKit's viewport pass then lays out that stretch and
re-positions it (fact 2) — after the chrome's last read of the cycle, and nothing runs the chrome again until the next
scroll tick. The next stop is clean (walk#11 shows `@9190` on its line; walk#22 `@18390`). Whether TextKit's viewport
layout for the new bounds runs after the text view's own `layoutSubviews` (in a subview's pass) or in a later display
pass that does not re-dirty the text view's layout, reading cannot say; the effect is the same. (The constant 74 fits a
gap of the same shape every time — the note's 7-periodic paragraphs, the paragraphs just above each fan — a guess, not
needed for the verdict.)

**So, by reading, on the confirmed shape as written:** the 24 load-value strays go; the 11 in-band 74-pt badges stay,
because "resolves it as it enters" keeps exactly the forced in-band read that makes them. Expected on the probe: (1)
green; (i) **~11** red, (i′) **~11**, (ii) **~9** — the pin stays red — unless the changed layout history (no load-time
forced reads below the fold) happens to remove them, which reading cannot promise. (iii) green.

**THE OPTIONS for a shape that would also remove symptom B (for the reviewer's final call; none built):**
- **(a) The confirmed shape plus one deferred re-read.** After a pass that resolved a band fan, ONE coalesced main-queue
  hop re-runs `.nearViewport` (equality-gated, so a settled hop writes nothing; it re-arms only when a frame moved, with
  a small budget per occasion — the shape of the Mac inline editor's settle net, TEXTKIT2 §3). It removes B only if the
  hop lands after TextKit's re-positioning: UNMEASURED on iOS 26.2. Smallest change, wholly in `MobileTakesChrome.swift`.
- **(b) The Mac's rule made literal in full (VX-246 U4/U4b):** no forcing read in the badge pass at all — read the
  in-band fan's first fragment UNFORCED (`options: []`), draw its badge only from a `.layoutAvailable` fragment within
  TextKit's own viewport range, hide it otherwise; plus (a)'s hop, so a fan newly exposed this tick is badged once
  TextKit has placed it. This removes the cause (no layout ahead of predecessors, so no estimate to read) and all of the
  badge pass's forced layout (VM-179's whole share). Without the hop, a fan just scrolled onto the screen would be bare
  until the next tick (the Mac's own recorded Write residual) and (ii) would read it red. Needs `firstLineGeometry`'s
  unforced twin — a geometry-helper line in `MobileEditorTextView.swift` or a private read in the chrome.
- **(c) Lay out the band contiguously before the reads:** one `.ensuresLayout` run from the viewport's start through the
  band's last fan, so no fan is laid out ahead of its predecessors. Cost ∝ the band (at most three viewports of
  characters, P1-honest); unmeasured whether TextKit's next viewport pass would still re-base what it laid out.

**The implementer's recommendation:** a short measuring window FIRST (an instrument, not a fix): at a walk stop, print
each band fan's frame as the chrome reads it inside `layoutSubviews`, after one main-queue hop, and after the settle —
which says whether (a)'s hop lands after TextKit's re-positioning. If it does, build **(b)** (the most spec-defensible:
the Mac's measured rule — "a frame read with `options: []` is a position only in `.layoutAvailable`", "never force
layout from a mid-document location" — and the cheapest under P1); if it does not, the re-read needs a later trigger,
and that is the reviewer's to shape. Either way the confirmed shape's hide rules stay (they are what remove A).

**What else the shape meets (recorded, not acted on):**
- **The peek markers** (`MobileTakesChrome.swift:253-283`) share the standing-frame rule (`:256-261`) and their in-band
  read is the same forced kind (`blockRectsUnion`, `MobileEditorTextView.swift:623-642`, `.ensuresLayout` at `:631`), so
  they carry both symptoms' exposure; the pill too (`:286-308`, off-band untouched, in-band `blockRectsUnion`). Whichever
  shape is called, the markers ride it, or the record names them for a ticket (no id invented).
- **An existing guard the confirmed shape contradicts by design:** `MobileTakesChromeTests.perTickRefreshResolvesOnlyNearViewportGeometry`'s
  `.document` half expects the full pass to resolve the far fan (`MobileTakesChromeTests.swift:534-538`,
  `lastGeometryResolvedBlockIDs.contains(seed.far)`). Under "the `.document` pass resolves badges for in-band blocks
  only", that expectation inverts; its `badgeView(for: seed.far) != nil` (`:529`) holds only if a hidden badge is kept as
  a hidden view rather than removed. The fix's commit would re-word that half, said in its message.
- **How the probe reads a hidden badge** (`MobileFanBadgePlacementProbeTests.swift:232`): `drawn` = in the text view, not
  `isHidden`, alpha above 0.01. A hidden badge is never (i)'s or (i′)'s subject, and (ii) still demands a DRAWN badge
  within 1 pt on every laid-out fanned first line on screen — so hiding cannot buy a green: a fan on screen with its
  badge hidden reads bare.
- **VM-179's number, by reading (before):** a full pass forces one `firstLineGeometry` per fanned block (22 on the probe's
  note, 86 on the 600-block note), plus one `blockRectsUnion` per peeked block and one for the pill's block; window
  (3)'s cost note measured it at 1.81 ms cold / 0.30 ms warm (150 blocks) and 6.02 / 1.24 ms (600). Under the confirmed
  shape a full pass would force only the band's fans (one to three on the probe's note at its 700-pt viewport); under
  (b), none. **What of VM-179 this would leave:** under the confirmed shape, the per-tick forced reads of band fans and
  the markers'/pill's forced reads; under (b), the markers' and the pill's only.
- **The test types that exercise the chrome** (for the window's `-only-testing` list, beside the probe):
  `ONLY=(MobileFanBadgePlacementProbeTests MobileTakesChromeTests MobileWalkTests MobileConflictDiscoveryTests
  MobileTakesBrowserSurfaceTests MobileTutorialTakesWalkTests MobileTutorialLibraryWalkTests MobileBlockListTests
  MobileBlockMenuTests)` — the first five read badges or markers, or tap the badge, directly; the two tutorial walks
  drive the peek marker and `refreshChrome`; `MobileBlockListTests` reads `firstLineGeometry` through the jump road
  (`jumpToBlock`), and `MobileBlockMenuTests` the block decor that shares the one refresh door (`refreshChrome`).
- **No PROVISIONAL was ruled and no question is raised for `notes/QUESTIONS.md`:** the open point is a fix shape for the
  reviewer's final call, not product behaviour.

#### The build — LIVE STATUS

**WHAT IS NOT DONE (first): the build is DONE and NOTHING in it is verified on the stage** — the red leg, the green
leg and the decor reading are the orchestrator's window (recipe below, "THE WINDOW"); the decor reading's removal
commit, the walk row and ladder round 4 follow it. A fresh
`opus-implementer` (2026-11-19) builds round 3's called shape (`vm-78-ladder-round3.md`, "Final calls" → "VM-17's fix —
the shape, as called", S1–S11) exactly, in five pieces plus two headless builds. It runs no `xcodebuild test` and boots
no simulator: every red and green below is the orchestrator's window, PENDING. **No revert is in flight; `git status` is clean** (the red tree's headless build reverted the two product files to `15add793d` under a recorded REVERT IN FLIGHT, `9ff04a4b4`, and restored them with `git checkout HEAD --` before this commit; `git diff HEAD` empty). (The implementer's proposed shape that the reviewer amended went to the reviewer as an
answer and is not on file in the repo; the four amended points are the ones marked "(changed)" in S1, S2, S3 and S5.)

| Piece | State |
|---|---|
| 0 — this LIVE STATUS opens | DONE (`c829bda3e`) |
| 1 — the pins first (`MobileTakesChromeTests`: the S9 re-pins, the new marker-and-pill pin, the new empty-last-block guard; the probe's header comment, R3-N3) | DONE (`15add793d`) — written against the OLD chrome's API only; compiles on both trees (the builds row). **Re-pins:** `perTickRefreshResolvesOnlyNearViewportGeometry` — the far badge `== nil` at load and after the tick (the old `:513`, `:529`), and the `.document` half `!lastGeometryResolvedBlockIDs.contains(far)` plus the far block's first fragment read unforced NOT `.layoutAvailable` (the old `:536-538`); the far reservation expectations untouched. `aKeystrokesChromePassIsEditScopedAndWriteFreeWhenNothingMoved` — the far badge `== nil` (the old `:617`). **New pin** `aFarFlipDrawsNoMarkerOrPillUntilItsBlockScrollsIn` (red on old by reading: the old `.document` pass makes the far marker through a forced union and the pill shows). **New guard** `anEmptyFannedLastBlockWearsItsBadgeWhileTheNotesEndIsOnScreen` (green on both sides by design; red on old too ⇒ record it, drop it, keep the rule). The two new tests MOUNT IN A WINDOW the probe's way (scene window, shown, never key, no first responder; VM-19's `endEditing` teardown), because they read TextKit's viewport and the windowless container's keyboard guide collapses (recorded in `MobileTypewriterRoomTests` and `MobileBlockListTests`). The probe: its header's last three comment lines rewritten in place (R3-N3 — the line count kept, so the test body's source lines are M5's); the test body and `fanEvery` untouched (`git diff` on the file is those three lines). |
| 2 — the fix (`Takes/MobileTakesChrome.swift`; the "Chrome geometry" section of `Write/MobileEditorTextView.swift`; ONE comment line in `Write/MobileBlockDecor.swift`) | DONE (`f869f8667`) — compiles (the builds row). **Said first, as the brief asks: `MobileEditorTextView.swift` changes, in its "Chrome geometry" section only** — nothing in `layoutSubviews`, `refreshChrome`, `installTakes`, the input, selection or storage roads; nothing in `MobileEditorViewModel.swift`, `Shared/EditorBrain` or any edit routing. Where each point of the called shape is built (pre-commit line numbers of this tip): **S1** `viewportCharacterRange()` (`MobileEditorTextView.swift:589`), the inside rule with the empty-last-block end case as ONE static helper beside it, `viewport(_:holdsBlockStartAt:textLength:)` (`:604` — used by the chrome and by the clipped union, so the rule lives once), `nearViewportBand()` re-expressed over it with identical arithmetic (`:617`; the decor still reads it). **S2** badge: `firstLineGeometry` unchanged, called only for a block start that is inside (`MobileTakesChrome.swift:289-295`); marker and pill: the new `blockRectsUnion(range:within:)` (`MobileEditorTextView.swift:681`), clipped both ends, nil when nothing is inside; the unclipped helper and the decor's calls untouched. **S3** a badge or marker view is made only when placed, hidden with its frame kept when its block has nothing inside (`MobileTakesChrome.swift:294`, `:316`), removed when its fan or peek dies (`:201`, `:233` — in the refresh, as the views' life, not their geometry); the pill placed or `isHidden`-hidden by the walk (`:346-356`), `hidePill()` kept for its two causes only (`:240`). **S4** `lastFullPassWidth` and the width escalation are gone; the three scopes share `geometryWalk(ranges:)` (`:274`); a scope decides only `healContinuations` and the `.edit` residue heal. **S5** `refresh` runs the reservation walk, the lives, ONE geometry walk, then keeps its ranges and arms the anchor (`:249-250`); `reread()` (`:258`) walks once more with the kept ranges, drops them, writes no reservation, never arms itself, never calls `blockRangesByID()`; a nil viewport makes the walk do nothing (`geometryWalk`'s guard). **S6** `MobileTakesChromeAnchor` (`:480`), made in the controller's `init` and added with `addSubview` (`:129`) — zero-size, not hidden, no interaction, not an accessibility element, a weak hold on the controller; `layoutSubviews` is `super`, then the re-read. The pre-decided arm (`insertSubview(_:at: 0)`) is NOT taken. **S8** the header's "Geometry discipline / SCOPES" paragraph (`:37`) and `RefreshScope`'s comment (`:141-154`) rewritten to the new law; `MobileBlockDecor.swift:82` — the one line, now saying the takes chrome no longer shares the band law and naming this record. **Read, not built differently:** a fan inside the viewport whose forced first-line read returns nothing is treated as having nothing inside (hidden, never shown at a stale frame) — the law's "nothing stands", not a new rule; `showPill` still sets the pill visible before its refresh (unchanged; the refresh's walk hides it at once when its block has nothing inside, and with a nil viewport the re-read decides, as S5 says). The `layoutSubviews` doc comment in `MobileEditorTextView.swift` (the width escalation) is left untouched by S8's rule and stays true of the decor. |
| 3 — the decor reading (R3-F1's fair pin, its own test type; runs ALONE by type in the green window; leaves after the window, not now) | DONE (`211221f6b`, its compile fix `75984c0e6`) — compiles (the builds row). `App/Variorum/VariorumMobileTests/MobileDecorPlacementReadingTests.swift`, TYPE **`MobileDecorPlacementReadingTests`**, one test `theDecorStandsOnItsOwnBlocksInTheViewportOnALongNote`, built to the final call's list item by item: (1) its own type, expectations not prints, `.serialized`, its doc comment saying it runs ALONE by type in the green window and LEAVES the tree in a named commit after it; (2) the probe's note byte for byte (`paragraph(i)`, 150 blocks, every 7th fanned with the probe's take text) plus a callout with a glyph (`sand`, 🕯) where `i % 5 == 2` (30) and a comment where `i % 3 == 1` (50), non-vacuity asserted (≥ 20 fans, ≥ 20 callouts, ≥ 40 comments, content > 6,000 pt); (3) truth is TextKit's only — fragments read `options: []` gated on `.layoutAvailable`, `textLayoutFragment(for:)` at points, 1 pt, `view.bounds`, after the probe's settle, on the probe's stepped walk (cold mount A) and the jump road to every decorated block far to near (cold mount B), the probe's host; (4) WASH (i) three points (top + 5, middle, bottom − 5, clamped into the visible rect, mid-width) each in a fragment that begins inside the wash's block, and top + 4 within 1 pt of the first fragment where the top edge is on screen; (ii) every laid-out callout fragment meeting the screen covered there by its drawn wash; (5) GLYPH (i)/(ii); (6) MARK (i) within 1 pt of the last line's top and the fragment 1 pt under it inside the block, (ii); (7) REACH with the probe's own-red wording ("the reading did not reach…"); (8) the probe's badge readings (i) and (ii) on this note, their messages saying a red there is batch D's (stop and report); (9) every red printed as `VM17D|` lines and a `VM17D|SUMMARY`. Its outcome and the commit that removes it are the record's after the window. |
| 4 — the settle instrument leaves (its result written here first, R3-F3) | DONE — the result is written below (`8f48427b0`); `MobileFanBadgeSettleMeasureTests.swift` removed whole in its own named commit (`5a57abdf0`), which names `35ce90848`, the commit that introduced it; no other file names the type |
| 5 — record lines (VM-179 before and after; VM-218's VoiceOver line; R3-N1's sentence) | DONE (`bb5087223`) — the three lines below the table, "For other owners and for round 4" |
| Builds — the signed phone `build-for-testing` at the tip (`DerivedData/vm78-ios`), and the RED leg's tree (the two product files at the pre-fix commit) into `DerivedData/vm78-ios-red` | DONE — at `f869f8667` (pieces 1 and 2): **TEST BUILD SUCCEEDED** (`DerivedData/logs/vm78-d-bft2.log`; the only new warning is the pins' deliberate `UIWindow(frame:)` fallback, the probe's own). At `bb5087223` (pieces 3–5): **TEST BUILD FAILED** (`vm78-d-bft3.log`) — the decor reading's `#require` inside a `map` closure called the main-actor `rangeOfBlock` from a nonisolated closure; fixed in this commit by a plain loop (and the `#require` bound to a local, so a missing range fails rather than silently dropping the block — `vm78-d-bft4.log` had warned it was redundant), then **TEST BUILD SUCCEEDED** (`vm78-d-bft5.log`; the only warning in the batch's files is the same deliberate `UIWindow(frame:)` fallback). **The red tree:** with `MobileTakesChrome.swift` and `MobileEditorTextView.swift` checked out at `15add793d` and the tests at the tip, a signed phone `build-for-testing` into the SEPARATE DerivedData `App/Variorum/DerivedData/vm78-ios-red`: **TEST BUILD SUCCEEDED** (`vm78-d-bft-red.log`; it compiled the old chrome, `MobileTakesChromeTests` and the decor reading) — so every pin compiles against the old chrome (they use only its API) and fails there, if at all, by assertion. Then both files restored from HEAD, and the tip rebuilt incrementally into `vm78-ios` once more: **TEST BUILD SUCCEEDED** (`vm78-d-bft6.log`) — that DerivedData is current for the green leg. The Mac target does not compile these files (they are under `VariorumMobile/` and `VariorumMobileTests/`, phone-only), so no Mac build was run. |

**The settle measurement's RESULT (written here before the instrument leaves — R3-F3's final call).** The orchestrator
ran `MobileFanBadgeSettleMeasureTests` alone by type on 2026-11-19 (`App/Variorum/DerivedData/logs/vm78-d-measure.log`:
"Test run with 1 test in 1 suite passed after 6.685 seconds"); the instrument is the one described in the trace's
LIVE STATUS above (introduced in `35ce90848`). Its SUMMARY rows, verbatim:
- `VM17M|walk|END stops=61 sentinelFired=61/61 linkFired=51/61 contentHeight=33812`
- `VM17M|SUMMARY mount=1 bandFanReads=118 withTruth=118 newVisible=22`
- `pass` — unforced `all(agree=118 disagree=0 missing=0 largest=0.00) newVisible(agree=22 disagree=0 missing=0
  largest=0.00)`; badge `all(agree=69 disagree=49 missing=0 largest=9202.00) newVisible(agree=13 disagree=9 missing=0
  largest=74.00)`
- `afterPass`, `hop` — exactly `pass`'s two rows (unforced 118/118 · 22/22; badge 69/49, largest 9202 · 13/9, largest 74)
- `relayout`, `flush`, `link` — unforced and badge both `all(agree=118 …) newVisible(agree=22 …)`, largest 0.00
- `settle` (the probe's own reading, after a relayout this walk adds) — badge `all(agree=118 …) newVisible(agree=22 …)`
- `VM17M|c|END stops=61 runs=60 runTotalMs=22.85 contentHeight=33812`; `mount=2 bandFanReads=118 withTruth=118
  newVisible=22`; `bandRun` unforced `all(agree=118 …)`; `bandRun` badge `all(agree=0 disagree=0 missing=118 …)`

What it says, with the two corrections the trace session made to its own first reading (both taken by the round-3
reviewer, who tallied the 118 rows independently):
- **At the first subview laid out after the text view's own layout (`pass`, reached at 61 of 61 stops), the UNFORCED
  first-line read already equals the after-settle read in all 118 band-fan rows; for the 28 rows whose line was on
  screen it equals the idealized layout in all 28.** The chrome's badge was off in 49 rows at `pass`, `afterPass`
  and `hop` (9 of them on screen, each exactly 74.00 pt) and right in all 118 from `relayout` on — once the chrome
  read again after TextKit's pass. The band printed at `pass` is fresh (walk#10's `6195..11148` works back to a
  viewport of `@7846..@9497`, the stop's own visible text): TextKit lays out the viewport after the chrome's tick and
  before that first subview. This is the measured moment the called shape's re-read stands on (S5, S6).
- **Correction 1 — "settled" is true only of what is on screen.** 28 of the 90 off-screen rows are still estimates
  after the settle, all below the screen (74 or 264 pt short), so the `settle` column is the truth for the on-screen
  rows only.
- **Correction 2 — at walk#10 the chrome did not read ahead of unlaid text; it read back a frame an earlier forced
  read had left.** `@9190` at walk#9 (visible `5040..5740`): `pass=b:4683.00,t:6133.00,L`, then `relayout=b:6133.00`;
  at walk#10 (visible `5600..6300`): `pass=b:6133.00,t:6207.00,L` — the fragment was laid out but not yet placed (6133)
  when the walk#9 relayout's forced read badged it, and TextKit moved it to 6207 at walk#10's viewport pass, before
  the chrome read again. Laid out is not placed: this is why the called shape reads only inside TextKit's viewport and
  re-reads after its pass, rather than trusting a `.layoutAvailable` fragment above or below it.
- **Mount 2 is VOID** — every `c|` row reads `b:-`: that mount discards the model it makes (`let (_, surface) = …`),
  the chrome holds its model weakly, so no chrome pass ran there. Option (c) is unmeasured, and the call does not need
  it.
- **`linkFired=51/61` is R3-F3's stale fallback, not the host:** one `DisplayTurn` served every stop and each call's
  0.5 s fallback was never cancelled, so an earlier stop's fallback ended a later stop's wait before any display
  callback came. Nothing was decided on the `link` moment: badge and unforced read agree 118 of 118 already at
  `relayout` and `flush`, the two moments before it.

**THE WINDOW — the orchestrator's (S10), from its own checkout; recipe and expectations as the build leaves them:**
- **RED leg:** `MobileTakesChrome.swift` and `MobileEditorTextView.swift` at `15add793d` (the commit before the fix;
  the tip's tests compile against them — proved headless into `DerivedData/vm78-ios-red`), `MobileTakesChromeTests`
  ONLY. Expected RED, exactly: `perTickRefreshResolvesOnlyNearViewportGeometry` (the far badge exists at load and after
  the tick, the full pass reads the far block and lays it out — four expectations),
  `aKeystrokesChromePassIsEditScopedAndWriteFreeWhenNothingMoved` (the far badge exists — one),
  `aFarFlipDrawsNoMarkerOrPillUntilItsBlockScrollsIn` (a marker made, the pill showing, the far block laid out — at
  least three; its scrolled-in half may go either way on the old chrome). Expected GREEN there: every other test in
  the type, including the new guard `anEmptyFannedLastBlockWearsItsBadgeWhileTheNotesEndIsOnScreen` — **if the guard is
  red on the old chrome too, that case never drew a badge: record it, drop the guard in a named commit, keep the rule
  (the final call's own arm).** The probe needs no red leg (R3-N1, below).
- **GREEN leg (the tip; `vm78-ios` is current, `vm78-d-bft6.log`):** `MobileFanBadgePlacementProbeTests` and the chrome
  types, by TYPE — `MobileTakesChromeTests MobileWalkTests MobileConflictDiscoveryTests MobileTakesBrowserSurfaceTests
  MobileTutorialTakesWalkTests MobileTutorialLibraryWalkTests MobileBlockListTests MobileBlockDecorTests`. **Correction
  to the trace's list:** the block decor's suite is the TYPE `MobileBlockDecorTests` (it lives in the FILE
  `MobileBlockMenuTests.swift`); the TYPE `MobileBlockMenuTests` builds menus and mounts no surface, so it may ride
  along or not. No other test type reads the takes chrome (grepped: `badgeView`, `markerView`, `pillIsShowing`,
  `pillView`, `lastGeometryResolvedBlockIDs`, `refreshChrome`, `nearViewportBand`, `blockRectsUnion`,
  `firstLineGeometry`, `blockDecor`, `takes.badge`). Expected: all green; the probe's reading 1, (i), (i′), (ii) and
  (iii) green on both roads, reading 2 printing `offscreenDrawn=0` (the fix's claim, not an empty measurement — a
  small count would mean TextKit's viewport reaches past the visible rect, still only a print).
- **Then the decor reading ALONE:** `-only-testing:VariorumMobileTests/MobileDecorPlacementReadingTests`. Its DECOR
  expectations red ⇒ the decor's ticket starts with that red on file (the log, the bundle, and `211221f6b` +
  `75984c0e6`, which added the file); green ⇒ R3-F1 closes hollow for the decor. Its BADGE expectations red ⇒ batch
  D's — stop and report. Its REACH expectations red ⇒ the reading's own. Expected by reading: decor red (the decor
  still forces mid-document reads and leaves off-band frames standing), badge green. Either way the file leaves in a
  named commit before any whole-target run.
- **If the probe is not green:** S6's pre-decided arm only if every red line is a badge one earlier estimate short of
  its line (the 74-pt class) — the anchor moves to `insertSubview(_:at: 0)`, rebuilt headless, a short window again,
  the record saying which position was seen red; any other red, or (ii) red on the jump road (S7) ⇒ stop and report.
  The probe is never edited.

**PREDICTED RISK, said before the window (not verified — the implementer runs no test):** the WINDOWLESS harness. The
existing chrome tests mount `MobileWriteSurfaceView` with no window, and two records say its text view then has no
height of its own (`MobileTypewriterRoomTests`: "the surface container's keyboardLayoutGuide collapses windowless";
`MobileBlockListTests`: "the headless harness gives the view no HEIGHT"). If so, TextKit's viewport there may hold only
the top paragraph, and under the called law only overlays inside it are placed. Every windowless test that reads an
overlay on the FIRST block is unaffected; two read overlays further down and would go red for that reason alone, the
product being right: `MobileTakesChromeTests.aFlushEndOneLineFannedAndCommentedBlockNeverCrowdsTheBadge` (it requires a
badge on each of six one-liners) and `MobileTutorialTakesWalkTests.theSwipeLessonPeeksStickyAndTheCheckChooses` (the
rain block is the lesson's third). If exactly those two are red with no badge view, no marker, or the pill not
showing, the remedy is the TESTS' posture, not the product's: mount those two the way the probe and the two new pins
do (a scene window, shown, never key — `makeHostedSurface` in `MobileTakesChromeTests.swift`), named in LIVE STATUS.
It was not done pre-emptively: the final call allows a test only the layout pass it needs, and the zero-height
reading is unproven. The new pin and the guard are hosted for exactly this reason, and do not depend on it.

**For other owners and for round 4 (round 3's S11 and R3-N1; record lines, no code):**
- **VM-179 (wave 4 — "the takes marks lay out only the fanned blocks on screen") — what the takes chrome forces per
  pass, BY READING (not measured here).** *Before:* every full pass (`.document` — deliveries, flips, voice — and the
  first tick after any width change) forced one `firstLineGeometry` for EVERY fanned block (22 on the probe's 150-block
  note, 86 on the 600-block note), plus one whole-block `blockRectsUnion` per peeked block and one for the pill's block,
  each `.ensuresLayout` from the block's own mid-document offset; every scroll tick and keystroke forced the fans in a
  band padded by a viewport of characters (at least 512) each side, the `.edit` band widened by the edited range;
  window (3)'s cost note measured the `.document` pass at 1.81 ms cold / 0.30 ms warm (150 blocks) and 6.02 / 1.24 ms
  (600 blocks). *After:* every scope reads only the fans whose start is inside TextKit's own, unpadded viewport (one to
  three on the probe's note at 700 pt), and the marker and pill read only their block's part inside it — TWICE per
  layout pass (the refresh's walk, then the re-read), each read a lookup in text TextKit has already laid out (or the
  re-layout of a paragraph an edit just invalidated); nothing off screen is read or forced, whatever the scope or the
  note's length. *What of VM-179 is left:* the reservation walk on every pass (every fan's first paragraph, storage
  attributes only, no layout); the walk over the slots to find the fans, now twice per pass (no geometry, but ∝ the
  note's blocks — as the reservation walk always was); and the block decor's forced reads (washes, glyphs, comment
  marks — the decor's ticket, R3-F1, unchanged here).
- **VM-218 (every screen with VoiceOver):** a fanned block outside TextKit's viewport now exposes NO badge to
  VoiceOver — no view exists until it is first placed, and one placed earlier is hidden while its block is off screen
  — where the old chrome exposed a badge for every fan, standing wherever its last read left it. VoiceOver reaches the
  badge once the block is on screen; whether a VoiceOver reader needs the fan announced before that is the VoiceOver
  pass's question.
- **R3-N1 — the pin is unchanged since M5:** the probe's test body (`noFanBadgePilesAndNoneStandsAstrayInTheViewportOnALongNote`)
  is statement for statement what M5 and M5b ran (built at `97282e72f`). Since then the file changed only by the cost
  note's removal and header comment lines (`16c75a5bf`, which moved the test's source lines down by two — the reds M5
  named at `:394`, `:396`, `:398` now sit at `:396`, `:398`, `:400`) and by this batch's three header lines rewritten in
  place (R3-N3; the line count kept, `fanEvery` left as it is). In M5 the pin ran first, before the cost note
  (`vm78-c-M5.log`), so its red owes nothing to its neighbour; reading 1 is not amended (R3-F2's third point: no
  badge view exists that was never placed), so no second red leg for the probe is owed.

#### BATCH D — THE WINDOW AND HER RULING (written by the orchestrator, 2026-11-19 14:10)

**The window (claimed 12:21:06, released 12:27:59; run by the orchestrator from the throwaway detached checkout at
`f4fce656b`, whose code is this branch's code up to `7e5eb2a58`; logs
`App/Variorum/DerivedData/logs/vm78-window-d-{red,green,decor}.log`). THE FIX IS NOT PROVED.**

- **RED leg** — `MobileTakesChromeTests` on the old chrome (the two product files at `15add793d`): 15 tests in 1
  suite FAILED, 9 issues. The three expected ran and failed (`perTickRefreshResolvesOnlyNearViewportGeometry` 4
  issues · `aKeystrokesChromePassIsEditScopedAndWriteFreeWhenNothingMoved` 1 ·
  `aFarFlipDrawsNoMarkerOrPillUntilItsBlockScrollsIn` 3) — and a fourth: the new guard
  `anEmptyFannedLastBlockWearsItsBadgeWhileTheNotesEndIsOnScreen` (`:754`, the badge not drawn), red on the OLD
  chrome too. By round 3's final call that guard is recorded and dropped; what it saw on today's chrome is
  unexplained and goes to the later run as an observation.
- **GREEN leg** — the fix, ten types: 67 tests in 10 suites FAILED, 13 issues, EIGHT tests red.
  - The probe `noFanBadgePilesAndNoneStandsAstrayInTheViewportOnALongNote` ran and failed on `bare.isEmpty`
    (`:400`) and `jumpMissed.isEmpty` (`:406`). `VM17|SUMMARY fans=22 astray=0 bare=17 misses=0 asked=29 (walk
    28, jump 1) skipped=1 walkReached=22 jumpMissed=4`; `VM17|reading2|offscreenDrawn=0`. So the SCROLLING road
    is clean — no astray badge, no (i′) miss, every fan reached — and every one of the 17 bare lines is on the
    JUMP road (`VM17|bare|jump@… badge=none drawn=false`): after `jumpToBlock` the target fan stands on screen
    with no badge; four far targets were not reached at all (`reachedTarget=false`). That is the final call's
    arm "(ii) red on the jump road: stop and report".
  - `MobileTakesChromeTests`: `perTickRefreshResolvesOnlyNearViewportGeometry` (`:598` the NEAR badge is nil;
    `:630` the far fragment IS laid out) · `badgeAppearsOnlyOnFannedBlocksAndOnlyTheyReserveSpace` (`:210`,
    `:211` badge nil) · `aFlushEndOneLineFannedAndCommentedBlockNeverCrowdsTheBadge` (`:417` badge nil) ·
    `theChromeRestylesWithTheVoice` (`:994`, `:1002`) · the guard (`:754`).
  - `MobileTutorialTakesWalkTests.theSwipeLessonPeeksStickyAndTheCheckChooses` (`:805` marker nil, `:806` pill
    not showing) · `MobileWalkTests.walk5_takesBadgePeekAndChoose` (`:351` badge nil).
  - Two of these were named in advance as a possible windowless-host effect; five were not. In six of the seven
    the failing expectation is EXISTENCE (the view was never made), which fits a host with no viewport or no
    layout pass, but nothing in the log shows the viewport: it is NOT established, and the lot is the fix's.
- **The decor reading, alone** — `MobileDecorPlacementReadingTests`: 1 test in 1 suite FAILED, 9 issues, as a
  measurement. `VM17D|SUMMARY stops=61 jumps=70 callouts=30 commented=50 fans=22 inView(washes=155 glyphs=126
  marks=192) washAstray=225 washBare=17 glyphAstray=51 glyphBare=13 markAstray=122 markBare=23 badgeAstray=4
  badgeBare=5 reach(wash=30/30 glyph=30/30 mark=50/50) jumpMissed=22`. **R3-F1 is real for the decor**, and its
  ticket is minted: **VM-239**. (The badge counts inside it are the unproved fix's.)
- Bundles: `d-red` and `d-green` unreadable (both runs failed and lingered the full 90 s), `d-decor` reads. No
  host restart and no zero-executed line in any of the three logs. The crash report stamped 12:05:44 on that
  machine predates the claim and is not this window's.

**HER RULING (2026-11-19, a dialog pick in the orchestrator's session, no prose).** Asked: "VM-17, the stray fan
badges on long notes: the fix I built this morning did not pass its stage window. Should I keep working it inside
VM-78, or take it out and give it its own run?" — with the window's result, the reasons and three options — she
chose **"Take it out, own run (Recommended)"**, worded to her as: "I back the unproven fix out of VM-78 with a
plain revert commit, and the probe and measurement tests leave the branch in named commits the tickets cite, so
main gets no new red test. VM-17, the callout/comment finding and wave 4's VM-179 become one run after wave 1
with all of last night's evidence as its starting point. VM-78 then merges its eight proven fixes plus the
test-hygiene pin."

**What follows from it, in this run:** the back-out (the next implementer's first piece; its commits are named in
that implementer's LIVE STATUS, under "THE MERGE-IN"); the tickets — VM-17 re-owned out of the umbrella
(Confirmed, retitled, a comment with the evidence), VM-239 minted (Bug · Confirmed · Editor · High), VM-179
commented; the later run's kickoff `notes/plans/vm-17-chrome-geometry.md`. Round 3's disposition of R3-F1 is
overtaken: the decor no longer waits behind a badge fix — both go to the one run.

### THE MERGE-IN (the back-out, main merged in, the re-land)

*Implementer: a fresh `opus-implementer` (2026-11-19, afternoon), one session, worktree `~/dev/variorum-vm-78`. Three
pieces in order: (1) the back-out of VM-17's unproven fix (her ruling, BATCH D, "THE WINDOW AND HER RULING");
(2) `origin/main` (`eb18888db`: VX-980 and VM-55) merged in by a merge commit and this run's proven fixes re-landed
on VM-55's seams; (3) both targets built for testing, and the recipe for the orchestrator's short window. No
`xcodebuild test`, no simulator, no walk in this session. **No revert is in flight** — the back-out is made of
`git revert` COMMITS (history), never a working-tree product revert; a red leg's revert is the orchestrator's, in
its own checkout.*

#### THE MERGE-IN — LIVE STATUS

| Piece | State |
|---|---|
| 0 — this LIVE STATUS opens; the trial merge's conflict list | DONE (`0f2094dc2`) |
| 1a — revert the fix `f869f8667` | DONE (`b69d5d12e`) — `git revert --no-commit f869f8667`; its three product files restored to their state before it (`MobileTakesChrome.swift`, `MobileEditorTextView.swift`, `MobileBlockDecor.swift`); the commit's one record line (batch D's build row 2) is KEPT as written — the record is history, and the revert conflicted there only |
| 1b — revert the pins `15add793d` | DONE (`feabe164c`) — `git revert --no-commit 15add793d`: `MobileTakesChromeTests.swift` back to its state before batch D (the re-pins, the marker-and-pill pin and the empty-last-block guard out), and the probe's three header lines (R3-N3) back to `16c75a5bf`'s; the commit's one record line kept as written, as in 1a |
| 1c — remove the probe `MobileFanBadgePlacementProbeTests.swift` | DONE (`1981d4041`) — `git rm`; the commits that hold it: `a570d3960` (introduced), `e3f406086`, `78179b765` (the body M5/M5b ran), `16c75a5bf` (its header shifted two lines), `15add793d` (R3-N3's header — its last edition). The kickoff `notes/plans/vm-17-chrome-geometry.md` said "restore it from the commit before VM-78's back-out commit", which is ambiguous once the back-out is four commits: corrected in place to `git checkout 15add793d -- <its path>` |
| 1d — remove the decor reading `MobileDecorPlacementReadingTests.swift` | DONE (`7d84e4b22`) — `git rm`; the commits that hold it: `211221f6b` (introduced), `75984c0e6` (its last edition, as run alone in batch D's window). The kickoff's wording for it is right as written |
| 1e — the back-out's check | DONE (`79fa4d36d`) — output below |
| 2a — the plan, written before the merge starts | DONE (`b83463516`) — "The plan" below |
| 2b — the merge commit (seven conflicts resolved, the re-land) | DONE (`ed1266e2f`, merging `origin/main` at `eb18888db`) — per file in "The re-land, file by file" below; both targets build (row 3) |
| 2c — the semantic merges git does not flag | DONE — in the merge commit `ed1266e2f` (`requestFinish`'s refusals onto VM-62's road; Book Details' delete line names a gathering); the pins re-shaped to the one line `c652d1669`; the join's own pin `bookDetailsDeleteLineNamesAGathering` (`8d2b9f8bf`); every listed file read against the merged product ("The semantic read" below) |
| 3 — phone + Mac `build-for-testing` on the merged tree | DONE — phone (signed, `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`, no boot, DerivedData `vm78-ios`) **TEST BUILD SUCCEEDED** at `c652d1669` (log `App/Variorum/DerivedData/logs/vm78-mergein-ios-build.log`) and again at `8d2b9f8bf` with the join's pin (`…-ios-build-2.log`); Mac (`-scheme Variorum -destination 'platform=macOS'`, DerivedData `vm78-mac`) **TEST BUILD SUCCEEDED** at `c652d1669` (`…-mac-build.log`; nothing the Mac compiles changed after it). 0 errors; no warning in a line this merge-in wrote |
| 4 — the window recipe (RED, GREEN, the Mac types) | DONE (`5906d1a59`) — "The window recipe" below; its runs are the orchestrator's, PENDING |

**The trial merge** (`git merge-tree --write-tree --name-only HEAD origin/main`, at `de3bb0107` against `eb18888db`,
nothing touched): exactly the seven expected textual conflicts —
`VariorumMobile/Features/Shell/MobileBookDetails.swift`, `Shell/MobileShelfViewModel.swift`,
`Shell/MobileTrashModel.swift`, `Write/MobileMembership.swift`, `Write/MobileUndoDoor.swift`, `notes/MobileSoul.md`,
`notes/SurfaceContracts.md`. Auto-merged textually, to read by hand: `Shared/RecoveryCopy.swift`,
`Shell/MobileCreateBook.swift`, `Shell/MobileLibraryView.swift`, `Shell/MobileShelfView.swift`,
`Shell/MobileTrashView.swift`, `Takes/MobileBlockHistory.swift`, `Write/MobileEditorViewModel.swift`,
`Write/MobileWriteView.swift`, `VariorumMobileTests/MobileDeletionTests.swift`,
`VariorumMobileTests/MobileUndoDoorTests.swift`. Batch D's four product/test files and the two measurement files
are untouched by main (`git diff e48ef2f30 origin/main -- <them>` is empty), so the back-out cannot conflict with
the merge.

**The back-out's check (1e), as run at `7d84e4b22`:**
- `git log --oneline e48ef2f30..HEAD -- <file>` for each of the four files names ONLY batch D's two commits and
  their reverts — so the claim "batch D was the only thing in this run that touched them" is TRUE:
  `Takes/MobileTakesChrome.swift`, `Write/MobileEditorTextView.swift`, `Write/MobileBlockDecor.swift` →
  `f869f8667`, `b69d5d12e` (its revert); `VariorumMobileTests/MobileTakesChromeTests.swift` → `15add793d`,
  `feabe164c` (its revert).
- `git diff e48ef2f30 HEAD -- App/Variorum/VariorumMobile/Features/Takes/MobileTakesChrome.swift
  App/Variorum/VariorumMobile/Features/Write/MobileEditorTextView.swift
  App/Variorum/VariorumMobile/Features/Write/MobileBlockDecor.swift
  App/Variorum/VariorumMobileTests/MobileTakesChromeTests.swift` prints NOTHING (0 bytes).
- None of `MobileFanBadgePlacementProbeTests`, `MobileDecorPlacementReadingTests`, `MobileFanBadgeSettleMeasureTests`,
  `MobileCaretReplaceTraceTests` exists in the tree: `git ls-files` and `git grep` over `App/*.swift` find no file and
  no type of those names (the last two left earlier, `5a57abdf0` and `16c75a5bf`).
- KEPT: `MobileLivenessTests.swift` (VM-19's pin and fix, +23/−1 against `e48ef2f30`);
  `MobileMarkdownCaretTests.swift` untouched against `e48ef2f30` (VM-24's pin, red by her decision).

**The plan (2a), written from main's versions before the merge starts** — the rule for every code conflict: main's
structure wins and this run's BEHAVIOR is re-landed onto it in main's vocabulary.
- `Write/MobileUndoDoor.swift` (VM-16, VM-20). Main's door STILL calls `undo(with:)` / `redo(with:)`, so the
  label-for-a-quiet-press bug is live there: a quiet press reports `undone(label)` with `action: .redo` (the
  mirror `.undo`) and `line: .ordinary` — on the phone the line drops it, so the press is SILENT and the model
  records a stale way back. VM-16 is needed exactly: main's file as the base, `runUndo` / `redo` re-landed on
  `undoReporting` / `redoReporting` — changed → main's report unchanged (`undone`/`redone`, `.redo`/`.undo`,
  `.ordinary`); quiet → `report(StructuralUndoCopy.undoFoundNothing(label))` / `redoFoundNothing`, the funnel's
  default class `.refusal`, no action; nothing on the stack → main's `nothingToUndo` / `nothingToRedo` refusal.
  VM-20: `discardingUndoDetail` forwards to `StructuralUndoCopy.discardingUndoDetail(_:readBackFrom:)` (main's
  file still has the "It is saved first" copy).
- `Shell/MobileBookDetails.swift` (VM-81, F3, F5, N3, R2-N1). Main: `lastError` speaks on the line from its
  `didSet`; every raw dump → `OpsRefusalCopy.sentence(for:roads:)`; `refusal(_:)` ends in
  `DeletionRefusal.sentence(error, roads: .phone)`, whose road reaches the table for `.readingSealed` and
  `.readingNotArchived` (`DeletionRefusal.knownWords` has no arm for either; the table words both, the same bytes
  this run pinned) — so this run's forwarding arm is DELETED and main's road speaks both. Re-landed whole: the
  Finish confirm (`requestFinish` / `confirmFinish` / `finishConfirmPresented`, no `cancelFinish`), `finishRowAct`,
  `finishCaption`, the archived book's resolve (`archivedBook`, `nameLine`, `offersUnarchive`, `unarchive`), the
  sheet's rows with their labels and hints. `requestFinish`'s two `DeletionRefusal.words(…)` move to main's road
  (`DeletionRefusal.sentence(…, roads: .phone)`; VM-62's scan forbids the old road).
- `Shell/MobileShelfViewModel.swift` (VM-83). Main: `MobileWingScope.follow` + `bookshelf(_:wingID:)`, the line.
  Re-landed: no `pins` in the snapshot, `orderedBooks` = `BookcaseBoard.ordered(…, .alphabetical)`, `rowActs`,
  `setPinned` retired, the gathering-aware delete receipt (spoken by main's removal line).
- `Shell/MobileTrashModel.swift` (VM-33). Main: the listing runs once per wing inside `MobileWingScope.follow`.
  Re-landed: `trashListingLoaded` lowered at the top of EACH wing run (the first and every restart) and raised by
  each value.
- `Write/MobileMembership.swift` (VM-81 W-110, VM-21, VM-83). Main: the note's own wing's books, `say(_:as:)`.
  Re-landed: `rowCarriesDiverge`, `kindMark`, `memberRowName`, `addRowLabel`, and the collect receipt =
  `AddToBookCopy.collected(…)` spoken as `.refusal` — the class main gives BOTH collect arms (already-matched: a
  door that did nothing; tagging: a direction, P-55-11).
- `notes/MobileSoul.md`, `notes/SurfaceContracts.md`: both runs' lines kept; this run's row takes the next free
  PL number.
- Semantic merges to hunt after it compiles: VM-62's source scan (`MobileNoRawErrorPinTests`) over this run's new
  phone lines (`String(describing:`, `DeletionRefusal.words(` …); every slot of this run's new code that main moved
  onto the line; this run's tests that read a slot; `MobileEditorViewModel` (the `entryDate` mirror at the one
  `header` assignment), `MobileWriteView` (`dateChipDay`), `MobileTrashView`, `MobileShelfView` /
  `MobileShelfFaces`, `MobileCreateBook`, `Shared/RecoveryCopy.swift`, `MobileDeletionTests`.

**The re-land, file by file (the merge commit; line numbers are the merged tree's).** Main's structure in every file;
this run's behavior on top.
- **`Write/MobileUndoDoor.swift` — VM-16 needed exactly** (main's door still read `undo(with:)` / `redo(with:)`;
  VM-55 did not change the calls). Main's change: the receipt left the masthead (VM-61) — a landed press is
  `.ordinary` (nothing on the line; the ⋯ sheet's Undo/Redo rows stay; the model still records `statusAction`),
  nothing on the stack is `.refusal`; refusals through `OpsRefusalCopy.sentence` (VM-62). On main a QUIET press was
  therefore SILENT on the line while the model recorded "Undid: X" and a way back that acts on another entry. This
  run's rule, re-landed: `runUndo` reads `undoReporting` (`:213`) and `redo()` reads `redoReporting` (`:271`);
  changed → main's report exactly (`undone`/`redone`, `action: .redo`/`.undo`, `line: .ordinary`); QUIET →
  `report(StructuralUndoCopy.undoFoundNothing(label), line: .refusal)` (`:231`) / `redoFoundNothing` (`:282`), no
  action recorded or offered; nil → main's `nothingToUndo` / `nothingToRedo` as `.refusal`. VM-20:
  `discardingUndoDetail` forwards to `StructuralUndoCopy.discardingUndoDetail(_:readBackFrom:)` (`:317`; main's file
  still said "It is saved first").
- **`Shell/MobileBookDetails.swift` — VM-81, F3, F5, N3, R2-N1.** Main's change: `lastError` speaks on the one line
  from its `didSet` (`:56`); dumps → `OpsRefusalCopy.sentence`; `refusal(_:)` → `DeletionRefusal.sentence(error,
  roads: .phone)`; delete and archive now say the shelf row's removal lines. **Main had ALREADY fixed this run's two
  forwarded refusals:** `DeletionRefusal.knownWords` has no arm for `.readingSealed` or `.readingNotArchived`, so
  VM-62's road reaches the table, whose phone sentences are byte-identical to this run's pins — this run's
  forwarding arm is DELETED (`refusal(_:)`, `:384`, a comment says why). Re-landed whole: `pendingFinish` (`:60`),
  `finishRowAct` (`:96`), `finishCaption` (`:107`), `FinishConfirm` (`:117`), `archivedBook` (`:160`), `nameLine`
  (`:175`), `requestFinish` (`:205` — its two `DeletionRefusal.words(…)` moved onto main's road, `:214`, `:218`;
  VM-62's scan forbids the old one), `confirmFinish` (`:236`), `finishConfirmPresented` (`:247`, no `cancelFinish`),
  `offersUnarchive` / `unarchive` (`:253`, `:258` — ordinary, no line: P-55-4), the sheet's rows with their labels
  and hints (`unarchiveRow` `:551`, `deleteRow(_:)` `:579`, `finishRow` `:627`, the hints `:543`, `:574`, `:598`,
  `:660`). **One semantic join:** main's new delete line from Book Details said "Book moved to the Trash…" for a
  gathering; it now composes `RecoveryCopy.movedToTrashReceipt(.book, isGathering:)` (`:307`) — this run's W-073
  rule on main's P-55-8 line (the same act says the same line as the shelf row, whose words name a gathering).
- **`Shell/MobileShelfViewModel.swift` — VM-83.** Main's change: the held listing runs per wing
  (`MobileWingScope.follow`, `bookshelf(db, wingID:)`), refusals onto the line, the delete and archive removal
  lines. Re-landed: `start()` (`:72`) inside main's follow with no `pins` in the snapshot; `orderedBooks` (`:112`) =
  `BookcaseBoard.ordered(…, .alphabetical)` — the wing-scoped listing, ordered by this run's rule; `rowActs`
  (`:139`); `setPinned` retired (`:147`, main's refusal-road edit of it dropped with it); the delete receipt names a
  gathering (`:216`) and main's removal line speaks it.
- **`Shell/MobileTrashModel.swift` — VM-33.** Main's change: the listing runs once per wing inside
  `MobileWingScope.follow`. Re-landed: `trashListingLoaded` (`:63`) is lowered at the TOP of each follow run
  (`:117` — the first run and every wing's re-run) and raised by each value (`:124`); its doc says a failed listing
  speaks on the line, not a red slot.
- **`Write/MobileMembership.swift` — VM-81 W-110, VM-21, VM-83.** Main's change: the note's own wing's books
  (`:150`), `say(_:as:)` onto the line. Re-landed: `rowCarriesDiverge` (`:104`), `kindMark` (`:111`),
  `memberRowName` (`:119`), `addRowLabel` (`:132`), and the collect receipt `AddToBookCopy.collected(…)` spoken
  `.refusal` (`:200`) — the class main gives BOTH collect arms (already matched: a door that did nothing; tagging: a
  direction, P-55-11); for a star or an archived gathering this run's words, for a live tags-only or already-matched
  collect byte-identical to main's (so main's `MobileLineDirectionTests` collect pin keeps its words).
- **`notes/MobileSoul.md`.** Main added PL-75 (VX-980) and PL-76 (VM-55); this run's row, drafted as PL-75, is
  **PL-77**, after them. Its only self-number was its heading (every other PL number in it names another row).
  **For the closeout pass, not done here:** the row still describes VM-17's takes-chrome change as gained and the
  decor reading as owed — both now false after the back-out (VM-17 and VM-239 went to their own run).
- **`notes/SurfaceContracts.md`.** Main changed the Delete bullet (the Trash's own search) and the wing switcher
  bullet (the phone's wings) and added the phone's message-line clause; this run's five clauses are kept beside
  main's words: the Bookcase (the phone's shelf order), the book settings sheet (two: the phone's Finish confirm, the
  membership sheet's "(archived)"), the Delete bullet (two: Delete Gathering… on the phone's shelf row and Book
  Details, the phone's Trash first paint). None of main's lines already states those phone behaviors, so no clause
  was dropped.

**The pins re-shaped (`c652d1669`; each still asserts this run's rule, now also where she reads it — `session.status.current`, the
one line — beside the model's own record, which VM-61 keeps):**
- `MobileUndoDoorTests` — `aQuietUndoSpeaksTheRefusalAndOffersNoRedo`, `aQuietRedoSpeaksTheRefusalAndOffersNoUndo`:
  the quiet press's line exists, is `.refusal`, carries `undoFoundNothing` / `redoFoundNothing` and no action; the
  landed undo between says nothing on the line. **RED against main's door as merged, by reading:** main's door
  classes the quiet press `.ordinary`, so `session.status.current` is nil (the `#require` fails) and
  `statusMessage` is "Undid: Delete Block" / "Redid: Delete Block" with `statusAction` `.redo` / `.undo` (three
  expectations fail before it). `aLandedRedoStillOffersItsUndo`: + nothing on the line — GREEN on both sides by
  design (main's landed press is ordinary too). `MobileUndoWarningWordsTests` needed no change (a pure words pin);
  `theWarningsDetailSaysCommittedInTheMacsSentence` is RED against main's door by reading ("It is saved first").
- `MobileBookFixesTests` — `reopenOnASealedBookSpeaksTheSharedSentence`, `aRacedUnarchiveSpeaksTheSharedSentence`:
  + the table's own call equals the pinned sentence, + the line is that refusal. **GREEN against main's
  `MobileBookDetails.swift` by reading** (VM-62's road reaches the same table sentences) — that half is main's fix
  now; both stay as guards. `theDeleteDoorConfirmAndReceiptNameAGathering`: + the gathering's delete is a removal
  line with its words. `MobileCollectReceiptTests`' five collects: + the line is a `.refusal` with the composer's
  words (`expectOnTheLine`). RED against main's `MobileMembership.swift` by reading for the three that name the
  star or the archive (main composes "Added by tagging …"); the tags-only and already-matched controls GREEN on both.

**The semantic read (2c), file by file against the merged product** — the compiler first (both targets green), then
the assertions:
- **VM-62's source scan** (`MobileNoRawErrorPinTests`) over every phone file: by hand with its own patterns, the
  merged `VariorumMobile/` holds only main's two exempt `MobileStarterJournal` lines and one `privacy:` log line —
  the two `DeletionRefusal.words(…)` this run had added in `requestFinish` were the only offenders, moved onto
  main's road in the merge commit.
- `Write/MobileEditorViewModel.swift`: this run's only lines are the observed `entryDate` and its one set in
  `adoptHeader`, beside the ONE `header = value` (`:696`); main's `report(line:)` untouched. `MobileWriteView`: the
  chip reads `dateChipDay` (auto-merged beside main's removal of the masthead's status row).
- `MobileTrashView` (the gate's face, the gathering/version placeholder), `MobileShelfView` / `MobileShelfFaces`
  (the row's act table, the delete confirm's kind words — main dropped the red slots, nothing of this run drew
  one), `MobileCreateBook` (the gathering words beside main's wing snapshot and line), `Shared/RecoveryCopy.swift`
  (the `isGathering:` overload beside main's edits), `MobileBlockHistory` (VM-43's `insuringBuffer: true` beside
  main's report classes): auto-merged, each read, nothing to change.
- **Tests:** `MobileDeletionTests` (this run's `deleteDoorTitle(for:)` / `deleteConfirmTitle(for:)` beside main's
  line-reading rewrite), `MobileShellTests`, `MobileBooksTests`, `MobileMembershipTests`, `MobileTrashTests`,
  `MobileBlockHistoryTests` (reads `blockHistory.status`, the record main keeps), `MobileTutorialWalkTests`,
  `MobileWalkTests`, `MobileLivenessTests`: each read — they read model records main kept or pure faces, so none
  needed a change; the slot-reading pins that ARE this run's rule were re-shaped (above). Main's own new tests over
  files this run changed were read the other way: `MobileLineDirectionTests`' collect pin (a live tags-only collect
  — this run's composer speaks the same bytes), `MobileLineDoorTests` (a book's delete line from the row and from
  Book Details — byte-identical for a book), `MobileRefusalSentencePinTests` (Finish on a gathering and Reopen on a
  sealed book through `setFinished`, which still exists), `MobileWingListingTests`, `MobileWingBlindPickerTests`.
- **The join's own pin (`8d2b9f8bf`):** `MobileGatheringWordTests/bookDetailsDeleteLineNamesAGathering` — Book
  Details' delete of a gathering speaks "Gathering moved to the Trash…" as a removal line; a book's is unchanged.
  Red against main's `MobileBookDetails.swift` by reading; no file-swap red leg exists for it (main's file lacks
  every symbol the batch-A pins name).
- **Not changed, for the orchestrator:** VM-55's two Mac source scans read a hand-kept list of hoisted Mac BRAINS
  (`VM61MacStatusSeamPinTests.hoistedMacBrains` — "the next hoist adds its file"). This run's hoists are WORDS
  (`BookStateCopy`, `ArrivalsCopy`, `CollectReceiptCopy`, `StructuralUndoCopy`'s detail), not seam-speaking brains,
  and are not on the list; grepped for the scans' patterns (seam calls, phone roads, `#if os(`, face imports) they
  hold none. Whether word hoists join the list is that guard's owner's call — left as VM-55 built it.
- **PROVISIONAL calls from the merge: none new.** Every place the two runs met was vocabulary, not behavior: the
  quiet press is a refusal in main's classes (the Mac door's own); the collect receipt keeps this run's words in
  the class main gives the act; Unarchive from Details stays silent (main's P-55-4: an unarchive is ordinary);
  Book Details' delete line is main's P-55-8 (already PROVISIONAL there) speaking this run's ruled W-073 words.

**The window recipe (4) — for the orchestrator's short window, run from its own checkout at this branch's tip; the
implementer ran no `xcodebuild test` and booted no simulator.**

*RED leg — the re-landed fixes' product files at main's merged version, the tests at the tip.* VM-16 is re-landed
on main's door, and VM-33's gate was re-placed inside main's per-wing follow, so those two are the legs; every
other re-land either is main's own fix now (the sealed and raced-Unarchive refusals — green on both sides by
design) or cannot be file-swapped (main's `MobileBookDetails`, `MobileShelfViewModel`, `MobileMembership` lack the
symbols batch A's pins name). The tree compiles **by reading**: the three files at `eb18888db` declare every symbol
the tip names in them, and the only symbol the tip adds to the pair (`MobileTrashModel.trashListingLoaded`) is read
only by `MobileTrashView`, which reverts with it (grep over `VariorumMobile/` and `VariorumMobileTests/`). Not built
by the implementer — build it in the window's own DerivedData.
```zsh
git checkout eb18888db -- \
  App/Variorum/VariorumMobile/Features/Write/MobileUndoDoor.swift \
  App/Variorum/VariorumMobile/Features/Shell/MobileTrashModel.swift \
  App/Variorum/VariorumMobile/Features/Shell/MobileTrashView.swift
RED=(
  -only-testing:VariorumMobileTests/MobileUndoDoorTests
  -only-testing:VariorumMobileTests/MobileUndoWarningWordsTests
  -only-testing:VariorumMobileTests/MobileTrashTests
  -only-testing:VariorumMobileTests/MobileGatheringWordTests
)
xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'platform=iOS Simulator,id=<simulator-udid>' \
  -derivedDataPath <the checkout's red DerivedData> \
  -resultBundlePath App/Variorum/DerivedData/vm78-bundles/mergein-red.xcresult "${RED[@]}"
# restore: git checkout HEAD -- <the same three files>; `git status` clean before GREEN
```
**Expected RED, by name — six, and no other:**
1. `MobileUndoDoorTests/aQuietUndoSpeaksTheRefusalAndOffersNoRedo` — main's door classes the quiet press ordinary:
   `statusMessage` "Undid: Delete Block", `statusAction` `.redo`, and the line's `#require` finds nothing.
2. `MobileUndoDoorTests/aQuietRedoSpeaksTheRefusalAndOffersNoUndo` — the mirror ("Redid: Delete Block", `.undo`).
3. `MobileUndoWarningWordsTests/theWarningsDetailSaysCommittedInTheMacsSentence` — main's detail says "It is saved
   first" (VM-20).
4. `MobileTrashTests/theFirstPaintSaysNothingBeforeTheListingAnswers` — main's view draws "Nothing in the Trash." on
   `model.trash.isEmpty` (VM-33).
5. `MobileGatheringWordTests/theTrashNamesAnUntitledGatheringAGathering` — main's `rowTitle` says "(empty book)"
   (W-073, rides the Trash view's revert).
6. `MobileGatheringWordTests/theTrashNamesAnUntitledSavedVersionAsOne` — "(empty note)" (N2, the same).

**Expected GREEN on both sides:** `aLandedRedoStillOffersItsUndo` and every other `MobileUndoDoorTests` test (main's
five rewritten pins included); `theWarningsDetailSaysBeforeInLowercaseAndShoutsNothing`;
`anEmptyTrashSaysSoOnceTheListingAnswers` and the rest of `MobileTrashTests` (its DESIGNED known issue,
`anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, on both sides); the rest of
`MobileGatheringWordTests`, `bookDetailsDeleteLineNamesAGathering` included (Book Details is not reverted). Anything
else red is a finding.

*GREEN leg — the tip, restored; every test TYPE this run owns or edited, then main's types over the files this run
changed.* Expected: all green; the one standing phone red (VM-24's `MobileMarkdownCaretTests`) is NOT in the list.
```zsh
GREEN=(
  # this run's own and edited files (TYPE names, checked against the sources)
  -only-testing:VariorumMobileTests/MobileUndoDoorTests
  -only-testing:VariorumMobileTests/MobileUndoWarningWordsTests
  -only-testing:VariorumMobileTests/MobileBlockHistoryTests
  -only-testing:VariorumMobileTests/MobileTrashTests
  -only-testing:VariorumMobileTests/MobileFinishConfirmTests
  -only-testing:VariorumMobileTests/MobileBookStateRowTests
  -only-testing:VariorumMobileTests/MobileArchivedStarredBookTests
  -only-testing:VariorumMobileTests/MobileShelfOrderTests
  -only-testing:VariorumMobileTests/MobileShelfRowActsTests
  -only-testing:VariorumMobileTests/MobileGatheringWordTests
  -only-testing:VariorumMobileTests/MobileCollectReceiptTests
  -only-testing:VariorumMobileTests/MobileBookCreateTests
  -only-testing:VariorumMobileTests/MobileBookDetailsTests
  -only-testing:VariorumMobileTests/MobileBookNameGuardTests
  -only-testing:VariorumMobileTests/MobileMembershipTests
  -only-testing:VariorumMobileTests/MobileNoteRenameTests
  -only-testing:VariorumMobileTests/MobileNoteEntryDateTests
  -only-testing:VariorumMobileTests/MobileShellTests
  -only-testing:VariorumMobileTests/MobileWalkTests
  -only-testing:VariorumMobileTests/MobileDeletionTests
  -only-testing:VariorumMobileTests/MobileLivenessTests
  -only-testing:VariorumMobileTests/MobileTutorialBookShapeTests
  -only-testing:VariorumMobileTests/MobileTutorialDoorTests
  -only-testing:VariorumMobileTests/MobileTutorialWritingWalkTests
  -only-testing:VariorumMobileTests/MobileTutorialTakesWalkTests
  -only-testing:VariorumMobileTests/MobileTutorialStructureWalkTests
  -only-testing:VariorumMobileTests/MobileTutorialLibraryWalkTests
  -only-testing:VariorumMobileTests/MobilePocketGuidePrivacyTests
  -only-testing:VariorumMobileTests/MobileTutorialStarCapTests
  -only-testing:VariorumMobileTests/MobilePocketGuideDeletionTests
  -only-testing:VariorumMobileTests/MobileTakesChromeTests
  -only-testing:VariorumMobileTests/MobileFilterTests
  # main's (VM-55) types over files this run changed
  -only-testing:VariorumMobileTests/MobileLineDirectionTests
  -only-testing:VariorumMobileTests/MobileLineDoorTests
  -only-testing:VariorumMobileTests/MobileLineShowRuleTests
  -only-testing:VariorumMobileTests/MobileNoRawErrorPinTests
  -only-testing:VariorumMobileTests/MobileRefusalSentencePinTests
  -only-testing:VariorumMobileTests/MobileErrorLogPrivacyPinTests
  -only-testing:VariorumMobileTests/MobileWingListingTests
  -only-testing:VariorumMobileTests/MobileWingBlindPickerTests
  -only-testing:VariorumMobileTests/MobileNavigationTests
)
xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'platform=iOS Simulator,id=<simulator-udid>' \
  -derivedDataPath App/Variorum/DerivedData/vm78-ios \
  -resultBundlePath App/Variorum/DerivedData/vm78-bundles/mergein-green.xcresult "${GREEN[@]}"
```
(`MobileTakesChromeTests`, `MobileTutorialTakesWalkTests` and `MobileWalkTests` are the back-out's evidence too:
batch D's window had their chrome tests red on the reverted fix; they run here on the restored chrome. The
signed `build-for-testing` into `vm78-ios` is current at `8d2b9f8bf`, so this leg starts built.)

*The Mac types that read the `Shared/` files this run changed* (`ShelfOrder`, `BookcaseBoard`, `BookStateCopy`,
`ArrivalsCopy`, `CollectReceiptCopy`, `RecoveryCopy`, `StructuralUndoCopy`), found by grepping `VariorumTests/` for
the moved symbols and reading each matched file's TYPE names (a file can hold several). Tier 1 is batch A's and
batch B's proven list (window (1), 110/17); tier 2 is the rest of the grep's reach plus main's three Mac scan pins,
which read the Mac sources this run changed. Some tier-2 files are serialized or pointer-driven suites — the
window's usual idle-machine check applies.
```zsh
MAC1=(
  -only-testing:VariorumTests/BookStateDoorsTests
  -only-testing:VariorumTests/BookSettingsSheetTests
  -only-testing:VariorumTests/GatheringKindWordTests
  -only-testing:VariorumTests/ArrivalsDoorPlacementTests
  -only-testing:VariorumTests/BookArrivalsTests
  -only-testing:VariorumTests/GatheringCollectReceiptTests
  -only-testing:VariorumTests/GatheringCollectStarReceiptTests
  -only-testing:VariorumTests/VocabularySweepTests
  -only-testing:VariorumTests/BookArchiveDoorActTests
  -only-testing:VariorumTests/BookSettingsArchiveRowTests
  -only-testing:VariorumTests/ArchivedBooksGroupTests
  -only-testing:VariorumTests/ShelfModelTests
  -only-testing:VariorumTests/TutorialBooksLessonTests
  -only-testing:VariorumTests/TutorialMCPChapterTests
  -only-testing:VariorumTests/GatheringRuleGateTests
  -only-testing:VariorumTests/UndoWarningWordsTests
  -only-testing:VariorumTests/DestructiveUndoWarningTests
)
MAC2=(
  -only-testing:VariorumTests/VM61MacStatusSeamPinTests
  -only-testing:VariorumTests/VM62MacRefusalWordsPinTests
  -only-testing:VariorumTests/VM63MacWingBrainsHoistPinTests
  -only-testing:VariorumTests/BookArchivedLineTests
  -only-testing:VariorumTests/BookDeleteAndDuplicateTests
  -only-testing:VariorumTests/BookStructureModelTests
  -only-testing:VariorumTests/JournalBooksTests
  -only-testing:VariorumTests/BookDropTests
  -only-testing:VariorumTests/BookPanelDragGateTests
  -only-testing:VariorumTests/NewNoteInBookTests
  -only-testing:VariorumTests/BookArchiveDeclarationTests
  -only-testing:VariorumTests/ArchivedMarkTests
  -only-testing:VariorumTests/ComesBackReceiptTests
  -only-testing:VariorumTests/WingContentsArchivedWordsTests
  -only-testing:VariorumTests/TutorialBooksRitualTests
  -only-testing:VariorumTests/ConfirmCommaWordsTests
  -only-testing:VariorumTests/AscentKindWordsTests
  -only-testing:VariorumTests/BookCopyFamilyTests
  -only-testing:VariorumTests/OwnershipBadgeTests
  -only-testing:VariorumTests/UnfiledWordTests
  -only-testing:VariorumTests/BookArrivalsReviewTests
  -only-testing:VariorumTests/ArrivalArmsTests
  -only-testing:VariorumTests/BookcasePlacingGripTests
  -only-testing:VariorumTests/BookcaseStarredShelfBrainTests
  -only-testing:VariorumTests/BookcaseStarredShelfDropTests
  -only-testing:VariorumTests/AddToBookMintTests
  -only-testing:VariorumTests/MCPWingFacesTests
  -only-testing:VariorumTests/TagAndFolderTests
  -only-testing:VariorumTests/FreeTypedTagTests
  -only-testing:VariorumTests/PromoteAndPaletteTests
  -only-testing:VariorumTests/BookcaseBoardBrainTests
  -only-testing:VariorumTests/MoveToShelfGateTests
  -only-testing:VariorumTests/BookcaseViewModelTests
  -only-testing:VariorumTests/BookcaseMastheadPopoverTests
  -only-testing:VariorumTests/NoteDeletionDeclarationTests
  -only-testing:VariorumTests/NoteDeletionActTests
  -only-testing:VariorumTests/NoteDeletionNavigateAwayTests
  -only-testing:VariorumTests/NoteDeleteConfirmEdgeTests
  -only-testing:VariorumTests/SnippetsVocabularyTests
  -only-testing:VariorumTests/SnippetFilterTests
  -only-testing:VariorumTests/SnippetsGroupDoorsTests
  -only-testing:VariorumTests/BookDoorsEverywhereTests
  -only-testing:VariorumTests/BookCollectingDoorsTests
  -only-testing:VariorumTests/SnippetGroupTrashTests
  -only-testing:VariorumTests/IAAndTrashShapeTests
)
xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme Variorum -destination 'platform=macOS' \
  -derivedDataPath App/Variorum/DerivedData/vm78-mac "${MAC1[@]}" "${MAC2[@]}"
```
(`vm78-mac` is built for testing at `c652d1669`; nothing the Mac compiles changed after it.)

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

**Round 2's result: 0 BLOCKER · 0 MAJOR · 3 MINOR · 5 NIT** (findings `a00581328`, final calls `874da32d8`; every
finding confirmed, none disputed, none FINDER-FIXES; it re-checked each of round 1's final calls as applied, and
read the kept logs for window (5)'s red leg and F4's follow-up). Dispositions:

| Finding | Final call | What changes |
|---|---|---|
| R2-F1 MINOR — window (5)'s red bundle is unreadable; the stop rule will make more | CONFIRMED (the orchestrator's answer: agreed) | recorded as unreadable with its kept log as the evidence; from here a 90 s grace before a lingering `xcodebuild` is stopped, each bundle checked with `xcresulttool`, every log kept under `DerivedData/logs/` |
| R2-F2 MINOR — batch C's arms leave two columns unread (the real posture's own posture; the report's widening) | CONFIRMED, record only | two more "no arm" lines; H1's confirmation gains the report reaching the terminator; arm A's fixed `host` asserts the three things it waited for — applied before window (3) (`046a886fc`) |
| R2-F3 MINOR — the probe's reading (i) trusts the badge's own fragment | CONFIRMED with refinements | reading (i′): what TextKit says stands at the badge; HOLLOW needs (1), (i), (i′), (ii) all green — applied before window (3) (`78179b765`) |
| R2-N1 NIT — the explicit labels hide the rows' captions from VoiceOver | CONFIRMED, all four rows | `.accessibilityHint` carries each row's drawn caption; pin `theBookDetailsRowsSpeakTheirCaptionsAsHints` (`01205f799`, fix `97282e72f`); its red/green rides the next short window; if the driver cannot read SwiftUI hints the modifiers and pin come out and the line goes to the phone's VoiceOver pass |
| R2-N2 NIT — the fix-pin recipe's array misnames F4's type | CONFIRMED | the array marked as run, the follow-up's leg and results beside it, F4's row flipped (`ed7b82ef4`) |
| R2-N3, R2-N5 NIT — a filter to quote; a stale cite | CONFIRMED | record lines (`046a886fc`) |
| R2-N4 NIT — Unarchive's double press meets the refusal | CONFIRMED as a line for VM-62's run | no code |

**The ladder does not close on round 2** (round 1's F1): a further fresh round reads window (3)'s outcome and the
instruments' removal, reading (i′) and its run, R2-N1's fix with its red and green, R2-F2's lines, and VM-16
re-landed on main's message seam.

### Round 3 — `vm-78-ladder-round3.md` (a fresh `fable-reviewer`; opened at tip `35ce90848`)

**0 BLOCKER · 1 MAJOR · 5 MINOR · 3 NIT**, none against a product line this run changed (findings `117e8c047`,
final calls `b7161468b`; none disputed, none FINDER-FIXES). It read window (3)'s outcome, the instruments' removal,
reading (i′), R2-N1's fix, the VM-24 write-up, batch D's trace and the closeout drafts; its final calls also read
the settle measurement's log. Dispositions:

| Finding | Final call | What changes |
|---|---|---|
| R3-F1 MAJOR — the block decor (callout washes and glyphs, comment marks) shares the standing-frame rule and the forced helpers; unmeasured | CONFIRMED; the orchestrator's disposition taken | batch D stays the badge's (with its markers and pill); the decor gets a ticket carrying a MEASURED reading as its pin — its own test type, run alone in the fix's green window (red ⇒ the ticket starts with red on file; green ⇒ hollow for the decor), then out of the tree in a named commit; one comment line in `MobileBlockDecor.swift`, no decor code |
| R3-F2 MINOR — three places where "in-band only, hide the rest" as worded falls short | CONFIRMED | they become the fix shape's same-pass re-read, "a nil viewport resolves nothing", and no amendment to reading 1 |
| R3-F3 MINOR — the instrument's display-link fallback bug | CONFIRMED as a bug; no action | nothing was decided on the `link` moment; the instrument leaves |
| R3-F4 MINOR — two readings the instrument did not take | WITHDRAWN | the branch `passEnd` was to split never occurred; every pass now ends with a re-read inside the layout pass, never on a hop |
| R3-F5 MINOR — VM-24's reach was understated | CONFIRMED | the reach table's typing row and the live state reworded: a typed character can land unarmed; the options' consequence written; it leads the handoff |
| R3-F6 MINOR — the steps to the gate pre-dated the second red test and the new instrument | CONFIRMED | live state step 5 names them and the rule for the red probe |
| R3-N1, R3-N2 | CONFIRMED | a sentence that the pin test is unchanged since M5; the closeout drafts refreshed before the gate, with `grep -n PENDING notes/MobileSoul.md notes/SurfaceContracts.md` answering nothing as a merge precondition |
| R3-N3 | CONFIRMED in part | the probe's header comment updated; the `fanEvery` tidy withdrawn so the pin's compiled bytes stay what M5 ran |

**VM-17's fix shape is called** (round 3's "Final calls", written to be built from): geometry scoped to TextKit's
viewport — no read begins outside it; a badge or marker view exists only once placed, is hidden with its frame
kept when its block leaves the viewport, removed when its fan or peek dies; one geometry walk for every scope;
and a second geometry walk in the same layout pass from a zero-size anchor subview's `layoutSubviews`, on the
fresh viewport (the measured moment: after the text view's own layout, before anything is drawn). The settle
measurement behind it: at that moment the unforced read equals the settled position in 118 of 118 band-fan reads
(the ideal layout in all 28 on-screen ones), while the chrome's badge was off in 49 until it read again.

**Round 4 is earned (a MAJOR) and owed anyway:** one fresh round reads batch D's fix against the shape, its
windows, and VM-16 re-landed on main's message seam. The probe must be green again on the merged tree at the
gate (the measured moment depends on the layout pass's order, and another wave-1 run works in the same file).

## Closeout

#### THE CLOSEOUT RE-FIT — LIVE STATUS

*A documents-only session (2026-11-19, afternoon): no code, no test, no build, no simulator, no stage. It re-fits the
closeout documents to the settled outcome — VM-17's fix backed out by her ruling (BATCH D, "THE WINDOW AND HER
RULING"), `origin/main` merged in and the run's fixes re-landed ("### THE MERGE-IN"). Every fact traces to this
file, the round files, the code at HEAD, or git; where two places disagree the code at HEAD and the newest dated
text win. Run order 0, 1, 2, 3, 4, 6, then 5 (FOR A LATER READER is written last). **The re-fit is DONE; no piece is
in flight.** Another session may place the re-land's window result into its `PENDING(…)` slots.*

| Piece | State |
|---|---|
| 0 — this LIVE STATUS opens | DONE (`648929eff`) |
| 1 — `notes/MobileSoul.md` row PL-77 made true of HEAD | DONE (`e24e0fb81`) — the takes-chrome claim out; VM-17 (with VM-239 and VM-179, the kickoff named) under STILL OWED; VM-16's sentence as the re-landed door speaks (the one line, a refusal, no way back recorded); the sealed Reopen's sentence credited to VM-62's road; the VM-218 viewport clause out; "Verified so far" = the pre-merge windows + both targets built on the merged tree. `grep -n PENDING` on MobileSoul and SurfaceContracts answers nothing. SurfaceContracts' five clauses re-read in the merged file: all five true of HEAD, each beside VM-55's and VX-980's lines; none changed |
| 2 — the three #274 canon sites (AppSpec §9 twice, OverallModel §3) | DONE (`3471d0ad4`) — both checks passed first: QUESTIONS #274 addendum 2 carries "P-849-1 RATIFIED + the phone wired (the insured restore stands; the phone's one-argument insurance is VM-43)", and the phone's one restore door passes `insuringBuffer: true` at HEAD (`Takes/MobileBlockHistory.swift`, `restore(_:of:confirmed:)`, after its flush). Applied verbatim from "Canon delta proposed"; `git diff --word-diff` shows only "PROVISIONAL," dropped and "on both platforms" added, three times; no other word, no reflow |
| 3 — `notes/TEXTKIT2_NOTES.md` §3: the two iOS 26.2 facts this run measured | DONE (`02a3ac002`) — one "iOS 26.2 measured findings (VM-78 …)" block in §3's own shape, after the macOS 27.0.1 VX-601 block and before "Spell check / completion": (a) the unarmed replace's report widened past the line's terminator inside `processEditing`, with window (3)'s ranges, its five-of-six / six-of-six split and the iteration-to-iteration instability, pointing at VM-24's kickoff; (b) the forced mid-document read's stale frame (9,276 / 4,716 pt at load, 1,260 pt astray, 74 pt short in 11 of 11) against the unforced read at the first subview after the text view's own layout (118 of 118; 28 of 28 on screen; "settled" only on screen), and the first fix built on it failing on the jump road — a measurement, not a recipe, pointing at VM-17's kickoff. Named as measured on the phone suites' simulator, iPhone 17 Pro / iOS 26.2; no id written |
| 4 — this `## Closeout`, re-fitted section by section | DONE (`92333a505`) — every section from the opening paragraph to "Not done" re-fitted to the settled outcome ("The run's state when ladder round 1 opened" left as written, history): VM-17 and VM-24 as traced findings handed to their own runs, VM-17's first fix and its window as history; every shipped member's row re-checked against the merged tree, the re-land's commit beside the original; batch D's window, the back-out's check and the merge-in's builds in the evidence table; her VM-17 ruling added (item 10) and every ruling re-reconciled; the wording table re-read against HEAD; the owner lines re-pointed (VM-62's moot, R2-N4's latch to a ticket); VM-239 out of "to file"; the canon deltas in the past tense with their commits; every draft for main re-written. Kept as `PENDING(…)` slots, and only these: the re-land's stage window, ladder round 4, the gate's three legs, `Tools/canon-size`, the QUESTIONS number, the minted ticket ids, the PR number and the merge SHA, and the conditional wave-1 install |
| 5 — `## FOR A LATER READER`, rewritten last | DONE (`f2eb1c42b`) — rewritten whole from the settled facts, within a page: the eight shipped members' mechanisms and one pointer per piece (the re-land `ed1266e2f`, `c652d1669`, `8d2b9f8bf` where it changed the shape); VM-24 and VM-17 as traced findings handed to their own runs, each with its kickoff and the evidence it reads, no fix of either described as built; her rulings by where they are quoted; the evidence lines; the canon with commits; the open items. Every hash it cites resolves and is an ancestor of HEAD (checked with `git cat-file -t` and `git merge-base --is-ancestor`). The STATUS banner stays OPEN |
| 6 — `notes/handoffs/vm-78-handoff.md`, re-fitted for her | DONE (`3107de895`) — rewritten whole in plain words: her checklist at the top, leading with her two decisions (VM-24's own run, launched by the coordinator once wave 1 has merged, starting with a session on her phone; VM-17 taken out after its failed window, one run with VM-239 and VM-179, hers to launch with the exact command and the kickoff); the eight fixes as the merged tree has them; the two provisional calls; the wording pass; "Two canon lines I changed, for your eyes" (pieces 2 and 3, old beside new); the evidence with slots; the trip-wires; the conditional install slot; the canon-size slot; "Tickets filed:" last, VM-239 minted and the six still to mint as `PENDING(id)` |

**OPEN — re-fitted 2026-11-19 at tip `02a3ac002` to the settled outcome, by a documents-only session (no code, build
or stage; its LIVE STATUS is above).** This run closes on EIGHT proved members — VM-16 (with VM-20), VM-43, VM-3,
VM-84, VM-33, VM-81, VM-83 and VM-21 — plus VM-19's teardown pin. VM-24 and VM-17 were each traced here and each
left for its own run by her rulings: neither is fixed by this run, and neither closes with it. **Done:** batches B
and A, every code fix of ladder rounds 1 and 2, and VM-19's pin, each proved red on the old code and green on the
fix in stage windows before the merge; batch C's traces of VM-24 and VM-17 (window (3)); batch D's trace, its settle measurement, its build and its window, which the fix FAILED; her ruling to take VM-17
out; the back-out (the fix and its pins reverted, the probe and the decor reading removed, each in a named commit);
`origin/main` (`eb18888db`: VX-980 and VM-55) merged in by `ed1266e2f`, the run's fixes re-landed on VM-55's seams,
the pins re-shaped to the one message line (`c652d1669`), the merge's one semantic join pinned (`8d2b9f8bf`), and
both targets built for testing on the merged tree; ladder rounds 1, 2 and 3; the canon deltas (below). **Still
ahead, each a `PENDING(…)` slot below:** the re-land's stage window; ladder round 4 and any round it earns; the
gate's three legs (the whole phone target, the Mac leg, the simulator walk); the shared ledgers at the merge moment
(the QUESTIONS number, the minted ticket ids); `Tools/canon-size`; the PR and its merge SHA. Nothing marked PENDING
is claimed. Facts here trace to this file, the three round files, the two kickoffs
(`notes/plans/vm-24-unwarned-edit-routing.md`, `notes/plans/vm-17-chrome-geometry.md`), the code at HEAD, or git
(`git log e48ef2f30..HEAD`); where an older line in this file and the newest dated text differ, the newest dated
text ("The orchestrator's live state" UPDATEs, BATCH D's "THE WINDOW AND HER RULING", "THE MERGE-IN") and the code
at HEAD win.

### Results, member by member

Ten members, plus VM-20 (carried by VM-16) and VM-19 (carried by VM-24) — both already closed at VM-44 as
duplicates of their carriers, so their work is answered here. "Window (n)" is a stage window in the evidence table
below; "red/green" means the pin was seen red on the pre-fix product and green on the fix. **"Re-landed"** names
how a fix sits on the merged tree where VM-55 had moved its seams: the merge commit `ed1266e2f` (main's structure in
every file, this run's behavior on top — "THE MERGE-IN", "The re-land, file by file"), with the pins re-shaped to
read the one line (`c652d1669`). Every pre-merge window ran on the code before the merge; on the merged tree the
fixes are built for testing and read, and their windows are the slots below.

**VM-16 — the undo door (Urgent; W-145).**
- *What was wrong.* `MobileUndoDoor.runUndo` / `redo()` called `UndoStack.undo(with:)` / `redo(with:)`, which hand
  back the entry's label for a QUIET press too. A quiet half retires its entry and leaves the other stack as it
  was, so the phone said "Undid: X" and offered a Redo whose press re-applied a different entry (and the mirror
  for a quiet redo). VM-55's door still read `undo(with:)` / `redo(with:)`: on main a quiet press passed SILENTLY
  as an ordinary act (VM-61's class) while the model recorded "Undid: X" and a way back acting on another entry.
- *What changed.* The Mac door's three arms through `undoReporting` / `redoReporting` (`48055fa9c`; the pins'
  typed-local fix `a11af21d0`). **Re-landed on VM-55's message line** (`ed1266e2f`): changed → main's report
  exactly (`undone` / `redone`, the other direction recorded, `line: .ordinary` — nothing on the line; Undo and
  Redo stay in the ⋯ sheet); quiet → `StructuralUndoCopy.undoFoundNothing` / `redoFoundNothing` spoken as a
  REFUSAL on the one line, no action recorded; nothing on the stack → main's refusal (`MobileUndoDoor.swift`,
  `runUndo` and `redo()` at HEAD).
- *Pin.* `MobileUndoDoorTests` — `aQuietUndoSpeaksTheRefusalAndOffersNoRedo`, `aQuietRedoSpeaksTheRefusalAndOffersNoUndo`,
  re-shaped to read the line as well as the model's record (`c652d1669`); control `aLandedRedoStillOffersItsUndo`
  (plus nothing on the line).
- *Evidence.* Window (2): both red on the pre-fix door, green on the fix. On the merged tree: built; red against
  main's door by reading ("THE MERGE-IN", "The pins re-shaped"); PENDING(the re-land's stage window: the two quiet
  pins red with `MobileUndoDoor.swift` at `eb18888db`, green on the tip). Read by ladder round 4 as new work —
  PENDING(ladder round 4).

**VM-20 — the undo warning's word (carried by VM-16; W-146).**
- *What was wrong.* The phone's warning detail said "It is saved first" where the Mac says "It is committed
  first" (the commit vocabulary).
- *What changed.* The Mac's sentence moved whole to `Shared/StructuralUndoCopy.discardingUndoDetail(_:readBackFrom:)`;
  the Mac's `Registry/ShellActions.swift` forwards it with "the take's history (⌘S's list)", bytes unchanged; the
  phone forwards it with "the block's Block History" (`48055fa9c`). VX-342 had already landed, so no shouted
  capital existed to drop and nothing here is PROVISIONAL. **Re-landed** in the merge (`ed1266e2f`; main's door
  file still had "It is saved first").
- *Pin.* `MobileUndoWarningWordsTests/theWarningsDetailSaysCommittedInTheMacsSentence`; the Mac's byte guard
  `UndoWarningWordsTests`.
- *Evidence.* Window (2) red/green; the Mac guard green inside window (1)'s Mac leg. On the merged tree:
  PENDING(the re-land's stage window: the words pin red with the door at `eb18888db`, green on the tip) and
  PENDING(gate 2, the Mac leg: `UndoWarningWordsTests` on the merged tree).

**VM-43 — restores keep the words they replace (W-181).**
- *What was wrong.* `MobileBlockHistoryController.restore` (which already flushed pending typing) called
  `ops.restoreCommit(variantID, commitID:)` without insurance, so the words a restore replaced were kept nowhere.
- *What changed.* The one phone call site passes `insuringBuffer: true` — the only `restoreCommit` call under
  `VariorumMobile/` and `Shared/` (`Takes/MobileBlockHistory.swift`, `0f8ca319d`; at HEAD in `restore(_:of:confirmed:)`,
  after its flush). The merge auto-merged it beside main's report classes; read, unchanged. Her ruling: QUESTIONS
  #274 addendum 2 (below); the canon now says it without PROVISIONAL (`3471d0ad4`).
- *Pin.* `MobileBlockHistoryTests/aRestoreKeepsTheReplacedWordsAsAQuietSavepoint` (control
  `aRestoreOverABufferEqualToItsLastSavepointAddsNoSavepoint` — the dedupe).
- *Evidence.* Window (2) red/green; on the merged tree, PENDING(the re-land's stage window: its GREEN leg carries
  `MobileBlockHistoryTests`).

**VM-3 — the tutorial's retired lesson (W-218).**
- *What was wrong.* The pocket guide's "divide with takes" lesson taught the duplicate divide ("copied onto both
  halves") while the phone divides keep-on-top (`KeepOnTopDivide` → `divideW`), and its walk pin asserted the
  old shape inside `withKnownIssue`.
- *What changed.* The lesson's blocks 1–2 rewritten — a DRAFT for her wording pass (the table below); the walk pin
  unwrapped and flipped to assert keep-on-top (`Tutorial/MobileTutorialSeeder.swift`, `c29095d35`, `a11af21d0`).
  The Mac's guide is untouched. The merge did not touch the seeder's lesson.
- *Pin.* `MobileTutorialStructureWalkTests/theFannedDivideLessonSaysKeepOnTop` (the red-on-old words pin);
  `theFannedDivideLessonLandsKeepOnTop` is green on both sides by design (the divide itself did not change).
- *Evidence.* Window (2) red/green; on the merged tree its types ride PENDING(the re-land's stage window, its GREEN
  leg).

**VM-84 — the date chip (EDITOR SEAM; W-161).**
- *What was wrong.* `header` is `@ObservationIgnored`; the chip read `header?.entryDate`, so it re-rendered only
  when an observed sibling changed in the same pass — `displayTitle`, which is the date only on an untitled note.
  On a titled note a date change left the chip on the old day.
- *What changed.* A small observed `entryDate` mirror set in `adoptHeader` (the file's own pattern, beside
  `isSealed` and `displayTitle`), read through `MobileWriteView.dateChipDay` (seam `2d66e9a30`, fix `f933a4663`).
  No `MobileEditorTextView`, `BlockRangeIndex`, gate or routing line is touched. An implementation choice among
  three weighed in batch B's LIVE STATUS; not PROVISIONAL. The merge auto-merged both files beside main's lines
  (the mirror's one set sits beside the one `header = value`; the chip beside main's removal of the masthead's
  status row); read, unchanged.
- *Pin.* `MobileNoteEntryDateTests/theDateChipFollowsTheDateWhenTheTitleDoesNot` (in `MobileMembershipTests.swift`;
  its third arm: an unchanged header wakes nothing).
- *Evidence.* Window (2) red/green; on the merged tree its type rides PENDING(the re-land's stage window, its GREEN
  leg).

**VM-33 — the Trash's first paint (filed Suspected; found REAL; W-057).**
- *What was wrong.* `MobileTrashView` drew "Nothing in the Trash." on `model.trash.isEmpty` before the `.task` that
  starts the Trash observation could run, so every opening of a non-empty Trash painted "empty" first — the Mac's
  VX-670 mechanism.
- *What changed.* `MobileTrashModel.trashListingLoaded` (lowered when the listing starts, raised by each value) and
  `MobileTrashView.emptyStateLine(_:)` (nil until the listing answers) — the Mac's rule carried on the phone's own
  model, not hoisted, because the Mac's is a computed property over its own model rather than a pure function
  (`e1d709b1b`). **Re-landed inside VM-55's per-wing follow** (`ed1266e2f`): the flag is lowered at the top of each
  wing's run — the first and every re-run — and raised by each value.
- *Pin.* `MobileTrashTests/theFirstPaintSaysNothingBeforeTheListingAnswers` (control
  `anEmptyTrashSaysSoOnceTheListingAnswers`).
- *Evidence.* Window (2): red on the pre-fix tree, so the member is real, not hollow. On the merged tree:
  PENDING(the re-land's stage window: the pin red with the Trash pair at `eb18888db`, green on the tip).

**VM-81 — Finish asks before it dismisses; book doors only where they work (W-105, W-106, W-110, W-120).**
- *The Finish confirm (W-105).* Was: Finish called `lockReading`, whose transaction dismisses every pending
  arrival, so notes waiting at Arrivals were tombstoned unseen. Now: `MobileBookDetailsModel.requestFinish()` reads
  `Queries.pendingArrivalCount` (the dismissal's own predicate) and, when N > 0, asks "Finish “‹name›”?" with "N
  waiting at Arrivals will be dismissed." and Finish / Cancel; with nothing waiting it acts at once (`aa4a8670f`).
  "Open Arrivals first" is NOT built (VM-175).
- *The caption (W-106).* Was: "a finished book reads ✓ and freezes its notes" / "finished — its notes and order are
  frozen" (false: the text stays editable). Now: the Mac's `BookStateCopy.finishedMeans`, and `sealedMeans` on a
  sealed book (`081af74b0`).
- *Finish not on a gathering (W-106).* `finishRowAct(for:)` reads the Mac's finish pair: a gathering draws nothing,
  unless already finished (legacy), then Reopen alone (`081af74b0`).
- *Reopen on a sealed book (W-106).* Was: "That couldn't be done — readingSealed(id: …)." Built: this run's arm
  forwarded `.readingSealed` to the shared table with the phone's roads (`081af74b0`). **At the merge main had
  already reached the same sentence** — VM-62's road (`DeletionRefusal.sentence(error, roads: .phone)`) falls to
  the table for `.readingSealed` and `.readingNotArchived` — so this run's forwarding arm is DELETED and main's road
  speaks both, the same bytes this run pinned ("This book is sealed, so it can't be reopened here." · "That book
  isn't archived any more — nothing changed."; `MobileBookDetailsModel.refusal(_:)` at HEAD). The two pins stay as
  guards (green on both sides by reading).
- *Diverge on a gathering row (W-110).* `rowCarriesDiverge(_:)` is book rows only (`081af74b0`). PROVISIONAL under
  F8: the Mac's chip still draws it and refuses.
- *The starred archived book (W-120).* Was: Details resolved its book from `Queries.bookshelf`, which drops archived
  books, while `Queries.starred` keeps them and archiving never unstars — so Starred → the book opened an empty
  sheet with no way back. Now `archivedBook(_:id:absentFrom:)` resolves it, the name wears "(archived)", and an
  Unarchive row runs `unarchiveReading` with no line (an ordinary act — main's P-55-4) (`081af74b0`; face polish
  `5681d8304`).
- *Round 1 and round 2.* F3: Unarchive's raced refusal (`readingNotArchived`) speaks "That book isn't archived any
  more — nothing changed." (since the merge by main's road, above). F5: the Finish row carries its verb as its
  label and `cancelFinish()` is gone (both `326d61da4`). R2-N1: the four act rows carry their drawn captions as
  `.accessibilityHint` (pin `01205f799`, fix `97282e72f`).
- *At the merge (`ed1266e2f`).* Main's file as the base; re-landed whole: the Finish confirm (`requestFinish`,
  `confirmFinish`, `finishConfirmPresented`, no `cancelFinish`), `finishRowAct`, `finishCaption`, the archived
  book's resolve and Unarchive, the rows' labels and hints; `requestFinish`'s two refusals moved onto main's road
  (VM-62's source scan forbids the old one). **One semantic join:** main's Book Details delete line (P-55-8) said
  "Book moved to the Trash…" for a gathering; it now composes `RecoveryCopy.movedToTrashReceipt(.book,
  isGathering:)`, the shelf row's words — pinned `MobileGatheringWordTests/bookDetailsDeleteLineNamesAGathering`
  (`8d2b9f8bf`; red against main's file by reading — no file-swap red leg exists for it).
- *Pins.* `MobileFinishConfirmTests` (`finishWithArrivalsWaitingAsksWithTheCountAndDoesNotLock`,
  `cancellingTheConfirmLeavesTheBookAsItWas`, `aConfirmWhoseBindingWasWrittenBackFirstStillFinishes`, F5's hosted
  guards `theFinishRowsConfirmPresentsAndItsFinishActs` and `theFinishRowsConfirmCancelChangesNothing`, control
  `finishWithNothingWaitingActsAtOnce`) · `MobileBookStateRowTests` (`theFinishCaptionSaysWhatFinishedMeans`,
  `finishIsNotDrawnOnAGathering`, `reopenOnASealedBookSpeaksTheSharedSentence`, `divergeIsNotDrawnOnAGatheringRow`,
  R2-N1's `theBookDetailsRowsSpeakTheirCaptionsAsHints`) · `MobileArchivedStarredBookTests`
  (`anArchivedStarredBooksDetailsCarriesTheUnarchiveDoor`, F3's `aRacedUnarchiveSpeaksTheSharedSentence`) · the
  join's `bookDetailsDeleteLineNamesAGathering`.
- *Evidence.* Window (1): red on the seam commit `7c9fc0151`, green on the tip. Window (5): F3 red/green; F5's two
  guards red only because the reverted row had no label for the driver to find, green on the tip. R2-N1's window
  (07:19:38–07:23:59): its pin red on `046a886fc`'s `MobileBookDetails.swift`, green on the tip, F5's guards green
  on both sides — so the hosted driver can read a SwiftUI hint and the fix stands. On the merged tree:
  PENDING(the re-land's stage window: its GREEN leg carries these types and VM-55's over the same files).

**VM-83 — order, one star door, "gathering" (W-068, W-071, W-073).**
- *The order (W-068).* Was: the retired `Shared/ShelfOrder.ordered` — pins, then journal-trait books, then the rest
  by case-sensitive `<` ("Zebra" before "apple", "Book 10" before "Book 2"). Now: `BookcaseBoard.ordered(books,
  mode: .alphabetical, lastEdited: [:])`, the Mac Bookcase's rule — starred first (the union star), then
  `localizedStandardCompare`; the Library's book rows read the same order; no order door (her ruling — VM-113)
  (`0abaf3938`). `ShelfOrder.ordered`, its forwarder and its pin are deleted; `ShelfOrder.swift` stays for
  `smartQueryTagPaths`.
- *One star door (W-071).* "Pin to Shelf Top" — which IS `setStarred` since 13i-d — removed beside Star; the row's
  menu is the act table `rowActs(for:starred:)`: Star/Unstar, then Delete (Archive on the daily Journal);
  `MobileBookPinTests` deleted with the door (`0abaf3938`).
- *"gathering", never "smart", in these faces (W-073).* The shelf row's meta, the delete door, confirm and receipt
  (shelf row and Book Details — the hoisted `BookStateCopy.deleteDoorLabel(_:)` / `deleteVerb(_:)` and a new
  `RecoveryCopy.movedToTrashReceipt(_:isGathering:)`), the membership sheet's kind mark, the create sheet's three
  lines (DRAFTS, below), the Trash's empty-name placeholder (`0abaf3938`; round 1's N2 made the placeholder read
  `RecoveryCopy.rowKind(item)`, so an untitled saved version names itself, `36ace0aa5`).
- *Round 1's F4.* The guide's shelf lesson said a long press "pins or unpins" — rewritten to the star, a DRAFT
  (below; `36ace0aa5`).
- *At the merge (`ed1266e2f`).* Re-landed on main's per-wing listing: `start()` inside `MobileWingScope.follow` with
  no pins in the snapshot; `orderedBooks` orders the wing-scoped listing by this run's rule; `rowActs`; `setPinned`
  retired (main's refusal-road edit of it dropped with it); the delete receipt names a gathering and main's removal
  line speaks it.
- *Pins.* `MobileShelfOrderTests` (`theShelfSortsAToZDigitAwareWithStarredFirst`; N1's guard
  `aStarTakenWithTheShelfOpenReordersIt`) · `MobileShelfRowActsTests/theRowMenuOffersStarAndNoPin` ·
  `MobileGatheringWordTests` (`theShelfRowCallsAGatheringAGathering`, `theDeleteDoorConfirmAndReceiptNameAGathering`
  — re-shaped to read the removal line, `c652d1669` — `theMembershipAndCreateSheetsSayGathering`,
  `theTrashNamesAnUntitledGatheringAGathering`, `noRenderedStringInTheseFacesSaysSmart`, N2's
  `theTrashNamesAnUntitledSavedVersionAsOne`) · `MobilePocketGuideDeletionTests/theShelfLessonDescribesTheShelfThatExists`
  (F4) · the edited existing pins `MobileBookDetailsTests/theIdentityBlockDisplaysTagsForBothKinds`,
  `MobileShellTests/lk5FacesLeadWithCountAndTags`, `MobileWalkTests/walk7_shelfTodayLibraryColdLaunch`.
- *Evidence.* Window (1) red/green; window (5): N2 red/green, N1 green on both sides by design; F4's follow-up
  red/green. On the merged tree: PENDING(the re-land's stage window: the Trash placeholder's two pins red with the
  Trash view at `eb18888db`, green on the tip, and its GREEN leg's shelf and word types).

**VM-21 — the collect receipt and "(archived)" marks (W-092).**
- *The receipt.* Was: `MobileMembershipModel.collect(into:)` composed "Added by tagging ‹paths› — “X” collects by
  filter." on every collect that applied something — so a ★-only collect read with an empty tag list and no star,
  a tag-and-star collect never named the star, and on an archived gathering (which assembles empty everywhere) it
  claimed the gathering shows the note. Now: the Mac chip's composer `AddToBookCopy.collected(result,
  gatheringName:)`, hoisted to `Shared/CollectReceiptCopy.swift` (`4118af9b3`), with the op's own
  `SmartCollectResult.starred` / `.gatheringArchived` deciding (`ea3b965af`). **Re-landed** (`ed1266e2f`): spoken
  on the one line as a refusal-class line — the class main gives both collect arms (P-55-11) — and byte-identical
  to main's words for a live tags-only or an already-matched collect.
- *The marks.* The add list (archived books included — explicit adds stay open) and the membership rows wear
  `BookArchiveCopy`'s "(archived)" (`ea3b965af`); an archived GATHERING's add row wears it too — PROVISIONAL.
- *Pins.* `MobileCollectReceiptTests` (`aStarOnlyCollectNamesTheStar`, `aTagAndStarCollectNamesBoth`,
  `anArchivedGatheringsReceiptSaysWhenItWillShow`, `pickersMarkAnArchivedBook`; control
  `aLiveTagsOnlyCollectKeepsTheChipsWords`), the collects re-shaped to read the line (`c652d1669`); the Mac's
  `GatheringCollectReceiptTests` and `GatheringCollectStarReceiptTests` over the hoisted bytes.
- *Evidence.* Window (1) red/green and its Mac leg green. On the merged tree: PENDING(the re-land's stage window,
  its GREEN leg) and PENDING(gate 2, the Mac leg).

**VM-24 — the standing phone red (W-258). EDITOR SEAM. Traced to a product mechanism in the phone editor's edit
routing; by her ruling it gets its own run after wave 1; this run builds NO fix for it and does not close it.**
- *What was traced* (window (3); BATCH C, "WINDOW (3) — RESULTS" and "VM-24 — the mechanism, its reach, and the
  options"; the trace instruments `a570d3960`, `fec0e478b`, removed in `16c75a5bf`). The red test's replace comes
  through UIKit's text-input door (`replaceRange:withText:` into `NSTextStorage coordinateEditing:`) and the edit
  gate is never consulted on that road (E1 `consults=0 … gate-less` in every act of M2 and M3), so the edit
  reaches `storageDidEdit` unarmed and `fallbackVerdict` routes it from the storage's own report. TextKit's
  attribute fixing widens that report inside `processEditing` (for "hi": `willProcessEditing` `{1,2}`,
  `didProcessEditing` `{1,5}`); widened past the line's terminator, the old range `(1,8)` reaches the separator,
  the route is refused, and `desyncRecovery` re-renders the surface from the store — before the replacement was
  ever queued for saving. The red follows the report's range, not the posture: exact and green in all six
  real-posture acts, widened in five of six suite-posture acts, and within one posture "Hello" #1 exact and green
  while #2 is widened and red. H1 (the caret settle writing inside the transaction) is killed: no in-transaction
  write in any M2 case, the red persists with the settle held, and M3's forced in-transaction write desyncs
  nothing without the widening. No pre-decided arm mapped (both of round 2's R2-F2 lines were met); arm A's
  test-side wait was refused, because it would turn the test green by avoiding the condition, not by removing the
  hazard. The measured fact is now in `notes/TEXTKIT2_NOTES.md` §3 (`02a3ac002`).
- *Its reach, by reading the code* (round 3's R3-F5 taken, `76bfc56b6`). Return, Tab and the markdown acts arm at
  the call. A typed character is asked about but can land unarmed behind a keyboard transaction of its own (her
  iPhone's E1 #50–#52, `notes/plans/mobile-round-2-crash-trace.md`). Autocorrect, predictive replacement,
  dictation and marked-text commits reach `storageDidEdit` without the gate by the code's own account. What she
  would see when a widened report meets one of those roads: the character or word just entered snaps back, with a
  re-render flicker. Stored text is never at risk: the refused route returns before the autosave is recorded, and
  the recovery first flushes what was already pending. How often fixing widens the report on a device is
  unmeasured. It reads as one mechanism with VX-68 (the gate-less insertion watch row).
- *Her ruling* (2026-11-19, the morning; a dialog pick in the orchestrator's session, no prose): "Own run after
  wave 1 (Recommended)" — quoted with her words to the stage coordinator under "Her rulings built here" (item 9).
- *What this run did.* The trace and the write-up for her decision (`6b214ad67`, `65fe3a114`; the reach corrected
  at `76bfc56b6`); the instruments out of the tree before any whole-target run (`16c75a5bf`); the later run's
  kickoff, `notes/plans/vm-24-unwarned-edit-routing.md` (`f4fce656b`), for `/architect-phase vm-24`, which the
  stage coordinator launches once all four wave-1 mobile runs have merged; the ticket re-owned out of this umbrella
  (the orchestrator's live state: un-parented, Todo, Area Editor, retitled, related to VM-64 and VX-68, a comment
  carrying the mechanism and her decision). The merge touched nothing of it: `MobileMarkdownCaretTests.swift` is
  untouched against `e48ef2f30` (the back-out's check). *What it did not do:* no fix and no seam line; the caret
  test stays red and unwrapped as the pin — on this branch and, after the merge, on main, by decision, never
  wrapped as a known issue — until VM-24's own run turns it green.
- *Pin.* `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` — red for "hi"
  and "hello there" at `desyncRecoveryCount == 0` (`:215`), "Hello" green; red as expected in M1, M6a, M6b and M7.

**VM-19 — the stale first responder (W-259; carried by VM-24). DONE, as test hygiene.**
- *The mechanism, C-1's reading.* A text view raised in a frame window and then only hidden keeps first responder,
  and was read as desyncing the editor on `insertText`.
- *What changed.* `MobileLivenessTests`' arrival test ends editing in its window before hiding it (`5ec59922c`), on
  every exit (`839d86dd9`, round 1's N5). Test code only; kept through the back-out and the merge (the back-out's
  check: +23/−1 against `e48ef2f30`).
- *Pin.* `615a12189` — `MobileLivenessTests/arrivalRaisesFocusBeforeTheObservationLoops`' VM-19 expectation.
- *Evidence.* Window (3): M9-red (the test file at `615a12189`, the hide-only teardown) — 18 tests in 1 suite
  failed, 1 issue, exactly the VM-19 expectation (`:1087`); M9-green — 18 passed. The desync itself did not
  reproduce on this toolchain: no desync in any of M4's four cases (frame window and scene window, with and
  without the polluter). The pin stands as test hygiene and claims no more.

**VM-17 — fan badges on a long note (W-147). EDITOR SEAM. REAL, though not as filed: no pile at block 1, but stray
badges in the viewport on a stepped scroll. Traced and measured here; the first fix FAILED its stage window and
was backed out by her ruling; VM-17 is its own run with VM-239 and VM-179. NOT shipped — the takes chrome is as
main has it.**
- *What window (3) showed* (M5, and M5b identical line for line). Reading 1, the pile: green — no two badges
  coincide, none at block 1. The viewport invariant on the stepped walk (61 stops): (i) 35 badges astray, (i′) 35
  misses, (ii) 9 fans on screen with no badge on their line; on the jump road (22 jumps) 0 · 0 · 0; reach (iii)
  green (`walkReached=22/22`, `jumpMissed=0`; (i′) asked 76, skipped 0). One badge stood 1,260 pt from its own
  block, beside another block's text; several stood 74 pt off their own line. By the record's arm: REAL — stopped
  and reported before any product line. Reading 2, printed and never asserted: `offscreenDrawn=21 offIdeal=21
  largest=9276.0 mean=4716.0` (points), on a live content height of 33,812 pt.
- *The two mechanisms* (batch D's trace, `23f772dba`, read against M5 by round 3). **A — an off-band stale frame:**
  24 of the 35 strays carry their block's exact load-time value. The load's full pass forced layout at each fan's
  mid-document offset ahead of its unlaid predecessors, so TextKit placed the fragment at an estimate and later
  moved it, while the off-band badge kept its frame ("its last resolved frame stands"). **B — an in-band badge read
  before TextKit placed its fragment:** the other 11, each exactly 74 pt, with all 9 bare lines — read in the scroll
  tick before TextKit had laid out the new viewport. Round 1's shape ("hide off-band, resolve as it enters") would
  remove A and not B, so the implementer stopped at the trace (the brief's own rule).
- *The settle measurement* (an instrument: introduced `35ce90848`, its result written `8f48427b0`, removed
  `5a57abdf0`; log `vm78-d-measure.log`). At the first subview laid out after the text view's own layout, the
  unforced first-line read already equals the after-settle read in 118 of 118 band-fan reads (and the idealized
  layout in all 28 on screen), while the chrome's badge was off in 49 until the chrome read again. Two corrections
  the round-3 reviewer took: "settled" is true only of what is on screen; and at walk#10 the chrome read back a
  frame an earlier forced read had left — laid out is not placed. Mount 2 was void (its model was released), and
  `linkFired=51/61` is R3-F3's stale fallback, not the host. Both measured facts are now in
  `notes/TEXTKIT2_NOTES.md` §3 as measurements, not a recipe (`02a3ac002`).
- *The first fix, as built — history, not shipped.* Round 3's called shape, S1–S11, built exactly: pins
  `15add793d` (the re-pinned far-badge expectations, the marker-and-pill pin, the empty-last-block guard), fix
  `f869f8667` (every takes overlay read only inside TextKit's own viewport, views made only once placed and hidden
  with their frame kept when their block leaves it, one geometry walk for every scope, and a second walk in the
  same layout pass from a zero-size anchor subview).
- *Its window* (BATCH D, "THE WINDOW AND HER RULING"; claimed 12:21:06, released 12:27:59). RED leg
  (`MobileTakesChromeTests` on the old chrome): 15 tests in 1 suite failed — the three expected, and a fourth: the
  new guard `anEmptyFannedLastBlockWearsItsBadgeWhileTheNotesEndIsOnScreen`, red on the OLD chrome too (by round
  3's arm recorded and dropped; unexplained, an observation for the later run). GREEN leg (the fix, ten types): 67
  tests in 10 suites failed, eight red. The probe failed on `bare.isEmpty` and `jumpMissed.isEmpty`: the SCROLLING
  road went clean (`astray=0`, no (i′) miss, every fan reached) while all 17 bare lines were on the JUMP road (after
  `jumpToBlock` the target fan stood on screen with no badge) and four far targets were not reached. Seven chrome
  tests failed too, six of them on a view never made — consistent with a host that has no viewport or no layout
  pass, which nothing in the log shows: NOT established. **THE FIX IS NOT PROVED.**
- *Her ruling* (a dialog pick, no prose): "Take it out, own run (Recommended)" — quoted with the option's wording
  under "Her rulings built here" (item 10).
- *The back-out* ("THE MERGE-IN", rows 1a–1e). `b69d5d12e` reverts the fix, `feabe164c` reverts its pins,
  `1981d4041` removes the probe `MobileFanBadgePlacementProbeTests.swift`, `7d84e4b22` removes the decor reading
  `MobileDecorPlacementReadingTests.swift` (the settle instrument had left at `5a57abdf0`). The check `79fa4d36d`:
  the four chrome files (`MobileTakesChrome.swift`, `MobileEditorTextView.swift`, `MobileBlockDecor.swift`,
  `MobileTakesChromeTests.swift`) print nothing against `e48ef2f30`; no instrument type is in the tree. At HEAD
  `git diff eb18888db HEAD` on the same four files is empty: the takes chrome is main's.
- *What goes to its own run.* The kickoff `notes/plans/vm-17-chrome-geometry.md` (`de3bb0107`; its restore line
  for the probe corrected in place at `1981d4041`) for `/architect-phase vm-17 vm-239 vm-179` after wave 1 — hers to
  launch. VM-17 is re-owned out of this umbrella (Confirmed, retitled, a comment with the evidence — the live
  state). The evidence that run reads here: BATCH C's "WINDOW (3) — RESULTS" for VM-17; BATCH D whole (the brief,
  the trace of mechanisms A and B, the settle measurement, "The build — LIVE STATUS", "THE WINDOW AND HER
  RULING"); round 3's R3-F1, R3-F2 and "VM-17's fix — the shape, as called"; and in history the probe (its last
  edition `15add793d`; the body M5 ran from `78179b765`), the decor reading (`211221f6b`, `75984c0e6`), the settle
  measurement (`35ce90848`) and the first attempt (`15add793d`, `f869f8667`). The peek markers and the choosing
  pill share the badge's standing-frame rule (batch D's trace) and are in that record too.
- *The decor — round 3's R3-F1, MAJOR — measured.* The block decor (callout washes and glyphs, comment marks)
  shares the standing-frame rule and the forced helpers. Its reading ran alone in batch D's window, on the tree
  with the failed fix in (the decor code unchanged there but for one comment line): 1 test in 1 suite failed, 9
  issues, as a measurement — `washAstray=225 washBare=17 glyphAstray=51 glyphBare=13 markAstray=122 markBare=23`,
  reach `wash=30/30 glyph=30/30 mark=50/50`, `jumpMissed=22` (its `badgeAstray=4 badgeBare=5` are the unproved
  fix's). **R3-F1 is real for the decor; VM-239 is minted** (Bug · Confirmed · Editor · High) and goes with VM-17's
  run, its pin the decor reading in history (`211221f6b`, `75984c0e6`, removed `7d84e4b22`), its red log
  `vm78-window-d-decor.log` and its bundle `d-decor.xcresult` (reads). Round 3's disposition is overtaken: the decor
  no longer waits behind a badge fix.
- *Pins in the tree.* None: the probe and the decor reading left so main carries no new red test (her ruling).

### The evidence

The phone windows ran on the standing phone-suite simulator (iPhone 17 Pro, iOS 26.2), addressed by id (never
written here), under `Tools/stage` claims nov18 granted. Windows (2), (1), (5), R2-N1's and batch D's ran from the
orchestrator's throwaway detached checkout (`~/dev/variorum-vm-78-pins`, its own DerivedData); F4's follow-up and
the settle measurement were the orchestrator's too; window (3) was run from the worktree by a fresh window runner.
Every window above "the merge-in's builds" ran on the code BEFORE the merge; the merged tree's windows are the
slots at the table's foot.

| Window | When | What ran | Verdict | Reds, by name | Bundle and log |
|---|---|---|---|---|---|
| (2) batch B | claimed 04:03:11, released 04:07:08 | checkout at `d17e61b2d`; the seven product files at their pre-fix versions, then the tip; six types | RED: 68 tests in 6 suites failed, 20 issues incl. 2 known. GREEN: 68 tests in 6 suites passed with 2 known issues (the designed `MobileTrashTests` diagnostic) | exactly the seven expected: `aQuietUndoSpeaksTheRefusalAndOffersNoRedo` · `aQuietRedoSpeaksTheRefusalAndOffersNoUndo` · `theWarningsDetailSaysCommittedInTheMacsSentence` · `aRestoreKeepsTheReplacedWordsAsAQuietSavepoint` · `theFannedDivideLessonSaysKeepOnTop` · `theDateChipFollowsTheDateWhenTheTitleDoesNot` · `theFirstPaintSaysNothingBeforeTheListingAnswers` | RED bundle NOT kept (recorded lost, N11); GREEN bundle read by round 1 (68: 67 passed, 1 expected failure, 0 failed). Logs `vm78-window-b-red.log`, `vm78-window-b-green.log` under `App/Variorum/DerivedData/logs/` |
| (1) batch A | claimed 05:26:26, released 05:33:04 | checkout at `437696f06`; the eight files at the seam `7c9fc0151`, then the tip; sixteen phone types; the Mac leg | phone RED: 84 tests in 16 suites failed, 52 issues. phone GREEN: 84 tests in 16 suites passed, no known issue. Mac leg: 110 tests in 17 suites passed | exactly the 21 expected: the 18 new pins and the 3 edited existing pins named in batch A's LIVE STATUS | no bundle path was named (the window ran before round 1's N11 rule); Xcode's own default bundles from that claim — a phone run stamped 05:28:55 and the Mac leg 05:31:34 — sit in the throwaway checkout's DerivedData (`vm78-pins`, `vm78-pins-mac`), not read for this record. Logs `vm78-window-a-red.log`, `vm78-window-a-green.log`, `vm78-window-a-mac.log` are the evidence |
| (5) the round-1 fix pass | claimed 06:26:55, released 06:31:48 | checkout at `140869902`; four product files at `0180727de`, then the tip; ten types | RED: 75 tests in 10 suites failed, 9 issues incl. 2 known. GREEN: 75 tests in 10 suites passed with 2 known issues | four: `aRacedUnarchiveSpeaksTheSharedSentence` (F3) · `theTrashNamesAnUntitledSavedVersionAsOne` (N2) · `theFinishRowsConfirmPresentsAndItsFinishActs` and `theFinishRowsConfirmCancelChangesNothing` (F5's guards, red only for the missing row label). F4's pin did not run (its type was misnamed in the recipe) | RED bundle `fixpass-red.xcresult` UNREADABLE (stopped before it was finalized) — its log `vm78-window-f-red.log` is the evidence; GREEN bundle `fixpass-green.xcresult` reads (75: 74 passed, 1 expected failure, 0 failed); log `vm78-window-f-green.log` |
| F4's follow-up | 06:52–06:54 | the seeder at `0180727de`, then the tip; one type, `MobilePocketGuideDeletionTests` | RED: 4 tests in 1 suite failed. GREEN: 4 tests in 1 suite passed | one: `theShelfLessonDescribesTheShelfThatExists` (3 issues — the three expectations F4 added) | `f4-red.xcresult` and `f4-green.xcresult` both read; logs `vm78-window-f4-red.log`, `vm78-window-f4-green.log` |
| R2-N1's pin | claimed 07:19:38, released 07:23:59 | checkout at `ef1430142`; only `MobileBookDetails.swift` at `046a886fc`, then the tip; `MobileBookStateRowTests` + `MobileFinishConfirmTests` | RED: 11 tests in 2 suites failed, 4 issues. GREEN: 11 tests in 2 suites passed, 0 failed | one: `theBookDetailsRowsSpeakTheirCaptionsAsHints` (F5's two guards green on both sides) | RED bundle `r2n1-red.xcresult` UNREADABLE (its `xcodebuild` was still alive 90 s after the verdict and was stopped at the bound) — its log `vm78-window-r2n1-red.log` is the evidence; GREEN bundle `r2n1-green.xcresult` reads; log `vm78-window-r2n1-green.log` |
| (3) batch C, matrix only | claimed 08:39:53, released 08:50:46 | the worktree; M1–M7 by `test-without-building` against `vm78-ios` built at the code of `97282e72f`, M9's two legs by `xcodebuild test`; the matrix's ten runs (M1, M2, M3, M4, M5, M6a, M6b, M7, M9-red, M9-green) plus one M5 re-run alone (M5b) | M1, M6a, M6b: 4 tests in 1 suite failed, 2 issues each. M2: 3 tests passed; M3, M4: 1 test each passed. M5 and M5b: 2 tests in 1 suite failed, 3 issues each, identical. M7: 22 tests in 2 suites failed, 2 issues. M9-red: 18 tests in 1 suite failed, 1 issue. M9-green: 18 tests in 1 suite passed | M1, M6a, M6b, M7: the caret pin's two cases ("hi", "hello there", `desyncRecoveryCount == 0`), by design — nothing beyond them in M7. M5, M5b: the probe's (i), (i′), (ii) expectations (`astray`, `misses`, `bare`) — VM-17 real. M9-red: the VM-19 expectation (`:1087`), by design | all eleven bundles read (`vm78-bundles/c-<run>.xcresult`); logs `vm78-c-<run>.log`; every `xcodebuild` exited by itself within 5 s of its verdict; no `Restarting after unexpected exit`, no new crash report |
| the settle measurement | 2026-11-19, between `35ce90848` and round 3's final calls (the record gives no claim times) | `MobileFanBadgeSettleMeasureTests` alone by type — an instrument, not a pin | 1 test in 1 suite passed after 6.685 seconds | none (it asserts nothing about the product) | bundle `vm78-bundles/d-measure.xcresult` (kept; not read for this record); log `vm78-d-measure.log` |
| batch C's second short window | not run | — no arm called for one: VM-24's fix is its own run's, VM-17's became batch D, VM-19 was proved in M9 | — | — | — |
| batch D, red leg | one claim for batch D's three legs: claimed 12:21:06, released 12:27:59 | checkout at `f4fce656b` (the branch's code up to `7e5eb2a58`); `MobileTakesChrome.swift` and `MobileEditorTextView.swift` at `15add793d`, the tests at the tip; `MobileTakesChromeTests` alone | 15 tests in 1 suite failed, 9 issues | the three expected — `perTickRefreshResolvesOnlyNearViewportGeometry` (4 issues), `aKeystrokesChromePassIsEditScopedAndWriteFreeWhenNothingMoved` (1), `aFarFlipDrawsNoMarkerOrPillUntilItsBlockScrollsIn` (3) — and the new guard `anEmptyFannedLastBlockWearsItsBadgeWhileTheNotesEndIsOnScreen` (`:754`), red on the old chrome too | `d-red.xcresult` UNREADABLE (the run failed and lingered the full 90 s) — log `vm78-window-d-red.log` is the evidence |
| batch D, green leg | the same claim | the fix; ten types — the probe and the chrome types (BATCH D's "THE WINDOW" list) | 67 tests in 10 suites failed, 13 issues, EIGHT tests red — **the fix is not proved** | the probe (`bare.isEmpty` `:400`, `jumpMissed.isEmpty` `:406`; `VM17\|SUMMARY fans=22 astray=0 bare=17 misses=0 asked=29 (walk 28, jump 1) skipped=1 walkReached=22 jumpMissed=4`, `offscreenDrawn=0`) · `MobileTakesChromeTests`: `perTickRefreshResolvesOnlyNearViewportGeometry`, `badgeAppearsOnlyOnFannedBlocksAndOnlyTheyReserveSpace`, `aFlushEndOneLineFannedAndCommentedBlockNeverCrowdsTheBadge`, `theChromeRestylesWithTheVoice`, the guard · `MobileTutorialTakesWalkTests.theSwipeLessonPeeksStickyAndTheCheckChooses` · `MobileWalkTests.walk5_takesBadgePeekAndChoose` | `d-green.xcresult` UNREADABLE (failed, lingered 90 s) — log `vm78-window-d-green.log` is the evidence |
| batch D, the decor reading | the same claim | `MobileDecorPlacementReadingTests` alone, on the tree with the failed fix in | 1 test in 1 suite failed, 9 issues — a measurement | the decor's expectations (counts under VM-17 above): R3-F1 real for the decor ⇒ VM-239 | `d-decor.xcresult` reads; log `vm78-window-d-decor.log`. No host restart and no zero-executed line in batch D's three logs |
| the back-out's check | git only, at `7d84e4b22` (`79fa4d36d`) | `git log` / `git diff e48ef2f30..` over the four chrome files; `git ls-files` and `git grep` for the instrument types | the four files print nothing against `e48ef2f30`; no instrument type in the tree; VM-19's and VM-24's test files kept | — | — |
| the merge-in's builds | the merged tree, headless | phone signed `build-for-testing` (`platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`, no boot) at `c652d1669` and again at `8d2b9f8bf`; Mac `build-for-testing` at `c652d1669` (nothing the Mac compiles changed after it) | TEST BUILD SUCCEEDED, all three; 0 errors; no warning in a line the merge-in wrote | — | logs `vm78-mergein-ios-build.log`, `vm78-mergein-ios-build-2.log`, `vm78-mergein-mac-build.log` |
| the re-land's window | PENDING(the re-land's stage window: its claim times) | RED — `MobileUndoDoor.swift`, `MobileTrashModel.swift`, `MobileTrashView.swift` at `eb18888db`, the tests at the tip, four types; GREEN — the tip, 41 phone types ("THE MERGE-IN" → "The window recipe") | PENDING(the re-land's stage window: both verdict lines) | PENDING(the re-land's stage window: every red by name — six expected on the RED leg, none on the GREEN) | PENDING(the re-land's stage window: bundles `mergein-red` / `mergein-green` and their logs) |
| Gate 1: the whole phone target | PENDING(gate 1: when) | the merged tip, the whole `VariorumMobile` test target | PENDING(gate 1: the verdict line) | PENDING(gate 1: every red by name — the one standing red by decision is VM-24's caret pin, `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`) | PENDING(gate 1: bundle and log) |
| Gate 2: the Mac leg | PENDING(gate 2: when) | the merged tip; the Mac types over the changed `Shared/` files — tier 1's 17 and tier 2's ("THE MERGE-IN" → "The window recipe") | PENDING(gate 2: the verdict line) | PENDING(gate 2: every red by name) | PENDING(gate 2: bundle and log) |
| Gate 3: the simulator walk | PENDING(gate 3: when) | the dev-store Debug phone build; one capture per row (below), both voices where a face has one | — | — | PENDING(gate 3: the screens folder and each row's capture) |

**The walk's rows (gate 3), collected from the record:** Book Details' Finish with notes waiting (the confirm and
its count; Cancel leaves the book; Finish dismisses) · Finish absent on a gathering's Details · a sealed book's
Reopen sentence · the membership sheet on a note in a gathering (no Diverge; the "gathering" mark; an archived
book "(archived)" in the add list; a ★-rule collect's line) · the shelf in a–z with a starred book first and a
long-press menu without Pin · a gathering's delete from the shelf row and from Book Details, the line naming a
gathering (added at this re-fit for the merge's one semantic join) · the create sheet's Gathering kind · a starred archived book from Starred → its Details with Unarchive
→ back on the shelf · the undo door after a quiet press (the refusal on the one line) · a restore and its kept
moment · the date chip · the Trash's first paint · the divide lesson · F4's "getting around" lesson · round 1's
N9: the tallest Book Details (an archived, journal-trait book with a rule, a refusal line showing) at the medium
and at the large detent. (No fan-badge row: VM-17 left the run.) PENDING(gate 3: each row's outcome and capture
name).

### Her rulings built here, against what shipped

Her words are quoted exactly as recorded; where the record holds an orchestrator's summary of a dialog pick
rather than her sentence, it says so.

1. **The ladder cap tonight** (Kickoff facts): "sounds good, tonight, up to 5 review rounds as long as a major is
   found." *Shipped:* round 1 found two MAJORs and earned round 2; round 2 found none, and round 3 was owed by
   round 1's F1 (new work not yet cold-read); round 3 found one MAJOR (R3-F1), which earns round 4 — which reads
   the back-out, the merge resolutions and VM-16 re-landed. PENDING(ladder round 4: its count and dispositions; a
   further round only on a new BLOCKER or MAJOR, within the cap of five).
2. **Her frame for the night** (Kickoff facts): "and just to be clear, the plan is sequential merges to main,
   overnight provisional running, but I won't get a new phone build until wave 2 is done according to what
   another session said." *Shipped:* the run closes on a simulator walk, with its PROVISIONAL calls bundled. Its
   phone-build half is superseded by item 3's install line.
3. **Her rulings later the same night** (Kickoff facts): "letting alll my sessions know this - which is good,
   since three of your fixes will solve active hazards. i resolved that issue with vx-64. book order - that's fine
   to leave it for wave 3. 2 - collect receipt your choice is fine.  resolved the previous install blocker with
   vm-55. now, i'll plan to have the wave 1 build installed on my phone after the last vm has merged in, prepared
   by the last one - a new session should be able to help me with the install if i don't want to wake a stale
   cache. sound good? the phone step is the single wave-1 install after all four runs have merged. I'll do the
   hands part hands on in the morning." *Shipped:* the shelf sorts a–z, digit-aware, starred first, with no order
   door — the choice waits for VM-113 (wave 3); the collect receipt is kept and made true. The install:
   PENDING(the single wave-1 phone install — only if this run is the last of the four mobile runs to merge: the
   device build from merged main and the paste-ready install kickoff per
   `notes/plans/vm-44/plans/vm-45-install-runbook.md`).
4. **Her away word, relayed by nov18:** "rule provisionally in my absence, i'll check in in the morning".
   *Shipped:* the two PROVISIONAL calls below, bundled; nothing author-only touched.
5. **The Finish confirm** (her sitting, 2026-11-15; sorted in `notes/plans/vm-44/plans/sitting-1-rulings.md` as
   "Says how many arrivals it dismisses, with an "Open Arrivals first" button."; her own words on the button, in
   `notes/plans/vm-44/her-words.md`: "Keep it"). *Shipped:* the count, its title and line, Finish and Cancel, and
   no confirm when nothing waits. **Remainder: the "Open Arrivals first" button** — the phone has no Arrivals
   review yet; VM-175 (wave 4) carries it.
6. **Receipts** (her sitting): which acts show a line — "Only removals and refusals". *Shipped:* no new line for
   an ordinary act; a refusal speaks a sentence on every road this run opened. On the merged tree every line this
   run speaks rides VM-55's one line in main's classes: the quiet undo a refusal; the collect receipt a
   refusal-class direction (P-55-11 — whether the phone keeps it at all is on the wording pass); a gathering's
   delete from Book Details a removal (P-55-8); Unarchive ordinary, with no line (P-55-4).
7. **Words** (her sitting, on the designers' lines): "I think we need to word things more simply." *Shipped:* the
   Mac's own words wherever a Mac face exists; the drafted lines below wait for her pass.
8. **The insured restore** — QUESTIONS #274 addendum 2, the orchestrator's record of her dialog pick at the
   2026-11-10 sitting: "**P-849-1 RATIFIED + the phone wired** (the insured restore stands; the phone's
   one-argument insurance is VM-43)." *Shipped:* VM-43, the one phone restore door; AppSpec §9 (two sites) and
   OverallModel §3 no longer mark the rule PROVISIONAL (`3471d0ad4`).
9. **VM-24's road** (2026-11-19, the morning). Her dialog pick in the orchestrator's session, no prose: "Own run
   after wave 1 (Recommended)" — the option as the record states it: its own short run on merged main as soon as
   all four mobile runs have merged, before wave 2, starting with one session on her phone counting unwarned edits
   and snap-backs. Her words to the stage coordinator, verbatim: "I chose the own run after wave 1 option that
   vm-78 proposed. i want you to message them about this to lock the plan down, but basically i want you to open a
   new session in tmux once wave 1 is done and merged, and tell it to architect-phase that issue, reporting to you
   for stage details. just kick that off when wave1 is done for me." *Shipped:* no VM-24 fix in this run; the pin
   stays red and unwrapped; the kickoff `notes/plans/vm-24-unwarned-edit-routing.md` (`f4fce656b`) for
   `/architect-phase vm-24`, its first acceptance unit the measurement on her phone; the ticket re-owned out of
   this umbrella. **Remainder, not this run's:** the coordinator's launch once wave 1 has merged, and the session on
   her phone (her hands, at that run's start).
10. **VM-17's road** (2026-11-19, after batch D's window; BATCH D, "THE WINDOW AND HER RULING"). Asked: "VM-17, the
    stray fan badges on long notes: the fix I built this morning did not pass its stage window. Should I keep
    working it inside VM-78, or take it out and give it its own run?" Her dialog pick, no prose: "Take it out, own
    run (Recommended)". The option as it was worded to her (the orchestrator's words, not hers): "I back the
    unproven fix out of VM-78 with a plain revert commit, and the probe and measurement tests leave the branch in
    named commits the tickets cite, so main gets no new red test. VM-17, the callout/comment finding and wave 4's
    VM-179 become one run after wave 1 with all of last night's evidence as its starting point. VM-78 then merges
    its eight proven fixes plus the test-hygiene pin." *Shipped:* the back-out as two `git revert` commits — the fix
    (`b69d5d12e`) and its pins (`feabe164c`) — rather than one; the probe and the decor reading removed in named
    commits (`1981d4041`, `7d84e4b22`; the settle instrument had left at `5a57abdf0`), which the later run's kickoff
    cites; VM-239 minted for the callout and comment finding; VM-17 re-owned out of the umbrella; the kickoff
    `notes/plans/vm-17-chrome-geometry.md` for `/architect-phase vm-17 vm-239 vm-179`, hers to launch after wave 1.
    **Remainder:** that run's launch (hers).

**The reconcile CLAUDE.md asks for (re-reading "every", "everywhere", "all" and the counts against what the merged
tree ships):**
- **W-073, "Say "gathering", never "smart", everywhere"** — the approved plan's row title (her approval of the
  composition: "22 is fine, composition is fine."), not a sentence of hers. Built in every face the brief named;
  the merge added one more face to the rule (Book Details' delete line, `8d2b9f8bf`). **Left at HEAD, each
  owned:** the Today door's `.wrongKind` note ("…is a smart book…", `MobileTodayDoor.swift`) — VM-85; the pocket
  guide's "a smart book collecting by tags" — VM-212; the create sheet's "Create Book" button on the gathering kind
  (not "smart", but the Mac has a separate "Create Gathering…") — VM-117, the new-book sheet; the Starred page's
  "book" kind word on a gathering row — VM-94; the delete confirm's detail "Its notes stay in the library." on a
  gathering (true; the Mac's gathering confirm says "No note is touched: a gathering holds none.") — the wording
  pass. Identifiers and the model's older spelling in code are out of scope (AppSpec §7). The sweep pin is a
  hand-kept list of strings; the Mac's source-scanning ban comes to the phone with VM-212 (round 1's N7).
- **"every phone restore call site"** (the brief's VM-43 line) — there is one at HEAD; it is wired.
- **The receipts ruling** — no ordinary act gained a line; every line this run speaks is a refusal, a direction or
  a removal in VM-55's classes (item 6).
- **VM-24's ruling** — "all four mobile runs have merged" (the option's words, as the record states them) is
  carried exactly by the kickoff ("only after all four wave-1 mobile runs (VM-47, VM-55, VM-64, VM-78) have
  merged"); her own words ("once wave 1 is done and merged") say no more than that.
- **VM-17's ruling** — "its eight proven fixes plus the test-hygiene pin": the eight members proved red/green in
  windows (2), (1), (5) and their follow-ups before the merge, and VM-19's pin in M9; on the merged tree they are
  built and read, and PENDING(the re-land's stage window and gate 1) prove them again. "main gets no new red
  test": no probe, decor reading or measurement type is in the tree (the back-out's check), and the one red the
  whole phone target is expected to show, VM-24's caret pin, predates this run — PENDING(gate 1) shows it. "a
  plain revert commit": built as two revert commits, one per reverted commit.
- **Her install line** — "the single wave-1 install after all four runs have merged": carried by item 3's slot, owed
  only by the last of the four to merge.
- **Nothing else** in the rulings above says every, everywhere or all.

### The ratify list (her PROVISIONAL calls)

1. **An archived GATHERING's add row in the membership sheet** (VM-21). Options: (a) mark it too — "Quotes
   (archived) (by tagging)" — **BUILT**: SurfaceContracts says "The pickers, chips and Book Panel mark
   "(archived)"" with no kind exception, and the collect receipt's archived arm then has a mark to agree with;
   (b) the Mac chip's picker exactly — gatherings carry only "by tagging", unmarked; (c) list no archived gathering
   in the add list (not the contract: explicit adds stay open). Her question: does an archived gathering's add row
   wear "(archived)" on both platforms?
2. **F8 — Diverge on a gathering's row** (VM-81, W-110). The question as the fix implementer drafted it, for
   `notes/QUESTIONS.md` at the merge: "Diverge on a gathering's row in a note's books list. The Mac's chip draws
   'diverge' on every row and a gathering refuses with the tag road (13f W23; `MembershipChip.swift:136-145`; its
   comment's 'her ruled shape' is the 13f orchestrator's batch-5 adjudication — `notes/plans/phase-13f-workspace.md`,
   'the orchestrator's adjudication — batch 5 CLOSES' — which endorsed the refusal's sentence and, for the W22
   offer, P-2's 'never offer an act that could only refuse'; no words of hers were found for either reading). The
   phone since VM-81 (W-110, 'a door drawn where it can't act') draws none. Options: (a) neither draws it — the Mac
   follows in a VX ticket (Books, Low); (b) both draw it and refuse with the road — the phone reverts W-110; (c)
   keep the difference as a recorded compromise (MobileSoul §3). PROVISIONAL as built: the phone's (a)."
3. **Not PROVISIONAL, named so it is not lost:** the phone's Book Details reads the Mac's finish door table on its
   own side (`finishRowAct(for:)`; Reopen stays drawn on a sealed BOOK and explains, per W-106) until the door sets
   are hoisted — W-070 (VM-115) and W-112 (VM-161) retire this small fork.
4. **Nothing else.** Batch C added no PROVISIONAL (its LIVE STATUS: "PROVISIONAL: none"); batch D added none and its
   build left the tree; the merge-in added none ("THE MERGE-IN", "PROVISIONAL calls from the merge: none new" —
   every meeting point was vocabulary, and Book Details' delete line is main's P-55-8, already PROVISIONAL there,
   speaking this run's ruled W-073 words). VM-24 and VM-17 are no longer questions: she ruled both (items 9 and 10).

### For her wording pass

Every line this run drafted, old beside new, re-read against the code at HEAD (each quoted "New" is what HEAD
says). The Mac's own words that are new on the phone (not drafts) follow the table. VM-24 and VM-17 render no
words.

| Where | Old | New (draft) |
|---|---|---|
| The divide-with-takes lesson, block 1 (VM-3) | Dividing a block that has several takes follows one simple rule on the phone: the take you're READING is cut in two, and every other take rides along whole — copied onto both halves, so nothing needs a matching cut and nothing is lost. | Dividing a block that has several takes follows one simple rule on the phone: the take you're reading is cut in two, and every other take rides along whole onto the top block, so nothing needs a matching cut and nothing is lost. |
| …block 2 (VM-3) | The extra copies are quick to delete where you don't want them — quicker than hunting for a lost take ever was. The original block keeps everything, off-stage, in lineage. | The bottom block holds just the second half. The original block keeps everything, off-stage, in lineage. |
| The "getting around" lesson, first sentence (F4) | The SHELF is home: your books at the top, with this one pinned first — pinned books always sit first, and a long press on a book row pins or unpins it. | The SHELF is home: your books at the top, starred books first — this one is starred. |
| …the star sentence (F4) | A long press also STARS a note or a book — starred things sit above everything at the shelf's very top, and the same press takes the star back off. | A long press STARS a note or a book — starred things sit above everything at the shelf's very top, and the same press takes the star back off. |
| The create sheet's kind door (VM-83) | Smart Book | Gathering *(the Mac's kind word)* |
| …its caption (VM-83) | A smart book collects notes by these tags — the tags stay on the notes. | A gathering shows every note these tags match and holds none of them — the tags stay on the notes. |
| …its no-tags line (VM-83) | No tags yet — notes get tags first; a smart book collects by them. | No tags yet — notes get tags first; a gathering shows the notes that match them. |
| A sealed book's Reopen (VM-81 keeps the door drawn; the sentence is the shared table's with the phone's roads — not reworded — and since the merge it comes by VM-62's road, main's, not by this run's arm) | That couldn't be done — readingSealed(id: …). *(before VM-62 and this run)* | This book is sealed, so it can't be reopened here. *(Her question: "here" quietly implies somewhere else can. With VM-161's Unseal the phone's roads fill and it reads "This book is sealed — unseal it to reopen it." VM-55's handoff lists the same sentence among its own, "existing phone sentences, now actually reached".)* |
| The collect line (VM-21; the Mac chip's words, spoken on the one line as a refusal-class direction, P-55-11) | Added by tagging ‹paths› — “X” collects by filter. *(on every collect that applied something, a ★-only one included)* | Starred — the gathering shows it now. · Tagged #x and starred — the gathering shows it now. · Tagged #x — the gathering shows it once it's unarchived. · It already matches — the gathering shows it once it's unarchived. *(a live tags-only collect keeps "Added by tagging #x — “X” collects by filter.", and an already-matched one "Already collected — it matches “X”'s filter."). Her question: does the phone keep a collect line at all?* |

The VM-3 draft dropped "READING"'s capitals under her no-shouting rule; F4's draft keeps the "getting around"
lesson's existing "SHELF" and "STARS" (the guide's capitals as a whole are VM-212's rewrite).

**New on the phone, in the Mac's own words (no draft):** "Finish “‹name›”?" and "N waiting at Arrivals will be
dismissed." · "Finished means the table of contents is done — the writing inside can still change." · "Sealed —
the book is done; no note in it can change." · "Delete Gathering…" and "Gathering moved to the Trash — 30 days to
put it back." (the shelf row's and Book Details' removal line) · the shelf meta's "gathering" · "(archived)" ·
"Nothing to undo — ‹label› was already undone or changed since." / "Nothing to redo — it changed again after
‹label› was undone." (on the one line) · "…It is committed first, so you can bring it back from the block's Block
History at any time." · "Unarchive". ("That book isn't archived any more — nothing changed." is the shared table's,
and since the merge main's road speaks it too.)

### Lines for other owners

- **VM-24's own run** (`/architect-phase vm-24`, after all four wave-1 mobile runs merge; the kickoff
  `notes/plans/vm-24-unwarned-edit-routing.md`): the mechanism, its reach, the three fix options and what only a
  device can tell are in BATCH C's "VM-24 — the mechanism, its reach, and the options"; the trace instruments can be
  restored from `a570d3960` and `fec0e478b` (run alone by type, never in a whole-target run). Its first acceptance
  unit needs her hands: one session on her phone with the E1 trace armed.
- **VM-17's own run, with VM-239 and VM-179** (`/architect-phase vm-17 vm-239 vm-179`, after wave 1, hers to launch;
  the kickoff `notes/plans/vm-17-chrome-geometry.md`): the evidence it reads is listed under VM-17 above; the
  first attempt and its pins are in history (`15add793d`, `f869f8667`), never to be assumed right and merely
  unfinished (the kickoff's own warning).
- **VX-68 (the gate-less insertion watch row, Backlog):** reads as one mechanism with VM-24 (an iOS one-character
  insert reporting `{8,9}`, named there as the candidate cause of "the note flickered"); VM-24's ticket is related to
  it, and VM-24's run decides whether it closes it.
- **VM-64 (wave 1, timing and lags):** its flight fence decides what happens to an unwarned edit while a
  structural act lands, in the same file, and its batch 2 traced the same widened-report mechanism for a bare
  `insertText` (the kickoff's reading of VM-64's record); VM-24's ticket is related to it, and VM-24's run designs
  against the fence as merged. VM-64 also changed `MobileEditorViewModel.swift`, where `jumpToBlock` lives — VM-17's
  run reads its record first (that kickoff's own list).
- **VM-62 (merged with VM-55):** moot as a line — at the merge main's road already reached the table for
  `.readingSealed` and `.readingNotArchived`, so this run's forwarding arm in `MobileBookDetailsModel.refusal` is
  deleted ("THE MERGE-IN"). Round 2's R2-N4, written for VM-62's sweep, had no owner after it merged without the
  latch; it moves to "Tickets to file" (item 6). Its words, verbatim from the fix pass: "Book Details' act rows
  (Unarchive here; Finish, Reopen and Archive share the shape) start one task per press with no in-flight latch. A
  double press on Unarchive that lands before the first press's re-read meets `readingNotArchived` and shows 'That
  book isn't archived any more — nothing changed.' under the book the first press did unarchive. Only Unarchive's
  second press is visible today — a second Finish or Reopen repeats an operation that is safe to repeat, and Archive
  dismisses its sheet. When the sweep moves `MobileBookDetailsModel.refusal` and its rows onto the message seam,
  give the rows an in-flight latch (the undo door's `inFlight`), so the sentence stays for the real race — the book
  unarchived elsewhere while the sheet is open." (At HEAD the rows still carry no latch.)
- **VM-55's word-hoist guard, for its owner:** VM-55's two Mac source scans read a hand-kept list of hoisted Mac
  BRAINS (`VM61MacStatusSeamPinTests.hoistedMacBrains`); this run's hoists are WORDS (`BookStateCopy`, `ArrivalsCopy`,
  `CollectReceiptCopy`, `StructuralUndoCopy`'s detail) and are not on it — whether word hoists join the list is that
  guard's owner's call ("THE MERGE-IN", "Not changed, for the orchestrator").
- **VM-179 (the takes marks' per-pass cost; now in VM-17's run):** window (3)'s cost note — 150 blocks: load 0.032 s
  unfanned and with 22 fans, the `.document` chrome pass cold 0.11 ms vs 1.81 ms, warm 0.05 ms vs 0.30 ms; 600
  blocks: load 0.116 s vs 0.122 s with 86 fans, the pass cold 0.31 ms vs 6.02 ms, warm 0.19 ms vs 1.24 ms — and
  reading 2 (`offscreenDrawn=21 offIdeal=21 largest=9276.0 mean=4716.0` pt on the 150-block note). What the takes
  chrome forces per pass on main, by reading: every full pass forces one `firstLineGeometry` for every fanned block
  plus a whole-block union per peeked block and the pill's, and every scroll tick and keystroke forces the fans in a
  band padded by a viewport of characters each side. The first attempt's "after", by reading (`bb5087223`), is
  history in batch D's record, not shipped.
- **VM-218 (VoiceOver and text size):** Book Details' name row carries `.accessibilityLabel("Rename Book")`
  (`MobileBookDetails.swift`, the identity block, from before this run), which replaces the book's name for
  VoiceOver. (R2-N1's own fix stands — its window proved it.)
- **VM-188 (wave 5 — the visible badge and the foot pill):** it redraws the badge's face on the takes chrome; the
  rule it meets is whatever VM-17's run lands.
- **VM-113 (wave 3, the Bookcase):** the order choice ("a–z or last edited") is hers to build there (her ruling,
  above). Round 1's N6, withdrawn here: `MobileShelfViewModel.orderedBooks` is a computed sort
  (`localizedStandardCompare`) read several times per shelf and Library body — ∝ the books, P1 holds; when the
  order becomes a live choice, decide whether to sort once where the observation delivers.
- **VM-212 (wave 6, the pocket guide):** the guide's "a smart book collecting by tags"; "starred things sit above
  everything at the shelf's very top" (false for notes since the Starred page); the seeder's cleanup comment about
  "the shelf-pins setting"; and, once VM-85 and VM-212 retire the last two phone "smart" sites, the Mac's
  source-scanning ban (`DeadVocabularyTests`) in place of `noRenderedStringInTheseFacesSaysSmart`'s hand-kept list
  (N7).
- **VM-85:** the Today door's `.wrongKind` note still says "smart book" (`MobileTodayDoor.swift`).
- **VM-117:** the create sheet's "Create Book" button on the gathering kind (the record named the umbrella, VM-112).
- **VM-94:** the Starred page's "book" kind word on a gathering row.
- **VM-175 (wave 4):** the Finish confirm's "Open Arrivals first" button.
- **VM-161 (wave 4, Seal and unseal):** the phone's Unseal; when it lands the sealed sentence names it.
- **VM-115 and VM-161 (W-070, W-112):** the door-set hoist retires `finishRowAct(for:)`'s phone-side reading of
  the Mac's table.
- **VM-96 / its Trash face (wave 2):** under a kind filter the phone's empty line still says "Nothing in the Trash."
  when other kinds wait (the Mac's ledger-row-2 rule).
- **VM-99 (wave 2, the Archived room):** only the starred archived book's way out is built here; the Archived
  room's books group is VM-99's.
- **The merging session (shared ledgers):** the QUESTIONS bundle and F8's question; the tickets below; the dated
  entry, the narrative and the finals-ledger line under "To land on main at the merge".

### Tickets — minted, and to file (no id invented; each still to mint at the merge, with Linear's priority field and no assignee)

**Minted:**
- **VM-239** (minted 2026-11-19, after batch D's window) — callout washes, callout glyphs and comment marks stand
  away from their own blocks on a long note. Bug · Confirmed · Editor · High · Mobile. Its pin is the decor reading
  in history (`MobileDecorPlacementReadingTests`, added `211221f6b`, last edition `75984c0e6`, removed `7d84e4b22`),
  its red log `vm78-window-d-decor.log` and its bundle `d-decor.xcresult` from batch D's window; it goes with VM-17's
  run (`notes/plans/vm-17-chrome-geometry.md`). Related VM-17, VM-179.

**To file:**
1. **To mint on VM** — "The Archive room may paint 'Nothing archived.' before its listing answers." Bug ·
   Suspected · Library & sidebar · Low · Mobile. One-liner: `MobileArchiveView` draws its empty line on
   `model.visible.isEmpty` while `MobileArchiveModel.archived` starts `[]` with no answered flag and is filled by a
   `.task` after the first render — VM-33's class; check first with VM-33's pin shape
   (`MobileTrashTests.theFirstPaintSaysNothingBeforeTheListingAnswers`), fix with its answered gate. Related VM-99.
   Pointer: this record, round 1's N10. (Still so at HEAD: the merge did not touch it.)
2. **To mint on VM** — "A book's contents may paint 'No notes in this book yet.' before its listing answers." Bug ·
   Suspected · Books · Low · Mobile. One-liner: `MobileBookView` draws it on `model.entries.isEmpty` while
   `MobileBookViewModel.entries` starts `[]`; same check and fix as above. Related VM-122. Pointer: round 1's N10.
   *(N10 named both sites in one line; it is split here because a ticket carries one Area.)* (Still so at HEAD.)
3. **To mint on VM, or a line on VM-218** — "Book Details' name row hides the book's name from VoiceOver." Bug ·
   Confirmed (by reading the code; not run) · Books · Low · Mobile. One-liner: the identity block's
   `.accessibilityLabel("Rename Book")` replaces the name it shows. Pointer: round 2's final call on R2-N1. (Still
   so at HEAD.)
4. **To mint on VX** (or a line on a standing VX sweep ticket, if one exists at the merge) — "`Queries.bookshelf`'s
   doc still says shelf ordering is the view model's call over `shelfPins`." Debt · Confirmed · Books · Low.
   One-liner: `Sources/VariorumCore/Queries/ShelfQueries.swift:43-44`; both platforms order by `BookcaseBoard`
   since VM-83 and the phone no longer reads `shelfPins` (comment only — this run opened no `Sources/` line).
   Pointer: round 1's N4. (Still so at HEAD.)
5. **To mint on VX, only if F8 is answered (a)** — "The membership chip draws Diverge on a gathering's row, then
   refuses." Bug · Confirmed · Books · Low. One-liner: `MembershipChip.swift:136-145`; the phone stopped drawing it
   at VM-81 (W-110). Pointer: QUESTIONS PENDING(the QUESTIONS number, at the merge), F8.
6. **To mint on VM, or a line on VM-156 (Book settings, rules and states)** — "A double press on Book Details'
   Unarchive shows a refusal under the book the first press unarchived." Bug · Confirmed (by reading; not run) ·
   Books · Low · Mobile. One-liner: Book Details' act rows start one task per press with no in-flight latch; give
   them the undo door's `inFlight`, so "That book isn't archived any more — nothing changed." stays for the real
   race. Pointer: round 2's R2-N4 (the line under VM-62 above), whose intended owner, VM-62's sweep, merged without
   it.

**Not tickets to file:** VM-24 and VM-17 exist and are re-owned (each its own run); VM-179 exists and joins VM-17's
run; VX-68's relation is recorded above; window (3)'s jump road was clean on the unfixed chrome, and the first
fix's jump-road failure is VM-17's own run's evidence, so no jump-road ticket; the peek markers and the choosing
pill share the badge's rule and are in the record VM-17's run reads, so they need no ticket of their own.

### The ladder

- **Round 1** (`vm-78-ladder-round1.md`; a fresh `fable-reviewer`; diff `e48ef2f30..988e9434f`, 27 commits, 43
  files): **0 BLOCKER · 2 MAJOR · 6 MINOR · 11 NIT** (findings `708450404`, final calls `90610aa92`); nobody
  disputed a finding, none FINDER-FIXES. F1 (process): the ladder cannot close before batch C's window is
  cold-read. F2: the VM-17 probe's reading 3 was vacuous — rebuilt as the viewport invariant. F3–F5 and N1–N5, N7,
  N8 became code, pins and guards (`72fa54dc8`, `326d61da4`, `36ace0aa5`; batch C's `e3f406086`, `839d86dd9`);
  F6/F7 re-drew batch C's arms and ordered the instruments out before any whole-target run; F8 became a question;
  N6 withdrawn to a line for VM-113; N9 a walk row; N10 tickets; N11 bundles kept.
- **Round 2** (`vm-78-ladder-round2.md`; a fresh `fable-reviewer`, opened at `84fe72e50`; the whole diff
  `e48ef2f30..db4f1ec6b`): **0 BLOCKER · 0 MAJOR · 3 MINOR · 5 NIT** (findings `a00581328`, final calls
  `874da32d8`); nobody disputed, none FINDER-FIXES; it re-checked every round-1 final call as applied. R2-F1: the
  unreadable red bundle and the bundle rule; R2-F2: two "no arm" lines and arm A's posture expectation (both lines
  were met in window (3)); R2-F3: the probe's (i′) (`78179b765`); R2-N1: the rows' hints (`01205f799`,
  `97282e72f`; red/green in its own window, 07:19:38–07:23:59); R2-N2, N3, N5: record lines (`046a886fc`,
  `ed7b82ef4`); R2-N4: a line for VM-62, now a ticket to file (item 6 above). It did not close the ladder (F1
  stands).
- **Round 3** (`vm-78-ladder-round3.md`; a fresh `fable-reviewer`, opened at `35ce90848`; the whole diff
  `e48ef2f30..35ce90848`, 67 commits, 49 files): **0 BLOCKER · 1 MAJOR · 5 MINOR · 3 NIT**, none against a product
  line this run changed (findings `117e8c047`, final calls `b7161468b`, dispositions in this record `76bfc56b6`);
  nobody disputed, none FINDER-FIXES; it read window (3)'s outcome against its logs, the instruments' removal,
  reading (i′), R2-N1's fix, the VM-24 write-up, batch D's trace and, in its final calls, the settle measurement's
  log. R3-F1 (MAJOR): the block decor shares the standing-frame rule — a measured reading as its pin, which batch
  D's window then ran red, so VM-239 and VM-17's run; R3-F2: three points of the round-1 shape — the same-pass
  re-read, "a nil viewport resolves nothing", no amendment to reading 1; R3-F3: the instrument's display-link
  fallback bug, no action; R3-F4: withdrawn; R3-F5: VM-24's reach understated — a typed character can land
  unarmed; R3-F6: the rule for the red probe and the settle instrument's removal; R3-N1–N3: record lines, the
  probe's header comment. Its final calls CALLED VM-17's fix shape (S1–S11), which batch D built exactly and which
  failed its window; the shape left the tree with the back-out and is not assumed by VM-17's run.
- **Round 4:** PENDING(ladder round 4 — a fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim, writing
  `notes/plans/fixes/vm-78-ladder-round4.md`, reading as new work the back-out, the merge resolutions and VM-16
  re-landed (`git diff eb18888db...HEAD` against merged main; `a00581328..HEAD` since round 2's review): its count,
  its findings' dispositions, and any round it earns — a further round only on a new BLOCKER or MAJOR, within the
  cap of five). With batch D gone it reads no new editor-seam fix.

### Canon deltas

**Applied in place, SurfaceContracts › The Bookcase and books** — one clause each naming the phone, one pointer each
(`786f50af9`), kept beside VM-55's and VX-980's lines at the merge (`ed1266e2f`; none of main's lines already stated
these phone behaviors, so none was dropped), and re-read in the merged file at this re-fit: all five true of HEAD,
none changed.
1. The Bookcase bullet, after "Starred floats first under any order.": "The phone's shelf sorts by the same a–z
   rule, starred first, with no order door yet (`notes/plans/fixes/vm-78-fixes-to-whats-there.md`)." (The order door
   is VM-113's, her ruling.)
2. The book settings sheet bullet, the Finished state door, after "only when N > 0": "; the phone's Book Details asks
   the same, by the same count — `notes/plans/fixes/vm-78-fixes-to-whats-there.md`".
3. The same bullet's last sentence: "The pickers, chips and Book Panel mark "(archived)", and so does the phone's
   membership sheet (`notes/plans/fixes/vm-78-fixes-to-whats-there.md`)."
4. The Delete bullet, after "Delete Gathering… on a gathering, everywhere the door draws": ", the phone's shelf row
   and Book Details included", the pointer joining the bracket: "(the one capability's verb by kind; VX-611;
   `notes/plans/fixes/vm-78-fixes-to-whats-there.md`)".
5. The Delete bullet, after "The Trash's listing never claims emptiness before its first value answers": ", the
   phone's included (`notes/plans/fixes/vm-78-fixes-to-whats-there.md`)".

**MobileSoul §6, PL-77:** drafted as PL-75 (`224bb9c38`), renumbered PL-77 at the merge-in (`ed1266e2f`; main's
PL-75 is VX-980's and PL-76 VM-55's), and made true of HEAD at this re-fit (`e24e0fb81`): the takes-chrome claim
taken out and VM-17 (with VM-239 and VM-179, the kickoff named) moved under STILL OWED; VM-16's sentence said as
the re-landed door speaks; the sealed Reopen's sentence credited to VM-62's road; the VoiceOver viewport clause
taken out; "Verified so far" limited to the pre-merge windows and both targets built on the merged tree.

**AppSpec §9 (two sites) and OverallModel §3 — the insured restore, ratified** (QUESTIONS #274 addendum 2, "**P-849-1
RATIFIED + the phone wired** (the insured restore stands; the phone's one-argument insurance is VM-43)"; VM-43 wired
the phone's one door). Applied at `3471d0ad4`, verbatim, after checking that the ruling line is in QUESTIONS and
that the phone's door passes `insuringBuffer: true` at HEAD; nothing else in either file changed:
- AppSpec §9, "Quiet auto-commits". Old: "a restore about to replace a buffer's words (`restoreCommit(…,
  insuringBuffer:)`, passed true by the flush-first restore doors — PROVISIONAL, QUESTIONS #274)". New: "a restore
  about to replace a buffer's words (`restoreCommit(…, insuringBuffer:)`, passed true by the flush-first restore
  doors on both platforms — QUESTIONS #274)".
- AppSpec §9, `restoreCommit`. Old: "the restore doors flush pending typing first and pass it true (PROVISIONAL,
  QUESTIONS #274; VX-849)". New: "the restore doors on both platforms flush pending typing first and pass it true
  (QUESTIONS #274; VX-849)".
- OverallModel §3. Old: "a restore about to replace a buffer's words (`restoreCommit`'s `insuringBuffer`, the
  restore doors flushing pending typing first — PROVISIONAL, QUESTIONS #274)". New: "a restore about to replace a
  buffer's words (`restoreCommit`'s `insuringBuffer`, the restore doors on both platforms flushing pending typing
  first — QUESTIONS #274)".

**`notes/TEXTKIT2_NOTES.md` §3 — the two iOS 26.2 facts this run measured** (`02a3ac002`), in the section's shape,
one block after the macOS 27.0.1 VX-601 block: the unarmed replace's report widened past the line's terminator
inside `processEditing` (window (3)'s ranges, and its instability), pointing at VM-24's kickoff; and the forced
mid-document read's stale frame against the unforced read at the first subview after the text view's own layout
(the settle measurement), with the first fix built on it failing on the jump road — a measurement, not a recipe,
pointing at VM-17's kickoff. Neither is pinned in the tree (the instruments left before the gate).

**Sentences to revisit, and after which step** (round 3's R3-N2: neither MobileSoul nor SurfaceContracts may carry
the word "PENDING" at the merge; `grep -n PENDING notes/MobileSoul.md notes/SurfaceContracts.md` answers nothing at
this re-fit):
- After the re-land's window: if VM-16's or VM-33's pins do not go red and then green as the recipe expects, PL-77's
  VM-16 or VM-33 sentence and SurfaceContracts' clause 5 are revisited with the fix.
- After gate 3: a failed walk row takes its SurfaceContracts clause and its PL-77 sentence out with the fix's revert.
- At the merge: PL-77's "Verified so far by…" may gain the gate's three legs — written as what ran, never with a
  pending word.

**Weighed and NOT applied:**
- AppSpec §9's structural undo line ("the Mac's door says so as a refusal naming the entry") — still true; the
  phone's re-landed door now says the same on its one line, but the line is not false, and nothing was ruled to
  change it.
- AppSpec §9's union star ("the Mac's Pin door is retired into Star and Unstar") — still true; the phone's retired
  door makes it true of both, but the line is not false.
- The collect door's receipt line (SurfaceContracts, the Bookcase bullet) — it describes the Bookcase door's mint
  family; the phone's membership sheet speaks the Mac CHIP's composer (a live tags-only collect keeps the chip's
  words), so "the phone too" there would be imprecise; and whether the phone keeps the line is on her wording pass.
- "Finish not drawn on a gathering", "Reopen on a sealed book speaks the shared sentence", Diverge (F8), the date
  chip, the insured restore's door, the two lessons — no Mac contract line states these for the phone's faces, or
  they are drafts or open questions.
- The commit vocabulary line (SurfaceContracts, The app) already names "the phone"; VM-20 made it true there.
- SurfaceContracts, The note ("a corner badge only on fanned blocks") — VM-17's first fix left the tree; nothing
  about which blocks wear a badge or where it stands changed.

**Lines believed false or stale — NOT edited, for the orchestrator** (each re-checked at HEAD; still so):
- SurfaceContracts, the book settings sheet: the Finished confirm's quote "N waiting at the door will be dismissed"
  — the shipped words on both platforms are "N waiting at Arrivals will be dismissed." (`BookStateCopy.waitingLine`,
  `App/Variorum/Shared/BookStateCopy.swift`, re-worded at 17y B3 (h), R-17y-2, per the code's own comment). Not this
  run's change; clause 2 says the phone asks "the same", which is true of the code and of the count.
- SurfaceContracts still marks P-849-4 ("PROVISIONAL P-849-4, QUESTIONS #274") and P-849-5 ("PROVISIONAL P-849-5,
  QUESTIONS #274") as provisional; #274 addendum 2 ratified both. Not this run's.
- Core `Queries.bookshelf`'s doc (ticket 4 above).

### MOBILE PARITY

This run is a mobile run's own row in `notes/MobileSoul.md` §6: **PL-77**. The line for the master plan's closeout
paragraph:

> MOBILE PARITY: PL-77 — the phone's existing faces made right (the undo door's quiet press, insured restores, the
> date chip, the Trash's first paint, two pocket-guide lessons, the Finish confirm and the book doors, a–z with one
> star door, "gathering", the collect line and "(archived)" marks), re-landed on VM-55's message line; VM-24's
> snap-back and VM-17's stray fan badges traced, and each given its own run after wave 1 by her rulings (VM-17's
> with VM-239, the callout and comment marks, and VM-179); zero schema, marker untouched.

### To land on main at the merge (the merging session's, on latest main — shared ledgers)

**`notes/AppSpecRecord.md`, the dated entry (draft):**

> ## 2026-11-19 — VM-78, Run: Fixes to what's there (the mobile catch-up's wave 1, umbrella 4; SurfaceContracts The Bookcase and books · MobileSoul §6 PL-77 · AppSpec §9 and OverallModel §3, the insured restore ratified · TEXTKIT2_NOTES §3; branch `vm-78-fixes-to-whats-there`, PR PENDING(the PR number), merge PENDING(the merge SHA))
>
> **What landed.** Eight fixes to the phone's existing faces, pin before fix per member, with no `Sync/`, custody,
> schema or `Sources/` line, re-landed on VM-55's message line at the merge: the undo door's quiet press refuses
> with the shared sentence on the one line and records no way back (VM-16) and its warning says "committed"
> (VM-20); a restore keeps the words it replaces (VM-43, P-849-1's phone half); the divide lesson teaches
> keep-on-top (VM-3); the date chip follows the date (VM-84); the Trash says nothing until its listing answers
> (VM-33, found real); Book Details' Finish asks with the count when notes wait, says what Finished means and is
> not drawn on a gathering, while a starred archived book has its way out (VM-81); the shelf sorts a–z with
> starred first, its Pin door is gone and a gathering is called one in every face the brief named, Book Details'
> delete line included (VM-83); the collect line names the star and is honest on an archived gathering, and pickers
> mark "(archived)" (VM-21). VM-19's test teardown is fixed and its pin proved; its desync did not reproduce. Words
> hoisted into `App/Variorum/Shared/` (`BookStateCopy`, `ArrivalsCopy.word`, the collect receipt family,
> `StructuralUndoCopy.discardingUndoDetail`), every Mac string byte-identical.
>
> **What was traced and handed on.** VM-24 — the long-standing caret red — is the phone editor's edit routing: an
> unarmed edit whose report TextKit's attribute fixing widens past its block's terminator is refused and re-rendered,
> so the character or word just entered snaps back (stored text is never at risk); its own run after wave 1,
> measured on her phone before and after; its pin stays red on main by decision. VM-17 — stray fan badges on a long
> note's stepped scroll, two mechanisms (a frame kept from a forced mid-document read that TextKit later moved; a
> badge read before TextKit placed its line); a settle measurement found the moment an unforced read is placed; a
> first fix built on it went clean on the scroll and failed its stage window on the jump road, and was backed out;
> its own run after wave 1 with VM-239 (the block decor, measured astray the same way) and VM-179.
>
> **Her words (2026-11-19, in the orchestrator's session).** "sounds good, tonight, up to 5 review rounds as long as
> a major is found." · "book order - that's fine to leave it for wave 3. 2 - collect receipt your choice is fine." ·
> "the phone step is the single wave-1 install after all four runs have merged. I'll do the hands part hands on in
> the morning." (The whole messages are in the record's Kickoff facts.) On VM-24, a dialog pick, no prose: "Own run
> after wave 1 (Recommended)"; and to the stage coordinator: "I chose the own run after wave 1 option that vm-78
> proposed. i want you to message them about this to lock the plan down, but basically i want you to open a new
> session in tmux once wave 1 is done and merged, and tell it to architect-phase that issue, reporting to you for
> stage details. just kick that off when wave1 is done for me." On VM-17, a dialog pick, no prose: "Take it out, own
> run (Recommended)".
>
> **Cast.** Fable orchestrated (briefs, the verification windows from a throwaway checkout, adjudication, records;
> no batch code); a second orchestrator session took over at a clean seam (`notes/plans/vm-78-orchestrator-handoff.md`); a fresh `opus-implementer` per batch (B, A, C), a
> fresh one for the round-1 fix pass, a fresh batch C window runner, for batch D a fresh one for the trace and
> another for the build, a fresh one for the back-out and the merge-in, and documents-only closeout drafters; a
> fresh `fable-reviewer` per ladder round (the editor seam: VM-84's view model, batch C's caret and badge test code,
> batch D's takes chrome). nov18 coordinated the stage and the merges.
>
> **The ladder.** Round 1: 0 BLOCKER, 2 MAJOR (F1 the ladder cannot close before batch C is cold-read; F2 the VM-17
> probe's vacuous reading), 6 MINOR, 11 NIT. Round 2: 0 BLOCKER, 0 MAJOR, 3 MINOR, 5 NIT. Round 3: 0 BLOCKER,
> 1 MAJOR (R3-F1, the block decor shares the badge's standing-frame rule), 5 MINOR, 3 NIT; its final calls called
> VM-17's fix shape, which failed its window. Round 4: PENDING(ladder round 4: its count). Every finding
> dispositioned in the round files.
>
> **The windows.** Batch B 68/6 green after its seven reds; batch A 84/16 green after its 21 reds, the Mac's 17 types
> 110/17 green over the hoists; the fix pass 75/10 green after its four reds; F4's follow-up 4/1 after its one red;
> R2-N1's pin 11/2 after its one red; window (3)'s matrix — the caret pin red by design, VM-17's probe red (real),
> VM-19's pin red on the old teardown and green on the fix; the settle measurement 1/1; batch D's window — the fix
> NOT proved (eight reds on its green leg, the jump road unbadged), the decor reading red (VM-239); both targets
> built for testing on the merged tree. PENDING(the re-land's stage window; gate 1, the whole phone target; gate 2,
> the Mac leg; gate 3, the walk).
>
> **Canon.** SurfaceContracts › The Bookcase and books: five clauses naming the phone (the order, the Finish
> confirm, "(archived)" in pickers, Delete Gathering…, the Trash's first paint). MobileSoul §6: PL-77. AppSpec §9
> (two sites) and OverallModel §3: the insured restore no longer PROVISIONAL (#274 addendum 2). TEXTKIT2_NOTES §3:
> the two iOS 26.2 facts measured. `Tools/canon-size`: PENDING(the canon-size line, at the merge).
>
> **Provisionals.** QUESTIONS PENDING(the QUESTIONS number, at the merge): an archived gathering's add row wears
> "(archived)"; F8, Diverge on a gathering's row. **Born:** VM-239; PENDING(the minted ticket ids). **Hers:** the
> ratify list, the wording pass, VM-24's measuring session on her phone at that run's start, the launch of VM-17's
> run, PENDING(the single wave-1 phone install, only if this run is the last mobile merger).

**`notes/AppSpecRecord.md`, the narrative under its sections (draft):**
- *§9, `restoreCommit`:* the phone's restore door (Block History) passes `insuringBuffer: true` since VM-78
  (VM-43), so a phone restore keeps one quiet automatic commit of the words it replaces, deduped — P-849-1's phone
  half, ordered wired at #274 addendum 2; with both platforms' doors wired, AppSpec §9 and OverallModel §3 drop the
  rule's PROVISIONAL mark.
- *§12, The Bookcase and books:* on the phone, Book Details' Finish asks only when notes wait at Arrivals, by the
  dismissal's own count (`Queries.pendingArrivalCount`); its caption is the Mac's "Finished means…"; Finish is not
  drawn on a gathering (unless a legacy finished one, which shows Reopen); a sealed book keeps its Reopen, whose
  refusal speaks the shared table's sentence (by VM-62's road since VM-55's merge); a starred archived book's
  Details resolves it with Unarchive. The shelf sorts by `BookcaseBoard`'s a–z with starred first and has one star
  door; a gathering is called a gathering on the shelf row, the delete door, confirm and receipt (the shelf row's
  and Book Details' removal line), the membership sheet, the create sheet and the Trash's placeholder; the
  membership sheet marks archived books and draws Diverge on book rows only (PROVISIONAL, F8); the collect line is
  the Mac chip's, on the one line. The "Open Arrivals first" button waits for VM-175.
- *§12, The note:* VM-17 — on a long fanned note the phone's takes chrome leaves fan badges astray on a stepped
  scroll (a frame kept from a forced mid-document read; a badge read before TextKit placed its line); the settle
  measurement found an unforced read placed at the first subview after the text view's own layout (TEXTKIT2_NOTES
  §3); a first fix built on it failed on the jump road and was backed out; by her ruling one run after wave 1 with
  VM-239 (the block decor, measured astray) and VM-179 (`notes/plans/vm-17-chrome-geometry.md`). VM-24: the phone
  editor's unarmed edits are routed from the storage's report, which attribute fixing can widen past the block's
  terminator, refusing a plain in-block edit and re-rendering it away; her ruling gives it its own run after wave 1,
  measured on her phone before and after (`notes/plans/vm-24-unwarned-edit-routing.md`).

**`notes/plans/run-finals-ledger.md`, the line (draft):**

> - **2026-11-19 · VM-78 — Run: Fixes to what's there** (PR PENDING(the PR number), merge PENDING(the merge SHA)):
>   ten members in four batches (B: VM-16/43/3/84/33 · A: VM-81/83/21 · C: VM-24/17 traced, VM-19 · D: VM-17's
>   fix, which failed its window and was backed out) plus VM-20 and VM-19 carried; EIGHT members shipped, re-landed
>   on VM-55's message line by the merge-in; VM-24 and VM-17 (with VM-239 and VM-179) each to its own run after
>   wave 1 (her rulings); Fable orchestrated (a second session took over at a clean seam), Opus implemented, a fresh fable-reviewer per round —
>   round 1 0B/2M/6m/11n, round 2 0B/0M/3m/5n, round 3 0B/1M/5m/3n, round 4 PENDING(ladder round 4: its count);
>   windows (2) 68/6, (1) 84/16 + Mac 110/17, (5) 75/10, F4 4/1, R2-N1 11/2, (3) the matrix's ten runs + M5b, the
>   settle measurement 1/1, each after its reds; batch D's window red (the fix not proved, the decor red); five bundles
>   lost or unreadable (batch B's red not kept; fixpass-red, r2n1-red, d-red, d-green unreadable), their logs kept; PENDING(the re-land's stage window and the gate's three legs);
>   PROVISIONALS QUESTIONS PENDING(the QUESTIONS number, at the merge); born VM-239 and PENDING(the minted ticket ids).

**`notes/QUESTIONS.md`, the bundle (draft; main's next free number was #278 when the merge-in ran, to be re-checked
on latest main at the merge):**

> #PENDING(the QUESTIONS number, at the merge) — **THE VM-78 PROVISIONAL BUNDLE (the mobile catch-up's wave 1,
> umbrella 4; the binding record is `notes/plans/fixes/vm-78-fixes-to-whats-there.md`, FOR A LATER READER at its
> top; your checklist is `notes/handoffs/vm-78-handoff.md`).** (1) **An archived gathering's add row** in the phone's
> membership sheet wears "(archived)" — as built (a) "Quotes (archived) (by tagging)"; (b) the Mac chip's picker
> exactly (gatherings carry only "by tagging", unmarked); (c) no archived gathering in the add list. Does it wear
> the mark on both platforms? (2) **F8 — Diverge on a gathering's row** — the question text in the record's ratify
> list, PROVISIONAL as built: the phone draws none. (3) **The wording pass:** the divide lesson (VM-3), the
> "getting around" lesson's two sentences (F4), the create sheet's three gathering lines, the sealed book's Reopen
> sentence on the phone, whether the phone keeps a collect line at all. (VM-24 and VM-17 are not in this bundle: she
> ruled both — each its own run after wave 1.) **Status: OPEN.**

### Not done, or left for later — honestly

- Everything in this section's opening paragraph marked "Still ahead": the re-land's stage window, ladder round 4,
  the gate's three legs, the shared ledgers, `Tools/canon-size`, the PR and its merge.
- No AppSpecRecord, QUESTIONS, master plan, TICKETS or finals-ledger line was written (shared ledgers, the merging
  session's); their drafts are above.
- No ticket was minted from this record's "To file" list; VM-239's minting and VM-24's and VM-17's re-owning in
  Linear are the orchestrator's acts (the live state), not this document's.
- VM-24 is NOT fixed by this run, by her ruling; its pin is red on this branch and will be red on main until its
  own run.
- VM-17 is NOT fixed by this run, by her ruling: its first fix failed its window and was backed out; the takes
  chrome is main's; its pins left the tree and live in history for its own run.
- The walk has not run, so no face here is proved by use yet; the SurfaceContracts clauses and PL-77 stand on the
  pre-merge windows' pins and the merged tree's builds until it does.
- The re-landed fixes (VM-16, VM-20, VM-33, VM-81's and VM-83's joins, VM-21's line class) are built and read on
  the merged tree; their own red/green on that tree is the re-land's window, not yet run.

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
