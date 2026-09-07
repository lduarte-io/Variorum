-- pre-13x — THE LADDER's ROUND-1 REPAIR (2026-09-06, fix session F1; the cold reviewer's BLOCKER-1, adopted whole by
-- the orchestrator): THE ROTATION'S COMPLETION GUARD on `key_vault_update`'s clearing arm.
--
-- WHAT THE REVIEWER TRACED (`notes/plans/pre-13x-ladder-round-1.md`, BLOCKER-1): `sync_pull` never serves a row
-- whose `server_written_at` is within the last 2 s (the A5 visibility horizon — 11's `sync_pull`, lines ~587/599).
-- A push that passed the OLD gate holds the vault row FOR SHARE, so `key_vault_update`'s FOR UPDATE waits for it to
-- commit: that push's rows land BELOW `rotation_started_seq` (decision 31, pinned) yet stay INVISIBLE to pulls for up
-- to 2 s after their write. The client's walk (`CorpusRotation.reencryptRemainder`) re-encrypts what it can SEE and
-- returned at its first empty window; on a small corpus both passes finished inside the window, and the clearing
-- write (completion) then NULLed the previous key, its id and the seq — the straggler was left sealed under a key
-- that existed in NO vault column and NO custody item, below a seq nobody records. Every later pull of the account,
-- on every device, opened it by the seq rule with the CURRENT key and failed at decrypt: the whole pull refused,
-- cursor unmoved, forever (availability, not confidentiality — the row is pre-switch writing).
--
-- THE FIX HAS TWO HALVES (the design's §3.10: "the rotation is complete when a device at head finds no row of its
-- own below it" — decision 31's letter). The CLIENT half (F1, `Sync/`): the walk waits past the horizon after its
-- first empty window and pulls once more; the runner re-walks on this refusal. THIS FILE IS THE SERVER HALF — the
-- STRUCTURAL one: the clearing write is REFUSED while any row of the caller's partition, in a table that CARRIES
-- CIPHERTEXT, still sits below the rotation seq. The server sees every COMMITTED row regardless of the horizon, and
-- every in-flight old-proof push holds FOR SHARE on the vault row, so after the FOR UPDATE is acquired the count is
-- EXACT: a row below the seq is a row the walk has not re-encrypted (every re-encrypted row was re-stamped ABOVE the
-- seq by `sync_reencrypt`). THE COUNT IS OVER ROWS THAT CARRY CIPHERTEXT — a row of an encrypted table with at
-- least one of its encrypted columns NOT NULL (the `e1:` values; the orchestrator's qualification, refined at the
-- author's question "is there a guarantee the horizon always clears?"): a row with no encrypted column, or with
-- every encrypted column NULL (a block with no name and no presentation), is under no key at all (the client seam
-- returns it untouched), so holding a completion hostage to its visibility would protect nothing — and a guard
-- that counted it could refuse FOREVER over a row no walk needs to touch. The client walk re-seals and re-stamps
-- EVERY row below the seq (it never skips one), so what it touches is a superset of what this guard counts: the two
-- agree by construction. The per-table column map below is pinned EQUAL to the client registry's encrypted
-- columns (`AuthRLSDDLTests`), so a future encrypted column cannot escape the guard.
--
-- WHAT THIS IS, and IS NOT: a BODY change to `key_vault_update` — the SAME signature, the SAME body as
-- `11_pre13x_postures.sql` section 13 plus ONE clause in the `incoming_previous is null` arm (pinned line for line:
-- the maintenance body with its two fenced additions removed EQUALS 11's). A stricter refusal is additive under
-- SyncSpec §12's letter: a client that predates it meets a new marker on ONE call (its clearing write), its marker
-- stays at `.reencrypt`, and its next resume re-walks — by then the straggler is visible — and completes (F1 read
-- the `.reencrypt` resume road of the shipped build to confirm this). NO lockstep bump: the marker STAYS 8; a
-- marker-8 client and this mirror keep serving each other. `11_pre13x_postures.sql` itself is UNTOUCHED (the
-- orchestrator's rule: the maintenance file is the road). Deployed by the AUTHOR (F1 never executes SQL against the
-- mirror) — the mirror FIRST, then the refreshed installs; her ledger-51 Replace All Keys drill runs only after both.
--
-- THE FORM: the 13j window repair's (`13j-window-pull-rename.sql`) — create-or-replace the body, then re-own and
-- re-grant exactly as 11 section 14/15 do (CREATE OR REPLACE keeps an existing function's owner and ACL, so these
-- are belt-and-braces and idempotent); one transaction; the re-run guard refuses on a mirror that does not speak
-- marker 8 (11 not deployed — run 11 first) and refuses a SECOND run once the guard is in the deployed body (the
-- override setting is for a genuinely rolled-back run only). Verification queries (read-only) at the end.
--
-- >>> F1 GUARD (re-run guard — not part of the function body)
do $rerun_guard$
declare
  override        text := nullif(current_setting('variorum.allow_clearing_guard_rerun', true), '');
  deployed_marker int  := 1;
  guard_deployed  boolean := false;
begin
  if to_regclass('public.sync_meta') is not null then
    select coalesce((select value::int from sync_meta where key = 'lockstep_version'), 1)
      into deployed_marker;
  end if;
  if deployed_marker < 8 then
    raise exception using
      message = 'VARIORUM_CLEARING_GUARD_NEEDS_11: this mirror speaks lockstep marker ' || deployed_marker
                || ' — deploy 11_pre13x_postures.sql (marker 8) before this repair.';
  end if;
  if to_regprocedure('key_vault_update(jsonb, int, text)') is not null then
    guard_deployed := pg_get_functiondef('key_vault_update(jsonb, int, text)'::regprocedure)
      like '%VARIORUM_ROTATION_ROWS_REMAIN%';
  end if;
  if guard_deployed and override is null then
    raise exception using
      message = 'VARIORUM_CLEARING_GUARD_ALREADY_DEPLOYED: key_vault_update already carries the completion guard.',
      hint    = 'Nothing to do. If this re-run is genuinely intended, prepend `set variorum.allow_clearing_guard_rerun = ''yes'';` in the same execution.';
  end if;
end
$rerun_guard$;
-- <<< F1 GUARD

begin;

-- ---------------------------------------------------------------------------
-- 13 (as 11 numbers it). key_vault_update — THE ONE WRITE ROAD into the vault
--     after creation: byte-for-byte 11's body PLUS the completion guard
--     (the two fenced F1 regions). Everything 11's header says of it holds.
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
  -- >>> F1 GUARD (the completion guard's declarations)
  -- THE ENCRYPTED COLUMNS, PER TABLE — every registry table with at least
  -- one encrypted-classified column and exactly those columns (the client's
  -- `SyncTable.encryptedColumns`; pinned equal by `AuthRLSDDLTests`). A row
  -- CARRIES CIPHERTEXT when at least one of them is NOT NULL; a row with
  -- none is under no key and never holds a completion.
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
  -- <<< F1 GUARD
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
    -- >>> F1 GUARD (the clause)
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
    -- <<< F1 GUARD
    -- Completion (or no rotation): the key, its id and the seq clear together.
    next_seq := null;
  elsif vault_previous is null then
    -- A rotation begins: the next value of the rows' own sequence, inside
    -- this transaction, with the row locked.
    next_seq := nextval('sync_server_seq');
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
-- 14/15 (as 11 numbers them). Ownership + the demotion posture, re-stated
--     for this function exactly as 11 states them — CREATE OR REPLACE keeps
--     an existing function's owner and ACL, so these lines are the record's
--     belt: the NON-BYPASS definer role owns the body (the 14c gate ruling),
--     CREATE on the schema opened and closed in the same transaction for the
--     acquisition, and the account-door posture (authenticated only,
--     service_role revoked by name).
-- ---------------------------------------------------------------------------

grant usage, create on schema public to variorum_definer;
alter function key_vault_update(jsonb, int, text) owner to variorum_definer;
revoke create on schema public from variorum_definer;

revoke execute on function key_vault_update(jsonb, int, text) from public, anon, service_role;
grant execute on function key_vault_update(jsonb, int, text) to authenticated;

-- The lockstep marker is DELIBERATELY NOT touched: a body-only, stricter
-- refusal is additive under SyncSpec §12 — the mirror keeps speaking 8.

commit;

-- Verification (read-only): expect (true, 'variorum_definer', false, true, false).
select pg_get_functiondef('key_vault_update(jsonb, int, text)'::regprocedure) like '%VARIORUM_ROTATION_ROWS_REMAIN%'
         as guard_deployed,
       pg_get_userbyid(p.proowner) as owner,
       has_function_privilege('anon', 'key_vault_update(jsonb, int, text)', 'EXECUTE') as anon_execute,
       has_function_privilege('authenticated', 'key_vault_update(jsonb, int, text)', 'EXECUTE') as authenticated_execute,
       has_function_privilege('service_role', 'key_vault_update(jsonb, int, text)', 'EXECUTE') as service_role_execute
  from pg_proc p
 where p.oid = 'key_vault_update(jsonb, int, text)'::regprocedure;
-- And the marker still reads 8:
select value from sync_meta where key = 'lockstep_version';
