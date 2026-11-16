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
| 1 | `Tools/ambient` becomes a thin door to `$AMBIENT_HOME/bin/ambient` | DONE (this commit) — probed with a fake command under `en_US.UTF-8` and `C` |
| 2 | `Tools/stage`: the ambient hook stops `Ambient` (and a lingering `StageAmbient`) | NOT-STARTED |
| 3 | `Tools/StageAmbient/` removed | NOT-STARTED |
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
