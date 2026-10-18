#!/bin/zsh
# VX-378 gate soak, RELEASE pass only, on the FINAL tree (soak3.sh's release leg re-run: zsh does not word-split
# an unquoted scalar, so "-c release" reached swift as one argument and every release seed exited at once).
cd <home>/dev/variorum-vx-305
LOG=$1
run() { # seed
  local seed=$1
  local out=$(PROTECTION_SOAK=1 PROTECTION_SEED=$seed PROTECTION_SOAK_SEEDS=1 PROTECTION_SOAK_SEQUENCES=1000 swift test -c release --filter 'VariorumCoreTests\.GeneratorTests/' 2>&1)
  local line=$(echo "$out" | grep -a -E "Test run with" | tail -1)
  local steps=$(echo "$out" | grep -a -oE "[0-9][0-9,]* steps" | tr -d , | sort -n | tail -1)
  echo "release seed=$seed steps=$steps :: $line" >> $LOG
  if echo "$line" | grep -q "✔"; then return 0; else echo "$out" | tail -80 >> $LOG.fail-release-$seed; return 1; fi
}
echo "RELEASE RERUN START $(date -u +%FT%TZ) tree $(git rev-parse --short HEAD) (soak3.sh's release leg never ran: zsh scalar passed '-c release' as one word)" >> $LOG
fail=0
for s in {1..20}; do run $s || fail=1; done
echo "GATE RELEASE RERUN DONE fail=$fail $(date -u +%FT%TZ)" >> $LOG
echo "RELEASE END $(date -u +%FT%TZ)" >> $LOG
