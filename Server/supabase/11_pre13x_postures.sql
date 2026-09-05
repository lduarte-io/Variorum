-- Variorum sync mirror — the pre-13x POSTURES lockstep event (batch 1b;
-- SyncSpec §12; the design `notes/plans/pre-13x-postures-design.md` §3.10,
-- decisions 12 / 31 / 32, ledger rows 16 / 25 / 29 / 34 / 35 / 38 / 41).
-- Run AFTER 01–10 (+ the 14c maintenance artifacts — `variorum_definer`
-- exists; + the 13j window rename), via the author's PAT arrangement.
--
-- THE DEPLOY IS PRE-AUTHORIZED (design §16: her PAT is stored — the 9c
-- arrangement — so the ORCHESTRATOR runs the mirror deploy at the window
-- without waiting for her at the keyboard; the `!` road if the permission
-- classifier blocks the mutating call — the 13j precedent) and EXECUTES
-- ONLY at the ARCHITECT's window — never a batch implementer. The window
-- is scheduled immediately BEFORE batch 2's migration + the Mac Release
-- refresh + the PHONE install (the 13j one-window sequencing): the moment
-- the marker bumps to 8, every installed marker-7 build VISIBLY refuses
-- to sync (outbox intact, cursor unmoved — the §12 refusal grammar;
-- offline is free while it waits). Always behind the A1 rail. The
-- checklist is `notes/plans/pre-13x-deploy-checklist.md`.
--
-- WHAT THIS EVENT SHIPS (the design's §3.10, verbatim in mechanism):
--   * THE KEY PROOF (decision 12): `kp = HMAC-SHA256(M, "variorum.key-proof.v1")`,
--     computed by every device that holds the master key M, presented as a
--     base64 body parameter `key_proof` on every mutating RPC — and on the
--     two READ RPCs (sync_horizon / sync_purge_ledger) — stored server-side
--     ONLY as `sha256(kp)` hex in `key_vault.key_proof_hash`, compared in
--     constant time. A bare session can fetch the vault's wrapped copies,
--     delete the whole account (`account_purge`, untouched), and NOTHING
--     ELSE: it cannot push, pull, purge, truncate, read the horizon or the
--     ledger, or write the vault. The `active_key_id` fence STAYS as the
--     stale-device honesty check; THE PROOF IS THE AUTHORIZATION (the key
--     id is readable from the vault by any session).
--   * THE MIGRATION ARM: a vault whose `key_proof_hash` is NULL accepts its
--     FIRST proof from any session and stores its hash — the author's
--     existing vault only, closed the moment the hash lands (her Mac's
--     first post-install round). A `BEFORE INSERT` trigger refuses a NULL
--     hash at vault CREATION — a trigger, never a CHECK, precisely so her
--     existing row may stay NULL until that round.
--   * THE VAULT'S FIVE ADDITIVE COLUMNS (all nullable):
--     `master_wrapped_by_apple_held` + `apple_key_id` (Standard's one
--     Apple-held copy, decision 3); `key_proof_hash`;
--     `corpus_previous_wrapped_by_master` (the PREVIOUS corpus key wrapped
--     under the NEW master for a rotation's duration, decision 6 — the
--     value carries the previous key's ID before a `:` so a follower can
--     bind the AAD of pre-rotation rows; batch 1b's recorded reading);
--     `rotation_started_seq` (decision 31 — which key a row is under is
--     told by its `server_seq`).
--   * `key_vault_update(payload, expected_revision, key_proof)` — the ONLY
--     write road into the vault after creation: SECURITY DEFINER,
--     `variorum_definer`-owned, the row locked FOR UPDATE (decision 31's
--     serialization point), the R1-2 revision CAS INSIDE it, the format
--     columns replaced WHOLE from the payload, the proof hash REPLACEABLE
--     when the call carries the CURRENT proof (the rotation road), and
--     `nextval('sync_server_seq')` taken into `rotation_started_seq` in the
--     same transaction when the payload sets a previous corpus key —
--     REFUSED with VARIORUM_ROTATION_IN_PROGRESS when a DIFFERENT previous
--     key is already present (decision 32: one rotation at a time); a
--     payload that clears the previous key clears the seq with it.
--   * THE VAULT'S TABLE-LEVEL WRITE ROAD CLOSES (ledger 41 — found by the
--     orchestrator reading 08:113-118): `key_vault_owner_update` DROPPED,
--     UPDATE REVOKED from `authenticated` (SELECT + INSERT stay: the
--     session-only read of the wrapped copies, and creation);
--     `variorum_definer` gains SELECT + UPDATE and its own update policy in
--     `device_cursor_owner_all`'s shape. A bare session's PostgREST PATCH
--     is now `permission denied` — otherwise the proof would protect
--     nothing (a proof-free write to every vault column, the hash
--     included). The deploy's LIVE PATCH PROBE proves it on the mirror.
--   * `sync_reencrypt(rows, active_key_id, key_proof)` — the rotation's
--     write (decision 6, version-neutral re-encryption): per `(table,
--     row_id, expected_version, columns)` it REPLACES the payload where
--     `sync_version = expected_version`, stamps a fresh `server_seq`
--     through the existing trigger, and does NOT bump the version — so no
--     other device's offline edit is ever rejected by a rotation and
--     followers apply nothing; a mismatch is `skipped` (with the current
--     version) for the caller to pull and retry. The server stays DUMB:
--     bytes it is handed, own partition, CAS on version.
--   * THE SIX DATA RPCs REWRITTEN with `key_proof` beside `active_key_id`:
--     sync_push · sync_pull · sync_horizon · sync_purge_ledger ·
--     sync_purge_execute · account_data_truncate — bodies VERBATIM from 10
--     except the fence being replaced by the ONE gate helper call. The OLD
--     signatures are DROPPED FIRST (the 09/10 discipline: an overload left
--     standing would be a proof-free door beside the new one).
--   * ONE gate, two helpers: `sync_key_gate(active_key_id, key_proof)`
--     reads the vault row FOR SHARE (decision 31 — a push that passed the
--     old check commits, and takes its seqs, BEFORE any rotation's vault
--     write, never after it), applies the fence, then
--     `sync_key_proof_check(key_proof)` — the constant-time compare and the
--     NULL-hash arm. Both are `variorum_definer`-owned and revoked from
--     every API role (the `sync_table_pk` posture): the definer bodies are
--     their only callers.
--
-- WHAT DOES NOT CHANGE: the 19 data tables and their policies; `account_purge`
-- (session-only — deletion is mandated and loud); vault SELECT and INSERT
-- (session-only — a new device must fetch the wrapped copies to obtain M;
-- creation sets the hash); `sync_schema_version()`; the A5 horizon; the
-- entitlement gate; the purged-ids ledger; the device cursor.
--
-- THE CHOREOGRAPHY (SyncSpec §12): this file runs on the mirror FIRST, at
-- the architect's window under her standing PRE-AUTHORIZED go — never a
-- batch implementer; then every client updates (the Mac Release + the
-- phone build, bundled into the same window with batch 2's migration —
-- her one-time passphrase confirm on each device needs her present); only
-- then may any client write what the new schema shapes. A marker-7 client
-- refuses the marker-8 mirror and vice versa — stalling is safe by design.
--
-- THIS FILE EXECUTES AS ONE TRANSACTION (the 09/I-3 discipline): begin →
-- re-run guard → the drops → the columns → the closure → the trigger →
-- the helpers → the functions → ownership + grants → the marker LAST →
-- commit. A failed run rolls back whole, marker untouched; an honest retry
-- needs no override.
--
-- THE NAMING RULE (13j, the author's ruling): no RPC parameter may shadow
-- a column it writes. `payload` / `expected_revision` / `key_proof` /
-- `active_key_id` / `rows` / `batch` / `since_seq` / `max_rows` /
-- `for_device` are none of `key_vault`'s or the data tables' columns; every
-- local that reads a vault column carries a `vault_` / `stored_` /
-- `presented_` prefix.

begin;

-- ---------------------------------------------------------------------------
-- 0a. THE RE-RUN GUARD — first statement inside the transaction, before the
--     destructive drops below. Keyed on evidence only a deployed 11 leaves:
--     the marker at 8+, or the `key_proof_hash` column no other artifact
--     adds.
-- ---------------------------------------------------------------------------

do $rerun_guard$
declare
  override           text    := nullif(current_setting('variorum.allow_11_rerun', true), '');
  deployed_marker    int     := 1;
  proof_column_here  boolean := exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'key_vault'
      and column_name = 'key_proof_hash');
begin
  if override = 'yes-rerun-the-postures-event' then
    raise notice 'VARIORUM 11 RE-RUN OVERRIDE ACCEPTED — re-applying the postures lockstep event.';
    return;
  end if;

  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;

  if deployed_marker >= 8 or proof_column_here then
    raise exception using
      message = 'VARIORUM_11_ALREADY_DEPLOYED: this mirror has already run 11 (lockstep marker '
                || deployed_marker || '; key_vault.key_proof_hash '
                || case when proof_column_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_11_rerun = ''yes-rerun-the-postures-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;
end
$rerun_guard$;

-- ---------------------------------------------------------------------------
-- 0. Drop the OLD RPC signatures before creating the new ones (Postgres
--    overloads by signature — the 09/10 discipline): a lingering
--    sync_push(jsonb, text) or sync_pull(bigint, text, int, text) would keep
--    serving the mirror to ANY session with no proof — the proof-free door
--    this whole event exists to close.
-- ---------------------------------------------------------------------------

drop function if exists sync_push(jsonb, text);
drop function if exists sync_pull(bigint, text, int, text);
drop function if exists sync_horizon(text);
drop function if exists sync_purge_ledger(bigint, text);
drop function if exists sync_purge_execute(jsonb, text);
drop function if exists account_data_truncate(text);

-- ---------------------------------------------------------------------------
-- 1. The vault's five additive columns — all nullable (the format version
--    STAYS 1: a row without them decodes as a pre-postures vault; the
--    author's row is exactly that until her first round lands the hash).
--    Key material is base64 TEXT as everywhere in this table;
--    `corpus_previous_wrapped_by_master` carries `<previous corpus key id>:`
--    before the base64 wrap.
-- ---------------------------------------------------------------------------

alter table key_vault add column master_wrapped_by_apple_held text;
alter table key_vault add column apple_key_id text;
alter table key_vault add column key_proof_hash text;
alter table key_vault add column corpus_previous_wrapped_by_master text;
alter table key_vault add column rotation_started_seq bigint;

-- ---------------------------------------------------------------------------
-- 2. THE WRITE ROAD CLOSES (ledger 41): after creation the ONLY write into
--    the vault is `key_vault_update` under the proof. SELECT + INSERT stay
--    session-only (08's owner policies); UPDATE moves to the definer role
--    with a policy of its own — `device_cursor_owner_all`'s shape.
-- ---------------------------------------------------------------------------

drop policy if exists key_vault_owner_update on key_vault;
revoke update on key_vault from authenticated;
grant select, update on key_vault to variorum_definer;
create policy key_vault_definer_update on key_vault
  for update to variorum_definer
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 3. THE INSERT ARM: a vault is CREATED with its key-proof hash, never
--    without — a trigger, not a CHECK, so the author's existing NULL-hash
--    row stands until her first round lands the hash (the migration arm).
-- ---------------------------------------------------------------------------

create or replace function key_vault_require_proof_hash() returns trigger
language plpgsql as $$
begin
  if new.key_proof_hash is null then
    raise exception 'VARIORUM_KEY_PROOF_REQUIRED: a vault is created with its key-proof hash — never without';
  end if;
  return new;
end;
$$;

create trigger key_vault_require_proof_hash before insert on key_vault
  for each row execute function key_vault_require_proof_hash();

-- ---------------------------------------------------------------------------
-- 4. THE PROOF CHECK — the one place the token is compared. Reads the
--    caller's vault row FOR SHARE (the caller may already hold FOR UPDATE —
--    `key_vault_update` — which is the same transaction's stronger lock),
--    hashes the presented token, and compares in CONSTANT TIME: a fixed
--    64-step loop over the hex digits accumulating XOR into an OR, never
--    short-circuiting (`ascii('')` is 0 past either string's end; the
--    lengths join the accumulator last). A malformed token (not base64)
--    refuses the same way — never a raw decode error. The NULL-hash arm:
--    the FIRST proof presented to a hash-less vault is stored and accepted
--    — the author's existing vault, once.
-- ---------------------------------------------------------------------------

create or replace function sync_key_proof_check(key_proof text) returns void
language plpgsql
set search_path = public
as $$
declare
  caller uuid;
  stored_hash text;
  presented_hash text;
  vault_found boolean := false;
  hash_diff int := 0;
  i int;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  select true, key_proof_hash into vault_found, stored_hash
    from key_vault where user_id = caller for share;
  if not coalesce(vault_found, false) then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

  begin
    presented_hash := encode(sha256(decode(key_proof, 'base64')), 'hex');
  exception when others then
    presented_hash := null;
  end;
  if presented_hash is null then
    raise exception 'VARIORUM_KEY_PROOF_REQUIRED: this session holds no proof of the account''s master key — pick up your keys before syncing';
  end if;

  if stored_hash is null then
    -- THE MIGRATION ARM (hers only): the first proof lands its hash. The
    -- share lock upgrades to the row's exclusive lock inside this same
    -- transaction; two first-rounds racing this arm resolve by the
    -- deadlock detector aborting one — its next round simply presents the
    -- proof against the landed hash.
    update key_vault set key_proof_hash = presented_hash where user_id = caller;
    return;
  end if;

  for i in 1..64 loop
    hash_diff := hash_diff
      | (ascii(substr(stored_hash, i, 1)) # ascii(substr(presented_hash, i, 1)));
  end loop;
  hash_diff := hash_diff | (length(stored_hash) # length(presented_hash));
  if hash_diff <> 0 then
    raise exception 'VARIORUM_KEY_PROOF_REQUIRED: this session holds no proof of the account''s master key — pick up your keys before syncing';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. THE GATE — what every data RPC calls first: the vault row read FOR
--    SHARE (decision 31: a data round holds the share lock for its whole
--    transaction, so a rotation's FOR UPDATE write waits for every in-flight
--    round that passed the OLD check — those rows commit, and take their
--    seqs, BELOW the rotation seq, never above it), the 14c fence
--    (unchanged: mismatch OR a missing vault row refuses with the CF-16
--    marker), then the proof.
-- ---------------------------------------------------------------------------

create or replace function sync_key_gate(active_key_id text, key_proof text) returns void
language plpgsql
set search_path = public
as $$
declare
  caller uuid;
  fence_key text;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE VAULT-KEY-ID FENCE (THE DESIGN item 2, 14c): the caller's presented
  -- corpus key id must match the account's current key_vault row. A
  -- mismatch — or a missing vault row — refuses the WHOLE round before
  -- any row is touched (the CF-16 replaced state, client-classified).
  select corpus_key_id into fence_key from key_vault where user_id = caller for share;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

  -- THE KEY PROOF (pre-13x decision 12): the authorization.
  perform sync_key_proof_check(key_proof);
end;
$$;

-- ---------------------------------------------------------------------------
-- 6. sync_push — the 10 body VERBATIM, the fence replaced by the gate.
-- ---------------------------------------------------------------------------

create or replace function sync_push(batch jsonb, active_key_id text, key_proof text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  -- The tables whose CLIENT schema carries owner_id (AppSpec §6 top-level
  -- entities + their later siblings): payloads carry owner and must
  -- carry the caller's. Everything else is mirror-only-owner: the
  -- server stamps on insert and subtracts on serve.
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment', 'purge_intent'];
  caller uuid;
  item jsonb;
  tbl text;
  pk text;
  row_id text;
  base_version bigint;
  current_version bigint;
  current_jsonb jsonb;
  full_row jsonb;
  granted_seq bigint;
  results jsonb := '[]'::jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE GATE (pre-13x): the vault row FOR SHARE, the fence, the proof.
  perform sync_key_gate(active_key_id, key_proof);

  -- THE ENTITLEMENT GATE (THE DESIGN item 5): hosted sync is the tier.
  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  for item in select * from jsonb_array_elements(batch) loop
    tbl := item->>'table';
    if not (tbl = any (allowed)) then
      raise exception 'unknown sync table %', tbl;
    end if;
    pk := sync_table_pk(tbl);
    row_id := item->>'row_id';
    base_version := (item->>'base_version')::bigint;
    current_version := null;
    current_jsonb := null;

    -- Client-carried owner guard (the NINE, since purge_intent): a pushed
    -- row must carry the caller's own owner_id (NULL refused too — `is
    -- distinct from`).
    if tbl = any (owner_tables)
       and (item->'columns'->>'owner_id') is distinct from caller::text then
      raise exception 'owner_id mismatch on % row % — pushes must carry owner_id = auth.uid()',
        tbl, row_id;
    end if;

    -- THE PURGED-IDS LEDGER (Phase 13j — the memo's §2): a push naming a
    -- purged id is REFUSED with the typed 'purged' status. This is what
    -- makes physical removal safe under S2's bend: a stale peer's
    -- re-push can never resurrect a purged row — the client drops the
    -- outbox entry and its local copy instead of retrying. Checked
    -- BEFORE the CAS: a purged row has no CAS state to compare.
    if exists (
      select 1 from purged_row p
      where p.owner_id = caller and p.table_name = tbl and p.row_id = item->>'row_id'
    ) then
      results := results || jsonb_build_array(jsonb_build_object('status', 'purged'));
      continue;
    end if;

    -- TENANT-SCOPED CAS lock + read: identity is (owner_id, id) — the
    -- composite PK — so another account's same-id row is structurally
    -- unaddressable, and this seek is exact.
    execute format(
      'select sync_version, to_jsonb(t) from %I t where t.owner_id = $2 and t.%I = $1 for update',
      tbl, pk)
      into current_version, current_jsonb
      using row_id, caller;

    if current_version is null then
      -- Absent row (in THIS tenant's partition): only base 0 inserts.
      if base_version = 0 then
        full_row := (item->'columns')
          || jsonb_build_object('sync_version', 1, 'owner_id', caller);
        execute format(
          'insert into %I select * from jsonb_populate_record(null::%I, $1) returning server_seq',
          tbl, tbl)
          into granted_seq using full_row;
        results := results || jsonb_build_array(jsonb_build_object(
          'status', 'accepted', 'new_version', 1, 'server_seq', granted_seq));
      else
        results := results || jsonb_build_array(jsonb_build_object(
          'status', 'rejected', 'current', null));
      end if;
    elsif base_version = current_version then
      -- Matching base: replace the row wholesale (delete+insert is safe —
      -- nothing references a mirror row) and bump.
      full_row := (item->'columns')
        || jsonb_build_object('sync_version', current_version + 1, 'owner_id', caller);
      execute format('delete from %I where owner_id = $2 and %I = $1', tbl, pk)
        using row_id, caller;
      execute format(
        'insert into %I select * from jsonb_populate_record(null::%I, $1) returning server_seq',
        tbl, tbl)
        into granted_seq using full_row;
      results := results || jsonb_build_array(jsonb_build_object(
        'status', 'accepted', 'new_version', current_version + 1, 'server_seq', granted_seq));
    else
      -- Stale base: reject WITH the current row so the client can merge
      -- deterministically and push again (SyncSpec §4). No server
      -- merging. The served payload subtracts the server-only columns —
      -- and, for the mirror-only-owner tables, the stamped owner_id.
      results := results || jsonb_build_array(jsonb_build_object(
        'status', 'rejected',
        'current', jsonb_build_object(
          'table', tbl,
          'row_id', row_id,
          'sync_version', current_version,
          'server_seq', current_jsonb->'server_seq',
          'columns', case when tbl = any (owner_tables)
            then current_jsonb - 'sync_version' - 'server_seq' - 'server_written_at'
            else current_jsonb - 'sync_version' - 'server_seq' - 'server_written_at' - 'owner_id'
          end)));
    end if;
  end loop;
  return results;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. sync_pull — the 10 body VERBATIM, the fence replaced by the gate.
--    `key_proof text default null` — Postgres refuses a defaultless
--    parameter after the defaulted `max_rows` / `for_device` (the brief's
--    parameter ORDER is kept); the gate refuses a NULL proof with the typed
--    marker, so the default buys nothing but the compile.
-- ---------------------------------------------------------------------------

create or replace function sync_pull(since_seq bigint, active_key_id text, max_rows int default 500, for_device text default null, key_proof text default null)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment', 'purge_intent'];
  caller uuid;
  -- `for_device`, NOT `device_id` (2026-08-19, the window's first live
  -- round): the parameter's original name shadowed the device_cursor
  -- COLUMN inside the upsert's ON CONFLICT list — PL/pgSQL 42702, caught
  -- by the strict variable_conflict default doing exactly its job. The
  -- author's ruling: fix the NAME, never relax the policy — no RPC
  -- parameter may shadow a column it writes (the standing naming rule).
  dev text := for_device;
  tbl text;
  union_sql text := '';
  result jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE GATE (pre-13x): the vault row FOR SHARE, the fence, the proof.
  perform sync_key_gate(active_key_id, key_proof);

  -- THE ENTITLEMENT GATE (same as push).
  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  -- THE DEVICE CURSOR (Phase 13j — what makes a horizon computable):
  -- `since_seq` on a round's FIRST window is the caller's committed
  -- cursor — everything at or below it has been integrated and
  -- committed. Recorded monotonically (greatest), stamped seen_at now.
  if dev is not null then
    insert into device_cursor (owner_id, device_id, last_seq, seen_at)
    values (caller, dev, since_seq, now())
    on conflict (owner_id, device_id) do update
      set last_seq = greatest(device_cursor.last_seq, excluded.last_seq),
          seen_at  = now();
  end if;

  -- State-based changefeed: each row appears once, in its current state,
  -- at its latest seq (SyncSpec §2) — strictly within the caller's
  -- partition. The visibility horizon (A5) is the `interval '2 seconds'`
  -- filter: rows written within that window are never served.
  foreach tbl in array allowed loop
    if union_sql <> '' then
      union_sql := union_sql || ' union all ';
    end if;
    if tbl = any (owner_tables) then
      -- Client-carried owner: the payload keeps owner_id.
      union_sql := union_sql || format(
        $q$select %L::text as tbl, t.server_seq, t.sync_version,
             to_jsonb(t) - 'sync_version' - 'server_seq' - 'server_written_at' as cols,
             (to_jsonb(t))->>%L as row_id
           from %I t
           where t.owner_id = %L
             and t.server_seq > %s
             and t.server_written_at <= clock_timestamp() - interval '2 seconds'$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq);
    else
      -- Mirror-only owner: subtract the stamped owner_id — the client
      -- has no home for it (the unknown-column refusal would fire).
      union_sql := union_sql || format(
        $q$select %L::text as tbl, t.server_seq, t.sync_version,
             to_jsonb(t) - 'sync_version' - 'server_seq' - 'server_written_at' - 'owner_id' as cols,
             (to_jsonb(t))->>%L as row_id
           from %I t
           where t.owner_id = %L
             and t.server_seq > %s
             and t.server_written_at <= clock_timestamp() - interval '2 seconds'$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq);
    end if;
  end loop;

  execute format(
    $q$select coalesce(jsonb_agg(jsonb_build_object(
         'table', u.tbl, 'row_id', u.row_id,
         'sync_version', u.sync_version, 'server_seq', u.server_seq,
         'columns', u.cols) order by u.server_seq), '[]'::jsonb)
       from (select * from (%s) raw order by raw.server_seq limit %s) u$q$,
    union_sql, max_rows)
    into result;
  return result;
end;
$$;

-- ---------------------------------------------------------------------------
-- 8. sync_horizon — the 10 body, the fence replaced by the gate. A READ
--    RPC, and the proof gates it too (decision 12's letter, the
--    orchestrator's note): a session without the keys gets nothing from
--    the mirror, a seq included.
-- ---------------------------------------------------------------------------

create or replace function sync_horizon(active_key_id text, key_proof text) returns bigint
language plpgsql security definer
set search_path = public
as $$
declare
  caller uuid;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;
  perform sync_key_gate(active_key_id, key_proof);
  return coalesce(
    (select min(last_seq) from device_cursor
      where owner_id = caller and seen_at > now() - interval '60 days'),
    0);
end;
$$;

-- ---------------------------------------------------------------------------
-- 9. sync_purge_ledger — the 10 body, the fence replaced by the gate (a
--    READ RPC, proof-gated for the same reason).
-- ---------------------------------------------------------------------------

create or replace function sync_purge_ledger(since_seq bigint, active_key_id text, key_proof text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  caller uuid;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;
  perform sync_key_gate(active_key_id, key_proof);
  return jsonb_build_object(
    'floor', 0,
    'entries', coalesce(
      (select jsonb_agg(jsonb_build_object(
         'table', p.table_name, 'row_id', p.row_id, 'purged_seq', p.purged_seq)
         order by p.purged_seq)
        from purged_row p
        where p.owner_id = caller and p.purged_seq > since_seq),
      '[]'::jsonb));
end;
$$;

-- ---------------------------------------------------------------------------
-- 10. sync_purge_execute — the 10 body, the fence replaced by the gate.
-- ---------------------------------------------------------------------------

create or replace function sync_purge_execute(rows jsonb, active_key_id text, key_proof text) returns bigint
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  caller uuid;
  item jsonb;
  tbl text;
  pk text;
  granted_seq bigint;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;
  perform sync_key_gate(active_key_id, key_proof);

  granted_seq := nextval('sync_server_seq');
  for item in select * from jsonb_array_elements(rows) loop
    tbl := item->>'table';
    if not (tbl = any (allowed)) then
      raise exception 'unknown sync table %', tbl;
    end if;
    pk := sync_table_pk(tbl);
    execute format('delete from %I where owner_id = $2 and %I = $1', tbl, pk)
      using item->>'row_id', caller;
    insert into purged_row (owner_id, table_name, row_id, purged_seq)
    values (caller, tbl, item->>'row_id', granted_seq)
    on conflict (owner_id, table_name, row_id) do nothing;
  end loop;
  return granted_seq;
end;
$$;

-- ---------------------------------------------------------------------------
-- 11. account_data_truncate — the 10 body, the fence replaced by the gate:
--     the right `active_key_id` WITHOUT the proof deletes nothing.
-- ---------------------------------------------------------------------------

create or replace function account_data_truncate(active_key_id text, key_proof text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  data_tables constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  caller uuid;
  tbl text;
  removed bigint;
  counts jsonb := '{}'::jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  -- THE GATE (the sync RPCs' exact arm: the fence, then the proof).
  perform sync_key_gate(active_key_id, key_proof);

  foreach tbl in array data_tables loop
    execute format('delete from %I where owner_id = $1', tbl) using caller;
    get diagnostics removed = row_count;
    counts := counts || jsonb_build_object(tbl, removed);
  end loop;
  return counts;
end;
$$;

-- ---------------------------------------------------------------------------
-- 12. sync_reencrypt — THE ROTATION'S WRITE (decision 6, version-neutral):
--     per item `{table, row_id, expected_version, columns}` the payload is
--     replaced where `sync_version = expected_version` — delete + insert
--     through the seq trigger, so the row takes a FRESH `server_seq` (above
--     the rotation seq: the seq rule then reads it under the CURRENT key)
--     while its `sync_version` is NOT bumped, so no other device's offline
--     edit is ever CAS-rejected by a rotation and followers apply nothing.
--     A mismatch (or an absent row) answers `skipped` with the current
--     version for the caller to pull and retry. Own partition only; the
--     push posture (auth · the gate · the entitlement gate · the
--     client-carried owner guard); the server stays dumb.
-- ---------------------------------------------------------------------------

create or replace function sync_reencrypt(rows jsonb, active_key_id text, key_proof text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment', 'purge_intent'];
  caller uuid;
  item jsonb;
  tbl text;
  pk text;
  row_id text;
  expected_version bigint;
  current_version bigint;
  full_row jsonb;
  granted_seq bigint;
  results jsonb := '[]'::jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  perform sync_key_gate(active_key_id, key_proof);

  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  for item in select * from jsonb_array_elements(rows) loop
    tbl := item->>'table';
    if not (tbl = any (allowed)) then
      raise exception 'unknown sync table %', tbl;
    end if;
    pk := sync_table_pk(tbl);
    row_id := item->>'row_id';
    expected_version := (item->>'expected_version')::bigint;
    current_version := null;

    if tbl = any (owner_tables)
       and (item->'columns'->>'owner_id') is distinct from caller::text then
      raise exception 'owner_id mismatch on % row % — re-encryptions must carry owner_id = auth.uid()',
        tbl, row_id;
    end if;

    execute format(
      'select sync_version from %I t where t.owner_id = $2 and t.%I = $1 for update',
      tbl, pk)
      into current_version
      using row_id, caller;

    if current_version is null or current_version is distinct from expected_version then
      -- The version moved (an edit landed since the caller pulled this
      -- row) or the row is gone: skipped — the caller pulls and retries.
      results := results || jsonb_build_array(jsonb_build_object(
        'status', 'skipped', 'current_version', current_version));
      continue;
    end if;

    -- The bytes swapped, the version KEPT, a fresh seq stamped.
    full_row := (item->'columns')
      || jsonb_build_object('sync_version', current_version, 'owner_id', caller);
    execute format('delete from %I where owner_id = $2 and %I = $1', tbl, pk)
      using row_id, caller;
    execute format(
      'insert into %I select * from jsonb_populate_record(null::%I, $1) returning server_seq',
      tbl, tbl)
      into granted_seq using full_row;
    results := results || jsonb_build_array(jsonb_build_object(
      'status', 'replaced', 'server_seq', granted_seq));
  end loop;
  return results;
end;
$$;

-- ---------------------------------------------------------------------------
-- 13. key_vault_update — THE ONE WRITE ROAD into the vault after creation
--     (replacing the client's PostgREST PATCH): the row locked FOR UPDATE
--     (decision 31's serialization point — every in-flight data round's
--     FOR SHARE must release first), the proof checked against the CURRENT
--     hash (the NULL-hash arm lands the first), the R1-2 revision CAS
--     inside, the format columns replaced WHOLE from the payload (an absent
--     nullable key ⇒ NULL — the full-replace semantics; the PATCH road's
--     set-only-present-keys let a re-key leave a STALE recovery wrap), the
--     hash REPLACEABLE by the payload (the rotation road — a call carrying
--     the current proof may install the next), and the rotation seq:
--       * the payload SETS a previous corpus key where none stands → a
--         rotation begins: `nextval('sync_server_seq')` into
--         `rotation_started_seq` in this same transaction;
--       * the payload carries the SAME previous key that stands → a carry-
--         through (a re-wrap mid-rotation): the seq is kept;
--       * the payload sets a DIFFERENT previous key while one stands →
--         VARIORUM_ROTATION_IN_PROGRESS (decision 32: one rotation at a
--         time; the acting device resumes through its marker, any device
--         holding M′ finishes);
--       * the payload clears the previous key → the seq clears with it
--         (completion: "no row of mine below it").
--     `revision`, `rotation_started_seq`, `user_id`, `created_at` and
--     `updated_at` are SERVER-managed — the payload's copies are ignored.
--     Returns `{revision, rotation_started_seq}` — the acting device reads
--     the seq that bounds its re-encryption.
-- ---------------------------------------------------------------------------

create or replace function key_vault_update(payload jsonb, expected_revision int, key_proof text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  caller uuid;
  vault_revision int;
  vault_previous text;
  vault_seq bigint;
  incoming_previous text;
  next_seq bigint;
  updated_rows int;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  select revision, corpus_previous_wrapped_by_master, rotation_started_seq
    into vault_revision, vault_previous, vault_seq
    from key_vault where user_id = caller for update;
  if vault_revision is null then
    raise exception 'VARIORUM_VAULT_ABSENT: no vault exists for this account — set up sync first';
  end if;

  perform sync_key_proof_check(key_proof);

  incoming_previous := payload->>'corpus_previous_wrapped_by_master';
  if incoming_previous is null then
    next_seq := null;
  elsif vault_previous is null then
    next_seq := nextval('sync_server_seq');
  elsif incoming_previous = vault_previous then
    next_seq := vault_seq;
  else
    raise exception 'VARIORUM_ROTATION_IN_PROGRESS: a key rotation started elsewhere is still finishing — let it complete before starting another';
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
    journal_bridge_key_id                = payload->>'journal_bridge_key_id',
    journal_bridge_key_wrapped_by_master = payload->>'journal_bridge_key_wrapped_by_master',
    master_wrapped_by_apple_held         = payload->>'master_wrapped_by_apple_held',
    apple_key_id                         = payload->>'apple_key_id',
    key_proof_hash                       = coalesce(payload->>'key_proof_hash', key_proof_hash),
    corpus_previous_wrapped_by_master    = incoming_previous,
    rotation_started_seq                 = next_seq,
    revision                             = expected_revision + 1,
    updated_at                           = now()
  where user_id = caller and revision = expected_revision;
  get diagnostics updated_rows = row_count;
  if updated_rows = 0 then
    raise exception 'VARIORUM_VAULT_REVISION_CONFLICT: the vault changed since it was fetched — fetch it again and re-derive';
  end if;

  return jsonb_build_object(
    'revision', expected_revision + 1,
    'rotation_started_seq', next_seq);
end;
$$;

-- ---------------------------------------------------------------------------
-- 14. Ownership: every DATA function belongs to the NON-BYPASS
--     `variorum_definer` role (the 14c gate repair's ruling — under FORCE
--     RLS the policies then genuinely bind their bodies; on `key_vault`,
--     ENABLE-only, the definer's own select + update policies are what let
--     the gate read and `key_vault_update` write). The six re-created
--     functions and the four new ones are owned by the deployer until the
--     alters below; the role needs CREATE on the schema for the
--     acquisition (the maintenance file's recorded lesson) — granted and
--     revoked in the same transaction. `account_purge` deliberately keeps
--     postgres (auth-schema DML); the trigger function keeps the deployer.
-- ---------------------------------------------------------------------------

grant usage, create on schema public to variorum_definer;

alter function sync_key_proof_check(text) owner to variorum_definer;
alter function sync_key_gate(text, text) owner to variorum_definer;
alter function sync_push(jsonb, text, text) owner to variorum_definer;
alter function sync_pull(bigint, text, int, text, text) owner to variorum_definer;
alter function sync_horizon(text, text) owner to variorum_definer;
alter function sync_purge_ledger(bigint, text, text) owner to variorum_definer;
alter function sync_purge_execute(jsonb, text, text) owner to variorum_definer;
alter function account_data_truncate(text, text) owner to variorum_definer;
alter function sync_reencrypt(jsonb, text, text) owner to variorum_definer;
alter function key_vault_update(jsonb, int, text) owner to variorum_definer;

revoke create on schema public from variorum_definer;

-- ---------------------------------------------------------------------------
-- 15. The demotion posture. The two sync RPCs keep the 09 posture
--     (authenticated + the named service_role default, zero live reach —
--     both bodies refuse a NULL auth.uid()); the purge functions, the
--     truncate, the re-encryption and the vault update take the
--     ACCOUNT-DOOR posture — authenticated only, service_role revoked by
--     name (each is a signed-in device's own act, never server
--     machinery's). The two helpers are reachable by NO API role: the
--     definer bodies are their only callers (the `sync_table_pk` posture).
-- ---------------------------------------------------------------------------

revoke execute on function sync_push(jsonb, text, text) from public, anon;
grant execute on function sync_push(jsonb, text, text) to authenticated, service_role;
revoke execute on function sync_pull(bigint, text, int, text, text) from public, anon;
grant execute on function sync_pull(bigint, text, int, text, text) to authenticated, service_role;

revoke execute on function sync_horizon(text, text) from public, anon, service_role;
revoke execute on function sync_purge_ledger(bigint, text, text) from public, anon, service_role;
revoke execute on function sync_purge_execute(jsonb, text, text) from public, anon, service_role;
revoke execute on function account_data_truncate(text, text) from public, anon, service_role;
revoke execute on function sync_reencrypt(jsonb, text, text) from public, anon, service_role;
revoke execute on function key_vault_update(jsonb, int, text) from public, anon, service_role;
grant execute on function sync_horizon(text, text) to authenticated;
grant execute on function sync_purge_ledger(bigint, text, text) to authenticated;
grant execute on function sync_purge_execute(jsonb, text, text) to authenticated;
grant execute on function account_data_truncate(text, text) to authenticated;
grant execute on function sync_reencrypt(jsonb, text, text) to authenticated;
grant execute on function key_vault_update(jsonb, int, text) to authenticated;

revoke execute on function sync_key_proof_check(text) from public, anon, authenticated, service_role;
revoke execute on function sync_key_gate(text, text) from public, anon, authenticated, service_role;
grant execute on function sync_key_proof_check(text) to variorum_definer;
grant execute on function sync_key_gate(text, text) to variorum_definer;

-- ---------------------------------------------------------------------------
-- 16. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
--     TRANSACTION, immediately before commit — a partial deploy can never
--     advertise the new version. The mirror now speaks lockstep version 8.
--     Must equal SyncSchema.lockstepVersion in the client — the in-repo DDL
--     pin fails the build if they drift.
-- ---------------------------------------------------------------------------

insert into sync_meta (key, value) values ('lockstep_version', '8')
  on conflict (key) do update set value = excluded.value;

commit;
