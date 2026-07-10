-- Variorum sync mirror — auth alignment (Phase 9c, Step 3; SyncSpec §2 note,
-- QUESTIONS #9). Run AFTER 01_mirror_schema.sql + 02_sync_rpc.sql +
-- 03_visibility_horizon.sql — and ONLY after the owner_id backfill has
-- converged on the mirror and every client (SyncSpec §12 lockstep, exactly:
-- (1) Step 4's `adoptOwnerID` backfill runs and PUSHES from the Mac, the
-- phone pulls/converges — no live or tombstoned row on any owner-carrying
-- table still has NULL owner_id anywhere; (2) THEN the author pastes this
-- file in the SQL editor; (3) only then do clients sync under auth. A
-- half-done state is safe by construction: until this file runs, the mirror
-- keeps the pre-existing key-auth posture; after it runs, an unauthenticated
-- or wrongly-owned call FAILS the whole RPC — the client's round fails
-- visibly, outbox intact, cursor unmoved. Stalling is free; guessing is
-- forbidden.)
--
-- WHAT THIS CLOSES (the 02_sync_rpc.sql SECURITY NOTE's debt): the RPCs
-- performed no auth check beyond the API-key gate, so ANY bearer of the key
-- was a full read/write token to the corpus. After this file:
--   * the API key alone grants NOTHING — RPC execution requires an
--     authenticated Supabase Auth user (the key demotes to genuinely
--     publishable);
--   * every row pushed to or served from an owner-carrying table
--     (container, block, reading, tag, reference) must carry
--     owner_id = auth.uid();
--   * direct Data-API access to the mirror tables is dead (RLS enabled
--     with no policies + privileges revoked) — the two RPCs are the only
--     doors, and they are SECURITY DEFINER (owner-run, so RLS does not
--     bind them; their own guards do).
--
-- WHAT THIS DOES NOT DO (Phase 14's, deliberately): per-user isolation of
-- the NON-owner tables (variant, commit_point, edge, container_block,
-- reading, reading_post, post_tag, block_tag, setting rows have no owner
-- column; isolating them needs parent joins). In the single-user phase every
-- authenticated user is the author; commercial multi-tenancy hardens this
-- at the accounts phase. This file changes WHO may call the endpoints,
-- never what the server stores (no E2EE front-running).
--
-- Future mirror tables (e.g. Phase 11's canvas_layout) must repeat the
-- per-table pattern below in their own lockstep migration.

-- 1. RLS on all 13 mirror tables — no policies are created, so every
--    non-owner role is denied outright; the SECURITY DEFINER RPCs (owned by
--    postgres, the table owner) are unaffected and remain the only doors.
alter table container       enable row level security;
alter table block           enable row level security;
alter table variant         enable row level security;
alter table commit_point    enable row level security;
alter table edge            enable row level security;
alter table container_block enable row level security;
alter table reading         enable row level security;
alter table reading_post    enable row level security;
alter table tag             enable row level security;
alter table post_tag        enable row level security;
alter table block_tag       enable row level security;
alter table reference       enable row level security;
alter table setting         enable row level security;

-- 2. Belt to RLS's suspenders: revoke direct table/sequence privileges from
--    the API roles (Supabase grants them broadly by default).
revoke all on all tables in schema public from anon, authenticated;
revoke all on sequence sync_server_seq from anon, authenticated;

-- 3. The RPCs: executable by AUTHENTICATED users only. The bare API key
--    (anon role) can no longer call them — the demotion, enforced.
revoke execute on function sync_push(jsonb) from public, anon;
revoke execute on function sync_pull(bigint, int) from public, anon;
revoke execute on function sync_table_pk(text) from public, anon;
grant execute on function sync_push(jsonb) to authenticated, service_role;
grant execute on function sync_pull(bigint, int) to authenticated, service_role;

-- 4. sync_push: per-user-guarded compare-and-set. CAS semantics, the
--    visibility-horizon machinery (03), and the wire shapes are UNTOUCHED;
--    what is new is the auth gate and the owner_id guards. Guard failures
--    RAISE (aborting the whole call) rather than returning a per-row
--    reject: a reject-with-current invites the client's CAS merge loop,
--    and an ownership violation is never merge-resolvable — it is either
--    a not-yet-backfilled client (SyncSpec §12: refuse until lockstep
--    completes) or a foreign/hostile caller (refuse, and never echo the
--    stored row back).
create or replace function sync_push(batch jsonb) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'setting'];
  -- The owner-carrying tables (AppSpec §6: owner_id on top-level entities).
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference'];
  caller text;
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
  caller := auth.uid()::text;
  if caller is null then
    raise exception 'sync requires an authenticated user';
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

    -- Owner guard, incoming half: a pushed row on an owner-carrying table
    -- must carry the caller's own owner_id (NULL is rejected too — a
    -- pre-backfill client must refuse-and-stall, never write unowned rows
    -- past the flip).
    if tbl = any (owner_tables)
       and (item->'columns'->>'owner_id') is distinct from caller then
      raise exception 'owner_id mismatch on % row % — pushes must carry owner_id = auth.uid()',
        tbl, row_id;
    end if;

    -- Lock + read the current row (CAS is per row, in this transaction).
    execute format('select sync_version, to_jsonb(t) from %I t where %I = $1 for update', tbl, pk)
      into current_version, current_jsonb
      using row_id;

    -- Owner guard, stored half: a stored row owned by someone else is
    -- never overwritten and never echoed back in a reject.
    if tbl = any (owner_tables) and current_jsonb is not null
       and (current_jsonb->>'owner_id') is distinct from caller then
      raise exception 'row % on % belongs to another owner', row_id, tbl;
    end if;

    if current_version is null then
      -- Absent row: only base 0 may insert it.
      if base_version = 0 then
        full_row := (item->'columns') || jsonb_build_object('sync_version', 1);
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
      full_row := (item->'columns') || jsonb_build_object('sync_version', current_version + 1);
      execute format('delete from %I where %I = $1', tbl, pk) using row_id;
      execute format(
        'insert into %I select * from jsonb_populate_record(null::%I, $1) returning server_seq',
        tbl, tbl)
        into granted_seq using full_row;
      results := results || jsonb_build_array(jsonb_build_object(
        'status', 'accepted', 'new_version', current_version + 1, 'server_seq', granted_seq));
    else
      -- Stale base: reject WITH the current row so the client can merge
      -- deterministically and push again (SyncSpec §4). No server merging.
      results := results || jsonb_build_array(jsonb_build_object(
        'status', 'rejected',
        'current', jsonb_build_object(
          'table', tbl,
          'row_id', row_id,
          'sync_version', current_version,
          'server_seq', current_jsonb->'server_seq',
          'columns', current_jsonb - 'sync_version' - 'server_seq' - 'server_written_at')));
    end if;
  end loop;
  return results;
end;
$$;

-- 5. sync_pull: the authenticated changefeed. The A5 visibility horizon and
--    the server-only column subtraction (03) are preserved VERBATIM; the
--    owner-carrying tables additionally serve only the caller's own rows.
--    (Post-backfill no NULL-owner row exists; if one ever appeared it would
--    be invisible here — fail-safe in the non-leaking direction, and the
--    push guard prevents new ones.)
create or replace function sync_pull(since_seq bigint, max_rows int default 500)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'setting'];
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference'];
  caller text;
  tbl text;
  union_sql text := '';
  result jsonb;
begin
  caller := auth.uid()::text;
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- State-based changefeed: each row appears once, in its current state,
  -- at its latest seq (SyncSpec §2 — mirrored tables, not an op log).
  foreach tbl in array allowed loop
    if union_sql <> '' then
      union_sql := union_sql || ' union all ';
    end if;
    union_sql := union_sql || format(
      $q$select %L::text as tbl, t.server_seq, t.sync_version,
           to_jsonb(t) - 'sync_version' - 'server_seq' - 'server_written_at' as cols,
           (to_jsonb(t))->>%L as row_id
         from %I t
         where t.server_seq > %s
           and t.server_written_at <= clock_timestamp() - interval '2 seconds'$q$,
      tbl, sync_table_pk(tbl), tbl, since_seq);
    if tbl = any (owner_tables) then
      union_sql := union_sql || format(' and t.owner_id = %L', caller);
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
