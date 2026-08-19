-- Variorum sync mirror — the Phase 13j purge lockstep event (batch 6b;
-- SyncSpec §12). Run AFTER 01–09 (+ the 14c maintenance artifacts — the
-- `variorum_definer` role this file assigns ownership to is created by
-- maintenance/14c-gate-definer-owner.sql), via the author's PAT
-- arrangement.
--
-- THE DEPLOY IS PRE-AUTHORIZED (her round-8 ruling, verbatim: "The small
-- purge_intent table is fine and I'll authorize the DDL and mirror deploy
-- right now - that's fine for them to have") and EXECUTES ONLY at the
-- ARCHITECT's one-window — never a batch implementer. The window bundles
-- the Mac Release refresh AND a fresh PHONE build over the tunnel (round
-- 9's one-window sequencing): the moment the marker bumps to 7, every
-- installed marker-6 build VISIBLY refuses to sync (outbox intact, cursor
-- unmoved — the §12 refusal grammar; offline is free while it waits).
-- Always behind the A1 rail where any store-adjacent act rides the window.
--
-- WHAT THIS EVENT SHIPS (the purge memo, notes/plans/phase-13j-purge-memo.md,
-- §5 — every author call closed at sitting rounds 8/8b/9/10 — plus the
-- post-batch-6 architect adjudication's two mechanical notes):
--   * `purge_intent`, the ONE new SYNCED table (client migration v1_14):
--     "this is going, everywhere" — one row per thing being purged, ids
--     and enums only, no user words by design. Born multi-tenant in the
--     09 idiom (composite PK, owner policy, FORCE RLS, seq stamp).
--   * `device_cursor`, server-only: the per-device pull cursor that makes
--     a horizon computable at all. DISCLOSURE (the adjudication's note 2,
--     the 14c I-1 precedent): `seen_at` discloses per-device activity
--     TIMING (content-free) to the server operator — recorded in the
--     E2EE disclosure envelope.
--   * `purged_row`, server-only: the content-free purged-ids ledger that
--     fences a returner — a push naming a purged id is refused with the
--     typed 'purged' status and the client drops that outbox entry (and
--     its local copy) instead of resurrecting the row.
--   * `sync_horizon()` — the account's lowest live-device cursor; a
--     device unseen for 60 days (her round-8 ruling) leaves the horizon.
--   * `sync_purge_ledger(since_seq)` — the ledger page a client reads to
--     reconcile row-by-row, plus the coverage FLOOR (0 until ledger
--     pruning exists; the future pruning rider advances it and owes the
--     returner face).
--   * `sync_purge_execute(rows)` — the purge-execution RPC (the
--     adjudication's note 1): the family DELETE + the ledger INSERTs,
--     one transaction, tenant-scoped, owned by the NON-BYPASS
--     `variorum_definer` role (the 14c gate pattern). The server stays
--     DUMB: the FAMILY EXPANSION is the client's (`PurgeFamily`) — this
--     door deletes exactly the rows it is handed, inside the caller's
--     own partition only. A caller can only ever purge its OWN rows,
--     which is the account_data_truncate trust posture exactly.
--   * sync_push REWRITTEN: the typed 'purged' per-row refusal (the
--     ledger check before the CAS), and `purge_intent` joining the
--     allowed + owner-carried arrays.
--   * sync_pull REWRITTEN with a NEW SIGNATURE: `device_id text default
--     null` — the cursor UPSERT rides the same round trip (memo §5b item
--     5; MECHANICAL CORRECTION recorded there and in the batch record:
--     the 14c signatures did NOT already carry the device — the
--     parameter is added here, additive). The OLD signature is DROPPED
--     FIRST (the 09 discipline — an overload left standing would be a
--     cursor-less door beside the new one).
--   * account_data_truncate / account_purge REWRITTEN only insofar as
--     the registry grew: `purge_intent` joins their data_tables arrays
--     (the DDL pins hold those arrays registry-exact). account_purge
--     additionally removes the caller's device_cursor and purged_row
--     rows — the whole account goes. account_data_truncate deliberately
--     touches NEITHER: purged stays purged across a re-key, and cursors
--     stay valid under the monotonic sequence.
--
-- NO ENTITLEMENT GATE on the three purge functions, deliberately: purge
-- is data REMOVAL, and data removal is a right, never commerce-gated
-- (account_data_truncate's recorded reasoning, applied to the same
-- class). The VAULT-KEY-ID FENCE does apply to all three — a stale-keyed
-- device must not drive purges.
--
-- THE CHOREOGRAPHY (SyncSpec §12): this file runs on the mirror FIRST,
-- at the architect's one-window under her standing PRE-AUTHORIZED go —
-- never a batch implementer; then every client updates (the Mac Release
-- + the phone build, bundled into the same window); only then may any
-- client write what the new schema shapes. A marker-6 client refuses
-- the marker-7 mirror and vice versa — stalling is safe by design.
--
-- THIS FILE EXECUTES AS ONE TRANSACTION (the 09/I-3 discipline): begin →
-- re-run guard → DDL/functions → grants → the marker LAST → commit. A
-- failed run rolls back whole, marker untouched; an honest retry needs
-- no override.

begin;

-- ---------------------------------------------------------------------------
-- 0a. THE RE-RUN GUARD — first statement inside the transaction, before
--     the one destructive statement below (the old sync_pull signature
--     drop). Keyed on evidence only a deployed 10 leaves: the marker at
--     7+, or the `purge_intent` table no other artifact creates.
-- ---------------------------------------------------------------------------

do $rerun_guard$
declare
  override          text    := nullif(current_setting('variorum.allow_10_rerun', true), '');
  deployed_marker   int     := 1;
  purge_table_here  boolean := to_regclass('public.purge_intent') is not null;
begin
  if override = 'yes-rerun-the-purge-event' then
    raise notice 'VARIORUM 10 RE-RUN OVERRIDE ACCEPTED — re-applying the purge lockstep event.';
    return;
  end if;

  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;

  if deployed_marker >= 7 or purge_table_here then
    raise exception using
      message = 'VARIORUM_10_ALREADY_DEPLOYED: this mirror has already run 10 (lockstep marker '
                || deployed_marker || '; purge_intent table '
                || case when purge_table_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_10_rerun = ''yes-rerun-the-purge-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;
end
$rerun_guard$;

-- ---------------------------------------------------------------------------
-- 0. Drop the OLD sync_pull signature before creating the new one
--    (Postgres overloads by signature — the 09 discipline): a lingering
--    sync_pull(bigint, text, int) would keep serving the changefeed with
--    no cursor upsert, silently starving the horizon.
-- ---------------------------------------------------------------------------

drop function if exists sync_pull(bigint, text, int);

-- ---------------------------------------------------------------------------
-- 1. purge_intent — the ONE new synced table, born multi-tenant in the
--    09 idiom (the mirror twin of client migration v1_14). NO uniqueness
--    beyond the composite PK and NO foreign keys (SyncSpec §2's
--    load-bearing dumbness — the client repairs the live-unique
--    (table_name, row_id) pair as a pure duplicate, smaller id wins).
-- ---------------------------------------------------------------------------

create table purge_intent (
  owner_id          uuid not null,
  id                text not null,
  table_name        text,
  row_id            text,
  requested_at      text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_purge_intent before insert or update on purge_intent
  for each row execute function stamp_server_seq();
create index idx_owner_seq_purge_intent on purge_intent (owner_id, server_seq);
alter table purge_intent enable row level security;
alter table purge_intent force row level security;
create policy purge_intent_owner_all on purge_intent
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on purge_intent from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 2. device_cursor — the per-device pull cursor (server-only, never a
--    mirror data table: it appears in no allowlist and no client schema).
--    `seen_at` is the 60-day horizon-membership clock. Content-free;
--    its timing disclosure is recorded in the E2EE disclosure envelope.
-- ---------------------------------------------------------------------------

create table device_cursor (
  owner_id  uuid not null,
  device_id text not null,
  last_seq  bigint not null default 0,
  seen_at   timestamptz not null default now(),
  primary key (owner_id, device_id)
);
alter table device_cursor enable row level security;
alter table device_cursor force row level security;
create policy device_cursor_owner_all on device_cursor
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on device_cursor from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 3. purged_row — the content-free purged-ids ledger: ids only, no
--    words. An entry fences a returner (the push RPC's 'purged' status)
--    and feeds the client's row-by-row reconciliation scan. Ledger
--    PRUNING is deliberately unbuilt (the memo's own answer: prunable on
--    the same horizon, one level up) — the future pruning rider owns it,
--    and until then `sync_purge_ledger`'s floor stays 0.
-- ---------------------------------------------------------------------------

create table purged_row (
  owner_id   uuid not null,
  table_name text not null,
  row_id     text not null,
  purged_seq bigint not null,
  primary key (owner_id, table_name, row_id)
);
alter table purged_row enable row level security;
alter table purged_row force row level security;
create policy purged_row_owner_all on purged_row
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on purged_row from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 4. sync_push — the 09 body VERBATIM plus exactly two changes: the
--    ledger check (a row named in purged_row answers the typed 'purged'
--    status BEFORE any CAS work — the client drops that outbox entry and
--    its local copy instead of retrying), and `purge_intent` joining the
--    allowed + owner_tables arrays (its client schema carries owner_id).
-- ---------------------------------------------------------------------------

create or replace function sync_push(batch jsonb, active_key_id text) returns jsonb
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
  fence_key text;
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

  -- THE VAULT-KEY-ID FENCE (THE DESIGN item 2): the caller's presented
  -- corpus key id must match the account's current key_vault row. A
  -- mismatch — or a missing vault row — refuses the WHOLE round before
  -- any row is touched (the CF-16 replaced state, client-classified).
  select corpus_key_id into fence_key from key_vault where user_id = caller;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

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
-- 5. sync_pull — the 09 body VERBATIM plus exactly two changes: the NEW
--    `device_id text default null` parameter with its cursor UPSERT (one
--    round trip — the engine passes the device id with its FIRST window
--    of a round, whose `since_seq` is the device's COMMITTED cursor;
--    later windows pass null, so a mid-round crash can never over-report
--    what the device has integrated), and `purge_intent` joining the
--    arrays. The A5 visibility horizon and the server-only column
--    subtraction are preserved verbatim.
-- ---------------------------------------------------------------------------

create or replace function sync_pull(since_seq bigint, active_key_id text, max_rows int default 500, device_id text default null)
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
  fence_key text;
  dev text := device_id;
  tbl text;
  union_sql text := '';
  result jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE VAULT-KEY-ID FENCE (same as push — both round halves refuse).
  select corpus_key_id into fence_key from key_vault where user_id = caller;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

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
-- 6. sync_horizon — the account's lowest live-device cursor (the memo's
--    §2 rule: purge only what every device has already seen deleted). A
--    device unseen for 60 days (her round-8 ruling) leaves the horizon;
--    an account with NO recorded cursors answers 0, and nothing is ≤ 0 —
--    the janitor's safe no-op. Auth + fence, deliberately NO entitlement
--    gate (purge is data removal — a right, the account_data_truncate
--    reasoning). SECURITY DEFINER, variorum_definer-owned (a data read).
-- ---------------------------------------------------------------------------

create or replace function sync_horizon(active_key_id text) returns bigint
language plpgsql security definer
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
  select corpus_key_id into fence_key from key_vault where user_id = caller;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;
  return coalesce(
    (select min(last_seq) from device_cursor
      where owner_id = caller and seen_at > now() - interval '60 days'),
    0);
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. sync_purge_ledger — the ledger page for the client's row-by-row
--    reconciliation scan (entries above `since_seq`) plus the coverage
--    FLOOR: the seq below which ledger completeness is no longer
--    guaranteed. 0 while ledger pruning is unbuilt (nothing has ever
--    been pruned, so coverage is complete from the beginning of time);
--    the future pruning rider advances it — and a client whose scan
--    point is below the floor takes the SAY-SO-FIRST returner road
--    (round 10). Same posture as sync_horizon.
-- ---------------------------------------------------------------------------

create or replace function sync_purge_ledger(since_seq bigint, active_key_id text) returns jsonb
language plpgsql security definer
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
  select corpus_key_id into fence_key from key_vault where user_id = caller;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;
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
-- 8. sync_purge_execute — the purge-execution RPC (the adjudication's
--    note 1): deletes EXACTLY the rows it is handed, inside the caller's
--    own partition, and records every one in the ledger — ONE
--    transaction (this function IS one transaction). Idempotent: a row
--    already gone deletes zero and its ledger entry upserts silently, so
--    a janitor resuming mid-family re-runs this safely. The family
--    expansion is deliberately CLIENT-side (the server stays dumb —
--    SyncSpec §2; family semantics are domain knowledge). One granted
--    seq per call stamps every entry: the purge is one event.
-- ---------------------------------------------------------------------------

create or replace function sync_purge_execute(rows jsonb, active_key_id text) returns bigint
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
  fence_key text;
  item jsonb;
  tbl text;
  pk text;
  granted_seq bigint;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;
  select corpus_key_id into fence_key from key_vault where user_id = caller;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

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
-- 9. account_data_truncate — the 09 body verbatim; the ONLY change is
--    `purge_intent` joining data_tables (the registry grew — the DDL
--    pin holds the array registry-exact). device_cursor and purged_row
--    are DELIBERATELY untouched: purged stays purged across a re-key,
--    and cursors stay valid under the monotonic sequence.
-- ---------------------------------------------------------------------------

create or replace function account_data_truncate(active_key_id text) returns jsonb
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
  fence_key text;
  tbl text;
  removed bigint;
  counts jsonb := '{}'::jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  -- THE VAULT-KEY-ID FENCE (the sync RPCs' exact arm, same marker).
  select corpus_key_id into fence_key from key_vault where user_id = caller;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

  foreach tbl in array data_tables loop
    execute format('delete from %I where owner_id = $1', tbl) using caller;
    get diagnostics removed = row_count;
    counts := counts || jsonb_build_object(tbl, removed);
  end loop;
  return counts;
end;
$$;

-- ---------------------------------------------------------------------------
-- 10. account_purge — the 09 body verbatim; the changes: `purge_intent`
--     joins data_tables, and the caller's device_cursor + purged_row
--     rows go too — the WHOLE account goes (her Round-5 ruling's letter,
--     extended to the tables this event adds). Order preserved: data →
--     vault → entitlement → the auth user LAST.
-- ---------------------------------------------------------------------------

create or replace function account_purge() returns jsonb
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
  data_rows bigint := 0;
  vault_rows bigint;
  entitlement_rows bigint;
  auth_rows bigint;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  foreach tbl in array data_tables loop
    execute format('delete from %I where owner_id = $1', tbl) using caller;
    get diagnostics removed = row_count;
    data_rows := data_rows + removed;
  end loop;

  -- The purge machinery's own account rows go with the account.
  delete from device_cursor where owner_id = caller;
  delete from purged_row where owner_id = caller;

  delete from key_vault where user_id = caller;
  get diagnostics vault_rows = row_count;

  delete from entitlement where user_id = caller;
  get diagnostics entitlement_rows = row_count;

  -- The auth user LAST — the deliberate reporting order (ladder R1-2).
  delete from auth.users where id = caller;
  get diagnostics auth_rows = row_count;

  return jsonb_build_object(
    'data_rows', data_rows,
    'vault_rows', vault_rows,
    'entitlement_rows', entitlement_rows,
    'auth_user_removed', auth_rows > 0);
end;
$$;

-- ---------------------------------------------------------------------------
-- 11. Ownership: the DATA functions belong to the NON-BYPASS
--     `variorum_definer` role (the 14c gate repair's ruling — under
--     FORCE RLS the policies then genuinely bind their bodies).
--     CREATE OR REPLACE preserved the existing owners for sync_push /
--     account_data_truncate; the re-created sync_pull and the three new
--     functions are owned by the deployer until the alters below. The
--     role needs CREATE on the schema for the acquisition (the
--     maintenance file's recorded lesson) — granted and revoked in the
--     same transaction. account_purge deliberately keeps postgres
--     (auth-schema DML, the maintenance file's recorded reasoning).
-- ---------------------------------------------------------------------------

grant usage, create on schema public to variorum_definer;
grant select, insert, update, delete on purge_intent to variorum_definer;
grant select, insert, update on device_cursor to variorum_definer;
grant select, insert on purged_row to variorum_definer;

alter function sync_push(jsonb, text) owner to variorum_definer;
alter function sync_pull(bigint, text, int, text) owner to variorum_definer;
alter function account_data_truncate(text) owner to variorum_definer;
alter function sync_horizon(text) owner to variorum_definer;
alter function sync_purge_ledger(bigint, text) owner to variorum_definer;
alter function sync_purge_execute(jsonb, text) owner to variorum_definer;

revoke create on schema public from variorum_definer;

-- ---------------------------------------------------------------------------
-- 12. The demotion posture. The sync RPCs keep the 09 posture
--     (authenticated + the named service_role default, zero live reach —
--     both bodies refuse a NULL auth.uid()); the three purge functions
--     take the ACCOUNT-DOOR posture — authenticated only, service_role
--     revoked by name (a purge is always a signed-in device's own act,
--     never server machinery's).
-- ---------------------------------------------------------------------------

revoke execute on function sync_pull(bigint, text, int, text) from public, anon;
grant execute on function sync_pull(bigint, text, int, text) to authenticated, service_role;
revoke execute on function sync_horizon(text) from public, anon, service_role;
revoke execute on function sync_purge_ledger(bigint, text) from public, anon, service_role;
revoke execute on function sync_purge_execute(jsonb, text) from public, anon, service_role;
grant execute on function sync_horizon(text) to authenticated;
grant execute on function sync_purge_ledger(bigint, text) to authenticated;
grant execute on function sync_purge_execute(jsonb, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 13. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
--     TRANSACTION, immediately before commit — a partial deploy can
--     never advertise the new version. The mirror now speaks lockstep
--     version 7. Must equal SyncSchema.lockstepVersion in the client —
--     the in-repo DDL pin fails the build if they drift.
-- ---------------------------------------------------------------------------

insert into sync_meta (key, value) values ('lockstep_version', '7')
  on conflict (key) do update set value = excluded.value;

commit;
