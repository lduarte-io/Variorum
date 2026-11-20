# Coordinator handoff — 2026-11-19 → 11-20 (nov18)

The Pro's stage coordinator for the overnight window you set up on 2026-11-19: wave 1 of the mobile catch-up
(VM-47, VM-55, VM-64, VM-78) and two Mac runs (VX-980 search, VX-981 the MCP door). All six runs merged and
closed. One run is still open under me: VM-24, launched at your standing word once the four mobile runs had
merged, with VM-243 riding it. This file is written at 04:00 on 11-20 so it is on main when you start from the
handoffs; its last section is filled in when the VM-24 run ends.

**How to read this file:** a **claim** is one turn on the shared screen, simulator or dev store. A **gate** is the
last test run before a merge: the whole phone target, the whole Mac target, and a walk. **Baseline** is what
already fails on main. A **walk** is a session that drives the app and photographs it.

## Your checklist

1. **The 1.5 Mac release is NOT built. It needs you first (VX-1028).** VX-981 was to build it unpublished. The
   release script stopped at its own first check: Apple's notary service answered "A required agreement is missing
   or has expired" (HTTP 403). Nothing was archived, signed or written. Sign the current agreement on Apple's
   developer site, then follow the five steps in `notes/handoffs/vx-981-handoff.md`. Your word that night: you will
   take care of it later. Two things to know before you build:
   - The first-run check passed on main at `ad5053002`. Main has since gained all four mobile runs, so that check
     is owed again on the tip you build from. The handoff has the one-line way to tell.
   - The label 1.5 and `ReleaseNotes-1.5.md` are on main as PROVISIONAL. They are yours to confirm or change
     before anything is published. `/Applications/Variorum.app` is untouched: the published 1.4 (build 12299).
2. **The one wave-1 phone install, this morning.** The build is made and waiting; nothing was installed and no
   device was touched. Follow "This morning: the one phone install for wave 1" at the top of
   `notes/handoffs/vm-47-handoff.md`. A fresh session can drive it with you; it asks the coordinator for the
   stage first.
   - The app: `~/Library/Developer/Xcode/DerivedData/vm47-wave1-device/Build/Products/Release-iphoneos/VariorumMobile.app`,
     built from main's final wave-1 merge commit `226edf626`. I checked its signature twice.
   - **Install THAT app. Do not rebuild main for the install.** VM-24's "before" count must be taken on wave 1 as
     it stands; a fresh build of main could carry VM-24's fix.
   - It is an in-place install: safety copy first, the app quit, never an uninstall. One local migration runs on
     first open (VM-64's `v1_38`); treat it as one-way, with the safety copy as the way back.
3. **One phone sitting serves two measurements.**
   - VM-64's timing readout: Settings ▸ Diagnostics ▸ Timing…, then Copy. Its handoff lists what to do a few times
     each (`notes/handoffs/vm-64-handoff.md`, "The phone sitting").
   - VM-24's "before" count: Settings ▸ Diagnostics ▸ Record edit trace. The VM-24 session read the wave-1 build
     and found its trace is enough. Its script for you is `notes/handoffs/vm-24-morning-phone-session.md` on the
     branch `vm-24-unwarned-edit-routing` (worktree `~/dev/variorum-vm-24`).
   - While you are there: VM-64's five-second check that a quick tap on the takes button opens the takes sheet,
     and the two screens no capture saw (the Account sheet; the readout behind its door).
4. **Confirm or overturn my gate calls.** I ruled provisionally while you were away, as you asked.
   - **VM-64's gate (the one to look at).** Its last whole-Mac run had two failures, both ticketed flaky tests on
     main, both green when run alone: VX-701 (the find board's esc test) and VX-953 (the spelling door's write
     arm). VX-953's ticket says "flaky under load, one sighting each". This was a second sighting, and the machine
     was not under load (2.4 to 3.5). I passed the gate; the ticket has the new sighting.
   - VX-981's, VM-55's, VM-78's and VM-47's gates each had VX-701 as their only Mac failure outside their own
     work, green alone.
   - The 1.5 label riding VX-981's merge as PROVISIONAL (item 1).
5. **Each run's decisions for you are bundled in `notes/QUESTIONS.md`:** #276 VX-980 · #277 VM-55 · #278 VX-981 ·
   #279 VM-78 · #280 VM-64 · #281 VM-47 (forty-one provisional calls). Each handoff leads with the ones that matter
   most. Three I would read first:
   - VM-64: a key typed while a divide, merge or extract is landing is now refused, with a line saying so.
   - VM-47: the eight questions its walks raised, and the screens folder it kept for your sitting
     (`notes/plans/vm-47-screens/` in the main checkout, 136 MB, ignored by git; "delete the screens" removes it).
   - VX-980: VX-1013, the first Debug launch of a night can sit blank for about nine minutes while it walks the
     backup folder. I recommended High; its priority is unchanged without your word.
6. **Two follow-up runs. One is running, one is yours to start.**
   - **VM-24 + VM-243 is running** (tmux session `variorum`, window `vm-24`). You added VM-243, the faint text
     after a dash, as a rider at 02:17. It holds its questions for you.
   - **VM-17 + VM-239 + VM-179 (fan badges and decor placement) is yours to launch**:
     `/architect-phase vm-17 vm-239 vm-179`, kickoff `notes/plans/vm-17-chrome-geometry.md`. You took the unproven
     fan-badge fix out of VM-78 and made it this run.
7. **Left alone at your word:** PR #8 (VX-997, the Ambient app) is still a draft; no Fragments work ran; the five
   parked mobile questions wait for wave 2.

## What merged

| # | Run | PR | Merge commit | Handoff |
|---|---|---|---|---|
| 1 | VX-980 — search fixes | #11 (+ #12, a record correction) | `ed4d87cb7` | `vx-980-handoff.md` |
| 2 | VM-55 — wings underneath | #13 | `66337ff08` | `vm-55-handoff.md` |
| 3 | VX-981 — MCP door follow-ups, with VX-1007 | #14 | `7629cf049` | `vx-981-handoff.md` |
| 4 | VM-78 — fixes to what's there | #15 | `f909d6714` | `vm-78-handoff.md` |
| 5 | VM-64 — timing and the two lags | #16 | `982405967` | `vm-64-handoff.md` |
| 6 | VM-47 — sizes and look | #17 | `226edf626` | `vm-47-handoff.md` |

Every merge is a merge commit whose tree I compared with the tree its gate tested; each on-main ledger commit is
notes only. Main at this writing: `8fb172e6e`. The wave's one Sync/-custody slot was VM-64's; it wrote no line
under `Sync/`, `Server/` or custody code and released the slot at its close. Its merge carries the local-only
migration `v1_38`.

VX-1007 (your daily Journal not showing as Private) is fixed on the Mac and was walked by sight: the Journal and
each entry wear the Private eye, and the Journal's Private row is ticked and locked with a line saying why.

**Baselines on main after wave 1.** Whole phone target: 1,194 tests in 209 suites, ONE failing test, VM-24's
caret test (two of its three cases), and 13 skipped (VM-64's speed suite runs only alone, with
`TEST_RUNNER_VM66_PERF=1`). Whole Mac target: 6,435 tests in 1,114 suites, none failing, 13 declared known
issues, and two flaky names (VX-701, VX-953).

## The stage, in numbers

From `~/.variorum/stage.log`, 2026-11-19 03:02 to 2026-11-20 03:33: about 20.4 hours of work claims in a 24.5 hour
span, 84 hand-overs of about twenty seconds each, and 165 minutes with nobody ready.

| Run | Claims | Minutes held |
|---|---|---|
| VM-47 | 25 | 444 |
| VM-64 | 21 | 266 |
| VM-78 | 13 | 142 |
| VM-55 | 10 | 141 |
| VX-981 | 9 | 136 |
| VX-980 | 5 | 94 |

The stage sat idle for 40 minutes once, 11:10 to 11:50 on 11-19, when the usage limit stopped every session
just after I had taken the stage for VM-55's walk.

## Calls I made

- **Merge order:** VX-980, VM-55, VX-981, then VM-78 and VM-64 by whichever was ready first, VM-47 last. VM-47
  conflicted with both of the others, and VM-78's review had found that a wrong resolution compiles and passes
  while showing three old phone faces. VM-78 wrote guard tests; they reached main before VM-47 had to merge.
- **A merge that touches `Sources/VariorumCore` or `App/Variorum/Shared` owes both a phone and a Mac run**, not
  only a Shared change. I made this rule after missing it on VX-980 (below).
- **Walk first, then the whole-target runs; every review round closed before the gate.** A walk is the step most
  likely to earn a code fix. This paid for itself on VM-47, whose walks found fourteen defects of its own before
  its gate, one of them a regression its own fix had caused (below).
- **A quiet machine for every whole-Mac run.** I asked the other sessions to hold cold builds and whole-package
  runs while one ran, and told them when it ended.
- **Short windows ahead of long ones** where the short one unblocked a review round that needed no stage.
- **VM-64 offered to merge last after its wording failure; I kept the order** and used its rebuild time for
  VM-47's work, so the stage did not idle.
- **A ten-minute retry before two hours of runs.** VM-64's walk reported the takes door "did not open under my
  taps". The retry showed it was the driver's 70 ms tap, not the app.
- **One failure in a whole run does not always mean the whole run again.** A change confined to one test file or
  one phone screen re-ran its own suites; a change to shared code would have re-run the target.

## What went wrong

- **My miss: VX-980 merged without a phone run.** Its diff had no Shared file, so I cleared it; it had changed
  six Core files the phone compiles. It ran the phone suites after the merge (128 tests in 13 suites, green) and
  corrected its record in PR #12.
- **The 1.5 release was not built** (checklist item 1).
- **Tests that read source files by path caught three runs late.** The Mac target has tests that read the phone's
  and Shared's source. VM-64's timing labels said "Savepoint" where your ruling is "commit"; only the whole Mac
  run included that check, so its gate failed once and cost a second whole-Mac run. VM-47 hit two more of the
  class (a moved file; a button style's literal text). VM-47 counted 133 such test files; VM-64's handoff lists
  the ones a phone run should run at its first batch.
- **VM-47's edge fix broke typing, and its own walk caught it.** Making backgrounds reach the screen's edges
  stopped the note scrolling a tapped line above the keyboard: a typed letter landed out of sight. It redid the
  fix, added a test that fails on the first fix and passes on the redo, and re-shot the screens.
- **A timing mark that outlives its screen.** VM-64's code marks "note painted" one frame late, and nothing
  cancels the mark when a test ends. In VM-47's larger target it landed inside a VM-64 test and failed it once.
  VM-47 reproduced it on purpose and made the test wait; the product code is unchanged, and VM-241 has a note.
- **Smaller things:** a test of VM-47's reached the live database default and left a stray store on the standing
  simulator (removed the same afternoon); VM-64's first fence window trapped the test host six times; one
  session's implementer wrapped builds in a watchdog that killed by a pattern matching every worktree's phone
  build (it never fired; builds are now stopped by process ID only); several test lists named files where types
  are required (caught before they ran); my own early log stamps ran two minutes fast.

## Process notes

- **Read the log, not only the result line.** I read each gate's log myself before passing it. Twice that gave a
  session a half-hour head start on a failure still in flight.
- **A short tap can lie on the simulator.** A 70 ms synthetic tap leaves some buttons drawn pressed and never
  fires them; 180 ms works. VM-64's handoff asks you for a five-second check on the real phone.
- **`Timing` beside the dev store is not a stray store.** After VM-64, the app writes its readout's data into a
  `Timing` folder in Application Support. The standing simulator's test-host container should still list
  `Variorum-dev` only.
- **Sizes that held all night:** a whole phone target is about 13 minutes of stage, a whole Mac target about 53.
- **The Spotlight exclusion helped.** After you excluded `~/dev` and `~/Library/Developer`, load stayed low
  except for short bursts of the system's own background work.

## Tickets born this window

- By me, at your word: **VM-228** ("New Block Below" refused on an empty last line) and **VM-243** (faint text
  after a dash), both under VM-137; VM-243 now rides the VM-24 run.
- By the runs, as they reported them to me (each handoff has its own full list): VX-1009, 1010, 1013–1017
  (VX-980) · VM-229, 230, 231, 238 and VX-1021–1024 (VM-55) · VX-1028 (VX-981) · VM-239, 244, 245, 246 and
  VX-1029, 1030 (VM-78) · VM-226, 227, 232–237, 240–242 (VM-64) · VM-247, 248, 249 (VM-47).

## Cleanup

Every closed run removed its own worktrees, branches, build folders and simulator devices, and I checked each
one. Nothing of the six runs remains but what is kept on purpose: the wave-1 phone build (checklist item 2) and
VM-47's screens folder (item 5). Disk: 155 GiB free at 04:00, up from 71 GiB when the window opened. No install
ran, so no safety copy of your real store was taken or pruned. Still to do at my close: sweep this window's
leftover test-result folders under `~/Library/Developer/Xcode/DerivedData/`, keeping `vm47-wave1-device`.

## Still open: the VM-24 run

Launched 2026-11-20 03:42. I remain its stage coordinator. This section is completed when it ends.
