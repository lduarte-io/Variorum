#!/bin/zsh
# VX-336 U7 window kit — the scratch config's command for an ordinary turn: the product's
# shim, both directions tee'd line for line (U6's tee/<leg>-in.jsonl / -out.jsonl shape).
# Env (set by turn.sh in the config): U7_SHIM (the shim's absolute path), U7_TEE (the tee
# prefix), VARIORUM_MCP_KEY (the shim's own key — never echoed here).
P="${U7_TEE:?U7_TEE unset}"
tee -a "$P-in.jsonl" | "${U7_SHIM:?U7_SHIM unset}" | tee -a "$P-out.jsonl"
