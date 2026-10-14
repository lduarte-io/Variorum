# Coordinator handoff, 2026-10-13 → 14 (oct13coordinator)

The Pro's stage coordinator from 17:04 MDT on the 13th to the close at ~12:50 on the 14th, under
`.claude/skills/stage-coordinator`. Three overnight runs went through the queue to their merges, and the night's one
`/Applications` refresh ran last. Your mandate to the runs (relayed via vx-282, ~00:50): *"continue on through the night
ending in a merge to main - the final merge in of the night can be the only one to do an applications refresh."*

## Your checklist

1. **Your Pro's app:** `/Applications/Variorum.app` = **0.9.5 (7503)**, built from merged main `66b95d9b` (PR #162's
   merge `712bbb4f` plus vx-246's docs commit). I verified the build and `codesign --verify --deep --strict` myself.
   - **The first launch is yours.** F6 applies: it may sweep a lingering silent key copy on your real store. Nothing to
     do.
   - **The old 7045** is at `~/.Trash/Variorum-7045-replaced-by-vx246.app`, restorable.
   - **Your real store's ONE safety copy:** `…/io.lduarte.Variorum/…/Variorum/Backups/safety-copies/vx246-refresh-20261014T172650Z/`.
     I compared all seven files to the live store with nothing running (all identical), then removed the older
     `vx184-refresh-20261013T214607Z`. `~/dev/variorum-store-backups/` holds no store copy.
2. **Review the three runs' outputs from your Air.** The paste-ready prompt is in my last messages to you. It has
   Claude verify the merges and finals mechanically, then walk you through each handoff and its provisional calls:
   - VX-281: `notes/handoffs/vx-281-handoff.md`, QUESTIONS #219 (nine calls).
   - VX-282: `notes/handoffs/vx-282-handoff.md`, QUESTIONS #220–#224.
   - VX-246: `notes/handoffs/vx-246-handoff.md`, QUESTIONS #226. Its scope trim is also a provisional call: the new
     wire tools and the docs unit moved to the follow-on run VX-336.
3. **Tickets born tonight** (each run's handoff carries the pre-launch-or-not question):
   - **VX-281:** VX-330.
   - **VX-282:** VX-319, VX-320, VX-321, VX-322, VX-325, VX-331, VX-332, VX-334, VX-335, VX-337, VM-18 and VM-19.
     VX-229 was cancelled as hollow: its leak was runner-only, and a heap read on the running app found nothing
     retained.
   - **VX-246:** VX-323 (born and fixed), VX-318 (closed, not a bug), VX-324, VX-327, VX-328, VX-333, VM-16, VM-17
     and VX-336 (the follow-on run).
4. **The iOS simulators were ERASED at your word**, not deleted. All 49 devices keep their names, so every run's
   destinations still work. It freed less disk than `du` promised (see "What went wrong").
5. **Still yours, carried over:**
   - the dev store's W-1 repro `castle-W1-20261013` (in the dev container's `Backups/safety-copies/`), not yet
     dispositioned;
   - the field-guide re-seed;
   - a stray untracked `default.profraw` (10-13 17:00, before my window) at `~/dev/variorum`'s root;
   - older disk users, if space gets tight again: `/private/tmp/claude-501/-<home>-dev-variorum` (~10 GB
     of old sessions' scratch), the gitignored `notes/plans/*-screens` captures (~5 GB) and `/private/tmp/dd-vm5-*`.
6. **For the next coordinator:**
   - VX-305 (Castle phase 1) started at 12:32 and holds the `Sync/`/custody slot per its own in-flight row
     (`554d0849`). It took the slot in its kickoff before any coordinator grant, so the new coordinator should record
     the explicit grant. The slot was free; no other effort touches `Sync/` or custody.
   - I released my hold at 12:52 with the stage FREE. At your word, vx-246 is cleared to use it for a release build
     for the website. That build will produce a newer build than the 7503 now in `/Applications`.

## What merged

| PR | Run | Merge commit | On-main after | Refresh |
|---|---|---|---|---|
| #159 | VX-281 MCP settings pane + shared icon (vx-281) | `0f5efe1c` | `3d42df78` ledgers · `fa3bc6e1` handoff | none |
| #160 | VX-282 Editor & notes fixes (vx-282) | `19be2f01` | `3ddec585` ledgers · `f3cc8d07` handoff | none |
| #161 | VX-266 Castle design (notes only, merged outside the queue) | `2f5ac7a7` | `c62eda7d` ledgers | none |
| #162 | VX-246 MCP door fixes (vx-246), the night's last merge | `712bbb4f` | `66b95d9b` · `c1f42841` | 0.9.5 (7503) |

Before each merge GO I checked that the branch contained `origin/main`, that GitHub reported it mergeable and clean,
that it was the only open PR, and that nothing outside `notes/` had changed since the tree its merge-moment run
tested.

## The stage (from `~/.variorum/stage.log`, 17:05 → 11:34)

- **33 working windows** across three efforts: vx-282 ×18, vx-281 ×8, vx-246 ×7. That includes three merge-moment
  whole-target runs, two live rounds with a real Claude Code on the dev store, eleven windows with walks and the one
  refresh.
- **No collisions** and no overlapping holders. Your real store was touched only by the refresh's A1 and my
  prune-time compare, each done with zero instances running.
- The first window was granted at 21:58 (vx282-u1); the refresh was released at 11:33.
- Every dev-store window ended restored, byte-identical to its safety copy. In each live round, your user-scope MCP
  servers fingerprinted the same before and after.
- **Disk:** 63 GiB at the start, a low of 28 GiB at 23:47, then 80 GiB at the close after the runs pruned ~63 GB of
  finished build folders and I cleaned up.
- **Timeline in brief:**
  - 21:58–00:14: U1/U2 windows and walks for VX-281 and VX-282.
  - 00:23–05:16: VX-246's units interleaved with VX-282's.
  - 01:36–03:01: VX-281's ladder fixes.
  - 03:43–04:23: VX-281's merge-moment run → merge.
  - 08:40–10:01: VX-282's merge run, its phone crash and decider → merge.
  - 10:28–11:09: VX-246's merge-moment run → merge.
  - 11:26–11:33: the refresh.

## The calls I made

1. **Ordering:** VX-281 went first whenever it was READY, because VX-246's last units waited on its merge (the
   critical path). Otherwise READY order, short before long, plus the starvation guard.
2. **Asked before breaking a promise:** vx-282 had been promised "next" and agreed to let VX-281's 10-minute re-check
   go first.
3. **Split long windows at seams:** vx-282's three-part window was split after part 2, and vx-246's 120-minute window
   got a SEAM ping between its batch and its live round, so a merge-gating run could slot in. None needed to.
4. **Walk clearance:** I first cleared walks on evidence (no local input on the Pro for ~2 h), then your word ("i
   won't be at the pro all night").
5. **The simulator cleanup** used `simctl erase all` rather than `delete`, so the runs' destinations kept working.
6. **Merge order:** VX-282 first, then VX-246, because VX-282's merge-moment run was already on the stage. When
   VX-282's phone crash appeared I kept the order: its 5-minute decider was cheaper than making it redo a 60-minute
   run after a VX-246 merge. The decider found an older test-posture gap (VM-19), not VX-282's code.
7. **Refresher:** VX-246, as the night's last merge. It ran under the full rule card.

## What went wrong

1. **Startup sweep:** I messaged every Variorum session at startup, which woke six sessions that didn't need the stage.
   You ruled that coordinators never do this; it's saved to memory and amended in the skill in this PR.
2. **My hold lapsed:** my first 180-minute hold expired at 20:06 and I didn't notice until 21:57. For almost two hours
   I told you I held the stage when I didn't. The log shows nobody used it in the gap. The skill now says to re-check
   the clock on every message.
3. **Forecast clock times:** I gave you and the sessions times like "releases ~01:30" until two runs cited your
   no-time-predictions rule.
4. **Memory hygiene:** a `git add -A` in the shared memory repo swept another session's uncommitted edit
   (`vx-266-castle-backups-state.md`) into my commit. The content was intact, but the commit message was wrong. I
   stage only my own file now.
5. **The simulator erase freed far less than `du` showed:** the folder went from 32 GB to 0.7 GB, but free space rose
   only ~4 GiB. The simulator data was mostly copy-on-write clones of the iOS runtime. On APFS, `du` overstates what
   deleting will free.
6. **A stale relay:** variorum-d1 relayed an outdated "she picked jadeite, re-source PR #150". I caught it against the
   sea-glass record before anyone acted.
7. **PR #161 merged outside the queue** during VX-246's closeout run. You said that was yours and won't recur. It was
   notes only, so VX-246's evidence held.

## Process notes

- **The SEAM pattern worked:** a long window runs its tests first and pings before taking its dev-store copy. That
  lets a merge-gating run slot in without fouling either run's restore check. It's in the skill now.
- **Docs-only main moves need no re-test:** checking `git diff --name-only <tested> <tip> | grep -v '^notes/'` at
  each merge ask was enough to keep three runs' evidence valid while main moved under them. It's in the skill.
- **Sessions' own lessons worth keeping:** `defaults import` merges keys rather than replacing them (two walks found a
  walk-added key left behind, so restores must re-export and diff). The loose `pgrep -f` form matches headless
  `xcodebuild` command lines, so use `pgrep -lx Variorum`. `Tools/stage status` exits 1 while a claim is held. All
  three are in the skill.
- **Folding a window into the next unit worked well:** vx-282 never held the stage while its own builder ran (FOLD).
  It cost a few round trips but kept the pointer-injection suites on an idle machine.
- **Disk:** the run-tagged DerivedData trees are the real consumer, about 3–5 GB per unit. One mid-run nudge to prune
  finished units' trees took us from 31 to 65 GiB. Worth doing at every closed unit, not just at a run's end.
