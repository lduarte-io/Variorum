# Phase 13g — Formatting, lists & checkboxes

**Status: PASTE-READY (authored at the 13f closeout, 2026-07-31, per
the front-loaded-planning rule). The author kicks it off at her
word.** Sequencing is HER round-5 ruling at 13f: 13f → **13g** → 13e,
then her choice. **13g's closeout AUTHORS 13e's plan** (her explicit
instruction: "leave a note for 13g to author 13e" — this is that
note; do not close 13g without it).

## Kickoff message (paste-ready for the orchestrator/coordinator the author invokes)

> You are running Variorum Phase 13g under the shape the author
> picks at kickoff (`/architect-phase` fits — the storage-format
> fork is design-heavy and wants sittings). Read IN FULL first:
> `CLAUDE.md` + the canon it loads (AppSpec §14's 13f delta is the
> latest state), this plan, `notes/handoffs/phase-13f-handoff.md`,
*[removed for publication]*
> inclination), `notes/TEXTKIT2_NOTES.md` (§1's
> `includesTextListMarkers` note and §3's broken-`NSTextList`
> warning are this phase's terrain), and the 13c plan's
> "Environment traps" (binding, as every phase). Verify the
> baselines with your own runs. Copy the P-1…P-9 constitution into
> this file verbatim if running under `/architect-phase`. **OPEN
> WITH THE AUTHOR-ATTENDED SITTING, in this order:** (1) **her 13f
> WALKTHROUGH** — walk `notes/handoffs/phase-13f-handoff.md`'s
> checklist with her item by item, recording her verdicts as
> sitting rounds (her round-15 directive at 13f moved the
> walkthrough here so that phase could close; her reports are
> findings — verbatim, routed, answered point-by-point); (2) the
> **MARKDOWN FORK** (below) — hers to rule; (3) the kickoff-sweep
> item (the shell-redo flaky pin's trace — the KnownIssues row this
> phase now owns); (4) cast confirmation.

## Goal

Text can look like text (her A33/A34, verbatim in the 13c intake
ledger): bold, italics, sizes, some markdown — **and the
list/checkbox maker she added live** ("a simple list maker and
checkbox maker (like hyphens, [], bullets)").

## The opening design fork (hers to rule; nothing pre-decided)

**Markdown-as-content** (zero schema; the stored text IS markdown;
export free; sidesteps the broken `NSTextList`; rendering is a
presentation transform) **vs. real attributed runs** (schema for
runs — a SyncSpec §12 lockstep event — plus editor-core work in
TK2's least reliable neighborhoods). This is an architectural fork
and hers.

**Her recorded inclination (2026-07-30, ahead of the sitting —
*[removed for publication]*
pre-decision):** markdown **DUAL-MODE** — one storage format
(markdown-as-content), two input faces (raw syntax, or
native-looking tools/buttons that insert it), export emitting proper
markdown either way. **Her 13f-kickoff words for this sitting's
agenda** (recorded at that plan's kickoff sitting, item 9): *"I'm
interested in trying to consider if we should have a 'markdown
mode' where you can write actual markdown and have it format as a
particular setting to have on, with the default just being like
normal rich text editor for bolding, italics, etc., but that can
still export correctly as markdown… worth considering and talking
about the tradeoffs for."* The sitting rules; the phase builds to
the ruling.

## Binding constraints (whichever fork she rules)

- `renderedText` / export / the Fragments bridge's join brain:
  semantics PINNED UNCHANGED (the one-join-brain rule; the bridge
  pushes what export emits). Any storage-format decision must state
  its export story before building.
- The seal, variant locks, and I4 (newlines are content) bind as
  everywhere; formatting must never become structure by accident.
- TEXTKIT2 §3/§1: `NSTextList` is broken since macOS 14 and the
  Tahoe `includesTextListMarkers` delta makes lists a known-rough
  area — treat any native-list temptation as the trap the notes
  say it is; §5 re-verifies after the phase's editor work.
- A schema-touching ruling is a SyncSpec §12 lockstep event —
  mirror-first, her explicit go (the R53 precedent).
- The P-1…P-9 constitution binds; the registry grows to cover new
  doors (formatting acts are acts: declared, walked, honest).
- No `Sources/VariorumCore/Sync/` lines without the standing rider.

## Carried into this phase

- **The 13f walkthrough** (the opening sitting's first act — the
  handoff doc's checklist; her verdicts become this plan's first
  sitting rounds; anything she overturns is this phase's early
  batch material).
- **The kickoff-sweep item:** the shell-redo flaky pin
  (`theShellRedoActionRunsThroughTheRunnerAndReports`) — the
  KnownIssues row now names 13g; trace the status-delivery timing
  when in that code (the hallucination guard binds: trace, never an
  untraced patch).
- **W17 (her infinite-scroll jot)** — exploratory, uncommitted;
  offer it at the sitting only if she raises it (the narrow
  jump-and-return reading is cheap atop 13f's carry/history
  machinery; the broad reading is a design conversation).
- **13i's brief** (`notes/plans/phase-13i-smart-book-identity-brief.md`)
  and **13h's design note** exist; neither is this phase's scope.

## Baselines at open (verify with your own runs)

Core **926/105** · Mac **1068/188** · mobile **14/4** — the 13f
finals, verified by that orchestrator's own runs 2026-07-31. No
schema since v1_12; mirror at lockstep marker 4. The tutorial spine
(49/7 by TYPE name) green.

## Verification

Per-batch: the standing loop (build → red-on-old pins by behavioral
revert with checksums and `build-for-testing` first → the tutorial
spine green by TYPE name → full suites, counts by the "Test run
with N tests" line; mobile when `Sources/`/`Shared/` is touched).
Review shape: the author sets it at kickoff. Every PROVISIONAL to
`notes/QUESTIONS.md` (append, never renumber — next free number at
authoring time: **#49**). **The closeout authors 13e's plan** (her
round-5 ruling — the takes & block management row, plus the
13e-owned KnownIssues rows: the takes-aware find&replace half, the
11a copy-doors flush alignment, and the 13e kickoff candidates
recorded at 13f round 11: the tag-surface ask + the in-post tags
face).
