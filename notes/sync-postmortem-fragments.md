# Sync post-mortem: Variorum vs Fragments (2026-07-07)

**What this is:** the author's two apps both hand-rolled row sync over Supabase and hardened
them independently. On 2026-07-07 a one-time, author-authorized, read-only study of
Fragments' sync (its Phase 15: ~193 commits, a mid-phase review, four self-assessment
rounds, a cold review) was mined for transferable lessons. This document preserves the
comparison so future sync sessions don't rediscover it. **Read this before changing anything
in `Sources/VariorumCore/Sync/`** (AppSpec §15 risk 3 points here). The Fragments repo
itself is hands-off for this repo's agents — the author is the only channel
(`notes/fragments-bridge-contract.md`).

## The two architectures, side by side

| Dimension | Variorum | Fragments |
|---|---|---|
| Model | state-based row sync | state-based row sync |
| Server | deliberately dumb: per-row CAS on `sync_version` + global `server_seq` changefeed; **mirror has NO constraints beyond PKs** | Postgres with **real FKs, partial uniques, XOR CHECKs**, data-table-driven cascade triggers; allowlisted RPCs (`sync_push`/`sync_pull`/`sync_delete`), RLS |
| Conflict authority | per-row CAS; ordering by `server_seq`; **wall clocks never** | **row-LWW on client-stamped `updated_at`** (+ a clock-ahead clamp/park/heal subsystem to survive that trust) |
| IDs | random UUIDv4; convergence via deterministic apply-time repairs | deterministic UUIDv5 from natural keys (+ ID freeze, canonical-user adoption pass, dayKey backfill, twin dedup, erase-and-switch) |
| Text conflicts | **conflict-as-variant designed in** (S5): one mutable field, losers become fan cards | whole-row LWW; a notes conflict-copy was bolted on late after real near-loss |
| Outbox | trigger-fed dirty-row set + `_sync_applying` suppression | willSave-observer `PendingChange` rows in the same save + suppression flag (same shape, different substrate) |
| Pull | whole-feed in one deferred-FK transaction; cursor advances on commit; straggler guard stalls | keyset pages on `(server_updated_at, id)`; park/heal for poison rows; drop-loudly-and-advance for unresolvable orphans |
| Ordering surface | jittered fractional-index strings, no rebalance op | none (no user-ordered lists) — **zero evidence either way on this class** |

## The divergence ledger — who paid for what

- **Clock trust.** Fragments' entire clock-clamp subsystem (server refuses rows >10 min
  ahead, parks them, heals on later success) exists *only because* LWW trusts client clocks.
  Variorum's `server_seq` authority sidesteps the whole class. **Variorum's choice validated
  by Fragments' pain.**
- **Deterministic IDs.** Fragments' heaviest sync machinery — the ID FREEZE ("never re-run
  the id migration"), the canonical-user adoption pass (its self-declared riskiest unbuilt
  piece), dayKey backfill, twin-Day dedup — is all UUIDv5 fallout: every install derives
  different ids for the same natural keys until adopted. Variorum dropped v5 deliberately
  (AppSpec §6). Bonus: Fragments' nastiest delete-machinery bug (insert+delete across saves
  wrongly "dropping both" because an insert can be a *resurrect* of a live server row)
  **cannot exist** in Variorum — recreates mint fresh ids. **Validated, twice.**
- **Conflict-as-new-row.** Fragments judged whole-row LWW on prose "the worst possible loss
  for a reflection app" and retrofitted a conflict-copy late. Variorum designed
  conflict-as-variant in from day one. **Validated.**
- **Server constraints — the standing tension, not a verdict.** Fragments keeps server
  FKs/uniques as a correctness net and *uses* them (a name-collision reject deliberately
  drives the client merge; it then needed topological push-ordering because FKs reject
  out-of-order children). Variorum's constraint-free mirror is **required** by its repair
  design — the server must accept both sides of a race for deterministic client repairs to
  work (SyncSpec §2) — but the cost is real: **no server backstop if a client repair is
  buggy or a new violation class ships unhandled.** Standing discipline this imposes: every
  new live-unique index MUST ship with its deterministic repair, an explicit
  "what moves with the loser" spec (re-pointed applications, edges, chosen pointers), and
  per-class tests — the mirror will never catch a miss. (`canvas_layout` at Phase 11 is the
  next one.)
- **Version skew.** Fragments *tolerates* schema-skewed clients (`sync_push` SETs only
  `payload keys ∩ real columns`, so an old client can't NULL-clobber new columns). Variorum
  *refuses* skew (SyncSpec §12 lockstep: mirror first, then every client, else no sync).
  Refusal is stricter and right for a two-device personal fleet; revisit tolerance only if
  multi-tenant scale ever forces rolling upgrades.

## Lessons transferred into Variorum (each verified against Phase 5's actual code first)

1. **Changefeed visibility skew** — the one genuine uncovered gap. `server_seq` is assigned
   at write time, visible at commit time; a pull racing two out-of-order commits can skip a
   row forever. Fragments hit the identical bug on `server_updated_at`, found it only by
   cold-review reasoning, fixed it server-side with a ~2 s visibility horizon. → SyncSpec §5
   note + **Phase 8 amendment A5** (+ fake-server in-flight-transaction mode; a synchronous
   fake can never surface this by accident).
2. **Lost-ack echo** — a retry after a dropped response gets rejected with the client's
   *own* winning row; the reject-merge must recognize byte-equal text and mint no spurious
   conflict variant (the pull path's merged-equals-server rule needed its reject-path twin).
   → **A2(e)**.
3. **Edit-during-push-await** — Fragments needed a conditional ack (`queuedAt` snapshot
   guard). Variorum's Phase 5 already ships the equivalent (clear-vs-re-dirty by payload
   comparison) — *covered*, now pinned end-to-end under real network gaps → **A2(d)**.
4. **Serializer/registry drift** — a migration adds a column, the payload wiring misses it,
   sync silently drops the data and the corruption spreads by pull. Fragments made the
   serializer schema-derived + added an independent completeness walk. → **A6**
   (PRAGMA-introspection completeness tests).
5. **Round order** — push-before-pull once acked away the pending edit that would have
   materialized a conflict copy ("the losing body vanished silently"). → engine rounds
   pinned **pull → push** (A3). Variorum's CAS gives extra safety here (a loser always
   learns via reject), but only if lesson 2 holds.
6. **Vacuous-pass discipline** — Fragments had tests "pass" on empty pages and unexercised
   effects. → every fault scenario asserts **positive activity counts** (A2), and the
   Phase 9 soak's review foci already demand non-vacuous assertions.
7. **Poison-row park/heal** — a permanently-bad row must not wedge a drain or jam a cursor
   forever; Fragments grew a park/retry/drop-loudly subsystem. Variorum's constraint-free
   mirror makes per-row rejects rare by construction → KnownIssues, owned Phase 12,
   evidence-gated.
8. **Test-fidelity meta-lesson** — Fragments' two nastiest bugs (suppression-flag restore;
   the half-born deferred insert) were invisible to unit tests that bypassed the production
   write path. Variorum's harness runs real SQLite triggers (structurally better), but the
   *faked* layers — the in-process server and the transport — are exactly where A5 and A2
   aim. Any future sync test that doesn't exercise the production path is decoration.

## Bridge note

The Phase 9b journal bridge does not mix the two protocols: it speaks Fragments' RPC dialect
against `journal_entries` only, and lands everything Variorum-side through ordinary
Operations (S5 covers conflicts). The only shared semantics are the satellite table and the
user-set calendar day as the join key. Fragments' clobber guard (unchanged text never
re-saves) is load-bearing for two writers — Variorum's bridge mirrors it.
