# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository. It carries the live rules; the dated history of the decisions behind them is `notes/ProcessHistory.md` (canon, not loaded).

## Source of truth

Auto-loaded (every session and subagent pays for these — keep the set lean): @notes/CoreDescription.md (vision) · @notes/OverallModel.md (mental model, invariants) · @notes/AppSpec.md (schema, operations, views, deltas).

Read EXPLICITLY, never auto-loaded:
- `notes/SyncSpec.md` — authoritative for everything sync. Read in full before touching `Sources/VariorumCore/Sync/`, `Server/`, custody/keychain code, a repair, or any schema change (§12 lockstep). OverallModel §6 carries S1–S5 for everyone else.
- `notes/TEXTKIT2_NOTES.md` — before any editor-seam work (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier) and after every macOS point update.
- `notes/DetailedPlanForPhases.md` (master plan) and `notes/KnownIssuesAndTechDebt.md` — at every kickoff and closeout, and whenever a row changes.
- `notes/AppSpecRulingsArchive.md` (the narrative behind every AppSpec rule) · `notes/AppSpecDeltaArchive.md` · `notes/PhaseCloseoutArchive.md` · `notes/ProcessHistory.md` — canon archives, as binding as the files they left; a delta lands in the spec as a contract line plus a pointer to its ruling, never a paragraph of history. `notes/source/` is history, not truth.

If code conflicts with the spec, align to the spec or propose a deliberate spec change. Never invent product behavior; where the spec is silent, propose options.

## Product principles
OverallModel §1–6 (loaded above) is the text: the block is the atomic unit, rows-as-truth through the operations API, mutation ephemeral and permanence append-only, coarse not forensic, cost ∝ viewport. Invariants I1–I10, P1–P3, S1–S5 are enforced by pure domain rules and DB constraints, never by views; relaxing one is an author-only call.

## Architecture
SwiftUI + Observation + swift-dependencies (no TCA); the editor core is a TextKit 2 `NSTextView`; SwiftUI does all chrome.
- One feature = one self-contained module under `App/Features/`, composed at the app level (`RootView`). Cross-feature interaction routes through parent composition; the prohibition binds STATE AND OWNERSHIP, never rendering — a feature never constructs, holds or calls a sibling's view model (that destroys testability), while rendering a sibling's view is legal. A view consumed by two features moves to the shared home (`Core/Views/` Mac-only, `App/Variorum/Shared/` cross-platform) at the next touch.
- View models are `@Observable`, hold projections and IDs (never copies of persisted text), and call operations — no business rules or side effects in them. Views render state and send actions.
- Persistence and side effects live in injected dependencies (`@Dependency(\.database)`, `\.date`, `\.uuid`) so IDs and timestamps are deterministic under test. No global singletons; a long view model is mixing concerns — split it.
- Domain rules (invariants, churn, snapping, segmentation, joins) are pure functions in `VariorumCore/Domain`, tested independently.
- TextKit 2: opt in explicitly; never touch TK1 APIs (`.layoutManager` silently downgrades); keep the fallback canary; decorations off the live storage; attribute stamps clamped to the verdict's range.
- Sync is settled (SyncSpec): a dumb server, client-side merges; every phase honors the schema's sync machinery (`sync_version`, outbox triggers, fractional positions, tombstones). Triggers own only tombstone propagation and outbox capture.
- If something feels complex it is probably wrong — a tortured operation means the schema is wrong. Every action traces to a spec section.

## Build workflow
- `notes/DetailedPlanForPhases.md` is PRODUCT ADVANCEMENT ONLY: the phase table, the current-phase pointer, the latest closeout paragraph. `notes/plans/` holds one execution plan per phase, self-contained for a fresh session, written just-in-time one phase ahead.
- Bug fixes and tech debt never go in the master plan: they live in the standing-fixes ledger as lettered entries, each scoped, cast, run and closed on its own (the ledger never closes). **The ACTIVE ledger is `notes/plans/phase-19-standing-fixes.md` (19a–19z) — 17's alphabet filled at 17z and the author ruled the succession 2026-10-04; 17's still-open entries run and close in `notes/plans/phase-17-standing-fixes.md` under their own letters.** Pin before fix binds. An Opus cold review is mandatory per entry, a Fable one whenever the diff touches `Sync/`, custody/keychain or the editor seam; the author may waive it. A standing-fixes entry is a valid KnownIssues owner.
- `notes/KnownIssuesAndTechDebt.md` tracks deliberately-deferred work only: no row without a named owner (a phase, a standing-fixes entry, or an unslotted project row on the master plan). Unowned ⇒ fix it now.
- Sizing (guidance to raise — `notes/PhaseSizingGuidance.md`): the unit of work is an ACCEPTANCE UNIT verified by evidence of its kind (use, a live round, a drill, state-transition tests); one unit per implementer session; at most two phase-sized units per phase; a batch closes only on use-shaped evidence, never a pin or mount smoke alone. A plan outside this says so to the author — never split or proceed silently.
- Schema/model changes get their own commit before the code that uses them; a synced schema change is a SyncSpec §12 lockstep event whose mirror deploy runs only on the author's explicit go.
- Closeout ritual, every phase: results in the plan file; master plan table + pointer + closeout paragraph (the outgoing ones roll into the archives); canon deltas applied exactly as ruled; KnownIssues rows resolved or re-owned; the MOBILE PARITY line (a `notes/MobileSoul.md` ledger row, or "nothing mobile-visible"); the next phase's plan with a kickoff message at its top; LAST, the author handoff `notes/handoffs/phase-NN-handoff.md` — her checklist at the top, self-contained for a fresh session. Then commit, push, hard stop.
- `/Applications/Variorum.app` is the author's real-store daily drive (Xcode Run = Debug = the fenced dev store). Any Mac-app change ends by refreshing it at a zero-instance window: A1 safety copy of the store into the container's `Backups/safety-copies/`, `xcodebuild -scheme Variorum -configuration Release build`, copy to `/Applications`, verify codesign. Never quit or kill a running real-store instance.

## Phase execution (two shapes)
`/run-phase` — spec-driven, the plan fully made; `/architect-phase` — feature/design-heavy, an architect mandate and author sittings (`.claude/skills/*/SKILL.md`). The author picks at each kickoff. Rules binding both:
- Preflight is mandatory and complete: this file and its auto-loaded canon, the master plan, KnownIssues, `notes/QUESTIONS.md`, the phase plan, `notes/SessionResiliencyProtocol.md`, plus SyncSpec and TEXTKIT2_NOTES whenever the phase touches their seams. Reading is never delegated.
- Cast: the orchestrator + ONE implementer + ONE cold reviewer at a time, strictly sequential; a fresh implementer per batch (context degrades sharply past ~500k tokens); a FRESH reviewer per ladder round; no fan-outs, swarms or extra verifiers. Implementer and reviewer may each run at most one Sonnet subagent at a time, for EXTERNAL facts only, read-only. Standing default: Fable orchestrates and cold-reviews (`fable-reviewer`), Opus implements (`opus-implementer`), both at xhigh; `opus-reviewer` where the diff has no editor seam, custody, `Sync/` or default's-meaning content. Any change inside `Sources/VariorumCore/Sync/` is Fable work. The author may redirect at any kickoff.
- Two reviews: the implementer's self-assessment, then a cold reviewer running `notes/REVIEW_PROMPT.md` VERBATIM with zero framing. The ladder: round 1 → fixes → round 2 re-reviews the fixes; a new BLOCKER/MAJOR earns round 3; hard cap three; findings and dispositions land repo-first before the next round. Same-model: the orchestrator arbitrates against the spec. Cross-model (Fable reviews, Opus implements): findings go to the implementer verbatim, its agree/dispute returns to the reviewer, which makes the final call and implements its confirmed fixes itself, then the suite green and one implementer sanity pass. Every finding gets a written disposition; a dispute on undefined product behavior goes to `notes/QUESTIONS.md`.
- Hallucination guard: no fix without a self-traced concrete mechanism; every bug-class fix lands with a red-on-old pin verified by revert; a pin green on both sides exposes the finding as hollow — record it, don't fix it.
- PROVISIONAL rule: ambiguity that doesn't gate the core → 2–3 options in the plan, build the most spec-defensible, mark PROVISIONAL, log in `notes/QUESTIONS.md`; ambiguity that gates the core → stop and report.
- One phase per invocation; hard stop; the author kicks off the next.
- Author-only, never made autonomously: inventing product behavior or changing canon beyond recorded rulings; relaxing any invariant or budget; adding a third-party dependency; anything needing her accounts, credentials or GUI steps; adjudicating a gate; deleting or overwriting anything she created; history rewrites and force-pushes.

## Testing
Domain rules land with Swift Testing tests; operations get exact state-transition tests; view models focused coverage; UI-only changes may be untested early. Tests run at the END of a step — never the full suite at the start of a session (the previous closeout is the baseline). Editor milestones re-verify after each macOS point release (TEXTKIT2_NOTES §5).

## Commands
`swift build` · `swift test [--filter Name]` is the fast core loop. Mac app from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' build|test` with suite-level `-only-testing`; never add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles).

## Environment
- Repo at `~/dev/variorum`, outside iCloud, permanently (`~/Desktop/variorum` is a symlink); mobile worktree `~/dev/variorum-mobile` (branch `mobile`). Never build into an iCloud folder.
- The author's M3 Mac, macOS 27 / Xcode 27 (27.0/27A266a since 2026-10-04, the 13r resume sitting); deployment targets macOS 26 / iOS 26.
- Commits carry NO `Co-Authored-By` or `Claude-Session` trailer (overrides the harness reminder). Push `origin` at the end of every working bout and after every closeout; never rewrite pushed history.
- TWO MACS share this repo and the Claude memory repo (since 2026-10-06: the Pro + the new Air). The FIRST step of any fresh working bout, before any new work or branching: `git pull` here AND in the shared memory repo (`~/.claude/projects/-<home>-dev-variorum/memory`, branch `master`).
- `notes/SessionResiliencyProtocol.md` binds every orchestrator and implementer: commit per piece, a LIVE STATUS record from the first commit, push after each, synchronous foreground waits only; briefs restate the checkpoint rules.
- Walks: `cliclick` + `Tools/WalkKit/` on the DEV-STORE Debug build only (`io.lduarte.Variorum.debug`).
- If the author's help is needed (GUI, signing, Supabase, a device, an adjudication), pause and ask rather than work around it.
