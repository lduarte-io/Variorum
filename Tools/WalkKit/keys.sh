#!/bin/zsh
# keys.sh <devpid> <applescript statements...> — the author checks FIRST, then activate, the full
# guard, and the System Events statements. (U-VIS round 1, MAJOR-1 — the click.sh order.)
S="$(cd "$(dirname "$0")" && pwd)"
pid=$1; shift
"$S"/guard.sh --author || exit $?
osascript -e "tell application \"System Events\" to set frontmost of (first application process whose unix id is $pid) to true" >/dev/null
sleep 0.4
"$S"/guard.sh $pid || exit $?
args=(-e 'tell application "System Events"')
for st in "$@"; do args+=(-e "$st"); done
args+=(-e 'end tell')
osascript "${args[@]}"
