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
| P1 | MEASUREMENTS + THE FORK PROPOSAL — contentless vs external-content FTS5; doc normalization (per source row vs per rendered unit); where scope (note/wing/archived) lives. A throwaway measurement suite over synthetic corpora; numbers + tradeoffs written below. **→ SEAM 1: stop for the architect's ruling before the schema half.** | NOT-STARTED |
| P2 | Domain, fork-independent: the `SearchQuery` AST (text terms + filter tree, R-13o-8) + the v1 grammar parser (words · "phrases" · `#tag` · facets) + the DATE-PARSE predicate (R-13o-6 — "september 14" / "sep 14" / "9/14" → day bounds), pure, exhaustive little tests | NOT-STARTED |
| P3 | The Phase-2 re-assessment record for R-13o-4's third trigger duty (below), BEFORE any trigger line | NOT-STARTED |
| P4 | Migration `v1_22` ALONE: the doc table + the FTS5 table (`unicode61 remove_diacritics 2`, prefix indexes) + the mechanical capture triggers + the backfill (the rebuild SQL run once). **→ SEAM 2: SyncSchemaTests' completeness walk goes red — the exact new table names land here, push, stop for the orchestrator's registry line.** | NOT-STARTED |
| P5 | The rebuild door (a maintenance operation: drop + rebuild from truth) + the integrity check (doc rows vs source rows) | NOT-STARTED |
| P6 | The capture pins — operations · cascade · fake-server remote apply (each red when its trigger is dropped, verified by revert) + tombstone/archive transitions + wing isolation + accent/case folding + rebuild idempotence | NOT-STARTED |
| P7 | The ONE Domain SQL composer (AST → SQL) + `Queries.searchPassages(_:scope:filters:)` — bm25 ranked (title-weighted, rendered-take boosted), snippeted, wing-scoped always, note/book scopes, archived facet, paged with a road to everything (R-13o-9); EXPLAIN pins | NOT-STARTED |
| P8 | P1 measurements as pins + the NUMBERS here (update cost ∝ the edit, flat across corpus sizes; query cost ∝ matches; the keystroke road bounded) | NOT-STARTED |
| P9 | Close: the named suites green at the END, every claim flipped from PENDING, the report | NOT-STARTED |

PENDING flags: none yet.

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
