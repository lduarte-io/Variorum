-- Variorum sync mirror — the Phase 13 lockstep event (Step A1; SyncSpec §12).
-- Run AFTER 01 + 02 + 03 + 04 + 05, via the author's PAT (the 9c precedent;
-- the deploy is PRE-AUTHORIZED — sitting-7 ruling R53: "just do the schema
-- deploy") or the SQL-editor paste. ONE deploy covers the event's FOUR
-- additive client changes (migrations v1_8 block_comment, v1_9
-- block.presentation, v1_10 reading_section + reading_post.section_id,
-- v1_11 reading.word_target) on the reworked RPC allowlists.
--
-- THE CHOREOGRAPHY (SyncSpec §12; R53's shape — the phone app is REMOVED,
-- so the lockstep is MIRROR → MAC only):
--   (1) this file runs on the mirror FIRST. The moment its final statement
--       bumps the marker to 3, the still-installed pre-13 Mac build VISIBLY
--       refuses to sync (outbox intact, cursor unmoved) until this phase's
--       build replaces it — the accepted R53 consequence; the author is not
--       using the app during the phase.
--   (2) THEN the Mac client updates (migrations v1_8–v1_11 run on next
--       launch of the phase's build).
--   (3) only then may any client write new-schema rows. The phone reinstalls
--       onto current schema whenever the author next wants it (Phase 15's
--       orbit) — no un-updated client exists today.
--
-- THE DUMBNESS IS STILL LOAD-BEARING (SyncSpec §2): new mirror tables carry
-- PRIMARY KEY only — no other uniqueness, no FKs, no checks. block_comment
-- and reading_section deliberately have NO live-unique indexes client-side
-- either (no natural keys), so no new repair classes exist.
--
-- RLS POSTURE (the 04/05 pattern, verified not assumed): each new table
-- repeats the per-table pattern — RLS enabled with no policies, direct
-- privileges revoked, the SECURITY DEFINER RPCs the only doors.
-- block_comment carries owner_id and joins the owner_tables guard arrays;
-- reading_section is a child table (no owner column — Phase 14's
-- parent-join isolation debt, same as container_block et al.).

-- ---------------------------------------------------------------------------
-- 1. block_comment (client migration v1_8) — working notes on a block.
--    Metadata CAS text (S5 stays scoped to variant.working_text); no
--    uniqueness, no repair class; tombstoned; deleted comments resurrect
--    client-side.
-- ---------------------------------------------------------------------------

create table block_comment (
  id                text primary key,
  owner_id          text,
  block_id          text,
  text              text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp()
);

create trigger stamp_seq_block_comment before insert or update on block_comment
  for each row execute function stamp_server_seq();
create index idx_seq_block_comment on block_comment (server_seq);

alter table block_comment enable row level security;
revoke all on block_comment from anon, authenticated;


-- ---------------------------------------------------------------------------
-- 2. block.presentation (client migration v1_9) — the callout frame
--    (sitting rulings R16/R27): block-level presentation metadata,
--    identity-level like block.name. Additive nullable column; plain
--    metadata CAS, no uniqueness, no repair.
-- ---------------------------------------------------------------------------

alter table block add column if not exists presentation text;

-- ---------------------------------------------------------------------------
-- 3. reading_section (client migration v1_10) — real chapters (R28: "a
--    reading section table is fine; we don't need nesting readings").
--    Ordered metadata rows; position races converge by CAS like every
--    fractional index. reading_post gains section_id — a dangling pointer
--    reads as unsectioned client-side (the chosen-variant fallback class).
-- ---------------------------------------------------------------------------

create table reading_section (
  id                text primary key,
  reading_id        text,
  name              text,
  position          text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp()
);

create trigger stamp_seq_reading_section before insert or update on reading_section
  for each row execute function stamp_server_seq();
create index idx_seq_reading_section on reading_section (server_seq);

alter table reading_section enable row level security;
revoke all on reading_section from anon, authenticated;

alter table reading_post add column if not exists section_id text;

-- ---------------------------------------------------------------------------
-- 4. reading.word_target (client migration v1_11) — bounded-length
--    notebooks in WORDS (§14 item 10; the max_posts sibling). A display
--    target, never an add-time refusal — enforcement would need word
--    counts at membership time, which edits immediately invalidate.
-- ---------------------------------------------------------------------------

alter table reading add column if not exists word_target bigint;
