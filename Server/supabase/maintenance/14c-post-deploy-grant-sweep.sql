-- Variorum mirror — THE POST-DEPLOY GRANT SWEEP (Phase 14c; the dedicated
-- isolation round's finding I-3, and live-probe obligation 11). EXTENDED at
-- pre-13x batch 1b for the postures event (11_pre13x_postures.sql): the new
-- RPC signatures, the two gate helpers, the vault's closed write road (its
-- policy set, its per-role UPDATE privilege) and the insert trigger.
-- EXTENDED at Phase 13y UNIT A for the per-tenant sequence event
-- (12_phase13y_tenant_seq.sql): sync_pull's REORDERED signature (NIT-4 —
-- the old spelling becomes the UNEXPECTED lingering-overload class), the
-- `next_tenant_seq(uuid)` counter helper (the sync_table_pk posture — no
-- API role), the `sync_tenant_seq` counter table (the device_cursor
-- posture — forced RLS, one owner policy, no API-role privileges), and
-- the `sync_visibility_horizon_ms()` served-horizon function (the
-- R-13y-4 fork's Shape 1 — `sync_schema_version()`'s exact posture).
-- EXTENDED at Phase 13y UNIT B for the SAME event's challenge half (the
-- ruled memo, QUESTIONS #144): EVERY gated RPC's signature gains the
-- defaultless `challenge` (the 11-era spellings ALL become the
-- UNEXPECTED lingering-overload class — a survivor is a CHALLENGE-FREE
-- door), the two gate helpers re-shape with it, and the new surface
-- lands: `sync_challenge(integer)` + `key_proof_enroll(text,text,text)`
-- (the account-door posture), `sync_constant_time_equal(text,text)` (the
-- helper posture), and the two server-only tables
-- `key_proof_challenge` / `sync_write_budget` (the device_cursor
-- posture). EXTENDED again at Phase 13y ladder R1 (F-R2): the definer
-- role's SCHEMA-USAGE reach on `extensions` (pgcrypto, for
-- gen_random_bytes/hmac) and `vault` (the MAC secret) is now asserted LIVE
-- via `has_schema_privilege` — the honest end-state check the grant line's
-- mere presence cannot be.
--
-- WHAT IT IS: one READ-ONLY query, run IMMEDIATELY AFTER a lockstep deploy
-- (09 at the 14c gate; 10 at the 13j window; 11 at the pre-13x window),
-- that prints the mirror's FINAL privilege posture — every function's ACL
-- and per-role EXECUTE, every public table's RLS enabled/forced state,
-- policy count, and per-role privileges — plus, since 11, the vault's
-- policy NAMES, its insert trigger and its UPDATE privilege per role — with
-- each row carrying its EXPECTED value from the artifacts' letter and an
-- OK / MISMATCH / UNEXPECTED / MISSING verdict. The point is that the
-- operator SEES the posture instead of trusting that the trailing REVOKEs
-- ran: the postures land by revokes that undo Supabase's broad CREATE-time
-- defaults, and "assumed, not verified" is exactly what the isolation
-- round refused to leave standing.
--
-- IT WRITES NOTHING. No DDL, no DML, no transaction — safe to run any
-- number of times, before or after any other gate act. Run it as the
-- deploying role (the stored-PAT Management-API road or the dashboard SQL
-- editor). It reads only catalogs.
--
-- HOW TO READ IT: every row should say OK. Any MISMATCH is a real posture
-- defect — investigate before the signup door opens. `INFO` rows are
-- deliberately unasserted observations (the service_role column where 09
-- states no expectation; the trigger functions, uncallable via RPC by
-- Postgres rule). UNEXPECTED rows are objects nobody in this repo's
-- artifacts creates — including a LINGERING OLD RPC OVERLOAD, which is the
-- one failure this sweep exists to make impossible to miss (a surviving
-- `sync_push(jsonb,text)` after 11 would be a PROOF-FREE door beside the
-- new one; 11 section 0 drops all six old signatures) — and, since 11, a
-- lingering `key_vault_owner_update` policy, the proof-free PATCH road.
--
-- The expectations below are the artifacts' letter, transcribed (12's
-- signatures supersede 11's; 11's superseded 10's; 10's superseded 09's):
--   sync_push(jsonb,text,text,text) / sync_pull(bigint,text,text,text,integer,text)
--                                    anon ✗  authenticated ✓  service_role ✓
--                                    (both spellings are 13y UNIT B's challenge
--                                    signatures; EVERY 11-era gated spelling is
--                                    DROPPED by 12 and would surface UNEXPECTED —
--                                    a survivor is a CHALLENGE-FREE door)
--   account_data_truncate(text,text,text) / account_purge()
--                                    anon ✗  authenticated ✓  service_role ✗
--   sync_horizon(text,text,text) / sync_purge_ledger(bigint,text,text,text) /
--   sync_purge_execute(jsonb,text,text,text) / sync_reencrypt(jsonb,text,text,text) /
--   key_vault_update(jsonb,integer,text,text) /
--   sync_challenge(integer) / key_proof_enroll(text,text,text) (13y UNIT B)
--                                    anon ✗  authenticated ✓  service_role ✗
--   sync_key_gate(text,text,text,text) / sync_key_proof_check(text,text,text) /
--   sync_constant_time_equal(text,text) (13y UNIT B) /
--   next_tenant_seq(uuid) (13y)       anon ✗  authenticated ✗  service_role ✗
--                                    (definer bodies are the only callers)
--   entitlement_set                  anon ✗  authenticated ✗  service_role ✓
--   sync_schema_version              anon ✗  authenticated ✓
--   sync_visibility_horizon_ms (13y) anon ✗  authenticated ✓
--                                    (the version RPC's exact posture — the
--                                    served A5 horizon, Shape 1)
--   sync_table_pk                    anon ✗  authenticated ✗   (finding I-4)
--   the 19 data tables               anon ✗  authenticated ✗  RLS on + FORCED, 1 policy
--   entitlement                      anon ✗  authenticated ✓ (SELECT only), RLS on, 2 policies
--   key_vault (08 + 11)              anon ✗  authenticated ✓ (select/insert — UPDATE REVOKED),
--                                    RLS on, 4 policies: owner_select · owner_insert ·
--                                    definer_fence_select · definer_update
--                                    (owner_update DROPPED); the insert trigger present
--   sync_meta (05)                   anon ✗  authenticated ✗  RLS on, 0 policies

with expected_functions (signature, exp_anon, exp_authenticated, exp_service_role) as (
  -- VX-308 REHEARSAL (2026-10-19, finding R-2 — artifact 17's dress rehearsal
  -- on the throwaway): marker-aware rows. Artifact 17 DROPS sync_reencrypt
  -- (rule 15's kept list replaces the rotation walk), so on a marker-14
  -- mirror its expectation row RETIRES; a marker-13 mirror — production
  -- until VX-329's window — still demands it. Without this, the release
  -- window's sweep would report MISSING on a deliberately dropped function.
  select v.signature, v.exp_anon, v.exp_authenticated, v.exp_service_role
  from (
  values
    -- 13y UNIT B (12): every gated RPC's signature gained the defaultless
    -- `challenge`; ALL 11-era overloads are DROPPED by 12 — any
    -- reappearance is UNEXPECTED, the exact lingering-overload class this
    -- sweep exists to catch (a survivor is a CHALLENGE-FREE door).
    ('sync_push(jsonb,text,text,text)',                                false, true,  true),
    ('sync_pull(bigint,text,text,text,integer,text)',                  false, true,  true),
    ('account_data_truncate(text,text,text)',                          false, true,  false),
    ('account_purge()',                                                false, true,  false),
    ('sync_horizon(text,text,text)',                                   false, true,  false),
    ('sync_purge_ledger(bigint,text,text,text)',                       false, true,  false),
    ('sync_purge_execute(jsonb,text,text,text)',                       false, true,  false),
    ('sync_reencrypt(jsonb,text,text,text)',                           false, true,  false),
    ('key_vault_update(jsonb,integer,text,text)',                      false, true,  false),
    -- 13y UNIT B: the nonce mint (session-gated) and the one enrollment
    -- road — the account-door posture.
    ('sync_challenge(integer)',                                        false, true,  false),
    ('key_proof_enroll(text,text,text)',                               false, true,  false),
    -- The two gate helpers: reachable by NO API role (the sync_table_pk
    -- posture — the definer bodies call them as their owner).
    ('sync_key_gate(text,text,text,text)',                             false, false, false),
    ('sync_key_proof_check(text,text,text)',                           false, false, false),
    -- 13y UNIT B: the hoisted constant-time compare — the helper posture.
    ('sync_constant_time_equal(text,text)',                            false, false, false),
    -- 13y (12): the per-owner counter helper — the sync_table_pk posture
    -- (the trigger and the definer bodies are its only callers).
    ('next_tenant_seq(uuid)',                                           false, false, false),
    ('entitlement_set(uuid,text,boolean,timestampwithtimezone,text)',  false, false, true),
    ('sync_schema_version()',                                          false, true,  null),
    -- 13y (12): the served A5 horizon (the R-13y-4 fork's Shape 1) —
    -- the version RPC's exact posture, transcribed.
    ('sync_visibility_horizon_ms()',                                   false, true,  null),
    ('sync_table_pk(text)',                                            false, false, null),
    ('stamp_server_seq()',                                             null,  null,  null),
    -- pre-13x 11: the vault's insert trigger function — RETURNS trigger,
    -- uncallable via RPC by Postgres rule; INFO by design.
    ('key_vault_require_proof_hash()',                                 null,  null,  null),
    -- Signup auto-entitlement (maintenance, 2026-09-24 — her word at the
    -- 13y window's tail; the record rides 13t's row): the auth.users
    -- signup trigger's function — RETURNS trigger; INFO by design.
    ('signup_auto_entitle()',                                          null,  null,  null),
    -- Identified at the 14c gate (2026-08-11): a platform-side event-trigger
    -- function (attached as `ensure_rls` on ddl_command_end) that auto-enables
    -- RLS on new public tables — never in a repo artifact, benign and
    -- protective. RETURNS event_trigger, so it is uncallable via RPC by
    -- Postgres rule; its broad EXECUTE acl is moot. INFO by design.
    ('rls_auto_enable()',                                              null,  null,  null)
  ) as v(signature, exp_anon, exp_authenticated, exp_service_role)
  where v.signature <> 'sync_reencrypt(jsonb,text,text,text)'
     or coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1) < 14
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
    -- 13j (10_phase13j_purge.sql): the 19th data table + the two
    -- server-only purge tables, all on the standard forced-RLS posture.
    ('purge_intent',    false, false, true,  true,  1),
    ('device_cursor',   false, false, true,  true,  1),
    ('purged_row',      false, false, true,  true,  1),
    -- 13y (12_phase13y_tenant_seq.sql): the per-owner sequence counter —
    -- server-only, the device_cursor posture.
    ('sync_tenant_seq',  false, false, true,  true,  1),
    -- 13y UNIT B (12): the single-use challenge nonces and the abuse
    -- guard's accounting row — server-only, the device_cursor posture.
    ('key_proof_challenge', false, false, true, true, 1),
    ('sync_write_budget',   false, false, true, true, 1),
    -- 13i-a (13_phase13i_wings.sql): the two wings/shelves data tables,
    -- born on the standard forced-RLS posture.
    ('wing',            false, false, true,  true,  1),
    ('shelf',           false, false, true,  true,  1),
    -- policy counts +1 each since the 14c-gate BYPASSRLS repair
    -- (2026-08-11, maintenance/14c-gate-definer-owner.sql): the own-row
    -- SELECT policies for the non-bypass variorum_definer owner
    -- (key_vault_definer_fence_select / entitlement_definer_gate_select)
    -- — the fence and tier-gate reads inside the re-owned RPC bodies.
    -- pre-13x 11: key_vault stays at 4 — owner_update DROPPED,
    -- definer_update ADDED (the policy-name rows below name them).
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
-- pre-13x 11: the vault's policy set BY NAME — the count alone cannot tell
-- "owner_update dropped + definer_update added" from "nothing changed".
expected_vault_policies (polname) as (
  values
    ('key_vault_owner_select'),
    ('key_vault_owner_insert'),
    ('key_vault_definer_fence_select'),
    ('key_vault_definer_update')
),
observed_vault_policies as (
  select pol.polname
  from pg_policy pol
  join pg_class c on c.oid = pol.polrelid
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relname = 'key_vault'
),
-- pre-13x 11: the vault's UPDATE privilege per role — the closed write road
-- (authenticated ✗) and the one road left (variorum_definer ✓) — and the
-- insert trigger that refuses a NULL key_proof_hash at creation.
expected_vault_facts (fact, expected) as (
  values
    ('privilege:authenticated:UPDATE', false),
    ('privilege:authenticated:SELECT', true),
    ('privilege:authenticated:INSERT', true),
    ('privilege:authenticated:DELETE', false),
    ('privilege:variorum_definer:UPDATE', true),
    ('privilege:variorum_definer:SELECT', true),
    ('privilege:anon:UPDATE', false),
    ('trigger:key_vault_require_proof_hash', true),
    -- Signup auto-entitlement (maintenance, 2026-09-24; the act's cold
    -- review F-4): the auth.users trigger is LOAD-BEARING for the beta —
    -- lost, every new signup lands unentitled while the function's INFO
    -- row still reads clean. A fact row makes its absence a MISMATCH.
    ('trigger:auth.users:variorum_signup_auto_entitle', true)
),
observed_vault_facts as (
  select 'privilege:authenticated:UPDATE' as fact,
         has_table_privilege('authenticated', 'public.key_vault', 'UPDATE') as observed
  union all
  select 'privilege:authenticated:SELECT',
         has_table_privilege('authenticated', 'public.key_vault', 'SELECT')
  union all
  select 'privilege:authenticated:INSERT',
         has_table_privilege('authenticated', 'public.key_vault', 'INSERT')
  union all
  select 'privilege:authenticated:DELETE',
         has_table_privilege('authenticated', 'public.key_vault', 'DELETE')
  union all
  select 'privilege:variorum_definer:UPDATE',
         has_table_privilege('variorum_definer', 'public.key_vault', 'UPDATE')
  union all
  select 'privilege:variorum_definer:SELECT',
         has_table_privilege('variorum_definer', 'public.key_vault', 'SELECT')
  union all
  select 'privilege:anon:UPDATE',
         has_table_privilege('anon', 'public.key_vault', 'UPDATE')
  union all
  select 'trigger:key_vault_require_proof_hash',
         exists (
           select 1 from pg_trigger t
           join pg_class c on c.oid = t.tgrelid
           join pg_namespace n on n.oid = c.relnamespace
           where n.nspname = 'public' and c.relname = 'key_vault'
             and t.tgname = 'key_vault_require_proof_hash' and not t.tgisinternal)
  union all
  select 'trigger:auth.users:variorum_signup_auto_entitle',
         exists (
           select 1 from pg_trigger t
           join pg_class c on c.oid = t.tgrelid
           join pg_namespace n on n.oid = c.relnamespace
           where n.nspname = 'auth' and c.relname = 'users'
             and t.tgname = 'variorum_signup_auto_entitle' and not t.tgisinternal)
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
      when o.signature is null then 'MISSING — the lockstep artifact must create it'
      when e.signature is null then 'UNEXPECTED FUNCTION — review (a lingering old RPC overload is a proof-free or cross-tenant door)'
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
      when o.relname is null then 'MISSING — the lockstep artifact must create it'
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
),
vault_policy_rows as (
  select
    'vault-policy'                                   as kind,
    'key_vault.' || coalesce(e.polname, o.polname)   as object,
    ''                                               as acl,
    case when o.polname is null then 'absent' else 'present' end as observed,
    'present'                                        as expected,
    case
      when o.polname is null then 'MISSING — 11 must create it'
      when e.polname is null then 'UNEXPECTED POLICY — review (key_vault_owner_update is the proof-free PATCH road 11 drops)'
      else 'OK'
    end as verdict
  from expected_vault_policies e
  full outer join observed_vault_policies o on o.polname = e.polname
),
vault_fact_rows as (
  select
    'vault-fact'                       as kind,
    -- The auth-schema signup-trigger fact carries its own table in the
    -- fact name (2026-09-24); only the key_vault-scoped facts take the
    -- historical 'key_vault.' prefix.
    case when e.fact like 'trigger:auth.users:%' then e.fact
         else 'key_vault.' || e.fact end as object,
    ''                                 as acl,
    coalesce(o.observed::text, 'absent') as observed,
    e.expected::text                   as expected,
    case
      when o.observed is distinct from e.expected then 'MISMATCH:' || e.fact
      else 'OK'
    end as verdict
  from expected_vault_facts e
  left join observed_vault_facts o on o.fact = e.fact
),
-- 13y ladder R1 (F-R2): the definer role's SCHEMA-USAGE reach, verified
-- LIVE. The two 13y-UNIT-B bodies resolve pgcrypto in `extensions` AS
-- `variorum_definer` (the SECURITY DEFINER callers), and the definer reads
-- the MAC secret in `vault`. `has_schema_privilege` reports the ACTUAL
-- end state whichever mechanism supplies it — the explicit
-- `grant usage on schema extensions/vault to variorum_definer` in 12/11 OR
-- the definer's inherited `authenticated` membership (14c-gate) — so this
-- is the honest verification the grant-line's mere presence cannot be
-- (an explicit grant is a WARNING no-op where postgres lacks grant option
-- on a platform-owned schema, exactly as it was for `auth`).
schema_usage_rows as (
  select
    'schema-usage'                                                       as kind,
    'variorum_definer USAGE on ' || s.schema_name                       as object,
    ''                                                                   as acl,
    has_schema_privilege('variorum_definer', s.schema_name, 'USAGE')::text as observed,
    'true'                                                              as expected,
    case
      when has_schema_privilege('variorum_definer', s.schema_name, 'USAGE')
        then 'OK'
      else 'MISMATCH:usage — the definer bodies cannot resolve this schema (extensions.hmac / vault.decrypted_secrets refuse)'
    end                                                                  as verdict
  from (values ('extensions'), ('vault')) as s(schema_name)
)
select * from (
  select 1 as ord, * from function_rows
  union all
  select 2 as ord, * from table_rows
  union all
  select 3 as ord, * from vault_policy_rows
  union all
  select 4 as ord, * from vault_fact_rows
  union all
  select 5 as ord, * from schema_usage_rows
) sweep
order by ord, case when verdict = 'OK' or verdict = 'INFO' then 1 else 0 end, object;
