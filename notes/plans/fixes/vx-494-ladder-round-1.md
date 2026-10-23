# VX-494 — ladder round 1 (cold review, opus-reviewer, REVIEW_PROMPT verbatim)

Reviewer: a fresh `opus-reviewer` (Opus 5.5), zero implementation context. Diff: `git diff main...HEAD` on
`vx-494-catchup-hang` (tip `34abbef16`), 13 files. Anchor: `notes/plans/fixes/vx-494-catchup-hang.md` (there is no
phase plan and no "Review foci" section, so there were no foci to check). Canon read: CLAUDE.md, AppSpec, OverallModel,
CoreDescription (loaded), SyncSpec in full, plus the code each claim rests on. Runs, all from the worktree:
`swift test --filter ResumableCatchUpTests` passed 5/5. A targeted sync sweep
(`--filter "Sync|FaultInjection|Purge|Migration|LocalMachinery|StorePlaintext|Soak|Convergence|Scheduler|AbuseGuard|RestoreMatrix"`)
passed 343 tests in 80 suites. One reviewer probe ran on a SCRATCH COPY of the package, never this repo (F1 below).

## SCOPE FLAG (stated first, as the reviewer brief requires)

The diff IS in Fable's mandatory scope: it changes `Sources/VariorumCore/Sync/` (`PullStage.swift` is new;
`SyncEngine.swift`, `SyncScheduler.swift` and `SyncSchema.swift` change) and adds a schema migration (`v1_32`). The
record carries the author's waiver for exactly this case: R-494-1 (Opus writes the `Sync/` fix and a fresh
`opus-reviewer` runs the ladder) and R-494-3 ("no step needs Fable"). CLAUDE.md allows it ("the author may waive it").
I reviewed under that waiver. If the orchestrator reads the waiver differently, re-spawn the round as
`fable-reviewer`. The kickoff file's "Sync/ — no waiver" line, and the same words in the record's STATUS header,
predate R-494-1 (see N4).

## FINDINGS (severity-ranked)

### F1 [MAJOR] · `Sources/VariorumCore/Sync/PullStage.swift:26–55, 80–85, 94–100` + `SyncEngine.swift:497–544` · one bad staged row stops sync on that device for good: nothing ever discards the stage

**What's wrong.** The stage is now an ON-DISK format that outlives app updates. It holds `SyncPulledRow` as its
synthesized `Codable` JSON. Two gaps make it dangerous:

1. **The stage's identity has no format or schema version.** The header records only `base`, `seq`, `keyID` and
   `deviceID`. So a stage written by one build is resumed by the next one with no check.
2. **A stage the apply cannot take is never discarded.** The header treats unreadable as absent
   (`readHeader` uses `try?`, so `plan` discards). The rows get no such rule: `PullStage.rows` uses
   `try decoder.decode`. And `plan` returns `.resume` on a header match whether or not the rows can be read or
   applied. The apply's rollback keeps the stage on purpose ("A rollback keeps it: the next round resumes, not
   restarts"). The stage leaves only in four ways: a committed apply, a base/key/device mismatch, or
   `resyncReinitialize`.

**Mechanism, traced and probe-confirmed.** First, a device's catch-up is interrupted and leaves a stage. Quitting to
install an update is itself such an interruption. Then any of these happens:

- **(a)** A later build changes `SyncRow`, `SyncPulledRow` or `SyncValue`'s Codable shape: a renamed property, or a
  new non-optional field. Nothing on those types says they are now a persisted format.
- **(b)** A staged value or column is one the current build's apply refuses.

From then on every round runs the same way: `plan` returns `.resume`, the fetch runs, then `rows()` or the apply
throws. The cursor stays where it was, and the next round does exactly the same. The status row shows a
`DecodingError` or SQLite error forever. No user door clears it: sign-out and sign-in keep the key and the device,
and `resyncReinitialize`'s only production road is the purge-floor re-onboard, which the code itself calls
unreachable today.

Probe: a scratch copy of the package plus one test file, `ProbeStageWedgeTests` in the reviewer's scratchpad, never
committed. B's first catch-up was interrupted at its 4th window, then one staged payload was corrupted in three ways:
- `payload = '{"renamed":1}'`: 3 of 3 later rounds threw `DecodingError.keyNotFound "row"`, and the cursor stayed 0.
- `json_set(… '$.row.columns.future_col', 'x')` on a staged block: 3 of 3 rounds threw
  `unknown column 'future_col'`, cursor 0.
- `json_set(… '$.row.columns.status', 'bogus')` on a staged variant: 3 of 3 rounds threw `CHECK constraint failed`,
  cursor 0.
- Control: `PullStage.clear` by hand, then the same round, which completed (cursor 189).

**What is genuinely new here.** For any row the server has not changed since it was staged, the stage holds what a
fresh fetch would return. A server change gives the row a higher seq, so it is served again and replaces the staged
copy. So a CONTENT poison the server still serves also failed before this fix. The new, distinctive harm is twofold:
- **(i)** Format drift of the stored payload across app updates. Before the stage, nothing persisted it.
- **(ii)** Stale content the server no longer serves stays pinned. A row physically removed by a purge or a
  truncate is never served again, so it can never be replaced.

Before this fix, every round re-fetched and would heal both. (i) is the realistic one: the stage is most likely to
exist exactly when an update lands, and VM-8's phone catch-up will be interrupted far more often than the Mac's.

**Proposed fix (cheap):**
- **(1)** Add `format: Int` to the header (a constant, bumped whenever the staged row's encoding or meaning changes)
  and `lockstep: Int = SyncSchema.lockstepVersion`. A marker bump is exactly when the client's wire→row transform may
  change. `plan` resumes only when both match, and otherwise takes `.discardThenFresh`.
- **(2)** Treat an undecodable staged row the way the code already treats an unreadable header: clear the stage and
  fetch fresh from the cursor. Log it; it costs one re-download, never a wedge.
- **(3)** Optionally, for arbitration: on an apply failure that is not a `CancellationError`, also discard the stage.
  The trade-off is a transient I/O failure costing the download again, against a deterministic failure the stage
  would otherwise never escape. As built, a deterministic one never heals until the server changes the row.

**Red-on-old pins:**
- **(p1)** Interrupt a first catch-up (`armFailPull(atCall:)`), then overwrite one staged payload with undecodable
  JSON. Expect the next round to complete with `cursor == head` and an empty stage. Old code: it throws on every
  round, which is the probe above.
- **(p2)** Interrupt a first catch-up, then rewrite the header with `"format": <current-1>`. Expect the next round's
  first `pullSinces` entry to be 0. Old code: it resumes, because the extra key is ignored and identity matches.

### F2 [MINOR] · `SyncEngine.swift:512–520` · the 13j device rule on a RESUMED round is new, load-bearing and unpinned

**What's wrong.** The diff extends the 13j comment to the new case: "a resumed round's first window passes nil". That
behavior comes only from `windowDevice = fetchCursor == since ? deviceID : nil`. A plausible simplification such as
"device on the round's first window" would send `since = reach` on a resumed round, and none of the five pins would
fail.

`ResumableCatchUpTests` never reads the server's device cursor. `FaultInjectingTransport` doesn't record `deviceID`,
and no existing engine test asserts that mid-round windows carry nil. The only "mid-round windows pass null" check is
the SQL DDL pin in `AuthRLSDDLTests:1424`.

**Mechanism of the regression it would allow:**
- The server upserts `last_seq = greatest(existing, since)` (`13_phase13i_wings.sql:238–244`). So the device would
  report `reach`, which is uncommitted, while its committed cursor is `base`.
- The purge horizon can then pass tombstones in (base, reach].
- If the later apply stalls below them, the stage is cleared, and those purged tombstones are never served again.
- This is mitigated, not prevented, by the pre-round ledger reconciliation (`PurgeJanitor.reconcileLedger`, run
  before every round), which drops purged ids locally on a later round.

**Proposed fix (a pin, no code change).** In the D2 pin, after the interrupted round and the resumed round, assert
`await server.deviceCursor(b.deviceID) == 0`: the resumed round reported nothing, and the committed 0 stands. With the
mutation above it reads `failedAt`. This is a guard, so on the pre-fix tree it is red for another reason (no resume
exists there).

### F3 [MINOR] · `PullStage.swift:46–49` (identity legs) + `SyncEngine.swift:720–721` · two load-bearing stage lines carry no pin

**What's wrong.** RV3 proved only the DEVICE leg of the identity. Two other lines can be deleted with every test
green:
1. **The `keyID` leg of `plan`.** If it is removed, a stage fetched under one account's corpus key resumes under
   another's. VX-314's binding gate refuses mismatched sign-ins, but a library re-joined to a reset account (a new
   vault and a new key id, with the committed cursor still 0) would resume the old account's stage and apply its rows.
2. **`resyncReinitialize`'s `PullStage.clear`.** If it is removed, the plan's base check catches most cases, because
   the cursor goes to 0 and a non-zero base mismatches. It does NOT catch a stage whose base was already 0: a first
   catch-up interrupted, then a wipe-and-repush. The next round would resume and apply the pre-truncate mirror's
   rows, including rows the re-pushing device never had, which the server no longer holds.

**Proposed fix.** Two guard pins:
- **(a)** Interrupt a first catch-up, swap the key provider's `corpusKeyID`, then assert the next round's first
  since is 0.
- **(b)** Interrupt a first catch-up, run `resyncReinitialize()`, then assert the stage is empty and the next round's
  first since is 0.

Each goes red when its line is reverted.

### F4 [MINOR] · canon (AppSpec §7; SyncSpec §3, §5) + `notes/handoffs/vx-494-handoff.md` step 6 · the canon deltas this diff owes are not on any checklist

**What's wrong.** The diff adds:
- a local-only table, `sync_pull_stage` (v1_32);
- a second live `sync_state` key, `pull_stage`;
- a changed pull shape: windows staged on disk and resumable across rounds, with the window sized apart from the
  push chunk.

Canon still says otherwise:
- AppSpec §7's local-only machinery block lists `sync_state` keys as `'last_server_seq'` only, and names no stage
  table. Compare: `protection_record` (v1_31) got its own line there.
- SyncSpec §3 says "the cursor is the one live key".
- SyncSpec §5 describes the pull with no download stage.

The handoff's closeout step 6 names only "the dated narratives — VX-488's and VX-494's — into AppSpecRecord". The
two-file rule needs the contract lines changed in place too, and they are not listed anywhere.

**Proposed fix.** Add an explicit line to the record and the handoff's step 6:
- AppSpec §7: name `sync_pull_stage` (v1_32, local-only, the export drops it) and the `pull_stage` key.
- SyncSpec §3: the machinery list.
- SyncSpec §5: the resumable download, with the apply's one-transaction rule unchanged.

### F5 [MINOR] · the record, "D4" (`vx-494-catchup-hang.md:130–132`) · deferred work with no ticket

**What's wrong.** The save is still all-or-nothing and holds the store's writer for about 4 minutes at about 420
rows/s, at 100% of one core, on her corpus. The record names it "a measured target … recorded as D4". But R-494-2
minted only VX-495 (the server query) and VX-496 (the progress line), and the handoff's "calls owed" list doesn't
carry D4.

CLAUDE.md says: "Deferred work is a ticket too … unowned/reason-less ⇒ fix it now". This matters most for VM-8: on
a slower phone CPU, the one save may exceed a foreground session, and a lock or quit during it still costs the whole
save. D2 saves the download, not the save.

**Proposed fix.** Mint the ticket (Improvement, Performance, related to VX-494/VX-495) before closeout, or fold it
explicitly into VX-495's scope with a written line.

### F6 [MINOR] · `Sources/VariorumCore/Persistence/Migrations.swift:1047–1053` × `Operations+PlaintextExportImport.swift:113–116` · v1_32 silently makes every earlier plaintext export un-importable

**What's wrong.** T-8, bringing a plaintext export in as a new library, refuses any export whose applied migration set
differs from this build's (`guard applied == known`, which is P-VX309-U1b-7, PROVISIONAL). v1_32 is a local-only
table that the export itself DROPS. Even so, adding it to the migrator means the post-fix build refuses every export
the 0.10 (9093) build wrote, with `schemaNotCurrent(newer: false)`, for no content reason. Today that touches only
exports made on her Pro since the 9093 install, so the reach is small. But it is a product-visible consequence that
neither the record nor the handoff mentions, and every future local-only migration will repeat it.

**Proposed fix.** No code change in this fix. That would amend a PROVISIONAL rule, which is hers to make. Add a line
to the record and the handoff naming the consequence. Optionally raise it at her sitting as a QUESTIONS entry: should
local-only migrations count toward "this build's export"?

### N1 [NIT] · doc drift the diff's behavior change left behind

- `SyncScheduler.swift:141–142`: `retire()`'s first paragraph still says "(the current one, if any, finishes and
  `awaitIdle` observes it)". D3's paragraph below it says the opposite.
- `App/Variorum/Shared/SyncSession.swift:186–187` (`stop()`'s doc): "an in-flight round finishes on its own". Now it is
  cancelled.
- `PullStage.swift:98`: "so `resumePoint` discards it". There is no `resumePoint`; the function is `plan`.
- `SyncEngine.swift:508–510` and `SyncScheduler.swift:154`: "what it fetched is staged". In fact the window in flight
  at cancellation is dropped, because its stage write throws `CancellationError`. That is exactly why RV6 stays
  green. Only completed windows are staged.
- `SyncEngine.swift:57–58`: "2,000 cut her … catch-up from ~550 calls to ~55" states a projection as a result. The
  live crossing with 2,000-row windows has not run yet.
- `LocalMachineryRecreation.swift`: its header and its function doc still say "the four tables". The registry now
  holds six. The staleness predates this diff, which adds the sixth.

### N2 [NIT] · `PullStage.swift:19–22` · the "ONE WRITER" assumption has a hole in its stated mechanism (SPECULATIVE reachability)

**What's wrong.** The doc says a retired chain is "drained before a replacement starts (`SyncSession.configure`)".
That holds only when `configure` finds an old scheduler. On the `stop()` → `configure()` road it does not:
- `stop()` retires inside an unstructured `Task` without a drain and sets `scheduler` to nil.
- So a later `configure()` sees `old == nil` and starts the new chain at once. Real cases: sign-out then sign-in, and
  `deleteAccount`'s wrong-password reconnect.

**The traced hazard.** The old round commits a STALLED apply after the new round has resumed from the old reach and
is still fetching. The new round would then apply only the windows staged after the clear, and could commit a cursor
past (stall, reach]. I could not make this reachable: D3's cancel plus GRDB 7's cancellable accesses roll back the old
apply within milliseconds of `retire()`. So this is hardening, with no production red-on-old pin.

**Proposed belt.** Inside the apply transaction, refuse if `cursor(db) != since`: throw and keep the stage, and the
next round re-plans. Optional.

### N3 [NIT] · `PullStage.swift:59–77` · write-path cost and disk footprint (not measured)

- `stage` compiles one `INSERT … ON CONFLICT` per row with `db.execute(sql:)`, and JSON-encodes inside the writer.
  `db.cachedStatement(sql:)`, with encoding done before the write, would shorten the writer hold. That is about 55
  windows of 2,000 rows on her corpus.
- The store has no `auto_vacuum` (no PRAGMA anywhere in `Sources`). After the first catch-up's apply deletes the
  stage, the freed pages stay in the file. That is a one-time growth of about the corpus re-encoded as JSON, and
  backups carry it. Worth one sentence in the record as an accepted consequence.

### N4 [NIT] · `notes/plans/fixes/vx-494-catchup-hang.md:3–8` · the record's STATUS header contradicts its own ruling

The header still says "the fix is the orchestrator's own hands (Fable at kickoff …)" and "the ladder is a fresh cold
reviewer (Sync/ — no waiver)". It also says "the cast note for the ladder is in OPEN ITEMS", but OPEN ITEMS has no
cast note. R-494-1 is the binding cast: Opus, plus the `opus-reviewer` ladder under her waiver. Fix the header so the
ladder's own legitimacy reads unambiguously.

## CLEAN BILL (specifically checked, found solid)

- **D2's semantics.**
  - The stage is a faithful cache of the state-based feed. A staged row whose server seq hasn't moved is exactly what
    a fresh fetch returns. Any later change gets a higher seq, is served again past `header.seq`, and replaces the
    staged copy (the upsert keeps the higher `server_seq`). The de-duplication yields exactly the shape a fresh round
    would see.
  - The resume point is a window boundary the old loop already used as a `since`. 13y's per-tenant, in-order commits
    plus the A5 horizon make the time between windows irrelevant.
  - A stall commit clears the stage, so the next round re-fetches from the stall exactly as before. That includes
    the janitor's orphan-heal road, which reads the stall report.
  - A rollback keeps the stage. The rollback is atomic, and `_sync_applying` is unwound.
  - The apply body is otherwise byte-identical.
- **Stage-write atomicity.** Each window's rows and its header land in one transaction, so a header can never claim
  rows that are absent.
- **Local-only registration is complete and registry-driven.**
  - It joins `SyncSchema.localOnlyTables`.
  - `LocalMachineryRecreation`'s DDL map matches it, pinned by `ddl.keys == localOnlyTables`.
  - `StorePlaintextExport` drops it, and `LibraryClassifier`'s export-vs-library test covers it.
  - `MigrationTests.expectedTables` was updated.
  - There is no `sync_version`, no outbox trigger and no lockstep event; marker 14 stands, matching the
    `protection_record` and MCP-grants precedents.
  - The schema landed in its own commit (`f6658017b`) before the code (`c1583de0b`).
- **D1.**
  - `sync_pull` returns one `jsonb` value (`13_phase13i_wings.sql:184–291`). PostgREST's max-rows cap does not apply,
    and there is no server-side clamp, so 2,000-row windows really are served.
  - The loop ends on an empty window whatever the page size.
  - The push chunk (200) is untouched, so the abuse guard's per-call relation stands.
  - The harness maps `pullWindowSize = batchSize`, so every soak's window count is unchanged.
- **D3.**
  - GRDB 7.11.1's async accesses are cancellable: `SerializedDatabase.execute` stores `db.cancel`, and later
    statements throw `CancellationError` (`Database.swift:1384–1428`). A retire during the 4-minute save therefore
    rolls back cleanly.
  - No `catch` in `Sync/` treats a `CancellationError` as a server verdict.
  - The lost-ack class it can produce is already covered (`FaultInjectionSyncTests`, `armDropAckOnNextPush`).
  - `loopTask` is set and cleared under actor isolation.
  - The trigger-after-retire guard is unchanged.
- **D3's dropped half is correctly reasoned.** `SyncRowFace.face` returns on `!isConfigured`
  (`SyncStatusViews.swift:128–132`) before it reads `isSyncing`, and `isConfigured` is `scheduler != nil`
  (`SyncSession.swift:45`).
- **The E2EE seam is intact.** Rows open before any write. The stage holds plaintext inside the SQLCipher store like
  every local row, is never a payload, and the export drops it.
- **P1.**
  - `plan` is O(1): an existence read and the header.
  - Staging, the read and the clear are proportional to the batch.
  - Ordinary empty-feed rounds add only O(1) reads.
  - Peak memory during a download is now one window, down from the whole feed.
- **The pins have teeth.**
  - I read each RV against the code. The D2 pin asserts both the resume point and that nothing restarts from 0.
  - The D1 pin exercises the production default through `SyncEngine.init`.
  - The D3 pin gates the first data call. `GatedSpyTransport` leaves the schema and challenge calls ungated, so
    `pulls == 1` is meaningful.
  - RV6's hollowness is honestly recorded.
- **Runs.**
  - `ResumableCatchUpTests`: 5/5 green.
  - Targeted sync sweep: 343 tests in 80 suites, green.
