#!/bin/zsh
# VX-378 gate runs on the FINAL tree: discovery 21-40 (Debug), then gate soak 1-20 Debug, then Release.
cd <home>/dev/variorum-vx-305
LOG=$1
run() { # cfg seed
  local cfg=$1 seed=$2 extra=""
  [[ $cfg == release ]] && extra="-c release"
  local out=$(PROTECTION_SOAK=1 PROTECTION_SEED=$seed PROTECTION_SOAK_SEEDS=1 PROTECTION_SOAK_SEQUENCES=1000 swift test $extra --filter 'VariorumCoreTests\.GeneratorTests/' 2>&1)
  local line=$(echo "$out" | grep -a -E "Test run with" | tail -1)
  local steps=$(echo "$out" | grep -a -oE "[0-9][0-9,]* steps" | tr -d , | sort -n | tail -1)
  echo "$cfg seed=$seed steps=$steps :: $line" >> $LOG
  if echo "$line" | grep -q "✔"; then return 0; else echo "$out" | grep -a -E "✘|Issue|recorded|sequence|minimal|promise" | head -60 >> $LOG.fail-$cfg-$seed; return 1; fi
}
echo "START $(date -u +%FT%TZ) tree $(git rev-parse --short HEAD)" >> $LOG
fail=0
for s in {21..40}; do run debug $s || fail=1; done
echo "DISCOVERY DONE fail=$fail $(date -u +%FT%TZ)" >> $LOG
[[ $fail == 1 ]] && { echo "STOP: discovery red" >> $LOG; exit 1; }
for s in {1..20}; do run debug $s || fail=1; done
echo "GATE DEBUG DONE fail=$fail $(date -u +%FT%TZ)" >> $LOG
for s in {1..20}; do run release $s || fail=1; done
echo "GATE RELEASE DONE fail=$fail $(date -u +%FT%TZ)" >> $LOG
echo "END $(date -u +%FT%TZ)" >> $LOG
