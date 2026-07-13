-- Variorum sync mirror — the Phase 11 lockstep event (Step A1; SyncSpec §12).
-- Run AFTER 01 + 02 + 03 + 04, in the SQL editor or via the author's PAT
-- (the 9c precedent) — NEVER headless. ONE deploy covers the event's FOUR
-- additive client changes (migrations v1_5 canvas_layout, v1_6 block.name,
-- v1_7 lens + lens_choice) plus the §12 version-check mechanism ("ships
-- with the first post-sync migration that needs it" — this one).
--
-- THE CHOREOGRAPHY (SyncSpec §12, to the letter):
--   (1) this file runs on the mirror FIRST. It is SAFE for still-deployed
--       old clients: the new tables serve zero rows until a new client
--       writes them; the reworked RPCs behave identically on the old
--       tables; old clients carry no schema marker check and keep syncing.
--   (2) THEN every client updates (both devices run migrations v1_5–v1_7).
--       A new client against an un-migrated mirror REFUSES to sync (the
--       schema marker check — visible refusal, outbox intact, cursor
--       unmoved); stalling is free, guessing is forbidden.
--   (3) only then may any client write new-schema rows.
--
-- THE DUMBNESS IS STILL LOAD-BEARING (SyncSpec §2): new mirror tables carry
-- PRIMARY KEY only — no other uniqueness, no FKs, no checks. The client's
-- live-unique indexes get deterministic apply-time repairs, which REQUIRE
-- the server to accept both sides of a race.
--
-- RLS POSTURE (verified against the deployed 04_auth_rls.sql, not assumed):
-- each new table repeats 04's per-table pattern — RLS enabled with no
-- policies, direct privileges revoked, the SECURITY DEFINER RPCs the only
-- doors. canvas_layout and lens carry owner_id and join 04's owner_tables
-- guard arrays (incoming pushes must carry owner_id = auth.uid(); stored
-- foreign/NULL-owner rows are never overwritten or echoed; pulls serve only
-- the caller's rows). lens_choice is a child table (no owner column —
-- Phase 14's parent-join isolation debt, same as container_block et al.).

-- ---------------------------------------------------------------------------
-- 1. canvas_layout (client migration v1_5) — canvas card positions.
--    Metadata-CAS positions; live-unique (container_id, block_id) repairs
--    client-side as a pure duplicate (keep smaller id).
-- ---------------------------------------------------------------------------

create table canvas_layout (
  id                text primary key,
  owner_id          text,
  container_id      text,
  block_id          text,
  x                 double precision,
  y                 double precision,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp()
);

create trigger stamp_seq_canvas_layout before insert or update on canvas_layout
  for each row execute function stamp_server_seq();
create index idx_seq_canvas_layout on canvas_layout (server_seq);

alter table canvas_layout enable row level security;
revoke all on canvas_layout from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 2. block.name (client migration v1_6) — the optional per-block name.
--    Additive nullable column; plain metadata CAS, no uniqueness, no repair.
-- ---------------------------------------------------------------------------

alter table block add column if not exists name text;

-- ---------------------------------------------------------------------------
-- 3. lens + lens_choice (client migration v1_7) — saved lenses: durable
--    named selection profiles, SPARSE overrides over chosen. Never
--    rendering truth (the client's ✓/adopt ops are the only lens→chosen
--    doors). lens carries owner_id (joins the owner guards below);
--    lens_choice is a child table. Live-unique (lens_id, block_id) repairs
--    client-side as a pure duplicate.
-- ---------------------------------------------------------------------------

create table lens (
  id                text primary key,
  owner_id          text,
  container_id      text,
  name              text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp()
);

create trigger stamp_seq_lens before insert or update on lens
  for each row execute function stamp_server_seq();
create index idx_seq_lens on lens (server_seq);

alter table lens enable row level security;
revoke all on lens from anon, authenticated;

create table lens_choice (
  id                text primary key,
  lens_id           text,
  block_id          text,
  variant_id        text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp()
);

create trigger stamp_seq_lens_choice before insert or update on lens_choice
  for each row execute function stamp_server_seq();
create index idx_seq_lens_choice on lens_choice (server_seq);

alter table lens_choice enable row level security;
revoke all on lens_choice from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 4. The RPC rework: 04's bodies VERBATIM (auth gates, owner guards, the A5
--    visibility horizon, CAS semantics all preserved) with the allowlists
--    extended to the sixteen tables and owner_tables gaining canvas_layout
--    and lens (both carry owner_id). CREATE OR REPLACE preserves the
--    function ACLs 04 set; the grants are re-affirmed below anyway (belt).
-- ---------------------------------------------------------------------------

create or replace function sync_push(batch jsonb) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'setting'];
  -- The owner-carrying tables (AppSpec §6: owner_id on top-level entities).
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens'];
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
    if tbl = any (owner_tables) and current_jsonb is not null then
      if (current_jsonb->>'owner_id') is null then
        raise exception 'row % on % is not yet backfilled — complete the owner adoption before the flip',
          row_id, tbl;
      elsif (current_jsonb->>'owner_id') is distinct from caller then
        raise exception 'row % on % belongs to another owner', row_id, tbl;
      end if;
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

create or replace function sync_pull(since_seq bigint, max_rows int default 500)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'setting'];
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens'];
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

-- Re-affirm the demotion posture on the replaced bodies (CREATE OR REPLACE
-- preserves ACLs; these lines are the belt).
revoke execute on function sync_push(jsonb) from public, anon;
revoke execute on function sync_pull(bigint, int) from public, anon;
grant execute on function sync_push(jsonb) to authenticated, service_role;
grant execute on function sync_pull(bigint, int) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. The SyncSpec §12 version-check mechanism (ships NOW — the spec's
--    letter: with the first post-sync migration that needs it). sync_meta
--    is SERVER-ONLY machinery (never a mirror of a client table, never in
--    a payload); the marker is read by every client at the start of every
--    round half and any mismatch refuses the round. THE MARKER INSERT IS
--    DELIBERATELY THE LAST STATEMENT OF THIS FILE: a partially-executed
--    deploy never advertises the new version before the tables exist.
-- ---------------------------------------------------------------------------

create table if not exists sync_meta (
  key   text primary key,
  value text not null
);

alter table sync_meta enable row level security;
revoke all on sync_meta from anon, authenticated;

-- A missing marker row (or the whole function 404ing on a pre-05 mirror)
-- reads as version 1 — the 9c-era deployment, defined retroactively.
create or replace function sync_schema_version() returns bigint
language sql stable security definer
set search_path = public
as $$
  select coalesce(
    (select value::bigint from sync_meta where key = 'lockstep_version'), 1);
$$;

revoke execute on function sync_schema_version() from public, anon;
grant execute on function sync_schema_version() to authenticated, service_role;

-- LAST STATEMENT (see above): the mirror now speaks lockstep version 2.
-- Must equal SyncSchema.lockstepVersion in the client — the in-repo DDL
-- pin fails the build if they drift.
insert into sync_meta (key, value) values ('lockstep_version', '2')
  on conflict (key) do update set value = excluded.value;
