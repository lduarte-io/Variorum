-- Variorum sync mirror — the Phase 13i-e BOOK ARCHIVE lockstep event
-- (SyncSpec §12; the execution plan `notes/plans/phase-13i-e-daily-journal.md`
-- — her kickoff ruling R-13ie-1: "a book is a set of rules + ordering now so
-- it makes sense to archive it … I'm fine with another sync schema event to
-- do this right"). Run AFTER 01–14. ONE transaction; the marker update is the
-- last statement inside it (12's discipline, kept).
--
-- THE DEPLOY RUNS ONLY AT THE AUTHOR'S WINDOW (CLAUDE.md's lockstep rule;
-- `notes/plans/13i-e-deploy-checklist.md` is the checklist): mirror first,
-- then her Mac Release install and the phone build in the SAME window — the
-- moment the marker bumps to 12, every installed marker-11 build VISIBLY
-- refuses to sync (outbox intact, cursor unmoved — the §12 refusal grammar).
-- Always behind the A1 rail.
--
-- WHAT THIS EVENT SHIPS:
--   * `reading.archived_at text` — the ONE additive, nullable, constraint-
--     free mirror column (SyncSpec §2's dumb mirror). Domain archive for
--     books and gatherings — the `container.archived_at` class,
--     kept-but-out-of-view, keep-forever (never a step toward deletion).
--     PLAIN under E2EE — a bare timestamp; disclosed structure only (that
--     a book is put away, never which one or what it holds).
--   * NOTHING ELSE server-side: no new table, no RPC change, so the
--     allowlists, the owner-table arrays, the truncate/purge registries and
--     the ciphertext registry are all UNCHANGED (they are table-level, and
--     this column is plain).
--   * the client side rides the CLIENT migration (v1_21) + this phase's op
--     family: archive/unarchive/archive-with-notes, the auto-ingestion
--     pause, the daily Journal's never-hard-delete guard and derived
--     designation. No data migration anywhere — nothing is archived at
--     birth.
--   * the marker: 11 → 12. It moves because a marker-11 client's CAS
--     whole-row push would silently null `archived_at` out from under a
--     marker-12 writer.

-- ---------------------------------------------------------------------------
-- 0. The re-run guard (12's shape): refuses when the mirror already speaks
--    marker 12 or carries the column, and when 14 has not run.
-- ---------------------------------------------------------------------------

do $rerun_guard$
declare
  override        text    := nullif(current_setting('variorum.allow_15_rerun', true), '');
  deployed_marker int     := 1;
  column_here     boolean := exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'reading'
      and column_name = 'archived_at');
begin
  if override = 'yes-rerun-the-archive-event' then
    raise notice 'VARIORUM 15 RE-RUN OVERRIDE ACCEPTED — re-applying the book-archive event.';
    return;
  end if;

  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;

  if deployed_marker >= 12 or column_here then
    raise exception using
      message = 'VARIORUM_15_ALREADY_DEPLOYED: this mirror has already run 15 (lockstep marker '
                || deployed_marker || '; reading.archived_at '
                || case when column_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_15_rerun = ''yes-rerun-the-archive-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;

  if deployed_marker < 11 then
    raise exception using
      message = 'VARIORUM_15_PREREQUISITE_MISSING: this mirror is at lockstep marker '
                || deployed_marker || ' — run 14 (the outflow event) first.';
  end if;
end
$rerun_guard$;

begin;

-- ---------------------------------------------------------------------------
-- 1. The one additive column — nullable, no default, no constraint (SyncSpec
--    §2: the client reads an absent/NULL value as NOT ARCHIVED; pinned by
--    this phase's suites). The stamp trigger re-seqs nothing here: a bare
--    `add column` writes no row.
-- ---------------------------------------------------------------------------

alter table reading add column archived_at text;

-- ---------------------------------------------------------------------------
-- 2. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
--    TRANSACTION, immediately before commit — a partial deploy can never
--    advertise the new version. The mirror now speaks lockstep version 12.
--    Must equal SyncSchema.lockstepVersion in the client — the in-repo
--    DDL pin fails the build if they drift.
-- ---------------------------------------------------------------------------

insert into sync_meta (key, value) values ('lockstep_version', '12')
  on conflict (key) do update set value = excluded.value;

commit;

-- Verification (read-only; the window runs these — the 13i-e checklist):
--   select sync_schema_version();                                    -- 12
--   select column_name, data_type from information_schema.columns
--     where table_name = 'reading' and column_name = 'archived_at';  -- one row, text
--   select count(*) from reading where archived_at is not null;      -- 0 at the window;
--                                                                    -- her archives arrive by round
