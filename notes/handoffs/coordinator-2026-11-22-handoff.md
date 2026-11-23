# Coordinator handoff — 2026-11-22 (session `nov22`, the Pro)

The window ran from 14:02 on 2026-11-22 to about 02:10 on 2026-11-23. Two sessions used the stage: a Fragments
session (not Variorum; an iOS simulator and her phone) and VX-1035, the second Ambient effort. No Variorum build
effort asked for the stage, and nothing merged through the queue.

Her words at kickoff: "I will name you nov22, sessions will announce themselves to you. I'll have a range of
different efforts - including fragments, which isn't variorum, but does run an ios simulator. what should I tell that
session? when does fragments need to reach out to you for a stage? I know that it led to heavy system load and some
tests failing at different points previously."

## Your checklist

1. **Your real store and `/Applications`: untouched.** `/Applications/Variorum.app` is 1.4 (12299), the published
   release; `codesign --verify --deep --strict` passes. No install ran, so no A1 safety copy was taken or pruned.
2. **The answer to your load question** is the section "The simulator load" below. In one line: a booted iOS 27.0
   simulator by itself put the Pro at a load of 60–100, because one of the simulator's own system daemons crashes
   in a loop; with that daemon disabled inside the device and a five-minute wait after boot, the Fragments suite
   ran in 13 minutes at a load of 3–4 where it used to take 45–50.
3. **Held for your hands:**
   - **`watchman`.** The Homebrew `watchman` on the Pro dies at every launch ("Library not loaded:
     libfmt.11.dylib"; Homebrew's `fmt` is now 12.1.0) and its launch agent keeps restarting it. It wrote a crash
     report about every 45 seconds for most of the day and slowed after 22:00. `brew reinstall watchman` should
     end it. Not touched.
   - **A ticket for the simulator finding**, if you want one: Variorum's phone suites run on an iOS 26.2 device,
     which I did not test, but the two steps would apply the day they move to iOS 27. Not filed.
   - **The skill lines proposed at the end of this file.** Not landed; they change how the next coordinator
     works, so they wait for your word.
   - **PR #8 (VX-997)** is still held at your word. Its branch gained one commit during the window.
4. **Outside Variorum, for your record:** Fragments was upgraded in place on your phone at 15:35, at your word to
   that session; its version string did not change. `/Applications/Ambient.app` is build 525 after five installs
   by VX-1035 (372, 476, 485, 493, 525), each signed and verified.
5. **Tickets born:** none by me. VX-1035's session names VX-1042 (Low, open) and says it will file two more Low
   tickets of its own.
6. **Leftovers, none of them mine to clean:** worktrees `~/dev/variorum-vm-44`, `-vx-1033` (the open sitting),
   `-vx-1036` (new, design sittings) and `-vx-997` (held). No effort closed under this window inside the Variorum
   repo. VX-1035 closed in its own repo and removed its build folders; I checked that. Free space went from 165 to
   148 GiB. About 235 crash reports were written during the window, nearly all simulator daemons and `watchman`;
   each one feeds macOS's symbol cache (VX-1011), so that file is the first suspect if space keeps falling.

## Merges

None. Main moved three times outside the queue, each a docs-only commit to the in-flight table (VX-1036 opened,
VX-1035 opened and retired); nothing outside `notes/` changed, so no broadcast was sent.

## Stage numbers and timeline

From `~/.variorum/stage.log`. Twenty grants, each handed over through a bridge claim; the stage read free for 548
seconds in all between a release and the next claim, 48 seconds at most. The coordinator's idle hold covered about
5 h 14 min.

| Session | Windows | Minutes held |
|---|---|---|
| Fragments | 16 | 346 |
| VX-1035 | 4 | 19 |

| From | To | Min | Who | What |
|---|---|---|---|---|
| 15:34 | 15:35 | 0.4 | fragments | phone: store snapshot, upgrade install |
| 16:31 | 16:42 | 10.6 | vx-1035 | first live look of the Ambient app, install |
| 16:43 | 17:24 | 41.2 | fragments | unit suites and UI probes (extended once) |
| 17:31 | 17:36 | 5.1 | fragments | the daemon diagnostic |
| 17:57 | 18:29 | 31.2 | fragments | unit suites and UI tests, first run after the fix |
| 18:29 | 18:32 | 2.6 | vx-1035 | second look, install |
| 18:32 | 18:33 | 0.7 | fragments | released unused (a hand-off race on its side) |
| 18:34 | 18:56 | 21.4 | fragments | the same block, second GO |
| 18:58 | 19:18 | 19.2 | fragments | full suite, no seam |
| 19:19 | 19:21 | 2.6 | vx-1035 | third look (clips), install |
| 19:33 | 19:55 | 22.5 | fragments | its reviewer's full suite, no seam (extended once) |
| 19:56 | 20:01 | 5.3 | fragments | its reviewer's probe block |
| 20:21 | 20:41 | 19.9 | fragments | fix pass, ending in a full suite |
| 21:23 | 21:27 | 3.2 | vx-1035 | last look, install |
| 22:03 | 22:52 | 48.9 | fragments | next batch: unit bundle, UI tests, red-on-old (extended twice) |
| 22:58 | 23:20 | 22.1 | fragments | run of record, quiet (extended once) |
| 23:25 | 23:38 | 12.9 | fragments | A/B diagnostic on a wall-clock test, quiet |
| 23:45 | 00:12 | 27.0 | fragments | its reviewer's full suite, quiet (extended once) |
| 00:13 | 00:37 | 24.7 | fragments | its reviewer's probe block |
| 01:19 | 02:02 | 43.4 | fragments | fix pass, ending in a full suite (extended once) |

One act ran without a claim, at my word: VX-1035's install at 17:25 (a build, a signature and a copy; no screen).

## The simulator load

What was measured, in order:

- **15:25, load 144.** No simulator was booted. This was VX-1035's fan-out of about nineteen headless build
  agents, at your word to that session. A separate cause from everything below.
- **16:58, load 100–115 with no compiler running anywhere.** It was 8 when Fragments booted its iOS 27.0
  simulator at 16:43. Thirty-six of the runnable processes belonged to the simulator runtime; two of its system
  daemons, `intelligencetasksd` and `AppIntentsLiveEntityService`, were writing crash reports whose parent is the
  simulator's own `launchd_sim`; macOS's crash reporter was using two full cores. One minute after the device
  shut down, the load read 2.8.
- **17:31, the diagnostic.** With the device booted and idle, no app running, the load went from 3.8 to 24 in
  about 80 seconds and `intelligencetasksd` kept trapping. Fragments disabled that one service inside its own
  device (`launchctl disable system/com.apple.intelligencetasksd`, then `bootout`); the load fell to about 5 and
  the reports stopped. The setting persists across that device's boots.
- **After the fix,** a boot still costs a burst (I read 60 for a minute at one boot), which settles in about five
  minutes. Fragments now waits those five minutes before starting tests. Its full suite then ran in 13 to 16
  minutes at a load of 2–4, six times over the evening (the suite grew by about seventy tests on the way).

Two more facts for any simulator window on this Mac:

- **"The test runner hung before establishing connection"**, zero tests executed, is the environment and it is
  intermittent: Fragments counted 4 in about 29 launches by 22:52 and one more after. The launch right after a hang
  fails with "No such process" until the device has had one fresh boot. A zero-executed run is a retry, not a
  verdict.
- **macOS keeps only a limited number of crash reports per process name.** A count of files saturates near 25–30;
  count by time.

I did not test Variorum's iOS 26.2 device for either behaviour.

## Calls I made

- **Fragments stages like a Variorum session.** Every simulator boot or use, anything on the Mac's screen and
  anything to her phone needs a GO; headless builds do not. It claimed with Variorum's `Tools/stage` by absolute
  path and never touched this repo. I never read or touched its repo.
- **Whichever session can start first, starts.** With two requests waiting and neither ready, I told both that
  rule rather than fix an order; a no-seam run was never interrupted once started.
- **A no-screen install is not stage work.** VX-1035's install at 17:25 ran on a one-line word from me, without a
  claim, behind Fragments' release so its build did not sit beside timing probes.
- **Pauses instead of ordering headless work.** For five no-seam or "quiet" runs I asked VX-1035 to freeze its
  headless agents; it stopped them inside a minute each time and I resumed it at the release.
- **A hold on someone's behalf is spelled `HOLD FOR`.** Four times Fragments released with its next word still to
  come; I held the stage under that reason, with no decoration, until the line arrived.
- **A renewal pre-approved at T−5.** At 22:48 Fragments' claim was five minutes from lapsing mid-run and it had
  not asked; I sent the approval first. Its own request crossed mine.
- **The window closed on the skill's own condition:** VX-1035 sent its done line at 00:50, Fragments said at
  02:05 that it starts no further batch in that session.

## What went wrong

- **My first watcher reported the stage free when it was not.** It read the claim file in the instant between a
  bridge's release and the taker's claim (15:34). Every later watcher confirms "free" twice, three seconds apart.
- **An early reading I had to take back.** At 17:58, a minute into the first block after the fix, I told her the
  load read 13; three minutes later it read 66. The fix removed the loop, not the boot burst.
- **A word that arrived too late.** At 19:00 I asked VX-1035 to hold a rebuild during Fragments' full-suite run;
  it had already run one. It said so itself, and I passed the note to Fragments.
- **A crash-report count that understated the rate.** I told her `watchman` had written twelve reports that day;
  the per-name cap hid a rate of one every 45 seconds.
- **The stage sat free for 48 seconds at 16:42** while I identified a process named `Ambient` before bridging; it
  was a few-second test stand-in. Bridge first, then look.
- **The memory index.** A hook asked for it to be cut to 17.1 KB; I shortened the closed-effort lines to 18.4 KB
  and stopped, since the rest is her standing-rule lines.

## Process notes

- **A session's builder can wait on the claim itself.** Fragments' subagents loop on `Tools/stage status` and
  start when the claim's reason carries a word ("builder", "reviewer", "fix", "full"). It ended a hand-off race
  where a GO reached a subagent too late. The coordinator's part is to put the word in the reason.
- **The process sampler and Spotlight are loads nobody can pause.** `mediaanalysisd`, `corespotlightd` and a
  `sample` run each took half a core to a core at different pre-GO checks. Name them in a "quiet" GO.
- **`pgrep -fl "Problem Reporter"` matches a session's own shell line** that contains those words. Use
  `pgrep -lx "Problem Reporter"`.
- **After a window that raises Ambient's icon door under a claim,** look for its "stage is in use" alert before
  the next screen-driving GO. Build 485 and later bring it forward and close it after 20 seconds.
- **The koi raise can live inside the hold watcher:** one loop that renews the wake-up and runs `Tools/ambient on`
  once the Mac has been untouched for two minutes costs no extra turn.

### Skill lines proposed, not landed

For `.claude/skills/stage-coordinator/SKILL.md`, at her word:

- *A session outside Variorum (Fragments) stages like any other:* a GO for every simulator boot or use, anything
  on the screen, anything to her phone; headless builds free; its own simulator addressed by id; never a command
  that reaches every simulator; its device shut down before each release; claims by `~/dev/variorum/Tools/stage`
  run by absolute path. The coordinator never reads or cleans its repo.
- *An iOS 27.0 simulator on this Mac:* disable `intelligencetasksd` inside the device and wait five minutes after
  boot before any timing-sensitive run; read the load at the end of the wait and do not start in double figures.
- *A zero-executed simulator launch* is a retry after one fresh boot, and a no-seam window carries six to eight
  minutes for that recovery.
- *Watchers confirm "free" twice;* a bridge claim comes before any investigation.
- *"Quiet" means:* freeze the other sessions' headless work by message, get the confirmation, and name in the GO
  whatever cannot be paused.
