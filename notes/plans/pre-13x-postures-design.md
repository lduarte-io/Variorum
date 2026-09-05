# pre-13x — POSTURES & RECOVERY: Standard and Castle (the design + the execution plan)

**Status: SETTLED. Build from this file.** Every decision below is the author's, final as of 2026-09-04; nothing in
it is provisional. The reasoning behind each shape, the shapes that were tried and left, and the session records
live in `notes/plans/pre-13x-design-history.md` — read that ONLY when you need a *why*; it never overrides this
file. **Cast: Fable** (the phase touches `Sources/VariorumCore/Sync/` and the crypto seams — the standing rider).
**Placement:** its own phase before 13y; separate from 13x (portability). 17i is not in this phase. All user-facing
text is `notes/plans/pre-13x-copy.md` — render, don't re-derive.

---

## 0. KICKOFF (for every session that builds a batch)

Read, in order: `CLAUDE.md`; `.claude/skills/architect-phase/SKILL.md` (the 13b constitution P-1…P-9 binds this
phase byte-verbatim; not re-copied here); `notes/SessionResiliencyProtocol.md`; **this file whole**;
`notes/plans/pre-13x-copy.md`; `notes/plans/pre-13x-spike-memo.md` (batch 0's measured facts). For what you are
replacing: `notes/plans/phase-13p-note-protection.md` §THE DESIGN + R13p-1…16 and `notes/plans/phase-14b-suite-e2ee.md`
§THE DESIGN. Then the code: `App/Variorum/Shared/{StoreProtection,StoreKeyGuard,ProtectionController,
EncryptionKeychain,EncryptionSession,StoreLaunchGate,AppBootstrap,ProtectionShapes,StoreBackup,AuthSession}.swift`,
`Sources/VariorumCore/Persistence/{StoreKey,StoreKeyEnvelope,StoreBinding}.swift`,
`Sources/VariorumCore/Crypto/{KeyVaultFormat,KeyVaultClient,VaultEnrollment,AccountRekey,AccountDeletion,
PassphraseKDF}.swift`, `Sources/VariorumCore/Sync/SyncEngine.swift` (`resyncReinitialize`),
`Server/supabase/{08_phase14b_lockstep,09_phase14c_multitenant,10_phase13j_purge}.sql`.
**Do:** the batch named NEXT in §18's LIVE STATUS, per its brief in §19. **Verify by:** §15's per-batch gates, the
two drills, her acceptance walk on both devices. **Never** read the history file to decide a mechanism — if this
file is silent, stop and ask.

---

## 1. THE DECISIONS (binding; the whole list)

1. **Two postures, nothing else: Standard (the default) and Castle.** No hybrids: a device never keeps a stricter
   gate under a Standard account. The gate STYLE in Castle (Touch ID vs Always ask; the idle minutes) is per device.
2. **Both postures are end-to-end encrypted.** The library is ciphertext on disk; every synced text is encrypted
   on the device before it leaves; the server never holds a key to either. The postures differ only in WHO holds a
   key.
3. **The sync keys and the device identity live in per-store CUSTODY beside the library key — never in the library
   file.** Standard: the silent device-only item; Castle: the biometric item; Always ask: in memory for the unlocked
   session. **A copy of the file is writing, never a device:** a backup, a Time Machine snapshot, an AirDropped library
   or a restore on a new Mac opens by its key file's roads and rejoins sync only by ENROLLING (Standard: through the
   iCloud key, nothing typed; Castle: the passphrase or the words once), with a fresh device identity because the new
   machine has no custody for that store id. No raw key ever sits in
   iCloud. Standard adds exactly ONE Apple-held key (the iCloud key, in iCloud Keychain) and one wrapped copy under
   it in the vault and one in the key file; Castle has neither copy. **One Apple-held copy per account:** the vault's
   iCloud-wrapped copy is under the iCloud account of the device that turned on sync; a device on a different Apple
   ID enrolls by passphrase once and opens silently from its own device item thereafter — said in the book.
4. **The account password never touches keys.** It signs you in, deletes the account, and signs out everywhere.
5. **Turning on sync requires a passphrase AND the twelve words** (generated, written down, confirmed by re-entry,
   once); so does entering Castle. Standard sync users hold both too. **A library that already has twelve words makes
   the user TYPE them at sync setup or generate new ones — never a silent reuse.**
6. **Entering Castle rotates EVERYTHING a Standard-era copy could hold:** the master key, the corpus key (every row
   re-encrypted in place), and — device by device, as each follows — the library key. The vault's and the key files'
   iCloud copies go; the iCloud key itself stays. The follow types the passphrase or the words once. **Re-encryption is version-neutral:** a row's bytes are swapped where its version matches and its version is NOT
   bumped (`sync_reencrypt`), so no other device's offline edit is ever rejected by a rotation and followers apply
   nothing. **Any enrolled
   device can finish a rotation:** for its duration the vault also carries the PREVIOUS corpus key wrapped under the
   NEW master, so a follower or a new device can read the rows still under the old key and re-encrypt them; the
   device that pulls to head and sees none left clears that copy. **Entering Castle leaves nothing behind:** a fresh
   snapshot under the new key is made BEFORE the offer to delete the old ones, and the scheduled plaintext `.md`
   insurance is turned OFF with one notice (re-enabling it in Castle shows the Castle warning; the manual export is
   ungated).
7. **Leaving Castle rotates nothing:** the iCloud key is read (minted if absent) and one wrapped copy of the master
   and one of the library key are added under it. Consent sentence + re-auth.
8. **Posture is the ACCOUNT's** once a vault exists: every device follows. Before sync, each library's posture is its
   own key file's.
9. **Posture changes re-authenticate in either direction:** Touch ID or the passphrase. **Every key door is an ONLINE
   act for an enrolled library** — change passphrase, regenerate words, Replace All Keys, both switches — because each
   is a server write; offline they refuse with one sentence (a local-only library changes its passphrase offline —
   nothing is on the server). Two devices changing at once online: the server's CAS accepts the first, the second
   re-reads and retries on top (the last change wins), and the other device learns on its next open (Rules 1 and 3).
10. **Three acts for users, no more:** *Change Passphrase / Regenerate Twelve Words* — **a CONVENIENCE act, never a
    security act**: a re-wrap of the same keys for when YOU forgot the word or want another; other devices keep
    syncing; the new word works on them at once online (through the vault) and each stops taking the old one once the
    new one has been used there; a one-time notice names the change; the copy says so and points a suspected leak at
    the checkbox. *Replace All Keys* — the security act (the switch's key half — for a secret that may have been USED
    or a device that may be in someone's hands; four entrances: its own door, the checkbox on the two re-wrap doors,
    the checkbox on the door for a new passphrase too, and entering Castle; every device re-keys its library as it
    follows, which is what retires an old word everywhere). *Delete the account and set sync up again* (the recovery
    road and the compromised-account road). No standalone library-key door.
11. **Backups are never rewritten after they are written** — not at a posture change, a passphrase change or a
    words regeneration. Key files are named by key fingerprint and never overwritten by another key's file. The
    Castle ceremony says, once, that pre-switch backups still open through the Apple account (a limit AND a way back)
    and offers to delete the app's own; Time Machine and copies elsewhere are the user's.
12. **The key proof.** Every mutating RPC except whole-account deletion requires proof of the master key; a bare
    session can fetch the vault's wrapped copies, delete the whole account, and nothing else. ONE §12 lockstep event
    (marker 7 → 8).
13. **Custody items are scoped per STORE ID; session tokens are device-bound.** The device identity rides the
    sync-key custody item (§1.3): a machine with no custody for a store id has never opened that library, so a copy
    gets a fresh device id by construction; a wiped Keychain mints a new one — harmless.
14. **The absent-store route never resets a lock:** "your library file is missing — restore, open, or start new."
15. **The plaintext SQLite export exists:** re-authenticated, warned, user-chosen destination, never scheduled;
    the synced tables only (the local bookkeeping tables stay behind; no key is in the file). The library-wide `.md` export is not gated in Castle.
16. **Account deletion:** account password + typed phrase + a fresh re-authentication; reachable signed-in but not
    enrolled.
17. **Sync setup ADOPTS a library that synced under another OWNER** (re-stamp every row + `resyncReinitialize`); a
    library under the SAME owner whose keys were rotated FOLLOWS (an ordinary pull).
18. **Castle's controls:** Always ask (no Touch ID copy at all); Lock after time away — 10 minutes default, offered
    5 · 10 · 30 · never, the clock = time since Variorum was last used; re-lock on sleep / screen lock always on;
    Lock Library Now; a keyless byte-copy of the library at lock time when a backup is due (the app's own folder only).
19. **The open-app attacker is out of scope** and said once; any finger enrolled on the Mac account passes Touch ID,
    said where Touch ID is offered.
20. **Sign out everywhere** is a deliverable.
21. **Both floors are stated:** Castle — lose every enrolled device and both secrets and it is gone, nobody can help;
    Standard — lose every Apple device, every Apple recovery path and both secrets.
22. **The tutorial's "keeping it private" is a SHORT chapter; the full explanation is a second seeded book,
    *Encryption Explained*** — which joins the seeded-book dedupe facts so two devices never seed two of it.** Two vocabulary registers: everyday surfaces name no key; the book and the FAQ name every
    key and define "wrapped" on first use; "box" appears in no user text. Every Castle surface that offers Touch ID
    says where that copy of the key sits. The three-line compromise rule appears in both postures.
23. **Mobile changes inside this phase** (shared faces; the shared keychain access group on both targets).
24. **Backups may be kept in iCloud Drive** (the offer at the first backup run); the LIVE library never lives there
    (13x guards the one door that could put it there).
25. **The account-password minimum is 12 characters** with Supabase leaked-password protection on. The "forget keys"
    door is folded into Sign out.
26. **No delete-and-set-up-again drill runs on the author's real store in this phase** — the dev store and the fake
    server carry it.
27. **The Fragments bridge is retired** (done; `notes/plans/pre-13x-bridge-retirement.md`).
28. **Three design laws:** a SECRET or an ENROLLED DEVICE authorizes every key act — never an account credential ·
    iCloud holds a KEY TO A WRAPPED COPY — never the copy · **the posture law:** a posture change is complete only
    when no credential the old posture could reach opens anything written after the change, checked against every
    copy of every key (raw, wrapped, inside libraries, inside backups) — §3.4 is the check.
29. **Not in this phase, owned elsewhere:** pause sync / auto-sync off (18a); "Open a library file…" and the
    iCloud-Drive guard (13x); Keychain Sharing on the App IDs for distribution profiles (13r); 17i (its own entry,
    after).

---

## 2. THE MODEL (what users are told — the whole of it)

Both modes: your library is encrypted on disk, and sync is end-to-end encrypted — **the Variorum server can never
read your writing in either mode.** The only difference is **who holds a key.**

| | **Standard** (default) | **Castle** |
|---|---|---|
| who holds a key | your Apple account — iCloud Keychain, and Apple's recovery paths (device passcode · recovery contact · recovery key) | only you: your passphrase, your twelve words, and your enrolled devices behind Touch ID / Face ID |
| opening | silently, on any device signed into your iCloud | Touch ID / Face ID with the passphrase as fallback, or the passphrase every time |
| a new device | sign into iCloud + sign into Variorum → everything, nothing typed | sign in + type your passphrase (or twelve words), once |
| who it stops | the Variorum server: **yes**. someone at your unlocked Mac: **no** — anyone who can launch Variorum as you can read, and can set a new passphrase. someone fully in your iCloud: **no** | the server: **yes**. your Mac's login password: **yes** — nothing on this Mac releases the key to it. someone in your iCloud: **yes**. someone holding your secrets or an enrolled finger: **no** |
| if your computer dies | **with sync:** sign in + iCloud brings everything back. **without sync:** iCloud holds a KEY, not your writing — you need a copy of the library that survived the Mac (the backup folder in iCloud Drive, or Time Machine) | **with sync:** sign in + your passphrase. **without sync:** a surviving backup + your passphrase or twelve words |
| the floor | lose every Apple device AND every Apple recovery path AND both secrets | lose every enrolled device AND both secrets — **gone; nobody can help, and that is the point** |
| the ceremony | at sync setup: passphrase + twelve words, once, with *"keep your twelve words even in Standard — they are your way back if you ever lose your Apple account"* | at the switch or at sync setup: passphrase + twelve words, once, with the floor said as the sign the lock is real |
| optional | — | Always ask for the passphrase instead of Touch ID; lock after N minutes away |

**The keystone lines:** *"An unlocked, enrolled device is as powerful as your passphrase. Touch ID guards this
device — your passphrase is what lets a new device in."* (Castle) · *"Sync brings your writing back to any device"* —
*"…through your Apple account"* (Standard) / *"…as long as you keep your passphrase or twelve words. We can never
reset it for you: that's what end-to-end means."* (Castle) · **"Your account password signs you in and can delete
your account. It never touches your keys."** (both) · *"While Variorum is open and unlocked, everything in it is
readable — that is what open means. Locking is how you end that."* (both).

---

## 3. THE MECHANISMS

### 3.1 The pieces

| piece | what | where it lives |
|---|---|---|
| **P** the passphrase · **W** the twelve words | the two secrets; W is P's twin (128 bits of BIP-39 entropy through HKDF) | the user's head / paper — NEVER stored |
| **M** the master key | one random 256-bit key per ACCOUNT, minted at sync setup; wraps the class keys; its proof earns the right to sync | RAW in each enrolled device's per-store custody beside L (never in the library file); on the server only as wrapped copies |
| **C** the corpus key (and **J**, the dormant journal class key the vault format still carries) | encrypts every synced text before it leaves the device (AES-256-GCM, per-value nonce, AAD `table:rowID:column:keyID`) | wrapped under M in the vault; RAW in custody beside M |
| **L** the library key | one random 256-bit key per LIBRARY FILE (the Mac's ≠ the phone's); what SQLCipher decrypts the file with | RAW in exactly one place per device — the device Keychain (Standard: the bound plain item, silent after login; Castle: the `.biometryCurrentSet` item, or NONE under Always ask); in the key file only as wrapped copies |
| **A** the iCloud key | one random 256-bit key per iCloud account; minted the first time a Standard library exists on this iCloud (the ceremony-free first launch included), else read | ONE iCloud-synchronizable Keychain item (no access control — Apple does not sync ACL'd items; `AfterFirstUnlock`; the SHARED access group, §3.9; the account name carries the dev-store scope discriminator); read by the app, never by us |
| **the vault** (server, per account) | M wrapped under P (+ P's KDF descriptor) · M wrapped under W · **[Standard] M wrapped under A** (+ `apple_key_id`) · C and J wrapped under M · **[during a rotation] the PREVIOUS corpus key wrapped under the new M** · the `revision` CAS · the key-proof hash · the corpus key id (the fence) | `key_vault`, owner-only RLS; READ needs a session; every WRITE after creation needs a session + the proof |
| **the key file** (`variorum-keys-<fp>.json`, beside each library and in every backup folder) | format 2: `storeID` · L under P (+ descriptor) · L under W · L under M · **[Standard] L under A** (+ `appleKeyID`) · the vault's descriptor and corpus key id last reconciled against · `keyFingerprint` | non-secret; holding it grants nothing |
| **the key proof** | `HMAC-SHA256(M, "variorum.key-proof.v1")` | computed on demand by M holders; the server keeps `SHA-256(proof)` |
| **the session** | the account's tokens | the data-protection Keychain, `ThisDeviceOnly` — a cloned Mac signs in again |
| **the device identity** | the `device_id` this machine uses for this library's sync (`device_cursor`, the purge horizon) | in the sync-key custody item; absent ⇒ this machine never opened this library ⇒ a fresh id |
| **posture** | DERIVED, never a setting: the ACCOUNT is Standard ⇔ the vault has an iCloud copy; a LOCAL-ONLY library is Standard ⇔ its key file has one; an enrolled library's key file must agree with the vault (reconciled at every ready launch/unlock and at enrollment) | nowhere else |
| Castle's two switches + the idle dial | per device, UserDefaults per store ID | as today |
| **"the follow"** (a word this file uses throughout) | what a device does when it opens and finds the account's keys or posture changed on another device: picks up the new master and corpus key from the vault (unwrapped with the passphrase or the words), re-keys its own library if it is entering Castle, and resumes syncing — it follows the account into its new state (§7) | — |

"Wrapped under X" = encrypted under X with RFC 3394 `AES.KeyWrap` (as `KeyVaultFormat` and `StoreKeyEnvelope` already
do); a wrong key REFUSES, never yields bytes. The passphrase copy is the only brute-forceable one (Argon2id, the v1
descriptor, `PassphraseKDF`); every other copy is under a random key. **In plain words:** the key file holds THE
LIBRARY KEY wrapped separately under the passphrase, the twelve words, the master key and (Standard) the iCloud key;
the vault holds THE MASTER KEY wrapped separately under the passphrase, the twelve words and (Standard) the iCloud
key; the master key and the corpus key sit RAW only in each enrolled device's custody beside the library key —
never in the library file, so never in any copy of it. The library key is per FILE; the master key is per ACCOUNT.

### 3.2 Every credential — what unlocks it, what it unlocks, where it stays

| credential / key | what unlocks it | what it unlocks | where it stays — Standard | where it stays — Castle |
|---|---|---|---|---|
| the account password | your memory (resettable by email) | sign-in (a session); account deletion; sign out everywhere. **Never a key.** | your head; the server holds a hash | same |
| the session (tokens) | sign-in | fetching the vault's wrapped copies; with the proof, sync | this device's Keychain, device-bound; cleared by sign-out | same |
| the passphrase P | your memory | L (the key file's P copy); M (the vault's P copy); enrolling a new device | nowhere | nowhere |
| the twelve words W | the paper | exactly what P unlocks | nowhere but paper | nowhere but paper |
| the iCloud key A | being signed into your iCloud on a trusted device (iCloud Keychain; Apple's account recovery) | L (the key file's A copy); M (the vault's A copy) | ONE item in iCloud Keychain, readable only by Variorum | the item may exist (minted before, or serving another library) but **no current copy opens with it** |
| Touch ID / Face ID | a finger/face enrolled on this device's user account | the gated library-key item | not used (silent open) | the Secure Enclave gates the item; adding a fingerprint invalidates it (P recovers) |
| the library key L | silently, this device's Keychain (Standard) · the gated item (Castle) · any copy in the key file: P, W, M, A | the library file | raw: this device's Keychain, hardware-bound. Wrapped: the key file (P, W, M, **A**) | raw: the gated item, or nowhere. Wrapped: the key file (P, W, M — **no A**) |
| the master M | any vault copy (P, W, A) — or it is already in this enrolled device's custody | the class keys → everything in sync; the master copy in every key file → L; the key proof | raw: each enrolled device's custody (the silent item). Wrapped: the vault under P, W, **and A** | raw: each enrolled device's custody (the biometric item, or session memory). Wrapped: the vault under P and W only |
| the corpus key C | the master | the text on the server | in custody beside M; the vault under M | same |
| the key proof | derived from M | the right to read or write the sync copy, to update the vault, to purge | computed on demand; the server keeps only its hash | same |
| the key file | nothing — it is wrapped copies | nothing alone | beside the library; in backup folders; public | same |

**Read it as two sentences.** Standard: Apple holds A; A opens a copy in the key file and a copy in the vault; those
copies hold L and M; L opens the file, M opens sync. Castle: no copy opens with A; only P, W, an enrolled device's
Touch ID, or the master already inside an open library reach L and M.

### 3.3 The sync keys live in custody, never in the library file
The master key, the corpus key (+ id), the dormant journal class key (+ id) and the device identity live in this
device's per-store custody beside the library key — the same item family, the same shape: **Standard:** the silent
device-only item; **Castle:** the biometric item (`.biometryCurrentSet`); **Always ask:** no item — the sync keys are
held in memory for the unlocked session, obtained at unlock from the typed secret through the vault when online
(offline there is no network to sync with). `SyncKeyProviding` reads custody (or the session); a LOCKED library reads
as no keys and the engine refuses its round visibly (`SyncError.encryptionKeysUnavailable`). **The library file
carries writing and local bookkeeping only** (`sync_state`'s cursor, the outbox, `sync_row_seq`, `_sync_applying`,
`purge_*`) — never a key and never an identity.
**Consequences.** A copy of the file is writing, never a device: a backup, a Time Machine snapshot, an AirDropped
library, a restore on a new Mac all open by the key file's roads and rejoin sync only by ENROLLING (Standard: through
the iCloud key, nothing typed, on a device signed into the account; Castle: the passphrase or the words once — a word
just typed to open is reused), with a fresh device identity because the new machine has no custody for that store
id. A FRESH library has no custody and can only ask. A locked device never syncs. The same-machine bypass stays closed
by per-store custody + the absent-store route (§3.7). The existing `E2EEKeychainStorage` / `E2EECustodyStorage` /
`DeviceKeySyncProvider` are RESHAPED into this family (per store id; custody aligned with the library key's; the
device id added); the CF-12 opt-in gate, `SyncGateOptIn` and `E2EELaunchKeyCache` are deleted — custody follows
posture, never a toggle. **The plaintext SQLite export** is a keyed `sqlcipher_export` of the synced tables into a
plaintext ATTACHed file; there is no key in the file to strip, and the local bookkeeping tables stay behind. The synced
tables keep `sync_version` and `owner_id` so 13x's open door can reconcile a re-opened export (§14.13).

### 3.4 THE CREDENTIAL AUDIT — every key and credential, per posture, and the two switches

**The posture law's check: read each table's "at the switch" column top to bottom — a switch is complete only when
every row retires or provably opens nothing written after it. Every ladder reviewer walks this section.**

**Standard**

| credential | what it is | where every copy lives | what it opens | who can obtain it | at the switch to Castle | rotated by | rotation reaches / leaves |
|---|---|---|---|---|---|---|---|
| Mac login password | Apple's | your head | the Mac; the device Keychain after login; so Variorum's silent open | whoever knows it | stops opening Variorum | Apple's | — |
| library key, RAW | one random key per library FILE | this device's Keychain, device-only, no gate | the library file | anyone logged in as you, through Variorum | REPLACED (export-and-swap); the raw copy re-saved behind Touch ID or dropped | the switch; Replace All Keys — never alone | this device's file only; the phone's key untouched; old backups keep the old key |
| library key, WRAPPED | the same key under P, W, M and A; in the key file beside the library and in every backup folder; public | the library file, to whoever holds one wrapper | P/W/M holders; anyone in your iCloud (A) | the new key's file has NO A copy; old key files untouched (backups, Time Machine) | with the library key | old key files still open old snapshots |
| passphrase P | never stored; Argon2id-stretched | your head | L (key file); M (vault); a new device | you | unchanged; set at the switch if none | Change Passphrase — any open device | re-wraps the live key file's L copy and the vault's M copy; others ask next time; old backups keep the day's |
| twelve words W | a 128-bit key as words | paper | exactly what P opens | you | unchanged; generated if none | Regenerate | same |
| iCloud key A | a random key in iCloud Keychain | every device signed into your iCloud; Apple's account recovery | L (the key file's A copy); M (the vault's A copy); so everything | anyone fully in your Apple account | STAYS in iCloud; every CURRENT copy under it is removed (vault) or replaced (new key file); it still opens old Standard-era key files → old snapshots | re-minted only after an iCloud Keychain reset | — |
| master key M | one random key per ACCOUNT; the right to sync | RAW in each enrolled device's custody (the silent item) — never in a file or a backup; WRAPPED in the vault under P, W, A | C; the proof; L via the key file's M copy | any enrolled device's unlocked app; anyone in your iCloud (the vault's A copy, with a session) | REPLACED: M′ wrapped under P and W only; the old master refused by the server for push, pull, vault writes and purge | the switch; Replace All Keys; delete-and-set-up-again | the server accepts only M′; every device types P or W once; old snapshots hold a dead master |
| corpus key C | the key every synced text is encrypted under | RAW in custody beside M; wrapped under M in the vault | every row of ciphertext on the server and in the server's own backups | same as M | REPLACED and every row re-encrypted under C′; old C in old snapshots decrypts only pre-switch ciphertext | the switch; Replace All Keys; delete-and-set-up-again | all devices re-pull; the server's own backups keep old-C ciphertext of PRE-switch writing only |
| key proof | HMAC of M; the server keeps its hash | computed on demand by M holders | push, pull, the vault-update RPC, purge, truncate | M holders | replaced with M′'s (the old proof authorizes the ONE write that installs the new hash) | with M | — |
| account password | signs in; deletes | your head; the server's hash | a session; deletion; sign out everywhere | you; anyone who resets it by email (an iCloud email ⇒ anyone in your iCloud) | unchanged | change it | nothing but sign-in |
| session (tokens) | the signed-in state | this device's Keychain, device-only | fetching the vault's wrapped copies; with the proof, sync | the device | unchanged (inert without the new proof) | Sign out everywhere | every device signs in again |
| a backup | the library file (writing and bookkeeping — NO sync key, NO identity) + its key file, frozen | the app's folders (local or iCloud Drive); Time Machine; copies | everything it held, to P-of-the-day, W, or A; never sync — it must enroll | anyone in your iCloud | UNTOUCHED; the ceremony offers to delete the app's own (iCloud Drive's Recently Deleted keeps them 30 days — said); Time Machine is the user's | never rewritten | — |

**Castle**

| credential | what it is | where every copy lives | what it opens | who can obtain it | at the switch to Standard | rotated by | rotation reaches / leaves |
|---|---|---|---|---|---|---|---|
| Mac login password | Apple's | your head | the Mac; NOT Variorum | — | starts opening Variorum again | — | — |
| library key, RAW | per file | the security chip behind Touch ID (`.biometryCurrentSet`, this device only), or NOWHERE under Always ask | the library file | your fingerprint; nobody through the login password | re-saved as a silent device item; no re-key | Replace All Keys — never alone | this device only |
| library key, WRAPPED | under P, W, M only | the key file beside the library; backups made after the switch | the file | you; an enrolled device via M | an A copy is ADDED (the same key; no re-key) | with the library key | — |
| passphrase P | as above | your head | L; M; new devices | you | unchanged | Change Passphrase — Touch ID, the current P, or W (re-auth) | re-wraps; others ask; offline grace |
| twelve words W | as above | paper | same | you | unchanged | Regenerate (same re-auth) | same |
| iCloud key A | may exist (a Standard past; another library on this iCloud) | iCloud | NOTHING current; old Standard-era snapshots only | anyone in your Apple account — gets nothing current | minted if absent; M and L get copies wrapped under it (the consent sentence) | — | — |
| master key M | per account | raw in each enrolled device's custody (the biometric item, or session memory) — never in a file or a backup; wrapped in the vault under P and W | C; the proof; L | P/W holders (through the vault); an enrolled device | an A copy added; NO rotation (adding trust) | Replace All Keys; delete-and-set-up-again | new M; every device types P or W once |
| corpus key C | as above | raw in custody beside M; wrapped under M in the vault | server ciphertext | same as M | unchanged | Replace All Keys; delete-and-set-up-again | server re-encrypted; all re-pull |
| key proof | as above | M holders | push, pull, vault updates, purge, truncate | M holders | unchanged | with M | — |
| account password | as above | head; server hash | a session; deletion | resettable by email | unchanged | change it | nothing |
| session | as above | device-bound | the vault's wrapped copies; with the proof, sync | the device | unchanged | Sign out everywhere | all sign in again |
| Touch ID / the security chip | the gate on the raw library key | this device's hardware | the raw library key | any finger enrolled on this Mac account | the gate is removed | Always ask = no copy at all | — |
| a backup | ciphertext (no sync key inside) + the key file (P, W, M copies) | folders | everything it held, to P or W; never sync — it must enroll | you | untouched | never rewritten | — |

**The two switches, credential by credential**

| credential | Standard → Castle | Castle → Standard |
|---|---|---|
| the iCloud key (iCloud Keychain) | stays where it is, untouched; nothing current is wrapped under it any more | read from iCloud Keychain; minted and written ONLY if absent — the one thing that can ever be added to iCloud, and only if it wasn't there; nothing else ever enters iCloud Keychain |
| the library key, raw (device Keychain) | REPLACED by a new key (export-and-swap); the raw copy moves to the Touch ID item, or nowhere under Always ask | the same key; the raw copy moves from the Touch ID item to the silent device-only item |
| the library key, wrapped (the key file) | a NEW key file for the new key — copies under P, W and M′, no iCloud copy; the old key file stays beside old snapshots | the same key file gains ONE field: the library key under the iCloud key; the P, W, M copies unchanged |
| the master key | REPLACED (M′); the vault's copies rewritten under P and W only, in one CAS write the old proof authorizes; the old master refused from then on | the same master; the vault gains ONE copy, under the iCloud key, in one CAS write under the proof |
| the corpus key | REPLACED (C′ under M′); every row re-pushed re-encrypted behind the fence | unchanged |
| the key proof | replaced with M′'s | unchanged |
| the passphrase / the twelve words | unchanged (set / generated at the switch if none) | unchanged |
| the account password / the session | unchanged | unchanged |
| Touch ID | becomes the gate on the raw library key | the gate is removed |
| re-lock on sleep / screen lock | on | off |
| backups | untouched; the offer to delete the app's own pre-switch snapshots | untouched; the next snapshot's key file carries the iCloud copy |
| other devices | at their next open: the notice → type P or W once → M′/C′ → re-key their own library → pull (§7) | at their next open: the notice → add the iCloud copy to their own key file (A read from their own iCloud Keychain) → custody silent; nothing typed, nothing rotated |
| what is written, where | the vault (one write), this device's library file + key file, the server's rows (the re-push), custody | the vault (one write), this device's key file, custody — in place, nothing rotated |

**Why no key rotates ALONE.** The LIBRARY key alone protects future copies of one device's file against someone
who already copied its raw key from that device's Keychain — the open-device attacker, out of scope; its job is
inside the bundle (Standard-era key file copies must stop opening the live file). The MASTER alone kills every old
copy's right to sync but leaves the corpus readable by a breach + an old copy. The CORPUS key alone is pointless —
its new wrapped copy sits under the master, which an old copy still holds. A PASSPHRASE or WORDS change re-wraps —
a convenience act: it changes the word that opens the server's copy and this device's key file; a leaked word still
opens another enrolled device in hand until the new word is used there, and it opens old backups' writing (never their
sync — copies hold no sync keys). Replace All Keys is the security act: every device re-keys its library as it
follows, which is what retires an old word everywhere. **So:**

| act | what it rotates | other devices | when |
|---|---|---|---|
| **Change Passphrase / Regenerate Twelve Words** | nothing — a re-wrap of the same keys under the new word | keep syncing; take the new word at once online; stop taking the old one once the new one is used there | you forgot it or want another — convenience, not security |
| **Replace All Keys** (= the key half of entering Castle) | the master, the corpus key (every row re-encrypted), and — device by device as each follows — every library key | type the passphrase once, re-key their own library, pull | someone may have USED a secret, or holds a copy of a library or backup, or had a device unlocked |
| **Delete the account and set sync up again** | everything Replace All Keys does, plus the account, the server copy and the login | join the new account | the recovery road when no enrolled device is left (an old backup + iCloud + a fresh account); a compromised ACCOUNT |

**What each rotation does on the OTHER devices:** the LIBRARY key: nothing (per file) — except that entering Castle
makes every device re-key ITS OWN library when it follows, because its own key file also carried an iCloud copy.
The MASTER: every device types P or W once and syncs only after. The CORPUS key: every device re-pulls the
re-encrypted rows once it holds M′. The PASSPHRASE / WORDS: others ask for the new one next time they need one.
The SESSION: all sign in again.

### 3.5 The key file, format 2
`StoreKeyEnvelope` gains `master: Data?` (L under M), `apple: Data?` + `appleKeyID: String?` (L under A),
`vaultKDF: PassphraseKDF.Descriptor?` + `vaultCorpusKeyID: String?` (what the local P copy was last reconciled
against); `formatVersion = 2`; files are named by key fingerprint (`variorum-keys-<fp16>.json`; the legacy
`variorum-keys.json` reads as format 1 for the store's current key). Written at enrollment, at every re-wrap, at every
posture change — of the LIVE library's key file only. Format 1 files read as "no master copy, no iCloud copy,
unknown descriptor." **The master copy is what makes both local secret copies CACHES:** any device holding M can
extend its own key file with no visit (§11's backfill), and the twelve words open a Castle library ONLINE through the
vault before the local W copy has ever been landed on that device.

### 3.6 The lobby (Castle) — three roads + two rules
Roads: **Touch ID / Face ID** (the gated item) · **the passphrase** · **the twelve words**. The two secret roads try the
LOCAL copy first, then — on failure, signed in and online — **the vault road**: derive per the vault's descriptor →
unwrap M → the key file's master copy → L → open → write a fresh local copy under the typed word + record the
descriptor and the vault's corpus key id. The pre-unlock network contact is ONE authenticated vault READ (wrapped
copies only — a session without M can fetch them and nothing else). Derive ONCE when the recorded descriptor equals
the vault's; start the vault read concurrently with the derivation; progress from ~200 ms; a ~10 s ceiling hands off
to the local copies (measured: 0.77 s per derivation; 0.05–0.3 s round trip).
**Rule 1 — the new word works everywhere; the old word retires by use.** After a passphrase (or words) change on
another device, the NEW word opens this device online at once through the vault road and, on success, re-wraps this
device's local copy — from then on only the new word opens it here. Until the new word has been used here, the OLD
word still opens this device from its local copy, online or offline. A one-time notice names the change (device,
day). A passphrase or words change is a convenience act (§1.10); the security act is Replace All Keys, one tick away
on the same screen.
**Rule 2 — the owner distinction.** If the vault's corpus key id DIFFERS from the key file's recorded one, the local
copy stands as a road, and after unlock the device lands in one of two states: **same owner ⇒ the account's keys
were ROTATED (entering Castle, Replace All Keys) ⇒ the FOLLOW** (§7); **different owner ⇒ a different vault** (a
deleted-then-recreated account; a library moved between accounts) ⇒ *"this account's keys don't match this library —
re-enroll"* (the enrollment row of §5 re-stamps and `resyncReinitialize`s). **A change on another account can never
lock a device out of its own library** (pinned).
**How the new word opens a locked device:** the master is not in the file, so it cannot help; the new word derives →
the vault's M copy → the key file's L-under-M copy → L. Once open, a fresh local copy under the new word is written —
after the vault unwrap succeeded, so a typo writes nothing. The vault road is online by nature; offline, the local
copies are the roads.

### 3.7 The absent-store route
A demanded mode over an absent store: *"your library file is missing — restore it, open an existing library, or start
a new one"* — the lock STAYS (`StoreLaunchRoute.libraryMissing`; `openResettingModeToAuto` is deleted); starting new is
a deliberate act that mints under a NEW store ID (per-store-ID custody makes the old items unreachable but never
deleted). On a Castle ACCOUNT a new library cannot get M without a secret (no iCloud copy exists).

### 3.8 Standard's open road
Auto-open from this device's bound Keychain item. Missing item (a restored copy on a fresh device; a wiped Keychain):
the key file's iCloud copy via A from iCloud Keychain — and, for a sync user, A → vault → M → the master copy as a
second road. A absent (iCloud Keychain lag, iCloud Keychain off, no Apple ID): a real **"waiting for iCloud Keychain"**
state with two doors — *"enter your passphrase / twelve words instead"* and *"open an existing library"* (13x). Never a
silent mint over an existing store. The three-value probe (covered / exposed / unknown) is this state's verdict; the
nudge keeps two tiers + the honest unknown: *"iCloud Keychain is off on this Mac — write down your twelve words."*
Propagation latency is unbounded in practice, so the waiting state and its passphrase door are load-bearing.

### 3.9 The shared keychain access group
Both targets carry a SECOND group, `$(AppIdentifierPrefix)io.lduarte.Variorum.shared` (landed at batch 0 under the
team wildcard; the default group stays first so nothing already written strands), and every iCloud-synchronizable
write names it via `kSecAttrAccessGroup`. The one iCloud item this design writes is A. The Apple-key query family is
ONE builder carrying `kSecAttrSynchronizable = true` + the shared group + the data-protection marker on
add/read/update/delete/probe (a flagless delete is a silent no-op — measured). The Developer ID build must carry both
groups (13r).

### 3.10 The key proof — a session alone can neither write the vault nor touch the mirror
The server cannot verify P — that is E2EE — so without this any session for the account could PATCH the vault row and
push rows. **`kp = HMAC-SHA256(M, "variorum.key-proof.v1")`**, computed by every device that holds M, presented on
every `sync_push` / `sync_pull` / `sync_purge_execute` / `account_data_truncate` call and on every vault UPDATE, stored
server-side only as `SHA-256(kp)` in `key_vault` (written at vault creation), compared in constant time inside the
RPCs. The `active_key_id` fence stays as the stale-device honesty check; **the proof is the authorization** (the key id
is readable from the vault by any session). **`sync_reencrypt(rows, active_key_id, key_proof)`** is the rotation's
write: for each `(table, id, payload, expected_version)` it replaces the payload where `sync_version = expected`,
stamps a new `server_seq`, and does NOT bump the version — the server stays dumb (bytes it is handed, own partition,
CAS on version); a mismatch is skipped for the caller to pull and retry. The vault's PostgREST PATCH is replaced by a SECURITY DEFINER
`key_vault_update(payload, expected_revision, key_proof)` carrying the CAS inside it, which **may REPLACE
`key_proof_hash` when the call carries the CURRENT proof** (the rotation road); vault CREATE stays a session-only
insert that sets the hash; **a vault whose hash is NULL accepts its FIRST proof from any session** — the migration arm
for the author's existing vault, closed the moment the hash lands. Vault READ stays session-only (a new device must
fetch the wrapped copies to obtain M). `account_purge` stays session-only (deletion is mandated and loud).
**Consequence: the account password alone can sign in, see nothing, push nothing, purge nothing, delete nothing but
the whole account**; a stolen or cloned session is inert against the corpus; the pull side stops disclosing even the
structure to a bare session. Cost: four nullable columns on `key_vault` (`master_wrapped_by_apple_held`,
`apple_key_id`, `key_proof_hash`, `corpus_previous_wrapped_by_master`) and a `key_proof` parameter on the RPCs — **ONE §12 lockstep event, marker 7 → 8**,
in her deploy window (the 13j choreography). The fake-server harness enforces the proof exactly as the SQL does.

---

## 4. ENTERING AND LEAVING CASTLE (the two acts, step by step)

**Standard → Castle (an open library; signed in and online if sync is on; the ceremony: passphrase set if none, twelve
words generated + confirmed if none, the floor read once; Touch ID or the passphrase confirms):**
1. **Pull to head.** Refuse offline or with a non-empty outbox.
2. **Rotate the sync keys** (sync users only): mint M′ and C′; rewrite the vault in ONE `key_vault_update` authorized
   by the OLD proof — M′ under P and under W (no iCloud copy), C′ under M′, **the old C under M′ (the previous corpus
   key, for the rotation's duration)**, the proof hash replaced, the corpus key id advanced (the fence). M′ and C′ into
   this device's custody; the old C kept there as the previous key until step 3 completes.
3. **Re-encrypt the server copy:** every row still under the old key is rewritten under C′ through `sync_reencrypt` —
   version-neutral, no truncation; a row whose version moved is pulled and retried; the fence refuses old-key pushes
   and pulls from then on. **Any device holding M′ can do this work** (it reads old-key rows
   with the previous corpus key); the rotation is COMPLETE when a device at head sees no row under the previous key,
   and that device clears the previous key from the vault (a proof-authorized write) and from its custody.
4. **Re-key this library:** export-and-swap on the 13p migration road — `sqlcipher_export()` from the open keyed
   connection into a fresh file under a NEW L with a fresh salt; verify; atomic swap; old `-wal`/`-shm` removed; the
   pool closed first; off-main. A NEW key file under the new fingerprint: L′ under P, W and M′ — no iCloud copy; the
   old key file stays beside old snapshots.
5. **Custody:** the raw L′ behind Touch ID (`.biometryCurrentSet`), or nowhere under Always ask, through the existing
   `CustodyHandover` transition; re-lock on sleep/screen lock ON.
6. **A fresh snapshot** of the re-keyed library under the new key, into the app's own folder — BEFORE anything is
   offered for deletion. **The scheduled plaintext `.md` insurance goes OFF** with one notice (re-enabling it under
   Castle shows the Castle warning).
7. **The offer:** delete the app's own pre-switch snapshots (the outside-copies sentence; iCloud Drive's Recently
   Deleted keeps them 30 days).
A persisted marker (the `AccountRekeyMarker` pattern) re-runs a crash at any step to completion on the acting device,
and any device holding M′ can finish step 3 if the acting device never returns; **Castle is declared only when the
vault write has landed**; the iCloud key is never deleted; **no backup folder is written** (the fresh snapshot in step
6 is a new file, not a rewrite). Without sync (no vault): steps 4–7 only.

**Castle → Standard (an open library; Touch ID or the passphrase + the consent sentence):** read A from iCloud
Keychain (mint + write if absent); add the iCloud copy of M to the vault (one CAS write under the proof) and of L to
this key file; custody gated → plain; re-lock off. Nothing rotated.

**Other devices follow** (§7): into Castle by typing the passphrase or the words once and re-keying their own
library; into Standard silently.

---

## 5. THE DOORS (who · authorization · what changes · what other devices see)

| door | needs | authorization | changes | other devices |
|---|---|---|---|---|
| **Set up sync** (first device of an account) | an open library, signed in, no vault | the ceremony: P (verified against the library's own P copy if one exists — one secret) + W: generated and confirmed, ONCE — or, if the library already has twelve words, TYPED (they become the account's) or replaced by new ones (the key file's copy replaced); never a silent reuse | mint M, C, J; wrapped copies of M under P, W, and (Standard) A — A read from iCloud Keychain, minted + written if absent; create the vault with the proof hash; M/C/J into this device's custody; the master copy (+ the iCloud copy in Standard) into the key file; **a library whose rows carry another OWNER's stamp: re-stamp every row + `resyncReinitialize`** (the deleted-then-recreated account; a library from another account) | — |
| **Enroll** (a device joins an existing vault) | a library (fresh or with content), signed in | Standard: A → the vault's iCloud copy → M, nothing typed (P or W as the alternative). Castle: P or W → the vault → M | M/C/J into this device's custody (a fresh identity on a machine that had none); the master copy into the key file; custody/posture reconciled to the account's — **a Standard-born library (its key file carries an iCloud copy) joining a CASTLE account re-keys itself exactly as §4's step 4** (its pre-sign-in rows ride into the new file; the account's passphrase becomes the library's — the P copy re-wrapped); **another OWNER: re-stamp + `resyncReinitialize`; the SAME owner with a rotated key id: the follow (§7)** | — |
| **Change passphrase** | an OPEN library; online if enrolled (a server write) | Standard: the current P if known; *forgot it?* → a plain confirm (this device holds the keys). Castle: the current P; *forgot it?* → Touch ID on a gated device, else the twelve words (an always-ask device typed P to open). The words authorize everywhere | a RE-WRAP: M under the new P in the vault (one CAS write under the proof; a fresh KDF salt/descriptor); L under the new P in THIS device's key file. Nothing else — no backup folder, no other device's key file. The checkbox *"Also replace my keys"* runs Replace All Keys | keep syncing (they hold M); the new word opens them at once online (the vault road) and re-wraps their copy on first use; the old word keeps opening them until then; a one-time notice names the change (Rule 1) |
| **Regenerate twelve words** | same (online if enrolled) | same | the W copies replaced in the vault and this key file; the old words dead the moment the new are confirmed; the same checkbox | the new words work there at once online; their local W copy re-lands when the new words are typed there; the old words keep opening them until then (Rule 1) |
| **Standard → Castle** | §4 | §4 | §4 | §7 |
| **Castle → Standard** | §4 | §4 | §4 | §7 |
| **Replace All Keys** | an open, ENROLLED library, signed in, online, holding the CURRENT master (the door checks the key file's recorded corpus key id against the vault before offering itself; else *"this account's keys don't match this library"*) | Castle: Touch ID or P (or W). Standard: P if one is set, else a plain confirm | §4's steps 1–4 without the posture change: M′, C′, the vault rewritten under the same posture's wrappers (+ the iCloud copy again in Standard), the proof replaced under the old proof, every row re-pushed under C′, THIS library re-keyed; the checkbox *"Also choose a new passphrase"*; the marker. The server refuses a stale proof regardless of the front check | the same follow as entering Castle: type P or W once, re-key own library, pull |
| **Delete account** | signed in (enrolled or not) | account password + typed phrase + a FRESH re-authentication | server copy + vault + login gone (`account_purge`); LOCAL COPIES UNTOUCHED; the app signs out; the keys stay in this device's custody; A stays in iCloud | lose sync; keep everything local; a later account adopts them at setup |
| **Sign out everywhere** | signed in | — (the mitigation for a stolen password or session; `signOut(scope: global)`) | every session revoked; keys untouched | sign in again |
| **Sign out** | — | — | clears this device's tokens; the keys stay in this device's custody (behind the library key's own gate) | — |
| **Plaintext `.sqlite` export** | an open library | Castle: P (never Touch ID alone). Standard: P if set, else a plain confirm | a decrypted copy WITHOUT the local sync tables (§3.3) to a user-chosen location; a plain warning; never scheduled, never into the backups folder | — |
| **Plaintext `.md` export** | — | unchanged (13l; the scheduled insurance opt-in, warned under Castle); not gated in Castle | — | — |
| **Lock Now / re-lock** | Castle | — | tears down services, drops key material (`StoreBinding.lock`) | — |

**What the account password can do, in BOTH postures:** sign in · delete the account · sign out everywhere · cancel.
It can NEVER open a library, read or write the mirror, purge, change a passphrase, change a posture, or export.
**Its worst case is the loud one — the account deleted — which every local copy survives.**

---

## 6. BACKUPS UNDER THE MODEL
The 13l backups are ciphertext + key file(s), launch-if-due + daily, 14 dailies + 4 weeklies (`StoreBackup.swift`),
made through GRDB `backup(to:)` from an OPEN keyed connection — under Castle they run **at the first unlock of the day
if due**, plus a keyless byte-copy at lock time when due (the app's own folder only). **A backup is writing, never a
device:** the file carries no sync key and no device identity (§3.3). Snapshots carry the key fingerprint in their
filename (`variorum-backup-<stamp>-<fp8>.sqlite`); the key file beside them is named by fingerprint and **NEVER
overwritten by a different key's file** — a folder holds one per library key it has ever held; legacy
`variorum-keys.json` serves legacy snapshots. **A backup folder is never rewritten after it is written** — not at a
passphrase change, a words regeneration or a posture change.
**Opening a snapshot:** by whatever its key file's copies open under — the passphrase of its day, the twelve words,
the master copy (an enrolled device's master, or the current passphrase online through the vault), and, if it was made
in Standard, the iCloud key. On the Mac the library lives on, custody and the LIVE key file pair with every snapshot of
the same library key, so Touch ID and the current passphrase open old snapshots there without any folder being touched
(the restore surface's second look: a matching-fingerprint key file beside the live library as well as in the folder
— 13x's open door; the 13l restore drill).
**Rejoining sync:** a restored snapshot enrolls like any library with content — Standard: through the iCloud key,
nothing typed, on a device signed into the account; Castle: the passphrase or the words once — and gets a fresh
device identity on a machine that had no custody for it. It never syncs by virtue of being a copy. **A Standard-era
snapshot keeps its iCloud copy and opens through the Apple account for as long as it exists;** snapshots made after
the switch come from the re-keyed library under the new key and its new key file.
**The one user sentence:** *"A backup opens with your twelve words — always, unless you regenerated them — or the
passphrase you had when it was made; and, if it was made while you were in Standard, through your Apple account."*
**Said once at the Castle switch, as a limit and as a way back:** *"backups made before today — Variorum's own, Time
Machine, copies you made — still open through your Apple account. Delete them, Time Machine included, if you want
Castle to cover everything you have ever written. Keep them if you want a way back to what you wrote before today,
should you ever lose your passphrase and twelve words."* The runbook (`notes/DataSafetyRunbook.md`) is rewritten for
two postures; same-Mac erase-and-restore: Castle reopens by passphrase, Standard by iCloud — proven in the drill.

---

## 7. CROSS-DEVICE CHOREOGRAPHY (Mac + phone)
**A passphrase change (both Castle):** 1. Mac (open, online): re-wrap M in the vault (CAS + the proof), re-wrap L in
its own key file. Phone untouched, keeps syncing. 2. Phone, next open by Face ID: the post-unlock reconcile reads
descriptor ≠ recorded, same corpus key id → a one-time notice (*"your passphrase was changed on [Mac] on [day]; use
the new one here the next time you need a passphrase"*) — nothing prompted, nothing deleted. 3. Phone, next open by
passphrase: the OLD word still opens it (its local copy); the NEW word opens it online via the vault road and re-wraps
the local copy — from then on only the new word. 4. Phone OFFLINE: the local copy, the old word. 5. Both change at
once: the vault's CAS refuses the second; it re-reads and retries (the last change wins). The same steps serve Standard
and a regenerated phrase.
**The follow into Castle (after §4 ran on another device, or after Replace All Keys):** (1) the device opens as it did
(Standard: silently; Castle: Face ID / Touch ID, or the unchanged passphrase on an Always-ask device — reused for the
follow, never asked twice); (2) at ready it reads the vault: no iCloud copy ⇒ Castle (or the corpus key id ≠ the id
its custody records, SAME owner ⇒ rotated) ⇒ the notice; its rounds are refused meanwhile (old proof); (3) the user
types P or W; the device derives the wrapping key locally, unwraps M′ from the vault's P (or W) copy, C′ from its copy
under M′ (and the previous corpus key while the vault carries one), computes the new proof — nothing is unwrapped on
the server; (4) it writes M′ and C′ (+ ids) into its CUSTODY, replacing the old ones (the previous key kept until the
rotation completes); (5) it re-keys its own library (§4 step 4) and writes a NEW key file: L′ under the typed secret
and under M′ (the other secret's local copy lands when that secret is next typed here), no iCloud copy; the raw L′
goes behind Touch ID or nowhere (Castle), or stays the silent item (Replace All Keys under Standard, where the key
file also gets the iCloud copy again); (6) it PULLS from its own cursor — the re-encrypted rows arrive with unchanged
versions and are seq-recorded only; its pending outbox rows push under C′ with the new proof and CAS cleanly. **No
`resyncReinitialize`, no re-stamp: same account, same rows.**
**A device that has not followed yet (what it looks like):** it opens as it did; then a modal notice (copy §5): *your
account moved to Castle* or *your keys were replaced* on [device] on [day] — enter your passphrase once. *Not now* is
allowed: the library opens, reads and edits; sync does NOT run and a persistent banner says *waiting for your
passphrase*; edits queue in the outbox; every key door (change passphrase, regenerate words, Replace All Keys, the
posture switches) is unavailable with one sentence — *pick up your new keys first* (its proof is stale; the server
would refuse); Sign out and Delete account still work; the notice returns on every open. Nothing on the device is at
risk meanwhile — its content is pre-rotation and its old keys are dead on the server — but a Standard device stays
silently openable until it follows, which is why the notice insists.
**The follow into Standard:** at their next open: an iCloud copy in the vault ⇒ Standard ⇒ they add their own iCloud
copy to their key file (A from their own iCloud Keychain), custody goes silent, a one-time notice names the device
and day; nothing typed, nothing rotated. Offline devices follow when they connect.
**A restored or copied library:** it holds no sync keys, so it opens by the key file's roads and then ENROLLS (§5) —
Standard: nothing typed; Castle: the passphrase or words once, reusing a word just typed to open — with a fresh device
identity; the reconcile then finds the same owner (and a current or stale key id ⇒ the follow) or a different owner
(⇒ adopt).
**A deleted-then-recreated account:** §5's setup + enrollment rows; the other devices see "keys don't match" (a
different owner) and re-enroll (Standard: nothing typed) with re-stamp + `resyncReinitialize`.

---

## 8. COMMUNICATION (every surface — the strings are `pre-13x-copy.md`)
- **Protection pane** → the two-posture chooser (Standard default; Castle behind the ceremony) + Castle's two switches
  + the idle dial + Lock Now. Presets / escrow / loss legs / sync-gate sections deleted.
- **`ProtectionShapes`** → §2's table rendered; two what-ifs per posture; the keystone lines; the design laws in the
  field guide. §2 IS the copy.
- **Where the Touch ID copy sits:** every Castle surface that offers Touch ID says *this Mac's security chip holds a
  copy of the key, released only to your fingerprint — never to your login password, never to iCloud; it never leaves
  this Mac; turn Always ask on and no copy exists.* The Standard card carries the mirror sentence (the key lives in
  iCloud Keychain, travels with the Apple account, reachable by Apple's account recovery).
- **The three-line compromise rule**, both postures: a passphrase or words only SEEN → change / regenerate; a leaked
  session or account password → sign out everywhere; someone who may HOLD your keys (an unlocked enrolled device plus
  your account password; in Standard, your Apple account) → Replace All Keys; the ACCOUNT itself in someone's hands →
  delete it and set sync up again.
- **Tutorial "keeping it private"** → a SHORT chapter (copy §7): both modes E2EE; who holds a key; the two modes; what
  you must keep in each; the open-app sentence; a door to the book. Re-seeded through the seeder's replace door; the
  walk asserts both postures, both floors, keystone 3, keystone 4 and the book's door.
- **THE ENCRYPTION BOOK — *Encryption Explained*** (copy §7b): a second seeded book in Home beside the tutorial,
  restorable from Help like the tutorial, and a member of the seeded-book dedupe facts (two devices never seed two of
  it): what is encrypted and with what; every key and where it lives; Standard and Castle step by step; backups and why
  an old one behaves as it does; changing things; who can read what; what we can and cannot do. The website FAQ
  mirrors it.
- **Backups tab** → §6's sentence per posture; "backups run while your library is open" under Castle; the iCloud Drive
  offer; the scheduled plaintext `.md` insurance shows the Castle warning and is OFF after a switch into Castle.
- **Encryption tab** → setup / enroll / change passphrase (+ checkbox) / regenerate (+ checkbox) / Replace All Keys / sign
  out everywhere / delete under §5's authorizations; the biometric-sync toggle, the forget door, the reset door GONE;
  the not-enrolled state shows delete/cancel.
- **The nudge** → two tiers + unknown (§3.8). **The unchosen indicator** → "Standard".
- **The sync signup ceremony** → passphrase + twelve words + one sentence per posture on what iCloud does + Standard's
  keep-your-words line. **The Castle ceremony** → §4's screens incl. the backups sentence and the delete offer.
- **Mobile** (§9) — the same shared faces.
- **The tier sentence** (13t) → posture-conditional. **Runbook** rewritten. **KnownIssues** rows resolved at closeout
  (the E2EE custody residual; the clone row; the Castle-bypass row; the copy-ahead-of-code row; the staleness row).
  **QUESTIONS #81 / #87** dissolved as listed at closeout; `pre-13u-memo-security-shapes.md` superseded.
- **Outbound brief re-issued**: the stargazing privacy-policy brief (two postures; the plaintext export; the disclosure
  envelope SHRINKS — a bare session no longer reads structure).
- **Marketing discipline:** Castle is the headline; Standard's sentence must survive the landing page; the Day One
  contrast is the true one — *"the file itself is ciphertext, and in Castle the key that opens it is not on your Mac in
  any form your login password can release."*

## 9. MOBILE
All faces are shared code; the phone changes with the Mac inside this phase. Phone specifics: Castle = Face ID with the
passphrase as fallback (Always ask remains the one switch); Standard = iCloud Keychain (present when signed in); quick
capture demands unlock under Castle; the phone is a first-class birthplace of libraries and of Castle; the phone
follows the account posture like any device (§7); the iOS target carries the shared access group, A's item family and the sync-key custody item (which carries the device identity);
the iOS device-backup fact is in copy (a keychain item in an iCloud device backup restores only to the SAME device — a
new phone receives A through iCloud Keychain SYNC: "sign into iCloud, open Variorum," never "restore the backup"). An
iOS device backup taken between first open and Castle enrollment holds the old ciphertext + its key file (iCloud copy)
— old writing only after the enrollment re-key. Parity ledger line at closeout.

## 10. THE FRAGMENTS BRIDGE
Retired and removed from `main` (`notes/plans/pre-13x-bridge-retirement.md`; tag `archive/fragments-bridge-2026-09-04`).
Kept: the vault's `journal_bridge` class key column (NOT NULL; minted, dormant) and `DeviceKeyMaterial.journalBridgeKey`.

## 11. MIGRATION (existing stores — the author's two devices, in her presence)
Both map to **Castle** (the vault carries no iCloud copy; nothing to rotate). At first unlock: re-scope the existing
E2EE Keychain items per store ID and align their custody with the library key's (her Mac: the biometric item); delete
the plain item and the CF-12 opt-in; add the device identity to the custody item (from `sync_state`); re-bind the
tokens; retire the dial keys; write the key file's master copy + descriptor + corpus key id from HELD material (no
visit, no typing — this alone gives the vault road); land the proof hash in the vault (an M-holder's write) at the
lockstep window; the passphrase copy follows the first time the passphrase is typed anywhere (the migration may ask
ONCE — *"confirm your passphrase to finish"*). The custody scope migrates to store-ID naming; the existing gated
store-key item stays under the app's own group. Every migration leg logs a line — never key material (pinned). Her
phone becomes Castle at its migration (Face ID with passphrase fallback) — say so to her at the batch 2 sitting.

## 12. TESTS & PINS (red-on-old, each)
- **Keys in custody, never in the file:** a byte scan of a fresh backup, of the keyless lock-time copy and of the
  plaintext export finds no key-shaped value and no device identity; a copied library on another machine cannot sync
  until enrolled and gets a fresh device identity; a fresh library has no custody and can only ask; the absent-store
  route never opens a pullable library; a locked library reads as no keys; an Always-ask device holds its sync keys
  only in memory for the session; an Always-ask Castle library on the same machine keeps its identity across opens.
- **The key proof:** a session without it cannot push, pull, update the vault, purge or truncate — and CAN fetch the
  vault and CAN delete the whole account; the wrong proof refuses; the NULL-hash first write lands once; a call with
  the old proof after a rotation is refused; the right `active_key_id` without the proof deletes nothing.
- **Rule 1 by use:** after a change elsewhere, the new word opens a device online at once and re-wraps its copy; the
  old word opens it until then (online and offline); the notice appears once; a typo never writes a copy (the vault
  unwrap must succeed first).
- **Rule 2, the owner distinction:** a rotated same-owner account FOLLOWS with an ordinary pull and no re-stamp; a
  foreign owner ADOPTS; a change on another account never locks a device out of its own library.
- **The master copy:** the current passphrase opens an old backup online (undeleted account); the twelve words open a
  library whose local W copy was never landed.
- **The iCloud copy:** a Standard new device enrolls with nothing typed; a Castle vault carries none — pin the ABSENCE.
- **Entering Castle:** a Standard-era key file + A opens NO page of the post-switch library; a Standard-era snapshot
  restored and opened through A holds NO sync key and cannot enroll into a Castle account without P or W; after the
  switch NO row on the fake server decrypts under the old corpus key; an old-C push or pull is refused by the fence;
  the follow lands M′ only after P or W is typed; a device that follows re-pulls to an identical store (convergence);
  the switch run on a byte-copy of her real store, its time recorded; a crash injected after the export and before the
  swap, and one mid-re-encryption, each re-run to completion; the vault write is the declaration; the acting device's
  rotation is one CAS write (a concurrent second switch refuses and retries); enrollment re-keys a Standard-born
  library (the phone's pre-sign-in rows survive; its old key file + A opens only the old file).
- **Any enrolled device can finish a rotation:** the acting device is killed after the vault write with rows still
  under the previous key; a follower (and, separately, a NEW device enrolled mid-rotation) reads them, re-encrypts
  them, and clears the previous key at head; the vault's previous-key column is NULL outside a rotation (pin the
  absence).
- **Version-neutral re-encryption:** a device with offline edits across a rotation converges with ZERO conflict
  variants; re-encrypted rows arrive at followers with unchanged versions and are seq-recorded only; a row whose
  version moved is skipped by `sync_reencrypt` and re-encrypted after a pull.
- **Entering Castle leaves nothing behind:** a snapshot under the new key exists before the delete offer; the
  scheduled plaintext insurance is OFF after the switch and re-enabling shows the warning.
- **Backups:** NO backup folder is EVER rewritten (the folder's bytes before == after a posture change, a passphrase
  change, a words regeneration); a same-fingerprint snapshot opens with the live library's custody / current key file;
  the delete offer removes only the app's own pre-switch snapshots and never a post-switch one; a second key's file
  never replaces the first; a restored snapshot enrolls with a fresh identity and never syncs before enrolling.
- **Replace All Keys:** refused twice on a stale master (the front check; the server); the same follow as the switch.
- **The un-followed device:** opens and reads; sync refused; the key doors unavailable with the sentence; sign out and
  delete work; the notice returns at every open; a passphrase typed to open is reused for the follow.
- **Key doors online:** an enrolled library's change passphrase / regenerate / Replace All Keys / switch refuses
  offline with the sentence; a local-only library changes its passphrase offline; two online changes at once: CAS,
  last writer wins, the other learns.
- **Twelve words at sync setup:** a library with existing words refuses a silent reuse — typed (they become the
  account's) or regenerated (the key file's copy replaced).
- **Her attacker scenario (the two-user suite):** old Standard backup + A + the account password after the switch →
  reads pre-switch writing, cannot enroll (no P/W), can delete the whole account, and nothing else; an upload under a
  NEW account never touches another tenant's rows; no ownership-change instruction exists on the wire.
- **Posture:** derivation + follow (a Standard phone under a Castle account gates at its next open; a Castle→Standard
  switch propagates silently); an account with no vault makes nothing Castle.
- **The plaintext export** carries the synced tables only, no key-shaped value, and keeps the synced tables' sync
  columns.
- **Custody:** per-store-ID items (a legacy item migrates once; a second store never collides); device-bound tokens;
  the biometric item carries NO passcode fallback; no key material in the launch log.
- **Setup adopts** a foreign-stamped library (delete → recreate → every row syncs); **re-enrollment re-initializes**
  (a row the server lost is re-pushed, not stranded).
- Deletion reachable when not enrolled; the 12-character floor; the descriptor floor on read (m ≥ 19 MiB, t ≥ 2,
  16-byte salt); the client never wraps M or L under a key received from the network (A is read from iCloud Keychain or
  minted locally; the server supplies only wrapped copies and an `apple_key_id` the client verifies, never adopts); the
  shared access group on both targets (an entitlements pin).
- The convergence suites gain §7's choreography against the fake server (which enforces the proof, the fence and
  `sync_reencrypt`). Both drills re-run: the 13p migration drill on a byte-copy of her real store, and the 13l restore
  drill per posture, on both devices.

## 13. WHAT GETS DELETED
`StoreAtOpenMode` as a three-way setting (posture + gate style replace it), `ProtectionDials.escrowOn` +
`effectiveEscrowOn` + the coupling copy, `ProtectionPreset`, `ReminderCheckPolicy` as a dial (Castle: always on),
`relockOnSleepAndScreenLock` as a dial (Castle: always on), the CF-12 opt-in sync gate + `SyncGateOptIn` + `E2EELaunchKeyCache` (the sync keys' custody follows the library
key's — no toggle; `E2EEKeychainStorage` / `E2EECustodyStorage` / `DeviceKeySyncProvider` are RESHAPED into the
per-store custody item family, not deleted), the escrow item family (`StoreKeyGuardKeychain` escrow arms — A's family replaces it), the CF-11 forget door
(folded into sign-out), the R13p-9 reset door as a separate door (merged into change-passphrase), `AccountRekey` as the
OLD user door + `RekeyRecencyProbe`'s UI caller (the brain is reused by Replace All Keys and the headless
`vault-bootstrap` tool), `lossLegs`/`lossMath`, the recipes/need-states/shapes tables, the escrow verify-landed probe,
`openResettingModeToAuto`, the two DEBUG probe doors once the real Apple key lands.

## 14. CORNERS (each is a step, not a deferral)
1. The plaintext export never receives local tables (§3.3). 2. Deletion/cancel reachable when not enrolled. 3. Custody
per store ID. 4. Entering Castle writes no backup folder; every pre-switch copy opens through the Apple account for as
long as it exists, and the ceremony says so as a limit and a way back. 5. A is never deleted — after the switch it opens
nothing but pre-switch copies; it serves other libraries/accounts on the same iCloud. 6. Two libraries on one Mac with
different postures joining one account: the second adopts the account's posture with consent at enrollment (and
re-keys if Standard-born into Castle). 7. Old backups after a deleted-then-recreated account hold the OLD M — useless
(the old vault is gone); the restored library lands in "keys don't match — set up sync again." 8. Backups run at
unlock-if-due under Castle; freshness copy never cries wolf. 9. Same-Mac erase-and-restore proven in the drill.
10. iCloud Keychain lag/off: the waiting state + the honest unknown. 11. Offline grace after a passphrase change or a
posture change, stated. 12. Apple's account-recovery paths named in Standard's sentence. **13. A re-opened plaintext
export (13x's door):** the export keeps `sync_version`/`owner_id`; under the SAME account the re-opened library enrolls
and pulls from cursor 0 with an empty outbox (zero pushes); under a NEW or NO account it takes the adopt road.
14. Two Variorum accounts on one iCloud share A — each account's copies are its own. 15. Sparkle relaunch → lobby
(verify). 16. Quick capture/hotkey under Castle demands unlock. 17. The pre-unlock vault read is the ONE network contact
before unlock; a locked device never syncs. 18. Two devices changing at once → CAS refuse + retry. 19. A Castle
"always ask" Mac + forgotten passphrase + no words = the floor; the ceremony says so. 20. A Standard user with iCloud
Keychain OFF and no secrets is the ONLY unrecoverable Standard state — the nudge's whole job. 21. Time Machine /
Migration Assistant of a Castle Mac carries nothing usable (no key in the file; custody items device-bound; tokens bound; the gated item
hardware-wrapped); of a Standard Mac carries what iCloud carries anyway. 22. Any finger enrolled on the macOS user
account passes Touch ID — and can therefore open, set a new passphrase and Replace All Keys (keystone 2); Always ask is
the shared-Mac answer. 23. The recovery phrase's COPY ALL clears the clipboard after 60 s. 24. A Standard account's
iCloud copy can be REMOVED only by an M-holder — an account-password holder cannot flip a posture in either direction.
25. The client never wraps M or L under a network-supplied key. 26. **Posture before sync:** with no vault each
library's posture is its own key file's; a Castle Mac without sync does not make a phone Castle; the first device to
set up sync gives the vault its shape. 27. **Passphrases before sync are per library;** at setup the typed passphrase
is verified against the library's own P copy; at enrollment the account's passphrase re-wraps the joining library's P
copy — one passphrase from then on. 28. **A snapshot carries NO sync key and no identity** (§3.3) — it is writing; entering Castle still rotates the
master and the corpus key, because anyone in your iCloud could have unwrapped the old master from the vault during
Standard. 29. **Her attacker scenario** (a Standard user's iCloud-Drive backups + A + the
account password, after the switch): opens the old backup (pre-switch writing); push/pull refused; the follow needs
P or W; Replace All Keys refused; the passphrase-change vault write refused; purge/truncate refused (the proof); CAN
delete the whole account, sign out everywhere, change the account password (the disclosed account-password class —
loud, survivable; 13y's recently-re-authenticated-session guard for the destructive doors); an upload under a NEW
account lands in its own partition (14c's `(owner_id, id)` keys + forced RLS); the adopt road re-stamps LOCALLY —
resyncing is not the attack surface. 30. **Replace All Keys requires the current master** (the front check + the
server). 31. The delete-and-set-up-again road needs no export: it re-stamps and re-uploads the SAME library — every
take, savepoint, edge and comment stays. 32. "Pause sync" is 18a's. 33. **A library that arrives by AirDrop or by hand with its key file** opens by the lobby's
ordinary roads (Castle: the passphrase or words from the key file; Standard on the same iCloud: silently), holds NO
sync key, so it rejoins sync only by enrolling (Standard: the iCloud key; Castle: the passphrase or words once — the
word just typed to open is reused), with a fresh device identity by construction; no new library key is needed.
Without the key file nothing opens.
34. **One Apple-held copy per account:** a device on another Apple ID enrolls by passphrase once (its own key file then
gets a copy under ITS iCloud key for silent open); the nothing-typed new-device road belongs to the iCloud account that
turned on sync.

## 15. BATCHES (strictly sequential; each red-on-old; the tutorial spine green every batch)
- **0 — measurements: DONE** (`notes/plans/pre-13x-spike-memo.md`; the facts in §18). **0b — the bridge retirement:
  DONE** (`notes/plans/pre-13x-bridge-retirement.md`).
- **1a — the client substrate** (zero server, zero lockstep): the sync keys + the device identity in per-store custody
  beside the library key (`SyncKeyProviding` over custody / the session); the
  key file format 2 + per-fingerprint naming; custody per store ID; device-bound tokens; the absent-store route;
  the migration hooks written behind seams (run at batch 2). Brief: §19.
- **1b — the protocol event** (marker 7 → 8; drafted and pinned; DEPLOYED by her): the vault's four columns; the
  proof on push / pull / purge-execute / truncate / `key_vault_update` (which may replace the hash under the current
  proof); `sync_reencrypt`; the fake server; the deploy checklist. Brief: §19.
- **2 — postures + the two switches:** posture derivation + per-device follow; Standard's silent open + the iCloud
  road + the waiting state; A's item family (the dev-scope discriminator; the one query builder); Castle's gated
  custody + Always ask + the idle dial + re-lock + Lock Now + the keyless byte-copy; **entering Castle in full (§4:
  pull to head, the rotations with the previous corpus key, the in-place re-encryption any M′-holder can finish, the
  re-key, the marker, the fresh snapshot, the insurance off, the offer)** and leaving it; the follow
  (§7) on both platforms; the migration (§11) for her two devices; the probe doors deleted.
- **3 — the doors:** the device identity per machine (§1.13); setup adopts (re-stamp + re-init) and the existing-words rule; enroll (incl. the Standard-born-into-Castle re-key and the
  follow-vs-adopt discriminator); change passphrase + regenerate as re-wraps with their checkboxes; **Replace All
  Keys**; sign out everywhere; deletion by account password (reachable unenrolled); the plaintext export + the
  reconciliation note for 13x; the 12-character floor; the descriptor floor.
- **4 — lobby + cross-device:** the vault road; Rule 1 (by use) and Rule 2 (the owner distinction); the change
  notice; the follow notices; the phone's faces; the convergence pins of §12 incl. her attacker scenario.
- **5 — copy + tutorial chapter + *Encryption Explained* (in the seeded-book dedupe) + runbook + parity line + the
  deletions + the privacy-policy brief + the 13y / 13x hand-forwards; the lost-device FAQ entry; the ceremonies'
  progress indicator (an ORIGINAL animated indicator with movement — her example: a line with a few black dots
  travelling back and forth — never the system spinner).**
Then the cold-review ladder (Fable reviewers on every round; each walks §3.4), the two drills, her acceptance walk on
both devices, the `/Applications` refresh and the phone install. **The delete-and-set-up-again road runs on the DEV
store and the fake server only.**

## 16. OPEN
Nothing in the design. **Her acts pending:** Q3's phone leg (optional — the shared-group probe on both devices); the
lockstep deploy window (after 1b, immediately before batch 2's migration + install); at the batch 2 sitting: her phone's
move to Castle and the one-time passphrase confirm on both devices; the sizing flag (three phase-sized units under
one theme — one phase with drills as gates, or a split after U3; U2 proceeds either way); 13s re-voices the copy later.

## 17. CANON DELTAS AT CLOSEOUT AND HAND-FORWARDS
AppSpec §14 (this phase's delta, incl. the bridge retirement's canon changes applied in place 2026-09-04) + §7's
`setting`/`sync_state` note (the sync keys and the device identity live in per-store custody beside the library key, never in the file; the key file beside the store; entering Castle rotates the
library key, the master and the corpus key); SyncSpec §3 (the key provider reads the store; the vault read before
unlock; the key proof on every mutating RPC but whole-account deletion) + §12's running record (marker 7 → 8);
CoreDescription untouched except §8's 9b mention (retired with the bridge); the 13p constitution's R13p-5/6/7/9
recorded as superseded; `pre-13u-memo-security-shapes.md` superseded; KnownIssues rows resolved; 13x's row gains the
open door's reconciliation cases (§14.13) and the same-fingerprint second look; 13y's row carries the adopt-road
convergence pin under per-tenant `server_seq`; MobileSoul parity line; QUESTIONS #81 / #87 dissolved / re-listed.

---

## 18. EXECUTION RECORD (the running record the `/architect-phase` skill requires)

### Acceptance units
| unit | kind | evidence that closes it |
|---|---|---|
| U0 batch 0 — measurements | spike | **DONE** — `notes/plans/pre-13x-spike-memo.md` |
| U1 batch 0b — the bridge retirement | operations | **DONE 2026-09-04** — `notes/plans/pre-13x-bridge-retirement.md` |
| U2 batch 1 (1a + 1b) — substrate + the lockstep event | sync/protocol (phase-sized) | convergence suites incl. the proof; ONE live two-device round on the real mirror after her deploy |
| U3 batch 2 — postures + entering/leaving Castle | custody (phase-sized) | four drills: the Standard new-device road (nothing typed); the Castle new-device road (passphrase once); Standard → Castle on a byte-copy of her store with a Standard sibling device following (the old snapshot refused; every row under C′); Castle → Standard |
| U4 batches 3 + 4 — doors + lobby + cross-device | custody (phase-sized) | per-door drills (change passphrase across two devices; regenerate; Replace All Keys with a sibling following and a stale copy refused; sign out everywhere; delete + re-setup on the DEV store; the export's strip pin; the vault road at the lobby) |
| U5 batch 5 — copy + tutorial + book + mobile faces | UI | hands-on use of both apps, both postures; the tutorial spine green |

**Measured facts (batch 0):** the shared access group signs on both targets under the team wildcard with no App-ID
step; a synchronizable item under the shared group round-trips (add 0 · read 0 · flagged delete 0 · flagless delete =
silent no-op · another group does not see it); the pre-unlock vault GET: median 0.051 s, max 0.314 s cold, 0.015 s
warm; Argon2id v1 (m=64 MiB, t=3): 0.766 s median on the M3; the Apple key's Keychain account must carry the dev-store
scope discriminator (a Debug build and the Release install would otherwise share one A). Q3 (the item crossing to the
phone) is PENDING her sitting — not blocking until batch 2 writes the real Apple key.

### Environment traps (every batch brief carries this verbatim)
Instance checks via `pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated by PATH; treat real-store instances by
STORE — NEVER quit/kill one; NO Release builds or `/Applications` refreshes while one lives (and none at all before the
lockstep deploy lands — a marker-8 client would visibly refuse against the marker-7 mirror); core tests via `swift test`
from the repo root; Mac app tests from `App/Variorum/` with suite-level `-only-testing` only, passed as a zsh array
(`"${ARGS[@]}"` — an unquoted `$VAR` arrives as ONE argument and xcodebuild exits 65), confirm the "Test run with N
tests" line and read the `skipped:` lines (Swift Testing counts skipped tests); `xcodebuild build-for-testing` compiles
without the runner; NEVER add a custom build configuration (the 4G trap); zsh `pipestatus`; scratch and screenshots in
gitignored dirs INSIDE the worktree (the batch 0 DerivedData `App/Variorum/DerivedData/pre13x-b0` is reusable); never
`git checkout` over uncommitted work; commit per piece and PUSH after every commit; synchronous foreground waits only
(poll with a `grep -q` loop — `tail -f | grep -m1` never returns); the A1 backup rail before ANY touch of the real
store; suites beside her live session flash the test host's windows — prefer zero-instance windows for timing-sensitive
measurements; never spawn subagents (one Sonnet lookup for external facts is the sole exception, read-only). The
tutorial spine is SIX suites in `TutorialWalkTests.swift` addressed by TYPE name — 72 tests / 10 suites standing.

### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- U0 — DONE. U1 — DONE 2026-09-04.
- **U2 batch 1a — NEXT** (a fresh Fable implementer; brief §19). U2 batch 1b — NOT-STARTED. U3 — NOT-STARTED.
  U4 — NOT-STARTED. U5 — NOT-STARTED.

### THE LEDGER (every row owned)
| # | item | owner | status |
|---|---|---|---|
| 1 | the shared keychain access group on both targets | U0 → U2 | done at U0 (`a37f9cd`) |
| 2 | A crosses Mac ⇄ phone under the shared group (her two devices) | U0 | PENDING her sitting (both DEBUG doors built) |
| 3 | the decision memo | U0 | done |
| 4 | the guard against working from a library inside iCloud Drive | 13x | deferred, owned |
| 5 | "Open a library file…" (plaintext → fresh key + identity; ciphertext + key file; the same-fingerprint second look; §14.13's reconciliation) | 13x | deferred, owned |
| 6 | the inactivity dial: default 10, offered 5 · 10 · 30 · never; clock = time since Variorum was last used | U3 | open |
| 7 | the keyless byte-copy at lock (app folder only) | U3 | open |
| 8 | the Apple key's Keychain ACCOUNT carries the dev-store scope discriminator | U3 | open |
| 9 | the Apple-key query family: ONE builder (synchronizable + shared group + DP marker) on every verb; `KeychainPartitionTests` extended | U3 | open |
| 10 | the lobby's vault road: derive once when descriptors match; concurrent vault read; progress from ~200 ms; ~10 s ceiling → offline grace | U4 | open |
| 11 | Keychain Sharing on BOTH App IDs for distribution profiles | 13r | deferred, owned |
| 12 | the two DEBUG probe doors DELETED when the real Apple-key item lands | U3 | open |
| 13 | entering Castle in full: pull to head · M′/C′ · the vault rewrite under the old proof · the in-place re-push behind the fence · the library re-key (export-and-swap) · custody · the marker · the offer; measured first on a byte-copy of her store | U3 | open |
| 14 | NO backup folder is ever rewritten — the absence pin; the same-fingerprint second look | U3 (the look: U4 → 13x) | open |
| 15 | the Standard-born-into-Castle enrollment re-key; the follow-vs-adopt discriminator (Rule 1, Enroll, §7) | U4 | open |
| 16 | `key_vault_update` may replace the hash under the current proof; `sync_purge_execute` and `account_data_truncate` take the proof | U2 (1b) | open — MUST |
| 17 | Replace All Keys + its checkboxes; the stale-master front check; the same follow as the switch | U4 | open |
| 18 | the "Delete backups made before today" offer — the app's own folders; the outside-copies + Recently-Deleted sentences | U3 | open |
| 19 | her attacker scenario in the two-user suite; the no-ownership-change pin | U4 | open |
| 20 | the where-the-key-sits line on every Castle surface + the Standard mirror + the three-line rule | U5 | open |
| 21 | *Encryption Explained* seeded + the tutorial's short chapter; the two-register vocabulary rule | U5 | open |
| 22 | the plaintext-export reconciliation note for 13x (§14.13) | U4 → 13x | open |
| 23 | the 13y hand-forward (the adopt-road pin under per-tenant seq) + 13x's row updated at closeout | U5 | open |
| 24 | §3.4 kept current and walked by every ladder reviewer; every "at the switch" cell pinned at closeout | every unit; U5 | open |
| 25 | any enrolled device can finish a rotation: the previous corpus key wrapped under M′ in the vault (the fourth column), kept in followers' custody until cleared at head; the dead-acting-device drill | U2 (1b) → U3 → U4 | open |
| 26 | entering Castle: the fresh snapshot before the offer; the scheduled plaintext insurance OFF with a notice | U3 | open |
| 27 | sync setup from a library with existing twelve words: typed or regenerated, never silently reused | U4 (batch 3) | open |
| 28 | *Encryption Explained* in the seeded-book dedupe facts | U5 | open |
| 29 | `sync_reencrypt` — version-neutral re-encryption (the RPC, the fake server, the zero-conflict pin) | U2 (1b) → U3 | open |
| 30 | the device identity rides the sync-key custody item (a copy on a machine with no custody gets a fresh id; Always ask unaffected) on both platforms | U2 (1a) | open |
| 31 | one Apple-held copy per account — the book's and the waiting state's sentence | U5 | open |
| 32 | the lost-device FAQ entry; the ceremonies' original animated progress indicator | U5 | open |
| 33 | Rule 1 by use + the one-time change notice; the un-followed device's state (banner, door lockout, the reused passphrase) | U4 | open |

### The architect's sign-off conditions (the reasoning is in the history file)
(i) the key proof ships in this phase's lockstep event; (ii) the descriptor-floor and never-wrap-under-a-network-key
pins land in batch 1; (iii) A is observed crossing her two real devices under the shared group before any Standard copy
is written (Q3); (iv) Fable reviewers on every ladder round, each walking §3.4; the two drills on both devices; (v) the
honest boundaries in §2 and §14 survive 13s's re-voicing in substance; (vi) §3.4 holds at closeout with every "at the
switch" cell pinned.

---

## 19. BATCH BRIEFS

### BATCH 1 — the substrate (U2, phase-sized; TWO implementer sessions, 1a then 1b; each a FRESH Fable)
**Read first (both sessions):** `CLAUDE.md`; `notes/SessionResiliencyProtocol.md`; this file §0–§5, §11, §12, §18.
**Baseline:** the bridge retirement has LANDED on `main` (`notes/plans/pre-13x-bridge-retirement.md` §6 DONE) — verify;
batch 1 never runs over the bridge code. **Rule for both:** her installed Release app keeps working untouched — NO
install refresh, NO Release build, no migration of her real store (batch 2's §11, after the deploy). The dev store is
the proving ground. Batch 1a inherits ONE KnownIssues row from the retirement (the retired-credential sweep's sign-in
occasion: gate + off-main + a required seam).

**1a — the CLIENT substrate (zero server, zero lockstep):**
1. **Sync keys in custody, never in the file** (§3.3): reshape `E2EEKeychainStorage` / `E2EECustodyStorage` /
   `DeviceKeySyncProvider` into ONE per-store item family beside the library key's, with the library key's three
   shapes (silent · biometric · none-with-session-memory), the account keyed `<scope>-<storeID>-sync`; it carries M,
   C (+id), J (+id) and the device identity. `SyncKeyProviding` reads custody (or the session under Always ask),
   synchronous by contract; a LOCKED library reads as no keys → `SyncError.encryptionKeysUnavailable` (pin).
   `sync_state` loses `device_id` (read from custody; a library on a machine with no custody for its store id ⇒ a fresh
   id — pin; `resyncReinitialize` still spares nothing key-shaped because nothing key-shaped is in the file — pin by a
   byte scan of a backup and of the plaintext export). DELETE the CF-12 opt-in gate + `SyncGateOptIn` +
   `E2EELaunchKeyCache`; the `KeychainTestTripwire`'s E2EE leaves adjust to the new account names. **Her migration
   hook** (§11; batch 2 runs it): a one-shot `migrateSyncCustodyToStoreScope` that re-scopes the legacy plain/gated
   items and aligns them to the library key's custody — write it now behind a seam.
2. **The key file, format 2** (§3.5): the five new fields; `formatVersion = 2`; format-1 files read as "no master copy,
   no iCloud copy, unknown descriptor" (pin). Per-fingerprint NAMING beside the store and in backup folders; legacy
   `variorum-keys.json` read for the store's current key when no fingerprint file exists; `StoreBackup.copyKeyEnvelope`
   writes the fingerprint-named file and NEVER overwrites a file whose fingerprint differs (pin: two keys' files coexist;
   snapshots gain the fingerprint in their filename; `existingBackups` accepts both names). **No code path rewrites a
   backup folder's key file after it is written.** This batch lands the FORMAT + the `masterBox(key:under:)` /
   `unwrapKey(master:)` and `appleBox(key:under:)` / `unwrapKey(apple:)` roads; enrollment/setup (batch 3) write them.
3. **Custody per STORE ID:** the bound item and the gated item accounts keyed by the key file's `storeID` (the scope
   discriminator kept as a prefix: `<scope>-<storeID>-bound` / `-biometric`); a TN3137-style read-legacy → re-add →
   verify → delete-legacy migration exactly like `StoreKeyKeychain.load`'s road (pin: a legacy item migrates once; a
   second store on the same Mac never collides).
4. **Device-bound session tokens:** `KeychainAuthStorage` moves to the data-protection keychain with
   `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` under a `-bound` account, the same migration shape; the
   `KeychainPartitionTests` structural pin extends to it. (A migrated Mac signs in again — recorded, not a bug.)
5. **The absent-store route** (§3.7): `StoreLaunchRoute.openResettingModeToAuto` → `.libraryMissing`; `AppBootstrap`
   renders the three-door face (copy §3 "Library file missing"); "Start a New Library" mints under a NEW store ID; the
   lock never resets (red pin on both targets: a demanded mode over an absent store no longer persists a mode change
   and never opens a pullable library).
**1a's gate:** `swift test` + the touched Mac suites + the tutorial spine green; the iOS target builds; LIVE STATUS per
item. Commit per item, push after each.

**1b — the PROTOCOL event (the ONE §12 lockstep, marker 7 → 8; drafted and pinned here, DEPLOYED by her):**
1. **The vault's additive columns** (§3.10): `master_wrapped_by_apple_held text`, `apple_key_id text`,
   `key_proof_hash text`, `corpus_previous_wrapped_by_master text` (all nullable) in a NEW file
   `Server/supabase/11_pre13x_postures.sql`; `KeyVaultFormat` gains the three optional fields (format version STAYS 1 —
   additive; pin: a format-1 vault without them decodes); `KeyVaultWireRow` maps them; the previous-key field is NULL
   outside a rotation (pin the absence).
2. **The key proof:** `KeyProof.token(master:)` (32 bytes, base64 on the wire); the server stores `SHA-256(token)` hex.
   `sync_push(batch, active_key_id, key_proof)`, `sync_pull(since_seq, active_key_id, max_rows, for_device, key_proof)`,
   `sync_purge_execute(rows, active_key_id, key_proof)` and `account_data_truncate(active_key_id, key_proof)` and the NEW `sync_reencrypt(rows jsonb, active_key_id text,
   key_proof text)` (payload replaced where `sync_version` matches; a new `server_seq`; the version NOT bumped;
   mismatches returned for retry; `variorum_definer`-owned) REFUSE with
   a typed marker `VARIORUM_KEY_PROOF_REQUIRED` unless `sha256(key_proof) = key_vault.key_proof_hash` (constant-time
   compare); a NULL hash accepts the FIRST proof and stores its hash (the migration arm — hers only, pre-launch); the
   OLD signatures are DROPPED FIRST in the file (the 14c precedent — no unfenced door survives).
   `key_vault_update(payload jsonb, expected_revision int, key_proof text)` SECURITY DEFINER, `variorum_definer`-owned
   like the data RPCs, carrying the revision CAS inside; it MAY replace `key_proof_hash` when the call carries the
   CURRENT proof (pin: a call with the old proof after a rotation is refused); the client's PostgREST PATCH is replaced
   by it (`KeyVaultClient.updateVault`); vault CREATE stays a session-only insert that MUST carry the hash. **No RPC
   parameter may shadow a column it writes** (the 13j rule). The marker bump is the file's LAST statement.
3. **The client:** `SyncSchema.lockstepVersion = 8`; `SyncTransport`/`SupabaseTransport` pass `key_proof` from the
   engine's key provider (`SyncEncryptionKeys` gains `keyProof`); `VaultEnrollment`/setup compute and land the hash; the
   FAKE SERVER enforces the proof and the fence exactly as the SQL does — pins: a session without the proof cannot push,
   pull, purge, truncate or update the vault, CAN fetch it, CAN delete the account; the wrong proof refuses; the
   NULL-hash first write lands once; the right `active_key_id` without the proof deletes nothing. `AuthRLSDDLTests` pins
   the DDL ↔ registry ↔ `lockstepVersion` together; `SerializerCompletenessTests` classifies the new columns.
4. **The deploy checklist** (`notes/plans/pre-13x-deploy-checklist.md`): the 13j choreography — A1 backup rail; run
   `11_…sql` on the mirror in HER window (author-only; the `!` road); verify `sync_schema_version()` = 8, the three
   columns, the RPC signatures, the grant sweep (`maintenance/14c-post-deploy-grant-sweep.sql`); her installed marker-7
   app then visibly refuses until batch 2's install — so the deploy is scheduled immediately BEFORE batch 2's migration
   + install, never earlier.
**1b's gate:** the convergence suites + the two-user suites green against the fake server with the proof; the DDL pin;
`swift test` green; NO live round (the mirror is marker 7 until her window). Record + push.

**What batch 1 hands to batch 2:** the migration hooks (1a.1, 1a.3, 1a.4) unrun; the deploy checklist; the key-file
roads unused until enrollment writes them; ledger rows 6–9, 12–14, 18 for U3.

### BATCH 2 → 5 BRIEFS
Written by the orchestrator at each seam, from §4, §5, §7, §12 and §15, in this file's §19 — never from the history file.

### BATCH RECORDS (appended by each implementer; newest at the bottom)
*(batch 0's record lives in the history file, Part II; batch 0b's in its own plan.)*
