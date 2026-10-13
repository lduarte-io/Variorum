# VX-266 research — copies of a library, the churn, and the failure taxonomy

Research only (no design, no code changed). Worktree `~/dev/variorum-vx-266` @ `63ec98c1` (= main).
Evidence tags: **V** = VERIFIED (read in code, file:line) · **I** = INFERRED (from docs/records, or a
mechanism composed from verified pieces but not executed) · **D≠C** = a doc/code disagreement.
Paths: `Core/` = `Sources/VariorumCore/`, `Shared/` = `App/Variorum/Shared/`, `Mac/` = `App/Variorum/Variorum/`.
`<store>` = the live store folder (`…/Application Support/Variorum/`, holds `variorum.sqlite`).

---

## 0. The ten findings that matter most (details and evidence in §1–§8)

1. **VX-209 is three coupled design choices, not one bug** (K1+K2+K5): the store id is shared by every copy and
   "stable across re-keys" (the design review's P6(b) "a re-key mints a NEW store id" was never built); posture is
   derived from THIS Mac's custody SHAPE for that id (corner 45: a silent item ⇒ Standard-waiting); and reads write
   (`currentEffectiveGate` lands an Apple copy). `landCustody` derives the landing posture from custody a PREVIOUS
   copy left behind. Fixing any one of the three alone leaves the other two.
2. **Copies are write-once, uncatalogued and kept forever**: pairs and folder key files are never rewritten
   (decision 11), A is never deleted, Previous Libraries + adopt safety copies are never pruned (each adoption
   duplicates the library twice), and `removeAppleWrappedCopy` has no production caller — entering Castle mints a
   new key file and leaves the old Apple-wrapped one beside the library. Posture changes reach copies only by deletion.
3. **VX-263 is verified in code, and a design rule is missing**: the restore list (container only) asks ONE key file
   per snapshot; exposed-era pairs carry no wraps; the old key's only wrap sits in the leftover live-folder file, which
   nothing reads. The postures design says "every fingerprint key file is tried newest-first" — no road does; all read
   `locate`'s newest-mtime file. VX-213's "retire that file" would destroy the last route.
4. **The Castle offer** is one-shot, scans container + the CURRENT bookmark + Apple-openable aside folders, misses old/
   unplugged folders, hand-offs, A1 copies, `.md` exports, folder key files and the leftover key file, deletes two
   kinds of copy with one button, and is decided by **two different rules** (ceremony: any Castle entry; follow/resume:
   old key file had `apple`) — so exposed users read "they still open through your Apple account, and they always will".
5. **Adoption's recorded crash window is mis-described**: step 4→5 "routes `libraryMissing`" only under Castle; under
   Standard the route opens and mints a fresh EMPTY library under a new store id beside a standing hold (I). The
   3½→4 window holds the OLD library. `landCustody` drops every custody result and skips the verify-then-delete rule.
6. **Aliasing inventory**: bound/gated/sync Keychain items, dials, the legacy-mode read-through, switch-pending and
   This-Mac-only flags are all `(scope, storeID)` and shared by every copy; the collision rule reconciles only the KEY
   in the bound item. The rotation marker travels INSIDE copies (the switch's own fresh snapshot carries `.snapshot`)
   while the restore hold is per location.
7. **Churn**: 213 commits on 53 files in 99 days; **Oct 1–13: 62 commits, 65% fix-like**; the area grew 300 →
   24,933 lines (doubling Sep 1→8). Hotspots: ProtectionController 51 commits / 2,154 lines, PostureSwitch 43 / 2,024
   (+29% in October), AppBootstrap 36, PostureCopy 35, ProtectionPane 34. The copies brains are one week old and were
   re-touched by three 13x ladder rounds, VX-203 and VX-209.
8. **Taxonomy (13 classes)** — three families: posture truth (K1 posture-from-proxy 13 · K2 store-id aliasing 6 · K5
   read-that-writes 8), copies lifecycle (K3 frozen wraps 10 · K4 discovery fragmentation 9 · K13 leftovers 8),
   custody transactions (K6 crash windows/markers 12 · K7 races 8 · K8 write-only law 8); plus the cost layer (K9
   harness 9 · K10 copy overclaims 19 · K11 hosting 11 · K12 duplicated brains 8).
9. **Doc/face contradictions**: Data Safety lists `Open…` rows above "Restoring is a Finder operation, not a button";
   RESTORE.md teaches only the manual swap (no hold, legacy `variorum-keys.json` name); the library-missing
   "Restore from a Backup…" merely reveals Finder; recovery sentences name a file modern folders don't contain.
10. **Blind spots**: the phone has no copy road at all (VM-15 has nothing to list); the posture drill was last run green on
    09-07 and found red on 10-13 (VX-233); harness worlds can be account-inconsistent (VX-106); a test once overwrote her
    live custody (13p-fix R3-1).

---

## 1. The copies map

### 1.1 Copy kinds (every copy of a library the code writes or reads)

| # | Kind | Where (path pattern) | When written · by whom (file:func:line) | Retention / pruning | Protected by | Key file that travels with it — and its wraps at write time | Rewritten later? |
|---|---|---|---|---|---|---|---|
| C1 | **Scheduled snapshot, primary leg** | `<store>/Backups/variorum-backup-<UTC yyyy-MM-dd-HHmmss>-<fp8>.sqlite` (legacy 13p names: no `-<fp8>`) | launch + hourly due-check (24 h interval), Back Up Now, iCloud-offer pick, insurance toggle, posture-switch step 6 — `Shared/StoreBackup.swift:performPrimaryLeg:545-573` (GRDB `backup(to:)` at 563, then sealed to `journal_mode=DELETE` by `integrityCheck:477-516`) — single-flight latch `run:169-184` **V** | newest **14** by parsed stamp, oldest-first, pairs go with them — `prune:609-615`; only names `date(fromBackupURL:)` accepts (`existingBackups:704-715`) **V** | ciphertext under the library key **of that moment** (`database.storeKeyFingerprint` names it, 559-562) **V** | **(a)** its own PAIR `…-<fp8>.keys.json` = the live key file's bytes at that instant (`writeSnapshotKeyFile:589-594`, only-when-absent); **(b)** the folder file `<store>/Backups/variorum-keys-<fp16>.json` (`copyKeyEnvelope:317-325`, only-when-absent, copied on EVERY run, 281-283). Wraps = whatever the live file held: Standard ⇒ `apple` (+P/W/M if set); exposed ⇒ none; Castle ⇒ P/W(/M), no `apple` **V** | **Never.** Both pair and folder file are write-once ("NEVER rewritten after it is written", 308-316) — the folder file keeps the wraps of the FIRST run that met that key, even if later runs saw more wraps **V** |
| C2 | **Scheduled snapshot, second leg** ("A second folder") | `<picked>/Variorum/Backups/<same name>.sqlite` + `.keys.json`; folder key file one level UP at `<picked>/Variorum/variorum-keys-<fp16>.json`; `RESTORE.md` at `<picked>/Variorum/` | same run, byte-copy of THIS act's primary snapshot (18k C7) — `performSecondLeg:353-431`; pair copied only-when-absent 414-419; folder file 380-383; bookmark = device-local `UserDefaults` `variorum.backup.secondDestination` (`BackupDestination.swift:34`) **V** | **14 dailies + 4 weeklies** (`BackupRetention.keep:87-119`, `pruneSecond:435-444`) **V** | same ciphertext (byte copy) **V** | same frozen bytes as C1's pair; NB the folder file sits in `Variorum/`, not beside the snapshots in `Variorum/Backups/` **V** | Never (same rule). A same-name far snapshot IS overwritten (`removeItem` 408-410) but its pair is not **V** |
| C3 | **Lock-time keyless byte-copy** (Castle) | `<store>/Backups/variorum-backup-<stamp>-<fp8>.sqlite` (same namespace as C1) | at Lock (demanded gates only), after pool close + key drop, when a backup is due and `-wal` empty — `StoreBackup.performLockTimeCopyIfDue:633-669`, wired `Mac/VariorumApp.swift:267-273`, run `AppBootstrap.lock:909-950` (949) **V** | prune keep **14 hard-coded** (664 — not `configuration.keep`) **V** | ciphertext as on disk **V** | pair = the file `locate` picks (648-662) + folder file (663); integrity check deferred to the next unlock via defaults `variorum.backup.pendingLockTimeChecks` (621, 675-688) **V** | Never |
| C4 | **13x hand-off pair** ("Send Library to Another Mac…") | `<user-picked parent>/Variorum Library — <local yyyy-MM-dd>[ (n)]/variorum.sqlite` + `variorum-keys-<fp16>.json` | the door (File menu + Data Safety twin) — `Shared/LibraryHandOff.swift:produce:88-143` (backup + seal 117-129; key file bytes 95-104, 130-136) **V** | never pruned (user's folder) **V** | ciphertext, current key **V** | the LIVE key file's bytes at that moment (`locate`, 95) — a Standard-era hand-off carries `apple` **V** | Never |
| C5 | **Previous Libraries entry** (13x step-aside) | `<store>/Previous Libraries/<UTC stamp>/` ← the outgoing `variorum.sqlite`, its `-wal/-shm`, and **every** key file beside it (`keyFileURLs`) | every adoption with a library standing — `Core/…/LibraryAdoption.swift:execute` step 4 (271-286; departing set 222-231) **V** | **never pruned**; only the Castle offer can delete it, and only if Apple-openable (`LibraryAsideCopies.swift:54-93`) **V** | the outgoing library's key **V** | all its key files move WITH it (moveItem preserves mtimes — the qualification relies on it, 30-31) **V** | Never (but `locate` picks among several by **mtime**) |
| C6 | **Adoption safety copy** | `<store>/Backups/safety-copies/variorum-adopt-safety-<stamp>/` (same files as C5, copied) | adoption step 3, BEFORE the move — `LibraryAdoption.execute:233-248` **V** | never pruned; Castle offer may delete (Apple-openable only) **V** | same | same set as C5 | Never |
| C7 | **A1 rail safety copies** (manual, sessions/author) | `<store>/Backups/safety-copies/variorum-backup-a1-*/`, `scale-prestage-*` | not app code: CLAUDE.md's `/Applications` refresh ritual; `Tools/ScaleFixture/stage.sh:29` **V**; rule R-18k-8 (`.claude/skills/architect-phase/SKILL.md:303-306`) **V** | never | whatever was copied | whatever was copied | — ; explicitly NOT matched by the offer's lister (`LibraryAsideCopies.swift:20-21`) **V** |
| C8 | **Decrypted `.sqlite` export** | user-chosen file (default `Variorum-unencrypted.sqlite`); refused inside `<store>/Backups` and `<picked>/Variorum` (`Mac/…/DataSafetyPane.swift:416-423`) | Data Safety door — `Core/…/StorePlaintextExport.swift:export:48-82` (`sqlcipher_export`, drops the 4 local-only tables, empties MCP grant tables) **V** | never (user's) | **none** (plaintext) | none — no key in the file (header 15-16) **V** | Never |
| C9 | **Scheduled `.md` insurance** | `<picked>/Variorum/md-exports/<dated folder>/` | weekly leg of the same run, OFF by default since 13p — `Shared/MarkdownInsurance.swift:performRun:96-125`, opt-in `variorum.backup.markdownInsurance.enabled` (65) **V** | keep 4 (42) **V** | none (plaintext prose) | — | turned OFF (not deleted) on entering Castle (`PostureSwitch.swift:1362-1370`) **V** |
| C10 | **Manual bulk `.md` export** | user-chosen folder | ⌘K Export Library — `Shared/ExportWriter.swift:29-38` **V** | never | none | — | — |
| C11 | **iCloud Drive placement** | not a separate kind: the iCloud Drive offer just PICKS `<iCloud Drive>/…` as C2's second folder (`Mac/…/ICloudDriveOffer.swift:pick` → `BackupDestination.remember`); live library refused there (`Core/…/LibraryPlacementGuard.swift:22-37`) **V** | — | C2's 14+4 (+ iCloud's own 30-day Recently Deleted, stated in `PostureCopy.swift:569-571`) | same as C2 | same as C2 — Standard-era key files in iCloud Drive carry `apple` (A is in iCloud Keychain) **I** | — |
| C12 | **Transient staged read** | `$TMPDIR/variorum-picked-<UUID>/picked.sqlite[-wal]` | every classifier/schema consult of a picked file — `LibraryClassifier.withStagedRead:289-318` **V** | removed by `defer`; a crash mid-consult leaves one (288-290) **V** | as the source | none | — |
| C13 | **Re-key / encryption temp** | `<store>/variorum.sqlite.encrypting` (+ the re-key's temp) | `StoreEncryptionMigration.migrateIfNeeded:73` / `rekey:220`; atomic `rename(2)` (178, 315) **V** | swept at next attempt | new key | — | — |
| C14 | **Set-aside key files** (not a library copy, but a copy leg) | `<store>/variorum-keys-<fp>.stale-<epoch>.json` | `StoreIdentity.setAside:80-85`, `StoreLaunchGate.live.setAsideEnvelope:116-121`, `ProtectionController.ensuredEnvelope:1129-1142` (a FOREIGN file met while landing a wrap), `LibraryMissingLobby.startNewLibrary:1091` **V** | never | — | — | — |

Not copies, but they ride copies: `RESTORE.md` (written only-when-bytes-change, `StoreBackup.writeRunbook:330-339`) and the
`sync_state` table inside every `.sqlite` copy (C1–C6) — cursor, **and any `rekey_in_progress` marker** (§8 S-9).

### 1.2 What the key files beside each copy carry, per posture at write time

| Posture when the copy was written | Pair / folder key file wraps | What opens that copy LATER (VERIFIED roads) |
|---|---|---|
| Standard, A landed | `apple` (+ P, W, M if set) | the Apple road on any Mac whose iCloud Keychain holds A — **forever**: A is never deleted (`Shared/AppleKeyCustody.swift:15-18`, `delete` is migration/pins-only 189-195) **V** |
| **Exposed** (Standard with no passphrase and no A copy landed) | **none** (storeID + fp only) | nothing via its own pair; only (i) the live custody's second look if same key, or (ii) a DIFFERENT key file holding a wrap of that key (e.g. the leftover old file beside the library) — which no listing consults (§2.1) **V/I** → VX-263 |
| Castle | P, W (+ M) — the passphrase **of its day** | that passphrase, the twelve words of its day, or — only while the account's master is unchanged — M online via the vault road; every rotation (entering Castle, Replace All Keys) mints M′, after which an older pair's M copy unwraps nothing (`StoreLaunchGate.swift:960-974`; `PostureSwitch.swift:20-31`) **V** |

Nothing ever re-wraps a written copy's key file: `copyKeyEnvelope` and `writeSnapshotKeyFile` are only-when-absent (V, above);
`removeAppleWrappedCopy` (`Core/…/StoreKeyEnvelope.swift:317-322`) has **no production caller** — tests only
(`grep`: `KeychainOffMainTests.swift:564`, `Phase13pLobbyTests.swift:832`, `StoreKeyEnvelopeTests.swift:376`) **V**.
Entering Castle mints a NEW key file and leaves the old one (with its `apple` copy of the OLD key) beside the library —
"The old key file stays beside old snapshots" (`PostureSwitch.swift:38-39`, `writeNewKeyFile:1270-1316`) — except on
the FOLLOW road, which deletes it (`retireOldKeyFiles:1019-1045`, called 1248, 1774) **V**.

### 1.3 Key-file lifecycle by event (what sits beside the LIVE store afterwards; every copy then freezes these bytes)

| Event | Live-folder key files afterwards | Evidence |
|---|---|---|
| First open of a fresh library | `variorum-keys-<fp>.json` = storeID + fp, no wraps (written BEFORE the Keychain add); the ready's Apple arm adds `apple` if A can be read or minted — else the library is **exposed** | `StoreKey.swift:297-304`; `StoreIdentity.establish:49-75`; `ProtectionController.reconcileAppleKey:1600-1700` **V** |
| Set passphrase / generate or land words / enroll (master) | the SAME file gains P / W / M (a FOREIGN file met on the way is set aside `.stale-<epoch>`) | `ProtectionController.swift:1149-1171, 1196-1236, 1800+`; `ensuredEnvelope:1129-1142` **V** |
| Enter Castle (ceremony; enrolled or local-only) | NEW `variorum-keys-<fp′>.json` (P, W, M′ of L′; no `apple`) **plus the OLD file kept** (its `apple(L)` in Standard; from the exposed state the ceremony's passphrase step has put P(L) there — the ticket's verified fact) | `PostureSwitch.swift:1207-1316` (old file "stays", 38-39); VX-263 comment **V/I** |
| Follow into Castle (another device switched) | new file as above; old fp file DELETED; a wrap-less legacy stub deleted | `retireOldKeyFiles:1019-1045` **V** |
| Replace All Keys | new file (`apple` only when the vault's word is Standard — VX-99); old file kept | `PostureSwitch.swift:1270-1316`, `appleHeldCopyForStandard` **V** |
| Leave Castle / follow into Standard | `apple` added to the CURRENT file; no re-key | `leaveCastle:1441+` (write at 1468); `followIntoStandard:1091+` (1105) **V** |
| Route / ready "Standard-waiting" heal | `apple` added to the current file on a READ (`effectiveGate` landing arm; reconcile's Apple arm) | `StoreLaunchGate.swift:411-420`; `ProtectionController.swift:1733-1755` **V** |
| Open Library / Restore (adoption) | every key file moves to `Previous Libraries/<stamp>/`; exactly ONE lands (the source's serving file, canonical fp name) | `LibraryAdoption.swift:222-231, 302-304` **V** |
| Start a New Library | the `locate`-chosen file set aside `.stale-<epoch>`; others stay; a new file under a NEW store id | `AppBootstrap.swift:1082-1119` **V** |
| Any backup run / lock-time copy / hand-off | the pair (or hand-off file) = bytes of `locate`'s pick at that instant; the folder file only if absent | §1.1 C1–C4 **V** |

With two or more fp files beside the store, "the current one" is whichever has the newest **mtime**
(`StoreKeyEnvelope.locate:482-497`) — the classifier, the lobby, the route, the hand-off, every backup pair and the
aside-copy qualifier all depend on that one heuristic (VX-191 B6c) **V**.

---
## 2. Read / open roads

### 2.1 Settings ▸ Data Safety ▸ *Restore from Backup* (the listing)

| Step | What happens | Evidence |
|---|---|---|
| Folders scanned | **Only** the in-container `<store>/Backups/` (`backup.directory`). NOT the second folder (C2) — recorded PROVISIONAL "the second folder's listing waits on the walk's verdict"; NOT Previous Libraries (C5), adopt safety copies (C6), hand-offs (C4), A1 copies (C7) | `Mac/…/DataSafetyModel.swift:refresh:104-128` (gather at 119-120); `Mac/…/DataSafetyPane.swift:137-143` **V** |
| Candidate filter | `.sqlite` whose name parses as the app's own (`variorum-backup-<stamp>[-<fp8>]`, stamp must round-trip) — a restatement of `StoreBackup.date(fromBackupURL:)` (3rd copy of the stamp parser: also `LibraryClassifier.backupNameFingerprint`) | `Core/…/BackupRestoreCandidates.swift:backupDate:129-142` **V** |
| Serving key file ("decision 11") | via the classifier, ONE file: (1) the snapshot's own pair `…keys.json` if its fp agrees with the name's fp8; (2) else the folder's `variorum-keys-<fp16>.json` whose fp starts with fp8; (3) stamp-only legacy name → `locate` in the same folder; else none | `BackupRestoreCandidates.candidate:85-122` → `LibraryClassifier.classifyOpaque:154-205` **V** |
| "Which credential opens it" | the booleans `passphrase/recovery/apple/master` of THAT one file + the "second look" (`envelope.keyFingerprint == live fingerprint`, else fp8 vs live short fp) | `BackupRestoreCandidates.swift:96-121`; worded by `LibraryOpenCopy.credentialLine:106-117` **V** |
| Other key files consulted? | **No.** The live folder's key files (incl. the leftover pre-Castle file holding P(L_old)) are never read for a candidate → VX-263 | V (no other read in `gather`) + ticket VX-263 comment |
| Row door | `Open…` rendered only when `keyFile != nil` (a key file with zero roads still shows the door; the flow then refuses with `bareStoreRefusal` — "no key file came with it", false: one did) | `DataSafetyPane.swift:167-172`; `LibraryOpenModel.beginUnlock:216-222` **V** |
| Other "restore" door | The library-missing face's *Restore from a Backup…* only **reveals `Backups/` in Finder** (the 13l manual road) — a second, different meaning of the same words | `Mac/LibraryMissingView.swift:58-64`; `AppBootstrap.swift:LibraryMissingLobby.backupsFolderURL` **V** |
| Restore prose | The same pane still says "Restoring is a Finder operation, not a button" and RESTORE.md's §3 is the manual Finder swap (no hold, no custody rule, legacy `variorum-keys.json` name) | `DataSafetyPane.swift:515-539`; `Mac/…/DataSafetyCopy.swift:197-243` **V** (**D≠C** with the 13x doors) |

### 2.2 File ▸ Open Library… classification (`Core/…/LibraryClassifier.swift`, keyless stage)

| Verdict | Trigger | Door outcome (`Shared/LibraryOpenModel.swift:land:114-139`) |
|---|---|---|
| `encryptedLibrary(store,keyFile)` | ciphertext, ordinary name, `StoreKeyEnvelope.locate` finds a key file beside it (several fp files ⇒ **newest mtime**) (197-202; `StoreKeyEnvelope.swift:482-497`) | unlock roads |
| `snapshotPair(store,keyFile)` | backup-named ciphertext + pair / fp8-matched folder file / legacy (155-196) | unlock roads |
| `folderHoldingPair` | a picked folder with exactly one `.sqlite` whose inner verdict is pair-shaped (101-125) | unlock roads |
| `folderHoldingStores([…])` | several `.sqlite` in the folder | chooser (never guessed) |
| `plaintextExport` / `plaintextLibrary` | plaintext, Variorum-shaped; export = all 4 local-only tables absent (225-259) | confirm → plaintext road (fresh key + **fresh store id**) |
| `bareStoreWithoutKeyFile` | ciphertext, nothing serves it; also a fp8-named snapshot whose folder file is another key's (188-190) | refusal |
| `newerSchema` / `notAVariorumStore` / `unreadable` | migrator superseded check; no Variorum tables; decode error | refusal |

Every SQLite read of a picked file happens on a staged copy in `$TMPDIR` (13x F3 — a read-only open used to rewrite the picked `-shm`) — `withStagedRead:289-318` **V**.

### 2.3 Unlock → settle → confirm (`LibraryOpenModel`)

| Step | Logic | State written | Evidence |
|---|---|---|---|
| Source gate | a COPY of the launch gate whose `loadEnvelope` serves the classifier's key file and `saveEnvelope` is a no-op (the source pair is never rewritten) | none | `sourceGate:145-150` **V** |
| Second look (silent) | `guardFor(scope).loadAuto()` — the live library's silent item — if the pair `belongs(to:)` it | none | `beginUnlock:181-183` **V** |
| Apple road | `StoreLobby.openWithAppleKey` over the source pair (A from iCloud Keychain) | none | 186-187; `StoreLaunchGate.swift:821-833` **V** |
| Gated second look | Touch ID ask only if the gated item exists and the pair is not provably foreign (promptless fp compare vs the LIVE key file) | none | 202-211, `pairIsProvablyForeign:159-169` **V** |
| Typed roads | passphrase / twelve words; vault road online (needs `master` in the pair) — rendered only if the pair carries P/W/M | none (vault fresh-copy write suppressed by the no-op save) | 213-254 **V** |
| Settle | post-unlock `schemaVerdict` on a staged copy: current/behind ⇒ confirm; newer/keyRejected/unreadable ⇒ refusal | none | `settle:263-281` **V** |
| Confirm facts | `willStepAside` (a store exists), `sourceInICloudDrive`, plaintext line, **VX-209 `leavesCastle`** (current posture Castle AND incoming key file derives Standard by `Posture.derive(... rawKeyCustody: .unknown, enrolled: false)`) | none | `enterConfirm:285-297`, `leavesCastle:317-334` **V** |

### 2.4 Adoption — exact order, state, crash windows (`Core/…/LibraryAdoption.swift:execute:188-310` + `LibraryOpenModel.confirmAdoption:339-465`)

| # | Step | State written | If it fails / crash after it | Evidence |
|---|---|---|---|---|
| 0 | READY road: `onWillLock` (flush/savepoint/stop), `state=.opening`, drop resident key, reset per-open deferrals, drop sync-custody session, `binding.lock()` (TRUNCATE checkpoint + close). Non-ready road: suspend the lobby's Apple re-probe, await any in-flight open | memory; the store's `-wal` truncated | — | `AppBootstrap.adoptLibrary:761-787`; `StoreBinding.lock:89-113`; `LibraryOpenModel.swift:396-454` **V** |
| 1 | source pair verified readable | none | refuse, nothing moved | `execute:191-212` **V** |
| 2 | live store must look closed (non-empty `-wal` refuses) | none | refuse | 214-220 **V** |
| 3 | A1-shaped safety copy → `Backups/safety-copies/variorum-adopt-safety-<stamp>/` (store, sidecars, **every** key file) | files (C6) | refuse; a partial safety folder may remain | 233-248 **V** |
| 3½ | restore hold `variorum-restore-hold.json` beside the store (written over the **old** library, before the move) | marker file | refuse "nothing moved"; but a crash between 3½ and 4 leaves the OLD library held with a banner that calls it "your library as of <date>" **I** | 250-269; `LibraryRestoreHold.swift:51-57` **V** |
| 4 | move aside → `Previous Libraries/<stamp>/` (store, sidecars, every key file) | files (C5) | `moveAsideFailed` mid-way: some files moved, some not | 271-286 **V** |
| 5 | landing: copy store + non-empty source `-wal` (never `-shm`); source key file bytes written under the CANONICAL fp name (only that one key file lands) | files | **the one recorded window** (4→5): "the launch routes `libraryMissing`" — true only for a demanded (Castle) gate; under Standard an absent store + no key file routes `.open` and `resolveStoreKey` **mints a fresh empty library under a new store id** (**D≠C, I**: `LibraryAdoption.swift:39-42` vs `StoreLaunchRoute.resolve:344-348`, `Posture.localReading:102`, `AppDatabase+Dependency.swift:resolveStoreKey:173-195`) | 288-307 **V** |
| 6a | encrypted road: `landCustody` — verdict from the silent item **of the landed store id** vs the opener: aligned / adopt / mint; then writes per `gate.effectiveGate(scope, storeID, storeURL)` of the LANDED file: `.auto` ⇒ `saveAuto`+`deleteGated`; `.biometric` ⇒ `saveGated`+`deleteAuto`; `.passphrase` ⇒ delete both. Results discarded (`_ =`), no `CustodyHandover` verify | Keychain items `<scope>-<storeID>-bound` / `-biometric`; and **`effectiveGate` itself may WRITE an Apple copy into the landed key file** (the route's landing arm, `StoreLaunchGate.swift:411-420`) | VX-209's engine: a silent item left by an earlier copy of the same store id makes corner 45 read Standard | `landCustody:509-544` → `StoreLaunchGate.live.guardFor:104-109` → `StoreKeyGuard.keychain:81-111` (bound item via `StoreKeyCustody.deviceKeychain` → `StoreKeyKeychain.save/delete`, `StoreKey.swift:297-337`; gated via `StoreKeyGuardKeychain.saveGated/deleteGated`, `StoreKeyGuard.swift:270-330`) — the store id re-read from the LANDED key file at each call **V** |
| 6b | plaintext road: recreate the 4 local-only tables; `StoreIdentity.establish` (NEW key file, NEW store id); `saveDials(ProtectionDials())` (Standard/Auto) for that id; `saveAuto(freshKey)` (a refused save "self-heals" at next launch — I) | DB tables, key file, defaults, Keychain | — | `LibraryOpenModel.swift:371-394`; `LocalMachineryRecreation.swift:69-92` **V** |
| 7 | reopen with the opener as in-memory custody (route skipped since a key is in hand); first ready: dials re-read **per store id**, lingering-silent sweep, follow, stale switch-pending flag cleared (VX-201 R1-1: "a restored copy shares" the per-store-id flag), Apple arm lands an `apple` copy in the live key file if the reading is determined Standard | defaults, Keychain, key file | — | `AppBootstrap.swift:818-822`, `routeAndOpen:306-430`; `ProtectionController.reconcile:1442-1497`, `reconcileAppleKey:1600-1700` **V** |
| 8 | HELD: every round/flush refuses; rotation ceremonies (Use Castle, Replace All Keys) refuse at the door; Use Standard and a marker resume stay open | — | — | `SyncSession.swift:164-176`; `PostureSwitchModel.swift:265-278, 720-723`; gates read the marker file, never the projection (`RestoreHoldModel.wireGates:49-53`) **V** |
| 9 | Resume Sync: delete the marker, then `onResume` (resumeSync) — a copy never carries sync custody (sync custody is per store id; a new store id ⇒ enrollment; VX-100) | marker removed | a failed `removeItem` is swallowed (`clear` returns Bool, `resume` ignores it) **V** | `RestoreHoldModel.resume:81-90`; `LibraryRestoreHold.clear:86-90` **V** |

The hold is per-LOCATION (marker beside the store), deliberately not per store id and not in `sync_state`
(`LibraryRestoreHold.swift:7-24`) **V**. Mobile has none of §2: `backupEnabled: false`
(`VariorumMobile/VariorumMobileApp.swift:70`), its library-missing face offers only Start a New Library
(`MobileLibraryMissingView.swift:8-12`) **V**.

### 2.5 Who opens what, and where it lands (composed from §2.1–2.4; same Mac unless said)

**Opening roads by copy kind** (the unlock step's order: silent second look → Apple road → gated second look → typed):

| Copy | Silent / Touch ID second look | Apple road (A in iCloud Keychain) | Passphrase | Twelve words | Vault (M, online) | In the restore list? |
|---|---|---|---|---|---|---|
| Container pair under the **current** key | yes (live custody holds it) | if its pair has `apple` | P of its day | W of its day | if pair has `master` | yes |
| Container pair under an **older** key, Standard era | no (fp differs ⇒ foreign, no prompt) | **yes — forever, any Mac on the iCloud** | if P existed then | if W existed then | no — its M copy is under the master the rotation retired (yet the list still says "your current passphrase (online)") | yes |
| Pair from the **exposed** era (no P, no A copy) | only while still under the live key — never after entering Castle (which re-keys) | no | no | no | no (not enrolled without a passphrase) | listed as "can't be opened"; `Open…` refuses with the wrong sentence (VX-263, S-14) |
| Castle-era older pair (pre Replace All Keys) | no | no | P of its day | W of its day (unless regenerated) | no (M rotated) | yes |
| Second-folder pair (C2) | same as its container twin | same | same | same | same | **no** — File ▸ Open Library only |
| Previous Libraries / adopt safety copy (C5/C6) | by `locate`'s newest-mtime key file only | if that file has `apple` | … | … | … | **no** — Open Library, inside the container (VX-101) |
| Hand-off folder (C4) | as the live key file at hand-off | Standard-era ⇒ yes | … | … | … | no |
| Plaintext export (C8) | — | — | — | — | — | no — plaintext road |

**Where the adopted library LANDS** (`landCustody` + the first ready; V for the code path, ticket-confirmed where named):

| Library standing here | Copy picked | Custody write | Lands as | Evidence |
|---|---|---|---|---|
| Castle, local-only (gated item) | Standard-era pair of the SAME library | `saveAuto(L_old)` + `deleteGated` (Touch ID item destroyed) | **Standard**, silently; the Apple arm verifies the copy | VX-209 step 1; `LibraryOpenModel.swift:533-536` |
| Standard-by-accident after the above (silent = L_old) | the Castle library brought back from Previous Libraries | silent present ⇒ corner 45 ⇒ `.auto` ⇒ `saveAuto(L_castle)`; the ready's `currentEffectiveGate` read wraps L_castle under A | **Standard + an Apple copy of the Castle key** | VX-209 step 2, F-U5-1/F-U5-6 |
| Castle, enrolled | Standard-era pair of the same library | enrolled ⇒ indeterminate ⇒ shape gated ⇒ `saveGated(L_old)` | Castle-shaped, `apple` live in the key file until `castleKeyFileAppleOpenable` owes the follow (re-key) | 13x R1-BLOCKER fix; F-U5-4 (traced, not pinned) |
| Castle | older Castle-era pair | gated item present ⇒ `adoptOpeningKey` ⇒ shape gated ⇒ `saveGated(opener)` + `deleteAuto` | Castle | `LibraryOpenModel.swift:519-543` |
| any | plaintext export / pre-13p plaintext library | new key, **new store id**, `ProtectionDials()` (Standard), `saveAuto` | Standard, new identity (sync re-enrolls) | `LibraryOpenModel.swift:371-394` |
| any | a DIFFERENT library (other store id) | `mintFreshCustody`; shape from its own key file (`apple` ⇒ silent; P only ⇒ gated) | its own key file's posture | `CustodyCollisionRule.swift:35-39` |

---

## 3. The Castle offer ("Delete the backups Variorum made before today?")

| Aspect | Today | Evidence |
|---|---|---|
| When offered | Only after a **Castle-entering** road whose step-6 fresh snapshot was WRITTEN. Ceremony road: `listPreSwitchPairs: entersCastle` (any prior shape, incl. exposed). Follow + resume roads: `entersCastle && wasStandardShaped` (old key file had `apple`). **Two different rules for one offer.** Phone: `takeSnapshot` ⇒ `.notKept` ⇒ never | `PostureSwitch.swift:811` vs `963/981/1000/1672/1687/1769`; `snapshotAndInsurance:1349-1385`; live `takeSnapshot:1942-1949` **V** |
| What it lists | (a) app-named snapshots whose name fp8 ≠ the new key's (stamp-only legacy names always listed) in `<store>/Backups` **and the CURRENTLY bookmarked** far folder; (b) VX-203: `Previous Libraries/<stamp>` + `variorum-adopt-safety-<stamp>` folders whose `locate`-chosen key file carries `apple`, excluding the new key's | `Leaves.live.preSwitchSnapshots:1951-1958`, `pairs:1903-1907`; `LibraryAdoption.appleOpenableAsideCopies:54-76` **V** |
| What it never lists | previously-picked or unreachable far folders (VX-210); hand-off folders (C4); A1 copies (C7); `.md` exports (C9/C10 — a Done line tells her to delete them, VX-208); the **folder-level** `variorum-keys-<oldfp>.json` files in `Backups/` and `<picked>/Variorum/` (not part of a "pair"); the **leftover old key file beside the library** (still carrying `apple(L_old)` on the ceremony device) | `removeSnapshotPair:598-604` deletes only `.sqlite` + `.keys.json` **V**; `retireOldKeyFiles` runs on the FOLLOW only (1248, 1774) **V** |
| What it deletes | `Delete Them` ⇒ `runner.deletePreSwitchSnapshots(outcome)` ⇒ each pair (`removeSnapshotPair`, far ones under the bookmark's scope — prefix-match `url.path.hasPrefix(picked.path)`) + each qualifying aside folder whole (`removeAsideCopy` re-qualifies first). ONE button for both kinds (VX-265) | `PostureSwitchModel.deleteOldBackups:652-656`; `PostureSwitch.swift:1429-1432, 1959-1991` (pairs 1959-1974, folders 1979-1991) **V** |
| What it says | Title "Delete the backups Variorum made before today?"; body: counts, then **"They still open through your Apple account, and they always will."** — asserted for every listed pair, though exposed-era pairs carry no `apple` (VX-263) and Castle-era pairs never do; "Variorum can only delete its own backups…" (overclaims: its own pairs in other/unplugged folders are skipped — VX-210) | `PostureCopy.swift:543-579` **V** |
| Does it return? | **Never.** `.offer` is a one-shot phase; `Keep Them` → `.closed`; no persisted "owed" flag; a later Castle entry would list again only pairs not under the then-new key | `PostureSwitchModel.swift:647-661`; QUESTIONS/VX-210 comment (F-U3-4) **V/I** |
| Marker | cleared at the END of step 6, i.e. after the offer's listing but before the choice; RotationMarker.Step still has an `.offer` case that no road writes | `PostureSwitch.swift:1235-1249`; `CorpusRotation.swift:150-153` **V** |

---

## 4. Store-id aliasing (two different library FILES with one `storeID`)

A library's `storeID` lives in its key file, is stable across re-keys and is copied verbatim into every pair,
hand-off and aside copy (`StoreIdentity.swift:3-18`, `StoreKeyEnvelope.swift:44-49`) **V**. Only "Start a New
Library" and the plaintext adoption road mint a new one. Everything below is keyed by `(scope, storeID)` and so
is SHARED by every copy of the library, whichever one currently sits at the store path:

| State | Key / name | Written by | Read by | Collision consequence | Evidence |
|---|---|---|---|---|---|
| Silent library-key item | Keychain `io.lduarte.Variorum.store-key` / `<scope>-<storeID>-bound` | open-mint, R1-M3 re-land, custody moves, `landCustody` | route `effectiveGate` (custody SHAPE), lobby second look, Apple landing arm | **VX-209**: an older copy's key lands here; the brought-back Castle copy then reads "silent ⇒ Standard-waiting" (corner 45) | `Core/…/StoreKey.swift:265-267, 273-304`; `StoreLaunchGate.swift:405-436` **V** |
| Gated (Touch ID) item | `<scope>-<storeID>-biometric` (+ legacy `<scope>-biometric`) | custody moves, `landCustody` | lobby, `pairIsProvablyForeign` gate | deleted when a Standard copy is adopted (`landCustody` `.auto` arm deletes gated) — the Castle copy's Touch ID road is gone | `StoreKeyGuard.swift:229-232, 322-330` **V** |
| Per-store dials | `UserDefaults` `variorum.protection.<scope>.<storeID>.alwaysAsk/.relockIdleMinutes` | pane, plaintext adopt, Start New | `effectiveGate`, reconcile | the brought-back copy inherits whatever the last copy's session saved | `StoreProtection.swift:261-264, 283-298, 339-342` **V** |
| Legacy at-open mode read-through | `…<storeID>.mode` else the scope's `…mode` | 13p era; retired by §11 | `Posture.derive` arm 3 | the SCOPE-level legacy key is read for any store id that never wrote its own keys | `StoreProtection.swift:304-323` **V** |
| Switch-pending flag | `…<storeID>.switchPending` | runner (VX-202 belt c) | route landing arm, reconcile | a restored copy shares it; cleared at ready when no marker (VX-201 R1-1) | `StoreProtection.swift:372-383`; `ProtectionController.swift:1495-1499` **V** |
| This-Mac-only flag | `…<storeID>.thisDeviceOnlySwitch` | VX-110 road | resume's Done | shared by copies | `StoreProtection.swift:390-401` **V** |
| Sync custody (M, C, identity) | Keychain `<scope>-<storeID>-sync` (silent/gated) via `SyncCustodyScope(scope, storeID)` | enrollment, rotation, follow | route "enrolled?" (`syncCustodyPresent`), reconcile | an older copy with the same id inherits this device's ENROLLED status (indeterminate posture ⇒ acts by custody shape, Posture arm 2) and its CURRENT M/C — so the rotated-keys follow (custody corpus id vs the vault's) sees nothing owed although the copy's key file predates the rotation (13x R1-BLOCKER's blindness, closed only for the `apple` case by `castleKeyFileAppleOpenable`); the collision rule leaves M/C/identity "untouched" by design (`CustodyCollisionRule.swift:11-14`); a DIFFERENT id (any copy on a new Mac, any plaintext adoption) enrolls afresh — VX-100's second passphrase ask | `StoreLaunchGate.swift:126-130`; `13x-ladder-round1.md:17-50`; VX-100 **V/I** |
| Legacy 13p escrow item | `io.lduarte.Variorum.store-key-escrow` / account = `storeID`, synchronizable | 13p only (retired) | migration delete leg | named by store id in iCloud Keychain — all copies, all Macs | `StoreKeyGuard.swift:223, 450-457` **V** |
| iCloud key A | `<scope>-apple-key` (per SCOPE, not per store id; never deleted) | Apple arm, Leave Castle | Apple road | not store-id aliasing but wider: every Standard-era key file of every library on the iCloud account opens under the same A forever | `AppleKeyCustody.swift:15-18, 135` **V** |
| Restore hold | `variorum-restore-hold.json` per LOCATION | adoption | sync/ceremony gates | not by id — survives a manual Finder restore (stale) or can be missed by one (none written) **I** | `LibraryRestoreHold.swift:7-19` **V** |
| Rotation marker | `sync_state.rekey_in_progress` INSIDE the store file | runner | engine (refuses rounds), resume | travels WITH copies: the step-6 fresh snapshot is taken while the marker reads `.snapshot` (written 1235-1238, snapshot 1242, cleared 1249) ⇒ restoring that snapshot lands a library with a pending marker (§8 S-9) **V/I** | `PostureSwitch.swift:1235-1249`; `CorpusRotation.swift:194-229` **V** |
| Reminder/nudge stamps | `variorum.protection.<scope>.<leaf>` (per SCOPE) | controller | nudge/reminder policies | shared by every library of the scope (even different store ids) | `StoreProtection.swift:405-412` **V** |
| iCloud Drive offer mark | `variorum.backup.iCloudDriveOffered.<variant>` | offer | offer | per variant, not per library | `ICloudDriveOffer.swift:markKey` **V** |
| Backup bookmark, `.md` opt-in, lock-time pending list, backup log | `variorum.backup.*` (device-local, per app domain) | Data Safety | backup run | shared across every library that ever sits at the store path | `BackupDestination.swift:34`; `MarkdownInsurance.swift:65`; `StoreBackup.swift:621` **V** |

The custody-collision rule (`Core/…/CustodyCollisionRule.swift:26-56`) decides only "same key / different key /
none" for the bound item — it has no notion of WHICH copy's posture the store id should now carry, and the
gate then derives posture from the custody SHAPE that the collision write just produced **V**.

---
## 5. Churn statistics

Method: `git log --follow` per file over the 53 source files named in the brief (no tests) on `63ec98c1`; the
union de-duplicated by hash. All dates are author dates. **V** throughout (scratch output, not committed).

### 5.1 Totals

| Measure | Value |
|---|---|
| Unique commits touching the area | **213** (2026-07-06 → 2026-10-13) |
| Per month | Jul 4 · Aug 65 · Sep 82 · **Oct 1–13: 62** (≈4.8/day vs Sep's ≈2.7/day) |
| "Fix-like" subjects (fix / ladder / round / R-n / BLOCKER·MAJOR·MINOR·NIT / finding / correct / red on main) | **111 of 213 (52%)** — Aug 33/65 · Sep 36/82 · **Oct 40/62 (65%)** |
| Busiest days | 08-30 (33, 13p + 13p-fix + pre-13u Act 9) · 09-05 (27) · 09-06 (24) (pre-13x) · 10-07 (18, 13x) · 10-13 (16, VX-201 run) · 10-08 (16, 13x close + VX-99) |
| Area size (53 files, lines) | 2026-08-01: 300 · 08-29: 4,869 · 09-01: 10,044 · 09-08: **19,758** · 10-05: 20,693 · 10-09: 23,873 · **10-14: 24,933** |

### 5.2 By phase / ticket (subject-line classification, first match wins)

| Era | Commits | Dates | What it built |
|---|---|---|---|
| Phase 7/8/9 (A1 backups, A4 dev fence) | 4 | 07-06 → 07-10 | `StoreBackup`, `StoreLocation`, the recoverable open |
| 14b / 14c / 14d (E2EE sync keys, vault) | 15 | 08-04 → 08-16 | `Crypto/*`, `EncryptionSession`, `EncryptionKeychain`, the 14c rekey marker |
| 13e/13l (Keychain off-main; the second destination, integrity, log, runbook) | 8 | 08-18 → 08-24 | `BackupDestination`, `BackupRetention`, `BackupLog`, Data Safety pane |
| **13p / 13p-fix / pre-13u Act 9–10 / 17h** (whole-store encryption, envelope, lobby, custody law) | **42** | 08-30 → 08-31 | `StoreKeyEnvelope`, `StoreBinding`, `StoreLaunchGate`, `StoreKeyGuard`, `ProtectionController`, `KeychainCustody` |
| **pre-13x** (postures: format-2 key file, per-store-id custody, Standard/Castle, switch runner, follow, offer, runbook rewrite, 2 ladder rounds + F3) | **65** | 09-04 → 09-07 (+1 on 09-22) | `StoreIdentity`, `AppleKeyCustody`, `PostureSwitch*`, `PostureCopy`, `ProtectionMigration`, `KeyDoorModel`, `CorpusRotation` |
| 13y / 17l / 17m / run A (A2) | 10 | 09-21 → 09-23 | key proof v2, Re-link Apple account, presenter fix, passphrase floor |
| 18k / 18l / 18o | 7 | 09-25 → 09-30 | backup single-flight, own-names-only listing (C7), future-stamp rule |
| other phases touching the files (13i-d, 13r calm asks, 17y, 13o, 13s, 13n-b) | 8 | 10-02 → 10-09 | iCloud-offer cadence, search-index derived tables, MCP grant tables in the export |
| **13x (VX-6)** — portability: classifier, hand-off, adoption, hold, restore list, 4 ladder rounds, W-1..W-4 | **24** | 10-06 → 10-08 | `Library*`, `BackupRestoreCandidates`, `CustodyCollisionRule`, `LocalMachineryRecreation` |
| VX-80 (follow crash window) | 2 | 10-07 | wrong-key recovery lobby |
| **VX-99** (Castle Replace-All-Keys Apple copy) + 3 ladder rounds + post-merge | **11** | 10-08 | posture decisions moved onto the vault in hand |
| VX-140 (Touch ID re-prompt) | 1 | 10-10 | lobby auto-ask |
| **VX-201 run** (VX-110/202/203/204/206/208/209) | **16** | 10-13 | belts a/b/c, This-Mac-only road, aside-copy lister, confirm line |

Ticket ids in subjects: VX-6 ×21, VX-99 ×11, VX-110 ×10, VX-202 ×7, VX-209 ×4, VX-203 ×4, VX-80 ×3, VX-201 ×3,
VX-206/204/140 ×2, VX-83/7/214/208/124/101/100 ×1. Phase tags: pre-13x 65 · 13x 29 · 13p 26 · pre-13u 18 · 14b 17 ·
14c 7 · 13s 5 · Phase 8 4 · 13y 4 · 13p-fix 4 · 18o/18k/17h/13r 3 each.

### 5.3 Hotspots (commits per file, `--follow`; lines now)

| File | Commits | First → last | Lines now | Lines at 09-01 → 09-08 → 10-05 → 10-14 |
|---|---|---|---|---|
| `Shared/ProtectionController.swift` | **51** | 08-30 → 10-13 | 2,154 | 1,039 → 1,926 → 1,984 → 2,154 |
| `Shared/PostureSwitch.swift` | **43** | 09-05 → 10-13 | 2,024 | 0 → 1,552 → 1,570 → 2,024 (+454 in Oct) |
| `Shared/AppBootstrap.swift` | 36 | 07-06 → 10-13 | 1,120 | 512 → 969 → 979 → 1,120 (191 on 08-29) |
| `Shared/PostureCopy.swift` | 35 | 09-05 → 10-13 | 1,105 | 0 → 693 → 861 → 1,105 |
| `Mac/…/ProtectionPane.swift` | 34 | 08-30 → 10-13 | 1,530 | 807 → 1,322 → 1,484 → 1,530 |
| `Shared/EncryptionSession.swift` | 32 | 08-04 → 10-13 | 785 | 714 → 760 → 765 → 785 |
| `Shared/EncryptionKeychain.swift` | 25 | 08-04 → 09-06 | 880 | — |
| `Shared/StoreProtection.swift` | 24 | 08-30 → 10-13 | 940 | 660 → 906 → 906 → 940 |
| `Shared/StoreLaunchGate.swift` | 22 | 08-30 → 10-13 | 1,073 | 362 → 975 → 975 → 1,073 |
| `Shared/PostureSwitchModel.swift` | 18 | 09-05 → 10-13 | 857 | 0 → 631 → 644 → 857 |
| `Mac/…/DataSafetyPane.swift` | 15 | 08-24 → 10-07 | 626 | — |
| `Shared/StoreBackup.swift` | 15 | 07-07 → 09-30 | 798 | 481 → 652 → 798 → 798 |
| `Crypto/KeyVaultClient.swift` · `Shared/StoreKeyGuard.swift` | 13 · 13 | 08-04/08-30 → 09 | 727 · 458 | — |
| `Core/…/StoreKey.swift` · `Mac/…/DataSafetyCopy.swift` | 10 · 10 | 08-30/08-24 → 09-04/10-08 | 509 · 389 | — |
| `Shared/LibraryOpenCopy.swift` | 9 in 7 days | 10-07 → 10-13 | 203 | — |
| copies-area cores (`LibraryAdoption` 6 · `LibraryOpenModel` 7 · `LibraryOpenDoor` 6 · `DataSafetyModel` 8 · `RestoreHoldModel` 4 · `LibraryClassifier` 3 · `BackupRestoreCandidates` 2 · `LibraryRestoreHold` 2 · `LibraryHandOff` 2 · `LibraryAsideCopies` 1) | 41 | 10-06 → 10-13 | ~2,700 | all born 10-06/07 |

Reading: the custody/posture brains (ProtectionController, PostureSwitch, StoreLaunchGate, StoreProtection) carry
~140 commits and ~6,200 lines and are still growing (PostureSwitch +29% in October); the copies brains are young
(one week) but every one of them was re-touched by a ladder or a VX ticket within days of birth.

### 5.4 Fix / ladder records skimmed (findings counts)

| Record | Findings (B/M/m/n or ids) | Area-relevant ones |
|---|---|---|
| `notes/plans/phase-13p-fix-dp-keychain.md` | R1 0/5/4/4 (14) · R2 0/1/9/4 · R3 0/3/5/6 | R1-1 custody delete on write-success alone; R1-4 wrong diagnosis; R2-2/R3-2 "nothing was altered" lie; R2-7 delete-then-add window; R3-1 a test overwrote her LIVE E2EE custody; R3-5 deletes drop status; R1-14 Developer-ID access groups |
| `notes/plans/pre-13x-design-review.md` (P1–P9) + `…-final-review.md` (32 scenarios, R1–R9) | design findings | 2C: one key file per folder overwritten at re-key (→ fp-named files); **P6(b) "a store re-key mints a NEW store ID" — not adopted** (the id is "stable across re-keys", `StoreIdentity.swift:4-5`); scenario 14/15 assumed same-Mac restores "covered" |
| `notes/plans/pre-13x-ladder-round-1.md` / `-2.md` | R1 1/3/8/5 · R2 0/0/4/4 | MAJOR-2 offer made with no fresh snapshot; MAJOR-3 `readOrMint` minted a 2nd A; MINOR-3 design says old key file never deleted, follow deletes it; MINOR-5 a second engine built without facts; NIT-5 "never changes a backup" vs pruning; MINOR-N1 heal fires on a mint; MINOR-N2 pause flag instance-scoped vs road-scoped |
| `notes/plans/run-a-custody-text-loss.md` (rows 9–16 custody) | ladder 0/1/1/2 → 0/1/0/1 → 0/2/0/1 (text-loss doors) | row 11 the Replace-All-Keys ceremony had NO presenter from the main window; row 15 an unreadable vault read as "no words" ⇒ a second secret minted |
| `notes/plans/13x-ladder-round1..4.md` + plan walk | R1 1/1/5/4 · R2 0/0/1/2 · R3 0/1/1/1 · R4 0/0/1/1; W-1..W-4 | R1-BLOCKER same-Mac Standard-era pair onto a Castle account ⇒ live library Apple-openable (custody shape ⇒ posture); R1-MAJOR hand-off had no door; `try?` swallowed the hold write; hold gated only the scheduler; R2-1 adoption racing an in-flight open; **R3-1** a read-only consult rewrote the picked file / the landing dropped the `-wal`; R3-2 gates read a projection; W-1 `StoreBinding.lock` left a `-wal`, so the ready-road adoption could never act; W-3 her Pro's live key file Apple-wrapped under Castle (→ VX-99) |
| `fixes/vx-80-castle-follow-recovery-door.md` | 1 incident | swap→custody crash window; the marker lives INSIDE the encrypted store it would resume; recovery lobby keyed only on empty custody |
| `fixes/vx-99-*.md` (record, R1–R3, post-merge) | R1 0/1/1/1 · R2 1(pre-existing)/4 m · R3 1/3 m · PM 0/0/0/3 | key-file Apple decision used the acting posture, vault side used the vault — two deciders; 13 of her backup pairs carry the stray `apple` wrap forever; a 13-row class sweep of every `apple` writer (row 7 "route landing: SAFE" is the arm VX-209 later broke) |
| `fixes/vx-106-posture-harness-standard-world.md` | 1 + R1 0/0/1/2 | the harness's default Standard world was account-inconsistent (key file `apple` + vault none) |
| `fixes/vx-191-encryption-audit.md` + `vx-191-audit/{A,B,C}` | 11 rows + B1a–B6c + C-1/C-2 + Q1–Q11 | §O.3 (VX-202), VX-110, B1d (VX-203), C-1 (VX-204), C-2 (VX-207), B3c (VX-208), B2c (VX-209), B1e (VX-210), Q11 (VM-15), Q10 (VX-211), Q3 (VX-212); **B1f** folder key files survive Delete; **B6c** leftover Standard-era key file + "current file chosen by mtime" |
| `fixes/vx-201-castle-prelaunch-fixes.md` | F1–F7 · F-U2-0..8 · F-U3-1..7 · F-U4-1..6 · F-U5-1..8 · ladder R1 0/0/2/2 · R2 0/0/0/2 · walk W-1 | F-U5-6 `currentEffectiveGate` is a read that writes; F-U5-5 resident key read as custody shape; F5 `landCustody` ignores delete results; F-U2-5 (→VX-235); F-U3-2 13p escrow-era copies invisible to the key-file rule; R1-1 per-store-id switch flag outlives its marker (a restored copy shares it); W-1 (→VX-263) |

---

## 6. Ticket table (Linear, read-only; queries: Castle, custody, posture, backup, restore, key file, passphrase, follow, vault, Keychain, library, lock, encryption, sign, iCloud + project "Castle & backups before launch")

The board starts 2026-10-06; earlier bugs live only in the ladder records (§5.4).

| Id | Title (short) | State | One-line root cause |
|---|---|---|---|
| VX-6 | 13x — Library portability | Done | (phase) the doors in §2 |
| VX-64 | vault-bootstrap can't open an encrypted store | Done | tooling took the bare `openStore` road (ambient Keychain custody) instead of the lobby's key-file road |
| VX-80 | Castle follow crash window strands the library | Done | non-atomic swap→custody; the resume marker sits inside the encrypted store; the recovery lobby keyed on "empty custody" only |
| VX-81 | SwiftUI assertion crashes the re-key reopen | Backlog | the `.ready` tree torn down/rebuilt under a live sheet (I) |
| VX-99 | Pro library Apple-openable after Castle | Done | key-file Apple copy decided by `entersCastle`/acting posture while the vault side read the account — two deciders |
| VX-100 | Copied library asks the passphrase twice | Backlog | sync custody keyed per store id; a copy never carries it; the adoption's secret is not carried to enrollment |
| VX-101 | Open Library should offer backup/previous locations | Backlog | copies live in places no picker or list points at |
| VX-102 | Landing inherits source flags; stray sidecar at empty slot | Backlog | file-copy mechanics carry the source's state; the empty-slot arm doesn't sweep |
| VX-104 | Drill: older library via Open Library end to end | Backlog | coverage gap (pieces proven alone) |
| VX-106 | Two PostureSwitchTests red since 13x | Done | harness default world account-inconsistent; the closeout run omitted the suite |
| VX-107 | Double-crashed resume loses the other-device sentence | Todo | a fact held in memory, not on the marker |
| VX-108 | Switch doors gate on the local posture reading | Todo | stale local reading instead of the vault in hand |
| VX-109 | `CorpusRotation.begin` re-fetches the vault | Todo | CAS against its own second fetch, not the caller's (check-then-act) |
| VX-110 | Use Castle runs the local road for a lapsed-session enrolled library | Done | gate on the act/session, not the library's enrolled shape; + the Apple arm's silent revert (F-U2-1) |
| VX-113 | Changed-elsewhere refusal names the change | Todo | refusal copy names the wrong cause |
| VX-114 | Mac literals in Shared `LibraryOpenCopy` | Todo | Mac-only words in a both-platform file |
| VX-140 | Lock re-prompts Touch ID relentlessly | Done | the auto-ask fired per view mount/occasion, not per lock occasion |
| VX-152 | `AppBootstrap.lock()` not reentrant | Backlog | two lock triggers race (no guard) |
| VX-191 | Pre-launch encryption & Castle audit | Done | (audit) §5.4 |
| VX-201 | Run: Castle pre-launch fixes | Done | (run) §5.4 |
| VX-202 | Re-key reopen re-saves L′ into the silent item | Done | unordered background custody write vs the move's delete |
| VX-203 | Castle offer misses Previous Libraries / safety copies | Done | a later feature's copies not registered with the earlier cleanup's listing |
| VX-204 | Field guide: "everything is encrypted" | Done | copy overclaim (plain envelope travels) |
| VX-206 | Entering Castle leaves Settings on General | Done | the re-key reopen rebuilds Settings at its default pane |
| VX-207 | MCP AI fence keys on server-rewritable plain columns | Parked | trust in unauthenticated plain columns |
| VX-208 | One line: delete pre-Castle `.md` exports | Done | plaintext copies outside any cleanup |
| **VX-209** | A Castle library silently becomes Standard after Open/Restore — even on the way BACK | **Needs Lillian** | posture inferred from this Mac's custody SHAPE for a store id every copy shares; the route's read lands an Apple copy (V: `LibraryOpenModel.swift:509-544`, `StoreLaunchGate.swift:405-427`, `StoreProtection.swift:101-109`) |
| VX-210 | Offer skips other/unreachable folders; never returns | Todo | one-shot offer over a point-in-time, bookmark-only listing |
| VX-211 | Passphrase: length floor, no strength check | Todo | policy |
| VX-212 | Rotation poison row has no owner | Todo | a rotation can never complete if one row is sealed under an unknown key |
| VX-213 | Encryption tidy-ups (retire the leftover Standard-era key file …) | Todo | leftover artifact whose purpose was never written down — conflicts with VX-263 |
| VX-224 | Lock with Settings open leaves a stub window | Done | Settings scene's non-ready arm |
| VX-228 | Corner 45 redesign | Todo | "silent item ⇒ Standard-waiting" cannot tell a previously-Castle store id |
| VX-233 | Posture drill harness rot | Todo | `@Dependency(\.date)` unscoped on a detached ready-path task; the drill unrun since 09-07 |
| VX-235 | Crash between `.rekeyLibrary` marker and the new key file | Todo | marker written before the artifact it names; no resume arm |
| VX-239 | Idle pane-hosted ceremony comes back hidden after lock | Todo | presentation state lost across the lock rebuild |
| VX-240 | "Open the main window first." during a re-key/restore | Todo | Settings' non-ready arm renders a wrong instruction during `.opening` |
| VX-243 | Follow sheet presents on two windows | Todo | two hosts bind one model (row 11's rule applied to the ceremony only) |
| **VX-263** | Pre-Castle backups unopenable after entering Castle from the exposed state (W-1) | Todo | copies' key files frozen with no wraps; the only wrap of that key sits in the leftover live-folder file, which no list consults |
| VX-264 | Castle wording + signed-out screen (#216) | Todo | copy rulings (incl. VX-209's confirm line made concrete) |
| VX-265 | Separate delete choice for older libraries | Todo | one button deletes two kinds of copies (backups + possibly a different library) |
| VX-266 | Castle & backups before launch (flagship) | Needs Lillian | — |
| VM-15 | Unfollowed sibling phone (+ its iCloud device backup) stays Apple-openable | Backlog | posture change propagates only when each device opens; device backups are uncatalogued copies |
| VX-14 · VX-31 · VX-53 | "open without Variorum" recipe · 18b restore across devices · rotation at scale | Parked · Backlog · Backlog | future work |

Open in the area right now: **17 in project VX-266** (VX-107/108/109/209/210/211/212/213/228/233/235/239/243/263/264/265
+ the flagship) plus VX-100/101/102/104/113/114/152/240, VM-15.

---
## 7. Failure-class taxonomy (root causes, not symptoms)

Inputs: the 46 tickets of §6 plus ~150 ladder/audit/run findings of §5.4. A finding may sit in two classes; counts
are of the listed members (traceable), not of every finding ever written.

| # | Class | n | Members (ids) | The STRUCTURAL cause — the design choice that keeps producing it |
|---|---|---|---|---|
| K1 | **Posture inferred from a local proxy** (this Mac's custody SHAPE, the acting reading, the session) instead of the library's own durable fact or the authority in hand | 13 | VX-209 · VX-228 · 13x R1-BLOCKER · VX-99 (key-file side) · VX-99 R1-MAJOR · VX-108 · VX-110 (+F-U2-1) · VX-191 B2c · F-U5-5 · F-U2-4 · F-U2-2 · run-A row 15 · pre-13x MAJOR-3 | Posture is "DERIVED, never a setting … stored nowhere" (`StoreProtection.swift:19-30`) from five inputs with a precedence (`Posture.derive:85-98`): vault word › enrolled custody shape › legacy mode › key file › default. Every site gathers a different subset (`leavesCastle` passes `.unknown`/`enrolled:false`; the route passes custody presence; the controller the vault). Corner 45 makes the custody SHAPE an input (`localReading:101-109`: silent ⇒ Standard) while the adoption and the reconcile make it an OUTPUT of the same decision (`landCustody` → `effectiveGate` → `saveAuto`) — a feedback loop. Nothing records "this library/store id IS Castle". |
| K2 | **Per-store-id state aliased across copies** (N files, one custody slot) | 6 | VX-209 · VX-100 · 13x R1-BLOCKER · VX-201 R1-1 (switch flag shared by a restored copy) · F-U2-3 · VX-201 F5 | The store id is minted once and copied into every pair, hand-off and aside folder, and is "stable across re-keys" (`StoreIdentity.swift:4-5`); the design review's P6(b) "a store re-key mints a NEW store ID … old ID ↔ old key" (`pre-13x-design-review.md:358-359`) was not built. Keychain bound/gated/sync items, dials, the switch/This-Mac-only flags are all keyed `(scope, storeID)` (§4). The custody-collision rule reconciles only WHICH KEY sits in the bound item (`CustodyCollisionRule.swift:49-56`), never posture, dials or flags. |
| K3 | **Copies frozen at write-time wraps drift from the library's later posture** | 10 | VX-263 · VX-99's 13 Apple-wrapped pairs · VX-203/B1d · B1f · VM-15/Q11 · VX-208/B3c · F-U3-2 (13p escrow-era copies) · F-U3-5 (pre-Castle plaintext export) · C4 hand-offs (never offered) · pre-13x design §2C (the earlier opposite failure: one file per folder overwritten) | Decision 11: a copy's key file is write-once (`StoreBackup.swift:304-325, 583-594`); A is never deleted (`AppleKeyCustody.swift:15-18`); no catalog of copies exists. A posture change can therefore reach an old copy only by DELETING it, and only if a listing finds it; and a copy written before any wrap existed (exposed era) can never gain one. Entering Castle deliberately leaves the old key file in place (`PostureSwitch.swift:38-39`) — the only artifact that ties the old key to a secret. |
| K4 | **Copy discovery fragmented** — each road scans its own subset of places with its own name rules | 9 | VX-203 · VX-210/B1e · VX-101 · VX-263 (list ignores other key files) · restore list = container only (`DataSafetyPane.swift:137-143`) · library-missing "Restore" = Finder reveal · 18k C7 (foreign `variorum-backup-a1-*` / drill files taken as "newest" and sent to her second folder) · W-1 walk · design scenarios 14/15 marked "covered" | ≥6 independent directory scans (`existingBackups`, `BackupRestoreCandidates.gather`, `appleOpenableAsideCopies`, `Leaves.live.preSwitchSnapshots`, `LibraryClassifier.classify*`, `MarkdownInsurance.existingExports`) and 3 copies of the stamp parser (`StoreBackup.date(fromBackupURL:)`, `BackupRestoreCandidates.backupDate`, `LibraryClassifier.backupNameFingerprint`). Each new copy kind (13x aside/safety, hand-offs) is invisible to the older consumers until a ticket adds it. |
| K5 | **A read that writes** (healing placed on read paths) | 8 | F-U5-6 (`currentEffectiveGate` lands an Apple copy — completes VX-209 in-session) · `StoreKeyKeychain.load(.none)` → `establish` writes a key file + migrates legacy items (`StoreKey.swift:278-286`) · `ensuredEnvelope` sets a foreign key file aside inside reconcile (`ProtectionController.swift:1129-1142`) · 13x R3-1 (a read-only open rewrote the picked `-shm`, folded its `-wal`) · 13x R1 NIT (rw fallback opened the picked source writable) · the lobby's vault road writes a fresh local copy after unlock (`StoreLaunchGate.swift:975-990`) · pre-13x MAJOR-3 (`readOrMint` on a reconcile read) · MINOR-N1 | Convergence was built as "heal on every consult" (route, reconcile, custody load) to avoid ceremonies. Consequence: read ORDER and read COUNT are state transitions; any new caller of a read (13x's `landCustody`, `lock()`, the phone's relock coordinator) silently becomes a custody/key-file writer. |
| K6 | **Crash windows between non-atomic multi-store steps; markers without a resume arm or stored where the resume can't reach** | 12 | VX-80 · VX-235/F-U2-5 · VX-107 · adoption 4→5 (D≠C, §2.4) · adoption 3½→4 (old library held) · VX-201 R1-1 (flag before marker) · pre-13x BLOCKER-1 (straggler row) · 13p-fix R2-7 (gated delete-then-add) · VX-212 (rotation never completes) · F-U5-7 (same-second stamps) · VX-152 (lock reentrancy) · §8 S-9 (marker rides the step-6 snapshot) | One act spans the store file, key files, two Keychain families, UserDefaults and the vault with no journal. Recovery facts live in three places that can disagree: the rotation marker INSIDE the encrypted store (`sync_state.rekey_in_progress`, `CorpusRotation.swift:194-229`), the switch flag in UserDefaults by store id, the hold marker beside the store by location. |
| K7 | **Unordered concurrent custody writers (races)** | 8 | VX-202 · 13x R1 MINOR (lobby Apple re-probe during adoption ⇒ two bindings) · 13x R2-1 (adoption over an in-flight open) · VX-109 · VX-152 · pre-13x MINOR-N2 · 13x R1 MINOR (ceremonies' direct engine drives bypass the hold) · VX-201 F4 | Custody/key-file writes are reachable from ≥7 independent tasks (route, ready housekeeping, R1-M3 re-land, lobby probe, runner, adoption, reconcile); serialization was added per incident (custody queue, `switchInProgress`, `suspendForAdoption`, `awaitOpen` loop, `switchPending`). |
| K8 | **Custody law enforced on writes only; results discarded; second write paths skip the handover rule** | 8 | 13p-fix R1-1 · R2-3 · R2-4 · R3-2 · R3-5 · VX-201 F5 + `landCustody`'s `_ =` saves/deletes (`LibraryOpenModel.swift:533-543`) · VX-201 R1-4 · 13x R1 MINOR (`try?` swallowed the hold write) | Keychain ops return `Bool`/`OSStatus`; the three-step `CustodyHandover` (`KeychainCustody.swift:211-269`) is opt-in per call site, and the 13x adoption writes custody through raw save/delete with results dropped ("no new write path" was read as "no handover"). |
| K9 | **Test-harness drift; tests reaching real state; the dangerous combination uncovered** | 9 | VX-106 · VX-233 · 13p-fix R3-1 (a test overwrote her live E2EE custody) · R3-4 · VX-99 (no test of Replace All Keys on a Castle account; the harness's A always readable) · 13x R1-BLOCKER ("no drill covers it") · VX-104 · the 13x closeout run omitted `PostureSwitchTests` · F-U5-8 (an ad-hoc scratch harness) | Truth lives in Keychain/iCloud/UserDefaults/files; tests script it through seams (`StoreLaunchGate.scripted`, in-memory backings) whose worlds can be self-inconsistent (key file vs vault vs custody). The end-to-end drills are env-gated and need the exclusive stage, so they go unrun for weeks (VX-233: last green 09-07). |
| K10 | **Copy (UI text) overclaims or describes the design instead of the code** | 19 | VX-204/C-1 · F-U4-1 · offer "they always will" (VX-263) · offer "only its own backups" (VX-210) · pre-13x NIT-5 · 13x R1 failure lead · 13x R4 MINOR · R4 NIT/W-4 · VX-113 · F-U2-3 · F-U2-6/F-U4-3 · Data Safety "a Finder operation, not a button" · runbook's iCloud-offer timing · `deadEnd`/`.unreadable` name `variorum-keys.json` · `bareStoreRefusal` when a key file DID come · restore body "opens the same way your library does" · second look "your current passphrase or Touch ID" under Standard · "your current passphrase (online)" on pre-rotation pairs · VX-114 | Sentences are static constants encoding the DESIGN's intended state ("written with it and never rewritten", "with the keys of its day"); their truth depends on runtime facts (copy era, account presence, folder reachability, posture) the constants never receive. |
| K11 | **Presentation hosting across reopen/lock: no host, two hosts, wrong pane, silent door** | 11 | run-A row 11 (no presenter) · VX-243 (two) · VX-206 · VX-239 · VX-240 · VX-224 · VX-81 · 13x W-2 · F-U2-7 · 13x R1-MAJOR (hand-off brain without a door) · 13x R1 NIT (Sync now silent under hold) | Ceremony/follow models live on the controller to survive the re-key/adoption reopen, while every lock, re-key and adoption sets `state = .opening` and tears down the `.ready` view tree (`AppBootstrap.adoptLibrary:761-787`, `rekeyLibrary:837-874`); host rules were added per model (row 11's open-time pick for the ceremony only). |
| K12 | **Duplicated brains that disagree** | 8 | VX-99 (vault-side vs key-file-side Apple decision) · pre-13x MINOR-5 (a second engine without facts) · 13p R2-M1 (phone composition lacked the Mac's hooks) · `listPreSwitchPairs` ceremony (`entersCastle`) vs follow/resume (`wasStandardShaped`) (§3) · 3 stamp parsers · two "Restore from a Backup" doors · pre-13x MINOR-3 (design vs follow on the old key file) · `sourceGate` as a mutated copy of the launch gate | Rules are "restated from their owners rather than re-invented" (`LibraryClassifier.swift:25-31`) to keep layers independent; restatements drift and each fix touches one copy. |
| K13 | **Leftover artifacts with an unrecorded purpose** ("never delete, set aside" without an owner) | 8 | VX-213 ⟂ VX-263 (the leftover key file "opens nothing current" vs "the only route to every pre-Castle backup") · VX-191 B6c · B1f · `.stale-<epoch>.json` files never pruned · Previous Libraries / adopt safety copies never pruned · `removeAppleWrappedCopy` dead · `RotationMarker.Step.offer` never written · F-U3-3 (a set-aside copy may be a DIFFERENT library) | The doctrine "never deleted: its wraps are somebody's recovery legs" (`StoreIdentity.swift:12-18`, `LibraryAdoption.swift:23-27`) keeps everything but records no reason, owner or expiry; later features must guess whether a leftover is load-bearing — and guesses differ by ticket. |

**Cross-cutting reading.** K1+K2+K5 are one mechanism seen three ways (VX-209 needs all three: the shared store id
puts an older copy's key in the silent slot; corner 45 reads that slot as the posture; a read lands the Apple copy).
K3+K4+K13 are the copies problem (VX-263, VX-203, VX-210, VX-213, VX-265 all fall here): copies are immutable,
uncatalogued and kept forever, so every posture change needs a new scan rule and a new sentence. K6+K7+K8 are the
custody-transaction problem. K9–K12 are the cost of K1–K8 (each fix needs a harness world, a sentence and a host).

---

## 8. Surprises (fragile, duplicated, contradictory or dead; doc-vs-code)

| # | Surprise | Tag | Evidence |
|---|---|---|---|
| S-1 | **The design rule "with no custody, every fingerprint key file beside the store is tried newest-first, the one whose unwrapped key opens the file wins" is not implemented.** Every road reads ONE file — `locate`'s newest-**mtime** pick (lobby, route, classifier, aside qualifier). | **D≠C** V | `pre-13x-postures-design.md:369-372`, ruling 1 at `:1316`; `StoreKeyEnvelope.swift:482-497`; `StoreLaunchGate.swift:894` (`loadEnvelope` → `loadCurrent`); no other caller of `keyFileURLs` tries several (grep) |
| S-2 | **The adoption's documented crash window (step 4→5) routes `libraryMissing` only under Castle.** Under Standard an absent store + moved-aside key files routes `.open`, and `resolveStoreKey` mints a FRESH EMPTY library under a NEW store id at the store path — with the hold marker beside it (banner: "your library as of …"). | **D≠C** I | `LibraryAdoption.swift:39-42` vs `StoreLaunchRoute.resolve:344-348`, `Posture.localReading:102` (no key file ⇒ Standard), `AppDatabase+Dependency.swift:173-195`, `StoreKey.swift:297-304` |
| S-3 | **`removeAppleWrappedCopy` has no production caller** — "Entering Castle: the iCloud copy goes" is implemented by minting a new key file and keeping the old one (with its `apple` copy) beside the store; only the FOLLOW deletes the old file. | **D≠C** V | `StoreKeyEnvelope.swift:281-284, 315-322`; tests only (3 sites); `PostureSwitch.swift:38-39, 1019-1045, 1248` |
| S-4 | **Two rules decide whether the Castle offer is made**: the ceremony lists whenever it `entersCastle` (exposed libraries included — whose pairs carry no `apple`, yet the body says "They still open through your Apple account, and they always will"); the follow and the resume require the old key file to carry `apple`. | V | `PostureSwitch.swift:811` vs `963, 981, 1000, 1672, 1687, 1769`; `PostureCopy.swift:562, 568` |
| S-5 | **`landCustody` drops every custody result and skips `CustodyHandover`'s verify-then-delete** (the 13p-fix rule written after a key was lost): e.g. `.biometric` ⇒ `saveGated` then `deleteAuto` even if the gated save failed. | V | `LibraryOpenModel.swift:533-543`; `KeychainCustody.swift:191-209` |
| S-6 | **Data Safety contradicts itself**: the *Restore from Backup* list with `Open…` sits above "Restoring is a Finder operation, not a button: quit Variorum, move the current library file aside…"; RESTORE.md (written into every backup folder, pinned byte-equal to `notes/DataSafetyRunbook.md`) teaches only the manual swap — no hold, no custody rule, the key file renamed to the LEGACY `variorum-keys.json`. | **D≠C** V | `DataSafetyPane.swift:145-177` vs `515-539`; `DataSafetyCopy.swift:197-243` |
| S-7 | **Stale "unbuilt" claims**: `LibraryMissingView` and `LibraryMissingLobby` headers still say Open an Existing Library is "13x's door, unbuilt" (it renders); the runbook still says "the first time Variorum backs up, it offers to use iCloud Drive" (retired by R-13r-12 for a day-5 calm ask). | **D≠C** V | `LibraryMissingView.swift:9-12` vs `21-24, 65-69`; `AppBootstrap.swift:1030-1038`; `DataSafetyCopy.swift:124-127` vs `ICloudDriveOffer.swift:37-50` |
| S-8 | **User-facing recovery copy names a file that modern folders don't contain**: "Restore the `variorum-keys.json` file from a backup folder" (`deadEnd`, `message(for: .unreadable)`, default arm) — backup folders hold `variorum-keys-<fp16>.json` and per-snapshot `….keys.json`. | V | `StoreProtection.swift:891, 918, 937`; `StoreKeyEnvelope.swift:418, 427-429` |
| S-9 | **The rotation marker rides the Castle switch's own fresh snapshot**: step 6 writes `rekey_in_progress = .snapshot`, takes the backup, then clears it — so that snapshot (the one copy the offer keeps) carries a pending marker in its `sync_state`; adopting it lands a library on which every sync round refuses (`accountRekeyIncomplete`) until a resume runs. (`LibraryRestoreHold` was kept out of `sync_state` precisely because that table "rides ciphertext backups".) | V/I | `PostureSwitch.swift:1235-1249`; `SyncEngine.swift:77-78`; `LibraryRestoreHold.swift:21-24` |
| S-10 | **The library-missing face's "Restore from a Backup…" and Data Safety's "Restore from Backup" are different acts** (Finder reveal of `Backups/` vs the adoption flow); Previous Libraries / adopt safety copies appear in neither list, and the restore list skips the second folder entirely (PROVISIONAL since 13x). | V | `LibraryMissingView.swift:58-64`; `DataSafetyPane.swift:137-143` |
| S-11 | **The second folder's layout splits pair and fallback**: the folder-level key file is written to `<picked>/Variorum/`, the snapshots to `<picked>/Variorum/Backups/`; the classifier's fallback hunt looks beside the snapshot, so a pair-less (13p / pre-row-42) far snapshot classifies `bareStoreWithoutKeyFile`. | V/I | `StoreBackup.swift:366, 380-383`; `LibraryClassifier.swift:172-195` |
| S-12 | **Dead state machine arm**: `RotationMarker.Step.offer` ("§4 step 7 — the offer") is never written by any road; the marker clears at the end of step 6, before the choice. | V | `CorpusRotation.swift:150-153`; `PostureSwitch.swift:1249` (grep: no `.offer` writer) |
| S-13 | **Unbounded keep-forever copies**: every adoption duplicates the outgoing library TWICE (Previous Libraries + adopt safety copy), neither pruned; the A1 rail and `.stale-*` key files accumulate the same way. Only Apple-openable aside copies are ever deletable, and only from the one-shot offer. | V | `LibraryAdoption.swift:233-286`; `LibraryAsideCopies.swift:54-93` |
| S-14 | **The "restore list says which credential opens it" consults one file and can be wrong both ways**: a copy whose pair has no roads still gets an `Open…` door whose refusal says "no key file came with it" (false); the second-look line says "your current passphrase or Touch ID on this Mac" even in Standard (silent, maybe no passphrase); any pair carrying `master` reads "your current passphrase (online)" although a rotation since (entering Castle, Replace All Keys) left that copy under a retired master; the section body says every copy "opens the same way your library does". | V | `DataSafetyPane.swift:167-172`; `LibraryOpenModel.swift:216-222`; `LibraryOpenCopy.swift:29-31, 106-123`; `StoreLaunchGate.swift:960-974` |
| S-15 | **The custody-collision memo assumed "the custody SHAPE follows the posture unchanged"** — but the posture the write consults is derived FROM the custody shape left by the previous copy (K1/K2); the memo's own case ("a pre-Castle copy adopted on the Mac the library lives on") is VX-209. | **D≠C** V | `phase-13x-library-portability.md:512-545`; `CustodyCollisionRule.swift:11-18`; `LibraryOpenModel.swift:509-544` |
| S-16 | **The hold's stale-marker guarantee is per location and can be bypassed**: a manual RESTORE.md swap writes no hold (silent catch-up); a crash after step 3½ holds the OLD library; `clear()`'s failure is ignored by `resume()`, which sets the projection to nil anyway — the banner vanishes while both gates (which read the marker FILE) keep refusing, so sync stays silently held until a later ready re-reads the marker. | V/I | `LibraryRestoreHold.swift:7-19, 86-90`; `RestoreHoldModel.swift:81-90`; `LibraryAdoption.swift:250-269` |
| S-17 | **Small mechanics**: the lock-time copy prunes with a hard-coded `14` (not `configuration.keep`); the far-folder delete authorizes by raw `hasPrefix` on paths; a re-copied same-name far snapshot is overwritten while its pair is kept. | V | `StoreBackup.swift:664, 408-419`; `PostureSwitch.swift:1963` |
| S-18 | **The phone has no copy road at all** (`backupEnabled: false`; no Open Library, restore list or hold), so every copies rule above is Mac-only while the posture machinery (`Shared/`) is shared — VM-15's sibling-phone exposure has no listing to fix it with. | V | `VariorumMobileApp.swift:70`; `MobileLibraryMissingView.swift:8-12` |

---

## Appendix A — per-file churn (all 53 files; `git log --follow`, author dates; lines at `63ec98c1`)

| File | Commits | First | Last | Lines |
|---|---|---|---|---|
| `Shared/ProtectionController.swift` | 51 | 2026-08-30 | 2026-10-13 | 2154 |
| `Shared/PostureSwitch.swift` | 43 | 2026-09-05 | 2026-10-13 | 2024 |
| `Shared/AppBootstrap.swift` | 36 | 2026-07-06 | 2026-10-13 | 1120 |
| `Shared/PostureCopy.swift` | 35 | 2026-09-05 | 2026-10-13 | 1105 |
| `Mac/Features/Settings/ProtectionPane.swift` | 34 | 2026-08-30 | 2026-10-13 | 1530 |
| `Shared/EncryptionSession.swift` | 32 | 2026-08-04 | 2026-10-13 | 785 |
| `Shared/EncryptionKeychain.swift` | 25 | 2026-08-04 | 2026-09-06 | 880 |
| `Shared/StoreProtection.swift` | 24 | 2026-08-30 | 2026-10-13 | 940 |
| `Shared/StoreLaunchGate.swift` | 22 | 2026-08-30 | 2026-10-13 | 1073 |
| `Shared/PostureSwitchModel.swift` | 18 | 2026-09-05 | 2026-10-13 | 857 |
| `Mac/Features/Settings/DataSafetyPane.swift` | 15 | 2026-08-24 | 2026-10-07 | 626 |
| `Shared/StoreBackup.swift` | 15 | 2026-07-07 | 2026-09-30 | 798 |
| `Core/Crypto/KeyVaultClient.swift` | 13 | 2026-08-04 | 2026-09-22 | 727 |
| `Shared/StoreKeyGuard.swift` | 13 | 2026-08-30 | 2026-09-06 | 458 |
| `Core/Persistence/StoreKey.swift` | 10 | 2026-08-30 | 2026-09-04 | 509 |
| `Mac/Features/Settings/DataSafetyCopy.swift` | 10 | 2026-08-24 | 2026-10-08 | 389 |
| `Shared/LibraryOpenCopy.swift` | 9 | 2026-10-07 | 2026-10-13 | 203 |
| `Core/Sync/CorpusRotation.swift` | 8 | 2026-09-05 | 2026-09-22 | 670 |
| `Core/Persistence/StoreKeyEnvelope.swift` | 8 | 2026-08-30 | 2026-09-06 | 561 |
| `Core/Crypto/VaultBootstrap.swift` | 8 | 2026-08-04 | 2026-09-22 | 324 |
| `Core/Crypto/KeyVaultFormat.swift` | 8 | 2026-08-04 | 2026-09-06 | 481 |
| `Mac/Features/Settings/DataSafetyModel.swift` | 8 | 2026-08-24 | 2026-10-07 | 361 |
| `Core/Crypto/VaultEnrollment.swift` | 7 | 2026-08-04 | 2026-09-22 | 431 |
| `Shared/ProtectionMigration.swift` | 7 | 2026-09-05 | 2026-09-06 | 485 |
| `Shared/LibraryOpenModel.swift` | 7 | 2026-10-07 | 2026-10-13 | 545 |
| `Shared/KeychainCustody.swift` | 7 | 2026-08-30 | 2026-09-05 | 270 |
| `Core/Persistence/LibraryAdoption.swift` | 6 | 2026-10-06 | 2026-10-13 | 320 |
| `Mac/LibraryOpenDoor.swift` | 6 | 2026-10-07 | 2026-10-13 | 330 |
| `Shared/PostureFollowModel.swift` | 6 | 2026-09-05 | 2026-10-13 | 264 |
| `Core/Persistence/StoreBinding.swift` | 4 | 2026-08-30 | 2026-10-07 | 133 |
| `Core/Crypto/KeyProof.swift` | 4 | 2026-09-05 | 2026-09-23 | 134 |
| `Shared/RestoreHoldModel.swift` | 4 | 2026-10-07 | 2026-10-08 | 98 |
| `Shared/BackupLog.swift` | 4 | 2026-08-24 | 2026-08-30 | 153 |
| `Core/Persistence/StorePlaintextExport.swift` | 3 | 2026-09-06 | 2026-10-09 | 83 |
| `Core/Persistence/LibraryClassifier.swift` | 3 | 2026-10-06 | 2026-10-07 | 365 |
| `Core/Crypto/PayloadCipher.swift` | 3 | 2026-08-04 | 2026-09-04 | 155 |
| `Mac/Features/Settings/ICloudDriveOffer.swift` | 3 | 2026-09-06 | 2026-10-04 | 232 |
| `Shared/KeyDoorModel.swift` | 3 | 2026-09-06 | 2026-09-21 | 465 |
| `Core/Persistence/LibraryRestoreHold.swift` | 2 | 2026-10-07 | 2026-10-07 | 91 |
| `Core/Persistence/BackupRestoreCandidates.swift` | 2 | 2026-10-07 | 2026-10-07 | 154 |
| `Core/Crypto/PassphraseKDF.swift` | 2 | 2026-08-04 | 2026-09-06 | 223 |
| `Core/Crypto/AccountDeletion.swift` | 2 | 2026-08-04 | 2026-09-06 | 35 |
| `Shared/LibraryHandOff.swift` | 2 | 2026-10-06 | 2026-10-07 | 219 |
| `Shared/BackupDestination.swift` | 2 | 2026-08-24 | 2026-08-24 | 153 |
| `Core/Persistence/StoreIdentity.swift` | 1 | 2026-09-04 | 2026-09-04 | 86 |
| `Core/Persistence/LocalMachineryRecreation.swift` | 1 | 2026-10-07 | 2026-10-07 | 93 |
| `Core/Persistence/LibraryPlacementGuard.swift` | 1 | 2026-10-07 | 2026-10-07 | 38 |
| `Core/Persistence/LibraryAsideCopies.swift` | 1 | 2026-10-13 | 2026-10-13 | 156 |
| `Core/Persistence/CustodyCollisionRule.swift` | 1 | 2026-10-06 | 2026-10-06 | 57 |
| `Core/Crypto/RecoveryPhrase.swift` | 1 | 2026-08-04 | 2026-08-04 | 210 |
| `Shared/StoreLocation.swift` | 1 | 2026-07-07 | 2026-07-07 | 48 |
| `Shared/BackupRetention.swift` | 1 | 2026-08-24 | 2026-08-24 | 136 |
| `Shared/AppleKeyCustody.swift` | 1 | 2026-09-05 | 2026-09-05 | 196 |

## Appendix B — how the numbers were produced (re-runnable, read-only)

- Per file: `git log --follow --format='%h' -- <file> | wc -l` (and `%ad --date=short` for first/last), over the
  53 paths listed in Appendix A, in `~/dev/variorum-vx-266` at `63ec98c1`.
- Union: every `--follow` hash, `sort -u` → 213; subjects via `git log -1 --format='%h%x09%ad%x09%s' --date=short`.
- Month/day counts: `cut -f2 | cut -c1-7 | sort | uniq -c`. "Fix-like": subject matches
  `fix|ladder|round [0-9]|R[1-4]-|F[1-3] |BLOCKER|MAJOR|MINOR|NIT|finding|correct|stop|red on main|did not build` (case-insensitive).
- Era classification: first-match regex over subjects in the order VX-201-run ids › VX-99 › VX-80 › VX-140 ›
  `pre-13x` › `13x` › `13p|pre-13u|17h` › `14[bcd]` › `13y|17l|17m|A2` › `18[klo]` › 13l/13e › `Phase [789]` › other.
- Size over time: `git rev-list -1 --before="<date> 00:00" HEAD`, then `git show <rev>:<path> | wc -l` summed.
- Linear: `list_issues` (query/project, `includeArchived: true`, limit 100), `get_issue`, `list_comments` — read only.
- Records skimmed by heading/finding-id greps: `run-a-custody-text-loss.md`, `phase-13p-fix-dp-keychain.md`,
  `pre-13x-design-review.md`, `pre-13x-design-final-review.md`, `pre-13x-ladder-round-{1,2}.md`,
  `13x-ladder-round{1..4}.md`, `fixes/vx-80-…`, `fixes/vx-99-*`, `fixes/vx-106-…`, `fixes/vx-191-encryption-audit.md`
  + `vx-191-audit/{A,B,C}`, `fixes/vx-201-castle-prelaunch-fixes.md`, `phase-13x-library-portability.md` (row-4 memo),
  `pre-13x-postures-design.md` (§3.5 + ruling 1).
