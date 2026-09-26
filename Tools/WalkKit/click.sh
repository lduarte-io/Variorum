#!/bin/zsh
# click.sh <devpid> x y — the author checks FIRST (nothing touches the GUI before them), then activate
# the dev instance, the full guard, one click. (U-VIS round 1, MAJOR-1: activating first moved her
# keyboard focus before the check that she is at the machine.)
S="$(cd "$(dirname "$0")" && pwd)"
"$S"/guard.sh --author || exit $?
osascript -e "tell application \"System Events\" to set frontmost of (first application process whose unix id is $1) to true" >/dev/null
sleep 0.4
"$S"/guard.sh $1 $2 $3 || exit $?
cliclick c:$2,$3
