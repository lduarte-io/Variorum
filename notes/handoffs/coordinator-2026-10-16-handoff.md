# Coordinator closeout, 2026-10-16 (oct13coordinator)

The window's end, at your word ("go ahead and run your closeout as a coordinator - all the current sessions are done,
leave the stage open"). The full story through the release is `notes/handoffs/coordinator-2026-10-15-handoff.md`
(PR #165). This file covers the closeout and what's left for you.

## Your checklist

1. **Your Pro runs 0.9.7 (7933)**, the one release covering VX-336 and VX-283. It's published on the website and
   installed in `/Applications`; codesign and spctl both pass. The old 0.9.5 (7503) is in the Trash.
2. **Your real store's safety copy:** only the newest remains, `Backups/safety-copies/vx283-refresh-20261016T180250Z`
   in the app's container. It's cmp-identical to the live store on all 7 files.
3. **Held for your hands:**
   - **VX-376:** drag notes in the sidebar's Open list by hand. Synthetic drags can't reach sidebar drops on main or on
     the branch, so the drag shipped proven only by its pins and by matching the book navigator's road. vx-283's
     handoff names a one-commit fallback.
   - **QUESTIONS #228:** you've answered part of it; the rest stays provisional until you've used 0.9.7.
4. **The stage is open** (released at the closeout), for whichever session or coordinator comes next.
5. **Left alone, for you to decide:**
   - `/tmp/default.profraw-vx283-20261016T174909Z` (6 KB), the profiling file moved aside for the release. The rule is
     never to delete it.
   - The 0.9.7 release's own intermediates, `App/Variorum/DerivedData/release/release-0.9.7-20261016T175207Z.noindex`
     (668 MB). It holds the DMG and the release records; the older ones are deleted at your word.
   - VX-283's walk evidence, `notes/plans/vx283-screens` (376 MB, gitignored, screenshots and logs only).
   - **Copies of the app outside `/Applications` that macOS still has registered** and that still exist on disk:
     - One full Release build with your real store's identity (`io.lduarte.Variorum`), from 10-12, in an old session's
       scratchpad: `…/scratchpad/dd-vx192-release/Build/Products/Release/Variorum.app`.
     - The rest are Debug builds (dev store) in `/tmp` and old scratchpads.
     - `/private/tmp/13y-release-dd`'s copy is an empty husk with no Info.plist or binary, so it can't launch.

     None is from this window, and I didn't touch them.
   - **Live worktrees, untouched:** `~/dev/variorum-vx-305`, `~/dev/variorum-mobile`, and a `bisect-wt` in a
     scratchpad (a session's own).
   - **Old local branches from before this window:** `vx-177-cards-icon`, `vx-177-jadeite-icon`,
     `vx-7-13s-voice-onboarding`, `vx-7-handoff-finals`, `vx-99-post-merge-review`, `vx-99-pro-castle-apple-wrap`.

## What merged on the 16th

| PR | What | Merge commit |
|---|---|---|
| #167 | VX-283: Run: Sidebar & Library polish | `e2efdc794` |
| #165 | My 10-15 coordinator handoff (with the release outcome) | `af19a0152` |

VX-283's post-stamp fills landed on main directly (`01e69ce64`), after the stamp, so the freeze stayed clean.

## The stage since 10:40 on the 15th (from `stage.log`)

- **Nine windows:** vx-283 ×8 (U2, the walk, U3c, U2b, U2c with the main-build control, U2d, the closeout run, the
  release) and vx-336 ×1 (the release I started too early; stopped, nothing published).
- **No collisions.** Every dev-store window ended restored and cmp-identical; I verified each safety copy and pruned it.
  The dev store's safety-copies folder holds only your `castle-W1-20261013` repro.
- **Expiries:**
  - My hold lapsed three times while a usage limit paused me. Nobody used the stage in those gaps.
  - vx283-close's claim lapsed once, because vx-283 was paused by the same limit.

## The closeout's cleanup

- **Deleted at your word:** the 0.9.3 (×2) and 0.9.6 release leftovers, about 4 GB. I unregistered their app copies
  from LaunchServices first.
- **Deleted under the skill's cleanup rule:** ten orphaned global DerivedData folders from the 14th–15th (no
  `info.plist`, one traceable to VX-336's removed worktree), about 1.2 GB.
- **Already gone:** VX-336's and VX-283's worktrees and branches, and my handoff worktree and branch.
- **Disk:** 59 GiB free, up from 40 at the overnight low.

## What went wrong (since the 10-15 handoff)

1. **I restored vx-283's dev store for it** when its claim expired. It was only paused by the same usage limit, and my
   hold alone was enough. Your rule is in my memory: the coordinator only keeps track of the stage.
2. **A stray command of mine hung** waiting for input and left an empty file in the shared memory repo. vx-283's memory
   commit picked it up; I deleted it.
3. **I briefly ran a stage-everything git command** in the memory repo and undid it at once. Nothing extra was
   committed.
4. **vx-283 released one window with its control instance still running.** It quit the app within a minute, and the
   store was untouched. It now waits for zero instances before restoring and releasing.

## Process notes

- **A shared usage limit pauses the coordinator and the claimants together.** The right move on an expired claim is to
  hold the stage and wait.
- **The stage-log watcher** caught every release made without a ping. It's needed only while someone else holds the
  stage.
- **Synthetic cliclick drags can't land drops in the sidebar,** proven on main itself. Walks that need a sidebar drop
  need your hands or another road.
