-- Variorum sync RPC functions (SyncSpec §2/§4) — Phase 5, Step 8.
-- Run AFTER 01_mirror_schema.sql. The server's ENTIRE intelligence is here:
-- per-row compare-and-set on push, a seq-ordered changefeed on pull.
-- No merging, no validation, no domain logic — ever (SyncSpec §2).
--
-- Wire shapes (must stay aligned with SupabaseTransport.swift):
--   sync_push(batch jsonb) → jsonb array, index-aligned with the batch:
--     request item : {"table": t, "row_id": id, "base_version": n,
--                     "columns": {col: value, …}}   -- excludes sync_version
--     accepted     : {"status": "accepted", "new_version": n, "server_seq": s}
--     rejected     : {"status": "rejected", "current": {"table": t,
--                     "row_id": id, "sync_version": n, "server_seq": s,
--                     "columns": {…}} | null}
--   sync_pull(since_seq bigint, max_rows int) → jsonb array ordered by seq:
--     item         : {"table": t, "row_id": id, "sync_version": n,
--                     "server_seq": s, "columns": {…}}

create or replace function sync_table_pk(tbl text) returns text
language sql immutable as $$
  select case when tbl = 'setting' then 'key' else 'id' end;
$$;

create or replace function sync_push(batch jsonb) returns jsonb
language plpgsql security definer as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'setting'];
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

    -- Lock + read the current row (CAS is per row, in this transaction).
    execute format('select sync_version, to_jsonb(t) from %I t where %I = $1 for update', tbl, pk)
      into current_version, current_jsonb
      using row_id;

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
          'columns', current_jsonb - 'sync_version' - 'server_seq')));
    end if;
  end loop;
  return results;
end;
$$;

create or replace function sync_pull(since_seq bigint, max_rows int default 500)
returns jsonb
language plpgsql security definer as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'setting'];
  tbl text;
  union_sql text := '';
  result jsonb;
begin
  -- State-based changefeed: each row appears once, in its current state,
  -- at its latest seq (SyncSpec §2 — mirrored tables, not an op log).
  foreach tbl in array allowed loop
    if union_sql <> '' then
      union_sql := union_sql || ' union all ';
    end if;
    union_sql := union_sql || format(
      $q$select %L::text as tbl, t.server_seq, t.sync_version,
           to_jsonb(t) - 'sync_version' - 'server_seq' as cols,
           (to_jsonb(t))->>%L as row_id
         from %I t where t.server_seq > %s$q$,
      tbl, sync_table_pk(tbl), tbl, since_seq);
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
