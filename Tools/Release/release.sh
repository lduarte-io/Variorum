#!/bin/bash
# release.sh — Phase 13r U2: THE RELEASE PIPELINE, whole and in order (the 13r plan's U2 section + the
# site-side report's binding facts).
#
#   Tools/Release/release.sh --version X.Y.Z               # a REAL release (0.9.x for the friends beta)
#   Tools/Release/release.sh --walk --version 0.0.N        # a WALK build (R-13r-8 — NEVER published)
#   options:  --out DIR                 (default App/Variorum/DerivedData/release/<mode>-<version>-<UTC>.noindex)
#             --stop-before-appcast     (everything but the one step that reads HER Keychain)
#
# THE ORDER (each step refuses to continue on any failure):
#   0. preflight   clean tree (a release is ONE commit's build) · ZERO Variorum instances (pgrep, by PATH)
#                  · the Sparkle tools verified by digest · the notary credential answers · release mode:
#                  the version is unpublished (no local feed copy, and dl.stargazing.tech answers 404)
#   1. stamp       MARKETING_VERSION = --version · CURRENT_PROJECT_VERSION = `git rev-list --count HEAD`
#                  (R-13r-6's number; command-line overrides, never a build configuration)
#   2. archive + export   archive-and-export.sh: U1's developer-id road, CLEAN by construction; its
#                  verify-export.sh run must PASS with the stamp proven (pre-notarization reading)
#   3. notarize + staple the APP (zipped; Keychain profile VariorumNotary), then verify-export.sh
#                  --require-notarized → Gatekeeper ACCEPTED + the ticket stapled
#   4. DMG         plain `hdiutil` (UDZO, HFS+): Variorum.app + an /Applications link, named EXACTLY
#                  Variorum-<version>.dmg (the site's per-IP rate limit keys on that prefix)
#   5. sign the DMG (Developer ID, secure timestamp)
#   6. notarize + staple the DMG; `spctl -t open` must ACCEPT it
#   7. verify the SHIPPED BYTES: mount the final DMG read-only and run verify-export.sh --require-notarized
#                  on the app inside it, so what is checked is exactly what users get
#   8. dSYMs retained: copied out of the archive with their UUIDs proven equal to the shipped binary's.
#                  Release mode also files them DURABLY under ~/Library/Developer/Variorum/Releases/<version>/
#                  with the build's records (never in DerivedData, which gets swept)
#   9. appcast     make-appcast.sh (it reads HER Keychain; the first run asks her)
#  10. HANDOFF     printed + HANDOFF.txt. RELEASE: SHE carries the DMG and then appcast.xml to the site repo
#                  in the site's PUBLISH-AND-LEAVE order (DMG uploaded and VERIFIED reachable BEFORE the
#                  appcast lands), each leg checked by verify-published.sh. WALK: the local feed's
#                  serve command and a pointer to the staged walk checklist.
#
# Every real-store-id Variorum.app this run makes stays under a .noindex folder and is unregistered from
# LaunchServices (U1's measured hazard). Nothing here launches the app, touches a store, or touches
# /Applications (a --compare-with signature READ of it is all).
#
# Exit: 0 done · 1 a verification failed · 2 usage · 3 preflight refused · 4 notarization failed ·
#       5 archive/export failed · 6 DMG failed · 7 appcast failed.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "${HERE}/../.." && pwd)"
RELEASES="${VARIORUM_RELEASES_DIR:-${HOME}/Library/Developer/Variorum/Releases}"
NOTARY_PROFILE="VariorumNotary"
DMG_HOST_PREFIX="https://dl.stargazing.tech/variorum/"
EXPORT_OPTIONS="${HERE}/ExportOptions.plist"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
PB=/usr/libexec/PlistBuddy

usage() { echo "usage: $0 [--walk] --version X.Y.Z [--out DIR] [--stop-before-appcast]" >&2; exit 2; }
MODE=release; VERSION=""; OUT=""; STOP_BEFORE_APPCAST=""
while [ $# -gt 0 ]; do
  case "$1" in
    --walk) MODE=walk; shift ;;
    --version) [ $# -ge 2 ] || usage; VERSION="$2"; shift 2 ;;
    --out) [ $# -ge 2 ] || usage; OUT="$2"; shift 2 ;;
    --stop-before-appcast) STOP_BEFORE_APPCAST=yes; shift ;;
    *) usage ;;
  esac
done
[ -n "$VERSION" ] || usage
say() { echo "[release] $*"; }
refuse() { echo "REFUSED: $*" >&2; exit 3; }
step() { echo; echo "[release] ===== $* ====="; }

# ------------------------------------------------------------------ 0. preflight
step "0. preflight (${MODE} ${VERSION})"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || refuse "--version must be X.Y.Z (got '${VERSION}')"
if [ "$MODE" = walk ]; then
  [[ "$VERSION" =~ ^0\.0\.[0-9]+$ ]] || refuse "a WALK build's version is 0.0.N, so no walk artifact can ever wear a release number (got ${VERSION})"
else
  [[ "$VERSION" =~ ^0\.0\. ]] && refuse "0.0.x is the WALK range; pass --walk, or choose a release number"
fi
DIRTY="$(git -C "$REPO" status --porcelain | wc -l | tr -d ' ')"
[ "$DIRTY" = "0" ] || refuse "the working tree has ${DIRTY} uncommitted change(s): a ${MODE} build is ONE commit's build (commit first)"
HEAD_SHA="$(git -C "$REPO" rev-parse HEAD)"
BUILD="$(git -C "$REPO" rev-list --count HEAD)"
say "commit ${HEAD_SHA} · build number ${BUILD} (git rev-list --count HEAD — R-13r-6)"
HITS="$(pgrep -fl 'Variorum.app/Contents/MacOS' || true)"
[ -z "$HITS" ] || refuse "a Variorum instance is running (a Release archive runs only at a ZERO-INSTANCE window; quit it by hand — this script never quits or kills one):
$(echo "$HITS" | sed 's/^/    /')"
say "zero Variorum instances"
"${HERE}/fetch-sparkle-tools.sh" >/dev/null || refuse "the Sparkle tools did not verify (Tools/Release/fetch-sparkle-tools.sh)"
say "Sparkle 2.10.0 tools verified by digest"
xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" --output-format json >/dev/null 2>&1 \
  || refuse "the notary credential '${NOTARY_PROFILE}' did not answer (xcrun notarytool history --keychain-profile ${NOTARY_PROFILE})"
say "notary credential '${NOTARY_PROFILE}' answers"
DMG_NAME="Variorum-${VERSION}.dmg"
if [ "$MODE" = release ]; then
  [ ! -e "${RELEASES}/${VERSION}" ] || refuse "${RELEASES}/${VERSION} already exists: ${VERSION} was built for release before (versions are never reused)"
  [ ! -e "${RELEASES}/feed/${DMG_NAME}" ] || refuse "${RELEASES}/feed/${DMG_NAME} already exists (a published name is immutable)"
  CODE="$(curl -sS -o /dev/null -I -w '%{http_code}' "${DMG_HOST_PREFIX}${DMG_NAME}" || echo 000)"
  [ "$CODE" = "404" ] || refuse "${DMG_HOST_PREFIX}${DMG_NAME} answered HTTP ${CODE} (expected 404): it is published or the host cannot confirm it is not. Published names are IMMUTABLE."
  say "${DMG_NAME} is unpublished (the DMG host answers 404) and unbuilt here"
fi
[ -n "$OUT" ] || OUT="${REPO}/App/Variorum/DerivedData/release/${MODE}-${VERSION}-$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${OUT%/}"
case "$OUT" in *.noindex) ;; *) OUT="${OUT}.noindex" ;; esac
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
[ -z "$(ls -A "$OUT")" ] || refuse "${OUT} is not empty (every run builds into a fresh directory)"
say "output: ${OUT}"
CERT="$("$PB" -c 'Print :signingCertificate' "$EXPORT_OPTIONS")"

# ------------------------------------------------------------------ 1–2. stamp + archive + export (U1's road)
step "1–2. stamp ${VERSION} (${BUILD}) + clean Release archive + developer-id export"
set +e
"${HERE}/archive-and-export.sh" --out "${OUT}/build" --version "$VERSION" --build "$BUILD"
AE=$?
set -e
BUILD_DIR="${OUT}/build.noindex"
APPX="${BUILD_DIR}/export/Variorum.app"
[ "$AE" -eq 0 ] || { echo "archive-and-export.sh exited ${AE} (${BUILD_DIR})" >&2; exit 5; }
say "export ${APPX}: the pre-notarization drill PASSED with the stamp proven (${BUILD_DIR}/verify.txt)"

notarize() {   # notarize <file> <label> — submit, wait, keep the JSON result and Apple's log
  local file="$1" label="$2" status id
  say "notarytool submit ${file##*/} (${label}) — waiting for Apple"
  if ! xcrun notarytool submit "$file" --keychain-profile "$NOTARY_PROFILE" --wait --timeout 45m \
         --output-format json > "${OUT}/notary-${label}.json" 2> "${OUT}/notary-${label}.err"; then
    echo "notarytool submit failed (${label}):" >&2; cat "${OUT}/notary-${label}.err" >&2; exit 4
  fi
  status="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("status",""))' "${OUT}/notary-${label}.json")"
  id="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("id",""))' "${OUT}/notary-${label}.json")"
  [ -z "$id" ] || xcrun notarytool log "$id" --keychain-profile "$NOTARY_PROFILE" "${OUT}/notary-${label}-log.json" >/dev/null 2>&1 || true
  if [ "$status" != "Accepted" ]; then
    echo "NOTARIZATION ${status:-unknown} (${label}, id ${id}) — Apple's log: ${OUT}/notary-${label}-log.json" >&2
    [ -f "${OUT}/notary-${label}-log.json" ] && cat "${OUT}/notary-${label}-log.json" >&2
    exit 4
  fi
  local issues
  issues="$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(len(d.get("issues") or []))' "${OUT}/notary-${label}-log.json" 2>/dev/null || echo "?")"
  say "notarization Accepted (${label}, id ${id}; issues in Apple's log: ${issues})"
}

COMPARE=()
[ ! -d /Applications/Variorum.app ] || COMPARE=(--compare-with /Applications/Variorum.app)

# ------------------------------------------------------------------ 3. notarize + staple the APP
step "3. notarize + staple the APP"
ditto -c -k --keepParent "$APPX" "${OUT}/Variorum-app-for-notary.zip"
notarize "${OUT}/Variorum-app-for-notary.zip" app
xcrun stapler staple "$APPX" > "${OUT}/staple-app.txt" 2>&1 || { cat "${OUT}/staple-app.txt" >&2; exit 4; }
xcrun stapler validate "$APPX" >> "${OUT}/staple-app.txt" 2>&1 || { cat "${OUT}/staple-app.txt" >&2; exit 4; }
rm -f "${OUT}/Variorum-app-for-notary.zip"
set +e
"${HERE}/verify-export.sh" "$APPX" ${COMPARE[@]+"${COMPARE[@]}"} --expect-version "$VERSION" --expect-build "$BUILD" \
  --require-notarized > "${OUT}/verify-stapled.txt" 2>&1
V=$?
set -e
grep -E '^(FAIL|VERDICT)|Gatekeeper|stapler' "${OUT}/verify-stapled.txt" || true
[ "$V" -eq 0 ] || { echo "the STAPLED app failed verify-export.sh (${OUT}/verify-stapled.txt)" >&2; exit 1; }

# ------------------------------------------------------------------ 4. the DMG (named EXACTLY)
step "4. hdiutil DMG: ${DMG_NAME}"
ROOT="${OUT}/dmg-root"
mkdir "$ROOT"
ditto "$APPX" "${ROOT}/Variorum.app"
ln -s /Applications "${ROOT}/Applications"
DMG="${OUT}/${DMG_NAME}"
hdiutil create -volname "Variorum" -srcfolder "$ROOT" -fs HFS+ -format UDZO -ov "$DMG" > "${OUT}/hdiutil-create.txt" 2>&1 \
  || { cat "${OUT}/hdiutil-create.txt" >&2; exit 6; }
"$LSREGISTER" -u "${ROOT}/Variorum.app" >/dev/null 2>&1 || true
rm -rf "$ROOT"
say "${DMG} ($(stat -f %z "$DMG") bytes before signing)"

# ------------------------------------------------------------------ 5. sign the DMG
step "5. sign the DMG (Developer ID ${CERT})"
codesign --sign "$CERT" --timestamp "$DMG" > "${OUT}/codesign-dmg.txt" 2>&1 || { cat "${OUT}/codesign-dmg.txt" >&2; exit 6; }
codesign --verify --verbose=2 "$DMG" >> "${OUT}/codesign-dmg.txt" 2>&1 || { cat "${OUT}/codesign-dmg.txt" >&2; exit 6; }
codesign -dvv "$DMG" 2>&1 | grep -E '^(Authority|Timestamp)=' | head -2 | sed 's/^/    /'

# ------------------------------------------------------------------ 6. notarize + staple the DMG
step "6. notarize + staple the DMG"
notarize "$DMG" dmg
xcrun stapler staple "$DMG" > "${OUT}/staple-dmg.txt" 2>&1 || { cat "${OUT}/staple-dmg.txt" >&2; exit 4; }
xcrun stapler validate "$DMG" >> "${OUT}/staple-dmg.txt" 2>&1 || { cat "${OUT}/staple-dmg.txt" >&2; exit 4; }
spctl -a -t open --context context:primary-signature -vv "$DMG" > "${OUT}/spctl-dmg.txt" 2>&1 || true
sed 's/^/    /' "${OUT}/spctl-dmg.txt"
grep -q ': accepted' "${OUT}/spctl-dmg.txt" && grep -q 'source=Notarized Developer ID' "${OUT}/spctl-dmg.txt" \
  || { echo "Gatekeeper does not ACCEPT the DMG as Notarized Developer ID (${OUT}/spctl-dmg.txt)" >&2; exit 1; }
say "the DMG: signed, notarized, stapled, Gatekeeper-accepted"

# ------------------------------------------------------------------ 7. verify the SHIPPED bytes
step "7. verify the app INSIDE the final DMG"
MNT="${OUT}/mnt"
mkdir "$MNT"
hdiutil attach -nobrowse -noautoopen -readonly -mountpoint "$MNT" "$DMG" > "${OUT}/hdiutil-attach.txt" 2>&1 \
  || { cat "${OUT}/hdiutil-attach.txt" >&2; exit 6; }
set +e
"${HERE}/verify-export.sh" "${MNT}/Variorum.app" ${COMPARE[@]+"${COMPARE[@]}"} --expect-version "$VERSION" --expect-build "$BUILD" \
  --require-notarized > "${OUT}/verify-dmg.txt" 2>&1
V=$?
LINK="$(readlink "${MNT}/Applications" || true)"
"$LSREGISTER" -u "${MNT}/Variorum.app" >/dev/null 2>&1
hdiutil detach "$MNT" > /dev/null 2>&1 || hdiutil detach -force "$MNT" > /dev/null 2>&1
set -e
rmdir "$MNT" 2>/dev/null || true
grep -E '^(FAIL|VERDICT)' "${OUT}/verify-dmg.txt" || true
[ "$V" -eq 0 ] || { echo "the app INSIDE the DMG failed verify-export.sh (${OUT}/verify-dmg.txt)" >&2; exit 1; }
[ "$LINK" = "/Applications" ] || { echo "the DMG's Applications link reads '${LINK}'" >&2; exit 1; }
DMG_BYTES="$(stat -f %z "$DMG")"
DMG_SHA="$(shasum -a 256 "$DMG" | cut -d' ' -f1)"
say "shipped bytes verified: ${DMG_NAME} · ${DMG_BYTES} bytes · sha256 ${DMG_SHA}"

# ------------------------------------------------------------------ 8. dSYMs retained (UUIDs proven)
step "8. dSYMs retained"
ditto "${BUILD_DIR}/Variorum.xcarchive/dSYMs" "${OUT}/dSYMs"
SHIP_UUIDS="$(dwarfdump --uuid "${APPX}/Contents/MacOS/Variorum" | awk '{print $2}' | sort)"
DSYM_UUIDS="$(dwarfdump --uuid "${OUT}/dSYMs/Variorum.app.dSYM" | awk '{print $2}' | sort)"
[ -n "$SHIP_UUIDS" ] && [ "$SHIP_UUIDS" = "$DSYM_UUIDS" ] \
  || { echo "the dSYM's UUIDs (${DSYM_UUIDS}) do not match the shipped binary's (${SHIP_UUIDS})" >&2; exit 1; }
say "Variorum.app.dSYM matches the shipped binary: $(echo "$SHIP_UUIDS" | tr '\n' ' ')"
{
  echo "mode:      ${MODE}"
  echo "version:   ${VERSION} (build ${BUILD})"
  echo "commit:    ${HEAD_SHA}"
  echo "dmg:       ${DMG_NAME} · ${DMG_BYTES} bytes · sha256 ${DMG_SHA}"
  echo "uuids:     $(echo "$SHIP_UUIDS" | tr '\n' ' ')"
  echo "built:     $(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "${OUT}/RELEASE-INFO.txt"
cat "${BUILD_DIR}/BUILD-INFO.txt" >> "${OUT}/RELEASE-INFO.txt"
if [ "$MODE" = release ]; then
  RECORD="${RELEASES}/${VERSION}"
  mkdir -p "$RECORD"
  ditto "${OUT}/dSYMs" "${RECORD}/dSYMs"
  cp -p "${OUT}/RELEASE-INFO.txt" "${OUT}"/notary-*.json "${OUT}/verify-stapled.txt" "${OUT}/verify-dmg.txt" "$RECORD/"
  cp -p "${BUILD_DIR}/verify.txt" "${RECORD}/verify-pre-notarization.txt"
  say "DURABLE record (dSYMs + the build's records): ${RECORD}"
fi

# ------------------------------------------------------------------ 9. the appcast (HER Keychain)
if [ -n "$STOP_BEFORE_APPCAST" ]; then
  step "9. appcast — STOPPED BEFORE IT (--stop-before-appcast)"
  say "run when she is at the machine (the first run asks her Keychain):"
  say "  Tools/Release/make-appcast.sh --${MODE} --dmg ${DMG} --version ${VERSION} --build ${BUILD}"
  exit 0
fi
step "9. appcast"
if ! "${HERE}/make-appcast.sh" "--${MODE}" --dmg "$DMG" --version "$VERSION" --build "$BUILD"; then
  # Never re-run release.sh for this version: it would rebuild different bytes under the same name.
  echo "the appcast step failed. RESUME it on the SAME DMG (never rebuild ${VERSION}):" >&2
  echo "  Tools/Release/make-appcast.sh --${MODE} --dmg ${DMG} --version ${VERSION} --build ${BUILD}" >&2
  exit 7
fi

# ------------------------------------------------------------------ 10. the handoff
step "10. HANDOFF"
LEFT="$("$LSREGISTER" -dump 2>/dev/null | grep -c "path: *${OUT}/" || true)"
{
if [ "$MODE" = release ]; then
  FEED="${RELEASES}/feed"
  cat <<EOF
VARIORUM ${VERSION} (build ${BUILD}) — READY TO PUBLISH. SHE carries it to the site repo, whose agent runs
its notes/variorum-releases.md. THE SITE'S PUBLISH-AND-LEAVE ORDER (binding — the site-side report):

  1. THE DMG FIRST:  ${FEED}/${DMG_NAME}
                     ${DMG_BYTES} bytes · sha256 ${DMG_SHA}
     → ${DMG_HOST_PREFIX}${DMG_NAME}   (the name EXACTLY; IMMUTABLE once the appcast references it)
  2. VERIFY it is reachable BEFORE the appcast moves (must print VERDICT: PASS):
     Tools/Release/verify-published.sh dmg ${FEED}/${DMG_NAME}
  3. ONLY THEN the appcast:  ${FEED}/appcast.xml
     → https://stargazing.tech/variorum/appcast.xml
  4. VERIFY the live feed is byte-identical (must print VERDICT: PASS):
     Tools/Release/verify-published.sh appcast ${FEED}/appcast.xml

dSYMs + records retained: ${RELEASES}/${VERSION}/
EOF
else
  FEED="${REPO}/App/Variorum/DerivedData/walk-feed"
  cat <<EOF
WALK BUILD ${VERSION} (build ${BUILD}) — NEVER PUBLISHED. The walk's DMG and the walk feed:
  DMG:   ${DMG}   (${DMG_BYTES} bytes · sha256 ${DMG_SHA})
  feed:  ${FEED}/ (appcast.xml + the walk DMGs; enclosures http://localhost:8765/…)
  serve: cd ${FEED} && python3 -m http.server 8765 --bind 127.0.0.1
The R-13r-8 walk checklist (the 13r plan's U2 RECORD, piece 6) runs it — author-gated.
EOF
fi
echo "LaunchServices registrations left under ${OUT}: ${LEFT:-0}"
} | tee "${OUT}/HANDOFF.txt"
