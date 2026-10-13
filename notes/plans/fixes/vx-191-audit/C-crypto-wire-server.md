# VX-191 audit — Area C: crypto primitives, the wire, the server, keychain attributes

Auditor: Area C subagent (read-only on product code; worktree `~/dev/variorum-vx-191` at f337f19e).
Status: COMPLETE.

## Verdict table

| # | item | verdict | severity | one line |
|---|---|---|---|---|
| C1.1 | AES-GCM nonces + AAD | HOLDS | — | CryptoKit random 96-bit nonce per seal, no caller-nonce API; AAD table:row:column:keyID; per-account key makes cross-owner swaps fail |
| C1.2 | RFC 3394 key wrap | HOLDS | NIT | refuses on wrong key/tamper; M doubles as KW-KEK and HMAC key for the proof (theoretical) |
| C1.3 | Argon2id + floor at read | HOLDS | — | every vault/key-file descriptor floor-checked (19 MiB/t=2/16 B) before P is hashed; only mint sites skip it |
| C1.4 | BIP-39 → key | HOLDS | — | 128-bit CSPRNG entropy, checksum, PBKDF2-2048, HKDF with domain strings |
| C1.5 | key proof + challenge | HOLDS | — | kp1/kp2 domain-separated; single-use nonce, 5-min TTL, correct HMAC order, constant-time, null-guarded |
| C1.6 | randomness / zeroization | HOLDS | — | every key from SymmetricKey(size:); no zeroization claimed or built |
| C1.7 | SQLCipher + fingerprints | HOLDS | — | raw 256-bit key pragma on every connection, error text redacted; fingerprint = 64 bits of SHA-256(L) |
| C2.1 | every push road seals | HOLDS | — | only push and reencrypt carry rows, both through encryptForWire; no plaintext mode |
| C2.2 | classification vs website promise | HOLDS | — | every user-written/named text column sealed; plain set = the disclosed envelope |
| C-1 | in-app guide says "everything is encrypted" | FINDING | MAJOR (copy-only) | PostureCopy.swift:781 overstates; dates/tag-tree shape/membership/flags/sizes travel plain |
| C-2 | plain columns unauthenticated; AI fence keyed on them | FINDING | MINOR | a malicious server can null ai_private_at/flip profile (genuine ciphertext reused) and widen an approved MCP client's reach |
| C3 | server RLS / definer / proof / vault road / anon | HOLDS | NIT ×3 | add `pg_temp` to definer search_path; account_purge has no server-side re-auth (ruled session-only); brief wording on what a bare session's vault read returns |
| C3 | account deletion | HOLDS | OPEN | complete in-repo; Supabase auth audit logs outlive the user (policy-text question) |
| C4 | keychain classes / sync / ACLs | HOLDS | — | only A synchronizable; custody ThisDeviceOnly on DP; Castle items `.biometryCurrentSet`, Castle never `.auto` |
| C4 | delete flags (incl. Castle entry, follow, sign-out) | HOLDS | NIT ×2 | every delete carries the item's DP/sync flags; dup-add keeps old class (no weaker item exists); her pre-13x file-based legacy M item lingers only if migration 2a never ran |
| C4 | Keychain Access / Passwords visibility | OPEN | — | DP items list in Keychain Access (DTS); whether values reveal there, and Passwords-app listing, unconfirmed |

## C1 — Primitives

### C1.1 AES-GCM value cipher (`Sources/VariorumCore/Crypto/PayloadCipher.swift`)
- Nonce: `AES.GCM.seal(_:using:authenticating:)` with NO nonce argument (PayloadCipher.swift:69-70) — CryptoKit mints a fresh random 96-bit nonce per call. No API in the file accepts a caller nonce; grep finds no `AES.GCM.Nonce(` in Sources. Every re-seal (rotation re-encrypt, CorpusRotation.swift:591-593) calls `encryptForWire` → `seal` again → fresh nonce. **HOLDS.** Per-key volume bound (2^32) documented at PayloadCipher.swift:17-24; personal-corpus volume is orders below.
- AAD = `table:rowID:column:keyID` (PayloadCipher.swift:50-52), built per value in SyncEncryption.swift:249-256. Swapping a ciphertext between rows/columns/keys fails `open` → `authenticationFailed` → the round refuses (SyncEncryption.swift:227-230). Owner is not in the AAD, but the key is per-account (one corpus key per vault, one vault per `auth.uid()`), so cross-owner swaps fail on the key itself. **HOLDS.**
- Known, design-inherent limit (NOT a finding; noted for completeness): the AAD binds no version/sync_version, so a malicious server can REPLAY an older genuine ciphertext of the same row+column (rollback), or withhold rows. This is the "dumb server" model (SyncSpec §1); integrity of the row SET and freshness are not promised anywhere I found. Rotation's seq rule (SyncEncryption.swift:201-206) lets the server choose which of two genuine keys opens a row — it cannot make a forged value open.
- Open path refuses non-`e1:` in encrypted columns (SyncEncryption.swift:224-226, 232-236) — no plaintext pass-through. **HOLDS.**

### C1.2 Key wrap (RFC 3394) — `KeyVaultFormat.swift`, `StoreKeyEnvelope.swift`
- All wraps/unwraps are CryptoKit `AES.KeyWrap` (KeyVaultFormat.swift:134-140, 199, 238, 292, 319, 346, 428). A wrong KEK or flipped byte throws (integrity check value) → typed `unwrapFailed` (KeyVaultFormat.swift:426-432). Every "re-wrap with held master" door verifies the master against the first class key before writing (KeyVaultFormat.swift:265-270, 286-289, 313-316, 339-342). **HOLDS.**
- NIT (theoretical): master M is used both as the AES-KW KEK for class keys and as the HMAC-SHA256 key for kp1/kp2 (KeyProof.swift:46-58). Cross-primitive key reuse; no known attack, the HMAC messages are fixed purpose strings. A future `e2`/v2 could derive a proof key via HKDF(M, "key-proof") instead.

### C1.3 Argon2id + the descriptor floor (`PassphraseKDF.swift`)
- Mint default: m=64 MiB, t=3, p=1, 16-byte CSPRNG salt, 32-byte output (PassphraseKDF.swift:73-83, 138-140).
- FLOOR AT READ: production floor 19 MiB / t=2 / 16-byte salt (PassphraseKDF.swift:106); relaxed floor compiled only under `#if DEBUG` and only for test hosts (PassphraseKDF.swift:116-132).
- Every READ site checks the floor before deriving:
  - server vault row → `KeyVaultWireRow.format()` validates (KeyVaultClient.swift:661-679); `fetchVault()` always goes through it (KeyVaultClient.swift:157). Every app use of `fetched.format.kdf` (PostureSwitch, ProtectionMigration, ProtectionController, EncryptionSession, KeyDoorModel, StoreLaunchGate:908-947) is downstream of that.
  - key file passphrase wrap → `StoreKeyEnvelope.unwrapKey(passphrase:)` / `(passphraseKey:)` validate (StoreKeyEnvelope.swift:359, 375); the lobby road validates before its own derive (StoreLaunchGate.swift:875).
  - rotation reuse road → `vault.kdf.validateFloor()` (CorpusRotation.swift:112).
  - VaultEnrollment's `measuredDerive(... vault.kdf)` (VaultEnrollment.swift:218, 312) receives a vault from `fetchRequiredVault()` → `fetchVault()` → floor-checked.
  - The only `deriveKey` calls on an UNCHECKED descriptor are MINT sites (fresh `.v1(salt:)`): VaultEnrollment.swift:147/190/327/358, StoreKeyEnvelope.swift:194, CorpusRotation.swift:74.
- `KeyVaultFormat(decoding:)` (the JSON path, no floor) has no caller in Sources/App (grep).
- **HOLDS** — a server- or file-supplied descriptor below 19 MiB/t=2/16 B refuses before the user's P is hashed. Residual (by design): the floor (19 MiB/t=2) is ~4-5x cheaper than the mint default, so a downgrade from 64/3 to the floor would be accepted — but only a writer holding the key proof can change the vault row (key_vault_update), and a downgraded descriptor without a matching re-wrap simply fails to unwrap; no road re-wraps the user's P under a server-chosen descriptor without first proving the existing wrap opens under it (CorpusRotation.swift:113-118, StoreLaunchGate.swift:908-935). No information about P is sent to the server on any failed unwrap.

### C1.4 BIP-39 words → key (`RecoveryPhrase.swift`)
- 128-bit entropy from `SymmetricKey(size: .bits128)` (CSPRNG); standard BIP-39 checksum validation; seed via PBKDF2-HMAC-SHA512 2048 (the BIP-39 standard); then HKDF-SHA256(salt "variorum.suite.e2ee.v1", info "recovery-wrap-key") → 32 bytes. 128 bits of entropy makes the low PBKDF2 count irrelevant. **HOLDS.**

### C1.5 Key proof (`KeyProof.swift`, SQL `12_phase13y_tenant_seq.sql`)
- kp1 = HMAC(M, "variorum.key-proof.v1"), kp2 = HMAC(M, "variorum.key-proof.v2") — domain-separated purposes (KeyProof.swift:37-58). Per-request proof = HMAC(kp2, nonce ‖ ":" ‖ rpc) (KeyProof.swift:128-133); server recomputes with pgcrypto `hmac(data, key)` in the correct argument order and compares in a fixed 64-step loop (12_phase13y_tenant_seq.sql:509-525, 723-743). Nonces are 32 random bytes (`gen_random_bytes(32)`, :558), single-use per success (DELETE…RETURNING, :704-709), 5-minute server-clock TTL (:710-712). Both comparands null-guarded (:740-743). **HOLDS.**
- By design (disclosed in the privacy brief "the server keeps a per-account secret … authorizes writes and can decrypt nothing"): the server holds kp2 in Supabase Vault, so a server-side actor can authorize writes, never reads.

### C1.6 Randomness
- Store key L: `SymmetricKey(size: .bits256)` (StoreKey.swift:47-53). Salts/entropy: `SymmetricKey(size:)` (PassphraseKDF.swift:138-140, RecoveryPhrase.generate). Nonces: CryptoKit internal. Key-material randomness deliberately does NOT use the seedable `@Dependency(\.uuid)` (comment PassphraseKDF.swift:134-137). Server nonces: pgcrypto. (Master/corpus key mint sites: see C1.6a below once checked.)

### C1.7 SQLCipher
- Raw-key mode: `PRAGMA key = "x'<64 hex>'"` on every connection (AppDatabase.swift:106-129) — the 256-bit random L goes straight to the pager; no passphrase KDF (deliberate, documented). SQLCipher 4 defaults otherwise (per-file salt, HMAC page authentication). Key-bearing SQL errors are redacted (AppDatabase.swift:120-128, StoreKey.redactedDescription). **HOLDS.**
- Fingerprint = first 8 bytes of SHA-256(L), hex (StoreKeyEnvelope.swift:150-153) — 64 bits of a hash of a 256-bit random key; reveals nothing usable. **HOLDS.**
- Master/corpus/journal keys: `SymmetricKey(size: .bits256)` at every mint (VaultEnrollment.swift:141-143, 185-187; CorpusRotation.swift:408-410); iCloud key A: `SymmetricKey(size: .bits256)` (AppleKeyCustody.swift `AppleKey.mint`). Key IDs are `UUID()` v4 (random, non-secret — they ride every AAD in clear). **HOLDS.**
- Zeroization: nowhere claimed in the code, and none is built (keys live in Swift `Data`/`SymmetricKey`, session-held in `SyncCustodySession`, dropped by reference on relock, EncryptionKeychain.swift `drop()`). Nothing user-facing promises memory wiping; the open-app attacker is out of scope (decision 19). Nothing to report.

## C2 — The wire

### C2.1 Push/pull roads all pass the seam
Only two transport calls carry row payloads up: `transport.push` (SyncEngine.swift:187-197, `chunk.map(crypto.encryptForWire)`) and `transport.reencrypt` (CorpusRotation.swift:591-597, `encryptForWire(decryptFromWire(pulled))`). Every other transport call carries ids/enums/seqs only (`executePurge` — table+row id; `purgeLedger`, `syncHorizon`, `fetchChallenges`, `enrollKeyProof`, `schemaVersion`, `visibilityHorizonMillis`). `resyncReinitialize` only re-enqueues (VaultBootstrap.swift:137; PurgeJanitor.swift:805) — the re-push then rides `push` → seam. The conflict rescue / reject merge opens on the way in (SyncEngine.swift:205). The pull opens every row before inland logic (SyncEngine.swift:473). There is no plaintext mode (SyncEncryption.swift:9-15); an encrypted-classified column with a non-text value refuses (SyncEncryption.swift:170-177). **HOLDS — no road pushes a plaintext value of an encrypted-classified column.**

### C2.2 The classification (SyncSchema.swift:161-365; server mirror registry 13_phase13i_wings.sql:640-653 matches it)

| table | ENCRYPTED (`e1:` AES-GCM) | PLAIN on the wire |
|---|---|---|
| container | title, floating_notes | id, owner_id, kind, profile, entry_date, locked, locked_at, segmentation_default, last_touched_at, last_major_revision_at, churn_accumulator, baseline_length, word_target, wing_id, created_at, updated_at, archived_at, ai_private_at, deleted_at |
| block | name, presentation | id, owner_id, default_variant_id, last_container_id, timestamps |
| variant | working_text, label | id, block_id, parent_variant_id, status, locked, fan_position, timestamps |
| commit_point | text, message | id, variant_id, kind, created_at |
| tag | name, path | id, owner_id, parent_id, wing_id, timestamps |
| wing | name | id, owner_id, position, timestamps |
| shelf | name, glyph | id, owner_id, wing_id, role, position, timestamps |
| reading | name, query_spec | id, owner_id, kind, profile, sort_field, sort_dir, grouping_tag_id, max_posts, word_target, locked, wing_id, shelf_id, shelf_position, starred, owned, sealed_at, hide_owned, intake_seating, auto_tag_id, auto_tag_ids, archived_at, ai_private_at, timestamps |
| reading_section | name | id, reading_id, position, timestamps |
| reference | name, url, view_state | id, owner_id, container_id, kind, position, timestamps (file_bookmark EXCLUDED — never on the wire) |
| lens | name | id, owner_id, container_id, timestamps |
| block_comment | text | id, owner_id, block_id, timestamps |
| edge, container_block, reading_post, post_tag, block_tag, canvas_layout, lens_choice, purge_intent | — | every column (ids, positions, enums, x/y, timestamps) |
| setting | — | key, value |

Every user-NAMED or user-WRITTEN text column is sealed: titles, floating notes, take text and labels, savepoint text and messages, block names and callout presentation, tag names AND paths, wing/shelf/book/chapter/lens names, shelf glyph, book rules, reference names/URLs/view state, comments. `setting.value` holds only enums/flags/hex tints/ids (writers: Operations+Appearance.swift:21-116 and :350 — `starred` is a JSON list of target keys; `daily_journal_book`/`quicknote_book` are ids) — the AppSpec §7 E2EE constraint ("no future setting key may carry user-authored prose") holds today. The vault row's `updated_by_device` is a plain device NAME (self-reported) — disclosed in the privacy brief.

Against the website/policy promise (notes/stargazing-privacy-policy-brief-2026-10-04.md:50-53, 85-106 — "Every text-bearing column is encrypted"; the operator sees "ids, dates, positions, kinds … content-free organizational structure … with every NAME in that structure encrypted"; "No content, no titles, no words") — **HOLDS**.

### C2.3 FINDING C-1 (MAJOR per the brief's scale — a promise stated more strongly than built; a copy-only fix): the in-app field guide says "everything is encrypted"
- The promise: `ProtectionCopy.privacyLessonOneParagraphs` (App/Variorum/Shared/PostureCopy.swift:778-783), seeded into the field guide on BOTH platforms (TutorialSeeder.swift:2465; MobileTutorialSeeder.swift:793): *"Sync is end-to-end encrypted: everything is encrypted on your device before it leaves, and the Variorum server stores what it can never read."*
- What is built: C2.2's PLAIN column set — note dates (`entry_date`, created/edited stamps), which notes are journal entries (`profile`), the whole tag tree SHAPE and which tag sits on which note/block (`tag.parent_id`, `post_tag`, `block_tag`), book membership and order, starred/owned/sealed/archived/Private flags, note length (`baseline_length`) and every row's size and timing — leave the device unencrypted. The website brief discloses exactly this envelope (lines 85-106); the in-app sentence the user actually reads does not, and says "everything".
- Path: any user reading Field guide ▸ the privacy lesson.
- Fix shape: one sentence — e.g. "everything you write and name — text, titles, tags, book and shelf names — is encrypted on your device before it leaves; the server sees only the shape (dates, counts, how things are arranged), never a word." (Her copy call; the keystone at PostureCopy.swift:19-22 — "can never read your writing" — is accurate and needs no change.)

### C2.4 FINDING C-2 (MINOR): plain columns are unauthenticated, and the AI fence is keyed on plain columns — a malicious server can strip the Private / journal fence
- Mechanism: the AAD binds only `table:rowID:column:keyID` of each ENCRYPTED value (PayloadCipher.swift:50-52); nothing authenticates a row's PLAIN columns. A server returning a pulled row can keep the row's genuine ciphertext (the AAD still matches — same table/row/column/key) and rewrite any plain column; `decryptFromWire` checks encrypted columns only (SyncEncryption.swift:208-240); the apply takes any remote row whose `sync_version` exceeds local (SyncEngine.swift:546) — the server sets `sync_version`.
- Consequence traced to a confidentiality effect: the MCP fence (`Queries.mcpNoteFacts`, Sources/VariorumCore/Queries/MCPGrantQueries.swift:380-430; `MCPGrantRule.Fence`, Domain/MCPGrantRule.swift:68-79) is computed from `container.profile = 'journal'`, `container.ai_private_at`, `reading.ai_private_at`, `reading.profile = 'daily'` and `reading_post` membership — ALL plain (SyncSchema.swift:167-176, 242-268, 279-283). A server that nulls `ai_private_at` (or flips `profile`) on a note moves it out of the per-ask fence into a standing wing/book grant's reach, so an approved AI client (whose host may send text off-device) can then read a note she marked Private without a per-ask grant.
- Preconditions (why MINOR, not higher): a malicious or compromised server (the E2EE threat model's adversary) AND her having approved an MCP client with a standing wing/book grant. The server still learns nothing itself. Same class, lower stakes: a server can inject `purge_intent` rows (all plain) or move `container_block`/`reading_post` pointers — integrity/availability, never confidentiality. Nothing user-facing promises metadata integrity.
- Fix shape (options): (a) make the fence local-sticky — a remote CLEAR of `ai_private_at` (or a profile change away from journal) does not widen MCP reach until confirmed on this device; (b) bind fence-relevant plain columns into an authenticated field (e.g. carry `ai_private_at` inside an encrypted column, or add an `e1:` MAC column over the row's security-relevant plain values) — a §12 lockstep event.

### C2.5 Other wire notes (not findings)
- Replay/withholding by a malicious server (C1.1) — design-inherent, undisclosed only in the sense that nothing claims otherwise.
- `KeyProof` kp2 lives server-side (Supabase Vault) — disclosed ("authorizes writes and can decrypt nothing").

## C3 — The server (Server/supabase/*.sql; latest definitions: 13_phase13i_wings.sql for sync_pull/push/reencrypt/purge_execute/account_data_truncate/key_vault_update/account_purge; 12_phase13y_tenant_seq.sql for the challenge, enroll, proof check, gate, horizon, ledger)

- **RLS on every table, owner-scoped.** Every data table: `enable` + `force row level security` + one `*_owner_all` policy on `auth.uid()` + `revoke all … from anon, authenticated` (09_phase14c_multitenant.sql:272-696; wing/shelf 13_phase13i_wings.sql:96-136); server-only tables the same (purge_intent/device_cursor/purged_row 10_…:154-200; sync_tenant_seq/key_proof_challenge/sync_write_budget 12_…:309-314, 470-475, 492-497). API roles reach data ONLY through the definer RPCs. **HOLDS.**
- **Definer functions:** every `security definer` body sets `search_path = public` (or `public, extensions`) and takes `caller := auth.uid()` with a null refusal (13_…:186-187, 296-297, 480-481, 568-569, 621-622, 804-805, 852-853; 12_…:446-447, 539-540, 591-592, 1183-1184, 1207-1208). Owner scoping: every read/write predicate carries `owner_id = caller` (13_…:251-254, 264-267, 385-388, 408-409, 539-541, 607-608, 829-830); push/reencrypt overwrite the row's `owner_id` with the caller (13_…:395-396, 412-413, 552-553) and refuse a client-carried foreign owner (13_…:367-371, 527-531). Dynamic SQL interpolates only allowlisted table names (`%I` after an `= any(allowed)` check), typed ints, and `%L` literals. **HOLDS.**
  - NIT (hardening): `search_path = public` without a trailing `pg_temp` leaves `pg_temp` implicitly searched FIRST for relation names (Postgres docs, "Writing SECURITY DEFINER Functions Safely"). Exploiting it needs the caller to create a temp table in the same session — not possible through PostgREST RPC calls, so no reachable path; append `, pg_temp` at the next lockstep artifact for belt-and-braces.
- **The key proof on every data RPC** — sync_push, sync_pull, sync_reencrypt, sync_purge_execute, sync_horizon, sync_purge_ledger, account_data_truncate all `perform sync_key_gate(active_key_id, key_proof, challenge, '<rpc>')` (13_…:217, 333, 509, 588, 823; 12_…:1193, 1217); key_vault_update calls `sync_key_proof_check` under its FOR UPDATE (13_…:668-675). The check: Vault-held kp2, single-use nonce consumed by DELETE…RETURNING, 5-minute server-clock TTL, HMAC over nonce‖":"‖rpc in pgcrypto's correct argument order, constant-time 64-step compare, both comparands null-guarded (12_…:656-745). The old challenge-free overloads are dropped (12_…:284-293) and the post-deploy sweep flags any survivor (maintenance/14c-post-deploy-grant-sweep.sql). account_data_truncate additionally requires a ≤10-minute password re-auth (13_…:595-606). **HOLDS.**
- **The vault's UPDATE road is closed to `authenticated`:** `drop policy key_vault_owner_update` + `revoke update, delete on key_vault from authenticated` (11_pre13x_postures.sql:207-214; maintenance/pre13x-window-vault-delete-revoke.sql:16); UPDATE only by `variorum_definer` under its own policy (11_…:215-218) — i.e. only through key_vault_update with the proof. INSERT stays session-only by design (08_phase14b_lockstep.sql:111-118) with the proof-hash trigger (11_…:226-240). **HOLDS.**
- **anon:** revoked on every table and every RPC (e.g. 04_auth_rls.sql:74; 12_…:1749-1789). **HOLDS.**
- **What a bare session (account password only) can do** — matches the privacy brief's "keystone" list exactly: `sync_challenge` (mint/churn its own ≤64 nonces), SELECT its own `key_vault` row (the wrapped copies — the offline P brute-force target, disclosed; Argon2id 64 MiB/t=3 per guess and the 12-character set-door floor, ProtectionCopy.passphraseFloor PostureCopy.swift:347, enforced at PassphraseSetModel.swift:220, SyncEnrollmentModel.swift:152/159, KeyDoorModel.swift:443, PostureSwitchModel.swift:317/530 — the Q10 "length ≠ entropy" residual is already owned), INSERT a vault on an account that never synced (disclosed), SELECT its entitlement, `sync_schema_version`, `sync_visibility_horizon_ms`, and `account_purge()`. It cannot enroll (needs kp1, 12_…:617-623) or call any data RPC. **HOLDS as disclosed.**
  - NIT: `account_purge()` (13_…:851-922) takes NO proof and — unlike account_data_truncate — enforces NO recent-re-auth window server-side; the client re-authenticates first (pre-13x-postures-design.md:1251), but a stolen refresh token (not the password) also suffices. Ruled "session-only, loud, survivable" (design :1271 item 7), so not a finding; the amr window from account_data_truncate (13_…:595-606) would be a one-paragraph hardening if she wants "password" to mean password.
  - NIT (copy precision): the brief says a bare session "can fetch the account's wrapped key copies … nothing else"; the same SELECT also returns the plain `updated_by_device` name and the posture (both disclosed elsewhere in the same brief).
- **Account deletion completeness** (13_…:851-922): all 21 data tables, device_cursor, purged_row, sync_tenant_seq, key_proof_challenge, sync_write_budget, the Vault MAC secret (BEST-EFFORT — a swallowed failure leaves kp2 for a dead uuid, which authorizes nothing and reveals nothing about M), key_vault, entitlement, auth.users (Supabase cascades sessions/refresh tokens). **HOLDS.** OPEN (not checked, outside the repo): Supabase's own `auth.audit_log_entries` (email/IP) outlive the user row; whether the policy's "deletes … the login" should mention provider logs is a policy-text question.

## C4 — Keychain attributes (every item the app writes; the phone shares the same `App/Variorum/Shared` code — no `SecItem` call exists under VariorumMobile/)

All items are `kSecClassGenericPassword`. "DP" = `kSecUseDataProtectionKeychain = true` on every verb. Access group: none named ⇒ the FIRST entitled group, `$(AppIdentifierPrefix)$(PRODUCT_BUNDLE_IDENTIFIER)` (Variorum.entitlements / VariorumMobile.entitlements `keychain-access-groups`), except A.

| item | service / account | class | sync | ACL | DP | written at |
|---|---|---|---|---|---|---|
| L silent (Standard "Auto") | `io.lduarte.Variorum.store-key` / `<scope>-<storeID>-bound` | WhenUnlockedThisDeviceOnly | no | none | yes | StoreKey.swift:376-395 |
| L gated (Castle + Touch ID) | same service / `<scope>-<storeID>-biometric` | WhenUnlockedThisDeviceOnly | no | `.biometryCurrentSet` | yes | StoreKeyGuard.swift:270-298 |
| L gated probe (transient) | same / `…-biometric-probe` | same ACL, dummy data | no | `.biometryCurrentSet` | yes | GatedSaveChoreography |
| sync custody plain (identity; + M/C material only in Standard) | `io.lduarte.Variorum.e2ee-keys` / `<scope>-<storeID>-sync` | WhenUnlockedThisDeviceOnly | no | none | yes | EncryptionKeychain.swift:590-603 |
| sync custody gated (M/C material in Castle + Touch ID) | same / `<scope>-<storeID>-sync-biometric` | WhenUnlockedThisDeviceOnly | no | `.biometryCurrentSet` | yes | EncryptionKeychain.swift:637-664 |
*[removed for publication]*
| session tokens | `io.lduarte.Variorum.auth` / `<scope>-session-bound` | WhenUnlockedThisDeviceOnly | no | none | yes | AuthSession.swift `KeychainAuthStorage.add` |
| LEGACY (read/delete only): store key `scope` (file-based), `<scope>-bound` (DP), `<scope>-biometric` (DP); E2EE `device-keys` (file-based), `device-keys-biometric` (DP); escrow `io.lduarte.Variorum.store-key-escrow`/`<storeID>` (sync) | — | — | escrow only | — | per row | migration roads |

- **Only A is synchronizable** (the legacy escrow item is read only to be deleted — ProtectionMigration.swift:199-205, ownership-guarded). **HOLDS.**
- **Custody items are ThisDeviceOnly** (every L and sync custody write above), on the DP keychain where the class is actually enforced. **HOLDS.**
- **Castle items really require biometry, nothing else silently reads them:** both gated families are `.biometryCurrentSet` (no `.devicePasscode`/`.userPresence`; re-enrolling a finger invalidates); existence probes use `interactionNotAllowed` and return attributes only; the only DATA reads are `unlockGated`/`readGated` after `evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)` with `localizedFallbackTitle = ""` (StoreKeyGuard.swift:339-372). Castle's at-open mode is `.biometric` or `.passphrase`, never `.auto` (StoreProtection.swift:189-193); `.biometric` deletes the silent L item after the gated one verifies, `.passphrase` deletes both (ProtectionController.swift:1346-1376); the sync record moves in lockstep and a refused sync move reverses the L move (ProtectionController.swift:1270-1290; EncryptionKeychain.swift `SyncCustodyTransition.move` — Castle shapes leave the plain item IDENTITY-ONLY). **HOLDS.**
- **Delete flags — every delete path checked for the "flagless delete is a silent no-op" class:**
  - L silent: `deleteItem(account: bound, dataProtection: true)` + legacy bound (DP) + legacy `scope` (no DP — correct, that item was file-based) (StoreKey.swift:331-373, 404-408). Wired as `StoreKeyGuard.deleteAuto` → `deviceKeychainRemove(scope:storeURL:)` (StoreKey.swift:162-168). The account is per STORE ID, which a re-key preserves (PostureSwitch.swift:1150-1156), so entering Castle and a follow into Castle delete the same account that held the old L. **HOLDS.**
  - L gated / probe: `gatedQuery`/`probeQuery` merge DP; the gated item is not synchronizable so the default (false) matches it. **HOLDS.**
  - sync custody plain/gated/probe: `boundQuery`/`gatedQuery`/`probeQuery` merge DP (EncryptionKeychain.swift `E2EEKeychainStorage`). **HOLDS.**
  - legacy E2EE: plain without DP (file-based, as written by 14b), gated with DP (EncryptionKeychain.swift:717-725). **HOLDS.**
  - legacy escrow (synchronizable): the query CARRIES `kSecAttrSynchronizable: true` + DP (StoreKeyGuard.swift:450-457) — the one sync item ever deleted, flagged correctly. **HOLDS.**
  - A: `AppleKeyKeychain.delete` uses the full family query (sync + group + DP) — and production never calls it (A is never deleted, design §14.5). **HOLDS.**
  - session tokens on sign-out: bound (DP) + unscoped bound (DP) + legacy `session` (file-based) (AuthSession.swift `clear`/`deleteUnscoped`). **HOLDS.**
  - Sign-out and account deletion deliberately KEEP the custody items (EncryptionSession.swift:572-582 — decision 25 / copy §4); only the session tokens go. By design.
- NIT: every plain `add` handles `errSecDuplicateItem` by updating DATA only (StoreKey.swift:376-395; EncryptionKeychain `save`; AuthSession `add`), so a pre-existing item's protection class would be kept. Every such account name has only ever been written by the same code with the same class (the `-bound` accounts were DP-born at bbf5cf28), so no weaker item exists to inherit; noted for future accounts.
- NIT (her installs only, not new users): a pre-13x 14b legacy E2EE plain item lived in the FILE-BASED keychain (accessibility inert, Migration-Assistant-portable) and carried M. It is deleted by migration 2a's `legacyDelete` once the per-store item verifies; if that migration never completed on some machine, the old item lingers. Public users never had it.
- **What shows where (external facts, delegated; confidence noted):** DP-keychain generic passwords appear in Keychain Access.app under "iCloud" (or "Local Items" with iCloud Keychain off) — DTS-confirmed for a DP item (developer.apple.com/forums/thread/678497); A (synchronizable) under iCloud. Whether "Show Password" reveals a DP item's value with the login password, and whether the gated items list at all, is UNCONFIRMED (OPEN — a hands-on look on a dev-scope item would settle it; for Standard's silent items a reveal would only restate the documented "the login session releases Standard's keys"; Castle's gated items need biometry regardless). Third-party generic passwords are not expected in the Passwords app (medium-low confidence; OPEN). ThisDeviceOnly items are UID-wrapped in backups and unusable on another device (Apple Platform Security, "Keychain data protection" — high).

## WHAT I DID NOT CHECK
- The two ACTS' sequencing (Castle entry / follow: whether the key file's Apple copy, the vault's Apple-held copy and old snapshots are removed, and whether `transitionCustody` receives L′ rather than the old L when no resident key is held) — Areas A/B; I checked only that the Keychain deletes target the right accounts with the right flags.
- The live Supabase deployment (grants as deployed, Vault privileges, the actual `amr` contents) — read the SQL artifacts only; the post-deploy sweep is the live check.
- `SupabaseTransport` request shapes beyond confirming the key proof travels in the JSON body (per KeyProof.swift's doc), not a header/query.
- CArgon2's vendored source and SQLCipher's build flags (assumed SQLCipher 4 defaults: per-file salt, HMAC pages).
- The MCP shim / socket and the local MCP grants tables (Area elsewhere) beyond C-2's fence-key observation.
- Hands-on Keychain Access / Passwords app behaviour (the OPEN row).
- I ran no tests (no pin needed for a HOLDS that the code reads directly; C-1 is copy; C-2 would want a two-client fake-server pin: a server-rewritten pulled row with `ai_private_at` NULL and the original ciphertext applies, and the fence then reports unfenced).
