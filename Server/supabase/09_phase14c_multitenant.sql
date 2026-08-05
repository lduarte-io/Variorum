-- Variorum sync mirror — the Phase 14c lockstep event (multi-tenant
-- hardening, batch 1; SyncSpec §12). Run AFTER 01 + 02 + 03 + 04 + 05 +
-- 06 + 07 + 08, via the author's PAT arrangement. The deploy is a GATE
-- ACT executed by the ARCHITECT at the author's EXPLICIT GO —
-- never a batch implementer. It is choreography step (2) of the 14c
-- design sitting's ruled signup-door order, always behind the A1 rail
-- (backup + mirror export FIRST — this file DROPS her mirror data
-- tables).
--
-- WHAT THIS EVENT SHIPS (the sitting's Round-4 CLEAN REBUILD ruling +
-- THE DESIGN items 1–2 and 5's entitlement half):
--   * the 18 data tables DROPPED AND RECREATED BORN MULTI-TENANT:
--     `owner_id uuid NOT NULL` inside a composite primary key
--     (owner_id, id) — (owner_id, key) for `setting` — so another
--     account's rows are not guarded away but structurally
--     UNADDRESSABLE: every lookup is tenant-scoped by the table's own
--     identity, and cross-tenant id collision is impossible rather than
--     improbable. Composite PKs are FREE here precisely because the
--     mirror has NO foreign keys by design (the repair architecture
--     requires the constraint-free mirror — SyncSpec §2; the usual
--     children-carry-the-key cost cannot exist);
--   * (owner_id, server_seq) indexes — each user's changefeed reads off
--     its own index;
--   * FORCED row level security (ENABLE + FORCE) with owner policies on
--     auth.uid() — under FORCE the policies bind even the table owner,
--     so the SECURITY DEFINER RPCs themselves pass through the policy:
--     the ruled two-layer HYBRID (explicit RPC guards + database-enforced
--     policies; a bug must get through both). The policies deliberately
--     carry NO `to` clause: restricting them to `authenticated` would
--     leave the definer role policy-less under FORCE and default-deny
--     the RPCs themselves; direct API access stays shut by PRIVILEGE
--     revokes, exactly as before. One build-time caveat rides the gate:
--     the live probe verifies empirically that the hosted `postgres`
--     role carries no BYPASSRLS (the sitting's pinned check);
--   * the RPCs REWRITTEN TENANT-SCOPED with new signatures —
--     sync_push(batch, active_key_id) / sync_pull(since_seq,
--     active_key_id, max_rows): every CAS lookup keys on (caller, id);
--     owner stamped into every insert server-side; owner subtracted from
--     every served payload for the TEN mirror-only-owner tables
--     (variant, commit_point, edge, container_block, reading_post,
--     reading_section, post_tag, block_tag, lens_choice, setting) whose
--     client schema has no owner column; the EIGHT client-carried owner
--     tables (container, block, reading, tag, reference, canvas_layout,
--     lens, block_comment) keep the validate-equals-caller guard. The
--     OLD function signatures are DROPPED FIRST — a lingering
--     sync_push(jsonb) would be an unfenced, unscoped door standing
--     beside the new ones;
--   * THE VAULT-KEY-ID FENCE (THE DESIGN item 2; CF-8's structural
--     half): every round carries the caller's active corpus key id; the
--     server compares it against the account's current `key_vault` row —
--     mismatch (or a missing vault row) refuses the WHOLE round with the
--     VARIORUM_STALE_KEY_FENCE error, which the client surfaces as the
--     CF-16 keys-were-replaced state. The re-key door (batch 2) writes
--     the NEW vault FIRST, so every stale writer everywhere is fenced
--     before its truncate runs — the structural fix for the whole
--     stale-key class (cold pass C-3's traced poison-push window);
--   * the `entitlement` table (THE DESIGN item 5's server half), born
--     clean, enforced by both RPCs from birth — safe because strangers
--     arrive only after the tier per the ruled choreography; the deploy
--     path seeds every EXISTING auth user (signups are OFF, so that is
--     exactly the author's account — no hardcoded uid). The gate's
--     second probe account is provisioned AFTER this deploy and gets its
--     entitlement row deliberately as part of the probe's setup;
--   * THE ACCOUNT LIFECYCLE DOORS (batch 2; THE DESIGN items 3–4):
--     `account_data_truncate(active_key_id)` — CF-8's server half: the
--     caller's OWN rows deleted across the 18 data tables (tenant-scoped
--     by owner_id; never key_vault, never entitlement, never sync_meta),
--     gated by the SAME vault-key-id fence as the sync RPCs, so the
--     truncate can only run for a caller holding the account's CURRENT
--     key — which, in the re-key order (new vault written FIRST), is
--     exactly the device that just re-keyed; and `account_purge()` —
--     the deletion door's immediate hard purge (her Round-5 ruling):
--     the account's data rows + its key_vault row + its entitlement
--     rows + the auth user itself, in that order. Local copies SURVIVE
--     both doors by construction — neither touches any device.
--
-- THE CHOREOGRAPHY (SyncSpec §12; the ruled signup-door order, steps
-- (1)–(3) of the gate):
--   (1) the A1 rail runs: WAL-safe local backup + a full mirror export
--       (this file drops the mirror's data tables — her local store is
--       TRUTH and re-pushes, but the rail is non-negotiable);
--   (2) this file runs on the mirror FIRST, at her explicit go. The
--       moment its final statement bumps the marker to 6, the installed
--       marker-5 builds VISIBLY refuse to sync (outbox intact, cursor
--       unmoved) — the accepted consequence; her Variorum-usage pause
--       holds through 14c (Round 1), so no round is running.
--       /Applications refreshes ONLY AFTER this deploy (the
--       lockstep-strand rule);
--   (3) THEN her corpus re-pushes from local truth through the proven
--       runner (the 14b wipe-and-repush road, run twice already), and
--       the phone re-onboards once, as at 14b. Only then do the live
--       probes, the domain, SMTP, and HER signup flip follow (steps
--       4–8 of the ruled order).
--
-- THE DUMBNESS IS STILL LOAD-BEARING (SyncSpec §2): beyond each
-- composite PK there are NO uniqueness constraints, NO foreign keys, NO
-- checks on the data tables. The repair design REQUIRES the server to
-- accept both sides of a race so clients can repair deterministically —
-- WITHIN a tenant. Across tenants there is nothing to repair: the
-- composite identity makes foreign rows unaddressable. Do not "harden"
-- this schema further.
--
-- `reference.file_bookmark` still does not exist here: local-only
-- (security-scoped bookmarks are per-machine, AppSpec §7). Timestamps
-- stay TEXT (opaque display/domain data; byte-identical ISO-8601).
-- `key_vault`, `sync_meta`, and `auth.*` are NOT touched by the rebuild.

-- ---------------------------------------------------------------------------
-- 0. Drop the OLD RPC signatures before anything else. CREATE with a new
--    parameter list would leave the old functions standing (Postgres
--    overloads by signature): sync_pull(bigint, int) would keep serving
--    the TEN ownerless tables to ANY authenticated caller with no owner
--    filter, no fence, and no entitlement — a full cross-tenant read
--    door beside the new one. Dropping them is the isolation boundary's
--    requirement, not hygiene.
-- ---------------------------------------------------------------------------

drop function if exists sync_push(jsonb);
drop function if exists sync_pull(bigint, int);

-- ---------------------------------------------------------------------------
-- 1. Shared machinery: the global sequence survives (SyncSpec §9 — the
--    ordering authority is never reset; her repush continues it), and
--    the stamping trigger function is re-affirmed (03's two-column body,
--    consolidated here for fresh-project bootstrap).
-- ---------------------------------------------------------------------------

create sequence if not exists sync_server_seq;

create or replace function stamp_server_seq() returns trigger
language plpgsql as $$
begin
  new.server_seq := nextval('sync_server_seq');
  new.server_written_at := clock_timestamp();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 2. The 18 data tables, born multi-tenant. Final consolidated columns
--    (the 01→08 accretion: 05's block.name + canvas_layout/lens/
--    lens_choice, 06's block.presentation + reading_section +
--    reading_post.section_id + reading.word_target + block_comment,
--    07's container.word_target). Per table: composite PK, the
--    (owner_id, server_seq) changefeed index, the seq/written-at stamp
--    trigger, forced RLS + the owner policy, privilege revokes.
-- ---------------------------------------------------------------------------

drop table if exists container;
create table container (
  owner_id               uuid not null,
  id                     text not null,
  kind                   text,
  title                  text,
  profile                text,
  entry_date             text,
  locked                 bigint,
  locked_at              text,
  floating_notes         text,
  segmentation_default   text,
  last_touched_at        text,
  last_major_revision_at text,
  churn_accumulator      double precision,
  baseline_length        bigint,
  word_target            bigint,
  created_at             text,
  updated_at             text,
  archived_at            text,
  deleted_at             text,
  sync_version           bigint not null default 0,
  server_seq             bigint not null default 0,
  server_written_at      timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_container before insert or update on container
  for each row execute function stamp_server_seq();
create index idx_owner_seq_container on container (owner_id, server_seq);
alter table container enable row level security;
alter table container force row level security;
create policy container_owner_all on container
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on container from anon, authenticated;

drop table if exists block;
create table block (
  owner_id           uuid not null,
  id                 text not null,
  default_variant_id text,
  last_container_id  text,
  name               text,
  presentation       text,
  created_at         text,
  updated_at         text,
  archived_at        text,
  deleted_at         text,
  sync_version       bigint not null default 0,
  server_seq         bigint not null default 0,
  server_written_at  timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_block before insert or update on block
  for each row execute function stamp_server_seq();
create index idx_owner_seq_block on block (owner_id, server_seq);
alter table block enable row level security;
alter table block force row level security;
create policy block_owner_all on block
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on block from anon, authenticated;

drop table if exists variant;
create table variant (
  owner_id          uuid not null,
  id                text not null,
  block_id          text,
  parent_variant_id text,
  working_text      text,
  status            text,
  locked            bigint,
  label             text,
  fan_position      text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_variant before insert or update on variant
  for each row execute function stamp_server_seq();
create index idx_owner_seq_variant on variant (owner_id, server_seq);
alter table variant enable row level security;
alter table variant force row level security;
create policy variant_owner_all on variant
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on variant from anon, authenticated;

drop table if exists commit_point;
create table commit_point (
  owner_id          uuid not null,
  id                text not null,
  variant_id        text,
  text              text,
  kind              text,
  message           text,
  created_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_commit_point before insert or update on commit_point
  for each row execute function stamp_server_seq();
create index idx_owner_seq_commit_point on commit_point (owner_id, server_seq);
alter table commit_point enable row level security;
alter table commit_point force row level security;
create policy commit_point_owner_all on commit_point
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on commit_point from anon, authenticated;

drop table if exists edge;
create table edge (
  owner_id          uuid not null,
  id                text not null,
  source_block_id   text,
  target_block_id   text,
  type              text,
  origin_op         text,
  created_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_edge before insert or update on edge
  for each row execute function stamp_server_seq();
create index idx_owner_seq_edge on edge (owner_id, server_seq);
alter table edge enable row level security;
alter table edge force row level security;
create policy edge_owner_all on edge
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on edge from anon, authenticated;

drop table if exists container_block;
create table container_block (
  owner_id          uuid not null,
  id                text not null,
  container_id      text,
  block_id          text,
  position          text,
  chosen_variant_id text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_container_block before insert or update on container_block
  for each row execute function stamp_server_seq();
create index idx_owner_seq_container_block on container_block (owner_id, server_seq);
alter table container_block enable row level security;
alter table container_block force row level security;
create policy container_block_owner_all on container_block
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on container_block from anon, authenticated;

drop table if exists reading;
create table reading (
  owner_id          uuid not null,
  id                text not null,
  name              text,
  kind              text,
  profile           text,
  sort_field        text,
  sort_dir          text,
  grouping_tag_id   text,
  query_spec        text,
  max_posts         bigint,
  word_target       bigint,
  locked            bigint,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_reading before insert or update on reading
  for each row execute function stamp_server_seq();
create index idx_owner_seq_reading on reading (owner_id, server_seq);
alter table reading enable row level security;
alter table reading force row level security;
create policy reading_owner_all on reading
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on reading from anon, authenticated;

drop table if exists reading_section;
create table reading_section (
  owner_id          uuid not null,
  id                text not null,
  reading_id        text,
  name              text,
  position          text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_reading_section before insert or update on reading_section
  for each row execute function stamp_server_seq();
create index idx_owner_seq_reading_section on reading_section (owner_id, server_seq);
alter table reading_section enable row level security;
alter table reading_section force row level security;
create policy reading_section_owner_all on reading_section
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on reading_section from anon, authenticated;

drop table if exists reading_post;
create table reading_post (
  owner_id          uuid not null,
  id                text not null,
  reading_id        text,
  post_id           text,
  position          text,
  section_id        text,
  created_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_reading_post before insert or update on reading_post
  for each row execute function stamp_server_seq();
create index idx_owner_seq_reading_post on reading_post (owner_id, server_seq);
alter table reading_post enable row level security;
alter table reading_post force row level security;
create policy reading_post_owner_all on reading_post
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on reading_post from anon, authenticated;

drop table if exists tag;
create table tag (
  owner_id          uuid not null,
  id                text not null,
  parent_id         text,
  name              text,
  path              text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_tag before insert or update on tag
  for each row execute function stamp_server_seq();
create index idx_owner_seq_tag on tag (owner_id, server_seq);
alter table tag enable row level security;
alter table tag force row level security;
create policy tag_owner_all on tag
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on tag from anon, authenticated;

drop table if exists post_tag;
create table post_tag (
  owner_id          uuid not null,
  id                text not null,
  tag_id            text,
  post_id           text,
  created_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_post_tag before insert or update on post_tag
  for each row execute function stamp_server_seq();
create index idx_owner_seq_post_tag on post_tag (owner_id, server_seq);
alter table post_tag enable row level security;
alter table post_tag force row level security;
create policy post_tag_owner_all on post_tag
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on post_tag from anon, authenticated;

drop table if exists block_tag;
create table block_tag (
  owner_id          uuid not null,
  id                text not null,
  tag_id            text,
  block_id          text,
  created_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_block_tag before insert or update on block_tag
  for each row execute function stamp_server_seq();
create index idx_owner_seq_block_tag on block_tag (owner_id, server_seq);
alter table block_tag enable row level security;
alter table block_tag force row level security;
create policy block_tag_owner_all on block_tag
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on block_tag from anon, authenticated;

drop table if exists reference;
create table reference (
  owner_id          uuid not null,
  id                text not null,
  container_id      text,
  kind              text,
  name              text,
  url               text,
  view_state        text,
  position          text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_reference before insert or update on reference
  for each row execute function stamp_server_seq();
create index idx_owner_seq_reference on reference (owner_id, server_seq);
alter table reference enable row level security;
alter table reference force row level security;
create policy reference_owner_all on reference
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on reference from anon, authenticated;

drop table if exists canvas_layout;
create table canvas_layout (
  owner_id          uuid not null,
  id                text not null,
  container_id      text,
  block_id          text,
  x                 double precision,
  y                 double precision,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_canvas_layout before insert or update on canvas_layout
  for each row execute function stamp_server_seq();
create index idx_owner_seq_canvas_layout on canvas_layout (owner_id, server_seq);
alter table canvas_layout enable row level security;
alter table canvas_layout force row level security;
create policy canvas_layout_owner_all on canvas_layout
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on canvas_layout from anon, authenticated;

drop table if exists lens;
create table lens (
  owner_id          uuid not null,
  id                text not null,
  container_id      text,
  name              text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_lens before insert or update on lens
  for each row execute function stamp_server_seq();
create index idx_owner_seq_lens on lens (owner_id, server_seq);
alter table lens enable row level security;
alter table lens force row level security;
create policy lens_owner_all on lens
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on lens from anon, authenticated;

drop table if exists lens_choice;
create table lens_choice (
  owner_id          uuid not null,
  id                text not null,
  lens_id           text,
  block_id          text,
  variant_id        text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_lens_choice before insert or update on lens_choice
  for each row execute function stamp_server_seq();
create index idx_owner_seq_lens_choice on lens_choice (owner_id, server_seq);
alter table lens_choice enable row level security;
alter table lens_choice force row level security;
create policy lens_choice_owner_all on lens_choice
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on lens_choice from anon, authenticated;

drop table if exists block_comment;
create table block_comment (
  owner_id          uuid not null,
  id                text not null,
  block_id          text,
  text              text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, id)
);
create trigger stamp_seq_block_comment before insert or update on block_comment
  for each row execute function stamp_server_seq();
create index idx_owner_seq_block_comment on block_comment (owner_id, server_seq);
alter table block_comment enable row level security;
alter table block_comment force row level security;
create policy block_comment_owner_all on block_comment
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on block_comment from anon, authenticated;

-- setting: the 14c multi-user redesign, subsumed by the rebuild exactly
-- as ruled — the composite key becomes the table's REAL primary key
-- (owner_id, key), no special case. The client schema and app stay
-- untouched (a device's store is one user's by nature): owner is
-- stamped and subtracted server-side like every mirror-only-owner
-- table, so two users' settings can never CAS-fight again.
drop table if exists setting;
create table setting (
  owner_id          uuid not null,
  key               text not null,
  value             text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0,
  server_written_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, key)
);
create trigger stamp_seq_setting before insert or update on setting
  for each row execute function stamp_server_seq();
create index idx_owner_seq_setting on setting (owner_id, server_seq);
alter table setting enable row level security;
alter table setting force row level security;
create policy setting_owner_all on setting
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on setting from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 3. entitlement — the tier's server half (THE DESIGN item 5), born
--    clean. NOT a sync-mirror table (never in the RPC allowlists, never
--    in a payload — the serializer walk's server-only set carries it).
--    Rows are written server-side only (the batch-3 checkout webhook
--    function / service_role); the apps READ their own row via plain
--    authenticated PostgREST (the P-ii pattern) — hence RLS ENABLED
--    (not forced: the definer RPCs must read it for the gate below)
--    with an owner-only SELECT policy, and no insert/update/delete
--    grants to authenticated at all. Price-agnostic by design: a row
--    IS the entitlement; `expires_at` NULL means non-expiring.
-- ---------------------------------------------------------------------------

drop table if exists entitlement;
create table entitlement (
  user_id    uuid not null,
  feature    text not null,
  granted_at timestamptz not null default now(),
  source     text,
  expires_at timestamptz,
  primary key (user_id, feature)
);
alter table entitlement enable row level security;
create policy entitlement_owner_select on entitlement
  for select to authenticated using (auth.uid() = user_id);
revoke all on entitlement from anon, authenticated;
grant select on entitlement to authenticated;

-- The deploy-path seed: every EXISTING auth user is entitled. At deploy
-- time signups are OFF and the author's account is the only user — this
-- seeds HER, by construction, with no hardcoded uid. The gate's second
-- probe account arrives after this deploy and is granted its row
-- deliberately as part of the probe setup (recorded in the plan file).
insert into entitlement (user_id, feature, source)
select id, 'hosted_sync', '14c-deploy-seed' from auth.users
on conflict (user_id, feature) do nothing;

-- ---------------------------------------------------------------------------
-- 4. sync_push — tenant-scoped compare-and-set. CAS semantics, the wire
--    shapes, and the A5 machinery are UNTOUCHED; what is new: the
--    required active_key_id parameter (the vault-key-id fence), the
--    entitlement gate, identity keyed (caller, id) on every lookup,
--    owner stamped server-side into every insert, and owner subtracted
--    from reject payloads for the mirror-only-owner tables. Guard
--    failures RAISE (aborting the whole call) exactly as 04 ruled: a
--    reject-with-current invites the client's CAS merge loop, and a
--    fence/entitlement/ownership violation is never merge-resolvable.
-- ---------------------------------------------------------------------------

create or replace function sync_push(batch jsonb, active_key_id text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting'];
  -- The tables whose CLIENT schema carries owner_id (AppSpec §6 top-level
  -- entities + their later siblings): payloads carry owner and must
  -- carry the caller's. Everything else is mirror-only-owner: the
  -- server stamps on insert and subtracts on serve.
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment'];
  caller uuid;
  fence_key text;
  item jsonb;
  tbl text;
  pk text;
  row_id text;
  base_version bigint;
  current_version bigint;
  current_jsonb jsonb;
  full_row jsonb;
  granted_seq bigint;
  results jsonb := '[]'::jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE VAULT-KEY-ID FENCE (THE DESIGN item 2): the caller's presented
  -- corpus key id must match the account's current key_vault row. A
  -- mismatch — or a missing vault row (a re-key mid-flight, or setup
  -- never ran) — refuses the WHOLE round before any row is touched;
  -- the client surfaces the marker as the CF-16 replaced state. The
  -- re-key door writes the NEW vault first, so every stale writer is
  -- fenced before its truncate runs.
  select corpus_key_id into fence_key from key_vault where user_id = caller;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

  -- THE ENTITLEMENT GATE (THE DESIGN item 5): hosted sync is the tier.
  -- Enforced from birth — safe because strangers arrive only after the
  -- tier per the ruled choreography (her account is seeded above).
  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  for item in select * from jsonb_array_elements(batch) loop
    tbl := item->>'table';
    if not (tbl = any (allowed)) then
      raise exception 'unknown sync table %', tbl;
    end if;
    pk := sync_table_pk(tbl);
    row_id := item->>'row_id';
    base_version := (item->>'base_version')::bigint;
    current_version := null;
    current_jsonb := null;

    -- Client-carried owner guard (the EIGHT): a pushed row must carry
    -- the caller's own owner_id (NULL refused too — `is distinct
    -- from`). The stored-side foreign-owner guard of 04–06 is retired
    -- as structurally unreachable: the tenant-scoped CAS read below
    -- cannot see another owner's row at all.
    if tbl = any (owner_tables)
       and (item->'columns'->>'owner_id') is distinct from caller::text then
      raise exception 'owner_id mismatch on % row % — pushes must carry owner_id = auth.uid()',
        tbl, row_id;
    end if;

    -- TENANT-SCOPED CAS lock + read: identity is (owner_id, id) — the
    -- composite PK — so another account's same-id row is structurally
    -- unaddressable, and this seek is exact.
    execute format(
      'select sync_version, to_jsonb(t) from %I t where t.owner_id = $2 and t.%I = $1 for update',
      tbl, pk)
      into current_version, current_jsonb
      using row_id, caller;

    if current_version is null then
      -- Absent row (in THIS tenant's partition): only base 0 inserts.
      if base_version = 0 then
        -- Owner stamped server-side into EVERY insert (for the eight
        -- this merely re-affirms the validated payload value; for the
        -- ten it is the stamp — the payload has no owner column).
        full_row := (item->'columns')
          || jsonb_build_object('sync_version', 1, 'owner_id', caller);
        execute format(
          'insert into %I select * from jsonb_populate_record(null::%I, $1) returning server_seq',
          tbl, tbl)
          into granted_seq using full_row;
        results := results || jsonb_build_array(jsonb_build_object(
          'status', 'accepted', 'new_version', 1, 'server_seq', granted_seq));
      else
        results := results || jsonb_build_array(jsonb_build_object(
          'status', 'rejected', 'current', null));
      end if;
    elsif base_version = current_version then
      -- Matching base: replace the row wholesale (delete+insert is safe —
      -- nothing references a mirror row) and bump. Both statements are
      -- tenant-scoped by the composite identity.
      full_row := (item->'columns')
        || jsonb_build_object('sync_version', current_version + 1, 'owner_id', caller);
      execute format('delete from %I where owner_id = $2 and %I = $1', tbl, pk)
        using row_id, caller;
      execute format(
        'insert into %I select * from jsonb_populate_record(null::%I, $1) returning server_seq',
        tbl, tbl)
        into granted_seq using full_row;
      results := results || jsonb_build_array(jsonb_build_object(
        'status', 'accepted', 'new_version', current_version + 1, 'server_seq', granted_seq));
    else
      -- Stale base: reject WITH the current row so the client can merge
      -- deterministically and push again (SyncSpec §4). No server
      -- merging. The served payload subtracts the server-only columns —
      -- and, for the mirror-only-owner tables, the stamped owner_id
      -- (the client has no home for it; SyncSpec §12's unknown-column
      -- refusal would fire).
      results := results || jsonb_build_array(jsonb_build_object(
        'status', 'rejected',
        'current', jsonb_build_object(
          'table', tbl,
          'row_id', row_id,
          'sync_version', current_version,
          'server_seq', current_jsonb->'server_seq',
          'columns', case when tbl = any (owner_tables)
            then current_jsonb - 'sync_version' - 'server_seq' - 'server_written_at'
            else current_jsonb - 'sync_version' - 'server_seq' - 'server_written_at' - 'owner_id'
          end)));
    end if;
  end loop;
  return results;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. sync_pull — the tenant-scoped changefeed. The A5 visibility horizon
--    and the server-only column subtraction are preserved VERBATIM;
--    EVERY table now serves only the caller's own rows off its
--    (owner_id, server_seq) index, and the mirror-only-owner tables
--    additionally subtract the stamped owner_id from payloads. Same
--    fence + entitlement gates as push — a stale writer's pull half
--    refuses identically.
-- ---------------------------------------------------------------------------

create or replace function sync_pull(since_seq bigint, active_key_id text, max_rows int default 500)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting'];
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment'];
  caller uuid;
  fence_key text;
  tbl text;
  union_sql text := '';
  result jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE VAULT-KEY-ID FENCE (same as push — both round halves refuse).
  select corpus_key_id into fence_key from key_vault where user_id = caller;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

  -- THE ENTITLEMENT GATE (same as push).
  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  -- State-based changefeed: each row appears once, in its current state,
  -- at its latest seq (SyncSpec §2) — now strictly within the caller's
  -- partition. The visibility horizon (A5) is the `interval '2 seconds'`
  -- filter: rows written within that window are never served, so a pull
  -- can never advance past a seq still hidden in an uncommitted
  -- transaction (pushes are short transactions; the Fragments-proven
  -- margin).
  foreach tbl in array allowed loop
    if union_sql <> '' then
      union_sql := union_sql || ' union all ';
    end if;
    if tbl = any (owner_tables) then
      -- Client-carried owner: the payload keeps owner_id (the client
      -- schema has the column and the value is the caller's by guard).
      union_sql := union_sql || format(
        $q$select %L::text as tbl, t.server_seq, t.sync_version,
             to_jsonb(t) - 'sync_version' - 'server_seq' - 'server_written_at' as cols,
             (to_jsonb(t))->>%L as row_id
           from %I t
           where t.owner_id = %L
             and t.server_seq > %s
             and t.server_written_at <= clock_timestamp() - interval '2 seconds'$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq);
    else
      -- Mirror-only owner: subtract the stamped owner_id — the client
      -- has no home for it (the unknown-column refusal would fire).
      union_sql := union_sql || format(
        $q$select %L::text as tbl, t.server_seq, t.sync_version,
             to_jsonb(t) - 'sync_version' - 'server_seq' - 'server_written_at' - 'owner_id' as cols,
             (to_jsonb(t))->>%L as row_id
           from %I t
           where t.owner_id = %L
             and t.server_seq > %s
             and t.server_written_at <= clock_timestamp() - interval '2 seconds'$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq);
    end if;
  end loop;

  execute format(
    $q$select coalesce(jsonb_agg(jsonb_build_object(
         'table', u.tbl, 'row_id', u.row_id,
         'sync_version', u.sync_version, 'server_seq', u.server_seq,
         'columns', u.cols) order by u.server_seq), '[]'::jsonb)
       from (select * from (%s) raw order by raw.server_seq limit %s) u$q$,
    union_sql, max_rows)
    into result;
  return result;
end;
$$;

-- ---------------------------------------------------------------------------
-- 6. account_data_truncate — CF-8's server half (batch 2; THE DESIGN
--    item 3). The user-facing re-key door's order of operations is the
--    safety design: passphrase authorization → the NEW vault written
--    FIRST (fresh key ids — every stale writer everywhere is fenced
--    from that instant) → THIS truncate → local resyncReinitialize →
--    repush. The fence check below is what makes the order enforceable
--    server-side: only a caller presenting the account's CURRENT corpus
--    key id — post-vault-write, that is the freshly-minted one — can
--    empty the account's synced copy; a stale device refuses here with
--    the same marker as at sync (cold pass C-3's poison-push window,
--    closed structurally).
--
--    Tenant-scoped row DELETEs, never TRUNCATE: the composite
--    (owner_id, id) identity makes `where owner_id = auth.uid()` exact,
--    and other tenants' rows are structurally unaddressable. NEVER
--    key_vault (the new vault is the re-key's whole point), NEVER
--    entitlement (the tier survives a re-key), NEVER sync_meta (the
--    marker is schema choreography). The global server_seq sequence is
--    untouched (SyncSpec §9 — ordering authority stays monotonic).
--
--    DELIBERATELY NO entitlement gate: removing your own synced data is
--    a data-removal right, never commerce-gated (an expired account can
--    still empty its server copy; it just cannot repush until the tier
--    is active again).
-- ---------------------------------------------------------------------------

create or replace function account_data_truncate(active_key_id text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  data_tables constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting'];
  caller uuid;
  fence_key text;
  tbl text;
  removed bigint;
  counts jsonb := '{}'::jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  -- THE VAULT-KEY-ID FENCE (the sync RPCs' exact arm, same marker): a
  -- missing vault row or a mismatched key id refuses the whole act —
  -- the client classifies the marker into the CF-16 replaced state.
  select corpus_key_id into fence_key from key_vault where user_id = caller;
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

  foreach tbl in array data_tables loop
    execute format('delete from %I where owner_id = $1', tbl) using caller;
    get diagnostics removed = row_count;
    counts := counts || jsonb_build_object(tbl, removed);
  end loop;
  return counts;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. account_purge — the deletion door's immediate hard purge (batch 2;
--    THE DESIGN item 4, her Round-5 ruling). ONE transaction: the
--    account's rows across the 18 data tables, then its key_vault row,
--    then its entitlement rows, then THE AUTH USER ITSELF — the order
--    matters because key_vault.user_id references auth.users (08's FK),
--    so the vault row must die before the user row can.
--
--    THE PINNED COPY RULE lives client-side (her Round-5 ruling: the
--    door's copy MUST say the local copy survives) — and it is TRUE by
--    construction here: this function touches only the server.
--
--    Server-side authorization is the authenticated session alone; the
--    passphrase authorization and the typed confirmation are CLIENT-side
--    friction by necessity (the server never sees the encryption
--    passphrase — that is the whole E2EE design). No fence arm: deletion
--    supersedes re-key (a stale device's owner may still delete the
--    account), and no entitlement gate (deletion is a right, never
--    commerce-gated).
--
--    Definer-function auth-user removal, VERIFIED (build-time lookup,
--    2026-08-04, per THE DESIGN's verify-honestly instruction):
--    Supabase's 2025-04 auth-schema lockdown restricted DDL and DML on
--    the migration-tracking tables ONLY — the postgres role (this
--    function's owner) retains full DML on auth.users, and Supabase
--    collaborators explicitly confirm the SECURITY DEFINER
--    delete-from-auth.users self-deletion RPC pattern (GitHub
--    discussions #1066/#26223/#35987; the 2025 restriction notice is
--    discussion #34270). auth.identities/sessions/refresh_tokens
--    cascade off auth.users; this project uses no Supabase Storage, so
--    the storage.objects RESTRICT caveat is N/A. Two recorded caveats:
--    (1) already-issued access JWTs stay cryptographically valid until
--    expiry (≤1 h) — a lingering device's push in that window refuses
--    at the sync RPCs' fence anyway (its key_vault row is gone: the
--    missing-vault arm), so no post-deletion write can land; (2) if a
--    live deploy ever refuses this delete (a future privilege change),
--    the recorded fallback shape is an Edge Function calling
--    auth.admin.deleteUser() with the service role — a redesign-level
--    swap, not a quiet patch. The gate's probe-account deletion is the
--    live verification (the Verification section's letter).
-- ---------------------------------------------------------------------------

create or replace function account_purge() returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  data_tables constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting'];
  caller uuid;
  tbl text;
  removed bigint;
  data_rows bigint := 0;
  vault_rows bigint;
  entitlement_rows bigint;
  auth_rows bigint;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  foreach tbl in array data_tables loop
    execute format('delete from %I where owner_id = $1', tbl) using caller;
    get diagnostics removed = row_count;
    data_rows := data_rows + removed;
  end loop;

  delete from key_vault where user_id = caller;
  get diagnostics vault_rows = row_count;

  delete from entitlement where user_id = caller;
  get diagnostics entitlement_rows = row_count;

  -- The auth user LAST (key_vault's FK is gone now). Cascades inside
  -- the auth schema (identities, sessions, refresh tokens) ride the
  -- delete; the session that made this very call dies with them.
  delete from auth.users where id = caller;
  get diagnostics auth_rows = row_count;

  return jsonb_build_object(
    'data_rows', data_rows,
    'vault_rows', vault_rows,
    'entitlement_rows', entitlement_rows,
    'auth_user_removed', auth_rows > 0);
end;
$$;

-- ---------------------------------------------------------------------------
-- 8. The demotion posture on the NEW signatures (the old signatures were
--    dropped in section 0; their historical revokes stand in the
--    composition record). The version-check RPC is untouched. The two
--    account doors take the same posture — authenticated only (no
--    service_role grant: the account acts are always a signed-in user's
--    own, never server machinery's).
-- ---------------------------------------------------------------------------

revoke execute on function sync_push(jsonb, text) from public, anon;
revoke execute on function sync_pull(bigint, text, int) from public, anon;
grant execute on function sync_push(jsonb, text) to authenticated, service_role;
grant execute on function sync_pull(bigint, text, int) to authenticated, service_role;
revoke execute on function account_data_truncate(text) from public, anon;
revoke execute on function account_purge() from public, anon;
grant execute on function account_data_truncate(text) to authenticated;
grant execute on function account_purge() to authenticated;

-- ---------------------------------------------------------------------------
-- 9. The lockstep marker (SyncSpec §12): sync_meta and
--    sync_schema_version() already exist (05); nothing here recreates
--    them. THE MARKER UPDATE IS DELIBERATELY THE LAST STATEMENT OF THIS
--    FILE: a partially-executed deploy never advertises the new version
--    before the rebuilt tables and rewritten RPCs exist.
-- ---------------------------------------------------------------------------

-- LAST STATEMENT (see above): the mirror now speaks lockstep version 6.
-- Must equal SyncSchema.lockstepVersion in the client — the in-repo DDL
-- pin fails the build if they drift.
insert into sync_meta (key, value) values ('lockstep_version', '6')
  on conflict (key) do update set value = excluded.value;
