# VX-191 audit — Area B: every flow into and out of the encrypted library

Auditor: area-B subagent (Opus), read-only, worktree `~/dev/variorum-vx-191` @ f337f19e.
No tests run (every verdict below is from a code trace; pins cited where they exist).
Out of scope by design (decision 19): someone at the unlocked running app; malware running as the user.

## Verdict table

| # | Item | Verdict | Severity | One line |
|---|------|---------|----------|----------|
| B1a | New snapshot pairs under Castle carry no Apple copy | HOLDS | — | Pair = the bytes of the live key file at snapshot time; Castle's live file is written with no `apple`. |
| B1b | Lock-time keyless copy | HOLDS | — | Runs only after the pool closed and the key dropped; skipped on a hot `-wal`. Ciphertext byte copy + its pair. |
| B1c | Castle "Delete Them" offer — pairs in Backups/ + the picked folder | HOLDS (for what it lists) | — | Snapshot + `.keys.json` pair removed in both folders, under the security scope. |
| **B1d** | **"Delete Them" leaves Variorum-made full library copies that A still opens** | **FINDING** | **MAJOR** | `Previous Libraries/<stamp>/` and `Backups/safety-copies/variorum-adopt-safety-<stamp>/` (whole library + Standard-era key file with an `apple` copy) are never listed, deleted or named. |
| B1e | Pre-switch pairs in an unreachable or previously-picked second folder | FINDING | MINOR | Silently left out of a one-time offer that never comes back. Users aren't told those copies exist. |
| B1f | Folder-level `variorum-keys-<oldfp>.json` stays in Backups/ and the picked folder after Delete | NOTE | NIT | Holds only an A-wrap of the OLD L; it opens nothing left once the snapshots are gone. |
| B2a | Library stepping aside to Previous Libraries takes its key files (A copy included) | HOLDS (disclosed at adoption) | — | The confirm says so. The Castle ceremony never mentions it — see B1d. |
| B2b | R1-BLOCKER fix (`castleKeyFileAppleOpenable`) on the adopt roads | HOLDS for enrolled libraries. The phone has no adopt road. | — | The arm needs a vault reading plus held sync material. Local-only Castle is outside it — see B2c. |
| B2c | Local-only Castle library + adopt a Standard-era pair or a plaintext export | FINDING | MINOR | The posture silently becomes Standard and the Apple arm mints and lands an `apple` copy. No "Castle ended" notice. |
| B2d | Staged private copies (`withStagedRead`) | HOLDS | — | Per-user temp dir, removed by `defer` on every exit. They are byte copies of the picked file (ciphertext, or the user's own plaintext). |
| B3a | Plaintext SQLite export | HOLDS | — | Manual only. Passphrase re-auth under Castle, never biometric alone. Goes to the chosen destination. Sidecars removed. |
| B3b | Scheduled `.md` insurance OFF on entering Castle, on the acting device AND on a follow | HOLDS | — | One shared `snapshotAndInsurance` serves the ceremony, the follow (both arms) and the resume. |
| B3c | `.md` insurance exports written BEFORE Castle survive | FINDING | MINOR | Up to 4 plaintext exports stay in `<picked>/Variorum/md-exports/` (maybe iCloud Drive). Prune stops once the toggle is off, and nothing names them. |
| B3d | Copy full text / take copies to the clipboard | HOLDS (by design) | NIT | User-initiated. No auto-clear, no local-only/expiry option on the pasteboard (Universal Clipboard can carry it). |
| B4a | MCP server on lock (idle, sleep, screen lock, Lock Now, Always ask) | HOLDS | — | `onWillLock` detaches the door: socket unlinked, sessions shut down. Belt: the host's database is the BOUND view, so `StoreLockedError` after lock. |
| B4b | MCP traffic cannot keep a Castle library awake | HOLDS | — | The idle clock is stamped only by local NSEvents. |
| B4c | Who can connect to the socket | HOLDS | — | `0600` socket in the `0700` app container, plus the VX-168 per-setup key. A same-user process is out of scope. |
| B4d | MCP activity log / grants location | HOLDS | — | Tables in the SQLCipher store (`MCPGrantSchema`, v1_24), not a plain file. |
| B5a | Logs | HOLDS (light sweep) | — | No `.public` log line carries note text, titles or key bytes. The only `.public` names found are seeded books' fixed names. Verbose `NSLog` is DEBUG-only. |
| B5b | UserDefaults / AppStorage | HOLDS (sweep) | — | IDs, offsets, layout and dials only. No titles or prose found. |
| B5c | Spotlight / Handoff / widgets / share extension / Quick Look thumbnails | HOLDS | — | None present. The only extra target is the MCP shim. `QLPreviewView` serves external reference files. Phone app-switcher snapshot redacted. |
| B5d | FTS search index | HOLDS | — | `search_doc`/`search_fts` are tables in the same SQLCipher file. |
| B5e | WAL/SHM after re-key | HOLDS | — | `TRUNCATE` checkpoint, refuse on a non-empty `-wal`, atomic rename, old sidecars removed. SSD remnants are the recorded footnote. |
| B5f | Crash reports | HOLDS | — | MetricKit stack diagnostics. Opt-in, local only, sent only by hand. |
| B6a | Lock closes the pool and drops the key references | HOLDS | — | `binding.lock()` nils writer + key and closes. Also drops the resident key and the sync custody session. Memory scrub not claimed (recorded honestly). |
| B6b | Re-lock on sleep / screen lock wired | HOLDS (both platforms) | — | Mac: `willSleep` + `com.apple.screenIsLocked` + 30 s idle poll, started in the production bootstrap. Phone: `scenePhase` background ⇒ lock in Castle, and the away dial on return. |
| B6c | Acting device keeps its Standard-era key file beside the live store; "current" key file is chosen by mtime | OPEN | (MINOR if it holds) | Defense-in-depth gap. No realistic trigger traced (see B6c). |

---

## B1 — Backups

**What each snapshot writes.**
- **Snapshot:** a SQLite backup-API copy under the live L, so ciphertext (`StoreBackup.swift:563`). The name carries L's fingerprint (`:559–562`).
- **Pair (`…keys.json`):** a byte copy of the CURRENT key file as `StoreKeyEnvelope.locate` finds it, written only when absent (`:567–570`, `:589–594`).
- **Folder-level key file:** `variorum-keys-<fp>.json` in `Backups/` and in `<picked>/Variorum/`, written only when absent and never deleted (`:281–283`, `:317–325`, `:380–383`).
- **Far copy:** a byte copy of this run's own snapshot, plus its pair (`:407–419`).

**B1a — HOLDS.** On entering Castle the new key file is written with `appleKey: nil`: `writeNewKeyFile` via `rekeyCustodyAndSnapshot`, called with `entersCastle ? nil : …` at `PostureSwitch.swift:861,880`. It gets the newest mtime, so `locate` returns it (`StoreKeyEnvelope.swift:482–498`). Every later pair is a copy of it. The Apple arm cannot add a copy while the posture is determined Castle (`ProtectionController.swift:1491–1496`). The one caveat is B6c.

**B1b — HOLDS.**
- `performLockTimeCopyIfDue` (`StoreBackup.swift:633–669`) runs inside `lock()` after `binding.lock()` (`AppBootstrap.swift:918–924`).
- It requires `.encryptedOrUnknown` and refuses a non-empty `-wal`.
- It writes the closed file's bytes plus the live key file as its pair.

**B1c — HOLDS for what it lists.**
- **Listing** (`PostureSwitch.swift:1752–1759`): `existingBackups` of the container's `Backups/` plus the CURRENTLY resolved picked folder's `Backups/`, minus the new fingerprint.
- **Deletion** (`:1760–1773`): `removeSnapshotPair` takes the snapshot and its pair (`StoreBackup.swift:598–604`) inside the picked folder's security scope.
- Offered only over a fresh snapshot that was actually written (`PostureSwitch.swift:1227–1252`).
- Listed on the ceremony, on the follow (`:863,882`) and on the resume (`:1533,1612`).
- If she declines, what survives is disclosed honestly: `PostureCopy.swift:320–324` (the ceremony bullet) and `:463–468` (the offer body: "They still open through your Apple account, and they always will… Variorum can only delete its own backups — Time Machine, copies you made, and anything outside Variorum's folders aren't touched").

### B1d — MAJOR: "Delete Them" never reaches the full library copies Variorum itself made at adoption

**The promise.**
- Ceremony bullet (`PostureCopy.swift:320–324`): "Backups made before today — Variorum's own … still open through your Apple account. Delete them … if you want Castle to cover everything you have ever written."
- Offer (`:462–468`): "Delete the backups Variorum made before today? … Deleting them closes that door for what they hold. Variorum can only delete its own backups — … anything outside Variorum's folders aren't touched."

This tells her that pressing Delete Them removes every A-openable copy Variorum made inside its own folders.

**The path.**
1. While in Standard she uses any 13x adoption road: Restore from Backup, Open Library, or the welcome/absent-store faces. For example, she moved Macs or restored a backup.
2. `LibraryAdoption.execute` copies the outgoing library and EVERY key file beside it to `Backups/safety-copies/variorum-adopt-safety-<stamp>/` (`LibraryAdoption.swift:216–231`). It then moves them whole to `Previous Libraries/<stamp>/` (`:259–274`, plan `:153–160`). In Standard that key file carries the `apple` copy of that library's L.
3. Later she enters Castle and presses Delete Them.
4. The listing reads only the top level of `Backups/` and of the picked `Backups/`:
   - `pairs` → `StoreBackup.existingBackups` (`PostureSwitch.swift:1735–1739`)
   - `existingBackups` is a non-recursive `contentsOfDirectory` filtered to the app's own `.sqlite` names (`StoreBackup.swift:704–715`)
   - so `Backups/safety-copies/**` (a subfolder) and `Previous Libraries/**` (outside `Backups/`) are never candidates.
5. Nothing else in the app deletes them. A grep for `Previous Libraries` / `safety-copies` finds only `LibraryAdoption` and the adoption copy (`LibraryOpenCopy.swift:53,188`).

**Wrong state.** Two whole copies of her pre-adoption library stay in Variorum's own container, each beside a key file that her Apple account's key opens. That is after she chose "Delete Them … if you want Castle to cover everything you have ever written". The Castle screens never mention them. The adoption confirm did name the folders, but as a recoverable home, not as an Apple-openable copy.

**Bound.** This matters only if she adopted while in Standard. The copies sit in the local container (not iCloud), so an attacker needs her disk or a disk backup plus her Apple account. That is the same class as the Time Machine copies the copy discloses — but those are disclosed, and these are Variorum's own.

**Fix shape (not implemented):**
- Have the offer's lister also walk `Previous Libraries/*/` and `Backups/safety-copies/*/`, offering any folder whose key file carries `apple`.
- Or at least name those folders in the offer body.
- The same applies on the follow road.

### B1e — MINOR: unreachable or previously-picked second folders are silently skipped, once and for all

- `preSwitchSnapshots` resolves only the CURRENT bookmark (`PostureSwitch.swift:1754`). An unplugged drive or a stale bookmark (`resolve` → nil) contributes nothing.
- A folder she picked before switching destinations is never consulted.
- The offer is one-time: no Data Safety or later door re-lists pre-switch pairs (`deletePreSwitchSnapshots` is reachable only from `PostureSwitchModel.swift:587` and `PostureFollowModel.swift:247`).
- The offer body's "Variorum can only delete its own backups" implies its own are covered, yet these are its own.

**Fix shape:** when the picked folder is unresolvable, say so in the offer. Better, keep a later "delete pre-Castle backups" door in Data Safety.

**B1f — NIT.** `copyKeyEnvelope` never removes old folder-level key files. After a full Delete they hold only an A-wrap of the OLD L, which opens nothing that remains (beyond B1d's folders, which carry their own key files).

## B2 — Library portability (13x)

**B2a — HOLDS, disclosed at adoption time.**
- The outgoing library's key files, Standard-era `apple` copy included, travel into `Previous Libraries/<stamp>/` (`LibraryAdoption.swift:207–213,259–274`).
- The confirm says so: `LibraryOpenCopy.swift:51–54`.
- The gap is the Castle ceremony's silence about it (B1d).

**B2b — HOLDS for enrolled libraries.**
- The `castleKeyFileAppleOpenable` arm (`ProtectionController.swift:663–684`) fires when the vault reads Castle, the ids agree, and the live key file carries `apple`.
- The follow then re-keys the library and runs `retireOldKeyFiles` (`PostureSwitch.swift:1130`, `:901–927`).
- That follow's offer lists every pair not under the new key (`wasStandardShaped` = the live file has `apple`, `:845,863`). This covers the A-openable snapshots taken between the adoption and the follow, which carry writing made after the restore.
- The pin `anAdoptedStandardEraPairUnderACastleVaultOwesTheFollowThatRetiresItsAppleCopy` is recorded red-on-old (13x plan :1278, :1296).
- Plaintext road on a Castle account: it lands the silent item with Auto dials (`LibraryOpenModel.swift:331–347`). The vault-read posture stays determined Castle, so the Apple arm writes nothing. The `castleStillOpensOldWay` arm owes the follow.
- The phone has no adopt road. `LibraryOpenModel` and `LibraryHandOff` are composed only by the Mac's `LibraryOpenDoor.swift`.
- Residual: until she accepts the follow (it can be deferred with "Later"), the live library and each new snapshot pair stay A-openable. This is the accepted design: the notice speaks.

### B2c — MINOR: a local-only Castle library silently becomes Standard after an adoption

**The arm needs a vault.** `reconcileFollow` returns early with no vault reading (`ProtectionController.swift:608–612`). Without a vault the posture is the key file's own (`StoreProtection.swift:92–109`).

**The path (plaintext road).**
1. `StoreIdentity.establish` writes a key file with no passphrase wrap, then `saveDials(ProtectionDials())` and `saveAuto` (`LibraryOpenModel.swift:341–347`).
2. `localReading` reads that as Standard (`StoreProtection.swift:104`).
3. `reconcileAppleKey` runs on determined Standard and mints and lands an `apple` copy (`ProtectionController.swift:1491–1549`; `mintAllowed` because there is no vault id).

**The path (Standard-era pair).** Restoring such a pair reads Standard directly (`:103`).

**What she sees.** The confirm (`LibraryOpenCopy.swift:59–61`, "It gets a fresh key of its own … and opens encrypted") and the restore rows never say Castle has ended.

**Fix shape:** when the outgoing library read Castle and the landed one reads Standard, say so at the confirm. Or carry the Castle shape onto a plaintext landing.

**B2d — HOLDS.**
- `LibraryClassifier.withStagedRead` (`LibraryClassifier.swift:289–318`) copies into a fresh per-user temp subdirectory, `defer`-removed. Only a crash mid-consult leaves one (recorded at `:283–284`).
- The staged bytes are the picked file's own: ciphertext for a pair, or the plaintext export the user already holds.

## B3 — Exports

**B3a — HOLDS.**
- `StorePlaintextExport.export` does `ATTACH … KEY ''` + `sqlcipher_export` to the chosen destination and removes its sidecars (`StorePlaintextExport.swift:48–80`).
- Authorization (`PlaintextExportModel.swift:57–80`): the passphrase (vault-verified when enrolled) under Castle, never Touch ID alone.
- Never scheduled. The phone has no door.

**B3b — HOLDS.**
- `MarkdownInsurance.setEnabled(false)` runs in `snapshotAndInsurance` whenever `entersCastle` (`PostureSwitch.swift:1240–1247`).
- That one function serves the acting ceremony, the follow's no-rotation arm (`:858–866`), the follow-by-passphrase arm (`:878–883`), and the resume (`:1612`).
- The flag is per-device UserDefaults, so each device's own follow turns its own off.
- The phone never runs the insurance (`backupEnabled: false`, `VariorumMobileApp.swift:70`).

### B3c — MINOR: plaintext exports already written survive Castle with no word

- If she had opted in, up to 4 dated plaintext folders sit in `<picked>/Variorum/md-exports/`, possibly in iCloud Drive.
- Turning the toggle off also stops their prune: `performRun` returns at `guard isEnabled` (`MarkdownInsurance.swift` ≈ line 104) before `prune`.
- Delete Them removes `.sqlite` pairs only.
- The notice (`PostureCopy.swift:434–437`) says the export "would have kept writing readable copies". It does not say that readable copies already sit there.
- Opt-in only, so a narrow audience — but it is the strongest plaintext left after a "cover everything" Castle entry.

**Fix shape:** name the `md-exports` folder in the notice, or include it in the Delete offer.

**B3d — HOLDS / NIT.** Copy full text (`TakeClipboard`, the note menus) writes the general pasteboard on her own press. There is no auto-clear and no `.currentHostOnly` / expiration option. This is ordinary for a writing tool, and the user is the open-app actor.

## B4 — The MCP door

**B4a — HOLDS.**
- **The detach wiring.** `bootstrap.onWillLock` is set in the same synchronous ready-task that attaches the door (`VariorumApp.swift:198–257`). It runs `macWillLock` and then `appDelegate.mcp.detach()`.
- **What detach does.** `stopServer()` → `MCPServerHost.stop()` closes the listener, UNLINKS `mcp.sock` and `shutdown(SHUT_RDWR)`s every session (`MCPServerHost.swift:104–126`, `MCPSession.swift:194–196`).
- **Order.** All of this happens BEFORE `binding.lock()` (`AppBootstrap.swift:876–925`). Quit detaches too (`VariorumAppDelegate.swift:115`).
- **Belt.** The host and sessions read through `session.database`, which is the BOUND view (`AppBootstrap.swift:454–492`). After lock, every access throws `StoreLockedError` (`StoreBinding.swift:79–113`), so even a race cannot read a closed store.
- **Which locks this covers.** Idle, sleep, screen lock, Lock Now and Always ask all end at `AppBootstrap.lock()`. The re-key road also runs `onWillLock` (`:818`).
- **On unlock** the door re-attaches. It re-serves only if her toggle is ON.

**B4b — HOLDS.** `noteActivity` is fed only by the local NSEvent monitor and became-active/ready (`ProtectionController.swift:1863–1869`, `AppBootstrap.swift:544`). MCP calls never touch it.

**B4c — HOLDS.**
- `MCPSocketRoad.listen` binds, then `chmod 0600` (`MCPSocketRoad.swift:148–180`), inside the app's `0700` container `Data/`.
- Admission also needs the VX-168 per-setup key.
- A process running as the same user is out of scope (decision 19 / malware).

**B4d — HOLDS.** The grants, switches and activity log are tables created in `MCPGrantSchema.swift` (v1_24) inside the SQLCipher store. The MCP code writes no UserDefaults.

## B5 — Plaintext outside the SQLCipher file

**B5a — HOLDS.** A sweep of every `privacy: .public` interpolation and every `print`/`NSLog` in App/ and Sources/ (tests excluded):
- No note text, title, query or key bytes.
- `ShellActions.swift:550` and `SampleLibrarySeeder.swift:938` log SEEDED book names (fixed content).
- `LandingAuthority.swift:773`'s verbose dump is `#if DEBUG`.
- Errors are logged `.public` as `String(describing:)`. GRDB hides statement arguments by default; `publicStatementArguments` is not set anywhere.

**B5b — HOLDS.** Every UserDefaults/`@AppStorage` write in App/ was reviewed. They hold IDs (open notes, current block `id|variant|offset`, per-post mode/layout), widths, dials, the backup bookmark, and `BackupLog` records (file names, paths, error strings). No titles, no search history, no prose.

**B5c — HOLDS.** No CoreSpotlight, `NSUserActivity`, widgets, share extension or recent-documents donation exists. The phone redacts its app-switcher snapshot (`VariorumMobileApp.swift:58–64`).

**B5d — HOLDS.** The FTS index is created in `Migrations.swift` (≈:843) in the same database file.

**B5e — HOLDS.** `StoreEncryptionMigration.rekey` (`StoreEncryptionMigration.swift:220–327`):
- truncate-checkpoints and refuses a non-empty `-wal`
- exports to `.rekeying` under the new key and verifies row counts and ciphertext
- `rename`s over the store, then removes the old `-wal` and `-shm`
- the temp's sidecars are swept before the rename.

**B5f — HOLDS.** `CrashReporting.swift:1–45`: off unless she opts in, local only, sent only by her own hand.

## B6 — Lock behavior

**B6a — HOLDS.**
- `AppBootstrap.lock()` (`:875–925`) runs `onWillLock` (flush, then services stop, then the MCP detach).
- It flips state to the lobby, then calls `protection.dropResident()` and `syncCustodySession.drop()`.
- It then runs `binding.lock()` off-main: writer and key set to nil under the mutex, a TRUNCATE checkpoint, then `close()` (`StoreBinding.swift:79–113`).
- That file honestly records that it does not scrub already-freed memory.

**B6b — HOLDS.**
- **Mac:** `startRelockMonitors()` is called by the production bootstrap init (`AppBootstrap.swift:179–183`). It covers `willSleepNotification`, the `com.apple.screenIsLocked` distributed notification, and a 30 s idle poll. Each re-checks the effective gate when it fires (`ProtectionController.swift:1848–1903`).
- **Phone:** `scenePhase` background locks under a demanded gate, and the away dial applies on return (`MobileRelock.swift:43–68`; `VariorumMobileApp.swift:247,308`).

### B6c — OPEN: the acting device keeps its Standard-era key file live, and "current" is decided by mtime

- **The leftover file.** On the acting ceremony road the OLD key file (with the `apple` copy of the old L) deliberately stays beside the live store. `retireOldKeyFiles` runs only on a follow into Castle (`PostureSwitch.swift:1128–1130`; the comment at `:894–899` says "Not on the ceremony's own road").
- **How "current" is picked.** `StoreKeyEnvelope.locate` picks the most recently MODIFIED of several key files (`StoreKeyEnvelope.swift:482–498`).
- **What would go wrong.** If the old file ever read as newest, a local-only library's posture would derive Standard (`StoreProtection.swift:103`). `reconcileAppleKey` would then:
  1. read the old file,
  2. find it does not `belongs(to:)` L′ and set it aside (`ProtectionController.swift:1104–1111`),
  3. wrap the CURRENT L′ under A into a fresh envelope saved at L′'s own path (`:1612–1613`).

  That would overwrite the Castle key file with an Apple-openable one.
- **Why it stays OPEN.** I traced no writer that touches the old file after the switch: writers save to the loaded envelope's own fingerprint path (`StoreLaunchGate.swift:106`). Only a backwards clock jump or an external mtime change would trigger it.
- **What would settle it:** a pin that sets the old file's mtime later than the new file's and runs a local-only reconcile.
- **Fix shape:** retire the Apple-carrying old file on the ceremony road too (the follow already proves it is safe — the snapshot pairs keep their own copies). Or have `locate` prefer the file whose fingerprint matches custody or the open key.

## WHAT I DID NOT CHECK
- I ran no tests. Every HOLDS above is a code trace; the only pin cited is the 13x R1-BLOCKER pin, by name.
- macOS Saved Application State (window titles and restorable state on disk) and Dock/Mission Control thumbnails while locked.
- The 11b bulk `.md` export and the per-note export file doors, beyond confirming they are manual.
- Whether `BackupLog` error strings could carry a title-derived export filename. Only the plaintext insurance leg writes such names; this is NIT-level at most and untraced.
- The phone's keychain/file-protection classes beyond the redaction and the relock (`prepareStoreDirectoryProtection` not read).
- Whether the restore hold suppresses the vault read. This matters only to the enrolled B2b timing, which is conservative either way.
- Universal Clipboard and Time Machine behavior (external facts, already disclosed by the copy).
