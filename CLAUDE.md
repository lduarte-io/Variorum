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

## Testing expectations

- New **domain invariants or business rules** must land with tests (Swift Testing).
- Operations get exact state-transition tests (rows read/written); view models get focused coverage for core flows and edge cases.
- UI-only changes may be untested early; domain logic may not.
- Tests run at the **END** of a step/phase — **never run the full suite at the start of a session.** The previous phase's recorded closeout result is the baseline.
- Editor milestones additionally re-verify on the M3/Tahoe machine per the matrix in @notes/TEXTKIT2_NOTES.md §5.

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
# Note: xcode-select must point at Xcode.app (fixed 2026-07-04; was CommandLineTools,
# whose SDK can't compile this manifest). If builds fail that way again:
#   export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

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

- **Dev machine (this one): Intel MacBook Air, macOS Sequoia 15.6 — cannot run Tahoe.** Acceptance testing happens on the author's M3 (Tahoe), which shares this repo. Ask the author to run/report anything Tahoe-specific.
- **Author decision 2026-07-06: development transitions to the M3/Tahoe Mac before Phase 6.** From then on the Air-era constraints (dev/acceptance split, Air-motivated deployment target, Xcode-26-on-Intel) are moot; the Phase 6 plan re-baselines these notes.
- Editor-phase builds must use the **macOS 26 SDK** (Xcode 26 — runs on this Intel Air; universal binary). Deployment target stays **macOS 15** so the app runs on this machine.
- If the author's help is needed (Xcode project creation, signing, a Tahoe test run, an error readout), pause and ask rather than working around it.
