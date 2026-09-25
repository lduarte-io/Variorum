-- Variorum sync mirror — SIGNUP AUTO-ENTITLEMENT (2026-09-24, her word at
-- the 13y window's tail: "yeah, i'd do it now"). REVISED SAME DAY at the
-- act's Opus cold review (1 MAJOR / 5 MINOR / 2 NIT — dispositions in
-- `notes/plans/13y-deploy-checklist.md` §10's tail-act record): the spent
-- backfill REMOVED (F-1), the signup-outage containment arm and the
-- anonymous guard added, the verification tail corrected. The `beta-`
-- filename is HISTORICAL (the review's NIT-2): the mechanism is permanent
-- until 13t re-shapes it — the name stays because three records cite the
-- path and a rename buys nothing functional.
--
-- WHY: her ruled launch posture (2026-08-26, the launch-strategy sitting —
-- "sync is open at v1… free for 3 months") always IMPLIED signup ⇒ entitled,
-- but the mechanism was never built: 14c shipped the entitlement gate with a
-- one-time deploy seed (existing users only) and the manual `entitlement_set`
-- door. This artifact closes that gap for the friends beta AND for launch:
-- every new auth user is granted `hosted_sync` at signup, open-ended.
-- 13t (the sync tier) re-shapes the semantics when the paywall arrives —
-- its recorded per-user-trial LEAN (decided with the purchase channel, not
-- yet ruled) keys on signup dates (`auth.users.created_at`), which this
-- artifact does not touch. The record rides 13t's row in
-- notes/FuturePhases.md (dated line). NOTE THE SUITE SCOPE (the review's
-- F-6, QUESTIONS #145(b)): auth.users is the SUITE's user table — a
-- Fragments-only signup mints a Variorum hosted_sync row too; harmless
-- under open-at-v1, product silence for 13t's kickoff to answer.
--
-- THE COUPLING, STATED (the review's F-2): an AFTER INSERT trigger error
-- aborts GoTrue's insert — signup for the WHOLE SUITE would fail with
-- "Database error saving new user". PL/pgSQL bodies are not dependency-
-- tracked, so a future `entitlement` re-shape (13t's) that renames the
-- table, changes the PK, or adds a bare NOT NULL column would break every
-- signup while passing its own deploy. Two defenses: the containment arm
-- in the function body below (a failure degrades to an UNENTITLED signup —
-- the typed VARIORUM_NO_ENTITLEMENT refusal, repairable by
-- `entitlement_set` — never a signup outage; the warning lands in the
-- Postgres logs), and the dated coupling note on 13t's row.
--
-- WHAT IT DOES NOT CHANGE: no marker (entitlement is server-only; no client
-- semantics move; both apps already read the gate — the 14d pin). Her
-- per-account kill-switch survives untouched: `entitlement_set(uid,
-- 'hosted_sync', false)` deletes the row and the next RPC refuses typed.
-- The trigger fires ONLY at INSERT on auth.users, so a revoked account is
-- never re-granted — BY THE ARTIFACT AS A WHOLE, not just the trigger: the
-- original deploy's backfill (which would have re-granted revoked accounts
-- on a re-run — the review's F-1, the MAJOR) ran ONCE as a verified no-op
-- and is REMOVED from this file. A future entitlement gap (e.g. signups
-- landing while the trigger was lost) is repaired by a DELIBERATE targeted
-- act scoped to the gap's `created_at` window — never a blanket
-- every-user insert, which cannot distinguish a gap from a revocation.
--
-- IDEMPOTENT AND RE-RUN-SAFE (now without qualification): create-or-replace
-- + drop-trigger-if-exists; a re-run writes no entitlement rows at all.
-- One transaction; a raised error rolls the whole file back.
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
  -- Anonymous sign-ins (unused today — the runbook's §5 posture) never
  -- earn a grant; if that toggle ever flips, sync stays entitlement_set's
  -- to give (the review's NIT-1).
  if coalesce(new.is_anonymous, false) then
    return new;
  end if;
  insert into entitlement (user_id, feature, source)
  values (new.id, 'hosted_sync', 'signup-auto')
  on conflict (user_id, feature) do nothing;
  return new;
exception when others then
  -- THE CONTAINMENT ARM (the review's F-2): a bookkeeping failure must
  -- degrade to an unentitled signup (typed, visible, repairable), never
  -- abort the suite's signup door. The warning is the operator's signal.
  raise warning 'signup_auto_entitle failed for %: % — signup proceeds unentitled; repair via entitlement_set', new.id, sqlerrm;
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

commit;

-- Verification (read-only; run after deploy):
--   select t.tgname from pg_trigger t
--     join pg_class c on c.oid = t.tgrelid
--     join pg_namespace n on n.oid = c.relnamespace
--     where n.nspname = 'auth' and c.relname = 'users' and not t.tgisinternal;
--                                          -- variorum_signup_auto_entitle present
--     (the standing sweep now carries this as a FACT ROW —
--      `trigger:auth.users:variorum_signup_auto_entitle` — so a lost
--      trigger can never read clean; the review's F-4)
--   select prosecdef, pg_get_userbyid(proowner)
--     from pg_proc where proname = 'signup_auto_entitle';
--                                          -- true | postgres
--   THE ENTITLEMENT COVERAGE READ (the review's F-5 — a bare count
--   comparison is the wrong shape: an orphaned row and an unentitled user
--   cancel out, and every kill-switch use breaks the equality forever):
--   select count(*) from auth.users u
--     where not exists (select 1 from entitlement e
--                       where e.user_id = u.id and e.feature = 'hosted_sync');
--                                          -- 0, or EXACTLY the accounts she
--                                          -- has deliberately revoked
--   select count(*) from entitlement e
--     where not exists (select 1 from auth.users u where u.id = e.user_id);
--                                          -- 0 (no orphaned grants; the
--                                          -- 2026-09-24 probe left none —
--                                          -- its entitlement row was
--                                          -- deleted BEFORE its auth row,
--                                          -- both via the query road)
--   plus maintenance/14c-post-deploy-grant-sweep.sql — every row OK/INFO
--   (signup_auto_entitle() is a trigger-function INFO row; the trigger
--   itself is an asserted fact row).
--   BEHAVIORAL PROOF: LANDED 2026-09-24 (same day) — a probe signup
--   through the real public door fired the trigger (source 'signup-auto'
--   on the minted row); the probe account was then deleted whole
--   (entitlement row first, auth row second). The fake harness cannot
--   reach an auth.users trigger (the recorded 13j PL/pgSQL class), so
--   live evidence IS the behavioral test for this artifact.
