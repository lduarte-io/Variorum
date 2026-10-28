# VX-678 — Run: Trash, purge & resurrection

**STATUS: LIVE (opened 2026-10-28). Orchestrator: the vx-669 session (Fable, /architect-phase).**

Ticket: VX-678 (Umbrella) · Project: v1 release readiness · Branch: `vx-678-trash-purge-resurrection` · Worktree: `~/dev/variorum-vx-678` (Pro).
**The binding brief is `notes/handoffs/vx-669-trash-resurrection-kickoff.md`** — her rulings are in it and are not restated at length here: the fix direction is RULED (remove the defense leg, option B); VX-670 is Pre-launch; VX-669 does not gate launch; VX-672 is deliberately NOT a member. Members verified against VX-678's SUB-ISSUE LISTING at kickoff (her rule, 2026-10-27): VX-669 · VX-670 · VX-654 · VX-671 · VX-657 · VX-653 — exactly the six invoked, no strays.

This run HOLDS THE ONE Sync/-custody SLOT (granted by oct27coordinator 2026-10-28, in-session message). Coordinator protocol for this run: every stage window by REQUEST → READY → GO (never self-claim); any schema change declared first (a LOCAL migration takes **v1_35**; v1_34 is VX-648's, merged); ledger numbers at merge: QUESTIONS next free **#250**, MobileSoul after PL-62, renumber on the branch before merging; NO RELEASE at this close — one release after both VX-678 and VX-677 merge (closeouts serialize; VX-677 = the vx-664 session, editor seam + MCP instructions, no Sync/ by her rule). Dev store as-found: its Trash holds the 10-27 walk content — **record as-found, never purge it without her word**; any walk uses the empty Walk Wing and walk-minted content only.

**Binding principles:** the 13b constitution P-1…P-9 binds as written in `.claude/skills/architect-phase/SKILL.md` (carried there byte-verbatim; not re-copied here — a deliberate lean-record deviation, recorded: this is a fixes run on existing surfaces, and the skill file is in-repo canon). The rules that bite this run: **P-7** (red-on-old pins, find bugs before she does), **P-8** (P1–P3 bind the rebuilt layer; cost ∝ viewport), **P-2** (fire-and-DO for the new multi-select doors), **P-1** (registry scope grows only as work touches routed doors).

---

## The acceptance units (one per implementer session; evidence named per unit)

**Unit 1 — VX-669 + VX-657, the Sync/ half (FABLE — the orchestrator implements under the architect mandate, the pre-13u Act 0 precedent; a FRESH Fable reviewer cold-reviews at the ladder, same-model disputes arbitrated against the spec).**
- **VX-669, remove the defense leg** (her ruling, option B). The removal surface, traced in-session 2026-10-28:
  - `Sources/VariorumCore/Sync/Repairs.swift`: `TouchedRows.sampleCopyKills` (line ~58); the kill-evidence hook in `writeResolvedRow` (lines ~221–243); the `defendEditedSampleCopies` post-batch call (lines ~883–889).
  - `Sources/VariorumCore/Sync/SampleLibraryDedupe.swift`: `recordSampleCopyKillEvidence`, `meetingStands` + `meetingSettleWindow`, `defendEditedSampleCopies`, `killVerdictKey`/`persistKillVerdict`/`consumeKillVerdict`, `reviveSampleCopy`. KEPT: the core matrix, `retireSampleCopy` (the seeded-furniture fold's shared body), `retireSignedOutCopyIfOutranked` (its defense-referencing doc updated), the classifier whole.
  - **Migration `v1_35` (LOCAL-ONLY, not a SyncSpec §12 event — `sync_state` is local-only):** one-time `DELETE FROM sync_state WHERE key LIKE 'sample_kill_verdict:%'` — the F-R3 one-shot verdict markers are unreadable once `consumeKillVerdict` is gone; her devices carry lingering rows from the live resurrections.
  - **Pins (the fake-server two-client harness; a sync change without a convergence test is unreviewed):**
    1. HER SCENARIO, red-on-old: a SETTLED both-edited standing pair → deliberate delete of BOTH books on A → B applies → NO revival, tombstones converge, both edited texts intact on the dead rows (old code revives via arms 1+3 = red).
    2. Arm-1-only, red-on-old: settled standing pair → deliberate delete of ONE copy on A → B applies → the delete stands (old: the live twin holds the meeting open forever and the kill-time EDITED verdict revives).
    3. THE PURGE-STALENESS pin (the brief's fix-run obligation): a book family with PENDING purge intents whose rows are live again (a revival that could not void) → the janitor's `familyVerdict` reads `.stale`, intents are COMPLETED, nothing is purged. If red on old ⇒ data-loss hazard, fixed in this run.
  - **Existing pins that FLIP:** `SyncReconciliationProbeTests.p5bBothEditedMeansBothCopiesSurvive` pins the crossing race's OLD outcome (defense revives both). Post-fix the accepted outcome is: the crossing retirements both land — both copies in the Trash, visible, recoverable, every byte intact, Put back real (her accepted cost at the sitting). The pin flips to state that. `aRetirementSplitAtTheReadingBoundary…`, `aDeliberateDeleteAfterTheMeetingSettled…`, `aDeliberateDeleteWithNoSecondCopy…` stay green (stronger now); doc comments updated. `twoEditedCopiesBothSurvive` (the true-meeting pass row) is UNTOUCHED — the ruled matrix itself does not change.
- **VX-657, the purge-road quit race** (mechanism confirmed in-session: `AppServices.localPurgeTask` ticks hourly into `AppSession.sweepLocalPurge` → `LocalPurge.sweep()`; the transported janitor rides sync rounds; `applicationShouldTerminate` awaits only the editor flush + the `quitFinalize` registry — nothing registers the sweeps, so ⌘Q mid-sweep exits the process over an in-flight GRDB reader → the SIGSEGV in the page-decrypt teardown). Fix shape (the ticket's): the in-flight sweep is HELD where quit can await it — `AppSession` tracks the running sweep task and a standing `quitFinalize` registration awaits (cancel-then-await) it; the sync janitor's in-flight round gets the same guard at the quit door. Evidence: a state-transition pin that a quit-finalize run blocks on a mid-flight sweep (injected slow store/spy), plus the registry-shape pin. The crash itself is a teardown race — mechanism pin, not a crash repro.

**Unit 2 — VX-654 + VX-653 (OPUS, headless core; no stage).** Rewrite `Queries.originalsStrandedBy` (recursive lineage CTE, O(L²) pair growth → O(L) reachability bounded to the deleted block's own lineage neighborhood) and `Queries.preservedOriginals` (the `released_at` subquery re-scans the note's whole placement history per original → seek by block; `v1_34`'s `idx_cblock_dead_block` may serve a re-shaped probe). The trace of record: `notes/plans/fixes/vx-648-launch-week.md` §"VX-653 / VX-654 MEASUREMENTS" (13 s / 5.8 s at 600 rounds) and ruling A-648-3. Evidence: EXACT-ROWS pins (new query ≡ old on seam-history fixtures, divide/merge rounds with released originals, dangling edges, cross-container lineage) green on both sides, PLUS the A-648-1 evidence shape for a perf fix: a statement-plan/step-bound pin red on the pre-fix query, and the gated probe's measured bound (flat-ish in rounds, the VX647_PROBE idiom).

**Unit 3 — VX-670 + VX-671 (OPUS, app target + queries; a stage window for the walk).** Profile first (her blank-listing, slow Put back, slow Delete Now — `RecoveryView` awaits `observeTrash`'s first value; `Queries.trash`'s stranded-originals arm walks `originFamilies`; Unit 2 removes one confirmed root). Then: the listing's first paint must not wait on the expensive arm (stage the cheap rows, or move the stranded arm off the first value); Delete Now / Put back answer the UI before the family walks complete where safe (off-main, P2); multi-select (selection set, bulk Put back / Delete Now with honest counts in the confirms, the existing per-row acts untouched; fire-and-DO refusal copy at the doors; `MobileTrashModel` shares `observeTrash` so query-side gains carry — the UI is Mac-only). Evidence: before/after latency on a large Trash fixture (measured, numbers in this record), state-transition tests for the bulk acts (exact rows), and a dev-store WALK under a coordinator-granted stage claim — walk-minted content only, the as-found Trash content untouched.

Then: ONE ladder over the run's whole diff — a FRESH `fable-reviewer`, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing; cross-model flow for the Opus units (reviewer makes final calls, the implementer applies confirmed fixes), orchestrator arbitration for the Fable unit's same-model findings; findings repo-first in `notes/plans/fixes/vx-678-ladder-round1.md`; hard cap three rounds.

## Rider candidates (NOT adopted — bundled for her next sitting per the kickoff-riders rule)

Open Low/Medium tickets in the touched Areas were scanned at kickoff (board snapshot 2026-10-28). Candidates her sitting may seat: none adopted autonomously; the run's membership is her ruled bundle and already extended once at the afternoon sitting. (Scan note: VX-672 explicitly stays out at her word.)

## Environment traps (this run)

The coordinator's standing lines (2026-10-28): `-only-testing` silently drops FILE names — use @Suite TYPE names, passed as a zsh ARRAY; build BEFORE claiming a stage window; every `xcodebuild test` needs the stage, headless `swift build`/`swift test` never does; ask before any renew; the RELEASE line carries executed counts, failures, instance/sim state, `pgrep -fl "Problem Reporter"` + new DiagnosticReports `.ips`, dev-store posture, stage.log times. Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'`, discriminate by PATH; real-store instances by STORE, never quit/kill. Never a custom build configuration. zsh `pipestatus`. Push after every commit. Dev-store Castle values only from `~/.variorum/dev-castle.env`; live Castle walks and simulated input go to an Opus walker, never Fable.

## LIVE STATUS (flip per piece, same commit)

- Unit 1 (VX-669 + VX-657, Fable): **IN PROGRESS** — removal surface traced (this file); build not started.
- Unit 2 (VX-654 + VX-653, Opus): NOT STARTED — brief = this file's Unit 2 + the A-648-3 trace.
- Unit 3 (VX-670 + VX-671, Opus): NOT STARTED — brief = this file's Unit 3; runs after Unit 2 lands (shared root).
- Ladder: NOT STARTED.
- No revert is in flight.

## Ledger

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | VX-669 defense-leg removal + pins 1–2 + p5b flip | Unit 1 (Fable) | IN PROGRESS |
| 2 | v1_35 local-only verdict-marker sweep | Unit 1 (Fable) | OPEN |
| 3 | Purge-staleness pin (brief obligation; fix if red) | Unit 1 (Fable) | OPEN |
| 4 | VX-657 quit-race guard + pins | Unit 1 (Fable) | OPEN |
| 5 | VX-654 `originalsStrandedBy` rewrite + pins | Unit 2 (Opus) | OPEN |
| 6 | VX-653 `preservedOriginals` rewrite + pins | Unit 2 (Opus) | OPEN |
| 7 | VX-670 Trash responsiveness (profile → fix → measure) | Unit 3 (Opus) | OPEN |
| 8 | VX-671 multi-select | Unit 3 (Opus) | OPEN |
| 9 | Ladder (whole diff, fresh Fable reviewer) | Orchestrator | OPEN |
| 10 | Canon deltas at closeout: SyncSpec §7 dedupe bullet (defense sentence → removal + accepted residual), QUESTIONS #143(b) row updated, dated narrative to AppSpecRecord | Merge moment | OPEN |
| 11 | Handoff: her acceptance = the live Mac+phone round AFTER the phone build carries the fix; VX-633 seed swap waits on exactly that; her library cleanup steps | Closeout | OPEN |
