#!/bin/zsh
# build.sh [--src <tree>] [--dd <derived data>] — build the Debug app the harness launches, and STAMP it
# with what it was compiled from (lib.zsh's vw_tree_state: App/ and the core, committed + uncommitted).
# The default is this repo into App/Variorum/DerivedData/vis-walk (what `visual-walk.sh --build` runs).
# A scratch tree (a fix reverted in a worktree, the harness's teeth) builds the same way:
#   Tools/VisualWalk/build.sh --src <worktree> --dd <worktree>/dd   then   VW_DD=<worktree>/dd visual-walk.sh …
emulate -L zsh
source ${0:A:h}/lib.zsh
src=$REPO dd=$DD
while (( $# )); do
  case $1 in --src) src=${2:A}; shift ;; --dd) dd=${2:A}; shift ;; *) print -u2 "unknown: $1"; exit 5 ;; esac
  shift
done
before=$(vw_tree_state $src)
print -u2 "building $src → $dd  ($before)"
(cd $src/App/Variorum && xcodebuild -scheme Variorum -configuration Debug -destination 'platform=macOS' \
   -derivedDataPath $dd build > $dd.build.log 2>&1) || { print -u2 "the Debug build failed ($dd.build.log)"; exit 1 }
after=$(vw_tree_state $src)
[[ $before == $after ]] || { print -u2 "the source tree changed during the build — not stamped"; exit 1 }
print -r -- "$before built=$(date -u +%Y-%m-%dT%H:%M:%SZ)" > $dd/vis-walk.stamp
print -u2 "stamped: $dd/vis-walk.stamp"
