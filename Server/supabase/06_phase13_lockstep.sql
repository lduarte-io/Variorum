-- Variorum sync mirror — the Phase 13 lockstep event (Step A1; SyncSpec §12).
-- Run AFTER 01 + 02 + 03 + 04 + 05, via the author's PAT (the 9c precedent;
-- the deploy is PRE-AUTHORIZED — sitting-7 ruling R53: "just do the schema
-- deploy") or the SQL-editor paste. ONE deploy covers the event's FOUR
-- additive client changes (migrations v1_8 block_comment, v1_9
-- block.presentation, v1_10 reading_section + reading_post.section_id,
-- v1_11 reading.word_target) on the reworked RPC allowlists.
--
-- THE CHOREOGRAPHY (SyncSpec §12; R53's shape — the phone app is REMOVED,
-- so the lockstep is MIRROR → MAC only):
--   (1) this file runs on the mirror FIRST. The moment its final statement
--       bumps the marker to 3, the still-installed pre-13 Mac build VISIBLY
--       refuses to sync (outbox intact, cursor unmoved) until this phase's
--       build replaces it — the accepted R53 consequence; the author is not
--       using the app during the phase.
--   (2) THEN the Mac client updates (migrations v1_8–v1_11 run on next
--       launch of the phase's build).
--   (3) only then may any client write new-schema rows. The phone reinstalls
--       onto current schema whenever the author next wants it (Phase 15's
--       orbit) — no un-updated client exists today.
--
-- THE DUMBNESS IS STILL LOAD-BEARING (SyncSpec §2): new mirror tables carry
-- PRIMARY KEY only — no other uniqueness, no FKs, no checks. block_comment
-- and reading_section deliberately have NO live-unique indexes client-side
-- either (no natural keys), so no new repair classes exist.
--
-- RLS POSTURE (the 04/05 pattern, verified not assumed): each new table
-- repeats the per-table pattern — RLS enabled with no policies, direct
-- privileges revoked, the SECURITY DEFINER RPCs the only doors.
-- block_comment carries owner_id and joins the owner_tables guard arrays;
-- reading_section is a child table (no owner column — Phase 14's
-- parent-join isolation debt, same as container_block et al.).

-- ---------------------------------------------------------------------------
-- 1. block_comment (client migration v1_8) — working notes on a block.
--    Metadata CAS text (S5 stays scoped to variant.working_text); no
--    uniqueness, no repair class; tombstoned; deleted comments resurrect
--    client-side.
-- ---------------------------------------------------------------------------

create table block_comment (
  id                text primary key,
  owner_id          text,
  block_id          text,
  text              text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp()
);

create trigger stamp_seq_block_comment before insert or update on block_comment
  for each row execute function stamp_server_seq();
create index idx_seq_block_comment on block_comment (server_seq);

alter table block_comment enable row level security;
revoke all on block_comment from anon, authenticated;


-- ---------------------------------------------------------------------------
-- 2. block.presentation (client migration v1_9) — the callout frame
--    (sitting rulings R16/R27): block-level presentation metadata,
--    identity-level like block.name. Additive nullable column; plain
--    metadata CAS, no uniqueness, no repair.
-- ---------------------------------------------------------------------------

alter table block add column if not exists presentation text;

-- ---------------------------------------------------------------------------
-- 3. reading_section (client migration v1_10) — real chapters (R28: "a
--    reading section table is fine; we don't need nesting readings").
--    Ordered metadata rows; position races converge by CAS like every
--    fractional index. reading_post gains section_id — a dangling pointer
--    reads as unsectioned client-side (the chosen-variant fallback class).
-- ---------------------------------------------------------------------------

create table reading_section (
  id                text primary key,
  reading_id        text,
  name              text,
  position          text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp()
);

create trigger stamp_seq_reading_section before insert or update on reading_section
  for each row execute function stamp_server_seq();
create index idx_seq_reading_section on reading_section (server_seq);

alter table reading_section enable row level security;
revoke all on reading_section from anon, authenticated;

alter table reading_post add column if not exists section_id text;

-- ---------------------------------------------------------------------------
-- 4. reading.word_target (client migration v1_11) — bounded-length
--    notebooks in WORDS (§14 item 10; the max_posts sibling). A display
--    target, never an add-time refusal — enforcement would need word
--    counts at membership time, which edits immediately invalidate.
-- ---------------------------------------------------------------------------

alter table reading add column if not exists word_target bigint;

-- ---------------------------------------------------------------------------
-- 5. The RPC rework: 05's bodies VERBATIM (auth gates, owner guards, the A5
--    visibility horizon, CAS semantics all preserved) with the allowlists
--    extended to the eighteen tables and owner_tables gaining block_comment
--    (it carries owner_id). CREATE OR REPLACE preserves the function ACLs;
--    the grants are re-affirmed below anyway (belt).
-- ---------------------------------------------------------------------------

create or replace function sync_push(batch jsonb) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting'];
  -- The owner-carrying tables (AppSpec §6: owner_id on top-level entities).
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment'];
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
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting'];
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment'];
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
-- 6. The lockstep marker (SyncSpec §12): sync_meta and sync_schema_version()
--    already exist (05); nothing here recreates them. THE MARKER UPDATE IS
--    DELIBERATELY THE LAST STATEMENT OF THIS FILE: a partially-executed
--    deploy never advertises the new version before the tables exist.
-- ---------------------------------------------------------------------------

-- LAST STATEMENT (see above): the mirror now speaks lockstep version 3.
-- Must equal SyncSchema.lockstepVersion in the client — the in-repo DDL
-- pin fails the build if they drift.
insert into sync_meta (key, value) values ('lockstep_version', '3')
  on conflict (key) do update set value = excluded.value;
