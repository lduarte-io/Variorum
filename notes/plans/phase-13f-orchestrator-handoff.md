# Phase 13f — orchestrator ROLE handoff (prepared 2026-07-30, ~490k; the cutover seam is batch 4's acceptance)

**This is the role file for a SUCCESSOR ORCHESTRATOR session.** The
phase's ONE running record is `notes/plans/phase-13f-workspace.md` —
read it IN FULL; it is self-contained (constitution, kickoff sitting,
rounds 1–11, batch briefs 1–4, batch records + acceptances). This file
adds only what a fresh session cannot get from it: the role as
amended, cutover state to VERIFY-not-trust, and machinery lessons.

## Paste-ready kickoff for the successor

> You are the Phase 13f (Workspace) architect/orchestrator for
> Variorum, resuming at a session cutover (the ~500k rule). Invoke
> `/architect-phase 13f`. Read IN FULL: `CLAUDE.md` + the canon it
> loads, `notes/plans/phase-13f-workspace.md` (the ONE running
> record — constitution, sitting rounds 1–11, batch records), this
> handoff, the 13c plan's "Environment traps", and the 13d closeout's
> "Standing notes for successors". VERIFY (never trust) the cutover
> state below with your own runs and `git log`. The cast is ruled:
> Fable orchestrator · a fresh Opus implementer per batch · ONE Fable
> cold review at phase end. Respond to the author point-by-point in
> her words, every message (standing memory rule). Record repo-first,
> same turn, verbatim-faithful with her uncertainty preserved.

## The role as amended (beyond the skill's text)

- The author's parallel RELEASE-STRATEGY session commits to `notes/`
  *[removed for publication]*
  — its commits: f3b5251 · 11a8a0e · 32f1933 · b347e7a incl. the
  PHASE 14 SPLIT into 14a–14d). ALWAYS stage by explicit path; never
  commit/touch her files; 13f is a V1 GATE per her strategy file.
- Sequencing RULED (round 5): 13f → 13g (plan authored at THIS
  phase's closeout) → 13e (13g's closeout authors its plan; leave that
  note in the 13g plan) → her choice (13h note + 13i brief exist).
- The verify-don't-trust adjudication loop is the standing shape:
  counts by YOUR OWN runs quoted per suite; load-bearing diffs read;
  every flagged judgment call adjudicated in a written acceptance in
  the plan file; then the next batch briefed IN the plan file before
  its agent spawns (agents are briefed ONLY by plan-file sections).

## Cutover state (VERIFY with own runs; true as of commit 7e2c5ee)

- **Batches 1–3 ACCEPTED** (acceptances in the plan file; last
  verified counts: core 906/102 · Mac 987/159 after batch-4 item 0 ·
  mobile 14/4 — mobile re-verify owed at phase end).
- **Batch 4 (the split) ACCEPTED** (2026-07-30, this session's last
  act — the acceptance is in the plan file): counts verified by own
  runs core 906/102 · Mac 1003/165; both gate-condition pins
  verified (R4-A reproduces the LIFO hazard live); the adoption-door
  finding endorsed. NOTHING is in flight at cutover.
- **Batch 5 queue (briefed NEXT, in the plan file, after batch 4's
  acceptance):** (1) per-window router/workspace FIRST (ShellRouter is
  App-level @State shared across WindowGroup windows — batch 4's
  recorded finding; nothing ships a second window before this); (2)
  A26 windows both kinds (round 2: full app windows + note-only
  "Open in New Window"); (3) W20 the ascent door (wire
  MembershipChip.onOpenBook — dead since Phase 13 — + the foldable
  ONE context bar: back chip + "in <book>" in-line folding together,
  one keyboard/menu toggle; chooser order = curated before smart,
  session-recency floats within group; reveal-at-post via the batch-2
  grammar; history pushed); (4) W21 cross-mode position carry in
  books (Outline·Book·Read switches carry the current post — verified
  ABSENT today, the picker just sets `structure.mode`); (5) W22 the
  first-edit note (one-time, app-local seen flag, status voice,
  CARRIES the W23 button); (6) W23 diverge-for-this-book (the
  compound: `duplicateAsVersion` + membership swap at position, THIS
  book only; refuses under a finished book).
- **Then:** W4 stars (synced `setting` list — the `shelf_pins`
  precedent, zero schema; Starred sidebar section, cap 5) · W5 the
  quick-note floating mini-window (bookless note, no takes machinery
  on the sticky face) · W6+W15 the K5 sweep LAST (post→"note"
  strings + Blocks→"Snippets"; UI strings only) · W17/A32
  infinite-scroll = exploratory sitting material, uncommitted · W19
  the shell-redo flaky pin (kickoff-sweep item, trace when in that
  code) · phase-end: ONE Fable cold review (REVIEW_PROMPT.md
  verbatim, zero framing), closeout ritual, 13g plan authored.
- **Open with her:** W10's remaining propose-onlys are DONE (ruled);
  the visual-verification lists from batches 1–4 await her walk; the
  QoL-handoff standing items (field-guide re-seed, extract one-liner)
  are still hers; QUESTIONS next free number: **#49** (nothing added
  this phase so far).

## Machinery lessons (this session's, beyond the standing traps)

- The proposal gates keep earning their cost (batch 4's produced the
  mount-rule audit and the ShellRouter finding BEFORE code).
- Green guard-reverts got stronger arms FIRST four times across
  batches 1–4 (record each; it is the guard working).
- The SwiftUI drag route is UNPINNABLE in the test host (private
  selector `_lastDragDestinationOperation`, crash-verified) — pin at
  the model layer, list the visual halves honestly.
- Appending to the 13i brief with `cat >>` stranded a knot after
  References once (fixed e137636) — insert into lists with python,
  not appends.
- Her rounds arrive mid-batch; record verbatim SAME TURN (rounds 1–11
  are the form), rule or route each item, and reply point-by-point in
  her words — every item, every message.
