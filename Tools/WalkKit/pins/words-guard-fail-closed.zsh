#!/bin/zsh
# Tools/WalkKit/pins/words-guard-fail-closed.zsh [words-guard.swift] — the HEADLESS pin for the VX-623 ladder's round-1
# MAJOR (notes/plans/fixes/vx-623-ladder-round1.md, P-1): the words guard must WITHHOLD (exit 1) a pid whose AX tree it
# cannot read — never answer "ok". Before the fix every non-success answer of the windows read folded into an empty
# queue, so a non-GUI, dead or hung pid printed "ok" (exit 0) having inspected nothing, and the first-run walk's
# capture() — which reads exit 0 as go-ahead, while walk-cap lists windows by CGWindowList with no AX — would shoot.
#
# The guard under test (default: this checkout's Tools/WalkKit/words-guard.swift) is compiled into a temp folder. The
# only processes it reads are this pin's own: a backgrounded `sleep` (alive, no AX server — AXError -25204 at once) and a
# reaped pid. Nothing here touches the GUI, the stage, a store or production.
#
#   zsh Tools/WalkKit/pins/words-guard-fail-closed.zsh                       # the current guard: every case PASS
#   git show <pre-fix>:Tools/WalkKit/words-guard.swift > $T/old.swift        # RED ON OLD: the pid cases + --self-check FAIL
#   zsh Tools/WalkKit/pins/words-guard-fail-closed.zsh $T/old.swift
#
# Exit 0 = every case holds; 1 = a case failed (each prints PASS/FAIL with what it saw); 2 = it could not run.
emulate -L zsh
UNDER=${1:-${0:A:h:h}/words-guard.swift}
UNDER=${UNDER:A}
[[ -f $UNDER ]] || { print -u2 "words-guard-fail-closed: no source at $UNDER"; exit 2 }
T=$(mktemp -d)
SLEEPER=
trap '[[ -n $SLEEPER ]] && kill $SLEEPER 2>/dev/null; rm -rf $T' EXIT
swiftc -O -o $T/words-guard $UNDER 2>$T/swiftc.log || { print -u2 "words-guard-fail-closed: $UNDER does not compile"; exit 2 }

fails=0 n=0
# run_case <name> <want-rc> <want-prefix> <guard args…>
run_case() {
  local name=$1 want=$2 prefix=$3 out rc; shift 3
  out=$($T/words-guard "$@" 2>&1); rc=$?
  (( ++n ))
  if (( rc == want )) && [[ $out == ${prefix}* ]]; then print -r -- "PASS $name — exit $rc: ${out%%$'\n'*}"
  else print -r -- "FAIL $name — exit $rc (want $want, '$prefix…'): ${out%%$'\n'*}"; (( ++fails )); fi
}

sleep 60 & SLEEPER=$!
run_case "a live non-GUI pid (a backgrounded sleep) → withheld" 1 "withheld (" $SLEEPER
kill $SLEEPER 2>/dev/null; wait $SLEEPER 2>/dev/null; SLEEPER=
true & gone=$!; wait $gone 2>/dev/null
run_case "a reaped pid → withheld" 1 "withheld (" $gone
run_case "a non-numeric argument → usage, withheld (exit 2)" 2 "withheld (usage" notapid
run_case "--classify twelve lowercase words → withheld" 1 "withheld (" --classify "alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima"
run_case "--classify the join's landed line → ok" 0 "ok" --classify "Synced. Your account's writing is in this library now."
run_case "--self-check (the scan over synthetic trees: cap · cycle · unreadable · deep words · clean) → green" 0 "SELF-CHECK" --self-check

print -r -- "words-guard-fail-closed: $fails failing of $n (under: $UNDER)"
(( fails == 0 ))
