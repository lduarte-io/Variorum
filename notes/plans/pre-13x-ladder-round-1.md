# pre-13x — THE COLD-REVIEW LADDER, ROUND 1 (Fable reviewer; 2026-09-06)

**Scope:** `git diff 39c5b395..HEAD` (HEAD `66430082`, 174 commits, batches 1a → 5b). Read cold — no batch record was used as evidence; every load-bearing claim below is traced to code, DDL or a named pin. **Foci:** §18's sign-off conditions (i)–(vii) and §12's pin list, each addressed by name; **condition (vii)** — *Encryption Explained* and the tutorial chapter walked sentence by sentence (the table at the end); **§3.4** walked cell by cell. Read-only throughout; nothing was run against the mirror, no drill suite was invoked, the running `/Applications` instance was not touched.

**One-line verdict:** the design shipped as designed — the credential audit holds cell by cell, the book is true sentence by sentence, the proof is the authorization on every mirror door, and the postures rotate exactly what §3.4 says they rotate. Four defects worth fixing before the next round: one BLOCKER in the rotation's completion (the A5 window can orphan a row under a key that no longer exists anywhere — a permanently wedged pull for every device), and three MAJORs (a refused ceremony leaves sync stopped for the session; the delete-old-backups offer is made even when the fresh snapshot failed; the iCloud key's mint-on-unreadable rule can duplicate A and strand the vault's Apple-held copy).

---

## FINDINGS (severity-ranked)

### BLOCKER-1 · `Sources/VariorumCore/Sync/CorpusRotation.swift:365–444` (with `Server/supabase/11_pre13x_postures.sql:587,599,916–918`) — a row committed inside the A5 visibility window is left under the PREVIOUS corpus key, then COMPLETION deletes that key from the vault and from custody; every later pull of the account fails to decrypt it — a permanently wedged changefeed

**Mechanism (traced).** `sync_pull` never serves a row whose `server_written_at` is within the last 2 s (the A5 horizon, `11_pre13x_postures.sql:587/599`). A push that passed the OLD gate holds the vault row `FOR SHARE`, so `key_vault_update`'s `FOR UPDATE` waits for it to commit — that push's row therefore lands BELOW the rotation seq (decision 31, pinned by `KeyProofGateTests.aPushThatPassedTheOldCheckLandsBelowTheRotationSeqAndNewWritesAbove`) but stays INVISIBLE to pulls for up to 2 s after its write. `CorpusRotation.reencryptRemainder` (line 365) pulls the remainder with `pullBelow` (419), re-encrypts what it sees, and returns the moment a pass finds an EMPTY window (381). Nothing in the walk waits out the horizon: on a small corpus (a new user; a few hundred rows) the first pass and the second pass both complete well inside 2 s of the vault write. `PostureSwitchRunner.reencryptAndComplete` then calls `CorpusRotation.complete` (444), whose `key_vault_update` clears `corpus_previous_key_id` / `…wrapped_by_master` / `rotation_started_seq` together (SQL 916–918), and the runner saves `material.clearingPreviousCorpusKey()` into custody. The straggler now sits on the mirror below a seq nobody records, sealed under a key that exists in NO vault column and NO custody item. Every subsequent `SyncEngine.pull` on any device opens it by the seq rule — `keyMaterial(forServerSeq:)` finds no rotation and hands the CURRENT key, whose AAD names the current key id — `PayloadCipher.open` fails, and `pulled.append(contentsOf: try window.map(crypto.decryptFromWire))` (`SyncEngine.swift:374`) throws: the WHOLE pull refuses, cursor unmoved, forever. Only an edit of that exact row by a device still holding its plaintext heals it (a push CAS-accepts at the unbumped version and re-seals under C′); nothing else can.

**Why the existing pin does not cover it.** `CorpusRotationTests.theWalkReencryptsEveryRowBelowTheSeqAndCompletionClearsTheKeyAndTheSeqTogether` models the window with `visibilityHorizon: 2` and then ADVANCES THE FAKE CLOCK after the first re-encrypt (`SeamTransport(afterFirstReencrypt: .advanceClock(2))`), i.e. it assumes time passes between the passes. Production has no such clock advance; the walk's own duration is the only thing that makes the straggler visible, and on a small corpus it is shorter than the window. The design's own words ("the second pass catches the A5 visibility window's stragglers") hold only when the second pass happens ≥ 2 s after the straggler's write.

**Consequence class.** Availability, not confidentiality (the row is PRE-switch writing, so Chapter 4's "nothing written after today is ever under a key an old copy holds" stays true) — but a poison row that wedges every device's pull is a data-loss-adjacent defect in the design's own §12 grammar ("nothing is lost, the resume retries" — here nothing retries).

**Proposed fix (two halves; the first is the structural one).** (a) SERVER: in `key_vault_update`'s clearing arm (the `incoming_previous is null` branch while `vault_previous is not null`), refuse with a typed marker (`VARIORUM_ROTATION_ROWS_REMAIN`) while any row of the caller's partition has `server_seq < rotation_started_seq` — the server sees every COMMITTED row regardless of the horizon, and every push still in flight holds `FOR SHARE` on the vault row, so after the `FOR UPDATE` is acquired the check is exact. A body change only (no signature change; a stricter refusal — additive under SyncSpec §12's letter; the DDL pin `theVaultUpdateDoorLocksForUpdateCASesAndRecordsTheRotationSeq` gains the clause). (b) CLIENT: after the walk's first empty window, wait past the horizon (a `Task.sleep` ≥ 2.5 s, injectable) and pull once more before returning — cheap insurance that also keeps the fake server honest; on a refused completion the runner keeps the marker at `.reencrypt` and re-walks. **Red-on-old pin:** the same world as the existing walk pin but WITHOUT the clock advance between passes; then `complete`; then advance the clock and pull as a sibling — red on today's tree: the pull throws on the straggler. The `Sync/` rider binds (Fable).

### MAJOR-1 · `App/Variorum/Shared/PostureSwitch.swift:336, 496, 539, 809` with `App/Variorum/Shared/SyncSession.swift:148–171` — a REFUSED or FAILED switch/follow leaves sync STOPPED for the rest of the session; the refusal sentence then tells the user to "wait for sync to finish"

**Mechanism (traced).** `PostureSwitchRunner.run()` calls `leaves.pauseSync()` before its drain (336); `follow(passphrase:)` (496) and `follow(derivedPassphraseKey:)` (539) call it before the vault unwrap. The production leaf is `services()?.sync.stop()`, and `SyncSession.stop()` sets `scheduler = nil` and retires the old chain (164–171). `leaves.resumeSync()` is called ONLY on the success roads (809, 1138, and `pickUpKeys` 683), and the production leaf is `services()?.sync.triggerSync()`, which is `guard let scheduler else { return }` (148) — a NO-OP on a stopped session. On the SUCCESS road this is masked: the re-key's reopen rebuilds `AppServices` (`VariorumApp.swift:57`) and its `start()` reconnects the chain. On EVERY failure road before the reopen — `SyncError.outboxNotEmpty` (351), `pullStalled`, `CorpusRotationError.rotationInProgress` (354), `wordsRequired` (361), `syncKeysUnavailable` (364), a vault refusal in `begin`, a wrong passphrase at the follow's `enroll` — the runner throws with the chain retired and no reopen, and nothing restarts it: sync is dead until relaunch, relock, or sign-out/in. The `.outboxNotEmpty` sentence ("wait for sync to finish, then try again") is self-defeating — sync cannot finish because the ceremony just stopped it. `deleteAccount` (`AppServices.swift:515–545`) shows the correct shape: `sync.stop()` … on refusal `await connectSyncIfAllowed()`.

**Proposed fix.** Make the production `resumeSync` leaf `await connectSyncIfAllowed()` (or a `SyncSession.resume()` that re-configures when `scheduler == nil`), and call it on every exit of `run()` / `follow` / `follow(derived…)` (a `defer`-shaped guard that fires unless the re-key's reopen already rebuilt services). **Red-on-old pin:** `PostureSwitchTests` already records `calls.pauses` / `calls.resumes` (line 549–550); a step-1 refusal (`outboxNotEmpty`, or `rotationInProgress` — `aRotationStillFinishingOnAnotherDeviceRefusesAtTheDoorAndChangesNothing`'s world) must end with `resumes == pauses`; red today (1 / 0). Plus one pin at the `SyncSession` level: `stop()` then `triggerSync()` runs no round; the resume road does.

### MAJOR-2 · `App/Variorum/Shared/PostureSwitch.swift:900–918` (`snapshotAndInsurance`) — the offer to delete every pre-switch backup is made even when the FRESH snapshot did not land, and the Done then says "A fresh backup was made under it"

**Mechanism (traced).** Step 6 is `_ = await leaves.takeSnapshot()` (904) — the result (nil = the backup was NOT written; the production leaf returns nil unless `record.primary.outcome == .written`) is discarded — and the pre-switch pairs are listed regardless (`preSwitch = listPreSwitchPairs ? leaves.preSwitchSnapshots(…) : []`). The ceremony then renders `enteredCastleDone` ("A fresh backup was made under it") and, when pairs exist, the offer; *Delete Them* removes every app-made pair. Design §4 step 6 / §12's pin ("a snapshot under the new key exists before the delete offer") and decision 6 ("Entering Castle leaves nothing behind") are the exact promise this path can break: an unwritable Backups folder, a WAL that will not drain, or any `performRun` failure ⇒ the user is offered — with the sentence's assurance — the deletion of the only snapshots that exist. The same arm rides the follow (`rekeyCustodyAndSnapshot` is shared) and the resume's `.snapshot` step (1128).

**Proposed fix.** Gate the offer on the snapshot: nil ⇒ `preSwitchSnapshots = []` (no offer), and the Done renders a sentence that does not claim a backup (a one-line addition to the copy — hers / 13s's; the fact is the design's). **Red-on-old pin:** the existing scripted `takeSnapshot` leaf returns a URL; a variant returning nil must yield an empty `preSwitchSnapshots` (red today: the old pair is listed — cf. line 714's `#expect(outcome.preSwitchSnapshots == [oldPair])` world).

### MAJOR-3 · `App/Variorum/Shared/ProtectionController.swift:1382` (`reconcileAppleKeyOffMain` → `appleKeys.readOrMint()`) and `App/Variorum/Shared/PostureSwitch.swift:923` (`appleHeldCopyForStandard` → `readOrMint()`) — the iCloud key is MINTED whenever it is UNREADABLE here, which under iCloud Keychain propagation lag duplicates A; the vault's Apple-held copy is never re-landed after iCloud resolves the duplicate, and the waiting state then misnames the cause · **decision 30's letter is violated on the Replace All Keys road** · partly SPECULATIVE on the platform's exact conflict resolution

**Mechanism (traced to the client; the iCloud half is the batch-0 lookup's recorded fact).** The reconcile's Apple arm runs at every ready under a DETERMINED Standard reading (`reconcileAppleKey` → `postureReading.determined == .standard`) and mints A when `read()` is nil. A signed-in library on a NEW device of the SAME Apple ID whose A has not yet propagated (§3.8: "propagation latency is unbounded in practice") reaches ready — the route's waiting state is for the ABSENT-bound-item case; a FRESH library routes `.open` and mints its own L — and the arm mints A₂ and writes it synchronizable. Two items now exist under one (service, account, synchronizable, group) identity; batch 0's lookup recorded "most-recent-version-wins". If A₂ wins, every device's key file re-lands under A₂ at its next reconcile (`anAppleCopyUnderAnotherIDIsReLandedUnderThisDevicesA`) — fine — but the VAULT's `master_wrapped_by_apple_held` stays under A₁: no code path re-wraps it except sync setup, `leaveCastle`, and a Standard Replace All Keys. From then on every new Apple device reads `apple.id != vault.appleKeyID` ⇒ `EnrollFacts.AppleState.differentAppleID` ⇒ the tab says *"This Mac's Apple account isn't the one that set up sync"* (`waitingDifferentAppleID`) — false: it IS the same Apple account — and Standard's headline promise ("a new device: nothing typed") is dead for the account until a vault write happens to re-land the copy. Separately and without any platform speculation: `appleHeldCopyForStandard()` uses `readOrMint()`, so a Standard Replace All Keys on a device whose A is momentarily unreadable MINTS a new A and wraps M′ under it — decision 30 says in so many words "Replace All Keys never re-mints the iCloud key"; the design's own reason (someone inside the Apple account keeps their road) is unaffected, but the other devices' key files and the previous vault copy now name an id iCloud may retire.

**Proposed fix.** (a) Never mint A from a road that knows the vault names an `apple_key_id` this device cannot read: the reconcile's Apple arm mints ONLY when the account has no vault, or the vault carries no Apple-held copy (a Castle account), or the vault's `apple_key_id` IS readable; otherwise it waits (the honest "not landed" outcome — `appleKeyVerified = false`, the nudge's exposed tier, the waiting face). (b) `appleHeldCopyForStandard` uses `read()` and refuses (a worded sentence) when A is unreadable — decision 30's letter. (c) The healing half: when an enrolled device holds M, reads A, and finds `vault.appleKeyID != A.id` under a Standard vault, re-land the vault's copy under A in one proof-authorized write (the `leaveCastle` shape) — closes the orphaned-vault-copy case whatever iCloud decides. **Red-on-old pin (client half, exact):** a scripted world — the vault's reading says Standard with `appleKeyID = A₁`, `appleKeys.read()` nil — the reconcile must NOT mint (the backing's key stays nil; today it mints). A second pin for (b): Replace All Keys under Standard with A unreadable refuses rather than minting. The iCloud conflict itself is a Q3-class live fact for the acceptance walk, not a test.

### MINOR-1 · `notes/plans/pre-13x-postures-design.md` §18 THE LEDGER — eighteen rows still read **open** although their owning batches are recorded DONE (6 · 8 · 9 · 12 · 13 · 14 · 16 · 18 · 24 · 25 · 26 · 29 · 30 · 34 · 38 · 39 · 41 · 42)

The ladder's anchor is "every row owned"; a reviewer reading the ledger cold cannot tell a lagging status from an undone item (row 42's snapshot pairs are built — `SnapshotPairTests`; row 41's write-road closure is built and pinned — `theVaultsTableLevelWriteRoadIsClosed`; row 39's one-gated-read is built — `StoreKeyGuardKeychain.unlockGated` reads the sync record under the same `LAContext`). Each was verified here from code; the statuses should be flipped at the closeout with the pin named.

### MINOR-2 · corner 48 (§14) — the pin that the BUILT iOS Info.plist carries `NSFaceIDUsageDescription` does not exist (§16 says "still for the ladder")

`project.pbxproj:765,800` carry `INFOPLIST_KEY_NSFaceIDUsageDescription = "Unlock your Variorum library"` on two configurations; no test in `VariorumMobileTests` reads the built `Info.plist`. The fact was found by the app dying at the first Face ID gate on her phone; a regression would recur the same way. Pin: `Bundle.main.object(forInfoDictionaryKey: "NSFaceIDUsageDescription")` non-empty in the mobile test host (both configurations build the same key).

### MINOR-3 · design §3.5 / §4 step 4 vs `PostureSwitch.swift:624–650` (`retireOldKeyFiles`) — the design text says the old key file is never deleted ("nothing is set aside or deleted"; "the old key file stays beside old snapshots"); the follow REMOVES it (the 2d.4 adjudication's ruling 3, pinned by `theMismatchFollowReKeysTheLibraryMovesCustodyBehindTheGateAndRemovesTheOldKeyFile`)

The ruling is recorded in the 2d record and the code comment, but §3.5 and §4 step 4 were not re-based; a future reader of the settled design file reads a rule the build contradicts. Not a code defect (the ceremony's own road keeps the file; lock-time copies and snapshots are paired, so nothing that needs the old file loses it — checked: `performLockTimeCopyIfDue` writes its pair). The closeout should re-base the two sentences to "the ceremony's road keeps it; a follow under Castle retires it from the live folder (2d.4)".

### MINOR-4 · `App/Variorum/Shared/PostureSwitchModel.swift:159, 551` — the still-finishing sentence renders `device: "another device"` although decision 34 exists so the notice can name the device

`PostureSwitchRunner.DoorFacts` carries `vaultUpdatedAt` but not `updatedByDevice`, so copy §4's *"A key replacement started on [device] on [day]…"* always says "another device" — the one sentence decision 34 was made for ("the real name is what lets a user spot an act they did not do"). Add `updatedByDevice` to `DoorFacts` (the fetched format has it) and render it; the mid-run arm (551) can carry the fetched name the same way.

### MINOR-5 · `App/Variorum/Shared/PostureSwitch.swift:337` — the ceremony's drain constructs `SyncEngine(transport:keyProvider:)` WITHOUT `sampleLibraryFacts`, so a seeded-book copy whose `reading` row lands during the switch's pull-to-head never arms the dedupe's one-shot marker

`sampleDedupeOccasion` guards on `!sampleLibraryFacts.isEmpty` (`SampleLibraryDedupe.swift`), so this engine records no occasion and the regular engine never sees the arrival again (the pull cursor moved). Narrow (the other device's seed must land during the seconds of the drain) and self-healing at the next `reading`/reserved-tag arrival, but it is a second engine composition that silently drops a repair the design says every pull carries. Pass `SyncSession`'s facts through the leaves (they are `[SampleLibraryDedupeFacts]` on the configured engine).

### MINOR-6 · copy §7b Chapter 7 / copy §8 — "If your account password leaked, sign out everywhere and change it" names an act the app has no door for

No in-app account-password change or reset road exists in `AuthViews` / `AuthSession` / `AppServices` (grep: no `updateUser`, no recover/forgot road). The sentence is true only if "change it" means the stargazing.tech web flow — which neither the book nor the FAQ names. For the author / 13s: name the road, or 14-era's reset-by-email door is owed a mention.

### MINOR-7 · decision 22 — "The compromise rule (four lines) appears in both postures" — the rule is assembled whole ONLY in the book's Chapter 7; on the Protection pane its pieces are scattered (§2b's third bullet, the Replace All Keys body + Standard addendum)

The 5a record reads decision 22 as "present where the copy places it". A reading, not a defect: whether a user standing on the Protection pane in EITHER posture should see the four-line rule without opening the book is the author's call (the design §8's pane bullet lists "the compromise rule (four lines), both postures" under `ProtectionShapes` → the pane). Flagged for her.

### MINOR-8 · tutorial Lesson 2's last paragraph ("…is in the book "Encryption Explained" on this shelf") can point at a book that is not on the shelf

Ledger 70 records that a store that belongs to an account but has never synced cleanly seeds NEITHER seeded book (the arrive-by-sync gate), while `TutorialSeeder` seeds the tutorial by its own rule — so on exactly that store the sentence names an absent book until the first clean round; on the phone there is no Help ▸ Restore for it at all. Recorded at ledger 70 as "not a defect of this phase"; listed here because condition (vii) says a sentence the build does not agree with is a defect until she says otherwise. Her call (a door on the phone; or the seeder's gate loosened for the encryption book alone).

### NIT-1 · `Sources/VariorumCore/Persistence/StoreKeyEnvelope.swift:252–322` — the code's names still say `masterBox` / `noMasterBox` / `appleBox` / `noAppleBox` / `removeAppleBox` after her vocabulary ruling ("the master-wrapped copy of the library key"; "box" appears in no user text — it does not, the register pin proves it). Identifiers only; rename at the next touch so the code reads the ruling.

### NIT-2 · `App/Variorum/Shared/PostureSwitch.swift:568, 605` — `oldFingerprint` computed in `runFollow` and then `_ = oldFingerprint`: dead.

### NIT-3 · `App/Variorum/Shared/PostureSwitch.swift:1122` — the resume's `.snapshot/.offer` arm mints a throwaway `StoreKey.mint()` to compute a fallback fingerprint when the marker lacks one and no key is in hand; it should throw `libraryKeyUnavailable` (a marker at `.snapshot` always carries `newKeyFingerprint`, so the arm is unreachable — say so or remove it).

### NIT-4 · `Server/supabase/11_pre13x_postures.sql:515` — `sync_pull`'s `key_proof text default null` is the one defaulted proof parameter (Postgres forbids a defaultless parameter after defaulted ones; the gate refuses NULL, so nothing is open). Reorder the parameters at the next lockstep event (13y's) so the proof is defaultless everywhere, as the design's "REQUIRED, no default" doctrine says.

### NIT-5 · book Chapter 5 sentence 3 — "Variorum never changes a backup after it makes it" — retention PRUNES backups (14 dailies + 4 weeklies; `prune(directory:keep:)`). A deletion is arguably not a "change", and the runbook says so, but a reader who finds an old backup gone may read the sentence as broken. For 13s: "never rewrites".

---

## THE SIGN-OFF CONDITIONS (§18) — each addressed

- **(i) the key proof ships in this phase's lockstep event** — HOLDS. `11_pre13x_postures.sql` drops all six old signatures first (section 0), gates every data RPC and both read RPCs through `sync_key_gate` → `sync_key_proof_check` (constant-time, the NULL-hash arm under `FOR UPDATE` from the peek), closes the vault's table-level UPDATE road (policy dropped, grant revoked, the definer's own policy), refuses a NULL hash at INSERT by trigger, and moves the marker LAST. Pinned: `AuthRLSDDLTests.thePosturesEvent*` (12 pins), `KeyProofGateTests` (11), `KeyProofTests` (6); the live mirror read at marker 8 with the hash landed (§18's mirror acts). The fake server enforces the same order (`FakeSyncServer.gatedAccount` / `checkProof` / `keyVaultUpdate`).
- **(ii) the descriptor-floor and never-wrap-under-a-network-key pins land in batch 1** — HOLDS, one batch late by the record's own admission (3b). The floor: `PassphraseKDF.Floor` (19 MiB · 2 passes · 16-byte salt; test host relaxed under `#if DEBUG` + a test-host probe), consulted at `KeyVaultWireRow.format()` and both key-file passphrase roads before any derivation (`KeyProofTests.aVaultRowBelowTheFloorRefusesAtDecodeBeforeAnyDerivation`, `StoreKeyEnvelopeTests.aWrapBelowTheFloorRefusesBeforeDerivingAtBothPassphraseRoads`, `PassphraseKDFTests.theProductionFloorIs…`). Never-wrap-under-a-network-key: A is read from iCloud Keychain or minted locally (`AppleKeyKeychain`); the vault's `apple_key_id` is VERIFIED (`openWithAppleKey` refuses a mismatch; `EnrollFacts.AppleState.differentAppleID`); no code path wraps under a key parsed off the wire (checked: `settingAppleHeldCopy` takes `appleKey` from the leaves only). MAJOR-3 is the one hole in the letter of this condition (a MINT, not an adoption).
- **(iii) A observed crossing her two real devices before any Standard copy is written (Q3)** — HOLDS per §18 (ledger 2, the same `appleKeyID` on both devices). Not re-run here (a live act).
- **(iv) Fable reviewers on every ladder round, each walking §3.4; the two drills on both devices** — this round: Fable; §3.4 walked below. The drills: the 13p migration on a byte-copy of her store (`PostureSwitchDrillTests.standardToCastleWithASiblingThenBackToStandard` runs the switch over the sample library; the byte-copy leg is the opt-in drill class — recorded, not re-run here) and the 13l restore per posture (the runbook rewritten — `notes/DataSafetyRunbook.md` +229/−70; `DataSafetyRunbookTests` green per the records). The device legs are HER acceptance walk's.
- **(v) the honest boundaries in §2 and §14 survive 13s's re-voicing in substance** — HOLDS today: every §2 keystone renders verbatim (`ProtectionCopy.keystone*`, pinned by `ProtectionCopyTests`), the floors render on both cards and in the chapter, corner 19 (the open-app attacker) is keystone 4 at the pane's bottom on both platforms, corner 22 (any finger passes) is `enrolledFingerLine` on both. The §11 re-voices table is the 13s handoff; MINOR-6/-7 are the two places where the substance needs a word from her.
- **(vi) §3.4 holds at closeout with every "at the switch" cell pinned** — HOLDS cell by cell (the walk below names the pin per cell); the two caveats are BLOCKER-1 (the corpus-key row's "every row re-encrypted" can leave one straggler) and MAJOR-2 (the backup row's "the ceremony offers to delete the app's own" can offer before the fresh snapshot exists).
- **(vii) the book is the acceptance checklist** — WALKED. The seeded text (`EncryptionExplained.txt`) equals copy §7b sentence for sentence (a normalized diff shows only the two copy-file annotations, which are not reader text); the tutorial chapter's paragraphs equal copy §7 (the device nouns interpolated). The table at the end gives every sentence a verdict; three sentences carry observations (Ch.1 s12 offline; Ch.2 s21 — MAJOR-3; Ch.6 s66 the manual road) and none is a defect of the build's fact.

---

## §3.4 — THE CREDENTIAL AUDIT, walked cell by cell (the "at the switch" columns; the pin or code that makes each true)

**Standard → Castle**

| credential | cell | verdict · what makes it true |
|---|---|---|
| Mac login password | stops opening Variorum | ✓ `moveCustodyForSwitch` → `.biometric` / `.passphrase`; the silent bound item deleted through `CustodyHandover` (`Phase13pControllerTests.aMoveIntoTheGateMovesTheLibraryKeyAndTheSyncRecordTogether`, `passphraseGateLeavesNoSilentCustodyAtAll`) |
| library key, RAW | REPLACED (export-and-swap); re-saved behind Touch ID or dropped | ✓ `StoreEncryptionMigration.rekey` (verified swap, the old key opens nothing — `rekeyMovesTheStoreToTheNewKeyAndTheOldKeyOpensNothing`); `PostureSwitchTests.enteringCastleRotatesEverythingAndTheStandardEraKeysOpenNothing` |
| library key, WRAPPED | the new key's file has NO A copy; old key files untouched | ✓ `writeNewKeyFile` (`apple` nil when `entersCastle`; `newFile.apple == nil` pinned); the ceremony's road keeps the old file (the FOLLOW removes it — MINOR-3, ruled at 2d.4, pinned) |
| passphrase P | unchanged; verified against the vault | ✓ `PostureSwitchModel.verifyPassphrase` → `vaultTie.verifyPassphrase` (`theCeremonyWalksTheCopysOrderRefusingAWrongPassphraseAgainstTheVault…`); Change Passphrase re-wraps vault + THIS key file only (`changePassphrase` → `onVaultMaterialLanded` → `reconcilePassphraseWrap`; `rewrapMovesThePassphraseAndNothingElse`) |
| twelve words W | unchanged; generated if none; typed or regenerated | ✓ `WordsCeremony`; the runner refuses a wrap-less rotation over a vault that carries a wrap (`replaceAllKeysRefusesWithoutTheWordsWhenTheVaultCarriesAWrap`, ledger 44) |
| iCloud key A | STAYS; every current copy under it removed/replaced; still opens old files | ✓ `CorpusRotation.begin(appleHeldCopy: nil)` (the vault's absence pinned — attacker ARM 2); the new key file carries none; A never deleted in production (`AppleKeyKeychain.delete` is the migration's/pins' door only); `MultiTenantSyncAttackerTests` ARM 1 (the pair opens through A; L′ does not) |
| master M | REPLACED, M′ under P and W only; the old master refused everywhere | ✓ `KeyVaultFormat.create` + no Apple copy; `KeyProofGateTests.theOldProofIsRefusedAfterARotationAndTheNewOneAccepted`; attacker ARMs 3–6 (push · pull · vault write · purge · truncate · horizon · ledger all refused under the old proof) |
| corpus key C | REPLACED; every row re-encrypted; the old C opens pre-switch ciphertext only | ✓ (with **BLOCKER-1**) `CorpusRotation.reencryptRemainder` + `sync_reencrypt` (version-neutral, `reencryptionIsVersionNeutralAndADeviceWithOfflineEditsConvergesWithZeroConflicts`); "the OLD key opens nothing after the walk" pinned — for the rows the walk SAW |
| key proof | replaced under the old proof | ✓ `key_vault_update` `coalesce(payload->>'key_proof_hash', …)` under `sync_key_proof_check` of the OLD proof; `begin` presents the old master's token |
| account password | unchanged | ✓ no key act takes it; `AccountDeletion` alone (decision 16) |
| session | unchanged, inert without the new proof; device-bound | ✓ `KeychainAuthStorage` DP + `WhenUnlockedThisDeviceOnly`, per scope (`SessionTokenBindingTests`, 4 pins); attacker ARMs 3–6 |
| a backup | UNTOUCHED; the app's own offered for deletion; never rewritten | ✓ (with **MAJOR-2**) `copyKeyEnvelope` / `writeSnapshotKeyFile` only-when-absent; `SnapshotPairTests.eachSnapshotsKeyFileIsWrittenWithItAndNeverRewritten`; `LobbyVaultRoadTests…TheBackupFolderIsNeverRewritten`; `deleteSnapshotPairs` removes pairs listed by fingerprint ≠ new |

**Castle → Standard**

| credential | cell | verdict · what makes it true |
|---|---|---|
| Mac login password | starts opening Variorum again | ✓ `leaveCastle` → `moveCustody(.auto)` (`leavingCastleAddsTheAppleHeldCopiesAndMovesCustodySilentRotatingNothing`) |
| library key RAW / WRAPPED | re-saved silent, no re-key; an A copy ADDED to the same key file | ✓ same pin: the store still opens under the old key; `envelope.appleBox` under THIS device's A |
| P / W | unchanged | ✓ no wrap touched on this road |
| iCloud key A | minted if absent (decision 7 permits it); M and L get copies | ✓ `readOrMint` at 704/952; `settingAppleHeldCopy` under the current proof |
| master M | an A copy added; NO rotation | ✓ `updateVault(fetched.format.settingAppleHeldCopy…)` — one CAS write; the corpus key id unchanged (pinned) |
| corpus key · key proof · account password · session | unchanged | ✓ no write touches them |
| Touch ID | the gate removed | ✓ `moveCustody(.auto)` deletes the gated items (both families — `SyncCustodyTransition.move(.silent)`) |
| a backup | untouched; the next snapshot's key file carries the iCloud copy | ✓ the live key file gained `apple`; `writeSnapshotKeyFile` copies the live file at the next run |

**Other devices** — into Castle: the notice → P or W once → M′/C′ → re-key own library → pull (✓ `aStandardSiblingFollowsByThePassphraseFinishesTheRotationAndPullsToAnIdenticalStore`; `aCastleFollowerOfReplaceAllKeysFinishesTheWalkAndListsNoOffer`); into Standard: silent (✓ `theFollowIntoStandardAddsTheAppleCopyAndMovesCustodySilentRotatingNothing`; `aSilentCustodyLibraryUnderACastleVaultOwesTheFollowIntoCastleAndAGatedOneUnderStandardFollowsSilently`).

**Why no key rotates alone** — held by construction: no door rotates L alone (the re-key is only inside the runner's roads), M alone or C alone (`begin` mints all three).

---

## §12 — THE PINS, each addressed

| pin | verdict · where |
|---|---|
| keys in custody, never in the file (backup / lock-time copy / export scans; a copy cannot sync; a fresh library only asks; the absent-store route; a locked library reads as no keys; Always ask holds keys in memory; identity kept across opens) | ✓ `SyncCustodyIdentityTests` (2), `SnapshotPairTests.theLockTimeCopyIsKeyless…`, `StorePlaintextExportTests`, `Phase13pLobbyTests.aDemandedGateOverAnAbsentStoreNeverResetsTheLock…`, `DeviceKeyStore.custody` (the `.biometric/.sessionOnly` load returns nil), `SyncCustodySession.drop()` at `AppBootstrap.lock()`, `theDeviceIdentityRidesEveryCustodyMoveAndARelock` |
| the key proof | ✓ `KeyProofGateTests` (all seven clauses incl. the NULL-hash first write once, the old proof refused, the right id without the proof deleting nothing) |
| the vault road, by use; a retired word refused at every key door | ✓ `LobbyVaultRoadTests` (8), `KeyDoorTests.changePassphraseRefusesOfflineFirstWordsARetiredWord…`, `theReplaceKeysCeremony…RefusesAStaleMaster…`, `everyKeyDoorOfAnEnrolledLibraryRefusesOfflineWithTheSentenceAndOpensOnline` |
| the owner distinction | ✓ `aRotatedVaultUnderTheSameOwnerOwesTheFollowAndLaterLeavesTheBanner`, `aDifferentOwnerSpeaksTheKeysDontMatchSentenceAndOwesNoFollow`, `ConnectLibraryTests`, `OwnerIdentityTests.aMixedLibraryReadsForeign…` |
| the master-wrapped copy of the library key | ✓ `theCurrentPassphraseOpensAnOldBackupOnline…`, `theTwelveWordsOpenALibraryWhoseLocalWCopyWasNeverLanded…` |
| the iCloud copy (Standard silent; Castle absent) | ✓ `enrollsFourDirectionsAtTheReconcileAndTheStandardRoadLandsWithNothingTyped`; the absence — attacker ARM 2, `thePreviousKeyAndTheSeqClearTogetherAndCastleCarriesNoAppleCopy` |
| entering Castle (every clause) | ✓ `enteringCastleRotatesEverything…`, `aCrashAtEachOfTheThreeSeamsResumesToCompletion`, `aCrashMidReencryptionReRunsToCompletion`, `twoDevicesSwitchingPostureAtOnceTheSecondsCASRefuseBecomesTheFollow`, `aStandardBornLibraryWithNoCustodyJoinsCastleThroughTheFollow`; the byte-copy switch + its time — the opt-in drill class (recorded) |
| any enrolled device can finish a rotation | ✓ `anyEnrolledDeviceCanFinishARotationAndANewDeviceEnrolledMidRotationReadsTheMixedCorpus` |
| version-neutral re-encryption | ✓ `reencryptionIsVersionNeutral…`, `theSeamOpensARowBelowTheRotationSeq…`, `aPushRejectsCurrentRowOpensByTheSeqRuleToo` |
| entering Castle leaves nothing behind | ✓ the insurance OFF (`snapshotAndInsurance`); the snapshot-before-offer — **MAJOR-2** (the pin asserts the ORDER, not the snapshot's SUCCESS) |
| backups never rewritten; pairs; the delete offer removes only pairs | ✓ `SnapshotPairTests`, `pruningRemovesTheSnapshotAndItsPair`, `deleteSnapshotPairs` |
| Replace All Keys refused twice on a stale master | ✓ `theReplaceKeysCeremonyWalksCopyFoursOrderRefusesAStaleMaster…` (front) + attacker ARM 4 (server) |
| the un-followed device | ✓ `theUnfollowedDeviceOpensReadsAndWaitsWithEveryDoorSpeakingTheSentence`, `theFollowModelWalksTheNoticeToTheActAndLaterLeavesTheUnfollowedState`, `theFollowRunsFromTheWordJustTypedAtTheLobby…` |
| key doors online / local-only offline / two changes at once | ✓ `everyKeyDoorOfAnEnrolledLibraryRefusesOffline…`, `aLocalOnlyLibraryChangesItsPassphraseOfflineAgainstTheKeyFile`, `bothDevicesChangeThePassphraseAtOnceTheCASRefusesTheSecondAndTheLastChangeWins` |
| twelve words at sync setup | ✓ `SyncEnrollmentTests.aCastleLibraryTypesItsPassphraseAndItsWords…`, `generateNewOnesReplacesTheLibrarysWordsEverywhere` |
| her attacker scenario | ✓ `herAttackerScenarioTheNineArmsAfterTheSwitchToCastle` (nine arms, each named), `noOwnershipChangeInstructionExistsOnTheWire` |
| posture: derivation + follow; decision 35's three pins | ✓ `thePostureIsDerivedFromTheKeyFileAndTheVault`, `herPhoneReplayedAnEnrolledSecretlessLibraryWithTheVaultUnreadWritesNothing`, `aSilentCustodyLibraryUnderACastleVault…`, `anEnrolledLibraryIsIndeterminateAtTheRouteAndTheLandingWaits`, `MobileProtectionTests.herPhonesExactStateWritesNothingWhileTheVaultIsUnreachableAndThenFollowsIntoCastle` |
| the plaintext export | ✓ `theExportCarriesTheSyncedTablesOnlyKeepsTheirSyncColumnsAndHoldsNoKey`; `PlaintextExportDoorTests` |
| custody per store id; device-bound tokens; no passcode fallback; no key material in the launch log | ✓ `StoreKeyBindingTests`, `KeychainPartitionTests`, `SessionTokenBindingTests`, `.biometryCurrentSet` alone (`StoreKeyGuardKeychain.accessControl`, `E2EEKeychainStorage.saveGated`), `ProtectionMigrationTests.everyLegRunsInOrderAndTheLogCarriesNoKeyMaterial` |
| setup adopts; re-enrollment re-initializes | ✓ `deleteRecreateConnectUploadsEveryRowUnderTheNewOwnerAndASiblingConverges`, `aForeignLibraryConfirmsTheMoveAndAdoptsAfterTheCreate` |
| deletion reachable unenrolled; the 12-char floor; the descriptor floor; never-wrap-under-a-network-key; the shared group | ✓ `AuthViews.deleteAccountSection` is in the Account tab regardless of enrollment; `AccountView.passwordFloor` + the server's 12/true (§18's PAT act); the floor pins; `EntitlementsTests` (per the records) — MAJOR-3 for the mint half |
| the rotation seq (decision 31) | ✓ `aPushThatPassedTheOldCheckLandsBelowTheRotationSeqAndNewWritesAbove`, `aSecondRotationWhileOneIsOpenIsRefusedAndCompletionClearsTheKeyAndTheSeqTogether` — **BLOCKER-1** is the one clause ("completion is 'no row of mine below it'") the walk does not guarantee |
| one rotation at a time (decision 32) | ✓ the door (`checkDoor` + `run`'s refusal) and `key_vault_update`'s refusal; the marker's resume |
| Always ask (decision 10's exception) | ✓ `anAlwaysAskDevicesHeldDerivedKeyFillsTheSessionOrTheRetiredWordBannerSpeaks`, `theLobbysPassphraseRoadHoldsTheDerivedKeyAndItsDescriptorForTheSession` |
| Standard Replace All Keys keeps the Apple copy (decision 30 — PRESENCE) | ✓ `begin(appleHeldCopy:)` under Standard; pinned in the Replace All Keys ceremony pin — with **MAJOR-3**'s `readOrMint` caveat |
| the read RPCs + the insert arm; the proof in the body only | ✓ attacker ARM 6; `aVaultIsCreatedWithItsProofHashByTriggerNeverByCheck`; `KeyVaultClient.updateVault` (a BODY `Request`), `PushRequest` / `PullRequest` / purge DTOs all body-encoded; no URL query item carries it (checked every transport call) |
| the vault's table-level write road CLOSED | ✓ `theVaultsTableLevelWriteRoadIsClosed` (DDL), `aBareSessionsDirectVaultPatchIsRefused` (the fake's 42501), the window's live probe (§18) |
| convergence suites incl. §7's choreography; both drills | ✓ `thePassphraseChangeChoreographyStepsOneToFourAndSix`, `thePosturePinsHoldInTheTwoDeviceWorld`; the drills recorded (`PostureSwitchDrillTests`, `ProtectionMigrationDrillTests`, `ConnectDrillTests` — opt-in) |

---

## THE BOOK WALK — *Encryption Explained* (the seeded text = copy §7b verbatim), then the tutorial chapter

Verdicts: **TRUE** (the build agrees; the evidence names what makes it so) · **TRUE·obs** (true, with an observation for the author) · **DEFECT** (none found).

**Chapter 1 — What is encrypted, and with what**

| # | sentence | verdict · evidence |
|---|---|---|
| 1 | Your library is one file. | TRUE · one SQLite file (+ transient `-wal`/`-shm`, swept at every re-key) |
| 2 | Every page … AES-256 under the library key — a random 256-bit number — and every page carries a check… | TRUE · SQLCipher 4 defaults (AES-256-CBC, per-page HMAC-SHA512) under `AppDatabase.configuration(key:)`; `StoreKey.mint()` is 256 bits. Observation: the HMAC is a SQLCipher default, not pinned by name |
| 3 | Without the library key the file is noise… | TRUE · `rekeyMovesTheStoreToTheNewKeyAndTheOldKeyOpensNothing`; 13p's zero-plaintext scans |
| 4 | Sync is end-to-end encrypted in both modes. | TRUE · `SyncPayloadCrypto` seals every text column on every round; posture never touches the serializer |
| 5 | …encrypted with AES-256-GCM under the corpus key, which only your devices ever hold. | TRUE · `PayloadCipher`; C exists raw only in custody (`DeviceKeyMaterial`) and wrapped under M in the vault |
| 6 | The server stores and passes along what it cannot read. | TRUE · the mirror holds `e1:` ciphertext; 14b's zero-plaintext dumps |
| 7 | What it can see is the shape: that a note exists, when it changed, roughly how much, and how things are ordered — never a word of it. | TRUE · the disclosure envelope (plain columns = ids/dates/positions/enums; `server_written_at`); decision 34 adds one device NAME per account — said in Chapter 8 |
| 8 | Your passphrase is never stored anywhere. | TRUE · the lobby holds the DERIVED key only (`holdDerivedWrappingKey`); no persisted field carries the word |
| 9 | …Argon2id (64 MB of memory, three passes — about a second on a Mac)… | TRUE · `PassphraseKDF.Descriptor.v1` (m = 64 MiB, t = 3); measured 0.766 s on the M3 (§18) |
| 10 | Anyone guessing … pays that second per guess, which is why we ask for twelve characters or more. | TRUE · every set door refuses < 12 (`passphraseTooShort`); the read floor (19 MiB/2 passes) keeps a tampered descriptor from making a guess cheap |
| 11 | Your twelve words are a random key written out as words (128 bits — the same standard hardware wallets use). | TRUE · BIP-39, 128-bit entropy (`RecoveryPhrase.generate`) |
| 12 | They wrap exactly what your passphrase wraps, so either one opens the same doors. | TRUE·obs · vault: M under W; key file: L under W. Observation: the key file's W copy is a CACHE that lands when the words are next typed here — OFFLINE, a device where it never landed opens by passphrase/Touch ID only (online the vault road opens it: `theTwelveWordsOpenALibraryWhoseLocalWCopyWasNeverLandedAndTheCopyLands`) |

**Chapter 2 — The keys, and where each one lives**

| # | sentence | verdict · evidence |
|---|---|---|
| 13 | The library key. One per library file… | TRUE · per-store mint |
| 14 | The raw key sits in the device's Keychain: Standard silently once logged in; Castle held by the security chip and released only to your fingerprint, or kept nowhere under Always ask. | TRUE · the bound DP item (`WhenUnlockedThisDeviceOnly`); the `.biometryCurrentSet` item; `.passphrase` ⇒ neither (`passphraseGateLeavesNoSilentCustodyAtAll`) |
| 15 | Beside the library sits the key file … wrapped under your passphrase, twelve words, the master key, and — in Standard only — under the iCloud key. | TRUE · `StoreKeyEnvelope` format 2; `newFile.apple == nil` under Castle pinned |
| 16 | Anyone can read the key file; it gives them nothing without one of those. | TRUE · `envelopeCarriesNoKeyBytes` |
| 17 | The master key. One per account, made when you turn on sync. | TRUE · `VaultEnrollment.setUp` |
| 18 | Each device keeps it in its own protected Keychain beside the library key — never inside the library file, so never inside any backup — and on our server only wrapped: under P, W, and Standard only A. | TRUE · `aBackupAndTheStoreHoldNoKeyAndNoIdentityEvenAfterResync`; the vault's columns; Castle's Apple column absent (ARM 2) |
| 19 | The corpus key … is wrapped under the master key. | TRUE · `corpus_key_wrapped_by_master` |
| 20 | Holding the master key is what earns the right to sync: the server asks every device to prove it holds it before it will accept or hand over a single row. | TRUE · the key proof on `sync_push`/`sync_pull` (`aSessionWithoutTheProofGetsNothingFromTheMirror…`) |
| 21 | The iCloud key. A random key that Variorum places in your iCloud Keychain the first time a Standard library exists on your Apple account. | TRUE·obs · `AppleKeyKeychain.readOrMint` — the code mints whenever A is UNREADABLE here, which is "the first time" only if propagation is ahead of the reconcile — **MAJOR-3** |
| 22 | It syncs to every device signed into your iCloud, Apple's E2EE protects it in transit, and Apple's account recovery can reach it. | TRUE · synchronizable, `AfterFirstUnlock`, no ACL (Q3 proven on her devices) |
| 23 | By itself it opens nothing: it is only ever what a Standard wrapped copy is wrapped under. | TRUE · A is a wrap key only |
| 24 | Castle leaves it where it is, with nothing current wrapped under it. | TRUE · `reconcileUnderCastleNeverTouchesTheAppleKey`; ARM 1/2 |
| 25 | If one of your devices is signed into a different Apple account, that device's own key file holds its library key wrapped under THAT account's iCloud key too — … never your sync: the master key's Apple-held copy is under the Apple account that turned sync on. | TRUE · `anAppleCopyUnderAnotherIDIsReLandedUnderThisDevicesA`; the vault's copy is written at setup / leave / Standard Replace All Keys only |
| 26 | Your account password. It signs you in and can delete your account. It wraps nothing and opens nothing. | TRUE · `AccountDeletion` by `verifyPassword`; no key act takes it |

**Chapter 3 — Standard, step by step**

| # | sentence | verdict · evidence |
|---|---|---|
| 27 | The first time Variorum opens, it makes a library key and a key file, places an iCloud key … if one isn't there, and writes a copy of the library key wrapped under it into the key file. | TRUE · `StoreIdentity.establish`; `reconcileLandsTheAppleCopyAndVerifiesItOpens` |
| 28 | From then on your Mac opens the library silently, and any Mac signed into your iCloud can open a copy of it with nothing typed. | TRUE · `aStandardLibraryWithAMissingBoundItemOpensThroughTheAppleKey` |
| 29 | Turning on sync asks for a passphrase and shows you twelve words. | TRUE · `SyncEnrollmentModel` (copy §2a's order pinned) |
| 30 | It makes the master key and the corpus key, sends the master key wrapped three ways — P, W, A — and keeps the raw master key in this Mac's protected Keychain beside the library key, never in the library file. | TRUE · `aFreshStandardLibraryWalksTheCopysOrderAndTheVaultIsBornWhole` |
| 31 | A new Apple device signs into Variorum, reads the iCloud key, unwraps the master key, and has everything: nothing typed. | TRUE·obs · `enrollsFourDirectionsAtTheReconcileAndTheStandardRoadLandsWithNothingTyped` — under propagation lag the reconcile mints instead of waiting (**MAJOR-3**) |
| 32–34 | So in Standard: anyone fully inside your Apple account … Anyone at your unlocked Mac … the same trade Apple Notes makes. | TRUE · by construction of the two roads |

**Chapter 4 — Castle, step by step**

| # | sentence | verdict · evidence |
|---|---|---|
| 35 | Entering Castle does five things. | TRUE · L′ · M′ · C′+re-encrypt · custody behind the gate · the follow — five |
| 36 | Your library is re-encrypted under a brand-new library key, and the new key file wraps it under P, W and M only — never A. | TRUE · `writeNewKeyFile(entersCastle: true)`; `enteringCastleRotatesEverything…` |
| 37 | Your sync gets a new master key too, sent wrapped only under P and W; the old master key stops being accepted. | TRUE · `begin(appleHeldCopy: nil)`; `theOldProofIsRefusedAfterARotation…` |
| 38 | And a new corpus key: everything on the server is re-encrypted under it from your Mac, so nothing written after today is ever under a key an old copy holds. | TRUE · the walk + `sync_reencrypt`; the confidentiality clause holds even under **BLOCKER-1** (the straggler is PRE-switch writing; its harm is availability) |
| 39 | The copy of the library key your Mac keeps moves behind Touch ID — … or is kept nowhere under Always ask. | TRUE · `moveCustodyForSwitch` |
| 40 | And your other devices follow: each re-encrypts its own library the same way and asks for your passphrase once to pick up the new sync keys. | TRUE · `aStandardSiblingFollowsByThePassphrase…` |
| 41 | After that, three things can open your library: your passphrase, your twelve words, or a device you already enrolled, through its fingerprint. | TRUE · the lobby's three roads; the enrolled device's master copy is "a device you already enrolled" |
| 42–44 | Nothing in iCloud can. Nothing on our server can. Your Mac's login password can't. | TRUE · ARM 1 (L′ refuses A), the wrapped-only server copies, the gated custody |
| 45 | And nothing can be reset: there is no key anyone else holds. | TRUE · the forgot road needs Touch ID or the words on the device that holds the keys |
| 46 | That is the floor, and it is what makes Castle real. | TRUE |

**Chapter 5 — Backups**

| # | sentence | verdict · evidence |
|---|---|---|
| 47 | A backup is a sealed copy of your library file plus its key file as they were that day. | TRUE · `SnapshotPairTests` |
| 48 | It opens with whatever that key file's wrapped copies open under: the passphrase you had then, your twelve words, and — Standard — your iCloud key. | TRUE · the pair's own key file; ARM 1 |
| 49 | Variorum never changes a backup after it makes it. | TRUE·obs · never REWRITTEN (`…NeverRewritten`, `copyKeyEnvelope` only-when-absent); retention PRUNES — NIT-5 |
| 50–52 | Why your iCloud key can still open an old backup after Castle, but not your library … no more. | TRUE · ARM 1 (both halves) |
| 53 | Why opening an old backup does not bring sync back: a backup holds your writing and nothing else — no sync keys. | TRUE · `aBackupAndTheStoreHoldNoKeyAndNoIdentity…` |
| 54 | To sync again it has to join your account like any device… | TRUE · `aRestoredSnapshotWithTheCurrentIdEnrollsSilentlyAndAStaleIdOwesTheFollow` |
| 55–56 | And entering Castle replaced the keys Standard could reach … Signing in with your account password gets you a session, not a key. | TRUE · ARMs 2–6 (the register exception recorded) |
| 57–60 | So if you are in Castle, have lost both secrets, no enrolled device: an old Standard backup … gives you back what you wrote up to that day. To sync again you delete your Stargazing account and set sync up fresh … Whatever you wrote after the backup and kept only on the server is gone. That is Castle's floor… | TRUE · ARM 1 + ARM 7; `deleteRecreateConnectUploadsEveryRow…` |
| 61 | This is why entering Castle offers to delete the backups Variorum made before that day, and why it tells you about Time Machine and copies you made… | TRUE·obs · the offer + `deleteOldBackupsBody`; the offer is made even when the fresh snapshot failed — **MAJOR-2** |

**Chapter 6 — Changing things**

| # | sentence | verdict · evidence |
|---|---|---|
| 62–63 | Changing your passphrase is … not a security measure. It re-wraps the same keys under the new word. | TRUE · `rewrapMovesThePassphraseAndNothingElse` |
| 64 | The library key, master key, words and sync are untouched; the new passphrase works on other devices right away online, and each stops taking the old one once you've used the new one there. | TRUE · `theNewWordOpensOnlineReWrapsTheLocalCopyAndTheOldWordOpensUntilThen`; `changingThePassphraseOnOneDeviceRetiresTheOldWordAtTheVaultForItsSibling` |
| 65 | If someone may have your passphrase, replace all your keys instead. | TRUE · the checkbox hands the new word to Replace All Keys |
| 66 | Old backups keep the passphrase of their day — on the Mac they were made on, the current passphrase still opens them as long as the library key hasn't changed, because the key file beside your library pairs with them. | TRUE·obs · true by the runbook's restore recipe (put the copy in the library's place beside the live key file) and online by the master copy; the IN-APP same-fingerprint second look is 13x's (ledger 14) — copy §8's ⚠ NOT YET BUILT flag covers it |
| 67–69 | Regenerating your twelve words re-wraps … the old words stop opening the server's copy and this device the moment the new ones are confirmed; a device where you haven't used the new words yet still takes the old ones… If your words were seen, replace all your keys. | TRUE · `regeneratingTheWordsOnOneDeviceRetiresTheOldWordsAtTheVaultForItsSibling`; `onRecoveryPhraseLanded` re-lands the local W copy |
| 70 | Replacing all your keys … a new master key, a new corpus key with everything re-encrypted, and a new library key on each device as they follow — each asks for your passphrase once. | TRUE · `replaceAllKeysThroughTheDoorIsFollowedByTheSiblingAndAStaleCopyOpensNothing` |
| 71–73 | Your passphrase and twelve words stay unless you change them too. Use it when someone may have USED a secret … A copy of your library or a backup holds no keys, so it is never the reason on its own. | TRUE · the ceremony's words in hand; the custody-not-in-file pins |
| 74 | In Standard it does not shut out someone inside your Apple account: the new master key is wrapped under your iCloud key again, and they hold that. | TRUE · `begin(appleHeldCopy:)` under Standard — decision 30's presence pin |
| 75–76 | For that case, secure your Apple account … or move to Castle … Entering Castle runs this same act for you. | TRUE · one runner |
| 77 | Switching to Standard wraps the library key and the master key under your iCloud key again. | TRUE · `leaveCastle` |
| 78 | Switching to Castle is Chapter 4. | — |
| 79–80 | Deleting your account and setting sync up again … replaces everything … Your libraries on your devices are never touched by it. | TRUE · ARM 7; `deleteAccount` keeps custody and the store |

**Chapter 7 — Who can read what**

| # | sentence | verdict · evidence |
|---|---|---|
| 81–85 | The server: never. Apple: Standard yes / Castle nobody. Login password: Standard yes / Castle no. Secrets: yes either mode. Open and unlocked: yes either mode. | TRUE · §3.4's two tables, walked above |
| 86–90 | The compromise rule: seen → change/regenerate; used or a device unlocked → Replace All Keys; Standard + Apple account → Apple's tools or Castle; account password leaked → sign out everywhere and change it; the account in someone's hands → delete and set up again. | TRUE·obs · every door exists (`KeyDoorModel`, `PostureSwitchModel.replaceKeys`, `signOutEverywhere`, `deleteAccount`) EXCEPT "change it" — no in-app account-password change door — **MINOR-6** |
| 91 | The device named in a notice is the device's own word for itself; the day is the server's… | TRUE · `updated_by_device` from the payload; `updated_at = now()` in the RPC |

**Chapter 8 — What we can and cannot do**

| # | sentence | verdict · evidence |
|---|---|---|
| 92–94 | We cannot read your writing … cannot reset a Castle passphrase … cannot recover your writing if… | TRUE · no server-held key in Castle (the vault's columns) |
| 95 | We can see when your devices sync and how much; we cannot see what. | TRUE · `device_cursor.seen_at`, `server_seq` cadence; ciphertext |
| 96 | We can delete your account on your word, and we can sign your other devices out on your word. | TRUE · `account_purge` (session-only), `signOut(scope: .global)` |
| 97 | Everything else is yours. | — |
| 98–99 | When a notice names the device … that name is what the device calls itself — the day is ours. A name you don't recognize … is the sign to replace your keys. | TRUE · ledger 49's disclosure; `DeviceName.current` |

**The tutorial chapter — "keeping it private" (copy §7; `TutorialSeeder` ≈1208–1230, `MobileTutorialSeeder` ≈650–660, both from `ProtectionCopy.privacyLesson*` verbatim; pinned by `TutorialWalkTests.theChapterIsTwoLessonsInTheRightPlace`, `MobileTutorialWalkTests.theLessonRendersCopySevenInThePhonesNouns`)**

| lesson · sentence | verdict · evidence |
|---|---|
| L1 · Your library is encrypted on disk … to anyone who copies it. | TRUE · s3 above |
| L1 · Sync is end-to-end encrypted … stores what it can never read. Both modes are like this. What differs … is only who holds a key. | TRUE · s4–6; the postures differ only by the Apple-held copies (§3.4) |
| L1 · keystone 3 (the account password) | TRUE · s26 |
| L1 · keystone 4 (open means readable) | TRUE · corner 19 |
| L2 · Standard is the default. Your Apple account holds a key. | TRUE · `Posture.localReading` (no key file ⇒ Standard); the fresh library's Apple copy lands at ready |
| L2 · Keep: your Apple account, and — if you use sync — your passphrase and twelve words, in case your Apple account is ever gone. | TRUE · sync setup demands both (decision 5) |
| L2 · Anyone who can open Variorum as you, at your unlocked Mac or fully inside your Apple account, can read. | TRUE · the silent item + A |
| L2 · Castle means only you hold the keys. Keep: your passphrase and your twelve words. | TRUE |
| L2 · Touch ID opens this Mac for you; your passphrase is what lets a new device in. | TRUE · keystone 2's mechanism |
| L2 · Lose every enrolled device and both secrets, and your writing is gone — nobody can help. That is the point. | TRUE · the floor |
| L2 · The whole story … is in the book "Encryption Explained" on this shelf. | TRUE·obs · seeded by `SampleLibrarySeeder` (`Book.encryptionExplained`) on both platforms and restorable from Help on the Mac — absent on a signed-in-never-synced store until its first clean round (ledger 70) — **MINOR-8** |

---

## CLEAN BILL — what was specifically checked and found solid

- **The key proof is the authorization on every mirror door**, and the order inside the SQL is right: absent-vault → lock choice by the unlocked peek → the 14c fence → the proof (constant-time, the NULL arm under `FOR UPDATE`) → entitlement; the data RPCs hold `FOR SHARE`, `key_vault_update` `FOR UPDATE`, no lock-order cycle (vault row then data rows on every road); the six old signatures are dropped first; the marker is the last statement; the helpers are reachable by no API role; `variorum_definer` owns every data function, is a member of `authenticated`, and has its own SELECT + UPDATE policies on `key_vault`; the default DELETE grant is revoked by name. The fake server enforces the same gates in the same order.
- **No secret rides a channel it should not:** the proof is a body parameter on every transport call and on the vault RPC (no URL, no header); the KDF logger line carries a duration; the migration's log lines are pinned key-free; `AppleKey.description` is redacted; the re-key's `ATTACH … KEY` failures scrub both keys (`aFailedAttachNeverCarriesTheKeyHexInAnyErrorChannel`).
- **The custody family is one shape three ways** (`SyncCustodyShape` from `StoreAtOpenMode`; both items move in one `CustodyHandover`; the gated read is ONE `LAContext` for L, M, C, J and the identity — corner 41; `.biometryCurrentSet` alone, never a passcode fallback; `SyncCustodySession.drop()` at every lock; the derived wrapping key, never the word, in session memory).
- **The device identity rides custody, never the file:** `sync_state.device_id` is gone from the engine (`roundDeviceIdentity` from the provider; `resyncReinitialize` has nothing of it to spare); the migration's leg 1 carries the 13j row into the identity-only item (ledger 43) and the dev-scope legs are inert (corner 47).
- **The posture is derived, never stored**, with decision 35's indeterminate reading honored at the route, at ready, and inside the migration (which stops before leg 3 undone); the Apple arm writes nothing under an indeterminate reading; the follow fires on a posture MISMATCH as well as a key change.
- **The rotation is version-neutral and any M′-holder can finish it** — the previous key rides the vault under M′ with its id and the server-assigned seq; the seam opens rows by the seq rule on both the pull and the push-reject roads; completion clears key, id and seq together on the vault and in custody (BLOCKER-1 is about WHEN completion is allowed, not about what it clears).
- **Backups are pairs and are never rewritten;** the lock-time copy is keyless, paired, checked at the next unlock; the folder-level fingerprint file and the legacy file are written only when absent.
- **The plaintext export** keeps every synced table with its sync columns, drops exactly the registry's four local-only tables (never a hand list), refuses the backups folder, never runs on a schedule, and takes the passphrase under Castle (never Touch ID alone).
- **The doors' authorizations match §5:** change passphrase / regenerate verify the current word against the VAULT (a retired word worded as such by the recorded-descriptor test), the forgot roads by posture (plain / Touch ID / the words), every enrolled key door refuses offline before any field; Replace All Keys takes P typed + W typed-or-regenerated (decision 33; the runner refuses a wrap-less rotation over a vault with a wrap); leaving Castle by Touch ID or the passphrase; deletion by the account password through a fresh grant whose token pair is discarded and revoked; sign out everywhere is `scope=global`; the 12-character floor is enforced client-side and server-side (12 / HIBP on, read back).
- **The owner distinction** reads the EXACT foreign-owner predicate (any owner-carrying row ≠ the signed-in id); a rotated same-owner account follows with no re-stamp; a foreign owner adopts through `restampOwner` + `resyncReinitialize`; her attacker scenario's nine arms hold, and no ownership-change instruction exists on the wire.
- **The two-register rule** holds over every copy home and the seeded book (the one recorded exception is copy §7b's own sentence); the seeded book equals copy §7b sentence for sentence; the tutorial chapter equals copy §7; the four keystone lines render verbatim on both platforms; corner 19 and corner 22 render where the design says.
- **The lobby's vault road** is the ONE pre-unlock network contact, starts concurrently with the local derivation, derives once when descriptors match, writes the fresh local copy only after both unwraps succeed, hands off at the ceiling with the offline note, and the follow reuses the word just typed (ledger 54).
- **The absent-store route never resets a lock;** Start a New Library mints under a NEW store id with its own Auto dials; the old library's items stay unreachable, never deleted.
- **Migration §11** runs once per store id, off the main thread, every leg logging a line and never key material; the foreign escrow item is left; a refused alignment leaves the run undone for the next ready.
- **Zero schema, zero client migration** (the marker moves for the RPC semantics alone); `SyncSchema.lockstepVersion == 8 == the mirror's marker` (the DDL pin); every changed `Sync/` line is proof/rotation plumbing consistent with SyncSpec §3–§7's letter (S1–S5 untouched: tiny writes, tombstones, random UUIDs, `owner_id`, conflict-as-variant — `reencryptionIsVersionNeutral…ConvergesWithZeroConflicts` is the S5 proof under rotation).
- **Cost discipline:** the walk is bounded by the rotation seq and re-downloads the corpus once per rotation (the design's stated cost, corner 40); `foreignOwnerExists` / `stampedOwnerID` are one indexed `LIMIT 1` per owner-carrying table; the dedupe's per-book pass runs only on its occasions; nothing new scales with the corpus on a keystroke road.
