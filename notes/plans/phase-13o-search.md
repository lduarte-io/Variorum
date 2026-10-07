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

## THE MOCKUP RULINGS — her picks, 2026-10-06 (verbatim-faithful; BINDING; closes ledger row 3)

- **R-13o-13 — THE DAY DOOR'S WORD: "when".** Her words: *"I like 'when' for the day door."*
  The control reads **when ▾** at rest, opening: on a day… · between days… · any day (the
  mockup's wording 2); the armed state shows in the band as a clearable chip.
- **R-13o-14 — WITHIN-BOOK SEARCH: the masthead magnifier.** Her words: *"I like search this
  book to the right (option 1), but collapse it into a magnifying glass and only expand it
  when clicked on."* → option 1's placement, resting as a 🔍 glyph at the book masthead's
  right, expanding to the field on click. The FACE is ruled now; the build stays U3's.
- **R-13o-15 — DIRECTION C, THE ANSWER SHEET.** Her words: *"I like direction C, the answer
  sheet, the best. i feel like it could also grow a more advanced mode easily - an extra
  dropdown for a more full search if we want to add that later. let's do that."* → U2 builds
  direction C: the ONE results band (query echo · honest counts · filters as quiet chips),
  passages GROUPED under their notes, every "all N ›" a real road. The band is shaped so an
  ADVANCED-SEARCH DROPDOWN can join it later without rework — recorded on VX-73 with her
  words; nothing of the advanced mode is built now ("if we want to add that later").

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

**U1 CLOSED (2026-10-06) — what U1 did NOT do, first:** no faces and no app wiring (the Library
field, ⌘K, a Settings "rebuild" row, a post-restore integrity pass — U2's and later); no
tag-association join, mode facets or within-a-GATHERING scope (U3's — P-13o-U1-10); no canon
deltas (the closeout's — R-13o-4's OverallModel §9 / AppSpec §6 lines); no `notes/QUESTIONS.md`
entries (a shared ledger, touched only at the merge moment — the PROVISIONALs P-13o-U1-1…10 below
ride to the closeout ratify bundle, as the architect ruled for 1–4); no walk or GUI evidence (the
brief's headless-only rule — this unit's evidence is the suites, the revert/sensitivity probes and
the counter-pinned P1 numbers); zero `Sync/` lines from this seat (seam 2 was the architect's).

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
| P9 | Close: the named suites green at the END, every claim flipped from PENDING, the report | DONE (this commit) — **the full core suite at the END: `swift test` EXIT 0 — VariorumCoreTests 2,255 tests in 253 suites PASSED (incl. the 3 gated bench tests counted-as-skipped, the live-Supabase pass and `writeAScratchLibraryLikeHers` skipped as before) + StringsWorkbookTests 40 in 6 PASSED.** The U1 search suites alone: `SearchQueryParserTests` + `SearchDateParseTests` 19 · `SearchIndexCaptureTests` 11 · `SearchPassagesTests` 14 · `SearchP1Tests` 2 · `MigrationTests` 28 (incl. the backfill pin). No PENDING claim remains. |

PENDING flags: none (every claim below is verified).

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

**P8 SENSITIVITY PROBES — DONE, tree restored** (sources committed clean at `a4db3a15`; each probe
restored by `git checkout --`): **S1** — the placement seek disabled in the composer
(`+pl.block_id`): the fixed-match pins go RED (`zanzibar` 515 → 1,447 pages across 5×; `the`
26,588 → 539,471). **S2** — `+kind/+src_id` on the UPDATE trigger's orphan-DELETE: GREEN, and
rightly so — that DELETE's `NOT (live NEW)` term is constant-false for a live edit, so SQLite never
runs its loop (the probe was mis-aimed, not the pin). **S2b** — `+kind/+src_id` on the trigger's
per-edit RETIRE lookup: the autosave pin goes RED (38.1 → 97.1 pages/edit across 5×). The P1 pins
catch a corpus walk on both roads.

**LIVE STATUS (2026-10-06): U1 CLOSED — P0–P9 DONE, the full core suite green at the end, the
tree clean, nothing reverted or in flight.** Ready for the orchestrator (U2 is gated on the mockup
pick; the ladder runs over the combined diff after U3).

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

### U2 — THE FINDER (UN-GATED by R-13o-13…15; one implementer session; evidence: suites + the orchestrator's walk + screenshots)

The Library's search-active state per **DIRECTION C** (R-13o-15; the mockup
`notes/plans/mockups/13o-search.html` is the visual record): the results BAND + passages
grouped under their notes · land-at-match (LandingTarget; the find bar pre-armed so ⌘G steps
onward) · ⌘K body hits under its title hits · the day door becomes **when ▾** with the range
(R-13o-13) · the block/scrap cap falls to paging (R-13o-9) · owned notes show badged
(R-13o-10) · the date-parse/worn-day predicate wired. Registry: every new door declared (P-1).

### U2 BRIEF (the implementer session's self-contained instructions)

**Who you are:** the U2 implementer (Opus, xhigh), ONE session, ONE acceptance unit — the
finder's faces. Work ONLY in `~/dev/variorum-13o` (branch `vx-5-13o-search`). **Required
reading:** this plan file WHOLE (the SITTING RECORD + MOCKUP RULINGS + §FORK RULINGS are
binding; the U1 RECORD tells you what the substrate gives you) · the mockup file's Direction
C + its shared-everywhere section (`notes/plans/mockups/13o-search.html`) ·
`notes/SessionResiliencyProtocol.md` (the checkpoint protocol binds from your FIRST commit).
Maintain the **U2 RECORD** below as LIVE STATUS. At most ONE Sonnet subagent, external facts
only, read-only.

**The pieces (direction C, built on `Queries.searchPassages` — extend the query layer only
through the one composer):**
1. **The BAND** (`Features/Library/`): appears only while a query is active — the query echo,
   honest per-kind counts, the quiet chips (`in: <wing>` · an armed `#tag ✕` · the armed
   when-range ✕ · `+ archived`). VoiceTokens only, both voices, dark; no pills/underline
   furniture beyond the mockup's. Shape the band's trailing end so a LATER advanced-search
   dropdown can join without rework (R-13o-15's growth note — build NOTHING of it).
2. **Passages grouped under their notes** — note title row (DisplayTitle), its page of
   snippet lines with `<mark>`-class highlighting from the index's own snippet segments,
   "in another take" badges where the hit's take is unrendered, "all N ›" a REAL road (pages
   through the keyset). Blocks & scraps join the same grouped listing; `blockCap` DIES —
   delete the constant, page like the notes (R-13o-9).
3. **The when door** (R-13o-13): the control-row word becomes **when ▾** → on a day… ·
   between days… · any day; armed state = the band's chip; the day answer stays the unpaged
   SET it is today; the RANGE rides `Queries.editedOnSQL`'s bounds unchanged in rule.
4. **Land-at-match:** clicking a passage opens the note in Write AT that block with the match
   selected and the find bar armed with the query (⌘G steps onward). **FENCE: ride the
   existing LandingTarget + EditorFind controller APIs — zero changes inside
   `EditorTextView`/`BlockRangeIndex`/`PaneSurface` internals. If a seam change proves
   genuinely needed, STOP and report (that opens TEXTKIT2_NOTES + the Fable rider — the
   architect's call, never yours).**
5. **⌘K:** a bounded few passages under the title hits (`CommandPalette` — same
   `searchPassages`, small page), landing exactly as 4.
6. **Wiring truths:** owned-book notes always list here, badged (R-13o-10 — the Library is
   exempt; pin it); versions never appear (the composer already fences — face-level pin);
   archived behind the band's quiet word; the worn-day predicate makes "september 14" find
   the nameless note end-to-end; scraps list in every wing (P-13o-U1-5 RATIFIED).
7. **Registry (P-1):** every new door declared; refusal/receipt copy through the standing
   kind seam; the registry walk green.
8. **Pins:** view-model state-transition tests for the band/grouping/paging; the cap's death
   pinned (a 41st block hit reachable); land-at-match + ⌘G pinned at the feature-API level;
   copy pins. The Mac suites you touch + **the tutorial spine (TutorialWalkTests)** green at
   the END.

**Environment:** the plan's environment-traps block VERBATIM binds. Mac app tests run from
`App/Variorum/` with suite-level `-only-testing` and **a HELD `Tools/stage` claim** (claim →
run → release; headless `swift build`/`swift test` needs none). No Release builds, no
`/Applications` refresh, never touch a real-store instance. The orchestrator's walk +
screenshots follow your close — your "done" is a claim, the walk verifies.

### U2 RECORD (LIVE STATUS — the implementer maintains this from its first commit)

**Seat:** the U2 implementer (Opus, xhigh), seated 2026-10-06 in `~/dev/variorum-13o` on
`vx-5-13o-search` (pulled at `5a34b842`). Required reading done in-context: this plan WHOLE (the
sitting record, the mockup rulings, §FORK RULINGS, the U1 RECORD), the mockup's Direction C + its
shared-everywhere section, `notes/SessionResiliencyProtocol.md`, TEXTKIT2_NOTES (land-at-match
reaches a pane), the 13b constitution P-1…P-9 + application notes; the code it builds on — the
U1 substrate (`SearchQuery`/`SearchQueryParser`/`SearchDateParse`/`SearchComposer`/
`Queries.searchPassages`), the Library feature (`LibraryCatalogModel` + `…Paging`/`…View`/
`…DayFilter`/`…Copy`/`…ListFace`/`…ListingReads`), `CommandPalette`, the landing road
(`ShellRouter.adopt(landing:)` → `PostDetailView.jump(to:)` → `EditorView(caretSeed:)` →
`EditorViewModel.applyFocusSeeds`), `EditorFind.performFind`, `WriteIntent`/`CommandRouter`'s
park-and-clear rules, the registry walk (`CapabilityRegistryTests`).

**MACHINERY (honesty, the resiliency protocol's rule 7):** the first U2 session was STOPPED by an
accidental user action mid-piece, after P0 (`84a7a759`) and P1 (`f41f7f44`), both pushed. It left
ONE uncommitted edit: `Queries/ShelfQueries.swift` — `catalogBookHit(_:)` factored out of
`catalogBooks` (byte-identical nouns) + a new `catalogBookHits(_:ids:)` (the named books' catalog
rows in the order given, dead ones dropped — the search state's Books section, D2). Its last words
were "Now the search state's own model (P-9: its own file and brain)", i.e. P2. **A CONTINUATION
session (Opus, xhigh) was seated 2026-10-06 from the repo alone** (this plan whole, the mockup's
Direction C + shared section, the resiliency protocol, the diff, the code above) and ADOPTED the
edit as P2's first commit, with a core pin (`SearchGroupsTests.theBooksSectionReadsTheNamedBooks
InTheOrderGiven` — 9/9 green). Nothing of the predecessor's design is re-derived; D1–D8 stand.

**THE DESIGN AS BUILT (decisions the brief does not make are marked PROVISIONAL — they ride to the
closeout ratify bundle with U1's; nothing here re-opens a ruling):**

- **D1 — the SEARCH STATE** is the Library while the field's text parses (v1 grammar) to a query
  with WORDS. It replaces the shipped title-LIKE narrowing on that road (R-13o-7: the field IS the
  one finder). The **band** shows whenever the question is non-empty — words, a typed `#tag`, or an
  armed when-range (PROVISIONAL P-13o-U2-1: the brief's "only while a query is active" read as
  "while the SearchQuery is non-empty", so an armed day is never invisible state).
- **D2 — the answer sheet (Direction C):** a BOOKS section (book + chapter hits, one row per book,
  all of them — ∝ the wing's books, the Bookcase's class) then ONE ranked stream of GROUPS — a note
  (or a scraps group) per row-head, ordered by its best hit, keyset-paged by group; each group
  shows its top 3 passage lines and an **all N ›** that expands it IN PLACE and pages its passages
  through `searchPassages(scope: .note(id))` (a real road). Note group heads ARE the List's note
  rows (`postRow` — click selects + info panel, ⌘/⇧ pick, menu, tags, owned badge), so the pick,
  the bulk bar and the panel keep working while searching: in the search state `noteHits` mirrors
  the note groups in order (the near-window extras/facts machinery reads it unchanged). Scraps
  groups head as their Snippets group (not pickable — not notes). `blockCap` and the truncation
  line DIE (R-13o-9).
- **D3 — the scope picker in the search state:** All · Notes (`.family(.notes)`) · Books
  (`.family(.books)`) · Blocks (scraps ∪ block-name hits — a new AST leaf `.docKind`, composed in
  the ONE composer). The band's counts are the WHOLE question's per kind (books · notes · passages
  · scraps), independent of the scope picker (PROVISIONAL P-13o-U2-2: per-kind counts tell her
  what the other scopes hold).
- **D4 — archived:** the band's quiet `+ archived` chip toggles the facet (living ↔ including
  archived; armed it reads `archived ✕`); with the facet off and archived matches present, the
  sheet's foot says so with a `show archived` word (PROVISIONAL P-13o-U2-3 wording: "N more in the
  archive" — U3 owns the facet's polish).
- **D5 — the when door (R-13o-13):** `when ▾` opens on a day… · between days… · any day; the armed
  state is the band's clearable chip; the no-words day answer stays the unpaged SET (now a RANGE,
  `Queries.editedOnSQL`'s bounds unchanged in rule); with words, the range is the AST's `.days`
  filter. Arming still moves a books/blocks scope to Notes (QUESTIONS #104's shipped clause).
- **D6 — land-at-match:** a passage click opens its note IN WRITE AT ITS BLOCK through the shipped
  landing road (`adopt(landing:)` → `jump(to:)` → the caret seed), carrying ONE more one-shot seed
  beside the caret's: the FIND seed — the passage's own matched word as the index highlighted it
  (the snippet's first match run, so it is the text as written). The arriving Write editor, after
  placing the caret at the block's start, puts the word on the find pasteboard (what ⌘E does) and
  runs `performFind(.show)` + `performFind(.next)` — EditorFind's own controller API — so the
  match is SELECTED and ⌘G steps onward. Zero lines in `EditorTextView`/`BlockRangeIndex`/
  `PaneSurface`; the seed is `EditorViewModel.applyFocusSeeds`' third one-shot beside
  `pendingCaretSeed`/`pendingFanSeed`. A hit in an UNRENDERED take arms the bar without stepping
  (the match is not in the shown text — PROVISIONAL P-13o-U2-4); name/label/comment/title hits land
  at the block or note with no find seed.
- **D7 — ⌘K:** a bounded few passages (5) under the title hits, landing as D6, plus one road row
  to the rest ("All matches in the Library ›" — opens the Library's search state on the same words;
  R-13o-9's no-cap-without-a-road, PROVISIONAL P-13o-U2-5).
- **D8 — P-9:** the search state's brain is its OWN model (`LibrarySearchModel`), owned by the
  catalog model the way `bookRowDoors` is; the band and the sheet are their own view files.

**THE PIECE PLAN (each its own commit, pushed; flipped here in the same commit):**

| # | Piece | Status |
|---|---|---|
| P0 | This record + piece plan (the first commit) | DONE (this commit) |
| P1 | CORE: the composer grows the GROUP page (top-K per group + group facts, keyset on best score) and the COUNTS statement (living + archived, per kind) over ONE shared hits builder (the shipped passages statement byte-unchanged in shape); `.docKind` AST leaf; `DayBounds` range init; `Queries.searchGroups` / `Queries.searchCounts`; headless pins (grouping, keyset, counts = the listing, EXPLAIN) | DONE (this commit) — `SearchComposer.hits` (one builder; `passages` rebuilt on it and verified BYTE-IDENTICAL against a pre-refactor snapshot of three shapes — living/facet/archived-only, library/book/note, cursor/no-cursor), `SearchComposer.groups` (`scored AS MATERIALIZED`, grouped by home, keyset `(g_best, g_home)`, top-K by `ROW_NUMBER` with the title ranked last, snippets for the top rows only) and `SearchComposer.counts` (one `hits AS MATERIALIZED` walk; living + all + archived places; worn ids folded in as JSON), `SearchFilter.docKind` + `SearchDocKind` (pinned = `SearchIndex.sources`' kinds), `DayBounds(firstDay:lastDay:)`; `Queries.searchGroups` (worn day leads page one, merged with its own group; note heads read as the catalog's `CatalogHit` for the page's homes only) + `Queries.searchCounts` + `SearchGroup`/`SearchGroupPage`/`SearchCounts`. `SearchGroupsTests` 8/8 + `SearchPassagesTests` 14/14 green; `SearchP1Tests` 2/2 green with the sheet probes added — **group page 225 → 344 pages, counts 147 → 228 across the 5× corpus (fixed matches; the passages road's own ×1.4–1.5 log residue)** |
| P2 | `LibrarySearchModel` + the catalog's search-state routing (noteHits mirrors note groups; `blockCap` + truncation DIE); model pins (the band's state, grouping, paging, the cap's death — a 41st scrap reachable) | DONE (`6d86c95c` core half + this commit) — `Features/Library/LibrarySearchModel.swift` (`LibrarySearchQuestion` — the field's text → the AST + the range, `scoped(_:)` D3, `removingTag` for the chip's ✕; `LibrarySearchListing`; the model: facet, question, counts, books, groups + cursor, expansions "all N ›" paged by `searchPassages(.note(home))`, the pure reads `listing`/`groupPage`/`books`) · `LibrarySearchRouting.swift` (the catalog's seam: `isSearching`, `searchGroupAppeared` → `loadMoreSearchGroups` appending heads to `noteHits` once each, `removeTypedTag`, `toggleArchivedFacet`) · `LibraryCatalogModel` routes the field (words → the answer sheet; a `#tag` alone → nothing listed, P-13o-U2-6; none → the shipped listing UNNARROWED — the title-LIKE road retired), `refresh` re-reads groups to depth with opened groups re-read; **`blockCap`, `truncatedKinds`, `listingIsTruncated`, the block arm, `LibraryCopy.showingTheFirst` and `LibraryTruncationLine` DELETED**. The List view's block section/truncation row removed (the sheet's faces are P3). Pins: `LibrarySearchStateTests` (10 — the AST read, scopes, the chip ✕, the heads mirror the groups, tag-alone, the counts never move with the scope, **the 41st named block and the 41st–60th scrap reachable**, a superseded page never lands, in-place re-read at depth with groups kept open, the facet) — compiled (build-for-testing EXIT 0), **run PENDING (the stage is held by VM-5; runs at P8)**. JUSTIFIED EDITS: `LibraryDayFilterTests.theClearDoorReturnsTheWholeLibrary` (the named block is a passage of its note's group now) and `.theNotesBodysTruncationIsAboutNotes` (the truncation flag died) |
| P3 | The band + the answer sheet (views; both voices via VoiceTokens) | DONE (this commit) — `LibrarySearchBand.swift` (echo · "— N books · N notes · N passages · N scraps" · chips `in: <wing>` / `#tag ✕` / the armed day ✕ / `+ archived`↔`archived ✕`; hairline chips on the paper, the invitation dashed; the trailing end LEFT OPEN for VX-73's dropdown, nothing built) · `LibrarySearchSheet.swift` (Books section in the List's face; ONE ranked stream of groups — note heads ARE the catalog's `postRow` in the List row + pick background, scraps heads open the scraps area; ≤3 lines with the index's own marks on the wash, kind words, "in another take"; `all N ›` → `more ›`/`fewer ‹`; the group pager's sentinel; "Nothing matches."; the archived foot "N more in the archive — show archived") · `LibrarySearchCopy.swift` (every word, one place). `LibraryCatalogView`: the band under the controls whenever the field asks or a day is armed (never in the Timeline); the sheet replaces the List AND Cards bodies while the field asks; the sort door becomes the static `relevance · best first` while the sheet shows (PROVISIONAL P-13o-U2-7 — P-2); the dead `blockLine` removed; a passage click lands at its block through the shipped Stage C road (P5 adds the find). Pins: `LibrarySearchFaceTests` (the counts' words, the marks, the badge rule, the kind words, the band mounted in both voices × light/dark) — compiled, **run PENDING (P8)** |
| P4 | The when door (range) — model + face + pins | DONE (this commit) — `LibraryDayFilter.swift`: `LibraryDayRange` (first…last inclusive, real days, ordered); the door is `LibraryWhenDoor` — `when ▾` (her R-13o-13 wording 2, `VoicedMenu`) → **on a day…** (arms the armed run's first day, else today) · **between days…** (arms the run as it stands, else today–today) · **any day** (clears; disabled when nothing is armed), each arming at once and opening a popover with its date field(s) (FROM past TO carries TO and vice versa — a run is never empty); `LibraryDayFace` gains `chipLabel` (*edited on Sep 9* / *edited Sep 1 – Sep 14*), `rangeWords`, `emptyAnswer(range:)` (*…between Sep 1 and Sep 14.*), the three choice words; `closedLabel` = "when". Model: `editedRange` is the stored truth (`editedOn` = its first day, the 18h callers unchanged), `setEditedRange` (arming still moves Books/Blocks to Notes — #104's clause), `rangeForEmptyAnswer`; the read converts through `DayBounds(firstDay:lastDay:)` (the no-words SET rides `Queries.editedOnSQL` unchanged; with words the range is the AST's `.days` filter, D5). The band's day chip reads `chipLabel` with its ✕. Pins: `LibraryWhenRangeTests` (5 — the range's order/validity, the door's own closures, a run's SET with no words, the run narrowing the answer sheet + its counts, the words) — compiled, **run PENDING (P8)**. JUSTIFIED EDITS in `LibraryDayFilterTests`: the three pins that built `LibraryDayField` now build `LibraryWhenDoor` and drive its one-day field's own binding / `on a day…`'s own closure; the label pin reads "when" (R-13o-13 supersedes 13i-d U6 (c)'s "edited on…") |
| P5 | Land-at-match (the find seed) + pins at the feature-API level (⌘G steps) | NOT STARTED |
| P6 | ⌘K passages + the road row + pins | NOT STARTED |
| P7 | Wiring truths pins (owned notes listed badged; versions never; archived behind the word; "september 14" end-to-end; scraps in every wing) + registry declarations + walk | NOT STARTED |
| P8 | Close: touched Mac suites + TutorialWalkTests green at the END (held stage claim), record final | NOT STARTED |

PENDING flags: **the Mac pins have not RUN** (the stage is held by the VM-5 merge orchestrator;
every Mac suite this unit touches runs together at P8 under a held claim) — `LibrarySearchStateTests`
and the two justified `LibraryDayFilterTests` edits are compiled only.

**New PROVISIONAL (continuation):** P-13o-U2-6 — a `#tag` typed WITHOUT words lists nothing
(the band names the tag; the sheet asks for words) — the composer serves no text-less question
(P-13o-U1-7), the shipped title-LIKE road found nothing for "#tag" either, and the tag-association
join that answers a tag alone is U3's.

More PROVISIONALs (continuation): P-13o-U2-7 — while the answer sheet shows, the `sort ▾` door
stands down for a static `relevance · best first` (the mockup's words; a menu that could not
change the order would be a door that cannot act, P-2); P-13o-U2-8 — a non-prose passage wears
its kind word before its snippet ("block name", "comment", "take label", "floating notes"), so a
block's name never reads as its prose; the sheet renders in the Cards mode too (the passages need
the List's room), and its open-group words are `more ›` / `fewer ‹`.

P-13o-U2-9 (continuation): choosing `on a day…` / `between days…` ARMS at once (today, or the run
already armed) and opens the date field(s) in a popover — the shipped door's own convention (a
date field opens on today), so the band's chip and the listing answer from the first click.

**LIVE STATUS (2026-10-06, the continuation): P0–P5 committed; P6 (⌘K passages + the road row)
next.**

### U3 — SCOPES, FACETS & THE JOIN (one implementer session; evidence: suites + walk)

Within-a-book search (the same engine scoped; its face RULED R-13o-14: option 1's masthead placement resting as a magnifying-glass glyph, expanding to the field on click) · the
**tag-association join** (#tag surfaces the books/gatherings associated through intake rule +
outflow, TOP-RANKED — the §12 ruling) · the mode-facet chips (gathering · living · owned ·
finished · sealed — facts, never tags) · the archived facet's face · polish + the walk.

### U3 BRIEF (the implementer session's self-contained instructions; authored at the overnight open)

**Who you are:** the U3 implementer (Opus, xhigh), a FRESH session, ONE acceptance unit —
scopes, facets & the join. Work ONLY in `~/dev/variorum-13o` (branch `vx-5-13o-search`); pull
first. **Required reading:** this plan file WHOLE (the three rulings blocks + the U1/U2
RECORDs — build ON the substrate and U2's faces, never beside them) · the mockup's Direction
C + within-book Option 1 (`notes/plans/mockups/13o-search.html`) ·
`notes/SessionResiliencyProtocol.md` (checkpoint protocol from the first commit; the **U3
RECORD** below is your LIVE STATUS). One Sonnet subagent max, external facts, read-only.

**The pieces:**
1. **Within-a-book search** (R-13o-14): the book masthead's trailing 🔍 glyph — nothing else
   at rest — expanding to the field on click (Esc/empty-blur collapses); the SAME engine with
   `.book` scope; results in the book's own idiom (the answer-sheet band's small sibling or an
   in-place list — PROPOSE in the U3 RECORD before building the face half if the mockup
   leaves you a real fork); land-at-match identical to the Library's.
2. **The within-a-GATHERING scope** (P-13o-U1-10, now due): `.book(id)` on a gathering
   searches its ASSEMBLED members — the rule evaluated at query time through the ONE composer
   (never a second assembly path); a gathering with no rule answers empty (the ruled closed
   reading). PROPOSE the mechanism (rule → member-id predicate vs join) with a measurement
   line before building.
3. **The tag-association join** (the §12 ruling): a query whose parse carries a tag term
   surfaces the books/gatherings ASSOCIATED with that tag — intake-rule tag terms AND
   `auto_tag_ids` outflow — TOP-RANKED in the Books group, worded so the row says WHY (the
   mockup's "#dream flows here"). Pure-function the association read; pin it.
4. **The mode-facet chips** (facts, never tags): the band's "+ book state" chip opening
   gathering · living · owned · finished · sealed; composing with everything else through the
   AST's filter tree only.
5. **The archived facet's face** finished end-to-end (the band chip + the quiet word's road,
   U2's "show archived" wiring completed wherever U2 left it PENDING).
6. **Registry (P-1)** declarations for every new door; copy through the kind seam; polish per
   the mockup.
7. **Pins:** composer-level pins for the gathering scope + association join (EXPLAIN where
   plans matter); face/view-model state-transition tests; the touched Mac suites + the
   tutorial spine green at the END.

**Fences, verbatim from U2's (all binding):** zero `Sync/`; zero editor-core internals;
query-layer only through the one composer; environment traps verbatim; Mac suite runs under a
HELD stage claim — **you are in a SCHEDULED stage queue: message the session named "13o"
(the scheduler) for a slot BEFORE claiming; headless swift build/test is free.** End-of-
session report: hashes, self-assessment, PENDING flags, proposals awaiting rulings.

### U3 RECORD (LIVE STATUS — the implementer maintains this from its first commit)

*(empty — the U3 session writes here.)*

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
| 3 | Mockup round (`mockups/13o-search.html`) → her picks | **DONE 2026-10-06** — R-13o-13 "when" · R-13o-14 the book masthead magnifier (build at U3) · R-13o-15 direction C with the band's advanced-dropdown growth note (→ VX-73) |
| 4 | U1 substrate | **DONE 2026-10-06** — P0–P9 landed (close 3251cce7); the ORCHESTRATOR'S CHECK: commits + clean pushed tree verified, the four search suites + MigrationTests re-run green on the orchestrator's own machine (46/46 + 42/42 at seam 2), the U1 RECORD complete with the close banner and zero PENDING. Evidence of the unit's kind: state-transition + P1 page-count pins (headless substrate; USE evidence arrives with U2's walk). P-13o-U1-5 RATIFIED by the author same day (the question tool): SHARED ROOM — scrap hits list in every wing's search, matching the Snippets surface; wing isolation stays total for everything else |
| 5 | U2 finder (gated on 3) | IN PROGRESS — un-gated 2026-10-06, implementer spawned on the U2 BRIEF |
| 6 | U3 scopes/facets/join | NOT STARTED |
| 7 | Ladder → closeout → PR `VX-5: …` merges FIRST (R-13o-1); 13x unblocks — **PING the 13x session (`variorum-c0`) at the merge** (its 2026-10-06 ack + ask; it rebases and opens its Sync-composition batch on the ping) | NOT STARTED |
