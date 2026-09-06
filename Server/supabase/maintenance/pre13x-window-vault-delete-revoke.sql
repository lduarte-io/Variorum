-- pre-13x — THE WINDOW's one repair (2026-09-06, the orchestrator, immediately after 11 deployed at marker 8).
--
-- WHAT THE SWEEP FOUND: `maintenance/14c-post-deploy-grant-sweep.sql` (extended by batch 1b for the vault's
-- privilege set) reported ONE mismatch after 11 landed — `key_vault.privilege:authenticated:DELETE` expected false,
-- actual TRUE. No lockstep file ever granted it: 08 wrote `grant select, insert, update on key_vault to
-- authenticated` on top of Supabase's DEFAULT PRIVILEGES (`grant all` to anon/authenticated/service_role on every
-- new table in `public`), and only `anon` was ever `revoke all`'d — so `authenticated` kept DELETE from 14b on.
-- WHAT IT OPENED: nothing — `key_vault` has NO DELETE policy under RLS (14b's "NO delete door"), so a session's
-- DELETE affected zero rows. The privilege was a door frame without a door; the sweep's doctrine (the vault's only
-- delete is `account_purge`, as `postgres`) is now true at the privilege layer too.
-- THE FORM: the 14c gate repairs' (`14c-gate-grant-tidy.sql`) — one privilege moved, verified by the sweep re-run.
-- Run ONCE on the production mirror via the Management-API query road; idempotent (a repeated revoke is a no-op).

begin;

revoke delete on key_vault from authenticated;

commit;

-- Verification (read-only): expect (false, false, true).
select has_table_privilege('authenticated', 'public.key_vault', 'DELETE') as authenticated_delete,
       has_table_privilege('authenticated', 'public.key_vault', 'UPDATE') as authenticated_update,
       has_table_privilege('authenticated', 'public.key_vault', 'SELECT') as authenticated_select;
