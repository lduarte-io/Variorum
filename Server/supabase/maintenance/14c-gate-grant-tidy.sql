-- Variorum sync mirror — 14c GATE grant tidy (2026-08-11; one-time,
-- executed at the gate immediately after the 09 deploy).
--
-- WHAT: revoke the service_role EXECUTE grant from the two account
-- lifecycle doors. 09's letter is authenticated-only for both (account
-- acts are always a signed-in user's own, never server machinery's —
-- the batch-2 design call), but Supabase's default privileges grant
-- EXECUTE to service_role at function CREATE, and 09's revokes named
-- only public + anon. Caught by the post-deploy grant sweep
-- (MISMATCH:service_role on both doors); the scratch-Postgres proof run
-- could not surface it because the stub did not emulate Supabase's
-- default-privilege machinery.
--
-- REACH: zero either way — both deployed bodies refuse a NULL
-- auth.uid() caller, which service_role always is (verified in the
-- deployed account_purge body at the gate). This is posture exactness,
-- not a hole being closed.
--
-- 09 itself now names service_role in both revokes (same-day edit), so
-- any future deploy of the artifact lands the correct posture directly
-- and this file is not needed again.

begin;

revoke execute on function account_data_truncate(text) from service_role;
revoke execute on function account_purge() from service_role;

commit;
