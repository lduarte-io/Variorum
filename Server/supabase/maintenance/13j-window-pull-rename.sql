-- Variorum sync mirror — 13j WINDOW REPAIR (the 14c-gate maintenance
-- pattern): the first LIVE pull after the marker-7 deploy failed with
-- 42702 "column reference \"device_id\" is ambiguous" — the new
-- sync_pull's PARAMETER shadowed the device_cursor COLUMN inside the
-- cursor upsert's ON CONFLICT list. The strict variable_conflict default
-- did exactly its job; THE AUTHOR'S RULING (2026-08-19, in-window): fix
-- the NAME, never relax the policy — the parameter renames to
-- `for_device` (the wire key renames with it; both device builds
-- reinstall in the same window), and the standing rule is born: no RPC
-- parameter may shadow a column it writes.
--
-- Postgres cannot rename a parameter via CREATE OR REPLACE, so: DROP the
-- deployed signature, CREATE the corrected function (byte-identical to
-- the canonical 10_phase13j_purge.sql after its same-day fix), then
-- re-assign ownership and grants (they die with the drop). One
-- transaction; safe to re-run (the drop is IF EXISTS and the grants are
-- idempotent).

begin;

drop function if exists sync_pull(bigint, text, int, text);

create or replace function sync_pull(since_seq bigint, active_key_id text, max_rows int default 500, for_device text default null)
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

alter function sync_pull(bigint, text, int, text) owner to variorum_definer;
revoke execute on function sync_pull(bigint, text, int, text) from public, anon;
grant execute on function sync_pull(bigint, text, int, text) to authenticated, service_role;

commit;
