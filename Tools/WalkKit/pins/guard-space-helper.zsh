#!/bin/zsh
# Tools/WalkKit/pins/guard-space-helper.zsh [guard.sh] — the HEADLESS pin for VX-536 (VX-623 D-7): guard.sh's
# on-this-Space check must REFUSE, naming its helper, when the compiled wl2 helper is absent and cannot be compiled (or
# answers nonsense) — never pass silently. Before the fix an absent helper answered "" (a "no such file" on stderr),
# which matched no refusal, so the check said GUARD OK on a window it never looked at.
#
# The guard under test (default: this checkout's Tools/WalkKit/guard.sh) is COPIED into a fresh WalkKit folder per case,
# so its own folder holds exactly the case's wl2 / wl2.swift. Everything it runs that could touch the GUI or the machine
# — pgrep, ioreg, osascript, swiftc — is a PATH shim (checked before any case runs). Nothing here touches the GUI, the
# stage, a store or production.
#
#   zsh Tools/WalkKit/pins/guard-space-helper.zsh                    # the current guard: every case PASS
#   git show <pre-fix>:Tools/WalkKit/guard.sh > $T/old.sh            # RED ON OLD: the helper-absent cases FAIL
#   zsh Tools/WalkKit/pins/guard-space-helper.zsh $T/old.sh
#
# Exit 0 = every case holds; 1 = a case failed (each case prints PASS/FAIL with what it saw).
emulate -L zsh
UNDER=${1:-${0:A:h:h}/guard.sh}
UNDER=${UNDER:A}
SRC=${0:A:h:h}/wl2.swift
[[ -f $UNDER ]] || { print -u2 "guard-space-helper: no guard at $UNDER"; exit 2 }
[[ -f $SRC ]] || { print -u2 "guard-space-helper: no wl2.swift at $SRC"; exit 2 }
T=$(mktemp -d)
trap 'rm -rf $T' EXIT
mkdir -p $T/bin

# The shims. pgrep: her app absent. ioreg: idle 99 s. osascript: the frontmost pid is the case's dev pid (4242).
# swiftc: logs its call; STUB_SWIFTC=ok writes a stub wl2 answering STUB_WL2_OUT, anything else fails the compile.
print -r -- '#!/bin/zsh
exit 1' > $T/bin/pgrep
print -r -- '#!/bin/zsh
print -r -- "    |   \"HIDIdleTime\" = 99000000000"' > $T/bin/ioreg
print -r -- '#!/bin/zsh
print -r -- 4242' > $T/bin/osascript
print -r -- '#!/bin/zsh
print -r -- "swiftc $*" >> $PIN_LOG
[[ ${STUB_SWIFTC:-fail} == ok ]] || exit 1
out=
while (( $# )); do [[ $1 == -o ]] && { out=$2; shift }; shift; done
[[ -n $out ]] || exit 1
print -r -- "#!/bin/zsh" > $out
print -r -- "print -r -- \"${STUB_WL2_OUT:-onscreen 0 0 100 100}\"" >> $out
chmod +x $out' > $T/bin/swiftc
chmod +x $T/bin/*
SHIMPATH=$T/bin:/usr/bin:/bin
for c in pgrep ioreg osascript swiftc; do
  [[ $(PATH=$SHIMPATH whence -p $c) == $T/bin/$c ]] || { print -u2 "guard-space-helper: the $c shim does not shadow the real one — refusing to run"; exit 2 }
done

stub_wl2() {  # <dir> <answer> — a compiled-helper stand-in that answers <answer>
  print -r -- '#!/bin/zsh' > $1/wl2
  print -r -- "print -r -- \"$2\"" >> $1/wl2
  chmod +x $1/wl2
}

fails=0 n=0
# run_case <name> <setup> <want-rc> <want-compile: yes|no> <guard args…>
#   setup: a zsh snippet run in the case's WalkKit folder ($W) before the guard (stub_wl2, cp $SRC, touch …)
run_case() {
  local name=$1 setup=$2 want=$3 compile=$4; shift 4
  local W=$T/case$((++n))/wk
  mkdir -p $W; cp $UNDER $W/guard.sh; chmod +x $W/guard.sh
  : > $T/log
  ( cd $W && eval "$setup" )
  local out rc
  out=$(cd /; PATH=$SHIMPATH PIN_LOG=$T/log STUB_SWIFTC=${STUB_SWIFTC:-fail} STUB_WL2_OUT=${STUB_WL2_OUT:-} \
    /bin/zsh $W/guard.sh "$@" 2>&1); rc=$?
  local called=no; [[ -s $T/log ]] && called=yes
  local ok=1
  [[ $rc == $want ]] || ok=0
  [[ $called == $compile ]] || ok=0
  (( want == 8 )) && [[ $out != *wl2* ]] && ok=0     # a refusal NAMES its helper
  if (( ok )); then print -r -- "PASS  $name (exit $rc, compile $called)"
  else print -r -- "FAIL  $name — exit $rc (want $want), compile $called (want $compile): ${out//$'\n'/ | }"; (( fails++ )); fi
}

# 1. THE PIN (red on old): the helper absent and no source to compile — the Space check cannot run, so it REFUSES (8).
run_case "helper absent, no wl2.swift → refuse (8), naming wl2" ':' 8 no 4242
# 2. The helper absent, its source present, the compile fails → refuse (8). (Old: GUARD OK.)
run_case "helper absent, the compile fails → refuse (8)" 'cp $SRC wl2.swift' 8 yes 4242
# 3. The helper absent, its source compiles → compiled, then the check runs (0). (Old: never compiled.)
STUB_SWIFTC=ok STUB_WL2_OUT="onscreen 0 0 100 100" \
  run_case "helper absent, the source compiles → compiled, GUARD OK" 'cp $SRC wl2.swift' 0 yes 4242
# 4. A helper older than its source is recompiled. (Old: never.)
STUB_SWIFTC=ok STUB_WL2_OUT="onscreen 0 0 100 100" \
  run_case "helper older than wl2.swift → recompiled" 'stub_wl2 . "onscreen 0 0 100 100"; touch -t 202001010000 wl2; cp $SRC wl2.swift' 0 yes 4242
# 5. A helper that answers nonsense (or nothing) → refuse (8). (Old: GUARD OK.)
run_case "helper answers nothing → refuse (8)" 'stub_wl2 . ""; cp $SRC wl2.swift; touch wl2' 8 no 4242
run_case "helper answers nonsense → refuse (8)" 'stub_wl2 . "zsh: no such file"; cp $SRC wl2.swift; touch wl2' 8 no 4242
# 6. The shipped behaviour stands: a current helper → its answers (0 on this Space, 6 off it, 7 a point outside).
run_case "current helper, on this Space → GUARD OK" 'cp $SRC wl2.swift; stub_wl2 . "onscreen 0 0 100 100"' 0 no 4242
run_case "current helper, offscreen → not on this Space (6)" 'cp $SRC wl2.swift; stub_wl2 . "offscreen"' 6 no 4242
run_case "current helper, a point inside → GUARD OK" 'cp $SRC wl2.swift; stub_wl2 . "onscreen 0 0 100 100"' 0 no 4242 10 10
run_case "current helper, a point outside → (7)" 'cp $SRC wl2.swift; stub_wl2 . "onscreen 0 0 100 100"' 7 no 4242 500 500
# 7. --author never needs the helper (the author checks run before anything else, helper or not).
run_case "--author with no helper → GUARD OK, nothing compiled" ':' 0 no --author

print "guard-space-helper pins: $fails failing of $n"
(( fails == 0 ))
