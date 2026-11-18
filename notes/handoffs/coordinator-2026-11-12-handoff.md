# Coordinator handoff — 2026-11-12 → 11-18 (nov12)

The Pro's stage coordinator for one quiet, stretched window. Its scope at the author's word was "only helping a
mobile planning session"; the VX-997 Ambient session joined later. No merges ran through the queue, nothing touched
`/Applications/Variorum.app`, and the Sync/-custody slot stayed free throughout.

## Her checklist

- **Real store (Mac):** untouched. `/Applications/Variorum.app` is still the published 1.4 (build 12299). No A1 copy
  was taken or pruned this window.
- **Her iPhone:** now runs main's build with the brand icon (VM-46, installed in place 2026-11-15 22:17; VM-45's
  marker-15 update before it at 14:43). It opened, unlocked and synced. She noticed the first "Syncing…" ran for
  about a minute, which is filed with the mobile performance work.
- **Phone safety copies, yours to keep or prune** (neither opened; each holds the store and its key file):
  - `~/.variorum/phone-safety-copies/2026-11-15T214238Z/` — 279 MB, before VM-45
  - `~/.variorum/phone-safety-copies/2026-11-16T051657Z/` — 280 MB, before VM-46
- **VX-997 (PR #8) is waiting on your word.** The coordinator trial you asked for (R-997-12) ran in full and
  passed. My suggestions were taken onto the branch. Details below.
- **Leftovers kept on purpose by their sessions:** `~/dev/variorum-vm-44` (VM-44 continues in a fresh session;
  local-only screenshots), DerivedData `vm46-device` (symbols for the phone's build), `~/.variorum/vm-44-traces/`
  (12 MB), and the planning folders `~/dev/variorum-mobile-catchup` and `~/dev/variorum-mobile-catchup.local-archive`.
- **Old branches, safe to delete at your word:** `vx-993-brand-logo-reland` and `vx-995-cutover-notes`, local and
  on origin. Both are fully merged into main (PRs #1, #2) and predate this window.
- **Disk:** 42 GiB free at close, down from 78 GiB at open. Mostly other sessions' builds; nothing was owed by
  efforts closed under me.
- **Tickets born by the coordinator:** none.

## What ran on the stage

| When | Claim | What | Result |
|---|---|---|---|
| 11-12 13:38–14:30 | `mobilecatchup-capture` | Simulator capture walk on a dedicated sim (iOS 27.0) | 112 + 16 screenshots, 4 recordings; sim later deleted |
| 11-12 17:16–17:46 | `mobilecatchup-device` | VM-45 phone install | Expired unused: the session was in a dialog with her and the app was open on the phone. Nothing reached the phone |
| 11-15 14:41–14:43 | `mobilecatchup-device` | VM-45 phone install | Safety copy, then installed in place; marker 15; syncing |
| 11-15 19:29–19:52 | `mobilecatchup-device` | VM-46 install + Mac suite | Released unused: Variorum open on the phone |
| 11-15 20:45–21:14 | `mobilecatchup-device` | VM-46 install + Mac suite | `PaletteDerivationTests` 16/16 passed on beb638033; install skipped (app open on the phone again) |
| 11-15 22:16–22:17 | `mobilecatchup-device` | VM-46 install only | Safety copy, then installed in place; brand icon confirmed |
| 11-15 22:35–22:45 | `mobilecatchup-trace` | Lag trace via xctrace | 0 flows: she chose to build timing into the app instead; one 5-second attach test |
| 11-16 05:40–05:50 | `vx-997` | Ambient app live look | Keys, pane, pixel size, Esc all good; CPU 4–10% of one core per scene (under load) |

Every other minute of the window was the coordinator's own idle hold.

## The VX-997 coordinator trial (R-997-12)

Run from `~/dev/variorum-vx-997`, first on the repo-built road (11-16 03:45), then again on the installed-app road
(05:40). All four steps passed:

1. The thin `Tools/ambient` door: status, help, and the missing-home cases print the right line and exit code.
2. Real on/next/off under the idle hold. On the installed road `on` is instant (`bundle=installed`) and `off` takes
   about 200 ms.
3. The stage hook in a throwaway home with a stand-in: a `HOLD:` claim leaves it up and any other claim stops it
   before returning, in both locales.
4. The real hook at a live bridge claim: Ambient was gone the moment the claim returned. The log read
   `OFF signal TERM`, the hook's stop rather than the app's own poll.

Suggestions sent and taken onto the branch: keep both process names in the pre-GO check through the changeover;
name the first-start build (since removed by running the installed app); say "same name and rules" for the icon's
show; and record that a touch no longer ends the show (only Esc or ⌘Tab), so its absence no longer means she sat
down.

## Calls I made

- Gave the mobile capture its own new simulator rather than the standing phone-suite device, so suite runs stay
  clean.
- Adapted the `/Applications` install card for her phone: a verified safety copy first (store plus key file), never
  uninstall, any signing message a stop, she launches the app herself. After her "I switched accounts" I added a
  gate: no rebuild, and the build's team must equal the installed app's.
- Held the stage for the mobile session after its claim expired mid-dialog, then dropped to the plain idle hold once
  it was clear nothing had reached the phone.
- Left fragments' own simulator runs alone (outside this repo's stage) and noted their load beside the CPU numbers.
- Closed two Problem Reporter windows left by other processes (fragments' test crash, macOS PosterBoard).

## What went wrong

- **Claims lapsed in dialogs.** Twice a session's claim sat idle or expired while it waited on a question to her.
  Its later fix, renew or release before any dialog, held for the rest of the window.
- **My own hold lapsed twice overnight** (11-13 05:11, 11-14 04:26). The sleep-loop watchers stall while the Mac
  sleeps. Nothing was queued, so nothing was lost. I moved the renew point to an hour before expiry.
- **A wrong guess.** I suggested iOS was relaunching the app in the background. The app declares no background
  modes, so it had simply been reopened. Withdrawn.
- **The window outlived its work.** Both sessions finished on 11-16; I held and renewed for two more days waiting on
  a word about closing before taking the skill's own closing condition (every session silent).

## Process notes

- `cliclick kp:esc` is not seen as Esc by the Ambient app; a raw key code 53 works. It belongs beside the walk
  lessons' popover blind spot.
- About 20 `AmbientRender` crash reports (Swift traps) landed 11-16 02:01–05:00 from VX-997's headless render work.
  They were passed to that session. The installed app never crashed.
- A shared memory repo with several sessions committing makes `git pull --rebase` print alarming lines when two
  commits race. Check `HEAD == origin/master` before assuming anything was lost.
