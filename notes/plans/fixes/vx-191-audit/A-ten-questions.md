# VX-191 audit — AREA A: the ten questions re-run at HEAD (f337f19e)

*Read-only re-derivation of `notes/plans/run-b-stress-pass.md` (2026-09-21) against today's code, plus the open crypto/custody backlog and an eleventh question. Worktree `~/dev/variorum-vx-191`, branch `vx-191-encryption-audit` = main f337f19e. COMPLETE.*

## VERDICT TABLE

See the table at the end of this file (after Q11).

---

**Suite evidence for this area (run here, headless, the worktree at f337f19e):** `swift test --skip-build --filter "KeyProofGateTests|MultiTenantSyncAttackerTests|CorpusRotationTests|PassphraseKDF|KeyVaultFormat|StoreKeyEnvelope"` → **`✔ Test run with 93 tests in 9 suites passed after 15.732 seconds.`** The Mac-target pins this file cites (`PostureSwitchTests`, `Phase13pControllerTests`, `VX80CastleFollowRecoveryTests`) were READ, not run (no `xcodebuild test` in this audit — the brief's rule).

## Q1 — the key proof's server-side retention surface — **HOLDS (mechanism changed; residual narrowed, one 09-21 sentence now false)**

**What changed since 09-21 (13y UNIT B).** The static bearer proof is gone. Each gated RPC now carries `HMAC-SHA256(kp2, nonce ‖ ':' ‖ rpc_name)` over a single-use, 5-minute, server-minted nonce (`Sources/VariorumCore/Crypto/KeyProof.swift:128–133`; signer `Sources/VariorumCore/Sync/KeyProofChallenge.swift:72–106`). Server side: `sync_challenge` mints 32-byte nonces, ≤64 live per owner (`Server/supabase/12_phase13y_tenant_seq.sql:538–583`); `sync_key_proof_check` consumes the nonce by `DELETE … RETURNING` (single-use per SUCCESS — a refused call rolls the delete back), enforces the server-clock TTL, recomputes the HMAC under the Vault-held kp2 and compares constant-time with both comparands null-guarded (`12…sql:656–739`). The RPC name is bound, so a captured unspent pair cannot be spliced onto another door. kp2 = `HMAC(M, "variorum.key-proof.v2")` (`KeyProof.swift:57–59`), a value that yields nothing about M.

**The retention surface today:**
1. **Routine RPC bodies (push/pull/horizon/ledger/purge/truncate/reencrypt/vault update):** a captured body holds a SPENT nonce and its MAC — not reusable (single use + TTL + RPC binding). Pins: `KeyProofGateTests.aCapturedProofPairReplayedRefusesAndNothingLandsTwice` (:717), `anExpiredChallengeRefusesOnTheServersClockAlone` (:747), `aProofBoundToOneDoorRefusesOnAnotherAndTheSpliceGainsNothing` (:776). This closes 09-21's residual (closeout consideration 1 → 13y): **DELIVERED.**
2. **The two bodies that still carry a REUSABLE secret:** `key_proof_enroll(kp1, kp2, …)` (once per account, `12…sql:590–640`) and every rotation's `key_vault_update` payload key `key_proof_mac` = kp2′ of the NEW master (`13_phase13i_wings.sql` key_vault_update, the `incoming_mac` block; client `CorpusRotation.swift` `begin`, `successorMacKey:`). Body logging at the API edge during an enrollment or a Castle entry / Replace All Keys retains kp2 → the ability to mint valid proofs until the next rotation.
3. **NEW since 09-21 — the data plane now holds the reusable secret.** 09-21's "the durable data plane … retains only SHA-256(kp)" is no longer true: kp2 lives in Supabase Vault (`vault.create_secret(kp2, 'kp:'||uid)`, `12…sql:637`; read back as plaintext through `vault.decrypted_secrets`, `12…sql:681–683`). Supabase Vault encrypts at rest under a server-managed key, so a database operator (or anyone holding a backup plus that key) can read kp2. This is inherent to an HMAC challenge where the server verifies; the design accepted it (13y memo §3).

**What a holder of kp2 (+ a session for the account) can do:** exactly the 09-21 class — integrity/availability, never confidentiality: push/truncate/purge, and `key_vault_update` (which lets them lock real devices out — the loud, survivable account-password class). They cannot read: kp2 is not M, unwraps nothing, and the vault's master copies are under P/W (and A under Standard). Destructive acts also need a fresh password sign-in now (`account_data_truncate`'s 10-minute amr window, `13_phase13i_wings.sql:600–603`). A DB operator could do all of this anyway with direct table access; the proof's job is to stop a bare stolen SESSION, and it still does.

**NIT (wording, not mechanism):** if any outward copy says the server "stores only a hash of the proof" or "never holds a key", the second is still true of ENCRYPTION keys but kp2 is a server-held AUTHENTICATION key. Worth one precise line in the privacy brief. Not checked against the website copy (outside this repo).

## Q2 — the attacker scenario, nine arms + a tenth — **HOLDS; the 09-21 NIT was DELIVERED**

The nine arms remain in `Tests/VariorumCoreTests/MultiTenantSyncAttackerTests.swift` (`herAttackerScenarioTheNineArmsAfterTheSwitchToCastle`, :278) and pass (the run above). The 09-21 tenth arm — `sync_reencrypt` under the old proof — is now a real arm: `MARK: - (10) sync_reencrypt under an OLD key proof (RUN B B4, ledger row 16)` (:528), firing the old key id (fence refuses, :566), the old proof under the current id (proof refuses, :573), the rotated material succeeding (:588), plus a text pin that the deployed body calls `sync_key_gate(… 'sync_reencrypt')` (:605–610). Production SQL: `13_phase13i_wings.sql:509` (the latest `sync_reencrypt` body) routes through the same gate.

**NIT (pin scope):** the arm-10 text pin reads `12_phase13y_tenant_seq.sql`'s body (`sql12.components(separatedBy: "create or replace function sync_reencrypt")`, :605–606), but `13_phase13i_wings.sql:479` REDEFINES `sync_reencrypt` and is the deployed body. 13's body does carry the gate (verified by reading :509), so nothing is open today; the pin would not notice a later file dropping it. Fix shape: read the final body (the `AuthRLSDDLTests.finalBody(of:)` helper already does this for `key_vault_update`).

**Still true and worth restating for the attacker who holds the OLD master:** with 13y the old master gives the old kp2, whose Vault secret was replaced at the rotation's begin (`key_vault_update` `vault.update_secret`, same txn as the hash) — every challenge-gated call then refuses. Pin: `KeyProofGateTests.theOldProofIsRefusedAfterARotationAndTheNewOneAccepted` (:324).

## Q3 — the pre-rotation straggler vs the horizon + completion guard — **HOLDS; both 09-21 residuals DELIVERED; one routed residual NOT delivered (poison row)**

- **One horizon source of truth (closeout consideration 2 → 13y): DELIVERED.** The server horizon is one function, `sync_visibility_horizon_ms()` returning 2000 (`12…sql:445–450`); the deployed `sync_pull` derives its filter from it (`13_phase13i_wings.sql:211`); the client walk fetches the SERVED value and waits served + 500 ms (`CorpusRotation.swift:338–358`, `horizonWait(forServedMillis:)`). No client constant can drift from the server's any more.
- **The deploy-checklist caveat (09-21: an `11` redeploy silently reverts the overlay guard): DISSOLVED.** The completion guard is folded into the canonical `key_vault_update` body (12, then 13 — `13_phase13i_wings.sql` the `rows_below` loop under `if vault_previous is not null`), so no overlay can be dropped. Pinned by `AuthRLSDDLTests.theCompletionGuardLivesInTheCanonicalTwelveBody` (:2301), which reads the FINAL body across files and asserts the guard's ciphertext map equals the client registry byte-exact (13 added `wing`/`shelf`; the pin would catch a future encrypted column missing from the map).
- **The guard is still seq-based and clock-independent**, now on the per-tenant sequence (`next_tenant_seq(caller)` at rotation begin; rows stamped by the same counter). Pins green in the run above: `CorpusRotationTests` incl. `aStragglerWithEveryEncryptedColumnNullNeverHoldsACompletion`, `aCrashMidReencryptionReRunsToCompletion`.
- **NOT delivered — the poison-row class (closeout consideration 7 → Phase 12):** `aPoisonRowLeavesTheRotationStillFinishingWithThePreviousKeyRetainedUntilItIsPurged` still passes, i.e. the behavior is still "still finishing forever, nothing cleared". Phase 12 is unbuilt (`notes/DetailedPlanForPhases.md:185`) and no VX ticket names the poison row (grep of `notes/TICKETS.md`: none). Safe (availability, no exposure, the previous key retained), but the account has no user door out and a second rotation (Castle entry / Replace All Keys) is refused while it stands. **Severity MINOR for launch** (needs a row sealed under a key the account never held — corruption or a hostile session-holder with the proof). Suggest: a ticket so it is owned.

## Q4 — same-second passphrase changes / Castle entries — **HOLDS (pins present; Mac-target, read not run)**

The four choreography pins are present by name in `App/Variorum/VariorumTests/PostureSwitchTests.swift`: `bothDevicesChangeThePassphraseAtOnceTheCASRefusesTheSecondAndTheLastChangeWins` (:4648), `twoDevicesSwitchingPostureAtOnceTheSecondsCASRefuseBecomesTheFollow` (:4746, asserting the loser's Done == `enteredCastleAfterAnotherDevice`, :4793), `aCeremonyKilledBeforeItsVaultWriteResumesIntoAnotherDevicesSwitchAsTheFollowAndSaysSo` (:4828), `aCeremonyWhoseOwnWriteLandedResumesAsItselfAfterAFollowerFinishedAndSpeaksTheOrdinaryDone` (:4889). Her ruling (QUESTIONS #90(3)) landed: the conflict Done now says WHERE the real words are (`App/Variorum/Shared/PostureCopy.swift:852–857`). VX-99 round 2 added the Replace-All-Keys sibling (`keysReplacedAfterAnotherDevice`, :907–912). Under 13y the loser's refusal is still the PROOF's (the winner's rotation replaced the Vault secret) — consistent with ledger 62.

**Residual (VX-107, open):** a DOUBLE crash on the conflict-follow road loses ledger 61's sentence — the resume speaks the plain follow Done over twelve words that never landed (`notes/plans/fixes/vx-99-ladder-round3.md:131–153`). See the backlog section.

## Q5 — the recovery-wrap digest — **HOLDS (unchanged)**

`RecoveryWrapDigest.hex` (`Sources/VariorumCore/Crypto/KeyVaultFormat.swift:440`), recorded in the key file (`StoreKeyEnvelope.swift:96–102`, `recordVaultRecoveryWrapDigest` :343), consumed only by the advisory `changeElsewhere` (`App/Variorum/Shared/ProtectionController.swift:822–832`). Landing still verifies the WORDS against the vault's real wrap; the wrap is still deterministic RFC 3394 `AES.KeyWrap` (`KeyVaultFormat.swift:135, 292`). 09-21's analysis carries over verbatim. No change.

## Q6 — iCloud Keychain reset, three Standard devices — **HOLDS (17m DELIVERED) — with a CORRECTION to the 09-21 trace**

- **17m (the Re-link door) DELIVERED:** `notes/plans/phase-17-standing-fixes.md:118` (CLOSED 2026-09-21, `AppleRelinkDoorTests` ×8).
- **Correction:** 09-21 said the heal (`healAppleHeldCopy`) cannot fire after a reset because "a reset does not create" a read of a different id. With THREE devices it does: device 1 (holds the master) reads nil and MINTS A′ into the shared synchronizable item (`App/Variorum/Shared/AppleKeyCustody.swift:141–146, 174–178` — one fixed account, `kSecAttrSynchronizable = true`); iCloud Keychain syncs A′ to devices 2 and 3; at their next ready `appleKeys.read()` returns A′ (a READ, `minted == false`, `ProtectionController.swift:1594–1599`), their key files still record the vault's original id, and `apple.id != vaultAppleKeyID` — so the heal arm (`:1535–1547`) fires and re-lands the VAULT's Apple-held copy under A′ with no prompt.
- **Why this is not a finding:** the heal's own premise holds exactly — only the SAME Apple account could have put A′ in that item — and the account is in Standard, whose consented trust root already is that Apple account. Net effect: the orphan heals itself automatically once a second device sees the new key, which is the desired Standard state. It never writes on a Castle account (`guard determined == .standard`, :1492) and its vault write needs the current proof (`relandAppleHeldCopy`, wired at :1982–1984), so a lagging device holding an old master cannot re-add an Apple copy to a vault that entered Castle elsewhere.
- **NIT (record precision):** the same mechanism means an Apple-ID SWITCH on two devices (both moved to Apple ID B) re-homes the vault's copy under B silently — MINOR-N1's original worry, now reachable by two devices instead of one. Benign if B is hers; worth one sentence in the design record so "the heal never fires on a reset" is not relied on.

## Q7 — the fresh library on a Castle Mac cannot sync without a typed secret — **HOLDS (re-verified with 13x in the picture)**

Unchanged roads: `StoreLaunchRoute.resolve` → `.libraryMissing(demand:)` on absence (`App/Variorum/Shared/StoreLaunchGate.swift:308`); `openResettingModeToAuto` survives only as a red-on-old note in `Phase13pLobbyTests.swift:53, 347`; Start New mints a new store id (`AppBootstrap.swift:1043`); the engine refuses before network contact with no custody (`UnenrolledKeyProvider`, `Sources/VariorumCore/Sync/SyncEncryption.swift:79, 99`). 13y adds nothing a fresh library can satisfy: it needs kp2, derived only from M. **13x's Open Library** does not open a bypass: an adopted copy of a DIFFERENT library has no custody for its store id (`CustodyCollisionRule.mintFreshCustody`, `Sources/VariorumCore/Persistence/CustodyCollisionRule.swift:41–44`) and "a copy never carries the sync key or device identity", so it enrolls — on a Castle account, by P or W; an adopted copy of the SAME library on the same Mac uses this Mac's own existing custody (not a bypass — the same enrolled device), and lands HELD until Resume Sync.

## Q8 — a pre-Replace-All-Keys backup restored on the same Mac — **HOLDS; the 13x caveat DELIVERED**

13x built the routing 09-21 left open: File ▸ Open Library / Settings ▸ Restore from Backup open the pair by its OWN key file's roads, and custody then adopts the key that opened the landed file — `CustodyCollisionRule.verdict` returns `.adoptOpeningKey` when custody held a different fingerprint (`CustodyCollisionRule.swift:35–53`). So the current key's custody item is never applied to the older file; it is REPLACED by the older file's opener (the moved-aside current library keeps its own key-file roads). The credentials: the day's P, the twelve words (unless regenerated), Standard's Apple account — never the dead old master. Restoring a pre-CASTLE (Standard-era) pair onto a Castle account on the same Mac is the 13x ladder's R1-BLOCKER, FIXED by the `castleKeyFileAppleOpenable` reconcile arm (`ProtectionController.swift:663–684`): the follow is owed and named on screen until it re-keys and retires the Apple-carrying key file. Pin: `anAdoptedStandardEraPairUnderACastleVaultOwesTheFollowThatRetiresItsAppleCopy` (Mac target; read). Two things to be aware of: (a) that detection needs a signed-in vault reading — restored while signed out, the Apple-openable live file is undetected until sign-in; (b) between the restore and the follow, the live library IS Apple-openable on a Castle account. The notice tells her, so this is not a false belief. Folded into Q11 below.

## Q9 — a device wiped and restored from Time Machine — **HOLDS (custody/identity); one precision**

The custody items are DATA-PROTECTION keychain items with `WhenUnlockedThisDeviceOnly` in force: the sync-custody queries merge `KeychainPartition.dataProtection` (`App/Variorum/Shared/EncryptionKeychain.swift:754–768`, class at :595/:643); the store-key bound item sets `kSecUseDataProtectionKeychain` (`Sources/VariorumCore/Persistence/StoreKey.swift:421`, class :380–381 — the #82 fix that made the class real on macOS); the Apple key is synchronizable by design. So nothing in custody migrates; the identity is fresh; corner 37's returner road applies. Unchanged from 09-21.

**Precision (not a finding):** 09-21's "Time Machine … carries nothing usable" is true of KEYS and IDENTITY, but the key FILE travels with the library, and it carries the passphrase wrap (Castle) or the Apple wrap too (Standard). A Time Machine disk is therefore an offline brute-force target on P — exactly Q10's class. The Castle explain copy already says Time Machine backups made before today still open through the Apple account (`PostureCopy.swift:321–325`); Castle-era Time Machine snapshots fall under Q10.

## Q10 — brute-forcing the passphrase against a stolen key file — **HOLDS as a design; the 09-21 refinement was NOT adopted → MINOR residual**

**What ships.** Every wrap is MINTED at Argon2id **m = 64 MiB, t = 3, p = 1**, 16-byte salt, 32-byte output (`Sources/VariorumCore/Crypto/PassphraseKDF.swift:73–83`). That is RFC 9106's second recommended set with one lane instead of four, and about 3× OWASP's 19 MiB/t=2 minimum. The read-time floor (m ≥ 19 MiB, t ≥ 2, salt ≥ 16 B; `Floor.production`, :106) refuses a downgraded descriptor before any derivation. It applies at every read site, including the key file's (`StoreKeyEnvelope.swift:359, 375`); the test-host relaxation is `#if DEBUG` plus test-process only (:121–135). The offline attacker cannot use the floor to cheapen anything — the stolen wrap was made under its own 64 MiB/t=3 descriptor.

**What 17n delivered.** It delivered a 12-character LENGTH floor at every door that SETS a passphrase. `ProtectionCopy.passphraseFloor = 12` (`App/Variorum/Shared/PostureCopy.swift:347`) is enforced in `PassphraseSetModel.swift:221`, `KeyDoorModel.swift:444`, `PostureSwitchModel.swift:318, 531` and `SyncEnrollmentModel.swift:153, 160`. Existing shorter passphrases still unlock, by design. There is **no strength or entropy check**: a grep of `Sources`/`App` for zxcvbn/entropy/strength finds only the recovery phrase's 128-bit entropy. 09-21's refinement (a length floor is not an entropy floor) was therefore not built. The only mitigation is the subline "Four or more random words work well" (`PostureCopy.swift:336–338`).

**Is the cost reasonable? (external figure via a read-only subagent; extrapolations labeled.)** hashcat 7's own example session for mode 34000 at exactly `m=65536,t=3,p=1` shows about **1,700 guesses/s per RTX 4090** (hashcat.net wiki; an example session, not a formal benchmark). My extrapolation, linear in GPUs:

| Passphrase | Entropy | 1 GPU (~1.7×10³/s) | 1,000 GPUs (~1.7×10⁶/s) |
|---|---|---|---|
| human-chosen 12 characters (word + digits + symbol) | ~30–40 bits | days to ~20 years | minutes to ~a week |
| 4 random Diceware words | ~51.7 bits | ~60,000 years | ~60 years |
| 12 random alphanumeric characters | ~71 bits | out of reach | out of reach |

So the KDF is sound and well-sized for a consumer app. The weak link is a human-chosen passphrase that merely meets the length floor.

**Who can reach the wrap offline.**
- Anyone holding a key file: Variorum's backup pairs, Time Machine (Q9), a stolen or imaged disk, a phone's iCloud device backup (Q11).
- The server operator, through the vault's `master_wrapped_by_passphrase` plus its KDF columns.

The subline names only the server ("the one thing a stolen copy of the server could be guessed against"). That is true but incomplete, since a stolen backup or key file is the same target.

**Severity: MINOR.** The class is disclosed, owned and closed by 17n. The attacker needs a stolen key file or vault AND a weak passphrase, and the twelve words remain a 128-bit anchor.

**Suggested shape (not implemented):**
- a strength estimate at the SET doors — warn, or refuse below ~50 bits; or
- offer a generated Diceware passphrase; and
- widen the subline to "a stolen backup or a stolen copy of the server".

---

## THE OPEN CRYPTO/CUSTODY BACKLOG — launch severity

The question asked of each ticket: can it leave her believing she is in Castle while something current is still A-openable (or the reverse), or lose data or keys? Sources: `notes/TICKETS.md` (main), `notes/plans/fixes/vx-99-*.md`, `notes/handoffs/vx-99-handoff.md:70–76`, `notes/QUESTIONS.md` #205, `notes/plans/fixes/vx-80-castle-follow-recovery-door.md`. Every code citation was re-read at HEAD.

### VX-110 — Use Castle runs its local-only road for an ENROLLED library whose session lapsed — **MAJOR (false-Castle belief). Recommend fixing before launch.**

**The trace at HEAD:**
1. The pane offers *Use Castle* whenever `controller.posture == .standard` (`App/Variorum/Variorum/Features/Settings/ProtectionPane.swift:329–333`). The runner is wired unconditionally (`VariorumApp.swift:295–304`).
2. `checkDoor` returns `enrolled: false` when signed out (`PostureSwitch.swift:413–419`). `PostureSwitchModel.start` sends `.enter` straight to `.explain` with no enrolled check (`PostureSwitchModel.swift:258`).
3. In `runCeremony`, `enrolled = vault && transport && signedIn && custody` (`PostureSwitch.swift:521`). The guard is `guard enrolled || entersCastle` (`:535`), so a SIGNED-OUT device that still holds sync custody — design §5: sign-out keeps the keys — takes the `else` road (`:691–699`):
   - It runs only "steps 4–7": L′ under P (+W) only, the library re-keyed, custody behind the gate, the insurance off, and the pre-switch backups OFFERED for deletion.
   - The vault is **untouched**. It still carries `master_wrapped_by_apple_held`, and the server corpus is still under C, under M, under A.
4. The Done is the ordinary `enteredCastleDone` (`PostureCopy.swift:438–441`): *"You're in Castle. Your library has a new key that your Apple account never held … your other devices will ask the next time they open."*

**What she would believe vs what is true:**
- She believes the account is in Castle. In fact the account is still Standard:
  - an Apple-account holder plus the account password can enroll a new device silently;
  - that device unwraps M and reads every synced row;
  - her other devices never follow (the vault never changed).
- At her next signed-in ready, `reconcileFollow`'s follow-into-Standard arm (`ProtectionController.swift:707–717`) silently re-adds L′ under A and moves custody back to silent. The notice says "back in Standard", but any backups she deleted at the offer were deleted for a Castle that never happened.

The record's pin shape (red on HEAD, `vx-99-ladder-round3.md:105–129`) is: `makeWorld()` → `signedIn = { false }` → `enterCastle` → expect a refusal.

**The promise it breaks:** the Castle Done sentence above, and the posture law "entering Castle … must leave nothing current openable by A".

**Path realism:** she signs out (a normal door), or the session lapses, then presses Use Castle. Unusual but entirely plausible, and the face gives no hint.

**Fix shape** (the record's): refuse the switch for an enrolled-SHAPED library — sync custody held, or a key file recording a vault corpus id — when it is not enrolled NOW, with the switches' offline sentence. A genuinely pre-sync library keeps the local-only road. Mac + phone share this code (`Shared/`).

### VX-109 — `CorpusRotation.begin` re-fetches the vault, so a concurrent write is overwritten — **MINOR. Not launch-blocking; one sub-case is worth knowing.**

The trace (`Sources/VariorumCore/Sync/CorpusRotation.swift:449–483`): `begin` fetches again and CASes against ITS OWN fetch's revision, guarding only `previousCorpusKey` and the corpus id. A NON-rotating vault write landing between the ceremony's fetch (`PostureSwitch.swift:578`) and `begin`'s fetch is therefore overwritten by a format built from scratch.

**Direction check:**
- **Into Standard (the ticket's case):** B's *Use Standard* (adds the Apple copy, same id) is overwritten by A's Castle-decided rotation. The account silently stays Castle — the SAFE direction for confidentiality.
- **The reverse:** A Standard-decided rotation overwriting B's *entry into Castle* is impossible. B's entry rotates M; A's old-master proof then refuses at `key_vault_update` (the challenge-checked `sync_key_proof_check`), and `begin`'s `staleMaster`/`rotationInProgress` guards refuse earlier.
- **The sub-case to know — a passphrase change in the window:** B changes the passphrase (a re-wrap: same M, same corpus id — `begin`'s guards pass) while A's Replace All Keys or Castle entry is between its two fetches. A's write lands M′ wrapped under the passphrase A TYPED, i.e. the OLD word.
  - If she changed the word because the old one leaked (decision 22's first rule), the vault now protects M′ under the leaked word.
  - B is told: the vault's descriptor moved, so B gets the follow plus the changed-elsewhere notice naming A's device. Her new word is then refused — so this is not silent, but it is confusing, and the exposure is real until she changes the word again.
  - It needs two of her own devices acting inside about one second (the Argon2id derive + `prepare` + the marker write).

**Severity MINOR. Fix shape** (the record's): `begin` takes the caller's `expectedRevision`. This is `Sync/` work — Fable's.

### VX-108 — the Use Castle / Leave Castle doors read the local posture, not the vault — **MINOR / NIT. No exposure.**

The pane picks the door label from `controller.posture` (`ProtectionPane.swift:329–337`); `leaveCastle` gates on `leaves.posture() == .castle` (`PostureSwitch.swift:1308`).

Both wrong-label directions were traced:
- **Lagging device shows Use Castle on a Castle account:** the enrolled ceremony fetches the vault, and the old custody fails `begin`'s `staleMaster` and the proof. The VX-99 road turns that into the follow.
- **Lagging device shows Use Standard on a Standard account:** `leaveCastle` writes the vault only under the CURRENT proof (`:1319–1326`). It re-adds an Apple copy to an account that already has one, and makes custody silent — consistent with the account.

The ceremony decides the Apple copy from the VAULT's word since VX-99 round 1 (`PostureSwitch.swift:549–558`, `appleKeyReadable` :397–410). So the doors can be mislabeled, but no road writes a posture the account does not hold.

**Note:** `leaveCastle` signed out writes only the LOCAL Apple copy (the vault arm is skipped, `:1319`). That makes the local library A-openable on a Castle account. It is her deliberate choice of Standard, the next signed-in ready owes `castleStillOpensOldWay` and says so, and it is not a false-Castle belief.

### VX-107 — a double-crashed another-device resume loses ledger 61's sentence — **MINOR (recovery-credential correctness; no exposure)**

The trace is in `vx-99-ladder-round3.md:131–153`, re-read at `PostureSwitch.swift` (`clearMarker()` then `runFollow`; the follow marker carries no stamp):
1. Two devices enter Castle at once.
2. The loser's road becomes the follow, and that follow ALSO crashes.
3. The resume speaks the plain follow Done.

She may keep twelve words that never landed, believing they are the account's. Nothing becomes A-openable. The risk is a LOCKOUT later: if she also forgets the passphrase, those words open nothing. She would still have the other device's words (shown on her own other device) and any enrolled Touch ID device.

It needs a simultaneous two-device Castle entry plus two crashes. **MINOR.** Fix shape (the record's): stamp the CAS-refused follow's marker with the never-landed id.

### VX-81 — macOS 27.0.1: the `BarAppearanceBridge` assertion crashes the re-key reopen — **no key or data exposure since VX-80. A launch-quality item, not a privacy one.**

The crash fires between the swap and the custody move (`vx-80-castle-follow-recovery-door.md` timeline). Before VX-80 this stranded the library behind a doorless failure. VX-80 (merged in 13x) added the wrong-key recovery arm: `AppBootstrap.swift:408–419` offers the typed-secrets lobby, and the marker's resume then completes custody. Pins: `VX80CastleFollowRecoveryTests` (4 tests; Mac target, read).

**Posture safety in the window:**
- On a follow INTO Castle the store is already under L′ while custody still holds the dead L — nothing current is A-openable.
- On the ACTING device's crash before the swap, the old L and its key file still open the store. The marker's *Finish entering Castle* door says the act is unfinished, so it is not a false belief.

**OPEN (reproducibility):** the Pro on 27.0 did not crash on the same road (`phase-13x-library-portability.md:2279–2291`). Whether every 27.0.1+ follow crashes is unknown. If it does, every Castle follow on that OS costs her a crash plus the recovery lobby — honest but ugly on day one.

### VX-100 — opening a copied library asks for the passphrase twice — **NIT (UX). No security bearing.**

Adoption unlocks, then sync enrollment asks again (`phase-13x-library-portability.md:2338`). Carrying the typed word one hop is a convenience. A second ask is the safer failure mode.

### VX-113 — the changed-elsewhere refusal should name the change — **NIT (copy). No security bearing.**

QUESTIONS #205 (ruled (ii)): typing the OLD word into the follow after a change elsewhere reads "That isn't your library's passphrase". It is misleading, but the right word works and nothing is exposed.

### VX-107 is still VX-107

Nothing in the repo re-mints it. Round 3's MINOR-3 (the CAS-race follow marker carries no stamp) was appended to it (`vx-99-pro-castle-apple-wrap.md:1028`).

---

## Q11 (mine) — Castle entered while a sibling device does not follow (the phone left closed): what stays Apple-openable, and is she told? — **MINOR (disclosure precision); one part OPEN**

**The trace:**
1. Castle entry rotates M/C on the server and re-keys ONLY the acting device's library.
2. Each other device follows when the app next opens. The follow detection runs at ready (`ProtectionController.swift:631–643`). The phone has no background sync road (no `BGTaskScheduler` anywhere in `App/`).
3. Until the phone opens Variorum, its library — everything she wrote up to the switch, the same body of text the Mac just put under Castle — sits under L_phone with a key file carrying L_phone wrapped under A, beside the store in Application Support (`Sources/VariorumCore/Persistence/AppDatabase+Dependency.swift:78–84`).
4. Nothing excludes the store or key file from device backups: a grep for `isExcludedFromBackup` / `NSURLIsExcludedFromBackupKey` over `Sources` and `App` finds nothing. So each nightly iCloud device backup of that phone keeps a Standard-shaped pair until the phone follows.
5. The design knows the iOS device-backup corner (`pre-13x-postures-design.md:675–678`: "an iOS device backup taken between first open and Castle enrollment holds the old ciphertext + its key file").

**What she is told** (`PostureCopy.swift:317–325`):
- "Your other devices will start asking too …"
- "Backups made before today — Variorum's own, Time Machine, copies you made — still open through your Apple account."

That copy has two gaps:
- (a) It never says a device that has not opened since stays Apple-openable until it does.
- (b) "Before today" understates the window: phone backups taken AFTER today, until the phone follows, also open through the Apple account — and iCloud device backups are not named.

Exploiting this needs the Apple account (to obtain A through iCloud Keychain AND the device backup) — exactly the attacker Castle exists to shut out. The content exposed is everything up to the switch.

**Severity MINOR.** The design accepts that devices follow on open; the gap is that the copy is narrower than the truth.

**Fix shape:**
- one clause in the explain bullet and the Done: "until each of your devices opens Variorum, its copy still opens through your Apple account — open them soon"; and/or
- a Protection-pane list of devices not yet followed (the vault knows `updated_by_device` only for the writer, so this may need the `device_cursor` table).

**OPEN:** that iOS iCloud Backup actually includes this app's Application Support container on her build (Apple's default is yes for Application Support; not verified on a device here). Settled by checking a device backup's contents in Settings ▸ iCloud ▸ Manage Storage ▸ Backups, or by a backup-restore drill on a test phone.

**Related, same family:** a pre-Castle pair restored while SIGNED OUT (Q8 (a)) is not detected as Apple-openable until sign-in, because `reconcileFollow` needs a vault reading (`ProtectionController.swift:607–611`). NIT — her own act, on her own Mac.

---

## VERDICT TABLE

| Item | Verdict | Severity | One line |
|---|---|---|---|
| Q1 key-proof retention | HOLDS (changed) | NIT | 13y's per-request challenge DELIVERED; reusable kp2 now transits only enroll + rotation bodies and SITS in Supabase Vault (server-readable). Mutating access only, never confidentiality |
| Q2 attacker arms + tenth | HOLDS | NIT | Arm 10 (`sync_reencrypt` under the old proof) DELIVERED; its text pin reads file 12 while 13 redefines the function |
| Q3 straggler / horizon / guard | HOLDS | MINOR (routed residual) | One served horizon + the guard folded into the canonical body DELIVERED; the poison row (Phase 12) still unowned by any ticket |
| Q4 same-second switches | HOLDS | — | Pins present; her why-sentence landed; VX-107 the residual |
| Q5 recovery-wrap digest | HOLDS | — | Unchanged |
| Q6 iCloud Keychain reset | HOLDS (corrected) | NIT | 17m DELIVERED; 09-21's "the heal never fires on a reset" is wrong with 3 devices — devices 2/3 heal the vault copy under the new same-account A′ (benign under Standard) |
| Q7 fresh library needs a typed secret | HOLDS | — | 13x adoption opens no bypass |
| Q8 pre-RAK backup restore | HOLDS | — | 13x routing DELIVERED (custody adopts the opener); pre-Castle pairs owe a named follow |
| Q9 Time Machine | HOLDS | — | Data-protection keychain + ThisDeviceOnly in force; the key file in TM is Q10's target |
| Q10 passphrase brute force | HOLDS (design) | MINOR | 64 MiB/t=3/p=1 (~1.7k guesses/s per RTX 4090); 17n's 12-character floor shipped, NO entropy check; the subline names only the server |
| VX-110 | FINDING (confirmed at HEAD) | **MAJOR** | Signed-out Use Castle says "You're in Castle" while the vault and server stay A-openable; the next sign-in reverts it |
| VX-109 | FINDING (confirmed) | MINOR | Overwrite is into Castle only; a same-second passphrase change can be rolled back to the old word |
| VX-108 | confirmed, no exposure | MINOR/NIT | Wrong door label; the vault's word decides every write |
| VX-107 | confirmed | MINOR | Double crash → wrong words believed (lockout risk, no exposure) |
| VX-81 | OPEN (reproducibility) | quality, not privacy | VX-80 door recovers; nothing A-openable in the window |
| VX-100 / VX-113 | UX | NIT | No security bearing |
| Q11 unfollowed sibling | MINOR + OPEN | MINOR | A closed phone (and its iCloud device backups) stays A-openable until it opens; the copy says "before today" |

---

## WHAT I DID NOT CHECK

- **No Mac-target tests were run** (`xcodebuild test` is out of scope for this audit). The `PostureSwitchTests` / `Phase13pControllerTests` / `VX80CastleFollowRecoveryTests` pins are verified to EXIST and were read; their pass state rests on the VX-99 / 13x closeout records.
- **The deployed Supabase mirror** was not queried. The SQL verdicts are against the repo's files (the 13 body is the latest for every gated function).
- **The RLS on `vault.secrets` / `vault.decrypted_secrets`** for non-definer roles. I trusted 12's grant block (`12…sql:1707–1708` grants vault functions to `variorum_definer` only) and did not audit Supabase's own Vault grants.
- **Website and privacy-brief copy** (outside this repo), for the Q1 NIT.
- **iOS iCloud Backup inclusion** of the app container (Q11's OPEN).
- **VX-81's reproducibility on 27.0.1+.**
- **The phone's own Protection faces** for VX-110 (`MobileProtectionSheet`): the runner is shared, so the mechanism is the same, but the phone's door conditions were not read.
- **Argon2id cost figures** come from one hashcat example session (via a read-only Sonnet subagent), not a benchmark run; the table's 1,000-GPU column is extrapolation.
