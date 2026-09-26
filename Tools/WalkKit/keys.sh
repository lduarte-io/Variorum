#!/bin/zsh
# keys.sh <devpid> <applescript statements...> — activate, guard, then run System Events statements.
S="$(cd "$(dirname "$0")" && pwd)"
pid=$1; shift
osascript -e "tell application \"System Events\" to set frontmost of (first application process whose unix id is $pid) to true" >/dev/null
sleep 0.4
"$S"/guard.sh $pid || exit $?
args=(-e 'tell application "System Events"')
for st in "$@"; do args+=(-e "$st"); done
args+=(-e 'end tell')
osascript "${args[@]}"
