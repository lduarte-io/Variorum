#!/bin/zsh
# guard.sh --author        — the AUTHOR checks alone: (0) her app absent; (1) HID idle >= 2 s.
#                            Run them BEFORE anything touches the GUI — activation included.
# guard.sh <devpid> [x y]  — the full per-step rule (18l ENVIRONMENT TRAPS, hardened 615b833a): the
#                            author checks, then (2) dev pid frontmost; (3) dev window on this Space,
#                            point inside it.
# Exit: 3 her app · 4 someone at the machine (STOP — never re-activate and retry: U-VIS round 1,
# MAJOR-1) · 5 not frontmost · 6 not on this Space · 7 point outside the window · 8 the on-this-Space
# check cannot run (VX-536, VX-623 D-7: its compiled wl2 helper is absent and cannot be compiled from
# wl2.swift, or it answers neither onscreen nor offscreen — it COMPILES OR REFUSES, never a silent pass;
# the pin is pins/guard-space-helper.zsh).
S="$(cd "$(dirname "$0")" && pwd)"
if pgrep -f '/Applications/Variorum.app/Contents/MacOS' >/dev/null; then echo "GUARD: her app is running — STOP"; exit 3; fi
idle=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')
if [ "$idle" -lt 2 ]; then echo "GUARD: HID idle ${idle}s — someone is at the machine — STOP"; exit 4; fi
if [ "$1" = "--author" ]; then echo "GUARD OK (author: idle ${idle}s)"; exit 0; fi
pid=$1
# VX-536: the Space check's helper, compiled here when absent or older than its source (Tools/WalkKit/wl2 is gitignored,
# so a fresh worktree has none) — before the frontmost read, so a first compile's seconds never stale it. An absent
# helper used to answer "" (a "no such file" on stderr), which matched no refusal: the check passed on a window it never
# looked at.
if [ ! -x "$S/wl2" ] || [ "$S/wl2.swift" -nt "$S/wl2" ]; then
  if [ ! -f "$S/wl2.swift" ] || ! swiftc -O -o "$S/wl2" "$S/wl2.swift" >/dev/null 2>&1; then
    echo "GUARD: the on-this-Space helper $S/wl2 is missing and cannot be compiled from wl2.swift — STOP"; exit 8
  fi
fi
front=$(osascript -e 'tell application "System Events" to get unix id of first application process whose frontmost is true')
if [ "$front" != "$pid" ]; then echo "GUARD: frontmost pid $front, not $pid — STOP"; exit 5; fi
win=$("$S"/wl2 $pid 2>/dev/null)
case "$win" in
  offscreen) echo "GUARD: dev window not on this Space — STOP"; exit 6;;
esac
if [[ ! $win =~ '^onscreen -?[0-9]+ -?[0-9]+ [0-9]+ [0-9]+$' ]]; then
  echo "GUARD: the on-this-Space helper $S/wl2 answered '$win' (neither onscreen nor offscreen) — STOP"; exit 8
fi
if [ -n "$2" ]; then
  set -- $pid $2 $3 ${=win#onscreen }
  x=$2; y=$3; wx=$4; wy=$5; ww=$6; wh=$7
  if [ $x -lt $wx ] || [ $x -gt $((wx+ww)) ] || [ $y -lt $wy ] || [ $y -gt $((wy+wh)) ]; then echo "GUARD: point ($x,$y) outside the dev window ($win) — STOP"; exit 7; fi
fi
echo "GUARD OK ($win, idle ${idle}s)"
