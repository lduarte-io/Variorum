# Coordinator handoff — 2026-11-05 → 11-08 (nov5)

The window ran from 2026-11-05 17:13 to 2026-11-08 02:17 MST, on the Pro. It covered the whole of wave 2: VX-878, VX-819, VX-827 and VX-808, all merged. It finished with VX-808's marker-15 mirror deploy and **the Variorum 1.3 release**, both run by her sitting session `variorum-de` at her go. There was a long idle hold between 07:45 on the 6th and 22:40 on the 7th, while she was away.

## 1. Her checklist

- **Your real store.** `/Applications` is **Variorum 1.3 (build 11707)**. I verified the CFBundleVersion and `codesign --verify --deep --strict`. The one kept safety copy is **`Backups/safety-copies/A1-20261108-pre-1.3-refresh`**, with all six store files cmp-identical to your live store (variorum-de's check). The older **`A1-20261105-pre-1.2-refresh` is in your `~/.Trash`**, not deleted, because the harness refused `rm -rf` inside your container. **Empty the Trash when you like.**
- **The field guide in your real store is STALE**, from VX-827's lineage lessons and VX-808's B5. Re-seed it yourself via **Help ▸ Restore Field Guide…** in 1.3.
- **The Air:** update it to 1.3 through Sparkle. Until it updates, it's on a marker-14 build, and since the deploy, marker-14 builds refuse to sync with production.
- **Production is at marker 15.** `variorum-de` ran `Server/supabase/18_vx808_arrivals_pins.sql` through your stored PAT at your word ("yes i wanted it to do the deploy for me"). I verified it read-only: `sync_schema_version()` = 15, and `reading_post.arrival_provenance` and `pinned_at` are present.
- **VX-872:** the 1.1-older-build arm is **DROPPED** at your word ("we don't need the 1.1 check"). The rest of the live two-device Journal round stays on the ticket, for post-deploy builds.
- **The dev store's posture changed at your word.** Settings ▸ MCP's server is **ON**, `variorum-de` is an approved client, and the two demo arrivals at harbour review stay. The next walkers shouldn't "restore" MCP to off. It still holds **claude-code** as an approved client from earlier, plus tonight's replaceable walk fixtures. The usual "library as of October 20 · Resume Sync" bar is still there, and Resume was never pressed.
- **VX-855** (the purge-sweep reader racing pool teardown, a SQLCipher codec SIGSEGV) had a **second sighting**, at 02:39:29 on the 6th, at a whole-target host's quit in vx-878's window. It's commented on the ticket. **VX-661** (swift-testing's encoder stack-guard SIGSEGV) hit five times, all after per-test verdicts had printed. They're commented, including the new shape where green small-selection runs crash at exit.
- **VX-850** (MCP socket timing under load) fired in every whole-target or core run tonight, and every time it passed when run alone. Data points are on the ticket.
- **The phone red on main**, `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`, is standing. It had four duplicate tickets, VM-24/34/37/38, and your sitting deduped them.
- **Tickets born this window**, with full lists in each effort's handoff: VX-890 (vx-819), VX-891 and VX-893 plus VM-42 (vx-808), VX-892 plus VM-41 (vx-827), and vx-878's set (see its handoff). Your walkthrough added **VX-895–899**, and the sitting added more up to **VX-906**. The bundles **#264–#267 are CLOSED** (`409b37ad8`).
- **Leftovers from the previous window, not mine and untouched:** the local branch `vx-871-sweep-refusal-wording` (PR #225 merged; its tip `4bd7ecf07` is a stale local merge-main commit, safe to delete at your word), and `/tmp/vx828-prefs-{before,after}.plist` and `/tmp/vx853-pr-body.md`.

## 2. Merges

| # | Effort | PR | Merge | Ledgers | Gate (tested tree) |
|---|---|---|---|---|---|
| 1 | VX-878 book doors & faces | #229 | `35a98fb6a` | `5a9612650` | whole target on `da408355a` (6077/1054) + six-file fix + 11 suites re-run on `fbca5d431` (92/11); phone 852/139 |
| 2 | VX-819 search | #230 | `8fb04998b` | `a8c53fcf8` | whole target on `3e8bb59ef` (6019/1047) + post-878 overlap re-run, 41 suites on `2c134f320` (260/41) + core |
| 3 | VX-827 lineage | #231 | `602077445` | `1d4364355` | whole target on `6033016ea` (6091/1056) + post-819 headless core + smoke 69/9 on `f336297e7`; phone 852/139 |
| 4 | VX-808 Arrivals & books (Sync slot, v1_37) | #232 | `29cf674ea` | `516ebc093` | whole target on `72c3924cf` (6165/1068) + phone 852/139 (standing red only) |
| — | **Release 1.3** (build 11707) | — | `d453defec` | notes `c9a0ab221` | FirstRunDrillTests 11/11, first-run walk `std` both arms PASS; DMG + appcast verified; site `207bd08` |

The Sync/-custody slot went to vx-808 at her word (17:15 on the 5th) and was released at its hard stop. I re-granted it to `variorum-de` for the deploy, release and refresh, and it was released at "nothing further owed" (01:51 on the 8th). **The slot is FREE.**

## 3. Stage numbers and timeline (`~/.variorum/stage.log`)

There were 23 session windows, not counting bridges and my holds.

| Window | Time | Min | Result |
|---|---|---|---|
| vx-808-b2-suites | 11-05 19:39–19:43 | 4 | 49/5 green |
| vx-808-b3-window | 20:27–21:10 | 43 | 180/17: 2 test-side reds → fixed green; walk W-1..W-3 |
| vx-808-b3-rewalk | 21:23–21:35 | 12 | red-on-old proven; W-4 found |
| vx-819-b1-gate | 21:42–21:46 | 4 | 23/4 green + walk |
| vx-808-b4-window | 22:23–22:32 | 9 | 173/17 green + pin walk |
| vx-819-b2-gate | 22:32–22:46 | 14 | 138/20 green + VX-408 red-on-old |
| vx-819-b3-gate | 23:28–23:54 | 26 | 228/42 green; **W10 failed in use** |
| vx-819-b3-regate | 11-06 00:02–00:08 | 6 | fix still red |
| vx-819-b3-regate2 | 00:17–00:22 | 5 | walk all green; rig red |
| vx-819-b3-close | 00:27–00:28 | 1 | rig premise red |
| vx-819-b3-final | 00:32–00:35 | 3 | 29/4 green + red-on-old |
| vx-827-window | 00:52–01:48 | 56 | whole target 5 reds → **preempted for vx-878** |
| vx-878-closing | 01:49–02:51 | 62 | whole target + phone (2 reds → fixed) |
| vx-827-phone | 02:52–03:02 | 10 | 852/139 (standing red) |
| vx-878-walk | 03:03–03:21 | 18 | 92/11 + walk |
| vx-819-merge-gate | 03:22–04:22 | 60 | whole target 6019/1047 green |
| vx-827-window-2 | 04:23–05:09 | 46 | whole target 6091/1056 green |
| vx-819-merge-rerun | 05:10–05:26 | 16 | 260/41 green |
| vx-827-walk | 05:26–05:42 | 16 | 17 rows green |
| vx-827-merge-smoke | 05:51–05:54 | 3 | 69/9 green |
| vx-808-gate-window | 06:22–07:28 | 66 | whole target 6165/1068 + phone |
| lillian-debug-test | 11-07 22:44 → 11-08 01:30 | 166 | her walkthrough of main 516ebc093 (build 11702) |
| variorum-de-release | 11-08 01:30–01:51 | 21 | 1.3 released + refresh |

The stage was busy almost continuously from 21:23 on the 5th to 07:28 on the 6th, idle (my hold) until 22:40 on the 7th, then busy again for her sitting.

## 4. The calls I made

- **Preempted vx-827** at 01:48 (it had been holding the stage while its implementer fixed five reds headless) so that vx-878, READY since 01:43, could run its merge gate. vx-827 hadn't touched the dev store.
- **Whole-target re-run rulings.** vx-827's second window ran the whole target again, because its fix touched `TutorialSeeder`, which 25–42 test files construct. vx-878 was spared a fresh whole target, because its six-file fix was local to the MCP pane and trail. That made its gate: whole target + fix diff + 11 suites.
- **Second-merger re-runs instead of whole targets** after each merge. vx-819 re-ran 41 overlap suites after vx-878, and vx-827 ran a 9-suite smoke after vx-819. Neither merged-in code touched AppSession, AppServices or the seeders.
- **Phone suites added** to the merge gates whenever `App/Variorum/Shared/` changed: vx-827 (OpsRefusalTable and RecoveryCopy) and vx-808 (AppBootstrap, plus v1_37 and Sync/).
- **Slotted vx-827's phone arm** at vx-878's SEAM, and vx-819's overlap re-run at vx-827's SEAM.
- **Advised vx-808 to fold** its 45-type B5 window into one post-reconcile whole-target gate. That saved a full window.
- **Held the `/Applications` refresh** until after the marker-15 deploy, because a marker-15 build would refuse production sync on her real store.
- **Caught five FILE-name `-only-testing` entries** before they silently ran nothing: `TutorialBooksChapterTests` and `TutorialWalkTests` (twice), plus vx-819's own `ShellLandingTests` and `CommentTextAreaTests`.

## 5. What went wrong, honestly

- **My hold lapsed unnoticed overnight.** After renewing at 00:10 on the 7th, I didn't re-arm the expiry watcher, so the hold ran out around 03:10 and I only saw it at 22:40. `stage.log` shows nobody claimed the stage in between. The lesson: re-arm the watcher in the same turn as EVERY renew.
- **A stray test message** ("ignore") went to vx-878's socket after that session had hard-stopped. It's harmless, but it was a careless send.
- **One mistyped socket address** (a guessed pid) failed safely with nothing delivered. The fix: copy `from=` verbatim.
- **Problem Reporter dialogs left up** by vx-827 (00:54) and vx-878 (02:39). I closed both. Sessions now add `pgrep -fl "Problem Reporter"` to their release checks.
- **The newest-mtime DerivedData launch.** vx-808 launched a sibling worktree's older build and touched the dev store with it, harmlessly (one click, one capture).
- **vx-819 ran a 22-second core slice concurrently** with vx-827's whole target, before my message reached it. It was green, and vx-827's run showed no load reds.
- **A stale old-tree test host** (vx-878, pid 80417) appeared at ~03:03:25 inside vx-878's own claim, after a failed test-bundle start. Its spawner is unproven, and it was killed before any store act. My guards had been clean at 03:03.
- **Ambient focus loss:** the Phone app (Continuity) stole focus twice on the 5th, and loginwindow once (screen lock).

## 6. Process notes for the next coordinator

- **Walk lessons from this window**, which every walking session got:
  - launch the Debug app by DerivedData `info.plist` WorkspacePath matched to your own worktree, **never by newest mtime**;
  - **⌃⌘F to a windowed state first** (in full screen, cliclick's `t:`/`kp:` typing doesn't land, though its clicks do; System Events keystrokes work), and quit windowed;
  - the note header's **tag field is blind to synthetic typing** while an editor holds first responder (keys fall into the body, and a stray Return divides), so seed tags via quick-entry `{#tag}` and repair with ⌥⌘Z;
  - **revert legs restore with `git checkout HEAD --`**, not a bare checkout, after `apply -3`.
- **The 2-step merge-in check works:** trial-merge every open pair at each merge (`git merge-tree --write-tree --name-only`), and intersect the merged code files with each open branch to pick the second merger's re-run set.
- **Whole targets ran 46–50 min each** on this machine tonight; plan windows on that, not 25–30.
- **Debug defaults** grew from 879 to ~1125 keys over the window, well under the ~2,700 VX-695 threshold.
- **Disk** went from 107 GiB down to a 63 GiB low during vx-878's three old-tree builds, and ended at 91 GiB after I removed the closed efforts' orphan DerivedData (vx-808 4.0 G, vx-878 3.9 G) and /tmp debris.
- **Her preference, stated at close:** **one coordinator per wave.** Wave 3 starts with a fresh coordinator.
