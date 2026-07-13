-- Variorum sync mirror — the Phase 11 lockstep event (Step A1; SyncSpec §12).
-- Run AFTER 01 + 02 + 03 + 04, in the SQL editor or via the author's PAT
-- (the 9c precedent) — NEVER headless. ONE deploy covers the event's FOUR
-- additive client changes (migrations v1_5 canvas_layout, v1_6 block.name,
-- v1_7 lens + lens_choice) plus the §12 version-check mechanism ("ships
-- with the first post-sync migration that needs it" — this one).
--
-- THE CHOREOGRAPHY (SyncSpec §12, to the letter):
--   (1) this file runs on the mirror FIRST. It is SAFE for still-deployed
--       old clients: the new tables serve zero rows until a new client
--       writes them; the reworked RPCs behave identically on the old
--       tables; old clients carry no schema marker check and keep syncing.
--   (2) THEN every client updates (both devices run migrations v1_5–v1_7).
--       A new client against an un-migrated mirror REFUSES to sync (the
--       schema marker check — visible refusal, outbox intact, cursor
--       unmoved); stalling is free, guessing is forbidden.
--   (3) only then may any client write new-schema rows.
--
-- THE DUMBNESS IS STILL LOAD-BEARING (SyncSpec §2): new mirror tables carry
-- PRIMARY KEY only — no other uniqueness, no FKs, no checks. The client's
-- live-unique indexes get deterministic apply-time repairs, which REQUIRE
-- the server to accept both sides of a race.
--
-- RLS POSTURE (verified against the deployed 04_auth_rls.sql, not assumed):
-- each new table repeats 04's per-table pattern — RLS enabled with no
-- policies, direct privileges revoked, the SECURITY DEFINER RPCs the only
-- doors. canvas_layout and lens carry owner_id and join 04's owner_tables
-- guard arrays (incoming pushes must carry owner_id = auth.uid(); stored
-- foreign/NULL-owner rows are never overwritten or echoed; pulls serve only
-- the caller's rows). lens_choice is a child table (no owner column —
-- Phase 14's parent-join isolation debt, same as container_block et al.).

-- ---------------------------------------------------------------------------
-- 1. canvas_layout (client migration v1_5) — canvas card positions.
--    Metadata-CAS positions; live-unique (container_id, block_id) repairs
--    client-side as a pure duplicate (keep smaller id).
-- ---------------------------------------------------------------------------

create table canvas_layout (
  id                text primary key,
  owner_id          text,
  container_id      text,
  block_id          text,
  x                 double precision,
  y                 double precision,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp()
);

create trigger stamp_seq_canvas_layout before insert or update on canvas_layout
  for each row execute function stamp_server_seq();
create index idx_seq_canvas_layout on canvas_layout (server_seq);

alter table canvas_layout enable row level security;
revoke all on canvas_layout from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 2. block.name (client migration v1_6) — the optional per-block name.
--    Additive nullable column; plain metadata CAS, no uniqueness, no repair.
-- ---------------------------------------------------------------------------

alter table block add column if not exists name text;
