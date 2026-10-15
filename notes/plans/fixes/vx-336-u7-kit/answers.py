# VX-336 U9 window kit — EVERY TOOL CALL AND ITS ANSWER, verbatim, read from the wire's bytes.
#   python3 -I answers.py <leg>
# Reads tee/<leg>-in.jsonl (what the client sent) and tee/<leg>-out.jsonl (what the server answered):
# each tools/call in order — its name, its arguments (a long value shortened to its length), isError,
# and the answer's text WHOLE (U9's leg reads tag_ids / tags / changed and the refusal words from it).
# Writes <leg>-answers.txt. Never prints a key (the tee holds none — the shim's preamble is not a frame).
import json, os, sys

U = os.environ.get("U7_SCREENS", "<home>/dev/variorum-vx-336/notes/plans/vx336-screens/u9")
leg = sys.argv[1]

def lines(path):
    out = []
    if os.path.exists(path):
        for raw in open(path, encoding="utf-8", errors="replace"):
            raw = raw.strip()
            if raw:
                try: out.append(json.loads(raw))
                except Exception: pass
    return out

out, inn = lines(f"{U}/tee/{leg}-out.jsonl"), lines(f"{U}/tee/{leg}-in.jsonl")
answers = {m.get("id"): m for m in out if "id" in m}
report = []
step = 0
for m in inn:
    if m.get("method") != "tools/call":
        continue
    step += 1
    p = m.get("params", {})
    args = p.get("arguments", {})
    brief = {k: (v if len(json.dumps(v)) < 120 else f"<{len(json.dumps(v))} chars>") for k, v in args.items()}
    result = (answers.get(m.get("id"), {}) or {}).get("result") or {}
    text = "".join(c.get("text", "") for c in result.get("content", []) if c.get("type") == "text")
    report.append(f"{step}. {p.get('name')} {json.dumps(brief, ensure_ascii=False)}")
    report.append(f"   isError={bool(result.get('isError'))}  answer: {text}")
text = "\n".join(report) if report else "NO tools/call in the tee"
print(text)
open(f"{U}/{leg}-answers.txt", "w").write(text + "\n")
