-- ============================================================================
-- VX-213 — `pg_temp` appended to every definer-path search_path (marker 14)
-- ============================================================================
-- THE FINDING (VX-191's audit, C3 NIT — notes/plans/fixes/vx-191-audit/
-- C-crypto-wire-server.md): `set search_path = public` WITHOUT a trailing
-- `pg_temp` leaves pg_temp implicitly searched FIRST for relation names
-- (Postgres docs, "Writing SECURITY DEFINER Functions Safely"). No reachable
-- exploit path exists through PostgREST RPC (a caller cannot create a temp
-- table in the RPC's session), so this is belt-and-braces, held for her go
-- since 2026-10-13 and GIVEN at the 2026-10-22 sitting: rehearsed on the
-- throwaway with VX-329's set; PRODUCTION rides the marker-14 deploy window
-- at her explicit go (never pre-authorized).
--
-- THE SHAPE: one `alter function … set search_path` per function, by EXACT
-- deployed signature — never a blanket loop over pg_proc (the 13y window's
-- lesson: blanket sweeps catch supabase internals). Each alter preserves the
-- function's current list and appends `pg_temp` LAST (naming it explicitly
-- places it last in resolution order; unnamed, it is implicitly first).
-- `alter function … set` is idempotent — a re-run lands the same state.
--
-- SCOPE: the 14 SECURITY DEFINER functions live at marker 14, plus the four
-- invoker helpers that carry their own `set search_path` and execute INSIDE
-- definer bodies (their proconfig governs resolution while the definer's
-- privileges are in force): sync_key_gate, sync_key_proof_check,
-- next_tenant_seq, sync_constant_time_equal. Helpers with NO search_path
-- setting (stamp_server_seq, sync_table_pk, key_vault_require_proof_hash)
-- inherit the calling RPC's setting, which this artifact fixes at the RPC.
-- `sync_reencrypt` is retired at 17 and deliberately absent.
--
-- GUARD: refuses below marker 14 (17 redefines key_vault_update with
-- `set search_path = public`; applied before 17, that alter would be undone
-- by 17's create-or-replace). The verify tail then asserts ZERO definer
-- functions in public remain without a trailing pg_temp — fail loud on any
-- function this list missed (the read-fix-re-run road).
-- ============================================================================

do $guard$
declare
  deployed_marker int;
begin
  select value::int into deployed_marker from sync_meta where key = 'lockstep_version';
  if deployed_marker is null or deployed_marker < 14 then
    raise exception 'VARIORUM_PGTEMP_NEEDS_14: this artifact rides the marker-14 set — apply 17_phase_vx307_vault.sql first (deployed marker: %)', coalesce(deployed_marker::text, 'none');
  end if;
end;
$guard$;

-- The definer RPCs (search_path = public today):
alter function sync_push(jsonb, text, text, text)                       set search_path = public, pg_temp;
alter function sync_pull(bigint, text, text, text, int, text)           set search_path = public, pg_temp;
alter function sync_horizon(text, text, text)                           set search_path = public, pg_temp;
alter function sync_purge_ledger(bigint, text, text, text)              set search_path = public, pg_temp;
alter function sync_purge_execute(jsonb, text, text, text)              set search_path = public, pg_temp;
alter function account_data_truncate(text, text, text)                  set search_path = public, pg_temp;
alter function key_vault_update(jsonb, int, text, text)                 set search_path = public, pg_temp;
alter function key_proof_enroll(text, text, text)                       set search_path = public, pg_temp;
alter function account_purge()                                          set search_path = public, pg_temp;
alter function entitlement_set(uuid, text, boolean, timestamptz, text)  set search_path = public, pg_temp;
alter function sync_schema_version()                                    set search_path = public, pg_temp;
alter function sync_visibility_horizon_ms()                             set search_path = public, pg_temp;
alter function signup_auto_entitle()                                    set search_path = public, pg_temp;

-- The one definer RPC whose list carries `extensions` (12's challenge mint):
alter function sync_challenge(int)                                      set search_path = public, extensions, pg_temp;

-- The search_path-carrying helpers that run inside definer bodies:
alter function sync_key_gate(text, text, text, text)                    set search_path = public, pg_temp;
alter function sync_key_proof_check(text, text, text)                   set search_path = public, extensions, pg_temp;
alter function next_tenant_seq(uuid)                                    set search_path = public, pg_temp;
alter function sync_constant_time_equal(text, text)                     set search_path = public, pg_temp;

-- The project's RLS auto-enable EVENT TRIGGER (postgres-owned furniture the
-- grant sweep's expectation table already carries; `search_path=pg_catalog`
-- today — its own list preserved, pg_temp appended). Found by this artifact's
-- own verify sweep at the throwaway rehearsal (VX-329), the read-fix-re-run
-- road working as designed:
alter function rls_auto_enable()                                         set search_path = pg_catalog, pg_temp;

-- ============================================================================
-- VERIFY (fail loud): no SECURITY DEFINER function in public may remain
-- without a trailing pg_temp — any row here is a function the list above
-- missed; amend the artifact in repo and re-run (the 13j road).
-- ============================================================================
do $verify$
declare
  missing text;
begin
  select string_agg(p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')', ', ')
    into missing
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public'
     and p.prosecdef
     and (p.proconfig is null
          or not exists (
            select 1 from unnest(p.proconfig) cfg
             where cfg like 'search_path=%' and cfg like '%pg_temp'));
  if missing is not null then
    raise exception 'VARIORUM_PGTEMP_MISSED: definer function(s) without a trailing pg_temp: %', missing;
  end if;
end;
$verify$;

-- Read-only tail for the window record: every altered function's config.
select p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')' as fn,
       p.proconfig
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'public'
   and exists (select 1 from unnest(coalesce(p.proconfig, '{}')) cfg where cfg like 'search_path=%')
 order by 1;
