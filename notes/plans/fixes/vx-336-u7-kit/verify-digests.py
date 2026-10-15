# VX-336 U7 window kit — THE PRODUCT'S BYTE TRUTH from the wire, independent of the model.
#   python3 -I verify-digests.py <leg>                     (L1: the write answers)
#   python3 -I verify-digests.py <leg> --texts <leg2> ...  (L3: ids_only against texts read)
# Write form: from tee/<leg>-in/out.jsonl, recomputes SHA-256 (UTF-8 bytes, lowercase hex) of
# every text the client SENT — create_note's blocks and takes, add_take, edit_take — and
# compares each with the sha256 the answer gave; then replays the edits onto the note and
# checks duplicate_note's copies digest as their source takes. ids_only form: every take text
# the --texts legs' read_note answers carried, by take_id, against the sha256 <leg>'s ids_only
# answers gave for that take_id. Prints every mismatch; ends "N checked · N equal".
import hashlib, json, os, sys

U = "<home>/dev/variorum-vx-336/notes/plans/vx336-screens/u7"
digest = lambda s: hashlib.sha256(s.encode("utf-8")).hexdigest()

def pairs(leg):
    def lines(p):
        return [json.loads(l) for l in open(p, encoding="utf-8") if l.strip()] if os.path.exists(p) else []
    answers = {m.get("id"): m for m in lines(f"{U}/tee/{leg}-out.jsonl") if "id" in m and "method" not in m}
    for m in lines(f"{U}/tee/{leg}-in.jsonl"):
        if m.get("method") == "tools/call" and m.get("id") in answers:
            result = answers[m["id"]].get("result", {})
            text = "".join(c.get("text", "") for c in result.get("content", []) if c.get("type") == "text")
            try: body = json.loads(text)
            except Exception: body = None
            yield m["params"]["name"], m["params"].get("arguments", {}), body, result.get("isError")

checked, equal, bad = 0, 0, []
def check(what, sent, answered):
    global checked, equal
    checked += 1
    if answered == digest(sent): equal += 1
    else: bad.append(f"{what}: sent {sent!r} → digest {digest(sent)[:12]}…, answered {str(answered)[:12]}…")

leg = sys.argv[1]
if "--texts" in sys.argv:
    texts = {}
    for source in sys.argv[sys.argv.index("--texts") + 1:]:
        for name, args, body, error in pairs(source):
            if name == "read_note" and isinstance(body, dict):
                for b in body.get("blocks", []):
                    for t in b.get("takes", []):
                        if "text" in t: texts[t["take_id"]] = t["text"]
    for name, args, body, error in pairs(leg):
        if name == "read_note" and args.get("ids_only") and isinstance(body, dict):
            for b in body.get("blocks", []):
                for t in b.get("takes", []):
                    if t["take_id"] in texts: check(f"take {t['take_id'][:8]}", texts[t["take_id"]], t.get("sha256"))
                    else: bad.append(f"take {t['take_id'][:8]}: no text read for it in {sys.argv[sys.argv.index('--texts') + 1:]}")
                    if "text" in t: bad.append(f"take {t['take_id'][:8]}: ids_only carried text")
else:
    takes = {}          # take_id -> its current text (sent, then edited)
    blocks = {}         # block_id -> [take ids in fan order]
    for name, args, body, error in pairs(leg):
        if error or not isinstance(body, dict): continue
        if name == "create_note":
            for i, (sent, record) in enumerate(zip(args.get("blocks", []), body.get("blocks", []))):
                texts = [sent.get("text", "")] + [t.get("text", "") for t in sent.get("takes", [])]
                for j, (text, take) in enumerate(zip(texts, record.get("takes", []))):
                    check(f"create_note block {i + 1} take {j + 1}", text, take.get("sha256"))
                    takes[take["take_id"]] = text
                blocks[record["block_id"]] = [t["take_id"] for t in record.get("takes", [])]
        elif name == "add_take":
            check(f"add_take {args.get('text')!r}", args.get("text", ""), body.get("sha256"))
            takes[body["take_id"]] = args.get("text", ""); blocks.setdefault(args["block_id"], []).append(body["take_id"])
        elif name == "edit_take":
            check(f"edit_take {args.get('take_id', '')[:8]}", args.get("text", ""), body.get("sha256"))
            takes[args["take_id"]] = args.get("text", "")
        elif name == "duplicate_note":
            for record in body.get("blocks", []):
                source = blocks.get(record.get("source_block_id"), [])
                for j, take in enumerate(record.get("takes", [])):
                    sent = takes.get(source[j]) if j < len(source) else None
                    if sent is None: bad.append(f"duplicate_note copy take {j + 1}: no source take known"); continue
                    check(f"duplicate_note copy of {record.get('source_block_id', '')[:8]} take {j + 1}", sent, take.get("sha256"))
print("\n".join(bad) if bad else "no mismatch")
print(f"{checked} checked · {equal} equal")
