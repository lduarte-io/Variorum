-- Variorum sync mirror — the Phase 13n-b PRIVATE MARK lockstep event
-- (SyncSpec §12; her ruling R-13nb-4 at the 13n-b kickoff-day sitting,
-- 2026-10-09 — the binding record is the sitting record + design addendum in
-- `notes/plans/phase-13n-b-mcp-door.md`: a per-NOTE and per-BOOK privacy
-- mark so a book or note can be fenced from AI without being journal-typed;
-- her words raising it: "should we add a designation or boook setting like
-- 'Private' … that might be a small sync event but the stage is clear for
-- that"). Run AFTER 01–15. ONE transaction; the marker update is the last
-- statement inside it (12's discipline, kept).
--
-- THE DEPLOY RUNS ONLY AT THE AUTHOR'S WINDOW (CLAUDE.md's lockstep rule;
-- the 13n-b closeout window's checklist): mirror first, then her Mac
-- Release install and the phone build in the SAME window — the moment the
-- marker bumps to 13, every installed marker-12 build VISIBLY refuses to
-- sync (outbox intact, cursor unmoved — the §12 refusal grammar). Always
-- behind the A1 rail.
--
-- WHAT THIS EVENT SHIPS:
--   * `container.ai_private_at text` + `reading.ai_private_at text` — TWO
--     additive, nullable, constraint-free mirror columns (SyncSpec §2's
--     dumb mirror), the `archived_at` class. The AI fence's third leg
--     (journal profile · journal/daily membership · the private mark): a
--     marked note is fenced everywhere; a live private book fences every
--     live member — privacy wins ties; gatherings refuse the mark
--     operations-side. PLAIN under E2EE — bare timestamps; disclosed
--     structure only (that something is marked, never which or what).
--   * NOTHING ELSE server-side: no new table, no RPC change, so the
--     allowlists, the owner-table arrays, the truncate/purge registries and
--     the ciphertext registry are all UNCHANGED (table-level; these columns
--     are plain).
--   * the client side rides the CLIENT migration (v1_25) + 13n-b U2's op
--     family: the set/clear mark operations, the fence-leg wiring, the
--     Private faces. No data migration anywhere — nothing is private at
--     birth. No new §7 repair (plain CAS metadata; NULL reads NOT private).
--   * the marker: 12 → 13. It moves because a marker-12 client's CAS
--     whole-row push would silently null `ai_private_at` out from under a
--     marker-13 writer (13i-e's reasoning, verbatim).

-- ---------------------------------------------------------------------------
-- 0. The re-run guard (12's shape): refuses when the mirror already speaks
--    marker 13 or carries either column, and when 15 has not run.
-- ---------------------------------------------------------------------------

do $rerun_guard$
declare
  override        text    := nullif(current_setting('variorum.allow_16_rerun', true), '');
  deployed_marker int     := 1;
  container_here  boolean := exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'container'
      and column_name = 'ai_private_at');
  reading_here    boolean := exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'reading'
      and column_name = 'ai_private_at');
begin
  if override = 'yes-rerun-the-private-event' then
    raise notice 'VARIORUM 16 RE-RUN OVERRIDE ACCEPTED — re-applying the private-mark event.';
    return;
  end if;

  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;

  if deployed_marker >= 13 or container_here or reading_here then
    raise exception using
      message = 'VARIORUM_16_ALREADY_DEPLOYED: this mirror has already run 16 (lockstep marker '
                || deployed_marker || '; container.ai_private_at '
                || case when container_here then 'present' else 'absent' end
                || '; reading.ai_private_at '
                || case when reading_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_16_rerun = ''yes-rerun-the-private-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;

  if deployed_marker < 12 then
    raise exception using
      message = 'VARIORUM_16_PREREQUISITE_MISSING: this mirror is at lockstep marker '
                || deployed_marker || ' — run 15 (the book-archive event) first.';
  end if;
end
$rerun_guard$;

begin;

-- ---------------------------------------------------------------------------
-- 1. The two additive columns — nullable, no default, no constraint
--    (SyncSpec §2: the client reads an absent/NULL value as NOT PRIVATE;
--    pinned by this phase's suites). The stamp trigger re-seqs nothing
--    here: a bare `add column` writes no row.
-- ---------------------------------------------------------------------------

alter table container add column ai_private_at text;
alter table reading   add column ai_private_at text;

-- ---------------------------------------------------------------------------
-- 2. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
--    TRANSACTION, immediately before commit — a partial deploy can never
--    advertise the new version. The mirror now speaks lockstep version 13.
--    Must equal SyncSchema.lockstepVersion in the client — the in-repo
--    DDL pin fails the build if they drift.
-- ---------------------------------------------------------------------------

insert into sync_meta (key, value) values ('lockstep_version', '13')
  on conflict (key) do update set value = excluded.value;

commit;

-- Verification (read-only; the window runs these — the 13n-b closeout
-- checklist):
--   select sync_schema_version();                                       -- 13
--   select table_name, column_name, data_type from information_schema.columns
--     where column_name = 'ai_private_at';                              -- two rows, text
--   select count(*) from container where ai_private_at is not null;     -- 0 at the window
--   select count(*) from reading   where ai_private_at is not null;     -- 0 at the window;
--                                                                       -- her marks arrive by round
