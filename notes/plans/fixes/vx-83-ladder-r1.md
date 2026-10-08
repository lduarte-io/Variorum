# VX-83 — Ladder round 1 (cold review)

**Reviewer:** fable-reviewer ("searchfollowup ladder reviewer"), fresh session, zero implementation
context, `notes/REVIEW_PROMPT.md` run verbatim over `main...HEAD` on `vx-83-search-followup`
(merge-base `34fa645b`, HEAD `7203bda0`; 72 files, +6,575/−453).
**Read whole, in-session, never delegated:** CLAUDE.md + auto-loaded canon · the run record
`notes/plans/fixes/vx-83-search-followup.md` (all three unit records, the sitting record, the
rulings, §FIX PASS, both walk executions/judgments) · `notes/plans/phase-13o-search.md` whole
(the substrate's rulings R-13o-1…15, §FORK RULINGS F1–F4, §R-13o-4 RECORD, U1–U3, both ladder
rounds) · `notes/SyncSpec.md` IN FULL (the diff carries a migration) · `notes/TEXTKIT2_NOTES.md`
(the diff touches the jump/reveal seam) · `notes/KnownIssuesAndTechDebt.md` · the master plan's
in-flight table (main's copy — the VX-83 row) · the diff itself, file by file, and the test
suites by source. No "Review foci" section exists in the record or the 13o plan; the three
units' WATCH ITEMS were each dispositioned below anyway.

**Ran myself (headless, no stage):** `swift test --filter` over the run's core families — 126
tests green across SearchSavepointCaptureTests, SearchSavepointFacetTests, SearchTagListingTests
(+ the seam suite, whose measurement REPRODUCED: driven page 41→51 vs predicate-in-sort-walk
41→132 across 2k→10k), SearchTagOfferTests, SearchFindSeedSpanTests, SearchSnippetRawTextTests,
MigrationTests, SearchP1Tests (the savepoint cost-shape numbers reproduced: default-road delta
×1.13 / ×1.02, facet ∝ matches), SearchQueryParserTests, SearchPassages/Groups,
SearchModeFacetTests, SearchGatheringScopeTests. **Read, not re-run:** the Mac `xcodebuild`
suites (four recorded zero-skip slot runs incl. the announced red-on-old revert table, plus two
accepted walks); I read the pins' source instead and verified two committed walk shots with my
own eyes (17-V1: the underscored span whole in the find bar, 3w selected, below the bar;
21-V4: the commits facet end-to-end, "commit · oct 8", the band's words).

## Verdict: 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT

## Findings

- **[MINOR] · Sources/VariorumCore/Queries/TagListingQueries.swift:31–47 (`catalogTaggedBlocks`)
  + App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift (`blockLine`) · Under a
  `#tag` alone in the Blocks scope with `+ archived` armed, a block whose HOME NOTE is archived
  lists with NO "archived" mark — while the same note's row in the Notes scope wears
  `CatalogArchivedMark` (P-VX83-3) and the answer sheet's own rule is R-13o-6's letter, "rows
  say which they are" (quoted as the rule at 13o U3 P5).** Evidence (traced): the blocks
  narrowing's `.includingArchived` arm drops only the version fence (`SearchComposer.
  listingNarrowing`, the `.blocks` case), so a block in an archived note enters the listing;
  `catalogTaggedBlocks`' SELECT never reads `c.archived_at`; `CatalogHit.isArchived` defaults
  false; `blockLine` renders handle · "in <home>" with no mark — the row reads as living. (An
  archived BLOCK itself never lists — `archiveBlock` releases the placement and the road JOINs a
  live placement — so the gap is exactly the archived-HOME case.) Red-on-old pin: a
  state-transition test — block-tagged block in an archived note, tag alone, facet on →
  `catalogTaggedBlocks`' hit carries the archived fact / the row wears the mark; red today (the
  fact is absent). Fix: select `(c.archived_at IS NOT NULL) AS archived` in
  `catalogTaggedBlocks`, carry it into `CatalogHit.isArchived`, wear `CatalogArchivedMark` in
  `blockLine` (the Notes rows' exact idiom). Severity MINOR, not MAJOR: a facet-gated corner on
  a provisional surface (P-VX83-4 defines the row face without addressing it) — but the honest-
  labeling letter is ruled, so it is not a taste call.

- **[NIT] · App/Variorum/Variorum/Features/Library/LibrarySearchBand.swift:52–56, 119–131
  (`offersCommits` + body) · An ARMED commits facet goes invisible when the words leave the
  field, then resurfaces still-armed when words return.** Evidence (traced): both chip states —
  the `+ commits` invitation AND the armed `commits ✕` — sit inside `if Self.offersCommits
  (question)` (words only); `includesSavepoints` survives on `LibrarySearchModel` until the
  field empties (`resetFacet` runs only when `question == nil`). Type words → arm `+ commits` →
  delete down to `#classics`: the `commits ✕` chip vanishes while the facet stays armed; type a
  word again and the answer includes savepoints with no fresh act. No wrong output while hidden
  (the text-less roads never consult `includesSavepoints` — I traced `listingNarrowing`,
  `listingCounts` and the association reads; nothing it could narrow, which is the ruled reason
  the chip isn't OFFERED there), so this is clarity-class, not pinnable — but the armed chip's ✕
  is the facet's only clear door short of emptying the field, and it disappears while armed. The
  archived facet's chip, by contrast, stays visible under a tag alone. One-line shape: show the
  armed `commits ✕` whenever `includesSavepoints` is true; keep the invitation words-only.

- **[NIT] · App/Variorum/Variorum/Features/Library/LibraryWhenDoor.swift:175 · The month
  binding's last-resort fallback is a hard-coded `LibraryWhenMonth(year: 2026, month: 1)`.**
  Evidence: unreachable in practice — the door's press always seeds `month` via `openingState`
  before `shown = true` (and the U-B record flags it) — but if a future presentation road ever
  reaches it, January 2026 is wrong forever, and `LibraryWhenMonth(dayKey: today)` is available
  in the same expression (the first fallback already computes `opening(range:today:)`, which
  returns nil only for an invalid `today` — in which case any real-day anchor would do better
  than a fixed past month). Clarity-class; no pin.

## Dispositions I made as reviewer (no code owed)

- **F-W-1's HOLLOW classification — UPHELD.** The §FIX PASS ran the pin first (green on pre-fix
  for plain three-run spans), then traced the real mechanism (the seeded Markdown underscores =
  punctuation gaps, F-W-2's class). That is the hallucination guard working as written; the
  regression pin (`theSeededEmphasisGapsCoalesceEndToEnd`) stands and I re-ran it green.
- **P-VX83-W3 (the one-line-note flush caret) — record-only is right.** The line is VISIBLE
  (her complaint was HIDDEN); the tiny-document corner rides the bundle.
- **The worn-day/tag double-count I hunted in `searchCounts`' no-words branch is IMPOSSIBLE:**
  `SearchQueryParser` derives `wornDay` from `freeWords`, which always mint text terms, so
  `wornDay != nil ⇒ text != nil` and the text-less branch never sees a worn day. Not a finding.

## Clean bill (checked specifically, found solid)

1. **The migration class (v1_23) is exactly SyncSpec §12's local-only derived class** — read
   SyncSpec in full: `ALTER TABLE search_doc` (local-only derived), the `search_text` view
   recreated, three capture triggers ON `commit_point` writing ONLY the doc family; zero
   `Sources/VariorumCore/Sync/` lines, zero `Server/` lines, marker 12 untouched; the derived
   set is table-level and the family adds no table (completeness walk green untouched — suite
   re-run). The frozen kind lists are real: `sourcesV1_22` read by `create` + v1_22's backfill
   alone, `sourcesV1_23 = + savepoint`, `sources` = current for the rebuild door and integrity.
   Migration id v1_23 clean (13x merged with zero migrations; main checked).
2. **R-13o-4's letter held.** The savepoint triggers read NEW/OLD and the doc family only; the
   capture-set pin was made SOURCE-AWARE (justified edit, strictly stronger — a savepoint
   trigger reading `variant`, the refused FORK 1 (B) shape, turns it red). FORK 1 = A's five
   conditions each located: the own-row mirror (INSERT · physical DELETE · the load-bearing
   UPDATE arm), query-time take liveness BY KEY under the facet only, the integrity rule doc ⇔
   physical row (a dead take's lingering docs CORRECT), P4's default-road delta measured (and
   re-run by me), the approved `variant_id` column.
3. **The fence.** Off the facet every statement (passages · groups · counts · wornGroupFacts ×
   3 scopes × 3 visibilities) carries `AND d.kind <> 'savepoint'` and seeks no take and no
   savepoint day — pinned by LETTER (asserting absence of ` sv.`/`commit_point`), by BEHAVIOR
   (never-lists), and by the recorded sensitivity probes (F1 83 issues · F2 36 · F3); the
   EXPLAIN pin demands seeks on every alias (d, sv, pl, c, b, cp) and refuses any SCAN. ⌘K and
   the book 🔍 are fenced by construction (`includesSavepoints` defaults false on both roads).
4. **The one-composer rule (R-13o-8).** The text-less tag road is `SearchComposer.
   listingNarrowing` composed into `catalogNotesPage(narrowing:)` and `catalogTaggedBlocks` —
   no search SQL re-derived outside the composer; the driver's three plan traps are pinned
   (`+c.kind`, the CROSS JOIN order, the DISTINCT — red-first); `appliedTags(join:)` and
   `noteVisibility` factorings are relative-indentation-identical (and backed by the recorded
   270-statement `cmp`); the narrowed page keeps the sort door's own keyset, pages past page one
   on the same narrowing (`loadMoreNotes` passes `""` + the narrowing — the LIKE'd-field-text
   bug is dead), pages under an armed day (`canAskForMore`), and FAILS CLOSED on a narrowing the
   road cannot serve (pinned).
5. **P1 held.** The narrowed page ∝ the tag's applications (seam measurement reproduced on this
   machine); the savepoint kind's capture flat per commit, the facet ∝ its matches, the default
   road's class held (×1.13 / ×1.02 reproduced); the offer's vocabulary read ∝ the wing's tags
   (the typed-tag class). Nothing scales with corpus; nothing copies text across entities;
   nothing tracks word-level change.
6. **The editor seam.** Zero lines in `EditorTextView`/`BlockRangeIndex`/`PaneSurface`/
   `PaneTextAuthority` (diffstat-verified). VX-85 is one reveal KIND on the existing park —
   all six park/spend/abandon sites pair offset+kind (grepped); the non-stepping arm's banded
   upgrade (P-VX83-2) mutates kind only when a park exists; `consumePendingReveal`'s generation
   guard leaves the kind for the right hop. `restCaretLineInTheBand`'s bar-adjusted math checked
   (line top re-based to the seen viewport, height minus both insets, landingInset + bar.top) —
   byte-identical with no bar shown, where `findBarInsets` is hard-zero (`isFindBarVisible`
   guard). `JumpPrimitive`'s floor `minScroll = −top inset` is AppKit's own constrain floor
   (measured on 27.0, re-measure flag written into the code per TEXTKIT2_NOTES §5) and every
   other `JumpCorrectionLoop` caller rides the default 0, byte-unchanged.
7. **The re-mounted VX-85 pins measure a REAL landing** (the hollow-harness episode's watch
   item): a real `EditorView` in a key window, settled through layout + display passes, the
   line span vs the bar's CONVERTED frame, on-screen bounds asserted on both sides, plus a
   no-move mid-band control — read in source; the red-on-old table (12 issues, controls green)
   is the slot's announced-revert record.
8. **D-3/P-VX83-W2 (the needle).** `firstMatchedSpan` traced: per-term FTS5 runs coalesce
   across pure-whitespace and ≤2-char/no-newline gaps, kept AS WRITTEN so the literal find
   lands (walk V1/V2 confirm in the real app; shots read by me). The newline stop is I4's own.
9. **The when door.** No-silent-arm is STRUCTURAL (`opening`/`ask` return nothing armable;
   `press` is the one arming member — P-13o-U2-9's supersession recorded on the flipped pin
   with its justification in place); a backwards two-press run works (`LibraryDayRange` orders
   itself); the grid's day arithmetic is noon-anchored (`JournalDay.date`'s DST rule) with both
   2026 DST changes pinned; six fixed rows, her week order with a bad value reading Sunday;
   hand-written VoiceOver words per cell (ruling condition 1, in code); day KEYS stay the
   filter's calendar with only the DISPLAY order hers (condition 4).
10. **Counts and copy honesty.** The four-narrowing `listingCounts` argument order verified
    against its SQL; blocks and commits join `LibrarySearchCopy.counts`; F-W-3's `countsLead`
    pinned; R-VX83-10 applied coherently — search lines/counts/chip/lesson say "commit(s)",
    the schema kind id stays `savepoint` (vocabulary, not copy), the day-filter caveat's
    "savepoint" is that surface's own standing word (13s owns the app-wide noun, per the ruling).
11. **The tutorial lesson (VX-89)** teaches the finder as it stands at this run's close, incl.
    the re-worded commits sentence; the currency pins read every door's word from its one home;
    the plan gained the lesson and the plan-derived pins ride it. The REAL store's re-seed is
    correctly left to the closeout (A1 rail) and flagged.
12. **Hygiene.** No `Co-Authored-By`/`Claude-Session` trailers on any of the 38 branch commits;
    shared ledgers untouched on the branch (master plan, TICKETS.md, QUESTIONS.md, AppSpec);
    the in-flight row lives on main and matches the diff's declared surfaces; tree clean; no
    history rewrites (the red-on-old evidence used the committed-first announced-revert form);
    every justified pin edit is labeled in place with the superseding ruling named.

**Owed at closeout (the record already carries them — named here so the ladder cannot drop
them):** the canon deltas (AppSpec §7's ninth kind + `search_doc.variant_id`, §12's commits
facet + tag-alone narrowing + when-door direction 1 lines, §14's delta line) · the PROVISIONAL
ratify bundle (P-VX83-1…6, -W2/-W3, -B1…B4, -C1…C8 + the renamed counts cell) into QUESTIONS ·
the MOBILE PARITY line (the search lesson has no phone parity rule; the savepoint kind rides
VariorumCore onto the phone) · the real-store field-guide re-seed behind the A1 rail · the
rebase over 13x's merge (R-VX83-7: first-ready merged first; this branch is second).

**Round 1 closes: 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT.** Per the cross-model flow the three
findings go to the implementer verbatim; agree/dispute returns to this reviewer, which makes
the final call and implements its confirmed fixes itself (pin-before-fix, revert-verified),
then the suites green and one implementer sanity pass.

---

## DISPOSITIONS (cross-model, 2026-10-08 — every finding AGREED by its unit's implementer,
zero disputes; the reviewer's FINAL CALL on each: CONFIRMED, with the implementers'
refinements adopted)

- **MINOR — CONFIRMED (U-A agreed: "my omission, not a design choice"; P-VX83-3 meant every
  row the facet brings in says so).** Refinements adopted: the archived expression mirrors the
  narrowing's own archived-only clause — `(c.archived_at IS NOT NULL OR b.archived_at IS NOT
  NULL)`, one rule (the block half moot today: a released placement never lists; an archived
  POOL home rightly earns the mark); the column is always present on the statement, so the hit
  reads it without a default; the mark lands after the home text, before the Spacer.
- **NIT-1 — CONFIRMED (U-C agreed, with a stronger reading than the finding's: its P-2 guard
  was for the INVITATION only; hiding an ARMED state breaks P-13o-U2-1).** The armed
  `commits ✕` shows whenever the facet is armed and the band speaks; the invitation stays
  words-only; the reset rules stand as built (never remembered; `resetFacet()` on a blank
  field only — a day alone counts blank, so armed-chip-with-only-a-day cannot arise); the ✕
  road `toggleSavepointsFacet()` + `search()` is valid with no words.
- **NIT-2 — CONFIRMED with the implementer's CORRECTION to the reviewer's suggested fix
  (adopted):** `LibraryWhenMonth(dayKey:)` is failable and cannot close the `??` chain; the
  components form over `now` in the filter's calendar (Gregorian — always a real month) does.
  No pin (structurally unreachable); the test helpers' dated fallbacks are test-only and stay.

## THE FIX PASS (the reviewer's own, 2026-10-08 — commit per fix, pushed; no trailers)

| finding | commit | the fix | the pin + its evidence |
|---|---|---|---|
| NIT-2 | `b41a7c4e` | `LibraryWhenDoor.swift`: the month binding's last resort is NOW's month via `calendar.component(.year/.month, from: now)` (the filter's own calendar), never `LibraryWhenMonth(year: 2026, month: 1)` | none owed (structurally unreachable — the press seeds `month` before `shown`); compile + the slot's `LibraryWhenDoorTests` hold the door |
| NIT-1 | `9e52a0eb` | `LibrarySearchBand`: `showsArmedCommits(question:armed:)` — the armed `commits ✕` whenever armed and the band speaks; the `+ commits` invitation stays behind `offersCommits` (words only) | 4 new cells in `LibrarySearchCommitsFacetTests.theChipIsOfferedOnlyWhenTheQuestionHasWords` (armed under tag-alone shows · unarmed doesn't · armed with words shows · nil question never). Red-on-old BY ANNOUNCED GATE REVERT at the slot (everything committed first): `showsArmedCommits` short-circuited to the old gate's meaning (`armed && hasWords`) → the armed-under-tag-alone cell RED; restored, re-run green. PENDING-on-slot below |
| MINOR | `f9350c48` | `Queries.catalogTaggedBlocks` selects `(c.archived_at IS NOT NULL OR b.archived_at IS NOT NULL) AS archived`; the hit carries `isArchived: row["archived"]`; `blockLine` wears `CatalogArchivedMark` after the home text | **PIN-BEFORE-FIX, core:** `SearchTagListingTests.anArchivedHomesBlockEntersOnlyUnderTheFacetWearingItsFact` ran RED on the pre-fix statement FIRST (1 issue — the fact false; the entry/exclusion arms green, rightly: the facet already admitted the block, only the FACT was missing), then the fix, then green — and REVERT-RE-VERIFIED post-commit (`git checkout f9350c48~1 -- TagListingQueries.swift`; the pin red with the same 1 issue; restored; green; tree clean). **Mac:** `LibraryTagListingTests.theBlocksScopeListsTheBlocksTheTagNames` extended with the facet-toggled cells (the archived-home block waits for the facet, joins wearing the fact, the living sibling bare) — red-on-old by the same mechanism (the hit carried no fact); runs at the slot |

**Headless, at the fix pass's end (this machine):** full core `swift test` EXIT 0 —
**VariorumCoreTests 2,321 tests in 265 suites PASSED** (one more than the pre-ladder 2,320 —
the new MINOR pin; the standing honest skips only: the two gated benches, the live-Supabase
pass, `writeAScratchLibraryLikeHers`) + StringsWorkbookTests 40/6; Mac `build-for-testing`
SUCCEEDED (headless — a build needs no stage).

**OWED AT THE SLOT (test-only; "ready" ping sent to `oct7coordinator`):** (1) the touched Mac
suites — `LibrarySearchCommitsFacetTests` · `LibraryTagListingTests` · `LibraryWhenDoorTests` ·
`LibraryWhenRangeTests` · `LibraryDayFilterTests` · `LibrarySearchFaceTests` ·
`LibrarySearchStateTests` · `LibrarySearchJoinTests` · `LibrarySearchArchivedTests` ·
`LibrarySearchLandingTests` · `LibraryRowAlignmentTests` · `LibraryListFaceTests` ·
`ChromeLineLimitTests` — green, zero skipped; (2) the NIT-1 ANNOUNCED GATE REVERT (above);
(3) record the results here. Then the implementer sanity pass over the fix diff
(`dd572d82..HEAD`'s code commits), then round 2 with a FRESH reviewer.
