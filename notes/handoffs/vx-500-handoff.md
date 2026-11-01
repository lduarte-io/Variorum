# VX-500 — the orchestrator handoff at the cutover (2026-11-01, ~14:00 MDT; written at her word)

**Why a handoff now (her words, verbatim):** "it might be best for you to just finish you work, wrap it up to the
point where it has been committed, and then give me a fresh kickoff prompt to give to a new orchestrator. They can
ensure that your work is reviewed by the same cold-review ladder as always, they can pick it up from a fresh seam,
and most importantly you're already at 579k in your context window from having worked on the code - way too high to
be orchestrating several more batches of work." The first orchestrator breached the shape (it wrote U1's code
itself — the plan file's PROTOCOL BREACH section); everything it wrote is committed and recorded, nothing is in
flight, no revert is in flight, the tree is clean.

## THE PASTE-READY KICKOFF PROMPT (for her, for a fresh orchestrator session on the Pro)

```
/architect-phase VX-500 — RESUME the sync follow-ups run from its cutover seam. The run is kicked off: branch
vx-500-sync-followups, worktree ~/dev/variorum-vx-500 (the Pro), the in-flight row on main, VX-500 and its members In
Progress. READ FIRST, IN FULL, YOURSELF: notes/handoffs/vx-500-handoff.md (this file), then
notes/plans/fixes/vx-500-sync-followups.md WHOLE (the roster, THE DESIGN D-495…D-504, the two memos, THE DEPLOY,
PROTOCOL BREACH, LIVE STATUS), then the standard preflight (CLAUDE.md + canon, SyncSpec WHOLE, CastleRules WHOLE —
U3 is custody-adjacent — SurfaceContracts' Doors section, the resiliency protocol, the sizing guidance). THE CAST,
my rulings: the orchestrator writes NO product or test code (memory `orchestrator-never-writes-code`); a FABLE
SUBAGENT implements every batch that touches Sources/VariorumCore/Sync/ (U1) — spawn an implementer with the model
left as Fable and brief it exactly as an opus-implementer; Opus implements U2 (faces + the test fixes) and U3 (the
typed-unlock retry); a fresh fable-reviewer runs the ladder over the whole diff (Fable always reviews the Sync/ and
editor-seam class). Three units are fine. The first orchestrator's commit aad734aef is UNTRUSTED INPUT — the U1
Fable implementer ADOPTS it (re-reads every line against D-495/D-496/D-505, re-derives the pins' red-on-old, fixes
the DDL WIP named in the handoff) unless I say revert. Order: U1 → U2 → U3 → the ladder → the closing runs → the
PR OPENED AND HELD (we are in the launch code freeze — never merge; I say when). The server deploy
(maintenance/vx495-pull-keyset.sql) is HELD for my explicit word; VX-508 stays HELD (tester A's join). THE PROBES ARE DONE (my
`!` road, 2026-11-01 — D-495 EVIDENCE in the plan): old 3,398 ms · the draft 1,138 ms · SHAPE B 230 ms · the count
1,586 ms. SHAPE B (the bound-based range fetch) is D-495's design now — the U1 implementer rewrites the artifact's
fetch to it and builds the count per P-500-6. I'm present for the sittings; bundle my calls.
```

## STATE AT CUTOVER (verify, never trust — `git -C ~/dev/variorum-vx-500 log --oneline -6`)

| Commit | What | Standing |
|---|---|---|
| `11f7ee613` | the plan file — roster, designs, memos, held deploy, LIVE STATUS | a record |
| `aad734aef` | U1's code, WRITTEN BY THE FIRST ORCHESTRATOR: `maintenance/vx495-pull-keyset.sql` (the keyset `sync_pull` + `sync_pull_remaining`), the sweep row, `Sync/SyncEngine.swift` (`SyncProgress`, `pull(progress:)`, `countRemaining`, the save's stride publishes), `Sync/SyncScheduler.swift` (`Status.progress`, `Status.lastErrorIsRetrying`, the generation guard, `advances`), `Sync/PullStage.swift` (`stagedRowCount`), `Sync/SyncTransport.swift` (`SyncPullCountTransport`), `Sync/SupabaseTransport.swift` (the conformance + `PullRemainingRequest`), the fake server's count on both conformers, `Tests/VariorumCoreTests/SyncProgressTests.swift` (6 pins), one pin in `ResumableCatchUpTests` (the belt flag), `AuthRLSDDLTests` (the post-chain overlay for `finalBody`, the after-map as arrays, two new pins) | UNTRUSTED — adopt or revert at her word |
| `0a333758a` | the PROTOCOL BREACH record | a record |
| (this file's commit) | the handoff + the plan's STATUS banner | a record |

**What was observed, not claimed as evidence:** `swift build` green; `swift test --filter "ResumableCatchUpTests|SyncSchedulerTests|Scheduler"` 28/3 green BEFORE the new pins; `swift test --filter "SyncProgressTests|ResumableCatchUpTests"` 25/2 green (the six progress pins + the belt pin); `swift test --filter AuthRLSDDLTests` RED with 19 issues — ONE cause: `finalBody(of: "sync_pull")`/`lastBody` match `"create or replace function sync_pull"` as a PREFIX, so with the artifact laid over they return `sync_pull_remaining`'s body; the fix is to match `"create or replace function \(name)("` (the opening paren) in both finders — then re-run and re-read every remaining issue honestly. Two more known: the new pin's `!artifact.contains("lockstep_version'")` is wrong (the artifact's GUARD reads the marker; assert no marker WRITE instead), and `aDoctoredChainIsFlaggedByTheSearchPathCheck`'s "unbelted" arm expects every checked signature flagged when the belt is dropped — `sync_pull` and `sync_pull_remaining` now get `pg_temp` from the VX-495 artifact itself, so that arm must drop the post-belt artifact too or exempt the two. No red-on-old was derived for the pins (an Improvement's pins; the belt flag's pin is new-API red by compile) — the adopting implementer records that honestly.

**The probes — DONE after this handoff was first written** (her `!` road ran `EXPLAIN (ANALYZE, BUFFERS)` of four
shapes against her tenant; the files are the session scratchpad's `vx495-probe/` — old-shape, new-shape, new-shape-b,
count-shape — and the results and the SHAPE B design are the plan's D-495 EVIDENCE). **Not started:** the apply PROFILE (D-497 (1)); U2 whole
(D-496's words, D-505's line, D-539/VX-546's clock, VX-490); U3 whole (D-544); the ladder; the closing runs; the PR.

**Her calls so far (this session, verbatim-faithful):** three units are fine · the PR is held (freeze) · VX-508 held
· the Fable-subagent cast for `Sync/` (memory) · the breach recorded.

**Linear:** VX-500 In Progress; members VX-495/496/497/505/544/539 In Progress; riders VX-546 + VX-490 seated under
VX-500 (provisional — one line to unseat); VX-496 related to VX-76 (proposed duplicate at the merge); VX-504 and
VX-508 untouched (Todo).

**Flagged to her, outside this run (the priority raise she asked for):** VX-683 (data-loss class — a pull applied
into her autosave's debounce window on the same take is overwritten; the Mac+phone same-note shape; a `Sync/` design
memo run) · VX-672 (the phone's minutes-long post-purge round; profile after VM-32). Her question answered: VM-32
does not wait on this run (VX-678 merged 2026-10-28; no shared code).

## MACHINERY LESSONS (this session's)

- **The orchestrator never writes code** — the breach above; the memory rule carries her words.
- The `prod-read.sh` fence refuses `WITH` and `EXPLAIN`; a cost probe is bare `SELECT`s only.
- `AuthRLSDDLTests` reads only `04 + lockstepFiles` for the final bodies; a maintenance artifact that defines a
  function must be laid over explicitly (the post-chain list) AND joined to `searchPathDeployOrder` after the belt.
