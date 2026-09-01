# pre-13x — POSTURES & RECOVERY: the two-mode simplification (design note + execution plan)

**Status: SLOTTED 2026-09-01 at her word ("commit this & update the master plan") — the NEXT phase; NOTHING BUILT; §1's rulings are hers, §16's are still open.**
**Provenance:** the author's 2026-08-31 → 09-01 encryption-clarity thread with Fable (this is the
record she asked for: *"a design note on each and every step that's necessary for us to reach a firm
place on this issue"*). Written as a SEPARATE file at her instruction so it collides with nothing the
in-flight pre-13u round is closing. When ratified it SUPERSEDES `notes/plans/pre-13u-memo-security-
shapes.md` (the nine-wave memo) and dissolves most of QUESTIONS #81; the 13p constitution's custody
rulings R13p-5/6/7/9 are superseded where §1 says so. **Cast: Fable** (the whole phase touches
`Sources/VariorumCore/Sync/` — the standing rider — and the crypto seams). **Placement:** its own
in-between phase, "pre-13x" (the naming precedent), BEFORE 13y (the last sync-touching phase before
launch) and separate from 13x (her call: 13x keeps AirDrop/portability). **Pulled in at her word:
standing-fixes entry 17i** (the sync reconciliation probes + scenario sweep + harness-realism fix —
`notes/plans/phase-17-standing-fixes.md` §17i; same cast, same seams).

Every mechanism below was verified against the code on 2026-08-31/09-01 (file references inline).
Items marked **PROVISIONAL** are Fable's recommendation awaiting her ruling; §16 lists them. **§18 is the SESSION RECORD** — every edge case, clarifying sentence and trap the 2026-08-31 → 09-01 thread produced, pulled at her instruction so nothing lives only in chat.

---

## 0. KICKOFF MESSAGE (for the fresh session that builds this)

Read, in order: `CLAUDE.md`; this file whole; `notes/plans/phase-13p-note-protection.md` §THE DESIGN
and the constitution R13p-1…R13p-16 (what you are simplifying); `notes/plans/phase-14b-suite-e2ee.md`
§THE DESIGN (the vault + enrollment you are re-homing); `notes/plans/pre-13u-memo-security-shapes.md`
(the model this replaces — read it to know what NOT to re-derive); `notes/SessionResiliencyProtocol.md`.
Then the code: `App/Variorum/Shared/{StoreProtection,StoreKeyGuard,ProtectionController,
EncryptionKeychain,EncryptionSession,StoreLaunchGate,AppBootstrap,ProtectionShapes,StoreBackup}.swift`,
`Sources/VariorumCore/Persistence/{StoreKey,StoreKeyEnvelope,StoreBinding}.swift`,
`Sources/VariorumCore/Crypto/{VaultEnrollment,AccountRekey,AccountDeletion}.swift`. Do first: §15
batch 0 (the measurements). Verify by: §15's per-batch gates + the two drills.

---

## 1. HER RULINGS FROM THIS SITTING (binding once she ratifies this file)

1. **Two postures, nothing else.** *"Either choose full lockdown with the responsibility that implies
   of KNOWING YOUR PASSPHRASE… or, if you don't care about encryption, your fate is in apple / iCloud /
   your iCloud's hands."* Names: **Standard** and **Castle** (Fortress rejected after a night; "cool
   and safe").
2. **Delete the dial matrix**: Auto-device-only, the escrow dial and its posture coupling, both
   presets, the "require Touch ID to unlock sync" gate, the loss-legs matrix, the recipes table.
   *"users are NOT going to understand this. they barely understand what syncing means."*
3. **Anyone with any device that opens the library + their account must be able to set a new
   passphrase.** *"we need this person… to be able to set a new passphrase, or people might be in a bad
   spot."* Biometrics confirm where present; the account password is the confirmation where not.
4. **Sync keys live INSIDE the encrypted library** (in both modes), after the same-machine hole
   (§3.5) — *"it would be kinda disasterous if someone just moving your store aside let them in."*
   Standard additionally mirrors them to iCloud Keychain.
5. **Turning on sync always requires a passphrase + a recovery phrase** (already so — `setUp` + the
   CF-5 mandatory phrase step); Standard sync users therefore always have both.
6. **Standard users may set a passphrase/recovery phrase too** — optional extra doors, never a dial.
7. **Sync keys and the session must be device-bound**; in Castle the sync keys sit behind the
   library's own gate by construction (§3.2).
8. **Custody items scoped per STORE ID**, never per store variant.
9. **The plaintext SQLite export is BACK** (reverses R13p-8's "never"): re-authenticated, warned,
   user-chosen destination, never scheduled. A "decrypt without Variorum" recipe is a later publish.
10. **Account deletion authorizes by the ACCOUNT PASSWORD** (never the encryption passphrase) and
    must be reachable when signed in but not enrolled.
11. **The recovery phrase is MANDATORY at Castle enrollment** — generated, written down, confirmed by
    re-entry, ONCE (never at unlock).
12. **A passphrase change refreshes the envelopes in the on-disk backup folders.**
13. **Castle keeps the idle-minutes re-lock dial** (it reads SYSTEM idle — tabbing out never locks).
14. **The absent-store route is re-ruled**: never a silent reset to Auto.
15. **17i is pulled into this phase.**

---

## 2. THE MODEL (what users are told — the whole of it)

Both modes: your library is encrypted on disk, and sync is end-to-end encrypted — **the Variorum server
can never read your writing in either mode.** The only difference is **who holds the key.**

| | **Standard** (default) | **Castle** |
|---|---|---|
| who holds the key | your Apple account — iCloud Keychain (and Apple's recovery paths: device passcode · recovery contact · recovery key) | only you: your passphrase, your twelve words, and your enrolled devices behind Touch ID / Face ID |
| opening | silently, on any device signed into your iCloud | Touch ID / Face ID (passphrase fallback), or the passphrase every time |
| a new device | sign into iCloud + sign into Variorum → everything, nothing typed | sign in + type your passphrase (or twelve words) once |
| stops | someone in your iCloud? **no.** someone at your unlocked Mac? **no.** the Variorum server? **yes** | someone with your Mac's login password? **yes.** someone in your iCloud? **yes.** the server? **yes.** someone holding your secrets? **no** |
| if your computer dies | nothing lost — iCloud (or sync + your passphrase, if set) brings it back | sync + your passphrase; or a backup + your passphrase/twelve words |
| the floor | lose every Apple device AND every Apple recovery path AND (if set) both secrets | lose every enrolled device AND both secrets — **gone; nobody can help, and that is the point** |
| optional extras | a passphrase + twelve words (one more door in) | an idle-minutes re-lock; "always ask for the passphrase instead of Touch ID" |

The keystone lines that survive from the memo, verbatim-class: *"An unlocked, enrolled device is as
powerful as your passphrase. Touch ID guards this device — your passphrase is what lets a new device
in."* (Castle) · *"Sync brings your writing back to any device"* — completed per mode: *"…through your
Apple account"* (Standard) / *"…as long as you keep your passphrase or twelve words. We can never
reset it for you: that's what end-to-end means."* (Castle).

**The three key kinds** (internal vocabulary; users meet only "your key" and "your passphrase"):
the **library key** (random 256-bit, one per store, opens the SQLCipher file), the **sync keys** (the
account's master + corpus + journal-bridge class keys, one set per account), and the **one secret**
(passphrase; twelve words = its twin) that wraps both. In Castle nothing else exists; in Standard,
iCloud Keychain holds copies of the first two.

---

## 3. THE MECHANISMS

### 3.1 Custody by mode

| item | Standard | Castle |
|---|---|---|
| library key | ONE iCloud-synchronizable Keychain item, account = store ID (today's escrow item becomes THE item; the device-bound silent item retires) | the `.biometryCurrentSet` item (`WhenUnlockedThisDeviceOnly`), or NO item under "always ask" — today's custody law (`StoreKeyGuard.swift` header) |
| sync keys | inside the library (§3.2) + an iCloud-synchronizable mirror item (the `DeviceKeyMaterial` JSON, per account) | inside the library ONLY |
| session tokens | device-bound (DP keychain, `ThisDeviceOnly`) — a migrated Mac signs in again | same |
| the envelope (`variorum-keys.json`) | passphrase wrap + recovery wrap (if set) + master wrap (if sync) + the recorded vault descriptor | same, wraps mandatory |
| mode + dials | one `posture` key per store ID in UserDefaults; Castle's two switches | same |

### 3.2 Sync keys inside the library
`sync_state` is local-only, never synced (SyncSpec §3), lives inside the SQLCipher store, and
`SyncEngine.resyncReinitialize` already spares non-bookkeeping rows (`device_id` survives) — so the
material (`masterKey`, `corpusKey`+id, `journalBridgeKey`+id) lands there as base64 rows. **Zero
schema, zero §12 lockstep** (the vault format is untouched: passphrase wrap + recovery wrap).
`DeviceKeySyncProvider`/`DeviceBridgeKeyProvider` (`EncryptionKeychain.swift:558`) become DB-backed
implementations of the same `SyncKeyProviding` seam (synchronous by contract — a cached read
refreshed on write). Consequences: one engine read path in both modes; a FRESH store has no keys and
can only ask (passphrase/twelve words, or — Standard — adopt from the iCloud mirror); the E2EE launch
cache and the CF-12 gated twin are deleted; `secure_delete` already covers row removal.
**Corner:** the plaintext SQLite export (§4) MUST strip `sync_state`, `sync_outbox`, `sync_row_seq`,
`_sync_applying`, `purge_*` local tables — the master would otherwise ride out with the words.

### 3.3 The envelope gains a MASTER WRAP + a recorded vault descriptor
`StoreKeyEnvelope` (format 2): `masterWrap: Data?` = the library key wrapped (RFC 3394) under the
sync master; `vaultKDF: PassphraseKDF.Descriptor?` = the vault's passphrase-KDF descriptor the local
passphrase wrap was last reconciled against (non-secret: salt + params). Both written at enrollment
and at every re-wrap. Format 1 envelopes read as "no master wrap, unknown descriptor". Old backups
keep format 1/old wraps and still open by their own wraps (§6).

### 3.4 The lobby (Castle) — three roads + the two rules
Roads: biometric (gated item) · passphrase · twelve words. The passphrase/words roads try the LOCAL
wrap first (offline cache), then — on failure, when signed in and online — the **VAULT ROAD**: derive
against the vault's descriptor → unwrap master → unwrap the library key from the envelope's master
wrap → open → re-wrap the local envelope under the typed secret + record the new descriptor.
**Rule 1 (retired secrets die when the vault can be reached):** if online and the vault's descriptor ≠
the envelope's recorded one, the typed passphrase is verified against the VAULT, never the cache — the
old passphrase is refused with "your passphrase was changed on another device; enter the new one."
**Rule 2 (offline grace, stated):** offline, the cached wrap opens; the device catches up at its next
connection (a post-unlock one-time prompt: "enter the new passphrase to update this device" — the
device opened via Touch ID and never typed anything). Regenerated twelve words take the same road.
The pre-unlock network contact is ONE authenticated vault read (an account read, not a store service;
the 13p "nothing runs before unlock" rule is about the store and stays true).

### 3.5 The absent-store route — RE-RULED
Today (`StoreLaunchGate.swift:198`, `AppBootstrap.swift:236`): a demanded mode over an absent store
resets the mode to Auto and mints a fresh library. With a plain sync-keys item this was a **read
hole** (fresh store + still-signed-in + custody matching the vault ⇒ auto pull of the whole corpus;
found 2026-09-01). With keys inside the library the read closes, but the route still silently drops
the lock and mints custody under the same scope. New rule: "your library file is missing — restore
it, open an existing library, or start a new one" — the lock STAYS; starting new is a deliberate act
that mints under a NEW store ID (per-store-ID custody, ruling 8, makes the old items unreachable but
never deleted).

### 3.6 Standard's open road
Auto-open from the iCloud/local item. Missing item (fresh device; iCloud Keychain lag; iCloud
Keychain off): a real **"waiting for iCloud Keychain"** state with two doors — "enter your passphrase /
twelve words instead" (if the envelope has wraps) and "open an existing library" (13x). Never a
silent mint over an existing store. The T2 three-value probe (covered/exposed/unknown) survives as
this state's verdict; the nudge keeps two tiers + the honest unknown: "iCloud Keychain is off on this
Mac — write down your twelve words."

---

## 4. THE DOORS (who · authorization · what changes · what other devices see)

| door | needs | authorization | changes | other devices |
|---|---|---|---|---|
| **Change passphrase** | an UNLOCKED enrolled library | Castle: you're unlocked — Touch ID again if you opened by Touch ID (you may have forgotten it), nothing more if you typed it. Standard: Touch ID where present, else the **account password** (the library opened silently; something must prove it's you). The twelve words also authorize (built). | re-wrap the vault master (`VaultEnrollment.rewrapPassphrase(material:)` — the held-material road, today's reset door), re-wrap the local envelope, refresh on-disk backup envelopes (§6) | keep syncing untouched (they hold the master); learn the new passphrase via §3.4 |
| **Regenerate twelve words** | same | same as change-passphrase (today: passphrase-gated, CF-2 — ALIGN) | new recovery wrap in vault + envelope + backups | same road |
| **Replace keys** (re-key) | an OPEN library (empty counts) + signed in | **account password** + the T1 recency warning (built) + the understanding checkbox | new master + class keys; server copy truncated; THIS copy re-uploaded; Standard: the iCloud mirror REWRITTEN; ✱ all rows' `owner_id` re-stamped to the current account (so it doubles as "move this library to this account" — after a deletion + re-signup, or a library born under another account); the old twelve words die; new ones generated next | every other device STOPS ("keys were replaced") until re-enrolled with the passphrase; their local writing stays; their envelopes' master wraps go stale and re-enrollment rewrites them |
| **Delete account** | signed in (enrolled or not) | **account password** + typed confirmation | server copy + vault + account gone; LOCAL COPIES UNTOUCHED (her pinned rule) | lose sync; keep local |
| **Sign out** | — | — | clears tokens; keys stay inside the library (the library is the gate). CF-11 "forget keys on this device" is folded in (PROVISIONAL) | — |
| **Plaintext `.sqlite` export** | an open library | Castle: the passphrase (never Touch ID alone). Standard: Touch ID, else account password | writes a decrypted copy WITH LOCAL SYNC TABLES STRIPPED (§3.2) to a user-chosen location; a plain warning; never scheduled, never into the backups folder | — |
| **Plaintext `.md` export** | — | unchanged (13l; opt-in weekly) | — | — |
| **Standard → Castle** | open library | set a passphrase if none; generate + confirm the twelve words (ruling 11) | ✱ **re-key the STORE** (`PRAGMA rekey` — the old library key sat in iCloud and cannot be un-copied); Replace Keys if sync is on (same reason for the sync keys); delete the iCloud items; enter the gated custody; PROVISIONAL: re-key the retained on-disk backups too (14 dailies + 4 weeklies) or record that pre-Castle backups open with the passphrase you had then | re-enroll (keys replaced) |
| **Castle → Standard** | open library | one consent sentence ("your Apple account will hold the key") | library key → the iCloud item; sync keys mirrored; gate removed | none |
| **Lock Now / re-lock** | Castle | — | tears down services, drops key material (`StoreBinding.lock`) | — |

**What the account password can and cannot do, in Castle:** sign in · delete the account · cancel ·
replace keys (only with an open library, and it reads nothing). It can NEVER open a library, change a
passphrase, or export. Its worst case is server-side disruption — a truncated server copy — which
every local copy survives. In Standard it additionally confirms change-passphrase, replace-keys and
the plaintext export, because Standard has no other "it's you." Its weight rises accordingly: enforce
a real minimum at signup; the honest chain is *email compromise → password reset → PLUS an open copy
of the library → sync hijack*; content never leaves the email alone.

---

## 5. PASSPHRASE CHANGE vs. RE-KEY (the one table users need)

| | change your passphrase | replace your keys |
|---|---|---|
| what it is | a new word for the same lock (re-wrap) | a new lock (new keys) |
| your library key | unchanged | unchanged |
| your sync keys | unchanged | NEW |
| the server's copy | untouched | replaced by this device's copy |
| other devices | keep syncing; need the new passphrase next time they ask for one | stop until re-enrolled with the passphrase |
| twelve words | unchanged | die; write down new ones |
| old backups | open with the passphrase/words you had when they were made — or the current passphrase online (§6) | open exactly as before (the library key didn't change); their stale sync keys land the restored library in "keys were replaced — re-enroll" |
| iCloud (Standard) | nothing changes (iCloud holds KEYS, never passphrases) | the sync-keys mirror is rewritten |

---

## 6. BACKUPS UNDER THE MODEL
The 13l backups are ciphertext + the envelope, launch-if-due + daily, 14 dailies + 4 weeklies
(`StoreBackup.swift`), made through GRDB `backup(to:)` from an OPEN keyed connection — so under Castle
they run **at the first unlock of the day if due** ("launch" = after the lobby). PROVISIONAL extra: a
keyless byte-copy at lock time when due (the closed, checkpointed store copies consistently; the keyed
integrity check defers to the next unlock).
**The one user sentence, true in every case:** *"A backup opens with the passphrase or twelve words you
had when it was made — and, in Standard, through your iCloud."* Refinements the app makes true:
change-passphrase/regenerate refresh every on-disk backup folder's envelope (ruling 12) so the CURRENT
secrets open them; the master wrap lets the current passphrase open any backup of an un-re-keyed
account online; after Standard → Castle, pre-switch backups are under the OLD library key (§4).
The runbook (`notes/DataSafetyRunbook.md`) is rewritten for two postures; same-Mac erase-and-restore:
Castle reopens by passphrase, Standard by iCloud — device-bound items are proven in the drill, never
assumed.

---

## 7. CROSS-DEVICE PASSPHRASE CHANGE — the choreography (Mac + phone, both Castle)
1. Mac (unlocked, enrolled): Change passphrase → vault master re-wrapped (CAS-guarded), Mac envelope
   re-wrapped + descriptor recorded, Mac backups refreshed. Phone untouched; keeps syncing.
2. Phone, next open by Face ID: post-unlock reconcile reads the vault descriptor ≠ recorded → one-time
   prompt "your passphrase changed on another device — enter the new one to update this phone" →
   on success re-wrap + record. Until then Face ID keeps working; the passphrase road on the phone
   goes through the vault road (needs a connection).
3. Phone, next open by passphrase, ONLINE: local wrap + descriptor mismatch ⇒ verify against the
   vault; OLD refused with the sentence; NEW opens via the vault road and re-wraps.
4. Phone OFFLINE: the old passphrase opens (cache); step 2 fires at the next connection. Stated in copy.
5. Both devices change at once: the vault's CAS refuses the second; it re-reads and retries.
6. Replace Keys instead of change: the phone lands in "keys were replaced"; re-enrollment (passphrase)
   rewrites its keys AND its master wrap.
The same steps serve Standard (harmless) and a regenerated recovery phrase.

---

## 8. COMMUNICATION CHANGES (every surface)
- **Protection pane** → the two-mode chooser (Standard default; Castle behind the ceremony) + Castle's
  two switches + Lock Now. Presets/escrow/loss legs/sync-gate sections deleted.
- **`ProtectionShapes`** (one law · recipes · need states · shapes table · indicator · two ceremonies)
  → §2's table rendered, two what-ifs per mode ("what if I forget my passphrase" / "what if my
  computer explodes"), the two keystone lines. "Render, don't re-derive" still binds: §2 IS the copy.
- **Tutorial "keeping it private"** → two lessons rewritten to §2 + the change-vs-replace table; re-seed
  (the seeder's replace door); the walk asserts the lesson names both modes and both floors.
- **Backups tab** (`DataSafetyCopy`) → §6's sentence, per posture; "backups run while your library is
  open" under Castle.
- **Encryption tab** → setup/enroll/change/regenerate/replace/delete under §4's authorizations; the
  biometric-sync toggle and forget door gone; the not-enrolled state shows delete/cancel.
- **The nudge** → two tiers + unknown (§3.6). **The unchosen indicator** → "Standard" (nothing is
  "unchosen"; Castle is chosen at the lock moment).
- **The sync signup ceremony** → passphrase + twelve words, one sentence per mode on what iCloud does.
- **The tier sentence** (13t / the sync row) → posture-conditional (§2).
- **Runbook** rewritten; **KnownIssues** rows resolved (the E2EE custody residual; the clone row);
  **QUESTIONS #81** items dissolved as listed at closeout; **the memo** superseded.
- **Outbound briefs re-issued**: the stargazing privacy-policy brief (two postures; the plaintext
  export; the disclosure envelope unchanged) and the Fragments contract carry item (§10).
- **Marketing discipline** (the memo's own item 4): Castle is the headline; Standard's sentence — "your
  Apple account holds the key; the Variorum server can't read it" — must survive the landing page.

## 9. MOBILE
All faces are shared code; the phone changes with the Mac inside this phase (MobileSoul §6 "design
together"). Phone specifics: Castle = Face ID with passphrase fallback (every iPhone has biometrics;
"always ask" remains the one switch); Standard = iCloud Keychain (always present when signed in);
quick capture demands unlock under Castle (her 13p ratification, unchanged); the phone is a
first-class birthplace of libraries (PL-15) and of Castle. Parity ledger line at closeout.

## 10. FRAGMENTS
Mechanism unchanged: Fragments enrolls by the SAME passphrase against the SAME vault and holds only the
journal-bridge key; Standard users always have a passphrase (ruling 5), so Fragments-only enrollment's
carry item stands as written. Replace Keys still requires Fragments' re-enrollment (contract point 9).
One line joins the Castle ceremony: *"your journal in Fragments is guarded by Fragments' own lock."*
The re-issued carry item states: two postures; the passphrase is the only thing Fragments ever needs;
the iCloud mirror is Variorum-local and never a Fragments road.

## 11. MIGRATION (existing stores — pre-launch: hers and the phone)
- Biometric/Passphrase mode + escrow off → **Castle**: at first unlock, move the E2EE Keychain
  material into `sync_state`, delete the E2EE items (plain + CF-12 gated), re-bind the tokens, retire
  the dial keys, write the envelope's master wrap + descriptor.
- Auto (+ escrow on/off) → **Standard**: device item → the synchronizable item; sync keys → library +
  mirror; the escrow-dial key retired. Her consent line at first launch for the sync-mirror step.
- `sync_state` keys and the custody scope migrate to store-ID naming.

## 12. TESTS & PINS
Red-on-old for every mechanism: keys-in-library (a fresh store cannot sync without a secret; the
absent-store route never opens a pullable library); the retired-passphrase rule (online refuses old,
opens new via the vault road; offline opens old); the master wrap (current passphrase opens an old
backup online); Replace Keys rewrites the mirror + re-stamps owners; the plaintext export strips the
local tables; Standard→Castle re-keys the store (the old key no longer opens the file); per-store-ID
custody; deletion reachable when not enrolled; the memo's verbatim pins REPLACED by §2's. The
convergence suites gain §7's choreography against the fake server. Both drills re-run: the 13p
migration drill on a byte-copy of her real store, and the 13l restore drill per posture.

## 13. WHAT GETS DELETED
`StoreAtOpenMode.auto`-only paths as a mode (Standard subsumes), `ProtectionDials.escrowOn` +
`effectiveEscrowOn` + the coupling copy, `ProtectionPreset`, `ReminderCheckPolicy` as a dial (Castle:
always on), the CF-12 sync gate + `E2EELaunchKeyCache`, `E2EEKeychainStorage` (custody moves into the
library), the CF-11 forget door (PROVISIONAL), the R13p-9 reset door as a SEPARATE door (merged into
change-passphrase), `lossLegs`/`lossMath`, the recipes/need-states/shapes tables, the escrow
verify-landed probe (replaced by the iCloud-item presence probe), `openResettingModeToAuto`.

## 14. EDGE CASES & CORNERS (each is a step, not a deferral)
1. Plaintext export strips local sync tables (§3.2). 2. Deletion/cancel reachable when not enrolled.
3. Custody per store ID. 4. Standard→Castle re-keys the store AND the sync keys AND (PROVISIONAL) the
retained backups. 5. Replace Keys rewrites the Standard mirror and re-stamps `owner_id`. 6. Regenerate
words aligned with change-passphrase. 7. Old backups after a store re-key open by their own wraps.
8. Backups run at unlock-if-due under Castle; freshness copy never cries wolf. 9. Same-Mac erase-and-
restore proven in the drill. 10. iCloud Keychain lag/off: the waiting state + the honest unknown.
11. Offline grace after a passphrase change, stated. 12. Apple's account-recovery paths named in
Standard's sentence. 13. The account password's new weight + signup minimum. 14. Castle is per-app
(Fragments line). 15. Sparkle relaunch → lobby (verify). 16. Quick capture/hotkey under Castle demands
unlock (unchanged, re-verified). 17. The pre-unlock vault read is the ONE network contact before
unlock; a locked device never syncs. 18. Two devices changing at once → CAS refuse + retry. 19. A
Castle "always ask" no-Touch-ID Mac + forgotten passphrase + no words = the floor; the ceremony says
so. 20. A Standard user with iCloud Keychain OFF and no secrets is the ONLY unrecoverable Standard state
— the nudge's whole job. 21. Time Machine/Migration Assistant of a Castle Mac carries nothing usable
(keys inside the library; tokens bound); of a Standard Mac carries what iCloud carries anyway.
22. "Pause sync" as a security dial: NOT offered (PROVISIONAL — deletion damage is already bounded by
the 30-day Trash on every device + local backups, and Castle enrollment needs the passphrase); a plain
convenience "Pause sync" switch is cheap if wanted, with no posture semantics.

## 15. BATCHES (strictly sequential; each red-on-old; the tutorial spine green every batch)
0. **Measure + spike**: `PRAGMA rekey` cost on her store size + 18 backups; iCloud Keychain item
   propagation latency on two devices; the pre-unlock vault read's latency; confirm ThisDeviceOnly
   behavior on a same-Mac restore. Decision memo → her.
1. **Substrate**: keys into `sync_state` + the DB-backed providers (Sync/); envelope format 2 (master
   wrap + descriptor); per-store-ID custody; device-bound tokens; the absent-store re-rule.
2. **Postures**: the `posture` model + migration; Standard's synchronizable items + waiting state;
   Castle's gated custody; the switch ceremonies (store re-key, Replace Keys, item removal).
3. **Doors**: change-passphrase (merged reset; §4 authorizations), regenerate, Replace Keys
   (account password + mirror rewrite + owner re-stamp), deletion by account password, the plaintext
   export, backup-envelope refresh.
4. **Lobby + cross-device**: the vault road, the retired-passphrase rule, offline grace, the post-
   unlock prompt; the phone's faces; convergence pins for §7.
5. **Copy + tutorial + runbook + briefs** (§8); the deletions (§13); the parity line.
6. **17i** (the sync reconciliation hunt) — runs last on the settled key path, with the harness
   change as its structural deliverable.
Then the cold-review ladder; the two drills; her acceptance walk on both devices.

## 16. OPEN RULINGS FOR HER
(a) CF-11 forget door folded into sign-out? (b) re-key retained backups at Standard→Castle, or
record the pre-switch rule? (c) a keyless byte-copy backup at lock time? (d) "Pause sync" as a plain
convenience switch — offer or not? (e) Castle's idle default (off; N minutes)? (f) the signup
password minimum. (g) the exact Standard consent sentence and the Castle ceremony's floor sentence.

## 17. CANON DELTAS AT CLOSEOUT
AppSpec §14 (this phase's delta) + §7's `setting`/`sync_state` note (keys live in `sync_state`);
SyncSpec §3 (the key provider reads the store; the vault read before unlock); CoreDescription
untouched (substrate); the 13p constitution's R13p-5/6/7/9 recorded as superseded; the memo
superseded; KnownIssues rows resolved; 13x's row trimmed to portability; the running order gains this
phase before 13y; MobileSoul parity line; QUESTIONS #81 dissolved/re-listed.

---

## 18. THE SESSION RECORD — edge cases, clarifications and traps (pulled from the whole thread, 2026-08-31 → 09-01)

Read this section as the reason every line above exists. **A** is what bit; **B** is the sentences
that fixed the model; **C** is the corners pinned along the way; **D** is her framing, verbatim-
faithful; **E** is the precedent table; **F** is the verified facts; **G** reconciles the round's
open questions with this design.

### A. TRAPS FOUND (each one closed by a step above — the step is named)
- **A1 — The same-machine Castle bypass.** A demanded mode over an ABSENT store took
  `openResettingModeToAuto` (`StoreLaunchGate.swift:198`); with the sync keys in a PLAIN Keychain
  item and the session still signed in, moving `Variorum.sqlite` aside and relaunching produced a
  fresh Auto library that `custodyMatchesVault` read as enrolled and pulled the WHOLE corpus in the
  clear — the login-password holder, R13p-5's named adversary, defeated the asking modes through the
  server. Found 2026-09-01. → §3.2 (keys inside the library), §3.5 (the re-rule), §3.1 (bound tokens).
- **A2 — The clone door.** The 14b E2EE custody item and the auth-session item were deliberately
  file-based (`login.keychain-db`; #82 ruled "bind the store key only"), so Migration Assistant /
  Time Machine + the login password carried the sync keys and the signed-in session to other
  hardware — a clone was an enrolled device for sync even though it could not open the library
  file. Tokens alone let a custom client call the truncate RPC (the key-id fence is a staleness
  check, readable from one's own vault row). → §3.1/§3.2. Her verdict: *"an idiotic door to leave open."*
- **A3 — Copy ahead of code on Replace Encryption Keys.** The memo's re-entry rule and the shipped
  `resetRoad` line promised *possession + account → a NEW passphrase*; `AccountRekey.run`
  (`AccountRekey.swift:106-115`) required the CURRENT passphrase and re-wrapped the new vault under
  the SAME one. The final ladder's focus #1 checked the T1 recency guard only, never the
  authorization. The "render, don't re-derive" discipline caught paraphrase drift but not a
  claim about a door that did not exist. → §4 (account-password authorization).
- **A4 — The iCloud spare had no OPEN road.** `loadEscrow` was called only to verify the item landed
  (`ProtectionController.swift:760,777`); the recipes and the escrow dial's copy promised "signing
  into iCloud on a new device can still unlock your library," the door was 13x's, unbuilt. → §3.6.
- **A5 — The reset door needed biometrics** (R13p-9's letter), which every iPhone has and many Macs
  do not (mini, Studio, non-Touch-ID keyboards): an enrolled no-Touch-ID Mac that forgot both secrets
  kept working and syncing but could never add a device, rotate, delete the account, or re-upload —
  previously-synced rows are not in the outbox, the mirror's RLS (`with check (owner_id =
  auth.uid())`) refuses rows stamped with another owner, and `resyncReinitialize` was reachable
  only through Replace Keys or the headless CLI. → §4 (change-passphrase never needs the account
  password in Castle — an unlocked device already proved a secret or Touch ID; the account password
  confirms in Standard), §4 (Replace Keys re-stamps `owner_id`), §4 (deletion by account password).
- **A6 — Cross-device passphrase staleness.** The one-secret hooks re-wrapped the envelope on the
  device that made the change; every OTHER device's `variorum-keys.json` stayed wrapped under the
  retired passphrase with no staleness detection, so a Castle lobby there accepted the OLD
  passphrase and rejected the NEW. → §3.3/§3.4/§7.
- **A7 — Standard → Castle could not un-copy the library key.** The iCloud item's key, once copied,
  still opened the file after the switch. → §4 (`PRAGMA rekey` at the switch; retained backups per
  ruling (b)).
- **A8 — Custody scoped per store VARIANT, not store ID**, so a fresh store minted over an absent
  one wrote into the old store's custody slot. → ruling 8.
- **A9 — The plaintext SQLite export would carry the account's sync master** once the keys live in
  `sync_state`. → §3.2's strip rule (found while writing §4).
- **A10 — The deletion door needed the encryption passphrase**, so a user who lost it could never
  delete the account — the one shape Apple's 5.1.1(v) guidance would reject (re-authentication is
  explicitly fine). → §4.

### B. THE CLARIFYING SENTENCES (the model, one line each — these ARE the copy's bones)
- **One secret, two keys.** The library key and the sync master are never the same key in any mode;
  the passphrase (and its twin, the twelve words) is a WRAPPER over both. Her original "could be the
  same key if you use the passphrase for both" was the wrong frame; this is the right one.
- **The passphrase is stored nowhere.** What an enrolled device saves is the RESULT of using it once:
  the unwrapped master + class keys. Enrollment = passphrase OR twelve words (both are full roads).
- **iCloud holds KEYS, never passphrases.** So a passphrase change touches nothing in iCloud; only
  Replace Keys does (the mirror is rewritten). And the library key never changes on a passphrase
  change — a change is a re-wrap — so any backup of that library opens via iCloud in Standard
  regardless of passphrase history.
- **The envelope is a locked box holding the key, not the key.** `variorum-keys.json` is non-secret
  ciphertext (the library key wrapped under the passphrase / the words / the master) + salts + a
  store ID; "wraps absent until a secret is set" means a never-set-up Auto user's envelope holds
  nothing but the store ID.
- **Escrow = the iCloud spare key** (R13p-6's word; the UI never says escrow). It was synchronizable,
  no access control, readable by anyone in that iCloud — a key with nothing to open unless a copy of
  the store is also in their hands (the compound warning).
- **The passphrase is used at exactly three moments:** enrolling a new device; opening a Castle library
  (typed, or as the Touch ID fallback); authorizing changes. After a change the old one is good for
  nothing, anywhere — the other devices keep syncing because they hold the master, not because of
  iCloud.
- **Two roads, one key** (Castle): Touch ID reads the gated Keychain item; the passphrase unwraps the
  envelope. Neither touches the other's home. The login password releases neither.
- **Re-wrap changes the door; Replace Keys changes the lock.** A stolen PASSPHRASE is evicted by a
  change; a stolen ENROLLED DEVICE is evicted only by Replace Keys.
- **Replace Keys never recovers the old sync — it starts a new one from THIS copy:** new keys, the
  server's copy replaced, every other device stops until re-enrolled; anything only on the server is
  lost (the T1 count-and-dates warning names it).
- **An unlocked, enrolled device is as powerful as your passphrase; Touch ID guards THIS device — the
  passphrase is what lets a new device in.** (The memo's keystone, still true, now with a working
  reset road behind it.)
- **A copy of the database and nothing else is ciphertext**, like a FileVault disk without its
  password. In Standard that state needs iCloud Keychain off AND no secrets — the nudge's whole job.
- **Both modes are local encryption + E2EE sync; the ONLY difference is who holds the key.** Standard
  = your Apple account and its recovery paths; Castle = only you. "Apple can read" is WRONG (iCloud
  Keychain is itself end-to-end encrypted); "anyone fully in your Apple account, or Apple's
  account-recovery chain" is right. The Variorum server reads nothing in either mode — keep the claim.
- **Castle's honest floor:** an "always ask" no-Touch-ID Mac + forgotten passphrase + no words = gone.
  Said in the ceremony as the sign that the protection is real (her framing, §D).
- **An enrolled device is a pre-assembled recipe; a copy is ingredients** (memo) — and a CLONE of an
  enrolled device was a recipe too (A2); after this phase a clone carries nothing usable.
- **Backups:** *"a backup opens with the passphrase or twelve words you had when it was made — and,
  in Standard, through your iCloud"* — true under passphrase change, sync re-key and store re-key
  alike; the app keeps its own on-disk backups current so the CURRENT secrets also open them.
- **Tabbing out never locks:** Castle's idle re-lock reads SYSTEM idle
  (`CGEventSource.secondsSinceLastEventType(.combinedSessionState)`) — kept as Castle's one optional dial.
- **Backups under Castle run at the first unlock of the day if due** — GRDB's `backup(to:)` needs an
  open keyed connection, so locked means no key, not merely the "nothing runs before unlock" rule.
- **The recovery phrase is mandatory at Castle ENROLLMENT, once** — generated, written down, confirmed
  by re-entry — never at unlock.
- **The account password can never open a library or read content**, in any mode; its worst case is
  server-side disruption (a truncated server copy), which every local copy survives.

### C. EDGE CASES PINNED IN CONVERSATION (beyond §14)
- The fingerprint attack (move the store out → fresh store → add a finger → move the store back):
  NO read — keys are per store, their gated item holds THEIR key; your envelope is set aside never
  deleted; adding a finger invalidates your `.biometryCurrentSet` item BY DESIGN, so you reopen with
  the passphrase. Worst case: an availability prank, closed by §3.5 + ruling 8.
- A new device typing the NEW passphrase after a change syncs fully (the vault's wrap is the new one);
  the twelve words are untouched by a passphrase change and die only at Replace Keys.
- A Standard→Castle switch while sync is ON = store re-key + Replace Keys + iCloud item removal —
  the ceremony names the cost (other devices re-enroll) so nobody is surprised a year in.
- Old backups after a store re-key open by their OWN wraps (the passphrase at the time); the iCloud
  item for the old store ID is deleted at the switch — but by then you are in Castle and iCloud was
  never a Castle road.
- A restored OLD backup carries stale sync keys in `sync_state` → the restored library lands in
  "keys were replaced — re-enroll" (CF-16's existing state), never a silent failure.
- Two devices changing the passphrase at once → the vault's CAS refuses the second (built; R1-2).
- A Castle device offline for a month after a change elsewhere: the old passphrase opens it until it
  connects; then the one-time prompt. Stated in copy (§3.4 rule 2) — never a silent refusal offline.
- Standard, iCloud Keychain OFF, no secrets: the only unrecoverable Standard state; the nudge and the
  waiting-state door exist for it.
- Same-Mac erase-and-restore: device-bound items are characterized (not verified) as restorable to
  the SAME device; the drill proves it; Castle's answer is the passphrase, Standard's is iCloud.
- The quick-capture hotkey/widget under Castle demands unlock (her 13p ratification) — unchanged;
  a Sparkle relaunch lands in the lobby (verify in the drill).
- "Pause sync" as a security dial: deletion damage is already bounded — tombstones, the 30-day Trash on
  every device, purge only past the horizon, local backups; Castle enrollment needs the passphrase.
  Not offered as posture (§16(d) for the convenience switch).
- Fragments holds the journal-bridge key per device and enrolls by the SAME passphrase; a passphrase
  change does not touch it; Replace Keys forces its re-enrollment (contract point 9); Castle's promise
  is per-app (Fragments' own lock guards the journal there).

### D. HER FRAMING (verbatim-faithful — the copy should sound like this)
- *"it's up to you to protect your iCloud. My app will let you be fully protected even if your phone /
  mac is unlocked, which is more protection than almost anyone who isn't a password manager offers
  and definitely more protection than any other word editing program offers, and if you don't care
  about encryption, your fate is in apple / iCloud / your iCloud's hands."*
- *"Either choose full lockdown with the responsibility that implies of KNOWING YOUR PASSPHRASE… it'll
  make the people who care about encryption feel good to see the warning NOBODY AND NOTHING CAN HELP
  YOU IF YOU FORGET YOUR PASSPHRASE AND HAVE NO ENROLLED DEVICE. the warning is THEIR sign that
  they're safe."*
- *"The average user is NOT going to understand that they have an on device key + the one time they
  put in a passphrase two years ago is why sync works + they have an iCloud escrow key but it only
  works with a backup of variorum, and so if they lose this device… they actually have NOTHING, even
  if they're paying for variorum sync."* — the sentence that ended Shape 2.
- *"they all have a SINGLE encryption setting + posture. They may have different recovery mechanisms…
  but they just don't have all this key, sync, device key, escrow key, time machine loophole, etc."*
- *"sometimes you have to go through the whole building of the complexity to realize it is NOT the
  right shape."*
- *"we need this person: {anyone with any device that opens the library + their account} to be able
  to set a new passphrase, or people might be in a bad spot."*
- *"if someone can't read your work, why should they be able to delete it?"* → answered: deletion is
  an ACCOUNT act (1Password's own email-verification road), never a key act; the deleter in Castle has
  already passed the lobby; local copies are untouched.
- *"it kind of softens the 'you own your files in a good format' way, if I only let you keep them in
  an encrypted format"* → the plaintext SQLite export returns (ruling 9).
- *"I want it to feel cool and safe"* → Castle.
- *"I'm a bit concerned by the power of the account password, but I guess it wouldn't impact anything
  local."* → correct; §4's closing paragraph is the record.

### E. PRECEDENT (verified 2026-08-31, official docs)
Standard Notes — no reset; export + new account. Bitwarden — biometrics alone cannot change the
master password; Emergency Access contact can. 1Password — no change from device access alone; a
recovery code or a family organizer can issue new secrets; deletion/cancel via an EMAIL-verification
path without the Secret Key; the Secret Key is our passphrase's twin. Obsidian Sync — recreate the
remote vault from local data under a new password (= Replace Keys). Proton — a trusted signed-in
device resets the password with no old secret and no data loss (= our change-passphrase from an
enrolled device). Apple ADP — a trusted device's passcode is itself an official recovery path.
Conclusion: "an enrolled device can set a new secret" is mainstream; hard-biometric gating of it has
no precedent.

### F. FACTS VERIFIED BY LOOKUP (2026-09-01)
Apple: without the device passcode, a recovery contact or a recovery key, end-to-end encrypted data —
iCloud Keychain included — stays permanently inaccessible after an account reset (support.apple.com/
102651) → Standard's sentence names "your Apple account AND its recovery paths." Turning iCloud
Keychain off keeps items locally on the device (support.apple.com/109016) → the on-device key comes
free. Apple's account-deletion guidance permits re-authentication before deletion; link-out only to
FINISH deletion. `ThisDeviceOnly` same-device restore: characterized, not quoted — the drill proves it.

### G. RECONCILING THE ROUND'S OPEN QUESTIONS (QUESTIONS #86)
- **#86(c)** (the near-empty re-key demands a TYPED confirmation phrase — her 2026-09-01 ruling,
  slotted as a 13u2 item): Replace Keys is REBUILT here (§4); the typed confirmation lands with it in
  THIS phase and the 13u2 item is retired at kickoff, or stays if 13u2 runs first — one home, never two.
- **#86(d)** (the Fragments-only enrollment road, her lean: road (a) "AFTER her encryption-options
  simplification"): THIS phase IS that simplification; the spec brief stands unchanged (the vault
  format is untouched); the interop fixture is the acceptance bar when Fragments builds it.
- **#86(h)** / **17i**: pulled in as this phase's last batch (§15.6), on the settled key path.
