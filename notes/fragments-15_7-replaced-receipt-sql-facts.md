# Fragments 15.7 `replaced` receipts — verified deployed-SQL facts

**What this is:** the verbatim facts extracted from the Fragments repo on
**2026-07-11** (author-authorized one-time READ-ONLY look, via an Opus extraction
agent — the standing hands-off rule was not otherwise relaxed), taken so Variorum's
fake server and consumption path were pinned to the **deployed SQL**, never to
announcement prose. Kept as reference for future sessions; the consumption record
lives in `notes/fragments-bridge-contract.md` ("Ask 13 CLOSED" addendum).

**Primary source file (their repo):**
`app/fragments/supabase/migrations/20260707000013_push_replaced_bodies.sql`
(note their migrations live under `app/fragments/supabase/migrations/`).

## Deployment state (load-bearing)

- **Migration 13 (`replaced`) IS the deployed hosted shape** — hosted at "14/14",
  migration 13 "verified remote" July 10 (their `notes/variorum-integration-plan.md`
  §7).
- **A NEWER migration exists but is NOT deployed:** `20260711000015_push_skipped_rows.sql`
  adds a FIFTH key `skipped_rows: [{table, id}]`. Their phase-16 notes state
  verbatim: "hosted migrations remain 14/14 — migrations 15+16 are applied
  LOCAL-ONLY". The bridge's ignore-unknown-keys posture covers it (pinned with that
  exact key in `FragmentsTransportTests`); it is NOT modeled in the fake until it
  deploys and they ping.

## The response construction (migration 13, verbatim)

```sql
    return jsonb_build_object(
        'applied', applied, 'skipped', skipped,
        'conflicts', conflicts, 'replaced', replaced);
```

- `applied` / `skipped` — ints.
- `conflicts` — **a JSON ARRAY** of `{id, error}`: declared `conflicts jsonb :=
  '[]'::jsonb;`, array-appended. **Their announcement's `"conflicts": {}` example is
  WRONG per their own SQL** — the prose-lags-SQL trap, again; empty serializes `[]`.
- `replaced` — **a JSON ARRAY** of `{id, previous_body, previous_updated_at}`:
  declared `replaced jsonb := '[]'::jsonb;` — so the key is **ALWAYS present**
  (possibly `[]`). Per-entry sources: `id` ← the pushed row's key-column value;
  `previous_body` ← the pre-upsert snapshot; `previous_updated_at` ← the prior
  row's **client-stamped `updated_at`** (NOT `server_updated_at`).
- Migration 13's ONLY response-shape change vs migration 7 is the added `replaced`
  key — `conflicts` entries and all four producers unchanged; LWW/un-tombstone
  guards, column intersection, user_id forcing, clock clamp all carried unchanged
  (their comment: "Diff from migration 7: the replaced capture.").

## Emission predicates (verbatim)

Table gate:

```sql
        capture_body boolean := p_table in ('notes', 'journal_entries');
```

Prior-body snapshot, taken BEFORE the upsert:

```sql
        if capture_body and jsonb_typeof(r->'body') = 'string' then
            execute format(
                'select body, updated_at from %I where %I = $1 and deleted_at is null',
                p_table, key_col)
            using (r->>key_col)::uuid
            into prev_body, prev_updated;
        end if;
```

Emission, only inside the applied branch:

```sql
            if result_count > 0 then
                applied := applied + 1;
                if capture_body and prev_body is not null and prev_body <> ''
                   and prev_body is distinct from (r->>'body') then
                    replaced := replaced || jsonb_build_object(
                        'id', r->>key_col,
                        'previous_body', prev_body,
                        'previous_updated_at', prev_updated);
                end if;
```

A receipt is emitted **iff ALL of**: table is `notes`/`journal_entries`; the pushed
`body` is a JSON string; a **live** prior row existed (the snapshot query gates on
`deleted_at is null` — so resurrect-over-tombstone snapshots nothing and a plain
insert has no prior → no receipt); the prior body is **non-empty** and **differs**
(`is distinct from`) from the pushed one; and the row **applied** (`result_count >
0` — an LWW-skipped push emits nothing; it destroyed nothing). Emission is
**unconditional for any authenticated caller** — no opt-in flag (their RLS means a
pusher only overwrites its own rows; a receipt can never leak another user's text).

## Consumption rules (their consumer-facing docs, confirming contract ask 13)

Their `notes/variorum-integration-plan.md` §7: *"a receipt matching the last body it
pulled/pushed for that day is its own knowing replacement (already stored in
Variorum — rescuing it would duplicate); only a receipt for an UNSEEN body becomes a
variant."* Their `phase-15.7` plan §8 confirms the bridge's posture verbatim ("the
bridge assumes nothing about `replaced` and works without it; it consumes the key if
present") and §10 the framing (a receipt means "replaced a differing live body" —
NOT "loss"; classification is the consumer's, via a based-on discriminator on their
side). Their round-2 caution, re-verified against Variorum's landing half: an
LWW-**skipped** bridge push carries no receipt and destroys nothing, and the
subsequent pull's both-changed landing CARDS the pulled body rather than discarding
local text — Variorum's keep-everything model already defends the case.

## What Variorum pinned to these facts (2026-07-11)

`FragmentsReplacedReceipt` typed decode (consume-if-present; keyless responses
decode nil); the fake server's emission (predicates above, `replaced` always
present); `BridgeEngine.push()`'s consumption under ask 13's three discrimination
rules — (i) hash-equals the day's last pulled/pushed body → no-op, (ii) contained in
the just-pushed body → no-op, (iii) otherwise rescued as a `'fragments'` take via
the landing half's conflict-as-variant door, replay-deduped, surfaced as
`PushReport.rescuedReceipts` + a note. Closes the 9b "first-push overwrite window"
residual for every in-process path — the receipt is ONE-SHOT, so consumption runs
before the day-state write, never throws, and an unrescuable body is preserved
DURABLY (a keyed `bridge_state` row, poison-note style, re-surfaced every round
until cleared — hardened across two same-day cold-review rounds; see the contract
addendum); the recorded remainder is a process death before — or a failure of —
the preservation write itself. Core suite after the review ladder: 548/62.
