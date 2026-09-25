-- Variorum sync mirror — SIGNUP AUTO-ENTITLEMENT (2026-09-24, her word at
-- the 13y window's tail: "yeah, i'd do it now").
--
-- WHY: her ruled launch posture (2026-08-26, the launch-strategy sitting —
-- "sync is open at v1… free for 3 months") always IMPLIED signup ⇒ entitled,
-- but the mechanism was never built: 14c shipped the entitlement gate with a
-- one-time deploy seed (existing users only) and the manual `entitlement_set`
-- door. This artifact closes that gap for the friends beta AND for launch:
-- every new auth user is granted `hosted_sync` at signup, open-ended.
-- 13t (the sync tier) re-shapes the semantics when the paywall arrives —
-- its ruled trial honors each account's SIGNUP DATE (auth.users.created_at),
-- which this artifact does not touch, so nothing here complicates the trial
-- math. The record rides 13t's row in notes/FuturePhases.md (dated line).
--
-- WHAT IT DOES NOT CHANGE: no marker (entitlement is server-only; no client
-- semantics move; both apps already read the gate — the 14d pin). Her
-- per-account kill-switch survives untouched: `entitlement_set(uid,
-- 'hosted_sync', false)` deletes the row and the next RPC refuses typed.
--
-- IDEMPOTENT BY CONSTRUCTION (safe to re-run whole): create-or-replace +
-- drop-trigger-if-exists + on-conflict-do-nothing everywhere. One
-- transaction; a raised error rolls the whole file back.
--
-- Run via the stored-PAT query road as the deployer (postgres — which owns
-- `entitlement` and holds the standing auth-schema DML road the
-- `account_purge` precedent records).

begin;

-- The trigger function: SECURITY DEFINER (runs as postgres, the entitlement
-- table's owner), search_path pinned, RETURNS trigger. It grants exactly
-- the one feature the gate reads, open-ended, and never overwrites an
-- existing row (a deliberate `entitlement_set` state wins over the default).
create or replace function signup_auto_entitle() returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  insert into entitlement (user_id, feature, source)
  values (new.id, 'hosted_sync', 'signup-auto')
  on conflict (user_id, feature) do nothing;
  return new;
end;
$$;

-- The PUBLIC-execute footgun pair (the memo §2 discipline, every new
-- function): trigger firing never checks the DML role's EXECUTE, so this
-- costs nothing and leaves no RPC-shaped door.
revoke execute on function signup_auto_entitle() from public, anon, authenticated;

drop trigger if exists variorum_signup_auto_entitle on auth.users;
create trigger variorum_signup_auto_entitle
  after insert on auth.users
  for each row execute function signup_auto_entitle();

-- The backfill: anyone who signed up between 14c's seed and this trigger.
-- (At authoring time: exactly one auth user, hers, already entitled by the
-- 14c seed — this is a no-op today and insurance tomorrow.)
insert into entitlement (user_id, feature, source)
select u.id, 'hosted_sync', 'signup-auto-backfill'
from auth.users u
on conflict (user_id, feature) do nothing;

commit;

-- Verification (read-only; run after deploy):
--   select t.tgname from pg_trigger t
--     join pg_class c on c.oid = t.tgrelid
--     join pg_namespace n on n.oid = c.relnamespace
--     where n.nspname = 'auth' and c.relname = 'users' and not t.tgisinternal;
--                                          -- variorum_signup_auto_entitle present
--   select prosecdef, pg_get_userbyid(proowner)
--     from pg_proc where proname = 'signup_auto_entitle';
--                                          -- true | postgres
--   select (select count(*) from auth.users) =
--          (select count(*) from entitlement where feature = 'hosted_sync');
--                                          -- true (every user entitled)
--   plus maintenance/14c-post-deploy-grant-sweep.sql — every row OK/INFO
--   (signup_auto_entitle() joins the sweep's trigger-function INFO rows).
--   The BEHAVIORAL proof is the first real signup: its entitlement row
--   appears with source 'signup-auto' — check it when the first friend
--   arrives (or at any admin-created probe account).
