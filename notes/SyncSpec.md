# Variorum — Sync Spec

**Status:** the settled sync architecture, designed up front (author's call, 2026-07-04: sync is *not* a commercial-phase afterthought — iOS journal capture syncing to the Mac is wanted early, and the hard design should be done now). Built at its phase in `DetailedPlanForPhases.md`; every schema/operation decision before that phase must honor this document.
**Scope now:** one author, few devices (Mac + iPhone), local-first, offline-tolerant. **Scope later:** multi-tenant commercial (accounts phase adds `owner_id` + RLS on the same protocol — no redesign).

---

## 1. The decision: hand-rolled row sync over Supabase/Postgres

**Chosen:** a hand-rolled, state-based row-sync protocol — rich local SQLite kept exactly as designed (FKs, triggers, partial unique indexes), mirrored tables in Postgres (Supabase), a deliberately *dumb* server (compare-and-set + monotonic changefeed), and all merge intelligence in the client where the domain lives.

**Why not the alternatives (evaluated 2026-07):**
- **PowerSync (the original spec's assumption):** its default client storage is schemaless JSON exposed through SQLite *views* — foreign keys, custom indexes, triggers, and CHECK constraints are unavailable, which deletes the DB-enforced invariants this schema was chosen for (I2's live-unique ownership, RESTRICT guards, cascade triggers). Its "raw tables" escape hatch is experimental and puts schema/trigger management back on us anyway — at which point the engine's remaining value (transport + changefeed) is nearly free with Supabase directly.
- **ElectricSQL:** current architecture is read-path sync; writes go through your own API anyway — half the problem unsolved.
- **CRDT stores (cr-sqlite, Automerge):** character/row CRDTs over-merge prose (word salad) and fight rows-as-truth; conflict-as-variant is semantically better for this domain (settled in OverallModel §8).
- **CloudKit:** free transport for the personal phase, but wrong shape for the committed commercial future (single-account device sync, no server-side logic), and switching transports later means building sync twice. Still rejected.

**Why hand-rolling is tractable here (this is the schema's whole design):** exactly one mutable text field (`variant.working_text`); everything else is inserts, tombstones, and small metadata updates; mobile's surface is deliberately narrow (create entries, edit active text); tombstones + UUID PKs + tiny writes (S1–S3) were baked in from day one. The conflict surface is small *by design*, not by hope.

## 2. Topology

```
SQLite (Mac) ──┐                        ┌── SQLite (iPhone)
   outbox push ├──► Supabase Postgres ◄─┤ outbox push
   pull cursor ◄──── mirrored tables ───► pull cursor
                     + server_seq changefeed
```
- Server: one Postgres table per synced client table, same columns, plus `server_seq BIGINT` (global monotonic, stamped by trigger from one sequence on every insert/update) and `sync_version INTEGER` (incremented on every server-accepted change).
- **The mirror tables carry NO uniqueness constraints beyond the PK and NO foreign keys.** This is load-bearing, not laziness: the whole repair design (§7) requires the server to dumbly accept both sides of a race (two live placements for one block, dangling references mid-batch) so clients can repair deterministically. Mirroring the client's live-unique indexes or FKs onto Postgres breaks convergence. (Review finding #5, 2026-07-04.)
- Two endpoints (Supabase RPC / edge functions): **push(batch)** and **pull(sinceSeq)**. No server domain logic beyond compare-and-set.
- Auth: single-user token now; accounts phase adds `owner_id` population + RLS partitioning of the same endpoints.

## 3. Client-side machinery (lives in schema v1 — this is why sync is designed now)

- **`sync_version INTEGER NOT NULL DEFAULT 0`** on every synced table (AppSpec §6): the row's last server-accepted version; the CAS token for pushes.
- **`sync_outbox(table_name, row_id, queued_at, PRIMARY KEY(table_name,row_id))`** — a **dirty-row set, not an op log**: `INSERT OR REPLACE` naturally coalesces keystroke-rate autosaves into one pending push per row (S1's real payoff). Local-only, never synced.
- **Outbox population is by trigger, not by the operations layer.** AFTER INSERT/UPDATE triggers on every synced table enqueue `(table, id)`. Rationale: cascade triggers (block→variants etc.) write rows *below* the operations layer; app-level enqueueing would silently miss them — every write must be captured no matter which layer produced it.
- **Apply mode:** remote application sets a flag (temp table `_sync_applying`); outbox triggers check it and skip enqueueing during apply (echo suppression — the originating device already shipped every row its cascades produced). Cascade triggers stay *active* during apply (they're transition-guarded and idempotent, so a parent tombstone arriving before its children just pre-produces the same child rows the batch then applies over).
- **`sync_state(key, value)`** — pull cursor (`last_server_seq`), `device_id`. Local-only.

## 4. Push (upload)

Debounced/periodic: read outbox → load current rows → send `{table, row, base_sync_version}` batches. Server, per row, in one transaction: `base == current sync_version` → apply, bump version, stamp `server_seq`, clear ok; mismatch → **reject with the current server row** (no server merging). Client on reject: merge per §6, write the merged row locally (re-enqueues), push again. Convergence is guaranteed because rejects always carry the newer server state and merges are deterministic.

## 5. Pull (download)

`pull(sinceSeq)` → rows ordered by `server_seq`, applied in **one local transaction** with `PRAGMA defer_foreign_keys = ON` (multi-row operations — divide, merge, lock-post — arrive as row sets that may cross batch boundaries; deferred FKs make each batch atomic-consistent at commit) and `_sync_applying` set. Per row: locally clean → write it + its `sync_version`; locally dirty (in outbox) → merge per §6 into the local row, keep it enqueued. Advance the cursor only on commit. Read-side code must tolerate referenced-but-not-yet-arrived rows across batches (render gaps, never crash) — rare, but designed-for.

## 6. The merge matrix (client-side, deterministic)

| Class | Rows/fields | Rule |
|---|---|---|
| Append-only inserts | `commit_point`, `edge`, tag creations, new blocks/variants/placements | Insert-if-absent by PK; natural-key duplicates → §7 |
| The one mutable text | `variant.working_text` | **Conflict-as-variant (S5):** server text wins the row; the losing local text becomes a new variant on the same block, `label='conflict'`, branched from the same parent. Nothing is ever clobbered. |
| Metadata fields | titles, labels, locks, chosen_variant_id, entry_date, floating_notes, … | Server-version-wins on reject (CAS rebase): re-apply local intent on top if still meaningful, else accept |
| Positions | `position`, `fan_position` | CAS like metadata; ties impossible in practice (jittered fractional keys, §8) and broken deterministically by `(position, id)` |
| Tombstones | any `deleted_at` | Tombstone wins over edits — **except** a `working_text` edit racing its variant's tombstone: if the block is still live, the edit is rescued as a conflict variant before honoring the tombstone |
| Counters | `churn_accumulator`, `baseline_length` | Server wins; approximate by design, drift is harmless |

## 7. Constraint-violation repairs (each live-unique index gets a rule)

Concurrent offline writes can produce two *live* rows that violate a partial unique index when they meet. Apply-time repairs, all deterministic:

- **`container_block.block_id` (I2, move/move race):** the row with the higher `server_seq` wins (later intent); the other placement is tombstoned locally (and the repair pushes).
- **`tag.path` (duplicate creation):** keep the row with the lexically smaller `id`; re-point the duplicate's `post_tag`/`block_tag` rows to the keeper; tombstone the duplicate.
- **`edge` triple / `reading_post` pair / `post_tag`·`block_tag` pairs:** pure duplicates — keep smaller `id`, tombstone the other. For undirected `version_of` edges the operations layer stores the pair canonically as `(min(id), max(id))`, and this repair treats a reversed pair as a duplicate (review finding #8).
- **I10 double-tombstone race (review finding #1):** device A deletes variant V1 (V2 survives), device B concurrently deletes V2 (V1 survives) — both legal locally; tombstones-win converges to a live block with zero live variants, violating I10 without either device breaking a rule. Repair: if applying variant tombstones would leave a live block with no live active variant, **resurrect the tombstoned variant with the highest `server_seq`** (deterministic on every device), status `active`, label `'rescued'`. Resurrection over block-deletion because both devices wanted the block alive with *some* text — deleting it matches neither intent, and the pointer religion says rescue, never lose.
- **Dangling chosen variant (review finding #2):** device A re-points a slot away from V1 and tombstones V1; device B concurrently sets the same slot's `chosen_variant_id = V1`. Different tables, both CAS-accepted; RESTRICT never fires (tombstones are UPDATEs). Two-layer fix: **read-time, the fallback rule covers it** (a tombstoned or archived chosen variant renders as `default_variant_id`, same as NULL — AppSpec §7); **apply-time, the repair NULLs the dangling pointer** so the converged state is explicit and pushes. Same repair reassigns a `default_variant_id` that arrives dead.

**Repairs and echo suppression (review finding #4):** repairs run inside the apply transaction, where the `_sync_applying` flag has muted the outbox triggers — so **repair writes enqueue their outbox rows explicitly** (direct `INSERT OR REPLACE INTO sync_outbox`). Without this, repairs would be applied locally but never pushed, and the two devices would never converge. Every repair test must assert the outbox row exists.

**Documented convergence behavior, not a bug (review finding #6):** two devices structurally dividing the *same block* offline converge to duplicated content (both tombstone A's placement; both insert their own fresh-UUID successors; no index is violated, so no repair fires; the post reads B₁C₁B₂C₂). Accepted: structural editing is desktop-only by product design, making the race author-vs-herself-on-one-machine rare to impossible in practice. The Phase 5 suite includes a test *documenting* this outcome so it is never a surprise.

These repairs are ordinary domain operations (tested like any operation), run inside the apply transaction.

## 8. Ordering under sync (the position redesign)

`REAL` midpoint positions are a sync bomb twice over: two offline devices inserting between the same neighbors mint the *identical* midpoint, and REAL bisection exhausts precision (~50 splits) forcing a **mass renumber — N row-updates that conflict with every concurrent offline edit**. Therefore (schema delta, settled):

- Positions are **fractional-index strings** (`TEXT`, base-62 lexicographic keys à la Figma), generated by a pure Domain function `FractionalIndex.between(_,_)` **with per-call random jitter** so independent devices minting between the same neighbors collide with vanishing probability.
- Unlimited depth ⇒ **the rebalance operation does not exist.** No mass renumber, no sync bomb.
- Sort key is always `(position, id)` — a residual tie is stable and harmless, never an error.

## 9. Time, identity, cursors

- **No clock trust:** wall-clock timestamps are domain/display data only; sync ordering authority is `server_seq` exclusively. (Commit history ordering by `created_at` is display semantics and tolerates skew; commits are insert-only so nothing corrupts.)
- **IDs:** random UUIDv4 everywhere via `@Dependency(\.uuid)`. The original S3 idea of deterministic UUIDv5-from-natural-keys is **dropped** — it collides with tombstone-then-recreate (same natural key ⇒ same PK as a tombstoned row) and convergence is the sync layer's job, not the ID scheme's.
- **Tombstones are permanent** until a GC that is sync-aware (server-coordinated horizon); GC stays owned by a later phase.

## 10. What ships at the sync phase (and what doesn't)

Ships: mirrored Postgres schema + seq/CAS functions (author assist: Supabase project setup); push/pull engine in `VariorumCore/Sync`; apply mode + repairs; conflict-as-variant; engine tests that run **two in-memory client databases against a fake in-process server** (no network needed for the correctness suite), plus one integration pass against real Supabase.
Not yet: accounts/RLS/multi-tenant (accounts phase), GC (with sync horizon), any UI beyond a sync status indicator.

## 11. Invariant restated

Everything above preserves the load-bearing rule: **mutation is local and ephemeral; permanence is explicit and append-only** — a sync conflict is just one more way a variant gets born.
