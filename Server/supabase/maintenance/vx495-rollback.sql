-- ============================================================================
-- VX-495 ROLLBACK — the production mirror's `sync_pull` restored to its exact
-- pre-VX-495 state (marker 14; a MAINTENANCE artifact — NO marker move)
-- ============================================================================
-- WHEN IT RUNS (R-500-6 (2); the record `notes/plans/fixes/vx-500-sync-followups.md`,
-- THE DEPLOY §4): at her word only, if the live round after the keyset deploy
-- (`maintenance/vx495-pull-keyset.sql`) REFUSES. The keyset artifact's SQL
-- has never executed on a Postgres before that window (its DDL pins are
-- string pins; her probes were bare SELECTs of the SHAPE, not the PL/pgSQL
-- body), and the 13j 42702 class is caught only live — so the road back is
-- written and pinned BEFORE the deploy. One transaction, idempotent, no
-- client involvement: nothing on the wire changed in either direction.
--
-- WHAT IT RESTORES — the FINAL deployed state of `sync_pull` TODAY, which is
-- three artifacts' work laid in deploy order:
--   13_phase13i_wings.sql §3a      the body (12's with wing + shelf in both
--                                   arrays) under the header
--                                   `set search_path = public`;
--   12_phase13y_tenant_seq.sql      the owner `variorum_definer` (14c's
--   (kept across 13's replace)      non-bypass definer) and the grants
--                                   (authenticated + service_role; public and
--                                   anon revoked);
--   vx213-pg-temp-search-path.sql   the belt: `set search_path = public, pg_temp`.
-- So, below: 13's §3a `create or replace` of the pull BYTE-FOR-BYTE — copied
-- from 13, never retyped; `AuthRLSDDLTests` pins the byte-equality against
-- 13's own last body — then the belt's list, the owner and the grants
-- re-asserted exactly as the keyset artifact re-asserts them. The alter on
-- search_path is load-bearing, not decoration: a `create or replace` keeps a
-- function's owner and grants but RESETS its SET clause (the belt's own
-- finding), so 13's bare `public` header would otherwise be what lands.
--
-- `sync_pull_remaining` IS DROPPED: it is the keyset artifact's creature
-- (VX-496's catch-up count), unused by every 0.10.7 client (the client half
-- ships with the PR after the freeze and tolerates the function's absence —
-- a 404 reads as "no total", never a failed round), and a rolled-back mirror
-- should hold exactly the function set it held before. Consequence for the
-- verifier: THE BRANCH'S grant sweep (`14c-post-deploy-grant-sweep.sql`)
-- carries the count's expectation row, so after a rollback it reads
-- `sync_pull_remaining` as MISSING (fail-class wording) until the keyset
-- artifact re-runs — expected, not a door; main's sweep (no such row) reads
-- the rolled-back mirror clean.
--
-- RE-RUNNING THE KEYSET ARTIFACT AFTERWARDS IS LEGAL: both artifacts are
-- idempotent and each lands its WHOLE state (body, owner, search_path,
-- grants), so the mirror can go forward → back → forward at her word with no
-- half-state between. Neither artifact touches `sync_meta`: the marker stays
-- 14 throughout, and every client keeps speaking it.
--
-- GUARD: refuses below marker 14 — the keyset artifact's own shape, its own
-- exception name (13's body deployed at marker ≥ 10; today's mirror is 14).
-- Run on a mirror that never received the keyset artifact it is harmless:
-- 13's body replaces 13's body, the drop finds nothing, the alters and
-- grants land the state already in force.
-- DEPLOY: at her explicit word only (the record's THE DEPLOY section).
-- ============================================================================

begin;

do $guard$
declare
  deployed_marker int;
begin
  select value::int into deployed_marker from sync_meta where key = 'lockstep_version';
  if deployed_marker is null or deployed_marker < 14 then
    raise exception 'VARIORUM_VX495_ROLLBACK_NEEDS_14: this artifact rides the marker-14 set — apply 17_phase_vx307_vault.sql first (deployed marker: %)', coalesce(deployed_marker::text, 'none');
  end if;
end;
$guard$;

-- ---------------------------------------------------------------------------
-- 1. sync_pull — 13_phase13i_wings.sql §3a, lines 184–291 of that file,
--    BYTE-FOR-BYTE (copied, not retyped; the AuthRLSDDLTests pin compares the
--    whole `create or replace … $$;` text, comments included, against 13's).
--    The one-page `select * from (<union>) raw order by raw.server_seq
--    limit %s` is the pre-VX-495 shape: every eligible row to_jsonb'd and
--    sorted per call — correct, and the cost VX-495 removes.
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- 2. The count function dropped — the keyset artifact's creature; the
--    pre-VX-495 function set held exactly (the header says why, and what the
--    branch's sweep will read until the keyset artifact re-runs).
-- ---------------------------------------------------------------------------

drop function if exists sync_pull_remaining(bigint, text, text, text);

-- ---------------------------------------------------------------------------
-- 3. Ownership, search_path, grants — re-asserted for `sync_pull` (the keyset
--    artifact's letter: the `create or replace` above reset the SET clause to
--    13's bare `public`, so the belt's `public, pg_temp` is re-landed HERE;
--    the owner and the grants are idempotent and byte-identical to 12's and
--    to the keyset artifact's for this function).
-- ---------------------------------------------------------------------------

alter function sync_pull(bigint, text, text, text, int, text) owner to variorum_definer;
alter function sync_pull(bigint, text, text, text, int, text) set search_path = public, pg_temp;

revoke execute on function sync_pull(bigint, text, text, text, int, text) from public, anon;
grant execute on function sync_pull(bigint, text, text, text, int, text) to authenticated, service_role;

commit;

-- VERIFY (read-only, after the rollback):
--   select pg_get_functiondef('sync_pull(bigint,text,text,text,int,text)'::regprocedure);
--     — the body carries 'order by raw.server_seq limit %s) u' and NO
--     'with picked as' (13's one-page shape is back);
--   select proname, proconfig from pg_proc where proname in ('sync_pull', 'sync_pull_remaining');
--     — ONE row, sync_pull, proconfig = {search_path=public, pg_temp};
--   then the grant sweep from MAIN (`maintenance/14c-post-deploy-grant-sweep.sql`
--   — the branch's copy expects the dropped count's row; the header above).
