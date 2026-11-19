# VX-980 — LADDER ROUND 2 (cold review, fable-reviewer, 2026-11-19)

Reviewer: fresh `fable-reviewer`, zero implementation context, `notes/REVIEW_PROMPT.md` run verbatim.
Round 2's anchor: round 1's findings (`vx-980-ladder-round1.md`) and their dispositions (the run
record's THE LADDER section) — the standing re-check of the fix pass (`887c062fa` pin · `e7b24bb71`
fix · `ebf9d9ed6` comments), plus a fresh pass over the whole diff (`main...HEAD`, 38 files).
Ran myself: `swift test --filter 'SearchTokenizerSweepTests|SearchSymbolWordTests|SearchFoldedWordsBesideATagTests|SearchPunctuationOnlyTests|SearchIndexDoorsTests|SearchIndexRestoreRoadsTests|TrashSearchTests|TrashTextMatchTests'`
→ **45 tests in 8 suites passed**, 0 issues (matches round 1's own run). Worktree clean; fence
re-verified by my own name filter over `git diff main...HEAD --name-only` (no `Sync/`, no
`Protection/` product line, no `App/Variorum/Shared/`, no custody/keychain, no `AppBootstrap`, no
editor seam, no `Sources/VariorumMCP/`).

## THE RE-CHECK OF ROUND 1'S FIXES

**MINOR-1 (fix `e7b24bb71`, pin `887c062fa`) — CONFIRMED SOUND.**
- The fix is exactly the round's final call: `listingQuestion &+= 1` inside `ask(_:)`
  (`RecoveryView.swift:344`), beside the `restartToken` bump, both behind the one
  `words != askedWords` guard; `startTrash`'s own bump stays; the token's doc comment updated.
  Traced every caller of `ask` (`editSearch`'s debounce, `askSearchNow`, `clearSearch`): each now
  stales an in-flight answer the moment the words change, and a mounted view always restarts
  (the same guard gates both bumps). The unmounted case (`clearSearch` on disappear) has no
  answer to drop.
- The pin traces RED-ON-OLD by mechanism: on the pre-fix code `searchQuestion` (read after the
  ask, `listingQuestion &+ 1`) equals the held search answer's question; `clearSearch()` leaves
  the question unmoved; the released answer passes `answers(question)`, `adoptListing([], …)`
  blanks the six rows, raises `trashListingLoaded`, and `trashEmptyStateLine` (isSearching false,
  kindFilter nil) says "The Trash is empty." — the pin's exact three expectations
  (`!trashListingLoaded` · `trash.count == 6` · `trashEmptyStateLine == nil`) go red, nothing
  else. On the fixed code the ask moves the question past the held answer's, the guard drops it,
  and the 0.5 s settle times out with the rows intact. GREEN-ON-NEW traced the same way.
- The re-anchored `aSupersededQuestionsAnswerIsDropped` (`listingQuestion &+ 1` read AFTER the
  ask) is neutral on the old code (the ask moved nothing there) and right on the new — verified
  by walking both trees' question numbers through the test's sequence.
- `startTrashTotal`'s "Ladder R1 MINOR-1" comment (`RecoveryView.swift:460`) is VX-670's ladder,
  pre-existing (`42f25fca5`) — not this round's; no confusion in the code, only in a reader who
  greps "MINOR-1".
- Still owed, as the ladder table already says (row 6): the pin has been COMPILED
  (`l1-bft-pin.log` / `l1-bft-fix.log` end "** TEST BUILD SUCCEEDED **", EXIT=0 — read) but never
  RUN; the gate owes `TrashSearchModelTests` (8 tests) green at head and red (that one test,
  3 issues) with `e7b24bb71` reverse-applied in the snapshot.

**NIT-1 and NIT-2 (`ebf9d9ed6`) — CONFIRMED comment-only and now accurate.** Read against the
code: `excerpt`'s new comment matches the `gap`-nil behaviour (a cut with no whitespace between
it and the match stays at the limit, the word kept cut mid-word; a cut inside a word steps TOWARD
the match); `words`' new comment matches the exact-string dedup (`Red red` keeps both, harmless
under the folding match). No compiled behaviour changed in the commit (every hunk a comment).

## FINDINGS

**No BLOCKER. No MAJOR. No new MINOR.** One NIT:

### NIT-1 · notes/plans/fixes/vx-980-search-fixes.md (THE LEDGER, row 6) · the ledger row says "The ladder | NOT STARTED" while round 1 and its fix pass are recorded above it

Record-keeping staleness only; the closeout updates the ledger. No pin owed (not code).

## OPEN ITEMS (not findings — owed before the merge, already ledgered or needing triage)

1. **Gate 3** (the orchestrator's): batch 3's app suites (`TrashSearchModelTests` now 8 ·
   `TrashSearchFieldTests` 3) and the Trash walk; the `DataSafetyRoadCountsTests` re-run after
   `2eaf1ec93`; the MINOR-1 pin's green-at-head + revert-red leg (ladder table row 6).
2. **Round 1's out-of-scope observation** (the kind filter's / sort's / wing's restart beat —
   the pre-existing one-frame "The Trash is empty." lie, traced in the run record's ladder
   section) is still untriaged: it needs a ticket (or a deliberate no-ticket line) at closeout.
   I re-read the code (`kindFilter`/`oldestFirst` `didSet`s bump `restartToken` only) and confirm
   it is pre-existing (`173a2f678`, 13j) and not touched by this run's diff.
3. The closeout itself (canon deltas in the two-file shape, the ratify bundle, the parity line,
   the ticket triage) — pending, as the record says.

## REVIEW FOCI — round 2's own pass (each verified in this session, not inherited)

1. **The predicate follows the INDEX** — re-ran the sweep green (45/8 includes it); read
   `SearchTokenizerSweepTests` myself: `liveTokenizerOptions` reads `sqlite_master`'s
   `CREATE VIRTUAL TABLE search_fts` DDL (never a restated literal) and the oracle is the linked
   tokenizer through `FTS5_TOKENIZE_QUERY` — the drift alarm is real. `SearchTokenCharacters` is
   803 ascending transition points, binary-searched, pure (P1).
2. **One predicate, every reader** — my own grep over product code: zero `query.text != nil`
   routing twins remain (the one app hit is a doc comment; DiagnosticsPane's `report.text` is
   unrelated). Readers verified in the diff: `listingNarrowing`, `searchCounts(…facet:…)`,
   `searchTagOffers`, `LibrarySearchQuestion.hasWords`, `BookSearchModel.isAnswering` +
   `search()`, `PaletteModel.passageQuestion`. `SearchPunctuationOnlyTests`' one mirror-line
   change read and justified; ran green.
3. **Negation still refuses** — `aSymbolWordBesideANegationReadsAsADashDoes` and
   `negationStillRefusesAndAPositiveWordStillAnswers` ran green here; `textHalf` maps the
   negation-only throw to `.served` so the words road keeps the refusal.
4. **The wire unchanged in shape** — zero diff under `Sources/VariorumMCP/` (my own name
   filter); the composer-level change improves `red +` and leaves `— #tag`'s empty passages
   byte-identical; R-825 intact.
5. **The index doors honest and deliberate** — `SearchIndexDoorsTests` ran green here
   (check writes nothing, on a real WAL store, `data_version` from a second connection; rebuild's
   answer = a following check's); the registry declarations are `.surface` only (read in the
   diff); `runSearchIndex`'s one-flight guard sets `.working` before the first suspension on a
   `@MainActor` model (verified the class annotation); the doors run through the session's
   serial off-main runner (P2).
6. **The Trash search never reaches the living corpus** — `TrashSearchTests` ran green here,
   the plan pin among them (`SCAN j VIRTUAL TABLE` driver, four index SEEKs, no store-table
   scan); `Queries.trashSearch` narrows `Queries.trash` itself (same kinds/order/wing/fences,
   no display limit); the whole-Trash doors read their own observations
   (`startTrashTotal`, `observeEmptyTrashBlocks` — read in `RecoveryView.swift`).
7. **The fence held** — re-verified myself (name filter over the whole diff): clean.
8. **P1** — the token predicate is pure Swift over the parsed words; `— #tag` now skips a read
   in ⌘K and the book band; the Trash search is ∝ the wing's Trash (its observation's re-read
   rate is the listing's own named region — the recorded, honest residual).

## CLEAN BILL (load-bearing things this round checked itself and found solid)

- The three fix commits are exactly the round-1 final calls — nothing more rode in them
  (`e7b24bb71` is 7+/3− in one file; `ebf9d9ed6` is comments only — read hunk by hunk).
- The 45-test core battery green at head, matching the record's and round 1's counts; the
  restore-roads pins RUN the real roads (make-mine, two era copies, plaintext bring-in, first
  sync round, restore-then-resume, send-and-open) — re-ran green.
- `SearchComposer.textHalf` / `asksWords` / `holdsNothingSearchable` derive from one reading, so
  the road and the says-why sentence cannot disagree; `SearchAnswerCopy.emptyAnswer` is the one
  home read by both sheets; ⌘K deliberately speaks no empty sentence.
- `TrashTextMatch`'s sameness is `SearchTagOffer.fold`'s options; the match and the passage's
  place are one primitive (`range(of:options:)`); `matchesEvery` is per-word-any-text, empty
  words match nothing.
- `trashContainerTextsSQL` / `trashBlockTextsSQL` encode Put back's exact-stamp family (archived
  takes included per P-980-B3-1; a live preserved original joins only live takes); books and
  gatherings by name only; takes by their own row.
- The field: `canBecomeKeyView` false, no intrinsic width, esc clears only a non-empty field,
  programmatic clears go through the field editor; strings in one home each
  (`TrashSearchCopy`, `DataSafetyCopy`, `SearchAnswerCopy`) and every new rendered string is
  listed in the record as provisional (R-980-4).
- The built shapes match her rulings as recorded verbatim (`vx-980-her-rulings.md` read whole):
  R-980-5's say-why line and its reach, R-980-9…12's Trash search, R-980-2's trace-first (the
  handoff table matches the pins), R-980-3's Fable reviewer, R-980-4's ladder terms.
- No canon or shared-ledger file touched on the branch; commits carry no trailers and read as
  public copy; worktree clean after the teeth probes (verified `git status`).

**Verdict: no BLOCKER, no MAJOR — round 1's fixes stand confirmed.** Per R-980-4 the ladder ends
here; what remains before the merge is gate 3's owed runs (the open items above), not another
round.
