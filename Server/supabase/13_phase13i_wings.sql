-- Variorum sync mirror — the Phase 13i-a WINGS/SHELVES/BOOKS lockstep
-- event (SyncSpec §12; the binding design is the 13i sitting record §11 and
-- the execution plan `notes/plans/phase-13i-a-schema-event.md` §3/§5/§8).
-- Run AFTER 01–12. ONE transaction; the marker update is the last
-- statement inside it (12's discipline, kept).
--
-- THE DEPLOY RUNS ONLY AT THE AUTHOR'S WINDOW (CLAUDE.md's lockstep rule;
-- the 13i-a plan §8 is the checklist): mirror first, then her Mac Release
-- install and the phone build in the SAME window — the moment the marker
-- bumps to 10, every installed marker-9 build VISIBLY refuses to sync
-- (outbox intact, cursor unmoved — the §12 refusal grammar). Always behind
-- the A1 rail.
--
-- WHAT THIS EVENT SHIPS (the ONE 13i bundle — everything 13i b–e consumes,
-- landed before strangers; her 2026-08-25 bundling rule):
--   * `wing` + `shelf` — the two new synced tables (born multi-tenant on
--     09's exact posture: composite (owner_id, id) PK, stamp trigger,
--     (owner_id, server_seq) index, FORCE RLS + owner policy, zero
--     table-level grants). The virtual Home wing ('' on every pointer)
--     never exists as a row, so it never syncs (R-13ia-2).
--   * the additive mirror columns: reading's 13i nine (wing_id, shelf_id,
--     shelf_position, starred, owned, sealed_at, hide_owned,
--     intake_seating, auto_tag_id), container.wing_id, tag.wing_id
--     (R-13ia-1 — per-wing tags), reading_post.status (member|arrival).
--     All nullable (SyncSpec §2's dumb mirror — a row from before the
--     window reads its defaults client-side at apply; pinned).
--   * the six registry-carrying RPC bodies REDEFINED with the two tables
--     (sync_pull / sync_push / sync_reencrypt / account_data_truncate /
--     account_purge, and key_vault_update's ciphertext registry gaining
--     wing.name + shelf.name/glyph). Signatures UNCHANGED — create or
--     replace; no drops, no overloads.
--   * the client's recast rides the CLIENT migration (v1_18): the
--     gathering/book kind values and the v2 query_spec format travel as
--     ordinary row updates after the window; the mirror stores TEXT
--     either way (no CHECKs here, by design — §2).
--   * the marker: 9 → 10.

do $rerun_guard$
declare
  override        text    := nullif(current_setting('variorum.allow_13_rerun', true), '');
  deployed_marker int     := 1;
  wing_here       boolean := to_regclass('public.wing') is not null;
begin
  if override = 'yes-rerun-the-wings-event' then
    raise notice 'VARIORUM 13 RE-RUN OVERRIDE ACCEPTED — re-applying the wings/shelves event.';
    return;
  end if;

  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;

  if deployed_marker >= 10 or wing_here then
    raise exception using
      message = 'VARIORUM_13_ALREADY_DEPLOYED: this mirror has already run 13 (lockstep marker '
                || deployed_marker || '; wing table '
                || case when wing_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_13_rerun = ''yes-rerun-the-wings-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;

  if deployed_marker < 9 then
    raise exception using
      message = 'VARIORUM_13_PREREQUISITE_MISSING: this mirror is at lockstep marker '
                || deployed_marker || ' — run 12 (the per-tenant sequence event) first.';
  end if;
end
$rerun_guard$;

begin;

-- ---------------------------------------------------------------------------
-- 1. The two new tables — 09's born-multi-tenant posture, byte-for-shape.
--    Server-side both are ordinary data tables: in every allowlist, every
--    truncate/purge registry, both owner-carrying (the client schema has
--    owner_id on each, AppSpec §6's top-level-entity rule).
-- ---------------------------------------------------------------------------

drop table if exists wing;
create table wing (
  owner_id          uuid not null,
  id                text not null,
  name              text,
  position          text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_wing before insert or update on wing
  for each row execute function stamp_server_seq();
create index idx_owner_seq_wing on wing (owner_id, server_seq);
alter table wing enable row level security;
alter table wing force row level security;
create policy wing_owner_all on wing
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on wing from anon, authenticated;

drop table if exists shelf;
create table shelf (
  owner_id          uuid not null,
  id                text not null,
  wing_id           text,
  name              text,
  glyph             text,
  role              text,
  position          text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_shelf before insert or update on shelf
  for each row execute function stamp_server_seq();
create index idx_owner_seq_shelf on shelf (owner_id, server_seq);
alter table shelf enable row level security;
alter table shelf force row level security;
create policy shelf_owner_all on shelf
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on shelf from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 2. The additive columns on the existing mirrors — nullable, no defaults,
--    no constraints (SyncSpec §2: the dumb mirror accepts both sides of
--    every race so clients can repair deterministically; the CLIENT reads
--    an absent/NULL new column as its default — '' wing, 'member' status).
-- ---------------------------------------------------------------------------

alter table reading add column wing_id text;
alter table reading add column shelf_id text;
alter table reading add column shelf_position text;
alter table reading add column starred bigint;
alter table reading add column owned bigint;
alter table reading add column sealed_at text;
alter table reading add column hide_owned bigint;
alter table reading add column intake_seating text;
alter table reading add column auto_tag_id text;
alter table container add column wing_id text;
alter table tag add column wing_id text;
alter table reading_post add column status text;

-- Ladder R1 B-2 (belt beside the client's null-normalize): every PRE-WINDOW
-- row is backfilled with the client defaults, so a fresh device's first
-- pull serves real values rather than explicit nulls. (The re-seq the
-- stamp trigger performs on these updates is harmless: existing clients
-- discard the re-served rows by the sync_version-not-newer rule; fresh
-- pulls are exactly who the values are for. reading's nine columns are
-- backfilled too — its clients likewise read null-as-default, but the
-- mirror should say what the fleet converged on.)
update container set wing_id = '' where wing_id is null;
update tag set wing_id = '' where wing_id is null;
update reading_post set status = 'member' where status is null;
update reading set wing_id = '' where wing_id is null;
update reading set starred = 0 where starred is null;
update reading set owned = 0 where owned is null;

-- ---------------------------------------------------------------------------
-- 3. The six registry-carrying RPC bodies, REDEFINED (12's bodies VERBATIM
--    except the two tables joining each registry array — the headers and
--    reasoning in 12 hold unchanged; read them there). Signatures
--    unchanged, so `create or replace` replaces in place and no
--    challenge-free overload can come into being.
-- ---------------------------------------------------------------------------

-- 3a. sync_pull — 12's body verbatim; the allowlist and owner-table
--     arrays gain wing + shelf.

create or replace function sync_pull(since_seq bigint, active_key_id text, key_proof text, challenge text, max_rows int default 500, for_device text default null)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'wing', 'shelf', 'reading', 'reading_section',
    'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  owner_tables constant text[] := array[
    'container', 'block', 'wing', 'shelf', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment', 'purge_intent'];
  caller uuid;
  -- `for_device`, NOT `device_id` (2026-08-19, the window's first live
  -- round): the parameter's original name shadowed the device_cursor
  -- COLUMN inside the upsert's ON CONFLICT list — PL/pgSQL 42702, caught
  -- by the strict variable_conflict default doing exactly its job. The
  -- author's ruling: fix the NAME, never relax the policy — no RPC
  -- parameter may shadow a column it writes (the standing naming rule).
  dev text := for_device;
  -- 13y (the R-13y-4 fork's Shape 1): the A5 horizon, read ONCE from the
  -- one serving function; the two branch filters below derive from this
  -- local — no inline interval literal survives in this body, so the
  -- served value and the enforced value cannot drift.
  horizon interval := make_interval(secs => sync_visibility_horizon_ms() / 1000.0);
  tbl text;
  union_sql text := '';
  result jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE GATE (pre-13x; challenge-verified since 13y UNIT B): the vault
  -- row FOR SHARE, the fence, the proof.
  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_pull');

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
  -- partition. The visibility horizon (A5) is the derived-interval
  -- filter (the `horizon` local above — `sync_visibility_horizon_ms()`,
  -- 2000 ms): rows written within that window are never served.
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
             and t.server_written_at <= clock_timestamp() - %L::interval$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq, horizon);
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
             and t.server_written_at <= clock_timestamp() - %L::interval$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq, horizon);
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

-- 3b. sync_push — same.

create or replace function sync_push(batch jsonb, active_key_id text, key_proof text, challenge text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'wing', 'shelf', 'reading', 'reading_section',
    'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  -- The tables whose CLIENT schema carries owner_id (AppSpec §6 top-level
  -- entities + their later siblings): payloads carry owner and must
  -- carry the caller's. Everything else is mirror-only-owner: the
  -- server stamps on insert and subtracts on serve.
  owner_tables constant text[] := array[
    'container', 'block', 'wing', 'shelf', 'reading', 'tag', 'reference',
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
  batch_rows int;
  budget_lifetime bigint;
  budget_window_start timestamptz;
  budget_window_rows bigint;
  accepted_rows int := 0;
  quota_retry_after int;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE GATE (pre-13x; challenge-verified since 13y UNIT B): the vault
  -- row FOR SHARE, the fence, the proof.
  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_push');

  -- THE ENTITLEMENT GATE (THE DESIGN item 5): hosted sync is the tier.
  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  -- THE MINIMAL ABUSE GUARD (UNIT B, memo §4): the batch cap, then the
  -- budget row FOR UPDATE (after the vault lock — one order, no cycle),
  -- then the pool / the tumbling window. Refusal here aborts the whole
  -- call before any row lands — the §12 grammar's server half.
  batch_rows := jsonb_array_length(batch);
  if batch_rows > 2000 then
    raise exception 'VARIORUM_WRITE_QUOTA: the batch exceeds the per-call cap — retry_after_seconds=0';
  end if;
  insert into sync_write_budget (owner_id) values (caller)
  on conflict (owner_id) do update set owner_id = excluded.owner_id
  returning lifetime_rows, window_start, window_rows
    into budget_lifetime, budget_window_start, budget_window_rows;
  if budget_lifetime >= 500000 then
    if clock_timestamp() - budget_window_start >= interval '24 hours' then
      update sync_write_budget
        set window_start = clock_timestamp(), window_rows = 0
        where owner_id = caller;
      budget_window_rows := 0;
    elsif budget_window_rows + batch_rows > 50000 then
      quota_retry_after := greatest(0, ceil(extract(epoch from
        (budget_window_start + interval '24 hours' - clock_timestamp())))::int);
      raise exception 'VARIORUM_WRITE_QUOTA: this account reached its daily write limit — retry_after_seconds=%', quota_retry_after;
    end if;
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
        accepted_rows := accepted_rows + 1;
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
      accepted_rows := accepted_rows + 1;
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
  -- THE GUARD's increment: the ACTUAL accepted rows, on the same locked
  -- row (memo §4's "accepted row-writes" — CAS rejects burn nothing).
  if accepted_rows > 0 then
    update sync_write_budget
      set lifetime_rows = lifetime_rows + accepted_rows,
          window_rows   = window_rows + accepted_rows
      where owner_id = caller;
  end if;
  return results;
end;
$$;

-- 3c. sync_reencrypt — same.

create or replace function sync_reencrypt(rows jsonb, active_key_id text, key_proof text, challenge text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'wing', 'shelf', 'reading', 'reading_section',
    'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  owner_tables constant text[] := array[
    'container', 'block', 'wing', 'shelf', 'reading', 'tag', 'reference',
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

  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_reencrypt');

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

-- 3d. account_data_truncate — the data_tables registry gains both.

create or replace function account_data_truncate(active_key_id text, key_proof text, challenge text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  data_tables constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'wing', 'shelf', 'reading', 'reading_section',
    'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  caller uuid;
  tbl text;
  removed bigint;
  counts jsonb := '{}'::jsonb;
  newest_password_auth timestamptz;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  -- THE GATE (the sync RPCs' exact arm: the fence, then the proof).
  perform sync_key_gate(active_key_id, key_proof, challenge, 'account_data_truncate');

  -- THE RECENT-RE-AUTH WINDOW (13y UNIT B, memo §5 — 10 minutes): the
  -- session's newest PASSWORD-method amr entry must be inside it; absent
  -- or stale refuses typed. The doors' client flow signs in immediately
  -- before acting, so an honest act always passes.
  select to_timestamp(max((amr_entry->>'timestamp')::bigint))
    into newest_password_auth
    from jsonb_array_elements(coalesce(auth.jwt()->'amr', '[]'::jsonb)) amr_entry
    where amr_entry->>'method' = 'password';
  if newest_password_auth is null
     or newest_password_auth < now() - interval '10 minutes' then
    raise exception 'VARIORUM_REAUTH_REQUIRED: this act needs a fresh sign-in — confirm the account password and try again';
  end if;

  foreach tbl in array data_tables loop
    execute format('delete from %I where owner_id = $1', tbl) using caller;
    get diagnostics removed = row_count;
    counts := counts || jsonb_build_object(tbl, removed);
  end loop;
  -- THE POOL RESET (memo §4): the repush after a re-key is a FIRST LOAD.
  delete from sync_write_budget where owner_id = caller;
  return counts;
end;
$$;

-- 3e. key_vault_update — the CANONICAL body moves here (the completion
--     guard's ciphertext registry gains wing.name and shelf.name/glyph;
--     everything else byte-verbatim from 12).

create or replace function key_vault_update(payload jsonb, expected_revision int, key_proof text, challenge text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  caller uuid;
  vault_revision int;
  vault_previous_id text;
  vault_previous text;
  vault_seq bigint;
  incoming_previous_id text;
  incoming_previous text;
  next_seq bigint;
  updated_rows int;
  -- THE COMPLETION GUARD's declarations (folded from the pre-13x ladder's
  -- F1 overlay — BLOCKER-1). THE ENCRYPTED COLUMNS, PER TABLE — every
  -- registry table with at least one encrypted-classified column and
  -- exactly those columns (the client's `SyncTable.encryptedColumns`;
  -- pinned equal by `AuthRLSDDLTests`). A row CARRIES CIPHERTEXT when at
  -- least one of them is NOT NULL; a row with none is under no key and
  -- never holds a completion.
  ciphertext_columns constant jsonb := '{
    "container": ["title", "floating_notes"],
    "block": ["name", "presentation"],
    "variant": ["working_text", "label"],
    "commit_point": ["text", "message"],
    "tag": ["name", "path"],
    "wing": ["name"],
    "shelf": ["name", "glyph"],
    "reading": ["name", "query_spec"],
    "reading_section": ["name"],
    "reference": ["name", "url", "view_state"],
    "lens": ["name"],
    "block_comment": ["text"]
  }'::jsonb;
  rows_below_tbl text;
  rows_below_cols text;
  rows_below bigint;
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

  select revision, corpus_previous_key_id, corpus_previous_wrapped_by_master, rotation_started_seq
    into vault_revision, vault_previous_id, vault_previous, vault_seq
    from key_vault where user_id = caller for update;
  if vault_revision is null then
    raise exception 'VARIORUM_VAULT_ABSENT: no vault exists for this account — set up sync first';
  end if;

  perform sync_key_proof_check(key_proof, challenge, 'key_vault_update');

  -- The R1-2 revision CAS, PRE-CHECKED under the held lock (13y UNIT B:
  -- the successor rule below must never mask a stale fetch's honest
  -- refetch-and-re-derive contract — a stale payload's outdated hash
  -- would otherwise refuse as a proof fault; the UPDATE's own filter
  -- stays below as the belt, byte-unchanged).
  if vault_revision is distinct from expected_revision then
    raise exception 'VARIORUM_VAULT_REVISION_CONFLICT: the vault changed since it was fetched — fetch it again and re-derive';
  end if;

  -- THE ROTATION'S SUCCESSOR (13y UNIT B, memo §3): hash and secret land
  -- TOGETHER or not at all. The vault row is already locked FOR UPDATE
  -- above, so this read-then-write is serialized per account.
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

  incoming_previous_id := payload->>'corpus_previous_key_id';
  incoming_previous := payload->>'corpus_previous_wrapped_by_master';
  if (incoming_previous is null) <> (incoming_previous_id is null) then
    raise exception 'a previous corpus key travels as its id AND its wrap — never one without the other';
  end if;
  if incoming_previous is null then
    -- THE COMPLETION GUARD (the ladder's BLOCKER-1; decision 31's letter —
    -- "no row of mine below it"): clearing a STANDING previous key is
    -- refused while any row of the caller's partition that CARRIES
    -- CIPHERTEXT (at least one encrypted column not null) still sits below
    -- the rotation seq. Exact here: the row is locked FOR UPDATE, so every
    -- in-flight old-proof push (FOR SHARE) has committed, and the count
    -- reads committed rows regardless of `sync_pull`'s visibility horizon;
    -- and every such row is one the client walk re-stamps, so the refusal
    -- can never outlast a walk that saw it. The caller re-walks (any device
    -- holding the new master can) and clears again.
    if vault_previous is not null then
      for rows_below_tbl in select jsonb_object_keys(ciphertext_columns) loop
        select string_agg(format('t.%I is not null', c.col), ' or ')
          into rows_below_cols
          from jsonb_array_elements_text(ciphertext_columns->rows_below_tbl) as c(col);
        execute format(
          'select count(*) from %I t where t.owner_id = $1 and t.server_seq < $2 and (%s)',
          rows_below_tbl, rows_below_cols)
          into rows_below using caller, vault_seq;
        if rows_below > 0 then
          raise exception 'VARIORUM_ROTATION_ROWS_REMAIN: % row(s) of % still carry ciphertext under the previous corpus key — re-encrypt the remainder before clearing it',
            rows_below, rows_below_tbl;
        end if;
      end loop;
    end if;
    -- Completion (or no rotation): the key, its id and the seq clear together.
    next_seq := null;
  elsif vault_previous is null then
    -- A rotation begins: the next value of the CALLER'S OWN counter — the
    -- rows' own sequence (13y, M3) — inside this transaction, with the
    -- row locked.
    next_seq := next_tenant_seq(caller);
  elsif incoming_previous = vault_previous and incoming_previous_id = vault_previous_id then
    -- A carry-through (decision 32's precision): a re-wrap mid-rotation
    -- sends the vault whole with the SAME previous key — not a second
    -- rotation; the seq is kept.
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
    corpus_previous_key_id               = incoming_previous_id,
    corpus_previous_wrapped_by_master    = incoming_previous,
    rotation_started_seq                 = next_seq,
    updated_by_device                    = payload->>'updated_by_device',
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

-- 3f. sync_purge_execute — the purge door's allowlist gains both
--     (a tombstoned wing/shelf row is an ordinary purge family member
--     once the horizon passes; 12's body verbatim otherwise).

create or replace function sync_purge_execute(rows jsonb, active_key_id text, key_proof text, challenge text) returns bigint
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'wing', 'shelf', 'reading', 'reading_section',
    'reading_post', 'tag',
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
  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_purge_execute');

  -- NO RE-AUTH WINDOW HERE (memo §5 as AMENDED 2026-09-23, ladder R1 F-R1):
  -- the 13j janitor calls this door UNATTENDED, so a 10-minute amr check
  -- would freeze the autonomous purge pipeline. The gate above (the
  -- challenge-verified proof) + the own-partition deletes below are its
  -- walls. `account_data_truncate` keeps its re-auth window; this door
  -- deliberately does not.
  granted_seq := next_tenant_seq(caller);
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

-- 3f. account_purge — the data_tables registry gains both.

create or replace function account_purge() returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  data_tables constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'wing', 'shelf', 'reading', 'reading_section',
    'reading_post', 'tag',
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

  -- The purge machinery's own account rows go with the account — and,
  -- since 13y, the account's sequence counter with them; UNIT B adds the
  -- challenge nonces, the write-budget row, and the Vault-held MAC
  -- secret. The secret's delete is BEST-EFFORT under this function's
  -- `postgres` owner (vault-schema privileges are the window's probe): a
  -- failure never fails the purge — deletion is mandated and loud, and a
  -- dangling secret for a dead uuid authorizes nothing (no auth user can
  -- ever present it; a re-created account is a NEW uuid, a new name) —
  -- recorded, window-verified.
  delete from device_cursor where owner_id = caller;
  delete from purged_row where owner_id = caller;
  delete from sync_tenant_seq where owner_id = caller;
  delete from key_proof_challenge where owner_id = caller;
  delete from sync_write_budget where owner_id = caller;
  begin
    delete from vault.secrets where name = 'kp:' || caller::text;
  exception when others then
    null;
  end;

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
-- 4. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
--    TRANSACTION, immediately before commit — a partial deploy can never
--    advertise the new version. The mirror now speaks lockstep version 10.
--    Must equal SyncSchema.lockstepVersion in the client — the in-repo
--    DDL pin fails the build if they drift.
-- ---------------------------------------------------------------------------

insert into sync_meta (key, value) values ('lockstep_version', '10')
  on conflict (key) do update set value = excluded.value;

commit;

-- Verification (read-only; the window runs these — the 13i-a plan §8):
--   select sync_schema_version();                                    -- 10
--   select to_regclass('public.wing'), to_regclass('public.shelf');  -- both present
--   select count(*) from wing; select count(*) from shelf;           -- 0 and 0 at the window
--   select relrowsecurity, relforcerowsecurity from pg_class
--     where relname in ('wing','shelf');                             -- t, t on both rows
--   select pg_get_functiondef('sync_pull(bigint,text,text,text,int,text)'::regprocedure)
--          like '%''wing'', ''shelf''%';                             -- true (the allowlist grew)
--   select pg_get_functiondef('key_vault_update(jsonb, int, text, text)'::regprocedure)
--          like '%"shelf": ["name", "glyph"]%';                      -- true (the ciphertext registry grew)
--   select column_name from information_schema.columns
--     where table_name = 'reading' and column_name in
--       ('wing_id','shelf_id','shelf_position','starred','owned',
--        'sealed_at','hide_owned','intake_seating','auto_tag_id');   -- nine rows
