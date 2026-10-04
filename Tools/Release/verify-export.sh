#!/bin/bash
# verify-export.sh — Phase 13r U1's STATIC DRILL as a re-runnable PASS/FAIL check over a
# Developer-ID export of Variorum (U2 reuses it on every release, after notarize + staple).
#
#   Tools/Release/verify-export.sh <path/to/Variorum.app> [--compare-with <other/Variorum.app>]
#
# It READS signatures and files only: it never launches the app, never touches a store,
# never writes outside a private temp dir. --compare-with reads another build's signature
# (for example her /Applications daily drive) and proves the keychain identity is the SAME:
# the access group is part of a keychain item's identity, so a Developer ID build must carry
# byte-identical groups, in the same order, or every item her current build wrote becomes
# unreachable (KnownIssues: the keychain-access-groups row 13r closes).
#
# Exit 0 = every check passed · 1 = at least one FAIL · 2 = usage error.
set -uo pipefail   # deliberately not -e: every check runs and reports; the verdict counts

TEAM="384925MZJ6"
BUNDLE_ID="io.lduarte.Variorum"
AUTHORITY="Developer ID Application: Lillian Duarte (${TEAM})"
GROUP_DEFAULT="${TEAM}.${BUNDLE_ID}"           # FIRST: items written with no explicit group land here
GROUP_SHARED="${TEAM}.io.lduarte.Variorum.shared"
HERE="$(cd "$(dirname "$0")" && pwd)"
PROFILE_VERSIONED="${HERE}/Variorum_Developer_ID.provisionprofile"
EXPORT_OPTIONS="${HERE}/ExportOptions.plist"
PB=/usr/libexec/PlistBuddy

usage() { echo "usage: $0 <path/to/Variorum.app> [--compare-with <other.app>]" >&2; exit 2; }
[ $# -ge 1 ] || usage
APP="${1%/}"; shift
COMPARE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --compare-with) [ $# -ge 2 ] || usage; COMPARE="${2%/}"; shift 2 ;;
    *) usage ;;
  esac
done
[ -d "$APP" ] || { echo "no such app bundle: $APP" >&2; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/verify-export.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

pass=0; fail=0
ok()   { echo "PASS  $*"; pass=$((pass + 1)); }
bad()  { echo "FAIL  $*"; fail=$((fail + 1)); }
info() { echo "INFO  $*"; }
indent() { sed 's/^/        /'; }
pbget() { "$PB" -c "Print :$2" "$1" 2>/dev/null; }   # pbget <plist> <colon:key:path>
expect_eq() {   # expect_eq <description> <actual> <expected>
  if [ "$2" = "$3" ]; then ok "$1 = $2"; else bad "$1 = '${2}' (expected '${3}')"; fi
}

echo "== verify-export: ${APP}"
info "date (UTC) $(date -u +%Y-%m-%dT%H:%M:%SZ) · $(xcodebuild -version 2>/dev/null | tr '\n' ' ')· macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion))"

# ---------------------------------------------------------------- A. the bundle
INFO_PLIST="${APP}/Contents/Info.plist"
expect_eq "CFBundleIdentifier" "$(pbget "$INFO_PLIST" CFBundleIdentifier)" "$BUNDLE_ID"
EXE_NAME="$(pbget "$INFO_PLIST" CFBundleExecutable)"
EXE="${APP}/Contents/MacOS/${EXE_NAME}"
info "version $(pbget "$INFO_PLIST" CFBundleShortVersionString) (build $(pbget "$INFO_PLIST" CFBundleVersion)) · executable ${EXE_NAME} · archs $(lipo -archs "$EXE" 2>/dev/null) · LSMinimumSystemVersion $(pbget "$INFO_PLIST" LSMinimumSystemVersion)"

# ---------------------------------------------------------------- B. the seal is valid
echo "-- codesign --verify --deep --strict --verbose=2"
if codesign --verify --deep --strict --verbose=2 "$APP" > "$WORK/verify.txt" 2>&1; then
  ok "codesign --verify --deep --strict"
else
  bad "codesign --verify --deep --strict"
fi
indent < "$WORK/verify.txt"

# ---------------------------------------------------------------- C. who signed it, and how
echo "-- codesign -dvvv"
codesign -dvvv "$APP" > "$WORK/sig.txt" 2>&1
grep -E '^(Identifier|Format|CodeDirectory|Authority|Timestamp|Signed Time|TeamIdentifier|Runtime Version)=' "$WORK/sig.txt" \
  | sed -E 's/^(CodeDirectory v=[0-9]+ size=[0-9]+ flags=[^ ]+).*/\1/' | indent
expect_eq "signed Identifier" "$(sed -n 's/^Identifier=//p' "$WORK/sig.txt")" "$BUNDLE_ID"
expect_eq "TeamIdentifier" "$(sed -n 's/^TeamIdentifier=//p' "$WORK/sig.txt")" "$TEAM"
expect_eq "leaf Authority" "$(sed -n 's/^Authority=//p' "$WORK/sig.txt" | head -1)" "$AUTHORITY"
if grep -qx 'Authority=Developer ID Certification Authority' "$WORK/sig.txt" \
   && grep -qx 'Authority=Apple Root CA' "$WORK/sig.txt"; then
  ok "chain: Developer ID Certification Authority -> Apple Root CA"
else
  bad "chain: expected Developer ID Certification Authority -> Apple Root CA"
fi
if grep -qE '^CodeDirectory .*flags=0x[0-9a-f]+\([^)]*runtime' "$WORK/sig.txt"; then
  ok "HARDENED RUNTIME (CodeDirectory flags carry 'runtime')"
else
  bad "HARDENED RUNTIME missing from the CodeDirectory flags"
fi
if grep -q '^Timestamp=' "$WORK/sig.txt"; then
  ok "secure timestamp present ($(sed -n 's/^Timestamp=//p' "$WORK/sig.txt"))"
else
  bad "no secure timestamp (notarization requires one)"
fi

# ---------------------------------------------------------------- D. the entitlements
echo "-- codesign -d --entitlements - --xml"
ENT="$WORK/entitlements.plist"
codesign -d --entitlements - --xml "$APP" > "$ENT" 2>/dev/null
if plutil -lint -s "$ENT" >/dev/null 2>&1; then
  plutil -p "$ENT" | indent
  expect_eq "com.apple.security.app-sandbox" "$(pbget "$ENT" com.apple.security.app-sandbox)" "true"
  expect_eq "keychain-access-groups[0] (the default group, FIRST)" "$(pbget "$ENT" keychain-access-groups:0)" "$GROUP_DEFAULT"
  expect_eq "keychain-access-groups[1] (the shared group)" "$(pbget "$ENT" keychain-access-groups:1)" "$GROUP_SHARED"
  if pbget "$ENT" keychain-access-groups:2 >/dev/null; then
    bad "keychain-access-groups carries MORE than the two groups: $(pbget "$ENT" keychain-access-groups:2) ..."
  else
    ok "keychain-access-groups carries exactly two groups"
  fi
  expect_eq "com.apple.application-identifier" "$(pbget "$ENT" com.apple.application-identifier)" "${TEAM}.${BUNDLE_ID}"
  expect_eq "com.apple.developer.team-identifier" "$(pbget "$ENT" com.apple.developer.team-identifier)" "$TEAM"
  GTA="$(pbget "$ENT" com.apple.security.get-task-allow)"
  if [ -z "$GTA" ] || [ "$GTA" = "false" ]; then
    ok "com.apple.security.get-task-allow absent/false (notarization rejects true)"
  else
    bad "com.apple.security.get-task-allow = ${GTA} (notarization rejects it)"
  fi
  # The set Variorum.entitlements + the target's ENABLE_* settings carry today, re-proven on the
  # Developer ID road (U2 adds its own expectations; extra keys are listed, never failed).
  for key in com.apple.security.network.client \
             com.apple.security.files.user-selected.read-write \
             com.apple.security.files.bookmarks.app-scope; do
    expect_eq "$key (carried)" "$(pbget "$ENT" "$key")" "true"
  done
else
  bad "the entitlements dump is not a readable plist"
fi

# ---------------------------------------------------------------- E. the embedded profile authorizes them
echo "-- Contents/embedded.provisionprofile (security cms -D -i)"
EMB="${APP}/Contents/embedded.provisionprofile"
PROF="$WORK/profile.plist"
if [ -f "$EMB" ] && security cms -D -i "$EMB" > "$PROF" 2>/dev/null; then
  ok "embedded.provisionprofile present and decodes"
  for k in Name UUID TeamIdentifier:0 Platform:0 ProvisionsAllDevices; do
    echo "        $k = $(pbget "$PROF" "$k")"
  done
  echo "        Entitlements:"
  "$PB" -c "Print :Entitlements" "$PROF" 2>/dev/null | indent | indent
  if [ -f "$PROFILE_VERSIONED" ] && cmp -s "$EMB" "$PROFILE_VERSIONED"; then
    ok "embedded profile is BYTE-IDENTICAL to Tools/Release/Variorum_Developer_ID.provisionprofile"
  else
    bad "embedded profile differs from the versioned Tools/Release/Variorum_Developer_ID.provisionprofile"
  fi
  expect_eq "profile TeamIdentifier" "$(pbget "$PROF" TeamIdentifier:0)" "$TEAM"
  expect_eq "profile Platform" "$(pbget "$PROF" Platform:0)" "OSX"
  expect_eq "profile ProvisionsAllDevices (a Developer ID profile)" "$(pbget "$PROF" ProvisionsAllDevices)" "true"
  EXPIRY="$(plutil -extract ExpirationDate raw -o - "$PROF" 2>/dev/null)"
  NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [ -n "$EXPIRY" ] && [[ "$EXPIRY" > "$NOW" ]]; then ok "profile unexpired (ExpirationDate ${EXPIRY})"; else bad "profile EXPIRED or unreadable (ExpirationDate '${EXPIRY}')"; fi
  expect_eq "profile application-identifier = the signed one" \
    "$(pbget "$PROF" Entitlements:com.apple.application-identifier)" "$(pbget "$ENT" com.apple.application-identifier)"
  expect_eq "profile team-identifier = the signed one" \
    "$(pbget "$PROF" Entitlements:com.apple.developer.team-identifier)" "$(pbget "$ENT" com.apple.developer.team-identifier)"
  # Every SIGNED keychain group must match one of the profile's patterns (TEAMID.* is a prefix wildcard).
  i=0
  while g="$(pbget "$ENT" "keychain-access-groups:$i")"; do
    matched=""
    j=0
    while p="$(pbget "$PROF" "Entitlements:keychain-access-groups:$j")"; do
      case "$p" in
        *\*) [ "${g#"${p%\*}"}" != "$g" ] && matched="$p" ;;
        *)   [ "$g" = "$p" ] && matched="$p" ;;
      esac
      [ -n "$matched" ] && break
      j=$((j + 1))
    done
    if [ -n "$matched" ]; then ok "profile AUTHORIZES signed group ${g} (by '${matched}')"; else bad "profile does NOT authorize signed group ${g}"; fi
    i=$((i + 1))
  done
  [ "$i" -gt 0 ] || bad "no signed keychain-access-groups to authorize"
  # The signing leaf must be the certificate the profile embeds (and the one ExportOptions names).
  codesign -d --extract-certificates="$WORK/cert" "$APP" >/dev/null 2>&1
  LEAF="$(shasum -a 1 "$WORK/cert0" 2>/dev/null | cut -d' ' -f1 | tr '[:lower:]' '[:upper:]')"
  n="$(plutil -extract DeveloperCertificates raw -o - "$PROF" 2>/dev/null)"
  inprof=""
  k=0
  while [ "$k" -lt "${n:-0}" ]; do
    c="$(plutil -extract "DeveloperCertificates.$k" raw -o - "$PROF" | base64 -D | shasum -a 1 | cut -d' ' -f1 | tr '[:lower:]' '[:upper:]')"
    [ "$c" = "$LEAF" ] && inprof=yes
    k=$((k + 1))
  done
  if [ -n "$LEAF" ] && [ -n "$inprof" ]; then ok "signing leaf SHA-1 ${LEAF} is a DeveloperCertificate of the profile"; else bad "signing leaf SHA-1 '${LEAF}' is NOT among the profile's ${n:-0} DeveloperCertificates"; fi
  if [ -f "$EXPORT_OPTIONS" ]; then
    expect_eq "signing leaf SHA-1 = ExportOptions signingCertificate" "$LEAF" "$(pbget "$EXPORT_OPTIONS" signingCertificate)"
    expect_eq "embedded profile UUID = ExportOptions provisioningProfiles[${BUNDLE_ID}]" \
      "$(pbget "$PROF" UUID)" "$("$PB" -c "Print :provisioningProfiles:${BUNDLE_ID}" "$EXPORT_OPTIONS" 2>/dev/null)"
  fi
else
  bad "Contents/embedded.provisionprofile missing or undecodable (keychain-access-groups on Developer ID REQUIRES it)"
fi

# ---------------------------------------------------------------- F. nested code (notarization: every executable)
echo "-- nested code"
nested=0
while IFS= read -r f; do
  [ "$f" = "$EXE" ] && continue
  case "$(file -b "$f")" in *Mach-O*) ;; *) continue ;; esac
  nested=$((nested + 1))
  codesign -dvv "$f" > "$WORK/nested.txt" 2>&1
  rel="${f#"$APP"/}"
  if grep -qE 'flags=0x[0-9a-f]+\([^)]*runtime' "$WORK/nested.txt" && grep -q '^Timestamp=' "$WORK/nested.txt" \
     && [ "$(sed -n 's/^Authority=//p' "$WORK/nested.txt" | head -1)" = "$AUTHORITY" ]; then
    ok "nested ${rel}: Developer ID + hardened runtime + timestamp"
  else
    bad "nested ${rel}: needs Developer ID + hardened runtime + timestamp"
  fi
done < <(find "$APP/Contents" -type f \( -perm -u+x -o -name '*.dylib' \) 2>/dev/null)
[ "$nested" -gt 0 ] || info "no nested Mach-O code (the Swift packages link statically into the main executable)"

# ---------------------------------------------------------------- G. Gatekeeper's reading
echo "-- spctl --assess --type execute -vv"
spctl --assess --type execute -vv "$APP" > "$WORK/spctl.txt" 2>&1
indent < "$WORK/spctl.txt"
if grep -q ': accepted' "$WORK/spctl.txt"; then
  ok "Gatekeeper ACCEPTS (notarized: $(sed -n 's/^source=//p' "$WORK/spctl.txt"))"
elif grep -q ': rejected' "$WORK/spctl.txt" && grep -q '^source=Unnotarized Developer ID' "$WORK/spctl.txt"; then
  ok "Gatekeeper reads a valid Developer ID signature, rejected ONLY for notarization (expected before U2's notarize + staple)"
else
  bad "Gatekeeper's reading is neither 'accepted' nor 'Unnotarized Developer ID'"
fi

# ---------------------------------------------------------------- I. same keychain identity as another build
if [ -n "$COMPARE" ]; then
  echo "-- compare with ${COMPARE} (read-only signature read)"
  OTHER="$WORK/other-entitlements.plist"
  codesign -d --entitlements - --xml "$COMPARE" > "$OTHER" 2>/dev/null
  info "other build: $(codesign -dvv "$COMPARE" 2>&1 | sed -n 's/^Authority=//p' | head -1) · $(pbget "${COMPARE}/Contents/Info.plist" CFBundleIdentifier)"
  a="$("$PB" -c "Print :keychain-access-groups" "$ENT" 2>/dev/null)"
  b="$("$PB" -c "Print :keychain-access-groups" "$OTHER" 2>/dev/null)"
  printf '%s\n' "$b" | indent
  if [ -n "$a" ] && [ "$a" = "$b" ]; then
    ok "keychain-access-groups BYTE-IDENTICAL, same order, to ${COMPARE}"
  else
    bad "keychain-access-groups DIFFER from ${COMPARE}"
  fi
  expect_eq "application-identifier matches ${COMPARE}" \
    "$(pbget "$ENT" com.apple.application-identifier)" "$(pbget "$OTHER" com.apple.application-identifier)"
  echo "        entitlement keys, this build vs the other (diff; '<' this · '>' other):"
  diff <(plutil -p "$ENT") <(plutil -p "$OTHER") | indent | indent || true
fi

# ---------------------------------------------------------------- verdict
total=$((pass + fail))
echo "=="
if [ "$fail" -eq 0 ]; then
  echo "VERDICT: PASS — ${pass} of ${total} checks"
  exit 0
fi
echo "VERDICT: FAIL — ${fail} of ${total} checks failed"
exit 1
