# The Fragments ↔ Variorum journal-bridge contract

**What this file is:** the shared contract between the two apps' journal integration,
written 2026-07-07. **Audience: the author, and her Fragments agents** (she carries this to
the Fragments repo herself — Variorum's coordinator and agents never work in
`~/dev/fragments`, and Fragments' agents never work here). Variorum's side is specced in
`notes/plans/phase-09b-fragments-bridge-brief.md` (built after Variorum's Phase 9). If either side needs the contract to
change, the author is the channel.

## The arrangement (author-decided 2026-07-07)

Variorum becomes the **co-writer journal app** that Fragments' "journal satellite"
(Fragments SyncSpec §8) was explicitly designed to meet. **Variorum is the journal's home
and truth** (blocks, variants, commits, lineage); Fragments' `journal_entries` is a
**projection surface both apps write**: one plain-text body per calendar day. The join key
is the user's **stated calendar day** — Variorum's `entry_date` is user-set (past and future
allowed), so both apps simply agree the user's chosen day IS the identity.

## Facts Variorum's bridge relies on (from the 2026-07-07 survey — please keep true)

1. Table shape: `journal_entries(id uuid PK, user_id, date, body text, created_at,
   updated_at, deleted_at, server_updated_at)` with live-unique `(user_id, date)`.
2. Deterministic id: UUIDv5(`"journal|<canonical-user>|<dayKey>"`) in Fragments' namespace,
   dayKey `"yyyy-MM-dd"`; canonical user derivable via `user_settings.local_user_id`
   (Fragments SyncSpec §2.1/§2.2). Same-day creates in both apps must converge to one row.
3. Access: the allowlisted RPCs (`sync_push` guarded upsert, `sync_pull` keyset,
   `sync_delete`), RLS on `auth.uid()`; the bridge authenticates as the author's Fragments
   user and touches `journal_entries` only.
4. Merge: row-LWW on client-stamped `updated_at`; un-tombstone only on strictly-newer edits;
   clock-ahead clamp; **`sync_pull`'s ~2 s visibility horizon** (the commit-visibility fix).
5. The Day-screen **clobber guard**: unchanged text never re-saves (no pointless
   `updated_at` bumps). Load-bearing with two writers — Variorum mirrors it on its side.
6. **One-per-day is DB-enforced on the Fragments side** (confirmed by the Fragments agents
   2026-07-07): `UNIQUE (user_id, date)` plus the deterministic id — even if Variorum's
   UI-level create-or-open ever slips, the server cannot hold two rows for one day; a
   duplicate push under the same derived id would LWW-**overwrite** rather than duplicate.
   Which is exactly why Variorum's rule is **pause-the-day's-push, never newest-wins**:
   nothing is pushed for a duplicated day until the author hand-merges — an overwrite the
   author didn't choose is the one forbidden outcome.

## Asks of the Fragments side (for the author's Fragments agents)

1. **Confirm the visibility horizon applies to a third-party poller of `journal_entries`**
   via `sync_pull` (it should — same RPC — but say so explicitly): the bridge advances a
   keyset cursor and must never permanently skip a row.
2. **Keep the clobber guard** exactly as shipped; it is now part of a two-writer contract,
   not just hygiene.
3. **Treat this satellite's schema and key semantics as frozen without a contract update** —
   Fragments' own maintainer notes warn about add-a-column/migration compounding; a silent
   satellite change now breaks a second app. New columns are fine if `sync_push`'s
   key-intersection behavior preserves them for writers that don't send them (it does today).
4. **Tolerate any date** on entries arriving via sync — past, and **future** (the author
   allows future-dated journal entries). Confirm the Day screen renders a future day's
   entry sanely rather than assuming date ≤ today.
5. **The author wants journaling in Fragments to feel good as real writing** — Day-screen
   journal editor UX (comfortable size/type, maybe an expanded editor) is Fragments-side
   work with zero contract impact. This is her stated priority for your side.
6. Optional nicety: a subtle "updated elsewhere" cue/refresh when a pull changes the
   currently-visible day's body (the co-writer is live now).
7. Nothing Variorum-specific should enter Fragments: the satellite stays app-agnostic plain
   text, exactly as your spec intended ("the journal app owns richer journal tables if it
   wants them; what Fragments syncs is exactly this satellite").

### Phase 9b build asks — ANSWERED 2026-07-09 (the author carried them the same evening;
### the Fragments agents' full response is preserved in the Variorum coordinator's record;
### the answers below are the extracted contract facts, reconciled into the bridge the same
### night — see the phase plan's "Checkpoint reconciliation round." Source-of-truth note
### from their side: **their migration 7's SQL is the only truth — their SyncSpec §5.1
### PROSE still documents a superseded upsert guard.** Read the SQL, never the prose.)

8. **The UUIDv5 namespace — ANSWERED:** `7B69C1E4-9C72-4D2F-9B3A-2A41F0F4C0DE`
   (their `DeterministicID.swift`, "fixed forever" under their ID FREEZE; case irrelevant —
   parsed as 16 bytes; server-side parity via `uuid_generate_v5`). Now the pinned constant
   `FragmentsContract.fragmentsNamespace`; configuration defaults to it.
9. **Worked examples — ANSWERED; derivation parity CONFIRMED IDENTICAL** (our URL-namespace
   cross-check vector matches their Swift and their Postgres). Their journal vectors, now
   Variorum's pinned goldens (namespace above):
   `journal|9f1c2b3a-4d5e-6f70-8192-a3b4c5d6e7f8|2026-07-09` → `7ab43871-10ad-5597-a0d7-d721fcd3ecf9`;
   `…|2026-01-05` → `25cf2660-aa22-5057-97a9-e34fc11e5198`;
   `journal|11111111-1111-1111-1111-111111111111|2026-07-09` → `317235d4-855b-53e9-8e2b-fc6cfd9be899`.
   **Case is load-bearing** — the name is `bcased()` (lowercased) before hashing; the
   uppercased-user name derives a DIFFERENT (wrong) id (`a1f076a6-…`), pinned as a negative
   vector; Variorum's `entryID` lowercases the name to mirror `bcased()`; ids emitted
   lowercase.
10. **The canonical-user form — ANSWERED; the two-value design CONFIRMED.**
    `<canonical-user>` = `user_settings.local_user_id`, lowercased UUID text — minted by
    Fragments' first device, DISTINCT from `journal_entries.user_id` (= `auth.uid()`,
    forced server-side). **Amended contract facts:** (i) the bridge now also READS
    `user_settings.local_user_id` via `sync_pull` — a deliberate one-column amendment to
    "touches `journal_entries` only"; (ii) **fail-closed rule**: if `user_settings` has no
    row, the account has not synced from Fragments — the canonical id is undecided and the
    bridge MUST NOT write journal rows (shipped: all pushes hold, visibly, until the row
    exists); the id is never guessed and never the auth uid.
11. **The RPC wire shapes — ANSWERED, with THREE corrections (all reconciled into the
    transport + fake server):** params are `p_table`/`p_rows`/`p_after_ts`/`p_after_id`/
    `p_limit`/`p_ids`; the row column is `date`; `sync_push` responds with AGGREGATE
    counters `{applied, skipped, conflicts:[{id,error}]}` (no per-row status — Variorum now
    pushes ONE row per call so `applied == 1` is unambiguous); `sync_pull` returns a BARE
    array ordered `(server_updated_at, id)` ascending (the keyset is on
    **server_updated_at**, page while `count == p_limit`, 500), with the ~2 s horizon
    inside the RPC; `server_updated_at` is µs-precision and OPAQUE — stored verbatim as the
    cursor, never reformatted; `sync_delete(p_table, p_ids)` → `{tombstoned: n}`, soft
    only. **Ties go to the pusher (`>=`)** on live rows — re-pushing an unchanged row
    re-applies and bumps `server_updated_at`, churning every device's pull, which makes
    Variorum's never-push-unchanged guard load-bearing, not politeness. Un-tombstone stays
    STRICTLY-newer (the SQL; their prose wrongly says stale-can-resurrect). Omitted NOT
    NULL columns abort the ENTIRE call — all six always sent. Stamps: any
    Postgres-parseable timestamptz with an explicit UTC zone; Fragments emits ms, the
    server stores µs (ms and µs stamps are never tied).
12. **`created_at` on upsert-update — ANSWERED: NOT preserved** (their SET list includes
    it — a winning push overwrites it; the round-0 fake was wrong and is corrected). The
    bridge now ECHOES the pulled `created_at` on every push (own creation instant only for
    a never-seen row); never omitted (the NOT-NULL abort). Modelling correction only —
    nothing keys on it.
13. **Return-the-replaced-body — CONFIRMED COHERENT AND FEASIBLE; NOT BUILT, NOT
    PROMISED** (routed to the author as her own Fragments-side call: new server migration
    + their SyncSpec amendment + db push; their design notes recorded — gate on
    `p_table='journal_entries'`, return `{id, previous_updated_at, previous_body}` only on
    genuine loss; it cannot rescue text saved locally but never pushed). **The bridge
    assumes nothing.** Original ask, for the record: when `sync_push` LWW-overwrites a live
    row, consider returning the REPLACED body in the response. Variorum's pushes stamp
    minimally above the last server-row stamp the bridge has seen (a compare-and-set
    discipline added at its Phase 9b review), so an unseen Fragments save now survives as
    `.stale`-then-rescued — but three residues remain: a day's FIRST-EVER push carries no
    known stamp (falls back to wall clock), stamps quantize at 1 s, and an unparseable
    stamp falls back to wall clock (ask 11). With the previous body returned on overwrite,
    the bridge would land it as a variant → zero loss in every case.
    *(Related, from the same review: Variorum's re-projection stamps may sit only 1 s
    above the row they answer rather than at wall-clock time — confirm your `updated_at`
    semantics tolerate content-newer-than-stamp rows; it is pure LWW ordering to us.)*
14. **The clock-ahead clamp — ANSWERED: >10 minutes ahead** (migration 7), refused as a
    `conflicts[]` entry whose `error` carries the **`clock_ahead:` prefix** (match on the
    prefix). Reconciled: the bridge parks and surfaces clamped days visibly and retries as
    the clock catches up; since minimal stamping only ever goes 1 s above a stamp their
    server itself accepted, a clamped re-projection's hold is bounded by real skew.

### Standing asks (a)–(e) — ALL CONFIRMED 2026-07-09, with recorded caveats

- **(a) The ~2 s horizon lives INSIDE `sync_pull`** — every caller gets it; a keyset
  poller on `(server_updated_at, id)` of received rows cannot permanently skip; sync lags
  2 s, never skips.
- **(b) The clobber guard stays** (`JournalRules.bodyToSave`) — and **FRAGMENTS TRIMS**:
  leading/trailing whitespace (incl. a trailing newline) is silently trimmed the next time
  a Fragments user edits that day — the bridge treats whitespace as insignificant at the
  join (a trimmed body landing back converges normally; nothing lost — commits insure).
  **An empty body never saves and never creates through their UI** — if the bridge pushes
  "" (a Variorum-side emptying of a previously-agreed day), it owns that semantic alone.
  Corollary: a `journal_entries` tombstone today can only come from the bridge (their UI
  has no journal-delete path) — Variorum's tombstone-landing paths stay as defensive
  machinery.
- **(c) Schema/key semantics FROZEN** (their SyncSpec §2.3 ID FREEZE, normative; full DDL
  supplied and pinned in the fake). The `(user_id, date)` unique index is the safety net
  for a mis-derived id: **`unique_violation` = a derivation BUG, never retryable** —
  Variorum poisons the day (visible every round, never re-pushed).
- **(d) Any date tolerated, past and future** — an entry surfaces only where its date is
  navigated to (a UI absence, not a data constraint).
- **(e) Nothing Variorum-specific enters Fragments** — app-agnostic plain text; structure
  belongs in Variorum-owned tables, never in `journal_entries`.

## What each side promises operationally

- Variorum pushes only when its rendered text actually changed; pauses a day's push while
  that day has two live entries (a rare offline-race state, hand-merged by the author);
  lands every Fragments-side edit in durable Variorum rows (worst case: a labeled variant —
  nothing typed in Fragments can be lost by the bridge).
- Fragments keeps LWW semantics as-is; no special cases for the co-writer.
- Credentials: the bridge uses a user-auth session for the author's Fragments account,
  stored untracked on her machines; the Supabase *personal access token* (server tooling)
  is never used as the bridge's identity.
