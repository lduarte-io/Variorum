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

---

## The 14a horizon — suite-identity heads-up (added 2026-08-02, the evening Fragments goes to TestFlight)

> **READ THIS FIRST (2026-08-04):** this section accumulated in layers as rulings
> evolved. THE OPERATIVE PARTS for the Fragments agent are the **EXECUTION MODEL**
> block and the three **TOUCHPOINT** blocks below (one batched handoff at 14c's
> end). Everything above them in this section — the TestFlight-ships-tonight
> framing, the ship-native-then-relink caveat — is superseded history, kept for
> the record.

**Why this section exists:** the author is finishing Fragments for TestFlight and asked
what the suite-identity (Phase 14a) questions are, so tonight's build doesn't foreclose
them. The recorded rulings this rests on (Variorum master plan rows 14a–14c +
*[removed for publication]*
for both apps, brand PROVISIONALLY stargazing; the Fragments-side conversation formally
opens AT 14a; Fragments' E2EE is **journal-class ONLY** (14b, under the shared key — the
rest of Fragments stays server-readable by design, its insights being the product); ONE
sync payment covers both apps (14c).

**What TestFlight does NOT need to wait for (nothing here blocks shipping tonight):**
- **The bridge.** It is Variorum-side machinery over the standing asks above; Fragments
  ships without any bridge work (the author's own call, 2026-08-02: "i don't think
  fragments needs the bridge with variorum to ship").
- **The neutral issuer / stargazing login pages.** Ship Fragments' current sign-in; 14a
  re-points both apps at the suite account later.
- **E2EE** (14b, after 14a's identity and key vault).

**What the Fragments build should keep cheap tonight (so 14a is a re-point, not a rework):**
1. **Keep auth in one seam.** Sign-in, session handling, and canonical-user derivation
   should live in one module; nothing outside it should assume the current Supabase
   project's auth is permanent.
2. **Account migration is a 14a deliverable** — the author's account AND any
   TestFlight-era tester accounts will need mapping onto suite accounts. The
   canonical-user derivation (`user_settings.local_user_id`) already makes identity
   re-mappable; keep it that way, and accept that early testers may face a one-time
   re-link step.
3. **Privacy-policy wording:** don't promise E2EE (not built yet), and don't promise
   never-reads-your-data globally — the journal class gains E2EE at 14b while insights
   stay server-readable by design. Word it so 14b *tightens* the policy rather than
   contradicting it.
4. **The journal satellite stays frozen** (ask #3 above) — no TestFlight-rush migration
   should touch `journal_entries` shape or key semantics silently.

**The genuine 14a questions (for the author, at 14a — none are tonight's):** issuer
mechanics (a neutral project as OIDC issuer vs shared JWT secret — the 9c candidates,
re-decided at suite level) · the brand (stargazing is provisional, her word) · the
consent/sign-in pages on stargazing.tech (that repo's own agent builds them) · her own
account's migration path · how the one-payment entitlement is checked from both apps
(14c's build, but the account model should not preclude it).

**UPDATE 2026-08-03 (the 14a kickoff sitting, rounds 0d–0f — supersessions for this
section; the sitting record is `notes/plans/phase-14a-suite-identity.md`):**

- **TestFlight now WAITS — her ruling, verbatim:** *"I'm just going to wait to have
  the testers and testflight until this whole phase 14 and all of its issues are
  resolved and fragments has its new answers / new id provider - i'm not in THAT much
  of a hurry to open up testflight tbh, I'd rather just get everything right."* And
  separately: *"I don't want to have fragments native accounts."* Consequence: item 2's
  "early testers may face a one-time re-link step" DISSOLVES — no tester account will
  ever exist natively; testers arrive on suite (stargazing) accounts from day one,
  after 14a's identity work + 14b's journal-class E2EE.
- **Issuer mechanics RULED — shape (A):** a NEW neutral Supabase project is the suite's
  account home and OIDC issuer (OAuth 2.1 Server); both app projects trust it as a
  custom OIDC provider and keep minting their own native sessions. The Fragments-side
  ask, when the project exists (its issuer URL is the missing coordinate): add the
  neutral issuer as a trusted provider; route ALL sign-in — and signups, when they
  open — through it; retire the native signup surface.
- **Single sign-in RULED — the Fragments email+password identity RETIRES.** Her
  Fragments USER survives (same uid, `journal_entries` rows untouched): the stargazing
  identity links on, the password identity unlinks (or the deliberate re-map if that
  final state is cleaner — the sitting's R3 posture). The one-seam auth module (item 1
  above) is exactly what this rides on.
- **The bridge's session goes DELEGATED:** it stops using email+password and obtains
  its Fragments-project session through the stargazing issuer (one interactive flow
  per device, then the same persisted-session + refresh loop as today).
  `journal_entries` shape and key semantics stay frozen — ask #3 stands untouched.

**AMENDMENT 2026-08-03 (round 0h — supersedes the "NEW neutral Supabase project"
line above):** the suite account home is the **VARIORUM PROJECT itself** (her
ruling; "stargazing" stays the brand and the pages' front — plus an eventual
custom domain — never a separate project). Consequence: **the issuer URL is known
*[removed for publication]*
custom domain before any non-author signup. The Fragments-side asks, STAGED
by touchpoint (what belongs to what — her request that each stage be unambiguous):

**EXECUTION MODEL (her ruling, 2026-08-04): ALL THREE touchpoints execute as ONE
batched handoff at the END of 14c** — one conversation with the Fragments agent
covering everything below, in order (#1's provider/identity work, then #2's
E2EE, then #3's entitlement). Fragments may be broken in the interim — her
words: *"it's okay if fragments is broken while the 14 phases happen - that's
the beauty of taking care of this while i'm the only user"* — and the bridge
PAUSES from 14b's encryption until this batch completes (the R5 die-and-return
latitude, spent as designed). Neither she nor the bridge depends on Fragments
meanwhile; her phone journaling rides Variorum Mobile.

**AMENDMENT (2026-08-04, the 14c design sitting — her ruling): the one
batch now executes as its own MICRO-PHASE 14d, AFTER 14c's closeout.**
14c ships the multi-tenant isolation, the stale-key fence, and the
entitlement machinery this batch relies on, then closes without
waiting on Fragments (her words: *"let's let this phase close out…
it can be 14d… micro phase to validate that the bridge still works"* —
Fragments has UI refactoring in flight). Content, order, and the three
touchpoints below are UNCHANGED; the bridge stays paused until 14d
runs; the custom domain attaches inside 14c (before its signup door
opens), so this batch's provider configs are still written once
against the final issuer URL. One addition the batch will gain from
14c's build: sync rounds carry the caller's ACTIVE KEY ID (the
stale-key fence — a mismatch against the vault's current key refuses
the round with the keys-were-replaced state), and the concrete
parameter facts join touchpoint #2's block when 14c lands them.

**TOUCHPOINT #1 — at 14a, NOW** (ready to carry once the OAuth 2.1 Server is
enabled and Fragments is registered as a client; client id + page URLs delivered
with them):
1. Add the suite issuer as a trusted OIDC provider (`custom:stargazing`) and route
   sign-in through the delegated PKCE flow (the same 9c-proven pairing, pointed
   the other way).
*[removed for publication]*
   *[removed for publication]*
   unlink/retire her email+password identity — single sign-in, no Fragments
   password surviving.
3. Retire the native signup surface: accounts are created at the suite from now
   on — and suite signups stay OFF until Variorum's 14c isolation is built
   (nobody-before-the-family, her sequencing ruling).
4. `journal_entries` shape/keys stay frozen (standing ask #3, unchanged).
5. **Switch OFF Fragments' own OAuth 2.1 Server** (its 9c role as Variorum's
   *[removed for publication]*
   this point (Variorum's 14a code batch will long since have shipped the
   direct sign-in; until that batch, the old issuer must STAY ON — it is the
   Variorum app's only sign-in road).
6. **The signups-toggle nuance:** retire the native email SIGN-UP SURFACE (and
   optionally the email provider), but the Fragments project's global "Allow
   new users to sign up" toggle must be ON when suite users arrive — a FIRST
   delegated sign-in rides the create-account path (the same mechanism the
   Variorum side's 04 header documents).
7. **Config hygiene:** remove any stargazing.tech URLs added to the Fragments
   project's own auth configuration — none are needed there (the suite pages
   talk to the SUITE project's API; Fragments' project only ever needs the
   provider entry from item 1).

**Coordinates DELIVERED (2026-08-04Z — the registration ran through the admin
door; nothing further is needed from the Variorum side for this touchpoint):**
*[removed for publication]*
  works; endpoints live under it: `/oauth/authorize`, `/oauth/token`,
  `/.well-known/jwks.json`).
*[removed for publication]*
  `client_secret_post` · registered redirect
  *[removed for publication]*
  GoTrue callback).
- **client_secret:** in the author's untracked
  `~/dev/variorum/.env.fragments-oauth.local` (`SUITE_FRAGMENTS_CLIENT_*`) —
  she carries it into Fragments' provider config by hand; it appears in no
  repo and no chat.
- **THE FIRST-SIGN-IN RULE (load-bearing):** on her FIRST delegated sign-in
  into Fragments via the new provider, VERIFY the minted session's uid equals
  *[removed for publication]*
  email to the existing user when it can). If a NEW uid appears instead, STOP —
  do not use that account — and link deliberately via the admin API before
  proceeding: every `journal_entries` row keys on the old uid. Also check the
  interaction with Fragments' own signups toggle deliberately — a first
  delegated sign-in rides the create-account path there, exactly as on the
  Variorum side.

**TOUCHPOINT #2 — designed at 14b, executed in the one batch:** the journal
class goes ciphertext under the shared account key — Fragments' client gains
encrypt/decrypt for that class (setup UX includes the account's encryption
passphrase; the vault lives on the suite account; suite terminology ruling,
hers: nothing is ever called "Passkey" — that word is WebAuthn sign-in
vocabulary and confuses the encryption story) — and the two standing audit
flags land: the TRIM behavior and the EMPTY-BODY-AS-DELETION detection move
client-side or become metadata flags (server-side versions cannot operate on
ciphertext). `entry_date` stays plaintext metadata, disclosed. **Existing-rows
migration:** her historical `journal_entries` bodies re-arrive ENCRYPTED via the
bridge re-pushing every day from Variorum truth (Variorum is the journal's
home/truth — Fragments-side needs only to read ciphertext, never to migrate
rows itself). **Verification that closes the batch's bridge half:** a full
bridge round-trip completes over ciphertext on both ends — that round-trip is
also the bridge's RESUMPTION from its 14b pause.

**TOUCHPOINT #2 — THE CONCRETE FORMAT FACTS (added at 14b batch 3, 2026-08-04 —
the design half executed Variorum-side; what follows is everything a Fragments
implementer needs to build the client end at the one-batch handoff. The
Variorum bridge's capability is SHIPPED and PAUSED behind its key seam):**

1. **AEAD: AES-256-GCM**, per-value random **96-bit nonce**, 128-bit tag.
   (Apple CryptoKit `AES.GCM` on the Variorum side; any standard AES-GCM
   implementation interoperates.)
2. **Encoding:** the `journal_entries.body` column carries
   `e1:` + base64(nonce ‖ ciphertext ‖ tag) — one TEXT value, no schema
   change (the frozen satellite shape holds, ask #3 untouched). `e1:` is the
   suite's version prefix; any future format bumps the digit, so match the
   prefix exactly, never "starts with e".
3. **The AAD convention (reproduce it byte-exactly or nothing decrypts):**
   `AAD = UTF-8("journal_entries:<date>:body:<key_id>")` — where `<date>` is
   the row's own `date` column (the `yyyy-MM-dd` day key, the join key of
   this whole contract) and `<key_id>` is the vault's `journal_bridge_key_id`
   string. Binding the DAY means a ciphertext can never be moved between
   days undetected. (This is the suite's standard
   `table:rowID:column:keyID` grammar with the day standing in the rowID
   slot — deliberate: the deterministic UUID derives FROM the day, and both
   sides always know the day.)
4. **The key + where it comes from:** the `journal_bridge` class key — 32
   bytes, held wrapped in the suite vault; Fragments' client only ever
   touches THIS class key, never the corpus key (R-8). Vault access: plain
   authenticated PostgREST on the suite (Variorum) project's `key_vault`
   table (owner-only RLS on `auth.uid()`; one row per account). The unwrap
   chain, client-side: the user's **encryption passphrase** → Argon2id with
   the parameters stored IN the row (`kdf_*` columns + `kdf_salt`, base64 —
   never app defaults) → unwrap `master_wrapped_by_passphrase` (RFC 3394
   AES-KeyWrap) → unwrap `journal_bridge_key_wrapped_by_master` (RFC 3394)
   → hold per-device (Keychain), enrollment-only cadence. `journal_bridge_key_id`
   is a plaintext column on the same row. (The recovery-phrase road exists
   too — `master_wrapped_by_recovery`, BIP-39 12 words → PBKDF2-HMAC-SHA512
   ×2048 salt "mnemonic" → HKDF-SHA256 salt `variorum.suite.e2ee.v1` info
   `recovery-wrap-key` — but the Fragments client only needs the passphrase
   road.) **PRECISION added at the 14b closeout (2026-08-04, R-8's letter
   for your side): what Fragments PERSISTS is the `journal_bridge` key +
   its id, NOTHING ELSE — master is a transient in-memory step of the
   unwrap chain and is discarded the moment the class key is unwrapped;
   never store master, never touch the corpus key.** Two row facts your
   reader must tolerate: the row carries a **`revision`** column (writers'
   compare-and-set token — READ and ignore it; Fragments NEVER writes the
   vault row), and a **`format_version`** — refuse-by-version anything you
   don't speak (mirror Variorum's posture: a newer vault is never guessed
   at; tell the user to update).
5. **Legacy plaintext — the EXACT classification (refined at the 14b
   ladder R1-4 + cold pass C-4; mirror all three arms):** a body matching
   `e1:` exactly is ciphertext (open it; a tampered/unopenable one must
   never be displayed or silently dropped — preserve and refuse visibly);
   a body with any OTHER `e<ASCII digits>:` prefix (`e2:` etc.) is an
   UNSUPPORTED FUTURE VERSION — refuse/hold it, never display it, never
   treat it as legacy text; anything else — including look-alikes with
   non-ASCII numerals like `e²:` — is LEGACY PLAINTEXT and lands as text.
   (`journal_entries` is never wiped, so pre-E2EE rows and interim writes
   stay plaintext on the server.) Variorum's historical bodies re-arrive
   ENCRYPTED via the bridge's re-push from truth (as staged above); your
   side never migrates rows.
6. **`entry_date`/`date` stays PLAINTEXT metadata, disclosed** (which days
   carry entries is visible to the server; the words never are). Stamps,
   ids, tombstones — all unchanged and plaintext; LWW semantics are
   untouched (the ciphertext is just the body's bytes).
7. **The two standing relocations, now forced by ciphertext (as drafted
   above):** the TRIM behavior and the EMPTY-BODY-AS-DELETION detection move
   CLIENT-SIDE (server-side versions cannot operate on ciphertext) — the
   bridge now encrypts even the empty body, so "the body is empty" is a
   fact only a key-holding client can see; detect it after decrypt.
   Trimming likewise happens before encrypt / after decrypt.
8. **One behavioral note for your `replaced` receipts (ask 13):** under
   E2EE, re-pushing the same plaintext produces DIFFERENT bytes (random
   nonce), so byte-identity predicates fire receipts more often than in the
   plaintext era. Variorum's consumer already discriminates by decrypted
   content (rule (i)) — if your client consumes its own receipts, decrypt
   `previous_body` before classifying, and treat an unopenable receipt body
   as an only-copy to preserve, never to drop.
9. **STALE KEYS after a re-key (added at the 14b closeout — the CF-16
   lesson, and 14c ships the user-facing re-key door in the SAME phase as
   your batch):** the suite supports a deliberate RE-KEY (fresh vault,
   fresh key ids, corpus re-encrypted — Variorum ran it live twice at
   14b). After one, a device's held keys are silently wrong: decrypts
   fail authentication because the AAD's `<key_id>` no longer matches.
   **Mirror Variorum's honesty rule:** before failing opaquely, compare
   your held `journal_bridge_key_id` against the vault row's current one
   (you already read that row) — a mismatch means "this account's
   encryption keys were replaced; enter the passphrase to re-enroll",
   never a generic error. Re-enrollment overwrites the held key; nothing
   else needs clearing. (Bridge-side consequence, for the 14c re-key
   design: old-key `e1:` bodies left in `journal_entries` refuse on the
   Variorum side until the bridge's re-push from truth overwrites them —
   a re-key therefore triggers the same staged re-push as the migration
   above.)

**TOUCHPOINT #3 — at 14c (multi-user + the tier):** check the one-payment suite
entitlement from the Fragments side (entitlement rows live on the suite account;
both apps read the same answer). TestFlight opens only after the family
completes — no tester account exists before then.

---

## THE ONE-BATCH HANDOFF — EXECUTED AND CLOSED (2026-08-16, Phase 14d;
## the Fragments agent's closing report, carried by the author)

All three touchpoints verified done. The standing facts, superseding
any pending-tense wording above:

- **ONE STARGAZING ACCOUNT — the end state is REAL.** Her delegated
  *[removed for publication]*
  *[removed for publication]*
  duplicate ever created); the identity row reads `custom:stargazing` /
  *[removed for publication]*
  retired:** email provider off, the password grant 422s, the stored
  hash blanked. Any Variorum-only or Fragments-native account framing
  is DEPRECATED (the author's instruction).
- **The old issuer era is over:** Fragments' own OAuth 2.1 server is
  *[removed for publication]*
- **Journal-class E2EE is LIVE on both ends:** their client's
  enrollment opened the real vault (pure-Swift Argon2id + AES-KeyWrap
  interoperates; their tolerant `kdf_*` decode matched the live row),
  and her journal rows re-pushed as `e1:` ciphertext (verified
  server-side by prefix only). No interim plaintext remains on the
  wire for her rows. The Variorum bridge is RESUMED (the 14b pause
  ended; the staged re-push from truth drained — both ends observed
  it independently).
- **The entitlement gate is live and quiet** on her device (a
  not-entitled read would pause visibly).
- **The bridge's sign-in road is DELEGATED:** the Variorum app's
  Fragments email+password door is REMOVED (it could only 422); the
  browser flow through the suite issuer (`provider=custom:stargazing`
  — the platform prefixes dashboard-created custom providers; bare
  `stargazing` 400s) is the one road, with `variorum://auth-callback`
  on the Fragments project's redirect allow-list.
- **STANDING DESIGN NOTE (their flag, recorded as the contract's):**
  Fragments holds the suite provider token IN MEMORY ONLY, so its
  suite-project reads (vault, entitlement) happen at interactive
  sign-ins. If either side ever wants silent re-reads, that is a
  future contract conversation — not assumed by anything shipped.

**TOUCHPOINT #3 — THE CONCRETE FACTS (added at 14c's build, 2026-08-05 —
the Variorum-side machinery is BUILT; what follows is everything the
Fragments implementer needs for the entitlement check at the one-batch
handoff):**

1. **Where it lives:** the `entitlement` table on the SUITE (Variorum)
   project — `(user_id uuid, feature text)` primary key, plus
   `granted_at`, `expires_at timestamptz NULL` (NULL = non-expiring),
   and a `source` provenance text. The feature name for the one
   payment is exactly **`hosted_sync`** (one row covers BOTH apps —
   the suite ruling's letter).
2. **The read road:** plain authenticated PostgREST on the suite
   project, same as the `key_vault` read your touchpoint-#2 client
   already makes — owner-only RLS SELECT on `auth.uid()`; you read
   YOUR user's row(s) for `feature = 'hosted_sync'` and never anyone
   else's. **ENTITLED means: a row exists AND (`expires_at` IS NULL OR
   `expires_at > now`).** No row, or an expired row, means not
   entitled.
3. **Never write it:** entitlement writes are service-role-only by
   design (the checkout's webhook calls a dedicated server function);
   the apps are readers. A failed read should degrade QUIET (Variorum's
   posture: unknown-and-silent, never an error face — the static copy
   carries the story).
4. **What gating means on your side is YOURS to shape** (Variorum
   gates its hosted sync rounds server-side with a
   `VARIORUM_NO_ENTITLEMENT` refusal and presents it as a normal
   activation prompt, never an error); the suite promise ("one payment
   covers both apps") is worded on the stargazing.tech pages — the
   14c ruling is that neither app promises the OTHER app's coverage
   in-app until both ends are live.
5. **The issuer/domain coordinate — RESOLVED AT THE 14c GATE
   (2026-08-11): the confirmed issuer URL is the RAW project URL
   *[removed for publication]*
   `auth.stargazing.tech` custom domain was DECLINED — a lookup
   confirmed branded auth-email links come FREE via a rewritten email
   template pointing at stargazing.tech + a `/auth/confirm` `verifyOtp`
   *[removed for publication]*
   only user-invisible surfaces — the API hostname, OAuth callbacks, and
   per a community report maybe not even the `iss`) buys nothing users
   see. **Write your provider config against
   *[removed for publication]*
   custom domain later, it is a coordinated config-only update on both
   apps + your provider entry — never data; nothing forces it.)
6. **One interplay note for the batch's bridge half (informational —
   the Variorum side owns it):** when the bridge resumes at the
   batch, historical plaintext journal days re-arrive as `e1:`
   ciphertext via the staged re-push from Variorum truth; your side
   simply sees ordinary LWW updates. If the suite account was RE-KEYED
   before resumption (the 14c user-facing door), old-key ciphertext
   rows may sit in `journal_entries` until that staged re-push
   overwrites them — the Variorum side sequences its own resumption
   around this; nothing for your side to do beyond point 9's standing
   stale-key honesty rule.

---

## CARRY-ITEM FOR FRAGMENTS (2026-08-24, Phase 13l Act 6) — journal-day
## DELETIONS now travel; ONE confirmation asked, NOTHING new owed

**What changed on the Variorum side, in one sentence:** deleting a journal
day in Variorum now deletes it in Fragments too — at delete time (the round
after the tombstone), not 30 days later at the purge.

**Why you are being told rather than asked to build:** the wire semantic is
**one you already own, unchanged**. A travelled deletion is byte-identical
to the push standing ask (b) already describes — *"if the bridge pushes ""
(a Variorum-side emptying of a previously-agreed day), it owns that semantic
alone."* Same RPC, same deterministic id, same LWW stamping, same
`replaced`-receipt behavior. **No `sync_delete`, no tombstone, no new
column, no schema change** — the `journal_entries` freeze (standing ask #3)
is untouched. The only difference from before is **frequency**: empty bodies
will now arrive for deleted days, where previously they arrived only when
she hand-emptied a day.

**Why the tombstone road was NOT taken, recorded so nobody re-proposes it:**
your `sync_delete` is deliberately unguarded (it stamps `deleted_at` with no
LWW comparison, and emits no `replaced` receipt), so a bridge that deleted
that way would destroy an unseen Fragments save unconditionally and
silently. The empty-body push loses LWW to anything newer and draws a
receipt on the exact-tie residual — it is the only road that cannot lose her
words.

**THE ONE ASK — confirm, please, and describe:**

> **Is the client-side EMPTY-BODY-AS-DELETION detection live?** Touchpoint
> #2 item 7 relocated it (server-side detection cannot operate on
> ciphertext: under E2EE the bridge encrypts even the empty body, so "the
> body is empty" is a fact only a key-holding client can see — **detect it
> after decrypt**). The 14d closing report confirmed journal-class E2EE live
> on both ends but did not say whether that relocation landed. **And say
> what the Day screen actually SHOWS for a day whose decrypted body is
> empty** — an absent day, or a present-but-blank one. Either is fine and
> neither needs changing for the bridge's correctness; Variorum simply wants
> to describe the outcome to the author honestly ("delete it here and it
> goes there" should mean what she thinks it means).

**Guarantee riding this, for your reassurance:** a deletion NEVER travels
for a day Fragments has diverged on. Variorum's round pulls before it
pushes, and a Fragments edit made after the Variorum deletion re-lands
through create-or-open as a fresh Variorum note — which takes that day out
of the deletion path entirely. A round whose pull stalled travels no
deletions at all. Nothing typed in Fragments is at risk from this change.

## CARRY-ITEM FOR FRAGMENTS (2026-08-30, Phase 13p) — Variorum's store is
## now ENCRYPTED AT REST; the bridge is UNTOUCHED; one invitation, nothing owed

**What changed on the Variorum side (context, not asks):** Phase 13p made
Variorum's LOCAL store encrypted at rest as one unit — SQLCipher
(Community, BSD) under GRDB, universal on every store on every device,
with at-open modes (silent Keychain release by default; biometric or
passphrase for those who dial it up) and ciphertext backups. Key custody
is the ONE suite secret you already know from 14b: the same encryption
passphrase and the same BIP-39 recovery phrase that wrap the sync vault
now also wrap the store key. **Nothing about the bridge's wire changed**:
the journal class stays E2EE end-to-end exactly as 14d left it, the
`journal_entries` freeze stands, and no ask in this item requires a
single Fragments-side line.

**One design fact worth knowing because it answers a question before you
ask it:** Variorum deliberately ships NO per-note locks (the author's
R13p-16 ruling — inside an unlocked app a per-note gate is a curtain,
not a boundary, and she declined to ship the lock-on-open theater her
own marketing will critique). So there is no "locked day" state, and no
day ever stops pushing to Fragments for protection reasons — the bridge
sees exactly what it always saw.

**THE INVITATION (the author's instruction — this is the item's point):**
whether Fragments wants its OWN at-rest story for its local store is
YOUR app's call, and she asked that this brief inform it. The framing
that holds the suite coherent: **local at-rest encryption is orthogonal
to the 14b server-readability ruling.** Fragments' non-journal content
stays server-readable BY DESIGN (its insights are the product — that
ruling is not reopened here); an encrypted local store on the client
covers the stolen-device / copied-file threat while leaving the insight
pipeline exactly as it is. Variorum's road (whole-store SQLCipher, raw
key in device custody, wraps under the suite passphrase) is documented
in `notes/plans/phase-13p-note-protection.md` + its spike memo if the
pattern is useful; your stack and your call. Her stated goal, verbatim:
finishing this encryption *"lets me finish fragments and have a
cohesive privacy policy."*

**The cohesive-policy half:** the suite privacy story is being briefed
to the stargazing.tech agent in the same phase
(`notes/stargazing-privacy-policy-brief-13p.md` in the Variorum repo —
she carries it). Its three tiers name Fragments honestly: E2EE for the
journal class · local-encrypted-at-rest where an app has built it ·
server-readable by design for Fragments insights, with the why stated
plainly. If any sentence there misdescribes Fragments, say so through
this channel before the policy finalizes.

**Also coming, separately:** Phase 13y (pre-release) will carry an
abuse-limiting brief through this same channel (per-account
quotas/rate-limit design shared across the suite) — noted so it is
expected, not a surprise. And the 13l carry-item's ONE ASK above
(empty-body-as-deletion detection + what the Day screen shows) is still
open and still wanted; nothing here supersedes it.

## CARRY-ITEM FOR FRAGMENTS (2026-08-30, the pre-13u round, Act 6) — the
## ENGINEERING BRIEF for Fragments' own at-rest encryption (extends the
## 13p invitation directly above; still your call, still nothing owed)

The item above is the invitation; this is the transferable engineering,
so that if Fragments takes it up, it starts from Variorum's measured
facts instead of re-learning them. Her running order pairs this with
Fragments' launch tasks (row 3: *"fragments encryption"* means your own
at-rest/local story beyond the shared journal class — her confirmation
2026-08-25).

**The road Variorum proved, in the order that mattered:**

1. **Dependency shape:** SQLCipher Community (BSD) via a four-line GRDB
   fork (tag-pinned) + Zetetic's official SPM package (4.18.0). Any new
   dependency is your author-approval item exactly as it was here.
2. **Key the connection RAW, never by passphrase:** `PRAGMA key =
   "x'<hex>'"` on EVERY connection. `usePassphrase` runs a ~165 ms KDF
   per open (measured; pinned at the call site here). Derivation happens
   once, in key custody — never per-connection.
3. **The one-time migration is `sqlcipher_export()`**, built crash-safe
   at every boundary and SIGKILL-drilled on a byte-copy of the real
   store BEFORE the real store is touched (<1 s at Variorum's corpus).
   The drill is the acceptance gate, not the suite.
4. **Backups become ciphertext, and every backup/integrity code path
   that re-opens the store now needs the key** — Variorum's spike found
   this as a LOUD refusal, not a silent leak, but only because the
   backup road was audited first (the "one-commit rule"). Audit yours
   before flipping.
5. **Zero-plaintext claims need a WAL checkpoint first** — the WAL can
   hold plaintext pages after the main file is ciphertext; scan after
   checkpointing or the scan lies (a Variorum test-pin lesson).
6. **Measured costs, for expectation-setting:** ~1.0× keystroke
   overhead, ~1 ms keyed open, `secure_delete` ON with no measurable
   breach, FTS5 present in the prebuilt.

**Key custody — the suite-coherent option:** Fragments already trusts
the suite account and its 14b vault, so its store key can be wrapped by
the SAME encryption passphrase + BIP-39 recovery phrase rather than
inventing a new secret — the suite's one-secret doctrine (Variorum's
R13p-4) extended rather than forked. The simplest v1 is Variorum's
default: silent device-Keychain mint at first launch, no ceremony, with
the passphrase/recovery wraps as the recovery legs. The at-open-modes
family (biometric/passphrase gates, lobby, re-lock) is OPTIONAL
Variorum-shaped furniture — whether Fragments wants any of it is a
product call, not part of the invitation.

**Keychain lessons paid for this week, so you don't pay twice:** on
macOS, a write carrying a biometry ACL or `kSecAttrSynchronizable`
lands in the DATA-PROTECTION keychain, but a read without
`kSecUseDataProtectionKeychain` searches the FILE-BASED one — writes
"succeed" and reads miss (iOS is immune; it has only the one keychain).
And the custody rule that incident produced: **never delete a key's old
home on the strength of a write alone — verify the new item reads back
through the production read path first** (Variorum's `CustodyHandover`).
Also decided here 2026-08-30 (QUESTIONS #82): Variorum BINDS its store
key to the device so it stops riding login-keychain migration/backups —
on iOS you get that for free.

**Reference implementations** (Variorum repo, read-only to you as ever):
`notes/plans/phase-13p-note-protection.md`, `notes/plans/phase-13p-spike-memo.md`,
`Sources/VariorumCore/Persistence/StoreEncryptionMigration.swift`,
`StoreKey.swift`, and `notes/plans/phase-13p-fix-dp-keychain.md` for the
keychain incident. Questions come back through this channel; she
carries everything.

## CARRY-ITEM POINTER (2026-08-31) — the lockbox reply

Fragments' `phase-20.9-memo-lockbox.md` (their journal at-rest encryption spec) was reviewed by the
Variorum architect at the author's instruction; the full reply — her rulings (biometry-only gate;
lock-ON requires enrollment and retires escrow; the un-locked two-item default stands; the minimal
prompting cycle; no cross-app level enforcement) plus answers to all seven §6 questions and the
findings (the free-page/WAL residue fix, the claims-table clauses, the visible-refusal replacement
for the extinct pre-E2EE corner) — is **`notes/fragments-lockbox-reply-2026-08-31.md`**, written
self-contained for the Fragments agent. She carries it; Batch A's hold lifts at her go.

## CARRY ITEM (2026-08-31) — can a Fragments-only account ever enroll? (the passphrase-set ceremony question)

**Provenance:** surfaced in the lockbox exchange ("some people will only use fragments"), carried by
the author to the Variorum (pre-13u successor) architect the same night. Recorded here so it
survives; NOT this round's build on either side. The suite-side facts below are the Variorum
architect's, from canon.

**The question, hers verbatim-faithful:** *"if fragments can't sign up and mint its own token,
that's an issue for it, right? can i give fragments the ability to do that? or will it cause other
issues?"* — plus the lockbox thread's sharper half: whether a Fragments-only account can set its
suite passphrase anywhere outside the Variorum app; if not, a Fragments-only user can never enroll
and therefore never lock.

**Suite-side facts (Variorum canon, 14a/14b/14c/14d):**
1. **Sign-up + tokens: ALREADY POSSIBLE without Variorum.** There is ONE stargazing account, whose
   home and OAuth 2.1 issuer is the Variorum Supabase project; signups are OPEN with SMTP + branded
   links (14d), and Fragments signs in DELEGATED through the suite issuer's browser flow. A
   Fragments-only user can create the account and hold tokens today — IF Fragments' sign-in flow
   surfaces the signup door. If it doesn't, that is a Fragments-side FACE fix over the same issuer,
   not a suite change. **The forbidden shape is a second auth/account system** — that would
   resurrect exactly what 14d retired ("there is a single stargazing account").
2. **The vault EXISTS for new accounts** — per-user `key_vault` provisioning at signup was
   generalized at 14c.
3. **The passphrase-SET ceremony lives ONLY in Variorum today** — the answer to the lockbox
   thread's question is currently NO. The ceremony is client-side crypto against the account's
   RLS'd vault (Argon2id-derived wrap of the master key, BIP-39 recovery mint, CAS'd `revision`
   writes — the 14b format); nothing SERVER-side prevents another client from performing it.
4. Layer separation, so nothing gets conflated: the SUITE passphrase/vault (sync-payload E2EE,
   14b) ≠ Variorum's store key (13p, device-bound per #82) ≠ Fragments' own at-rest lockbox (the
   2026-08-31 reply above). The Fragments-only enrollment question concerns the FIRST layer only.

**The roads (her design call — none is ruled):**
- **(a) Fragments implements the SAME ceremony against the SAME vault, to a WRITTEN shared spec.**
  Right if Fragments-only users are a real audience she wants enrolled/locked. Cost, named
  honestly: a second implementation of the suite's most safety-critical custody flow — the
  forked-brains drift class at suite scale. The mitigation is a FORMAT SPEC as a contract-file
  deliverable (KDF params, wrap format, BIP-39 wordlist/derivation, the CAS discipline, and the
  rotation/Replace-Keys semantics INCLUDING the new stale-copy recency-warning doctrine), so both
  apps implement one written format and neither app's code is the de-facto spec. The Variorum side
  owes that spec at her word (a future carry item; candidate moment: beside 13y's abuse brief).
- **(b) Accept-and-state the degraded state:** Fragments-only users are unenrolled until they
  first touch Variorum; Fragments' lockbox/journal-class behavior for the unenrolled must then be
  DEFINED and honest (its side's call), never a silent difference.
- **(c) A web-hosted ceremony on stargazing.tech is NOT recommended** — client-side crypto in a
  browser is a different trust posture, and the v1 posture has no web app by ruling.

**One-secret doctrine binds any road:** whatever sets the passphrase, both apps present ONE
passphrase identity to the user — never a "Fragments passphrase" beside a "Variorum passphrase."

**HER FOLLOW-UP (2026-08-31, same night — verbatim: "can you have a subagent write that brief
now? I'd like to just carry it to fragments now, I think that's what would be most useful"):** the
brief is written NOW as a pre-13u-round architect-side deliverable (the Act 6 class) — see the
pointer below once it lands. It equips her Fragments conversation with the FACTS and the ceremony
format spec; it does not pre-decide road (a) — that ruling is hers with the Fragments agent.

## CARRY-ITEM POINTER (2026-08-31) — the enrollment & suite-ceremony brief

The brief her follow-up above ordered is written: **`notes/fragments-enrollment-brief-2026-08-31.md`**,
self-contained for the Fragments agent (the lockbox reply's precedent). It carries: the two-layer
answer (signup + tokens already possible at the one issuer; the passphrase-SET ceremony
Variorum-only today, with nothing server-side preventing another client); the FULL ceremony format
spec read from code with file:line citations — Argon2id v1 parameters (64 MiB / t=3 / p=1 /
16-byte salt / 32-byte output, NFKD, descriptor-is-truth), the RFC 3394 wrap tree (master wrapped
twice; corpus + journal_bridge class keys under master), the 12-word BIP-39 derivation
(PBKDF2-HMAC-SHA512 ×2048 → HKDF-SHA256 under `variorum.suite.e2ee.v1`/`recovery-wrap-key`), the
`key_vault` row + the `revision` CAS discipline (including the nil-omission PATCH trap), the
enrollment/set/change flows and the ruled write-down/re-enter choreography, and the `e1:` AAD
grammar with the bridge's day binding; what Fragments already holds vs what a set-ceremony build
would add; the binding suite doctrines (one-secret, R-4/R-6, the NEVER list, T1's stale-copy
recency warning, the layer separation); and the open (a)/(b) ruling stated without a
recommendation — that ruling is hers with the Fragments agent. No secrets appear in it. She
carries it; questions come back through this channel.

## CARRY-ITEM POINTER (2026-09-01) — the TWO-POSTURES brief (the revision Phase 20.10 waits for)

**`notes/fragments-postures-brief-2026-09-01.md`** — self-contained for the Fragments agent, written at
her word after the encryption-clarity sitting that produced Variorum's `pre-13x` design
(`notes/plans/pre-13x-postures-design.md`). It carries: the vault + ceremony spec UNCHANGED (the Aug-31
brief's §2 stands, so 20.10 can start); the suite's new custody model — two postures, Standard/Castle,
per app; escrow-follows-the-posture simplified to Standard-mirrors/Castle-doesn't; keys INSIDE the
encrypted store so one unlock covers content and sync (her "remove the sync difference from
unlocking"); the doors re-authorized (change-passphrase from any unlocked enrolled device; Replace Keys
and deletion by the ACCOUNT password; the near-empty typed confirmation); the cross-device
passphrase-change rule (vault is truth, local wraps are caches); the §6 answers that changed; the
tests to add (the interop fixture first); and what waits for pre-13x. It SUPERSEDES the Aug-31
lockbox reply's consistency map. She carries it; questions return here.

> **CARRY ITEM (2026-09-04) — the journal bridge is RETIRED on the Variorum side.** Variorum removed its
> half of the journal bridge from `main` (archived at tag `archive/fragments-bridge-2026-09-04`). Nothing is
> owed by Fragments: the 20.10 passphrase-set ceremony is moot for the bridge's sake (build it or not on
> your own merits); the journal-class E2EE bodies already in `journal_entries` are yours to keep or migrate;
> the `journal_bridge` class key remains in the suite vault format, dormant. UNCHANGED: the ONE
> Stargazing account and the suite issuer (14a/14d) — this retires the bridge, not the account. If the
> bridge ever returns it returns as shared rows on Variorum's own sync in a collaboration era, designed then.
>
> **TWO ASKS, both from the retirement's cold review (2026-09-04):** **(1) ORDER — do NOT tombstone or
> delete `journal_entries` rows on the sync-visible road until Variorum says its INSTALLED Mac build no
> longer runs the bridge.** Until that build is refreshed (or its journal bridge disconnected), it still runs
> the old engine, and that engine lands a Fragments tombstone as a BLANKED Variorum entry (the archived
> landing rule at `BridgeEngine.swift:384-517` on the tag). Variorum will send the word; nothing on your side
> waits on it except deletions. **(2) VERIFY, and REVOKE any leftover, of the Variorum bridge's Fragments-project
> sessions server-side** (the delegated `custom:stargazing` sign-ins Variorum's bridge held). The author's
> Disconnect on her installed build logs its session out best-effort; Variorum otherwise only clears its LOCAL
> copy of that refresh token, and Supabase refresh tokens never expire on their own — so a session that missed
> the logout stays valid until you revoke it or the author signs out of Fragments globally.
