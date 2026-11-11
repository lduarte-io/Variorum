# VX-990 — the quoted-novel fixture swap

**Not done here, first:** no history rewrite (the private rewrite rules own that, from the
removed-lines list kept outside the repo); the two app-target suites touched
(`DocumentImportDoorTests`, `NoteExportTests`) were NOT run — they need a stage claim and the
change there is string literals only; tracked images were spot-checked, not audited (see Open
items); no PR merge (the branch is left pushed).

## FOR A LATER READER

**What and why.** Quoted novel lines replaced with invented fixture text (R-oss-49). The open
source sweep found the opening sentences of the novel her PT/EN reading project follows — the
author's own words in English and in the Portuguese translation, plus close paraphrases of them —
standing as fixture and sample text. Her ruling: those lines leave; invented text of the same
shape replaces them; the book title, her study notes ("a escola", "o museu") and every reference
to the reading project (the `percy` tags, "the lightning thief" as a book name, chapter names
such as "1 o semideus") stay.

**The mechanism of the swap.** One ordered table of literal replacements (most specific literal
first, so a short literal never eats part of a longer one), applied to the named files, then the
hand-shaped places (mockup paragraphs that wrap, one record line that described a screenshot).
The invented text is one small made-up story — someone who never asked to inherit a lighthouse on
an island with a tide-bound ferry — kept in both languages, same block count, same sentence count
per block, same line structure (the three-line unlabeled take stays three lines; the
two-line english take keeps its internal newline). Every assertion that names the text was swapped in
the same table, so the tests assert the same shapes over new words.

**The pieces.**
- The sample folder: `notes/plans/13n-a-sample/o ladrão de raios/1 o semideus/01 abertura.md`
  (rewritten whole: three blocks, english takes, the numbered three-line take) and its README
  (the "original text" claim corrected to what is now true; the format documentation kept).
  `Tests/VariorumCoreTests/SampleBookDrillTests.swift` reads that folder from disk; its expected
  arrays moved with it.
- Core and MCP suites (string literals and comments only): `VariorumDocumentTests`,
  `DocumentFormatRoundTripTests`, `DocumentImportOperationTests`, `MCPWriteActsTests`,
  `SampleBookDrillTests`, `MCPServerTests`, `MCPTakeLabelFormServerTests`, `MCPWriteServerTests`;
  the doc comment's example in `Sources/VariorumCore/Domain/VariorumDocument.swift`.
- App-target suites (literals only, not run): `App/Variorum/VariorumTests/DocumentImportDoorTests.swift`,
  `App/Variorum/VariorumTests/NoteExportTests.swift`.
- Design records: `notes/plans/13n-sitting-mockups/mcp-door-mockups.html` (§5's three takes and
  §8's format sample), `notes/plans/vx-156-grant-ux-mockups.html` (one wire example),
  `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md` (a screenshot's description now names the
  block without quoting it).

**Evidence.** The core suites named above green at the branch head (the run lines are in the
LIVE STATUS below); a tree-wide grep of the known phrases (EN and PT) at 0 outside the public-domain
sample library.

**Open items.**
- Git history still carries the removed lines; the rewrite is the OSS rehearsal's, from the
  private list.
- Tracked PNG captures were spot-checked (two, both the public-domain Sherlock Holmes book), not
  audited one by one.

## LIVE STATUS

| Piece | State |
|---|---|
| Worktree `~/dev/variorum-vx-990`, branch `vx-990-quoted-fixture-swap` off main `00eb5a5d4` | done |
| 1 · sample folder + README + drill test + this record | committed |
| 2 · core + MCP suites + `VariorumDocument` doc comment | next |
| 3 · app-target suites (literals only, not run) | next |
| 4 · mockups + records | next |
| 5 · suites green at the end, greps at 0, private removed-lines list | next |
