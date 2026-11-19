# VM-78 — orchestrator handoff (a cutover inside the still-open run)

Written 2026-11-19 by the first orchestrator session (`vm-78`), at a clean seam: the back-out and the merge-in are
committed, both targets build on the merged tree, no agent is live. The first session's context had grown past
the project's cutover guideline; this file lets a fresh orchestrator finish the run from the repo.

## Paste-ready kickoff

> /run-phase vm-78
>
> You are RESUMING the run VM-78 (mobile catch-up, wave 1, umbrella 4, "Fixes to what's there") as its second
> orchestrator; the first cut over at a clean seam. Nothing is half-done. Do NOT re-mint, re-branch or
> re-announce a new effort: the branch is `vm-78-fixes-to-whats-there`, the worktree `~/dev/variorum-vm-78`, the
> in-flight row is on main, the stage coordinator is the session named `nov18` (announce yourself to it as the
> successor of `vm-78`; REQUEST, READY, GO, RELEASE as before).
> Read first: `notes/plans/vm-78-orchestrator-handoff.md` (this file), then
> `notes/plans/fixes/vm-78-fixes-to-whats-there.md` WHOLE (a cutover inside an open effort reads whole) — "The
> orchestrator's live state" is the map and its newest UPDATE outranks older text — and the three round files
> `notes/plans/fixes/vm-78-ladder-round{1,2,3}.md`. Then pick up at "What remains" below.

## Where the run stands

- **Eight members are proved** (red on the old code, green on the fix, in stage windows before the merge-in):
  VM-16 with VM-20, VM-43, VM-3, VM-84, VM-33, VM-81, VM-83, VM-21; and VM-19's teardown pin. Ladder rounds 1, 2
  and 3 are closed, every finding dispositioned.
- **Two members left the run by her rulings, each to its own run after wave 1:** VM-24 (kickoff
  `notes/plans/vm-24-unwarned-edit-routing.md`; the coordinator launches it; the caret test stays red and
  unwrapped on main BY DECISION) and VM-17 (with VM-239 and VM-179; kickoff
  `notes/plans/vm-17-chrome-geometry.md`; hers to launch). Both tickets are re-owned out of the umbrella.
- **The back-out and the merge-in are done** (record: "### THE MERGE-IN"): batch D's fix and pins reverted, the
  probe and the measurement tests removed; `origin/main` (`eb18888db`: VX-980 and VM-55) merged in by
  `ed1266e2f`; VM-16 re-landed on VM-55's message line; this run's parity row is PL-77. Tip `9ee926cb1` (plus
  this file's commit). Phone and Mac `build-for-testing` green on the merged tree.

## What remains, in order

1. **The re-land's stage window** (phone only, about 12 minutes; the recipe is in the record, "THE MERGE-IN" →
   "The window recipe"): RED with `MobileUndoDoor.swift`, `MobileTrashModel.swift`, `MobileTrashView.swift` at
   `eb18888db` — four types, six reds expected; GREEN on the tip — 41 phone types, all green. The first
   orchestrator had this queued with `nov18` when it cut over; **if the record's live state does not carry the
   window's result, it has not run** — re-point the throwaway checkout and run it (below).
2. **Ladder round 4** — a fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim with `{PHASE}` = `VM-78`,
   plus locators only (the plan file is this run's record; the diff `git diff eb18888db...HEAD` for the run
   against merged main and `a00581328..HEAD` since round 2's review; round files 1–3 as anchors; it writes
   `notes/plans/fixes/vm-78-ladder-round4.md`). It reads as new work: the back-out, the merge resolutions and
   VM-16 re-landed. Cross-model flow: findings verbatim to an implementer (a fresh `opus-implementer` — every
   earlier implementer's context is spent), its answers verbatim back to the reviewer for final calls, the
   implementer applies, pins red-on-old. **Her allowance covered up to five rounds "as long as a major is
   found", for the night of 2026-11-19; round 4 runs under it (she was told and did not object). A round 5 needs
   her word.** A final round's fixes get the orchestrator's line-by-line check against each finding.
3. **The gate** (`nov18` reads the whole-phone result against main's ONE red, VM-24's caret test, with no
   allowance): the whole phone target on the tip · a Mac leg over the changed `Shared/` files (the record's
   merge-in section lists tier 1's 17 types and tier 2's; size it in the READY with reasons — `nov18` asked) ·
   the simulator walk on the dev-store Debug phone build through the changed faces (the walk rows are in batch
   A's and batch B's LIVE STATUS plus round 1's N9; no fan-badge row any more).
4. **The closeout documents re-fitted** — they were refreshed BEFORE batch D's window and still describe VM-17's
   fix as built: the record's `## Closeout` and `## FOR A LATER READER`, `notes/handoffs/vm-78-handoff.md` (it
   must LEAD with the two decisions made: VM-24's own run and what needs her hands there; VM-17's own run and
   that it is hers to launch), and `notes/MobileSoul.md` row PL-77, **which is false as it stands** (it says the
   takes chrome gained VM-17's change). No "PENDING" may remain in `notes/MobileSoul.md` or
   `notes/SurfaceContracts.md` at the merge. Two canon deltas the first orchestrator told her it would apply on
   the merged tree and name in the handoff: dropping "PROVISIONAL" from the insured restore in AppSpec §9 (two
   sites) and OverallModel §3 (QUESTIONS #274 addendum 2; the exact old → new text is in the Closeout, "Canon
   delta proposed"), and this run's measured iOS 26.2 layout facts into `notes/TEXTKIT2_NOTES.md` §3.
5. **The merge moment** (ask `nov18` first; merges serialize): on latest main — `notes/QUESTIONS.md` (the
   PROVISIONAL bundle and round 1's F8 question; next free number was #278), `notes/AppSpecRecord.md` (the dated
   entry; drafted in the Closeout), `notes/plans/run-finals-ledger.md`, the master plan (in-flight row retired,
   closeout paragraph), `Tools/canon-size`; the PR `VM-78: …` merged as a MERGE COMMIT; Linear — the eight
   members, VM-19 and VM-20 Done, the umbrella Done, VM-24 / VM-17 / VM-239 left open, the tickets to mint from
   the Closeout's list; the worktrees (`~/dev/variorum-vm-78`, `~/dev/variorum-vm-78-pins`) and the branch
   removed; her tickets list given again as the last chat message.
6. **If this run is the last mobile merger** (VM-47 and VM-64 are still open): prepare the single wave-1 phone
   install (her ruling in Kickoff facts).

## Machinery the successor needs

- **The throwaway checkout** `~/dev/variorum-vm-78-pins` (detached; its own DerivedData `vm78-pins`) is where the
  orchestrator runs red/green windows without disturbing an implementer. For the re-land's window it sits at
  `9ee926cb1` with the three files staged at `eb18888db` and its build in progress or done.
- **The window scripts** are throwaway instruments, never in the PR; copies sit, local and gitignored, in
  `~/dev/variorum-vm-78/App/Variorum/DerivedData/vm78-scripts/` (`r-cycle.zsh` is the re-land's). They hold the
  simulator's UDID, which never enters the repo — the pre-push guard refuses it, and an absolute home path.
- **Every window's log** is under `App/Variorum/DerivedData/logs/`, bundles under
  `App/Variorum/DerivedData/vm78-bundles/`; a failed run's `xcodebuild` lingers and its bundle is usually
  unreadable — the log is the evidence. Result lines to `nov18` name every red and say what RAN.
- **Never write in the worktree while an agent is live there**; record commits are pathspec commits.
