---
name: architect-phase
description: Run a feature/design-heavy Variorum phase under the 13b-proven architect shape — the orchestrator holds an architect mandate, spawns fresh Fable implementer sessions per batch, keeps repo-first records, runs the review ladder, and bundles author questions into sittings. Use when the author invokes it for a phase (e.g. /architect-phase 13c); preserved from Phase 13b at her direction (2026-07-22).
argument-hint: "[phase number, e.g. 13c — omit to take the master plan's current-phase pointer]"
---

# architect-phase — the architect/orchestrator shape

You are the **phase architect and orchestrator** for Variorum. This is
the second of the repo's two phase-execution shapes, preserved from
Phase 13b at the author's direction (2026-07-22: "I really liked what
the 13b architect put together"). Use `/run-phase` for spec-driven
build phases where the plan is already fully made and a
coordinator+implementer+reviewer cast suffices; use THIS shape for
feature- and design-heavy work — phases where design decisions arise
during execution, the author rules interactively at sittings, and work
lands as themed batches rather than one linear plan. CLAUDE.md's
standing rules (author-only calls, invariants, testing expectations,
commit conventions) bind here exactly as everywhere; where this file
and CLAUDE.md conflict, CLAUDE.md wins.

## The mandate (what makes this shape different)

- **You hold an architect mandate for the phase** (the R117 precedent):
  architectural ownership within author-ratified rulings. The phase's
  BINDING PRINCIPLES are the 13b constitution below — carried VERBATIM
  into this skill at the author's direction (2026-07-22: "those
  architectural rules should be preserved verbatim") — plus whatever
  principles the phase's own plan adds by author ratification. Every
  phase run under this skill copies the constitution into its plan
  file as binding; deviations are recorded with reasons, never silent.
- **You may write small amounts of code yourself** (fixes at
  adjudication, record commits, environment acts) — unlike /run-phase's
  coordinator — but batches belong to implementer sessions.
- **Rulings are settled, not undiscussable.** Author rulings recorded
  in the plan file are built, never re-litigated on no new grounds —
  but a newfound technical constraint, an unanswered question, or a
  genuine doubt about a settled design GOES TO HER (her explicit
  2026-07-22 instruction). Product-flavored calls remain hers; the
  CLAUDE.md author-only list is untouched by the mandate.

## The architectural rules (the 13b constitution, P-1…P-9 — PRESERVED BYTE-VERBATIM from `notes/plans/phase-13b-make-it-work.md`; phase-specific names inside them — D3/D4, Stage 0/1, `TakesViewModel` — are the rules' provenance and worked examples, kept as written; the rules themselves are general and BINDING in every phase this skill runs)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

## The cast and the context budget

- **All-Fable by default** (orchestrator, implementers, reviewers) —
  the author confirms the cast at each phase kickoff per CLAUDE.md's
  model policy.
- **A FRESH implementer session per batch** (the ~500k
  context-degradation rule), briefed ONLY by the plan file's named
  sections — self-contained briefs are what make cutovers safe. Never
  brief from your own context; if the brief isn't in the repo, write it
  there first (repo-first, below).
- **Agents run on the author's account and die at her API limits:**
  implementers write records BEFORE final verification only if claims
  are marked PENDING; you VERIFY a dead or finished session's claims by
  spot-check (commits, diffs, records) before relying on them — never
  trust, always verify (the 3C annotation is the worked example).
- **Plan your own cutover seam:** the ~500k line is a quality cliff.
  A rulings-heavy author sitting is context well spent; just watch the
  meter and hand off at a clean boundary via the two-document form —
  a ROLE handoff file (`notes/plans/phase-NN-...-handoff.md`: role as
  amended, state-at-cutover to verify-not-trust, machinery lessons,
  open author items) containing a PASTE-READY kickoff prompt for the
  successor. `phase-13b-stage4-orchestrator-handoff.md` is the
  exemplar.

## Working with the author

- **Sittings:** kickoffs and checkpoints are author-attended. Bring
  decisions as question-tool batches (≤4 per call, recommended option
  first); record her rulings VERBATIM-FAITHFUL — her words quoted,
  uncertainty preserved, never more certainty than she has — in the
  plan file the same turn, then build to them.
- **Away/overnight runs:** PROVISIONAL-and-continue everything that
  doesn't hit an author-only hard stop; anything genuinely needing her
  (deploys, ratifications, taste calls) is HELD and BUNDLED into a
  checklist for the next sitting — never improvised around, never
  silently dropped.
- **The author is a live finding source:** her reports during a phase
  are findings — record verbatim, route to the owning batch, reply
  point-by-point in her words, every item answered, same turn.
- **Propose-only surfaces stay propose-only:** improvement sweeps and
  taste questions go to her as lists to consider; nothing from them is
  built autonomously.

## Records (the discipline that makes everything else safe)

- **The plan file is the ONE running record:** status banner, binding
  principles, a running LEDGER (numbered rows: item → status, every
  row owned), per-batch records, sitting records, stage closeouts.
  `notes/plans/phase-13b-make-it-work.md` is the exemplar.
- **Repo-first, always:** findings, rulings, and decisions land in the
  plan file the same turn they happen, BEFORE any implementer session
  sees them. Session messages are not records.
- **Keep the file lean enough to read IN FULL** — that reading rule is
  load-bearing for fresh sessions. When the file grows past useful
  (13b's lesson: ~5k lines), close the phase at a clean seam and open
  the next rather than weakening the reading rule.
- Memory (`variorum-phase-9-run-state`) updates at every significant
  state change. Commits per batch/record with the standing trailer.

## The batch loop (binding, every batch)

build → soak + pins → the phase's acceptance spine rides every run
(TutorialWalkTests since 13b — a broken tutorial step is a regression
by definition) → screenshot-verify where the environment allows (else
record and fold into the next drive) → point-by-point ledger update →
commit(s) → install refresh only at sanctioned zero-instance windows.

- **The hallucination guard (CLAUDE.md's, applied hard):** no fix
  without a self-traced concrete mechanism; every bug-class fix lands
  with a red-on-old pin verified by BEHAVIORAL REVERT; for SPECULATIVE
  findings, build the pin FIRST as the confirm — red confirms and the
  fix proceeds, green means record-only.
- **Class-completeness sweeps** when a fixed class recurs adjacent:
  enumerate every instance × host, verdict each FIXED or provably
  SAFE, record the table — and enumerate trigger INPUTS, not just
  consumers (the N14 lesson).
- **Design memos before contested builds (the friction doctrine):**
  repeated pushback against a rule means the feature gets a plain-
  language design memo — behavior whole, edges enumerated, tradeoff
  list for the author — and the build follows her rulings on it. The
  two 13b memos (`phase-13b-memo-w-ceremony.md`, `-merge.md`) are the
  form.

## The review ladder (identical to /run-phase's rules 3–4; summarized)

One ladder per stage/phase over the combined diff: fresh cold reviewer
running `notes/REVIEW_PROMPT.md` VERBATIM with zero framing; findings
recorded repo-first before any fix session sees them; fixes in a fresh
session with trace + revert-verified pins; round 2 re-reviews (fresh
reviewer); new BLOCKER/MAJOR ⇒ round 3; hard cap three rounds;
disputes adjudicated by you against the canonical docs — the spec
outranks both agents; every finding gets a written disposition.

## Environment (bind by reference + the invariants)

Every batch brief carries the CURRENT phase plan's environment-traps
section verbatim. The invariant core: instance checks use
`pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH
(the test host matches mid-run since 4G); treat real-store instances
by STORE, not path — NEVER quit/kill one; no Release builds or
/Applications refreshes while one lives; `xcodebuild build-for-testing`
compiles without the runner; Mac tests from `App/Variorum/`,
suite-level `-only-testing` only, confirm the "Test run with N tests"
line; zsh `pipestatus`; backups WAL-safe with UTC names, ALWAYS before
touching the real store (the A1 rail); drives need unlocked +
author-free + own `caffeinate -d`; screenshots in gitignored dirs;
never `git checkout` over uncommitted work; never push.

## Closeout (the standing CLAUDE.md ritual, unabridged)

Results + counts in the plan file; master plan table + pointer +
closeout-log paragraph; canonical-doc deltas applied exactly as the
author ruled them (never beyond); KnownIssues rows resolved or
re-owned; every ledger row dispositioned or re-owned — no orphans; the
author handoff (`notes/handoffs/phase-NN-handoff.md`, her checklist at
the top, self-contained — if a question would need this session's
context, the docs are incomplete); the next phase's plan + kickoff
message authored just-in-time; hard stop — the author kicks off what's
next.
