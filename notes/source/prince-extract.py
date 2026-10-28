#!/usr/bin/env python3
"""Derive the bilingual Prince's bundled resources, and VALIDATE the alignment.

Inputs (all in notes/source/):
  prince-marriott-pg1232.txt           W. K. Marriott's 1908 English, Project Gutenberg
                                       #1232 (verbatim download)
  prince-italiano-wikisource-1814.txt  the Italian, assembled from it.wikisource.org
                                       ("Edizione: Niccolò Machiavelli, Il Principe.
                                       Italia, 1814"; verbatim, `=== Il Principe/<sub> ===`
                                       markers added at assembly)
  prince-aligned/dedica.txt,           the CURATED Italian, one file per section: the
  prince-aligned/capitolo-01.txt …     Wikisource body re-paragraphed by hand to
  prince-aligned/capitolo-26.txt       Marriott's breaks, body paragraphs only, blank-line
                                       separated (VX-633 U1 — the curation is those files;
                                       this script only checks and copies them)
  prince-ricci-pg57037.txt             Luigi Ricci's English, Project Gutenberg #57037
                                       (verbatim download) — read ONLY for the
                                       famous-line third takes
Outputs:
  App/Variorum/Shared/SampleLibrary/ThePrince.txt          the English
  App/Variorum/Shared/SampleLibrary/ThePrinceItaliano.txt  the Italian, paired 1:1
  notes/source/prince-famous-lines.json                    the third-take table (Ricci's
                                       rendering of the standout paragraphs, by note title +
                                       paragraph index) + the Italian chapter titles

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
  · THE THIRD TAKES (R-633-4) — for each standout paragraph in FAMOUS below,
    the span of Ricci's text that renders the SAME Marriott paragraph, cut out of
    Ricci's coarser paragraph at sentence boundaries and copied verbatim
    (unwrapped). Each span is located by its first and last words and asserted
    to sit inside one Ricci paragraph, to start at a sentence start and to end at
    a sentence end; each entry's `quoteHint` is asserted to occur verbatim in the
    Marriott paragraph it names. `chapterTitlesItalian` maps each chapter's note
    title to the 1814 text's own chapter title line, as printed.

The validation. The third-take table depends only on the English, Ricci and the
raw Italian, so it is written as soon as its own checks pass. The two resources
are written ONLY when all 27 section files exist and pass; otherwise the run
exits non-zero listing EVERY missing, extra or mismatched section at once.
  0. COUNTS — each section file holds exactly as many paragraphs as Marriott's
     section (after the strips above).
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
  6. THIRD TAKES — the span checks above, for every FAMOUS entry.
It prints a per-chapter table and, for every pair, the first and last words of
the English and the Italian — the reading aid for the spot checks.

Re-run after any source change; the outputs are committed, so the app never
parses a raw file. Run with `python3 -I notes/source/prince-extract.py` (the
raw files are downloaded text).
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "notes/source"
EN_SRC = SRC / "prince-marriott-pg1232.txt"
IT_SRC = SRC / "prince-italiano-wikisource-1814.txt"
IT_ALIGNED_DIR = SRC / "prince-aligned"
RICCI_SRC = SRC / "prince-ricci-pg57037.txt"
OUT_DIR = ROOT / "App/Variorum/Shared/SampleLibrary"
EN_OUT = OUT_DIR / "ThePrince.txt"
IT_OUT = OUT_DIR / "ThePrinceItaliano.txt"
FAMOUS_OUT = SRC / "prince-famous-lines.json"

# The standout paragraphs that carry a third take — Ricci's rendering (R-633-4;
# the set is the U1 implementer's pick from the architect's candidates, recorded
# in the U1 record). `quoteHint` is verbatim Marriott, inside the named paragraph;
# Ricci's span is named by its first and last words in Ricci's chapter.
FAMOUS = [
    {"chapter": "VI", "paragraphIndex": 4,
     "quoteHint": "there is nothing more difficult to take in hand, more perilous to conduct, or more "
                  "uncertain in its success, than to take the lead in the introduction of a new order of things",
     "ricciFrom": "Those who by heroic means", "ricciTo": "between them he runs great danger."},
    {"chapter": "XV", "paragraphIndex": 0,
     "quoteHint": "how one lives is so far distant from how one ought to live",
     "ricciFrom": "It remains now to be seen", "ricciTo": "among so many who are not good."},
    {"chapter": "XVII", "paragraphIndex": 4,
     "quoteHint": "it is much safer to be feared than loved",
     "ricciFrom": "From this arises the question", "ricciTo": "dread of punishment which never fails."},
    {"chapter": "XVIII", "paragraphIndex": 0,
     "quoteHint": "it is necessary to be a fox to discover the snares and a lion to terrify the wolves",
     "ricciFrom": "How laudable it is", "ricciTo": "imitate the fox have succeeded best."},
    {"chapter": "XVIII", "paragraphIndex": 4,
     "quoteHint": "Every one sees what you appear to be, few really know what you are",
     "ricciFrom": "A prince must take great care", "ricciTo": "the end is everything."},
    {"chapter": "XXV", "paragraphIndex": 1,
     "quoteHint": "I compare her to one of those raging rivers",
     "ricciFrom": "I would compare her to an impetuous river",
     "ricciTo": "no dams or barriers have been made to hold her."},
]

ROMANS = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII",
          "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI", "XXII",
          "XXIII", "XXIV", "XXV", "XXVI"]
SECTIONS_IT = ["Dedica"] + [f"Capitolo {r}" for r in ROMANS]
# the curated Italian, one file per section: body paragraphs only, blank-line separated
ALIGNED_FILES = {"Dedica": "dedica.txt",
                 **{f"Capitolo {r}": f"capitolo-{n:02d}.txt" for n, r in enumerate(ROMANS, 1)}}
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
    """({section: [paragraph]}, [problem]) from the per-section curated files.
    A missing file is a problem for that section, never a crash — the run lists
    every missing or mismatched section at once."""
    sections, problems = {}, []
    for name in SECTIONS_IT:
        path = IT_ALIGNED_DIR / ALIGNED_FILES[name]
        if not path.exists():
            problems.append(f"MISSING {path.relative_to(ROOT)} ({name})")
            continue
        text = path.read_text(encoding="utf-8").replace("\r\n", "\n").strip("\n")
        sections[name] = text.split("\n\n") if text else []
    expected = set(ALIGNED_FILES.values())
    for extra in sorted(p.name for p in IT_ALIGNED_DIR.glob("*") if p.name not in expected):
        problems.append(f"UNEXPECTED {(IT_ALIGNED_DIR / extra).relative_to(ROOT)} (not one of the 27 section files)")
    return sections, problems


def cuts(parts):
    """Break offsets of `parts` in the whitespace-normalized stream."""
    pos, out = 0, []
    for part in parts[:-1]:
        pos += len(ws(part)) + 1
        out.append(pos)
    return out


def check_section(name, raw_chunks, paras, en_count):
    """Integrity, count, whitespace and break checks for one section.
    Returns (problems, report row)."""
    problems = []
    where = f"{name} ({ALIGNED_FILES[name]})"
    # count: the Italian must pair 1:1 with Marriott's body paragraphs
    if len(paras) != en_count:
        problems.append(f"MISMATCH {where}: {len(paras)} Italian paragraphs vs {en_count} English")
    # 1. integrity: same text modulo whitespace
    a, b = ws(" ".join(raw_chunks)), ws(" ".join(paras))
    if a != b:
        i = next((i for i in range(min(len(a), len(b))) if a[i] != b[i]), min(len(a), len(b)))
        problems.append(f"TEXT {where}: differs from the source at …{a[max(0, i - 40):i + 40]!r} "
                        f"vs …{b[max(0, i - 40):i + 40]!r}")
        return problems, None
    # 3. whitespace and verse
    for n, p in enumerate(paras):
        lines = p.split("\n")
        if (name, n) in VERSE:
            if len(lines) != VERSE[(name, n)]:
                problems.append(f"VERSE {where} ¶{n}: expected {VERSE[(name, n)]} lines, found {len(lines)}")
        elif len(lines) != 1:
            problems.append(f"NEWLINE {where} ¶{n}: a newline inside a prose paragraph")
        for l in lines:
            if not l or l != l.strip() or "  " in l:
                problems.append(f"WHITESPACE {where} ¶{n}: {l[:60]!r}")
    # 2. breaks: every inserted break at a sentence end
    src_cuts, new_cuts = set(cuts(raw_chunks)), cuts(paras)
    stream = ws(" ".join(paras))
    inserted = [c for c in new_cuts if c not in src_cuts]
    for c in inserted:
        if not SENTENCE_END.search(stream[:c - 1]):
            problems.append(f"BREAK {where}: not at a sentence end: …{stream[c - 60:c + 20]!r}")
    raw_ends = cuts(raw_chunks)
    merged = [f"{raw_ends.index(c) + 1}→{raw_ends.index(c) + 2}" for c in sorted(src_cuts - set(new_cuts))]
    # whitespace normalizations the curation applied
    doubled = sum(len(re.findall(r"(?<=\S) {2,}(?=\S)", c)) for c in raw_chunks)
    leading = sum(1 for c in raw_chunks for l in c.split("\n") if l != l.lstrip(" "))
    trailing = sum(1 for c in raw_chunks for l in c.split("\n") if l != l.rstrip(" "))
    return problems, (len(inserted), merged, doubled, leading, trailing)


# ── Ricci + the third-take table ─────────────────────────────────────────


def ricci():
    """{roman: [paragraph]} — Ricci's chapters, each paragraph unwrapped."""
    src = RICCI_SRC.read_text(encoding="utf-8").replace("\r\n", "\n").split("\n")
    start = next(i for i, l in enumerate(src) if l.startswith("*** START OF"))
    end = next(i for i, l in enumerate(src) if l.startswith("*** END OF"))
    body = src[start + 1:end]
    heads = [i for i, l in enumerate(body) if re.fullmatch(r"CHAPTER [IVXL]+", l)]
    names = [body[i].split(" ")[1] for i in heads]
    if names != ROMANS:
        fail(f"Ricci: expected chapter heads I–XXVI in order, found {names}")
    out = {}
    for k, h in enumerate(heads):
        stop = heads[k + 1] if k + 1 < len(heads) else len(body)
        cs = chunks(body[h + 1:stop])
        if not re.fullmatch(r"[A-Z',.? ]+", " ".join(l.strip() for l in cs[0])):
            fail(f"Ricci {names[k]}: expected an ALL-CAPS title block first")
        out[names[k]] = [" ".join(l.strip() for l in c) for c in cs[1:]]
    return out


def ricci_span(roman, paras, frm, to):
    """The verbatim span from `frm` to `to`, inside ONE Ricci paragraph, starting
    at a sentence start and ending at a sentence end."""
    hits = [n for n, p in enumerate(paras) if frm in p]
    if len(hits) != 1 or paras[hits[0]].count(frm) != 1:
        fail(f"Ricci {roman}: {frm!r} must open exactly one span, found {len(hits)} paragraph(s)")
    p = paras[hits[0]]
    i = p.index(frm)
    j = p.find(to, i)
    if j < 0 or p.count(to) != 1:
        fail(f"Ricci {roman}: {to!r} must close the span inside the same paragraph as {frm!r}")
    j += len(to)
    if i != 0 and not re.search(r"[.?!][)’”»\"']? $", p[:i]):
        fail(f"Ricci {roman}: the span does not start at a sentence start: …{p[max(0, i - 40):i + 20]!r}")
    if not SENTENCE_END.search(p[:j]) or (j != len(p) and p[j] != " "):
        fail(f"Ricci {roman}: the span does not end at a sentence end: …{p[j - 20:j + 20]!r}")
    return p[i:j]


def famous_lines(en_notes, raw):
    """The third-take table + the Italian chapter titles (deliverable 3)."""
    by_roman = {t.split(".")[0]: (t, paras) for t, paras in en_notes[1:]}
    rc = ricci()
    entries = []
    for f in FAMOUS:
        title, paras = by_roman[f["chapter"]]
        n = f["paragraphIndex"]
        if not 0 <= n < len(paras) or f["quoteHint"] not in paras[n]:
            fail(f"famous line {title} ¶{n}: the quote hint is not in that Marriott paragraph")
        entries.append({
            "noteTitle": title,
            "paragraphIndex": n,
            "quoteHint": f["quoteHint"],
            "ricciText": ricci_span(f["chapter"], rc[f["chapter"]], f["ricciFrom"], f["ricciTo"]),
        })
    titles = {"Dedication": "Dedica"}
    for (title, _), name in zip(en_notes[1:], SECTIONS_IT[1:]):
        titles[title] = raw[name][0]
    return {
        "about": ("VX-633 third takes (R-633-4): Luigi Ricci's English (Project Gutenberg #57037), "
                  "the span rendering the same Marriott paragraph, cut from Ricci's coarser paragraph "
                  "at sentence boundaries and copied verbatim (line wrapping undone). Keyed by note "
                  "title + 0-based paragraph index into ThePrince.txt; quoteHint is verbatim Marriott "
                  "from that paragraph. chapterTitlesItalian: each note title → the 1814 text's own "
                  "chapter title line as printed; the dedication has no title line there, so its "
                  "entry is Wikisource's section name. Generated by notes/source/prince-extract.py — "
                  "never hand-edit."),
        "famousLines": entries,
        "chapterTitlesItalian": titles,
    }


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

    # deliverable 3 needs only the English, Ricci and the raw Italian
    table = famous_lines(en_notes, raw)
    FAMOUS_OUT.write_text(json.dumps(table, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"third takes: {len(table['famousLines'])} entries + {len(table['chapterTitlesItalian'])} "
          f"Italian titles → {FAMOUS_OUT.relative_to(ROOT)}")

    aligned, problems = italian_aligned()
    rows = {}
    for (title, en), name in zip(en_notes, SECTIONS_IT):
        if name not in aligned:
            continue
        p, row = check_section(name, raw[name][1], aligned[name], len(en))
        problems += p
        rows[name] = row
    if problems:
        print(f"prince-extract: FAILED — {len(problems)} problem(s); the resources were NOT written:")
        for p in problems:
            print(f"  {p}")
        sys.exit(1)

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
        if [p for _, e in it_back for p in e] != [p for n in SECTIONS_IT for p in aligned[n]]:
            fail("the Italian resource does not round-trip")
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
    for (title, en), name in zip(en_notes, SECTIONS_IT):
        inserted, merged, *_ = rows[name]
        ew = sum(len(p.split()) for p in en)
        iw = sum(len(p.split()) for p in aligned[name])
        tot = [tot[0] + len(en), tot[1] + len(aligned[name]), tot[2] + ew, tot[3] + iw, tot[4] + inserted]
        print(f"{title[:48]:<48}  {len(en):>3} {len(aligned[name]):>3}  {ew:>8}  {iw:>8}  {inserted:>8}  "
              f"{', '.join(merged) or '—'}")
    print(f"{'TOTAL':<48}  {tot[0]:>3} {tot[1]:>3}  {tot[2]:>8}  {tot[3]:>8}  {tot[4]:>8}")
    d = sum(r[2] for r in rows.values())
    lead = sum(r[3] for r in rows.values())
    trail = sum(r[4] for r in rows.values())
    print(f"whitespace normalized in the Italian: {d} doubled-space run(s) collapsed, "
          f"{lead} leading and {trail} trailing space(s) trimmed; verse kept on its lines "
          f"({', '.join(f'{s} ¶{n}' for s, n in VERSE)})")
    print(f"English apparatus stripped: {stripped} block(s) (footnotes + the asserted unmarked apparatus)")
    for d in TOC_DIFFS:
        print(f"title from the chapter's own heading (PG's contents differs) — {d}")
    print()
    for (title, en), name in zip(en_notes, SECTIONS_IT):
        print(f"=== {title}  |  {ALIGNED_FILES[name]}  |  {raw[name][0] or '(dedica)'}")
        for n, (e, i) in enumerate(zip(en, aligned[name])):
            (ef, el), (itf, itl) = first_last(e), first_last(i)
            print(f"  [{n}] EN {ef} … {el}")
            print(f"      IT {itf} … {itl}")
    print()
    print(f"OK — {len(en_notes)} notes · {tot[0]} paragraph pairs · validation green → "
          f"{EN_OUT.relative_to(ROOT)} ({len(EN_OUT.read_bytes())} bytes), "
          f"{IT_OUT.relative_to(ROOT)} ({len(IT_OUT.read_bytes())} bytes), "
          f"{FAMOUS_OUT.relative_to(ROOT)}")


main()
