#!/bin/bash
# make-appcast.sh — Phase 13r U2: THE APPCAST STEP of the release pipeline. It is separable because it is
# the ONE step that reads HER Keychain: generate_appcast signs each new DMG with the EdDSA private key
# `generate_keys` stored there (R-13r-1). The FIRST run on a machine makes macOS ask HER: "generate_appcast
# wants to use your confidential information stored in 'https://sparkle-project.org'". She enters her
# login password, then Allow (or Always Allow). A tools upgrade (a new ad-hoc cdhash) asks again.
#
#   Tools/Release/make-appcast.sh --release --dmg PATH --version X.Y.Z --build N --notes MD [--feed-dir DIR]
#   Tools/Release/make-appcast.sh --walk    --dmg PATH --version 0.0.N --build N [--notes MD] [--feed-dir DIR] [--port P]
#
# THE RELEASE NOTES (U3-A — the ONE source; the in-app What's New reads the same file from the bundle):
# --notes copies App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-<version>.md into the feed as
# Variorum-<version>.md, beside its DMG, and generate_appcast --embed-release-notes embeds it in the item
# as <description sparkle:format="markdown"> (Sparkle 2.10.0's update alert renders Markdown natively —
# read from its source). The notes STAY in the feed directory: generate_appcast re-embeds every item from
# the files beside the DMGs at each run, and an item whose notes file is missing loses its description.
# Release mode REQUIRES --notes; an existing notes file with DIFFERENT bytes is refused (a published item's
# notes change only by a deliberate hand edit of the feed copy, never silently).
#
# THE TWO FEEDS NEVER MIX:
#   --release  feed dir  $VARIORUM_RELEASES_DIR/feed (default ~/Library/Developer/Variorum/Releases/feed):
#              every PUBLISHED DMG + appcast.xml. generate_appcast re-uses the existing appcast.xml and
#              adds the new item. Enclosure prefix https://dl.stargazing.tech/variorum/ (the LOCKED DMG
#              host, the site-side report).
#   --walk     feed dir  App/Variorum/DerivedData/walk-feed (gitignored). Enclosure prefix
#              http://localhost:<port>/ (default 8765). The R-13r-8 walk serves this directory from HER
#              session (localhost is machine-wide, so the walk account reaches it). ATS allows plain HTTP
#              to loopback, MEASURED at U2 piece 5 (the 13r plan's U2 RECORD). Never published.
#
# --maximum-deltas 0, always: the site's handoff is "appcast.xml + the DMG". Delta files would be extra
# uploads the site's publish-and-leave rule does not carry.
#
# After generate_appcast it cleans up after itself. generate_appcast EXTRACTS each archive into
# ~/Library/Caches/Sparkle_generate_appcast, which leaves a real-store-id Variorum.app there: the very
# LaunchServices/Spotlight hazard U1 measured. So every Variorum.app under that cache is unregistered and
# its cache entry removed. Other apps' cache entries are untouched.
#
# Then verify-appcast.swift proves the new item is exactly what a shipped Variorum accepts. That includes
# the EdDSA signature verifying under the BAKED SUPublicEDKey, checked by CryptoKit, independently of
# Sparkle.
#
# Exit: 0 appcast written and verified · 1 verification failed · 2 usage · 3 refused (immutability,
#       a mixed feed, an unstapled DMG) · 4 generate_appcast failed.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "${HERE}/../.." && pwd)"
RELEASES="${VARIORUM_RELEASES_DIR:-${HOME}/Library/Developer/Variorum/Releases}"
RELEASE_PREFIX="https://dl.stargazing.tech/variorum/"
# F2 (ladder round 1): the verification key is READ FROM THE ONE BAKED SOURCE — the partial
# Info.plist whose SUPublicEDKey ships in every bundle — never a duplicated literal (this file
# carried the THIRD copy; a rotation that missed it could verify an appcast under a key no
# shipped install holds). verify-export.sh's literal STAYS: it is the opposite-direction
# tripwire, checking the plist AGAINST an independent constant.
BAKED_PLIST="${REPO}/App/Variorum/VariorumInfo.plist"
ED_PUBLIC_KEY="$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "$BAKED_PLIST" 2>/dev/null || true)"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
GA_CACHE="${HOME}/Library/Caches/Sparkle_generate_appcast"

usage() { echo "usage: $0 (--release|--walk) --dmg PATH --version V --build N [--notes MD] [--feed-dir DIR] [--port P]" >&2; exit 2; }
MODE=""; DMG=""; VERSION=""; BUILD=""; FEED=""; PORT="8765"; NOTES=""
while [ $# -gt 0 ]; do
  case "$1" in
    --release) MODE=release; shift ;;
    --walk) MODE=walk; shift ;;
    --dmg) [ $# -ge 2 ] || usage; DMG="$2"; shift 2 ;;
    --version) [ $# -ge 2 ] || usage; VERSION="$2"; shift 2 ;;
    --build) [ $# -ge 2 ] || usage; BUILD="$2"; shift 2 ;;
    --feed-dir) [ $# -ge 2 ] || usage; FEED="$2"; shift 2 ;;
    --port) [ $# -ge 2 ] || usage; PORT="$2"; shift 2 ;;
    --notes) [ $# -ge 2 ] || usage; NOTES="$2"; shift 2 ;;
    *) usage ;;
  esac
done
[ -n "$MODE" ] && [ -n "$DMG" ] && [ -n "$VERSION" ] && [ -n "$BUILD" ] || usage
say() { echo "[make-appcast] $*"; }
refuse() { echo "REFUSED: $*" >&2; exit 3; }

# ------------------------------------------------------------------ the inputs agree
# F2: a 44-character base64 Ed25519 public key, or nothing was read — refuse before any work
# (verify-appcast would exit 2 on a malformed key anyway; this names the real cause).
[[ "$ED_PUBLIC_KEY" =~ ^[A-Za-z0-9+/]{43}=$ ]] \
  || refuse "no SUPublicEDKey read from ${BAKED_PLIST} (got '${ED_PUBLIC_KEY}') — the appcast is verified under the SHIPPED key, which lives there"
[[ "$BUILD" =~ ^[1-9][0-9]*$ ]] || refuse "--build must be a positive integer (got '${BUILD}')"
case "$MODE" in
  release)
    [[ "$VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || refuse "--version must be X.Y or X.Y.Z (got '${VERSION}')"
    [[ "$VERSION" =~ ^0\.0(\.|$) ]] && refuse "0.0.x is the WALK range; a release never carries it"
    [ -n "$FEED" ] || FEED="${RELEASES}/feed"
    [ -n "$NOTES" ] || refuse "a release REQUIRES --notes (the version's ReleaseNotes-<version>.md — What's New and the appcast read the one source)"
    PREFIX="$RELEASE_PREFIX" ;;
  walk)
    [[ "$VERSION" =~ ^0\.0\.[0-9]+$ ]] || refuse "a walk build's version is 0.0.N (got '${VERSION}'), so no walk artifact can ever wear a release number"
    [[ "$PORT" =~ ^[0-9]+$ ]] || refuse "--port must be a number"
    [ -n "$FEED" ] || FEED="${REPO}/App/Variorum/DerivedData/walk-feed"
    PREFIX="http://localhost:${PORT}/" ;;
esac
NAME="Variorum-${VERSION}.dmg"
[ -f "$DMG" ] || refuse "no such DMG: ${DMG}"
[ "$(basename "$DMG")" = "$NAME" ] || refuse "the DMG must be named EXACTLY ${NAME} (the site's rate limit keys on that prefix), got $(basename "$DMG")"
xcrun stapler validate "$DMG" >/dev/null 2>&1 || refuse "${DMG} carries no valid stapled notarization ticket: never put an unstapled DMG in a feed"
mkdir -p "$FEED"
FEED="$(cd "$FEED" && pwd)"
if [ "$MODE" = release ]; then
  case "$FEED" in *walk*) refuse "the release feed may not be a walk directory (${FEED})" ;; esac
  if ls "$FEED"/Variorum-0.0.*.dmg >/dev/null 2>&1; then refuse "${FEED} holds a WALK DMG: the feeds never mix"; fi
elif [ -d "${RELEASES}/feed" ] && [ "$FEED" = "$(cd "${RELEASES}/feed" && pwd)" ]; then
  refuse "a walk build may not enter the RELEASE feed"
fi

# ------------------------------------------------------------------ the DMG joins the feed (immutable names)
if [ -e "${FEED}/${NAME}" ]; then
  cmp -s "$DMG" "${FEED}/${NAME}" || refuse "${FEED}/${NAME} already exists with DIFFERENT bytes. A published DMG name is IMMUTABLE once an appcast references it (the site-side report): cut a new version instead."
  say "${NAME} already in the feed, byte-identical: re-generating only"
else
  cp -p "$DMG" "${FEED}/${NAME}"
  say "${NAME} copied into the ${MODE} feed: ${FEED}"
fi

# ------------------------------------------------------------------ the release notes join it (U3-A)
NOTES_NAME="Variorum-${VERSION}.md"
if [ -n "$NOTES" ]; then
  [ -s "$NOTES" ] || refuse "no such notes file (or empty): ${NOTES}"
  if [ -e "${FEED}/${NOTES_NAME}" ]; then
    cmp -s "$NOTES" "${FEED}/${NOTES_NAME}" || refuse "${FEED}/${NOTES_NAME} already exists with DIFFERENT text — a published item's notes change only by a deliberate hand edit of that copy"
  else
    cp -p "$NOTES" "${FEED}/${NOTES_NAME}"
    say "${NOTES_NAME} copied beside its DMG (embedded as the item's Markdown description)"
  fi
fi

# ------------------------------------------------------------------ generate_appcast (reads HER Keychain)
BIN="$("${HERE}/fetch-sparkle-tools.sh" --path)"
LOG="${FEED}/generate_appcast-${VERSION}.log"
say "generate_appcast --maximum-deltas 0 --embed-release-notes --download-url-prefix ${PREFIX} ${FEED}"
say "(it reads the EdDSA private key from HER login Keychain; the first run on this machine asks her: login password, then Allow)"
if ! "${BIN}/generate_appcast" --maximum-deltas 0 --embed-release-notes --download-url-prefix "$PREFIX" "$FEED" > "$LOG" 2>&1; then
  echo "generate_appcast FAILED — ${LOG}:" >&2
  tail -20 "$LOG" >&2
  exit 4
fi
sed 's/^/    /' "$LOG"

# ------------------------------------------------------------------ hygiene: no real-store-id copy left in its cache
if [ -d "$GA_CACHE" ]; then
  while IFS= read -r app; do
    "$LSREGISTER" -u "$app" >/dev/null 2>&1 || true
    entry="${app#"${GA_CACHE}"/}"; entry="${GA_CACHE}/${entry%%/*}"
    rm -rf "$entry"
    say "generate_appcast's cache: unregistered + removed the extracted copy ($(basename "$entry"))"
  done < <(find "$GA_CACHE" -maxdepth 4 -type d -name 'Variorum.app' -prune 2>/dev/null)
fi

# ------------------------------------------------------------------ prove the item
WORK="$(mktemp -d "${TMPDIR:-/tmp}/make-appcast.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
xcrun swiftc -O -o "${WORK}/verify-appcast" "${HERE}/verify-appcast.swift" 2>"${WORK}/swiftc.err" \
  || { cat "${WORK}/swiftc.err" >&2; echo "could not compile verify-appcast.swift" >&2; exit 1; }
set +e
"${WORK}/verify-appcast" "${FEED}/appcast.xml" "${FEED}/${NAME}" "$PREFIX" "$VERSION" "$BUILD" "$ED_PUBLIC_KEY" \
  "${NOTES:+${FEED}/${NOTES_NAME}}" \
  | tee "${FEED}/verify-appcast-${VERSION}.txt"
VERIFY=${PIPESTATUS[0]}
set -e
[ "$VERIFY" -eq 0 ] || { echo "the appcast item FAILED verification. Do NOT publish." >&2; exit 1; }
say "appcast: ${FEED}/appcast.xml · DMG: ${FEED}/${NAME} ($(stat -f %z "${FEED}/${NAME}") bytes)"
