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

**LIVE STATUS:** C-1…C-11, H-1…H-5, S-1…S-7 written (the row blocks below); R-1…R-6, T-1…T-8, A-1…A-4, L-1, K-1…K-4,
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

