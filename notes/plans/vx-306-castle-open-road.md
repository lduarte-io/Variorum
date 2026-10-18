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
   `v1_31_protection_record` (born `v1_30_protection_record`; renumbered at the fold of main after VX-348 merged its own v1_30 — theirs registers first) — `protection_record(library_id TEXT PRIMARY KEY, record TEXT NOT NULL, updated_at TEXT NOT
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

**U3 brief addendum (the orchestrator, 2026-10-18, after U1b's walk — read with the U3 paragraph above):**
- **The doors' home:** the Mac's `Features/Protection/` module (U2's) gains the two doors' faces; the ONE brain stays a
  shared model (`App/Variorum/Shared/Protection/CopyDoorsModel.swift`, pure and testable) over the executor's `lookInside`
  / `makeThisMyLibrary` (`Executor/Acts/Copies.swift`) and the catalogue (`CatalogLister`). 13x's `LibraryOpenModel` keeps
  its CLASSIFIER for a picked thing (`LibraryClassifier`) and its sheet frames; under the new road its adoption step is
  RETIRED behind Make this my library (today's road keeps it byte-unchanged for Release).
- **What a door takes:** a `CatalogCopy`. The Data Safety pane's Restore list under the new road lists the CATALOGUE's copies
  of this library (the new-layout pairs, Previous Libraries) newest first, each row with *Look inside…* and *Make this my
  library…*; today's flat copies are not catalogued (rule 26) and do not appear. **A picked folder that is NOT catalogued**
  (File ▸ Open Library… / the Bookcase drop: an AirDropped pair or library folder) is FILED FIRST — **P-VX306-U3-0 (the
  orchestrator's provisional ruling):** the picked pair is copied whole into the container's
  `Backups/safety-copies/variorum-adopt-safety-<stamp>/` (the catalogue's `adoptionSafetyCopy` kind — this Mac's by place,
  the one existing name shape for "a copy filed by an adoption"; a new kind would be a core names change) and the door then
  acts on the catalogued copy; a picked plaintext export keeps today's road (T-8 stays VX-309's); the empty-slot landing
  (T-5) stays VX-309's. Options recorded: (b) a new `CopyKind.imported` under `Backups/<library8>/imported-<stamp>/` (a
  `CatalogNames` change); (c) act on the picked path directly (the executor takes a catalogue id — a leaf change).
- **Look inside (rule 17):** read-only, writes nothing, closing forgets. **The implementer PROPOSES before building this
  half** (the architect rules — write the proposal into the U3 record, commit, and continue with Make this my library
  meanwhile): (a) a read-only WINDOW over the copy — the executor's `LookedInside` key opens the PRIVATE BYTE COPY (never the
  catalogued file) as a second read-only `AppDatabase` and renders the Library/Book read tier (P3's read-only surface) — if
  a second session can exist beside the live one without global state; (b) a read-only SHEET of the copy's facts (the
  library's name and ID, the copy's date and kind, its books and note titles, a note's text rendered read-only on
  selection) — the honest minimum; the sheet says it is a copy. The orchestrator's lean: (b) unless (a) is cheap and
  isolated; never a write, never a keychain item, the private copy deleted at close.
- **Make this my library (rule 17):** one confirmed door; the confirm reads §7c (8); the copy's own secrets or its quiet
  road, AND the current pair verified (the words always; the passphrase when `record.passphraseSet`) — the door asks what the
  executor requires; then `makeThisMyLibrary` on its plan. **THE SWAP'S PRECONDITION (U1a's hand-forward):** the app's pool
  on the slot is CLOSED and writes quiesced from the stage to the swap — reuse today's `AppBootstrap.adoptLibrary(reopeningWith:
  work:)` / `suspendLobbyForAdoption` seam shape (the pool closed, the work run, the reopen through the NEW road with the
  new key in hand); `swapStaged` refuses `walNotDrained` otherwise. **THE RESTORE HOLD stays:** the hold marker is written
  beside the landed library exactly as 13x's `LibraryAdoption.execute(holding:)` does (core `Persistence/LibraryRestoreHold`
  — the writer; `RestoreHoldModel.swift` is READ ONLY and untouched — VX-348 owns it), so no sync round runs until the one
  Resume Sync press; the new library binds no account (P-VX378-U2-4). The receipt after: §7c (9).
- **The phone:** the switch turns ON for iOS Debug (`ProtectionRoad.live` → `debug` alone; P-VX306-U1b-1 superseded here);
  `MobileStoreLockView` renders the lobby model (the words field, the Face ID/Touch ID button and line, the quiet line) and
  the creation card (§7c (1), the same words); the leaves compose on the main actor (`deviceName`); the SIMULATOR opens its
  fenced store under the stage (the walk's row); a DEVICE install is HER hands (the handoff — optional, the 13y road).
- **Evidence (the orchestrator's walk, `vx-306-u3-walk`, the dev store):** Look inside on the stage-3 pair → read-only, the
  key file beside the live library byte-unchanged, no new keychain item (the Diagnostics line), the private copy gone at
  close; Make this my library on that pair → the confirm, the pair typed, the new library in Standard with a FRESH identity
  and key, the outgoing library + its key file whole in `Previous Libraries/<stamp>/`, the hold banner with Resume Sync, the
  reopen silent; an "AirDropped" copy = the pair copied to a folder under `~/Downloads/` and picked through File ▸ Open
  Library… → filed, then Look inside; the simulator's open. HER HANDS (the handoff): Look inside on a byte-copy of her real
  store with her credentials typed by her.

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
- U1b — the lobby on roads, Debug-gated (+ VX-310, the creation card, the Release check, the dev store's fresh start): DONE 2026-10-18 — built by the Opus implementer (`fdda1a67b`…`137281318`, the §9 U1b RECORD), the batch under `vx-306-u1b` 212/33 (3 known = VX-310's witnesses; the pin fix `2b6a866ad`), THE CONVERSION walked (the §9 U1b WALK RECORD; findings W-1…W-6, W-2 fixed in U2).
- U2 — the honest faces (+ rule 3's reminder, the set-passphrase sheet, W-2's fix): BUILT 2026-10-18 (Opus implementer) — commits `d35b82290`…the close (the §9 U2 RECORD); `build-for-testing` and the phone build green on the final tree; the new pure and planted suites green HEADLESS (69 in the session harness), the core's protection set green in both configurations (315 / 291); the Mac suites (the record's list) and the walk (stages 2, 14, rule 1's restore, W-2's pair, rule 27 both moments) PENDING — the ORCHESTRATOR's, under the stage.
- U3 — the two doors; the phone opens: BUILT 2026-10-18 but for LOOK INSIDE (Opus implementer; DerivedData `vx306-u3`) — Make this my library on a catalogued copy and on a picked (filed-first) copy, the phone's faces and its switch, commits `eaeed1126`…the close (the §9 U3 RECORD); Look inside PROPOSED (piece 4 — (b), the read-only facts sheet, recommended), its build waiting on the orchestrator's ruling; `build-for-testing` green on both platforms; the planted suites green HEADLESS (57 in 8); the Mac and phone suites and the walk PENDING — the ORCHESTRATOR's, under the stage.
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

**(8) Make this my library's confirm:** title *Make this my library?*; lead *This copy becomes a new
library — in Standard, under your current twelve words and passphrase — with a fresh key of its own. Your current library
steps aside whole into Previous Libraries, where you can look inside it or make it your library again. The copy itself is
not changed.* Fields: the copy's own secret when its quiet road doesn't open it (*The copy's passphrase or twelve words*),
then *Your twelve words* (and *Your passphrase* when one is set). One button *Make this my library*. **(9) The receipt:**
*This is your library now. The previous one is in Previous Libraries.* **(10) Look inside's frame line:** *This is a copy
from <date>. Nothing you do here changes it or your library.*

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
- Piece 2 — the `protection_record` LOCAL-ONLY migration `v1_31_protection_record` (born `v1_30_protection_record`; renumbered at the fold of main after VX-348 merged its own v1_30 — theirs registers first): DONE (this commit) —
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

### U2 RECORD — THE HONEST FACES (Opus implementer, 2026-10-18; BUILT — the Mac suites and the walk PENDING)

**Not done in U2, first:**
- **No Mac suite was RUN** (the brief: no `xcodebuild test`, no stage) — only built (`build-for-testing` green). The
  orchestrator runs the list at this record's end under a stage claim and flips the counts. What DID run: the new
  pure and planted suites HEADLESS in the session's SwiftPM harness over the real `Shared/Protection/` files (below),
  and the core's protection set in both configurations.
- **The walk was not done** (the orchestrator's — the recipe below). No Debug app was launched; the dev store, the
  real store and `/Applications` were never touched.
- **The Release build was not re-run** on this tree (§8: no Release build this phase; the gate's Release check is
  U1b's and the orchestrator's to repeat). Release BEHAVIOUR is unchanged by construction — every new line is a new
  file or sits behind the switch (`roadStanding` and the interlude exist only when the new road opened a session;
  in Release `ProtectionRoadBar(model: nil)` and the pane's `roadStanding == nil` render nothing) — but the Release
  binary is not byte-identical: the new types compile in both configurations (rule 24, U1b's precedent).
- **Stage 13 is not walkable** (a key door interrupted needs a crash harness in the app) — it stands on the core's
  crash harness, as the addendum says.
- **The OLDER-COPY notice is not walkable by a hand-swapped pair this phase.** Rule 21's check keys on a KEY
  disagreement (`LibraryNotice.check`: this Mac remembers the library under one key, the live place holds it under
  another, P-VX378-U4-5) — and nothing in this phase changes a library's key (Use Castle / Replace All Keys are
  VX-307's; the passphrase door re-wraps, rule 6), so an older pair of the dev library carries the SAME key and the
  open rightly says nothing. The DIFFERENT-LIBRARY notice IS walkable (the recipe's row 5); the older-copy sentence
  stands on `ProtectionNoticeFaceTests` (the same card, the model's other constant). No walk switch was added for it.
- **The split-pair line has no reachable state** (P-VX306-U2-6 — a finding): built, pinned on the derive, never
  walked.
- **Today's Protection pane still renders today's passphrase doors on the new road** (U1b's note stands): the pane's
  passphrase section's *Set a Passphrase…* (title case) acts on TODAY's machinery; U2's ONE new row sits at the TOP of
  the pane, *Set a passphrase…* (sentence case). The walker presses only the top row. The rule-27 face's *Open
  Library…* is the missing face's 13x door (today's adoption road) — the walker does not press it either (U3).

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton: DONE (this commit).
- Piece 1 — `ProtectionWords.swift` gains §7c (2) (3) (4) (6) (7) verbatim + the pin reading the plan file: DONE (this
  commit) — `ProtectionWordsPlanTests` (3: every drafted string found between its asterisks in §7c, the plan read with its
  whitespace runs collapsed; the model's sentences — the notice's two, the offer's — found in §7c AND absent from the words
  file; the day's form). HEADLESS (the session harness — the record's close says how): green with the other planted
  suites; the Mac run PENDING under the stage. U2's undrafted lines are P-VX306-U2-2's.
- THE FACES' CODE for pieces 2–6, one COMPILING commit (WIP — their pins land per piece below): the open's report
  (`RoadOpenReport.acts` the union of every pass's — rule 3's `.quietRoadFailed` is owed at the open's FIRST pass,
  which the same open's repairs then answer; `keyFileSearch`), the session (`library`/`report` under one lock, the
  interlude once per open, the receipts owed, one act at a time), `ProtectionRoadActs.swift` (the search, *Use it*,
  the first passphrase, the dismissal, rule 27's set-aside), `ProtectionOpenFaces.swift` (the interlude, the standing
  faces, the open library's faces model), `PassphraseReminder.swift`, `SetPassphraseModel.swift`; the bootstrap's
  `.roadInterlude` state + `roadStanding`; the Mac faces `Features/Protection/RoadInterludeCard.swift` ·
  `ProtectionRoadBar.swift` · `SetPassphraseSheet.swift`, rule 27's doors on `RoadLockView`, the Protection pane's one
  row; the phone's unreachable arm. Debug `build` → `** BUILD SUCCEEDED **`: DONE (this commit).
- Piece 2 — the notice (`UnlockedLibrary.notice` via the open's report — a card in the lobby's room between the
  unlock and the library's open, OK once, then the open — PROVISIONAL P-VX306-U2-1): DONE (the WIP commit's code +
  this commit's pins). `ProtectionNoticeFaceTests` (4, planted facts): an OLDER COPY (the same library under another
  key with that key's own file beside it, this Mac remembering the current one) → `.opened` owing the interlude, the
  one card `.notice(.olderCopy(date: the record's date))`, the sentence = her string with `ProtectionWords.day(date)`
  written in, the open's `refreshMemory` already done, the next open says nothing (ONCE); a DIFFERENT LIBRARY (this Mac
  made a second library since — it remembers only that one) → her other string; an ordinary open → no card, and a
  read-only road (a hosted test run) never owes the interlude even with an offer owed; the card's one *OK* → the open
  goes on exactly once. HEADLESS green (the session harness); the Mac run PENDING under the stage.
- Piece 3 — the offer (`OwedAct.offerKeyFile` → `searchKeyFiles` at the open → the offer card; *Use it* =
  `useOfferedKeyFile` + the receipt; *Not now* writes nothing; the split pair's standing line; `.noKeyFileAnywhere` →
  rule 27's banner): DONE (the WIP commit's code + this commit's pins). `ProtectionOfferFaceTests` (5, planted facts):
  a stray (another library's format-3 file) beside the library → the silent item opens it, `.offerKeyFile` owed, the
  search's `.offer(source: .thisMacsKeychain)`, the card's sentence her two strings; *Not now* → the injected
  `useOffer` never called, no receipt, the open goes on, EVERY container file byte-identical and every planted
  keychain item (custody, memory, Apple ids) unchanged — and the next open owes the offer again; *Use it* through the
  real road (`ProtectionOpenRoad.useOffer` → `useOfferedKeyFile`) → the library's own file back beside it, the receipt
  *Key file restored from this Mac's keychain.*, nothing owed after (this open and the next); this Mac's copy gone too
  (memory forgotten) with a backup pair taken → `.backup(_, date)` named with its day, the receipt with the same day,
  *Use it* lands; *Use it* failing → the sentence, both doors stay; the search's other answers (the split pair, rule
  27, beside-opens-it) read into the standing faces. HEADLESS green; the Mac run PENDING under the stage. **Finding for
  the ladder (P-VX306-U2-6):** the split pair's line is built and pinned on the derive, but no planted state reaches it
  through `assess` — the offer is owed only when this Mac's copy or a backup holds the current key's file by name, and
  then the search's candidate always verifies (its key is the key in hand), so the search answers `.offer`; the
  replayed-old-file state (a newer key file beside, its history holding the library's key) owes no offer and is said by
  the older-copy NOTICE instead.
- Piece 4 — rule 27 (the lobby's face + the missing face's three doors; after a quiet-road open the standing banner,
  no doors): DONE (the WIP commit's code + this commit's pins). The lobby's face (`RoadLockView`): §7c (3)'s sentence,
  the account sentence only when `accountRoad`, then the missing face's three doors in §7c (3)'s words — *Restore from
  Backup…* (reveals the app's own Backups folder, rendered only when it exists — the missing face's road), *Open
  Library…* (13x's open door), *Start a New Library* with the missing face's sub-line — the library no key file opens
  set aside WHOLE into `Previous Libraries/<stamp>/` first (PROVISIONAL P-VX306-U2-5), then the creation and the words
  card. After a quiet-road open: `ProtectionRoadBar`'s standing banner, same words, no doors. `ProtectionRule27FaceTests`
  (3, planted): everything gone (no live key file, no memory, no custody, no Apple key) → the lobby's face with
  `noKeyFileAnywhere(accountRoad: false)`, no typed field, `accountRoad: true` with a sign-in; *Start a New Library* →
  the old library opens with its key inside `Previous Libraries/<stamp>/`, a new library in the slot; an ordinary lobby
  offers no fresh start; a quiet open with no key file anywhere → the standing faces' banner, no interlude, nothing
  rebuilt. **The walk switch gains `memory`** (`VARIORUM_WALK_FORGET=memory` — every memory item of the dev scope, the
  sealed mirror with it; DEBUG only, P-VX306-U1b-9's fences) for the walk's rule-27 rows; `ProtectionWalkSwitchTests`
  +1 (4). HEADLESS green; the Mac run PENDING under the stage.
- Piece 5 — rule 1's restore receipt (§7c (6) on the status seam): DONE (the WIP commit's code + this commit). The
  open owes the receipt when its repairs include `restoreKeyFileFromMirror` (`RoadStandingFaces.receipts`, added to the
  session at the open); the open library's faces model (`RoadStandingModel.make` — moved here from the bootstrap so
  the phone and the tests compose the same thing; the bootstrap passes its reminder ledger, a test bootstrap's in its
  own defaults suite, never the app's domain) speaks each owed receipt ONCE when the composition hands it the status
  seam's door (`VariorumApp`'s ready `.task`: `session.status.receipt` — `receipt_style` governs it as every receipt).
  `ProtectionRestoreReceiptTests` (1, planted): the live key file gone → the silent item opens it, the repair runs, the
  file is back, the receipt owed — and spoken exactly once across two `speak` hand-overs. HEADLESS green; the Mac
  run PENDING under the stage.
- Piece 6 — rule 3's reminder (the model's two moments + the launch-counted schedule, local, beside `CalmAsks`' keys;
  dismissals through `recordPassphraseReminderDismissed`) + the set-passphrase sheet (`resetPassphrase(.plainConfirm)`;
  the ask and the Protection pane's one row): DONE (the WIP commit's code + this commit's pins). **As built:** the
  model's moments are `assess`'s (`.askPassphrase(.beforeFirstBackup / .quietRoadFailed)`, read from the open's
  report — the union of every repair pass's acts, so the quiet-road moment survives the same open's repair that
  re-makes the road); the schedule is `PassphraseReminderRules` over a LOCAL per-library ledger in this Mac's defaults
  (`variorum.calmAsks.passphrase.<libraryID>.{launches,shows,lastShownAt,retired}` — beside `CalmAskScheduler`'s
  keys; a launch counted once per process, only on a writing road): the first showing at the third launch, each later
  one 7 × 24 h after the last, *Don't show again* offered once the record counts three dismissals (PROVISIONAL
  P-VX306-U2-3); the two moments show whatever the schedule, even retired (rule 3's "always"); a scheduled *Not now* /
  *Don't show again* records one dismissal (`recordPassphraseReminderDismissed`), a moment's *Not now* writes nothing
  (P-VX306-U2-4); never once a passphrase exists. The face: `ProtectionRoadBar`'s calm bar in the window's bottom
  stack (§7c (7) — the line, *Set a passphrase…* · *Not now* · *Don't show again*), re-read when the app becomes
  active (a week can pass in one session). The sheet (`SetPassphraseSheet`, §7c (7)) — two fields, one button, a way
  out, refused at once when a passphrase exists — from the bar AND the Protection pane's one new row (*Set a
  passphrase…*; the pane's other doors untouched), each host holding its own sheet; on success the reminder retires
  and §7c (7)'s receipt is spoken on the status seam. **Pins:** `PassphraseReminderTests` (12, pure — the arithmetic,
  retired ⇒ only the moments, the ledger in throwaway defaults suites, the presses, the sheet's refusals, the faces
  model's set → retire + receipt + a second sheet refusing at once); `ProtectionReminderRoadTests` (3, planted — the
  moments read from real opens, the quiet-road moment surviving its repair (MUTATION: `acts` = the last pass only → RED,
  `✘ Test run with 16 tests in 1 suite failed … with 1 issue` at the moment's line, restored and `git diff`-clean), the
  dismissal one record write read back from the file, THE SET-PASSPHRASE ROAD through the executor: `.set`, the key
  file gains the passphrase lock under the SAME key, the record's `passphraseSet` read back true, a second set
  `.alreadySet`, the lobby's typed roads now offer the passphrase and it opens the library, no reminder after).
  HEADLESS green; the Mac run PENDING under the stage.
- Piece 7 — W-2's fix (`ProtectionLibraryFiles.snapshot` — one self-contained file; red-on-old pin): DONE (this commit).
  **THE MECHANISM (traced):** the live library is a WAL-mode file (the app's pool); SQLite's backup API copies its
  pages, page 1's WAL marks included, so the snapshot came out a WAL-mode file; `snapshot` removed the sidecars and THEN
  verified the copy with `opens` — a READ-ONLY open (`StoreEncryptionMigration.opens`, `readonly = true`), which on a
  WAL-mode file makes the WAL index (`-shm`, 32 KiB) and an empty `-wal`, and a read-only connection can never remove
  them at close. (W-2's "copies with the WAL journal mode live" was half of it: the files are the PROBE's.) **THE FIX:**
  the copy turned to a rollback-journal file on the backup's own writable connection (`PRAGMA journal_mode = DELETE`,
  its answer checked) before the probe — so no later reader (the probe, the catalogue's, a restore's) makes anything
  beside it; `writeSendPair` takes the same road. **THE PINS (red-on-old):** core `ProtectionLibraryFilesTests
  .aSnapshotOfALiveWALLibraryIsOneSelfContainedFile` (a library held open in WAL mode → the snapshot's folder holds the
  snapshot ALONE; carried by itself it opens with its key and holds the record and the rows) — RED on the pre-fix tree
  (`✘ Test run with 6 tests in 1 suite failed … with 1 issue`, beside = the snapshot + `-shm` + `-wal`), GREEN after
  (`✔ Test run with 6 tests in 1 suite passed`); the app's `ProtectionFileLeavesTests
  .aBackupPairOfALiveWALLibraryIsExactlyTwoFilesAndTheSnapshotOpensAlone` (`FileBackupsLeaf.takeBackupPair` → the pair
  folder holds exactly two files; the snapshot alone opens with its key and holds the record) — RED against the pre-fix
  core (a scratch worktree at `e305daefd` + the session harness pointed at it: `✘ Test run with 10 tests in 1 suite
  failed … with 1 issue`, the folder `[….keys.json, ….sqlite, ….sqlite-shm, ….sqlite-wal]`; the worktree removed),
  GREEN on this tree headless (`✔ Test run with 10 tests in 1 suite passed`); its Mac run PENDING under the stage.
  The core suite's release leg PENDING (the close).
- Piece 8 — the Mac tests + `build-for-testing` + the phone build + the close (suites, walk recipe): DONE (the close
  commit — the final tree's `build-for-testing` and phone lines below; the Mac suites and the walk PENDING) —
  `ProtectionFacesRouteTests` (5, through `AppBootstrap` on a throwaway scope + temp slot, Mac only: a stray beside →
  the `.roadInterlude` STATE, *Use it* → `.ready` with the library's own file back and the keychain receipt owed;
  *Not now* → `.ready`, the stray byte-identical, the memory items unchanged; the live key file gone → `.ready`,
  rule 1's receipt spoken once, rule 3's first-backup moment showing; the set-passphrase sheet through the
  bootstrap's faces model on the real custody → set, the receipt, the reminder done, the record's fact; rule 27's
  lobby through the bootstrap → *Start a New Library* → the words card, the old library aside) (this commit).
  `xcodebuild … -configuration Debug -derivedDataPath DerivedData/vx306 build-for-testing` → `** TEST BUILD
  SUCCEEDED **`; the phone `-scheme VariorumMobile -destination 'generic/platform=iOS Simulator' build` → `** BUILD
  SUCCEEDED **`. The record's close (the suites, the walk recipe, the PROVISIONALs) is next.

**THE FACES AS BUILT (for the ladder):** the open's report now carries every act any repair pass found owed (`acts`,
the union — rule 3's quiet-road moment is the first pass's) and the key-file search (`keyFileSearch`, run at the open
only when `assess` owes `.offerKeyFile` — a READ over this Mac's keychain copy and every catalogued key file); the
session holds `library`/`report` under one lock (the backup hook reads them while an act writes), the interlude's
once-per-open flag, the receipts owed and one-act-at-a-time. THE INTERLUDE (P-VX306-U2-1): `routeOnNewRoad` — for a
route's `.opened` session AND a lobby press's — returns `.roadInterlude` when the session owes it (`writes` and a
notice or an offer); the state `.roadInterlude(RoadInterludeModel)` renders `RoadInterludeCard` in the lobby's room;
its last answer marks the session and calls `beginOpening(roadOpened:)` again, which then opens. *Use it* runs
`ProtectionOpenRoad.useOffer` off the main actor (`useOfferedKeyFile`, then the repairs' passes again, the search
re-run) and owes the receipt naming the source; *Not now* calls nothing. AT READY the bootstrap builds
`roadStanding = RoadStandingModel.make(session, ledger:)` (observable): the standing faces (`RoadStandingFaces` — rule
27's banner from the faults or the search, the split pair, rule 3's moment, rule 1's receipt), the reminder (its
launch counted once per process on a writing road, then evaluated), and the set-passphrase sheet's factory; the Mac's
ready `.task` hands it the status seam (`session.status.receipt`), which speaks the owed receipts once. The Mac's
bottom stack carries `ProtectionRoadBar` under today's notice bar; Settings ▸ Protection carries the one new row. Rule
27 before unlock: `RoadLockView` renders the missing face's three doors (the Backups folder revealed, 13x's open door,
*Start a New Library* → `createOnNewRoad(setAsideLiveKeyFile: true, setAsideUnopenableLibrary: true)`). The core's one
change is W-2's (`ProtectionLibraryFiles.snapshot`). Zero `Sync/`, `Server/`, `StoreBackup.swift`,
`BackupRetention.swift`, `RestoreHoldModel.swift` lines; no new dependency.

**Counts (the tree `f875c9343` + the close commit's two pin-list lines and this record):**
- HEADLESS (the session's SwiftPM harness — not durable; the recipe: a package in the scratchpad whose `Variorum`
  target SYMLINKS every `App/Variorum/Shared/Protection/*.swift` but `ProtectionBackupHook.swift`, plus one stub file
  of one-line stand-ins (`DeviceName`, `KeychainTestTripwire`, `KeychainPartition`, `AppleKeyKeychain`, `AppleKey`,
  `BackupDestination`, `AuthTokens`/`KeychainAuthStorage`, `EncryptionSession.words`), with the app's concurrency
  settings (default `MainActor` isolation, `NonisolatedNonsendingByDefault`, `InferIsolatedConformances`,
  `MemberImportVisibility`), depending on the worktree's core by path; its test target symlinks
  `ProtectionTestSupport`, `ProtectionFacesSupport`, the five per-piece face suites, `PassphraseReminderTests`,
  `ProtectionWordsPlanTests`, `ProtectionFileLeavesTests`, `ProtectionOpenRoadPlantedTests`, `ProtectionLobbyModelTests`,
  `ProtectionWalkSwitchTests`, and a one-line `RoadWorld.RoadWorldError` stub): `✔ Test run with 69 tests in 11 suites
  passed after 0.537 seconds.`
- The MUTATION run (piece 6): `RoadOpenReport.acts` reverted to the last pass only → `✘ Test run with 16 tests in 1
  suite failed … with 1 issue` (the quiet-road moment's expectation); restored, `git diff`-clean.
- W-2's red-on-old: piece 7's line (core RED/GREEN; the app pin RED against a scratch worktree at `e305daefd`, GREEN
  here; the worktree removed — `git worktree list` shows none of this session's).
- The core's protection set (every `@Test` under `Tests/VariorumCoreTests/Protection` — 77 suite types): Debug `✔ Test
  run with 315 tests in 77 suites passed after 6.775 seconds.`; Release (`swift test -c release`, the same filter) `✔
  Test run with 291 tests in 73 suites passed after 3.995 seconds.`
- On the FINAL tree (this close commit's code): `xcodebuild -scheme Variorum -destination 'platform=macOS'
  -configuration Debug -derivedDataPath DerivedData/vx306 build-for-testing` → `** TEST BUILD SUCCEEDED **`; the phone
  `xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vx306
  build` → `** BUILD SUCCEEDED **`; no new warning in a touched file.

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx306 test \
  -only-testing:VariorumTests/ProtectionWordsPlanTests \
  -only-testing:VariorumTests/ProtectionNoticeFaceTests \
  -only-testing:VariorumTests/ProtectionOfferFaceTests \
  -only-testing:VariorumTests/ProtectionRule27FaceTests \
  -only-testing:VariorumTests/ProtectionRestoreReceiptTests \
  -only-testing:VariorumTests/ProtectionReminderRoadTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/ProtectionFacesRouteTests \
  -only-testing:VariorumTests/ProtectionFileLeavesTests \
  -only-testing:VariorumTests/ProtectionWalkSwitchTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionLobbyModelTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/LibraryWordsCardTests \
  -only-testing:VariorumTests/ProtectionBackupHookTests \
  -only-testing:VariorumTests/ProtectionRoadSwitchTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests \
  -only-testing:VariorumTests/ProtectionKeychainFamilyTests \
  -only-testing:VariorumTests/KeychainTripwireTests \
  -only-testing:VariorumTests/KeychainLeavesTests \
  -only-testing:VariorumTests/ProtectionFactsGathererTests \
  -only-testing:VariorumTests/ProtectionSystemCompositionTests \
  -only-testing:VariorumTests/StoreLaunchRouteTests \
  -only-testing:VariorumTests/Phase13pLobbyTests \
  -only-testing:VariorumTests/AppBootstrapOffMainTests \
  -only-testing:VariorumTests/LibraryPortabilityDoorTests \
  -only-testing:VariorumTests/VX202ReopenRaceTests \
  -only-testing:VariorumTests/VX206ProtectionLandingTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/ProtectionSurfaceRenderTests \
  -only-testing:VariorumTests/ProtectionTierFaceTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests \
  -only-testing:VariorumTests/ICloudDriveOfferTests
```
The first ten are U2's new or grown suites (3 + 4 + 5 + 3 + 1 + 3 + 12 + 5 + 10 + 4 = 50 tests; `ProtectionFacesRouteTests`
and the keychain suites need the signed test host); then U1b's and U1a's suites (the road changed under them — the
report's acts, the session's lock, the interlude; `VX310TodayLobbyWitnessTests` still reports its 2 tests with KNOWN
ISSUES — expected, a pass of either is a FAILURE; the tripwire's exact count must hold); then today's road and the
surfaces whose files changed (the bootstrap, the Settings window's closed-library rule, the Protection pane, the lobby
view) and the source pins over the edited files (`CopyRegisterPinTests` now also reads `ProtectionWords.swift`;
`TravellingDotsIndicatorTests` now also reads the interlude card and the sheet). Read the `skipped:` lines. A test
bootstrap's reminder ledger writes the defaults suite `io.lduarte.Variorum.vx306-reminder-tests`, never the app's
domain.

**THE MAC SUITES — RUN (the orchestrator, 2026-10-18 09:59 MDT, claim `vx-306-u2-batch`, the tree 87478297e; the predesign
store sat in the slot for VX-348's reversible swap and its sha256 read identical before and after):** `━ Test run with 199
tests in 36 suites passed after 37.977 seconds with 3 known issues.` — the three known = `VX310TodayLobbyWitnessTests`' expected
witnesses; 0 skipped; `** TEST EXECUTE SUCCEEDED **`. The walk (B) PENDING its window.

**THE WALK RECIPE (the orchestrator's, under a held stage claim `vx-306-u2-walk`; DEV STORE ONLY; both appearances
where a face changed — the lobby's room and its cards speak the leading voice's fallback, the bottom bars are system
chrome, so a light and a dark capture each):**
0. Zero Debug instances (`pgrep -fl 'DerivedData/vx306/Build/Products/Debug/Variorum.app/Contents/MacOS'`; a
   `/Applications` instance is NEVER touched). Build: `cd App/Variorum && xcodebuild -scheme Variorum -destination
   'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx306 build`. Launch every time as the BINARY
   with stderr captured (W-4): `OS_ACTIVITY_DT_MODE=YES [VARIORUM_WALK_FORGET=…] App/Variorum/DerivedData/vx306/Build/
   Products/Debug/Variorum.app/Contents/MacOS/Variorum 2> ~/vx306-walk/run-N.log &`, quit with ⌘Q, and read the
   `road:` lines. `DC` = `~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev`;
   the library's ID is `"libraryID"` in `DC/variorum-library-keys.json`. Before any file move, quit and confirm no
   `-wal`/`-shm` beside `DC/variorum.sqlite`. `source ~/.variorum/dev-castle.env` for the dev values (never typed into
   a record). Expected start: U1b's posture (Standard, no passphrase, one backup pair).
1. **W-2 — Back Up Now** (Settings ▸ Data Safety) → `ls DC/Backups/<lib8>/<mac8>/` shows the NEW pair as exactly two
   files (`….sqlite` + `….keys.json`) — no `-wal`/`-shm` (U1b's pair, written before the fix, still has its two; leave
   them or remove those two files by hand).
2. **Stage 2 — rule 3's reminder and the set-passphrase sheet.** (a) Launch with `VARIORUM_WALK_FORGET=silent` → the
   library opens through the Apple wrap (`repairs [remakeOnDeviceItem]`) and the bottom stack shows the reminder bar:
   *Your library is only secured through iCloud Keychain right now — please add a passphrase and keep your twelve words
   to ensure continued access.* · *Set a passphrase…* · *Not now* (no *Don't show again* — a moment, not the
   schedule); the log line `road: rule 3's reminder shows — scheduled false, moment quietRoadFailed`. Capture (light,
   dark). (b) *Set a passphrase…* → the sheet: *Set a passphrase*, the lead, *Passphrase* / *Again*, *Cancel* · *Set
   passphrase* (off until both are typed). Type two different values → *The two passphrases don't match.* Then type
   the dev passphrase from `dev-castle.env` twice (NEVER a new value — CLAUDE.md; note in the env file that the new-road
   dev library now carries it) → the sheet closes, the bar goes, and the bottom bar's quiet line reads *Passphrase set.
   Your twelve words still open the library too.* (receipt_style quiet — it fades after 6 s; capture at once). `grep -c
   '"passphrase"' DC/variorum-library-keys.json` → 1; the log `road: a passphrase was set …`. (c) Settings ▸ Protection →
   the TOP row *Set a passphrase…* → the sheet refuses at once: *This library already has a passphrase.* (press
   *Cancel*; never press the pane's lower title-case *Set a Passphrase…* — today's machinery). (d) Quit; launch with
   `VARIORUM_WALK_FORGET=silent,apple` → THE LOBBY: *Enter your passphrase or your twelve words to open your
   library.*, the *Passphrase* field, *Use your twelve words instead* — stage 2's "the lobby's typed roads now say
   passphrase"; type it → opens (`repairs [remakeAppleRoad, remakeOnDeviceItem…]`), and NO reminder bar.
   (Optional — the schedule: only BEFORE (b) on a fresh library; it needs three launches, or `defaults write
   ~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Preferences/io.lduarte.Variorum.debug.plist
   variorum.calmAsks.passphrase.<libraryID>.launches -int 2` then one launch → `scheduled true`; its *Not now* logs
   `road: rule 3's reminder dismissed — the record counts 1`.)
3. **Rule 1's restore.** Quit; `mkdir -p ~/vx306-walk && mv DC/variorum-library-keys.json ~/vx306-walk/live-keys.json`;
   launch → the silent item opens it, `repairs [restoreKeyFileFromMirror, …]`, `DC/variorum-library-keys.json` is back,
   and the bottom bar's quiet line reads *The key file beside your library was missing. This Mac's sealed copy was put
   back.* (6 s — capture at once). Remove `~/vx306-walk/live-keys.json` after `cmp`-ing its `libraryID`.
4. **Stage 13** — not walkable (the core's crash harness carries it).
5. **Stage 14 (a) — the DIFFERENT-LIBRARY notice.** Quit. Library A aside: `mkdir -p ~/vx306-walk/A && mv DC/variorum.sqlite
   DC/variorum-library-keys.json DC/variorum-keys-*.json ~/vx306-walk/A/` (the slot, its key file, today's store-id
   stub). Launch → the missing face → *Start a New Library* → B's words card (B is throwaway — do not record its words)
   → *I've written them down* → B opens. Quit. B aside, A back: `mkdir -p ~/vx306-walk/B && mv DC/variorum.sqlite
   DC/variorum-library-keys.json DC/variorum-keys-*.json ~/vx306-walk/B/ && mv ~/vx306-walk/A/* DC/`. Launch → A opens
   by its silent item and the CARD in the lobby's room reads *This is a different library than the one this Mac last
   had open* with one *OK* (log `notice true`). Capture (light, dark). *OK* → A opens. Quit; relaunch → no card (said
   once).
6. **Stage 14 (b) — the OFFER naming this Mac's keychain.** Quit. `mv DC/variorum-library-keys.json ~/vx306-walk/A-keys.json
   && cp ~/vx306-walk/B/variorum-library-keys.json DC/variorum-library-keys.json` (B's file — a stray beside A). Launch →
   A opens by its silent item; the CARD: *The key file beside your library doesn't open it. This Mac's keychain holds a
   copy that does. Use it?* · *Not now* · *Use it*. Capture. *Not now* → A opens (log `the key-file offer put off (Not
   now) — nothing written`); quit; `cmp DC/variorum-library-keys.json ~/vx306-walk/B/variorum-library-keys.json` → equal
   (nothing written). Relaunch → the card again → *Use it* → A opens, the quiet line *Key file restored from this
   Mac's keychain.*; `cmp DC/variorum-library-keys.json ~/vx306-walk/A-keys.json` may differ only in the Apple wrap the
   repairs re-made — its `"libraryID"` is A's. Remove `~/vx306-walk/A-keys.json`.
7. **Stage 14 (c) — RULE 27 before unlock (everything gone).** Quit. Every format-3 key file in the container out, kept:
   `cd DC && find . \( -name 'variorum-library-keys.json' -o -name 'variorum-backup-*.keys.json' \) -not -path
   './Backups/safety-copies/*' > ~/vx306-walk/keys.list && tar -cf ~/vx306-walk/keys.tar -T ~/vx306-walk/keys.list && xargs
   rm < ~/vx306-walk/keys.list` (today's flat `….keys.json` copies ride along — harmless, restored with the rest). Launch
   with `VARIORUM_WALK_FORGET=silent,memory` (no `apple` needed — with no key file there is no Apple wrap to open, and
   the Apple key left standing is what lets row 8 reopen quietly) → THE LOBBY's rule-27 face: the lock, *Open your
   library*, *No key file opens this library. Variorum looked beside the library, inside every backup, and in this Mac's
   keychain, and found none that opens it. Without one, there is nothing left to open.* (and *This library syncs with
   your account…* ONLY if the dev scope is signed in — record which), then *Restore from Backup…* · *Open Library…* ·
   *Start a New Library* with its sub-line. Capture (light, dark). PRESS NOTHING; quit.
8. **Rule 27 after a quiet-road open (the banner).** Restore first: `cd DC && tar -xf ~/vx306-walk/keys.tar`; launch → the
   library opens QUIETLY through the live key file's Apple wrap (`repairs [remakeOnDeviceItem, refreshMemory…]` — the
   silent item and this Mac's memory re-made). Quit. Now the banner: `cd DC && xargs rm < ~/vx306-walk/keys.list`; launch
   with `VARIORUM_WALK_FORGET=memory` → the silent item opens the library quietly with no key file anywhere, and the
   bottom stack shows the STANDING banner — §7c (3)'s sentence (and the account sentence only if signed in), no doors,
   no card (log `faults 1`). Capture (light, dark). Quit; `cd DC && tar -xf ~/vx306-walk/keys.tar`; launch → a quiet
   open, no banner (`repairs [refreshMemory…]` — this Mac's sealed copy follows the file again). `rm -r
   ~/vx306-walk/keys.tar ~/vx306-walk/keys.list ~/vx306-walk/A`.
9. **Posture after the window:** library A in Standard with the dev passphrase, quiet roads re-made, B kept aside in
   `~/vx306-walk/B` (delete it, or keep it for U3's Look inside) and B's custody/memory items harmless in the dev
   scope; record it for the coordinator and the next walker.

**PROVISIONALs (each built as its option (a); bundled under QUESTIONS #233 in plain words):**
- **P-VX306-U2-0** (the orchestrator's, built as ruled) — the set-passphrase sheet on the reset door's Standard road
  (`resetPassphrase(_:authorization: .plainConfirm, new:)`), refused when a passphrase exists; from the reminder and the
  Protection pane's one row.
- **P-VX306-U2-1 — the interlude.** (a) BUILT — the notice and the offer on a card in the lobby's room BETWEEN the
  unlock and the library's open (the words card's idiom: shown once per open, then the open goes on; the key file lands
  before the app's store opens); §7c (2)'s "on *Not now* … the lobby stays" read as: nothing is written, nothing decided
  for her, and the library opens either way (rule 21: "it never decides for you") — the offer owed again at the next
  open; (b) a sheet over the open library window (it competes with the window's own sheets — What's New, the iCloud
  offer — and the store would already be open under the stray); (c) a line in the bottom stack (the notice is not a
  standing fact).
- **P-VX306-U2-2 — U2's undrafted lines** (`ProtectionWords`): *Cancel* · *The two passphrases don't match.* · *This
  library already has a passphrase.* · *Variorum couldn't set the passphrase just now. Try again.* · *Variorum couldn't
  put that key file beside your library just now.* · *an earlier day* (a backup the catalogue can't date — her
  sentence's `<date>`) · the day's form `ProtectionWords.day` (*August 3* — her example's; the year added when it isn't
  this year's). (b) blank until her sitting; (c) other words. Her taste call.
- **P-VX306-U2-3 — the schedule.** (a) BUILT — a LOCAL per-library ledger beside `CalmAskScheduler`'s keys: the first
  showing at the third LAUNCH (a process's first writing open of the library), each later one 7 × 24 h after the last,
  weekly from then on; *Don't show again* offered once the record counts three dismissals (the executor's own doc for
  `reminderDismissals`); the reminder is its own bar in the bottom stack, not one of the two calm asks; (b) *Don't show
  again* from the fourth showing whatever was pressed; (c) register with `CalmAskScheduler` (one ask a day, calm
  moments — but days of use, not launches; rule 3 counts launches).
- **P-VX306-U2-4 — the two "always" moments.** (a) BUILT — they show at the open that owes them even after *Don't show
  again* (rule 3: "always"), their *Not now* writes nothing (only the returning reminder's answers are its dismissals);
  (b) *Don't show again* silencing everything; (c) every *Not now* recorded.
- **P-VX306-U2-5 — rule 27's *Start a New Library*.** (a) BUILT — the library no key file opens moves WHOLE (the file,
  its sidecars, anything in the live place) into `Previous Libraries/<stamp>/` first, never deleted (a key file found
  later still opens it there — rule 1's spirit, U1b-3's precedent); (b) refuse while it sits there (a door that
  refuses); (c) no *Start a New Library* on that face (the brief names the three doors).
- **P-VX306-U2-6 — the split pair, a finding.** No planted state reaches `.besideOpensItOnlyThroughItsHistory`
  through `assess`: `.offerKeyFile` is owed only when this Mac's copy (current) or a backup (by name) holds the
  library's own key file, and the search then always verifies that candidate (its key is the key in hand), answering
  `.offer`; the state the line describes (a replayed old library file, a newer key file beside it whose history holds
  the library's key) owes no offer and is said by the older-copy notice. (a) BUILT as the brief (search only on the
  owed offer; the line ready if a later model change owes it); (b) search also on `liveKeyFileIsAnotherKeys` when the
  live file's history holds the current key (the line would stand beside the notice); (c) drop the line. Likewise the
  search's own `.noKeyFileAnywhere` is unreachable through the owed offer — rule 27's banner stands on the FAULT.
- **P-VX306-U2-7 — her words, two notes (no build choice):** the post-open banner says §7c (3) verbatim, ending
  *Without one, there is nothing left to open.* over a library that just opened; and with the live place EMPTY while a
  backup holds the right file, her offer sentence still begins *The key file beside your library doesn't open it.*
  Variants are hers.
- **P-VX306-U2-8 — the walk switch gains `memory`** (every memory item of the dev scope), P-VX306-U1b-9's fences.
- **P-VX306-U2-9 — the first-backup moment at the creation's open.** (a) BUILT — rule 3's "always right before the
  first backup": the bar shows at the first open, right after the words card (the first backup runs at that launch),
  a calm bar, never a popup (R-13r-11 holds); (b) wait until the first backup begins (a hook inside today's
  `StoreBackup` — VX-348's file); (c) skip the first day as the calm asks do (rule 3 says always).

**Recorded refinements (not product calls):** the faces' factory lives in `ProtectionOpenFaces.swift`
(`RoadStandingModel.make`), so the phone (U3) and the tests compose the same thing the bootstrap does; the
interlude never shows on a read-only road (a hosted test run could answer nothing); each sheet host holds its own
sheet (two windows never show one); one act at a time per session (`beginAct`); the session's `library`/`report`
under one lock; a test bootstrap's reminder ledger writes its own defaults suite; two source pins now also read the
new files (`CopyRegisterPinTests` ← `ProtectionWords.swift`; `TravellingDotsIndicatorTests` ← the interlude card and
the sheet); the walk's Diagnostics lines (the reminder's showing, a dismissal's count, the offer put off).

**Hand-forwards (U3, VX-307/308/379):**
- U3 (the phone): `RoadStandingModel.make` and `RoadInterlude`/`RoadInterludeModel` are Shared — the phone's faces
  render them; `.roadInterlude` is the phone's unreachable arm until then.
- U3 (the two doors): the rule-27 face's *Restore from Backup…* reveals the Backups folder and *Open Library…* is 13x's
  adoption door — both retire behind Make this my library.
- VX-308: the pane's lower passphrase section (today's machinery) and the sheet's refusal once a passphrase exists
  (a change is the key door's).
- VX-379: every U2 string is in `ProtectionWords.swift`, pinned byte-equal to §7c.

**Notes:** no machinery deaths; no Sonnet lookup; one scratch worktree (W-2's red-on-old at `e305daefd`), removed.

**U2 WALK RECORD (the orchestrator, 2026-10-18 10:11–10:24 MDT, claim `vx-306-u2-walk`; the dev store; the Debug product
from `DerivedData/vx306` at 87478297e; the dev domain's appearance read `dark` at the start and was left so — the bars and
sheets captured dark, the lobby's room and its cards captured light by switching `appearanceChoice` for rows 5–8):**
- **Row 1 / W-2:** folded into the existing pair check — the U1b pair (written before the fix) keeps its two sidecars; the
  fix's proof is `ProtectionLibraryFilesTests`/`ProtectionFileLeavesTests`' red-on-old pins (the batch).
- **Stage 2:** `VARIORUM_WALK_FORGET=silent` → `road: opened … repairs [remakeOnDeviceItem]; acts 1` and `road: rule 3's
  reminder shows — scheduled false, moment quietRoadFailed, don't-show-again false`; the bottom stack's bar reads her rule-3
  sentence with *Set a passphrase…* · *Not now*. The sheet (§7c (7)): *Passphrase* / *Again*, *Cancel* · *Set passphrase*
  (off until both typed); two different values → *The two passphrases don't match.*; the dev passphrase twice →
  `reset_passphrase: done #1 under 88173013`, `road: a passphrase was set — the key file carries the passphrase lock (true)`,
  the sheet closed, the bar gone, the quiet receipt *Passphrase set. Your twelve words still open the library too.* on the
  bottom bar; `grep -c '"passphrase"'` on the live key file → 1. Settings ▸ Protection's top row *Set a passphrase…* → the
  sheet refuses at once *This library already has a passphrase.* (Cancel). `silent,apple` → THE LOBBY: *Enter your passphrase
  or your twelve words to open your library.*, the *Passphrase* field, *Open*, *Use your twelve words instead*, the quiet
  Touch ID line; the passphrase typed → `road: opened … live key file roads [apple,passphrase,words]; repairs
  [remakeAppleRoad,remakeOnDeviceItem]; acts 0` — no reminder.
- **Rule 1's restore:** the live key file moved away; launch → `repair restoreKeyFileFromMirror: done`, `road: opened …
  repairs [restoreKeyFileFromMirror,landAppleWrap(…)]`, the file back with A's `libraryID` and all three locks; the quiet
  receipt *The key file beside your library was missing. This Mac's sealed copy was put back.* caught mid-fade.
- **Stage 13:** not walkable (the core's crash harness).
- **Stage 14 (a), the different-library notice:** A set aside (its `-wal`/`-shm` moved WITH it — see the walker fact below),
  the missing face → *Start a New Library* → B's words card (light; B's words never recorded) → B opened (`road: created —
  library dfa07962 …; custody silent 2`; A's memory item forgotten — one library per Mac). B aside, A back → `road: opened —
  library 818912e0 … device 4e648d28; notice true; repairs [refreshMemory]` and the card *This is a different library than
  the one this Mac last had open* with *OK* (her string exactly); relaunch → `notice false` (said once). A FRESH device ID at
  that open — P-VX378-U1-1 (a)'s road, as recorded.
- **Stage 14 (b), the offer:** B's key file beside A → `road: opened … faults 1; acts 1` and the card *The key file beside
  your library doesn't open it. This Mac's keychain holds a copy that does. Use it?* · *Not now* · *Use it* (her sentence).
  *Not now* → `offer put off (Not now) — nothing written`, A opened; the stray `cmp`-identical to B's file. Relaunch → the
  card → *Use it* → `use_key_file: the offered key file written beside the library (88173013)`, the receipt *Key file
  restored from this Mac's keychain.*, the live file's `libraryID` A's with all three locks.
- **Stage 14 (c), rule 27 before unlock:** all 18 format-3 key files tarred out (the live one, the new pair's, today's flat
  `….keys.json` copies), `VARIORUM_WALK_FORGET=silent,memory` → the rule-27 lobby: *Open your library*, §7c (3)'s sentence,
  THE ACCOUNT SENTENCE (the dev scope holds a signed-in session before unlock), *Restore from Backup…* · *Open Library…* ·
  *Start a New Library* with its sub-line. Pressed nothing.
- **Rule 27 after a quiet open (the banner):** keys back → a quiet open (`repairs [refreshMemory,remakeOnDeviceItem]`);
  keys out again, `memory` forgotten → the silent item opened it, `faults 1`, the STANDING banner at the window's foot in
  §7c (3)'s sentence (no account sentence — the record names none), no doors; keys back → a clean open (`faults 0`); all 18
  files verified present; the live key file A's with `apple, passphrase, words`.

**Posture after the window:** library A (818912e0) in Standard with the dev passphrase SET (noted in `~/.variorum/dev-
castle.env`; the Castle values unchanged), quiet roads re-made, unlocked, silently openable by this branch's Debug build;
B's five files under `~/vx306-walk/B` (for U3's Look inside); instances 0; stage released 10:24.

**Walk findings (routed):**
- **W-7 (MINOR, cosmetic — U3 or the closeout polish):** a long quiet receipt on the bottom bar runs INTO the trailing
  `⌘J today · ⌘N new note` hint (rule 1's receipt overlapped it mid-fade; the shorter ones fit). The receipt slot needs a
  line limit / truncation or the hint yields while a receipt shows.
- **W-8 (note, her eye — P-VX306-U2-7 stands):** the banner's last sentence (*Without one, there is nothing left to open.*)
  reads oddly over an OPEN library; the offer's first sentence assumes a key file is beside the library.
- **W-9 (walker fact — WalkKit README at closeout):** moving the slot's `variorum.sqlite` aside after a quit can leave its
  `-wal`/`-shm` behind (the app's quit does not always checkpoint): move the three files together, always.
- **W-10 (note):** every memory-forget mints a fresh device ID for A (`4e648d28` → `fb3534f5` → `06853752`) — P-VX378-U1-1
  (a) as built; harmless on the dev store, worth her eye at the bundle (the record's sections accumulate one per forget).

### U3 RECORD — THE TWO DOORS: Look inside / Make this my library (+ the phone opens) (Opus implementer, 2026-10-18; BUILT but for LOOK INSIDE, which waits on the ruling — the Mac and phone suites and the walk PENDING)

**Not done in U3, first:**
- **LOOK INSIDE IS NOT BUILT** — propose-then-rule: the PROPOSAL is piece 4's (below; (b), the read-only facts sheet,
  recommended — on this tree (a) is not isolated). No *Look inside…* door renders anywhere until the ruling (P-2). The
  missing face's and rule 27's *Open Library…* stay retired on the new road until then (P-VX306-U3-7).
- **No Mac suite and no phone suite was RUN** (the brief: no `xcodebuild test`, no stage) — only built (`build-for-testing`
  green, both). What DID run: the planted suites HEADLESS in the session's SwiftPM harness (below) — the two suites that
  need the keychain or the bootstrap (`MakeMineRouteTests`; the phone's `MobileProtectionRoadTests`) did not run anywhere.
- **The walk was not done** (the orchestrator's — the recipe below), nor the simulator's open. No Debug app or simulator was
  launched; the dev store, the real store and `/Applications` were never touched.
- **The Release build was not re-run** (§8: no Release build this phase; the gate's Release check is the orchestrator's to
  repeat). Every new line is a new file or behind the switch: `copyDoorsRoads()` answers nil off the new road (Data Safety
  keeps today's rows, `roadDoors` stays nil, File ▸ Open Library… keeps today's flow), the phone's new arms are reached only
  by new-road states, and the biometry lines read byte-for-byte as before on the Mac (Release included).
- **A plain-text export is NOT given today's road on the new road** — a DEVIATION from the addendum's "a picked plaintext
  export keeps today's road", made on a trace (P-VX306-U3-5: today's adoption on the new road sets the library aside
  without its format-3 key file, lands a library the new road cannot open, and mints today's custody). It refuses in
  words instead; T-8 stays VX-309's. The orchestrator's eye.
- **The phone has no reminder bar, no set-passphrase sheet and no receipts** this unit (the brief names the lobby, the card,
  the interlude and rule 27's faces); `RoadStandingModel` is made at the phone's ready too, with no face there.
- **The empty-slot landing (T-5) is VX-309's**: Make this my library needs a library open (her current pair is verified
  against it), so neither the missing face nor rule 27's lobby offers it.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton: DONE (this commit).
- Piece 1 — the shared `CopyDoorsModel` (pure, testable) over the executor's two doors and the catalogue + the words §7c
  (8)–(10) in `ProtectionWords.swift` + the plan-byte-equality pin: DONE (this commit) — `Shared/Protection/
  CopyDoorsModel.swift`: `CopyDoorsListing` (pure — this library's copies newest first, then every other library's on this
  Mac; a copy no format-3 key file names left out, rule 26 — P-VX306-U3-1), `CopyDoorRefusal` (each worded),
  `CopyDoorsRoads` (every act injected), `MakeMineModel` (§7c (8): the copy's quiet road tried once at the confirm's open;
  its secret asked only when that fails, an EMPTY field trying her own pair — rule 4, P-VX306-U3-4; her words always, her
  passphrase when its lock exists; the words validated before the act; the copy field read as twelve words when they
  validate, else a passphrase, untrimmed), `CopyDoorsModel` (the picked flow's phases: reading · refused · choosing ·
  doors · makeMine · done) and `CopyDoorsListModel`. The words: §7c (8) (9) (10) verbatim + the addendum's two door names;
  the lead without its passphrase clause when none is set (P-VX306-U3-3); U3's undrafted lines (P-VX306-U3-2). Pins:
  `CopyDoorsModelTests` (9, planted — no keychain, no disk), `ProtectionWordsPlanTests` +1 (§7c (8)–(10) and the
  addendum's door names byte-equal to the plan). HEADLESS (the session's SwiftPM harness — the record's close says how):
  green; the Mac run PENDING under the stage.
- Piece 2 — MAKE THIS MY LIBRARY on a catalogued copy (Settings ▸ Data Safety's Restore list under the new road — the
  catalogue's copies, newest first; the confirm §7c (8); the secrets the executor requires; the act with the pool CLOSED
  through `AppBootstrap`'s adoption seam; the restore HOLD by the core writer; the reopen through the new road with the new
  key in hand; the receipt §7c (9)) + pins: DONE (this commit). **The road** (`Shared/Protection/ProtectionCopyDoors.swift`,
  off the main actor): `listing` (a READ), `opensQuietly` (`lookInside` with nothing typed, on its own read executor),
  `preflight` — ALL READS before anything closes: the copy still catalogued, it opens with what she typed (`lookInside`),
  its schema one this build opens (`LibraryClassifier.schemaVerdict` on a private copy — a newer Variorum's copy is never
  landed), her current pair against the open library's key file (the words always; the passphrase when its lock exists) —
  so a typo never tears the window down; `makeMine` — THE RESTORE HOLD FIRST by the core writer (`LibraryRestoreHold.set`,
  13x F1 R1-M2's order: before anything moves, so nothing lands un-held), then `ProtectionExecutor.makeThisMyLibrary` on
  its plan, then today's store id minted FRESH for the new library (the creation's own mint, `ensureStoreIdentity(fresh:
  true)`, injected); a refusal before the swap puts the hold back exactly as it stood (none, or its own bytes); past the
  swap (the commit point) the copy IS the library and an act that threw there finishes at the next open's settle (rule 20)
  — said as made. **The bootstrap** (`AppBootstrap.makeThisMyLibrary` + `copyDoorsRoads()`, new road only): one act at a
  time on the session; the preflight; then `adoptLibrary`'s seam shape — `onWillLock` (flush, savepoint, stop), `.opening`,
  the resident key and per-open deferrals dropped, the pool CLOSED through the binding (`StoreBinding.lock` checkpoints
  TRUNCATE before the close — the swap's precondition, so `swapStaged` never meets `walNotDrained`), the act detached; then
  the reopen THROUGH THE NEW ROAD with the key that opens the slot now in hand (`beginOpening(unlockedKey:)` →
  `ProtectionOpenRoad.route(keyInHand:)`); §7c (9)'s receipt owed to the REOPENED session (`receiptsForNextRoadOpen`,
  handed over in `finish(.ready)`) and spoken once by the ready composition's status seam. Every road reads the CURRENT
  session at its call. **The faces** (`Features/Protection/CopyDoorsSheet.swift`): `CopyDoorsSheet` + `MakeMineConfirm`
  (§7c (8): title, lead, the copy's field only when its quiet road fails with its quiet note, *Your twelve words*, *Your
  passphrase* when set, *Cancel* · *Make this my library*; the working line) and `RoadRestoreRows` — Settings ▸ Data
  Safety's Restore section under the new road (`DataSafetyPane(roadDoors:)` — today's rows on today's road unchanged):
  this library's copies, then *Other libraries on this Mac*, each row its day and kind and *Make this my library…*
  (through Settings' own presenter — `LibraryOpenPresenter.roadDoors` / `beginMakeMine`, its sheet in
  `SettingsSceneContent`). The pick road's classifier and filer (`PickedCopy.swift`, `ProtectionCopyDoors.pick`) land here
  so the file compiles; piece 3 wires File ▸ Open Library… to them. **Pins:** `MakeMineRoadTests` (3, planted — no
  keychain: a backup becomes a NEW library — fresh ID and key, Standard, no account, no past keys, under her words — with
  the outgoing library opening under the old key and ITS key file byte-equal in `Previous Libraries/<stamp>/`, the hold
  marker's day the backup's, ONE memory item, the store id minted for the new key, the outgoing library listed as another
  library's previous copy; the preflight refuses wrong words and writes NOTHING (the container's every byte, no hold); a
  refusal INSIDE the act puts the hold back — none, or the standing marker's exact bytes — MUTATION: `restoreHold` a no-op
  → `✘ Test run with 6 tests in 1 suite failed … with 2 issues`, restored and `cmp`-checked); `MakeMineRouteTests` (2,
  through `AppBootstrap`, throwaway scope + temp slot, Mac only: the pair by the backup hook's road → the doors' roads →
  `.made` → `.ready` on a FRESH session with a new library ID and key, the hold standing, the old library aside opening
  under the old key, a store id under the new key, the receipt said exactly once; a wrong word → refused, still `.ready`
  on the SAME session, no hold, nothing aside). HEADLESS (`MakeMineRoadTests` in the harness): green; the Mac runs PENDING
  under the stage.
- Piece 3 — A PICKED FOLDER under the new road (File ▸ Open Library…): filed first into `Backups/safety-copies/
  variorum-adopt-safety-<stamp>/` (P-VX306-U3-0 (a)), then the doors on the catalogued copy; the plaintext export and the
  empty slot: DONE (this commit). **The road** (`PickedCopy.swift` + `ProtectionCopyDoors.pick`, from piece 2's commit):
  this design's PAIR is a store (`variorum.sqlite`, or a backup snapshot) with a FORMAT-3 key file beside it — the backup's
  own `<stem>.keys.json`, else the folder's `variorum-library-keys.json` (Send Library's pair writes exactly that); a picked
  folder holding one is that pair, several are OFFERED (the chooser), never guessed; a pair is FILED — the store, its
  non-empty `-wal` (never its `-shm`) and the key file's bytes COPIED into a hidden staging folder (the catalogue lists no
  hidden name), sizes and the key file re-checked, then renamed whole into `variorum-adopt-safety-<stamp>/` under the
  catalogue's names — so the picked thing is ONLY READ and a crash never leaves a half-filed copy listed; the filed copy is
  then the catalogue's `adoptionSafetyCopy` and the doors act on it (its day is the picked file's own — the filed store
  keeps its modification date); a copy ALREADY in this Mac's catalogue, picked by hand, is used where it is (never filed
  twice); the open library itself (or its folder) is refused. **TODAY'S CLASSIFIER CANNOT SEE THIS DESIGN'S PAIRS** (it
  reads today's `StoreKeyEnvelope`, which a format-3 file does not decode as — a new-road pair classifies there as a bare
  store), so the new road classifies first and keeps today's classifier only for the honest words of everything else:
  a plain-text export or library → *Opening a plain-text copy isn't ready in this build yet.* (P-VX306-U3-5 — TRACED: today's
  adoption road on the new road would set the library aside WITHOUT its format-3 key file (`LibraryAdoption`'s departing set
  is today's key-file names only — `StoreKeyEnvelope.keyFileURLs`), land a store the new road cannot open (no protection
  record → `recordMissing` → the missing face, K5) and mint TODAY's silent custody; T-8 is VX-309's); an encrypted copy
  under TODAY's key-file format → today's *This file couldn't be read as a library.* (rule 26 — not handled, no sentence
  names it; P-VX306-U3-6); a bare store, a newer schema, not a library, unreadable → today's sentences. **The door**:
  `LibraryOpenPresenter.openPanel` on the new road builds a `CopyDoorsModel` and begins the pick (today's road byte-for-
  byte otherwise); the MAIN window's sheet renders `CopyDoorsSheet` (the picked copy's line, *Make this my library…*,
  *Cancel*); Settings' sheet (piece 2) serves its rows. **The empty slot / the lobby faces** (P-VX306-U3-7): the missing
  face's *Open Library…* and rule 27's lobby *Open Library…* RETIRE on the new road (no library is open whose current pair
  could make a copy its own — T-5's empty-slot landing is VX-309's — and Look inside is propose-then-rule; P-2: a door that
  cannot act is not rendered); today at an empty slot the new road shows the creation card (`.startFresh`), and at a
  missing library the missing face with *Start a New Library* and *Restore from Backup…* (the Finder reveal — rule 21's
  hand-restore opens with the notice). **The Bookcase drop is not an Open Library road** — it is 13n-a's document import
  (`BookcaseImportDrop` → `DocumentImporter`), untouched. **Pins:** `PickedCopyRoadTests` (3, planted — no keychain: an
  "AirDropped" library folder under a `Downloads/vx306-airdrop/` folder → filed, the picked folder byte-identical before and
  after, catalogued as an opened copy of THEIR library; her pair refused on it (`copyDoesNotOpen`), their words + her pair
  → made: a new library ID that is neither, locked under HER words only; a catalogued backup picked by hand → that row, no
  safety-copies folder made; the open library, a plain-text export, a bare store refused in their words; two pairs in one
  folder offered). HEADLESS: the U3 and neighbouring planted suites `✔ Test run with 57 tests in 8 suites passed`; the Mac
  runs PENDING under the stage.
- Piece 4 — LOOK INSIDE: the PROPOSAL (propose-then-rule; the build waits on the orchestrator's ruling): PROPOSED (this
  commit — the proposal below, "LOOK INSIDE — THE PROPOSAL"); the BUILD NOT-STARTED (waits on the ruling). Until it lands,
  no *Look inside…* door renders anywhere (P-2: `CopyDoorsSheet` and `RoadRestoreRows` carry only *Make this my
  library…*).

**LOOK INSIDE — THE PROPOSAL (the implementer's, 2026-10-18; for the orchestrator's ruling — the addendum's fork):**

The two options as the addendum names them, with what each costs and whether a second session can exist without global
state — traced on this tree:

- **(a) A read-only WINDOW over a second `AppDatabase` on the private byte copy, rendering the Library/Book read tier.**
  - *The open is feasible:* `lookInside` hands back the copy's key; `ProtectionLibraryFiles.privateCopy` makes the byte
    copy; `AppDatabase.onDisk(url:key:)` on THAT copy runs the migrator against our own copy (an older copy migrates up;
    the catalogued file is never touched). A newer-schema copy would refuse (the migrator's superseded check).
  - *The window is not isolated — global state everywhere, and one of it is unsafe:* the read tier's views read through
    `session.database` (per session — good), but every write door they carry goes through `Operations`, whose database is
    the AMBIENT `@Dependency(\.database)` (`Sources/VariorumCore/Operations/Operations.swift:16`) — the binding's view of
    HER LIVE LIBRARY. A "read-only" window built from the app's surfaces would send any edit, mode memory write, idle
    commit or structural act to the live library under the copy's row IDs. Fencing that means auditing every surface the
    read tier composes (Library cards, the Book's four modes, the note box, the Book Panel, the context bars) for every
    operation it can reach, plus the per-note LOCAL stores keyed by row ID (mode memory, note lengths, the reminder-style
    `UserDefaults` keys — shared with the live library's IDs on a same-library backup), `AppSession`'s own wiring
    (`SampleLibrarySeeder` marks by variant, the status seam, `wing.attachMemory(.standard)`), the MCP door's `attach`
    (per session, the live store's path), the deleted-notes notification road (`.variorumNotesDeleted`) and the
    `WindowRegistry`. A second `AppSession` cannot exist without global state on this tree.
  - *Cost:* a new read-only session kind and a write fence across the read tier — a design unit of its own, far past
    "cheap and isolated"; and P3/P1 questions (a whole second library's surfaces live at once).
- **(b) A read-only SHEET of the copy's facts.** **RECOMMENDED — and on this tree the only tractable road.**
  - *What it shows:* §7c (10)'s frame line first (*This is a copy from <date>. Nothing you do here changes it or your
    library.*); the copy's kind and day; its books (name, and how many notes each holds); its notes, newest first, a page
    at a time (title and day — P1: bounded by the page, never the corpus); a note's text rendered read-only on selection
    (the blocks in order, each its chosen take — falling back to the block's default — exactly as the page reads);
    *Make this my library…* beside *Close* (the same copy, the same confirm); nothing editable anywhere.
  - *How it reads — writes nothing:* `lookInside` (the executor's READ — its own quiet road, or what she typed) → the key;
    the catalogued file and its non-empty `-wal` byte-copied into a PRIVATE folder (`ProtectionLibraryFiles.privateCopy`
    — the catalogued file is never opened in place, 13x's rule); ONE keyed read connection on the private copy with RAW
    SQL over the columns every schema since Phase 1 carries (`reading.name/kind/deleted_at`, `reading_post`, `container
    .title/kind/entry_date/updated_at/deleted_at`, `container_block.position/chosen_variant_id`, `block
    .default_variant_id`, `variant.working_text`) — never the migrator, never `Operations`, never the ambient database, so
    no write can reach the live library by construction; a page of 100 notes per read. No key file, no keychain item, no
    record, no memory item, no `UserDefaults` key is written. **Closing forgets:** the key dropped from the model, the
    connection closed, the private folder deleted (a crash mid-look leaves a private temp folder only — the 13x staged-read
    residue class).
  - *Where:* the reads in core beside the keying (`Protection/Files/ProtectionCopyPeek.swift` — headless-testable in both
    configurations, P1-bounded queries pinned); the brain `Shared/Protection/LookInsideModel.swift` (the key held only while
    the sheet stands; `close()` forgets); the Mac face `Features/Protection/LookInsideSheet.swift`; *Look inside…* on every
    Restore row and on a picked copy's doors. **The proof (the addendum's):** a test with the executor's write log EMPTY
    and every keychain item and container byte unchanged across look → read → close, the private folder gone after
    close; the frame line pinned byte-equal to §7c (10).
  - *Cost:* ~4 files (one core helper, one model, one face, one suite + the words pin already landed); no new global, no
    core protocol change; the executor untouched.
  - *Where Look inside can be offered:* at ready (the Restore rows; a picked copy's doors). At the MISSING FACE and rule
    27's lobby (no library open) Look inside needs no current pair — so if (b) is ruled, those faces' *Open Library…* can
    come back as "file, then Look inside" (the empty-slot landing, T-5, stays VX-309's); the filed copy then stays listed
    (rule 19) until VX-309's delete — a tension with "close it and the app forgets it" the orchestrator may want to rule
    (P-VX306-U3-0's filing writes a copy of the PICK; the look itself writes nothing).
  - *What it can't do:* show takes beyond the chosen one, comments, chapters or the book's own order (a later polish, if
    she wants them — still raw reads).
- Piece 5 — THE PHONE: the switch on in the phone's Debug build (P-VX306-U1b-1 superseded); `MobileStoreLockView` renders
  the lobby model, the creation card, the interlude and rule 27's face; the phone's pins; `build-for-testing`: DONE
  (this commit). **The switch** (`ProtectionRoad`): the rule reads `debug` alone (`live(debug:)`; `newRoadIsLive =
  live(debug: isDebugBuild)` — still compile-time, nothing at run time can flip it); `AppBootstrap`'s production init
  keeps P-VX306-U1b-5 (the dev store's variant only); `ProtectionRoadSwitchTests` follows (its four-cell rule now two
  cells, the source pin's line) — the ruled supersession, noted under QUESTIONS #233. The phone composes the leaves on
  the main actor already (`RoadInputs.compose()` is `@MainActor`, so `ProtectionSystem`'s `DeviceName.current` reads the
  device there). **The faces** (`VariorumMobile/Features/Protection/MobileRoadFaces.swift`, the phone's layout and DEVICE
  voice, the shared models and words): `MobileRoadLockView` (the typed field at once — the passphrase field with the words
  behind one quiet door, or the words directly; the biometry button and its one line; the refusal line; rule 27's sentence
  before unlock with the account sentence when named and *Start a New Library* with its sub-line — the phone keeps no
  backups and has no Open Library door; the roads re-read when the scene becomes active — VX-310's second bug's twin),
  `MobileLibraryWordsCard` (§7c (1): the words numbered in two columns, never selectable, privacy-sensitive, ONE button),
  `MobileRoadInterludeCard` (her notice once with *OK*, then the offer *Not now* · *Use it*), `MobileNoKeyFileSheet` (rule
  27 after a quiet open — §7c (3)'s sentence as a SHEET over the open library once per open, *OK*, no doors); the phone's
  root renders them in place of U1b's unreachable arm. The shared biometry lines now name the platform's biometry and
  device (`ProtectionCopy.biometryName` / `.deviceName` — the Mac's read "Touch ID" / "Mac" byte-for-byte as before, the
  phone's "Face ID" / "iPhone"; P-VX306-U3-8). The phone's missing face already runs the core's creation on the new road
  (the bootstrap's `LibraryMissingLobby.newRoadCreate`). **Not on the phone this unit** (the hand-forward): rule 3's
  reminder bar and the set-passphrase sheet, the receipts (rule 1's restore, the offer's *Use it*) — `RoadStandingModel` is
  made at the phone's ready too but has no face there. **Pins:** `MobileProtectionRoadTests` (6, the phone's test target —
  the switch ON in the phone's Debug build; the biometry words the phone's own; the words card's columns and one button;
  the lobby model with an unlistable keychain — both typed roads, the reason, no biometry claimed, a refusal said; the
  notice said once; rule 27's after-open condition read from the report). `xcodebuild -scheme VariorumMobile -destination
  'generic/platform=iOS Simulator' -configuration Debug -derivedDataPath DerivedData/vx306-u3 build-for-testing` → `** TEST
  BUILD SUCCEEDED **`, no warning in a touched file; the Mac `build-for-testing` (the same DerivedData) → `** TEST BUILD
  SUCCEEDED **`; the headless planted suites green again (57 in 8 — the Mac's lobby pins read "Touch ID isn't set up on
  this Mac." byte-for-byte). The phone suites' RUN and the simulator's open are the orchestrator's — PENDING.
- Piece 6 — the Mac `build-for-testing` + the record's close (the suites, the walk recipe, the PROVISIONALs): DONE (the
  close commit) — the protection surfaces' no-spinner rule applied to the doors' sheet (`758f151bc`, its grep pin gaining
  `CopyDoorsSheet` and the phone's `MobileRoadFaces`); the final tree's `build-for-testing` lines and the record below.

**THE ROAD AS BUILT (for the ladder):** the doors' brain is `Shared/Protection/CopyDoorsModel.swift` (pure; every act an
injected `CopyDoorsRoads`); their off-main roads are `ProtectionCopyDoors.swift` (listing · quiet probe · preflight · the act
· the pick) over `PickedCopy.swift` (classify · file); the bootstrap holds the swap's precondition (`AppBootstrap
.makeThisMyLibrary` — one act at a time, the preflight, `onWillLock`, `.opening`, `binding.lock()` (checkpoint-truncate then
close), the act detached, the reopen through the new road with the key that opens the slot) and owes §7c (9)'s receipt to the
reopened session (`receiptsForNextRoadOpen`, handed over in `finish(.ready)`). The executor does every write
(`makeThisMyLibrary` on its plan); the app writes only the restore-hold marker (the core writer, before the act; put back as
it stood when nothing swapped), today's store-id stub (the creation's mint, injected), and — for a pick — the filed copy (the
picked thing only read). Zero `Sources/`, `Sync/`, `Server/`, `StoreBackup.swift`, `BackupRetention.swift`,
`RestoreHoldModel.swift` lines; no new dependency.

**Counts (the final tree `758f151bc` + this record):**
- HEADLESS (the session's SwiftPM harness — not durable; the recipe: a package in the scratchpad, swift-tools 6.2, macOS 26,
  the app's concurrency settings — default `MainActor` isolation, `NonisolatedNonsendingByDefault`,
  `InferIsolatedConformances`, `MemberImportVisibility` — depending on the worktree's core by path; its `Variorum` target
  SYMLINKS every `App/Variorum/Shared/Protection/*.swift` but `ProtectionBackupHook.swift`, plus `Shared/LibraryOpenCopy.swift`,
  plus one stub file of one-line stand-ins (`DeviceName`, `KeychainTestTripwire`, `KeychainPartition`, `AppleKeyKeychain`,
  `AppleKey`, `BackupDestination`, `AuthTokens`/`KeychainAuthStorage`, `EncryptionSession.words`, `ProtectionCopy`'s three
  names); its test target symlinks `ProtectionTestSupport`, `ProtectionOpenRoadPlantedTests`, `CopyDoorsModelTests`,
  `MakeMineRoadTests`, `PickedCopyRoadTests`, `ProtectionWordsPlanTests`, `ProtectionLobbyModelTests`,
  `ProtectionWalkSwitchTests`, `ProtectionFileLeavesTests`, and a one-line `RoadWorld.RoadWorldError` stub): `✔ Test run with
  57 tests in 8 suites passed after 0.862 seconds.` (9 + 3 + 3 + 4 + 9 + 15 + 4 + 10).
- The MUTATION run (piece 2): `ProtectionCopyDoors.restoreHold` a no-op → `✘ Test run with 6 tests in 1 suite failed after
  0.580 seconds with 2 issues.` (both at `aRefusalInsideTheActPutsTheHoldBackAsItStood` — no hold must stand; the standing
  marker's bytes); restored from the pre-mutation copy and `cmp`-checked.
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx306-u3
  build-for-testing` → `** TEST BUILD SUCCEEDED **`; `xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS
  Simulator' -configuration Debug -derivedDataPath DerivedData/vx306-u3 build-for-testing` → `** TEST BUILD SUCCEEDED **`
  (both on the final tree); no new warning in a touched file (the build's three test-file warnings are pre-existing:
  `Phase13pProtectionBrainTests` 2, `ProtectionRoadRouteTests` 1).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx306-u3 test \
  -only-testing:VariorumTests/CopyDoorsModelTests \
  -only-testing:VariorumTests/MakeMineRoadTests \
  -only-testing:VariorumTests/PickedCopyRoadTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/ProtectionWordsPlanTests \
  -only-testing:VariorumTests/ProtectionRoadSwitchTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/ProtectionLobbyModelTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests \
  -only-testing:VariorumTests/LibraryWordsCardTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/ProtectionFacesRouteTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionNoticeFaceTests \
  -only-testing:VariorumTests/ProtectionOfferFaceTests \
  -only-testing:VariorumTests/ProtectionRule27FaceTests \
  -only-testing:VariorumTests/ProtectionRestoreReceiptTests \
  -only-testing:VariorumTests/ProtectionReminderRoadTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/ProtectionBackupHookTests \
  -only-testing:VariorumTests/ProtectionFileLeavesTests \
  -only-testing:VariorumTests/ProtectionWalkSwitchTests \
  -only-testing:VariorumTests/KeychainTripwireTests \
  -only-testing:VariorumTests/KeychainLeavesTests \
  -only-testing:VariorumTests/ProtectionFactsGathererTests \
  -only-testing:VariorumTests/ProtectionSystemCompositionTests \
  -only-testing:VariorumTests/LibraryPortabilityDoorTests \
  -only-testing:VariorumTests/VX209GuideWarningTests \
  -only-testing:VariorumTests/VX209LeavesCastleConfirmTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/StoreLaunchRouteTests \
  -only-testing:VariorumTests/Phase13pLobbyTests \
  -only-testing:VariorumTests/AppBootstrapOffMainTests \
  -only-testing:VariorumTests/VX202ReopenRaceTests \
  -only-testing:VariorumTests/VX206ProtectionLandingTests \
  -only-testing:VariorumTests/ProtectionSurfaceRenderTests \
  -only-testing:VariorumTests/BackupFutureStampTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/CapabilityRegistryTests \
  -only-testing:VariorumTests/MCPAsksWaitTests \
  -only-testing:VariorumTests/Phase9cAuthWiringTests \
  -only-testing:VariorumTests/DeadVocabularyTests
```
The first seven are U3's new or grown suites (9 + 3 + 3 + 2 + 4 + 4 + the dots pin's own; `MakeMineRouteTests` needs the
signed test host — the keychain); then U2's, U1b's and U1a's suites (the road changed under them — `finish(.ready)`'s receipt
handover, the words file, the switch; `VX310TodayLobbyWitnessTests` still reports its 2 tests with KNOWN ISSUES — expected, a
pass of either is a FAILURE; the tripwire's exact count must hold — `MakeMineRouteTests` writes only its throwaway scope);
then today's road and the surfaces whose files changed (`LibraryOpenPresenter`, Data Safety, Settings' composition, the
main window's sheets) and the source pins over the edited files. Read the `skipped:` lines.

**THE PHONE'S SUITES (the simulator — under the stage, CoreSimulator is shared state; PENDING):**
```
*[removed for publication]*
  -configuration Debug -derivedDataPath DerivedData/vx306-u3 test \
  -only-testing:VariorumMobileTests/MobileProtectionRoadTests \
  -only-testing:VariorumMobileTests/MobileProtectionTests \
  -only-testing:VariorumMobileTests/MobileProtectionSurfaceTests \
  -only-testing:VariorumMobileTests/MobileTravellingDotsTests \
  -only-testing:VariorumMobileTests/MobileLobbyVaultRoadTests \
  -only-testing:VariorumMobileTests/MobileEmptyStoreTests
```
*[removed for publication]*
`MobileProtectionRoadTests` (6) is new. NOTE for the run: the phone's TEST HOST now takes the new road in its Debug build
(read-only in a hosted run — the tripwire is armed — so over an empty simulator dev store it lands `.failed` with
*A test run never creates a library.*, exactly as the Mac's test host has since U1b); the suites above build their own
stores and do not read the host's state.

**THE WALK RECIPE (the orchestrator's, under a held stage claim `vx-306-u3-walk`; DEV STORE ONLY; both appearances where a
face changed — the sheets are system chrome on the Mac, so a light and a dark capture of the confirm and the Restore list):**
0. Zero Debug instances (`pgrep -fl 'Variorum.app/Contents/MacOS'` — a `/Applications` instance is NEVER touched). Build:
   `cd App/Variorum && xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath
   DerivedData/vx306-u3 build`. Launch every time as the BINARY with stderr captured (W-4): `OS_ACTIVITY_DT_MODE=YES
   App/Variorum/DerivedData/vx306-u3/Build/Products/Debug/Variorum.app/Contents/MacOS/Variorum 2> ~/vx306-walk/u3-run-N.log &`,
   quit with ⌘Q. `DC` = `~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev`. Expected
   start (U2's posture): library A (`818912e0`) in Standard with the dev passphrase, its pairs in `DC/Backups/818912e0/<mac8>/`;
   B's files in `~/vx306-walk/B`. `source ~/.variorum/dev-castle.env` (`VARIORUM_DEV_NEWROAD_WORDS` and the dev passphrase —
   never typed into a record).
1. **The Restore list.** Settings ▸ Data Safety → the *Restore from Backup* section under the new road: the lead
   (*Look inside a copy to read it without changing anything, or make it your library — your current one steps aside into
   Previous Libraries.* — P-VX306-U3-2; note it names Look inside, whose door the ruling brings), A's pairs newest first
   (each its date and time, *Backup*, *Make this my library…*), and *Other libraries on this Mac* if any other library's
   catalogued copy is here (B's backup pair if one ran while B was open; record what lists). Today's flat copies are NOT
   listed (rule 26). Capture (light, dark).
2. **Stage 9 — Make this my library on A's newest backup.** *Make this my library…* → the confirm: *Make this my library?*,
   the lead (§7c (8) as drafted — A has a passphrase), *Checking the copy…* then NO copy field (A's silent item opens its
   own backup), *Your twelve words*, *Your passphrase*, *Cancel* · *Make this my library* (off until both are typed).
   Capture. (a) A WRONG word first (eleven words) → *There are twelve words — you entered 11.*; a wrong-but-valid set →
   *Those twelve words don't open this library.* — the window NEVER goes to *Opening your library…* (the preflight). (b) The
   real words + the dev passphrase → *Making this copy your library…* → the windows show *Opening your library…* → the
   library reopens: the RESTORE HOLD banner (*This is your library as of <the backup's day>. Sync is waiting …* + *Resume
   Sync*) and the quiet receipt *This is your library now. The previous one is in Previous Libraries.* (6 s — capture at
   once; W-7: a long receipt may run into the bottom bar's hint). Log: `road: made a copy this Mac's library — library <new8>
   key <fp8>; …; held`, then `road: opened — library <new8> … repairs […]`. Files: `DC/Previous Libraries/<stamp>/` holds
   `variorum.sqlite` + `variorum-library-keys.json` (A's, its `"libraryID"` 818912e0…); `DC/variorum-library-keys.json`'s
   `"libraryID"` is NEW, `"history"` empty, locks `apple`/`passphrase`/`words`; `DC/variorum-restore-hold.json` present; a new
   `variorum-keys-<fp>.json` stub beside the slot and A's renamed `….stale-<ts>.json`. The Restore list now shows A under
   *Other libraries on this Mac* as *Previous library*. Press *Resume Sync* → the banner goes. **The dev library is now a NEW
   library (C)** — under the same words and passphrase (her current pair), so `dev-castle.env` still opens it; tell the
   coordinator the dev library's ID changed (the `818912e0` key file now lives in Previous Libraries).
3. **"Make it your library again"** (§7c (8)'s promise — optional, it mints another new library): *Make this my library…* on
   A's previous-library row → the same confirm (A's silent item still opens A's file quietly) → a library D with A's
   content; C steps aside into Previous Libraries. Record the IDs.
4. **Stage 10 — an AirDropped copy.** `mkdir -p ~/Downloads/vx306-airdrop && cp ~/vx306-walk/B/variorum.sqlite
   ~/vx306-walk/B/variorum-library-keys.json ~/Downloads/vx306-airdrop/` (and B's `-wal` if it is non-empty; never its
   `-shm`); `shasum ~/Downloads/vx306-airdrop/*`. File ▸ Open Library… → pick `~/Downloads/vx306-airdrop` → the sheet
   *Open a Library* · *Reading what you picked…* → *A copy from <B's day>.* · *Cancel* · *Make this my library…*. Capture.
   `ls "DC/Backups/safety-copies/"` → a `variorum-adopt-safety-<stamp>/` holding `variorum.sqlite` + `variorum-library-keys.json`
   (B's); `shasum` the picked folder again → identical (only read). *Cancel* (making B's throwaway library this Mac's is
   optional — it swaps the dev library's content to B's; Previous Libraries brings C/D back). The Restore list now lists B's
   filed copy under *Other libraries on this Mac* as *Opened copy*. Also: pick `DC/variorum.sqlite` itself → *That's the
   library you have open now.*; a plain-text export → *Opening a plain-text copy isn't ready in this build yet.* (optional —
   only with a plain-text `.sqlite` export already at hand; Data Safety's *Export an unencrypted copy…* is one of today's
   protection doors, which the walker does not press on the new road; `PickedCopyRoadTests.thePicksRefusalsAndTheChooser`
   carries the row).
5. **Look inside** — NOT walkable until the ruling's build (the recipe's rows: on the stage-3 pair → read-only, the live key
   file `cmp`-identical, no new keychain item (the open's Diagnostics line counts), the private copy gone at close; on B's
   filed copy).
6. **The missing face under the new road** (optional): with the slot moved aside (and its sidecars — W-9) the missing face
   shows *Start a New Library* and *Restore from Backup…* and NO *Open Library…* (P-VX306-U3-7). Put the slot back.
7. **The simulator's open (the phone):**
   ```
   *[removed for publication]*
   xcrun simctl boot $UDID 2>/dev/null; open -a Simulator
   xcrun simctl install $UDID App/Variorum/DerivedData/vx306-u3/Build/Products/Debug-iphonesimulator/VariorumMobile.app
   DATA=$(xcrun simctl get_app_container $UDID io.lduarte.VariorumMobile data)
   ls -la "$DATA/Library/Application Support/Variorum-dev/"      # THE SIMULATOR'S DEV STORE
   ```
   If a pre-design store sits there (an earlier phone build's — `variorum.sqlite` with a `variorum-keys-*.json` and no
   `variorum-library-keys.json`), set it aside first as K1 did (rule 26): `cd "$DATA/Library/Application Support/Variorum-dev"
   && mkdir -p Backups/safety-copies/variorum-vx306-predesign-$(date -u +%Y-%m-%d-%H%M%S) && mv variorum.sqlite*
   variorum-keys*.json Backups/safety-copies/variorum-vx306-predesign-*/` (or `xcrun simctl uninstall $UDID
   io.lduarte.VariorumMobile` for a fresh container — the simulator keychain keeps its items; the new road's names never
   collide with today's). Launch with the log on the console:
   `SIMCTL_CHILD_OS_ACTIVITY_DT_MODE=YES xcrun simctl launch --console-pty --terminate-running-process $UDID
   io.lduarte.VariorumMobile 2>&1 | tee ~/vx306-walk/sim-1.log` (Ctrl-C ends the console; `xcrun simctl terminate $UDID
   io.lduarte.VariorumMobile` quits the app). EXPECTED: the words card (*Your twelve words*, the lead, the twelve words in
   two numbered columns, the foot, *I've written them down*) → the shell opens; the log `road: created — library …`.
   Capture: `xcrun simctl io $UDID screenshot ~/vx306-walk/sim-card.png` (the words are throwaway — delete the capture after
   checking it, as at U1b). Relaunch → a silent open (`road: opened … repairs []`). Then
   `SIMCTL_CHILD_VARIORUM_WALK_FORGET=silent,apple xcrun simctl launch --console-pty --terminate-running-process $UDID
   io.lduarte.VariorumMobile …` → THE PHONE'S LOBBY: *Open your library*, *Enter your twelve words to open your library.*,
   the words field, the quiet line *Face ID isn't set up for this library.* (or *…on this iPhone.* — whatever the
   simulator's Features ▸ Face ID ▸ Enrolled says); a wrong count → *There are twelve words — you entered N.*; the words →
   opens (`repairs [remakeAppleRoad, remakeOnDeviceItem]`). Capture. KNOWN RISK (F-U3-5): the creation mints an Apple key
   into the SHARED access group (synchronizable); if the simulator build lacks that keychain group the creation fails with
   *Variorum couldn't create your library.* and the log names the keychain status — record it, the fix is the
   entitlement's, not the road's. A DEVICE install is HER hands (the handoff — optional).
8. **Posture after the window:** record the dev library's new ID (C or D), the Previous Libraries folders made, the filed
   B copy, the hold resumed; `dev-castle.env`'s values unchanged (the new libraries carry her current pair).

**PROVISIONALs (each built as its option (a); bundled under QUESTIONS #233 in plain words):**
- **P-VX306-U3-0** (the orchestrator's, built as ruled) — a picked pair or library folder is filed first into this Mac's
  `Backups/safety-copies/variorum-adopt-safety-<stamp>/` and the doors act on the catalogued copy. A note: the filed copy
  then stays listed (rule 19) until VX-309's delete — a tension with Look inside's "close it and the app forgets it" when a
  pick is only to be looked at (the look writes nothing; the filing does).
- **P-VX306-U3-1 — the Restore list holds this library's copies AND every other library's catalogued copy on this Mac**
  (*Other libraries on this Mac*), each with the doors. (a) BUILT — §7c (8)'s lead promises the library that stepped aside
  is "where you can look inside it or make it your library again", and after Make this my library it is ANOTHER library's
  copy (a fresh ID); rule 19 lists copies of other libraries; (b) this library's copies only (the promise false until
  VX-309's list); (c) other libraries' Previous Libraries only (their backups and opened copies hidden). No delete door
  (VX-309's).
- **P-VX306-U3-2 — U3's words §7c does not draft** (`ProtectionWords`): the list's lead *Look inside a copy to read it without
  changing anything, or make it your library — your current one steps aside into Previous Libraries.* · *Other libraries on
  this Mac* · the kinds *Backup* / *Previous library* / *Opened copy* · the copy field's note *Leave it empty if your own
  passphrase and words open it.* · *Cancel* · *Making this copy your library…* · *Checking the copy…* · *That doesn't open
  this copy. Enter the copy's own passphrase or twelve words.* · *That copy isn't there any more.* · *Another change to your
  library is still running. Try again in a moment.* · *Variorum couldn't make this copy your library just now. Nothing
  changed.* · *Opening a plain-text copy isn't ready in this build yet.* · *This file couldn't be read as a library.* (today's
  own, reused) · *That's the library you have open now.* · *Variorum couldn't keep a copy of what you picked. Nothing you
  picked was changed.* · *Reading what you picked…* · *A copy from <day>.* (b) blank until her sitting; (c) other words.
  Her taste call.
- **P-VX306-U3-3 — the confirm's lead without a passphrase.** (a) BUILT — §7c (8) exactly as drafted when the library has a
  passphrase; with none, the same sentence without "and passphrase" (*… under your current twelve words — with a fresh key
  of its own …*) — a library with no passphrase is not under one (§3: a sentence the build makes false is a regression);
  (b) the drafted sentence always; (c) a variant of hers.
- **P-VX306-U3-4 — the copy's own secret.** (a) BUILT — its field shows only when its quiet road doesn't open it (tried
  once, a READ, at the confirm's open); an EMPTY field tries her own pair (rule 4: her current secrets open older backups
  of the same library); twelve words that validate are the words, anything else a passphrase (untrimmed); (b) the field,
  when shown, required; (c) two fields (passphrase / words).
- **P-VX306-U3-5 — a picked plain-text export on the new road REFUSES** (*Opening a plain-text copy isn't ready in this build
  yet.*) — a deviation from the addendum's "keeps today's road", on a trace: today's adoption (`LibraryOpenModel` →
  `LibraryAdoption.execute`) sets the library aside with TODAY's key-file names only (`StoreKeyEnvelope.keyFileURLs` — the
  format-3 `variorum-library-keys.json` is left in the live place), lands a plaintext store the new road cannot open (no
  protection record → `recordMissing` → the missing face, K5), and mints today's silent custody (`saveAuto`). (a) BUILT;
  (b) today's road (the trace above); (c) build T-8 now (VX-309's).
- **P-VX306-U3-6 — a picked copy under TODAY's key-file format** (rule 26 — from before this design): today's own *This file
  couldn't be read as a library.* (a) BUILT — her "no refusal string either" read as no NEW sentence naming the old design,
  while a door that did nothing still speaks (§12); (b) a sentence naming the earlier design; (c) today's adoption (it
  would land a library the new road cannot open).
- **P-VX306-U3-7 — the missing face's and rule 27's *Open Library…* retire on the new road** until Look inside lands: no
  library is open whose current pair could make a copy its own (T-5 is VX-309's), and 13x's door there would run today's
  adoption on the new road. (a) BUILT (P-2); (b) keep 13x's door (the trace of U3-5 applies); (c) file-then-Look-inside
  once (b) of the proposal is ruled — the proposal says so.
- **P-VX306-U3-8 — the biometry lines name the platform's own** (`ProtectionCopy.biometryName` / `.deviceName`): the Mac's
  read "Touch ID" / "this Mac" byte-for-byte as before; the phone's *Unlock with Face ID*, *Face ID isn't set up on this
  iPhone.* / *…for this library.* (a) BUILT; (b) the Mac's words on the phone (false there); (c) separate phone constants.
- **P-VX306-U3-9 — today's store id is minted FRESH for the new library** at Make this my library (the creation's own mint —
  the outgoing stub set aside, `StoreIdentity.establish` under the new key, the new id's Auto dials), so the rest of the
  app — today's sync custody keyed by store id, the dials, the backup log — starts fresh with the new library (rule 17: a
  fresh identity; rule 18: a copy made one's own joins one's account as a copy). (a) BUILT; (b) keep the outgoing
  library's store id (the new library would inherit the old one's sync custody and dials); (c) leave it to the next open
  (the next open keeps an existing stub — the same as (b)).
- **P-VX306-U3-10 — the restore hold around the act.** (a) BUILT — written BEFORE the act by the core writer (13x's order:
  nothing lands un-held); when nothing swapped (a refusal, a rollback) it is put back exactly as it stood (none, or the
  standing marker's bytes); past the swap it stays and the door says made (the act's last steps finish at the next open);
  (b) a failure always leaves the hold (13x's conservative direction — a library never replaced would sit held until
  Resume); (c) the hold written after the act (a crash between the swap and the write would land un-held).
- **P-VX306-U3-11 — the preflight.** (a) BUILT — every check as READS before the window comes down: the copy catalogued, it
  opens with what she typed, its schema one this build opens (a newer Variorum's copy refused, never landed), her pair
  against the open library; (b) let the act refuse after the teardown (a typo reloads every window); (c) no schema check
  (a newer copy would land and fail to open after the swap).
- **P-VX306-U3-12 — the pick's edges.** (a) BUILT — a copy already in this Mac's catalogue, picked by hand, is used where it
  is (never filed twice); the open library itself (or its folder) refused; a folder of several pairs offered; (b) file
  every pick; (c) refuse picks inside the container.
- **P-VX306-U3-13 — rule 27 after a quiet open, on the phone,** is a sheet once per open (§7c (3)'s words, *OK*, no doors);
  the reminder and the receipts have no phone face this unit. (a) BUILT; (b) a standing banner in the phone's shell (a
  shell file of another surface); (c) nothing on the phone.
- **P-VX306-U3-14 — §7c (9)'s receipt is spoken on the MAIN window's status seam after the reopen** (owed to the reopened
  session), wherever the door was pressed (Settings included). (a) BUILT — the status seam is the main window's, and the
  reopen rebuilds it; (b) a line in the Settings sheet before it closes (the sheet closes on the reopen); (c) none.

**Findings (routed):**
- **F-U3-1 (words — VX-379's pass):** Settings ▸ Data Safety's *Restoring a copy* section (today's) still says *Restoring is
  a Finder operation, not a button …* on the new road, beside the Restore list's *Make this my library…* — false there;
  and the hand-off's (*Send Library to Another Mac…*) is today's road (VX-309's). VX-379's sentence pass, or hide the
  section on the new road.
- **F-U3-2 (cosmetic, W-7's class):** §7c (9)'s receipt is ~70 characters — it may run into the bottom bar's hint as rule 1's
  did (W-7).
- **F-U3-3 (minor):** a Make this my library pressed in Settings reopens the library and the Settings window rebuilds at its
  default pane (the re-key road asks for its pane back — `requestProtectionPaneForCeremony`; this door does not).
- **F-U3-4 (the TODAY'S-CLASSIFIER fact, for the ladder):** `LibraryClassifier` reads today's `StoreKeyEnvelope`, which a
  format-3 key file does not decode as (no `storeID`) — so today's classifier sees this design's pairs as bare stores; the
  new road classifies them first (`PickedCopy`). Traced, not pinned against today's classifier.
- **F-U3-5 (the walk's risk):** the creation mints an Apple key into the shared access group on the simulator too; if the
  simulator build lacks the group, the phone's creation fails in words (recipe row 7).
- **F-U3-6 (note):** each Make this my library mints a fresh library ID, device ID, key, Apple key (iCloud, dev-scope names)
  and silent item by design (rules 17, 23); the walk's rows 2–3 mint two — W-10's accumulation class.

**Hand-forwards:**
- **Look inside** — the ruling, then its build (the proposal's (b): `ProtectionCopyPeek` in core, `LookInsideModel`,
  `LookInsideSheet`, *Look inside…* on every Restore row and a picked copy's doors, the write-nothing proof; the missing face's
  and rule 27's *Open Library…* back as file-then-Look-inside if ruled).
- The phone's reminder bar, set-passphrase sheet and receipts (a later phone unit / the mobile catch-up).
- VX-379: every U3 string is in `ProtectionWords.swift` (§7c (8)–(10) pinned byte-equal; P-VX306-U3-2's undrafted).
- VX-309: T-5 (the empty-slot landing), T-8 (the plain-text export in), the copies list's delete door, Send Library on the
  new road.

**Notes:** no machinery deaths; no Sonnet lookup. The one MUTATION (piece 2) was applied to a file not yet committed, with
its pre-mutation copy in the session scratchpad — the protocol's rule is "commit before you revert" (a crash there would
have left a mutated, uncommitted file); restored at once and `cmp`-checked. `git worktree list` shows none of this session's
(no scratch worktree was used — the doors are new code, their pins red by construction on the pre-unit tree, which had none
of these types).

**ORCHESTRATOR RULING on the Look-inside fork (2026-10-18, at U3's proposal — P-VX306-U3-15, bundled under #233):** **(b), the
read-only facts sheet, as proposed** — rule 17's "opens read-only, writes nothing, closing forgets" at its honest minimum:
§7c (10)'s line first, the copy's kind and day, its books with note counts, its notes newest first a page at a time, a note's
text read-only on pick (blocks in order, the chosen take, the default as fallback), *Make this my library…* beside *Close*;
the key from `lookInside` (a read), a private byte copy (the catalogued file and its non-empty `-wal` copied; never the
catalogued file itself), ONE keyed read connection over raw SQL on columns every schema since Phase 1 carries — never the
migrator, never `Operations`, never the ambient database; nothing written (no key file, keychain item, record, memory item or
defaults key) — proven by a test with the executor's write log empty and every keychain item and container byte unchanged
across look → read → close; closing drops the key, closes the connection, deletes the private folder. (a) is refused for
this phase on the implementer's trace: a second `AppSession` cannot exist without global state on this tree, and the read
tier's doors write through the ambient `Operations` database — a "read-only" window built from the app's surfaces would
write to the LIVE library under the copy's row IDs; it is a design unit of its own, not a door. **With (b) ruled, the
missing face's and rule 27's *Open Library…* doors COME BACK as "file, then the two doors"** (P-VX306-U3-7 narrowed: the
door renders again on the new road and leads to the picked flow). **The filing tension:** the filed copy stays listed (rule
19: copies of other libraries are listed and can be deleted — VX-309's delete) while the LOOK itself forgets; the filing
writes a copy of the pick, never anything of hers — accepted, said in the bundle. **Also ruled at this seam:** P-VX306-U3-5
(the plain-text export REFUSES on the new road with its sentence; T-8 stays VX-309's) — accepted, the implementer's trace
shows today's road unsafe there; P-VX306-U3-3 (the confirm's lead drops "and passphrase" over a library with none) —
accepted, truth over verbatim. The fold of main at this seam renumbered U1a's migration to `v1_31_protection_record` (VX-348's
`v1_30` registers first); the dev store, which applied the old name, re-applies the idempotent DDL at its next open.
