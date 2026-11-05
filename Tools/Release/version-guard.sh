#!/bin/bash
# version-guard.sh — VX-779: the PROJECT's marketing version tracks the latest release.
#
# THE SCHEME (R-13r-6's adjudicated reading, notes/plans/phase-13r-distribution.md): the repo's
# MARKETING_VERSION bumps WITH each release, on the Mac app target's two configurations (Debug and
# Release) — the release run's first act is the version-bump commit — so a plain build from main (her
# hand-copied daily drive, a walk's Debug build) wears the latest release's number in About, What's New
# and the support draft. release.sh stamps the SHIPPED bundle by command-line override (its step 1) and
# never writes the project, so nothing noticed when the bump was skipped: 0.10.5 through 1.0.1 shipped
# with the project still reading 0.10.4, and a plain Release build from main reported 0.10.4 under an
# installed 1.0.1 (VX-779).
#
# Read: ONLY the Mac app target ("Variorum"), every configuration it has. Not read, deliberately:
#   · the build NUMBER — R-13r-6 stamps `git rev-list --count HEAD` into every build's CFBundleVersion
#     (App/Variorum/StampBuildNumber.sh), so CURRENT_PROJECT_VERSION in the project is never the number
#     a bundle carries, and a tip build outranking the appcast is the design (R-13r-7);
#   · the test bundles' and the mobile targets' MARKETING_VERSION — not the Mac release's line (the
#     mobile app is its own project, its version its own).
#
#   mac_marketing_version_mismatch PBXPROJ EXPECT
#       → true (0), printing the reason on stdout, when the Mac app target's configurations do not ALL
#         carry MARKETING_VERSION = EXPECT (or Debug/Release is missing, or the project cannot be read);
#         false (1) when they do. Sourced by release.sh's preflight (release mode: EXPECT = --version),
#         the notes-guard.sh precedent: one definition, so the refusal and the check cannot drift.
#
#   Tools/Release/version-guard.sh [--expect X.Y[.Z]] [--repo DIR]
#       → the headless check: read-only, no xcodebuild, no stage. EXPECT defaults to the NEWEST
#         release-notes file's version (App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-<v>.md — a
#         release refuses without one, so the newest is the latest release, or the one being cut, whose
#         notes ride the same commit as its bump). --repo reads another checkout (default: this one).
#         Exit 0 PASS · 1 FAIL · 2 usage.

# mac_marketing_versions PBXPROJ → one "<configuration name><TAB><MARKETING_VERSION>" line per
# configuration of the Mac app target. plutil reads the project's old-style plist; jq is the system's.
mac_marketing_versions() {
  local pbx="$1" json
  [ -f "$pbx" ] || return 1
  json="$(/usr/bin/plutil -convert json -o - "$pbx" 2>/dev/null)" || return 1
  printf '%s' "$json" | /usr/bin/jq -r '
    .objects as $o
    | [$o | to_entries[] | select(.value.isa == "PBXNativeTarget" and .value.name == "Variorum") | .value]
    | if length == 1 then .[0] else error("expected exactly one Mac app target named Variorum") end
    | $o[.buildConfigurationList].buildConfigurations[]
    | $o[.]
    | "\(.name)\t\(.buildSettings.MARKETING_VERSION // "")"' 2>/dev/null
}

mac_marketing_version_mismatch() {
  local pbx="$1" expect="$2" lines name version bad="" seen=" "
  if ! lines="$(mac_marketing_versions "$pbx")" || [ -z "$lines" ]; then
    echo "cannot read the Mac app target's configurations from ${pbx}"
    return 0
  fi
  while IFS=$'\t' read -r name version; do
    [ -n "$name" ] || continue
    seen="${seen}${name} "
    [ "$version" = "$expect" ] || bad="${bad}${bad:+, }${name} reads '${version:-unset}'"
  done <<< "$lines"
  case "$seen" in *" Debug "*) ;; *) bad="${bad}${bad:+, }no Debug configuration" ;; esac
  case "$seen" in *" Release "*) ;; *) bad="${bad}${bad:+, }no Release configuration" ;; esac
  [ -n "$bad" ] || return 1
  echo "the Mac app target's MARKETING_VERSION must read ${expect} in every configuration (${bad}): the version-bump commit comes first at every release (R-13r-6)"
  return 0
}

version_guard_main() {
  local here repo expect="" basis pbx notes_dir newest f v reason
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  repo="$(cd "${here}/../.." && pwd)"
  while [ $# -gt 0 ]; do
    case "$1" in
      --expect) [ $# -ge 2 ] || { version_guard_usage; return 2; }; expect="$2"; shift 2 ;;
      --repo)   [ $# -ge 2 ] || { version_guard_usage; return 2; }; repo="$2"; shift 2 ;;
      *) version_guard_usage; return 2 ;;
    esac
  done
  pbx="${repo}/App/Variorum/Variorum.xcodeproj/project.pbxproj"
  notes_dir="${repo}/App/Variorum/Variorum/Features/WhatsNew"
  if [ -n "$expect" ]; then
    basis="--expect"
  else
    newest=""
    for f in "${notes_dir}"/ReleaseNotes-*.md; do
      [ -e "$f" ] || continue
      v="${f##*/ReleaseNotes-}"; v="${v%.md}"
      [[ "$v" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] && newest="${newest}${v}"$'\n'
    done
    newest="$(printf '%s' "$newest" | sort -V | tail -1)"
    if [ -z "$newest" ]; then
      echo "FAIL  no ReleaseNotes-<version>.md under ${notes_dir}"
      echo "VERDICT: FAIL"
      return 1
    fi
    expect="$newest"
    basis="the newest release notes, ReleaseNotes-${newest}.md"
  fi
  echo "INFO  expected ${expect} (${basis})"
  mac_marketing_versions "$pbx" | while IFS=$'\t' read -r f v; do echo "INFO  Variorum ${f}: MARKETING_VERSION = ${v:-unset}"; done
  if reason="$(mac_marketing_version_mismatch "$pbx" "$expect")"; then
    echo "FAIL  ${reason}"
    echo "VERDICT: FAIL"
    return 1
  fi
  echo "PASS  every configuration of the Mac app target reads MARKETING_VERSION = ${expect}"
  echo "VERDICT: PASS"
  return 0
}

version_guard_usage() { echo "usage: $0 [--expect X.Y[.Z]] [--repo DIR]" >&2; }

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -uo pipefail
  version_guard_main "$@"
  exit $?
fi
