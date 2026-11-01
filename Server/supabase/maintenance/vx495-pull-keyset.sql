-- ============================================================================
-- VX-495 / VX-496 — the changefeed's page costs the page, and the count that
-- sizes a catch-up (marker 14; a MAINTENANCE artifact — NO marker move)
-- ============================================================================
-- THE FINDING (VX-494's D1 server check, 2026-10-23, read-only on production):
-- `sync_pull` built a `union all` over every synced table of EVERY row past
-- the cursor — `to_jsonb(t)` computed per eligible row — then sorted the lot
-- and took one page: Seq Scan → to_jsonb of 58,347 rows → Sort → Limit;
-- 2,934 ms at LIMIT 200 and 1,477 ms at LIMIT 2,000 on her ~108k-row
-- tenant, against an 8 s statement timeout for `authenticated`. Each call's
-- cost grows with the rows STILL AHEAD of the cursor, so a from-zero
-- catch-up pays ≈ N²/page in all, and a tenant a few times hers would meet
-- the timeout on its FIRST window whatever the page size (VX-495).
--
-- THE SHAPE — SHAPE B, the bound-based fetch (VX-500 U1a; the record
-- `notes/plans/fixes/vx-500-sync-followups.md`, D-495 and its EVIDENCE):
-- the SAME signature, the SAME wire shape (a JSON array of
-- {table,row_id,sync_version,server_seq,columns} ordered by server_seq), the
-- SAME gates (the challenge-verified key gate, the entitlement gate), the
-- SAME device-cursor upsert, the SAME A5 horizon derived from the one serving
-- function, the SAME owner scoping and server-only column subtraction — and
-- the page assembled in TWO phases inside one statement:
--   THE PICK — per table, the first `max_rows` seqs past the cursor read
--     off `idx_owner_seq_<table> (owner_id, server_seq)` in index order,
--     stopping after `max_rows` qualifying rows — SEQS ONLY, never a row's
--     id or JSON; the per-table picks `union all`, then ONE `order by
--     server_seq limit max_rows` over ≤ 21 × max_rows bigints is the CTE
--     `picked`. Any row in the global first page is in its own table's
--     first page, so the pick's union always contains the page.
--   THE BOUND — `bound` is `max(server_seq)` over `picked`: the page's LAST
--     seq (NULL when nothing is past the cursor — then no branch matches
--     and the page is `[]`, as before).
--   THE FETCH — the two existing branches VERBATIM (owner-carrying keeps
--     owner_id; mirror-only subtracts it; the same owner filter; the same
--     derived horizon filter) with ONE added predicate each,
--     `t.server_seq <= (select seq from bound)`, so every branch is one
--     index RANGE scan off `idx_owner_seq_<table>` and `to_jsonb(t)` runs
--     exactly for the page's rows, sequential within each index. The outer
--     aggregate orders by server_seq exactly as before.
-- WHY THE BOUND IS EXACT: a tenant's `server_seq`s are UNIQUE across all its
-- tables (`next_tenant_seq`, the row-locked per-owner counter, stamps every
-- write — 13y; the pre-13y global sequence was unique too), so "the page's
-- rows" ≡ "every allowed table's rows with since < seq ≤ bound" — no row of
-- any table can sit inside that range unpicked: were a row with seq s ≤
-- bound outside its table's first `max_rows`, that table alone would hold
-- `max_rows` rows below s, and the global `max_rows`-th seq would be below
-- s too. Each row appears once (one PK per table) at its latest seq; the
-- output is byte-identical to 13's for every input, so the client and the
-- fake server (`FakeSyncServer.pull`, already an in-memory sort) change
-- nothing and every convergence suite stays the evidence. The page may
-- hold fewer than `max_rows` rows only at the head — then `bound` is the
-- head and the fetch returns everything left, as today. Nothing on the wire
-- moves — hence a maintenance artifact, not a lockstep event (SyncSpec §12
-- names the procedure for a server body: the mirror first; clients need
-- nothing).
-- THE HORIZON ACROSS THE TWO PHASES: `clock_timestamp()` is evaluated per
-- branch, so the fetch reads it microseconds after the pick. Harmless, and
-- said so rather than hidden: visibility only GROWS with the clock, so a
-- picked row can never go unfetched; a row fetched but unpicked would need
-- a seq ≤ bound while still inside the horizon at the pick — impossible
-- under the per-tenant counter (its lock serializes a tenant's commits, so
-- write time is monotone in seq and the horizon excludes a SUFFIX of the
-- seq order, every excluded seq above `bound`) — and were it ever to ride,
-- the client reads a window of `max_rows` or more as full and the row
-- lands at its proper place in seq order. The pinned filter text
-- (`t.server_written_at <= clock_timestamp() - %L::interval`, every branch)
-- therefore stays byte-identical to 13's.
-- MEASURED (her `EXPLAIN (ANALYZE, BUFFERS)` probes on production, her
-- tenant, since = 0, page 2,000, 2026-11-01 — the record's D-495 EVIDENCE):
-- 13's body 3,398 ms (Parallel Append of Seq Scans, ~122k rows to_jsonb'd,
-- 11,538 buffers) · the first draft's pick-by-id + per-row PK probes
-- 1,138 ms (the pick 37 ms; ~0.5 ms a probe × 2,000) · SHAPE B 230 ms
-- (the pick a Merge Append of per-table index scans under their limits; the
-- fetch an index RANGE scan per table; 969 buffers).
--
-- AND THE COUNT (VX-496, the sync row's progress line — D-496): one new READ
-- RPC, `sync_pull_remaining(since_seq, active_key_id, key_proof, challenge)`,
-- the rows past the cursor under the same horizon filter, summed over the
-- same allowlist off the same indexes — `sync_horizon`'s posture exactly
-- (challenge-gated, entitlement-gated, authenticated only). The client calls
-- it ONCE per round and only after a first window came back full, treats
-- any failure — a 404 before this deploys included — as "no total", and
-- never fails a round on it.
--
-- GUARD: refuses below marker 14 (the body it replaces is 13's, deployed at
-- marker ≥ 10; today's mirror is 14). Idempotent — a re-run lands the same
-- state. Deploys AFTER `vx213-pg-temp-search-path.sql` (the belt): a
-- `create or replace` resets a function's SET clause, so this artifact
-- re-asserts `search_path = public, pg_temp` on both functions itself, and
-- re-asserts the non-bypass owner and the grants (the 14c gate's letter).
-- DEPLOY: at her explicit word only (the record's THE DEPLOY section).
-- ============================================================================

begin;

do $guard$
declare
  deployed_marker int;
begin
  select value::int into deployed_marker from sync_meta where key = 'lockstep_version';
  if deployed_marker is null or deployed_marker < 14 then
    raise exception 'VARIORUM_VX495_NEEDS_14: this artifact rides the marker-14 set — apply 17_phase_vx307_vault.sql first (deployed marker: %)', coalesce(deployed_marker::text, 'none');
  end if;
end;
$guard$;

-- ---------------------------------------------------------------------------
-- 1. sync_pull — 13's body with the page assembled by THE PICK, THE BOUND
--    and THE FETCH (SHAPE B).
-- ---------------------------------------------------------------------------

create or replace function sync_pull(since_seq bigint, active_key_id text, key_proof text, challenge text, max_rows int default 500, for_device text default null)
returns jsonb
language plpgsql security definer
set search_path = public, pg_temp
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
  -- one serving function; every filter below derives from this local —
  -- no inline interval literal survives in this body, so the served
  -- value and the enforced value cannot drift.
  horizon interval := make_interval(secs => sync_visibility_horizon_ms() / 1000.0);
  tbl text;
  pick_sql text := '';
  fetch_sql text := '';
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
  --
  -- VX-495 — THE PICK: per table, the first `max_rows` seqs past the
  -- cursor, in index order off (owner_id, server_seq), stopping after
  -- `max_rows` qualifying rows. Seqs only — never a row's id or JSON.
  foreach tbl in array allowed loop
    if pick_sql <> '' then
      pick_sql := pick_sql || ' union all ';
    end if;
    pick_sql := pick_sql || format(
      $q$(select t.server_seq
          from %I t
          where t.owner_id = %L
            and t.server_seq > %s
            and t.server_written_at <= clock_timestamp() - %L::interval
          order by t.server_seq
          limit %s)$q$,
      tbl, caller, since_seq, horizon, max_rows);
  end loop;

  -- VX-495 — THE FETCH: 13's two branches verbatim, each bounded to the
  -- page's last seq (`bound`, below) — one index range scan per table, so
  -- `to_jsonb(t)` runs exactly for the page's rows.
  foreach tbl in array allowed loop
    if fetch_sql <> '' then
      fetch_sql := fetch_sql || ' union all ';
    end if;
    if tbl = any (owner_tables) then
      -- Client-carried owner: the payload keeps owner_id.
      fetch_sql := fetch_sql || format(
        $q$select %L::text as tbl, t.server_seq, t.sync_version,
             to_jsonb(t) - 'sync_version' - 'server_seq' - 'server_written_at' as cols,
             (to_jsonb(t))->>%L as row_id
           from %I t
           where t.owner_id = %L
             and t.server_seq > %s
             and t.server_written_at <= clock_timestamp() - %L::interval
             and t.server_seq <= (select seq from bound)$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq, horizon);
    else
      -- Mirror-only owner: subtract the stamped owner_id — the client
      -- has no home for it (the unknown-column refusal would fire).
      fetch_sql := fetch_sql || format(
        $q$select %L::text as tbl, t.server_seq, t.sync_version,
             to_jsonb(t) - 'sync_version' - 'server_seq' - 'server_written_at' - 'owner_id' as cols,
             (to_jsonb(t))->>%L as row_id
           from %I t
           where t.owner_id = %L
             and t.server_seq > %s
             and t.server_written_at <= clock_timestamp() - %L::interval
             and t.server_seq <= (select seq from bound)$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq, horizon);
    end if;
  end loop;

  -- The page: the pick's global first `max_rows` seqs, the bound as their
  -- maximum (one row, read by every fetch branch), then the fetch of
  -- exactly the rows up to it, aggregated in seq order as before.
  execute format(
    $q$with picked as (
         select raw.server_seq
         from (%s) raw
         order by raw.server_seq
         limit %s),
       bound as (select max(server_seq) as seq from picked)
       select coalesce(jsonb_agg(jsonb_build_object(
         'table', u.tbl, 'row_id', u.row_id,
         'sync_version', u.sync_version, 'server_seq', u.server_seq,
         'columns', u.cols) order by u.server_seq), '[]'::jsonb)
       from (%s) u$q$,
    pick_sql, max_rows, fetch_sql)
    into result;
  return result;
end;
$$;

-- ---------------------------------------------------------------------------
-- 2. sync_pull_remaining — the rows past the cursor (VX-496's total), a
--    READ under `sync_horizon`'s exact posture.
-- ---------------------------------------------------------------------------

create or replace function sync_pull_remaining(since_seq bigint, active_key_id text, key_proof text, challenge text)
returns bigint
language plpgsql security definer
set search_path = public, pg_temp
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'wing', 'shelf', 'reading', 'reading_section',
    'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  caller uuid;
  -- The same derived A5 horizon as sync_pull's — the count sees exactly
  -- the rows the feed will serve.
  horizon interval := make_interval(secs => sync_visibility_horizon_ms() / 1000.0);
  tbl text;
  count_sql text := '';
  result bigint;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE GATE and THE ENTITLEMENT GATE — a read under the pull's own gates.
  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_pull_remaining');
  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  foreach tbl in array allowed loop
    if count_sql <> '' then
      count_sql := count_sql || ' + ';
    end if;
    count_sql := count_sql || format(
      $q$(select count(*) from %I t
          where t.owner_id = %L
            and t.server_seq > %s
            and t.server_written_at <= clock_timestamp() - %L::interval)$q$,
      tbl, caller, since_seq, horizon);
  end loop;

  execute 'select ' || count_sql into result;
  return coalesce(result, 0);
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. Ownership, grants, search_path — re-asserted (a `create or replace`
--    keeps the owner but resets the SET clause; the grants are idempotent;
--    the 14c gate's non-bypass definer owner on every data function; the
--    13j `sync_horizon` posture on the count — authenticated only).
-- ---------------------------------------------------------------------------

alter function sync_pull(bigint, text, text, text, int, text) owner to variorum_definer;
alter function sync_pull_remaining(bigint, text, text, text) owner to variorum_definer;

alter function sync_pull(bigint, text, text, text, int, text)   set search_path = public, pg_temp;
alter function sync_pull_remaining(bigint, text, text, text)   set search_path = public, pg_temp;

revoke execute on function sync_pull(bigint, text, text, text, int, text) from public, anon;
grant execute on function sync_pull(bigint, text, text, text, int, text) to authenticated, service_role;

revoke execute on function sync_pull_remaining(bigint, text, text, text) from public, anon, service_role;
grant execute on function sync_pull_remaining(bigint, text, text, text) to authenticated;

commit;

-- VERIFY (read-only, after the deploy):
--   select pg_get_functiondef('sync_pull(bigint,text,text,text,int,text)'::regprocedure);
--     — the body carries 'with picked as', 'bound as (select max(server_seq)'
--     and 't.server_seq <= (select seq from bound)'; and 'sync_pull_remaining'
--     exists:
--   select proname, proconfig from pg_proc where proname in ('sync_pull', 'sync_pull_remaining');
--     — each proconfig = {search_path=public, pg_temp};
--   then `maintenance/14c-post-deploy-grant-sweep.sql` — every row OK, the
--   new function's row included.
