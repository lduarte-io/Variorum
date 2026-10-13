# Backup · Restore · Open Library — a code map

Read-only map of worktree `~/dev/variorum-vx-266` at `2dd0c70b` (branch `vx-266-castle-backups-before-launch`). Built from the code alone; `notes/plans/vx-266/` was not read. Every claim cites `path:line`.

Abbreviations: `Core/` = `Sources/VariorumCore/Persistence/` · `Sync/` = `Sources/VariorumCore/Sync/` · `Sh/` = `App/Variorum/Shared/` · `Mac/` = `App/Variorum/Variorum/`.
Tags in §7: **traced** means I followed the code path end to end. **suspected** means the mechanism is visible but I did not trace every leg or the timing.

---

## 0. The identities everything hangs on

- **The slot.** `Application Support/<Variorum|Variorum-dev>/variorum.sqlite` (`Core/AppDatabase+Dependency.swift:78-90`). Everything "beside the store" is in that folder.
- **The store id** is the key file's `storeID` (`Core/StoreKeyEnvelope.swift:61-63`). It is read without the key from the *current* key file (`Core/StoreIdentity.swift:33-41`). Every key file of one library carries the same id, which stays stable across re-keys (`Core/StoreKeyEnvelope.swift:47-49`).
- **The current key file** is found by `StoreKeyEnvelope.locate` (`Core/StoreKeyEnvelope.swift:482-497`). The rule:
  - one fingerprint-named file → that file;
  - several → the one with the newest mtime;
  - none → the legacy `variorum-keys.json`.
  `keyFileURLs` lists every fingerprint-named file plus the legacy one (`:464-474`). It does not list `*.stale-*.json` names, because `fingerprint(fromFilename:)` requires exactly 16 hex characters (`:433-438`).
- **Keychain items per (scope, store id).** Every act re-resolves the store id from the key file beside the slot (`Sh/StoreKeyGuard.swift:81-94`; `Sh/EncryptionKeychain.swift:329-339`).
  - Silent library-key item: service `io.lduarte.Variorum.store-key`, account `<scope>-<id>-bound`, data-protection keychain, `WhenUnlockedThisDeviceOnly` (`Core/StoreKey.swift:115, 265-267, 376-390`).
  - Gated (Touch ID) item: same service, account `<scope>-<id>-biometric`, `.biometryCurrentSet` (`Sh/StoreKeyGuard.swift:229-232, 289-298`).
  - Sync custody (M, C, device identity): service `io.lduarte.Variorum.e2ee-keys`, accounts `<scope>-<id>-sync` and `<scope>-<id>-sync-biometric` (`Sh/EncryptionKeychain.swift:94-100, 578`).
  - Legacy shapes (`<scope>-bound`, `<scope>`, `<scope>-biometric`) migrate onto the per-id items on read (`Core/StoreKey.swift:308-360`; `Sh/StoreKeyGuard.swift:339-353`).
- **The iCloud key A is per scope, not per store.** Account `<scope>-apple-key`, service `io.lduarte.Variorum.apple-key`, shared access group, synchronizable (`Sh/AppleKeyCustody.swift:124-137`). Any key file anywhere that holds `apple(L)` opens every copy under key L for whoever has A.
- **UserDefaults keyed per (scope, store id)** use the prefix `variorum.protection.<scope>.<id>.` (`Sh/StoreProtection.swift:261-264`):
  - `alwaysAsk`, `relockIdleMinutes` (`:339-342`);
  - legacy `mode` with its read-through (`:304-323`);
  - `switchPending` (`:372-383`);
  - `thisDeviceOnlySwitch` (`:390-401`);
  - `migrated2a` and `migration2aConfirmPending` (`Sh/ProtectionMigration.swift:125-126, 353-354`).

  With no store id, the dials fall back to the scope-level legacy keys (`Sh/StoreProtection.swift:283-298`).
- **Global UserDefaults, not per store** (Mac): `variorum.backup.secondDestination` (bookmark, `Sh/BackupDestination.swift:34`), `variorum.backup.log` (`Sh/BackupLog.swift:103`), `variorum.backup.pendingLockTimeChecks` (`Sh/StoreBackup.swift:621`), `variorum.backup.markdownInsurance.enabled` (`Sh/MarkdownInsurance.swift:65`), and `variorum.backup.iCloudDriveOffered.<variant>` (`Mac/Features/Settings/ICloudDriveOffer.swift:93-95`).

---

## 1. Every on-disk artifact

### 1a. Beside the store (the slot's folder)

**`variorum.sqlite` (the live library)**
- Created by `openStore` → `onDisk`, which mints a key on an absent file (`Core/AppDatabase+Dependency.swift:103-140, 155-175`; `Core/AppDatabase.swift:87-91`).
- Replaced in place by the plaintext→encrypted migration's `rename` (`Core/StoreEncryptionMigration.swift:73-193`, swap at `:178`) and by the re-key's `rename` (`:220-329`, swap at `:315`).
- Moved whole to `Previous Libraries/<stamp>/` by an adoption (`Core/LibraryAdoption.swift:271-286`).
- Landed by copy from the picked source (`:292-295`).

**`variorum.sqlite-wal` / `-shm`**
- SQLite's own sidecars (WAL pool).
- Lock truncates the WAL (`PRAGMA wal_checkpoint(TRUNCATE)`) before the close (`Core/StoreBinding.swift:104-106`).
- Swept after a migration or re-key swap (`Core/StoreEncryptionMigration.swift:189-191, 325-327`).
- Moved aside with the store (`Core/LibraryAdoption.swift:226-229`).
- On landing, the source `-wal` is copied when non-empty; the source `-shm` never is (`:296-301`).

**`variorum.sqlite.encrypting` (+ its sidecars)**
- The temp of the plaintext migration (`Core/StoreEncryptionMigration.swift:78`).
- Swept on every open of a non-plaintext store (`:79-86`).

**`variorum.sqlite.rekeying` (+ its sidecars)**
- The re-key temp, under the new key L′ (`:226`).
- Swept only by the next `rekey` call (`:234-237, 245`).
- It is not in the adoption's departing set (`Core/LibraryAdoption.swift:222-231`).

**`variorum-keys-<fp16>.json` (format 2) and legacy `variorum-keys.json`**

Names: `Core/StoreKeyEnvelope.swift:418, 427-429`. All writes are atomic (`:523-528`).

Created by `StoreIdentity.establish`, which writes id + fingerprint and no wraps (`Core/StoreIdentity.swift:49-75`). It is reached through:
- every silent-item save, `StoreKeyKeychain.save(scope:storeURL:)` (`Core/StoreKey.swift:297-304`; the guard's `saveAuto` at `Sh/StoreKeyGuard.swift:88-89`);
- the legacy re-scope on load (`Core/StoreKey.swift:283-287`);
- Start a New Library (`Sh/AppBootstrap.swift:1097`);
- the plaintext adoption (`Sh/LibraryOpenModel.swift:388`).

Rewritten through `gate.saveEnvelope`, which writes the envelope's own fingerprint name (`Sh/StoreLaunchGate.swift:115`). Callers:
- `ProtectionController.setPassphrase` (`Sh/ProtectionController.swift:1163-1165`);
- `generateAndLandRecoveryPhrase` (`:1203-1205`);
- `landRecoveryWrap` (`:1225-1228`);
- `reconcilePassphraseWrap` (`:1774-1778`);
- `landVaultMaterial` (`:1812-1820`);
- the Apple arm of the reconcile (`:1743-1744`);
- migration leg 5 (`Sh/ProtectionMigration.swift:257-266`);
- the runner's `writeNewKeyFile` (`Sh/PostureSwitch.swift:1310`), `followIntoStandard` (`:1105-1106`) and `leaveCastle` (`:1468-1469`);
- **the route's `effectiveGate` Apple landing** (`Sh/StoreLaunchGate.swift:411-420`);
- the lobby's vault road (`:985, 1035`).

Landed from the source by an adoption: the source bytes are copied unchanged under the canonical name (`Core/LibraryAdoption.swift:127-135, 302-304`).

Set aside by rename to `<name>.stale-<unix>.json` in two places: `StoreIdentity.setAside` (`Core/StoreIdentity.swift:80-85`, called at `:56`) and `gate.setAsideEnvelope` (`Sh/StoreLaunchGate.swift:116-121`, called at `Sh/ProtectionController.swift:1135` and `Sh/AppBootstrap.swift:1091`).

Deleted only by `retireOldKeyFiles` (`Sh/PostureSwitch.swift:1019-1045`), and only on a **follow** into Castle (`:1248, 1773-1775`). It removes the old-fingerprint file and a wrap-less legacy stub.

Moved aside (all fingerprint files plus the legacy file) by an adoption (`Core/LibraryAdoption.swift:230`).

**`*.stale-<unix>.json`**
- Written by the two set-asides above.
- Nothing ever reads, lists, moves or deletes them. A grep for `stale-` finds only the two writers.
- Adoption leaves them beside the new library, because they do not match `keyFileURLs`.

**`variorum-restore-hold.json`**
- Written atomically by `LibraryRestoreHold.set` (`Core/LibraryRestoreHold.swift:42-57`), called only inside `LibraryAdoption.execute` step 3½ (`Core/LibraryAdoption.swift:254-269`).
- Overwritten by every adoption.
- Removed only by `clear` (`Core/LibraryRestoreHold.swift:86-90`) from `RestoreHoldModel.resume` (`Sh/RestoreHoldModel.swift:81-90`).
- Never moved or copied: it is not in the departing set (`Core/LibraryAdoption.swift:100-106`).

**`Previous Libraries/<yyyy-MM-dd-HHmmss UTC>/`**
- Adoption step 4 (`Core/LibraryAdoption.swift:145-146, 155-163, 271-286`) moves the store, its sidecars and every key file here.
- Never pruned or rewritten.
- Deleted whole only by the Castle offer, and only when it qualifies as Apple-openable (`Core/LibraryAsideCopies.swift:88-93, 122-155`).

**`Backups/` (the default backup folder)** — see 1b.

### 1b. `Backups/` beside the store (`Sh/AppServices.swift:221-237`)

**`variorum-backup-<stamp>-<fp8>.sqlite` (snapshot)**
- Written by `performPrimaryLeg` (`Sh/StoreBackup.swift:545-573`; name at `:559-562`; `database.backup` at `:563`).
- Sealed by `integrityCheck` (`:477-516`), which sets the copy's `journal_mode` to DELETE and removes its `-wal`/`-shm`.
- Pruned to the newest 14 (`:609-615`) and by the Castle offer.
- The legacy stamp-only name `variorum-backup-<stamp>.sqlite` is still recognised (`:757-767`).

**`variorum-backup-<stamp>-<fp8>.keys.json` (the snapshot's pair)**
- Written by `writeSnapshotKeyFile` (`:579-594`) from the bytes of `locate()` beside the live store, and **only when absent**.
- Never rewritten.
- Removed with its snapshot (`:598-604`).

**`variorum-keys-<fp16>.json` (folder-level key file)**
- Written by `copyKeyEnvelope` (`:317-325`) on every run (`:281-283`) and at lock time (`:663`), from `locate()`, **only when absent**.
- **Never rewritten and never deleted by anything.**

**`RESTORE.md`**
- Written by `writeRunbook` (`:330-339`, called at `:278`), only when its bytes change.
- Never deleted.

**Lock-time byte copies**
- Named exactly like snapshots, `-<fp8 of the located key file>` (`:633-669`).
- They carry a pair and the folder copy (`:662-663`) and prune to 14 (`:664`).
- Their names go into the pending-check list (`:665-667`).

**`safety-copies/variorum-adopt-safety-<stamp>/`**
- Adoption step 3: the store's bytes and every key file, copied (`Core/LibraryAdoption.swift:143-144, 157, 165-171, 233-248`).
- Never pruned.
- Deleted only by the Castle offer, and only when Apple-openable.

**`safety-copies/variorum-backup-a1-*`**
- The operator's A1 rail (a CLAUDE.md convention). **No app code writes them.**
- Explicitly never matched by the aside lister (`Core/LibraryAsideCopies.swift:20-21`).

### 1c. The second destination (`<picked>` = a user-chosen folder; "iCloud Drive" is only a pick)

- **The bookmark.** `BackupDestination.remember` stores an app-scoped bookmark (`Sh/BackupDestination.swift:73-93`). Two pick roads exist:
  - Settings ▸ Data Safety (`Mac/Features/Settings/DataSafetyModel.swift:258-287`), which refuses the live library's folder (`:265-273`);
  - the iCloud Drive offer, whose picker opens at `~/Library/Mobile Documents/com~apple~CloudDocs` (`Mac/Features/Settings/ICloudDriveOffer.swift:100-105, 166-183`). It has **no live-folder refusal**.

  Forgetting removes the bookmark only (`DataSafetyModel.swift:290-299`).
- **`<picked>/Variorum/Backups/<snapshot>.sqlite`.** A byte copy of this run's primary snapshot (`Sh/StoreBackup.swift:353-431`; copy at `:407-411`, which first deletes a same-named file). Pruned 14 dailies + 4 weeklies (`:423-424, 435-444`; `Sh/BackupRetention.swift:41, 87-119`), and by the Castle offer.
- **`<picked>/Variorum/Backups/<snapshot>.keys.json`.** Copied from the primary pair only when the far one is absent, best-effort `try?` (`Sh/StoreBackup.swift:412-419`).
- **`<picked>/Variorum/variorum-keys-<fp16>.json`.** `copyKeyEnvelope` into the **parent** `Variorum/` folder, not `Backups/` (`:380-383`). Never deleted.
- **`<picked>/Variorum/RESTORE.md`** (`:374-376`).
- **`<picked>/Variorum/md-exports/<stamp>/*.md`.** A weekly opt-in run (`Sh/MarkdownInsurance.swift:77-80, 96-166`), keeping the newest 4 folders (`:38-43, 176-182`). It is off by default (`:68-70`) and turned off on entering Castle (`Sh/PostureSwitch.swift:1363-1370`). Existing folders are never deleted by the app.

### 1d. Elsewhere (user-chosen, untracked)

- **Hand-off folder.** `Variorum Library — <yyyy-MM-dd>[ (n)]/variorum.sqlite` + `variorum-keys-<fp16>.json` (`Sh/LibraryHandOff.swift:60-82, 88-143`).
  - The snapshot comes from `database.backup` and is sealed (`:117-129`).
  - The key file is a byte copy of `locate()` (`:95-104, 130-134`), apple and master wraps included.
  - A failure removes the whole folder (`:139-142`).
- **Plaintext `.sqlite` export.** Default name `Variorum-unencrypted.sqlite` (`Mac/Features/Settings/DataSafetyPane.swift:436`).
  - Written by `StorePlaintextExport.export`: ATTACH `KEY ''`, then `sqlcipher_export`, then drop the 4 local-only tables, then empty the MCP grant tables, then sweep the export's sidecars (`Core/StorePlaintextExport.swift:48-82`).
  - Refused only inside the container `Backups/` and `<picked>/Variorum` (`DataSafetyPane.swift:416-423`; `Sh/PlaintextExportModel.swift:83-92`).
  - Never overwrites an existing file (`StorePlaintextExport.swift:49-52`).
- **Manual Markdown exports.** `Mac/Features/Export/ExportModel.swift:131-139`; `Sh/ExportWriter.swift:32-35`.
- **Staged-read temp.** `$TMPDIR/variorum-picked-<UUID>/picked.sqlite` (+ `-wal`) (`Core/LibraryClassifier.swift:289-318`). Removed by `defer`; a crash leaves it.

### 1e. Markers inside the library file (they travel in every snapshot and hand-off)

- **`sync_state.rekey_in_progress`** is the `RotationMarker` (`Sync/CorpusRotation.swift:138-232`; key at `:199`; write at `:208-214`). While it is set the engine refuses every round (`Sync/SyncEngine.swift:77`) and the janitor stops (`Sync/PurgeJanitor.swift:89`).
  - Written by the runner's `writeMarker` (`Sh/PostureSwitch.swift:1827-1832`) at steps `.vaultWrite`, `.reencrypt`, `.rekeyLibrary`, `.custody` and `.snapshot`.
  - Cleared at `:1249`, **before** the offer. The `.offer` step is defined but never written; a grep finds no writer.
- **`sync_state.last_server_seq`** (the cursor) and **`sync_outbox`** both travel too. The plaintext export drops them (`Core/StorePlaintextExport.swift:64-67`), and the plaintext road recreates them empty (`Core/LocalMachineryRecreation.swift:69-92`).
- **`mcp_switch.adoption_hold_ack`.** After an adoption, the MCP door clears setup-key bindings, turns its server off and records the hold stamp (`Sources/VariorumCore/Operations/Operations+MCPGrants.swift:392-411`; key at `Sources/VariorumCore/Queries/MCPGrantQueries.swift:347`). It is triggered by the hold marker (`Mac/Features/MCP/MCPDoor.swift:283-292`).

---

## 2. How a backup snapshot is made

**Clock and doors**
- `AppServices.start` starts `StoreBackup.start` (`Sh/AppServices.swift:289`). It makes one due-check at once, then hourly (`Sh/StoreBackup.swift:119-127`).
- Stopped at lock, adoption and re-key teardown (`Sh/AppServices.swift:300-306`, via `onWillLock` at `Mac/VariorumApp.swift:252-257`).
- Single-flight (`Sh/StoreBackup.swift:158-184`).
- Forced runs (`backUpNow`, `:146-148`) come from:
  - Back Up Now;
  - turning the insurance on (`DataSafetyModel.swift:150-155`);
  - the folder pick (`:282`);
  - the iCloud offer pick (`ICloudDriveOffer.swift:181`);
  - the switch's step 6 (`Sh/PostureSwitch.swift:1942-1950`).

**Due rule**
- A copy is due when the newest *trusted* app snapshot is ≥ 24 h old or missing (`Sh/StoreBackup.swift:45, 552-555, 740-749`).
- A future-stamped copy never counts as fresh (`:734-736`).

**One run** (`performRun`, `:236-302`)
1. Check pending lock-time copies with the key now in hand. The pending list is cleared first (`:250-251, 675-688`).
2. The primary leg (`:545-573`):
   - The name carries `fp8(database.storeKeyFingerprint)`: the key the open pool is under (`Core/AppDatabase.swift:150-157`).
   - `AppDatabase.backup(to:)` opens the destination with `artifactConfiguration()`, keyed with the same raw key, and runs GRDB/SQLite's online backup from the live writer (`Core/AppDatabase.swift:221-228`). So **the snapshot is ciphertext under the same key L.** It contains the whole file, local-only tables included.
   - It writes the pair from `locate()` (`Sh/StoreBackup.swift:567-570`), then `prune(keep: 14)` (`:571`).
   - The integrity seal runs with the same keyed configuration (`:261`).
3. `RESTORE.md` and the folder key file go into the container `Backups/` (`:278-283`).
4. The second leg (`:353-431`): it copies **this act's** snapshot (`.written` or `.fresh`, so a fresh lock-time copy can be the one sent; `:253-265, 396-411`). Then the pair, the integrity check and the 14+4 prune.
5. The Markdown leg (`:297-299`).

**The keyless lock-time copy** (`:633-669`)
- Wired only on the Mac (`Mac/VariorumApp.swift:262-274`). Run only by `AppBootstrap.lock()` after `binding.lock()` (`Sh/AppBootstrap.swift:942-950`).
- `lock()` refuses under Standard, so these copies exist only for **demanded (Castle) gates** (`:913-914`).
- Conditions:
  - the slot reads as ciphertext;
  - a copy is due;
  - the `-wal` is empty;
  - `locate()` gives a readable key file with a fingerprint.
- The copy is `Data(contentsOf: store)` written atomically. **The name's fp8 is the located key file's fingerprint, not a fact about the bytes** (`:648-655`).
- Then the pair, the folder key file, `prune(keep: 14)` and the pending-check entry.

**Retention**
- Container: the newest 14 app-named snapshots by stamp (`:609-615`).
- Far folder: 14 dailies + 4 weeklies (`Sh/BackupRetention.swift:87-119`).
- Pairs go with their snapshots (`Sh/StoreBackup.swift:598-604`).
- Both counts include **every** app-named snapshot in the folder (`existingBackups`, `:704-715`), whatever library, key or Mac made it.
- Folder key files, `RESTORE.md`, `Previous Libraries` and adopt safety copies are never pruned.

---

## 3. The "Restore from Backup" list

- **Built by** `DataSafetyModel.refresh` with `BackupRestoreCandidates.gather(in: backup.directory, liveKeyFingerprint: database.storeKeyFingerprint)` (`Mac/Features/Settings/DataSafetyModel.swift:104-131`).
  - **It reads the container `Backups/` only**, by design (PROVISIONAL, `Mac/Features/Settings/DataSafetyPane.swift:138-144`).
  - The far folder, `Previous Libraries` and safety copies are never listed.
- **Filter:** `.sqlite` files with the app's strict name grammar (`Core/BackupRestoreCandidates.swift:66-83, 129-142`). Sorted newest first.
- **The serving key file** comes from `LibraryClassifier.classify(at:)`. It accepts `.snapshotPair` and `.encryptedLibrary`; anything else is nil (`Core/BackupRestoreCandidates.swift:88-95`). `classifyOpaque` (`Core/LibraryClassifier.swift:154-205`) tries, in order:
  1. the pair `<snapshot>.keys.json`, if it decodes and its fingerprint agrees with the name's fp8, or the name has no fp8 (`:159-171`);
  2. for a backup name with an fp8: the first folder `variorum-keys-<fp16>.json` whose fp16 begins with that fp8. Otherwise the copy is **bare**, and the legacy file is never considered (`:177-191`);
  3. for a backup name without an fp8: `locate()`, meaning the sole or newest-mtime fingerprint file, else the legacy file (`:192-195`);
  4. for an ordinary name: `locate()` (`:200-202`).
- **"Which credential opens it"** reads the serving file's wraps keylessly (`Core/BackupRestoreCandidates.swift:98-105`). The flags are passphrase / recovery / apple / master.
- **The second look** (`:106-117`) compares the envelope's full fingerprint to the live key's, or else the name's fp8 to the live short form.
- **The words** (`Sh/LibraryOpenCopy.swift:106-117`):
  - "your current passphrase or Touch ID on this Mac" when the second look lights;
  - "the passphrase of its day";
  - "your twelve words";
  - "your Apple account";
  - "your current passphrase (online)" when a master copy exists and the second look is off.
- **With no road**, the row shows `bareCandidateLine` = "No key file serves this copy — it can't be opened. Its key file may be in another backup folder." (`:118-120`; `DataSafetyPane.swift:157-162`).
- **The Open… button** appears whenever `candidate.keyFile != nil` (`DataSafetyPane.swift:167-171`). It runs the same flow as File ▸ Open Library (`Mac/Features/Settings/SettingsSceneContent.swift:84-85`).
- **Nothing is verified:** not A's readability or id, not that the vault master is current, not that a Touch ID item exists.

---

## 4. File ▸ Open Library… and the adoption flow

### Doors
- File ▸ Open Library…, ready only (`Mac/EditorCommands.swift:431-433`).
- The Standard *waiting-for-iCloud-Keychain* face and the *library missing* face (`Mac/VariorumApp.swift:434-447`).
- Restore from Backup rows (§3).
- **No door** from the Castle lobby (`Mac/VariorumApp.swift:430-433`) or from the failure face.
- The panel takes files or folders (`Mac/LibraryOpenDoor.swift:28-40`).

### Step 1 — classify (keyless, off-main)

`LibraryClassifier.classify` (`Core/LibraryClassifier.swift:81-125`). Verdicts are routed in `Sh/LibraryOpenModel.swift:114-139`:

| What was picked | Road |
|---|---|
| encrypted library / snapshot pair / folder holding a pair | unlock |
| several stores | choose |
| plaintext export or plaintext full library | **plaintext road** → confirm |
| bare store | refused: "This library is sealed, and no key file came with it…" (`Sh/LibraryOpenCopy.swift:29-31`) |
| newer schema / not a Variorum store / unreadable | refused |

Plaintext files are read only through `withStagedRead`, our own copy (`Core/LibraryClassifier.swift:225-259, 289-318`).

### Step 2 — the unlock roads (`Sh/LibraryOpenModel.swift:171-254`)

They run over the source pair through a gate copy:
- `loadEnvelope` serves the classifier's key file;
- `saveEnvelope` is a no-op, so **nothing is ever written to the picked pair** (`:145-150`).

In order:
1. **Second look, silent.** The live silent item's key, if the pair's envelope `belongs(to:)` it by fingerprint (`:181-183`).
2. **The Apple road.** A unwraps the pair's `apple` copy; the `appleKeyID` must match (`:186-187`; `Sh/StoreLaunchGate.swift:821-833`).
3. **Second look, gated.** Only if the live gated item exists **and** the pair is not provably foreign. "Foreign" compares the pair's fingerprint with the **live** key file's, without a prompt (`Sh/LibraryOpenModel.swift:159-169, 202-211`). This costs one Touch ID ask, and the key must belong to the pair.
4. **Typed.** The passphrase or the twelve words through `StoreLobby.envelopeRoad`: the local copy first, then the vault road. The vault road needs a `master` copy in the pair, a session and the network (`:236-254`; `Sh/StoreLaunchGate.swift:885-1041`). The derived wrapping key is held in the **shared** session (`:929, 991`; `session: bootstrap.protection.syncCustodySession`, `Sh/LibraryOpenModel.swift:245`).

Then **settle** with `schemaVerdict` over a staged copy, keyed (`:263-281`; `Core/LibraryClassifier.swift:346-364`):
- current or behind → confirm;
- newer → refused;
- key rejected → "That key file doesn't open this library — it belongs to another copy." (`Sh/LibraryOpenCopy.swift:40-41`);
- unreadable → refused.

### Step 3 — the confirm (`Sh/LibraryOpenModel.swift:285-334`; rendered at `Mac/LibraryOpenDoor.swift:226-268`)

Lines, in order:
1. "Ready to open this library."
2. **The Castle line (VX-209)** "This copy isn't in Castle, so once it's open your library opens the old way — press Resume Sync, then choose Use Castle again…" (`Sh/LibraryOpenCopy.swift:74-76`). It shows when both hold:
   - the slot holds a **ready** library whose `protection.posture == .castle` (`Sh/LibraryOpenModel.swift:304-307`);
   - the incoming copy is plaintext, or its own key file derives Standard under `Posture.derive(legacyMode: nil, vault: nil, rawKeyCustody: .unknown, enrolled: false)` (`:317-334`).
3. Step-aside text, or the fresh-slot text (`Sh/LibraryOpenCopy.swift:51-55`), chosen by whether a file sits at the slot (`Sh/LibraryOpenModel.swift:288-290`).
4. Plaintext line (`Sh/LibraryOpenCopy.swift:60-62`).
5. iCloud Drive source line (`:134-136`).
6. "sync waits until you press Resume" (`:56-58`).

"As of" is the backup stamp, or else the source's mtime (`Sh/LibraryOpenModel.swift:291-293`).

### Step 4 — adopt (`confirmAdoption`, `Sh/LibraryOpenModel.swift:339-465`)

**Encrypted road (`:357-370`):** `LibraryAdoption.plan` + `execute(holding:)`, then `landCustody`.

**Plaintext road (`:371-394`):**
1. `freshKey = StoreKey.mint()`.
2. Execute with no key file.
3. `LocalMachineryRecreation.recreateIfMissing`.
4. `StoreIdentity.establish`, which makes a **new store id**.
5. `saveDials(ProtectionDials(), id)`, Auto.
6. `saveAuto(freshKey)`.
7. The reopen's `openStore` migrates the plaintext file to encrypted (`Core/AppDatabase+Dependency.swift:118`).

**Ready road** (`Sh/AppBootstrap.swift:761-789`):
1. `onWillLock`: flush, savepoint, services stop, MCP detach (`Mac/VariorumApp.swift:252-257`).
2. `.opening`.
3. Drop the resident key, the per-open deferrals and the shared session.
4. Off-main: `binding.lock()`, then the work.
5. On success, reopen with the key as **in-memory** custody; on failure, reopen with **no key**.
6. Rethrow after the reopen.

**Non-ready road** (`Sh/LibraryOpenModel.swift:400-453`):
1. Suspend the lobby's Apple probe.
2. Wait out any in-flight open.
3. Run the work.
4. On failure, re-arm the lobby. On success, `reopenAfterAdoption(unlockedKey:)` (`Sh/AppBootstrap.swift:798-822`).

**`LibraryAdoption.execute`** (`Core/LibraryAdoption.swift:188-310`):
1. Verify the source pair (`:193-212`).
2. Refuse a non-empty live `-wal` (`:214-220`).
3. Departing = the store, its `-wal`/`-shm` and `keyFileURLs` (`:222-231`). Copy them to the safety folder (`:233-248`).
4. **Step 3½:** write the hold (`:250-269`).
5. Move departing to `Previous Libraries/<stamp>` (`:271-286`).
6. Land, in this order: copy the source store, copy its `-wal` if non-empty, then write the source key file's bytes under `variorum-keys-<fp16>.json` (`:288-307`).

### How custody and the live key file are chosen

**The live key file is the source's bytes, verbatim** (`Core/LibraryAdoption.swift:127-135, 302-304`): its store id, its wraps of its day (P, W, M, A), its `vaultKDF` records. The plaintext road instead gets a fresh, wraps-less file with a new id (`Core/StoreIdentity.swift:49-75`).

**`landCustody`** (`Sh/LibraryOpenModel.swift:509-544`) runs after the landing. The guard therefore resolves the **incoming** copy's store id (`Sh/StoreKeyGuard.swift:83-86`).

*Verdict*, the `CustodyCollisionRule` (`Core/CustodyCollisionRule.swift:49-56`):

| What custody holds for that id | Verdict |
|---|---|
| a silent key | fingerprint equal → `alreadyAligned` (return); different → `adoptOpeningKey` |
| a gated item exists | `adoptOpeningKey` (cannot be read without a prompt) |
| nothing | `mintFreshCustody` |

*Shape:* `gate.effectiveGate(scope, incomingID, slot)` (`Sh/StoreLaunchGate.swift:405-427`), which reads this Mac's custody presence, its sync-custody presence, its legacy mode and its dials **for that id**, plus the landed key file:

| Effective gate | Writes |
|---|---|
| `.auto` | `saveAuto`, `deleteGated` |
| `.biometric` | `saveGated`, `deleteAuto` |
| `.passphrase` | `deleteAuto`, `deleteGated` |

**All results are ignored** (`_ =`). M, C and the device identity are untouched.

**After the reopen**, `finish(.ready)` (`Sh/AppBootstrap.swift:463-582`) does three things:
- `protection.adoptResident(unlockedKey)` on **every** road (`:530`);
- the R1-M3 re-landing `relandSilentItem(key)` → `saveAuto` again, when the effective gate is not demanded and no switch is pending (`:548-557`; `Sh/ProtectionController.swift:1336-1345`);
- the ready housekeeping (`Sh/AppBootstrap.swift:612-655`):
  - the §11 migration, only if `migrated2a` is unset for that id. Its legs re-scope sync custody (carrying `sync_state.device_id` into the identity item and deleting the row), retire the dial keys, align custody, and write the master copy (`Sh/ProtectionMigration.swift:143-290`);
  - then `reconcile`: re-read the dials, enrolled-ness, the vault word, the silent-item sweep, the follow verdicts (incl. `castleKeyFileAppleOpenable`, `Sh/ProtectionController.swift:680-685`), clearing a stale `switchPending` flag "a restored copy's" (`:1480-1499`), and the Apple arm (`:1600-1690`).

### Same incoming and outgoing store id (any older or same-key copy of the same library: a snapshot pair, a Previous Library, a hand-off returning home)

- **Silent and gated items** `<scope>-<id>-bound` / `-biometric` are shared. `landCustody` overwrites them when the keys differ, which retires the outgoing library's silent and Touch ID road. The outgoing library keeps its key-file roads in `Previous Libraries` (`Core/CustodyCollisionRule.swift:11-17`).
- **Sync custody** `<scope>-<id>-sync*` is untouched. The adopted copy inherits this Mac's M, C and **device identity** for that library.
- **UserDefaults** per id are shared: dials, `switchPending` (cleared at reconcile when no marker exists, `Sh/ProtectionController.swift:1480-1499`), `thisDeviceOnlySwitch`, and `migrated2a`. The migration therefore never re-runs for the copy.
- **The custody shape the copy lands in** is computed from the **outgoing** library's custody shape and dials (`Sh/StoreLaunchGate.swift:405-427`, `:433-436`), not the copy's key file alone. See §7 #11.
- **The aside copy shares the id with the live library.** Moving it back later collides again.
- **The second look and the restore list's second look** are fingerprint-based, not id-based (`Sh/LibraryOpenModel.swift:181`; `Core/BackupRestoreCandidates.swift:106-117`).

### Different store id

The outgoing library's items and dials stay under its id: orphaned, never deleted (`Core/StoreIdentity.swift:15-18`). The incoming id starts fresh on this Mac:
- `mintFreshCustody`, with the shape taken from its key file plus the scope's legacy read-through (`Sh/StoreProtection.swift:304-323`);
- the §11 migration runs at ready;
- no sync custody exists, so enrolment is owed (`Sh/EncryptionKeychain.swift:32-34`).

---

## 5. The restore hold

- **Where it lives.** `variorum-restore-hold.json` beside the slot: per location, not per store id (`Core/LibraryRestoreHold.swift:7-24, 42-47`). It is written before the move (`Core/LibraryAdoption.swift:250-269`).
- **Unreadable means held** (`Core/LibraryRestoreHold.swift:63-75`).

**What it blocks** — the gates read the marker, not the projection (`Sh/RestoreHoldModel.swift:40-53`, wired at `Mac/VariorumApp.swift:234-237`):
- Every sync round: `SyncSession.triggerSync` and `flush` (`Sh/SyncSession.swift:54, 164-178`). Every scheduler round funnels through them (`Sync/SyncScheduler.swift:129-163`). Sync Now speaks a refusal (`Sh/SyncStatusViews.swift:503-504`).
- The two rotation ceremonies, Use Castle and Replace All Keys, at their door and at a restart (`Sh/PostureSwitchModel.swift:265-279, 720-721`).

**What it does not block:**
- the marker **resume** (deliberately exempt);
- the **follow** roads, which can walk and re-encrypt on the server and write the vault (`Sh/PostureSwitch.swift:858-1004, 1145-1189`);
- Use Standard's vault write (`:1454-1463`);
- backups, lock-time copies and the hand-off;
- the ready reconcile's vault read;
- the silent follow into Standard (`Sh/ProtectionController.swift:707-716`).

It also triggers the MCP adoption landing (`Mac/Features/MCP/MCPDoor.swift:283-292`).

**Resume Sync** (`Sh/RestoreHoldModel.swift:81-90`):
1. `LibraryRestoreHold.clear`. The result is ignored.
2. Projection set to nil.
3. `onResume` → `AppServices.resumeSync()` (`Sh/AppServices.swift:439-445`): trigger a round if sync is configured, else `connectSyncIfAllowed` (owner adoption, configure, trigger; `:419-426`). With no account it only clears.

The banner's wording is at `Sh/LibraryOpenCopy.swift:88-100`, rendered by `Mac/LibraryOpenDoor.swift:300-329`.

---

## 6. The Castle offer ("Delete the backups Variorum made before today?")

**When it is listed.** In `snapshotAndInsurance` (`Sh/PostureSwitch.swift:1349-1385`), only when `listPreSwitchPairs` holds **and** step 6's fresh snapshot was `.written` (`:1373`). `listPreSwitchPairs` is set by the road:

| Road | `listPreSwitchPairs` |
|---|---|
| Use Castle ceremony | `entersCastle` (`:811`) |
| follow into Castle | entering Castle **and** the live key file had `apple` before (`:963, 981, 1000`) |
| resume, enrolled arm | the road's Castle reading AND the live key file had `apple` (`:1672, 1687`) |
| resume, snapshot arm | entering Castle AND the old key file beside the slot has `apple` (`:1764-1769`) |
| Replace All Keys | never (`entersCastle` false) |
| Use Standard | never |

The phone never offers: `takeSnapshot` returns `.notKept` there (`:1946`).

**Folders it enumerates** (`:1895-1896, 1903-1907, 1951-1958, 1976-1978`):
- the container `Backups/`;
- the far `<picked>/Variorum/Backups/`, if the bookmark resolves;
- `Previous Libraries/<stamp>/` and `Backups/safety-copies/variorum-adopt-safety-<stamp>/` beside the slot.

**How it decides "pre-switch":**
- *Snapshots:* by **name only**. `shortFingerprint(fromBackupURL:) != fp8(new key)`. Stamp-only names give nil, so they are included (`:1903-1907`; `Sh/StoreBackup.swift:778-784`).
- *Aside folders:* `qualify`:
  - a real directory in one of the two homes with the adoption's stamp name;
  - exactly one `.sqlite`;
  - the `locate()` key file carries `apple`;
  - that key file's short fingerprint is not the new one.

  Sources: `Core/LibraryAsideCopies.swift:54-76, 122-155`.

**What it deletes:**
- snapshot + `.keys.json` pairs via `removeSnapshotPair`. For far URLs it claims the bookmark's scope when `url.path.hasPrefix(picked.path)` (`Sh/PostureSwitch.swift:1959-1973`; `Sh/StoreBackup.swift:598-604`);
- aside folders whole, after re-qualifying each (`Core/LibraryAsideCopies.swift:88-93`; `Sh/PostureSwitch.swift:1979-1990`).

**It never touches:**
- folder-level `variorum-keys-*.json` (container or far);
- the live folder's old key file;
- `.stale-*`;
- `md-exports` (the Done says to delete those by hand, `Sh/PostureCopy.swift:532-541`);
- hand-off folders, plaintext exports, Time Machine.

**What it says.** The title, the counted body, "Delete Them" / "Keep Them" (`Sh/PostureCopy.swift:543-580`). The body claims every listed item "still open[s] through your Apple account".

**When it shows.** Done → Continue → `.offer` when `hasOffer` (`Sh/PostureSwitchModel.swift:647-661`; `Sh/PostureFollowModel.swift:245-260`; `Sh/PostureSwitch.swift:206`).

**Whether it re-appears.** The outcome lives only in memory and the marker is already cleared (`:1249`), so after Keep, Delete or a quit **it never returns**. A later switch, follow or resume computes a new list. Delete acts on the list computed at Done time.

---

## 7. Inconsistencies and hazards

1. **traced — An adoption failure or crash after the move mints a fresh empty library.**
   - The adoption header promises the 4→5 window routes `libraryMissing` (`Core/LibraryAdoption.swift:39-42`). But step 4 moves **every key file** too (`:222-231, 271-286`). With no key file the store id is nil, so the dials fall back to the scope's legacy keys (retired by §11), and the posture derives Standard (`Sh/StoreProtection.swift:96-109`). The route is then `.open` (`Sh/StoreLaunchGate.swift:344-348`).
   - On an absent file, `openStore` → `resolveStoreKey` **mints** a key, `establish` writes a **new store id**, and an empty library opens (`Core/AppDatabase+Dependency.swift:155-175`; `Core/StoreKey.swift:297-304`). The hold marker stands beside it, so the banner calls this empty library "your library as of <the copy's date>" (`Sh/LibraryOpenCopy.swift:88-100`).
   - In-process this happens immediately on `landingFailed`: the ready road reopens with no key (`Sh/AppBootstrap.swift:784-786`) while the sheet says the old library is whole in its two copies.
   - A mid-move failure that left the key files behind does the same under Standard, but creates the empty file **under the outgoing key and id** (`Core/StoreKey.swift:308-319`).
2. **traced — The fresh snapshot after a switch carries a pending rotation marker.** The marker is written at `.snapshot` before step 6's snapshot and cleared after it (`Sh/PostureSwitch.swift:1236-1249`). The backup copies the whole file (`Core/AppDatabase.swift:221-228`), so the very copy the offer requires holds `rekey_in_progress`. So do hourly snapshots and hand-offs taken during a walk. Restoring one lands a library whose engine refuses every round (`Sync/SyncEngine.swift:77`) until the marker's resume runs. A `.reencrypt` copy's resume re-runs steps 4–7, a new library key included — **suspected**, not traced through `CorpusRotation.complete`.
3. **traced — "Apple-openable" is decided two ways.** Snapshots are judged by name fp8 alone (`Sh/PostureSwitch.swift:1903-1907`). Aside copies are judged by their key file's `apple` (`Core/LibraryAsideCopies.swift:151-153`). Castle-era snapshots, another library's snapshots, and another Mac's snapshots in a shared far folder are all listed and deleted, while the copy says they "still open through your Apple account" (`Sh/PostureCopy.swift:562-563`).
4. **traced — Apple-openable key files outlive the offer.** Several survive:
   - folder-level key files (container `Backups/` and `<picked>/Variorum/`), which nothing deletes (`Sh/StoreBackup.swift:317-325, 380-383`);
   - the ceremony road's old Standard-era key file beside the slot (`Sh/PostureSwitch.swift:1006-1018`; header `:40`);
   - `.stale-*` files.

   Because A is per scope and openability belongs to the key L, any surviving `apple(L)` file opens kept, Time Machine or hand-off copies under L.
5. **traced — Two roads into Castle leave different folders.** A follow retires the old key file (`Sh/PostureSwitch.swift:1248, 1773-1775`); the Use Castle ceremony keeps it.
6. **traced — A snapshot's name and its pair can disagree.**
   - The name uses the pool's key (`Sh/StoreBackup.swift:559-560`); the pair uses `locate()`'s newest-mtime file (`:567-570`). In the switch window the new key file exists before the swap (`Sh/PostureSwitch.swift:1223-1227`). The classifier then falls back to the folder file.
   - The lock-time copy names and pairs itself from `locate()` (`Sh/StoreBackup.swift:648-662`). A lock during a crashed switch (new file written, swap undone) yields a copy listed as openable whose pair is rejected (`keyRejected`) — traced, given that crash state.
7. **traced — Legacy stamp-only snapshots get served by the wrong key.** `locate()` prefers fingerprint files over `variorum-keys.json` (`Core/LibraryClassifier.swift:192-194`; `Core/StoreKeyEnvelope.swift:482-496`). After any re-key copies a newer key's file into `Backups/`, such a snapshot lists the new key's credentials and fails with `keyRejected` at open.
8. **traced — The far folder's key file is not beside its snapshots.** It sits one level up (`Sh/StoreBackup.swift:380-383` vs `:366`), and the classifier looks only beside the snapshot (`Core/LibraryClassifier.swift:177-191`). A far snapshot without a pair (pre-row-42, or a failed `try?` pair copy at `Sh/StoreBackup.swift:416-419`) is bare. The restore list never shows the far folder anyway.
9. **traced — Retention and the offer ignore library and Mac.** `existingBackups` (`Sh/StoreBackup.swift:704-715`) feeds the 14 and 14+4 prunes and the offer. Two Macs sharing a far folder prune, and offer to delete, each other's copies.
10. **traced — `landCustody` ignores every result and has no verify step** (`Sh/LibraryOpenModel.swift:535-542`). The custody law's own handover verifies before it deletes (`Sh/ProtectionController.swift:1361-1420`). A refused `saveGated` followed by a successful `deleteAuto` leaves no item.
11. **traced (code) / outcomes partly suspected — A same-id copy inherits the outgoing library's custody shape.** `effectiveGate` (`Sh/StoreLaunchGate.swift:405-427`) reads this Mac's state for the shared id.
    - An enrolled Castle library adopting a Standard-era copy gets a **gated** item while the landed key file carries `apple`. The `castleKeyFileAppleOpenable` follow becomes owed (`Sh/ProtectionController.swift:680-685`), and until it runs every new pair copies the Apple-openable file.
    - A non-enrolled Standard library adopting a Castle-era copy gets a **silent** item. Then `effectiveGate`'s landing writes an `apple` copy into the copy's key file. That happens already at the reopen's `currentEffectiveGate` read (`Sh/AppBootstrap.swift:548`; `Sh/StoreLaunchGate.swift:411-420`), or else at the reconcile's Apple arm (`Sh/ProtectionController.swift:1600-1690`). No confirm line exists for that direction.
    - The VX-209 line decides with `enrolled: false` and `.unknown` custody (`Sh/LibraryOpenModel.swift:327-329`).
12. **traced — The key handed over at reopen is mistaken for a Castle key.** `finish` gives the unlocked key to `adoptResident` on every road (`Sh/AppBootstrap.swift:530`), but the controller reads "a resident key means gated or nowhere" (`Sh/ProtectionController.swift:1090-1096`). After a Standard adoption the session reads as `.gatedOrNone`. The VX-110 guard can then skip the Apple arm (`:1622-1628`) — suspected impact.
13. **traced — Readers that write.**
    - `effectiveGate` lands Apple copies. It is called by the route, `currentEffectiveGate` (`Sh/AppBootstrap.swift:668-674`), `lock()` and `landCustody`.
    - `StoreKeyKeychain.load` writes a key file and migrates or deletes legacy items (`Core/StoreKey.swift:273-319`).
    - The Apple arm's `ensuredEnvelope` sets aside a non-matching key file and starts a **new store id** (`Sh/ProtectionController.swift:1129-1142, 1718`).
    - The adoption's typed unlock replaces the live library's shared derived key before any confirm (`Sh/LibraryOpenModel.swift:242-246`; `Sh/StoreLaunchGate.swift:929, 991`) — suspected impact.
14. **traced — Resume can hide a hold that still stands.** `resume()` nils the projection even if the marker removal failed (`Sh/RestoreHoldModel.swift:85-89`). The banner goes away while the gates still refuse. The hold also does not cover the follow, resume or Use Standard server acts (§5).
15. **traced — Orphans.**
    - `.stale-*` files (never touched);
    - the `.rekeying` temp, until the next re-key, and not moved by an adoption;
    - per-id Keychain items and defaults of old ids;
    - folder key files and `RESTORE.md`;
    - `Previous Libraries` and adopt safety copies, which only the offer can delete, and only Apple-openable ones.
16. **traced — Landing order can leave ciphertext with no key file.** The store is landed before its key file (`Core/LibraryAdoption.swift:295-304`). A crash between them leaves ciphertext and no key file. The next route has no id → the Standard road → `keyUnavailable` with **no recovery road**, since one needs an envelope (`Sh/AppBootstrap.swift:432-461`). The source key file exists only at the picked location.
17. **suspected — The lock-time copy can race an unlock.** The copy runs after the lobby is already shown (`Sh/AppBootstrap.swift:931` then `:943-950`). A quick Touch ID unlock reopens the pool while the byte copy reads the file.
18. **traced — The live-folder guard is uneven.** Data Safety refuses the live library's folder (`Mac/Features/Settings/DataSafetyModel.swift:265-273`); the iCloud offer's pick does not (`Mac/Features/Settings/ICloudDriveOffer.swift:166-183`). The plaintext export refuses only the two backup folders.
19. **traced — The restore list promises roads it does not check.**
    - "your current passphrase (online)" is shown for any master copy (`Sh/LibraryOpenCopy.swift:114`). The vault road needs the **current** master to unwrap that copy (`Sh/StoreLaunchGate.swift:960-974`), so it is false for copies taken before a Use Castle or Replace All Keys rotated M (`Sh/PostureSwitch.swift:25-30`).
    - The second look is fingerprint-only.
    - A key file with no roads shows the bare sentence but still gets an Open… button (`Sh/LibraryOpenCopy.swift:115`; `Mac/Features/Settings/DataSafetyPane.swift:167`).
20. **traced — The snapshot name grammar is stated three times.** `Sh/StoreBackup.swift:757-767`, `Core/BackupRestoreCandidates.swift:129-142` and `Core/LibraryClassifier.swift:140-152`. The last treats any `variorum-backup-<non-fp tail>` file as stamp-only and serves it through `locate()`.
21. **suspected — The pending lock-time check list is global.** It is not per library (`Sh/StoreBackup.swift:621, 675-688`). After an adoption, a copy can be checked with the wrong key.
22. **traced — Pair and folder-key writes are best-effort `try?`.** A snapshot can exist with nothing serving it (`Sh/StoreBackup.swift:317-325, 589-594, 662-663`).
23. **suspected — Far deletes can fail silently.** Path-prefix scope matching may skip them with no error shown (`Sh/PostureSwitch.swift:1963-1970`), and the delete uses the list computed at Done time.
24. **suspected — The §11 migration can copy another device's identity.** On a new-id adoption, migration leg 1 carries an old copy's `sync_state.device_id` into this Mac's identity item (`Sh/ProtectionMigration.swift:172-194`). That identity can be another device's, if the copy came from another Mac before its own migration.
