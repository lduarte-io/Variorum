-- Variorum mirror — THE POST-DEPLOY GRANT SWEEP (Phase 14c; the dedicated
-- isolation round's finding I-3, and live-probe obligation 11).
--
-- WHAT IT IS: one READ-ONLY query, run IMMEDIATELY AFTER
-- `09_phase14c_multitenant.sql` deploys, that prints the mirror's FINAL
-- privilege posture — every function's ACL and per-role EXECUTE, every
-- public table's RLS enabled/forced state, policy count, and per-role
-- privileges — with each row carrying its EXPECTED value from 09's letter
-- and an OK / MISMATCH / UNEXPECTED / MISSING verdict. The point is that
-- the operator SEES the posture instead of trusting that the trailing
-- REVOKEs ran: 09's postures land by revokes that undo Supabase's broad
-- CREATE-time defaults, and "assumed, not verified" is exactly what the
-- isolation round refused to leave standing.
--
-- IT WRITES NOTHING. No DDL, no DML, no transaction — safe to run any
-- number of times, before or after any other gate act. Run it as the
-- deploying role (the stored-PAT Management-API road or the dashboard SQL
-- editor). It reads only catalogs.
--
-- HOW TO READ IT: every row should say OK. Any MISMATCH is a real posture
-- defect — investigate before the signup door opens. `INFO` rows are
-- deliberately unasserted observations (the service_role column where 09
-- states no expectation; the trigger function, uncallable via RPC by
-- Postgres rule). UNEXPECTED rows are objects nobody in this repo's
-- artifacts creates — including a LINGERING OLD RPC OVERLOAD, which is the
-- one failure this sweep exists to make impossible to miss (a surviving
-- `sync_push(jsonb)` would be an unscoped, unfenced door beside the new
-- one; 09 section 0 drops both old signatures).
--
-- The expectations below are 09's letter, transcribed:
--   sync_push / sync_pull            anon ✗  authenticated ✓  service_role ✓
--   account_data_truncate / _purge   anon ✗  authenticated ✓  service_role ✗
--   entitlement_set                  anon ✗  authenticated ✗  service_role ✓
--   sync_schema_version              anon ✗  authenticated ✓
--   sync_table_pk                    anon ✗  authenticated ✗   (finding I-4)
--   the 18 data tables               anon ✗  authenticated ✗  RLS on + FORCED, 1 policy
--   entitlement                      anon ✗  authenticated ✓ (SELECT only), RLS on, 1 policy
--   key_vault (08)                   anon ✗  authenticated ✓ (select/insert/update), RLS on, 3 policies
--   sync_meta (05)                   anon ✗  authenticated ✗  RLS on, 0 policies

with expected_functions (signature, exp_anon, exp_authenticated, exp_service_role) as (
  values
    ('sync_push(jsonb,text)',                                          false, true,  true),
    ('sync_pull(bigint,text,integer)',                                 false, true,  true),
    ('account_data_truncate(text)',                                    false, true,  false),
    ('account_purge()',                                                false, true,  false),
    ('entitlement_set(uuid,text,boolean,timestampwithtimezone,text)',  false, false, true),
    ('sync_schema_version()',                                          false, true,  null),
    ('sync_table_pk(text)',                                            false, false, null),
    ('stamp_server_seq()',                                             null,  null,  null),
    -- Identified at the 14c gate (2026-08-11): a platform-side event-trigger
    -- function (attached as `ensure_rls` on ddl_command_end) that auto-enables
    -- RLS on new public tables — never in a repo artifact, benign and
    -- protective. RETURNS event_trigger, so it is uncallable via RPC by
    -- Postgres rule; its broad EXECUTE acl is moot. INFO by design.
    ('rls_auto_enable()',                                              null,  null,  null)
),
observed_functions as (
  select
    replace(p.oid::regprocedure::text, ' ', '')                    as signature,
    coalesce(array_to_string(p.proacl::text[], ' | '), '(owner only)') as acl,
    has_function_privilege('anon',         p.oid, 'EXECUTE')       as obs_anon,
    has_function_privilege('authenticated', p.oid, 'EXECUTE')      as obs_authenticated,
    has_function_privilege('service_role',  p.oid, 'EXECUTE')      as obs_service_role
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
),
expected_tables (relname, exp_anon, exp_authenticated, exp_rls, exp_forced, exp_policies) as (
  values
    ('container',       false, false, true,  true,  1),
    ('block',           false, false, true,  true,  1),
    ('variant',         false, false, true,  true,  1),
    ('commit_point',    false, false, true,  true,  1),
    ('edge',            false, false, true,  true,  1),
    ('container_block', false, false, true,  true,  1),
    ('reading',         false, false, true,  true,  1),
    ('reading_section', false, false, true,  true,  1),
    ('reading_post',    false, false, true,  true,  1),
    ('tag',             false, false, true,  true,  1),
    ('post_tag',        false, false, true,  true,  1),
    ('block_tag',       false, false, true,  true,  1),
    ('reference',       false, false, true,  true,  1),
    ('canvas_layout',   false, false, true,  true,  1),
    ('lens',            false, false, true,  true,  1),
    ('lens_choice',     false, false, true,  true,  1),
    ('block_comment',   false, false, true,  true,  1),
    ('setting',         false, false, true,  true,  1),
    -- policy counts +1 each since the 14c-gate BYPASSRLS repair
    -- (2026-08-11, maintenance/14c-gate-definer-owner.sql): the own-row
    -- SELECT policies for the non-bypass variorum_definer owner
    -- (key_vault_definer_fence_select / entitlement_definer_gate_select)
    -- — the fence and tier-gate reads inside the re-owned RPC bodies.
    ('entitlement',     false, true,  true,  false, 2),
    ('key_vault',       false, true,  true,  false, 4),
    ('sync_meta',       false, false, true,  false, 0)
),
observed_tables as (
  select
    c.relname,
    coalesce(array_to_string(c.relacl::text[], ' | '), '(owner only)') as acl,
    c.relrowsecurity      as obs_rls,
    c.relforcerowsecurity as obs_forced,
    (select count(*) from pg_policy pol where pol.polrelid = c.oid)::int as obs_policies,
    has_table_privilege('anon', c.oid,
      'SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER')  as obs_anon,
    has_table_privilege('authenticated', c.oid,
      'SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER')  as obs_authenticated,
    has_table_privilege('service_role', c.oid,
      'SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER')  as obs_service_role
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relkind = 'r'
),
function_rows as (
  select
    'function'                                as kind,
    coalesce(e.signature, o.signature)        as object,
    coalesce(o.acl, '(absent)')               as acl,
    format('anon=%s authenticated=%s service_role=%s',
           o.obs_anon, o.obs_authenticated, o.obs_service_role) as observed,
    format('anon=%s authenticated=%s service_role=%s',
           coalesce(e.exp_anon::text, 'INFO'),
           coalesce(e.exp_authenticated::text, 'INFO'),
           coalesce(e.exp_service_role::text, 'INFO'))          as expected,
    case
      when o.signature is null then 'MISSING — 09 must create it'
      when e.signature is null then 'UNEXPECTED FUNCTION — review (a lingering old RPC overload is a cross-tenant door)'
      else coalesce(nullif(concat_ws(' ',
        case when e.exp_anon          is not null and o.obs_anon          is distinct from e.exp_anon          then 'MISMATCH:anon'          end,
        case when e.exp_authenticated is not null and o.obs_authenticated is distinct from e.exp_authenticated then 'MISMATCH:authenticated' end,
        case when e.exp_service_role  is not null and o.obs_service_role  is distinct from e.exp_service_role  then 'MISMATCH:service_role'  end
      ), ''), case when e.exp_anon is null and e.exp_authenticated is null then 'INFO' else 'OK' end)
    end as verdict
  from expected_functions e
  full outer join observed_functions o on o.signature = e.signature
),
table_rows as (
  select
    'table'                            as kind,
    coalesce(e.relname, o.relname)     as object,
    coalesce(o.acl, '(absent)')        as acl,
    format('anon=%s authenticated=%s service_role=%s rls=%s forced=%s policies=%s',
           o.obs_anon, o.obs_authenticated, o.obs_service_role,
           o.obs_rls, o.obs_forced, o.obs_policies)                       as observed,
    format('anon=%s authenticated=%s rls=%s forced=%s policies=%s',
           e.exp_anon, e.exp_authenticated, e.exp_rls, e.exp_forced, e.exp_policies) as expected,
    case
      when o.relname is null then 'MISSING — 09 must create it'
      when e.relname is null then 'UNEXPECTED TABLE — review'
      else coalesce(nullif(concat_ws(' ',
        case when o.obs_anon          is distinct from e.exp_anon          then 'MISMATCH:anon'          end,
        case when o.obs_authenticated is distinct from e.exp_authenticated then 'MISMATCH:authenticated' end,
        case when o.obs_rls           is distinct from e.exp_rls           then 'MISMATCH:rls'           end,
        case when o.obs_forced        is distinct from e.exp_forced        then 'MISMATCH:force_rls'     end,
        case when o.obs_policies      is distinct from e.exp_policies      then 'MISMATCH:policy_count'  end
      ), ''), 'OK')
    end as verdict
  from expected_tables e
  full outer join observed_tables o on o.relname = e.relname
)
select * from (
  select 1 as ord, * from function_rows
  union all
  select 2 as ord, * from table_rows
) sweep
order by ord, case when verdict = 'OK' or verdict = 'INFO' then 1 else 0 end, object;
