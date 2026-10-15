#!/bin/zsh
# VX-336 U7 window kit — ONE real-client turn. The PROMPT is read from STDIN (claude's
# --allowedTools and --mcp-config are both variadic and would swallow a trailing prompt).
#   turn.sh <leg> "<allowedTools, comma-separated>" [relay]  < prompt.txt
# Writes: <screens>/<leg>.jsonl (stream-json — every message, every tool result as the model
# saw it), <screens>/tee/<leg>-in.jsonl / -out.jsonl (the wire, both ways), logs/<leg>.stderr.
# The config is the runner's scratch file keys/cfg-<leg>.json (OUTSIDE the repo, chmod 600),
# --strict-mcp-config so no user-scope server ever starts; never `claude mcp list`.
set -u
S="${U7_SCRATCH:?set U7_SCRATCH to the runner's scratchpad}"
R="<home>/dev/variorum-vx-336"
U="$R/notes/plans/vx336-screens/u7"
LEG="$1"; TOOLS="$2"; MODE="${3:-tee}"
SHIM="$R/App/Variorum/DerivedData/vx336-u7/Build/Products/Debug/Variorum.app/Contents/MacOS/variorum-mcp"
KIT="$R/notes/plans/fixes/vx-336-u7-kit"
CFG="$S/keys/cfg-$LEG.json"
mkdir -p "$U/tee" "$U/logs" "$S/proj"
[ -s "$S/keys/u7.key" ] || { echo "STOP: no key at $S/keys/u7.key"; exit 2; }
[ -x "$SHIM" ] || { echo "STOP: no shim at $SHIM"; exit 2; }
python3 -I - "$CFG" "$MODE" "$KIT" "$S/keys/u7.key" "$SHIM" "$U/tee/$LEG" <<'PY'
import json, os, sys
cfg, mode, kit, keyfile, shim, tee = sys.argv[1:]
command, args = (("python3", ["-I", kit + "/drop-relay.py"]) if mode == "relay" else (kit + "/tee-shim.sh", []))
server = {"command": command, "args": args,
          "env": {"VARIORUM_MCP_KEY": open(keyfile).read().strip(), "U7_SHIM": shim, "U7_TEE": tee}}
with open(cfg, "w") as handle: json.dump({"mcpServers": {"variorum-dev": server}}, handle)
os.chmod(cfg, 0o600)
PY
cd "$S/proj" || exit 2
claude -p --strict-mcp-config --mcp-config "$CFG" --output-format stream-json --verbose \
  --allowedTools "$TOOLS" > "$U/$LEG.jsonl" 2> "$U/logs/$LEG.stderr"
echo "turn $LEG exit $?"
