-- Variorum sync mirror — the Phase 14b lockstep event (Suite E2EE, batch 2;
-- SyncSpec §12). Run AFTER 01 + 02 + 03 + 04 + 05 + 06 + 07, via the
-- author's PAT arrangement. The deploy is a GATE ACT executed by the
-- ARCHITECT, never a batch implementer: pre-authorized CONDITIONALLY by the
-- author's Round-4/Round-5 overnight rulings (attempted overnight ONLY if
-- the review ladder closes clean; otherwise it rides the morning checklist
-- at her explicit go), always behind the A1 rail.
--
-- WHAT THIS EVENT SHIPS: the suite E2EE key vault (rulings R-1/R-5/R-7/R-8,
-- the plan's THE DESIGN): one `key_vault` row per account on the VARIORUM
-- project (R-1 — the account home, the 14a 0h ruling extended), holding the
-- master key wrapped TWICE (passphrase-KDF wrap + recovery-phrase wrap) and
-- the per-class keys (corpus · journal-bridge) wrapped by master
-- (RFC 3394). The vault is ACCOUNT data accessed via plain authenticated
-- PostgREST under owner-only RLS (P-ii verified at 14a round 0r) — the
-- sync engine never touches it, and it is NEVER a sync-mirror table.
--
-- NO RPC REWORK RIDES THIS EVENT (deliberate): `key_vault` does not enter
-- the sync_push/sync_pull allowlists — 06's deployed bodies stand exactly
-- as they are. What DOES change client-side at this marker: the client's
-- payload serializer now ships `e1:` AEAD ciphertext in the eighteen
-- encrypted-classified text columns (the SyncSchema classification), so a
-- pre-14b client and a post-14b mirror corpus are mutually unreadable —
-- which is exactly why the marker bumps even though this file adds no
-- mirror column: the §12 refusal is what keeps a pre-14b build from
-- pushing plaintext into (or misreading ciphertext out of) the encrypted
-- corpus. The mirror stays dumb (SyncSpec §2): ciphertext is just TEXT.
--
-- THE CHOREOGRAPHY (SyncSpec §12; the wipe-and-repush shape, ruling R-2):
--   (1) this file runs on the mirror FIRST. The moment its final statement
--       bumps the marker to 5, the installed marker-4 Mac build VISIBLY
--       refuses to sync (outbox intact, cursor unmoved) — the accepted
--       consequence, and this phase's author-PAUSE means no round is
--       running anyway. /Applications refreshes ONLY AFTER this deploy
--       (the lockstep-strand rule, gate step 7).
--   (2) THEN the gate proceeds: her vault setup (the passphrase wrap; the
--       recovery wrap is added in her presence in the morning), the A1
--       rail + mirror export, the data-table truncate artifact at her go,
--       and the Mac's resyncReinitialize + repush THROUGH the encrypted
--       serializer (R-2 — no in-place migration machinery exists).
--   (3) the phone RE-ONBOARDS fresh (sign in → passphrase enrollment →
--       pull-to-head over ciphertext) — the restore drill's fresh-device
--       half (PL-6).
--
-- THE DUMBNESS IS STILL LOAD-BEARING (SyncSpec §2): `key_vault` carries no
-- constraints beyond the PK + NOT NULLs — format integrity lives in the
-- client's `KeyVaultFormat` (typed refusals, RFC 3394 integrity), and RLS
-- carries ownership. The mirror data tables gain NOTHING here.

-- ---------------------------------------------------------------------------
-- 1. key_vault — one row per account (user_id = auth.uid()). Column names
--    mirror the client's KeyVaultFormat/PassphraseKDF.Descriptor fields
--    (batch 3's PostgREST client maps them 1:1). All key material is
--    base64 TEXT; the KDF descriptor is stored beside the wrap it derives
--    (R-7's soft door: a future KDF change re-wraps ONE key at next
--    unlock, never the corpus — the descriptor is truth, never app
--    defaults).
-- ---------------------------------------------------------------------------

create table key_vault (
  user_id                              uuid primary key
                                       references auth.users (id) on delete cascade,
  format_version                       integer not null,
  kdf_algorithm                        text not null,
  kdf_argon2_version                   integer not null,
  kdf_memory_kib                       integer not null,
  kdf_iterations                       integer not null,
  kdf_parallelism                      integer not null,
  kdf_salt                             text not null,
  kdf_output_bytes                     integer not null,
  master_wrapped_by_passphrase         text not null,
  -- Nullable BY DESIGN (Round 5): a vault may be born overnight with the
  -- passphrase wrap alone; the recovery wrap lands in her presence (the
  -- phrase's whole point is being seen once and written down).
  master_wrapped_by_recovery           text,
  corpus_key_id                        text not null,
  corpus_key_wrapped_by_master         text not null,
  journal_bridge_key_id                text not null,
  journal_bridge_key_wrapped_by_master text not null,
  created_at                           timestamptz not null default now(),
  updated_at                           timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 2. Owner-only RLS + grants (the P-ii-verified pattern): the vault is
--    reached through plain authenticated PostgREST — NOT through the sync
--    RPCs — so unlike the mirror tables it gets real policies. The bare
--    key (anon) still grants nothing; every policy binds to auth.uid().
--    Deliberately NO delete policy: a vault row is never casually deleted
--    (losing it orphans the whole ciphertext corpus) — removal is an
--    account-deletion-scale act (14c's operationalia), run server-side.
-- ---------------------------------------------------------------------------

alter table key_vault enable row level security;

create policy key_vault_owner_select on key_vault
  for select to authenticated using (auth.uid() = user_id);
create policy key_vault_owner_insert on key_vault
  for insert to authenticated with check (auth.uid() = user_id);
create policy key_vault_owner_update on key_vault
  for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

revoke all on key_vault from anon;
grant select, insert, update on key_vault to authenticated;

-- ---------------------------------------------------------------------------
-- 3. The lockstep marker (SyncSpec §12): sync_meta and
--    sync_schema_version() already exist (05); nothing here recreates
--    them. THE MARKER UPDATE IS DELIBERATELY THE LAST STATEMENT OF THIS
--    FILE: a partially-executed deploy never advertises the new version
--    before the vault table exists.
-- ---------------------------------------------------------------------------

-- LAST STATEMENT (see above): the mirror now speaks lockstep version 5.
-- Must equal SyncSchema.lockstepVersion in the client — the in-repo DDL
-- pin fails the build if they drift.
insert into sync_meta (key, value) values ('lockstep_version', '5')
  on conflict (key) do update set value = excluded.value;
