# Why the phone's sync feels slow — a read-only trace (main at `37cf317fe`, phone build `fe1493c16`, previous `beb638033`)

Scope: read-only. No builds, no simulator, no device, no network or production reads. Every line cited was read on
`main`. Labels: **TRACED** = the code path and the constant were read; **INFERRED** = a reasoned consequence or a
magnitude not measured; **EXTERNAL** = an Apple or SQLite platform default, not set or checked in this repo.

## 0. The answer in five lines

1. **The phone runs the same sync engine and the same shared driver as the Mac**: the same 3 s settle, the same 2 s
   reachability debounce, the same 2,000-row pull windows, the same round. **Every Mac sync speed-up already lives in
   `Sources/VariorumCore`, `App/Variorum/Shared/` or on the server. All of them were already in the phone's old build
   `beb638033`** (table §3). There is nothing to port.
2. **Neither app pulls while it sits open.** No timer, no poll, no realtime socket, no push. A remote change is noticed
   only at a trigger (§1). The phone feels this more, because everything else below adds to each trigger.
3. **On the phone, under Castle, every trip out of the app locks the library.** Coming back means Face ID, then the
   store reopening cold, the services rebuilt, a new sync chain, and only then the first round. The Mac never locks on
   an app switch. Its became-active round runs on a live chain over a warm store.
4. **Every round makes at least 13 sequential HTTPS calls, even with nothing to send or receive.** That includes 5
   schema-version checks and 5 challenge fetches. A new edit's `sync_push` is the 9th or 10th call. After every clean
   round the purge janitor also does corpus-scale local reads: four full table scans, plus a savepoint-pruning
   aggregate. Every one of those reads sits behind a column that is stored after the text. Her phone already showed one
   round of "about a minute with nothing new to send" (sitting 1).
5. **The phone gets one round after she leaves the app, inside the iOS background grant.** If that round has not
   reached its push when the grant runs out, the edit waits for her next open and unlock. There is also no retry after
   a failed round on a working network, and no request timeout is set (URLSession's 60 s default applies).

---

## 1. The phone's sync driver, end to end

**Where it lives.**
- Engine: `Sources/VariorumCore/Sync/SyncEngine.swift`.
- Serializer and coalescer: `Sync/SyncScheduler.swift`.
- Purge janitor: `Sync/PurgeJanitor.swift`.
- Wire: `Sync/SupabaseTransport.swift` and `Sync/KeyProofChallenge.swift`.
- Shared driver: `App/Variorum/Shared/SyncSession.swift`, composed by `Shared/AppServices.swift`.
- Phone-only hooks: `VariorumMobile/VariorumMobileApp.swift`, `Features/Shell/MobileShellRouter.swift` and
  `Features/Protection/MobileRelock.swift`.

### 1a. Every trigger that starts a round on the phone

| # | Trigger | Where (file:line) | Cadence / debounce | Notes |
|---|---|---|---|---|
| T1 | **Launch, and every unlock** — the services' start composes the chain, then triggers once | `VariorumMobileApp.swift:104-156` (`.task` → `fresh.start()` :156) → `AppServices.start()` `AppServices.swift:298-324` → `connectSyncIfAllowed()` :518-547 → `sync.triggerSync()` :546 | immediate, after owner adoption (`runOwnerAdoption` :584) and `configure` | Under Castle, this is the ONLY road to a round after a return (T5's row). |
| T2 | **Local writes settle** — an observation of `SELECT COUNT(*) FROM sync_outbox` | `SyncSession.swift:230-242`; debounce `settleDebounce = .seconds(3)` :141, `scheduleSettleTrigger` :418-425 | **3 s**, restarted by each emitted change | The observation is `.removeDuplicates()` (`AppDatabase.swift:266-269`), so it fires only when the COUNT changes. More typing in the same take re-dirties the same outbox rows and does not restart the 3 s. Upstream: autosave trailing debounce **500 ms** (`AutosaveCoordinator.swift:127`, :155-162; phone editor `MobileEditorViewModel.swift:229`; quick note `MobileQuickNote.swift:326`, with its mint delay 1,000 ms at :319). |
| T3 | **The network comes back** (`NWPathMonitor`) | `SyncSession.swift:251-266`; `reachabilityDebounce = .seconds(2)` :143; wired on both platforms (`AppServices.swift:179`, `SystemNetworkPath`) | **2 s**, cancelled if the path drops again | Fires only on not-satisfied → satisfied. The first reading never fires, and a change from one working path to another (Wi-Fi to cellular) never fires. |
| T4 | **Configure's first outbox reading** | the same observation (`SyncSession.swift:232-237`) emits the current count at once | 3 s | When rows were left unpushed before a lock, a second round runs 3 s after T1's. |
| T5 | **Scene becomes `.active`** | `MobileShellRouter.swift:394-403`, called from `VariorumMobileApp.swift:229-281` | immediate | **Standard:** one round. **Castle after a real background:** the lock already released the services (`VariorumMobileApp.swift:143-155`), so `services?.sync` is nil, nothing fires here, and the round comes from T1 after Face ID. **Castle with no background** (Control Center, Notification Center, a system alert: `.inactive` → `.active`): `leftAt` is nil, `didReturnToTheScreen` returns false (`MobileRelock.swift:138-145`), and a round fires on the live chain. This is a free manual "pull" today. |
| T6 | **Scene goes `.background`** — the leaving flush | `MobileShellRouter.swift:404-437` → `performBackgroundFlush` :286-355 → `sync.flush()` :354 (`SyncSession.swift:354-366`) | one round, awaited, inside `beginBackgroundTask` (:417-418; expiry → `work.cancel()` :436) | Order: quick note filed → editors flushed → leaving savepoints → the round. **Then the Castle lock** (`relock.didLeaveTheScreen()` :429 → `MobileRelock.swift:126-131`). |
| T7 | **Manual: Settings ▸ Sync ▸ "Sync now"** | `SyncStatusViews.swift:268-269`, :735-749 | immediate | The sync row lives only in the Settings sheet (audit D-37). |
| T8 | **The scheduler's own follow-ups** | `SyncScheduler.swift:150-158` (a trigger mid-round becomes exactly ONE follow-up), :200-210 (loop), :321-327 (one-writer belt refusal: one immediate follow-up, once), :298-302 (orphan heal) | immediate | No back-off and no timer anywhere. |
| T9 | **Account acts** (`runFirstRound`, `resumeSync`) | `AppServices.swift:553-574` | immediate | rare |
| — | **Timer / poll / realtime / websocket / silent push / `BGAppRefresh`** | none. A grep over `App/` and `Sources/` found none; audit D-44 says the same | — | **ABSENT.** |

### 1b. What stops or suspends rounds on the phone

- **Backgrounded:** after T6's round, iOS suspends the process, and no round runs until the next foreground (TRACED:
  D-44, no background modes). The grant is iOS's usual ~30 s (EXTERNAL).
- **The Castle lock on every leaving:** `MobileRelockPolicy.locksOnLeaving` = `policy != nil` (`MobileRelock.swift:50-52`),
  which means every Castle background locks.
  - The lock's teardown stops and releases the services (`mobileWillLock` :80-96, `VariorumMobileApp.swift:143-155`).
  - `SyncSession.stop()` retires the scheduler and cancels any round in flight (`SyncScheduler.swift:184-189`).
  - The save is shielded from that cancel; the download resumes from the stage next time.
- **The restore hold:** Mac-only (the phone's `roundsHeld` is nil).
- **Low power:** nothing in the code reads it.
- **File protection:** a store cut off by iOS data protection fails the round like being offline
  (`VariorumMobileApp.swift:250-255` comment; `SyncScheduler.swift:309-314`).

### 1c. A local edit: how long until it is pushed (TRACED path, INFERRED durations)

`keystroke → 0.5 s pause (autosave) → outbox count changes → 3 s settle → triggerSync → beforeRound (flush pending
typing) → round`. Inside the round, the order is pinned (`SyncScheduler.swift:239-266`) and the push comes after the
pre-pass and the pull. Exact calls (§4a): pre-pass 3 → pull 3 (+1 if anything arrived, + the apply of what arrived) →
push's own 2 → **`sync_push` = sequential call #9, or #10 if anything arrived.**

- **Best case:** ≈ 3.5 s plus 8–9 sequential calls on her network, plus the apply time of any backlog from the Mac.
- **When a round is already running** (common while typing): T2 only sets the follow-up flag. The edit waits for the
  whole current round to finish, including the janitor sweep (6 more calls, the scans, any per-family purge calls), then
  the follow-up's 9 calls.
- **Leaving the app:** T6's round has to get through 9 calls before its push and before the grant ends. Otherwise the
  edit stays on the phone until the next open (under Castle, the next unlock). §5, cause 4.

### 1d. A remote change: what makes the phone notice it

Only T1–T9. **While the app is open and idle, nothing.** The worst case is unbounded until she types, switches away
and back, bounces Control Center, presses Sync now, or the network path drops and returns.

- **While she types:** a round starts ~3 s after the outbox first goes non-empty, and the next one needs another
  count change. So she receives about once per (3 s + one round's duration). If a round is ~60 s, that is about once a
  minute.
- **At an open under Castle:** Face ID, then "Unlock → library open", then the shell and the services' start, then the
  first round's pre-pass (3 calls) and pull (3–4 calls) and the apply. Only then does a listing re-fetch show the
  change.

---

## 2. The Mac's driver, and the side-by-side

The Mac composes the same `AppServices` and `SyncSession` (`Variorum/VariorumApp.swift:250-309`). Its only
platform-owned trigger is `NSApplication.didBecomeActiveNotification → services?.sync.triggerSync()` (`VariorumApp.swift:375-382`).
macOS does not suspend the app, so T2/T3 rounds run whether Variorum is frontmost or not. Castle re-locks the Mac on
sleep, on screen lock and after its idle minutes, **never on an app switch** (`ProtectionController.swift:80-138`).

| Aspect | Phone (`VariorumMobile`) | Mac | Same? |
|---|---|---|---|
| Engine, scheduler, janitor, transport | `Sources/VariorumCore/Sync/*` | same | **same code** |
| Post-write settle (T2) | 3 s, count-change only | 3 s, count-change only | same |
| Autosave debounce | 500 ms | 500 ms (`AppSession.swift:311`) | same |
| Reachability (T3) | 2 s, not-satisfied → satisfied | same | same |
| `beforeRound` occasion | typed-unlock key retry, then a typing flush (`AppServices.swift:263-266`) | same | same |
| Pull window / push chunk / push iterations | 2,000 / 200 / 5 (`SyncEngine.swift:130-131`) | same | same |
| Launch/unlock round (T1) | after **every** Castle return (services rebuilt) | at launch, and after a sleep, screen-lock or idle unlock | **differs in frequency** |
| Coming back to the app | `.active`. Under Castle after a background there is no live chain, so the round waits for Face ID → store reopen → services start (T1) | `didBecomeActive` → a round on the live chain at once | **differs** |
| Leaving the app | one awaited round inside the iOS grant (~30 s, EXTERNAL), then the Castle lock | nothing special; T2 rounds keep running in the background | **phone only** |
| Rounds while not frontmost | none (suspended) | yes (T2/T3/T8) | **differs** |
| Store warmth for the janitor's scans | reopened, so its page cache starts cold, at every Castle return | open for days, warm | **differs** |
| Lock on an app switch | yes, under Castle (`MobileRelock.swift:50-52`) | no | **differs** |
| Sync row visibility | Settings sheet only (D-37) | sidebar row | differs (perception) |
| Manual Sync now | Settings sheet | sidebar row | same door |
| Restore-hold gate | nil | wired (`VariorumApp.swift:273-283`) | Mac only, not speed |
| Timer / poll / realtime / push | none | none | **same gap** |
| Sync keys per round | session memory under Castle, else the silent Keychain item (`NewRoadSyncKeyProvider.swift:43-57`); 5 `currentKeys()` calls per round | same | same |
| Timing readout | VM-65 records (Settings ▸ Diagnostics ▸ Timing…) | recorder disabled | phone only |

---

## 3. The Mac's sync speed work: where it lives and whether the phone has it

The pre-flip SHAs quoted in the records do not resolve in this public repo. These are the public-history SHAs, and
ancestry was checked with `git merge-base --is-ancestor` against `beb638033` and `fe1493c16`.

| Fix | What it did | Where it lives | In the phone's old build `beb638033`? | In the phone now `fe1493c16`? | Needs phone work? |
|---|---|---|---|---|---|
| VX-494 D1 | pull window 200 → 2,000 rows (~550 calls → ~56 on a ~108k catch-up) | Core `Sync/SyncEngine.swift` (`3376416cc`) | yes | yes | no |
| VX-494 D2 | staged, resumable download (`sync_pull_stage`, v1_32) | Core `Sync/PullStage.swift`, `Persistence/Migrations.swift` (`674039b87`, `3376416cc`) | yes | yes | no |
| VX-494 D3 + R3-1 | a retired round stops between windows; the save is shielded | Core `Sync/SyncScheduler.swift` (`6c36b485d`), `SyncEngine.swift` | yes | yes | no |
| VX-495 SHAPE B | server `sync_pull` keyset pages (her probes 3,398 → 230 ms); `sync_pull_remaining` added | **server** (`Server/supabase/maintenance/vx495-pull-keyset.sql`, deployed 2026-11-02 00:41 UTC) | n/a — serves every client | n/a | no |
| VX-496 | catch-up progress ("Syncing — N of M") | Core engine seam (`73bed0213`) + Shared row words (`0fa077e0f`) | yes | yes | no (perception only; the phone's row is Settings-only) |
| VX-505 / R2-6 | the one-writer belt's "retrying" face + one immediate follow-up | Shared (`77025ff16`) + Core scheduler | yes | yes | no |
| VX-720 | v1_36 FK child indexes: first catch-up's save 330 s → 89 s | Core `Persistence/Migrations.swift` (`feca3bfd7`) | yes | yes | no |
| VX-497 | the save's single all-or-nothing transaction | **not fixed** (open; absorbed by VM-184) | — | — | it is VM-184 |
| VX-544 | reachability trigger | Shared `SyncSession.swift` (`95a5a053c`) | yes | yes | no |
| VX-544 P-849-3 | typed-unlock key retry, wired on the phone | Shared (`37e3bcd32`) | yes | yes | no |
| VX-683 A | `beforeRound`: pending typing lands before each round | Shared (`10786f0e7`) | yes | yes | no |
| VX-683 B / VX-402 | guarded autosave rescue; honest flush (correctness, not speed) | Core (`9911b28b2`), Shared (`9a080c366`) | yes | yes | no |
| VM-67 (phone-motivated, shared) | owner adoption probes a partial index before writing (Mac: 11.14 → 0.79 ms at 61.7k rows) | Core `Operations/OwnerIdentity.swift` (`e6d16fca7`) + v1_38 | **no** | **yes** | shortens the wait before the first round after each unlock; VM-64 showed it is **not** inside the round |

**Conclusion:** nothing Mac-only made the Mac's sync faster. Today's phone build carries every one of these.
Nothing in `Sources/VariorumCore/Sync/` changed between `beb638033` and `fe1493c16` (`git diff --stat` empty). The
other sync-path changes in that range are the VM-65 timing marks and VM-67.

---

## 4. What one round costs, on the phone

### 4a. The calls, exactly (TRACED)

A round with nothing to send and nothing to receive (`SyncScheduler.runOneRound`, `SyncScheduler.swift:212-334`):

| Step | Calls (sequential) | Where |
|---|---|---|
| Pre-pass `janitor.reconcileLedger()` | 1 `sync_schema_version` (preflight) · 2 `sync_challenge` (new signer, batch of 8) · 3 `sync_purge_ledger` | `PurgeJanitor.swift:297-317`, preflight :87-104 (`schemaVersion` :97) |
| `engine.pull()` | 4 `sync_schema_version` · 5 `sync_challenge` (its own signer) · 6 `sync_pull` → empty → stop | `SyncEngine.swift:582-666` (`verifySchemaLockstep` :591, :955-961; window loop :643-693) |
| `engine.push()` | 7 `sync_schema_version`; empty outbox → no further call | `SyncEngine.swift:227-254` (:236) |
| `janitor.sweep()` (after every CLEAN round) | 8 `sync_schema_version` (preflight) · then `reconcileLedger()` AGAIN: 9 `sync_schema_version` · 10 `sync_challenge` · 11 `sync_purge_ledger` · then 12 `sync_challenge` · 13 `sync_horizon` | `PurgeJanitor.swift:132-158` (re-runs reconcile at :145) |
| + per eligible synced family | one `sync_purge_execute` each, serially, plus one local write transaction each | `PurgeJanitor.swift:223-247` |

- **Floor: 13 sequential HTTPS calls**: 5× `sync_schema_version`, 5× `sync_challenge` (one per signer,
  `KeyProofChallenge.swift:56`, :96-98), 2× `sync_purge_ledger`, 1× `sync_pull`, 1× `sync_horizon`.
- **When rows arrived:** +1, because the pull loop breaks only on an EMPTY window (`SyncEngine.swift:666`), so any
  arrival costs a second `sync_pull`.
- **When there is something to push:** +2 (`sync_challenge` + `sync_push`) per 200-row chunk, per push iteration
  (≤ 5).
- **Every call:** `URLSession.shared` (`SupabaseTransport.swift:56`) with **no timeout set** (`send` :334-352;
  grep finds no `timeoutInterval` anywhere). The 60 s default per request applies (EXTERNAL).
- **Auth:** the token is cached in memory and refreshed single-flight (`AuthSession.swift:621-656`), so a refresh
  costs an extra call only after expiry.
- **Server side:** every gated call runs `sync_key_gate` (a nonce consumed, the proof checked against the Vault-held
  secret). `sync_purge_ledger` reads the caller's `purged_row` partition by its PK prefix and filters `purged_seq`. No
  `(owner_id, purged_seq)` index was found (`10_phase13j_purge.sql:189-195`, `11_pre13x_postures.sql:647-668`). That
  is a small cost, INFERRED, paid twice a round.

### 4b. What scales with the library rather than the change (P1)

All of this runs after every clean round, on GRDB's reader (off main):

1. **`collectRoots`: four full scans** (`PurgeJanitor.swift:393-425`): `container`, `reading`, `block` and `variant`
   `WHERE deleted_at IS NOT NULL AND deleted_at < cutoff`.
   - No index serves `deleted_at IS NOT NULL`. The `deleted_at` indexes are partial on `IS NULL`; `idx_cblock_dead_block`
     is on `container_block`. TRACED, and the VM-64 record agrees (§7 batch 4, lines 2235-2238).
   - **`variant.deleted_at` comes after `working_text`** in the DDL (`Migrations.swift:1329-1341`). A row whose text
     spills past the page has its overflow chain walked to reach the column, so the scan reads about all the
     library's take text. That is SQLite's record format, EXTERNAL; the magnitude is INFERRED.
2. **Per root, a family expansion and a verdict, serially** (`PurgeJanitor.swift:178-251`).
   - Every 30-day-old tombstone still present is re-collected and re-judged each round.
   - The horizon is `min(last_seq)` over device cursors seen in the last 60 days (`11_pre13x_postures.sql:635-638`). A
     device that synced rarely holds every family at `.deferred`, so they are re-expanded every round. INFERRED, and
     the counts are unknown.
3. **Savepoint pruning** (`PurgeJanitor.swift:263-274` → `prunableSavepoints` :636-677). It runs because the default
   is `.standard` (`Queries/IdleCommit.swift:96-99`).
   - It joins every live `variant` to its `commit_point` rows with `kind='auto'`, then `GROUP BY` + `HAVING COUNT(*) > 10`
     + `LIMIT 64`.
   - **`commit_point.kind` comes after `text`** (`Migrations.swift:1351-1358`), so each joined savepoint's text is read
     to test its kind.
   - The candidates are the first 64 variant ids with more than 10 quiet savepoints, whether or not anything is old
     enough (90 days, `SavepointPruning.swift:19`). The same 64 can be re-read every round. TRACED shape; INFERRED
     size.
   - **VM-182's title covers only "deleted rows". This scan is not ticketed anywhere I found.**
4. Everything else in a round is ∝ the batch or the outbox: the apply, the repairs (`Repairs.swift:754+`), the push
   bookkeeping. The ledger pass is ∝ new ledger entries. The empty-pull dedupe check is one marker read.

### 4c. Main actor, and what the phone wraps around the round

- **Nothing in the round runs on the main actor.** The scheduler is its own actor, and the engine's and janitor's
  reads and writes are async GRDB calls. `SyncSession`'s status stream and outbox loop resume on main but are trivial.
  The main-thread cost a round sets off is UI: the push's `sync_version` bump re-delivers the open note (VM-178,
  "aftershock"), a typing hitch rather than sync latency.
- **Keychain per round:** `currentKeys()` is called 5× per round. Under Castle, Face ID loads the keys into session
  memory (`NewRoadSyncKeyProvider.swift:13-20`, :48-49), so there is no Keychain read. In Standard each call reads the
  silent item. That is milliseconds, not the lag. No Face ID prompt per round.
- **The cold store:** under Castle, each return reopens the encrypted store, so the first round's scans in §4b read
  from flash and decrypt every page. TRACED (the lock closes the pool); INFERRED size.
- **The background grant:** §5, cause 4.
- **Retry and back-off: none, by design** (`SyncScheduler.swift:309-314`: "the next trigger retries"). The only
  automatic retry is the one-writer belt's single immediate follow-up (:321-327).
  - So there is **no long back-off** to explain the lag.
  - Instead, a failed round on a working network (a 60 s request timeout, a 5xx) waits for the next T1–T9. Nothing
    fires while the app sits open.

---

## 5. Ranked candidate causes of the lag she feels

The ranking is my estimate of what she most plausibly feels. The confirming measurement is chosen to use what the
phone already shows: the Settings ▸ Diagnostics ▸ Timing… rows "Sync round", "Sync round: rows sent (about)", "Sync
round: changes received (about)" and "Unlock → library open / Library ready" (`MobileTimingView.swift:47-70`), and the
Sync row.

| Rank | Cause | Status | Worst-case latency it implies | One measurement on her phone |
|---|---|---|---|---|
| 1 | **No pull while the app is open.** A change made on the other device is heard only at a trigger (§1d); the phone sitting open never asks. The Mac has the same gap, but she switches into the Mac constantly (each switch = `didBecomeActive` = a round). | TRACED | Unbounded while the phone sits open and idle; otherwise until her next write (+3 s), return, Control Center bounce or Sync now | Phone open on the Library, not typing. Change a note on the Mac and wait two minutes. The change does not arrive, and the readout's "Sync round" count does not move. Then pull Control Center down and back (no background, so no lock): the change arrives after one round. |
| 2 | **Castle locks on every leaving, so every return is a full rebuild before the first round** (Face ID → cold store reopen → shell → services start → configure → round) | TRACED (mechanism); INFERRED (size) | Face ID + "Unlock → library open" + services start + the round's first 6–7 calls + the apply, on EVERY return | Readout "Unlock → library open" and "Unlock → Library ready". Then compare how long a Mac change takes to appear after a full app switch (it locks) against a Control Center bounce (it does not). |
| 3 | **The round's floor is 13 sequential calls plus local corpus scans; an edit's push is call #9–10, and a trigger mid-round waits a whole round first** | TRACED (count, order); INFERRED (time per call) | Floor ≈ 13 × (her RTT + server time). Her phone showed ~1 min with nothing to send (sitting 1). A coalesced edit waits ≈ one round + 9 more calls. | Press Sync now three times in a row with nothing changed; each readout "Sync round · last" is the floor. Do it once on Wi-Fi and once on cellular: if the floor follows the network, the call count dominates (cause 7). If the first press after an unlock is much slower than the second, the cold local scans dominate (cause 6). |
| 4 | **The leaving round vs the iOS grant.** T6's round must get through 9 calls before its push and finish before ~30 s (EXTERNAL). `sync.flush()` awaits `awaitIdle()`, which is not cancellable, so the expiry's `work.cancel()` cannot stop it. The process is suspended mid-round. **Side effect (TRACED sequence, INFERRED frequency):** on resume the round finishes, then `relock.didLeaveTheScreen()` (`MobileShellRouter.swift:429`) locks the library just after she came back, and the next round waits for another unlock. | TRACED mechanism; INFERRED how often | Phone → Mac: until her next open and unlock of the phone | Type a sentence on the phone, press the side button within ~3 s, click into the Mac within a minute. If the sentence is missing until the phone is opened again, this is confirmed. Readout: a "Sync round" max of minutes is the suspended-then-resumed round. |
| 5 | **A failed round is never retried on a working network**, and requests have no timeout of their own (URLSession's 60 s default, EXTERNAL) | TRACED (no retry, no timeout set) | Up to ~60 s per stalled call, then the outbox waits for the next trigger | Sync row showing "· N pending" or the waiting face after a round. Readout "Sync round" values clustered at ≥ 60 s. |
| 6 | **The janitor's corpus-scale reads after every clean round** (§4b: four tombstone scans, per-root family verdicts, the savepoint-pruning aggregate), paid cold after each unlock | TRACED shape; INFERRED size | Adds to every round's END (not before its push); delays the next coalesced round; with eligible families, one serial `sync_purge_execute` each (VX-672/VM-183: "minutes") | The cold-vs-warm Sync now comparison in rank 3. The readout cannot split it further; that needs VM-232's in-round marks. |
| 7 | **Redundant fixed calls:** `sync_schema_version` ×5, `sync_challenge` ×5, the sweep's second `reconcileLedger` (2 calls) | TRACED | ~7 of the 13 floor calls; 2 of them sit before the push | Same as rank 3 (Wi-Fi vs cellular floor) |
| 8 | **The 3.5 s floor:** autosave 0.5 s + settle 3 s before any push | TRACED | 3.5 s per push, both platforms | Not worth measuring alone; it is the constant floor |
| 9 | **A narrow stranding:** if every push iteration (≤ 5) sees the same rows re-dirtied mid-call, the outbox COUNT ends unchanged and `removeDuplicates` emits nothing, so no settle trigger follows | TRACED; rare (continuous typing through five calls) | Until the next count change or trigger | The Sync row's "· N pending" staying after she stops typing |
| — | Not a cause: owner adoption (it runs before the round; VM-67 made it ms), Keychain reads (session memory under Castle), the main actor | TRACED | — | — |

---

## 6. Shape of each fix, and whether it touches `Sources/VariorumCore/Sync/`

| Cause | Fix shape | Touches `Sync/`? | Existing ticket |
|---|---|---|---|
| 1 | A foreground-only cadence while a chain stands and the scene is active (e.g. every 30–60 s), plus a round when a note opens. It would be much cheaper as a probe: `sync_pull_remaining` already exists server-side (an index-only count, VX-495/496), so a poll of 2 calls (challenge + count) could run the full round only when it answers > 0. Realtime (Supabase socket) or silent push (APNs) are bigger: a server artifact, and a new dependency or entitlement, which is her call. | Timer: **no** (`Shared/SyncSession.swift` or the phone shell). The probe: **yes** (a public engine entry, so the app does not bypass the engine). | **none found** |
| 2 | VM-105: keep the library open across app switches for the dial's minutes, and lock on a full close. Then `.active` runs a round on a live chain over a warm store, like the Mac. | No `Sync/` line, but protection/custody (CastleRules, Fable review class) | **VM-105** (+ VM-25, VM-104 first), wave 2, umbrella VM-103 |
| 3, 7 | One schema check per round (or per chain with a short TTL). ONE challenge signer per round shared by the pre-pass, pull, push and sweep (8 nonces cover it). Drop the sweep's second `reconcileLedger` when the pre-pass ran this round. End the pull loop on a short window rather than an empty one, after checking the A5 horizon. An empty round goes from 13 calls to ~6, and an edit's `sync_push` from call #9 to ~#5. The pull → push order (A3) and the pre-drain ledger pass (B2) stay. | **yes** (`SyncEngine`, `PurgeJanitor`, `SyncScheduler`); Fable review | **none found** |
| 4 | Bound the leaving: on grant expiry, retire the chain (`sync.stop()`) so `awaitIdle` returns and the lock lands before suspension, not after her return. Trimming the round (3/7) makes the push land inside the grant more often. Skipping the janitor sweep on the leaving round would also shorten it. | Retire on expiry: **no** (phone driver, `MobileShellRouter.swift`, touching the lock order, so VM-103's surface). Skip-sweep option: **yes** (scheduler). | not ticketed as such (audit F 6B notes "the grant can expire; the lock leg runs anyway") |
| 5 | Give the transport a configured `URLSession` with a request timeout (~15–20 s). `SupabaseTransport.init(configuration:sessionProvider:session:)` already accepts one, and `AppServices.makeSyncTransport` composes it. Add a bounded retry while the scene is active after a failed round (e.g. 10 s, then 30 s). | **no** (app composition plus `Shared/SyncSession.swift`) | **none found** |
| 6 | Take the sweep off the every-round path: run it at most every N minutes or hourly, and once per launch/unlock. Keep the pre-drain ledger pass. Serve the tombstone collection with local-only partial indexes `WHERE deleted_at IS NOT NULL` (the v1_34/36/38 precedent: not a §12 event). Re-shape the savepoint-pruning candidate query so it does not aggregate every take's savepoints each round. | Cadence: **yes** (`SyncScheduler`/`PurgeJanitor`). Indexes: no (Persistence). | **VM-182** (tombstone scans); **VM-183** (= VX-672, post-purge minutes); the pruning aggregate is **not ticketed** |
| measure first | VM-232: per-phase marks inside the round plus exact sent/received counts, so the "minute with nothing to send" can be split. The `ApplyProfileHook` seam (`Sync/ApplyProfile.swift`) already times the pull's phases and is nil in production; the RPC-level split needs new marks. | **yes** | **VM-232** (Todo; minted by VM-64, **not seated under any umbrella**) |
| perception | Sync status outside Settings | no | **VM-201** (wave 5) |

Already scoped in VM-176 "Speed, second pass" (wave 4, the ⚑ sync slot, blocked on VM-65's numbers):
- VM-182 (tombstone scans each clean round)
- VM-183 (post-purge minutes, VX-672)
- VM-184 (the catch-up save holds the writer, VX-497)
- VM-178 (the push re-delivers the open note; UI, not latency)
- the editor and layout members VM-177, 179, 180, 181 and 185

**Not scoped anywhere I found:**
- the while-open pull cadence (1)
- the redundant fixed calls (3/7)
- the request timeout and retry (5)
- the leaving-round-vs-grant ordering (4)
- the savepoint-pruning aggregate (6)

VM-232 exists but is unseated.

---

## 7. What VM-64 measured and changed about sync

- **It wrote no `Sync/` line** (its FOR A LATER READER).
- **VM-65's readout times a round whole**, from the status turning to syncing until it stops. It is started and
  stopped from the scheduler's public status (`SyncSession.swift:451-503`). The counts are "about": sent is the
  outbox's drop and received is the cursor's advance (P-65-7).
  - The catalog: `ownerAdoption`, `ownerAdoptionRows`, `syncRound`, `syncRoundSent`, `syncRoundReceived`, plus the
    launch and unlock spans (`AppTiming.swift:63-92`).
  - Each series is its own 64-entry ring, so a slow round and its counts are paired only by reading "last" right after
    the round.
  - The recorder is inert on the Mac.
- **VM-67 shortened the gap before the first round after each unlock** (owner adoption no longer scans eleven tables).
  The record answered "does adoption explain the minute-long empty round?" **No**: it returns before the round starts.
  It listed what the round does instead: ~8–10 challenge-signed calls, the pull, the sweep's four full tombstone scans
  on a cold store, and the per-family purge calls (`vm-64-timing-and-lags.md:2223-2263`).
- **Born ticket:** VM-232 ("Time a sync round in its parts…", needs a `Sync/` line and a Fable review).
- **Handoff line:** "The minute-long sync round with nothing to send is not this run's to fix" (`notes/handoffs/vm-64-handoff.md:112`).
- **Her numbers from the wave-1 install are the baseline VM-176 ranks from.** None are in the repo yet.

---

## 8. What I could not determine

- **The real round duration and its split on her phone.** The readout exists from `fe1493c16`, but no numbers are in
  the repo, and the split needs VM-232.
- **Her network's round-trip time and the server's time per gated call** (`sync_key_gate`, Vault decrypt, nonce
  bookkeeping). So the 13-call floor cannot be turned into seconds.
- **Her store's sizes:** variant/commit text bytes, 30-day-old tombstone roots, deferred families per round, purge
  intents, savepoints per take. These set §4b's cost.
- **Whether the purge horizon is held back** by a rarely-seen device's cursor (it needs a production read of
  `device_cursor`, which is hers or needs her approval).
- **Whether her complaint is Mac → phone, phone → Mac, or both.** The causes rank differently: 1/2 for Mac → phone;
  3/4/5 for phone → Mac.
- **Whether she runs Castle today.** Memory and audit D-23 say Castle + Face ID; I did not verify it from the device.
- **The exact iOS background-grant length on her phone** (EXTERNAL, typically ~30 s), and whether the grant actually
  expires in her leavings.
- **Whether the ~1-minute round she saw at sitting 1 had a backlog to receive.** "Nothing new to send" says nothing
  about what it pulled.
- **Whether App Nap delays the Mac's background settle timer** (irrelevant to the phone; not checked).
