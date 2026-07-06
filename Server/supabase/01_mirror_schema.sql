-- Variorum sync mirror schema (SyncSpec §2) — Phase 5, Step 8.
-- Run in the Supabase SQL editor (author-assisted step) BEFORE 02_sync_rpc.sql.
--
-- THE DUMBNESS IS LOAD-BEARING (SyncSpec §2, review finding #5):
--   * one mirror table per synced client table, same columns;
--   * PRIMARY KEY only — NO other uniqueness constraints, NO foreign keys,
--     NO check constraints. The repair design REQUIRES the server to accept
--     both sides of a race (two live placements for one block, dangling
--     references mid-batch) so clients can repair deterministically.
--     Mirroring the client's live-unique indexes or FKs here breaks
--     convergence. Do not "harden" this schema.
--   * `reference.file_bookmark` does not exist here: it is local-only
--     (security-scoped bookmarks are per-machine, AppSpec §7).
--   * plus, per table: `sync_version` (the CAS token) and `server_seq`
--     (global monotonic ordering authority, stamped by trigger from ONE
--     sequence on every accepted insert/update — SyncSpec §9: never wall
--     clocks).
--
-- Timestamps stay TEXT: they are opaque display/domain data in this
-- protocol; keeping the client's canonical ISO-8601 strings byte-identical
-- avoids representation drift.

create sequence if not exists sync_server_seq;

-- One stamping trigger function for all mirrors.
create or replace function stamp_server_seq() returns trigger
language plpgsql as $$
begin
  new.server_seq := nextval('sync_server_seq');
  return new;
end;
$$;

create table container (
  id                     text primary key,
  owner_id               text,
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
  created_at             text,
  updated_at             text,
  archived_at            text,
  deleted_at             text,
  sync_version           bigint not null default 0,
  server_seq             bigint not null default 0
);

create table block (
  id                 text primary key,
  owner_id           text,
  default_variant_id text,
  last_container_id  text,
  created_at         text,
  updated_at         text,
  archived_at        text,
  deleted_at         text,
  sync_version       bigint not null default 0,
  server_seq         bigint not null default 0
);

create table variant (
  id                text primary key,
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
  server_seq        bigint not null default 0
);

create table commit_point (
  id           text primary key,
  variant_id   text,
  text         text,
  kind         text,
  message      text,
  created_at   text,
  sync_version bigint not null default 0,
  server_seq   bigint not null default 0
);

create table edge (
  id              text primary key,
  source_block_id text,
  target_block_id text,
  type            text,
  origin_op       text,
  created_at      text,
  deleted_at      text,
  sync_version    bigint not null default 0,
  server_seq      bigint not null default 0
);

create table container_block (
  id                text primary key,
  container_id      text,
  block_id          text,
  position          text,
  chosen_variant_id text,
  created_at        text,
  updated_at        text,
  deleted_at        text,
  sync_version      bigint not null default 0,
  server_seq        bigint not null default 0
);

create table reading (
  id              text primary key,
  owner_id        text,
  name            text,
  kind            text,
  profile         text,
  sort_field      text,
  sort_dir        text,
  grouping_tag_id text,
  query_spec      text,
  max_posts       bigint,
  locked          bigint,
  created_at      text,
  updated_at      text,
  deleted_at      text,
  sync_version    bigint not null default 0,
  server_seq      bigint not null default 0
);

create table reading_post (
  id           text primary key,
  reading_id   text,
  post_id      text,
  position     text,
  created_at   text,
  deleted_at   text,
  sync_version bigint not null default 0,
  server_seq   bigint not null default 0
);

create table tag (
  id           text primary key,
  owner_id     text,
  parent_id    text,
  name         text,
  path         text,
  created_at   text,
  updated_at   text,
  deleted_at   text,
  sync_version bigint not null default 0,
  server_seq   bigint not null default 0
);

create table post_tag (
  id           text primary key,
  tag_id       text,
  post_id      text,
  created_at   text,
  deleted_at   text,
  sync_version bigint not null default 0,
  server_seq   bigint not null default 0
);

create table block_tag (
  id           text primary key,
  tag_id       text,
  block_id     text,
  created_at   text,
  deleted_at   text,
  sync_version bigint not null default 0,
  server_seq   bigint not null default 0
);

create table reference (
  id           text primary key,
  owner_id     text,
  container_id text,
  kind         text,
  name         text,
  url          text,
  view_state   text,
  position     text,
  created_at   text,
  updated_at   text,
  deleted_at   text,
  sync_version bigint not null default 0,
  server_seq   bigint not null default 0
);

create table setting (
  key          text primary key,
  value        text,
  sync_version bigint not null default 0,
  server_seq   bigint not null default 0
);

-- The stamping triggers + an index per mirror on the changefeed's access
-- path (pull is WHERE server_seq > cursor ORDER BY server_seq).
do $$
declare
  t text;
begin
  foreach t in array array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'setting'
  ] loop
    execute format(
      'create trigger %I before insert or update on %I
         for each row execute function stamp_server_seq()',
      'stamp_seq_' || t, t);
    execute format(
      'create index %I on %I (server_seq)', 'idx_seq_' || t, t);
  end loop;
end;
$$;
