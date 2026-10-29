# Coordinator handoff, part 2: 2026-10-28 09:30 → 2026-10-29 close

Session **oct27coordinator**, on the Pro. Part 1 (`coordinator-2026-10-27b-handoff.md`, this same PR) covers wave 2 through the
0.10.4 release. This part covers the launch-week runs VX-678 and VX-677, the absorbed VX-633 (the Prince), two releases, and
the close-out you ordered: "once VX-677 is rebuilt, ready, and has released to the website I officially want you to close
out, make sure that everything from the runs has been cleared / reset, that the environment traps are all noted durably
wherever they need to be, that things are all set for a new coordinator".

## Your checklist

1. **Your real store and the installed app.**
   - Installed: `/Applications` is **0.10.6 (10414)**, release 2, 10-29 07:02. I checked codesign deep/strict myself, and
     spctl says "Notarized Developer ID". The appcast leads with 10414 and the DMG is live.
   - Release 1 was **0.10.5 (10271)** on 10-29 04:14 (VX-648 · VX-440 · VX-678 · VX-633). It was notarized and published,
     the appcast verified, codesign checked staged and installed, and spctl reports "Notarized Developer ID".
   - The ONLY safety copy is **`variorum-a1-0.10.6-release-20261029T124534Z`**, which I cmp-verified (5 files SAME)
     against the live store with no instance running. The 0.10.4 and 0.10.5 copies are pruned.
   - One near miss, harmless: the 0.10.6 walk first renamed the July-era relic `Variorum-dev/` that sits in your REAL
     container beside `Variorum/`. The walk's G7 guard refused fail-closed, the rename was reversed, and your `Variorum/`
     was never touched (cmp above). It is now a written trap.
2. **The releases ran as you split them** ("i actually want VX-669 to do a release now … and then VX-664 can also do its
   own release").
   - 0.10.5's notes are at `App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-0.10.5.md`. They state both local-only
     migrations, v1_34 and v1_35.
   - VX-677's release is **0.10.6 (10414)**, its notes at `ReleaseNotes-0.10.6.md`. Step 0 passed on the first real run,
     with the three traps applied. Your walk screenshots for VX-572 are at `/Users/Shared/vx677-walk-shots`.
3. **Your bundles.**
   - QUESTIONS #250 (VX-678), #251 (VX-633/#204, including P-633-F1), #252 (VX-677).
   - Each run's handoff: `notes/handoffs/vx-678-handoff.md` (with its 0.10.5 addendum), the VX-633 entry in its plan
     record, and `notes/handoffs/vx-677-handoff.md`. VX-677's names the one-window words-guard relaxation, F-CW-1.
   - VX-661 (swift-testing's encoder crash) grew tonight: it now fires on green, single-test runs of rebuilt binaries.
     I'd raise its priority; that's your call.
4. **Calls still yours.**
   - VX-689: the JOIN road, where a fresh signed-out Prince could travel into your library. You called it "not a big deal".
   - VX-704: first-launch feel. Its premise fell, because the Prince never seeded tonight's walk births. The measurement
     road is in the ticket.
   - VX-697: the store-adjacent hold marker. It is Low, but it's real code: a fresh library born beside an orphaned hold
     file inherits the hold.
   - Still open from part 1: the VX-656/657 calls, the VX-637 real-⎋ check, and CLAUDE.md's stale "walk lift (a throwaway
     project)" line.
   - The commit-msg hook that strips AI trailers for every worktree. The classifier refused it to vx-664, so it's your
     hand or nobody's.
5. **Disk.** Free space was 39 GiB at your close-out word. After the sweep it is **94 GiB**. What was cleared is listed
   below. Two things are yours to decide:
   - `~/Library/Developer/Variorum/Releases/` holds 4.3 GB: every release's archive and dSYMs from 0.9.0 to 0.10.6, plus
     the feed. Those dSYMs are what symbolicate a crash report from that build. I kept them all. Pruning the 0.9.x ones
     would free about 2.2 GB.
   - The classifier REFUSED my deletion of seven branches that are already merged into main. You can run it if you want:
     `git branch -d vx-177-cards-icon vx-177-jadeite-icon vx-7-13s-voice-onboarding vx-7-handoff-finals
     vx-99-post-merge-review vx-99-pro-castle-apple-wrap` and `git push origin --delete vx-156-grant-ux-design
     vx-177-cards-icon vx-177-jadeite-icon vx-7-13s-voice-onboarding vx-7-handoff-finals vx-99-post-merge-review
     vx-99-pro-castle-apple-wrap`. Each one is `--is-ancestor` of main, checked 10-29.
   - Still open for you: the coordinator handoff PRs #203 (this one), #195, #175 and #168.
   - `vx-105-readme-letter` (unmerged, touched 10-29) is someone's live work, so I left it.
6. **The stage** is released, and nobody holds it. The next coordinator starts from the skill (updated in this PR) and the
   memory index.

## Merges

| Effort | PR | Merge commit | Time (MDT) | Notes |
|---|---|---|---|---|
| VX-678 (Trash resurrection and responsiveness, held the Sync/ slot) | #205 | `5aad3e378` | 10-28 21:50 | #250 · PL-64 · canon 126,641/150,000 |
| VX-633 (the Prince seed book, absorbed by vx-669 at your word) | #204 | `039aededb` | 10-29 02:22 | #251 · PL-65 |
| VX-703 (the walk's P4 wait; Tools only, your option (a)) | #206 | `b5e809c36` | 10-29 ~03:55 | harmless, not the cure (see traps) |
| VX-677 (editor seam, panes, the AI door) | #207 | `c78806aa1` | 10-29 06:4x | #252 (no PL row, nothing mobile-visible); ran release 2 |

## Stage numbers and timeline (`~/.variorum/stage.log`, from 09:30 10-28)

**16 session grants**, **1 expiry** (`vx-678-final` at 21:45:30, mid phone leg; I held it `HOLD FOR` and it
re-claimed at 21:45:53), **0 steals, 0 forced releases**, and **1 renew** (the 0.10.5 release, asked first).

| Run | Windows |
|---|---|
| VX-677 | vx677-b1 15:26–16:02 · b2 18:41–19:38 · final-suites 23:37–00:08 · final-walks 00:10–00:54 · c-suites 05:39–06:13 · c-walks 06:13–06:36 |
| VX-678 | window-1 17:37–18:39 · pins 19:45–19:50 · final 20:14–21:46 (lapse + re-claim) |
| VX-633 (#204) | suites-a 19:51–20:08 · tests-b 21:58–23:02 · walk 23:03–23:36 · fixes 00:54–01:12 · final 01:13–02:20 |
| Release 0.10.5 | 03:14–04:14 (A1 → release.sh 8 min → step 0 ×4 → refresh → publish → prune) |
| Release 0.10.6 | 06:45–07:02 (A1 → release.sh → step 0, one G7 refusal then PASS → refresh → publish → prune) |
| Coordinator | the Debug-prefs scrub at your word, 21:47–21:48 |

## Calls I made

- **The Sync/ slot** went to VX-678 alone, by explicit grant (10-28 14:05), and was released at its "nothing further owed"
  (21:5x). #204 touched no Sync/. VX-677 had no need.
- **#204's "after VX-678" hold was dropped.** You asked why it had to wait. I checked: zero shared code files, the Prince is
  not in `dedupeCovered`, and no release fell between the merges. vx-669 verified that and agreed.
- **Two merge GOs were held for one more whole-target window** (VX-678, then #204). Ladder fixes had changed product code
  after the last whole-target run (AppSession/AppServices; the seeders). Both re-runs came back clean apart from
  control-proven standing reds: VX-695, VM-34, and the VX-701 flake. VX-678's window was also the first phone run its
  Shared/ code ever had.
- **The reset walk for the Prince** ran as a SET-ASIDE plus an exact restore (WalkKit README 327–331), with the decline mark
  deleted first so the existing-store leg proved the decline live.
- **I declined to run a refused act.** vx-664's walker had its prefs-key delete refused, and the session offered the keys to
  me; I treated that as permission laundering. You then said "go ahead and clear those", and I scrubbed the Debug defaults
  domain: exactly the 2,622 per-note keys, 2,731 → 109, with a backup at
  `~/.variorum/debug-prefs-pre-scrub-2026-10-28T2147.plist`. That turned VX-695's red green for a while.
- **The 0.10.5 step-0 stops came to you twice,** under fence 1 and your "run once" word, rather than being rerun on my
  authority.

## What went wrong, honestly

- **My own timestamps ran fast** in memory several times (19:0x written at 18:34; 22:0x at 21:5x). I corrected them to the
  clock and now stamp with `date`.
- **A pre-approved renew never landed.** `vx-678-final` lapsed mid phone run. The hold caught it with nothing lost.
- **Sessions mis-read the screen and crashes.** vx-664 reported "no Problem Reporter" while one was up, and labelled the
  swift-testing encoder crash a product revert artifact. vx-669 put a lint re-run's verdict without an executed count. Each
  was caught from my own sweep.
- **The release's step 0 cost three stops.** All were environment, in one chain (below). vx-669's first trap hypothesis,
  that P4 was a timing race, was wrong; VX-703 shipped as a harmless wait that wasn't the cure.

## The environment traps, written down durably (this PR)

- `Tools/WalkKit/README.md`, "Step-0 environment traps":
  - set the dev slot aside WHOLE (VX-697's hold marker);
  - a stopped run leaves the walk app signed in;
  - seed marks leave step 0 on an empty store;
  - the -25200 capture class.
- `.claude/skills/stage-coordinator/SKILL.md`:
  - the last-whole-target tested-tree rule;
  - trial merges and the registry trap;
  - executed counts and the SpringBoard 0-executed launch;
  - the Problem Reporter and encoder-crash reads;
  - fast clocks and renew resets;
  - the Debug-defaults bloat scrub;
  - the laundering rule;
  - your dev-store content rule;
  - the live-run DerivedData ask.
- Memory: `release-step0-walk-traps.md`, `dev-store-is-the-agents.md` (vx-669's, your words).

## Cleanup done at close

Every item was verified on disk at close.

**Worktrees and branches.** `variorum-vx-678`, `variorum-vx-633` and `variorum-vx-677` are removed, and the branches
`vx-678-…`, `vx-633-prince-book`, `vx-703-walk-p4-wait` and `vx-677-…` are deleted locally and on origin. Each session did
its own; the classifier allowed theirs. Only `~/dev/variorum` (main) and this handoff's `variorum-coord-1027b` remain.
Remove the latter after you merge #203.

**Build output.**
- VX-677's worktree DerivedData, about 60 GB. vx-664 freed 29 GB mid-run and the rest went with the worktree.
- The main worktree's `App/Variorum/DerivedData/`: `release/` (1.4 GB), `vx510/` (the walk app, 1.9 GB), and
  `first-run-walk/`'s run folders and debris. I kept `first-run-walk/bin` (the walk's helpers) and `prod-reset/` (4 KB).
  The next release rebuilds the rest.
- No orphan global DerivedData.

**Copies and scratch.**
- Dev-store copies: VX-678's and VX-633's slot copies, deleted at their merges.
- `/tmp/claude-501`: vx-669 cleared about 2.5 GB and vx-664 its own. I cleared closed VX-439's 2.5 GB scratchpad (Swift
  probe builds only). Total now 153 MB.

**Settings and safety copies.**
- The Debug defaults scrub at your word: 2,622 per-note keys. The domain is 274 keys now, and the hosts re-grow it (VX-695).
- A1: only `variorum-a1-0.10.6-release-20261029T124534Z` remains.

**For your eye.** `/Users/Shared/vx677-walk-shots/` (251 MB, 555 PNGs): VX-677's walk films and the VX-572 Study shots,
trimmed by vx-664 to images only. Delete it when you've looked.

## Process notes for the next coordinator

- **The dev store (e11e5233), as of close.** Its content is the agents' (your rule).
  - The library is restored byte-exact after the 0.10.6 walk and HELD by its Oct-20 banner (never press Resume). It is
    signed out, and the vxtest accounts are at rest.
  - v1_34 and v1_35 are applied.
  - App Appearance is Dark (`appearanceChoice` = dark), and macOS is Light.
  - MCP: the server is OFF and claude-code is approved with no grants. Its key binding may be orphaned and re-binds at the
    next setup copy. A denied `vx677-walk` client row also stands.
  - Trash and leftovers:
    - Home's Trash holds walk residue, Sherlock and its 13 notes among it.
    - A live `#classics` tag stays in Home.
    - WK Book sits in the Walk Wing's Trash.
  - The Debug prefs are 274 keys and include the `the-prince` decline mark.
- **Step-0 walk traps:** read `Tools/WalkKit/README.md`, "Step-0 environment traps", before any release GO. There are five:
  - set the whole folder aside;
  - sign out after a stop;
  - empty-store seeding;
  - the words guard;
  - the two `Variorum-dev` folders.
- Read `oct27coordinator-resume-state.md` only as history. Start fresh from the skill.
- The commit trailer: sessions still need reminding. No hook exists yet (item 4 above).
