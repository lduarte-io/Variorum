# Phase 14a — architect handoff (written 2026-08-04 at ~500k, the author's context-window rule)

> **SPENT — the phase CLOSED 2026-08-04.** The fresh architect ran the full
> remainder from this file (ladder → gate → closeout); kept as history. The
> author-facing record is `notes/handoffs/phase-14a-handoff.md`; the phase
> record is the plan file.

## The cutover shape (her ruling, round 0z — with the architect's one refinement, accepted)

The sitting session receives batch 1's report, ADJUDICATES it, and records the
adjudication in the plan file; the author then opens a FRESH architect session
with the paste message below. The refinement to her floated shape: the
"verify and recheck" role is the COLD REVIEWER (fresh eyes, REVIEW_PROMPT
verbatim, zero implementation context — the standing ladder), not the next
implementer; a fresh IMPLEMENTER then applies confirmed fixes. Independence is
what makes the recheck worth anything.

## The author's paste message (copy verbatim into the fresh session)

You are the FRESH ARCHITECT for Variorum Phase 14a (repo ~/dev/variorum,
branch main), taking over mid-phase at the author's ~500k context-cutover
rule, under /architect-phase discipline (the skill file governs; CLAUDE.md
binds). The prior architect session ran the full kickoff sitting (rounds
0d–0z in the plan file) and spawned batch 1; its adjudication of batch 1's
report is recorded in the plan file.

READ FIRST, in your own context, in order: (1)
notes/plans/phase-14a-architect-handoff.md — THE entry point: live state,
remaining work in order, exact gate steps, standing cautions. (2)
notes/plans/phase-14a-suite-identity.md — the RULED STATE banner; the Batch 1
brief AS AMENDED (rounds 0w/0x changed scope items 2/3/4); "### Batch 1 —
implementer report (self-assessment)"; the architect's Batch 1 adjudication;
sitting rounds 0d–0z as needed (rounds SUPERSEDE earlier sections where they
differ). (3) notes/fragments-bridge-contract.md — the READ-THIS-FIRST pointer
+ EXECUTION MODEL + touchpoint blocks. (4) The master plan's 14a/14b/14c rows
and CLAUDE.md's closeout ritual — note the NEW MobileSoul parity-line rule.

IF the implementer report or the adjudication section is missing from the
plan file, STOP and tell the author — never reconstruct either from guesswork.

THEN, in order: (1) the cold-review LADDER on batch 1's combined diff — a
FRESH cold reviewer per round, notes/REVIEW_PROMPT.md verbatim, zero
implementation context, findings + dispositions recorded in the plan file;
the hallucination guard binds every fix (traced mechanism + red-on-old pin,
revert-verified both directions); cap three rounds. (2) Confirmed fixes go
to a FRESH implementer session (all-Fable cast, ruling R1); adjudicate
disputes against the spec docs — the spec outranks both agents. (3) The
GATE: the dashboard steps exactly as the handoff lists them — announce each,
the author's explicit go per step, the zero-identity caution on her identity
deletion, and do NOT touch the Fragments project. (4) The CLOSEOUT ritual in
full per CLAUDE.md plus the handoff's step 4 — archives, the MobileSoul
parity line, notes/handoffs/phase-14a-handoff.md with her checklist at top,
and the 14b kickoff DRAFT with its pinned sitting questions (device
enrollment phone-first · Fragments-insights-vs-journal-E2EE ·
wipe-and-repush vs in-place mirror migration · the KDF/recovery/enrollment
one-way doors; the wrap-secret and journal-class-only rulings are SETTLED,
never re-opened). (5) Report to the author; she opens 14b with its sitting.

STANDING: the author has PAUSED all Variorum usage until Phase 14 completes;
the signups-off toggle is the SOLE corpus guard — nothing you do touches it;
ZERO lines in Sources/VariorumCore/Sync/ (any need = stop and report); the
mirror is live production (announced changes only, committed artifacts, her
explicit go — the stored-PAT arrangement exists for authorized server work);
commit AND push at bout ends; baselines are in the handoff — never re-run at
session start.

A FRESH architect session resumes the phase from this file + the plan file.
Nothing in the original sitting session's context is load-bearing — the plan
file's rounds 0d–0y ARE the record (the repo-first discipline held all night).

## Read first, in this order

1. `notes/plans/phase-14a-suite-identity.md` — the RULED STATE banner, then the
   Batch 1 brief AS AMENDED (rounds 0w/0x changed scope items 2/3/4), then the
   sitting rounds you need for any specific question (0d–0y; they supersede
   earlier sections of the file where they differ).
2. `notes/fragments-bridge-contract.md` — the READ-THIS-FIRST pointer + the
   EXECUTION MODEL + three TOUCHPOINT blocks (the one-batch-at-14c's-end model).
3. The master plan's 14a/14b/14c rows (all amended through 2026-08-04) and
   CLAUDE.md's closeout ritual — NOTE the NEW mobile rule: the closeout must
   write the MobileSoul parity-ledger line (here: mobile ships the same sign-in
   change simultaneously via the shared seam — no parity debt).

## Live state at handoff

- **The author has PAUSED all Variorum activity until Phase 14 completes**
  (round 0v) — app, bridge, mobile. The store is quiescent.
- **Batch 1 is COMPLETE and ACCEPTED at the architect level** (commit
  `5082a51` + the SignInFlow deletion on `0fd1314`; the implementer session
  died after its implementation commit, so the report section in the plan
  file is ARCHITECT-RECORDED from its final status + the diff). **The
  architect's own acceptance runs: ALL FOUR SUITES AT BASELINE** — core
  1039/114 · Mac 1193/208 (the tripwire confirmed BY IDENTITY in an isolated
  re-run) · mobile 172/24 · spine 51/7. Scope compliance verified against
  the file list (zero Sync/, no schema, bridge untouched, net −25 lines).
  The adjudication section in the plan file lists what the ladder should
  weigh with fresh eyes. **Your first act is the cold-review ladder on
  batch 1's diff** (`git show 5082a51` + the SignInFlow deletion in
  `0fd1314`).
- Baselines (post-mobile-merge; never re-run at session start): core 1039/114 ·
  Mac 1193/208 (the standing TakePane tripwire red by identity) · mobile
  172/24 · spine 51/7.

## What remains of the phase, in order

1. **Receive/read batch 1's report** (in the plan file if the message was
   lost). Adjudicate the self-assessment.
2. **The cold-review ladder** on the batch diff — fresh reviewer per round,
   `notes/REVIEW_PROMPT.md` verbatim, findings + dispositions recorded in the
   plan file; the hallucination guard (traced mechanism + red-on-old pin)
   binds all fixes. Cap three rounds.
3. **The GATE (dashboard/server acts — announce each, her go, stored-PAT
   arrangement where applicable):** delete the `custom:fragments` IDENTITY on
   *[removed for publication]*
   the new direct sign-in works on the installed build (she has only that one
   identity; see round 0s's zero-identity caution — verify state before/
   after); delete the `custom:fragments` PROVIDER config on the Variorum
   *[removed for publication]*
   `Spikes/SuiteAccountSpike/` (throwaway by design; evidence lives in the
   plan file); **do NOT touch Fragments' project** (its old issuer stays ON
   until the one-batch handoff — contract item 5's guard is now moot for the
   APP once direct sign-in ships, but the shutdown is the Fragments batch's
   act, not this gate's); refresh `/Applications` per CLAUDE.md (pause makes
   timing flexible; instance traps still bind); the author signs out/in once
   with email+password as the live acceptance — **and ratifies (or adjusts)
   the R1-1 PROVISIONAL refusal wording "Wrong email or password." at the
   same sitting** (the ladder's round-2 R2-1 catch: the ratify must ride a
   checklist, not just the ladder table). The phone half of the walk also
   verifies R1-2 (the un-clipped sign-in sheet) live.
4. **The CLOSEOUT ritual, in full** (CLAUDE.md): plan file results + complete
   mark · master plan table/pointer · archives roll (pointer, closeout
   paragraph, AppSpec §14 delta — note: 14a shipped NO schema and NO AppSpec
   §14 delta unless the batch surprises) · **the MobileSoul parity line** ·
   `notes/handoffs/phase-14a-handoff.md` with her checklist at top (must
   include: her bootstrap-password change at `/oauth/reset`; the custom
   domain guardrail timing; the one-batch Fragments handoff living on the 14c
   row) · **author the 14b kickoff draft** (the design-sitting agenda — the
   named questions already pinned on the 14b row: device enrollment
   phone-first · the Fragments-insights-vs-journal-E2EE question ·
   wipe-and-repush vs in-place mirror migration · KDF/recovery/enrollment
   one-way doors; the wrap-secret ruling and journal-class-only ruling are
   SETTLED, not re-opened) · commit + push.
5. **Report to the author.** She opens 14b with its sitting; cast lean
   recorded all-Fable (her word on the row).

## Standing cautions

- **Subagent background-wait DEATH (the batch-1 implementer's failure mode —
  instruct every spawned session against it):** a subagent that launches a
  long run (build/test) in the background and ENDS ITS TURN to "wait for the
  notification" is self-terminating — the harness reads a stopped agent with
  no tracked children as COMPLETED, the background work dies with it, and
  the transcript may be cleaned up (batch 1's was — resume returned "no
  transcript found"). Spawned implementers and reviewers must run acceptance
  suites SYNCHRONOUSLY (wait in-turn, filtered output) and commit their
  reports to the repo BEFORE any long wait. Repo-first reporting is what
  made this death cost only test runs.
- **Shared-checkout commit discipline:** implementers work in this same
  checkout. While one is live, architect commits MUST use the pathspec form
  (`git commit -m "…" -- <paths>`) — a bare commit takes the whole index and
  swept the implementer's staged SignInFlow.swift deletion into docs commit
  0fd1314 (harmless there, but the class is real).

- Sessions are not data — but the mirror is LIVE production; every server
  change is announced-first, committed-artifact, her explicit go (SyncSpec
  §12 discipline; the R53/PAT precedent).
- The signups-off toggle is the SOLE corpus guard until 14c (round 0j — the
  allowlist was stood down at her word). Nothing this phase turns it on.
- Zero `Sync/` lines expected phase-wide; any need = stop and report.
- Her rulings supersede in rounds — when any doc section contradicts a later
  round, the round wins; fix the doc, never improvise.
