# 13n-a — the Variorum document format: HER MORNING HANDOFF (2026-10-09, the overnight run)

## Your checklist (the things only you can do, in order)

1. **Review and test the build — your refresh-not-merge order is honored:
   PR #144 is OPEN and NOT merged.** The branch is `vx-117-13n-a`.
2. **The GUI walk and the /Applications refresh were HELD all night** — your
   real-store app (PID 73118) ran the whole time and was never touched; the
   walk guard refused correctly. When you're ready: quit the app (or say the
   word and I quit nothing — you quit it), then this session (or any fresh
   one) runs the W1–W7 walk from the UNIT RECORD under a stage claim and
   finishes with the A1-railed /Applications refresh from this branch.
3. **Try the real thing:** import the committed sample —
   `notes/plans/13n-a-sample/o ladrão de raios/` — through **File ▸ Import…**
   (or drop the folder on the Bookcase): one PT/EN book, two chapters,
   fanned blocks; open it in Lenses with a lens per language; then ⌥⌘Z once
   (the whole book leaves), ⇧⌥⌘Z (it returns whole). Copy for AI is in the
   note ▾ menus and ⌘K.
4. **Rule on the overnight PROVISIONALs** (each built-as-stated, reversible):
   the architect rulings R-ARCH-13na-1…3 and the implementer's P-13na-1…5 —
   the honest sheet is below; the full text is the plan file's rulings
   section and UNIT RECORD.
5. **The ladder's outcome: closed clean at round 2.** Round 1 (fresh
   opus-reviewer): 0 BLOCKER · 1 MAJOR · 4 MINOR · 4 NIT — the MAJOR was a
   redo that resurrected a hand-deleted book off the wrong tombstone stamp;
   all nine findings dispositioned and fixed pin-first in a fresh session.
   Round 2 (fresh reviewer): all nine verified implemented-as-worded;
   0 BLOCKER · 0 MAJOR · 1 MINOR · 3 NIT, no round 3 earned — the MINOR
   (a retried-undo regression round 1's own fix introduced) and one NIT
   (a brace-bearing tag silently killing the whole header on re-import)
   were fixed by ME at adjudication, pin-first, the first to the reviewer's
   own scratch-verified shape; two were wording. **Honest flag: those two
   orchestrator-written fixes are pin-covered but not cold-reviewed (no
   round 3 was earned)** — say the word if you want a fresh pass over
   `ead486c4` + `1ae2ebc0` before your merge. Two pre-existing/adjacent
   finds became tickets rather than 5am fixes: VX-119 (the 13c
   single-container undo pair has the MAJOR's shape — probe-first + a class
   sweep) and VX-120 (door-level package semantics; the Pro's probe
   answered, the Air's owed).

## What landed (one paragraph)

Level 0, whole: the Variorum document format lives in
`Domain/VariorumDocument` (the export re-expressed over the SAME serializer
— one spelling, byte-pinned), with a fail-honest line-numbered parser;
`importDocument` (a file → a bookless note in the Pool) and `importBook`
(a folder → an unshelved book, subfolders = chapters, digit-aware order)
each ONE transaction and ONE compound undo entry whose redo revives exact
rows; File ▸ Import… + the Bookcase drop (outline only while a file drag is
over the board) + Copy for AI, all registry-declared; tags adopt-or-mint by
path through the one application road, so a living book's rule hears an
imported tag. Core 2,460/284 + the fix pass's 42/42 and 143/12 green, 0
skipped; Mac suites over every changed file green; phone builds. Zero
`Sync/`, zero schema, zero editor seam.

## The honest sheet (what you're ruling on)

- **R-ARCH-13na-1 — the format parses as the join's exact inverse** (blank
  line = block boundary; a single newline is content; k ≥ 3 newlines store
  k−1). I ruled this OVER the plan's own "standing bulk rule" letter after
  the implementer surfaced the consequence: under the bulk rule your rows
  never round-tripped and a hard-wrapped file (Gutenberg txt — your Percy
  case) became one block per LINE. Paste is untouched and pinned side by
  side. Two byte-level residuals are recorded as pins, both inherent to the
  export's bytes, not the parse: (a) a block storing exactly ONE trailing
  newline exports the same bytes as unspaced, so that one spacing reads
  back unspaced; (b) a blank-chosen fan's section right after a FANLESS
  paragraph is byte-identical to that paragraph owning the fan, so those
  takes land there — nothing refuses, every take arrives, rows differ. The
  full-fidelity answer to both stays 13m's edition (R-13n-8).
- **R-ARCH-13na-2 — any export re-imports whole:** a paragraph-less
  Alternates section now mints a block with an empty chosen take (the store
  shape that exports it) instead of refusing. Garbled/unterminated sections
  still refuse with line numbers.
- **R-ARCH-13na-3 — FORK-D deferred as VX-118:** the Library/scraps drops
  still run the plain import; routing their files through the one importer
  is ticketed.
- **P-13na-1…5 (implementer, adopted):** deep-nested files ride into their
  top-level chapter · a folder named like a live book refuses (E13) ·
  import-minted tags survive ⌥⌘Z as vocabulary (§9 excludes tags from
  structural undo) · Copy for AI is plain text on the clipboard · the door
  reads `.variorum`/`.md`/`.markdown`/`.txt`/`.text`.
- **IC-1…16 (implementer calls, adopted)** — the notable ones: the capture
  brace grammar moved INTO core byte-for-byte and the app delegates; a
  path-derived name is stored NFC (a real bug, pin-first: macOS hands out
  decomposed names SQLite then can't match); File ▸ Import… opens a lone
  imported item; a multi-pick import is all-or-nothing.

## Where everything is

- Plan + UNIT RECORD + rulings: `notes/plans/phase-13n-a-document-format.md`
- The sitting record (R-13n-1…11): `notes/plans/phase-13n-sitting-record-2026-10-09.md`
- Ladder rounds: `notes/plans/13na-ladder-round1.md` (findings +
  dispositions) · `notes/plans/13na-ladder-round2.md` (verdicts, R2
  findings, the close)
- Mockups: `notes/plans/13n-sitting-mockups/mcp-door-mockups.html`
- QUESTIONS #207 (the sitting's PROVISIONALs; this unit's P/R items land at
  YOUR merge, per your order)
- Board: VX-117 In Review (child of VX-25, In Progress); VX-118 minted
  (FORK-D); VX-116 Done (the sitting, PR #143 merged `062e8534`)

## After your yes

Your merge of PR #144 is the merge moment (I can run it at your
word: ledgers on latest main — AppSpec §9/§12 contract lines as proposed in
the UNIT RECORD's closeout section, QUESTIONS, the in-flight row retired,
the master-plan closeout paragraph, branch deleted, worktree removed); then
13n-b's plan is written and its kickoff is yours.
