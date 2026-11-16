# VX-997 — the coordinator's trial, before the merge

Her word (R-997-12): "I want the coordinator to be able to use and test this skill before it's merged /
changed." This is that trial, run by the stage coordinator from the branch's worktree,
`~/dev/variorum-vx-997` (branch `vx-997-ambient-app`), while `~/dev/variorum` stays on `main`. The batch
and its evidence are `vx-997-ambient-app.md`.

**What it tries:** `Tools/ambient` as a thin door to Ambient's own command (`~/dev/ambient/bin/ambient`),
and `Tools/stage`'s hook stopping a show named `Ambient` before a claim that is not `HOLD:` returns.
**What it touches:** steps 1 and 3 touch nothing real (step 3 runs under a throwaway `HOME`, with a fake
`Ambient`, and leaves a real show alone even if one is up). Step 2 puts the real show up and takes it down,
under your own `HOLD:`, exactly as your road does every night. Step 4 is optional and is your own next
bridge claim, made with the worktree's `Tools/stage`.

**Before you start:** no old show is up — `pgrep -x StageAmbient` prints nothing. If one is, stop it with
main's door while main still has it: `~/dev/variorum/Tools/ambient off`.

## 1 · The door (nothing real moves)

```
~/dev/variorum-vx-997/Tools/ambient status          # OFF, or RUNNING scene=… pid=… since=…; exit 0
~/dev/variorum-vx-997/Tools/ambient help            # Ambient's own usage (on … install); exit 2
AMBIENT_HOME=/nonexistent ~/dev/variorum-vx-997/Tools/ambient off      # one AMBIENT MISSING line; exit 1
AMBIENT_HOME=/nonexistent ~/dev/variorum-vx-997/Tools/ambient status   # OFF; exit 0
```

## 2 · On and off for real (under your `HOLD:`, she away from the Mac)

```
~/dev/variorum-vx-997/Tools/ambient on      # AMBIENT ON — RUNNING scene=… pid=…   (the first on builds Ambient)
pgrep -x Ambient                            # that pid
~/dev/variorum-vx-997/Tools/ambient next    # AMBIENT NEXT — dissolving
~/dev/variorum-vx-997/Tools/ambient off     # AMBIENT OFF (stopped pid … in … ms)
pgrep -x Ambient                            # nothing
```

`on` refuses as ever while she is at the Mac or a claim is not `HOLD:`. If it says ON, the scene on screen
is one of seventeen; Space would show the next, but don't press keys on her screen — `next` does the same.

## 3 · The hook, under a throwaway HOME with a fake Ambient (both locales)

Paste as one block; it runs in bash whatever your shell is, and prints four `ok` lines and one last line.

```
bash <<'TRIAL'
set -u
STAGE=~/dev/variorum-vx-997/Tools/stage
T=$(mktemp -d /tmp/vx997-trial.XXXXXX)
cp /bin/sleep "$T/Ambient" && codesign --force --sign - "$T/Ambient" 2>/dev/null   # a copied system binary must be re-signed to run
named() { for p in $(pgrep -x Ambient); do [ "$p" = "$1" ] && return 0; done; return 1; }
for loc in en_US.UTF-8 C; do
  rm -rf "$T/home"; mkdir -p "$T/home/.variorum"
  FAKE=$("$T/Ambient" 600 >/dev/null 2>&1 & echo $!)   # not a job of this shell, so no "Terminated" notice
  sleep 0.3
  printf 'PID=%s\nSCENE=koi\nSINCE=trial\nWINDOW=1\n' "$FAKE" > "$T/home/.variorum/ambient.state"
  run() { env -i HOME="$T/home" PATH=/usr/bin:/bin LANG=$loc LC_ALL=$loc /bin/bash "$STAGE" "$@" >/dev/null; }
  run claim --who vx997-trial --reason "HOLD: trial hold — ask vx997-trial" --minutes 2
  named "$FAKE" && echo "[$loc] ok   a HOLD: claim left the fake Ambient up" || echo "[$loc] FAIL a HOLD: claim stopped it"
  run release --who vx997-trial
  run claim --who vx997-trial --reason "VX-997 trial walk — the hook" --minutes 2; rc=$?
  named "$FAKE" && echo "[$loc] FAIL a walk's claim left it up" || echo "[$loc] ok   a walk's claim stopped it before returning (exit $rc)"
  run release --who vx997-trial
  kill "$FAKE" 2>/dev/null
done
rm -rf "$T"
echo "after: pgrep -x Ambient -> [$(pgrep -x Ambient | tr '\n' ' ')]"
TRIAL
```

The last line shows only a real show you had up before the block (if any), still up: the sandbox's hook
stops only the process its own `HOME`'s `ambient.state` names, so running this with the real show up
leaves it up. Nothing here reads or writes the real `~/.variorum`; your hold is as it was.

## 4 · Optional: the real hook at your next natural GO

With the real show up under your `HOLD:`, make your next `coord-for-*` bridge with the worktree's tool:

```
~/dev/variorum-vx-997/Tools/stage release --who <you> && ~/dev/variorum-vx-997/Tools/stage claim --who coord-for-<x> --reason "GO pending: <x> — …" --minutes 10
pgrep -x Ambient                                     # nothing: the claim stopped it before returning
~/dev/variorum-vx-997/Tools/ambient log | tail -2    # the OFF line says why it went
~/dev/variorum-vx-997/Tools/ambient off              # AMBIENT OFF (wasn't running) — the pre-GO check as ever
```

`main`'s `Tools/stage` does not see `Ambient` (finding F2): until the merge, only the worktree's does.

## What to report (to the VX-997 orchestrator)

- Step 1: the four outputs and exit codes.
- Step 2: the ON line (scene, pid), the OFF line (ms), and anything she or you saw on screen that read wrong.
- Step 3: the five lines as printed.
- Step 4, if run: whether `pgrep -x Ambient` was empty right after the claim, and the log's OFF line.
- Anything in the skill's changed lines (`.claude/skills/stage-coordinator/SKILL.md`, the pre-GO check and
  the "Ambient, the stage ambient" section) that does not match what you saw.

## At the merge (the merging session, not the trial)

- No `StageAmbient` up before the merge (above). After it, `~/dev/variorum/Tools/StageAmbient/.build/`
  (the old bundle, gitignored, about 111 MB) stays on disk untracked: remove it once no `StageAmbient` runs.
- The coordinator's memory note on the ambient still names `Tools/StageAmbient/`: refresh it.
