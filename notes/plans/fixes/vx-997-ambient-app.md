# VX-997 — Ambient: the stage decoration becomes its own app (the Variorum side)

**Ticket:** VX-997 (umbrella; the Ambient app itself lives in its own repo, `~/dev/ambient`, whose
`notes/plan.md` is the effort's plan and running record — this batch is its row L7 and its §11.1 brief).
**Branch:** `vx-997-ambient-app` (worktree `~/dev/variorum-vx-997`), with the Ambient repo's branch `l7`.
**Cast:** one Opus implementer, headless only (no app launched, no real stage claimed). Not merged: per
R-997-12 the coordinator trials it from the worktree first and the merge is hers.

FOR A LATER READER: written last (PENDING).

## LIVE STATUS

| # | Piece | State |
|---|---|---|
| 1 | `Tools/ambient` becomes a thin door to `$AMBIENT_HOME/bin/ambient` | DONE `94075193a` — probed with a fake command under `en_US.UTF-8` and `C` |
| 2 | `Tools/stage`: the ambient hook stops `Ambient` (and a lingering `StageAmbient`) | DONE (this commit) — 14/14 fake cases under both locales; the old hook fails the 4 `Ambient` cases |
| 3 | `Tools/StageAmbient/` removed | DONE (this commit) — 17 tracked files; this worktree had no untracked leftovers |
| 4 | The coordinator skill says what is true of Ambient | NOT-STARTED |
| 5 | This record + `vx-997-coordinator-trial.md` (walked once with fakes) | IN-PROGRESS — this LIVE STATUS from the first commit; the trial note and FOR A LATER READER owed |
| 6 | Every other `StageAmbient` mention updated or left with a reason | NOT-STARTED |
| 7 | Ambient repo: `Tests/Fixtures/stage` refreshed + the F2 probe in `StageClaimTests` | NOT-STARTED |
| 8 | Ambient repo: `README.md` says the synchronous stop is real once this PR merges | NOT-STARTED |

## Working notes (the night's record)

- **Piece 1, the door.** `Tools/ambient` holds none of Ambient now: it execs
  `${AMBIENT_HOME:-$HOME/dev/ambient}/bin/ambient` with its arguments unchanged, so every subcommand and
  flag the coordinator types (`on --scene … --stay --min-idle … --allow-claimant …`, `off`, `status`,
  `next`, `list`, `log`, `build`, `help`) is the Ambient command's own, exit codes included. Where that
  command is missing it prints one `AMBIENT MISSING — …` line naming the path it looked at and the clone
  that provides it, and exits 1; `status` (and no argument, which means `status`) prints `OFF` and exits
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
  `vx-458-stage-ambient.md` stays as history. Left on disk after the merge, untracked: the main clone's
  gitignored `Tools/StageAmbient/.build/` (111 MB on 2026-11-16, holding the old `StageAmbient.app`) —
  removed by hand once no `StageAmbient` runs (open items).
