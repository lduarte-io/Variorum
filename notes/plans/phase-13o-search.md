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
