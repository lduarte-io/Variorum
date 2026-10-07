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

The DESIGN SITTING's brief + question agenda were delivered to the author in-session this turn;
her rulings land here verbatim as they arrive, then the execution plan is authored below.
