# pre-13x — THE DEPLOY CHECKLIST (the ONE §12 lockstep event, marker 7 → 8)

*Batch 1b's deliverable (design §19 1b item 4; §3.10; §16's pre-authorization). Written as a checklist the
ORCHESTRATOR executes at the window — never a batch implementer. The artifact is
`Server/supabase/11_pre13x_postures.sql`; its pins are `AuthRLSDDLTests` (the 11 block), the grant sweep is
`Server/supabase/maintenance/14c-post-deploy-grant-sweep.sql` (extended for 11). The choreography is the 13j
window's (SyncSpec §12; `notes/plans/phase-13j-deletion-and-trash.md` "THE DEPLOY EXECUTED"), with the
postures event's own verifications added.*

## 0. WHEN — and the one sequencing rule

**Immediately BEFORE batch 2's migration + the Mac Release refresh + the phone install, never earlier.** The
moment the marker bumps to 8, BOTH installed marker-7 builds (her Mac's `/Applications/Variorum.app` and her
phone) VISIBLY refuse to sync — outbox intact, cursor unmoved, the §12 refusal grammar; offline is free while
they wait — and they keep refusing until batch 2's builds replace them. So the window is ONE sitting:

1. this checklist's server half (the orchestrator, under her standing pre-authorization — §16);
2. batch 2's Mac Release refresh behind the A1 rail (the orchestrator);
3. her one-time passphrase confirm on the Mac (batch 2's §11 migration — needs HER present);
4. the phone build + install (Xcode + her device — needs HER present) and its confirm.

**Pre-authorized (design §16):** her PAT is stored (`.env.supabase.local`, the 9c arrangement — the secret never
enters a transcript; a batch implementer never reads it); the orchestrator runs the mirror deploy without waiting
for her at the keyboard. If the session's permission classifier blocks the mutating Management-API call, the
deploy script is prepared and SHE runs it via the `!` road (the 13j precedent — never worked around).

**Never on the DEV store's mirror expectations:** there is ONE production mirror; the dev store never syncs (the A4
fence). Nothing here touches her real STORE — only the mirror and, at step 3 onward, the installs.

## 1. PREP (before the window; nothing mutates)

- [ ] `git log --oneline -1` on `main` shows 1b closed and batch 2's install-ready commit; `swift test` green at
      that commit (the gate's counts recorded in §19).
- [ ] **Zero real-store instances at the install steps** — `pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated
      by PATH; a real-store instance is quit by HER, never by a session. (The server half needs no zero-instance
      window: the running marker-7 app simply starts refusing.)
- [ ] **The A1 rail's local half:** a WAL-safe backup of her real store into `Backups/` with
      `PRAGMA integrity_check` = ok (the 13j window's shape: `Backups/variorum-<stamp>-pre-pre13x-window.sqlite`).
      The mirror half is satisfied by the pre-deploy snapshot (step 2) + local-truth repushability (the 14b/14c
      doctrine): 11 DROPS NO DATA TABLE and REWRITES NO ROW — it adds six nullable columns, replaces functions,
      and moves one privilege.
- [ ] Read `11_pre13x_postures.sql`'s header once more (six columns; the gate's peek-then-lock; the carry-through);
      confirm the sweep file names every signature 11 creates
      (`AuthRLSDDLTests.thePostDeployGrantSweepIsReadOnlyAndCoversEverything` is the pin).

## 2. THE PRE-DEPLOY SNAPSHOT (read-only, the stored-PAT query road)

Record in the batch-2 record, in this order:

- [ ] `select value from sync_meta where key = 'lockstep_version';` → **7**.
- [ ] Row counts: `container` · `block` · `variant` · `commit_point` · `key_vault` (expect 1).
- [ ] The vault row's state: `select revision, corpus_key_id from key_vault;` — and confirm the six columns are
      ABSENT (`select column_name from information_schema.columns where table_name = 'key_vault';`).
- [ ] The current function set: `select oid::regprocedure from pg_proc where pronamespace = 'public'::regnamespace
      order by 1;` — the six OLD signatures present (`sync_push(jsonb,text)`, `sync_pull(bigint,text,integer,text)`,
      `sync_horizon(text)`, `sync_purge_ledger(bigint,text)`, `sync_purge_execute(jsonb,text)`,
      `account_data_truncate(text)`).

## 3. THE DEPLOY

- [ ] Send `Server/supabase/11_pre13x_postures.sql` **WHOLE, in ONE session** via the Management-API query road
      (the file opens with `begin;` and closes with `commit;` — a statement-by-statement paste would defeat the
      wrapping; the 14c/I-3 discipline). Expected answer: `[]` (clean). A raised error rolls the WHOLE file back
      with the marker untouched — read the error, fix the cause, run again (the guard admits a retry when nothing
      landed). **Never** prepend the `variorum.allow_11_rerun` override unless the guard itself refuses a genuine
      re-run.
- [ ] If the classifier blocks the POST: prepare the exact command, hand it to her for the `!` road, and read its
      output in-conversation (the 13j precedent).

## 4. VERIFICATION (read-only; all must pass before any install)

- [ ] **The marker:** `select sync_schema_version();` → **8**.
- [ ] **The six columns:** `select column_name, data_type, is_nullable from information_schema.columns where
      table_name = 'key_vault' and column_name in ('master_wrapped_by_apple_held','apple_key_id','key_proof_hash',
      'corpus_previous_key_id','corpus_previous_wrapped_by_master','rotation_started_seq');` → six rows, `text` ×5 +
      `bigint`, all `YES`; `select count(*) from information_schema.columns where table_name = 'key_vault';` → **24**.
- [ ] **Her vault row untouched and pre-postures:** `select revision, corpus_key_id, key_proof_hash,
      corpus_previous_key_id, corpus_previous_wrapped_by_master, rotation_started_seq from key_vault;` → the SAME
      revision and key id as step 2; the four new values NULL (the NULL-hash migration arm is what her first round
      lands).
- [ ] **Every signature:** `select oid::regprocedure from pg_proc where pronamespace = 'public'::regnamespace order
      by 1;` → the six OLD signatures ABSENT; present: `sync_push(jsonb,text,text)`,
      `sync_pull(bigint,text,integer,text,text)`, `sync_horizon(text,text)`, `sync_purge_ledger(bigint,text,text)`,
      `sync_purge_execute(jsonb,text,text)`, `account_data_truncate(text,text)`, `sync_reencrypt(jsonb,text,text)`,
      `key_vault_update(jsonb,integer,text)`, `sync_key_gate(text,text)`, `sync_key_proof_check(text)`,
      `key_vault_require_proof_hash()`; `account_purge()` and `sync_schema_version()` unchanged.
- [ ] **Ownership:** `select proname, pg_get_userbyid(proowner) from pg_proc where pronamespace =
      'public'::regnamespace and proname in ('sync_push','sync_pull','sync_horizon','sync_purge_ledger',
      'sync_purge_execute','account_data_truncate','sync_reencrypt','key_vault_update','sync_key_gate',
      'sync_key_proof_check');` → every one `variorum_definer`; `account_purge` stays `postgres`.
- [ ] **THE GRANT SWEEP:** run `maintenance/14c-post-deploy-grant-sweep.sql` — **every row OK or INFO**; in
      particular: no `UNEXPECTED FUNCTION` (a lingering old overload is a PROOF-FREE door — the tripwire), no
      `UNEXPECTED POLICY` (`key_vault_owner_update` must be GONE), the `vault-fact` rows all OK
      (`privilege:authenticated:UPDATE = false`, `privilege:variorum_definer:UPDATE = true`,
      `trigger:key_vault_require_proof_hash = true`), `key_vault` at 4 policies by NAME.
- [ ] **THE LIVE PATCH PROBE (ledger 41 — the closed write road, proven on the mirror):** with a bare
      authenticated session — a signed-in throwaway probe account (signups are open since 14d; the 14c gate's
      stranger account if it still exists) or her own session's access token — send
      `PATCH https://<project>.supabase.co/rest/v1/key_vault?user_id=eq.<that uid>` with headers `apikey`,
      `Authorization: Bearer <token>`, `Content-Type: application/json`, `Prefer: return=representation` and body
      `{"revision": 99}` → expect **HTTP 403 with SQLSTATE `42501` "permission denied for table key_vault"** — the
      table-level UPDATE is revoked before any row is matched, so the probe account needs NO vault row. A 200
      (with `[]` or a row) is a FAILED closure — stop, do not install, investigate (the sweep's vault-fact rows
      say which grant survived).
- [ ] **The proof-required probe (the old client's fate, made visible):** with the same session, `POST
      …/rest/v1/rpc/sync_horizon` with body `{"active_key_id": "x"}` (no `key_proof`) → PostgREST answers
      **404 / PGRST202 (no function matches)** — the old signature is gone; with body `{"active_key_id": "x",
      "key_proof": null}` → **400 with `VARIORUM_STALE_KEY_FENCE`** (the probe account has no vault row; the fence
      precedes the proof) — for HER uid's session the same call answers `VARIORUM_KEY_PROOF_REQUIRED` once the key
      id matches. Either refusal is the typed marker, never a 500.
- [ ] Record every answer in the batch-2 record (the deploy's own paragraph), with the sweep's row count.

## 5. THE INSTALLS (batch 2's half — the same sitting)

- [ ] The Mac Release refresh behind the A1 rail (the standing `xcodebuild -scheme Variorum -configuration Release
      build` + copy to `/Applications`, at a zero-instance window SHE opens by quitting the app).
- [ ] Her passphrase confirm on the Mac (batch 2's §11 migration — the sync keys move into per-store custody, the
      key file to format 2).
- [ ] The phone build + install (Xcode + her device) and its confirm.

**The migration's prompt (2a's hand-forward):** at the Mac's first ready after the install the §11 migration runs
off-main; a login-keychain prompt MAY appear at the legacy items' DELETE leg (*"Variorum wants to use your
confidential information stored in 'io.lduarte.Variorum.e2ee-keys'…"*) — she answers with the login password and
**Always Allow**; then the one-time *confirm your passphrase* sheet (*Later* is safe at any point; the mark persists
until confirmed). The DEV store's own migration wants the same prompt answered ONCE on a Debug launch (the dev scope's
2026-08-31 login-keychain item vs a rebuilt binary) — any time before or at the sitting; the orchestrator then reads
the `[protection] migration 2a:` lines from `/usr/bin/log show` — the full path: in her zsh `log` is a BUILTIN, and the
migration must log at a PERSISTED level (`.notice`; 2b's item 0) for `log show` to read it afterwards.

**She is SIGNED OUT of the real store at this writing (her word):** at the window, after the install and the migration's
run, she SIGNS IN first — the confirm face's vault verify and the first round both need the session — and then runs
the 13l sanity check with her twelve words (the 1b stale-recovery-wrap defect's definitive check, moved here from
before the sitting because the face reads the vault).

## 6. THE FIRST ROUNDS (the migration arm lands; both devices sync)

- [ ] **Her Mac's first post-install round** presents the proof against her NULL-hash row: the round completes
      (the status row idle, no refusal) and `select key_proof_hash from key_vault;` → **a 64-char lowercase hex**
      value — the migration arm landed, ONCE. A second query after the next round shows the SAME value.
- [ ] **The phone's first round** (the same master, so the same proof) completes against the landed hash.
- [ ] `select corpus_previous_key_id, corpus_previous_wrapped_by_master, rotation_started_seq from key_vault;` → all
      three NULL (no rotation has begun; the triple is nil together).
- [ ] **The FOR UPDATE arm, if her two devices' first rounds ever coincide:** nothing to probe by hand — the gate
      peeks the hash unlocked, takes the row `FOR UPDATE` on a NULL, re-reads and sets only if still NULL; a second
      first-round waits on the lock and then compares against what landed (the same proof passes; a different one
      refuses typed). If the mirror's logs ever show a `40P01` (deadlock) on `key_vault` at this step, that is a
      defect of the deploy, not of the choreography — stop and read `sync_key_gate`'s lock choice.
- [ ] `device_cursor` carries BOTH devices' rows from these rounds (the 13j window's own verification).
- [ ] Run the grant sweep ONCE MORE after the rounds — every row OK/INFO (nothing a round does can change the
      posture; the second run is the record's belt).

## 7. ROLLBACK POSTURE

- **Before commit:** the file is one transaction — any raised error rolls the whole event back, the marker stays 7,
  the old signatures stand; both installed apps keep syncing as before.
- **After commit:** there is no un-deploy — a marker-8 mirror is served only by marker-8 clients. A defect found by
  the live probes is fixed the 13j way: a `maintenance/pre13x-window-<fix>.sql` artifact (drop + recreate +
  re-own + re-grant, one transaction), pinned in `AuthRLSDDLTests`, run in the SAME window before the installs —
  never a relaxation of the posture, never a re-run of 11 (the guard refuses; the override is for a genuinely
  rolled-back run only).
- **The migration arm is one-shot by nature:** if her first round's proof ever landed a WRONG hash (impossible by
  construction — the proof is computed from the master her custody holds — but stated), the road is Replace All
  Keys (batch 3) under the current proof, or delete-and-set-up-again.

## 8. THE RECORD AT CLOSEOUT

- SyncSpec §12's running record gains the marker 7 → 8 entry (the file, the six columns, the closed write road,
  the proof on every mutating RPC and the two read RPCs, the NULL-hash arm's one-time landing on her row, the
  PATCH probe's answer, the sweep's verdict) — the closeout's canon delta (design §17).
- The batch-2 record carries the window's paragraph in the 13j shape (pre-deploy snapshot · deploy · verification ·
  installs · first rounds · the sweep twice).
