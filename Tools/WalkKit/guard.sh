#!/bin/zsh
# guard.sh --author        — the AUTHOR checks alone: (0) her app absent; (1) HID idle >= 2 s.
#                            Run them BEFORE anything touches the GUI — activation included.
# guard.sh <devpid> [x y]  — the full per-step rule (18l ENVIRONMENT TRAPS, hardened 615b833a): the
#                            author checks, then (2) dev pid frontmost; (3) dev window on this Space,
#                            point inside it.
# Exit: 3 her app · 4 someone at the machine (STOP — never re-activate and retry: U-VIS round 1,
# MAJOR-1) · 5 not frontmost · 6 not on this Space · 7 point outside the window.
S="$(cd "$(dirname "$0")" && pwd)"
if pgrep -f '/Applications/Variorum.app/Contents/MacOS' >/dev/null; then echo "GUARD: her app is running — STOP"; exit 3; fi
idle=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')
if [ "$idle" -lt 2 ]; then echo "GUARD: HID idle ${idle}s — someone is at the machine — STOP"; exit 4; fi
if [ "$1" = "--author" ]; then echo "GUARD OK (author: idle ${idle}s)"; exit 0; fi
pid=$1
front=$(osascript -e 'tell application "System Events" to get unix id of first application process whose frontmost is true')
if [ "$front" != "$pid" ]; then echo "GUARD: frontmost pid $front, not $pid — STOP"; exit 5; fi
win=$("$S"/wl2 $pid)
case "$win" in offscreen) echo "GUARD: dev window not on this Space — STOP"; exit 6;; esac
if [ -n "$2" ]; then
  set -- $pid $2 $3 ${=win#onscreen }
  x=$2; y=$3; wx=$4; wy=$5; ww=$6; wh=$7
  if [ $x -lt $wx ] || [ $x -gt $((wx+ww)) ] || [ $y -lt $wy ] || [ $y -gt $((wy+wh)) ]; then echo "GUARD: point ($x,$y) outside the dev window ($win) — STOP"; exit 7; fi
fi
echo "GUARD OK ($win, idle ${idle}s)"
