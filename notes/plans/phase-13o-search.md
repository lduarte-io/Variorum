# Phase 13o — Search

**Ticket: VX-5 · Project: 13o — Search · Branch: `vx-5-13o-search` · Worktree: `~/dev/variorum-13o` (the Pro)**

*(This file holds the KICKOFF; the execution plan lands here AFTER the design sitting, authored
by this phase's orchestrator. Written 2026-10-06 at the workflow transition.)*

## KICKOFF MESSAGE (the author launches a fresh orchestrator with `/architect-phase 13o`)

You are the orchestrator for **Phase 13o — SEARCH**: full-corpus body search with filters,
scoped (within a note · within a book · library-wide), born knowing wings. A V1 GATE.

**The workflow is new — read it first.** PREFLIGHT, complete and never delegated: CLAUDE.md +
its auto-loaded canon · **`notes/plans/workflow-transition-2026-10-06.md`** (the Linear/VX
system, the PR rule, the stage) · the master plan's IN-FLIGHT table · `notes/TICKETS.md` (read
main's copy at `~/dev/variorum/notes/TICKETS.md`; never regenerate here) · `notes/QUESTIONS.md` ·
`notes/SessionResiliencyProtocol.md`. Work in THIS worktree on THIS branch; commits per piece,
pushed; the phase lands by ONE PR titled `VX-5: …`, merge commit, at closeout. Linear: move VX-5
to In Progress at kickoff, In Review at the ladder, Done rides the merge.

**THE SPEC is `notes/FuturePhases.md`'s 13o row, read WHOLE** — it carries everything this
kickoff only names: her scope words; `Queries.searchCatalog`'s today-limits; the ruled inputs
received from the 13i sitting (§12: the tag-association join, mode facets as FACTS never tags,
hide-owned composition with Library exempt, **wings total isolation — search scopes by wing,
period**); the §21 items (**the results cap is a DEFECT** — full browsing via keyset infinite
scroll or an honest pager; the many-books case; the day-filter RANGE; the "on day…" wording);
the display-name predicate (Act 10 row 70); R13p-16's ruled display posture (the index may
contain AND display everything — the store itself is the protection); her "very capable search
within a book if needed." Project tickets: **VX-44** (the find&replace row's library half) rides
this phase.

**THE PHASE OPENS WITH THE DESIGN SITTING** (her standing word on the row): the technical fork
(FTS5 vs sweep vs index) is the sitting's to settle, with P1 at corpus scale the hard bar and
client-side-by-architecture the constraint (never a server key). One flag for the sitting: an
FTS index is a MIGRATION even if local-only-derived — read SyncSpec §12 far enough to mark any
new table correctly (synced ⇒ lockstep at her window; local-only ⇒ the `sync_outbox` precedent),
and propose, never assume. Bundle the questions; she rules; THEN author the execution plan in
this file and build in batches per the sizing guidance.

**Parallel-work rules bind:** 13x (custody — it holds the one Sync/-custody slot) and 13s run
beside you. Declare this phase's surfaces at kickoff against the in-flight table; ZERO
`Sync/`/custody lines from this phase without a redirect from the author. Anything touching the
screen or a store — every `xcodebuild test` run, walks, Debug launches — claims `Tools/stage`
first; headless `swift build`/`swift test` is yours freely. Cast, ladder, closeout ritual, hard
stop: CLAUDE.md as ever; the closeout retires this effort's in-flight row and the PR merges.

---

## STATUS — SEATED, PREFLIGHT DONE, DESIGN SITTING OPEN (2026-10-06, the orchestrator)

Seated per the skill's workspace setup: worktree `~/dev/variorum-13o`, branch `vx-5-13o-search`
ff'd to main (18270b70) with upstream set; VX-5 moved **In Progress**. Preflight complete
(CLAUDE.md + canon, the workflow transition record, the in-flight table, main's TICKETS.md,
QUESTIONS.md's open tail + the search-adjacent entries #63/#104/#157/#187, the 13i sitting
record §12/§21, SyncSpec §12 + §3's local-only precedent, the 13p FTS5 spike record, and the
shipped code: `Queries.searchCatalog`/`catalogBooks`/`catalogBlocks`/`catalogPostsSQL` +
`editedOnClause`, `LibraryCatalogModel.listing` (17y B1 paging, `blockCap = 40`),
`CommandPalette`, `EditorFind`, `TakesFind*`, `SyncSchema.localOnlyTables`, `Triggers.swift`).

**SURFACES DECLARED (vs the in-flight table):** `Sources/VariorumCore/Queries/` ·
`Sources/VariorumCore/Domain/` (pure query/match rules) · `Sources/VariorumCore/Persistence/`
(one migration if an index is ruled in) · `App/Variorum/Variorum/Features/Library/` ·
`Features/CommandPalette/` · possibly a new `Features/Search/` module and a within-book face in
`Features/BookView/`. **Two flagged seams, held for the author at the sitting:** (1) a new
local-only index table must join `SyncSchema.localOnlyTables` (`Sync/SyncSchema.swift`) — a
data-only registry line, but a `Sync/` line all the same, and 13x holds the slot; (2)
`Persistence/Migrations.swift` is append-shared with any other effort minting a migration —
13o claims its migration id at the sitting and records it here. No custody, no keychain, no
editor-core internals anticipated (any in-note landing rides the existing `LandingTarget` /
find-bar machinery; TEXTKIT2_NOTES joins the required reading of any batch that touches a pane).

The DESIGN SITTING's brief + question agenda were delivered to the author in-session 2026-10-06;
her rulings landed the same sitting — the SITTING RECORD below is binding. The execution plan
follows it.

---

## THE SITTING RECORD — her rulings, 2026-10-06 (verbatim-faithful; BINDING)

- **R-13o-1 — MERGE ORDER + THE SYNC/ SLOT.** Her words: *"let's just decide that this phase
  will merge to main first, and do the numbering of migrations based on that. merging to main
  can't happen simultaneously, so I'm wondering why changing the migration id is even an issue
  later?"* and *"Go ahead and do R2, you can have the slot, 13x will wait on you. I think you
  can send 13x a message if needed."* → 13o holds the one Sync/-custody slot for its data-only
  registry line (`SyncSchema.localOnlyTables` + the completeness-walk accommodation); **13o
  merges to main FIRST; 13x waits on that merge.** (The slot message went to the likely-13x
  session `variorum-c0` the same turn, worded ignorable if mis-addressed.) Her migration-id
  question answered on the record: a collision only bites a DEV store that already ran a
  branch's migration under a name later changed at rebase (GRDB records applied names);
  serialized merges + claim-at-plan-time dissolve it, and with 13o merging first it is moot.
- **R-13o-2 — THE GOAL RATIFIED.** Her words: *"Your goal sounds excellent - that's a perfect
  bar and goal."* The bar: any words you ever wrote, findable in under a keystroke's breath, at
  any corpus size, from the place you'd naturally ask — search as the FINDER half of the
  place/finder boundary.
- **R-13o-3 — FTS5.** *"Agreed on the FTS5."* A local-only derived index family (the
  `sync_outbox` precedent — no mirror, no lockstep, the marker stays 12) + an explicit rebuild
  door.
- **R-13o-4 — THE THIRD TRIGGER DUTY.** *"Agree on your recommendation for R1"* → the closed
  trigger set (OverallModel §9) extends by one MECHANICAL duty: **derived-index capture** —
  the outbox-capture class (fires regardless of writing layer; zero domain knowledge). The
  Phase-2 re-assessment protocol is run and recorded at U1 before the first trigger line; the
  OverallModel §9 + AppSpec §6 contract lines amend at closeout exactly to this ruling.
- **R-13o-5 — MIGRATION IDS.** *"effort claims its id in its plan file is good, if you think
  it's good in the in flight table that's fine. do the ids have to be sequential? I'm planning
  on you merging first."* → **13o claims `v1_22`** (head is `v1_21`). On the record: ids are
  labels — GRDB's mechanism is REGISTRATION ORDER (append-only against stores that already
  ran), so sequential naming is our legibility convention, not a mechanism; claim-in-plan-file
  is the rule from here on (the in-flight table may carry the claim at the next merge moment).
- **R-13o-6 — WHAT THE INDEX CONTAINS.** *"Index - needs to be on all live active takes."* On
  the everything-search: *"we did talk about the appeal of being able to search through
  everything - including deleted and archived and savepoints… I lean towards thinking that it
  shouldn't be the default search, but it is a very unbeatable product idea - anything you've
  ever written, saved. I think the history search someday would be nice."* → DEFAULT search =
  the LIVING corpus (all live active takes, titles, book/gathering/chapter names, block names +
  take labels, scraps, block comments, floating notes); archived notes/books/takes indexed but
  OUT of default results behind one facet; savepoint history + the Trash are NOT in 13o — the
  index is born KIND-TAGGED so those classes join later additively (ticket VX-72). Versions
  stay excluded (the ruled posture). *"the derived display name would be good to do"* → the
  nameless note's worn date becomes findable (built as query-time date parsing, not a stored
  rendering — see U1).
- **R-13o-7 — WHERE SEARCH LIVES.** *"I agree that library field should be one giant finder -
  no new search mode. that being said, I feel like it could have pretty substantial UI in the
  full search mode, so that should be considered and maybe make some html mockups for how it
  could be brought together."* → ONE finder (the Library field; ⌘K keeps its quick-jump role
  with body hits); the Library's SEARCH-ACTIVE state may carry substantial UI — an HTML mockup
  round (local file, the 13i-bookcase pattern) GATES U2's faces; she picks at a sitting.
- **R-13o-8 — THE COMPLEX-QUERY DIRECTION.** Her words: *"I eventually hope to allow people to
  do more complex searches - what's the lift on queries kinda? like, notes with 'dream' that
  aren't in the Journal book, over 500 words in the note… I don't think that has to be done
  right now, but that is a shape I'm interested in, so I want to know if what we're building is
  working in that direction."* → BINDING on 13o's shape: the query layer is a pure Domain
  **SearchQuery AST** (text terms + a filter tree) with the SQL composed from it — v1's grammar
  (words, #tag, day range, facets) parses into it, and the future grammar (boolean, in:/not
  in:book, word-count thresholds — the RuleGrammar/gathering-rule kinship, saved searches) is a
  later parser + UI over the SAME AST (ticket VX-73). Lift assessed on the record: modest —
  FTS narrows by text, every other predicate is ordinary SQL over rows-as-truth.
- **R-13o-9 — THE CAP DIES.** *"block / scrap 40 cap should not exist - the 40 cap with no
  escape is terrible."* → block/scrap hits page like the notes (17y B1's mechanism); no capped
  listing without a road to the rest, anywhere in search.
- **R-13o-10 — HIDE-OWNED IS A NON-LIBRARY THING.** *"owned book notes should show in the
  library with search, by default. hide owned is a non library thing."* → the Library,
  searching included, is EXEMPT from `hide_owned_default`; owned-book notes list badged (the
  13i-c badge family). Non-Library surfaces keep composing the default as ruled at 13i.
- **R-13o-11 — ACCENT-INSENSITIVE.** *"I think it's fine to not be accent sensitive - the
  library is discovery, sometimes autocorrect throws an accent on there."* → the index folds
  case AND diacritics (unicode61, `remove_diacritics 2`) — recorded as the deliberate third
  sameness rule beside the Write/Takes bars' pinned pair (which stay accent-sensitive,
  untouched).
- **R-13o-12 — SIZING + DEFERRALS.** *"I approve what you want, log these follow up tickets
  and ideas and whatever isn't built today in linear with the plan note as required as well."*
  → the three-unit plan below stands; the deferred ideas are Linear tickets in project 13o
  (VX-72 Search Everything · VX-73 the power-search grammar), each pointing at this file.

## BINDING PRINCIPLES — the 13b constitution, carried per the skill

P-1…P-9 bind BYTE-VERBATIM as written in `.claude/skills/architect-phase/SKILL.md` (one
capability registry · fire-and-DO · one text surface/one liveness authority · broadcasts carry
signals never decisions · the friction doctrine · the tutorial is the executable spec · find
bugs before she does · standing law consolidated · no frontend god objects), plus that file's
application notes. Phase-specific additions by this sitting: R-13o-4 (the third trigger duty,
mechanical only — any trigger wanting domain knowledge remains the §9 smell), and R-13o-8's
AST rule (no search SQL composed outside the one Domain composer).

## THE EXECUTION PLAN (authored 2026-10-06, post-sitting)

**Cast:** the standing default — Opus implements (`opus-implementer`, xhigh), one fresh session
per unit; Fable orchestrates (this seat) and cold-reviews (`fable-reviewer` — required anyway:
the diff carries a `Sync/` registry line and U1 is substrate). One ladder over the combined
diff after U3; REVIEW_PROMPT verbatim; hard cap three rounds.

### U1 — THE SUBSTRATE (one implementer session; evidence: headless suites + pinned P1 numbers)

1. **Migration `v1_22`** (its own commit before consumers): the search-index family — a thin
   local-only doc table (kind-tagged: `take · title · book · chapter · block_name · take_label ·
   scrap · comment · note_meta`, entity ids, wing scoping columns, archived flag) + the FTS5
   table over it (`unicode61 remove_diacritics 2`, prefix indexes for type-ahead). Contentless
   vs external-content: the implementer PROPOSES with measurements, the architect rules (the
   in-batch fork rule). Backfill = the rebuild road run once inside the migration.
2. **The third trigger duty** (R-13o-4; the re-assessment protocol's record lands here first):
   mechanical capture triggers on the text-bearing source tables (variant / container / reading /
   reading_section / block / block_comment — insert, text-column update, tombstone), mirroring
   raw text into the doc family. No domain reads inside a trigger body, ever.
3. **The rebuild door:** a maintenance operation (drop + rebuild from truth, integrity check
   comparing doc rows against source rows) — the restore/doubt/drift net; also the migration's
   backfill engine.
4. **The `Sync/` registry line** (R-13o-1's grant): the doc + FTS shadow tables join
   `SyncSchema.localOnlyTables` (or the walk gains a declared shadow-prefix rule — smallest
   honest diff wins); the completeness walk stays the pin.
5. **Core queries:** `Queries.searchPassages(_:scope:filters:)` over the **SearchQuery AST**
   (R-13o-8 — the one pure Domain composer): ranked (bm25, title-weighted, rendered-take
   boosted), snippeted, wing-scoped always, book- and note-scoped variants, archived facet,
   paged with a road to everything (R-13o-9). **The date-parse predicate** (R-13o-6's display
   name): a pure Domain parser reading day-shaped query text ("september 14", "sep 14",
   "9/14") into entry-date/created-date bounds OR'd into the note arm — locale-honest, no
   stored rendering to go stale.
6. **Pins:** capture across ALL THREE write layers (operations, cascade, a fake-server remote
   apply — red-on-old each); rebuild idempotence + integrity; tombstone/archive transitions
   drop/flag doc rows; wing isolation; accent/case folding; the AST composer's SQL (EXPLAIN
   pins against the drift class); **P1 measurements**: index update cost ∝ the edit (flat
   across corpus sizes), query cost ∝ matches, keystroke road bounded — the day-search
   ladder's measurement discipline.

### U1 BRIEF (the implementer session's self-contained instructions)

**Who you are:** the U1 implementer (Opus, xhigh), ONE session, ONE acceptance unit — the
search substrate, headless. Work ONLY in `~/dev/variorum-13o` (branch `vx-5-13o-search`).
**Required reading before anything:** this plan file WHOLE (the sitting record is binding) ·
`notes/SyncSpec.md` IN FULL (you build beside sync machinery) ·
`notes/SessionResiliencyProtocol.md` (the checkpoint protocol binds from your FIRST commit:
commit per piece, push every commit, LIVE STATUS in the U1 RECORD below, PENDING for every
unverified claim, synchronous foreground waits only). You may run at most ONE Sonnet subagent,
for EXTERNAL facts only (e.g. FTS5/GRDB API confirmation), read-only — never for repo reading.

**Scope = the U1 list above (items 1–6), with these precisions:**
- **The ONE hard fence: you never edit `Sources/VariorumCore/Sync/`** (Fable work, CLAUDE.md).
  Your migration WILL turn `SyncSchemaTests`' completeness walk red (new tables unregistered).
  That red is the planned SEAM: stop there, write the exact table names into the U1 RECORD,
  push, and report — the orchestrator lands the registry line, then you continue. Treat that
  one red as expected at that seam only; everything else stays green.
- **The in-batch fork (the implementer proposes, the architect rules):** contentless vs
  external-content FTS5, and the doc-table normalization (one doc row per source row vs per
  rendered unit) — PROPOSE in the U1 RECORD with measurements/tradeoffs BEFORE committing that
  half; build only after the ruling lands in this file.
- Tokenizer: `unicode61 remove_diacritics 2` (R-13o-11); prefix indexes sized for type-ahead.
  The doc family is KIND-TAGGED from birth (R-13o-6's born-ready rule) and carries wing + 
  archived columns so scoping/facets are predicates, never joins at keystroke rate.
- Triggers: MECHANICAL ONLY (R-13o-4 — the ruled third duty). Raw text mirroring; zero domain
  reads in a body. Land the Phase-2 re-assessment protocol's short record in the U1 RECORD
  before the first trigger line (the OverallModel §9 provenance demands it).
- The SearchQuery AST + ONE SQL composer in Domain (R-13o-8); `Queries.searchPassages` rides
  it; the date-parse predicate is a pure Domain function with exhaustive little tests.
- Pins per U1 item 6 — red-on-old verified by revert for every bug-class claim; the
  three-layer capture pins (operations · cascade · fake-server remote apply) are the unit's
  heart; P1 measurements recorded as NUMBERS in the record.
- Schema commit FIRST and alone (`v1_22`), consumers after (CLAUDE.md's rule).
- Headless only: `swift build` / `swift test [--filter …]` on the core package — no stage, no
  xcodebuild, no app launches, nothing GUI. Environment traps: the plan's block above, verbatim.

### U1 RECORD (LIVE STATUS — the implementer maintains this from its first commit)

**Seat:** the U1 implementer (Opus, xhigh), seated 2026-10-06 in `~/dev/variorum-13o` on
`vx-5-13o-search`. Required reading done in-context (this file whole, SyncSpec in full, the
resiliency protocol; plus the code it names — `Migrations.swift`, `Triggers.swift`,
`SyncSchema.localOnlyTables` + `SyncSchemaTests`' walk, `StorePlaintextExport`, the catalog
queries in `ShelfQueries.swift`, `PostRender`'s rendered-take fragment, `wingScope`, the Phase-2
plan's trigger-smell protocol, the 13p spike memo's Q1). Machinery: no deaths so far.

**THE PIECE PLAN (each piece its own commit, pushed; flipped here in the same commit):**

| # | Piece | Status |
|---|---|---|
| P0 | This piece plan (the first commit) | DONE (this commit) |
| P1 | MEASUREMENTS + THE FORK PROPOSAL — contentless vs external-content FTS5; doc normalization (per source row vs per rendered unit); where scope (note/wing/archived) lives. A throwaway measurement suite over synthetic corpora; numbers + tradeoffs written below. **→ SEAM 1: stop for the architect's ruling before the schema half.** | DONE (this commit) — the proposal is §FORK below; AWAITING THE RULING |
| P2 | Domain, fork-independent: the `SearchQuery` AST (text terms + filter tree, R-13o-8) + the v1 grammar parser (words · "phrases" · `#tag` · facets) + the DATE-PARSE predicate (R-13o-6 — "september 14" / "sep 14" / "9/14" → day bounds), pure, exhaustive little tests | DONE (this commit) — `Domain/SearchQuery.swift` (the AST: `SearchQuery` = text tree + filter tree + `wornDay` + `visibility`; `SearchScope` with the wing mandatory), `Domain/SearchQueryParser.swift`, `Domain/SearchDateParse.swift`; `SearchQueryParserTests` 19/19 green (2 suites). PROVISIONALs: P-13o-U1-1 a day inside a sentence of words is words (the whole free text must be the day); P-13o-U1-2 a numeric day impossible in the locale's order reads the other way round ("14/9" in en_US); P-13o-U1-3 dotted numeric days only where the locale writes them; P-13o-U1-4 the type-ahead tail is a prefix only at ≥ 2 characters |
| P3 | The Phase-2 re-assessment record for R-13o-4's third trigger duty (below), BEFORE any trigger line | DONE (this commit) — §R-13o-4 RECORD below |
| P4 | Migration `v1_22` ALONE: the doc table + the FTS5 table (`unicode61 remove_diacritics 2`, prefix indexes) + the mechanical capture triggers + the backfill (the rebuild SQL run once). **→ SEAM 2: SyncSchemaTests' completeness walk goes red — the exact new table names land here, push, stop for the orchestrator's registry line.** | DONE (this commit) — built to §FORK RULINGS F1–F4: `Persistence/SearchIndex.swift` (`search_doc` AUTOINCREMENT + `uq_search_doc_src(kind, src_id)` · the `search_text` view · `search_fts` · 24 capture triggers `search_<table>_<kind>_{insert,update,delete}`, one generator · `SearchIndex.rebuild` = the backfill engine) + `v1_22_search_index` in `Migrations.swift` (create → `idx_container_undated_created` → rebuild). `MigrationTests` updated (tables, indexes, the v1_16→head index delta) + a backfill pin `theSearchIndexBackfillsAnOlderStoreAtMigration` (all eight kinds findable after migrating a v1_21 store; tombstoned take absent; archived take indexed with its fact; accents fold; integrity-check passes) — 28/28 green. **Full core suite: 2227 tests / 250 suites, exactly ONE red — the planned seam** (SEAM 2 below). |
| P5 | The rebuild door (a maintenance operation: drop + rebuild from truth) + the integrity check (doc rows vs source rows) | DONE (this commit) — `Operations+SearchIndex.swift`: `rebuildSearchIndex()` (rebuild + verify in ONE transaction; no synced row, no stamp, no undo entry) and `verifySearchIndex()`; `SearchIndex.integrity` (`Persistence/SearchIndex.swift`) → `SearchIndexIntegrity` {docCount · missing · orphaned · factDrift · indexMatchesContent (FTS5 `integrity-check` rank=1 vs the view = vs TRUTH)}. Faces (a Settings row, a post-restore pass) are a later unit's — the doors exist. |
| P6 | The capture pins — operations · cascade · fake-server remote apply (each red when its trigger is dropped, verified by revert) + tombstone/archive transitions + wing isolation + accent/case folding + rebuild idempotence | DONE (`77aedb95` + this commit) — `SearchIndexCaptureTests` 11/11 green; every layer's pin RED under its trigger's revert (the table below). Wing ISOLATION is a query property → P7's pins. |
| P7 | The ONE Domain SQL composer (AST → SQL) + `Queries.searchPassages(_:scope:filters:)` — bm25 ranked (title-weighted, rendered-take boosted), snippeted, wing-scoped always, note/book scopes, archived facet, paged with a road to everything (R-13o-9); EXPLAIN pins | DONE (this commit) — `Domain/SearchComposer.swift` (the one composer: `ftsMatch` quotes every leaf as an FTS5 string — no user text is ever FTS5 syntax, separator-only words drop, negation-only text refuses; `passages` = FTS MATCH → doc by rowid → home via the I2 placement seek + container/block/reading PKs → wing (ALWAYS) · within · archived facet · version fence · the filter tree → `bm25 × kind weight × rendered boost` → keyset page on (score, doc id) → snippets for the PAGE rows only (a page-driven `CROSS JOIN` FTS lookup by rowid); `wornDay` = the dated arm (seeks `idx_container_entry_date`) + the undated arm (one range per window on `idx_container_undated_created`, UNION ALL'd); the filter half: #path/tag-id SUBTREE driven from the root (an index RANGE on `uq_tag_path_live`), starred, day RANGE (edited = the shipped union rule, now `Queries.editedOnSQL(alias:)` with `editedOnClause` its byte-identical nil form, pinned) / created, family). `Queries/SearchQueries.swift`: `searchPassages(_:query:scope:after:limit:calendar:)` → `SearchPage {passages, next}`; `SearchPassage` (kind · source · family · note/block/reading · `homeTitle` by `DisplayTitle` · archived · rendered · snippet segments); the worn-day arm confirmed by `DisplayTitle` itself (one display brain). `SearchPassagesTests` 14/14 green. **PROVISIONALs:** P-13o-U1-5 scraps list in every wing (the shipped catalog's P-13id-U5-4 kept); P-13o-U1-6 the kind weights (title/book 3 · chapter 2.5 · block name 2 · label 1.5 · take 1 · comment/floating notes 0.8) and the rendered boost ×1.25; P-13o-U1-7 a text-less query returns no passages (filter-only browsing stays the Library listing); P-13o-U1-8 a released (unplaced) block's takes stay indexed but never list (no home to land in); P-13o-U1-9 a typed `#path` matches case-insensitively; P-13o-U1-10 within-a-GATHERING scope (a rule, no rows) is U3's — `.book(id)` on a gathering finds only its own name. |
| P8 | P1 measurements as pins + the NUMBERS here (update cost ∝ the edit, flat across corpus sizes; query cost ∝ matches; the keystroke road bounded) + the architect's addition: the integrity check's DRIFT pin | DONE (this commit; sensitivity probes PENDING, below) — `SearchP1Tests` 2/2 green: (1) PAGE REQUESTS (`SQLITE_DBSTATUS_CACHE_HIT+MISS`, deterministic) over two corpora of one shape, 2k and 10k blocks (5×), capture triggers live: **autosave 24.1 → 26.1 pages/edit** (flat, pinned ≤ 1.5×); **fixed-match queries** (20 probe takes): `zanzibar` 335 → 467 · `zanzibar quokkaprobe` 413 → 634 · the type-ahead `quokkapr` 334 → 468 (pinned ≤ 2× — the residue is logarithmic: each per-match B-tree seek and FTS5's segment levels deepen ~one page; a corpus-proportional cost would be ≥ 5×); **an every-block term** `the` 8,368 → 49,251 (∝ matches, pinned > 3×). (2) **DRIFT**: a take's text changed with its capture trigger dropped → the doc set reads whole but `indexMatchesContent` = false; the rebuild heals; the new words become findable. **A P7 correction found BY these pins:** the snippet stage had been page-DRIVEN (`page CROSS JOIN search_fts` — one FTS5 query per page row by rowid); FTS5 re-opens every segment per such query — 802 page requests for a 20-row page vs 326 for one more walk of the matches joined to the page (Bloom-filtered) — so the composer now walks once (`search_fts JOIN page`) and the EXPLAIN pin says so. |
| P9 | Close: the named suites green at the END, every claim flipped from PENDING, the report | NOT-STARTED |

PENDING flags: none yet.

**P6 REVERT PROBES — DONE, tree restored and re-verified green (11/11).** Each probe edited ONLY
`Persistence/SearchIndex.swift` (committed clean at `77aedb95`), ran `SearchIndexCaptureTests`,
and restored by `git checkout --`:

| probe | the revert | red pins (the layer each proves) |
|---|---|---|
| R1 | no INSERT capture triggers | operations (every kind's first write), REMOTE APPLY (the phone's arriving rows unindexed), cascades, facts, rebuild/integrity, the exact trigger set — 9 of 11 red |
| R2 | `deleted_at` out of the UPDATE triggers' watch | the CASCADES (block → label/name/comment, note → all, book → chapter still found), operations (a deleted comment/chapter lingers), archive/tombstone, REMOTE tombstone — 4 red |
| R3 | no `variant`·`take` UPDATE trigger | operations (autosave keeps the old words), REMOTE APPLY (the phone's edit: "lights" still found, "fog" not), cascades, archive, accent folding, the exact set — 6 red |
| R4 | the WHEN guard removed (fire on every write) | only the same-values remote rewrite (`changes == 1` → more) — the guard is pure economy, pinned on its own |
| R5 | no DELETE triggers | the physical delete (the janitor's road) + the exact set — 2 red |

**P8 SENSITIVITY PROBES IN FLIGHT:** S1 edits `Domain/SearchComposer.swift`, S2
`Persistence/SearchIndex.swift` — both committed clean at `a4db3a15`; a successor finding either
dirty restores it with `git checkout -- <file>` (safe). S1 disables the placement seek (`+pl.block_id`);
S2 disables the doc-key seek inside the UPDATE trigger (`+kind`, `+src_id`).

**LIVE STATUS (2026-10-06): STOPPED AT SEAM 2** — P0–P4 landed and pushed; the fork was ruled
(§FORK RULINGS, `880abf8f`) and P4 is built exactly to it. The tree is clean. Waiting on the
architect's `Sync/` side (the DERIVED set + the walk + the export-test accommodation). Nothing is
reverted, nothing half-built. On resume: P5 → P9 (P8 gains the integrity-check DRIFT pin, the
architect's addition).

**SEAM 2 — THE RED'S EXACT SHAPE** (full core suite after `v1_22`: 2227 tests in 250 suites, ONE
failing expectation, everything else green — the gated bench's 3 tests skip as designed):
`SyncSchemaTests.registryMatchesLiveSchemaExactly`, `SyncSchemaTests.swift:29` —
`SyncSchema.localOnlyTables == allTables.subtracting(synced)` is false:
`localOnlyTables` = {sync_outbox, sync_row_seq, _sync_applying, sync_state};
`allTables − synced` = those four **+ {search_doc, search_fts, search_fts_config, search_fts_data,
search_fts_docsize, search_fts_idx}**. Exactly the six predicted at §FORK; no `_content` shadow
(external content); `sqlite_sequence` (born of `search_doc`'s AUTOINCREMENT) is outside the walk
(`NOT LIKE 'sqlite_%'`); the view `search_text` is `type='view'`, outside it too. The six are
also `SearchIndex.tables` (`Persistence/SearchIndex.swift`, internal, same module) should the
DERIVED set want to name them from one place. `StorePlaintextExportTests` is GREEN as things
stand (the search family is in no local-only list, so the export already carries it whole —
the derived ruling's intended outcome).

#### §FORK — THE PROPOSAL (P1; the implementer proposes, the architect rules — nothing of the schema half is built until the ruling lands here)

**The bench** — `Tests/VariorumCoreTests/SearchForkMeasurementTests.swift`, gated behind
`VARIORUM_SEARCH_MEASURE=1` (skipped in the ordinary suite; re-runnable by any reviewer). The
REAL migrated schema on an on-disk (unkeyed) store, raw-SQL corpora of 1,000 / 5,000 notes × 10
blocks (every 10th block a second take ⇒ 11k / 55k take docs), 50-word takes from a deterministic
Zipf vocabulary of 30k pseudo-words (a sprinkle accented), 10% of notes in a second wing. Wall
times are best-of-5 on the M3; PAGES are `SQLITE_DBSTATUS_CACHE_HIT+MISS` (deterministic page
requests through the pager — what the FTS5 C code reads, which VM-step counters cannot see).

**The probe (the linked SQLCipher 4.18.0 community = SQLite 3.53.4):** FTS5 ✔ ·
`contentless_delete=1` ✔ · a VIEW as external content ✔ (`snippet()` over it highlights with the
tokenizer's own folding — "The [Café] was [naïve]" for `cafe AND naive`) · `remove_diacritics 2`
prefix folding ✔ (`res*` finds "Résumé") · `integrity-check` with `rank=1` over the view-backed
table ✔ — and it **DETECTS silent source drift** (a source text changed behind the index's back ⇒
SQLITE_CORRUPT_VTAB) · a contentless table's `snippet()` = NULL.

**The four content modes** — X = external content over a doc table that HOLDS a text copy ·
V = external content over a VIEW resolving text from the SOURCE rows (doc table = ids only) ·
C = contentless (`contentless_delete=1`) · R = a regular FTS5 table (its own `_content` copy):

| at 55k take docs | X | V | C | R |
|---|---|---|---|---|
| doc table / FTS (KB) — the `variant` table itself is 16,968 | 16,332 / 19,100 | **4,664 / 19,100** | 4,664 / 19,208 | 4,664 / 30,792 |
| backfill, 11k → 55k docs (ms) | 101 → 657 | 96 → 663 | 97 → 719 | 103 → 1,109 |
| one autosave, own txn, 11k → 55k (ms · pages) | 0.80 → 0.96 · 21 → 23 | **0.78 → 0.87 · 20 → 23** | 0.91 → 1.33 · 34 → 37 | 0.96 → 1.28 · 32 → 34 |
| snippet() | ✔ | ✔ | ✘ (NULL) | ✔ |
| `rebuild` / index-vs-TRUTH integrity check | ✔ / vs the copy | ✔ / **vs the source rows** | ✘ / internal only | ✔ / vs its copy |

The autosave PAGE counts are FLAT across a 5× corpus in every mode (the P1 shape the plan wants
pinned). Query cost is the SAME in every mode (±10%) and is ∝ MATCHES — ~2 page requests per
match (bm25 reads each match's docsize row): at 55k docs, ORDER BY rank LIMIT 50 + snippet, Home
scope — rare term (3 hits) 0.12–0.16 ms · mid (2.4k) ~1.5 ms · common (55k) ~32 ms · 2-char
prefix (45k) ~24 ms · 3-char prefix (17k) ~8.5 ms · two-term AND (50) ~0.45 ms.

**Where scope lives** (V, 55k; COLUMN = the doc row carries the fact · JOIN = resolved through the
placement `uq_cblock_ownership` + the container PK):

| query | majority scope (Home, 90%) | wing-two (10%) | ONE note | a 50-note book (join) |
|---|---|---|---|---|
| common term — col / join (ms) | 31.8 / 32.4 | 32.2 / 36.6 | 45.5 / 74.1 | 39.0 |
| mid term — col / join (ms) | 1.46 / 1.63 | 1.33 / 2.53 | 2.08 / 3.79 | 4.19 |

(Driving a note-scope from its own docs via `rowid IN (…)` was measured too and LOSES — FTS5
still walks the term's whole doclist: 31 ms common, 13.7 ms mid.)

**Prefix-index sizing** (V, 55k): none 8.8 MB / 2-char prefix 32.6 ms · `'3'` 12.7 MB / 33.6 ms ·
**`'2 3'` 19.1 MB / 25.7 ms** · `'2 3 4'` 23.5 MB / 24.9 ms.

**THE RECOMMENDATION (four parts, each ruleable on its own):**

- **F1 — content mode: V, external content over a VIEW of the source rows.** Text stored ONCE
  (the source rows are the content); `snippet()`/`highlight()` native with the index's own folding
  (so what matched and what is highlighted are one sameness rule — R-13o-11 needs no Swift twin);
  `rebuild` native (the backfill and the rebuild door are one statement); the integrity check
  compares the index against TRUTH, not a copy; the cheapest writes measured. Its contract: the
  index is updated in the SAME statement as every source text write with OLD = what was indexed —
  exactly what AFTER triggers give (pinned per write layer at P6; the integrity check is the net).
  Sound under VACUUM (the doc rowid is an `INTEGER PRIMARY KEY`; source rows are named by their
  TEXT id, never their implicit rowid). **Fallback: X** if the architect wants the derived family
  self-contained (a full second copy of every take — +16 MB per 55k takes — checked against the
  copy). **Not C** (no snippets ⇒ a second, Swift-side folding rule deciding highlights — a drift
  class; dearest writes). **Not R** (the text duplicated inside the index; slowest backfill).
- **F2 — normalization: ONE DOC ROW PER SOURCE TEXT FIELD.** kind ≡ a (table, column) pair:
  `take` (variant.working_text) · `take_label` (variant.label) · `block_name` (block.name) ·
  `comment` (block_comment.text) · `title` (container.title) · `note_meta`
  (container.floating_notes) · `book` (reading.name) · `chapter` (reading_section.name). A doc
  exists iff its source row is LIVE (`deleted_at IS NULL`) AND the field is non-NULL; archived rows
  stay indexed with an archived fact (R-13o-6). Rejected — per RENDERED UNIT (per block / per
  note): a keystroke would re-tokenize the whole unit (∝ note size, not the edit), building the unit
  needs sibling aggregation inside a trigger (a read), and a hit could no longer name its take for
  land-at-match. **`scrap` becomes a query-time FACET** (a take whose home container is a pool),
  not a stored kind: a variant row cannot know its container without a read (R-13o-4). The kind
  vocabulary stays closed and additive — VX-72's savepoints join as one more kind
  (`commit_point.text`).
- **F3 — scope: OWN-ROW FACTS ONLY on the doc** (`block_id` / `container_id` / `reading_id` as
  the source row itself carries them, the row's OWN `wing_id` for title/note_meta/book, the row's
  OWN archived fact). Every trigger reads only NEW/OLD and the doc family (to find its rowid) — no
  other table, ever. The home note / wing / note-archive / version-ness / pool-ness of BLOCK-HOSTED
  docs resolve at query time inside the ONE composer, through the I2 placement seek + the
  container PK. Measured price: +2% (common, majority scope) to +60–90% (minority scopes); the cost
  CLASS is unchanged (∝ matches). This deviates from the plan's "wing + archived columns … never
  joins at keystroke rate" for block-hosted docs — deliberately: the alternative (S2: `note_id` /
  `wing_id` / note-archived propagated onto take/comment/name docs) needs structural READS inside
  the variant/comment/placement triggers (the live placement + the container row) and ~8
  propagation triggers whose completeness under every remote-apply arrival order becomes its own
  correctness surface. Because the index is DERIVED and local-only, S2 stays reachable later as a
  local-only migration + one rebuild (no lockstep) if U2's walk finds minority scopes slow.
  **If the architect prefers S2 now**, it is buildable — the reads would be the placement seek and
  the container PK, and the R-13o-4 record would name them.
- **F4 — tokenizer + prefixes:** `unicode61 remove_diacritics 2` (R-13o-11), `prefix='2 3'` (the
  plan's type-ahead sizing: −25% on 2-char prefixes for 2.2× index size; the trailing token becomes
  a prefix term only at ≥ 2 characters — a 1-character prefix is the whole corpus). ONE indexed
  column (`body`): a kind's weight is a query-time bm25 multiplier, because a second sparse
  `name` column would make bm25 PENALIZE short titles (column-average length normalization) —
  the opposite of title-weighted.

**Table names under F1–F4 (for SEAM 2, so the registry line can be drafted at the ruling):**
`search_doc` · `search_fts` · `search_fts_config` · `search_fts_data` · `search_fts_docsize` ·
`search_fts_idx` (external content has no `_content` shadow) — plus the VIEW `search_text`, which
the walk's `type = 'table'` never sees. (X and C: the same six; R adds `search_fts_content`.)
**One consequence for the seam's owner:** `StorePlaintextExport` drops `SyncSchema.localOnlyTables`
from the export, so registering the search family there means an export carries the capture
triggers but not their tables (the outbox's own recorded consequence — 13x's open door reconciles);
a separate DERIVED set that the walk subtracts and the export KEEPS would hand 13x a working index
instead. The orchestrator's call; flagged, not decided.

#### §FORK RULINGS (the architect, 2026-10-06 — binding; the implementer builds to these)

- **F1 — RULED: V**, external content over the view of the source rows, exactly as proposed.
  The deciding reasons adopted: one sameness rule end-to-end (what matched IS what highlights —
  no Swift folding twin to drift), the integrity check against TRUTH (the probe's
  SQLITE_CORRUPT_VTAB detection is the derived family's honesty net), cheapest writes, text
  stored once. The V contract line is adopted verbatim: every source text write updates the
  index in the same statement with OLD = what was indexed (AFTER triggers), pinned per write
  layer at P6, the integrity check as the net.
- **F2 — RULED as proposed:** one doc row per source text FIELD; the eight (table, column)
  kinds; live-and-non-NULL existence; archived rows indexed with their fact; `scrap` a
  query-time facet (a stored kind would need a trigger READ — exactly what R-13o-4 forbids);
  the kind vocabulary closed and additive (VX-72's `commit_point.text` joins as a ninth kind
  someday, nothing reshapes).
- **F3 — RULED as proposed: own-row facts only**, the plan's "wing + archived columns" wording
  AMENDED to match for block-hosted docs (the plan bends to the measurement, not the reverse:
  S2's ~8 propagation triggers with structural reads inside trigger bodies is a correctness
  surface the mechanical-duty ruling exists to refuse). The cost class is unchanged
  (∝ matches); the absolute minority-scope prices (2.5 ms mid-term, 74 ms common-term-in-one-
  note at 55k docs) sit inside budget for a debounced search road. **WATCH-ITEM (named
  remedy):** if U2/U3's real-surface walks find a scoped road slow in the hand, S2 is the
  remedy — a local-only migration + one rebuild, no lockstep; the R-13o-4 record would then
  name the placement-seek and container-PK reads as the sanctioned exception.
- **F4 — RULED as proposed:** `unicode61 remove_diacritics 2` · `prefix='2 3'` · ONE indexed
  column with kind-weight as a query-time bm25 multiplier (the sparse-column penalty argument
  is correct and recorded).
- **THE EXPORT CONSEQUENCE — RULED: the DERIVED set.** `SyncSchema` gains `derivedTables`
  (the six search tables): the completeness walk's equality becomes
  localOnly ∪ derived == schema − synced, `StorePlaintextExport` keeps dropping
  **localOnlyTables only** — so an exported library carries a WORKING index and its capture
  triggers stay satisfied (no broken-trigger writes in the no-lock-in file; the open-format
  guarantee is the reason — an exported store is the product's promise, and the outbox's
  recorded broken-trigger consequence should not grow a second instance when one named set
  avoids it). All of it is the seam-2 Fable work (the granted slot): registry sets + the walk's
  test line + the export's unchanged drop list verified by its tests.
- **SEAM 2 stands as briefed:** the implementer commits `v1_22` (P4), records, pushes, stops;
  the architect lands the `Sync/` registry + walk + export-test accommodation; the implementer
  resumes P5–P9. The P-13o-U1-1…4 date-parse provisionals ride to the closeout ratify bundle.

#### SEAM 2 — LANDED (the architect's own commit, 2026-10-06; the granted `Sync/` slot)

The derived set is in: `SyncSchema.derivedTables = SearchIndex.tables` (one source of truth,
same module); the completeness walk now pins `localOnly ∪ derived == schema − synced` AND the
two sets disjoint; `StorePlaintextExport` is byte-unchanged (drops `localOnlyTables` alone) with
its doc comment carrying the ruling and a NEW pin — `theExportKeepsTheDerivedSearchIndexWorking`:
the exported file carries the six tables and answers `MATCH 'lighthouse'` through a bare
connection. Suites: SyncSchemaTests + StorePlaintextExportTests + MigrationTests 42/42 green.
**P4's rider RULED: `idx_container_undated_created` is APPROVED** — local-only, partial, no
§12 event (the v1_15/v1_17 index precedent: mirrors carry no client indexes), no shipped query
states its condition; it serves the worn-day seek and stays. The implementer resumes P5–P9.

#### §R-13o-4 RECORD — the Phase-2 re-assessment protocol, run for the third trigger duty (P3; written before any trigger line)

The protocol (`notes/plans/phase-02-operations-lifecycle.md`, Risks — "the trigger smell"):
the trigger families are a CLOSED set; pressure for a new trigger is diagnostic; re-assess in
order, and get the author's decision before any trigger gains domain knowledge. She ruled the
extension (R-13o-4, "Agree on your recommendation for R1") — this record is the provenance
OverallModel §9 demands, run honestly against the shape being built.

1. **Mis-filed semantics?** (operation logic wearing a propagation costume) — NO. The index must
   reflect every text write REGARDLESS OF LAYER, and three layers write text without passing
   through any operation: the tombstone CASCADES (a block's tombstone reaches its takes and
   comments inside `cascade_block_tombstone*`; a note's reaches its blocks; a book's its chapters),
   REMOTE APPLY (`SyncRow.apply` — a generic UPDATE-then-INSERT of whole rows, no operation), and
   the §7 REPAIRS + the purge janitor (explicit SQL; the janitor's physical DELETE). An
   operations-layer capture misses all three by construction — the exact argument that put outbox
   capture in triggers (SyncSpec §3). The capture is propagation, not semantics.
2. **Mis-decomposed operation?** — NO. No operation is being split or bent; the triggers carry
   no operation's rule, and no operation reads the index to decide anything.
3. **Mis-shaped schema?** — NO. The index is DERIVED, LOCAL-ONLY and REBUILDABLE from truth at
   any moment (P5's rebuild door; the integrity check compares it against the source rows). No
   invariant lives in it; no rule needs it as a home; deleting it loses nothing. The source schema
   is untouched.

**The domain-knowledge test (OverallModel §9's smell list), item by item — what the capture
triggers do NOT know:** which take RENDERS (chosen-pointer vs default fallback) · what a saved
VERSION is (the archived_at = created_at classifier) · what a SCRAP is (pool-ness of a home) ·
wing ISOLATION semantics (a dangling wing reads Home) · lock / seal · dirtiness · churn ·
ownership · intake. Every one of those is resolved at QUERY time by the one composer from
rows-as-truth. **What they DO, exactly:** per source (table, text column) — `variant.working_text`,
`variant.label`, `block.name`, `block_comment.text`, `container.title`,
`container.floating_notes`, `reading.name`, `reading_section.name` — on INSERT / UPDATE / DELETE,
mirror the field's EXISTENCE (row live ∧ field non-NULL) and its RAW TEXT into the index, plus the
source row's OWN id / parent-id / own wing / own archived columns. **Reads inside a body: the doc
family only** (to find the doc's rowid). No other table, ever (under F3 as proposed; if the
architect rules S2, this record names the two structural reads S2 would add — the live
placement by `block_id` and the container row by id — before they are written).

**Verdict: the closed set extends by exactly one family** — tombstone propagation · outbox
capture · **derived-index capture** — and the smell test survives intact for the future: a search
trigger that wants another table's value, or a rule, is the §9 smell, and stops for her decision.
The closeout amends OverallModel §9 + AppSpec §6's trigger sentence to exactly this (R-13o-4).

### U2 — THE FINDER (gated on her mockup pick; one implementer session; evidence: suites + the orchestrator's walk + screenshots)

The Library's search-active state per the picked mockup: the Passages section (snippets,
grouped under the shipped Books/Notes/Blocks idiom) · land-at-match (LandingTarget; the find
bar pre-armed so ⌘G steps onward) · ⌘K body hits under its title hits · the day filter grows
its RANGE with her wording for "on day…" (asked at the mockup sitting) · the block/scrap cap
falls to paging (R-13o-9) · owned notes show badged (R-13o-10) · the date-parse predicate
wired. Registry: every new door declared (P-1).

### U3 — SCOPES, FACETS & THE JOIN (one implementer session; evidence: suites + walk)

Within-a-book search (the same engine scoped; its face per the mockup round) · the
**tag-association join** (#tag surfaces the books/gatherings associated through intake rule +
outflow, TOP-RANKED — the §12 ruling) · the mode-facet chips (gathering · living · owned ·
finished · sealed — facts, never tags) · the archived facet's face · polish + the walk.

**MOCKUP ROUND (the U2 gate, orchestrator-authored):** one local HTML file,
`notes/plans/mockups/13o-search.html` — 2–3 directions for the search-active Library, both
voices, the §21 design-language anchor (the app's own idioms; no pills, no underlines); her
pick + "on day…" wording land here as rulings.

**Environment traps (every brief carries this verbatim):** instance checks via
`pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated by PATH; real-store instances by
STORE, never quit/kill one; no Release builds or `/Applications` refreshes while one lives;
every `xcodebuild test`/walk/Debug launch claims `Tools/stage` first (headless `swift
build`/`swift test` free); Mac tests from `App/Variorum/`, suite-level `-only-testing`,
confirm the "Test run with N tests" line, skipped-count honesty; NEVER a custom build
configuration; zsh `pipestatus`; A1 backups into `Backups/safety-copies/` before any
real-store touch; commit per piece, push after every commit, synchronous foreground waits;
never `git checkout` over uncommitted work. Work ONLY in `~/dev/variorum-13o`.

**Closeout (beyond the standing ritual):** canon deltas exactly as ruled — OverallModel §9 +
AppSpec §6's trigger sentence gains the third duty (R-13o-4); AppSpec §12 gains the search
contract line; the sameness-rule note; VX-5 Done rides the merge, VX-44 closes with U2 (the
body search IS the find&replace row's library half); MOBILE PARITY: the index + queries ride
VariorumCore onto the phone — the faces are the mobile catch-up's (a MobileSoul ledger row);
the in-flight row retires; the worktree is removed after the merge.

### LEDGER

| # | Item | Status |
|---|---|---|
| 1 | Sitting record + execution plan authored | DONE (this commit) |
| 2 | Linear: VX-72 (Search Everything) · VX-73 (power-search grammar) minted in project 13o | DONE — see tickets |
| 3 | Mockup round (`mockups/13o-search.html`) → her pick + "on day…" wording | OPEN — next act |
| 4 | U1 substrate | NOT STARTED |
| 5 | U2 finder (gated on 3) | NOT STARTED |
| 6 | U3 scopes/facets/join | NOT STARTED |
| 7 | Ladder → closeout → PR `VX-5: …` merges FIRST (R-13o-1); 13x unblocks — **PING the 13x session (`variorum-c0`) at the merge** (its 2026-10-06 ack + ask; it rebases and opens its Sync-composition batch on the ping) | NOT STARTED |
