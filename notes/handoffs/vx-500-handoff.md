# VX-500 — the SECOND orchestrator handoff (2026-11-01 ~19:15 MST; the server half deployed, the client half remains)

**Her checklist (bundled; nothing improvised around):**
- [ ] **The merge word** — the PR will be opened and HELD by the successor; you say when (the launch freeze). Your 1.0
      release from `main` is untouched by this branch; the deployed server body is wire-identical for every client.
- [ ] **The words** P-500-1 (the progress lines), P-500-2 (the sheet's count), P-500-3 (the belt's line) — ratify or
      reword when U2 lands them; **P-500-7** (the refused-follow-up corner — a second line, or leave it).
- [ ] **The palette follows the account** (your Pro flipped to sea glass at the catch-up — the synced `theme_palette` row,
      by design): per-device instead? a ticket at your word.
- [ ] **VX-508** stays held (tester A's join). **VX-683** next after VX-500 closes (a design memo + sitting first), then
      **VX-544** (its plan file is ready: `notes/plans/fixes/vx-544-offline-typed-unlock.md`).
- [ ] **The deploy's SyncSpec §12 maintenance line** lands at the MERGE moment (the shared-ledger rule) — the successor's.

## THE PASTE-READY KICKOFF PROMPT (for a fresh orchestrator on the Pro)

```
/architect-phase VX-500 — RESUME the sync follow-ups run from its SECOND cutover seam (the deploy done; the client half
remains). READ FIRST, IN FULL, YOURSELF: notes/handoffs/vx-500-handoff.md (this cutover's section at its top), then
notes/plans/fixes/vx-500-sync-followups.md WHOLE (FOR A LATER READER first — the state as of the cutover; then THE
REMAINING UNITS with the U2 and U4 briefs and THE LADDER; the closed material below is the working record you read once
and never again unless reopening), then the standard preflight (CLAUDE.md + canon — "The orchestrator never implements"
is the rule, with its small-adjudication-fix clause — SyncSpec WHOLE, SurfaceContracts' Doors section, the resiliency
protocol, the sizing guidance, the master plan's in-flight table, notes/TICKETS.md, QUESTIONS' tail).

STATE: branch vx-500-sync-followups, worktree ~/dev/variorum-vx-500 (the Pro); U1a + U1b DONE and verified; the SERVER
HALF DEPLOYED 2026-11-02 00:41 UTC and ACCEPTED (her Pro's ~23k-row catch-up in ~64 s) at her word (the checklist notes/plans/vx495-deploy-checklist.md); VX-544 lifted out (its own plan
file); VX-720 seated as U4. The PR is HELD at the end — the launch freeze; never merge, she says when.

THE CAST (R-500-5, hers): FABLE implements every unit (Agent general-purpose, model fable, effort xhigh, briefed by the
plan file's section — never from your context); a fresh fable-reviewer per ladder round; same-model, so you arbitrate
against the spec. You write nothing that ships beyond CLAUDE.md's small-adjudication-fix clause. ONE agent at a time.
The worktree is SHARED with your implementers: write nothing in it while one is live (drafts in your scratchpad;
pathspec adds only — never `git add -A`).

THE ORDER: U2 (§U2 BRIEF — the faces consume U1a's seam; the Mac suites need the stage: claim it yourself,
`Tools/stage claim --who <you> --reason … --minutes 240`, no coordinator unless she names one) → U4 (§U4 BRIEF — the
v1_35 two-index migration, its own commit first, the pin red-on-old, the bench re-run) → THE WHOLE-DIFF LADDER (a fresh
fable-reviewer over the branch's whole diff against main; its anchors the two server-half rounds for those files; the
U1a/U1b/U2/U4 records' self-assessments; rounds per CLAUDE.md, cap three) → the closing runs (core debug + release split
as the traps say; EVERY Mac suite that exercises a changed source; the phone build) → the PR opened and HELD → the
closeout's canon deltas drafted for the merge moment → the FOR A LATER READER section rewritten to the closed state →
the handoff notes/handoffs/vx-500-handoff.md (her checklist on top). Bundle her calls: the words P-500-1/-2/-3, the
corner P-500-7, VX-508. After VX-500 closes: VX-683 (a design memo + sitting first — her priority raise), then VX-544
(its plan file is ready) — each its own ticket run, branch and PR.
```

## STATE AT THIS CUTOVER (verify, never trust — `git -C ~/dev/variorum-vx-500 log --oneline -30`)

- The plan `notes/plans/fixes/vx-500-sync-followups.md` is restructured: FOR A LATER READER (the settled state) · THE
  REMAINING WORK (the U2 and U4 briefs, the U3 pointer, the ladder/closing/PR plan) · LIVE STATUS · HELD FOR HER · then the
  run's record in the order written. Read it WHOLE (a cutover inside an open effort).
- DONE and verified: U1a (`6155ba7fb`…`9a2b3dfc7`), U1b (`bf33a5d10`…`5d8737765`), the server-half fixes (`f87ad1d53`…
  `a8038ad91`), the two server-half rounds (`vx-500-server-half-round1.md`, `-round2.md`), the deploy fix (`fe718be4d`…
  `e01bb7359`; piece 1 inside the orchestrator's `168d8cd4f` by a shared-worktree sweep — recorded), the DEPLOY (run 2,
  `[]`, 2026-11-02 00:41 UTC; `notes/plans/vx495-deploy-checklist.md` RUN) and her acceptance (~64 s). Tree clean, pushed.
- NOT started: U2, U4, the whole-diff ladder, the closing runs, the PR, the closeout. VX-544 lifted out (Todo in Linear).
- Linear: VX-500 In Progress; members 495/496/497/505/539/546/490/720/721 In Progress; VX-504 Todo (the memo); VX-508 Todo
  (held); VX-544 Todo (its own run); VX-722/723 Backlog (Suspected flakes). Never set an assignee (one slipped in via the
  GitHub linking on VX-721 and was cleared).
- The stage is FREE (released for her release session); the successor claims it for U2's Mac suites.

## MACHINERY LESSONS (this session's)

- **Two writers, one worktree:** the orchestrator's `git add -A` swept a live implementer's uncommitted piece into a
  record commit. While any agent is live in the worktree the orchestrator writes nothing there (drafts in the scratchpad;
  pathspec adds only). Memory `subagent-infra-lessons` carries it.
- **Verify a premise before a ruling rides on it:** the "platform drift" read of the 42501 was wrong; 14c's letter is the
  bracket. The implementer's falsification was the correct outcome of the shape — say so in the record, re-ask her.
- `log show` for the real app's process returned nothing from this session (three predicates) — the download/save split
  of a live round needs her hands or an in-app timing line.
- `Tools/prod-read.sh` refuses the words CREATE/`createrole` in a probe; a privilege probe runs as a plain select through
  the management endpoint instead.
- The management API's `database/query` endpoint runs as `postgres` (non-superuser, a member of `variorum_definer`); a
  rollback-only dry run (`commit;` → `rollback;`) is a safe way to bisect an artifact's live refusal.

---

# VX-500 — the orchestrator handoff at the cutover (2026-11-01, ~14:00 MDT; written at her word)

**Why a handoff now (her words, verbatim):** "it might be best for you to just finish you work, wrap it up to the
point where it has been committed, and then give me a fresh kickoff prompt to give to a new orchestrator. They can
ensure that your work is reviewed by the same cold-review ladder as always, they can pick it up from a fresh seam,
and most importantly you're already at 579k in your context window from having worked on the code - way too high to
be orchestrating several more batches of work." The first orchestrator breached the shape (it wrote U1's code
itself — the plan file's PROTOCOL BREACH section); everything it wrote is committed and recorded, nothing is in
flight, no revert is in flight, the tree is clean.

## THE PASTE-READY KICKOFF PROMPT (for her, for a fresh orchestrator session on the Pro — rewritten after the probes and her rulings, 2026-11-01)

```
/architect-phase VX-500 — RESUME the sync follow-ups run from its cutover seam. The run is kicked off and part-built:
branch vx-500-sync-followups, worktree ~/dev/variorum-vx-500 (the Pro), the in-flight row on main, VX-500 and its
members In Progress. READ FIRST, IN FULL, YOURSELF: notes/handoffs/vx-500-handoff.md, then
notes/plans/fixes/vx-500-sync-followups.md WHOLE (the roster, THE DESIGN D-495…D-504 with D-495 EVIDENCE — the
probes — and the two memos, THE DEPLOY, PROTOCOL BREACH, HER RULINGS R-500-1…4, LIVE STATUS), then the standard
preflight (CLAUDE.md + canon — its cast rule was reworded today — SyncSpec WHOLE, CastleRules WHOLE for U3,
SurfaceContracts' Doors section, the resiliency protocol, the sizing guidance).

WHAT IS DONE: the plan; the first orchestrator's DRAFT of U1 in commit aad734aef (the server artifact, the engine's
progress seam, the scheduler's progress + lastErrorIsRetrying, the fake's count, SyncProgressTests, one belt pin, the
DDL-test changes) — UNTRUSTED INPUT, written in breach of the shape, never reviewed; and my EXPLAIN ANALYZE probes on
production (D-495 EVIDENCE): old 3,398 ms · the draft 1,138 ms · SHAPE B 230 ms · the count 1,586 ms.

THE CAST: you write nothing that ships — no file under Sources/, App/, Tests/ or Server/, no fix at adjudication;
probes and scratch instruments are yours (CLAUDE.md's cast rule, refined 2026-11-01). ASK ME at your kickoff whether U1
(the Sync/ batch) is implemented by a Fable subagent or by Opus — my call, per CLAUDE.md's new cast line; Opus
implements U2 and U3; a fresh fable-reviewer runs the ladder over the whole diff (Fable always reviews the Sync/ and
editor-seam class). Three units are fine.

U1'S BRIEF, in short (the plan carries it): the implementer ADOPTS aad734aef as a draft — re-reads every line against
D-495/D-496/D-505 and re-derives the pins' red-on-old honestly — then (1) REWRITES the artifact's fetch to SHAPE B (the
bound-based index range scan; the plan's D-495 EVIDENCE says exactly how; the drafted `in (select …)` form and its
DDL pin go, a bound pin replaces them); (2) builds the count per R-500-1 — the INDEX-ONLY count without the horizon
filter; (3) fixes the DDL-test WIP named in the handoff (the body finder's prefix match, the doctored-chain arm, the
marker-guard pin); (4) the apply PROFILE (D-497 (1)) and the FK memo only if the profile names it. Then U2 (D-496's
words, D-505's line, D-539/VX-546's injected clock, VX-490), then U3 (D-544). Then the ladder, the closing runs, and
the PR OPENED AND HELD — we are in the launch code freeze; never merge, I say when. The server deploy
(maintenance/vx495-pull-keyset.sql) is HELD for my explicit word; VX-508 stays HELD (tester A's join). Pre-launch:
neither VX-544 nor VX-683 (R-500-2). I'm present for the sittings; bundle my calls.
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
