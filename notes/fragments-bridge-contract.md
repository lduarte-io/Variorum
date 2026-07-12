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
### ✅ their FINAL message arrived 2026-07-10 (pasted by the author at the 9c kickoff) and is
### re-reconciled below — ZERO corrections to the pinned shipped-SQL facts, ONE addition (the
### fourth `conflicts[]` producer, ask 11), ONE semantic re-pin on ask 13 (genuine-OVERWRITE-
### only + the consumer-side discrimination rules); the one remaining pending event is the
### 15.7 DEPLOY PING (they state the final `replaced` shape + emission table then);
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
    server stores µs (ms and µs stamps are never tied). **Addition (their 2026-07-10
    reply — an omission in their earlier message, found in their own review):
    `conflicts[]` has a FOURTH producer, `"row carries no writable columns"` — emitted
    when a pushed row carries no recognized writable column for the table. Unreachable
    for a bridge sending all six journal columns, but the error-string pins should cover
    all four: missing-`updated_at`, the `clock_ahead:` prefix, the `unique_violation`
    text, and this one. The same reply independently re-verified every other pinned fact
    (all seven UUID vectors recomputed; their migrations 2/3/6/7 re-read; the applier
    gate and the `server_updated_at` trigger confirmed) — zero corrections: the
    reconciliation stands.**
12. **`created_at` on upsert-update — ANSWERED: NOT preserved** (their SET list includes
    it — a winning push overwrites it; the round-0 fake was wrong and is corrected). The
    bridge now ECHOES the pulled `created_at` on every push (own creation instant only for
    a never-seen row); never omitted (the NOT-NULL abort). Modelling correction only —
    nothing keys on it.
13. **Return-the-replaced-body — ANSWERED: the author decided YES; Fragments is BUILDING
    it as their Phase 15.7** (a sync-correctness phase after their current UI batch,
    before their TestFlight). Their investigation of this ask surfaced a live silent-loss
    bug in their OWN notes sync (their pull-side conflict-copy gate fires only on pending
    local changes — an already-acked-then-overwritten body was unrescuable), so the
    receipt fixes their path and ours together. **The shape is DRAFTED, NOT FINAL, NOT
    DEPLOYED — the author was explicitly warned the draft may not be the final answer;
    their final message is pending.** Nothing is pinned into Variorum's fake server until
    their deploy ping. **The draft, recorded as the to-be-pinned-on-deploy shape:**
    `sync_push`'s response gains `replaced: [{id, previous_body, previous_updated_at}]`
    (`previous_updated_at` an opaque µs timestamptz string, the `server_updated_at`
    class; shape re-confirmed unchanged in their 2026-07-10 reply); scope = notes +
    `journal_entries` only; emitted when the upsert applied AND a prior LIVE row existed
    AND the prior body differs and is non-empty; NOT on plain insert, identical body,
    skipped push, resurrect-over-tombstone, or any other table. **Semantics RE-PINNED per
    their 2026-07-10 reply: genuine-OVERWRITE-only, NOT genuine-loss-only** (our earlier
    gloss overstated the rules; the emission table above is right) — a receipt fires
    whenever a differing live body was replaced, INCLUDING when the pusher had already
    seen the body it replaced: every ordinary edit of an existing entry replaces the
    pusher's own previous push and draws a receipt. **Loss classification is the
    CONSUMER's job** (the server cannot know what the pusher had seen); their own
    same-tier review caught that their drafted consumption missed this and would have
    self-conflicted on ordinary edits. **The bridge's consumption discrimination (their
    recommendation — cheap for the bridge, which holds per-day state):** (i) the
    receipt's `previous_body` equals the body the bridge last pulled or pushed for that
    day → the bridge knowingly replaced text it had seen and already holds → no variant,
    no-op; (ii) `previous_body` is contained in the body just pushed → a superset/merge
    push → no-op (this WILL occur: a Fragments device that appends an inline conflicted
    copy and re-pushes draws a receipt for the body it merged — their earlier "the merged
    body carries no further receipt" statement was imprecise: the receipt IS emitted;
    consumers no-op it); (iii) otherwise → text the bridge never saw → rescue as a
    variant — the loss case, and the only one. **Emission is unconditional and
    server-side** (their 2026-07-10 answer to our question): ANY authenticated
    `sync_push` caller gets the receipt on the two scoped tables — no client opt-in
    flag, no header, no parameter (RLS means a pusher only ever overwrites its own rows,
    so a receipt can never leak anyone else's text). **Timing:** 15.7 runs after their
    current batch (15.6) and before their TestFlight track. Bootstrap
    exemption, their side: Fragments devices won't consume receipts during a bootstrap
    full-store push (a deliberate coverage gap on their side; the server still emits; the
    bridge never bootstraps — no impact). **The bridge's PERMANENT posture (their explicit
    recommendation): ignore unknown response keys; consume `replaced` only if present** —
    already structurally true (Codable ignores unknown keys; pinned by test) and never to
    be tightened. **Framing, corrected:** the receipt covers already-on-server losses at
    push time; it CANNOT rescue text that never reached the server — a Fragments device's
    unpushed local text losing LWW at pull time is covered by THEIR pull-side
    conflict-copy rule. Post-15.7, the honest statement: no path remains by which typed
    text vanishes — via two complementary mechanisms, neither sufficient alone.
    *(Related, answered with the asks: Variorum's re-projection stamps may sit only 1 s
    above the row they answer rather than at wall-clock time — pure LWW ordering to them;
    content-newer-than-stamp rows are tolerable.)*
    **Recorded consequence (15.7's other half):** Fragments will consume its own receipts —
    the winning device appends the destroyed body under an inline plain-text marker
    ("— conflicted copy from this device —") and re-pushes the merge. Post-15.7 the
    bridge may therefore pull a journal body CONTAINING that marker (a Fragments device
    overwrote bridge-written text). It arrives as ordinary plain text and lands through
    the normal doors — no action needed. Future AUTHOR question (not a task): whether
    Variorum ever parses that marker into a variant — default is leave-inline (coupling
    to their marker string is not owed). **Their side confirmed 2026-07-10: leave-inline
    is the right default and matches their intent — the marker text is part of the
    user's editable body (ruled wording), and its stability as a parse target is NOT
    promised.**
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

---

## Ask 13 CLOSED — the 15.7 deploy ping arrived and the consumption path SHIPPED (2026-07-11)

The author relayed Fragments' Phase 15.7 closeout addendum: **`replaced` receipts are
LIVE on hosted** (their migration `20260707000013`, verified remote). Per the recorded
protocol, their **deployed SQL was read the same day** (author-authorized one-time
read-only look at their repo — the migration file, quoted verbatim by the extraction
agent) before anything was pinned. Verified facts, superseding their prose where they
disagree:

- **The final shape is the drafted shape:** `replaced: [{id, previous_body,
  previous_updated_at}]`, a FOURTH key beside `applied`/`skipped`/`conflicts`, ALWAYS
  present (initialized `'[]'::jsonb`). `previous_updated_at` = the prior LIVE row's
  own client-stamped **`updated_at`** (their snapshot query: `select body, updated_at
  … where … deleted_at is null`) — not a server stamp.
- **Emission predicates exactly as recorded above** (applied-only; `notes`/
  `journal_entries`; live prior row — resurrects snapshot nothing; prior body
  non-empty and `is distinct from` the pushed body; unconditional for any
  authenticated caller, no opt-in).
- **Their announcement's `"conflicts": {}` example is WRONG per their own SQL** —
  `conflicts` remains a JSON ARRAY (`'[]'::jsonb`, array-append). The prose-lags-SQL
  trap, again; the SQL was trusted.
- **Heads-up, not deployed:** their migration 15 (`20260711000015`) will later add a
  fifth `skipped_rows: [{table, id}]` key — hosted remains at 14/14 without it. The
  bridge's ignore-unknown-keys posture covers it structurally (now pinned with that
  exact key); nothing is consumed until any future need is decided.

**What shipped in Variorum (same day):** the typed `FragmentsReplacedReceipt` decode
(consume-if-present — a keyless response still decodes, pinned); the fake server
emits per the verified predicates (pinned by `FakeFragmentsServerTests`); and
`BridgeEngine.push()` consumes receipts on applied pushes under **the three
discrimination rules exactly as recorded in ask 13** — (i) hash-equals the day's
last pulled/pushed body → knowing replacement, no-op; (ii) contained in the
just-pushed body → superset/merge, no-op; (iii) otherwise → rescued as a
`'fragments'` take through the same conflict-as-variant door as the landing half,
replay-deduped, surfaced in the round report (`rescuedReceipts` + a note). **This
closes the 9b closeout's "first-push overwrite window" residual** — the one loss
path the receipt existed to cover. Their round-2 caution (an LWW-skipped bridge push
followed by a pull must not discard local text) was re-verified as already-defended:
the landing half's both-changed path keeps Variorum's text and cards the pulled body;
nothing discards. Engine tests: rule (i) on an ordinary edit (no self-conflict),
rule (ii) containment, rule (iii) end-to-end rescue (`BridgePushTests`). Core suite
after: **545/62** (was 540/62).

**Cold review of the consumption diff (same day, author-requested — a fresh Fable
reviewer over commit `09b4444`, the canonical REVIEW_PROMPT verbatim): 2 MAJOR /
1 MINOR / 3 NIT — ALL AGREED; all fixed same-day except one recorded-only NIT.**
MAJOR 1 (the one-shot receipt was unprotected): a throw anywhere in the rescue path
after `recordDay` dropped the only copy of the destroyed body — the scheduler's
"the day hashes keep everything, the next trigger retries" premise is FALSE for
receipts (the recorded hash already matches, nothing re-pushes, and an identical
re-push draws no receipt by the identical-body predicate). Fixed structurally:
consumption MOVED BEFORE `recordDay`, and `consumeReplacedReceipt` no longer
throws — every failure arm returns a visible note carrying the FULL body
(`recordDay` throwing after a successful rescue is safe by the same predicate: the
stale hash re-pushes the identical body, no new receipt, records then). MAJOR 2
(the "no landable block" arm was REACHABLE, not defensive): the author empties a
day → the designed empty re-projection destroys an unseen save that won inside the
stamp-quantization tie window → no slot exists for a take — and the shipped arm
truncated the only copy to 80 characters. Fixed: the arm preserves the full body in
the note; the reviewer's option (b) — minting a block to carry the take, which
would resurrect content the author just emptied — is deliberately NOT built (a
product call, the author's if ever wanted). **The red-on-old pin was verified by
behavioral revert** (the emptied-day test fails on the pre-fix engine exactly at
the full-body assertion). MINOR: three stale Phase-10-baseline carriers updated.
NITs: an id-mismatched receipt (impossible per the verified SQL — pure drift belt,
no pin constructible against the real contract) is now surfaced with its body,
never silently dropped; rule (i)'s "last PULLED" half gained its own pin (only the
pushed half was tested); the Fragments-trim noise-card interaction recorded as
bounded, doctrine-consistent noise — no action, the reviewer's own call. **THE
HONEST RESIDUAL (supersedes this addendum's earlier unqualified "closes the
residual"):** the receipt is delivered exactly once, so a PROCESS DEATH between the
server applying a push and the rescue landing loses it — sub-second, same-process,
unfixable client-side, and now the only remaining sliver of the first-push
overwrite window. Final core suite: **547 green in 62 suites** (the Phase 10
baseline; was 540 at the 9c ladder's close).

## Outbound courtesy note to Fragments (2026-07-11, carried by the author — informational; no answers owed)

1. **Ask 13's loop is closed bridge-side.** The deployed receipts are consumed
   under the three discrimination rules (plus a same-day cold-review hardening of
   the one-shot delivery path). Nothing further is needed from Fragments; the
   receipt + the bridge's keep-everything landing together now cover both halves
   as designed.
2. **Doc correction for your side:** your consumer-facing §7 announcement shows
   `"conflicts": {}` in its example — your DEPLOYED SQL builds an ARRAY
   (`conflicts jsonb := '[]'::jsonb`, array-append). Worth correcting before it
   misleads a future consumer; we pinned against the SQL.
3. **`skipped_rows` (your undeployed migration 15): no bridge action needed when
   it deploys** — unknown response keys are ignored by permanent posture (already
   pinned with that exact key). Standing request going forward: a ping is only
   needed if a future migration CHANGES the shape or semantics of the keys the
   bridge consumes (`applied` / `skipped` / `conflicts` / `replaced`).

**Cold review ROUND 2 (same day — the ladder's re-review of round 1's fixes; a
fresh Fable reviewer anchored on the record above): 1 NEW MAJOR / 2 NIT; every
round-1 fix judged SOUND against its disposition — with MAJOR 1's disposition
called OVERSTATED, which is the new MAJOR — the emptied-day pin's red-on-old
independently verified, and the recordDay-after-consumption convergence argument
re-derived against the SQL facts.** THE NEW MAJOR — "preservation" wasn't: the
full-body note lived only in the round's in-memory report (a later in-round
throw — a second candidate's dropped connection is ordinary — discarded it with
the round, and the scheduler's catch keeps only the error string), and even a
delivered note lasted one round in a non-copyable hover tooltip before the next
round replaced it. Both mechanisms traced; AGREED. FIXED durable-first, the
poison-note precedent: the failure arms persist the note (full body) to a keyed
`bridge_state` row BEFORE it rides the report — appending, never replacing, if a
day ever accrues more than one — and every push round re-surfaces all preserved
notes until cleared by hand; if even the preservation write fails, the note says
so and that corner honestly merges into the process-death residual. RED-ON-OLD
PIN verified by behavioral revert (`anUnrescuedBodySurvivesItsRoundAndResurfaces
EveryRound` — the pre-fix engine's next round carried no trace of the body). The
pin's first run also caught the fix's own composition slip (the scan's
`report.notes =` assignment clobbered the re-surfaced notes — corrected to
append). NIT 1 (the hallucination-guard rationale round 1 owed for MAJOR 1's
structural no-pin, now recorded): the non-throwing signature is
COMPILER-ENFORCED — no test can construct a throw out of a non-throwing
function — and pinning the consume-before-recordDay ordering alone would need a
DB fault-injection seam the harness deliberately lacks; round 2's durability pin
now covers the note-survival property that ordering serves. NIT 2:
`unrescuedBodyNote` made private. THE RESIDUAL, restated at every carrier
(superseding round 1's "only remaining sliver" wording): a process death between
the server applying a push and the rescue-or-preservation write — or that write
itself failing — loses the one-shot receipt; sub-second, unfixable client-side.
Core suite: **548 green in 62 suites** (the Phase 10 baseline).

**Cold review ROUND 3 (same day — the ladder's FINAL round, focused on round 2's
fix): the fix judged SOUND against its disposition, ZERO new HIGH findings —
1 MINOR / 2 NIT, all landed post-cap per the ladder's rule; THE LADDER CLOSES.**
The round independently verified both traced mechanisms closed (the preservation
write commits its own transaction at consumption time; every round re-loads the
`unrescued:%` rows), re-derived the red-on-old claims from the actual pre-fix
source (no `unrescued:%` reader existed), and confirmed 548/62 by running the
suite. MINOR (fixed here, doc): "cleared by hand" had no documented hand — THE
RECIPE, recorded: to extract a preserved body, run against the local store
(`~/Library/Containers/io.lduarte.Variorum/Data/Library/Application Support/Variorum/variorum.sqlite`)
`SELECT key, value FROM bridge_state WHERE key LIKE 'unrescued:%';`
and to clear one after saving it
`DELETE FROM bridge_state WHERE key = 'unrescued:<day>';`
(an in-app face for this is the author's optional call — Phase 10/13 territory;
the corner is vanishingly rare). NIT (fixed): the id-mismatch drift-belt arm —
the one only-copy arm round 2's fix missed — now routes through the same durable
preservation. NIT (fixed): the append-never-replace property gained its unit pin
(`unrescuedBodyRecordsAppendNeverReplace` — a future bare-REPLACE simplification
now goes red). Post-cap suite: **549 green in 62 suites — THE Phase 10 core
baseline, final.**
