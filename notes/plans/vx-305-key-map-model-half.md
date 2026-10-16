# VX-305 — the key map's model half

**What this is.** The go/no-go's item 5 (`notes/plans/vx-305-castle-core.md` §1): *"The model half of the key-map
table is written: one row per element of the target key map, naming the test that proves the model does it. The code
half comes at phase 5."* One row per element of the acceptance checklist at the end of
`notes/plans/vx-266/castle-target-key-map.html` — 47 elements: C-1…C-11, H-1…H-5, S-1…S-7, R-1…R-6, T-1…T-8, A-1…A-4,
L-1, K-1…K-4, O-1. Each row quotes the element in one line, names the tests that prove the model does it, the scenario
promises and mutation pins that carry it, and gives a status.

**Code tree: `63cf038f1`** (the ladder's close, plan §9; every later commit on the branch is a record). Written
read-only on code while the go/no-go soak runs: every test named here was READ, none was run for this file. Their green
state is the ladder-close runs on that tree — Debug `434 tests in 71 suites`, `swift test -c release` `372 in 66`
(the five DEBUG-only mutation-pin suites, 62 tests, compile out) — recorded in plan §9. The fresh soak is item 1's, in
flight, not this file's.

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

**LIVE STATUS:** C-1…C-11 written (the row blocks below); H-1…H-5, S-1…S-7, R-1…R-6, T-1…T-8, A-1…A-4, L-1, K-1…K-4,
O-1 PENDING; the tally and the GAP and CUT lists PENDING.

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

Every fixed scenario runs every step through `SWorld.step` and ends `expectPromisesKept`; the soak is
`GeneratorTests.seededSequencesKeepEveryPromise` (`PROTECTION_SOAK=1`).

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

