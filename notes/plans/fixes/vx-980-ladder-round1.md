# VX-980 — LADDER ROUND 1 (cold review, fable-reviewer, 2026-11-19)

Reviewer: fresh `fable-reviewer`, zero implementation context, `notes/REVIEW_PROMPT.md` run verbatim.
Diff reviewed: `main...HEAD` on `vx-980-search-fixes` (37 files, +4,644/−76). Read whole: the run record
(`vx-980-search-fixes.md`), `vx-980-her-rulings.md`, every product file in the diff, the new core test
suites, the key app test suites; ran the run's eight new/changed core suites myself
(`swift test --filter 'SearchTokenizerSweepTests|SearchSymbolWordTests|SearchFoldedWordsBesideATagTests|SearchPunctuationOnlyTests|SearchIndexDoorsTests|SearchIndexRestoreRoadsTests|TrashSearchTests|TrashTextMatchTests'`
→ **45 tests in 8 suites passed**, 0 issues). Verified pin-before-fix structurally: commit `65bac2698`
(pins, test files only) precedes `568c96a9d` / `30789057a` (the fixes). Fence verified:
`git diff main...HEAD --name-only` holds no line under `Sync/`, `Protection/` (product),
`App/Variorum/Shared/`, custody/keychain, `AppBootstrap`, the editor seam, or `Sources/VariorumMCP/`
(the one `Protection/`-pathed file is the rider's TEST, `App/Variorum/VariorumTests/Protection/DataSafetyRoadCountsTests.swift`).

## FINDINGS

### MINOR-1 · App/Variorum/Variorum/Features/Library/RecoveryView.swift (`ask(_:)` ~line 341 / `answers(_:)` ~line 436) · a stale observation answer can land between `ask()` and the restarted task, and for one frame say "The Trash is empty." over a non-empty Trash

**Mechanism (traced):** `ask(_:)` sets `askedWords`, lowers `trashListingLoaded` and bumps
`restartToken` — but does NOT bump `listingQuestion`; only the next `startTrash()` body does. The old
`.task`'s `for try await` can hold a value already resumed (or resumed by a concurrent commit in
`Queries.trashTables` — `variant` is in that region and is written at autosave rate by sync applies or
MCP writes) and deliver it on the main actor BEFORE SwiftUI's task restart runs the new `startTrash`.
`answers(question)` then passes (the old question still equals `listingQuestion`), so `adoptListing`
raises `trashListingLoaded` with the stale rows/passages. Concrete bad frame: words asked, search
matched nothing (`trash == []`); she presses esc → `clearSearch()` → `ask([])`; the old SEARCH
observation delivers one more empty answer → `trash = []`, `trashListingLoaded = true`,
`isSearching == false` → `trashEmptyStateLine` falls to the plain arm and the surface says
**"The Trash is empty."** while the Trash holds rows, until the new task's first answer lands. The
sibling interleave (typing words; the old PLAIN answer re-adopts un-narrowed rows for a frame) is the
same window. The run itself ADDED the question token (the pre-fix code had this class on every
kind-filter change with no guard at all), so this is the last gap in a net the run built, not a
regression — but the new search/clear flow is what makes the misstatement visible.

**Pin (red-on-old):** DEBUG `listingAnswerGate` — start a search `startTrash` (question N), hold its
next answer at the gate, call `clearSearch()` WITHOUT running a second `startTrash`, release the gate:
today `answers(N)` passes and `trash`/`trashListingLoaded` adopt the stale empty answer
(`trashEmptyStateLine == "The Trash is empty."` with rows in the store); after the fix the answer is
dropped. (The shipped `aSupersededQuestionsAnswerIsDropped` covers only the two-`startTrash` race,
where the second start has already bumped the question.)

**Fix shape:** bump `listingQuestion` inside `ask(_:)` (one line — `listingQuestion &+= 1` beside the
`restartToken` bump), so an answer for the pre-ask question is stale the moment the question changes;
`startTrash`'s own bump stays. Implementer-applied (no FINDER-FIXES: mechanical, no design choice).

### NIT-1 · Sources/VariorumCore/Domain/TrashTextMatch.swift:142–150 (`excerpt`) · the comment says a lone over-long word is "kept whole"; the code keeps it CUT at the character limit

**Mechanism:** when the lead (or tail) region holds no whitespace, `gap` is nil and `start`/`end` stay
mid-word, so the partial word is kept cut — exactly the behaviour the batch's own residual 2 records
("a very long word or a CJK run is cut mid-word with '…'"). The doc comment at lines 143–144
("which is kept whole rather than leaving the side empty") misdescribes it. Comment-only; align the
comment with the behaviour (or vice versa — the recorded residual says the behaviour is the intended
one). No pin owed (no behaviour change).

### NIT-2 · Sources/VariorumCore/Domain/TrashTextMatch.swift:56 (`words`) · "Duplicates collapse (asking `red red` asks `red`)" is exact-spelling only

`Red red` keeps both spellings (dedup is by exact string, the match folds case) — harmless (both words
match identically; cost is one extra contains), but the comment overpromises. Wording-of-comment only.

## REVIEW FOCI — each addressed

1. **The predicate follows the INDEX.** YES. `SearchTokenCharacters` is a measured 803-point transition
   table; `SearchTokenizerSweepTests.everyScalarIsAskedExactlyWhenTheLinkedTokenizerFindsAToken`
   re-measures EVERY scalar (1,112,064 checked, asserted) against the tokenizer built from the LIVE
   DDL (`liveTokenizerOptions` reads `sqlite_master`, never a restated literal), prints the re-measured
   table on failure; `theTableWasMeasuredUnderTheLiveIndexsTokenizer` pins the options equal and the
   points strictly ascending; 33 multi-scalar words (combining sequences both orders, ZWJ/flag/VS
   emoji, `½`, `²`, private use, `_`) pin the per-scalar→per-word composition. Characters the pins do
   not name do not exist per-scalar; I probed the composition classes (diacritic-only words, token char
   + diacritic, remove_diacritics stripping) and found no counterexample — a scalar that tokenizes
   alone cannot be emptied inside a word, and a scalar that empties alone is measured as separator.
   Ran green here, 45/45. Drift alarm verified real (a SQLCipher bump or DDL change reds the sweep).
2. **One predicate, every reader.** YES. Grep over product code: the only remaining `query.text`
   readers are `SearchComposer.textHalf` itself, `hits` (line 377, downstream), and
   `SearchTagOffer.words(of:)` (the offers' word walk, behind the `asksWords` guard). Readers wired:
   `listingNarrowing` (so `listingCounts`, the catalog page, tagged blocks follow),
   `searchCounts(…facet:…)`, `searchTagOffers`, `LibrarySearchQuestion.hasWords` (band/sheet/listing
   routing all read `hasWords`), `BookSearchModel.isAnswering` + `search()`, `PaletteModel
   .passageQuestion`. `SearchPunctuationOnlyTests` keeps its law with the ONE justified mirror-line
   change (read in the diff, exactly as the record claims); its 6+3 cases ran green here.
3. **Negation still refuses.** YES. Pinned pure (`theOnePredicateReadsTheTextHalfAsTheIndexDoes` — a
   negation-only tree, a folded word beside a negation, with and without a tag, all `.served` → the
   words road) and against the store (`negationStillRefusesAndAPositiveWordStillAnswers`,
   `aSymbolWordBesideANegationReadsAsADashDoes` — `negativeOnlyText` thrown). Unreachable from doors
   (v1 parser emits no `.not`) — said so in the record. Ran green here.
4. **The wire unchanged in shape.** YES. Zero diff under `Sources/VariorumMCP/`; the `search` tool's
   guard is still `query.isEmpty` (MCPReadTools.swift:1166) and it reads `Queries.searchPassages`
   per scope — no narrowing, counts, offers or routing predicate on the wire, so `— #tag` answers the
   same empty passages before and after and `red +` now answers `red`'s reach-filtered passages
   (better, same shape). R-825 intact — the answer stays a pure function of reachable state.
5. **The index doors honest and deliberate.** YES. Check-writes-nothing pinned on a real on-disk WAL
   store against a FULL sorted dump of every stored row AND `PRAGMA data_version` from a second
   connection, healthy and broken alike, the broken report never healed (`SearchIndexDoorsTests`, ran
   green; the recorded teeth probe turned it red). Rebuild's answer == a following check's, outbox
   unmoved (nothing synced). No automatic path: `nothingRunsUntilShePresses` (refresh runs neither
   door) plus a source-tree scan pinning that only `DataSafetyPane.swift` composes the core doors and
   only it + `CapabilityRegistry.swift` name the two acts (`.surface` only — no ⌘K, no menu). Off-main
   through the session's serial runner (P2; the FTS5 integrity check is spelled as an INSERT, so the
   writer road is REQUIRED, not an accident); one flight per press pinned with a held door.
6. **The Trash search never reaches the living corpus or the main search.** YES. The narrowing runs
   `Queries.trash` itself (same kinds/order/wing/fences, no display limit) and reads families by two
   statements driven from the listed rows' ids — the plan pin
   (`theTextReadIsDrivenFromTheTrashsOwnRows`) asserts `SCAN j VIRTUAL TABLE` first, the four index
   SEEKs, and NO `SCAN` of container/container_block/block/variant; the wing/window/purge-fence pin
   (`theWingFenceTheWindowAndThePurgeFenceAreTheListings`) ran green here; teeth probes B/C/D recorded
   red. No line touches `SearchComposer`'s fence, `SearchIndex.swift`, or the finder's reads. The
   whole-Trash doors read their OWN observations (`startTrashTotal`, `observeEmptyTrashBlocks`) — by
   construction unnarrowed, pinned at the model.
7. **The fence held.** YES — verified by name-filter over the whole diff (above). The restore roads
   were driven by tests only; `SearchIndexRestoreRoadsTests` calls the real road functions
   (`snapshot`, `privateCopy`, `exportReencrypted`, `openStore`, `PlaintextExportReading.read`,
   `importPlaintextExport`, `SyncRow.apply` via the fake-server clients, `PurgeJanitor`) and edits none.
8. **P1.** No finder question gained a read: the token predicate is pure Swift (binary search over 803
   points per scalar); `— #tag` now SKIPS a read in ⌘K and the book band. The Trash search is ∝ the
   wing's Trash by design (her R-980-9…12 shape; the plan pin proves no corpus walk); its observation
   re-read rate is the listing's own named region (recorded residual, honest). The sweep test adds
   seconds to core test runs — test-time only, the deliberate drift alarm.

## CLEAN BILL (load-bearing things checked and found solid)

- **VX-955 mechanism and fix**: re-traced from the code (old `hasTokenCharacter` kept Sm/Sc/So/Sk →
  empty FTS5 phrase ANDed → empty answer); the fix follows the linked tokenizer by measurement, not
  Unicode categories; red-on-old proven by commit order AND the recorded 822,140-scalar disagreement;
  the oracle in `SearchSymbolWordTests` is non-tautological (compares listing+band against the
  words-only question over a real corpus, non-empty asserted).
- **VX-954**: the six VX-888 shapes pinned equal to `#flora` across band × facets, narrowed listing,
  tagged blocks, associated books, offers; `+ #flora` agrees with `— #flora` (the two fixes compose);
  `searchCounts`'s no-words arm reaches `listingCounts` for folded-beside-tag because
  `listingNarrowing`'s guard is the one predicate — verified by reading the whole call chain.
- **R-980-5 as built**: `textHalf` is the ONE reading; `asksWords` and `holdsNothingSearchable` derive
  from it so road and sentence cannot disagree; a punctuation-only field stays a typed search (band
  "nothing found", offers for a literally-named tag kept, days/book-state filters pinned); the sentence
  has one home (`SearchAnswerCopy.emptyAnswer`) read by both sheets; ⌘K deliberately unchanged.
  A worn day cannot co-exist with folded-only text (the parser derives `wornDay` from free words that
  stay in the text — read in `SearchQueryParser`), so no hidden day-armed says-why hole exists.
- **The restore-roads trace**: every claimed road has a real pin that RUNS it (backup-pair make-mine,
  send-and-open, two era copies incl. a pre-index v1_21, plaintext bring-in incl. an era export, first
  sync round over the fake server in 4-row windows, restore-then-resume with an edit + tombstone +
  purged-ids ledger); doc-for-doc and answer-for-answer comparisons, not just `isHealthy`; teeth
  recorded red (19 issues under four mutations). The handoff table matches the pins one for one.
- **VX-79's face**: model state machine (quiet/working/found/refused), one flight across both doors set
  before the first suspension on the main actor (`@MainActor` class verified), doors injected so pins
  drive without a store; registry declarations follow the pane's `.surface` precedent; Settings search
  row wired into `paneRowIDs`; `systemReason` strips GRDB's appended SQL. Strings all live in
  `DataSafetyCopy`, sentence-case rules honored (button title case is the pane's own convention).
- **VX-93's read**: `trashContainerTextsSQL`/`trashBlockTextsSQL` encode exactly Put back's exact-stamp
  family (cascade-stamp blocks, stamp-dead-or-live takes, archived takes included per P-980-B3-1;
  a live preserved original joins only live takes via the NULL-stamp comparison); books/gatherings by
  name only; order `(position, id)` per convention; `matchesEvery` is per-word-any-text (name OR text,
  her R-980-9); the passage picks the earliest unexplained word in reading order; the 500-window
  applies to matches with the +1 truncation probe (P-980-B3-3 as recorded).
- **The field**: AppKit, `canBecomeKeyView` false (never the opening caret, no Tab stop — VX-332's
  law, the sidebar precedent), no intrinsic width (typing moves nothing), esc clears only a non-empty
  field (the key passes on otherwise), programmatic clears go through the field editor without
  re-firing `controlTextDidChange`.
- **Debounce/token plumbing**: 180 ms with ask-at-once on empty, whitespace edits ask nothing, ⏎ asks
  now, `clearSearch` on disappear; the superseded-question pin exercises the two-start race through the
  DEBUG gate (MINOR-1 above is the one remaining window).
- **Process**: pin-before-fix held per member (commit order verified); the record's test counts match
  what I ran; the gate records are internally consistent; no canon or shared-ledger file touched on the
  branch; commits carry no trailers and read as public copy; `KnownIssuesAndTechDebt.md` owns nothing
  this run owed. Open (ledgered, not findings): gate 3 — batch 3's app suites
  (`TrashSearchModelTests`, `TrashSearchFieldTests`), the Trash walk, and the
  `DataSafetyRoadCountsTests` re-run after the rider.

**Verdict:** no BLOCKER, no MAJOR. One MINOR (the stale-answer window, pinnable, one-line fix shape
given), two comment-level NITs. Per R-980-4 (a further round only while the prior found a MAJOR or
BLOCKER), this round earns no round 3 beyond the standing re-check of the fixes.
