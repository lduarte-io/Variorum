# 13y — THE DEPLOY CHECKLIST (the ONE §12 lockstep event, marker 8 → 9)

*Step 6's artifact, on the pre-13x checklist's form (that file is the worked example; its
§10 standing caveat RETIRES at this event — the completion guard rides 12's canonical
body, text-verified below). Executed at HER window per R-13y-2: the orchestrator runs the
mirror deploy through the stored PAT (the pre-13x §16 arrangement); if the permission
classifier blocks the mutating call, the exact command is prepared and SHE fires it via
the `!` road (the 13j precedent). The artifact is `Server/supabase/12_phase13y_tenant_seq.sql`;
its pins are `AuthRLSDDLTests`' 12 block; the grant sweep is
`maintenance/14c-post-deploy-grant-sweep.sql` (extended for 12, incl. the LIVE
schema-usage facts).*

## 0. WHEN — and the one sequencing rule

**Only after the ladder closes and the finals are green; then ONE sitting.** The moment
the marker bumps to 9, BOTH installed marker-8 builds (her Mac's
`/Applications/Variorum.app` and her phone) VISIBLY refuse to sync — outbox intact,
cursor unmoved, the §12 grammar; offline free while they wait — until the marker-9 builds
replace them. The window: (1) the pre-deploy summary (below) + the server half; (2) the
Mac Release refresh behind the A1 rail; (3) the phone build + install (needs HER); (4)
her live round each direction + the verifications.

## 1. PREP (before the window; nothing mutates)

- [ ] The ladder CLOSED (all three rounds' dispositions final; ledger row 12 done).
- [ ] **THE FINALS, green first:** full core (`swift test`) · the FULL Mac suite in a
      zero-instance window — **green modulo the FIVE adjudicated macOS-27 kickoff deltas
      (the ENVIRONMENT ACTS list); any SIXTH red is 13y's to answer before the deploy** ·
      iOS build · mobile suite (with the standing 4 known issues). Exact counts into the
      plan's closeout slots.
- [ ] `git status` clean, main == origin/main; the tip recorded in the window's paragraph.
- [ ] **The A1 rail:** WAL-safe backup of her real store into `Backups/` with
      `PRAGMA integrity_check` = ok (`variorum-backup-<stamp>-pre-13y-window.sqlite`).
      12 DROPS NO DATA TABLE and REWRITES NO ROW (counters, challenge + budget tables,
      function replacements, one sequence drop, grants).
- [ ] Zero real-store instances at the install steps (`pgrep -fl
      'Variorum.app/Contents/MacOS'`, discriminate by PATH; her app quit by HER).
- [ ] Re-read 12's header + verification tail once more; confirm the sweep names every
      signature 12 creates (the AuthRLSDDL pin is the check).

## 2. THE PRE-DEPLOY SUMMARY (R-13y-4's governance rider — HER LAST HONEST EXIT, spoken before anything fires)

Named to her, one line each, at the window's start:
- [ ] **#144(a) — the key-proof challenge's shape (PROVISIONAL):** per-request single-use
      server nonces over a Vault-held v2 secret; kp transits only at enroll/rotation; a
      control-plane compromise could recover the MAC secret (integrity-only, recorded).
- [ ] **#144(b) — the abuse-guard numbers (PROVISIONAL):** 500k-row lifetime first-load
      pool · 50k/rolling-24h steady-state · 2,000/call batch cap; rotations exempt;
      truncate resets the pool.
- [ ] **#144(c) AS AMENDED at the ladder:** the 10-min re-auth window guards
      `account_data_truncate` ONLY (the original both-doors ruling would have frozen the
      13j janitor — the round-1 BLOCKER, re-ruled).
- [ ] Her word to proceed (or any objection resolves BEFORE the deploy — this is the
      exit, not a re-litigation).

## 3. THE PRE-DEPLOY SNAPSHOT (read-only, the stored-PAT query road; into the window's paragraph)

- [ ] `select value from sync_meta where key = 'lockstep_version';` → **8**.
- [ ] Row counts: `container` · `block` · `variant` · `commit_point` · `key_vault` (1).
- [ ] **The floor facts, recorded for step 5's carry-over check:** her owner's
      `max(server_seq)` across the data tables (one query per the 12 initializer's own
      list), her `device_cursor` rows (`last_seq` each), `max(purged_seq)` from
      `purged_row`.
- [ ] The function set: the 11-era signatures present (`sync_push(jsonb,text,text)` etc.);
      `sync_challenge`/`key_proof_enroll`/`sync_visibility_horizon_ms` ABSENT;
      `sync_server_seq` sequence EXISTS.
- [ ] The vault row: `revision`, `corpus_key_id`, `key_proof_hash` (64-hex, landed at the
      pre-13x window).

## 4. THE DEPLOY

- [ ] `Server/supabase/12_phase13y_tenant_seq.sql` WHOLE, in ONE session, via the stored
      PAT query road (the file opens `begin;` closes `commit;` — never statement-by-
      statement). Expected `[]`. A raised error rolls the WHOLE file back, marker
      untouched — read, fix, re-run (the in-file guard admits a retry when nothing
      landed).
- [ ] Classifier block ⇒ the exact command handed to her for the `!` road; output read
      in-conversation.

## 5. VERIFICATION (read-only; ALL pass before any install)

- [ ] Marker: `select sync_schema_version();` → **9**.
- [ ] Run 12's OWN verification tail (the queries at the file's end), every line its
      stated answer — including the `set role variorum_definer` extensions probes (hmac +
      gen_random_bytes — the definer-context checks the deployer-context probe masks),
      the horizon function → **2000**, and the two fold-in checks on the FOUR-parameter
      `key_vault_update` (the guard's `VARIORUM_ROTATION_ROWS_REMAIN` in the CANONICAL
      body — **the pre-13x §10 caveat retires on this line**; the overlay is superseded).
- [ ] The function set: every 11-era gated signature ABSENT (a survivor is a
      challenge-free door — the tripwire); the 12 set present with `key_proof`
      DEFAULTLESS everywhere (NIT-4); ownership `variorum_definer` throughout;
      `account_purge` stays postgres.
- [ ] `sync_server_seq` sequence GONE (fail-loud closure).
- [ ] **THE GRANT SWEEP** — every row OK/INFO; specifically the NEW `schema-usage` facts
      (`has_schema_privilege('variorum_definer', extensions|vault, 'USAGE')` = true,
      LIVE), no UNEXPECTED FUNCTION (the 11-era spellings must-not-appear), the vault
      posture rows unchanged.
- [ ] **THE FLOOR / CARRY-OVER (the phase's own requirement):** `sync_tenant_seq` holds
      her owner's row with `last_seq` ≥ every step-3 recorded number (data max, cursors,
      purged max, rotation seq if any) — her cursors stay valid by construction.
- [ ] The two new tables (`key_proof_challenge`, `sync_write_budget`) empty, FORCE RLS,
      owner policies (the sweep covers the posture).

## 6. THE INSTALLS (the same sitting)

- [ ] The Mac Release refresh behind the A1 rail (the standing recipe: Release build in a
      clean worktree, copy to `/Applications`, hashes recorded; zero-instance window).
- [ ] The phone build + install (Xcode + her device; marker-9).

## 7. THE FIRST ROUNDS (the acceptance evidence lands)

- [ ] **Her Mac's first round ENROLLS then RUNS:** `key_proof_enroll` fires once (the
      signer's transparent enroll — kp1 authorized by the stored hash, kp2 lands);
      `select count(*) from vault.secrets` gains her account's `kp:` row;
      `key_vault.key_proof_hash` now = SHA-256(kp2); the round completes (status idle, no
      refusal) — **the challenge road live on the real mirror.**
- [ ] **The cursor carry-over, proven:** her Mac's pull resumes from its standing cursor
      (no reset, no re-download; the round's row counts ordinary); same on the phone.
- [ ] The phone's first round (same master ⇒ same kp2; enroll already landed ⇒
      ALREADY_ENROLLED swallowed as success) completes.
- [ ] `device_cursor` carries BOTH devices' rows advancing under per-tenant seqs.
- [ ] Her live round each direction (a note Mac→phone, a note phone→Mac) — the standing
      sync-kind acceptance.
- [ ] **The owed live probes:** (a) **amr refresh-survival** — decode her session's JWT
      access token before and after a refresh; the `amr` password timestamp must be
      byte-identical (content-free check; if it BUMPS, the truncate guard is hollow —
      record and re-open #144(c)'s design at the checkpoint, the door has no production
      caller yet so nothing live breaks); (b) the schema-usage sweep facts (step 5)
      stand as the Vault/extensions live evidence; (c) `account_purge`'s best-effort
      vault-secret delete is NOT window-verifiable (it fires only on account deletion) —
      the recorded latitude stands, the fake's twin carries it.
- [ ] A quota sanity read: `sync_write_budget` holds her owner's row with plausible
      counts; her rounds nowhere near the numbers (normal use never meets the guard).
- [ ] The grant sweep ONCE MORE (the record's belt).

## 8. ROLLBACK POSTURE

- **Before commit:** one transaction — any error rolls the whole event back; marker stays
  8; both installed apps keep syncing.
- **After commit:** no un-deploy (a marker-9 mirror is served only by marker-9 clients). A
  defect found live is fixed the 13j way: a `maintenance/13y-window-<fix>.sql` artifact
  (drop + recreate + re-own + re-grant, one transaction), pinned in `AuthRLSDDLTests`, run
  in the SAME window — never a posture relaxation, never a re-run of 12 (the guard
  refuses; the override is for a genuinely rolled-back run only). **A 12 re-run after a
  successful deploy would also be safe on the guard's own terms — the completion guard
  now rides the canonical body, so no overlay re-application exists to forget** (the §10
  class is structurally closed).

## 9. THE RECORD AT CLOSEOUT

- SyncSpec §12's running record gains the marker 8 → 9 entry (the file; the per-tenant
  counter + floor; the challenge protocol + enrollment's one-time land; the quota; the
  re-auth-on-truncate; NIT-4; the horizon function; the guard fold-in retiring the
  overlay; the window's evidence).

## 10. THE WINDOW'S RECORD (2026-09-24 — live, updated as the window runs)

**Opened 2026-09-24 at her word.** The pre-deploy summary (§2) spoken across the sitting's
first two turns — #144(a) explained to her question (the two-vaults disambiguation: Supabase
Vault holds ONLY kp2, a one-way MAC secret; the prose keys stay wrapped under her passphrase
and recovery phrase in `key_vault`; operator-level integrity access is pre-existing, kp2 adds
no read power), #144(b) framed against her own corpus numbers, #144(c)'s janitor amendment
walked through — **ALL THREE APPROVED, her words: "ok all are approved and i'm here, ready
for the sitting."** #144's ratification is thereby SPOKEN at the window; the checkpoint
records it formally.

**Prep:** ladder closed + finals green (the recorded tip `01b67382`, = origin/main, tree
clean). **The stored PAT was found DEAD** (HTTP 401 on a bare projects read — her planned
rotation had landed since pre-13x); she minted a fresh PAT into `.env.supabase.local` at the
window's start, verified live (HTTP 200) before anything else ran. 12's header + verification
tail re-read; the sweep-coverage prep line satisfied by `AuthRLSDDLTests`' 12 block in the
green finals.

**The pre-deploy snapshot (read-only, the PAT query road):** marker **8**; rows container
**229** · block **4,462** · variant **4,636** · commit_point **4,647** · key_vault **1**
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
own 19-table list, verbatim); `device_cursor` rows `3D4D5F8A…` → **76,143** and `53536eb5…`
→ **75,919**; `purged_row` max **76,149** — ABOVE data-max, the F-S1 purge-outruns-data case
LIVE in her own mirror, so the wide floor is load-bearing on day one; no rotation seq. **The
post-deploy carry-over bar: her counter row ≥ 76,149.** Function set: all 11-era signatures
present (`sync_push(jsonb,text,text)`, `sync_pull(bigint,text,integer,text,text)`,
`key_vault_update(jsonb,integer,text)`, …); `sync_challenge` / `key_proof_enroll` /
`sync_visibility_horizon_ms` ABSENT; `sync_server_seq` sequence EXISTS.

**Deploy · verification · installs · first rounds · probes · the sweep twice:** PENDING —
this record fills as each lands.
- SyncSpec §12's **I-1 record AMENDED**: the closure executed on the disclosure-probe's
  evidence; the envelope gains the Vault-held MAC secret line + the pre-enrollment-gap
  line (memo §7 edge 9).
- `notes/plans/pre-13x-deploy-checklist.md` §10's standing caveat marked RETIRED-BY-12.
- CLAUDE.md's environment note: macOS 27.0 recorded (the kickoff's fact).
- The window's paragraph in this file, the 13j shape (snapshot · deploy · verification ·
  installs · first rounds · probes · the sweep twice).
