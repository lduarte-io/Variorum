-- Variorum sync mirror — changefeed visibility-horizon fix (Phase 8, A5;
-- SyncSpec §5 "changefeed visibility skew", found 2026-07-07 via the
-- Fragments post-mortem). Run AFTER 01_mirror_schema.sql + 02_sync_rpc.sql.
--
-- THE MECHANISM THIS CLOSES: `server_seq` is assigned at WRITE time (the
-- stamping trigger, inside the push transaction) but the row becomes visible
-- at COMMIT time. Two concurrent pushes can commit out of seq order, and a
-- pull racing them can read past the gap and advance its cursor beyond a
-- not-yet-visible lower seq — skipping that row FOREVER. Client-side
-- atomicity cannot touch this; the fix is server-side: the changefeed never
-- serves rows younger than a ~2-second visibility horizon (pushes are short
-- transactions, so by the time a seq range becomes servable every
-- transaction that wrote into it has committed — the fix proven in the
-- author's Fragments app).
--
-- Deployment follows SyncSpec §12 (migration lockstep): (1) this file on the
-- mirror; (2) no client schema change is needed — `server_written_at` is
-- server-only machinery, subtracted from every payload exactly like
-- `server_seq` (a payload carrying it would hit the client's unknown-column
-- refusal); clients simply see a slightly delayed head.

-- 1. Every mirror gains the server-stamped write time. Explicit per-table
--    (not a DO loop) so the in-repo DDL walk (SerializerCompletenessTests)
--    can parse it.
alter table container       add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table block           add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table variant         add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table commit_point    add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table edge            add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table container_block add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table reading         add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table reading_post    add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table tag             add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table post_tag        add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table block_tag       add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table reference       add column if not exists server_written_at timestamptz not null default clock_timestamp();
alter table setting         add column if not exists server_written_at timestamptz not null default clock_timestamp();

-- 2. The stamping trigger stamps BOTH server columns. This matters beyond
--    freshness: sync_push replaces rows via jsonb_populate_record, which
--    yields explicit NULL for fields the payload lacks — without the trigger
--    assignment the NOT NULL constraint would reject every push.
create or replace function stamp_server_seq() returns trigger
language plpgsql as $$
begin
  new.server_seq := nextval('sync_server_seq');
  new.server_written_at := clock_timestamp();
  return new;
end;
$$;

-- 3. The changefeed serves only rows older than the visibility horizon, and
--    subtracts the new server-only column from payloads (like server_seq).
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
  -- The visibility horizon (A5) is the `interval '2 seconds'` filter in the
  -- per-table branches below: rows written within that window are never
  -- served, so a pull can never advance past a seq that might still be
  -- hidden inside an uncommitted transaction. Pushes are single short
  -- transactions; 2 seconds is the Fragments-proven margin.
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
           to_jsonb(t) - 'sync_version' - 'server_seq' - 'server_written_at' as cols,
           (to_jsonb(t))->>%L as row_id
         from %I t
         where t.server_seq > %s
           and t.server_written_at <= clock_timestamp() - interval '2 seconds'$q$,
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

-- 4. sync_push: the reject payload subtracts the new server-only column too
--    (otherwise a reject's `current` row would hit the client's
--    unknown-column refusal). Only the reject branch changes; CAS semantics
--    are untouched.
create or replace function sync_push(batch jsonb) returns jsonb
language plpgsql security definer
set search_path = public
as $$
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
          'columns', current_jsonb - 'sync_version' - 'server_seq' - 'server_written_at')));
    end if;
  end loop;
  return results;
end;
$$;
