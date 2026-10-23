#!/bin/bash
# make-dmg.sh — Phase 13r U3-A: THE SELF-EXPLAINING DMG WINDOW (R-13r-10, her ruling at the U2 walk
# sitting: "yeah let's do this one - that's what I'm talking about as a standard experience … approved").
# U2's DMG was the app + an /Applications link with no layout; at the walk she never saw the link and ran
# the app from the mounted image. This builds the DMG so its window explains itself: the app icon and the
# Applications link at FIXED positions, a plain arrow and "Drag Variorum to Applications" between them, a
# fixed window size, no toolbar and no sidebar. FUNCTIONAL ONLY — the branded background art is 13s's.
#
#   Tools/Release/make-dmg.sh --app PATH --version X.Y.Z --out DIR   → DIR/Variorum-<version>.dmg (UDZO, UNSIGNED)
#   Tools/Release/make-dmg.sh --check [--ask]                        → may this host lay out a Finder window?
#   Tools/Release/make-dmg.sh --verify-layout MOUNTPOINT             → read a mounted DMG's layout back
#
# THE ROAD (her ruling's letter — plain hdiutil + scripted Finder settings, NO new dependency):
#   1. stage the app, an /Applications link and .background/background.tiff (dmg-background.swift draws
#      it, 1× + 2× combined by tiffutil) in a fresh folder
#   2. hdiutil create a READ-WRITE image (UDRW, HFS+, volume "Variorum") from it, attach it at /Volumes
#   3. AppleScript tells Finder the window's settings — Finder WRITES the .DS_Store into the read-write
#      image (icon view, toolbar/status bar hidden, the bounds, 128-pt icons, the background, the two
#      positions) — then the image is detached
#   4. hdiutil convert → UDZO, named EXACTLY Variorum-<version>.dmg
# The layout is therefore set BEFORE release.sh signs and notarizes the DMG (the order is unchanged: the
# .DS_Store is inside what Apple notarizes and what the signature seals).
#
# THE ONE PERMISSION: scripting Finder needs the user's consent for the terminal app running this (System
# Settings ▸ Privacy & Security ▸ Automation ▸ <terminal> ▸ Finder). `--check` asks the system WITHOUT a
# prompt (finder-automation-check.swift); release.sh runs it at PREFLIGHT, so a missing consent refuses
# before an hour of archive + notarization rather than hanging mid-run. Granting it is HER hands.
#
# Exit: 0 done · 1 a verification failed · 2 usage · 3 refused (permission, a volume already named
#       "Variorum" mounted, a non-empty output) · 6 hdiutil/Finder failed.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
VOLNAME="Variorum"
# THE GEOMETRY (dmg-background.swift draws to the same numbers — keep them in step): the window's content
# is 660×400 pt; Finder's bounds are {left, top, right, bottom} in screen points and include the 28-pt
# title bar; an icon's position is its CENTRE.
BOUNDS_LEFT=200; BOUNDS_TOP=120; CONTENT_W=660; CONTENT_H=400; TITLE_BAR=28
APP_X=165; APP_Y=190; LINK_X=495; LINK_Y=190
ICON_SIZE=128; TEXT_SIZE=13

usage() { echo "usage: $0 --app PATH --version X.Y.Z --out DIR | --check [--ask] | --verify-layout MOUNTPOINT" >&2; exit 2; }
say() { echo "[make-dmg] $*"; }
refuse() { echo "REFUSED: $*" >&2; exit 3; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/make-dmg.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

check_finder() {   # check_finder [--ask] → 0 allowed, else the checker's exit code
  xcrun swiftc -O -o "${WORK}/finder-automation-check" "${HERE}/finder-automation-check.swift" 2>"${WORK}/swiftc.err" \
    || { cat "${WORK}/swiftc.err" >&2; echo "could not compile finder-automation-check.swift" >&2; return 5; }
  "${WORK}/finder-automation-check" "$@"
}

verify_layout() {   # verify_layout MOUNTPOINT — the .DS_Store Finder wrote says exactly what was asked
  local mnt="$1"
  [ -f "${mnt}/.DS_Store" ] || { echo "FAIL  no .DS_Store at ${mnt} (the window was never laid out)"; return 1; }
  [ -f "${mnt}/.background/background.tiff" ] || { echo "FAIL  no .background/background.tiff at ${mnt}"; return 1; }
  python3 - "${mnt}/.DS_Store" "$APP_X" "$APP_Y" "$LINK_X" "$LINK_Y" "$CONTENT_W" <<'PY'
import plistlib, struct, sys
data = open(sys.argv[1], "rb").read()
app = (int(sys.argv[2]), int(sys.argv[3])); link = (int(sys.argv[4]), int(sys.argv[5])); width = int(sys.argv[6])
fails = 0
def record(name, code):
    key = struct.pack(">I", len(name)) + name.encode("utf-16-be") + code
    i = data.find(key)
    return None if i < 0 else i + len(key)
def iloc(name):
    at = record(name, b"Iloc")
    if at is None or data[at:at+4] != b"blob": return None
    return struct.unpack(">II", data[at+8:at+16])
for name, want in (("Variorum.app", app), ("Applications", link)):
    got = iloc(name)
    if got == want: print(f"PASS  {name} sits at {want} (its Iloc record)")
    else: print(f"FAIL  {name} sits at {got}, expected {want}"); fails += 1
def blob_plist(code):
    at = record(".", code)
    if at is None or data[at:at+4] != b"blob": return None
    n = struct.unpack(">I", data[at+4:at+8])[0]
    return plistlib.loads(data[at+8:at+8+n])
bwsp = blob_plist(b"bwsp")
if bwsp is None: print("FAIL  no window record (bwsp)"); fails += 1
else:
    # A hidden toolbar hides the sidebar with it (Finder's own rule); ShowSidebar is reported, not judged.
    if bwsp.get("ShowToolbar") is False and bwsp.get("ShowStatusBar") is False:
        print(f"PASS  no toolbar, no status bar (ShowSidebar={bwsp.get('ShowSidebar')})")
    else: print(f"FAIL  window chrome: {bwsp}"); fails += 1
    bounds = bwsp.get("WindowBounds", "")
    size = bounds.replace(" ", "").split("},{")[-1].strip("{}") if bounds else ""
    if size.split(",")[0] == str(width):
        print(f"PASS  the window is {width} pt wide ({bounds})")
    else: print(f"FAIL  window bounds {bounds!r}"); fails += 1
icvp = blob_plist(b"icvp")
if icvp is None: print("FAIL  no icon-view record (icvp)"); fails += 1
else:
    ok = icvp.get("backgroundType") == 2 and icvp.get("arrangeBy", "none") == "none" and int(icvp.get("iconSize", 0)) == 128
    if ok: print("PASS  icon view: the picture background, not arranged, 128-pt icons")
    else: print(f"FAIL  icon view: {dict((k, icvp.get(k)) for k in ('backgroundType', 'arrangeBy', 'iconSize'))}"); fails += 1
print("VERDICT: PASS" if fails == 0 else f"VERDICT: FAIL — {fails} check(s)")
sys.exit(0 if fails == 0 else 1)
PY
}

MODE=""; APP=""; VERSION=""; OUT=""; ASK=""; MNT_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --app) [ $# -ge 2 ] || usage; APP="$2"; MODE=build; shift 2 ;;
    --version) [ $# -ge 2 ] || usage; VERSION="$2"; shift 2 ;;
    --out) [ $# -ge 2 ] || usage; OUT="$2"; shift 2 ;;
    --check) MODE=check; shift ;;
    --ask) ASK=--ask; shift ;;
    --verify-layout) [ $# -ge 2 ] || usage; MODE=verify; MNT_ARG="$2"; shift 2 ;;
    *) usage ;;
  esac
done

case "$MODE" in
  check) check_finder ${ASK:+"$ASK"}; exit $? ;;
  verify) verify_layout "$MNT_ARG"; exit $? ;;
  build) ;;
  *) usage ;;
esac

[ -n "$APP" ] && [ -n "$VERSION" ] && [ -n "$OUT" ] || usage
[ -d "$APP" ] || refuse "no such app: ${APP}"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || refuse "--version must be X.Y or X.Y.Z (got '${VERSION}')"
mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
DMG="${OUT}/Variorum-${VERSION}.dmg"
[ ! -e "$DMG" ] || refuse "${DMG} already exists (every DMG is built fresh)"
set +e; check_finder >/dev/null; FINDER=$?; set -e
[ "$FINDER" -eq 0 ] || { check_finder || true; refuse "this host may not script Finder, so the DMG window cannot be laid out (see above)"; }
[ ! -e "/Volumes/${VOLNAME}" ] || refuse "a volume is already mounted at /Volumes/${VOLNAME} — eject it first (Finder must address exactly ONE \"${VOLNAME}\" disk while the layout is written)"

# ---------------------------------------------------------------- 1. stage
ROOT="${WORK}/root"
mkdir -p "${ROOT}/.background"
ditto "$APP" "${ROOT}/Variorum.app"
ln -s /Applications "${ROOT}/Applications"
xcrun swiftc -O -o "${WORK}/dmg-background" "${HERE}/dmg-background.swift" 2>"${WORK}/swiftc-bg.err" \
  || { cat "${WORK}/swiftc-bg.err" >&2; echo "could not compile dmg-background.swift" >&2; exit 6; }
"${WORK}/dmg-background" "$WORK" >/dev/null
tiffutil -cathidpicheck "${WORK}/background.png" "${WORK}/background@2x.png" -out "${ROOT}/.background/background.tiff" >/dev/null 2>&1 \
  || { echo "tiffutil could not combine the background's 1× and 2× images" >&2; exit 6; }
say "staged: Variorum.app · Applications → /Applications · .background/background.tiff (1× + 2×)"

# ---------------------------------------------------------------- 2. the read-write image, attached
RW="${WORK}/rw.dmg"
SIZE_MB=$(( $(du -sm "$ROOT" | cut -f1) + 40 ))
hdiutil create -volname "$VOLNAME" -srcfolder "$ROOT" -fs HFS+ -format UDRW -size "${SIZE_MB}m" -ov "$RW" \
  > "${WORK}/hdiutil-create.txt" 2>&1 || { cat "${WORK}/hdiutil-create.txt" >&2; exit 6; }
"$LSREGISTER" -u "${ROOT}/Variorum.app" >/dev/null 2>&1 || true
hdiutil attach -readwrite -noverify -noautoopen "$RW" > "${WORK}/hdiutil-attach.txt" 2>&1 \
  || { cat "${WORK}/hdiutil-attach.txt" >&2; exit 6; }
MNT="$(grep -o '/Volumes/.*$' "${WORK}/hdiutil-attach.txt" | tail -1)"
DEV="$(grep -o '^/dev/disk[0-9]*' "${WORK}/hdiutil-attach.txt" | head -1)"
detach_rw() {
  "$LSREGISTER" -u "${MNT}/Variorum.app" >/dev/null 2>&1 || true
  hdiutil detach "$DEV" >/dev/null 2>&1 || { sleep 3; hdiutil detach -force "$DEV" >/dev/null 2>&1 || true; }
}
[ "$MNT" = "/Volumes/${VOLNAME}" ] || { detach_rw; echo "the read-write image mounted at '${MNT}', not /Volumes/${VOLNAME}" >&2; exit 6; }
say "read-write image attached at ${MNT} (${DEV})"

# ---------------------------------------------------------------- 3. Finder writes the layout
RIGHT=$(( BOUNDS_LEFT + CONTENT_W )); BOTTOM=$(( BOUNDS_TOP + CONTENT_H + TITLE_BAR ))
set +e
osascript - "$VOLNAME" "$BOUNDS_LEFT" "$BOUNDS_TOP" "$RIGHT" "$BOTTOM" "$APP_X" "$APP_Y" "$LINK_X" "$LINK_Y" \
  "$ICON_SIZE" "$TEXT_SIZE" > "${WORK}/finder.txt" 2>&1 <<'APPLESCRIPT'
on run argv
  set volName to item 1 of argv
  set {l, t, r, b} to {(item 2 of argv) as integer, (item 3 of argv) as integer, (item 4 of argv) as integer, (item 5 of argv) as integer}
  set appPos to {(item 6 of argv) as integer, (item 7 of argv) as integer}
  set linkPos to {(item 8 of argv) as integer, (item 9 of argv) as integer}
  tell application "Finder"
    tell disk volName
      open
      set w to container window
      set current view of w to icon view
      set toolbar visible of w to false
      set statusbar visible of w to false
      set bounds of w to {l, t, r, b}
      set opts to the icon view options of w
      set arrangement of opts to not arranged
      set icon size of opts to (item 10 of argv) as integer
      set text size of opts to (item 11 of argv) as integer
      set background picture of opts to file ".background:background.tiff"
      set position of item "Variorum.app" to appPos
      set position of item "Applications" to linkPos
      close w
      open
      update without registering applications
      delay 2
      close container window
    end tell
  end tell
end run
APPLESCRIPT
FINDER_RC=$?
set -e
[ "$FINDER_RC" -eq 0 ] || { cat "${WORK}/finder.txt" >&2; detach_rw; echo "Finder could not lay out the window (osascript exit ${FINDER_RC})" >&2; exit 6; }
# Finder writes the .DS_Store asynchronously; wait for it, then read it back while the image is still ours.
for _ in $(seq 1 20); do [ -f "${MNT}/.DS_Store" ] && break; sleep 1; done
sync
set +e; verify_layout "$MNT" > "${WORK}/layout.txt"; LAYOUT=$?; set -e
sed 's/^/    /' "${WORK}/layout.txt"
rm -rf "${MNT}/.fseventsd" "${MNT}/.Trashes" 2>/dev/null || true
detach_rw
[ "$LAYOUT" -eq 0 ] || { echo "the window's layout did not read back as asked" >&2; exit 1; }
say "Finder wrote the layout; the read-write image is detached"

# ---------------------------------------------------------------- 4. compress, named EXACTLY
hdiutil convert "$RW" -format UDZO -imagekey zlib-level=9 -o "$DMG" > "${WORK}/hdiutil-convert.txt" 2>&1 \
  || { cat "${WORK}/hdiutil-convert.txt" >&2; exit 6; }
say "${DMG} ($(stat -f %z "$DMG") bytes, UNSIGNED — the caller signs and notarizes it)"
