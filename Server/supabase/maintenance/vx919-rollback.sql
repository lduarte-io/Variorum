-- ============================================================================
-- VX-919 ROLLBACK — the device_cursor cap belt removed; the mirror restored to
-- its exact pre-VX-919 state (a MAINTENANCE artifact — NO marker move)
-- ============================================================================
-- WHEN IT RUNS: at her word only — if the cap misbehaves after
-- `maintenance/vx919-device-cursor-cap.sql` deploys (a WARNING
-- 'device_cursor_cap failed …' in the Postgres logs, the optional probe
-- failing, or any reason she names). Written and reviewed BEFORE the deploy,
-- the vx495 precedent (`vx495-rollback.sql`): the road back exists before the
-- road forward is taken. AUTHORED in the VX-849 run (batch 6) and NEVER
-- EXECUTED there.
--
-- WHAT IT RESTORES — exactly what the cap artifact added, nothing else:
--   the trigger `device_cursor_cap` on device_cursor   DROPPED (if present);
--   the function `device_cursor_cap()`                  DROPPED (if present);
--   `variorum_definer`'s DELETE on device_cursor        REVOKED — before VX-919
--                                                       the role held SELECT /
--                                                       INSERT / UPDATE only
--                                                       (10_phase13j_purge.sql §11).
-- `sync_pull` is untouched in both directions (the cap artifact changes no
-- RPC), so nothing on the wire moves and no client is involved.
--
-- WHAT IT CANNOT RESTORE, stated: device_cursor rows the cap EVICTED while it
-- was live stay gone. They are content-free bookkeeping (a device id, a seq,
-- a timestamp); a real device re-mints its row at its next pull, and the 13j
-- design treats the gap as an early drop-out from `sync_horizon()` (the
-- purged-ids ledger fences a returner). No data row is touched in either
-- direction.
--
-- IDEMPOTENT: drop-if-exists and a revoke; run on a mirror that never received
-- the cap it lands the state already in force. RE-RUNNING THE CAP ARTIFACT
-- AFTERWARDS IS LEGAL (it lands its whole state again). GUARD: the cap
-- artifact's own — refuses below marker 14. One transaction. Run via the
-- stored-PAT query road as the deployer (postgres).
-- ============================================================================

begin;

do $guard$
declare
  deployed_marker int;
begin
  select value::int into deployed_marker from sync_meta where key = 'lockstep_version';
  if deployed_marker is null or deployed_marker < 14 then
    raise exception 'VARIORUM_VX919_NEEDS_14: this rollback rides the marker-14 set (deployed marker: %)', coalesce(deployed_marker::text, 'none');
  end if;
end;
$guard$;

drop trigger if exists device_cursor_cap on device_cursor;
drop function if exists device_cursor_cap();
revoke delete on device_cursor from variorum_definer;

commit;

-- VERIFY (read-only, after the rollback):
--   select count(*) from pg_trigger t
--     join pg_class c on c.oid = t.tgrelid
--     join pg_namespace n on n.oid = c.relnamespace
--     where n.nspname = 'public' and c.relname = 'device_cursor' and not t.tgisinternal;
--                                          -- 0   (no trigger on device_cursor)
--   select count(*) from pg_proc where proname = 'device_cursor_cap';
--                                          -- 0
--   select has_table_privilege('variorum_definer', 'public.device_cursor', 'DELETE');
--                                          -- false   (the pre-VX-919 grant set)
--   plus maintenance/14c-post-deploy-grant-sweep.sql — every row OK/INFO, with
--   no `device_cursor_cap()` row at all (its expectation lives only while the
--   function exists).
