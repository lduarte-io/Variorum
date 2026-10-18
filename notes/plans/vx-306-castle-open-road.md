# VX-306 — Castle rebuild, phase 2: the open road (the headless core goes live in Debug builds, to the rules)

**Status: LIVE — KICKED OFF 2026-10-18 by the author's `/architect-phase vx-306` with her rulings (§7); the orchestrator's provisional kickoff rulings §7b; the words drafts §7c; the units §2 (U1 as two sessions); the running record §6/§9. (Planned 2026-10-18 at VX-378's close.) Originally: PLANNED — READY TO KICK OFF (VX-378 merged 2026-10-18). Written 2026-10-17 at VX-378's closeout, to `notes/CastleRules.md` (the contract) and VX-306's
2026-10-16 re-scoping comment (the migration is GONE — rule 26). Kicks off at the author's word with
`/architect-phase vx-306` (recommended: the phase is face- and design-heavy, and her sittings rule the words).**

- **The contract:** `notes/CastleRules.md` — read in full before anything. **The walk:** `notes/plans/vx-266/castle-lifecycle.html`
  (rendered from the lifecycle fixture — the facts the faces must agree with). **The headless core this phase wires:**
  `Sources/VariorumCore/Protection/` as VX-378 left it (`notes/plans/vx-378-castle-simplified.md` §8's unit records,
  the U2 record's "What the faces will read changed shape" paragraph FIRST — it lists every type a face consumes).
- **The old design** `notes/plans/vx-266-castle-backups-prelaunch.md` is superseded where the rules differ; its §3.10
  (Touch ID, VX-310's rule as her words) and the Apple facts (`notes/plans/vx-266/second-opinion-apple-facts.md`) stay
  live.
- **Tickets:** VX-306 (this phase; project "Castle & backups before launch"); members VX-310 (the lobby's Touch ID
  button and line — the lobby half; the re-arm half is VX-308's); VX-379 rides as the standing acceptance item (the
  guide and settings copy to the rules — the Start Here chapter FIRST); VX-301's "moves" have nothing left to do (its
  body says so).

> **KICKOFF MESSAGE** (paste-ready; the orchestrator's brief for each implementer session is this plan's unit section
> plus the standing rules below).
>
> **STEP 0 — SEAT THE PHASE (the merge is DONE: her word 2026-10-18, PR #171, merge commit `aeabdd75b`; the VX-378 session
> retired the VX-305/VX-378 in-flight row, removed `~/dev/variorum-vx-305` and the branch, took the board snapshot, moved
> VX-378/VX-305/VX-345 to Done and noted the Sync/-or-custody slot's hand-over in the stage log).** From `~/dev/variorum`
> on `main`: `git pull`; `git worktree add -b vx-306-castle-open-road ~/dev/variorum-vx-306 origin/main`, push the branch;
> add this phase's in-flight row (ticket · branch · worktree · machine — it HOLDS the one Sync/-or-custody slot) in one
> atomic pull → edit → commit → push; Linear: VX-306 → In Progress. Announce yourself to the stage coordinator
> (oct18coordinator at the time of writing) before the first `xcodebuild test` or dev-store walk.
>
> You are building **the open road**: the first time the rebuilt protection core touches the app. Nothing here changes
> a rule; where a face would need one, STOP and bring it to the author (the VX-378 stop rule, carried forward).
>
> **Read first, yourself, in full, in this order:** `CLAUDE.md` and its canon; `notes/SessionResiliencyProtocol.md`;
> **`notes/CastleRules.md`**; `notes/plans/vx-266/castle-lifecycle.html` (in a browser); this plan whole; the VX-378
> plan's §8 U2 RECORD ("What the faces will read changed shape"), the U4 RESUMPTION RECORD's piece 3 (the notice and
> the offer as built) and §5 (the hand-forwards); `notes/SyncSpec.md` §3 (custody — this phase touches keychain code,
> so it HOLDS the one Sync/-or-custody slot and its ladder is Fable's); the vx-266 design §3.10; the current open road
> in `App/Variorum/Shared/` — `AppBootstrap.swift`, `StoreLockView.swift` (`App/Variorum/Variorum/`),
> `ProtectionController.swift`, `StoreProtection.swift`, `EncryptionKeychain.swift`, `AppleKeyCustody.swift`,
> `LibraryOpenModel.swift` + `LibraryOpenCopy.swift` (13x's Open Library), `RestoreHoldModel.swift`,
> `PostureCopy.swift`, `KeyDoorCopy.swift`; Settings ▸ Data Safety (`Features/Settings/DataSafety*.swift`).
>
> **The one law of this phase:** the new road is ON IN DEBUG BUILDS ONLY (her ruling: "dormant in release is what I
> meant" — the core compiles in both configurations, the WIRING is Debug-gated), so it reaches only the fenced dev
> store and byte-copies of her stores; today's road stays alive on `main` because Release still runs it. A check proves
> a Release build still runs today's road (gate item). The dev store, once opened by this build, is the new system's —
> tell the stage coordinator (`notes/plans/…coordinator…` / the in-flight row) and merge `main` before any walk.
>
> **Hard limits:** no `Sync/` line (the server's `key_vault` change is VX-307's §12 lockstep); no migration or
> pre-design-store handling (rule 26 — a store with no protection record REFUSES with `recordMissing`, no face string:
> "no refusal string either", her word); no new dependency; nothing from the rules' considered-and-not-pursued list;
> no face that contradicts a rule or the lifecycle page's facts. Every change to a keychain or custody path is red-on-
> old pinned. Every Mac-app change ends at the dev store under a HELD `Tools/stage` claim; `xcodebuild test` only under
> the stage; the real store is never touched (`/Applications` refresh: NONE this phase — Debug-only).
>
> Checkpoint rules as ever (commit per piece, push after each, LIVE STATUS from the first commit, PENDING until
> verified, foreground waits, no trailers, `Part of VX-306`). PROVISIONAL rule as ever (options · the most
> rule-defensible built · QUESTIONS). One Sonnet lookup at most, external facts only.

---

## 1. What this phase is, and how it closes

**The headless core goes live in the Debug app, on the OPEN road only:** the lobby decides nothing before unlock and
takes the executor's roads; the four remembered things, the per-key custody items, the protection record and key file
format 3 are written by the app's own doors; the two copy doors get faces; the honest refusals and the notice get
faces; rule 1's redundancy restore runs when the live key file is absent; VX-310's Touch ID button follows the real
road; the phone builds and opens (the Debug road on the phone's fenced store). **No act that changes posture or keys
ships here** — Use Castle / Use Standard / the follows / Replace All Keys are VX-307's; the key doors and the account
doors VX-308's; Send Library, the plaintext export and the copies list VX-309's. Creating a library (rule 2: words at
birth, the once-shown words) IS this phase's, because the open road begins there.

**Closes on USE-shaped evidence (CLAUDE.md's sizing guidance):** the dev store walked through the lifecycle's stages
1–5, 9, 10 (the Standard half; Castle's entries are VX-307's) and 13–14 under a held stage claim, screenshots recorded;
the two doors used on a real backup and on an AirDropped copy; the notice and the offer seen on a hand-swapped file;
byte-copies of her stores opened read-only through Look inside (behind the A1 rail); the Release-still-runs-today's-road
check; the phone opens its fenced store; **the words the app says agree with the rules as built** (VX-379's standing
item — the Start Here chapter and every face this phase touches, checked sentence by sentence against
`CastleRules.md`); a Fable ladder closed (custody code — CLAUDE.md's cast rule); the scenario suite and the lifecycle
suite green in both configurations on the final tree.

**Sizing:** three acceptance units (below), one implementer session each; the orchestrator walks each under the stage
before its record closes. Outside two phase-sized units — said to the author at kickoff, as the guidance asks; the
split is by surface, each unit's walk its own evidence.

---

## 2. The units

### U1 — THE LOBBY ON ROADS (the open road, Debug-gated) — RUN AS TWO SESSIONS, U1a and U1b (the orchestrator's kickoff reading, §7b P-VX306-K2)

**Found at kickoff (2026-10-18), and why U1 is two sessions:** NO production leaf exists anywhere in `App/`. The executor's
only conformers are its two test worlds (`Tests/VariorumCoreTests/Protection/Executor/ExecutorWorld.swift`,
`…/Scenario/World.swift`'s `DeviceLeaves`), and no `App/` file names `ProtectionExecutor`, `ExecutorLeaves` or
`ProtectionFacts`. `Leaves.swift`'s own header says it: *"Phase 2 wires the real Keychain, file and SQLCipher leaves."*
The plan's "the production `KeyFileStoreLeaf` implements `catalogedKeyFiles`" undersold it — there is no production leaf to
grow. So U1a BUILDS the thirteen leaves, the catalogue lister and the facts gatherer (headless, tested on throwaway
keychain scopes and temp folders), and U1b wires the Debug app's route and lobby to them. Three units, four implementer
sessions; the acceptance units are unchanged.

#### U1a — THE PRODUCTION LEAVES (one implementer session; headless; the orchestrator runs the Mac batch under the stage)

Pieces, in order, EACH its own commit (`Part of VX-386` / `Part of VX-390` / `Part of VX-306` as the piece says):

1. **VX-386 — the three residues, the phase's FIRST commit** (core only, no behaviour change): `PlanRunner.swift`'s
   DEBUG-guard-off resume call (`settleAct`, the `!guards.planNamedBySectionOn` branch) gains the same `catch ActRolledBack`
   as the normal call; `U4PromiseCheckTests` gains the promise-1 oracle arm on a synced FOLLOWED device (the round-4
   report's appendix probe — `notes/plans/vx-378-ladder-round-4.md`); `Promises.swift`'s STATED LIMITS L1 parenthetical
   widens (a lagging device may be Castle-recorded). Proof: the protection set green in both configurations.
2. **The `protection_record` table — a LOCAL-ONLY migration, its own commit** (CLAUDE.md's schema-commit rule):
   `v1_30_protection_record` — `protection_record(library_id TEXT PRIMARY KEY, record TEXT NOT NULL, updated_at TEXT NOT
   NULL)`, the `ProtectionRecord` as `ProtectionCoding` JSON. Registered in `SyncSchema.localOnlyTables` (never a payload,
   never a mirror — the completeness walk pins it; the plaintext export DROPS it, as the record's own doc says: *"the
   plaintext export leaves it behind"*; `LocalMachineryRecreation` re-creates it empty). The DDL lives in ONE value
   (`ProtectionRecordSchema.ddl`, `CREATE TABLE IF NOT EXISTS`) that the migration AND the production library leaf share:
   `createLibrary(with:record:)` writes a fresh keyed file holding only this table, and the app's ordinary open then runs
   every migration over it. Marker 13 untouched; ZERO lockstep (the MCP grants family's and the search index's class).
3. **VX-390 — the library-ID stamp (core + the fakes + the pin, red-on-old):** `CustodyItemFact` gains `libraryID:
   String?`; `CustodyLeaf.writeCustody` and `AppleKeysLeaf.addAppleKey` take `libraryID:`; `AppleKeysLeaf` gains
   `appleKeyIDs(ofLibrary:)` — every own-named item stamped with the ID that this device can SEE (readable or not: rule 11's
   deletion reaches the Apple account, and the leaf deletes by id). Castle entry's sweep — Use Castle, the follow into
   Castle, the join into Castle (`EnterCastle.swift`, `Follow.swift`, `AccountActs.swift`, the shared step in
   `CommonSteps.swift`) — deletes every SILENT custody item stamped with THIS library's ID and retires every Apple key so
   stamped, whatever the live key file or the catalogue remembers; the catalogue sweep (P-VX378-O2-2) stays as the belt;
   sync-keys items and another library's items untouched (rule 17's Look-inside road survives). The scenario world's fake
   keychain (`Scenario/World.swift`, `ExecutorWorld.swift`) stamps FIRST; the promise checker's L6 / rule-25 reading
   narrows (a STAMPED silent item or Apple key of this library surviving entry is a violation; an unstamped one — the fakes
   may plant one for the limit's own pin — stays rule 25's stated limit). **The pin:** the gate's seed 3 replayed
   (`U4GatePins`) with the catalogue leaf answering EMPTY — red on the pre-piece tree, green after: the stamp alone closes
   the rollback corner on this Mac. Rule 25's last sentence stays until her word (the plan's U1 text).
4. **The production leaves — `App/Variorum/Shared/Protection/`** (cross-platform: the phone composes the same leaves in U3),
   one file per leaf, each DUMB exactly as `Leaves.swift`'s header rules (reads or writes what it is told, verifies nothing
   about protection, decides nothing — a write lands or throws; every delete is the executor's call). The TYPES compile in
   both configurations (rule 24); their USE is U1b's Debug gate. The shapes:
   - `KeychainCustodyLeaf: CustodyLeaf` — generic-password items, service `ProtectionNames.custodyService`, account
     `custodyAccount(scope:fingerprint:class:)`; `.silent` = `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`, no ACL (today's
     silent item's shape — `E2EEKeychainStorage.boundQuery`); `.touchid` = `SecAccessControl` with `.biometryCurrentSet`
     (the Apple facts §6/§10 — `notes/plans/vx-266/second-opinion-apple-facts.md`), read through an `LAContext` (the press);
     the enumeration reads ATTRIBUTES only (`kSecReturnAttributes`, never `kSecReturnData`), so no Touch ID item is ever
     pressed by a listing; VX-390's stamp as a plain queryable attribute (`kSecAttrLabel` = the library ID — non-secret; the
     key file already says it in the clear). A silent write is verified by a read-back; a Touch ID write by an existence
     probe. `KeychainTestTripwire` guards the real scopes (`Variorum`, `Variorum-dev`) exactly as today — EVERY new keychain
     mutation goes through `refusesRealScopeMutation(scope, leaf:)`.
   - `KeychainSyncKeysLeaf: SyncKeysLeaf` — the same shapes under `syncKeysService` / `syncKeysAccount`; `holdInSession` in
     memory only. Real and tested; no act of this phase calls it (the record names no account — creation binds none; sync
     setup is VX-308's). Today's sync-key custody (`SyncCustodyRecord`, `DeviceKeySyncProvider`, `E2EEKeychainStorage`) is
     UNTOUCHED — sync itself keeps running on it in every configuration until VX-307/308 cross it.
   - `ICloudAppleKeysLeaf: AppleKeysLeaf` — synchronizable items (`kSecAttrSynchronizable`), service `appleKeyService`,
     account `appleKeyAccount(scope:id:)`, the access group today's `AppleKeyKeychain` uses (team prefix + shared suffix —
     the phone shares it), the stamp attribute; `readableAppleKeyIDs` = present AND readable here; `deleteAppleKey(id:)` with
     `kSecAttrSynchronizableAny`. The old shared name `<scope>-apple-key` is never read (rule 26; the parser refuses it).
   - `UnreachableVaultLeaf: VaultLeaf` — every call throws. The server's `key_vault` still has the pre-rules shape; VX-307's
     §12 lockstep wires the client. So `readVault` fails closed and nothing synced runs this phase (P-VX306-K3).
   - `SQLCipherLibraryLeaf: LibraryFileLeaf` over the slot's `variorum.sqlite`: `libraryOpens` = `StoreEncryptionMigration
     .opens(_:key:)` (a read probe); `readRecord`/`writeRecord` through a THIN keyed GRDB connection over `protection_record`
     (never the migrator — the record is read before the app's open); `stageReencryption` = `sqlcipher_export` into
     `variorum.sqlite.staged` beside the slot (`StoreEncryptionMigration`'s measured road); `stageCopy(copyID:opener:to:)`
     the same from the catalogue copy's path; `copyOpens` a READ-ONLY probe on a private byte-copy of the catalogued file
     (13x's rule: a picked file is never written — the WAL/shm sidecars of a read-only open would write beside it);
     `stagedFingerprint` from a sidecar marker beside the staged file; `writeStagedRecord`; `swapStaged(setAside:
     asideKeyFile:)` = the WAL checkpointed, then the outgoing library AND its key file moved whole into `Previous
     Libraries/<stamp>/` (`CatalogNames.stampString`), then the staged file into the slot by an atomic replace;
     `discardStaged`; `createLibrary(with:record:)` = a fresh keyed file holding `protection_record` only; `exportPlaintext`
     = `StorePlaintextExport`. The container marker (`ProtectionFacts.containerMarker`) is today's "a library lived here"
     marker — trace `StoreLaunchRoute.resolve`'s `.libraryMissing` arm and reuse its source.
   - `FileKeyFileStoreLeaf: KeyFileStoreLeaf` — `ProtectionNames.keyFilename` beside the slot (atomic write, read-back
     verified); `catalogedKeyFiles(ofLibrary:)` = the catalogue lister's key files outside the live place whose
     `document.libraryID` matches.
   - `KeychainMemoryLeaf: MemoryStoreLeaf` — a device-only non-secret item per library ID under `memoryService` /
     `memoryAccount`, the `Sealed<DeviceMemory>` as the item's data; `rememberedLibraryIDs()` by attribute enumeration (no
     payload read); `deleteMemory`.
   - `FilePlanStoreLeaf: PlanStoreLeaf` — `ProtectionNames.planFilename` beside the slot, sealed bytes, atomic write.
   - `FileBackupsLeaf: BackupsLeaf` — `takeBackupPair` writes `Backups/<library8>/<mac8>/variorum-backup-<stamp>-<fp8>.sqlite`
     (a consistent snapshot by the road today's `StoreBackup` uses — read its copy step and reuse the mechanism, not the
     file) and its frozen `….keys.json` beside it, under the container's `Backups/`; `writeSendPair` to a picked folder
     (VX-309's door; minimal); `deleteCopies(ids:)` by catalogue id (the pair); `pauseCopies`/`resumeCopies` an in-process
     flag the U1b hook honours. Today's flat `Backups/variorum-backup-<stamp>.sqlite` writer is UNTOUCHED (Release parity;
     VX-348 owns `StoreBackup.swift`/`BackupRetention.swift` this window — read them, never edit them).
   - `CatalogLister` (the facts gatherer's helper, not a leaf protocol): lists the container root (the slot's files,
     `Backups/…`, `Previous Libraries/…`, `Backups/safety-copies/…`) and the far folder (today's backup destination bookmark,
     resolved security-scoped; `Variorum/Backups/…` beneath it) as `CatalogEntry` values with every key file's bytes read,
     then `Catalog.build`. Today's flat backups and envelope files are NOT catalogued (rule 26, `CatalogNames` refuses them).
   - `SystemClockLeaf`, `SystemIDsLeaf` (UUIDs; a random 32-byte `StoreKey`; `AppleKeyMaterial`; a fresh `PassphraseKDF
     .Descriptor` by the existing minting; BIP-39 words by the existing recovery-words code today's envelope uses — find
     it, never a second word list), `LAEnvironmentBiometryLeaf` (`LAEnvironment.current` → hardware / enrolled / the
     transient reasons, the Apple facts §5; macOS 26 / iOS 26 only), `AppDiagnosticsLeaf` (the app's existing diagnostics
     log seam; never key material — act names, step names, eight-character fingerprints).
   - `ProtectionFactsGatherer` — `ProtectionFacts` from the leaves + the session + the catalogue, mirroring the world's
     `SWorld.facts(_:)` (`Tests/VariorumCoreTests/Protection/Scenario/World.swift:841`): before unlock `unlocked == nil`,
     `slotFingerprintHint` from the live key file, `custodyOpensLibrary` = each SILENT item's key tried against the slot
     (the round-2 NIT: an item the leaf could not READ has its fingerprint INCLUDED — could-not-read is not verified-fails),
     `rememberedKeyFileCopies` from the memory items' payloads read WITHOUT verifying (a key file holds no secret),
     `appleKeys.readable`, `biometry`, `session` (today's sign-in → `SessionFact`), `vault` nil this phase, `catalog`,
     `now`; after unlock the `UnlockedFacts` from the `UnlockedLibrary`.
   - `ProtectionSystem` — the composition root: `ExecutorLeaves` for a scope + slot URL + far-folder bookmark;
     `ExecutorConfiguration` (scope = the store variant's raw value; `libraryID` from the live key file, else `""` until
     unlock names it; `deviceName` = the Mac's localized host name; the real `PassphraseKDF.floor`; the session). Nothing
     in `AppBootstrap` calls it yet — that is U1b.
5. **Tests — the Mac test target, `App/Variorum/VariorumTests/Protection/`**, one suite per leaf plus the gatherer: a
   THROWAWAY keychain scope per test (`vx306-<uuid>` — the tripwire refuses the real scopes under tests; each test deletes
   its items in `defer`), temp directories for the file leaves; each leaf's contract pinned by round-trips, and the
   composition proven once end to end on a temp slot: `createLibrary(passphrase:)` → the words → `unlock` → `assess` →
   `.open` with the four remembered things written. The gatherer's facts pinned from planted state: a silent item whose key
   does not open the slot is NOT in `custodyOpensLibrary`; one that cannot be read IS; a Touch ID item is counted and never
   pressed by the listing; the memory enumeration reads no payload. A Touch ID item's PRESS is not testable headless —
   record it as the walk's row (U1b). `xcodebuild build-for-testing` (no stage) before the record; the record names the
   exact suites and ends PENDING — the ORCHESTRATOR runs them under a stage claim and flips the counts.

**U1a evidence:** `swift test` — the protection set and the full core suite green in BOTH configurations (`-c release`
too; VX-380's one Sync test is the known release red); the VX-390 pin red-on-old; the Mac Protection suites green under
the stage; the diff touches `Sources/VariorumCore/Protection/`, `Persistence/Migrations.swift` (+ the schema value),
`Sync/SyncSchema.swift` (ONE line: the local-only registration — the one `Sync/` file this phase touches, and only that
set), the Protection tests, and the new `App/Variorum/Shared/Protection/` folder + its Mac tests. Zero `Server/` lines.

#### U1b — THE LOBBY ON ROADS, DEBUG-GATED (one implementer session + the orchestrator's walk)

- **The gate, ONE switch:** `ProtectionRoad.newRoadIsLive` — `true` under `#if DEBUG`, `false` otherwise — read at the head
  of `AppBootstrap.routeAndOpen`. Release runs today's road byte-unchanged. **The Release check (gate item):** a pin that
  the switch reads `false` outside DEBUG (compile-time), the existing route tests green with the switch forced off (a test
  override), and `xcodebuild -scheme Variorum -configuration Release build` green (no install, no launch — the Release
  product's scope is the REAL store; it is never opened this phase).
- **Under the new road** the route is: the gatherer's facts → `assess(facts)` → `LaunchVerdict`. `.startFresh` → the
  creation card: `createLibrary(passphrase: nil)` (rule 3: the passphrase is asked later; P-VX378-U3-1's door is the reset
  door's Standard road — its face is U2's reminder family / VX-308), the twelve words shown ONCE on §7c's card, the library
  then opens. `.libraryMissing` → today's three-door face, unchanged this unit (its Open Library / Restore doors retire
  behind Make this my library at U3). `.lobby` → `StoreLockView` rebuilt on `LobbyRoads` + `TouchIDAssessment`: the quiet
  roads tried AT ONCE and in order (every silent item, then the live key file's Apple wrap when its key reads here); with
  none (`asksASecretAtOnce`) the typed field at once; the typed roads = `LobbyRoads.typed` PLUS rule 1's keychain mirror
  and every catalogued key file of this library (the N5 hand-forward: the offer-era open), each key verified against the
  slot before `unlock(with:alsoInHand:)`; the vault road hidden (no vault this phase). A `recordMissing` refusal routes to
  the `libraryMissing` face with NO sentence about the store (P-VX306-K5 — rule 26: not handled, as if absent). After
  unlock the executor runs `assess`'s repairs (`refreshMemory`, `remakeOnDeviceItem`, `remakeAppleRoad`,
  `restoreKeyFileFromMirror` — the mechanism; the FACES of the notice, the offer and rule 27 are U2's) and the open
  continues into today's `openStoreOffMain` with the key in hand (`StoreKeyCustody.inMemory`). Today's dials
  (`ProtectionDials`, the stored Castle gate style) are not read on the new road: the device's settings are the record's
  section (`DeviceSettings`), and the lobby's demand is the assessment's.
- **VX-310 — the Touch ID button and line** from `TouchIDAssessment`: the button whenever a Touch ID item for the current
  key exists (`button`), the one automatic ask at open (`autoAsk`), a press that is only temporarily unusable says why and
  changes nothing (`pressSays` → "Open the lid…" / the keyboard / the lockout sentence), the quiet line otherwise
  (`quietLine`: *Touch ID isn't set up on this Mac* / *…for this library*), the changed line after a press fails on an
  existing item (`changedLine`), the re-arm question is VX-308's (not asked here — `rearmQuestion` rendered as nothing).
  The press reads the item through `readCustody(.touchid)`; a cancel is `TouchIDPress.cancelled`. Both bugs VX-310 names
  are pinned red-on-old on the new road's lobby model (the enrolled-finger fact and the button's persistence across a
  dismissed prompt).
- **Rule 1 on every open:** the memory item written by the executor's `refreshMemory` carries the key-file mirror — the
  four things — at the first open after creation (the walk checks the item exists under the dev scope).
- **Stage 3 exists on the new road (P-VX306-K4):** `StoreBackup.onRun` (the existing callback, `StoreBackup.swift:100`) is
  attached once under the new road to `takeBackupPair` through the leaf — every scheduled or Back Up Now run also lands a
  pair in `Backups/<library8>/<mac8>/`; `pauseCopies` is honoured. Zero edits to `StoreBackup.swift`.
- **The store identity:** a fresh library on the new road still mints today's store id beside the store (`StoreIdentity`;
  today's `startNewLibrary` road) so the rest of the app — sync custody keyed by store id, the dials, the backup log —
  keeps its own footing. Trace `startNewLibrary` and keep its mint.
- **The dev store's fresh start (P-VX306-K1) — the walk's step 0, the ORCHESTRATOR's hands under `vx-306-u1b-walk`:** zero
  instances; the pre-design dev store (`variorum.sqlite` + sidecars + its envelope file + the store identity file) copied
  WHOLE into `Backups/safety-copies/variorum-vx306-predesign-<stamp>/` inside the dev container (the A1 shape), then the
  slot emptied; the Debug app launched → `.startFresh` → the card → the library opens; the seeder mints the shipped
  furniture as on any fresh store. The dev scope's TODAY-road keychain items are left in place (the Release-road fence
  never reads the new names, and the new road never reads the old — rule 26). After this, any Debug build without this
  branch cannot open the dev store — the coordinator broadcasts it.
- **The walk (stages 1–3 and 5, both voices where a face changed):** 1 — the creation card, the words shown once, the
  library open, the memory item + silent item + Apple key item present under the dev scope (`security find-generic-password`
  for the device-only items; the Apple item by the app's own Diagnostics line), the key file beside the slot with its
  words lock; 2 — skipped (the passphrase door is U2's reminder / VX-308's); 3 — Back Up Now → a pair in
  `Backups/<library8>/<mac8>/` with its `.keys.json`; 5 — the on-device road's half: the SILENT item deleted by hand
  (`security delete-generic-password` on the dev scope), relaunch → the Apple wrap opens the library silently and the
  silent item is re-made (rule 8's `remakeOnDeviceItem`); the Apple-road-lost half is NOT walkable by hand (iCloud
  Keychain items are out of the CLI's reach) — it stands on `U2Rule8AssessTests`' pins, said so in the record. Then the
  lobby: quit, relaunch → silent open; the silent item AND the Apple item both gone → the typed field at once, the words
  typed → open; the Touch ID rows per VX-310 as far as this Mac's enrollment allows (the Pro has Touch ID hardware; the
  enrolled state is whatever it is — record it).

**U1b evidence:** the walk above with captures; the pins (the switch, the lobby model on `LobbyRoads`/`TouchIDAssessment`
from planted facts — pure, no keychain; VX-310's two red-on-old pins); the Release check; the Mac suites that exercise
every changed source file green under the stage.

### U2 — THE HONEST FACES: the notice, the offer, rule 27, rule 1's restore

The notice (rule 21; her two strings are the model's constants — `U4NoticeTests.herWordsAreTheModelsValues` — the face
shows them ONCE, then the library opens); the key-file offer naming its source ("This Mac's keychain holds a copy that
does. Use it?" / "The backup from <date> holds a key file that does. Use it?"; written only at her yes); rule 27's
refusal naming the places it looked and the account road; rule 1's mirror restore when the live key file is simply
absent (one quiet repair, said in a receipt); the rule-3 reminder's two model-side moments as a calm ask
(`CalmAsks`' idiom — before the first backup; after a quiet road failed; the launch-counted schedule is a LOCAL
counter beside them, `reminderDismissals` recorded through the op). Evidence: the walk of stages 13–14 on the dev
store (a hand-swapped older file → the notice; a wrong key file beside the library → the offer; everything gone →
rule 27); pins per face-state from planted facts.

### U3 — THE TWO DOORS: Look inside / Make this my library (+ the phone opens)

Look inside (read-only; the executor's `lookInside`; the face is a window that says it is a copy and writes nothing —
closing forgets) and Make this my library (one confirmed door; the executor's `makeThisMyLibrary`; the confirm says
"a new library, in <posture>, under your current pair; your current library steps aside into Previous Libraries";
the Restore from Backup button in Settings ▸ Data Safety IS this door — 13x's landing/adoption road retires behind it,
the restore HOLD kept as the sync gate it is), on a catalogued copy (a backup pair, a Previous Library) and on a picked
folder that is NOT catalogued (an AirDropped library — filed first, as the lifecycle's stage 10 does; T-5's empty-slot
landing and T-8's plaintext-export-in stay VX-309's unless small enough here — the orchestrator rules at kickoff).
The phone: the Debug road builds and opens the phone's fenced store (no faces beyond the lobby on the phone this
phase). Evidence: the doors used on the dev store with a real backup and an AirDropped copy; a byte-copy of her real
store opened by Look inside behind the A1 rail (her credentials typed by HER — never by a session); `U2LookInsideTests`
/ `U2MakeMineTests` extended for any face-side seam; the phone's open.

---

## 3. Standing acceptance: the words (VX-379)

Every face this phase ships is checked sentence by sentence against `CastleRules.md`; the field guide's **Start Here
chapter** is rewritten FIRST (your work is encrypted · write down your twelve words · set a passphrase · the Apple
road is a convenience that works forever for most people), then the Castle/backups chapters and Settings ▸ Data
Safety's copy for the faces built here. A sentence the build makes false is a regression (P-6 applied to the words).
Her taste calls on exact strings are sitting items; the model's constants (the notice strings) are hers already.

## 4. Hand-forwards into this phase (from VX-378)

P-VX378-U3-1 (which door sets the first passphrase — the reset door's Standard road as built; the card is the face) ·
P-VX378-U1-1 (a missing memory item mints a fresh device ID — the face never mentions it) · P-VX378-O1-1 (rule 5's
reading after a Standard Replace All Keys — the lifecycle says it; no face) · the N5 lobby-roads line (§2 U1) · the
rule-21 doors on a LIVE-PLACE stray are no longer offered (her ruling: the notice instead) — the only door there is the
offer. Open for her at this phase's sittings: the exact words of the once-shown words card, the notice window, the
offer, rule 27's refusal.

## 5. Risks

The real keychain's behaviour vs the fakes (apple-facts §6, §10, §12 — synchronizable items, biometry ACLs, the login
password's reach): every custody path pinned on the throwaway dev scope; the `KeychainTestTripwire`. 13x's Open Library
retiring behind Make this my library: the restore HOLD's sync gate must survive (the hold marker beside the store; the
Resume Sync press). The dev store's one-way door: a Debug build from a branch cut before this merge cannot open a dev
store this build has written — coordinators told.

## 6. LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- KICKOFF 2026-10-18 (her rulings §7; the orchestrator's provisional rulings §7b; the words drafts §7c): DONE — worktree
  `~/dev/variorum-vx-306`, branch pushed, the in-flight row on main (`99d49fc4a`, holds the Sync/-or-custody slot),
  VX-306 In Progress, the coordinator (`oct18coordinator`) announced and the slot granted explicitly.
- U1a — the production leaves (+ VX-386 first, the `protection_record` migration, VX-390): IN-PROGRESS (Opus implementer, 2026-10-18) — the U1a RECORD in §9 carries the per-piece status.
- U1b — the lobby on roads, Debug-gated (+ VX-310, the creation card, the Release check, the dev store's fresh start): not started.
- U2 — the honest faces: not started.
- U3 — the two doors; the phone opens: not started.
- The ladder (Fable — custody code; her cap: up to five rounds while MAJORs are still found): not started.
- Closeout: the words checked (VX-379's first pass — the Start Here chapter §7c); canon: AppSpec §12's LIBRARY
  PORTABILITY line (the doors replace 13x's landing wording); the handoff with HER-HANDS items (Look inside on a byte-copy
  of her real store with her credentials; the real store's field-guide re-seed); VX-307's plan written to the rules (the
  crossings' faces; the `key_vault` lockstep — the mirror deploy ONLY at her explicit go).

---

## 7. HER KICKOFF RULINGS (2026-10-18, verbatim — the `/architect-phase vx-306` invocation)

> CAST: the standing default — Fable orchestrates and cold-reviews (fable-reviewer), Opus implements (opus-implementer),
> both at xhigh. Rider: if a Fable review stalls on an overactive safeguard, watch for it and run an opus-reviewer round
> instead. Every change on a keychain or custody path is Fable-reviewed.
> LADDER: up to five rounds while MAJORs are still found.
> MODE: through to close. Overnight mandate: do not stop for questions — rule provisionally with options and why, build
> the most rule-defensible, mark PROVISIONAL, bundle everything for my morning read. Stop only for a rule that cannot
> hold or for something that needs my hands.
> SIZING: the three-unit shape as planned (U1 the lobby on roads, U2 the honest faces, U3 the two doors + the phone
> opens) is accepted.
> WORDS: the once-shown words card, the key-file offer, rule 27's refusal and the Start Here chapter — draft them from
> notes/CastleRules.md and the lifecycle page, build as drafted, PROVISIONAL, bundle for me. The notice's two strings are
> already mine; use them exactly.
> U1 SCOPE, do not drop: VX-386 (the three deferred residues) is this phase's FIRST commit, and VX-390 (stamp the library
> ID on every custody item and Apple key; Castle entry sweeps this library's silent items and Apple keys by the stamp; the
> pin replays the gate's seed 3 with the catalogue leaf off) lands in U1 beside the production keychain leaf. Both are in
> the plan's U1 section; both are Pre-launch.
> STAGE AND DEV STORE: the coordinator is oct18coordinator — announce yourself to it as vx-306 before your first
> xcodebuild test or walk, and hold a stage claim for each. The dev store converting to the new system on first open is
> APPROVED; do not wait for other sessions' walks. The other live sessions have been told to merge main into their
> branches before any walk, so the dev store and the stage are shared.
> SLOT: this phase holds the one Sync/-or-custody slot (say so in its in-flight row). The server's key_vault change stays
> VX-307's lockstep — no Sync/ line here.
> MY HANDS, morning only: Look inside on a byte-copy of my real store with my credentials typed by me; anything that would
> touch the real store. Leave these in the handoff checklist.
> RELEASE: no /Applications refresh this phase (Debug-only road); the gate item is that a Release build still runs today's
> road.

**One reading of "no Sync/ line":** U1a's `protection_record` registration adds ONE table name to
`SyncSchema.localOnlyTables` (`Sources/VariorumCore/Sync/SyncSchema.swift`) — the local-only registry, the way the MCP
grants family and the search index were registered; it carries nothing to the wire and changes no protocol line. The
orchestrator reads her "no Sync/ line" as "no protocol/engine/server change" and lets this one registry line through,
Fable-reviewed as every custody line is (P-VX306-K6 — her eye at the bundle; if she reads it strictly, the registration
moves to a local-only registry outside `Sync/` in one commit).

## 7b. THE ORCHESTRATOR'S KICKOFF READING AND PROVISIONAL RULINGS (2026-10-18, overnight — bundled as QUESTIONS #232)

- **P-VX306-K1 — how the dev store "converts" (her approval: "the dev store converting to the new system on first open is
  APPROVED").** Rule 26 is explicit: stores from before this design are neither migrated nor handled; everyone with one
  "exports their writing or signs into sync before the switch, then starts fresh" — and the considered-and-not-pursued
  list retires migrating-or-refusing-with-a-message. Options: (a) **BUILT, PROVISIONAL — the dev store takes rule 26's own
  road:** at U1b's walk the pre-design store is set aside whole (a safety copy in the dev container, the A1 shape) and the
  slot recreated fresh through the new road's creation (the lifecycle's stage 1 — the walk begins there anyway; the seeder
  re-mints the shipped furniture; the dev store "holds only replaceable content", CLAUDE.md); (b) a Debug-only conversion
  road writing a record and a format-3 key file around the existing key (keeps today's Debug builds opening it too — the
  neighbourly option — but it is exactly the migration machinery rule 26 and the not-pursued list retired, Debug-gated or
  not); (c) wait for the other sessions' walks to end before converting (her word: don't). Built (a): zero machinery,
  rule-honest, and the walk's stage 1 is real. Cost accepted at her word: after the conversion a Debug build without this
  branch cannot open the dev store (the coordinator broadcasts the moment; VX-382/VX-348 fold main after this phase
  merges or walk on their own scratch stores).
- **P-VX306-K2 — sizing: U1 runs as TWO implementer sessions (U1a the leaves, U1b the lobby).** Her accepted three-unit
  shape stands — three acceptance units, each with its own evidence; the fourth SESSION is the kickoff finding that no
  production leaf exists (§2 U1). The guidance's "one unit per implementer session" is read as one unit per session, not
  one session per unit; said here, as the guidance asks, rather than proceeding silently.
- **P-VX306-K3 — the vault and the sync keys this phase.** The server's `key_vault` keeps its pre-rules shape until
  VX-307's lockstep, so the production `VaultLeaf` is UNREACHABLE (every call throws): nothing synced can run on the new
  road, and a library created here binds no account. Sync itself keeps running on today's custody (`SyncCustodyRecord`
  and its provider), untouched in every configuration. Options rejected: a vault leaf over today's row shape (it would
  model two vault shapes at once — the very thing VX-378 U2 replaced whole); binding the account at creation (sync setup
  is VX-308's door and types the pair up — rule 7). Consequence for the walk: the fresh dev library is local-only under
  the protection core while the app's sync (if the dev store is signed in) stays on today's keys — two systems beside
  each other for exactly this phase, said plainly in the handoff.
- **P-VX306-K4 — stage 3 on the new road.** No backup door is this phase's by name, but the walk's stage 3 ("your first
  backup") and U3's "the two doors used on a real backup" need a pair the catalogue can read. Built: `StoreBackup.onRun`
  — the existing after-every-run callback — attached once under the new road to the leaf's `takeBackupPair`, so a
  scheduled run or Back Up Now also lands `Backups/<library8>/<mac8>/<snapshot> + .keys.json` (the catalogue's layout).
  Today's flat backup keeps being written beside it (Release parity; VX-348's files untouched). Option rejected: teaching
  today's writer the pair (an edit inside VX-348's fenced files, and a second backup writer in Release).
- **P-VX306-K5 — a store with no protection record on the new road** (`ExecutorRefusal.recordMissing`; her word: "no
  refusal string either"). Built: it routes to the `libraryMissing` face — the lock stays, the three doors (Restore from
  Backup, Open Library, Start a New Library) — with NO sentence naming the store: rule 26's "not handled", as if absent.
  Options: (b) a blank lobby with no doors (unusable, and the face would still exist); (c) a sentence ("this library is
  from before…") — her word says no.
- **P-VX306-K6 — the one `Sync/` line** (§7's note): the local-only registration of `protection_record` in
  `SyncSchema.localOnlyTables`. Built; her eye.
- **P-VX306-K7 — the words card has no Copy door and no "later" door.** Rule 2: shown once, "write these down now". The
  card's one button ("I've written them down") opens the library; the words are never shown again; the clipboard never
  holds them. Options: a Copy button (a plain-text secret on the clipboard — against the one sentence's spirit); a "show
  me later" (there is no later — the words are never stored). Built as the strictest reading; her taste call on the words
  themselves (§7c).
- **The reviewer rider:** "if a Fable review stalls on an overactive safeguard, run an opus-reviewer round instead" —
  applied per round at the orchestrator's watch; a stalled Fable round is recorded as such in §9 and the Opus round takes
  its number (every keychain/custody line still gets a Fable read before the ladder closes — her first sentence).

## 7c. THE WORDS (drafted from `CastleRules.md` and the lifecycle page; built as drafted; PROVISIONAL — hers at the bundle; sentence case throughout, her no-shouty-caps rule)

**(1) The once-shown words card** (stage 1; rule 2; the creation's one face):
- Title: *Your twelve words*
- Lead: *Your library is encrypted. These twelve words open it — on this Mac, on any copy of it, for as long as they are
  its words. Write them down now and keep them somewhere safe. Variorum won't show them again.*
- The twelve words, numbered, in two columns.
- Foot: *You can add a passphrase later, as a convenience over the words. Either one can reset the other.*
- One button: *I've written them down* → the library opens.

**(2) The key-file offer** (rule 21; her sentences are the model's — `KeyFileOffer.besideDoesNotOpenIt` +
`keychainHoldsOne` / `backupHoldsOne` verbatim): a sheet over the lobby reading her sentence — *The key file beside your
library doesn't open it. This Mac's keychain holds a copy that does. Use it?* / *… The backup from <date> holds a key file
that does. Use it?* — with *Use it* and *Not now*. On yes the receipt reads *Key file restored from this Mac's keychain.*
/ *… from the backup from <date>.*; on *Not now* nothing is written and the lobby stays (the typed roads of the file that
does open it remain offered). The history-only split pair (P-VX378-U4-6 (a), `.besideOpensItOnlyThroughItsHistory`) reads
*The key file beside your library is an older one. It opens the library, but the quiet roads can't be re-made from it —
Restore from Backup puts the right one back.*

**(3) Rule 27's refusal** (`NoKeyFileAnywhere`): *No key file opens this library. Variorum looked beside the library,
inside every backup, and in this Mac's keychain, and found none that opens it. Without one, there is nothing left to
open.* When the account road is named: *This library syncs with your account. Sign in and enter your passphrase or twelve
words to bring your writing back.* Doors beneath: *Restore from Backup…* · *Open Library…* (and *Start a New Library* as
on the missing face).

**(4) The notice** (rule 21; her two strings EXACTLY, the date written in by `LibraryNotice.sentence(date:)`): a quiet
one-line sheet at the open — *This is an older copy of your library, from <date>* / *This is a different library than the
one this Mac last had open* — with one button, *OK*; shown once, then the library opens and this Mac remembers this one.

**(5) The Start Here chapter** (the field guide's first chapter, rewritten first — VX-379; four short passages):
> **Your work is encrypted.** Every library is locked with its own random key, kept in a small key file beside it.
> Variorum keeps copies of that key file for you — beside the library, inside every backup, and sealed in this Mac's
> keychain — so you never have to think about it.
>
> **Write down your twelve words.** Every library has twelve words from the moment it is made, and they open it for as
> long as they are its words. They were shown once, when the library was created. If you didn't write them down then,
> you can make new ones in Settings ▸ Data Safety — and write those down.
>
> **Set a passphrase.** A passphrase is a convenience over the words: easier to type, and either one can reset the
> other. Until you set one, Variorum reminds you now and then.
>
> **The Apple road is a convenience.** In Standard, Variorum also keeps quiet roads to your key — through your iCloud
> Keychain and this Mac's login — so most people never type anything, and for most people that simply works forever.
> If it ever stops, your passphrase or your words open the library, and nothing was ever at risk. Castle is the one
> promise that there is no quiet road through Apple, ever; it is a choice you can make in Settings.

## 8. ENVIRONMENT TRAPS AND THE BATCH PROTOCOL (carried verbatim into every brief)

- **Where your code goes (U1a):** `Sources/VariorumCore/Protection/`, `Tests/VariorumCoreTests/Protection/`, the one
  migration in `Sources/VariorumCore/Persistence/` (+ its schema value), the one registry line in
  `Sources/VariorumCore/Sync/SyncSchema.swift`, and the new `App/Variorum/Shared/Protection/` + `App/Variorum/VariorumTests/
  Protection/`. Nothing else in `Sync/`; nothing in `Server/`; nothing in `AppBootstrap`/`StoreLockView` (U1b's).
- **The stage:** you never claim it and never run `xcodebuild test` — `swift build`/`swift test` headless and `xcodebuild
  build-for-testing` are free; the orchestrator runs the Mac suites under a coordinator-granted claim after your record
  ends PENDING. You never launch the Debug app, never touch the dev store, never touch the real store or `/Applications`.
- **Keychain under tests:** the real scopes (`Variorum`, `Variorum-dev`) are refused by `KeychainTestTripwire` in a test
  process — every test plants under a THROWAWAY scope `vx306-<uuid>` and deletes its items in `defer`; every new keychain
  mutation calls `refusesRealScopeMutation` first. The signed test host has the keychain identity; a `swift test` process
  does not — keychain-touching tests live in the Mac target only.
- **Instance checks** use `pgrep -fl 'Variorum.app/Contents/MacOS'` and discriminate by PATH; a real-store instance is
  NEVER quit or killed; no Release build or `/Applications` refresh this phase at all.
- **Builds:** Mac tests from `App/Variorum/` with suite-level `-only-testing`; the "Test run with N tests" line is the
  count (skipped tests count — read the `skipped:` lines); NEVER a custom build configuration (anything not named exactly
  "Debug" builds the packages Release and strips the DEBUG oracles — the mutation pins and the guards' off-switches);
  `swift test -c release` for the release leg (VX-380's one Sync attacker test is the known red there).
- **DerivedData** for this phase under `App/Variorum/DerivedData/vx306/` (gitignored; deleted at closeout).
- **Red-on-old** runs use a scratch worktree at the piece's parent commit with the pin file copied in (VX-378's road);
  remove it when done; `git worktree list` must show no stray at your record's close.
- **Checkpoint rules (binding from the first commit):** commit per coherent piece and push after each (`git pull
  --rebase` first); this plan's LIVE STATUS and your unit's record flipped in the same commit as each piece; every
  unverified claim PENDING; synchronous foreground waits only (poll a log with `grep -q … && break; sleep 5`, never
  `tail -f`); no `Co-Authored-By` trailer; `Part of VX-306` (or the member's number) in every message; at most ONE Sonnet
  lookup subagent at a time, external facts only; reading never delegated.
- **The stop rule (VX-378's, carried):** a rule that cannot be built as written, two rules that conflict in code, or a core
  aim the model cannot meet — STOP that unit at a clean seam, record the trace in §9, commit, report. Never patch the design
  silently.

## 9. RECORDS (each unit appends: what shipped / counts both configurations / PROVISIONALs / commits / notes)

### U1a RECORD — THE PRODUCTION LEAVES (Opus implementer, 2026-10-18; IN PROGRESS)

**Not done in U1a, first:** PENDING (filled at the close).

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 1 — VX-386, the three residues (`PlanRunner` guard-off resume's `catch ActRolledBack`; `U4PromiseCheckTests
  .onePostureStillCatchesAFollowedSyncedDevice`; `Promises.swift` L1's parenthetical): DONE (this commit) — the
  protection set's counts in both configurations PENDING (run at the unit's close).
- Piece 2 — the `protection_record` LOCAL-ONLY migration `v1_30_protection_record`: DONE (this commit) —
  `Persistence/ProtectionRecordSchema.swift` (the ONE DDL value + the one-row codec: a write replaces every row, a
  read of two refuses `moreThanOneRecord`), the migration, the ONE `Sync/` line (`SyncSchema.localOnlyTables`), the
  `LocalMachineryRecreation` map entry (the shared value, re-created EMPTY), `MigrationTests.expectedTables` (the
  ritual's justified edit); `ProtectionRecordSchemaTests` (5). The schema-touching suites `✔ 103 tests in 12 suites`
  (Debug; the both-configuration counts PENDING at the close).
- Piece 3 — VX-390, the library-ID stamp + the fakes + the seed-3 pin (catalogue leaf empty), red-on-old: DONE (this
  commit). **Core:** `CustodyItemFact.libraryID` (the stamp; equality and hashing stay the item's NAME — fingerprint +
  class — so every `contains(CustodyItemFact(fp, class))` site keeps its meaning); `CustodyLeaf.writeCustody(_:itemClass:
  libraryID:)`, `AppleKeysLeaf.addAppleKey(_:libraryID:)` + `appleKeyIDs(ofLibrary:)` (attributes only, readable or
  not); every write passes the library it is FOR (`ActContext.stampLibraryID` — Make this my library's NEW library ID,
  else the library in hand; the creation, the repairs); Castle entry's shared steps (`CommonSteps.retireOldCustody
  (sweepForCastle: true)` — every SILENT item stamped with this library goes; `retireOwnAppleKeys` — every Apple key so
  stamped, under the existing `everyOwnKeyRetiredAtCastle` guard) cover Use Castle, the follow into Castle and the join
  into Castle; the catalogue sweep stays as the belt; sync-keys items and another library's items untouched. **Fakes
  stamp first:** `ExecutorWorld` (custody facts carry the stamp; `ICloudKeychain.stamps`), `ExecutorFixtures`, the
  scenario world (`KItem.libraryID`; `truth.appleKeyMintedOn`); the knob `SWorld.catalogedKeyFilesAnswerEmpty`.
  **Promise 1's stamp clause** (`Promises.entrySurvivors`, judged at each entry once nothing is in flight —
  `judgeCastleEntries`, wired into `step`): a stamped silent item or an Apple key THIS Mac made for the library
  surviving the entry is a violation; an unstamped one outside the key file's keys stays rule 25's stated limit.
  **Pins:** `U4GatePins.theStampAloneTakesTheRolledBackStretchsItemsAtCastleEntry` (the gate's seed 3 with the
  catalogue leaf answering empty) — RED on the pre-piece tree (scratch worktree at `d5642b5fa` + the pin file + the
  knob alone: `✘ Test run with 4 tests in 1 suite failed after 0.137 seconds with 1 issue`, at `U4GatePins.swift:86`,
  the violations promise 1 on macB "a quiet road reaches an earlier key 412b37b4" / "…b1df64c8" / "a quiet road opens
  the copy …-412b37b4.sqlite" — seed 3's own), GREEN after; `U4PromiseCheckTests
  .theStampClauseCatchesAStampedSurvivorAndLeavesAnUnstampedOne` (the clause's oracle) and the DEBUG mutation pin
  `ScenarioMutationPins.theStampedAppleKeyGoesAtEntry` (the step-level wiring; guard off ⇒ the clause fires). Protection
  set Debug `✔ Test run with 309 tests in 76 suites passed` (every `@Test` under `Tests/VariorumCoreTests/Protection`);
  a sample soak, seeds 1–3 × 350 sequences, Debug: `✔ Test run with 1 test in 1 suite passed after 414.916 seconds`
  (the new clause raised nothing). Rule 25's last sentence stays until her word. Release counts PENDING at the close.
- Piece 4 — the thirteen production leaves + `CatalogLister` + `ProtectionFactsGatherer` + `ProtectionSystem` under
  `App/Variorum/Shared/Protection/`: NOT STARTED.
- Piece 5 — the Mac tests under `App/Variorum/VariorumTests/Protection/` + `xcodebuild build-for-testing`: NOT STARTED.

