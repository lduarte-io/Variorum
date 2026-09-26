#!/bin/zsh
# pins/build-stamp.zsh — HEADLESS pin for the build identity and the launch verdict (U-VIS round 1,
# MINOR-3/4): the report must name the tree the BINARY came from, and the driver must refuse a build
# that is not the current tree's — an old or foreign core must never open the dev store; a VW_DD
# scratch build may differ ONLY under App/. A throwaway git repo stands in for the tree.
emulate -L zsh
VW=${0:A:h:h}
source $VW/lib.zsh
T=$(mktemp -d /tmp/vw-build-stamp.XXXXXX)
trap 'rm -rf $T' EXIT
fails=0
check() { if eval "$2"; then print "PASS  $1"; else print "FAIL  $1"; (( fails++ )); fi }

cd $T && git init -q && git config user.email pin@example.invalid && git config user.name pin
mkdir -p App Sources/VariorumCore/Persistence
print app > App/a.swift; print core > Sources/VariorumCore/Persistence/m.swift
print pkg > Package.swift; print res > Package.resolved
git add -A && git commit -qm one
s1=$(vw_tree_state $T)
print tweak >> App/a.swift;                                   s_app=$(vw_tree_state $T)
git checkout -q -- App/a.swift
print migration >> Sources/VariorumCore/Persistence/m.swift;  s_core=$(vw_tree_state $T)
git checkout -q -- Sources
print notes > notes.md && git add notes.md && git commit -qm notes-only; s_notes=$(vw_tree_state $T)

field() { local kv; for kv in ${(s: :)1}; do [[ ${kv%%=*} == $2 ]] && print -r -- ${kv#*=}; done }
check "an uncommitted App/ edit changes app, not core" \
  '[[ $(field $s_app app) != $(field $s1 app) && $(field $s_app core) == $(field $s1 core) && $(field $s_app dirty) == App/a.swift ]]'
check "an uncommitted persistence edit changes core" '[[ $(field $s_core core) != $(field $s1 core) ]]'
check "a commit outside App/ and the core changes neither (no rebuild for a record commit)" \
  '[[ $(field $s_notes app) == $(field $s1 app) && $(field $s_notes core) == $(field $s1 core) ]]'

verdict() { vw_stamp_verdict "$1" "$2" $3 >/dev/null }
check "no stamp → refused"                              '! verdict "" "$s1" 0'
check "the tree's own build → launched"                 'verdict "$s1" "$s1" 0'
check "a build of an older App/ → refused"              '! verdict "$s_app" "$s1" 0'
check "a build whose core differs → refused"            '! verdict "$s_core" "$s1" 0'
check "a scratch build differing only in App/ → launched" 'verdict "$s_app" "$s1" 1'
check "a scratch build with a different core → refused (never opens the dev store)" '! verdict "$s_core" "$s1" 1'

print "build-stamp pins: $fails failing"
(( fails == 0 ))
