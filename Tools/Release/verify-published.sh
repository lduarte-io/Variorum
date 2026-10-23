#!/bin/bash
# verify-published.sh — Phase 13r U2: the two checks of the site's PUBLISH-AND-LEAVE order, from
# this repo's side (the site-side report: DMG first, verified reachable, THEN the appcast).
#
#   Tools/Release/verify-published.sh dmg <local/Variorum-X.Y.Z.dmg>
#       step 2 of the handoff. It downloads https://dl.stargazing.tech/variorum/<that exact name> ONCE
#       (the host's per-IP limit is 10 requests / 10 s on that prefix, so a single GET is well inside
#       it). PASS only when the bytes are IDENTICAL (sha256) to the local DMG the appcast was signed
#       over. It also shows the content-type and cache headers the site promised
#       (application/x-apple-diskimage, immutable).
#   Tools/Release/verify-published.sh appcast <local/appcast.xml>
#       step 4. It fetches https://stargazing.tech/variorum/appcast.xml (no-cache) and requires it
#       BYTE-IDENTICAL to the local appcast.xml. It then re-checks that every enclosure the newest item
#       names answers 200 with its declared length, so publish-and-leave is verified from the other end
#       too.
#
# It reads the network and local files only. It never uploads anything. Exit 0 PASS · 1 FAIL · 2 usage.
set -uo pipefail

FEED_URL="https://stargazing.tech/variorum/appcast.xml"
DMG_HOST_PREFIX="https://dl.stargazing.tech/variorum/"

usage() { echo "usage: $0 dmg <local.dmg> | appcast <local appcast.xml>" >&2; exit 2; }
[ $# -eq 2 ] || usage
KIND="$1"; LOCAL="$2"
[ -f "$LOCAL" ] || { echo "no such file: $LOCAL" >&2; exit 2; }
WORK="$(mktemp -d "${TMPDIR:-/tmp}/verify-published.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
fail=0
ok()  { echo "PASS  $*"; }
bad() { echo "FAIL  $*"; fail=1; }
header() { grep -i "^$1:" "$2" | tail -1 | cut -d' ' -f2- | tr -d '\r'; }

case "$KIND" in
  dmg)
    NAME="$(basename "$LOCAL")"
    [[ "$NAME" =~ ^Variorum-[0-9]+\.[0-9]+(\.[0-9]+)?\.dmg$ ]] || { echo "the DMG must be named Variorum-X.Y[.Z].dmg (got ${NAME})" >&2; exit 2; }
    URL="${DMG_HOST_PREFIX}${NAME}"
    echo "== ${URL}"
    CODE="$(curl -sS -L -D "${WORK}/h" -o "${WORK}/remote.dmg" -w '%{http_code}' "$URL" || echo 000)"
    [ "$CODE" = "200" ] && ok "HTTP 200" || bad "HTTP ${CODE}"
    echo "      content-type: $(header content-type "${WORK}/h") · cache-control: $(header cache-control "${WORK}/h")"
    L="$(shasum -a 256 "$LOCAL" | cut -d' ' -f1)"
    R="$( [ -f "${WORK}/remote.dmg" ] && shasum -a 256 "${WORK}/remote.dmg" | cut -d' ' -f1 )"
    [ "$L" = "$R" ] && ok "the published bytes are IDENTICAL to the local DMG (sha256 ${L})" \
                    || bad "the published bytes DIFFER (local ${L} · remote ${R:-none})"
    ;;
  appcast)
    echo "== ${FEED_URL}"
    CODE="$(curl -sS -H 'Cache-Control: no-cache' -D "${WORK}/h" -o "${WORK}/remote.xml" -w '%{http_code}' "$FEED_URL" || echo 000)"
    [ "$CODE" = "200" ] && ok "HTTP 200" || bad "HTTP ${CODE}"
    echo "      cache-control: $(header cache-control "${WORK}/h")"
    cmp -s "$LOCAL" "${WORK}/remote.xml" && ok "the live appcast is BYTE-IDENTICAL to the local appcast.xml" \
                                       || bad "the live appcast DIFFERS from the local appcast.xml"
    # The newest item's enclosure(s) must already be live: the DMG lands first, always.
    python3 - "$LOCAL" > "${WORK}/enclosures.txt" <<'EOF'
import sys, xml.etree.ElementTree as ET
ns = {"sparkle": "http://www.andymatuschak.org/xml-namespaces/sparkle"}
items = ET.parse(sys.argv[1]).getroot().findall("./channel/item")
def build(i):
    v = i.find("sparkle:version", ns)
    if v is not None and v.text: return int(v.text)
    e = i.find("enclosure")
    return int(e.get("{%s}version" % ns["sparkle"], "0")) if e is not None else 0
if items:
    newest = max(items, key=build)
    for e in newest.findall("enclosure"):
        print(e.get("url"), e.get("length"))
EOF
    while read -r url length; do
      [ -n "$url" ] || continue
      got="$(curl -sS -I -L -o /dev/null -w '%{http_code} %header{content-length}' "$url" 2>/dev/null || echo "000 -")"
      code="${got%% *}"; len="${got#* }"
      if [ "$code" = "200" ] && [ "$len" = "$length" ]; then ok "the newest item's enclosure is live: ${url} (${len} bytes)"
      else bad "the newest item's enclosure is NOT live as declared: ${url} → HTTP ${code}, length ${len} (declared ${length})"; fi
    done < "${WORK}/enclosures.txt"
    ;;
  *) usage ;;
esac
echo "=="
if [ "$fail" -eq 0 ]; then echo "VERDICT: PASS"; exit 0; fi
echo "VERDICT: FAIL"; exit 1
