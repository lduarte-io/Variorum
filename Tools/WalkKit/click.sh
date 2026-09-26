#!/bin/zsh
# click.sh <devpid> x y — activate the dev instance, run the guard, click once.
S="$(cd "$(dirname "$0")" && pwd)"
osascript -e "tell application \"System Events\" to set frontmost of (first application process whose unix id is $1) to true" >/dev/null
sleep 0.4
"$S"/guard.sh $1 $2 $3 || exit $?
cliclick c:$2,$3
