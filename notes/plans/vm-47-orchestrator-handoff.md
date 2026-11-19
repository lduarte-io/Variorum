# VM-47 — the orchestrator's handoff (for a resumed or compacted orchestrator session)

Written 2026-11-19, 14:15, by the orchestrating session (`/run-phase vm-47`, session name `vm-47`), at her word:
"I want you to prepare for compaction and give me a kickoff prompt to send you post compaction." This file is
the orchestrator's state, repo-first. The run record is `notes/plans/vm-47-sizes-and-look.md` (§4 LIVE STATUS is
the truth for every piece); this file says what the ORCHESTRATOR was doing and what it does next. Machine-local
details that do not belong in a public repo (the session scratchpad's path and its script names, subagent ids,
the simulator ids) are in the orchestrator's private run-state memory, `vm-47-run-state`.

## UPDATE 14:35 — newer than "State at writing" and step 1 of "Next, in order" below

- **Step 1 is DONE.** The whole phone target on the re-landed tree ran 14:06–14:18 and is at baseline: 1,045
  tests in 179 suites, one host launch; the only red is VM-24's caret test (2 of 3 cases); 8 known issues (the
  four standing, this run's four filter-row marks). VM-55's wing-door suites and this run's path-line suite pass
  on one tree; the message line's, the wing landing's, the tab bar's, the Protection door's, Settings', the
  appearance choice's and the bottom bar's suites pass. The standing simulator's test-host container lists
  `Variorum-dev` only. The stage was released at 14:18:14 and the result line sent. This result is NOT yet in
  the run record: the next agent that commits the record writes it into §4 (batch 6) and §6 "Batch 6 — results",
  with her two unrecorded quotes into §1 (they are in the run-state memory).
- **Step 2 is DONE as far as the build.** The walk driver and the phone test host are built
  (`App/Variorum/DerivedData/vm47-walk`); the walker ended "WALK READY" and only DRIVES; `notes/plans/vm-47-walk.md`
  is whole for a fresh reader (§1 the captures' file names, §2 the standard, §3 every capture and what to check,
  §4 the screen rows for verdicts).
- **The orchestrator holds no stage claim and no agent is running.**
- **The coordinator's order (its call, 14:30):** another run's walk pass (to 14:58 at the latest) → another
  run's 20-minute phone window → THIS RUN'S MAC LEG (step 3: 114 types, 25 minutes) → another run's merge gate
  (a QUIET window of about 80 minutes: no cold builds or whole-package runs) → THIS RUN'S WALK PART A (30
  minutes, 99 captures) at that gate's release → PART B (50 minutes, 182 captures, resized from part A's
  measured timings; a merge gate that is READY goes ahead of it). Each piece gets its own GO with a claim line.
- **Part A's result line** owes the coordinator: the walk device's id, the captures counted and where they sit,
  the eight combinations each judged from its captures (the fresh reader's verdicts, sent as a follow-up if the
  reading is not finished inside the claim), the device shut down with its library kept, its container's
  Application Support listing, no Problem Reporter, no new crash report, the measured timings and the resized
  ask for part B.

## Read first, in this order

1. This file.
2. The run-state memory `vm-47-run-state` (the private half of this handoff).
3. `notes/plans/vm-47-sizes-and-look.md`: §1 (her words and rulings), §2 (the rules every batch inherits), §3
   "Batch 6" and "One walk for the whole run", §4 LIVE STATUS, §5 (R-47-1, R-47-2, P-47-1 … P-47-28).
4. `notes/plans/vm-47-ladder-midway.md` and `vm-47-ladder-round1.md` (their §2 tables), `notes/plans/vm-47-walk.md`.
5. `CLAUDE.md`'s "Phase execution" and "Tracker & parallel work"; `.claude/skills/run-phase/SKILL.md` (the loop,
   the closeout ritual); `notes/SessionResiliencyProtocol.md`.

## What the run is, in five lines

VM-47 "Sizes and look" is umbrella 1 of mobile catch-up wave 1: eight members (VM-48, 49, 50, 51, 52, 53, 54 and
VM-27). Branch `vm-47-sizes-and-look`, worktree `~/dev/variorum-vm-47` on the Pro, in-flight row on main. The
stage coordinator is the session `nov18`: every `xcodebuild test`, simulator boot and walk needs its GO (REQUEST
→ READY → GO with the exact claim line → RELEASE with one result line), and merges serialize through it. Cast:
the orchestrator never implements; ONE subagent at a time; `opus-implementer` builds, `fable-reviewer` cold-reads
(`notes/REVIEW_PROMPT.md` verbatim, zero framing); her word for this run: a midway review (done) and "up to 5
rounds as long as a major is found".

## State at writing (14:15)

- **All code is in.** Batches 1–5 (the phone type layer, inks and metrics; shared controls and 44 pt targets; the
  library's voice and palette with the grounds; the bottom bar; Settings), the midway review's fix, the ladder's
  round 1 (0 BLOCKER, 0 MAJOR; its two comment sentences applied), and batch 6: VM-55's branch merged in and
  re-landed (VM-55 itself merged to main as PR #13; main `eb18888db` is merged into this branch). Code tip
  `b20b04fad`; both schemes build into `App/Variorum/DerivedData/vm47-b6`.
- **Every bug-class pin is proven red on old:** the Terminal path line, the 13 pt floor in the UIKit type form
  (M-1), the borders on a light or dark switch (VM-54), the doubled Protection row (VM-27).
- **Suites so far** (each in §4): batch 1 and 2 whole phone targets; batch 3's whole phone target and its Mac leg
  (511 tests in 102 suites); batch 4's and batch 5's targeted suites; batch 5's fifteen Mac types. The one red
  that is not this run's is VM-24's caret test (`aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`,
  2 of 3 cases). The declared known issues: four pre-existing on the phone, and this run's four filter-row
  marks (P-47-7).
- **IN FLIGHT when this was written:** the whole phone target on the re-landed tree (the first run of both
  runs' tests on one tree), run by the orchestrator under its own stage claim `vm-47`, taken 14:06:36 for 30
  minutes, as a background command. Its verdict was expected about 14:27.
- **The walker** (a fresh Opus implementer) has written ONE unified walk driver and runbook
  (`notes/plans/vm-47-screens/instruments/VM47FinalWalkDriver.swift`, `walkfinal.zsh`; gitignored) and the
  findings file's skeleton (`notes/plans/vm-47-walk.md`: 31 screen rows, every capture id, what to check). It has
  NOT built the driver (held until the phone leg's verdict) and no walk has run. It ended its turn standing by,
  already deep in context.
- **Nothing has been looked at on a screen.** The run has no use-shaped evidence yet: that is the one walk.

## Next, in order

1. **Close the phone leg on the re-landed tree.** If the stage is still held by `vm-47`: read the background
   run's output, confirm the simulator is shut down and no `VariorumMobile` instance is left, check that the
   standing simulator's test-host container still lists `Variorum-dev` only (the script prints it), RELEASE
   (`Tools/stage release --who vm-47`) and send `nov18` the result line: counts; every red by name; VM-55's
   wing-door suites and this run's path-line suite called out; the baseline (VM-24, the known issues); any
   `.ips`. If the claim lapsed while the session was away, say so to `nov18` plainly. A red that is this run's
   goes to a FRESH `opus-implementer` (trace first; pin moved by design, real regression, or wrong test premise),
   re-run alone before it counts.
2. **Tell the walker "tree is free"** so it builds the driver (`walk_build`, into `DerivedData/vm47-walk`), then
   it reports "WALK READY". Because it is deep in context, plan a CUTOVER: the walker DRIVES the two parts (its
   runbook resumes from a progress file, each call under ten minutes); the captures are READ by a fresh
   `opus-implementer` per part, briefed by `notes/plans/vm-47-walk.md`'s rows and the sizing sheet. Do not let
   one agent both drive and read 281 captures.
3. **The targeted Mac leg** on the re-landed tree (114 types: the 102 theme-store types, batch 5's eight,
   VM-55's four Mac pins), READY with `nov18` since 13:50, run by the orchestrator; report passed, failed and
   skipped, `TakesEntryBandTests` and the seven theme types called out.
4. **REQUEST the walk** from `nov18` once the driver is built: part A about 35 minutes (99 captures), part B
   about 45 (182 captures), device `vm47-walk` created in part A and deleted at the end of part B. The
   orchestrator takes and releases each claim and messages the walker "GO, part A until HH:MM". Part A's result
   line carries the walk device's id (in the message only).
5. **The walk's findings**: this run's defects fixed narrowly (a test where one can hold it; red-on-old in a
   snapshot worktree, never by reverting the run's worktree), re-captured or re-run; other tickets' defects named;
   questions for her into §5.
6. **Ladder round 2** (a fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim with the phase named as VM-47
   and its record; no other framing). Round 1 earned no further round by her rule; round 2 is taken because the
   re-land of VM-55 and the walk's fixes entered after it. Findings verbatim into
   `notes/plans/vm-47-ladder-round2.md`; the implementer answers; the reviewer makes the final calls; the
   implementer applies. A MAJOR earns the next round, up to five.
7. **Closeout** (run-phase step 6), then the merge gate through `nov18` (the whole phone target and the whole Mac
   target, QUIET, on a tree that contains `origin/main`), the PR titled `VM-47: …`, a merge commit, the ledgers on
   main, cleanup. The list for THIS run is below.

## Hers: open questions and what is held for her

- **P-47-28, asked of her directly at 13:50, unanswered:** the Bookcase root's own line reads "Home · Shelf · N
  books" (Terminal `~/home/shelf · N books`) under a tab that says "Bookcase". Recommended: the page word follows
  to "Bookcase". Built: "Shelf" stays (VM-55's words). It goes into QUESTIONS at the merge and is named at the top
  of the handoff unless she rules first; if she rules "Bookcase", it is a small rendered-word change for an
  implementer, with VM-55's pins that read the path moved for that reason.
- **P-47-27:** in Terminal at 402 pt the path line's tail truncates.
- **Every other PROVISIONAL call is in §5** (P-47-1 the sizing sheet's numbers as drawn … P-47-26). R-47-1 (her
  prose never on the tint) and R-47-2 (the phone's voice row writes the library's voice) are RULED.
- **Her hands:** the wave-1 install on her phone is ONE install from merged main after all four mobile runs have
  merged, prepared by the LAST merger (a Release device build of merged main, signing verified, main's sync
  version checked against production's, the runbook `notes/plans/vm-44/plans/vm-45-install-runbook.md` re-checked)
  and started by her at the phone. `nov18` names the last merger when the third mobile merge lands; prepare
  nothing for the device build before then. Her glance at which Protection door stayed (the standing row). The
  wording pass over the new lines (§6 "Batch 5 — results", "Every new rendered line").

## Closeout, the parts specific to this run

- **The record:** its FOR A LATER READER section (still PENDING at the top of the record) written last; the
  STATUS banner flipped to CLOSED; §5 carried into `notes/QUESTIONS.md` at the merge moment (the coordinator gave
  the next free number as #278 at 13:40; re-check).
- **Canon, two-file shape:** the phone's surfaces this run ships enter `notes/SurfaceContracts.md` in place (the
  phone's look follows the library's voice and palette; appearance is this phone's own; the bar; Settings' list
  and its doors; one Protection door on the Settings sheet), with the dated entry and her words appended to
  `notes/AppSpecRecord.md`; `notes/MobileSoul.md`'s parity ledger row (the coordinator reserved PL-77 for this
  run; tell it when taken); QUESTIONS #199's ThemeStore hoist LANDED and #195 MINOR 3 CLOSED. `Tools/canon-size`
  run, its line in the handoff.
- **Tickets.** Members VM-48, 49, 50, 51, 52, 53, 54 and VM-27 close with the merge; the umbrella VM-47 too. Each
  remainder below must sit on an open ticket (a comment on the owner, or a new ticket triaged to CLAUDE.md's
  labeling rule; never an invented number; no assignee):
  - VM-52's W-009 (the empty system bar above the masthead on pushed screens), deferred with owners: VM-148
    (Write), VM-122 (a book's contents and Read), VM-100 / VM-99 (Trash, Archived), VM-110 (Protection), VM-147's
    umbrella (Versions).
  - The Settings palette row the mockup draws: no owner yet. File it.
  - For VM-137 (Writing): the editor body has no 13 pt floor in Terminal at the smallest text setting; the
    paragraph scale is taken at launch; one stale comment in `MobileEditorTextView`; the markdown marker ink; the
    editor's text inset.
  - The doubled divider in the note's ⋯ sheet: VM-61 / VM-148. The Library filter row as words, and its
    Terminal-at-Display-Zoom known issue: VM-93. The overlays' fixed frames: VM-152. The capture box's rows:
    VM-73. The keyboard bar's glyph sizes: VM-138 / VM-139.
  - A phone test that reads `@Dependency(\.database)` unscoped falls through to the live value and opens (or
    creates) the simulator app's own store: propose a ticket (Debt, Tests & tooling) to make that fail closed in
    a test host.
  - Whatever the walk and round 2 add.
- **The handoff** `notes/handoffs/vm-47-handoff.md`, written last: her checklist at the top (the Bookcase word
  first), the PROVISIONAL list, the filed tickets in her checkbox format by priority (and again as the session's
  very last chat message), the canon-size line, the MOBILE PARITY line, what wave 2 needs from this run. Wave 2's
  kickoffs already exist in `notes/plans/vm-44-mobile-catch-up-plan.md`; no new plan file is owed.
- **After the merge:** the in-flight row retired and the closeout paragraph on main (the outgoing one rolled to
  the archive); the worktree removed; the branch deleted on GitHub and locally; `App/Variorum/DerivedData/vm47-*`,
  the walk device, `notes/plans/vm-47-screens/` and the session scratchpad's logs deleted; the run-state memory
  marked CLOSED.

## Lessons this session paid for

- A subagent implementer ends its useful life at 400–700k tokens: cut over at a seam to a fresh one briefed from
  the record, and give stage work (suites, walks) to the orchestrator's own scripts or a fresh closer.
- Suites that scan sources at run time need a still tree: run them from a detached gate snapshot worktree with its
  own DerivedData when an implementer is editing, and never build into a product folder a pending window reads.
- A red-on-old is proven in a snapshot worktree with the one fix reverted, never by reverting the run's worktree.
- The pre-push guard refuses a simulator id, an absolute home path, an email or an account id in the repo.
- Count instances with `pgrep -x Variorum` / `pgrep -x VariorumMobile`; never `pgrep -fl`, and never `grep` a
  crash report's JSON without cutting the line length.
- Every message to a live implementer says: if this arrived while a command was running, check that command's
  result before going on.
- A phone run's "0 tests in 1 suite passed" after a host restart is no verdict: count launches and restarts.
