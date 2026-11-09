-- ============================================================================
-- VX-919 — the device_cursor cap belt: at most 64 device rows per account,
-- the oldest `seen_at` evicted first (a MAINTENANCE artifact — NO marker move)
-- ============================================================================
-- DEPLOY: HELD FOR HER WINDOW. A server act runs only at her word. This file
-- was AUTHORED and reviewed in the VX-849 run (batch 6) and NEVER EXECUTED
-- there — not on production, not on the mirror, not on any local database.
-- Its review is the run's ladder; its deploy is hers (the record
-- `notes/plans/fixes/vx-849-typed-over-rescue.md`, "### BATCH 6 RECORD").
--
-- THE CORNER (VX-912's B0 security re-verify,
-- `notes/plans/fixes/vx-912-b0-security-verify.md`, "The one recorded
-- corner"): `sync_pull`'s device-cursor upsert mints one `device_cursor` row
-- per distinct `for_device` value with NO per-account cap — an authenticated
-- caller can grow rows in its own partition without touching the write
-- quota. Self-scoped (no cross-tenant reach), content-free, cleared by
-- `account_purge` — acceptable as it stands; this is the optional belt the
-- re-verify offered, on `sync_challenge`'s pattern (12 §5e: cap N, oldest
-- out, enforced at the mint).
--
-- THE SHAPE — an AFTER INSERT row trigger on `device_cursor`, NOT a rewrite of
-- `sync_pull`: the mint IS the upsert's INSERT path, and a row trigger there is
-- exactly the mint. `sync_pull` (vx495's SHAPE B — the deployed body) stays
-- byte-untouched: nothing on the wire, no RPC body copied, no PL/pgSQL name
-- resolution in a hot RPC to get wrong (the 13j 42702 class is caught only
-- live), and the paired rollback is exact (`vx919-rollback.sql`). Postgres
-- fires a row-level AFTER INSERT trigger only for a row actually INSERTED: an
-- existing device's upsert takes ON CONFLICT DO UPDATE (the UPDATE path) and
-- pays nothing. Correctness does not lean on that — a count at or under the
-- cap deletes nothing.
--
-- THE CAP: count the owner's rows; above 64, delete the (count − 64) oldest by
-- `seen_at`, ties by `device_id` (a determinism tiebreak `sync_challenge`
-- lacks), NEVER the row just inserted (the caller's own cursor is never undone
-- by its own mint). Every row of the owner counts — the table has no
-- tombstone, and a device unseen for 60 days is already outside the horizon —
-- so stale rows leave first by the order and the table is bounded at
-- 64 × accounts. CONCURRENCY, stated: two first pulls in flight together each
-- count without the other's uncommitted row, so an account can briefly hold
-- 64 + k rows; its next new device trims it back (the delete takes count − 64,
-- not one) — `sync_challenge`'s own property. There is NO deploy-time trim: an
-- account already over the cap trims at its next new device; the VERIFY reads
-- below report any such account first (a blanket DML over production at
-- deploy is a deliberate act of hers, never a file's side effect — the
-- signup-auto-entitle F-1 lesson).
--
-- WHO RUNS IT: `sync_pull` is SECURITY DEFINER owned by `variorum_definer`
-- (14c's non-bypass role), so this INVOKER trigger function (the
-- `stamp_server_seq` / `key_vault_require_proof_hash` posture: no SET clause —
-- outside the pg_temp belt's scope — and every relation schema-qualified) runs
-- as `variorum_definer` under FORCE RLS: `device_cursor_owner_all` admits
-- exactly the caller's rows, beside the body's own `owner_id = new.owner_id` —
-- two layers. `variorum_definer` holds SELECT/INSERT/UPDATE on
-- `device_cursor` (10 §11) and NO DELETE, so this file grants DELETE — the
-- 13i-a live finding's class (a missing definer grant that only a live round
-- surfaces), named and closed here rather than found at the window.
--
-- THE CONTAINMENT ARM (signup-auto-entitle's F-2): an AFTER INSERT error
-- would abort the upsert and with it the whole pull — every NEW device's
-- first round. So a failure inside the cap is caught and raised as a WARNING
-- (the Postgres logs), and the pull proceeds UNCAPPED — the pre-VX-919
-- posture, never a sync outage. The VERIFY reads below (the trigger, the
-- function, the definer's DELETE) and the optional probe keep the arm from
-- hiding a dead cap at deploy.
--
-- WHAT IT DOES NOT CHANGE: no marker (`sync_meta` untouched — device_cursor
-- is server-only and no client reads it), no client, no mirror data table, no
-- RPC; the E2EE disclosure envelope is unchanged (eviction removes
-- content-free timing rows, never adds any). THE HORIZON, stated: evicting a
-- row seen within 60 days is that device dropping out of `sync_horizon()`
-- early — the 13j design's returner road (the purged-ids ledger fences its
-- pushes; its next pull re-mints its row). Reachable only past 64 devices on
-- one account.
--
-- IDEMPOTENT AND RE-RUN-SAFE: create-or-replace + drop-trigger-if-exists, an
-- idempotent grant and revoke; a re-run lands the same state and deletes
-- nothing (it fires no insert). One transaction; a raised error rolls the
-- whole file back. GUARD: refuses below marker 14 (the set this artifact was
-- authored and reviewed against; production reads 15) and without its two
-- dependencies (the table, the definer role). No re-own, so no 10/14c
-- CREATE bracket: every object here stays owned by the deploying role.
-- Run via the stored-PAT query road as the deployer (postgres), at her window.
-- ============================================================================

begin;

do $guard$
declare
  deployed_marker int;
begin
  select value::int into deployed_marker from sync_meta where key = 'lockstep_version';
  if deployed_marker is null or deployed_marker < 14 then
    raise exception 'VARIORUM_VX919_NEEDS_14: this artifact rides the marker-14 set (deployed marker: %)', coalesce(deployed_marker::text, 'none');
  end if;
  if to_regclass('public.device_cursor') is null then
    raise exception 'VARIORUM_VX919_NO_DEVICE_CURSOR: the device_cursor table (10_phase13j_purge.sql) is absent';
  end if;
  if not exists (select 1 from pg_roles where rolname = 'variorum_definer') then
    raise exception 'VARIORUM_VX919_NO_DEFINER: the variorum_definer role (maintenance/14c-gate-definer-owner.sql) is absent';
  end if;
end;
$guard$;

-- The definer's DELETE on device_cursor — the cap's eviction runs as
-- `variorum_definer` inside `sync_pull` (the header's WHO RUNS IT).
grant delete on device_cursor to variorum_definer;

-- The cap: an INVOKER trigger function, RETURNS trigger.
create or replace function device_cursor_cap() returns trigger
language plpgsql
as $$
declare
  cap  constant int := 64;
  live int;
begin
  select count(*) into live
    from public.device_cursor d
    where d.owner_id = new.owner_id;
  if live > cap then
    delete from public.device_cursor t
      where t.owner_id = new.owner_id
        and t.device_id in (
          select d.device_id
            from public.device_cursor d
            where d.owner_id = new.owner_id
              and d.device_id <> new.device_id
            order by d.seen_at asc, d.device_id asc
            limit live - cap);
  end if;
  return null;
exception when others then
  -- THE CONTAINMENT ARM (the header): a cap failure never aborts the pull.
  raise warning 'device_cursor_cap failed for owner %: % — the pull proceeds uncapped (the pre-VX-919 posture)', new.owner_id, sqlerrm;
  return null;
end;
$$;

-- The PUBLIC-execute footgun pair (every new function; service_role named too —
-- Supabase's default privileges grant it at CREATE, the 14c grant-tidy lesson):
-- trigger firing never checks the DML role's EXECUTE, so this costs nothing and
-- leaves no RPC-shaped door.
revoke execute on function device_cursor_cap() from public, anon, authenticated, service_role;

drop trigger if exists device_cursor_cap on device_cursor;
create trigger device_cursor_cap
  after insert on device_cursor
  for each row execute function device_cursor_cap();

commit;

-- VERIFY (her window; every read below is read-only unless marked).
--
-- BEFORE the deploy (optional — what the first new device of an over-cap
-- account will trim at once):
--   select count(*) filter (where n > 64) as accounts_over_cap,
--          coalesce(max(n), 0)            as most_rows_on_one_account
--     from (select count(*) as n from device_cursor group by owner_id) per_account;
--
-- AFTER the deploy:
--   select t.tgname, t.tgenabled from pg_trigger t
--     join pg_class c on c.oid = t.tgrelid
--     join pg_namespace n on n.oid = c.relnamespace
--     where n.nspname = 'public' and c.relname = 'device_cursor' and not t.tgisinternal;
--                                          -- device_cursor_cap | O   (present, enabled)
--   select prosecdef, pg_get_userbyid(proowner), proconfig
--     from pg_proc where proname = 'device_cursor_cap';
--                                          -- false | postgres | (null)   (an INVOKER; no SET clause)
--   select has_table_privilege('variorum_definer', 'public.device_cursor', 'DELETE');
--                                          -- true   (the eviction's road as the definer)
--   select pg_get_functiondef('sync_pull(bigint,text,text,text,int,text)'::regprocedure)
--          like '%with picked as%';         -- true   (vx495's SHAPE B untouched — this file
--                                          --   changes no RPC)
--   the BEFORE read above again           -- unchanged by the deploy itself (no trim at deploy)
--   plus maintenance/14c-post-deploy-grant-sweep.sql — every row OK/INFO;
--   `device_cursor_cap()` now reads as a trigger-function INFO row (the sweep
--   expects it only while it exists, so pre-deploy and post-rollback sweeps
--   read exactly as before VX-919).
--
-- THE OPTIONAL BEHAVIORAL PROBE (her word; it WRITES INSIDE ONE TRANSACTION
-- AND ROLLS BACK — nothing persists). The fake harness cannot reach a
-- PL/pgSQL trigger (the recorded 13j class), so this is the live proof, run
-- through the DEFINER's road (postgres holds `variorum_definer` — 14c-gate)
-- under a synthetic owner no account has:
--   begin;
--     select set_config('request.jwt.claims',
--                       '{"sub":"00000000-0000-4000-8000-000000000919"}', true);
--     set local role variorum_definer;
--     insert into device_cursor (owner_id, device_id, last_seq, seen_at)
--       select auth.uid(), 'vx919-probe-' || g, 0, now() - make_interval(secs => 1000 - g)
--       from generate_series(1, 64) g;     -- 64 rows: at the cap, nothing evicted
--     insert into device_cursor (owner_id, device_id, last_seq, seen_at)
--       values (auth.uid(), 'vx919-probe-new', 0, now());
--                                          -- the 65th device: the oldest goes
--     select count(*), bool_and(device_id <> 'vx919-probe-1'),
--            bool_or(device_id = 'vx919-probe-new')
--       from device_cursor where owner_id = auth.uid();
--                                          -- 64 | true | true, and NO WARNING printed
--                                          --   ('device_cursor_cap failed …' would mean
--                                          --   the containment arm caught a failure —
--                                          --   the definer's DELETE grant or the owner
--                                          --   policy not reaching)
--   rollback;                              -- writes nothing
--
-- THE ROAD BACK: `maintenance/vx919-rollback.sql` (her word; idempotent;
-- restores the pre-VX-919 state exactly).
