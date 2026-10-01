-- Variorum sync mirror — the Phase 13i-c OUTFLOW lockstep event (SyncSpec
-- §12; the execution plan `notes/plans/phase-13i-c-owned-finished-sealed.md`
-- §2 — her kickoff ruling R-13ic-1, after her five-year-view advice ask: the
-- book's OUTFLOW becomes a CHOSEN, OPTIONAL SET of tags, independent of the
-- intake rule, stored as ONE JSON column). Run AFTER 01–13. ONE transaction;
-- the marker update is the last statement inside it (12's discipline, kept).
--
-- THE DEPLOY RUNS ONLY AT THE AUTHOR'S WINDOW (CLAUDE.md's lockstep rule;
-- the 13i-c plan §11 is the checklist): mirror first, then her Mac Release
-- install and the phone build in the SAME window — the moment the marker
-- bumps to 11, every installed marker-10 build VISIBLY refuses to sync
-- (outbox intact, cursor unmoved — the §12 refusal grammar). Always behind
-- the A1 rail.
--
-- WHAT THIS EVENT SHIPS:
--   * `reading.auto_tag_ids text` — the ONE additive, nullable, constraint-
--     free mirror column (SyncSpec §2's dumb mirror). A JSON array of tag
--     ids; NULL = no outflow. PLAIN under E2EE — ids, content-free, the
--     class of the `auto_tag_id` column it retires (PROVISIONAL P-13ic-8).
--   * NOTHING ELSE server-side: no new table, so the allowlists, the
--     owner-table arrays, the truncate/purge registries and the ciphertext
--     registry are all UNCHANGED (they are table-level, and this column is
--     plain). `auto_tag_id` STAYS a column (retired-as-read client-side;
--     SQLite refuses to drop a column carrying a foreign key).
--   * the client's recast rides the CLIENT migration (v1_20): every live
--     book's single outflow carried into a one-element array, and every
--     live rule-less gathering moved to the Trash (her R-13ic-4) — both
--     travel as ordinary row updates after the window.
--   * the marker: 10 → 11.

-- ---------------------------------------------------------------------------
-- 0. The re-run guard (12's shape): refuses when the mirror already speaks
--    marker 11 or carries the column, and when 13 has not run.
-- ---------------------------------------------------------------------------

do $rerun_guard$
declare
  override        text    := nullif(current_setting('variorum.allow_14_rerun', true), '');
  deployed_marker int     := 1;
  column_here     boolean := exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'reading'
      and column_name = 'auto_tag_ids');
begin
  if override = 'yes-rerun-the-outflow-event' then
    raise notice 'VARIORUM 14 RE-RUN OVERRIDE ACCEPTED — re-applying the outflow event.';
    return;
  end if;

  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;

  if deployed_marker >= 11 or column_here then
    raise exception using
      message = 'VARIORUM_14_ALREADY_DEPLOYED: this mirror has already run 14 (lockstep marker '
                || deployed_marker || '; reading.auto_tag_ids '
                || case when column_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_14_rerun = ''yes-rerun-the-outflow-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;

  if deployed_marker < 10 then
    raise exception using
      message = 'VARIORUM_14_PREREQUISITE_MISSING: this mirror is at lockstep marker '
                || deployed_marker || ' — run 13 (the wings/shelves/books event) first.';
  end if;
end
$rerun_guard$;

begin;

-- ---------------------------------------------------------------------------
-- 1. The one additive column — nullable, no default, no constraint (SyncSpec
--    §2: the client reads an absent/NULL value as NO outflow; pinned by
--    `Phase13icOutflowTests`). The stamp trigger re-seqs nothing here: a
--    bare `add column` writes no row.
-- ---------------------------------------------------------------------------

alter table reading add column auto_tag_ids text;

-- ---------------------------------------------------------------------------
-- 2. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
--    TRANSACTION, immediately before commit — a partial deploy can never
--    advertise the new version. The mirror now speaks lockstep version 11.
--    Must equal SyncSchema.lockstepVersion in the client — the in-repo
--    DDL pin fails the build if they drift.
-- ---------------------------------------------------------------------------

insert into sync_meta (key, value) values ('lockstep_version', '11')
  on conflict (key) do update set value = excluded.value;

commit;

-- Verification (read-only; the window runs these — the 13i-c plan §11):
--   select sync_schema_version();                                    -- 11
--   select column_name, data_type from information_schema.columns
--     where table_name = 'reading' and column_name = 'auto_tag_ids'; -- one row, text
--   select count(*) from reading where auto_tag_ids is not null;     -- 0 at the window;
--                                                                    -- her first round carries the arrays
