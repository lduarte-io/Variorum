# VX-494 — ladder round 2 (a fresh `opus-reviewer`, `notes/REVIEW_PROMPT.md` verbatim)

**Reviewer:** a fresh `opus-reviewer` (Opus 5.5), 2026-10-23, worktree `~/dev/variorum-vx-494`, branch
`vx-494-catchup-hang`, the whole `git diff main...HEAD` with the round-1 fixes (commits after `9b2a043bc`) as the
anchor. Headless only (no stage, no app, no `xcodebuild`); this file is written incrementally as the review goes.

## SCOPE NOTE — FIRST (the reviewer contract's own line)

**The diff DOES touch `Sources/VariorumCore/Sync/`** (`PullStage.swift` new, `SyncEngine.swift`, `SyncScheduler.swift`,
`SyncSchema.swift`) — Fable's mandatory scope under CLAUDE.md ("Any change inside `Sources/VariorumCore/Sync/` is Fable
work"). The record carries the author's explicit waiver for this effort: **R-494-1** (2026-10-23 ~03:55, "yeah go with
opus …") and **R-494-3** ("R-494-1 covers the Fable waiver"). Under that waiver this round proceeds as an
`opus-reviewer` round; the orchestrator re-spawns as `fable-reviewer` only if it reads the waiver otherwise.

## TALLY

**0 BLOCKER · 1 MAJOR · 3 MINOR · 2 NIT.** The MAJOR (R2-1) is new: the stage reopens the 13j returner road. Under
CLAUDE.md's ladder it earns a round 3.

What was checked, and how:
- Every R1 fix item was re-checked against its final call.
- Two of the seven R1 reverts were re-run on a scratch copy and matched the record.
- Two new probes went red on the tip's code. Both are in
  `/private/tmp/claude-501/-<home>-dev-variorum/c34bb0c9-4f3f-47f5-964c-43a1eb555b91/scratchpad/probe/Tests/VariorumCoreTests/ZZReviewerR2ProbeTests.swift`,
  a scratch copy of the package whose `Sources/` are byte-identical to the tip (checked by `diff -rq`). The repo itself
  was never edited.

There is no phase plan and no "Review foci" section, so there were no foci to check.

## FINDINGS (severity-ranked)

### R2-1 [MAJOR] · `Sync/PurgeJanitor.swift:263–305` (`reconcileLedger`) × `Sync/PullStage.swift:82–96` (`plan`) × `Sync/SyncEngine.swift:497–563` · a stage that outlives a purge brings the purged rows back on that device, permanently (a new road around the 13j ledger)

**What's wrong.** The 13j returner road keeps purged rows off a returning device in two ways. The feed never serves a
purged row. And the pre-round ledger pass (`reconcileLedger`, run by the scheduler before every round) drops any
purged row the store still HOLDS, then moves its scan point (`last_purge_seq`) past those entries, for good. The
stage is a third place a row can live, and neither guard sees it:
- `reconcileLedger` checks only the live tables (`Self.rowExists(db, table:, rowID:)`, `PurgeJanitor.swift:293–295`).
  It never looks in `sync_pull_stage`. Then it advances `last_purge_seq` past the entry anyway (`:303`).
- `PullStage.plan` resumes on base/key/device/format/lockstep alone (`PullStage.swift:86–89`). Nothing in the header
  knows that a purge happened after the rows were staged.
- So the round's resumed apply writes the staged copy verbatim (`writeResolvedRow`, `SyncEngine.swift:659`). The
  staged copy is typically the LIVE version, staged before the deletion. The row's tombstone was purged, so it is
  never served again. The scan point has already passed the entry, so no later ledger pass names it.

**Mechanism (traced, then probe-confirmed).**
1. A device's first catch-up is interrupted, leaving a stage. Note P is staged live.
2. The device goes dark for more than 60 days: `seen_at` leaves `sync_horizon()`'s window
   (`10_phase13j_purge.sql:500`). Meanwhile P is deleted elsewhere and purged by the ordinary 30-day road, because the
   horizon no longer includes this device.
3. The device returns. `reconcileLedger` drops nothing (P is only staged) and moves the scan point past P's entries.
   `plan` returns `.resume`, the fetch serves nothing of P, and the apply writes the staged P live.
4. P now lives on this device and nowhere else, permanently:
   - Nothing ever re-serves P or re-names it.
   - It is not in the outbox (apply mode), so it never pushes. If she edits it, the push is refused `purged` and the
     family vanishes under her edit.
   - `syncedDump` diverges for good.

**Probe** (a scratch copy of the package, never this repo; `ZZReviewerR2ProbeTests` in the reviewer's scratchpad):
- The setup: A's doomed note created first, then a 12 × 10 corpus. B's first catch-up fails at window 6 (40-row
  windows), so the doomed container is staged live. A deletes it, backdates it past 30 days and rounds. Then
  `setHorizonDropoutTicks(10)` + `advanceClock(by: 100)`, `round(a)`, and A's `sweep` purges the family (the mirror
  row is nil).
- B then runs `reconcileLedger()` and then `pull(batchSize: 40)`.
- **Result on the tip `8ec29c300`'s code:** `ledger rows dropped=0 resumedFrom=200 liveDoomed=1`. B's own `sweep` plus
  a `round(b)` after it still leave it: `doomed container rows on B = 1`.
- **CONTROL:** the identical scene with `PullStage.clear` run by hand before B returns (the pre-stage engine's shape)
  gives `resumedFrom=0 liveDoomed=0`, and the control test passes. The stage is the whole mechanism; the pre-fix
  engine (no stage) cannot reach this state.

**Reach.** Any device whose stage outlives a purge of rows it staged:
- **(a)** A device dark for 60+ days mid-first-catch-up. The Air is the obvious candidate: a second Mac, with an
  interruption-prone catch-up while VX-492 is open. The phone is another. The same holds for a library left signed out
  (sync off) for 60+ days mid-catch-up: CastleRules rule 16 makes signing back in a join under the same account key,
  so the identity still matches and the stage resumes.
- **(b)** A device that keeps RESUMING without ever committing. See R2-3: a resumed round never refreshes `seen_at`,
  so such a device leaves the horizon while it is actively syncing.
- **(c)** CastleRules rule 21's hand-restore: an older copy of the same library in the live place keeps its device
  id, so a backup written mid-catch-up resumes its stage after purges.

The 13j suite pins exactly this road for the pre-stage engine (`anInWindowLaggardHoldsTheHorizonAndADropoutDoesNot`:
"The dropout returns … never a resurrection"). The stage reopens it.

**Proposed fix (either; (1) is precise):**
- **(1)** `reconcileLedger`'s write transaction also deletes staged rows the page names, for EVERY entry and not only
  the `present` ones: `DELETE FROM sync_pull_stage WHERE table_name = ? AND row_id = ?` before
  `setStateValue(last_purge_seq)`. A row it removes is one the server can never serve again. The rest of the stage
  stays valid, and nothing is re-downloaded.
- **(2)** The header records the scan point (`last_purge_seq`) at staging, and `plan` resumes only while it is
  unchanged. That costs one re-download whenever a purge landed during the interruption.

A purge that lands AFTER the round's pre-pass and before its apply heals by itself: the next pre-pass sees the entry
above its scan point and the row is now present.

**Pin** (red on the tip, green after the fix): the probe above, as a guard in `ResumableCatchUpTests` or
`PurgeConvergenceTests`. Assert the doomed container is absent on B after its return round, and
`a.syncedDump() == b.syncedDump()` after quiescence.

### R2-2 [MINOR — production reachability SPECULATIVE, as N2's was; the pin is RED on the tip] · `Sync/SyncEngine.swift:597–605` (the N2 belt) · the belt checks the cursor VALUE; a commit that stalls at its batch's FIRST row moves no cursor, so the belt passes and the round commits past rows another writer cleared

**What's wrong.** The ladder-R1 N2 belt refuses the apply when `cursor(db) != since`. But another round's apply can
clear the stage this round extends without moving the cursor. That happens when its batch stalls at index 0:
`newCursor = stopIndex > 0 ? … : since` (`SyncEngine.swift:665`), and then `PullStage.clear` (`:672`). It also happens
through `discardThenFresh`'s clear and `resyncReinitialize` from a base-0 cursor. A stall at the batch's first row is
not an exotic state. It is the steady state of every stalled device: after a stall the cursor sits just before the
straggler, so every later round's first row IS the straggler, until its referent arrives.

**Mechanism, probe-confirmed.** This is the N2 pin's own interleaving and hook, with B committed up to the stall point
first, so the straggler is B's next first row:
- B's round resumes nothing and stages windows 1–2. At its third pull call, the other round (same store, device and
  key) resumes B's stage, stalls at index 0, commits the cursor UNCHANGED at 7, and clears the stage.
- B's round then stages windows 3+ and saves. The belt sees `7 == 7` and passes. B commits head 128.
- Probe output: `other stalled=true other.newCursor=7 stallPoint=7 B outcome=committed B cursor=128 head=128
  missing=40` — the straggler placement@8 plus 39 posts@9…47, never applied, never re-served.

**Reach.** It needs the same two overlapping rounds on one store that N2 needed (the `stop()` → `configure()` road
with an undrained retired round). D3's cancel shrinks that window to milliseconds, and the R1 reviewer could not reach
it in production. So the production reachability is SPECULATIVE. But the belt was accepted as N2's closure, and the
hole it leaves is the most likely shape of the very overlap it guards.

**Proposed fix.** Check the stage's own continuity, not the cursor's value:
- **(i)** `PullStage.stage` refuses unless the stage is exactly where this window starts. That means either no header
  and `windowSince == base` (the round's first write), or a header with matching base/key/device whose
  `seq == windowSince`. A cleared or advanced-by-another stage throws, and nothing is written.
- **(ii)** The apply transaction refuses unless the header still exists with `seq == fetchCursor` (this round's reach)
  and `base == since`.
- Keep the cursor check beside them; it costs nothing.

In the N2 interleaving, (i) kills whichever writer is second at its next window, and (ii) covers a clear landing
between a round's last window and its apply.

**Pin.** `probeTheBeltMissesAFirstRowStall`: the N2 pin with a `b.pull(batchSize: 20)` to the stall point before the
straggler is pushed. Expect `missing.isEmpty` (red on the tip), and B to refuse or commit honestly.

### R2-3 [MINOR — a design consequence, no bug-class pin claimed] · `Sync/SyncEngine.swift:530–537` (`windowDevice`) × `10_phase13j_purge.sql:500` · a device that keeps RESUMING never refreshes `seen_at`, so it leaves the purge horizon while it is actively syncing

**What's wrong.** The server stamps `device_cursor.seen_at` only on a pull that carries the device id
(`13_phase13i_wings.sql:238–244`; the fake's twin is `FakeSyncServer.swift:759–764`). That `seen_at` is the 60-day
horizon-membership clock (her round-8 ruling). F2's guard rightly keeps the device id off a resumed round's first
window, so `last_seq` is never over-reported. The side effect is that a resumed round never refreshes `seen_at`
either, and every window of a resumed round passes nil.

**The consequence.** A device whose rounds keep resuming without committing looks "unseen" after 60 days, though it
talks to the server every round. Two ways to get there: a save that never finishes inside a foreground session (the
phone's case under iOS suspension, VM-8), or a deterministic apply failure (the F1 (3)-declined class).

What follows differs from the pre-stage engine:
- **Before the stage:** every round re-fetched from the committed cursor WITH the device id. A stuck device held the
  account's horizon at its cursor indefinitely, so nothing was purged past it.
- **Now:** the account's purges proceed past it. That is exactly R2-1's road (b). It also brings the purge-wins
  doctrine to the stuck device's own unpushed writing under purged families. Those writes never pushed anyway,
  because pull → push (A3) blocks the push behind a failing pull.

Nothing records the shift.

**Proposed disposition.** With R2-1 fixed, the harm left is the semantic shift itself. Record it as an accepted
consequence in the record, or put it to her: does an actively-resuming device count as "seen"? If it should, the
cheap road is one zero-row device report per resumed round, `since: base` with the device id. That costs one more
call, a ~1.5–3 s seq-scan on her corpus today (VX-495's shape). A pin is constructible against the fake
(`setHorizonDropoutTicks`, with B resuming on each tick), but whether it should be red is her call. So this is a
QUESTIONS line, not a bug.

### R2-4 [MINOR] · `notes/handoffs/vx-494-handoff.md` (step 6 + "Your calls owed") vs the record's "LADDER ROUND 1 — THE FINAL CALLS" · the R1 final calls say F4 was "Added to the handoff's step 6"; the handoff was never touched after the ladder

**Evidence.** `git log -- notes/handoffs/vx-494-handoff.md` shows one commit, `9124aeb4a`, made before the ladder.
- Step 6 still names only "the locked-row line in SurfaceContracts; the dated narratives … into AppSpecRecord". It
  carries no AppSpec §7 `sync_pull_stage`/`pull_stage` line and no SyncSpec §3/§5 line (`grep` for `pull_stage`,
  `§3`, `§5` and `v1_32` in the handoff finds only the result paragraph's mention of the table).
- "Your calls owed" carries none of the round's items for her:
  - F6, the v1_32 export-import question;
  - O-2, the stage's disk footprint, 79 → 150 MB;
  - O-1, the Standard join's system Touch ID prompt;
  - the Standard set-up's "Sync locked until relaunch" observation in row 2.

  Only the generic `PENDING(any finding the ladder … raised)` slot stands in for them.

A fresh morning session that works from the handoff, as her paste-ready prompt tells it to, would close without the
contract lines and without asking her the bundled calls. The record's claim that it is done is false on the branch.

**Proposed fix.** Before the merge, write step 6's canon line items (AppSpec §7; SyncSpec §3 and §5 — plus R2-1's
fix, if it lands, as the ledger now screening the stage) and list F6, O-1, O-2 and R2-3 under "Your calls owed".

### R2-5 [NIT] · `notes/plans/fixes/vx-494-catchup-hang.md:16–23` · the LIVE STATUS table is stale against its own header

- Row 4 still reads "IN-PROGRESS" with "release PENDING" and "PENDING its solo re-run". Both were run since: the
  R1-7 row shows the release suite, and the flake passes alone.
- Row 5, "Ladder", reads "NOT-STARTED", while the STATUS header and THE FINAL CALLS record round 1.

Under SessionResiliencyProtocol a fresh session trusts this table first. Flip rows 4 and 5.

### R2-6 [NIT] · `Sync/PullStage.swift:58–65` + `App/Variorum/Shared/ErrorPresentation.swift:46` · the belt's refusal is shown verbatim on the sync row, in engine words, and nothing re-runs the round

`CursorMovedUnderRound.description` reads "another sync round committed while this one was downloading (cursor 0 →
7); the next round starts from the new cursor". `SyncScheduler` stores `String(describing: error)`, and
`ErrorCauseNote` renders `Text(error)` under the error face. So if the belt ever fires she reads seq numbers and
"cursor" until the next trigger. The same holds for `UndecodableStage`'s "the pull stage this round downloaded would
not decode". The pre-existing posture for unclassified errors is the same, which is why this is a NIT. But this
refusal is self-healing by design.

**Proposed fix (cheap).** The scheduler sets `followUpRequested = true` on a `CursorMovedUnderRound`, so the healing
round runs at once and the line clears itself. The words stay as they are unless she wants a sentence, which is her
call and can be bundled.

## CLEAN BILL (specifically checked, found solid)

- **F1 (1)+(2) as built.**
  - `plan` resumes only on base · key · device · format · lockstep, with `seq > base` (`PullStage.swift:86–89`).
  - A pre-R1 header lacks both new keys, so it decodes as nil (`try?`) and is discarded.
  - `rows()` answers nil only on a `DecodingError`; a database error still throws.
  - `pullRound` refetches ONCE (`mayRefetch` true only on `.resume`) and clears before either the refetch or the
    throw.
  - The refetch's first window goes out with `since` equal to the committed cursor, so it carries the device id
    honestly.
- **F2 / F3 guards.** All three pins are present and meaningful. I re-ran RV-R1d (`windowDevice` keyed on the round's
  first window) on the scratch copy: `✘ … 12 tests … with 1 issue`, only
  `aResumedRoundNeverReportsItsReachAsTheDevicesCursor`, matching the record.
- **N2 belt.** It is present, refuses before any write, and rolls back clean. I re-ran RV-R1g (the belt removed):
  `✘ … with 2 issues`, only `aRoundNeverCommitsPastRowsAnotherWriterClearedFromUnderIt`, matching the record. Its gap
  is R2-2.
- **N3.**
  - `PullStage.encode` runs before the writer is taken.
  - `stage` uses one `cachedStatement` whose SQL text is constant, so the cache hits.
  - A window's rows and its header still land in one transaction.
- **N1.** Every listed drift is fixed: no `resumePoint`, no "what it fetched is staged", no "four tables" left in
  `Sources/` (grep). `retire()`'s and `stop()`'s docs now say cancel.
- **D3's reach re-checked.**
  - `stop()`'s three callers (`AppServices.swift:262/384/473`) are lock and teardown, sign-out, and delete-account.
    In each, cancel is the offline / lost-ack class the engine already survives.
  - `configure` retires, then drains.
  - `loopTask` is set and cleared under actor isolation.
  - The scheduler is the ONLY production caller of `pull()` (grep), so the one-writer premise holds except for the
    `stop()` → `configure()` overlap (R2-2).
- **Runs on the tip's code** (scratch copy):
  - `swift test --filter ResumableCatchUpTests`: `✔ Test run with 12 tests in 1 suite passed after 6.027 seconds`.
  - The sync sweep plus that suite: 355 tests in 81 suites, all green. The only red is the reviewer's own
    `probeAStageOutlivingAPurgeResurrectsThePurgedNote`, which the `Purge` filter caught.
- **P1.** `plan` is O(1): an EXISTS read and the header. An ordinary incremental round adds one window write and one
  read. The download's peak memory is one window; the apply reads the stage whole, as the in-memory batch did before.
- **E2EE seam.** Rows open at the seam BEFORE any stage write; a decrypt refusal throws with the window unstaged. The
  stage is plaintext inside the SQLCipher store, like every local row. It is never a payload, and the export drops it.
- **F1 (3)'s decline is sound.** A Castle lock fails the apply with a closed-pool error, not a cancellation, and the
  stage exists for exactly that case. With format, lockstep and decode guarding drift, the remaining content-poison
  class predates the stage.
- **De-duplication.** The upsert keeps only a row's highest `server_seq`, so when a row changed during the download
  the batch holds the newer version only. That is slightly narrower than the doc's "exactly the rows today's
  in-memory fetch would have held": the old batch carried both versions. It is semantically benign — the same final
  state, and a stall can only move earlier, to where a fresh round would put it.
