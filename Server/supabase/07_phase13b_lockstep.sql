-- Variorum sync mirror — the Phase 13b lockstep event (Stage 4, Batch 4F;
-- SyncSpec §12). Run AFTER 01 + 02 + 03 + 04 + 05 + 06, via the author's
-- PAT (the 9c precedent). The deploy is PRE-AUTHORIZED — the author's 13b
-- EOL addendum, 2026-07-22: "you also have my permission to do the mirror
-- deploys when you get there" — and is executed by the STAGE 4 ORCHESTRATOR
-- at the consolidated post-ladder window, never by a batch implementer.
-- ONE deploy covers the event's ONE additive client change (migration
-- v1_12 `container.word_target` — the per-post twin of v1_11's reading
-- column; author ruling S4-28.1, ledger N36).
--
-- THE CHOREOGRAPHY (SyncSpec §12; the R53 shape — the phone app remains
-- REMOVED, so the lockstep is MIRROR → MAC only):
--   (1) this file runs on the mirror FIRST. The moment its final statement
--       bumps the marker to 4, the still-installed marker-3 Mac build
--       VISIBLY refuses to sync (outbox intact, cursor unmoved) until the
--       post-4F Release build replaces it at /Applications — the accepted
--       consequence, same as the Phase 13 event's.
--   (2) THEN the Mac client updates (migration v1_12 runs on next launch
--       of the Stage 4 build).
--   (3) only then may any client write `container.word_target`. The phone
--       reinstalls onto current schema whenever the author next wants it
--       (Phase 15's orbit) — no un-updated client exists today.
--
-- NO RPC REWORK RIDES THIS EVENT (deliberate): v1_12 adds a COLUMN to an
-- already-allowlisted table — 06's deployed sync_push/sync_pull bodies
-- move whole rows via to_jsonb / jsonb_populate_record, which carry new
-- columns automatically, and `container` already sits in both `allowed`
-- and `owner_tables` arrays. The allowlists, owner guards, A5 visibility
-- horizon, and demotion posture all stand exactly as 06 deployed them.
--
-- THE DUMBNESS IS STILL LOAD-BEARING (SyncSpec §2): the new column is a
-- bare nullable bigint — no constraint, no check, no default semantics.

-- ---------------------------------------------------------------------------
-- 1. container.word_target (client migration v1_12) — the per-POST
--    words-based extent target (13b S4-28.1; display/progress only, never
--    an add/type-time refusal — word counts change with every edit).
--    Additive nullable column; plain metadata CAS, no uniqueness, no
--    repair rule.
-- ---------------------------------------------------------------------------

alter table container add column if not exists word_target bigint;

-- ---------------------------------------------------------------------------
-- 2. The lockstep marker (SyncSpec §12): sync_meta and sync_schema_version()
--    already exist (05); nothing here recreates them. THE MARKER UPDATE IS
--    DELIBERATELY THE LAST STATEMENT OF THIS FILE: a partially-executed
--    deploy never advertises the new version before the column exists.
-- ---------------------------------------------------------------------------

-- LAST STATEMENT (see above): the mirror now speaks lockstep version 4.
-- Must equal SyncSchema.lockstepVersion in the client — the in-repo DDL
-- pin fails the build if they drift.
insert into sync_meta (key, value) values ('lockstep_version', '4')
  on conflict (key) do update set value = excluded.value;
