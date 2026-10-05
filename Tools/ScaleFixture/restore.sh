#!/bin/zsh
# 17y B1 — RESTORE the dev store from a stage.sh prestage copy.
#
#   Tools/ScaleFixture/restore.sh "<…/Backups/safety-copies/scale-prestage-<ts>>"
#
# Refuses while ANY Variorum instance runs. Removes the CURRENT -wal/-shm first
# (a fixture-era WAL replayed onto the restored file would corrupt it), copies
# the prestage set back, and verifies every file byte-for-byte with cmp.
# Touches only the DEV container's Variorum-dev folder.
set -e
SRC="$1"
STORE="$HOME/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev"
case "$SRC" in
  "$STORE"/Backups/safety-copies/scale-prestage-*) ;;
  *) echo "STOP: not a scale-prestage dir under the DEV store: $SRC"; exit 2;;
esac
[ -f "$SRC/variorum.sqlite" ] || { echo "STOP: $SRC has no variorum.sqlite"; exit 2; }
if pgrep -f 'Variorum.app/Contents/MacOS' >/dev/null; then
  echo "STOP: a Variorum instance is running — quit the DEV build first (never her real-store app):"
  pgrep -fl 'Variorum.app/Contents/MacOS'; exit 3
fi
rm -f "$STORE/variorum.sqlite-wal" "$STORE/variorum.sqlite-shm"
for f in "$SRC"/*; do
  cp -p "$f" "$STORE/"
  cmp "$f" "$STORE/$(basename "$f")" || { echo "STOP: restore of $(basename "$f") did not verify"; exit 4; }
done
echo "Restored (verified) from $SRC:"
ls -la "$STORE" | grep -E "variorum"
