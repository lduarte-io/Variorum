#!/bin/bash
# archive-and-export.sh — Phase 13r U1: the Developer ID export road (U2 grows it into the full
# pipeline: stamp -> archive -> export -> notarize + staple -> DMG -> appcast).
#
#   Tools/Release/archive-and-export.sh [--out DIR] [--version X.Y.Z --build N]
#
# --version/--build (13r U2 — THE STAMP): MARKETING_VERSION and CURRENT_PROJECT_VERSION are passed to
# `xcodebuild archive` as COMMAND-LINE BUILD-SETTING OVERRIDES — never a new build configuration
# (CLAUDE.md's fence). With GENERATE_INFOPLIST_FILE=YES they become CFBundleShortVersionString and
# CFBundleVersion; verify-export.sh --expect-version/--expect-build proves the export carries them.
# release.sh supplies them (the build number = `git rev-list --count HEAD`, R-13r-6). Without them
# the project's own values build (U1's drill road, unchanged).
#
# DIR defaults to App/Variorum/DerivedData/release/<UTC stamp>.noindex (gitignored) and must NOT
# already hold anything: every run is CLEAN BY CONSTRUCTION (a fresh -derivedDataPath inside DIR —
# stale DerivedData lies about signatures). DIR ALWAYS ends in `.noindex` (appended when missing):
# measured at U1's first run, Spotlight indexed the export and LaunchServices RE-REGISTERED it after
# `lsregister -u` — a real-store-id bundle Spotlight / `open -b` could resolve her app to. Spotlight
# skips `.noindex` folders, and the re-registration stopped (0 registrations after 90 s). It produces
#   DIR/Variorum.xcarchive      the Release archive (development-signed by the project's Automatic style)
#   DIR/export/Variorum.app     the Developer ID export (ExportOptions.plist: manual, one identity, one profile)
#   DIR/verify.txt              verify-export.sh's PASS/FAIL drill over the export (+ the --compare-with
#                               /Applications/Variorum.app identity proof when that build exists)
#   DIR/BUILD-INFO.txt          provenance: the commit, a dirty-tree flag, the toolchain, the date
#
# THE EXPORT IS A RELEASE BUILD = BUNDLE ID io.lduarte.Variorum = THE REAL STORE. This script never
# launches it, and it unregisters every copy it made from LaunchServices so nothing (Spotlight, `open
# -b`, a Dock alias) resolves her app to them. Its first real launch is the U1 live drill behind the
# A1 rail (the 13r plan's U1 RECORD). It runs ONLY at a zero-instance window: it refuses while any
# Variorum instance runs, and it never quits or kills one.
#
# Exit: 0 export built and the drill passed · 1 the drill failed · 2 usage · 3 an instance is running
#       · 4 the signing inputs disagree · 5 archive failed · 6 export failed.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "${HERE}/../.." && pwd)"
PROJECT="${REPO}/App/Variorum/Variorum.xcodeproj"
SCHEME="Variorum"
BUNDLE_ID="io.lduarte.Variorum"
EXPORT_OPTIONS="${HERE}/ExportOptions.plist"
PROFILE_VERSIONED="${HERE}/Variorum_Developer_ID.provisionprofile"
PROFILES_DIR="${HOME}/Library/Developer/Xcode/UserData/Provisioning Profiles"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
PB=/usr/libexec/PlistBuddy

usage() { echo "usage: $0 [--out DIR] [--version X.Y.Z --build N]" >&2; exit 2; }
OUT=""
STAMP_VERSION=""
STAMP_BUILD=""
while [ $# -gt 0 ]; do
  case "$1" in
    --out) [ $# -ge 2 ] || usage; OUT="$2"; shift 2 ;;
    --version) [ $# -ge 2 ] || usage; STAMP_VERSION="$2"; shift 2 ;;
    --build) [ $# -ge 2 ] || usage; STAMP_BUILD="$2"; shift 2 ;;
    *) usage ;;
  esac
done
# The stamp comes whole or not at all: a version without its build number (or the reverse) is a
# half-stamped bundle that Sparkle would compare wrongly.
if [ -n "$STAMP_VERSION" ] || [ -n "$STAMP_BUILD" ]; then
  [[ "$STAMP_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || { echo "REFUSED: --version must be X.Y or X.Y.Z (got '${STAMP_VERSION}')" >&2; exit 2; }
  [[ "$STAMP_BUILD" =~ ^[1-9][0-9]*$ ]] || { echo "REFUSED: --build must be a positive integer (got '${STAMP_BUILD}')" >&2; exit 2; }
fi
STAMP_SETTINGS=()
[ -z "$STAMP_VERSION" ] || STAMP_SETTINGS=("MARKETING_VERSION=${STAMP_VERSION}" "CURRENT_PROJECT_VERSION=${STAMP_BUILD}")
[ -n "$OUT" ] || OUT="${REPO}/App/Variorum/DerivedData/release/$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${OUT%/}"
case "$OUT" in *.noindex) ;; *) OUT="${OUT}.noindex" ;; esac   # Spotlight never indexes the copies
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
if [ -n "$(ls -A "$OUT")" ]; then
  echo "REFUSED: ${OUT} is not empty — every run builds into a fresh directory (clean by construction)." >&2
  exit 2
fi

say() { echo "[archive-and-export] $*"; }

zero_instances() {   # $1 = the step about to run
  local hits
  hits="$(pgrep -fl 'Variorum.app/Contents/MacOS' || true)"
  if [ -n "$hits" ]; then
    echo "REFUSED before ${1}: a Variorum instance is running:" >&2
    echo "$hits" | sed 's/^/    /' >&2
    echo "A Release archive/export runs only at a ZERO-INSTANCE window (13r ENVIRONMENT TRAPS)." >&2
    echo "Quit it by hand and re-run into a fresh --out; this script never quits or kills one." >&2
    exit 3
  fi
  say "zero-instance check before ${1}: no Variorum process (pgrep -fl 'Variorum.app/Contents/MacOS')"
}

# ------------------------------------------------------------------ 0. provenance + the window
HEAD_SHA="$(git -C "$REPO" rev-parse HEAD)"
DIRTY="$(git -C "$REPO" status --porcelain | wc -l | tr -d ' ')"
{
  echo "date (UTC):  $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "commit:      ${HEAD_SHA}"
  echo "dirty files: ${DIRTY}"
  echo "toolchain:   $(xcodebuild -version | tr '\n' ' ')· xcode-select $(xcode-select -p)"
  echo "macOS:       $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
  if [ -n "$STAMP_VERSION" ]; then
    echo "stamp:       MARKETING_VERSION=${STAMP_VERSION} CURRENT_PROJECT_VERSION=${STAMP_BUILD} (command-line overrides)"
  else
    echo "stamp:       none (the project's own MARKETING_VERSION / CURRENT_PROJECT_VERSION)"
  fi
} > "${OUT}/BUILD-INFO.txt"
sed 's/^/    /' "${OUT}/BUILD-INFO.txt"
[ "$DIRTY" = "0" ] || say "WARNING: the working tree has ${DIRTY} uncommitted change(s) — this export is not one commit's build"
zero_instances "the archive"

# ------------------------------------------------------------------ 1. the signing inputs agree
WORK="$(mktemp -d "${TMPDIR:-/tmp}/archive-and-export.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
disagree() { echo "REFUSED: $*" >&2; exit 4; }

security cms -D -i "$PROFILE_VERSIONED" > "${WORK}/profile.plist" 2>/dev/null \
  || disagree "the versioned profile ${PROFILE_VERSIONED} does not decode"
P_UUID="$("$PB" -c 'Print :UUID' "${WORK}/profile.plist")"
P_NAME="$("$PB" -c 'Print :Name' "${WORK}/profile.plist")"
P_APPID="$("$PB" -c 'Print :Entitlements:com.apple.application-identifier' "${WORK}/profile.plist")"
P_EXPIRY="$(plutil -extract ExpirationDate raw -o - "${WORK}/profile.plist")"
O_UUID="$("$PB" -c "Print :provisioningProfiles:${BUNDLE_ID}" "$EXPORT_OPTIONS")"
O_CERT="$("$PB" -c 'Print :signingCertificate' "$EXPORT_OPTIONS" | tr '[:lower:]' '[:upper:]')"
O_METHOD="$("$PB" -c 'Print :method' "$EXPORT_OPTIONS")"

[ "$O_METHOD" = "developer-id" ] || disagree "ExportOptions method is '${O_METHOD}', not developer-id"
[ "$P_UUID" = "$O_UUID" ] || disagree "ExportOptions names profile ${O_UUID}, the versioned file is ${P_UUID}"
[ "$P_APPID" = "${P_APPID%%.*}.${BUNDLE_ID}" ] || disagree "the profile's application-identifier ${P_APPID} is not for ${BUNDLE_ID}"
[[ "$P_EXPIRY" > "$(date -u +%Y-%m-%dT%H:%M:%SZ)" ]] || disagree "the profile expired at ${P_EXPIRY}"
n="$(plutil -extract DeveloperCertificates raw -o - "${WORK}/profile.plist")"
in_profile=""
k=0
while [ "$k" -lt "$n" ]; do
  c="$(plutil -extract "DeveloperCertificates.$k" raw -o - "${WORK}/profile.plist" | base64 -D | shasum -a 1 | cut -d' ' -f1 | tr '[:lower:]' '[:upper:]')"
  [ "$c" = "$O_CERT" ] && in_profile=yes
  k=$((k + 1))
done
[ -n "$in_profile" ] || disagree "ExportOptions' signingCertificate ${O_CERT} is not a certificate the profile embeds"
security find-identity -v -p codesigning > "${WORK}/identities.txt"   # (no `| grep -q` under pipefail)
grep -q "$O_CERT" "${WORK}/identities.txt" || disagree "no valid codesigning identity ${O_CERT} in the Keychain"
say "signing inputs agree: profile '${P_NAME}' ${P_UUID} (expires ${P_EXPIRY}) · identity ${O_CERT} in the Keychain and in the profile · method developer-id"

# ------------------------------------------------------------------ 2. the profile is where xcodebuild looks
# A double-clicked .provisionprofile lands in System Settings' Device Management store, which
# xcodebuild does not read; the export resolves profiles from Xcode's own directory, by UUID.
INSTALLED="${PROFILES_DIR}/${P_UUID}.provisionprofile"
if [ -f "$INSTALLED" ]; then
  cmp -s "$INSTALLED" "$PROFILE_VERSIONED" || disagree "${INSTALLED} exists but differs from the versioned profile"
  say "profile already installed: ${INSTALLED}"
else
  mkdir -p "$PROFILES_DIR"
  cp -p "$PROFILE_VERSIONED" "$INSTALLED"
  say "profile INSTALLED (copied, nothing overwritten): ${INSTALLED}"
fi

# ------------------------------------------------------------------ 3. archive (Release, clean)
say "archiving (Release, fresh derived data) -> ${OUT}/Variorum.xcarchive · log ${OUT}/archive.log"
if ! xcodebuild archive -project "$PROJECT" -scheme "$SCHEME" -configuration Release \
      -destination 'generic/platform=macOS' \
      -archivePath "${OUT}/Variorum.xcarchive" -derivedDataPath "${OUT}/DerivedData" \
      ${STAMP_SETTINGS[@]+"${STAMP_SETTINGS[@]}"} \
      > "${OUT}/archive.log" 2>&1 \
   || ! grep -q '\*\* ARCHIVE SUCCEEDED \*\*' "${OUT}/archive.log"; then
  echo "ARCHIVE FAILED — ${OUT}/archive.log:" >&2
  grep -E 'error:|\*\* ARCHIVE' "${OUT}/archive.log" | sort -u | head -20 >&2 || true
  exit 5
fi
say "** ARCHIVE SUCCEEDED **"
zero_instances "the export"

# ------------------------------------------------------------------ 4. export (Developer ID)
say "exporting (developer-id) -> ${OUT}/export · log ${OUT}/export.log"
if ! xcodebuild -exportArchive -archivePath "${OUT}/Variorum.xcarchive" -exportPath "${OUT}/export" \
      -exportOptionsPlist "$EXPORT_OPTIONS" > "${OUT}/export.log" 2>&1 \
   || ! grep -q '\*\* EXPORT SUCCEEDED \*\*' "${OUT}/export.log"; then
  echo "EXPORT FAILED — ${OUT}/export.log:" >&2
  grep -E 'error|\*\* EXPORT' "${OUT}/export.log" | sort -u | head -20 >&2 || true
  exit 6
fi
say "** EXPORT SUCCEEDED **"

# ------------------------------------------------------------------ 5. nothing resolves her app to these copies
while IFS= read -r app; do
  "$LSREGISTER" -u "$app" >/dev/null 2>&1 || true
  say "LaunchServices: unregistered ${app#"${OUT}"/}"
done < <(find "$OUT" -type d -name 'Variorum.app' -prune)
"$LSREGISTER" -dump > "${WORK}/ls-dump.txt" 2>/dev/null || true
LEFT="$(grep -c "path: *${OUT}/" "${WORK}/ls-dump.txt" || true)"
if [ "${LEFT:-0}" = "0" ]; then
  say "LaunchServices: 0 registrations under ${OUT}"
else
  say "WARNING: LaunchServices still holds ${LEFT} registration(s) under ${OUT} — re-run 'lsregister -u' on them before any launch"
fi

# ------------------------------------------------------------------ 6. the static drill
COMPARE=()
if [ -d /Applications/Variorum.app ]; then COMPARE=(--compare-with /Applications/Variorum.app); fi
say "verify-export.sh ${OUT}/export/Variorum.app ${COMPARE[*]:-} -> ${OUT}/verify.txt"
EXPECT=()
[ -z "$STAMP_VERSION" ] || EXPECT=(--expect-version "$STAMP_VERSION" --expect-build "$STAMP_BUILD")
set +e
"${HERE}/verify-export.sh" "${OUT}/export/Variorum.app" ${COMPARE[@]+"${COMPARE[@]}"} ${EXPECT[@]+"${EXPECT[@]}"} > "${OUT}/verify.txt" 2>&1
VERIFY=$?
set -e
grep -E '^(PASS|FAIL|VERDICT)' "${OUT}/verify.txt" || true
zero_instances "the summary"

echo
say "export:  ${OUT}/export/Variorum.app"
say "archive: ${OUT}/Variorum.xcarchive (dSYMs inside)"
say "DO NOT LAUNCH the export outside the U1 live drill: it is the REAL-STORE build (A1 rail first)."
[ "$VERIFY" -eq 0 ] || exit 1
