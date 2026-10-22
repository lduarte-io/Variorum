# VX-329 — Castle rebuild: the release switch

**Status: OPEN — IN FLIGHT (kicked off 2026-10-22 under her overnight mandate; the kickoff record is §6; the run
pauses at U2's staging point — the real-store byte-copy rehearsal, the production deploy and the release are her
morning's). Plan written at VX-309's closeout, 2026-10-20; her kickoff calls ANSWERED at the 2026-10-22 sitting —
the kickoff block below carries them, QUESTIONS #237's answer block is the record.**
`Ticket: VX-329 · Project: Castle & backups before launch · Branch: vx-329-release-switch · Worktree:
~/dev/variorum-vx-329 (Pro)`. Holds the Sync/-custody slot.

> **KICKOFF MESSAGE (paste-ready).** STEP 0: the bout ritual (pull both repos, `Tools/vx sync`), then from
> `~/dev/variorum` on `main`: `git worktree add -b vx-329-release-switch ~/dev/variorum-vx-329 origin/main`; push
> the branch; the in-flight row (HOLDS the Sync/-custody slot); Linear VX-329 → In Progress; announce to the stage
> coordinator. **Read first, in full, never delegated:** CLAUDE.md + its canon; `notes/SessionResiliencyProtocol.md`;
> `notes/CastleRules.md` WHOLE (rules 15, 26 and the considered-and-not-pursued ledger are this phase's heart);
> `notes/SyncSpec.md` WHOLE (§12 lockstep — the marker 13→14 bump is this phase's); `notes/SurfaceContracts.md`'s
> protection and doors sections; the VX-329 ticket body and its comments (VX-309's seven inputs);
> `notes/plans/vx-308-accounts-key-doors.md` §5R (the fresh-mirror runbook and the rehearsed artifact 17) and its
> WALK RECORD; `notes/plans/vx-309-copies-and-words.md` §8–§9 (the walk's machinery notes and the born tickets);
> `notes/plans/vx-266-castle-backups-prelaunch.md` §3.15 (today's deletion list — superseded where the ticket says
> "nothing is kept read-only"); QUESTIONS #237 (her VX-309 bundle — any answer there may reshape a unit).
> **Her calls — ANSWERED at the 2026-10-22 sitting (QUESTIONS #237's answer block is the record):**
> (1) the switch does NOT wait for VX-212 — phase 6 runs right after this merge, before her public launch.
> (2) the cold review is FABLE (credits are back; no waiver).
> (3) riders IN: VX-461 (the export door — rule 26 and §2 lean on it) · VX-465 (the device-ID drift trace) ·
> VX-462 · VX-464 · VX-473 · VX-463 (ruled: conceal the words fields, with a reveal eye) · VX-469's ruled (c)
> confirm line (wording) · VX-468 if it fits (ruled: the what's-new card waits after a restore). VX-213's `pg_temp`
> has her GO (2026-10-22 follow-up): rehearse it on the throwaway mirror with the rest; its PRODUCTION application
> rides the marker-14 deploy set in the release window — the deploy itself still runs only at her explicit go.
> **VX-470 is RULED but unsized**
> ((c) plus an explicit Standard choice, carried to T-5 — #237's shape): take it only if it fits a batch cleanly,
> else it leads the next run.
> (4) the release is **0.10** (her word: no 1.0 until public launch, and 0.9.9 "will just get more confusing");
> notes drafted for her.
> **VX-423 joins as its own unit** (U3 below — her call at the sitting).
> **No stage coordinator tonight:** VX-329 is the only session running — hold `Tools/stage` claims directly and
> skip the announce step.
> **The pause point (her word):** run U1, U3 and U2's throwaway rehearsal to completion, then PAUSE with everything
> staged for her hands — the byte-copy rehearsal of her real store waits for her morning (stage the byte copy if
> container access allows, else leave her the exact commands; A1 discipline and the zero-instance gate as ever).
> **The phone (her word):** the Macs switch first — see §3's revised deploy line and §4.

## 1. What this phase is

The last step of the rebuild: Release builds take the new road. One compile-time switch
(`ProtectionRoad.newRoadIsLive`) flips; today's whole deciding and writing code is deleted in the same change (the
old envelope, the legacy readers, the old markers, `CorpusRotation`, `PostureSwitch`, the posture drill VX-233, the
old suites whose release-floor reds are VX-406) — nothing is kept read-only. The `key_vault` lockstep (artifact
`Server/supabase/17_phase_vx307_vault.sql`, marker 13 → 14, registered in the DDL drift pin with `lockstepVersion` →
14 in ONE commit — VX-307's pinned pairing) deploys at her explicit go in this release's window. No migration (rule
26): everyone with a pre-design store exports or signs into sync before the switch, then starts fresh; her own old
stores are kept whole as copies.

## 2. The one question this phase must answer before any real store crosses

**How does a fresh new-road library get her synced writing back?** Today's account holds her rows sealed under
today's sync keys; the new account vault (artifact 17) is new. Rule 15 says the account keeps every sync key it has
ever had and a device joining years later reads everything — this phase must PROVE that holds across the switch (or
find that it doesn't and bring it to her), on the throwaway project, before her stores are touched. If the answer is
"export, then bring in", T-8 (VX-309) is the bring-in road and VX-461's export door must work first.

## 3. Proposed cut (the kickoff session's to make; acceptance units, one implementer each)

- **U1 — THE SWITCH (Fable-reviewed custody work):** flip the switch; delete today's road per the ticket; the
  lockstep commit (artifact 17 registered + `lockstepVersion` 14); the ⌃⌘L chord declared with its helper row
  (P-VX309-U1c-4 (b)); the protection suites green under the Release configuration (`swift test -c release`
  included — VX-380/VX-406's reds die with the deleted suites or are fixed). Evidence: the Release build runs the new
  road; the suites green under Release; the deletion is complete (a grep sweep table, each legacy symbol GONE).
- **U2 — SWITCH DAY, REHEARSED:** the step-by-step switch-day script for her (§2's answer inside it), run start to
  finish on the throwaway project with two test accounts and two devices' worth of libraries; then the rehearsal on a
  byte-copy of her real store on the dev slot (Look inside, then Make this my library — her hands, her credentials);
  the website delta brief REWRITTEN to the rules (F-U2-4) and handed to the site agent after a check against the
  shipped build; VX-379's truth-check of the guide and panes against the Release build, and her real store's re-seed
  plan. Evidence: the script walked green on the throwaway; her rehearsal done; the brief rewritten.
- **U3 — VX-423 (Fable-reviewed Sync/custody work):** one refresh authority for the scope's rotating refresh
  token — the vault leaf's provider (`FollowingSessionProvider` → its `AuthSession`) and the app's own `AuthSession`
  stop refreshing it independently (F-U1-1's trace, routed at VX-308; the reuse detection fires as
  `refresh_token_already_used` and sync stops until re-login). Evidence: a red-on-old pin on the two-refreshers
  race, and U2's throwaway rehearsal running with the fix in — switch day is wall-to-wall sign-ins, which is why
  this rides here rather than phase 6 (her call at the sitting).
- **The deploy and the release** are hers: the mirror deploy at her explicit go; **both Macs** updated in one window
  (her 2026-10-22 revision of "update every device first": the phone follows when VM-8's catch-up lands — *"it's ok
  if the phone doesn't sync for a day after the switch"* — and cannot sync against marker 14 until then); her
  acceptance on both Macs now and on the phone at its catch-up; the release at her word (**0.10**, notes drafted
  for her); then she deletes the throwaway project.

## 4. Dependencies and risks

- **The phone.** SETTLED at the 2026-10-22 sitting: VM-8 is still Backlog, so the Macs switch first and the phone
  joins when VM-8's faces land (its kickoff prompt is with her; that session runs AFTER this phase merges, on a
  main-based `vm-8` worktree — VM-5 retired the `mobile` branch 2026-10-07 and her phone runs MAIN-built installs,
  so it sits at main's marker today and there is no merge leg). Her current phone install cannot sync against
  marker 14 until the VM-8 build installs — accepted by her word.
- **The export door (VX-461)** writes an empty file today; rule 26's instruction must not name it until it's fixed.
- **Device-ID drift (VX-465)** must be traced: a drifting device ID in Release would make "this Mac's copies" and
  retention lie.
- **Release parity ends here:** every new-road face becomes Release-visible. The #237 calls are SETTLED
  (2026-10-22): VX-463's conceal-with-reveal-eye and VX-469's (c) confirm line ride this run; VX-468 waits-after-
  restore rides if it fits; VX-470's ruled shape is sized at the kickoff (see the kickoff block). VX-234's wording
  pass remains.
- **The cold review** is custody code — Fable, or her explicit waiver.

## 5. Records

Each unit appends its record here (the VX-309 §6 form); the ladder files `notes/plans/vx-329-ladder-round-N.md`;
the walk and the rehearsals in §8; the closeout in §9.

### U1 RECORD — THE SWITCH (Opus implementer, 2026-10-22; DONE — the Mac and phone suite RUNS are the orchestrator's stage batch)

**Not done in U1, first:** NO Mac or phone test suite was RUN (no stage — the brief's limit): every app pin written,
rewired or trimmed here is COMPILED (`build-for-testing` green, both targets) and UNRUN — the suite list below is the
orchestrator's stage batch, and every app-side claim in this record is PENDING until it runs. NO walk, no Debug launch, no
dev-store touch. NOT built (each flagged below, none invented): a face that NAMES an older Variorum's key file or the road
out of a pre-design store (piece 5); the replacement for the session-stamped owner (F-U1-1); the phone's road faces (VM-8,
F-U1-3); the rewrites of `RESTORE.md` and the phone guide's privacy chapter (F-U1-4, F-U1-5); the deletion of the
orphaned `LocalMachineryRecreation` (F-U1-9) and of the 14b vault brains (`Crypto/VaultBootstrap` etc. — L1's call);
anything in `Sources/VariorumCore/Sync/` (the L1 flags). Standing limits from the brief: no stage, no Debug launch, no
dev-store touch, no network, no Linear, no subagent, no `xcodebuild test` (the Mac suite list below is the orchestrator's);
zero `Sources/VariorumCore/Sync/` lines (the L1 flags below are the orchestrator's); `SyncSchema` untouched (L0's 14 stands).

**Preflight (complete, not delegated):** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md` whole;
`notes/CastleRules.md` WHOLE (rules 24, 26, "What we do not promise" and the considered-and-not-pursued ledger);
`notes/SurfaceContracts.md` whole (The app · Doors — Library portability + Library protection); this plan WHOLE (§1–§6, the
CUT, the OPEN DESIGN NOTE, the environment traps, §6a, the L0 RECORD, the VX-465 RECORD); `notes/plans/vx-266-castle-
backups-prelaunch.md` §3.12–§3.15; `ProtectionRoad.swift` WHOLE; `AppBootstrap.swift` WHOLE (the fork at :217, every
`newRoad` arm); `CapabilityRegistry.swift` around `.lockLibraryNow` + `Capability.swift`'s P-VX309-U1c-4 comment +
`HelperView.groups` + `CapabilityRegistryTests`' discoverability guard; the composition roots (`VariorumApp.swift`,
`AppServices.swift`, `LibraryOpenDoor.swift`); the envelope (`StoreKeyEnvelope.swift` WHOLE — the new core borrows its
fingerprint and its `PassphraseWrap`); the new road's names (`Protection/Model/Names.swift` — the format-3 key file is
`variorum-library-keys.json`, a name today's files never carry); the backup seam (`ProtectionBackupHook.swift`,
`ProtectionBackupPair.swift`, `StoreBackup.swift`'s outline); `LibraryHandOff.swift` WHOLE; the vx-309 §6 U1c record (the
form). Machinery note: the orchestrator's own commits interleave on this branch (`1d3b84a19`, VX-465; an untracked
`Server/` artifact in progress) — every U1 commit is pathspec-limited, rebased before each push.

**MY READINGS (each the brief's letter as I read it):**
- **R-U1-1 — THE PRIMITIVES THE NEW CORE BORROWED ARE RELOCATED, NEVER RE-IMPLEMENTED.** The format-3 core named every
  key by `StoreKeyEnvelope.fingerprint(of:)` (key files, custody items, seals, pairs) and typed its passphrase lock as
  `StoreKeyEnvelope.PassphraseWrap`. Both moved byte-for-byte: `KeyFingerprint.of` / `.short`
  (`Persistence/KeyFingerprint.swift` — the same SHA-256-first-8-bytes hex) and `PassphraseWrap` (in `KeyFile.swift`,
  the same two coding keys `kdf`/`wrapped`, so a format-3 file's bytes are unchanged); the two envelope error cases the
  core threw (`unreadable`, `emptyPassphrase`) re-homed on `KeyFileError` (no new-road code matched them).
- **R-U1-2 — THE CLASSIFIER NAMES A KEY FILE, IT NEVER READS ONE.** With the envelope's readers gone, the opaque arm of
  `LibraryClassifier` would have called every pre-design pair "keyless" (`.bareStoreWithoutKeyFile` → "no key file"),
  which is false. It now recognises a key-file-shaped NAME beside an encrypted store — its own `<stem>.keys.json`, this
  design's `variorum-library-keys.json`, an older Variorum's `variorum-keys-<fp16>.json` / `variorum-keys.json` — in a
  FIXED order (never newest-modified), reading no byte, and says `.encryptedLibrary` (the new road's `PickedCopy` maps
  it to today's honest minimum, "couldn't be read as a library", unchanged). `.snapshotPair`/`.folderHoldingPair`
  collapsed into it (the faces were already one). Piece 5 pins it.
- **R-U1-3 — TODAY'S TOOLS THAT UNLOCKED THROUGH TODAY'S KEY FILE GO WITH IT.** StringsWorkbook's `StoreUnlock` + its CLI
  executable + `StoreUnlockTests` (VX-406's) + its rehearsal fixture; `vault-bootstrap`'s CLI shell (its unlock read
  today's envelope — VX-64) + `Vx64DrillFixtureTests`. The workbook LIBRARY (parser, plan, mint) and the vault-bootstrap
  BRAIN (`Crypto/VaultBootstrap.swift`, the 14b vault create + resync) are untouched — the brain is FLAGGED below.

- **R-U1-4 — ONE ROAD IN THE BOOTSTRAP, AND ITS TEST HARNESS REQUIRED.** With today's route gone, a bootstrap without the
  road has nothing to open: the production init always composes `RoadInputs.live(variant:)` (every variant — the dev-store
  fence dissolved), and the test init takes the harness (`init(testStoreURL:protectionRoad:)`). Today's store id beside
  the library (`ensureStoreIdentity` — today's `StoreIdentity` stub envelope, written on the new road "so the rest of the
  app keeps its footing") went with the envelope: nothing reads it any more (today's sync custody, dials and backup log
  were its only readers). The copy doors' `mintStoreIdentity` hook went with it.
- **R-U1-5 — THE PAIR ROAD IS THE BACKUP WRITER.** `StoreBackup` keeps the clock (launch + hourly, Back Up Now, one run
  at a time), the record and the log, the `RESTORE.md` drop and the Markdown leg; its run's writer is the road's pair road
  (`ProtectionBackupHook.attach` → `StoreBackup.pairRoad`; `runPair`: due when this Mac's newest pair of the library beside
  it is older than the interval — `OwnCopies.pairIsDue`, the catalogue's, never the folder's newest file — or forced;
  `takePairReporting` lands the container pair, the picked folder's when due there, then retention, and reports both
  legs). Today's flat legs (the container's flat snapshots + 14-newest prune, the second-folder copy + its 14+4 sweep
  over this Mac's own list, today's key-file copies into both folders, the lock-time keyless byte copy and its next-unlock
  check) are DELETED. Data Safety's two rows count the catalogue's pairs only (today's flat-file count deleted).
- **R-U1-6 — SEND LIBRARY STANDS, ON THE ROAD'S ACT.** Today's producer copied today's key file beside a sealed snapshot;
  the core already holds the road's act (`ProtectionExecutor.sendLibrary` → `writeSendPair`: `variorum.sqlite` + this
  design's key file — exactly what the road's Open Library… files on the other Mac). The door, its faces and words are
  unchanged; `AppBootstrap.sendLibrary(into:)` runs the act (one act at a time, off the main actor; a refusal removes the
  half-made folder). PROVISIONAL P-VX329-U1-1 (stop-and-flag below).
- **R-U1-7 — THE DECRYPTED EXPORT'S FACTS FROM THE ROAD.** Its authorization rule is unchanged (Castle, or a passphrase
  set: the passphrase); the facts moved from today's controller and vault tie to the open library — its posture, whether
  its key file carries a passphrase lock, the typed passphrase checked against that key file (`RoadStandingModel
  .checkPassphrase`). PROVISIONAL P-VX329-U1-2. (The core's own `plaintextExport` act exists unwired — noted for R1's
  VX-461.)

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece R — this record skeleton: DONE (`c629ae54f`).
- Piece 0 — the flip (`ProtectionRoad.live` → true unconditionally; the dev-store fence's parameter deleted with its
  callers' discrimination; the bootstrap's and the composition roots' `!newRoad` arms deleted): DONE (`c3d939c9e` the
  seeders/Settings half · `f2306a535` the rest). `ProtectionRoad.live(debug:)` answers true for both arms (the pure
  function kept, its pin to flip); `opensOnTheNewRoad(devStore:)` DELETED with every caller's discrimination;
  `AppBootstrap.newRoad` DELETED — the bootstrap has one road: `State` lost `.locked`/`.waitingForICloudKeychain` and
  `.failed`'s recovery lobby; the test init is `init(testStoreURL:protectionRoad:)` (the harness REQUIRED — today's
  `testOpener`/`gate`/`testPresence` went with today's route); the production init composes `RoadInputs.live`.
  `VariorumApp`, the phone's root, `LibraryOpenDoor`, `SettingsSceneContent`, `AppSettingsView`, `RootView` lost their
  today arms. `swift build` + the Mac app `build` (Debug) GREEN at this commit; the TEST targets do not compile yet
  (piece 3).
- Piece 1 — the Shared/ deletions (today's deciding and writing road in the app): IN-PROGRESS — DELETED whole:
  `AppleKeyCustody`, `AppleRelinkModel`, `EncryptionKeychain` (today's sync custody: `SyncCustodyRecord`/`Session`,
  `E2EECustodyLeaves`, `DeviceKeyStore`, `DeviceKeySyncProvider`), `EncryptionSession`, `EncryptionViews` (the Account
  sheet's Encryption tab), `KeyDoorModel`/`KeyDoorView`/`KeyDoorCopy`, `LibraryOpenModel` (13x's adoption flow + its
  sheet), `LobbyVaultRoad`, `PassphraseSetModel` (+ `VaultTie`), `PostureCopy`, `PostureFollowModel`, `PostureSwitch`,
  `PostureSwitchModel`, `ProtectionMigration`, `SecretCheck`, `StoreKeyGuard`, `StoreLaunchGate`, `StoreProtection`
  (`Posture`, `RawKeyCustody`, `StoreAtOpenMode`, `ProtectionDials`, today's `ProtectionCopy` base), `SyncEnrollment
  Model`/`View`, `WordsCeremony`, `BackupRetention`; the Mac's `ProtectionStatusRow` (today's tier); the phone's
  `MobileProtectionSheet`, `MobileProtectionCeremonies`, `MobilePostureSheets`, `MobileStoreLockView`. STRIPPED to the
  road's arms: `ProtectionController` (the relock monitors over `roadRelock`, the idle clock, the Settings pane
  request — nothing else), `AppServices` (the key provider REQUIRED, today's encryption session / vault client / adopt
  road / rotation-marker reads gone), `StoreBackup` (see R-U1-5), `LibraryHandOff` (see R-U1-6), `LibraryOpenCopy`,
  `KeychainCustody` (the tripwire + partition rules kept; today's gated-save and handover choreographies gone),
  `RestoreHoldModel` (the round gate only), `SyncStatusViews` (the engine-error classifiers moved here; the
  rekey-incomplete arm gone), `AuthViews` (the Encryption tab gone), the Protection and Data Safety panes, the Mac's
  `StoreLockView.swift` (today's `StoreLockView` struct gone; `RoadLockView` stays, its Finder-revealing restore arm gone),
  `StoreFailureView` (both platforms — the sidecar recovery lobby gone), `LibraryMissingView` (the Finder reveal gone),
  `MobileRelock` (reads `RoadRelockPolicy`). RELOCATED byte-for-byte: the road's surviving `ProtectionCopy` members
  (`Shared/Protection/ProtectionCopy.swift`), `IdleLockClock` (→ `ProtectionRoadLock.swift`), the shared access group
  (→ `ProtectionKeychain.sharedGroup`), `WordsInput.words(from:)` (today's `EncryptionSession.words`), the Apple-key
  item's `{id,key}` JSON shape (a private struct in `ICloudAppleKeysLeaf`). The iOS app target BUILDS (`xcodebuild
  -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' build` EXIT 0 at `1026d4484`). REMAINS: the final
  sweep for dead members (piece 6).
- Piece 2 — the Persistence/ deletions (the envelope, custody, the legacy arms; the primitives the new core borrows
  relocated byte-for-byte, never re-implemented): DONE (`c3d939c9e`) — `swift build` green (the core library + tools):
  DELETED `StoreKeyEnvelope`, `CustodyCollisionRule`, `StoreIdentity`, `BackupRestoreCandidates`, `LibraryAdoption`,
  `LibraryAsideCopies`, `StoreKeyKeychain` + `StoreKeyCustody.deviceKeychain*` (custody by library ID; `liveValue` now
  holds nothing), `StoreEncryptionMigration.rekey` (today's export-and-swap); RELOCATED R-U1-1; `LibraryClassifier` per
  R-U1-2; the tools per R-U1-3. `OwnCopies.pairIsDue` (per place — the backup clock's container due-check) added.
- Piece 3 — the old suites (VX-233's drill, VX-406's list, VX-380's attacker test, every test of deleted code):
  DONE (the counts are the Evidence line's). **The core half DONE** (`232561ddf` + this commit; `swift build --build-tests` green; `swift test` (debug):
  VariorumCoreTests **3296 tests in 430 suites passed** (2 known issues, pre-existing); VariorumMCPTests 383 tests, ONE
  red — `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (18.98 s against its
  15 s bound, the suite run under the full core load) — re-run ALONE green (3/3, 2.2 s): a load-timing flake, not this
  unit's; StringsWorkbook 32/32). VX-406: `CorpusRotationTests`, `StoreKeyEnvelopeTests` (+ `Format2`, the floor suite)
  DELETED with their subjects — the vault re-wrap suite that shared the envelope's file (`KeyVaultFormat
  .rewrappingPassphrase`, a SURVIVING subject) moved byte-for-byte to `VaultRewrapFormatTests.swift`; StringsWorkbook's
  `StoreUnlockTests` went at `c3d939c9e` (R-U1-3). VX-380: RESOLVED BY DELETION WITH ITS SUBJECT — the red
  `herAttackerScenarioTheNineArmsAfterTheSwitchToCastle` entered Castle through today's posture switch (`CorpusRotation`,
  `StoreEncryptionMigration.rekey`, today's format-2 key file), all deleted; arms 9 and 10 (the fake server's gate, the
  deployed function set — surviving subjects) stay byte-untouched; the protection road's attacker promise is pinned by
  `Protection/Scenario/Promises.swift`. Every test of deleted core code: DELETED whole — `BackupRestoreCandidatesTests`,
  `CustodyCollisionRuleTests`, `LibraryAdoptionTests`, `LibraryAsideCopiesTests`, `LibraryExportAndReturnerDrillTests`
  + `LibrarySameMacRestoreDrillTests` (13x's adoption door run call-for-call — their sync claims stand pinned in
  `RestoreMatrixTests` + `PurgeConvergenceTests`); TRIMMED to the surviving subject — `StoreEncryptionMigrationTests`
  (the re-key pins), `LibraryKeyLegDrillTests` (leg 2's wrap roads + collision rule gone; leg 5's consults stand, the
  encrypted arm consulting with the key in hand), `LibraryHotCopyAdoptionTests` (the LANDING halves gone with 13x's
  landing; the CONSULT halves stand — the source-never-written law, the verdict truths, and constraint (2) asserted on
  what the classifier's staged read reads), `LibraryClassifierTests` (R-U1-2: the pair verdicts collapse into
  `.encryptedLibrary`; the which-opens-which match and the fp8 name parser went with the readers; piece 5's pins added).
  New-road suites REWIRED, never weakened: `KeyFingerprint` for the envelope's fingerprint everywhere; today's key-file
  NAMES as fixtures (`PF.olderKeyFilename` / `.olderLegacyKeyFilename`, the same bytes); `CatalogTests`' parity pins keep
  today's parsers as a FROZEN ORACLE (`OlderBuilds` — the deleted parsers' rules copied byte-for-byte from `c629ae54f`,
  never a looser restatement). **The Mac test target: DONE** (this commit — `xcodebuild -scheme Variorum
  build-for-testing` GREEN; RUN is the orchestrator's stage batch, the list below). DELETED with their subjects (today's
  road whole): `PostureSwitchTests`, `PostureSwitchDrillTests` (VX-233, its own commit `b388fc994`),
  `Phase13pControllerTests`, `Phase13pLobbyTests`, `EncryptionFlowTests`, `VX110SignedOutCastleTests`,
  `VX202ReopenRaceTests`, `AppleRelinkDoorTests`, `ProtectionMigrationTests` + `…DrillTests`, `LobbyVaultRoadTests`,
  `VX209WayBackRoundTripTests`, `VX209LeavesCastleConfirmTests`, `VX209GuideWarningTests`, `KeyDoorTests`,
  `SyncEnrollmentTests`, `EnrollDirectionsTests`, `CustodyHandoverTests`, `CustodyReleaseTests`,
  `GatedSaveChoreographyTests`, `VX80CastleFollowRecoveryTests`, `VX338SharedBackupFolderTests`, `SnapshotPairTests`,
  `ConnectLibraryTests`, `ConnectDrillTests`, `StoreKeyBindingTests`, `VX206ProtectionLandingTests`,
  `LobbyAutoAskTests` (today's `StoreLobby`; the road lobby's auto-ask is `RoadLockTests`/`RoadRearmTests`'),
  `AppleKeyRoundTripTests`, `Phase13pKeyedDrillTests`, `ProtectionTierFaceTests`, `ProtectionSurfaceRenderTests`,
  `VX310TodayLobbyWitnessTests` (its own header: "revisit at VX-329"), `WordsCopyDoorTests` (its subject retired —
  `4c3e3b5f0`), `EncryptionTestSupport`, `VaultRPCEmulation` (orphaned). TRIMMED to the surviving subject, the trims
  named in each file: `KeychainOffMainTests` (the session's lazy load stands), `KeychainPartitionTests` +
  `KeychainTripwireTests` (the rules stand; today's families went), `Phase13pKeychainFactTests` (the platform facts
  stand), `Phase13pProtectionBrainTests` (the idle clock + its words), `Phase13pCopySweepTests` (keystone 4, rule 11's
  warning), `Phase13pSubstrateTests`, `Phase8ServicesTests` (the flat A1 suite), `DataSafetyFacesTests` (row 18's
  sanity check), `DataSafetyTests` (the 14+4 rule, the flat legs' integrity/far-leg/own-files pins; the run, log,
  runbook and single-flight pins now drive a SCRIPTED pair road), `BackupFutureStampTests` (the flat readers; the
  weekly export and the face's stale rule stand), `SessionTokenBindingTests` (corner 47's legacy legs),
  `LibraryPortabilityDoorTests` (13x's adoption flow), `TutorialWalkTests`' privacy suite (copy §7's chapter → the
  road's three lessons + the register rule). REWIRED onto the road, the claim unchanged: `AppBootstrapOffMainTests`
  (the planted road, the harness's staged opener), `SettingsLockCloseTests` (`LockWorld` + a holdable opener — the
  crossing into Castle is the reopen road held mid-flight), `LibraryHandOffTests` (the road's act; `PickedCopy` reads
  the pair back; the key file opens with the words), `ProtectionBackupHookTests` (`attach`/`runPair` — the writer),
  `ProtectionRoadSwitchTests` (the pin FLIPPED: `live(debug: false)` is true), `ReadmeStartHerePlanTests` +
  `TutorialNewRoadChapterTests` (every store, both variants), `SettingsAccountSurfaceTests`, `VX379PaneRowsTests`,
  `RoadCrossingSurfaceTests`, `ProtectionPaneRoadRowTests`, `WordsConcealedClipboardTests`, `CopyRegisterPinTests` +
  `TravellingDotsIndicatorTests` (their file lists: today's files out, the relocated `ProtectionCopy.swift` in);
  today's store id assertions in the road route tests INVERTED (no file of today's names beside the library);
  today's test init (`testOpener:gate:testPresence:`) stripped from every road harness. RELOCATED byte-for-byte: the
  `SurfaceComposition` read (`VariorumTests/SurfaceComposition.swift`), the `AppleKeyRoundTrip` switch. **The phone's
  test target: DONE** (this commit — `xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS Simulator'
  build-for-testing` GREEN): DELETED `MobileProtectionSurfaceTests` (today's phone lobby), `MobileEncryptionTestSupport`,
  the phone's `VaultRPCEmulation` (orphaned); `MobileProtectionTests` rebuilt to its surviving subjects (the encrypted
  birth and the at-open migration; the lock's teardown factory `mobileWillLock`, driven directly — the bootstrap
  calling it before the pool closes is the Mac's `RoadLockRouteTests` pin; the relock policy and coordinator REWIRED
  onto `RoadRelockPolicy`; the locked capture; the floor) — its lobby, copy-grammar, one-secret, follow and replay
  suites went with today's road; `MobileTravellingDotsTests` (today's lobby pin), `MobileTutorialWalkTests` (today's
  posture names and floor constants — the paragraphs stay pinned verbatim), `MobileStructuralTests` (the register
  walk's file list: today's files out, `ProtectionCopy.swift` + `ProtectionWords.swift` in). **Piece 3: DONE.**
- Piece 4 — ⌃⌘L declared on `.lockLibraryNow` with its helper row (P-VX309-U1c-4 (b)): DONE (this commit;
  `build-for-testing` GREEN). `shortcutLabel: "⌃⌘L"` on the declaration (`CapabilityRegistry.swift`), its one key
  wiring in `EditorCommands.keyEquivalent(for:)` (`("l", [.command, .control])` — the walk's
  `everyShortcutLabelHasExactlyOneKeyWiring`; the File menu's call site and its chord unchanged), and its row in the ⌘/
  helper's "Windows & panes" group (`everyDeclaredShortcutIsFindableInTheHelper`; Settings ▸ Shortcuts and its search
  read the same list) — words PROVISIONAL P-VX329-U1-7. `Capability.swift`'s comment says the (b) arm now stands. The
  pin: `RoadIdleDialRouteTests.lockLibraryNowIsOneDeclarationTheMenuAndThePaneRender` gains the label, the wiring, the
  helper row and one-act-one-chord (red on the pre-switch tree by construction — no label). Collision sweep re-run at
  this tip: ⌃⌘L is the only ⌃⌘L in the key table and in every `.keyboardShortcut(` call site.
- Piece 5 — the honest-refusal check (the §6 OPEN DESIGN NOTE): DONE as pins; the Mac half's RUN is PENDING (the
  stage batch). THE CLASSIFIER (core — VERIFIED green in `swift test`, 0ab016636's run): an encrypted store with an older
  Variorum's key file beside it (`variorum-keys-<fp16>.json` or `variorum-keys.json`) is `.encryptedLibrary` naming that
  file, never `.bareStoreWithoutKeyFile`; names alone, any bytes; the keyless verdict only when no key-file-shaped name is
  there (`LibraryClassifierTests`: `aPreDesignLibraryWith…IsNamedNeverKeyless` ×3,
  `theClassifierNamesByNameAloneAndOnlyTheShapesAnyBuildWrote`). THE TWO FACES (Mac — `PreDesignStoreRefusalTests`,
  PENDING the stage run): the LIVE SLOT holding such a store routes to the lobby with RULE 27'S REFUSAL — "No key file
  opens this library. Variorum looked beside the library, inside every backup, and in this Mac's keychain, and found none
  that opens it. Without one, there is nothing left to open." (§7c (3)) and its doors (Restore from Backup…, Open
  Library…, Start a New Library — which steps the library aside WHOLE into Previous Libraries, never deleted); signed in,
  its account line ("This library syncs with your account. Sign in and enter your passphrase or twelve words to bring
  your writing back."); no typed or Touch ID road; the older key file and the store only read; nothing minted. A PICKED
  copy of that shape → "This file couldn't be read as a library." (with no key file at all: the keyless refusal, true).
  **What the built shape cannot do (recorded, not built — the morning bundle's):** neither face NAMES the older format or
  the road out (export from the old build; sign into sync; start fresh). Rule 27's sentence is honest on its letter (no
  key file OPENS it — this build reads none of today's) and claims nothing keyless, but it does not say an older
  Variorum's key file is there. Naming it needs a new fact (the road's facts do not see foreign names, rule 26) and new
  words — hers.
- Piece 6 — the sweep table: DONE (this commit; the table below). Comments that still described today's road as
  present (the "nil on today's road" family, the tripwire's leaf log line, the vault-bootstrap brain's caller note, the
  retention rule's home, the harness's init) reworded to what is true — history kept, the claim made true; every
  source-string pin that held on the pre-cut tree and no longer does was found by a scan (pre-cut product sources vs
  now) and fixed (`EmptySlotDoorsSurfaceTests`, `FollowDoneNoticeTests`, `U2WordsTests`, `RoadAccountSurfaceTests`).
- Evidence (at `df9835835` + the final tidy commit; every run foreground, in sequence, on the Pro):
  - `swift test` (debug): **VariorumCoreTests 3296 tests in 430 suites PASSED** (2 known issues, pre-existing);
    **VariorumMCPTests 383 tests in 71 suites PASSED**; **StringsWorkbook 32 tests in 4 suites PASSED**; EXIT 0.
  - `swift test -c release` (the acceptance): **VariorumCoreTests 3267 tests in 425 suites PASSED** (2 known issues;
    the DEBUG-only pins compile out — VX-406's release-floor reds are GONE with their suites, VX-380's with its
    subject); StringsWorkbook 32/32; VariorumMCPTests 382/383 — ONE red, the same load-timing flake as debug run 1
    (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 18.2 s against its 15 s
    bound under the full suite's load), re-run ALONE under `-c release` GREEN (3/3, 2.2 s). Not this unit's (the MCP
    harness is untouched) — FINDING below.
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' build-for-testing`: GREEN.
  - `xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' build-for-testing`: GREEN (the iOS
    app target and its tests).
  - `xcodebuild -scheme Variorum -configuration Release build` into this unit's own DerivedData (no Variorum instance
    running — checked first; nothing near `/Applications`): GREEN — §6's "a Release-configuration build of the Mac app
    compiles".

**THE SWEEP TABLE (piece 6 — every deleted symbol `rg`'d as a WORD across `Sources/`, the app's four source and test
folders, `Tests/`, `Tools/` and `Package.swift`, at this commit; DerivedData excluded):**

| Symbol(s) | Remaining | Cells |
|---|---|---|
| `CustodyCollisionRule` `LibraryAsideCopies`(code) `StoreKeyKeychain`(code) `deviceKeychain*` `ensureStoreIdentity` `mintStoreIdentity` `StoreUnlock`(code) `RehearsalFixture` `ScratchLibrary` | 0 code | DELETED |
| `AppleKeyCustody` `AppleKeyLeaves` `AppleRelinkModel` `CeremonyAct` `ConnectLibraryError` `connectLibrary` `CustodyHandover` `FollowNotice` `GatedSaveChoreography` `InMemoryStoreKeyGuardBacking` `KeyDoorModel` `KeyDoorView` `LibraryOpenSheet` `LobbyVaultRoad` `MobilePostureSheets` `MobileProtectionCeremonies` `MobileProtectionSheet` `PassphraseSetModel` `PostureSwitchModel` `ProtectionLegs` `ProtectionNoticeBar` `RawKeyCustody` `ScriptedDialsBox` `ScriptedEnvelopeBox` `ScriptedStampsBox` `StoreLaunchRoute` `SyncCustodyScope` `SyncCustodySession` `VaultTie` `WordsCeremony` `existingBackups` `wireOneSecretHooks` `testPresence` `waitingForICloudKeychain` `awayChoices` `awayLabel` `checklistRows` `postureCard` `privacyLessonTwoTitle` `lockTimeCopy` `folderHoldingPair` `protection.restoreHoldStands` | 0 anywhere | DELETED |
| `StoreKeyEnvelope` `StoreKeyEnvelopeError` `StoreIdentity` `BackupRestoreCandidates` `LibraryAdoption` `LibraryOpenModel` `BackupRetention` `PostureSwitch` `PostureCopy` `PostureFollowModel` `KeyDoorCopy` `EncryptionSession` `EncryptionView` `SyncCustodyRecord` `E2EEKeychainStorage` `E2EECustodyLeaves` `DeviceKeyStore` `DeviceKeySyncProvider` `AppleKeyKeychain` `StoreKeyGuard` `StoreKeyGuardKeychain` `StoreLaunchGate` `StoreLobby` `StoreAtOpenMode` `ProtectionDials` `ProtectionMigration` `LegacyLegs` `SecretCheckModel` `SyncEnrollmentModel` `SyncEnrollmentView` `ProtectionStatusRow` `MobileStoreLockView` `WordsCopyDoor` `adoptLibrary` `copyKeyEnvelope` `integrityCheck` `performBackupIfDue` `performPrimaryLeg` `performSecondLeg` `performLockTimeCopyIfDue` `restoringByTheDoor` `opensOnTheNewRoad` `onTheNewRoad` `StoreEncryptionMigration.rekey` `wordsCopied` `testOpener` `LibraryClassifier.pairedKeyFile` | 1–7 each | COMMENT-ONLY — history notes saying the symbol left at VX-329 U1 (each read; none describes it as present), the pins that assert ABSENCE (`!contains`), the relocation notes of what moved byte-for-byte |
| `backupNameFingerprint`, `pairedKeyFile` | `CatalogTests` | NEW-ROAD TEST ORACLE — `OlderBuilds`, today's parsers frozen byte-for-byte so the catalogue keeps reading the names older builds left on disk |
| `StoreLaunchGate`, `StoreLockView` in `Tools/StringsWorkbook/Tests/WorkbookPlanTests.swift:84,92`, `InventoryParserTests.swift:43` | 3 | FIXTURE TEXT — inventory lines inside the parser tests' multi-line literals (paths as data, never read) |
| `StoreLockView` (the file) | 6 | NEW-ROAD — the file keeps its name and holds `RoadLockView` (the pins read it by path) |
| `Posture` | 6 code | NEW-ROAD — `Promises.swift`'s own test-local `struct Posture` (the scenario's), another type; the rest comments (`FallbackCanary`'s unrelated "Posture (memo)") |
| `newRoad` | 4 code | NEW-ROAD — a local variable named `newRoad` in `DataSafetyRoadCountsTests`; the rest comments and the fork-absence pin's literals |
| `VaultBootstrap` | 21 code | KEPT, FLAGGED — the 14b vault brain (`Crypto/VaultBootstrap.swift`) and its suite; its CLI shell deleted (R-U1-3); no app caller (L1 flags) |
| `rekeyLibrary`, `RotationMarker`, `CorpusRotation` | Sync/ + 2 test lines | L1's — the fence (the flags below) |
| `StorePlaintextExport` | 28 | NEW-ROAD — the decrypted export's writer and the classifier's export check (kept) |
| `LocalMachineryRecreation` | its file, its suite, `ProtectionRecordSchemaTests` | KEPT, FLAGGED (F-U1-9) — orphaned in product since `LibraryOpenModel` left; a new-road pin reads it |

**L1 FLAGS (Sync/ references to deleted symbols — the orchestrator's carve; file:line, symbol):** none of these
breaks the build today (the symbols live IN Sync/ until L1 deletes them); every writer of the rotation marker is gone
with today's posture switch, so these are now readers of a marker nothing sets.
- `Sync/CorpusRotation.swift` whole (`CorpusRotation`, `RotationMarker`, `RotationSecrets`, `CorpusRotationError`) — no
  caller outside Sync/ and the two test lines below remain.
- `Sync/SyncEngine.swift:113,122` — the round's preflight reads `RotationMarker.isSet` → `SyncError.accountRekeyIncomplete`.
- `Sync/PurgeJanitor.swift:21,79,89–90,670` — the janitor's preflight, the same read and throw.
- `Sync/SyncSchema.swift:672–680,773–774` — `SyncError.accountRekeyIncomplete` (case + its description arm); the app's
  rendering of it (`SyncRowFace`'s rekey-incomplete arm, today's `CeremonyAct`) is DELETED, so a thrown one falls to the
  row's generic engine-error face.
- `Sync/SyncTransport.swift:245` — a comment naming `CorpusRotation.horizonWait(forServedMillis:)`.
- `Sync/SyncSchema.swift:387` — a comment naming `StorePlaintextExport` (KEPT — new-road, comment-only; no action).
- Tests that read the Sync/ symbols L1 deletes (not Sync/ files; flagged so L1's carve takes them in the same commit):
  `Tests/VariorumCoreTests/AccountLifecycleTests.swift:113` (`RotationMarker.isSet`; comments :11, :146 name
  `CorpusRotationTests`), `Tests/VariorumCoreTests/AuthRLSDDLTests.swift:2230` (`CorpusRotation.horizonWait`).
- OUTSIDE Sync/, kept and flagged (the 14b vault's brains, read by Sync/ and Auth/): `Crypto/KeyVaultClient.swift`,
  `Crypto/VaultEnrollment.swift`, `Crypto/VaultBootstrap.swift` — their consumers are `Sync/CorpusRotation`,
  `Auth/AccountLifecycle`, and (VaultBootstrap) nothing since its CLI shell left (R-U1-3). `KeyVaultFormat` is the NEW
  road's too (`WireVaultLeaf`, `Protection/Model/Secrets.swift`, `Protection/Wire/AccountVaultClient.swift`) — KEPT.

**STOP-AND-FLAG ITEMS (a face only today's road provided) — each left as found or minimally rewired, for the
orchestrator's ruling or her morning bundle; none invented:**
- **F-U1-1 — the session-stamped owner.** `AppBootstrap.finish()` still stamps `OwnerIdentity` from the signed-in
  session (`roadInputs.sessionFact`); §6's list names "the session-stamped owner", but its replacement (the library's
  bound account as owner — vx-266 §3.8) is unbuilt, and deleting the stamp would leave synced rows ownerless. KEPT, with
  a STOP-and-flag comment at the site.
- **F-U1-2 — Send Library.** Today's producer was deleted; the door now runs the road's own act (R-U1-6). The door, its
  words and faces are unchanged; whether the act's pair (store + format-3 key file) is the hand-off she wants is the
  orchestrator's to confirm. PROVISIONAL P-VX329-U1-1.
- **F-U1-3 — the phone's Protection screen and its notice bar** (`MobileProtectionSheet`, `MobileProtectionCeremonies`,
  `MobilePostureSheets`, the shell's notice bar) were today's road whole and are DELETED; the phone's road faces are
  VM-8's. Until VM-8 the phone's Settings has no Protection row (the phone already refuses marker 13 → 14 by her word).
- **F-U1-4 — `RESTORE.md`** (`DataSafetyCopy.runbook`, dropped beside every backup run): its text describes TODAY's
  restore (the flat snapshot + the key file, Finder steps); kept byte-equal to `notes/DataSafetyRunbook.md` (the pin), its
  posture interpolations inlined as the literal words they rendered. Its rewrite to the pair road is words — hers / U2's
  truth-check (VX-379), never this unit's.
- **F-U1-5 — the phone's pocket guide's privacy chapter** (`ProtectionCopy.privacyLessonOneParagraphs` /
  `privacyLessonTwoParagraphs`): copy §7's chapter, kept verbatim; lesson 2 describes today's postures. The Mac's guide
  already seeds the road's chapter. Same owner as F-U1-4 (VX-379 / VM-8). PROVISIONAL P-VX329-U1-6.
- **F-U1-6 — the sync row's key doors.** Today's keys-locked / keys-replaced rows offered today's ceremonies; with
  those deleted the rows offer `Account…` (the road's account sheet). PROVISIONAL P-VX329-U1-4.
- **F-U1-7 — the Account sheet's single tab.** The Encryption tab (today's E2EE flows) is deleted; the picker now holds
  one segment. A face nit for the orchestrator (hide the picker, or leave it) — not invented here.
- **F-U1-8 — Delete Account's error wording.** Today's mapper (`EncryptionSession.message(for:)`) is deleted; the error
  now renders `String(describing:)`. The arms that mapper had for the account errors could be re-homed byte-for-byte if
  the orchestrator wants them — flagged rather than re-invented.
- **F-U1-9 — the orphaned `LocalMachineryRecreation`** (`Persistence/`): its only product caller was 13x's
  `LibraryOpenModel` (deleted); the new road brings an export in through the import road. A NEW-road suite pins it
  (`ProtectionRecordSchemaTests.thePlaintextExportLeavesItBehindAndTheRecreationMakesItEmpty`, VX-306 U1a), so it is KEPT
  rather than delete a new-road test's half; the orchestrator rules (delete with that pin's second half, or keep).
- **F-U1-10 — `StoreEncryptionMigration.migrateIfNeeded`** (the 13p plaintext → encrypted at-open migration) is KEPT:
  `AppDatabase.openStore` composes it and the new road opens through that primitive (a no-op on an encrypted store);
  rule 26 says a pre-13p plaintext store is not handled, so it may be dead in practice — not on §6's list; flagged.

**PROVISIONALs / FINDINGS:**
- P-VX329-U1-1 — Send Library on the road's `sendLibrary` act (F-U1-2).
- P-VX329-U1-2 — the decrypted export's facts from the open library (R-U1-7): the typed passphrase is checked against
  the library's key file off the main actor (`RoadStandingModel.checkPassphrase`), `passphraseIsSet` from the same file.
- P-VX329-U1-3 — the backup clock's far leg: the picked folder's pair is written only on a run that writes the
  container's (a run that finds the container up to date writes no far pair even when the far folder is due) — the
  narrowest reading of "the pair road is the writer"; widening it is a new-road behavior change (out of scope).
- P-VX329-U1-4 — the sync row's key doors → `Account…` (F-U1-6).
- P-VX329-U1-5 — the phone's root composes the road's key provider and the bound-account read unconditionally (as the
  Mac's), its relock reading `RoadRelockPolicy`.
- P-VX329-U1-6 — the phone's guide keeps copy §7's chapter verbatim until VM-8 (F-U1-5).
- P-VX329-U1-7 — the ⌃⌘L helper row's words: "lock the library now — in Castle, where it can lock; it closes and
  forgets its key until you unlock it again" (her copy pass).
- FINDING — `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` flakes under the
  full suite's load (18–19 s against its 15 s bound — 2 of 3 full runs, debug and release; alone 3/3 green in 2.2 s). The
  MCP harness is untouched by this unit; a ticket's (the orchestrator's to file).
- FINDING — a warning this unit introduced was fixed in place (`LibraryOpenDoor`'s weak capture); no other new warning in
  a file this unit touched.

**MAC-SUITE LIST (the orchestrator's stage batch — every app suite this unit added, rewired or trimmed; all COMPILED,
none RUN).** The bootstrap's route changed for every launch, so the whole Mac suite is the honest closing run; the list
is the minimum. Mac (`-only-testing:VariorumTests/<Suite>`): the WHOLE `VariorumTests/Protection/` folder (every road
suite — the harness's init changed under all of them; NEW: `PreDesignStoreRefusalTests`), plus
`AppBootstrapOffMainTests`, `SettingsLockCloseTests`, `SettingsAccountSurfaceTests`, `LibraryHandOffTests`,
`LibraryPortabilityDoorTests`, `DataSafetyTests` (`BackupRunTests`, `DataSafetyRunbookTests`, `BackupSingleFlightTests`),
`DataSafetyFacesTests` (`MarkdownInsuranceTests`, `SyncSafetyFaceTests`), `BackupFutureStampTests`,
`Phase13pSubstrateTests` (`MarkdownInsuranceFlipTests`, `AcknowledgmentsCopyTests`, `Phase13pInsuranceFaceTests`),
`Phase13pProtectionBrainTests` (`ProtectionCadenceTests`), `Phase13pCopySweepTests`, `Phase13pKeychainFactTests`
(signed host), `Phase8ServicesTests`, `KeychainOffMainTests` (`AuthSessionLazyLoadTests`), `KeychainPartitionTests`,
`KeychainTripwireTests`, `SessionTokenBindingTests` (signed host), `PlaintextExportDoorTests`, `ICloudDriveOfferTests`,
`TierAndOnboardingTests` (3 suites), `SyncOutOfDateFaceTests`, `CopyRegisterPinTests`, `TravellingDotsIndicatorTests`,
`EncryptionExplainedDrillTests`, `TutorialWalkTests` (`TutorialPrivacyChapterTests` and its siblings),
`CapabilityRegistryTests` (piece 4's guards). Phone (`VariorumMobileTests`, simulator): `MobileProtectionTests` (6
suites), `MobileStructuralTests` (`MobileCopyRegisterSweepTests`), `MobileTravellingDotsTests`, `MobileTutorialWalkTests`
(`MobilePocketGuidePrivacyTests`), `MobileKDFLatencyTests`. Opt-in, unchanged in kind: `ICloudAppleKeysLeafTests`
(`VARIORUM_APPLE_KEY_ROUND_TRIP=1`).

### U3 RECORD — VX-423, ONE REFRESH AUTHORITY (Opus implementer, 2026-10-22; IN PROGRESS)

**Not done in U3, first:** PENDING — filled at the close.

**Preflight (complete, not delegated):** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md` whole;
this plan §1–§6 (the CUT, the environment traps, §6b — this brief) and the U1 RECORD (the shape inherited); the VX-308
F-U1-1 trace and its routing (`notes/plans/vx-308-accounts-key-doors.md` R-3, the arbitration, the hand-forwards); the
code — `AuthSession.swift` WHOLE, `AppServices.swift` WHOLE, `AppBootstrap.swift` WHOLE, `FollowingSessionProvider
.swift`, `WireVaultLeaf.swift`, `ProtectionSystem.swift`, `ProtectionOpenRoad.swift`'s `RoadInputs`/`ComposedRoad`, the two
app roots' `AppServices(` sites (`VariorumApp.swift`, `VariorumMobileApp.swift`), the core seam (`Auth/UserSession.swift`)
and the vault client's session use (`Protection/Wire/AccountVaultClient.swift`); every `AuthSession(` construction site
(`rg "AuthSession(" App/ Sources/` — product: `AppServices.swift:182`, `WireVaultLeaf.swift:40`; the rest tests); every
reader and writer of the session's keychain item (the one WRITER is `AuthSession` through its store; the readers are
`OwnerIdentity`'s install, `RoadInputs.live`'s `sessionFact`, the leaf's `signedInUser`). `LobbyVaultRoad` (the brief's
name for the second instance's old home) was DELETED at U1 — the second instance today is the protection road's vault
leaf, traced below from the current code. Machinery: the orchestrator's own commits interleave on this branch (the
switch-day script, the release notes) — every U3 commit is pathspec-limited, rebased before each push.

**THE MECHANISM, re-traced on the current tree (inputs → wrong state):**
1. Instance A — `AppServices.init` (`AppServices.swift:182`) mints `AuthSession(configuration: ProjectConfig
   .variorumAuth, store: .keychain(scope:))` when no `auth` is passed; both app roots pass none (`VariorumApp.swift:210`,
   `VariorumMobileApp.swift:88`). A rides the sync transport (`makeSyncTransport(auth)`), the account lifecycle, sign-in,
   sign-out and Delete Account. Made per `.ready`, dies at relock (the root's `onWillLock` nils the services).
2. Instance B — every `roadInputs.compose()` (each open, each lock, the empty-slot doors, the bring-in) runs
   `ProtectionSystem.live(variant:)` → `ProtectionSystem.init`'s default vault → `WireVaultLeaf.live(scope:deviceName:)`
   → a `FollowingSessionProvider` whose `make` mints ANOTHER `AuthSession` over the SAME keychain item
   (`WireVaultLeaf.swift:40`) at its first call for a user, kept for as long as that user stays signed in. The open
   library's road session holds that leaf for the whole `.ready` (the pane's vault reads, the account acts, the
   crossings' preflights all reach it).
3. Each `AuthSession` reads the item ONCE (`ensureLoadedFromStore`) and keeps its tokens in memory; its refresh is
   single-flighted within ITSELF only (`refreshTask`). The two never re-read each other's writes.
4. The race: B reads RT1 (a pane read, the access token still fresh). An hour on, A's sync round refreshes RT1 → RT2
   (saved). B's next vault read finds its cached access token expired and refreshes with its cached RT1 — GoTrue's
   reuse detection (outside its short reuse interval) answers `refresh_token_already_used` and REVOKES THE FAMILY, RT2
   included. A's next refresh is refused: sync stops until she signs in again (the board's VX-423 symptom). The mirror
   order (A stale behind B) burns the same way.

**MY READINGS (each the brief's letter as I read it — building on them):**
- **R-U3-1 — THE PREFERRED SHAPE, NO FORK.** One `AuthSession` per process, owned by `AppBootstrap` (the process-lived
  composition-root object — `newRoadSyncKeys`' precedent: the bootstrap owns a seam object, the root hands it to
  `AppServices`), handed to BOTH consumers: the services (`AppServices(auth:)` — REQUIRED, the default mint deleted; both
  roots pass `bootstrap.auth`) and the protection road (`RoadInputs.live(variant:auth:)` → `ProtectionSystem
  .live(variant:session:)` → `WireVaultLeaf.live(deviceName:session:)`). The narrower alternative is NOT taken: the
  one-instance shape breaks no lifecycle — the authority lives on the bootstrap, across every locked window, lobby and
  reopen; the services that die at relock only BORROW it (their `onChange` handler is replaced at each `start()`).
- **R-U3-2 — `FollowingSessionProvider` DELETED, ITS JOB DONE BY CONSTRUCTION.** Handed the one authority, the leaf
  follows a sign-out and a sign-in to another account because every sign-in and sign-out in the process lands in that
  actor (`AppServices.signInWithVariorum`/`signOutVariorum`/`deleteAccount` are the only doors — `rg`'d). Kept, the
  provider would wrap the same instance with a per-call keychain read and a duplicate `notSignedIn` guard — dormant
  code. R-3's claim (VX-308) is re-pinned on the new shape (P3 below); its old suite (`FollowingSessionProviderTests`)
  goes with its subject.
- **R-U3-3 — A SYSTEM COMPOSED WITHOUT THE AUTHORITY RIDES NO ONE'S SIGN-IN.** `ProtectionSystem.init` (the test worlds'
  door) takes `session:` defaulted to a provider that refuses `notSignedIn` — exactly what the per-system session it
  replaces answered over a throwaway scope holding no session, so no test world's vault refusal changes; production's
  door (`ProtectionSystem.live`) REQUIRES the session. Nothing but the bootstrap mints an `AuthSession`.
- **R-U3-4 — PER PROCESS, NOT PER MACHINE.** A second process over the same scope (two instances of one build) is
  outside the unit (the brief: "one refresh authority per process"); the readers that read the item directly
  (`OwnerIdentity`, `sessionFact`) read, never refresh, and are untouched (F-U1-1's owner stamp is U1's flag).

**THE PINS (planned; each named with its red-on-old in LIVE STATUS):**
- P1 — THE TWO-REFRESHERS RACE (behavioral): a fake GoTrue that rotates every refresh token and, on a reused one,
  answers `refresh_token_already_used` and revokes the family; ONE stored token; the services' consumer (the authority
  itself, as `AppServices` holds it) and the vault leaf as production composes it (`WireVaultLeaf.live(deviceName:session:)`
  over a scripted vault endpoint); the sequential race of step 4 and the concurrent one (both consumers past expiry at
  once → ONE refresh request). Plus the mechanism's witness: two instances over one stored token DO burn on this fake (so
  P1's green is never vacuous). Red-on-old by behavioral revert (the leaf riding its own second instance over the same
  stored session — the pre-fix `make`).
- P2 — THE COMPOSITION (source): exactly one `AuthSession(` construction in product code, in `AppBootstrap`; both roots
  hand `auth: bootstrap.auth`; the production init composes `RoadInputs.live(variant: variant, auth: auth)`;
  `FollowingSessionProvider` gone. Red on the pre-fix tree by construction (two constructions, neither in the bootstrap).
- P3 — R-3 ON THE NEW SHAPE (regression guard, green on both sides by design): the leaf, handed the authority, follows a
  sign-out and a sign-in to another account.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece R — this record skeleton: DONE (this commit).
- Piece 0 — the headless harness: DONE (not durable — this session's scratchpad `u3-harness`; the VX-308/309 recipe
  pointed at this worktree: tools 6.2, macOS 26, the app target's concurrency settings — default `MainActor`,
  `NonisolatedNonsendingByDefault`, `InferIsolatedConformances`, `MemberImportVisibility` — and the TEST target's WITHOUT
  the default `MainActor` (the Xcode test targets carry none; the earlier recipe gave both targets the app's, which
  `KeychainOffMainTests` cannot compile under), the worktree's core by path; its `Variorum` target symlinks every
  `Shared/Protection/*.swift` but `ProtectionBackupHook.swift` — `WireVaultLeaf.swift` and `FollowingSessionProvider
  .swift` REAL now (the earlier recipe stubbed the leaf nil) — plus `Shared/AuthSession.swift`, `KeychainCustody.swift`,
  `LibraryOpenCopy.swift`, `WordsCopyDoor.swift` and one stub file (`DeviceName`, `BackupDestination`, a `ProjectConfig`
  pointed at a host never dialled); its test target symlinks the VX-309 harness's 57 protection files, the app's
  `AuthSessionTests` + `KeychainOffMainTests` (the auth suites), this unit's suite, and the `RoadWorldError` stub).
  **HARNESS BASELINE on the pre-fix tree `4f6e3edef`: `✔ Test run with 368 tests in 59 suites passed`** (0 skipped).
- Piece 1 — P2 committed BEFORE the fix (`OneRefreshAuthorityTests.swift`, `OneRefreshAuthorityCompositionTests`): DONE
  (this commit). **RED on the pre-fix product sources** (the harness, `--filter OneRefreshAuthority`): `✘ Test run with 4
  tests in 1 suite failed … with 7 issues` — the mints found `["WireVaultLeaf.swift": 1, "AppServices.swift": 1]`, neither
  root hands `auth: bootstrap.auth`, the road and system lines absent, `FollowingSessionProvider` present (its file and the
  leaf's use). Green is piece 2's.
- Piece 2 — THE FIX + P1/P3: DONE (this commit). `AppBootstrap.auth` — the process's one authority, minted once by
  `AppBootstrap.authority(_:)` (production: over the scope's Keychain item; the test init: over memory, signed out);
  `RoadInputs.live(variant:auth:)` → `ProtectionSystem.live(variant:session:)` (REQUIRED) → `ProtectionSystem.init`'s
  `session:` (defaulted to `NobodySignedIn` — R-U3-3) → `WireVaultLeaf.live(deviceName:session:load:)` (`scope:` gone with
  the keychain read it served; `load:` the vault endpoint's pin seam, production never passes it);
  `AppServices.init(auth:)` REQUIRED (the default mint deleted); both roots pass `auth: bootstrap.auth`;
  `FollowingSessionProvider.swift` DELETED and its suite (`FollowingSessionProviderTests`, in `RoadAccountFacesTests
  .swift`) with it, a pointer left at its place; the headers of `AuthSession`, `AppServices`, `WireVaultLeaf`,
  `ProtectionSystem` made true. P1 + P3 + the witness added to `OneRefreshAuthorityTests.swift`
  (`OneRefreshAuthorityRaceTests`: `aRotationByTheServicesNeverLeavesTheVaultLeafASpentToken`,
  `bothConsumersPastExpiryAtOnceRefreshOnce`, `twoInstancesOverOneStoredTokenBurnTheSessionOnThisFake`,
  `theVaultLeafFollowsASignOutAndASignInToAnotherAccount`). **The harness on the fixed tree: `✔ Test run with 375 tests
  in 60 suites passed`** (0 skipped; 368 − the deleted provider test + this unit's 8; P2 GREEN 4/4). The Mac and phone
  builds: PENDING (piece 4).
- Piece 3 — P1's behavioral revert: IN-PROGRESS — **REVERTS STARTING on the committed tree `550ff123a`** (restore =
  `git checkout -- App/Variorum/Shared/AuthSession.swift App/Variorum/Shared/Protection/WireVaultLeaf.swift` + removing
  the restored `FollowingSessionProvider.swift`, verified by `git status`/`git diff --exit-code` clean). THE REVERT (the
  pre-fix vault-leaf composition, over the pin world's stored session and endpoint): `FollowingSessionProvider.swift`
  restored byte-for-byte from `550ff123a^`; `WireVaultLeaf.live` composes `FollowingSessionProvider(signedInUser: {
  <the authority's store>.load()?.userID }, make: { <a second AuthSession over the same store, endpoint and clock> })`
  — exactly the pre-fix `signedInUser` (the stored session's user) and `make` (another instance over the same item),
  the store and endpoint being the pin world's instead of the scope's Keychain item and the production project (no
  network); two REVERT-ONLY accessors on `AuthSession` expose its store and mint that sibling.
- Piece 4 — evidence: the harness (P1–P3 + the app's protection/auth suites it carries), core auth/account + protection
  sets debug AND release, `build-for-testing` both targets: NOT-STARTED.

## 6. THE KICKOFF RECORD (2026-10-22, the orchestrator — session `vx-329`, Fable, overnight mandate)

**Her mandate (the /architect-phase argument, faithful):** the only session tonight — no coordinator, hold
`Tools/stage` directly. Run U1, U3, the riders and the throwaway rehearsal to completion, then pause with everything
staged for her hands — the byte-copy rehearsal of her real store waits for her morning. Cold reviews are Fable.
Release 0.10. `pg_temp` has her go: rehearse it on the throwaway; production rides the marker-14 deploy set at her
morning go.

**Preflight done (read in full, never delegated):** CLAUDE.md + canon · SessionResiliencyProtocol · CastleRules WHOLE
· SyncSpec WHOLE · SurfaceContracts (The app, Doors — protection + portability) · the VX-329 ticket + all seven-input
comments (read via the Linear API) · the rider tickets' bodies (VX-423, VX-213, VX-461..470, VX-473, VX-379, VX-234,
VX-406, VX-233) · vx-308 §5R + REHEARSAL RECORD + WALK RECORD · vx-309 §8–§9 · vx-266 §3.15 · QUESTIONS #237 whole ·
the master plan + in-flight table · TICKETS.md. Workspace: branch `vx-329-release-switch`, worktree
`~/dev/variorum-vx-329` (Pro), in-flight row pushed on main (`c6b093258`), VX-329 + VX-423 In Progress in Linear.
The Sync/-custody slot is HELD by this effort; no other effort is in flight.

**Sizing, said plainly (the guidance's say-so):** U1 and U2 are the two phase-sized units; U3 and the rider batch are
small units. All four were ruled IN by her at the 2026-10-22 sitting (the kickoff block), so the shape is hers.

### THE CUT (final; one acceptance unit per implementer session, the orchestrator's own legs lettered L)

- **L0 (the orchestrator, Fable — Sync/ is Fable work): THE LOCKSTEP COMMIT.** One commit:
  `SyncSchema.lockstepVersion` 13 → 14 + `17_phase_vx307_vault.sql` registered in `AuthRLSDDLTests.lockstepFiles`
  (the drift pin enforces the pairing — the vx307 checklist's preflight row) + the four
  `MCPGrantSchemaTests` marker pins and `VX307VaultArtifactTests` read 14. Headless green before U1 spawns.
  Consequence stated: from this commit the branch's builds speak marker 14 — they sync only against the throwaway
  (already marker 14 since §5R) until the production deploy at her morning go; the dev store doesn't sync, so
  nothing strands. **No `/Applications` refresh this phase until the production deploy lands (the skill's
  lockstep-hold rule).**
- **U1 (Opus implementer #1, Fable cold review): THE SWITCH.** `ProtectionRoad.live` → true for every build;
  `opensOnTheNewRoad`'s dev-store fence dissolves (every store, every variant, both configurations take the new
  road; the bootstrap's `!newRoad` arms die — `AppBootstrap.swift:217` is the seam). Delete today's whole deciding
  and writing road per the ticket + vx-266 §3.15 (superseded where the ticket says "nothing is kept read-only" —
  the legacy readers go entirely): the old envelope (`StoreKeyEnvelope`), `RawKeyCustody`, `Posture.derive`, the
  13p read-through, `effectiveGate`/`landCustody`/`CustodyCollisionRule`/`ensuredEnvelope`, custody-by-library-ID,
  several-key-files-per-folder + newest-modified, the `switchPending`/`thisDeviceOnly` defaults, the five
  "enrolled" definitions, the session-stamped owner, Castle settings in UserDefaults, the shared never-deleted
  Apple key as a live road + 17m's Re-link, the silent follow into Standard, VX-202's belts, the duplicate safety
  copy, the old confirm/guide lines, the Finder-revealing restore, the identity-only silent sync item, today's flat
  `StoreBackup` leg where it is today's road's writer, `PostureSwitch`/`PostureSwitchModel`/`PostureFollowModel`/
  `PostureCopy`/`EncryptionSession`/`AppleRelinkModel`/`WordsCeremony` and the legacy arms of
  `ProtectionController`, the posture drill (`PostureSwitchDrillTests.swift`, VX-233's retirement) and the old
  suites (VX-406's list: `CorpusRotationTests`, `StoreKeyEnvelopeTests`/`Format2`, StringsWorkbook's
  `StoreUnlockTests`; VX-380's red attacker test fixed or dead with its subject). **FENCE: `Sources/VariorumCore/
  Sync/**` is NOT touched by this unit** — anything in Sync/ referencing deleted symbols is FLAGGED to the
  orchestrator (L1 carves it). ⌃⌘L declared with its helper row (P-VX309-U1c-4 (b) — the `.lockLibraryNow`
  capability gains its `shortcutLabel` + the shortcuts helper row). Evidence: the grep sweep table (every legacy
  symbol GONE, instance × file, each cell DELETED or provably new-road); `swift build`/`swift test` green BOTH
  configurations (`-c release` included — the protection set and the full core suite's release floor now honest);
  `xcodebuild build-for-testing` green; the phone builds; a Release-configuration build of the Mac app compiles.
- **L1 (the orchestrator, Fable): THE SYNC/ CARVE.** After U1: delete `Sync/CorpusRotation.swift`; retire the
  in-file `RotationMarker`'s live-marker role and `sync_state.rekey_in_progress` writers; sweep U1's flagged Sync/
  references. Own commit(s), headless green both configurations.
- **U3 (Opus implementer #2, Fable cold review): VX-423 — ONE REFRESH AUTHORITY.** The app's `AuthSession`
  (`App/Variorum/Shared/AuthSession.swift`) and the lobby's (`LobbyVaultRoad`/`FollowingSessionProvider`) stop
  refreshing the rotating refresh token independently — one shared session provider or a cross-instance
  single-flight + keychain re-read, per F-U1-1's trace (the VX-423 comment carries file:line). Evidence: a
  red-on-old pin on the two-refreshers race (revert-verified); the suites green; U2's throwaway rehearsal then runs
  with the fix in (switch day is wall-to-wall sign-ins — her sequencing reason).
- **R1 (Opus implementer #3, Fable cold review rides the phase ladder): THE RIDERS.** Pin-before-fix PER MEMBER;
  commits say `Part of VX-nnn`. Members: **VX-461** (the export door's 0-byte file — the save-panel grant not
  held around the ATTACH is the lead; a file-access fix, rule 26's instruction leans on it) · **VX-463** (conceal
  the words fields with a reveal eye — her ruling) · **VX-464** (the join refusal's referent — "that passphrase
  doesn't open this account."-class line, the move sheet too) · **VX-473** (the hold banner's `hasAccount` reads
  the library's bound account on the new road, not the Mac's sign-in) · **VX-469 (c)** (the Use Castle confirm
  says Previous Libraries' quiet roads stand — one line, her ruled wording direction) · **VX-468** (the what's-new
  card waits after a restore/adoption first open — her "wait") · **VX-462** (the set-up arm's words moment goes
  quiet — custody-adjacent; its `withKnownIssue` wrappers drop). **VX-470 is sized at R1's door:** ruled (c) —
  T-8 from an open Castle library lands in Castle with the current pair typed, PLUS an explicit "land it in
  Standard instead" secondary choice with its consequence named, carried to T-5 the same way (supersedes
  P-VX309-U1b-2's Standard landing). If it doesn't fit R1 cleanly it LEADS THE NEXT RUN (her word).
- **VX-465 (the orchestrator): THE DEVICE-ID DRIFT TRACE** — owed before the switch; runs between batches
  (read-only trace first; a fix only with a traced mechanism + red-on-old pin, else the ticket carries the trace).
- **THE LADDER:** one ladder over the whole phase diff; FRESH `fable-reviewer` per round, REVIEW_PROMPT verbatim,
  zero framing; cross-model flow (findings → implementer agree/dispute → reviewer's final call → implementer
  applies; FINDER-FIXES and Sync/ lines the reviewer's own).
- **U2 (the orchestrator): SWITCH DAY, REHEARSED (tonight's half)** — the step-by-step switch-day script for her
  (§2's answer inside it); the §2 proof + the full script walked on the throwaway project (two test accounts, two
  devices' worth of libraries); the `pg_temp` artifact authored, REHEARSED on the throwaway, and added to the
  marker-14 deploy set (production at her morning go — VX-213's held half); the vx307 deploy checklist amended to
  her 2026-10-22 choreography (BOTH MACS in one window, the phone follows VM-8 — its marker-13 install visibly
  refuses until then, accepted by her word); `notes/stargazing-castle-rebuild-delta-brief.md` REWRITTEN to the
  rules (F-U2-4) and checked against the built Release product, staged for her to hand to the site agent;
  VX-379's truth-check of the guide and panes against the Release build; the 0.10 release notes DRAFTED for her;
  the real-store byte-copy rehearsal STAGED (the copy placed if container access allows, else her exact commands)
  with A1 discipline and the zero-instance gate. **PAUSE THERE — her morning: the byte-copy rehearsal, the
  production deploy (marker-14 set incl. `pg_temp`), both Macs' installs, the release at her word.**

### §2's proof, the planned shape (detail worked at U2, repo-first)

Rule 15 across the switch = a fresh new-road library joining an account whose vault was BORN today's-road-shaped
and crossed via artifact 17's backfill reads every row sealed under the pre-switch corpus key. The §5R rehearsal
proved the backfill's field arms on planted rows; U2 proves the client end-to-end on the throwaway: a
post-backfill-shaped vault under known secrets (the §5R planting recipe, `~/.variorum/dev-vault-throwaway.env`),
rows sealed under its corpus key, then join + full pull from a fresh library — everything decrypts, the words/
passphrase typed at the join are the account's. The sealing seam (AES-GCM, AAD, `e1:`) is byte-unchanged across
the switch, so key continuity is the whole question and the vault shape is the whole risk.

### OPEN DESIGN NOTE (resolve at U2; an author item if it bends the plan's sentence)

With the legacy readers gone entirely (the ticket's "nothing is kept read-only"), a pre-design store — hers
included — is a store the new road cannot open: Look inside and the live slot must give rule 26's HONEST REFUSAL
naming the road (export from the old build / sign into sync / start fresh), never a crash and never a guess. The
plan's U2 sentence "Look inside, then Make this my library on a byte-copy of her real store" is therefore read as:
the byte-copy rehearsal proves the HONEST-REFUSAL face plus the switch-day script's real road (her writing returns
by sync; the old store kept whole as a copy, openable by the old build she keeps). If the built classifier can do
better than refuse (it cannot, without a reader), or if she wants a kept reader after all, that is HERS — bundled
for the morning sitting. U1 must leave the refusal face honest (the classifier must not claim "keyless" when an
old-format key file sits beside the store — name it as from an older Variorum where the shape allows).

### Environment traps (binding on every session of this phase)

Instance checks `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store instances by STORE,
never quit/kill; no Release builds or /Applications refreshes while one lives — and NO /Applications refresh at all
until the marker-14 deploy lands (L0's consequence). `xcodebuild build-for-testing` compiles without the runner;
Mac tests from `App/Variorum/`, suite-level `-only-testing`, confirm the "Test run with N tests" line and read
`skipped:` before claiming a gated suite ran; zsh `pipestatus`; NEVER a custom build configuration (non-"Debug"
strips the DEBUG oracles). EVERY `xcodebuild test` run and anything touching the screen or a shared store holds a
`Tools/stage` claim (no coordinator tonight — this session claims directly, renew-per-row on long walks). Headless
`swift build`/`swift test` is stage-free. Backups WAL-safe, UTC names, into `Backups/safety-copies/` (A1). The dev
Castle pair is `~/.variorum/dev-castle.env`, the throwaway's users `~/.variorum/dev-vault-throwaway.env` — values
never echoed, never committed; every throwaway apply carries the in-command ref guard (the §5R discipline). The
walk's Debug build lives at `App/Variorum/DerivedData/vx329` (the vx-309 stale-build slip's lesson: never launch
the standard-path build). Implementers: no subagents, no stage, no Debug launches, no dev-store touch; headless +
`build-for-testing` only; checkpoint commits per piece, push each, LIVE STATUS flips in the same commit, PENDING
on every unverified claim; foreground waits only (poll, don't `tail -f`).

## 6a. U1 BRIEF — THE SWITCH (an Opus implementer; ticket VX-329's trunk + VX-233 + VX-406/VX-380)

**Read first, in full:** CLAUDE.md + its canon; `notes/SessionResiliencyProtocol.md`; `notes/CastleRules.md` WHOLE
(rules 24, 26 and "What we do not promise" are this unit's heart); `notes/SurfaceContracts.md` "Doors to the
outside" (Library protection + portability) and "The app"; this plan WHOLE (§1–§6 — §6's CUT carries your fence and
your deletion list); `notes/plans/vx-266-castle-backups-prelaunch.md` §3.15 (the deletion list's birth — superseded
where §6 says "nothing is kept read-only"); `App/Variorum/Shared/Protection/ProtectionRoad.swift` (the switch);
`App/Variorum/Shared/AppBootstrap.swift` (the road fork at :217 and every `newRoad` arm);
`App/Variorum/Variorum/Registry/CapabilityRegistry.swift` around `.lockLibraryNow` (P-VX309-U1c-4's comment).
Work from `~/dev/variorum-vx-329`; commits say `Part of VX-329` (the drill deletion `Part of VX-233`; the suite
resolutions name VX-406/VX-380 where theirs).

**The goal.** One compile-time change in one place turns the new road on for EVERY build: `ProtectionRoad.live`
returns true unconditionally (keep the pure function + its pin, flipped); `opensOnTheNewRoad`'s dev-store fence
dissolves — every store, every variant, both configurations. Then delete today's whole deciding and writing road in
the same change, per §6's U1 list — nothing kept read-only, no `#if` shrouds, no commented-out code. Today's road
must be GONE as code, not dormant.

**The fence (absolute):** you never edit anything under `Sources/VariorumCore/Sync/`. Where a Sync/ file references
a symbol you deleted, STOP on that file, flag it in your record (file:line, the symbol), and leave it — the
orchestrator carves Sync/ in its own commit (L1). If that fence makes your tree uncompilable mid-unit, flag it and
coordinate with the orchestrator rather than working around it.

**Pieces (suggested order; checkpoint commit + push per piece):**
0. The flip: `ProtectionRoad` (live → true; `opensOnTheNewRoad` loses the fence or states it vacuously true —
   prefer deleting the devStore parameter and its callers' discrimination), plus the bootstrap's `!newRoad` arms.
   Compile-first discipline: get the app building on the new road everywhere before deleting files wholesale.
1. The Shared/ deletions (PostureSwitch, PostureSwitchModel, PostureFollowModel, PostureCopy, EncryptionSession,
   AppleRelinkModel, WordsCeremony, the legacy arms of ProtectionController/AppServices/AppBootstrap/VariorumApp,
   the panes' today's-road rows — SettingsShape/AppSettingsView/ProtectionPane/DataSafetyPane legacy arms, the
   mobile sheets' legacy arms).
2. The Persistence/ deletions (StoreKeyEnvelope, RawKeyCustody, CustodyCollisionRule, Posture.derive, the legacy
   arms of StoreIdentity/AppDatabase/LibraryAdoption/StoreBackup — today's flat backup leg dies where it is
   today's road's writer; the new road's pair road is THE backup writer).
3. The old suites: delete `PostureSwitchDrillTests.swift` (VX-233, Canceled — say so in the commit), the VX-406
   list (`CorpusRotationTests`, `StoreKeyEnvelopeTests`/`Format2Tests`, StringsWorkbook's `StoreUnlockTests`),
   and every test of deleted code; VX-380's red attacker test is FIXED if its subject survives, deleted with its
   subject if not — never skipped. Tests of the new road are NEVER deleted or weakened.
4. ⌃⌘L: the `.lockLibraryNow` capability gains `shortcutLabel` ⌃⌘L + the Shortcuts helper row
   (P-VX309-U1c-4 (b)); the registry-walk pin covers it.
5. The honest-refusal check (the §6 OPEN DESIGN NOTE): with the readers gone, point the classifier suites at a
   pre-design-shaped store/key-file fixture and PIN what it says — the refusal must be honest (never "keyless"
   where an old-format key file exists, if the shape allows naming it; never a crash). If the built shape cannot
   name it better than the generic refusal, record that honestly for the orchestrator's morning bundle — do not
   invent a new face without a ruling.
6. The sweep table: `rg` every deleted symbol name + §6's list — instance × file, each cell DELETED or provably
   new-road/comment-only; the table lands in your record.

**Hard limits:** headless `swift build`/`swift test` (BOTH configurations — `-c release` is this unit's acceptance)
+ `xcodebuild build-for-testing` ONLY; no stage, no Debug launch, no dev-store touch, no network, no subagents;
today's road's behavior is not "improved" on its way out — it is deleted; every new-road behavior change beyond §6's
list is out of scope (flag, don't build); no shouting caps, sentence case. The lockstep marker is ALREADY 14 when
you start (L0) — do not touch `SyncSchema` or anything in Sync/. `Tools/canon-size` is not yours. If a deletion
exposes a genuine product-behavior hole (a face only today's road provided), STOP on it and flag — the orchestrator
rules or bundles for her.

**Evidence closing the unit:** the sweep table complete; `swift test` AND `swift test -c release` green (counts in
the record; the release floor honest — VX-406's reds GONE with their suites); `xcodebuild build-for-testing` green
for the Mac app; the iOS app target builds; the record (§5, the VX-309 §6 form) with counts, the Mac-suite list for
the orchestrator's stage batch, PROVISIONALs bundled, findings routed, LIVE STATUS flipped per piece.

### L0 RECORD — THE LOCKSTEP COMMIT (the orchestrator, Fable, 2026-10-22; commit `0d1820336` — DONE)

`SyncSchema.lockstepVersion` 13 → 14 and `17_phase_vx307_vault.sql` registered in `AuthRLSDDLTests.lockstepFiles`,
ONE commit (the vx307 checklist's preflight pairing row now reads true on this branch). The chain's resolution moved
with it: the deployed `key_vault_update` is now 17's mode-shaped body, so the rotation-era DDL pins were made
marker-aware (the R-2 class) — `theVaultUpdateDoorLocksForUpdateCASesAndRecordsTheRotationSeq` and
`theCompletionGuardLivesInTheCanonicalTwelveBody` read the last PRE-17 definition from `13_phase13i_wings.sql`'s own
file (13i-a re-carried 12's fold-in with the wing/shelf ciphertext registry — found when the 12-file read failed the
registry-exactness arm), the clearing-guard overlay test asserts the guard's history (11 never · 12/13 carried ·
17 retires), `everyMintSite…` reads M3 in 12's text and asserts the deployed door mints nothing, and ONE NEW pin
(`theMarker14VaultDoorRetiresRotationAndLandsTheModeShape`) holds the deployed truth: 17's body byte-equal as the
chain's final resolution, the FOR UPDATE/proof/CAS clauses kept, `VARIORUM_PRE_VX307_PAYLOAD` live, rotation absent
whole. The five "a local-only migration never moves the marker" pins read 14. **Red-on-old:** the drift pin verified
red with the constant reverted to 13 (the pairing is enforced), restored green. **Suites:** the four affected suites
106/106; the FULL core suite green — 3368 tests, 2 known issues (standing `withKnownIssue` wrappers), one UNRELATED
load flake (`MCPHarnessTimeLimitTests` — a 15-second wall-clock bound read 18.6 s under the parallel full-suite run;
green in isolation at 2.2 s; no product line near it). **Consequence standing:** this branch speaks marker 14 — live
sync only against the throwaway until the production deploy at her morning go; NO `/Applications` refresh until then.

### VX-465 RECORD — THE DEVICE-ID DRIFT TRACED (the orchestrator, Fable, 2026-10-22; read-only, no fix — a design
consequence, her call bundled for the morning)

**The mechanism, code-traced:** the device ID lives ONLY in the per-library memory item (rule 21's four facts —
`DeviceMemory.deviceID`), and the app deliberately remembers ONE library: every act that lands or creates a library
ends with the forget loop (`DeviceActs.createLibrary` :144, `Copies` make-mine :218, `PlanRunner` :578,
`ExecutorRepairs` :170 — "Rule 21: this Mac remembers ONE library"). With the memory item gone, the next open of the
forgotten library cannot recognise which record section is this Mac's (rule 23 — no hardware fingerprinting;
`DeviceFacts.thisMacsSection`'s own comment: "never a section guessed from the record") so it MINTS a fresh device
ID and writes fresh memory — stable from then on. **The dev drift, fully accounted:** VX-308's walk ran the dev
library A first (the c31a4daf-era pairs, 10-19 ~11:00), THEN created throwaways B, C and D in the same slot domain —
each creation deleted A's memory item; VX-309's walk row 1 was A's next open: fresh era `a39ae6d7`, the honest zero
count, consistent pairs thereafter. No identity door on the DEV library was pressed; a CREATION door on other
libraries was — the designed trigger. The ticket's suspect (a test-host open minting a device row) is superseded.
**Release consequence, bounded:** in ordinary single-library life the ID never drifts. It re-mints only when another
library is created or adopted on the Mac and the earlier one later returns to the live place (the hand-restore of
rule 21; slot swapping is a walk pattern). Then the earlier eras' pairs LIST under the library but never COUNT as
this Mac's, and retention never prunes them — conservative both ways (nothing deleted wrongly), honest by its rule,
surprising to read. Switch day is untouched (her old stores retire; a fresh library mints fresh identity by design).
**Her options (the morning bundle):** (a) accept as designed — the ticket closes traced-by-design, with one wording
row if the counts' per-era meaning should say itself; (b) remember more than one library (bends rule 21's one-library
line; each memory item holds a sealed key-file copy, so N memories = N standing sealed copies — adjacent to her
VX-469 (c) stance that kept Previous Libraries' roads standing); (c) does not exist by design (ID continuity without
fingerprinting). No code changed; the pin question is moot until she rules.

### THE PG_TEMP REHEARSAL RECORD (the orchestrator, Fable, 2026-10-22 — VX-213's held half, her go at the sitting;
network-only, no stage; the ref guard in every apply)

The artifact `Server/supabase/maintenance/vx213-pg-temp-search-path.sql` authored to the strict shape: one
`alter function … set search_path` per EXACT deployed signature (never a pg_proc loop — the 13y blanket lesson),
each list preserved with `pg_temp` appended LAST; the marker-14 guard (`VARIORUM_PGTEMP_NEEDS_14` — 17 redefines
`key_vault_update` with a bare `public` list, so this artifact rides AFTER it); a fail-loud verify DO (zero definer
functions in public without a trailing pg_temp) and a read-only config tail. **The rehearsal on the throwaway:**
run 1 REFUSED in the verify — `rls_auto_enable()` (the project's RLS auto-enable event trigger, postgres-owned,
`search_path=pg_catalog`, already in the grant sweep's expectation table) was not in my list; the artifact amended
IN REPO (its own list preserved: `pg_catalog, pg_temp`) — the read-fix-re-run road working as designed, the same
class every live window has caught. Run 2 landed WHOLE: the tail read all **19** functions with trailing pg_temp
(the 14 definer RPCs incl. `sync_challenge`'s `public, extensions, pg_temp`, the four definer-path helpers,
`rls_auto_enable`). **The grant sweep after: 62 OK · 4 INFO · 0 fail — byte-identical to the marker-14 expectation**
(R-2's corrected shape). PRODUCTION application rides the marker-14 deploy set in the release window, AFTER 17, at
her explicit go — the checklist's run section carries it. No secrets echoed; every apply ref-guarded to
`<supabase-project-ref>`.

### L1 RECORD — THE SYNC/ CARVE (the orchestrator, Fable, 2026-10-22; commit `d0c579f08`)

U1's flags carved in one commit, Fable's own hands (Sync/ is Fable work): `Sync/CorpusRotation.swift` DELETED WHOLE
(`CorpusRotation`, `RotationMarker`, `RotationSecrets`, `CorpusRotationError`, the derived horizon wait);
`refuseIfRekeyIncomplete` + both round guards and `SyncError.accountRekeyIncomplete` (case + description) retired —
nothing writes the marker since U1 deleted the runner, and a pre-design store never reaches the engine, so the guards
were dead code, not protection; `pullIgnoringMarker` folded into `pullRound` (the marker distinction had no meaning
left); PurgeJanitor's preflight and doc comments follow; `visibilityHorizonMillis()` KEPT on the transport protocol
as the served A5 value's one client-visible authority (13y Shape 1 — the server function still derives `sync_pull`'s
filter; only the client consumer died), its comment rewritten honestly; `AccountLifecycleTests`' vault-write event
drops the marker suffix (no pin consumed it); the AuthRLSDDL cross-pin's client half replaced by the recorded
retirement note (the served constant and the inline-literal ban remain the non-vacuous arms). **Residue check:** zero
product references to the deleted names outside the two honest history comments. **Evidence:** debug core suite
3296 green (+MCP 383 with the recurring harness timing flake — unrelated, ticketed at closeout; StringsWorkbook 32);
**the release leg GREEN** (3267 in 425 suites + StringsWorkbook 32; the one red is the same MCP harness
timing flake — its fourth sighting tonight, both configurations, always green in isolation — ticketed at closeout).
**Canon note for the closeout:** SyncSpec §3's `sync_state` key list still names `rekey_in_progress` — the key is
dead with the marker; the canon delta lands at the merge moment per the two-file rule.

### THE R1 DOOR'S SIZING — VX-470 LEADS THE NEXT RUN (the orchestrator's call under her rule, 2026-10-22)

Her #237 ruling is (c) PLUS an explicit Standard choice, carried to T-5. The read: the core already parameterizes
the landing posture (`ActParameters.newKind`; the full-face make-mine already lands `record.mode`), but the ruled
shape needs the T-8 act's posture defaulted to the open library's mode, the empty-slot landing defaulted to the
copy's own mode, BOTH confirm sheets gaining the explicit "land it in Standard instead" secondary choice with its
consequence named, Castle landings typing the current pair, and pins per arm across three doors. That is a real
acceptance unit, not a rider beside seven others — her word at the sitting: "take it only if it fits a batch
cleanly, else it leads the next run." It leads the next run; the ticket carries this sizing as a comment.

## 6b. U3 BRIEF — VX-423, ONE REFRESH AUTHORITY (a fresh Opus implementer; Fable cold review rides the phase ladder)

**Read first, in full:** CLAUDE.md + its canon; `notes/SessionResiliencyProtocol.md`; this plan §6 (the cut, the
environment traps — they bind verbatim) and this brief; the VX-423 ticket's trace comments as mirrored here; the
code: `App/Variorum/Shared/AuthSession.swift` WHOLE, `App/Variorum/Shared/AppServices.swift` (the main instance's
birth), `App/Variorum/Shared/LobbyVaultRoad.swift` + `App/Variorum/Shared/Protection/FollowingSessionProvider.swift`
(the lobby/vault instance), `App/Variorum/Shared/AppBootstrap.swift` (who owns which), and every other
`AuthSession(` construction site (`rg "AuthSession(" App/ Sources/`). Work from `~/dev/variorum-vx-329`; commits say
`Part of VX-423`. NOTHING in `Sources/VariorumCore/Sync/` — if the fix wants a line there, STOP and flag it to the
orchestrator.

**The traced mechanism (VX-308 F-U1-1 + the VX-423 scout, code-confirmed):** two long-lived `AuthSession` actors
share ONE Keychain item (service `io.lduarte.Variorum.auth`, account `real-session-bound`) and ONE ROTATING refresh
token: instance A (AppServices — the sync transport, KeyVaultClient, EncryptionSession, AccountLifecycle) and
instance B (the bootstrap's lobby road, alive for the process). Each loads the Keychain once and never re-reads;
refresh is single-flighted WITHIN an actor only. A rotates RT1→…→RTn; B later refreshes with stale RT1; GoTrue
reads that as token reuse (`refresh_token_already_used`) and revokes the session — sync dies until re-login.

**The goal:** ONE refresh authority per process. The spec-defensible shape (propose-then-build if you see a
cleaner one — the architect rules on a fork): ONE `AuthSession` instance per process, owned at the composition
root and handed to both the services and the lobby road (the lobby's `FollowingSessionProvider` follows it), so
the single-flight covers every caller. A narrower alternative (cross-instance single-flight + keychain re-read
before any refresh) is acceptable only if the one-instance shape breaks a lifecycle the record names (the lobby
lives across locked windows; the services die at relock — say exactly why if you take it).

**Evidence closing the unit:** a RED-ON-OLD pin on the two-refreshers race (a fake GoTrue endpoint that revokes on
a reused refresh token; two instances sharing one stored token; the old shape burns the token — the pin red on the
pre-fix code, verified by behavioral revert, green after); the auth/account suites green headless; the protection
set green both configurations; `build-for-testing` green on both targets; the record (§5, the live-status form)
with counts, PROVISIONALs bundled, findings routed. Hard limits: §6's environment traps verbatim (headless only, no
stage, no subagents, no network, foreground waits, checkpoint commits pushed per piece).

## 6c. R1 BRIEF — THE RIDERS (a fresh Opus implementer; pin-before-fix PER MEMBER; Fable review rides the ladder)

**Read first, in full:** CLAUDE.md + its canon; `notes/SessionResiliencyProtocol.md`; this plan §6 + §6a's
environment traps (verbatim binding) + the U1 RECORD's F-flags (the shape you inherit); `notes/CastleRules.md`
rules 9, 11, 17, 21, 25–27; `notes/SurfaceContracts.md` Doors (Library protection); the member tickets' substance
as mirrored below (the Linear bodies point at `notes/plans/vx-309-copies-and-words.md` §8 — read the walk rows that
bore each member). Work from `~/dev/variorum-vx-329`; commits say `Part of VX-nnn` per member. NOTHING under
`Sources/VariorumCore/Sync/`. VX-470 is NOT yours (it leads the next run — the sizing record above).

**The members, each with its pin-before-fix (red on old, revert-verified):**
- **VX-461 — the export door writes an empty file.** `DataSafetyPane` → `StorePlaintextExport.export`: the
  suspected mechanism is the save panel's security-scoped grant not held around the export's ATTACH on the
  detached task's connection (the vx-309 §8 W-VX309-4 trace; a one-literal-path sandbox probe did NOT prove the
  journal-sidecar story — trace to a CONCRETE mechanism before fixing, and say it in the record). Rule 26's
  switch-day instruction leans on this door. The deliberate backups-folder refusal arm stays byte-unchanged.
- **VX-463 — conceal the words fields (her ruling: "conceal with a reveal eye").** Every typed-words field
  (make-mine both faces, the join/move sheets' account-words field, the key doors' words arms) conceals like the
  passphrase field, with the same reveal eye; one shared field component if one already serves the passphrase.
- **VX-464 — the join refusal's referent.** The wrong-account-passphrase refusal on the join and move sheets says
  the ACCOUNT, not "this library" (one sentence class; the make-mine faces keep theirs).
- **VX-473 — the hold banner's `hasAccount`.** On the new road it reads whether the OPEN LIBRARY's record names an
  account, never whether the Mac is signed in; the unsynced adopted library's banner drops the "catch up with your
  account" clause.
- **VX-469 (c) — the Use Castle confirm's one line.** The confirm says Previous Libraries' quiet roads on this Mac
  stand (her framing: Castle's promise is about live libraries; the warning idiom of the backups sentence).
  Wording PROVISIONAL, bundled.
- **VX-468 — the what's-new card waits (her "wait").** The card does not greet the first open of a library adopted
  by Make this my library / restore; it waits for the next ordinary launch (the calm-first-open rule's idiom).
- **VX-462 — the set-up arm's words moment goes quiet.** VX-456's quiet check answers false on a set-up-built
  vault (the own-words-lock clause); make set-up → leave → re-join quiet exactly as join → leave → re-join is,
  by whichever of the ticket's two candidates traces clean (drop the own words lock once the copy holds the same
  words, or a recorded same-words mark at set-up). The standing `withKnownIssue` wrappers in
  `JoinWordsMomentSetUpArmTests` DROP with the fix (they are the red-on-old). Custody-adjacent: the Fable ladder
  reviews it.

**Evidence closing the unit:** per-member pins red-on-old (named in the record with their revert checks); the
protection + faces suites green headless both configurations; `build-for-testing` green both targets; the record
(§5) with per-member dispositions, the Mac-suite list for the stage batch, PROVISIONALs bundled.
