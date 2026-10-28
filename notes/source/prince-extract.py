#!/usr/bin/env python3
"""Derive the bilingual Prince's bundled resources, and VALIDATE the alignment.

Inputs (all in notes/source/):
  prince-marriott-pg1232.txt           W. K. Marriott's 1908 English, Project Gutenberg
                                       #1232 (verbatim download)
  prince-italiano-wikisource-1814.txt  the Italian, assembled from it.wikisource.org
                                       ("Edizione: Niccolò Machiavelli, Il Principe.
                                       Italia, 1814"; verbatim, `=== Il Principe/<sub> ===`
                                       markers added at assembly)
  prince-italiano-aligned.txt          the CURATED Italian: the Wikisource body
                                       re-paragraphed by hand to Marriott's breaks
                                       (VX-633 U1 — the curation is that file; this
                                       script only checks and copies it)
Outputs:
  App/Variorum/Shared/SampleLibrary/ThePrince.txt          the English
  App/Variorum/Shared/SampleLibrary/ThePrinceItaliano.txt  the Italian, paired 1:1

What it does, and why (VX-633 U1, the bilingual Prince seed book):
  · ENGLISH — drops PG's header/footer boilerplate (outside the `*** START/END`
    markers), Marriott's long INTRODUCTION, the table of contents, the "THE
    PRINCE" title line and the appendix after XXVI (the Valentino description,
    the Life of Castruccio). Keeps the dedication and the 26 chapters. Strips
    the editor's apparatus: every `[n]` footnote marker, every footnote block,
    and the two UNMARKED apparatus blocks — XVIII's "Italian Proverb." epigraph
    and XXVI's Edward Dacre verse rendering of Petrarch with its attribution
    (PROVISIONAL, see the U1 record in notes/plans/vx-633-prince-book.md; each
    strip is asserted by its exact content, so a source change fails loudly).
    UNWRAPS each paragraph to one line (bulk segmentation makes every non-blank
    line a block, so the hard wrapping would mint one block per line; verse
    lines join with a space for the same reason). Paragraphs are joined by ONE
    newline — the typed-note shape, no stored blank line per block (the Jekyll
    resource's precedent, not Sherlock's).
  · NOTE TITLES (PROVISIONAL, hers to retitle): `<ROMAN>. <Marriott's chapter
    title in sentence case>`, e.g. "XVIII. Concerning the way in which princes
    should keep faith"; the dedication is "Dedication". Both resources carry the
    SAME titles in the same order — the seeder pairs by title + paragraph index.
  · ITALIAN — copies the curated paragraphs. Paragraphs are separated by a BLANK
    line, because one paragraph may hold newlines: verse (the Virgil couplet in
    XVII, the Petrarch stanza closing XXVI) keeps its line breaks (a newline inside
    a block is content — I4). A reader of this resource splits each note's text
    on "\\n\\n"; the English resource splits on "\\n".
  · `%%% <title>` delimiter lines separate the notes in both outputs and are
    never stored.

The validation (any failure exits non-zero and writes nothing):
  1. INTEGRITY — per section, the curated Italian with every break removed equals
     the raw Wikisource body with its headings stripped, modulo whitespace only
     (runs of spaces/newlines compared as one space). The stripped heading lines
     are asserted by exact content.
  2. BREAKS AT SENTENCE ENDS — every paragraph break the curation INSERTED falls
     right after . ? or ! (optionally closed by a quote or bracket); a break may
     otherwise sit only where the source itself had one.
  3. WHITESPACE — no doubled spaces, no leading/trailing spaces, and newlines
     only inside the two declared verse paragraphs.
  4. FOOTNOTES — per chapter, the `[n]` markers Marriott's text carries are
     exactly the footnote blocks stripped; no marker survives.
  5. PAIRING — the two written resources, re-read the way the seeder reads them,
     have identical note titles in the same order and EQUAL paragraph counts.
It prints a per-chapter table and, for every pair, the first and last words of
the English and the Italian — the reading aid for the spot checks.

Re-run after any source change; the outputs are committed, so the app never
parses a raw file. Run with `python3 -I notes/source/prince-extract.py` (the
raw files are downloaded text).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "notes/source"
EN_SRC = SRC / "prince-marriott-pg1232.txt"
IT_SRC = SRC / "prince-italiano-wikisource-1814.txt"
IT_ALIGNED = SRC / "prince-italiano-aligned.txt"
OUT_DIR = ROOT / "App/Variorum/Shared/SampleLibrary"
EN_OUT = OUT_DIR / "ThePrince.txt"
IT_OUT = OUT_DIR / "ThePrinceItaliano.txt"

ROMANS = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII",
          "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI", "XXII",
          "XXIII", "XXIV", "XXV", "XXVI"]
SECTIONS_IT = ["Dedica"] + [f"Capitolo {r}" for r in ROMANS]
DELIM = "%%% "

# Proper nouns the sentence-casing of Marriott's ALL-CAPS titles must keep.
PROPER = {"darius": "Darius", "alexander": "Alexander", "italy": "Italy"}

# Marriott's UNMARKED apparatus (no Italian counterpart; not Machiavelli's text) —
# stripped like his footnotes, each asserted by exact content. PROVISIONAL.
APPARATUS = {
    "XVII": [["Christopher Pitt."]],  # the tail of footnote [2] (Pitt's verse), set apart by a blank line
    "XVIII": [["Alexander never did what he said,", "Cesare never said what he did."],
              ["Italian Proverb."]],
    "XXVI": [["Virtue against fury shall advance the fight,",
              "    And it i’ th’ combat soon shall put to flight:",
              "For the old Roman valour is not dead,",
              "    Nor in th’ Italians’ brests extinguished."],
             ["Edward Dacre, 1640."]],
}

# The curated paragraphs that are verse: (section, paragraph index) → line count.
VERSE = {("Capitolo XVII", 2): 2, ("Capitolo XXVI", 10): 4}

SENTENCE_END = re.compile(r"[.?!][)’”»\"]?$")
TOC_DIFFS = []  # chapters whose heading PG's table of contents words differently


def fail(msg):
    sys.exit(f"prince-extract: FAILED — {msg}")


def chunks(lines):
    """Blank-line-separated runs of lines (lines kept verbatim)."""
    out, cur = [], []
    for line in lines:
        if line.strip() == "":
            if cur:
                out.append(cur)
                cur = []
        else:
            cur.append(line)
    if cur:
        out.append(cur)
    return out


def ws(text):
    """Whitespace-insensitive form for the integrity comparison."""
    return re.sub(r"\s+", " ", text).strip()


def sentence_case(caps):
    words = caps.lower().split(" ")
    out = []
    for w in words:
        core = re.sub(r"\W+$", "", w)
        out.append(PROPER.get(core, core) + w[len(core):] if core in PROPER else w)
    s = " ".join(out)
    return s[0].upper() + s[1:]


# ── English ────────────────────────────────────────────────────────────────


def english():
    """[(title, [paragraph])] for the dedication and I–XXVI, plus the report."""
    src = EN_SRC.read_text(encoding="utf-8").replace("\r\n", "\n").split("\n")
    start = next(i for i, l in enumerate(src) if l.startswith("*** START OF"))
    end = next(i for i, l in enumerate(src) if l.startswith("*** END OF"))
    body = src[start + 1:end]
    ded = [i for i, l in enumerate(body) if l == "DEDICATION"]
    if len(ded) != 1:
        fail(f"expected one body DEDICATION heading, found {len(ded)}")
    heads = [i for i, l in enumerate(body) if re.match(r"^CHAPTER [IVXL]+\.(\[\d+\])?$", l)]
    names = [re.match(r"^CHAPTER ([IVXL]+)\.", body[i]).group(1) for i in heads]
    if names != ROMANS:
        fail(f"expected chapter heads I–XXVI in order, found {names}")
    appendix = [i for i, l in enumerate(body) if l.startswith("DESCRIPTION OF THE METHODS ADOPTED")]
    if len(appendix) != 1:
        fail("expected one appendix heading after XXVI")
    # the table of contents' chapter titles, to cross-check the body title blocks
    toc = {m.group(1): m.group(2) for m in
           (re.match(r"^ CHAPTER ([IVXL]+)\. (.+)$", l) for l in body[:ded[0]]) if m}

    bounds = [ded[0]] + heads + [appendix[0]]
    notes, stripped_total = [], 0
    for k in range(len(bounds) - 1):
        cs = chunks(body[bounds[k] + 1:bounds[k + 1]])
        if k == 0:
            name, title = "Dedication", "Dedication"
            if cs[0] != ["To the Magnificent Lorenzo Di Piero De’ Medici"] or cs[-1] != ["THE PRINCE"]:
                fail("the dedication's heading line or the THE PRINCE title line moved")
            cs = cs[1:-1]
            heading_markers = set()
        else:
            name = ROMANS[k - 1]
            caps = " ".join(l.strip() for l in cs[0])
            if not re.fullmatch(r"[A-Z’,?' ]+", caps):
                fail(f"chapter {name}: expected an ALL-CAPS title block, found {caps!r}")
            # the chapter's OWN heading is the title; where PG's contents line
            # words it differently (XII's comma, XIV's "the art of"), say so
            if toc.get(name) != caps:
                TOC_DIFFS.append(f"{name}: heading {caps!r} / contents {toc.get(name)!r}")
            title = f"{name}. {sentence_case(caps)}"
            heading_markers = set(int(n) for n in re.findall(r"\[(\d+)\]", body[bounds[k]]))
            cs = cs[1:]
        apparatus = list(APPARATUS.get(name, []))
        paras, notes_seen, markers = [], set(), set(heading_markers)
        for c in cs:
            if re.match(r"^ \[\d+\]", c[0]):
                notes_seen |= set(int(n) for n in re.findall(r"^ \[(\d+)\]", "\n".join(c), re.M))
                stripped_total += 1
                continue
            if c in apparatus:
                apparatus.remove(c)
                stripped_total += 1
                continue
            text = " ".join(l.strip() for l in c)
            markers |= set(int(n) for n in re.findall(r"\[(\d+)\]", text))
            text = re.sub(r"\[\d+\]", "", text)
            paras.append(text)
        if apparatus:
            fail(f"chapter {name}: apparatus block(s) not found: {apparatus}")
        if markers != notes_seen:
            fail(f"chapter {name}: footnote markers {sorted(markers)} ≠ footnote blocks {sorted(notes_seen)}")
        for p in paras:
            if re.search(r"\[\d+\]", p) or p != p.strip() or "  " in p or not p:
                fail(f"{title}: a paragraph kept a marker or stray whitespace: {p[:80]!r}")
        notes.append((title, paras))
    return notes, stripped_total


# ── Italian ────────────────────────────────────────────────────────────────


def italian_raw():
    """{section: (italian title or None, [raw body chunk text], [stripped lines])}"""
    src = IT_SRC.read_text(encoding="utf-8").replace("\r\n", "\n").split("\n")
    heads = [i for i, l in enumerate(src) if l.startswith("=== ")]
    names = [re.fullmatch(r"=== Il Principe/(.+) ===", src[i]).group(1) for i in heads]
    if names != SECTIONS_IT:
        fail(f"raw Italian: expected Dedica + Capitolo I–XXVI, found {names}")
    out = {}
    for k, h in enumerate(heads):
        name = names[k]
        stop = heads[k + 1] if k + 1 < len(heads) else len(src)
        cs = chunks(src[h + 1:stop])
        if name == "Dedica":
            head = [["NICC. MACHIAVELLI"], ["al"], ["MAGNIFICO LORENZO"], ["DI PIERO DE’ MEDICI."]]
            title = None
        else:
            roman = name.split(" ")[1]
            head = [["IL PRINCIPE"], ["di"], ["NICC. MACHIAVELLI."], ["____"]] if roman == "I" else []
            head = head + [[f"CAPITOLO {roman}."]]
            if len(cs) <= len(head) or len(cs[len(head)]) != 1:
                fail(f"raw Italian {name}: no one-line title after the heading")
            title = cs[len(head)][0]
            head = head + [[title]]
        if cs[:len(head)] != head:
            fail(f"raw Italian {name}: heading lines changed: {cs[:len(head)]}")
        out[name] = (title, ["\n".join(c) for c in cs[len(head):]], head)
    return out


def italian_aligned():
    """{section: [paragraph]} from the curated file (leading # lines are its header)."""
    text = IT_ALIGNED.read_text(encoding="utf-8").replace("\r\n", "\n")
    sections, name, buf = {}, None, []
    order = []
    for line in text.split("\n"):
        if line.startswith(DELIM):
            if name is not None:
                sections[name] = buf
            name, buf = line[len(DELIM):].strip(), []
            order.append(name)
        elif name is None:
            if line and not line.startswith("#"):
                fail(f"aligned Italian: text before the first section: {line[:60]!r}")
        else:
            buf.append(line)
    if name is not None:
        sections[name] = buf
    if order != SECTIONS_IT:
        fail(f"aligned Italian: expected Dedica + Capitolo I–XXVI in order, found {order}")
    return {n: [p for p in "\n".join(b).strip("\n").split("\n\n")] for n, b in sections.items()}


def check_italian(raw, aligned):
    """Integrity, whitespace and break checks. Returns the report rows."""
    rows = []
    for name in SECTIONS_IT:
        title, raw_chunks, _ = raw[name]
        paras = aligned[name]
        # 1. integrity: same text modulo whitespace
        if ws(" ".join(raw_chunks)) != ws(" ".join(paras)):
            a, b = ws(" ".join(raw_chunks)), ws(" ".join(paras))
            i = next((i for i in range(min(len(a), len(b))) if a[i] != b[i]), min(len(a), len(b)))
            fail(f"{name}: the curated text differs from the source at …{a[max(0, i - 40):i + 40]!r} "
                 f"vs …{b[max(0, i - 40):i + 40]!r}")
        # 3. whitespace
        for n, p in enumerate(paras):
            lines = p.split("\n")
            if (name, n) in VERSE:
                if len(lines) != VERSE[(name, n)]:
                    fail(f"{name} ¶{n}: expected a {VERSE[(name, n)]}-line verse paragraph")
            elif len(lines) != 1:
                fail(f"{name} ¶{n}: a newline inside a prose paragraph")
            for l in lines:
                if not l or l != l.strip() or "  " in l:
                    fail(f"{name} ¶{n}: stray whitespace in {l[:60]!r}")
        # 2. breaks: positions in the whitespace-normalized stream
        def cuts(parts):
            pos, out = 0, []
            for part in parts[:-1]:
                pos += len(ws(part)) + 1
                out.append(pos)
            return out
        src_cuts = set(cuts(raw_chunks))
        new_cuts = cuts(paras)
        stream = ws(" ".join(paras))
        inserted = [c for c in new_cuts if c not in src_cuts]
        for c in inserted:
            if not SENTENCE_END.search(stream[:c - 1]):
                fail(f"{name}: an inserted break is not at a sentence end: …{stream[c - 60:c + 20]!r}")
        removed = sorted(src_cuts - set(new_cuts))
        # which raw paragraph boundaries (1-based, body only) were run on
        raw_ends = cuts(raw_chunks)
        merged = [f"{raw_ends.index(c) + 1}→{raw_ends.index(c) + 2}" for c in removed]
        # whitespace normalizations actually applied
        doubled = sum(len(re.findall(r"(?<=\S) {2,}(?=\S)", c)) for c in raw_chunks)
        leading = sum(1 for c in raw_chunks for l in c.split("\n") if l != l.lstrip(" "))
        trailing = sum(1 for c in raw_chunks for l in c.split("\n") if l != l.rstrip(" "))
        rows.append((name, title, len(raw_chunks), len(paras), len(inserted), merged,
                     doubled, leading, trailing))
    return rows


# ── Output + pairing ─────────────────────────────────────────────────────


def read_resource(path, sep):
    """Re-read a written resource the way the seeder does (split on the delimiter
    lines; the note text is the joined body, trimmed), then split paragraphs."""
    notes, title, body = [], None, []
    for line in path.read_text(encoding="utf-8").split("\n"):
        if line.startswith(DELIM):
            if title is not None:
                notes.append((title, "\n".join(body).strip()))
            title, body = line[len(DELIM):].strip(), []
        else:
            body.append(line)
    if title is not None:
        notes.append((title, "\n".join(body).strip()))
    return [(t, text.split(sep)) for t, text in notes]


def first_last(p, n=6):
    w = p.replace("\n", " / ").split()
    return " ".join(w[:n]), " ".join(w[-n:])


def main():
    en_notes, stripped = english()
    raw = italian_raw()
    aligned = italian_aligned()
    rows = check_italian(raw, aligned)

    if len(en_notes) != len(SECTIONS_IT):
        fail("section count differs between the English and the Italian")
    for (title, en), name in zip(en_notes, SECTIONS_IT):
        if len(en) != len(aligned[name]):
            fail(f"{title}: {len(en)} English paragraphs vs {len(aligned[name])} Italian ({name})")

    en_text = "\n\n".join(f"{DELIM}{t}\n\n" + "\n".join(p) for t, p in en_notes) + "\n"
    it_text = "\n\n".join(f"{DELIM}{t}\n\n" + "\n\n".join(aligned[name])
                          for (t, _), name in zip(en_notes, SECTIONS_IT)) + "\n"

    # 5. pairing, on what the seeder will actually read — checked before writing
    tmp_en, tmp_it = EN_OUT.with_suffix(".tmp"), IT_OUT.with_suffix(".tmp")
    tmp_en.write_text(en_text, encoding="utf-8")
    tmp_it.write_text(it_text, encoding="utf-8")
    try:
        en_back, it_back = read_resource(tmp_en, "\n"), read_resource(tmp_it, "\n\n")
        if [t for t, _ in en_back] != [t for t, _ in it_back]:
            fail("the two resources' note titles differ")
        for (t, e), (_, i) in zip(en_back, it_back):
            if len(e) != len(i) or any(not p.strip() for p in e + i):
                fail(f"{t}: {len(e)} EN vs {len(i)} IT paragraphs after the round trip")
        if [p for _, e in en_back for p in e] != [p for _, e in en_notes for p in e]:
            fail("the English resource does not round-trip")
    except SystemExit:
        tmp_en.unlink()
        tmp_it.unlink()
        raise
    tmp_en.replace(EN_OUT)
    tmp_it.replace(IT_OUT)

    # the report
    print("note                                              EN  IT  EN words  IT words  "
          "inserted  source breaks run on")
    tot = [0, 0, 0, 0, 0]
    for (title, en), row in zip(en_notes, rows):
        name, _, _, n_it, inserted, merged, *_ = row
        ew = sum(len(p.split()) for p in en)
        iw = sum(len(p.split()) for p in aligned[name])
        tot = [tot[0] + len(en), tot[1] + n_it, tot[2] + ew, tot[3] + iw, tot[4] + inserted]
        print(f"{title[:48]:<48}  {len(en):>3} {n_it:>3}  {ew:>8}  {iw:>8}  {inserted:>8}  "
              f"{', '.join(merged) or '—'}")
    print(f"{'TOTAL':<48}  {tot[0]:>3} {tot[1]:>3}  {tot[2]:>8}  {tot[3]:>8}  {tot[4]:>8}")
    d = sum(r[6] for r in rows)
    lead = sum(r[7] for r in rows)
    trail = sum(r[8] for r in rows)
    print(f"whitespace normalized in the Italian: {d} doubled-space run(s) collapsed, "
          f"{lead} leading and {trail} trailing space(s) trimmed; verse kept on its lines "
          f"({', '.join(f'{s} ¶{n}' for s, n in VERSE)})")
    print(f"English apparatus stripped: {stripped} block(s) (footnotes + the asserted unmarked apparatus)")
    for d in TOC_DIFFS:
        print(f"title from the chapter's own heading (PG's contents differs) — {d}")
    print()
    for (title, en), name in zip(en_notes, SECTIONS_IT):
        print(f"=== {title}  |  {name}  |  {raw[name][0] or '(dedica)'}")
        for n, (e, i) in enumerate(zip(en, aligned[name])):
            (ef, el), (itf, itl) = first_last(e), first_last(i)
            print(f"  [{n}] EN {ef} … {el}")
            print(f"      IT {itf} … {itl}")
    print()
    print(f"OK — {len(en_notes)} notes · {tot[0]} paragraph pairs · validation green → "
          f"{EN_OUT.relative_to(ROOT)} ({len(EN_OUT.read_bytes())} bytes), "
          f"{IT_OUT.relative_to(ROOT)} ({len(IT_OUT.read_bytes())} bytes)")


main()
