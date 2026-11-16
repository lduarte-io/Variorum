# VX-997 — Ambient: the stage decoration becomes its own app (the Variorum side)

**Ticket:** VX-997 (umbrella; the Ambient app itself lives in its own repo, `~/dev/ambient`, whose
`notes/plan.md` is the effort's plan and running record — this batch is its row L7 and its §11.1 brief).
**Branch:** `vx-997-ambient-app` (worktree `~/dev/variorum-vx-997`), with the Ambient repo's branch `l7`.
**Cast:** one Opus implementer, headless only (no app launched, no real stage claimed). Not merged: per
R-997-12 the coordinator trials it from the worktree first and the merge is hers.

## FOR A LATER READER

**The mechanism as settled.** The stage ambient grew into Ambient, its own app in its own repo (R-997-1);
Variorum keeps only two touch points. `Tools/ambient` is a thin door: it execs
`${AMBIENT_HOME:-~/dev/ambient}/bin/ambient` with its arguments, and where that is missing prints one line
and exits 1 (`status` prints `OFF`, exit 0). `Tools/stage`'s hook (VX-459) had looked for the process
`StageAmbient` by name, so it never saw `Ambient` (Ambient's ladder finding F2): the show went only by its
own 0.25 s poll. The hook now stops exactly the process its own HOME's `~/.variorum/ambient.state` names
(`PID=`), and only while that process is named `Ambient` (or `StageAmbient`, for the changeover) in `pgrep
-x`'s sense — TERM, up to 3 s, then KILL — before a claim that is not `HOLD:` returns. Scoping it to the
state file's pid is what keeps a throwaway-HOME run (Ambient's tests, the coordinator's trial) from ever
ending the real show, which a by-name stop would; both guards stand (no state file ⇒ nothing; it always
returns 0). `Tools/StageAmbient/` is gone; the skill names `Ambient` and its new keys.

**The fix as built, one pointer per piece.** `Tools/ambient` (`94075193a`) · the `Tools/stage` hook
(`17f23dd2f`) · `Tools/StageAmbient/` removed (`979bd07bf`) · `.claude/skills/stage-coordinator/SKILL.md`,
the ambient lines only (`b506cc7fe`) · the other mentions, each left with a reason (`ff570f996`) · the
coordinator's trial, `vx-997-coordinator-trial.md` (`8cc063c84`) · in the Ambient repo, branch `l7`:
`Tests/Fixtures/stage` refreshed and the F2 probe in `StageClaimTests` (`d536e63`) · Ambient's README
line (piece 8): HELD, settled text in the working notes.

**Her rulings.** R-997-1 (its own repo; `Tools/ambient` stays as a thin command) · R-997-2 (only Esc ends
it; Space is the next scene; brightness and volume never end it; a stage claim still does) · R-997-8 (a
focus loss ending it is fine) · R-997-12 (the coordinator trials this before the merge; the merge is hers).

**Evidence.** `bash -n` on both scripts. The door, with a fake command, under `en_US.UTF-8` and `C`:
arguments and exit codes pass through; the missing case as specified. The hook, with stand-ins under a
throwaway HOME, both locales: 14 of 14; the old hook fails its four `Ambient` cases. Ambient
`swift test -c release` at `d536e63`: 355 tests in 39 suites green; with the old fixture the four stop
pins go red (6 issues) and the two guards stay green. The trial note's hook block, run verbatim through
zsh and bash: its four `ok` lines and the `after` line; against the old hook, `FAIL`.

**Open items.**
- The Ambient side, DONE on `l7` once its round-1 fixes merged (`c74c35b`), one commit each, 380 tests
  green in release: the fixture refresh to `96a2f2741` (`f9b443c`); M1 — stand-ins on a 30 s clock and
  `bin/ambient` finding the show by the state file's pid, with no state file only an `Ambient` running
  from an `Ambient.app` bundle (`d69d001`, `82c4fc5`; four pins red on the old road); M5's guard pin
  (`964c807`; red when the hook's order is flipped); P-997-4 in `bin/ambient`, with `which` and
  `bundle=` (`64ec82c`); the header's stop claim (`0245e3d`); piece 8, README naming this PR, #8
  (`c5458c7`).
- M7 — HELD FOR HER: the clone URL removed at `6bf14ca78` stays in the branch's earlier pushed commits;
  accept it, or rewrite the unmerged branch before the merge (author-only). Nothing about history changed.
- The coordinator's trial: steps 1–3 ran clean (Ambient's `notes/plan.md` §11.3); step 4, rewritten for M2,
  runs at the live look's GO. The merge is hers.
- The merge ORDER (L2-2, Ambient's `notes/plan.md` §11.5): Ambient's `l7` reaches Ambient's `main` and
  `~/dev/ambient` is pulled BEFORE this PR merges. `Tools/ambient` execs whatever `~/dev/ambient` holds,
  and the skill on this branch describes `l7`'s road (P-997-4's installed app, the state file's pid), not
  `main`'s old one (it builds the repo's bundle and finds the show by name). Then the coordinator re-runs
  the trial's steps 1, 2 and 4 from this worktree on that merged road, expecting `bundle=installed` in the
  RUNNING line and no build; then this PR merges.
- The merge-in, on the Pro, BEFORE `git pull` in `~/dev/variorum`: check no `StageAmbient` runs
  (`pgrep -x StageAmbient` prints nothing), then `rm -rf ~/dev/variorum/Tools/StageAmbient` (the old build
  folder, ~111 MB, holding `StageAmbient.app`). Why: the pull deletes the package's own `.gitignore`, so
  without it the folder turns untracked and un-ignored, `release.sh` refuses a dirty tree (it counts `git
  status --porcelain`, untracked files included), and a careless add would publish the old binaries; the
  root `.gitignore` line `Tools/StageAmbient/` (M3) is the belt for every other clone. Then refresh the
  coordinator's memory note on the ambient.
- The hook's TERM and focus — RULED app-side (Ambient's `notes/plan.md` §11.2) and BUILT as F2b on
  Ambient's `fix-1` at `5d7d562`: the show reads the stage as it leaves, and any exit while a claim stands
  (the hook's TERM included) leaves focus where it is. It depends on the hook sending TERM only after the
  claim is on disk, which `Tools/stage`'s comment now says (M5).
- The drift check (`notes/plan.md` L12) — RULED not built (§11.2): while this PR is open, Ambient's
  vendored `Tests/Fixtures/stage` and Variorum's `main` differ on purpose, so a check against `main` would
  be red for the wrong reason. The fixture is refreshed by hand whenever `Tools/stage` changes, and the
  hook's comment names that pin (M6).

## LIVE STATUS

| # | Piece | State |
|---|---|---|
| 1 | `Tools/ambient` becomes a thin door to `$AMBIENT_HOME/bin/ambient` | DONE `94075193a` — probed with a fake command under `en_US.UTF-8` and `C` |
| 2 | `Tools/stage`: the ambient hook stops `Ambient` (and a lingering `StageAmbient`) | DONE `17f23dd2f` — 14/14 fake cases under both locales; the old hook fails the 4 `Ambient` cases |
| 3 | `Tools/StageAmbient/` removed | DONE `979bd07bf` — 17 tracked files; this worktree had no untracked leftovers |
| 4 | The coordinator skill says what is true of Ambient | DONE `b506cc7fe` — the lines that name the ambient only (240 → 246 lines) |
| 5 | This record + `vx-997-coordinator-trial.md` (walked once with fakes) | DONE — the trial note `8cc063c84`; FOR A LATER READER (this commit) |
| 6 | Every other `StageAmbient` mention updated or left with a reason | DONE `ff570f996` — none needed a change; each left with its reason below |
| 7 | Ambient repo: `Tests/Fixtures/stage` refreshed + the F2 probe in `StageClaimTests` | DONE Ambient `l7` `d536e63` — 355 tests green in release; red on the old fixture |
| 8 | Ambient repo: `README.md` says the synchronous stop is real once this PR merges | DONE Ambient `l7` `c5458c7`, after its round-1 fixes merged (`c74c35b`); it names this PR, #8 |
| R1 | The cold review (Ambient's `notes/plan.md` §11.4), Variorum side | DONE — the URL out `6bf14ca78`; M2 `362591467`; M3 `aab6f3661`; M5 `f78023c21`; M6 `6ff8fe217`; N1 `96a2f2741` (hook probe re-run, 14/14 in both locales, a TERM-deaf show gone in 2.6–3.1 s); N2 `6c8cb56c8`; the skill's suggestions, M1's line and P-997-4 `3b499fcea`. The Ambient side waits (open items) |

## Working notes (the night's record)

- **Piece 1, the door.** `Tools/ambient` holds none of Ambient now: it execs
  `${AMBIENT_HOME:-$HOME/dev/ambient}/bin/ambient` with its arguments unchanged, so every subcommand and
  flag the coordinator types (`on --scene … --stay --min-idle … --allow-claimant …`, `off`, `status`,
  `next`, `list`, `log`, `build`, `help`) is the Ambient command's own, exit codes included. Where that
  command is missing it prints one `AMBIENT MISSING — …` line naming the path it looked at, that Ambient
  lives in its own repo at `~/dev/ambient`, and that `AMBIENT_HOME` can point elsewhere — never a clone
  URL, since this repo is public (ruled, Ambient's `notes/plan.md` §11.2) — and exits 1; `status` (and no argument, which means `status`) prints `OFF` and exits
  0. Probe, a fake `bin/ambient` that echoes its arguments, under both locales: five arguments including a
  space and an em dash arrive intact; the fake's exit 7 on `off` comes back as 7; missing → `OFF`/0 for
  `status` and for no argument, the one line/1 for `off`; an empty `AMBIENT_HOME` falls back to the
  default path.
- **Piece 2, the hook — and one decision taken in the build (reversible).** The old hook stopped the
  show BY NAME (`pgrep -x StageAmbient`, then `Tools/ambient off` or `pkill -x`), so its comment's
  promise — "it acts only on THIS home's ambient, so a throwaway-HOME run never touches the real one" —
  held only because no sandbox ever wrote a state file. The F2 probe must write one (a stand-in under a
  throwaway HOME), and a by-name stop would then end the REAL show if one were up — and Ambient's tests,
  running in parallel, would stop each other's stand-ins. So the new hook stops exactly the process its
  own HOME's state file names (`PID=`), and only while that process is named `Ambient` or `StageAmbient`
  in `pgrep -x`'s sense (a reused pid or another program is left alone): TERM, up to 3 s, then KILL, up
  to 2 s more — Ambient's own `off`, scoped to one pid. It no longer goes through `Tools/ambient off`:
  the door's `off` finds the show by name, and under a throwaway HOME with `AMBIENT_HOME` exported it
  would reach the real show. Both guards stand (no state file ⇒ nothing; it always returns 0, the
  claim's `STAGE CLAIMED`/`STAGE RENEWED` and exit 0 untouched). Under the real HOME this is the same
  stop as before, since both of Ambient's doors write the state file only while up, naming themselves.
- **Piece 2's probe** (a throwaway shell instrument, not kept — the durable pin is piece 7's
  `StageClaimTests` in the Ambient repo; the coordinator's trial note carries its core). A throwaway HOME
  per case, `env -i` with `PATH=/usr/bin:/bin`; the stand-ins are ad-hoc-signed copies of `/bin/sleep`
  named `Ambient`, `StageAmbient` and `Bystander`, and a copy of `/bin/bash` named `Ambient` that ignores
  TERM (a copied system binary is killed at exec until re-signed). Fourteen checks, `en_US.UTF-8` and `C`
  both 14/14:
  a non-HOLD claim with an em dash in its reason stops the named show before returning (`STAGE
  CLAIMED`, exit 0); `HOLD:` leaves it; the holder's re-claim to `HOLD FOR …` stops it (`STAGE
  RENEWED`, exit 0); of two shows named `Ambient` only the one this HOME names stops; a state file
  naming another program, a garbage pid or a dead pid stops nothing and the claim exits 0; no state
  file stops nothing; a lingering `StageAmbient` stops; a TERM-deaf show is KILLed and gone before the
  claim returns (4.5 s under a load average near 60), exit 0. The OLD hook, same probe: the four
  `Ambient` cases (a, c, d's named show, h) stay up — red on old. Machine left clean (no `Ambient`, no
  `StageAmbient`).
- **Piece 3, the package retired** (R-997-1: Variorum keeps only the thin command). `git rm -r
  Tools/StageAmbient` — the 17 tracked files (the package, its README, the koi, the claim reader and its
  tests); all of it lives on, grown, in the Ambient repo (seeded from Variorum `5dde1bcf9`). The record
  `vx-458-stage-ambient.md` stays as history. Left on disk by the pull: the main clone's
  `Tools/StageAmbient/.build/` (111 MB on 2026-11-16, holding the old `StageAmbient.app`), no longer
  ignored once the package's own `.gitignore` goes (the cold review's M3) — so a root `.gitignore` line
  now covers it, and the merge-in removes it before the pull (open items).
- **Piece 4, the coordinator skill.** Only the lines that name the ambient changed: the pre-GO check is
  `pgrep -x Ambient`; the section (now "Ambient, the stage ambient") says `Tools/ambient` is a thin door
  to `~/dev/ambient/bin/ambient` (or `$AMBIENT_HOME`) and points at that repo's README instead of the
  retired one; seventeen scenes, black and white and colour; it no longer goes at her touch — of her keys
  only Esc ends it, Space is the next scene, `⌘,` the settings pane, brightness, volume, the mouse and
  every other key leave it up (R-997-2); it still goes by itself on any non-`HOLD:` claim and when
  another app takes the keyboard (R-997-8); she may open it from its icon, the same process; `on` still
  refuses while she is at the Mac. The `HOLD:` / `HOLD FOR` lines, the RELEASE and closing lines keep
  their sense, with "the stage ambient" read as "Ambient".
- **Piece 6, every other mention** (`git grep -i` for `StageAmbient`, `stage ambient` and `Tools/ambient`
  over the tracked tree; the many other `ambient` hits are the app's dependency vocabulary — "the ambient
  database" — and unrelated). Left, each with its reason:
  - `notes/DetailedPlanForPhases.md` — this effort's own in-flight row, which says `Tools/StageAmbient/`
    retires: true, and a shared ledger touched only at the merge moment by the merging session.
  - `notes/TICKETS.md` — generated by `Tools/vx sync`, never hand-edited (VX-460's and VX-531's titles).
  - `notes/plans/fixes/vx-458-stage-ambient.md` — the history of the first build; it stays as written
    (§11.1, piece 3).
  - `notes/plans/fixes/vx-912-open-source-gating.md` — a dated row of the open-source sweep's ledger
    (`Tools/ambient` + `Tools/StageAmbient/`: ship as-is); a record of that sweep, not a contract.
  - `notes/plans/fixes/vx-510-first-run-sync.md` — names `Tools/ambient on --allow-claimant vx-510`, which
    still works word for word through the door (`bin/ambient on` takes `--allow-claimant`).
  - Outside this repo (not touched by a build session): the shared memory's
    `coordinator-ambient-scenes.md` — the note the coordinator reads before coordinating — still points
    at `Tools/StageAmbient/`; the orchestrator's to refresh at the merge.
- **Piece 5, the trial note** (`vx-997-coordinator-trial.md`): four steps from the worktree — the door
  (nothing real moves), on/next/off for real under the coordinator's own `HOLD:`, the hook under a
  throwaway HOME with a fake `Ambient` in both locales (one pasteable bash block), and optionally the real
  hook at the coordinator's next natural bridge claim — then what to report, and the two merge-moment
  chores (no `StageAmbient` up; the old `.build/` and the memory note). **Walked once by the implementer,
  with fakes:** step 1 as written — `status` → `OFF` exit 0 through the real door to `~/dev/ambient`;
  `help` → Ambient's usage, exit 2; a missing command → the one line, exit 1, and `OFF` exit 0 for
  `status`. Step 2 against a fake command (the real `on` is the coordinator's): `on`, `next`, `off` arrive
  as given. Step 3 extracted verbatim from the note and run through `zsh -f` and through `bash`: exactly
  the five lines, four `ok` (both locales: `HOLD:` leaves the fake up; a walk's claim stops it before
  returning, exit 0) and `after: pgrep -x Ambient -> []`, no trial directory left. The same block pointed
  at the old hook prints `FAIL a walk's claim left it up` in both locales. Step 4 not walked (it is the
  real stage). The first walk printed a bash `Terminated: 15` job notice per fake; the fake now starts
  from a command substitution, so it is no job of that shell and the block prints only its five lines.
- **The Ambient side: the gate.** §11.1 builds pieces 7–8 after `git merge origin/main` "so the round-1
  fixes are underneath". At the time (twice checked, `git log origin/main --oneline | grep -c F1` → 0;
  Ambient `main` at `83a6506`) they were not: they sit on Ambient's `fix-1` branch, unmerged, still
  without its F1 commit. `fix-1` touches neither `Tests/Fixtures/stage` nor `StageClaimTests.swift`, so
  piece 7 was built on `83a6506` and will merge clean; piece 8 edits README sentences `fix-1` rewrites
  (rail 2's F2 sentence, the doors section), so it is held rather than written onto text about to change.
- **Piece 7, the fixture and the probe** (Ambient `l7`, `d536e63`). `Tests/Fixtures/stage` is
  byte-identical to this branch's `Tools/stage` (`cmp`), the suite's comment naming `17f23dd2f`. Seven new
  `StageClaimTests` functions, each under a throwaway HOME with a stand-in started from the test (an
  ad-hoc-signed copy of `/bin/sleep` named `Ambient`, `StageAmbient` or `Bystander`; a copy of `/bin/bash`
  named `Ambient` that ignores TERM), liveness read as `pgrep -x` reads it: a claim that is not `HOLD:`
  stops the show before it returns (both locales); `HOLD:` leaves it and the holder's re-claim to `HOLD
  FOR …` stops it (both locales); only the show its own HOME names is stopped; a state file naming another
  program leaves it; no state file leaves it; a lingering `StageAmbient` is stopped; a TERM-deaf show is
  KILLed and the claim still exits 0. **Evidence:** `swift test -c release` — 355 tests in 39 suites
  passed (348 before, plus these 7). **Red on old:** with `Tests/Fixtures/stage` swapped to the
  `5dde1bcf9` copy (from Ambient `main`; the committed `d536e63` the restore point), the four stop pins
  fail at their `!isUp` expectations — 6 issues across the locale cases — while the two guard pins (no
  state file; another program) pass on both sides, as guards should; restored by `git checkout`, `cmp`
  identical, the three stage suites green again (25 tests). No stand-in left running.
- **Piece 8's settled text, for when `fix-1` is on Ambient's `main`** (a successor merges `origin/main`
  into `l7` and applies it; `#N` is this branch's Variorum PR, opened by the orchestrator):
  - Rail 2, replacing `fix-1`'s "Today that poll is all that takes the show down … come with the
    Variorum-side change (`notes/plan.md`, L7)." with: "Once Variorum's PR #N (`VX-997`, branch
    `vx-997-ambient-app`) merges, `Tools/stage claim` also stops the show before it returns, for any
    reason that isn't `HOLD:`, however it was opened: its hook stops the process `~/.variorum/ambient.state`
    names while that process is named `Ambient` (VX-459, VX-997), and the coordinator's checks look for
    `Ambient`. Until then the poll is all that takes the show down." (The focus sentence after it stays.)
  - The doors section: "Variorum's `Tools/stage` hook and the coordinator's checks do not see either door's
    show yet (rail 2)." → "Once Variorum's PR #N merges, its `Tools/stage` hook stops either door's show and
    the coordinator's checks see it (rail 2)."; and "(Variorum's `Tools/ambient` becomes a thin exec of it,
    a later Variorum-side batch)" → "(Variorum's `Tools/ambient` is a thin exec of it once PR #N merges)".
