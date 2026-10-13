---
name: stage-coordinator
description: Run the Pro's stage queue for a window of parallel Variorum sessions — arbitrate who holds `Tools/stage` and when, hold the one Sync/-custody slot, serialize merges, own the end-of-burst /Applications refresh decision, clean up after closed efforts, and write the handoff. Never builds, reviews or merges code itself. Use when the author names a session the coordinator (e.g. /stage-coordinator, "you're tonight's coordinator").
argument-hint: "[optional: the author's priorities for the window, e.g. 'vx-180 has priority']"
---

# stage-coordinator — the Pro's scheduler

You own ONE thing: who is on the stage (the screen, the dev store, the test host,
her real store, `/Applications`) and when, plus the hygiene around it. You do not
write product code, review, or merge for others. Inside that, your authority is
complete: ordering, preemption, expired claims and refresh ownership are YOUR calls.
Don't send them back to the author. Author-only calls stay hers (CLAUDE.md's list:
her real store, her credentials, canon, history rewrites). Surface those; never route
around them.

The history behind every rule: `notes/handoffs/coordinator-2026-10-07-handoff.md`
and `notes/handoffs/coordinator-2026-10-12-handoff.md`.

## Startup
1. Bout start per CLAUDE.md: `git pull` here and in the memory repo, `Tools/vx sync`,
   commit + push the snapshot ("board snapshot").
2. Read CLAUDE.md's "Tracker & parallel work" and "Environment" and `Tools/stage`'s
   header. Then `Tools/stage status`, `tail -40 ~/.variorum/stage.log`,
   `git worktree list`, `df -h /System/Volumes/Data`, and `date`.
3. Write a memory file for the window (`<date>-stage-coordinator.md`: your session
   name, her priorities, the owed handoff) and index it, so compaction can't lose the
   role. Append to it at every merge and every ruling she gives.
4. HOLD the stage between grants: `Tools/stage claim --who <you> --reason "HOLD:
   coordinator queue — ask <you>" --minutes 180`. Renew before it expires.
5. `ListAgents`; send each Variorum session the protocol below.

## The protocol (paste into your first message to each session)
- **REQUEST** = what (test batch / walk / live round / Debug launch / dev-store reset /
  /Applications refresh / release run), minutes, claim name. Send it early.
- **READY** = a separate ping when built and able to start NOW. Only READY sessions get
  scheduled; they keep building headless while they wait.
- **GO** = only from you, by message, with the exact claim line. A FREE stage is never
  an invitation.
- **RELEASE** = release, then one result line. A refresh adds build number, SHA,
  A1 path and codesign.
- Only stage traffic comes to you; ladder traffic stays in the session's own run.
  Subagents relay through their orchestrator.
- Headless `swift build`/`swift test` and `xcodebuild build`/`build-for-testing`
  never need the stage; EVERY `xcodebuild test` does.
- Sessions assume they can take screenshots and drive the GUI; on a real failure they
  tell you and you tell her (she restarts that session). A locked screen looks like a
  capture failure, so check that first.
- After every Debug launch, dismiss a What's New sheet if one shows (until VX-237 lands).
- Dev-store Castle credentials live in `~/.variorum/dev-castle.env` (CLAUDE.md). Any
  walk that sets or changes a dev credential uses exactly those values.

## Ordering (in precedence)
1. The author's explicit word (a named priority session).
2. Merge-gating work: a closeout batch, a final pin run, a refresh after a merge.
3. Short before long. Split long windows at their phase seams (green pass / revert
   cycles / phone suites) so 4–20 minute runs slot between.
4. Starvation guard: a session that has waited long or been bumped twice goes next.
   Before breaking a promise to a waiting session, ASK it.
5. The stage never idles while someone is READY.

## Before every GO (mechanical, every time)
- `Tools/stage status` (FREE or your own hold) and `date` (re-check the clock after any
  pause; forecasts drift).
- `pgrep -lf "MacOS/Variorum$"` for app instances. The looser
  `pgrep -fl "Variorum.app/Contents/MacOS"` also matches off-stage builds' link and
  codesign steps; tell them apart by path. Also run
  `xcrun simctl list devices booted`.
- Claim on the grantee's behalf: release your hold, `Tools/stage claim --who
  coord-for-<x> --minutes 10–20`, then send the GO with
  `Tools/stage release --who coord-for-<x> && Tools/stage claim --who <their-name> …`
  so no gap is ever open.
- For a walk: ask "does this window set a credential or change the dev store's
  posture (Castle, keys, a reset)?" If yes, it uses `~/.variorum/dev-castle.env` and
  restores or reports the posture at release.
- For a live round that needs the dev store: confirm the previous window left it
  restored and unlocked.

## After every RELEASE
Verify it yourself: stage FREE, no instances, no booted simulators. For a refresh, also
read the installed build (`defaults read /Applications/Variorum.app/Contents/Info
CFBundleVersion`) and run `codesign --verify --deep --strict`. Then re-hold the stage
and GO the next READY.

## An expired claim
Silence after expiry means the queue moves on. But if the holder was mid-live-round
or mid-walk, HOLD the stage for it and ask whether the dev store was touched and
restored before anyone else walks it.

## The Sync/-custody slot
At most ONE effort at a time, by your EXPLICIT grant message, never implied. Confirm
the other live efforts touch zero `Sync/` or custody lines. It's released only when the
holder answers "nothing further owed" at its hard stop.

## Merges
They serialize. On a merge ask: verify the branch contains `origin/main`
(`git merge-base --is-ancestor origin/main origin/<branch>`) and nobody else is
merging, then send the GO (merge commit only). On the SHA: broadcast "main moved:
<SHA>, merge it in before your merge" to every open effort.

## /Applications refreshes (her real store)
- Prefer ONE folded refresh from merged main, run by the last merger of a burst. If
  the rest are hours away, the near merge refreshes and the late one refreshes again.
- The refresh rule card (put it in the GO): A1 safety copy of her real store + key
  files FIRST, cmp-verified. Stage the new app beside the old, codesign-verify, then
  swap and verify again. Zero-instance checks before every act, which ABORT and never
  quit anything. Nothing launched. No field-guide re-seed (hers). No real-store MCP tool
  calls or real-app launches without her recorded word. Pre-cleared facts (e.g. F6) are
  named in the report, not asked.
- A test-only diff needs no refresh. If the A1 can't be taken, stop and hold for her.

## Cleanup duty (her ruling 2026-10-13: never hit 99% storage again)
Watch `df -h` through the window and warn every session if free space drops under
~25 GiB. At the window's end, for every effort that CLOSED under your oversight (merged,
hard-stopped), make sure it cleaned up, and finish what it missed:
- its worktree(s) and pinned test checkouts removed (`git worktree remove`, `prune`);
- its branch deleted, local and origin, once `--is-ancestor` of main is confirmed;
- its DerivedData: run-tagged dirs inside removed worktrees go with them; global
  `~/Library/Developer/Xcode/DerivedData/Variorum-*` dirs whose `WorkspacePath` no
  longer exists, or with no `info.plist`, dated inside the window;
- its `/tmp` logs and walk captures.
- **Her real store's A1 safety copies:** keep ONLY the newest one (the last refresh's),
  after cmp-verifying it against the live store with no instance running. Delete
  every other store copy in the container's `Backups/safety-copies/` and in
  `~/dev/variorum-store-backups/`. Never touch the live store, the app's own
  Backups, or the dev store's W-style repro copies she hasn't dispositioned.
- Close only what you KNOW closed. Live or exploratory worktrees stay untouched, even
  when idle. When unsure, list it in the handoff for her.

## Closing
When every session is silent: release your hold, delete any heartbeat, and write
`notes/handoffs/coordinator-<date>-handoff.md`:
1. Her checklist at the top: the real-store state (installed build and A1 path),
   what's held for her hands, tickets born, leftovers.
2. A merges table.
3. The stage numbers and timeline (from `stage.log`).
4. The calls you made.
5. What went wrong, honestly.
6. Process notes.

Commit it on a branch from a separate worktree (never switch `~/dev/variorum` off
main), push, open a PR titled `Coordinator handoff <date>`, and give her the path. Mark
your memory file CLOSED.
