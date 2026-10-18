# VX-305 — the key map's model half

**What this is.** The go/no-go's item 5 (`notes/plans/vx-305-castle-core.md` §1): *"The model half of the key-map
table is written: one row per element of the target key map, naming the test that proves the model does it. The code
half comes at phase 5."* One row per element of the acceptance checklist at the end of
`notes/plans/vx-266/castle-target-key-map.html` — 47 elements: C-1…C-11, H-1…H-5, S-1…S-7, R-1…R-6, T-1…T-8, A-1…A-4,
L-1, K-1…K-4, O-1. Each row quotes the element in one line, names the tests that prove the model does it, the scenario
promises and mutation pins that carry it, and gives a status.

**Code tree: `63cf038f1`** (the ladder's close, plan §9; every later commit on the branch is a record). Written
read-only on code while the go/no-go soak ran: every test named here was READ, none was run for this file. Their green
state is the ladder-close runs on that tree — Debug `434 tests in 71 suites`, `swift test -c release` `372 in 66`
(the five DEBUG-only mutation-pin suites, 62 tests, compile out) — recorded in plan §9.

**The soak (the coordinator's word, 2026-10-16, received while this file was being written):** the go/no-go soak on
`63cf038f1` FAILED — 13 of 20 seeds, in both configurations — and a triage follows this session, so tests may be added
afterwards. This table is written against `63cf038f1` as briefed and does NOT account for the soak's failures: a
PROVEN row here means the named tests assert the claim, not that the generated runs are green.

**Status — each row's status is its MODEL half:**
- **PROVEN** — everything the element says that the model can carry (the values, `assess`, the route finder and
  catalog, the executor over its leaves, the scenario world and its promises) is asserted by the named tests. Whatever
  the element's "proven by" column names beyond the model — a real-Keychain drill, the posture or restore drill, a walk,
  a live round, the fake-server or convergence suite, a face, the real persistence — is listed as **Code half** (phase
  5's table), with the phase that builds it.
- **PARTLY** — part of the model half is built and asserted; the rest is a model road a recorded ruling or record
  defers to a later phase, named.
- **NOT A MODEL CLAIM** — the element lives only in the code half; the phase that owns it is named.
- **CUT** — removed by her ruling; the ruling's words are quoted and what of the row survives is said.
- **GAP** — a phase-1 model clause no test asserts. *Narrow*: the code path exists (cited) and only the assertion is
  missing. *Substantive*: no road in `Sources/VariorumCore/Protection/` runs it. The test it needs is written out; no
  test was written here.
- A clause CUT inside an otherwise-standing row is marked **CUT clause** in that row.

**The two rulings the CUT rows and clauses quote** (plan §8, verbatim):
- **LC** — HER RULING, 2026-10-14, THE LEGACY CUT: *"we don't need to keep every store shape today's builds ever left.
  they don't need to keep opening forever. as long as everyone's current store stays fine to open, we really don't need
  anything else"*; the plan's record of it: "What DROPS: pre-rebuild copies opening on the new system, Previous
  Libraries and set-aside stores from before the switch, other libraries' old copies — and therefore: the migration's
  fold beyond the current key; §3.5 point 2's gift machinery (per-library key files + own Apple keys for OTHER
  libraries' old copies); the legacy readers' keep-forever role (they become migration-only); the 'copy with no record'
  open road; the retirement sheet's old-copy listings." What STANDS: "the catalog/retention/offer still LIST and DELETE
  old copies as files (VX-265's delete choice survives) — they just don't open."
- **LCW** — HER RULING, 2026-10-15, THE LEGACY CUT WIDENED: NO OLD BUILDS: *"yeah i mean we do need to make sure that it
  doesn't ruin my existing store for sure, but no old backups or builds have to be considered."* The scoping: "DROPS —
  old builds as LIVE, CONCURRENT ACTORS after the switch: an un-updated device completing a rotation, an older build's
  Re-link re-landing a vault, the last-step-race arms"; every state an old build has already left in a current store
  STAYS as a migration input. The older-build fixed scenarios stay "beyond scope, kept while green".
- The phase-1 model arms the cut kills (the fold beyond the current key, the gifts) stay built and green: "phase 1
  closes with the model as built and green"; they are "removed with their tests at phase 2's first act".

**LIVE STATUS: DONE (2026-10-16)** — all 47 rows written; the tally, the GAP list and the CUT list at the end. 31
PROVEN · 2 PARTLY · 1 NOT A MODEL CLAIM · 2 CUT · 11 GAP (2 substantive, 9 narrow). PENDING: nothing of this file's;
every test named was read on `63cf038f1`, none run here (their green is the ladder-close runs). The go/no-go soak on
that tree FAILED (13 of 20 seeds, both configurations — the coordinator's word); its triage follows and may add tests;
this table doesn't account for it, and a re-read against the triage's final tree is owed before the GO record cites it.

---

## The suite index (every suite a row names, and its file under `Tests/VariorumCoreTests/Protection/`)

| suite | file | | suite | file |
|---|---|---|---|---|
| `ProtectionNamesTests`, `ProtectionSealTests` | `NamesAndSealTests.swift` | | `OpenRuleTests` | `OpenRuleTests.swift` |
| `ProtectionValueRoundTripTests`, `FamilyTreeTests`, `HardwareMarkerTests`, `DeviceFactsTests`, `SealedHomesAndPlansTests` | `RecordModelTests.swift` | | `CatalogNameTests`, `CatalogAttributionTests` | `CatalogTests.swift` |
| `KeyFileWrapTests`, `KeyHistoryTests`, `KeyFileCrossingTests`, `CastleAnchorTests` | `KeyFileTests.swift` | | `RetentionTests`, `RetentionGuardMutationTests`† | `RetentionTests.swift` |
| `LegacyModeReaderTests`, `LegacyKeyFileTests`, `LegacyItemsTests`, `LegacyMarkerTests` | `LegacyReadersTests.swift` | | `RouteFinderRoadTests`, `AnchorSentenceTests`, `RetirementRoutesTests` | `RouteFinderTests.swift` |
| `ProtectionScanTests` | `ProtectionScanTests.swift` | | `AssessAccountTests`, `AssessVaultTests`, `AssessModeTests`, `AssessTouchIDTests`, `AssessRepairTests`, `AssessDoorTests`, `AssessOldSharedKeyTests` | `AssessTests.swift` |
| `ProtectionGuardsTests`, `ProtectionGuardMutationTests`† | `ProtectionGuardTests.swift` | | `AssessGuardsOnTests`, `AssessGuardMutationTests`† | `AssessGuardTests.swift` |
| `LiveKeyFileIsTheCurrentKeysTests`, `TakingOverStandingOldSharedTests`, `TouchIDLobbyWithNoHintTests` | `LadderRound1UnitPins.swift` | | `UseCastleTests` | `Executor/CrossingTests.swift` |
| `UseStandardTests` | `Executor/LeaveCastleTests.swift` | | `ReplaceAllKeysTests`, `FollowTests` | `Executor/FollowTests.swift` |
| `AccountJoinTests`, `LeaveAccountTests` | `Executor/AccountActTests.swift` | | `OpenCopyTests`, `LandTests`, `SmallCopyActTests` | `Executor/CopyActTests.swift` |
| `ExecutorKeyDoorTests`, `ExecutorDeviceActTests`, `SharedKeyActTests`, `ProtectionMigrationTests` | `Executor/DoorAndDeviceActTests.swift` | | `ExactWritesTests`, `ExecutorEdgeTests` | `Executor/ExactWritesTests.swift` |
| `SettleSealTests`, `ExecutorRepairTests` | `Executor/ExecutorCoreTests.swift` | | `ExecutorGuardsOnTests`, `ExecutorGuardMutationTests`† | `Executor/ExecutorGuardTests.swift` |
| `ExecutorLogScanTests` | `Executor/ExecutorLogScanTests.swift` | | `MigrationScenarios` | `Scenario/FixedScenarios.swift` |
| `AccountScenarios` | `Scenario/FixedScenariosAccounts.swift` | | `CopyAndCrossingScenarios` | `Scenario/FixedScenariosCopies.swift` |
| `CornerScenarios` | `Scenario/FixedScenariosCorners.swift` | | `DeviceScenarios` | `Scenario/FixedScenariosDevices.swift` |
| `GeneratorFoundScenarios` | `Scenario/FixedScenariosFound.swift` | | `MoreScenarios` | `Scenario/FixedScenariosMore.swift` |
| `ScenarioMutationPins`† | `Scenario/MutationPins.swift` | | `GeneratorTests` | `Scenario/Generator.swift` |
| `LadderRound1MajorPin` | `Scenario/LadderRound1Pins.swift` | | `LadderRound1NewFindsPins` | `Scenario/LadderRound1NewFindsPins.swift` |
| `LadderRound2AbsentArmPin` | `Scenario/LadderRound2Pins.swift` | | `WorldSmokeTests` | `Scenario/WorldSmokeTests.swift` |

† DEBUG only (`#if DEBUG`): the mutation pins — each runs its case guarded (must hold) and with its
`ProtectionGuards` off-switch flipped (must fail).

**Helpers the rows lean on** (all read): `UseCastleStates.finished` / `.neverHappened` (`Executor/CrossingTests.swift`),
`UseStandardStates.finished` / `.neverHappened` (`Executor/LeaveCastleTests.swift`), `expectSettled` (no plan, no staged
file, copies running, nothing in flight; the record, the key file and what this Mac remembers name one key —
`Executor/ExecutorFixtures.swift`), `CrashHarness.everywhere` (a crash after EVERY write of a clean run, relaunch,
settle: finished or never happened, never both or neither — `Executor/CrashHarness.swift`), `walk` /
`expectEveryRoadOpens` (each named opener's witness road opened with the real secret of its day —
`RouteFinderTests.swift`), `mutationPin` (`Scenario/MutationPins.swift`).

## The promise index (design §4.1; the checkers in `Scenario/Promises.swift`, as `SWorld` methods)

| # | promise | checker | when |
|---|---|---|---|
| 1 | Known | `known` (one record per open library; the memory names its key and epoch; the live key file is the current key's unless a repair is owed — round 1's clause, P-R1-1's copy-less case exempt) | every step |
| 2 | Castle means Castle | `castleMeansCastle` (no silent item for any key of the tree; no silent sync-keys item for Castle-era keys; no Apple wrap of the current key; nothing a login-password holder reads opens the library or a copy made here, the stated exceptions taken out of the seeds) + `vaultInvariant` (no Apple wrap beside a Castle-era previous corpus key or over a Castle-era master) | every step; the retired-key clause once settled |
| 3 | Standard means Standard | `standardMeansStandard` (the live key file's Apple wrap of the current key under this Mac's own readable key) | at every settle |
| 4 | No silent change | `noSilentChange` (mode and account change only at a deliberate act; an opened copy never lowers the mode or brings its own key) | every step |
| 5 | Nothing stranded | `nothingStranded` (every copy made opens by her roads — every secret of every day, custody, every Apple account of hers, the vaults) | every step |
| 6 | Crash-safe | `crashSafe` (nothing left in flight but her ruled named-and-waiting synced act; no stray plan or staged file; copies paused only while waiting) | every step |
| 7 | Converges | `converges` (the account's mode and keys) | at every settle |
| 8 | The posture law | `castleMeansCastle`'s current-key reach (`fail(…, 8)`) | every step |
| 9 | Honest words | `honestWords` (every *Opens with* opener walked with the real secret of the day it names) | every `done` step of a fixed scenario; every 10th generated step and every settle |
| 10 | Sealed | `sealed` (in Castle, a tamper or a tamper group alone changes no mode, account, custody or weakening setting) | after each tamper step's relaunch |
| 11 | Own copies only | `ownCopiesOnly` (every retention prune is this Mac's copy of this library) | every step |
| 12 | Moving adds | `openableCopies` before and after (`SWorld.step`, `Scenario/Generator.swift`) | each `.moveOffSharedKey` step |
| 13 | Castle's stays Castle's | `castleStaysCastles` (after a leave, nothing the Apple account or a login-password holder reaches opens a key from before the leave) | every step |

Every fixed scenario (the `Scenario/FixedScenarios*.swift` suites, and each mutation pin's guarded run) takes its steps
through `SWorld.step` and ends `expectPromisesKept`; the soak is `GeneratorTests.seededSequencesKeepEveryPromise`
(`PROTECTION_SOAK=1`).

---

## The rows

### C-1 · PROVEN
**Element.** Castle: a Castle key's only device copy is its Touch ID item — none under Always ask; no silent item for
any key the library has had, the migration's per-library items included.
**Model proof.**
- Promise 2 (`castleMeansCastle`): a silent custody item holding any key of the family tree fails it; with promise 8,
  anything a login-password holder can read — every non-Touch-ID item, today's per-library `.key` items and the 13p
  escrow items included — that opens the library or a copy made here fails it.
- `AssessRepairTests.inCastleNoSilentItemForAnyKeyTheLibraryHasHad`;
  `AssessRepairTests.inCastleTodaysItemsAndKeyFilesGoOnceTheHistoryHoldsTheirKey` (today's per-library-ID bound item
  and the escrow item deleted once the history holds the key; a key the fold couldn't reach keeps its file);
  `ExecutorRepairTests.aSilentItemGoesOnlyWhenTheHistoryVerifiablyHoldsItsKey`;
  `ExecutorRepairTests.aLegacyItemGoesOnlyWhileItStillHoldsTheKeyTheHistoryHolds`.
- The writes: `UseCastleTests.useCastleLocalWritesExactlyThisInOrder` (`custody+ touchid K1` at the press, `custody-
  silent K0` after the swap; `UseCastleStates.finished` requires no silent item); `ExactWritesTests.theFollowIntoCastle`.
- None under Always ask: `LandTests.aCastlePairLandsWithItsWordsAloneThePassphraseMadeNew` (no item of either class for
  the landed Castle key); `ExecutorDeviceActTests.touchIDComesOnlyFromSettingsWithThePassphraseAndAlwaysAskDeletesTheItem`.
- Today's items through the crossing: `MigrationScenarios.corner45sAmbiguousCase` (the per-library silent item gone once
  answered), `AccountScenarios.todaysSyncCustodyGoesWhenTheLibraryEntersCastle`, `CopyAndCrossingScenarios.a13pEscrowItem`,
  `MigrationScenarios.aVaultThatMovedWhileTheLibraryDidntIsAnOrdinaryFollow` (the Castle-born key never in a silent item).
**Code half.** The real-Keychain drill on a throwaway scope (the accessibility classes, `.biometryCurrentSet`) —
phase 2's Keychain leg, phase 3's drills.

### C-2 · GAP (substantive: the planted Apple lock's re-key)
**Element.** Castle: the one key file locks the current key with the passphrase and the words (synced: the master,
beside its words copy) — a follower's with the secret it typed, the master and its words copy — never an Apple lock; a
planted Apple lock on a Castle key is answered with a re-key.
**Model proof — what is asserted.**
- The locks: `KeyFileWrapTests.everyWrapOpensWithTheRightSecretAndRefusesAWrongOne` (P with its descriptor, W, M, the
  master through the words copy; each refuses a wrong secret); `KeyFileWrapTests.aWrapOfAnotherKeyIsRefused` (a planted
  wrap of another key opens nothing); `UseCastleTests.syncedUseCastleRotatesTheAccountThenTheLibrary` (the new file's
  words copy is the vault's recovery wrap, `open(wordsThroughMaster:)`); `FollowTests.aStandardDeviceFollowsIntoCastleTypingOneSecret`
  (the follower's file: the typed words, no passphrase, the master, the words road).
- Never an Apple lock: `KeyFileCrossingTests.enteringCastleTakesEverything` (`apple == nil`; an Apple lock offered at
  entry refuses `appleWrapOnACastleKey`); `UseCastleStates.finished` (`live.apple == nil`); promise 2 ("an Apple wrap of
  the current key").
- The planted lock is SEEN: `AssessRepairTests.anAppleWrapOnACastleKeyIsAFaultTheReKeyAnswers` (fault
  `appleWrapOnCastleKey`, act `rekeyForFault` owed).
**The gap.** `rekeyForFault` is owed by `assess` (`Assess/Assess.swift:575–576`) and referenced nowhere in `Executor/`
(grep on the code tree), so no road runs the re-key, and no scenario reaches the state: the world's `plantAppleWrap`
needs a silent item holding the key (`Scenario/Alphabet.swift` `tamperWith`), so in Castle it is refused. **Needed:** an
executor road for the owed re-key, and a fixed scenario — a Castle library, local and synced, whose live key file is
given an Apple wrap of its CURRENT key (a fixture: a holder who had the key, since the world's adversary can't read a
Castle key) → relaunch and settle → the library under a fresh Castle key, the planted key in the history, no Apple wrap
on the live key file, promises 2 and 8 holding against the planted key's Apple road; its pin run with the re-key's
guard off must fail.
**Code half.** The posture drill (phase 3).

### C-3 · GAP (narrow: the kept anchor's Diagnostics line)
**Element.** Castle: the history holds every older key, each locked with today's key — entering Castle took
everything, an anchor folded back in (one the typed secrets can't open kept beside it, unchanged, listed in
Diagnostics, never failing the entry); an old key opens nothing newer.
**Model proof — what is asserted.**
- `KeyHistoryTests.theHistorySurvivesThreeReKeys` (every older key reachable from the newest, verified; an old key opens
  none of the newer file's entries); `KeyFileCrossingTests.enteringCastleTakesEverything`;
  `KeyFileCrossingTests.castleToStandardToCastleFoldsTheAnchorBack`; `KeyFileCrossingTests.anUnopenableAnchorIsKeptAndDoesNotFailTheEntry`
  (kept beside, unchanged; a later leave seals it inside the new anchor, where it opens with ITS day's secrets).
- `CopyAndCrossingScenarios.castleStandardCastle` (the anchor folded back; promise 5 walks every older copy); promise 8.
**The gap.** "Listed in Diagnostics" (and the outcome's notice) is unasserted: the code reports it
(`Executor/Acts/CommonSteps.swift:113–115`, `.anchorKeptUnopened`), no test reads it. **Needed:** an executor test — a
library that left Castle, both secrets changed by the key doors since, then Use Castle with the new secrets → the entry
completes, the anchor sits in `keptAnchors` byte-identical, `diagnostics` holds `.anchorKeptUnopened(madeAt: <leave
day>, …)` and the outcome's notices `.anchorKeptUnopened(day: <leave day>)`.
**CUT clause (LC).** "Every older key" for keys from before the switch: "the migration's fold beyond the current key"
drops; the history holds the migration's current key and every key since.
**Code half.** None beyond the face of the Diagnostics line (phase 5).

### C-4 · PROVEN
**Element.** Castle: every Apple key of this Mac's own for the library (every id its facts list, not only the live
file's) was retired at entering Castle with no sheet; the account's deleted and recorded retired once its rotation
completed; no retired key exists, one that reappears deleted on sight by recorded id only, never another Mac's.
**Model proof.**
- Every own key: `AssessDoorTests.useCastleRetiresEveryOwnKeyAndNamesWhatItCantDelete` (Re-link's, an adopted one, a
  former Apple ID's — never the account's); `SharedKeyActTests.theLibraryArmMintsAFreshOwnKeyAndThenUseCastleRetiresBoth`;
  `DeviceScenarios.aReplacementMacsFirstOpen` (the predecessor's own key taken over and retired at Use Castle, memory
  carried or not); `GeneratorFoundScenarios.aReplacementFinishesUseCastlesRetirement`.
- The writes: `UseCastleTests.useCastleLocalWritesExactlyThisInOrder` (`apple- <own>` after the backup, recorded in both
  homes); `UseCastleTests.syncedUseCastleRotatesTheAccountThenTheLibrary` (the account key's `apple-` after `vault castle`;
  `retiredAppleKeyIDs == [own, accountKey]`); `FollowTests.aStandardDeviceFollowsIntoCastleTypingOneSecret` (a follower
  retires its own and records the account's).
- Delete on sight by recorded id: `AssessRepairTests.deleteOnSightIsByRecordedIDOnly`; `ExecutorRepairTests.deleteOnSightIsByRecordedIDOnly`;
  `ExecutorEdgeTests.aLibraryFileSwappedForAnOlderOneLosesToTheNewerMemoryWithTheRoadsKeys` (a retired id survives a
  replayed file); `DeviceFactsTests.aReplayOfEitherHomeAloneChangesNothing` (a replay never un-retires).
- Never another Mac's: `CornerScenarios.oneLocalLibraryOnTwoMacs`; `MoreScenarios.twoMacOSLoginsOnOneMac`;
  `CopyAndCrossingScenarios.thisMacOnlyCastleFromAStandardAccount`; `CopyAndCrossingScenarios.aStandardLibraryLeavesItsAccountThenEntersCastle`.
- Promise 2 (the retired-key clause at every settle; nothing Apple-reachable opens a pre-Castle copy made here).
- Pins: `ScenarioMutationPins.reLinksLibraryArmThenUseCastle`, `ExecutorGuardMutationTests.onlyTheLiveFilesOwnKeyIsRetiredAtCastleWithTheGuardOff`,
  `AssessGuardMutationTests.everyOwnKeyRetiredAtCastle` (every own Apple key retired); `ScenarioMutationPins.deleteOnSightByRecordedIDOnly`,
  `ExecutorGuardMutationTests.anotherMacsAppleKeyIsDeletedOnSightWithTheGuardOff`, `AssessGuardMutationTests.deleteOnSightByIDOnly`.
**Code half.** The iCloud Keychain drill (deletes of synchronizable items) — phase 3.

### C-5 · PROVEN
**Element.** Castle: every backup carries its day's key file; older backups open through the history with Touch ID,
the passphrase or the words.
**Model proof.**
- The executor's fresh pair is the live key file (`backup K1` in every act's exact writes; `UseCastleTests.useCastleLocalWritesExactlyThisInOrder`:
  `backups.map(\.fingerprint) == [K1]`); a pair's frozen key file IS the live one (`SmallCopyActTests.sendLibraryWritesThePairWithNoSharingNote`:
  `keyFile == liveFormat3`).
- Promise 5 (every copy made opens by her roads — Touch ID items through the press, every day's passphrase and words);
  `CopyAndCrossingScenarios.w1VX263` (new-system pairs across Use Castle and Replace All Keys);
  `CopyAndCrossingScenarios.castleStandardCastle`; `RouteFinderRoadTests.everyRoadCombinationIsNamedAndWalks` (the history
  road walked; `.touchID` named for a gated key).
**CUT clause (LC).** Backups from before the switch: "pre-rebuild copies opening on the new system" drops.
**Code half.** The real backup service writing frozen pairs into `Backups/<library8>/<mac8>/` (the world's
`backupService` stands in) — phase 5; the restore drill — phases 2 and 5.

### C-6 · GAP (narrow: Always ask holds the sync keys in session memory only)
**Element.** Castle, synced: the sync keys live only in a Touch ID item (session memory under Always ask).
**Model proof — what is asserted.**
- Never silent: promise 2 ("a silent sync-keys item holds the account's Castle-era keys");
  `AssessVaultTests.syncKeysAreHeldByWhatTheyReach`; `AssessRepairTests.aSilentSyncKeysItemWhileTheyReachACastleEraKeyIsReported`
  (P-U2-2).
- The Touch ID item: `UseCastleTests.syncedUseCastleRotatesTheAccountThenTheLibrary`, `AccountJoinTests.setUpSyncInCastleGivesTheVaultNoAppleCopy`,
  `ReplaceAllKeysTests.castleReplaceAllKeysRotatesTheAccountAndGrowsTheHistory` (`sync+ touchid`).
- Session memory under Always ask: `CornerScenarios.aWipedKeychainStillFollowsAKeyReplacement` (the account's keys held
  in session memory, following a replacement); `ScenarioMutationPins.castleKindCustodyThroughALeavesWindow` (Always ask:
  no silent item in a leave's window).
**The gap.** No test asserts that an Always-ask Castle device holds NO sync-keys item of either class (the code drops the
Touch ID item there: `Executor/Acts/CommonSteps.swift:344–346`). **Needed:** a synced Use Castle and a follow into Castle
on an Always-ask device → `syncItems` empty for the account and `session[account]` the account's keys.
**Code half.** The drill (phase 3).

### C-7 · PROVEN (over the modelled vault)
**Element.** Castle, synced: the vault holds the master locked with the passphrase and words, the sync key locked with
the master — no Apple copy.
**Model proof.** The vault is MODELLED from the real `KeyVaultFormat` (`Executor/VaultModel.swift`; zero `Sync/` lines):
`AccountJoinTests.setUpSyncInCastleGivesTheVaultNoAppleCopy` (mode Castle, no `apple_key_id`, no Apple key added);
`UseCastleTests.syncedUseCastleRotatesTheAccountThenTheLibrary` (the rotation ends Castle, no previous key);
`ReplaceAllKeysTests.castleReplaceAllKeysRotatesTheAccountAndGrowsTheHistory`; `CornerScenarios.anActingDeviceLostMidReplaceAllKeys`
(no Apple copy, finished by anyone); `ExecutorKeyDoorTests.newWordsSyncedReplaceTheVaultsRecoveryWrapAndTheKeyFilesCopy`;
`vaultInvariant` (with promise 2) after every step.
**Code half.** The design names only code-half proof here: the vault through `Sync/` (the `VaultLeaf` over
`KeyVaultClient` and `CorpusRotation`), the fake-server suite and a live round — phase 3 (Fable).

### C-8 · PROVEN
**Element.** Key files with a master lock carry the master locked with the twelve words, copied from the vault and
refreshed while that master is current.
**Model proof.**
- `KeyFileWrapTests.everyWrapOpensWithTheRightSecretAndRefusesAWrongOne` (the `masterThroughWords` road; a file with no
  words lock still opens with the words through the copy); `CastleAnchorTests.noValueEverHoldsAMasterUnderThePassphrase`
  (the copy is the master under the words, never under the passphrase).
- Copied from the vault: `AccountJoinTests.setUpSyncInStandardMintsTheAccountKeyAndKeepsTheLibraryKey`,
  `UseCastleTests.syncedUseCastleRotatesTheAccountThenTheLibrary` (`masterWordsCopy == vault.masterWrappedByRecovery`);
  a follower's: `FollowTests.aStandardDeviceFollowsIntoCastleTypingOneSecret`.
- Refreshed while current: `ExecutorKeyDoorTests.newWordsSyncedReplaceTheVaultsRecoveryWrapAndTheKeyFilesCopy`;
  `GeneratorFoundScenarios.newWordsResumedPastAnotherDevicesLeaveKeepsTheWordsCopyHonest` (never refreshed from a master
  that isn't the file's).
- The fixed scenario the element names: `MoreScenarios.aSilentlyJoinedDeviceLosingItsKeychain` (the device opens after
  its keychain is wiped; which road opened it is not asserted — its own Apple key returns from iCloud in the world — so
  the words road itself rests on the unit test above); the residue: `GeneratorFoundScenarios.aSilentlyJoinedDeviceBehindANewMasterIsTheStatedResidue`.
**Code half.** None (no server change, design §3.5a).

### C-9 · GAP (narrow: the follow's one notice)
**Element.** Entering Castle turns this device's scheduled Markdown export off, with one notice — on Use Castle and on
every follow into Castle.
**Model proof — what is asserted.**
- Use Castle: `UseCastleTests.useCastleLocalWritesExactlyThisInOrder` (`notices == [.scheduledExportTurnedOff]`, the
  export off in the section); the door: `AssessDoorTests.useCastleRetiresEveryOwnKeyAndNamesWhatItCantDelete`
  (`.scheduledExportTurnsOff`).
- Off on the follower too: `ScenarioMutationPins.enteringCastleWithTheScheduledExportOn` (macA by Use Castle, macB by its
  follow at the settle; red with `exportOffAtCastle` off); `ExecutorGuardMutationTests.theScheduledExportStaysOnWithTheGuardOff`.
**The gap.** The follow's ONE notice is unasserted (the code: `Executor/Acts/Follow.swift:52, 120` →
`CommonSteps.swift:271–277`). **Needed:** a follow into Castle on a device with the export on → `outcome.notices ==
[.scheduledExportTurnedOff]` and the export off in both homes.
**Code half.** The notice's face (phase 3/5).

### C-10 · PROVEN (CUT clause: the older-build exception)
**Element.** After leaving Castle nothing the Apple account or a login-password holder reaches opens a copy from before
the leave or a key made in Castle — through the rotation too (the sync keys the Castle way on every device until the
previous key leaves; the Apple wrap only in the one completing write, by a device that reads the named key); the
library itself opens to them from the leave on, and the leave screen says so.
**Model proof.**
- Promise 13 (`castleStaysCastles`) every step; `vaultInvariant`; `RouteFinderRoadTests.afterALeaveCastleCopiesOpenWithTheDaysSecretsAndNothingAppleReachable`.
- The rotation: `UseStandardTests.syncedUseStandardMarksTheLeaveThenCompletesIt` (`vault rotating apple-id-no-wrap`,
  `sync+ touchid`, then ONE `vault apple-wrap`, `sync+ silent`, `sync- touchid`); `AssessVaultTests.aDeviceThatReadsTheNamedKeyMayCompleteTheLeave`;
  `AssessVaultTests.aFollowerThatSeesALeaveInProgressHoldsItsReKey`; `FollowTests.aFollowerMeetingALeaveInProgressHoldsItsReKeyWithItsKeysTheCastleWay`.
- Fixed scenarios: `CopyAndCrossingScenarios.leavingCastleLocalAndSynced` (synced, three devices, followers typing the
  passphrase and the words, a crash at six write counts on Touch ID and Always ask); `CornerScenarios.aFollowerReachingTheHeadFirst`;
  `CornerScenarios.aFollowIntoStandardWithICloudKeychainOff`; `CornerScenarios.aFollowerMeetingARotationInProgress`.
- Opens to them from the leave on: promise 3 at every settle. The sentence: `UseStandardTests.useStandardLocalWritesExactlyThisInOrder`
  (`done == [.ruleFive]`), `AssessDoorTests.useStandardTypesTheWordsNeverMakesNewOnesAndSaysRuleFive`.
- Pins: `ScenarioMutationPins.castleKindCustodyThroughALeavesWindow`, `ExecutorGuardMutationTests.theSyncKeysGoSilentInALeavesWindowWithTheGuardOff`,
  `AssessGuardMutationTests.castleKindCustodyThroughLeave` (Castle-kind custody on every device);
  `ScenarioMutationPins.theLeavesIDGatesItsCompletion`, `ExecutorGuardMutationTests.aFollowerClearsAPreviousKeyWhileTheLeavesIDStandsWithTheGuardOff`,
  `AssessGuardMutationTests.leaveIDGatesCompletion` (the leave's id gating its completion).
**CUT clause (LCW).** "The one exception: a leave or follow made by an older build" — "old builds as LIVE, CONCURRENT
ACTORS after the switch" drop. Kept while green, beyond scope: `MoreScenarios.anOlderBuildCompletingALeavesRotation`,
the older-build half of `CornerScenarios.followersAnchorsOpenWithWhatOpenedThem`; promise 13's `olderBuildLeaveKeys`
exemption stays as built.
**Code half.** The `Sync/` half of the rotation (the leave's mark, the completing write) — phase 3 (Fable); the drill —
phase 3; the leave screen's face — phases 3/4.

### C-11 · PROVEN
**Element.** Castle: copies under an Apple key in an Apple account this Mac has left are rule 2's last stated
exception — they open through that former account while its iCloud Keychain keeps the key; Use Castle's door names them;
their *Opens with* line says so; they can be deleted.
**Model proof.**
- `CornerScenarios.aMacThatSwitchedAppleID` (the door's words carry `.copiesUnderAKeyThisMacCantDelete` naming them;
  their *Opens with* routes carry `.appleKeyNotReadableHere`; then Use Castle, every promise kept);
  `AssessDoorTests.useCastleRetiresEveryOwnKeyAndNamesWhatItCantDelete` (the copy named by id);
  `RouteFinderRoadTests.everyRoadCombinationIsNamedAndWalks` (`.appleKeyNotReadableHere` on the line).
- Open through the former account: `GeneratorFoundScenarios.aFormerAppleAccountStillOpensItsCopies` (promise 5 counts
  every Apple account of hers). Promise 9 deliberately skips `.appleKeyNotReadableHere` (a road elsewhere, by its own
  words — `honestWords`).
**Code half.** "They can be deleted": the delete door on this library's own copies (Data Safety, VX-265) — phase 5; the
walk — phase 5.

### H-1 · PROVEN
**Element.** A fresh key at every crossing — entering and leaving Castle, leaving an account in either mode, a
different library landing — plus Replace All Keys and the follow; every key born Castle or Standard keeps that kind
for life, and no repair changes it.
**Model proof.**
- Kind for life: `FamilyTreeTests.everyMintedKeyIsRecordedWithItsKindAndItsMac` (born with its kind and Mac; the mode is
  the current key's kind); `ProtectionNamesTests.theCustodyClassFollowsTheKeysKindForLife`; `UseCastleStates.finished`
  (the new key's tree entry `.castle`); `AssessRepairTests.noRepairMakesATouchIDItemOrChangesAKeysKind` (every repair the
  shapes owe is a delete, a wrap under an existing key, a refresh or a quiet record — none re-kinds a key);
  `FamilyTreeTests.mergingTakesTheSafeSide` (two homes disagreeing on a kind take Castle — PROVISIONAL P-U1-3).
- A fresh key: `UseCastleStates.finished`, `UseStandardStates.finished` (current ≠ K0); `LeaveAccountTests.aCastleLeaveReKeysWithBothSecretsAndNothingAfterOpensThroughTheAccount`,
  `.moveLeavesOneAccountAndJoinsTheSignedInOne`, `AssessAccountTests.everyLeaveReKeysInBothModes`; `LandTests.aCastlePairLandsWithItsPassphraseAloneTheWordsMadeNew`
  (`library.key != sender.key`); `ReplaceAllKeysTests.castleReplaceAllKeysRotatesTheAccountAndGrowsTheHistory`;
  `FollowTests.aStandardDeviceFollowsIntoCastleTypingOneSecret`; `MigrationScenarios.corner45sAmbiguousCase` (confirming
  Standard is a key change).
- The fixed scenarios the element names: `CopyAndCrossingScenarios.leavingCastleLocalAndSynced`, `.aLibraryLeavingItsAccountByEachAct`
  (three acts × both modes: a new fingerprint, no account), `CornerScenarios.aLibraryLeavingByMoveThenTheAccountLeavesCastle`
  (the fourth act), `CopyAndCrossingScenarios.sendLibraryAfterThisChange` (all four landing typings: a fresh key).
- Pins (the re-key at every crossing): `ScenarioMutationPins.theRekeyAtEveryCrossing`, `ExecutorGuardMutationTests.aStandardLeaveKeepsItsKeyWithTheGuardOff`,
  `AssessGuardMutationTests.rekeyAtEveryCrossing` (the landing's fresh key too).
**Code half.** None beyond the acts' own phases (3, 4, 5).

### H-2 · PROVEN
**Element.** The history: entering Castle takes everything (an anchor folded in, or kept beside unchanged when the
typed secrets can't open it); within a mode it grows, the anchor carried unchanged; leaving Castle and a landing take
nothing — the new key's history starts empty.
**Model proof.** `KeyFileCrossingTests.enteringCastleTakesEverything`, `.castleToStandardToCastleFoldsTheAnchorBack`,
`.anUnopenableAnchorIsKeptAndDoesNotFailTheEntry`, `.withinAModeTheHistoryGrowsAndTheAnchorRides`,
`.leavingCastleTakesNothing_theAnchorOpensWithThePassphraseAndTheWords`, `.aLandingStartsEmpty`;
`KeyHistoryTests.theHistorySurvivesThreeReKeys`; at the act: `UseStandardTests.useStandardLocalWritesExactlyThisInOrder`
(`historyKeys(currentKey: K1).isEmpty`), `LandTests.aCastlePairLandsWithItsPassphraseAloneTheWordsMadeNew` (history empty,
no anchor), `LeaveAccountTests.aCastleLeaveReKeysWithBothSecretsAndNothingAfterOpensThroughTheAccount` (the leave's
history takes K0); the fixed scenarios the element names: `CopyAndCrossingScenarios.castleStandardCastle`,
`.sendLibraryAfterThisChange` (`history.isEmpty` on the receiver).
**Code half.** None.

### H-3 · PROVEN (CUT clause: an older build's leave)
**Element.** The anchor is written first at every leave, by the act and by each follow — the outgoing key with its
whole history (and any earlier anchor) under one anchor key locked only with what opened that device that day: the
acting device's typed P and W; a follower's typed secret plus the outgoing key with its own locks copied beside it; a
words-only device's anchor opening with the words alone; in the key file and every later pair.
**Model proof.**
- Written first: `KeyFileCrossingTests.leavingCastleTakesNothing_theAnchorOpensWithThePassphraseAndTheWords` (a leave
  without it refuses `anchorNotWrittenFirst`; carried byte for byte); `UseStandardTests.useStandardLocalWritesExactlyThisInOrder`
  and `.syncedUseStandardMarksTheLeaveThenCompletesIt` (`keyfile K0` — the anchor — is the first write after the act is
  named); the follow's step order begins `"anchor"` (`Executor/Acts/Follow.swift`) and
  `FollowTests.aFollowerMeetingALeaveInProgressHoldsItsReKeyWithItsKeysTheCastleWay` shows it written while the library
  re-key holds. Pins: `ProtectionGuardMutationTests.anchorWrittenFirst`; `ExecutorGuardMutationTests.swappingBeforeTheKeyFileStrandsTheLibraryWithTheGuardOff`
  (prepare-then-commit).
- The acting device's locks: `UseStandardStates.finished` (opens with the passphrase and with the words to K0) and
  `anchor.locks.outgoingKey == nil` (nothing Apple-reachable); crash after every write on Touch ID and on Always ask:
  `UseStandardTests.aCrashAfterEveryWriteFinishesOnResume`, `.aCrashAfterEveryWriteOnAlwaysAskFinishesOnResume`,
  `.withThePlanGoneItRollsBackBeforeTheSwapAndFinishesFromTheRecordAfter`, `.syncedUseStandardCrashAfterEveryWriteFinishes_AlwaysAsk`.
- A follower's locks: `CastleAnchorTests.aFollowersAnchorOpensWithTheTypedSecretAndWithWhatOpenedThatDevice` (the typed
  secret; the older passphrase it held; the words; the master copy alone); `FollowTests.aCastleDeviceFollowsIntoStandardAndItsAnchorOpensWithTheSecretTypedAtItsFollow`;
  `CastleAnchorTests.aWordsOnlyFollowersAnchorSaysTheWords`, `.noValueEverHoldsAMasterUnderThePassphrase`,
  `.aTamperedAnchorOpensNothing`; `RouteFinderRoadTests.aFollowersAnchorWithThePassphraseTyped`,
  `.aFollowersAnchorWithTheWordsTypedAndAStaleCopiedPassphrase`, `.aWordsOnlyFollowersCopiesSayTheWordsNotThePassphrase`.
- An earlier anchor kept beside: `KeyFileCrossingTests.anUnopenableAnchorIsKeptAndDoesNotFailTheEntry` (sealed inside the
  next anchor); in every later pair: a pair's key file is the live one (`SmallCopyActTests.sendLibraryWritesThePairWithNoSharingNote`),
  the anchor survives encoding (`KeyFileWrapTests.aFormat3FileRoundTrips`).
- The fixed scenarios the element names: `CopyAndCrossingScenarios.leavingCastleLocalAndSynced`;
  `CornerScenarios.followersAnchorsOpenWithWhatOpenedThem` (an Always-ask follower relocked after the rotation, and a
  words-typed one); `CornerScenarios.aWordsOnlyFollowerLeavingCastle`; the passphrase changed during Castle on another
  device: `ScenarioMutationPins.aFollowersAnchorOpensWithTheSecretTypedAtItsFollow` (pin: a follower's anchor under the
  secret typed at its follow) and `ExecutorGuardMutationTests.aFollowersAnchorMissesTheSecretTypedAtItsFollowWithTheGuardOff`.
**CUT clause (LCW).** "The master's road left out when the vault's master is still the Castle-era one (an older build's
leave)" and "a follow after an older build's leave": old builds as live actors drop. The model's switch stays pinned
(`CastleAnchorTests.withTheMasterUnchangedSinceCastleTheMastersRoadIsLeftOut`); the older-build half of
`CornerScenarios.followersAnchorsOpenWithWhatOpenedThem` is kept while green.
**Code half.** None.

### H-4 · GAP (narrow: four doors' sentences, and the enroll's anchor at the act)
**Element.** The anchor keeps the secrets of its day: never re-locked; the key doors re-lock only the current key;
every later re-key carries it unchanged, an enroll under a differing passphrase leaves it untouched; pre-leave copies
open with the leave day's secrets, the route finder naming the day; while an anchor exists, every door that replaces a
secret says its one sentence (the words doors, change passphrase, Standard's reset road, a Use Castle that can't fold).
**Model proof — what is asserted.**
- Never re-locked, carried unchanged: `CastleAnchorTests.noDoorReLocksItAndEveryReKeyCarriesItUnchanged`
  (`settingPassphrase`, `settingWords`, a re-key: byte-identical; opens with the day's secrets, not the new ones);
  `KeyFileCrossingTests.withinAModeTheHistoryGrowsAndTheAnchorRides`; `ExecutorKeyDoorTests.changePassphraseReWrapsTheCurrentKeyAndTheAnchorKeepsItsDay`.
  Pins (the anchor carried by every re-key): `ProtectionGuardMutationTests.anchorCarriedByEveryRekey`,
  `ScenarioMutationPins.theAnchorCarriedByEveryRekey` (a leave from an account after Use Standard).
- The day named: `RouteFinderRoadTests.aPassphraseChangedAfterTheLeaveIsNamedByTheLeavesDay`; `AnchorSentenceTests.afterASecondPassphraseChangeTheSentenceNamesTheDay`;
  promises 5 and 9 over `CopyAndCrossingScenarios.afterALeaveTheKeyDoors` (change passphrase here, new words on another
  device, a reset — copies from before the leave open with the leave day's secrets everywhere).
- The sentences: `AnchorSentenceTests.everyDoorThatReplacesASecretSaysItsSentence` (the words doors, change passphrase,
  the reset road naming that day's words only, Use Castle that can't fold), `.noAnchorNoSentence`;
  `AssessDoorTests.theKeyDoorsSayTheirAnchorSentenceWhileAnAnchorExists` (New Words', Change Passphrase's and the reset
  door's specs); in the Done: `ExecutorKeyDoorTests.changePassphraseReWrapsTheCurrentKeyAndTheAnchorKeepsItsDay`,
  `.theResetRoadNeverPointsAtTheForgottenPassphrase`, `CopyAndCrossingScenarios.afterALeaveTheKeyDoors` (the reset).
- The joining case the design names: `CornerScenarios.aCastleLibraryJoiningAStandardAccount` (the anchor written at the
  join opens with the secrets typed there).
**The gap.** (a) The sentence on four doors is coded but unasserted: New Words' Done (`Executor/Acts/KeyDoors.swift:75`),
Replace All Keys' Done (`ReplaceAllKeys.swift:57`) and its door spec (`Assess/Assess.swift:795`), a leave from an
account's Done (`AccountActs.swift:99`, said on every leave) and the leave doors' specs (`Assess.swift:855`), sync
setup's Done when it makes new words (`AccountActs.swift:135`). (b) "An enroll under a differing account passphrase leaves it
untouched" is asserted only through the primitive the enroll uses (`AccountActs.swift:188`, `settingPassphrase` —
pinned anchor-identical above), never at the act. **Needed:** after a leave (an anchor exists): `regenerateWords`,
`replaceAllKeys`, `leaveAccount` (each of the three) and `setUpSync` making new words → each
`outcome.done` holds `.anchor(s)` with `s.door == .replacesWords` and the leave's day; `assess`'s `.replaceAllKeys`,
`.thisMacOnly`, `.stopSyncingHere` and `.deleteAccountHere` specs carry it; and an enroll of a Standard library carrying
an anchor into a Standard account whose passphrase differs → the live key file's anchor byte-identical.
**Code half.** The walk (the sentences' faces) — phases 4 and 5.

### H-5 · PROVEN
**Element.** The family tree lists every key the library has had — kind, Mac, dates, no secret — in two homes unioned
at open, seeded at the migration with every fingerprint the catalog's key files name, reached or not; it decides
whether a copy is this library's own.
**Model proof.** `FamilyTreeTests.everyMintedKeyIsRecordedWithItsKindAndItsMac`, `.theTwoHomesUnion_aRolledBackLibraryStillKnowsItsLaterKeys`
(union laws), `.itCanBeSeededWithUnreachedFingerprints`, `.mergingTakesTheSafeSide`; the migration's seed:
`ProtectionMigrationTests.aStandardLibraryMigratesFoldsItsOlderKeyAndMovesBesideTheOldSharedKey`
(`familyTree.contains(older)` from `catalogFingerprints`); no secret: `ProtectionScanTests.noSecretAppearsInAnyValueWrittenToDisk`
(the record and the memory scanned); deciding "ours": `OpenRuleTests.thisLibrarysOwnCastleEraCopyAfterALeaveReadsAsOurs`,
`.everyCopyKindAgainstEveryLibraryState`. The fixed scenarios and pins the element names:
`ScenarioMutationPins.ownCastleEraCopyRestoredAfterALeave` (own-line check, on a new-system pair as LC re-points it) and
`AssessGuardMutationTests.ownLineByFamilyTree`; `ScenarioMutationPins.aTimeMachineRollbackPastARekey` (its two homes) and
`ProtectionGuardMutationTests.familyTreeTwoHomes`.
**Note (not a ruling of mine).** The migration's seeding exists for copies made before the switch to read as their own;
LC drops those copies' opening ("pre-rebuild copies opening on the new system"). The seed is built and pinned as above;
whether phase 2 keeps it is phase 2's to record under LC.
**Code half.** The record's table and the memory item going live — phase 2.

### S-1 · PROVEN
**Element.** Standard: a Standard key's device copy is its silent item; never a Touch ID item.
**Model proof.** Promise 3 as built checks the Standard library's Apple road, not its custody; the silent item is pinned
by: `ProtectionNamesTests.theCustodyClassFollowsTheKeysKindForLife` (`.standard → .silent`); `UseStandardStates.finished`
(`custody == [.silent]`) and `UseStandardTests.useStandardLocalWritesExactlyThisInOrder` (`custody+ silent K1`,
`custody- touchid K0`); `ExecutorDeviceActTests.aNewLibraryIsBornStandardWithThisMacsOwnAppleKey`;
`LandTests.aStandardPairThroughAReadableAppleKeyLandsWithNothingTyped`; `ProtectionMigrationTests.aStandardLibraryMigratesFoldsItsOlderKeyAndMovesBesideTheOldSharedKey`.
Never a Touch ID item: no executor road makes one for a Standard key (the custody step takes the key's own kind,
`newCustodyItem(kind:)`); one found is reported and never deleted by a repair —
`AssessRepairTests.inStandardNothingDestructiveRunsOnTheRecordsWordAlone`, `ExecutorRepairTests.noRepairEverMakesATouchIDItemAndNothingDestructiveRunsOnAStandardRecordsWord`,
pins `AssessGuardMutationTests.standardRecordNoDestructiveRepair`, `ExecutorGuardMutationTests.aTouchIDItemIsDeletedOnAStandardRecordsWordWithTheGuardOff`
(PROVISIONAL P-U2-1 (a)).
**Note.** P-U2-1's "it goes at the next act a person presses" is not asserted; by reading, the next re-key's custody step
deletes only the outgoing key's items (`Executor/Acts/CommonSteps.swift:220–230`), so a stray item of another key would
stay. For the closeout's QUESTIONS entry, not this row.
**Code half.** The drill (the silent item's accessibility class) — phases 2 and 3.

### S-2 · GAP (narrow: a follower's new Standard key file, lock by lock)
**Element.** Standard: each device's key file locks its current key with its own Apple key for the library (by id),
synced with the master beside its words copy, with the passphrase and words where it has them — a follower's carries
the secret it typed.
**Model proof — what is asserted.**
- The own Apple wrap, named by id: promise 3 at every settle (the wrap under this Mac's OWN readable key);
  `KeyFileWrapTests.everyWrapOpensWithTheRightSecretAndRefusesAWrongOne` (`appleKeyMismatch` on another id);
  `UseStandardStates.finished` (the wrap's key listed own and live in iCloud).
- The master and its copy: `AccountJoinTests.setUpSyncInStandardMintsTheAccountKeyAndKeepsTheLibraryKey`. The passphrase
  where it has one: `LeaveAccountTests.aStandardLeaveWithAForgottenPassphraseSetNewMintsNothing`.
- The fixed scenario the element names: `CopyAndCrossingScenarios.leavingCastleLocalAndSynced` (each follower Standard,
  promise 3 at the settle).
**The gap.** A follow INTO Standard's new key file is not asserted lock by lock (the code: `Executor/Acts/Follow.swift`,
the `keyFile` step — the typed secret's lock, the master, this Mac's fresh own Apple key). **Needed:** after
`FollowTests`'s follow into Standard typing the passphrase (and again typing the words): the live file opens with the
typed secret and not the other, opens through the new master and through `wordsThroughMaster`, carries `masterWordsCopy
== vault.masterWrappedByRecovery`, and its Apple wrap is under a key the follower minted (own, live).
**Code half.** The drill — phase 3.

### S-3 · PROVEN
**Element.** Apple keys: one per library per Mac (minted and named by that Mac) and one per account (the vault's master
only); minted only by a deliberate act or the migration, under fresh ids; two minters for one account → the vault's CAS
keeps one and the other deletes its own; a device that can't read the account's key waits for silent setup only.
**Model proof.**
- One per library per Mac: `LandTests.aStandardPairThroughAReadableAppleKeyLandsWithNothingTyped` (this Mac's OWN key, not
  the sender's); `CornerScenarios.oneLocalLibraryOnTwoMacs`; `MoreScenarios.twoMacOSLoginsOnOneMac`;
  `AccountScenarios.replaceAllKeysOnAnAccountStillOnTheOldSharedKey` (a new device joining: its key file under its own key).
- One per account, the master only: `AssessRepairTests.theLibraryWrapNeverLandsUnderTheAccountsKey`;
  `UseStandardTests.syncedUseStandardMarksTheLeaveThenCompletesIt` (`vault.mode == .standard(appleKeyID: <the account key>)`).
- Minted only by acts: `AssessRepairTests.inStandardTheWrapLandsUnderThisMacsOwnKeyAndNoRepairMintsOne`;
  `ReplaceAllKeysTests.standardReplaceAllKeysKeepsTheAccountKeyAndThisMacsOwn` and `LeaveAccountTests.aStandardLeaveWithAForgottenPassphraseSetNewMintsNothing`
  (no `appleAdd`); the minting acts' writes: `ExecutorDeviceActTests.aNewLibraryIsBornStandardWithThisMacsOwnAppleKey`,
  `UseStandardTests.useStandardLocalWritesExactlyThisInOrder` (`apple+ <fresh own>`), `.syncedUseStandardMarksTheLeaveThenCompletesIt`
  (`apple+ <fresh account>`); `GeneratorFoundScenarios.aSetUpWhoseAccountKeyWasLostMintsAfresh` (one minter, mint afresh).
- Two minters: `ExecutorEdgeTests.theDeviceWhoseLeaveLostTheRaceDeletesTheAccountKeyItMinted` (the loser's key deleted,
  recorded retired, not the vault's).
- Waiting for silent setup only: `AssessVaultTests.theAccountMovingElsewhereIsAFollow` (the account key unreadable here → the
  follow types one secret instead of waiting).
**Code half.** The convergence suite for the mint, wait and delete rules — phase 3 (design §3.5: "its convergence pins
live in phase 3").

### S-4 · PROVEN (CUT clause: an older build's Re-link)
**Element.** Standard, synced: the vault's Apple copy is under the account's Apple key, named by its id; an account
from before this change stays on the old shared key until it enters Castle or is re-linked; nothing moves a vault
automatically.
**Model proof.**
- Under the account's key, by id: `AccountJoinTests.setUpSyncInStandardMintsTheAccountKeyAndKeepsTheLibraryKey`,
  `UseStandardTests.syncedUseStandardMarksTheLeaveThenCompletesIt`, `ReplaceAllKeysTests.standardReplaceAllKeysKeepsTheAccountKeyAndThisMacsOwn`
  (decision 30), `SharedKeyActTests.reLinkMintsAFreshAccountKeyNeverTheOldSharedOne`.
- Moves only by a deliberate act: `ReplaceAllKeysTests.onAnAccountStillOnTheOldSharedKeyItReLinksFirst`,
  `AccountScenarios.replaceAllKeysOnAnAccountStillOnTheOldSharedKey`; never by a repair (no repair case writes the vault —
  the enumeration in `AssessRepairTests.noRepairMakesATouchIDItemOrChangesAKeysKind`); never by a settle: the first
  assertion of `CornerScenarios.anOlderBuildsRelinkAndTheLastStepRace` (today's account vault, on the old shared key, still
  there after two settles — current-store shaped, though the test as a whole is beyond scope under LCW).
**CUT clause (LCW).** The element's proof "an older build's Re-link": "an older build's Re-link re-landing a vault"
drops; that scenario and `ScenarioMutationPins.anOlderBuildsRelinkLandsTheVaultOnTheOldKey` are kept while green.
**Code half.** The fake-server suite (the real vault's `apple_key_id`) — phase 3 (Fable).

### S-5 · PROVEN
**Element.** Re-link mints a fresh account key under the vault's CAS, and Replace All Keys re-links an account still on
the old shared key first; nothing this build writes is locked with the old shared key.
**Model proof.** `SharedKeyActTests.reLinkMintsAFreshAccountKeyNeverTheOldSharedOne` (a fresh account key, never the old
one; re-keys nothing); `ReplaceAllKeysTests.onAnAccountStillOnTheOldSharedKeyItReLinksFirst` (nothing written under the
old key, nothing deleted); `AccountScenarios.replaceAllKeysOnAnAccountStillOnTheOldSharedKey` (and refused before any
write where the account's key can't be read); `AssessDoorTests.replaceAllKeysOnAnAccountStillOnTheOldSharedKeyReLinksFirst`;
`KeyHistoryTests.aReKeyDropsTheOldSharedWrap` (no re-key carries a wrap under it); `GeneratorFoundScenarios.aStaleDeviceNeverRelinksACastleAccount`.
**Code half.** The vault's CAS race for Re-link — phase 3's convergence suite; Re-link's door and the drill — phase 4.

### S-6 · PROVEN
**Element.** Standard: the history holds the older keys since the library came into Standard, each locked with today's
key; older copies open through it, and copies from before a leave through the anchor with the leave day's secrets.
**Model proof.** `KeyFileCrossingTests.withinAModeTheHistoryGrowsAndTheAnchorRides`, `.leavingCastleTakesNothing_theAnchorOpensWithThePassphraseAndTheWords`;
`KeyHistoryTests.theHistorySurvivesThreeReKeys`; `RouteFinderRoadTests.afterALeaveCastleCopiesOpenWithTheDaysSecretsAndNothingAppleReachable`,
`.aPassphraseChangedAfterTheLeaveIsNamedByTheLeavesDay`; `OpenCopyTests.aCastleEraCopyOpenedIntoAStandardLibraryTakesTheStandardModeAndNeverLowersAnything`
(opened through the anchor with the leave day's passphrase); promise 5 over `CopyAndCrossingScenarios.afterALeaveTheKeyDoors`.
**Code half.** The restore drill — phases 2 and 5.

### S-7 · GAP (narrow: "re-keying nothing") (CUT clause: other libraries' key files)
**Element.** Re-link's library arm: where a Standard library's own Apple key can't be read here, no repair mints one —
the assessment says the road is lost and offers the arm, which mints a fresh own key and re-locks every Standard key
file here that needs one (other libraries' and local-only included), re-keying nothing; then promise 3 settles.
**Model proof — what is asserted.**
- No repair mints; the road lost; the arm offered: `AssessRepairTests.inStandardTheWrapLandsUnderThisMacsOwnKeyAndNoRepairMintsOne`;
  `GeneratorFoundScenarios.aReplacedMacIsOfferedReLinkForALocalLibraryWithNoAppleWrap`.
- The arm: `SharedKeyActTests.theLibraryArmMintsAFreshOwnKeyAndThenUseCastleRetiresBoth` (a fresh own key, live in iCloud,
  on the live file).
- Then promise 3 settles (the world's settle presses the arm wherever it's offered): `MoreScenarios.aStandardLibrarysOwnAppleKeyLost`
  (local-only), `CornerScenarios.aSyncedStandardLibrarysOwnAppleKeyLost`, `MoreScenarios.aLivingMacClonedOntoNewHardware`.
**The gap.** "Re-keying nothing" is unasserted for the library arm (the code re-wraps the same key: `Executor/Acts/SharedKeyAndRelink.swift:58–66`;
the account Re-link's test does assert it). **Needed:** after `relinkLibraryArm`: `library.key`, the live key file's
fingerprint, epoch and history unchanged, and the record's tree unchanged.
**CUT clause (LC).** "Other libraries' ... included": other libraries' own key files are §3.5 point 2's gifts, which drop
("§3.5 point 2's gift machinery (per-library key files + own Apple keys for OTHER libraries' old copies)"); the arm's
other-library half is built (PROVISIONAL P-U3-5) and unpinned, and goes with the gifts at phase 2's first act.
**Code half.** Re-link's library-arm door and the drill — phase 4.

### R-1 · PROVEN
**Element.** The protection record inside the library file states the library's own facts — its mode (the current
key's kind) and whether confirmed, its account, its family tree — and every copy carries them; what this Mac remembers
agrees.
**Model proof.** Promise 1 (`known`) every step: one record per open library; the memory names the record's key and
epoch; the live key file is the current key's (round 1's clause). `ProtectionValueRoundTripTests.everyValueRoundTrips`
(the record, its sections, the memory, the plan, the tree; sealed forms); `FamilyTreeTests.everyMintedKeyIsRecordedWithItsKindAndItsMac`
(the mode is the current key's kind); `expectSettled` in every executor test (the record, the key file and the memory
name one key). Every copy carries them: `OpenCopyTests.aCopyIsReEncryptedUnderTheCurrentKeyAndTakesTheCurrentFacts`;
`SealedHomesAndPlansTests.aCopysActsInFlightAreClearedWhenItIsOpened` (a copy's record keeps the library's facts; its acts
cleared, unverifiable sections dropped).
**Note.** Promise 1's key-file clause exempts PROVISIONAL P-R1-1 (the copy-less case: no catalogued copy of the current
key's file — the honest refusal stands; a rebuild door is the recommended hand-forward, the author's call) —
`LadderRound1MajorPin.theCopyLessCaseIsP_R1_1sHonestRefusal`.
**Code half.** The `protection_record` table inside the SQLCipher file (the local-only family) and the memory item going
live — phase 2.

### R-2 · PROVEN
**Element.** This Mac's facts — identity and salted hardware marker, gate style, idle lock, scheduled export, its Apple
key ids and their retirements, the act in flight — live in two sealed homes; the newer wins, retired ids the union; a
Mac whose memory is gone finds its section by its hardware; in Castle a file, memory item or plan planted, edited,
replayed or deleted alone changes nothing (in Standard no repair deletes or re-keys on the record's word alone);
copies never carry them.
**Model proof.**
- The values and the seal: `ProtectionValueRoundTripTests.everyValueRoundTrips`; `ProtectionSealTests.theSealIsTheDesignsFormula`,
  `.aTamperedOrMisdirectedSealFails`, `.anOlderSealOpensThroughTheReach`; `SealedHomesAndPlansTests.aTamperedMemoryItemIsNotThisMacsMemory`,
  `.storingReplacesThatDevicesSectionOnly`.
- Two homes: `DeviceFactsTests.theNewerWinsAndTheRetiredIdsAreTheUnion`, `.aReplayOfEitherHomeAloneChangesNothing`,
  `.actsAreSequencedAndVersionsOnlyGrow`; found by the marker: `DeviceFactsTests.aMacWithNoMemoryItemFindsItsSectionByItsMarker`.
- Alone changes nothing (promise 10 after every tamper step and group): `MoreScenarios.replaysAndTheFileSwap` (eleven
  tampers on a Castle Always-ask library), `.aLibraryFileReplayedAloneInCastle`, `.theEditedGateStylePlusAnEnrolledFinger`,
  `.theMemoryItemDeletedAloneAndTheLidClosed` (the memory deleted alone on an Always-ask Castle Mac, a finger enrolled);
  `GeneratorFoundScenarios.aLibraryFileReplayedFromBeforeAJoinChangesNothing`, `.anotherIdentitysMemoryItemNeverRestoresTheRecordsFacts`;
  `LadderRound1NewFindsPins.aLoneOlderFileOfALibrarySetAsideByALandingLosesToItsMemory`;
  `LadderRound2AbsentArmPin.aLibraryFileReplayedWithItsKeyFileDeletedLosesToItsMemory`; `SettleSealTests.aMemoryItemThatFailsItsSealLosesToTheRecordsDeviceSection`;
  `ExecutorEdgeTests.aLibraryFileSwappedForAnOlderOneLosesToTheNewerMemoryWithTheRoadsKeys`. The stated limit (both
  homes together): `MoreScenarios.bothHomesRolledBackPastASwitchToAlwaysAsk`, `GeneratorFoundScenarios.bothHomesRolledBackOverAVX209VictimIsTheStatedLimit`.
- Standard's guard: `AssessRepairTests.inStandardNothingDestructiveRunsOnTheRecordsWordAlone`.
- Copies never carry them: `SealedHomesAndPlansTests.aCopysActsInFlightAreClearedWhenItIsOpened`; a section counts only on
  its own Mac (`DeviceFactsTests.aMemoryItemOnNewHardwareMintsANewIdentityThatTakesOver`, `.aSecondMacOSLoginStartsItsOwnIdentity`).
- Pins: `ScenarioMutationPins.aReplayedMemoryItemChangesNothing`, `ProtectionGuardMutationTests.twoHomes` (the two
  homes); `ScenarioMutationPins.theHardwareMarker`, `ProtectionGuardMutationTests.hardwareMarker` (the section's
  hardware marker); `ScenarioMutationPins.aLibraryFileReplayedAloneLosesToTheMemory`,
  `.aLibraryFileReplayedWithItsKeyFileDeletedLosesToTheMemory` (U4's `libraryFileLosesToMemory`);
  `AssessGuardMutationTests.standardRecordNoDestructiveRepair`.
**Code half.** The real memory item and section table — phase 2.

### R-3 · PROVEN
**Element.** Plans live beside the library, sealed and named by the act in flight in this Mac's section, never in a
backup; any copy's act in flight is cleared whenever it's opened, lock-time copies included; a plan the section doesn't
name is ignored and reported; a missing one never blocks.
**Model proof.**
- Sealed and named: `SealedHomesAndPlansTests.aPlanResumesOnlyWhenTheSectionNamesIt` (planted, replayed, another device's:
  refused); `SettleSealTests.aPlantedPlanIsIgnoredReportedAndTheActRollsBack`, `.aReplayedPlanFromAnEarlierActIsNotNamedAndChangesNothing`,
  `.aGenuinePlanOfAnotherActIsNotNamedTheActRollsBack`, `.aStrayPlanWithNoActInFlightIsDeletedAndReported` (each reported
  in Diagnostics), `.aPlanNeverHoldsASecret`.
- Never in a backup: the world's backup pair and Time Machine snapshot carry no plan (`Scenario/Alphabet.swift`
  `backupService`, `.timeMachineSnapshot`); promise 6 ("a plan is left on disk with nothing in flight").
- A copy's act cleared: `OpenCopyTests.aCopysActInFlightIsClearedWhenItsOpened` (a lock-time byte copy);
  `SealedHomesAndPlansTests.aCopysActsInFlightAreClearedWhenItIsOpened`; the fixed scenario the element names:
  `CopyAndCrossingScenarios.anActInFlightWhenABackupIsTaken`, `CornerScenarios.anActInFlightWhenABackupIsTakenForReal`.
- A missing one never blocks: `UseCastleTests.withThePlanGoneItRollsBackBeforeTheSwapAndFinishesFromTheRecordAfter`,
  `UseStandardTests.withThePlanGoneItRollsBackBeforeTheSwapAndFinishesFromTheRecordAfter`, `LeaveAccountTests.aLeaveWithThePlanGoneRollsBackOrFinishes`,
  `OpenCopyTests.aCrashAfterEveryWriteFinishesOrNeverHappened` (plan dropped); round 1's MAJOR fixed: `LadderRound1MajorPin.aPlanlessRollBackWithNoMirrorGetsTheCurrentKeysFileBack`,
  `.aPlantedPlanInsteadOfAReplayedOne`, `.anEarlierKeysFileReplayedWithTheMemoryGone`, `.theUseCastleVariant`.
- Promises 6 and 10; pins (planted, replayed): `ScenarioMutationPins.thePlantedPlan`, `ExecutorGuardMutationTests.aPlanTheSectionDoesntNameResumesWithTheGuardOff`;
  `ExecutorGuardMutationTests.aCopysActInFlightIsCarriedWithTheGuardOff`.
**Code half.** The plan file beside the library with `NSURLIsExcludedFromBackupKey` — phase 2; the Diagnostics and log
faces — phase 5.

### R-4 · PARTLY (the lobby's memory-mirror road is phase 2's, her ruling)
**Element.** Before unlock nothing decides: the lobby offers only self-verifying roads — the enumerated custody items
and the route finder's, the history and the anchor among them — and a missing key file or memory item isn't fatal.
**Model proof — what is proven.** `AssessModeTests.beforeUnlockNothingDecides` (lobby launch; the mode a hint only; no
repairs, acts or faults; every door refused `.locked`; the roads Touch ID and the typed secrets),
`.theLobbysAutomaticRoadsAreEveryItemThatAsksNothing` (every silent item whatever fingerprint it names; the Apple wrap
readable here); `TouchIDLobbyWithNoHintTests.aTouchIDItemWithNoHintShowsTheButton`, `.noItemNoButton`; the file swap:
`MoreScenarios.replaysAndTheFileSwap`, `ExecutorEdgeTests.aLibraryFileSwappedForAnOlderOneLosesToTheNewerMemoryWithTheRoadsKeys`;
the key file and memory both deleted: `DeviceScenarios.theKeyFileAndTheMemoryItemBothDeleted` (Touch ID and Always ask:
the lobby opens it through the newest pair's key file, the live file comes back, the next act runs whole). The world's
lobby walk (`SWorld.walkLobby`, `Scenario/World.swift`) opens only by keys that open the file.
**What is left.** (1) PROVISIONAL P-U4-13, RULED (b) by her: a secretless library restored by Time Machine past its Use
Castle opens by no road on this Mac until "phase 2's lobby builds the keychain-saved-copy road" (the memory's mirror of
the key file) — a named vx-306 deliverable; today `GeneratorFoundScenarios.aTimeMachineRestorePastUseCastleOfASecretlessLibrary`
pins the honest state as promise 5's exception, and the generator excludes the `deleteKeyFile` group shape until that road
lands (`ScenarioGenerator.rollsBackBothHomes`, "NARROW this exclusion when that road lands"). (2) PROVISIONAL P-R1-1: with
no catalogued copy of the current key's file, the library opens (not fatal) but the next act refuses `noLiveKeyFile`
(`LadderRound1MajorPin.theCopyLessCaseIsP_R1_1sHonestRefusal`); the recommended rebuild door is phases 2/4's, the author's
call.
**Code half.** The lobby itself and its tests — phase 2.

### R-5 · PROVEN
**Element.** The device identity and its hardware marker live in both homes; the marker is a salted hash of the
hardware identity (and the login's), never the identifier, recomputed on the same hardware after unlock, carried by no
log line, Diagnostics entry or support bundle; other hardware mints a new identity (no shared device cursor or backups
folder); the same hardware with its memory gone keeps its identity, found by its marker.
**Model proof.** `HardwareMarkerTests.itRecomputesOnTheSameHardwareAndLoginOnly` (two salted parts — her ruling 2, the
marker split), `.theMarkerCarriesNeitherIdentifier`; `ProtectionScanTests.noSecretAppearsInAnyValueWrittenToDisk` (no raw
identifier, no unsalted hash; the marker's parts only in this Mac's facts; the salt only in the record);
`ExecutorLogScanTests.nothingTheExecutorLogsCarriesASecretAMarkerOrTheSalt` (every log line and Diagnostics entry scanned,
both parts and the salt as needles); `DeviceFactsTests.aMemoryItemOnNewHardwareMintsANewIdentityThatTakesOver`,
`.aSecondMacOSLoginStartsItsOwnIdentity` (VX-340), `.aMacWithNoMemoryItemFindsItsSectionByItsMarker`,
`.theMemoryContinuesWhereItWasMade`; `ProtectionNamesTests.theFoldersAreNamedByLibraryAndMac`; the fixed scenarios:
`MoreScenarios.twoMacOSLoginsOnOneMac` (own device id and `<mac8>`), `.theMemoryItemDeletedAloneAndTheLidClosed`,
`DeviceScenarios.aReplacementMacsFirstOpen`; pins `ScenarioMutationPins.theHardwareMarker`, `ProtectionGuardMutationTests.hardwareMarker`.
**Code half.** The real identity leaves under the App Sandbox (`IOPlatformUUID`, the login's `GeneratedUID` — P-U1-1's
checks across a password reset, a keychain reset and an OS update) — phase 2; the support bundle's scan — phase 5.

### R-6 · PROVEN
**Element.** A replacement Mac (a new identity on new hardware) takes over its predecessor's Apple keys — its live key
file's own wrap ids, every own id the predecessor's section lists (the predecessor named by the memory item it came
with), every id any section lists retired — so entering Castle there retires them, and delete on sight keeps working.
**Model proof.** `DeviceFactsTests.aMemoryItemOnNewHardwareMintsANewIdentityThatTakesOver` (exactly those three sets; the
account's followed key not taken as its own; Always ask); `.newHardwareWithNoMemoryItemTakesOverWhatNeedsNoPredecessor`;
`.newHardwareUnderThisLoginNamesItsPredecessor` (PROVISIONAL P-U4-14, ratified (a)); the fixed scenario the element names:
`DeviceScenarios.aReplacementMacsFirstOpen` (memory carried or not: the predecessor's own key taken over, then retired by
Use Castle); `GeneratorFoundScenarios.aReplacementFinishesUseCastlesRetirement`, `.aReplacementWithNoMemoryNamesItsPredecessorByTheLogin`,
`.aReplacementMacKnowsTheOldSharedKeyWasRetired`, `.aReplacementKeepsTheOldSharedKeysStandingRecord` (P-U4-9, ratified
(a)); `TakingOverStandingOldSharedTests.theRecordWhoseIDWrapsThisLibraryWins`, `.noMatchTakesTheSmallestID`, `.aRetirementStillWins`.
**Code half.** The iCloud Keychain drill — phase 3; whether Migration Assistant carries `GeneratedUID` (P-U4-14's
mechanism) — phase 2's leaf check.

### T-1 · GAP (narrow: the door-time refusal leaves nothing written)
**Element.** Use Castle runs "Entering Castle" in order: the door-time check (a vault still on the old shared key stops
it before anything starts) and the door naming copies under an Apple key this Mac can't delete; prepare-then-commit,
the record in the staged copy before the swap, copies paused; the export off; every own Apple key retired with no
sheet; last, the old shared key retired by recorded id — and survives a crash at every step.
**Model proof — what is asserted.**
- The order: `UseCastleTests.useCastleLocalWritesExactlyThisInOrder` (the act named in both homes, the plan; custody, key
  file, stage, `staged-record`, THE SWAP, memory, the old item, export off, backup, own key retired, the old-shared step;
  `copyEvents == ["pause", "resume"]`), `.syncedUseCastleRotatesTheAccountThenTheLibrary`;
  `SharedKeyActTests.useCastleRetiresTheOldSharedKeyLastByItsRecordedID` (after the backup and the own key's retirement).
- The door: `AssessOldSharedKeyTests.aVaultOnTheOldKeyStopsUseCastleUnlessItIsTheActsOwn`; `AssessDoorTests.useCastleRetiresEveryOwnKeyAndNamesWhatItCantDelete`;
  `CornerScenarios.aMacThatSwitchedAppleID`; at the act: `ExecutorGuardMutationTests.useCastlesDoorOpensOnAVaultStillOnTheOldKeyWithTheGuardOff`
  (refuses `vaultOnOldSharedKey`).
- A crash at every step: `UseCastleTests.aCrashAfterEveryWriteFinishesOnResume_TouchID`, `_AlwaysAsk`,
  `.withThePlanGoneItRollsBackBeforeTheSwapAndFinishesFromTheRecordAfter`, `.syncedUseCastleCrashAfterEveryWriteFinishes_AlwaysAsk`;
  `CornerScenarios.vx235sCrashAfterTheMarker`; the refusals: `UseCastleTests.theRefusalsAreNamed` (nothing written by any
  of its four).
- Pins: the door-time vault check — `AssessGuardMutationTests.doorTimeVaultCheck`, the executor pin above (the scenario
  pin `ScenarioMutationPins.anOlderBuildsRelinkLandsTheVaultOnTheOldKey` is beyond scope under LCW, kept while green); the
  export-off step — `ScenarioMutationPins.enteringCastleWithTheScheduledExportOn`; every own Apple key retired —
  `ScenarioMutationPins.reLinksLibraryArmThenUseCastle`; prepare-then-commit — `ExecutorGuardMutationTests.swappingBeforeTheKeyFileStrandsTheLibraryWithTheGuardOff`.
**The gap.** "Before anything starts" is unasserted for the vault-on-old-key refusal (by reading it is thrown before
`perform`: `Executor/Acts/EnterCastle.swift:89–94`). **Needed:** add it to `UseCastleTests.theRefusalsAreNamed`'s
nothing-written check — `writes` empty, no plan, nothing in flight.
**Code half.** The posture drill — phase 3; the door's face — phase 3.

### T-2 · PROVEN (CUT clause: an older build completing the leave's rotation)
**Element.** Use Standard runs "Leaving Castle" in order: both secrets typed, the words never made new; the anchor
first; synced, the rotation's first write naming the account's fresh key with no wrap (past it a crash resumes, never
rolls back); the window's keys the Castle way; one completing write by a device that reads the named key; then silent
sync keys; a lost actor's leave finished at a press that names it, minting only if the key never arrives; a new
Standard key, empty history, silent item, fresh own Apple key; the leave screen's sentence.
**Model proof.**
- The order: `UseStandardTests.useStandardLocalWritesExactlyThisInOrder`, `.syncedUseStandardMarksTheLeaveThenCompletesIt`;
  the end state `UseStandardStates.finished`.
- The door: `UseStandardTests.theRefusalsAreNamed` (`wordsMustBeTyped` when made new, `wordsDoNotOpen`, another account;
  nothing written); `AssessDoorTests.useStandardTypesTheWordsNeverMakesNewOnesAndSaysRuleFive`.
- Past the commit point: `UseStandardTests.syncedUseStandardCrashAfterEveryWriteFinishes_AlwaysAsk`;
  `.pastTheVaultsFirstWriteWithThePlanGoneTheDeviceFinishesTheLeaveAsAnyFollower` (PROVISIONAL P-U3-2); her stuck-leave
  ruling: `GeneratorFoundScenarios.aSyncedLeaveCrashedPastItsFirstWriteWaitsForTheVault`, `.aWaitingLeaveIsFinishedByAnotherDeviceThenAtSignIn`,
  `.aSyncedLeaveCrashedBeforeItsFirstWriteRollsBackWhileSignedOut`, `.copiesStayPausedWhileAnActWaitsAcrossARelaunch`.
- A lost actor: `AssessDoorTests.aFinishDoorNamesTheLeaveALostDeviceStarted` (device, day, the named key);
  `FollowTests.finishingALeaveALostDeviceStartedMintsAFreshAccountKeyOnlyAtThePressThatStopsWaiting`;
  `CornerScenarios.aFollowerMeetingARotationInProgress`; `GeneratorFoundScenarios.anActorWhoseNamedKeyWasLostFinishesItsLeave`.
- The fixed scenario the element names: `CopyAndCrossingScenarios.leavingCastleLocalAndSynced` (a crash at six write
  counts, Touch ID and Always ask); crash harness: `UseStandardTests.aCrashAfterEveryWriteFinishesOnResume`,
  `.aCrashAfterEveryWriteOnAlwaysAskFinishesOnResume`, `.withThePlanGone…`.
- Pins: `ScenarioMutationPins.castleKindCustodyThroughALeavesWindow`, `.theLeavesIDGatesItsCompletion` (and their
  executor and assess twins, C-10).
**CUT clause (LCW).** "An older build completing the leave's rotation": "an un-updated device completing a rotation"
drops; `MoreScenarios.anOlderBuildCompletingALeavesRotation` is kept while green.
**Code half.** The rotation's `Sync/` lines — phase 3 (Fable); the walk (the leave screen and the finish door's face) —
phases 3/4.

### T-3 · PROVEN (CUT clause: a follow after an older build's leave)
**Element.** Replace All Keys runs as drawn (the old key into the history, any anchor carried; in Castle its rotation
names no Apple key, completed by anyone, never with an Apple copy); every follow into or out of Castle types one secret
once and never waits on an Apple key — into Standard writing its anchor first; a follower reads the vault's three
states and, while a rotation is in progress, holds its re-key with its keys the Castle way, never clearing the
previous key while an id stands with no wrap; the refusal names a change made elsewhere.
**Model proof.**
- Replace All Keys: `ReplaceAllKeysTests.castleReplaceAllKeysRotatesTheAccountAndGrowsTheHistory` (exact writes; the
  history holds K0), `.standardReplaceAllKeysKeepsTheAccountKeyAndThisMacsOwn`, `.onAnAccountStillOnTheOldSharedKeyItReLinksFirst`,
  `.aCrashAfterEveryWriteFinishes`, `.aLocalLibraryIsRefused`; the anchor carried by the within-mode re-key it runs
  (`KeyFileCrossingTests.withinAModeTheHistoryGrowsAndTheAnchorRides`, pin `ProtectionGuardMutationTests.anchorCarriedByEveryRekey`);
  no id, anyone completes it, no Apple copy: `AssessVaultTests.aRotationWithNoIdCompletesWithoutAnAppleCopy`,
  `CornerScenarios.anActingDeviceLostMidReplaceAllKeys` (the follower completes it; the account never lowered).
- One secret, no Apple wait: `FollowTests.aStandardDeviceFollowsIntoCastleTypingOneSecret` (the words alone),
  `.aCastleDeviceFollowsIntoStandardAndItsAnchorOpensWithTheSecretTypedAtItsFollow` (the passphrase alone; its anchor under
  the typed secret and the outgoing key with its copied locks, the master's road kept); `AssessVaultTests.aFollowerThatSeesALeaveInProgressHoldsItsReKey`
  (`followNow` requires `.oneSecret`), `.theAccountMovingElsewhereIsAFollow`; `CornerScenarios.aFollowIntoStandardWithICloudKeychainOff`;
  `FollowTests.aFollowIntoStandardCrashAfterEveryWriteFinishes_AlwaysAsk`; `ExactWritesTests.theFollowIntoCastle`;
  `CornerScenarios.vx107sDoubleCrash`.
- The three states and the hold: `AssessVaultTests.aWrapReadsStandardAnIdWithNoWrapALeaveNeitherCastle`;
  `FollowTests.aFollowerMeetingALeaveInProgressHoldsItsReKeyWithItsKeysTheCastleWay`; `CornerScenarios.aFollowerReachingTheHeadFirst`,
  `.aFollowerMeetingARotationInProgress`; pins `ScenarioMutationPins.castleKindCustodyThroughALeavesWindow`,
  `.theLeavesIDGatesItsCompletion`, `ExecutorGuardMutationTests.aFollowerClearsAPreviousKeyWhileTheLeavesIDStandsWithTheGuardOff`.
- A change named: `FollowTests.theOldPassphraseAfterAChangeElsewhereIsRefusedWithTheChangeNamed` (the device named;
  `day: nil` in that fixture, whose vault carries no stamp); `CornerScenarios.vx109sConcurrentUseStandard` (a stale door
  refused).
**CUT clause (LCW).** "A follow after an older build's leave" (the element's named scenario): old builds as live actors
drop; the older-build half of `CornerScenarios.followersAnchorsOpenWithWhatOpenedThem` is kept while green.
**Code half.** The rotation and follow `Sync/` lines (VX-107, VX-109, VX-113) — phase 3 (Fable); the drills and the walk —
phase 3.

### T-4 · PROVEN (CUT clause: backups from before the switch)
**Element.** Opening an older backup of this library — the family tree says it's ours — brings it in under today's key
and mode, never lowering it: through the history with nothing typed, or, from before a leave, with the leave day's
passphrase or words through the anchor, the confirm saying its writing then opens through the Apple account.
**Model proof.** `OpenRuleTests.thisLibrarysOwnCastleEraCopyAfterALeaveReadsAsOurs` (`castleEraIntoStandard: true` — the
confirm's fact), `.aCopyNeverLowersTheMode`; `OpenCopyTests.aCopyIsReEncryptedUnderTheCurrentKeyAndTakesTheCurrentFacts`
(the CURRENT key; her writing as it was; the library she had kept aside), `.aCastleEraCopyOpenedIntoAStandardLibraryTakesTheStandardModeAndNeverLowersAnything`
(through the anchor with the leave day's passphrase), `.aCrashAfterEveryWriteFinishesOrNeverHappened` (PROVISIONAL
P-U3-6, ratified (a)); promise 4 (`noSilentChange`: an opened copy never lowers the mode or brings its own key); the
fixed scenarios the element names: `CopyAndCrossingScenarios.vx209sWayBack` (local and synced, on new-system pairs),
`ScenarioMutationPins.ownCastleEraCopyRestoredAfterALeave`; pins `AssessGuardMutationTests.neverLowerOnOpen`, `.ownLineByFamilyTree`.
**CUT clause (LC).** A backup from before the switch: "pre-rebuild copies opening on the new system" drop (an old copy
meets an honest refusal naming its roads — phases 2/5).
**Code half.** The restore drill — phases 2 and 5; the confirm's words and the walk — phase 5.

### T-5 · PARTLY (the landing into an empty slot is phase 5's)
**Element.** A Castle copy not in the tree raises a Standard library through Use Castle's steps; an unknown-key copy is
flagged; a different library keeps its mode and lands under a fresh key, empty history, one secret then the other
typed or made new — a Standard pair through a readable Apple key with nothing typed, under this Mac's own key; a synced
pair lands held, a secret made new becoming the account's at Resume Sync; no key held by two Macs; Send Library says
nothing about sharing.
**Model proof — what is proven.**
- The verdicts: `OpenRuleTests.everyCopyKindAgainstEveryLibraryState` (raises, flagged foreign, a different library's
  landing: fresh key, `oneSecretOtherTypedOrMadeNew` or `noneThroughAppleKey`, `mintsOwnAppleKey` in Standard),
  `.aSyncedPairLandsHeld`; pins `AssessGuardMutationTests.rekeyAtEveryCrossing` (the landing's fresh key).
- The raise: `CornerScenarios.aCastleCopyFromAnotherMacRaises`.
- The landings: `LandTests.aCastlePairLandsWithItsPassphraseAloneTheWordsMadeNew`, `.aCastlePairLandsWithItsWordsAloneThePassphraseMadeNew`,
  `.aStandardPairThroughAReadableAppleKeyLandsWithNothingTyped`, `.aCrashAfterEveryWriteFinishesOrNeverHappened`;
  `ExactWritesTests.aLanding`; the held pair: `ExecutorEdgeTests.aSyncedPairsPassphraseMadeNewBecomesTheAccountsAtResumeSync`
  (the landing's notice; the made-new passphrase opens the vault after Resume Sync), `MoreScenarios.aSyncedPairLandedWithAPassphraseMadeNew`,
  `GeneratorFoundScenarios.aHeldLandingWaitsForResumeSyncBeforeStandardMeansStandard`, `.aSyncedStandardPairLandsHeldAndFinishes`,
  `.aCrashedHeldLandingIsHeldWhenItsResumeFinishes`.
- No key held by two Macs: `CopyAndCrossingScenarios.sendLibraryAfterThisChange` (all four typings), `CornerScenarios.oneLocalLibraryOnTwoMacs`
  ("sent after"); no sharing note: `SmallCopyActTests.sendLibraryWritesThePairWithNoSharingNote`.
**What is left.** A landing into an EMPTY slot (a fresh Mac with no library of its own): "hand-forwarded to phase 5 (Open
Library)" (the U3 record's first line; the orchestrator's note after U3 carries it to VX-309) — the world's receivers
always hold a library. The passphrase-and-words offer on a Standard landing and the declined-offer confirm are words
(phase 5).
**Code half.** Open Library's road and the walk — phase 5.

### T-6 · PROVEN (CUT clauses: the fold beyond the current key; the gifts)
**Element.** The migration runs as drawn: no custody repair either way until the mode is confirmed, corner 45's notice
offering Use Standard as a key change; the tree's first entries (the current key in the recorded mode, every catalogued
fingerprint); the fold; this Mac's copies of other libraries and the live library (once confirmed Standard) gain an
Apple key of their own beside the old shared one; a fresh backup — removing no road.
**Model proof.**
- The mode and the guard: `LegacyModeReaderTests.itAgreesWithTodaysDeriveOnTheWholeInputSpace` (against a verbatim
  transcription of today's `Posture.derive`), `.theStartingStatesReadAsTheDesignSays`; `AssessModeTests.aLibraryWithNoRecordOwesTheMigrationAndNothingElse`,
  `.cornerFortyFiveRecordsCastleNotYetConfirmedAndRepairsNothing` (the notice; Use Standard re-keys), `.answeringCornerFortyFiveStandardIsAKeyChange`,
  `.aSyncedUnconfirmedModeWaitsForTheVault` (nothing Apple-reachable while indeterminate); `ProtectionMigrationTests.corner45RecordsCastleNotYetConfirmedAndRunsNoCustodyRepair`;
  pin `AssessGuardMutationTests.unconfirmedModeNoCustodyRepair`; the key's birth (P-U4-4, ratified (a)):
  `GeneratorFoundScenarios.aWipedKeychainBeforeTheMigrationKeepsStandard`, `.aStandardBornKeyStaysStandardWithNoVaultToAsk`,
  `.aDeviceMigratedOfflineFollowsOnceOnline`.
- The run: `ProtectionMigrationTests.aStandardLibraryMigratesFoldsItsOlderKeyAndMovesBesideTheOldSharedKey` (the device id
  carried; today's marker cleared; the tree seeded; this Mac's own key beside the old wrap; nothing removed; a fresh
  pair), `.aCastleLibraryMigratesToATouchIDItemOfItsOwnKeyWhereTodaysGatedItemStood` (P-U3-8), `.aCrashAfterEveryWriteFinishes`;
  `WorldSmokeTests.todaysStandardStoreMigratesThenEntersCastle`.
- The fixed scenarios the element names: `MigrationScenarios.corner45sAmbiguousCase`, `.todaysStandardWaitingAndExposedLibrariesThroughTheMigration`,
  `.signedOutWithKeysThenTheVaultAnswers` (the deferred steps run once the vault confirms), `.aVaultThatMovedWhileTheLibraryDidntIsAnOrdinaryFollow`;
  `CornerScenarios.theWindowAfterTheMove`, `.iCloudKeychainOffThenTheRetirement`, `MoreScenarios.iCloudKeychainOffOnTheMacWhoseLibraryMoves`
  (promise 12 at the move).
- Today's old acts as migration input (in scope under LCW: "every state an old build has ALREADY LEFT"):
  `LegacyMarkerTests.itReadsWhatTodaysMarkerWrites`, `.theClearingCheckReadsTheDisk`; `CopyAndCrossingScenarios.anOldBuildsCrashedActMigrated`;
  `CornerScenarios.anOldBuildsCrashedActWhoseCommitHappened`, `.anOldRotationStillStandingOnTheServer`.
- Pins: `ScenarioMutationPins.theMoveRemovesNoRoad` (the move keeps the old wrap), `.theFreshPairAfterTheMove`;
  `ExecutorGuardMutationTests.theMoveDropsTheOldWrapWithTheGuardOff`, `.theMoveTakesNoFreshPairWithTheGuardOff`.
**CUT clauses (LC).** "The fold" beyond the current key — "the migration's fold beyond the current key" drops; "this
Mac's copies of other libraries … gain an Apple key of their own" — "§3.5 point 2's gift machinery" drops. Both stay
built and pinned as phase 1 closes (`ProtectionMigrationTests.aStandardLibraryMigratesFolds…`' older-key fold,
`AssessOldSharedKeyTests.theMovesGiftsAreOnlyForThisMacsCopies`, `ScenarioMutationPins.giftsOnlyForThisMacsCopies`,
`AssessGuardMutationTests.giftsOnlyForThisMacsCopies`, `SharedKeyActTests.theMoveAddsKeysOfThisMacsOwnBesideTheOldOneAndRemovesNothing`'s
gift half) and go at phase 2's first act. LCW also drops "§3.15's 'today's runner's finish path kept for one release'"
(the migration resolves old acts from the disk, as pinned).
**Code half.** The migration drills per shape, her stores' byte-copies, the real-scope rehearsal, and the app-target
test of the legacy reader against the REAL `Posture.derive` (the U1 hand-forward) — phase 2 (and VX-329).

### T-7 · GAP (narrow: the door gone once pressed) (CUT clauses: old-copy listings, the moves' re-run, the last-step race)
**Element.** Retiring the old shared key runs as drawn: the move again and the checks at Use Castle's door, a vault
still on it stopping the act; the sheet listing exactly what would stop opening and every Standard thing with no
passphrase or words; no keep-for-now; deleted only by its recorded id; the last-step race landing with the door and
the exception; the door only on a library already in Castle before this change, gone once pressed.
**Model proof — what is asserted.**
- The checks and the sheet: `RetirementRoutesTests.theRetirementsListIsExact` (still needs it, would stop opening, an
  Apple key alone, other Macs' key files — and nothing else); `AssessOldSharedKeyTests.aVaultOnTheOldKeyStopsUseCastleUnlessItIsTheActsOwn`
  (PROVISIONAL P-U2-4 for signed out); `CornerScenarios.iCloudKeychainOffThenTheRetirement` (a library with no passphrase
  or words listed), `.oneLibraryOnTwoMacsFromBeforeThisChange` (the other Mac's key file named),
  `.twoLibrariesOnOneAppleAccount` (the updated half).
- Deleted only by recorded id: `SharedKeyActTests.useCastleRetiresTheOldSharedKeyLastByItsRecordedID`,
  `.aNewOldNameItemAnOlderBuildMintedLaterIsLeftAlone`; `AssessRepairTests.theOldSharedKeyIsDeletedOnSightOnlyUnderTheIdThisSectionRetired`;
  pin `ExecutorGuardMutationTests.aNewerOldNameItemIsDeletedWithTheGuardOff`; `CornerScenarios.aRollbackAcrossARetirement`
  (delete on sight after a rollback); `GeneratorFoundScenarios.anOfflineRetirementResumeTakesItsOwnKnowledge`,
  `.aRetirementThatCouldNotReachItsKeyIsADeleteNeverCarried` (P-U4-1, ratified (b)).
- No keep-for-now: the act has no such parameter (`retireOldSharedKey(_:moves:)`, `useCastle(_:typed:gate:moves:)`).
- The door on a library already in Castle: `AssessOldSharedKeyTests.aLibraryAlreadyInCastleGetsOneAskAndADoor` (asked
  once; the door kept in Settings after a dismissal).
**The gap.** "Gone once pressed" (and absent after an ordinary Use Castle) is unasserted; by reading, the door is gated on
`oldSharedKeyStillStanding` (`Assess/Assess.swift:830`), which a retirement clears. **Needed:** after
`retireOldSharedKey` on a library already in Castle, and after a Use Castle that retired the key as its last step,
`assess` owes no `retireOldSharedKeyAsk` and offers no `.retireOldSharedKey` door.
**CUT clauses.** The sheet's old-copy listings — LC: "the retirement sheet's old-copy listings" drop (the routes stay
built: `RetirementRoutesTests` lists such copies as built); "the move again" — the re-run of the gifts (LC's "gift
machinery"; the U4 record supersedes "the old key's fold, then retirement — no stranded copy" and its pin
`retirementRerunsMoves`; `ExecutorGuardMutationTests.theRetirementStrandsAnotherLibrarysCopyWithoutTheMovesWithTheGuardOff`
stays as built); "the last-step race" — LCW: "the last-step-race arms" drop (`SharedKeyActTests.theLastStepRaceKeepsTheKeyWhenAVaultItReadsNamesIt`,
`ExecutorGuardMutationTests.theLastStepRaceDeletesTheOldKeyAVaultStillNamesWithTheGuardOff`,
`CornerScenarios.anOlderBuildsRelinkAndTheLastStepRace` kept while green). What STANDS (LC): "the old shared key's
retirement checks for CURRENT stores and vaults elsewhere".
**Code half.** The sheet, the door in Settings ▸ Protection, the walk — phases 3 and 5.

### T-8 · GAP (substantive: no road brings a plaintext export in)
**Element.** A plaintext export lands under today's key and mode when it carries this library's ID, otherwise as a new
library in Standard — said in the confirm.
**Model proof — what is asserted.** The verdict only: `OpenRuleTests.everyCopyKindAgainstEveryLibraryState`
(`.plaintextExport(sameLibrary: true, mode: <the library's>)`, `(sameLibrary: false, mode: .standard)`). Making an export:
`SmallCopyActTests.aPlaintextExportInCastleTakesThePassphrase`.
**The gap.** No executor act brings an export IN — the world refuses the verdict (`Scenario/Alphabet.swift`
`openCopyByRule`, `case .plaintextExport: throw ExecutorRefusal.nothingToDo`) — and no fixed scenario exists, though the
element's proof names one. No record hands it forward (it may belong with phase 5's "the plaintext export's ID" and Open
Library, design §5 — the orchestrator's call). **Needed:** an act and a fixed scenario — an export of THIS library opened
(encrypted under the current key, the record's mode, account and tree kept, this Mac's facts from the newer home,
promises 1–13 holding) and one of ANOTHER library (a new library in Standard under a fresh key, this Mac's own Apple
key, an empty history, a fresh sync identity), each with its confirm's facts in the act's outcome.
**Code half.** The export's library-ID table (the plain table the export keeps) — phase 5; the restore drill — phases 2/5.

### A-1 · PROVEN
**Element.** The four account situations behave as the table says; signing in or out changes nothing.
**Model proof.** `AssessAccountTests.noAccountIsLocalOnlyAndOffersToTurnSyncOn` (signing in changes nothing),
`.theLibrarysAccountSignedInIsInSync`, `.theLibrarysAccountSignedOutOffersTheOneRoadScreens`, `.anotherAccountSignedInOffersMoveOrSignOutOnly`
(the same email with a different account named); `MoreScenarios.herSignedInOutOtherAccountWalk` (signed out, into another
account, back: the record's account unchanged); promise 4 every step (`noSilentChange`: sign-in and sign-out are not
deliberate acts, so any mode or account change at one fails it).
**Code half.** The four situations' screens and the account-sequence walk — phase 4.

### A-2 · NOT A MODEL CLAIM
**Element.** New writing belongs to the library's account.
**Why.** Stamping new rows with the record's account (`OwnerIdentity` reading the binding, design §3.8) is persistence
code, proven by VX-314's state-transition suite — phase 4. The model's supporting fact — the record names the account
and only an act changes it — is A-1's (`MoreScenarios.herSignedInOutOtherAccountWalk`, promise 4).

### A-3 · PROVEN
**Element.** Leaving an account re-keys in either mode (Castle: both secrets; Standard: the passphrase typed or set new,
the words typed or made new, the new key under this Mac's existing own Apple key, nothing minted), the new history
taking the old key, any anchor riding unchanged; the account left opens only the Standard-synced days' copies until it
replaces its keys or enters Castle, never what's written after; the account's Apple key left to the account.
**Model proof.** `AssessAccountTests.everyLeaveReKeysInBothModes` (each of This Mac Only, Stop syncing here, delete the
account here, per mode: re-keys, the requirement); `LeaveAccountTests.aCastleLeaveReKeysWithBothSecretsAndNothingAfterOpensThroughTheAccount`
(no master lock; the history holds K0; the account's vault untouched; the sync keys gone),
`.aStandardLeaveWithAForgottenPassphraseSetNewMintsNothing` (this Mac's EXISTING own key; the account's key left; no
`appleAdd`; a fresh descriptor), `.thisMacOnlyCastleFromAnAccountInStandardLeavesTheAccountsKeyUntouched`,
`.moveLeavesOneAccountAndJoinsTheSignedInOne`, `.aLeaveCrashAfterEveryWriteFinishes_AlwaysAsk`, `.aLeaveWithThePlanGoneRollsBackOrFinishes`;
`ExactWritesTests.aLeaveInCastle`; the fixed scenarios the element names: `CopyAndCrossingScenarios.aLibraryLeavingItsAccountByEachAct`
(three acts × both modes), `CornerScenarios.aLibraryLeavingByMoveThenTheAccountLeavesCastle` (Move, then the account's
own leave from Castle reaches nothing), `CopyAndCrossingScenarios.thisMacOnlyCastleFromAStandardAccount`,
`.aStandardLibraryLeavesItsAccountThenEntersCastle`; the anchor riding: `ScenarioMutationPins.theAnchorCarriedByEveryRekey`;
promise 13's handling of the Standard-synced days' exception (`castleStaysCastles`); pins `ScenarioMutationPins.theRekeyAtEveryCrossing`,
`ExecutorGuardMutationTests.aStandardLeaveKeepsItsKeyWithTheGuardOff`. (A leave's anchor sentence: H-4's gap.)
**Code half.** The leave doors and the account-sequence walk — phase 4; the account's server-side deletion and Move's
re-stamp and resync (the U3 record's first lines) — phase 4.

### A-4 · GAP (narrow: Castle into a Castle account, at the act)
**Element.** Joining or moving into an account takes its mode: into Castle as entering Castle; into Standard from
Castle as leaving Castle (anchor, the sentence); in the library's own mode keeping the key; a differing passphrase
re-locks the library key under the account's, the anchor untouched.
**Model proof — what is asserted.** `AssessAccountTests.theJoiningRules` (all four pairings: `.entersCastle`,
`.leavesCastle` with rule five, `.sameMode` with no re-key both ways); `AccountJoinTests.joiningACastleAccountFromStandardIsEnteringCastle`,
`.joiningAStandardAccountFromCastleIsLeavingCastle` (rule five; the anchor; an empty history), `.joiningInTheLibrarysOwnModeKeepsTheKeyAndReWrapsThePassphraseUnderTheAccounts`
(Standard into Standard: the key kept, the passphrase under the vault's descriptor — corner 27), `.setUpSyncInStandardMintsTheAccountKeyAndKeepsTheLibraryKey`,
`.setUpSyncInCastleGivesTheVaultNoAppleCopy`, `.theRefusalsAreNamed`; `LeaveAccountTests.anEnrollIntoCastleCrashAfterEveryWriteFinishes`;
Move: `LeaveAccountTests.moveLeavesOneAccountAndJoinsTheSignedInOne`; the fixed scenario the element names:
`CornerScenarios.aCastleLibraryJoiningAStandardAccount`.
**The gap.** Castle into a Castle account is pinned only at `assess`; no executor test enrolls a Castle library into a
Castle account (the code path: `Executor/Acts/AccountActs.swift`, the `joinKeyFile` step). **Needed:** enroll a Castle
library (its passphrase differing) into a Castle account → the key kept, the master's lock with its words copy added,
the passphrase re-locked under the account's descriptor, no Apple write, the sync keys the Castle way; with an anchor
present, the anchor byte-identical (H-4's (b)).
**Code half.** Setup, enroll and connect, and the account-sequence walk — phase 4.

### L-1 · PROVEN
**Element.** The lobby follows the table (VX-310): the button whenever a Touch ID item for the current key exists; no
item or no finger — no button, one quiet line; a press failing on an existing item — the changed line, then the
re-arm question, a new item only on yes; a Touch ID choice with no item — nothing asked, Always ask recorded quietly,
Touch ID back only from Settings with the passphrase; a new device identity on Always ask; the stored hash a hint.
**Model proof.** `AssessTouchIDTests.theButtonIsThereWheneverAnItemExists` (a closed lid: the button stays, the press says
why), `.withNoItemOrNoFingerThereIsALineAndNoButton`, `.aPressThatFailsOnAnExistingItemShowsTheChangedLineThenTheReArmQuestion`,
`.aTouchIDChoiceWithNoItemRecordsAlwaysAskQuietlyAndAsksNothing`, `.aMovedHashChangesNothing`, `.aNewDeviceIdentityStartsOnAlwaysAsk`;
`TouchIDLobbyWithNoHintTests.aTouchIDItemWithNoHintShowsTheButton`, `.noItemNoButton`; `AssessModeTests.beforeUnlockNothingDecides`;
`ExecutorDeviceActTests.theReArmIsAskedOnlyWhenTheItemExists` (yes: a new item; no: Always ask; no item: nothing to do),
`.touchIDComesOnlyFromSettingsWithThePassphraseAndAlwaysAskDeletesTheItem`; `ExecutorRepairTests.aChoiceOfTouchIDWithNoItemRecordsAlwaysAskQuietly`;
`ExactWritesTests.theSettingsAndTheReArm`; the fixed scenarios the element names: `MoreScenarios.aBiometryChangeThenTheRearmQuestion`
(the moved hash: the button stays, a press opens, nothing asked; then an enrollment change and the question),
`.bothHomesRolledBackPastASwitchToAlwaysAsk`, `DeviceScenarios.aReplacementMacsFirstOpen`; the lid at Castle entry:
`MoreScenarios.theMemoryItemDeletedAloneAndTheLidClosed`; the fakes' semantics: `WorldSmokeTests.aTouchIDItemDiesOnAnEnrollmentChangeButNotOnAClosedLid`;
pins (no re-arm question without an existing item): `ScenarioMutationPins.noRearmQuestionWithoutAnItem`,
`AssessGuardMutationTests.noRearmWithoutItem`; (no repair makes one) `ScenarioMutationPins.noRepairMakesATouchIDItem`,
`AssessGuardMutationTests.noRepairMakesTouchID`, `ExecutorGuardMutationTests.aRepairMakesATouchIDItemWithTheGuardOff`.
**Note.** A brand-new identity with NO predecessor (another login, a landing) starts with no choice yet, its act's own
press deciding; only a replacement's takeover starts on Always ask (PROVISIONAL P-U1-7; `DeviceFactsTests.aSecondMacOSLoginStartsItsOwnIdentity`).
**Code half.** The lobby's own tests and faces — phase 2; the re-arm door — phase 4; the walk on a Mac with and without an
enrolled finger — phases 2/4.

### K-1 · PROVEN
**Element.** Retention and the offer act only on this Mac's copies of this library.
**Model proof.** `RetentionTests.overASharedFolderNothingForeignIsPruned` (two Macs' and two libraries' copies, an
unattributable one, legacy flat files listed and never pruned), `.theContainerKeepsItsNewestFourteen`,
`.theFarFolderKeepsFourteenDailiesAndFourWeeklies`, `.todaysFourteenPlusFourRuleIsKeptExactly`, `.anotherLibraryOnThisMacIsKeptAsToday`;
`CatalogAttributionTests.everyCopyIsAttributedToItsLibraryFromItsKeyFileAndToItsMacFromItsSubfolder`; the offer:
`SmallCopyActTests.theOfferDeletesOnlyThisMacsCopiesOfAnotherLibraryAndTheLastCopysAppleKey` (another Mac's copy and this
library's own untouched); promise 11 every step (retention's half; the offer's half is the unit test); the fixed scenario
and pin the element names: `ScenarioMutationPins.theCrossMacPrune`, `RetentionGuardMutationTests.pruneOwnCopiesOnly`.
**Code half.** The real retention over the far folder and the offer's face — phase 5.

### K-2 · PROVEN
**Element.** Every sentence about what opens a copy comes from the route finder and is true.
**Model proof.** Promise 9 (`honestWords`: every *Opens with* opener's witness road walked with the real secret of the day
it names — after every `done` step of every fixed scenario, every 10th generated step and every settle);
`RouteFinderRoadTests.*` (eight tests, each `expectEveryRoadOpens`), notably `.aCopyWhoseKeyCantBePinnedNamesOnlyWhatOpensEveryCandidate`
and `.aNestedAnchorsKeysNeedTheirOwnDaysSecrets`; `AnchorSentenceTests.*`.
**Code half.** Every surface rendering only the route finder's line (the restore list, the offer, the confirm, Data
Safety, the field guide) — phase 5.

### K-3 · CUT
**Element.** Other libraries' copies whose newest copy is in Standard keep opening through this Mac's own key file and
Apple key for them; deleting a library's last copy deletes its key file and its Apple key.
**The ruling (LC).** *"we don't need to keep every store shape today's builds ever left. they don't need to keep opening
forever"* — her question-tool pick: "Previous Libraries / set-aside stores / other libraries' old copies take the same
cut"; the plan's record: "What DROPS: … other libraries' old copies — and therefore: … §3.5 point 2's gift machinery
(per-library key files + own Apple keys for OTHER libraries' old copies)". The fixed scenario the element names ("an
older library of another library") is "SUPERSEDED … both variants removed" (`Scenario/FixedScenariosCorners.swift`).
**What survives.** "The catalog/retention/offer still LIST and DELETE old copies as files (VX-265's delete choice
survives)": `SmallCopyActTests.theOfferDeletesOnlyThisMacsCopiesOfAnotherLibraryAndTheLastCopysAppleKey` (this Mac's
copies of another library deleted, its last copy's Apple key deleted; the own key file's deletion is not asserted — that
file is the gifts' and dies with them). Copies of another library made AFTER the switch open through their own frozen
pairs (promise 5 walks every copy a device made); reopening a library this Mac itself set aside under that library's
current key ("any it knows", design §3.7) is DEFERRED to phase 5 / VX-309 (the U4 record's first line).
**Code half.** The offer's other-libraries group — phase 5.

### K-4 · CUT
**Element.** A copy with no record has its mode worked out once with today's rules; an exposed-era Standard copy with
no passphrase or words never lands in Castle.
**The ruling (LC).** The plan's record: "What DROPS: … the legacy readers' keep-forever role (they become
migration-only); the 'copy with no record' open road". The fixed scenario the element names ("a copy made before this
change, of another library … lands in Standard, never Castle") is "SUPERSEDED by her ruling of 2026-10-14"
(`Scenario/FixedScenariosCopies.swift`).
**What survives.** Today's rule as the MIGRATION's input (T-6: `LegacyModeReaderTests.*`, the exposed shape recorded
Standard, never Castle — `.theStartingStatesReadAsTheDesignSays`). The open road is built and pinned as phase 1 closes
(`OpenRuleTests.aCopyWithNoRecordIsWorkedOutByTodaysRule`) and goes with the other dead arms at phase 2's first act; an old
copy then meets the honest refusal naming its roads (an old build, or a plaintext export).

### O-1 · PROVEN
**Element.** Who can open what matches the table, for every row.
**Model proof — the table's rows against the promises.**
- *You, on your Mac* (Castle: Touch ID or passphrase; Standard: opens, nothing asked) — promise 5 (her roads: the press,
  custody, every day's secrets) and the lobby walk; *you, on a new Mac, with your passphrase or words* (yes — at least
  that copy's day's secrets) — promise 5 with `RouteFinderRoadTests` naming the day; *you, on a new Mac, with your Apple
  account only* (Castle no; Standard yes when iCloud Keychain carried the key) — promise 3 (each Standard key file's
  Apple wrap is under a key iCloud Keychain carries) and promise 2 (nothing Apple-reachable opens a Castle library); the
  replacement and clone scenarios (`DeviceScenarios.aReplacementMacsFirstOpen`, `MoreScenarios.aLivingMacClonedOntoNewHardware`)
  open a new Mac, but the world's lobby also types her secrets, so no test opens with the Apple account ALONE as its
  own act.
- *Someone who knows this Mac's login password* and *someone in your Apple account* (Castle: nothing; Standard: the
  library and its copies since it came into Standard — after a leave, nothing from before) — promises 2 and 8 (the
  attacker's seeds are every non-Touch-ID item on the device, its iCloud Keychain replica included, every file, the
  session's vault — the stated exceptions taken out), promise 13 (the Apple account's whole keychain added after a leave),
  promise 3 for the Standard column.
- *Someone who steals one backup file* (no — needs a key) — the attacker's reach opens a file only by a key whose
  fingerprint it carries; no named test steals a file alone.
- The stated exceptions (the Castle column's) — the attacker's seeds and exemptions take out exactly §3.1 rule 2's: the
  old shared key until its retirement, the Standard-synced days (promise 13), the pre-change hand-off, a retirement not
  yet carried by iCloud Keychain (with P-U4-1's ratified residue); a former Apple account is never among the attacker's
  seeds (C-11); the Markdown-export exception is plain text by her choice and isn't modelled.
**Not model claims.** *The Variorum server* row (your writing no; dates, tag shape and sizes yes) is the E2EE wire's
(SyncSpec), outside this model.
**Code half.** The Keychain Access check on the dev store (a Touch ID item listed and deleted, its secret unreadable) —
phase 3's drill; the adversary drills — phases 2/3.

---

## The tally (47 rows)

| status | n | rows |
|---|---|---|
| PROVEN | 31 | C-1, C-4, C-5, C-7, C-8, C-10, C-11, H-1, H-2, H-3, H-5, S-1, S-3, S-4, S-5, S-6, R-1, R-2, R-3, R-5, R-6, T-2, T-3, T-4, T-6, A-1, A-3, L-1, K-1, K-2, O-1 |
| PARTLY | 2 | R-4 (the lobby's memory-mirror road, phase 2 — her P-U4-13 (b) ruling; P-R1-1's copy-less case), T-5 (the landing into an empty slot, phase 5 / VX-309) |
| NOT A MODEL CLAIM | 1 | A-2 (row stamping by the record's account — phase 4, VX-314) |
| CUT | 2 | K-3, K-4 (LC) |
| GAP | 11 | substantive: C-2, T-8 · narrow: C-3, C-6, C-9, H-4, S-2, S-7, T-1, T-7, A-4 |

Rows standing with **CUT clauses**: C-3, C-5, T-4 (pre-rebuild copies and keys — LC); S-7, T-6, T-7 (the gifts, the
fold beyond the current key, the sheet's old-copy listings — LC); C-10, H-3, S-4, T-2, T-3, T-7 (live older builds,
the last-step race — LCW).

## The GAP list (each with the test it needs; none written here)

**Substantive — no road runs it (the orchestrator's call: build before the GO, or hand forward with an owner):**
1. **C-2 — the planted Apple lock's re-key.** `assess` owes `rekeyForFault` (`Assess/Assess.swift:575–576`); nothing in
   `Executor/` runs it, and the world can't reach the state. Needs an executor road and a fixed scenario: a Castle library
   (local and synced) whose live key file carries an Apple wrap of its CURRENT key (a fixture) → relaunch and settle → a
   fresh Castle key, the planted key in the history, no Apple wrap live, promises 2 and 8 holding against the planted key;
   its mutation twin failing with the re-key off.
2. **T-8 — bringing a plaintext export in.** The verdict is pinned; no act exists (the world refuses it:
   `Scenario/Alphabet.swift` `openCopyByRule`) and no record hands it forward. Needs an act and a fixed scenario: this
   library's export lands under the current key and the record's facts; another library's lands as a new Standard
   library (fresh key, this Mac's own Apple key, empty history, fresh sync identity); the confirm's facts in the outcome.

**Narrow — the code path exists, the assertion is missing:**
3. **C-3** — Use Castle that can't fold an anchor (both secrets changed since the leave): the entry completes, the anchor
   in `keptAnchors` byte-identical, `diagnostics` holds `.anchorKeptUnopened(madeAt: <leave day>, …)`, the outcome's
   notices `.anchorKeptUnopened(day:)` (`CommonSteps.swift:113–115`).
4. **C-6** — a synced Use Castle and a follow into Castle on an Always-ask device: no sync-keys item of either class, the
   account's keys in session memory (`CommonSteps.swift:344–346`).
5. **C-9** — a follow into Castle with the export on: `notices == [.scheduledExportTurnedOff]`, the export off in both homes
   (`Follow.swift:52, 120`).
6. **H-4** — after a leave, the `.replacesWords` sentence (with the leave's day) in the Done of `regenerateWords`,
   `replaceAllKeys`, each `leaveAccount`, and `setUpSync` making new words, and in `assess`'s `.replaceAllKeys` and three
   leave-door specs (`KeyDoors.swift:75`, `ReplaceAllKeys.swift:57`, `AccountActs.swift:99, 135`, `Assess.swift:795, 855`);
   and an enroll of a library carrying an anchor into a Standard account whose passphrase differs leaving the anchor
   byte-identical (`AccountActs.swift:188`).
7. **S-2** — a follow into Standard typing the passphrase, then the words: the new key file opens with the typed secret
   (not the other), through the new master and `wordsThroughMaster`, `masterWordsCopy == vault.masterWrappedByRecovery`,
   its Apple wrap under a key the follower minted (own, live) (`Follow.swift`, the `keyFile` step).
8. **S-7** — Re-link's library arm re-keys nothing: `library.key`, the live file's fingerprint, epoch, history and the
   record's tree unchanged (`SharedKeyAndRelink.swift:58–66`).
9. **T-1** — the vault-on-old-key refusal leaves nothing written: `writes` empty, no plan, nothing in flight
   (`EnterCastle.swift:89–94`).
10. **T-7** — after `retireOldSharedKey`, and after a Use Castle that retired the key as its last step: no
    `retireOldSharedKeyAsk` and no `.retireOldSharedKey` door (`Assess.swift:830`).
11. **A-4** — a Castle library enrolling into a Castle account (a differing passphrase): the key kept, the master's lock
    and words copy added, the passphrase re-locked under the account's descriptor, no Apple write, the sync keys the Castle
    way (`AccountActs.swift`, `joinKeyFile`).

## The CUT list (rows and clauses, with the ruling)

- **K-3** (LC: other libraries' old copies, the gift machinery) — survives: the offer still deletes them as files.
- **K-4** (LC: "the 'copy with no record' open road"; the legacy readers migration-only) — survives: today's rule as the
  migration's input.
- Clauses: **C-3, C-5, T-4** — pre-rebuild keys and copies (LC: "pre-rebuild copies opening on the new system", "the
  migration's fold beyond the current key"); **S-7** — other libraries' key files (LC: the gifts); **T-6** — the fold
  beyond the current key and the gifts (LC), today's runner's finish path (LCW); **T-7** — the sheet's old-copy listings
  and the moves' re-run (LC), the last-step race (LCW); **C-10, H-3, T-2, T-3** — a leave, follow or rotation completion
  by an older build (LCW); **S-4** — an older build's Re-link (LCW).
- Built, pinned and green as phase 1 closes, removed at phase 2's first act (LC): the fold beyond the current key, the
  gifts (`AssessOldSharedKeyTests.theMovesGiftsAreOnlyForThisMacsCopies`, `AssessGuardMutationTests.giftsOnlyForThisMacsCopies`,
  `ScenarioMutationPins.giftsOnlyForThisMacsCopies`, `ExecutorGuardMutationTests.theRetirementStrandsAnotherLibrarysCopyWithoutTheMovesWithTheGuardOff`),
  the no-record open road (`OpenRuleTests.aCopyWithNoRecordIsWorkedOutByTodaysRule`).
- Kept while green, beyond scope (LCW): `MoreScenarios.anOlderBuildCompletingALeavesRotation`,
  `CornerScenarios.anOlderBuildsRelinkAndTheLastStepRace`, the older-build half of `CornerScenarios.followersAnchorsOpenWithWhatOpenedThem`,
  the not-updated half of `CornerScenarios.twoLibrariesOnOneAppleAccount`, `ScenarioMutationPins.anOlderBuildsRelinkLandsTheVaultOnTheOldKey`,
  `GeneratorFoundScenarios.aRollbackPastUseCastleToTodaysFilesKeepsTheKeysBirth`.

## For the orchestrator (found while reading; none acted on)

- The two substantive GAPs (C-2, T-8) have no recorded owner; each needs an owner before the GO record closes, or a
  build.
- S-1: PROVISIONAL P-U2-1's own words ("it goes at the next act a person presses") are not what the code does for a
  stray Touch ID item of another key — the next re-key deletes only the outgoing key's items (`CommonSteps.swift:220–230`).
  Worth a line in P-U2-1's QUESTIONS entry.
- H-5: the migration's tree seeding exists for pre-switch copies to read as their own; LC drops their opening. Built and
  pinned; phase 2's record should say whether it stays.
- The hand-forwards this table leans on, already recorded: P-U4-13 (b) (phase 2's memory-mirror road — R-4), P-R1-1
  (the copy-less rebuild door — R-1, R-4), the empty-slot landing and "any it knows" (phase 5 / VX-309 — T-5, K-3),
  P-U1-1 and P-U4-14's leaf checks (phase 2 — R-5, R-6), the app-target `Posture.derive` test (phase 2 — T-6).

