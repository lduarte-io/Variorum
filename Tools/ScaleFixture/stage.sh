#!/bin/zsh
# 17y B1 — STAGE THE LARGE FIXTURE in the DEV store (never the real one).
#
#   Tools/ScaleFixture/stage.sh [notes=600,long=2000] [derived-data dir]
#
# 1. Refuses while ANY Variorum instance runs (her real-store app included —
#    the dev store must be quiet for the copy, and hers is never touched).
# 2. Takes the A1 safety copy of the dev store (every store file + the key
#    file) into the dev container's Backups/safety-copies/scale-prestage-<ts>/,
#    verified byte-for-byte with cmp.
# 3. Launches the DEV-store Debug build with VARIORUM_SCALE_FIXTURE set; the
#    app mints the fixture once (`ScaleFixture.swift`, DEBUG-only) — about a
#    minute for the default size — and logs "ScaleFixture: minted …".
# Afterwards: quit the Debug app, then Tools/ScaleFixture/restore.sh <the dir
# this prints> puts the dev store back exactly as it was.
set -e
SPEC="${1:-notes=600,long=2000}"
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
DD="${2:-$REPO/App/Variorum/DerivedData/17y}"
APP="$DD/Build/Products/Debug/Variorum.app"
STORE="$HOME/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev"
[ -d "$APP" ] || { echo "STOP: no Debug build at $APP"; exit 2; }
[ -f "$STORE/variorum.sqlite" ] || { echo "STOP: no dev store at $STORE"; exit 2; }
if pgrep -f 'Variorum.app/Contents/MacOS' >/dev/null; then
  echo "STOP: a Variorum instance is running — quit the DEV build first (never her real-store app):"
  pgrep -fl 'Variorum.app/Contents/MacOS'; exit 3
fi
TS=$(date -u +%Y%m%dT%H%M%SZ)
DEST="$STORE/Backups/safety-copies/scale-prestage-$TS"
mkdir -p "$DEST"
for f in "$STORE"/variorum.sqlite "$STORE"/variorum.sqlite-wal "$STORE"/variorum.sqlite-shm "$STORE"/variorum-keys-*.json; do
  [ -e "$f" ] || continue
  cp -p "$f" "$DEST/"
  cmp "$f" "$DEST/$(basename "$f")" || { echo "STOP: copy of $f did not verify"; exit 4; }
done
echo "A1 prestage copy (verified): $DEST"
ls -la "$DEST"
open -n --env VARIORUM_SCALE_FIXTURE="$SPEC" "$APP"
echo "Launched the DEV build with VARIORUM_SCALE_FIXTURE=$SPEC — the fixture mints in the background (~1 min)."
echo "When done walking: quit the DEV build, then: Tools/ScaleFixture/restore.sh \"$DEST\""
