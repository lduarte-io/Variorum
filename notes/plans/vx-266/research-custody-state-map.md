# VX-266 research — the custody / posture STATE MAP (as implemented)

Read-only research for the pre-launch Castle redesign. Worktree `~/dev/variorum-vx-266` @ `63ec98c1`
(branch `vx-266-castle-backups-before-launch` = main). Code wins over docs; every claim cites `file:line`
and is marked **V** (verified — I read the code) or **I** (inferred — from names/docs/comments).
Paths are abbreviated: `Core/` = `Sources/VariorumCore/`, `Sh/` = `App/Variorum/Shared/`,
`Mac/` = `App/Variorum/Variorum/`, `Mob/` = `App/Variorum/VariorumMobile/`.

STATUS: complete (all eight sections). No code was changed; nothing was run beyond reads and greps.

## 1. State inventory

Legend for "keyed by": **S** = store id (the key file's `storeID`), **σ** = scope = store-variant raw value
(`Variorum` | `Variorum-dev`, `Core/Persistence/AppDatabase+Dependency.swift:71-74`), **fp** = library-key fingerprint
(first 8 bytes of SHA-256(L), hex — `Core/Persistence/StoreKeyEnvelope.swift:150-153`).

### 1a. The store id itself

| fact | evidence | V/I |
|---|---|---|
| A random lowercased UUID minted with an envelope (`StoreKeyEnvelope.init` default) | `StoreKeyEnvelope.swift:119` | V |
| Lives ONLY inside the key file(s) beside the store; read without any key via `StoreIdentity.resolve` → `loadCurrent` → `locate` | `Core/Persistence/StoreIdentity.swift:33-41`; `StoreKeyEnvelope.swift:482-504` | V |
| Stable across re-keys: `writeNewKeyFile` copies the resolved id into the new-fingerprint file (mints a fresh UUID only if no key file resolves) | `Sh/PostureSwitch.swift:1275-1287` | V |
| A NEW id is minted only by `StoreIdentity.establish` when the current file is foreign (fingerprint ≠ key) or absent, by "Start a New Library", and by a plaintext adoption | `StoreIdentity.swift:49-75`; `Sh/AppBootstrap.swift:1091-1097`; `Sh/LibraryOpenModel.swift:388` | V |
| **Two different library FILES share one store id**: every snapshot pair / backup / `Previous Libraries` copy carries a byte copy of the key file, so it carries the source's id; adopting it keeps that id (only the plaintext road mints) | `Sh/StoreBackup.swift:589` (pair = copy of live key file), `LibraryOpenModel.swift:358-370` (encrypted road keeps the file) | V |
| ⇒ every slot keyed by S is shared by every copy of a library on this Mac; a slot written for one copy is read for the other (the VX-209 mechanism). **Keyed by S:** 1c-1 silent L, 1c-2 gated L (+ probe), 1c-3 sync bound, 1c-4 sync gated (+ probe), 1c-7 legacy escrow (S alone, no σ), 1d-1 dials, 1d-2 `switchPending`, 1d-3 `thisDeviceOnlySwitch`, 1d-4 migration done/confirm, 1d-5 legacy `mode` where 1a wrote one. **NOT keyed by S:** 1c-6 A (σ), 1c-8 session (σ), 1d-6 stamps (σ), 1d-8 insurance (global), 1e-* (process), 1f-* (account) | — | V |
| "Current" key file when several sit beside the store = newest **mtime**, not the one custody's key matches | `StoreKeyEnvelope.swift:482-497` | V |

### 1b. Files beside the store / inside the store

| # | name | location | holds | keyed by | writers (file:func:line) | readers | lifecycle |
|---|---|---|---|---|---|---|---|
| 1b-1 | the library file | `Application Support/<σ>/variorum.sqlite` (always the default URL; no other location is ever opened) | SQLCipher ciphertext under L; temp `.encrypting`/`.rekeying` during migration/re-key | σ (path) | mint: `AppDatabase+Dependency.swift:openStore:103-140`; plaintext→encrypted `StoreEncryptionMigration.swift:migrateIfNeeded:73-193`; re-key `StoreEncryptionMigration.swift:rekey:220-329` via `PostureSwitch.swift:swapLibrary:1316-1325` → `AppBootstrap.swift:rekeyLibrary:837-874`; adoption swaps (other agent) | every open | born at first open; re-keyed by Use Castle, Replace All Keys and EVERY follow (`runFollow` always re-keys, `PostureSwitch.swift:977-1000`); never deleted by custody code |
| 1b-2 | key file, format 2 | `<store folder>/variorum-keys-<fp16>.json` (+ legacy `variorum-keys.json`) | `formatVersion, storeID, passphrase{kdf,wrapped}?, recovery?, keyFingerprint?, master? (L under M), apple? (L under A), appleKeyID?, vaultKDF?, vaultCorpusKeyID?, vaultRecoveryWrapDigest?` — **no posture field** | fp (name) + S (content) | see the key-file-writer census in §8 (16 production functions) | `locate`/`loadCurrent` (all routes, controller, lobby, migration, runner) | one file per L ever held; old files stay beside the store except `retireOldKeyFiles` (follow into Castle only, `PostureSwitch.swift:1019-1045`) |
| 1b-3 | set-aside key files | `variorum-keys-<fp>.stale-<epoch>.json` | a moved-aside foreign/old envelope | — | `StoreIdentity.setAside:80-85`; `StoreLaunchGate.live.setAsideEnvelope:116-121` | nothing (name fails `fingerprint(fromFilename:)` so `locate` ignores it, `StoreKeyEnvelope.swift:433-438`) | never deleted |
| 1b-4 | `sync_state.rekey_in_progress` | INSIDE the library DB (local-only table) | `RotationMarker` JSON: `step, entersCastle, oldKeyFingerprint?, newKeyFingerprint?, newCorpusKeyID?, startedAt, follow?` | the file (so every copy of the file carries it) | `PostureSwitch.swift:writeMarker:1827-1832`, `clearMarker:1834-1838`; `AppServices.swift:deleteAccount:567` clears | `SyncEngine.swift:refuseIfRekeyIncomplete:76-79`; `AppBootstrap.swift:517-519`; pane `ProtectionPane.swift:344-346`; `AppServices.swift:261-268` | set before the vault write; cleared after step 6 (`CorpusRotation.swift:138-241`) — I: a backup or `sqlcipher_export` taken mid-switch copies it |
| 1b-5 | `sync_state.last_server_seq` / legacy `device_id` | inside the DB | pull cursor; 13j-era device id (migration leg 1 carries it into custody then deletes the row) | file | `SyncEngine.swift:764-768`; `ProtectionMigration.swift:375-379` | engine; migration `:370-374` | cursor cleared by `resyncReinitialize` (`SyncEngine.swift:632-647`) |
| 1b-6 | rows' `owner_id` | inside the DB | the account that last synced each row | file | owner adoption / `restampOwner` (`AppServices.swift:451-462,504-514`) | `Queries.foreignOwnerExists` wired at `AppBootstrap.swift:523-525` → `reconcileFollow` `ProtectionController.swift:619` | — |
| 1b-7 | restore-hold marker | `<store folder>/variorum-restore-hold.json` | a held adoption | file folder | `LibraryRestoreHold.swift:51-56` (other agent) | `PostureSwitchModel.swift:274-278` refuses Use Castle / Replace All Keys while it stands | other agent's map |

### 1c. Keychain items

| # | item | service / account | flags | holds | keyed by | writers | readers | lifecycle |
|---|---|---|---|---|---|---|---|---|
| 1c-1 | **silent library-key item** (Standard / "Auto") | `io.lduarte.Variorum.store-key` / `<σ>-<S>-bound` | DP keychain; `WhenUnlockedThisDeviceOnly`; no ACL; not synchronizable; default access group (`StoreKey.swift:376-424`) | raw L (32 B) | σ+S | `StoreKeyKeychain.save:297-328` via: `openStore` mint `AppDatabase+Dependency.swift:167`; `transitionCustody(.auto)` `ProtectionController.swift:1372`; `relandSilentItem:1336-1345`; `startNewLibrary` `AppBootstrap.swift:1107`; `landCustody` `LibraryOpenModel.swift:535`; plaintext adoption `:393`; legacy migration on LOAD `StoreKey.swift:283-287,316-318,352-360` | `StoreKeyGuard.loadAuto` (`StoreKeyGuard.swift:88`) ← `rawKeyCustody` `StoreLaunchGate.swift:433-436`, landing arm `:413`, route `AppBootstrap.swift:351`, `currentKey` `ProtectionController.swift:880-882`, Apple arm `:1715`, sweep `:1530`, migration `AppBootstrap.swift:629`, `landCustody` `LibraryOpenModel.swift:517`; `DeviceKeyStore` shape `EncryptionKeychain.swift:349-351`; `openStore` `AppDatabase+Dependency.swift:158` | deleted (`deviceKeychainRemove` `StoreKey.swift:155-167`) by `transitionCustody(.biometric/.passphrase)` `ProtectionController.swift:1399,1415`, rollback `:1377`, `sweepLingeringSilentItem:1551`, `landCustody` `LibraryOpenModel.swift:539,541` |
| 1c-1L | legacy silent shapes | same service / `<σ>-bound` (DP) and `<σ>` (file-based) | — | raw L | σ only | none (read→migrate→delete) | `StoreKey.swift:344-347` | swept once per account per process `:431-437`; deleted on every save `:326` |
| 1c-2 | **gated library-key item** (Castle Touch ID) | `io.lduarte.Variorum.store-key` / `<σ>-<S>-biometric`; probe sibling `…-biometric-probe` | DP; SecAccessControl(`WhenUnlockedThisDeviceOnly`, `.biometryCurrentSet` alone) (`StoreKeyGuard.swift:289-298`) | raw L | σ+S | `saveGated` (delete-then-add after a probe add, `StoreKeyGuard.swift:269-287`) via `transitionCustody(.biometric)` `ProtectionController.swift:1395`; `landCustody` `LibraryOpenModel.swift:538`; legacy `<σ>-biometric` migrated at unlock `StoreKeyGuard.swift:396-407` | `unlockGated` (PROMPTS, one context also reads 1c-4) `:339-376`; `gatedItemExists` probe `:240-255` (lobby `biometryOffered`, sweep, `landCustody`) | deleted by `transitionCustody(.auto/.passphrase)` `:1376,1412`, rollback `:1400`, `landCustody:536,542`; **invalidated, not deleted,** by a biometry change (`.biometryCurrentSet`) — I |
| 1c-3 | **sync custody bound item** | `io.lduarte.Variorum.e2ee-keys` / `<σ>-<S>-sync` | DP; `WhenUnlockedThisDeviceOnly`; no ACL (`EncryptionKeychain.swift:589-603,754-760`) | `SyncCustodyRecord{deviceID, material?}`; `material` = `DeviceKeyMaterial{masterKey, corpusKey+ID, journalBridgeKey+ID, previousCorpusKey?+ID?, rotationStartedSeq?}` (`EncryptionKeychain.swift:61-68`; `Core/Crypto/VaultEnrollment.swift:10-45`). Silent shape: whole record; biometric / session-only shapes: identity-only (material nil) | σ+S | `DeviceKeyStore.save/clear/deviceID` `EncryptionKeychain.swift:402-449` (callers: `EncryptionSession.adoptEnrolledMaterial:566`, `adopt:642`, `forgetDeviceKeys:600`; runner `PostureSwitch.swift:755,990,1075,1184,1627`); `SyncCustodyTransition.move:251-294`; migration `:814-848`, `ProtectionMigration.swift:188` | `DeviceKeyStore.load` (engine every round via `DeviceKeySyncProvider.currentKeys` `:865-875`); route presence `StoreLaunchGate.swift:126-130`; reconcile `ProtectionController.swift:1455-1458`; `heldSyncMaterial:600-603` | `clear` keeps the identity (`:426-437`); never deleted by sign-out or account deletion (`AppServices.swift:537-545`) |
| 1c-4 | **sync custody gated item** | `io.lduarte.Variorum.e2ee-keys` / `<σ>-<S>-sync-biometric`; probe `…-sync-biometric-probe` | DP; SecAccessControl(`WhenUnlockedThisDeviceOnly`, `.biometryCurrentSet`) (`EncryptionKeychain.swift:637-662`) | the whole record | σ+S | `saveGated` via `DeviceKeyStore.save` (biometric shape) `:415`, `E2EECustodyStorage.setGated:219-229` | `readGated` under the lobby's evaluated context `:675-681` (called `StoreKeyGuard.swift:361-364`) → `SyncCustodySession.shared.hold` | deleted by silent/session-only saves `:412,421,431`; transitions `:234,266,284` |
| 1c-5 | legacy E2EE items (14b/CF-12) | `io.lduarte.Variorum.e2ee-keys` / `device-keys` (file-based), `device-keys-biometric` (DP) | — | bare `DeviceKeyMaterial` | none (scope-less) | none | migration leg 1 only, REAL scope only (`ProtectionMigration.swift:307-338`); gated one read at unlock `StoreKeyGuard.swift:365-374` | released by migration `EncryptionKeychain.swift:717-725` |
*[removed for publication]*
| 1c-7 | legacy 13p escrow | `io.lduarte.Variorum.store-key-escrow` / `<S>` | synchronizable, DP (`StoreKeyGuard.swift:450-457`) | RAW L in iCloud Keychain | S only | none | migration leg 2 `ProtectionMigration.swift:198-209` | removed only if equal to the key in hand |
| 1c-8 | auth session | `io.lduarte.Variorum.auth` / `<σ>-session-bound` (+ legacy unscoped `session-bound`, `session`) | DP; `WhenUnlockedThisDeviceOnly` (`Sh/AuthSession.swift:142-223`) | `AuthTokens` (userID, email, access/refresh) | σ only — **one session for every library opened under the variant** | `AuthSession.adopt` / refresh | `currentUserID`; `LobbyVaultRoad.live` pre-unlock (`LobbyVaultRoad.swift:41-54`); `OwnerIdentity` (`AppBootstrap.swift:497-501`) | cleared only by `signOut` (`AuthSession.swift:512-526`, `store.clear()` :524) |

### 1d. UserDefaults (standard domain; `ProtectionDefaults.key` = `variorum.protection.<σ>[.<S>].<leaf>`, `Sh/StoreProtection.swift:254-264`)

| # | key | holds | keyed by | writers | readers |
|---|---|---|---|---|---|
| 1d-1 | `.<S>.alwaysAsk` (Bool), `.<S>.relockIdleMinutes` (Int; 0 = never) | Castle's two dials | σ+S (read-through to σ-only legacy while the store has none, `StoreProtection.swift:283-298`) | `ProtectionController.persistDials:1431-1433`; `startNewLibrary` `AppBootstrap.swift:1104`; plaintext adoption `LibraryOpenModel.swift:389`; migration `ProtectionMigration.swift:383-387`, `retireLegacyKeys` `StoreProtection.swift:349-357` | gate `dials`; `DeviceKeyStore` shape `EncryptionKeychain.swift:365` |
| 1d-2 | `.<S>.switchPending` | VX-202 belt c: a switch's custody move is pending | σ+S | `PostureSwitch.swift:markSwitchPending:1868-1871` (from `writeMarker`/`clearMarker`); cleared by reconcile `ProtectionController.swift:1495-1499` | route landing arm `StoreLaunchGate.swift:409-411` |
| 1d-3 | `.<S>.thisDeviceOnlySwitch` | VX-110 This-Mac-Only road in flight | σ+S | `PostureSwitch.swift:1845-1848` | resume `:1513` |
| 1d-4 | `.<S>.migrated2a`, `.<S>.migration2aConfirmPending` | §11 migration done / confirm owed | σ+S | `ProtectionMigration.swift:360-363` | bootstrap `AppBootstrap.swift:631-633`; notices |
| 1d-5 | legacy `.<σ>[.<S>].{mode, escrowOff, relockOnSleep, reminders}`, `.<σ>.relockIdleMinutes` | 13p stored at-open mode etc. | σ (+S where 1a wrote one) | none now | `legacyMode` `StoreProtection.swift:304-323` → `Posture.derive` arm 3 |
| 1d-6 | `.<σ>.{firstUseAt, passphraseSetAt, reminderConfirmedAt, reminderDismissedAt, nudgeSnoozedUntil, nudgeDismissedForever}` | nudge / reminder stamps | **σ only — not per library** (`StoreProtection.swift:405-412`) | `ProtectionController.swift:1166,1447,1904-1925` | `refreshNotices:1877-1899` |
| 1d-7 | `variorum.e2ee.syncGateOptIn` | retired CF-12 opt-in | global | removed by migration (`EncryptionKeychain.swift:799`, `ProtectionMigration.swift:367`) | — |
| 1d-8 | `variorum.backup.markdownInsurance.enabled` | scheduled plaintext export on/off | **global (no σ, no S)** | turned OFF by entering Castle `PostureSwitch.swift:1363-1370` | `MarkdownInsurance.swift:65-74` |

### 1e. Process memory (lost at quit; several survive library adoption)

| # | holder | holds | lifetime | evidence |
|---|---|---|---|---|
| 1e-1 | `SyncCustodySession.shared` | `record` (gated read / vault road), derived passphrase-wrapping key + its KDF, legacy gated material | dropped at `lock()` (`AppBootstrap.swift:941`) and `adoptLibrary` (`:771`) | `EncryptionKeychain.swift:111-176` |
| 1e-2 | `ProtectionController` (ONE per process — built in `AppBootstrap.init`, `:164-168`) | `residentKey`/`residentAdopted`, `vaultReading`, `postureReading`, `appleKeyVerified`, follow/change notices, `switchInProgress` | process; **`vaultReading` is written only at `ProtectionController.swift:1463` and never cleared** (survives sign-out, account switch, adoption) | `ProtectionController.swift:274-365` |
| 1e-3 | `AppBootstrap.switchInProgress` | VX-202 gate i (re-key reopen in flight) | set `rekeyLibrary:845`, cleared `endSwitch:879-881` | `AppBootstrap.swift:127` |
| 1e-4 | `StoreBinding.key` | the open pool's L | nil at `lock()` | `Core/Persistence/StoreBinding.swift:40,89-113` |

### 1f. Server

| # | where | holds | keyed by | writers | readers |
|---|---|---|---|---|---|
| 1f-1 | `key_vault` row | KDF descriptor; `master_wrapped_by_passphrase`; `master_wrapped_by_recovery?`; `corpus_key_id` + wrap; `journal_bridge_key_id` + wrap; `revision`; `created_at`; `updated_at` (stamped by the RPC — `11_pre13x_postures.sql:955`, `12_phase13y_tenant_seq.sql:1569`; the 08 comment calling it insert-only is stale); `master_wrapped_by_apple_held?`; `apple_key_id?`; `key_proof_hash`; `corpus_previous_key_id?` + wrap; `rotation_started_seq?`; `updated_by_device?` | `user_id` (account) | create: `KeyVaultClient.swift:createVault:166-194` ← `VaultEnrollment.setUp:134-161,175-208`; update RPC `key_vault_update` `KeyVaultClient.swift:updateVault:224-272` ← `landRecoveryWrap:265-287`, `changePassphrase:302-341`, `rewrapPassphrase:352-366`, `CorpusRotation.begin:449-482` / `complete:652-669`, `leaveCastle` `PostureSwitch.swift:1454-1463`, `relandAppleHeldCopy` `EncryptionSession.swift:458-472` | `fetchVault` (single-flight) `KeyVaultClient.swift:131-158` — the ONE pre-unlock network contact via `LobbyVaultRoad` |
| 1f-2 | Supabase Vault secret `kp:<owner uuid>` | kp2 (per-request MAC key) | account | `key_proof_enroll` / rotation payload `key_proof_mac` (`12_phase13y_tenant_seq.sql:612-626,1491-1493`) | server proof checks |
| 1f-3 | `device_cursor` | per-device pull cursor (purge horizon) | device id (from 1c-3) | pull rounds with a device id | purge janitor (`10_phase13j_purge.sql:161-167`) |
| 1f-4 | rows' `server_seq` vs `rotation_started_seq` | which corpus key a row is under | row | server | `SyncPayloadCrypto.keyMaterial(forServerSeq:)` `Core/Sync/SyncEncryption.swift:201-206` |

**Not stored anywhere (V):** the posture (derived, `StoreProtection.swift:21-27`), "is this library Castle", "was this store id ever Castle", which Apple account a key belongs to (only A's random id), the effective gate (derived, `StoreProtection.swift:160-201`).

## 2. Key hierarchy

### 2a. Every key, what wraps it, where each wrap lives

| key | minted by | wrapped under → stored where | raw copies | V/I |
|---|---|---|---|---|
| **L** library/SQLCipher key (256-bit, per library FILE) | `StoreKey.mint` `Core/Persistence/StoreKey.swift:47-54` at: first open `AppDatabase+Dependency.swift:166`, "Start a New Library" `AppBootstrap.swift:1094`, plaintext adoption `LibraryOpenModel.swift:377`, every re-key `PostureSwitch.swift:1215` | **P-derived** → key file `passphrase.wrapped` (+ its own KDF descriptor) `StoreKeyEnvelope.swift:175-229`; **W-derived** → `recovery` `:234-244`; **M** → `master` `:252-261`; **A** → `apple` + `appleKeyID` `:285-297` (RFC 3394 `AES.KeyWrap` throughout) | 1c-1 silent item, or 1c-2 gated item, or none; `StoreBinding.key` while open; `ProtectionController.residentKey` after a lobby/Apple-road/adoption open | V |
| **M** master (256-bit, per ACCOUNT) | `VaultEnrollment.setUp` `VaultEnrollment.swift:141,185`; `CorpusRotation.prepare` `CorpusRotation.swift:408` | P-derived → vault `master_wrapped_by_passphrase`; W-derived → `master_wrapped_by_recovery`; **A** → `master_wrapped_by_apple_held` + `apple_key_id` (`KeyVaultFormat.swift:122-158,192-205`) | `SyncCustodyRecord.material.masterKey` in 1c-3 (silent) / 1c-4 (gated) / session memory 1e-1 (Always ask) | V |
| **C** corpus key (+ id; AAD `table:rowID:column:keyID`) | same mints as M | M → vault `corpus_key_wrapped_by_master` (`KeyVaultFormat.swift:136-142`) | beside M in the custody record | V |
| **J** journal-bridge key (+ id) — dormant | same | M → vault `journal_bridge_key_wrapped_by_master` | beside M | V |
| **C_prev** (rotation only) | — (the old C) | **M′** → vault `corpus_previous_wrapped_by_master` + `corpus_previous_key_id` (`KeyVaultFormat.swift:230-263`) | custody record `previousCorpusKey*` + `rotationStartedSeq` (`VaultEnrollment.swift:27-29`) | V |
| **A** iCloud key (256-bit + random id, per iCloud account × σ) | `AppleKey.mint` `AppleKeyCustody.swift:65-68` inside `readOrMint` | — (it is a wrapping key; never wrapped) | 1c-6, synchronizable; never deleted | V |
| **P-derived key** | `PassphraseKDF.deriveKey` (Argon2id; `.v1` = 64 MiB, 3 passes; floor 19 MiB / 2 / 16-byte salt — `PassphraseKDF.swift:73-106`) | — | transient; held in session memory after a lobby passphrase unlock with its descriptor (`StoreLaunchGate.swift:929,991` → `SyncCustodySession.holdDerivedWrappingKey`) | V |
| **two KDF descriptors** | key file's `passphrase.kdf`; vault's `kdf` | — | reconciled via key file `vaultKDF` (`StoreKeyEnvelope.swift:90`); "derive once" only when equal (`StoreLaunchGate.swift:950-956`) | V |
| **W-derived key** | BIP-39 seed (PBKDF2-SHA512 ×2048, salt "mnemonic") → HKDF-SHA256 (salt `variorum.suite.e2ee.v1`, info `recovery-wrap-key`) `RecoveryPhrase.swift:28-30,166-177` | — | never stored | V |
| **kp1** | `HMAC(M, "variorum.key-proof.v1")` `KeyProof.swift:46-53` | — | computed; SHA-256(kp1) is the CREATION-time `key_proof_hash` (`KeyVaultFormat.swift:149-151`) and `key_proof_enroll`'s authorization | V |
| **kp2** | `HMAC(M, "variorum.key-proof.v2")` `KeyProof.swift:55-65` | — | computed; server keeps SHA-256(kp2) in `key_proof_hash` after enrollment/rotation and kp2 itself in Vault secret 1f-2; per-request proof = `HMAC(kp2, nonce‖":"‖rpc)` `KeyProof.swift:128-133` | V |
| **device identity** | `SyncCustodyRecord.fresh` / `DeviceKeyStore.save`/`deviceID` mint `EncryptionKeychain.swift:65-67,404-406,446-448` | — | 1c-3 (whole record or identity-only), every shape | V |
| **session tokens** | sign-in | — | 1c-8 (σ-scoped) — gates the vault READ only | V |

### 2b. Per posture: where every copy of L and M sits (as the code writes it)

| copy | Standard, local-only | Standard, enrolled | Castle, local-only (Touch ID) | Castle, local-only (Always ask) | Castle, enrolled (TID / AA) | "exposed" (Standard, no P, no A copy) |
|---|---|---|---|---|---|---|
| L raw | 1c-1 silent | 1c-1 silent | 1c-2 gated | none | 1c-2 / none | 1c-1 silent |
| L under P (key file) | optional | only if a passphrase was TYPED here (setUp / enroll-by-passphrase / change: `ProtectionController.swift:1802-1810`); the silent Standard enroll lands none (`reconcileFollow` arm i → `adoptEnrolledMaterial(typedPassphrase: nil)` `EncryptionSession.swift:560-577`) — the lobby still offers the passphrase road via `master` (`StoreLaunchGate.swift:605-607`) | required (ceremony sets it, `PostureSwitchModel.swift:365-369`) | required | required | absent |
| L under W (key file) | optional | present when typed/generated here | optional (nil if the ceremony had no words) `PostureSwitch.swift:1297-1299` | optional | optional | absent |
| L under M (key file) | absent | present (`landVaultMaterial:1813`, migration leg 5, `writeNewKeyFile:1300-1304`) | absent | absent | present | absent |
| L under A (key file) | present once the Apple arm lands (`ProtectionController.swift:1733-1755`); absent while A unreadable (Standard-waiting) | present | **absent** (`writeNewKeyFile` gets `appleKey: nil`, `PostureSwitch.swift:801,1305-1307`) | absent | absent | absent |
| M raw | — | 1c-3 silent record | — | — | 1c-4 gated + 1c-3 identity-only / session memory + 1c-3 identity-only | — |
| M under P, W (vault) | — | present | — | — | present | — |
| M under A (vault) | — | present (`setUp(appleHeldCopy:)` `VaultEnrollment.swift:200-203`; kept by Standard Replace All Keys `CorpusRotation.swift:426-429`) | — | — | **absent** (entering Castle writes none; `PostureSwitch.swift:687-688`) | — |

**Posture is never written; it is read off this table** — Standard ⇔ "an A copy exists (vault for the account, key file for a local-only library)", with corner 45 reading the absence of the key-file A copy through the raw-L custody shape (§3, §5). Old key files / snapshot pairs keep whatever copies they had (an A copy in every Standard-era file) — I (design §3.4), V for the live folder (`StoreKeyEnvelope.swift:423-426`, old files never deleted except `retireOldKeyFiles`).

### 2c. How the sync engine consumes the keys (V)
Per round half, before any network: `refuseIfRekeyIncomplete` (any marker ⇒ `accountRekeyIncomplete`, `Core/Sync/SyncEngine.swift:76-79,152`) → `roundCrypto` = `keyProvider.currentKeys()` (ANY throw ⇒ `encryptionKeysUnavailable`, `:114-120,155,433`) → pull only: `roundDeviceIdentity` (`:438,773-779`) → one `SyncChallengeSigner` per half (`:159,441`; `KeyProofChallenge.swift:44-106`). The production provider is `DeviceKeySyncProvider` over `DeviceKeyStore.keychain` (`EncryptionKeychain.swift:858-880`; composed `AppServices.swift:172-175`): `currentKeys` = custody material → `syncKeys` (C + id, kp material, rotation) (`VaultEnrollment.swift:63-68`); a locked Castle device has no session record ⇒ no keys ⇒ refused round. Payloads seal under C with AAD `table:rowID:column:keyID`; a pulled row below `rotation_started_seq` opens under C_prev (`SyncEncryption.swift:143-257`). The purge janitor and the rotation walk read the same provider / material (`PurgeJanitor.swift:94,803`; `CorpusRotation.swift:541-614`). `pullToHead`/`resyncReinitialize` bypass the marker guard on purpose (`SyncEngine.swift:84-101,632-647`).

## 3. Decision functions

⚠ = a READ THAT WRITES (a function whose name/role is a reading but which can change Keychain, a file, or the vault).

### 3.1 `Posture.derive(legacyMode:vaultHasAppleHeldCopy:keyFile:rawKeyCustody:enrolled:) -> PostureReading` — pure (V, `Sh/StoreProtection.swift:85-119`)

| arm (in order) | condition | result |
|---|---|---|
| 1 | `vaultHasAppleHeldCopy != nil` | `.determined(apple ? .standard : .castle)` |
| 2 | `enrolled` | `.indeterminate(shape:)` = `shapeReading`: raw `.silent` → Standard · `.gatedOrNone` → Castle · `.unknown` → `localReading(keyFile, .unknown)` |
| 3 | `legacyMode != nil` | `.determined(isDemanded ? .castle : .standard)` |
| 4–5 | else | `.determined(localReading(keyFile, raw))` |

`localReading` (the local-only rule, **corner 45 at `:106`**):

| key file | `apple` | `passphrase` | raw-L custody | → |
|---|---|---|---|---|
| none | — | — | any | Standard (born) |
| present | ✔ | any | any | Standard |
| present | ✘ | ✘ | any | Standard (exposed / waiting) — note `recovery` is NOT consulted |
| present | ✘ | ✔ | `.silent` | **Standard ("Standard-waiting", corner 45)** |
| present | ✘ | ✔ | `.gatedOrNone` / `.unknown` | Castle |

`PostureReading.acting` (`:134-139`) = the determined posture, else the shape's; `determined` is nil while indeterminate — every posture-driven write is supposed to require it.

### 3.2 `StoreAtOpenMode.effective(posture:dials:)` — pure (V, `StoreProtection.swift:189-200`)
Standard → `.auto`; Castle → `dials.alwaysAsk ? .passphrase : .biometric`. **No biometry check** (a Castle library on a Mac without Touch ID whose dial was never set reads `.biometric` — §8 S-8).

### 3.3 ⚠ `StoreLaunchGate.effectiveGate(scope:storeID:storeURL:) -> StoreAtOpenMode` (V, `Sh/StoreLaunchGate.swift:405-427`)
Inputs: the guard's silent-item read, `syncCustodyPresent(σ,S)`, `switchPending(σ,S)`, the current key file, `legacyMode(σ,S)`, the dials, A.
1. `custody = rawKeyCustody(guard)` — `.silent` iff `loadAuto()` returns a key, else `.gatedOrNone` (`:433-436`; the gated item is NOT probed despite the doc comments at `:358-361,429-432`). ⚠ `loadAuto` → `StoreKeyKeychain.load` can migrate legacy items and even `establish` a key file (`Core/Persistence/StoreKey.swift:283-287,316-318`).
2. `enrolled = syncCustodyPresent` — ANY bound record (an identity-only one counts) or the gated probe (`:126-130`).
3. **The landing arm (the write, `:411-420`):** `!enrolled ∧ !switchPending ∧ custody == .silent ∧ keyFile.apple == nil ∧ keyFile.passphrase != nil ∧ loadAuto() belongs(to: keyFile) ∧ A readable` ⇒ wrap the SILENT key under A into the key file and save it.
4. derive (§3.1) over the (possibly just-landed) key file → `effective(reading:dials:)`.
Callers — every one inherits the write: the route `AppBootstrap.swift:329-330`; `currentEffectiveGate` `:668-674` (← the R1-M3 re-land check `:548`, the §11 migration `:638`, `lock()` `:913`, the phone's relock coordinator on EVERY scene change `Mob/VariorumMobileApp.swift:307`); `LibraryOpenModel.landCustody` `LibraryOpenModel.swift:533`.

### 3.4 The launch route — `AppBootstrap.routeAndOpen` (V, `Sh/AppBootstrap.swift:306-461`)

| unlockedKey | effective gate | presence | further facts | outcome |
|---|---|---|---|---|
| ✔ (lobby/adoption/re-key reopen) | not consulted | — | — | open with `StoreKeyCustody.inMemory(key)` (`:402-405`) |
| — | `.auto` | absent | — | open; `openStore` MINTS L, saves the silent item, establishes a key file (`AppDatabase+Dependency.swift:166-174`) |
| — | `.auto` | encrypted | silent item present | silent open |
| — | `.auto` | encrypted | silent missing; key file has A/P/W; Apple road opens | open with the A-unwrapped key as `unlockedKey` (`:350-357`) |
| — | `.auto` | encrypted | silent missing; wraps present; Apple road fails | `.waiting` lobby, demand `.auto`, `differentAppleID` flag (`:358-374`) |
| — | `.auto` | encrypted | silent missing; NO wraps / unreadable | `openStore` throws `keyUnavailable` → `failedOutcome`: doorless |
| — | demanded | absent | — | `.libraryMissing(demand)` (`:377-381`) |
| — | demanded | encrypted/plaintext | — | `.locked` lobby: `biometryOffered = demand == .biometric ∧ gatedItemExists`; `passphraseOffered = P ∨ M`; `recoveryOffered = W ∨ M` (`:382-391`, `StoreLaunchGate.swift:605-610`) |
| — | any | — | open threw `keyUnavailable` ∨ `keyRejected` (VX-80), key file has P or W | `.failed` + a recovery lobby (typed roads only, demand `.passphrase`) (`:432-461`) |

### 3.5 The controller's projection (V, `Sh/ProtectionController.swift`)

| function | inputs | output | notes |
|---|---|---|---|
| `refreshPosture` `:1057-1065` | `legacyMode`, **cached** `vaultReading?.hasAppleHeldCopy`, key file, `libraryKeyCustodyShape`, `enrolled` | `postureReading`, `posture = acting` | called by `refreshEnvelopeFacts` (`:1008-1017`) after nearly every act |
| `libraryKeyCustodyShape` `:1093-1096` | `residentAdopted`, `residentKey` | `!adopted → .unknown`; `resident != nil → .gatedOrNone`; else `.silent` | **inferred from HOW the store was opened, not read from the Keychain** (§5) |
| `enrolled` `:362-365` | `signedInAtReady`, `syncCustodyPresentAtReady` (material in the silent item or gated probe, `:1455-1458`), session record | Bool | ≠ the route's "enrolled" (identity-only record counts there) |
| `effectiveGate` `:290-292` | `posture`, `dials` | gate | drives `canLock`, the relock monitors (`:2023-2034`), `legs.storeCustodyGated` |
| `libraryOwnPosture` `:1074-1078` | key file, shape | derive with `enrolled:false, vault:nil` | used by sync setup's vault shape (`EncryptionSession.swift:302-310`), enroll facts (`:785`), the VX-110 consent guard (`:1622`) |
| `legs` / `ProtectionLegs.tier` `:326-334`, `StoreProtection.swift:529-533` | P, W, `appleKeyVerified`, waiting, unreadable | `unknown` > `covered` (P ∨ W ∨ verified A) > `waiting` > `exposed` | the exposed nudge |

### 3.6 ⚠ `ProtectionController.reconcile()` — "idempotent launch housekeeping" (V, `:1442-1504`)
Order and writes: re-read dials → stamp `firstUseAt` (defaults write) → `signedInAtReady`, `syncCustodyPresentAtReady` → vault read (`readVaultPosture`; a nil answer — signed out, offline, OR no vault — **leaves the previous reading standing** for `refreshPosture`/the Apple arm, while `reconcileFollow` receives only the fresh reading, `:1461-1465,1473`) → **`sweepLingeringSilentItem`** (may DELETE the silent item, `:1522-1557`) → `reconcileFollow` (may LAND custody + key file, or RUN the silent follow into Standard) → clear a stale `switchPending` flag (`:1495-1499`) → **`reconcileAppleKey`** (may mint A, set aside a key file, write the key file, write the VAULT) → notices.
Callers: ready housekeeping `AppBootstrap.swift:612-617` (twice per launch/unlock: the ready road and `runReadyHousekeeping` after services start, `VariorumApp.swift:353`, `VariorumMobileApp.swift:174`); end of every runner road (`PostureSwitch.swift:1114,1251,1479,1778`); Connect (`PostureFollowModel.swift:179`); relink (`AppleRelinkModel.swift:184`). **Never at sign-in or sign-out** (`AppServices.swift:393-409`).

`reconcileFollow(_:)` decision table (V, `:607-817`):

| # | condition | verdict | write? |
|---|---|---|---|
| 0 | no vault reading, or no corpus id | clear `differentOwner`, `enrollReading` | — |
| 1 | any owner-carrying row stamped by another account | `differentOwner` (Connect door) | — |
| 2a | material in hand; custody corpus id ≠ vault's | follow owed: `movedToCastle` if vault has no A copy ∧ key file has one, else `keysReplaced` | — |
| 2b | material; vault Castle; `libraryKeyCustodyShape == .silent`; no switch | `castleStillOpensOldWay` | — |
| 2c | material; vault Castle; key file carries `apple`; no switch | `castleKeyFileAppleOpenable` (13x R1-BLOCKER) | — |
| 2d | material; otherwise | change notice (`changeElsewhere`, `:822-836`); and if vault Standard ∧ (key file has no `apple` ∨ shape `.gatedOrNone`) ∧ no switch ∧ act wired ⇒ **`followIntoStandard()`** | **YES** (A readOrMint, key file, custody → silent) |
| 3i | no material; recorded corpus id nil-or-current; derived key held under the vault's descriptor opens M | `landEnrollment` (custody + key file) else session hold | **YES** |
| 3b | no material; recorded == vault id; derived key under another descriptor | `alwaysAskRetiredWord` banner | — |
| 3i′ | no material; recorded nil-or-current; no custody at ready; signed in | account = vault A copy?; library = `libraryOwnPosture`; A matched/absent/different; Standard∧Standard∧matched ⇒ unwrap M by A and **`landEnrollment`**; else `EnrollFacts` (the four directions) | **YES** (silent Standard enroll) |
| 3ii | no material; recorded id ≠ vault's | follow owed (`movedToCastle` / `keysReplaced`) | — |

`reconcileAppleKey()` (V, `:1600-1755`):

| condition | action |
|---|---|
| reading indeterminate | nothing |
| determined Castle | `appleKeyVerified = false`; nothing written |
| VX-110: no sync custody at ready ∧ shape `.gatedOrNone` ∧ `libraryOwnPosture == .castle` | nothing (consent first) |
| else | key = resident ?? `loadAuto`; ⚠ `ensuredEnvelope(for:)` SETS ASIDE a current key file whose fingerprint ≠ key (`:1129-1142`); A = `read() ?? (mintAllowed ? readOrMint() : nil)` with `mintAllowed = vaultAppleKeyID == nil ∨ holdsMaster` (`:1636-1643,1725-1726`) |
| no A, mint disallowed | `appleKeyWaiting` |
| no A, mint refused | `appleKeyLandingFailed` |
| holds M ∧ A was READ ∧ key file's `appleKeyID` == vault's ∧ A.id ≠ vault's | **vault write**: `healAppleHeldCopy` (`:1663-1679`) |
| copy under A already opens | `appleKeyVerified = true` |
| else | **key file write**: `setAppleWrappedCopy` + save + read-back verify (`:1733-1755`) |

`sweepLingeringSilentItem()` (V, `:1522-1557`): after adoption only; no switch/marker; a silent item AND a gated item; posture re-derived with raw custody forced `.gatedOrNone`; determined Castle; (resident ≠ silent) ∨ (key file fingerprint == silent ∧ P∨W) ⇒ **delete the silent item**.

`refreshNotices` precedence (V, `:1840-1902`): differentOwner > follow / followWaiting > alwaysAskRetired > movedToStandard > changedElsewhere (unless dismissed this open) > migrationConfirm > reminderDue (posture Castle; σ-scoped stamps) > nudge (determined Standard) > none.

### 3.7 ⚠ `DeviceKeyStore.keychain(scope:storeURL:)` — which item holds the sync record (V, `Sh/EncryptionKeychain.swift:329-371`)
Per call (i.e. at engine-round cadence through `DeviceKeySyncProvider.currentKeys`): S from the key file; raw-L shape = `StoreKeyCustody.deviceKeychain(σ,S).load() != nil ? .silent : .gatedOrNone` (⚠ legacy migration on load); `RoutePostureFacts(legacyMode, keyFile, raw, enrolled: false)` → posture → `effective(dials)` → `SyncCustodyShape` (`.auto→.silent`, `.biometric→.biometric`, `.passphrase→.sessionOnly`, `:82-88`). `load`: session record, else (silent shape only) the bound item's material. `save`: per shape (`:402-425`). ⚠ `deviceID()` mints into the bound item when none (`:438-449`).

### 3.8 ⚠ `LibraryOpenModel.landCustody(openingKey:scope:storeURL:gate:)` (V, `Sh/LibraryOpenModel.swift:509-545`) — adoption's custody write
`CustodyCollisionRule.verdict` (`Core/Persistence/CustodyCollisionRule.swift:49-56`): silent item held → same fp `.alreadyAligned` (return) / different `.adoptOpeningKey`; no silent but gated exists → `.adoptOpeningKey`; neither → `.mintFreshCustody`. Then the SHAPE comes from ⚠ `gate.effectiveGate` evaluated **with custody as it stands before the write** (an older copy's silent item for the same S ⇒ corner 45 ⇒ `.auto`): `.auto` → `saveAuto` + `deleteGated`; `.biometric` → `saveGated` + `deleteAuto`; `.passphrase` → delete both. Return values ignored; no `CustodyHandover` verify.

### 3.9 Door-availability decisions

| door | decided by | source of the fact | evidence |
|---|---|---|---|
| Use Castle… vs Use Standard (Mac pane, phone sheet) | `controller.posture` (cached acting reading) | local projection, not the fetched vault (VX-108) | `Mac/Features/Settings/ProtectionPane.swift:330-338`; `Mob/…/MobileProtectionSheet.swift:272-278` |
| …hidden / "pick up your keys first" | `controller.followPending` | last reconcile | `ProtectionPane.swift:307-314` |
| Finish… (resume) | `switchRunner.pendingMarker()` | DB marker | `ProtectionPane.swift:317-329,344-346` |
| ceremony start | `followPending`, restore hold, `checkDoor` (enrolled = vault ∧ transport ∧ signed in ∧ custody material; vault facts) | live vault read for enrolled; local otherwise | `PostureSwitchModel.swift:252-313`; `PostureSwitch.swift:465-487` |
| Replace All Keys front check | enrolled; key file's recorded corpus id vs vault's; `appleKeyReadable` (vault A copy ⇒ A readable and = vault id) | live vault | `PostureSwitchModel.swift:327-335`; `PostureSwitch.swift:449-463` |
| Use Standard act | `leaves.posture() == .castle` | local projection | `PostureSwitch.swift:1443` |
| Always ask toggle / idle / Lock Now section | `controller.posture == .castle` | local projection | `ProtectionPane.swift:184-186`; `ProtectionController.swift:1253-1255` |
| Lock Now enabled / any relock | `canLock` = ready ∧ `protection.effectiveGate.isDemanded`; `lock()` re-checks ⚠ `currentEffectiveGate` | projection, then the route's derivation | `AppBootstrap.swift:897-914` |
| reminder section | posture Castle ∧ (P ∨ W) | projection | `ProtectionPane.swift:188-191` |
| Re-link Apple account | posture Standard ∧ heal wired ∧ `encryption.state == .enrolled` | projection + cached `EncryptionSession.state` | `ProtectionPane.swift:394-399` |
| passphrase change here vs "under Account & Encryption" | `controller.enrolled ∧ hasPassphraseWrap` | ready-time projection | `ProtectionPane.swift:481-493` |
| key doors (change passphrase / regenerate) | `encryption.state == .enrolled` (cached) → vault fetch; forgot road by `posture`/`gate`/biometry | cached state + projection | `Sh/KeyDoorModel.swift:134-147,153-182` |
| one-secret tie on the set sheet | `VaultTie.make`: nil when `encryption.state` is `.signedOut/.noVault/.unknown` (⇒ the sheet mints its own secrets) | cached `EncryptionSession.state` | `Sh/PassphraseSetModel.swift:64-120` |
| vault born with an A copy at sync setup | `libraryOwnPosture == .standard` | local rule | `Sh/EncryptionSession.swift:302-310` |

### 3.10 Smaller deciders
- `StoreLobby.openWithAppleKey` (V, `StoreLaunchGate.swift:821-833`): no file/no `apple` → `.noAppleCopy`; A unreadable → `.appleKeyAbsent`; id mismatch or unwrap failure → `.differentAppleID`; else `.opened`.
- `StoreLobby.runEnvelopeRoad` (V, `:885-1041`): local copy first; on refusal and a key file with `master`, the concurrent vault read (≤10 s ceiling); vault opens M → `master` copy → L → ⚠ writes a fresh P (or W) copy + reconciliation into the key file (`:975-990,1031-1037`); holds the derived key in session memory.
- `ProtectionMigration.runBody` posture (V, `Sh/ProtectionMigration.swift:216-231`): `rawKeyCustody` inferred from `facts.effectiveGate.isDemanded`; indeterminate stops before legs 3–6 without marking done.
- Runner: `enrolled` (`PostureSwitch.swift:584`); `appleHeldCopyForStandard` (`:1407-1420`); custody target `moveCustodyForSwitch` (`:1327-1347`: entering Castle → `.passphrase` if `alwaysAsk ∨ !biometry` else `.biometric`; otherwise `effective(accountPosture ?? leaves.posture())`); `runFollow` posture from the vault (`:962`) and the no-rotation test (`:973-975`); `resume` (`:1490-1787`, §4).
- `EncryptionSession.refresh` → `VaultState` (V, `EncryptionSession.swift:228-269`): signed out / no vault / notEnrolled / enrolled / keysReplaced (`custodyMatchesVault` by key ids, `:634-639`) / newerFormat.

## 4. Acts (transitions)

Notation: **[K]** Keychain write · **[F]** key-file write · **[D]** defaults write · **[DB]** library-DB write · **[V]** vault write · **[S]** store-file swap. "Marker" = `RotationMarker` in `sync_state` (1b-4); "flag" = `switchPending` (1d-2). All V unless marked I.

### 4.1 New library (first launch, or "Start a New Library")
1. Route over an absent store reads `.auto` (no key file ⇒ born Standard, `StoreProtection.swift:102`) — but a σ-scoped legacy `mode` key, if still present, is read when no S exists (`StoreProtection.swift:304-323`) and could route `.libraryMissing` instead (I).
2. `openStore` mints L → `StoreKeyCustody.save(storeURL:)` → **[F]** `StoreIdentity.establish` (S + fp, no wraps) → **[K]** 1c-1 (`StoreKey.swift:297-304`; `AppDatabase+Dependency.swift:166-174`) → **[S]** born encrypted.
   "Start a New Library" instead: set aside the located key file (only the newest — older fp files stay, `AppBootstrap.swift:1091`, `StoreKeyEnvelope.swift:482-497`) → mint → **[F]** establish → **[D]** dials Auto for the NEW S → **[K]** `saveAuto` (`:1082-1119`); the old S's items stay, unreachable by name.
3. Ready: `adoptResident(nil)` ⇒ shape `.silent`; §11 migration runs for the new S (4.18) → **[D]** `migrated2a`; reconcile's Apple arm: Standard ⇒ A read-or-mint (mint allowed: no vault) → **[F]** `apple` copy (`ProtectionController.swift:1600-1755`).
- Crash windows: between establish and the Keychain add → a key file with no custody beside an absent/plaintext store; the next open's `load` finds nothing and (store absent) mints again — `establish` finds the stub's fingerprint ≠ the new key ⇒ sets the stub aside and mints a NEW id (`StoreIdentity.swift:52-58`) (I).
- If iCloud Keychain refuses the A write ⇒ `appleKeyLandingFailed`, no P/W ⇒ the **exposed** tier (`StoreProtection.swift:529-533`).

### 4.2 Set passphrase / words (local-only, or the set sheet)
`PassphraseSetModel.commit` (`Sh/PassphraseSetModel.swift:207-251`): ≥12 chars; **if `VaultTie` exists** the typed word must unwrap the vault (`:233-245`) → `ProtectionController.setPassphrase` (`:1149-1173`): derive off-main → `ensuredEnvelope` (⚠ sets aside a foreign file) → **[F]** P copy (fresh salt) → **[D]** `passphraseSetAt` (σ-scoped). Phrase half: W exists ⇒ done; vault has W ⇒ extend (typed, vault-verified) → **[F]** W copy + digest; else `generateAndLandRecoveryPhrase` → **[F]** W copy (`:1196-1213`).
- The local "Change Passphrase…" in Settings is this same sheet (`ProtectionPane.swift:481-493`): **no current-passphrase authorization** for a local-only library (the open-app actor is out of scope) — V.
- Posture effect: none by itself; but a key file that gains P while it has no `apple` and custody is silent becomes corner 45's "Standard-waiting" input (§3.1).

### 4.3 Use Castle — local-only (`runCeremony` non-enrolled branch, `Sh/PostureSwitch.swift:769-803` then `rekeyCustodyAndSnapshot:1208-1258`)
Preconditions: no marker; key in hand; signed out ∧ custody material ⇒ refused (`signInOrThisDeviceOnly`, `:611-614`) unless This-Mac-Only (4.10). Model screens: explain → set P if none → words (generate/confirm or type/verify against the key file) → floor + passphrase verify (`PostureSwitchModel.swift:357-547`); restore hold refuses at the door (`:274-278`).
1. **[D]** `thisDeviceOnlySwitch` cleared (or set + **[K]** forget, 4.10). Secrets derived with a FRESH salt (`:791-793`).
2. Mint L′ (`:1215`) → **[DB] marker `.rekeyLibrary`** {old fp, new fp} (+ **[D]** flag set first, `:1827-1832`).
3. **[F]** new key file `variorum-keys-<fp′>.json`: S copied; P (fresh kdf), W if words; no `master`, **no `apple`** (`:1270-1312`). **[D]** flag again (`:1226`).
4. **[S]** `bootstrap.rekeyLibrary`: `switchInProgress`, onWillLock, pool closed, `StoreEncryptionMigration.rekey`, reopen under whichever key opens (`AppBootstrap.swift:837-874`); the reopen's ready runs `reconcile` with `controller.switchInProgress` true (guards skip the follow/Apple arms).
5. **[DB] marker `.custody`** → `moveCustodyForSwitch(entersCastle:)` → target `.passphrase` if `alwaysAsk ∨ !biometry` else `.biometric` (`:1327-1347`) → `moveCustody`: **[K]** gated L′ write + verify + silent delete (or delete both) and the sync record's twin move (`ProtectionController.swift:1276-1330`) → `endSwitch`.
6. **[DB] marker `.snapshot`** (flag cleared) → fresh snapshot (Mac) → **[D]** insurance OFF → list pre-switch pairs + `Previous Libraries` copies (`:1349-1385`).
7. **[DB] marker cleared** + flags cleared (`:1834-1838`) → resume sync → reconcile → offer (pairs/copies deletion is a separate press, `:1429-1432`).
- The Always-ask DIAL is never written by this road: on a Mac without biometry custody lands "nowhere" while `alwaysAsk` stays false ⇒ the derived gate reads `.biometric` (§8 S-8).
- The old key file (with its `apple` copy, if Standard-era) STAYS beside the store on this road (`retireOldKeyFiles` runs only for follows, `:1248`); `locate` then depends on mtime (VX-191 B6c).

### 4.4 Use Castle — enrolled (the ceremony; `runCeremony` `:637-767` then steps 4–7 above)
Door: `checkDoor` reads the vault (offline throws); rotation in progress ⇒ refuse; signed-out-with-material ⇒ the two doors (`PostureSwitchModel.swift:279-312`).
1. Pause sync; drain: ≤3 × (push, `pullToHead`, outbox count) else refuse `outboxNotEmpty` (`:639-655`).
2. Fetch vault; refuse a previous corpus key; `RotationSecrets.derive(forRotationOf:)` (reuses the vault's descriptor when the word is unchanged, `CorpusRotation.swift:103-121`); words required when the vault has a W wrap (`:673-675`); current material from custody.
3. `CorpusRotation.prepare` (mint M′, C′, J′; C under M′ as previous; **no A copy when entering Castle**; hash = SHA-256(kp2′)) → **[DB] marker `.vaultWrite` {newCorpusKeyID}** (+ flag) → **[V]** `begin`: fetch, re-check, `key_vault_update` under the OLD proof with the successor MAC (`CorpusRotation.swift:449-482`).
   - CAS/proof refused and the vault's corpus id MOVED ⇒ the retry IS the follow: enroll by the typed passphrase, **marker cleared**, `runFollow` (`:706-751`).
4. **[K]** custody ← M′/C′/C_prev/seq (`:755-759`) → **[DB] marker `.reencrypt`** → walk (`sync_reencrypt` per batch) + wait past the visibility horizon → **[V]** completion clears C_prev+seq (refused while rows remain; ≤3 tries) → **[K]** custody ← cleared material (`:1145-1189`).
5. Steps 2–7 of 4.3 with the new key file carrying `master` (L′ under M′) + reconciliation record; no `apple`.
- VX-109 (ticket): `begin` re-fetches the vault and writes under THAT revision, so a concurrent Use Standard landed between step 2's fetch and `begin` is overwritten without its A copy (the prepared format was decided from the older fetch) — consistent with `CorpusRotation.swift:454-474` (V for the re-fetch; the race itself I).

### 4.5 Leave Castle / Use Standard (`PostureSwitchRunner.leaveCastle`, `PostureSwitch.swift:1441-1482`) — **no marker**
Guard `leaves.posture() == .castle` (local projection — VX-108). Model: Touch ID presence or the passphrase (vault-verified when tied) (`PostureSwitchModel.swift:665-693`).
1. **[K]** A `readOrMint` (`:1450`).
2. Enrolled (vault ∧ signed in ∧ material): **[V]** add `master_wrapped_by_apple_held` under the current proof (`:1454-1463`).
3. **[F]** key file `apple` copy of the SAME L (`:1465-1469`).
4. **[K]** `moveCustody(.auto)`: L gated→silent, sync record gated→silent (`:1471-1478`) → reconcile.
- Crash after 2: vault Standard, file/custody Castle ⇒ next ready `reconcileFollow` 2d runs `followIntoStandard` (heals). After 3: local-only ⇒ the route reads Standard by the `apple` copy, opens by the Apple road, R1-M3 re-lands the silent item (`AppBootstrap.swift:548-557`) — **the gated L item is never deleted** in that branch (nothing deletes a gated item under `.auto` except a custody move) — I.

### 4.6 Replace All Keys (`replaceAllKeys` → `runCeremony(entersCastle:false)`)
As 4.4 except: requires enrolled (else `replaceKeysNeedsSync`, `:598-601`); front check = recorded corpus id vs vault, A readable & = vault id on a Standard account (`PostureSwitchModel.swift:327-335`); `appleHeldCopyForStandard` READS A (never mints) and the SAME A wraps M′ in the vault and L′ in the new key file (`:687-698,1407-1420`); custody target = `effective(leaves.posture())` (current shape re-saved, `:1337-1338`); no insurance change; `listPreSwitchPairs:false` ⇒ no offer. Optional "Also choose a new passphrase" = a change-passphrase on the NEW vault afterwards (`PostureSwitchModel.swift:627-633`).

### 4.7 Crash-resume — the marker's arms (`PostureSwitchRunner.resume`, `PostureSwitch.swift:1490-1787`)

| marker step | crash point | resume arm | outcome |
|---|---|---|---|
| `.vaultWrite` | before the vault write (`FaultPoint.beforeVaultWrite`) | vault id == custody id ∧ no C_prev ⇒ **clear marker, `restartRequired`** (`:1529-1534`) | ceremony restarts (its own door again, `PostureSwitchModel.swift:709-728`) |
| `.vaultWrite` | write landed, custody did not | vault id ≠ custody ⇒ needs P or W → M′ from vault → **[K]** (`:1615-1630`); `byAnotherDevice` = stamped `newCorpusKeyID` ≠ vault id (`:1565-1570`) | finishes; words not landed if another device's |
| `.reencrypt` | mid-walk / before completion / before the cleared custody save | re-walk, complete (`:1664-1666`); a partial save re-derives C_prev from the vault (`:1631-1635`) | finishes |
| **`.rekeyLibrary`** | **after the marker, before the new key file (`:1219-1223`)** | `newKeyFromKeyFile` → **throws `rekeyFailed("the new key file is missing…")`** (`:1796-1799`); marker never clears | **VX-235: stuck forever** — every round refuses `accountRekeyIncomplete` (`SyncEngine.swift:76-79`); flag stays set (corner-45 landing disabled for S); every resume throws; library still opens under L (I for the user-visible face) |
| `.rekeyLibrary` | after the key file, before the swap | L′ from the new file (M′ via custody, else P/W) → `opens(newKey)` false ⇒ redo swap (`:1717-1734`) | finishes; meanwhile `locate` already names the NEW file (newest mtime) while the store is under L |
| `.rekeyLibrary`/`.custody` | after the swap, before custody moved | custody still releases the OLD L ⇒ next launch `keyRejected` → recovery lobby by typed P/W from the newest file (VX-80, `AppBootstrap.swift:420-461`); resume moves custody (`:1736-1744`) | finishes; R1-M3 re-land suppressed by gate ii (marker pending, `:548-557`) |
| `.custody` | L item moved, sync item not | resume re-runs `moveCustody` (idempotent: delete-then-add gated, `ProtectionController.swift:1394-1408`) | finishes; until then M sits in the SILENT bound item under a Castle library and the engine reads no keys (shape `.biometric` ⇒ load needs the session) — I |
| `.snapshot` / `.offer` | after custody | re-snapshot, retire old files if a follow into Castle, clear (`:1746-1786`) | finishes |
| any (local Castle road) | material re-landed after a crash | resume FORGETS sync material first (`:1503-1520`) | This-Mac-Only Done |
- No marker exists for: Leave Castle, follow into Standard, setUp/enroll/Connect, change passphrase, regenerate, relink, `landCustody` (adoption) — each relies on the next reconcile to heal (or on nothing).

### 4.8 The follow (another device switched) — detection §3.6 rows 2a–2d/3ii; acts in `PostureSwitch.swift`
- **Into Castle / after Replace All Keys** (`follow(passphrase:recoveryWords:)` `:858-900` or `follow(derivedPassphraseKey:kdf:)` `:912-951` — the lobby's held derived key when its descriptor = the vault's): M′ from the vault → `runFollow` (`:954-1004`): `entersCastle` = vault has no A copy.
  - **No-rotation road** (custody corpus id = vault's ∧ same M ∧ no C_prev — the posture-mismatch kinds): straight to `rekeyCustodyAndSnapshot(follow:true)` — **the library is RE-KEYED** (new L′) even though no account key changed; custody → gated/none; old key files retired (Castle) (`:974-984,1248`).
  - **Rotation road:** **[DB] marker `.reencrypt` {follow:true, no newCorpusKeyID}** → **[K]** custody M′ → finish the walk if rows remain → steps 4–7 with `listPreSwitchPairs = entersCastle ∧ wasStandardShaped`.
- **Into Standard (silent, no typing, no marker)** — `followIntoStandard` (`:1091-1117`), run BY THE RECONCILE (row 2d): **[K]** A readOrMint → **[F]** `apple` copy → **[K]** custody → silent → reconcile; `movedToStandard` notice.
- **Always-ask pickup** (`pickUpKeys` `:1055-1082`): new word → M from the vault → **[K/session]** material saved under the current shape (session-only) → **[F]** P copy re-wrapped under the vault's descriptor (`PostureFollowModel.swift:209-223`).
- **Change notices** (passphrase changed / words regenerated elsewhere): `pickUpKeys` (re-save of the SAME material) → **[F]** the new word's local copy + reconciliation (`PostureFollowModel.swift:183-208`); never a re-key.
- `Later` defers per open (`ProtectionController.swift:578-581`); key doors refuse while a follow is owed (`PostureSwitchModel.swift:261-264`, `KeyDoorModel.swift:163-166`).

### 4.9 Sign in (`AppServices.signInWithVariorum` → `AuthSession.adopt` → `variorumSignInChanged`, `AppServices.swift:330-409`)
**[K]** 1c-8 tokens → legacy-credential sweep → owner adoption (**[DB]** NULL `owner_id` rows stamped with the signed-in id, `:451-462`) → sync configured. **No reconcile and no enrollment run at sign-in** (only at the next ready, §3.6 callers); the controller's `signedInAtReady`/`vaultReading` stay as last read (I: stale until a relock/relaunch/ceremony).

### 4.10 Sign out · "This Mac Only" · sign out everywhere
- **Sign out** (`AuthSession.signOut(.local)`, `AuthSession.swift:512-526`): **[K]** tokens cleared → `account.variorum = nil`, `sync.stop()` (`AppServices.swift:405-408`). **Custody (1c-1…1c-4) and the key file untouched; `vaultReading` not cleared** (1e-2). After relaunch the library is "enrolled by custody" with no vault word ⇒ permanently INDETERMINATE (§3.1 arm 2) until signed in again — the Apple arm and §11 legs 3–6 never run while so (`ProtectionController.swift:1604-1607`; `ProtectionMigration.swift:226-229`).
- **This Mac Only** (VX-110, a Use Castle variant reached only signed out with material): **[D]** flag → `forgetSyncKeysVerified` → **[K]** `DeviceKeyStore.clear`: material removed from 1c-3/1c-4/session, **identity-only bound record kept** (`EncryptionKeychain.swift:426-437`) → 4.3. The account stays Standard; the route afterwards still reads the store as "enrolled" (identity-only record counts, `StoreLaunchGate.swift:126-130`) — consistent here only because the shape is gated (I).
- **Sign out everywhere**: `signOut(.global)` — same local effects (`AppServices.swift:389-391`).

### 4.11 Join / enroll an account (`Sh/EncryptionSession.swift`)
- **Sync setup (first device)** `setUp(passphrase:recoveryWords:)` `:284-323`: one-secret guard against the key file's P; `libraryOwnPosture == .standard` ⇒ A **readOrMint** (refuse if the Keychain refuses) → **[V]** vault born with P + W (+ A copy) under the KEY FILE's descriptor → **[K]** custody (`adoptEnrolledMaterial`) → **[F]** `master` copy + reconciliation + typed copies (`ProtectionController.swift:1800-1830`). The key file's A copy is landed later by the reconcile's Apple arm. Crash after [V] before [K]: the device holds nothing; a re-run refuses `vaultAlreadyExists` (`VaultEnrollment.swift:182-184`); road = enroll by passphrase (I).
- **Enroll by passphrase / words** `:336-369`: M from the vault → **[K]** custody (current shape) → **[F]** `master` + reconciliation + the typed word's copy re-wrapped under the vault's descriptor (corner 27).
- **Silent Standard enroll** (reconcile row 3i′): account Standard ∧ library Standard (own rule) ∧ A matched ⇒ M via A → **[K]** + **[F]** (no P copy lands — §2b).
- **(c) Standard-born joins a Castle account**: `joinCastle` → `runner.follow(passphrase/words)` (`VariorumApp.swift:326-328`) ⇒ re-key into Castle (4.8 rotation road with no prior custody).
- **(d) Castle-born joins a Standard account ("corner 6", consent)**: until Join, the VX-110 guard keeps the Apple arm off (`ProtectionController.swift:1614-1628`); `declineStandardJoin` is a per-PROCESS flag (`EncryptionSession.swift:133,432-434`). `joinStandard` (`:402-429`): M via A (if A.id = vault's) else typed → **[K]** custody (current, gated shape) → **[F]** `master` → `followIntoStandard` (**[K]** A readOrMint, **[F]** `apple`, **[K]** custody → silent).
- **Connect (rows owned by another account)** `AppServices.connectLibrary` `:477-495`: enroll by typed secret → **[DB]** `restampOwner` + `resyncReinitialize` (sync stopped) → **[K]+[F]** `adoptEnrolledMaterial` → reconnect. No marker: a crash between the restamp and custody leaves a re-stamped library with no custody and a key file still recording the OLD account's corpus id ⇒ the next ready reads row 3ii "keys replaced" and offers a follow (a re-key) instead of a Connect (I).

### 4.12 Account deletion (`AppServices.deleteAccount`, `:546-580`; `Core/Crypto/AccountDeletion.swift:20-35`)
Sync stop → password re-auth (`verifyPassword`, grant revoked) → **[V]** `account_purge` (vault row + data + entitlements + auth user) → **[DB]** marker cleared → sign out. **Custody and the key file are KEPT**: M (dead) stays in 1c-3/1c-4; the key file keeps `master`/`vaultKDF`/`vaultCorpusKeyID`. ⇒ "enrolled by custody" + signed out ⇒ indeterminate until a NEW vault exists (sync setup again: `setUp` overwrites custody; Connect/move handles the foreign `owner_id` stamps) (I for the after-state face).

### 4.13 Change passphrase (`KeyDoorModel` → `EncryptionSession`)
- Enrolled (`changePassphrase` `EncryptionSession.swift:516-527`): **[V]** vault P wrap re-wrapped (fresh salt; current P or the words authorize) → **[K]** custody re-saved (same material) → **[F]** P copy under the vault's NEW descriptor + reconciliation (`reconcilePassphraseWrap` `ProtectionController.swift:1764-1787`). Forgot roads (Standard plain confirm / Castle Touch ID / words) use `rewrapPassphrase` from HELD material (`:536-549`). Crash between [V] and [F]: the device's own key file now disagrees with the vault ⇒ its next ready raises "passphrase changed elsewhere" against itself (`changeElsewhere`, `:822-836`) — I.
- Local-only: the set sheet (4.2), no authorization.

### 4.14 Regenerate twelve words
Enrolled only (`KeyDoorModel.authorizeRegenerate` needs the vault tie, `KeyDoorModel.swift:316-319`; the doors render only on the enrolled Encryption surface, `EncryptionViews.swift:596-607`): authorize (vault-verified P / device confirm / old words) → fresh words → confirm → **[V]** `landRecoveryWrap(allowReplace:true)` → **[F]** W copy + digest (`EncryptionSession.swift:487-504`). **A local-only library has no regenerate door** (the set sheet's phrase half ends when a W exists, `PassphraseSetModel.swift:253-257`).

### 4.15 Lock / unlock
- **Lock** (`AppBootstrap.lock`, `:909-951`): ⚠ `currentEffectiveGate` (may LAND an A copy) must be demanded → onWillLock (flush, services stop, MCP detach) → lobby facts → `.locked` → `dropResident`, per-open deferrals reset, `syncCustodySession.drop()` → `binding.lock()` (TRUNCATE checkpoint, close) → lock-time keyless copy (Mac).
- **Unlock**: Touch ID (`unlockGated`: ONE evaluated context reads 1c-2 and 1c-4; **[K]** migrates a legacy gated item; fills the session, `StoreKeyGuard.swift:339-376`) · passphrase/words (local copy first, then the vault road; **[F]** on vault success, `StoreLaunchGate.swift:885-1041`) → `beginOpening(unlockedKey:)` → ready → `adoptResident(key)` → housekeeping. Mac auto-ask once per lobby, only while active (`StoreLaunchGate.swift:683-706`); phone auto-asks per VIEW appearance (§7).

### 4.16 Touch ID / Face ID enrollment changes
Both gated items carry `.biometryCurrentSet` (`StoreKeyGuard.swift:289-298`; `EncryptionKeychain.swift:641-645`) ⇒ a finger added/removed invalidates them (platform behavior, I). The lobby still offers Touch ID while `gatedItemExists()` answers (it probes presence, not validity — `AppBootstrap.swift:387`); the ask fails ⇒ passphrase road. **Nothing re-saves the gated L item after a passphrase unlock** (the only `saveGated` callers are `transitionCustody(.biometric)` and `landCustody`, §8 census) ⇒ every later launch falls to the passphrase until a custody move (Always ask on→off) — V for the code path, I for the platform effect. The SYNC gated item does heal at ready when online: reconcile row 3i lands the vault's material from the derived key (`ProtectionController.swift:751-771`) → `DeviceKeyStore.save` biometric shape re-creates it (`EncryptionKeychain.swift:414-418`).

### 4.17 Always ask toggle · relink
- `setAlwaysAsk` (`ProtectionController.swift:1252-1263`): posture Castle; `moveCustody` (both families, rollback on a sync refusal) → **[D]** dial persisted only when both moved.
- Re-link Apple account (`Sh/AppleRelinkModel.swift`): Standard, no follow owed, A READ (never minted), passphrase key act → **[V]** `healAppleHeldCopy` → reconcile lands the key file's copy (**[F]**).

### 4.18 §11 migration — once per S at the first ready (`Sh/ProtectionMigration.swift:143-293`)
Done-flag keyed by S, so it re-runs for EVERY new store id (a new library, a plaintext adoption) (V, `:353-361`). Legs: (1) legacy sync items → per-store record (**[K]**, REAL σ only) or the `sync_state.device_id` → identity-only item; (2) legacy escrow removed if it equals the key; posture derived with `rawKeyCustody` from `effectiveGate.isDemanded`; indeterminate ⇒ stop, undone; (3) **[D]** legacy dial keys retired; (4) **[K]** custody aligned (`alwaysAsk` forced true without biometry, `:240-244`); (5) **[F]** `master` copy + reconciliation from held material; (6) **[D]** confirm pending; **[D]** done.

## 5. Inference heuristics

Every place one fact is derived from another instead of read from an authority. "Authority" = the fact's own home (the vault for the account's posture; the Keychain for where L sits; nothing at all for "this library is Castle" — no such record exists).

| # | inferred fact | inferred from | where | what goes wrong (V = traced in code, I = inferred) |
|---|---|---|---|---|
| H1 | a local-only library's posture | key-file wrap presence: `apple` ⇒ Standard; no `passphrase` ⇒ Standard; else custody shape | `StoreProtection.swift:101-109` | a recovery-only file (W, no P, no A) reads Standard; a Castle library's own key file carries no "Castle" mark, so posture is reconstructed on every read (V) |
| H2 | **Castle vs Standard-waiting (corner 45)** | whether THIS MAC's silent item for S releases a key | `StoreProtection.swift:105-108`; `StoreLaunchGate.swift:433-436` | S is shared by every copy of a library (§1a), so another copy's silent item decides this copy's posture — the VX-209 way-back (`landCustody` writes the silent item for the shared S, `LibraryOpenModel.swift:509-545`; the next route/ready reads "silent" ⇒ Standard ⇒ lands an A copy) (V; VX-201 U5 reproduced it) |
| H3 | **raw-L custody shape inside the controller** | whether the bootstrap handed over a resident key | `ProtectionController.swift:1093-1096` (set by `adoptResident`, `AppBootstrap.swift:530`) | every open with an `unlockedKey` — the Castle lobby, the route's Apple road (`AppBootstrap.swift:350-357`), the waiting lobby, the failure-recovery lobby, every adoption reopen (`:783`), every re-key reopen (`:863-867`) — reads `.gatedOrNone` even when custody is silent; persists until lock / relaunch / a custody move (F-U5-5) (V for the mechanism) |
| H4 | raw-L custody in the §11 migration | `effectiveGate.isDemanded` | `ProtectionMigration.swift:224` | circular: the gate was itself derived from custody (V) |
| H5 | **"enrolled"** — FIVE definitions | route: ANY bound record (identity-only counts) or gated probe · ready: signed in ∨ material ∨ session record · runner: vault ∧ transport ∧ signed in ∧ material · key doors: cached `EncryptionSession.state == .enrolled` · sync shape: always `false` | `StoreLaunchGate.swift:126-130`; `ProtectionController.swift:362-365,1453-1458`; `PostureSwitch.swift:584`; `KeyDoorModel.swift:134-137`; `EncryptionKeychain.swift:352-362` | after This-Mac-Only or any `clear`, the route reads "enrolled ⇒ indeterminate" while the ready reads "not enrolled ⇒ determined" (V); a signed-out library holding material is indeterminate after every relaunch (V) |
| H6 | the account's posture at ready | the LAST successful vault read, cached | `ProtectionController.swift:1461-1465` (only writer `:1463`) | survives sign-out, account deletion and library adoption in the same process; `refreshPosture` (`:1060`), the sweep (`:1537`) and therefore the Apple arm's determined-posture gate and its `mintAllowed` (`:1636`) act on it — only `reconcileFollow` is handed the FRESH reading alone (`:1473`) (V that it is never cleared; I for a concrete bad write) |
| H7 | **which posture doors render / act** | the controller's acting posture (cached; under indeterminate the custody shape) | `ProtectionPane.swift:184-191,330-338`; `MobileProtectionSheet.swift:272-278`; `PostureSwitch.swift:1443`; `ProtectionController.swift:1253` | VX-108: Use Castle vs Use Standard chosen from a local reading; e.g. after This-Mac-Only + a later sign-in the vault says Standard ⇒ the pane says Standard / offers Use Castle while every launch asks Touch ID (I) |
| H8 | "an account constrains this library" (key doors; one-secret tie) | cached `EncryptionSession.state` from the last `refresh()` | `KeyDoorModel.swift:134-137`; `PassphraseSetModel.swift:71-74` | `.unknown` (never refreshed / refresh failed) ⇒ no tie ⇒ the set sheet mints a local secret with no vault check (V for the branch) |
| H9 | **which item holds the SYNC record** | the library key's derived posture + dials (`RoutePostureFacts(enrolled:false)`) | `EncryptionKeychain.swift:340-366` | if the dial disagrees with custody (no-biometry Castle, §8 S-8) or a custody move half-ran, loads read the wrong item (sync silently "locked") and saves write the wrong shape (I) |
| H10 | which key file is "current" | newest mtime among `variorum-keys-<fp>.json` | `StoreKeyEnvelope.swift:482-497` | the old Standard-era file stays beside a Castle library on the ceremony road; an mtime flip would make it current (VX-191 B6c); between a new key file's write and the swap the NEW file is "current" while the store is still under L (V) |
| H11 | the library's identity | the current key file's `storeID` | `StoreIdentity.swift:33-41` | copies share it (H2's root) (V) |
| H12 | follow kind "moved to Castle" vs "keys replaced" | vault has no A copy ∧ the key file has one | `ProtectionController.swift:646-647,810-811` | wording only (V) |
| H13 | "a different account's vault" | rows' `owner_id` ≠ signed-in id | `ProtectionController.swift:619` | owner adoption stamps NULL rows at every signed-in start (`AppServices.swift:451-462`) (V) |
| H14 | passphrase / words changed elsewhere | key file's recorded `vaultKDF` / digest ≠ the vault's | `ProtectionController.swift:822-836` | this device's own interrupted change reads as "elsewhere" (I) |
| H15 | "my vault write landed" vs another device's | the marker's stamped `newCorpusKeyID` vs the vault's; fallback: `updated_by_device` NAME ≠ this device's name | `PostureSwitch.swift:1565-1570` | names are not unique (two Macs with one name) for pre-F1 markers (I) |
| H16 | "this library was Standard-shaped" (offer honesty) | the live / marker-named old key file carries `apple` | `PostureSwitch.swift:963,1672,1764-1769` | (V) |
| H17 | "this device holds the master" (A-mint permission) | sync material present at ready | `ProtectionController.swift:1636-1638` | (V) |
| H18 | "a same-Apple-account duplicate A" | key file's `appleKeyID` = vault's ∧ the A READ now has another id | `ProtectionController.swift:1666-1668` | an iCloud Keychain reset vs another Apple ID are indistinguishable (documented, `:1588-1599`) (V) |
| H19 | which lobby roads exist | P ∨ M (passphrase), W ∨ M (words), gated item PRESENCE (Touch ID) | `StoreLaunchGate.swift:605-610`; `AppBootstrap.swift:387,925` | an invalidated gated item still offers Touch ID (4.16) (I) |
| H20 | a "retired" passphrase | key file `vaultKDF` ≠ vault kdf | `StoreLaunchGate.swift:965`; `KeyDoorModel.swift:458-464` | wording (V) |
| H21 | the adoption confirm's "this copy leaves Castle" | the picked copy's own key file with `rawKeyCustody: .unknown` | `LibraryOpenModel.swift:316-334` | corner 45 cannot apply (custody unknown) ⇒ a passphrase-only copy reads Castle even when it was Standard-waiting (V) |
| H22 | "keys replaced" (`EncryptionSession.state`) | custody key IDS vs the vault's IDs, no unwrap | `EncryptionSession.swift:634-639` | (V) |
| H23 | "the Apple key leg is verified" | this Mac read A back and the copy unwraps | `StoreProtection.swift:480-489` | cannot prove iCloud propagation (documented) (V) |
| H24 | "Always ask" vs Touch ID | the dial | `StoreProtection.swift:189-200` | not what custody holds (§8 S-8) (V) |
| H25 | library present vs missing | 16-byte header / existence | `StoreKey.swift:491-508` | (V) |
| H26 | "is this library demanded" at ready | R1-M3 uses the ROUTE rule (`currentEffectiveGate`); the controller uses the RESIDENT rule (H3) | `AppBootstrap.swift:548` vs `ProtectionController.swift:1093` | two answers in one ready (V) |
| H27 | an indeterminate library's acting posture | its custody shape (decision 35) | `StoreProtection.swift:93-95,113-119` | by design; but "enrolled" (H5) decides who is indeterminate (V) |

## 6. Recognized shapes

### 6a. Every named state the code uses for a library's protection shape (V)

| type | cases | file:line |
|---|---|---|
| `Posture` | `standard`, `castle` | `StoreProtection.swift:28-30` |
| `PostureReading` | `determined(Posture)`, `indeterminate(shape: Posture)` | `:129-148` |
| `RawKeyCustody` | `silent`, `gatedOrNone`, `unknown` | `:154-158` |
| `StoreAtOpenMode` (the derived gate) | `auto`, `biometric`, `passphrase` | `:171-200` |
| `ProtectionDials` | `alwaysAsk`, `relockAfterIdleMinutes` | `:210-225` |
| `ProtectionLegs.Tier` | `covered`, `exposed`, `unknown`, `waiting` | `:512-533` |
| `SyncCustodyShape` | `silent`, `biometric`, `sessionOnly` | `EncryptionKeychain.swift:72-89` |
| `StoreLaunchRoute` | `open`, `lobby(demand)`, `libraryMissing(demand)` | `StoreLaunchGate.swift:323-349` |
| `StoreLobby.Kind` | `castle`, `waitingForICloudKeychain(differentAppleID:)` | `:452-458` |
| `StoreLobby.AppleRoadReading` | `opened`, `appleKeyAbsent`, `differentAppleID`, `noAppleCopy` | `:805-819` |
| `EnvelopeReading` / `StoreIdentity.Reading` | `absent/loaded/unreadable` · `known/none/unreadable` | `:218-232`; `StoreIdentity.swift:21-30` |
| `StoreFilePresence` | `absent`, `plaintext`, `encryptedOrUnknown` | `StoreKey.swift:459-470` |
| `AppBootstrap.State` | `opening`, `locked`, `waitingForICloudKeychain`, `libraryMissing`, `ready`, `failed(error, recovery:)` | `AppBootstrap.swift:57-82` |
| `EncryptionSession.VaultState` | `unknown`, `signedOut`, `noVault`, `notEnrolled`, `enrolled`, `keysReplaced`, `newerFormat` | `EncryptionSession.swift:45-69` |
| `EnrollFacts` (+ `AppleState`) | account posture × library posture × `matched/absent/differentAppleID/notApplicable`; `standardBornJoinsCastle`, `castleBornJoinsStandard` | `ProtectionController.swift:97-118` |
| `FollowNotice.Kind` | `movedToCastle`, `castleStillOpensOldWay`, `castleKeyFileAppleOpenable`, `keysReplaced`, `movedToStandard`, `alwaysAskRetiredWord`, `connectLibrary`, `passphraseChangedElsewhere`, `wordsRegeneratedElsewhere` | `:122-165` |
| `ProtectionController.Notice` | `nudge`, `reminderDue`, `migrationConfirm`, `follow`, `followWaiting`, `movedToStandard`, `alwaysAskRetiredWord`, `differentOwner`, `changedElsewhere` | `:373-402` |
| `RotationMarker.Step` | `vaultWrite`, `reencrypt`, `rekeyLibrary`, `custody`, `snapshot`, `offer` (+ `entersCastle`, `follow?`) | `CorpusRotation.swift:138-195` |
| `CeremonyAct` | `enterCastle`, `replaceKeys`, `leaveCastle`, `follow(entersCastle:)` | `PostureSwitchModel.swift:35-66` |
| `CustodyCollisionRule.Verdict` | `alreadyAligned`, `adoptOpeningKey`, `mintFreshCustody` | `CustodyCollisionRule.swift:27-40` |
| `CustodyHandover.Outcome` | `done`, `writeRefused`, `wroteButUnreadable`, `outgoingNotReleased` | `KeychainCustody.swift:218-240` |

**No code name exists for:** "Standard-waiting" (corner 45 returns plain `.standard`, `StoreProtection.swift:106`), "exposed" as a posture (it is only a nudge tier), "this store id was ever Castle", "a Standard library with a lingering gated item", "enrolled by an identity-only record", or "a vault-less account with custody" (§6b).

### 6b. The matrix — key-file wraps × raw-L custody × account × sync (what the code does with each)

KF = live key file; A/P = its `apple` / `passphrase` copies (W is never consulted by the posture rule). Local-only rows assume `enrolled = false` and no legacy `mode` key. "R" = the route's gate, "C" = the controller's acting posture after open.

| # | KF A | KF P | raw L | account (vault) | R / C | named? | handling / gap (V unless I) |
|---|---|---|---|---|---|---|---|
| 1 | ✔ | any | silent | local-only | `.auto` / Standard | ✔ Standard | steady; Apple arm verifies |
| 2 | ✔ | any | gated | local-only | `.auto` / Standard after re-land | ✘ | route opens via the Apple road; R1-M3 re-lands silent (`AppBootstrap.swift:548-557`); **the gated item is never deleted** (sweep only acts on determined Castle, `ProtectionController.swift:1541`) — custody law broken silently |
| 3 | ✔ | any | none | local-only | `.auto` → Apple road; A missing ⇒ waiting lobby | ✔ `waitingForICloudKeychain` | ✔; passphrase/words doors act |
| 4 | ✘ | ✔ | silent | local-only | `.auto` (+ route lands A if readable) / Standard | ✘ (doc: "Standard-waiting") | **ambiguous**: a never-landed Standard library and a Castle library whose S got a silent item from another copy (VX-209, VX-228) read the same; the landing then makes it Standard for good |
| 5 | ✘ | ✔ | gated | local-only | `.biometric` / Castle | ✔ Castle | steady |
| 6 | ✘ | ✔ | none | local-only | `.passphrase` if dial on, else **`.biometric` with no gated item** | ✔ Castle | dial ≠ custody when the Castle road ran without biometry (§8 S-8): lobby offers passphrase only; sync shape reads `.biometric` |
| 7 | ✘ | ✘ | silent | local-only | `.auto` / Standard | tier `exposed` (no W) / `covered` (W) | the exposed nudge; Apple arm keeps trying |
| 8 | ✘ | ✘ | gated | local-only | `.auto` → silent missing → waiting (W only) or doorless failure | ✘ | unreachable by app roads (Castle needs P); unhandled |
| 9 | ✘ | ✘ | none | local-only | `.auto` → `keyUnavailable` | `failed` (doorless) | a lost key with no wraps; nothing to offer |
| 10 | no KF | — | silent | local-only | `.auto` | pre-1a legacy | legacy items migrate on load; `establish` writes a KF (`StoreKey.swift:278-287`) |
| 11 | unreadable | — | any | any | read as "no key file" for posture (`StoreLaunchGate.swift:384-389`) | `factsUnknown` tier | doors refuse to write over it; legacy items may still open |
| 12 | ✔ | any | silent | vault Standard, read | Standard (determined) | ✔ | steady |
| 13 | ✘ | any | silent | vault Standard, read | follow into Standard row 2d | ✔ `movedToStandard` | silent heal at ready (**[F]**+**[K]**) |
| 14 | any | any | gated/none | vault Standard, read | follow into Standard (row 2d); BUT if this device holds NO material and the library's own rule reads Castle ⇒ enroll consent (d) | ✔ / ✔ `castleBornJoinsStandard` | VX-110 guard keeps the Apple arm off until Join |
| 15 | ✘ | ✔ | silent | vault Castle, read | `castleStillOpensOldWay` follow owed | ✔ | `Later` allowed — Apple-openable until followed |
| 16 | ✔ | any | gated | vault Castle, read | `castleKeyFileAppleOpenable` follow owed | ✔ | 13x R1-BLOCKER fix; only when material is in hand |
| 17 | ✘ | ✔ | gated/none | vault Castle, read | Castle (determined) | ✔ | steady |
| 18 | any | any | any (material in hand) | vault corpus id ≠ custody's | `movedToCastle` / `keysReplaced` | ✔ | the follow (rotation road) |
| 19 | any | any | any | rows owned by another account | `differentOwner` → Connect | ✔ | adopt road (no marker) |
| 20 | any | any | silent / gated / none | enrolled (material or signed in), vault UNREAD | `indeterminate(shape)`: silent→Standard, gated/none→Castle | ✔ `indeterminate` | writes nothing; signed-out-with-material and post-account-deletion libraries live here indefinitely (H5) |
| 21 | any | any | any | signed in, vault exists, NO material here | `EnrollFacts` (four directions) / silent Standard enroll | ✔ | — |
| 22 | ✘ | ✔ | gated/none | identity-only bound record (after This Mac Only / `clear`), signed out | route: enrolled ⇒ indeterminate (Castle shape); ready: not enrolled ⇒ determined Castle | ✘ | consistent by luck; after a later sign-in the vault (Standard) wins at ready while the route keeps the Castle lobby — the face says Standard (H7) (I) |
| 23 | any | any | any | account deleted / signed in to an account with no vault, custody kept | indeterminate (custody ⇒ enrolled; no vault word) | ✘ | lasts until a new vault exists (`setUp`) (I) |
| 24 | ✔ (old file) + ✘ (new file) both present | — | gated | vault Castle | `locate` by mtime picks the new one | ✘ | the ceremony road leaves the old Apple-carrying file in place (B6c); follows retire it |
| 25 | marker pending (any step) | — | — | — | `switchPending` flag disables the route's corner-45 landing; reconcile's Apple arm skipped | ✔ marker | `.rekeyLibrary`-before-key-file = no exit (VX-235) |

## 7. Mobile deltas

The phone composes the SAME Shared brains (`StoreLaunchGate`, `ProtectionController`, `PostureSwitchRunner`, the models, `wireOneSecretHooks`) — `Mob/VariorumMobileApp.swift:65-175`. Differences only:

| # | delta | evidence | consequence |
|---|---|---|---|
| M1 | no backups: `backupEnabled: false` ⇒ `takeSnapshot` answers `.notKept` ⇒ no fresh pair, no pre-switch offer; no lock-time keyless copy (never wired) | `VariorumMobileApp.swift:67-73`; `PostureSwitch.swift:1946`; only the Mac sets `lockTimeCopy` (`Mac/VariorumApp.swift:264-272`) | the phone's old library keys stay only in the store's own folder (no Apple-openable snapshots exist to offer) (V) |
| M2 | no adoption roads (Open Library / Restore / plaintext adopt) and no restore hold | `LibraryOpenModel` / `RestoreHoldModel` are composed only by the Mac (no references under `Mob/`); `MobileLibraryMissingView.swift:7-11` | `landCustody` and VX-209 cannot occur on the phone; the phone's "library missing" face offers Start a New Library only (V) |
| M3 | relock: NO Mac monitors (sleep / screen lock / 30 s idle poll are `#if os(macOS)`); instead `MobileRelockCoordinator` on scene phase — leaving the screen locks under any demanded gate; the idle dial is read on return | `ProtectionController.swift:1966-2035`; `AppBootstrap.swift:191-195`; `Mob/Features/Protection/MobileRelock.swift:45-160` | **⚠ `bootstrap.currentEffectiveGate` runs at EVERY scene change** (`VariorumMobileApp.swift:300-310`) — the route's landing arm can write an A copy on any background/foreground (V) |
| M4 | lobby auto-ask: a VIEW-local `@State autoAsked` asks Face ID on each appearance, not the lobby's once-per-lock `autoAskIfDue` (VX-140) | `MobileStoreLockView.swift:32,104-108` vs `Mac/StoreLockView.swift:87,94` | a remounted face can ask again (V) |
| M5 | biometry = Face ID; the sentences interpolate device nouns | `StoreProtection.swift:546-560` | corner 48: `NSFaceIDUsageDescription` must ride the plist (I, design §14) |
| M6 | one keychain for Debug and Release builds ⇒ every account carries σ; the scope-less legacy legs run under the REAL σ only | `ProtectionMigration.swift:296-338`; `AuthSession.swift:150-166`; `KeychainCustody.swift:122-126` (DP flag a no-op on iOS) | dev and real never cross (V) |
| M7 | store directory protection class `.completeUntilFirstUserAuthentication` set before the first open | `AppBootstrap.swift:997-1021` | OS-level class is independent of posture (V) |
| M8 | no re-link Apple account door; no plaintext export door | `AppleRelinkModel.swift:3-7`; VX-191 audit B3a | (V for relink; I for export) |
| M9 | app-switcher snapshot redaction of `privacySensitive` spans | `VariorumMobileApp.swift:58-64` | (V) |
| M10 | A is shared with the Mac on the same Apple ID (same σ account in the shared access group) — the phone's own L gets its own key file copy under the same A | `AppleKeyCustody.swift:124-135` | a Standard phone and Mac open each other's Standard-era copies by the same A (I) |
| M11 | the Protection sheet's door gating is the same posture-based logic as the Mac pane (VX-108 applies) | `Mob/Features/Protection/MobileProtectionSheet.swift:57-66,261-283,347-371` | (V) |

## 8. Surprises

### 8a. The counts

| question | count | the sites (V) |
|---|---|---|
| places that call `Posture.derive` | **6** (7 entry paths) | `StoreLaunchGate.swift:371` (via `RoutePostureFacts`, built at `:421` and `EncryptionKeychain.swift:357`); `ProtectionController.swift:1058,1075,1535`; `ProtectionMigration.swift:220`; `LibraryOpenModel.swift:327` |
| places that read the vault's A-copy bit directly AS the posture (no derive) | **12** | `PostureSwitch.swift:459,486,962,1410,1597`; `ProtectionController.swift:646,662,680,707,786,810,2135` |
| places that compute the gate (`StoreAtOpenMode.effective`) | **5** | `StoreLaunchGate.swift:426`; `ProtectionController.swift:291`; `EncryptionKeychain.swift:363`; `PostureSwitch.swift:1337`; `ProtectionMigration.swift:230` |
| definitions of "enrolled" | **5** | H5 |
| functions that write the raw-L custody items (silent / gated) | **9** | `AppDatabase.openStore` mint (`AppDatabase+Dependency.swift:167`); `StoreKeyKeychain.load` legacy migration (`StoreKey.swift:283-287,316-318`); `ProtectionController.transitionCustody` (`:1361-1420`, the only one with write-verify-delete, reached via `moveCustody` from `setAlwaysAsk`, migration leg 4, the runner's custody step, `followIntoStandard`, `leaveCastle`); `relandSilentItem` (`:1336`); `sweepLingeringSilentItem` (`:1551`); `LibraryMissingLobby.startNewLibrary` (`AppBootstrap.swift:1107`); `LibraryOpenModel.landCustody` (`:535-542`); the plaintext adoption (`LibraryOpenModel.swift:393`); `StoreKeyGuardKeychain.unlockGated` legacy migration (`StoreKeyGuard.swift:396-407`) |
| functions that write the sync custody items | **5** | `DeviceKeyStore.save` / `.clear` / `.deviceID` (`EncryptionKeychain.swift:402-449`); `SyncCustodyTransition.move` (`:251-294`); `SyncCustodyMigration` + migration identity carry (`:814-848`; `ProtectionMigration.swift:188`) |
| functions that write A | 1 leaf (`AppleKeyKeychain.readOrMint`) from **4** callers | `ProtectionController.swift:1726`; `PostureSwitch.swift:1099,1450`; `EncryptionSession.swift:305` |
| functions that write / move / delete the LIVE key file | **16** | `StoreIdentity.establish` (`StoreIdentity.swift:49-75`); `ProtectionController.ensuredEnvelope` set-aside (`:1129-1142`); `startNewLibrary` set-aside (`AppBootstrap.swift:1091`); `retireOldKeyFiles` (`PostureSwitch.swift:1019-1045`); and 12 `saveEnvelope` callers — `effectiveGate` landing (`StoreLaunchGate.swift:417`), `runEnvelopeRoad` (`:985,1035`), `setPassphrase` (`ProtectionController.swift:1165`), `generateAndLandRecoveryPhrase` (`:1205`), `landRecoveryWrap` (`:1228`), `landAppleCopyOffMain` (`:1744`), `reconcilePassphraseWrap` (`:1778`), `landVaultMaterial` (`:1820`), `followIntoStandard` (`PostureSwitch.swift:1106`), `writeNewKeyFile` (`:1310`), `leaveCastle` (`:1469`), migration leg 5 (`ProtectionMigration.swift:266`). (+ `LibraryAdoption` and `StoreBackup` copies — the other agent's map.) |
| functions that write the vault | **9** (8 in-app) | create: `VaultEnrollment.setUp(passphrase:recoveryWords:appleHeldCopy:kdf:)` (`VaultEnrollment.swift:175-208`; the passphrase-only `setUp` `:134-161` is the CLI's, `VaultBootstrap.swift:116`); update: `landRecoveryWrap` (`:265-287`), `changePassphrase` (`:302-341`), `rewrapPassphrase` (`:352-366`), `CorpusRotation.begin` / `complete` (`CorpusRotation.swift:449-482,652-669`), `PostureSwitchRunner.leaveCastle` (`PostureSwitch.swift:1454-1463`), `EncryptionSession.relandAppleHeldCopy` (`EncryptionSession.swift:458-472`) |
| crash-resume markers | **1** (`RotationMarker`, + the `switchPending` / `thisDeviceOnlySwitch` defaults beside it) — covering only the rotation/re-key roads | §4.7 |

### 8b. Findings (fragile · duplicated · contradictory · dead)

| # | finding | evidence | V/I |
|---|---|---|---|
| S-1 | **The route's gate is a read that writes**, and it is read far beyond the route: `lock()`, the R1-M3 re-land check, the §11 migration, `landCustody`, and the phone's relock on every scene change (F-U5-6) | `StoreLaunchGate.swift:405-427`; `AppBootstrap.swift:548,638,668-674,913`; `LibraryOpenModel.swift:533`; `VariorumMobileApp.swift:307` | V |
| S-2 | **A silent-item read can write too**: `StoreKeyCustody.load(storeURL:)` migrates legacy items and may `establish` a key file; every `rawKeyCustody` / `loadAuto` inherits it | `StoreKey.swift:273-319` | V |
| S-3 | The engine's per-round key load re-derives the LIBRARY posture (reading the silent L item and the key file) just to choose which item holds the sync record | `EncryptionKeychain.swift:340-366`; `:865-875` | V |
| S-4 | The controller infers custody from whether a resident key was handed over (F-U5-5) — after an Apple-road, waiting-lobby, recovery-lobby, adoption or re-key open it reads "gated or none" under silent custody; it and the route answer differently within one ready | `ProtectionController.swift:1093-1096`; `AppBootstrap.swift:530,548` | V |
| S-5 | `vaultReading` is never cleared — the account's posture outlives sign-out, account deletion and library adoption inside one process | `ProtectionController.swift:1461-1465` (only writer `:1463`) | V |
| S-6 | **VX-235 confirmed by code**: the `.rekeyLibrary` marker is written BEFORE the new key file (L′ exists only in memory), and the resume arm demands that file — a crash in between leaves a marker no resume can clear (rounds refuse forever; the flag disables corner 45's landing) | `PostureSwitch.swift:1215-1223,1717-1723,1796-1799`; `SyncEngine.swift:76-79` | V |
| S-7 | `rawKeyCustody`'s doc (and `RoutePostureFacts`') says the gated item is probed; the code never probes it (harmless — the value is binary) | `StoreLaunchGate.swift:358-361,429-436` | V |
| S-8 | **No-biometry Castle**: the ceremony lands custody "nowhere" (`.passphrase`) but never sets `alwaysAsk`; the derived gate then reads `.biometric`, the sync shape reads `.biometric`, and the pane's Always-ask toggle shows OFF. Only the §11 migration sets the dial in this case | `PostureSwitch.swift:1330-1333`; `ProtectionMigration.swift:240-244`; `StoreProtection.swift:189-194`; `EncryptionKeychain.swift:363-365` | V (code) / I (impact) |
| S-9 | A Standard library can keep a lingering GATED L item (a Leave-Castle crash after the key-file write; any re-land beside an old gated item); nothing deletes a gated item under `.auto` except a custody move, and the sweep acts only on determined Castle | `ProtectionController.swift:1541`; `AppBootstrap.swift:548-557` | V (no deleter) / I (reachability) |
| S-10 | After a fingerprint change the gated L item is never re-saved on a passphrase unlock (`saveGated` callers: `transitionCustody`, `landCustody` only); the lobby keeps offering Touch ID because it probes presence | `StoreKeyGuard.swift:269-287`; `AppBootstrap.swift:387` | V (path) / I (platform) |
| S-11 | `landCustody` drops every write result, skips `CustodyHandover`'s verify, and takes its shape from the writing `effectiveGate` BEFORE its own writes — the VX-209 vector | `LibraryOpenModel.swift:509-545` | V |
| S-12 | Nudge/reminder stamps are σ-scoped, not per library: a new or adopted library inherits the previous one's dismissals and cadence | `StoreProtection.swift:405-412`; `ProtectionController.swift:2039-2044` | V |
| S-13 | `variorum.backup.markdownInsurance.enabled` has no σ: entering Castle in the dev store turns the REAL store's scheduled plaintext export off too (and the dial is per-machine, not per library) | `MarkdownInsurance.swift:65-74`; `PostureSwitch.swift:1363-1370` | V |
| S-14 | A local-only library's passphrase can be changed from the set sheet with no current-passphrase authorization; a local-only library has no regenerate-words door at all | `ProtectionPane.swift:481-493`; `PassphraseSetModel.swift:207-257`; `KeyDoorModel.swift:316-319`; `EncryptionViews.swift:596-607` | V |
| S-15 | `PostureCopy.currentStateLine(.standard)` says "Your Apple account holds a key" for every Standard reading — including Standard-waiting and exposed libraries that hold no A copy | `PostureCopy.swift:53-58` | V |
| S-16 | The ceremony road keeps the old Standard-era key file (with `apple`) beside the live Castle library; "current" is mtime | `PostureSwitch.swift:1248,1019-1045`; `StoreKeyEnvelope.swift:482-497` | V (VX-191 B6c) |
| S-17 | `readVaultPosture` collapses offline, signed-out, "no vault" and any error into nil (`try?`), and nil keeps the previous reading | `ProtectionController.swift:2131-2147,1461-1465` | V |
| S-18 | Sign-in triggers no reconcile; sign-out clears only the tokens — the controller's `enrolled`, `vaultReading` and follow state stay until the next ready | `AppServices.swift:393-409`; §3.6 callers | V |
| S-19 | Account deletion keeps custody (dead M) and the key file's `master`/`vaultKDF`/`vaultCorpusKeyID`: the library is then "enrolled" with no vault word — indeterminate until a new vault exists; the Apple arm and §11 legs 3–6 cannot run meanwhile | `AppServices.swift:537-572`; `StoreProtection.swift:93-95`; `ProtectionController.swift:1604-1607` | V (mechanism) / I (face) |
| S-20 | The phone's lobby auto-asks per VIEW appearance (`@State`), not per lock (VX-140's lobby-scoped flag) | `MobileStoreLockView.swift:32,104-108` | V |
| S-21 | `routeAndOpen` calls `openWithAppleKey` twice on the waiting branch (a second Keychain + unwrap) | `AppBootstrap.swift:355-361` | V |
| S-22 | Not every posture-driven write waits for a DETERMINED reading (decision 35's rule): `leaveCastle` acts on the controller's ACTING posture (an indeterminate shape or a stale cached vault word passes `== .castle`); the route's landing arm and `landCustody` act on the route's reading (indeterminacy only exempts enrolled libraries from the landing). `followIntoStandard` is safe on this count — its callers hold a fresh vault word (`reconcileFollow` gets `freshReading`, `joinStandard` fetches) | `PostureSwitch.swift:1441-1447`; `StoreLaunchGate.swift:411`; `LibraryOpenModel.swift:533`; `ProtectionController.swift:1473`; `EncryptionSession.swift:407-424` | V |
| S-23 | Doc/code drift: `08_phase14b_lockstep.sql`'s "`updated_at` is insert-time-only" — the RPC stamps it | `08_phase14b_lockstep.sql:88-93` vs `11_pre13x_postures.sql:955`, `12_phase13y_tenant_seq.sql:1569` | V |
| S-24 | Dead / not custody: `EncryptionSession.deviceIdentity()`, `RekeyRecencyProbe`/`RekeyGuardRule` and `AccountLifecycleClient.truncateAccountData` have no production caller (the 14c re-key road retired, `AppServices.swift:252-259`); `VaultBootstrap` is a CLI-only in-memory device; `RecoveryActs.swift` is the Trash's put-back layer, not a key file | `EncryptionSession.swift:605-609`; `Core/Sync/RekeyRecencyProbe.swift:62-166`; `Core/Auth/AccountLifecycle.swift:161-181`; `VaultBootstrap.swift:5-20`; `RecoveryActs.swift:1-35` | V |
| S-25 | Five no-marker multi-write acts rely on "the next reconcile heals": Leave Castle (vault → key file → custody), follow into Standard, setUp/enroll (vault → custody → key file), Connect (restamp → resync → custody → key file), change passphrase (vault → custody → key file) | §4.5, §4.8, §4.11, §4.13 | V (order) / I (heal paths) |
| S-26 | `StoreKeyEnvelope.belongs(to:)` answers TRUE for a fingerprint-less file, so `establish` adopts a wraps-less stub's `storeID` for whatever key it is handed | `StoreKeyEnvelope.swift:157-160`; `StoreIdentity.swift:52-55` | V |
| S-27 | The Castle-born-joins-Standard consent "Cancel" is a per-process flag; the Apple arm's VX-110 guard is what actually holds the line across launches | `EncryptionSession.swift:133,432-434`; `ProtectionController.swift:1614-1628` | V |

### 8c. The ten that matter most for the redesign
1. **Posture is never stored** — it is rebuilt on every read from four sources (the vault's A-copy bit · the key file's wraps · where THIS Mac keeps L for the store id · a legacy dial), at 6 `derive` sites + 12 direct vault-bit reads + 5 gate derivations (§8a). Nothing records "this library is Castle" or "this store id was ever Castle" (§1f footnote) — which is why VX-209/VX-228 cannot be expressed in today's state.
2. **Corner 45 keys posture on the silent item for the store id, and the store id is shared by every copy** (backups, pairs, Previous Libraries) — so one copy's custody decides another's posture; `landCustody` writes that item using the route's reading taken before its own writes (§1a, H2, §3.8, S-11).
3. **Reads that write**: the route's gate lands an A copy (and is read by `lock()`, the R1-M3 check, the migration, `landCustody`, the phone's every scene change); a silent-item read can migrate items and write a key file; `reconcile()` deletes items, lands custody, runs follow-into-Standard, mints A, sets key files aside and writes the vault (§3.3, §3.6, S-1–S-2).
4. **The controller infers raw-L custody from "was a resident key handed over"** (F-U5-5): every Apple-road / waiting / recovery / adoption / re-key open reads "gated or none" under silent custody, so controller and route disagree within one ready (H3, H26, S-4).
5. **"Enrolled" has five definitions** and decides who is indeterminate; signed-out-with-material and post-account-deletion libraries are indeterminate indefinitely — no Apple arm, no §11 legs 3–6 (H5, §4.10, §4.12).
6. **Stale projections drive doors**: `vaultReading` is never cleared; sign-in runs no reconcile; Use Castle/Standard, Castle switches, relink, key doors and the one-secret tie read cached state, not the fetched vault (VX-108) (H6–H8, §3.9, S-5, S-17, S-18).
7. **One crash marker, partial coverage — and VX-235 is real**: `.rekeyLibrary` is written before the new key file (L′ only in memory) and its resume demands that file ⇒ an unclearable marker, sync refused forever, `switchPending` stuck; six multi-write acts have no marker at all (§4.7, S-6, S-25).
8. **Writes are scattered**: 9 functions write raw-L custody (only `transitionCustody` verifies), 5 write sync custody, 16 write/move/delete the live key file, 9 write the vault; "current key file" = newest mtime and the ceremony leaves the old Apple-carrying file in place (§8a, H10, S-16).
9. **Gate ≠ custody in two real paths**: Castle without biometry lands custody "nowhere" but never sets `alwaysAsk` (gate and sync shape read `.biometric`); after a fingerprint change nothing re-saves the gated L item (S-8, S-10, §4.16).
10. **The sync record's location is derived, not recorded** — every engine round re-derives the LIBRARY posture (silent-item read + key file + dials) to pick the item; unnamed shapes the code handles only implicitly: a Standard library with a lingering gated item, an identity-only "enrolled" record, custody with no vault (H9, §6b rows 2/22/23, S-3, S-9).
