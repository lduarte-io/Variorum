# Phase 5 — Sync core

## Kickoff message (for a fresh session)

> You are starting **Phase 5 of Variorum** — the sync engine: two devices converge on one store, per the settled protocol. Read, in order: `CLAUDE.md`, **`notes/SyncSpec.md` in full — it is authoritative for everything in this phase** (topology §2, client machinery §3, push §4, pull §5, merge matrix §6, repairs §7, ordering §8–9, what ships §10), `notes/AppSpec.md` §6 (conventions: sync_version, outbox-by-trigger, tombstones, live-row uniqueness), §7 (schema; local-only tables at the bottom), §9 (`resolveSyncConflict` — the one new operation this phase adds), §11, `notes/OverallModel.md` §6 (S1–S5), `Sources/VariorumCore/Persistence/Triggers.swift` + `AppDatabase.applyingRemote` + `Tests/VariorumCoreTests/TriggerTests.swift` (the Phase 1 machinery you build on: coalescing outbox, echo suppression, transition-guarded cascades — and the **Phase 1 trap**: any local write the engine makes on its own behalf, like the post-accept `sync_version` bump, must run in apply mode or the outbox re-enqueues forever), and the **Phase 4 closeout** at the bottom of `notes/plans/phase-04-read-layer.md` (your baseline: **`swift test` = 296 green in 28 suites on the M3 — do not re-run at session start**; the read side already tolerates missing/tombstoned referents, and Test Support has `unenforcedDatabase()` for materializing child-before-parent states). Key context: the server is deliberately dumb (CAS + `server_seq` changefeed, NO uniqueness constraints or FKs on mirrors — load-bearing, SyncSpec §2); all merge intelligence is client-side and deterministic; the whole correctness suite runs against an **in-process fake server** — no network, no Supabase account needed until the final integration step, which is an **author-assist gate** (pause and ask; never touch her accounts). Work step by step; each step lands with tests; when done, run the closeout ritual (results here, master plan table + pointer, Phase 6 — TK2 spike — plan + kickoff written from `notes/TEXTKIT2_NOTES.md` §2/§5 and AppSpec §4).

**Goal:** `VariorumCore/Sync` — push/pull engine over a protocol-shaped transport, apply mode, the full merge matrix, every SyncSpec §7 repair, conflict-as-variant — proven by two-client convergence suites against an in-process fake server, plus the Postgres mirror DDL ready for the author-assisted Supabase pass. No UI beyond nothing (a status indicator waits for the app shell); no accounts/RLS (Phase 14); no GC (Phase 12).

**References:** @notes/SyncSpec.md (all); @notes/AppSpec.md §6, §7, §9 (resolveSyncConflict), §11; @notes/OverallModel.md §6; Phase 1 trigger machinery; Phase 4 closeout (baseline + read-side tolerance).

---

## Ground rules

- **`server_seq` is the only ordering authority** — never wall clocks (SyncSpec §9). `sync_version` is a per-row CAS token, not an ordering.
- **Every engine-initiated local write runs in apply mode** (`applyingRemote`) except repair writes' explicit outbox enqueues (SyncSpec §7): repairs run *inside* the apply transaction where triggers are muted, so they `INSERT OR REPLACE INTO sync_outbox` directly — every repair test asserts the outbox row exists.
- **The fake server must be as dumb as the real one**: per-row CAS, global seq, no constraint checks, rejects carry the current server row. Anything smarter would hide client bugs the real server won't.
- **Determinism**: identical inputs on two clients must produce identical converged states, whichever order batches arrive. Convergence tests assert byte-equal synced-table dumps.
- **The transport is a protocol** (`push(batch)` / `pull(sinceSeq)`), so the fake server and the Supabase client are two implementations of one seam; the engine never knows which it's talking to.
- Payloads exclude `reference.file_bookmark` (local-only, AppSpec §7); `setting` is upsert-only and never tombstones (AppSpec §7); `commit_point` has no `deleted_at` by design.

## Steps

### Step 1 — Synced-table registry & row payloads
**Files:** `Sources/VariorumCore/Sync/SyncSchema.swift`, tests.
**Work:** the registry of the 13 synced tables (name, PK column, FK-dependency-friendly apply order, per-table quirks: setting upsert-only/PK `key`; reference's bookmark exclusion), and a `SyncRow` payload type — table + PK + column/value map (JSON-encodable; TEXT/INTEGER/REAL/NULL; BLOB only exists on the excluded column) + `sync_version`. Encode from a fetched `Row`, apply back with INSERT-or-REPLACE semantics.
**Tests:** registry vs live schema by introspection (every synced table registered, `sync_outbox`/`sync_state`/`_sync_applying` not, every registered table carries `sync_version`); payload round-trip per table (row → payload → row, byte-stable); bookmark excluded; setting payload sane.

### Step 2 — The fake server
**Files:** `Tests/VariorumCoreTests/Support/FakeSyncServer.swift`.
**Work:** in-process SyncSpec §2/§4 server: per-table row store, `sync_version` per row, one global `server_seq` stamped on every accepted insert/update, `push(batch)` → per-row `accepted(newVersion, seq)` / `rejected(currentRow)` (CAS: `base == current`), `pull(sinceSeq)` → rows with `server_seq > sinceSeq` ordered by seq. **No uniqueness, no FKs, no domain logic.**
**Tests:** CAS accept bumps + stamps; stale base rejects with the *current* row; interleaved pushes from two writers; pull ordering and cursor windows; tombstones are ordinary row updates to the server.

### Step 3 — Push engine
**Files:** `Sources/VariorumCore/Sync/SyncEngine.swift` (push half), tests.
**Work:** drain the outbox: snapshot outbox rows → load each current row (tombstoned rows included — a tombstone is a push) → batch → per-row result: accepted ⇒ write the server-granted `sync_version` locally **in apply mode** and clear the outbox row *only if it wasn't re-dirtied since the snapshot* (the dirty-row set contract; compare `queued_at` or re-check membership); rejected ⇒ hand to the merge (Step 5), which rewrites locally (re-enqueues via triggers) for the next cycle. Bounded retry loop per drain call.
**Tests:** **a full push cycle ends with an empty outbox** (the Phase 1 trap, SyncSpec §4 — the master-plan-named assertion); a row edited mid-push stays enqueued and re-pushes; reject → merge → converged re-push; batch spanning many tables.

### Step 4 — Pull engine & apply mode
**Files:** `SyncEngine.swift` (pull half), tests.
**Work:** `pull(sinceSeq)` → apply the batch in **one** `applyingRemote` transaction with `PRAGMA defer_foreign_keys = ON` set inside it: rows in `server_seq` order; locally-clean row ⇒ write verbatim + its `sync_version`; locally-dirty row (in outbox) ⇒ merge per §6 into the local row, keep enqueued; advance `sync_state.last_server_seq` **inside the same transaction** (cursor moves only on commit). Then run repairs (Step 6) before commit.
**Tests:** clean apply writes rows + versions and re-enqueues nothing (echo suppression, existing Phase 1 machinery observed end-to-end); dirty rows merge and stay enqueued; a failing row rolls back the whole batch *and* the cursor; parent-tombstone-before-children arrives fine (cascades are transition-guarded + idempotent — SyncSpec §3); child-before-parent within one batch commits under deferred FKs; the read layer renders gaps for cross-batch stragglers (already proven Phase 4 — one integration assertion here).

### Step 5 — The merge matrix + `resolveSyncConflict`
**Files:** `Sources/VariorumCore/Sync/Merge.swift`, `Sources/VariorumCore/Operations/Operations+Sync.swift`, tests.
**Work:** SyncSpec §6, rule by rule: insert-if-absent by PK; **`variant.working_text` conflict-as-variant (S5)** — server text wins the row, the losing local text becomes a new variant on the same block via `resolveSyncConflict(variant, losingText)` (AppSpec §9: same parent, `label='conflict'`; runs inside apply, so its outbox row is enqueued explicitly like a repair); metadata server-version-wins (CAS rebase); positions CAS with `(position, id)` determinism; **tombstone-wins except the rescue**: a `working_text` edit racing its variant's tombstone, block still live ⇒ rescue the edit as a conflict variant *before* honoring the tombstone; counters server-win.
**Tests:** each matrix row as a table-driven case; conflict-variant born with right parent/label/block and **nothing clobbered**; the rescue path; rescue skipped when the whole block died.

### Step 6 — Apply-time repairs (every live-unique index gets its rule)
**Files:** `Sources/VariorumCore/Sync/Repairs.swift`, tests.
**Work:** inside the apply transaction, after rows land: **I2 double-placement** (higher `server_seq` wins, loser tombstoned locally); **`tag.path` duplicate** (smaller id keeps, applications re-pointed, duplicate tombstoned); **pure duplicates** for `edge` triple / `reading_post` pair / `post_tag`·`block_tag` pairs (smaller id keeps; a reversed `version_of` pair is a duplicate); **I10 double-tombstone** (a live block left with zero live active variants ⇒ resurrect the tombstoned variant with the highest `server_seq`, status active, label `'rescued'`); **dangling `chosen_variant_id`** ⇒ NULL (read-time fallback already covers rendering; the repair makes convergence explicit), dead `default_variant_id` ⇒ reassign. Every repair write **explicitly enqueues its outbox row** past the muted triggers.
**Tests:** one test per repair asserting (a) the deterministic outcome, (b) both simulated devices converge to the same choice, (c) **the outbox row exists** (SyncSpec §7's standing requirement).

### Step 7 — Two-client convergence suites
**Files:** `Tests/VariorumCoreTests/SyncConvergenceTests.swift` (+ a small `SyncClient` test harness: an `AppDatabase` + device id + drain/pull helpers + a canonical synced-tables dump for byte-equality).
**Work/Tests (these are the phase's verification, from the master plan row):** offline edits on disjoint rows converge; same-row metadata race converges (server-version-wins); `working_text` race → conflict variant, no text lost; move/move race → single live placement via I2 repair; double-tombstone I10 race → deterministic resurrection labeled `'rescued'`; dangling-chosen race → NULL repair + fallback render; concurrent same-block divide → **documented duplication** (B₁C₁B₂C₂ — the SyncSpec §7 "documented, not a bug" outcome, so it is never a surprise); repairs' outbox rows push and the *other* device converges on them; **every scenario ends with both outboxes empty and byte-identical synced tables.** Add one long randomized soak: N random ops on each side per round, sync, assert convergence + invariant sweep predicates (reuse `InvariantSweepTests` predicates where exposed).

### Step 8 — Supabase mirror (AUTHOR-ASSIST GATE — pause here)
**Files:** `Server/supabase/` (mirror DDL + seq/CAS RPC functions as `.sql`), `Sources/VariorumCore/Sync/SupabaseTransport.swift` (the transport protocol's second implementation).
**Work:** generate the mirrored Postgres schema from the Step 1 registry (same columns; PK only; `server_seq BIGINT` + trigger from one global sequence; `sync_version`; **no other constraints**), `push`/`pull` RPC functions per SyncSpec §2/§4, and the URLSession transport against Supabase RPC with the single-user token. **Then stop and ask the author** (account, project creation, token — her credentials, her machine steps; KnownIssues owns this entry for Phase 5). With her: run one integration pass — the Step 7 basic offline-edit scenario against the real server.
**If the author is unavailable at this point,** everything author-independent above still closes green; report the gate at the checkpoint and leave Step 8's integration pass explicitly open in the closeout (the KnownIssues entry stays, still owned by Phase 5).

### Step 9 — Closeout
Ritual per CLAUDE.md: results + findings here; master plan table + pointer; any new deferrals only with owners; **write the Phase 6 (TK2 spike) plan + kickoff** from `notes/TEXTKIT2_NOTES.md` §2 (the viewport/height/scroll-to-location facts to establish, the 50k-word throwaway prototype, the canary) and §5 (per-version matrix), AppSpec §4 (what the spike must decide: live TK2 geometry vs stored-estimate scrubber vs STTextView) — the decision memo is the author's to accept (Phase 6-class gate, CLAUDE.md).

## Explicitly out of scope
Accounts/RLS/multi-tenant (14). GC/tombstone horizon (12). Sync UI (7+). Retry/backoff/network hardening beyond a bounded drain loop (12 hardening; the correctness suite is the phase's point). E2EE (14 decision).

## Risks / things to watch
- **The Phase 1 trap, generalized:** any engine write outside apply mode re-dirties what it just synced. The empty-outbox-after-push test is the canary; run it against every engine path that writes (accept bookkeeping, merges, repairs, conflict variants).
- **Clear-vs-re-dirty race on the outbox:** clearing an outbox row the user re-dirtied mid-push loses an edit forever. The dirty-row set semantics (snapshot, compare, clear-if-unchanged) must be tested with an interleaved write.
- **Repairs writing through muted triggers:** forgetting one explicit enqueue makes two devices *silently* diverge — the exact failure SyncSpec §7 flags. Every repair test asserts its outbox row; the convergence suite catches any missed one by byte-comparison.
- **`defer_foreign_keys` scope:** it resets at commit and must be set *inside* the apply transaction; verify with a child-before-parent batch test, and remember `_sync_applying` is a permanent main-schema table for exactly this class of reason (Phase 1 finding).
- **Fake-server fidelity drift:** the fake must stay dumber than you're tempted to make it. Any check it adds that Postgres won't have is a hidden client bug.
- **Determinism under batch splits:** convergence must not depend on batch boundaries; the soak test should randomize pull window sizes.
