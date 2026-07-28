# Phase 13d — orchestrator ROLE handoff (2026-07-27 evening)

**Why this exists:** the 13c/13d-kickoff orchestrator session reached
~620k tokens and the author stopped the first 13d batch to start a
FRESH orchestrator (her standing ~500k context-degradation rule —
`subagent-context-management` memory). This is the two-document-form
role handoff; the 13d plan (`phase-13d-refusal-ergonomics-floor.md`)
is the phase's running record and carries the kickoff, cast, batch 1
brief, rolled items, and gates.

## The role, as amended

13d architect/orchestrator under `/architect-phase` (the skill file
governs; CLAUDE.md outranks). **Cast — the author's ruling, verbatim:**
*"let's keep the implementation to Orchestrator Fable, implementer
Opus, and cold review at the end fable."* Operating reading (carried
from 13c's K6, recorded there): fresh Opus implementer per batch, NO
per-batch cold review — the orchestrator adjudicates each batch
(verify-don't-trust: counts by own runs, load-bearing diffs read); ONE
Fable cold review over the phase's combined diff at the end
(`REVIEW_PROMPT.md` verbatim, zero framing); further rounds only at
her word.

## State at cutover — VERIFY, never trust

- **HEAD `89ed1e0`, tree CLEAN.** The first 13d batch-1 agent was
  spawned and STOPPED before it acted (its transcript ends at "I'll
  start by reading" — zero commits, zero tree changes, verified by
  `git status`). **Batch 1 has NOT started. Re-spawn it fresh** from
  the 13d plan's "Ruled at the 13c walk — BATCH 1" section.
- **13c is fully CLOSED** including the post-closeout A47 family
  (phantom → frame → draw gap, all traced/fixed/installed — the saga
  lives in the 13c plan's A47b/A47c sections and Batch 1F/1G records;
  anyone touching `PaneSurface.swift` reads them first) and the ratify
  walk's batches 1–2 (rulings in the 13c plan's "THE RATIFY WALK"
  section + the walk status ledger at the end of `notes/QUESTIONS.md`).
- **Counts at 13d open: core 882/100 · Mac 788/135 · mobile 14/4** —
  verify with your own runs before building on them. No schema change
  since v1_12; mirror at marker 4.
- **`/Applications` carries the full A47c build** (installed 19:27 at
  her word, behind backup `variorum-backup-2026-07-28-012524.sqlite`).
  Installs happen ONLY at her word, zero-instance-checked, behind a
  fresh WAL-safe backup.

## Open author items (bundle at sittings, never drip)

- The **rolled walk items** — the checklist is the walk status ledger
  at the end of `notes/QUESTIONS.md`: #29–#33, #36, #37, #38, #42,
  minor sub-calls of #43–#47, #46's five, the C3 block-extent memo's
  Parts 1/3, and the long-content-panes memo's §6.
- The **field-guide re-seed** ("Restore Tutorial" from ⌘K — 2C revised
  the books lesson): on her 13c handoff checklist; never confirmed run.
- Her 13c handoff checklist generally
  (`notes/handoffs/phase-13c-handoff.md`) — walk items 1–3 are
  experience checks she may or may not have done.

## Machinery lessons (beyond what the plans record)

- The 13c plan's "Environment traps" section is CURRENT and binding by
  reference — including the 2E `-only-testing` false-green trap (the
  "Test run with N tests" line is the ONLY proof a suite ran; it has
  bitten twice) and the worktree-must-be-named-`variorum` SPM note.
- Implementer/investigator sessions on this machine run ~300–500k
  tokens each; keep briefs repo-first and self-contained (this cutover
  is the rule applied to the orchestrator itself).
- Her app is frequently LIVE during work sessions: instance discipline
  (pgrep + discriminate by path; never quit/kill; no Release builds or
  refreshes beside a live instance) binds every session.
- The A47 investigations twice found "the pin drives by hand what
  production never fires" (R3-4's class) — when accepting any fix that
  adds a trigger, demand the production-wired red.

## PASTE-READY KICKOFF (for the author to start the fresh session)

> /architect-phase 13d
>
> You are the fresh 13d orchestrator. Read the skill file, then
> `notes/plans/phase-13d-orchestrator-handoff.md` (the cutover state),
> then `notes/plans/phase-13d-refusal-ergonomics-floor.md` IN FULL
> (the phase's running record — kickoff, cast, batch 1, gates), then
> the 13c plan's constitution/environment/walk sections it points at.
> Verify the baselines with your own runs. First act: spawn Batch 1
> (the three ruled walk changes) to a fresh Opus implementer per the
> plan's brief.
