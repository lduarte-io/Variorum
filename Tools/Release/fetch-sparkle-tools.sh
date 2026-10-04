#!/bin/bash
# fetch-sparkle-tools.sh — Phase 13r U2: Sparkle 2.10.0's official command-line tools
# (generate_keys · generate_appcast · sign_update · BinaryDelta), PINNED BY DIGEST.
#
#   Tools/Release/fetch-sparkle-tools.sh          # fetch + verify (idempotent; re-verifies when present)
#   Tools/Release/fetch-sparkle-tools.sh --path   # print the verified bin/ directory, fetching first if needed
#
# WHERE THEY LAND: Tools/Release/vendor/Sparkle-2.10.0/bin/ (gitignored: binaries never enter the repo).
#
# WHY DIGESTS, NOT A SIGNATURE: Sparkle ships these tools AD-HOC signed (CodeDirectory flags
# adhoc,runtime; TeamIdentifier not set — measured 2026-10-04), so no Developer ID vouches for
# them. Their authenticity is the RELEASE ARTIFACT's: the tarball's sha256 below is the digest
# GitHub publishes for the 2.10.0 release asset (uploader Sparkle-Bot), and each tool's sha256 was
# measured BYTE-IDENTICAL to the copy inside the SPM artifact that Xcode verified independently
# (Package.swift at tag 2.10.0, revision eef1a539, pins that zip's checksum 17e28312…, also the
# digest GitHub publishes). Two independently-checksummed roads agree on every byte.
#
# THE ONE CUSTODY RULE (R-13r-1): this script never RUNS any tool. `generate_keys` touches the
# login Keychain of whoever runs it; only the author runs it (HER HANDS step 3 — the 13r plan's
# U2 RECORD carries the staged commands). The release pipeline runs generate_appcast, which reads
# the private key from her Keychain at signing time; nothing here ever writes key material.
#
# Exit: 0 verified · 1 a digest or signature check failed (nothing installed) · 2 usage · 3 download failed.
set -euo pipefail

VERSION="2.10.0"
TARBALL="Sparkle-${VERSION}.tar.xz"
URL="https://github.com/sparkle-project/Sparkle/releases/download/${VERSION}/${TARBALL}"
TARBALL_SHA256="c2bf58aa8387266ac179357b1415d6f2635f044da8be41042af32425dae6da0c"
TOOLS=(generate_keys generate_appcast sign_update BinaryDelta)
tool_sha256() {
  case "$1" in
    generate_keys)    echo "c37679f98d9121981cf7b2d18592fdc8b44931bffa604acf10c9e11791b6222e" ;;
    generate_appcast) echo "59e48e8432433cf4358519027e67e2c66a7348e0fe415f75f67b3b2372c13844" ;;
    sign_update)      echo "43c249771bafc3aa581228abae00731a012d324691b8292860896635050be76b" ;;
    BinaryDelta)      echo "020adbe773efb0e53e4146d805e37a72e9ceee25c993b7ff6c86c4bb4f9f90b3" ;;
    *) return 1 ;;
  esac
}

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="${HERE}/vendor/Sparkle-${VERSION}"
BIN="${DEST}/bin"

PRINT_PATH=""
case "${1:-}" in
  "") ;;
  --path) PRINT_PATH=yes ;;
  *) echo "usage: $0 [--path]" >&2; exit 2 ;;
esac

say() { [ -n "$PRINT_PATH" ] && echo "[fetch-sparkle-tools] $*" >&2 || echo "[fetch-sparkle-tools] $*"; }
sha() { shasum -a 256 "$1" | cut -d' ' -f1; }

verify_bin() {   # $1 = a bin/ directory; 0 when every tool matches its pin and its signature verifies
  local dir="$1" t
  for t in "${TOOLS[@]}"; do
    [ -f "${dir}/${t}" ] || { say "missing ${dir}/${t}"; return 1; }
    [ "$(sha "${dir}/${t}")" = "$(tool_sha256 "$t")" ] || { say "DIGEST MISMATCH: ${dir}/${t}"; return 1; }
    codesign --verify --strict "${dir}/${t}" 2>/dev/null || { say "SIGNATURE does not verify: ${dir}/${t}"; return 1; }
  done
  return 0
}

if [ -d "$BIN" ] && verify_bin "$BIN"; then
  say "present and verified: ${BIN} (Sparkle ${VERSION}; ${#TOOLS[@]} tools match their pinned sha256)"
  [ -z "$PRINT_PATH" ] || echo "$BIN"
  exit 0
fi

WORK="$(mktemp -d "${TMPDIR:-/tmp}/fetch-sparkle-tools.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
say "downloading ${URL}"
curl -fsSL -o "${WORK}/${TARBALL}" "$URL" || { say "DOWNLOAD FAILED"; exit 3; }
got="$(sha "${WORK}/${TARBALL}")"
if [ "$got" != "$TARBALL_SHA256" ]; then
  say "TARBALL DIGEST MISMATCH: got ${got}, pinned ${TARBALL_SHA256} — nothing installed"
  exit 1
fi
say "tarball sha256 matches the pinned release digest (${TARBALL_SHA256})"
mkdir -p "${WORK}/x"
tar -xJf "${WORK}/${TARBALL}" -C "${WORK}/x" ./bin ./LICENSE   # the release's members carry a ./ prefix
verify_bin "${WORK}/x/bin" || { say "the extracted tools failed verification — nothing installed"; exit 1; }
rm -rf "$DEST"
mkdir -p "$DEST"
mv "${WORK}/x/bin" "$BIN"
mv "${WORK}/x/LICENSE" "${DEST}/LICENSE"
verify_bin "$BIN" || { say "post-install verification failed"; exit 1; }
say "installed and verified: ${BIN}"
for t in "${TOOLS[@]}"; do say "  ${t}  sha256 $(tool_sha256 "$t")"; done
[ -z "$PRINT_PATH" ] || echo "$BIN"
