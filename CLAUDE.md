# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Source of truth (authoritative)

These documents define **Variorum**. When implementing, refactoring, or making decisions, treat them as canonical:

- Vision for the app: @notes/CoreDescription.md
- App Spec: @notes/AppSpec.md
- System Mental Model: @notes/OverallModel.md
- Sync Architecture: @notes/SyncSpec.md
- Detailed Build Plan: @notes/DetailedPlanForPhases.md
- Known Issues & Tech Debt: @notes/KnownIssuesAndTechDebt.md
- TextKit 2 build companion (editor phases): @notes/TEXTKIT2_NOTES.md

Original source material (requirements verbatim, original spec, design rationale, chat transcript) is preserved in `notes/source/` — history, not truth.

If code conflicts with the spec/model, call it out explicitly and align the implementation to the spec/model (or propose a deliberate spec/model change).

## Core product principles (non-negotiable)

- **The atomic unit is the block.** Nothing owns blocks; everything points at them. Every view is a traversal of one graph — never a bespoke subsystem.
- **Canonical persisted truth lives in SQLite (GRDB), rows-as-truth.** Every mutation flows through the transactional operations API — never ad-hoc row edits.
- UI state is a **projection**, not a source of truth.
- **Mutation is local and ephemeral; permanence is explicit and append-only.** The only mutable text in the system is `variant.working_text`.
- **Coarse, not forensic.** Lineage is `(fromBlock, toBlock, type)`. Anything that tracks word-level change is out of scope by definition.
- **Cost ∝ viewport + edit, never document/corpus size.** Performance invariants (P1–P3) are as load-bearing as data invariants.
- Avoid denormalization: names/labels/text are never copied across entities (lineage copies like pool-drag are *deliberate operations*, not denormalization).

## Invariants (must be enforced in Domain / Operations)

Defined precisely in @notes/OverallModel.md §4–6 and @notes/AppSpec.md §5. By ID: **I1–I10** (data: variants never span blocks; single ownership; chosen-variant-on-pointer; newlines are content; commits append-only; lock ⊥ commit; no nesting; posts are edges-only; cross-block = edges; live block ⇒ live variant), **P1–P3** (performance), **S1–S5** (sync-shaped writes). Violating one quietly corrupts a whole class of views — enforce via pure domain rules and DB constraints, not views.

## Architecture rules

Settled: **SwiftUI + Observation + swift-dependencies** (no TCA). The editor core is AppKit — a TextKit 2 `NSTextView` wrapped for SwiftUI; SwiftUI does all chrome.

- One feature = one self-contained module under `App/Features/`, composed at the app level — new features are new modules, not additions to existing ones.
- View models are `@Observable`, hold projections, and call operations; **no business rules in view models, no side effects constructed in them.**
- All persistence and side effects happen in injected dependencies (`@Dependency(\.database)`, etc.).
- Views render state and send actions only; no business logic in views.
- Use injected dependencies for time/identity (`@Dependency(\.date)`, `@Dependency(\.uuid)`) so logic is testable and IDs/timestamps are deterministic under test.
- Store IDs or lightweight derived values in state, never copies of persisted text.
- Cross-feature interactions route through parent composition, never feature-to-feature calls.
- Domain rules (invariant enforcement, churn math, boundary snapping, segmentation) are **pure functions** in `VariorumCore/Domain`, tested independently.
- TextKit 2 discipline (editor phases): never touch TK1 APIs (`.layoutManager` etc.); opt into TK2 explicitly; install the fallback canary from the first editor commit. See @notes/TEXTKIT2_NOTES.md §4.

## Source of truth & persistence

- **SQLite via GRDB 7 is the canonical local persisted truth.** WAL mode; all DB I/O off the main thread; reads via the reader pool.
- UI reads from local data only (GRDB ValueObservation for live projections).
- Sync is **early** (Phase 5 — the author journals from her phone soon after) and its architecture is settled in @notes/SyncSpec.md: remote is a sync peer; the server is dumb (CAS + changefeed); all merge intelligence is client-side. Schema v1 already contains the sync machinery (`sync_version`, outbox triggers, fractional-index positions) — honor it in every phase; don't build the *engine* before Phase 5.

## Build workflow (how phases work)

This is the workflow — keep it.

- **`notes/DetailedPlanForPhases.md`** is the master plan: the phase table, a "current phase" pointer, and a running one-paragraph closeout for each completed phase (what shipped, test results, what was deferred and where it went).
- **`notes/plans/`** holds one execution plan per phase/sub-phase, each **self-contained for a fresh Claude session**: goal, references, file-level steps, **tests for every step**, verification. Written **just-in-time, one phase ahead** — never plan the whole app up front.
- **Closeout ritual** at the end of each phase: record results in the plan file, mark it complete, update the master plan's table + pointer, **write the next phase's execution plan AND a kickoff message at the top of that plan file** (self-contained: what a fresh session should read, do first, and verify), and commit per convention. The closeout of phase N is the starting context for phase N+1.
- **Schema/model changes get their own commit** before code that uses them, so rollbacks are clean.
- **`notes/KnownIssuesAndTechDebt.md`** tracks deliberately-deferred work only. Rule: no new entry without naming the phase that resolves it — if nothing owns it, fix it now instead of parking it.

## Autonomous phase execution (2026-07-06 amendment — active only in `/run-phase` coordinator sessions)

The author can delegate phase execution to a coordinator session via the `/run-phase` skill (`.claude/skills/run-phase/SKILL.md`). This is a deliberate process amendment (adapted from the author's ClipFarm workflow), not drift. The rules:

- **The coordinator knows the whole picture before anything else happens.** Preflight reading is mandatory and complete: this file, `notes/CoreDescription.md`, `notes/OverallModel.md`, `notes/AppSpec.md`, `notes/SyncSpec.md`, `notes/DetailedPlanForPhases.md`, `notes/KnownIssuesAndTechDebt.md`, `notes/QUESTIONS.md`, and the current phase plan in `notes/plans/` — plus `notes/TEXTKIT2_NOTES.md` for editor-adjacent phases (6, 7, 9+).
- **Cast per phase: exactly three parties.** The coordinator (writes no feature code) + ONE implementer agent + ONE cold reviewer agent, strictly sequential — never two agents working concurrently. Subagents never spawn subagents, except the single Sonnet lookup helper allowed below. No fan-outs, no swarms, no Workflow tool, no extra verifiers. **This is also the token budget:** the whole point of the three-session shape is that it replaces a manual flow that worked because it was only ever two chats — keep it that lean.
- **Model policy (author-settled 2026-07-06; amended later the same day at the forward-planning session — Fable token supply is now constrained, so Fable is spent where its judgment pays most: cold reviews, which caught both Phase 5 BLOCKERs, and the single riskiest implementation).** Per-phase assignments:
  - **Phase 8:** coordinator **Opus** · implementer **Fable** · cold reviewer **Fable** (author, 2026-07-07 — revised from Opus/Fable: Phase 8 is where the engine meets real networks, real scheduling, and the fault-injection amendments, and surfacing sync issues is worth Fable end-to-end; the Phase 9 contingency below covers this phase too if the budget disagrees). *Standing rider from the same call:* any change **inside `Sources/VariorumCore/Sync/` itself** is **sync-engine surgery** and is Fable work in *every* phase while tokens last — in Opus-implemented phases the coordinator stops and reports rather than letting the implementer touch it.
  - **Phase 9:** coordinator **Opus** · implementer **Fable** · cold reviewer **Fable**. Pre-agreed contingency (author, 2026-07-06): if Fable is exhausted/unavailable, the implementer falls back to Opus and any remaining Fable goes to the review — no mid-phase renegotiation.
  - **Phase 10:** coordinator **Opus** · implementer **Opus** · cold reviewer **Fable** — the cross-model review flow below applies.
  - **Phase 11 onward:** implementer **Opus**; cold reviewer **Fable while the budget allows** (the author's 2026-07-07 read: the Opus-implements/Fable-reviews split stays worthwhile from Phase 10 onward), under the same cross-model review flow; falls back to an Opus reviewer with the hardened `notes/REVIEW_PROMPT.md` + Review-foci checks when the budget ends. The author may redirect at any kickoff.

  Reading discipline is model-independent: the implementer always does its own spec reading, in its own context, before touching code (reading is never delegated to a cheaper agent). The exposure cap is unchanged by the amendment: coordinator + two agents, nothing else, ever, of any model; the lookup exception below adds only Sonnet.
- **Front-loaded planning (author-settled 2026-07-06, same session):** `notes/plans/phase-09-structural-gestures.md` is pre-written (Fable), and `notes/plans/phase-10-brief.md` / `phase-11-brief.md` / `phase-12-brief.md` are design briefs. The closeout ritual's "write the next phase's plan" duty adapts: **Phase 8's closeout reconciles the pre-written Phase 9 plan** (its Reconciliation checklist) instead of authoring one; **Phases 9–11's closeouts author the next just-in-time plan FROM the corresponding brief** — the brief's author-ratified decisions are binding, its open interpretations are the plan's to answer. The just-in-time rule is satisfied by reconciliation/incorporation, never by ignoring the brief. **Phases 13–15 additionally have orientation sketches** (`phase-13/14/15-brief.md`, author-requested 2026-07-07) — tradeoff framing only, expected to partially stale, binding nothing beyond the spec decisions they cite; their just-in-time plans treat them as a head start, not a contract.
- **Lookup exception (author-settled 2026-07-06):** the implementer and the cold reviewer may each run **at most one Sonnet lookup subagent at a time**, strictly for **external facts** — web searches, Apple documentation, API signatures/availability — returning facts and quotes. Reading the repo's canonical docs, the phase plan, code, or the diff under review is never delegated: that reading is what the phase buys, and a summary in its place is the failure mode this workflow exists to avoid. Lookup agents are read-only (no file edits, no commits) and never spawn agents of their own.
- **Hard stop after every phase.** One `/run-phase` invocation = one phase (implement → cold review → adjudicate → closeout), ending in a checkpoint report to the author. Never auto-advance to the next phase; the author kicks off each one. (Product and quality stay in her loop by construction.)
- **Two reviews per phase:** review 1 = the implementer's self-assessment in-session; review 2 = a cold reviewer running `notes/REVIEW_PROMPT.md` **verbatim** with zero implementation context (the coordinator never summarizes the work to the reviewer — the isolation is the point). In **same-model phases** findings are adjudicated implementer-vs-reviewer, the coordinator arbitrates against the spec docs (the spec wins), and the implementer applies the fixes. **Cross-model review flow (author, 2026-07-07 — applies whenever the reviewer is Fable and the implementer is not):** findings go to the implementer verbatim as always and it returns agree/dispute with rationale — but the coordinator does not arbitrate: the responses go back to the **reviewer**, which makes the final call on each finding (a dispute is a reason to recheck, or to dismiss as wrong — the spec outranks both agents) and **implements the fixes for its confirmed findings itself, in its own session**. Rationale: an implementer that could wrongly dismiss a finding could equally lack the understanding to fix it, and findings escalated to the author without context aren't useful. After the reviewer's fix pass the suite must be green, and the implementer gets one sanity pass over the reviewer's diff (it holds context the reviewer doesn't; anything it raises returns to the reviewer for the final word). Either way: max two review rounds, **every finding gets a written disposition** in the phase plan's closeout, and a dispute that turns on undefined product behavior goes to `notes/QUESTIONS.md` — neither agent decides product.
- **PROVISIONAL rule** (the autonomous variant of "propose options instead of implementing assumptions"): ambiguity that doesn't gate the phase's core → document 2–3 options in the phase plan, implement the most spec-defensible one, mark it **PROVISIONAL**, log it in `notes/QUESTIONS.md` for the checkpoint's ratify list. Ambiguity that gates the core → stop and report instead.
- **Author-only calls — never made autonomously, by coordinator or subagent:**
  - inventing product behavior, or changing/contradicting the canonical docs beyond recording the closeout's deltas and the author's explicit in-session decisions;
  - violating or relaxing any invariant (I1–I10, P1–P3, S1–S5) or performance budget;
  - adding any new third-party dependency (license vetting is hers);
  - anything requiring her accounts, credentials, or machine-side GUI steps (Supabase setup, Xcode project creation, signing, TCC prompts);
  - adjudicating a Phase 6-class gate (the TK2 viability decision memo is hers to accept);
  - deleting or overwriting anything she created; pushing to origin; any history rewrite.

## Testing expectations

- New **domain invariants or business rules** must land with tests (Swift Testing).
- Operations get exact state-transition tests (rows read/written); view models get focused coverage for core flows and edge cases.
- UI-only changes may be untested early; domain logic may not.
- Tests run at the **END** of a step/phase — **never run the full suite at the start of a session.** The previous phase's recorded closeout result is the baseline.
- Editor milestones additionally re-verify against the current Tahoe point release per the matrix in @notes/TEXTKIT2_NOTES.md §5 (TK2 behavior shifts between point releases).

## Product behavior guardrails

- **Do not invent product behavior.**
- If the spec/model does not define behavior, propose options instead of implementing assumptions.
- Prefer surfacing uncertainty over silently choosing.
- In the technical phases, views are built functional and unstyled — zero investment in visual polish until the UI design phase (with the author).

## Code hygiene

- No global singletons; everything flows through injected dependencies.
- Keep helpers and utilities small, explicit, and purpose-driven.
- Avoid "god state" or dumping grounds for logic.
- If a function/view model is getting long, you're probably mixing concerns — split it.

## Guidelines for the build

1. **Every action should be traceable to a spec behavior.** If you can't point to the section of @notes/AppSpec.md (or CoreDescription/OverallModel) that justifies it, question whether it belongs.
2. **Domain rules are pure functions, tested independently.** Never bury a business rule inside a view model body or a view.
3. **One feature = one module.**
4. **Model changes get their own commit.**
5. **If something feels complex, it's probably wrong — the model should be opinionated but not complicated.** An operation that's tortured to express means the schema is wrong, not the operation.

## Project structure

```
variorum/
├── Package.swift               # VariorumCore package (GRDB 7, swift-dependencies)
├── Sources/VariorumCore/
│   ├── Models/                 # Value models + GRDB record types
│   ├── Persistence/            # Database stack, migrations, triggers
│   ├── Domain/                 # Pure domain rule functions (invariant enforcement)
│   ├── Operations/             # The transactional operations API (AppSpec §9)
│   ├── Queries/                # Read-side traversals + ValueObservation
│   └── Sync/                   # Push/pull engine per SyncSpec (from Phase 5)
├── Tests/VariorumCoreTests/
├── App/                        # Thin Xcode app target (arrives Phase 6)
│   ├── Variorum/               # Entry point, root composition, shared views
│   └── Features/               # One folder per feature module (Editor, Library, …)
└── notes/                      # Canonical docs (+ notes/plans/, notes/source/)
```

## Commands

```bash
# Core package — the fast inner loop (no Xcode project needed)
swift build
swift test
swift test --filter <TestName>

# App (from Phase 6; requires the Xcode app target)
xcodebuild -scheme Variorum -destination 'platform=macOS' build
xcodebuild test -scheme Variorum -destination 'platform=macOS'
xcodebuild clean -scheme Variorum
```

## Environment notes

- **The repo lives at `~/dev/variorum` — outside iCloud sync, permanently** (2026-07-06 emergency move: iCloud Desktop sync choking on `.build`'s tiny files froze the whole machine). `~/Desktop/variorum` is only a convenience symlink. Never relocate the repo, or write build artifacts, into an iCloud-synced folder (Desktop/Documents).
- **Dev machine (this one): the author's M3 Mac on macOS Tahoe 26.x with Xcode 26 — development and acceptance are one machine.** The Intel Air era ended 2026-07-06 (transition executed ahead of the planned before-Phase-6 date); all Air-era constraints (dev/acceptance machine split, Air-motivated deployment target, Xcode-26-on-Intel) are permanently moot.
- **Deployment targets: macOS 26 / iOS 26** (author decision 2026-07-06: no older-OS support). Build SDK and runtime OS now match, so no availability-gating for Tahoe APIs.
- TextKit 2 behavior remains version- and point-release-gated: re-verify editor milestones after each macOS point update per the matrix in @notes/TEXTKIT2_NOTES.md §5.
- If the author's help is needed (Xcode GUI steps, signing, Supabase setup, a device test, an adjudication call), pause and ask rather than working around it.
