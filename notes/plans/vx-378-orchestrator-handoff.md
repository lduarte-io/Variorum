# VX-378 — orchestrator handoff (written 2026-10-18 ~07:30Z at ~740k tokens, BEFORE compaction; the two-document form)

**Who reads this:** the VX-378 orchestrator itself after compaction, or a fresh Fable session seated by the kickoff prompt
at the end. **The repo is the only memory that survives.** Everything below is verifiable from the repo and the
scratchpad; trust nothing from a transcript.

---

## 1. The role, as amended during the phase

- `/architect-phase vx-378` (the architect shape): Fable orchestrates and cold-reviews; Opus implements — **but the Opus
  pool died twice on her session limit** (2026-10-17; "resets 12:40pm Denver" = the next day), so since ~21:00Z on
  10-17 the orchestrator has done the remaining implementation itself under the resiliency protocol's BUDGET-DEATH road
  (`notes/SessionResiliencyProtocol.md`, the model-budget addendum). Every change traced, pinned red-first, and read by a
  fresh `fable-reviewer` round. Keep orchestrator text product-framed (the Fable classifier tripped on custody/attacker
  narration in VX-305 — `fable-safeguards` memory).
- **Her kickoff rulings (plan §8 KICKOFF SITTING):** cast rider — if a Fable round stalls on a safeguard, rerun it as
  `opus-reviewer` at max (never needed); ladder cap up to FIVE while a MAJOR is found (none was); THROUGH TO THE GATE.
- **Her overnight mandate (10-17, verbatim):** *"from here on out, please do not stop for questions and instead rule
  provisionally and I will assess everything in the morning."* ⇒ no `AskUserQuestion`; every call PROVISIONAL with
  options + WHY in QUESTIONS and the handoff. **The PR is OPENED, never merged by this session** — her word: *"I'll have
  my kickoff of VX-306 start with merging the PR if I approve it."* Her kickoff of VX-306 = acceptance of the GO and the
  bundle (she asked; I said yes; it's written into the handoff's checklist and the VX-306 plan's STEP 0).
- She is awake and around today (she asked for status at ~05:30Z and ~07:00Z); she may ask questions — answer plainly,
  point-by-point. She asked that the Sync/-custody slot hold be written into the stage: DONE (a NOTE line in
  `~/.variorum/stage.log`, 2026-10-17 16:51 MDT) — the stage itself is never claimed (headless phase).

## 2. Where everything is

- **Worktree** `~/dev/variorum-vx-305`, branch `vx-305-castle-core` (one branch for VX-305 + VX-378; one PR closes
  VX-378, VX-305, VX-345). `main` is never touched except the in-flight row (done at kickoff, `aecb509d0`).
- **The plan (the ONE record):** `notes/plans/vx-378-castle-simplified.md` — §7 LIVE STATUS, §8 the unit records + the
  orchestrator's notes after U1/U2/U3 + HER RULINGS AT THE U4 STOP + the U4 RESUMPTION RECORD, §9 the ladder (rounds
  1–4 with dispositions), §10 the gate (items 2–6 DONE; item 1 = the soak attempts; the RULES CHECKLIST is in; the
  VERDICT line reads `GATE_VERDICT_PENDING`; the attempt-3 soak paragraph ends `GATE_SOAK3_PENDING`).
- **The contract:** `notes/CastleRules.md` (27 rules; amended at her word only: 11–12 both secrets; 12, 25 (FD-2/3);
  4, 5, 12 the floor; 17 back to no carry; 21 fingerprint + wrapped copy, the notice, the offer; its status line lists
  them). **The walk:** `notes/plans/vx-266/castle-lifecycle.html`, rendered from the fixture under
  `Tests/VariorumCoreTests/Protection/Scenario/Lifecycle/` (guard `LifecyclePageTests.theCommittedPageIsTheRenderedOne`).
- **Ladder reports (committed unedited):** `notes/plans/vx-378-ladder-round-{1,2,3,4}.md`.
- **The review worktree (scratch, read-only, its own `.build`):** `<scratchpad>/review-wt` at `66f7561e1` — used for
  reviewers and for red-on-old checks; REMOVE at closeout (`git worktree remove --force <path>; git worktree prune`).
- **Scratchpad** `/private/tmp/claude-501/-<home>-dev-variorum/3a7b80a3-9433-4e7c-814a-2348d303a301/scratchpad/`:
  `soak3.sh` (the gate script: discovery 21–40 Debug → soak 1–20 Debug → soak 1–20 release; one seed per call; writes
  `<log>` lines `cfg seed=N steps=S steps :: <exit line>` and `<log>.fail-<cfg>-<seed>` on a red; markers `DISCOVERY
  DONE fail=…`, `GATE DEBUG DONE`, `GATE RELEASE DONE`, `END`); `gate-runs-5.log` = ATTEMPT 3 (the live one; earlier
  attempts in `gate-runs-3.log`, `gate-runs-4.log`); `rules-checklist-draft.md` (landed in §10 already);
  `vx-378-handoff-draft.md` (the AUTHOR handoff draft with PENDING slots); `canon-deltas-draft.md` (the exact canon
  lines to apply at closeout); `vx-306-castle-open-road.md` (landed in `notes/plans/` already).
- **Memory:** `~/.claude/projects/-<home>-dev-variorum/memory/vx-378-run-state.md` (pull/push the memory
  repo, branch `master`).
- **Tickets:** VX-378 (this), VX-305 (closes with it), VX-345 (closes with it), VX-380 (Parked — the release-only Sync
  attacker test, VX-345's class), **VX-386** (the deferred ladder residue → VX-306's FIRST commit), VX-379 (wording,
  standing item), VX-306/307/308/309 re-scoped by the VX-305 session's Linear pass (a ticket's newest comment wins).

## 3. State at cutover — VERIFY, never trust

- **Final CODE tree `66f7561e1`** (`git diff 66f7561e1..HEAD -- Sources Tests` must be EMPTY; every later commit is
  notes). HEAD at writing: `5db704945`/`d2f2498c6` + this file.
- **Gate attempt 3** running on it (started 04:00Z 10-18): discovery 21–40 GREEN (table in §10); Debug soak green
  through seed 13 at 07:30Z; release soak follows. Expect `GATE DEBUG DONE` ≈ 08:00Z, `GATE RELEASE DONE`/`END` ≈
  09:30Z. A Monitor is armed on the log (re-arm every 30 min: `tail -n 0 -f <log> | grep -E --line-buffered
  "DONE|STOP|END|✘"`). `pgrep -f soak3.sh` = 1 while it runs.
- **Suite checks on `66f7561e1` DONE and recorded (§10 item 2):** protection set Debug 388/149; release minus VX-380;
  full core Debug 240/51 · 3160/405 · 40/6.
- **Ladder CLOSED** (4 rounds; §9); three test/DEBUG-only residues deferred as VX-386.
- **Three gate finds so far, all fixed + pinned (`U4GatePins`, 3 tests):** attempt 1 seeds 2 (rule 20 — a pre-commit
  resume with the wrong secrets rolls back; P-VX378-O2-1) and 3 (rule 11 — Castle entry's sweep reads the catalogue via
  the new leaf `KeyFileStoreLeaf.catalogedKeyFiles(ofLibrary:)`; P-VX378-O2-2); attempt 2 seed 8 (CHECKER — promise 1
  gains rule 10's lagging-device exemption).

## 4. If attempt 3 goes RED — the triage road (proven three times tonight)

1. Read `<scratchpad>/gate-runs-5.log.fail-<cfg>-<seed>`: it names `seed N sequence M (world seed W, start <state
   name>)`, the failing promise + detail, and the MINIMAL sequence (a Swift array of `Action`s).
2. **Stop the soak** (`pkill -f soak3.sh; pkill -f GeneratorTests`) — a fix changes the tree and gate item 1 wants BOTH
   runs on the FINAL tree; append a `SOAK STOPPED by the orchestrator <UTC>: <why>` line to the log.
3. **Replay in the review worktree** (never build in the main worktree while a soak runs there): write
   `Tests/VariorumCoreTests/Protection/Scenario/ZZTraceN.swift`:
   ```swift
   import Testing
   @testable import VariorumCore
   @Suite("ZZ trace") struct ZZTraceN {
       @Test func trace() async throws {
           let world = SWorld(seed: N &* 1_000_003 &+ M)          // the generator's own formula (Generator.swift:311)
           let idx = StartingState.all.firstIndex { $0.name.contains("<part of the start name>") }!
           try await StartingState.all[idx].build(world)
           func dump(_ label: String) { for d in [world.macA, world.macB] { let lib = d.library; let rec = d.slot?.record
               let file = (try? DeviceLeaves(world: world, device: d).readLiveKeyFile()) ?? nil
               print("### \(label) [\(d.name)]: open=\(d.isOpen) recMode=\(String(describing: rec?.mode)) account=\(rec?.account?.prefix(8) ?? "-") rowKey=\(rec?.accountRowKeyID?.prefix(8) ?? "-") inFlight=\(String(describing: lib?.section.actInFlight?.act)) slotFP=\(d.slot?.fingerprint.prefix(8) ?? "-") liveKF=\(file?.fingerprint.prefix(8) ?? "-") hist=\(file?.history.map { $0.fingerprint.prefix(8) } ?? []) kfApple=\(file?.apple?.keyID.prefix(8) ?? "-") planOnDisk=\(d.container.files[SPath.plan] != nil) staged=\(d.staged != nil) paused=\(d.paused) keychain=\(d.keychain.local.keys.map { "\($0.service.split(separator: ".").last ?? "")/\($0.account.suffix(12))" }.sorted()) session=\(String(describing: d.session))") } }
           dump("start")
           for s in [Action.<the minimal sequence verbatim>] {
               let r = await world.apply(s); dump("after \(s) -> \(r)")
               print(world.stepLog.suffix(10).joined(separator: "\n"))
               print("violations: \(world.checkPromises(settled: false).map { "\($0.promise)/\($0.device): \($0.detail)" })")
           }
       }
   }
   ```
   `swift test --filter ZZTraceN 2>&1 | grep -aE "^###|^violations|^▸|^  |error:|Test run"`. Delete the file after.
   Promise checkers: `Tests/.../Scenario/Promises.swift` (`onePosture` = P1 at :357, `crashSafe` = P6 at :758; the
   STATED LIMITS header L1–L6). Acts: `Sources/VariorumCore/Protection/Executor/Acts/*.swift`; the resume/rollback:
   `Executor/PlanRunner.swift` (`settleAct` :281, `resume` :369, `reachNewKey`, `rollBack` :480+); the Castle sweep:
   `Acts/CommonSteps.swift` `retireOldCustody` / `retireOwnAppleKeys`; unlock: `Executor/Executor.swift:231`.
4. **Classify:** MODEL (the app does the wrong thing — fix in Sources, rule-traced, PROVISIONAL options in QUESTIONS if a
   reading is involved) · CHECKER (the promise over-claims against a rule's stated boundary — fix in Promises.swift,
   quote the rule) · WORLD (the fake is wrong) · a RULE that cannot hold ⇒ STOP, record in §10 with the trace, bring to her
   (the only thing that waits for her under the mandate).
5. **Pin:** add a replay test to `Tests/.../Scenario/U4GatePins.swift` (pattern there: `SWorld(seed:)`,
   `StartingState.all[...]`, `world.step(action)`, `expectPromisesKept(world)`); prove RED on the pre-fix tree by copying
   the pin file into the review worktree at the old commit and running `swift test --filter U4GatePins/<name>`; green
   after. Run the protection set (`swift test --filter 'Lifecycle|Protection|Scenario|Executor|Assess|Catalog|Retention|
   RouteFinder|KeyFile|Names|Seal|Cut|U2|U4'`) in Debug and `-c release` (the ONE release red
   `MultiTenantSyncAttackerTests` is VX-380, not Protection's).
6. **Commit** per fix (message: the trace, the rule, the pin and its red issue count; `Part of VX-378`; NO trailers),
   push; record in §10 (`ATTEMPT k … NO-GO at seed N` + the trace + `FINAL TREE <hash>`), QUESTIONS if PROVISIONAL.
7. **Fresh `fable-reviewer` round** over the fix (read-only in the review worktree checked out at the new tree; findings
   file `notes/plans/vx-378-ladder-round-5.md`; commit it UNEDITED; disposition in §9). Her cap of five rounds counts
   rounds that find MAJORs; rounds 3–4 were fix re-reads. If a sixth read is needed, say so in §9 as the orchestrator's
   call and do it (a fix no one read is worse than a sixth round).
8. **Re-run the WHOLE gate** on the new final tree: `nohup zsh <scratchpad>/soak3.sh <scratchpad>/gate-runs-6.log >
   <scratchpad>/soak6.nohup 2>&1 &` from the main worktree (clean tree, pushed); re-arm the Monitor. Also re-run the
   suite checks on the new tree (protection set both configs in the main worktree; full core Debug in the review
   worktree) and update §10 item 2.

## 5. If attempt 3 goes GREEN — the closeout, in order (all on the branch, then the PR)

1. **§10 item 1:** land the two soak tables (Debug, release — seed · steps · seconds · exit line; the script's log has
   them; the python pattern used for the discovery tables is in the git history of the plan's commits `623bf6be9`,
   `d2f2498c6`) replacing `GATE_SOAK3_PENDING`; **VERDICT: GO** replacing `GATE_VERDICT_PENDING`, with one paragraph:
   the six items met, the three attempts and what each found, the final tree.
2. **§7 LIVE STATUS:** U4 DONE (resumption + orchestrator), the ladder CLOSED, the gate GO; the STATUS banner at the top
   → `CLOSED 2026-10-18 — GO (…); PR #…`. **VX-305's plan banner** (`notes/plans/vx-305-castle-core.md` line 3) →
   `SUPERSEDED-AND-CLOSED 2026-10-18 by VX-378 (…)`.
3. **Canon deltas** — the exact text is in `<scratchpad>/canon-deltas-draft.md` (copy it; fill the PENDING slots):
   CLAUDE.md's read-explicitly list gains `notes/CastleRules.md`; AppSpec §12's LIBRARY PORTABILITY line gains THE
   PROTECTION REBUILD sentence; AppSpec §14 gains the VX-378 entry (roll the oldest of the five to
   `notes/AppSpecDeltaArchive.md` if the five-entry rule says so — count them); the master plan `notes/DetailedPlanForPhases.md`:
   the closeout paragraph (the previous one — 13n-c's — rolls VERBATIM to `notes/PhaseCloseoutArchive.md`); the in-flight
   row is retired at the MERGE (VX-306's STEP 0), not now. These are canon edits on latest main at the merge moment
   per CLAUDE.md — since the merge is hers, make them ON THE BRANCH now so the PR carries them (she merges with a merge
   commit); note the §14 numbering may collide with a sibling run — the merging session renumbers.
4. **QUESTIONS:** the VX-378 heading's entries are written; number the bundle (#229 if main's next is free — check
   `grep -n "^#2[0-9][0-9]\|^\*\*#2" notes/QUESTIONS.md` on main) and add the one-line bundle header listing every
   P-VX378-* with status (U1-1/2 stand; O1-1 hers; U2-1/3/4/5 stand; U2-2 RULED; U3-1/2 stand; U4-1 RULED, U4-2
   CLOSED, U4-3 RULED, U4-6/7 (the resumption's), O2-1/O2-2 hers; the FACTS DIFF FD-1…3 RULED).
5. **The author handoff** `notes/handoffs/vx-378-handoff.md` from `<scratchpad>/vx-378-handoff-draft.md`: fill
   GATE_VERDICT, the gate table, LADDER_SUMMARY (4 rounds, tallies), the filed tickets by priority (VX-380 Low Parked;
   VX-386 Medium), the three attempts' story, her rulings verbatim, the MOBILE PARITY line ("nothing mobile-visible"),
   the PR URL. Her checklist leads: read §10 → the bundle → the page → the rules → merge the PR → `/architect-phase
   vx-306`.
6. **The VX-306 plan** is landed (`notes/plans/vx-306-castle-open-road.md`, PLANNED, kickoff STEP 0 = the merge). Re-read
   its U1 obligations list once more against §9's dispositions (VX-386's three items are named).
7. **Linear:** VX-378 → In Review (Done rides the merge); comments pointing at the handoff on VX-378 and VX-305; VX-386
   stays Todo under the project; VX-380 Parked. Never set an assignee.
8. **Tidy:** delete the ZZ trace files if any remain (none should); `git worktree remove --force <scratchpad>/review-wt;
   git worktree prune`; the scratchpad's logs/scripts are deleted ONLY after the PR merges (her 13x rule: the plan's
   record is the evidence) — so leave them until VX-306's STEP 0 and say so in the handoff.
9. **The PR:** `gh pr create --base main --head vx-305-castle-core --title "VX-378: Castle, simplified — the headless
   core rebuilt to the rules (closes VX-378, VX-305, VX-345)" --body <the handoff's summary + the gate verdict + the
   bundle pointer + "merge commit only">` — body ends with the attribution block the system reminder prescribes for PR
   descriptions (CLAUDE.md forbids trailers on COMMITS; the PR body line is allowed). **Do not merge.**
10. **Memory:** `vx-378-run-state.md` → CLOSED-PENDING-HER-MERGE with the PR URL; MEMORY.md line updated; push.
11. **Hard stop.** Tell her: the GO, the PR link, the handoff path, one line per thing she must look at.

## 6. Machinery lessons (this phase)

- **zsh does not word-split an unquoted scalar.** `extra="-c release"; swift test $extra` passes ONE argument under zsh and
  `swift test` refuses it instantly; the soak script's release leg produced twenty empty lines in a second and a `fail=1` marker.
  Spell flags as separate words (or an array: `extra=(-c release)`), and treat a run whose per-seed line is EMPTY as a script
  fault to reproduce by hand before reading it as a red. The Debug leg was unaffected (an empty scalar expands to nothing).

- `swift test` with a wide `--filter` sweeps `MultiTenantSyncAttackerTests` in; under `-c release` it fails on the
  Argon2 production floor — that is VX-380, never a Protection red. A full-suite Debug run once hit a 60-s timeout in
  `StarContextTests` under load (green alone) — timing class, not ours.
- Never build/test in the main worktree while the soak runs there (the `.build` lock and the tree); use the review
  worktree. Never edit Sources/Tests in the main worktree mid-soak (each seed's `swift test` rebuilds).
- `grep -a` on test output (binary bytes appear); the script's step parse takes the LARGEST "N steps" match.
- Subagent reviewers that end a turn "waiting on background work" are flagged completed; their incremental findings
  file is the deliverable — read it, then wait for the real handback.
- The Monitor's 30-min cap: re-arm on every expiry; `tail -n 0 -f` avoids replaying old lines.
- The two memory-less edits of the plan while an implementer owned the worktree were avoided by holding her verbatim
  words in the MEMORY repo until the seam — keep doing that when a subagent owns the tree.

## 7. Her open items (bundled; nothing waits on her before the PR)

P-VX378-O1-1 (rule 5's one sentence), O2-1, O2-2, U2-1/3/4/5, U3-1/2, U1-1/2, the resumption's U4-6/7; the page's
stage-14 text as rendered; VX-386's placement as VX-306's first commit; the VX-306 kickoff's STEP 0 (the merge).

---

## KICKOFF PROMPT (paste-ready, for the post-compaction orchestrator or a fresh Fable session)

> You are the VX-378 orchestrator (Fable), resuming after compaction. Read, in this order, yourself: `CLAUDE.md` and its
> auto-loaded canon; `notes/plans/vx-378-orchestrator-handoff.md` (this file — §3 is the state to VERIFY, §4/§5 the two
> roads); `notes/plans/vx-378-castle-simplified.md` §7, §9, §10 (and §8's HER RULINGS AT THE U4 STOP + KICKOFF SITTING
> for her words); `notes/CastleRules.md`; `notes/SessionResiliencyProtocol.md`. Then: `cd ~/dev/variorum-vx-305 && git
> status -sb && git log --oneline -5 && git diff --stat 66f7561e1..HEAD -- Sources Tests` (must be empty), `tail -5
> <scratchpad>/gate-runs-5.log`, `pgrep -f soak3.sh`. Her standing mandate holds: no questions — rule provisionally with
> options and why, bundle for her; stop only for a rule that cannot hold. If the soak is still running, re-arm the
> Monitor on `gate-runs-5.log` and wait. On `END` with zero reds → §5 of the handoff (the closeout; open the PR; do NOT
> merge — her VX-306 kickoff merges). On a red → §4 (stop the soak, trace in the review worktree, classify, pin
> red-on-old, fix, a fresh `fable-reviewer` round, re-run the whole gate on the new final tree). Keep every record
> repo-first and pushed; keep the memory file current; keep orchestrator text product-framed. Report to her at each
> marker in plain words, point by point.
