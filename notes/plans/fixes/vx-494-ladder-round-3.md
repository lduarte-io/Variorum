# VX-494 — ladder round 3 (the cap; a fresh `opus-reviewer`, `notes/REVIEW_PROMPT.md` verbatim)

**Reviewer:** a fresh `opus-reviewer` (Opus 5.5), 2026-10-23, worktree `~/dev/variorum-vx-494`, branch
`vx-494-catchup-hang`, the whole `git diff main...HEAD` (tip `fed71e05b`), with rounds 1–2's findings and the record's
FINAL CALLS / R1 FIXES / R2 FIXES as the anchor. Headless only (no stage, no app, no `xcodebuild`). Written
incrementally; FINAL.

## SCOPE NOTE — FIRST (the reviewer contract's own line)

**The diff DOES touch `Sources/VariorumCore/Sync/`** (`PullStage.swift` new; `SyncEngine.swift`, `SyncScheduler.swift`,
`SyncSchema.swift` changed) and adds a schema migration (`v1_32`) — Fable's mandatory scope under CLAUDE.md. The record
carries the author's explicit waiver for this effort: **R-494-1** (2026-10-23 ~03:55, "yeah go with opus - i think fable
will almost certainly just hit a bunch of safeguards") and **R-494-3** ("R-494-1 covers the Fable waiver, so no step
needs Fable"); CLAUDE.md allows it ("the author may waive it"). This round proceeds under that waiver as an
`opus-reviewer` round; the orchestrator re-spawns as `fable-reviewer` only if it reads the waiver otherwise.

## TALLY

**0 BLOCKER · 1 MAJOR · 1 MINOR · 3 NIT. FINAL.**

- **The MAJOR (R3-1) is in D3, not D2.** D3's cancel reaches the SAVE: a Castle lock mid-save now discards the save
  where it used to wait for it. It is probe-proven on a scratch copy: red on the tip, green on the pre-D3 control and
  on a one-line fix shape.
- **D2's stage is clean this round.** R2-1 (the ledger scan point in the identity) and R2-2 (continuity) are sound as
  built. RV-R2a was re-run and goes red on exactly its pin.
- There is no phase plan and no "Review foci" section, so there were no foci to check.

## FINDINGS (severity-ranked)

### R3-1 [MAJOR] · `Sync/SyncScheduler.swift:166` (`retire()`'s `loopTask?.cancel()`, D3) × `Sync/SyncEngine.swift:598` (the save's async GRDB write) × the record's THE FIX DESIGN D3 (`vx-494-catchup-hang.md:483–484`) + the handoff (`vx-494-handoff.md:31–32`, `:50–52`) · D3 cancels the SAVE: a Castle lock that lands while the save runs now throws the save away, where before D3 the lock waited behind it and the save committed — and since D1 the save is the long phase

**What's wrong.** D3 makes `retire()` cancel the round's task. The design said "with D2, a cancelled round loses
nothing" (record :484). That is true for the DOWNLOAD (completed windows stay staged). It is false for the SAVE: the
save is one async GRDB write (`applyingRemoteWithDeferredFKs` → `AppDatabase.applyingRemote` → `currentWriter().write`,
`AppDatabase.swift:339–353`), and GRDB 7's async accesses turn task cancellation into `db.cancel` —
`sqlite3_interrupt` plus `CancellationError` on the next statement (`SerializedDatabase.swift:251–269`,
`Database.swift:1242–1268` in the checkout). The transaction rolls back. The stage survives, but the save's minutes of
work are gone, and the next round redoes the whole save.

**Why this is a regression, not only a cost.** Before D3, a lock did not cancel the round, so a lock that arrived
mid-save waited for it:
- The Mac's lock road runs `onWillLock` (`MacWillLock.swift:45–61`). That ends at `stopServices()` → `services?.stop()`
  (`VariorumApp.swift:290`) → `SyncSession.stop()` → `retire()`.
- Then `binding.lock()` (`AppBootstrap.swift:1276–1277`) runs. It first takes the OUTGOING writer for a checkpoint
  (`StoreBinding.swift:89–110`; `writeWithoutTransaction` is a synchronous access on the same serial writer), and only
  then closes the pool. So it queued behind the in-flight save, and the save committed first.
- With D2 in place, D3 gains almost nothing in the download phase. After `binding.lock()`, the retired round's next
  stage write throws `StoreLockedError` (`AppDatabase.swift:44–51`), so the old "kept downloading the whole feed"
  problem is already capped at one window.
- What D3 still changes is the save phase. A lock there used to let the save land. Now it discards the save.

**Why it bites the ticket's own acceptance case.** In Castle, re-lock on sleep and on screen lock is ALWAYS ON
(decision 18, `ProtectionController.swift:76–92`), and the idle lock defaults to 10 minutes. D1 shrank the
download to ~1–2 min on her server. The save stayed: ~4.3 min on her Pro, ~7 min in the live proof. So the save is now
most of a first catch-up, and the phase a lock is most likely to hit.

The handoff tells her, for the Air crossing (a MacBook, joining her Castle account — rule 10), to "Leave it alone until
the row says Synced" (:32). Here is what happens on a laptop left alone:
1. The display sleeps (on battery the macOS default is minutes), then the screen locks, then Castle locks. If that
   lands in the save, the save is lost.
2. She returns and unlocks. The resumed round downloads nothing and starts the full save again.
3. If she leaves again, the same thing happens.

That is the "first catch-up never lands unattended" class this ticket exists to close. On the tip it is reachable
whenever the display-sleep delay or idle timeout is shorter than the save. On D1 + D2 without D3 it is not reachable.

The handoff's VX-492 call (:50–52), "with the download resumable, a lock now costs a pause, not the download — keep the
lock as is (close VX-492 as resolved by VX-494)?", puts a false premise to her for the save phase.

**Probe (a scratch copy of the package whose `Sources/` equal the tip, never this repo).** The probe is
`…/scratchpad/probe-r3/Tests/VariorumCoreTests/ZZReviewerR3ProbeTests.swift`,
`probeARetireDuringTheSaveLetsTheSaveCommit`. The scene:
- A pushes a 12 × 10 corpus. B runs a `SyncScheduler` round.
- A TEMP trigger on B's connection fires on the first `block` row the SAVE writes (apply mode only). It calls a SQL
  function that runs `scheduler.retire()` and waits until it has been delivered. That is the lock landing mid-save,
  deterministically.

Results:
- **On the tip:** `fired=true cursor=0 head=375 staged=375 lastError=CancellationError()`. The save rolled back and the
  download stayed staged. RED.
- **Pre-D3 control** (`retire()` without `loopTask?.cancel()`): `cursor=375 head=375 staged=0`. The save committed.
  GREEN.

**Proposed fix: one of these, the orchestrator's arbitration.** The spec is silent on a lock's promptness during
sync work. CastleRules has no such rule. The one precedent, P-VX308-U4-2 (PROVISIONAL), rules that "a lock asked while
an act runs WAITS for it". If the orchestrator reads this as product behaviour, it goes to QUESTIONS.

- **(a) Shield the save, keep the download cancellable.** Run the apply in an unstructured task, so a retire's cancel
  never reaches it; it inherits the task-locals and dependencies:
  `return try await Task { try await self.applyingRemoteWithDeferredFKs { … } }.value`.
  The between-window `checkCancellation`, the in-flight network cancel and D3's pin all stay. A lock mid-save then
  waits for the save, as before D3. Checked on the scratch copy:
  - the probe goes GREEN (`cursor=375`; the push after it is the one cancelled — `lastError=CancellationError()` on a
    retired scheduler, invisible);
  - `ResumableCatchUpTests` 17/17 stays green, D3's `retiringASchedulerStopsItsInFlightDownload` included;
  - the sync sweep stays green: 360 tests in 81 suites (the probe included).
- **(b) Keep the cancel, and correct what rests on the premise.** Fix the record's D3 line and the scheduler's D3 doc:
  a cancel mid-save loses the save. Restate the handoff's VX-492 call for the save phase. Change the Air's crossing
  instructions to "keep the Air on power, awake and unlocked through the save" (her Pro's crossing ran under
  `caffeinate` with the idle lock at Never). Fold "a save that survives a lock" into VX-497's scope.

**The pin:** the probe's scene as a `ResumableCatchUpTests` case. It is RED on the tip, and GREEN on the pre-D3 shape
and on (a). Under (b) there is no code pin, only the record and handoff lines.

**Note for THE ARCHITECT'S NOTE's fallback.** That fallback merges D1 + D3 and reverts D2. That is the combination this
finding hurts most: without the stage, a lock during the save would cost the save AND the whole download, where D1
alone would have let the save land.

### R3-2 [MINOR] · `notes/plans/fixes/vx-494-catchup-hang.md:3–4, :18, :20` + the R2-4 final call (`:103–104`) · the record's STATUS header and LIVE STATUS row 2 are stale again, and row 2's "closeout ticket" sits on no closeout list

**Evidence.**
- **The STATUS header** (:3–4) still reads "ladder round 1 in (1 MAJOR, 5 MINOR, 4 NIT — the fixes go to a fresh
  implementer session)". Since then round 2 ran, its fixes are done, and this is round 3.
- **Row 2** (:18) still reads IN-PROGRESS, with "the stage window is OPEN (claim `vx-494`, 03:48 MDT, 240 min)" and
  "RESTORE (owed at the window's end): … remove the walk library's files + its Backups subfolder, `mv` the 9 back".
  But the record's own "THE DEV SLOT — RESTORED WHOLE (06:00–06:03)" (:330–349) says the restore is done: the 9 dev
  files are back and the aside dir is removed.
- **Row 4** (:20) names the R1 fix commits only, not R2's (`1b9cf434d`…`fed71e05b`).
- **Row 2's "OBSERVATION (a closeout ticket, Low)"** reads: after the Standard set-up, the row stayed "Sync locked"
  until a relaunch, because no act-side round ran. Round 2's reviewer listed it under R2-4 as a fourth item. The R2-4
  final call ("the calls owed gain F6, O-1, O-2 and R2-3") dropped it without a disposition, and no other line carries
  it. That is deferred work with no ticket and no checklist (CLAUDE.md: "unowned/reason-less ⇒ fix it now").

**Why it matters.** SessionResiliencyProtocol has a fresh session trust LIVE STATUS first. The morning session works
from the handoff, which sends it to this record. It would read a stage claim as open and a dev-slot restore as owed.
That restore's "remove the walk library's files" step now names a slot that holds the DEV library's files.

**Fix (the orchestrator's, no code).**
- Flip the header and row 2 to what the record says below them.
- Add the R2 commits to row 4.
- Put row 2's observation under the closeout's ticket list, or the handoff's calls owed, with its disposition.

### R3-3 [NIT] · `Sync/PullStage.swift:27–29` + `Sync/SyncEngine.swift` (the comment above `PullStage.rows` in `pullRound`) · two docs still say the staged batch is "exactly" what the old in-memory fetch held

The upsert keeps ONE copy per row: the highest `server_seq` (`PullStage.swift:191–197`). The old in-memory loop could
hold two versions of a row that changed during the download. Round 2 checked this and found it semantically benign
(its clean bill). The words were never corrected.

The accurate sentence: each row once, at its latest staged seq — exactly what a FRESH round from the base would fetch.
Doc only; no pin.

### R3-4 [NIT] · `Sync/PullStage.swift:84–90` · the ledger scan point's key and its reader are a second copy of `PurgeJanitor`'s private ones

`PullStage.ledgerScanPointKey = "last_purge_seq"` and `ledgerScanPoint(_:)` restate the janitor's literal and its
`stateValue` "absent ⇒ 0" rule (`PurgeJanitor.swift:211–213, 278, 303, 815–817, 824–828`). A rename on one side is
caught: the R2-1 pin drives the real `reconcileLedger`, and it would go red (traced). So this is cleanliness only. The
fix: one shared constant and one reader, e.g. internal statics on `PurgeJanitor` that `PullStage` calls.

### R3-5 [NIT] · `Sync/PullStage.swift:223–232` (`rows`) · the apply's batch read holds every payload string and the decoded batch at once

`String.fetchAll` materializes the whole stage's JSON before any decode:
- At the live proof's ~110k rows that is ~79 MB of strings, on top of the decoded batch the apply then holds.
- The pre-stage engine held only the decoded rows.
- A `String.fetchCursor` loop decodes as it reads. It keeps the same order, the same nil-on-undecodable rule, and the
  same thrown database errors.

This matters most on the phone (VM-8). It is a cost, not a bug: no pin is claimed.

## CLEAN BILL (specifically checked, found solid)

- **Runs on the worktree:**
  - `swift test --filter ResumableCatchUpTests`: `✔ Test run with 17 tests in 1 suite passed after 8.196 seconds`.
  - The record's sync sweep filter plus `ResumableCatchUp`: `✔ Test run with 359 tests in 80 suites passed after
    50.913 seconds`. That is consistent with the record's 344, since two of the suite's tests already match `Purge`
    and `Scheduler`.
  - `swift build`: no warnings in the changed files.
- **Runs on a scratch copy** (`…/scratchpad/probe-r3`, `Sources/` = the tip by `diff -rq`; the repo was never edited):
  - **RV-R2a** (`Header.belongs` without the scan-point leg): `✘ … 17 tests … with 4 issues`, only
    `aStageFetchedBeforeAPurgeLandedIsNeverResumedAfterIt`. This matches the record.
  - **The R3-1 probe and its control and fix shape** are as stated above.
  - The scratch `Sources/` were restored to the tip afterwards.
- **R2-1 as built, against every writer of `last_purge_seq`.**
  - `reconcileLedger` (the pre-round pass) writes only when the page holds entries.
  - The sweep's own-purge advance runs only after a clean round, when the apply has already emptied the stage.
  - `reonboardFromAccount` empties the stage through `resyncReinitialize`.
  - `LocalPurge` touches no ledger.
  - So mid-round the scan point moves only under another writer, and continuity refuses that.
  - A first catch-up holds the account's horizon at its committed 0 (its first window carries the device id), so no
    purge can land during it, and R2-1's discard costs nothing in the case D2 exists for.
  - A purge landing after the pre-pass heals: the applied row is dropped by the next pre-pass.
  - A failed pre-pass leaves the scan point where the stage was fetched, so the resume is followed by the drop on the
    next good pre-pass.
- **The decode guarantee for a pre-R2 header** (non-optional `ledgerScanPoint` → `keyNotFound` → unreadable →
  `.discardThenFresh`; `stage` never writes over an unreadable header). It is pinned (R2-1u; RV-R2b in the record).
- **R2-2 continuity: no false refusal on any single-writer road.** Each plan arm was traced:
  - `.fresh` is absent with `windowSince == base`;
  - `.resume` has `header.seq == reach`;
  - `.discardThenFresh` clears first;
  - the F1 (2) refetch clears and restarts at `since`.

  The `rows()` read and the apply sit in separate transactions; the gap between them is covered by `verifyRoundsStage`
  plus the cursor check inside the apply. The record states honestly that both apply-side belts are unpinned
  (RV-R2d, RV-R2g green).
- **R2-6.**
  - The follow-up never runs on a retired scheduler and never twice in a row.
  - Triggers can extend it only as triggers always could.
  - `SyncRowFace.face` reads `isSyncing` before `lastError` (`SyncStatusViews.swift:133`), so the follow-up shows
    "Syncing…", not the belt's words.
- **D2's core semantics, re-read.**
  - Stage writes keep a window's rows and its header in one transaction.
  - The stage leaves with the commit that moves the cursor, a stall included.
  - A rollback keeps it.
  - The upsert keeps the newest copy of a row, so the batch is what a fresh round would fetch. That includes the
    prefix-satisfiability of a row whose referent was re-served later, under deferred FKs.
  - A resume point is a served window's end. The A5 horizon (`13_phase13i_wings.sql:207–211, 264, 276`) makes the gap
    between windows irrelevant.
- **The E2EE seam.** Rows open before any stage write. `SyncValue`'s bare-scalar JSON coding makes the stage's round
  trip idempotent relative to the wire's own JSON decode.
- **D1.** `sync_pull` applies the caller's `max_rows` with no clamp (`13_phase13i_wings.sql:184, 286`). The scheduler
  is the only production caller of `pull()`. The harness keeps one size, so soak window counts are unchanged.
- **Local-only registration.** `SyncSchema.localOnlyTables` lists six tables, with a matching
  `LocalMachineryRecreation` map. `MigrationTests.expectedTables` was updated. The migration landed in its own commit
  before the code. There is no lockstep event; marker 14 stands.
- **P1.**
  - `plan` is O(1).
  - Staging is window-bounded.
  - A first catch-up is inherently proportional to its backlog.
  - The download's peak memory is one window. R3-5 covers the one transient at the apply.
- **D3's other effects re-traced** (beyond R3-1):
  - the cancel during a push is the lost-ack class;
  - the cancel during a janitor sweep or `reconcileLedger` heals through the ledger on the next pre-pass;
  - `loopTask` is managed under actor isolation;
  - `configure`'s drain now ends promptly;
  - nothing else constructs a `SyncScheduler` or a `SyncSession` in production.
- **Carried, owed at closeout, by disposition (not findings).**
  - F4's canon lines (AppSpec §7; SyncSpec §3, §5) are not yet written. That is consistent with "at closeout".
  - The handoff still has no R2-4 items (F6, O-1, O-2, R2-3). R3-1's handoff lines join them if (b) is chosen.
  - The QUESTIONS entries owed at the merge are F6 and R2-3.
- **`notes/KnownIssuesAndTechDebt.md`** is absorbed into tickets. This effort owns no entry there.
