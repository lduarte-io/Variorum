-- Variorum sync mirror — the VX-307 KEY-VAULT SHAPE lockstep event
-- (SyncSpec §12; the binding plan is `notes/plans/vx-307-castle-crossings.md`
-- §1 — the vault takes the CastleRules shape the core's `VaultModel` holds:
-- rules 7, 11, 12, 14, 15). Run AFTER 01–16. ONE transaction; the marker
-- update is the last statement inside it (12's discipline, kept).
--
-- THE DEPLOY RUNS ONLY AT THE AUTHOR'S WINDOW — and HER RULING (2026-10-18,
-- verbatim in the plan §1) holds it further: "I think it makes sense to wait
-- to bump the mirror until we're ready to release this so that my client
-- doesn't stop syncing." This artifact runs in the release window that
-- carries VX-329's switch, never before; the moment the marker bumps to 14,
-- every installed marker-13 build VISIBLY refuses to sync (outbox intact,
-- cursor unmoved — the §12 refusal grammar), so the window co-installs her
-- Mac and phone builds. Always behind the A1 rail. The checklist is
-- `notes/plans/vx307-deploy-checklist.md`.
--
-- WHAT THIS EVENT SHIPS:
--   * `key_vault.mode text` — THE MODE FLAG, the account's one posture
--     (rules 10–12): 'standard' | 'castle'. Replaces the Apple-held-wrap
--     encoding (pre-13x: wrap absent ⇒ Castle); the backfill below carries
--     that exact semantic over, so it is today's truth restated, never a
--     guess.
--   * `key_vault.earlier_row_keys jsonb` — EVERY EARLIER SYNC KEY the
--     account has had, `{key_id: base64 wrap}`, each wrapped under the
--     CURRENT master (rule 15: "the account keeps every sync key it has
--     ever had … so a device joining years later reads everything"). NULL
--     reads as empty. The sync key changes ONLY when the account enters
--     Castle — ONE CAS write; no walk, no re-encryption, no crash window.
--   * RETIRED-AS-UNREAD (left in place, nulled once below): the rotation's
--     three columns (`corpus_previous_key_id`,
--     `corpus_previous_wrapped_by_master`, `rotation_started_seq`) — the
--     kept-keys list replaces the rotation whole (CastleRules' considered-
--     and-not-pursued: re-sealing the account is out). LEFT UNREAD, not
--     nulled: `master_wrapped_by_apple_held` + `apple_key_id` (rule 14:
--     the account's keys are wrapped by the passphrase and the words only,
--     never by Apple — the new road never reads them; they stay as the
--     pre-event history of the row).
--   * DROPPED: `sync_reencrypt` — the rotation's walk; nothing calls it on
--     marker 14.
--   * `key_vault_update` REDEFINED (same signature — the one CAS write,
--     the 13y challenge-verified proof byte-unchanged, the
--     hash-and-secret-together rule KEPT): the rotation arms go; `mode`
--     and `earlier_row_keys` land; a pre-VX307 payload (no 'mode' key)
--     refuses loudly — an old client's write can never null the new
--     columns silently (the 13i-e class, answered by refusal since every
--     old client is refused by the marker anyway).
--   * The journal-bridge columns' NOT NULL relaxes (P-VX307-U1-1): the
--     bridge is retired (tag archive/fragments-bridge-2026-09-04); a new
--     account's vault mints no bridge key. Existing rows keep their
--     historical values; the new update body does not touch them.
--   * the marker: 13 → 14. It moves because the RPC's payload contract
--     changes shape (a marker-13 client's `key_vault_update` payload is
--     refused by the new body; its engine refuses the round first).
--
-- CLIENT SIDE: `SyncSchema.lockstepVersion` stays 13 until the VX-329
-- release (her ruling). The new-road client (Debug) reads/writes this shape
-- through the production vault leaf, proven on the fake server until the
-- window.

-- ---------------------------------------------------------------------------
-- 0. The re-run guard (12's shape): refuses when the mirror already speaks
--    marker 14 or carries `mode`, and when 16 has not run. Also refuses
--    MID-ROTATION (fail-loud; the checklist's preflight probe confirms
--    before the window): nulling a standing rotation would strand its
--    re-encryption — complete it on marker 13 first.
-- ---------------------------------------------------------------------------

do $rerun_guard$
declare
  override        text    := nullif(current_setting('variorum.allow_17_rerun', true), '');
  deployed_marker int     := 1;
  mode_here       boolean := exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'key_vault'
      and column_name = 'mode');
begin
  if override = 'yes-rerun-the-vault-shape-event' then
    raise notice 'VARIORUM 17 RE-RUN OVERRIDE ACCEPTED — re-applying the vault-shape lockstep event.';
    return;
  end if;

  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;

  if deployed_marker >= 14 or mode_here then
    raise exception using
      message = 'VARIORUM_17_ALREADY_DEPLOYED: this mirror has already run 17 (lockstep marker '
                || deployed_marker || '; key_vault.mode '
                || case when mode_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_17_rerun = ''yes-rerun-the-vault-shape-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;

  if deployed_marker < 13 then
    raise exception using
      message = 'VARIORUM_17_PREREQUISITE_MISSING: this mirror is at lockstep marker '
                || deployed_marker || ' — run 16 (the private-mark event) first.';
  end if;

  if exists (select 1 from key_vault where rotation_started_seq is not null) then
    raise exception using
      message = 'VARIORUM_17_ROTATION_IN_FLIGHT: a key rotation is still finishing on this mirror — complete it on marker 13 before this event (nulling it here would strand the re-encryption).';
  end if;
end
$rerun_guard$;

begin;

-- ---------------------------------------------------------------------------
-- 1. The two additive columns — nullable, no default. `mode` is enum
--    semantics ('standard' | 'castle'); `earlier_row_keys` is `{key_id:
--    base64 wrap}`, every wrap under the CURRENT master. Both PLAIN under
--    E2EE in the sense the vault always was: wrapped key material and a
--    posture flag — no prose, no content. The disclosure delta: the mirror
--    now shows WHICH posture the account is in and HOW MANY sync keys it
--    has had (≈ its Castle entries), never a key.
-- ---------------------------------------------------------------------------

alter table key_vault add column mode text;
alter table key_vault add column earlier_row_keys jsonb;

-- ---------------------------------------------------------------------------
-- 2. The journal-bridge columns' NOT NULL relaxes (P-VX307-U1-1): the
--    bridge is retired; a vault created on marker 14 carries no bridge
--    key. Existing rows keep their values, unread.
-- ---------------------------------------------------------------------------

alter table key_vault alter column journal_bridge_key_id drop not null;
alter table key_vault alter column journal_bridge_key_wrapped_by_master drop not null;

-- ---------------------------------------------------------------------------
-- 3. The backfill (P-VX307-U1-2) — TODAY'S OWN SEMANTIC restated, never a
--    guess: on the pre-13x road the vault's posture IS the Apple-held
--    wrap's presence (`PostureSwitch`: `masterWrappedByAppleHeld == nil` ⇒
--    Castle — the deployed client's own reading). The rotation's three
--    columns are nulled once (the guard above proved none is in flight);
--    `earlier_row_keys` stays NULL (= empty: the rotation era re-encrypted
--    rows instead of keeping keys, so no pre-event account has earlier
--    keys).
-- ---------------------------------------------------------------------------

update key_vault
   set mode = case when master_wrapped_by_apple_held is not null then 'standard' else 'castle' end,
       corpus_previous_key_id = null,
       corpus_previous_wrapped_by_master = null,
       rotation_started_seq = null
 where mode is null;

-- ---------------------------------------------------------------------------
-- 4. The rotation's walk goes: nothing calls `sync_reencrypt` on marker 14
--    (rule 15's kept list reads every row under the key its own label
--    names; no bulk re-encryption exists).
-- ---------------------------------------------------------------------------

drop function if exists sync_reencrypt(jsonb, text, text, text);

-- ---------------------------------------------------------------------------
-- 5. `key_vault_update` REDEFINED — the one CAS write (the table-level
--    UPDATE road stays closed since 11). KEPT byte-faithful from 12's
--    canonical body: the FOR UPDATE lock, the challenge-verified proof
--    (`sync_key_proof_check`), the revision CAS pre-check + the UPDATE's
--    own filter as the belt, the hash-and-secret-together rule (a payload
--    installing a NEW `key_proof_hash` carries `key_proof_mac` = kp2′,
--    landed in Supabase Vault in the same transaction). GONE: every
--    rotation arm (the completion guard, `next_tenant_seq`, the previous-
--    key columns, `VARIORUM_ROTATION_*`). NEW: `mode` and
--    `earlier_row_keys` land from the payload; a payload with no 'mode'
--    key is a pre-VX307 client's and refuses loudly. The journal-bridge,
--    Apple-held and rotation columns are NOT touched by the new body.
-- ---------------------------------------------------------------------------

create or replace function key_vault_update(payload jsonb, expected_revision int, key_proof text, challenge text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  caller uuid;
  vault_revision int;
  updated_rows int;
  incoming_hash text;
  incoming_mac text;
  incoming_mac_hash text;
  vault_current_hash text;
  mac_secret_id uuid;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  select revision into vault_revision
    from key_vault where user_id = caller for update;
  if vault_revision is null then
    raise exception 'VARIORUM_VAULT_ABSENT: no vault exists for this account — set up sync first';
  end if;

  perform sync_key_proof_check(key_proof, challenge, 'key_vault_update');

  -- The R1-2 revision CAS, PRE-CHECKED under the held lock (13y UNIT B);
  -- the UPDATE's own filter stays below as the belt, byte-unchanged.
  if vault_revision is distinct from expected_revision then
    raise exception 'VARIORUM_VAULT_REVISION_CONFLICT: the vault changed since it was fetched — fetch it again and re-derive';
  end if;

  -- VX-307: the payload must speak this event's shape — a pre-VX307
  -- client's payload (no mode) can never silently null the new columns.
  if payload->>'mode' is null then
    raise exception 'VARIORUM_PRE_VX307_PAYLOAD: this mirror speaks the marker-14 vault shape — the payload carries no mode; update the client';
  end if;
  if payload->>'mode' not in ('standard', 'castle') then
    raise exception 'VARIORUM_PRE_VX307_PAYLOAD: mode must be standard or castle';
  end if;

  -- THE MASTER'S SUCCESSOR (13y UNIT B, memo §3 — kept whole): hash and
  -- secret land TOGETHER or not at all. The row is locked FOR UPDATE, so
  -- this read-then-write is serialized per account.
  incoming_hash := payload->>'key_proof_hash';
  incoming_mac := payload->>'key_proof_mac';
  select key_proof_hash into vault_current_hash from key_vault where user_id = caller;
  if incoming_mac is not null then
    begin
      incoming_mac_hash := encode(sha256(decode(incoming_mac, 'base64')), 'hex');
    exception when others then
      incoming_mac_hash := null;
    end;
    if incoming_mac_hash is null or incoming_hash is null
       or incoming_mac_hash <> incoming_hash then
      raise exception 'VARIORUM_KEY_PROOF_REQUIRED: the successor proof secret must hash to the payload''s key_proof_hash — they land together or not at all';
    end if;
  elsif incoming_hash is not null and incoming_hash is distinct from vault_current_hash then
    raise exception 'VARIORUM_KEY_PROOF_REQUIRED: a new key_proof_hash lands only beside its key_proof_mac — a hash that moved without its secret would refuse every follower';
  end if;
  if incoming_mac is not null then
    select s.id into mac_secret_id
      from vault.secrets s where s.name = 'kp:' || caller::text;
    if mac_secret_id is null then
      perform vault.create_secret(incoming_mac, 'kp:' || caller::text);
    else
      perform vault.update_secret(mac_secret_id, incoming_mac);
    end if;
  end if;

  update key_vault set
    format_version                       = (payload->>'format_version')::int,
    kdf_algorithm                        = payload->>'kdf_algorithm',
    kdf_argon2_version                   = (payload->>'kdf_argon2_version')::int,
    kdf_memory_kib                       = (payload->>'kdf_memory_kib')::int,
    kdf_iterations                       = (payload->>'kdf_iterations')::int,
    kdf_parallelism                      = (payload->>'kdf_parallelism')::int,
    kdf_salt                             = payload->>'kdf_salt',
    kdf_output_bytes                     = (payload->>'kdf_output_bytes')::int,
    master_wrapped_by_passphrase         = payload->>'master_wrapped_by_passphrase',
    master_wrapped_by_recovery           = payload->>'master_wrapped_by_recovery',
    corpus_key_id                        = payload->>'corpus_key_id',
    corpus_key_wrapped_by_master         = payload->>'corpus_key_wrapped_by_master',
    mode                                 = payload->>'mode',
    earlier_row_keys                     = payload->'earlier_row_keys',
    key_proof_hash                       = coalesce(payload->>'key_proof_hash', key_proof_hash),
    updated_by_device                    = payload->>'updated_by_device',
    revision                             = expected_revision + 1,
    updated_at                           = now()
  where user_id = caller and revision = expected_revision;
  get diagnostics updated_rows = row_count;
  if updated_rows = 0 then
    raise exception 'VARIORUM_VAULT_REVISION_CONFLICT: the vault changed since it was fetched — fetch it again and re-derive';
  end if;

  return jsonb_build_object('revision', expected_revision + 1);
end;
$$;

-- `create or replace` on an existing signature keeps the owner and grants,
-- but the posture is re-asserted so a from-scratch mirror lands it too
-- (12's tail, verbatim for this function).
alter function key_vault_update(jsonb, int, text, text) owner to variorum_definer;
revoke execute on function key_vault_update(jsonb, int, text, text) from public, anon, service_role;
grant execute on function key_vault_update(jsonb, int, text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
--    TRANSACTION. The mirror now speaks lockstep version 14. The CLIENT
--    bump rides the VX-329 release (her ruling) — this artifact never runs
--    before that window.
-- ---------------------------------------------------------------------------

insert into sync_meta (key, value) values ('lockstep_version', '14')
  on conflict (key) do update set value = excluded.value;

commit;

-- Verification (read-only; the window runs these — the vx307 deploy
-- checklist):
--   select sync_schema_version();                                        -- 14
--   select column_name, data_type, is_nullable from information_schema.columns
--     where table_name = 'key_vault'
--       and column_name in ('mode', 'earlier_row_keys',
--                           'journal_bridge_key_id');                    -- mode text YES ·
--                                                                        -- earlier_row_keys jsonb YES ·
--                                                                        -- journal_bridge_key_id YES
--   select user_id, mode, earlier_row_keys,
--          corpus_previous_key_id is null as rot_id_clear,
--          rotation_started_seq is null as rot_seq_clear
--     from key_vault;                                                    -- her row: mode matches her
--                                                                        -- posture probe; rot_* true
--   select proname from pg_proc where proname = 'sync_reencrypt';        -- zero rows
