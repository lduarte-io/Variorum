# VX-336 U8b window kit — WHAT THE SERVER SENT AS ITS ADVICE, read from bytes, and WHICH ACTS THE CLIENT TOOK.
#   python3 -I instructions.py <leg>
# Reads tee/<leg>-out.jsonl (the server's side of the wire): the `initialize` result's `instructions`
# (its length in code points, its first and last lines, and the U8a markers it must carry), then the
# tee/<leg>-in.jsonl tools/call names in order with each answer's isError. Writes <leg>-instructions.txt.
import json, os, sys

U = os.environ.get("U7_SCREENS", "<home>/dev/variorum-vx-336/notes/plans/vx336-screens/u8")
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
report = []
advice = next((m["result"]["instructions"] for m in out
               if isinstance(m.get("result"), dict) and "instructions" in m["result"]), None)
if advice is None:
    report.append("NO initialize result with instructions in the tee")
else:
    first, last = advice.splitlines()[0], advice.splitlines()[-1]
    report.append(f"instructions: {len(advice)} code points; first line starts {first[:60]!r}; last line {last!r}")
    for marker in ["Once approved, list_my_activity is always listed",
                   "Help the author stay organized: put plans, summaries and research into notes, not just chat; "
                   "file notes into books and chapters; tag them, and make books that collect by tag rules.",
                   "Three acts are the author's alone",
                   "The guide to this door: https://stargazing.tech/variorum/mcp"]:
        report.append(f"  {'CARRIES' if marker in advice else 'LACKS'}: {marker[:70]}")
answers = {m.get("id"): m for m in out if "id" in m}
report.append("acts, in order:")
for m in inn:
    if m.get("method") == "tools/call":
        p = m.get("params", {})
        a = answers.get(m.get("id"), {})
        err = (a.get("result") or {}).get("isError")
        args = p.get("arguments", {})
        brief = {k: (v if len(json.dumps(v)) < 80 else f"<{len(json.dumps(v))} chars>") for k, v in args.items()}
        report.append(f"  {p.get('name')} {json.dumps(brief, ensure_ascii=False)} -> {'REFUSED/ERROR' if err else 'ok'}")
text = "\n".join(report)
print(text)
open(f"{U}/{leg}-instructions.txt", "w").write(text + "\n")
