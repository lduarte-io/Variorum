-- Variorum sync mirror — 14c GATE definer-owner repair (2026-08-11;
-- one-time, executed at the gate in the empty window between the 09
-- deploy and her repush, at the author's explicit go).
--
-- WHY: live-probe obligation 2 answered the design sitting's pinned
-- caveat, and the answer was NO — the hosted `postgres` role (owner of
-- every SECURITY DEFINER function 09 installs) carries BYPASSRLS, which
-- overrides even FORCE row level security. As deployed, the ruled
-- two-layer hybrid therefore ran on ONE live layer at the RPC path (the
-- explicit tenant-scoped guards — heavily pinned and isolation-round
-- verified); the policies bound only direct anon/authenticated access.
--
-- THE REPAIR: a dedicated NON-BYPASS owner for the three DATA functions
-- (`sync_push`, `sync_pull`, `account_data_truncate`). Under FORCE RLS
-- the policies then genuinely bind those bodies — an RPC guard bug hits
-- the policy, a policy bug hits the guard: the sitting's Round-3/4
-- ruling, made real. Verified live after execution: the grant sweep, an
-- owner check, and a uid-checked probe pull (zero rows, no refusal)
-- BEFORE the repush ran.
--
-- DELIBERATELY NOT MOVED:
--   * `account_purge` keeps postgres — it must DELETE the caller's
--     `auth.users` row (auth-schema DML is postgres's; a custom role
--     cannot be granted it here). Its safety is structural: every
--     delete keys on auth.uid() and it takes no input (the isolation
--     round's clean verdict).
--   * `entitlement_set` keeps postgres — it must WRITE `entitlement`,
--     whose only policy is an own-row SELECT (a non-bypass owner would
--     be policy-refused). Its safety is the service_role-only EXECUTE
--     posture, sweep-verified.
--   * `sync_schema_version` keeps postgres — marker only, no tenant
--     data, and `sync_meta` has RLS enabled with no policies (a
--     non-bypass owner could not read it).
--
-- SUPPORTING PIECES, each load-bearing:
--   * `key_vault` + `entitlement` policies are `to authenticated`, so
--     the new owner needs its OWN own-row SELECT policies or the fence
--     and tier-gate reads inside the RPC bodies would default-deny and
--     refuse every round (both tables are ENABLE-only RLS; the
--     predicate is the caller's row exactly as the RPC reads it).
--   * `sync_table_pk`'s I-4 revoke reasoned "the definer bodies call it
--     as the OWNER, which also owns the helper" — ownership moving OFF
--     postgres breaks that equality, so the helper is granted to
--     variorum_definer explicitly (NOLOGIN — unreachable from any API;
--     the no-door-back posture holds, and the DDL pin now says so).
--   * `stamp_server_seq` is INVOKER security, so the BEFORE INSERT
--     trigger runs as the DML role — the sequences grant covers its
--     nextval.
--   * `auth.uid()` carries a PUBLIC execute ACL (verified live), so the
--     new owner needs no grant there.
--
-- ROLLBACK (if a live refusal ever traces here): three one-line
-- `alter function … owner to postgres;` statements restore the
-- pre-repair state exactly.

begin;

create role variorum_definer with nologin nobypassrls;
grant variorum_definer to postgres;

grant usage on schema public to variorum_definer;
grant select, insert, update, delete on
  container, block, variant, commit_point, edge, container_block,
  reading, reading_section, reading_post, tag, post_tag, block_tag,
  reference, canvas_layout, lens, lens_choice, block_comment, setting
  to variorum_definer;
grant select on key_vault, entitlement to variorum_definer;
grant usage, select on all sequences in schema public to variorum_definer;
grant execute on function sync_table_pk(text) to variorum_definer;

create policy key_vault_definer_fence_select on key_vault
  for select to variorum_definer using (auth.uid() = user_id);
create policy entitlement_definer_gate_select on entitlement
  for select to variorum_definer using (auth.uid() = user_id);

alter function sync_push(jsonb, text) owner to variorum_definer;
alter function sync_pull(bigint, text, integer) owner to variorum_definer;
alter function account_data_truncate(text) owner to variorum_definer;

commit;
