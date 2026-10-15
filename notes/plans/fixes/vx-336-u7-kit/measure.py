# VX-336 U7 window kit — WHAT THE MODEL SAW, call by call (the cap measurement, OWED 5).
#   python3 -I measure.py <leg>
# Pairs each mcp__variorum-dev__ tool_use in <screens>/<leg>.jsonl (stream-json) with the
# tools/call the tee recorded (tee/<leg>-in.jsonl, in order) and the server's answer
# (tee/<leg>-out.jsonl, by id), and prints per call: the server's answer size, the size of
# the tool_result the MODEL received, and INLINE (the same text arrived) or NOT-INLINE (with
# the first 300 characters of what arrived instead — a saved-to-file notice, a truncation, an
# error). For read_note pages: blocks, block_count, next_cursor, the page's take-text characters.
# The context growth after each result (from the API usage) is printed as an APPROXIMATE token
# cost (it includes the previous assistant message's own output). Writes <leg>-measure.txt too.
import json, os, sys

U = "<home>/dev/variorum-vx-336/notes/plans/vx336-screens/u7"
leg = sys.argv[1]

def lines(path):
    if not os.path.exists(path): return []
    out = []
    for raw in open(path, encoding="utf-8", errors="replace"):
        raw = raw.strip()
        if raw:
            try: out.append(json.loads(raw))
            except Exception: pass
    return out

def text_of(content):
    if isinstance(content, str): return content
    if isinstance(content, list):
        return "".join(c.get("text", "") for c in content if isinstance(c, dict) and c.get("type") == "text")
    return ""

events = lines(f"{U}/{leg}.jsonl")
model, uses, order, results, usage, last_msg = None, {}, [], {}, [], None
for e in events:
    if e.get("type") == "system" and e.get("subtype") == "init": model = e.get("model")
    if e.get("type") == "assistant":
        m = e.get("message", {})
        u = m.get("usage") or {}
        ctx = sum(u.get(k, 0) or 0 for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
        if m.get("id") != last_msg:
            usage.append([m.get("id"), ctx, u.get("output_tokens", 0) or 0, []]); last_msg = m.get("id")
        else:
            usage[-1][1], usage[-1][2] = ctx, u.get("output_tokens", 0) or 0
        for c in m.get("content", []) or []:
            if c.get("type") == "tool_use":
                uses[c["id"]] = (c.get("name", ""), c.get("input", {})); order.append(c["id"]); usage[-1][3].append(c["id"])
    if e.get("type") == "user":
        for c in (e.get("message", {}).get("content") or []):
            if isinstance(c, dict) and c.get("type") == "tool_result":
                results[c.get("tool_use_id")] = text_of(c.get("content"))

calls = [m for m in lines(f"{U}/tee/{leg}-in.jsonl") if m.get("method") == "tools/call"]
answers = {m.get("id"): m for m in lines(f"{U}/tee/{leg}-out.jsonl") if "id" in m and "method" not in m}
mcp = [u for u in order if uses[u][0].startswith("mcp__variorum-dev__")]

def context_after(use_id):
    for i, (_, ctx, out, ids) in enumerate(usage):
        if use_id in ids and i + 1 < len(usage):
            return usage[i + 1][1] - ctx, out
    return None, None

report = [f"leg {leg} · model {model} · {len(mcp)} MCP calls in the stream · {len(calls)} tools/call on the wire"]
for n, use_id in enumerate(mcp):
    name, args = uses[use_id]
    call = calls[n] if n < len(calls) else {}
    wire_name = call.get("params", {}).get("name")
    answer = answers.get(call.get("id"), {}).get("result", {})
    server = text_of(answer.get("content"))
    seen = results.get(use_id)
    shown = {k: (v[:12] + "…" if isinstance(v, str) and len(v) > 16 else v) for k, v in (args or {}).items()
             if k not in ("text", "blocks", "expected_text")}
    verdict = "NO-RESULT (the turn ended first)" if seen is None else (
        "INLINE" if seen == server or (server and server in seen) else "NOT-INLINE")
    grow, prior = context_after(use_id)
    line = (f"#{n + 1} {name.split('__')[-1]} (wire: {wire_name}) {shown} · server {len(server):,} chars"
            f"{' isError' if answer.get('isError') else ''} · model saw "
            f"{'—' if seen is None else format(len(seen), ',')} chars · {verdict}")
    if grow is not None: line += f" · context +{grow:,} tokens (≈; incl. {prior} output)"
    try:
        page = json.loads(server)
        if name.endswith("read_note") and isinstance(page, dict) and "blocks" in page:
            chars = sum(len(t.get("text", "")) for b in page["blocks"] for t in b.get("takes", []))
            line += (f"\n     page: {len(page['blocks'])} blocks · block_count {page.get('block_count')} · "
                     f"next_cursor {'yes' if page.get('next_cursor') else 'no'} · take text {chars:,} chars")
    except Exception:
        pass
    if verdict == "NOT-INLINE": line += "\n     arrived instead: " + repr(seen[:300])
    report.append(line)
print("\n".join(report))
open(f"{U}/{leg}-measure.txt", "w").write("\n".join(report) + "\n")
