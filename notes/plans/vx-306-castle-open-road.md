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

- **Hand-forwards from U1a (read its §9 record first):** `KeychainCustodyLeaf.lastPress` is the lobby's `TouchIDPress`
  fact (`ProtectionSystem.facts` reads it); `FileBackupsLeaf.copiesArePaused` is what the `onRun` hook honours; the
  "library lived here" marker is the file `variorum-library-lived-here` beside the slot, written by `createLibrary`
  (P-VX306-U1a-1); a non-format-3 file in the live place makes `unlock` THROW (P-VX306-U1a-2 — the route must catch it and
  show the lobby with the typed roads, never crash; U2 gives it a face); an unlistable keychain makes gathering throw
  (P-VX306-U1a-3 — the route catches `GatherError` and shows the lobby's typed field with a one-line reason, PROVISIONAL);
  Touch ID items are found by name over `touchIDCandidates` (P-VX306-U1a-5 — the composition root feeds them); the
  composition root is `ProtectionSystem` (compose it once per open on the main actor; `deviceName` is main-actor on iOS).
  The dev scope's store variant raw value is the scope (`AppDatabase.StoreVariant.dev` = `Variorum-dev`).
- **The walk's Touch ID rows settle U1a's one Unknown:** whether the non-prompting existence probe truly never prompts
  with a real `.biometryCurrentSet` item present — the walk makes a Touch ID item impossible this phase (no Castle entry),
  so the row reads: with NO Touch ID item, the lobby shows no button and the quiet line; the probe's no-prompt claim
  stays on `KeychainLeavesTests.aTouchIDItemIsListedByNameAndNeverPressed` where a finger is enrolled. Say which in the
  record.

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

**U2 brief addendum (the orchestrator, 2026-10-18, after U1a — read with the U2 paragraph above):**
- **Where the faces go:** a new Mac feature module `App/Variorum/Variorum/Features/Protection/` (the notice sheet, the
  offer sheet, rule 27's face, the reminder's calm ask, the set-passphrase sheet); the WORDS in ONE cross-platform file
  `App/Variorum/Shared/Protection/ProtectionWords.swift` (the phone reuses them at U3), each string exactly as §7c drafts
  it — the notice's two sentences are the MODEL's constants (`LibraryNotice.olderCopyWords`/`differentLibraryWords`,
  hers; the face never restates them).
- **The notice** consumes `UnlockedLibrary.notice` at the open (U1b hands it through the route) — shown ONCE as §7c (4),
  then the library opens; the executor's `refreshMemory` repair has already made this Mac remember this one.
- **The offer** is `OwedAct.offerKeyFile` → `ProtectionExecutor.searchKeyFiles(_:catalog:typed:)` (a READ) → `KeyFileOffer`
  rendered by §7c (2) → her yes = `useOfferedKeyFile` (the act `.useKeyFile` on a plan); *Not now* writes nothing. The
  split pair (`.besideOpensItOnlyThroughItsHistory`) reads §7c (2)'s last sentence. The `.noKeyFileAnywhere` answer of
  the search is rule 27's face.
- **Rule 27** has two moments: before unlock `LobbyRoads.noKeyFileAnywhere` (the lobby's face per §7c (3), its doors
  the missing face's); after a quiet-road open `Fault.noKeyFileAnywhere` (a standing banner on the open library in the
  same words, minus the doors — nothing rebuilds a key file from the key).
- **Rule 1's restore** is `Repair.restoreKeyFileFromMirror`, run by the executor's `runRepairs` at the open (U1b wires
  the pass) — U2 gives it its RECEIPT on the status seam: §7c (6).
- **Rule 3's reminder:** `OwedAct.askPassphrase(.beforeFirstBackup)` / `(.quietRoadFailed)` are the model's two moments;
  the launch-counted schedule (the third launch, then weekly twice, then with "don't show again" — rule 3) is a LOCAL
  counter beside them on `CalmAsks`' cadence (`Features/CalmAsks/CalmAsks.swift`); a dismissal is recorded through
  `recordPassphraseReminderDismissed` (one record write); the words are rule 3's sentence in sentence case (§7c (7)).
  The ask leads to the SET-PASSPHRASE sheet — P-VX378-U3-1 (a)'s road, `resetPassphrase(_:.plainConfirm, …)`
  (`Acts/KeyDoors.swift:125`): a new passphrase typed twice, nothing else asked (Standard: this Mac holds the key); the
  sheet refuses when a passphrase already exists. Built here so the reminder leads somewhere and stage 2 walks —
  **P-VX306-U2-0 (the orchestrator's provisional ruling):** options (a) BUILT — the minimal sheet on the reset door's
  Standard road; (b) wait for VX-308's key doors (a reminder leading nowhere); (c) Change Passphrase accepting none
  (P-VX378-U3-1 (c), a model change). The tutorial's last card (the lifecycle's stage 2 as her sitting had it) is NOT
  rewritten here — the sheet is reachable from the reminder and from Settings ▸ Data Safety's protection pane under the
  new road.
- **Evidence (the orchestrator's walk, `vx-306-u2-walk`):** stage 2 (the ask → the sheet → the key file gains a
  passphrase lock → the lobby's typed roads now say passphrase), stage 13 (a key door interrupted — NOT walkable without
  a crash harness in the app; stands on the core's crash harness, said so), stage 14 (a hand-swapped OLDER dev-store
  pair → the older-copy notice; a stray key file beside the library → the offer naming this Mac's keychain; everything
  gone → rule 27's face), rule 1's restore (the live key file moved away by hand → the receipt and the file back).

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
- U1a — the production leaves (+ VX-386 first, the `protection_record` migration, VX-390): DONE 2026-10-18 — commits
  `82e4ad038`…`e3d623d3a` (the §9 U1a RECORD); main folded `bfc9f85c4` (VX-381 + VX-382 in; the bundle renumbered #233);
  the six Mac suites run by the orchestrator under `vx-306-u1a-batch` (07:06 MDT): `✔ Test run with 28 tests in 6 suites
  passed after 0.387 seconds.` (0 skipped — the Touch ID listing row ran on the Pro's enrolled finger), `** TEST EXECUTE
  SUCCEEDED **`; the tripwire's own suite proved every real-scope mutation refused from the test process. VX-406 filed
  (the release-floor reds, Low). The ladder reads U1a with U1b.
- U1b — the lobby on roads, Debug-gated (+ VX-310, the creation card, the Release check, the dev store's fresh start): BUILT 2026-10-18 (Opus implementer) — commits `fdda1a67b`…`cd00b20cb` + the record (§9 U1b RECORD); Release build green on the final tree, Debug `build-for-testing` and the phone build green, 27 of the new tests green HEADLESS; the Mac suites (the record's list) and the walk (K1's fresh start, stages 1, 3, 5, the lobby, Touch ID) PENDING — the ORCHESTRATOR's, under the stage.
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

## 7b. THE ORCHESTRATOR'S KICKOFF READING AND PROVISIONAL RULINGS (2026-10-18, overnight — bundled as QUESTIONS #233)

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

**(6) Rule 1's restore receipt** (`Repair.restoreKeyFileFromMirror`, a quiet repair): *The key file beside your library was
missing. This Mac's sealed copy was put back.*

**(7) Rule 3's reminder** (her sentence in rule 3, sentence case; the calm ask's one line + two doors): *Your library is only
secured through iCloud Keychain right now — please add a passphrase and keep your twelve words to ensure continued
access.* Doors: *Set a passphrase…* · *Not now* (and, at the third return, *Don't show again*). **The set-passphrase
sheet:** title *Set a passphrase*; lead *A passphrase is a convenience over your twelve words — easier to type, and either
one can reset the other.*; two fields (*Passphrase* / *Again*); one button *Set passphrase*; the receipt *Passphrase
set. Your twelve words still open the library too.*

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

### U1a RECORD — THE PRODUCTION LEAVES (Opus implementer, 2026-10-18; BUILT — the Mac suites PENDING under the stage)

**Not done in U1a, first:**
- **The Mac suites were NOT RUN** (the brief: no `xcodebuild test`, no stage) — only built (`build-for-testing` green).
  The orchestrator runs them under a coordinator-granted claim (the exact list closes this record) and flips the counts.
- **The opt-in iCloud suite** (`ICloudAppleKeysLeafTests`) writes a synchronizable throwaway item into her iCloud
  Keychain for moments (the `AppleKeyRoundTripTests` pattern) — run only by a deliberate choice
  (`TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1`); the composition test uses an in-memory Apple leaf instead.
- **A Touch ID item's PRESS is not testable headless** — the walk's row (U1b); so is the listing's no-prompt behaviour
  with a real Touch ID item present (`KeychainLeavesTests.aTouchIDItemIsListedByNameAndNeverPressed` runs only where a
  finger is enrolled on the test Mac).
- **Nothing wires the road** — `AppBootstrap`, `StoreLockView`, the `StoreBackup.onRun` hook, the Debug gate are U1b's.
- **The far folder's backup pair is not written** (P-VX306-U1a-4); Send Library's pair is minimal (VX-309's door).

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
  `App/Variorum/Shared/Protection/`: IN-PROGRESS.
  - 4a — the library file's mechanics in core, `Sources/VariorumCore/Protection/Files/ProtectionLibraryFiles.swift`
    (a recorded refinement: every SQLCipher statement the app's `LibraryFileLeaf`/`BackupsLeaf` need sits beside the
    ONE keying implementation, `AppDatabase.configuration(key:)`, instead of a second keying road in the app — and so
    runs headless in both configurations): the probe, the record's thin keyed connection (the write drains the WAL),
    `sqlcipher_export` into a fresh file under a new key (verified by row counts), the no-clobber creation, the
    same-key snapshot (the backup API), the private byte copy (a catalogued copy is never written), the WAL belt.
    `ProtectionLibraryFilesTests` (5) Debug green: DONE (this commit).
  - 4b/4c — the leaves, the lister, the gatherer, the system — `App/Variorum/Shared/Protection/` (16 files: the
    shared keychain family `ProtectionKeychain`; `KeychainCustodyLeaf` · `KeychainSyncKeysLeaf` · `ICloudAppleKeysLeaf`
    · `UnreachableVaultLeaf` · `SQLCipherLibraryLeaf` · `FileKeyFileStoreLeaf` · `KeychainMemoryLeaf` ·
    `FilePlanStoreLeaf` · `FileBackupsLeaf` · `SystemClockLeaf` · `SystemIDsLeaf` · `LAEnvironmentBiometryLeaf` ·
    `AppDiagnosticsLeaf`; `ProtectionPlaces`, `CatalogLister`, `ProtectionFactsGatherer`, `ProtectionSystem`):
    COMPILING (`xcodebuild … -configuration Debug build` → `** BUILD SUCCEEDED **`, zero warnings in the folder) — this
    commit; the Mac tests (piece 5) NOT STARTED; one external-facts lookup (the keychain's listing/press behaviour) in
    flight — its answers may adjust the keychain family.
- Piece 5 — the Mac tests under `App/Variorum/VariorumTests/Protection/` + `xcodebuild build-for-testing`: WRITTEN
  (this commit) — `ProtectionKeychainFamilyTests` (structural, no Keychain traffic) + the per-leaf tripwire test as an
  extension of the `.serialized` `KeychainTripwireTests` (its exact trip-count delta never interleaves) ·
  `KeychainLeavesTests` (throwaway scopes, purged in `defer`) · `ICloudAppleKeysLeafTests` (OPT-IN,
  `TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1`, the `AppleKeyRoundTripTests` pattern) · `ProtectionFileLeavesTests`
  (temp folders) · `ProtectionFactsGathererTests` (planted leaves) · `ProtectionSystemCompositionTests` (end to end);
  support `ProtectionTestSupport.swift`. `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration
  Debug -derivedDataPath App/Variorum/DerivedData/vx306 build-for-testing` → `** TEST BUILD SUCCEEDED **`; the phone
  target (`-scheme VariorumMobile -destination 'generic/platform=iOS Simulator' build`) → `** BUILD SUCCEEDED **` (the
  Shared folder compiles for iOS). The Mac suites' RUN is the orchestrator's under the stage — PENDING.

**THE KEYCHAIN FACTS THE LEAVES REST ON (the unit's one external lookup, Sonnet, read-only — sources: the macOS 27 SDK
headers, Apple's open-source Security repo, DTS; tags as it gave them):** (1) an attributes-only `SecItemCopyMatching`
over items carrying a `.biometryCurrentSet` ACL is GATED on the ACL [Src medium-high — `SecDbKeychainItem.m`
`ks_decrypt_data` decrypts whenever the access control has constraints]; under a non-interactive context ONE such match
fails the WHOLE listing with `errSecInteractionNotAllowed`, and with UI allowed the listing would PROMPT; `kSecUseAuthentication
UISkip` (NOT deprecated — `API_AVAILABLE(macos(10.11))`, SecItem.h) silently skips them [Header] — so a device-only
listing skips, and Touch ID items are found by name (P-VX306-U1a-5); (2) `kSecAttrLabel` is a stored, synced,
exact-match attribute [Src] (the leaves filter by it client-side anyway); (3) updating any attribute of an ACL'd item
re-encrypts it and would prompt [Src medium-high] — so a Touch ID item is never rewritten (an item already under the
key's name is kept); (4) deleting an ACL'd item needs no auth [Src + DTS]; (5) an un-evaluated `LAContext` with
`localizedReason` makes the read show the prompt; LA errors map to `errSecUserCanceled` (cancel), else
`errSecAuthFailed` (lockout, lid closed [Inf]); an enrollment change answers `errSecAuthFailed` or `errSecItemNotFound`
(Unknown on macOS) — both read as "failed on an item that exists"; (6) `kSecMatchLimitAll` with data is fine on the
data-protection keychain; (7) a synchronizable item must not be ThisDeviceOnly and cannot carry an ACL [Header + Src] —
`AfterFirstUnlock` is a sensible choice. The existence probe keeps today's MEASURED shape (an `interactionNotAllowed`
context; `errSecInteractionNotAllowed` means present — `KeychainPartition`'s 2026-08-30 measurement); whether the flag
survives the context's externalization is the lookup's one Unknown — the walk confirms no prompt (U1b).

**Counts (the final tree `e9bb71007` + this record):**
- The protection set (every `@Test` under `Tests/VariorumCoreTests/Protection` — 314 on the final tree), Debug
  (`swift test --filter 'VariorumCoreTests\.(<its 79 suite types>)/'`): `✔ Test run with 314 tests in 77 suites passed
  after 5.384 seconds.`; Release (`swift test -c release --filter <the same>`): `✔ Test run with 290 tests in 73 suites
  passed after 3.908 seconds.` (the DEBUG-only mutation pins excluded by construction).
- The full core suite, Debug (`swift test`): `✔ Test run with 3241 tests in 417 suites passed after 316.374 seconds.`
  (VariorumCoreTests); `✔ Test run with 40 tests in 6 suites passed` (StringsWorkbookTests); VariorumMCPTests `✘ 362
  tests in 68 suites … 2 issues (including 1 known issue)` — the one real issue `MCPHarnessTimeLimitTests
  .aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (a wall-clock bound, 20.09 s against 15 s, under the
  full parallel run on a shared machine) — alone: `✔ Test run with 3 tests in 1 suite passed after 2.208 seconds.`
  Untouched by this diff (no MCP line).
- The full core suite, Release (`swift test -c release`): VariorumCoreTests `✘ 3212 tests in 412 suites … 18 issues` —
  EVERY issue `PassphraseKDFError.belowFloor("memory 256 KiB is below the floor of 19456 KiB")` (the release floor is
  `.production` by construction; these legacy suites derive test-speed descriptors): `CorpusRotationTests` 12,
  `StoreKeyEnvelopeTests`/`StoreKeyEnvelopeFormat2Tests` 5, `MultiTenantSyncAttackerTests` 1 (VX-380's known red);
  StringsWorkbook `StoreUnlockTests` 2 (same class); MCP the same timing flake. **PRE-EXISTING, proven:** a scratch
  worktree at the kickoff commit `9eff28e3e` (pre-U1a), the same suites in release: `CorpusRotationTests` 12 +
  `StoreKeyEnvelopeTests` 3 (`✘ 32 tests in 2 suites … 15 issues`), `StoreKeyEnvelopeFormat2Tests` 2 (`✘ 10 tests in 1
  suite … 2 issues`), `StoreUnlockTests` 2 (`✘ 7 tests in 1 suite … 2 issues`) — the same tests, the same lines; the
  worktree removed. None is a protection suite and none touches this diff. **For the orchestrator:** the plan's "VX-380's
  one Sync test is the known release red" undercounts the release reds of the FULL suite — the `.belowFloor` class is
  wider and older (a ticket-worthy Tests & tooling debt, the orchestrator's to file).
- `swift build -c release` (the core in both configurations, rule 24): `Build complete! (99.74 sec)`.
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath
  App/Variorum/DerivedData/vx306 build-for-testing` → `** TEST BUILD SUCCEEDED **`; the phone target `-scheme
  VariorumMobile -destination 'generic/platform=iOS Simulator' build` → `** BUILD SUCCEEDED **`.
- A sample soak at piece 3 (seeds 1–3 × 350 sequences, Debug — the new stamp clause's false-positive check):
  `✔ Test run with 1 test in 1 suite passed after 414.916 seconds.`

**PROVISIONALs (each built as its option (a); bundled under QUESTIONS #233):**
- **P-VX306-U1a-1 — "a library lived here" (`ProtectionFacts.containerMarker`).** Traced as the brief asked: today's
  `.libraryMissing` arm (`StoreLaunchRoute.resolve(gate:presence:)`, `StoreLaunchGate.swift`) fires on a DEMANDED
  effective gate over an absent store — the gate derived from the 13p stored mode, today's envelope beside the store and
  the dials, every one a pre-design file the new road never reads (rule 26) — so nothing of it carries over. Options:
  (a) BUILT — the marker file `variorum-library-lived-here` beside the slot, written by `createLibrary(with:record:)`
  after the library lands (design §3.2's home; the scenario world's exact shape); (b) the live key file beside an absent
  slot (today's source restated — misreads a creation that crashed between the key file and the library as a MISSING
  library); (c) either.
- **P-VX306-U1a-2 — a file in the live place that is not a format-3 key file THROWS** (`unreadableLiveKeyFile`), so
  `unlock` throws on it. Options: (a) BUILT — throw (rule 21: whatever sits there is never overwritten, and a nil would
  let the mirror repair write over it); (b) nil; (c) move it aside first. U2's face will meet it.
- **P-VX306-U1a-3 — an unlistable custody or memory keychain makes gathering THROW** (`GatherError`), never "no road" —
  rule 27's refusal stands on those listings; the sync-keys and Apple listings fall back to empty (neither feeds rule
  27). Options: (a) BUILT; (b) empty everywhere (a transient keychain error could show rule 27); (c) a per-fact
  "unknown" (a core facts change).
- **P-VX306-U1a-4 — backup pairs land in the CONTAINER only** (`Backups/<library8>/<mac8>/`); the far folder's pair is
  not written this phase (the scenario world writes both; today's second leg still copies its own flat files there).
  Options: (a) BUILT; (b) both, through today's destination; (c) the far folder only when one is picked and in reach.
- **P-VX306-U1a-5 — Touch ID items are listed BY NAME** over the fingerprints this device knows of (every catalogued key
  file's keys, the memory items' keys, the plan's two, the staged one, every silent item's), since a listing that does
  not skip them would prompt or fail whole (the keychain facts above). A Touch ID item for a key nothing here names is
  not listed (it opens nothing this Mac can reach; it is no quiet road — rule 9), and lists unstamped. Options: (a)
  BUILT; (b) a listing that may prompt (the plan forbids it); (c) a separate service or an index item for Touch ID items
  (a core names change). The sync-keys leaf probes the same way (its candidates are VX-308's to wire).

**Recorded refinements (not product calls):** the SQLCipher mechanics live in core `Protection/Files/
ProtectionLibraryFiles.swift`, beside the ONE keying implementation (`AppDatabase.configuration(key:)` is internal —
the app would otherwise need a second keying road), and so run headless in both configurations; `CustodyItemFact`'s
equality and hash stay its NAME (fingerprint + class) with the stamp an attribute, so every existing `contains` site
keeps its meaning; the plan's protocol shapes are as written (no other protocol change).

**Hand-forwards (U1b and later):**
- `KeychainCustodyLeaf.lastPress` is the lobby's `TouchIDPress` (cancelled · failed on an item that exists · unusable
  for now — the transient reason re-read after the press); `ProtectionSystem.facts` reads it by default.
- `FileBackupsLeaf.copiesArePaused` is what the `StoreBackup.onRun` hook honours (P-VX306-K4).
- THE SWAP: `SQLCipherLibraryLeaf.swapStaged` refuses while a WAL with frames sits beside the slot (`walNotDrained`) and
  removes the slot's sidecars before ONE atomic rename — the act's caller MUST CLOSE THE APP'S POOL on the slot and
  quiesce writes from the stage to the swap (`writeRecord` and `stageReencryption` drain the WAL); set-aside is a hard
  link into `Previous Libraries/<stamp>/` first, so the slot is never empty (a crash after the link and before the
  rename leaves a duplicate aside copy of the live library — harmless, listed as a Previous Library). Make this my
  library (U3) meets this first.
- The phone: `ProtectionSystem`'s default `deviceName` reads `DeviceName.current` (main-actor on iOS) — compose on the
  main actor or pass the name (U3).
- Today's sync custody, store-key custody and Apple key `<scope>-apple-key` are untouched; the new names never collide
  with them (rule 26).

**The Mac suites the orchestrator runs under the stage (from `App/Variorum/`; `-derivedDataPath DerivedData/vx306`;
the record ended PENDING on them — RUN by the orchestrator 2026-10-18 07:06 MDT under `vx-306-u1a-batch`: `✔ Test run with 28 tests in 6 suites passed after 0.387 seconds.`, 0 skipped, `** TEST EXECUTE SUCCEEDED **` — the tree 22a737d94 after the fold of main):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx306 test \
  -only-testing:VariorumTests/ProtectionKeychainFamilyTests \
  -only-testing:VariorumTests/KeychainTripwireTests \
  -only-testing:VariorumTests/KeychainLeavesTests \
  -only-testing:VariorumTests/ProtectionFileLeavesTests \
  -only-testing:VariorumTests/ProtectionFactsGathererTests \
  -only-testing:VariorumTests/ProtectionSystemCompositionTests
```
(`KeychainTripwireTests` carries the new per-leaf refusal test as an extension, inside its `.serialized` suite.) The
expected shape: 4 + (the tripwire suite's own + 1) + 5 (one enabled only with an enrolled finger) + 9 + 4 + 1 tests —
PENDING. Opt-in, only by a deliberate choice: `TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1 … -only-testing:
VariorumTests/ICloudAppleKeysLeafTests` (1 test; a synchronizable throwaway item rides into iCloud Keychain for moments).

**Commits:** `82e4ad038` (VX-386) · `d5642b5fa` (the migration) · `5cc3b0c8e` (VX-390) · `b12f49cf8` (4a) · `c224bd578`
(4b/4c) · `2e2d56de0` (the keychain facts applied) · `e9bb71007` (the Mac suites) · this record. `git worktree list`:
no stray (both scratch worktrees removed).

### U1b RECORD — THE LOBBY ON ROADS, DEBUG-GATED (Opus implementer, 2026-10-18; BUILT — the Mac suites and the walk PENDING)

**Not done in U1b, first:**
- **No Mac suite was RUN** (the brief: no `xcodebuild test`, no stage) — only built (`build-for-testing` green). The
  orchestrator runs the list at this record's end under a stage claim and flips the counts. That includes the RED half
  of VX-310's red-on-old (`VX310TodayLobbyWitnessTests` — today's road, two known issues) and every real-keychain test.
  What DID run: 27 of the new tests HEADLESS in a SwiftPM harness over the real `Shared/Protection/` files (below).
- **The walk was not done** (the orchestrator's: K1's fresh start of the dev store, then stages 1, 3, 5, the lobby and
  the Touch ID rows — the recipe below). No Debug app was launched; the dev store, the real store and `/Applications`
  were never touched.
- **THE WALK'S `security` ROWS CANNOT BE WALKED AS THE PLAN WROTE THEM.** The new road's custody, memory and sync-keys
  items are DATA-PROTECTION keychain items (`kSecUseDataProtectionKeychain`, `KeychainPartition.dataProtection`); the
  unit's one Sonnet lookup (external facts, read-only): *"There is no command-line tool access to the data protection
  keychain"* [DTS — developer.apple.com/forums/thread/807782]; `/usr/bin/security`'s find/delete call the file-based
  `SecKeychain*` APIs only [Src — apple-oss-distributions/Security, `SecurityTool/macOS/keychain_find.c`,
  `keychain_delete.c`]; the shared `security item` command (which sets the flag) answers `unknown command "item"` on this
  macOS 27 Mac (iOS only) [Src, verified locally]; Keychain Access shows the data-protection keychain as "iCloud" /
  "Local Items" (password items only, TN3137) and its signature carries the `*` access group, so it PROBABLY lists and
  deletes them — unverified [Doc + Src + Inference]. So: OBSERVATION goes through the open's one Diagnostics line
  (`ProtectionOpenRoad.logSummary`, below), and the stage-5 deletions through the DEBUG walk switch
  `VARIORUM_WALK_FORGET` (P-VX306-U1b-9). Built, not walked.
- **The faces of the notice, the offer, rule 27's doors, rule 1's receipt and the rule-3 reminder are U2's** — the route
  hands them through (`AppBootstrap.roadSession?.report`: `notice`, `repairsDone`, `faults`, `acts`); until U2 an
  open's rule-21 notice is carried, not shown (the open's `refreshMemory` has already followed the library — U2 must
  render the report's notice once at the open, as its brief says). Rule 27 before unlock shows §7c (3)'s sentence with
  NO doors (U2 adds them).
- **Today's protection doors in Settings still render on the new road** (Change Passphrase / New Words / the reset door,
  13x's Open Library / Restore from Backup / Send Library) and act on TODAY's machinery — the today-road key file stub
  beside the store, not the protection core's key file. Only the posture switches are unwired (P-VX306-U1b-6). U2 (the
  set-passphrase sheet, the protection pane) and U3 (the two doors) replace them — **the walker presses none of them.**
- Nothing in `Sources/`, `Sync/`, `Server/`, `StoreBackup.swift`, `BackupRetention.swift` or `RestoreHoldModel.swift`.

**What shipped, per piece (commits):**
- `fdda1a67b` the record skeleton.
- `4f411d60a` PIECE 1 — the one switch (`Shared/Protection/ProtectionRoad.swift`: `newRoadIsLive = live(debug:
  isDebugBuild, mac: isMac)`, `isDebugBuild` the `#if DEBUG` arm alone); `AppBootstrap.newRoad`; `ProtectionRoadSwitchTests`.
- `454db4417` PIECE 2 — the route (`ProtectionOpenRoad.swift`; `AppBootstrap`'s switch read at the head of
  `routeAndOpen`, now `async`) + the faces it lands on (compiling state).
- `ca7de7f68` PIECE 3 (Part of VX-310) — `ProtectionLobbyModelTests` + `VX310TodayLobbyWitnessTests`.
- `2f9cef7bb` PIECE 4 — `LibraryWordsCardTests`.
- `5056fd359` PIECE 5 — `ProtectionBackupHook` + `ProtectionBackupHookTests` + the new-road test world + the open's
  Diagnostics line.
- `ea99ea24c` PIECE 6 — `ProtectionRoadRouteTests` + `ProtectionOpenRoadPlantedTests`.
- `cd00b20cb` the DEBUG walk switch (`ProtectionWalkSwitch.swift`, `ProtectionWalkSwitchTests`).
- this record.

**THE ROAD AS BUILT (for the ladder):** `beginOpening` composes `ProtectionSystem.live(variant: .dev)` ONCE per open on the
main actor (`RoadInputs.compose`); `routeAndOpen` (off the main actor) reads `newRoad` first → `routeOnNewRoad`: the
sign-in read (`KeychainAuthStorage`, a read) → `ProtectionOpenRoad.route`: a key handed back by today's adoption doors is
tried first through the executor; the gatherer's facts (a `GatherError` ⇒ no facts — over an empty slot `.failed`, else
the lobby with the reason) → `assess` → `.startFresh` ⇒ `createLibrary(passphrase: nil)` ⇒ the card; `.libraryMissing` ⇒
today's three-door face (its Start a New Library now the core's creation, the missing library's live key file stepped
aside first — P-VX306-U1b-3); `.lobby` ⇒ THE QUIET ROADS AT ONCE: every silent item's key, then each Apple wrap whose key
reads here (live first, then the mirror's, then the catalogued files' — P-VX306-U1b-2), the candidates expanded through
every held key file's history, the first that opens the slot unlocking with the rest in hand; none ⇒ the lobby. After any
unlock: `settle(&library, typed:)` (failure logged, never blocking), `repairPasses` (up to three runs of `assess(facts with
unlocked)` → `runRepairs`, a repair failure logged), the Diagnostics line; then `openOnNewRoad`: today's store id
(`ensureStoreIdentity` — at a creation today's `startNewLibrary` mint: the old envelope aside, `StoreIdentity.establish`
under the new key, the new id's Auto dials, NEVER today's silent custody; at a later open only when none is there) →
today's `openStoreOffMain(variant:, custody: .inMemory(initial: key))` → `.ready` with `roadSession` held. The lobby's
presses (`openTyped`, `pressTouchID`, `lobbyFacts` for refresh) run detached through the same road. THE TYPED ROADS: a
passphrase derived ONCE per descriptor (the floor checked first) and the words (validated first, BIP-39 refusals in
words) tried on the live key file, this Mac's sealed mirror(s) (memory payloads read unverified — a key file holds no
secret; the unlock verifies) and every catalogued key file; `offeredTyped` = `LobbyRoads.typed` ∪ the locks of the
library's held files. ON THE NEW ROAD, OFF: today's R1-M3 relanding of the silent item, today's ready housekeeping (the
§11 migration; the reconcile — its Apple arm mints today's shared Apple key), `lock()`/`canLock`, today's posture
runner (P-VX306-U1b-6/7). A HOSTED TEST RUN takes the road READ-ONLY (P-VX306-U1b-8).

**VX-310 (Part of VX-310) — traced, pinned, red-on-old:** piece 3's line above carries the mechanisms, the cures and the
evidence; in one line: the old `biometryOffered = demand == .biometric && gatedItemExists()` (no enrolled-finger fact) and
a `let` fixed from one probe at the lobby's build (never re-read) → the new button `TouchIDAssessment.button`, a press
moving only the press fact, `refresh()` on her return never removing a button. The re-arm question stays VX-308's
(rendered as nothing). **The Touch ID ROW's honest scope:** no Touch ID item can exist this phase (no Castle entry), so
the walk sees only "no item → no button, the quiet line" (*Touch ID isn't set up for this library.* on the Pro's
enrolled finger; *…on this Mac.* without one); the PRESS and the no-prompt listing with a real `.biometryCurrentSet` item
present stay on U1a's `KeychainLeavesTests.aTouchIDItemIsListedByNameAndNeverPressed` (enrolled finger only).

**Counts (the tree `cd00b20cb` + this record):**
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Release -derivedDataPath DerivedData/vx306
  build` → `** BUILD SUCCEEDED **` on piece 1's tree, on `ea99ea24c`, on `cd00b20cb`, and on the FINAL tree (the card's
  Return shortcut dropped — below) (no install, no launch); in the Release binary `strings … | grep -c VARIORUM_WALK_FORGET` → `0` (the Debug dylib: `1`) — the walk
  switch is not in Release.
- `xcodebuild … -configuration Debug -derivedDataPath DerivedData/vx306 build-for-testing` → `** TEST BUILD SUCCEEDED **`
  (final tree); zero warnings in the touched files.
- `xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vx306
  build` → `** BUILD SUCCEEDED **` (final tree). The phone keeps today's road (P-VX306-U1b-1); its unreachable arm is
  `MobileStoreOpeningView`.
- HEADLESS (a SwiftPM harness in the session scratchpad — not durable: `Sources/Variorum/` = every
  `App/Variorum/Shared/Protection/*.swift` but `ProtectionBackupHook.swift`, byte-identical to the worktree's (`diff`ed),
  plus eight one-line app stubs (`DeviceName`, `BackupDestination`, `KeychainPartition`, `AppleKeyKeychain`,
  `KeychainTestTripwire`, `AuthTokens`/`KeychainAuthStorage`, `AppleKey`, `EncryptionSession.words`); the test target the
  worktree's `ProtectionTestSupport.swift`, `ProtectionOpenRoadPlantedTests.swift`, `ProtectionLobbyModelTests.swift`,
  `ProtectionWalkSwitchTests.swift`; the package depends on the worktree's core by path, with the app's concurrency
  settings — default `MainActor` isolation, `NonisolatedNonsendingByDefault`, `InferIsolatedConformances`,
  `MemberImportVisibility`): `✔ Test run with 27 tests in 3 suites passed after 0.142 seconds.` (15 lobby + 9 planted
  road + 3 walk switch). The mutation runs: piece 3's line.

**PROVISIONALs (each built as its option (a); bundled under QUESTIONS #233):**
- **P-VX306-U1b-1 — the phone keeps today's road this unit** (the switch's rule is `debug && mac`). (a) BUILT — the
  phone's lobby face is U3's; (b) the switch on in the phone's Debug build too (a new-road state with no phone face);
  (c) U3's phone faces now (another unit's surface).
- **P-VX306-U1b-2 — the quiet roads walked as the scenario world walks them** (`World.walkLobby`): every silent item, then
  the Apple wrap of each key file this Mac holds whose key reads here (the live file's first, then the mirror's and the
  catalogued files'), every candidate expanded through every held file's history. (a) BUILT — rule 8's "the next open
  uses whatever quiet road still works", and the proof's own road; (b) exactly `LobbyRoads`' two (the live file's Apple
  wrap only) — a Mac whose live key file is gone while its mirror carries a readable Apple wrap would ask for a secret
  with a quiet road working; (c) history expansion through the live file only. The face's `asksASecretAtOnce` is
  unchanged (a visible lobby means every quiet road failed).
- **P-VX306-U1b-3 — Start a New Library on the missing face sets the missing library's live key file aside** into
  `Previous Libraries/<stamp>/` (moved, never deleted) before the creation writes the new one. (a) BUILT — rule 1: the
  key file is as essential as the library (the library file is only missing; without its key file it could never open
  again — rule 27), and today's door set its envelope aside the same way; (b) overwrite it (the core's `createLibrary` as
  is); (c) refuse Start New while it sits there (a dead end).
- **P-VX306-U1b-4 — the lobby's words §7c does not draft**, from the rules, sentence case (`ProtectionWords.swift`):
  *Open your library* · *Enter your passphrase or your twelve words to open your library.* (and its passphrase-only /
  words-only forms) · *Passphrase* · *Open* · *Use your twelve words instead* · *Your twelve words, separated by spaces* ·
  *Open with the words* · *Opening your library…* · *That passphrase doesn't open this library.* · *Those twelve words
  don't open this library.* · *There are twelve words — you entered N.* · *“x” isn't one of the words Variorum uses —
  check its spelling.* · *One of the twelve words is off. Compare them with what you wrote down.* · *The key file beside
  your library can't be read, so Variorum can't open the library with it.* · *Variorum couldn't check this Mac's
  keychain just now. Enter your passphrase or your twelve words.* · Touch ID: *Unlock with Touch ID* · *Touch ID isn't set
  up on this Mac.* / *…for this library.* (§3.10's) · *Touch ID changed since you set it up — unlock with the passphrase.*
  (§3.10 verbatim) · *Open the lid to use Touch ID.* · *Connect your keyboard with Touch ID to use it.* · *Pair your
  keyboard with Touch ID to use it.* · *Touch ID is locked after too many tries. Enter your passphrase, or lock and unlock
  your Mac.* · the failures *Variorum couldn't create your library.* / *…couldn't check this Mac's keychain, so it didn't
  create a library. Try again.* (a) BUILT; (b) today's `ProtectionCopy` lobby sentences (they speak today's design —
  "encryption passphrase", "recovery phrase"); (c) blank until her sitting. Her taste call.
- **P-VX306-U1b-5 — the new road reaches only the dev store**: a Debug build opted into the real store's variant
  (`-VariorumRealStore`) keeps today's road. (a) BUILT — the phase's one law ("it reaches only the fenced dev store");
  (b) the switch alone (a Debug build on the real variant would write real-scope new-road items, its Apple keys into
  her iCloud Keychain).
- **P-VX306-U1b-6 — today's posture runner is not wired on the new road** (Use Castle / Use Standard / Replace All Keys
  / the follows do not render — P-2). (a) BUILT — a press would re-key the library under today's key file, which the
  protection core's key file would then no longer open; (b) leave them; (c) hide today's whole protection pane on the new
  road (U2's surface).
- **P-VX306-U1b-7 — today's ready housekeeping, today's silent-item relanding and Lock / Lock Now do not run on the new
  road.** (a) BUILT — rule 26 (the new road writes none of today's names; today's reconcile would mint today's shared
  Apple key and land its wrap, a quiet road Castle entry's sweep never finds — rule 11) and every new-road library is
  Standard this phase, which never locks (rule 8); (b) run them as today; (c) run only their read-only parts (a split of
  today's controller). Castle's lock on the new road is VX-307's.
- **P-VX306-U1b-8 — a hosted test run takes the new road READ-ONLY** (`KeychainTestTripwire.armed`): it may open the dev
  library, never create, settle, repair, mint the store id or take a pair. (a) BUILT — the tripwire refuses every
  real-scope mutation in a test process, and a refused trip would land in `KeychainTripwireTests`' exact count; (b)
  today's road in the test host (it cannot open a converted dev store); (c) full writes (refused mid-repair, partial
  record writes).
- **P-VX306-U1b-9 — the DEBUG walk switch `VARIORUM_WALK_FORGET`** (`silent` · `apple` · `silent,apple`): once per launch,
  before the facts, the dev scope's silent custody items and/or the Apple keys stamped with the live key file's library are
  forgotten through the production leaves — as a keychain reset would. (a) BUILT — the rule-8 rows are otherwise
  unwalkable (no CLI reaches the data-protection keychain or iCloud Keychain — the lookup above); DEBUG only, the new road
  only, never in a hosted test run, never on a test harness (`road.open == nil`); (b) Keychain Access by hand (unverified
  for these items; a GUI step); (c) leave the rows on the pins (`ProtectionRoadRouteTests` does the deletions on a
  throwaway scope with the real leaves).
- **P-VX306-U1b-10 — a keychain that could not be listed shows no Touch ID face** (and both typed roads with the reason).
  (a) BUILT — nothing listed, nothing claimed; (b) a Touch ID button whenever biometry is usable (a press may find nothing).

**Recorded refinements (not product calls):** the words card's one button carries NO Return shortcut (a stray Return
must never put the once-shown words away — pinned in `LibraryWordsCardTests`); a backup run that found nothing due takes no pair (the hourly re-check
would otherwise mint a pair an hour); today's store id is re-minted at a later open only when none is there (a key change
later must never change it); the creation runs the repairs' passes but no settle (no plan in an empty slot); every new
OpenOutcome/State case is reachable only with the switch on (the cases compile in both configurations — rule 24's
spirit); the lobby re-reads its roads on `NSApplication.didBecomeActiveNotification`.

**Hand-forwards (U2, U3, VX-307):**
- U2: `AppBootstrap.roadSession?.report` — `notice` (show ONCE, §7c (4)), `repairsDone` (`.restoreKeyFileFromMirror` →
  §7c (6)'s receipt), `faults` (`.noKeyFileAnywhere` → rule 27's banner), `acts` (`.askPassphrase` → the reminder,
  `.offerKeyFile` → the offer); `ProtectionLobbyFace.noKeyFileAnywhere` → rule 27's lobby doors; `liveKeyFileUnreadable`
  → its face. The executor and the `UnlockedLibrary` for an act live on `roadSession` (`executor`, `library`).
- U3: the phone (`ProtectionRoad.live` widens to the phone's Debug build when its faces land); today's 13x doors still
  render and act on today's road; `adoptLibrary`/`reopenAfterAdoption` hand a key back that the new road tries first.
- VX-307: `lock()`/`canLock` and the re-lock monitors on the new road (Castle's), today's posture runner's replacement.

**THE WALK RECIPE (the orchestrator's, under a held stage claim `vx-306-u1b-walk`; DEV STORE ONLY):**
0. Zero Debug instances (`pgrep -fl 'DerivedData/vx306/Build/Products/Debug/Variorum.app/Contents/MacOS'`; a
   `/Applications` instance is NEVER touched). Build if needed: `cd App/Variorum && xcodebuild -scheme Variorum -destination
   'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx306 build`. K1: the dev container is
   `~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev/` — copy
   `variorum.sqlite` + its `-wal`/`-shm` + today's key file(s) (`variorum-keys*.json`) + anything else beside the slot that
   is the pre-design store's WHOLE into `Backups/safety-copies/variorum-vx306-predesign-<stamp>/`, then remove them from
   the slot (leave `Backups/` in place). The dev scope's TODAY-road keychain items stay.
1. Launch: `open -n App/Variorum/DerivedData/vx306/Build/Products/Debug/Variorum.app` (or the binary
   `…/Variorum.app/Contents/MacOS/Variorum` directly). EXPECTED: the CREATION CARD — the lobby's room (the glyph rain),
   a calm card: a key glyph, *Your twelve words*, the lead (§7c (1)), the twelve words in two numbered columns (1–6,
   7–12, mono), the foot, ONE button *I've written them down* (no Copy, the words not selectable). Capture it (both
   appearances if the walk flips light/dark — the card speaks the leading voice's fallback tokens; there is no store
   voice yet). WRITE THE WORDS DOWN for the walk (they are the dev library's; never into a commit or record — her
   2026-10-13 rule for the dev credentials applies; put them beside `~/.variorum/dev-castle.env` only at her word).
   Press the button → the library opens; the seeder mints the shipped furniture (with `VARIORUM_SEED_GATE_UNOWNED=1`
   if the dev scope's session is signed in — the 13s-b diagnosis).
   OBSERVE (the Diagnostics line): `log show --last 10m --info --predicate 'subsystem == "io.lduarte.Variorum" AND category
   == "protection"' | grep 'road:'` → `road: created — library <lib8> key <fp8> device <dev8>; custody silent 1 touchid 0;
   Apple keys readable [<id8>]; memory items 1; live key file roads [apple,words]; notice false; repairs […]; …`. Files
   beside the slot: `variorum-library-keys.json` (format 3, `"words"` present, no `"passphrase"`),
   `variorum-library-lived-here`, today's store-id stub `variorum-keys*.json`. **The keychain items (data-protection —
   NOT visible to `security`):** custody `service io.lduarte.Variorum.library-key / account Variorum-dev-<fp16>-silent`
   (label = the library ID), memory `io.lduarte.Variorum.memory / Variorum-dev-<libraryID>`, Apple key (iCloud,
   synchronizable, shared group) `io.lduarte.Variorum.apple-key / Variorum-dev-apple-key-<id>` — read by the line above
   (Keychain Access's "iCloud"/"Local Items" view may show them — unverified).
3. Back Up Now (Settings ▸ Data Safety) → `Backups/<lib8>/<mac8>/variorum-backup-<stamp>-<fp8>.sqlite` + `….keys.json`
   beside today's flat `Backups/variorum-backup-<stamp>.sqlite`; the line `backup pair: written under <fp8> in
   Backups/<lib8>/<mac8>`.
5. Quit; relaunch → opens silently (`road: opened …; repairs []`). Quit; relaunch with `VARIORUM_WALK_FORGET=silent`
   (`open -n --env VARIORUM_WALK_FORGET=silent <app>`, or the binary with the variable set) → opens SILENTLY through the
   Apple wrap: lines `WALK SWITCH (VARIORUM_WALK_FORGET): forgot 1 silent custody item(s) of scope Variorum-dev` then
   `road: opened … repairs [remakeOnDeviceItem]; custody silent 1` (rule 8 — the on-device road re-made). Quit; relaunch
   with `VARIORUM_WALK_FORGET=silent,apple` → THE LOBBY at once: *Open your library*, *Enter your twelve words to open your
   library.*, the words field, the quiet line *Touch ID isn't set up for this library.* (an enrolled finger) or *…on this
   Mac.*; a wrong attempt says why; the twelve words typed → opens (`repairs [remakeOnDeviceItem, remakeAppleRoad, …]`).
   NOTE: the `apple` forgetting deletes a synchronizable dev-scope item, which iCloud carries to her other devices'
   keychains (dev-scope names only). Touch ID rows: no Touch ID item can exist this phase (record which quiet line shows).
   **Press none of today's Settings protection doors on the new road** (see "Not done").
   The dev store is the new system's after step 1: a Debug build without this branch cannot open it — tell the
   coordinator (K1's broadcast).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx306 test \
  -only-testing:VariorumTests/ProtectionRoadSwitchTests \
  -only-testing:VariorumTests/ProtectionLobbyModelTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests \
  -only-testing:VariorumTests/LibraryWordsCardTests \
  -only-testing:VariorumTests/ProtectionBackupHookTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionWalkSwitchTests \
  -only-testing:VariorumTests/ProtectionKeychainFamilyTests \
  -only-testing:VariorumTests/KeychainTripwireTests \
  -only-testing:VariorumTests/KeychainLeavesTests \
  -only-testing:VariorumTests/ProtectionFileLeavesTests \
  -only-testing:VariorumTests/ProtectionFactsGathererTests \
  -only-testing:VariorumTests/ProtectionSystemCompositionTests \
  -only-testing:VariorumTests/StoreLaunchRouteTests \
  -only-testing:VariorumTests/Phase13pLobbyTests \
  -only-testing:VariorumTests/AppBootstrapOffMainTests \
  -only-testing:VariorumTests/Phase13pKeyedDrillTests \
  -only-testing:VariorumTests/LobbyVaultRoadTests \
  -only-testing:VariorumTests/LibraryPortabilityDoorTests \
  -only-testing:VariorumTests/VX202ReopenRaceTests \
  -only-testing:VariorumTests/VX206ProtectionLandingTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/VX110SignedOutCastleTests \
  -only-testing:VariorumTests/VX209WayBackRoundTripTests \
  -only-testing:VariorumTests/VX80CastleFollowRecoveryTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/ICloudDriveOfferTests \
  -only-testing:VariorumTests/MCPAsksWaitTests \
  -only-testing:VariorumTests/VX209LeavesCastleConfirmTests \
  -only-testing:VariorumTests/Phase9cAuthWiringTests
```
The first eight are U1b's new suites (4 + 15 + 2 + 3 + 5 + 7 + 9 + 3 = 48 tests; `VX310TodayLobbyWitnessTests` reports
its 2 tests with KNOWN ISSUES — that is the red-on-old, expected, and a pass of either known issue is a FAILURE); then
U1a's six (the test host now runs the new road read-only — the tripwire's exact count must hold); then the existing route
suites (the switch forced off — the Release check's second leg) and the source pins over the edited files. Run it after
K1 or before — the test host's own launch takes the new road read-only either way (before K1 it sits at the rule-27
lobby over the pre-design dev store; nothing in the suites reads the host's store). Read the `skipped:` lines.

**Notes:** no machinery deaths; one Sonnet lookup (the data-protection keychain's CLI reach — above); `git worktree list`
shows no scratch worktree (the red-on-old ran through today's road in the tree and the headless harness, never a scratch
worktree).

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 1 — the Debug switch `ProtectionRoad.newRoadIsLive` + its pins + the Release check: DONE (this commit) —
  `Shared/Protection/ProtectionRoad.swift` (the rule `debug && mac`, compile-time — `isDebugBuild` is the `#if DEBUG` arm
  alone; P-VX306-U1b-1: the phone keeps today's road this unit); `AppBootstrap.newRoad` (the production instance reads the
  switch; the test init defaults it OFF — the test override); `ProtectionRoadSwitchTests` (4: the rule's four cells, this
  Debug Mac build reads it on, the source pin on the compile-time arm and no run-time input, a test bootstrap runs today's
  road). Release check, this tree: `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Release
  -derivedDataPath DerivedData/vx306 build` → `** BUILD SUCCEEDED **` (no install, no launch); Debug `build-for-testing` →
  `** TEST BUILD SUCCEEDED **`. The pins' RUN and the existing route suites' run under the switch forced off: PENDING (the
  orchestrator, under the stage).
- Piece 2 — the new road's route in `routeAndOpen` behind the switch (facts → `assess` → the verdict; the quiet roads at once;
  the typed roads with the mirror and the catalogued key files; settle + repairs; the open with the key in hand; the store
  identity; the throwing edges caught): DONE (this commit — COMPILING STATE: Debug `build-for-testing` → `** TEST BUILD
  SUCCEEDED **`, the phone `** BUILD SUCCEEDED **`; its route test is piece 6's). `Shared/Protection/ProtectionOpenRoad.swift`
  (the off-main road: `route` · `lobbyFacts` · `create` · `openTyped` · `pressTouchID` · `open` → `unlock(with:alsoInHand:)`
  → `settle` → `repairPasses`; `heldKeyFiles` = live + the mirror + every catalogued key file; `expand` through every held
  file's history; the bootstrap's `RoadInputs`/`ComposedRoad`/`ProtectionRoadTestHarness`); `AppBootstrap` — the switch read
  at the head of `routeAndOpen` (`routeOnNewRoad` → `openOnNewRoad` → today's `openStoreOffMain` with `.inMemory(key)`),
  `ensureStoreIdentity` (today's mint at a creation; at a later open only when none is there), the states `.roadLobby` /
  `.newLibraryWords`, today's relanding · ready housekeeping · `lock`/`canLock` OFF on the new road, the missing face's
  Start a New Library → the core's creation; the arms in `VariorumApp` / `SettingsSceneContent` / `VariorumMobileApp` (the
  phone's unreachable); today's posture runner NOT wired on the new road (P-VX306-U1b-6). The faces the route lands on
  (the model, the face, the card — pieces 3/4) ride this commit so it compiles.
- Piece 3 — the lobby MODEL (pure, Shared) + `StoreLockView`'s road face + VX-310's two pins (red-on-old): DONE — the
  model/face/view rode piece 2 (`454db4417`: `Shared/Protection/ProtectionLobbyFace.swift` — the core's `TouchIDAssessment`
  and `LobbyRoads` read into a face, no rule of its own; `ProtectionLobbyModel.swift` — the presses over injected roads;
  `StoreLockView.swift`'s new `RoadLockView`); THIS commit the pins. **THE MECHANISMS (traced on today's road, re-read on
  this tree):** bug 1 — `AppBootstrap.routeAndOpen`'s `.lobby` arm and `lock()` build `biometryOffered: demand ==
  .biometric && guardSeam.gatedItemExists()`, a presence probe that never asks whether a finger is enrolled (hardware, no
  finger ⇒ the button, the automatic ask, and the line *"Unlock your library with Touch ID."*); bug 2 — `StoreLobby
  .biometryOffered` is a `let` fixed from ONE probe at the lobby's build and the lobby never re-reads, so a lobby built while
  the probe answered "no" (the ticket's suspect: a re-lock just after a cancelled prompt) has no button until a relaunch
  builds a new one (the probe's real-world "no" is not reproducible headless — Unknown; the scripted guard's
  `gatedWritesAreInvisible` stands in for that one answer). **THE CURES on the new road:** the button is
  `TouchIDAssessment.button` (item for the current key AND hardware AND an enrolled finger); a press moves ONLY the press
  fact (never a re-listing); `refresh()` on her return to the app re-reads the roads, a failed read keeping the face and a
  read that misses a Touch ID item seen before keeping it (only a press that finds the item gone drops the button).
  **The pins:** `ProtectionLobbyModelTests` (15, planted facts, no keychain) — and **red-on-old twice over:** (i)
  `VX310TodayLobbyWitnessTests` (2) drives TODAY'S road (the pre-fix code, byte-unchanged and still Release's until VX-329)
  through the same scenarios, each expectation inside `withKnownIssue` — the red is the known issue, and the file is a
  tripwire if today's road ever changes; its RUN is the orchestrator's under the stage — PENDING; (ii) a HEADLESS harness
  (the real `ProtectionLobbyFace.swift` + `ProtectionLobbyModel.swift` + `ProtectionWords.swift` and the pin file, compiled
  by SwiftPM against the worktree's core with the app's concurrency settings; the plain `RoadLobbyFacts`/`RoadAttempt`
  declarations copied, `ProtectionRoadSession` an empty stub) — green `✔ Test run with 15 tests in 1 suite passed after
  0.025 seconds.`; MUTATION A (the face's button = today's presence-only rule): `✘ Test run with 15 tests in 1 suite failed
  … with 8 issues` — both bug-1 pins red (`!face.touchIDButton`, `!face.autoAsk`, the line; `roads.presses == 0`);
  MUTATION B (a press re-reads the listing and adopts it; `refresh` a no-op — today's never-re-read lobby): `✘ … failed …
  with 12 issues` — both bug-2 pins red (`model.face.touchIDButton` after a dismissal; the button not back after her
  return); each mutation restored and `diff`-checked against the worktree file. The harness lived in the session
  scratchpad (not durable; the recipe is this paragraph).
- Piece 4 — the creation card (§7c (1) verbatim, one button) + `createLibrary(passphrase: nil)`: DONE — the card rode
  piece 2 (`454db4417`: `Shared/Protection/LibraryWordsCardModel.swift`, the face `Features/Protection/LibraryWordsCard.swift`
  — the title, the lead, the twelve words numbered in two columns in the mono face, not selectable, privacy-sensitive, the
  foot, ONE button; the route's `.startFresh` → `ProtectionOpenRoad.create` → `createLibrary(passphrase: nil)` → the card
  → its button → the open); THIS commit `LibraryWordsCardTests` (3: the two columns and the one button forgetting the words
  and opening once; §7c (1) verbatim; the face's source has no copy road, no later door, exactly one button). The words in
  `Shared/Protection/ProtectionWords.swift` (§7c (1) and (3) verbatim; the lobby's undrafted lines P-VX306-U1b-4). The
  run PENDING under the stage.
- Piece 5 — the `StoreBackup.onRun` hook → `takeBackupPair`, honouring `copiesArePaused` (K4): DONE (this commit) —
  `Shared/Protection/ProtectionBackupHook.swift`: attached ONCE per services instance in `VariorumApp`'s ready `.task`
  (`ProtectionBackupHook.attach(to: fresh.backup, session: bootstrap.roadSession)` — nil on today's road, and never for a
  read-only session); a run whose primary leg WROTE a snapshot (a due scheduled run, or Back Up Now) → off the main actor,
  `takeBackupPair(with: key, keyFile: <the live key file, when it is the key's>, deviceID: <this Mac's device ID>)` →
  `Backups/<library8>/<mac8>/variorum-backup-<stamp>-<fp8>.sqlite` + `.keys.json`; a run that found nothing due writes no
  pair (the hourly re-check would otherwise mint one an hour — a recorded refinement); paused copies or another key's file ⇒
  none, logged; a failure is logged, never raised. Zero edits to `StoreBackup.swift`; `RootView.swift` carries no `onRun`
  (the `ICloudDriveOfferTests` pin). `ProtectionBackupHookTests` (5, throwaway scope, temp slot): the pair opens with the
  library's key and its `.keys.json` IS the live key file, the catalogue reads it as this library's backup; nothing-due ⇒
  none; paused ⇒ none, resumed ⇒ written; another key's live file ⇒ none; attached only for a writing session. Also here:
  the open's ONE Diagnostics line (`ProtectionOpenRoad.logSummary` — counts and eight-character names only; the walk reads
  it). Debug `build-for-testing` → `** TEST BUILD SUCCEEDED **`. The run PENDING under the stage.
- Piece 6 — the Mac tests + `build-for-testing` + the phone build: DONE (this commit; the final checks are the close's) —
  `ProtectionRoadRouteTests` (7, through `AppBootstrap` with the harness, throwaway scope + temp slot + the real custody and
  memory leaves, an in-memory Apple leaf: stage 1 → the card → the open, rule 21's four things, today's store id, the
  quiet relaunch, `canLock` off; stage 5's on-device half (the silent item gone → the Apple wrap → `remakeOnDeviceItem`);
  both quiet roads gone → the words field → a wrong attempt refused → the words open, `remakeAppleRoad`; K5 → the missing
  face with no sentence; a junk live key file → the lobby, never written over; an unlistable keychain → the typed field
  with its reason; Start a New Library on the missing face → the old key file aside, the card; the read-only road creates
  nothing); `ProtectionOpenRoadPlantedTests` (9, the road over PLANTED leaves — no keychain: the creation's every rule-1
  home, the quiet reopen with nothing owed, rule 8 both ways, the words through the keychain MIRROR with the key file
  written back (`restoreKeyFileFromMirror`), K5, the junk live file, the unlistable keychain over an empty slot and over a
  library, the read-only road). HEADLESS (the harness — all of `Shared/Protection/` but the backup hook, eight one-line app
  stubs, the support file, this suite and the lobby suite): `✔ Test run with 24 tests in 2 suites passed after 0.154
  seconds.` The Mac runs PENDING under the stage.

### U1b WALK RECORD — THE CONVERSION (the orchestrator, 2026-10-18 08:37–08:50 MDT, claim `vx-306-u1b`; the dev store only)

**The batch (A):** the 33 suites → `✘ Test run with 212 tests in 33 suites … 4 issues (including 3 known issues)` on the
first run — the three known issues are `VX310TodayLobbyWitnessTests`' expected red-on-old witnesses (bug 1: two lines,
bug 2: one) and the ONE real red was a test-construction fault: `ProtectionRoadSwitchTests
.theReleaseArmIsTheCompileTimeElseAndNothingCanFlipIt` matched the word "environment" inside `ProtectionRoad.swift`'s own
header comment; fixed to scan code lines only (`2b6a866ad`), rebuilt, re-run `✔ Test run with 4 tests in 1 suite passed`.
0 skipped. The Release check's three legs therefore stand: the switch pins green, the twelve existing route suites green
with the switch off, the Release build green.

**The conversion (B), P-VX306-K1 as ruled:** step 0 with zero instances — the pre-design dev store (`variorum.sqlite` +
`-wal`/`-shm` + the two `variorum-keys-*.json`) copied into `Backups/safety-copies/variorum-vx306-predesign-2026-10-18-144152/`,
each file `cmp`-verified, then moved out of the slot (the originals ride in the same folder as `moved-*.orig`); `Backups/`
and `Previous Libraries/` left in place. Then the walk, the Debug product launched as the BINARY with `OS_ACTIVITY_DT_MODE=YES`
and stderr captured (W-4 below):
- **Stage 1 — the creation card:** exactly §7c (1): the key glyph, *Your twelve words*, the lead, twelve words in two
  numbered mono columns (not selectable), the foot, the one button *I've written them down*. The button opened the
  library; the road line `road: created — library 818912e0 key 88173013 device c7592aa6; custody silent 1 touchid 0; Apple
  keys readable [5e3a0032]; memory items 1; live key file roads [apple,words]` (read at the next launch as `opened`).
  Beside the slot: `variorum-library-keys.json` (format 3: `apple` + `words` wraps, no `passphrase`, history empty,
  `libraryID`), `variorum-library-lived-here`, today's store-id stub `variorum-keys-881730135471ec9f.json` (format,
  fingerprint, storeID — no key). The words went into `~/.variorum/dev-castle.env` as `VARIORUM_DEV_NEWROAD_WORDS` (the
  coordinator's term; CLAUDE.md's "update the file in the same window"), the old store's values untouched; the card's
  capture was deleted from the scratchpad at once (the words never ride a record).
- **Stage 3 — Back Up Now:** `backup pair: written under 88173013 in Backups/818912e0/c7592aa6` —
  `variorum-backup-2026-10-18-144548-88173013.sqlite` (557,056 bytes) + `….keys.json` (format 3, apple + words). Today's
  flat writer wrote its own `Backups/variorum-backup-…-88173013.sqlite` beside its copy of the STUB as `….keys.json` and to
  the far folder ("Copied, checked, ok. Copied to your folder too, 1 old copy retired").
- **Stage 5 — the quiet roads (the on-device half + the typed lobby):** plain relaunch → `road: opened … repairs []; acts 1`
  (rule 3's `beforeFirstBackup` ask owed before stage 3; `acts 0` after it). `VARIORUM_WALK_FORGET=silent` → `WALK SWITCH …
  forgot 1 silent custody item(s)` then `road: opened … repairs [remakeOnDeviceItem]; custody silent 1` — the Apple wrap
  opened it silently and the on-device road was re-made (rule 8). `VARIORUM_WALK_FORGET=silent,apple` → `forgot 1 silent …`,
  `forgot 1 Apple key(s) of library 818912e0`, and THE LOBBY at once: the lock glyph, *Open your library*, *Enter your
  twelve words to open your library.*, the quiet line *Touch ID isn't set up for this library.* (the Pro has an enrolled
  finger; no item exists — VX-310's quiet-line rule), the words field, the one button *Open with the words* (disabled until
  text). A wrong attempt (eleven words) → the refusal *There are twelve words — you entered 11.* under the button, the field
  cleared. The twelve words typed → `road: opened … Apple keys readable [9358575a]; repairs [remakeAppleRoad,
  remakeOnDeviceItem]` — a FRESH Apple key and the silent item re-made (rule 8's "quietly makes a fresh Apple road").
- **Touch ID rows:** no Touch ID item can exist this phase (no Castle entry), so the walk shows only the quiet line and no
  button — VX-310's rule for that state; the press rows and U1a's one Unknown (the probe's no-prompt with a real
  `.biometryCurrentSet` item) stand on `KeychainLeavesTests.aTouchIDItemIsListedByNameAndNeverPressed`, green twice under
  the stage on this enrolled Mac. Both voices: the lobby's room and the card render in the leading voice's fallback (the
  store's voice is unreadable before unlock — one face), captured once.
- **The furniture:** the first open seeded nothing — the per-scope seed marks (`SampleLibrarySeeded.Variorum-dev`,
  `StarredGatheringSeeded.Variorum-dev`) survive a store reset (the 13s-b corner, QUESTIONS #183 — pre-existing, not this
  road's); cleared both and relaunched with `VARIORUM_SEED_GATE_UNOWNED=1` → sherlock (13 notes) + starred notes seeded. The
  Welcome arrangement reads `alreadySettled` by its own mark, so the field guide, readme and snippet are NOT in the fresh dev
  store — a later walker who needs them clears that mark too (W-5).

**POSTURE AFTER THE WINDOW:** a fresh dev library in STANDARD under the new road, no passphrase, unlocked and silently
openable by this branch's Debug build (a silent item, an Apple key, the memory item under `Variorum-dev`; one backup pair);
the old store whole in the safety copy; `dev-castle.env`'s Castle values unchanged. Instances 0; stage released 08:50.

**Walk findings (routed):**
- **W-1 (words — VX-379's pane row, U2 carries the posture box's sentence if it touches it):** the sidebar's posture box
  reads today's *Standard — Right now, only this Mac can open your work.* — FALSE under the rules (rule 8: the Apple road
  reaches her other Macs on the Apple account). Every today's-road sentence on the new road is VX-379's; this one is noted
  for its rewrite.
- **W-2 (MINOR, bug-class — U2 fixes with a red-on-old pin):** the backup pair's folder carries `…sqlite-wal` (0 bytes) and
  `…sqlite-shm` (32 KiB) sidecars beside the frozen snapshot. A pair is the snapshot + its key file; a frozen copy must be
  ONE self-contained file (a later reader without the sidecars must lose nothing; the catalogue's sidecar entries are
  noise). Mechanism: `FileBackupsLeaf.takeBackupPair` copies with the WAL journal mode live; fix: checkpoint and write the
  snapshot in `journal_mode=DELETE` (or remove the sidecars after a verified clean checkpoint), pinned on a temp slot.
- **W-3 (note, expected coexistence — retired at U3/VX-379):** today's flat backup writer copies the store-id STUB as the
  flat snapshot's `.keys.json`, and today's Restore list speaks today's words over the new store (*Opens with your current
  passphrase or Touch ID on this Mac.* for the new pair; the fourteen old flat copies listed). The Debug-only two-road
  coexistence; U3 replaces the Restore list behind Make this my library, VX-379 the words.
- **W-4 (walker fact — WalkKit README at closeout):** `log show` by the `io.lduarte.Variorum` subsystem returns NOTHING for
  the Debug app's `os_log` lines (not persisted/visible here); the walk's road is launching the BINARY directly with
  `OS_ACTIVITY_DT_MODE=YES` and stderr to a file — the `road:` / `WALK SWITCH` / `backup pair:` lines all land there.
- **W-5 (note, pre-existing):** the seed marks above; the Welcome arrangement's mark left as found.
- **W-6 (note for U2):** rule 3's `beforeFirstBackup` act was owed at the first open (`acts 1`) and has no face yet — U2's
  reminder; the open said nothing, as the plan intends until U2.
