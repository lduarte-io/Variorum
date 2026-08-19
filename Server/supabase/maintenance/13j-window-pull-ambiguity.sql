-- Variorum sync mirror — 13j WINDOW REPAIR (registry-pinned like the 14c
-- gate maintenance artifacts): the first LIVE pull after the marker-7
-- deploy failed with 42702 "column reference \"device_id\" is ambiguous" —
-- the new sync_pull's cursor-UPSERT conflict target parses where the
-- `device_id` PARAMETER is visible (the fake-server harness cannot reach
-- PL/pgSQL name resolution; the deploy checklist carried exactly this as
-- PENDING-until-live). The parameter name is the PostgREST wire contract
-- and cannot change; `#variable_conflict use_column` resolves the class
-- name-independently. This file re-deploys the ONE function, corrected —
-- byte-identical to the canonical 10_phase13j_purge.sql after its same-day
-- fix, so a future fresh deploy of 10 alone is already correct.
-- Executed via the author's PAT arrangement in the same 13j window.

create or replace function sync_pull(since_seq bigint, active_key_id text, max_rows int default 500, device_id text default null)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
-- 42702 FIX (2026-08-19, the window's first live round — caught exactly
-- where the deploy checklist marked PENDING "only a live call proves the
-- Postgres side"): the `device_id` PARAMETER is visible inside the cursor
-- UPSERT's ON CONFLICT column list, and PL/pgSQL raises "column reference
-- device_id is ambiguous". The parameter CANNOT be renamed (PostgREST
-- passes named JSON keys — the name IS the wire contract), so columns win
-- by pragma; every variable read in this function's static SQL was swept
-- for same-named columns in scope (none exist — the sweep is in the 13j
-- plan's window record). Re-deployed via
-- maintenance/13j-window-pull-ambiguity.sql.
#variable_conflict use_column
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
