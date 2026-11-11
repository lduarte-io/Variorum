# VX-990 — the quoted-novel fixture swap

**Not done here, first:** no history rewrite (the OSS rehearsal's rewrite rules own that, from the
removed-lines list kept outside the repo); the two app-target suites touched
(`DocumentImportDoorTests`, `NoteExportTests`) were NOT run — they need a stage claim, and the
change there is string literals only; tracked images were spot-checked, not audited (see Open
items); no PR, no merge (the branch is left pushed).

## FOR A LATER READER

**What and why.** Quoted novel lines replaced with invented fixture text (R-oss-49). The open
source sweep found the opening sentences of the novel her PT/EN reading project follows — the
novelist's own words in English and in the Portuguese translation, plus close paraphrases of them —
standing as fixture and sample text. Her ruling: those lines leave; invented text of the same
shape replaces them; the book title, her study notes ("a escola", "o museu") and every reference
to the reading project (the `percy` tags, "the lightning thief" as a book name, chapter names
such as "1 o semideus", the walk records' search term) stay.

**The mechanism of the swap.** One ordered table of literal replacements (most specific literal
first, so a short literal never eats part of a longer one), applied to the named files, then the
hand-shaped places (mockup paragraphs that wrap). The invented text is one small made-up story —
someone who never asked to inherit an observatory on an island with a tide-bound ferry (not a
lighthouse: "lighthouse" is already the repo's search fixture word, and a swap must not seed new
hits for it) — kept in both languages, with the same block count, the same sentences per block
and the same line structure (the three-line unlabeled take stays three lines; the two-line english
take keeps its internal newline). Every assertion that names the text was swapped by the same
table, so the tests assert the same shapes over new words; the one count-shaped assertion
(`DocumentImportOperationTests`' baseline length) is computed from the literals themselves.

**The pieces.**
- The sample folder: `notes/plans/13n-a-sample/o ladrão de raios/1 o semideus/01 abertura.md`
  (rewritten whole: three blocks, english takes, the numbered three-line take) and its README
  (the "original text" claim replaced by what is now true; the format documentation kept).
  `Tests/VariorumCoreTests/SampleBookDrillTests.swift` reads that folder from disk; its expected
  arrays moved with it.
- Core and MCP suites (string literals only): `VariorumDocumentTests`,
  `DocumentFormatRoundTripTests`, `DocumentImportOperationTests`, `MCPWriteActsTests`,
  `SampleBookDrillTests`, `MCPServerTests`, `MCPTakeLabelFormServerTests`, `MCPWriteServerTests`;
  the doc comment's example in `Sources/VariorumCore/Domain/VariorumDocument.swift`.
- App-target suites (literals only, not run): `App/Variorum/VariorumTests/DocumentImportDoorTests.swift`,
  `App/Variorum/VariorumTests/NoteExportTests.swift`.
- Design records: `notes/plans/13n-sitting-mockups/mcp-door-mockups.html` (§5's three takes and
  §8's format sample); `notes/plans/vx-156-grant-ux-mockups.html` (the divide-addressing wire
  example — its first half, and the two "starts with" phrases so the example still splits where it
  says); `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md` — one line described a screenshot
  of her store by quoting its first block; it now names the block without quoting it (an invented
  quote there would misstate what the capture shows).

**Evidence.** The eight core and MCP suites green at the branch head — 65 tests in 5 suites
(VariorumCoreTests) and 28 tests in 3 suites (VariorumMCPTests). A grep of the known phrases, EN and
PT (the sentences, their paraphrases, the translation's own opening), at 0 across the tracked tree
at the branch head; "semideus" survives only as a chapter name and as the search term the 13n-b
walk records name.

**Open items.**
- Git history still carries the removed lines; the rewrite is the OSS rehearsal's, from the
  private list (and a private replacement table beside it, in the rehearsal's rule format).
- Tracked PNG captures were spot-checked (two, both showing the public-domain Sherlock Holmes
  book), not audited one by one.
- The two app-target suites run at the next stage-held app-suite run.

## LIVE STATUS

| Piece | State |
|---|---|
| Worktree `~/dev/variorum-vx-990`, branch `vx-990-quoted-fixture-swap` off main `00eb5a5d4` | done |
| 1 · sample folder + README + drill test + this record | committed `66326cb11`, noun follow-up `3cfa03331` |
| 2 · core + MCP suites + `VariorumDocument` doc comment | committed `026b12d8f` |
| 3 · app-target suites (literals only, not run) | committed `3bc692606` |
| 4 · mockups + records | committed `f172a04ca` |
| 5 · suites green at the end (93 tests, 8 suites), greps at 0, private removed-lines list | done |
