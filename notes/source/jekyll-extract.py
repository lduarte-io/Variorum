#!/usr/bin/env python3
"""Derive the app's bundled Jekyll & Hyde text from the Project Gutenberg source.

Input:  notes/plans/18l-inputs/drjekyllandmrhyde-gutenberg-raw.txt
        (PG #42, verbatim download — committed at the 18l-c kickoff; the author's
        own copy of the public-domain novella, handed over in her kickoff message)
Output: App/Variorum/Shared/SampleLibrary/JekyllAndHyde.txt

What it does, and why (18l-c U6 — the takemania book, R-18l-11):
  · Strips the PG header/footer boilerplate — everything outside the
    `*** START OF …` / `*** END OF …` markers, plus the title page,
    dedication and table of contents that sit inside them — exactly as
    `sherlock-extract.py` does for Sherlock. The novella is US public domain;
    only PG's own edition matter is dropped.
  · UNWRAPS the hard-wrapped lines into one line per paragraph
    (`SegmentationRules.bulkSegments` splits paragraph mode on every
    non-blank LINE, so the 72-column wrapping would mint one block per line).
  · Emits ONLY the two QUIET chapters the book carries as straight text —
    the first and the last. The middle of the novella is takemania's
    material, and takemania is minted by a scripted history
    (`Shared/SampleLibrary/Takemania.swift`), never from this file.
  · Paragraphs are joined by ONE newline, not a blank line: the seed then
    stores each paragraph block WITHOUT a trailing blank line — the shape of
    her own typed notes (Sherlock's resource keeps a blank line between
    paragraphs, so every Sherlock block stores one; see the U6 record's
    design call 4 for why this book differs).
  · Emits `%%% <title>` delimiter lines the seeder splits on (never stored).
  · The chapter headings are UPPERCASE in the source; the note titles are
    their title-case forms (`DR.` keeps its period; the curly apostrophe
    rides through).

Also writes every chapter's unwrapped paragraphs, numbered, to the path in
argv[1] when one is given — a reading aid for writing takemania's script,
never shipped.

Re-run after any source change; the output is committed, so the app never
parses the raw PG file.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "notes/plans/18l-inputs/drjekyllandmrhyde-gutenberg-raw.txt"
OUT = ROOT / "App/Variorum/Shared/SampleLibrary/JekyllAndHyde.txt"

HEADINGS = [
    "STORY OF THE DOOR",
    "SEARCH FOR MR. HYDE",
    "DR. JEKYLL WAS QUITE AT EASE",
    "THE CAREW MURDER CASE",
    "INCIDENT OF THE LETTER",
    "REMARKABLE INCIDENT OF DR. LANYON",
    "INCIDENT AT THE WINDOW",
    "THE LAST NIGHT",
    "DR. LANYON’S NARRATIVE",
    "HENRY JEKYLL’S FULL STATEMENT OF THE CASE",
]
# The two quiet chapters, by heading, with the note title each becomes.
QUIET = {
    "STORY OF THE DOOR": "Story of the Door",
    "HENRY JEKYLL’S FULL STATEMENT OF THE CASE":
        "Henry Jekyll’s Full Statement of the Case",
}


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
    src = SRC.read_text(encoding="utf-8").replace("\r\n", "\n").split("\n")
    start = next(i for i, l in enumerate(src) if l.startswith("*** START OF"))
    end = next(i for i, l in enumerate(src) if l.startswith("*** END OF"))
    body = src[start + 1:end]
    # The chapter heads are the heading lines standing ALONE at column 0 —
    # the table of contents indents them by one space, so it never matches.
    heads = [i for i, l in enumerate(body) if l in HEADINGS]
    if [body[i] for i in heads] != HEADINGS:
        sys.exit(f"expected the ten chapter heads in order, found {[body[i] for i in heads]}")

    chapters = []
    for k, head in enumerate(heads):
        stop = heads[k + 1] if k + 1 < len(heads) else len(body)
        chapters.append((body[head], paragraphs(body[head + 1:stop])))

    chunks, words, blocks = [], 0, 0
    for heading, paras in chapters:
        if heading not in QUIET:
            continue
        # Lanyon's narrative ends with a signature line; the last chapter has
        # none — nothing to trim, but the rule is stated so a re-extraction
        # that changes the source says so here rather than in a note.
        words += sum(len(p.split()) for p in paras)
        blocks += len(paras)
        chunks.append("%%% " + QUIET[heading] + "\n\n" + "\n".join(paras))
    OUT.write_text("\n\n".join(chunks) + "\n", encoding="utf-8")
    print(f"{len(chunks)} quiet chapters · {blocks} paragraphs · {words} words · "
          f"{len(OUT.read_bytes())} bytes → {OUT.relative_to(ROOT)}")

    if len(sys.argv) > 1:
        aid = Path(sys.argv[1])
        lines = []
        for heading, paras in chapters:
            lines.append(f"=== {heading} ({len(paras)} paragraphs, "
                         f"{sum(len(p.split()) for p in paras)} words)")
            for n, p in enumerate(paras):
                lines.append(f"[{n}] {p}")
            lines.append("")
        aid.write_text("\n".join(lines), encoding="utf-8")
        total = sum(sum(len(p.split()) for p in paras) for _, paras in chapters)
        print(f"reading aid: {len(chapters)} chapters · {total} words → {aid}")


main()
