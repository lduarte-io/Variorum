# The pre-beta standing-fix runs — RUN A (custody & the text-loss doors) · RUN B (sync correctness)

**Written 2026-09-14 at the 13u1 kickoff, at the author's instruction (her words, the sitting's
R-13u-6):** *"please write a plan + kickoff orchestrator for the ones that can run together / be
done by a single orchestrator. do some of them naturally fit into a phase together? if not I can
also run them one by one, but I want to be able to move through them easily."*

**What this file is:** the choreography for the crucial-17 block she confirmed (17i · 17l · 17n ·
17b, plus 17d + the stress-test pass before 13y and 17m before the packaging build), grouped by
what NATURALLY runs under one orchestrator. **The entries themselves live in
`notes/plans/phase-17-standing-fixes.md` — that file is the binding item record; this one adds
grouping, order, cast and paste-ready kickoffs.** Each run is an ad-hoc phase under a Fable
orchestrator (her recorded practice, PhaseSizingGuidance §5), closes each entry under the
standing rules (every item FIXED-with-pin / DISMISSED-as-hollow / DEFERRED-with-owner; the
dispositions copied into the entry at its close), and ends with a checkpoint report — one
invocation per run, never auto-advancing.

**The grouping logic (why two runs, not four-and-more):**
- **17l, 17n, 17m and 17b share a cast and a review shape** — custody/keychain surfaces and
  operations-layer doors, Opus implementers under a Fable orchestrator, ONE Fable cold-review
  ladder (custody in the diff makes Fable mandatory; R-cor-14). 17m with 17l/17n is the same
  subsystem opened once, and it satisfies its own "before the packaging build" constraint early.
- **17i, 17d and 17l's item 5 are ALL `Sources/VariorumCore/Sync/`** — the standing rider makes
  every line Fable work, and they share one instrument (the Phase 5 two-client harness). 17l
  item 5 (the double-passphrase re-wrap, `CorpusRotation.swift`) MOVES from RUN A's roster to
  RUN B for exactly this reason — same fix class, right cast.
- **The stress-test agent's pass** (the pre-13x CONSIDERATIONS' ten questions) runs BESIDE RUN B
  — its findings become 17 entries or 13y items, so running it before 13y's lockstep is the
  point. It is her-triggered and read-only; RUN B's orchestrator can host it or she runs it
  separately.

**The order (after the 13u phases, per her 2026-09-14 roadmap):**
RUN A → RUN B (+ the stress pass) → 13y → 13r (packaging; 17m already done in RUN A) →
🍰 FRIENDS BETA.

---

## RUN A — custody & the text-loss doors: 17b + 17l (items 1–4, 6–7) + 17n + 17m

**Cast:** Fable orchestrator · `opus-implementer` per batch (one at a time) · ONE Fable
cold-review ladder over the run's combined diff (custody + operations doors ⇒ Fable mandatory).
**Shape:** three batches, strictly sequential, each walked/drilled per its kind before its
record closes; zero schema; `Sync/` is FENCED (17l item 5 is RUN B's — any other fix that wants
`Sync/` lines stops and reports).

- **Batch A1 — 17b, the six text-loss doors** (P4 · P5 · P6 · P7 · P14 · P36 — the entry's own
  text has every trace). Consequence-class evidence: red-on-old per door; the P7 flush-first fix
  verified against OverallModel §3's "branching inherits the current buffer".
- **Batch A2 — 17l items 1–4, 6–7 + 17n** (the seeder latch · the drill's escrow-leg scope ·
  her #90 wording rulings incl. *Pick Up New Keys* · the dead Replace-All-Keys door from the
  main window (a root-level presenter, pinned) · the *(0 of 0)* face · the NIT-N8/#90-residue
  copy · the 12-character encryption-passphrase floor at every SETTING door, never at unlock).
  The phrase-transit KnownIssues row's one-arm pin rides here (17l's re-own).
- **Batch A3 — 17m, the Re-link-your-Apple-account door** (the entry's text is the spec: consent
  sentence · passphrase · one proof-authorized re-land of the Apple-held copy; refuses when `A`
  is unreadable; pins as written).

### Paste-ready kickoff (RUN A's orchestrator)

> You are the Fable orchestrator for **RUN A — custody & the text-loss doors** (17b + 17l items
> 1–4/6–7 + 17n + 17m), an ad-hoc standing-fixes phase per `notes/plans/pre-beta-standing-fix-runs.md`.
> READ FIRST, in full: `CLAUDE.md` + the canon it loads · that runs file · the four entries in
> `notes/plans/phase-17-standing-fixes.md` (17b whole with its verifier traces; 17l; 17n; 17m) ·
> `notes/QUESTIONS.md` #90 (her rulings the wording items execute) · `notes/KnownIssuesAndTechDebt.md`'s
> phrase-transit row · `notes/SessionResiliencyProtocol.md` · `notes/PhaseSizingGuidance.md` §5.
> Cast: `opus-implementer` per batch (A1 doors · A2 custody residuals + the floor · A3 the
> re-link door), one at a time; ONE Fable cold-review ladder (`fable-reviewer`,
> `notes/REVIEW_PROMPT.md` verbatim, zero framing) over the combined diff, cross-model flow,
> cap three rounds. PIN BEFORE FIX on every item (a pin green on both sides = DISMISSED AS
> HOLLOW, recorded); 17l item 5 is NOT yours (RUN B's, `Sync/`); any fix wanting `Sync/` lines
> stops and reports. Drills are the custody evidence (the entry texts name them); walks on the
> dev-store Debug build only; never touch `/Applications` or her real store mid-run. Implementer
> briefs RESTATE the checkpoint protocol (commit+push per piece; LIVE STATUS from the first
> commit; foreground poll-loop waits; no subagents beyond one Sonnet lookup). At close: each
> entry's dispositions copied into `phase-17-standing-fixes.md` (17b/17l/17n/17m close; the
> phase itself never does), KnownIssues rows resolved/re-owned, the install refresh AFTER the
> walk (A1 backup first), the master plan's order line ticked, a checkpoint report with her
> ratify list. Hard stop after the run — RUN B is a fresh invocation at her word.

---

## RUN B — sync correctness: 17i + 17d + 17l item 5 (+ hosting the stress-test pass at her word)

**Cast:** Fable orchestrator · **Fable implementer** (every line is `Sources/VariorumCore/Sync/`
or its harness — the standing rider; no Opus seat in this run) · Fable cold review per ladder
round. **Shape:** the 17i HUNT first (the four probes → the scenario sweep under production's
round shape → findings become items), then the fixes (17i's tag.path repair item; 17d's four,
with P8's "the run IS the pin" rule; 17l item 5's same-descriptor re-wrap with her
passphrase-wrap-only scope), then the harness-realism structural deliverable (`productionRound`
becomes the convergence suites' default). One ladder over the combined diff. A live two-device
round on the real mirror is the sync-kind acceptance evidence (her devices — coordinate the
window with her; nothing deploys server-side: zero lockstep, marker stays 8).

### Paste-ready kickoff (RUN B's orchestrator)

> You are the Fable orchestrator for **RUN B — sync correctness** (17i + 17d + 17l item 5), an
> ad-hoc standing-fixes phase per `notes/plans/pre-beta-standing-fix-runs.md`. EVERYTHING in
> this run is `Sources/VariorumCore/Sync/` work or its harness — the standing rider: Fable
> implements, Fable reviews; no Opus seat.
> READ FIRST, in full: `CLAUDE.md` + the canon it loads (SyncSpec WHOLE — §§5–7 and §12 are the
> contracts under test) · the runs file · `notes/plans/phase-17-standing-fixes.md` entries 17i
> and 17d (P8's next step is A RUN in the Phase 5 harness, not a fix — reproducing it IS the
> pin; not reproducing it closes it as refuted) and 17l item 5 · the 17i brief
> `notes/plans/pre-13u-memo-sync-disagreements.md` WHOLE · `notes/sync-postmortem-fragments.md`
> (the standing read before changing anything in Sync/) · the KnownIssues tag.path row ·
> `notes/SessionResiliencyProtocol.md`.
> Order: the probes and scenario sweep FIRST (every answer recorded in the memo, confirming or
> not), then fixes pin-first, then the harness-realism deliverable (production's round shape as
> the suites' default; chunk splits at registry boundaries). Canon outranks code: a probe that
> falsifies a SyncSpec sentence is a finding against the CODE unless she rules the sentence
> wrong — log such to `notes/QUESTIONS.md`, never decide. The 13y-adjacent residuals (the
> dedupe's late-registry legs, 18a's rows) are NOT yours — re-verify their owners, don't absorb
> them. Acceptance: convergence suites green under the NEW harness shape + one live two-device
> round on the real mirror (HER window — ask; zero server deploys, marker 8). The stress-test
> agent's pass may run beside this run at her word (read-only; its findings file as 17/13y
> candidates). Checkpoint protocol restated in any brief; dispositions into the entries at
> close; hard stop; 13y is next and is NOT yours to start.

