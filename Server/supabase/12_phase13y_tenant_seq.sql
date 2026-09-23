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
--   * `sync_tenant_seq` — the per-owner counter table (server-only, never
--     a mirror data table, never in an allowlist or a payload), one row
--     per account, on the `device_cursor` posture (FORCE RLS + owner
--     policy + definer grants);
--   * `next_tenant_seq(for_tenant)` — the ONE counter function: a
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
--     key. The body is 11's VERBATIM below the signature except ONE swap
--     — the A5 horizon's filter now DERIVES from the serving function
--     (next bullet); the device-cursor upsert, the owner scoping and the
--     subtraction all byte-kept;
--   * THE A5 HORIZON EXPOSED — served and enforced by ONE function (the
--     R-13y-4 fork's ruling, Shape 1; the pre-13x closeout's
--     consideration 2, her instruction): `sync_visibility_horizon_ms()`
--     returns the constant 2000 on `sync_schema_version()`'s exact shape
--     and grants, and `sync_pull` reads it ONCE into a local and derives
--     its filter interval FROM it — no inline interval literal survives
--     in the pull body, so the served value and the enforced value
--     CANNOT drift (BLOCKER-1's class closed by construction). The
--     client's rotation walk fetches the served value and waits
--     served + margin (`CorpusRotation.horizonWait(forServedMillis:)`;
--     margin 500 ms, stated as derived — today's 2500 − 2000). A future
--     horizon change is a deliberate §12-grammar act moving this ONE
--     function; the client wait re-derives for free;
--   * `account_purge` gains the caller's `sync_tenant_seq` row — the whole
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
-- WHAT UNIT B ADDS TO THE SAME EVENT (the ruled memo
-- `notes/plans/phase-13y-memo-key-proof-challenge.md`, R-13y-4,
-- QUESTIONS #144 a/b/c — one marker, one window, one transaction):
--   * THE KEY-PROOF CHALLENGE (memo §3): the static bearer proof retires —
--     every gated RPC's `key_proof` becomes a PER-REQUEST value
--     `base64(HMAC-SHA256(kp2, nonce ‖ ':' ‖ rpc_name))` beside a new
--     defaultless `challenge` parameter carrying the nonce, where
--     `kp2 = HMAC-SHA256(M, "variorum.key-proof.v2")` — deliberately NOT
--     the v1 value, so every hypothetical captured log of the v1 era holds
--     a value the new protocol never accepts. kp2 lives in SUPABASE VAULT
--     (`vault.create_secret`, name `kp:<owner uuid>`; backups stay
--     ciphertext — the confirmed property), read ONLY inside the verify;
--     `key_vault.key_proof_hash` becomes `SHA-256(kp2)` after enrollment
--     and keeps its roles (the integrity record; the enroll compare).
--     The nonce table `key_proof_challenge` is per-owner capped at 64
--     (oldest evicted), GC'd at every mint, TTL 5 minutes on the SERVER
--     clock only (§9: no client-clock trust); the verify consumes the
--     nonce ATOMICALLY (DELETE … RETURNING — single-use by construction),
--     recomputes the HMAC from the Vault-held secret, and compares via the
--     standing 64-hex constant-time loop (hoisted into ONE helper,
--     `sync_constant_time_equal`, shared with the enroll road). Binding
--     `rpc_name` stops cross-RPC splicing of an unconsumed pair; the
--     request BODY is deliberately NOT bound (TLS carries transit
--     integrity; jsonb canonicalization is a bug farm — the memo's stated
--     reason). `sync_challenge(n)` (session-gated, n ≤ 32) mints nonce
--     batches; `key_proof_enroll(kp1, kp2, active_key_id)` is the ONE
--     enrollment road — the OLD hash authorizes the successor, once, FOR
--     UPDATE on the vault row; a second call refuses
--     (VARIORUM_KEY_PROOF_ALREADY_ENROLLED — the racing loser proceeds,
--     its kp2 is the same value, both derive from M). The NULL-hash
--     first-proof migration arm (hers, spent 2026-09-06) RETIRES with the
--     static road. `key_vault_update` gains the rotation's successor:
--     a payload installing a NEW `key_proof_hash` must carry `key_proof_mac`
--     (kp2′, whose SHA-256 must equal the new hash) and the row's hash and
--     the Vault secret land TOGETHER — or the account's followers, who
--     derive kp2′ from M′, would be refused forever. Honest residue,
--     stated (memo §3): kp values still transit the body at ENROLLMENT
--     (once per account) and ROTATION (per rotation) — the shared-secret
--     floor; asymmetric in-database is ruled out (pgsodium deprecation).
--   * THE MINIMAL ABUSE GUARD (memo §4; the numbers ruled, the table shape
--     the UNIT B implementer's plan-recorded proposal): ONE per-owner
--     `sync_write_budget` row + a TUMBLING 24-hour window — a
--     500,000-row LIFETIME first-load pool before any daily check (her
--     constraint: a one-time import is an HONEST burst — a 10k-note
--     import lands ~50–100k rows, ×5–10 headroom), then 50,000 accepted
--     row-writes per window; a per-call batch cap of 2,000 (the measured
--     shipped chunk, `SyncEngine.batchSize` = 200, ×10). `sync_push` is
--     the ONLY quota'd door; `sync_reencrypt` is EXEMPT (a rotation
--     rewrites the corpus by design); `sync_purge_execute` takes no quota
--     (removal is a right); `account_data_truncate` RESETS the pool by
--     deleting the row (delete-and-set-up-again's repush IS a first
--     load). The refusal is typed VARIORUM_WRITE_QUOTA carrying
--     `retry_after_seconds=<n>`; the increment counts the ACTUAL accepted
--     rows, after the CAS loop, on the same locked row. Deliberate
--     corner, stated: a pool burned inside one window meets the daily
--     limit immediately for that window's remainder — only the abuse
--     shape ever reaches it. 13t re-prices every number.
--   * THE RE-AUTH DOORS (memo §5; the ADDENDUM's item 2): the two
--     destructive RPCs — `account_data_truncate` and `sync_purge_execute`
--     — require a session re-authenticated by PASSWORD within 10 MINUTES,
--     read from the JWT's `amr` (the newest password-method timestamp);
--     absent or stale refuses typed VARIORUM_REAUTH_REQUIRED. This
--     matches the doors' client flow exactly (they verify the account
--     password through a sign-in immediately before acting); the window's
--     empirical probe (memo §5) confirms the amr timestamp survives a
--     token refresh, or the fallback comes back for a re-ruling.
--   * THE SIGNATURES: every gated RPC gains the defaultless `challenge`
--     (before the defaulted parameters — the NIT-4 discipline), so the
--     OLD signatures are DROPPED FIRST (section 0 — the 09/10/11
--     discipline: an overload left standing would be a challenge-free
--     door beside the new one); the two gate helpers re-shape the same
--     way. Ownership and grants are re-stated for every dropped-and-
--     re-created function (they die with a drop; section 11).
--
-- WHAT DOES NOT CHANGE: the entitlement gate; the A5 horizon; every
-- data-table policy and payload shape; `sync_schema_version()`'s own
-- shape; `account_purge`'s session-only posture (deletion is mandated
-- and loud — no proof, no challenge; it now takes the account's
-- challenge rows, budget row and Vault secret WITH the account). Client
-- semantics beyond the proof's carriage are UNCHANGED AND TEST-PINNED
-- (the phase's premise, Step 0-verified): a client's cursor only ever
-- meets own-account rows, and every seq comparison any client makes is
-- between own-account numbers — per-tenant sequences preserve every
-- relative order any client ever observes.
--
-- PENDING-UNTIL-LIVE (the 13j-window class, each verified at HER window
-- before the installs): `vault.create_secret`/`vault.update_secret`
-- availability + the definer-role grant road on the hosted project (the
-- memo §2's community-converged pattern — the verification tail carries
-- the read-only probes); `extensions.hmac`/`extensions.gen_random_bytes`
-- resolution (pgcrypto lives in the `extensions` schema on Supabase — the
-- two new bodies that need it carry `search_path = public, extensions`);
-- the `auth.jwt() -> 'amr'` password-timestamp refresh-survival probe
-- (memo §5's named check); and `account_purge`'s best-effort Vault-secret
-- delete under its `postgres` owner.
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
-- a column it writes. `for_tenant` is none of `sync_tenant_seq`'s columns
-- (`owner_id`, `last_seq`) — the `for_device` idiom exactly. UNIT B's
-- parameters hold it too: `challenge` / `rpc_name` are none of
-- `key_proof_challenge`'s columns (`owner_id`, `nonce`, `issued_at` —
-- which the proof check DELETEs against); `n` is none of them either;
-- `kp1` / `kp2` / `active_key_id` are none of `key_vault`'s.

begin;

-- ---------------------------------------------------------------------------
-- 0a. THE RE-RUN GUARD — first statement inside the transaction, before
--     the destructive drop below. Keyed on evidence only a deployed 12
--     leaves: the marker at 9+, or the `sync_tenant_seq` table no other
--     artifact creates.
-- ---------------------------------------------------------------------------

do $rerun_guard$
declare
  override            text    := nullif(current_setting('variorum.allow_12_rerun', true), '');
  deployed_marker     int     := 1;
  counter_table_here  boolean := to_regclass('public.sync_tenant_seq') is not null;
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
                || deployed_marker || '; sync_tenant_seq table '
                || case when counter_table_here then 'present' else 'absent' end || ').',
      hint    = 'If this re-run is genuinely intended, prepend `set variorum.allow_12_rerun = ''yes-rerun-the-tenant-seq-event'';` in the same execution. Otherwise: nothing to do — the mirror already speaks this schema.';
  end if;
end
$rerun_guard$;

-- ---------------------------------------------------------------------------
-- 0. Drop the OLD signatures before creating the new ones (Postgres
--    overloads by signature — the 09/10/11 discipline): a lingering
--    sync_pull(bigint, text, int, text, text) would keep serving the
--    changefeed with a DEFAULTED proof parameter beside the new one — and,
--    since UNIT B, EVERY gated RPC's signature gains the defaultless
--    `challenge`, so every 11-era overload left standing would be a
--    CHALLENGE-FREE door beside the new one (the static-bearer road this
--    half of the event exists to close). The two gate helpers re-shape the
--    same way and drop with them.
-- ---------------------------------------------------------------------------

drop function if exists sync_pull(bigint, text, int, text, text);
drop function if exists sync_push(jsonb, text, text);
drop function if exists sync_horizon(text, text);
drop function if exists sync_purge_ledger(bigint, text, text);
drop function if exists sync_purge_execute(jsonb, text, text);
drop function if exists account_data_truncate(text, text);
drop function if exists sync_reencrypt(jsonb, text, text);
drop function if exists key_vault_update(jsonb, int, text);
drop function if exists sync_key_gate(text, text);
drop function if exists sync_key_proof_check(text);

-- ---------------------------------------------------------------------------
-- 1. sync_tenant_seq — the per-owner counter (server-only: never a mirror
--    data table, never in an allowlist, never in a payload). One row per
--    account; the `device_cursor` posture exactly. Every mint path runs
--    with the caller's auth context (the trigger fires inside the
--    SECURITY DEFINER bodies as `variorum_definer`, whose row reach the
--    FORCE-RLS owner policy scopes to auth.uid() — the calling account).
-- ---------------------------------------------------------------------------

create table sync_tenant_seq (
  owner_id uuid   not null,
  last_seq bigint not null default 0,
  primary key (owner_id)
);
alter table sync_tenant_seq enable row level security;
alter table sync_tenant_seq force row level security;
create policy sync_tenant_seq_owner_all on sync_tenant_seq
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on sync_tenant_seq from anon, authenticated;
grant select, insert, update on sync_tenant_seq to variorum_definer;

-- ---------------------------------------------------------------------------
-- 2. next_tenant_seq — the ONE counter function: a row-locked
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

create or replace function next_tenant_seq(for_tenant uuid) returns bigint
language plpgsql
set search_path = public
as $$
declare
  granted bigint;
begin
  insert into sync_tenant_seq (owner_id, last_seq)
  values (for_tenant, 1)
  on conflict (owner_id) do update
    set last_seq = sync_tenant_seq.last_seq + 1
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

insert into sync_tenant_seq (owner_id, last_seq)
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
  set last_seq = greatest(sync_tenant_seq.last_seq, excluded.last_seq);

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
  new.server_seq := next_tenant_seq(new.owner_id);
  new.server_written_at := clock_timestamp();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. sync_visibility_horizon_ms — THE ONE HORIZON (the R-13y-4 fork's
--    ruling, Shape 1): the A5 visibility horizon, in milliseconds, served
--    as a constant on `sync_schema_version()`'s exact shape (zero-arg,
--    STABLE, definer, the same grants). `sync_pull` below derives its
--    filter interval FROM this function — the served value and the
--    enforced value are ONE definition, un-driftable by construction
--    (the rider's whole demand: one constant moving without the other
--    reopens BLOCKER-1's class). A horizon change is a deliberate
--    §12-grammar act — a numbered artifact moving this one function, the
--    client's wait re-deriving for free — never an operator dial, which
--    is why this is a constant-returning function and not a `sync_meta`
--    row (Shape 2's tunability declined: a knob makes the dumb server
--    less dumb for no present need).
-- ---------------------------------------------------------------------------

create or replace function sync_visibility_horizon_ms() returns bigint
language sql stable security definer
set search_path = public
as $$
  select 2000;
$$;

-- ---------------------------------------------------------------------------
-- 5b. key_proof_challenge — the single-use nonce table (UNIT B, memo §3).
--     Server-only (never a mirror data table, never in an allowlist, never
--     in a payload); the `device_cursor` posture. A row IS one unconsumed
--     challenge: minted by `sync_challenge`, consumed ATOMICALLY by the
--     proof check's DELETE … RETURNING (single-use by construction),
--     GC'd at every mint, capped at 64 live rows per owner (memo §7 edge
--     3: the table is bounded by 64 × live accounts). `issued_at` is the
--     SERVER clock — the 5-minute TTL trusts nothing a client stamps.
-- ---------------------------------------------------------------------------

create table key_proof_challenge (
  owner_id  uuid        not null,
  nonce     bytea       not null,
  issued_at timestamptz not null default clock_timestamp(),
  primary key (owner_id, nonce)
);
alter table key_proof_challenge enable row level security;
alter table key_proof_challenge force row level security;
create policy key_proof_challenge_owner_all on key_proof_challenge
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on key_proof_challenge from anon, authenticated;
grant select, insert, delete on key_proof_challenge to variorum_definer;

-- ---------------------------------------------------------------------------
-- 5c. sync_write_budget — the minimal abuse guard's accounting row (UNIT B,
--     memo §4; the numbers ruled at QUESTIONS #144(b), the shape the
--     plan-recorded proposal, ADJUDICATED approved-as-proposed). ONE row
--     per owner, no write log — the guard must never be its own write
--     amplifier. Server-only, the `device_cursor` posture.
-- ---------------------------------------------------------------------------

create table sync_write_budget (
  owner_id      uuid        not null,
  lifetime_rows bigint      not null default 0,
  window_start  timestamptz not null default clock_timestamp(),
  window_rows   bigint      not null default 0,
  primary key (owner_id)
);
alter table sync_write_budget enable row level security;
alter table sync_write_budget force row level security;
create policy sync_write_budget_owner_all on sync_write_budget
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
revoke all on sync_write_budget from anon, authenticated;
grant select, insert, update, delete on sync_write_budget to variorum_definer;

-- ---------------------------------------------------------------------------
-- 5d. sync_constant_time_equal — the standing 64-hex constant-time compare
--     (11's proof-check loop, hoisted into ONE helper so the challenge
--     verify and the enroll road share one implementation): a fixed
--     64-step loop over the hex digits accumulating XOR into an OR, never
--     short-circuiting (`ascii('')` is 0 past either string's end; the
--     lengths join the accumulator last). The `sync_table_pk` posture —
--     reachable by NO API role.
-- ---------------------------------------------------------------------------

create or replace function sync_constant_time_equal(a text, b text) returns boolean
language plpgsql
set search_path = public
as $$
declare
  acc int := 0;
  i int;
begin
  for i in 1..64 loop
    acc := acc | (ascii(substr(a, i, 1)) # ascii(substr(b, i, 1)));
  end loop;
  acc := acc | (length(a) # length(b));
  return acc = 0;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5e. sync_challenge — the nonce mint (UNIT B, memo §3). SESSION-GATED
--     ONLY, deliberately (memo §7 edge 7): a sessionless caller gets
--     nothing; a session-holder can at worst churn its own 64 rows. No
--     vault requirement — a not-yet-enrolled account fetches challenges
--     too (its first gated call refuses VARIORUM_KEY_PROOF_ENROLL and the
--     client enrolls, then spends the same batch). `n` is clamped to 32
--     per call; the caller's EXPIRED rows are GC'd at every mint; the
--     64-row cap evicts oldest-first. `extensions.gen_random_bytes` —
--     pgcrypto lives in the `extensions` schema on Supabase, hence this
--     body's widened search_path.
-- ---------------------------------------------------------------------------

create or replace function sync_challenge(n int) returns jsonb
language plpgsql security definer
set search_path = public, extensions
as $$
declare
  caller uuid;
  granted int;
  fresh bytea;
  minted jsonb := '[]'::jsonb;
  live int;
  i int;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;
  granted := least(greatest(coalesce(n, 1), 1), 32);
  delete from key_proof_challenge
    where owner_id = caller
      and issued_at < clock_timestamp() - interval '5 minutes';
  for i in 1..granted loop
    fresh := extensions.gen_random_bytes(32);
    insert into key_proof_challenge (owner_id, nonce) values (caller, fresh);
    minted := minted || to_jsonb(encode(fresh, 'base64'));
  end loop;
  select count(*) into live from key_proof_challenge where owner_id = caller;
  if live > 64 then
    delete from key_proof_challenge
      where owner_id = caller
        and nonce in (
          select c.nonce from key_proof_challenge c
          where c.owner_id = caller
          order by c.issued_at asc
          limit live - 64);
  end if;
  return minted;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5f. key_proof_enroll — THE ONE ENROLLMENT ROAD (UNIT B, memo §3): the
--     EXISTING hash authorizes the successor, ONCE per account, FOR
--     UPDATE on the vault row (two racing devices serialize; the loser
--     meets VARIORUM_KEY_PROOF_ALREADY_ENROLLED and proceeds — its kp2 is
--     the same value, both derive from M). The secret and the hash land
--     TOGETHER, one transaction: `vault.create_secret(kp2)` under the
--     unique name `kp:<owner uuid>` + `key_proof_hash = SHA-256(kp2)`.
--     The NULL-hash migration arm is RETIRED with the static road (hers
--     landed 2026-09-06; creation lands one by trigger) — a hash-less row
--     refuses rather than adopting a first-comer.
-- ---------------------------------------------------------------------------

create or replace function key_proof_enroll(kp1 text, kp2 text, active_key_id text) returns void
language plpgsql security definer
set search_path = public
as $$
declare
  caller uuid;
  vault_fence_key text;
  stored_hash text;
  presented_hash text;
  successor_hash text;
  existing_secret uuid;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;
  select corpus_key_id, key_proof_hash into vault_fence_key, stored_hash
    from key_vault where user_id = caller for update;
  if vault_fence_key is null or vault_fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;
  select s.id into existing_secret
    from vault.secrets s where s.name = 'kp:' || caller::text;
  if existing_secret is not null then
    raise exception 'VARIORUM_KEY_PROOF_ALREADY_ENROLLED: this account''s per-request key proof is already enrolled';
  end if;
  begin
    presented_hash := encode(sha256(decode(kp1, 'base64')), 'hex');
    successor_hash := encode(sha256(decode(kp2, 'base64')), 'hex');
  exception when others then
    presented_hash := null;
  end;
  if stored_hash is null or presented_hash is null
     or not sync_constant_time_equal(stored_hash, presented_hash) then
    raise exception 'VARIORUM_KEY_PROOF_REQUIRED: this session holds no proof of the account''s master key — pick up your keys before syncing';
  end if;
  perform vault.create_secret(kp2, 'kp:' || caller::text);
  update key_vault set key_proof_hash = successor_hash where user_id = caller;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5g. THE PROOF CHECK, REWORKED (UNIT B, memo §3 — replacing 11's static
--     compare): the re-read under the caller's held lock stays; then, in
--     THIS order — (1) the Vault-held MAC secret is read (ABSENT refuses
--     VARIORUM_KEY_PROOF_ENROLL, BEFORE any nonce is consumed, so the
--     enroll road's retry still holds a live challenge); (2) the nonce is
--     consumed atomically (DELETE … RETURNING — an unknown, already-used
--     or malformed challenge refuses VARIORUM_KEY_PROOF_STALE_CHALLENGE;
--     single-use by construction, THE replay closure); (3) the 5-minute
--     server-clock TTL; (4) the HMAC recomputed from the Vault-held kp2
--     over `nonce ‖ ':' ‖ rpc_name` (the binding that stops cross-RPC
--     splicing), compared constant-time. A malformed proof refuses the
--     same way — never a raw decode error. `extensions.hmac` — pgcrypto's
--     schema on Supabase, hence the widened search_path.
-- ---------------------------------------------------------------------------

create or replace function sync_key_proof_check(key_proof text, challenge text, rpc_name text) returns void
language plpgsql
set search_path = public, extensions
as $$
declare
  caller uuid;
  vault_found boolean := false;
  stored_mac text;
  presented_nonce bytea;
  nonce_issued_at timestamptz;
  expected_hex text;
  presented_hex text;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- The re-read under the caller's lock (no lock clause of its own — a
  -- FOR SHARE here would be a no-op for a FOR UPDATE holder and an UPGRADE
  -- hazard is what the gate's peek exists to avoid).
  select true into vault_found from key_vault where user_id = caller;
  if not coalesce(vault_found, false) then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

  select ds.decrypted_secret into stored_mac
    from vault.decrypted_secrets ds
    where ds.name = 'kp:' || caller::text;
  if stored_mac is null then
    raise exception 'VARIORUM_KEY_PROOF_ENROLL: this account holds no per-request proof secret yet — enroll before this call';
  end if;

  begin
    presented_nonce := decode(challenge, 'base64');
  exception when others then
    presented_nonce := null;
  end;
  if presented_nonce is null then
    raise exception 'VARIORUM_KEY_PROOF_STALE_CHALLENGE: the challenge is unknown, already used, or expired — fetch a fresh challenge and retry once';
  end if;
  delete from key_proof_challenge
    where owner_id = caller and nonce = presented_nonce
    returning issued_at into nonce_issued_at;
  if nonce_issued_at is null then
    raise exception 'VARIORUM_KEY_PROOF_STALE_CHALLENGE: the challenge is unknown, already used, or expired — fetch a fresh challenge and retry once';
  end if;
  if nonce_issued_at < clock_timestamp() - interval '5 minutes' then
    raise exception 'VARIORUM_KEY_PROOF_STALE_CHALLENGE: the challenge is unknown, already used, or expired — fetch a fresh challenge and retry once';
  end if;

  begin
    expected_hex := encode(extensions.hmac(
      decode(stored_mac, 'base64'),
      presented_nonce || convert_to(':' || rpc_name, 'utf8'),
      'sha256'), 'hex');
    presented_hex := encode(decode(key_proof, 'base64'), 'hex');
  exception when others then
    presented_hex := null;
  end;
  if presented_hex is null
     or not sync_constant_time_equal(expected_hex, presented_hex) then
    raise exception 'VARIORUM_KEY_PROOF_REQUIRED: this session holds no proof of the account''s master key — pick up your keys before syncing';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5h. THE GATE, REWORKED (UNIT B): 11's body — the lock choice, the fence
--     — with the challenge and the calling RPC's name passed through to
--     the proof check. The gate ORDER is unchanged (the memo's letter):
--     the lock choice → the `active_key_id` fence → the proof, now
--     challenge-verified. The FOR UPDATE arm of the lock choice survives
--     as the conservative lock on a hash-less row (an impossible state
--     since the migration arm's retirement — creation lands a hash by
--     trigger and hers landed 2026-09-06; a hash-less row now dead-ends
--     at the proof check's enroll refusal, whose enroll road refuses a
--     NULL hash in turn: correct-by-refusal, never adopted).
-- ---------------------------------------------------------------------------

create or replace function sync_key_gate(active_key_id text, key_proof text, challenge text, rpc_name text) returns void
language plpgsql
set search_path = public
as $$
declare
  caller uuid;
  fence_key text;
  peek_hash text;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE LOCK CHOICE: the unlocked peek, then the row locked for the round.
  select key_proof_hash into peek_hash from key_vault where user_id = caller;
  if peek_hash is null then
    select corpus_key_id into fence_key from key_vault where user_id = caller for update;
  else
    select corpus_key_id into fence_key from key_vault where user_id = caller for share;
  end if;

  -- THE VAULT-KEY-ID FENCE (THE DESIGN item 2, 14c): the caller's presented
  -- corpus key id must match the account's current key_vault row. A
  -- mismatch — or a missing vault row — refuses the WHOLE round before
  -- any row is touched (the CF-16 replaced state, client-classified).
  if fence_key is null or fence_key is distinct from active_key_id then
    raise exception 'VARIORUM_STALE_KEY_FENCE: this account''s encryption keys were replaced — the device holds a stale key id; re-enroll before syncing';
  end if;

  -- THE KEY PROOF (pre-13x decision 12; challenge-verified since 13y
  -- UNIT B): the authorization.
  perform sync_key_proof_check(key_proof, challenge, rpc_name);
end;
$$;

-- ---------------------------------------------------------------------------
-- 6. sync_pull — 11's body VERBATIM under the REORDERED signature (NIT-4):
--    `key_proof` is now DEFAULTLESS, before the genuinely-optional
--    `max_rows` / `for_device`. Zero wire change (PostgREST resolves by
--    name; the client always sends every key). The device-cursor upsert,
--    the owner scoping and the server-only column subtraction are all
--    byte-kept; the ONE swap below the signature is the A5 horizon's
--    filter, which now DERIVES from `sync_visibility_horizon_ms()` (one
--    declare line + the two branch filters — nothing else moves).
-- ---------------------------------------------------------------------------

create or replace function sync_pull(since_seq bigint, active_key_id text, key_proof text, challenge text, max_rows int default 500, for_device text default null)
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
  -- 13y (the R-13y-4 fork's Shape 1): the A5 horizon, read ONCE from the
  -- one serving function; the two branch filters below derive from this
  -- local — no inline interval literal survives in this body, so the
  -- served value and the enforced value cannot drift.
  horizon interval := make_interval(secs => sync_visibility_horizon_ms() / 1000.0);
  tbl text;
  union_sql text := '';
  result jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE GATE (pre-13x; challenge-verified since 13y UNIT B): the vault
  -- row FOR SHARE, the fence, the proof.
  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_pull');

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
  -- partition. The visibility horizon (A5) is the derived-interval
  -- filter (the `horizon` local above — `sync_visibility_horizon_ms()`,
  -- 2000 ms): rows written within that window are never served.
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
             and t.server_written_at <= clock_timestamp() - %L::interval$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq, horizon);
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
             and t.server_written_at <= clock_timestamp() - %L::interval$q$,
        tbl, sync_table_pk(tbl), tbl, caller, since_seq, horizon);
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
-- 6b. sync_push — 11's body VERBATIM except the challenge-gated signature
--     and THE MINIMAL ABUSE GUARD (UNIT B, memo §4 — the ONLY quota'd
--     door; the numbers ruled at QUESTIONS #144(b), the row shape
--     adjudicated approved-as-proposed):
--       * the per-call batch cap (2,000 — the measured shipped chunk,
--         `SyncEngine.batchSize` = 200, ×10) refuses a malformed client
--         before any row lands; the shipped engine's chunks never meet it;
--       * the owner's budget row is upsert-locked FOR UPDATE — always
--         AFTER the gate's vault lock (only push touches the budget row,
--         one lock order, no cycle: the deadlock argument, stated here);
--       * `lifetime_rows < 500000` is the FIRST-LOAD POOL: no daily check
--         applies (her constraint — a one-time import is an honest burst);
--       * past the pool, the TUMBLING 24-hour window: expired resets it,
--         and `window_rows + batch > 50000` refuses the WHOLE call typed
--         (VARIORUM_WRITE_QUOTA, `retry_after_seconds=<n>`) — the
--         refuse-whole boundary means NO overshoot, pinned as stated
--         (the adjudication's point 1); the seam's bounded ≤2× short-span
--         worst case is ACCEPTED for the minimal posture (point 2; 13t
--         re-prices);
--       * the increment counts the ACTUAL accepted rows, after the CAS
--         loop, on the same locked row — CAS rejects burn nothing.
-- ---------------------------------------------------------------------------

create or replace function sync_push(batch jsonb, active_key_id text, key_proof text, challenge text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  allowed constant text[] := array[
    'container', 'block', 'variant', 'commit_point', 'edge',
    'container_block', 'reading', 'reading_section', 'reading_post', 'tag',
    'post_tag', 'block_tag', 'reference', 'canvas_layout',
    'lens', 'lens_choice', 'block_comment', 'setting', 'purge_intent'];
  -- The tables whose CLIENT schema carries owner_id (AppSpec §6 top-level
  -- entities + their later siblings): payloads carry owner and must
  -- carry the caller's. Everything else is mirror-only-owner: the
  -- server stamps on insert and subtracts on serve.
  owner_tables constant text[] := array[
    'container', 'block', 'reading', 'tag', 'reference',
    'canvas_layout', 'lens', 'block_comment', 'purge_intent'];
  caller uuid;
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
  batch_rows int;
  budget_lifetime bigint;
  budget_window_start timestamptz;
  budget_window_rows bigint;
  accepted_rows int := 0;
  quota_retry_after int;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  -- THE GATE (pre-13x; challenge-verified since 13y UNIT B): the vault
  -- row FOR SHARE, the fence, the proof.
  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_push');

  -- THE ENTITLEMENT GATE (THE DESIGN item 5): hosted sync is the tier.
  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  -- THE MINIMAL ABUSE GUARD (UNIT B, memo §4): the batch cap, then the
  -- budget row FOR UPDATE (after the vault lock — one order, no cycle),
  -- then the pool / the tumbling window. Refusal here aborts the whole
  -- call before any row lands — the §12 grammar's server half.
  batch_rows := jsonb_array_length(batch);
  if batch_rows > 2000 then
    raise exception 'VARIORUM_WRITE_QUOTA: the batch exceeds the per-call cap — retry_after_seconds=0';
  end if;
  insert into sync_write_budget (owner_id) values (caller)
  on conflict (owner_id) do update set owner_id = excluded.owner_id
  returning lifetime_rows, window_start, window_rows
    into budget_lifetime, budget_window_start, budget_window_rows;
  if budget_lifetime >= 500000 then
    if clock_timestamp() - budget_window_start >= interval '24 hours' then
      update sync_write_budget
        set window_start = clock_timestamp(), window_rows = 0
        where owner_id = caller;
      budget_window_rows := 0;
    elsif budget_window_rows + batch_rows > 50000 then
      quota_retry_after := greatest(0, ceil(extract(epoch from
        (budget_window_start + interval '24 hours' - clock_timestamp())))::int);
      raise exception 'VARIORUM_WRITE_QUOTA: this account reached its daily write limit — retry_after_seconds=%', quota_retry_after;
    end if;
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

    -- Client-carried owner guard (the NINE, since purge_intent): a pushed
    -- row must carry the caller's own owner_id (NULL refused too — `is
    -- distinct from`).
    if tbl = any (owner_tables)
       and (item->'columns'->>'owner_id') is distinct from caller::text then
      raise exception 'owner_id mismatch on % row % — pushes must carry owner_id = auth.uid()',
        tbl, row_id;
    end if;

    -- THE PURGED-IDS LEDGER (Phase 13j — the memo's §2): a push naming a
    -- purged id is REFUSED with the typed 'purged' status. This is what
    -- makes physical removal safe under S2's bend: a stale peer's
    -- re-push can never resurrect a purged row — the client drops the
    -- outbox entry and its local copy instead of retrying. Checked
    -- BEFORE the CAS: a purged row has no CAS state to compare.
    if exists (
      select 1 from purged_row p
      where p.owner_id = caller and p.table_name = tbl and p.row_id = item->>'row_id'
    ) then
      results := results || jsonb_build_array(jsonb_build_object('status', 'purged'));
      continue;
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
        full_row := (item->'columns')
          || jsonb_build_object('sync_version', 1, 'owner_id', caller);
        execute format(
          'insert into %I select * from jsonb_populate_record(null::%I, $1) returning server_seq',
          tbl, tbl)
          into granted_seq using full_row;
        accepted_rows := accepted_rows + 1;
        results := results || jsonb_build_array(jsonb_build_object(
          'status', 'accepted', 'new_version', 1, 'server_seq', granted_seq));
      else
        results := results || jsonb_build_array(jsonb_build_object(
          'status', 'rejected', 'current', null));
      end if;
    elsif base_version = current_version then
      -- Matching base: replace the row wholesale (delete+insert is safe —
      -- nothing references a mirror row) and bump.
      full_row := (item->'columns')
        || jsonb_build_object('sync_version', current_version + 1, 'owner_id', caller);
      execute format('delete from %I where owner_id = $2 and %I = $1', tbl, pk)
        using row_id, caller;
      execute format(
        'insert into %I select * from jsonb_populate_record(null::%I, $1) returning server_seq',
        tbl, tbl)
        into granted_seq using full_row;
      accepted_rows := accepted_rows + 1;
      results := results || jsonb_build_array(jsonb_build_object(
        'status', 'accepted', 'new_version', current_version + 1, 'server_seq', granted_seq));
    else
      -- Stale base: reject WITH the current row so the client can merge
      -- deterministically and push again (SyncSpec §4). No server
      -- merging. The served payload subtracts the server-only columns —
      -- and, for the mirror-only-owner tables, the stamped owner_id.
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
  -- THE GUARD's increment: the ACTUAL accepted rows, on the same locked
  -- row (memo §4's "accepted row-writes" — CAS rejects burn nothing).
  if accepted_rows > 0 then
    update sync_write_budget
      set lifetime_rows = lifetime_rows + accepted_rows,
          window_rows   = window_rows + accepted_rows
      where owner_id = caller;
  end if;
  return results;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. sync_purge_execute — 11's body VERBATIM except the mint (M2): the
--    granted ledger seq draws from the CALLER's counter — the owner's
--    device cursors and `last_purge_seq` scan points are what it is
--    compared against, and they live on the same counter now — and, since
--    UNIT B, the challenge-gated signature + THE RECENT-RE-AUTH WINDOW
--    (memo §5, QUESTIONS #144(c)): a destructive RPC requires a session
--    re-authenticated by PASSWORD within 10 minutes, read from the JWT's
--    `amr` — a stolen long-lived token cannot empty an account's server
--    copy from a custom client. NO quota (removal is a right, and this
--    door writes no data rows).
-- ---------------------------------------------------------------------------

create or replace function sync_purge_execute(rows jsonb, active_key_id text, key_proof text, challenge text) returns bigint
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
  newest_password_auth timestamptz;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;
  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_purge_execute');

  -- THE RECENT-RE-AUTH WINDOW (13y UNIT B, memo §5 — 10 minutes): the
  -- session's newest PASSWORD-method amr entry must be inside it; absent
  -- or stale refuses typed. The doors' client flow signs in immediately
  -- before acting, so an honest act always passes.
  select to_timestamp(max((amr_entry->>'timestamp')::bigint))
    into newest_password_auth
    from jsonb_array_elements(coalesce(auth.jwt()->'amr', '[]'::jsonb)) amr_entry
    where amr_entry->>'method' = 'password';
  if newest_password_auth is null
     or newest_password_auth < now() - interval '10 minutes' then
    raise exception 'VARIORUM_REAUTH_REQUIRED: this act needs a fresh sign-in — confirm the account password and try again';
  end if;

  granted_seq := next_tenant_seq(caller);
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
-- 7b. sync_horizon — 11's body VERBATIM under the challenge-gated
--     signature. A READ, and the proof gates it too (decision 12's
--     letter): a session without the keys gets nothing from the mirror,
--     a seq included.
-- ---------------------------------------------------------------------------

create or replace function sync_horizon(active_key_id text, key_proof text, challenge text) returns bigint
language plpgsql security definer
set search_path = public
as $$
declare
  caller uuid;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;
  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_horizon');
  return coalesce(
    (select min(last_seq) from device_cursor
      where owner_id = caller and seen_at > now() - interval '60 days'),
    0);
end;
$$;

-- ---------------------------------------------------------------------------
-- 7c. sync_purge_ledger — 11's body VERBATIM under the challenge-gated
--     signature (a READ, proof-gated for the same reason).
-- ---------------------------------------------------------------------------

create or replace function sync_purge_ledger(since_seq bigint, active_key_id text, key_proof text, challenge text) returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  caller uuid;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;
  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_purge_ledger');
  return jsonb_build_object(
    'floor', 0,
    'entries', coalesce(
      (select jsonb_agg(jsonb_build_object(
         'table', p.table_name, 'row_id', p.row_id, 'purged_seq', p.purged_seq)
         order by p.purged_seq)
        from purged_row p
        where p.owner_id = caller and p.purged_seq > since_seq),
      '[]'::jsonb));
end;
$$;

-- ---------------------------------------------------------------------------
-- 7d. sync_reencrypt — 11's body VERBATIM under the challenge-gated
--     signature. DELIBERATELY NO QUOTA (memo §4's exemption): a rotation
--     rewrites the whole corpus by design, it is already proof- and
--     entitlement-gated, and a quota here would break Replace All Keys at
--     exactly the corpus sizes that matter.
-- ---------------------------------------------------------------------------

create or replace function sync_reencrypt(rows jsonb, active_key_id text, key_proof text, challenge text) returns jsonb
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
  item jsonb;
  tbl text;
  pk text;
  row_id text;
  expected_version bigint;
  current_version bigint;
  full_row jsonb;
  granted_seq bigint;
  results jsonb := '[]'::jsonb;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'sync requires an authenticated user';
  end if;

  perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_reencrypt');

  if not exists (
    select 1 from entitlement
    where user_id = caller and feature = 'hosted_sync'
      and (expires_at is null or expires_at > now())
  ) then
    raise exception 'VARIORUM_NO_ENTITLEMENT: hosted sync is not active on this account';
  end if;

  for item in select * from jsonb_array_elements(rows) loop
    tbl := item->>'table';
    if not (tbl = any (allowed)) then
      raise exception 'unknown sync table %', tbl;
    end if;
    pk := sync_table_pk(tbl);
    row_id := item->>'row_id';
    expected_version := (item->>'expected_version')::bigint;
    current_version := null;

    if tbl = any (owner_tables)
       and (item->'columns'->>'owner_id') is distinct from caller::text then
      raise exception 'owner_id mismatch on % row % — re-encryptions must carry owner_id = auth.uid()',
        tbl, row_id;
    end if;

    execute format(
      'select sync_version from %I t where t.owner_id = $2 and t.%I = $1 for update',
      tbl, pk)
      into current_version
      using row_id, caller;

    if current_version is null or current_version is distinct from expected_version then
      -- The version moved (an edit landed since the caller pulled this
      -- row) or the row is gone: skipped — the caller pulls and retries.
      results := results || jsonb_build_array(jsonb_build_object(
        'status', 'skipped', 'current_version', current_version));
      continue;
    end if;

    -- The bytes swapped, the version KEPT, a fresh seq stamped.
    full_row := (item->'columns')
      || jsonb_build_object('sync_version', current_version, 'owner_id', caller);
    execute format('delete from %I where owner_id = $2 and %I = $1', tbl, pk)
      using row_id, caller;
    execute format(
      'insert into %I select * from jsonb_populate_record(null::%I, $1) returning server_seq',
      tbl, tbl)
      into granted_seq using full_row;
    results := results || jsonb_build_array(jsonb_build_object(
      'status', 'replaced', 'server_seq', granted_seq));
  end loop;
  return results;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7e. account_data_truncate — 11's body VERBATIM under the challenge-gated
--     signature, plus UNIT B's two arms: THE RECENT-RE-AUTH WINDOW (memo
--     §5 — the second destructive RPC, same 10-minute amr check) and THE
--     POOL RESET (memo §4: the budget row is DELETED, so the next push
--     re-creates it at zero — delete-and-set-up-again's repush IS a
--     first load; the adopt road converges). The SEQ counter
--     (`sync_tenant_seq`) stays deliberately untouched — metering is
--     never ordering.
-- ---------------------------------------------------------------------------

create or replace function account_data_truncate(active_key_id text, key_proof text, challenge text) returns jsonb
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
  counts jsonb := '{}'::jsonb;
  newest_password_auth timestamptz;
begin
  caller := auth.uid();
  if caller is null then
    raise exception 'account acts require an authenticated user';
  end if;

  -- THE GATE (the sync RPCs' exact arm: the fence, then the proof).
  perform sync_key_gate(active_key_id, key_proof, challenge, 'account_data_truncate');

  -- THE RECENT-RE-AUTH WINDOW (13y UNIT B, memo §5 — 10 minutes): the
  -- session's newest PASSWORD-method amr entry must be inside it; absent
  -- or stale refuses typed. The doors' client flow signs in immediately
  -- before acting, so an honest act always passes.
  select to_timestamp(max((amr_entry->>'timestamp')::bigint))
    into newest_password_auth
    from jsonb_array_elements(coalesce(auth.jwt()->'amr', '[]'::jsonb)) amr_entry
    where amr_entry->>'method' = 'password';
  if newest_password_auth is null
     or newest_password_auth < now() - interval '10 minutes' then
    raise exception 'VARIORUM_REAUTH_REQUIRED: this act needs a fresh sign-in — confirm the account password and try again';
  end if;

  foreach tbl in array data_tables loop
    execute format('delete from %I where owner_id = $1', tbl) using caller;
    get diagnostics removed = row_count;
    counts := counts || jsonb_build_object(tbl, removed);
  end loop;
  -- THE POOL RESET (memo §4): the repush after a re-key is a FIRST LOAD.
  delete from sync_write_budget where owner_id = caller;
  return counts;
end;
$$;

-- ---------------------------------------------------------------------------
-- 8. key_vault_update — THE ONE WRITE ROAD into the vault, now carrying
--    the ROTATION COMPLETION GUARD in its CANONICAL body (the fold-in;
--    the maintenance overlay is superseded) and the per-owner mint (M3):
--    a rotation's `rotation_started_seq` draws from the CALLER's counter
--    — the seq rule (`SyncPayloadCrypto.keyMaterial`) and the completion
--    guard both compare it against the owner's own data-row seqs, which
--    live on the same counter now. Everything 11's header says of this
--    door holds; the guard's reasoning is the overlay's, verbatim.
--
--    UNIT B (memo §3, the rotation's successor): the signature gains the
--    defaultless `challenge`; the proof check is challenge-verified; and
--    a payload installing a NEW `key_proof_hash` MUST carry
--    `key_proof_mac` (kp2′, base64 — a payload KEY, never a table
--    column) whose SHA-256 equals the new hash — the row's hash and the
--    Vault-held secret then land TOGETHER in this same transaction
--    (`vault.update_secret`, or `create_secret` on a never-enrolled
--    account), because a hash that moved without its secret would refuse
--    every follower forever (they derive kp2′ from M′ and the verify
--    reads the SECRET). A mac whose hash mismatches refuses; a payload
--    with neither (a re-wrap under the same master) is byte-unchanged.
-- ---------------------------------------------------------------------------

create or replace function key_vault_update(payload jsonb, expected_revision int, key_proof text, challenge text) returns jsonb
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
  incoming_hash text;
  incoming_mac text;
  incoming_mac_hash text;
  vault_current_hash text;
  mac_secret_id uuid;
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

  perform sync_key_proof_check(key_proof, challenge, 'key_vault_update');

  -- The R1-2 revision CAS, PRE-CHECKED under the held lock (13y UNIT B:
  -- the successor rule below must never mask a stale fetch's honest
  -- refetch-and-re-derive contract — a stale payload's outdated hash
  -- would otherwise refuse as a proof fault; the UPDATE's own filter
  -- stays below as the belt, byte-unchanged).
  if vault_revision is distinct from expected_revision then
    raise exception 'VARIORUM_VAULT_REVISION_CONFLICT: the vault changed since it was fetched — fetch it again and re-derive';
  end if;

  -- THE ROTATION'S SUCCESSOR (13y UNIT B, memo §3): hash and secret land
  -- TOGETHER or not at all. The vault row is already locked FOR UPDATE
  -- above, so this read-then-write is serialized per account.
  incoming_hash := payload->>'key_proof_hash';
  incoming_mac := payload->>'key_proof_mac';
  select key_proof_hash into vault_current_hash from key_vault where user_id = caller;
  if incoming_mac is not null then
    begin
      incoming_mac_hash := encode(sha256(decode(incoming_mac, 'base64')), 'hex');
    exception when others then
      incoming_mac_hash := null;
    end;
    if incoming_mac_hash is null or incoming_hash is null
       or incoming_mac_hash <> incoming_hash then
      raise exception 'VARIORUM_KEY_PROOF_REQUIRED: the successor proof secret must hash to the payload''s key_proof_hash — they land together or not at all';
    end if;
  elsif incoming_hash is not null and incoming_hash is distinct from vault_current_hash then
    raise exception 'VARIORUM_KEY_PROOF_REQUIRED: a new key_proof_hash lands only beside its key_proof_mac — a hash that moved without its secret would refuse every follower';
  end if;
  if incoming_mac is not null then
    select s.id into mac_secret_id
      from vault.secrets s where s.name = 'kp:' || caller::text;
    if mac_secret_id is null then
      perform vault.create_secret(incoming_mac, 'kp:' || caller::text);
    else
      perform vault.update_secret(mac_secret_id, incoming_mac);
    end if;
  end if;

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
    next_seq := next_tenant_seq(caller);
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
-- 9. account_purge — 11-era body verbatim; the ONE change: the caller's
--    `sync_tenant_seq` row goes with the account (the 13j letter — the
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
  -- since 13y, the account's sequence counter with them; UNIT B adds the
  -- challenge nonces, the write-budget row, and the Vault-held MAC
  -- secret. The secret's delete is BEST-EFFORT under this function's
  -- `postgres` owner (vault-schema privileges are the window's probe): a
  -- failure never fails the purge — deletion is mandated and loud, and a
  -- dangling secret for a dead uuid authorizes nothing (no auth user can
  -- ever present it; a re-created account is a NEW uuid, a new name) —
  -- recorded, window-verified.
  delete from device_cursor where owner_id = caller;
  delete from purged_row where owner_id = caller;
  delete from sync_tenant_seq where owner_id = caller;
  delete from key_proof_challenge where owner_id = caller;
  delete from sync_write_budget where owner_id = caller;
  begin
    delete from vault.secrets where name = 'kp:' || caller::text;
  exception when others then
    null;
  end;

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
-- 10. THE GLOBAL SEQUENCE RETIRES (F-S4): nothing references
--    `sync_server_seq` after the swaps above (the data tables default the
--    column to 0 and the trigger overwrites; the two direct mints now
--    draw per-owner). Dropping it is the fail-loud closure — a future
--    artifact that quietly `nextval`s the global counter ERRORS instead
--    of silently reopening the cross-tenant disclosure this event closes.
-- ---------------------------------------------------------------------------

drop sequence if exists sync_server_seq;

-- ---------------------------------------------------------------------------
-- 11. Ownership + the demotion posture. UNIT B DROPS AND RE-CREATES every
--     gated function (the challenge signatures), so ownership and grants
--     are RE-STATED for all of them — nothing rides `create or replace`'s
--     ACL preservation any more except `account_purge` (unchanged
--     signature; `postgres`-owned by the 14c-gate reasoning, auth-schema
--     DML). Everything returns to the NON-BYPASS definer owner through
--     the CREATE-for-acquisition dance (the 10/11 idiom). The helpers —
--     `next_tenant_seq`, `sync_constant_time_equal`, the reworked
--     `sync_key_gate`/`sync_key_proof_check` — take the `sync_table_pk`
--     posture: reachable by NO API role (Supabase's CREATE-time
--     EXECUTE-to-PUBLIC default revoked by name — the memo §2's recorded
--     footgun, every new function). THE VAULT GRANTS (memo §2/§3): the
--     definer role reads the MAC secret inside the verify and writes it
--     at enroll/rotation — USAGE on schema `vault`, SELECT on
--     `vault.secrets` + `vault.decrypted_secrets`, and EXECUTE on the
--     vault helper functions (granted as ALL FUNCTIONS IN SCHEMA rather
--     than by signature: `create_secret`/`update_secret` signatures vary
--     by Vault version, a wrong-signature grant fails the whole deploy,
--     and the schema's surface is Supabase's own fixed helper set — the
--     window's sweep verifies the landed posture; the role is NOLOGIN
--     and reachable only through these definer bodies).
-- ---------------------------------------------------------------------------

grant usage on schema vault to variorum_definer;
grant select on vault.secrets, vault.decrypted_secrets to variorum_definer;
grant execute on all functions in schema vault to variorum_definer;

grant usage, create on schema public to variorum_definer;
alter function sync_push(jsonb, text, text, text) owner to variorum_definer;
alter function sync_pull(bigint, text, text, text, int, text) owner to variorum_definer;
alter function sync_horizon(text, text, text) owner to variorum_definer;
alter function sync_purge_ledger(bigint, text, text, text) owner to variorum_definer;
alter function sync_purge_execute(jsonb, text, text, text) owner to variorum_definer;
alter function account_data_truncate(text, text, text) owner to variorum_definer;
alter function sync_reencrypt(jsonb, text, text, text) owner to variorum_definer;
alter function key_vault_update(jsonb, int, text, text) owner to variorum_definer;
alter function sync_key_gate(text, text, text, text) owner to variorum_definer;
alter function sync_key_proof_check(text, text, text) owner to variorum_definer;
alter function sync_constant_time_equal(text, text) owner to variorum_definer;
alter function sync_challenge(int) owner to variorum_definer;
alter function key_proof_enroll(text, text, text) owner to variorum_definer;
alter function sync_visibility_horizon_ms() owner to variorum_definer;
revoke create on schema public from variorum_definer;

-- The two round RPCs keep the 09 posture (authenticated + the named
-- service_role default, zero live reach — both bodies refuse a NULL
-- auth.uid()).
revoke execute on function sync_push(jsonb, text, text, text) from public, anon;
grant execute on function sync_push(jsonb, text, text, text) to authenticated, service_role;
revoke execute on function sync_pull(bigint, text, text, text, int, text) from public, anon;
grant execute on function sync_pull(bigint, text, text, text, int, text) to authenticated, service_role;

revoke execute on function sync_visibility_horizon_ms() from public, anon;
grant execute on function sync_visibility_horizon_ms() to authenticated, service_role;

-- The account-door posture (authenticated only, service_role revoked by
-- name) for everything a signed-in device alone may call — the mint and
-- the enroll road included.
revoke execute on function sync_horizon(text, text, text) from public, anon, service_role;
grant execute on function sync_horizon(text, text, text) to authenticated;
revoke execute on function sync_purge_ledger(bigint, text, text, text) from public, anon, service_role;
grant execute on function sync_purge_ledger(bigint, text, text, text) to authenticated;
revoke execute on function sync_purge_execute(jsonb, text, text, text) from public, anon, service_role;
grant execute on function sync_purge_execute(jsonb, text, text, text) to authenticated;
revoke execute on function account_data_truncate(text, text, text) from public, anon, service_role;
grant execute on function account_data_truncate(text, text, text) to authenticated;
revoke execute on function sync_reencrypt(jsonb, text, text, text) from public, anon, service_role;
grant execute on function sync_reencrypt(jsonb, text, text, text) to authenticated;
revoke execute on function key_vault_update(jsonb, int, text, text) from public, anon, service_role;
grant execute on function key_vault_update(jsonb, int, text, text) to authenticated;
revoke execute on function sync_challenge(int) from public, anon, service_role;
grant execute on function sync_challenge(int) to authenticated;
revoke execute on function key_proof_enroll(text, text, text) from public, anon, service_role;
grant execute on function key_proof_enroll(text, text, text) to authenticated;

-- The helper posture: reachable by NO API role.
revoke execute on function next_tenant_seq(uuid) from public, anon, authenticated, service_role;
grant execute on function next_tenant_seq(uuid) to variorum_definer;
revoke execute on function sync_key_gate(text, text, text, text) from public, anon, authenticated, service_role;
grant execute on function sync_key_gate(text, text, text, text) to variorum_definer;
revoke execute on function sync_key_proof_check(text, text, text) from public, anon, authenticated, service_role;
grant execute on function sync_key_proof_check(text, text, text) to variorum_definer;
revoke execute on function sync_constant_time_equal(text, text) from public, anon, authenticated, service_role;
grant execute on function sync_constant_time_equal(text, text) to variorum_definer;

-- Belt (idempotent): the one function this event does NOT re-create.
revoke execute on function account_purge() from public, anon, service_role;
grant execute on function account_purge() to authenticated;

-- ---------------------------------------------------------------------------
-- 12. The lockstep marker (SyncSpec §12): THE LAST STATEMENT INSIDE THE
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
--   select count(*) from sync_tenant_seq;                             -- ≥ 1 (her account)
--   select owner_id, last_seq from sync_tenant_seq;                   -- her floor ≥ her devices' cursors
--   select pg_get_functiondef('key_vault_update(jsonb, int, text)'::regprocedure)
--          like '%VARIORUM_ROTATION_ROWS_REMAIN%';                   -- true (the fold-in)
--   select pg_get_functiondef('key_vault_update(jsonb, int, text)'::regprocedure)
--          like '%next_tenant_seq%';                                  -- true (M3)
--   select to_regclass('public.sync_server_seq') is null
--          and not exists (select 1 from pg_class where relname = 'sync_server_seq');
--                                                                    -- the global counter is gone
--   select oid::regprocedure from pg_proc where proname = 'sync_pull';
--                                                                    -- ONE row: sync_pull(bigint,text,text,text,integer,text)
--   select sync_visibility_horizon_ms();                              -- 2000 (the served horizon)
--   select pg_get_functiondef('sync_pull(bigint,text,text,text,int,text)'::regprocedure)
--          like '%sync_visibility_horizon_ms%';                       -- true (the ONE horizon — derived, never inlined)
--   select pg_get_functiondef('sync_pull(bigint,text,text,text,int,text)'::regprocedure)
--          not like '%interval ''2 seconds''%';                       -- true (no inline literal survives)
--
-- UNIT B verification (read-only; the window runs these too):
--   select oid::regprocedure from pg_proc where proname in
--     ('sync_push','sync_pull','sync_horizon','sync_purge_ledger',
--      'sync_purge_execute','account_data_truncate','sync_reencrypt',
--      'key_vault_update','sync_key_gate','sync_key_proof_check')
--     order by 1;                                                     -- EXACTLY ONE row per name — the challenge signatures;
--                                                                    --   any second spelling is a lingering challenge-free door
--   select count(*) from key_proof_challenge;                         -- 0 (nothing minted yet)
--   select count(*) from sync_write_budget;                           -- 0 (no push has run yet)
--   select extensions.hmac('probe'::bytea, 'key'::bytea, 'sha256') is not null;
--                                                                    -- true (pgcrypto resolves in `extensions` — the PENDING-until-live probe)
--   select vault.create_secret('cHJvYmU=', 'kp:deploy-probe');        -- a uuid (the Vault road works for the DEPLOYER;
--   delete from vault.secrets where name = 'kp:deploy-probe';        --   then removed; the DEFINER-role road is proven by
--                                                                    --   her first round's enroll — the window watches it land)
--   select key_proof_hash from key_vault;                             -- pre-enroll: her v1 hash (unchanged by the deploy);
--                                                                    --   AFTER her Mac's first round: a NEW 64-hex value =
--                                                                    --   sha256(kp2), landed by key_proof_enroll, and
--                                                                    --   select name from vault.secrets → 'kp:<her uuid>'
--   select pg_get_functiondef('sync_key_proof_check(text,text,text)'::regprocedure)
--          like '%VARIORUM_KEY_PROOF_ENROLL%';                        -- true (the enroll refusal, before any nonce is consumed)
--   select pg_get_functiondef('sync_push(jsonb,text,text,text)'::regprocedure)
--          like '%VARIORUM_WRITE_QUOTA%';                             -- true (the guard lives in the one quota'd door)
--   select pg_get_functiondef('sync_reencrypt(jsonb,text,text,text)'::regprocedure)
--          not like '%sync_write_budget%';                            -- true (the exemption — a rotation is never metered)
--   select pg_get_functiondef('sync_purge_execute(jsonb,text,text,text)'::regprocedure)
--          like '%VARIORUM_REAUTH_REQUIRED%';                         -- true (the destructive doors' 10-minute window)
--   select pg_get_functiondef('account_data_truncate(text,text,text)'::regprocedure)
--          like '%VARIORUM_REAUTH_REQUIRED%';                         -- true (both of them)
--   THE AMR REFRESH-SURVIVAL PROBE (memo §5's named check, HER window):
--     decode her session's JWT before and after a token refresh — the
--     amr password timestamp must be byte-identical; if it BUMPS, the
--     guard is hollow and the fallback comes back for a re-ruling.
--   plus maintenance/14c-post-deploy-grant-sweep.sql — every row OK/INFO.
