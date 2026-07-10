# Phase 9c — Step 6 runbook (the gate sitting, executable end to end)

**What this is:** the self-contained checklist for Phase 9c's batched author-assist
gates — a FRESH session (or the author alone) can conduct every walkthrough and check
below with zero prior-session context. Written 2026-07-10 by the 9c implementer at
the author's request (coordinator relay); the completeness bar is the handoff rule:
if a gate question needs a prior session's context, this document is broken — fix it
here. The ordinary phase handoff references this file as its Step 6 arm.

**Cast:** the author (dashboards, devices, sign-ins) + optionally the coordinator
(authorized 2026-07-10 to execute the SQL cutover via her PAT). **Risk posture:
LOW** (author, 2026-07-10): neither app holds important content yet — daily use was
deliberately deferred until after this phase — so the store is effectively pre-live.
The backup still runs (seconds-cheap, rehearses the path); no drama is owed,
correctness discipline is unchanged.

**The two projects:**

| | Variorum | Fragments |
|---|---|---|
*[removed for publication]*
| Role here | the mirror + the sign-in issuer of record | the OIDC identity + the journal bridge's backend |
| Key state | JWT signing keys (ECC P-256) | same |

**Deployed auth topology (Step 0, 2026-07-10):** Variorum has custom provider
*[removed for publication]*
Variorum is a registered confidential OAuth client of Fragments' OAuth 2.1 Server
*[removed for publication]*
`.env.fragments-oauth.local`); the login/consent page serves at Fragments' Site URL +
Authorization Path (the spike used `localhost:3000` + `/consent.html`; production is
the stargazing.tech page — spec in `notes/fragments-consent-page-spec.md`).

**The §12 choreography this sitting executes, in one line:** keys in → Mac signs in
(backfill runs + pushes) → phone signs in (converges) → totality verified on both +
mirror → THEN `04_auth_rls.sql` runs → probes → both devices sync under auth →
device rounds → the bridge + real-Fragments pass.

---

## Gate 0 — Preconditions (author, ~10 min)

1. **Fill the two publishable keys** in `App/Variorum/Shared/ProjectConfig.swift`
   (`variorumPublishableKey`, `fragmentsPublishableKey` — from her untracked env
   files). They are publishable by design post-cutover and committable; commit at
   the closeout. Build after editing. *(Until filled, the sign-in button is
   disabled with a visible hint — that is the designed dormant state.)*
2. **Variorum dashboard → Authentication → URL Configuration:** add
   `variorum://auth-callback` to the Redirect URLs. (The spike's
   `http://localhost:3000/callback.html` entry can be REMOVED at the same visit —
   its purpose is served.)
3. **The consent page must be reachable** at Fragments' Site URL + Authorization
   Path. Either: the production stargazing.tech page is live and the Fragments
   OAuth Server page points at it (REMEMBER the page's save trap — it silently
   discarded values twice on 2026-07-10; reload the page to verify the values
   stuck), or, for this sitting only, keep the spike's local page:
   `cd Spikes/AuthPairingSpike && python3 -m http.server 3000` (Site URL
   `http://localhost:3000`, Authorization Path `/consent.html`).
4. **Both apps installed as RELEASE builds** (see Gate 4 for the phone; on the Mac
   either a Release build or a debug launch with the `-VariorumRealStore` opt-in —
   plain debug opens the fenced dev store where sync/sign-in surfaces are absent
   by design).

## Gate 1 — The pre-cutover backup (author, ~1 min)

With Variorum QUIT on the Mac:

```bash
STORE=~/Library/Containers/io.lduarte.Variorum/Data/Library/Application\ Support/Variorum/variorum.sqlite
sqlite3 "$STORE" ".backup '$HOME/Desktop/variorum-pre-9c-cutover.sqlite'"
sqlite3 ~/Desktop/variorum-pre-9c-cutover.sqlite "PRAGMA integrity_check;"
```

**Expected:** `ok`. (The A1 rotating backups also live beside the store in
`…/Variorum/Backups/` — this manual copy is the rehearsal + belt.)

## Gate 2 — Mac sign-in + backfill (author; the coordinator watches)

1. Launch Variorum (Release / opted-in). The sync status row (bottom of the
   sidebar) reads **"Signed out · [Sign in…]"**.
2. Click **Sign in…** → **Sign in with Fragments…** → the browser sheet runs:
   Variorum authorize → Fragments authorize → the consent page (sign in with the
   Fragments email+password if prompted; approve) → the sheet closes.
   **Expected:** the Account sheet shows "Signed in as <her email>"; the status
   row begins syncing. *(Consent may auto-skip — the client+scope was approved at
   the spike.)*
3. **What just happened automatically:** the owner-adoption backfill ran BEFORE
   the first push (every NULL `owner_id` row — live and tombstoned — stamped with
   her Variorum `auth.uid()`, expected value
   *[removed for publication]*
   round pushed the adopted rows.
4. **Verify locally** (app can stay open; reads are safe):

```bash
for t in container block reading tag reference; do
  echo -n "$t NULL-owner rows: "
  sqlite3 "$STORE" "SELECT COUNT(*) FROM $t WHERE owner_id IS NULL;"
done
```

**Expected:** five zeros. Also spot-check the value:
`sqlite3 "$STORE" "SELECT DISTINCT owner_id FROM container;"` → exactly
*[removed for publication]*

5. **Wait for the round to finish** (status row shows "Synced HH:MM", 0 pending),
   then **verify the mirror** (SQL editor, or the coordinator via PAT):

```sql
select 'container' as t, count(*) from container where owner_id is null
union all select 'block', count(*) from block where owner_id is null
union all select 'reading', count(*) from reading where owner_id is null
union all select 'tag', count(*) from tag where owner_id is null
union all select 'reference', count(*) from reference where owner_id is null;
```

**Expected:** five zeros. **Do not proceed to Gate 5 until they are.**

**If a count is non-zero locally:** quit and relaunch the app signed in (adoption
re-runs at every signed-in launch, idempotently) — or sign out and back in.
**If non-zero on the mirror only:** the push hasn't drained; "Sync now" and re-check.

## Gate 3 — Phone sign-in + convergence (author)

1. **Install as Release** — Xcode: open the project, select the VariorumMobile
   scheme → Product → Scheme → Edit Scheme… → Run → Build Configuration →
   **Release**, then run to the device once. **Why Release (the A4 fence):** a
   DEBUG build launched from the home screen always resolves the fenced dev store
   (`Variorum-dev/`), where sync and sign-in are OFF by design — the Xcode-launch
   opt-in doesn't exist for home-screen launches, and alternating would split the
   journal across two stores.
2. Launch on the phone → the sync row reads "Signed out" → **Sign in…** → the same
   delegated flow (the phone's browser sheet).
3. **Expected:** sync configures and the first pull converges the corpus. Spot
   check: an entry authored on the Mac is present; the phone's rows are owned
   (the phone store isn't trivially shell-accessible — convergence + the Gate 5
   probes stand in; the Mac-side dump-compare in Gate 6 is the byte-level check).

## Gate 4 — The cutover: `04_auth_rls.sql` (coordinator via PAT, or author paste)

Execute `Server/supabase/04_auth_rls.sql` — the committed file verbatim, nothing
improvised — against the VARIORUM project. (Author authorized the coordinator's
PAT execution 2026-07-10; the SQL-editor paste is the equivalent manual path.)

**Post-cutover probes (coordinator or author; `$VURL` = the Variorum project URL,
`$KEY` = the publishable key):**

1. **The bare key is refused** (the demotion, proven):

```bash
curl -s -w "\nHTTP %{http_code}\n" -X POST "$VURL/rest/v1/rpc/sync_pull" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" -d '{"since_seq": 0, "max_rows": 1}'
```

**Expected:** HTTP **401 or 403** with a PostgREST permission error (code `42501`,
`permission denied for function sync_pull`) — NEVER a JSON row array. Same result
with the Authorization header omitted entirely. Also probe a direct table read:

```bash
curl -s -w "\nHTTP %{http_code}\n" "$VURL/rest/v1/container?select=id&limit=1" \
  -H "apikey: $KEY"
```

**Expected:** permission denied (RLS + revoked table privileges — the Data API is
dead as a door).

2. **Her session still syncs:** on the Mac, click **Sync now**. **Expected:** the
   row returns to "Synced HH:MM" with no error. (That request rode her real
   session token through the new auth gates — the positive probe.) Repeat on the
   phone.

3. **Cross-device round-trip under auth:** create a journal entry on the phone →
   "Sync now" on both → it appears on the Mac (and vice versa with a Mac edit).

**FAILURE → RECOVERY (the RLS-lockout rollback):** if after the cutover her
session is refused (both devices show a persistent sync error naming
`sync_push`/`sync_pull` or `owner_id`):

- **Data is safe by construction** — a refused round leaves the outbox and cursor
  intact on both devices; nothing needs restoring. Diagnose first: the error text
  rides the status row's tooltip verbatim.
- `owner_id mismatch …` → a row escaped the backfill: re-run Gate 2 step 4/5's
  checks, relaunch signed-in (idempotent adoption), sync, re-probe.
- `sync requires an authenticated user` / 401s → the session: sign out, sign back
  in; check the provider + redirect URL config from Gate 0.
- **Full rollback** (returns the mirror to the pre-cutover key-auth posture; run
  in the SQL editor / via PAT):
  1. Re-run `Server/supabase/03_visibility_horizon.sql` IN FULL (its
     `create or replace` of both functions restores the un-gated bodies —
     CREATE OR REPLACE preserves grants, so also:)
  2. `grant execute on function sync_push(jsonb) to anon, authenticated;`
     `grant execute on function sync_pull(bigint, int) to anon, authenticated;`
  3. (RLS enablement and the table-privilege revokes may STAY — the app only ever
     speaks through the two functions.)
  4. Verify: the Gate 4 bare-key probe now returns rows/`[]` again; both devices
     sync. Then regroup — the retry is another Gate 4 after the cause is fixed.

## Gate 5 — The device rounds (Phase 8's deferred, folded in here)

All on Release builds, signed in, post-cutover:

1. **Offline capture:** phone in Airplane Mode → create a journal entry + edit an
   existing block → status row shows pending/queued (offline is free) → Airplane
   Mode off → foreground → **Expected:** the round drains; the Mac pulls both.
2. **Two-way edits:** distinct blocks of the same post edited on each device →
   sync → **Expected:** both edits on both devices, no conflict variants.
3. **The S5 same-entry race:** put BOTH devices offline → edit the SAME block's
   text differently on each → bring both online, sync both →
   **Expected:** the store converges byte-identical; the block gains EXACTLY ONE
   extra variant labeled `conflict` (the losing text — check the block's fan:
   Show Takes / the ⑂ badge); nothing lost on either side.
4. **Status-row expectations throughout:** failures name their cause and keep a
   Retry button; "pending N" counts drain to zero on a clean round; neither
   device ever shows a silent stall.

## Gate 6 — The bridge + the real-Fragments pass (9b's deferred gate)

1. On the Mac: **Account… → Connect the Fragments journal** — her Fragments
   email+password (QUESTIONS #16, ratified (c): a direct Fragments-project
   session; only the session persists, never the password).
2. **Expected:** the bridge status row goes configured; the first bridge round
   runs after the next sync round. If Fragments' `user_settings` hasn't synced a
   `local_user_id` yet the bridge FAILS CLOSED with a visible note and pushes
   nothing — that is designed behavior, not a defect (it clears once her
   Fragments account has synced from the Fragments app).
3. **The two-way day (one manual pass):**
   - Write in the FRAGMENTS app (phone) for today → wait ~2 min (their pull
     horizon + the bridge cadence) or click the bridge row's manual trigger →
     **Expected:** the body lands in Variorum's journal entry for that date.
   - Edit that entry in VARIORUM → after the next bridge round, **Expected:** the
     Fragments Day screen shows the updated body.
   - Edit in BOTH before a round → **Expected:** Variorum keeps its text, the
     Fragments body arrives as a `fragments`-labeled variant on the entry's
     block (nothing typed anywhere is lost), and the next push re-projects
     Variorum's truth to Fragments.
4. **Dump-compare (the byte-level check):**

```bash
sqlite3 "$STORE" "SELECT c.entry_date, v.working_text FROM container c
  JOIN container_block cb ON cb.container_id = c.id AND cb.deleted_at IS NULL
  JOIN variant v ON v.id = COALESCE(cb.chosen_variant_id, (SELECT default_variant_id FROM block WHERE id = cb.block_id))
  WHERE c.profile = 'journal' AND c.entry_date = date('now', 'localtime') AND c.deleted_at IS NULL;"
```

   versus the same day's body in the Fragments app (visual). **Expected:**
   identical text (modulo Fragments' leading/trailing-whitespace trim — a
   recorded contract caveat, not a defect).
5. **Ask-13 conditional (from the 9c plan, Step 6(iv)):** if Fragments' 15.7
   `replaced`-receipt is LIVE AND FINAL on hosted by this sitting (their deploy
   ping is the signal — as of 2026-07-10 it has NOT arrived), the fake server
   gets pinned to the final shape and the consumption path lands under the three
   discrimination rules (contract ask 13; NEVER unconditional). Otherwise this
   stays a named follow-up on their ping — do nothing here.
6. **The week-one dump-compare ritual begins** once she daily-drives (repeat
   step 4 after the first week; Phase 12's soak formalizes it).

## Gate 7 — Closing the sitting

- Re-run the Gate 2 totality queries (local + mirror) one last time — still zeros.
- Confirm the spike's localhost redirect URL is gone from Variorum's URL config
  (Gate 0.2) and the Fragments Authorization Path points wherever the consent
  page permanently lives.
- Record per-gate results in the phase plan's closeout (the coordinator or the
  author notes anything surprising verbatim — surprises are findings).
- The pre-cutover backup file can be kept or deleted at will once Gate 5 passes
  (the A1 rotation continues regardless).

## Quick reference — expected failure shapes vs defects

| Symptom | Meaning | Action |
|---|---|---|
| Sign-in button disabled + "keys not configured" | ProjectConfig placeholders unfilled | Gate 0.1 |
| Consent page 404s | Authorization Path not saved (the known dashboard save trap) | Re-save, reload to verify, retry |
| `callbackWithoutCode` error after browser sheet | Consent denied/cancelled, or redirect URL not allow-listed | Gate 0.2; retry |
| Sync error `permission denied for function` post-cutover with HER session | Grants drifted — should be impossible if 04 ran verbatim | Rollback path, Gate 4 |
| Sync error `owner_id mismatch` | A row escaped the backfill | Relaunch signed-in (idempotent re-adoption), sync, re-probe |
| Bridge note "canonical user … has not synced" | Fragments `user_settings` empty — fail-closed gate | Open the Fragments app, let it sync, retry |
| Bridge pauses a day, "two live entries" | The designed duplicate-day pause | Hand-merge/delete/re-date the extra entry |
| Phone shows no sign-in door | Debug build from home screen = fenced dev store | Gate 3.1 (Release install) |
