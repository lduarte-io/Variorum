-- Variorum sync mirror — the Phase 13y PER-TENANT `server_seq` lockstep
-- event (UNIT A; SyncSpec §12; the plan `notes/plans/phase-13y-per-tenant-seq.md`
-- — the Step 0 survey's verdict table and the F-S1..F-S4 findings are the
-- design record this file builds to). Run AFTER 01–11 (+ the maintenance
-- artifacts — `variorum_definer` exists; the rotation-clearing-guard
-- overlay's body is FOLDED INTO this file's canonical `key_vault_update`,
-- so the overlay is SUPERSEDED the moment this deploys; its own re-run
-- guard then refuses it forever, by the guard text this file installs).
--
-- THE DEPLOY IS PRE-AUTHORIZED (the kickoff sitting's R-13y-2: her PAT is
-- stored — the pre-13x §16 arrangement — so the ORCHESTRATOR runs the
-- mirror deploy at the ONE end-of-phase window; the `!` road if the
-- permission classifier blocks the mutating call — the 13j precedent) and
-- EXECUTES ONLY at the ORCHESTRATOR's window — never a batch implementer.
-- THE GOVERNANCE RIDER (R-13y-4, recorded in the plan): the window's
-- pre-deploy summary NAMES the two QUESTIONS #144 PROVISIONALs (the
-- key-proof challenge's shape; the abuse-guard numbers), one line each,
-- before anything fires — a last honest exit. The window bundles the Mac
-- Release refresh AND the PHONE build (the 13j one-window sequencing):
-- the moment the marker bumps to 9, every installed marker-8 build
-- VISIBLY refuses to sync (outbox intact, cursor unmoved — the §12
-- refusal grammar; offline is free while it waits). Always behind the
-- A1 rail. Her live round each direction and THE CARRY-OVER PROOF (her
-- cursors intact — the floor below, proven live) close the window.
--
-- WHAT THIS EVENT SHIPS (the phase's WHY: the 14c I-1 disclosure — one
-- global monotonic `server_seq` let any tenant infer every other tenant's
-- aggregate write volume/timing from the gaps in the seqs it receives;
-- with sync OPEN at v1 the closure must land BEFORE stranger cursors
-- accumulate):
--   * `sync_owner_seq` — the per-owner counter table (server-only, never
--     a mirror data table, never in an allowlist or a payload), one row
--     per account, on the `device_cursor` posture (FORCE RLS + owner
--     policy + definer grants);
--   * `next_owner_seq(for_owner)` — the ONE counter function: a
--     row-locked upsert-increment, so ONE account's writers serialize on
--     their own row and TENANTS NEVER CONTEND WITH EACH OTHER. The row
--     lock is held to commit, which also means one account's pushes
--     commit in seq order — the A5 visibility-skew class closes WITHIN an
--     account as a structural belt (the survey's F-S3; the A5 horizon
--     itself stays deployed byte-unchanged — the rotation walk leans on
--     it, and removing it would be its own event, never a rider);
--   * `stamp_server_seq()` REPLACED: every data row's seq now draws from
--     ITS OWNER's counter (every data table carries `owner_id uuid NOT
--     NULL` since 09's rebuild — the trigger has the owner in hand);
--   * the TWO direct mint sites SWAPPED to the caller's counter:
--     `sync_purge_execute`'s granted ledger seq (compared against the
--     owner's device cursors and ledger scan points — same counter or
--     the comparison breaks) and `key_vault_update`'s rotation-begin
--     `rotation_started_seq` (compared against the owner's data-row seqs
--     by the seq rule and the completion guard — same counter or the
--     rotation's whole bookkeeping breaks);
--   * THE FLOOR (the survey's F-S1 — WIDER than data-max, deliberately):
--     each owner's counter initializes to the GREATEST of (a) the max
--     `server_seq` across every data table's rows, (b) the max
--     `device_cursor.last_seq` (a purge can remove an owner's top-seq
--     rows AFTER a device's cursor passed them — a counter floored at
--     data-max would mint fresh seqs at or below that cursor, and the
--     device's `server_seq > cursor` pulls would never serve them:
--     silent loss), (c) the max `purged_row.purged_seq` (a fresh ledger
--     entry minted below a device's `last_purge_seq` scan point would
--     never be scanned — a stale peer never learns of the purge), and
--     (d) `key_vault.rotation_started_seq` where one stands (a
--     mid-rotation deploy must keep new rows ABOVE the rotation seq).
--     NO CURSOR RESETS: her devices' cursors stay valid by construction
--     — the carry-over proof at the window is this floor, proven live;
--   * `sync_pull` RE-CREATED with its parameters REORDERED so `key_proof`
--     is DEFAULTLESS (NIT-4, the pre-13x ladder: Postgres forbids a
--     defaultless parameter after defaulted ones, which is the only
--     reason the proof ever carried `default null`). The OLD signature is
--     DROPPED FIRST (the 09/10/11 discipline). ZERO wire change: PostgREST
--     resolves RPC arguments BY NAME and the client always sends every
--     key. The body is 11's VERBATIM — the A5 horizon, the device-cursor
--     upsert, the owner scoping and the subtraction all byte-kept;
--   * `account_purge` gains the caller's `sync_owner_seq` row — the whole
--     account goes (the 13j letter, extended to the table this event
--     adds). `account_data_truncate` deliberately does NOT touch the
--     counter: the owner's sequence stays monotonic across a re-key
--     exactly as the global one did (cursors stay valid; SyncSpec §9
--     per-owner), and the repush mints strictly above the old head;
--   * THE ROTATION COMPLETION GUARD'S BODY, FOLDED IN (RUN B S1/Q3's
--     carry; the standing caveat at `notes/plans/pre-13x-deploy-checklist.md`
--     §10 retires with this artifact): the canonical `key_vault_update`
--     below carries `VARIORUM_ROTATION_ROWS_REMAIN` — verified by the
--     in-repo DDL text pin on the DEPLOYED COMPOSITION's body
--     (`AuthRLSDDLTests`), never assumed from the overlay's state. The
--     overlay `maintenance/pre13x-ladder-rotation-clearing-guard.sql`
--     is marked superseded-by-12 in its header; a re-run of it refuses
--     on its own guard (the deployed body already carries the text);
--   * THE GLOBAL SEQUENCE RETIRES (the survey's F-S4): after the three
--     swaps NOTHING references `sync_server_seq` (the data tables default
--     the column to 0; the trigger overwrites), so this file DROPS it —
--     fail-loud closure: any future artifact that quietly `nextval`s the
--     global counter ERRORS instead of silently reopening the disclosure.
--
-- WHAT DOES NOT CHANGE: `sync_push` (its granted seqs come from the
-- trigger — M1 covers it); `sync_reencrypt` (same road); the gate and the
-- proof; the entitlement gate; the A5 horizon; every table, policy and
-- payload shape; `sync_schema_version()`'s own shape. Client semantics
-- are UNCHANGED AND TEST-PINNED (the phase's premise, Step 0-verified):
-- a client's cursor only ever meets own-account rows, and every seq
-- comparison any client makes is between own-account numbers — per-tenant
-- sequences preserve every relative order any client ever observes.
--
-- THE CHOREOGRAPHY (SyncSpec §12): this file runs on the mirror FIRST, at
-- the ORCHESTRATOR's window under her standing PRE-AUTHORIZED go — never
-- a batch implementer; then every client updates (the Mac Release + the
-- PHONE build, bundled into the same window); only then may any client
-- write what the new schema shapes. A marker-8 client refuses the
-- marker-9 mirror and vice versa — stalling is safe by design.
--
-- THIS FILE EXECUTES AS ONE TRANSACTION (the 09/I-3 discipline): begin →
-- re-run guard → the drop → the counter + the floor → the swaps → the
-- fold-in → ownership + grants → the marker LAST → commit. A failed run
-- rolls back whole, marker untouched; an honest retry needs no override.
--
-- THE NAMING RULE (13j, the author's ruling): no RPC parameter may shadow
-- a column it writes. `for_owner` is none of `sync_owner_seq`'s columns
-- (`owner_id`, `last_seq`) — the `for_device` idiom exactly.

begin;

-- ---------------------------------------------------------------------------
-- 0a. THE RE-RUN GUARD — first statement inside the transaction, before
--     the destructive drop below. Keyed on evidence only a deployed 12
--     leaves: the marker at 9+, or the `sync_owner_seq` table no other
--     artifact creates.
-- ---------------------------------------------------------------------------

do $rerun_guard$
declare
  override            text    := nullif(current_setting('variorum.allow_12_rerun', true), '');
  deployed_marker     int     := 1;
  counter_table_here  boolean := to_regclass('public.sync_owner_seq') is not null;
begin
  if override = 'yes-rerun-the-tenant-seq-event' then
    raise notice 'VARIORUM 12 RE-RUN OVERRIDE ACCEPTED — re-applying the per-tenant sequence event.';
    return;
  end if;

  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;

  if deployed_marker >= 9 or counter_table_here then
    raise exception using
      message = 'VARIORUM_12_ALREADY_DEPLOYED: this mirror has already run 12 (lockstep marker '
                || deployed_marker || '; sync_owner_seq table '
                || case when counter_table_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_12_rerun = ''yes-rerun-the-tenant-seq-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;
end
$rerun_guard$;

-- ---------------------------------------------------------------------------
-- 0. Drop the OLD sync_pull signature before creating the reordered one
--    (Postgres overloads by signature — the 09/10/11 discipline): a
--    lingering sync_pull(bigint, text, int, text, text) would keep serving
--    the changefeed with a DEFAULTED proof parameter beside the new one.
-- ---------------------------------------------------------------------------

drop function if exists sync_pull(bigint, text, int, text, text);

-- ---------------------------------------------------------------------------
-- 1. sync_owner_seq — the per-owner counter (server-only: never a mirror
--    data table, never in an allowlist, never in a payload). One row per
--    account; the `device_cursor` posture exactly. Every mint path runs
--    with the caller's auth context (the trigger fires inside the
--    SECURITY DEFINER bodies as `variorum_definer`, whose row reach the
--    FORCE-RLS owner policy scopes to auth.uid() — the calling account).
-- ---------------------------------------------------------------------------

create table sync_owner_seq (
  owner_id uuid   not null,
  last_seq bigint not null default 0,
  primary key (owner_id)
);
alter table sync_owner_seq enable row level security;
alter table sync_owner_seq force row level security;
create policy sync_owner_seq_owner_all on sync_owner_seq
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on sync_owner_seq from anon, authenticated;
grant select, insert, update on sync_owner_seq to variorum_definer;

-- ---------------------------------------------------------------------------
-- 2. next_owner_seq — the ONE counter function: a row-locked
--    upsert-increment. The ON CONFLICT UPDATE takes the owner's counter
--    row lock and HOLDS IT TO COMMIT — one account's writers serialize on
--    their own row (per-tenant serialization; commit order = seq order
--    per owner), and two tenants touch two rows: never each other.
--    LOCK-ORDER SAFETY (the survey's trace): every caller takes the vault
--    row (the gate's FOR SHARE, or key_vault_update's FOR UPDATE) BEFORE
--    its first counter touch — one lock order everywhere, no cycle; and
--    decision 31's guarantee TIGHTENS: an old-proof push holds the
--    owner's counter row to commit, so a rotation's begin-mint waits on
--    both locks and pre-rotation rows sit below the rotation seq by lock
--    order, per owner. SECURITY INVOKER (the stamp_server_seq class):
--    the definer bodies and the trigger are its only callers, and the
--    FORCE-RLS policy above binds even a misuse to the caller's own row.
-- ---------------------------------------------------------------------------

create or replace function next_owner_seq(for_owner uuid) returns bigint
language plpgsql
set search_path = public
as $$
declare
  granted bigint;
begin
  insert into sync_owner_seq (owner_id, last_seq)
  values (for_owner, 1)
  on conflict (owner_id) do update
    set last_seq = sync_owner_seq.last_seq + 1
  returning last_seq into granted;
  return granted;
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. THE FLOOR (F-S1 — no cursor resets, by construction): each owner's
--    counter starts at the GREATEST seq any of their bookkeeping already
--    compares against — every data table's rows, their device cursors
--    (a purge can leave data-max BELOW a served cursor), their ledger
--    entries, and a standing rotation seq. Gaps above the floor are
--    ordinary (the global counter interleaved tenants for months); a
--    floor higher than data-max only skips numbers, which the protocol
--    never assumes are dense. Runs as the deployer inside this
--    transaction — before any new mint can occur.
-- ---------------------------------------------------------------------------

insert into sync_owner_seq (owner_id, last_seq)
select owner_id, max(server_seq) from (
  select owner_id, server_seq from container
  union all
  select owner_id, server_seq from block
  union all
  select owner_id, server_seq from variant
  union all
  select owner_id, server_seq from commit_point
  union all
  select owner_id, server_seq from edge
  union all
  select owner_id, server_seq from container_block
  union all
  select owner_id, server_seq from reading
  union all
  select owner_id, server_seq from reading_section
  union all
  select owner_id, server_seq from reading_post
  union all
  select owner_id, server_seq from tag
  union all
  select owner_id, server_seq from post_tag
  union all
  select owner_id, server_seq from block_tag
  union all
  select owner_id, server_seq from reference
  union all
  select owner_id, server_seq from canvas_layout
  union all
  select owner_id, server_seq from lens
  union all
  select owner_id, server_seq from lens_choice
  union all
  select owner_id, server_seq from block_comment
  union all
  select owner_id, server_seq from setting
  union all
  select owner_id, server_seq from purge_intent
  union all
  select owner_id, last_seq from device_cursor
  union all
  select owner_id, purged_seq from purged_row
  union all
  select user_id, rotation_started_seq from key_vault where rotation_started_seq is not null
) seq_sources
group by owner_id
on conflict (owner_id) do update
  set last_seq = greatest(sync_owner_seq.last_seq, excluded.last_seq);

-- ---------------------------------------------------------------------------
-- 4. stamp_server_seq — the trigger every data table fires, REPLACED: the
--    seq draws from the ROW'S OWNER's counter (M1). Every data table
--    carries `owner_id uuid NOT NULL` (09's rebuild), and every insert is
--    owner-stamped server-side before the trigger fires, so the owner is
--    always in hand. `server_written_at` stays — the A5 horizon's
--    substrate is untouched.
-- ---------------------------------------------------------------------------

create or replace function stamp_server_seq() returns trigger
language plpgsql as $$
begin
  new.server_seq := next_owner_seq(new.owner_id);
  new.server_written_at := clock_timestamp();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. sync_pull — 11's body VERBATIM under the REORDERED signature (NIT-4):
--    `key_proof` is now DEFAULTLESS, before the genuinely-optional
--    `max_rows` / `for_device`. Zero wire change (PostgREST resolves by
--    name; the client always sends every key). The A5 visibility horizon,
--    the device-cursor upsert, the owner scoping and the server-only
--    column subtraction are all byte-kept.
-- ---------------------------------------------------------------------------

create or replace function sync_pull(since_seq bigint, active_key_id text, key_proof text, max_rows int default 500, for_device text default null)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment', 'purge_intent'];
  caller uuid;
  -- `for_device`, NOT `device_id` (2026-08-19, the window's first live
  -- round): the parameter's original name shadowed the device_cursor
  -- COLUMN inside the upsert's ON CONFLICT list — PL/pgSQL 42702, caught
  -- by the strict variable_conflict default doing exactly its job. The
  -- author's ruling: fix the NAME, never relax the policy — no RPC
  -- parameter may shadow a column it writes (the standing naming rule).
  dev text := for_device;
  tbl text;
  union_sql text := '';
  result jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE GATE (pre-13x): the vault row FOR SHARE, the fence, the proof.
  perform sync_key_gate(active_key_id, key_proof);

  -- THE ENTITLEMENT GATE (same as push).
  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  -- THE DEVICE CURSOR (Phase 13j — what makes a horizon computable):
  -- `since_seq` on a round's FIRST window is the caller's committed
  -- cursor — everything at or below it has been integrated and
  -- committed. Recorded monotonically (greatest), stamped seen_at now.
  if dev is not null then
    insert into device_cursor (owner_id, device_id, last_seq, seen_at)
    values (caller, dev, since_seq, now())
    on conflict (owner_id, device_id) do update
      set last_seq = greatest(device_cursor.last_seq, excluded.last_seq),
          seen_at  = now();
  end if;

  -- State-based changefeed: each row appears once, in its current state,
  -- at its latest seq (SyncSpec §2) — strictly within the caller's
  -- partition. The visibility horizon (A5) is the `interval '2 seconds'`
  -- filter: rows written within that window are never served.
  foreach tbl in array allowed loop
    if union_sql <> '' then
      union_sql := union_sql || ' union all ';
    end if;
    if tbl = any (owner_tables) then
      -- Client-carried owner: the payload keeps owner_id.
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
-- 6. sync_purge_execute — 11's body VERBATIM except the mint (M2): the
--    granted ledger seq draws from the CALLER's counter — the owner's
--    device cursors and `last_purge_seq` scan points are what it is
--    compared against, and they live on the same counter now.
-- ---------------------------------------------------------------------------

create or replace function sync_purge_execute(rows jsonb, active_key_id text, key_proof text) returns bigint
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  caller uuid;
  item jsonb;
  tbl text;
  pk text;
  granted_seq bigint;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;
  perform sync_key_gate(active_key_id, key_proof);

  granted_seq := next_owner_seq(caller);
  for item in select * from jsonb_array_elements(rows) loop
    tbl := item->>'table';
    if not (tbl = any (allowed)) then
      raise exception 'unknown sync table %', tbl;
    end if;
    pk := sync_table_pk(tbl);
    execute format('delete from %I where owner_id = $2 and %I = $1', tbl, pk)
      using item->>'row_id', caller;
    insert into purged_row (owner_id, table_name, row_id, purged_seq)
    values (caller, tbl, item->>'row_id', granted_seq)
    on conflict (owner_id, table_name, row_id) do nothing;
  end loop;
  return granted_seq;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. key_vault_update — THE ONE WRITE ROAD into the vault, now carrying
--    the ROTATION COMPLETION GUARD in its CANONICAL body (the fold-in;
--    the maintenance overlay is superseded) and the per-owner mint (M3):
--    a rotation's `rotation_started_seq` draws from the CALLER's counter
--    — the seq rule (`SyncPayloadCrypto.keyMaterial`) and the completion
--    guard both compare it against the owner's own data-row seqs, which
--    live on the same counter now. Everything 11's header says of this
--    door holds; the guard's reasoning is the overlay's, verbatim.
-- ---------------------------------------------------------------------------

create or replace function key_vault_update(payload jsonb, expected_revision int, key_proof text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  caller uuid;
  vault_revision int;
  vault_previous_id text;
  vault_previous text;
  vault_seq bigint;
  incoming_previous_id text;
  incoming_previous text;
  next_seq bigint;
  updated_rows int;
  -- THE COMPLETION GUARD's declarations (folded from the pre-13x ladder's
  -- F1 overlay — BLOCKER-1). THE ENCRYPTED COLUMNS, PER TABLE — every
  -- registry table with at least one encrypted-classified column and
  -- exactly those columns (the client's `SyncTable.encryptedColumns`;
  -- pinned equal by `AuthRLSDDLTests`). A row CARRIES CIPHERTEXT when at
  -- least one of them is NOT NULL; a row with none is under no key and
  -- never holds a completion.
  ciphertext_columns constant jsonb := '{
    "container": ["title", "floating_notes"],
    "block": ["name", "presentation"],
    "variant": ["working_text", "label"],
    "commit_point": ["text", "message"],
    "tag": ["name", "path"],
    "reading": ["name", "query_spec"],
    "reading_section": ["name"],
    "reference": ["name", "url", "view_state"],
    "lens": ["name"],
    "block_comment": ["text"]
  }'::jsonb;
  rows_below_tbl text;
  rows_below_cols text;
  rows_below bigint;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  select revision, corpus_previous_key_id, corpus_previous_wrapped_by_master, rotation_started_seq
    into vault_revision, vault_previous_id, vault_previous, vault_seq
    from key_vault where user_id = caller for update;
  if vault_revision is null then
    raise exception 'VARIORUM_VAULT_ABSENT: no vault exists for this account — set up sync first';
  end if;

  perform sync_key_proof_check(key_proof);

  incoming_previous_id := payload->>'corpus_previous_key_id';
  incoming_previous := payload->>'corpus_previous_wrapped_by_master';
  if (incoming_previous is null) <> (incoming_previous_id is null) then
    raise exception 'a previous corpus key travels as its id AND its wrap — never one without the other';
  end if;
  if incoming_previous is null then
    -- THE COMPLETION GUARD (the ladder's BLOCKER-1; decision 31's letter —
    -- "no row of mine below it"): clearing a STANDING previous key is
    -- refused while any row of the caller's partition that CARRIES
    -- CIPHERTEXT (at least one encrypted column not null) still sits below
    -- the rotation seq. Exact here: the row is locked FOR UPDATE, so every
    -- in-flight old-proof push (FOR SHARE) has committed, and the count
    -- reads committed rows regardless of `sync_pull`'s visibility horizon;
    -- and every such row is one the client walk re-stamps, so the refusal
    -- can never outlast a walk that saw it. The caller re-walks (any device
    -- holding the new master can) and clears again.
    if vault_previous is not null then
      for rows_below_tbl in select jsonb_object_keys(ciphertext_columns) loop
        select string_agg(format('t.%I is not null', c.col), ' or ')
          into rows_below_cols
          from jsonb_array_elements_text(ciphertext_columns->rows_below_tbl) as c(col);
        execute format(
          'select count(*) from %I t where t.owner_id = $1 and t.server_seq < $2 and (%s)',
          rows_below_tbl, rows_below_cols)
          into rows_below using caller, vault_seq;
        if rows_below > 0 then
          raise exception 'VARIORUM_ROTATION_ROWS_REMAIN: % row(s) of % still carry ciphertext under the previous corpus key — re-encrypt the remainder before clearing it',
            rows_below, rows_below_tbl;
        end if;
      end loop;
    end if;
    -- Completion (or no rotation): the key, its id and the seq clear together.
    next_seq := null;
  elsif vault_previous is null then
    -- A rotation begins: the next value of the CALLER'S OWN counter — the
    -- rows' own sequence (13y, M3) — inside this transaction, with the
    -- row locked.
    next_seq := next_owner_seq(caller);
  elsif incoming_previous = vault_previous and incoming_previous_id = vault_previous_id then
    -- A carry-through (decision 32's precision): a re-wrap mid-rotation
    -- sends the vault whole with the SAME previous key — not a second
    -- rotation; the seq is kept.
    next_seq := vault_seq;
  else
    raise exception 'VARIORUM_ROTATION_IN_PROGRESS: a key rotation started elsewhere is still finishing — let it complete before starting another';
  end if;

  update key_vault set
    format_version                       = (payload->>'format_version')::int,
    kdf_algorithm                        = payload->>'kdf_algorithm',
    kdf_argon2_version                   = (payload->>'kdf_argon2_version')::int,
    kdf_memory_kib                       = (payload->>'kdf_memory_kib')::int,
    kdf_iterations                       = (payload->>'kdf_iterations')::int,
    kdf_parallelism                      = (payload->>'kdf_parallelism')::int,
    kdf_salt                             = payload->>'kdf_salt',
    kdf_output_bytes                     = (payload->>'kdf_output_bytes')::int,
    master_wrapped_by_passphrase         = payload->>'master_wrapped_by_passphrase',
    master_wrapped_by_recovery           = payload->>'master_wrapped_by_recovery',
    corpus_key_id                        = payload->>'corpus_key_id',
    corpus_key_wrapped_by_master         = payload->>'corpus_key_wrapped_by_master',
    journal_bridge_key_id                = payload->>'journal_bridge_key_id',
    journal_bridge_key_wrapped_by_master = payload->>'journal_bridge_key_wrapped_by_master',
    master_wrapped_by_apple_held         = payload->>'master_wrapped_by_apple_held',
    apple_key_id                         = payload->>'apple_key_id',
    key_proof_hash                       = coalesce(payload->>'key_proof_hash', key_proof_hash),
    corpus_previous_key_id               = incoming_previous_id,
    corpus_previous_wrapped_by_master    = incoming_previous,
    rotation_started_seq                 = next_seq,
    updated_by_device                    = payload->>'updated_by_device',
    revision                             = expected_revision + 1,
    updated_at                           = now()
  where user_id = caller and revision = expected_revision;
  get diagnostics updated_rows = row_count;
  if updated_rows = 0 then
    raise exception 'VARIORUM_VAULT_REVISION_CONFLICT: the vault changed since it was fetched — fetch it again and re-derive';
  end if;

  return jsonb_build_object(
    'revision', expected_revision + 1,
    'rotation_started_seq', next_seq);
end;
$$;

-- ---------------------------------------------------------------------------
-- 8. account_purge — 11-era body verbatim; the ONE change: the caller's
--    `sync_owner_seq` row goes with the account (the 13j letter — the
--    whole account goes; a re-created account is a NEW uuid and starts
--    its own counter at 1). `account_data_truncate` deliberately does NOT
--    touch the counter — the owner's sequence stays monotonic across a
--    re-key (cursors stay valid; SyncSpec §9 per-owner).
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
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
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

  -- The purge machinery's own account rows go with the account — and,
  -- since 13y, the account's sequence counter with them.
  delete from device_cursor where owner_id = caller;
  delete from purged_row where owner_id = caller;
  delete from sync_owner_seq where owner_id = caller;

  delete from key_vault where user_id = caller;
  get diagnostics vault_rows = row_count;

  delete from entitlement where user_id = caller;
  get diagnostics entitlement_rows = row_count;

  -- The auth user LAST — the deliberate reporting order (ladder R1-2).
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
-- 9. THE GLOBAL SEQUENCE RETIRES (F-S4): nothing references
--    `sync_server_seq` after the swaps above (the data tables default the
--    column to 0 and the trigger overwrites; the two direct mints now
--    draw per-owner). Dropping it is the fail-loud closure — a future
--    artifact that quietly `nextval`s the global counter ERRORS instead
--    of silently reopening the cross-tenant disclosure this event closes.
-- ---------------------------------------------------------------------------

drop sequence if exists sync_server_seq;

-- ---------------------------------------------------------------------------
-- 10. Ownership + the demotion posture. `create or replace` preserved the
--     owner and ACL for sync_purge_execute / key_vault_update /
--     account_purge (their signatures are unchanged); the DROPPED-and-
--     re-created sync_pull returns to the definer owner through the
--     CREATE-for-acquisition dance (the 10/11 idiom), and its grants are
--     re-stated (they died with the drop). `next_owner_seq` takes the
--     helper posture (the `sync_table_pk` class): reachable by NO API
--     role — the trigger and the definer bodies are its only callers,
--     and Supabase's CREATE-time default EXECUTE-to-PUBLIC is revoked by
--     name (the memo §2's recorded footgun).
-- ---------------------------------------------------------------------------

grant usage, create on schema public to variorum_definer;
alter function sync_pull(bigint, text, text, int, text) owner to variorum_definer;
revoke create on schema public from variorum_definer;

revoke execute on function sync_pull(bigint, text, text, int, text) from public, anon;
grant execute on function sync_pull(bigint, text, text, int, text) to authenticated, service_role;

revoke execute on function next_owner_seq(uuid) from public, anon, authenticated, service_role;
grant execute on function next_owner_seq(uuid) to variorum_definer;

-- Belt (idempotent; `create or replace` preserves ACLs): the re-created
-- bodies keep their standing postures, re-affirmed by name.
revoke execute on function sync_purge_execute(jsonb, text, text) from public, anon, service_role;
grant execute on function sync_purge_execute(jsonb, text, text) to authenticated;
revoke execute on function key_vault_update(jsonb, int, text) from public, anon, service_role;
grant execute on function key_vault_update(jsonb, int, text) to authenticated;
revoke execute on function account_purge() from public, anon, service_role;
grant execute on function account_purge() to authenticated;

-- ---------------------------------------------------------------------------
-- 11. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
--     TRANSACTION, immediately before commit — a partial deploy can never
--     advertise the new version. The mirror now speaks lockstep version 9.
--     Must equal SyncSchema.lockstepVersion in the client — the in-repo
--     DDL pin fails the build if they drift.
-- ---------------------------------------------------------------------------

insert into sync_meta (key, value) values ('lockstep_version', '9')
  on conflict (key) do update set value = excluded.value;

commit;

-- Verification (read-only; the window runs these — the checklist's shape):
--   select sync_schema_version();                                    -- 9
--   select count(*) from sync_owner_seq;                             -- ≥ 1 (her account)
--   select owner_id, last_seq from sync_owner_seq;                   -- her floor ≥ her devices' cursors
--   select pg_get_functiondef('key_vault_update(jsonb, int, text)'::regprocedure)
--          like '%VARIORUM_ROTATION_ROWS_REMAIN%';                   -- true (the fold-in)
--   select pg_get_functiondef('key_vault_update(jsonb, int, text)'::regprocedure)
--          like '%next_owner_seq%';                                  -- true (M3)
--   select to_regclass('public.sync_server_seq') is null
--          and not exists (select 1 from pg_class where relname = 'sync_server_seq');
--                                                                    -- the global counter is gone
--   select oid::regprocedure from pg_proc where proname = 'sync_pull';
--                                                                    -- ONE row: sync_pull(bigint,text,text,integer,text)
--   plus maintenance/14c-post-deploy-grant-sweep.sql — every row OK/INFO.
