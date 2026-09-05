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
**Do:** the batch named NEXT in §18's LIVE STATUS, per its brief in §19. **Verify by:** §15's per-batch gates — each batch's drills are created, run and recorded by its
IMPLEMENTER in §19's batch record; the ladder's cold reviewers check that they were the right drills and re-run what
they doubt; the orchestrator adjudicates from the records and never runs suites itself (its context stays clean);
the two drills; the book walked against the build by the closing ladder's reviewer (§18, condition vii); her
acceptance walk on both devices. **Never** read the history file to decide a mechanism — if this
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
   re-reads and retries on top (the last change wins), and the other device learns on its next open (the vault road).
10. **Three acts for users, no more:** *Change Passphrase / Regenerate Twelve Words* — **a CONVENIENCE act, never a
    security act**: a re-wrap of the same keys for when YOU forgot the word or want another; other devices keep
    syncing; the new word works on them at once online (through the vault) and each stops taking the old one once the
    new one has been used there; until then a DISMISSABLE banner nudges at every open (a device you hold but have not
    given the new word to is worth a second look); the copy says so and points a suspected leak at the checkbox. **An Always-ask device is the one exception to "keep syncing":** it
    holds no master key, so opened with a retired word it reads and edits but does NOT sync until the new word is typed
    there — its banner says so; it keeps the DERIVED wrapping key in session memory (never the typed word) so a vault
    read after connectivity returns can fetch the master, and a relock drops it.
    **A retired word opens a device you hold but authorizes no key act:** the key doors' passphrase re-auth is checked
    against the SERVER's current copy, never the local key file, so the old word is refused there (Touch ID passes;
    forgot → Touch ID or the words). *Replace All Keys* — the security act (the switch's key half — for a secret that may have been USED
    or a device that may be in someone's hands; four entrances: its own door, the checkbox on the two re-wrap doors,
    the checkbox on the door for a new passphrase too, and entering Castle; every device re-keys its library as it
    follows, which is what retires an old word everywhere). *Delete the account and set sync up again* (the recovery
    road and the compromised-account road). No standalone library-key door.
11. **Backups are never rewritten after they are written** — not at a posture change, a passphrase change or a
    words regeneration. Beside the live library the key file is named by key fingerprint; in a backup folder EVERY
    SNAPSHOT has its own key file, written with it and never rewritten (`variorum-backup-<stamp>-<fp8>.sqlite` +
    `variorum-backup-<stamp>-<fp8>.keys.json`), so a backup opens with the passphrase and the twelve words you had
    the day it was made — her call, over one key file per library key. The
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
    *Encryption Explained*, which joins the seeded-book dedupe facts so two devices never seed two of it.** Two vocabulary registers: everyday surfaces name no key; the book and the FAQ name every
    key and define "wrapped" on first use; "box" appears in no user text. Every Castle surface that offers Touch ID
    says where that copy of the key sits. The compromise rule (four lines) appears in both postures.
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
30. **Replace All Keys never re-mints the iCloud key.** In Standard the new master is re-wrapped under the SAME A, so
    someone inside the Apple account is NOT shut out by it — that case is answered by entering Castle (no copy under
    A) or by Apple's own account security, and every surface that names the case says so: the compromise rule's
    fourth line, the Replace All Keys screen, Chapters 6 and 7, the lost-device and Apple-account FAQ entries. The
    presence of the vault's A-wrapped copy of M′ after a Standard Replace All Keys is PINNED, so the honest sentence is
    tested, never assumed.
31. **Which key a row is under is told by its `server_seq`.** The shipped `e1:` envelope carries no key id and the
    mirror has no per-row key column, so the vault records the rotation: `key_vault_update`, when the payload it lands
    sets a previous corpus key, takes the next value of the server sequence INSIDE its own transaction with the vault
    row locked and stores it as `rotation_started_seq` (one of SIX nullable columns — `corpus_previous_key_id` names the
    previous key for the AAD and its twin `corpus_previous_wrapped_by_master` carries it, the existing id/wrap pair's
    shape; never an id packed inside a value); every data RPC reads the vault row
    under a share lock for its fence and proof checks, so a push that passed the old check commits — and takes its
    seqs — before the vault write, never after. The rule every client applies: a row below the rotation seq is under
    the previous corpus key; every other row is under the current one. What remains is a pull bounded by that seq;
    completion is "no row of mine below it," and the completing write clears the previous key and the seq together.
    A follower decrypts by the same rule. Every device re-downloads the corpus once per rotation, seq-recorded only.
    Under 13y's per-tenant sequence the rotation seq is per tenant (a hand-forward).
32. **One rotation at a time.** Replace All Keys and Use Castle refuse while the vault carries a previous corpus key —
    at the door AND inside `key_vault_update` — with one sentence naming the device, the day and the rows to go; the
    acting device resumes through its marker and never starts a second; any device holding the new master can finish.
    A re-wrap mid-rotation (a passphrase change, a words regeneration) sends the vault whole and carries the SAME
    previous key through — that is not a second rotation and is allowed; only a payload setting a DIFFERENT previous
    key refuses.

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
| **posture** | DERIVED, never a setting: the ACCOUNT is Standard ⇔ the vault has an iCloud copy; a LOCAL-ONLY library is Standard ⇔ its key file has one — or, with no iCloud copy landed yet, its raw key sits in the SILENT bound item (a Standard library whose Apple copy has not landed: the waiting / exposed state, never a lock); Castle is ENTERED, and entering moves the raw key behind Touch ID or nowhere, so the custody SHAPE tells the two apart by presence alone, no unlock; an enrolled library's key file must agree with the vault (reconciled at every ready launch/unlock and at enrollment) | nowhere else |
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
Touch ID, or the master already in this device's custody reach L and M.

### 3.3 The sync keys live in custody, never in the library file
The master key, the corpus key (+ id), the dormant journal class key (+ id) and the device identity live in this
device's per-store custody beside the library key — the same item family, the same shape: **Standard:** the silent
device-only item; **Castle:** the biometric item (`.biometryCurrentSet`); **Always ask:** no item — the sync keys are
held in memory for the unlocked session, obtained at unlock from the typed secret through the vault when online; an
offline unlock keeps the DERIVED wrapping key in session memory (never the typed word) so the vault read runs when
connectivity returns, and a relock drops it (offline there is no network to sync with; a retired word opens such a
device but the vault's master copy is under the new one — it reads and edits and does not sync until the new word is
typed there, decision 10). `SyncKeyProviding` reads custody (or the session); a LOCKED library reads
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
| master key M | one random key per ACCOUNT; the right to sync | RAW in each enrolled device's custody (the silent item) — never in a file or a backup; WRAPPED in the vault under P, W, A | C; the proof; L via the key file's M copy | any enrolled device's unlocked app; anyone in your iCloud (the vault's A copy, with a session) | REPLACED: M′ wrapped under P and W only; the old master refused by the server for push, pull, vault writes and purge | the switch; Replace All Keys; delete-and-set-up-again | the server accepts only M′; every device types P or W once; old key files' master copies are dead |
| corpus key C | the key every synced text is encrypted under | RAW in custody beside M; wrapped under M in the vault | every row of ciphertext on the server and in the server's own backups | same as M | REPLACED and every row re-encrypted under C′; the old C — wherever it survives (old custody; an old iCloud-account holder) — decrypts only pre-switch ciphertext | the switch; Replace All Keys; delete-and-set-up-again | all devices re-pull; the server's own backups keep old-C ciphertext of PRE-switch writing only |
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
holder's right to sync but leaves the corpus readable by a breach + anyone who held the old corpus key (an old
device's custody; an in-iCloud party during Standard). The CORPUS key alone is pointless — its new wrapped copy sits
under the master, which old custody still holds. A PASSPHRASE or WORDS change re-wraps —
a convenience act: it changes the word that opens the server's copy and this device's key file; a leaked word still
opens another enrolled device in hand until the new word is used there, and it opens old backups' writing (never their
sync — copies hold no sync keys). Replace All Keys is the security act: every device re-keys its library as it
follows, which is what retires an old word everywhere. **In Standard no rotation shuts out someone inside the Apple
account** — the new master is re-wrapped under the same A; only entering Castle removes the copy under it, and every
surface that names the case says so (decision 30). **So:**

| act | what it rotates | other devices | when |
|---|---|---|---|
| **Change Passphrase / Regenerate Twelve Words** | nothing — a re-wrap of the same keys under the new word | keep syncing; take the new word at once online; stop taking the old one once the new one is used there | you forgot it or want another — convenience, not security |
| **Replace All Keys** (= the key half of entering Castle) | the master, the corpus key (every row re-encrypted), and — device by device as each follows — every library key | type the passphrase once, re-key their own library, pull | someone may have USED a secret, or had one of your devices unlocked — NEVER the answer to an Apple-account intruder in Standard (decision 30: the new master is re-wrapped under the same A) |
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
`variorum-keys.json` reads as format 1 for the store's current key). The store id is read from ANY key file beside the
store (every key file of one library carries the same id); the key file for a KEY is chosen by FINGERPRINT — custody's
raw key names it directly (zero derivations), and with no custody every fingerprint file beside the store is tried
newest-first, the one whose unwrapped key opens the file winning; nothing is set aside or deleted (a folder holds one
per library key it has ever held, §6). Written at enrollment, at every re-wrap, at every
posture change — of the LIVE library's key file only; in a backup folder each snapshot carries its own key file, written
with it (decision 11). Format 1 files read as "no master copy, no iCloud copy,
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
**THE VAULT ROAD — the new word works everywhere; the old word retires by use.** After a passphrase (or words) change on
another device, the NEW word opens this device online at once through the vault road and, on success, re-wraps this
device's local copy — from then on only the new word opens it here. Until the new word has been used here, the OLD
word still opens this device from its local copy, online or offline; a dismissable banner nudges at every open until
the new word has been used here. **The key doors are stricter than the lobby:** their passphrase re-auth (change
passphrase, regenerate, Replace All Keys, the switches — all online acts) derives the typed word and checks it against
the VAULT's current copy, never the local key file — a retired word is refused there even where it still opens the
library; Touch ID passes; forgot → Touch ID or the words. A passphrase or words change is a convenience act (§1.10);
the security act is Replace All Keys, one tick away on the same screen.
**THE OWNER DISTINCTION.** If the vault's corpus key id DIFFERS from the key file's recorded one, the local
copy stands as a road, and after unlock the device lands in one of two states — told apart by comparing the
library's rows' `owner_id` stamp (the account that last synced them) with the signed-in account's user id: **same owner ⇒ the account's keys
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
structure to a bare session. Cost: six nullable columns on `key_vault` (`master_wrapped_by_apple_held`,
`apple_key_id`, `key_proof_hash`, `corpus_previous_key_id`, `corpus_previous_wrapped_by_master`, `rotation_started_seq`) and a `key_proof` parameter on the RPCs — **ONE §12 lockstep event, marker 7 → 8**,
in her deploy window (the 13j choreography). The fake-server harness enforces the proof exactly as the SQL does.
**Which key a row is under — the rotation seq (decision 31).** `key_vault_update`, when the payload it lands sets a
previous corpus key, takes `nextval` of the server sequence INSIDE its own transaction with the vault row locked
`FOR UPDATE` and records it as `rotation_started_seq`; `sync_push`, `sync_pull`, `sync_reencrypt`, `sync_purge_execute`
and `account_data_truncate` read the vault row `FOR SHARE` for their fence and proof checks, so a push that passed the
old check commits — and takes its seqs — BEFORE the vault write, never after it. The rule every client applies: a row
whose `server_seq` is below the rotation seq is under the previous corpus key; every other row is under the current
one. What remains to re-encrypt is a pull bounded by that seq; the rotation is complete when a device at head finds no
row of its own below it, and that device's clearing write NULLs the previous key and the seq together (pin the absence
of both outside a rotation). A follower decrypts by the same rule. Every device re-downloads the corpus once per
rotation, seq-recorded only. Under 13y's per-tenant sequence the rotation seq is per tenant (hand-forward). **One
rotation at a time (decision 32):** `key_vault_update` refuses a payload that would set a previous key while one is
present (`VARIORUM_ROTATION_IN_PROGRESS`), and the doors refuse before asking. **The read RPCs too:** `sync_horizon`
and `sync_purge_ledger` take the proof as well — a session without the keys gets nothing from the mirror at all, a seq
included. **The insert arm:** a `BEFORE INSERT` trigger on `key_vault` rejects a NULL `key_proof_hash` (a CHECK would
refuse the author's existing row until her first round lands the hash — the NULL-hash arm exists for that row alone);
that arm's first write takes the row `FOR UPDATE` — re-read under the lock, set only if still NULL — so two racing
first rounds resolve deterministically, never by the deadlock detector. `sync_reencrypt` is entitlement-gated exactly
as a push (a rotation writes ciphertext, and an unentitled account cannot pull to head, so §4 step 1 refuses first);
whether a LAPSED account may rotate at all is 13t's product call (a hand-forward).
`key_vault_update` scopes to `auth.uid()` like the data RPCs (the 14c guard). **The table-level UPDATE road CLOSES with
it:** the `key_vault_owner_update` policy is DROPPED and UPDATE on `key_vault` is REVOKED from `authenticated` (the
shipped 14b grant) — otherwise a bare session's PostgREST PATCH is a proof-free write to every vault column, the proof
hash included, and the proof protects nothing; `variorum_definer` gets the UPDATE grant and a policy of its own (the
`device_cursor` pattern), so after creation the ONLY write road into the vault is the RPC that checks the proof. A live
probe at the deploy proves the PATCH refused. **The proof is a bearer token,** presented
in the request BODY only — never a URL or a header that lands in a gateway log; the server sees it on every call and
keeps only its hash, so a server compromise or a log capture yields the right to MUTATE the mirror without the right to
read it — the account-password class, and the privacy brief's disclosure list says so.

---

## 4. ENTERING AND LEAVING CASTLE (the two acts, step by step)

**Standard → Castle (an open library; signed in and online if sync is on; the ceremony: passphrase set if none, twelve
words generated + confirmed if none, the floor read once; Touch ID or the passphrase — checked against the vault's
current copy — confirms):**
1. **Pull to head.** Refuse offline, with a non-empty outbox, or while the vault carries a previous corpus key (decision
   32 — a rotation is still finishing; the sentence names the device, the day and the rows to go).
2. **Rotate the sync keys** (sync users only): mint M′ and C′; rewrite the vault in ONE `key_vault_update` authorized
   by the OLD proof — M′ under P and under W (no iCloud copy), C′ under M′, **the old C under M′ (the previous corpus
   key, for the rotation's duration)**, the proof hash replaced, the corpus key id advanced (the fence), the rotation seq recorded (decision 31). M′ and C′ into
   this device's custody; the old C kept there as the previous key until step 3 completes.
3. **Re-encrypt the server copy:** every row still under the old key — every row of this account BELOW the rotation
   seq (decision 31) — is rewritten under C′ through `sync_reencrypt` — version-neutral, no truncation; a row whose
   version moved is pulled and retried; the fence refuses old-key pushes and pulls from then on. **Any device holding
   M′ can do this work** (it reads old-key rows with the previous corpus key, told apart by the seq); the rotation is
   COMPLETE when a device at head sees no row of its own below the rotation seq, and that device clears the previous
   key AND the seq from the vault (a proof-authorized write) and the previous key from its custody.
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
| **Change passphrase** | an OPEN library; online if enrolled (a server write) | Standard: the current P if known; *forgot it?* → a plain confirm (this device holds the keys). Castle: the current P — verified against the VAULT's copy, so a word retired elsewhere is refused here even if it still opened the lobby; *forgot it?* → Touch ID on a gated device, else the twelve words (an always-ask device typed P to open). The words authorize everywhere | a RE-WRAP: M under the new P in the vault (one CAS write under the proof; a fresh KDF salt/descriptor); L under the new P in THIS device's key file. Nothing else — no backup folder, no other device's key file. The checkbox *"Also replace my keys"* runs Replace All Keys | keep syncing (they hold M); the new word opens them at once online (the vault road) and re-wraps their copy on first use; the old word keeps opening them until then; a one-time notice names the change (the vault road) |
| **Regenerate twelve words** | same (online if enrolled) | same | the W copies replaced in the vault and this key file; the old words dead the moment the new are confirmed; the same checkbox | the new words work there at once online; their local W copy re-lands when the new words are typed there; the old words keep opening them until then (the vault road) |
| **Standard → Castle** | §4 | §4 | §4 | §7 |
| **Castle → Standard** | §4 | §4 | §4 | §7 |
| **Replace All Keys** | an open, ENROLLED library, signed in, online, holding the CURRENT master (the door checks the key file's recorded corpus key id against the vault before offering itself; else *"this account's keys don't match this library"*); refused while the vault carries a previous corpus key — a rotation still finishing (decision 32) | Castle: Touch ID, or P (or W) verified against the vault's copy — a retired word is refused. Standard: P if one is set (the same check), else a plain confirm | §4's steps 1–4 without the posture change: M′, C′, the vault rewritten under the same posture's wrappers (+ the iCloud copy again in Standard), the proof replaced under the old proof, every row re-pushed under C′, THIS library re-keyed; the checkbox *"Also choose a new passphrase"*; the marker. The server refuses a stale proof regardless of the front check | the same follow as entering Castle: type P or W once, re-key own library, pull — asked once even in Standard, where the iCloud key could hand M′ over silently (her call: *"it's making sure you have it"*) |
| **Delete account** | signed in (enrolled or not) | account password + typed phrase + a FRESH re-authentication | server copy + vault + login gone (`account_purge`); LOCAL COPIES UNTOUCHED; the app signs out; the keys stay in this device's custody; A stays in iCloud | lose sync; keep everything local; a later account adopts them at setup |
| **Sign out everywhere** | signed in | — (the mitigation for a stolen password or session; `signOut(scope: global)`) | every session revoked; keys untouched | sign in again |
| **Sign out** | — | — | clears this device's tokens; the keys stay in this device's custody (behind the library key's own gate) | — |
| **Plaintext `.sqlite` export** | an open library | Castle: P (never Touch ID alone). Standard: P if set, else a plain confirm | a decrypted copy WITHOUT the local sync tables (§3.3) to a user-chosen location; a plain warning; never scheduled, never into the backups folder | — |
| **Plaintext `.md` export** | — | unchanged (13l; the scheduled insurance opt-in, warned under Castle); not gated in Castle | — | — |
| **Lock Now / re-lock** | Castle | — | tears down services, drops key material (`StoreBinding.lock`) | — |

**What the account password can do, in BOTH postures:** sign in · delete the account · sign out everywhere · cancel —
and, on an account that has never turned on sync, CREATE the vault (racing sync setup). That last is loud and
survivable: the owner's passphrase never opens a vault someone else made, the Turn On Sync door says so (copy §4), and
the remedy is deleting the account.
It can NEVER open a library, read or write the mirror, purge, change a passphrase, change a posture, or export.
**Its worst case is the loud one — the account deleted — which every local copy survives.**

---

## 6. BACKUPS UNDER THE MODEL
The 13l backups are ciphertext + key file(s), launch-if-due + daily, 14 dailies + 4 weeklies (`StoreBackup.swift`),
made through GRDB `backup(to:)` from an OPEN keyed connection — under Castle they run **at the first unlock of the day
if due**, plus a keyless byte-copy at lock time when due (the app's own folder only). **A backup is writing, never a
device:** the file carries no sync key and no device identity (§3.3). Snapshots carry the key fingerprint in their
filename (`variorum-backup-<stamp>-<fp8>.sqlite`); each snapshot has ITS OWN key file beside it
(`variorum-backup-<stamp>-<fp8>.keys.json`, written with the snapshot and **NEVER rewritten**), so it opens with the
wrappers of its day; a fingerprint-named key file in a folder serves the snapshots made before this rule (1a's
shape — never overwritten by a different key's file), and legacy `variorum-keys.json` serves legacy snapshots. **A backup folder is never rewritten after it is written** — not at a
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
once: the vault's CAS refuses the second; it re-reads and retries (the last change wins). 6. An Always-ask phone
(decision 10's exception): opened with the OLD word it reads and edits but does not sync until the NEW word is typed
there — its banner says so. 7. Two devices SWITCHING posture at once: the second's CAS refuse re-reads — the account
already moved ⇒ the retry is the follow, never a second rotation. The same steps serve Standard and a regenerated
phrase.
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
- **The compromise rule (four lines)**, both postures: a passphrase or words only SEEN → change / regenerate; a leaked
  session or account password → sign out everywhere; someone who may HOLD your keys (an unlocked enrolled device plus
  your account password) → Replace All Keys; in Standard, someone inside your Apple account → secure the Apple account
  with Apple's tools, or enter Castle — Replace All Keys alone does not shut them out there (decision 30); the ACCOUNT
  itself in someone's hands → delete it and set sync up again.
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
- **The vault road, by use:** after a change elsewhere, the new word opens a device online at once and re-wraps its copy; the
  old word opens it until then (online and offline); the banner shows at every open until the new word is used there and
  is dismissable; a typo never writes a copy (the vault unwrap must succeed first). **A retired word is refused at every
  key door's re-auth** (change passphrase, regenerate, Replace All Keys, the switches) on a device it still opens; Touch
  ID passes; the words pass.
- **The owner distinction:** a rotated same-owner account FOLLOWS with an ordinary pull and no re-stamp; a
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
  the delete offer removes only the app's own pre-switch snapshots and never a post-switch one (pairs — the snapshot
  and its key file); a second key's file never replaces the first; each snapshot's key file is written with it and
  never rewritten (a passphrase change between two snapshots leaves the earlier pair byte-identical and the later pair
  under the new word — pin both); a restored snapshot enrolls with a fresh identity and never syncs before enrolling.
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
- **The rotation seq (decision 31):** a row below the rotation seq decrypts under the previous key and one above it
  under the current; a push that read the old proof and committed before the vault write lands BELOW the seq (the fake
  server serializes the vault row exactly as the SQL's locks do); the remainder pull is bounded by the seq; completion
  NULLs the previous key, its id AND the seq together; a follower re-downloads the corpus once, seq-recorded only, with zero
  conflict variants.
- **One rotation at a time (decision 32):** Replace All Keys and Use Castle refuse while a previous key is present, at
  the door AND at `key_vault_update`; the acting device's marker resumes; a second device holding M′ finishes.
- **Always ask (decision 10's exception):** opened with a retired word it reads and edits and does not sync; the
  banner names it; an offline unlock followed by connectivity syncs (the derived key in session memory); a relock
  drops the derived key; the typed word is never retained.
- **Standard Replace All Keys (decision 30):** the vault's iCloud-wrapped copy of M′ EXISTS after it — pin the
  PRESENCE, so the copy's honest sentence is tested, not assumed; entering Castle pins the absence.
- **The read RPCs and the insert arm:** a session without the proof gets nothing from `sync_horizon` or
  `sync_purge_ledger`; a new vault with a NULL hash is refused at insert; the proof travels in the body only.
- **The vault's table-level write road is CLOSED:** a session's direct PostgREST PATCH on `key_vault` is refused
  (permission denied — the DDL pin reads the policy and grant set; the deploy's live probe proves it on the mirror);
  the only post-creation write is `key_vault_update` under the proof; INSERT (creation) and SELECT (the wrapped copies)
  stay session-only; DELETE has no road but `account_purge`.
- The convergence suites gain §7's choreography against the fake server (which enforces the proof, the fence,
  `sync_reencrypt`, the rotation seq and the in-progress refusal). Both drills re-run: the 13p migration drill on a byte-copy of her real store, and the 13l restore
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
re-keys if Standard-born into Castle). 7. Old backups after a deleted-then-recreated account hold no keys; a restored one enrolls into whatever account is signed in — a different
owner ⇒ the adopt road ("set up sync again"). 8. Backups run at
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
turned on sync. 35. **Replace All Keys in Standard leaves an Apple-account holder able to unwrap the new master** — the
copy says so; the remedy is Castle or Apple's account security (decision 30). 36. **Macs without Touch ID** (a Mac mini,
a closed MacBook on an external keyboard): the Castle ceremony offers Always ask only where `LAContext` reports no
biometry; an existing biometric item on a lidded MacBook falls to the passphrase road for that open. 37. **A re-minted
device identity with a non-zero cursor is a RETURNER** to the purge ledger (13j's fence) — reconciled at its first round,
never stranded. 38. **Sign Out Everywhere revokes refresh tokens;** an access token already issued lives to its expiry
(≤ 1 h — the project's default access-token lifetime; a signed JWT is checked by signature and expiry, never against a
revocation list, so a global sign-out revokes the refresh tokens and cannot recall a token already in hand) — inert
against the corpus (no proof), able only to read the vault's wrapped copies and, through a custom client, to call
`account_purge` — loud and survivable, the disclosed account-password class; ACCEPTED as it stands (her word); 13y's
recently-re-authenticated-session guard on the destructive RPCs closes the deletion arm; the lifetime stays as it is
(her word: *"I'll keep the lifetime as is"*). 39. **A CAS refuse at a posture switch re-reads:** if the account already changed posture,
the retry is the follow, never a second rotation. 40. **A rotation re-delivers the whole corpus to every device once,**
seq-recorded only — the pull-to-head memory shape at corpus scale, once per rotation. 41. **The biometric custody item is
read ONCE per unlock** — L, M, C, J and the device identity in one gated read, one Touch ID prompt. 42. **A third crash
point is pinned:** between the swap and custody (the silent custody still holds M′; the new key file's master copy
opens the re-keyed file; the marker resumes at step 5). 43. **The account password's fourth power on a vault-less
account** is creating the vault (racing sync setup) — loud: the owner's passphrase never opens it, the Turn On Sync door
says so, and the remedy is deletion. 44. **Snapshot pairs (decision 11 as ruled):** a snapshot taken after a passphrase
change or a words regeneration opens OFFLINE with the new word, because its own key file was written with it; the
earlier pairs keep their day's words; the master copy and, online, the current passphrase through the vault open every
snapshot regardless. 45. **A refused Apple landing never makes Castle:** a local-only key file with no `apple` copy
derives Castle only when the raw key's custody is the gated item or nowhere (Castle was ENTERED); with the raw key in
the silent bound item it is Standard-waiting — the reconcile keeps trying to land A, the exposed nudge speaks, and the
route tries the landing before it derives. 46. **"iCloud Keychain is off" is undetectable on macOS** (a synchronizable
add succeeds with it off; no toggle API; no arrival notification): the exposed tier fires only when A is UNREADABLE;
the covered tier's sentence hedges ("as far as this Mac can tell"), and a second device's arrival (Q3) is the only
proof.

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
- **3 — the doors:** setup adopts (re-stamp + re-init) and the existing-words rule; enroll (incl. the Standard-born-into-Castle re-key and the
  follow-vs-adopt discriminator); change passphrase + regenerate as re-wraps with their checkboxes; **Replace All
  Keys**; sign out everywhere; deletion by account password (reachable unenrolled); the plaintext export + the
  reconciliation note for 13x; the 12-character floor; the descriptor floor.
- **4 — lobby + cross-device:** the vault road (the new word everywhere, the old retiring by use) and the owner distinction; the change
  notice; the follow notices; the phone's faces; the convergence pins of §12 incl. her attacker scenario.
- **5 — copy + tutorial chapter + *Encryption Explained* (in the seeded-book dedupe) + runbook + parity line + the
  deletions + the privacy-policy brief + the 13y / 13x hand-forwards; the lost-device FAQ entry; the ceremonies'
  progress indicator (an ORIGINAL animated indicator with movement — her example: a line with a few black dots
  travelling back and forth — never the system spinner).**
Then the cold-review ladder (Fable reviewers on every round; each walks §3.4), the two drills, the book walked
sentence by sentence against the build by the closing ladder's reviewer (§18's condition vii), her acceptance walk
on both devices, the
`/Applications` refresh and the phone install. **The delete-and-set-up-again road runs on the DEV
store and the fake server only.**

## 16. OPEN
Nothing in the design. **Ruled at her word (the kickoff evening): ONE phase** — the drills as gates, the ladder at the
end (13p's shape); no split. **The lockstep deploy (marker 7 → 8) and the refreshed installs are PRE-AUTHORIZED:** her
PAT is stored (`.env.supabase.local`, the 9c arrangement), so the orchestrator runs the mirror deploy at the window
without waiting for her at the keyboard (the `!` road if the permission classifier blocks the mutating call — the 13j
precedent), then the Mac Release refresh behind the A1 backup rail; her migration's one-time passphrase confirm on
each device and the PHONE install (Xcode + her device) still need her present. **Her acts pending:** Q3's phone leg at
the batch 2 sitting (five minutes on both devices); the passphrase confirm on both devices at migration; her phone's
move to Castle to expect; ladder adjudications and any book sentence not plainly a defect as they arise; the
acceptance walk at the end; 13s re-voices the copy later.

## 17. CANON DELTAS AT CLOSEOUT AND HAND-FORWARDS
AppSpec §14 (this phase's delta, incl. the bridge retirement's canon changes applied in place 2026-09-04) + §7's
`setting`/`sync_state` note (the sync keys and the device identity live in per-store custody beside the library key, never in the file; the key file beside the store; entering Castle rotates the
library key, the master and the corpus key); SyncSpec §3 (the key provider reads the store; the vault read before
unlock; the key proof on every mutating RPC but whole-account deletion) + §12's running record (marker 7 → 8);
CoreDescription untouched except §8's 9b mention (retired with the bridge); the 13p constitution's R13p-5/6/7/9
recorded as superseded; `pre-13u-memo-security-shapes.md` superseded; KnownIssues rows resolved; 13x's row gains the
open door's reconciliation cases (§14.13) and the same-fingerprint second look; 13y's row carries the adopt-road
convergence pin under per-tenant `server_seq`; MobileSoul parity line; QUESTIONS #81 / #87 dissolved / re-listed.
**Handed to 18b (her candidate, unslotted — restore across devices):** a restore surface for copies OUTSIDE the app's
folders (Time Machine, another machine — 13x's open door is its first half), restoring on a different device, and the
surface saying which credential opens which backup; and the recorded idea of HISTORICAL masters (a chain of old
masters wrapped under the current secrets so the current passphrase opens every old backup — declined for v1: the
twelve words already cover it, and the chain costs a re-wrap of every entry at each secret change).

---

## 18. EXECUTION RECORD (the running record the `/architect-phase` skill requires)

### Acceptance units
| unit | kind | evidence that closes it |
|---|---|---|
| U0 batch 0 — measurements | spike | **DONE** — `notes/plans/pre-13x-spike-memo.md` |
| U1 batch 0b — the bridge retirement | operations | **DONE 2026-09-04** — `notes/plans/pre-13x-bridge-retirement.md` |
| U2 batch 1 (1a + 1b) — substrate + the lockstep event | sync/protocol (phase-sized) | convergence suites incl. the proof; ONE live two-device round on the real mirror after her deploy |
| U3 batch 2 — postures + entering/leaving Castle | custody (phase-sized) | four drills: the Standard new-device road (nothing typed); the Castle new-device road (passphrase once); Standard → Castle on a byte-copy of her store with a Standard sibling device following (an old snapshot cannot enroll; every row under C′); Castle → Standard |
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
- **U2 batch 1a — DONE** (`10079de2`; the record + the orchestrator adjudication under §19 BATCH RECORDS). **U2 batch 1b — DONE** (`12cd1767`; the record + the orchestrator adjudication under §19 BATCH RECORDS; U2 closes at the deploy window with its ONE live round). **U3 batch 2 — IN PROGRESS: 2b** (2a DONE `4b2eb646`, adjudicated; 2b a fresh Fable implementer on the REFINED 2b brief in §19 BATCH 2; its record under BATCH RECORDS — verify by `git log` before trusting). U3 — NOT-STARTED.
  U4 — NOT-STARTED. U5 — NOT-STARTED.

### THE LEDGER (every row owned)
| # | item | owner | status |
|---|---|---|---|
| 1 | the shared keychain access group on both targets | U0 → U2 | done at U0 (`a37f9cd`) |
| 2 | A crosses Mac ⇄ phone under the shared group (her two devices) | U0 → the batch 2 sitting | PENDING — five minutes on both devices at the batch 2 sitting (she is present for the migration anyway); needed before Standard's iCloud road is treated as verified, not before |
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
| 15 | the Standard-born-into-Castle enrollment re-key; the follow-vs-adopt discriminator (the owner distinction, Enroll, §7) | U4 | open |
| 16 | `key_vault_update` may replace the hash under the current proof; `sync_purge_execute` and `account_data_truncate` take the proof | U2 (1b) | open — MUST |
| 17 | Replace All Keys + its checkboxes; the stale-master front check; the same follow as the switch | U4 | open |
| 18 | the "Delete backups made before today" offer — the app's own folders; the outside-copies + Recently-Deleted sentences | U3 | open |
| 19 | her attacker scenario in the two-user suite; the no-ownership-change pin | U4 | open |
| 20 | the where-the-key-sits line on every Castle surface + the Standard mirror + the compromise rule (four lines) | U5 | open |
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
| 33 | the vault road by use + the dismissable change banner + the key doors' vault-checked re-auth; the un-followed device's state (banner, door lockout, the reused passphrase) | U4 | open |
| 34 | the rotation seq (decision 31): the fifth vault column; the vault row locked in every data RPC; the fake server's serialization; the bounded remainder pull; completion clears key + seq together | U2 (1b) → U3 → U4 | open — MUST |
| 35 | one rotation at a time (decision 32): the door refusal + the `key_vault_update` refusal + the sentence | U2 (1b) → U3 | open |
| 36 | the Always-ask exception (decision 10): the derived key in session memory; no sync on a retired word; the banner variant | U2 (1a) → U4 | open |
| 37 | Standard's honest limit (decision 30): the A-copy-of-M′ PRESENCE pin; the compromise rule's fourth line; the Replace All Keys screen, Chapters 6/7, the lost-device and Apple-account FAQ entries | U2 (1b) → U5 | open |
| 38 | the proof on `sync_horizon` / `sync_purge_ledger`; the NULL-hash `BEFORE INSERT` arm; `auth.uid()` scope on `key_vault_update`; the proof in the body only | U2 (1b) | open |
| 39 | one gated read per unlock for the biometric custody item (L, M, C, J, the identity — one Touch ID prompt); a re-minted identity with a non-zero cursor reconciled as a returner | U2 (1a) | open |
| 40 | the third crash point (between the swap and custody); a CAS refuse at a switch becomes the follow; Macs without Touch ID get Always ask only; the vault-less account's fourth account-password power said in copy | U3 | open |
| 41 | the vault's table-level UPDATE road CLOSED (drop `key_vault_owner_update`, revoke UPDATE from `authenticated`, the definer grant + policy) — the DDL pin + the deploy's live PATCH probe | U2 (1b) | open — MUST |
| 42 | one key file PER SNAPSHOT in backup folders (decision 11 as ruled): `StoreBackup` writes `…-<fp8>.keys.json` beside each snapshot at its time; `existingBackups` pairs them; the fingerprint-named folder file serves 1a-era snapshots; the delete offer and the restore surface handle pairs; the two §12 pins | U3 (batch 2, on 1a.2's naming) | open |

### The architect's sign-off conditions (the reasoning is in the history file)
(i) the key proof ships in this phase's lockstep event; (ii) the descriptor-floor and never-wrap-under-a-network-key
pins land in batch 1; (iii) A is observed crossing her two real devices under the shared group before any Standard copy
is written (Q3); (iv) Fable reviewers on every ladder round, each walking §3.4; the two drills on both devices; (v) the
honest boundaries in §2 and §14 survive 13s's re-voicing in substance; (vi) §3.4 holds at closeout with every "at the
switch" cell pinned; **(vii) THE BOOK IS THE ACCEPTANCE CHECKLIST: the closing ladder's FIRST cold reviewer walks
*Encryption Explained* (copy §7b) and the tutorial chapter (copy §7) sentence by sentence against the build as the
spine of its review — every sentence gets a verdict and the pin, drill or observation that makes it true, recorded
beside it; the orchestrator adjudicates the verdicts; a sentence the build does not agree with is presumed a DEFECT of
the build, never a copy edit — and any mismatch that is not plainly a defect goes to the author, in case the design
itself is what needs the word.**

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
   C (+id), J (+id) and the device identity. `SyncKeyProviding` reads custody (or the session under Always ask — which holds the DERIVED wrapping key for the
   session, never the typed word, so a vault read after an offline unlock can fetch the master when connectivity
   returns; a relock drops it — pin), synchronous by contract; a LOCKED library reads as no keys →
   `SyncError.encryptionKeysUnavailable` (pin). The biometric item is read ONCE per unlock — L, M, C, J and the identity
   in one gated read, one Touch ID prompt (pin: the `LAContext` is evaluated once per unlock). A re-minted identity (a
   wiped Keychain) with a non-zero `sync_state` cursor is a RETURNER to the purge ledger (13j's fence) — reconciled at
   its first round, never stranded (pin).
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
   `key_proof_hash text`, `corpus_previous_key_id text`, `corpus_previous_wrapped_by_master text`,
   `rotation_started_seq bigint` (all nullable — SIX; the previous key's id is its own column, the existing id/wrap
   pair's shape, never packed inside the value) in a NEW file `Server/supabase/11_pre13x_postures.sql`;
   `KeyVaultFormat` gains the optional fields (format version STAYS 1 — additive; pin: a format-1 vault without them
   decodes); `KeyVaultWireRow` maps them; the previous key, its id AND the rotation seq are NULL outside a rotation
   (pin the absence of all three, together).
2. **The key proof:** `KeyProof.token(master:)` (32 bytes, base64 on the wire); the server stores `SHA-256(token)` hex.
   `sync_push(batch, active_key_id, key_proof)`, `sync_pull(since_seq, active_key_id, max_rows, for_device, key_proof)`,
   `sync_purge_execute(rows, active_key_id, key_proof)`, `account_data_truncate(active_key_id, key_proof)` and the NEW `sync_reencrypt(rows jsonb, active_key_id text,
   key_proof text)` (payload replaced where `sync_version` matches; a new `server_seq`; the version NOT bumped;
   mismatches returned for retry; `variorum_definer`-owned) REFUSE with
   a typed marker `VARIORUM_KEY_PROOF_REQUIRED` unless `sha256(key_proof) = key_vault.key_proof_hash` (constant-time
   compare); a NULL hash accepts the FIRST proof and stores its hash (the migration arm — hers only, pre-launch); the
   OLD signatures are DROPPED FIRST in the file (the 14c precedent — no unfenced door survives).
   `key_vault_update(payload jsonb, expected_revision int, key_proof text)` SECURITY DEFINER, `variorum_definer`-owned
   like the data RPCs, carrying the revision CAS inside; it MAY replace `key_proof_hash` when the call carries the
   CURRENT proof (pin: a call with the old proof after a rotation is refused); the client's PostgREST PATCH is replaced
   by it (`KeyVaultClient.updateVault`); vault CREATE stays a session-only insert that MUST carry the hash — a `BEFORE
   INSERT` trigger rejects a NULL `key_proof_hash` (never a CHECK: the author's existing row stays NULL until her first
   round). **The vault row is the serialization point (decision 31):** `key_vault_update` locks it `FOR UPDATE` and,
   when its payload sets a previous corpus key, stores `nextval` of the server sequence as `rotation_started_seq` in
   the same transaction — and REFUSES (`VARIORUM_ROTATION_IN_PROGRESS`) when a DIFFERENT previous key is already
   present (decision 32; a re-wrap carrying the SAME previous key through is not a second rotation); the NULL-hash
   arm's first write re-reads the row `FOR UPDATE` and sets the hash only if still NULL; every data RPC (`sync_push`, `sync_pull`, `sync_reencrypt`, `sync_purge_execute`,
   `account_data_truncate`) reads it `FOR SHARE` for the fence + proof check, so no old-key row can commit with a seq
   above the rotation seq. `sync_horizon` and `sync_purge_ledger` take `key_proof` too (a bare session gets nothing).
   `key_vault_update` scopes to `auth.uid()` (the 14c guard). The proof is a BODY parameter on every RPC. **THE VAULT'S
   TABLE-LEVEL WRITE ROAD CLOSES (found by the orchestrator reading `08_phase14b_lockstep.sql:113-118` — MUST):** DROP
   POLICY `key_vault_owner_update`; `REVOKE UPDATE ON key_vault FROM authenticated` (keep SELECT + INSERT for the
   session-only read and create); `GRANT SELECT, UPDATE ON key_vault TO variorum_definer` + a policy in
   `device_cursor_owner_all`'s shape (`for update using (user_id = auth.uid()) with check (user_id = auth.uid())` —
   `auth.uid()` reads the caller's claim inside a definer body exactly as the data RPCs rely on); `key_vault_update` and
   `sync_reencrypt` are OWNED by `variorum_definer` and revoked from `public, anon, service_role`, granted to
   `authenticated` (10's lines 720–742 are the form); `sync_reencrypt` writes the 18 data tables under the definer
   policies the data RPCs already use. Pin: the DDL pin (`AuthRLSDDLTests`) asserts the policy set + grants; the deploy's
   live probe PATCHes the vault with a bare session and expects permission denied. **Shipped facts the file builds on:**
   the sequence is `sync_server_seq` (`stamp_server_seq()` uses `nextval('sync_server_seq')` — the rotation seq takes
   the same `nextval`); the re-run guard reads `sync_meta.lockstep_version` and raises `VARIORUM_11_ALREADY_DEPLOYED`
   (10's guard at its lines 106–112 is the form); the marker bump is `insert into sync_meta … ('lockstep_version','8')`
   with 10's on-conflict form; the current typed refusals are `VARIORUM_STALE_KEY_FENCE` / `VARIORUM_NO_ENTITLEMENT` —
   the new ones are `VARIORUM_KEY_PROOF_REQUIRED` and `VARIORUM_ROTATION_IN_PROGRESS`; `sync_horizon` and
   `sync_purge_ledger` today take `active_key_id` only and are already revoked from `service_role`. **No RPC
   parameter may shadow a column it writes** (the 13j rule). The marker bump is the file's LAST statement.
3. **The client:** `SyncSchema.lockstepVersion = 8`; `SyncTransport`/`SupabaseTransport` pass `key_proof` from the
   engine's key provider (`SyncEncryptionKeys` gains `keyProof`); `VaultEnrollment`/setup compute and land the hash; `SyncEncryptionKeys` gains
   the previous corpus key (+ id) and the rotation seq so the serializer opens a row by the seq rule (§3.10); the
   device identity STAYS a provider method (`SyncKeyProviding.deviceIdentity()`, 1a's reading — never a field on the
   keys value); `SyncTransport`'s `push` / `pull` / `syncHorizon` / `purgeLedger` / `executePurge` (+ truncate) carry
   the proof beside `activeKeyID` (a REQUIRED parameter, the `activeKeyID` precedent), and `SupabaseTransport`'s request
   structs encode it as `key_proof`; the shipped `PullRequest` already encodes `for_device`; the
   FAKE SERVER (`Tests/VariorumCoreTests/Support/FakeSyncServer.swift`, an actor over `SyncTransport` +
   `SyncPurgeTransport`) enforces the proof, the fence, `sync_reencrypt`, the rotation seq (a push that passed the old check
   lands BELOW the seq — the harness serializes the vault row as the SQL's locks do) and the in-progress refusal
   exactly as the SQL does — pins: a session without the proof cannot push, pull, purge, truncate, read the horizon or
   the purge ledger, or update the vault, CAN fetch it, CAN delete the account; the wrong proof refuses; the NULL-hash
   first write lands once and a NULL-hash INSERT is refused; the right `active_key_id` without the proof deletes
   nothing; a second rotation while one is open is refused by the harness exactly as by the SQL. `AuthRLSDDLTests` pins
   the DDL ↔ registry ↔ `lockstepVersion` together; `SerializerCompletenessTests` classifies the new columns.
4. **The deploy checklist** (`notes/plans/pre-13x-deploy-checklist.md`): the 13j choreography — A1 backup rail; run
   `11_…sql` on the mirror at the window — PRE-AUTHORIZED via the stored PAT (her word; the `!` road if the classifier
   blocks it); verify `sync_schema_version()` = 8, the three
   columns, the RPC signatures, the grant sweep (`maintenance/14c-post-deploy-grant-sweep.sql`); her installed marker-7
   app then visibly refuses until batch 2's install — so the deploy is scheduled immediately BEFORE batch 2's migration
   + install, never earlier.
**1b's gate:** the convergence suites + the two-user suites green against the fake server with the proof; the DDL pin;
`swift test` green; NO live round (the mirror is marker 7 until her window). Record + push.

**What batch 1 hands to batch 2:** the migration hooks (1a.1, 1a.3, 1a.4) unrun; the deploy checklist; the key-file
roads unused until enrollment writes them; ledger rows 6–9, 12–14, 18 for U3.

### BATCH 2 → 5 BRIEFS
Written by the orchestrator at each seam, from §4, §5, §7, §12 and §15, in this file's §19 — never from the history file
— **and only after the orchestrator has READ THE SHIPPED CODE each batch's mechanisms assume and checked the design's
claims against it** (the decision 31 precedent: the `e1:` envelope's missing key id was found by reading
`PayloadCipher` and the mirror DDL — a check the design file cannot make for itself; her instruction, relayed from
another session: keep doing that at every batch brief).

### BATCH 2 — postures + the two switches (U3, phase-sized; THREE implementer sessions, 2a → 2b → 2c, each a FRESH Fable; the unit closes at the batch 2 sitting — the deploy window)
**Written after the orchestrator read the shipped protection code** (`StoreProtection` · `ProtectionController` · `StoreKeyGuard` · `StoreLaunchGate` · `AppBootstrap` · `EncryptionKeychain` · `EncryptionSession` · `StoreBackup` · `StoreEncryptionMigration` · `AccountRekey` · `SyncEngine` · `RotationDrill` · the phone's `Features/Protection/`). **Four facts the design's letter did not carry, now binding on the batch:** (i) `StoreAtOpenMode` (auto · biometric · passphrase) is today a STORED three-way setting the routes and faces switch on — it becomes the DERIVED effective gate, a pure function of (posture, Castle's gate style), and the stored setting is deleted (§13); the routes keep their shape. (ii) The 13p escrow family (`StoreKeyGuardKeychain.escrowService`, `loadEscrow` / `saveEscrow` / `deleteEscrow` by store id) put the RAW LIBRARY KEY in iCloud Keychain — the one thing decision 3 forbids ("no raw key ever sits in iCloud"); the family is deleted (§13) AND every legacy escrow item is REMOVED from iCloud Keychain at the migration, with the R1-m1 ownership guard on the delete (pin: after migration no synchronizable item under the escrow service exists for the store). `ProtectionDials.escrowOn` defaults TRUE today, so stores other than hers may hold one. (iii) `StoreEncryptionMigration.migrateIfNeeded` is the plaintext → keyed road (`sqlcipher_export()` into a keyed temp, verify, `rename(2)`, a fault-injector over its `Step`s); the re-key needs its keyed → keyed twin (a NEW key + fresh salt), reusing the same steps and injector so the crash pins ride the same seams. (iv) `SyncEngine` exposes `push()` / `pull()` / `resyncReinitialize()`; "pull to head" and "the outbox is empty" are compositions over `PullReport` and the outbox count — build them once as a named primitive (`SyncEngine.pullToHead()` or its equivalent), never inline. Her devices: Mac = Biometric, escrow off; phone = silent today (both map to Castle at the migration, §11).
**Read first (all three sessions):** `CLAUDE.md`; `notes/SessionResiliencyProtocol.md`; this file §0–§8, §11, §12, §14, §18 (the traps verbatim; the ledger rows named per session), §19 (the batch 1 records + adjudications — 1a hands you the custody family and the key file; 1b the proof, the rotation seq and the previous-key roads); `notes/plans/pre-13x-copy.md` §1, §2b–§2d, §3, §5, §6, §9 (render verbatim); `notes/plans/pre-13x-spike-memo.md` (Q5's query-family rule; surprise 4; Q3 PENDING her sitting). **Rules for all three:** the DEV store is the proving ground; her live real-store app runs beside you and is NEVER touched, quit or opened; NO Release build, NO install refresh, NO real-store migration (the window's — §16); the fake server carries every server claim (the mirror is marker 7 until her window); every pin red-on-old by behavioural revert from a committed state; the tutorial spine green at each gate; every record carries ORCHESTRATOR-DECIDED NOTES; a design fork returns to the orchestrator BEFORE the build; a silent mechanism STOPS with the question in the record.

**2a — custody & posture (the substrate of postures; no switch, no rotation) — ledger 6, 7, 8, 9, 12, 26 (the insurance half is 2b's), 30 (the Mac half done at 1a), 36 (the banner variant is 2c's), 39, 42:**
1. **Posture DERIVED, never a setting** (§3.1's posture row; §14.26): `Posture` (standard · castle) read from the vault when enrolled (an Apple-held copy ⇒ Standard) and from the key file's `apple` copy when local-only; an enrolled library's key file must agree with the vault (reconciled at every ready launch/unlock — a disagreement is a follow, 2c's, or an adopt, batch 3's; 2a lands the derivation + the reconcile's READ and leaves the acts to their batches). `StoreAtOpenMode` becomes the derived effective gate — Standard ⇒ silent; Castle ⇒ the device's gate STYLE (Touch ID / Face ID · Always ask), per device per store id in the 1a per-store dials — and the stored three-way setting is DELETED with `ProtectionPreset`, `ReminderCheckPolicy`-as-a-dial, `relockOnSleepAndScreenLock`-as-a-dial (Castle: always ON), `escrowOn` + `effectiveEscrowOn` + the coupling copy (§13). The idle dial: default 10, offered 5 · 10 · 30 · never, the clock = time since Variorum was last used (row 6). Lock Library Now. The keyless byte-copy of the closed library at lock time when a backup is due, the app's own folder only (row 7). Backups run at the first unlock of the day if due under Castle (§14.8; the freshness copy never cries wolf). Pins: the derivation from both sources; a Castle library's gate style changes (Touch ID ↔ Always ask) move BOTH custody items — the store key's `CustodyHandover` and 1a's sync-record twin — in one transition (the handover pin), with the Always-ask arm holding the sync keys in session memory only; the idle clock; the byte-copy is ciphertext with no key-shaped value.
2. **A's item family** (§3.9; rows 8, 9): ONE query builder carrying `kSecAttrSynchronizable = true` + the shared access group + the data-protection marker on add / read / update / delete / probe (Q5's rule; `KeychainPartitionTests` extended to the family — a flagless delete is a silent no-op, pinned); the Keychain ACCOUNT carries the dev-store scope discriminator (a Debug build never reads the Release install's A — pin); A is minted the first time a Standard library exists on this iCloud (the ceremony-free first launch included), else read; the key file gains its `apple` copy (L under A) + `appleKeyID` at that moment through 1a's `appleBox` road — the VAULT's A copy is batch 3's (setup / leaving Castle writes it); the client NEVER wraps under a key received from the network — A comes from iCloud Keychain or is minted locally (§12's pin). The escrow family DELETED and the legacy escrow items REMOVED at migration (fact ii). The two DEBUG probe doors + `SharedKeychainGroupProbe` + its tests DELETED (row 12). **Q3 (A crossing to the phone) is PENDING her sitting** — the same-Mac round trip is 2a's evidence; the cross-device fact is verified at the batch 2 sitting, and until then the design treats the iCloud road as unverified (§18's measured facts).
3. **Standard's open road** (§3.8; copy §2d + §5): auto-open from this device's bound item; missing item ⇒ the key file's A copy via A from iCloud Keychain (and, for an enrolled library, A → the vault → M → the key file's master copy as the second road — the vault half composes with 2c/batch 3); A absent ⇒ a real **"waiting for iCloud Keychain"** state rendering copy §2d's doors that ACT (P-2: the passphrase and the words; "Open an Existing Library…" is 13x's); never a silent mint over an existing store (pin). The three-value probe (covered · exposed · unknown) re-based on A; the nudge's two tiers + the honest unknown (copy §5) — the exposed tier's copy names iCloud Keychain OFF and the missing secrets.
4. **Row 42 — one key file per snapshot:** `StoreBackup` writes `variorum-backup-<stamp>-<fp8>.keys.json` beside each snapshot at its time (the live key file's bytes of that moment); `existingBackups` / the restore surface pair them; the fingerprint-named folder file keeps serving 1a-era snapshots; the two §12 pins (an earlier pair byte-identical across a passphrase change; a later pair under the new word); NO folder is ever rewritten.
5. **The migration §11, RUN behind the seam** (executes on her devices at the window; the dev store proves it here): at first unlock — 1a's `migrateSyncCustodyToStoreScope` (re-scope + align to the library key's custody: her Mac ⇒ the biometric item); the plain item + the CF-12 opt-in ITEMS deleted; the device identity from `sync_state` into custody (1a's hook); the tokens re-bound (1a's load road); the dial keys retired to the per-store keys (1a's legacy read-through ends for a migrated store); the key file's master copy + the vault's descriptor + corpus key id written FROM HELD MATERIAL (no visit, no typing — this alone gives the vault road); the legacy escrow item removed from iCloud Keychain (fact ii); the passphrase copy follows the first time the passphrase is typed anywhere — the ONE-TIME face (copy §9: *"…Confirm your passphrase once to finish."* / *Later*), on both targets; every migration leg logs a line and NEVER key material (pin: the launch log scanned). The proof hash's landing is 1b's engine round — nothing here.
**2a's gate:** the touched Mac suites + the spine green; `swift test` green; the iOS target builds + the phone lobby/protection suites on the simulator; the migration drill on a DEV store dressed in the 13p-era shape (a plain E2EE item, a legacy-scope bound item, an escrow item, `sync_state.device_id`) — before/after Keychain inventory quoted; the same-Mac A round trip quoted. Record per the BATCH RECORDS rules; the real-store legs handed to the sitting.

**2b — entering and leaving Castle + the rotation runner (the brain Replace All Keys reuses) — ledger 13, 14, 18, 25, 26, 29, 34, 35, 40:** §4 in full on the Mac — the ceremony's screens (copy §2b; progress TEXT now, the original animated indicator is batch 5's); step 1's three refusals (offline · a non-empty outbox · a rotation in progress, decision 32) over the named `pullToHead` primitive; step 2's ONE `key_vault_update` under the OLD proof (M′ under P and W only, C′ under M′, the previous key + its id, the new hash, the key id advanced — the receipt's `rotationStartedSeq`), M′/C′/the previous key into custody; step 3's driver productized from `RotationDrill` (pull below the seq under the previous key, re-seal, `reencrypt`, retry the skipped after a pull; completion clears the key, its id and the seq under the current proof; the driver is the SHARED one any M′-holder runs — 2c's follower calls it); step 4's re-key on the keyed → keyed twin of `StoreEncryptionMigration` (fact iii) + a NEW key file under the new fingerprint (L′ under P, W, M′; no A copy; the old file stays); step 5's custody (both items; re-lock ON); step 6's fresh snapshot PAIR under the new key BEFORE the offer + the scheduled `.md` insurance OFF with its notice; step 7's offer (pre-switch PAIRS only; the outside-copies + Recently Deleted sentences); the per-step persisted marker (`AccountRekeyMarker`'s pattern) re-running a crash at any step; Castle declared only when the vault write landed; without sync, steps 4–7 only. Leaving Castle (copy §2c): A read / minted, ONE vault write adding M under A under the proof, L under A added to this key file, custody gated → plain (both items), re-lock off, nothing rotated. **The runner is ONE type with `entersCastle`** — Replace All Keys (batch 3's door) is steps 1–4 without the posture change. Pins: §12's "Entering Castle" list, the Mac half (a Standard-era key file + A opens no page of the re-keyed library; no fake-server row decrypts under the old C after completion; an old-C push/pull refused by the fence; the vault write is the declaration; a concurrent second switch refuses → the retry becomes a follow (§14.39); the three crash points — after the export before the swap, mid-re-encryption, between the swap and custody — each re-run to completion; the snapshot-before-offer pin; the insurance-OFF + re-enable-warns pin; NO backup folder rewritten — bytes before == after; the delete offer removes only pre-switch pairs; "leaves nothing behind"). Drills: Standard → Castle on the DEV store seeded with the sample library (the timing recorded — the byte-copy of HER store is the sitting's, it needs her passphrase); Castle → Standard; a crash at each seam. **2b — REFINED AT 2a's SEAM (binding on the 2b session, read with the paragraph above; written after the orchestrator read `AccountRekey`, `RotationDrill`, `StoreEncryptionMigration`, `MarkdownInsurance`, `SyncScheduler` and 2a's record):** **(0) Two small items first:** the migration confirm sheet renders copy §9's CORRECTED sentence (*"…in this Mac's own protected Keychain, beside your library's key — never in the library file…"*, the device word interpolated) — the string + its pin; and `Posture.derive`'s arm (c) gains corner 45's discriminator (no `apple` copy + the raw key in the SILENT bound item ⇒ Standard-waiting; the gated item or nowhere ⇒ Castle — presence checks, no unlock; the route tries the Apple landing before deriving), pinned red-on-old (a refused landing followed by a passphrase set must NOT route to a lobby). **(1) The rotation runner REPLACES `AccountRekey`'s 14c road.** That brain still TRUNCATES (`account_data_truncate`) and `resyncReinitialize`s; the design's rotation is IN PLACE (§4 steps 1–4, `sync_reencrypt`, version-neutral) and never truncates. `AccountRekey` (+ `RekeyRecencyProbe`'s UI caller) retires per §13; the truncate RPC keeps its fence for the headless `vault-bootstrap` tool alone; `EncryptionSession.rekeyAccount` becomes the runner's caller. ONE runner type with `entersCastle: Bool`: (a) `pullToHead` — the named engine primitive (fact iv): pull until a window returns zero rows, then the outbox count must be zero (`SyncScheduler.outboxCount()` is private today — hoist it to the engine); refuse offline · a non-empty outbox · `previousCorpusKey != nil` on the fetched vault (decision 32; copy §4's "still finishing" sentence); (b) the vault write: `KeyVaultFormat.create`(M′; C′ under M′; P + W wraps — and the Apple-held copy kept through 1b's `settingAppleHeldCopy` ONLY under Standard's Replace All Keys, never when entering Castle) `.carryingPreviousCorpusKey(id:wrap:)` + the new hash, `updateVault(…, expectedRevision:, keyProof: OLD)`, the receipt's `rotationStartedSeq`; M′ / C′ / the previous key into custody through 1a's family under the CURRENT shape (the shape moves at step 5); (c) the driver productized from `RotationDrill`'s walk — pull below the seq under the previous key (`SyncPayloadCrypto.decryptFromWire` opens by the seq rule), re-seal at the pulled version, `SyncRotationTransport.reencrypt`, retry the skipped after a pull, complete at an empty window with `clearingPreviousCorpusKey()` under the current proof and drop the previous key from custody — the SHARED driver 2c's follower calls, so it lives in core (`Sync/`, the rider) with a progress callback (N of M) the ceremony renders as text; (d) the re-key: the keyed → keyed twin of `StoreEncryptionMigration.migrateIfNeeded` (`rekey(at:from:to:faultInjector:)`, the same `Step`s exported · checkpointed · verified · swapped, the pool closed first, off-main), then the NEW key file (`variorum-keys-<fp16′>.json`: L′ under P, W and M′ via 1a's `masterBox`; no `apple` copy when entering Castle — `StoreKeyEnvelope.removeAppleBox` exists; the old file stays), then custody — `moveCustody(to:)` (2a's; both items, reversing on a refused half) to the Castle gate style, or re-saved silent under Standard's Replace All Keys; the per-step persisted marker on `AccountRekeyMarker`'s pattern (`sync_state`, keyed by STEP so a relaunch resumes at the failed step — the three crash pins), cleared only after step 7; Castle declared only once the vault write landed. **(2) The ceremony's authorization:** Touch ID (an `LAContext` evaluation under Standard, where no gated item exists; the gated item's read under Castle) OR the passphrase checked against the VAULT's current copy (2a's `MigrationConfirmModel` road — `enroll` + `fetchVault`), never the local copy; "set a passphrase if none / generate + confirm the words if none" reuses `PassphraseSetModel` + `PhraseOffer` (the CF-5 flow) — the words land on the vault AND the key file. **(3)** The fresh snapshot PAIR (`StoreBackup.performRun` forced; 2a's pair shape) BEFORE the offer; the scheduled `.md` insurance OFF (`MarkdownInsurance.isEnabled`'s key cleared + copy §2b's notice; re-enabling under Castle shows the Castle warning — the Backups tab's line if in your path, else record it for batch 5); the offer deletes pre-switch PAIRS only (fingerprint ≠ fp′), never a post-switch one. **(4) Leaving Castle:** `AppleKeyKeychain.readOrMint` (2a) → ONE `updateVault` with `settingAppleHeldCopy` under the current proof → the key file's `apple` copy (1a's `appleBox`) → `moveCustody(to: .auto)` → re-lock off; the consent sentence + re-auth (copy §2c). **(5)** Without sync (no vault): steps 4–7 only, the ceremony's words landing on the key file alone. **Evidence:** the pins above and the paragraph's; the drills on the DEV store seeded with the sample library — Standard → Castle with a fake-server sibling holding old-C rows (every row re-encrypted; the sibling's pull refused by the fence until it follows — 2c proves the follow), Castle → Standard, a crash at each of the three seams re-run to completion, the switch's time recorded; NO real-store byte-copy (the sitting's — it needs her passphrase). The Mac and iOS targets build; the ceremony faces are shared code (2c wires the phone's posture acts). Brief refined at 2a's seam from 2a's record.

**2c — the follow on both platforms + the phone's faces — ledger 15 (the follow half; the adopt discriminator is batch 3/4's), 25 (the follower), 30 (the phone), 36 (the banner variant), 40:** §7 — the follow into Castle (open as before; at ready read the vault: no Apple-held copy ⇒ Castle, or the key id ≠ custody's under the SAME owner ⇒ rotated ⇒ the notice, copy §5's *Account moved to Castle* / *Keys replaced elsewhere*; type P or W once — a word typed to open is reused; M′ from the vault's P or W copy, C′ + the previous key under M′; custody replaced; own library re-keyed on 2b's runner + a NEW key file; pull from the own cursor — re-encrypted rows seq-recorded only, pending outbox rows push under C′ with CAS; NO `resyncReinitialize`, no re-stamp); **the un-followed device's state** (*Later*: reads and edits; sync refused — `SyncError.keyProofRefused` → copy §5's persistent banner; every key door unavailable with the sentence; Sign out and Delete work; the notice returns at every open); the follow into Standard (an Apple-held copy in the vault ⇒ add L under A to the own key file from the own iCloud Keychain; custody → silent; the one-time notice); a Standard phone under a Castle account gates at its next open; Castle → Standard propagates silently; decision 10's Always-ask exception (the banner variant; the derived key in session memory serving the vault read). The PHONE (§9; copy's device words): the posture faces shared; Castle = Face ID with the passphrase fallback, Always ask the one switch; Standard = iCloud Keychain; quick capture demands unlock under Castle (§14.16); the phone's migration (§11 — Face ID with passphrase fallback; the one-time confirm). Pins: §12's follow + posture + version-neutral lines (a follower re-pulls to an identical store; the follow lands M′ only after P or W; a device with offline edits across a rotation converges with ZERO conflict variants; the acting device killed after the vault write with rows under the previous key — a follower finishes and clears at head; the un-followed device's list; a Standard phone under a Castle account gates at its next open); the phone suites on the simulator. **U3's four drills close here:** the Standard new-device road (nothing typed — same-Mac now, the phone at her sitting via Q3), the Castle road (P once — the follow of a Standard sibling), Standard → Castle with a sibling following (an old snapshot cannot enroll into the Castle account without P or W; every fake-server row under C′), Castle → Standard. Brief refined at 2b's seam.

**The batch 2 SITTING (= the deploy window, §16):** the deploy (`notes/plans/pre-13x-deploy-checklist.md`, pre-authorized) → the Mac Release refresh behind the A1 rail → her Mac's first unlock (the migration; *confirm your passphrase once*) → her first round (the hash lands) → the phone install (Xcode + her device) → Q3's five minutes → her phone's move to Castle (Face ID with the passphrase fallback) → the two drills' real-store legs. Her decisions to bundle: none open at this writing.

### BATCH RECORDS (appended by each implementer; newest at the bottom)
*(batch 0's record lives in the history file, Part II; batch 0b's in its own plan.)*
**Every record carries a section ORCHESTRATOR-DECIDED NOTES:** what the orchestrator settled under the mandate without
the author, listed there so the cold reviewer sees what was decided without her (her instruction, relayed from
another session).

### BATCH 1a RECORD (the client substrate — the implementer's record; LIVE STATUS first)

#### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- **1a.6 the inherited KnownIssues row (the retired-credential sweep's sign-in occasion):** DONE (`8d9cc250`; the KnownIssues row resolved in the commit that flips this line) — settled: one private `runRetiredCredentialSweep()` (gate on `sync.allowsSync`, `Task.detached(.utility)`) serving both occasions; `legacyCleanup` a REQUIRED init parameter (the `makeSyncKeyProvider` precedent); two spy pins (a `.dev` sign-in after wiring → 0 sweeps; a `.real` sign-in records off-main); the row resolved in KnownIssues when green.
- **1a.2 the key file, format 2:** DONE (`e3882ec6`) — settled: `formatVersion = 2`; `master` / `apple` + `appleKeyID` / `vaultKDF` + `vaultCorpusKeyID` (all optional; a format-1 file decodes with them nil — pin); the `masterBox(key:under:)` / `unwrapKey(master:)` and `appleBox(key:under:appleKeyID:)` / `unwrapKey(apple:)` roads + `recordVaultReconciliation`; naming `variorum-keys-<fp16>.json` (`url(besideStore:fingerprint:)`), the legacy `variorum-keys.json` read when no fingerprint file exists (`locate(besideStore:)`); `StoreBackup.copyKeyEnvelope` writes ONLY WHEN ABSENT (never rewrites a backup folder's key file — the brief's last sentence); snapshots `variorum-backup-<stamp>-<fp8>.sqlite`; `existingBackups` / `date(fromBackupURL:)` accept both names.
- **1a.3 custody per STORE ID:** DONE (`bf05582f`) — settled: `StoreKeyCustody.deviceKeychain(scope:storeURL:)` resolves the store id from the key file beside the store (`locate`); accounts `<scope>-<storeID>-bound` / `-biometric` / `-biometric-probe`; the mint road writes the key file (storeID + fingerprint, no wraps) BEFORE the Keychain add; legacy `<scope>-bound` (DP) and `<scope>` (file-based) migrate read → re-add → verify → delete-legacy (pin: once; a second store never collides — red by behavioural revert of the account naming); the gated legacy `<scope>-biometric` migrates at unlock under the evaluated context.
- **1a.4 device-bound session tokens:** DONE (`013123a7`) — settled: `KeychainAuthStorage` account `session-bound`, DP + `WhenUnlockedThisDeviceOnly`; load reads bound → legacy `session` → migrate → delete legacy; save/clear cover both; `KeychainPartitionTests` extended; a signed-host pin under a throwaway SERVICE.
- **1a.5 the absent-store route:** DONE (`49ac43cd` + `6f3a7b73`) — settled: `StoreLaunchRoute.libraryMissing(demand:)` replaces `openResettingModeToAuto`; `AppBootstrap.State.libraryMissing(LibraryMissingLobby)`; copy §3 verbatim on both targets; "Start a New Library" sets the old key file aside and mints under a NEW store id; the DIALS are read per store id with a legacy scope-key read-through (see the notes — the design's own end state, pulled in so the new library is not born gated and the restored old one is not born silent); red pin on both targets (no dial write, no open).
- **1a.1 sync keys + the device identity in per-store custody:** DONE (`e08389ee` + `bbc64b0f`) — settled: `SyncCustodyRecord { deviceID; material? }` under `<scope>-<storeID>-sync` (bound) / `-sync-biometric` (gated; read under the SAME evaluated `LAContext` as the library key — one prompt) / identity-only bound item + session memory under Always ask; `SyncCustodySession` (the session memory: the record + the DERIVED wrapping key; `drop()` at relock); `SyncKeyProviding` gains `deviceIdentity()` (a second provider METHOD — not a field on `SyncEncryptionKeys`: two simulated devices share one keys value in the multi-tenant suites, and an identity on the keys would collapse two devices into one cursor); the engine's `ensureDeviceID` + the `sync_state.device_id` read deleted (the pull passes the provider's id); `SyncGateOptIn` + `E2EELaunchKeyCache` + the CF-12 toggle/locked faces deleted; `migrateSyncCustodyToStoreScope` behind a seam, unrun; the tripwire refuses mutations under the REAL scopes only.
- **Gate:** DONE — core `swift test` full: **1402 tests in 154 suites passed** (EXIT 0); the Mac gate run over the tutorial spine + every suite the batch touched: **342 tests in 59 suites passed**, 0 skipped, the spine's ten suites inside it at **72 tests / 10 suites**; the iOS target at HEAD: **** BUILD SUCCEEDED **** (`generic/platform=iOS`); the phone lobby suites on the simulator 15/4 (1a.5).

#### THE SETTLED DESIGN, PER ITEM (what a fresh session builds from)
*(Each item's mechanism above is the whole of it; the notes below are the readings the brief left to the implementer.)*
1. **The key file beside the live library is found WITHOUT the key** (the store id must be known before the custody item can be named): `StoreKeyEnvelope.locate(besideStore:)` = the sole `variorum-keys-<fp>.json`, else the legacy `variorum-keys.json`, else nil; SEVERAL fingerprint files beside a live library (a state only batch 2's re-key produces — never 1a) resolve to the most recently modified one. INTERIM, recorded for the architect (a question below).
2. **The store id is stable across re-keys** (the library's identity, not the key's): every key file of one library carries the same `storeID`; custody items are named by it, so a re-key changes the item's VALUE, never its name.
3. **`copyKeyEnvelope` never rewrites** — a backup folder's key file is written once, under the source's own name, and left alone thereafter (the brief's "No code path rewrites a backup folder's key file after it is written"). Consequence for batch 5's copy: a snapshot taken after a passphrase change but under the SAME library key opens with the passphrase the folder's key file was FIRST written under (the twelve words and the master copy are unaffected) — §6's "the passphrase you had when it was made" is loose for that corner; noted for the author.
4. **Dials per store id with a legacy read-through:** `ProtectionDefaults.dials(scope:storeID:)` reads `<scope>.<storeID>.<leaf>` when present, else `<scope>.<leaf>` (her existing dials keep reading exactly what they read); saves write the store-id keys. "Start a New Library" writes the new id's dials as Auto, so the new library opens silently while the old library's lock (its legacy scope key AND its per-store-id custody items) stays untouched — restore the old file and its key file, and it routes to its lobby as before.
5. **Doors rendered on the libraryMissing face (P-2 — a door that cannot act is not rendered):** *Start a New Library* on both targets; *Restore from a Backup…* on the Mac (reveals the app's Backups folder beside the runbook sentence — the 13l restore is a manual road today) and not on the phone (no restore road exists there); *Open an Existing Library…* on neither (13x's door, unbuilt). The title, body and sub-line render verbatim.

#### ORCHESTRATOR-DECIDED NOTES (settled under the mandate without the author — for the cold reviewer)
- The biometric custody item is read ONCE per unlock: one `LAContext` evaluation, the library key and the sync record read under it — one Touch ID prompt (§14.41, ledger row 39).
- The Always-ask session holds the DERIVED wrapping key (never the typed word) for the unlocked session, dropped at relock (decision 10's exception; ledger row 36).
- A re-minted device identity with a non-zero cursor is reconciled as a purge-ledger RETURNER at its first round, never stranded (§14.37, ledger row 39).
- The retired-credential sweep's seam (`legacyCleanup`) is REQUIRED at every composition site (the retirement's round-3 finding 2, the `makeSyncKeyProvider` precedent).
- *(Implementer readings the orchestrator did not pre-settle, listed for the same reader:)* dials per store id with the legacy read-through (note 4 above); the sync custody item under Always ask exists as an IDENTITY-ONLY item (keys in session memory) so an Always-ask library keeps its identity across opens (§12's pin); the tripwire narrowed to the REAL scopes so the per-store E2EE family can be pinned against the real Keychain under throwaway scopes.

#### PINS (each red-on-old; the revert's failing assertion quoted when run)
- **1a.6** `Phase9cAuthWiringTests.aDevStoreSignInAfterWiringNeverRunsTheSweep` + `.aRealStoreSignInSweepsOffTheMainThread` (`8d9cc250`). Green: `Test run with 20 tests in 3 suites passed` (Phase9cAuthWiringTests · HostedSyncStatusReadTests · AccountDoorWiringTests, 0 skipped). RED by behavioural revert (the sign-in occasion's `runRetiredCredentialSweep()` → the old bare `legacyCleanup()`): `Expectation failed: (sweeps.count → 1) == 0` and `Expectation failed: !(…SweepSpy).anyOnMainThread → true` — `Test run with 14 tests in 1 suite failed … with 2 issues`. The required-seam half is compile-time (every `AppServices(` site names `legacyCleanup:`; the sixth site, `TierAndOnboardingTests.withServices`, now declares `{}`).
- **1a.2** core `StoreKeyEnvelopeFormat2Tests` (7 tests — the format-1 read, the wrap-landing rewrite, the master and apple roads, the reconciliation record, the naming, `locate`'s three rules): green `Test run with 21 tests in 3 suites passed` (`swift test --filter StoreKeyEnvelope`); red-on-old BY CONSTRUCTION (the fields, roads and names do not exist on the pre-1a tree). Mac: `Phase13pBackupEnvelopeTests.theEnvelopeRidesBesideTheCopiesAndIsNeverRewritten` (the 13p "refreshes" pin FLIPPED to the design's rule) + `.twoKeysFilesCoexistAndNeitherOverwritesTheOther` + `StoreBackupTests.aKeyedStoresSnapshotCarriesItsShortFingerprintAndBothNamesParse`; green `57 tests in 7 suites` + `70 tests in 11 suites` over every touched suite (0 skipped). RED by behavioural revert of `StoreBackup.swift` (`copyKeyEnvelope` back to the bytes-changed refresh; the snapshot suffix removed): `Expectation failed: try Data(contentsOf: carried) == carriedBytes` · `Expectation failed: try Data(contentsOf: legacy) == Data("legacy".utf8)` · `Expectation failed: (url.lastPathComponent → "variorum-backup-2026-07-01-100000.sqlite").hasSuffix("-\(fp8).sqlite" → "-46c454c6.sqlite")` · `(StoreBackup.shortFingerprint(fromBackupURL: url) → nil) == (fp8 → "46c454c6")` — `Test run with 8 tests in 2 suites failed … with 5 issues`.
- **1a.3** `StoreKeyBindingTests.aLegacyBoundItemMigratesOnceOntoTheStoreID` + `.aSecondStoreUnderTheSameScopeNeverCollides` + `.theStoreURLRoadMintsTheKeyFileAndReScopesALegacyItem` (signed host, throwaway scopes + ids; the three 13p pins moved onto the per-store road). Green: `Test run with 88 tests in 13 suites passed` (StoreKeyBindingTests · KeychainPartitionTests · Phase13pKeychainFactTests · GatedSaveChoreographyTests · Phase13pLobbyTests · StoreLaunchRouteTests · Phase13pControllerTests · Phase13pKeyedDrillTests · EscrowPostureCouplingTests · CustodyReleaseTests · MacWillLockTests · AppBootstrapOffMainTests · CustodyHandoverTests, 0 skipped); core `48 tests in 9 suites` (the store/envelope/restore suites). RED by behavioural revert of `StoreKeyKeychain.boundAccount` to the scope-only `<scope>-bound`: `aSecondStoreUnderTheSameScopeNeverCollides` — `Expectation failed: (firstCustody.load() → nil) == (firstKey …)` at line 199 (removing the second store's item took the first's: ONE item for two stores) and `(secondCustody.load() → nil) == (secondKey …)`; `aLegacyBoundItemMigratesOnceOntoTheStoreID` — `Expectation failed: itemExists(scope: …, storeID: …, dataProtection: true)` (no per-store item exists); the revert also made the legacy migration self-destructive (one account for both shapes), reddening the three 13p pins with it — `Test run with 6 tests in 1 suite failed`. The gated legacy item's unlock-time migration is NOT pinned (it evaluates biometrics — unreachable from any test; the road mirrors the bound item's, presence-verified).
- **1a.4** `SessionTokenBindingTests.aLegacySessionMigratesIntoTheBoundItemOnLoad` + `.freshSavesAreBornBoundAndClearTakesBothShapes` (signed host, throwaway SERVICES — the live `io.lduarte.Variorum.auth` never touched) + `KeychainPartitionTests` (the fourth family). Green: `Test run with 32 tests in 4 suites passed` (SessionTokenBindingTests · KeychainPartitionTests · AuthSessionTests · Phase9cAuthWiringTests) + `11 tests in 4 suites` (the four `KeychainOffMainTests` suites), 0 skipped. RED by behavioural revert of `KeychainAuthStorage.load`/`save` to the 9c file-based item: `Expectation failed: itemExists(service: …, bound: true)` and `Expectation failed: !(itemExists(service: …, bound: false) → true)` in both tests — `Test run with 2 tests in 1 suite failed … with 4 issues`.
- **1a.5** `StoreLaunchRouteTests.aDemandedGateOverAnAbsentStoreIsTheLibraryMissingRoute` (the 13p route pin FLIPPED) + `Phase13pLobbyTests.aDemandedGateOverAnAbsentStoreNeverResetsTheLockAndStartNewMintsAFreshLibrary` (Mac) + `MobilePhoneLobbyTests.anAbsentStoreUnderADemandedModeNeverResetsTheLockOnThePhone` (phone, on the `iPhone 17 Pro, OS 26.2` simulator) + `ProtectionDialsPerStoreTests` (2: the legacy read-through; a store's own save ends it for that store only). Green: Mac `Test run with 81 tests in 14 suites passed` (StoreLaunchRouteTests · Phase13pLobbyTests · ProtectionDialsPerStoreTests · ProtectionDialsTests · Phase13pControllerTests · CustodyReleaseTests · MacWillLockTests · AppBootstrapOffMainTests · Phase13pKeyedDrillTests · ProtectionSetModeOffMainTests · ProtectionReconcileOffMainTests · EscrowPostureCouplingTests · Phase13pCopySweepTests · ProtectionSurfaceRenderTests, 0 skipped); phone `15 tests in 4 suites` (MobilePhoneLobbyTests · MobilePhoneStoreEncryptionTests · MobileRelockCoordinatorTests · MobilePhoneProtectionCopyTests); the iOS target `** BUILD SUCCEEDED **` (`generic/platform=iOS`). RED by behavioural revert of `AppBootstrap.routeAndOpen`'s `.libraryMissing` arm to 13p's silent Auto reset + open: Mac `Issue recorded at Phase13pLobbyTests.swift:239` (the `expected .libraryMissing, got ready` record — the old code opened a pullable library and persisted Auto) and phone `Issue recorded at MobileProtectionTests.swift:378` — `Test run with 9 tests in 1 suite failed` / `5 tests in 1 suite failed`. The route pin is red-by-construction (the old enum case). The faces render copy §3 verbatim (`ProtectionCopy.libraryMissing*`); per P-2 the phone renders Start a New Library only, the Mac adds Restore from a Backup… when the app's Backups folder exists (reveals it in Finder), and Open an Existing Library… renders on neither (13x's door, unbuilt) — recorded for the orchestrator.
- **1a.1** core: `SyncPushTests.theDeviceIdentityRidesTheProviderAndNeverTheStore` (the 13j `deviceIDIsMintedOnceAndKept` pin FLIPPED) · `SyncCustodyIdentityTests` (2: the byte scan of an on-disk plaintext store + its WAL + a `backup(to:)` copy after real rounds and again after `resyncReinitialize` — no corpus key raw/hex/base64, no identity, no `device_id` row; a copy of the library gets a fresh identity and refuses to sync without custody) · `PurgeConvergenceTests.aReMintedIdentityWithANonZeroCursorIsReconciledAsAReturner` (§14.37 / row 39) · `RestoreMatrixTests` M7 REWRITTEN to the design (a restored copy is a NEW device; the source's cursor untouched; the horizon holds at the restored device's position — the laggard rule) · `SyncMirrorDumpAndResyncTests` (resync spares nothing key-shaped). Mac: `CopyFlowRoundTests.underTheBiometricShapeAFreshLaunchReadsNoKeysUntilTheLobbysOneGatedRead` (the CF-12 gate pin REPLACED by the shape) + `.underAlwaysAskTheKeysLiveInTheSessionAndTheIdentitySurvivesARelock` + `.theSessionMemoryHoldsTheDerivedKeyNeverTheWordAndDropsAtRelock` · `CustodyHandoverTests` (the wiring pins over `SyncCustodyRecord`; gate-ON's outgoing act is the identity-only rewrite; `theSyncCustodyMigrationLandsPerShapeThenReleasesTheLegacyItems` — the §11 hook over recording leaves, all three shapes + the refused arm) · `KeychainTripwireTests` (the REAL-scope rule; a throwaway scope writes for real in the signed host) · `KeychainPartitionTests` (the bound + gated per-store queries) · `EncryptionCustodyThreadTests` (the gate probe gone: `["save"]` / `["load"]`). Green: core `Test run with 112 tests in 17 suites passed` (the sync/identity filters incl. SyncCustodyIdentity · PurgeConvergence · RestoreMatrix · RekeyRecencyProbe · AccountLifecycle · MultiTenant · KeyedStoreConvergence); Mac `129 tests in 23 suites` with ONE recorder-wiring failure in the migration pin, fixed at `bbc64b0f` (`CustodyHandoverTests` 10/1 green); the iOS target `** BUILD SUCCEEDED **`. RED by behavioural revert of the engine's push to the 13j store-minted identity (`INSERT OR IGNORE INTO sync_state ('device_id', …)` on the first push): `Expectation failed: try a.storedDeviceID() == nil` ×7 (SyncPushTests:252/256, SyncCustodyIdentityTests:54/86, RestoreMatrixTests:338/359, SyncMirrorDumpAndResyncTests:123/153) + `try copy.storedDeviceID() == nil` (SyncCustodyIdentityTests:104) — `Test run with 17 tests in 4 suites failed … with 9 issues`. The shape/session pins and the returner pin are red-by-construction (no shapes, no session memory, no re-mintable identity on the old tree). NOT pinned: the one-context gated read itself (`StoreKeyGuardKeychain.unlockGated` evaluates biometrics — unreachable from any test; the E2EE record is read under the same `LAContext`, by construction one prompt).

#### DRILLS RUN
The batch's evidence is pins (its kind is substrate); the drills it created and ran are the RED-ON-OLD reverts, one per item, each quoted under PINS above: 1a.6 (the bare MainActor sweep), 1a.2 (the bytes-changed key-file refresh + the suffix-less snapshot name), 1a.3 (the scope-only bound account), 1a.4 (the 9c file-based session item), 1a.5 (13p's silent Auto reset + open, on both targets), 1a.1 (the 13j store-minted `device_id`). Every revert was announced in this record before it started, taken from a committed state, and restored by `git checkout --` with `git diff` empty. The signed-host Keychain pins (StoreKeyBindingTests, SessionTokenBindingTests, KeychainTripwireTests' throwaway write) ran against the REAL Keychain under throwaway scopes/services only — no real-scope item was read or written (the tripwire's law, now the real-scope rule). No drill touched the author's store; her live app ran throughout (`pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated by path at every zero-instance question — none arose: no Release build, no install refresh).

#### SUITE COUNTS
- Core (`swift test`, the full suite at the gate): **1402 / 154**, green (the baseline before the batch, from the bridge retirement's record: 1391 / 152 — +11 tests, +2 suites: `StoreKeyEnvelopeFormat2Tests`, `SyncCustodyIdentityTests`, the returner pin, the flipped device-id pins).
- Mac (one `xcodebuild test` over the spine + every touched suite): **342 / 59**, green, 0 skipped; the spine **72 / 10** inside it. Per-item runs as quoted under PINS.
- Phone (the simulator, `iPhone 17 Pro, OS 26.2`): the four lobby/protection suites **15 / 4**, green.
- iOS build at HEAD: ** BUILD SUCCEEDED **.

#### HANDED FORWARD
- To 1b: `SyncKeyProviding.deviceIdentity()` (the key-provider seam's one wire-visible change: the pull's `for_device` now comes from the provider, never the store; `StaticSyncKeyProvider` is the in-memory world the re-key brain, the bootstrap tool and 1b's fake worlds compose over).
- To batch 2 (unrun hooks): `migrateSyncCustodyToStoreScope`; the store-key and token migrations run implicitly at the first load (TN3137 roads — they are NOT gated behind a seam, since they are the load road's own idempotent healing, exactly `StoreKeyKeychain.load`'s precedent); the key file's `masterBox` / `appleBox` roads unused until enrollment writes them; the dials' legacy read-through retires when §11 "retires the dial keys".
- To batch 3: the plaintext-export byte-scan half of the "nothing key-shaped" pin (the export does not exist yet; the backup + resync halves land here).
- To batch 2 (from 1a.1 / 1a.5): the library key's mode transition (`ProtectionController.setMode`) now has a sibling to move — `E2EECustodyStorage.live(scope:)`'s `setGated` / `setPlain` over the per-store sync record (the store-key handover's twin; the shape follows the dials, which the store reads at each call, so a mode change alone already changes what `save` writes next — the transition of an EXISTING record between items is the seam left for the switch); the Always-ask session is filled by the vault road (batch 4) — `SyncCustodySession.shared.hold(record)` / `holdDerivedWrappingKey`; the dials' legacy read-through retires with §11; `DeviceKeyStore.clear` keeps the identity (CF-11's forget door survives until §13's fold into sign-out).
- To the closeout (the orchestrator, §8): the KnownIssues rows this batch makes resolvable — the E2EE-custody-residual row (the sync custody item is DP + ThisDeviceOnly per store now; the tokens bound) and the custody half of the Castle-bypass row (per-store custody + the re-ruled route) — are left for the closeout as the design says; only the inherited sweep row was resolved here.

#### MACHINERY NOTES
- `-only-testing` names are TYPE names, never file names: `VariorumTests/MobileProtectionTests` ran ZERO tests silently (XCTest's `Executed 0 tests`; no Swift Testing `Test run with` line at all) — the pin lives in `MobilePhoneLobbyTests`. A wrong name is ignored, not refused; count the `✔ Suite` lines against the names passed.
- The phone suites run on the simulator by `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2` (the scheme's devices are the OS 26.2 runtime; `simctl list devices available` shows other runtimes the scheme cannot use; a bare UDID from that list was refused). `generic/platform=iOS` builds the target without a device.
- The DerivedData `App/Variorum/DerivedData/pre13x-b0` served every Mac and iOS build and test run; logs beside it (`1a-logs-*.log`, gitignored).
- swift-dependencies' unimplemented-`Date` trap: an `AppBootstrap` pin that reaches `.ready` must run inside the file's `withDeps` scope (the `.ready` session reads `@Dependency(\.date)`) — the phone twin already did; the Mac twin learned it red.
- Reverts: **no revert in flight** (every drill — 1a.6 / 1a.2 / 1a.3 / 1a.4 / 1a.5 / 1a.1 — restored by `git checkout --` from `8d9cc250` / `e3882ec6` / `bf05582f` / `013123a7` / `6f3a7b73` / `bbc64b0f`, `git diff` empty each time). Pre-revert copies, when made, live in `App/Variorum/DerivedData/1a-prerevert/` (gitignored, inside the worktree; `App/Variorum/1a-prerevert` is NOT ignored — checked with `git check-ignore`).
- The orchestrator's rulings commit (`39c5b395`) landed while this session was reading; the tree was clean at this record's first commit.

#### QUESTIONS FOR THE AUTHOR / ARCHITECT
1. Note 1 above (several fingerprint files beside a live library → newest by modification date) is an interim the lobby's batch will meet at the re-key; is that the rule, or does the re-key set the previous key file aside beside the LIVE library (keeping it only beside snapshots)? 1a produces no such state.
2. Note 3's copy corner for batch 5.
3. The libraryMissing face's doors (P-2): "Open an Existing Library…" is not rendered until 13x builds it, and the phone renders no restore door — is the orchestrator content with the two copy §3 doors being absent on their targets until their roads exist, or should a disabled door with its sentence render instead (a rendered door that cannot act is what P-2 forbids; the copy lists three)?
4. `DeviceKeyStore.clear` (the CF-11 forget door, still wired to account deletion) keeps the device identity and drops the material — read as "this machine has opened this library" surviving a forget; if the forget should also retire the identity (a fresh id at the next enrollment), say so at batch 2/3.

#### ORCHESTRATOR ADJUDICATION — batch 1a (verified against git before adoption: 18 commits `2a9caea6`…`10079de2`, HEAD == `origin/main`, tree clean; the claimed deletions' only residue is three doc comments; the record's counts adopted as recorded)
1. **Several fingerprint key files beside a live library — RULED (architect):** the store id is read from ANY of them (they agree — note 2); the key file for a KEY is chosen by FINGERPRINT — custody's raw key names it directly; with no custody, every fingerprint file beside the store is tried newest-first and the one whose unwrapped key opens the file wins. Nothing is set aside or deleted (§6's "one per library key it has ever held"; the old file is the same-fingerprint second look's road). Batch 2's re-key builds the fingerprint match; the newest-first trial is the lobby's (batch 4). §3.5 carries the sentence.
2. **The post-passphrase-change snapshot corner — RULED BY THE AUTHOR: one key file per snapshot** (decision 11 amended; §6, §3.5, §12, corner 44; ledger 42 — batch 2 builds it on 1a.2's naming; the copy's "the passphrase you had when it was made" is now literally true).
3. **The libraryMissing doors — RULED (architect, P-2's letter):** a door that cannot act is not rendered; the copy's third door ships with 13x's road; the phone gains a restore door when a restore road exists there (the parity line at closeout names it). Content as built.
4. **`DeviceKeyStore.clear` keeps the identity — INTENDED:** the identity is the machine's for this library (decision 13) and survives a forget exactly as it survives a sign-out; the forget door itself folds into sign-out at §13 (batch 5's deletions). A fresh id is minted only where no custody item exists.
The two implementer readings — the identity as a provider METHOD; the dials per store id early with the legacy read-through — are ADOPTED: 1b composes `deviceIdentity()` beside `keyProof`; batch 2 retires the read-through with §11.

### BATCH 1b RECORD (the protocol event — the implementer's record; LIVE STATUS first)

#### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- **1b.1 the vault's additive columns (five at first; SIX since 1b.5) + the lockstep file:** DONE (`c9e5ce03` the server half — `11_pre13x_postures.sql` in 10's shape; the grant sweep extended with the new signatures, the vault's policy NAMES, its insert trigger and its per-role UPDATE privilege; `SyncSchema.lockstepVersion = 8` + the four new refusal markers + `SyncError.keyProofRefused`; the DDL pins: `AuthRLSDDLTests` +9 tests over 11, the fence pins moved onto the gate, `SerializerCompletenessTests.theVaultsColumnsAreClassifiedExactly` (the vault's 23 columns each take a side; the accumulator taught that `references` is an FK continuation); `SupabaseTransportTests` reads 11 — green `84 tests in 5 suites`) + (the client half, this commit — `KeyProof` (token · wire form · hash); `KeyVaultFormat` gains `masterWrappedByAppleHeld` / `appleKeyID` / `keyProofHash` / `previousCorpusKey` (`PreviousCorpusKey { keyID, wrappedByMaster }`, the one-column `<id>:<base64>` value) / `rotationStartedSeq`, `create` lands the hash, the roads `settingAppleHeldCopy` / `removingAppleHeldCopy` / `unwrapMaster(withAppleKey:)` / `carryingPreviousCorpusKey` / `clearingPreviousCorpusKey` / `unwrapPreviousCorpusKey`; `KeyVaultWireRow` maps the five with `decodeIfPresent`; `KeyProofTests` 5 tests — a pre-postures format-1 row decodes with the fields nil, the five round-trip, the key + seq clear TOGETHER, Castle's absence — green `70 tests in 6 suites` over the vault suites).
- **1b.2 the key proof + the RPC bodies + the closed write road:** DONE (`c9e5ce03` the server half; `bef51eb7` `KeyProof`; this commit the CLIENT HALF — `KeyVaultClient.updateVault(_:expectedRevision:keyProof:)` POSTs `rpc/key_vault_update` and classifies the four markers + returns the `UpdateReceipt` (revision · rotation seq); a create without its hash classifies `keyProofRefused`; `VaultEnrollment`'s three update roads and `AccountRekey` (the OLD master's proof authorizes the vault write; the NEW proof the truncate and the keys) and `VaultBootstrap` compute the proof from the master they hold).
- **1b.3 the client (`lockstepVersion = 8`, the keys value, the transports, the fake server, the pins):** DONE (`eb419d91` the client + the fakes + the sweep; `bded78f7` the pins; `6a1106fd` the reverts quoted; `8b7cde76` the APP-SIDE doubles — the three Mac raw-JSON vault doubles and the mobile one call the shared `VaultRPCEmulation` (the RPC route with the proof, the NULL-hash arm, the CAS, the rotation seq, decision 32, the WHOLE replace; PATCH → 42501; a hash-less POST refused) — and the gate below).
- **1b.4 the deploy checklist (`notes/plans/pre-13x-deploy-checklist.md`):** DONE (`6a1106fd`) — the 13j choreography in eight sections: WHEN (immediately before batch 2's migration + both installs; both marker-7 apps refuse until then; the pre-authorization + the `!` road), PREP (the A1 rail's local half; 11 drops no data table), the PRE-DEPLOY SNAPSHOT, THE DEPLOY (whole body, one session), VERIFICATION (marker 8 · the five columns · her row untouched and pre-postures · every signature present and the six old ones absent · ownership · the extended sweep every row OK/INFO with the two UNEXPECTED classes named · THE LIVE PATCH PROBE (403/42501 from a bare session; a 200 is a FAILED closure — stop) · the proof-required probe), THE INSTALLS, THE FIRST ROUNDS (the NULL-hash arm lands ONCE on her row; the phone's round; the nil-together pair; `device_cursor` both devices; the sweep once more), ROLLBACK POSTURE, THE RECORD AT CLOSEOUT (SyncSpec §12's marker 7 → 8 entry).
- **1b.5 THE SIXTH COLUMN (the orchestrator's ruling 1 on this record's questions, `be955835`):** DONE (this commit) — `corpus_previous_key_id text` (nullable) beside `corpus_previous_wrapped_by_master`, which now carries the BARE RFC 3394 wrap — the existing `corpus_key_id` / `corpus_key_wrapped_by_master` pair's shape, never an id packed inside a value; 11 edited in place (undeployed): six alters, `key_vault_update` reads both, refuses one without the other, compares BOTH for the carry-through, sets and clears both with the seq; `KeyVaultWireRow` two fields (`format()` refuses a half); `KeyVaultFormat.PreviousCorpusKey` loses its packed wire value; the fake's vault row + `keyVaultUpdate(previousCorpusKeyID:previousCorpusKey:)`; `RotationDrill`; both `VaultRPCEmulation` copies; the DDL pin (six), the vault-column walk (24 columns), the nil-together pins (key + id + seq) on the format, the wire row and the fake's row; the checklist's verification (24 columns; the six named). Green `142 tests in 10 suites` over the touched suites. RED-ON-OLD: the DDL pin and the column walk under the sixth alter removed (quoted below).
- **1b.6 THE NULL-HASH ARM TAKES THE ROW FOR UPDATE (ruling 5):** DONE (this commit) — `sync_key_gate` PEEKS the hash UNLOCKED first and takes the row `FOR UPDATE` from the start when it is NULL (else `FOR SHARE`), then the fence, then the proof; `sync_key_proof_check` re-reads under the caller's lock (no lock clause of its own) and sets the hash only if still NULL, else compares against what landed. (The ruling's letter — re-read `FOR UPDATE` after the `FOR SHARE` read — is a lock UPGRADE, which deadlocks by construction when a second round also holds `FOR SHARE`; the peek-then-lock gives the ruled OUTCOME — one hash lands, the second call passes or refuses deterministically — without leaning on the deadlock detector. The implementer's reading, recorded here for the reviewer; the ruling's substance is kept whole.) The fake server's actor and `VaultRPCEmulation`'s lock serialize the same way by construction (a doc line at the fake's `checkProof`). Pins: `AuthRLSDDLTests.theNullHashArmTakesTheRowForUpdateFromTheStartNeverByUpgrade` (the peek → the two lock branches → the fence, in that order; the proof check lock-free; `key_vault_update`'s FOR UPDATE before its call) + the gate/proof-check pins re-worded; `KeyProofGateTests.twoRacingFirstProofsLandExactlyOneHashAndTheSecondIsDecidedAgainstIt` (two tasks racing a NULL-hash row: the same proof — both pass, one hash; different proofs — exactly one lands, the loser stays refused, the landed hash stands). Green `91 tests in 6 suites` over the touched suites. RED-ON-OLD quoted below.
- **Gate:** DONE — RE-RUN AFTER THE FIX PASS (this commit; the first gate at `8b7cde76` stood at core 1433/156 · Mac 225/41): core `swift test` full: **1435 tests in 156 suites passed** (EXIT 0; +2 = the FOR UPDATE DDL pin and the racing pin; the ONE `skipped` is the standing env-gated real-server integration pass `basicOfflineEditsConvergeOverTheRealServer`, never run here by design); the Mac gate run over the spine + every touched/composing suite: **225 tests in 41 suites passed**, **0** tests skipped (the log's two `skipped` lines are the AppIntents metadata-extraction build warning, not tests), the spine's ten suites inside it (**72 / 10** standing, re-run alone at the first gate); the phone lobby/protection suites on the `iPhone 17 Pro, OS 26.2` simulator at the first gate: **15 / 4** (the mobile double's only change since is the emulation's id column — covered by the Mac twin's identical copy); the iOS target at HEAD: `** BUILD SUCCEEDED **` (`generic/platform=iOS`); the Mac target `build-for-testing`: `** TEST BUILD SUCCEEDED **` (the test run builds it). NO live round — the mirror is marker 7 until her window.
- **Reverts:** no revert in flight — the six drills below ran from committed states ((a)–(d) from `bded78f7`, (e)–(f) from `83637a38`), each restored by `git checkout --` with `git diff` empty (the pre-revert copies in `App/Variorum/DerivedData/1b-prerevert/`).

#### THE SETTLED DESIGN, PER ITEM (the readings the brief left to the implementer — all revisable at zero cost until the window, since nothing deploys before it)
1. **`sync_pull`'s `key_proof` carries `default null`** — Postgres refuses a defaultless parameter after `max_rows int default 500, for_device text default null` ("input parameters after one with a default value must also have defaults"), and the brief's parameter ORDER is kept as written; the gate refuses a NULL proof with the typed marker, so the default buys nothing but the compile. Every other new signature has no default.
2. **ONE gate helper, seven callers.** The fence + proof + NULL-hash arm live in `sync_key_gate` rather than being inlined seven times (the fence was inlined six times before); the DDL pins assert every data body calls it and the helper's own body carries the mechanisms. The helper is SECURITY INVOKER (it runs inside the definer bodies as `variorum_definer`), owned by `variorum_definer`, revoked from `public, anon, authenticated, service_role` (a NOLOGIN role is its only caller — the `sync_table_pk` posture).
3. ~~**The previous corpus key's ID rides INSIDE the one text column**~~ — SUPERSEDED by the orchestrator's ruling 1 (`be955835`, built at 1b.5): the id is its OWN column, `corpus_previous_key_id`, beside a BARE wrap — SIX columns, the current key's id/wrap pair's shape. The packed `<id>:<base64>` value never deployed (the file was undeployed; nothing to migrate).
4. **`key_vault_update` replaces the format columns WHOLE.** The PostgREST PATCH road set only the keys present in the body, and Codable omits a nil optional — so the 14c re-key (`AccountRekey`, a fresh format with NO recovery wrap) left a STALE `master_wrapped_by_recovery` (the OLD master under the OLD words) on a vault that had one; the shipped pin passed vacuously because its world never landed a wrap before re-keying. The RPC's full replace fixes that class; pinned red-on-old (the PATCH road keeps the stale wrap).
5. **`sync_reencrypt` takes the push posture** (auth · fence + proof · entitlement): it writes the mirror's data tables exactly as a push does; an unentitled account cannot pull to head either (§4 step 1 refuses first). RULED as built (the orchestrator's ruling 2); the lapsed-account-mid-rotation question is 13t's (HANDED FORWARD).
6. **`updated_at` is stamped server-side (`now()`) by the RPC**; the client's `updatedAt` stamp (R2-1's decided one-liner) retires with the PATCH — the decision's substance (a truthful stamp on every update) survives, more truthfully.
7. **The in-memory rotation walk used by the pins lives in test support**, not in core: batch 2 owns the productized driver (pull to head, the marker, completion, custody of the previous key); 1b proves the server semantics under a minimal walk.

#### ORCHESTRATOR-DECIDED NOTES (settled under the mandate without the author — for the cold reviewer)
- The vault's table-level UPDATE road CLOSES in this event (ledger 41): the shipped 14b grant let a bare session PATCH every vault column, the proof hash included (found by the orchestrator reading `08_phase14b_lockstep.sql:113-118`).
- The proof gates the two READ RPCs too (`sync_horizon`, `sync_purge_ledger`): a session without the keys gets nothing from the mirror, a seq included.
- The `BEFORE INSERT` arm (a NULL `key_proof_hash` refused at insert) instead of a CHECK, so the author's existing row stays NULL until her first round lands the hash (the migration arm, hers alone).
- `key_vault_update` scopes to `auth.uid()` exactly as the data RPCs do (the 14c guard).
- The proof is a bearer token presented in the request BODY only — never a URL or a header.
- The rotation seq's lock discipline: `key_vault_update` locks the vault row `FOR UPDATE` and takes `nextval` inside its transaction; every data RPC reads the row `FOR SHARE` for its gate, so a push that passed the old check commits — and takes its seqs — before the vault write (decision 31).
- **The five rulings on this record's questions (`be955835`, settled by the orchestrator under the mandate, without the author):** (1) the previous corpus key's id is its OWN column (`corpus_previous_key_id`; SIX columns; never packed in a value) — built at 1b.5; (2) `sync_reencrypt` stays entitlement-gated like a push; the lapsed-account question → 13t; (3) the stale-recovery-wrap defect recorded as found; the orchestrator checks her live vault's history separately; (4) decision 32's precision: a re-wrap carrying the SAME previous key through is allowed, only a DIFFERENT one refuses — the pin covers exactly that; (5) the NULL-hash arm's first write takes the row FOR UPDATE, never the deadlock detector — built at 1b.6 (the implementer's reading: an unlocked peek chooses the lock, since an upgrade under a second share lock deadlocks).

#### PINS (each red-on-old; the revert's failing assertion quoted when run)
- **1b.1 / 1b.2 (server) — the DDL pins** (`AuthRLSDDLTests`, +9 tests over 11, the fence pins moved onto the gate; `SerializerCompletenessTests.theVaultsColumnsAreClassifiedExactly`; `SupabaseTransportTests.serverSQLFilesCoverExactlyTheRegistry` reading 11): green `84 tests in 5 suites` (`c9e5ce03`). RED-ON-OLD BY CONSTRUCTION — the file, the signatures, the columns, the closure, the helpers and the marker do not exist on the pre-1b tree (`lockstepFiles.last` was 10 at marker 7); the marker drift pin is the two-sided belt (`SyncSchema.lockstepVersion` 8 ⇔ 11's `'8'`).
- **1b.1 (client) / 1b.2 (KeyProof)** — `KeyProofTests` (5): the token 32 bytes / deterministic / distinct per master / the wire round trip / lowercase hex / a malformed token has no hash / a fixed vector; a pre-postures format-1 vault (and wire row) decodes with the fields nil; the five columns round-trip and the previous-key value is ONE column `<id>:<base64>` (a malformed value refuses typed); the key + the seq clear TOGETHER and Castle carries no Apple copy (the absence pin); a wrong master never becomes a copy's content. Green `70 / 6` over the vault suites (`bef51eb7`). Red-on-old by construction (the fields and roads do not exist on the old tree).
- **1b.3 — `KeyProofGateTests` (9) + `RotationDrill`** (`bded78f7`), green `78 / 7` over the seven touched suites:
  - `aSessionWithoutTheProofGetsNothingFromTheMirrorButCanFetchTheVaultAndDeleteTheAccount` — the wrong / empty / malformed proof refused on push · pull · horizon · ledger · purge · truncate · re-encrypt · the vault update; nothing landed, no cursor recorded, the vault row byte-identical; the vault fetched; the account deleted with no proof; the missing-vault arm after.
  - `aBareSessionsDirectVaultPatchIsRefused` — 403 / 42501, nothing written, the hash it tried to overwrite still gates.
  - `theNullHashArmLandsTheFirstProofOnceAndANullHashInsertIsRefused` — her pre-postures row lands the first proof's hash ONCE (the second refused, the first kept, never replaced); a hash-less create refused with nothing written.
  - `theRightKeyIDWithoutTheProofDeletesNothing`.
  - `theOldProofIsRefusedAfterARotationAndTheNewOneAccepted` — the fence refuses the old id FIRST; the new id + old proof refused at the proof; the vault update refuses the old proof; the new proof accepted on every door.
  - `aSecondRotationWhileOneIsOpenIsRefusedAndCompletionClearsTheKeyAndTheSeqTogether` — the seq assigned at begin; a DIFFERENT previous key refused (`rotationInProgress`, nothing written); the SAME carries through keeping the seq; completion clears both on the wire row AND the fetched format.
  - `aPushThatPassedTheOldCheckLandsBelowTheRotationSeqAndNewWritesAbove` — every pre-rotation seq < the rotation seq < every new-proof seq; the old world cannot write past it; the stored rows agree with the seq rule.
  - `theSeamOpensARowBelowTheRotationSeqUnderThePreviousKeyAndAboveUnderTheCurrent` — the seam's rule, both directions, outside a rotation, and the seal side.
  - `reencryptionIsVersionNeutralAndADeviceWithOfflineEditsConvergesWithZeroConflicts` — the walk pulls below the seq under the previous key; a row edited in the pull→send window (and its note — the autosave's `last_touched_at`) is SKIPPED with its current version, every other row REPLACED; every version equals its pre-send value; every row above the seq under the new key, the old key opening nothing; B's two offline take edits CAS cleanly — ZERO conflict variants — and the fleet converges; a fresh follower re-downloads the corpus seq-recorded; completion clears key + seq together; the completed world still reads everything.
  - `aPushRejectsCurrentRowOpensByTheSeqRuleToo`.
  - **RED (a) — the SEQ RULE, production code** (`SyncPayloadCrypto.keyMaterial(forServerSeq:)` reverted to the current key always): `Test run with 10 tests in 1 suite failed … with 3 issues` — `KeyProofGateTests.swift:355:6: Caught error: Sync refused: 'container' row 'c-rot' column 'title' failed to encrypt/decrypt (authenticationFailed)` (the seam pin), `:408:6` the same over the walk's first pre-rotation row, `:540:6` the same on the push-reject's `current`.
  - **RED (b) — the fake's proof gate reverted to no check** (the `sync_key_proof_check` emulation): `Test run with 21 tests in 2 suites failed … with 39 issues` — `KeyProofGateTests.swift:60/64/67/70/73/77/80: Expectation failed: an error was expected but none was thrown` (push · pull · horizon · ledger · purge · truncate · re-encrypt without the proof), `:84: … "UpdateReceipt(revision: 2, rotationStartedSeq: nil)" was returned` (the vault update without the proof), `:91–94` (rows landed, the truncate deleted, the ledger grew, the cursor recorded), `:153/:161: keyProofHash` (the NULL-hash arm never lands), `:195: rowCount == 2` (the proof-less truncate emptied the partition), `:239/:242/:245 … "UpdateReceipt(revision: 3 …)" was returned` (the old proof accepted after the rotation).
  - **RED (c) — the fake's rotation logic reverted** (no in-progress refusal; a version bump on re-encryption): `10 tests in 1 suite failed … with 17 issues` — `KeyProofGateTests.swift:287:15: … "UpdateReceipt(revision: 3, rotationStartedSeq: Optional(2))" was returned` (a second rotation accepted), `:290: fetchVault() == mid` (it wrote), `:474:13: (stored.row.syncVersion → 2) == (versionsBeforeSend[key] → 1)` ×11 (re-encryption bumped every version), `:499:13: conflict variants` on both devices (B's offline edits became S5 conflicts — exactly what version-neutrality exists to prevent).
  - **RED (d) — the scripted vault server reverted** (PATCH accepted with merge semantics; a hash-less insert accepted; the RPC route merging only present keys): `21 tests in 2 suites failed … with 7 issues` — `KeyProofGateTests.swift:177: an error was expected but none was thrown` + `:180: isEmpty → false` (the hash-less create landed), `:127: (statusCode → 200) == 403` + `:128: 42501` + `:129: storedRow ≠ before` (the PATCH wrote), `AccountLifecycleTests.swift:220:9: (fetched.format.masterWrappedByRecovery → 40 bytes) == nil` + `:222: hasRecoveryWrap() == false` (the STALE recovery wrap survived the merge — the settled-design note 4 defect, reproduced).
- **1b.5 / 1b.6 — the fix pass's reverts** (from the committed state `83637a38`, each restored by `git checkout --`, `git diff` empty): **RED (e) — the sixth alter removed from 11:** `Test run with 60 tests in 2 suites failed … with 5 issues` — `AuthRLSDDLTests.swift:1382: (sql → …) contains "alter table key_vault add column corpus_previous_key_id text;"` false, `:1385: (… count - 1 → 5) == 6`, `SerializerCompletenessTests.swift:261: (declared.subtracting(vault) → ["corpus_previous_key_id"]).isEmpty → false`, `:268: 11 must add corpus_previous_key_id`, `:270: (vault.count → 23) == 24`. **RED (f) — the fake's NULL-hash arm made ALWAYS-ADOPT** (every presented proof lands — the shape the ruling forbids): `Test run with 11 tests in 1 suite failed … with 32 issues` — `KeyProofGateTests.swift:212:17: (successes → 2) == 1` (both racing proofs landed), `:218: an error was expected but none was thrown` (the loser was not refused), `:221: vaultRow(for: uid)?.keyProofHash == landed` (a second hash replaced the first), `:157` (the NULL-hash arm's "once" broken), and the whole without-the-proof family (`:60/64/67/70…`, `:234`, `:238`) — an always-adopting arm is no gate at all.
- **1b.3 — the transport / vault-client / lifecycle pins:** `SupabaseTransportSessionTests.theProofRidesTheBodyOnlyNeverTheURLOrAHeader` (six RPCs recorded off the real transport: the proof in every body, in no URL, in no header) + `.aKeyProofRefusalClassifiesTyped` (+ the re-encryption result shapes); `SupabaseTransportTests` push/pull requests encode `key_proof`; `KeyVaultClientTests.theUpdateRidesTheRPCWithTheProofInTheBodyAndAWrongProofWritesNothing` (POST `rpc/key_vault_update`, no URL items, the decoded body, the receipt, `patchCount == 0`, a wrong proof writes nothing) + `.theRPCsRefusalMarkersClassifyTyped`; `AccountLifecycleTests.theLifecycleClientClassifiesRetriesAndDecodes` (the proof's marker → `SyncError.keyProofRefused`; no `key_proof` in any path) + `.aRekeyOverAVaultWithARecoveryWrapLeavesNoStaleWrap` (RED under (d) as quoted); `MultiTenantSyncTests.theEngineSendsItsHeldKeyIDOnBothRoundHalves` records the proof on both halves. Red-on-old by construction where not quoted (the parameters, routes and markers do not exist on the old tree).

#### DRILLS RUN
The batch's evidence is pins (its kind is sync/protocol; the ONE live two-device round on the real mirror after her deploy is U2's closing evidence and belongs to the deploy window — NOT run here: the mirror is marker 7 until then). The drills it created and ran are the six RED-ON-OLD reverts (a)–(d) quoted above (from `bded78f7`) and (e)–(f) from the fix pass (from `83637a38`), each announced in this record before it started, restored by `git checkout --` with `git diff` empty. The rotation walk (`RotationDrill`) is the in-memory drill batch 2's driver productizes. No drill touched the author's store; no Release build; no `/Applications` refresh; no live round; `.env.supabase.local` never read (`pgrep -fl 'Variorum.app/Contents/MacOS'` found no instance at the session's start).

#### SUITE COUNTS
- Core (`swift test`, the full suite at the gate, AFTER the fix pass): **1435 / 156**, green — the first gate read 1433 / 156; the fix pass added the FOR UPDATE DDL pin and the racing pin (the baseline before the batch, from 1a's record: 1402 / 154 — +31 tests, +2 suites: `KeyProofTests` (5) and `KeyProofGateTests` (9) are the new suites; the DDL pins +9, the vault-column walk +1, the transport pins +2, the vault-client pins +2, the lifecycle pin +1, the rest inside existing suites).
- Mac (one `xcodebuild test` over the spine + every touched suite, 41 TYPE names): **225 / 41**, green, 0 tests skipped, at BOTH gates (`1b-mac-gate.log`, `1b-mac-gate2.log`); the spine **72 / 10** inside it (and alone). The Mac subset after the doubles' fix: `53 / 12`.
- Phone (the simulator, `iPhone 17 Pro, OS 26.2`): the four lobby/protection suites **15 / 4**, green.
- iOS build at HEAD: `** BUILD SUCCEEDED **`; Mac build-for-testing at HEAD: `** TEST BUILD SUCCEEDED **`.
- The fix pass's logs: `1b5-core.log` (142/10) · `1b6-core.log` (91/6) · `1b-revert-{e,f}.log` · `1b-core-full2.log` (1435/156) · `1b-mac-gate2.log` (225/41) · `1b-ios-build2.log`.
- Logs (gitignored, beside the DerivedData): `1b-core-ddl.log` (84/5) · `1b-core-proof.log` (70/6) · `1b-core-sync.log` (386/65) · `1b-core-pins.log` (78/7) · `1b-core-full.log` (1433/156) · `1b-revert-{a,b,c,d}.log` · `1b-mac-bft.log` · `1b-mac-tests.log` (the first run, 223/39 with the four app doubles 404ing the RPC — the find) · `1b-mac-tests2.log` (53/12) · `1b-mac-gate.log` (225/41) · `1b-spine.log` (72/10) · `1b-sim-tests.log` (15/4) · `1b-ios-build.log`.

#### HANDED FORWARD
- **To the deploy window (the orchestrator):** `notes/plans/pre-13x-deploy-checklist.md` — run immediately BEFORE batch 2's migration + both installs; the extended sweep; the LIVE PATCH PROBE and the proof-required probe; the NULL-hash arm's first proof landing at her Mac's first post-install round; the SyncSpec §12 running-record entry (marker 7 → 8) at closeout. **Not run here:** the ONE live two-device round on the real mirror after her deploy (U2's closing evidence — the window's).
- **To batch 2 (the rotation's client half):** `SyncEncryptionKeys.rotation` is the seam's input — batch 2 fills it from the vault (`KeyVaultFormat.unwrapPreviousCorpusKey(masterKey:)` + the fetched `rotationStartedSeq`) into custody (`DeviceKeyMaterial` gains the previous corpus key + id, and the provider hands `RotationInProgress` to the seam; `DeviceKeySyncProvider.currentKeys()` passes `rotation: nil` today); the productized driver is `RotationDrill`'s shape (pull below the seq under the previous key — `SyncPayloadCrypto.decryptFromWire(_:)` already opens by the seq rule — re-seal, `SyncRotationTransport.reencrypt`, retry the `skipped` after a pull, complete with `clearingPreviousCorpusKey()` under the current proof) plus the marker, the pull-to-head road (§4 step 1) and the vault write itself (`carryingPreviousCorpusKey` + the new hash in the payload, `updateVault(…, keyProof: oldProof)` → the receipt's `rotationStartedSeq` bounds the walk); the Apple-held copy's roads (`settingAppleHeldCopy` / `removingAppleHeldCopy` / `unwrapMaster(withAppleKey:)`) unused until batch 2 writes Standard's copy; the migration arm's first proof from her Mac is nothing to build — her first round lands it (the checklist §6).
- **To batch 3 (the doors that call `key_vault_update`):** every vault write now carries the proof — `VaultEnrollment.landRecoveryWrap` / `changePassphrase` / `rewrapPassphrase` compute it from the master they hold; Replace All Keys is `AccountRekey`'s shape with the OLD proof on the vault write and the NEW on everything after (built here for the 14c road; batch 3 re-shapes the door per §5); the door-side refusal of decision 32 reads the fetched format's `previousCorpusKey != nil` BEFORE asking (`KeyVaultClientError.rotationInProgress` is the server's backstop); `AccountLifecycleProviding.truncateAccountData(activeKeyID:keyProof:)`; the account-password re-auth road is §5's, untouched here.
- **To batch 4 (the lobby + cross-device):** `SyncError.keyProofRefused` is the un-followed device's typed round refusal — the banner is the copy file's (`Waiting for your passphrase`); the engine's own status sentence is in `SyncError.description`; `KeyVaultClientError.keyProofRefused` on a vault write is the "pick up your new keys first" sentence's trigger.
- **To batch 5 / the closeout:** the KnownIssues rows this batch makes resolvable at the deploy — none directly (1b lands no custody change); the privacy-policy brief line (copy §10) is already true of the design; SyncSpec §3's "THE WIRE IS CIPHERTEXT" paragraph gains the proof sentence at closeout (design §17).
- **To 13t (the sync tier):** `sync_reencrypt` is entitlement-gated like a push (ruling 2) — an account whose tier LAPSES mid-rotation cannot finish re-encrypting the rows below the rotation seq until it is entitled again (its previous key stays in the vault, Replace All Keys and Use Castle refuse meanwhile by decision 32); the tier's posture must say what a lapsed account may still do with its own keys, or exempt `sync_reencrypt` the way the purge doors are exempt.
- **To 13y (per-tenant `server_seq`):** the rotation seq is `nextval('sync_server_seq')` taken by `key_vault_update` — under a per-tenant sequence it is per tenant (decision 31's hand-forward): the same `nextval` on the tenant's counter, and `rotation_started_seq` compares against that tenant's seqs only; `sync_reencrypt`'s fresh seqs likewise. The adopt-road convergence pin (delete → recreate → adopt) is the design's own 13y hand-forward, unchanged.
- **The forked test double (test support, not production):** `VaultRPCEmulation.swift` exists TWICE — `App/Variorum/VariorumTests/` and `App/Variorum/VariorumMobileTests/`, byte-identical — because the project's synchronized folders share no test-support folder between the two test targets; the hoist is a project-file change (a shared test-support folder added to both targets), owned by whoever next touches the project file. The three Mac doubles + the mobile double call it; the core suites' `ScriptedVaultServer` is the full, linked emulation.

#### MACHINERY NOTES
- **Postgres refuses a defaultless parameter after defaulted ones** — `sync_pull`'s `key_proof text default null` (settled-design note 1); the DDL pin quotes the signature verbatim.
- **Foundation's `JSONEncoder` escapes `/` in JSON strings** — a base64 token containing a slash appears as `\/` in the body; a body assertion must DECODE the JSON, never substring-match the raw proof (the vault-client pin learned it red).
- **A post-rotation autosave touches its NOTE too** (`container.last_touched_at`), so a "one moved row" scenario moves two rows (the take and its container) — the version-neutral pin identifies the skipped rows by id, never by count.
- **Swift refuses `NSLock` from an async context** — the `ScriptedVaultServer`'s async router calls SYNCHRONOUS locked helpers around its one `await` (the linked actor); the app doubles stay synchronous and call the pure `VaultRPCEmulation`.
- **The naive DDL accumulator read `references` as a column** (08's FK continuation line) the first time a walk compared `key_vault` — `SerializerCompletenessTests.accumulateDDL` now skips that token.
- **`-only-testing` names are TYPE names** (1a's note, re-confirmed): the app-test files hold several suites each (`Phase8ServicesTests.swift` = `SyncSessionFenceTests` + `IdleCommitSchedulerTests` + `IdleSweepMarkTests` + `StoreBackupTests` + `StoreLocationTests`; `TierAndOnboardingTests.swift` = `HostedSyncTierFaceTests` + `SignUpPresentationTests`; `KeychainOffMainTests.swift` = four suites) — the gate names every TYPE, and 1a's `VariorumTests/Phase8ServicesTests` name would have run zero tests silently.
- The DerivedData `App/Variorum/DerivedData/pre13x-b0` served every Mac, simulator and iOS build/test run; logs beside it (`1b-*.log`, gitignored). The core runs: `App/Variorum/DerivedData/1b-core-*.log`. The reverts' logs: `1b-revert-{a,b,c,d}.log`.
- The orchestrator's ruling commit (`5db36fc7`, the one-key-file-per-snapshot amendment) landed while this session worked; every push here rebased over it cleanly (the record's tail and the ruling's sections never overlapped).
- **No revert in flight.** Pre-revert copies: `App/Variorum/DerivedData/1b-prerevert/` (gitignored, inside the worktree; `git check-ignore` confirmed).

#### QUESTIONS FOR THE AUTHOR / ARCHITECT
1. Settled-design note 3: the previous corpus key's id inside the one text column (`<id>:<base64>`) vs a sixth nullable column `corpus_previous_key_id` — the design says five; a follower cannot open a pre-rotation row without the old id (the AAD names it). Free to flip before the window (the DDL, the wire row, the format's `PreviousCorpusKey` and two pins move; nothing deployed).
2. Settled-design note 5: `sync_reencrypt` under the entitlement gate (the push posture, as built) or ungated like the purge doors (data removal's "a right, never commerce-gated" reasoning)?
3. Settled-design note 4 (a FOUND DEFECT, not a question — stated for the reviewer): the 14c re-key's PATCH road left a STALE recovery wrap on a vault that had one (the old master under the old words beside the new class keys); the RPC's whole-replace fixes it and it is pinned. Nothing on the live mirror is affected today: her vault's recovery wrap belongs to her CURRENT master (no re-key has run on it since the wrap landed) — the orchestrator may want to confirm that reading against the 14c/13p records.
4. The decision-32 carry-through reading (`key_vault_update`'s "the SAME previous key carries through, keeping the seq"): decision 32's letter says "refuses a payload that would set a previous key while one is present"; a passphrase re-wrap mid-rotation sends the fetched format WHOLE — previous key included — so the strict letter would refuse every mid-rotation re-wrap. Built as carry-through (a re-wrap mid-rotation is allowed; only a DIFFERENT previous key refuses). Confirm or flip.
5. The migration arm's concurrency corner (the SQL helper's comment): two first-rounds racing the NULL-hash arm on her row resolve by Postgres's deadlock detector aborting one (its next round presents the proof against the landed hash) — a self-healing retry, recorded, not a defect; say if a `FOR UPDATE` upgrade on the NULL-hash read is preferred before the window.

#### ORCHESTRATOR ADJUDICATION — batch 1b (verified against git before adoption: 13 commits `f9ee2d70`…`12cd1767`, HEAD == `origin/main`, tree clean; `11_pre13x_postures.sql` carries the six columns, the closed write road, the `FOR UPDATE` / `FOR SHARE` arms and the marker `'8'` last; the record's counts adopted as recorded)
1. **The five questions — RULED at `be955835` and BUILT in the fix pass (`8d09a30b`…`12cd1767`):** the sixth column (decision 31); `sync_reencrypt` entitlement-gated with the lapsed-account question handed to 13t; the stale-recovery-wrap defect RECORDED (the author's live vault: the 14b drill deleted and re-created it fresh with new words on 2026-08-04 and no live run of the 14c door on her account is recorded anywhere after; the definitive check is HERS — the 13l sanity-check face with her twelve words before the batch 2 sitting); decision 32's carry-through precision confirmed; the NULL-hash arm exclusive from the start.
2. **The implementer's 1b.6 reading ADOPTED over the ruling's letter:** a `FOR SHARE → FOR UPDATE` upgrade deadlocks by construction when two rounds hold `FOR SHARE`, so the gate peeks the hash unlocked and takes `FOR UPDATE` from the start on a NULL — the ruled OUTCOME (deterministic, never the deadlock detector) met by a sounder mechanism; §3.10's sentence stands as the outcome.
3. **U2's closing evidence is SPLIT:** the convergence suites with the proof are green; the ONE live two-device round on the real mirror is the deploy window's (the checklist §6) — U2 reads DONE-PENDING-THE-WINDOW.
4. The forked `VaultRPCEmulation` (two byte-identical test-support copies) is a project-file hoist owned by whoever next touches the project file — recorded in KnownIssues at closeout if still forked.

### BATCH 2a RECORD (custody & posture — the implementer's record; LIVE STATUS first)

#### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- **2a.1 posture DERIVED + the derived effective gate + the §13 deletions + the idle dial + Lock Now + the keyless byte-copy + backups-at-first-unlock:** DONE (`41afd430` the substrate — `Posture.derive` from both sources with the pre-2a legacy read-through and the no-secrets safety arm; `StoreAtOpenMode.effective(posture:dials:)`; `ProtectionDials { alwaysAsk, relockAfterIdleMinutes = 10 }` with `ProtectionDefaults`' read-through + `retireLegacyKeys`; the routes on `resolve(gate:presence:)` over `StoreLaunchGate.effectiveGate`; `ProtectionController` reshaped — `posture`/`effectiveGate`/`appleKeyVerified`, `moveCustody(to:)` moving BOTH items with a refused sync half reversing the key's move, `setAlwaysAsk`, `setRelockIdleMinutes`, the Apple arm in `reconcile`, `readVaultPosture` wired in `wireOneSecretHooks`, the Mac idle clock on an app-local event monitor + `IdleLockClock`; `ProtectionPreset` · `escrowOn`/`effectiveEscrowOn` + the coupling copy · `relockOnSleepAndScreenLock` · `reminderChecksOn` · `EscrowPostureCouplingTests` DELETED; the pane + the phone sheet rebuilt to copy §1; `AppBootstrap.lock` runs `lockTimeCopy` after the pool closes (`StoreBackup.performLockTimeCopyIfDue` + `checkPendingLockTimeCopies` at the next run; wired in `VariorumApp`); the phone's relock policy on the derived gate) — the byte-copy pin landed at `dc3d2fe0` (`SnapshotPairTests`); the migration's ALIGN leg (`c8b3ca8c`) is what moves a 13p store's custody onto the derived gate; the idle-clock monitor is unpinned by nature (an `NSEvent` monitor — the pure `IdleLockClock` is pinned); the reverts DONE — batches A (the byte-copy) · B (the derivation, the retirement) · C (the both-items handover).
- **2a.2 A's item family + the key file's `apple` copy + the escrow family deleted + the probe doors deleted:** DONE (`41afd430` the family + the arm + the deletions; `dc3d2fe0` `AppleKeyRoundTripTests` — the signed-host round trip under a THROWAWAY account, opt-in `TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1`, run once and quoted under DRILLS RUN) — the legacy-escrow removal leg landed with 2a.5's migration (`c8b3ca8c`, ownership-guarded, drilled); the reverts DONE (batch C: the Apple arm).
- **2a.3 Standard's open road (the A road; the waiting state; the probe/nudge re-based on A):** DONE (`9f28f4d8` — `StoreLobby.Kind` (`castle` · `waitingForICloudKeychain(differentAppleID:)`), `StoreLobby.openWithAppleKey` (the verdict: opened · appleKeyAbsent · differentAppleID · noAppleCopy) + `appleRoad` polled by `beginWaiting(every:)` (5 s in production — no notification exists for a synchronizable item's arrival, the lookup's fact); `AppBootstrap.routeAndOpen`'s `.open` arm: a missing bound item over an encrypted Standard store tries A → the key file's Apple copy → opens and RE-LANDS the bound item (R1-M3), else `.waitingForICloudKeychain(StoreLobby)` — a new `State` both roots render through the lobby faces with copy §2d (the title, the body, the different-Apple-ID sentence, `Enter Passphrase…` / `Enter Twelve Words…` as the doors); never a silent mint (the open refuses typed without a key; nothing lands in custody until a secret or A opens); `ProtectionShapes.tierSentence` renders copy §5's three lines; the nudge's covered/exposed/unknown re-based on `appleKeyVerified` at 2a.1) — the revert quoted under PINS (batch A).
- **2a.4 row 42 — one key file per snapshot:** DONE (`41afd430` the pairs; `dc3d2fe0` `SnapshotPairTests` — the two §12 pins: an earlier pair byte-identical across a passphrase change and NO folder file rewritten, the later pair under the new word; prune takes the pair; the lock-time copy's pin rides the same suite) — the revert quoted under PINS (batch A).
- **2a.5 the §11 migration behind the seam + the one-time confirm face on both targets:** DONE (`c8b3ca8c` — `ProtectionMigration` (`Facts` · `Leaves` · `Report` · `run`), the production leaves `Leaves.live(...)` built in `AppBootstrap.init(variant:gate:)` and run ONCE per store id at the first ready, awaited BEFORE the reconcile; the legacy gated E2EE item read under the lobby's ONE evaluated context in `StoreKeyGuard.unlockGated` and held on `SyncCustodySession.legacyMaterial` until the migration takes it; `StoreKeyGuardKeychain.loadLegacyEscrow`/`removeLegacyEscrow` (the escrow seam's last two verbs); `ProtectionController.reconcilePassphraseWrap` + `deferMigrationConfirm` + `Notice.migrationConfirm`; `MigrationConfirmModel` (copy §9, verbatim) rendered as `MigrationConfirmSheet` (Mac) and `MobileMigrationConfirmSheet` (phone); eight recording-leaves pins in `ProtectionMigrationTests` incl. the NO-KEY-MATERIAL log scan and the off-main pin; the opt-in `ProtectionMigrationDrillTests` under `TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1` — RUN ONCE, its before/after inventory quoted under DRILLS RUN) — TWO FINDINGS at the first launch of the test host with the live road wired (recorded under MACHINERY NOTES): the run executes OFF the main thread by construction now, and the live leaves are never built in the test host (`KeychainTestTripwire.armed`) — the dev store's OWN migration is therefore the Debug APP's, and it stops at the login-keychain ACL prompt for the dev scope's 2026-08-31 legacy item, which needs HER keychain password (handed forward) — settled design: `ProtectionMigration.run` at the first ready (idempotent per store id; every leg logs a line, never key material): the sync custody re-scope (1a's hook) with the legacy gated E2EE item read under the lobby's ONE evaluated context; the plain item + the CF-12 opt-in items deleted; `sync_state.device_id` → custody, then the row deleted; the dial keys retired to per-store (`mode` → `alwaysAsk`); the key file's master copy + the corpus key id from held material (the vault's KDF descriptor lands when the reconcile READ fetches the vault); the legacy escrow item removed (ownership-guarded); the passphrase confirm (copy §9, verbatim) re-wraps the local P copy under the VAULT's descriptor after the typed word unwraps the vault's master — the one-time face; *Later* defers.
- **Gate:** DONE 2026-09-05 on the restored tree — core `swift test` 1435 tests / 156 suites green; the Mac gate run (every 2a-touched suite TYPE — 24 — plus the ten spine suites of `TutorialWalkTests.swift`): 206 tests / 34 suites green, the two opt-in drills reporting `skipped:` (each run deliberately once and quoted under DRILLS RUN); the ten spine suites individually green; iOS `generic/platform=iOS` builds; the phone's protection/lobby/relock/tutorial suites on the iPhone 17 Pro (OS 26.2) simulator 61 tests / 16 suites green. The dev store's own migration run is NOT part of this gate (the login-keychain prompt, MACHINERY NOTES) — handed forward.
- **Reverts:** DONE (three batches A · B · C from the committed state `c8b3ca8c`, 2026-09-05 — every pin red under its own mechanism's revert, quoted under PINS; the tree restored to an empty diff after each; no revert in flight) — behavioural reverts of one mechanism group at a time, signatures kept, pre-revert copies in `App/Variorum/DerivedData/2a-prerevert/` (gitignored, inside the worktree — `git check-ignore` confirmed at this record's first commit), each restored with `git checkout --` and an empty `git diff` before the next; the failing assertions quoted under PINS as they land. If this line still reads STARTING in a later session, check `git status` first: an uncommitted diff in the mechanism files is a revert in flight — restore it from git, never adopt it.

#### THE SETTLED DESIGN, PER ITEM (the readings the brief left to the implementer)
1. **Posture DERIVED.** `Posture.derive(legacyMode:vaultHasAppleHeldCopy:keyFile:)` — a pure function, in this precedence: (a) the pre-2a stored mode READS THROUGH until §11 retires it (a 13p Castle store stays Castle on the marker-8 build's first launch — `.biometric`/`.passphrase` ⇒ Castle, `.auto` ⇒ Standard); (b) the vault's word when enrolled — an Apple-held copy of the master exists ⇒ Standard, none ⇒ Castle (decision 8: every device follows the account); (c) local-only: the key file's `apple` copy ⇒ Standard, else a passphrase wrap ⇒ Castle; (d) NO SECRETS AT ALL (no vault, no key file, no wraps) ⇒ Standard — the safety arm, because a library nobody can re-open by any word must not demand one. `StoreAtOpenMode.effective(posture:dials:)`: Standard ⇒ `.auto`; Castle ⇒ `.biometric`, or `.passphrase` under Always ask. The legacy read (`ProtectionDefaults.legacyMode`) is per store id first, then the scope's — and returns nil once the store has written its OWN `alwaysAsk`, so a NEW library minted over an absent store never inherits the scope's old Castle. `ProtectionDials` = Castle's two switches only (`alwaysAsk`, `relockAfterIdleMinutes` default 10; choices 5 · 10 · 30 · never); the idle clock is time since Variorum was last used (`IdleLockClock.isDue`, fed by an app-local `NSEvent` monitor on the Mac and the phone's relock coordinator). Lock Now runs the composition root's `lock()`; after the pool closes, `StoreBackup.performLockTimeCopyIfDue` byte-copies the encrypted file (no WAL pending, a backup due, the app's own folder only) with NO key leg, records the copy's name in a pending list, and the next keyed run's `checkPendingLockTimeCopies` integrity-checks it and writes the line into that run's detail. A gate-style change is ONE transition moving BOTH custody items — `ProtectionController.moveCustody(to:)`: the store key via `CustodyHandover` first, then the sync record via `SyncCustodyTransition.move`; a refused sync half REVERSES the key's move, so the two families move together or not at all.
2. **A's item family.** `AppleKeyKeychain` is the ONE query builder — `kSecAttrSynchronizable = true`, the shared group `$(AppIdentifierPrefix)io.lduarte.Variorum.shared`, the data-protection marker, `AfterFirstUnlock`; the service `io.lduarte.Variorum.apple-key`, the account `<scope>-apple-key` (the dev scope has its own A by construction — the spike's surprise 4). `readOrMint` is idempotent; production NEVER deletes (the flagless delete is a no-op at the query level; only the test-flagged delete releases — pinned in the round trip). The reconcile's Apple arm (Standard, key in hand): read A or mint it, land the key file's `apple` copy under `appleKeyID`, VERIFY it opens the key (never adopt), and re-land a copy that sits under another A; under Castle the arm never touches A and reads `appleKeyVerified = false`. A refused A write reads as not-landed, never covered. The escrow family and both DEBUG probe doors, the probe brain and their tests are DELETED (row 12); the legacy escrow ITEMS are removed at the migration under the R1-m1 ownership guard (only when the escrowed key IS this store's key).
3. **Standard's open road (§3.8).** The route over an encrypted Standard store: the bound item opens silently; a MISSING bound item tries A against the key file's `apple` copy (`StoreLobby.openWithAppleKey` — `.opened` re-lands the bound item, R1-M3's rule); `.noAppleCopy` / `.appleKeyAbsent` / `.differentAppleID` become `AppBootstrap.State.waitingForICloudKeychain(StoreLobby)` — a real state, copy §2d (the different-Apple-ID sentence when the key file names another A), whose `Enter Passphrase…` / `Enter Twelve Words…` doors run the ordinary envelope road, and whose Apple road is re-probed every 5 s (`beginWaiting(every:)` — no notification exists for a synchronizable item's arrival; the lookup's fact) until A lands, then opens and re-lands. Never a silent mint over an existing store; nothing lands in custody before a secret or A opens. The probe/nudge tiers re-based on `appleKeyVerified`: covered (A verified) · exposed (Standard, A unreadable — the ONLY signal for "iCloud Keychain off", which is undetectable directly) · unknown.
4. **Row 42.** Every snapshot is a PAIR — `variorum-backup-<stamp>-<fp8>.sqlite` + `.keys.json`, the key file copied WITH the snapshot and never rewritten (a later passphrase change leaves the earlier pair byte-identical; the folder's `variorum-keys.json` is written ONLY when absent, for 1a-era snapshots); prune and remove take the pair; the lock-time copy's pair is written the same way.
5. **The §11 migration.** `ProtectionMigration.run(facts:leaves:)` at the FIRST ready of a store id (idempotent — a done leaf per store; a refused leg returns without marking done so the next ready retries), OFF the main thread by construction, awaited before the reconcile. Legs, in order, each logging one line and never key material: (1) the sync custody re-scoped from the 14b items into the per-store pair under the gate the route used — the legacy GATED item's material read under the lobby's ONE evaluated context at unlock (`StoreKeyGuard.unlockGated` → `SyncCustodySession.holdLegacyMaterial`) and taken here, else the plain item; the identity from `sync_state.device_id` (then the row deleted), else minted; the legacy items deleted and the CF-12 opt-in retired only after write+verify; (2) the legacy escrow item removed iff it holds THIS store's key, else left and said; (3) the dial keys retired to the per-store keys (the read-through ends); (4) custody ALIGNED to the derived posture (both items in one transition; no biometry ⇒ Always ask; a refusal leaves the run undone); (5) the key file gains the master copy + the corpus key id from the held material, and the vault's KDF descriptor when the reconcile READ reached the vault (else at the next online ready); (6) for an enrolled library, the one-time passphrase confirm is marked pending — `MigrationConfirmModel` (copy §9 verbatim) verifies the typed word against the VAULT (`enroll` + `fetchVault`), re-wraps the local passphrase copy under the vault's descriptor (`reconcilePassphraseWrap`), clears the mark; a wrong word writes nothing; *Later* hides the face for this launch and keeps the mark. The production leaves are built in `AppBootstrap.init(variant:gate:)` and NEVER in the test host (`KeychainTestTripwire.armed`).

#### ORCHESTRATOR-DECIDED NOTES (settled under the mandate without the author — for the cold reviewer)
- The four binding facts of the BATCH 2 brief: (i) `StoreAtOpenMode` becomes the DERIVED effective gate, the stored three-way setting deleted; (ii) the 13p escrow family put the RAW library key in iCloud Keychain — deleted, and every legacy escrow item REMOVED at the migration under the R1-m1 ownership guard; (iii) the keyed → keyed re-key twin of `StoreEncryptionMigration` (2b's); (iv) `pullToHead` as a named engine primitive (2b's).
- The three-session split of batch 2 under ONE acceptance unit (2a → 2b → 2c), the unit closing at the batch 2 sitting (= the deploy window).
- The same-Mac half of the A road is 2a's evidence; the cross-device fact (Q3) is verified at her sitting — until then the iCloud road is treated as unverified.

#### PINS
*(each red-on-old by a behavioural revert of its mechanism from the committed state `c8b3ca8c`, signatures kept, the tree restored to an empty diff after each batch; the failing assertion quoted verbatim from the run's log)*

**Revert batch A (2026-09-05; `StoreBackup.writeSnapshotKeyFile` → no-op · `StoreBackup.performLockTimeCopyIfDue` → nil · `StoreLobby.openWithAppleKey` → `.appleKeyAbsent` always · `ProtectionMigration.run` without its detached hop; suites `SnapshotPairTests` · `Phase13pLobbyTests` · `ProtectionMigrationTests` — 23 tests, 7 red with 8 issues, the other 16 green):**
- **Row 42 — one key file per snapshot** (`writeSnapshotKeyFile` reverted): `eachSnapshotsKeyFileIsWrittenWithItAndNeverRewritten` — `SnapshotPairTests.swift:77: Expectation failed: (FileManager.default).fileExists(atPath: firstPair.path …) → false` and `:79: Expectation failed: try StoreKeyEnvelope.load(at: firstPair) → nil`; `pruningRemovesTheSnapshotAndItsPair` — `:150: Expectation failed: (FileManager.default).fileExists(atPath: StoreBackup.pairedKeyFile(for: urls[2]).path …)` (no pair ever existed to prune).
- **Row 7 — the keyless byte-copy at lock** (`performLockTimeCopyIfDue` reverted): `theLockTimeCopyIsKeylessCiphertextPairedAndCheckedAtTheNextRun` — `SnapshotPairTests.swift:190: Expectation failed: StoreBackup.performLockTimeCopyIfDue(storeURL: …) → nil`.
- **§3.8 — Standard's open road** (`openWithAppleKey` reverted): `aStandardLibraryWithAMissingBoundItemOpensThroughTheAppleKey` — `Phase13pLobbyTests.swift:478: Issue recorded` (the bootstrap never reaches `.ready`; the `#require` on the ready state); `anAbsentAppleKeyIsTheWaitingStateWhoseDoorsActAndWhoseProbeOpensWhenALands` — `:580: Expectation failed: opened` (A landed in the scripted Keychain and the probe never opened); `anotherAppleIDsKeyRendersTheDifferentAppleIDSentence` — `:609: Expectation failed: (lobby → Variorum.StoreLobby).differentAppleID → false`. (The waiting state's own doors and the copy pins stayed green — they script A absent, which the revert also says.)
- **The KeychainOffMain law on the migration** (the detached hop reverted): `theKeychainLegsNeverRunOnTheMainThread` — `ProtectionMigrationTests.swift:266: Expectation failed: (w.onMain → ["legacyPlainMaterial", "loadLegacyEscrow"]).isEmpty → false` — the exact shape that parked the test host behind the login-keychain prompt.

**Revert batch B (2026-09-05; `Posture.derive` → `.standard` always · `ProtectionDefaults.retireLegacyKeys` → no-op; the pin files' suite TYPES — `ProtectionDialsTests` · `ProtectionDialsPerStoreTests` · `ProtectionCadenceTests` · `ProtectionCopyTests` · `StoreLaunchRouteTests` · `StoreKeyGuardBackingTests` · `Phase13pControllerTests` · `Phase13pLobbyTests` + the recording leaves — 69 tests in 9 suites, 32 issues). A first attempt named `Phase13pProtectionBrainTests` — a FILE name, not a suite type — and xcodebuild exited 0 having executed ZERO tests; caught by the missing `Test run with` line (the brief's own trap), re-run against the types:**
- **Posture DERIVED** (`derive` reverted): `postureDerivesFromTheVaultWhenEnrolledAndTheKeyFileWhenLocalOnly` — `Phase13pProtectionBrainTests.swift:49: Expectation failed: (Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: false, keyFile: standardFile) → .standard) == .castle` and `:52: … (legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: castleFile) → .standard) == .castle`; `theLegacyModeReadsThroughUntilTheMigrationRetiresIt` — `:80: … (legacyMode: .biometric, …) → .standard) == .castle` and `:81: … (legacyMode: .passphrase, vaultHasAppleHeldCopy: true, …) → .standard) == .castle`. Downstream, the same revert turned every Castle library Standard and the consumers said so — `StoreLaunchRouteTests.theRouteDerivesTheGateFromTheKeyFileAndTheStyle` (`Phase13pLobbyTests.swift:82/83/85: gate(castle …) → .auto`), `Phase13pControllerTests.thePostureIsDerivedFromTheKeyFileAndTheVault` (`:186 posture → .standard == .castle`; `:187/:189 effectiveGate → .auto`), `reconcileUnderCastleNeverTouchesTheAppleKey` (`:412–415` — a Castle library read as Standard ran the Apple arm), `alwaysAskMovesBothItemsAndPersistsTheDialInCastleOnly`, `noticesFollowThePolicies` (`:546 notice → nil == .reminderDue`), and the lobby's demanded-mode routes (six `Issue recorded` lines at `:272/:334/:350/:365/:424/:628` — Castle stores opened instead of locking). One upstream cause; corroboration, not second causes.
- **The legacy keys retire** (`retireLegacyKeys` reverted): `retiringTheLegacyKeysKeepsTheStyleAndRemovesEveryLeaf` — `Phase13pProtectionBrainTests.swift:348: Expectation failed: !(ProtectionDefaults.hasLegacyKeys(scope: "probe", storeID: "store-a", …) → true)` and `:349: (ProtectionDefaults.legacyMode(scope: scope, storeID: "store-a", …) → .passphrase) == nil`.

**Revert batch C (2026-09-05; `ProtectionController.moveCustody` with the sync record NOT following the key's move (`syncOutcome = .done`) · `reconcileAppleKey` → early return · `ProtectionMigration.runBody` returning right after "begins"; suites `Phase13pControllerTests` · `ProtectionMigrationTests` — 41 tests in 2 suites, 43 issues):**
- **A gate-style change moves BOTH custody items in one transition** (the sync half reverted): `aMoveIntoTheGateMovesTheLibraryKeyAndTheSyncRecordTogether` — `Phase13pControllerTests.swift:244: Expectation failed: (w.syncLeaves.gatedRecord?.material → nil) != nil`, `:246: … plainRecord?.material → DeviceKeyMaterial(…)` (the plain record still holds the material), `:249: (w.syncSession.record?.material → nil) != nil`; `passphraseGateLeavesNoSilentCustodyAtAll` — `:272/:273` (a silent sync record survives under Always ask); `backToAutoRestoresTheSilentItemAndDropsTheGate` — `:282: (w.syncLeaves.plainRecord?.material → nil) != nil`, `:283: (w.syncLeaves.gatedRecord → SyncCustodyRecord(…))` (the gated item never released); `aRefusedSyncRecordMoveReversesTheLibraryKeysMove` — `:305: Issue recorded` (a refused sync half no longer reverses the key's move — the `#require` on the refusal); `alwaysAskMovesBothItemsAndPersistsTheDialInCastleOnly` — `:344` (the gated sync record still present after Always ask).
- **The reconcile's Apple arm** (`reconcileAppleKey` reverted): `reconcileLandsTheAppleCopyAndVerifiesItOpens` — `:376: Expectation failed: (w.appleKeys → InMemoryAppleKeyBacking).key → nil` (A never minted); `aRefusedAppleKeyWriteReadsAsNotLandedNeverCovered` — `:400: (w.controller.appleKeyVerified → nil) == false`, `:401: appleKeyLandingFailed → false`; `reconcileUnderCastleNeverTouchesTheAppleKey` — `:414: (appleKeyVerified → nil) == false` (the arm's Castle branch is what writes the explicit false); `theAppleArmRunsOnTheDevVariantToo` — `:426: (w.appleKeys.key → nil) != nil`, `:427: (appleKeyVerified → nil) == true`; `anAppleCopyUnderAnotherIDIsReLandedUnderThisDevicesA` — `:440: (w.envelopeBox.value?.appleKeyID → "someone-elses") == (mine.id → "21ff0823-…")`, `:441`.
- **The §11 migration's legs** (`runBody` reverted after "begins"): `everyLegRunsInOrderAndTheLogCarriesNoKeyMaterial` — 11 issues from `ProtectionMigrationTests.swift:125: (report.syncCustody → nil) == .done` through `:134` (the report carries only the "begins" line) and `:109: Caught error: noMasterBox` (the key file never gained its master copy); `aForeignLegacyEscrowItemIsLeftAlone` — `:182`, `:185: w.log.contains { $0.contains("another key's — left") }`; `anAlreadyGatedLibraryReScopesWithoutMoving` — `:201–:208` (the legacy gated material never taken: `(w.legacyGated → DeviceKeyMaterial(…)) == nil`); `noBiometryMeansAlwaysAsk` — `:219–:221`; `aRefusedAlignmentLeavesTheMigrationUndoneForTheNextReady` — `:236`; `aLocalOnlyLibraryRetiresItsDialsAndOwesNoConfirm` — `:248`, `:250: World.done → false`. The confirm face's brain pins (`theConfirmVerifiesAgainstTheVaultThenReWrapsUnderItsDescriptor`, `theControllerReWrapsUnderTheVaultDescriptorAndTheNoticeFollowsThePendingMark`) stayed green — they pin the face, not the legs; the off-main pin read red under this revert (its Keychain-class leaves are not reached when no leg runs; its own mechanism was reverted and proven in batch A).
- **Reverts complete:** every 2a pin proven red under its own mechanism's revert; the tree restored after each batch (`git diff` empty, checked); the pre-revert copies remain in `App/Variorum/DerivedData/2a-prerevert/` (gitignored).


#### DRILLS RUN
- **The migration drill (`ProtectionMigrationDrillTests`, opt-in, run once 2026-09-05 in the signed test host — a scratch encrypted store dressed in the 13p-era shape under a THROWAWAY scope: the 14b plain E2EE item under a throwaway service, the legacy-scope bound store-key item, the legacy synchronizable escrow item holding the RAW key, a `sync_state.device_id` row, the 13p dial keys; the vault's word scripted as Castle):**
```
dress: escrow add 0 (No error.)
BEFORE inventory:
  PRESENT — e2ee legacy plain (device-keys, throwaway service)
  absent  — e2ee per-store GATED (-sync-biometric)
  absent  — e2ee per-store bound (-sync)
  PRESENT — legacy ESCROW (synchronizable, raw key)
  PRESENT — store-key legacy bound (drill-abfb1120-bound)
  absent  — store-key per-store GATED (biometric)
  absent  — store-key per-store bound
BEFORE sync_state.device_id = drill-device-13j · dial keys: mode=auto
route-time gate (the legacy mode reads through): auto · posture standard · biometry available: true
migration 2a: begins for store 4cfa62a3… under auto
migration 2a: sync custody re-scoped → done (identity from sync_state)
migration 2a: legacy iCloud escrow item removed → true
migration 2a: dial keys retired to the per-store keys
migration 2a: custody aligned auto → biometric: done
migration 2a: key file gains the master copy + corpus key id + the vault's descriptor
migration 2a: passphrase confirm pending (the one-time face)
migration 2a: done
AFTER inventory:
  absent  — e2ee legacy plain (device-keys, throwaway service)
  PRESENT — e2ee per-store GATED (-sync-biometric)
  PRESENT — e2ee per-store bound (-sync)
  absent  — legacy ESCROW (synchronizable, raw key)
  absent  — store-key legacy bound (drill-abfb1120-bound)
  PRESENT — store-key per-store GATED (biometric)
  absent  — store-key per-store bound
AFTER sync_state.device_id = nil · legacy dial keys: retired · alwaysAsk=false idle=Optional(15) · opt-in key: retired · confirm pending: true
```
  Read: leg 1 re-scoped the sync custody from the legacy plain item into the per-store pair under the SILENT shape the route used (the identity taken from `sync_state`, the row deleted after); leg 2 removed the legacy escrow item because it held THIS store's key; leg 3 retired the scope-wide dial keys into the store's own (the idle 15 carried, `alwaysAsk` false); leg 4 aligned custody `auto → biometric` — the store key AND the sync record moved to their gated items in one transition (both `-biometric` items PRESENT after, both bound items absent); leg 5 wrote the key file's master copy + the corpus key id + the vault's descriptor from the held material; leg 6 left the one-time confirm pending. The AFTER inventory shows exactly the per-store custody of the design and NONE of the 13p-era items. Pollution: none — every item under `drill-<uuid>` accounts and the throwaway service, deleted at the end of the test.
- **The A round trip (`AppleKeyRoundTripTests`, opt-in `TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1`, run once 2026-09-05 — the REAL family under a throwaway account):**
```
*[removed for publication]*
flagged delete: released true — gone: true
flagless delete: -25300 (The specified item could not be found in the keychain.) — item still there: true
read: id 465c1764-b772-4f48-a6b5-5b5e6ebc4883 — equal: true
readOrMint (again): equal to the first: true
readOrMint (mint): id 465c1764-b772-4f48-a6b5-5b5e6ebc4883, 32 bytes: true
*[removed for publication]*
```
  *[removed for publication]*
- **Pollution to state (the test host boots the DEV store):** the reconcile's Apple arm ran for real in the host at 2a.1's first run — ONE `Variorum-dev-apple-key` item under `io.lduarte.Variorum.apple-key` in the shared group, synchronizable, in her iCloud Keychain, never deleted by production (the dev scope's own A; harmless, dev-only, recorded so no one mistakes it for a stray).

#### SUITE COUNTS
- Core (`swift test`, full): **1435 / 156** green (2026-09-05; the bridge retirement's post-0b baseline, unchanged by 2a — 2a touches no core file).
- Mac, the gate run (24 touched suite types + the ten spine suites): **206 / 34** green; the two opt-in drills skipped in the gate and run once each on their own (`ProtectionMigrationDrillTests` 1/1; `AppleKeyRoundTripTests` 1/1).
- Mac, the touched-suite runs at the commits: `41afd430` controller suites 35/2 (the one accidental FULL run 2100/378 with one honest failure fixed — the reset door authorizes from the disk, P2); `9f28f4d8` lobby suites 15/2 (its commit message says 22/2 — a miscount at the message, the log says 15/2); `dc3d2fe0` pairs 3/1 + the round trip 1/1; `c8b3ca8c` migration+controller+lobby+off-main+handover 73/7.
- iOS: `generic/platform=iOS` builds; the phone's protection · lobby · relock · store-encryption · tutorial suites on the iPhone 17 Pro (OS 26.2) simulator **61 / 16** green.
- The spine (`TutorialWalkTests.swift`, TEN suite types — the standing 72/10): every suite green inside the gate run.

#### HANDED FORWARD
*(to 2b, 2c, batch 3, the window — filled at the gate; the first entries below)*
- **To the batch 2 sitting / her hands (the dev store):** launch the Debug app (dev store) once and enter the login-keychain password at the *Variorum Dev wants to use your confidential information…* prompt (Always Allow) — the dev store's §11 migration then runs to `done` and the one-time confirm face appears; the orchestrator reads the `[protection] migration 2a:` lines from `log show`. Until then the dev store stays in the 13p shape (nothing lost; the legacy read-through keeps it opening as before).
- **To the window (the real store, both devices):** the migration runs at the first ready of the marker-8 build; watch for a keychain prompt at the legacy items' DELETE leg (MACHINERY NOTES) — *Always Allow*; the confirm face's *Later* is safe at any point (the mark persists until confirmed). The vault's KDF descriptor lands in the key file only when the reconcile READ reaches the vault — offline first launches leave it for the next online ready (logged as such).
- **To 2b (the two switches + the rotation runner):** `ProtectionController.moveCustody(to:)` is the ONE act both switches compose (it already moves both items and reverses on a refused half); the choose doors are UNRENDERED — `ProtectionCopy.useStandardDoor` / `useCastleDoor` and the two posture cards exist as strings and faces, but no button flips a posture yet (entering Castle is the rotation — 2b's; leaving is a re-wrap — 2b's); `StoreKeyEnvelope.removeAppleBox` exists for the Castle entry; the Standard entry's vault half (the master's Apple-held copy in the vault) is batch 3's read for `readVaultPosture`.
- **To 2c (the follow + the phone):** `ProtectionController.readVaultPosture` is a READ only — the follow acts (a device learning the account changed posture and moving its own custody) are not built; the phone renders the waiting state, the migration bar/sheet and the two-switch sheet, and its relock coordinator takes the derived gate — the phone's own custody moves ride `moveCustody` like the Mac's.
- **To batch 3:** the vault's Apple-held copy of the master (`VaultPostureReading.hasAppleHeldCopy` is read from the vault today; nothing WRITES it yet).
- **The batch 2 sitting's Q3** (A crossing to the phone): unverified — the same-Mac round trip is 2a's evidence; the item is synchronizable in the shared group by construction.
- **The dev-scope A pollution** (DRILLS RUN): one `Variorum-dev-apple-key` item in her iCloud Keychain; leave it.

#### MACHINERY NOTES
- The batch's DerivedData: `App/Variorum/DerivedData/pre13x-b0` (reused); logs beside it as `2a-*.log` (gitignored).
- **THE HANG (2026-09-05, the first launch of the test host with the live migration wired):** `xcodebuild test` reported *the test runner timed out while preparing to run tests* after `[protection] migration 2a: begins for store 4077e8a5… under auto` — the dev store's — and nothing more. `sample` of the host: the MAIN thread parked in `ProtectionMigration.run` → `E2EEKeychainStorage.legacyLoadPlain` → `SecItemCopyMatching` → `SecKeychainItemCopyContent` → securityd decrypt (`mach_msg`) — the login-keychain ACL road. Launching the dev-store Debug APP itself showed the dialog: *"Variorum Dev wants to use your confidential information stored in \"io.lduarte.Variorum.e2ee-keys\" in your keychain. To allow this, enter the \"login\" keychain password."* (screenshot `App/Variorum/DerivedData/2a-devapp-launch.png`, gitignored; `security find-generic-password` without `-w`: the item was created 2026-08-31 07:24 UTC in `login.keychain-db` — a Debug build's, whose signature this rebuilt binary does not match). Two consequences, both fixed here: (1) **the migration ran its Keychain legs on the MainActor** — under approachable concurrency a nonisolated async function runs on its CALLER's actor and the bootstrap calls from the MainActor — so `run` now hops to a detached utility task by construction (the KeychainOffMain law; pinned: `theKeychainLegsNeverRunOnTheMainThread` records `Thread.isMainThread` in the Keychain-class leaves — red without the hop); (2) **the test host must never run the live migration over the dev scope** — the tripwire refuses every real-scope Keychain mutation there, so the road could only ever end `writeRefused` at every launch — `AppBootstrap.init(variant:gate:)` builds no production leaves when `KeychainTestTripwire.armed` (the drill under throwaway scopes is the real-Keychain proof; the bootstrap's own migration road is pinned through injected leaves). What is NOT fixed, deliberately: the dev scope's legacy item stays behind its prompt — answering it needs her login-keychain password, which no session types; the dev store's app-level run is handed forward. **For the WINDOW (her real store):** the Release app has read its own legacy item on every sync round since 14b without a prompt (its ACL trusts the app), so the migration's read is silent there; the one leg the drill cannot show under the real ACL is `SecItemDelete` of the legacy login-keychain items — if a prompt appears at that leg on window day, it is this class, and *Always Allow* is the answer.
- **Suite names are TYPES, and a file is not a type:** `-only-testing:VariorumTests/Phase13pProtectionBrainTests` matched NOTHING (the file holds `ProtectionDialsTests`, `ProtectionDialsPerStoreTests`, `ProtectionCadenceTests`, `ProtectionCopyTests`, `StoreLaunchRouteTests`, `StoreKeyGuardBackingTests`), and xcodebuild exited 0 with `Executed 0 tests` — caught only because the `Test run with N tests` line was missing. The spine file likewise holds TEN types (the standing 72/10 is ten suites); the gate run names all ten.
- **The accidental full Mac run at 2a.1** (an ugrep multi-file string bug in a suite-discovery command ran the whole `VariorumTests` bundle): 2100/378 with ONE failure — `setPassphraseRefusesOverAnUnreadableSidecar…` — a real 2a defect (the reset door read a stale envelope projection), fixed at `41afd430` (`resetPassphrase` refreshes the envelope facts first, the P2 pattern). Recorded because the accident found it.
- **The commit message of `9f28f4d8` says "lobby suites 22/2"; the run was 15/2** (the log). A miscount at the message, not the log; the record's counts are the log's.
- **The batch C off-main pin** (`theKeychainLegsNeverRunOnTheMainThread`) went red under the LEGS revert at `:267` — its "…and the run did run" clause, not its off-main clause (no leg reached a Keychain leaf); its own mechanism was reverted and proven in batch A at `:266`.

#### QUESTIONS FOR THE AUTHOR / ARCHITECT
1. **Copy §9's first sentence is stale against the final design** — *"Variorum now keeps your sync keys inside your encrypted library"* — the exact phrase `e499f5ca` corrected elsewhere (the keys live in per-store custody beside the library key, NEVER in the file). Rendered VERBATIM per the render-don't-re-derive rule and flagged here: the orchestrator should correct the copy file (copy §4's enrolled line has the true sentence: *"This Mac keeps your sync keys in its own protected Keychain, beside your library's key."*) and the string follows in one edit before the window.
2. **A Standard library whose A write was REFUSED that then sets a passphrase derives Castle at its next route** (local-only, no vault): the key file holds a passphrase wrap and no `apple` copy, and rule (c) reads Castle. Rare (the Keychain-refusal class) and self-describing (the lobby says Castle), but it is a posture the user never chose; the honest fix is the reconcile re-trying the Apple landing at every Standard ready (it does — `reconcileAppleKey` runs at each ready; the corner is the ONE route between a refused landing and the next ready). Recorded, not changed — the architect's call whether the route should also try to land A before deriving.
3. **"iCloud Keychain is off" is undetectable on macOS** (the lookup's fact: a synchronizable `SecItemAdd` succeeds with iCloud Keychain off; no toggle API; no arrival notification). The exposed tier therefore fires only when A is UNREADABLE, never when it merely will not sync — a Standard library on a Mac with iCloud Keychain off reads "covered" while its key would not reach a second device. Copy §5's covered line says what the code can know; the sitting may want a sentence for the off case (the phone's arrival is the only proof, Q3).
4. **Copy §9's confirm sheet renders the stale sentence verbatim** (question 1) — the one-time face every enrolled user meets at the window says "inside your encrypted library". Fix the copy file before the window; the face re-renders it unchanged.
5. **The dev store's own §11 run needs her login-keychain password once** (the Debug app's ACL prompt — MACHINERY NOTES); until then the dev store stays in the 13p shape, opening as before. Not a defect; a fact of the dev scope's 2026-08-31 item.

#### ORCHESTRATOR ADJUDICATION — batch 2a (verified against git before adoption: 10 commits `cfda8938`…`4b2eb646`, HEAD == `origin/main`, tree clean, no instance running; the probe doors and `ProtectionPreset` gone; `ReminderCheckPolicy` survives as a brain, not a dial, and `escrowService` only as the DELETE leg's name — both correct; the record's counts adopted as recorded)
1. **Copy §9's stale sentence (questions 1 and 4) — FIXED in the copy file** (the sync keys live in this device's protected Keychain beside the library key, never in the file); the rendered string + its pin are 2b's item (0).
2. **A refused Apple landing followed by a passphrase set derived Castle (question 2) — RULED (architect), corner 45:** Castle is ENTERED, and entering moves the raw key behind Touch ID or nowhere; so with no `apple` copy the custody SHAPE tells Standard-waiting (the raw key in the silent bound item) from Castle (the gated item or nowhere) by presence alone — arm (c) gains the discriminator and the route tries the landing before deriving; §3.1's posture row carries it; 2b builds it (item 0).
3. **"iCloud Keychain is off" is undetectable (question 3) — ACCEPTED, corner 46:** the covered tier's sentence now hedges in the copy file ("as far as this Mac can tell"); Q3's phone arrival is the only proof.
4. **The dev store's login-keychain prompt (question 5) — HERS, bundled for the sitting** (the checklist §5 carries it, and the real store's possible prompt at the DELETE leg — Always Allow).
5. The `Variorum-dev-apple-key` item in her iCloud Keychain (the dev scope's own A) is left as recorded.

### BATCH 2b RECORD (entering and leaving Castle + the rotation runner — the implementer's record; LIVE STATUS first)

#### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- **2b.0 item (0) — the corrected copy §9 string + its pin; `Posture.derive`'s corner-45 discriminator + the route's landing-before-deriving + its pin:** DONE (this commit; the hash recorded at the next flip) — built: `ProtectionCopy.migrationConfirmBody` renders copy §9's corrected sentence verbatim (the device word interpolated); `RawKeyCustody { silent · gatedOrNone · unknown }` + `Posture.derive(…, rawKeyCustody:)` — arm (c)'s no-`apple`-copy case answers Standard when the raw key sits in the SILENT bound item and Castle only when it is gated or nowhere (`.unknown` keeps the older reading); `RoutePostureFacts.rawKeyCustody`; `StoreLaunchGate.effectiveGate` reads the shape by presence (`loadAuto`) and TRIES THE APPLE LANDING before deriving (a silent, passphrase-wrapped, Apple-less key file whose A is readable gets its copy landed at the route); the controller derives from its resident (after adoption: resident ⇒ gated-or-none, none ⇒ silent); the sync custody's shape read and the migration's target derive pass the real presence. Pins: `ProtectionDialsTests.aRefusedAppleLandingNeverMakesCastle` · `StoreLaunchRouteTests.aRefusedLandingFollowedByAPassphraseSetNeverRoutesToALobby` · `ProtectionCopyTests.theMigrationConfirmRendersCopyNinesCorrectedSentence`. Green: `Test run with 107 tests in 12 suites passed` (ProtectionDialsTests · ProtectionCopyTests · StoreLaunchRouteTests · Phase13pControllerTests · Phase13pLobbyTests · ProtectionMigrationTests · CustodyHandoverTests · CopyFlowRoundTests · ProtectionDialsPerStoreTests · ProtectionSurfaceRenderTests · Phase13pCopySweepTests · StoreKeyGuardBackingTests; 0 skipped). RED-ON-OLD: PENDING (the revert follows this commit).
- **2b.1 the core substrate — `DeviceKeyMaterial`'s rotation fields + the provider's `RotationInProgress`; `SyncEngine.pullToHead()` + `outboxCount()` hoisted; the per-STEP `RotationMarker` replacing `AccountRekeyMarker`; the SHARED driver `CorpusRotation` in `Sync/` (the vault-write payload, the bounded remainder walk with a progress callback, the completing write) + its pins:** NOT-STARTED — settled: the driver is productized from `RotationDrill`'s walk; the marker lives in `sync_state` keyed by step with non-secret facts (step · entersCastle · the old and new library-key fingerprints · the new corpus key id); the engine refuses rounds while ANY step is set (the R1-1 doctrine, kept).
- **2b.2 the keyed → keyed re-key twin `StoreEncryptionMigration.rekey(at:from:to:faultInjector:)` on the same `Step`s + the crash matrix:** NOT-STARTED — settled: the same export · checkpoint · verify · swap road with the source opened KEYED and the temp under the new key + a fresh salt; the injector rides the same seams.
- **2b.3 the app runner `PostureSwitchRunner` (Shared) with `entersCastle` — steps 1–7; the bootstrap's re-key road (flush → close the pool → swap → reopen under L′); `AccountRekey` + the recency probe's UI caller retired, `EncryptionSession.rekeyAccount` the runner's caller; the fresh snapshot PAIR before the offer; the scheduled `.md` insurance OFF with its notice; the offer over pre-switch PAIRS; leaving Castle:** NOT-STARTED — settled: see THE SETTLED DESIGN below.
- **2b.4 the ceremony — `PostureSwitchModel` (Shared) over copy §2b / §2c, the vault-checked passphrase re-auth, decision 32's + the offline + the outbox refusals at the door, the Mac sheet + the pane's two doors, the ceremony held on the controller across the reopen:** NOT-STARTED — see QUESTIONS 1 (the Touch-ID-only arm cannot wrap the new keys; built over the typed passphrase; the arm is the architect's).
- **2b.5 the Mac pins (§12's "Entering Castle" Mac half, "leaves nothing behind", Backups, one rotation at a time):** NOT-STARTED.
- **2b.6 the drills (the signed host, throwaway scopes; a scratch keyed store seeded with the sample library; a fake-server sibling): Standard → Castle · Castle → Standard · a crash at each of the three seams re-run to completion · the wall time:** NOT-STARTED.
- **Gate:** NOT-STARTED — core `swift test` full; the touched Mac suites + the ten spine suites; the Mac and iOS targets build. Counts PENDING.
- **Reverts:** REVERTS STARTING after this commit — item (0)'s two mechanisms (`Posture.derive`'s discriminator + the route landing; the copy §9 string), from the committed state this line rides; restored by `git checkout --` with `git diff` empty. Pre-revert copies, when made, go to `App/Variorum/DerivedData/2b-prerevert/` (gitignored, inside the worktree); every revert is announced here before it starts and taken from a committed state.

#### THE SETTLED DESIGN, PER ITEM (filled as each lands)
*(pending)*

#### ORCHESTRATOR-DECIDED NOTES (settled under the mandate without the author — for the cold reviewer)
- The rotation runner REPLACES `AccountRekey`'s 14c truncate road — in place through `sync_reencrypt`, never truncating; `account_data_truncate` keeps its fence for the headless `vault-bootstrap` tool alone.
- `pullToHead` + the outbox count are ENGINE primitives (fact iv), never inlined.
- The keyed → keyed re-key is `StoreEncryptionMigration`'s twin on the same `Step`s (fact iii).
- The per-step persisted marker on `AccountRekeyMarker`'s pattern, resuming at the failed step.
- Corner 45's discriminator (a refused Apple landing never makes Castle) and the corrected copy §9 sentence.

#### PINS
*(pending)*

#### DRILLS RUN
*(pending)*

#### SUITE COUNTS
*(pending)*

#### HANDED FORWARD
*(pending)*

#### MACHINERY NOTES
- The batch's DerivedData: `App/Variorum/DerivedData/pre13x-b0` (reused); logs beside it as `2b-*.log` (gitignored).
- No instance of the app was running at this session's start (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty); HEAD `663476a6`, tree clean.

#### QUESTIONS FOR THE AUTHOR / ARCHITECT
1. **A DESIGN FORK, found reading before building — the Touch-ID-only arm of the two rotation doors cannot produce the new keys' wraps.** Entering Castle (§4 step 2) and Replace All Keys (§5) rewrite the vault with **M′ under P and under W**, and the new key file with **L′ under P and W** — every one of those wraps needs the SECRET-DERIVED key (`PassphraseKDF.deriveKey(P, descriptor)` / `RecoveryPhrase.recoveryWrapKey(W)`), and nothing in custody yields it: the vault holds M under K_P (not K_P), the key file holds L under K_P (not K_P), and decision 3.1 says P and W are NEVER stored. So "Touch ID, or the passphrase — confirms" (copy §2b Screen 4; §4; §5's Castle row for Replace All Keys) and "You already have twelve words. They still open your library." (Screen 3) cannot both hold: with Touch ID alone, M′ cannot be wrapped under P; with the words untyped, M′ cannot be wrapped under W (the vault would lose its recovery wrap — exactly the 14c `AccountRekey` shape the design retires). **Two honest options:** (A) **the ceremony types the passphrase ALWAYS** (Screen 4's confirmation is the passphrase, vault-checked — Touch ID is not sufficient because the new keys must be wrapped under it), and when twelve words EXIST the ceremony reuses 2a's Screen 3 ("Type My Words…" → the same twelve wrap M′ / "Generate New Ones" → fresh words replace them everywhere) instead of "They still open your library" — decision 5's letter ("Turning on sync requires a passphrase AND the twelve words…; so does entering Castle"), §7's follow (which writes only the TYPED secret's copy — the design plainly assumes no derived key is cached), zero new custody; or (B) **the per-store custody item gains the DERIVED wrapping keys** (K_P + its descriptor, K_W) beside M — no new power (M already equals both), validated against the vault's descriptor at use (a change elsewhere ⇒ fall to typing), refreshed whenever a word is typed — which makes Touch ID sufficient but contradicts §7's letter and widens what custody holds. **This batch BUILDS the runner over INPUT secrets** (a `RotationSecrets` value: the passphrase-derived key + its fresh descriptor, and the recovery-derived key or nil), so either answer plugs in without touching the driver, **and builds the ceremony on (A)'s road** (the typed passphrase, vault-checked; the words typed-or-regenerated when they exist) as the PROVISIONAL — the Touch-ID-only confirmation is NOT built. The architect rules before the copy is re-voiced; the recorded consequence under (A): a Castle entry without the words typed regenerates them (the standing CF-5 mandatory step), never silently drops the vault's recovery wrap.
