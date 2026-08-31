#!/usr/bin/env python3
"""Derive the app's bundled sample-library text from the Project Gutenberg source.

Input:  notes/source/sherlock-adventures-pg1661.txt  (PG #1661, verbatim download)
Output: App/Variorum/Variorum/Features/SampleLibrary/SherlockAdventures.txt

What it does, and why (pre-13u Act 3):
  · Strips the PG header/footer boilerplate — everything outside the
    `*** START OF …` / `*** END OF …` markers, plus the volume front matter
    and table of contents that sit inside them. The stories themselves are
    US public domain; only PG's own edition matter is dropped.
  · UNWRAPS the hard-wrapped lines into one line per paragraph.
    `SegmentationRules.bulkSegments` splits paragraph mode on every non-blank
    LINE, so shipping the 72-column wrapping would mint ~11,000 one-line
    blocks instead of 2,530 real paragraphs.
  · Emits `%%% <title>` delimiter lines the seeder splits on. The delimiter
    cannot occur in the prose and is never stored.

Re-run after any source change; the output is committed, so the app never
parses the raw PG file.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "notes/source/sherlock-adventures-pg1661.txt"
OUT = ROOT / "App/Variorum/Variorum/Features/SampleLibrary/SherlockAdventures.txt"
ROMAN = r"(?:I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII)"


def paragraphs(lines):
    out, cur = [], []
    for line in lines:
        if line.strip() == "":
            if cur:
                out.append(" ".join(s.strip() for s in cur))
                cur = []
        else:
            cur.append(line)
    if cur:
        out.append(" ".join(s.strip() for s in cur))
    return out


def main():
    src = SRC.read_text(encoding="utf-8").split("\n")
    start = next(i for i, l in enumerate(src) if l.startswith("*** START OF"))
    end = next(i for i, l in enumerate(src) if l.startswith("*** END OF"))
    body = src[start + 1:end]
    titles = [
        re.sub(r"^[IVX]+\.\s+", "", l.strip())
        for l in body
        if re.match(rf"^\s+{ROMAN}\.\s+\S", l)
    ]
    heads = [i for i, l in enumerate(body) if re.match(rf"^{ROMAN}\. [A-Z]", l)]
    if len(titles) != 12 or len(heads) != 12:
        sys.exit(f"expected 12 stories, found {len(titles)} titles / {len(heads)} headers")

    chunks, words, blocks = [], 0, 0
    for k, head in enumerate(heads):
        stop = heads[k + 1] if k + 1 < len(heads) else len(body)
        paras = paragraphs(body[head + 1:stop])
        words += sum(len(p.split()) for p in paras)
        blocks += len(paras)
        chunks.append("%%% " + titles[k] + "\n\n" + "\n\n".join(paras))
    OUT.write_text("\n\n".join(chunks) + "\n", encoding="utf-8")
    print(f"{len(heads)} stories · {blocks} paragraphs · {words} words · "
          f"{len(OUT.read_bytes())} bytes → {OUT.relative_to(ROOT)}")


main()
