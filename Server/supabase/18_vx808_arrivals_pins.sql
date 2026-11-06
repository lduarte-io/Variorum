-- Variorum sync mirror — the VX-808 ARRIVALS & PINS lockstep event
-- (SyncSpec §12; the run record `notes/plans/fixes/vx-808-arrivals-books.md`
-- §5 — the architect's shape under her VX-821 ruling, "the reason is SYNCED —
-- a nullable column on the arrival row, riding the run's ONE SyncSpec §12
-- lockstep event TOGETHER with VX-803's pin (one marker bump)", and her
-- VX-803 ruling, "a nullable pin mark on `reading_post`, synced, the SAME
-- lockstep event as the reason column"). Run AFTER 01–17 (and the
-- maintenance artifacts that ride after 17 — the pg_temp belt and the VX-495
-- keyset pull; this file creates and alters NO function, so it never resets a
-- SET clause they assert). ONE transaction; the marker update is the last
-- statement inside it (12's discipline, kept).
--
-- THE DEPLOY RUNS ONLY AT THE AUTHOR'S WINDOW (CLAUDE.md's lockstep rule; the
-- VX-808 closeout window, at the stage's FINISH per her order ruling): mirror
-- first, then her Mac Release installs in the SAME window — the moment the
-- marker bumps to 15, every installed marker-14 build VISIBLY refuses to sync
-- (outbox intact, cursor unmoved — the §12 refusal grammar); the phone
-- follows the mobile track. Always behind the A1 rail. HELD until then: from
-- the run's merge every main build speaks marker 15 and refuses production
-- sync until this lands.
--
-- WHAT THIS EVENT SHIPS:
--   * `reading_post.arrival_provenance text` — WHY an arrival waits: the
--     client's canonical JSON `{kind, client?, reason?}` (VX-821's
--     why-it-waits + VX-811's optional per-note reason, one column). ENCRYPTED
--     under E2EE (an AI-authored reason is prose; the kind and client ride
--     inside the one sealed value), so the mirror stores only `e1:` AEAD
--     ciphertext there — the column needs no server type change (the
--     existing TEXT convention). No server-side ciphertext registry exists
--     to join: its one home was `key_vault_update`'s rotation completion
--     guard, which 17 retired with rotation itself.
--   * `reading_post.pinned_at text` — the membership pin (non-NULL = pinned,
--     the stamp doubling as since-when). PLAIN — a bare timestamp, the
--     `archived_at` / `ai_private_at` class; disclosed structure only (that a
--     membership is pinned, never which words).
--   * Both are ADDITIVE, NULLABLE, CONSTRAINT-FREE mirror columns (SyncSpec
--     §2's dumb mirror — no uniqueness, no FK). NOTHING ELSE server-side: no
--     new table, no RPC change, so the allowlists, the owner-table arrays and
--     the truncate/purge registries are all UNCHANGED (table-level).
--   * No new §7 repair client-side (no new live-unique index; both columns
--     are CAS metadata, server-wins). Recorded and accepted: the status-aware
--     `reading_post` pair dedupe keeps the smaller id and ITS column values
--     ride.
--   * the client side rides the CLIENT migration (v1_37) + this run's op
--     family (the propose act, the arrival doors' provenance, the pin op). No
--     data migration anywhere — nothing is pinned or provenanced at birth.
--   * the marker: 14 → 15. It moves because a marker-14 client's CAS
--     whole-row push would silently null either column out from under a
--     marker-15 writer (13i-e's reasoning, verbatim).

-- ---------------------------------------------------------------------------
-- 0. The re-run guard (12's shape): refuses when the mirror already speaks
--    marker 15 or carries either column, and when 17 has not run.
-- ---------------------------------------------------------------------------

do $rerun_guard$
declare
  override         text    := nullif(current_setting('variorum.allow_18_rerun', true), '');
  deployed_marker  int     := 1;
  provenance_here  boolean := exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'reading_post'
      and column_name = 'arrival_provenance');
  pin_here         boolean := exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'reading_post'
      and column_name = 'pinned_at');
begin
  if override = 'yes-rerun-the-arrivals-pins-event' then
    raise notice 'VARIORUM 18 RE-RUN OVERRIDE ACCEPTED — re-applying the arrivals & pins event.';
    return;
  end if;

  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;

  if deployed_marker >= 15 or provenance_here or pin_here then
    raise exception using
      message = 'VARIORUM_18_ALREADY_DEPLOYED: this mirror has already run 18 (lockstep marker '
                || deployed_marker || '; reading_post.arrival_provenance '
                || case when provenance_here then 'present' else 'absent' end
                || '; reading_post.pinned_at '
                || case when pin_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_18_rerun = ''yes-rerun-the-arrivals-pins-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;

  if deployed_marker < 14 then
    raise exception using
      message = 'VARIORUM_18_PREREQUISITE_MISSING: this mirror is at lockstep marker '
                || deployed_marker || ' — run 17 (the key-vault event) first.';
  end if;
end
$rerun_guard$;

begin;

-- ---------------------------------------------------------------------------
-- 1. The two additive columns — nullable, no default, no constraint
--    (SyncSpec §2: the client reads an absent/NULL provenance as a
--    pre-dating arrival and an absent/NULL pin as NOT PINNED; pinned by this
--    run's suites). The stamp trigger re-seqs nothing here: a bare
--    `add column` writes no row.
-- ---------------------------------------------------------------------------

alter table reading_post add column arrival_provenance text;
alter table reading_post add column pinned_at text;

-- ---------------------------------------------------------------------------
-- 2. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
--    TRANSACTION, immediately before commit — a partial deploy can never
--    advertise the new version. The mirror now speaks lockstep version 15.
--    Must equal SyncSchema.lockstepVersion in the client — the in-repo
--    DDL pin fails the build if they drift.
-- ---------------------------------------------------------------------------

insert into sync_meta (key, value) values ('lockstep_version', '15')
  on conflict (key) do update set value = excluded.value;

commit;

-- Verification (read-only; the window runs these — the VX-808 closeout
-- checklist):
--   select sync_schema_version();                                          -- 15
--   select column_name, data_type from information_schema.columns
--     where table_name = 'reading_post'
--       and column_name in ('arrival_provenance', 'pinned_at');            -- two rows, text
--   select count(*) from reading_post where arrival_provenance is not null; -- 0 at the window
--   select count(*) from reading_post where pinned_at is not null;          -- 0 at the window;
--                                                                          -- hers arrive by round
