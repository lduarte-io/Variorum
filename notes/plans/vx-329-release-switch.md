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

### U3 RECORD — VX-423, ONE REFRESH AUTHORITY (Opus implementer, 2026-10-22; DONE — the Mac and phone suite RUNS are the orchestrator's stage batch, the live proof is U2's rehearsal)

**Not done in U3, first:** NO Mac or phone suite was RUN through `xcodebuild test` (no stage — the brief's limit): this
unit's pins and the app's auth + protection suites ran in the HEADLESS HARNESS (below); the suites that need
`AppServices`, the signed host or the bootstrap's hosted road (`Phase9cAuthWiringTests`, `TierAndOnboardingTests`,
`SessionTokenBindingTests`, the bootstrap-constructing road suites) are COMPILED (`build-for-testing` green, both
targets) and UNRUN — the stage-batch list below; every claim about them is PENDING until it runs. NO live network: the
fix has not met a real GoTrue — that is U2's throwaway rehearsal (the hand-forward below says what it must outlive to
exercise the race). NO Release-configuration build of the Mac app (U1's stands; no line here sits under `#if`). No walk,
no Debug launch, no dev-store touch, no subagent, zero `Sources/` lines (core untouched: `git diff 4f6e3edef..HEAD --
Sources Tests Package.swift` is empty — the fence never came near `Sync/`).

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
- **R-U3-5 — THE AUTHORITY HOLDS THE SIGN-IN ACROSS A LOCK; THE LOCK STILL FORGETS THE KEY.** Before, the services'
  session was released with the services at a relock, so the access and refresh tokens left process memory until the
  next unlock re-read the item; now the bootstrap's authority keeps them through the locked window. Considered and
  kept: what a Castle lock forgets is the LIBRARY's key and the account's sync keys (`ProtectionRoadLock
  .dropSessionMemory` — untouched); no rule (CastleRules read for "lock", "session", "memory", "sign-in") names the
  account's sign-in among them, and the item itself stays readable by the process without a prompt
  (`WhenUnlockedThisDeviceOnly`, no ACL) through any lock — so memory retention crosses no boundary the item did not.
  No lobby door signs in or out (the Account surfaces need the services — `rg`'d), so nothing reaches the authority
  while locked but a vault read the lobby's road makes.

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
  builds: green (piece 4).
- Piece 3 — P1's behavioral revert: DONE — no revert is in flight (both runs restored, `git status` + `git diff
  --exit-code` clean). **REVERT RUN 2 (on `21f956933`, the corrected pin): the race pins RED for the reasons their names
  state** — `aRotationByTheServicesNeverLeavesTheVaultLeafASpentToken` ✘ 5 issues (the leaf's second read refused
  `VaultRefusal.notSignedIn` — its own instance refreshed its cached `rt-1`; the services' next refresh refused
  `refresh_token_already_used`; presented `[rt-1, rt-1, rt-2]`, refused `[rt-1, rt-2]`, the family revoked);
  `bothConsumersPastExpiryAtOnceRefreshOnce` ✘ 3 issues (two refresh requests carrying `rt-1` — `[rt-1, rt-1]` — the one
  that landed second refused, the family revoked); the witness ✔ and the R-3 follow guard ✔ (the pre-fix provider
  followed too — green on both sides, as designed). Restored → the fixed tree green (piece 4's run). The revert, exactly
  (two hunks): in `AuthSession`, after `init` — `nonisolated var revertStore: AuthTokensStore { store }` and `nonisolated
  func revertSibling() -> AuthSession { AuthSession(configuration: configuration, store: store, expiryMargin:
  expiryMargin, now: now, http: http) }`; in `WireVaultLeaf.live`, the client's `sessionProvider: session` replaced by
  `FollowingSessionProvider(signedInUser: { store.load()?.userID }, make: { authority.revertSibling() })` over `let
  authority = session as! AuthSession; let store = authority.revertStore` — plus `FollowingSessionProvider.swift` restored
  from `550ff123a^`. The record of the first attempt: **REVERTS STARTED on the committed tree `550ff123a`** (restore =
  `git checkout -- App/Variorum/Shared/AuthSession.swift App/Variorum/Shared/Protection/WireVaultLeaf.swift` + removing
  the restored `FollowingSessionProvider.swift`, verified by `git status`/`git diff --exit-code` clean). THE REVERT (the
  pre-fix vault-leaf composition, over the pin world's stored session and endpoint): `FollowingSessionProvider.swift`
  restored byte-for-byte from `550ff123a^`; `WireVaultLeaf.live` composes `FollowingSessionProvider(signedInUser: {
  <the authority's store>.load()?.userID }, make: { <a second AuthSession over the same store, endpoint and clock> })`
  — exactly the pre-fix `signedInUser` (the stored session's user) and `make` (another instance over the same item),
  the store and endpoint being the pin world's instead of the scope's Keychain item and the production project (no
  network); two REVERT-ONLY accessors on `AuthSession` expose its store and mint that sibling. **Revert run 1** (restored
  clean, `git diff --exit-code`): the burn reproduced (presented `[rt-1, rt-1, rt-2]`, refused `[rt-1, rt-2]`, the
  services' next refresh refused `refresh_token_already_used`) — and it EXPOSED a vacuous expectation in my own pin: the
  leaf-read checks were `(try? r.get()) == .some(nil)`, which `try?`'s flattening makes TRUE for a refusal too, so the
  leaf's own refusal did not register. Fixed in the pin (this commit: `answeredNoVault` matches `.success(.none)` by
  case); green again on the fixed tree (8/8). Revert run 2 follows on this commit.
- Piece 4 — evidence: DONE (the tree `9ccad2e42`; after it ONE comment-only edit — `ProtectionSystem.swift`'s header
  line "nothing in `AppBootstrap` calls this yet", stale since U1's switch, made true — the harness re-run on it below;
  every run foreground-polled, in sequence):
  - THE HARNESS (debug — the app test targets' only configuration): **`✔ Test run with 375 tests in 60 suites passed`**,
    0 skipped — on `9ccad2e42` and again after the comment-only edit (baseline 368/59 on the pre-fix `4f6e3edef`; −
    `FollowingSessionProviderTests`' 1, + this unit's 8: the
    composition 4, the race 2, the witness 1, the follow guard 1). The app's auth suites inside it:
    `AuthSessionTests` and `AuthSessionLazyLoadTests` (13e B-1's lazy load — the bootstrap's construction reads nothing)
    green. Under `-c release` the harness does not build — the app's protection suites name DEBUG-only walk machinery
    (`ProtectionWalkSwitch`), exactly as the Xcode test targets build in Debug only; the release floor is the core's.
  - THE CORE (untouched — confirmation of L1's floor): the protection set (every test type under
    `Tests/VariorumCoreTests/Protection`) + the auth/account set (`AccountBindingGateTests`, `AccountLifecycleTests`,
    `AuthRLSDDLTests`, `KeyVaultClientTests`, `SupabaseTransportTests`, `SupabaseTransportSessionTests`): debug **`✔ Test
    run with 497 tests in 97 suites passed … with 2 known issues`**; release (`swift test -c release`, the same filter)
    **`✔ Test run with 473 tests in 93 suites passed … with 2 known issues`**; 0 skipped both; the 2 known issues are
    VX-462's standing `withKnownIssue` wrappers (`JoinWordsMomentSetUpArmTests` — R1's to drop), not this unit's.
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx329-u3
    build-for-testing`: **`** TEST BUILD SUCCEEDED **`**; `-scheme VariorumMobile -destination 'generic/platform=iOS
    Simulator' -derivedDataPath …/vx329-u3-ios build-for-testing`: **`** TEST BUILD SUCCEEDED **`**; no warning in a file
    this unit touched (both logs grepped).

**PROVISIONALs:** none — no product behavior was decided: sign-in, sign-out, the account doors and the vault's refusals
read exactly as before; the composition changed beneath them.

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-U3-1 → U2 (the orchestrator): the live proof must OUTLIVE AN ACCESS TOKEN.** The race needs a refresh: GoTrue's
  access tokens live an hour (`expires_in` 3600 on the project's default), and a consumer refreshes only within 60 s of
  expiry or on a 401. A throwaway rehearsal shorter than an hour never exercises it; to see the fix live, keep one
  signed-in library open past one expiry with both consumers active (a sync round AND a Settings ▸ Protection pane read
  — the vault leaf) and watch for `refresh_token_already_used` (absent) in the sync row and the protection log.
- **F-U3-2 (the orchestrator — a ticket or not): two PROCESSES over one scope still race.** One authority per process is
  the unit; a Debug build opened on the real store beside the installed Release app (the real-store opt-in) would be two
  refreshers of her real token again. Today's posture forbids that pairing by rule (CLAUDE.md), not by mechanism.
- **F-U3-3 (pre-existing, fail-closed — the orchestrator's to ticket or not):** `AuthTokensStore.keychain`'s `save`
  drops `KeychainAuthStorage.save`'s result, so a refused Keychain write leaves the authority's in-memory tokens newer
  than the item the direct readers read (`RoadInputs.live`'s `sessionFact`, `OwnerIdentity`) — the road would then
  name a different signed-in user than the leaf rides, and the vault client refuses `notSignedIn` (the mismatch check).
  Visible, never destructive; unchanged by this unit.
- **F-U3-4 (machinery, for the next harness): the recipe's TEST target must not take the app's default `MainActor`
  isolation** — the Xcode test targets carry none, and `KeychainOffMainTests` (rightly) does not compile under it.
- **F-U3-5 (found and fixed in my own pin, recorded as the lesson):** `#expect((try? r.get()) == .some(nil))` is
  vacuous for a refusal — `try?` flattens, the nil promotes to `.some(nil)` — so revert run 1 showed the burn but not the
  leaf's own refusal; matched by case now. A sweep of the test tree for the same shape found none.

**MAC-SUITE LIST (the orchestrator's stage batch — compiled, unrun here):** `OneRefreshAuthorityCompositionTests`,
`OneRefreshAuthorityRaceTests` (harness-green), `AuthSessionTests`, `AuthSessionLazyLoadTests` (harness-green),
`Phase9cAuthWiringTests` and `TierAndOnboardingTests` (`AppServices`' `auth:` now required — every test site already
passed one), `SessionTokenBindingTests` (signed host — subject untouched, the sanity run), `RoadAccountFacesTests` (the
provider suite removed), `AppBootstrapOffMainTests`, `SettingsLockCloseTests` and the bootstrap-constructing road suites
(`RoadJoinFollowSurfaceTests`, `RoadLockRouteTests`, `RoadKeyDoorSurfaceTests`, `SetPassphraseRowRereadRouteTests`,
`RoadAccountSurfaceTests` — the bootstrap's inits gained the authority), `ProtectionSystemCompositionTests` and
`ProtectionFactsGathererTests` (`ProtectionSystem.init`'s defaulted `session:`); U1's whole `VariorumTests/Protection/`
folder covers the rest. Phone: `MobileProtectionTests` (the phone root's composition changed — the sanity run).

### R1 RECORD — THE RIDERS (Opus implementer, 2026-10-22; DONE — the Mac and phone suite RUNS and the walk rows are the orchestrator's stage batch)

**Not done in R1, first:** NO Mac or phone suite was RUN through `xcodebuild test` and NO walk ran (no stage — the brief's
limit): every app pin of this unit ran in the HEADLESS HARNESS (all green, red-on-old verified there), and the Mac-only and
phone suites over what changed are COMPILED (`build-for-testing` green, both targets) and UNRUN — the stage batch's list
below; every claim about them is PENDING until it runs. The ruled design and wording rows (VX-463, VX-469 (c), VX-464's
sentence) have no walk capture yet — they close on the stage batch's captures, not on these pins. VX-461's fix is proven
under a sandbox PROFILE, not yet in the sandboxed app — its live proof is the walk's first row. NOT built (each a finding
below): a failed export's cleanup of its half-made file (F-R1-2), the same own-lock rule on the re-keying roads (F-R1-4),
VX-469's line on the follow (P-VX329-R1-2 (c)). VX-470 is not this unit's (it leads the next run). Zero
`Sources/VariorumCore/Sync/` lines (`git diff f5afb1d76^..HEAD -- Sources/VariorumCore/Sync` empty); no schema change; no
dev-store, real-store or network touch; no subagent.

**Preflight (complete, not delegated):** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md` whole;
this plan §1–§6 (the CUT, the environment traps, §6c — this brief), the U1 RECORD (its F-flags) and the U3 RECORD (the
one-authority shape); `notes/CastleRules.md` whole (rules 9, 11, 17, 21, 25–27 the heart); `notes/SurfaceContracts.md`
(The app; Doors — Library protection and portability); `notes/plans/vx-309-copies-and-words.md` §8 (the walk rows that
bore each member: W-VX309-3 → VX-464, W-VX309-4 → VX-461, W-VX309-5 → VX-462, the clear-text words slips → VX-463, the
what's-new greeting at row 3 → VX-468, F-U2-2's banner → VX-473) and the findings behind them (F-U1b-1 + F-U1c-4 → VX-469,
F-U2-2, P-VX309-U2-1); QUESTIONS #237's answer block (her rulings for VX-463, VX-468, VX-469). The code read per member
is named in its row below.

**THE MEMBERS — the traced mechanism and the planned pin (each pin red on the pre-fix tree, then the fix, then green;
a behavioral revert re-checks it):**
- **VX-461 — the export door's empty file.** Traced (piece 1 carries the proof): `StorePlaintextExport.export` ATTACHes
  the picked path and lets `sqlcipher_export` write it; the attached database's first write opens a ROLLBACK JOURNAL
  beside it (`<picked>-journal`). The save panel's sandbox grant is the one picked PATH (the system's app-sandbox
  profile carries no related-file rule for SQLite sidecars — `/System/Library/Sandbox/Profiles/application.sb` read), so
  the sibling's creation is denied → `SQLITE_CANTOPEN` inside the export → the walk's exact *"SQLite error 1: unable to
  open database file - while executing `SELECT sqlcipher_export('plain')`"*, the ATTACH having already created the
  picked file at 0 bytes. PENDING the probe (the real export, the app's own SQLCipher, under a one-literal-path sandbox
  profile). Pin (core): a folder where no sibling of the picked file can be made (a directory standing at each sidecar
  name) — the export must write its file and nothing beside it. Fix: the attached copy keeps its journal in memory.
- **VX-462 — the set-up arm's words moment.** Traced: set-up's `joinKeyFile` re-makes the library's OWN words lock from
  the typed words beside the master's twelve-words copy (`locks.words` set → `settingWords`), and rule 16's leave changes
  no lock, so at the re-join `wordsAreTheAccountsAlready`'s first clause (`file.words == nil`) can never hold — the moment
  speaks. A passphrase join drops the own lock (the `typedSecret` arm), which is why join → leave → re-join is quiet.
  Fix (the ticket's first candidate): where the master's words copy is written — the copy holds the very words typed (a
  join verified them against the vault; a set-up made the vault from them) — the own words lock is not kept; the copy is
  the words' road. Pins: `JoinWordsMomentSetUpArmTests`' two `withKnownIssue` wrappers DROP (they are the red-on-old).
- **VX-464 — the join refusal's referent.** Traced: the join's and Move's typed secret is checked against the ACCOUNT's
  vault (`ProtectionAccountRoad.accountSecretRefusal`; the core's `join`), but the refusal is the lobby's
  `passphraseDoesNotOpen`/`wordsDoNotOpen` ("…this library"). Fix: the two arms say the account on join and Move; the
  follow (the library's pair IS the account's — rule 7) and set-up (the library's own pair) keep theirs. Pins:
  `ProtectionJoinFollowRoadTests`' wrong-secret pins flip to the account's sentences (they pinned the mis-aim); a Move
  pin; guards on the follow and the set-up arm.
- **VX-473 — the hold banner's `hasAccount`.** Traced: the composition root passes `services.account.variorum != nil ||
  services.sync.isConfigured` — whether this Mac is SIGNED IN — so after Make this my library while signed in (the new
  library names no account) the banner speaks the catch-up clause. Fix: the open library's record names an account,
  read by its standing faces and re-read when an account act lands. Pins: the standing faces' fact (unbound / bound /
  after a landed join) and the root's composition (never the Mac's sign-in).
- **VX-469 (c) — the Use Castle confirm's line.** Fix: one sentence on every confirm that enters Castle from this Mac's
  door (Use Castle; the join into a Castle account — the doors that say the backups warning) saying Previous Libraries'
  quiet roads on this Mac stand. Words PROVISIONAL. Pins: the confirms' exact sentence lists.
- **VX-468 — the what's-new card waits.** Traced: the ledger is decided once per process and claimed by the first ready
  window's appearance; a launch that opens on the missing face or the lobby has no ready window until a copy door lands,
  so the adopted library's first open is the first window — and the card greets it. Fix: a copy door's landing (Make
  this my library, the empty slot's, the plain-text bring-in) makes this process's show wait; the version stays
  unrecorded, so the next ordinary launch shows it. Pins: the ledger's wait (harness) and the landings' composition.
- **VX-463 — the words fields conceal.** Every typed-words field (the lobby's, both platforms; Make this my library's;
  the crossings'; the join/Move/follow sheet's; the set-up's; the reset door's) renders through `PeekableSecretField`, the
  passphrase's one shared concealing field with its reveal eye. A ruled design row: its evidence is the stage batch's
  walk capture; a structural pin (no words field outside the shared field) rides as insurance.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece R — this record skeleton: DONE (this commit).
- Piece 1 — VX-461: FIX DONE (this commit); the behavioral revert follows (its own line below). **THE TRACE, PROVEN
  (headless, no store, no network — a transient probe test, never committed, removed before this commit):** the real
  `StorePlaintextExport.export` over a scratch encrypted store (the app's own SQLCipher via the core), run through
  SwiftPM's testing helper under `sandbox-exec` with a profile that denies writes in the destination folder except ONE
  literal path — the save panel's grant shape. (A) unsandboxed: OK, 552,960 bytes. (B) one-path grant: **`SQLite error 1:
  unable to open database file - while executing `SELECT sqlcipher_export('plain')``, the picked file left at 0 bytes —
  the walk's line byte-for-byte.** (C) the same grant plus ONLY `<picked>-journal`: OK, 552,960 bytes — the journal
  sibling is the one missing grant. (D) the system `/usr/bin/sqlite3` (3.54.0) under (B)'s profile: `ATTACH` then `CREATE
  TABLE plain.t` → "unable to open database file"; with `PRAGMA plain.journal_mode=MEMORY` first → written (8,192
  bytes). So the earlier one-literal-path probe's pass (§8, W-VX309-4's trace) was not this grant's shape; under it both
  SQLite builds fail at the first write. Why the walk saw it: the ATTACH opens (creates) the picked path — allowed —
  and the copy's first write opens a rollback journal BESIDE it, which the grant does not cover; SQLCipher turns the
  inner `SQLITE_CANTOPEN` into its error 1. The system profile `application.sb` carries no related-file rule for SQLite's
  sidecars (read: no `journal`/`sqlite`/`related` rule). **THE PIN** (core, `StorePlaintextExportTests
  .theCopyLandsInThePickedFileAloneWhereNoSiblingCanBeMade`): the grant's shape without a sandbox — the picked file
  standing empty and writable (what the ATTACH makes there) in a folder at mode 0555 where nothing new can be created;
  the copy must land whole in it with nothing beside it. **RED on the pre-fix code:** `SQLite error 1: attempt to write a
  readonly database - while executing `SELECT sqlcipher_export('plain')`` (the same failing open of `<picked>-journal`;
  the folder's `EACCES` reads as SQLite's `SQLITE_READONLY_DIRECTORY` where the sandbox's `EPERM` reads as
  `SQLITE_CANTOPEN`). A first stand-in (a DIRECTORY at each sidecar name) was discarded unrun-as-evidence: it trips the
  hot-journal check at the ATTACH itself (`disk I/O error`), which the real grant never does. **THE FIX**
  (`Sources/VariorumCore/Persistence/StorePlaintextExport.swift`): `PRAGMA plain.journal_mode = MEMORY` right after the
  ATTACH — the fresh copy's rollback journal never touches the disk (nothing reads the copy until it is whole); the
  writing half split out as `write(from:into:)` (internal — the pin's door; `export` keeps its never-overwrite guard
  and the folder creation, byte-for-byte). **GREEN after:** the pin + the export's suites (`StorePlaintextExportTests`,
  `PlaintextExportImportTests`, `MCPGrantSchemaTests`, `LibraryClassifierTests`, `LocalMachineryRecreationTests`,
  `ProtectionRecordSchemaTests`): `✔ Test run with 49 tests in 6 suites passed`; and the probe's (B) on the FIXED tree:
  **OK, 552,960 bytes, 36 tables, nothing beside it.** The backups-folder refusal arm (`PlaintextExportModel.refusal`) is
  untouched. The sidecar sweep after the copy is kept (now a no-op by construction — noted for the ladder).
  **REVERT CHECK (on `3470c6905`, the tree clean first):** the `PRAGMA plain.journal_mode = MEMORY` line removed alone
  → the pin RED for its stated reason (`attempt to write a readonly database - while executing `SELECT
  sqlcipher_export('plain')``); restored by `git checkout --`, `git diff --exit-code` clean. **VX-461: DONE (`3470c6905`).**
- Piece 2 — VX-462: FIX DONE (this commit); the revert check follows. **The mechanism, confirmed by the pins:** set-up's
  `joinKeyFile` built `locks.words` from the typed words and re-made the library's OWN words lock (`settingWords`)
  beside the master's twelve-words copy; the leave changes no lock (rule 16); at the re-join `wordsAreTheAccountsAlready`
  requires `file.words == nil`, so it answered false and the moment spoke. A join by the PASSPHRASE drops the own lock
  (the `typedSecret` arm) — hence join → leave → re-join was quiet. The SAME function re-made the own lock on a join by
  the WORDS, so that arm over-spoke the same way. **THE FIX** (`Sources/VariorumCore/Protection/Executor/Acts
  /AccountActs.swift`, `joinKeyFile` — custody-adjacent, Fable reads it): where the master's twelve-words copy is written
  (`locks.masterWordsCopy` set — the vault's own recovery wrap, which holds the very words typed: a join verified them
  against the vault, a set-up made the vault from them), no own words lock is kept (`file.words = nil`); with no copy to
  write (the vault unread), the typed words keep their own lock as before. `opensWithTheWords` holds through the copy.
  **THE PINS — RED on the pre-fix code, each for its stated reason** (`swift test --filter JoinWordsMoment`: 3 issues,
  `!replaced(rejoined)` at each): `JoinWordsMomentSetUpArmTests.aRejoinAfterSetUpByThePassphraseIsQuiet` and
  `…aRejoinAfterSetUpThatChoseThePassphraseIsQuiet` — their **`withKnownIssue` wrappers DROPPED** (they were the
  red-on-old), each now also asserting the library's words and passphrase open it after; NEW
  `…aRejoinByThePassphraseAfterAJoinByTheWordsIsQuiet` (the words-join arm; the laptop's old words never open it).
  **GREEN after:** `✔ Test run with 11 tests in 2 suites passed` (no known issue left). **TWO PINS FLIPPED, each pinned the
  shape this fix removes** (found by the full core run — `✔`/`✘` 3298 tests, 5 issues in exactly these two suites):
  `AccountJoinTests.setUpSyncInStandardHandsTheLibrarysPairUpAndKeepsTheLibraryKey` asserted the own lock opened after
  set-up (`open(words:)` — the own-lock road only) → now: no own lock beside the copy, and the library's words open it
  (`open(.words(…))`, the copy's road); the lifecycle scenario's stage-12 check (`LifecycleChecks
  .syncSetUpHandsThePairUp`, the page's *"Your library's passphrase and twelve words become the account's. Nothing is
  replaced [7]."*) read "nothing is replaced" as the own words lock's BYTES unchanged → now: her words open the library
  just after set-up (`LifecycleWalk` records `setUpWordsOpenAfter`) and no own lock is kept beside the copy — the page's
  sentence and its fixture untouched (her words are not replaced; their road moves). The passphrase-lock arm of that
  check is unchanged and green. `JoinWordsMomentTests.theFirstDevicesOwnWordsLockBesideTheCopyStillSpeaks` (the EX
  fixture's hand-built own-lock-beside-copy file) stands green, its comment made true (that shape is now pre-VX-462's,
  not set-up's). Re-run after the flips (`AccountJoinTests|LifecycleScenarioTests|JoinWordsMoment`): `✔ Test run with 21
  tests in 4 suites passed`. **REVERT CHECK (on `ab4e2cbe3`, the tree clean first):** `joinKeyFile`'s pre-fix branch
  restored alone → RED for the stated reasons: the three re-join pins (`!replaced(rejoined)`), the flipped set-up pin
  (`live.words == nil`), the lifecycle's stage 12 (4 cases); restored by `git checkout --`, `git diff --exit-code` clean.
  **VX-462: DONE (`ab4e2cbe3`).**
- Piece 3 — VX-464: FIX DONE (this commit); the revert check follows. **The mechanism:** the join's and Move's typed
  secret is checked against the ACCOUNT's vault on both roads — the open session's (`ProtectionAccountRoad.press` →
  `perform` → the core's `join` throws `passphraseDoesNotOpen`/`wordsDoNotOpen` → `RoadAccountFaces.actRefusalSentence`)
  and the re-keying seam's (`preflight` → `accountSecretRefusal` → the same mapper) — and the mapper said the lobby's
  "…doesn't open this library." **THE FIX** (`App/Variorum/Shared/Protection/`): `ProtectionAccountRoad
  .typesTheAccountsSecret(request)` — Move, and turning sync on where the account has a vault (the join: `spec.join` set,
  not `.setsUpInLibrarysMode`) — feeds a new `secretIsTheAccounts:` on `actRefusalSentence` (defaulted false: every other
  caller unchanged) from BOTH roads; true, the two arms say `ProtectionWords.passphraseDoesNotOpenAccount` *"That
  passphrase doesn't open this account."* and `wordsDoNotOpenAccount` *"Those twelve words don't open this account."*
  (PROVISIONAL P-VX329-R1-1 — the plan's ruled direction, "this account"); the follow (the library's pair is the
  account's — rule 7) and set-up (the library's own pair) keep "this library". **THE PINS** (`ProtectionJoinFollowRoadTests`,
  harness): `aWrongSecretWritesNothing` (the same-posture join, the open session's road) and `aJoinIntoACastleAccount
  EntersCastle`'s preflight loop (the seam's road) FLIPPED DELIBERATELY — they held the mis-aimed line; NEW
  `vx464_aWrongSecretAtMoveNamesTheAccount` (Move on both roads, nothing written); NEW GUARD
  `vx464_theFollowsWrongPassphraseKeepsTheLibrarysSentence` (green on both sides by design); the set-up arm's guard is the
  standing `ProtectionAccountRoadTests.aWrongWordWritesNothing` (unchanged, green). **RED before the fix** (the two
  sentences added first with no caller, so the red is behavioral, never a compile failure): `✘ Test run with 15 tests in 1
  suite failed … with 8 issues` — the join's press ×2, its preflight ×2, Move's press ×2 and preflight ×2. **GREEN after:**
  the account suites (`ProtectionJoinFollowRoadTests|ProtectionAccountRoadTests|RoadAccount*|RoadJoinFollow*`) `✔ Test
  run with 70 tests in 8 suites passed`. The two sentences pass the two-register rule (no forbidden word). **REVERT
  CHECK (on `181774e60`, the tree clean first):** `typesTheAccountsSecret` answering false for Move and the join →
  `✘ Test run with 15 tests in 1 suite failed … with 8 issues` (the same eight); restored by `git checkout --`, `git diff
  --exit-code` clean, the harness rebuilt. **VX-464: DONE (`181774e60`).**
- Piece 4 — VX-469 (c): FIX DONE (this commit); the revert check follows. **What it is:** a wording row under her ruling
  (QUESTIONS #237: *"Castle's promise is about live libraries and at most we should show a warning like we do for backups
  when you go into castle. I think C is fine."*). **THE LINE** (`ProtectionWords.castleLeavesPreviousLibraries`,
  PROVISIONAL P-VX329-R1-2): *"The libraries in Previous Libraries keep their own quiet roads on this Mac — Castle protects
  the library you have open."* (the device name the platform's). **WHERE:** right after what entering does
  (`useCastleLead`) on every confirm that says it — Use Castle (`RoadCrossingFaces.open`) and the join into a Castle account
  (`RoadAccountFaces.joinDoor`, which speaks Use Castle's own door words and the backups warning); the sheets render a door's
  sentence list as given, so no face changed. Not on the follow into Castle (its confirm carries neither the entering lead
  nor the backups warning — PROVISIONAL; adding it there is one line). Unconditional: entering Castle never touches a
  Previous Library's roads, so the line is true whether or not one is there (option (b), said only when this Mac holds a
  Previous Library, needs a new fact from the catalogue — not built). **THE PINS** (harness): NEW `RoadCrossingFacesTests
  .vx469_useCastleSaysPreviousLibrariesKeepTheirQuietRoads` (the line right after the lead, its exact words, never on Use
  Standard or Replace All Keys); the exact sentence lists FLIPPED (`aFreshStandardLibraryOffersUseCastleAlone`,
  `RoadJoinFollowFacesTests.joiningACastleAccountEntersCastleAndSaysSo`) and the no-shouting sweep gains the line. **RED
  before the wiring** (the sentence added first with no caller): `✘ Test run with 22 tests in 3 suites failed … with 3
  issues` — exactly the three expectations (the pin's first run also tripped on its own construction — `Crossing.inCastle`
  makes its own library, so it took a second road; fixed in the pin, re-run red as stated). **GREEN after:**
  `RoadCrossing*|RoadJoinFollow*|ProtectionCrossingRoadTests|ProtectionJoinFollowRoadTests|U2WordsTests` `✔ Test run with
  83 tests in 9 suites passed`. Her eyes: the stage batch's walk capture of Use Castle's confirm (both voices). **REVERT
  CHECK (on `557558321`, the tree clean first):** the line unwired from both confirms → the three pins RED
  (`aFreshStandardLibraryOffersUseCastleAlone`, `vx469_…`, `joiningACastleAccountEntersCastleAndSaysSo`); restored by `git
  checkout --`, `git diff --exit-code` clean, the harness rebuilt. **VX-469 (c): DONE (`557558321`).**
- Piece 5 — VX-473: FIX DONE (this commit); the revert check follows. **The mechanism** (traced in the code): the Mac
  root composed `RestoreHoldBar(hasAccount: services.map { $0.account.variorum != nil || $0.sync.isConfigured } ?? true)`
  — whether THIS MAC is signed in — so Make this my library while signed in (the new library names no account,
  P-VX378-U2-4) spoke *"Resume to catch up with your account"* where Resume only clears the hold (the VX-314 gate refuses
  a round there). **THE FIX:** `RoadStandingModel.syncsWithAnAccount: Bool?` — the OPEN library's record names an account
  (`make` passes the session's `record?.account != nil`, the band's own `synced` read), observable, re-read by
  `rereadAccountBinding()` from the bootstrap's account-act `landed` hook (turning sync on and the leaves change the record
  with no reopen) and from `refreshPane()`; nil for hand-made faces (no session). The root reads
  `bootstrap.roadStanding?.syncsWithAnAccount ?? true` (unknown keeps the shipped wording, as before); the bar's parameter
  comment made true. The phone hosts no hold banner. **THE PINS** (`HoldBannerAccountTests.swift`, NEW — harness):
  `HoldBannerAccountFactTests.anUnboundLibraryOnASignedInMacNamesNoAccountUntilItSyncs` (a signed-in Mac, an unbound
  library → false and the banner's no-account sentence; turning sync on, the landing's re-read → true; Stop syncing here,
  the pane's re-read → false) and `…handMadeFacesKnowNothing` (nil); `HoldBannerAccountCompositionTests
  .theRootFeedsTheBannerTheOpenLibrarysAccountNeverTheMacsSignIn` (source: the bar's `hasAccount` reads `roadStanding`'s
  `syncsWithAnAccount`, never `services`/`account.variorum`/`isConfigured`; the `landed` hook re-reads). **RED on the
  pre-fix root** (the fact added first, the root unwired): the composition pin `✘ … with 2 issues` (the sign-in read
  found, the library's fact absent) — the fact pins green, by design (a new fact — red-on-old by construction; their
  behavioral check is the revert below). **GREEN after:** `HoldBannerAccount*|SetPassphraseRowReread*|ProtectionPaneWave*`
  `✔ Test run with 8 tests in 4 suites passed`. The root's compile: `build-for-testing` green at piece 6 (below). **REVERT
  CHECK (on `cf9efc580`, the tree clean first):** the root's old expression restored AND `rereadAccountBinding` made a
  no-op → the composition pin RED (2 issues — the sign-in read found, the library's fact absent) and the fact pin RED
  (`standing.syncsWithAnAccount == true` after the landing's re-read); restored by `git checkout --`, `git diff
  --exit-code` clean, the harness rebuilt. **VX-473: DONE (`cf9efc580`).**
- Piece 6 — VX-468: FIX DONE (this commit); the revert check follows. **The mechanism** (traced in the code): the ledger
  (`WhatsNewLedger`) is decided once per process and claimed in the FIRST ready window's `onAppear` (`RootView`); a launch
  that opens on the missing face or rule 27's lobby has no ready window until a copy door lands, so the adopted library's
  first open IS the first window — the walk's row 3 (T-5 from the missing face) exactly. **THE FIX:** `AppBootstrap
  .adoptedALibraryThisProcess` (set at the three copy-door landings on a made landing — `makeThisMyLibrary`,
  `makeThisMyLibraryInTheEmptySlot`, `bringInPlaintextExport` — before the landing's open, so the ready window that open
  makes reads it; never reset); the Mac root hands it to `RootView(whatsNewWaits:)`; the window's one claim is
  `claimAutoShow(afterAdoption: whatsNewWaits)` — adopted, the process's ticket is spent and nothing is recorded (no sheet
  appears, so `markShown` never runs) → the next ordinary launch shows it. Help ▸ What's New untouched. A creation (Start a
  New Library) is not a copy door and is unchanged (PROVISIONAL P-VX329-R1-3 — her ruling named a restored/adopted
  library). `WhatsNewLedger` RELOCATED byte-for-byte to `Features/WhatsNew/WhatsNewLedger.swift` (diffed identical) so the
  harness compiles it; `WhatsNew.swift` keeps the sheet and says where the ledger went. **THE PINS**
  (`App/Variorum/VariorumTests/WhatsNewWaitsAfterAdoptionTests.swift`, NEW — harness): `WhatsNewWaitsAfterAdoptionTests
  .aDueShowWaitsForTheNextLaunchWhenThisProcessAdoptedALibrary` (due 0.9.8 → 0.10: no card at the adopted open nor a later
  window, the record still 0.9.8, the next launch shows it once) and `…anOrdinaryLaunchStillShowsOnceAndAFreshInstallStays
  Silent` (the guard); `WhatsNewWaitsCompositionTests.everyCopyDoorLandingMarksTheProcessAndTheReadyWindowReadsIt`
  (source: each landing's body marks it, the root hands it, the claim reads it). **RED on the pre-fix decision** (the seam
  added first carrying the old claim — the adoption ignored, exactly what the claim did before): the ledger pin `✘ … 1
  issue` (`claimAutoShow(afterAdoption: true) == false`), the composition `✘ … 5 issues`; the guard green. **GREEN
  after:** `✔ Test run with 3 tests in 2 suites passed`; and the Mac `build-for-testing` (`App/Variorum/DerivedData
  /vx329-r1`, APFS-cloned from U3's) **`** TEST BUILD SUCCEEDED **`** with this piece and piece 5's root edits in, no
  warning in a touched file (the clone's "stale file … outside the allowed root paths" notices only — Xcode declined to
  touch U3's directory). **REVERT CHECK (on `82285d1d3`, the tree clean first):** the ledger's decision restored to the
  old claim (`return true`) AND the empty slot's mark removed → RED: `✘ Test run with 3 tests in 2 suites failed … with 2
  issues` (the ledger's adoption arm; `makeThisMyLibraryInTheEmptySlot`'s mark); restored by `git checkout --`, `git diff
  --exit-code` clean, the harness rebuilt. **VX-468: DONE (`82285d1d3`).**
- Piece 7 — VX-463: FIX DONE (this commit); the revert check follows. **What it is:** a ruled design row (her ruling:
  *"conceal with a reveal eye."*). **THE FIX:** every field a person types the twelve words into renders through
  `PeekableSecretField` — the passphrase's ONE shared concealing field (a `SecureField` until the eye is pressed; back to
  hidden when the field clears; `privacySensitive` over the pair): the Mac lobby (`StoreLockView.swift`), the phone lobby
  (`MobileRoadFaces.swift`), Make this my library's full face (`CopyDoorsSheet.swift` — the empty slot's combined secret
  field already was), the crossings (`RoadCrossingSheet.swift`), the join/Move/follow sheet and set-up's words
  (`RoadAccountSheet.swift`, two fields), the reset door (`RoadKeyDoorSheet.swift`) — eight labels, seven views. Each
  keeps its own submit (the crossings', the account sheet's two carry `onSubmit: submit` as before; the lobbies' and
  Make-mine's had none and still have none — their button submits). Consequence, PROVISIONAL P-VX329-R1-4: the words
  fields are now SINGLE-LINE in both states (the shared field's shape — the multi-line `axis: .vertical` with 2–3 reserved
  lines is gone; twelve words read on one line when revealed, and the sheets lose the reserved height). **THE PIN**
  (`App/Variorum/VariorumTests/Protection/WordsFieldsConcealTests.swift`, NEW — structural, source-read, harness):
  `noWordsFieldIsAPlainTextField` (no `TextField(` in either app's product code carries a words label or a words binding)
  and `everyWordsFieldIsThePasswordsSharedConcealingField` (each of the eight sites is a `PeekableSecretField(` call with
  its label; the shared field still conceals until toggled and on clear). **RED on the pre-fix faces:** `✘ Test run with 2
  tests in 1 suite failed … with 9 issues` (eight sites + the sweep). **GREEN after:** `✔ Test run with 2 tests in 1 suite
  passed`; `build-for-testing` Mac **and** iOS (`App/Variorum/DerivedData/vx329-r1-ios`, cloned from U3's) **`** TEST
  BUILD SUCCEEDED **`**, no warning in a touched face. Her eyes: the stage batch's walk captures (each field concealed,
  then revealed by the eye — captures-before-typing with a disposable words string, never the dev pair). **REVERT CHECK
  (on `471b57fc4`, the tree clean first):** the six face files checked out from `471b57fc4~1` (the pre-fix faces) → `✘ …
  failed … with 9 issues` (the same nine); restored by `git checkout HEAD --`, `git diff HEAD --exit-code` and `git status`
  clean. (A first attempt passed the six paths in one unsplit zsh variable — both checkouts refused, nothing changed;
  re-run with the paths spelled.) **VX-463: DONE (`471b57fc4`).**
- Piece 8 — the evidence: DONE (this commit; the tree `471b57fc4` — nothing but this record changed after it) — each run
  foreground (the release run outlived the 10-minute call cap and was waited on by polling its log).
  - `swift test` (debug, the whole package): **VariorumCoreTests 3298 tests in 430 suites — ONE red,
    `StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar` ("Time limit was exceeded: 60.000 seconds", after
    167 s under the full parallel run) — re-run ALONE GREEN (`StarContextTests` 11/11, 0.7 s)**; no known issue left (the
    two VX-462 wrappers dropped — the suite reported "2 known issues" at U1/U3); VariorumMCPTests 383 tests, ONE red — the
    recurring `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (19.1 s against
    its 15 s bound) — re-run ALONE GREEN (3/3, 2.2 s); StringsWorkbook 32/32. Neither red is near a line of this unit (no
    Queries, observation or MCP code touched).
  - `swift test -c release` (the whole package): **VariorumCoreTests `✔ Test run with 3269 tests in 425 suites passed`**
    (no known issue — U1's 3267 with 2 known issues, + this unit's two new core pins, the wrappers gone); StringsWorkbook
    32/32; VariorumMCPTests 383 tests, TWO reds — the same time-limit flake and `MCPSizeCapTests
    .aMessageOneByteOverTheSessionCapIsAnsweredThenClosed` (`socket.isHungUp()` at 0.9 s) — both re-run ALONE under
    `-c release` GREEN (`✔ Test run with 10 tests in 2 suites passed`). The MCP target is untouched by this unit.
  - THE HARNESS (debug — the app test targets' only configuration; under `-c release` it does not build, as U3 recorded:
    the app's protection suites name DEBUG-only walk machinery, exactly as the Xcode test targets build in Debug only;
    this session's scratchpad `u3-harness`, re-used, plus symlinks for this unit's three new test files and
    `WhatsNewLedger.swift`): **`✔ Test run with 386 tests in 65 suites passed`**, 0 skipped (U3's 375/60 + this unit's 11
    tests in 5 new suites: HoldBanner 3, WhatsNewWaits 3, WordsFieldsConceal 2, the Move pin, the follow guard, the
    VX-469 pin).
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx329-r1
    build-for-testing`: **`** TEST BUILD SUCCEEDED **`**; `-scheme VariorumMobile -destination 'generic/platform=iOS
    Simulator' -derivedDataPath …/vx329-r1-ios build-for-testing`: **`** TEST BUILD SUCCEEDED **`** — both after the last
    code edit (piece 7's faces), no warning in a file this unit touched.

**THE DISPOSITIONS (every member):**
- **VX-461 — FIXED** (`3470c6905`): the mechanism proven under a one-path sandbox profile; pin `StorePlaintextExportTests
  .theCopyLandsInThePickedFileAloneWhereNoSiblingCanBeMade`, red on old, revert-checked. Live proof: the walk.
- **VX-462 — FIXED** (`ab4e2cbe3`): `JoinWordsMomentSetUpArmTests`' two `withKnownIssue` wrappers DROPPED (the red-on-old)
  + the words-join arm; two old-shape pins flipped (recorded); revert-checked. The re-keying roads' same shape → F-R1-4.
- **VX-464 — FIXED** (`181774e60`): the join's two pins flipped, Move's pin, the follow's guard; red on old (8 issues),
  revert-checked. Words PROVISIONAL P-VX329-R1-1.
- **VX-469 (c) — BUILT as ruled** (`557558321`): the line on both entering confirms; red before the wiring, revert-checked.
  Words PROVISIONAL P-VX329-R1-2; her eyes at the walk capture.
- **VX-473 — FIXED** (`cf9efc580`): the fact + the root's composition (red on the old root), revert-checked.
- **VX-468 — FIXED** (`82285d1d3`): the ledger's wait (red on the old claim) + the composition, revert-checked. Reach
  PROVISIONAL P-VX329-R1-3.
- **VX-463 — BUILT as ruled** (`471b57fc4`): eight sites on the shared concealing field; the structural pin red on the old
  faces (9 issues), revert-checked; the design row's evidence is the walk capture. Shape PROVISIONAL P-VX329-R1-4.
- No member dismissed as hollow; none deferred.

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle):**
- **P-VX329-R1-1 — VX-464's two sentences:** (a) BUILT *"That passphrase doesn't open this account."* / *"Those twelve
  words don't open this account."* (the plan's ruled direction); (b) name the account by its email where the sign-in has
  one (*"…doesn't open vx@example.com's account."*).
- **P-VX329-R1-2 — VX-469 (c)'s line and its homes:** (a) BUILT *"The libraries in Previous Libraries keep their own
  quiet roads on this Mac — Castle protects the library you have open."*, unconditional, on Use Castle and the join into a
  Castle account (the confirms that say what entering does and the backups warning); (b) said only when this Mac holds a
  Previous Library (a new catalogue fact into the door's words); (c) on the follow into Castle too.
- **P-VX329-R1-3 — VX-468's reach:** (a) BUILT — the three copy doors (Make this my library, the empty slot's landing, a
  plain-text copy brought in); (b) also a creation (Start a New Library from rule 27's lobby — a fresh library's first open).
- **P-VX329-R1-4 — VX-463's field shape:** (a) BUILT — the shared field as it is: single-line in both states, the lobbies'
  words fields still submit by their button only (Return does nothing there, as before); (b) a multi-line reveal for the
  words (a second shape of the shared field); (c) Return submits the lobby's words too.

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-R1-1 (VX-461 — the ladder's):** the copy's sidecar sweep after the export (`-wal`/`-shm`/`-journal` beside the
  picked file) is a no-op by construction now (the journal never touches the disk); kept, its one risk being a stranger's
  file of those names beside a NEW pick. Delete or keep.
- **F-R1-2 (VX-461 — a ticket or not):** a copy that fails for any OTHER reason still leaves the picked file the ATTACH
  created (0 bytes or partial). Not built: after the fix no failure seam reaches that arm, so no pin could go red (the
  hallucination guard). Option: remove the picked file on a refused copy (the guard proves it was the export's own).
- **F-R1-3 (VX-461 — for §8's record):** W-VX309-4's one-literal-path probe (the system `sqlite3`, which passed) was not
  this grant's shape: under a profile that denies writes in the folder and allows the one literal path, the system
  `sqlite3` fails at the first write exactly as the export does (piece 1, run D).
- **F-R1-4 (VX-462 — the orchestrator's, likely a ticket):** the own-words-lock-beside-the-copy shape is also made by the
  RE-KEYING roads (traced by reading, not pinned): a join that crosses postures typed with the words (`AccountMoveProgram`'s
  `keyFile` step → `KeyFileCrossings`'s `building` with `locks.words` and the copy), a synced crossing (both secrets typed),
  a synced key door re-wrapping the copy. After a leave, their passphrase re-join still speaks (true — it over-speaks, the
  P-VX309-U2-1 class). The same rule (no own words lock where the copy is written) would sit in the re-key's key-file
  builder — every re-key's, so not this rider's.
- **F-R1-5 (Tests & tooling — new sighting):** `StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar` exceeded
  its 60 s time limit under the full parallel debug run; green alone. A load-starved observation, no line of this unit.
- **F-R1-6 (Tests & tooling — known):** the `MCPHarnessTimeLimitTests` wall-clock flake, sighted again (debug and release);
  and in release `MCPSizeCapTests.aMessageOneByteOverTheSessionCapIsAnsweredThenClosed` (`socket.isHungUp()` at 0.9 s
  under the full load) — both green alone under `-c release`. A ticket's, the orchestrator's (the MCP target untouched).
- **F-R1-7 (VX-464 — note only):** a one-secret door's `secretMissing` refusal says *"Enter your passphrase and your
  twelve words."* (`crossingSecretsMissing`) though the join asks ONE; the sheet's button is disabled until a secret is
  typed, so the line looks unreachable from the face — recorded, not touched.

**MAC-SUITE LIST (the orchestrator's stage batch — compiled, the Mac-only ones unrun here):** Mac
(`-only-testing:VariorumTests/<Suite>`): this unit's NEW suites — `HoldBannerAccountFactTests`,
`HoldBannerAccountCompositionTests`, `WhatsNewWaitsAfterAdoptionTests`, `WhatsNewWaitsCompositionTests`,
`WordsFieldsConcealTests` (all harness-green); the suites over what changed — `WhatsNewTests` (the ledger relocated, the
claim's new parameter), `ProtectionJoinFollowRoadTests`, `ProtectionAccountRoadTests`, `RoadAccountFacesTests`,
`RoadAccountSurfaceTests`, `RoadJoinFollowFacesTests`, `RoadJoinFollowSurfaceTests`, `RoadCrossingFacesTests`,
`RoadCrossingSurfaceTests`, `ProtectionCrossingRoadTests`, `ProtectionCrossingRouteTests`, `SetPassphraseRowRereadTests`,
`ProtectionPaneWaveTests`, `RoadKeyDoorSurfaceTests`, `PassphraseFloorRoadTests`, `EmptySlotDoorsSurfaceTests`,
`ProtectionWordsVX307Tests`, `CopyRegisterPinTests` (the two-register rule over the new lines),
`TravellingDotsIndicatorTests`, `PlaintextExportDoorTests`, `PickedCopyRoadTests`, `PlaintextExportBringInRoadTests`,
`LibraryPortabilityDoorTests` (the banner's two texts), `ChromeMinHeightTests` (the hold bar); U1's whole
`VariorumTests/Protection/` folder covers the rest. Phone (`VariorumMobileTests`, simulator): `MobileProtectionTests`
(the lobby's words field), `MobileSnapshotPrivacyTests`, `MobileStructuralTests`.
**THE WALK ROWS THIS UNIT OWES (the stage batch's — use, not pins):** VX-461 THE LIVE PROOF — Settings ▸ Data Safety ▸
*Export an unencrypted copy* into a user-picked folder (`~/Downloads` and one other) writes a WHOLE file (open it; count
its notes) and nothing beside it; the backups-folder refusal still speaks. VX-463 — each words field concealed, then
revealed by its eye (both voices; a disposable words string, captured before typing). VX-469 — Use Castle's confirm with
the line (both voices). VX-464 — the join's wrong-passphrase refusal names the account. VX-473 — Make this my library
while signed in: the hold banner without the catch-up clause. VX-468 — needs a recorded older marketing version in the
dev domain to make the card due, then a launch on the missing face and T-5: no card at that open, the card at the next
launch (the orchestrator's to stage or leave pin-covered). VX-462 — set up sync, Stop syncing here, re-join by the
passphrase: no words moment (the throwaway).

### FIX LEG RECORD — THE MAC SUITE'S SIX REDS (Opus implementer, 2026-10-22; DONE — the re-run of the affected Mac suites is the orchestrator's stage batch)

**Not done in the fix leg, first:** NO `xcodebuild test` (the brief's limit — the orchestrator re-runs the affected suites
at the stage after this lands), so every fix below is COMPILED and its green is PENDING that re-run. No stage, no app
launch, no store touch, no network, no subagent; zero `Sources/` lines (the six reds are all test-side). The seventh name in
the run's failing list (`RoadLockViewNamesPinTests.theBackupsFolderIsTheCataloguesName`) is NOT one of the six and NOT
touched — the test host CRASHED in it (a real `EXC_BREAKPOINT`, not a timeout) and the restarted host reported its suite
with no test run; traced and FLAGGED below (F-FL-1), its fix the orchestrator's to route.

**The run read:** the orchestrator's full Mac app suite (`xcodebuild test`, the first app-side run after the switch; its log
in the session scratchpad, `vx329-mac-suite.log`): `✘ Test run with 1556 tests in 274 suites failed … with 3 issues
(including 1 known issue)` for the restarted host's tail, the failing list naming the six below (plus the restart).

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece R — this record skeleton, the six traced and dispositioned: DONE (this commit).
- Piece 1 — the lifetime mechanism (failures 2–5) proven headless by a transient probe: DONE (this commit). The probe
  (`FixLegLifetimeProbe`, never committed — U3's headless harness in the session scratchpad, `u3-harness`, which
  compiles `PlantedRoad`/`TempSlot`/`Crossing` and the road but not `AppBootstrap`) drives the failing sites' exact
  shape — a helper that takes an inline `PlantedRoad()`, makes the library and returns the session, the system and the
  slot's URL (what the bootstrap keeps) but never the road — beside the same helper over a HELD road:
  RELEASED → the slot's file is gone at the call's end; the send act throws exactly *"ProtectionLibraryFiles: no file at
  variorum.sqlite"* (failures 4 + 5's detail, verbatim); Use Castle (the bootstrap's preflight-then-act order,
  `Crossing.press`) reports `.made` while the library stays STANDARD (failure 2 — the catch's no-file arm reads as past
  the swap); after a crossing made while the road lived, the lobby's passphrase road (`ProtectionOpenRoad.openTyped`
  over the kept system) opens NOTHING (failure 3). HELD → the send lands exactly the pair, `PickedCopy` reads `.pair`,
  the words open it to the library's key, and a row written through a pool OPEN on the slot (in its WAL) travels inside
  the copy (failures 4 + 5's claims, the snapshot's backup-API read); the crossing lands in Castle; the passphrase opens
  it. **`✔ Test run with 6 tests in 1 suite passed`** (all six arms as stated). So nothing hides behind the lifetime
  defect on the send, crossing and typed-road paths these four tests drive — the remaining unproven layer is the
  bootstrap's own wrapper (its `.ready` guard, the pool close and reopen), which is the stage re-run's.
- Piece 2 — failures 2–5 fixed (the road held for the test's life): DONE (this commit; the compile PENDING piece 4's
  `build-for-testing`, the green PENDING the orchestrator's stage re-run). Every one of the eight inline sites U1's
  rewire left (`SettingsLockCloseTests` ×5 — the three green ones too, so `aReopenRoadShowsTheOpeningSpinnerMidCeremony`
  stops passing vacuously over a crossing that never crossed and a reopen that minted a fresh library;
  `LibraryHandOffTests` ×2; `LibraryPortabilityDoorTests` ×1) now reads `let road = PlantedRoad()` + `defer {
  withExtendedLifetime(road) {} }` (explicit — never leaning on Debug's lexical lifetimes) and passes `road`; no
  expectation, claim or helper body changed. `LockWorld.readyInStandard`'s doc and `SettingsLockCloseTests`' own helper
  say the caller holds the road (comment only). A sweep for the hazard's other shapes (`PlantedRoad().…`, an inline
  `TempSlot(…)`) across both test trees: none.
- Piece 3 — failures 1 and 6 rewritten to the new road's truth: DONE (this commit; the compile PENDING piece 4, the
  green PENDING the stage re-run). **1:** `aFreshStoreOnTodaysRoadSeedsHerFiveBlocksAlone` DELETED with its subject
  (today's road's five-only readme — U1 `c3d939c9e`) and REPLACED by
  `aFreshStoreOfEitherVariantSeedsHerFiveThenTheFourPassages`: per `StoreVariant` (`.real` and `.dev`), each in its own
  fresh launch world through `LaunchFurniture.seed`, the readme holds nine blocks and renders `herBlocks +
  startHerePassages` joined (the oracle built from the two lists, never from `paragraphs` — so a variant fork returning
  inside the seeder reads red), and the real variant's page equals the dev variant's byte for byte. Its red side is the
  run's own: the real variant read nine where today's road read five. **6:** the new-road half byte-unchanged (2 beside,
  1 far); the second half now asserts that with no road counts both rows count NONE over the same planted flat files
  (beside: `FolderSummary(path as read, exists, 0, nil, nil)`; far: still `.set` at the same path, 0/nil/nil); the test
  renamed `theRowsCountThisMacsPairsOfThisLibraryAndNeverTheFlatFiles` (its doc names the old one and why); the file
  header made true.
- Piece 4 — the evidence: DONE (this commit; the tree `3335bdb8b` — nothing but this record changed after it; every run
  foreground, in sequence):
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx329-fixleg
    build-for-testing` (APFS-cloned from R1's `vx329-r1`): run 1 FAILED on my own slip — `invalid redeclaration of
    'road'` in `aReopenRoadShowsTheOpeningSpinnerMidCeremony`, whose crossing `Task` already owns the name; its planted
    road is `planted` (`3335bdb8b`) — run 2 **`** TEST BUILD SUCCEEDED **`**. One warning in a touched file,
    PRE-EXISTING and not this leg's line (`LibraryPortabilityDoorTests.swift:85`, `UnnecessaryEffectMarker`, blamed
    2026-10-07; in R1's log and the stage batch's too).
  - `xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' -derivedDataPath
    App/Variorum/DerivedData/vx329-fixleg-ios build-for-testing` (cloned from `vx329-r1-ios`): **`** TEST BUILD
    SUCCEEDED **`** (no phone file touched — the sanity build).
  - THE HEADLESS HARNESS (U3's, debug — the app test targets' only configuration): with the probe in **`✔ Test run with
    392 tests in 66 suites passed`** (R1's 386/65 + the probe's 6/1), then the probe REMOVED (transient — the harness is
    left as R1 left it) **`✔ Test run with 386 tests in 65 suites passed`**, 0 failures, no skip. None of the six suites
    compiles there (each needs `AppBootstrap`, `DataSafetyModel`/`StoreBackup` or `LaunchFurniture`) — their run is the
    stage re-run below.
  - THE CORE: untouched — `git diff aec559bca..HEAD -- Sources Tests Package.swift Tools` is EMPTY, so R1's floor (debug
    3298 / release 3269) stands by construction; not re-run (no line of the package or its tests changed, either
    configuration).
  - CORROBORATION from the stage run itself: `RoadLockRouteTests.lockNowClosesACastleLibraryBehindTheLobbyAndItsSecretOpensItAgain`
    — which holds its road as a local and drives failure 2's and 3's exact bootstrap path (ready → the crossing into
    Castle through the bootstrap → lock → the lobby's typed unlock → ready) — PASSED in the same run; with the road held,
    2 and 3 run that path.

**THE DISPOSITIONS (every one of the six):**
1. `LaunchFurnitureTests.aFreshStoreOnTodaysRoadSeedsHerFiveBlocksAlone` — **(a) STALE PREMISE**, rode U1's deletion of
   today's road's five-only readme (`c3d939c9e`); the test DELETED with its subject and REPLACED by the new road's truth,
   `aFreshStoreOfEitherVariantSeedsHerFiveThenTheFourPassages` (`79d11ea74`). The run's red is its red-on-old.
2. `SettingsLockCloseTests.aReopenRoadThroughOpeningKeepsTheSettingsWindow` — **(c) TEST-WORLD DEFECT** of U1's rewire
   (`e52f3f275`), the planted road's lifetime; FIXED in the test (`7438d26a4` + `3335bdb8b`), claim unchanged.
3. `SettingsLockCloseTests.theLibraryClosedRuleNamesTheSettledClosedStatesAndNeverOpening` — **(c)**, the same; FIXED
   (`7438d26a4`).
4. `LibraryPortabilityDoorTests.theHandOffDoorProducesThePairRevealsItAndWordsItsRefusal` — **(c)**, the same; FIXED
   (`7438d26a4`).
5. `LibraryHandOffTests.theHandOffFolderRoundTripsThroughTheOpenDoorAndItsOwnKeyFile` — **(c)**, the same; FIXED
   (`7438d26a4`).
6. `DataSafetyRoadCountsTests.theNewRoadsRowsCountThisMacsPairsOfThisLibraryAndTodaysRoadIsUnchanged` — **(a) STALE
   PREMISE** in its second half, rode U1's deletion of today's flat-file count (R-U1-5); that half REWRITTEN to the new
   truth, the new-road half untouched, the test renamed `theRowsCountThisMacsPairsOfThisLibraryAndNeverTheFlatFiles`
   (`79d11ea74`).
- None is **(b)**: no product line is wrong on the paths these six drive (the probe's held arms prove the send, the
  crossing and the typed road; the run proved the seeder and the counts). No new-road pin was weakened. No row hollow.
  **Why (c) and not (a)/(b):** the four tests' premises are the new road's and true, and the product does what they
  claim; the world they built destroyed its own library under the bootstrap — a test-harness lifetime, fixed in the test
  with no expectation touched. If the orchestrator reads the brief's two classes as exhaustive, (c) sits nearer (a)
  (a test-side cause, the product untouched), and is recorded as its own class so it is not mistaken for a premise
  rewrite.

**THE SIX — the traced mechanism and the disposition of each (recorded before any fix):**
1. **`LaunchFurnitureTests.aFreshStoreOnTodaysRoadSeedsHerFiveBlocksAlone`** (:389 `blocks == 5` read 9, :390 the rendered
   page read her five + the four Start Here passages) — **(a) A STALE PREMISE.** The pin held TODAY's road's readme (her
   five blocks alone on the `.real` variant, "until the road switches (VX-329)" — its own doc); U1 deleted that variant
   fork deliberately (`c3d939c9e`, the seeders half of piece 0 — `ReadmeSeeder.paragraphs` is `herBlocks +
   startHerePassages` for every store: "today's five-only variant went with today's road"). The product is right; the pin
   is today's road's. Disposition: REWRITTEN to the new road's truth through the same production composition — a fresh
   store of the `.real` variant (the Release builds' store) seeds the same nine blocks as every store, her five first and
   byte-exact (the four-passage static fact is `ReadmeStartHerePlanTests.theFourPassagesSeedInEveryStore`; this keeps the
   behavioural one).
2. **`SettingsLockCloseTests.aReopenRoadThroughOpeningKeepsTheSettingsWindow`** (:195 — the crossing's reopen did not land
   in Castle) — **(c) A TEST-WORLD DEFECT in U1's rewire — neither a stale premise nor a product break.** The mechanism
   (inputs → wrong state): the test hands an INLINE `PlantedRoad()` to `readyInStandard(_:hold:)`, which returns the
   bootstrap and the words and never the road; the bootstrap keeps the road's `ProtectionSystem` (its `places` are URLs, a
   value) and the opener's captured URL — nothing that holds the road — so the road is released when that call expression
   ends, and `TempSlot.deinit` (`ProtectionTestSupport.swift:65`) removes the slot's whole folder: `variorum.sqlite`, the
   key file, the lived-here marker. The open pool keeps its unlinked file (reads and writes still work), so the ready
   stands; the crossing's act then opens the slot by PATH (`ProtectionLibraryFiles.keyedQueue(…, mustExist: true)`) →
   *"no file at variorum.sqlite"*; its catch arm finds the old key no longer opening the (absent) slot and logs *"useCastle
   swapped, then stopped"*; the reopen routes an empty slot → a FRESH library (the log's `create library: c7ebbe3b`) in
   Standard. The claim (the window survives a reopen road) was never reached. Every inline site came in at U1's rewire
   (`e52f3f275`, compiled, never run). Disposition: the test HOLDS its road for its whole life (the canonical
   `RoadLockRouteTests` shape — `let road = PlantedRoad()`), the claim and every expectation unchanged.
3. **`SettingsLockCloseTests.theLibraryClosedRuleNamesTheSettledClosedStatesAndNeverOpening`** (:205 — `.notReady("after
   the unlock: roadLobby(…)")`) — **(c), the same mechanism**: `LockWorld.readyInCastle(PlantedRoad())` crosses while the
   road lives (the log's `enter_castle: done`), the road is released at the call's end, the lock lands in the lobby
   (nothing path-based), and the lobby's typed road finds no library to open — the reopen never comes. Disposition: as 2.
4. **`LibraryPortabilityDoorTests.theHandOffDoorProducesThePairRevealsItAndWordsItsRefusal`** (:234 — `.refused("The
   travelling folder couldn't be made…", detail: "ProtectionLibraryFiles: no file at variorum.sqlite")`) — **(c), the
   same mechanism** at `LockWorld.readyInStandard(PlantedRoad())`: the send act's snapshot opens the slot by path
   (`ProtectionLibraryFiles.snapshot` → `keyedQueue(…, mustExist: true)`) — the detail string is that throw, verbatim.
   Disposition: as 2.
5. **`LibraryHandOffTests.theHandOffFolderRoundTripsThroughTheOpenDoorAndItsOwnKeyFile`** (:37 — `.failed("…no file at
   variorum.sqlite")`) — **(c), the same mechanism and the same throw** (the marked row's write succeeded through the open
   pool's unlinked file; the send then found no file). Disposition: as 2; its sibling
   `aLibraryWithoutItsKeyFileRefusesAndLeavesNothingBehind` (green — it refuses before any path read) is held the same way
   so no inline site stays.
6. **`DataSafetyRoadCountsTests.theNewRoadsRowsCountThisMacsPairsOfThisLibraryAndTodaysRoadIsUnchanged`** (:89 `primary
   count == 3` read 0, :93 `far count == 2` read 0) — **(a) A STALE PREMISE.** The pin's second half held TODAY's road
   (no `roadCounts` → the folders' flat files counted "exactly as before"); U1 deleted today's flat-file count with today's
   flat legs (R-U1-5: "Data Safety's two rows count the catalogue's pairs only (today's flat-file count deleted)") — the
   model's own comment: `roadCounts` nil — no library's faces — "counts none". The new-road half (this Mac's pairs of this
   library: 2 beside, 1 far — never another Mac's or another library's) was GREEN in the run and stays byte-unchanged.
   Disposition: the second half REWRITTEN to the new truth over the same planted world — with no road counts the rows
   count NOTHING (today's flat files never count, either way) while each row's path and the picked folder's set state stay
   as read; the test renamed to say so (its old name asserted today's road), the file header made true.

**FLAGS (not this leg's; for the orchestrator):**
- **F-FL-1 — THE SEVENTH RED, a test-host CRASH (outside the six; not touched).**
  `RoadLockViewNamesPinTests.theBackupsFolderIsTheCataloguesName` crashed the host (`~/Library/Logs/DiagnosticReports/
  Variorum-2026-10-22-082458.ips`: `EXC_BREAKPOINT`/SIGTRAP in `_dispatch_assert_queue_fail` ← `_swift_task_checkIsolatedSwift`
  ← closure #1 in `static RoadLockView.copiesHome(besideStore:)` ← `Sequence.contains(where:)` ← the test's `#expect` at
  `RoadLockViewNamesPinTests.swift:45`). The mechanism as read: `copiesHome` is a static on a `View` in the app target
  (default `MainActor` isolation), and its `contains { … }` closure carries that isolation with Swift's dynamic isolation
  check; the suite is NONISOLATED (the test target has no default isolation), so Swift Testing may run it off the main
  thread, and the check traps. U1 added the two `copiesHome` calls to this pin (its "VX-329 U1:" comment). The restarted
  host then reported the suite "passed after 0.001 seconds" with no test line, so the test never re-ran. Options for
  whoever owns it: `@MainActor` on the suite (test-side, the `LockWorld` suites' shape), or `nonisolated` on
  `copiesHome` (product-side — a pure file-existence read). Unpinned and unfixed here, by the one-unit rule.
- **F-FL-2 — the crossing reports `.made` when the library file is gone (seen through the probe; a product edge, not
  built).** `ProtectionCrossings.cross`'s catch treats "the old key no longer opens the slot" as "past the swap"
  (`ProtectionCrossingActs.swift:242–249`), so an act that threw BEFORE any swap because the slot's file was missing
  (`no file at variorum.sqlite`) logs *"swapped, then stopped"* and returns `.made(door, …)` while the library stays in
  its old mode; the reopen then routes the slot as it finds it. The same `opens(slot, key: oldKey)` test decides the
  account acts' catch (`ProtectionAccountActs.swift:278–293`) and Make this my library's (`ProtectionCopyDoors.swift:
  308–316`); the empty slot's landing (`:417–420`) asks `slotIsOccupied()` instead and is not this shape. Reachable in
  product only if the library's file vanishes under an open library. A ticket or not — the orchestrator's (no ruling exists for that face; nothing invented).
- **F-FL-3 — a hazard-class note for the next harness writer:** any helper that builds a bootstrap or a session from a
  `PlantedRoad` and returns without it hands the caller a world whose files die with the road. `LockWorld`'s doc now says
  so; no other inline site exists in either test tree (swept).

**MAC-SUITE RE-RUN LIST (the orchestrator's stage batch — `-only-testing:VariorumTests/<Suite>`; compiled, unrun here):**
`LaunchFurnitureTests` (the whole suite — the replaced pin is `aFreshStoreOfEitherVariantSeedsHerFiveThenTheFourPassages`),
`SettingsLockCloseTests` (all five — the three that were green now run a real crossing too), `LibraryPortabilityDoorTests`,
`LibraryHandOffTests` (both road tests), `DataSafetyRoadCountsTests` (the renamed
`theRowsCountThisMacsPairsOfThisLibraryAndNeverTheFlatFiles`), `RoadLockRouteTests` (a doc comment only — the sanity
run). Read `skipped:` and the "Test run with N tests" line before claiming them. F-FL-1's `RoadLockViewNamesPinTests` is
still red-by-crash until someone takes it.
 (2026-10-22, the orchestrator — session `vx-329`, Fable, overnight mandate)

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

### THE STAGE BATCH RECORD (the orchestrator, Fable, 2026-10-22; stage claim `vx-329`, renewed per row)

**Run 1 — the FULL Mac app suite** (the honest run: every launch takes the new route; `xcodebuild test`,
DerivedData `vx329-stagebatch`): SEVEN reds — six test failures (LaunchFurniture's today's-road readme pin,
SettingsLockClose ×2, LibraryPortabilityDoor, LibraryHandOff, DataSafetyRoadCounts' today's-road half) and ONE
HOST CRASH the first grep missed (`RoadLockViewNamesPinTests` — EXC_BREAKPOINT in the dynamic actor-isolation
check; the restarted host said "no test run", so it printed no ✘ — the lesson: read the crash reports, not only
the ✘ lines). **The fix leg** (its record above) dispositioned the six: two stale today's-road premises rewritten
to the new road's truth, four the PLANTED ROAD'S LIFETIME — U1's rewire passed an inline `PlantedRoad()` the
bootstrap doesn't retain, so `TempSlot.deinit` deleted the slot under a ready bootstrap; every site now holds its
road (test-only; one previously-vacuous spinner pin now really crosses). F-FL-1 (the crash) fixed by the
orchestrator's own hand: the suite takes `@MainActor`; the product keeps its isolation. **Run 2 — the full Mac
suite again, on the fixed tree: GREEN — 5085 tests in 889 suites, 14 known issues (standing wrappers), exit 0.**
The phone's full simulator suite runs next (the record flips below). Findings carried: F-FL-2 (the catch arms'
past-the-swap read when the library file vanishes mid-act — ticket at closeout), F-FL-3 (the lifetime trap's
class note), and the recurring MCP harness timing flake (its ticket at closeout).
